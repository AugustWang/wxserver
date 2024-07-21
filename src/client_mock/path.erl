%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-5-6
%% Description: TODO: Add description to path
-module(path).

%%
%% Include files
%%
-define(MAP_WIDTH,[{100,{3000,2800}},{200,{4000,4000}},{300,{5000,4200}},{333,{3600,5100}},{500,{3000,4500}},{600,{4200,6600}},{700,{4500,3800}},{1000,{4500,2800}},{1300,{3400,5000}},{1400,{5000,3800}}]).
%%
%% Exported Functions
%%
-export([random_pos/1,path_find/3,path_find/6,check_around_nodes/4,distance/2,make_path/4,get_around_nodes/2]).

%%
%% API Functions
%%

%随机一个（200,200）内的坐标，不管障碍点
%% random_pos(_MapId)->
%% 	Random_X = random:uniform(200),
%% 	Random_Y = random:uniform(200),
%% 	{Random_X,Random_Y}.
random_pos(MapId)->
	case lists:keyfind(MapId,1,?MAP_WIDTH) of
		false->
			random_pos(300);
		{_MapId,{Width,Height}}->
			Min=erlang:min(Width,Height),
			PointY=erlang:trunc((Min/40)-1),
			{Tx,Ty}=random_p(300,300),
			Px=(Tx-(Ty-PointY))*40/2,
			Py=(Tx+(Ty-PointY))*20/2,
			InX=(Px>0 andalso Px<Min),
			InY=(Py>0 andalso Py<Min),
			if
				InX and InY->
					{Tx,Ty};
				true->
					random_pos(MapId)
			end;
		_->
			random_pos(300)
	end.

random_p(X,Y)->
	Random_X = random:uniform(X),
	Random_Y = random:uniform(Y),
	{Random_X,Random_Y}.

%% make random pos  
%% random_pos()-> {Random_X,Random_Y}
random_pos1(MapId)->
%% 	io:format("path:random_pos(MapId)~n"),
	MapDbName = load_map_op:make_db_name(MapId),
	case load_map_op:query_map_board(MapDbName) of
		{X,Y}->
%% 			io:format("board:X:~p,Y:~p~n",[X,Y]),
			is_can_stand_pos(X,Y,MapDbName);
		{}->
			slogger:msg("Path:not find board~n"),
			is_can_stand_pos(200,200,MapDbName);
		ERROR->
			slogger:msg("random_pos,ERROR:~p~n",[ERROR]),
			is_can_stand_pos(200,200,MapDbName)
	end. 


is_can_stand_pos(X,Y,MapDbName)->
	Random_X = random:uniform(X),
	Random_Y = random:uniform(Y),
		case load_map_op:query_map_stand(MapDbName,{Random_X,Random_Y}) of
			1 ->
				is_can_stand_pos(X,Y,MapDbName);
			_ ->
%% 				io:format("Random Pos :Random_X:~p,Random_Y:~p~n",[Random_X,Random_Y]),
				{Random_X,Random_Y}
		end.


%%
%% Local Functions
%%

distance(Begin,End)->
	{BeginX,BeginY} = Begin,
	{EndX,EndY} = End,
	Distance = ((BeginX-EndX)*(BeginX-EndX)+(BeginY-EndY)*(BeginY-EndY))*100,
	Distance.


%%
%%make the path to end pos
%%

%%
%% WaitCheckNodeList = [{point,parentpoint,f,g,h}]
%%

make_path(Path,PresentNode,HadCheckNodeList,Begin)->
	{PresentPoint,ParentPoint,_,_,_} = PresentNode,
	case PresentPoint of
		Begin->
%%			io:format("Path:~p~n",[Path]),
			Path;
		_->
			case lists:keysearch(ParentPoint, 1, HadCheckNodeList) of 
				{value,ParentNode}->
					make_path([PresentPoint|Path],ParentNode,HadCheckNodeList,Begin);
				false->
					slogger:msg("path:not find parentnode~n"),
					[]
			end
	end.
		
	
get_around_nodes(PresentNode,End)->
	{{X,Y},_,_,G,_} = PresentNode,
	 [{{X-1,Y},{X,Y},G+10+distance({X-1,Y},End),G+10,distance({X-1,Y},End)},
      {{X,Y-1},{X,Y},G+10+distance({X,Y-1},End),G+10,distance({X,Y-1},End)},
	  {{X+1,Y},{X,Y},G+10+distance({X+1,Y},End),G+10,distance({X+1,Y},End)},
	  {{X,Y+1},{X,Y},G+10+distance({X,Y+1},End),G+10,distance({X,Y+1},End)},
	  {{X-1,Y-1},{X,Y},G+14+distance({X-1,Y-1},End),G+14,distance({X-1,Y-1},End)},
	  {{X+1,Y-1},{X,Y},G+14+distance({X+1,Y-1},End),G+14,distance({X+1,Y-1},End)},
	  {{X-1,Y+1},{X,Y},G+14+distance({X-1,Y+1},End),G+14,distance({X-1,Y+1},End)},
	  {{X+1,Y+1},{X,Y},G+14+distance({X+1,Y+1},End),G+14,distance({X+1,Y+1},End)}].
 	

	


