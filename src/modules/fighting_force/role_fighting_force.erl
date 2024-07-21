%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-15
%% Description: TODO: Add description to role_fighting_force
-module(role_fighting_force).

%%
%% Include files
%%
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("fighting_force_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
hook_on_change_role_fight_force()->
	BaseAttr = role_op:get_role_base_attr(),
	OtherAttr = role_op:get_role_other_attr(),
	{CurrentAttributes,_CurrentBuffers, _ChangeAttribute} 
	= compute_buffers:compute(get(classid), get(level), get(current_attribute), [], [], [],BaseAttr,[],OtherAttr,[]),
	Hpmax = attribute:get_current(CurrentAttributes,hpmax),
	Power = attribute:get_current(CurrentAttributes,power),
	Meleedefense = attribute:get_current(CurrentAttributes,meleedefense),
	Rangedefense = attribute:get_current(CurrentAttributes,rangedefense),
	Magicdefense = attribute:get_current(CurrentAttributes,magicdefense),
	Hitrate = attribute:get_current(CurrentAttributes,hitrate),
	Dodge = attribute:get_current(CurrentAttributes,dodge),
	Criticalrate = attribute:get_current(CurrentAttributes,criticalrate),
	CriDerate = attribute:get_current(CurrentAttributes,criticaldestroyrate),
	Meleeimmunity = attribute:get_current(CurrentAttributes,meleeimmunity),
	Rangeimmunity = attribute:get_current(CurrentAttributes,rangeimmunity),
	Magicimmunity = attribute:get_current(CurrentAttributes,magicimmunity),
	Toughness = attribute:get_current(CurrentAttributes,toughness),
	Fighting_force = computter_fight_force(Hpmax,Power,Meleedefense,Rangedefense,Magicdefense,Hitrate,Dodge,Criticalrate,
					  CriDerate,Toughness,Meleeimmunity,Rangeimmunity,Magicimmunity),
	NewRoleInfo = set_fighting_force_to_roleinfo(get(creature_info),Fighting_force),
	put(creature_info,NewRoleInfo),
	role_op:update_role_info(get(roleid),NewRoleInfo),
	role_op:only_self_update([{fighting_force,Fighting_force}]),
	guild_op:hook_on_change_fightforce(Fighting_force),
	Fighting_force.

computter_fight_force(Hpmax,Power,Meleedefense,Rangedefense,Magicdefense,Hitrate,Dodge,Criticalrate,
					  CriDerate,Toughness,Meleeimmunity,Rangeimmunity,Magicimmunity)->	
	trunc(Hpmax*?FIGHT_FORCE_HP
	+ Power*?FIGHT_FORCE_POWER 
	+ (Meleedefense+Rangedefense+Magicdefense)*?FIGHT_FORCE_DEFINSES
	+ (Hitrate-900)*?FIGHT_FORCE_HITRATE
	+ Dodge*?FIGHT_FORCE_DODGE
	+ (Criticalrate-50)*?FIGHT_FORCE_CRITICALRATE
	+ (CriDerate-500)*?FIGHT_FORCE_CRITICALDAMA
	+ Toughness*?FIGHT_FORCE_TOUGHNESS
	+ (Meleeimmunity+Rangeimmunity+Magicimmunity)*?FIGHT_FORCE_IMMUNITY).
	
	
