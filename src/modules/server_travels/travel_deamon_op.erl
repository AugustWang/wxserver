%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(travel_deamon_op).

-compile(export_all).

-define(CHECK_MAP_INTERVAL,10000).
-define(SHARE_MAP_NODES,'$share_map_nodes$').		

init()->
	put(connect_map_nodes,[]),
	ets:new(?SHARE_MAP_NODES,[set,named_table]),
	erlang:send_after(60000,self(), check_interval).	
	
do_check_interval()->	
	erlang:send_after(?CHECK_MAP_INTERVAL,self(), check_interval).

do_check()->
	AllShareNodes = env:get(share_map_node, []),
	CantConNodes = 
	lists:filter(fun({MapNode,Cookie})->
		erlang:set_cookie(node(), Cookie),				 
	  	net_adm:ping(MapNode) =/= pong		
	end,AllShareNodes),
	ConnNodes = AllShareNodes -- CantConNodes,
	case lists:filter(fun(NodeTmp)-> lists:keymember(NodeTmp, 1, CantConNodes) end,get(connect_map_nodes)) of
		[]->
			nothing;
		LostConNodes->
			delete_connect_nodes(LostConNodes)
	end,
	lists:foreach(fun({NewNode,_})-> 
		case lists:member(NewNode, get(connect_map_nodes) ) of
			false->			%%new node
				erlang:monitor_node(NewNode, true),
				slogger:msg("travel_deamon_op connect share_map NewNode ~p ~n",[NewNode]),
				case node_util:check_snode_match(line, node()) of
					true->
						ServerId = env:get(serverid, undefined),
						slogger:msg("travel_deamon_op connect apply_regist_server Server ~p ~n",[{ServerId,node()}]),
						case map_travel:apply_regist_server(NewNode,{ServerId,node()}) of
							ok->
								put(connect_map_nodes,[NewNode|get(connect_map_nodes)]),
								add_share_map_node(NewNode);
							_->
								nothing
						end;
					_->
						put(connect_map_nodes,[NewNode|get(connect_map_nodes)]),
						add_share_map_node(NewNode)
				end;
			_->
				nothing
		end
	end, ConnNodes),
	erlang:set_cookie(node(),env:get(cookie,undefined)),
	do_check_interval().

add_share_map_node(MapNode)->
	ets:insert(?SHARE_MAP_NODES,{MapNode}).

delete_connect_nodes(LostConNodes)->
	lists:foreach(fun(NodeTmp)->delete_from_connect_servers(NodeTmp) end, LostConNodes),
	slogger:msg("lost connect share map ~p ~n",[LostConNodes]),
	put(connect_map_nodes,get(connect_map_nodes) -- LostConNodes).

delete_from_connect_servers(MapNode)->
	case node_util:check_snode_match(line, node()) of
		true->
			lines_manager:unregist_map_by_node(MapNode);
		_->
			nothing
	end,
	ets:delete(?SHARE_MAP_NODES, MapNode).

get_share_node()->
	case ets:tab2list(?SHARE_MAP_NODES) of
		[]->
			[];
		[{Node}|_]->
			Node
	end.

