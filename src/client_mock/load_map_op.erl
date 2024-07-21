%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-5-6
%% Description: TODO: Add description to load_map_op
-module(load_map_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([load_map_file/2,make_db_name/1,query_born_pos/1,query_map_board/1,query_map_stand/2]).

%%
%% API Functions
%%

		
string_to_term(String)->
	case erl_scan:string(String++".") of 
		{ok,Tokens,_}->
			case erl_parse:parse_term(Tokens) of
				{ok,Term}->
					{ok,Term};
				{error, ErrorInfo}->
					slogger:msg("string_to_term ~p error : ~p~n",[String,ErrorInfo]),
					parse_error
			end;
		Reason->
			slogger:msg("string_to_term ~p error: ~p~n",[String,Reason]),
			scan_error
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

					
		




map_data_format([],_EtsName)->
	nothing;
map_data_format(String,EtsName)->
	[Header|Tail] = String,
	case string_to_term(Header) of
		{ok,Term}->
			{X,Y,V} = Term,
			add_coord_to_ets(X,Y,V,EtsName);
		_->
			nothing
	end,
	map_data_format(Tail,EtsName).

		
	
	

load_map_file(MapId,EtsName)->
	nothing.
%% 	MapFile = string:concat("../maps/map_", integer_to_list(MapId)),
%% 	case file:read_file(MapFile) of 
%% 		{ok,BinData}->
%% %% 			String = string:tokens(binary_to_list(BinData),".\n"),
%% %% 			map_data_format(String,EtsName),
%% 			<<CellWidth:16, CellHeight:16, XLen:16, YLen:16, Width:16, Height:16, PointY:16, Tmp:40, StandData/binary>>=BinData,
%% 			ets:insert(EtsName, {board,{XLen,YLen}}),
%% 			ets:insert(EtsName, {data,XLen,StandData}),
%% 			erlang:garbage_collect();
%% 		{error,Reason}->
%% 			slogger:msg("map ~p read false,the reason is ~p~n",[MapFile,Reason])
%% 	end.


make_db_name(MapId)->
%% 	io:format("load_map_op:make_db_name:MapId:~p~n",[MapId]),
	list_to_atom(lists:append([integer_to_list(MapId),"_db"])).
	
query_born_pos(MapDb)->
	case ets:lookup(MapDb,born_pos) of
		{born_pos,{X,Y}}->
			{X,Y};
		{error, Reason}->
			slogger:msg("query born pos occur error,the reason is : ~p~n",[Reason])
	end.

query_map_board(MapDb)->
%% 	io:format("load_map_op:query_map_board,MapDb:~p~n",[MapDb]),
	case ets:lookup(MapDb,board) of
		[]->
			{};
		[{board,{BoardX,BoardY}}]->
			{BoardX,BoardY};
		{error,Reason}->
			slogger:msg("query borad occur error,the reason is : ~p~n",[Reason]),
			{};
		ERROR->
			slogger:msg("querry board error,ERROR:~p~n",[ERROR]),
			{}
	end.

query_map_stand(MapDb,{X,Y})->
	case ets:lookup(MapDb,data) of
		[{data,MaxX,StandBin}]->
			if 
				X>=MaxX->
					slogger:msg("exceed the board~n"),
					1;
				true->
%% 					io:format("the point {~p,~p} is in the map~n",[X,Y]),
%% 					PassX = X*8,
%% 					<<_:PassX,Stande:8,_/binary>> = StandBin,
%% %% 					io:format("load_map_op:query_map_stand StandBin is :~p~n",[Stande]),
%% 					Stande
					PassX = (Y*MaxX + X)*8,
					<<_:PassX, Stand:8, _/binary>> = StandBin,
					Stand
			end;
		{error,Reason}->
			slogger:msg("load_map_op: query_map_stand lookup is error:~p~n ",[Reason]),
			1
	end.


