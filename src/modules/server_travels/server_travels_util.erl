%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(server_travels_util).

-compile(export_all).

-include("common_define.hrl").

is_share_server()->
	env:get(share_map_server,0)=:=1.

is_has_share_map()->
	env:get(share_map_node,[])=/=[].

is_share_maps(MapId)->
	lists:member(MapId,env:get(share_maps,[])).

is_share_map_node(MapNode)->
	lists:member(MapNode,get_share_map_nodes()).
	
ping_share_map_nodes()->
	nothing.

get_share_map_nodes()->
	lists:map(fun({MapNode,_})->MapNode end ,env:get(share_map_node,[]) ).

get_serverid_by_roleid(RoleId)->
	trunc(RoleId / ?SERVER_MAX_ROLE_NUMBER).
	
%%do in every server
cast_for_all_server(Module,Function,Args)->
	case is_share_server() of
		true->
			map_travel_op:multicast_all_in_travel(Module,Function,Args);
		_->	
			case map_travel_op:multicast_all_not_in_travel(Module,Function,Args) of
				false->
					erlang:apply(Module, Function, Args);
				_->
					nothing
			end	
	end.

%%do in self only and do in every server if is share node 
cast_for_all_server_with_self_if_share_node(Module,Function,Args)->
	erlang:apply(Module, Function, Args),
	case is_share_server() of
		true->
			map_travel_op:multicast_all_in_travel(Module,Function,Args);
		_->
			nothing
	end.

send_msg_to_all_server(Msg)->
	cast_for_all_server(role_pos_util,send_to_all_online_clinet,[Msg]).

%%apply in share_node.if not,apply self
do_in_share_node_if_has_travel(Module,Function,Args)->
	case server_travels_util:is_share_server() of
		true->			%%is share_node
			erlang:apply(Module, Function, Args);
		_->	
			case server_travels_util:is_has_share_map() of
				false->			%%if not has share_node,apply		
					erlang:apply(Module, Function, Args);
				_->
					nothing
			end
	end.

do_in_not_share_node(Module,Function,Args)->
	case server_travels_util:is_share_server() of
		true->			%%is share_node
			nothing;
		_->
			erlang:apply(Module, Function, Args)
	end.