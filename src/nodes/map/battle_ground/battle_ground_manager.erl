%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(battle_ground_manager).
-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_define.hrl").

%% External exports
-export([start_link/0,start_battle_ground/0,stop_battle_ground/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-compile(export_all).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?MODULE},?MODULE,[],[]).

get_my_battle_ground(Type,Info)->
	try
		global_util:call(?MODULE,{get_adapt_battle_ground,{Type,Info}})
	catch
		E:R->
			slogger:msg("get_my_battle_ground error ~p ~p ~n ",[E,R]),
			error
	end.

get_tangle_records(RoleId)->
	try
		global_util:send(?MODULE,{get_tangle_records,RoleId})
	catch
		E:R->
			slogger:msg("get_my_battle_ground error ~p ~p ~n ",[E,R]),
			error
	end.
	
get_tangle_kill_info(Info)->
	try
		global_util:send(?MODULE,{get_tangle_kill_info,Info})
	catch
		E:R->
			slogger:msg("get_tangle_kill_info error ~p ~p ~n ",[E,R]),
			error
	end.
	
get_tangle_battle_curenum()->
	try
		global_util:call(?MODULE,{get_tangle_battle_curenum})
	catch
		E:R->
			slogger:msg("get_tangle_battle_curenum error ~p ~p ~n ",[E,R]),
			[]
	end.
		
apply_yhzq(RoleId,BattleType)->
	try
		global_util:send(?MODULE,{apply_yhzq,{someone,RoleId,BattleType}})
	catch
		E:R->
			slogger:msg("someone_apply_yhzq error ~p ~p ~n ",[E,R]),
			error
	end.
		

apply_yhzq(LeaderId,GroupList,GroupId,BattleType)->
	try
		global_util:send(?MODULE,{apply_yhzq,{group,LeaderId,GroupList,GroupId,BattleType}})
	catch
		E:R->
			slogger:msg("group_apply_yhzq error ~p ~p ~n ",[E,R]),
			error
	end.

reject_to_join_yhzq(RoleId,BattleType,BattleId)->
	try
		global_util:send(?MODULE,{reject_to_join_yhzq,{RoleId,BattleType,BattleId}})
	catch
		E:R->
			slogger:msg("reject_to_join_yhzq error ~p ~p ~n ",[E,R]),
			error
	end.	

cancel_apply_yhzq(RoleId,BattleType)->
	try
		global_util:send(?MODULE,{cancel_apply_yhzq,{RoleId,BattleType}})
	catch
		E:R->
			slogger:msg("cancel_apply_yhzq error ~p ~p ~n ",[E,R]),
			error
	end.

change_yhzq_state(State,Info)->
	try
		global_util:send(?MODULE,{change_yhzq_state,{State,Info}})
	catch
		E:R->
			slogger:msg("change_yhzq_state error ~p ~p ~n ",[E,R]),
			error
	end.

get_reward_error(RoleId)->
	try
		global_util:send(?MODULE,{get_reward_error,RoleId})
	catch
		E:R->
			slogger:msg("get_reward_error error ~p ~p ~n ",[E,R]),
			error
	end.

%%
%% return time {A,B,C}
%%
	
get_battle_start(Type)->
	try
		global_util:call(?MODULE,{check_battle_time,{Type}})
	catch
		E:R->
			slogger:msg("get_battle_start error ~p ~p ~n ",[E,R]),
			{0,0,0}
	end.

%%
%%ç”³è¯·åŠ å…¥æˆ˜åœº
%%
apply_for_battle(BattleType,Info)->
	try
		global_util:send(?MODULE,{apply_for_battle,{BattleType,Info}})
	catch
		E:R->
			slogger:msg("apply_for_battle error ~p ~p ~n ",[E,R]),
			error
	end.

%%
%%å–æ¶ˆåŠ å…¥æˆ˜åœº
%%
cancel_apply_battle(BattleType,Info)->
	try
		global_util:send(?MODULE,{cancel_apply_battle,{cancel_apply_battle,Info}})
	catch
		E:R->
			slogger:msg("cancel_apply_battle error ~p ~p ~n ",[E,R]),
			error
	end.	

notify_manager_battle_start(BattleType,Info)->
	try
		global_util:send(?MODULE,{notify_manager_battle_start,{BattleType,Info}})
	catch
		E:R->
			slogger:msg("notify_manager_battle_start error ~p ~p ~n ",[E,R]),
			error
	end.	

notify_manager_role_leave(BattleType,Info)->
	try
		global_util:send(?MODULE,{notify_manager_role_leave,{BattleType,Info}})
	catch
		E:R->
			slogger:msg("notify_manager_role_leave error ~p ~p ~n ",[E,R]),
			error
	end.
		

start_battle_ground()->
	todo.

stop_battle_ground()->
	todo.

get_battle_info()->
	todo.

