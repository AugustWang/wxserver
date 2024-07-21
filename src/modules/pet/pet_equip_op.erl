%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pet_equip_op).

-compile([
		  init_pet_equipinfo/0,get_equipinfo_by_db/1,
		  get_attr_by_equipinfo/1,
		  proc_equip_pet_item/3,
		  proc_unequip_pet_item/3
		  ]).

-compile(export_all).

-include("data_struct.hrl").
-include("common_define.hrl").
-include("skill_define.hrl").
-include("slot_define.hrl").
-include("item_define.hrl").
-include("error_msg.hrl").
-include("mnesia_table_def.hrl").
-include("pet_struct.hrl").
-include("item_struct.hrl").


init_pet_equipinfo()->
	lists:map(fun(Index)->{Index,0} end, lists:seq(?SLOT_PET_BODY_INDEX +1,?SLOT_PET_BODY_ENDEX)).

%%PetDbEquipInfo:[{Slot,ItemsId}]
get_equipinfo_by_db(PetDbEquipInfo)->
	lists:ukeymerge(1, PetDbEquipInfo, init_pet_equipinfo()).

export_for_db(MyPetInfo)->
	%get_equipinfo_from_mypetinfo(MyPetInfo).
	nothing.

get_body_items_info(EquipInfo)->
	lists:foldl(fun({_Slot,Id},ItemsInfoTmp)->
			if
				Id=/=0->
					case items_op:get_item_info(Id) of
						[]->
							ItemsInfoTmp;
						ItemInfo->
							[ItemInfo|ItemsInfoTmp]	
					end;
				true->	
					ItemsInfoTmp
			end
		end,[],EquipInfo).

get_attr_by_equipinfo(EquipInfo)->
	BodyItemsInfo = get_body_items_info(EquipInfo),
	ItemsAttr1 = lists:foldl(fun(ItemInfo,Attr)->
			case ItemInfo =/= [] of
				true ->
					Attr ++ items_op:get_item_attr(ItemInfo);
				false ->	
					Attr
			end
			end,[],BodyItemsInfo),
	case erlang:length(BodyItemsInfo) >= (?SLOT_PET_BODY_ENDEX - ?SLOT_PET_BODY_INDEX) of
		true ->				
			MinEnchant = role_op:get_item_enchantmentset(BodyItemsInfo),
			apply_pet_enchantments_changed(MinEnchant),
			ItemsAttr1 ++ role_op:get_equip_set_attr(BodyItemsInfo);
%%			ItemsAttr1 ++ role_op:get_item_enchantmentset_attr(MinLevel,MinEnchant) ++  role_op:get_equip_set_attr(BodyItemsInfo);							
		false ->			
			apply_pet_enchantments_changed(0),
			ItemsAttr1 ++ role_op:get_equip_set_attr(BodyItemsInfo)
	end.

%%[]/NewEquipInfo
proc_equip_pet_item(PetId,MyPetInfo,SlotNum)->
	ItemInfo = package_op:get_iteminfo_in_package_slot(SlotNum),
	case (MyPetInfo=:=[]) or (ItemInfo =:= []) of
		true ->					
			[];
		_->
			%OriPetEquipInfo = get_equipinfo_from_mypetinfo(MyPetInfo),
			OriPetEquipInfo=[],
			EquipSlot = get_inventorytype_from_iteminfo(ItemInfo),
			ItemId = get_id_from_iteminfo(ItemInfo),
			BaseCheck = can_equip_item(PetId,ItemInfo) and (package_op:where_slot(EquipSlot)=:=pet_body),
			{EquipSlot,OriItemId} = lists:keyfind(EquipSlot,1,OriPetEquipInfo),
			if
				BaseCheck -> 
					NewEquiInfo=
					if
						OriItemId=/=0->	%%has equip
							package_op:del_item_from_slot(SlotNum),	
							items_op:set_item_slot(ItemId,EquipSlot),
							ChangeAttrs = [role_attr:to_item_attribute({slot,EquipSlot})],
							ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(ItemId),get_highid_from_itemid(ItemId),ChangeAttrs,[]),
							%%Ori Item
							OriItemInfo = items_op:get_item_info(OriItemId),
							OriCount = get_count_from_iteminfo(OriItemInfo),
							package_op:set_item_to_slot(SlotNum,OriItemId,OriCount),
							items_op:set_item_slot(OriItemId,SlotNum),
							OriChangeAttrs = [role_attr:to_item_attribute({slot,SlotNum})],
							OriChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(OriItemId),get_highid_from_itemid(OriItemId),OriChangeAttrs,[]),
							Msg = pet_packet:encode_update_item_for_pet_s2c(PetId,[OriChangeInfo] ++ [ChangeInfo]),
							role_op:send_data_to_gate(Msg),
							%lists:keyreplace(EquipSlot,1,get_equipinfo_from_mypetinfo(MyPetInfo),{EquipSlot,ItemId});
							lists:keyreplace(EquipSlot,1,[],{EquipSlot,ItemId});
						true->			%%not equip	
							package_op:del_item_from_slot(SlotNum),	
							items_op:set_item_slot(ItemId,EquipSlot),
							ChangeAttrs = [role_attr:to_item_attribute({slot,EquipSlot})],
							ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(ItemId),get_highid_from_itemid(ItemId),ChangeAttrs,[]),
							Msg = pet_packet:encode_update_item_for_pet_s2c(PetId,[ChangeInfo]),
							role_op:send_data_to_gate(Msg),
							%lists:keyreplace(EquipSlot,1,get_equipinfo_from_mypetinfo(MyPetInfo),{EquipSlot,ItemId})
							lists:keyreplace(EquipSlot,1,[],{EquipSlot,ItemId})
					end,
					%%active overdue&&bond
					Quality = package_op:get_qualty_from_iteminfo(ItemInfo),
