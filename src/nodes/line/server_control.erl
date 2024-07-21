%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhang
%% Created: 2011-1-21
%% Description: TODO: Add description to server_control
-module(server_control).
-behaviour(gen_server).
-record(state, {}).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).
-export([hotshutdown/1,hotshutdown/2]).
-export([openthedoor/0,closethedoor/0,open_gmdoor/0]).
-export([cancel_shutdowncmd/0]).
-export([hotshutdown/0]).
-export([backup_db/0]).
-export([gen_data/0]).
-export([clear_goals_data/0]).
-export([write_flag_file/0]).
-export([clear_flag_file/0]).
-export([recovery_db/0]).
-export([update_code/0]).
-export([update_data/0]).
-export([update_option/0]).
-export([format_data/1]).

%%
%% API Functions
%%
start_link()->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

hotshutdown()->
	clear_flag_file(),
	[CenterNode|_] = util:get_argument('-line'),
	ping_center:ping(CenterNode),
	%%LineNode = lists:last(node_util:get_linenodes()),
	gs_rpc:cast(CenterNode,?MODULE,{hotshutdown_start,600}),
	c:q().

backup_db()->
	clear_flag_file(),
	[CenterNode|_] = util:get_argument('-line'),
	ping_center:ping(CenterNode),
	ping_center:wait_node_connect(db),
	DbNode = lists:last(node_util:get_dbnodes()),
	%%ping_center:ping(DbNode),
	gs_rpc:cast({dbmaster,DbNode},{backupdata}),
	c:q().

recovery_db()->
	clear_flag_file(),
	[CenterNode|_] = util:get_argument('-line'),
	ping_center:ping(CenterNode),
	ping_center:wait_node_connect(db),
	DbNode = lists:last(node_util:get_dbnodes()),
	%%ping_center:ping(DbNode),
	gs_rpc:cast({dbmaster,DbNode},{recoverydata}),
	c:q().

gen_data()->
	clear_flag_file(),
	[CenterNode|_] = util:get_argument('-line'),
	ping_center:ping(CenterNode),
	ping_center:wait_node_connect(db),
	DbNode = lists:last(node_util:get_dbnodes()),
	%%ping_center:ping(DbNode),
	gs_rpc:cast({dbmaster,DbNode},{gen_data}),
	c:q().

clear_goals_data()->
	clear_flag_file(),
	[CenterNode|_] = util:get_argument('-line'),
	ping_center:ping(CenterNode),
	ping_center:wait_node_connect(db),
	DbNode = lists:last(node_util:get_dbnodes()),
	gs_rpc:cast({dbmaster,DbNode},{clear_goals_data}),
	c:q().

create_giftcard()->
	clear_flag_file(),
	[CenterNode|_] = util:get_argument('-line'),
	ping_center:ping(CenterNode),
	ping_center:wait_node_connect(db),
	DbNode = lists:last(node_util:get_dbnodes()),
	%%ping_center:ping(DbNode),
	gs_rpc:cast({dbmaster,DbNode},{create_giftcard}),
	c:q().


update_code()->
	[CenterNode|_] = util:get_argument('-line'),
	ping_center:ping(CenterNode),
	gs_rpc:cast(CenterNode,?MODULE,{update_code}),
	c:q().

update_data()->
	[CenterNode|_] = util:get_argument('-line'),
	ping_center:ping(CenterNode),
	gs_rpc:cast(CenterNode,?MODULE,{update_data}),
	c:q().

update_option()->
	[CenterNode|_] = util:get_argument('-line'),
	ping_center:ping(CenterNode),
	gs_rpc:cast(CenterNode,?MODULE,{update_option}),
	c:q().	
	
hotshutdown(Time_s)->
	%%io:format("hotshutdown ~p ~n",[Time_s]),
	LineNode = lists:last(node_util:get_linenodes()),
	gs_rpc:cast(LineNode,?MODULE,{hotshutdown_start,Time_s}).

hotshutdown(Time_s,Reason)->
	%%io:format("hotshutdown ~p ~p ~n",[Time_s,Reason]),
	LineNode = lists:last(node_util:get_linenodes()),
	if
		Reason =:= [] ->
			gs_rpc:cast(LineNode,?MODULE,{hotshutdown_start,Time_s});
		true->
			%%io:format("hotshutdown ~p ~p ~n",[Time_s,Reason]),
			gs_rpc:cast(LineNode,?MODULE,{hotshutdown_start,Time_s,Reason})
	end.
	
openthedoor()->
	GateNodeList = node_util:get_gatenodes(),
	lists:foreach(
			fun(GateNode)->
				rpc:call(GateNode,tcp_listener,enable_connect,[])
			end,
	GateNodeList).

closethedoor()->
	GateNodeList = node_util:get_gatenodes(),
	lists:foreach(
			fun(GateNode)->
				rpc:call(GateNode,tcp_listener,disable_connect,[])
			end,
	GateNodeList).

