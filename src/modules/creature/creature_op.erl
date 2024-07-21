%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : creature_op.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 27 May 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(creature_op).

-compile(export_all).

-include("data_struct.hrl").
-include("common_define.hrl").
-include("creature_define.hrl").
-include("ai_define.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("pet_struct.hrl").
-include("map_def.hrl").
-include("map_info_struct.hrl").
-include("instance_define.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 攻击: 
%%     AttackingId: 攻击发起方的Id;
%%     BeAttackedId: 被攻击方的Id;
%%     AttackingInfo: 攻击发起方的信息;
%%     Way: 使用何种方式攻击;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
point_attack(AttackingInfo, BeAttackedInfo, Skill) ->
	AttackMod = skill_op:get_attack_module(Skill),
	case AttackMod of
		undefined ->
			nothing;
		_ ->
			AttackMod:cast(AttackingInfo, BeAttackedInfo)			
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 检查点攻击技能是否合法
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
point_attack_check(AttackingInfo, BeAttackedInfo, Skill) ->
	AttackMod = skill_op:get_attack_module(Skill),
	case AttackMod of
		undefined ->
			nothing;
		_ ->
			AttackMod:check(AttackingInfo, BeAttackedInfo)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 生物发起面攻击
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scope_attack(AttackingInfo, Skill, CastPos, MapInfo) ->
	AttackMod = skill_op:get_attack_module(Skill),
	case AttackMod of
		undefined ->
			nothing;
		_ ->
			AttackMod:cast(AttackingInfo, CastPos, MapInfo)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 检查群体攻击是否合法
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scope_attack_check(AttackingInfo, CastPos, Skill, MapInfo) ->
	AttackMod = skill_op:get_attack_module(Skill),
	case AttackMod of
		undefined ->
			false;
		_ ->
			AttackMod:check(AttackingInfo, CastPos, MapInfo)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 根据指定Id得到生物(玩家/NPC)的信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_creature_info(Id) ->
	case what_creature(Id) of
		role ->
			role_manager:get_role_info(Id);			
		npc ->
			%% 为了接口的统一，只能把NPCInfodDB的查询封装在这里了
			npc_manager:get_npcinfo(Id);
		pet->
			pet_manager:get_pet_info(Id)				
	end.
	
get_creature_info()->	
	get(creature_info).
	
%%调用此方法必须共享表:role_pos_db	
get_remote_role_info(RoleId)->	
	case role_pos_util:where_is_role(RoleId) of
		[]->
			undefined;
		RolePos->
			OtherNode = role_pos_db:get_role_mapnode(RolePos),
			role_manager:get_role_remoteinfo_by_node(OtherNode,RoleId)
	end.
				
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 从生物信息中获得ID
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_id_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_id_from_roleinfo(CreatureInfo);
get_id_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_id_from_npcinfo(CreatureInfo);
get_id_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	get_id_from_petinfo(CreatureInfo);	
get_id_from_creature_info(CreatureInfo) ->
	undefined.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 从生物信息中获取Pos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_faction_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	0;
get_faction_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_faction_from_npcinfo(CreatureInfo);
get_faction_from_creature_info(_) ->
	undefined.

get_pos_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_pos_from_roleinfo(CreatureInfo);
get_pos_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_pos_from_npcinfo(CreatureInfo);
get_pos_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	get_pos_from_petinfo(CreatureInfo);	
get_pos_from_creature_info(CreatureInfo) ->
	undefined.


set_pos_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_pos_to_roleinfo(CreatureInfo,Value);
set_pos_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_pos_to_npcinfo(CreatureInfo,Value);
set_pos_to_creature_info(CreatureInfo,Value)->
	set_pos_to_petinfo(CreatureInfo,Value).	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 从生物信息中获取等级信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_level_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_level_from_roleinfo(CreatureInfo);
get_level_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_level_from_npcinfo(CreatureInfo);
get_level_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	get_level_from_petinfo(CreatureInfo);	
get_level_from_creature_info(CreatureInfo) ->
	undefined.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 从生物信息中提取Path信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_path_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_path_from_roleinfo(CreatureInfo);
get_path_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_path_from_npcinfo(CreatureInfo);
get_path_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	get_path_from_petinfo(CreatureInfo);	
get_path_from_creature_info(CreatureInfo) ->
	undefined.

set_path_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_path_to_roleinfo(CreatureInfo,Value);
set_path_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_path_to_npcinfo(CreatureInfo,Value);
set_path_to_creature_info(CreatureInfo,Value)->
	set_path_to_petinfo(CreatureInfo,Value).		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 判断两个点是否在指定的距离之内
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
is_in_aoi(Pos1, Pos2) when (Pos1 == undefined) or (Pos2 == undefined)->
	false;
is_in_aoi(Pos1, Pos2) ->
	%%single_screen:check_in_aoi(Pos1, Pos2).
	util:is_in_range(Pos1, Pos2,?CREATURE_VIEW_RANGE).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 得到区域内生物列表
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_creatures_from_squard_up(Grid, MapProc, SelfId) ->
	lists:delete(SelfId,mapop:get_roles_from_squared_up(MapProc, Grid)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 从生物信息中获取PID
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_pid_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_pid_from_roleinfo(CreatureInfo);
get_pid_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_pid_from_npcinfo(CreatureInfo);
get_pid_from_creature_info(CreatureInfo) ->
	undefined.

get_displayid_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_displayid_from_roleinfo(CreatureInfo);
get_displayid_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_displayid_from_npcinfo(CreatureInfo);
get_displayid_from_creature_info(CreatureInfo)  when is_record(CreatureInfo, gm_pet_info) ->
	undefined.


set_displayid_to_creature_info(CreatureInfo,Displayid) when is_record(CreatureInfo, gm_role_info) ->
	set_displayid_to_roleinfo(CreatureInfo,Displayid);
set_displayid_to_creature_info(CreatureInfo,Displayid) when is_record(CreatureInfo, gm_npc_info) ->
	set_displayid_to_npcinfo(CreatureInfo,Displayid);
set_displayid_to_creature_info(CreatureInfo,Displayid) ->
	undefined.	

%%基本属性获取
get_speed_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_speed_from_roleinfo(CreatureInfo);
get_speed_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_speed_from_npcinfo(CreatureInfo);
get_speed_from_creature_info(CreatureInfo) ->
	undefined.
	
set_speed_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_speed_to_roleinfo(CreatureInfo,Value);
set_speed_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_speed_to_npcinfo(CreatureInfo,Value);
set_speed_to_creature_info(CreatureInfo,Value) ->
	undefined.	
	
get_buffer_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_buffer_from_roleinfo(CreatureInfo);
get_buffer_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_buffer_from_npcinfo(CreatureInfo);
get_buffer_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	[];	
get_buffer_from_creature_info(CreatureInfo) ->
	undefined.

get_extra_state_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_extra_state_from_roleinfo(CreatureInfo);
get_extra_state_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_extra_state_from_npcinfo(CreatureInfo);	
get_extra_state_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	[].
	
remove_extra_state_from_creature_info(CreatureInfo,Type) when is_record(CreatureInfo, gm_role_info) ->
	remove_extra_state_to_roleinfo(CreatureInfo,Type);
remove_extra_state_from_creature_info(CreatureInfo,Type) when is_record(CreatureInfo, gm_npc_info) ->	
	remove_extra_state_to_npcinfo(CreatureInfo,Type);
remove_extra_state_from_creature_info(CreatureInfo,Type)->
	CreatureInfo.

add_extra_state_to_creature_info(CreatureInfo,Type) when is_record(CreatureInfo, gm_role_info) ->
	add_extra_state_to_roleinfo(CreatureInfo,Type);
add_extra_state_to_creature_info(CreatureInfo,Type) when is_record(CreatureInfo, gm_npc_info) ->
	add_extra_state_to_npcinfo(CreatureInfo,Type);
add_extra_state_to_creature_info(CreatureInfo,Type)->
	CreatureInfo.		

get_name_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_name_from_roleinfo(CreatureInfo);
get_name_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_name_from_npcinfo(CreatureInfo);
get_name_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	get_name_from_petinfo(CreatureInfo);	
get_name_from_creature_info(CreatureInfo) ->
	undefined.
	
get_hatredratio_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_hatredratio_from_roleinfo(CreatureInfo);
get_hatredratio_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_hatredratio_from_npcinfo(CreatureInfo);
get_hatredratio_from_creature_info(CreatureInfo) ->
	undefined.	
	
set_hatredratio_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_hatredratio_to_roleinfo(CreatureInfo,Value);
set_hatredratio_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_hatredratio_to_npcinfo(CreatureInfo,Value);
set_hatredratio_to_creature_info(CreatureInfo,Value)->
	CreatureInfo.		
	

get_life_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_life_from_roleinfo(CreatureInfo);
get_life_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_life_from_npcinfo(CreatureInfo);
get_life_from_creature_info(CreatureInfo) ->
	undefined.

set_life_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_life_to_roleinfo(CreatureInfo,Value);
set_life_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_life_to_npcinfo(CreatureInfo,Value);
set_life_to_creature_info(CreatureInfo,Value) ->
	undefined.

get_hpmax_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_hpmax_from_roleinfo(CreatureInfo);
get_hpmax_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_hpmax_from_npcinfo(CreatureInfo);
get_hpmax_from_creature_info(CreatureInfo) ->
	undefined.
	
set_hpmax_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_hpmax_to_roleinfo(CreatureInfo,Value);
set_hpmax_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_hpmax_to_npcinfo(CreatureInfo,Value);
set_hpmax_to_creature_info(CreatureInfo,Value) ->
	undefined.

get_mana_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_mana_from_roleinfo(CreatureInfo);
get_mana_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_mana_from_npcinfo(CreatureInfo);
%get_mana_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	%get_mana_from_petinfo(CreatureInfo);	
get_mana_from_creature_info(CreatureInfo) ->
	undefined.

set_mana_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_mana_to_roleinfo(CreatureInfo,Value);
set_mana_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_mana_to_npcinfo(CreatureInfo,Value);
set_mana_to_creature_info(CreatureInfo,Value) ->
	undefined.
	
get_mpmax_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_mpmax_from_roleinfo(CreatureInfo);
get_mpmax_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_mpmax_from_npcinfo(CreatureInfo);
%get_mpmax_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	%get_mpmax_from_petinfo(CreatureInfo);	
get_mpmax_from_creature_info(CreatureInfo) ->
	undefined.
	
set_mpmax_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_mpmax_to_roleinfo(CreatureInfo,Value);
set_mpmax_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_mpmax_to_npcinfo(CreatureInfo,Value);
set_mpmax_to_creature_info(CreatureInfo,Value) ->
	undefined.
	

get_npcflags_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	?CREATURE_ROLE;
get_npcflags_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->	
	get_npcflags_from_npcinfo(CreatureInfo);
get_npcflags_from_creature_info(CreatureInfo) ->	
	?CREATURE_PET.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 战斗属性
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_class_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_class_from_roleinfo(CreatureInfo);
get_class_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_class_from_npcinfo(CreatureInfo);
get_class_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	get_class_from_petinfo(CreatureInfo);
get_class_from_creature_info(CreatureInfo) ->
	undefined.
	
get_power_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_power_from_roleinfo(CreatureInfo);
get_power_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_power_from_npcinfo(CreatureInfo);
get_power_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	get_meleepower_value_from_pet_info(CreatureInfo);
get_power_from_creature_info(CreatureInfo) ->
	undefined.
	
set_power_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_power_to_roleinfo(CreatureInfo,Value);
set_power_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_power_to_npcinfo(CreatureInfo,Value);
set_power_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_pet_info) ->
	set_meleepower_to_petinfo(CreatureInfo,Value);
set_power_to_creature_info(CreatureInfo,Value) ->
	undefined.	
	
get_commoncool_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_commoncool_from_roleinfo(CreatureInfo);
get_commoncool_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_commoncool_from_npcinfo(CreatureInfo);
get_commoncool_from_creature_info(CreatureInfo) ->
	undefined.

get_immunes_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_immunes_from_roleinfo(CreatureInfo);
get_immunes_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_immunes_from_npcinfo(CreatureInfo);
get_immunes_from_creature_info(CreatureInfo) ->
	undefined.	
	
set_immunes_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_immunes_to_roleinfo(CreatureInfo,Value);
set_immunes_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_immunes_to_npcinfo(CreatureInfo,Value);
set_immunes_to_creature_info(CreatureInfo,Value) ->
	undefined.		

get_hitrate_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_hitrate_from_roleinfo(CreatureInfo);
get_hitrate_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_hitrate_from_npcinfo(CreatureInfo);
get_hitrate_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	get_hitrate_from_petinfo(CreatureInfo);
get_hitrate_from_creature_info(CreatureInfo) ->
	undefined.	
	
set_hitrate_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_hitrate_to_roleinfo(CreatureInfo,Value);
set_hitrate_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_hitrate_to_npcinfo(CreatureInfo,Value);
set_hitrate_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_pet_info) ->
	set_hitrate_to_petinfo(CreatureInfo,Value);
set_hitrate_to_creature_info(CreatureInfo,Value) ->
	undefined.			
	
get_dodge_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_dodge_from_roleinfo(CreatureInfo);
get_dodge_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_dodge_from_npcinfo(CreatureInfo);
get_dodge_from_creature_info(CreatureInfo) ->
	undefined.
		
set_dodge_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_dodge_to_roleinfo(CreatureInfo,Value);
set_dodge_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_dodge_to_npcinfo(CreatureInfo,Value);
set_dodge_to_creature_info(CreatureInfo,Value) ->
	undefined.			
	

get_criticalrate_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_criticalrate_from_roleinfo(CreatureInfo);
get_criticalrate_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_criticalrate_from_npcinfo(CreatureInfo);
get_criticalrate_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	get_criticalrate_from_petinfo(CreatureInfo);
get_criticalrate_from_creature_info(CreatureInfo) ->
	undefined.	

set_criticalrate_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_criticalrate_to_roleinfo(CreatureInfo,Value);
set_criticalrate_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_criticalrate_to_npcinfo(CreatureInfo,Value);
set_criticalrate_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_pet_info) ->
	set_criticalrate_to_petinfo(CreatureInfo,Value);
