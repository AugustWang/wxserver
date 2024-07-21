%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-3-19
%% Description: TODO: Add description to skill_especially_collect
-module(skill_especially_collect).
-export([on_cast/5,on_check/2]).
%%
%% Include files
%%
-include("battle_define.hrl").
-include("common_define.hrl").
-include("data_struct.hrl").
-include("npc_struct.hrl").
-include("role_struct.hrl").
%%
%% Exported Functions
%%



%%
%% API Functions
%%

on_cast(TargetId,ManaChanged,CastResult,SkillID,SkillLevel)->
	TargetInfo = creature_op:get_creature_info(TargetId),
	case can_attack(TargetInfo) of
		true->
			%%TargetInfo = creature_op:get_creature_info(TargetId),
			if
				TargetInfo =:= undefined ->
					nothing;
				true->
					NpcPid = creature_op:get_pid_from_creature_info(TargetInfo),
					gs_rpc:cast(NpcPid,{special_attack, {get(roleid),{battle_ground_op:get_node(),battle_ground_op:get_proc()}}})
			end;
		_->
			nothing
	end,
	{[],[{TargetId,{normal,0},[]}]}.

on_check(_SkillInfo,TargetInfo)->
	can_attack(TargetInfo).

%%
%% Local Functions
%%

can_attack(TargetInfo)->
	TargetId = creature_op:get_id_from_creature_info(TargetInfo),
	case creature_op:what_creature(TargetId) of
		npc->
			NpcFaction = get_battle_state_from_npcinfo(TargetInfo),
			MyFaction = get_camp_from_roleinfo(get(creature_info)),
			if
				NpcFaction =:= MyFaction->
					false;
				NpcFaction =:= ?REDGETFROMBLUE,MyFaction =:= ?YHZQ_CAMP_RED->
					false;
				NpcFaction =:= ?BLUEGETFROMRED,MyFaction =:= ?YHZQ_CAMP_BLUE->
					false;
				true->
					true
			end;
		_->
			false
	end.
		
	
