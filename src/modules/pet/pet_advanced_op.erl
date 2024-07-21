%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-2-26
%% Description: TODO: Add description to pet_advanced_op
-module(pet_advanced_op).
-include("pet_struct.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
-include("common_define.hrl").
-include("login_pb.hrl").
-include("system_chat_define.hrl").
-include("string_define.hrl").
%%
%% Include files
%%
-define(NITEM,13190010).%%宠物进阶丹
-define(NEEDMONEY,10000).%%进阶所需钱币
-define(ADVANCE_LUVKY,10000).%%宠物进阶祝福最大祝福值几率
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% API Functions
%%



%%
%% Local Functions
%%

pet_advance(Petid)->
	case pet_op:get_gm_petinfo(Petid) of
		[]->
					Error=?ERROR_PET_NOEXIST,
					 Message=pet_packet:encode_pet_opt_error_s2c(Error),
				   role_op:send_data_to_gate(Message);
		PetInfo->
			Step=get_social_from_petinfo(PetInfo),
			AdvanceInfo=pet_advanced_db:get_advance_info(Step),
			MyPetInfo=pet_op:get_pet_info(Petid),
			PetLucky=get_lucky_from_mypetinfo(MyPetInfo),
			if AdvanceInfo=:=[]->
				   nothing;
			   true->
				Count=pet_advanced_db:get_itemnum_from_advance_info(AdvanceInfo),
				Bounditeminfo=package_op:getSlotsByItemInfo(?NITEM,true),
				NBounditeminfo=package_op:getSlotsByItemInfo(?NITEM,false),
				Nitem=lists:merge(Bounditeminfo, NBounditeminfo),
				case Nitem of
					[]->
							Error=?ERROR_PET_NOT_ENOUGH_ITEM,
							 Message=pet_packet:encode_pet_opt_error_s2c(Error),
					  		 role_op:send_data_to_gate(Message);
					Niteminfo->
									{HasCount,ItemList}=package_op:get_need_item_info(Niteminfo,Count),
									if HasCount<Count->
												Error=?ERROR_PET_NOT_ENOUGH_ITEM,
												 Message=pet_packet:encode_pet_opt_error_s2c(Error),
					  							 role_op:send_data_to_gate(Message);
									true->
											NeedMoney=pet_advanced_db:get_needmoney_from_advance_info(AdvanceInfo),
											Hasmoney=role_op:check_money(?MONEY_BOUND_SILVER, NeedMoney),
											if not Hasmoney->
													Error=?ERROR_PET_NOT_ENOUGH_MONEY,
													    Message=pet_packet:encode_pet_opt_error_s2c(Error),
					  									 role_op:send_data_to_gate(Message);
											true->
												case pet_advanced_db:get_advance_lucky_info(Step, PetLucky) of
													[]->
															nothing;
														LuckyInfo->
															case can_advance(LuckyInfo)  of
																true->
																		role_op:money_change(?MONEY_SILVER,-NeedMoney,petadvance) ,
																		Class=get_class_from_petinfo(PetInfo),
																		Proto=get_proto_from_petinfo(PetInfo),
																		Protoid=get_pet_protoid(Step,Proto),
																		lists:foreach(fun({Slot,Id,Num})->
																							consume_items(Slot,Id,Num) end, ItemList),
																		NewGameinfo=PetInfo#gm_pet_info{proto=Protoid,social=Step+1},
																		NewMyPetInfo=MyPetInfo#my_pet_info{lucky=0},
																		pet_op:update_pet_info_all(NewMyPetInfo),
																		pet_op:update_gm_pet_info_all(NewGameinfo),
																		pet_util:recompute_attr(advance, Petid),
																		Message=pet_packet:encode_pet_advance_update_s2c(1,Petid),
																		role_op:send_data_to_gate(Message),
																		gm_logger_role:pet_advance(get(roleid),Petid,get_proto_from_petinfo(PetInfo),Step,Step+1);
															false->
																NewMyPetInfo=MyPetInfo#my_pet_info{lucky=PetLucky+1},
																pet_op:update_pet_info_all(NewMyPetInfo),
																Message=pet_packet:encode_pet_advance_update_s2c(PetLucky+1,Petid),
																role_op:send_data_to_gate(Message),
																pet_op:save_pet_to_db(Petid),
																role_op:money_change(?MONEY_SILVER,-NeedMoney,petadvance) ,
																lists:foreach(fun({Slot,Id,Num})->
																							consume_items(Slot,Id,Num) end, ItemList)
															end
												end
											end
									end
					end
		end
end.

%%自动进阶
pet_advanced_auto_init(Petid)->
	put(money,0),
	put(count,0),
	put(lucky_value,0),
	pet_advanced_auto(Petid).
pet_advanced_auto(Petid)->
		case pet_op:get_gm_petinfo(Petid) of
		[]->
					Error=?ERROR_PET_NOEXIST,
					MessageError=2,
					 Message=pet_packet:encode_pet_opt_error_s2c(Error),
				   role_op:send_data_to_gate(Message);
		PetInfo->
			Step=get_social_from_petinfo(PetInfo),
			AdvanceInfo=pet_advanced_db:get_advance_info(Step),
			MyPetInfo=pet_op:get_pet_info(Petid),
			PetLucky=get_lucky_from_mypetinfo(MyPetInfo),
			if AdvanceInfo=:=[]->
				   	MessageError=2;
			   true->
				Count=pet_advanced_db:get_itemnum_from_advance_info(AdvanceInfo),
				Bounditeminfo=package_op:getSlotsByItemInfo(?NITEM,true),
				NBounditeminfo=package_op:getSlotsByItemInfo(?NITEM,false),
				Nitem=lists:merge(Bounditeminfo, NBounditeminfo),
				case Nitem of
					[]->
							Error=?ERROR_PET_NOT_ENOUGH_ITEM,
								MessageError=1,
							 Message=pet_packet:encode_pet_opt_error_s2c(Error),
					  		 role_op:send_data_to_gate(Message);
					Niteminfo->
									{HasCount,ItemList}=package_op:get_need_item_info(Niteminfo,Count),
									if HasCount<Count->
										   		MessageError=1,
												Error=?ERROR_PET_NOT_ENOUGH_ITEM,
												 Message=pet_packet:encode_pet_opt_error_s2c(Error),
					  							 role_op:send_data_to_gate(Message);
									true->
											NeedMoney=pet_advanced_db:get_needmoney_from_advance_info(AdvanceInfo),
											Hasmoney=role_op:check_money(?MONEY_BOUND_SILVER, NeedMoney),
											if not Hasmoney->
												   	MessageError=1,
													Error=?ERROR_PET_NOT_ENOUGH_MONEY,
													    Message=pet_packet:encode_pet_opt_error_s2c(Error),
					  									 role_op:send_data_to_gate(Message);
											true->
												case pet_advanced_db:get_advance_lucky_info(Step, PetLucky) of
													[]->
														 	MessageError=2,
															Error=[];
														LuckyInfo->
															case can_advance(LuckyInfo)  of
																true->
																		MessageError=[],
																		put(lucky_value,0),
																		put(money,get(money)+NeedMoney),
																		role_op:money_change(?MONEY_SILVER,-NeedMoney,petadvance) ,
																		Class=get_class_from_petinfo(PetInfo),
																		Proto=get_proto_from_petinfo(PetInfo),
																		Protoid=get_pet_protoid(Step,Proto),
																		lists:foreach(fun({Slot,Id,Num})->
																							  put(count,get(count)+Num),
																							consume_items(Slot,Id,Num) end, ItemList),
																		NewGameinfo=PetInfo#gm_pet_info{proto=Protoid,social=Step+1},
																		NewMyPetInfo=MyPetInfo#my_pet_info{lucky=0},
																		pet_op:update_pet_info_all(NewMyPetInfo),
																		pet_op:update_gm_pet_info_all(NewGameinfo);
															false->
																MessageError=[],
																put(lucky_value,get(lucky_value)+1),
																NewMyPetInfo=MyPetInfo#my_pet_info{lucky=PetLucky+1},
																pet_op:update_pet_info_all(NewMyPetInfo),
																put(money,get(money)+NeedMoney),
																role_op:money_change(?MONEY_SILVER,-NeedMoney,petadvance) ,
																lists:foreach(fun({Slot,Id,Num})->
																					  put(count,get(count)+Num),
																							consume_items(Slot,Id,Num) end, ItemList)
															end
												end
											end
									end
					end
		end
end,
if 	MessageError=:=[]->
		pet_advanced_auto(Petid);
	true->
		GmInfo=pet_op:get_gm_petinfo(Petid),
		Result=get_social_from_petinfo(GmInfo),
		MoneyAll=get(money),
		CountAll=get(count),
		Lucky=get(lucky_value),
		Message1=pet_packet:encode_pet_auto_advance_result_s2c(MoneyAll,Petid,CountAll,Result,Lucky),
		role_op:send_data_to_gate(Message1),
		gm_logger_role:pet_advance(get(roleid),Petid,get_proto_from_petinfo(GmInfo),Result,Result),
		pet_util:recompute_attr(advance, Petid)
end.
		
	
get_pet_protoid(Step,Proto)->
	if Step>1->
			Proto+1000;
	true->
			Proto+1000*(Step+1)
	end.
		
consume_items(Slot,Id,Num)->
	case package_op:get_iteminfo_in_normal_slot(Slot) of
		[]->nothing;
			%io:format("@@@@@@@@@   no item~n",[]);
		ItemInfo->
			role_op:consume_item(ItemInfo, Num)
	end.

can_advance(LuckyInfo)->
	Rannum=random:uniform(?ADVANCE_LUVKY),
	Rate=pet_advanced_db:get_rate_from_advance_lucky(LuckyInfo),
	if Rannum=<Rate->
		   true;
	   true->
		   false
	end.
	
			
	
	