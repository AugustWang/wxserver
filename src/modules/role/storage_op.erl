%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(storage_op).

-compile(export_all).

-include("data_struct.hrl").
-include("login_pb.hrl").
-include("common_define.hrl").
-include("map_info_struct.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Shoping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 		remote shop  			NpcId=:=0

do_enum(NpcId)->
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	if
		NpcId=:=0->
			case vip_op:get_role_vip() > 0 of
				true->
					npc_function_frame:do_action_without_check(Mapid,get(creature_info),NpcId,npc_storage_action,[enum,NpcId]);
				_->
					slogger:msg("storage_op do_enum maybe hack ,not vip call remote ~n")
			end;
		true->
			npc_function_frame:do_enum(Mapid,get(creature_info),NpcId,npc_storage_action)
	end.

do_swap_item(NpcId,SrcSlot,DesSlot)->
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	if
		NpcId=:=0->
			case vip_op:get_role_vip() > 0 of
				true->
					npc_function_frame:do_action_without_check(Mapid,get(creature_info),NpcId,npc_storage_action,[swap_item,SrcSlot,DesSlot]);
				_->
					slogger:msg("storage_op do_swap_item maybe hack ,not vip call remote ~n")
			end;
		true->
			npc_function_frame:do_action(Mapid,get(creature_info),NpcId,npc_storage_action,[swap_item,SrcSlot,DesSlot])
	end.
	
