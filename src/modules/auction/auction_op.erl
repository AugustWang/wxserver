%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(auction_op).
-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
-include("mnesia_table_def.hrl").
-include("auction_define.hrl").

load_from_db(StallName)->
	put(my_stall_name,StallName).

export_for_db()->
	get(my_stall_name).

export_for_copy()->
	get(my_stall_name).

load_by_copy(StallName)->
	put(my_stall_name,StallName).

proc_rename(StallName)->
	if
		length(StallName) < 100->
			put(my_stall_name,StallName),
			auction_manager:stall_rename(get(roleid),StallName);
		true->
			role_op:kick_out(get(roleid))
	end.

proc_item_up_stall_by_xiaowu(Slot,Moneys,Duration_type)->%%2.20jia[xiawu]%%上架物品
	case package_op:get_iteminfo_in_package_slot(Slot) of
		[]->
			slogger:msg(" proc_item_up_stall error Slot roleid ~p ~n",[get(roleid)]);
		ItemInfo->
			RoleName = get_name_from_roleinfo(get(creature_info)),
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			ItemName = get_name_from_iteminfo(ItemInfo),
			PlayerItem = items_op:build_item_by_fullinfo(ItemInfo),
			case get_isbonded_from_iteminfo(ItemInfo) of
				0->
					case auction_manager:apply_up_stall({get(roleid),RoleName,RoleLevel}, {PlayerItem,Moneys,get(my_stall_name),ItemName,Duration_type}) of
						ok->
							items_op:lost_from_stall_by_playeritem(PlayerItem),
							ok;
						_->
							nothing
					end;
				_->
					nothing
			end
	end.

proc_money_up_stall_by_xiaowu(Gold, Duration_type, Silver,Value,Type,Duration_type)->%%2.21xie[xiaowu]%%上架钱币和元宝
	RoleName = get_name_from_roleinfo(get(creature_info)),
	RoleLevel = get_level_from_roleinfo(get(creature_info)),
	case Type of
		1 ->%%挂售钱币
			MoneyCount = trunc(Value),
			case auction_manager:apply_up_money_stall({get(roleid),RoleName,RoleLevel},{{Gold,Value,Type,Silver},{0,Gold,0},get(my_stall_name),[],Duration_type}) of
				ok ->
					role_op:money_change_not_gold(?MONEY_SILVER, -MoneyCount,lost_function),
					bao_guan_fei_by_xiao_wu(Gold,Silver,Duration_type),
					role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_SHANGJIA_CHENGGONG));
				_ ->
					role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_TANWEIMAN))
			end;
		2 ->%%挂售元宝
			MoneyCount = trunc(Value),
			case auction_manager:apply_up_money_stall({get(roleid),RoleName,RoleLevel},{{Gold,Value,Type,Silver},{Silver,0,0},get(my_stall_name),[],Duration_type})of
				ok ->
					role_op:money_change(?MONEY_GOLD, -MoneyCount,lost_function),
					bao_guan_fei_by_xiao_wu(Gold,Silver,Duration_type),
					role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_SHANGJIA_CHENGGONG));
				_ ->
					role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_TANWEIMAN))
			end
	end.

bao_guan_fei_by_xiao_wu(Gold,Silver,Duration_type)->%%2.20xie[xiaowu]%%收取保管费
		if ((Silver > 0)and(Gold =:=0)) ->
				if 
					trunc(Silver*(Duration_type)*0.01) =< 1 ->
						MoneyCount = 1;
					true ->
						MoneyCount = trunc(Silver*(Duration_type)*0.01)
				end;
			true ->
				MoneyCount = trunc(Gold*(Duration_type)*10)
		end,
		role_op:money_change_not_gold(?MONEY_BOUND_SILVER, -MoneyCount,lost_function).
				
proc_paimai_detail(StallId)->%%2月22日加【xiaowu】查看上架物品
	if
		StallId=:=0->
			auction_manager:paimai_detail_myself(get(roleid),get(my_stall_name));
		true->
			auction_manager:stall_detail(get(roleid),StallId)
	end.	

%proc_item_up_stall(Slot,Moneys)->
%	case package_op:get_iteminfo_in_package_slot(Slot) of
%		[]->
%			slogger:msg(" proc_item_up_stall error Slot roleid ~p ~n",[get(roleid)]);
%		ItemInfo->
%			RoleName = get_name_from_roleinfo(get(creature_info)),
%			RoleLevel = get_level_from_roleinfo(get(creature_info)),
%			ItemName = get_name_from_iteminfo(ItemInfo),
%			PlayerItem = items_op:build_item_by_fullinfo(ItemInfo),
%			case get_isbonded_from_iteminfo(ItemInfo) of
%				0->
%					case auction_manager:apply_up_stall({get(roleid),RoleName,RoleLevel}, {PlayerItem,Moneys,get(my_stall_name),ItemName}) of
%						ok->
%							items_op:lost_from_stall_by_playeritem(PlayerItem);
%						_->
%							nothing
%					end;
%				_->
%					nothing
%			end
%	end.

