%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-14
%%% -------------------------------------------------------------------
-module(mapdb_processor).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("map_define.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([start_link/2,
	 whereis/1,
	 query_db_name/1,
	 query_map_stand/2,
	 get_map_data/1,
	 make_db_name/1,
	 query_born_pos/1,
	 query_safe_grid/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {mapdb}).

-compile(export_all).

%% TODO: ä¸´æ—¶ä»£ç éœ€è¦æ›´æ”¹
-define(View, 15).
-define(MapRect, {{0,0}, {50, 50}}).


%% ====================================================================
%% External functions
%% ====================================================================

start_link(MapFile,MapId)->
	gen_server:start_link(?MODULE ,[MapFile,MapId], []).

whereis(MapId)->
	MapDbProc = make_db_proc(MapId),
	case erlang:whereis(MapDbProc) of
		undefined->undefined;
		_Pid->MapDbProc
	end.

query_db_name(MapDbProc)->
	Reply = gen_server:call(MapDbProc, {query_db_name}),
	case Reply of
		{ok,DbName}->DbName;
		_->undefined
	end.

query_safe_grid(MapDb,{GridX,GridY})->
	case ets:lookup(MapDb, {sg,GridX,GridY}) of
		[]->
			0;
		[{_,Value}]->
			Value
	end.
	
	
query_born_pos(MapDb)->
	case ets:lookup(MapDb, born_pos) of
 		[PosInfo] ->
 			{born_pos,BornInfo} = PosInfo,
			BornInfo;
		[] ->
 			[]
 	end.
 	
query_map_stand(MapDbName,{X,Y})->
 	case ets:lookup(MapDbName, Y) of
 		[{Y,MaxX,StandBin}] ->
			if
				X>=MaxX->
					?MAP_DATA_TAG_CANNOT_WALK;
				true->
					PassX = X*8,
					<<_:PassX,Stande:8,_/binary>> = StandBin,					
						Stande
			end;
		[] ->
 			?MAP_DATA_TAG_NORMAL	%%
 	end.

get_map_data(Map_id) ->
	MapDbProc = ?MODULE:whereis(Map_id),
	MapDbName = query_db_name(MapDbProc),
	[{_,Data}] = ets:lookup(MapDbName, map_data),
	Data.

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
init([MapFile,MapId]) ->
%%	case {ok,{{0,0},true}} of % file:consult(MapFile)
%%		{error,Reson}-> {stop,Reson};

%%		{ok,L}-> 
			MapDB = make_db_name(MapId),
			ets:new(MapDB, [set,named_table]),	%% first new the database, and then register proc
			slogger:msg("map_db:load_map_file MapId ~p MapDB~p ~n",[MapId,MapDB]),
			map_db:load_map_file(MapId,MapDB),
			register(make_db_proc(MapId),self()),
			{true, Tree} = build_quadtree(MapFile),
			ets:insert(MapDB, {map_data, Tree}),
			{ok, #state{mapdb=MapDB}}.
%%	end.


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
handle_call(Request, From, State) ->
	case Request of
		{query_db_name}-> {reply, {ok,State#state.mapdb}, State};
		_ -> {reply, ok, State}
	end.



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

make_db_name(MapId)->
	list_to_atom(lists:append([integer_to_list(MapId),"_db"])).

make_map_ext_name(MapId)->
	list_to_atom(lists:append([integer_to_list(MapId),"_ext_db"])).	

make_db_proc(MapId)->
	list_to_atom(lists:append([integer_to_list(MapId),"_proc"])).


build_quadtree(_MapFile) ->
	%%    {Rect, View} = file:consults(MapFile),
	quadtree:build(?MapRect, ?View).
