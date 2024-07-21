%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-4-8
%% Description: TODO: Add description to item_sysbrd_op
-module(creature_sysbrd_util).
-compile(export_all).
%%
%% Include files
%%
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("game_map_define.hrl").
%%
%% API Functions
%%



sysbrd({loot,NpcProtoId},{ItemProtoId,Count})->
	case equipment_sysbrd_db:get_info({loot,NpcProtoId}) of
		[]->
			nothing;
		BrdInfo->
			ItemList = equipment_sysbrd_db:get_itemlist(BrdInfo),
			BrdId = equipment_sysbrd_db:get_brdid(BrdInfo),
			case lists:member(ItemProtoId,ItemList) of
				false->
					nothing;
				_->
					ParamRole = system_chat_util:make_role_param(get(creature_info)),
					ParamItem = system_chat_util:make_item_param(ItemProtoId),
					MsgInfo = [ParamRole,ParamItem],
					system_chat_op:system_broadcast(BrdId,MsgInfo)
			end
	end;

sysbrd({boss_loot,NpcProtoId,MapId},{ItemProtoId,Count})->
	case equipment_sysbrd_db:get_info({boss_loot,NpcProtoId}) of
		[]->
			nothing;
		BrdInfo->
			ItemList = equipment_sysbrd_db:get_itemlist(BrdInfo),
			BrdId = equipment_sysbrd_db:get_brdid(BrdInfo),
			case lists:member(ItemProtoId,ItemList) of
				false->
					nothing;
				_->
					ParamRole = system_chat_util:make_role_param(get(creature_info)),
					ParamItem = system_chat_util:make_item_param(ItemProtoId),
					NpcInfo = npc_db:get_proto_info_by_id(NpcProtoId),
					NpcName = npc_db:get_proto_name(NpcInfo),
					ParamNpcName = system_chat_util:make_string_param(NpcName),
					case  map_info_db:get_map_info(MapId) of
						[]->
							nothing;
						MapInfo->
							MapName = map_info_db:get_map_name(MapInfo), 
							ParamMapName = system_chat_util:make_string_param(MapName),
							MsgInfo = [ParamRole,ParamMapName,ParamNpcName,ParamItem],
							system_chat_op:system_broadcast(BrdId,MsgInfo)
					end	
			end
	end;
			
sysbrd({mail,ItemProtoId},Count)->
	case equipment_sysbrd_db:get_info({mail,ItemProtoId}) of
		[]->
			nothing;
		BrdInfo->
			BrdId = equipment_sysbrd_db:get_brdid(BrdInfo),
			ParamRole = system_chat_util:make_role_param(get(creature_info)),
			ParamItem = system_chat_util:make_item_param(ItemProtoId),
			MsgInfo = [ParamRole,ParamItem],
			system_chat_op:system_broadcast(BrdId,MsgInfo)
	end;

sysbrd({shop,ItemProtoId},Count)->
	case equipment_sysbrd_db:get_info({shop,ItemProtoId}) of
		[]->
			nothing;
		BrdInfo->
			BrdId = equipment_sysbrd_db:get_brdid(BrdInfo),
			ParamRole = system_chat_util:make_role_param(get(creature_info)),
			ParamItem = system_chat_util:make_item_param(ItemProtoId),
			MsgInfo = [ParamRole,ParamItem],
			system_chat_op:system_broadcast(BrdId,MsgInfo)
	end;

sysbrd({quest_got_item,ItemProtoId},Count)->
	case equipment_sysbrd_db:get_info({quest_got_item,ItemProtoId}) of
		[]->
			nothing;
		BrdInfo->
			BrdId = equipment_sysbrd_db:get_brdid(BrdInfo),
			ParamRole = system_chat_util:make_role_param(get(creature_info)),
			ParamItem = system_chat_util:make_item_param(ItemProtoId),
			MsgInfo = [ParamRole,ParamItem],
			system_chat_op:system_broadcast(BrdId,MsgInfo)
	end;
	
	
sysbrd({npc_exchange,ItemProtoId},Count)->
	case equipment_sysbrd_db:get_info({npc_exchange,ItemProtoId}) of
		[]->
			nothing;
		BrdInfo->
			BrdId = equipment_sysbrd_db:get_brdid(BrdInfo),
			ParamRole = system_chat_util:make_role_param(get(creature_info)),
			ParamItem = system_chat_util:make_item_param(ItemProtoId),
			MsgInfo = [ParamRole,ParamItem],
			system_chat_op:system_broadcast(BrdId,MsgInfo)
	end;