%proc_recede_item(ItemId)->
%	MyId = get(roleid),
%	case package_op:get_empty_slot_in_package() of
%		0->
%			role_op:send_data_to_gate(auction_packet:encode_stall_opt_result_s2c(?ERROR_PACKEGE_FULL));
%		[EmpSlot]->
%			case auction_manager:apply_recede_item(MyId,ItemId) of
%				{ok,PlayerItem}->
%					NewPlayerItem = PlayerItem#playeritems{ownerguid = MyId},
%					items_op:obtain_from_auction_by_playeritem(NewPlayerItem, EmpSlot,got_down_stall);
%				_->
%					nothing
%			end
%	end.
proc_recede_item_by_xiaowu(Type,Stallid,Indexid)->%%xie[xiaowu]物品或钱币元宝下架
	if
		Type =:=0 ->		
			MyId = get(roleid),
			StallInfo = auction_manager_op:get_stall_info(Stallid),
			ItemInfos = auction_manager_op:get_stall_by(items,StallInfo),
			case lists:keyfind(Indexid,5,ItemInfos) of
				{ItemId,{Silver,Gold,Ticket},Createtime,Duration_type,IndexId}->
					case auction_manager:apply_recede_item(MyId,ItemId) of
						{ok,PlayerItem}->				
							role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_XIAJIA_CHENGGONG));
						_->
							nothing
					end;
				_->
					role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_RECEDE_NO_STALL))
			end;
		true->
			MyId = get(roleid),
			StallInfo = auction_manager_op:get_stall_info(Stallid),
			ItemInfos = auction_manager_op:get_stall_by(items,StallInfo),
			Acc1 = length(ItemInfos),
			Stallmoneys = auction_manager_op:get_stall_by(stallmoney,StallInfo),
			case lists:keyfind(Indexid,6,Stallmoneys) of
				{_,{Gold,Value,Type,Silver},{Silver,Gold,Ticket},Createtime,Duration_type,IndexId}->
					case Type of
						1 ->%%下架钱币
							MoneyCount = trunc(Value),
							{From,Title,Body} = auction_manager_op:make_recede_mail_body(),
							case mail_op:auction_send_by_playeritems(From,MyId,Title,Body,[],MoneyCount,0) of
								{ok}->
									auction_manager_op:proc_delete_money(Stallid,MyId,StallInfo,IndexId);
								MailError->
									slogger:msg("mail send error ~p ~n",[MailError]),
									error
							end,
							role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_XIAJIA_CHENGGONG));
						2 ->%%下架元宝
							MoneyCount = trunc(Value),
							{From,Title,Body} = auction_manager_op:make_recede_mail_body(),
							case mail_op:auction_send_by_playeritems(From,MyId,Title,Body,[],0,MoneyCount) of
								{ok}->
									auction_manager_op:proc_delete_money(Stallid,MyId,StallInfo,IndexId);
								MailError->
									slogger:msg("mail send error ~p ~n",[MailError]),
									error
							end,
							role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_XIAJIA_CHENGGONG))
					end;
				_->
					role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_RECEDE_NO_STALL))
			end
	end.


proc_paimai_search_by_sort(Subsortkey,Sortkey,Levelsort,Index,Mainsort,Moneysort)->%%xie[xiaowu]左侧搜索
	auction_manager:paimai_search_by_sort(get(roleid),Subsortkey,Sortkey,Levelsort,Index,Mainsort,Moneysort).

proc_paimai_search_by_string(Levelsort,Str,Index,Mainsort,Moneysort)->%%xie[xiaowu]下面搜索
	auction_manager:paimai_search_by_string(get(roleid),Levelsort,Str,Index,Mainsort,Moneysort).

proce_paimai_search_by_grade(Levelsort,Index,Allowableclass,Mainsort,Levelgrade,Moneysort,Qualitygrade)->%%xie[xiaowu]上面搜索
	auction_manager:paimai_search_by_grade(get(roleid),Levelsort,Index,Allowableclass,Mainsort,Levelgrade,Moneysort,Qualitygrade).

