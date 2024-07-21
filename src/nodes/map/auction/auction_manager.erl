%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : MacX
%%% Description :
%%%
%%% Created : 2011-3-28
%%% -------------------------------------------------------------------
-module(auction_manager).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([apply_up_stall/2,apply_up_money_stall/2,apply_recede_item/2,paimai_search_by_sort/7,paimai_search_by_string/6,paimai_search_by_grade/8,paimai_buy/4,stall_detail/2,apply_buy_item/4,paimai_detail_myself/2,
		 stall_detail_myself/2,stall_rename/2,stall_detail_by_rolename/2,apply_all_auctions_down/0]).%stalls_search/4

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?MODULE},?MODULE,[],[]).

%% ====================================================================
%% Server functions
%% ====================================================================
apply_up_stall(RoleInfo,ApllyInfo)->
	try
		global_util:call(?MODULE,{apply_up_stall,RoleInfo,ApllyInfo})
	catch
		E:R->
			slogger:msg("apply_up_stall error ~p ~p ~n ",[E,R]),
			error
	end.

apply_up_money_stall(RoleInfo,ApllyInfo)->
	try
		global_util:call(?MODULE,{apply_up_money_stall,RoleInfo,ApllyInfo})
	catch
		E:R->
			slogger:msg("apply_up_stall error ~p ~p ~n ",[E,R]),
			error
	end.


apply_all_auctions_down()->
	try
		global_util:call(?MODULE,{all_auctions_down},infinity)
	catch
		E:R->
			slogger:msg("all_auctions_down error ~p ~p ~n ",[E,R]),
			error
	end.

apply_recede_item(RoleId,ItemId)->
	try
		global_util:call(?MODULE,{apply_recede_item,RoleId,ItemId})
	catch
		E:R->
			slogger:msg("apply_recede_item error ~p ~p ~n ",[E,R]),
			error
	end.

apply_buy_item(MyInfo,StallId,ItemId,Money)->
	try
		global_util:call(?MODULE,{apply_buy_item,MyInfo,StallId,ItemId,Money})
	catch
		E:R->
			slogger:msg("apply_recede_item error ~p ~p ~n ",[E,R]),
			error
	end.	

%stalls_search(RoleId,Serchtype,Str,Index)->
 % 	try
%		global_util:send(?MODULE,{stalls_search,{RoleId,Serchtype,Str,Index}})
%	catch
%		E:R->
%			slogger:msg("stalls_search error ~p ~p ~n ",[E,R]),
%			error
%	end.
paimai_search_by_sort(RoleId,Subsortkey,Sortkey,Levelsort,Index,Mainsort,Moneysort)->%%
  	try
		global_util:send(?MODULE,{paimai_search_by_sort,{RoleId,Subsortkey,Sortkey,Levelsort,Index,Mainsort,Moneysort}})
	catch
		E:R->
			slogger:msg("stalls_search error ~p ~p ~n ",[E,R]),
			error
	end.

paimai_search_by_string(RoleId,Levelsort,Str,Index,Mainsort,Moneysort)->
	try
		global_util:send(?MODULE,{paimai_search_by_string,{RoleId,Levelsort,Str,Index,Mainsort,Moneysort}})
	catch
		E:R->
			slogger:msg("stalls_search error ~p ~p ~n ",[E,R]),
			error
	end.

paimai_search_by_grade(RoleId,Levelsort,Index,Allowableclass,Mainsort,Levelgrade,Moneysort,Qualitygrade)->
	try
		global_util:send(?MODULE,{paimai_search_by_grade,{RoleId,Levelsort,Index,Allowableclass,Mainsort,Levelgrade,Moneysort,Qualitygrade}})
	catch
		E:R->
			slogger:msg("stalls_search error ~p ~p ~n ",[E,R]),
			error
	end.
paimai_buy(RoleId,Type, Stallid, Indexid)->
	try
		global_util:send(?MODULE,{paimai_buy,{RoleId,Type, Stallid, Indexid}})
	catch
		E:R->
			slogger:msg("stalls_search error ~p ~p ~n ",[E,R]),
			error
	end.
stall_detail(RoleId,StallId)->
	try
		global_util:send(?MODULE,{stall_detail,{RoleId,StallId}})
	catch
		E:R->
			slogger:msg("stall_detail error ~p ~p ~n ",[E,R]),
			error
	end.

stall_detail_by_rolename(RoleId,RoleName)->
	try
		global_util:send(?MODULE,{apply_stall_detail_by_rolename,{RoleId,RoleName}})
	catch
		E:R->
			slogger:msg("stall_detail error ~p ~p ~n ",[E,R]),
			error
	end.

stall_detail_myself(RoleId,DeafualName)->
	try
		global_util:send(?MODULE,{apply_stall_myself,{RoleId,DeafualName}})
	catch
		E:R->
			slogger:msg("stall_detail error ~p ~p ~n ",[E,R]),
			error
	end.


