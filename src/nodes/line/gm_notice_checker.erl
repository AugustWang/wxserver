%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-8-6
%%% -------------------------------------------------------------------
-module(gm_notice_checker).
-include("mnesia_table_def.hrl").
-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% External exports
-compile(export_all).
%% for testing function.
-export([start_link/0]).
-include("festival_define.hrl").
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start({global,?MODULE}, ?MODULE, [], []).

publish_notice_id(Id)->
	case global:whereis_name(?MODULE) of
		undefined->	gen_server:start_link({global,?MODULE}, ?MODULE, [], []);
		Pid-> Pid!{publish_notice_id,Id}
	end,
	{ok}.
	%%gs_rpc:cast(node(), ?MODULE, {publish_notice_id,Id}).

publish_notice_content(Content,Ntype)->
	self()!{publish_notice_content,Content,Ntype}.
	%%gs_rpc:cast(node(), ?MODULE, {publish_notice_content,Content}).

update_gm_notice(Id)->
	self()!{update_gm_notice,Id}.

mall_sale_test()->
	case global:whereis_name(?MODULE) of
		undefined->slogger:msg("gm_notice_checker process not alive~n");
		Pid-> Pid!{mall_sale_test}
	end.
			

cancel_mall_sale_test()->
	case global:whereis_name(?MODULE) of
		undefined->slogger:msg("gm_notice_checker process not alive~n");
		Pid-> Pid!{cancel_mall_sale_test}
	end.

	%%gs_rpc:cast(node(), ?MODULE, {update_gm_notice,Id}).
%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	put(mall_test_state,false),
	put(festival_charge_state,false),
	put(festival_charge_send_mail_state,false),
	put(mall_item,[]),
	random:seed(timer_center:get_correct_now()),
	timer:send_interval(50000,{check_db}),
	timer:send_interval(60000,{check_sales_item}),
	timer:send_interval(?SECONDS_PER_HOUR*1000, {check_festival_charge_state}),
    {ok, #state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({check_db}, State) ->
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	CurSec = MegaSec*1000000 + Sec ,
	case gm_notice_db:get_gm_notice(CurSec) of
		[]->
			empty;
		GmNoticeList->
			lists:foreach(fun(GmNotice)->
								  publish_notice_content(GmNotice#gm_notice.notice_content,GmNotice#gm_notice.ntype),
								  update_gm_notice(GmNotice#gm_notice.id)
						  end, GmNoticeList),
			io:format("list size:~p~n",[length(GmNoticeList)])
	end,
	{noreply, State};

handle_info({mall_sale_test},State)->
	MallSaleItems = mall_item_db:get_all_sales_item_info(),
	put(mall_sale_items,MallSaleItems),
	put(mall_test_state,true),
	{noreply, State};

handle_info({cancel_mall_sale_test},State)->
	put(mall_sale_items,[]),
	put(mall_test_state,false),
	dal:clear_table_rpc(mall_up_sales_table),
	{noreply, State};

handle_info({check_sales_item}, State) ->
	try
		MallTestState = get(mall_test_state),
		if
			MallTestState->
				MallItems = get(mall_sale_items),
				MallLength = erlang:length(MallItems),
				if
					MallLength =:= 0->
						put(mall_test_state,false),
						dal:clear_table_rpc(mall_up_sales_table),
						mall_op:flush_sales_item();
					MallLength =< 3->
						put(mall_sale_items,[]),
						mall_op:flush_sales_item();
					true->
						[Item1,Item2,Item3|Remain] = MallItems,
						put(mall_sale_items,Remain),
						mall_op:flush_sales_item_test([Item1,Item2,Item3])
				end;
			true->
				mall_op:flush_sales_item()
		end
	catch
		E:R ->slogger:msg("check_sales_item error ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()])
	end,
	{noreply, State};


				
handle_info({check_festival_charge_state},State)->
%% 	io:format("check_festival_charge_state,festival_charge_state:~p,festival_charge_send_mail_state:~p~n",[get(festival_charge_state),get(festival_charge_send_mail_state)]),
	try
		ControlInfo = festival_db:read_festival_control_info_from_db(?FESTIVAL_RECHARGE),
		case festival_op:get_festival_state_by_info(ControlInfo) of
			?CLOSE->
				put(festival_charge_state,false),
				SendMailState = get(festival_charge_send_mail_state),
				if
					SendMailState =:= false->
						case rpc:call(gm_op:get_mapnode(),festival_recharge,charge_send_mail,[]) of
							{badrpc, Reason}->
								slogger:msg("festival charge send mail failed Reason:~p~n",[Reason]);
							_Ok->
								put(festival_charge_send_mail_state,true),
								put(festival_charge_state,false),
								nothing
						end;
					true->
						nothing
				end;
			_OtherState->
						put(festival_charge_state,true),
						put(festival_charge_send_mail_state,false)
		end
	catch
		E:R ->slogger:msg("check_festival_charge_state ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()])
	end,
	{noreply, State};	

handle_info({publish_notice_id,Id}, State) ->
	%%TODO publish
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	CurSec = MegaSec*1000000 + Sec,
	case gm_notice_db:get_gm_notice(CurSec,Id) of
		[]->
			empty;
		GmNotice->
			case (CurSec-GmNotice#gm_notice.last_notice_time)>=GmNotice#gm_notice.interval_time/1000 of
				true->
			%%Todo send to map interface.
			publish_notice_content(GmNotice#gm_notice.notice_content,GmNotice#gm_notice.ntype),
			update_gm_notice(GmNotice#gm_notice.id);
				_->
					nothing
			end
	end,
	{noreply, State};

handle_info({publish_notice_content,Content,Ntype}, State) ->
	%%TODO publish.
	case node_util:get_mapnode() of
		undefined-> slogger:msg("publish_notice_content error : can not find map node~n");
		MapNode->
			case Ntype of
				0 -> rpc:call(MapNode,chat_manager,gm_broad_cast,[Content]);
				1 -> rpc:call(MapNode,chat_manager,gm_speek,[Content])
			end
	end,
	io:format("publish_notice_content~n"),
	{noreply, State};

handle_info({update_gm_notice,Id}, State) ->
	%%Todo update to mnesia.
	gm_notice_db:update_gm_notice(Id),
	{noreply, State};

handle_info(Info, State) ->
	io:format("info:~p~n",[Info]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    {ok,Reason}.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

get_notice()->
	o.