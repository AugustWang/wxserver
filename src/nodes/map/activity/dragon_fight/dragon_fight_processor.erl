%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-11
%%% -------------------------------------------------------------------
-module(dragon_fight_processor).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_define.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([apply_join/1,hook_role_online/1,apply_get_faction_num/1,apply_change_my_faction/1,get_dragon_fight_state/1,get_user_result/1]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
hook_role_online(Info)->
	try
		case dragon_fight_manager:check_dragon_start() of
			true->
					global_util:call(?MODULE,{role_online,Info});
		    _->
				nothing
			end
	catch
		_E:_R->
			nothing
	end.	
apply_join(Info)->
	try
		global_util:send(?MODULE,{apply_join,Info})
	catch
		E:R->
			slogger:msg("answer apply_leave_activity error ~p ~p ~n ",[E,R]),
			error
	end.

%%return : 0:not running/relation_questid
get_dragon_fight_state(Info)->
	try
		global_util:call(?MODULE,{dragon_fight_state,Info})
	catch
		_E:_R->
		error		%%not start
	end.

%%return : result_state
get_user_result(Info)->
	try
		global_util:call(?MODULE,{get_user_result,Info})
	catch
		_E:_R->
		error		%%not start
	end.

apply_get_faction_num(Info)->
	try
		global_util:call(?MODULE,{get_faction_num,Info})
	catch
		E:R->
			slogger:msg("answer apply_change_faction error ~p ~p ~n ",[E,R]),
			error
	end.

apply_change_my_faction(Info)->
	try
		global_util:call(?MODULE,{change_my_faction,Info})
	catch
		E:R->
			slogger:msg("answer apply_leave_activity error ~p ~p ~n ",[E,R]),
			error
	end.

start_link(Info)->
	gen_server:start_link({local,?MODULE},?MODULE,Info,[]).

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
init(Info) ->
	timer_center:start_at_process(),
	dragon_fight_op:init(Info),
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
handle_call({get_faction_num,Info}, _From, State) ->
	Replay =
	try
		dragon_fight_op:get_faction_num(Info)
	catch
		E:R->
			slogger:msg("get_faction_num E ~p R ~p ~n",[E,R]),
			error
	end,
	{reply, Replay, State};

handle_call({dragon_fight_state,Info},_From, State) ->
	Replay =
	try
		dragon_fight_op:get_state_for_faction(Info)
	catch
		E:R->
			slogger:msg("dragon_fight_state E ~p R ~p ~n",[E,R]),
			error
	end,
	{reply, Replay, State};

handle_call({change_my_faction,Info},_From, State) ->
	Replay = 
	try
		dragon_fight_op:change_faction(Info)
	catch
		E:R->
			slogger:msg("change_my_faction E ~p R ~p ~n",[E,R]),
			error
	end,	
	{reply, Replay, State};

handle_call({get_user_result,Info},_From, State) ->
	Replay = 
	try
		dragon_fight_op:get_user_result(Info)
	catch
		E:R->
			slogger:msg("change_my_faction E ~p R ~p ~n",[E,R]),
			error
	end,	
	{reply, Replay, State};

handle_call({role_online,Info},_From, State) ->
	Replay = 
	try
  		dragon_fight_op:role_online(Info)
	catch
		E:R->
			error
	end,
    {reply, Replay, State};

handle_call(_Info, _From, State) ->
    {reply, ok, State}.

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
handle_info(start_dragon_fight, State) ->
	dragon_fight_op:start(),
	{noreply, State};

handle_info({left_time_check},State) ->
	dragon_fight_op:left_time_check(),
	{noreply, State};

handle_info({apply_join,Info},State) ->
	dragon_fight_op:apply_join(Info),
	{noreply, State};

handle_info(_INFO, State) ->
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


