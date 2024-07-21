%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-12-20
%% Description: TODO: Add description to equipment_punch
-module(equipment_punch).

%%
%% Include files
%%
-include("error_msg.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
equipment_punch(EquipSlot,ItemSlot)->
	case package_op:get_iteminfo_in_normal_slot(EquipSlot) of
		[]->
			Errno = ?ERROR_EQUIPMENT_NOEXIST;
		EquipInfo->
			MaxPunch = get_maxsocket_from_iteminfo(EquipInfo),
			PunchInfo = get_socketsinfo_from_iteminfo(EquipInfo),
			CurPunchNum = erlang:length(PunchInfo),
			if
				CurPunchNum >= MaxPunch ->
					Errno = ?ERROR_SOCKETS_MAX;
				true->
					ConsumeInfo = enchantments_db:get_equip_punch_info(CurPunchNum+1),
					NeedItems = enchantments_db:get_equip_punch_consume(ConsumeInfo),
					NeedMoney = enchantments_db:get_equip_punch_money(ConsumeInfo),
					Rate = enchantments_db:get_equip_punch_rate(ConsumeInfo),
					case equipment_op:get_item_from_proc(ItemSlot) of
						[]->
							Errno = ?ERROR_MISS_ITEM;
						ItemInfo->
							ItemId = get_template_id_from_iteminfo(ItemInfo),
							case lists:member(ItemId,NeedItems) of
								false->
									Errno = ?ERROR_EQUIPMENT_SOCKETS_NOT_MATCHED;
								_->
									HasItem =get_count_from_iteminfo(ItemInfo) >= 1, 
									HasMoney = role_op:check_money(?MONEY_BOUND_SILVER,NeedMoney),
									if
										not HasItem ->
											Errno = ?ERROR_MISS_ITEM;
										not HasMoney ->
											Errno = ?ERROR_LESS_MONEY;
										true->
											Errno = [],
											case equipment_op:check_is_bonding_by_info(EquipInfo,ItemInfo) of
												false->
													ignor;
												_->
													items_op:set_item_isbonded(package_op:get_item_id_in_slot(EquipSlot),1)
											end,
											role_op:consume_item(ItemInfo,1),
											role_op:money_change(?MONEY_BOUND_SILVER,-NeedMoney,equip_punch),
											{A,B} = Rate,
											case random:uniform(B) =< A of
												true->
													NewPunchInfo = lists:append(PunchInfo,[{CurPunchNum+1,0}]),
													equipment_op:change_socket_attr(EquipSlot,NewPunchInfo),
													EquipTempId = get_template_id_from_iteminfo(EquipInfo),
													gm_logger_role:role_enchantments_item(get(roleid),EquipTempId,socket,NewPunchInfo,get(level)),
													role_op:async_write_to_roledb(),
													items_op:save_to_db(),
													quest_op:update(sock,CurPunchNum+1),
													Message = equipment_packet:encode_equipment_sock_s2c(1, CurPunchNum+1),
													role_op:send_data_to_gate(Message);
												_->
													EquipTempId = get_template_id_from_iteminfo(EquipInfo),
													gm_logger_role:role_enchantments_item(get(roleid),EquipTempId,socket_failed,PunchInfo,get(level)),
													Message = equipment_packet:encode_equipment_sock_s2c(2, CurPunchNum),
													role_op:send_data_to_gate(Message)
											end
									end
							end
					end
			end
	end,
	if 
		Errno =/= []->
			Message_failed = equipment_packet:encode_equipment_sock_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

					






