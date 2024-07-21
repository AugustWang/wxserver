%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-8-17
%% Description: TODO: Add description to ride_pet_op
-module(ride_pet_synthesis_op).

%%
%% Include files
%%
-include("error_msg.hrl").
-include("common_define.hrl").
-include("ride_pet_define.hrl").
-include("system_chat_define.hrl").
-define(MAXQUALITY,5).
-define(PURPLE_QUALITY,3).
-define(PASS_RIDEPET,[33100115,33100116,33100117,31100118,33100118]).
%%
%% Exported Functions
%%
-export([process_message/1]).

-include("item_struct.hrl").
%%
%% API Functions
%%
process_message({ride_pet_synthesis_c2s,_,Slot_A,Slot_B,ItemSlot,Type})->
	case Type of
		?USEITEM->
			ride_pet_synthesis_by_item(Slot_A,Slot_B,ItemSlot);
		?USEGOLD->
			ride_pet_synthesis_by_gold(Slot_A,Slot_B,ItemSlot)
	end.

ride_pet_synthesis_by_item(Slot_A,Slot_B,ItemSlot)->
	if 
		Slot_A =:= Slot_B ->
			nothing;
		true->
			case package_op:get_iteminfo_in_package_slot(Slot_A) of
				[]->
					nothing;
				RidePetInfo_A->
					RideQuality_A = get_qualty_from_iteminfo(RidePetInfo_A),
					case package_op:get_iteminfo_in_package_slot(Slot_B) of
						[]->
							nothing;
						RidePetInfo_B->
							RideQuality_B = get_qualty_from_iteminfo(RidePetInfo_B),
							if 
								RideQuality_A =:= RideQuality_B->
									if RideQuality_A =:= ?MAXQUALITY->
										    nothing;
									   true->
										   RidePetATempId = get_template_id_from_iteminfo(RidePetInfo_A),
										   RidePetBTempId = get_template_id_from_iteminfo(RidePetInfo_B),
										   ISA_QILIN = lists:member(RidePetATempId,?PASS_RIDEPET),
										   ISB_QILIN = lists:member(RidePetBTempId,?PASS_RIDEPET),
										   if ISA_QILIN or ISB_QILIN ->
												  Message = ride_pet_packet:encode_ridepet_synthesis_error_s2c(?ERROR_CANT_SYNTHESIS),
												  role_op:send_data_to_gate(Message);
											  true->
													SynthesisInfo = ride_pet_db:get_ridepet_synthesis_info(RideQuality_A),
													{Silver,{Class,Count}} = ride_pet_db:get_ridepet_synthesis_consume(SynthesisInfo),
													case package_op:get_iteminfo_in_package_slot(ItemSlot) of
														[]->
															Message = ride_pet_packet:encode_ridepet_synthesis_error_s2c(?ERROR_CANT_SYNTHESIS),
															role_op:send_data_to_gate(Message);
														ItemInfo->
															ItemClass = package_op:get_class_from_iteminfo(ItemInfo),
															if ItemClass=:= Class ->
																	HasItem = item_util:is_has_enough_item_in_package_by_class(ItemClass,Count);
																true->
																	HasItem = false
															end,
															CheckSilver = role_op:check_money(?MONEY_BOUND_SILVER,Silver),
															if
																not HasItem ->
																	Message = ride_pet_packet:encode_ridepet_synthesis_error_s2c(?ERROR_MISS_ITEM),
																	role_op:send_data_to_gate(Message);
																not CheckSilver ->
																	Message = ride_pet_packet:encode_ridepet_synthesis_error_s2c(?ERROR_LESS_MONEY),
																	role_op:send_data_to_gate(Message);
																true ->
																	role_op:money_change(?MONEY_BOUND_SILVER,-Silver,ride_pet_synthesis),
																	role_op:proc_destroy_item(RidePetInfo_A,ride_pet_synthesis),
																	role_op:proc_destroy_item(RidePetInfo_B,ride_pet_synthesis),
																	role_op:consume_items_by_classid(ItemClass,Count),
																	SynthesisRateList = ride_pet_db:get_ridepet_synthesis_rateinfo(SynthesisInfo),
																	case ride_pet_util:random_value_by_rate(SynthesisRateList) of
																		[]->
																			nothing;
																		{PetTempId,BondPetTempId}->
																			PetTempInfo = item_template_db:get_item_templateinfo(PetTempId),
																			PetQuality = item_template_db:get_qualty(PetTempInfo),
																			PetAttrInfo = ride_pet_db:get_attr_info(PetQuality),
																			CanDropNum = ride_pet_db:get_attr_drop_num(PetAttrInfo),
																			DropRateList = ride_pet_db:get_drop_rate_list(PetAttrInfo),
																			ResultAttr = ride_pet_util:random_attr_by_rate(DropRateList,CanDropNum),
																			TmpId_PetA = get_template_id_from_iteminfo(RidePetInfo_A),
																			TmpId_PetB = get_template_id_from_iteminfo(RidePetInfo_B),
																			gm_logger_role:ride_pet_synthesis_log(get(roleid),TmpId_PetA,TmpId_PetB,PetTempId,ResultAttr),
																			case check_is_bond(RidePetInfo_A,RidePetInfo_B) of
																				false->
																					{ok,[PetId]} = role_op:auto_create_and_put(PetTempId, 1, ride_pet_synthesis);
																				_->
																					{ok,[PetId]} = role_op:auto_create_and_put(BondPetTempId, 1, ride_pet_synthesis)
																			end,
																			case ResultAttr of
																				[]->
																					nothing;
																				_->
																					equipment_op:change_enchant_attr_by_itemid(PetId,ResultAttr)
																			end,
																			if PetQuality >= ?PURPLE_QUALITY->
																					ride_pet_util:system_bodcast(?SYSTEM_CHAT_PET_SYNTHESIS,get(creature_info),PetId);
																			   true->
																				   nothing
																			end,
																			Message = ride_pet_packet:encode_ridepet_synthesis_opt_result_s2c(PetTempId,role_attr:to_item_attribute({enchant,ResultAttr})),
																			role_op:send_data_to_gate(Message) 
																	end
															end		
													end
										   end
									end;
								true->
									Result=?ERROR_NOT_SAME_QULITY
							end
					end
			end
	end.