%% check around nodes if can stand or in WaitCheckNodeList or in HadCheckNodeList
check_around_nodes(WaitCheckNodeList,_HadCheckNodeList,_MapDbName,[])->	
	lists:keysort(5, WaitCheckNodeList);
	
check_around_nodes(WaitCheckNodeList,HadCheckNodeList,MapDbName,[HNode|TNodes])->
%% 	io:format("path:check_around_nodes start~n"),
	{{X,Y},_,_,G,_} = HNode,
	case load_map_op:query_map_stand(MapDbName,{X,Y}) of
		1->
%%   		io:format("the pos can not stand {~p,~p}~n",[X,Y]),
			check_around_nodes(WaitCheckNodeList,HadCheckNodeList,MapDbName,TNodes);
		_->
			case lists:keyfind({X,Y},1,WaitCheckNodeList) of
				{{X,Y},_,_,OldG,_}->
					if G>=OldG->
%% 						   io:format("the node {~p,~p} is in WaitCheckNodeList",[X,Y]),
						   check_around_nodes(WaitCheckNodeList,HadCheckNodeList,MapDbName,TNodes);
					   true->
						   NewWaitCheckNodeList = lists:keyreplace({X,Y},1,WaitCheckNodeList,HNode),
						   check_around_nodes(NewWaitCheckNodeList,HadCheckNodeList,MapDbName,TNodes)
					end;
				false->
					case lists:keyfind({X,Y},1,HadCheckNodeList) of 
						{{X,Y},_,_,_,_}->
%% 							io:format("the node {~p,~p} is in HadCheckNodeList",[X,Y]),
							check_around_nodes(WaitCheckNodeList,HadCheckNodeList,MapDbName,TNodes);
						false->
							check_around_nodes([HNode|WaitCheckNodeList],HadCheckNodeList,MapDbName,TNodes)
					end
			end
	end.

%%算出直线路线，不管障碍点
path_find(Begin, End, _MapId)->
	path_find_sub(Begin, End, []).

path_find_sub(Begin, Begin, NodeList)->
	NodeList;
path_find_sub(Begin, End, NodeList)->
	NNodeList = [Begin|NodeList],
	%%io:format("~p ~p ~p~n", [Begin, End, NodeList]),
	{StartX, StartY} = Begin,
	{EndX, EndY} = End,
	if
		StartX < EndX, StartY<EndY ->
			path_find_sub({StartX+1,StartY+1}, End, NNodeList);
		StartX<EndX, StartY==EndY->
			path_find_sub({StartX+1,StartY}, End, NNodeList);
		StartX==EndX, StartY<EndY->
			path_find_sub({StartX,StartY+1}, End, NNodeList);
		StartX==EndX, StartY==EndY->
			NodeList;
		StartX>EndX, StartY>EndY->
			path_find_sub({StartX-1,StartY-1}, End, NNodeList);
		StartX>EndX, StartY==EndY->
			path_find_sub({StartX-1,StartY}, End, NNodeList);
		StartX==EndX, StartY>EndY->
			path_find_sub({StartX,StartY-1}, End, NNodeList);
		StartX<EndX, StartY>EndY->
			path_find_sub({StartX+1,StartY-1}, End, NNodeList);
		StartX>EndX, StartY<EndY->
			path_find_sub({StartX-1,StartY+1}, End, NNodeList);
		true->
			NodeList
	end.
			

%%
%%the main code about path find
%%

path_find1(Begin,End,MapId)->
	try
		MapDbName = load_map_op:make_db_name(MapId),
%% 		io:format("path find start ~n"),
		StartNode = {Begin,{},distance(Begin,End),0,distance(Begin,End)},
		path_find(Begin,End,StartNode,[StartNode],[],MapDbName)
	catch
		E:R ->
			slogger:msg("E:~pR:~p~n",[E,R]),
			[]
	end.


path_find(Begin,End,ParentNode,[],HadCheckNodeList,MapDbName)->
%% 	slogger:msg("path_find,error,startpos is not can stand,Begin:~p,End:~p~n",[Begin,End]),
	[];

path_find(Begin,End,ParentNode,WaitCheckNodeList,HadCheckNodeList,MapDbName)->	
	[LeastCostNode|NWaitCheckNodeList] = WaitCheckNodeList,
	case LeastCostNode of
		{End,_,_,_,_}->
%% 			io:format("path:find Path:find the end point~n"),
			 make_path([],LeastCostNode,HadCheckNodeList,Begin);
		{_,_,_,_,_}->
%%  		io:format("path:find path :not find the end ~n"),
			NewHadCheckNodeList = [LeastCostNode|HadCheckNodeList],
%% 			io:format("path:path_find:NewHadCheckNodeList:~p~n",[NewHadCheckNodeList]),
			AroundNodes=get_around_nodes(ParentNode,End),
%% 			io:format("get around node aroundNode:~p~n",[AroundNodes]),
			NewWaitCheckNodeList = check_around_nodes(NWaitCheckNodeList,HadCheckNodeList,MapDbName,AroundNodes), 	
%%  			io:format("path:path_find:NewWaitCheckNodeList:~p~n",[NewWaitCheckNodeList]),		
			path_find(Begin,End,LeastCostNode,NewWaitCheckNodeList,NewHadCheckNodeList,MapDbName);
		ERROR->
			slogger:msg("path_find,error:~p~n",[ERROR]),
			[]
	end.



  

