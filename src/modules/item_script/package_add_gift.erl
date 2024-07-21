%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(package_add_gift).
-export([use_item/1]).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("error_msg.hrl").
use_item(ItemInfo)->
	Slots = get_states_from_iteminfo(ItemInfo),
	case lists:keyfind(package_add, 1, Slots) of
		{_,Value}->
			case package_op:expand_package(Value) of
				ok->
					true;
				_->
					Msg = role_packet:encode_use_item_error_s2c(?ERRNO_PACKAGE_EXPAND_FULL),
					role_op:send_data_to_gate(Msg),
					false
			end;
		_->
			false
	end.
