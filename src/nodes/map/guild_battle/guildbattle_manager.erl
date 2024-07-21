%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-11-1
%% Description: TODO: Add description to guildbattle_manager
-module(guildbattle_manager).
-behaviour(gen_server).

%%
%% Include files
%%
-include("error_msg.hrl").
-record(state, {}).
%%
%% Exported Functions
%%
%% External exports
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-compile(export_all).

%%
%% API Functions

%%
%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: start_link/1
%% Description: start server
%% --------------------------------------------------------------------
start_link() ->
	slogger:msg("guildbattlemgr start~n"),
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).
	
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init(_Args) ->	
    slogger:msg("guildbattlemgr init~n"),
	try    
		timer_center:start_at_process(),
		guildbattle_manager_op:init()
	catch
		E:R->
			slogger:msg("init E:~p R:~p S:~p \n",[E,R,erlang:get_stacktrace()])
	end,
	{ok, #state{}}.


%%
%% call
%%

%%
%%return [] | {state,{node,mapproc,guildids,bornposindex}}
%%
get_battle_info()->
	global_util:call(?MODULE,{get_battle_info}).

%%
%%return [] | {guildid,guildindex,guildname}
%%
get_guild_info()->
	global_util:call(?MODULE,{get_guild_info}).

%%
%%return errno
%%
apply_battle(RoleId,GuildId)->
	global_util:call(?MODULE,{apply_battle,{RoleId,GuildId}}).
%%
%%send
%%
change_throne_state(ThroneState,GuildId,RoleId,RoleName,RoleClass,RoleGender,StartTime)->
	global_util:send(?MODULE,{change_throne_state,{ThroneState,GuildId,RoleId,RoleName,RoleClass,RoleGender,StartTime}}).

change_battle_fight()->
	global_util:send(?MODULE,{change_battle_fight}).

role_join(RoleId,GuildId)->
	global_util:send(?MODULE,{role_join,{RoleId,GuildId}}).

role_leave(RoleId,GuildId)->
	global_util:send(?MODULE,{role_leave,{RoleId,GuildId}}).

kill_other(RoleId,GuildId,OtherId)->
	global_util:send(?MODULE,{kill_other,{RoleId,GuildId,OtherId}}).

role_online(RoleId,GuildId)->
	global_util:send(?MODULE,{role_online,{RoleId,GuildId}}).

change_leaderinfo(RoleId,GuildId)->
	global_util:send(?MODULE,{change_leaderinfo,{RoleId,GuildId}}).

change_guild_name(GuildId,NewNameStr)->
	global_util:send(?MODULE, {change_guild_name,{GuildId,NewNameStr}}).

change_role_name(RoleId,NewNameStr)->
	global_util:send(?MODULE, {change_role_name,{RoleId,NewNameStr}}).

get_guilebattle_rank_info()->
	global_util:call(?MODULE,{get_guilebattle_rank_info}).

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

handle_call({get_battle_info},_From, State)->
	Reply = guildbattle_manager_op:get_battle_info(),
    {reply, Reply, State};

handle_call({get_guild_info},_From, State)->
	Reply = guildbattle_manager_op:get_guild_info(),
    {reply, Reply, State};

handle_call({apply_battle,{RoleId,GuildId}},_From, State)->
	Reply =
		try
			guildbattle_manager_op:apply_battle(RoleId,GuildId)
		catch
			E:R->
				slogger:msg("apply_battle E:~p R:~p S:~p \n",[E,R,erlang:get_stacktrace()]),
				?ERROR_UNKNOWN
		end,
    {reply, Reply, State};

handle_call({get_guilebattle_rank_info},_From, State)->
	Reply = guildbattle_manager_op:get_guilebattle_rank_info(),
    {reply, Reply, State};

handle_call(_Request,_From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info({change_throne_state,{ThroneState,GuildId,RoleId,RoleName,RoleClass,RoleGender,StartTime}}, State) ->
	catch guildbattle_manager_op:change_throne_state(ThroneState,GuildId,RoleId,RoleName,RoleClass,RoleGender,StartTime),
    {noreply, State};

handle_info({role_join,{RoleId,GuildId}}, State) ->
	catch guildbattle_manager_op:on_role_join(RoleId,GuildId),
    {noreply, State};

handle_info({role_leave,{RoleId,GuildId}}, State) ->
	catch guildbattle_manager_op:on_role_leave(RoleId,GuildId),
    {noreply, State};

handle_info({kill_other,{RoleId,GuildId,OtherId}}, State) ->
	catch guildbattle_manager_op:on_kill_other(RoleId,GuildId,OtherId),
    {noreply, State};

handle_info({battle_check}, State) ->
	catch guildbattle_manager_op:on_check(),
    {noreply, State};

handle_info({change_battle_fight},State) ->
	catch guildbattle_manager_op:change_battle_fight(),
    {noreply, State};

handle_info({role_online,{RoleId,GuildId}}, State) ->
	catch guildbattle_manager_op:role_online(RoleId,GuildId),
    {noreply, State};

handle_info({change_leaderinfo,{RoleId,GuildId}}, State)->
	catch guildbattle_manager_op:change_leaderinfo(RoleId,GuildId),
	{noreply, State};

handle_info({change_guild_name,{GuildId,NewNameStr}},State)->
	catch guildbattle_manager_op:change_guild_name(GuildId,NewNameStr),
	{noreply, State};

handle_info({change_role_name,{RoldId,NewNameStr}},State)->
	catch guildbattle_manager_op:change_role_name(RoldId,NewNameStr),
	{noreply, State};
		   

handle_info(Info, State) ->
	slogger:msg("~p handle_info error:~p~n", [?MODULE,Info]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
	slogger:msg("~p~n",[Reason]),
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State,_Extra) ->
    {ok, State}.

%%
%% Local Functions
%%

