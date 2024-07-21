%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-11-3
%% Description: TODO: Add description to skill_attack_throne
-module(skill_attack_throne).

-export([on_cast/5,on_check/2]).
%%
%% Include files
%%
-include("common_define.hrl").
-include("guildbattle_define.hrl").
-include("data_struct.hrl").
-include("npc_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%

%%
%% API Functions
%%
on_cast(TargetId,ManaChanged,CastResult,SkillID,SkillLevel)->
	case get(guildbattle_skillinfo) of
		{_,TargetInfo}->
			NpcPid = creature_op:get_pid_from_creature_info(TargetInfo),		
			gs_rpc:cast(NpcPid,{guildbattle_special_real_attack, {get(roleid)}});
		_->
			nothing
	end,
	put(guildbattle_skillinfo,[]),
	{[],[{TargetId,{normal,0},[]}]}.

on_check(SkillInfo,TargetInfo)->
	SkillID = skill_db:get_id(SkillInfo),
	SkillLevel = skill_db:get_level(SkillInfo),
	can_attack(SkillID,SkillLevel,SkillInfo,TargetInfo).

%%
%% Local Functions
%%

can_attack(SkillID,SkillLevel,SkillInfo,TargetInfo)->
	case guildbattle_op:is_in_fight() of
		true->
			SelfInfo = get(creature_info),
			case combat_op:is_target_in_range(SelfInfo, TargetInfo, SkillInfo) of	
				true->
					case combat_op:is_cool_time_ok(SkillID, SkillLevel) and combat_op:is_global_cooltime_ok(SelfInfo,SkillID) of	
						true->
							case ( (not combat_op:is_self_silent(SelfInfo)) or combat_op:is_normal_attack(SkillID) ) of		
								true->							
										case (not combat_op:is_self_coma(SelfInfo)) of	
											true->
												case get_battle_state_from_npcinfo(TargetInfo) of
														?THRONE_STATE_NULL->
															NpcPid = creature_op:get_pid_from_creature_info(TargetInfo),
															put(guildbattle_skillinfo,{SkillInfo,TargetInfo}),
															MyName = get_name_from_roleinfo(get(creature_info)),
															GuildId = guild_util:get_guild_id(), 
															MyClass = get_class_from_roleinfo(get(creature_info)),
															MyGenger = get_gender_from_roleinfo(get(creature_info)),
															gs_rpc:cast(NpcPid,{guildbattle_special_attack, {get(roleid),MyName,MyClass,MyGenger,GuildId}}),
															true;
														Other->
															false
												end;
											false->
												is_coma
										end;										
								_->
									is_silent
							end;														
						_->
							cooltime
					end;
				false->
					range
			end;	
		_->
			ErrnoMsg = guildbattle_packet:encode_guild_battle_opt_s2c(?ERRNO_GUILD_BATTLE_THRONE_READY_CANNOT_ATTACK),
			role_op:send_data_to_gate(ErrnoMsg),
			false
	end.
%%
%% Local Functions
%%

