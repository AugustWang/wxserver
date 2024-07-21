%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-12-20
%% Description: TODO: Add description to equipment_relieve_seal
-module(equipment_remove_seal).

%%
%% Include files
%%
-include("error_msg.hrl").
-include("common_define.hrl").
-include("item_define.hrl").
-include("item_struct.hrl").
%%
%% Exported Functions
%%
-compile(export_all).


%%
%% API Functions
%%
equipment_remove_seal(EquipSlot)->
	case package_op:get_iteminfo_in_normal_slot(EquipSlot) of
		[]->
			Errno = ?ERROR_EQUIPMENT_NOEXIST;
		EquipInfo->
			EquipTempId = get_template_id_from_iteminfo(EquipInfo),
			case enchantments_db:get_relieve_seal_info(EquipTempId) of
				[]->
					Errno = ?ERROR_EQUIPMENT_CANT_SEAL;
				ConsumeInfo->
					Itemlist = enchantments_db:get_relieve_seal_needitem(ConsumeInfo),
					Count = enchantments_db:get_relieve_seal_needitemcount(ConsumeInfo),
					NeedMoney = enchantments_db:get_relieve_seal_needmoney(ConsumeInfo),
					NewTempId = enchantments_db:get_relieve_seal_result(ConsumeInfo),
					%%杩斿洖{SlotNum,Itemid,Count}
					[Itemlist1|Itemlist2]=Itemlist,
					BoundStoneSlotInfos=package_op:getSlotsByItemInfo(Itemlist1,true),
					 NoBoundStoneSlotInfos=package_op:getSlotsByItemInfo(Itemlist1,false),
					StoneSlotInfo=lists:merge(BoundStoneSlotInfos, NoBoundStoneSlotInfos),
					case StoneSlotInfo of
						[]->
							Errno = ?ERROR_MISS_ITEM;
						StoneIntemSlotInfo->
									{HasCount,ItemList}=lists:foldl(fun(ItemInfo,Acc)->
																{Num,Item}=Acc,
																if Num=:=Count->
																	   Acc;
																   true->
																case ItemInfo of
																	{SlotNum,ItemId,ItemCount}->
																		if Num+ItemCount<Count->
																			   {Num+ItemCount,Item++[ItemInfo]};
																		Num+ItemCount=:=Count->
																			   {Count,Item++[ItemInfo]};
																		Num+ItemCount>=Count->
																			   {Count,Item++[{SlotNum,ItemId,Count-Num}]}
																		end
																end
																end
																	end		, {0,[]},StoneSlotInfo),
									case HasCount >= Count of
										true->
											LeftNeed = 0,
											LeftItem = [],
											IsEnough = true,
											HasItem = true;
										_->
											LeftNeed = Count - HasCount,
										%	[LeftItem] = Itemlist -- [ItemId],
									%		HasItem = package_op:get_counts_by_template_in_package(LeftItem) >= LeftNeed,
											HasItem=false,
											IsEnough = false
									end,
									HasMoney = role_op:check_money(?MONEY_BOUND_SILVER,NeedMoney),
									if
										not HasItem ->
											Errno = ?ERROR_MISS_ITEM;
										not HasMoney->
											Errno = ?ERROR_LESS_MONEY;
										true->
											Errno = [],
											role_op:money_change(?MONEY_BOUND_SILVER,-NeedMoney,remove_seal),
											EquipStars = get_enchantments_from_iteminfo(EquipInfo),
											EquipSockets = get_socketsinfo_from_iteminfo(EquipInfo),
											EquipEnchant = get_enchant_from_iteminfo(EquipInfo),
											role_op:proc_destroy_item(EquipInfo,remove_seal),
											{ok,[ResultId]} = role_op:auto_create_and_put(NewTempId,1,remove_seal),
										%	if 
												%not IsEnough ->
													%role_op:consume_item(ItemInfo, HasCount),
												%	role_op:consume_items(LeftItem, LeftNeed),
												%	case get_isbonded_from_iteminfo(EquipInfo) of
													%	0->
													%		items_op:set_item_isbonded(ResultId,1);
													%	_->
												%			ignor
												%	end;
												%true->
													lists:foreach(fun({Slot,_,ItemCOunt})->
																		 consum_item_by_slot(Slot,ItemCOunt) end, ItemList),
													%role_op:consume_item(ItemInfo, Count),
													case  (BoundStoneSlotInfos=:=[]) and (get_isbonded_from_iteminfo(EquipInfo)=:=0) of
														true->
															ignor;
														_->
															items_op:set_item_isbonded(ResultId,1)
													end,
											%end,
											equipment_op:change_enchantment_attr_itemid(ResultId,EquipStars),
											equipment_op:change_socket_attr_by_itemid(ResultId,EquipSockets),
											equipment_op:change_enchant_attr_by_itemid(ResultId,EquipEnchant),
											equipment_op:recompute_equipment_attr(EquipSlot,ResultId),
											Message = equipment_packet:encode_equipment_remove_seal_s2c(),
											role_op:send_data_to_gate(Message),
											gm_logger_role:role_enchantments_item(get(roleid),EquipTempId,remove_seal,NewTempId,get(level))
									end
							end
					end
	end,
	if 
		Errno =/= []->
			Message_failed = equipment_packet:encode_equipment_riseup_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.			

consum_item_by_slot(Slot,Count)->
	case equipment_op:get_item_from_proc(Slot) of
		[]->
			nothing;
		ItemInfo->
			role_op:consume_item(ItemInfo,Count)
	end.	
				 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
