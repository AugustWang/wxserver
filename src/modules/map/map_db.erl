%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-24
%% Description: TODO: Add description to map_db
-module(map_db).

%%
%% Include files
%%
-define(MAP_DATA_ETS,map_data_ets).
%%
%% Exported Functions
%%
-export([init/0,load_map_file/2,load_map_ext_file/2]).

%%
%% API Functions
%%

init()->
	nothing.
	%%	init_ets(),
	%%	CurNode = node(),
	%%	case env:get(lines_info, []) of
	%%		[]->slogger:msg("read lines_info error,please check >>>gm.option<<< file\n");
	%%		LinesInfo->process_line_config(CurNode,LinesInfo)
	%%	end.

%%
%% Local Functions
%%
init_ets()->

	try	ets:new(?MAP_DATA_ETS, [public,set,named_table]) catch _:_-> ignor end.


process_line_config(CurNode,LinesInfo)->
	lists:foldl(fun(LineConfig,MapIds)-> 
						  {LineId,MapInfo} = LineConfig,
						  case LineId of
							  'LineDynamic'-> process_dynamic_config(CurNode,MapInfo,MapIds);
							  _-> process_static_config(CurNode,MapInfo,MapIds)
						  end
				  end,[], LinesInfo).

process_static_config(CurNode,Terms,MapIds)->
	lists:foldl(fun({MapId,Node},LoopMaps)->  
						IfLoad = (not lists:member(MapId, MapIds)) and (Node==CurNode),
						if IfLoad ->
								load_map_file(MapId,?MAP_DATA_ETS), [MapId|LoopMaps];
							true-> LoopMaps
						end	
				     end,MapIds,Terms).

process_dynamic_config(CurNode,Terms,MapIds)->
	lists:foldl(fun({MapId,Nodes},LoopMaps)->  
						IfLoad = (not lists:member(MapId, MapIds)) and lists:member(CurNode, Nodes),
						if IfLoad->
							   load_map_file(MapId,?MAP_DATA_ETS), [MapId|LoopMaps];
							true-> LoopMaps
						end	
				     end,MapIds,Terms).


load_map_file(MapId,EtsName)->
	MapFile = string:concat("../maps/map_", integer_to_list(MapId)),
	%%processe_map_file(MapFile,EtsName).
	processe_map_file_by_parse(MapFile,EtsName).

load_map_ext_file(MapId,EtsName)->
	MapFile = string:concat("../maps/map_ext_", integer_to_list(MapId)),
	%%processe_map_file(MapFile,EtsName).
	processe_map_file_by_parse(MapFile,EtsName).

processe_map_file(File,EtsName)->
	case file:consult(File) of 
		{ok,Terms}->				
					lists:foreach(fun(Term)->{X,Y,V} =Term, add_coord_to_ets(X,Y,V,EtsName) end, Terms);
		{error,Reason}-> slogger:msg("map db read file ~p error,Reason=~p\n",[File,Reason]);
		_->
			slogger:msg("processe_map_file unknown error!!!~p~n",[File])			
	end.

add_coord_to_ets(X,Y,V,EtsName)->
	case X of
		born_pos ->	ets:insert(EtsName, {born_pos,{Y,V}});
		board -> ets:insert(EtsName, {board,{Y,V}});
		safe_grid -> ets:insert(EtsName, {{sg,Y,V},1});
		_->
			case is_binary(V) of
				true->
					ets:insert(EtsName, {X,Y,V});
				_->
					nothing
			end
	end.

map_data_format([],EtsName)->
	nothing;
map_data_format(String,EtsName)->
	[Header|Tail] = String,
%%	Len = string:len(Header),
%%	SubString = string:sub_string(Header,2,Len-1),
%%	[TermHeader|TermTail] = string:tokens(SubString,","),
	case util:string_to_term(Header) of
				{ok,Term}->
					{X,Y,V} = Term,
					add_coord_to_ets(X,Y,V,EtsName);
			_->
				nothing
	end,
%%	case TermHeader of
%%		"born_pos"->
%%				case util:string_to_term(Header) of
%%					{ok,Term}->
%%						{X,Y,V} = Term,
%%						add_coord_to_ets(X,Y,V,EtsName);
%%				_->
%%					nothing
%%			end;
%%		"board"->
%%			case util:string_to_term(Header) of
%%					{ok,Term}->
%%						{X,Y,V} = Term,
%%						add_coord_to_ets(X,Y,V,EtsName);
%%				_->
%%					nothing
%%			end;
%%		"safe_grid"->
%%			case util:string_to_term(Header) of
%%					{ok,Term}->
%%						{X,Y,V} = Term,
%%						add_coord_to_ets(X,Y,V,EtsName);
%%				_->
%%					nothing
%%			end;
%%		StringX->
%%			[StringY|[StringCanMove]] = TermTail,
%%			{X,_} = string:to_integer(StringX),
%%			{Y,_} = string:to_integer(StringY),
%%			{CanMove,_} = string:to_integer(StringCanMove),
%%			add_coord_to_ets(X,Y,CanMove,EtsName)
%%	end,
	map_data_format(Tail,EtsName).

processe_map_file_by_parse(File,EtsName)->
	Now1 = now(),
	case file:read_file(File) of
		{ok,BinData}->
			Now2 = now(),
			String = string:tokens(binary_to_list(BinData),".\n"),
			map_data_format(String,EtsName);
		Reason->
			slogger:msg("load map file File ~p ~p ~n",[File,Reason])
	end.
			

	
