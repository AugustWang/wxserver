%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-8-26
%% Description: TODO: Add description to pet_evolution
-module(pet_evolution).

%%
%% Include files
%%
-include("common_define.hrl").
-include("game_rank_define.hrl").
-include("error_msg.hrl").
-include("system_chat_define.hrl").
-include("string_define.hrl").
%%
%% Exported Functions
%%
-export([process_message/1]).

-include("pet_struct.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
%%
%% API Functions
%%
process_message({pet_evolution_c2s,_,Petid,ItemSlot})->
	pet_evolution(Petid,ItemSlot).

pet_evolution(PetId,ItemSlot)->
	case package_op:get_iteminfo_in_package_slot(ItemSlot) of
		[]->
			nothing;
		ItemInfo->
			ItemClass = package_op:get_class_from_iteminfo(ItemInfo),
			OldPetInfo = pet_op:get_pet_info(PetId),
			OldGmPetInfo = pet_op:get_gm_petinfo(PetId),
			if 
				(OldPetInfo =/= []) and (OldGmPetInfo =/= []) -> 
					case get_state_from_petinfo(OldGmPetInfo) of
						?PET_STATE_IDLE->
							OldPetProto = get_proto_from_petinfo(OldGmPetInfo),
							case pet_evolution_db:get_pet_evolution_info(OldPetProto) of
								[] ->
									Result=?ERROR_PET_QUALITY_MAX;
								EvoluntionInfo ->
									{Silver,{NeedClass,Count}} = pet_evolution_db:get_pet_evolution_consume(EvoluntionInfo),
									if ItemClass =:= NeedClass->
										HasItem = item_util:is_has_enough_item_in_package_by_class(ItemClass,Count),
										CheckSilver = role_op:check_money(?MONEY_BOUND_SILVER,Silver),
										if
											not HasItem->
												Result=?ERROR_PET_NOT_ENOUGH_ITEM;
											not CheckSilver->
												Result=?ERROR_PET_NOT_ENOUGH_MONEY;
											true->
												{A,B} = pet_evolution_db:get_evolution_rate(EvoluntionInfo),
												case random:uniform(A) > B of
													true->
														role_op:money_change(?MONEY_BOUND_SILVER,-Silver,pet_evolution),
														role_op:consume_items_by_classid(ItemClass,Count),
														gm_logger_role:pet_evolution_log(get(roleid),PetId,OldPetProto,Silver,ItemClass,Count,failed),
														Result=?ERROR_PED_EVOLUTION_FAILED;
													false->
														Proto = pet_evolution_db:get_evolution_protoid(EvoluntionInfo),
														case check_min_take_level(Proto) of
															true->
																Result=?ERROR_PET_EVOLUTION_SUCCESS,
																role_op:money_change(?MONEY_BOUND_SILVER,-Silver,pet_evolution),
																role_op:consume_items_by_classid(ItemClass,Count),
																gm_logger_role:pet_evolution_log(get(roleid),PetId,OldPetProto,Silver,ItemClass,Count,success),
																PetProtoInfo = pet_proto_db:get_info(Proto),
																case get_changenameflag_from_mypetinfo(OldPetInfo) of
																	true->
																		Name = get_name_from_petinfo(OldGmPetInfo),
																		GmPetInfo = OldGmPetInfo;
																	false->
																		Name = pet_proto_db:get_name(PetProtoInfo),
																		GmPetInfo = set_name_to_petinfo(OldGmPetInfo,Name)
																end,
																put(gm_pets_info,lists:keyreplace(PetId, #gm_pet_info.id,get(gm_pets_info),set_proto_to_petinfo(GmPetInfo, Proto))),
																pet_util:recompute_attr(proto,{PetId,OldPetProto}),
																PetOrder = get_order_string(pet_evolution_db:get_pet_evolution_order(EvoluntionInfo)),
																RoleInfo = get(creature_info),
																RoleId = get_id_from_roleinfo(RoleInfo),
																RoleName = get_name_from_roleinfo(RoleInfo),
																ServerId = get_serverid_from_roleinfo(RoleInfo),
																PetQuality = get_quality_from_petinfo(OldGmPetInfo),
																game_rank_manager:updata_pet_rank_info(PetId,Name),
																system_broadcast(?SYSTEM_CHAT_CHAT_EVOLUTION,RoleInfo,RoleId,RoleName,ServerId,PetId,get_name_from_petinfo(OldGmPetInfo),PetQuality,PetOrder);
															false->
																Result=?ERROR_PET_CAN_NOT_TAKE
														end
												end
										end;
			   		   		  		  true->
				   						Result=?ERROR_PET_NOT_ENOUGH_ITEM
				    				end
							end;
						_->
							Result=?ERROR_PET_IS_EXPLORING
					end,
					Message = pet_packet:encode_pet_opt_error_s2c(Result),
					role_op:send_data_to_gate(Message);
				true->
					nothing
			end
	end.

get_order_string(PetOrder)->
	StringNum = lists:nth(PetOrder,[?STR_PET_ORDER_1,?STR_PET_ORDER_2,?STR_PET_ORDER_3,?STR_PET_ORDER_4,?STR_PET_ORDER_5]),
	language:get_string(StringNum).
		

%%return:
%% 	 true/false
check_min_take_level(ProtoId)->
	case pet_proto_db:get_info(ProtoId) of
		[]->
			false;
		PetProtoInfo->
			case pet_proto_db:get_min_take_level(PetProtoInfo) =< get(level) of
				true->
					true;
				false->
					false
			end
	end.

system_broadcast(SysId,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,PetOrder)->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamPet = chat_packet:makeparam(pet,{PetId,PetName,PetQuality,RoleId,RoleName,ServerId}),
	ParamPetOrder = system_chat_util:make_string_param(PetOrder),
	MsgInfo = [ParamRole,ParamPet,ParamPetOrder],
	system_chat_op:system_broadcast(SysId,MsgInfo).
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
						

				
%% pet_evolution(PetId,ItemSlot)->
%% 	case package_op:get_iteminfo_in_package_slot(ItemSlot) of
%% 		[]->
%% 			nothing;
%% 		ItemInfo->
%% 			ItemClass = package_op:get_class_from_iteminfo(ItemInfo),
%% 			OldPetInfo = pet_op:get_pet_info(PetId),
%% 			OldGmPetInfo = pet_op:get_gm_petinfo(PetId),
%% 			if 
%% 				(OldPetInfo =/= []) and (OldGmPetInfo =/= []) -> 
%% 					case get_state_from_petinfo(OldGmPetInfo) of
%% 						?PET_STATE_IDLE->
%% 							OldPetProto = get_proto_from_petinfo(OldGmPetInfo),
%% 							case pet_evolution_db:get_pet_evolution_info(OldPetProto) of
%% 								[] ->
%% 									Result=?ERROR_PET_QUALITY_MAX;
%% 								EvoluntionInfo ->
%% 									{Silver,{NeedClass,Count}} = pet_evolution_db:get_pet_evolution_consume(EvoluntionInfo),
%% 									if ItemClass =:= NeedClass->
%% 										HasItem = item_util:is_has_enough_item_in_package_by_class(ItemClass,Count),
%% 										CheckSilver = role_op:check_money(?MONEY_SILVER,Silver),
%% 										if
%% 											not HasItem->
%% 												Result=?ERROR_PET_NOT_ENOUGH_ITEM;
%% 											not CheckSilver->
%% 												Result=?ERROR_PET_NOT_ENOUGH_MONEY;
%% 											true->
%% 												{A,B} = pet_evolution_db:get_evolution_rate(EvoluntionInfo),
%% 												case random:uniform(A) > B of
%% 													true->
%% 														role_op:money_change(?MONEY_SILVER,-Silver,pet_evolution),
%% 														role_op:consume_items_by_classid(ItemClass,Count),
%% 														gm_logger_role:pet_evolution_log(get(roleid),Silver,ItemClass,Count,failed),
%% 														Result=?ERROR_PED_EVOLUTION_FAILED;
%% 													false->
%% 														NewPetId = petid_generator:gen_newid(),
%% 														Proto = pet_evolution_db:get_evolution_protoid(EvoluntionInfo),
%% 														case check_min_take_level(Proto) of
%% 															true->
%% 																Result=[],
%% 																role_op:money_change(?MONEY_SILVER,-Silver,pet_evolution),
%% 																role_op:consume_items_by_classid(ItemClass,Count),
%% 																gm_logger_role:pet_evolution_log(get(roleid),Silver,ItemClass,Count,success),
%% 																{GmPetInfo,PetInfo} = pet_op:create_petinfo_byoldinfo(NewPetId,Proto,OldPetInfo,OldGmPetInfo),
%% 																PetProtoInfo = pet_proto_db:get_info(Proto),
%% 																pet_op:add_pet_by_petinfo(PetInfo,GmPetInfo,PetProtoInfo),
%% 																pet_op:delete_pet(PetId,false),
%% 																PetName = get_name_from_petinfo(OldGmPetInfo),
%% 																{T_Power,T_HitRate,T_Criticalrate,T_Stamina}=get_talent_from_mypetinfo(PetInfo),
%% 																pet_util:compute_talent_score(NewPetId,PetName,T_Power,T_HitRate,T_Criticalrate,T_Stamina);
%% 															false->
%% 																Result=?ERROR_PET_CAN_NOT_TAKE
%% 														end
%% 												end
%% 										end;
%% 			   		   		  		  true->
%% 				   						Result=?ERROR_PET_NOT_ENOUGH_ITEM
%% 				    				end
%% 							end,
%% 							Message = pet_packet:encode_pet_opt_error_s2c(Result),
%% 							role_op:send_data_to_gate(Message);
%% 						_->
%% 							nothing
%% 					end;
%% 				true->
%% 					nothing
%% 			end
%% 	end.				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
						