set_criticalrate_to_creature_info(CreatureInfo,Value) ->
	undefined.		

get_toughness_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_toughness_from_roleinfo(CreatureInfo);
get_toughness_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_toughness_from_npcinfo(CreatureInfo);
get_toughness_from_creature_info(CreatureInfo) ->
	undefined.	

set_toughness_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_toughness_to_roleinfo(CreatureInfo,Value);
set_toughness_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_toughness_to_npcinfo(CreatureInfo,Value);
set_toughness_to_creature_info(CreatureInfo,Value) ->
	undefined.		

get_criticaldamage_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_criticaldamage_from_roleinfo(CreatureInfo);
get_criticaldamage_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_criticaldamage_from_npcinfo(CreatureInfo);
get_criticaldamage_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_pet_info) ->
	get_criticaldamage_from_petinfo(CreatureInfo);
get_criticaldamage_from_creature_info(CreatureInfo) ->
	undefined.		
	
set_criticaldamage_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_criticaldamage_to_roleinfo(CreatureInfo,Value);
set_criticaldamage_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_criticaldamage_to_npcinfo(CreatureInfo,Value);
set_criticaldamage_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_pet_info) ->
	set_criticaldamage_to_petinfo(CreatureInfo,Value);
set_criticaldamage_to_creature_info(CreatureInfo,Value) ->
	undefined.		

