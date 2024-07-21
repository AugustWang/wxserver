%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-12-16
%% Description: TODO: Add description to achieve_equipment_script
-module(achieve_equipment_script).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([todo/2]).
-include("item_define.hrl").
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("pet_struct.hrl").
%%
%% API Functions
%%
todo(_AchieveId,Target)->
	[{Msg,List,Count}] = Target,
	case Msg of
		body_equipment->
			BodyItemsId = package_op:get_body_items_id(),
			MatchFun = fun(ItemId,Acc)->
							case items_op:get_item_info(ItemId) of
								[]->
									Acc;
								ItemInfo->
									Quality = get_qualty_from_iteminfo(ItemInfo),
									case lists:member(Quality, List) of
										true->
											Acc + 1;
										false->
											Acc
									end
							end
					   end,
			MatchResult = lists:foldl(MatchFun, 0, BodyItemsId),
			if
				MatchResult >= Count->
					{true,MatchResult};
				true->
					{false,MatchResult}
			end;
		target_equipment->
			Fun = fun(TargetSlot,Acc)->
						  case package_op:get_item_id_in_slot(TargetSlot) of
							  []->
								  Acc;
							  ItemId->
								  [ItemId|Acc]
						  end
				  end,
			Result = [Fun(TargetSlot,[])||TargetSlot<-List],
			case length(Result) =:= length(List) of
				true->
					{true,length(Result)};
				_->
					{false,length(Result)}
			end;
		target_arm->
			ItemId = package_op:get_item_id_in_slot(7),
			case ItemId of
				[]->
					nothing;
				_->
			ItemInfo = items_op:get_item_info(ItemId),
			Quality = get_qualty_from_iteminfo(ItemInfo),
			ItemLevel = get_level_from_iteminfo(ItemInfo),
			[TargetQ] = List,
			if
				TargetQ =:= Quality,Count =:= ItemLevel ->
					{true,1};
				true ->
					{false,0}
			end
			end;
		target_suit->
			BodyItemsId = package_op:get_body_items_id(),
			MatchResult = lists:foldl(fun(ItemId,Acc)->
											  ItemInfo = items_op:get_item_info(ItemId),
											  Suit = get_equipmentset_from_iteminfo(ItemInfo),
											  [Value] = List,
											  if
												  Suit =:= Value->
													  Acc+1;
												  true->
													  Acc
											  end end,0,BodyItemsId),
			if
				MatchResult >= Count->
					{true,Count};
				true->
					{false,MatchResult}
			end;
		pet_equipment->
			MatchResult = lists:foldl(fun(PetInfo,Result)->
											  %EquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
												EquipInfo=[],
											  EquipInfoList = pet_equip_op:get_body_items_info(EquipInfo),
											  Num = lists:foldl(fun(EquipmentInfo,Acc)->
																	  Quality = package_op:get_qualty_from_iteminfo(EquipmentInfo),
																	  case lists:member(Quality,List) of
																		  true->
																			  Acc + 1;
																		  false->
																			  Acc
																	  end
																  end,0,EquipInfoList),
											  if
												  Num >= Result ->
													  Num;
												  true->
													  Result
											  end
										end,0,get(pets_info)),
			if
				MatchResult >= Count->
					{true,MatchResult};
				true->
					{false,MatchResult}
			end;
		enchantments->
			BodyItemsId = package_op:get_body_items_id(),
			MatchFun = fun(ItemId,Acc)->
						    case items_op:get_item_info(ItemId) of
								[]->
									Acc;
								ItemInfo->
									Enchantments = get_enchantments_from_iteminfo(ItemInfo),
									case lists:member(Enchantments, List) of
										true->
											Acc + 1;
										false->
											Acc
									end
							end
					   end,
			MatchResult = lists:foldl(MatchFun, 0, BodyItemsId),
			if
				MatchResult >= Count->
					{true,MatchResult};
				true->
					{false,MatchResult}
			end;
		inlay->
			BodyItemsId = package_op:get_body_items_id(),
			MatchFun = fun(ItemId,Acc)->
							case items_op:get_item_info(ItemId) of
								[]->
									Acc;
								ItemInfo->
									SocketInfo = get_socketsinfo_from_iteminfo(ItemInfo),
									case SocketInfo of
										[]->
											Acc;
										_->
											Len = lists:foldl(fun({_,StoneTmpId},Acc1)->
															  case item_template_db:get_item_templateinfo(StoneTmpId) of
																  []->
																	  Acc1;
																  TemplateInfo->
																	  StoneLevel = item_template_db:get_level(TemplateInfo),
																	  case lists:member(StoneLevel, List) of
																		  true->
																			  Acc1+1;
																		  false->
																			  Acc1
																	  end
															  end
													  end, 0, SocketInfo),
											Acc+Len
									end
								end
					   end,
			MatchResult = lists:foldl(MatchFun, 0, BodyItemsId),
			if
				MatchResult >= Count->
					{true,MatchResult};
				true->
					{false,MatchResult}
			end;
		enchant->
			BodyItemsId = package_op:get_body_items_id(),
			MatchFun = fun(ItemId,Acc)->
							case items_op:get_item_info(ItemId) of
								[]->
									Acc;
								ItemInfo->
									ItemCless = get_class_from_iteminfo(ItemInfo),
									if ItemCless =:= ?ITEM_TYPE_RIDE ->
										   Acc;
									   true->
										   Quality = get_qualty_from_iteminfo(ItemInfo),
										   Enchant = get_enchant_from_iteminfo(ItemInfo),
										   case Enchant of
												[]->
													Acc;
												_->
													case lists:member(Quality, List) of
														true->
															Acc+1;
														false->
															Acc
													end
											end
									end
								end
					   end,
			MatchResult = lists:foldl(MatchFun, 0, BodyItemsId),
			if
				MatchResult >= Count->
					{true,MatchResult};
				true->
					{false,MatchResult}
			end;
		target_enchant->
			Fun = fun(TargetSlot,Acc)->
						  case package_op:get_iteminfo_in_normal_slot(TargetSlot) of
							  []->
								  [0|Acc];
							  ItemInfo->
								  Enchent = get_enchantments_from_iteminfo(ItemInfo),
								  [Enchent|Acc]
						  end
				  end,
			ResultEnchent = lists:foldl(Fun,[],List),
			RightItem = lists:foldl(fun(EnchantTemp,Result)->
											if
												EnchantTemp >= Count->
													[EnchantTemp|Result];
												true->
													Result
											end
										end,[],ResultEnchent),
			case length(RightItem) =:= length(List) of
				true->
					{true,length(RightItem)};
				_->
					{false,length(RightItem)}
			end;
		vip->
			case get(role_vip) of
				[]->
					nothing;
				{_,_,_,Level,_,_,_}->
					case lists:member(Level,List) of
						true->
							{true,1};
						_->
							{false,0}
					end
			end;
		pet->
			case get(pets_info) of
				[]->
					nothing;
				_->
					PetsInfo=get(pets_info),
					Result=lists:foldl(fun(PetInfo,Acc)->
											   PetId=get_id_from_mypetinfo(PetInfo),
											   GMInfo=pet_op:get_gm_petinfo(PetId),
											   PetQuality=get_quality_from_petinfo(GMInfo),
											   case lists:member(PetQuality,List) of
												   true->
													   Acc+1;
												   _->
													   Acc
											   end
									   end,0,PetsInfo),
					if
						Result>=1->
							{true,1};
						true->
							{false,0}
					end
			end;
		pet_skill->
			case get(pets_info) of
				[]->
					nothing;
				_->
					PetsInfo=get(pets_info),
					Result=lists:foldl(fun(PetInfo,ResultAcc)->
											   PetId=get_id_from_mypetinfo(PetInfo),
											   GMInfo=pet_op:get_gm_petinfo(PetId),
											   SkillList=get_skill_from_mypetinfo(PetInfo),
											   case SkillList of
												   []->
													   [0]++ResultAcc;
												   _->
													   R=lists:foldl(fun({_,_,Level},Acc)->
																			 case lists:member(Level, List) of
																				 true->
																					 Acc+1;
																				 _->
																					 Acc
																			 end
																	 end,0,SkillList),
													   [R]++ResultAcc
											   end
									   end,[],PetsInfo),
					case lists:max(Result)>=Count of
						true->
							{true,Count};
						_->
							{false,lists:max(Result)}
					end
			end;
		_->
			{other}
	end.
%%
%% Local Functions
%%

