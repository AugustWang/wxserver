%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-10-23
%% Description: TODO: Add description to node_util
-module(node_util).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).
-compile(export_all).
%%
%% API Functions
%%

get_appnodes(AppType)->
	env:get2(nodes, AppType,[]).

get_all_nodes()->
	[node()| nodes()]++nodes(hidden).

get_nodes_without_hidden()->
	[node()| nodes()].

get_all_nodes_for_global()->
	case server_travels_util:is_share_server() of
		false->
			get_all_nodes();
		_->		%%global not reg not self node!
			lists:filter(fun(Node)-> node_util:is_share_server_node(Node) end, get_all_nodes())
	end.

check_snode_match(AppType,SNode)->
	SNodeStr = atom_to_list(SNode),
	lists:foldl(fun(Node,Acc)->
						AppNodeStr = atom_to_list(Node),
						case Acc of
							true-> true;
							_-> Index = string:str(SNodeStr, AppNodeStr),
								if Index>= 1 -> true;
								   true-> false
								end
						end
				end, false, get_appnodes(AppType)).
	
%	lists:member(get_node_sname(SNode), get_appnodes(AppType)).

is_share_server_node(SNode)->
	SNodeStr = get_match_snode_str(SNode),
	list_util:is_part_of("share",SNodeStr).

get_match_snode(AppType,SNode)->
	SNodeStr = get_match_snode_str(SNode),
	Ret = lists:foldl(fun(Node,Acc)->
						AppNodeStr = atom_to_list(Node),
						{_,TempRe} = Acc,
						case TempRe of
							true-> Acc;
							_-> 
								AppNodeStrLen = string:len(AppNodeStr),
								SNodeStrLen = string:len(SNodeStr),
								if
									AppNodeStrLen > SNodeStrLen->
										Acc;
									true->
										NewStr = string:substr(SNodeStr,SNodeStrLen-AppNodeStrLen+1), 
										if
											NewStr =:= AppNodeStr ->
												{Node,true};
											true->
												Acc
										end
								end
						end
				end, {SNode,false}, get_appnodes(AppType)),
	{MatchNode,_} = Ret,
	MatchNode.

get_gatenodes()->
	lists:filter(fun(Node)->
						 check_snode_match(gate,Node)
				 end, get_all_nodes()).	


get_mapnodes()->
	lists:filter(fun(Node)->
						 check_snode_match(map,Node)
				 end, get_all_nodes()).

check_match_map_and_line(MapNode,LineId)->
	MapStr = "map"++erlang:integer_to_list(LineId),
	SNodeStr = get_match_snode_str(MapNode),
	string:str(SNodeStr, MapStr) > 0.

get_linenodes()->
	lists:filter(fun(Node)->
						 check_snode_match(line,Node)
				 end, get_all_nodes()).	

get_dbnodes()->
	lists:filter(fun(Node)->
						 check_snode_match(db,Node)
				 end, get_all_nodes()).	

get_guilnodes()->
	lists:filter(fun(Node)->
						 check_snode_match(guild,Node)
				 end, get_all_nodes()).	


get_authnodes()->
	lists:filter(fun(Node)->
						 check_snode_match(auth,Node)
				 end, get_all_nodes()).	

get_gmnodes()->
	lists:filter(fun(Node)->
						 check_snode_match(gm,Node)
				 end, get_all_nodes()).	
get_chatnodes()->
	lists:filter(fun(Node)->
						 check_snode_match(chat,Node)
				 end, get_all_nodes()).	
	
get_timernodes()->
	lists:filter(fun(Node)->
						 check_snode_match(timer,Node)
				 end, get_all_nodes()).	

get_crossnodes()->
	lists:filter(fun(Node)->
						 check_snode_match(cross,Node)
				 end, get_all_nodes()).	

get_crossnode()->
	case get_crossnodes() of
		[]-> undefined;
		[Node|_]-> Node
	end.

get_dbnode()->
	global_node:get_global_proc_node(db_node).
%%	case get_dbnodes() of
%%		[]-> undefined;
%%		[Node|_]-> Node
%%	end.

get_gmnode()->
	global_node:get_global_proc_node(gm_node).
%%	case get_gmnodes() of
%%		[]-> undefined;
%%		[Node|_]-> Node
%%	end.

get_mapnode() ->
	case get_mapnodes() of
		[] -> undefined;
		[Node|_] -> Node
	end.

get_timernode()->
	case get_timernodes() of
		[]-> undefined;
		[Node|_]-> Node
	end.
	
get_node_sname(Node)->
	StrNode = atom_to_list(Node),
	case string:tokens(StrNode, "@") of
		[NodeName,_Host]-> list_to_atom(NodeName);
		_-> undefined
	end.
get_node_sname_str(Node)->
	StrNode = atom_to_list(Node),
	case string:tokens(StrNode, "@") of
		[NodeName,_Host]-> NodeName;
		_-> []
	end.
get_node_host(Node)->
	StrNode = atom_to_list(Node),
	case string:tokens(StrNode, "@") of
		[_NodeName,Host]-> Host;
		_-> []
	end.
get_match_snode_str(Node)->
	StrNode = atom_to_list(Node),
	case string:tokens(StrNode, "@") of
		[NodeName,_Host]-> NodeName;
		[NodeName]-> NodeName;
		_->[]
	end.

get_run_apps(Node)->
	SNode = get_node_sname(Node),
	NodeInfos = env:get(nodes,[]),
	FilterApp = fun({_App,Nodes})->
				  RealSNode = get_match_snode(_App,SNode),
				  lists:member(RealSNode, Nodes)
			 end,
	Apps = lists:filter(FilterApp, NodeInfos),
	lists:map(fun({App,_})-> App end, Apps).



%%Num =< now map_nodes's number
%%please call at map node
get_low_load_node(Num)->
	%InitList = lists:map(fun(Node)->{Node,0} end, lines_manager:get_map_nodes()),
InitList = lists:map(fun(Node)->{Node,0} end,['map1@127.0.0.1']),%%ä¿®æ”¹æ¸©æ³‰æ´—æµ´åªè¿›ä¸€çº¿ã€Šæž«å°‘ã€‹
	Fun = 
	fun(RolePos,ReLists)->
		MapNode = role_pos_db:get_role_mapnode(RolePos),
		case lists:keyfind(MapNode, 1, ReLists) of
			{MapNode,NumTmp}->
				lists:keyreplace(MapNode, 1, ReLists, {MapNode,NumTmp+1});
			false->
				ReLists
		end
	end,
	ReList = lists:keysort(2, role_pos_db:foldl(Fun, InitList)),
	case Num > length(ReList) of
		true->
			{FirstList,_} = lists:split(Num,lists:append( lists:duplicate(Num, ReList))),
			lists:map(fun({Map,_})->Map end,FirstList);
		_->	
			{FirstList,_}  = lists:split(Num,ReList),
			lists:map(fun({Map,_})->Map end,FirstList)
	end.

%%
%% Local Functions
%%

