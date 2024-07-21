%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(map_travel_op).

%%
%% Include files
%%
-compile(export_all).

-define(REGIST_CALLBACK_TIME,30000).		%%wait line_manager_start
-define(SHARE_MAP_CONNECTING_NODES,'$share_map_line_nodes$').		%%wait line_manager_start

%%wait_servers,connect_servers :[{serverid,line_node}]

init()->
	put(wait_servers,[]),
	ets:new(?SHARE_MAP_CONNECTING_NODES,[set,named_table]).

regist_server({ServerId,LineNode})->
	slogger:msg("receive regist_server ServerId ~p LineNode ~p ~n ",[ServerId,LineNode]),
	add_wait_server({ServerId,LineNode}),
	erlang:send_after(?REGIST_CALLBACK_TIME, self(),{regist_map,{ServerId,LineNode}}),
	ok.

regist_map({ServerId,LineNode})->
	AllLineMaps = lines_manager:get_line_map_in_node(node()),
	FaildRegists = 
	lists:filter(fun({LineId,MapId})-> 
		MapName = map_manager:make_map_process_name(LineId, MapId),
		lines_manager:regist_mapprocessor(LineNode,{node(), LineId, MapId, MapName})=/=ok
	end, AllLineMaps),
	case FaildRegists of
		[]->
			slogger:msg("regist_map ok  ServerId ~p LineNode ~p ~n",[ServerId,LineNode]),
  			delete_from_wait_server({ServerId,LineNode}),
			add_connect_servers({ServerId,LineNode});
		_->
			slogger:msg("regist_map error ! ServerId ~p LineNode ~p ~n",[ServerId,LineNode]),
			erlang:send_after(?REGIST_CALLBACK_TIME, self(),{regist_map,{ServerId,LineNode}})
	end.
			   
add_wait_server(ServerRef)->
	case lists:member(ServerRef, get(wait_servers)) of
		true->
			nothing;
		false->
			put(wait_servers,[ServerRef|get(wait_servers)])
	end.

delete_from_wait_server(ServerRef)->
	put(wait_servers,lists:delete(ServerRef, get(wait_servers))).

add_connect_servers(ServerRef)->
	ets:insert(?SHARE_MAP_CONNECTING_NODES,ServerRef).

delete_from_connect_servers({ServerId,_})->
	ets:delete(?SHARE_MAP_CONNECTING_NODES, ServerId).

%%call in not share_map node %% return: true/false
multicast_all_not_in_travel(Module,Fun,Args)->
	case travel_deamon_op:get_share_node() of
		[]->
			false;
		ShareNode->
			cast_server(ShareNode,?MODULE,multicast_all_in_travel,[Module,Fun,Args]),
			true
	end.

%%call in share_map node
multicast_all_in_travel(Module,Fun,Args)->
	ets:foldl(fun({_LineId,LineNode},_)->
		cast_server(LineNode,Module,Fun,Args)	  
	end ,[], ?SHARE_MAP_CONNECTING_NODES).

cast_server(Node,Module,Fun,Args)->
	try
		rpc:cast(Node, Module,Fun,Args)
	catch
		E:R->
			slogger:msg("cast_server ~p ~p  Module ~p Fun ~p ~n",[E,R,Module,Fun]),
			error
	end.

get_source_node_by_serverid(ServerId)->
	case ets:lookup(?SHARE_MAP_CONNECTING_NODES, ServerId) of
		[]->
			[];
		[{ServerId,Node}]->
			Node
	end.

get_all_server_online()->
	ets:foldl(fun({_LineId,LineNode},AccNum)->
			AccNum +
			try
				rpc:call(LineNode,role_pos_db,get_online_count,[])
			catch
				_:_->0
			end
		end,0, ?SHARE_MAP_CONNECTING_NODES).
	

