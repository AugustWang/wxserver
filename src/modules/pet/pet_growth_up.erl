%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-1-23
%% Description: TODO: Add description to pet_growth_up
-module(pet_growth_up).
-export([pet_growth_s2c/1,pet_growth_up/2]).
-include("pet_struct.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
-include("common_define.hrl").
-include("login_pb.hrl").
-include("system_chat_define.hrl").
-include("string_define.hrl").
-define(ITEMCLASS,122).
-include("data_struct.hrl").
-include("role_struct.hrl").
-define(SUCESS,10759).
-define(FAILED,10730).

pet_growth_s2c(PetId)->
	case pet_op:get_pet_info(PetId) of
		[]->
			ERROR = ?ERROR_MISS_ITEM,
			ResultMessage = pet_packet:encode_pet_opt_error_s2c(ERROR),
			role_op:send_data_to_gate(ResultMessage);
		PetInfo->
			GamePetInfo=pet_op:get_gm_petinfo(PetId),
			Hp=get_hp_value_from_pet_info(GamePetInfo),
			Meleepower=get_meleepower_value_from_pet_info(GamePetInfo),
			Rangepower=get_rangepower_value_from_pet_info(GamePetInfo),
			Magicpower=get_magicpower_value_from_pet_info(GamePetInfo),
			Meleedefence=get_meleedefence_value_from_pet_info(GamePetInfo),
			Rangedefence=get_rangedefence_value_from_pet_info(GamePetInfo),
			Magicdefence=get_magicdefence_value_from_pet_info(GamePetInfo),
%%æˆé•¿å€¼å¢žåŠ ä¸‰ç‚¹ä¹‹åŽçš„å±žæ€§å˜åŒ–
			New_hp=	Hp+3*10,
			New_meleepower=Meleepower+3*2,%%æ”»å‡»åŠ åŒæ ·å€¼
			New_rangepower=Rangepower+3*2,
			New_magicpower=Magicpower+3*2,
			New_meleedefence=Meleedefence+3*1,
			New_rangedefence=Rangedefence+3*1,
			New_magicdefence=Magicdefence+3*1,
			Message=pet_packet:encode_pet_evolution_growthvalue_s2c(New_hp,New_meleepower,New_rangepower,New_magicpower,New_meleedefence,New_rangedefence,New_magicdefence),
			role_op:send_data_to_gate(Message)
	end.
			

	
pet_growth_up(PetId,Slot)->
	case pet_op:get_pet_info(PetId) of
		[]->
			ERROR = ?ERROR_MISS_ITEM,	
			Message=pet_packet:encode_pet_opt_error_s2c(ERROR),
			 role_op:send_data_to_gate(Message);
		PetInfo->
			GamePetInfo=pet_op:get_gm_petinfo(PetId),
			Now_growthvalue=get_growth_value_from_pet_info(GamePetInfo),
			Pet_social=get_social_from_petinfo(GamePetInfo),
			Quality=get_quality_from_petinfo(GamePetInfo),
			Step=get_social_from_petinfo(GamePetInfo),
			case pet_growth_db:get_growthup_info_from_db(Now_growthvalue) of
				[]->	nothing;
				UpInfo->
					{_,Growth_up}=pet_growth_db:get_growth_value(Step),
					Need_itemlist=pet_growth_db:get_need_itemlist_from_db(UpInfo),
						case package_op:get_iteminfo_in_normal_slot(Slot) of
							[]->	nothing;
							ItemInfo->
								ItemId=get_template_id_from_iteminfo(ItemInfo),
								case lists:member(ItemId, Need_itemlist) of
									false->
											ERROR = ?ERROR_MISS_ITEM,	
											Message=pet_packet:encode_pet_opt_error_s2c(ERROR),
					  	  					 role_op:send_data_to_gate(Message);
									true->
										HasCount=get_count_from_iteminfo(ItemInfo),
										if HasCount=:=0->
											  	   Error=?ERROR_PET_NOT_ENOUGH_ITEM,
													Message=pet_packet:encode_pet_opt_error_s2c(Error),
					  	  							 role_op:send_data_to_gate(Message);
										   true->
											   role_op:consume_item(ItemInfo, 1),
											   Add_growth=pet_growth_db:get_add_growthvalue(UpInfo),
											   New_growthvalue=Now_growthvalue+Add_growth,
											   if
												   New_growthvalue>=Growth_up->
													  NewGmInfo= set_growth_to_petinfo(GamePetInfo,Growth_up),
													 pet_op:update_gm_pet_info_all(NewGmInfo),
													  pet_util:recompute_attr(growthvalue,PetId,Growth_up-Now_growthvalue),
													  if New_growthvalue=/=Now_growthvalue->
															 Message=pet_packet:encode_pet_growup_result_s2c(PetId, ?SUCESS, Growth_up);
														 true->
															  Message=pet_packet:encode_pet_growup_result_s2c(PetId, ?FAILED, Growth_up)
													  end;
												  true->
													     NewGmInfo=set_growth_to_petinfo(GamePetInfo,New_growthvalue),
														 pet_op:update_gm_pet_info_all(NewGmInfo),
														 if  New_growthvalue>Now_growthvalue->
																  Message=pet_packet:encode_pet_growup_result_s2c(PetId, ?SUCESS, New_growthvalue),
																 pet_util:recompute_attr(growthvalue, PetId,New_growthvalue-Now_growthvalue );
															 true->
																 Message=pet_packet:encode_pet_growup_result_s2c(PetId, ?FAILED, New_growthvalue),
																 pet_util:recompute_attr(growthvalue, PetId,New_growthvalue-Now_growthvalue )
														 end
											   end,
										role_op:send_data_to_gate(Message)
										end
								end
						end
			end
		end,
	pet_growth_s2c(PetId).