open_gmdoor()->
	GmNodes = node_util:get_gmnodes(),
	lists:foreach(
			fun(GmNode)->
				rpc:call(GmNode,gm_listener,enable_connect,[])
			end,
	GmNodes).

cancel_shutdowncmd()->
	LineNode = lists:last(node_util:get_linenodes()),
	gs_rpc:cast(LineNode,?MODULE,{cancelshutdowncmd}).


format_data(Param)->
	clear_flag_file(),
	[CenterNode|_] = util:get_argument('-line'),
	ping_center:ping(CenterNode),
	ping_center:wait_node_connect(db),
	DbNode = lists:last(node_util:get_dbnodes()),
	%%ping_center:ping(DbNode),
	gs_rpc:cast({dbmaster,DbNode},{format_data,Param}),
	c:q().
%% ====================================================================
%% Server functions
%% ====================================================================

%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
init([]) ->
	put(last_shutdowncmd_id,0),		
	put(shutdowncmd_flag,false),
	{ok, #state{}}.


%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)

handle_call(Request, From, State) ->
	Reply = ok,
	{reply, Reply, State}.	


%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
handle_cast(Msg, State) ->
	{noreply, State}.

%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
handle_info({hotshutdown_start,Time_s}, State) ->
%%	io:format("handle_info  hotshutdown_start ~p ~n",[Time_s]),
	case get(shutdowncmd_flag) of
		true->
			io:format("please cancel last cmd first ~n");
		Other->
			CmdId = get(last_shutdowncmd_id) + 1,
			put(last_shutdowncmd_id,CmdId),		
			put(shutdownreason,[]), 	
			put(shutdowncmd_flag,true),
			hotshutdown_server(CmdId,Time_s)
	end,
	{noreply, State};

handle_info({manage_hotshutdown_start,Time_s,FromProc}, State) ->
	slogger:msg("handle_info manage_hotshutdown_start~n"),
	case get(shutdowncmd_flag) of
		true->
			slogger:msg("please cancel last cmd first ~n");
		_Other->
			CmdId = get(last_shutdowncmd_id) + 1,
			put(last_shutdowncmd_id,CmdId),		
			put(shutdownreason,[]), 	
			put(shutdowncmd_flag,true),
			manage_hotshutdown_server(CmdId,Time_s,FromProc)
	end,
	{noreply,State};

handle_info({hotshutdown_start,Time_s,ShutDownReason}, State) ->
	%%io:format("handle_info hotshutdown_start ~p ~p ~n",[Time_s,ShutDownReason]),
	case get(shutdowncmd_flag) of
		true->
			io:format("please cancel last cmd first ~n");
		Other->
			CmdId = get(last_shutdowncmd_id) + 1,
			put(last_shutdowncmd_id,CmdId),		
			put(shutdownreason,ShutDownReason), 	
			put(shutdowncmd_flag,true),
			hotshutdown_server(CmdId,Time_s)
	end,
	{noreply, State};

handle_info({hotshutdown, {CmdID,Time_s}}, State) ->
	hotshutdown_server(CmdID,Time_s),
	{noreply, State};

handle_info({manage_hotshutdown,{CmdID,Time_s,FromProc}},State)->
	slogger:msg("{manage_hotshutdown,{CmdID,Time_s,FromProc,FromNode~n"),
	manage_hotshutdown_server(CmdID,Time_s,FromProc),
	{noreply,State};


handle_info({cancelshutdowncmd},State)->
	cancel_lastshutdowncmd(),
	{noreply, State};

handle_info({update_code},State)->
	handle_update_code(),
	{noreply, State};

handle_info({update_data},State)->
	handle_update_data(),
	{noreply, State};

handle_info({update_option},State)->
	handle_update_option(),
	{noreply, State};

handle_info(Info, State) ->
	%%io:format("~p handle info  ~p ~n",[?MODULE,Info]),
	{noreply, State}.


%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
terminate(_Reason, State) ->
	 ok.


%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
code_change(OldVsn, State, Extra) ->
	{ok, State}.


%%
%% Local Functions
%%
%%hot shutdown server at Time_s sec. later
hotshutdown_server(CmdID,Time_s)->
	case (CmdID =:= get(last_shutdowncmd_id)) and (get(shutdowncmd_flag)) of
		true->
			%%io:format("hotshutdown_server ~p ~n",[Time_s]),
			if
				Time_s > 15*60 ->
					LastTime_s = 15*60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 15*60) or (Time_s > 10*60) ->
					LastTime_s = 10*60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 10*60) or (Time_s > 5*60) ->
					LastTime_s = 5*60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 5*60)  or (Time_s > 4*60) ->
					LastTime_s = 4*60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 4*60)  or (Time_s > 3*60) ->
					LastTime_s = 3*60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 3*60)  or (Time_s > 2*60) ->
					LastTime_s = 2*60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 2*60)  or (Time_s > 60) ->
					LastTime_s = 60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 60)  or (Time_s > 30) ->
					LastTime_s = 30,
					NextTime_s = Time_s - LastTime_s;	
				(Time_s =:= 30)  or (Time_s > 10) ->
					LastTime_s = 10,
					NextTime_s = Time_s - LastTime_s;
				Time_s > 0 ->
					LastTime_s = Time_s - 1,
					NextTime_s = 1;		
				Time_s =:= 0 ->
					LastTime_s = 0,
					NextTime_s = 0,
					shutdown_server(),
					cancel_lastshutdowncmd()
			end,
	
			case Time_s > 0 of
				true->
					erlang:send_after(NextTime_s*1000,self(),{hotshutdown,{CmdID,LastTime_s}}),	
					case 	Time_s >= 10 of
						true->
							waring_broadcast(Time_s)	;
						false->
							countdown_broadcast(Time_s)
					end;
				_->
					nothing
			end;
		false->
			io:format("cancel shutdown cmd id ~p ~n",[CmdID])
	end.
	
