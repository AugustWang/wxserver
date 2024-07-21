%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(item_exp_gift).
-export([use_item/1]).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").

use_item(ItemInfo)->
	Moneys = get_states_from_iteminfo(ItemInfo),
	case lists:keyfind(exp_add, 1, Moneys) of
		{_,Value}->
			role_op:obtain_exp(Value),
			true;
		_->
			false
	end.