%%return:true/false
check_is_bond(RidePetInfo_A,RidePetInfo_B)->
	IsBondA = items_op:get_isbonded_from_iteminfo(RidePetInfo_A),
	IsBondB = items_op:get_isbonded_from_iteminfo(RidePetInfo_B),
	lists:member(1,[IsBondA,IsBondB]).

ride_pet_synthesis_by_gold(Slot_A,Slot_B,ItemSlot)->
	nothing.
%% 	if 
%% 		Slot_A == Slot_B ->
%% 			nothing;
%% 		true->
%% 			case package_op:get_iteminfo_in_package_slot(Slot_A) of
%% 				[]->
%% 					nothing;
%% 				RidePetInfo_A->
%% 					RideQuality_A = get_qualty_from_iteminfo(RidePetInfo_A),
%% 					case package_op:get_iteminfo_in_package_slot(Slot_B) of
%% 						[]->
%% 							nothing;
%% 						RidePetInfo_B->
%% 							RideQuality_B = get_qualty_from_iteminfo(RidePetInfo_B),
%% 							if 
%% 								RideQuality_A == RideQuality_B->
%% 									SynthesisInfo = ride_pet_db:get_ridepet_synthesis_info(RideQuality_A),
%% 									{{_,Gold},_} = ride_pet_db:get_ridepet_synthesis_consume(SynthesisInfo),
%% 									CheckGold = role_op:check_money(?MONEY_GOLD,Gold),
%% 									if
%% 										not CheckGold ->
%% 											Message = ride_pet_synthesis_packet:encode_ridepet_synthesis_opt_result_s2c(?ERROR_LESS_MONEY),
%% 											role_op:send_data_to_gate(Message);
%% 										true ->
%% 											role_op:money_change(?MONEY_GOLD,-Gold,ride_pet_synthesis),
%% 											role_op:proc_destroy_item(RidePetInfo_A,ride_pet_synthesis),
%% 											role_op:proc_destroy_item(RidePetInfo_B,ride_pet_synthesis),
%% 											SynthesisRateList = ride_pet_db:get_ridepet_synthesis_rateinfo(SynthesisInfo),
%% 											case ride_pet_util:random_value_by_rate(SynthesisRateList) of
%% 												[]->
%% 													nothing;
%% 												PetTempId->
%% 													PetTempInfo = item_template_db:get_item_templateinfo(PetTempId),
%% 													PetQuality = item_template_db:get_qualty(PetTempInfo),
%% 													PetAttrInfo = ride_pet_db:get_attr_info(PetQuality),
%% 													CanDropNum = ride_pet_db:get_attr_drop_num(PetAttrInfo),
%% 													DropRateList = ride_pet_db:get_drop_rate_list(PetAttrInfo),
%% 													ResultAttr = ride_pet_util:random_attr_by_rate(DropRateList,CanDropNum),
%% 													{ok,[PetId]} = role_op:auto_create_and_put(PetTempId, 1, ride_pet_synthesis),
%% 													equipment_op:change_enchant_attr_by_itemid(PetId,ResultAttr),
%% 													ride_pet_util:system_bodcast(?SYSTEM_CHAT_PET_SYNTHESIS,get(creature_info),PetId)
%% 											end
%% 									end;
%% 								true->
%% 									Result=?ERROR_NOT_SAME_QULITY
%% 							end
%% 					end
%% 			end
%% 	end.





	


















					