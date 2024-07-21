%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: PC17
%% Created: 2010-9-22
%% Description: TODO: Add description to npc_skill_learn
-module(npc_skill_study).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("login_pb.hrl").
-include("common_define.hrl").
-include("npc_define.hrl").
-include("skill_define.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-export([do_learn_without_npc/1,do_pet_learn_without_npc/3,do_pet_forget_skill/2,do_learn_skill_auto/1]).



-behaviour(npc_function_mod).

-export([init_func/0,registe_func/1,enum/3]).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("pet_struct.hrl").

%%
%% API Functions
%%
init_func()->
	npc_function_frame:add_function(skill_learn,?NPC_FUNCTION_SKILL, ?MODULE).


registe_func(NpcId)->
	Mod= ?MODULE,
	Fun= skill_learn,
	Arg=  [],
	Response=#kl{key=?NPC_FUNCTION_SKILL, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = [],
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

%%%%%%%%%%%%%%%
%%
%% db operator
%%
%%%%%%%%%%%%%%%

enum(_RoleInfo,_SkillList,NpcId)->
	Message = role_packet:encode_enum_skill_item_s2c(NpcId),
	role_op:send_data_to_gate(Message),
	{ok}.
	
do_learn_without_npc(Skillid)->
	RoleInfo = get(creature_info),
	SkillLevel = skill_op:get_skill_level(Skillid)+1,
	case skill_db:get_skill_info(Skillid,SkillLevel) of
		[]->
			nothing;
			%slogger:msg("learn skill error Roleid ~p Skill: ~p Level ~p~n",[get_id_from_roleinfo(RoleInfo),Skillid,SkillLevel]);
		SkillInfo ->
			Price = skill_db:get_money(SkillInfo),
			Soul = skill_db:get_soulpower(SkillInfo),
			NeedItems = skill_db:get_items(SkillInfo),
			case can_learn_skill_skillinfo(RoleInfo,Skillid,SkillInfo) of
				false->
					nothing;
				true->
					role_op:money_change(?MONEY_BOUND_SILVER, -Price ,lost_skill),
					role_op:consume_soulpower(Soul),
					lists:foreach(fun(TemplateId)->script_op:destory_item(TemplateId,1) end, NeedItems),
					skill_op:learn_skill(Skillid, SkillLevel),
					skill_op:async_save_to_db(),
					case (skill_db:get_type(SkillInfo) =:= ?SKILL_TYPE_PASSIVE_ATTREXT) of
						true->
							role_op:recompute_skill_attr(),
							role_fighting_force:hook_on_change_role_fight_force();
						_->
							nothing
					end,
					Msg = role_packet:encode_update_skill_s2c(get(roleid),Skillid, SkillLevel),
					role_op:send_data_to_gate(Msg)
			end
	end.

do_learn_skill_auto(Skillid)->
	RoleInfo = get(creature_info),
	SkillLevel = skill_op:get_skill_level(Skillid)+1,
	case skill_db:get_skill_info(Skillid,SkillLevel) of
		[]->
			nothing;
			%slogger:msg("learn skill error Roleid ~p Skill: ~p Level ~p~n",[get_id_from_roleinfo(RoleInfo),Skillid,SkillLevel]);
		SkillInfo ->
			Price = skill_db:get_money(SkillInfo),
			Soul = skill_db:get_soulpower(SkillInfo),
			NeedItems = skill_db:get_items(SkillInfo),
			case can_learn_skill_skillinfo(RoleInfo,Skillid,SkillInfo) of
				false->
					false;
				true->
					role_op:money_change(?MONEY_BOUND_SILVER, -Price ,lost_skill),
					role_op:consume_soulpower(Soul),
					lists:foreach(fun(TemplateId)->script_op:destory_item(TemplateId,1) end, NeedItems),
					skill_op:learn_skill(Skillid, SkillLevel),
					skill_op:async_save_to_db(),
					case (skill_db:get_type(SkillInfo) =:= ?SKILL_TYPE_PASSIVE_ATTREXT) of
						true->
							role_op:recompute_skill_attr(),
							role_fighting_force:hook_on_change_role_fight_force();
						_->
							false
					end,
					Msg = role_packet:encode_update_skill_s2c(get(roleid),Skillid, SkillLevel),
					role_op:send_data_to_gate(Msg),
					do_learn_skill_auto(Skillid)
			end
	end.

do_pet_learn_without_npc(PetId,SkillId,SkillLevel)->
	case pet_op:get_pet_info(PetId) of
		[]->
			false;
		PetInfo->

			case skill_db:get_pet_skill_info(SkillId, SkillLevel) of
				[]->
					false;
				SkillInfo->
					case can_pet_learn_skill_skillinfo(PetInfo,SkillId,SkillLevel,SkillInfo) of
						false->
							false;
						true->
							case pet_skill_op:pet_skill_learn_skill(PetId, SkillId, SkillLevel) of
								false->
									false;
								_->
									pet_util:recompute_attr(skill, PetId),
									true
							end
					end
			end
	end.

%%return true/false
do_pet_forget_skill(PetId, SkillId)->
%%	case pet_op:get_pet_gminfo(PetId) of
%%		[]->
%%			false;
%%		_->
%%			SkillLevel = pet_skill_op:get_skill_level(PetId, SkillId),
%%			if
%%				SkillLevel =:= 0->
%%					false;
%%				true->
%%					AllSoul = calculus_skill_consume_soulpower(SkillId,SkillLevel),
%%					pet_skill_op:forget_skill(PetId, SkillId),
%%					role_op:obtain_soulpower(AllSoul),
%%					Msg = role_packet:encode_update_skill_s2c(PetId,SkillId, 0),
%%					role_op:send_data_to_gate(Msg),
%%					true
%%			end
%%	end.
	false.		

calculus_skill_consume_soulpower(SkillId,SkillLevel)->
	lists:foldl(fun(LevelTmp,AccPower)->
					case skill_db:get_skill_info(SkillId, LevelTmp) of
						[]->
							AccPower;
						SkillInfo->
							AccPower + skill_db:get_soulpower(SkillInfo)
					end end,0, lists:seq(1, SkillLevel)).

can_pet_learn_skill_skillinfo(PetInfo,SkillId,SkillLevel,SkillInfo)->
	PetId = get_id_from_mypetinfo(PetInfo),
	%Price = skill_db:get_money(SkillInfo),
	%EngouhMoney = role_op:check_money(?MONEY_BOUND_SILVER,Price),
	%EngouhLevel = skill_db:get_learn_level(SkillInfo) =< get_level_from_petinfo(PetInfo),
	%PetProto = get_proto_from_petinfo(PetInfo),
	%PetProtoInfo = pet_proto_db:get_info(PetProto),
	%PetSpecies = pet_proto_db:get_species(PetProtoInfo),
	%NeedCreature = lists:member(PetSpecies, skill_db:get_creature(SkillInfo)),
	%NeedSkillList = skill_db:get_required_skills(SkillInfo),
	%NeedItems = skill_db:get_items(SkillInfo),
	%IsHasItem = lists:filter(fun(TemplateId)->not item_util:is_has_enough_item_in_package(TemplateId,1) end, NeedItems)=:=[],
	%IsHasSkill = lists:foldl(fun({NeedId,NeedLevel},Re)->
	%								 if 
		%								 not Re->
		%									 Re;
		%								 true->
		%									 pet_skill_op:get_skill_level(PetId, NeedId)>=NeedLevel
		%							end		 
		%						end,true,NeedSkillList),
	SkillList=get_skill_from_mypetinfo(PetInfo),
	IsHasSkill = lists:keyfind(SkillId, 2, SkillList),
	IsCanLearn=case IsHasSkill of
				   false->
					   if SkillLevel=:=1->
							  true;
						  true->
							  false
					   end;
				   {Slot,Sid,Slevel}->
					   if (Slevel+1)=:=SkillLevel->
							  true;
						  true->
							  false
					   end
			   end,
	IsHasSolt =if SkillLevel=:=1->
					 case  pet_skill_op:get_new_skill_slot(SkillList) of
				   0->
					   false;
				   _->
					   true
			   end;
				  true->
					 true
			   end,
	IsSameSkill=case IsHasSkill of
					false->
						false;
					 {Slot1,Sid1,Slevel1}->
						if SkillLevel=:=Slevel1->
							   true;
						   true->
							   false
						end
				end,

	if
	%	not EngouhMoney->
		%	Errno = ?ERROR_LESS_MONEY;
	%	not EngouhLevel->
	%		Errno = ?ERROR_PET_LESS_LEVEL;
		%not NeedCreature->
		%	Errno = ?ERROR_PET_LEARN_SKILL_SPECIES_NOT_MATCH;
		 IsHasSkill->
			Errno = ?ERROR_PET_LEARN_SKILL_LESS_NEED_SKILL;
	%	not IsHasSoul->
		%	Errno = ?ERROR_PET_LEARN_SKILL_LESS_SOULPOWER;
	%	not IsHasItem->
	%		Errno = ?ERROR_PET_LEARN_SKILL_LESS_ITEM;
		not IsHasSolt->
			Errno = ?ERROR_PET_LEARN_SKILL_LESS_SLOT;
		IsSameSkill->
			Errno = ?ERROR_PET_LEARN_SKILL_SAME_SKILL;
		not IsCanLearn->
			Errno = ?ERROR_PET_LEARN_SKILL_SAME_SKILL;
		true->
			Errno = []
	end,
	if
		Errno =:= []->
			true;
		true->
			io:format("can_pet_learn_skill_skillinfo ~p ~n",[Errno]),
			role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno)),
			false
	end.

