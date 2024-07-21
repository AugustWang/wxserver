%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(object_update).
-compile(export_all).
-export([send_pending_update/0,make_update_attr/3,make_create_data/1,make_create_data/2,make_delete_data/1,make_delete_data/2]).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("map_def.hrl").
-include("common_define.hrl").
-include("creature_define.hrl").
-include("item_struct.hrl").
-include("pet_struct.hrl").
-define(MAX_CREATE_NUM,20).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		自己和别人的属性变化相关
%%		object_create_info:[{Id,Type,Attrs}]
%%		object_update_info:[{Id,Type,Attrs}]
%%		object_delete_info:[Id,Type]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
send_pending_update()->
	GateProc = get_proc_from_gs_system_gateinfo(get(gate_info)),
	tcp_client:send_pending_object_update(GateProc).

make_update_attr(Type,Id,Attrs)->
	pb_util:to_object_attribute(Id,Type,lists:map(fun(Attr)-> role_attr:to_role_attribute(Attr) end,Attrs)).

make_create_data(CreatureInfo)->
	case creature_op:what_creature(creature_op:get_id_from_creature_info(CreatureInfo)) of
		npc->
			make_create_data(?UPDATETYPE_NPC,CreatureInfo);
		role->
			make_create_data(?UPDATETYPE_ROLE,CreatureInfo);
		pet->	
			make_create_data(?UPDATETYPE_PET,CreatureInfo)
	end.
	
make_create_data(?UPDATETYPE_SELF,RoleInfo)->
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	RoleAttrs = build_self_attr_data(RoleInfo),
	pb_util:to_object_attribute(RoleId,?UPDATETYPE_SELF,lists:map(fun(Attr)-> role_attr:to_role_attribute(Attr) end,RoleAttrs));
	
make_create_data(?UPDATETYPE_ROLE,RoleInfo)->
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	RoleAttrs = build_create_role_attr_data(RoleInfo),
	RoleData = pb_util:to_object_attribute(RoleId,?UPDATETYPE_ROLE,lists:map(fun(Attr)-> role_attr:to_role_attribute(Attr) end,RoleAttrs)),
	%%如果带宠物,发送宠物
	case get_pet_id_from_roleinfo(RoleInfo) of
		0->
			RoleData;
		PetId->	
			case pet_manager:get_pet_info(PetId)of
				undefined->
					RoleData;
				PetInfo->	
					[RoleData,make_create_data(?UPDATETYPE_PET,PetInfo)]
			end
	end;

make_create_data(?UPDATETYPE_NPC,NpcInfo)->
	NpcId = creature_op:get_id_from_creature_info(NpcInfo),
	NpcAttrs = build_create_npc_attr_data(NpcInfo),
	pb_util:to_object_attribute(NpcId,?UPDATETYPE_NPC,lists:map(fun(Attr)-> role_attr:to_role_attribute(Attr) end,NpcAttrs));
	
make_create_data(?UPDATETYPE_PET,GmPetInfo)->
	PetId = get_id_from_petinfo(GmPetInfo),	
	PetAttrs = build_create_pet_attr_data(GmPetInfo),
	pb_util:to_object_attribute(PetId,?UPDATETYPE_PET,lists:map(fun(Attr)-> role_attr:to_role_attribute(Attr) end,PetAttrs)).
	
make_delete_data(CreatureId)->
	case creature_op:what_creature(CreatureId) of
		npc->
			make_delete_data(?UPDATETYPE_NPC,CreatureId);
		role->
			make_delete_data(?UPDATETYPE_ROLE,CreatureId);
		pet->	
			make_delete_data(?UPDATETYPE_PET,CreatureId)
	end.
	
