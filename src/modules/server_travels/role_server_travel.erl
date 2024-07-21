%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(role_server_travel).

-compile(export_all).

-include("map_info_struct.hrl").
-include("login_pb.hrl").

init()->
	put(is_in_travel,false),
	put(source_servers_ids,env:get(serverids,[])),
	put(role_source_node,node()).

hook_on_chat_in_view()->
	todo.

hook_on_trans_map_by_node(NewMapinfo)->
	NewMapId = get_mapid_from_mapinfo(NewMapinfo),
	case server_travels_util:is_share_maps(NewMapId) of
		true ->
			on_trans_server(NewMapinfo);
		_->
			case get(is_in_travel) of
				true->
					on_back_home_from_other();
				_->
					nothing
			end
	end.

hook_on_trans_map_faild()->
	MapId = get_mapid_from_mapinfo(get(map_info)),
	LineId = get_lineid_from_mapinfo(get(map_info)), 
	Node = get_node_from_mapinfo(get(map_info)), 
	role_pos_db:update_role_line_map_node(get(roleid),LineId,MapId,Node),
	case server_travels_util:is_share_maps(MapId) of 
		true->
			change_is_in_travel(true);
		_->
			change_is_in_travel(false)
	end.

hook_on_offline()->
	case get(is_in_travel) of
		true->
			role_pos_db:unreg_role_pos_to_mnesia(get(roleid)),
			do_in_travels(role_pos_db,unreg_role_pos_to_mnesia,[get(roleid)]);
		false->
			role_pos_db:unreg_role_pos_to_mnesia(get(roleid))
	end.

on_trans_server(NewMapinfo)->
	RoleId = get(roleid),
	NewLineId = get_lineid_from_mapinfo(NewMapinfo), 
	NewMapId = get_mapid_from_mapinfo(NewMapinfo),
	NewNode = get_node_from_mapinfo(NewMapinfo),
	case get(is_in_travel) of
		false->				%%leave copy in my node
			role_pos_db:update_role_line_map_node(RoleId,NewLineId,NewMapId,NewNode);
		true->				%%join another travel ,unregist
			role_pos_db:unreg_role_pos_to_mnesia(RoleId)
	end,
	change_is_in_travel(true).		

on_back_home_from_other()->
	change_is_in_travel(false),
	role_pos_db:unreg_role_pos_to_mnesia(get(roleid)).

export_for_copy()->
	{get(is_in_travel),get(source_servers_ids),get(role_source_node)} .

load_by_copy({IsTravel,SourceSIds,SourceNode})->
	put(is_in_travel,IsTravel),
	put(source_servers_ids,SourceSIds),
	put(role_source_node,SourceNode).

is_in_travel()->
	get(is_in_travel).

get_my_source_node()->
	get(role_source_node).

is_same_source_role(RoleId)->
	lists:member(server_travels_util:get_serverid_by_roleid(RoleId), get(source_servers_ids)).

safe_do_in_travels(Module,Fun,Args)->
	case get(is_in_travel) of
		true->
			do_in_travels(Module,Fun,Args);
		_->
			apply(Module,Fun,Args)
	end.

do_in_travels(Module,Fun,Args)->
	try
		rpc:call(role_server_travel:get_my_source_node(),Module,Fun,Args)
	catch
		E:R->
			slogger:msg("safe_do_in_travels RoleId ~p ~p ~p ~n",[get(roleid),E,R]),
		[]
	end.

change_is_in_travel(Tag)->
	if
		Tag-> 
			Msg = login_pb:encode_server_travel_tag_s2c(#server_travel_tag_s2c{istravel = 1});
		true->
			Msg = login_pb:encode_server_travel_tag_s2c(#server_travel_tag_s2c{istravel = 0})
	end,
	role_op:send_data_to_gate(Msg),
	put(is_in_travel,Tag).
	