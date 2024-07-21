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
-module(map_manager).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_define.hrl").
-include("little_garden.hrl").
-define(GAME_MAP_MANAGER,local_map_manager).
%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,start_map_processor/4,stop_map_processor/3,start_instance/3,stop_instance/2,make_map_process_name/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).


%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?GAME_MAP_MANAGER},?MODULE,[],[]).

%% ====================================================================
%% Server functions
%% ====================================================================

start_map_processor(MapManagerNode,LineId,MapId,Tag)->
	gs_rpc:cast(MapManagerNode, ?GAME_MAP_MANAGER ,{start_map_process,LineId,MapId,Tag}).

stop_map_processor(MapManagerNode,LineId,MapId)->
	gs_rpc:cast(MapManagerNode, ?GAME_MAP_MANAGER , {stop_map_process,LineId,MapId}).

start_instance(MapName,CreatInfo,MapId)->
	try
		gen_server:call(?GAME_MAP_MANAGER,{start_instance,MapName,CreatInfo,MapId})
	catch
		E:R ->
			instanceid_generator:safe_turnback_proc(MapName),
			slogger:msg("map_manager:start_instance error: ~p ~p,MapName ~p,ProtoId ~p,MapId ~p",[E,R,MapName,CreatInfo,MapId]),
			error
	end.

stop_instance(MapManagerNode,MapName)->
	gs_rpc:cast(MapManagerNode, ?GAME_MAP_MANAGER , {stop_instance,MapName}).
		
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	%% start time to check 
	send_check_message(),
	%%load all map
	AllMapInfo = map_info_db:get_all_maps_and_serverdata(),
	lists:foreach(fun({MapId,MapDataId})->
		MapDb = mapdb_processor:make_db_name(MapId),
		case ets:info(MapDb) of
			undefined->
				ets:new(MapDb, [set,named_table]),	%% first new the database, and then register proc
				case MapDataId of
					[]->
						nothing;
					_->
						map_db:load_map_ext_file(MapDataId,MapDb),
						map_db:load_map_file(MapDataId,MapDb)
				end;
			_->
				nothing
		end end,AllMapInfo),
%%	DefaultLoadMapIDs = [?DEFAULT_MAP|env:get(preload_map,undefined)],
%%	lists:foreach(fun(MapId)->
%%		MapDb = mapdb_processor:make_db_name(MapId),
%%		case ets:info(MapDb) of
%%			undefined->
%%				ets:new(MapDb, [set,named_table]),	%% first new the database, and then register proc
%%				map_db:load_map_ext_file(MapId,MapDb),
%%				map_db:load_map_file(MapId,MapDb);
%%			_->
%%				nothing
%%		end end,DefaultLoadMapIDs),
	erlang:garbage_collect(),
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
handle_call({start_instance,MapName,CreatInfo,MapId}, _From, State) ->
	case map_sup:start_child(MapName,{-1,MapId},CreatInfo) of
		{ok,Pid} ->
			slogger:msg("---start map ok \n"),
		    Reply = ok;
		{ok,Pid,_Info} ->
			slogger:msg("---start map ok info ~p \n",[_Info]),
		    Reply = ok;
		{error,Error} ->
			slogger:msg("---start map failed, reason: ~p\n", [Error]),
			Reply = error,
			Pid = 0
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
handle_info({global_line_check}, State) ->
	case lines_manager:whereis_name() of
		error->
			slogger:msg("lines manager can not found ,1 sencond check\n"),
			send_check_message();
		undefined ->
			slogger:msg("lines manager can not found ,1 sencond check\n"),
			send_check_message();
		_GlobalPid-> 
			slogger:msg("send to lines_manager {~p,~p}\n",[node(),?GAME_MAP_MANAGER]),
			lines_manager:regist_mapmanager({node(),?GAME_MAP_MANAGER})
	end,
	{noreply, State};
		
handle_info({start_map_process,LineId,MapId,Tag}, State) ->		
	slogger:msg("receive the msg:start_map_process Line ~p Map ~p\n",[LineId,MapId]),
	MapName = make_map_process_name(LineId,MapId),			
	case map_sup:start_child(MapName,{LineId,MapId},Tag) of
		{ok,Child} ->
		        lines_manager:regist_mapprocessor({node(), LineId, MapId, MapName});
		{ok,Child,Info} ->
		        lines_manager:regist_mapprocessor({node(), LineId, MapId, MapName});
		{error,Error} ->
			slogger:msg("---start map failed, reason: ~p\n", [Error])
	end,
	{noreply, State};

handle_info({stop_map_process,LineId,MapId}, State) ->
	MapName = make_map_process_name(LineId,MapId),
	map_sup:stop_child(MapName),	
    {noreply, State};

handle_info({stop_instance,MapName}, State) ->
	map_sup:stop_child(MapName),	
    {noreply, State};

handle_info({change_map_bornpos,MapId,BronMap,BornX,BornY},State)->
	try
		MapDb = mapdb_processor:make_db_name(MapId),
		ets:insert(MapDb,{born_pos,{BronMap,{BornX,BornY}}})
	catch
		E:R->
			slogger:msg("change_map_bornpos error E:~p R:~p ~n",[E,R])
	end,
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

send_check_message()->
	timer_util:send_after(1000, {global_line_check}).


make_map_process_name(LineId,MapId)->
	ListMap = lists:append(["map_",integer_to_list(LineId),"_",integer_to_list(MapId)]),
	list_to_atom(ListMap).

