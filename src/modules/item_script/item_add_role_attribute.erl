%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaowu
%% Created: 2013-4-26
%% Description: 因为炼制出的丹药无法使用，所以为了可以使用丹药并增加人物的各项属性我写了一个使用物品的脚本【小五】: Add description to item_add_role_attribute
-module(item_add_role_attribute).

%%
%% Exported Functions
%%
-export([use_item/1]).

%%
%% Include files
%%
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-define(ALL_ATTRIBUTE_VALUE,[{hpmax,1},{power,2},{meleedefense,3},{rangedefense,4},{magicdefense,5},{hitrate,6},{dodge,7},{criticalrate,8},{criticaldestroyrate,9},{toughness,10}]).
%%生命，攻击，近防，远防，魔防，命中，闪避，暴击，暴伤，韧性
-define(ALL_FURNACE_ADD_ATTRIBUTE_NUM,[400,300,300,300,300,200,200,200,200,200]).
-define(CLASS_POWER_TYPE,[magicpower,rangepower,meleepower]).
%%
%% API Functions
%%

%%
%% Local Functions
%%

use_item(ItemInfo)->
	[{Value,AttributeValue }] = get_states_from_iteminfo(ItemInfo),
	{_,Num} = lists:keyfind(Value, 1, ?ALL_ATTRIBUTE_VALUE),
	MaxNum = lists:nth(Num, ?ALL_FURNACE_ADD_ATTRIBUTE_NUM),
	Pill_Use_Info = get(pill_use_info),
	RoleInfo = get(creature_info),
	Role_Class = get_class_from_roleinfo(RoleInfo),
	if
		Value =:= power->
			NewValue = lists:nth(Role_Class,?CLASS_POWER_TYPE);
		true->
			NewValue = Value
	end,
	if
		Pill_Use_Info =:= []->
			New_Pill_Use_Info = [{Num,1,MaxNum,NewValue}],
			State = true;
		true->
			case lists:keyfind(NewValue, 4, Pill_Use_Info) of
				false->
					New_Pill_Use_Info = Pill_Use_Info ++ [{Num,1,MaxNum,NewValue}],
					State = true;
				{PillId,UseNum,UseMaxNum,_}->
					if
						UseNum >= UseMaxNum->
							New_Pill_Use_Info = Pill_Use_Info,
							State = false;
						true->
							NewTuple = {PillId,UseNum+1,UseMaxNum,NewValue},
							New_Pill_Use_Info = lists:keyreplace(NewValue, 4, Pill_Use_Info, NewTuple),
							State = true
					end
			end
	end,
	if
		State =:= true->
			RoleId = get(roleid),
			furnace_db:save_furnace_add_role_attribute_info(RoleId,New_Pill_Use_Info),
			put(pill_use_info,New_Pill_Use_Info),
			furnace_op:make_and_send_pills_info(RoleId,New_Pill_Use_Info),
			RoleInfo = get(creature_info),
			case Value of
				hpmax->
					Hpmax = get_hpmax_from_roleinfo(RoleInfo),
					NewHpmax = Hpmax + AttributeValue,
					NewInfo = set_hpmax_to_roleinfo(RoleInfo,NewHpmax),
					role_op:only_self_update([{hpmax,NewHpmax}]);
				power->
					Power = get_power_from_roleinfo(get(creature_info)),
					NewPower = Power + AttributeValue,
					NewInfo = set_power_to_roleinfo(RoleInfo,NewPower),
					role_op:only_self_update([{power,NewPower}]);
				meleedefense->
					{Magicdefense,Rangedefense,Meleedefense} = get_defenses_from_roleinfo(get(creature_info)),
					NewMeleedefense = Meleedefense + AttributeValue,
					NewInfo = set_defenses_to_roleinfo(RoleInfo, {Magicdefense,Rangedefense,NewMeleedefense}),
					role_op:only_self_update([{meleedefense,NewMeleedefense}]);
				rangedefense->
					{Magicdefense,Rangedefense,Meleedefense} = get_defenses_from_roleinfo(get(creature_info)),
					NewRangedefense = Rangedefense + AttributeValue,
					NewInfo = set_defenses_to_roleinfo(RoleInfo, {Magicdefense,NewRangedefense,Meleedefense}),
					role_op:only_self_update([{rangedefense,NewRangedefense}]);
				magicdefense->
					{Magicdefense,Rangedefense,Meleedefense} = get_defenses_from_roleinfo(get(creature_info)),
					NewMagicdefense = Magicdefense + AttributeValue,
					NewInfo = set_defenses_to_roleinfo(RoleInfo, {NewMagicdefense,Rangedefense,Meleedefense}),
					role_op:only_self_update([{magicdefense,NewMagicdefense}]);
				hitrate->
					Hitrate=get_hitrate_from_roleinfo(get(creature_info)),
					NewHitrate = Hitrate + AttributeValue,
					NewInfo = set_hitrate_to_roleinfo(RoleInfo, NewHitrate),
					role_op:only_self_update([{hitrate,NewHitrate}]);
				dodge->
					Dodge=get_dodge_from_roleinfo(get(creature_info)),
					NewDodge = Dodge + AttributeValue,
					NewInfo = set_dodge_to_roleinfo(RoleInfo, NewDodge),
					role_op:only_self_update([{dodge,NewDodge}]);
				criticalrate->
					Criticalrate=get_criticalrate_from_roleinfo(get(creature_info)),
					NewCriticalrate = Criticalrate + AttributeValue,
					NewInfo = set_criticalrate_to_roleinfo(RoleInfo, NewCriticalrate),
					role_op:only_self_update([{criticalrate,NewCriticalrate}]);
				criticaldestroyrate->
					Criticaldamage=get_criticaldamage_from_roleinfo(get(creature_info)),
					NewCriticaldamage = Criticaldamage + AttributeValue,
					NewInfo = set_criticaldamage_to_roleinfo(RoleInfo, NewCriticaldamage),
					role_op:only_self_update([{criticaldestroyrate,NewCriticaldamage}]);
				toughness->
					Toughness = get_toughness_from_roleinfo(get(creature_info)),
					NewToughness = Toughness + AttributeValue,
					NewInfo = set_toughness_to_roleinfo(RoleInfo, NewToughness),
					role_op:only_self_update([{toughness,NewToughness}])
			end,		
			put(creature_info,NewInfo),
			role_fighting_force:hook_on_change_role_fight_force(),
			role_op:update_role_info(get(roleid),NewInfo);
		true->
			nothing
	end.	

