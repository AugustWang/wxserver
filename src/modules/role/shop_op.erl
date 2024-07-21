%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(shop_op).

-compile(export_all).

-include("data_struct.hrl").
-include("login_pb.hrl").
-include("common_define.hrl").
-include("map_info_struct.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shoping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 		remote shop  			NpcId=:=0

enum_shoping_item(RoleInfo, NpcID) ->
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	npc_function_frame:do_enum(Mapid,RoleInfo,NpcID,trad).

buy_item(RoleInfo, ItemClsid, Count, 0)->
	case vip_op:get_role_vip() > 0 of
		true->
			Mapid = get_mapid_from_mapinfo(get(map_info)),
			npc_function_frame:do_action_without_check(Mapid,RoleInfo,0,trad,[buy, ItemClsid, Count]);
		_->
			slogger:msg("shop_op buy_item maybe hack ,not vip call remote ~n")
	end;

buy_item(RoleInfo, ItemClsid, Count, NpcID) ->
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	npc_function_frame:do_action(Mapid,RoleInfo,NpcID,trad,[buy, ItemClsid, Count]).

sell_item(RoleInfo, 0, Slot) ->
	case vip_op:get_role_vip() > 0 of
		true->
			Mapid = get_mapid_from_mapinfo(get(map_info)),
			npc_function_frame:do_action_without_check(Mapid,RoleInfo,0,trad,[sell,Slot]);
		_->
			slogger:msg("shop_op buy_item maybe hack ,not vip call remote ~n")
	end;

sell_item(RoleInfo, NpcID, Slot) ->
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	npc_function_frame:do_action(Mapid,RoleInfo,NpcID,trad,[sell,Slot]).

repair_item(RoleInfo, 0, Slot) ->
	case vip_op:get_role_vip() > 0 of
		true->
			Mapid = get_mapid_from_mapinfo(get(map_info)),
			npc_function_frame:do_action_without_check(Mapid,RoleInfo,0,trad,[repair,Slot]);
		_->
			slogger:msg("shop_op buy_item maybe hack ,not vip call remote ~n")
	end;

repair_item(RoleInfo, NpcID, Slot) ->
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	npc_function_frame:do_action(Mapid,RoleInfo,NpcID,trad,[repair,Slot]).	
