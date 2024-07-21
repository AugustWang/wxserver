%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-8-16
%% Description: TODO: Add description to item_identify_op
-module(item_identify_op).

%%
%% Include files
%%
-include("item_define.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("ride_pet_define.hrl").

%%
%% Exported Functions
%%
-export([process_message/1]).

-include("item_struct.hrl").
%%
%% API Functions
%%
process_message({item_identify_c2s,_,Slot,ItemSlot,Type})->
	case Type of
		?USEITEM->
			item_identify_by_item(Slot,ItemSlot);
		?USEGOLD->
			item_identify_by_gold(Slot,ItemSlot)
	end.

item_identify_by_item(Slot,ItemSlot)->
	case package_op:get_iteminfo_in_package_slot(Slot) of
		[]->
			nothing;
		ItemInfo->
			case get_class_from_iteminfo(ItemInfo) of
				?ITEM_TYPE_ITEM_IDENTIFY->
					ItemIdentifyInfo = ride_pet_db:get_item_identify_info(get_class_from_iteminfo(ItemInfo)),
					{Silver,{Class,Count}} = ride_pet_db:get_item_identify_consume(ItemIdentifyInfo),
					case package_op:get_iteminfo_in_package_slot(ItemSlot) of
						[]->
							nothing;
						UseItemInfo->
							ItemClass = package_op:get_class_from_iteminfo(UseItemInfo),
							if ItemClass=:= Class ->
								HasItem = true;
							   true->
								HasItem = false
							end,
							CheckSilver = role_op:check_money(?MONEY_BOUND_SILVER,Silver),
							if
								not HasItem->
									Error=?ERROR_IDENTIFY_NO_ITEM,
									Message = ride_pet_packet:encode_item_identify_error_s2c(Error),
									role_op:send_data_to_gate(Message); 
								not CheckSilver ->
									Error = ?ERROR_LESS_MONEY,
									Message = ride_pet_packet:encode_item_identify_error_s2c(Error),
									role_op:send_data_to_gate(Message); 
								true->
									role_op:money_change(?MONEY_BOUND_SILVER,-Silver,item_identify),
									role_op:proc_destroy_item(ItemInfo,item_identify),
									role_op:consume_item(UseItemInfo,Count),
									NormalRateList = ride_pet_db:get_item_identify_rateinfo(ItemIdentifyInfo),
									case ride_pet_util:random_value_by_rate(NormalRateList) of
										[]->
											nothing;
										ResultItem->
											ItemTempInfo = item_template_db:get_item_templateinfo(ResultItem),
											ItemQuality = item_template_db:get_qualty(ItemTempInfo),
											AttrInfo = ride_pet_db:get_attr_info(ItemQuality),
											CanDropNum = ride_pet_db:get_attr_drop_num(AttrInfo),
											DropRateList = ride_pet_db:get_drop_rate_list(AttrInfo),
											ResultAttr = ride_pet_util:random_attr_by_rate(DropRateList,CanDropNum),
											{ok,[ItemId]} = role_op:auto_create_and_put(ResultItem, 1, item_identify),
											case ResultAttr of
												[]->
													nothing;
												_->
													equipment_op:change_enchant_attr_by_itemid(ItemId,ResultAttr)
											end,
											gm_logger_role:item_identify_log(get(roleid),ResultItem,ResultAttr),
											Message = ride_pet_packet:encode_item_identify_opt_result_s2c(ResultItem),
											role_op:send_data_to_gate(Message) 
									end
							end
					end;
				Num->
					nothing
			end
	end.

item_identify_by_gold(Slot,ItemSlot)->
	nothing.
%% 	case package_op:get_iteminfo_in_package_slot(Slot) of
%% 		[]->
%% 			nothing;
%% 		ItemInfo->
%% 			case get_class_from_iteminfo(ItemInfo) of
%% 				?ITEM_TYPE_FLY_SHOES->
%% 					ItemIdentifyInfo = ride_pet_db:get_item_identify_info(get_template_id_from_iteminfo(ItemInfo)),
%% 					{{_,Gold,_},_} = ride_pet_db:get_item_identify_consume(ItemIdentifyInfo),
%% 					CheckGold = role_op:check_money(?MONEY_GOLD,Gold),
%% 					if
%% 						not  CheckGold ->
%% 							Error = ?ERROR_LESS_MONEY,
%% 							Message = ride_pet_packet:encode_item_identify_opt_result_s2c(Error),
%% 							role_op:send_data_to_gate(Message); 
%% 						true->
%% 							role_op:money_change(?MONEY_GOLD,-Gold,item_identify),
%% 							role_op:proc_destroy_item(ItemInfo,consume_up),
%% 							NormalRateList = ride_pet_db:get_item_identify_rateinfo(ItemIdentifyInfo),
%% 							case ride_pet_util:random_value_by_rate(NormalRateList) of
%% 								[]->
%% 									nothing;
%% 								ResultItem->
%% 									ItemTempInfo = item_template_db:get_item_templateinfo(ResultItem),
%% 									ItemQuality = item_template_db:get_qualty(ItemTempInfo),
%% 									AttrInfo = ride_pet_db:get_attr_info(ItemQuality),
%% 									CanDropNum = ride_pet_db:get_attr_drop_num(AttrInfo),
%% 									DropRateList = ride_pet_db:get_drop_rate_list(AttrInfo),
%% 									ResultAttr = ride_pet_util:random_attr_by_rate(DropRateList,CanDropNum),
%% 									{ok,[ItemId]} = role_op:auto_create_and_put(ResultItem, 1, item_identify),
%% 									equipment_op:change_enchant_attr_by_itemid(ItemId,ResultAttr),
%% 									ride_pet_util:system_bodcast(?SYSTEM_CHAT_ITEM_IDENTIFY,get(creature_info),ItemId)
%% 							end
%% 					end;
%% 				_->
%% 					nothing
%% 			end
%% 	end.









