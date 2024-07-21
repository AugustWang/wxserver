%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : PCWS06
%%% Description : order to create for chat_process for each peer
%%%
%%% Created : 2010-7-8
%%% -------------------------------------------------------------------
-module(chat_manager).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_chat_role/3,stop_chat_role/3,get_crash_role_info/1,
	     reg_crash_role_info/2,unreg_crash_role_info/1,
	     reg_chat_process/1,unreg_chat_process/1,
	     gm_broad_cast/1,gm_speek/1,
	     system_message/2,system_message/3,system_broadcast/3]).

-export([system_to_someone/2]).

-export([get_filter_msg/1]).

-compile(export_all).

-record(state, {}).

-define(CHAT_ROLEINFO_ETS,chat_roleinfo_ets).%%{roleid,MapInfo,RoleInfo,GateInfo},
-define(CHAT_PROC_ETS,'$chat_proc_ets$').%%{roleid},

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").



%% ====================================================================
%% External functions
%% ====================================================================


%% ====================================================================
%% Server functions
%% ====================================================================
%% -------------------------------sss-------------------------------------
%% Function: start_link/1
%% Description: start server
%% --------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->	
	ets:new(?CHAT_ROLEINFO_ETS, [set,public,named_table]),
	ets:new(?CHAT_PROC_ETS, [set,public,named_table]),
	timer_center:start_at_process(),
	send_check_message(),
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
handle_call({start_chat_role, { GS_system_role_info, GS_system_gate_info}},_From, State) ->
	Reply = safe_apply(?MODULE,start_chat_role,[GS_system_role_info,GS_system_gate_info]),
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
%% line_check
handle_info({global_line_check}, State) ->
	safe_apply(?MODULE,global_line_check,[]),
	{noreply, State};

handle_info({gm_broad_cast,Msg}, State) ->	
	safe_apply(chat_process,send_world,[?CHAT_TYPE_SYSTEM,0,"system", Msg,[],?ROLE_IDEN_COM]),
	{noreply, State};

handle_info({gm_speek,Msg}, State) ->
	safe_apply(chat_process,send_world,[?CHAT_TYPE_GM_NOTICE,0,"gm", Msg,[],?ROLE_IDEN_COM]),
	{noreply, State};

handle_info({system_message,Type,Msg},State)->
	safe_apply(chat_process,send_world,[Type,0,"system", [],Msg,?ROLE_IDEN_COM]),
	{noreply, State};
	
handle_info({system_message_map,Type,Msg,MapId},State)->
	safe_apply(chat_process,send_map,[Type,0,MapId,"system",[],Msg,?ROLE_IDEN_COM]),
	{noreply, State};
	
handle_info({system_message_map,Type,Msg,MapId,LineId},State)->
	safe_apply(chat_process,send_map,[Type,0,MapId,"system",[],Msg,?ROLE_IDEN_COM]),
	{noreply, State};	
handle_info({system_message_instance,Type,Msg,Instance},State)->
	safe_apply(chat_process,send_instance,[Type,0,Instance,"system", [],Msg,?ROLE_IDEN_COM]),
	{noreply, State};

handle_info({system_broadcast,Id,Param},State)->
	safe_apply(chat_process,send_broadcast_world,[Id,Param]),
	{noreply, State};
	
handle_info({system_broadcast_map,Id,Param,MapId},State)->
	safe_apply(chat_process,send_broadcast_map,[Id,MapId,Param]),
	{noreply, State};
	
handle_info({system_broadcast_map,Id,Param,MapId,LineId},State)->
	safe_apply(chat_process,send_broadcast_map,[Id,MapId,LineId,Param]),
	{noreply, State};	

handle_info({system_broadcast_instance,Id,Param,Instance},State)->
	safe_apply(chat_process,send_broadcast_instance,[Id,Instance,Param]),
	{noreply, State};

