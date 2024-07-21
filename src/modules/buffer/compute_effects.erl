%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-19
%% Description: TODO: Add description to compute_effects
-module(compute_effects).
-include("common_define.hrl").
%%
%% Include files
%%

%%
%% Exported Functions
%%
%% for role
-export([compute/7,compute_attributes/2]).
%% for npc
-export([compute/4,compute_attributes/1]).


-export([get_hpmax_base/3,get_mpmax_base/3]).

%%
%% EffectList: [{effect_atom,argument}]
%%

filter_change_attribute(K,V,LastAttributes)->
	case lists:keyfind({K,current}, 1, LastAttributes) of
		{{K,current},V}-> false;
		_-> true
	end.

compute(AttributeInfos,ClassId,Level,EffectList,RemoveEffect,AddBaseAttr,RemoveBaseAttr)->
	EffectList2 = effect:combin_effect(EffectList ++ AddBaseAttr),
	BaseAttrList =  effect:combin_effect(AddBaseAttr),
%%	RemoveEffect2 = get_change_attributes(ClassId,RemoveEffect),
%%	ChangeAttributeList = attribute_merge(get_change_attributes(ClassId,EffectList2) , RemoveEffect2),
	ChangeAttributeList = get_change_attributes(ClassId,RemoveEffect++EffectList2 ++ RemoveBaseAttr),
	AttributeResList = lists:foldl(fun(Att,AttResList)-> compute_attribute(Att,AttResList,{ClassId,Level},EffectList2,BaseAttrList) end,AttributeInfos ,ChangeAttributeList),
	ChangeAttributes = lists:map(fun(AttrKey)-> {AttrKey,attribute:get_current(AttributeResList,AttrKey)} end, ChangeAttributeList),
	ChangeAttributes1 = lists:filter(fun({K,V})-> filter_change_attribute(K,V,AttributeInfos) end, ChangeAttributes),
	{AttributeResList,ChangeAttributes1}.

compute_attributes(ClassId,Level)->
	AttributeList = get_all_attributes(ClassId),
	AttributeResList = lists:foldl(fun(Att,AttResList)-> compute_attribute(Att,AttResList,{ClassId,Level},[],[]) end,[] ,AttributeList),
	NewAttributes = lists:map(fun(AttrKey)-> {AttrKey,attribute:get_current(AttributeResList,AttrKey)} end, AttributeList),
	{AttributeResList,NewAttributes}.

compute(AttributeInfos,NpcProtoId,EffectList,RemoveEffect)->
	NpcProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
	ClassId = npc_db:get_proto_attacktype(NpcProtoInfo),
	EffectList2 = effect:combin_effect(EffectList),
	ChangeAttributeList = get_change_attributes(ClassId,RemoveEffect++EffectList2),
%%	RemoveEffect2 = get_change_attributes(ClassId,RemoveEffect),
%%	ChangeAttributeList = attribute_merge(get_change_attributes(ClassId,EffectList2) , RemoveEffect2),
	AttributeResList = lists:foldl(fun(Att,AttResList)-> compute_attribute(Att,AttResList,NpcProtoId,EffectList2,[]) end,AttributeInfos ,ChangeAttributeList),
	ChangeAttributes = lists:map(fun(AttrKey)-> {AttrKey,attribute:get_current(AttributeResList,AttrKey)} end, ChangeAttributeList),
	ChangeAttributes1 = lists:filter(fun({K,V})-> filter_change_attribute(K,V,AttributeInfos) end, ChangeAttributes),
	{AttributeResList,ChangeAttributes1}.

compute_attributes(NpcProtoId)->
	NpcProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
	ClassId = npc_db:get_proto_attacktype(NpcProtoInfo),
	AttributeList = get_all_attributes(ClassId),
	AttributeResList = lists:foldl(fun(Att,AttResList)-> 
									   compute_attribute(Att,AttResList,NpcProtoId,[],[]) end,[] ,AttributeList),
	NewAttributes = lists:map(fun(AttrKey)-> {AttrKey,attribute:get_current(AttributeResList,AttrKey)} end, AttributeList),
	{AttributeResList,NewAttributes}.

attribute_merge(Keys1,Keys2)->
	lists:foldl(fun(Key,NewAcc)-> 
					case lists:member(Key, NewAcc) of
						true-> NewAcc;
						false-> NewAcc++[Key]
					end
				end, 
				Keys1, Keys2).

get_change_attributes(ClassId,EffectList)->
	Attributes =get_effect_to_attributes(ClassId),
	lists:foldl(fun({Effect,AttributeList},AccAttri)-> 
						case lists:keyfind(Effect, 1, EffectList) of
							false->
								AccAttri;
							_->
								attribute_merge(AccAttri,AttributeList)
						end
						end, [], Attributes).


get_all_attributes(ClassId)->
	Attributes =get_effect_to_attributes(ClassId),
	lists:foldl(fun({_,AttributeList},AccAttri)-> 
							attribute_merge(AccAttri,AttributeList)
						end, [], Attributes).