manage_hotshutdown_server(CmdID,Time_s,FromProc)->
	case (CmdID =:= get(last_shutdowncmd_id)) and (get(shutdowncmd_flag)) of
		true->
			slogger:msg("hotshutdown_server ~p ~n",[Time_s]),
			if
				Time_s > 15*60 ->
					LastTime_s = 15*60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 15*60) or (Time_s > 10*60) ->
					LastTime_s = 10*60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 10*60) or (Time_s > 5*60) ->
					LastTime_s = 5*60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 5*60)  or (Time_s > 4*60) ->
					LastTime_s = 4*60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 4*60)  or (Time_s > 3*60) ->
					LastTime_s = 3*60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 3*60)  or (Time_s > 2*60) ->
					LastTime_s = 2*60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 2*60)  or (Time_s > 60) ->
					LastTime_s = 60,
					NextTime_s = Time_s - LastTime_s;
				(Time_s =:= 60)  or (Time_s > 30) ->
					LastTime_s = 30,
					NextTime_s = Time_s - LastTime_s;	
				(Time_s =:= 30)  or (Time_s > 10) ->
					LastTime_s = 10,
					NextTime_s = Time_s - LastTime_s;
				Time_s > 0 ->
					LastTime_s = Time_s - 1,
					NextTime_s = 1;		
				Time_s =:= 0 ->
					LastTime_s = 0,
					NextTime_s = 0,
					closethedoor(),
					kick_all_roles(),
					slogger:msg("manage_hotshutdown ok fromnode:~p~n",[FromProc]),
					gs_rpc:cast(FromProc,{hotshutdown_ok}),
					cancel_lastshutdowncmd()
			end,
			case Time_s > 0 of
				true->
					erlang:send_after(NextTime_s*1000,self(),{manage_hotshutdown,{CmdID,LastTime_s,FromProc}}),	
					case 	Time_s >= 10 of
						true->
							waring_broadcast(Time_s);
						false->
							countdown_broadcast(Time_s)
					end;
				_->
					nothing
			end;
		false->
			io:format("cancel shutdown cmd id ~p ~n",[CmdID])
	end.


kick_all_roles()->
	MapNode= node_util:get_mapnode(),
	rpc:call(MapNode,gm_order_op,kick_all,[]).

shutdown_server()->
	closethedoor(),
	kick_all_roles(),
	write_flag_file(),
	slogger:msg("hot shutdown server complete!!!~n").

waring_broadcast(Time_s)->
	if
		Time_s > 60 ->
			BrdTime = integer_to_list(trunc(Time_s/60)) ++"åˆ†é’Ÿ",
			BrdMsg = get(shutdownreason);
		true->
			BrdTime = integer_to_list(Time_s) ++"ç§’",
			BrdMsg = get(shutdownreason)
	end,

	if
		is_binary(BrdMsg)->
			NewBrdMsg = binary_to_list(BrdMsg);
		true->
			NewBrdMsg = BrdMsg
	end,
	MapNode = node_util:get_mapnode(),
	rpc:call(MapNode,system_chat_op,send_message,[23,[NewBrdMsg,BrdTime],[]]).
	
countdown_broadcast(Time_s)->
	BrdMsg = integer_to_list(Time_s) ++"ç§’",
	MapNode = node_util:get_mapnode(),
	rpc:call(MapNode,system_chat_op,send_message,[23,[[],BrdMsg],[]]).

cancel_lastshutdowncmd()->
	%%io:format("cancel_lastshutdowncmd ~n"),
	ResetCmdID = get(last_shutdowncmd_id)+1,
	put(last_shutdowncmd_id,ResetCmdID),		
	put(shutdowncmd_flag,false).

handle_update_code()->
	version_up:up_all().

handle_update_data()->
	version_up:up_data().

handle_update_option()->
	version_up:up_option().
	

write_flag_file()->
	File = "update_server_flag",
	case file:open(File, [write]) of
		{ok,F}->
			file:close(F);
		_->
			slogger:msg("can not open file ~p ~n",[File])
	end.

clear_flag_file()->
	File = "update_server_flag",
	file:delete(File).
		
