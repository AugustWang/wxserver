%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(item_money_gift).
-export([use_item/1]).
-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").

use_item(ItemInfo)->
	Moneys = get_states_from_iteminfo(ItemInfo),
	lists:foreach(fun({Type,Value})->
						  role_op:money_change(Type,Value,got_giftplayer)
					end,Moneys),
	true.		
			