-define(COMMON_EFFECT_TUPLE,{hitrate,[hitrate]},
							{dodge,[dodge]},
							{magicdefense,[magicdefense]},
							{rangedefense,[rangedefense]},
							{meleedefense,[meleedefense]},
							{magicimmunity,[magicimmunity]},
							{rangeimmunity,[rangeimmunity]},
							{meleeimmunity,[meleeimmunity]},
							{criticalrate,[criticalrate]},
							{criticaldestroyrate,[criticaldestroyrate]},
							{toughness,[toughness]},
							{imprisonment_resist,[imprisonment_resist]},
							{silence_resist,[silence_resist]},
							{daze_resist,[daze_resist]},
							{poison_resist,[poison_resist]},
							{normal_resist,[normal_resist]},
							{movespeed,[movespeed]},
							{hprecover,[hprecover]},
							{mprecover,[mprecover]},
							{skillcostreduce,[skillcostreduce]},
							{skillcostzero,[skillcostzero]},
							{castspeed,[castspeed]},
							{enhancerate,[enhancerate]},
							{makesocketrate,[makesocketrate]},
							{decomposerate,[decomposerate]},
							{composerate,[composerate]},
							{excellentpetrate,[excellentpetrate]},
							{threatgainrate,[threatgainrate]},
							{invincible,[invincible]},
							{displayid,[displayid]},
							{magicdefense_percent,[magicdefense]},
							{rangedefense_percent,[rangedefense]},
							{meleedefense_percent,[meleedefense]},
							{hitrate_percent,[hitrate]},
							{dodge_percent,[dodge]},
							{criticalrate_percent,[criticalrate]},
							{criticaldestroyrate_percent,[criticaldestroyrate]},
							{toughness_percent,[toughness]}
	   						).
get_effect_to_attributes(0)->
	[];
get_effect_to_attributes(?CLASS_MAGIC)->
	[
		{agile_effect,[agile,dodge]},%% æ•æ· ï¼Œèº²é—ª
		{agile_effect_percent,[agile,dodge]},
		{strength_effect,[strength,hitrate]},
		{strength_effect_percent,[strength,hitrate]},
		{intelligence_effect,[intelligence,mpmax,power]},
		{intelligence_effect_percent,[intelligence,mpmax,power]},
		{stamina_effect,[stamina,hpmax]},
		{stamina_effect_percent,[stamina,hpmax]},
		{hpmax,[hpmax]},
		{hpmax_percent,[hpmax]},
		{mpmax,[mpmax]},
		{mpmax_percent,[mpmax]},
		{magicpower,[power]},
		{magicpower_percent,[power]},
		?COMMON_EFFECT_TUPLE
	];

get_effect_to_attributes(?CLASS_RANGE)->
	[
		{agile_effect,[agile,dodge,power]},
		{agile_effect_percent,[agile,dodge,power]},
		{strength_effect,[strength,hitrate]},
		{strength_effect_percent,[strength,hitrate]},
		{intelligence_effect,[intelligence]},
		{intelligence_effect_percent,[intelligence]},
		{stamina_effect,[stamina,hpmax]},
		{stamina_effect_percent,[stamina,hpmax]},
		{hpmax,[hpmax]},
		{hpmax_percent,[hpmax]},
		{mpmax,[mpmax]},
		{mpmax_percent,[mpmax]},
		{rangepower,[power]},
		{rangepower_percent,[power]},

		?COMMON_EFFECT_TUPLE
	];
get_effect_to_attributes(?CLASS_MELEE)->
	[
		{agile_effect,[agile,dodge]},
		{agile_effect_percent,[agile,dodge]},
		{strength_effect,[strength,power,hitrate]},
		{strength_effect_percent,[strength,power,hitrate]},
		{intelligence_effect,[intelligence]},
		{intelligence_effect_percent,[intelligence]},
		{stamina_effect,[stamina,hpmax]},
		{stamina_effect_percent,[stamina,hpmax]},
		{hpmax,[hpmax]},
		{hpmax_percent,[hpmax]},
		{mpmax,[mpmax]},
		{mpmax_percent,[mpmax]},
		{meleepower,[power]},
		{meleepower_percent,[power]},
		?COMMON_EFFECT_TUPLE
	].
	  