can_learn_skill_skillinfo(RoleInfo,Skillid,SkillInfo)->
	Price = skill_db:get_money(SkillInfo),
	EngouhMoney = role_op:check_money(?MONEY_BOUND_SILVER,Price),
	EngouhLevel = skill_db:get_learn_level(SkillInfo) =< get_level_from_roleinfo(RoleInfo),
	LearnClass = skill_db:get_class(SkillInfo),
	NeedClass = (LearnClass=:= get_class_from_roleinfo(RoleInfo)) or (LearnClass=:=0),	
	NeedCreature = lists:member(?SKILL_ROLE_STUDY, skill_db:get_creature(SkillInfo)),
	NeedItems = skill_db:get_items(SkillInfo),
	IsHasItem = lists:filter(fun(TemplateId)->not item_util:is_has_enough_item_in_package(TemplateId,1) end, NeedItems)=:=[],
	NeedSkillList = skill_db:get_required_skills(SkillInfo),
	IsHasSkill = lists:foldl(fun({NeedId,NeedLevel},Re)->
									 if 
										 not Re->
											 Re;
										 true->
											 skill_op:get_skill_level(NeedId)>=NeedLevel
									end		 
								end,true,NeedSkillList),
	IsHasSoul = role_soulpower:get_cursoulpower()>= skill_db:get_soulpower(SkillInfo),
	EngouhMoney and EngouhLevel and NeedClass and NeedCreature and IsHasSkill and IsHasSoul and IsHasItem.		
			
