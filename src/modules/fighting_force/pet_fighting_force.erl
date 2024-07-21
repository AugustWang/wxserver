%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-15
%% Description: TODO: Add description to pet_fighting_force
-module(pet_fighting_force).

%%
%% Include files
%%
-include("pet_struct.hrl").
-include("fighting_force_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
hook_on_change_pet_fighting_force(PetId)->
	PetInfo = pet_op:get_gm_petinfo(PetId),
	Hp=get_hp_value_from_pet_info(PetInfo),
	MeleePower =get_meleepower_value_from_pet_info(PetInfo),
	RangePower=get_rangepower_value_from_pet_info(PetInfo),
	MagicPower=get_magicpower_value_from_pet_info(PetInfo),
	Meleedefense=get_meleedefence_value_from_pet_info(PetInfo),
	Rangedefense=get_rangedefence_value_from_pet_info(PetInfo),
	Magicdefense=get_magicdefence_value_from_pet_info(PetInfo),
	Fighting_Force = computter_fight_force(Hp,MeleePower,RangePower,MagicPower,Meleedefense,Rangedefense,Magicdefense),
	pet_attr:only_self_update(PetId,[{fighting_force,Fighting_Force}]),
	Fighting_Force.
computter_fight_force(Hp,MeleePower,RangePower,MagicPower,Meleedefense,Rangedefense,Magicdefense)->
	Fighting_Force = trunc(Hp*0.5)
					 + MeleePower+RangePower+MagicPower+Meleedefense+Rangedefense+Magicdefense.
	