compute_attribute(agile,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			ClassBase = role_db:get_class_base(ClassId,Level),
			BaseValue = role_db:get_class_agile(ClassBase),
			AddBaseValue = effect:get_value(BaseAttrList,agile),
			NewBaseValue = AddBaseValue + BaseValue, 		
			compute_4dimensions(AttResList,agile,NewBaseValue,agile_effect,agile_effect_percent,EffectList,AddBaseValue);
		NpcProtoId->
			AttResList
	end;
	

compute_attribute(strength,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			ClassBase = role_db:get_class_base(ClassId,Level),
			BaseValue = role_db:get_class_strength(ClassBase),
			AddBaseValue = effect:get_value(BaseAttrList,strength),
			NewBaseValue = AddBaseValue + BaseValue,
			compute_4dimensions(AttResList,strength,NewBaseValue,strength_effect,strength_effect_percent,EffectList,AddBaseValue);
		NpcProtoId->
			AttResList	
		end;

compute_attribute(intelligence,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			ClassBase = role_db:get_class_base(ClassId,Level),
			BaseValue = role_db:get_class_intelligence(ClassBase),
			AddBaseValue = effect:get_value(BaseAttrList,intelligence),
			NewBaseValue = AddBaseValue + BaseValue,
			compute_4dimensions(AttResList,intelligence,NewBaseValue,intelligence_effect,intelligence_effect_percent,EffectList,AddBaseValue);
		NpcProtoId->
			AttResList
	end;

compute_attribute(stamina,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			ClassBase = role_db:get_class_base(ClassId,Level),
			BaseValue = role_db:get_class_stamina(ClassBase),
			AddBaseValue = effect:get_value(BaseAttrList,intelligence),
			NewBaseValue = AddBaseValue + BaseValue,
			compute_4dimensions(AttResList,stamina,NewBaseValue,stamina_effect,stamina_effect_percent,EffectList,AddBaseValue);
		NpcProtoId->
			AttResList
	end;
		
compute_attribute(hpmax,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			HpMaxBase =get_hpmax_base(Level,ClassId,attribute:get_base(AttResList,stamina)),
			AddBaseValue = effect:get_value(BaseAttrList,hpmax),
			NewHpMaxBase = HpMaxBase + AddBaseValue,
			EffectStmHp = get_hpmax_effect(ClassId,attribute:get_effect(AttResList,stamina)),
			EffectValue = effect:get_value(EffectList,hpmax) - AddBaseValue,
			EffectPercent=effect:get_value(EffectList,hpmax_percent),
			HpMaxEffect = NewHpMaxBase * EffectPercent/100 + EffectValue + EffectStmHp,
			R1 = attribute:put_base(AttResList,hpmax,NewHpMaxBase),
			R2 = attribute:put_effect(R1,hpmax,HpMaxEffect),
			attribute:put_current(R2,hpmax,erlang:trunc(HpMaxEffect+NewHpMaxBase));
		NpcProtoId->
			EffectValue = effect:get_value(EffectList,hpmax),
			EffectPercent = effect:get_value(EffectList,hpmax_percent),
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			HpMaxBase = npc_db:get_proto_hpmax(ProtoInfo),
			HpMaxEffect = HpMaxBase * EffectPercent/100 + EffectValue,
			R1 = attribute:put_base(AttResList,hpmax,HpMaxBase),
			R2 = attribute:put_current(R1,hpmax,HpMaxEffect),
			attribute:put_current(R2,hpmax,erlang:trunc(HpMaxEffect+HpMaxBase))			
	end;
		

compute_attribute(mpmax,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			MaxBase = get_mpmax_base(Level,ClassId,attribute:get_base(AttResList,intelligence)),
			EffectIntMp = get_mpmax_effect(ClassId,attribute:get_effect(AttResList,intelligence)),
			EffectValue = effect:get_value(EffectList,mpmax),
			EffectPercent=effect:get_value(EffectList,mpmax_percent),
			MpMaxEffect = MaxBase * EffectPercent/100 + EffectValue + EffectIntMp,
			R1 = attribute:put_base(AttResList,mpmax,MaxBase),
			R2 = attribute:put_current(R1,mpmax,MpMaxEffect),
			attribute:put_current(R2,mpmax,erlang:trunc(MpMaxEffect+MaxBase));
		NpcProtoId->
			EffectValue = effect:get_value(EffectList,mpmax),
			EffectPercent=effect:get_value(EffectList,mpmax_percent),
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			MpMaxBase = npc_db:get_proto_mpmax(ProtoInfo),
			MpMaxEffect = MpMaxBase * EffectPercent/100 + EffectValue,
			R1 = attribute:put_base(AttResList,mpmax,MpMaxBase),
			R2 = attribute:put_current(R1,mpmax,MpMaxEffect),
			attribute:put_current(R2,mpmax,erlang:trunc(MpMaxEffect+MpMaxBase))			
	end;

compute_attribute(power,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
		%% player 
		ClassInfo = role_db:get_class_base(ClassId,Level),
		ClassPower = role_db:get_class_power(ClassInfo),
			{BasePower,PowerEffect} = case ClassId of
				1->BaseMagicPower = Level+0.4*attribute:get_base(AttResList,intelligence),
				   EffectIntPower = 0.4*attribute:get_effect(AttResList,intelligence),
				   AddBaseValue = effect:get_value(BaseAttrList,magicpower),
				   NewBaseMagicPower = BaseMagicPower + AddBaseValue,
				   MagicPowerEffect =  effect:get_value(EffectList,magicpower) + ClassPower - AddBaseValue,
				   MagicPowerPercent=  effect:get_value(EffectList,magicpower_percent),
				   {NewBaseMagicPower,NewBaseMagicPower*MagicPowerPercent/100+MagicPowerEffect + EffectIntPower};
				2->BaseRangePower = Level+0.4*attribute:get_base(AttResList,agile),
				   EffectAglPower = 0.4*attribute:get_effect(AttResList,agile),
				   AddBaseValue = effect:get_value(BaseAttrList,rangepower),
				   NewBaseRangePower = BaseRangePower + AddBaseValue,
				   RangePowerEffect =  effect:get_value(EffectList,rangepower)  + ClassPower - AddBaseValue,
				   RangePowerPercent=  effect:get_value(EffectList,rangepower_percent),
				   {NewBaseRangePower,NewBaseRangePower*RangePowerPercent/100+RangePowerEffect + EffectAglPower};
				3->BaseMeleePower = Level+0.3*attribute:get_base(AttResList,strength),
				   EffectStrPower = 0.3*attribute:get_effect(AttResList,strength),
				   AddBaseValue = effect:get_value(BaseAttrList,meleepower),
				   NewBaseMeleePower = BaseMeleePower + AddBaseValue,
				   MeleePowerEffect =  effect:get_value(EffectList,meleepower)  + ClassPower - AddBaseValue,
				   MeleePowerPercent=  effect:get_value(EffectList,meleepower_percent),
				   {NewBaseMeleePower,NewBaseMeleePower*MeleePowerPercent/100+MeleePowerEffect + EffectStrPower}
				end,
			R1 = attribute:put_base(AttResList,power,BasePower),
			R2 = attribute:put_current(R1,power,PowerEffect),
			attribute:put_current(R2,power,erlang:trunc(PowerEffect+BasePower));
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			BasePower =  npc_db:get_proto_power(ProtoInfo),
			PowerEffect = case npc_db:get_proto_attacktype(ProtoInfo) of
							  1-> 	MagicPowerEffect =  effect:get_value(EffectList,magicpower),
				   					MagicPowerPercent=  effect:get_value(EffectList,magicpower_percent),
									BasePower*MagicPowerPercent/100+MagicPowerEffect;
							  
							  2-> 	RangePowerEffect =  effect:get_value(EffectList,rangepower),
									RangePowerPercent=  effect:get_value(EffectList,rangepower_percent),
									BasePower*RangePowerPercent/100+RangePowerEffect;
							  
							  3-> 	MeleePowerEffect =  effect:get_value(EffectList,meleepower),
									MeleePowerPercent=  effect:get_value(EffectList,meleepower_percent),
									BasePower*MeleePowerPercent/100+MeleePowerEffect
						  end,
			
			R1 = attribute:put_base(AttResList,power,BasePower),
			R2 = attribute:put_current(R1,power,PowerEffect),
			attribute:put_current(R2,power,erlang:trunc(PowerEffect+BasePower))
	end;

compute_attribute(hitrate,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			{BaseHitRate,EffectHitRate} = case ClassId of
						1-> {Level*0.1 + attribute:get_current(AttResList,strength)*0.2 + 900 
											, effect:get_value(EffectList,hitrate)};
						2-> {Level*0.1 + attribute:get_current(AttResList,strength)*0.2 + 900
							 				, effect:get_value(EffectList,hitrate)};
						3-> {Level*0.1 + attribute:get_current(AttResList,strength)*0.1 + 900 
											, effect:get_value(EffectList,hitrate)}
					  end,
			AddBaseValue = effect:get_value(BaseAttrList,hitrate),
			NewBaseHitRate = BaseHitRate + AddBaseValue,
			NewEffectHitRate = EffectHitRate - AddBaseValue,
			HitRatePercent = effect:get_value(EffectList,hitrate_percent),
			EffectHitRateValue = NewBaseHitRate * HitRatePercent/100 + NewEffectHitRate,
			R1 = attribute:put_base(AttResList,hitrate,NewBaseHitRate),
			R2 = attribute:put_current(R1,hitrate,EffectHitRateValue),
			attribute:put_current(R2,hitrate,erlang:trunc(EffectHitRateValue+NewBaseHitRate));
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			BaseHitRate =  npc_db:get_proto_hitrate(ProtoInfo),
			EffectHitRate = effect:get_value(EffectList,hitrate),
			R1 = attribute:put_base(AttResList,hitrate,BaseHitRate),
			R2 = attribute:put_current(R1,hitrate,EffectHitRate),
			attribute:put_current(R2,hitrate,erlang:trunc(EffectHitRate+BaseHitRate))			
	end;

compute_attribute(dodge,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			{BaseDodge,EffectDodge} = case ClassId of
										  1-> {Level*0.1 + attribute:get_current(AttResList,agile)*0.2
											  			,effect:get_value(EffectList,dodge)};
										  2-> {Level*0.1 + attribute:get_current(AttResList,agile)*0.1
											  			,effect:get_value(EffectList,dodge)};
										  3-> {Level*0.1 + attribute:get_current(AttResList,agile)*0.2
											  			,effect:get_value(EffectList,dodge)}
									  end,
			AddBaseValue = effect:get_value(BaseAttrList,dodge),
			NewBaseDodge = BaseDodge + AddBaseValue,
			NewEffectDodge = EffectDodge - AddBaseValue,
			DodgePercent = effect:get_value(EffectList,dodge_percent),
			EffectDodgeValue = NewBaseDodge * DodgePercent / 100 + NewEffectDodge,
			R1 = attribute:put_base(AttResList,dodge,NewBaseDodge),
			R2 = attribute:put_current(R1,dodge,EffectDodgeValue),
			attribute:put_current(R2,dodge,erlang:trunc(EffectDodgeValue+NewBaseDodge));
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			BaseDodge =  npc_db:get_proto_dodge(ProtoInfo),
			EffectDodge=effect:get_value(EffectList,hitrate),
			R1 = attribute:put_base(AttResList,dodge,BaseDodge),
			R2 = attribute:put_current(R1,dodge,EffectDodge),
			attribute:put_current(R2,dodge,erlang:trunc(EffectDodge+BaseDodge))
	end;
compute_attribute(magicdefense,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			ClassInfo = role_db:get_class_base(ClassId,Level),
			ClassMagicDef = role_db:get_class_magicdefense(ClassInfo),
			AddBaseValue =  effect:get_value(BaseAttrList,magicdefense),
			BaseValue = ClassMagicDef + AddBaseValue,
			EffectValue = effect:get_value(EffectList,magicdefense) - AddBaseValue,
			DefPercent = effect:get_value(EffectList,magicdefense_percent),
			NewEffectValue = BaseValue * DefPercent / 100 +  EffectValue,
			R1 = attribute:put_base(AttResList,magicdefense,BaseValue),
			R2 = attribute:put_current(R1,magicdefense,NewEffectValue),
			attribute:put_current(R2,magicdefense,erlang:trunc(NewEffectValue + BaseValue));
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			{MagicDefense,_,_} =  npc_db:get_proto_defense(ProtoInfo),
			EffectValue = effect:get_value(EffectList,magicdefense),
			R1 = attribute:put_base(AttResList,magicdefense,MagicDefense),
			R2 = attribute:put_current(R1,magicdefense,EffectValue),
			attribute:put_current(R2,magicdefense,EffectValue+MagicDefense)
	end;
compute_attribute(rangedefense,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			ClassInfo = role_db:get_class_base(ClassId,Level),
			ClassRangeDef = role_db:get_class_rangedefense(ClassInfo),
			AddBaseValue = effect:get_value(BaseAttrList,rangedefense),
			BaseValue = ClassRangeDef + AddBaseValue,
			EffectValue = effect:get_value(EffectList,rangedefense) - AddBaseValue,
			DefPercent = effect:get_value(EffectList,rangedefense_percent),
			NewEffectValue = BaseValue * DefPercent / 100 +  EffectValue,
			R1 = attribute:put_base(AttResList,rangedefense,BaseValue),
			R2 = attribute:put_current(R1,rangedefense,NewEffectValue),
			attribute:put_current(R2,rangedefense,erlang:trunc(NewEffectValue + BaseValue));
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			{_,RangeDefense,_} =  npc_db:get_proto_defense(ProtoInfo),
			EffectValue = effect:get_value(EffectList,rangedefense),
			R1 = attribute:put_base(AttResList,rangedefense,RangeDefense),
			R2 = attribute:put_current(R1,rangedefense,EffectValue),
			attribute:put_current(R2,rangedefense,EffectValue+RangeDefense)
	end;
compute_attribute(meleedefense,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			ClassInfo = role_db:get_class_base(ClassId,Level),
			ClassMeleeDef = role_db:get_class_meleedefense(ClassInfo),
			AddBaseValue = effect:get_value(BaseAttrList,meleedefense),
			BaseValue = ClassMeleeDef + AddBaseValue,
			EffectValue = effect:get_value(EffectList,meleedefense) - AddBaseValue,
			DefPercent = effect:get_value(EffectList,meleedefense_percent),
			NewEffectValue = BaseValue * DefPercent / 100 +  EffectValue,
			R1 = attribute:put_base(AttResList,meleedefense,BaseValue),
			R2 = attribute:put_current(R1,meleedefense,NewEffectValue),
			attribute:put_current(R2,meleedefense,erlang:trunc(BaseValue + NewEffectValue));
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			{_,_,MeleeDefense} =  npc_db:get_proto_defense(ProtoInfo),
			EffectValue = effect:get_value(EffectList,meleedefense),
			R1 = attribute:put_base(AttResList,meleedefense,MeleeDefense),
			R2 = attribute:put_current(R1,meleedefense,EffectValue),
			attribute:put_current(R2,meleedefense,EffectValue+MeleeDefense)
	end;

compute_attribute(magicimmunity,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			BaseValue = effect:get_value(BaseAttrList,magicimmunity),
			EffectValue = effect:get_value(EffectList,magicimmunity) - BaseValue,
			Percent = effect:get_value(EffectList,magicimmunity_percent),
			NewEffectValue = BaseValue*Percent/100 + EffectValue,
			R1 = attribute:put_base(AttResList,magicimmunity,BaseValue),
			R2 = attribute:put_current(R1,magicimmunity,NewEffectValue),
			attribute:put_current(R2,magicimmunity,erlang:trunc(NewEffectValue + BaseValue));
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			{MagicImmunity,_,_} =  npc_db:get_proto_immunity(ProtoInfo),
			EffectValue = effect:get_value(EffectList,magicimmunity),
			R1 = attribute:put_base(AttResList,magicimmunity,MagicImmunity),
			R2 = attribute:put_current(R1,magicimmunity,EffectValue),
			attribute:put_current(R2,magicimmunity,EffectValue+MagicImmunity)
	end;
compute_attribute(rangeimmunity,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			BaseValue = effect:get_value(BaseAttrList,rangeimmunity),		
			EffectValue = effect:get_value(EffectList,rangeimmunity) - BaseValue,
			Percent = effect:get_value(EffectList,rangeimmunity_percent),
			NewEffectValue = BaseValue*Percent/100 + EffectValue,
			R1 = attribute:put_base(AttResList,rangeimmunity,BaseValue),
			R2 = attribute:put_current(R1,rangeimmunity,NewEffectValue),
			attribute:put_current(R2,rangeimmunity,erlang:trunc(NewEffectValue + BaseValue));
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			{_,RangeImmunity,_} =  npc_db:get_proto_immunity(ProtoInfo),
			EffectValue = effect:get_value(EffectList,rangeimmunity),
			R1 = attribute:put_base(AttResList,rangeimmunity,RangeImmunity),
			R2 = attribute:put_current(R1,rangeimmunity,EffectValue),
			attribute:put_current(R2,rangeimmunity,EffectValue+RangeImmunity)
	end;
compute_attribute(meleeimmunity,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			BaseValue = effect:get_value(BaseAttrList,meleeimmunity),			
			EffectValue = effect:get_value(EffectList,meleeimmunity) - BaseValue,
			Percent = effect:get_value(EffectList,meleeimmunity_percent),
			NewEffectValue = BaseValue*Percent/100 + EffectValue,
			R1 = attribute:put_base(AttResList,meleeimmunity,BaseValue),
			R2 = attribute:put_current(R1,meleeimmunity,NewEffectValue),
			attribute:put_current(R2,meleeimmunity,erlang:trunc(NewEffectValue + BaseValue));
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			{_,_,MeleeImmunity} =  npc_db:get_proto_immunity(ProtoInfo),
			EffectValue = effect:get_value(EffectList,meleeimmunity),
			R1 = attribute:put_base(AttResList,meleeimmunity,MeleeImmunity),
			R2 = attribute:put_current(R1,meleeimmunity,EffectValue),
			attribute:put_current(R2,meleeimmunity,EffectValue+MeleeImmunity)
	end;
compute_attribute(criticalrate,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			AddBaseValue = effect:get_value(BaseAttrList,criticalrate),
			BaseValue = AddBaseValue + 50,		
			EffectValue = effect:get_value(EffectList,criticalrate) - AddBaseValue,
			Percent = effect:get_value(EffectList,criticalrate_percent),
			NewEffectValue = BaseValue*Percent/100 + EffectValue,
			R1 = attribute:put_base(AttResList,criticalrate,BaseValue),
			attribute:put_current(R1,criticalrate,erlang:trunc(BaseValue+NewEffectValue));
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			BaseCrtRate = npc_db:get_proto_criticalrate(ProtoInfo),
			EffectValue = effect:get_value(EffectList,criticalrate),
			R1 = attribute:put_base(AttResList,criticalrate,BaseCrtRate),
			R2 = attribute:put_current(R1,criticalrate,EffectValue),
			attribute:put_current(R2,criticalrate,EffectValue+BaseCrtRate)
	end;
compute_attribute(criticaldestroyrate,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			AddBaseValue = effect:get_value(BaseAttrList,criticaldestroyrate),
			BaseValue = AddBaseValue + 500,	
			EffectValue = effect:get_value(EffectList,criticaldestroyrate) - AddBaseValue,
			Percent = effect:get_value(EffectList,criticaldestroyrate_percent),
			NewEffectValue = BaseValue*Percent/100 + EffectValue,
			R1 = attribute:put_base(AttResList,criticaldestroyrate,BaseValue),
			attribute:put_current(R1,criticaldestroyrate,erlang:trunc(BaseValue+NewEffectValue));
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			BaseCrtDestRate = npc_db:get_proto_criticaldestroyrate(ProtoInfo),
			EffectValue = effect:get_value(EffectList,criticaldestroyrate),
			R1 = attribute:put_base(AttResList,criticaldestroyrate,BaseCrtDestRate),
			R2 = attribute:put_current(R1,criticaldestroyrate,EffectValue),
			attribute:put_current(R2,criticaldestroyrate,EffectValue+BaseCrtDestRate)
	end;
compute_attribute(toughness,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			AddBaseValue = effect:get_value(BaseAttrList,toughness),
			BaseValue = AddBaseValue,
			EffectValue = effect:get_value(EffectList,toughness) - AddBaseValue,
			Percent = effect:get_value(EffectList,toughness_percent),
			NewEffectValue = BaseValue*Percent/100 + EffectValue,
			R1 = attribute:put_base(AttResList,toughness,BaseValue),
			R2 = attribute:put_current(R1,toughness,NewEffectValue),
			attribute:put_current(R2,toughness,erlang:trunc(BaseValue+NewEffectValue));
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			BaseCrtDestRate = npc_db:get_proto_toughness(ProtoInfo),
			EffectValue = effect:get_value(EffectList,toughness),
			R1 = attribute:put_base(AttResList,toughness,BaseCrtDestRate),
			R2 = attribute:put_current(R1,toughness,EffectValue),
			attribute:put_current(R2,toughness,EffectValue)
	end;

compute_attribute(imprisonment_resist,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,imprisonment_resist),
			R1 = attribute:put_base(AttResList,imprisonment_resist,0),
			R2 = attribute:put_current(R1,imprisonment_resist,EffectValue),
			attribute:put_current(R2,imprisonment_resist,EffectValue);
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			{ImprisResist,_,_,_,_} =  npc_db:get_proto_debuff_resist(ProtoInfo),
			EffectValue = effect:get_value(EffectList,imprisonment_resist),
			R1 = attribute:put_base(AttResList,imprisonment_resist,ImprisResist),
			R2 = attribute:put_current(R1,imprisonment_resist,EffectValue),
			attribute:put_current(R2,imprisonment_resist,EffectValue+ImprisResist)
	end;
	
compute_attribute(silence_resist,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,silence_resist),
			R1 = attribute:put_base(AttResList,silence_resist,0),
			R2 = attribute:put_current(R1,silence_resist,EffectValue),
			attribute:put_current(R2,silence_resist,EffectValue);
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			{_,SilenceResist,_,_,_} =  npc_db:get_proto_debuff_resist(ProtoInfo),
			EffectValue = effect:get_value(EffectList,silence_resist),
			R1 = attribute:put_base(AttResList,silence_resist,SilenceResist),
			R2 = attribute:put_current(R1,silence_resist,EffectValue),
			attribute:put_current(R2,silence_resist,EffectValue+SilenceResist)
	end;
	
compute_attribute(daze_resist,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,daze_resist),
			R1 = attribute:put_base(AttResList,daze_resist,0),
			R2 = attribute:put_current(R1,daze_resist,EffectValue),
			attribute:put_current(R2,daze_resist,EffectValue);
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			{_,_,DazeResist,_,_} =  npc_db:get_proto_debuff_resist(ProtoInfo),
			EffectValue = effect:get_value(EffectList,daze_resist),
			R1 = attribute:put_base(AttResList,daze_resist,DazeResist),
			R2 = attribute:put_current(R1,daze_resist,EffectValue),
			attribute:put_current(R2,daze_resist,EffectValue+DazeResist)
	end;
	
compute_attribute(poison_resist,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,poison_resist),
			R1 = attribute:put_base(AttResList,poison_resist,0),
			R2 = attribute:put_current(R1,poison_resist,EffectValue),
			attribute:put_current(R2,poison_resist,EffectValue);
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			{_,_,_,PoisonResist,_} =  npc_db:get_proto_debuff_resist(ProtoInfo),
			EffectValue = effect:get_value(EffectList,poison_resist),
			R1 = attribute:put_base(AttResList,poison_resist,PoisonResist),
			R2 = attribute:put_current(R1,poison_resist,EffectValue),
			attribute:put_current(R2,poison_resist,EffectValue+PoisonResist)
	end;

compute_attribute(normal_resist,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,normal_resist),
			R1 = attribute:put_base(AttResList,normal_resist,0),
			R2 = attribute:put_current(R1,normal_resist,EffectValue),
			attribute:put_current(R2,normal_resist,EffectValue);
		NpcProtoId->
			ProtoInfo = npc_db:get_proto_info_by_id(NpcProtoId),
			{_,_,_,_,NormalResist} =  npc_db:get_proto_debuff_resist(ProtoInfo),
			EffectValue = effect:get_value(EffectList,normal_resist),
			R1 = attribute:put_base(AttResList,normal_resist,NormalResist),
			R2 = attribute:put_current(R1,normal_resist,EffectValue),
			attribute:put_current(R2,normal_resist,EffectValue+NormalResist)
	end;
	
compute_attribute(movespeed,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,movespeed),
			R1 = attribute:put_base(AttResList,movespeed,0),
			R2 = attribute:put_current(R1,movespeed,EffectValue),
			attribute:put_current(R2,movespeed,EffectValue);
		NpcProtoId->			
			EffectValue = effect:get_value(EffectList,movespeed),
			R1 = attribute:put_base(AttResList,movespeed,0),
			R2 = attribute:put_current(R1,movespeed,EffectValue),
			attribute:put_current(R2,movespeed,EffectValue)
	end;

compute_attribute(displayid,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,displayid),
			R1 = attribute:put_base(AttResList,displayid,0),
			R2 = attribute:put_current(R1,displayid,EffectValue),
			attribute:put_current(R2,displayid,EffectValue);
		NpcProtoId->			
			EffectValue = effect:get_value(EffectList,displayid),
			R1 = attribute:put_base(AttResList,displayid,0),
			R2 = attribute:put_current(R1,displayid,EffectValue),
			attribute:put_current(R2,displayid,EffectValue)
	end;

compute_attribute(hprecover,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,hprecover),
			ClassBase = role_db:get_class_base(ClassId,Level),
			BaseRecv = role_db:get_class_hprecover(ClassBase),
			R1 = attribute:put_base(AttResList,hprecover,BaseRecv),
			R2 = attribute:put_current(R1,hprecover,EffectValue),
			attribute:put_current(R2,hprecover,erlang:trunc(BaseRecv+EffectValue));
		NpcProtoId->
			AttResList
	end;

compute_attribute(mprecover,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,mprecover),
			ClassBase = role_db:get_class_base(ClassId,Level),
			BaseRecv = role_db:get_class_mprecover(ClassBase),
			R1 = attribute:put_base(AttResList,mprecover,BaseRecv),
			R2 = attribute:put_current(R1,mprecover,EffectValue),
			attribute:put_current(R2,mprecover,erlang:trunc(BaseRecv+EffectValue));
		NpcProtoId->
			AttResList
	end;

compute_attribute(skillcostreduce,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,skillcostreduce),
			R1 = attribute:put_base(AttResList,skillcostreduce,0),
			R2 = attribute:put_current(R1,skillcostreduce,EffectValue),
			attribute:put_current(R2,skillcostreduce,EffectValue);
		NpcProtoId->
			AttResList
	end;
	
%%
%% skillcostzero: value-> 1|0 
%%
compute_attribute(skillcostzero,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,skillcostzero),
			R1 = attribute:put_base(AttResList,skillcostzero,0),
			R2 = attribute:put_current(R1,skillcostzero,EffectValue),
			attribute:put_current(R2,skillcostzero,EffectValue);
		NpcProtoId->
			AttResList
	end;
	
%%
%% cast_time = skill_cast_time *(100-castspeed)/100
%% 
compute_attribute(castspeed,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,castspeed),
			R1 = attribute:put_base(AttResList,castspeed,0),
			R2 = attribute:put_current(R1,castspeed,EffectValue),
			attribute:put_current(R2,castspeed,EffectValue);
		NpcProtoId->
			AttResList
	end;

compute_attribute(enhancerate,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,enhancerate),
			R1 = attribute:put_base(AttResList,enhancerate,0),
			R2 = attribute:put_current(R1,enhancerate,EffectValue),
			attribute:put_current(R2,enhancerate,EffectValue);
		NpcProtoId->
			AttResList
	end;

compute_attribute(makesocketrate,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,makesocketrate),
			R1 = attribute:put_base(AttResList,makesocketrate,0),
			R2 = attribute:put_current(R1,makesocketrate,EffectValue),
			attribute:put_current(R2,makesocketrate,EffectValue);
		NpcProtoId->
			AttResList
	end;

compute_attribute(decomposerate,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,decomposerate),
			R1 = attribute:put_base(AttResList,decomposerate,0),
			R2 = attribute:put_current(R1,decomposerate,EffectValue),
			attribute:put_current(R2,decomposerate,EffectValue);
		NpcProtoId->
			AttResList
	end;

compute_attribute(composerate,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,composerate),
			R1 = attribute:put_base(AttResList,composerate,0),
			R2 = attribute:put_current(R1,composerate,EffectValue),
			attribute:put_current(R2,composerate,EffectValue);
		NpcProtoId->
			AttResList
	end;

compute_attribute(excellentpetrate,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,excellentpetrate),
			R1 = attribute:put_base(AttResList,excellentpetrate,0),
			R2 = attribute:put_current(R1,excellentpetrate,EffectValue),
			attribute:put_current(R2,excellentpetrate,EffectValue);
		NpcProtoId->
			AttResList
	end;

compute_attribute(threatgainrate,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,threatgainrate),
			R1 = attribute:put_base(AttResList,threatgainrate,0),
			R2 = attribute:put_current(R1,threatgainrate,EffectValue),
			attribute:put_current(R2,threatgainrate,EffectValue);
		NpcProtoId->
			AttResList
	end;

compute_attribute(invincible,AttResList,ClassId_Level_or_NpcProtoId,EffectList,BaseAttrList)->
	case ClassId_Level_or_NpcProtoId of
		{ClassId,Level}->
			EffectValue = effect:get_value(EffectList,invincible),
			R1 = attribute:put_base(AttResList,invincible,0),
			R2 = attribute:put_current(R1,invincible,EffectValue),
			attribute:put_current(R2,invincible,EffectValue);
		NpcProtoId->
			AttResList
	end;

compute_attribute(_Key,_AttResList,ClassId_Level_or_NpcProtoId,_EffectList,BaseAttrList)->
	slogger:msg("no this key [~p]for effects \n",[_Key]),
	_AttResList.

%
% current= base + (effect - adjustvalue) + base * percentvalue 
%
compute_4dimensions(AttResList,Key,BaseValue,EffectKey,PercentKey,EffectList,AdjustValue)->
	PercentValue = effect:get_value(EffectList, PercentKey),
	EffectValue = effect:get_value(EffectList, EffectKey),
	DeletaEffect = EffectValue - AdjustValue + BaseValue*PercentValue/100,
	R1 = attribute:put_base(AttResList,Key,BaseValue),
	R2 = attribute:put_current(R1,Key,DeletaEffect),
	R3 = attribute:put_effect(R2,Key,EffectValue),
	attribute:put_current(R3,Key,erlang:trunc(BaseValue+DeletaEffect)).



get_hpmax_base(Level,ClassId,Stamina)->
	case ClassId of
		1-> Level*27+55+5*Stamina;
		2-> Level*27+65+5*Stamina;
		3-> Level*28+75+6*Stamina
	end.

get_hpmax_effect(ClassId,Stamina)->
	case ClassId of
		1-> 5*Stamina;
		2-> 5*Stamina;
		3-> 6*Stamina
	end.

get_mpmax_base(Level,ClassId,Intelligence)->
	case ClassId of
		1->Level*28+2*Intelligence+55;
        2->Level*27+2*Intelligence+60;
		3->Level*28+2*Intelligence+60
	end.

get_mpmax_effect(ClassId,Intelligence)->
	case ClassId of
		1-> 17*Intelligence;
		2-> 0;
		3-> 0
	end.
%%
%% Local Functions
%%

	