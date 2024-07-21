%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(item_util).

-export([get_max_socketnum_on_item_onhands/0,
		 get_max_enchantments_on_item_onhands/0,
		 get_max_stone_level_on_item_onhands/0,
		 get_items_count_in_package/1,
		 get_items_count_onhands/1,
		 is_has_enough_item_in_package/2,
		 is_has_enough_items_onhands/1,
		 is_has_enough_item_onhands/2,
		 is_has_enough_item_in_package_by_class/2,
		 consume_items_by_tmplateid/2,
		 consume_items_by_classid/2,
		 get_enchantments_on_item_body/1
		 ]).

-export([get_role_cloth_and_arm_dispaly/0,get_cloth_and_arm_by_playeritems/1]).


-include("slot_define.hrl").
-include("item_struct.hrl").
-include("mnesia_table_def.hrl").


consume_items_by_tmplateid(TmplateId,Count)->
	role_op:consume_items(TmplateId,Count).

%% bonded first
consume_items_by_classid(ClassId,Count)->
	role_op:consume_items_by_classid(ClassId,Count).

is_has_enough_item_in_package_by_class(Class,Count)->
	get_items_count_in_package_by_class(Class)>=Count.	

get_items_count_in_package_by_class(Class)->	
	package_op:get_counts_by_class_in_package(Class).
	
%% package
is_has_enough_item_in_package(TemplateId,Count)->
	get_items_count_in_package(TemplateId) >= Count.

is_has_enough_items_onhands(ItemTempltes)->
  lists:filter(fun({TemplateId, Count})-> not is_has_enough_item_onhands(TemplateId, Count) end, ItemTempltes) =:= [].

%% package && body
is_has_enough_item_onhands(TemplateId,Count)->
	get_items_count_onhands(TemplateId)>=Count.

%% package
get_items_count_in_package(TemplateId)->
	package_op:get_counts_by_template_in_package(TemplateId).

%% package && body
get_items_count_onhands(TemplateId)->
	package_op:get_counts_onhands_by_template(TemplateId).

get_max_socketnum_on_item_onhands()->
	lists:foldl(fun(ItemId,MaxCount)->
					ItemInfo = items_op:get_item_info(ItemId),
					SocketCount = length(get_socketsinfo_from_iteminfo(ItemInfo)),
					case SocketCount > MaxCount of
						true->
							SocketCount;
						_->
							MaxCount
					end
				end,0,package_op:get_items_id_on_hands()).

get_max_enchantments_on_item_onhands()->
	lists:foldl(fun(ItemId,MaxEnchan)->
					ItemInfo = items_op:get_item_info(ItemId),
					Enchantments = get_enchantments_from_iteminfo(ItemInfo),
					case Enchantments > MaxEnchan of
						true->
							Enchantments;
						_->
							MaxEnchan
					end
				end,0,package_op:get_items_id_on_hands()).

get_max_stone_level_on_item_onhands()->
	lists:foldl(fun(ItemId,MaxLevel)->
					ItemInfo = items_op:get_item_info(ItemId),
					case get_socketsinfo_from_iteminfo(ItemInfo) of
						[]->
							MaxLevel;
						Sockets->
							lists:foldl(fun({_,StoneTmpId},CurMax)->
								if
									StoneTmpId=:=0->
										CurMax;
									true->
										TemplateInfo = item_template_db:get_item_templateinfo(StoneTmpId),
										Mylevel = item_template_db:get_level(TemplateInfo),
										if
											Mylevel>CurMax-> 
												Mylevel;
											true->
												CurMax
										end 
								end
							end,MaxLevel,Sockets)
								
					end
				end,0,package_op:get_items_id_on_hands()).

%%FASHION_SLOT,CHEST_SLOT,MAINHAND_SLOT
get_role_cloth_and_arm_dispaly()->
	FashionDisplay = get_template_id_by_slot(?FASHION_SLOT),
	IsFashionDispaly = role_private_option:get_is_fashion_dispaly(),
	if
		(FashionDisplay=/=0) and IsFashionDispaly->
			{FashionDisplay,0};
		true->
			{get_template_id_by_slot(?CHEST_SLOT),get_template_id_by_slot(?MAINHAND_SLOT)}
	end.

get_cloth_and_arm_by_playeritems(PlayerItems)->
	Cloth = 
	case lists:keyfind(?CHEST_SLOT,#playeritems.slot, PlayerItems) of
		false->
			0;
		ClothItem->
			playeritems_db:get_entry(ClothItem)
	end,
	Arm = 
	case lists:keyfind(?MAINHAND_SLOT,#playeritems.slot, PlayerItems) of
		false->
			0;
		ArmItem->
			playeritems_db:get_entry(ArmItem)
	end,
	Fashion =
		case lists:keyfind(?FASHION_SLOT,#playeritems.slot, PlayerItems) of
		false->
			0;
		FashionItem->
			playeritems_db:get_entry(FashionItem)
	end,
	if
		Fashion=/=0->
			{Fashion,0};
		true->
			{Cloth,Arm}	  
	end.
						
get_template_id_by_slot(Slot)->		
	case package_op:get_iteminfo_in_normal_slot(Slot) of
		[]->			
			0;
		ItemInfo->
			get_template_id_from_iteminfo(ItemInfo)
	end.	
	
%%鍒ゆ柇浠诲姟韬笂瑁呭鏄熺骇瑁呭鏁扮洰
get_enchantments_on_item_body(Value)->
	lists:foldl(fun(ItemId,Acc)->
						ItenInfo=items_op:get_item_info(ItemId),
						Enchantments = get_enchantments_from_iteminfo(ItenInfo),
						if Enchantments>=Value->
							   Acc+1;
						   true->
							   Acc
						end end , 0, package_op:get_body_items_id()).

%%浠诲姟闄勯瓟
get_enchant_on_item_onhands()->
	lists:foldl(fun(ItemId,Acc)->
					ItemInfo = items_op:get_item_info(ItemId),
					Enchant = get_enchant_from_iteminfo(ItemInfo),
					if Enchant=/=[]->
						   Acc+1;
					   true->
						   Acc
					end end,0,package_op:get_items_id_on_hands()).
	
	