%%宠物的delete由客户端关联role删除
make_delete_data(Type,Id)->
	pb_util:to_object_attribute(Id,Type,[]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%				local
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
build_create_pet_attr_data(GmPetInfo)->
	Master= get_master_from_petinfo(GmPetInfo),
	ProtoId  = get_proto_from_petinfo(GmPetInfo),
	{PosX,PosY} = get_pos_from_petinfo(GmPetInfo),
	Name = get_name_from_petinfo(GmPetInfo),
	OtherLevel = get_level_from_petinfo(GmPetInfo),
	%Mp = get_mana_from_petinfo(GmPetInfo),
	%MpMax = get_mpmax_from_petinfo(GmPetInfo),
	Hp=get_hp_value_from_pet_info(GmPetInfo),
	Quality = get_quality_from_petinfo(GmPetInfo),
	Path = get_path_from_petinfo(GmPetInfo),
	Icons = get_icon_from_pet_info(GmPetInfo),
	Pathx = lists:map(fun(Coord)-> {PosXTmp,_} = pb_util:convert_to_pos(Coord), PosXTmp end,Path),
	Pathy = lists:map(fun(Coord)-> {_,PosYTmp} = pb_util:convert_to_pos(Coord), PosYTmp end,Path),
	[	
	{pet_master,Master},
	{name,Name},
	{posx,PosX},
	{posy,PosY},
	{templateid, ProtoId},
	{level, OtherLevel},
	{hp,Hp},
	{pet_quality,Quality},
	{path_x,Pathx},
	{path_y,Pathy},
	{icon,Icons}
	].

build_self_attr_data(RoleInfo)->
	ClassID = get_class_from_roleinfo(RoleInfo),
	Level = get_level_from_roleinfo(RoleInfo),
	Expr = get_exp_from_roleinfo(RoleInfo),
	Hp = get_life_from_roleinfo(RoleInfo),
	Mp = get_mana_from_roleinfo(RoleInfo),
	Name = get_name_from_roleinfo(RoleInfo),
	Power = get_power_from_roleinfo(RoleInfo),
	{PackSize,StorageSize} = package_op:get_size(),
	{PkModle,_} = get_pkmodel_from_roleinfo(RoleInfo),
	Icons = get_icon_from_roleinfo(RoleInfo),
	SpiritsPower = spiritspower_op:get_value(),
	MaxSpiritsPower = spiritspower_op:get_maxvalue(),
   	[
   	{name,Name},
	{level, Level},
	{class, ClassID},
	{expr, Expr},
	{hp, Hp},
	{mp, Mp},
	{icon,Icons},
	{gender,get_gender_from_roleinfo(RoleInfo)},
	{state,get_state_from_roleinfo(RoleInfo)},
	{power, Power},
	{hprecover, get_hprecover_from_roleinfo(RoleInfo)},
	{criticaldestroyrate,get_criticaldamage_from_roleinfo(RoleInfo)},
	{mprecover, get_mprecover_from_roleinfo(RoleInfo)},
	{movespeed, get_speed_from_roleinfo(RoleInfo)},
	{meleeimmunity,erlang:element(3,get_immunes_from_roleinfo(RoleInfo))},
	{rangeimmunity,erlang:element(2,get_immunes_from_roleinfo(RoleInfo))},
	{magicimmunity,erlang:element(1,get_immunes_from_roleinfo(RoleInfo))},
	{hpmax, get_hpmax_from_roleinfo(RoleInfo)},
	{mpmax, get_mpmax_from_roleinfo(RoleInfo)},
	{stamina, get_stamina_from_roleinfo(RoleInfo)},
	{strength, get_strength_from_roleinfo(RoleInfo)},
	{intelligence, get_intelligence_from_roleinfo(RoleInfo)},
	{agile, get_agile_from_roleinfo(RoleInfo)},
	{meleedefense, erlang:element(3,get_defenses_from_roleinfo(RoleInfo))},
	{rangedefense, erlang:element(2,get_defenses_from_roleinfo(RoleInfo))},
	{magicdefense, erlang:element(1,get_defenses_from_roleinfo(RoleInfo))},
	{hitrate, get_hitrate_from_roleinfo(RoleInfo)},
	{dodge, get_dodge_from_roleinfo(RoleInfo)},
	{criticalrate, get_criticalrate_from_roleinfo(RoleInfo)},
	{toughness, get_toughness_from_roleinfo(RoleInfo)},
	{imprisonment_resist,erlang:element(1,get_debuffimmunes_from_roleinfo(RoleInfo))},
	{silence_resist,erlang:element(2,get_debuffimmunes_from_roleinfo(RoleInfo))},
	{daze_resist,erlang:element(3,get_debuffimmunes_from_roleinfo(RoleInfo))},
	{poison_resist,erlang:element(4,get_debuffimmunes_from_roleinfo(RoleInfo))},
	{normal_resist,erlang:element(5,get_debuffimmunes_from_roleinfo(RoleInfo))},
	{packsize,PackSize},
	{storagesize,StorageSize},
	{levelupexpr,get_levelupexp_from_roleinfo(RoleInfo)},
	{silver,get_silver_from_roleinfo(RoleInfo)}, 
	{boundsilver,get_boundsilver_from_roleinfo(RoleInfo)}, 
	{gold, get_gold_from_roleinfo(RoleInfo)},
	{ticket, get_ticket_from_roleinfo(RoleInfo)},				
	{cloth,get_cloth_from_roleinfo(RoleInfo)},
	{arm,get_arm_from_roleinfo(RoleInfo)},
	{guildname,get_guildname_from_roleinfo(RoleInfo)},
	{guildposting,get_guildposting_from_roleinfo(RoleInfo)},
	{pkmodel,PkModle},				
	{crime,get_crime_from_roleinfo(RoleInfo)},
	{view,get_view_from_roleinfo(RoleInfo)},
	{soulpower,role_soulpower:get_cursoulpower()},
	{maxsoulpower,role_soulpower:get_maxsoulpower()},
	{viptag,get_viptag_from_roleinfo(RoleInfo)},
	{faction,get_camp_from_roleinfo(RoleInfo)},
	{serverid,get_serverid_from_roleinfo(RoleInfo)},
	{ride_display,get_ride_display_from_roleinfo(RoleInfo)},
	{companion_role,get_companion_role_from_roleinfo(RoleInfo)},
	{treasure_transport,get_treasure_transport_from_roleinfo(RoleInfo)},
	{cur_designation,get_cur_designation_from_roleinfo(RoleInfo)},
	{fighting_force,get_fighting_force_from_roleinfo(RoleInfo)},
	{spiritspower,SpiritsPower},
	{maxspiritspower,MaxSpiritsPower},
	{guildtype,get_guildtype_from_roleinfo(RoleInfo)}
	].

build_create_role_attr_data(RoleInfo)->
	case creature_op:get_state_from_creature_info(RoleInfo) of
		deading->
			CreatureState = deading;
		State->
			case block_training_op:is_other_training(RoleInfo) of
				true->
					CreatureState = block_training;
				_->
					CreatureState = State
			end
	end,
	{PkModel,_} = get_pkmodel_from_roleinfo(RoleInfo),
	Icons = get_icon_from_roleinfo(RoleInfo),
	[
	{creature_flag,?CREATURE_ROLE},
	{guildname,get_guildname_from_roleinfo(RoleInfo)},
	{guildposting,get_guildposting_from_roleinfo(RoleInfo)},
	{cloth,get_cloth_from_roleinfo(RoleInfo)},
	{arm,get_arm_from_roleinfo(RoleInfo)},
	{class,get_class_from_roleinfo(RoleInfo)},
	{gender,get_gender_from_roleinfo(RoleInfo)},
	{pkmodel,PkModel},
	{crime,get_crime_from_roleinfo(RoleInfo)},
	{state,CreatureState},
	{view,get_view_from_roleinfo(RoleInfo)},
	{viptag,get_viptag_from_roleinfo(RoleInfo)},
	{faction,get_camp_from_roleinfo(RoleInfo)},
	{serverid,get_serverid_from_roleinfo(RoleInfo)},
	{icon,Icons},
	{ride_display,get_ride_display_from_roleinfo(RoleInfo)},
	{cur_designation,get_cur_designation_from_roleinfo(RoleInfo)},
	{companion_role,get_companion_role_from_roleinfo(RoleInfo)},
	{treasure_transport,get_treasure_transport_from_roleinfo(RoleInfo)},
	{fighting_force,get_fighting_force_from_roleinfo(RoleInfo)},
	{guildtype,get_guildtype_from_roleinfo(RoleInfo)}
	]++
	build_create_base_creature_data(RoleInfo).


build_create_npc_attr_data(RoleInfo)->
	Npcflag = get_npcflags_from_npcinfo(RoleInfo),
	Touchred = get_touchred_from_npcinfo(RoleInfo),
	ProtoId = get_templateid_from_npcinfo(RoleInfo),
	CreatureState = creature_op:get_state_from_creature_info(RoleInfo),
	[
		{creature_flag, Npcflag},
		{touchred, Touchred},
		{templateid, ProtoId},
		{state,CreatureState}
	] ++ build_create_base_creature_data(RoleInfo).
	
build_create_base_creature_data(RoleInfo)->
	OtherLife = creature_op:get_life_from_creature_info(RoleInfo),
	OtherFullLife = creature_op:get_hpmax_from_creature_info(RoleInfo),
	OtherLevel = creature_op:get_level_from_creature_info(RoleInfo),
	OtherSpeed = creature_op:get_speed_from_creature_info(RoleInfo),
	OtherName = creature_op:get_name_from_creature_info(RoleInfo),
	{PosX,PosY} = creature_op:get_pos_from_creature_info(RoleInfo),
	Mp = creature_op:get_mana_from_creature_info(RoleInfo),
	MpMax = creature_op:get_mpmax_from_creature_info(RoleInfo),
	CreatureBuffers = creature_op:get_buffer_from_creature_info(RoleInfo),
	Displayid = creature_op:get_displayid_from_creature_info(RoleInfo),
	Buffers = lists:map(fun({BufferId,_Level})->BufferId end,CreatureBuffers),
	BuffersLevel = lists:map(fun({_,BuffLevel})->BuffLevel end,CreatureBuffers),
	Path = creature_op:get_path_from_creature_info(RoleInfo),
	Pathx = lists:map(fun(Coord)-> {PosXTmp,_} = pb_util:convert_to_pos(Coord), PosXTmp end,Path),
	Pathy = lists:map(fun(Coord)-> {_,PosYTmp} = pb_util:convert_to_pos(Coord), PosYTmp end,Path),
	[
		{hp, OtherLife},
		{hpmax, OtherFullLife},
		{mp, Mp},
		{mpmax, MpMax},
		{level, OtherLevel},
		{displayid, Displayid},
		{movespeed, OtherSpeed},
		{name,OtherName},
		{posx,PosX},
		{posy,PosY},
		{buffer,Buffers},
		{buff_level,BuffersLevel},
		{path_x, Pathx},
		{path_y, Pathy}
	].
		
		