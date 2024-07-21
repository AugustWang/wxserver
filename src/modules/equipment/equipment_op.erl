%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-11-24
%% Description: TODO: Add description to equipment_op
-module(equipment_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).
-include("data_struct.hrl").
-include("equipment_up_def.hrl").
-include("equipment_up_define.hrl").
-include("error_msg.hrl").
-include("common_define.hrl").
-include("slot_define.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("system_chat_define.hrl").
-include("item_define.hrl").
-include("string_define.hrl").
-define(STONEMIX_NEED_NUM,2).

-define(BONDING,1).
-define(CARDINAL,10000).
-define(STONE_BROADCAST_QUALITY,2).
-define(EXTREMELY_PROP_COUNT,1).
-define(LEVEL_RANGE_1,1).
-define(LEVEL_RANGE_2,2).
-define(LEVEL_RANGE_3,3).
-define(LEVEL_RANGE_4,4).
%%
%% API Functions
%%
equipment_riseup(Equipment,Riseup,Protect,LuckySolts)->
	try
		case get_item_from_proc(Equipment) of 
			[]->
				throw(?ERROR_EQUIPMENT_NOEXIST);
			EquipProp->
				case get_item_from_proc(Riseup) of
					[]->
						throw(?ERROR_EQUIPMENT_RISEUP_NOEXIST);
					RiseupProp->
						OrigEnchantments = get_enchantments_from_iteminfo(EquipProp),
						if 
							OrigEnchantments =:= ?MAX_ENCHANTMENTS ->
								throw(?ERROR_EQUIPMENT_MAX);
							true -> 
								nothing
						end,
						Level = OrigEnchantments + 1,
						EquipTemplateId = get_template_id_from_iteminfo(EquipProp),
						EnchantmentInfo = enchantments_db:get_enchantments_info(Level),
						%%#enchantments{level={_,_,Level},bonuses=_Bonuses,consum=Consum,riseup=Riseupdb,successrate={Max,Success},failure=Failure,protect=Protectdb,return = set_attr = _} = EnchantmentInfo,
						Riseupdb = enchantments_db:get_enchantments_riseup(EnchantmentInfo),
						BondingState = get_isbonded(Equipment),
						%% check riseup item 
						case lists:member(get_template_id_from_iteminfo(RiseupProp),Riseupdb) of
							false->
								throw(?ERROR_EQUIPMENT_RISEUP_NOT_MATCHED);
					   		true->
								nothing
						end,
						Consum = enchantments_db:get_enchantments_consum(EnchantmentInfo),
						%%check money
						case role_op:check_money(?MONEY_BOUND_SILVER, Consum) of
							false->	
								throw(?ERROR_LESS_MONEY);
							_->
								nothing
						end,
						%%merge solts
						FinalLuckySolts = 
							lists:foldl(fun(CurSolt,SlotAcc)->
												case lists:keyfind(CurSolt,1,SlotAcc) of
													false->
														[{CurSolt,1}|SlotAcc];
													{_,NumAcc}->
														lists:keyreplace(CurSolt,1,SlotAcc,{CurSolt,NumAcc+1})
												end
										end,[],LuckySolts),
						%% check  and consume lucky item
						LuckyItems =  enchantments_db:get_enchantments_lucky(EnchantmentInfo),
						{NewBondingState,LuckyAddRate} = lists:foldl(fun({PacketSlot,TotalNum},{BondingAcc,RateAcc})->
												case get_item_from_proc(PacketSlot) of
													[]->
														throw(?ERROR_MISS_ITEM);
													PacketItemInfo->
														ItemProtoId = get_template_id_from_iteminfo(PacketItemInfo),
														case lists:member(ItemProtoId, LuckyItems) of
															true->
																nothing;
															_->
																throw(?ERROR_MISS_ITEM)
														end,															
														CurCount = get_count_from_iteminfo(PacketItemInfo),
														if
															TotalNum > CurCount->
																throw(?ERROR_MISS_ITEM);
															true->
																nothing
														end,
														AddRate = enchantments_db:get_enchantments_lucky_rate_by_templateid(ItemProtoId)*TotalNum,
														if
															AddRate =:=  0->
																throw(?ERROR_MISS_ITEM);
															true->
																NewRateAcc = RateAcc + AddRate,
																if
																	BondingAcc =:= 1->
																		NewBondingAcc = BondingAcc;
																	true->
																		NewBondingAcc = get_isbonded(PacketSlot)
																end,														
																{NewBondingAcc,NewRateAcc}
														end	
												end						
										end,{BondingState,0},FinalLuckySolts),
						%% check  and set bonding 
						if
							NewBondingState =:= 1->
								if
									BondingState =/= NewBondingState ->
										items_op:set_item_isbonded(get_item_id(Equipment), 1);
									true->
										nothing
								end;
							true->
								check_bonding(Equipment,[Riseup,Protect])
						end,
						%% money consume
						role_op:money_change(?MONEY_BOUND_SILVER, -Consum, lost_enchantment),
						%% item consume
						consume_item(Riseup),
						lists:foreach(fun({PacketSlot,TotalCount})->
											consume_item(PacketSlot,TotalCount)
											end, FinalLuckySolts),
						%%success rate
						{MaxRate,SuccessRate} = enchantments_db:get_enchantments_successrate(EnchantmentInfo),
						RandomRate = random:uniform(MaxRate),
						case check_role_guild_contribution() of
							true->
								GuildAdditong =  guild_util:get_guild_smith_addation();
							_->
								GuildAdditong =  0
						end,
						VipAddition = vip_op:get_addition_with_vip(enchantment),
						FinalSuccess = erlang:trunc(((SuccessRate + LuckyAddRate) * (1+GuildAdditong/100))+VipAddition),
						Protectdb = enchantments_db:get_enchantments_protect(EnchantmentInfo),
						if 
							FinalSuccess >= RandomRate ->
								case get_item_from_proc(Protect) of
										[]->[];
										ProtectProp->
											case lists:member(get_template_id_from_iteminfo(ProtectProp), Protectdb) of
												false->[];
												true->
													consume_item(Protect)
											end
								end,
								change_enchantment_attr(Equipment,Level),
								recompute_equipment_attr(Equipment,get_id_from_iteminfo(EquipProp)),
								role_fighting_force:hook_on_change_role_fight_force(),
								hook_onbody_achieve_update(enchantments,Equipment,Level),
								role_op:async_write_to_roledb(),
								items_op:save_to_db(),
								Message = equipment_packet:encode_equipment_riseup_s2c(1, Level),
								role_op:send_data_to_gate(Message),
								quest_op:update(enchantments,Level),
								quest_op:update({equipment_enchantments,Level}),
								gm_logger_role:role_enchantments_item(get(roleid),EquipTemplateId,star,Level,get(level)),								
								%% system broad 
								case enchantments_db:get_enchantments_successsysbrd(EnchantmentInfo) of
									[]->
										nothing;
									SysBrdId->
										system_bodcast(SysBrdId,get(creature_info),Equipment,Level)
								end,
								case package_op:where_slot(Equipment) of
									body->
										_Inventory = get_inventorytype_from_iteminfo(EquipProp),
										%%goals_op:role_attr_update(),%%
										%%goals_op:goals_update({target_enchant},[Inventory]),%%@@wb20130311
										%%achieve_op:role_attr_update(),
										%%achieve_op:achieve_update({target_enchant},[Inventory]),
										open_service_activities:enchantment_equipment();%%@@wb20130409开服活动：装备升星
									D->
										ignor
								end;
							true->
								Failure = enchantments_db:get_enchantments_failure(EnchantmentInfo),
								gm_logger_role:role_enchantments_item(get(roleid),EquipTemplateId,star_failed,Level,get(level)),
								case get_item_from_proc(Protect) of
									[]->
										if 
											Failure > 0,Failure=/=OrigEnchantments ->
												change_enchantment_attr(Equipment,Failure),
												recompute_equipment_attr(Equipment,get_id_from_iteminfo(EquipProp)),
												role_fighting_force:hook_on_change_role_fight_force(),
												Message = equipment_packet:encode_equipment_riseup_s2c(2, Failure);
											true->
												Message = equipment_packet:encode_equipment_riseup_s2c(3, OrigEnchantments)
										end,
										%% system broad 
										case enchantments_db:get_enchantments_faildsysbrd(EnchantmentInfo) of
											[]->
												nothing;
											SysBrdId->
												system_bodcast(SysBrdId,get(creature_info),Equipment,Level,Failure)
										end;
									ProtectProp->
										case lists:member(get_template_id_from_iteminfo(ProtectProp), Protectdb) of
											false->
												if 
													Failure > 0,Failure=/=OrigEnchantments ->
														change_enchantment_attr(Equipment,Failure),
														recompute_equipment_attr(Equipment,get_id_from_iteminfo(EquipProp)),
														role_fighting_force:hook_on_change_role_fight_force(),
														Message = equipment_packet:encode_equipment_riseup_s2c(2, Failure);
													true->
														Message = equipment_packet:encode_equipment_riseup_s2c(3, OrigEnchantments)
												end;	   
					   						true->
												consume_item(Protect),
												%%
												%%proc return item
												%%
												Message = equipment_packet:encode_equipment_riseup_s2c(3, OrigEnchantments)
										end,
										%% system broad 
										case enchantments_db:get_enchantments_faildsysbrdwithprotect(EnchantmentInfo) of
											[]->
												nothing;
											SysBrdId->
												system_bodcast(SysBrdId,get(creature_info),Equipment,Level)
										end
								end,
								role_op:send_data_to_gate(Message),
								case enchantments_db:get_enchantments_return(EnchantmentInfo) of
									[]->
										nothing;
									ReturnItems->
										MailTitle = language:get_string(?STR_EQUIPMENT_RISEUP_RETURN_MAIL_TITLE),
										MailFormat = language:get_string(?STR_EQUIPMENT_RISEUP_RETURN_MAIL_CONTENT),
										MyName = get_name_from_roleinfo(get(creature_info)),
										lists:foreach(fun({SendItemProto,SendItemCount})->
																	%%check packet  
																	case role_op:auto_create_and_put(SendItemProto,SendItemCount,riseup_back) of
																		{ok,_}->
																			nothing;
																		_->
																			case item_template_db:get_item_templateinfo(SendItemProto) of
																				[]->
																					SendItemName = [];
																				SendItemInfo->
																					SendItemName = item_template_db:get_name(SendItemInfo)
																			end,
																			MailContent = util:sprintf(MailFormat,[SendItemName,SendItemCount]),
																			gm_op:gm_send_rpc(MyName,MyName,MailTitle,MailContent,SendItemProto,SendItemCount,0)	
																	end
															  end,ReturnItems)
								end
						end
				end
		end
	catch
		E:R->
			case E of
				throw->
					Message_failed = equipment_packet:encode_equipment_riseup_failed_s2c(R),
					role_op:send_data_to_gate(Message_failed);
				_->
					slogger:msg("~p equipment_riseup role ~p E ~p R ~p S ~p \n",[?MODULE,get(roleid),E,R,erlang:get_stacktrace()])	
			end
	end.	

gm_equipment_riseup(Slot,Level)->
	case get_item_from_proc(Slot) of 
		[]->
			nothing;
		EquipProp->
			change_enchantment_attr(Slot,Level),
			recompute_equipment_attr(Slot,get_id_from_iteminfo(EquipProp)),
			role_fighting_force:hook_on_change_role_fight_force(),
			hook_onbody_achieve_update(enchantments,Slot,Level),
			role_op:async_write_to_roledb(),
			items_op:save_to_db(),
			quest_op:update(enchantments,Level),
			open_service_activities:enchantment_equipment()%%@@wb20130409开服活动：装备升星
	end.

system_bodcast(SysId,RoleInfo,Slot,Num) ->   
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamEquipment = system_chat_util:make_equipment_param(Slot),
	ParamInt = system_chat_util:make_int_param(Num),
	MsgInfo = [ParamRole,ParamEquipment,ParamInt],
	system_chat_op:system_broadcast(SysId,MsgInfo).

system_bodcast(SysId,RoleInfo,StoneId) ->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamItem = system_chat_util:make_item_param(StoneId),
	MsgInfo = [ParamRole, ParamItem],
	system_chat_op:system_broadcast(SysId,MsgInfo).

system_bodcast(SysId,RoleInfo,Slot,Level,Failure)->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamEquipment = system_chat_util:make_equipment_param(Slot),
	ParamInt1 = system_chat_util:make_int_param(Level),
	ParamInt2 = system_chat_util:make_int_param(Failure),
	MsgInfo = [ParamRole,ParamEquipment,ParamInt1,ParamInt2],
	system_chat_op:system_broadcast(SysId,MsgInfo).

system_bodcast_equipment(SysId,RoleInfo,Slot) ->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamEquipment = system_chat_util:make_equipment_param(Slot),
	MsgInfo = [ParamRole, ParamEquipment],
	system_chat_op:system_broadcast(SysId,MsgInfo).

system_bodcast_upgrade(SysId,RoleInfo,OldEquipmentInfo,EquipmentId2) ->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
%%	ParamItem1 = chat_packet:makeparam_by_equipid(EquipmentId1),
	ParamItem2 = chat_packet:makeparam_by_equipid(EquipmentId2),
	MsgInfo = [ParamRole,OldEquipmentInfo,ParamItem2],
	system_chat_op:system_broadcast(SysId,MsgInfo).

equipment_inlay(Equipment,Inlay,SockNum)->
	case get_item_from_proc(Equipment) of 
		[]->
			Errno = ?ERROR_EQUIPMENT_NOEXIST;
		EquipProp->
			case get_item_from_proc(Inlay) of
				[]->
					Errno = ?ERROR_EQUIPMENT_INLAY_NOEXIST;
				InlayProp->
					EquipLevel = get_level_from_iteminfo(EquipProp),
					EquipClass = get_class_from_iteminfo(EquipProp),
					OrigSocketsInfo = get_socketsinfo_from_iteminfo(EquipProp),
					IsSocketEmpty = lists:member({SockNum,0}, OrigSocketsInfo),
					case enchantments_db:get_inlay_info(get_item_level_class(EquipLevel,EquipClass)) of
						[]->
							Errno = ?ERRNO_NPC_EXCEPTION;
						InlayInfo->
							#inlay{level={_,_,_Level},
								   type=StoneTypeList,
								   stonelevel=StoneLeveldb} = InlayInfo,
							StoneTemplateId = get_template_id_from_iteminfo(InlayProp),
							StoneType = list_to_integer(string:sub_string(integer_to_list(StoneTemplateId),5,6)),
							StoneLevel = get_level_from_iteminfo(InlayProp),
							IsTypeMatched = lists:member(StoneType, StoneTypeList),
					IsSameStone = check_same_stone(StoneTemplateId,OrigSocketsInfo),
					case IsSocketEmpty of
						true->
							case IsTypeMatched of
								true->
									case IsSameStone of
										true->
										if 
										StoneLeveldb >= StoneLevel->
											Errno=[],
											check_bonding(Equipment,[Inlay]),
											NewSocketsInfo = lists:keyreplace(SockNum,1,OrigSocketsInfo,{SockNum,StoneTemplateId}),
  											change_socket_attr(Equipment,NewSocketsInfo),
											recompute_equipment_attr(Equipment,get_id_from_iteminfo(EquipProp)),
											role_fighting_force:hook_on_change_role_fight_force(),
											hook_onbody_achieve_update(inlay,Equipment,[0,0]),
											consume_item(Inlay),
											role_op:async_write_to_roledb(),
 											items_op:save_to_db(),
 											Message = equipment_packet:encode_equipment_inlay_s2c(),
 											role_op:send_data_to_gate(Message),
