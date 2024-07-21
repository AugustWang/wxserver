%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(loot_rules_gift).
-export([use_item/1]).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("error_msg.hrl").

use_item(ItemInfo)->
	Rules = get_states_from_iteminfo(ItemInfo),
	case package_op:get_empty_slot_in_package(erlang:length(Rules)) of
		0->
			Message = role_packet:encode_add_item_failed_s2c(?ERROR_PACKEGE_FULL),
			role_op:send_data_to_gate(Message);
		_->
			ObtItemsApply = drop:apply_quest_droplist(Rules),
			lists:foreach(fun({Itemid,ItemCount})->role_op:auto_create_and_put(Itemid,ItemCount,got_giftplayer) end,ObtItemsApply),
			true
	end.		
