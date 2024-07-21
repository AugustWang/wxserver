%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-12-1
%% Description: TODO: Add description to item_add_role_integral
-module(item_add_role_integral).

%%
%% Include files
%%
-include("item_struct.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
use_item(ItemInfo)->
	Integral = get_states_from_iteminfo(ItemInfo),
	case lists:keyfind(add_charge_integral, 1, Integral) of
		{_,Value}->
			mall_op:add_role_charge_integral_by_value(Value),
			true;
		_->
			false
	end.