paimai_detail_myself(RoleId,DeafualName)->%%2æœˆ22æ—¥åŠ ã€xiaowuã€‘
	try
		global_util:send(?MODULE,{apply_paimai_myself,{RoleId,DeafualName}})
	catch
		E:R->
			slogger:msg("stall_detail error ~p ~p ~n ",[E,R]),
			error
	end.

stall_rename(RoleId,StallName)->
	try
		global_util:send(?MODULE,{apply_stall_rename,{RoleId,StallName}})
	catch
		E:R->
			slogger:msg("stall_detail error ~p ~p ~n ",[E,R]),
			error
	end.	
	
  
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	try
		timer_center:start_at_process(),
		auction_manager_op:init()
	catch
		E:R ->slogger:msg("auction_manager_op init error ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()])
	end,
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
handle_call({apply_up_stall,RoleInfo,ApllyInfo}, _From, State) ->
	Reply = my_apply(auction_manager_op,apply_up_stall,[RoleInfo,ApllyInfo]),
    {reply, Reply, State};

handle_call({apply_up_money_stall,RoleInfo,ApllyInfo}, _From, State) ->%%2.27xie[xiaowu]
	Reply = my_apply(auction_manager_op,apply_up_money_stall,[RoleInfo,ApllyInfo]),
    {reply, Reply, State};

handle_call({apply_recede_item,RoleId,ItemId},_From, State) ->
	Reply = my_apply(auction_manager_op,apply_recede_item,[RoleId,ItemId]),
    {reply, Reply, State};

handle_call({apply_buy_item,MyInfo,StallId,ItemId,Money},_From, State) ->
	Reply = my_apply(auction_manager_op,apply_buy_item,[MyInfo,StallId,ItemId,Money]),
    {reply, Reply, State};

handle_call({all_auctions_down},_From, State) ->
	Reply = my_apply(auction_manager_op,proc_all_auctions_down,[]),
	{reply, Reply, State};

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
handle_info({paimai_search_by_sort,{RoleId,Subsortkey,Sortkey,Levelsort,Index,Mainsort,Moneysort}}, State) ->
	my_apply(auction_manager_op,apply_paimai_search_by_sort,[RoleId,Subsortkey,Sortkey,Levelsort,Index,Mainsort,Moneysort]),
	{noreply, State};

handle_info({paimai_search_by_string,{RoleId,Levelsort,Str,Index,Mainsort,Moneysort}}, State) ->
	my_apply(auction_manager_op,apply_paimai_search_by_string,[RoleId,Levelsort,Str,Index,Mainsort,Moneysort]),
	{noreply, State};

handle_info({paimai_search_by_grade,{RoleId,Levelsort,Index,Allowableclass,Mainsort,Levelgrade,Moneysort,Qualitygrade}}, State) ->
	my_apply(auction_manager_op,apply_paimai_search_by_grade,[RoleId,Levelsort,Index,Allowableclass,Mainsort,Levelgrade,Moneysort,Qualitygrade]),
	{noreply, State};

handle_info({paimai_buy,{RoleId,Type, Stallid, Indexid}}, State) ->
	my_apply(auction_manager_op,apply_paimai_buy,[RoleId,Type, Stallid, Indexid]),
	{noreply, State};

%handle_info({stalls_search,{RoleId,Serchtype,Str,Index}}, State) ->
%	my_apply(auction_manager_op,apply_stalls_search,[RoleId,Serchtype,Str,Index]),
%	{noreply, State};

handle_info({apply_stall_myself,{RoleId,Name}}, State) ->
	my_apply(auction_manager_op,apply_stall_myself,[RoleId,Name]),
	{noreply, State};

handle_info({apply_paimai_myself,{RoleId,Name}}, State) ->%%2æœˆ22æ—¥åŠ ã€xiaowuã€‘
	my_apply(auction_manager_op,apply_paimai_myself,[RoleId,Name]),
	{noreply, State};

handle_info({stall_detail,{RoleId,StallId}}, State) ->
	my_apply(auction_manager_op,apply_stall_detail,[RoleId,StallId]),
	{noreply, State};

handle_info({apply_stall_rename,{RoleId,StallName}}, State) ->
	my_apply(auction_manager_op,apply_stall_rename,[RoleId,StallName]),
	{noreply, State};

handle_info(over_due_check, State) ->
	my_apply(auction_manager_op,over_due_check,[]),
	{noreply, State};

handle_info({apply_stall_detail_by_rolename,{RoleId,RoleName}}, State) ->
	my_apply(auction_manager_op,apply_stall_detail_by_rolename,[RoleId,RoleName]),
	{noreply, State};

handle_info(crash_test, State) ->
	aaa:ppp("~p",[]),
	{noreply, State};

handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ok.

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
my_apply(Module,Fun,Args)->
	try
		erlang:apply(Module,Fun,Args)
	catch
		E:R->
			slogger:msg("apply ~p ~p ~p ~p, ~p ~p ~n",[Module,Fun,Args,erlang:get_stacktrace(),E,R]),
			error
	end.