get_debuffimmunes_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_debuffimmunes_from_roleinfo(CreatureInfo);
get_debuffimmunes_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_debuffimmunes_from_npcinfo(CreatureInfo);
get_debuffimmunes_from_creature_info(CreatureInfo) ->
	undefined.
	
set_debuffimmunes_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_debuffimmunes_to_roleinfo(CreatureInfo,Value);
set_debuffimmunes_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_debuffimmunes_to_npcinfo(CreatureInfo,Value);
set_debuffimmunes_to_creature_info(CreatureInfo,Value) ->
	undefined.		
	
get_defenses_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_defenses_from_roleinfo(CreatureInfo);
get_defenses_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	get_defenses_from_npcinfo(CreatureInfo);
get_defenses_from_creature_info(CreatureInfo) ->
	undefined.	
	
set_defenses_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_role_info) ->
	set_defenses_to_roleinfo(CreatureInfo,Value);
set_defenses_to_creature_info(CreatureInfo,Value) when is_record(CreatureInfo, gm_npc_info) ->
	set_defenses_to_npcinfo(CreatureInfo,Value);
set_defenses_to_creature_info(CreatureInfo,Value) ->
	undefined.
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 被攻击
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_state_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	get_state_from_roleinfo(CreatureInfo);
get_state_from_creature_info(CreatureInfo) when is_record(CreatureInfo, gm_npc_info)  ->
	get_state_from_npcinfo(CreatureInfo);
get_state_from_creature_info(CreatureInfo) ->
	undefined.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 判断是那一类Creature
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
what_creature(Id) ->
	if 
		(Id >= ?MIN_ROLE_ID) and (Id < ?MIN_PET_ID) ->
			role;
		Id < ?MIN_ROLE_ID->
			npc;
		true->
			pet
	end.

