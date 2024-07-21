%%% -------------------------------------------------------------------
%%% 9√Î…ÁÕ≈»´«Ú ◊¥Œø™‘¥∑¢≤º
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-12-23
%% Description: TODO: Add description to equipment_move
-module(equipment_move).

%%
%% Include files
%%
-export([equipment_move/2]).

-include("error_msg.hrl").
-include("equipment_define.hrl").
-include("equipment_up_def.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
%%
%% Exported Functions
%%

%%
%% API Functions
%%
equipment_move(FromSlot,ToSlot)->
	case package_op:get_iteminfo_in_normal_slot(FromSlot) of 
		[]->
			Errno = ?ERROR_EQUIPMENT_NOEXIST;
		FromEquip->
			case package_op:get_iteminfo_in_normal_slot(ToSlot) of
				[]->
					Errno = ?ERROR_EQUIPMENT_NOEXIST;
				ToEquip->
					FromLevel = get_level_from_iteminfo(FromEquip),
					ToLevel = get_level_from_iteminfo(ToEquip),
					FromInvent = get_inventorytype_from_iteminfo(FromEquip),
					ToInvent = get_inventorytype_from_iteminfo(ToEquip),
					if
						FromInvent=:=ToInvent->
							case check_level(FromLevel,ToLevel) of
								MoveInfo->
									Money = get_move_money(ToLevel),
									case role_op:check_money(?MONEY_BOUND_SILVER, Money) of
 										true->
												if (ToLevel>=0) and (ToLevel=<49) ->
													   Errno=[],
														FromStars = get_enchantments_from_iteminfo(FromEquip),
														FromSockets = get_socketsinfo_from_iteminfo(FromEquip),
														FromEnchant = get_enchant_from_iteminfo(FromEquip),
														role_op:money_change(?MONEY_BOUND_SILVER, -Money, lost_equip_move),
														equipment_op:change_enchantment_attr(FromSlot,0),
														equipment_op:change_enchantment_attr(ToSlot,FromStars),
														equipment_op:change_socket_attr(FromSlot,[]),
														equipment_op:change_socket_attr(ToSlot,FromSockets),
														equipment_op:change_enchant_attr(FromSlot,[]),
														equipment_op:change_enchant_attr(ToSlot,FromEnchant),
														equipment_op:recompute_equipment_attr(FromSlot,get_id_from_iteminfo(FromEquip)),
														equipment_op:recompute_equipment_attr(ToSlot,get_id_from_iteminfo(ToEquip)),
													   case equipment_op:check_is_bonding_by_info(FromEquip,ToEquip) of
																false->
																				ignor;
																	_->
																				items_op:set_item_isbonded(package_op:get_item_id_in_slot(ToSlot),1)
														end,
														Message = equipment_packet:encode_equipment_move_s2c(),
														role_op:send_data_to_gate(Message);
									  true->	   
										  [Need1|NeedItem2]=MoveInfo,
										  [Need2|_]=NeedItem2,
										  [NeedOneItemId|_]=erlang:element(1, Need1),
										  BoundStoneSlotInfos=package_op:getSlotsByItemInfo(NeedOneItemId,true),
					 						NoBoundStoneSlotInfos=package_op:getSlotsByItemInfo(NeedOneItemId,false),
											StoneSlotInfo=lists:merge(BoundStoneSlotInfos, NoBoundStoneSlotInfos),
											case StoneSlotInfo of
												[]->
													Errno=?ERROR_MISS_ITEM;
												NeedOneInfo->		
													%OneId=get_template_id_from_iteminfo(NeedOneInfo),
													%NeedItemList=get_needs_item(MoveInfo),			
															Onecount=get_one_needs_count(MoveInfo),
														{HasOneCount,ItemList}=lists:foldl(fun(ItemInfo,Acc)->
																{Num,Item}=Acc,
																if Num=:=Onecount->
																	   Acc;
																   true->
																case ItemInfo of
																	{SlotNum,ItemId,ItemCount}->
																		if Num+ItemCount<Onecount->
																			   {Num+ItemCount,Item++[ItemInfo]};
																		Num+ItemCount=:=Onecount->
																			   {Onecount,Item++[ItemInfo]};
																		Num+ItemCount>Onecount->
																			   {Onecount,Item++[{SlotNum,ItemId,Onecount-Num}]}
																		end end end end, {0,[]},StoneSlotInfo),
															HasOneItem=HasOneCount>=Onecount,
															if not HasOneItem ->
																   Errno = ?ERROR_MISS_ITEM;
															   true->
																     [NeedTwoItemId|_]=erlang:element(1, Need2),
																	 TBoundStoneSlotInfos=package_op:getSlotsByItemInfo(NeedTwoItemId,true),
					 												TNoBoundStoneSlotInfos=package_op:getSlotsByItemInfo(NeedTwoItemId,false),
																	TStoneSlotInfo=lists:merge(TBoundStoneSlotInfos, TNoBoundStoneSlotInfos),
																   case TStoneSlotInfo of
																	   []->
																		   Errno=?ERROR_MISS_ITEM;
																	   NeedTwoInfo->
																		 %  TwoId=get_template_id_from_iteminfo(NeedTwoInfo),
																	  Twocount=get_two_needs_count(MoveInfo),
														{HasTwoCount,TItemList}=lists:foldl(fun(ItemInfo,Acc)->
																{Num,Item}=Acc,
																if Num=:=Twocount->
																	   Acc;
																   true->
																case ItemInfo of
																	{SlotNum,ItemId,ItemCount}->
																		if Num+ItemCount<Twocount->
																			   {Num+ItemCount,Item++[ItemInfo]};
																		Num+ItemCount=:=Twocount->
																			   {Twocount,Item++[ItemInfo]};
																		Num+ItemCount>Twocount->
																			   {Twocount,Item++[{SlotNum,ItemId,Twocount-Num}]}
																		end end end end, {0,[]},NeedTwoInfo),
																				   HasTwoItem=HasTwoCount>=Twocount,
																				   if not HasTwoItem ->Errno = ?ERROR_MISS_ITEM;
																					  true->
																								Errno=[],
																								FromStars = get_enchantments_from_iteminfo(FromEquip),
																								FromSockets = get_socketsinfo_from_iteminfo(FromEquip),
																								FromEnchant = get_enchant_from_iteminfo(FromEquip),
																								role_op:money_change(?MONEY_BOUND_SILVER, -Money, lost_equip_move),
																								lists:foreach(fun({Slot,_,ItemCOunt})->
																													 consum_item_by_slot(Slot,ItemCOunt) end, ItemList),
																								lists:foreach(fun({Slot,_,ItemCOunt})->
																													 consum_item_by_slot(Slot,ItemCOunt) end, TItemList),
																								%role_op:consume_item(NeedOneInfo,Onecount),
																								%role_op:consume_item(NeedTwoInfo,Twocount),
																								equipment_op:change_enchantment_attr(FromSlot,0),
																								equipment_op:change_enchantment_attr(ToSlot,FromStars),
																								equipment_op:change_socket_attr(FromSlot,[]),
																								equipment_op:change_socket_attr(ToSlot,FromSockets),
																								equipment_op:change_enchant_attr(FromSlot,[]),
																								equipment_op:change_enchant_attr(ToSlot,FromEnchant),
																								equipment_op:recompute_equipment_attr(FromSlot,get_id_from_iteminfo(FromEquip)),
																								equipment_op:recompute_equipment_attr(ToSlot,get_id_from_iteminfo(ToEquip)),
																								case equipment_op:check_is_bonding_by_info(FromEquip,ToEquip) of
																									false->
																										ignor;
																									_->
																										items_op:set_item_isbonded(package_op:get_item_id_in_slot(ToSlot),1)
																								end,
																				   					Message = equipment_packet:encode_equipment_move_s2c(),
																									role_op:send_data_to_gate(Message)
																							end
																				   end
																   end
													end
												   end;
										[]->
											Errno=?ERROR_LESS_MONEY
									end;
								_->
									Errno = ?ERROR_EQUIPMENT_CANNOT_MOVE
							end;
						true->
							Errno=?ERROR_EQUIPMENT_CANNOT_MOVE
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

check_level(FromLevel,ToLevel)->
%%	Func = fun({_,Info},Acc)->
%				  if
%						Acc =:= [] ->
%					  	{FSLevel,FELevel} = element(#equipment_move.flevel,Info),
%					  	if
%							(FromLevel >= FSLevel) and (FromLevel =< FELevel) ->
%							{TSLevel,TELevel} = element(#equipment_move.tlevel,Info),
%							if
%						  		(ToLevel >= TSLevel) and (ToLevel =< TELevel) ->
%^							  		true;
%						  		true->
%							  		false
%							end;
%						true->
%							Acc
%					  end;
%					true->
%					  Acc
%				  end
%		   end,
%	ets:foldl(Func, [],?EQUIPMENT_MOVE_ETS).
	%%Ë£ÖÂ§á‰ø°ÊÅØËΩ¨Áßª<Êû´Â∞ë>
Func=fun({_,Info},Acc)->
			 if Acc=:=[]->
					{TMinLevel,TMaxLevel}=element(#equipment_move.tlevel,Info),
					if(ToLevel>=TMinLevel) and (ToLevel=<TMaxLevel)->
						element(#equipment_move.needitem,Info);
					  true->
						  Acc
					end;
				true->
					Acc
			 end
	end,
ets:foldl(Func, [], ?EQUIPMENT_MOVE_ETS).
						 
							 
						 

get_move_money(ToLevel)->
	%%Func = fun({_,Info},Acc)->
	%			   if
	%				  Acc =:= [] ->
	%				  	{FSLevel,FELevel} = element(#equipment_move.flevel,Info),
	%				  	if
	%					  	(FromLevel >= FSLevel) and (FromLevel =< FELevel) ->
	%							{_,MoveInfo}=element(#equipment_move.needmoney,Info),
	%							MoveInfo;
	%						true->
	%							Acc
	%					end;
	%				  true->
		%				Acc
	%				end
	%	   end,
	%ets:foldl(Func,[],?EQUIPMENT_MOVE_ETS).
	Func=fun({_,Info},Acc)->	%%‰øÆÊîπ„ÄäÊû´Â∞ë„Äã
				 if
					 Acc=:=[]->
						 {MinLevel,MaxLevel}=element(#equipment_move.tlevel,Info),
						 if (ToLevel>=MinLevel) and (ToLevel=<MaxLevel)->
								element(#equipment_move.needmoney,Info);
							true->
								Acc
						 end;
					 true->
						 Acc
				 end
				end,
	ets:foldl(Func, [], ?EQUIPMENT_MOVE_ETS).

get_needs_item(MoveItemList)->
	lists:foldl(fun({ItemList,Num},Acc)->
						Itemlist1=Acc,
						Itemlist1++ItemList
					end,[], MoveItemList).

get_one_needs_count([ItemOne|ItemRemain])->
	case ItemOne of
		{Items,Num}->
			Num;
		[]->
			[]
	end.
get_two_needs_count([ItemOne|ItemRemain])->
	[ItemTwo|_ItemRemain]=ItemRemain,
		case ItemTwo of
		{Items,Num}->
			Num;
		[]->
			[]
	end.
	
	consum_item_by_slot(Slot,Count)->
	case equipment_op:get_item_from_proc(Slot) of
		[]->
			nothing;
		ItemInfo->
			role_op:consume_item(ItemInfo,Count)
	end.	
				 
	


