%% 											achieve_op:achieve_update({inlay}, [get_template_id_from_iteminfo(EquipProp)], StoneLevel),
											quest_op:update(inlay,StoneLevel),
											EquipTemplateId = get_template_id_from_iteminfo(EquipProp),
											gm_logger_role:role_enchantments_item(get(roleid),EquipTemplateId,socket,NewSocketsInfo,get(level));
										true->
											Errno=?ERROR_EQUIPMENT_INLAY_LEVEL_NOT_MATCHED
										end;
										false->
											Errno=?ERROR_EQUIPMENT_STONE_TYPE_REPEAT
									end;
								false->
									Errno=?ERROR_EQUIPMENT_INLAY_TYPE_NOT_MATCHED
							end;
						false->
							Errno=?ERROR_EQUIPMENT_CANT_INLAY
					end	
					end
			end
	end,
	if 
		Errno =/= []->
			Message_failed = equipment_packet:encode_equipment_inlay_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

equipment_stone_remove(Equipment,Remove,SockNum)->
	%case get_item_from_proc(Remove) of
	%%	[]->
		%	Errno=?ERROR_EQUIPMENT_REMOVE_NOEXIST;
	%	RemoveProp->
	%		RemoveTempID = get_template_id_from_iteminfo(RemoveProp),
	case get_item_from_proc(Equipment) of 
		[]->
			Errno = ?ERROR_EQUIPMENT_NOEXIST;
		EquipProp->
			EquipLevel = get_level_from_iteminfo(EquipProp),
			EquipClass = get_class_from_iteminfo(EquipProp),
			OrigSocketsInfo = get_socketsinfo_from_iteminfo(EquipProp),
			case lists:keyfind(SockNum,1,OrigSocketsInfo) of
				false->
					Errno=?ERROR_EQUIPMENT_SOCKET_NOEXIST;
				SocketInfo ->
					{_,StoneTempId} = SocketInfo,
					if StoneTempId =/= 0 ->
						case package_op:can_added_to_package(StoneTempId,1) of
							0 -> %% full bag
								Errno=?ERROR_EQUIPMENT_REMOVE_PACKAGE_FULL;
							_OK ->
								InlayInfo = enchantments_db:get_inlay_info(get_item_level_class(EquipLevel,EquipClass)),
								#inlay{level={_,_,_Level},remove=Removedb} = InlayInfo,
								%case lists:member(RemoveTempID,Removedb) of
								%	false->
									%	Errno=?ERROR_EQUIPMENT_REMOVE_NOEXIST;
									%true->	
										case role_op:auto_create_and_put(StoneTempId, 1, removestone) of
											full ->
												Errno=?ERROR_EQUIPMENT_REMOVE_PACKAGE_FULL;
											{ok,_} ->
												Errno=[],
												NewSocketsInfo = lists:keyreplace(SockNum,1,OrigSocketsInfo,{SockNum,0}),
												change_socket_attr(Equipment,NewSocketsInfo),
												recompute_equipment_attr(Equipment,get_id_from_iteminfo(EquipProp)),
												role_fighting_force:hook_on_change_role_fight_force(),
												EquipTemplateId = get_template_id_from_iteminfo(EquipProp),
												gm_logger_role:role_enchantments_item(get(roleid),EquipTemplateId,socket,NewSocketsInfo,get(level)),
												consume_item(Remove),
												role_op:async_write_to_roledb(),
 												items_op:save_to_db(),
												
 												Message = equipment_packet:encode_equipment_stone_remove_s2c(),
 												role_op:send_data_to_gate(Message)		   			   
										end
							%	end
						end;
					   true->
						   Errno=?ERROR_EQUIPMENT_STONE_NOEXIST
					end
			end
	%end
	end,
	if 
		Errno =/= []->
			Message_failed = equipment_packet:encode_equipment_stone_remove_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.


