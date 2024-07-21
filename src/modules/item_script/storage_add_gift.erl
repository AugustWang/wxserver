%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-9-17
%% Description: TODO: Add description to storage_add_gift
-module(storage_add_gift).

-export([use_item/1]).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("error_msg.hrl").
use_item(ItemInfo)->
	Slots = get_states_from_iteminfo(ItemInfo),
	case lists:keyfind(storage_add, 1, Slots) of
		{_,Value}->
			case package_op:expand_storage(Value) of
				ok->
					true;
				_->
					Msg = role_packet:encode_use_item_error_s2c(?ERRNO_STORAGE_EXPAND_FULL),
					role_op:send_data_to_gate(Msg),
					false
			end;
		_->
			false
	end.

