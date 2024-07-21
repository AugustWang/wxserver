%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : SQ.Wang
%%% Description :
%%%
%%% Created : 2012-1-5
%%% -------------------------------------------------------------------
-module(guild_instance_manager).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("npc_define.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([start_link/3,join_guildinstance/1,call_guild_monster/3,callback_guild_monster/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link(ProcName,Type,Info)->
	gen_server:start_link({local,ProcName},?MODULE,[ProcName,Type,Info],[]).

%% ====================================================================
%% Server functions
%% ====================================================================
join_guildinstance(MapProc)->
	global_util:send(?MODULE,{join_guildinstance,MapProc}).

call_guild_monster(MonsterId,BornPos,GuildId)->
	global_util:send(?MODULE,{call_guild_monster,MonsterId,BornPos,GuildId}).

callback_guild_monster(MonsterId,GuildId)->
	global_util:send(?MODULE,{callback_guild_monster,MonsterId,GuildId}).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([ProcName,InstanceType,{InstanceId,GuildId}]) ->
	InstanceInfo = instance_proto_db:get_info(InstanceId),
	MapId = instance_proto_db:get_level_mapid(InstanceInfo),
	MapProc = battle_ground_processor:make_map_proc_name(ProcName),
	map_manager:start_instance(MapProc,{atom_to_list(ProcName),InstanceId,{?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM}},MapId), 
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
handle_call({get_instance_info,MapProc}, From, State) ->
    Reply = get(MapProc),
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
handle_info({join_guildinstance,MapProc}, State) ->
	guild_op:trans_to_instance(MapProc),
	{noreply, State};

handle_info({call_guild_monster,MonsterId,BornPos,GuildId}, State) ->
	guild_monster:handle_call_guild_monster(MonsterId,BornPos,GuildId),
	{noreply, State};

handle_info({callback_guild_monster,MonsterId,GuildId}, State) ->
	guild_monster:handle_callback_guild_monster(MonsterId,GuildId),
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
my_apply(Mod,Fun,Args)->
	try
		apply(Mod,Fun,Args)
	catch
		E:R->
			slogger:msg("guild_instance mod ~p,~p,~p error ~p,~p",[Mod,Fun,Args,E,R]),
			error
	end.