%%
%%éŽ´æ¨ºæº€æ¾¶æ ­î•«é™æ §îš›é”?
%%
get_reward_by_manager(Type,RoleId)->
	try
		global_util:send(?MODULE,{get_reward_by_manager,{Type,RoleId}})
	catch
		E:R->
			slogger:msg("get_reward_by_manager error ~p ~p ~n ",[E,R]),
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
	%% load db ,init info
	try
		timer_center:start_at_process(),
		battle_ground_manager_op:init()
	catch
		E:R ->slogger:msg("battle_ground_manager init error ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()])
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
handle_call({get_adapt_battle_ground,{Type,Info}}, _From, State) ->
%%	Reply = 
%%	try
%%		case battle_ground_manager_op:get_adapt_battle_ground(Type,Info) of
%%			{0,0,0,0}->
%%				error;
%%			{KeyAc,NumAc,NodeAc,ProcAc}->
%%				{NodeAc,ProcAc}
%%		end
%%	catch
%%		E:R->
%%			slogger:msg("get_my_battle_ground error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
%%			error
%%	end,
    {reply, nothing, State};
    
handle_call({get_tangle_battle_curenum}, _From, State) ->
	Reply = battle_ground_manager_op:get_tangle_battle_curenum(), 
    {reply, Reply, State};
    
handle_call({check_battle_time,{Type}}, _From, State) ->
	Reply = 
	try
		 battle_ground_manager_op:check_battle_time(Type)
	catch
		E:R->
			slogger:msg("get_battle_start error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			{0,0,0}
	end,
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
		
handle_info({battle_check}, State) ->
	try
		battle_ground_manager_op:on_check()
	catch
		E:R->
			slogger:msg("battle_ground_check error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({battle_start_notify,Info}, State) ->
	try
		battle_ground_manager_op:battle_start_notify(Info)
	catch
		E:R->
			slogger:msg("battle_start_notify error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({get_tangle_records,RoleId}, State) ->
	try
		battle_ground_manager_op:get_role_battle_info({?TANGLE_BATTLE,RoleId})
	catch
		E:R->
			slogger:msg("get_tangle_records error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({get_tangle_kill_info,Info},State)->
	try
		battle_ground_manager_op:get_role_battle_kill_info({?TANGLE_BATTLE,Info})
	catch
		E:R->
			slogger:msg("get_role_battle_kill_info error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};
	
handle_info({on_battle_end,Info}, State) ->
	try
		battle_ground_manager_op:on_battle_end(Info)
	catch
		E:R->
			slogger:msg("on_battle_end error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({apply_for_battle,Info},State)->
	try
		battle_ground_manager_op:apply_for_battle(Info)
	catch
		E:R->
			slogger:msg("apply_for_battle error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({cancel_apply_battle,Info},State)->	
	try
		battle_ground_manager_op:cancel_apply_battle(Info)
	catch
		E:R->
			slogger:msg("cancel_apply_battle error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

%%handle_info({check_init_battle,Info},State)->
%%	try
%%		battle_ground_manager_op:check_init_battle(Info)
%%	catch
%%		E:R->
%%			slogger:msg("check_init_battle error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
%%			error
%%	end,
%%	{noreply, State};

handle_info({notify_manager_battle_start,Info},State)->
	try
		battle_ground_manager_op:notify_manager_battle_start(Info)
	catch
		E:R->
			slogger:msg("notify_manager_battle_start error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({notify_manager_role_leave,Info},State)->
	try
		battle_ground_manager_op:notify_manager_role_leave(Info)
	catch
		E:R->
			slogger:msg("notify_manager_role_leave error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({get_reward_by_manager,Info},State)->
	try
		battle_ground_manager_op:get_reward_by_manager(Info)
	catch
		E:R->
			slogger:msg("get_reward_by_manager error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};
		

%%		
%% yhzq 
%%
handle_info({apply_yhzq,Info},State)->
	try
		battle_ground_manager_op:apply_yhzq(Info)
	catch
		E:R->
			slogger:msg("apply_yhzq ~p error ~p ~p ~p ~n ",[Info,E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({reject_to_join_yhzq,Info},State)->
	try
		battle_ground_manager_op:reject_to_join_yhzq(Info)
	catch
		E:R->
			slogger:msg("reject_to_join_yhzq ~p error ~p ~p ~p ~n ",[Info,E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({cancel_apply_yhzq,Info},State)->
	try
		battle_ground_manager_op:cancel_apply_yhzq(Info)
	catch
		E:R->
			slogger:msg("cancel_apply_yhzq ~p error ~p ~p ~p ~n ",[Info,E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({change_yhzq_state,Info},State)->
	try
		battle_ground_manager_op:change_yhzq_state(Info)
	catch
		E:R->
			slogger:msg("change_yhzq_state ~p error ~p ~p ~p ~n ",[Info,E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({get_reward_error,RoleId},State)->
	try
		tangle_battle_manager_op:get_reward_error(RoleId)
	catch
		E:R->
			slogger:msg("get_reward_error ~p error ~p ~p ~p ~n ",[RoleId,E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({syna_bonfire_time}, State) ->
	guild_instance_manager_op:syna_bonfire_time(),
	{noreply, State};

handle_info(_INFO, State) ->
	io:format("_INFO ~p ~n",[_INFO]),
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

