%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-4
%% Description: TODO: Add description to guild_treasure_item
-module(guild_treasure_item).

%%
%% Include files
%%
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").
-include("common_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
guild_get_treasure_item(ShopType)->
	case guild_util:get_guild_id() of
		0->
			nothing;
		GuildId->
			guild_manager:guild_get_treasure_item(get(roleid),GuildId,ShopType)
	end.
	
guild_treasure_buy_item(ShopType,Id,ItemId,Count)->
	case guild_util:get_guild_id() of
		0->
			nothing;
		GuildId->
			case package_op:can_added_to_package(ItemId,Count) of
				0->
					ErrMsg = guild_packet:encode_guild_opt_result_s2c(?ERROR_PACKEGE_FULL),
					role_op:send_data_to_gate(ErrMsg);
				_->
					if
						Count > 0->
							RoleInfo = get(creature_info),
							CurSilver = get_boundsilver_from_roleinfo(RoleInfo),
							CurGold = get_gold_from_roleinfo(RoleInfo),
							CurTicket = get_ticket_from_roleinfo(RoleInfo),
							RoleMoneyList = [
												{?MONEY_BOUND_SILVER,CurSilver},
												{?MONEY_GOLD,CurGold},
												{?MONEY_TICKET,CurTicket}],
							case guild_manager:guild_treasure_buy_item(get(roleid),GuildId,ShopType,Id,Count,RoleMoneyList) of
								{ok,RealPrice,ReItemId}->
									{MoneyType,MoneyCount} = RealPrice,
									role_op:money_change(MoneyType,-MoneyCount,lost_guild_treasure),
									role_op:auto_create_and_put(ReItemId,Count,got_guild_treasure);
								Error->
									slogger:msg("treasure buy error roleid ~p id ~p count ~p ERROR: ~p ~n",[get(roleid),Id,Count,Error]),
									nothing
							end;
						true->
							slogger:msg("treasure buy error roleid ~p id ~p count ~p~n",[get(roleid),Id,Count]),
							nothing
					end
			end
	end.
	
guild_treasure_set_price(ShopType,Id,Price,ItemId)->
	case guild_util:get_guild_id() of
		0->
			nothing;
		GuildId->
			guild_manager:guild_treasure_set_price(get(roleid),GuildId,ShopType,Id,Price)
	end.