proce_paimai_buy(Type, Stallid, Indexid)->%%xie[xiaowu]购买
	case auction_manager_op:get_stall_info(Stallid) of
			[] ->
				role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_RECEDE_NO_STALL));
			StallInfo -> 
				ItemInfos = auction_manager_op:get_stall_by(items,StallInfo),
				Gold = get_gold_from_roleinfo(get(creature_info)),
				Silver = get_silver_from_roleinfo(get(creature_info)),
				Ticket = get_ticket_from_roleinfo(get(creature_info)),
				MyName = get_name_from_roleinfo(get(creature_info)),
				MyId = get(roleid),
				if
					Type =:=0 ->%%购买物品	
						 case lists:keyfind(Indexid,5,ItemInfos) of
							{ItemId,{StallSilver,StallGold,StallTicket},Createtime,Duration_type,IndexId}->
								case auction_manager:apply_buy_item({MyId,MyName},Stallid,ItemId,{Silver,Gold,Ticket}) of
									{ok,{DelSilver,DelGold,_DelTicket},PlayerItem}->
										if
											DelGold =/= 0->
												role_op:money_change( ?MONEY_GOLD, -DelGold,lost_stall_buy);
											true->
												nothing
										end,
										if
											DelSilver =/= 0->
												role_op:money_change( ?MONEY_SILVER, -DelSilver,lost_stall_buy);
											true->
												nothing
										end,
										role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_GOUMAI_CHENGGONG));
									_->
										nothing
								end;
							_ ->
								role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_RECEDE_NO_ITEM))
						end;	
					true->%%购买钱币或元宝
						Stallmoneys = auction_manager_op:get_stall_by(stallmoney,StallInfo),
						case lists:keyfind(Indexid,6,Stallmoneys) of
							{_,{StallGold,StallValue,StallType,StallSilver},{NeedSilver,NeedGold,NeedTicket},Createtime,Duration_type,IndexId}->
								case Type of
									1 ->%%买钱币
										MoneyCount = trunc(StallValue),
										BeiStallSilver = StallValue,
										case auction_manager_op:apply_buy_money({MyId,MyName},Stallid,{0,StallValue,StallType,BeiStallSilver},{NeedSilver,NeedGold,NeedTicket},{Silver,Gold,Ticket},Indexid) of
											ok ->				
												role_op:money_change(?MONEY_GOLD,-NeedGold,add_function),
												role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_GOUMAI_CHENGGONG));
											_ ->
												error
										end;
									2 ->%%买元宝
										MoneyCount = trunc(StallValue),
										BeiStallGold = StallValue,
										case auction_manager_op:apply_buy_money({MyId,MyName},Stallid,{BeiStallGold,StallValue,StallType,0},{NeedSilver,NeedGold,NeedTicket},{Silver,Gold,Ticket},Indexid) of
											ok ->
												role_op:money_change_not_gold(?MONEY_SILVER,-NeedSilver,add_function),
												role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_GOUMAI_CHENGGONG));
											_ ->
												error
										end	
								end;
							_ ->
								role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_RECEDE_NO_ITEM))
						end
				end
	end.



%proc_stalls_search(Index)->
%	case Index>=0 of
%		true->
%			auction_manager:stalls_search(get(roleid),?ACUTION_SERCH_TYPE_ALL,[],Index);
%		_->
%			nothing
%	end.

%proc_stalls_item_search(Index,Str)->
%	case Index>=0 of
%		true->
%			auction_manager:stalls_search(get(roleid),?ACUTION_SERCH_TYPE_ITEMNAME,Str,Index);
%		_->
%			nothing
%	end.
	
%proc_stall_detail(StallId)->
%	if
%		StallId=:=0->
%			auction_manager:stall_detail_myself(get(roleid),get(my_stall_name));
%		true->
%			auction_manager:stall_detail(get(roleid),StallId)
%	end.	

proc_stall_detail_by_rolename(RoleName)->
	auction_manager:stall_detail_by_rolename(get(roleid),RoleName).

%proc_buy_item_c2s(StallId,ItemId)->
%	Gold = get_gold_from_roleinfo(get(creature_info)),
%	Silver = get_silver_from_roleinfo(get(creature_info)),
%	Ticket = get_ticket_from_roleinfo(get(creature_info)),
%	MyName = get_name_from_roleinfo(get(creature_info)),
%	MyId = get(roleid),
%	case package_op:get_empty_slot_in_package() of
%		0->
%			role_op:send_data_to_gate(auction_packet:encode_stall_opt_result_s2c(?ERROR_PACKEGE_FULL));
%		[EmpSlot]->
%			case auction_manager:apply_buy_item({MyId,MyName},StallId,ItemId,{Silver,Gold,Ticket}) of
%				{ok,{DelSilver,DelGold,_DelTicket},PlayerItem}->
%					if
%						DelGold =/= 0->
%							role_op:money_change( ?MONEY_GOLD, -DelGold,lost_stall_buy);
%						true->
%							nothing
%					end,
%					if
%						DelSilver =/= 0->
%							role_op:money_change( ?MONEY_SILVER, -DelSilver,lost_stall_buy);
%						true->
%							nothing
%					end,
%					items_op:obtain_from_auction_by_playeritem(PlayerItem, EmpSlot,stall_buy);
%				_->
%					nothing
%			end
%	end.