update_creature_info(NewCreatureInfo)->
	Id = get_id_from_creature_info(NewCreatureInfo),
	case what_creature(Id) of
		role->
			role_op:update_role_info(Id,NewCreatureInfo);
		npc->
			npc_op:update_npc_info(Id,NewCreatureInfo);
		_->
			nothing
	end.	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 生物要加入地图
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
join(CreatureInfo, MapInfo) ->
	put(is_in_world,true),
 	SelfId = get_id_from_creature_info(CreatureInfo),
 	SelfPos = get_pos_from_creature_info(CreatureInfo),
 	put(range_update_pos,SelfPos),
 	MapProcName = get_proc_from_mapinfo(MapInfo),
 	Grid = mapop:convert_to_grid_index(SelfPos, ?GRID_WIDTH),
 	MyType = what_creature(SelfId),	
	if 
		MyType =:= role->
			mapop:update_grids_state(MapProcName, Grid,0);
		true->
			nothing
	end, 	
  	OtherCreatureId = mapop:join_grid(SelfId, Grid, MapProcName),
  	CreateObj = object_update:make_create_data(get(creature_info)),
	lists:foreach(fun(CreatureId)->				
					if
						CreatureId =:= SelfId->
							nothing;
						true->
							OtherInfo = get_creature_info(CreatureId),
							case is_has_relation(CreatureInfo,OtherInfo) of
								true->
			  						OtherPos = get_pos_from_creature_info(OtherInfo),
									case is_in_aoi(SelfPos, OtherPos) of
			  				    			true->		  				    				
			  				    				into_view_notify_other(OtherInfo,CreatureInfo,CreateObj);
			  				    			false->
			  				    				nothing
			  				  		end;
			  				  	_->
			  				  		nothing
			  				end	
		  			end end,OtherCreatureId).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 玩家离开地图的消息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