handle_info({system_to_someone,RoleId,Msg}, State) ->
	safe_apply(chat_process,system_to_someone,[?CHAT_TYPE_GM_NOTICE,0,"gm",RoleId, Msg,[],?ROLE_IDEN_COM]),
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
start_chat_role(GS_system_role_info,GS_system_gate_info)->
	#gs_system_role_info{role_id=Role_id} = GS_system_role_info,
	unreg_crash_role_info(Role_id),
	case chat_process:whereis_role(Role_id) of
		undefined ->
			case chat_manager_sup:start_chat_role(Role_id) of
				{ok, Role_pid} ->                                         
					chat_process:init_role(Role_pid, {GS_system_role_info, GS_system_gate_info});	    
				AnyInfo ->
					slogger:msg("chat_manager:handle_info:start_chat_role:error:~p~n",[AnyInfo])		    
			end;
		Role_proc ->
			chat_process:init_role(Role_proc, {GS_system_role_info, GS_system_gate_info})
	end,
    {node(),role_op:make_role_proc_name(Role_id)}.

send_check_message()->
	timer_util:send_after(1000, {global_line_check}).

global_line_check()->
	case lines_manager:whereis_name() of
		error ->
			slogger:msg("lines manager can not found ,1 sencond check\n"),
			send_check_message();
		undefined->
			slogger:msg("lines manager can not found ,1 sencond check\n"),
			send_check_message();
		_GlobalPid-> 
			Count = ets:info(?CHAT_PROC_ETS,size),
			lines_manager:regist_chatmanager({node(),?MODULE,Count})
	end.

