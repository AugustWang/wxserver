%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-2-28
%% Description: TODO: Add description to pet_xisui_op
-module(pet_xisui_op).
-export([pet_xisui_init/2]).


-include("pet_struct.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
-include("common_define.hrl").
-include("login_pb.hrl").
-include("system_chat_define.hrl").
-include("string_define.hrl").
-define(XISUI_HP,1).%%血量
-define(XISUI_MELEEPOWER,2).%%近攻
-define(XISUI_RANGEPOWER,3).%%远攻
-define(XISUI_MAGICPOWER,4).%%魔攻
-define(XISUI_MELEEDEFENCE,5).%%近防
-define(XISUI_RANGEDEFENCE,6).%%远防
-define(XISUI_MAGICDEFENCE,7).%%魔防
-define(XISUI_ITEM1,13170011).
-define(XISUI_ITEM2,13170021).
-define(XISUI_ITEM3,13170031).
-define(XISUI_RATE,400).
%%
%% Include files
%%

%%
%% Exported Functions
%%

%%
%% API Functions
%%



%%
%% Local Functions
%%

pet_xisui_init(PetId,UseGold)->
	Type=random:uniform(7),
	case pet_op:get_gm_petinfo(PetId) of
		[]->
		Error=?ERROR_PET_NOEXIST,
					 Message=pet_packet:encode_pet_opt_error_s2c(Error),
				   role_op:send_data_to_gate(Message);
		GameInfo->
			Quality=get_quality_from_petinfo(GameInfo),
			if Quality=:=1->
				   Itemid=?XISUI_ITEM1;
			   Quality=:=2->
				   Itemid=?XISUI_ITEM1;
			   Quality=:=3->
				   Itemid=?XISUI_ITEM2;
			   Quality=:=4->
				     Itemid=?XISUI_ITEM3;
			   true->
				   Itemid=0
			end,
			pet_xisui_c2s(Type,PetId,Itemid)
	end.
pet_xisui_c2s(?XISUI_HP,PetId,Itemid)->
	case pet_op:get_pet_info(PetId) of
			[]->
					Error=?ERROR_PET_NOEXIST,
					 Message=pet_packet:encode_pet_opt_error_s2c(Error),
				   role_op:send_data_to_gate(Message);
			Petinfo->
					Xisuiinfo=get_xisui_from_mypetinfo(Petinfo),
					Xhp=pet_packet:get_hp_xs(Xisuiinfo),
					ItemNum=((Xhp-100)+1)*2,
					Bounditeminfo=package_op:getSlotsByItemInfo(Itemid,true),
					NBounditeminfo=package_op:getSlotsByItemInfo(Itemid,false),
					%%得到slot,id,num
					Nitem=lists:merge(Bounditeminfo, NBounditeminfo),
					case Nitem of
					[]->
								Error=?ERROR_PET_UP_RESET_NEEDS_NOEXIST,
							   Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  				 role_op:send_data_to_gate(Message);
					Niteminfo->
							{HasCount,ItemList}=package_op:get_need_item_info(Nitem,ItemNum),
						if HasCount<ItemNum->
									Xmeleepower=pet_packet:get_meleepower_xs(Xisuiinfo),
									Meleepower_ItemNum=((Xmeleepower-100)+1)*2,
									Xrangepower=pet_packet:get_rangedefence_xs(Xisuiinfo),
									Rangepower_ItemNum=((Xrangepower-100)+1)*2,
									Xmagicpower=pet_packet:get_magicpower_xs(Xisuiinfo),
									Magicpower_ItemNum=((Xmagicpower-100)+1)*2,
									Xmeleedefence=pet_packet:get_meleedefence_xs(Xisuiinfo),
									Meleedefence_ItemNum=((Xmeleedefence-100)+1)*2,
									Xrangedefence=pet_packet:get_rangedefence_xs(Xisuiinfo),
									Rangedefence_ItemNum=((Xrangedefence-100)+1)*2,
									Xmagicdefence=pet_packet:get_magicdefence_xs(Xisuiinfo),
									Magicdefence_ItemNum=((Xmagicdefence-100)+1)*2,
									if HasCount>=Meleepower_ItemNum->
										   pet_xisui_c2s(?XISUI_MELEEPOWER,PetId,Itemid);
									   HasCount>=Rangepower_ItemNum->
										    pet_xisui_c2s(?XISUI_RANGEPOWER,PetId,Itemid);
									   HasCount>=Magicpower_ItemNum->
										    pet_xisui_c2s(?XISUI_MAGICPOWER,PetId,Itemid);
									   HasCount>=Meleedefence_ItemNum->
										    pet_xisui_c2s(?XISUI_MELEEDEFENCE,PetId,Itemid);
									   HasCount>=Rangedefence_ItemNum->
										   pet_xisui_c2s(?XISUI_RANGEDEFENCE,PetId,Itemid);
									   HasCount>=Magicdefence_ItemNum->
										      pet_xisui_c2s(?XISUI_MAGICDEFENCE,PetId,Itemid);
									   true->
										  Error=?ERROR_PET_NOT_ENOUGH_ITEM,
										  Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  						 role_op:send_data_to_gate(Message)
									   end;
						true->
								XisuiHpValue=get_xisui_random_value(Xhp),
								lists:foreach(fun({Slot,Id,Num})->  consume_items(Slot,Id,Num) end, ItemList),
								NewXisui=Xisuiinfo#pxs{xshpmax=XisuiHpValue},
								NewPetinfo=Petinfo#my_pet_info{xs=NewXisui},
								pet_op:update_pet_info_all(NewPetinfo),
								Message=pet_packet:encode_pet_xs_update_s2c(NewXisui, PetId),
								role_op:send_data_to_gate(Message),
								pet_util:recompute_attr(xisui, PetId)
						end
			end
	end;

pet_xisui_c2s(?XISUI_MELEEPOWER,PetId,Itemid)->
	case pet_op:get_pet_info(PetId) of
			[]->
				Error=?ERROR_PET_NOEXIST,
					 Message=pet_packet:encode_pet_opt_error_s2c(Error),
				   role_op:send_data_to_gate(Message);
			Petinfo->
					Xisuiinfo=get_xisui_from_mypetinfo(Petinfo),
					XMeleepower=pet_packet:get_meleepower_xs(Xisuiinfo),
					ItemNum=((XMeleepower-100)+1)*2,
					Bounditeminfo=package_op:getSlotsByItemInfo(Itemid,true),
					NBounditeminfo=package_op:getSlotsByItemInfo(Itemid,false),
					%%得到slot,id,num
					Nitem=lists:merge(Bounditeminfo, NBounditeminfo),
					case Nitem of
					[]->
							Error=?ERROR_PET_UP_RESET_NEEDS_NOEXIST,
							   Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  				 role_op:send_data_to_gate(Message);
					Niteminfo->
							{HasCount,ItemList}=package_op:get_need_item_info(Nitem,ItemNum),
						if HasCount<ItemNum->
									Xhp=pet_packet:get_hp_xs(Xisuiinfo),
									Hp_ItemNum=((Xhp-100)+1)*2,
									Xrangepower=pet_packet:get_rangedefence_xs(Xisuiinfo),
									Rangepower_ItemNum=((Xrangepower-100)+1)*2,
									Xmagicpower=pet_packet:get_magicpower_xs(Xisuiinfo),
									Magicpower_ItemNum=((Xmagicpower-100)+1)*2,
									Xmeleedefence=pet_packet:get_meleedefence_xs(Xisuiinfo),
									Meleedefence_ItemNum=((Xmeleedefence-100)+1)*2,
									Xrangedefence=pet_packet:get_rangedefence_xs(Xisuiinfo),
									Rangedefence_ItemNum=((Xrangedefence-100)+1)*2,
									Xmagicdefence=pet_packet:get_magicdefence_xs(Xisuiinfo),
									Magicdefence_ItemNum=((Xmagicdefence-100)+1)*2,
									if HasCount>=Hp_ItemNum->
										   pet_xisui_c2s(?XISUI_HP,PetId,Itemid);
									   HasCount>=Rangepower_ItemNum->
										    pet_xisui_c2s(?XISUI_RANGEPOWER,PetId,Itemid);
									   HasCount>=Magicpower_ItemNum->
										    pet_xisui_c2s(?XISUI_MAGICPOWER,PetId,Itemid);
									   HasCount>=Meleedefence_ItemNum->
										    pet_xisui_c2s(?XISUI_MELEEDEFENCE,PetId,Itemid);
									   HasCount>=Rangedefence_ItemNum->
										   pet_xisui_c2s(?XISUI_RANGEDEFENCE,PetId,Itemid);
									   HasCount>=Magicdefence_ItemNum->
										      pet_xisui_c2s(?XISUI_MAGICDEFENCE,PetId,Itemid);
									    true->
										   Error=?ERROR_PET_NOT_ENOUGH_ITEM,
										  Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  						 role_op:send_data_to_gate(Message)
									   end;
						true->
								XisuiValue=get_xisui_random_value(XMeleepower),
								lists:foreach(fun({Slot,Id,Num})->  consume_items(Slot,Id,Num) end, ItemList),
								NewXisui=Xisuiinfo#pxs{xsmeleepower=XisuiValue},
								NewPetinfo=Petinfo#my_pet_info{xs=NewXisui},
								pet_op:update_pet_info_all(NewPetinfo),
								Message=pet_packet:encode_pet_xs_update_s2c(NewXisui, PetId),
								role_op:send_data_to_gate(Message),
								pet_util:recompute_attr(xisui, PetId)
						end
			end
	end;


pet_xisui_c2s(?XISUI_RANGEPOWER,PetId,Itemid)->
	case pet_op:get_pet_info(PetId) of
			[]->
				Error=?ERROR_PET_NOEXIST,
					 Message=pet_packet:encode_pet_opt_error_s2c(Error),
				   role_op:send_data_to_gate(Message);
			Petinfo->
					Xisuiinfo=get_xisui_from_mypetinfo(Petinfo),
					Xrangepwoer=pet_packet:get_rangpower_xs(Xisuiinfo),
					ItemNum=((Xrangepwoer-100)+1)*2,
					Bounditeminfo=package_op:getSlotsByItemInfo(Itemid,true),
					NBounditeminfo=package_op:getSlotsByItemInfo(Itemid,false),
					%%得到slot,id,num
					Nitem=lists:merge(Bounditeminfo, NBounditeminfo),
					case Nitem of
					[]->
							Error=?ERROR_PET_UP_RESET_NEEDS_NOEXIST,
							   Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  				 role_op:send_data_to_gate(Message);
					Niteminfo->
							{HasCount,ItemList}=package_op:get_need_item_info(Nitem,ItemNum),
						if HasCount<ItemNum->
									Xhp=pet_packet:get_hp_xs(Xisuiinfo),
									Hp_ItemNum=((Xhp-100)+1)*2,
									Xmeleepower=pet_packet:get_meleepower_xs(Xisuiinfo),
									Meleepower_ItemNum=((Xmeleepower-100)+1)*2,
									Xmagicpower=pet_packet:get_magicpower_xs(Xisuiinfo),
									Magicpower_ItemNum=((Xmagicpower-100)+1)*2,
									Xmeleedefence=pet_packet:get_meleedefence_xs(Xisuiinfo),
									Meleedefence_ItemNum=((Xmeleedefence-100)+1)*2,
									Xrangedefence=pet_packet:get_rangedefence_xs(Xisuiinfo),
									Rangedefence_ItemNum=((Xrangedefence-100)+1)*2,
									Xmagicdefence=pet_packet:get_magicdefence_xs(Xisuiinfo),
									Magicdefence_ItemNum=((Xmagicdefence-100)+1)*2,
									if HasCount>=Hp_ItemNum->
										   pet_xisui_c2s(?XISUI_HP,PetId,Itemid);
									   HasCount>=Meleepower_ItemNum->
										    pet_xisui_c2s(?XISUI_RANGEPOWER,PetId,Itemid);
									   HasCount>=Magicpower_ItemNum->
										    pet_xisui_c2s(?XISUI_MAGICPOWER,PetId,Itemid);
									   HasCount>=Meleedefence_ItemNum->
										    pet_xisui_c2s(?XISUI_MELEEDEFENCE,PetId,Itemid);
									   HasCount>=Rangedefence_ItemNum->
										   pet_xisui_c2s(?XISUI_RANGEDEFENCE,PetId,Itemid);
									   HasCount>=Magicdefence_ItemNum->
										      pet_xisui_c2s(?XISUI_MAGICDEFENCE,PetId,Itemid);
									    true->
										    Error=?ERROR_PET_NOT_ENOUGH_ITEM,
										  Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  						 role_op:send_data_to_gate(Message)
									   end;
						true->
								XisuiValue=get_xisui_random_value(Xrangepwoer),
								lists:foreach(fun({Slot,Id,Num})->  consume_items(Slot,Id,Num) end, ItemList),
								NewXisui=Xisuiinfo#pxs{xsrangepower=XisuiValue},
								NewPetinfo=Petinfo#my_pet_info{xs=NewXisui},
								pet_op:update_pet_info_all(NewPetinfo),
								Message=pet_packet:encode_pet_xs_update_s2c(NewXisui, PetId),
								role_op:send_data_to_gate(Message),
								pet_util:recompute_attr(xisui, PetId)
						end
			end
	end;


pet_xisui_c2s(?XISUI_MAGICPOWER,PetId,Itemid)->
	case pet_op:get_pet_info(PetId) of
			[]->
				Error=?ERROR_PET_NOEXIST,
					 Message=pet_packet:encode_pet_opt_error_s2c(Error),
				   role_op:send_data_to_gate(Message);
			Petinfo->
					Xisuiinfo=get_xisui_from_mypetinfo(Petinfo),
					Xmagicpower=pet_packet:get_magicpower_xs(Xisuiinfo),
					ItemNum=((Xmagicpower-100)+1)*2,
					Bounditeminfo=package_op:getSlotsByItemInfo(Itemid,true),
					NBounditeminfo=package_op:getSlotsByItemInfo(Itemid,false),
					%%得到slot,id,num
					Nitem=lists:merge(Bounditeminfo, NBounditeminfo),
					case Nitem of
					[]->
								Error=?ERROR_PET_UP_RESET_NEEDS_NOEXIST,
							   Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  				 role_op:send_data_to_gate(Message);
					Niteminfo->
							{HasCount,ItemList}=package_op:get_need_item_info(Nitem,ItemNum),
						if HasCount<ItemNum->
									Xhp=pet_packet:get_hp_xs(Xisuiinfo),
									Hp_ItemNum=((Xhp-100)+1)*2,
									Xmeleepower=pet_packet:get_meleepower_xs(Xisuiinfo),
									Meleepower_ItemNum=((Xmeleepower-100)+1)*2,
									Xrangepower=pet_packet:get_rangedefence_xs(Xisuiinfo),
									Rangepower_ItemNum=((Xrangepower-100)+1)*2,
									Xmeleedefence=pet_packet:get_meleedefence_xs(Xisuiinfo),
									Meleedefence_ItemNum=((Xmeleedefence-100)+1)*2,
									Xrangedefence=pet_packet:get_rangedefence_xs(Xisuiinfo),
									Rangedefence_ItemNum=((Xrangedefence-100)+1)*2,
									Xmagicdefence=pet_packet:get_magicdefence_xs(Xisuiinfo),
									Magicdefence_ItemNum=((Xmagicdefence-100)+1)*2,
									if HasCount>=Hp_ItemNum->
										   pet_xisui_c2s(?XISUI_HP,PetId,Itemid);
									   HasCount>=Meleepower_ItemNum->
										    pet_xisui_c2s(?XISUI_MELEEPOWER,PetId,Itemid);
									   HasCount>=Rangepower_ItemNum->
										    pet_xisui_c2s(?XISUI_RANGEPOWER,PetId,Itemid);
									   HasCount>=Meleedefence_ItemNum->
										    pet_xisui_c2s(?XISUI_MELEEDEFENCE,PetId,Itemid);
									   HasCount>=Rangedefence_ItemNum->
										   pet_xisui_c2s(?XISUI_RANGEDEFENCE,PetId,Itemid);
									   HasCount>=Magicdefence_ItemNum->
										      pet_xisui_c2s(?XISUI_MAGICDEFENCE,PetId,Itemid);
									    true->
										   Error=?ERROR_PET_NOT_ENOUGH_ITEM,
										  Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  						 role_op:send_data_to_gate(Message)
									   end;
						true->
								XisuiValue=get_xisui_random_value(Xmagicpower),
								lists:foreach(fun({Slot,Id,Num})->  consume_items(Slot,Id,Num) end, ItemList),
								NewXisui=Xisuiinfo#pxs{xsmagicpower=XisuiValue},
								NewPetinfo=Petinfo#my_pet_info{xs=NewXisui},
								pet_op:update_pet_info_all(NewPetinfo),
								Message=pet_packet:encode_pet_xs_update_s2c(NewXisui, PetId),
								role_op:send_data_to_gate(Message),
								pet_util:recompute_attr(xisui, PetId)
						end
			end
	end;


pet_xisui_c2s(?XISUI_MELEEDEFENCE,PetId,Itemid)->
	case pet_op:get_pet_info(PetId) of
			[]->
			Error=?ERROR_PET_NOEXIST,
					 Message=pet_packet:encode_pet_opt_error_s2c(Error),
				   role_op:send_data_to_gate(Message);
			Petinfo->
					Xisuiinfo=get_xisui_from_mypetinfo(Petinfo),
					Xmeleedefence=pet_packet:get_meleedefence_xs(Xisuiinfo),
					ItemNum=((Xmeleedefence-100)+1)*2,
					Bounditeminfo=package_op:getSlotsByItemInfo(Itemid,true),
					NBounditeminfo=package_op:getSlotsByItemInfo(Itemid,false),
					%%得到slot,id,num
					Nitem=lists:merge(Bounditeminfo, NBounditeminfo),
					case Nitem of
					[]->
							Error=?ERROR_PET_UP_RESET_NEEDS_NOEXIST,
							   Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  				 role_op:send_data_to_gate(Message);
					Niteminfo->
							{HasCount,ItemList}=package_op:get_need_item_info(Nitem,ItemNum),
						if HasCount<ItemNum->
									Xhp=pet_packet:get_hp_xs(Xisuiinfo),
									Hp_ItemNum=((Xhp-100)+1)*2,
									Xmeleepower=pet_packet:get_meleepower_xs(Xisuiinfo),
									Meleepower_ItemNum=((Xmeleepower-100)+1)*2,
									Xrangepower=pet_packet:get_rangedefence_xs(Xisuiinfo),
									Rangepower_ItemNum=((Xrangepower-100)+1)*2,
									Xmagicpower=pet_packet:get_magicpower_xs(Xisuiinfo),
									Magicpower_ItemNum=((Xmagicpower-100)+1)*2,
									Xrangedefence=pet_packet:get_rangedefence_xs(Xisuiinfo),
									Rangedefence_ItemNum=((Xrangedefence-100)+1)*2,
									Xmagicdefence=pet_packet:get_magicdefence_xs(Xisuiinfo),
									Magicdefence_ItemNum=((Xmagicdefence-100)+1)*2,
									if HasCount>=Hp_ItemNum->
										   pet_xisui_c2s(?XISUI_HP,PetId,Itemid);
									   HasCount>=Meleepower_ItemNum->
										    pet_xisui_c2s(?XISUI_MELEEPOWER,PetId,Itemid);
									   HasCount>=Rangepower_ItemNum->
										    pet_xisui_c2s(?XISUI_RANGEPOWER,PetId,Itemid);
									   HasCount>=Magicpower_ItemNum->
										    pet_xisui_c2s(?XISUI_MAGICPOWER,PetId,Itemid);
									   HasCount>=Rangedefence_ItemNum->
										   pet_xisui_c2s(?XISUI_RANGEDEFENCE,PetId,Itemid);
									   HasCount>=Magicdefence_ItemNum->
										      pet_xisui_c2s(?XISUI_MAGICDEFENCE,PetId,Itemid);
									    true->
										    Error=?ERROR_PET_NOT_ENOUGH_ITEM,
										  Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  						 role_op:send_data_to_gate(Message)
									   end;
						true->
								XisuiValue=get_xisui_random_value(Xmeleedefence),
								lists:foreach(fun({Slot,Id,Num})->  consume_items(Slot,Id,Num) end, ItemList),
								NewXisui=Xisuiinfo#pxs{xsmeleedefence=XisuiValue},
								NewPetinfo=Petinfo#my_pet_info{xs=NewXisui},
								pet_op:update_pet_info_all(NewPetinfo),
								Message=pet_packet:encode_pet_xs_update_s2c(NewXisui, PetId),
								role_op:send_data_to_gate(Message),
								pet_util:recompute_attr(xisui, PetId)
						end
			end
	end;


pet_xisui_c2s(?XISUI_RANGEDEFENCE,PetId,Itemid)->
	case pet_op:get_pet_info(PetId) of
			[]->
				Error=?ERROR_PET_NOEXIST,
					 Message=pet_packet:encode_pet_opt_error_s2c(Error),
				   role_op:send_data_to_gate(Message);
			Petinfo->
					Xisuiinfo=get_xisui_from_mypetinfo(Petinfo),
					Xrangedefence=pet_packet:get_rangedefence_xs(Xisuiinfo),
					ItemNum=((Xrangedefence-100)+1)*2,
					Bounditeminfo=package_op:getSlotsByItemInfo(Itemid,true),
					NBounditeminfo=package_op:getSlotsByItemInfo(Itemid,false),
					%%得到slot,id,num
					Nitem=lists:merge(Bounditeminfo, NBounditeminfo),
					case Nitem of
					[]->
								Error=?ERROR_PET_UP_RESET_NEEDS_NOEXIST,
							   Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  				 role_op:send_data_to_gate(Message);
					Niteminfo->
							{HasCount,ItemList}=package_op:get_need_item_info(Nitem,ItemNum),
						if HasCount<ItemNum->
									Xhp=pet_packet:get_hp_xs(Xisuiinfo),
									Hp_ItemNum=((Xhp-100)+1)*2,
									Xmeleepower=pet_packet:get_meleepower_xs(Xisuiinfo),
									Meleepower_ItemNum=((Xmeleepower-100)+1)*2,
									Xrangepower=pet_packet:get_rangedefence_xs(Xisuiinfo),
									Rangepower_ItemNum=((Xrangepower-100)+1)*2,
									Xmagicpower=pet_packet:get_magicpower_xs(Xisuiinfo),
									Magicpower_ItemNum=((Xmagicpower-100)+1)*2,
									Xmeleedefence=pet_packet:get_meleedefence_xs(Xisuiinfo),
									Meleedefence_ItemNum=((Xmeleedefence-100)+1)*2,
									Xmagicdefence=pet_packet:get_magicdefence_xs(Xisuiinfo),
									Magicdefence_ItemNum=((Xmagicdefence-100)+1)*2,
									if HasCount>=Hp_ItemNum->
										   pet_xisui_c2s(?XISUI_HP,PetId,Itemid);
									   HasCount>=Meleepower_ItemNum->
										    pet_xisui_c2s(?XISUI_MELEEPOWER,PetId,Itemid);
									   HasCount>=Rangepower_ItemNum->
										    pet_xisui_c2s(?XISUI_RANGEPOWER,PetId,Itemid);
									   HasCount>=Magicpower_ItemNum->
										    pet_xisui_c2s(?XISUI_MAGICPOWER,PetId,Itemid);
									   HasCount>=Meleedefence_ItemNum->
										   pet_xisui_c2s(?XISUI_MELEEDEFENCE,PetId,Itemid);
									   HasCount>=Magicdefence_ItemNum->
										      pet_xisui_c2s(?XISUI_MAGICDEFENCE,PetId,Itemid);
									    true->
										  Error=?ERROR_PET_NOT_ENOUGH_ITEM,
										  Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  						 role_op:send_data_to_gate(Message)
									   end;
						true->
								XisuiValue=get_xisui_random_value(Xrangedefence),
								lists:foreach(fun({Slot,Id,Num})->  consume_items(Slot,Id,Num) end, ItemList),
								NewXisui=Xisuiinfo#pxs{xsrangedefence=XisuiValue},
								NewPetinfo=Petinfo#my_pet_info{xs=NewXisui},
								pet_op:update_pet_info_all(NewPetinfo),
								Message=pet_packet:encode_pet_xs_update_s2c(NewXisui, PetId),
								role_op:send_data_to_gate(Message),
								pet_util:recompute_attr(xisui, PetId)
						end
			end
	end;

pet_xisui_c2s(?XISUI_MAGICDEFENCE,PetId,Itemid)->
	case pet_op:get_pet_info(PetId) of
			[]->
				Error=?ERROR_PET_NOEXIST,
					 Message=pet_packet:encode_pet_opt_error_s2c(Error),
				   role_op:send_data_to_gate(Message);
			Petinfo->
					Xisuiinfo=get_xisui_from_mypetinfo(Petinfo),
					Xmagicdefence=pet_packet:get_magicdefence_xs(Xisuiinfo),
					ItemNum=((Xmagicdefence-100)+1)*2,
					Bounditeminfo=package_op:getSlotsByItemInfo(Itemid,true),
					NBounditeminfo=package_op:getSlotsByItemInfo(Itemid,false),
					%%得到slot,id,num
					Nitem=lists:merge(Bounditeminfo, NBounditeminfo),
					case Nitem of
					[]->
								Error=?ERROR_PET_UP_RESET_NEEDS_NOEXIST,
							   Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  				 role_op:send_data_to_gate(Message);
					IInfo->
							{HasCount,ItemList}=package_op:get_need_item_info(Nitem,ItemNum),
						if HasCount<ItemNum->
									Xhp=pet_packet:get_hp_xs(Xisuiinfo),
									Hp_ItemNum=((Xhp-100)+1)*2,
									Xmeleepower=pet_packet:get_meleepower_xs(Xisuiinfo),
									Meleepower_ItemNum=((Xmeleepower-100)+1)*2,
									Xrangepower=pet_packet:get_rangedefence_xs(Xisuiinfo),
									Rangepower_ItemNum=((Xrangepower-100)+1)*2,
									Xmagicpower=pet_packet:get_magicpower_xs(Xisuiinfo),
									Magicpower_ItemNum=((Xmagicpower-100)+1)*2,
									Xmeleedefence=pet_packet:get_meleedefence_xs(Xisuiinfo),
									Meleedefence_ItemNum=((Xmeleedefence-100)+1)*2,
									Xrangedefence=pet_packet:get_rangedefence_xs(Xisuiinfo),
									Rangedefence_ItemNum=((Xrangedefence-100)+1)*2,
									if HasCount>=Hp_ItemNum->
										   pet_xisui_c2s(?XISUI_HP,PetId,Itemid);
									   HasCount>=Meleepower_ItemNum->
										    pet_xisui_c2s(?XISUI_MELEEPOWER,PetId,Itemid);
									   HasCount>=Rangepower_ItemNum->
										    pet_xisui_c2s(?XISUI_RANGEPOWER,PetId,Itemid);
									   HasCount>=Magicpower_ItemNum->
										    pet_xisui_c2s(?XISUI_MAGICPOWER,PetId,Itemid);
									   HasCount>=Meleedefence_ItemNum->
										   pet_xisui_c2s(?XISUI_MELEEDEFENCE,PetId,Itemid);
									   HasCount>=Rangedefence_ItemNum->
										      pet_xisui_c2s(?XISUI_RANGEDEFENCE,PetId,Itemid);
									    true->
										    Error=?ERROR_PET_NOT_ENOUGH_ITEM,
										  Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  						 role_op:send_data_to_gate(Message)
									   end;
						true->
								XisuiValue=get_xisui_random_value(Xmagicdefence),
								lists:foreach(fun({Slot,Id,Num})->  consume_items(Slot,Id,Num) end, ItemList),
								NewXisui=Xisuiinfo#pxs{xsmagicdefence=XisuiValue},
								NewPetinfo=Petinfo#my_pet_info{xs=NewXisui},
								pet_op:update_pet_info_all(NewPetinfo),
								Message=pet_packet:encode_pet_xs_update_s2c(NewXisui, PetId),
								role_op:send_data_to_gate(Message),
								pet_util:recompute_attr(xisui, PetId)
						end
			end
	end.


%%是否可以洗髓成功并返回洗髓值
get_xisui_random_value(Value)->
	case pet_xisui_db:get_pet_xisui_rate_info(Value+1) of
			[]->
				Value;
			Xinfo->
					Rate=pet_xisui_db:get_pet_xisui_rate_from_info(Xinfo),
					RandNum=random:uniform(?XISUI_RATE),
					if RandNum =< Rate->
							Value+1;
					true->
							Value
					end
	end.
				
		
consume_items(Slot,Id,Num)->
	case package_op:get_iteminfo_in_normal_slot(Slot) of
		[]->nothing;
			%io:format("@@@@@@@@@   no item~n",[]);
		ItemInfo->
			role_op:consume_item(ItemInfo, Num)
	end.

					