sysbrd({monster_born,IsTravel,NpcProtoId},{LineId,MapId,NpcNameTmp})->
	if
		IsTravel->
			SerchKey =  {travel_monster_born,NpcProtoId};
		true->
			SerchKey =  {monster_born,NpcProtoId}
	end,		
	case equipment_sysbrd_db:get_info(SerchKey) of
		[]->
			nothing;
		BrdInfo->	
			BrdId = equipment_sysbrd_db:get_brdid(BrdInfo),
			case  map_info_db:get_map_info(MapId) of
				[]->
					false;
				MapInfo->
					case ?CHECK_INSTANCE_MAP(map_info_db:get_is_instance(MapInfo)) of
						false->	
							MsgInfo = make_monster_born_msg(MapInfo,NpcNameTmp,LineId),
							system_chat_op:system_broadcast(BrdId,MsgInfo);
						_->
							nothing
					end
			end
	end;

sysbrd({monster_kill,IsTravel,NpcProtoId},{ParamMS,ParamRole,OtherName})->
	if
		IsTravel->
			SerchKey =  {travel_monster_kill,NpcProtoId},
			ParamString = system_chat_util:make_string_param(OtherName),
			MsgInfo = [ParamMS,ParamRole,ParamString];
		true->
			SerchKey =  {monster_kill,NpcProtoId},
			ParamString = system_chat_util:make_string_param(OtherName),
			MsgInfo = [ParamRole,ParamString]
	end,		
	case equipment_sysbrd_db:get_info(SerchKey) of
		[]->
			nothing;
		BrdInfo->	
			BrdId = equipment_sysbrd_db:get_brdid(BrdInfo),
			system_chat_op:system_broadcast(BrdId,MsgInfo)
	end;

sysbrd({treasure_chest,ItemProtoId},Count)->
	case equipment_sysbrd_db:get_info({treasure_chest,ItemProtoId}) of
		[]->
			nothing;
		BrdInfo->
			BrdId = equipment_sysbrd_db:get_brdid(BrdInfo),
			ParamRole = system_chat_util:make_role_param(get(creature_info)),
			ParamItem = system_chat_util:make_item_param(ItemProtoId),
			MsgInfo = [ParamRole,ParamItem],
			system_chat_op:system_broadcast(BrdId,MsgInfo),
			RoleName = util:safe_binary_to_list(get_name_from_roleinfo(get(creature_info))),
			Msg = treasure_chest_v2_packet:encode_treasure_chest_broad_s2c(RoleName,ItemProtoId,Count),
			chat_op:send_binary_message(Msg)
	end;

sysbrd({refine_system,ItemProtoId},Count)->
	case equipment_sysbrd_db:get_info({refine_system,ItemProtoId}) of
		[]->
			nothing;
		BrdInfo->
			BrdId = equipment_sysbrd_db:get_brdid(BrdInfo),
			ParamRole = system_chat_util:make_role_param(get(creature_info)),
			ParamItem = system_chat_util:make_item_param(ItemProtoId),
			MsgInfo = [ParamRole,ParamItem],
			system_chat_op:system_broadcast(BrdId,MsgInfo)
	end;

sysbrd({pet_explore,ItemProtoId},Count)->
	case equipment_sysbrd_db:get_info({pet_explore,ItemProtoId}) of
		[]->
			nothing;
		BrdInfo->
			BrdId = equipment_sysbrd_db:get_brdid(BrdInfo),
			ParamRole = system_chat_util:make_role_param(get(creature_info)),
			ParamItem = system_chat_util:make_item_param(ItemProtoId),
			MsgInfo = [ParamRole,ParamItem],
			system_chat_op:system_broadcast(BrdId,MsgInfo)
	end;

sysbrd(Msg,Info)->
	nothing.


%%
%% Local Functions
%%
make_monster_born_msg(MapInfo,NpcNameTmp,LineId)->
	MapNameTmp = map_info_db:get_map_name(MapInfo),
	if 
		is_binary(NpcNameTmp)->
			MyName=binary_to_list(NpcNameTmp);
		true->
			MyName = NpcNameTmp
	end,
	if 
		is_binary(MapNameTmp)->
			MapName=binary_to_list(MapNameTmp);
		true->
			MapName = MapNameTmp
	end,
	ParamNpcName = system_chat_util:make_string_param(MyName),
	ParamString = system_chat_util:make_string_param(MapName),
	ParamInt = system_chat_util:make_int_param(LineId),
	[ParamNpcName,ParamString,ParamInt].