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
-module(line_processor).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("line_def.hrl").

-define(LOOKUP_INTERVAL, 100).

%% --------------------------------------------------------------------
%% External exports
-export([
	 start_link/1,
	 lookup_map_name/2,
	 get_role_count_by_map/1,
	 get_role_count_by_line_map/2
	]).

-compile(export_all).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {line_name}).

%% ====================================================================
%% External functions
%% ====================================================================
%%	TODO:this proc not need again!!!!!!! zhaoyan/2011-6-8
start_link({LineName, NamedProc})->
	gen_server:start_link({local, LineName}, ?MODULE, {LineName, NamedProc}, []).

% ====================================================================
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
init({LineName, NamedProc}) ->
	lines_manager:regist_to_manager(NamedProc,LineName),
	{ok, #state{line_name = LineName}}.

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
%%% Description: get the maps that belongs to this line server.
%%% AllMaps: the map data of all line server.
%%% LineName: this line server' name.
%%% Return: maps that belongs to this line server.
%% --------------------------------------------------------------------
%% @spec create_map(atom(), atom()) -> list().
get_map(AllMaps, LineName, MapNodeName) ->
	get_map2(AllMaps, LineName, MapNodeName).

get_map2([H|T], LineName, {SNode,Host,MapNodeName}) ->
	{Line, Maps} = H,
	case Line =:= LineName of
		true ->
			Fun = fun(MapRec) ->
					      {_, Node} = MapRec,
					      Node =:= SNode			      
			      end,
			Filt = lists:filter(Fun, Maps),
			MakeNode = lists:map(fun({MapId,X})-> 
										%% NodeStr = atom_to_list(X) ++"@" ++ Host,
										%% Node = list_to_atom(NodeStr),
										%% {MapId,Node}
										{MapId,MapNodeName}
								 end, Filt),
			{true, MakeNode};
		false ->
			get_map2(T, LineName, {SNode,Host,MapNodeName})
	end;
%% This line is empyt line, does not contain map
get_map2([], _LineName, _MapNodeName) ->
	{false}.

%% --------------------------------------------------------------------
%% Description: regist information into LineServer
%% Args: regist infromation
%% --------------------------------------------------------------------
%% @spec do_regist(atom(), atom()) -> void().
do_regist(regist_mapprocessor, Args, State) ->
	{NodeName, LineId, MapId, MapName} = Args,
	Key = make_map_id(LineId, MapId),
	%% {key, nodename, mapname, lineid, mapid, rolecount}
	%slogger:msg("regist_mapprocessor ~p ~n ",[Args]),
	ets:insert(?MAP_PROC_DB, {Key, NodeName, MapName, LineId, MapId}),
	ok.

do_regist(RegistType, Args) ->
	%% unkonwn format
	{LineId, MapId} = RegistType,
	Id = make_map_id(LineId, MapId),
	slogger:msg("unknown regist type: ~s~n", [Id]).

unregist_by_node(NodeName)->
	AllNodeMaps = ets:match(?MAP_PROC_DB, {'$1', NodeName, '_', '_', '_'}),
	lists:foreach(fun(Key)-> ets:delete(?MAP_PROC_DB, Key) end, lists:append(AllNodeMaps)).
	

%% Description: get the map processor name by LineId and MapId
lookup_map_name(LineId, MapId) ->
	Key = make_map_id(LineId, MapId),
	case ets:lookup(?MAP_PROC_DB, Key) of
		[{_, NodeName, ProcName, _, _}]->
			{ok, {NodeName, ProcName}};
		[] ->
			{error}
	end.

%% Description: get the rold count by mapid
%% return: [{LineId, Count}, {LineId, Count}]
%% DB field: {key, nodename, mapname, lineid, mapid, rolecount}
%%           {'_', '_',      '_',     '_',    mapid, '$1'}).
get_role_count_by_map(MapId) ->
	case ets:match(?MAP_PROC_DB, {'_', '_', '_', '$1', MapId}) of
		[]->
			slogger:msg("get_role_count_by_map error ! MapId ~p ~n",[MapId]),
			[];
		LineIdList->
			OrgList = lists:map(fun(LineId)-> {LineId,0} end, lists:append(LineIdList)),
			MaxCount = env:get2(line_switch,open_count,200),
			DynLineList =  lists:filter(fun(Lid)-> lists:keymember(Lid, 1, OrgList) end, get(dynamic_lines)),
			Fun = 
				fun(RolePos,{CountTmp,LineInfo})->
						LineId = role_pos_db:get_role_lineid(RolePos),
						LineRoleCount = 
						if
							LineId>0->
								case lists:keyfind(LineId, 1, LineInfo) of
									false-> LineInfo;%%[{LineId,1}|LineInfo]; no this map
									{_LineId,Count}->
										lists:keyreplace(LineId, 1, LineInfo, {LineId,Count+1})
								end;
							true->
								LineInfo
						end,
						{CountTmp+1,LineRoleCount}
				end,
			{AllOnlineNum,LineRoleCountOri} = role_pos_db:foldl(Fun ,{0,OrgList}),
			RoleCountWithoutIdelDynLine =  lists:filter(fun({LineId,Count})->
									   		(Count =/= 0) or (not lists:member(LineId, DynLineList))
							   		end, LineRoleCountOri),
			LiveLine = max(length(RoleCountWithoutIdelDynLine),1),
			LonelyMaps = map_info_db:get_lonely_maps(),
			case ( (AllOnlineNum/LiveLine) >=MaxCount) and (not lists:member(MapId,LonelyMaps)) of
				true->
		   			{_,RoleCountWithNewLine} = lists:foldl(fun(DyLineId,Acc0)->
														case Acc0 of
															{true,_}-> Acc0;
															{false,RoleCountX}->
																case lists:keyfind(DyLineId, 1, RoleCountWithoutIdelDynLine) of
																		false->{true, RoleCountX ++ [{DyLineId,0}]};
																	_-> Acc0
																end
														end
												end, {false,RoleCountWithoutIdelDynLine}, DynLineList),
			   		RoleCountWithNewLine;
		   		_->
			   		RoleCountWithoutIdelDynLine
			end
	end.


%% Description: 
get_role_count_by_line_map(MapId, LineId) ->
	RoleInfo = role_pos_db:get_role_info_by_map_line(MapId, LineId),
	erlang:length(RoleInfo).

%%
%%get role num in the map (all line)
%%return [{MapId,RoleNum},.....]
%%
get_rolenum_by_mapid() ->	
	Fun = 
		fun(RolePos,TempList)->
				MapId = role_pos_db:get_role_mapid(RolePos),
				case lists:keyfind(MapId,1,TempList) of
					false-> [{MapId,1}|TempList];
					{_MapId,Count}->
						lists:keyreplace(MapId, 1, TempList, {MapId,Count+1})
				end
		end,
	role_pos_db:foldl(Fun ,[]).

make_map_id(LineId, MapId) ->
	integer_to_list(LineId) ++"_"++ integer_to_list(MapId).
