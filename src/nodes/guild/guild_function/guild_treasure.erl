%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-4-17
%% Description: TODO: Add description to guild_treasure
-module(guild_treasure).

%%
%% Include files
%%
-include("error_msg.hrl").
-include("guild_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% member_treasure_list {{guildid,memberid,id},guildid,member,count,time}
%%
%% treasure_item_price {{guildid,id},guildid,price}
%%

%%
%% API Functions
%%
init()->
	ets:new(member_treasure_list,[set,protected, named_table]),
	%%加载数据库
	AllMemberInfo = guild_spawn_db:get_allmembertreasureinfo(),
	lists:foreach(fun(Info)->
				Key = guild_spawn_db:get_membertreasureinfo_key(Info),
				GuildId = guild_spawn_db:get_membertreasureinfo_guildid(Info),
				MemberId = guild_spawn_db:get_membertreasureinfo_memberid(Info),
				Count = guild_spawn_db:get_membertreasureinfo_count(Info),
				Time = guild_spawn_db:get_membertreasureinfo_time(Info),
				update_member_treasure_info({Key,GuildId,MemberId,Count,Time})	
			end,AllMemberInfo),
	
	ets:new(treasure_item_price,[set,protected, named_table]),
	%%加载数据库
	AllPriceInfo = guild_spawn_db:get_treasurepriceinfo(),
	lists:foreach(fun(Info)->
				Key = guild_spawn_db:get_membertreasurepriceinfo_key(Info),
				GuildId = guild_spawn_db:get_membertreasurepriceinfo_guildid(Info),
				Price = guild_spawn_db:get_membertreasurepriceinfo_price(Info),
				update_treasure_item_price_info({Key,GuildId,Price})	
			end,AllPriceInfo).

update_member_treasure_info(Info)->
	ets:insert(member_treasure_list,Info).

update_treasure_item_price_info(Info)->
	ets:insert(treasure_item_price,Info).

buy_item(RoleId,GuildId,ShopType,Id,Count,RoleMoney)->
	FacilityInfo = guild_facility_op:get_facility_info(GuildId,?GUILD_FACILITY_TREASURE),
	Level = guild_facility_op:get_by_facility_item(level,FacilityInfo),
	case guild_proto_db:get_guild_treasure_info() of
		[]->
			error;	
		Info->
			case guild_proto_db:get_guild_treasureitem_info(Id) of
				[]->
					error;
				ItemInfo->
					case guild_member_op:get_member_info(RoleId) of
						[]->
							slogger:msg("guild treasure buy item member ~p not exist guild ~p \n",[RoleId,GuildId]),
							error;
						MemberInfo->
							Now = timer_center:get_correct_now(),																
							LimitNum = guild_proto_db:get_guild_treasureitem_limitnum(ItemInfo),
							Contribution = guild_proto_db:get_guild_treasureitem_contribution(ItemInfo),
							LimitLevel = guild_proto_db:get_guild_shopitem_minlevel(ItemInfo),
							RoleLevel = guild_member_op:get_by_member_item(level,MemberInfo),
							LevelCheck  = (RoleLevel >= LimitLevel),
							ItemPrice = get_treasure_item_realprice({GuildId,Id}),
							{MoneyType,MoneyCount} = ItemPrice,
							TotalMoneyCount = MoneyCount*Count, 
							RealPrice = {MoneyType,TotalMoneyCount},	
							MoneyCheck = 
								case lists:keyfind(MoneyType,1,RoleMoney) of
									false->
										false;
									{_,CurMoney}->
										CurMoney >= TotalMoneyCount;
									_->
										false
								end,
							CurContribution = guild_member_op:get_by_member_item(contribution,MemberInfo),
							ContributionCheck = (CurContribution >= Contribution*Count),											
							CurNum = get_item_buy_count_today({GuildId,RoleId,Id},Now),
							NewNum = CurNum + Count,
							LimitNumCheck =  ((NewNum =< LimitNum) or (LimitNum < 0)),		%%负数为不限制
							if
								not LevelCheck->%%等级不足
									ErrMsg = guild_packet:encode_guild_opt_result_s2c(?ERROR_LESS_LEVEL),
									role_pos_util:send_to_role_clinet(RoleId,ErrMsg),
									error_less_level;
								not MoneyCheck-> %%钱币不足
									ErrMsg = guild_packet:encode_guild_opt_result_s2c(?ERROR_LESS_MONEY),
									role_pos_util:send_to_role_clinet(RoleId,ErrMsg),
									error_less_gold;
								not ContributionCheck-> %%帮贡不足
									ErrMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_LESS_CONTRIBUTION),
									role_pos_util:send_to_role_clinet(RoleId,ErrMsg),
									error_less_contribution;
								not LimitNumCheck -> %%超过限购
									ErrMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_LIMITNUM),
									role_pos_util:send_to_role_clinet(RoleId,ErrMsg),
									error_limitnum;
								true->
									%%扣除帮贡
									NewContribution = CurContribution - Contribution*Count,
									NewMemberInfo = guild_member_op:set_by_member_item(contribution,NewContribution,MemberInfo),
									guild_member_op:update_member_info(NewMemberInfo),
									gm_logger_role:role_guild_contribution_change(RoleId,GuildId,NewContribution - CurContribution,guild_treasure),
									%%给帮会的回扣
									Restore = trunc(TotalMoneyCount * guild_proto_db:get_settingvalue(?GUILD_TREASURE_RESTORE_RATE)/100),
									OldGuildInfo = guild_manager_op:get_guild_info(GuildId),
									GuildInfo = guild_manager_op:add_guild_money([{MoneyType,Restore}],OldGuildInfo,guild_treasure_restore),
									guild_manager_op:update_guild_info(GuildInfo),
									%%广播公会金钱变化
									guild_manager_op:broad_cast_guild_base_changed_to_client(GuildInfo),
									guild_spawn_db:set_guild_silver(GuildId,guild_manager_op:get_by_guild_item(silver,GuildInfo)),	
									guild_spawn_db:set_guild_gold(GuildId,guild_manager_op:get_by_guild_item(gold,GuildInfo)),
									guild_spawn_db:set_member_contribution(RoleId,NewContribution),
									%%发送给进程
									guild_manager_op:send_base_info_update(RoleId,GuildId),
									%%广播贡献度变化给客户端
									Message = guild_packet:encode_guild_member_update_s2c(guild_packet:make_roleinfo(NewMemberInfo)),
									guild_manager_op:broad_cast_to_guild_client(GuildId,Message ),
									%%更新消费记录
									update_member_treasure_info({{GuildId,RoleId,Id},GuildId,RoleId,NewNum,Now}),
									%%更新数据库
									guild_spawn_db:add_info_to_membertreasureinfo(GuildId,RoleId,Id,NewNum,Now),
									%%更新帮会日志
									%%
									MemberName = guild_member_op:get_member_name(RoleId),
									MemberPosting = guild_member_op:get_member_posting(RoleId),
									ItemId = guild_proto_db:get_guild_treasureitem_itemid(ItemInfo),
									ItemTempInfo = item_template_db:get_item_templateinfo(ItemId),
									ItemName = item_template_db:get_name(ItemTempInfo),
									LogInfo = {treasure,MemberName,MemberPosting,RealPrice,ItemName,{MoneyType,Restore}},
									%%guild_manager_op:add_log(GuildId,?GUILD_LOG_MALL,LogInfo),
									%%
									%%发送限购信息
									%%
									ShowIndex = guild_proto_db:get_guild_treasureitem_showindex(ItemInfo),
									CurItem = guild_packet:make_guildtreasureitem(Id,ShowIndex,MoneyCount,NewNum),
									BuyNumMsg = guild_packet:encode_guild_treasure_update_item_s2c(ShopType,CurItem),
									role_pos_util:send_to_role_clinet(RoleId,BuyNumMsg), 
									{ok,RealPrice,ItemId}
							end
					end									 	 				
			end
	end.