%%单一合成功能 by zhangting
equipment_stonemix(StoneList)->
	NumRequire=length(StoneList),
    RandomRate = 
	case enchantments_db:get_stonemix_rateinfo(NumRequire) of 
	    []->?CARDINAL;
		 Stonemix_rateinfo -> element(#stonemix_rateinfo.rate,Stonemix_rateinfo)
	end,	
	{Result1,ResultStoneId_ErrNo,Used_stone,Money}=equipment_stonemix_public(StoneList,RandomRate),
	role_op:consume_item_buff_do(),  
	if Result1=:=ok ->
		 ResultStoneInfo = item_template_db:get_item_templateinfo(ResultStoneId_ErrNo), 
		 ResultStoneQuality = item_template_db:get_qualty(ResultStoneInfo),
		 case ResultStoneQuality >= ?STONE_BROADCAST_QUALITY of
			 true->
				 system_bodcast(?SYSTEM_CHAT_STONEMIX,get(creature_info),ResultStoneId_ErrNo);
			 false->
				 nothing
		 end, 
	     Msg = equipment_packet:encode_equipment_stonemix_s2c(ResultStoneId_ErrNo),
		 role_op:send_data_to_gate(Msg);
	true->
		Message = equipment_packet:encode_equipment_stonemix_failed_s2c(ResultStoneId_ErrNo),
		role_op:send_data_to_gate(Message)
   end.
	
	

%%[{slot1,count1},{slot2,count2},{slot3,count3}] 批量合成 new interface  comment by zhangting
equipment_stonemix_batch(StoneSlot,NumRequire,NumMix)->
	RandomRate = 
	case enchantments_db:get_stonemix_rateinfo(NumRequire) of 
	   []->?CARDINAL;
		Stonemix_rateinfo -> element(#stonemix_rateinfo.rate,Stonemix_rateinfo)
	end,		
    StoneItemInfo =get_item_from_proc(StoneSlot),
	 TmpId=element(#item_info.template_id,StoneItemInfo),
	 %%返回{SlotNum,Itemid,Count}
    BoundStoneSlotInfos=package_op:getSlotsByItemInfo(TmpId,true),
	 NoBoundStoneSlotInfos=package_op:getSlotsByItemInfo(TmpId,false),
	StoneSlotInfos=lists:merge(BoundStoneSlotInfos, NoBoundStoneSlotInfos),
	StoneSlotInfos1 =
	lists:foldl(fun({SlotNum,Itemid,Count},Acc0)->
		  lists:append(Acc0,lists:duplicate(Count,{Itemid,SlotNum,1}))
	end,[],StoneSlotInfos), 
	StoneSlotInfos2=list_util:split(NumRequire,StoneSlotInfos1),
	{All_times1,Succ_times1,Fau_times1,Used_stones1,Moneys1,ResultStoneIds1} = 
	lists:foldl(fun(StoneList,{All_times,Succ_times,Fau_times,Used_stones,Moneys,ResultStoneIds})->
		 if 	All_times>=NumMix ->		{All_times,Succ_times,Fau_times,Used_stones,Moneys,ResultStoneIds};
		 true->
			  {Result1,ResultStoneId_ErrNo,Used_stone,Money}=equipment_stonemix_public(StoneList,RandomRate),
			  if Result1=:=ok ->
					{All_times+1,Succ_times+1,Fau_times,Used_stones+Used_stone,Moneys+Money,[ResultStoneId_ErrNo|ResultStoneIds]};
			  true->
	              {All_times+1,Succ_times,Fau_times+1,Used_stones+Used_stone,Moneys+Money,ResultStoneIds}
	         end
		 end	 		
	end,{0,0,0,0,0,[]},StoneSlotInfos2),	
	role_op:consume_item_buff_do(),  
	
	if ResultStoneIds1 =:= [] ->nothing;
	true->
		 ResultStoneInfo = item_template_db:get_item_templateinfo(hd(ResultStoneIds1)), 
		 ResultStoneQuality = item_template_db:get_qualty(ResultStoneInfo),
		 case ResultStoneQuality >= ?STONE_BROADCAST_QUALITY of
			 true->
				 system_bodcast(?SYSTEM_CHAT_STONEMIX,get(creature_info),hd(ResultStoneIds1),Succ_times1);
			 false->
				 nothing
		 end,
	[ResultStoneIds3|ResultStoneIds4]=ResultStoneIds1,
	  Msg = equipment_packet:encode_equipment_stonemix_s2c(ResultStoneIds3),
		 role_op:send_data_to_gate(Msg)
   end.
	
	%%Msg = equipment_packet:encode_equipment_stonemix_bat_result_s2c({All_times1,Succ_times1,Fau_times1,Used_stones1,Moneys1,ResultStoneIds1}),	
    %%Msg = equipment_packet:encode_equipment_stonemix_bat_result_s2c([Succ_times1,Fau_times1,Used_stones1,Moneys1]),	
   %% Msg = equipment_packet:encode_equipment_stonemix_bat_result_s2c(Succ_times1,Fau_times1,Used_stones1,Moneys1),	
	%%slogger:msg("equipment_op:equipment_stonemix_batch zhangting 20120719 Msg:~p  ~n",[Msg]),	
	%%role_op:send_data_to_gate(Msg).
	
	
	
%%[{slot1,count1},{slot2,count2},{slot3,count3}]  old interface  comment by zhangting
equipment_stonemix_public(StoneList,RandomRate)->
    %%slogger:msg("equipment_op:equipment_stonemix zhangting 20120715  StoneList:~p  ~n",[StoneList]),
	StoneMixInfo = lists:foldl(fun({_,StoneSlot,Count},{IsBondList,TotleCount,StoneType,Flag,StoneSlotInfo})->
								  		StoneInfo =get_item_from_proc(StoneSlot),
									%%	slogger:msg("equipment_op:equipment_stonemix_public zhangting 20120715 StoneInfo:~p StoneList:~p  ~n"
												%%   ,[StoneInfo,StoneList]),
						  				if 
							  				StoneInfo =:= [] ->
								  				{IsBondList,TotleCount,StoneType,Flag,StoneSlotInfo};
					    	  				true ->
												if StoneSlotInfo =:= []->
													   NewStoneSlotInfo = [{StoneSlot,Count}|StoneSlotInfo];
												   true->
													   case lists:keyfind(StoneSlot,1,StoneSlotInfo) of
														   false->
															   NewStoneSlotInfo = [{StoneSlot,Count}|StoneSlotInfo];
														   {_,OldCount}->
															   NewStoneSlotInfo = lists:keyreplace(StoneSlot,1,StoneSlotInfo,{StoneSlot,Count+OldCount})
													   end
												end,
												IsBond = get_isbonded_from_iteminfo(StoneInfo),
								  				Type = get_socket_type_from_iteminfo(StoneInfo),
												if StoneType =/= 0 ->
													   if Type =:= StoneType ->
															  {[IsBond|IsBondList],Count+TotleCount,Type,true,NewStoneSlotInfo};
														  true ->
															  {[IsBond|IsBondList],Count+TotleCount,Type,false,NewStoneSlotInfo}
													   end;
												   true ->
													   {[IsBond|IsBondList],Count+TotleCount,Type,true,NewStoneSlotInfo}
												end
						  				end
									end,{[],0,0,false,[]},StoneList),

	{IsBondList,TotleCount,StoneType,Flag,StoneSlotInfo} = StoneMixInfo,
	IsenoughStone = lists:map(fun({Slot,Count})->
									  StoneInfo =get_item_from_proc(Slot),
									  StoneCount = items_op:get_count_from_iteminfo(StoneInfo),
									  if StoneCount >= Count ->
											 true;
										 true->
											 false
									  end
								end,StoneSlotInfo),
	StoneCountFlag = lists:member(false, IsenoughStone),
	case Flag of
		false ->
			Result = {fault,?ERROR_NOT_SAME_STONE,0,0};
		true ->
			case StoneCountFlag of
				false->
					StonemixInfo = enchantments_db:get_stonemix_info(StoneType),
					Silver = enchantments_db:get_stonemix_consume_silver(StonemixInfo),
					[ResStoneId,ResBondStoneId] = enchantments_db:get_stonemix_result(StonemixInfo),
				
					if TotleCount >= ?STONEMIX_NEED_NUM ->
		   				case role_op:check_money(?MONEY_BOUND_SILVER,Silver) of
			   				true ->
				   				case package_op:get_empty_slot_in_package() of
					   				0 ->
										Result = {fault,?ERROR_PACKEGE_FULL,0,0};
					   				_ ->
										role_op:money_change(?MONEY_BOUND_SILVER,-Silver,equipment_stonemix),
										lists:foreach(fun({_,StoneSlot,Count})->
												 			case get_item_from_proc(StoneSlot) of
													 			[]->
														 			nothing;
													 			StoneInfo ->
														 			role_op:consume_item_buff(StoneInfo,Count)
												 			end
														end,StoneList),
						   				case random:uniform(?CARDINAL) > RandomRate of
							   				true ->
												Result = {fault,?ERROR_EQUIPMENT_STONEMIX_FAILED,length(StoneList),Silver};
							   				_ ->
												
				   	   			   				case lists:member(?BONDING,IsBondList) of
			   										true ->
				   										ResultStoneId = ResBondStoneId;
			   										false ->
				   										ResultStoneId = ResStoneId
		   										end,
												role_op:auto_create_and_put(ResultStoneId,1,equipment_stonemix),
                                          Result = {ok,ResultStoneId,length(StoneList),Silver}
				   						end
				   				end;
							false ->
								Result = {fault,?ERROR_LESS_MONEY,length(StoneList),0}
						end;
			  		  true ->
				  		Result = {fault,?ERROR_EQUIPMENT_STONEMIX_LESS_COUNT,length(StoneList),0}
					end;
				true->
					Result = {fault,?ERROR_EQUIPMENT_STONEMIX_LESS_COUNT,length(StoneList),0}
			end
	end,
	Result.
	
	

%%[{slot1,count1},{slot2,count2},{slot3,count3}]  old interface  comment by zhangting
equipment_stonemix_old(StoneList)->
   %%slogger:msg("equipment_op:equipment_stonemix zhangting 20120715  StoneList:~p  ~n",[StoneList]),
	StoneMixInfo = lists:foldl(fun({_,StoneSlot,Count},{IsBondList,TotleCount,StoneType,Flag,StoneSlotInfo})->
								  		StoneInfo =get_item_from_proc(StoneSlot),
										slogger:msg("equipment_op:equipment_stonemix zhangting 20120715 StoneInfo:~p StoneList:~p  ~n"
												   ,[StoneInfo,StoneList]),
						  				if 
							  				StoneInfo =:= [] ->
								  				{IsBondList,TotleCount,StoneType,Flag,StoneSlotInfo};
					    	  				true ->
												if StoneSlotInfo =:= []->
													   NewStoneSlotInfo = [{StoneSlot,Count}|StoneSlotInfo];
												   true->
													   case lists:keyfind(StoneSlot,1,StoneSlotInfo) of
														   false->
															   NewStoneSlotInfo = [{StoneSlot,Count}|StoneSlotInfo];
														   {_,OldCount}->
															   NewStoneSlotInfo = lists:keyreplace(StoneSlot,1,StoneSlotInfo,{StoneSlot,Count+OldCount})
													   end
												end,
												IsBond = get_isbonded_from_iteminfo(StoneInfo),
								  				Type = get_socket_type_from_iteminfo(StoneInfo),
												if StoneType =/= 0 ->
													   if Type =:= StoneType ->
															  {[IsBond|IsBondList],Count+TotleCount,Type,true,NewStoneSlotInfo};
														  true ->
															  {[IsBond|IsBondList],Count+TotleCount,Type,false,NewStoneSlotInfo}
													   end;
												   true ->
													   {[IsBond|IsBondList],Count+TotleCount,Type,true,NewStoneSlotInfo}
												end
						  				end
									end,{[],0,0,false,[]},StoneList),
	{IsBondList,TotleCount,StoneType,Flag,StoneSlotInfo} = StoneMixInfo,
	IsenoughStone = lists:map(fun({Slot,Count})->
									  StoneInfo =get_item_from_proc(Slot),
									  StoneCount = items_op:get_count_from_iteminfo(StoneInfo),
									  if StoneCount >= Count ->
											 true;
										 true->
											 false
									  end
								end,StoneSlotInfo),
	StoneCountFlag = lists:member(false, IsenoughStone),
	case Flag of
		false ->
			Result = ?ERROR_NOT_SAME_STONE;
		true ->
			case StoneCountFlag of
				false->
					StonemixInfo = enchantments_db:get_stonemix_info(StoneType),
					Silver = enchantments_db:get_stonemix_consume_silver(StonemixInfo),
					[ResStoneId,ResBondStoneId] = enchantments_db:get_stonemix_result(StonemixInfo),
					RandomRate = enchantments_db:get_random_rate(StonemixInfo),
					if TotleCount >= ?STONEMIX_NEED_NUM ->
		   				case role_op:check_money(?MONEY_BOUND_SILVER,Silver) of
			   				true ->
				   				case package_op:get_empty_slot_in_package() of
					   				0 ->
										Result = ?ERROR_PACKEGE_FULL;
					   				_ ->
						   				case random:uniform(?CARDINAL) > RandomRate of
							   				true ->
												Result = ?ERROR_EQUIPMENT_STONEMIX_FAILED;
							   				_ ->
												Result = [],
				   	   			   				case lists:member(?BONDING,IsBondList) of
			   										true ->
				   										ResultStoneId = ResBondStoneId;
			   										false ->
				   										ResultStoneId = ResStoneId
		   										end,
												role_op:money_change(?MONEY_BOUND_SILVER,-Silver,equipment_stonemix),
												lists:foreach(fun({_,StoneSlot,Count})->
														 			case get_item_from_proc(StoneSlot) of
															 			[]->
																 			nothing;
															 			StoneInfo ->
																 			role_op:consume_item(StoneInfo,Count)
														 			end
																end,StoneList),

												role_op:auto_create_and_put(ResultStoneId,1,equipment_stonemix),
												ResultStoneInfo = item_template_db:get_item_templateinfo(ResultStoneId), 
												ResultStoneQuality = item_template_db:get_qualty(ResultStoneInfo),
												case ResultStoneQuality >= ?STONE_BROADCAST_QUALITY of
													true->
														system_bodcast(?SYSTEM_CHAT_STONEMIX,get(creature_info),ResultStoneId);
													false->
														nothing
												end,
												Msg = equipment_packet:encode_equipment_stonemix_s2c(ResultStoneId),
												role_op:send_data_to_gate(Msg)
				   						end
				   				end;
							false ->
								Result = ?ERROR_LESS_MONEY
						end;
			  		  true ->
				  		Result = ?ERROR_EQUIPMENT_STONEMIX_LESS_COUNT
					end;
				true->
					Result = ?ERROR_EQUIPMENT_STONEMIX_LESS_COUNT
			end
	end,
	if 
		Result =/= []->
			Message = equipment_packet:encode_equipment_stonemix_failed_s2c(Result),
			role_op:send_data_to_gate(Message);
 		true->
			nothing
	end.

 %%按建华要求
 %%附魔锁定1次20元宝；2次60元宝，20120817
recast_lock_gold(Count) ->
	case  Count of 
	1->20;
	2->60;
	_->0
	end.

%% add new param LockArr,by zhangting  (Equipment=index,Enchant=slot  不要
abstract_enchant(Equipment,Enchant,Type,LockArr)->
	case get_item_from_proc(Equipment) of 
		[]->
			Errno = ?ERROR_EQUIPMENT_NOEXIST;
		EquipmentProp->
			Invent = get_inventorytype_from_iteminfo(EquipmentProp),
			Enchants = get_enchant_from_iteminfo(EquipmentProp),
			EquipTmpId = get_template_id_from_iteminfo(EquipmentProp),
			Quality = get_qualty_from_iteminfo(EquipmentProp),
			if
				Enchants=:=[],Type=:=recast->
					Errno = ?ERROR_EQUIPMENT_RECAST_NONE_ENCHANT;
				true->
					case equipment_db:get_enchant_opt_info(Invent) of
						[]->
							Errno = ?ERRNO_NPC_EXCEPTION;
						EnchantOpt->
							case Type of
								enchant->
									 {PropIdsDB,EnchantInfo} = {equipment_db:get_info_enchant_prop(EnchantOpt), get_item_from_proc(Enchant)};
								recast->
									%%%%锁定消耗元宝%%
									 {PropIdsDB,EnchantInfo} =
										 case  length(LockArr)>0 andalso role_op:check_money(?MONEY_GOLD,  recast_lock_gold(length(LockArr))  ) =:= false of
										     true->{undefined,undefined};									 
										     false->{equipment_db:get_info_recast_prop(EnchantOpt),get_item_from_proc(Enchant)}
										 end	   
							end,
							case EnchantInfo of
								undefined->Errno =  ?ERROR_LESS_GOLD;
								[]->
									Errno = ?ERRNO_NPC_EXCEPTION;
								EnchantProp->
									TmpId = get_template_id_from_iteminfo(EnchantProp),
									case lists:member(TmpId, PropIdsDB) of
										false->
											Errno=?ERROR_EQUIPMENT_RISEUP_NOT_MATCHED;
										true->
											PriorityList = equipment_db:get_info_property_count(EnchantOpt),
											case Type of
												enchant->
													PropertyCount = get_value_by_priority(PriorityList);
												recast->
													PropertyCount = get_recast_prop_count(Equipment,Enchants)
											end,
											case equipment_db:get_enchant_property_opt_infos(Invent) of
												[]->
													Errno = ?ERRNO_NPC_EXCEPTION;
												PropInfos->
													Errno=[],
													check_bonding(Equipment,[Enchant]),
													OldEnchants=if length(LockArr)>0 ->get_enchant_from_iteminfo(EquipmentProp);true->[] end,
													BackProps = get_property_by_count(OldEnchants,PropInfos,PropertyCount,LockArr),
													consume_item(Enchant),
													case Type of
														enchant->
															change_enchant_attr(Equipment,BackProps),
															recompute_equipment_attr(Equipment,get_id_from_iteminfo(EquipmentProp)),
															role_fighting_force:hook_on_change_role_fight_force(),
															hook_onbody_achieve_update(enchant,Equipment,Quality),
															if
																erlang:length(BackProps) =:= 3->
																	achieve_op:achieve_update({enchant_detail},[3],1),%%@@wb附魔出现三条属性成就
																	system_bodcast_equipment(?SYSTEM_CHAT_EQUIPMENT_EHCHANT,get(creature_info),Equipment);
																true->
																	nothing
															end,
															gm_logger_role:role_enchantments_item(get(roleid),EquipTmpId,prop_enchant,BackProps,get(level)),
															Message = equipment_packet:encode_equipment_enchant_s2c(role_attr:to_item_attribute({enchant,BackProps}));
														recast->
															if  length(LockArr)>0 ->
																	%%锁定消耗元宝
																	role_op:money_change(?MONEY_GOLD, -1*recast_lock_gold(length(LockArr)), lock_recast);
															true->nothing
                                                     end,
															MessageProps = recast_extremely_property_judge(Invent,BackProps),
															put(recast_props,{get_item_id(Equipment),MessageProps}),
															put(convert_props,[]),
															gm_logger_role:role_enchantments_item(get(roleid),EquipTmpId,prop_recast,MessageProps,get(level)),
															Message = equipment_packet:encode_equipment_recast_s2c(role_attr:to_item_attribute({enchant,MessageProps}))
													end,
													quest_op:update(enchant,1),
													role_op:send_data_to_gate(Message)
											end
									end
							end
					end
			end
	end,
	if 
		Errno =/= []->
			io:format("Errno is ~p~n",[Errno]),
			Message_failed = equipment_packet:encode_equipment_riseup_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

%%  Equipment=index,Enchant=slot 
abstract_enchant_with_gold(Equipment,Type,LockArr)->
	case get_item_from_proc(Equipment) of 
		[]->
			Errno = ?ERROR_EQUIPMENT_NOEXIST;
		EquipmentProp->
			Invent = get_inventorytype_from_iteminfo(EquipmentProp),
			Enchants = get_enchant_from_iteminfo(EquipmentProp),
			EquipTmpId = get_template_id_from_iteminfo(EquipmentProp),
			Quality = get_qualty_from_iteminfo(EquipmentProp),
		if 
			((Enchants=/=[]) and (Type=:=recast)) or (Type=:=enchant)->
			case equipment_db:get_enchant_opt_info(Invent) of
				[]->
					Errno = ?ERRNO_NPC_EXCEPTION;
				EnchantOpt->
					case Type of
						enchant->
							Cgold = equipment_db:get_info_enchant_gold(EnchantOpt);
						recast->
							%%锁定消耗元宝
							Cgold = equipment_db:get_info_recast_gold(EnchantOpt)+  recast_lock_gold(length(LockArr))
					end,
					case role_op:check_money(?MONEY_GOLD, Cgold) of
						false->
							Errno=?ERROR_LESS_GOLD;
						true->
							PriorityList = equipment_db:get_info_property_count(EnchantOpt),
							case Type of
								enchant->
									PropertyCount = get_value_by_priority(PriorityList);
								recast->
									PropertyCount = get_recast_prop_count(Equipment,Enchants)
							end,
							case equipment_db:get_enchant_property_opt_infos(Invent) of
								[]->
									Errno = ?ERRNO_NPC_EXCEPTION;
								PropInfos->
									Errno=[],
									OldEnchants=if length(LockArr)>0 ->get_enchant_from_iteminfo(EquipmentProp);true->[] end,
									BackProps = get_property_by_count(OldEnchants,PropInfos,PropertyCount,LockArr),
									case Type of
										enchant->
											role_op:money_change(?MONEY_GOLD, -Cgold, lost_enchant),
											change_enchant_attr(Equipment,BackProps),
											recompute_equipment_attr(Equipment,get_id_from_iteminfo(EquipmentProp)),
											role_fighting_force:hook_on_change_role_fight_force(),
											if
												erlang:length(BackProps) =:= 3->
													achieve_op:achieve_update({enchant_detail},[3],1),%%@@wb附魔出现三条属性成就
													system_bodcast_equipment(?SYSTEM_CHAT_EQUIPMENT_EHCHANT,get(creature_info),Equipment);
												true->
													nothing
											end,
											hook_onbody_achieve_update(enchant,Equipment,Quality),
											gm_logger_role:role_enchantments_item(get(roleid),EquipTmpId,gold_enchant,BackProps,get(level)),
											Message = equipment_packet:encode_equipment_enchant_s2c(role_attr:to_item_attribute({enchant,BackProps}));
										recast->
											role_op:money_change(?MONEY_GOLD, -Cgold, lost_recast),
											MessageProps = recast_extremely_property_judge(Invent,BackProps),
											put(recast_props,{get_item_id(Equipment),MessageProps}),
											put(convert_props,[]),
											gm_logger_role:role_enchantments_item(get(roleid),EquipTmpId,gold_recast,MessageProps,get(level)),
											Message = equipment_packet:encode_equipment_recast_s2c(role_attr:to_item_attribute({enchant,MessageProps}))
									end,
									role_op:send_data_to_gate(Message)
							end
					end
			end;
		true->
			Errno=?ERROR_EQUIPMENT_RECAST_NONE_ENCHANT
		end
	end,
	if 
		Errno =/= []->
			Message_failed = equipment_packet:encode_equipment_riseup_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

get_recast_prop_count(Equipment,Enchants)->
	EnchantCount = erlang:length(Enchants),
	TempCount = case get(recast_props) of
					undefined->
						EnchantCount;
					[]->
						EnchantCount;
					{ItemId,BackProps}->
						ThisItemId = get_item_id(Equipment),
						BackPropsCount = erlang:length(BackProps),
						if
							ItemId=:=ThisItemId,BackPropsCount>EnchantCount->
								BackPropsCount;
							true->
								put(recast_props,[]),
								EnchantCount
						end
				end,
	if 
		TempCount >= 3->
			PropertyCount = 3;
		true->
			PropertyCount = TempCount
	end,
	PropertyCount.

recast_extremely_property_judge(Invent,BackProps)->
	case length(BackProps) < 3 of
		true->
			case equipment_db:get_enchant_property_opt_infos(Invent) of
				[]->
					BackProps;
				PropInfos->
					IsQualityRange = check_quality_range(PropInfos,BackProps),
					if
						IsQualityRange->
							case equipment_db:get_enchant_property_opt_infos(Invent) of
								[]->
									BackProps;
								PropInfos->
									ExtremeLy = get_property_by_count([],PropInfos,1,[]),
									BackProps%%wb20130626重铸不改变附魔条数
%% 									BackProps++ExtremeLy
							end;
						true->
							BackProps
					end
			end;
		_->
			BackProps
	end.
	
equipment_enchant(Equipment,Enchant)->
	put(recast_props,[]),
	put(convert_props,[]),
	if
		Enchant=:=0->
			abstract_enchant_with_gold(Equipment,enchant,[]);
		true->
			abstract_enchant(Equipment,Enchant,enchant,[])
	end.
		
equipment_recast(Equipment,Recast,Type,LockArr)->
	if
		Type=:=1->
			abstract_enchant(Equipment,Recast,recast,LockArr);
		true->
			abstract_enchant_with_gold(Equipment,recast,LockArr)
	end.

equipment_recast_confirm(Equipment)->      %%Equipment=Slot
	case get_item_from_proc(Equipment) of 
		[]->
			nothing;
		EquipmentProp->
			Invent = get_inventorytype_from_iteminfo(EquipmentProp),
			EquipTmpId = get_template_id_from_iteminfo(EquipmentProp),
			ThisItemId = get_id_from_iteminfo(EquipmentProp),
			EnchantInfo = get_enchant_from_iteminfo(EquipmentProp),
			case get(recast_props) of
				undefined->
					equipment_convert_confirm(EquipTmpId,ThisItemId,Equipment);
				[]->
					equipment_convert_confirm(EquipTmpId,ThisItemId,Equipment);
				{ItemId,BackProps}->
					if
						ItemId =:= ThisItemId->
							put(recast_props,[]),
							change_enchant_attr(Equipment,BackProps),
							recompute_equipment_attr(Equipment,ThisItemId),
							role_fighting_force:hook_on_change_role_fight_force(),
							gm_logger_role:role_enchantments_item(get(roleid),EquipTmpId,recast_confirm,BackProps,get(level)),
							case equipment_db:get_enchant_property_opt_infos(Invent) of
								[]->
									nothing;
								PropInfos->
									IsQualityRange = check_quality_range(PropInfos,BackProps),
									enchant_golden_achieve(EnchantInfo,BackProps,PropInfos),
									if
										IsQualityRange->
											system_bodcast_equipment(?SYSTEM_CHAT_EQUIPMENT_RECAST,get(creature_info),Equipment);
										true->
											nothing
									end
							end;
						true->
							nothing
					end
			end
	end.

equipment_convert_confirm(EquipTmpId,ThisItemId,Equipment)->
	case get(convert_props) of
		undefined->
			nothing;
		[]->
			nothing;
		{ItemId,BackProps}->
			if
				ItemId =:= ThisItemId->
					put(convert_props,[]),
					change_enchant_attr(Equipment,BackProps),
					recompute_equipment_attr(Equipment,ThisItemId),
					role_fighting_force:hook_on_change_role_fight_force(),
					gm_logger_role:role_enchantments_item(get(roleid),EquipTmpId,convert_confirm,BackProps,get(level));
				true->
					nothing
			end
	end.

equipment_convert(Equipment,_Convert,_Type)->
	case get_item_from_proc(Equipment) of 
		[]->
			Errno = ?ERROR_EQUIPMENT_NOEXIST;
		EquipItemInfo->
			EquipItemId = get_id_from_iteminfo(EquipItemInfo),
			Invent = get_inventorytype_from_iteminfo(EquipItemInfo),
			Enchants = get_enchant_from_iteminfo(EquipItemInfo),
			EquipTmpId = get_template_id_from_iteminfo(EquipItemInfo),
		if 
			Enchants=/=[]->
			case equipment_db:get_enchant_opt_info(Invent) of
				[]->
					Errno = ?ERRNO_NPC_EXCEPTION;
				EnchantOpt->
					Cgold = equipment_db:get_info_convert_gold(EnchantOpt),
					case role_op:check_money(?MONEY_GOLD, Cgold) of
						false->
							Errno=?ERROR_LESS_GOLD;
						true->
							case equipment_db:get_enchant_convert_all_info() of
								[]->
									Errno = ?ERRNO_NPC_EXCEPTION;
								Converts->
									case check_has_convert_property(Enchants,Converts,EquipItemId) of
										false->
											Errno = ?ERROR_HAVE_NOT_CONVERT_PROPERTY;
										Converted->
											Errno=[],
											role_op:money_change(?MONEY_GOLD, -Cgold, lost_convert),
											put(convert_props,{EquipItemId,Converted}),
											put(recast_props,[]),
											gm_logger_role:role_enchantments_item(
											  get(roleid),EquipTmpId,gold_convert,Converted,get(level)),
											Message = equipment_packet:encode_equipment_convert_s2c(
														role_attr:to_item_attribute({enchant,Converted})),
											role_op:send_data_to_gate(Message)
									end
							end
					end
			end;
		true->
			Errno=?ERROR_EQUIPMENT_CONVERT_NONE_ENCHANT
		end
	end,
	if 
		Errno =/= []->
			Message_failed = equipment_packet:encode_equipment_riseup_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

check_has_convert_property(Enchants,Converts,EquipItemId)->
	case get(convert_props) of
		{ItemId,BackProps}->
			if
				ItemId=:=EquipItemId->
					TempEnchants=BackProps;
				true->
					TempEnchants=Enchants
			end;
		_->
			case get(recast_props) of
				undefined->
					TempEnchants=Enchants;
				[]->
					TempEnchants=Enchants;
				{RecastItemId,RecastBackProps}->
					if
						RecastItemId=:=EquipItemId->
							TempEnchants=RecastBackProps;
						true->
							TempEnchants=Enchants
					end
			end
	end,
	{ConvertEnchants,ReFlag} = 
	lists:foldl(fun(Enchant,{Acc,Flag})->
					{Prop,Value} = Enchant,
					case lists:keyfind(Prop, 2, Converts) of
						false->
							{Acc++[Enchant],Flag};
						ConvertInfo->
							ConvertList = equipment_db:get_info_convert_convert(ConvertInfo),
							Random = random:uniform(erlang:length(ConvertList)),
							ConvertProp = lists:nth(Random, ConvertList),
							{Acc++[{ConvertProp,Value}],true}
					end
				end, {[],false}, TempEnchants),
	if
		ReFlag->
			ConvertEnchants;
		true->
			false
	end.

property_list_refresh(TempInfos,TempProps)->
	Groups = lists:foldl(fun({PropName,_}, Acc)->
								 case lists:keyfind(PropName, 3, TempInfos) of
									 false->
										 Acc;
									 Info->
										 Group = equipment_db:get_info_group(Info),
										 MaxCount = equipment_db:get_info_max_count(Info),
										 case lists:keyfind(Group, 1, Acc) of
											 false->
												 Acc++[{Group,1,MaxCount}];
											 {Tgroup,Tcount,_}->
												 lists:keyreplace(Group, 1, Acc, {Tgroup,Tcount+1,MaxCount})
										 end
								 end
						 end, [], TempProps),
	lists:foldl(fun({A,B,C}, Acc)->
						if
							B < C->
								Acc;
							true->
								lists:keydelete(A, 6, Acc)
						end
				end, TempInfos, Groups).

get_property_by_count(_,_,[],LockArr)->
	[];
get_property_by_count(OldEnchants,PropInfosParam,Count,LockArr)->
	  PropInfos = 
     lists:foldr(fun(LockNo,PropInfosParam0)->
				OldEnchant=lists:nth(LockNo, OldEnchants),
				lists:keydelete(element(1,OldEnchant), #enchant_property_opt.property, PropInfosParam0)
		   end
	 ,PropInfosParam, LockArr),
	  
	 PropNameFun = fun(#enchant_property_opt{property=PropName,priority=PropPriority})->
						{PropName,PropPriority}
				   end,
	
	{_,BackProps,_} = 
		lists:foldl(fun(dummy,{TempInfos,ReProps,Seq0})->
				case  lists:member(Seq0, LockArr) of
                  true->
                      OldEnchant=lists:nth(Seq0, OldEnchants),
                      ReProps2 = ReProps++[OldEnchant],
                     {TempInfos,ReProps2,Seq0+1};
                  false-> 
				        PropNameInfos = lists:map(PropNameFun,TempInfos),
				        PropName = get_value_by_priority(PropNameInfos),
                      EnchantPropertyOpt = lists:keyfind(PropName, 3, TempInfos),
				        #enchant_property_opt{min_value=MinV,
									  max_value=MaxV,
									  min_priority=MinP,
									  max_priority=MaxP} = EnchantPropertyOpt,
				        PropValue = get_prop_value_fun(MinV,MaxV,MinP,MaxP),
				        ReProps2 = ReProps++[{PropName,PropValue}],
				        TempInfos2 = property_list_refresh(TempInfos,ReProps2),
				       {TempInfos2,ReProps2,Seq0+1}
               end
		end, {PropInfos,[],1}, lists:duplicate(Count, dummy)),
	  
	   %%slogger:msg("get_property_by_count98  BackProps:~p,OldEnchants:~p,PropInfosParam:~p,PropInfos:~p,LockArr:~p ~n",[BackProps,OldEnchants,PropInfosParam,PropInfos,LockArr]),
	  
	   BackProps.

get_prop_value_fun(MinV,MaxV,MinP,MaxP)->
	Values = lists:foldl(fun(X,Acc)->
								 Xpriority = MinP - (MinP-MaxP)/(MaxV-MinV)*(X-MinV),
								 XPriority2 = erlang:round(math:pow(Xpriority, 2)),
								 Acc ++ [{X,XPriority2}]
						 end, [], lists:seq(MinV, MaxV)),
	get_value_by_priority(Values).

get_value_by_priority([])->
	[];
get_value_by_priority(PriorityList)->
	MaxRate = lists:foldl(fun(ItemRate,LastRate)->
						LastRate +element(2,ItemRate)
				end, 0, PriorityList),
	RandomV = random:uniform(MaxRate),
%% 	RandomV = MaxRate,
	{BackValue,_} = lists:foldl(fun({X1,RateTmp},{Value,LastRate})->
						if
							Value =/= []->
								{Value,0};
							true->
								if
									LastRate+RateTmp >= RandomV->
										{X1,0};
									true->
										{[],LastRate+RateTmp}
								end
						end
				end, {[],0}, PriorityList),
	BackValue.

check_quality_range(PropInfos,BackProps)->
	CheckFun = fun({PropName,PropValue})->
					   EnchantPropertyOpt = lists:keyfind(PropName, 3, PropInfos),
					   #enchant_property_opt{max_quality_range={RangeA,RangeB}} = EnchantPropertyOpt,
					   if
						   PropValue>=RangeA,PropValue=<RangeB->
%% 							   achieve_op:achieve_update({enchant_gold},[0],1),%%@@wb20130408附魔出现金色属性成就
							   true;
						   true->
							   false
					   end
			   end,
	lists:any(CheckFun, BackProps).

get_backstone_slot_counts(StoneCount)->
	if
		StoneCount>0->
			if
				StoneCount rem 99 > 0->
					StoneCount div 99 + 1;
				true->
					StoneCount div 99
			end;
		true->
			0
	end.

check_same_stone(TemId,OrigSocketsInfo)->
	CurType = list_to_integer(string:sub_string(integer_to_list(TemId),5,6)),
	TempIds = lists:foldl(fun({_Pos,TemplateId},Acc)->
					  case TemplateId of 
						 0->
							 Acc;
						Id->
							Temp = list_to_integer(string:sub_string(integer_to_list(Id),5,6)),
					  		if 
								CurType =:= Temp ->
								   Acc ++ [TemplateId];
							   	true->
								   Acc
							end
					  end
					  end, [],OrigSocketsInfo),
	if erlang:length(TempIds) > 0 ->
		   false;
	   true->
		   true
	end.

check_bonding(ESlot,PropsSlot)->
	Equipbonding = get_isbonded(ESlot),
	IsBonded = lists:any(fun(PropSlot)-> get_isbonded(PropSlot) =:= 1 end, PropsSlot),
	if 
		Equipbonding=:=0,IsBonded ->
			items_op:set_item_isbonded(get_item_id(ESlot), 1);
		true->
			nothing
	end.

check_bonding_props(ESlot,PropsSlot)->
	Equipbonding = get_isbonded(ESlot),
	IsBonded = lists:any(fun(PropSlot)-> get_isbonded(PropSlot) =:= 1 end, PropsSlot),
	if 
		Equipbonding=:=0,IsBonded ->
			true;
		true->
			false
	end.

get_isbonded(Slot)->
	case get_item_from_proc(Slot) of
		[]->
			0;
		ItemInfo->
			get_isbonded_from_iteminfo(ItemInfo)
	end.

change_enchantment_attr(Package_slot,NewEnchantment)->
	case get_item_id(Package_slot) of
		[]->
			nothing;
		ItemId->
			items_op:set_item_enchantment(ItemId, NewEnchantment)
	end.

change_enchantment_attr_itemid(ItemId,NewEnchantment)->
	items_op:set_item_enchantment(ItemId, NewEnchantment).

recompute_equipment_attr(Slot,ItemId)->
	case package_op:where_slot(Slot) of
		body->
			role_op:recompute_equipment_attr();
		pet_body->
			pet_op:hook_item_attr_changed(ItemId);
		_->
			nothing
	end.

hook_onbody_achieve_update(enchantments,Slot,Param)->
	case package_op:where_slot(Slot) of
		body->
%% 			achieve_op:achieve_update({enchantments},[Param]),
%% 			achieve_op:achieve_update({target_enchantments},[Param]),
			%%zhangting add 全身升级六星的bug 20120830
            achieve_op:achieve_update({target_enchant},[Slot],Param),
			achieve_op:role_attr_update(),
%%             goals_op:goals_update({enchantments},[Param]),%%
%% 			goals_op:goals_update({target_enchantments},[Param]),%%
            goals_op:goals_update({target_enchant},[Slot],Param),%%
			goals_op:role_attr_update();%%@@wb20130311
		_->
			nothing
	end;
hook_onbody_achieve_update(inlay,Slot,Param)->
	case package_op:where_slot(Slot) of
		body->
			achieve_op:achieve_update({inlay},Param),
			achieve_op:role_attr_update(),
            goals_op:goals_update({inlay},Param),%%
			goals_op:role_attr_update();%%@@wb20130311
		_->
			nothing
	end;
hook_onbody_achieve_update(enchant,Slot,Param)->
	case package_op:where_slot(Slot) of
		body->
%% 			achieve_op:achieve_update({enchant},[Param]),
			achieve_op:role_attr_update(),
			goals_op:goals_update({enchant},[Param]),%%
			goals_op:role_attr_update();%%wb20130318
		_->
			nothing
	end.

get_stone_count_on_equipment(NewSocketsInfo)->
	Stones = lists:filter(fun({_,TemplateId})->if 
												  TemplateId=/=0->
													  true;
												  true->
													  false
											  end
						 end, NewSocketsInfo),
	erlang:length(Stones).

change_socket_attr(Package_slot,NewSocketsInfo)->
	case get_item_id(Package_slot) of
		[]->
			nothing;
		ItemId->
			items_op:set_item_socketsInfo(ItemId,NewSocketsInfo),
			ChangeAttrs = [role_attr:to_item_attribute({sockets,get_client_socketsinfo(NewSocketsInfo)})],
			ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(ItemId),
												get_highid_from_itemid(ItemId),
												ChangeAttrs,[]),
			Message = role_packet:encode_update_item_s2c([ChangeInfo]),
			role_op:send_data_to_gate(Message)
	end.

change_socket_attr_by_itemid(ItemId,NewSocketsInfo)->
	items_op:set_item_socketsInfo(ItemId,NewSocketsInfo),
	ChangeAttrs = [role_attr:to_item_attribute({sockets,get_client_socketsinfo(NewSocketsInfo)})],
	ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(ItemId),
										get_highid_from_itemid(ItemId),
										ChangeAttrs,[]),
	Message = role_packet:encode_update_item_s2c([ChangeInfo]),
	role_op:send_data_to_gate(Message).

change_enchant_attr(Package_slot,NewEnchantInfo)->
	case get_item_id(Package_slot) of
		[]->
			nothing;
		ItemId->
			items_op:set_item_enchantInfo(ItemId,NewEnchantInfo),
			ChangeAttrs = [],
			ExtEnchant = role_attr:to_item_attribute({enchant,NewEnchantInfo}),
			ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(ItemId),
												get_highid_from_itemid(ItemId),
												ChangeAttrs,ExtEnchant),
			Message = role_packet:encode_update_item_s2c([ChangeInfo]),
			role_op:send_data_to_gate(Message)
	end.

change_enchant_attr_by_itemid(ItemId,NewEnchantInfo)->
	items_op:set_item_enchantInfo(ItemId,NewEnchantInfo),
	ChangeAttrs = [],
	ExtEnchant = role_attr:to_item_attribute({enchant,NewEnchantInfo}),
	ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(ItemId),
												get_highid_from_itemid(ItemId),
												ChangeAttrs,ExtEnchant),
	Message = role_packet:encode_update_item_s2c([ChangeInfo]),
	role_op:send_data_to_gate(Message).

get_client_socketsinfo(ServerSocketsInfo)->
	SockFun = fun({_Socket,TemplateId},Acc0) ->
							  Acc0 ++ [TemplateId]
			  end,
	ReturnSockets = lists:foldl(SockFun, [], ServerSocketsInfo),
	ReturnSockets.

consume_item(Slot)->
	case get_item_from_proc(Slot) of
		[]->
			nothing;
		ItemInfo->
			role_op:consume_item(ItemInfo, 1)
	end.

consume_item(Slot,Count)->
	case get_item_from_proc(Slot) of
		[]->
			nothing;
		ItemInfo->
			role_op:consume_item(ItemInfo, Count)
	end.

get_item_level_star(_Level,Star) ->
	%%case Level of 
	%%	Level when Level >=1, Level =<49 ->
	%%		{1,49,Star};
	%%	Level when Level >=50, Level =<69 ->
	%%		{50,69,Star};
	%%	Level when Level >=70, Level =<89 ->
	%%		{70,89,Star};
	%%	Level when Level >=90, Level =<100 ->
	%%		{90,100,Star}
	%%end.
	Star.

get_item_level_star_for_sock(Level,Sock) ->
	case Level of 
		Level when Level >=1, Level =<49 ->
			{1,49,Sock};
		Level when Level >=50, Level =<69 ->
			{50,69,Sock};
		Level when Level >=70, Level =<89 ->
			{70,89,Sock};
		Level when Level >=90, Level =<100 ->
			{90,100,Sock}
	end.

get_item_level_class(Level,Class)->
	case Level of 
		Level when Level >=10, Level =<19 ->
			{10,19,Class};
		Level when Level >=20, Level =<29 ->
			{20,29,Class};
		Level when Level >=30, Level =<39 ->
			{30,39,Class};
		Level when Level >=40, Level =<49 ->
			{40,49,Class};
		Level when Level >=50, Level =<69 ->
			{50,69,Class};
		Level when Level >=70, Level =<89 ->
			{70,89,Class};
		Level when Level >=90, Level =<100 ->
			{90,100,Class}
	end.

get_item_id(Package_slot)->
	package_op:get_item_id_in_slot(Package_slot).

get_item_from_proc(Package_slot)->
	package_op:get_iteminfo_in_normal_slot(Package_slot).

get_player_item_from_proc(Package_slot)->
	case  package_op:get_item_id_in_slot(Package_slot) of
		[]->
			[];
		ItemId->
			items_op:make_playeritem(ItemId)
	end.
%%
%% Local Functions
%%
check_is_bonding_by_info(EquipInfo,ItemInfo)->
	EquipBound = get_isbonded_from_iteminfo(EquipInfo),
	ItemBound = get_isbonded_from_iteminfo(ItemInfo),
	if
		(EquipBound =:= 0) and (ItemBound =:= 0) ->
			false;
		true->
			true
	end.			
		
check_role_guild_contribution()->
	RoleContribution = guild_util:get_guild_tcontribution(),
	case guild_spawn_db:get_guild_right_limit(guild_util:get_guild_id()) of
		{_,_,Smith,_}->
			RoleContribution >= Smith;
		_->
			false
	end.

%%@@wb20130626附魔出现或覆盖金色属性成就更新
enchant_golden_achieve(OldEnchantInfo,NewEnchantInfo,PropInfos)->
	CheckFun = fun({PropName,PropValue},Acc)->
					   EnchantPropertyOpt = lists:keyfind(PropName, 3, PropInfos),
					   #enchant_property_opt{max_quality_range={RangeA,RangeB}} = EnchantPropertyOpt,
					   if
						   PropValue>=RangeA,PropValue=<RangeB->
							   Acc+1;
						   true->
							   Acc
					   end
			   end,
	OldNum = lists:foldl(CheckFun,0,OldEnchantInfo),
	NewNum = lists:foldl(CheckFun,0,NewEnchantInfo),
	if
		NewNum > OldNum ->
			achieve_op:achieve_update({enchant_gold},[0],erlang:min(NewNum-OldNum,3));
		NewNum < OldNum ->
			achieve_op:achieve_update({enchant_gold},[0],erlang:max(NewNum-OldNum,-3));
		true ->
			nothing
	end.
		
		
		
		
		
		
		
		
		
		
		
		
		
		
