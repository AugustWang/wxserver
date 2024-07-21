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
-module(activity_manager).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,
		 apply_join_activity/2,
		 apply_leave_activity/2,
		 apply_stop_me/2,
		 get_activity_state/1,
		 role_online_notify/1,
		 request_spalist/1,
		 spa_touch_other_role/2,
		 spa_add_vip_count/2,
		 treasure_transport_online_notic/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?MODULE},?MODULE,[],[]).

%% ====================================================================
%% Server functions
%% ====================================================================

role_online_notify(Info)->
	try
		global_util:send(?MODULE,{role_online_notify,Info})
	catch
		E:R->
			slogger:msg("role_online_notify error ~p ~p ~n ",[E,R]),
			error
	end.

apply_join_activity(ActivityType,Info)->
	try
		global_util:call(?MODULE,{apply_join_activity,{ActivityType,Info}})
	catch
		E:R->
			slogger:msg("apply_join_activity error ~p ~p ~n ",[E,R]),
			error
	end.

apply_leave_activity(ActivityType,Info)->
	try
		global_util:send(?MODULE,{apply_leave_activity,{ActivityType,Info}})
	catch
		E:R->
			slogger:msg("apply_leave_activity error ~p ~p ~n ",[E,R]),
			error
	end.

apply_stop_me(ActivityType,Info)->
	try
		global_util:send(?MODULE,{apply_stop_me,{ActivityType,Info}})
	catch
		E:R->
			slogger:msg("apply_stop_me error ~p ~p ~n ",[E,R]),
			error
	end.

get_activity_state(ActivityType)->
	try
		global_util:call(?MODULE,{get_activity_state,ActivityType})
	catch
		E:R->
			slogger:msg("get_activity_state error ~p ~p ~n ",[E,R]),
			error
	end.

request_spalist(RoleId)->
	try
		global_util:send(?MODULE,{request_spalist,RoleId})
	catch
		E:R->
			slogger:msg("request_spalist error ~p ~p ~n ",[E,R]),
			error
	end.

spa_touch_other_role(Type,Info)->
	try
		global_util:send(?MODULE,{spa_touch_other_role,Type,Info})
	catch
		E:R->
			slogger:msg("spa_swimming error ~p ~p ~n ",[E,R]),
			error
	end.

spa_add_vip_count(RoleId,AddCount)->
	try
		global_util:send(?MODULE,{spa_add_vip_count,RoleId,AddCount})
	catch
		E:R->
			slogger:msg("spa_add_vip_count error ~p ~p ~n ",[E,R]),
			error
	end.

role_online_to_recharge(Name,Money)->
		try
		global_util:send(?MODULE,{role_recharge,Name,Money})
	catch
		E:R->
			slogger:msg("spa_add_vip_count error ~p ~p ~n ",[E,R]),
			error
	end.

treasure_transport_online_notic(RoleId)->
	global_util:send(?MODULE,{treasure_transport_online_notic,RoleId}).
	
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
		activity_manager_op:init()
	catch
		E:R ->slogger:msg("activity_manager init error ~p ~p ~p ~n",
						  [E,R,erlang:get_stacktrace()])
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
handle_call({get_activity_state,Info}, _From, State) ->
	Reply = 
	try
		activity_manager_op:get_activity_state(Info)
	catch
		E:R->
			slogger:msg("get_activity_state error ~p ~p ~p ~n ",
						[E,R,erlang:get_stacktrace()]),
			error
	end,
    {reply, Reply, State};

handle_call({apply_join_activity,{ActivityType,Info}},_From,State)->
	Reply=
	try
		activity_manager_op:apply_join_activity(ActivityType,Info)
	catch
		E:R->
			slogger:msg("apply_join_activity error ~p ~p ~p ~n ",
						[E,R,erlang:get_stacktrace()]),
			error
	end,
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
handle_info({activity_check}, State) ->
	try
		activity_manager_op:on_check()
	catch
		E:R->
			slogger:msg("activity_check error ~p ~p ~p ~n ",
						[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({apply_leave_activity,{ActivityType,Info}},State)->
	try
		activity_manager_op:apply_leave_activity(ActivityType,Info)
	catch
		E:R->
			slogger:msg("apply_join_activity error ~p ~p ~p ~n ",
						[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({apply_stop_me,{ActivityType,Info}},State)->
	try
		activity_manager_op:apply_stoped_activity(ActivityType,Info)
	catch
		E:R->
			slogger:msg("apply_stop_me error ~p ~p ~p ~n ",
						[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({role_online_notify,Info}, State)->
	try
		activity_manager_op:role_online_notify(Info)
	catch
		E:R->
			slogger:msg("role_online_notify error ~p ~p ~p ~n ",
						[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({request_spalist,RoleId}, State)->
	try
		spa_manager_op:request_spalist(RoleId)
	catch
		E:R->
			slogger:msg("request_spalist error ~p ~p ~p ~n ",
						[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({spa_touch_other_role,Type,Info}, State)->
	try
		spa_manager_op:spa_touch_other_role(Type,Info)
	catch
		E:R->
			slogger:msg("spa_swimming error ~p ~p ~p ~n ",
						[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({spa_add_vip_count,RoleId,AddCount}, State)->
	try
		spa_manager_op:spa_add_vip_count(RoleId,AddCount)
	catch
		E:R->
			slogger:msg("spa_swimming error ~p ~p ~p ~n ",
						[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({spa_start_notify,InstanceLevel}, State)->
	try
		spa_manager_op:spa_start_notify(InstanceLevel)
	catch
		E:R->
			slogger:msg("spa_start_notify error ~p ~p ~p ~n ",
						[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({treasure_transport_online_notic,RoleId}, State)->
	treasure_transport_manager:role_on_line_notic(RoleId),
	{noreply, State};
%%çŽ©å®¶å……å€¼
handle_info({role_recharge,Name,Money}, State)->
	role_op:role_recharge(Name,Money),
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