leave_map(CreatureInfo, MapInfo) ->	
	case get(is_in_world) of 
		true->
			put(is_in_world,false),
			MapProcName = get_proc_from_mapinfo(MapInfo),
			RolePos = get_pos_from_creature_info(CreatureInfo),
			SelfId = get_id_from_creature_info(CreatureInfo),
			Grid = mapop:convert_to_grid_index(RolePos, ?GRID_WIDTH),	
			mapop:leave_grid(SelfId, MapProcName, Grid),	
			case what_creature(SelfId) of
				role->
					mapop:update_grids_state(MapProcName, 0,Grid);
				npc->
					nothing
			end,
			clear_aoi_and_notify(CreatureInfo);
		_->
			nothing
	end.	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 获取九宫格内的玩家信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_creatures_info_from_squard_up(Grid, MapProc, SelfId) ->
	lists:map(fun(Id) ->
				  get_creature_info(Id)
		  end, get_creatures_from_squard_up(Grid, MapProc, SelfId)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 通知Others该玩家移动
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_notify_other(OtherInfo, SelfInfo, Path)->
	SelfId = creature_op:get_id_from_creature_info(SelfInfo),
	Time = util:now_to_ms(timer_center:get_time_of_day()),
	Pos = creature_op:get_pos_from_creature_info(SelfInfo),
	Message = role_packet:encode_other_role_move_s2c(SelfId,Time,Pos, Path),	
	role_op:send_to_other_client_roleinfo(OtherInfo,Message).

move_notify_aoi_roles(SelfInfo,Pos,Path,Time)->
	SelfId = creature_op:get_id_from_creature_info(SelfInfo),
	Message = role_packet:encode_other_role_move_s2c(SelfId,Time, Pos, Path),
	lists:foreach(fun({OtherId,_})->
			case what_creature(OtherId) of
				role ->
					case get_creature_info(OtherId) of
						undefined ->
							remove_from_aoi_list(OtherId);
						OtherInfo->	
							role_op:send_to_other_client_roleinfo(OtherInfo,Message)							
					end;
				_->
					nothing
			end
		end,get(aoi_list)).		

move_notify_aoi_roles(SelfInfo, Path) ->		%%10.19 zhaoyan	
	Time = util:now_to_ms(timer_center:get_time_of_day()),
	Pos = creature_op:get_pos_from_creature_info(SelfInfo),
	move_notify_aoi_roles(SelfInfo,Pos,Path,Time).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 移动
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
move_update(RoleInfo, MapInfo, Pos,Grid) ->
	MapProcName = get_proc_from_mapinfo(MapInfo),
	SelfId = get_id_from_creature_info(RoleInfo),
	CreateObj = object_update:make_create_data(get(creature_info)),
	AllCreatures = creature_op:get_creatures_from_squard_up(Grid, MapProcName, SelfId),			
	lists:foreach(fun(OtherId)->
				OtherInfo =get_creature_info(OtherId),
				OtherPos = creature_op:get_pos_from_creature_info(OtherInfo),
				case creature_op:is_in_aoi(OtherPos, Pos) of
					true->											%%在视野里
						case is_in_aoi_list(OtherId) of 			
							false->					
								case is_has_relation(RoleInfo,OtherInfo) of
									true->		
							       		into_view_notify_other(OtherInfo,RoleInfo,CreateObj);
							       	_->
							       		nothing
							    end;	
						    true->									
						    	nothing
						end;
					false->											%%未在视野里
						case is_in_aoi_list(OtherId) of 			
							true->									%%在aoi列表里,通知删除生物	    	   
								outof_view_notify_other(OtherInfo,RoleInfo);
							false->
								nothing
						end
				end
			end,AllCreatures).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 移动心跳逻辑
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
move_heartbeat(OriRoleInfo, MapInfo, Coord) ->
	Path = creature_op:get_path_from_creature_info(OriRoleInfo),
	Pos = pb_util:convert_to_pos(Coord),
	RemainPath = list_util:trunk(Path, Coord),
	SelfId = creature_op:get_id_from_creature_info(OriRoleInfo),	
	SelfType = what_creature(SelfId),
	Old_pos = creature_op:get_pos_from_creature_info(OriRoleInfo),									
	%% 设置新位置
	NewCreatureInfo = set_pos_to_creature_info(set_path_to_creature_info(OriRoleInfo,RemainPath),Pos),
	put(creature_info,NewCreatureInfo),
	update_creature_info(NewCreatureInfo),
	MapProcName = get_proc_from_mapinfo(MapInfo),
	Old_Grid = mapop:convert_to_grid_index(Old_pos, ?GRID_WIDTH),					
	New_grid = mapop:convert_to_grid_index(Pos, ?GRID_WIDTH),							
	LastUpdatePos = get(range_update_pos),
	case util:is_in_range(LastUpdatePos,Pos,?MOVE_UPDATE_RANGE) of
		false->							
			move_update(NewCreatureInfo, MapInfo, Pos,New_grid),
			put(range_update_pos,Pos);
		true->
			nothing
	end,
	if
		New_grid =/= Old_Grid->							
			%%% 切换不同的网格
			mapop:leave_grid(SelfId, MapProcName, Old_Grid),
			mapop:join_grid(SelfId, New_grid, MapProcName),
			if
				SelfType =:= role->		%%玩家更新区域
					mapop:update_grids_state(MapProcName, New_grid,Old_Grid);
				true->		
					case mapop:is_grid_active(MapProcName,New_grid) of
						false->		%%Npc走到了未激活的区域
							self() ! {hibernate};
						true->
							nothing
					end																			
			end;					
		true ->
			if
				SelfType =:= npc->	
					%%如果是npc,判断此格是否是激活状态,如果不是,hibernate
					case mapop:is_grid_active(MapProcName,New_grid) of
						false->		%%休眠
							self() ! {hibernate};
						true->
							nothing
					end;	
					true->
						nothing
			end						
	end,				
	case  RemainPath of
		[] ->
			%% 切换状态, 并返回下一个状态
			gaming;
		_ ->
			%% 切换状态, 并返回下一个状态
			{moving, RemainPath}
	end.	
		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%							进出视野的通知begin								  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

into_view_notify_other(OtherInfo, SelfInfo,SelfCreate) ->
	SelfId = creature_op:get_id_from_creature_info(SelfInfo),	 
	OtherId =  creature_op:get_id_from_creature_info(OtherInfo),
	if
		OtherId =/= SelfId -> 
			OtherPid = creature_op:get_pid_from_creature_info(OtherInfo),
			gs_rpc:cast(OtherPid,{other_into_view, SelfId}),
			change_aoi_other_into_view(OtherInfo),
			OtherCreate = object_update:make_create_data(OtherInfo),
			%%通知对方我的结构
			into_view_notify_other_client(OtherInfo,SelfCreate),
			%%通知自己对方的结构
			into_view_notify_other_client(SelfInfo,OtherCreate);
		true->
			slogger:msg("into_view_notify_other has self! SelfId  ~p~n",[SelfId])
	end.		     

into_view_notify_other_client(OtherInfo,SelfCreate)->
	case what_creature(creature_op:get_id_from_creature_info(OtherInfo)) of
		role->
			GatePid = get_proc_from_gs_system_gateinfo(get_gateinfo_from_roleinfo(OtherInfo)),
			tcp_client:object_update_create(GatePid,SelfCreate);
		_->
			nothing
	end.
	
%%处理别人进入视野的other_into_view	
handle_other_into_view(OtherInfo)->
	change_aoi_other_into_view(OtherInfo).
	
%%物体进入视野时修改aoi
change_aoi_other_into_view(OtherInfo) ->
	OtherId = creature_op:get_id_from_creature_info(OtherInfo),
	OtherPid = creature_op:get_pid_from_creature_info(OtherInfo),
	creature_op:insert_into_aoi_list({OtherId, OtherPid}).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 通知Others该玩家离开了他的视野
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear_aoi_and_notify(RoleInfo) ->
	SelfId = creature_op:get_id_from_creature_info(RoleInfo),
	lists:foreach(fun({OtherId,OtherPid})->
				case what_creature(SelfId) of
					role->	%%玩家要通知清除aoi
						role_op:other_outof_view(OtherId);
					_->
						npc_op:other_outof_view(OtherId)
				end,	
				gs_rpc:cast(OtherPid,{other_outof_view, get_id_from_creature_info(RoleInfo)})
			end,get(aoi_list)),
	put(aoi_list,[]).
			
%%try catch			
outof_view_notify_other(OtherInfo, RoleInfo) ->
	%% 通知其他玩家
	SelfId = creature_op:get_id_from_creature_info(RoleInfo),
	SelfType = what_creature(SelfId),
	OtherId = creature_op:get_id_from_creature_info(OtherInfo),
	OtherPid = creature_op:get_pid_from_creature_info(OtherInfo),
	gs_rpc:cast(OtherPid,{other_outof_view, SelfId}),
	if
		SelfType =:= npc->				%%npc 需要根据不同的状态做不同的事情,所以需要给自己发送,交给状态机去做
			self() ! {other_outof_view, OtherId};
		true->	
			role_op:other_outof_view(OtherId)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%							进出视野的通知end								  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

is_in_aoi_list(RoleId) ->
	lists:keymember(RoleId, 1, get(aoi_list)).

insert_into_aoi_list({RoleId, Info}) ->
	case is_in_aoi_list(RoleId) of
		true ->
			nothing;
		false ->
			put(aoi_list, lists:append(get(aoi_list),[{RoleId, Info}]))
	end.

remove_from_aoi_list(RoleId) ->	
	put(aoi_list, lists:keydelete(RoleId, 1, get(aoi_list))).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%							aoi的操作										  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
get_aoi_role()->
	lists:filter(fun({Id,_})-> what_creature(Id)=:=role end,get(aoi_list)).		

%%返回以Range为半径内,与SelfInfo关系为Realation的,活着的生物.
%%返回：距离由近到远的目标列表
get_nearest_from_aoi_by_radius(SelfInfo,Realation,Range)->
	Pos = creature_op:get_pos_from_creature_info(SelfInfo),
	CreatureIdsAndDistance =
	lists:foldl(fun({ID,_},AccCreatureIds)->
			case creature_op:get_creature_info(ID) of
					undefined ->		%%aoi列表出问题了,清楚该aoi玩家,记录
						remove_from_aoi_list(ID),
						AccCreatureIds;
					OtherInfo ->
						BaseCheck =  (not creature_op:is_creature_dead(OtherInfo)) and
									 (what_realation(SelfInfo,OtherInfo) =:= Realation) and
									 (util:is_in_range(Pos,creature_op:get_pos_from_creature_info(OtherInfo),Range)),
						if
							BaseCheck->
								Distansepow = npc_ai:get_distance_pow(Pos,creature_op:get_pos_from_creature_info(OtherInfo)),
								AccCreatureIds++[{ID,Distansepow}];
							true->
								AccCreatureIds
					end     
			end
	end,[],get(aoi_list)),
	lists:map(fun({IDTmp,PosTmp})-> IDTmp end,lists:keysort(2, CreatureIdsAndDistance)). 
	
get_aoi_info_by_realation(SelfInfo,Realation)->		
	lists:foldl(fun({ID,_},InfoList)->
				case creature_op:get_creature_info(ID) of
						undefined ->		%%aoi列表出问题了,清楚该aoi玩家,记录
							remove_from_aoi_list(ID),
							slogger:msg("get_aoi_info_by_realation undefined ID ~p~n", [ID]),
							InfoList;
						OtherInfo ->
							case what_realation(SelfInfo,OtherInfo) =:= Realation of
								true->
									[OtherInfo|InfoList];
								_->			
									InfoList
							end
				end
		end,[],get(aoi_list)).

get_nearest_role_from_aoi()->
	Pos = creature_op:get_pos_from_creature_info(get(creature_info)),
	{NearestId,_}=
	lists:foldl(fun({ID,_},{LastId,LastDistance})->
		case what_creature(ID) of
			role-> 
				case creature_op:get_creature_info(ID) of
						undefined ->		%%aoi列表出问题了,清楚该aoi玩家,记录
							remove_from_aoi_list(ID),
							{LastId,LastDistance};
						OtherInfo ->
							Distansepow = npc_ai:get_distance_pow(Pos,creature_op:get_pos_from_creature_info(OtherInfo)),
						    if
						    	Distansepow < LastDistance-> 
								    {ID,Distansepow};
							    true -> 
								    {LastId,LastDistance}
						    end
				end;
			_->
				{LastId,LastDistance}
		end
	end,{0,?DEFAULT_MAX_DISTANCE},get(aoi_list)),
	NearestId.
		
get_aoi_role_info()->
	AoiList = get(aoi_list),
	lists:foldl(fun({ID,_},InfoList)->
				case creature_op:get_creature_info(ID) of
						undefined ->		%%aoi列表出问题了,清楚该aoi玩家,记录
							remove_from_aoi_list(ID),
							slogger:msg("get_aoi_role_info undefined ID ~p~n", [ID]),
							InfoList;
						OtherInfo ->
							case creature_op:what_creature(ID) of
								role->
									[OtherInfo|InfoList];
								npc->
									InfoList
							end
				end
		end,[],AoiList).


%%
%%获取以角色为中心 以Radius为半径的圆范围内的所有玩家
%%
get_aoi_role_by_radius(Radius)->
	AoiList = get(aoi_list),
	Center = get_pos_from_roleinfo(get(creature_info)),
	lists:foldl(fun({ID,_},InfoList)->
				case creature_op:get_creature_info(ID) of
						undefined ->		
							remove_from_aoi_list(ID),
							slogger:msg("get_aoi_role_by_radius undefined ID ~p~n", [ID]),
							InfoList;
						OtherInfo ->
							case creature_op:what_creature(ID) of
								role->
									OtherPos = creature_op:get_pos_from_creature_info(OtherInfo),
									case util:is_in_range(Center, OtherPos, Radius) of
										true->
											[ID|InfoList];
										_->
											InfoList
									end;
								npc->
									InfoList
							end
				end
		end,[],AoiList).		
		
get_aoi_grouped_role_groupid()->
	lists:foldl(fun({Id,_},AccTmp)-> 
			case what_creature(Id)=:=role of
				true->
					case creature_op:get_creature_info(Id) of
						undefined ->		
							remove_from_aoi_list(Id),
							slogger:msg("get_aoi_role_groupid undefined ID ~p~n", [Id]),
							AccTmp;
						RoleInfo->
							GroupId = get_group_id_from_roleinfo(RoleInfo),
							if
								GroupId=/=0->
									[{Id,get_group_id_from_roleinfo(RoleInfo)}|AccTmp];
								true->
									AccTmp
							end	
					end;
				_->	
					AccTmp
			end
		end,[],get(aoi_list)).		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%							aoi的操作end										  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		

%%在玩家或怪物当前地图召唤出怪物!!!!如果存在,直接复活,如果不存在,则创建
call_creature_spawn(NpcId,CreatorTag)->
	call_creature_spawn_with_pos(NpcId,[],CreatorTag).

call_creature_spawns(NpcIds,CreatorTag)->
	lists:foreach(fun(NpcId)-> call_creature_spawn_with_pos(NpcId,[],CreatorTag) end,NpcIds). 

call_creature_spawns_with_pos(NpcIds,Pos,CreatorTag)->
	lists:foreach(fun(NpcId)-> call_creature_spawn_with_pos(NpcId,Pos,CreatorTag) end,NpcIds).

%%按位置召唤怪物,召唤在调用者当前地图
call_creature_spawn_with_pos(NpcId,Pos,CreatorTag)->	
	case npc_db:get_creature_spawns_info_by_id(NpcId) of
		[]->	
			slogger:msg("load_npc_to_map NpcId ~p ~n",[NpcId]);
		NpcSpawnInfo->	
			MapProcName = get_proc_from_mapinfo(get(map_info)),
			LineId = get_lineid_from_mapinfo(get(map_info)),
			MapId = get_mapid_from_mapinfo(get(map_info)),
			if
				Pos=/=[]->
					NpcInfo = npc_db:set_spawn_bornposition( npc_db:set_spawn_mapid(NpcSpawnInfo,MapId),Pos);
				true->
					NpcInfo =npc_db:set_spawn_mapid(NpcSpawnInfo,MapId)
			end, 	
			load_npc_to_map(MapProcName,LineId,MapId,NpcInfo,CreatorTag)
	end.

%%按线召唤怪物,召唤不可在副本.调用必须处于同一节点
call_creature_spawn(LineId,NpcId,CreatorTag)->
	case npc_db:get_creature_spawns_info_by_id(NpcId) of
		[]->	
			slogger:msg("load_npc_to_map NpcId ~p ~n",[NpcId]);
		NpcSpawnInfo->	
			MapId = npc_db:get_spawn_mapid(NpcSpawnInfo),
			MapProcName = map_manager:make_map_process_name(LineId,MapId),
			NpcInfo = npc_db:set_spawn_mapid(NpcSpawnInfo,MapId),
			load_npc_to_map(MapProcName,LineId,MapId,NpcInfo,CreatorTag)
	end.
	
%%按mapproc召唤怪物
call_creature_spawn_in_instance(MapProcName,MapId,NpcId,CreatorTag)->
	case npc_db:get_creature_spawns_info_by_id(NpcId) of
		[]->	
			slogger:msg("load_npc_to_map NpcId ~p ~n",[NpcId]);
		NpcSpawnInfo->	
			%%MapId = npc_db:get_spawn_mapid(NpcSpawnInfo),
			NpcInfo = npc_db:set_spawn_mapid(NpcSpawnInfo,MapId),
			load_npc_to_map(MapProcName,?INSTANCE_LINEID,MapId,NpcInfo,CreatorTag)
	end.

%%按模板动态召唤怪物 return:error/NpcId,定点怪物
call_creature_spawn_by_create(ProtoId,Bornposition,CreatorTag)->
	call_creature_spawn_by_create(ProtoId,Bornposition,?MOVE_TYPE_POINT,Bornposition,CreatorTag).
	
%%按模板动态召唤怪物 return:error/NpcId	
call_creature_spawn_by_create(ProtoId,Bornposition,Movetype,WayPoints,CreatorTag)->
	MapProcName = get_proc_from_mapinfo(get(map_info)),
	LineId = get_lineid_from_mapinfo(get(map_info)),
	MapId = get_mapid_from_mapinfo(get(map_info)),	
	NpcManagerProc = npc_manager:make_npc_manager_proc(MapProcName),
	case npc_manager:gen_npc_id(NpcManagerProc) of
		0->
			error;
		Id->	
			NpcInfo = npc_db:create_npc_spawn_info(Id,ProtoId,MapId,Bornposition,Movetype,WayPoints),
			case load_npc_to_map(MapProcName,LineId,MapId,NpcInfo,CreatorTag) of
				error->
					error;
				_->
					Id
			end	
	end.
	
call_creature_spawn_by_create(ProtoId,Bornposition,MapProcName,LineId,MapId,CreatorTag)->
	NpcManagerProc = npc_manager:make_npc_manager_proc(MapProcName),
	case npc_manager:gen_npc_id(NpcManagerProc) of
		0->
			error;
		Id->	
			NpcInfo = npc_db:create_npc_spawn_info(Id,ProtoId,MapId,Bornposition,?MOVE_TYPE_POINT,Bornposition),
			case load_npc_to_map(MapProcName,LineId,MapId,NpcInfo,CreatorTag) of
				error->
					error;
				_->
					Id
			end	
	end.

%%加载npc到当前地图Pos:[]->默认位置	return error/_
load_npc_to_map(MapProcName,LineId,MapId,NpcSpawnInfo,CreatorTag)->	
	NpcInfoDB = npc_op:make_npcinfo_db_name(MapProcName),
	NpcId = npc_db:get_spawn_id(NpcSpawnInfo),
	case npc_manager:get_npcinfo(NpcInfoDB,NpcId) of
		undefined ->
			NpcManagerProc = npc_manager:make_npc_manager_proc(MapProcName),
			npc_manager:add_npc_by_option(NpcManagerProc,NpcId,LineId,MapId,NpcSpawnInfo,CreatorTag);			
		NpcInfo ->			%%Npc存在,复活之
			CreaturePid = get_pid_from_npcinfo(NpcInfo),
			gen_fsm:send_event(CreaturePid,{respawn_by_call})
	end.

%%按线 卸载怪物.调用必须处于同一节点
unload_npc_by_line(LineId,NpcId)->
	case npc_db:get_creature_spawns_info_by_id(NpcId) of
		[]->
			slogger:msg("unload_npc_by_line NpcId ~p ~n",[NpcId]);
		NpcSpawnInfo->
			MapId = npc_db:get_spawn_mapid(NpcSpawnInfo),	
			MapProcName = map_manager:make_map_process_name(LineId,MapId),
			NpcInfoDB = npc_op:make_npcinfo_db_name(MapProcName),
			case npc_manager:get_npcinfo(NpcInfoDB,NpcId) of
				undefined->
					unload_npc_from_map(MapProcName,NpcId);
				NpcInfo->
					npc_processor:forced_leave_map(get_pid_from_npcinfo(NpcInfo)),
					unload_npc_from_map(MapProcName,NpcId)
			end
	end.
	
%%从当前地图卸载npc,慎重调用,必须已经不在地图内,如果不确定,不如不卸载.
unload_npc_from_map_ext(MapProc,NpcId)->
	NpcInfoDB = npc_op:make_npcinfo_db_name(MapProc),
	case npc_manager:get_npcinfo(NpcInfoDB,NpcId) of
		undefined->
			slogger:msg("unload_npc_from_map_ext error NpcId ~p  MapProc ~p~n",[NpcId,MapProc]);
		NpcInfo->
			npc_processor:forced_leave_map(get_pid_from_npcinfo(NpcInfo)),
			unload_npc_from_map(MapProc,NpcId)
	end.

%%从当前地图卸载npc,慎重调用,必须已经不在地图内,如果不确定,不如不卸载.
unload_npc_from_map(MapProc,NpcId)->
	NpcManagerProc = npc_manager:make_npc_manager_proc(MapProc),
	npc_manager:remove_npc(NpcManagerProc,NpcId).

is_has_relation(SelfInfo,OtherInfo)->
	SelfFac = get_faction_from_creature_info(SelfInfo),
	OtherFac = get_faction_from_creature_info(OtherInfo),
	if
		(SelfFac =:= 0) or (OtherFac=:=0)->
			true;
		true->
			SelfFacInfo = faction_relations_db:get_info(SelfFac),
			lists:member(OtherFac,faction_relations_db:get_friendly(SelfFacInfo)) or
			lists:member(OtherFac,faction_relations_db:get_opposite(SelfFacInfo))
	end.

%%enemy/friend/undfined	
what_realation(SelfInfo,OtherInfo)->
	SelfFac = get_faction_from_creature_info(SelfInfo),
	OtherFac = get_faction_from_creature_info(OtherInfo),
	SelfFacInfo = faction_relations_db:get_info(SelfFac),
	case lists:member(OtherFac,faction_relations_db:get_friendly(SelfFacInfo)) of
		true->
			friend;
		_->
			case lists:member(OtherFac,faction_relations_db:get_opposite(SelfFacInfo)) of
				true->
					enemy;
				_->
					undefind
			end
	end.

combat_bufflist_proc(SelfInfo,CastResult,FlyTime)->
	%%处理buff
	ImmunesInfos = 
		lists:map(fun({TargetID2, _, OriBuffList}) ->
				HitBuffList = lists:filter(fun({_,Result})->Result =/= immune end,OriBuffList),
				ImmuneBuffList = lists:filter(fun({_,Result})->Result =:= immune end,OriBuffList),
				BuffList = lists:map(fun({BuffTmp,_})-> BuffTmp end, HitBuffList),
				process_buff_list(SelfInfo, TargetID2, FlyTime, BuffList),
				{TargetID2,ImmuneBuffList}									     
		end, CastResult),
		process_buff_immune(SelfInfo,FlyTime,ImmunesInfos).				
						
%%BuffList:[{BuffId,BuffLevel}]
process_buff_list(SelfInfo, TargetID, FlyTime, BuffList) ->
	case BuffList of
		[] ->
			nothing;
		_ ->
			%% 处理给别人的BUFFER
			TargetPID = get_pid_from_creature_info(get_creature_info(TargetID)),
			CasterInfo =  {get_id_from_creature_info(SelfInfo),get_name_from_creature_info(SelfInfo)},
			erlang:send_after(FlyTime, TargetPID, {be_add_buffer, BuffList,CasterInfo})
	end.				

%%ImmunesInfos:[TargetID,ImmnueList] ImmnueList:[{{Id,Level},immnue}]				 	
process_buff_immune(SelfInfo,FlyTime,OriImmnueList)->
	ImmnueList = lists:filter(fun({_TargetId,Immnues})->Immnues=/=[] end,OriImmnueList),
	if
		ImmnueList=:=[]->
			nothing;
		true->
			SelfId = get_id_from_creature_info(SelfInfo),	  
			Msg = role_packet:encode_buff_immune_s2c(SelfId,FlyTime,ImmnueList),
			case what_creature(SelfId) of
				npc->
					npc_op:broadcast_message_to_aoi_client(Msg);
				role->	
					role_op:send_data_to_gate(Msg),
					role_op:broadcast_message_to_aoi_client(Msg)
			end
	end.
	
remove_buffers(Buffers,CreatureInfo) when is_record(CreatureInfo, gm_role_info) ->
	role_op:remove_buffers(Buffers);
remove_buffers(Buffers,CreatureInfo) when is_record(CreatureInfo, gm_npc_info) ->
	npc_op:remove_buffers(Buffers);
remove_buffers(Buffers,CreatureInfo)->
	nothing.
	
clear_all_buff_for_type(Module,Type)->	
	RemoveBuffer = buffer_op:get_cancel_buffs_by_type(Type), 
	lists:foreach(fun({BufferID,BufferLevel})->		
			Module:remove_without_compute({BufferID, BufferLevel})
		end,RemoveBuffer),
	if
		RemoveBuffer=/= []->
			Module:recompute_attr([],RemoveBuffer);
		true->
			nothing
	end.	
	
direct_broadcast_to_aoi_gate(Message)->
	lists:foreach(fun({RoleId,_})->
			case creature_op:what_creature(RoleId) of
				role-> 
					direct_send_to_gate(RoleId,Message);
				_->
					nothing
			end 
	end,get(aoi_list)).

direct_send_to_gate(RoleId,Message)->
	case creature_op:get_creature_info(RoleId) of
		undefined->
			nothing;
		RoleInfo->
			GS_GateInfo = get_gateinfo_from_roleinfo(RoleInfo),
			Gateproc = get_proc_from_gs_system_gateinfo(GS_GateInfo),					
			gs_rpc:cast(Gateproc,Message)
	end.	
	
is_creature_dead(undefined)->
	true;
is_creature_dead(CreatureInfo)->
	(get_state_from_creature_info(CreatureInfo) =:= deading).
	