delete_guild(GuildId)->
	ets:match_delete(member_treasure_list,{'_',GuildId,'_','_','_'}),
	ets:match_delete(treasure_item_price,{'_',GuildId,'_'}),
	guild_spawn_db:delete_member_treasureinfo_by_guild(GuildId),
	guild_spawn_db:delete_treasureprice_by_guildid(GuildId).

delelte_member(MemberId)->
	ets:match_delete(member_treasure_list,{'_','_',MemberId,'_','_'}),
	guild_spawn_db:delete_member_treasureinfo(MemberId).

change_treasure_price(RoleId,GuildId,ItemType,Id,Price)->
	CurPrice = get_treasure_item_realprice({GuildId,Id}),
	{MoneyType,MoneyCount} = CurPrice,
	case MoneyCount =:= Price of
		true->
			nothing;
		_->
			update_treasure_item_price_info({{GuildId,Id},GuildId,{MoneyType,Price}}),
			guild_spawn_db:add_treasurepriceinfo(GuildId,Id,{MoneyType,Price}),
			%%通知帮会成员
			Item = 
				case guild_proto_db:get_guild_treasureitem_info(Id) of
								[]->
									ItemName ="",
									[];
								ItemInfo->
									ItemId = guild_proto_db:get_guild_treasureitem_itemid(ItemInfo),
									ItemTempInfo = item_template_db:get_item_templateinfo(ItemId),
									ItemName = item_template_db:get_name(ItemTempInfo),
									ShowIndex = guild_proto_db:get_guild_treasureitem_showindex(ItemInfo),
									update_item_info_to_all(GuildId,ItemType,{Id,ShowIndex,Price})
				end,
