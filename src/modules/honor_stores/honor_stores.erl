%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-30
%% Description: TODO: Add description to honor_stores
-module(honor_stores).

%%
%% Include files
%%
-include("common_define.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
honor_stores_buy_items(TypePart,ItemId,Count)->
	Items = get_sell_item_by_typepart(TypePart),
	case lists:keyfind(ItemId,2,Items) of
		{Price,_}->
			CostHonor = Price * Count,
			HasHonor = role_op:check_money(?MONEY_HONOR,CostHonor),
			if
				not HasHonor->
					Message = honor_stores_packet:encode_buy_honor_item_error_s2c(?ERROR_LESS_HONOR),
					role_op:send_data_to_gate(Message);
				true->
					case package_op:can_added_to_package_template_list([{ItemId,Count}]) of
						true->
							role_op:obtain_honor(-CostHonor),
							role_op:auto_create_and_put(ItemId,Count,honor_store),
							gm_logger_role:role_buy_item_by_honor(get(roleid),ItemId,Count,Price);
						_->
							Msg = honor_stores_packet:encode_buy_honor_item_error_s2c(?ERROR_PACKEGE_FULL),
							role_op:send_data_to_gate(Msg)
					end
			end;
		_ ->
			ignor
	end.
	
get_sell_item_by_typepart(TypePart)->
	case honor_stores_db:get_sell_items_by_type(TypePart) of
		{_,_,Items}->
			Items;
		_->
			[]
	end.
