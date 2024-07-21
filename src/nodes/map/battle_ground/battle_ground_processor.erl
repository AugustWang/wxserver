%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(battle_ground_processor).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/3]).

-compile(export_all).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("data_struct.hrl").

-record(state, {battle_info}).

%% External functions
%% ====================================================================
start_link(ProcName,BattleType,BattleInfo)->
	gen_server:start_link({local,ProcName},?MODULE,[ProcName, {BattleType,BattleInfo}],[]).

join_battle(Node,MapProcName,Info)->
	try
		gs_rpc:cast(Node,MapProcName,{role_join,Info})
	catch
		E:R->
			slogger:msg("join_instance error E ~p: R ~p",[E,R]),
			error
	end.
	
on_kill(Node,MapProcName,Info)->
	try
		gs_rpc:cast(Node,MapProcName,{role_kill,Info})
	catch
		E:R->
			slogger:msg("on_kill error E ~p: R ~p",[E,R]),
			error
	end.

leave_battle(Node,MapProcName,Info)->
	try
		gs_rpc:cast(Node,MapProcName,{role_leave,Info})
	catch
		E:R->
			slogger:msg("leave_battle error E ~p: R ~p",[E,R]),
			error
	end.

take_a_zone(Node,MapProcName,Info)->
	try
%%		io:format("take_a_zone Node ~p Proc ~p Info ~p ~n",[Node,MapProcName,Info]),
		gs_rpc:cast(Node,MapProcName,{take_a_zone,Info})
	catch
		E:R->
			slogger:msg("take_a_zone error E ~p: R ~p",[E,R]),
			error
	end.

battle_chat(Node,MapProcName,Info)->
	try
		gs_rpc:cast(Node,MapProcName,{role_battle_chat,Info})
	catch
		E:R->
			slogger:msg("role_battle_chat error E ~p: R ~p",[E,R]),
			error
	end.

get_reward(Node,MapProcName,Info)->
	try
		case gen_server:call({MapProcName,Node},{get_reward,Info}) of
			error->
				[];
			Re->
				Re
		end
	catch
		E:R->
			slogger:msg("get_reward error E ~p: R ~p",[E,R]),
			[]
	end.

get_keybornpos(Node,MapProcName,Info)->
	try
		case gen_server:call({MapProcName,Node},{get_keybornpos,Info}) of
			error->
				false;
			Re->
				Re
		end
	catch
		E:R->
			slogger:msg("get_keybornpos error E ~p: R ~p",[E,R]),
			false
	end.

get_tangle_kill_info(Node,MapProcName,Info)->
	try
		gs_rpc:cast(Node,MapProcName,{get_tangle_kill_info,Info})
	catch
		E:R->
			slogger:msg("get_tangle_kill_info error E ~p: R ~p",[E,R]),
			error
	end.
  
%%TODO:all try catch!!!
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([ProcName, {BattleType,BattleInfo}])->
	put(battle_type,BattleType),
	timer_center:start_at_process(),
	my_apply(get(battle_type), on_init,[ProcName,BattleInfo]),
	{ok, #state{battle_info = BattleInfo}}.

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
handle_call({get_reward,Info}, From, State) ->
	Reply = my_apply(get(battle_type), on_reward,[Info]),
	{reply, Reply, State};

handle_call({get_keybornpos,Info}, From, State) ->
	Reply = my_apply(get(battle_type), get_keybornpos,[Info]),
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

handle_info({role_join,Info},State)->
	my_apply(get(battle_type),on_role_join,[Info]),
	{noreply,State};

handle_info({role_kill,Info},State)->
	my_apply(get(battle_type),on_killed,[Info]),
	{noreply,State};

handle_info({role_leave,Info},State) ->
%%	io:format(" ~p role_leave ~n",[?MODULE]),
	my_apply(get(battle_type), on_role_leave,[Info]),
	{noreply,State};

handle_info({on_destroy},State)->
	my_apply(get(battle_type),on_destroy,[]),
	{noreply,State};

handle_info({take_a_zone,Info},State)->
	my_apply(get(battle_type),take_a_zone,[Info]),
	{noreply,State};

handle_info({do_interval,Info},State)->
	my_apply(get(battle_type),do_interval,[Info]),
	{noreply,State};

handle_info({sync_time,Info},State)->
	my_apply(get(battle_type),sync_time,[Info]),
	{noreply,State};

handle_info({battle_timeout,Info},State)->
	my_apply(get(battle_type),battle_timeout,[Info]),
	{noreply,State};

handle_info({destory_self},State)->
%%	io:format("~p destory_self ~n",[get(battle_type)]),
	my_apply(get(battle_type),destroy_self,[]),
	{noreply,State};
handle_info({get_tangle_kill_info,Info}, State) ->
	tangle_battle:get_role_tangle_kill_info(Info),
	{noreply, State};
handle_info({role_battle_chat,Info},State)->
	my_apply(get(battle_type),on_role_chat,[Info]),
	{noreply,State};

handle_info(Info, State) ->
	{noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
	slogger:msg("battle_ground_process terminate Reason ~p ~n",[Reason]),
	ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
	{ok, State}.

make_map_proc_name(BattleProcName)->
	erlang:list_to_atom(lists:append("map_", erlang:atom_to_list(BattleProcName))).

my_apply(Module,Fun,Args)->
	try
		erlang:apply(Module,Fun,Args)
	catch
		E:R->slogger:msg("apply ~p ~p ~p ~p, ~p ~p ~n",[Module,Fun,Args,erlang:get_stacktrace(),E,R]),error
	end.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
send_kick_out(Proc,MapProcName)->
	try
		Proc ! {kick_from_instance,MapProcName}
	catch
		E:R->slogger:msg("MapProcName~p send_kick_out Proc ~p",[MapProcName,Proc])
	end.