%%			Message = guild_packet:encode_guild_treasure_update_item_s2c(ItemType,Item),
%%			guild_manager_op:broad_cast_to_guild_client(GuildId,Message),
			%%
			%%更新帮会日志
			%%
			LeaderName = guild_manager_op:get_member_name(RoleId),
			LeaderPosting = guild_manager_op:get_member_posting(RoleId),
			LogInfo = {LeaderName,LeaderPosting,ItemName,CurPrice,{MoneyType,Price}},
			guild_manager_op:add_log(GuildId,?GUILD_LOG_MODIFY_PRICES,LogInfo)						
	end.
	
%%
%% Local Functions
%%

get_member_treasure_info({GuildId,MemberId,Id})->
	case ets:lookup(member_treasure_list, {GuildId,MemberId,Id}) of
		[]-> [];
		[TreasureInfoRecord]->
			TreasureInfoRecord
	end.

get_treasure_item_price({GuildId,Id})->
	case ets:lookup(treasure_item_price, {GuildId,Id}) of
		[]-> [];
		[TreasurePriceRecord]->
			TreasurePriceRecord
	end.
	

%%
%%获取当天某商品的购买信息
%%

get_item_buy_count_today({GuildId,MemberId,Id},Now)->
	case get_member_treasure_info({GuildId,MemberId,Id}) of
		[]->
			0;
		{_,_,_,Count,Time}->
			{Today,_} = calendar:now_to_local_time(Now),
			{OtherDay,_} = calendar:now_to_local_time(Time),
			if
				Today =:= OtherDay ->
					Count;
				true->
					0
			end;
		_->
			0
	end.

get_treasure_item_realprice({GuildId,Id})->
	case get_treasure_item_price({GuildId,Id}) of
		[]->
			%%读取模板表中的原始价格
			case guild_proto_db:get_guild_treasureitem_info(Id) of
				[]->
					nothing;
				ItemInfo->
					guild_proto_db:get_guild_treasureitem_baseprice(ItemInfo)
			end;
		{_,_,Price}->
			Price
	end.

update_item_info_to_all(GuildId,ItemType,{Id,ShowIndex,Price})->
	case guild_manager_op:get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->
			Now = timer_center:get_correct_now(),
			Members = guild_manager_op:get_by_guild_item(members,GuildInfo),
			lists:foreach(fun(RoleId)->
						Item = guild_packet:make_guildtreasureitem(Id,ShowIndex,Price,
									get_item_buy_count_today({GuildId,RoleId,Id},Now)),
						Message = guild_packet:encode_guild_treasure_update_item_s2c(ItemType,Item),
						role_pos_util:send_to_role_clinet(RoleId,Message)							
				end,Members)
	end.
	