%% 					achieve_op:hook_on_swap_pet_equipment(Quality),
					role_op:proc_equip_changed_for_equip_by_itemid(ItemId),
					NewEquiInfo;
				true ->
					io:format("auto_equip_pet_item SlotNum ~p not pet_body ~n",[SlotNum]),
					[]
			end
	end.

%%[]/NewEquipInfo
proc_unequip_pet_item(PetId,MyPetInfo,SlotNum)->
	%OriPetEquipInfo = get_equipinfo_from_mypetinfo(MyPetInfo),
	OriPetEquipInfo=[],
	case lists:keyfind(SlotNum,1,OriPetEquipInfo) of
		{SlotNum,0}->	%%has not equip
			[];
		{SlotNum,ItemId}->
			case package_op:get_empty_slot_in_package() of
				0->
					role_op:send_data_to_gate(pet_packet:encode_pet_item_opt_result_s2c(?ERROR_PACKEGE_FULL)),
					[];
				[EmptySlot]->
					io:format("proc_unequip_pet_item SlotNum ~p EmptySlot ~p ItemId ~p ~n",[SlotNum,EmptySlot,ItemId]),
					case items_op:get_item_info(ItemId) of
						[]->
							[];
						ItemInfo->
							Count = get_count_from_iteminfo(ItemInfo),
							package_op:set_item_to_slot(EmptySlot,ItemId,Count),
							items_op:set_item_slot(ItemId,EmptySlot),
							ChangeAttrs = [role_attr:to_item_attribute({slot,EmptySlot})],
							ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(ItemId),get_highid_from_itemid(ItemId),ChangeAttrs,[]),
							Msg = pet_packet:encode_update_item_for_pet_s2c(PetId,[ChangeInfo]),
							role_op:send_data_to_gate(Msg),
							lists:keyreplace(SlotNum,1,OriPetEquipInfo,{SlotNum,0})
					end
			end;
		_->
			[]
	end.

proc_item_destroy_on_pet(MyPetInfo,ItemId)->
	 %OriPetEquipInfo = get_equipinfo_from_mypetinfo(MyPetInfo),
OriPetEquipInfo=[],
	 case lists:keyfind(ItemId, 2, OriPetEquipInfo) of
		{Slot,ItemId}-> 
	 		lists:keyreplace(Slot,1,OriPetEquipInfo,{Slot,0});
		 false->
			 OriPetEquipInfo
	 end.

can_equip_item(PetId,ItemInfo)->
	{MinLevel,MaxLevel} = get_requiredlevel_from_iteminfo(ItemInfo),
	CurLevel = get_level_from_petinfo(pet_op:get_pet_gminfo(PetId)),
	ItemClassCheck = lists:member(get_class_from_iteminfo(ItemInfo),?PET_ITEM_TYPES),
	(CurLevel >= MinLevel) and (CurLevel =< MaxLevel) and ItemClassCheck.

is_in_pet_body(MyPetInfo,ItemId)->
	%OriPetEquipInfo = get_equipinfo_from_mypetinfo(MyPetInfo),
OriPetEquipInfo=[],
	lists:keymember(ItemId,2, OriPetEquipInfo).

hook_on_pet_destroy(MyPetInfo)->
	%lists:foreach(fun(ItemInfo)->role_op:proc_destroy_item(ItemInfo,pet_release) end,get_body_items_info(get_equipinfo_from_mypetinfo(MyPetInfo))).
	lists:foreach(fun(ItemInfo)->role_op:proc_destroy_item(ItemInfo,pet_release) end,get_body_items_info([])).

apply_pet_enchantments_changed(_Enchant)->
	todo_maybe_pet_dispay.
									 
	