safe_apply(Module,Fun,Args)->
	try
		erlang:apply(Module, Fun, Args)
	catch 
		E:R->
			slogger:msg("chat_manager safe_apply error ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()])
	end.

start_chat_role(Chat_node, GS_system_role_info, GS_system_gate_info)->
	try
		gen_server:call({?MODULE,Chat_node}, {start_chat_role, { GS_system_role_info, GS_system_gate_info}})
	catch
		E:R->
			error
	end.

gm_broad_cast(Msg)->
	case get(chat_node_name) of
		undefined->
			case lines_manager:get_chat_name() of
				{Node,_,_}->
					put(chat_node_name,Node);
				_->
					Node = [],
					slogger:msg("lines_manager:get_chat_name() error~n")
			end;
		Node->
			nothing
	end,
	if
		Node=/= []->
			gs_rpc:cast(Node, ?MODULE, {gm_broad_cast,Msg});
		true->
			nothing
	end.

gm_speek(Msg)->
	case get(chat_node_name) of
		undefined->
			case lines_manager:get_chat_name() of
				{Node,_,_}->
					put(chat_node_name,Node);
				_->
					Node= [],
					slogger:msg("lines_manager:get_chat_name() error~n")
			end;
		Node->
			nothing	
	end,
	if
		Node=/= []->
			gs_rpc:cast(Node, ?MODULE, {gm_speek,Msg});
		true->
			nothing
	end.

system_message(Type,Msg)->
	case get(chat_node_name) of
		undefined->
			case lines_manager:get_chat_name() of
				{Node,_,_}->
					put(chat_node_name,Node);
				_->
					Node = [],
					slogger:msg("lines_manager:get_chat_name() error~n")
			end;
		Node->
			nothing
	end,
	if
		Node=/= []->
			gs_rpc:cast(Node, ?MODULE, {system_message,Type,Msg});
		true->
			nothing
	end.
			
system_message(Type,Msg,{map,MapId})->
	case get(chat_node_name) of
		undefined->
			case lines_manager:get_chat_name() of
				{Node,_,_}->
					put(chat_node_name,Node);
				_->
					Node = [],
					slogger:msg("lines_manager:get_chat_name() error~n")
			end;
		Node->
			nothing
	end,
	if
		Node=/= []->
			gs_rpc:cast(Node, ?MODULE, {system_message_map,Type,Msg,MapId});
		true->
			nothing
	end;

system_message(Type,Msg,{map,MapId,LineId})->
	case get(chat_node_name) of
		undefined->
			case lines_manager:get_chat_name() of
				{Node,_,_}->
					put(chat_node_name,Node);
				_->
					Node = [],
					slogger:msg("lines_manager:get_chat_name() error~n")
			end;
		Node->
			nothing	
	end,
	if
		Node=/= []->
			gs_rpc:cast(Node, ?MODULE, {system_message_map,Type,Msg,MapId,LineId});
		true->
			nothing
	end;	
			
	
system_message(Type,Msg,{instance,Instance})->
	case get(chat_node_name) of
		undefined->
			case lines_manager:get_chat_name() of
				{Node,_,_}->
					put(chat_node_name,Node);
				_->
					Node = [],
					slogger:msg("lines_manager:get_chat_name() error~n")
			end;
		Node->
			nothing
	end,
	if
		Node=/= []->
			gs_rpc:cast(Node, ?MODULE, {system_message_instance,Type,Msg,Instance});
		true->
			nothing
	end;	

system_message(_,_,_)->
	ignor.	

system_broadcast(Id,Param,[])->
	case get(chat_node_name) of
		undefined->
			case lines_manager:get_chat_name() of
				{Node,_,_}->
					put(chat_node_name,Node);
				_->
					Node = [],
					slogger:msg("lines_manager:get_chat_name() error~n")
			end;
		Node->
			nothing
	end,
	if
		Node=/= []->
			gs_rpc:cast(Node, ?MODULE, {system_broadcast,Id,Param});
		true->
			nothing
	end;

system_broadcast(Id,Param,{map,MapId})->
	case get(chat_node_name) of
		undefined->
			case lines_manager:get_chat_name() of
				{Node,_,_}->
					put(chat_node_name,Node);
				_->
					Node = [],
					slogger:msg("lines_manager:get_chat_name() error~n")
			end;
		Node->
			nothing
	end,
	if
		Node=/= []->
			io:format("Param is ~p~n",[Param]),
			gs_rpc:cast(Node, ?MODULE, {system_broadcast_map,Id,Param,MapId});
		true->
			nothing
	end;

system_broadcast(Id,Param,{map,MapId,LineId})->
	case get(chat_node_name) of
		undefined->
			case lines_manager:get_chat_name() of
				{Node,_,_}->
					put(chat_node_name,Node);
				_->
					Node = [],
					slogger:msg("lines_manager:get_chat_name() error~n")
			end;
		Node->
			nothing	
	end,
	if
		Node=/= []->
			io:format("Param is ~p~n",[Param]),
			gs_rpc:cast(Node, ?MODULE, {system_broadcast_map,Id,Param,MapId,LineId});
		true->
			nothing
	end;

system_broadcast(Id,Param,{instance,Instance})->
	case get(chat_node_name) of
		undefined->
			case lines_manager:get_chat_name() of
				{Node,_,_}->
					put(chat_node_name,Node);
				_->
					Node = [],
					slogger:msg("lines_manager:get_chat_name() error~n")
			end;
		Node->
			nothing
	end,
	if
		Node=/= []->
			gs_rpc:cast(Node, ?MODULE, {system_broadcast_instance,Id,Param,Instance});
		true->
			nothing
	end;

system_broadcast(_,_,_)->
	nothing.
	
stop_chat_role(Chat_node,Chat_proc,RoleId)->
	try
		chat_manager_sup:stop_role(Chat_node,RoleId)
	catch
		E:R->error
	end.

get_crash_role_info(undefined) ->
	slogger:msg("undefined role info~n");
	
get_crash_role_info(RoleId) ->
	case ets:lookup(?CHAT_ROLEINFO_ETS, RoleId) of
		[] ->
			undefined;
		[{_,RoleInfo}] ->
			RoleInfo
	end.
reg_crash_role_info(RoleId,RoleInfo)->
	ets:insert(?CHAT_ROLEINFO_ETS, {RoleId, RoleInfo}).

unreg_crash_role_info(RoleId)->
	ets:delete(?CHAT_ROLEINFO_ETS, RoleId).

reg_chat_process(RoleId)->
	ets:insert(?CHAT_PROC_ETS, {RoleId}).
unreg_chat_process(RoleId)->
	ets:delete(?CHAT_PROC_ETS, RoleId).

get_filter_msg(Msg)->
	try
		senswords:replace_sensitive(list_to_binary(Msg))
	catch
		E:R ->slogger:msg("get_filter_msg excption:(~p:~p)~n",[E,R]),
			Msg
	end.	

system_to_someone(RoleId,Msg)->
	case get(chat_node_name) of
		undefined->
			case lines_manager:get_chat_name() of
				{Node,_,_}->
					put(chat_node_name,Node);
				_->
					Node= [],
					slogger:msg("lines_manager:get_chat_name() error~n")
			end;
		Node->
			nothing	
	end,
	if
		Node=/= []->
			gs_rpc:cast(Node, ?MODULE, {system_to_someone,RoleId,Msg});
		true->
			nothing
	end.
