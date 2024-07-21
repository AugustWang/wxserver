%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-1-21
%% Description: TODO: Add description to petup_op
-module(petup_op).
%%
%% Exported Functions
%%
-export([pet_up_reset_c2s/6,pet_up_growth_c2s/3,pet_up_stamina_growth_c2s/3,pet_riseup_c2s/3]).
-include("data_struct.hrl").
-include("common_define.hrl").
-include("mnesia_table_def.hrl").
-include("pet_struct.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
%%
%% API Functions
%%
pet_up_reset_c2s(PetId,Reset,Protect,Locked,Pattr,Lattr)->
%%	case equipment_op:get_item_from_proc(Reset) of 
%%		[]->
%%			Errno = ?ERROR_PET_UP_RESET_NOEXIST;
%%		ResetProp->
%%			Pets_info = get(pets_info),
%%			case lists:keyfind(PetId, 2, Pets_info) of
%%				false->
%%					Errno = ?ERROR_PET_NOEXIST;
%%				MyPet->
%%					ProtoId = get_proto_from_petinfo(MyPet),
%%					ResetInfo = util:term_to_record(petup_db:get_pet_up_reset_info(ProtoId), pet_up_reset),
%%					Needs = petup_db:get_needs_with_reset_info(ResetInfo),
%%					ProtectFromDB = petup_db:get_protect_with_reset_info(ResetInfo),
%%					LockedFromDB = petup_db:get_locked_with_reset_info(ResetInfo),
%%					Consume = petup_db:get_consume_with_reset_info(ResetInfo),
%%					ResetTemplateId = get_template_id_from_iteminfo(ResetProp),
%%					case lists:member(ResetTemplateId, Needs) of
%%						true->
%%							case role_op:check_money(?MONEY_SILVER, Consume) of
%%								true->
%%									Errno=[],
%%									Class = get_class_from_petinfo(MyPet),
%%									OStrength=get_born_strength_from_petinfo(MyPet),
%%									OAgile=get_born_agile_from_petinfo(MyPet),
%%									OIntelligence=get_born_intelligence_from_petinfo(MyPet),
%%									AbilitiesNum=OStrength+OAgile+OIntelligence,
%%									MainClassRate = pet_op:apply_ran_list(petup_db:get_main_growth_rate_with_reset_info(ResetInfo))/100,
%%									ClassPower = trunc(MainClassRate*AbilitiesNum),
%%									ProtectedClass = check_prop_class(Protect,ProtectFromDB,Pattr,0),
%%									LockedClass = check_prop_class(Locked,LockedFromDB,Lattr,0),
%%									case Class of
%%										?CLASS_MAGIC->
%%											Intelligence = ClassPower,
%%											Agile =  trunc((AbilitiesNum - ClassPower)/2),
%%											Strength = AbilitiesNum - Intelligence - Agile;
%%										?CLASS_RANGE->
%%											Agile = ClassPower,
%%											Intelligence = trunc((AbilitiesNum - ClassPower)/2),
%%											Strength = AbilitiesNum - Intelligence - Agile;
%%										_->
%%											Strength = ClassPower,
%%											Intelligence = trunc((AbilitiesNum - ClassPower)/2),
%%											Agile = AbilitiesNum - Intelligence - Strength
%%									end,
%%									case check_protect_and_lock(Class,ProtectedClass,LockedClass,Strength,Agile,Intelligence,OStrength,OAgile,OIntelligence) of
%%										[]->
%%											FinalStrength = Strength,
%%											FinalAgile = Agile,
%%											FinalIntelligence = Intelligence;
%%										{A,B,C}->
%%											FinalStrength = A,
%%											FinalAgile = B,
%%											FinalIntelligence = C
%%									end,
%%									role_op:money_change(?MONEY_SILVER, -Consume, lost_pet_reset),
%%									equipment_op:consume_item(Reset),
%%									NewPetInfo = MyPet#gm_pet_info{born_strength=FinalStrength,born_agile=FinalAgile,born_intelligence=FinalIntelligence},
%%									pet_util:recompute_attr(NewPetInfo),
%%									Message = petup_packet:encode_pet_up_reset_s2c(PetId,FinalStrength,FinalAgile,FinalIntelligence),
%%									role_op:send_data_to_gate(Message);
%%								false->
%%									Errno=?ERROR_LESS_MONEY		
%%							end;
%%						false->
%%							Errno = ?ERROR_PET_UP_RESET_NEEDS_NOEXIST
%%					end
%%			end
%%	end,
%%	if 
%%		Errno =/= []->
%%			Message_failed = petup_packet:encode_pet_opt_error_s2c(Errno),
%%			role_op:send_data_to_gate(Message_failed);
%% 		true->
%%			nothing
%%	end.
	todo.

check_protect_and_lock(Class,ProtectedClass,LockedClass,Strength,Agile,Intelligence,OStrength,OAgile,OIntelligence)->
%%	Sum = OStrength+OAgile+OIntelligence,
%%	case ProtectedClass of
%%		?CLASS_MAGIC->
%%			if 
%%				Intelligence =< OIntelligence->
%%					FinalIntelligence = OIntelligence,
%%					case LockedClass of
%%						?CLASS_RANGE->
%%							FinalAgile = OAgile,
%%							FinalStrength = Sum - FinalIntelligence - FinalAgile;
%%						?CLASS_MELEE->
%%							FinalStrength = OStrength,
%%							FinalAgile = Sum - FinalIntelligence - FinalStrength;
%%						_->
%%							FinalAgile = OAgile,
%%							FinalStrength = OStrength
%%					end,
%%					{FinalStrength,FinalAgile,FinalIntelligence};
%%				true->
%%					FinalIntelligence = Intelligence,
%%					case LockedClass of
%%						?CLASS_RANGE->
%%							FinalAgile = Agile,
%%							FinalStrength = Sum - FinalIntelligence - FinalAgile;
%%						?CLASS_MELEE->
%%							FinalStrength = Strength,
%%							FinalAgile = Sum - FinalIntelligence - FinalStrength;
%%						_->
%%							FinalAgile = Agile,
%%							FinalStrength = Strength
%%					end,
%%					{FinalStrength,FinalAgile,FinalIntelligence}
%%			end;
%%		?CLASS_RANGE->
%%			if 
%%				Agile =< OAgile->
%%					FinalAgile = OAgile,
%%					case LockedClass of
%%						?CLASS_MAGIC->
%%							FinalIntelligence = OIntelligence,
%%							FinalStrength = Sum - FinalIntelligence - FinalAgile;
%%						?CLASS_MELEE->
%%							FinalStrength = OStrength,
%%							FinalIntelligence = Sum - FinalStrength - FinalAgile;
%%						_->
%%							FinalIntelligence = OIntelligence,
%%							FinalStrength = OStrength
%%					end,
%%					{FinalStrength,FinalAgile,FinalIntelligence};
%%				true->
%%					FinalAgile = Agile,
%%					case LockedClass of
%%						?CLASS_MAGIC->
%%							FinalIntelligence = Intelligence,
%%							FinalStrength = Sum - FinalIntelligence - FinalAgile;
%%						?CLASS_MELEE->
%%							FinalStrength = Strength,
%%							FinalIntelligence = Sum - FinalStrength - FinalAgile;
%%						_->
%%							FinalIntelligence = Intelligence,
%%							FinalStrength = Strength
%%					end,
%%					{FinalStrength,FinalAgile,FinalIntelligence}
%%			end;
%%		?CLASS_MELEE->
%%			if 
%%				Strength =< OStrength->
%%					FinalStrength = OStrength,
%%					case LockedClass of
%%						?CLASS_RANGE->
%%							FinalAgile = OAgile,
%%							FinalIntelligence = Sum - FinalStrength - FinalAgile;
%%						?CLASS_MAGIC->
%%							FinalIntelligence = OIntelligence,
%%							FinalAgile = Sum - FinalIntelligence - FinalStrength;
%%						_->
%%							FinalAgile = OAgile,
%%							FinalIntelligence = OIntelligence
%%					end,
%%					{FinalStrength,FinalAgile,FinalIntelligence};
%%				true->
%%					FinalStrength = Strength,
%%					case LockedClass of
%%						?CLASS_RANGE->
%%							FinalAgile = Agile,
%%							FinalIntelligence = Sum - FinalStrength - FinalAgile;
%%						?CLASS_MAGIC->
%%							FinalIntelligence = Intelligence,
%%							FinalAgile = Sum - FinalIntelligence - FinalStrength;
%%						_->
%%							FinalAgile = Agile,
%%							FinalIntelligence = Intelligence
%%					end,
%%					{FinalStrength,FinalAgile,FinalIntelligence}
%%			end;
%%		_->
%%			case LockedClass of
%%				?CLASS_RANGE->
%%					FinalAgile = OAgile,
%%					case Class of 
%%						?CLASS_RANGE->
%%							FinalIntelligence = trunc((Sum - FinalAgile)/2),
%%							FinalStrength = Sum - FinalAgile - FinalIntelligence;
%%						?CLASS_MAGIC->
%%							if 
%%								(FinalAgile+Intelligence) =< Sum->
%%									FinalIntelligence = Intelligence,
%%									FinalStrength = Sum - FinalAgile - FinalIntelligence;
%%								true->
%%									FinalIntelligence = Sum - FinalAgile,
%%									FinalStrength = 0
%%							end;
%%						?CLASS_MELEE->
%%							if
%%								(FinalAgile+Strength) =< Sum->
%%									FinalStrength = Strength,
%%									FinalIntelligence = Sum - FinalAgile - FinalStrength;
%%								true->
%%									FinalStrength = Sum - FinalAgile,
%%									FinalIntelligence = 0
%%							end
%%					end,
%%					{FinalStrength,FinalAgile,FinalIntelligence};
%%				?CLASS_MAGIC->
%%					FinalIntelligence = OIntelligence,
%%					case Class of 
%%						?CLASS_RANGE->
%%							if
%%								(FinalIntelligence+Agile) =< Sum->
%%									FinalAgile = Agile,
%%									FinalStrength = Sum - FinalAgile - FinalIntelligence;
%%								true->
%%									FinalAgile = Sum - FinalIntelligence,
%%									FinalStrength = 0
%%							end;
%%						?CLASS_MAGIC->
%%							FinalAgile = trunc((Sum - FinalIntelligence)/2),
%%							FinalStrength = Sum - FinalAgile - FinalIntelligence;
%%						?CLASS_MELEE->
%%							if
%%								(FinalIntelligence+Strength) =< Sum->
%%									FinalStrength = Strength,
%%									FinalAgile = Sum - FinalIntelligence - FinalStrength;
%%								true->
%%									FinalStrength = Sum - FinalIntelligence,
%%									FinalAgile = 0
%%							end
%%					end,
%%					{FinalStrength,FinalAgile,FinalIntelligence};
%%				?CLASS_MELEE->
%%					FinalStrength = OStrength,
%%					case Class of 
%%						?CLASS_RANGE->
%%							if
%%								(FinalStrength+Agile) =< Sum->
%%									FinalAgile = Agile,
%%									FinalIntelligence = Sum - FinalAgile - FinalStrength;
%%								true->
%%									FinalAgile = Sum - FinalStrength,
%%									FinalIntelligence = 0
%%							end;
%%						?CLASS_MAGIC->
%%							if
%%								(FinalStrength+Intelligence) =< Sum->
%%									FinalIntelligence = Intelligence,
%%									FinalAgile = Sum - FinalIntelligence - FinalStrength;
%%								true->
%%									FinalIntelligence = Sum - FinalStrength,
%%									FinalAgile = 0
%%							end;
%%						?CLASS_MELEE->
%%							FinalAgile = trunc((Sum - FinalStrength)/2),
%%							FinalIntelligence = Sum - FinalAgile - FinalStrength
%%					end,
%%					{FinalStrength,FinalAgile,FinalIntelligence};
%%				_->
%%					[]
%%			end
%%	end.
	todo.

check_prop_class(PropSlot,PropFromDB,Class,DefaultClass)->
	case equipment_op:get_item_from_proc(PropSlot) of
		[]->
			DefaultClass;
		PropItem->
			case lists:member(get_template_id_from_iteminfo(PropItem), PropFromDB) of
				false->
					DefaultClass;
				true->
					Class
			end
	end.

pet_up_growth_c2s(PetId,Needs,Protect)->
%%	case equipment_op:get_item_from_proc(Needs) of 
%%		[]->
%%			Errno = ?ERROR_PET_UP_RESET_NEEDS_NOEXIST;
%%		NeedsProp->
%%			Pets_info = get(pets_info),
%%			case lists:keyfind(PetId, 2, Pets_info) of
%%				false->
%%					Errno = ?ERROR_PET_NOEXIST;
%%				MyPet->
%%					ProtoId = get_proto_from_petinfo(MyPet),
%%					OGrowth = get_growth_from_petinfo(MyPet),
%%					State = get_state_from_petinfo(MyPet),
%%					if 
%%						State =/= ?PET_STATE_IDLE->
%%							Errno = ?ERROR_PET_NO_PACKAGE;
%%						true->
%%					case petup_db:get_pet_up_abilities_info({ProtoId,OGrowth}) of
%%						[]->
%%							Errno=?ERRNO_NPC_EXCEPTION;
%%						Infodb->
%%					GrowthInfo = util:term_to_record(Infodb, pet_up_abilities),
%%					NeedsDB = petup_db:get_needs_with_info(GrowthInfo),
%%					Consume = petup_db:get_consume_with_info(GrowthInfo),
%%					Next = petup_db:get_next_with_info(GrowthInfo),
%%					Failure = petup_db:get_failure_with_info(GrowthInfo),
%%					{Success,Max} = petup_db:get_rate_with_info(GrowthInfo),
%%					Protectdb = petup_db:get_protect_with_info(GrowthInfo),
%%					ResetTemplateId = get_template_id_from_iteminfo(NeedsProp),
%%					case lists:member(ResetTemplateId, NeedsDB) of
%%						true->
%%							case role_op:check_money(?MONEY_SILVER, Consume) of
%%								true->
%%									Errno=[],
%%									role_op:money_change(?MONEY_SILVER, -Consume, lost_pet_up_abilities),
%%									equipment_op:consume_item(Needs),
%%									RandomRate = random:uniform(Max),
%%									case vip_op:get_addition_with_vip(pet_up_abilities) of
%%										0->
%%											VipAddition = 0;
%%										Vip->
%%											VipAddition = Vip/100
%%									end,
%%									FinalSuccess = erlang:trunc(Success * (1+VipAddition)),
%%									if 
%%										FinalSuccess >= RandomRate ->
%%											case equipment_op:get_item_from_proc(Protect) of
%%												[]->nothing;
%%												ProtectProp->
%%													case lists:member(get_template_id_from_iteminfo(ProtectProp), Protectdb) of
%%														false->nothing;
%%														true->
%%															equipment_op:consume_item(Protect)
%%													end
%%											end,
%%											NewPetInfo = MyPet#gm_pet_info{growth=Next},
%%											pet_attr:only_self_update(get_id_from_petinfo(MyPet),[{pet_growth,Next}]),
%%											pet_util:recompute_attr(NewPetInfo),
%%											Message = petup_packet:encode_pet_up_growth_s2c(1, Next),
%%											role_op:send_data_to_gate(Message),
%%											gm_logger_role:role_petup(get(roleid),ProtoId,growth,OGrowth,Next,get(level));
%%							   			true->
%%											case equipment_op:get_item_from_proc(Protect) of
%%												[]->
%%													if 
%%														Failure > 0 ->
%%															NewPetInfo = MyPet#gm_pet_info{growth=Failure},
%%															pet_attr:only_self_update(get_id_from_petinfo(MyPet),[{pet_growth,Failure}]),
%%															pet_util:recompute_attr(NewPetInfo),
%%															Message = petup_packet:encode_pet_up_growth_s2c(2, Failure),
%%															gm_logger_role:role_petup(get(roleid),ProtoId,growth_failed,OGrowth,Failure,get(level));
%%													   	true->
%%															gm_logger_role:role_petup(get(roleid),ProtoId,growth_failed,OGrowth,OGrowth,get(level)),
%%															Message = petup_packet:encode_pet_up_growth_s2c(3, OGrowth)
%%													end;
%%												ProtectProp->
%%													case lists:member(get_template_id_from_iteminfo(ProtectProp), Protectdb) of
%%														false->
%%															if 
%%																Failure > 0 ->
%%																	NewPetInfo = MyPet#gm_pet_info{growth=Failure},
%%																	pet_attr:only_self_update(get_id_from_petinfo(MyPet),[{pet_growth,Failure}]),
%%																	pet_util:recompute_attr(NewPetInfo),
%%																	Message = petup_packet:encode_pet_up_growth_s2c(2, Failure),
%%																	gm_logger_role:role_petup(get(roleid),ProtoId,growth_failed,OGrowth,Failure,get(level));
%%													   			true->
%%																	gm_logger_role:role_petup(get(roleid),ProtoId,growth_failed,OGrowth,OGrowth,get(level)),
%%														   			Message = petup_packet:encode_pet_up_growth_s2c(3, OGrowth)
%%															end;	   
%%					   									true->
%%															equipment_op:consume_item(Protect),
%%															Message = petup_packet:encode_pet_up_growth_s2c(3, OGrowth)
%%													end
%%											end,
%%											role_op:send_data_to_gate(Message)
%%									end;
%%								false->
%%									Errno=?ERROR_LESS_MONEY		
%%							end;
%%						false->
%%							Errno = ?ERROR_PET_UP_RESET_NEEDS_NOEXIST
%%					end
%%					end
%%					end
%%			end
%%	end,
%%	if 
%%		Errno =/= []->
%%			Message_failed = petup_packet:encode_pet_opt_error_s2c(Errno),
%%			role_op:send_data_to_gate(Message_failed);
%% 		true->
%%			nothing
%%	end.
	todo.

pet_up_stamina_growth_c2s(PetId,Needs,Protect)->
%%	case equipment_op:get_item_from_proc(Needs) of 
%%		[]->
%%			Errno = ?ERROR_PET_UP_RESET_NEEDS_NOEXIST;
%%		NeedsProp->
%%			Pets_info = get(pets_info),
%%			case lists:keyfind(PetId, 2, Pets_info) of
%%				false->
%%					Errno = ?ERROR_PET_NOEXIST;
%%				MyPet->
%%					ProtoId = get_proto_from_petinfo(MyPet),
%%					OStaminaGrowth = get_stamina_growth_from_petinfo(MyPet),
%%					State = get_state_from_petinfo(MyPet),
%%					if 
%%						State =/= ?PET_STATE_IDLE->
%%							Errno = ?ERROR_PET_NO_PACKAGE;
%%						true->
%%					case petup_db:get_pet_up_stamina_info({ProtoId,OStaminaGrowth}) of
%%						[]->
%%							Errno=?ERRNO_NPC_EXCEPTION;
%%						Info->		
%%							StaminaGrowthInfo = util:term_to_record(Info, pet_up_stamina),
%%							NeedsDB = petup_db:get_needs_with_info(StaminaGrowthInfo),
%%							Consume = petup_db:get_consume_with_info(StaminaGrowthInfo),
%%							Next = petup_db:get_next_with_info(StaminaGrowthInfo),
%%							Failure = petup_db:get_failure_with_info(StaminaGrowthInfo),
%%							{Success,Max} = petup_db:get_rate_with_info(StaminaGrowthInfo),
%%							Protectdb = petup_db:get_protect_with_info(StaminaGrowthInfo),
%%							ResetTemplateId = get_template_id_from_iteminfo(NeedsProp),
%%							case lists:member(ResetTemplateId, NeedsDB) of
%%								true->
%%									case role_op:check_money(?MONEY_SILVER, Consume) of
%%										true->
%%											Errno=[],
%%											role_op:money_change(?MONEY_SILVER, -Consume, lost_pet_up_stamina),
%%											equipment_op:consume_item(Needs),
%%											RandomRate = random:uniform(Max),
%%											case vip_op:get_addition_with_vip(pet_up_stamina) of
%%												0->
%%													VipAddition = 0;
%%												Vip->
%%													VipAddition = Vip/100
%%											end,
%%											FinalSuccess = erlang:trunc(Success * (1+VipAddition)),
%%											if 
%%												FinalSuccess >= RandomRate ->
%%													case equipment_op:get_item_from_proc(Protect) of
%%														[]->nothing;
%%														ProtectProp->
%%															case lists:member(get_template_id_from_iteminfo(ProtectProp), Protectdb) of
%%																false->nothing;
%%																true->
%%																	equipment_op:consume_item(Protect)
%%															end
%%													end,
%%													NewPetInfo = MyPet#gm_pet_info{stamina_growth=Next},
%%													pet_attr:only_self_update(get_id_from_petinfo(MyPet),[{pet_stamina,Next}]),
%%													pet_op:update_pet_info_all(NewPetInfo),
%%													pet_util:recompute_attr(NewPetInfo),
%%													Message = petup_packet:encode_pet_up_stamina_growth_s2c(1, Next),
%%													role_op:send_data_to_gate(Message),
%%													gm_logger_role:role_petup(get(roleid),ProtoId,stamina,OStaminaGrowth,Next,get(level));
%%							   					true->
%%													case equipment_op:get_item_from_proc(Protect) of
%%														[]->
%%															if 
%%																Failure > 0 ->
%%																	NewPetInfo = MyPet#gm_pet_info{stamina_growth=Failure},
%%																	pet_attr:only_self_update(get_id_from_petinfo(MyPet),[{pet_stamina,Failure}]),
%%																	pet_op:update_pet_info_all(NewPetInfo),
%%																	pet_util:recompute_attr(NewPetInfo),
%%																	Message = petup_packet:encode_pet_up_stamina_growth_s2c(2, Failure),
%%																	gm_logger_role:role_petup(get(roleid),ProtoId,stamina_failed,OStaminaGrowth,Failure,get(level));
%%															   	true->
%%																	gm_logger_role:role_petup(get(roleid),ProtoId,stamina_failed,OStaminaGrowth,OStaminaGrowth,get(level)),
%%																	Message = petup_packet:encode_pet_up_stamina_growth_s2c(3, OStaminaGrowth)
%%															end;
%%														ProtectProp->
%%															case lists:member(get_template_id_from_iteminfo(ProtectProp), Protectdb) of
%%																false->
%%																	if 
%%																		Failure > 0 ->
%%																			NewPetInfo = MyPet#gm_pet_info{stamina_growth=Failure},
%%																			pet_attr:only_self_update(get_id_from_petinfo(MyPet),[{pet_stamina,Failure}]),
%%																			pet_op:update_pet_info_all(NewPetInfo),
%%																			pet_util:recompute_attr(NewPetInfo),
%%																			Message = petup_packet:encode_pet_up_stamina_growth_s2c(2, Failure),
%%																			gm_logger_role:role_petup(get(roleid),ProtoId,stamina_failed,OStaminaGrowth,Failure,get(level));
%%															   			true->
%%																			gm_logger_role:role_petup(get(roleid),ProtoId,stamina_failed,OStaminaGrowth,OStaminaGrowth,get(level)),
%%																   			Message = petup_packet:encode_pet_up_stamina_growth_s2c(3, OStaminaGrowth)
%%																	end;	   
%%					   											true->
%%																	equipment_op:consume_item(Protect),
%%																	Message = petup_packet:encode_pet_up_stamina_growth_s2c(3, OStaminaGrowth)
%%															end
%%													end,
%%													role_op:send_data_to_gate(Message)
%%											end;
%%										false->
%%											Errno=?ERROR_LESS_MONEY		
%%									end;
%%								false->
%%									Errno = ?ERROR_PET_UP_RESET_NEEDS_NOEXIST
%%							end
%%					end
%%					end
%%			end
%%	end,
%%	if 
%%		Errno =/= []->
%%			Message_failed = petup_packet:encode_pet_opt_error_s2c(Errno),
%%			role_op:send_data_to_gate(Message_failed);
%% 		true->
%%			nothing
%%	end.
	todo.

pet_riseup_c2s(PetId,Needs,Protect)->
%%	case equipment_op:get_item_from_proc(Needs) of 
%%		[]->
%%			Errno = ?ERROR_PET_UP_RESET_NEEDS_NOEXIST;
%%		NeedsProp->
%%			Pets_info = get(pets_info),
%%			case lists:keyfind(PetId, 2, Pets_info) of
%%				false->
%%					Errno = ?ERROR_PET_NOEXIST;
%%				MyPet->
%%					ProtoId = get_proto_from_petinfo(MyPet),
%%					OQuality = get_quality_from_petinfo(MyPet),
%%					State = get_state_from_petinfo(MyPet),
%%					if 
%%						State =/= ?PET_STATE_IDLE->
%%							Errno = ?ERROR_PET_NO_PACKAGE;
%%						true->
%%					case petup_db:get_pet_up_riseup_info({ProtoId,OQuality}) of
%%						[]->
%%							Errno=?ERRNO_NPC_EXCEPTION;
%%						Infodb->
%%							RiseupInfo = util:term_to_record(Infodb, pet_up_riseup),
%%							NeedsDB = petup_db:get_needs_with_info(RiseupInfo),
%%							Consume = petup_db:get_consume_with_info(RiseupInfo),
%%							Next = petup_db:get_next_with_info(RiseupInfo),
%%							Failure = petup_db:get_failure_with_info(RiseupInfo),
%%							{Success,Max} = petup_db:get_rate_with_info(RiseupInfo),
%%							Protectdb = petup_db:get_protect_with_info(RiseupInfo),
%%							TemplateId = get_template_id_from_iteminfo(NeedsProp),
%%							PetProtoInfo = pet_proto_db:get_info(ProtoId),
%%							case lists:member(TemplateId, NeedsDB) of
%%								true->
%%									case role_op:check_money(?MONEY_SILVER, Consume) of
%%										true->
%%											Errno=[],
%%											role_op:money_change(?MONEY_SILVER, -Consume, lost_pet_riseup),
%%											equipment_op:consume_item(Needs),
%%											RandomRate = random:uniform(Max),
%%											case vip_op:get_addition_with_vip(pet_riseup) of
%%												0->
%%													VipAddition = 0;
%%												Vip->
%%													VipAddition = Vip/100
%%											end,
%%											FinalSuccess = erlang:trunc(Success * (1+VipAddition)),
%%											if 
%%												FinalSuccess >= RandomRate ->
%%													case equipment_op:get_item_from_proc(Protect) of
%%														[]->nothing;
%%														ProtectProp->
%%															case lists:member(get_template_id_from_iteminfo(ProtectProp), Protectdb) of
%%																false->nothing;
%%																true->
%%																	equipment_op:consume_item(Protect)
%%															end
%%													end,
%%													{_,BornGrownList} = lists:nth(Next, pet_proto_db:get_born_growth(PetProtoInfo)),
%%													{_,Stamina_growthList }= lists:nth(Next, pet_proto_db:get_stamina_growth(PetProtoInfo)),
%%													BornGrowth = pet_op:apply_ran_list(BornGrownList),
%%													Stamina_growth = pet_op:apply_ran_list(Stamina_growthList),		
%%													NewPetInfo = MyPet#gm_pet_info{quality=Next,stamina_growth = Stamina_growth,growth = BornGrowth},
%%													pet_attr:only_self_update(get_id_from_petinfo(MyPet),[{pet_stamina,Stamina_growth},{pet_growth,Stamina_growth}]),
%%													pet_util:recompute_attr(NewPetInfo),
%%													Message = petup_packet:encode_pet_riseup_s2c(1, Next),
%%													role_op:send_data_to_gate(Message),
%%													gm_logger_role:role_petup(get(roleid),ProtoId,riseup,OQuality,Next,get(level));
%%									   			true->
%%													case equipment_op:get_item_from_proc(Protect) of
%%														[]->
%%															if 
%%																Failure > 0 ->
%%																	{_,BornGrownList} = lists:nth(Failure, pet_proto_db:get_born_growth(PetProtoInfo) ),
%%																	{_,Stamina_growthList }= lists:nth(Failure, pet_proto_db:get_stamina_growth(PetProtoInfo)),
%%																	BornGrowth = pet_op:apply_ran_list(BornGrownList),
%%																	Stamina_growth = pet_op:apply_ran_list(Stamina_growthList),		
%%																	NewPetInfo = MyPet#gm_pet_info{quality=Failure,stamina_growth = Stamina_growth,growth = BornGrowth},
%%																	pet_attr:only_self_update(get_id_from_petinfo(MyPet),[{pet_stamina,Stamina_growth},{pet_growth,Stamina_growth}]),
%%																	pet_util:recompute_attr(NewPetInfo),
%%																	Message = petup_packet:encode_pet_riseup_s2c(2, Failure),
%%																	gm_logger_role:role_petup(get(roleid),ProtoId,riseup_failed,OQuality,Failure,get(level));
%%															   	true->
%%																	gm_logger_role:role_petup(get(roleid),ProtoId,riseup_failed,OQuality,OQuality,get(level)),
%%																	Message = petup_packet:encode_pet_riseup_s2c(3, OQuality)
%%															end;
%%														ProtectProp->
%%															case lists:member(get_template_id_from_iteminfo(ProtectProp), Protectdb) of
%%																false->
%%																	if 
%%																		Failure > 0 ->
%%																			{_,BornGrownList} = lists:nth(Failure, pet_proto_db:get_born_growth(PetProtoInfo) ),
%%																			{_,Stamina_growthList }= lists:nth(Failure, pet_proto_db:get_stamina_growth(PetProtoInfo)),
%%																			BornGrowth = pet_op:apply_ran_list(BornGrownList),
%%																			Stamina_growth = pet_op:apply_ran_list(Stamina_growthList),		
%%																			NewPetInfo = MyPet#gm_pet_info{quality=Failure,stamina_growth = Stamina_growth,growth = BornGrowth},
%%																			pet_attr:only_self_update(get_id_from_petinfo(MyPet),[{pet_stamina,Stamina_growth},{pet_growth,Stamina_growth}]),
%%																			pet_util:recompute_attr(NewPetInfo),
%%																			Message = petup_packet:encode_pet_riseup_s2c(2, Failure),
%%																			gm_logger_role:role_petup(get(roleid),ProtoId,riseup_failed,OQuality,Failure,get(level));
%%															   			true->
%%																			gm_logger_role:role_petup(get(roleid),ProtoId,riseup_failed,OQuality,OQuality,get(level)),
%%																   			Message = petup_packet:encode_pet_riseup_s2c(3, OQuality)
%%																	end;	   
%%					   											true->
%%																	equipment_op:consume_item(Protect),
%%																	Message = petup_packet:encode_pet_riseup_s2c(3, OQuality)
%%															end
%%													end,
%%													role_op:send_data_to_gate(Message)
%%											end;
%%										false->
%%											Errno=?ERROR_LESS_MONEY		
%%									end;
%%								false->
%%									Errno = ?ERROR_PET_UP_RESET_NEEDS_NOEXIST
%%							end
%%						end
%%					end
%%			end
%%	end,
%%	if 
%%		Errno =/= []->
%%			Message_failed = petup_packet:encode_pet_opt_error_s2c(Errno),
%%			role_op:send_data_to_gate(Message_failed);
%% 		true->
%%			nothing
%%	end.
	todo.

%%
%% Local Functions
%%

