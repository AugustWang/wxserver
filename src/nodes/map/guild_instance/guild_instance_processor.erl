%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : SQ.Wang
%%% Description :
%%%
%%% Created : 2012-1-13
%%% -------------------------------------------------------------------
-module(guild_instance_processor).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("activity_define.hrl").
-include("little_garden.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,start_instance/4,stop_instance/1,is_instance_start/1]).

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
start_instance(GuildId,InstanceId,MapProc,Proc)->
	global_util:call(?MODULE,{start_instance,{GuildId,InstanceId,MapProc,Proc}}).

stop_instance(GuildId)->
	global_util:send(?MODULE,{stop_instance,GuildId}).

is_instance_start(MapProc)->
	global_util:call(?MODULE,{is_instance_start,MapProc}).
	
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
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
handle_call({is_instance_start,MapProc}, From, State) ->
    Reply = case get(MapProc) of
				undefined->
					false;
				Info->
					Info
			end,
    {reply, Reply, State};

handle_call({start_instance,{GuildId,InstanceId,MapProc,Proc}}, From, State) ->
    Nodes = node_util:get_low_load_node(?CANDIDATE_NODES_NUM),
	Node = lists:nth(random:uniform(length(Nodes)),Nodes),
	case rpc:call(Node,guild_instance_sup,start_child, [guild_instance,{InstanceId,GuildId}]) of
		{badrpc, _}->
			Reply = false;
		_->
			put(MapProc,{Node,Proc,MapProc}),
			Reply = {ok,Node}
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
handle_info({stop_instance,GuildId}, State) ->
	Proc = guild_instance_sup:make_proc_name(guild_instance,{?GUILD_INSTANCEID,GuildId}),
	MapProc = battle_ground_processor:make_map_proc_name(Proc),
	case get(MapProc) of
		{Node,Proc,MapProc} ->
			erlang:send_after(1000,MapProc, {on_destroy}),
			rpc:call(Node,guild_instance_sup,stop_child, [Proc]);
		_->
			ignor
	end,
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

