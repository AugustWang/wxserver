%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(hp_package_gift).
-compile(export_all).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").

use_item(ItemInfo)->
	ItemId = get_id_from_iteminfo(ItemInfo),
	case get(hp_package_info) of
		undefined->			
			start_hp_package(ItemId);
		_->
			stop_hp_package()
	end,
	false.


start_hp_package(ItemId)->
	case items_op:get_item_info(ItemId) of
		[]->
			nothing;
		ItemInfo->
			Buffs = get_states_from_iteminfo(ItemInfo),
			role_op:add_buffers_by_self(Buffs),
			[{BuffId,BuffLevel}|_T] = Buffs,
			put(hp_package_info,{ItemId,{BuffId,BuffLevel}}),
			Msg = role_packet:encode_hp_package_s2c(ItemId,BuffId),
			role_op:send_data_to_gate(Msg)
	end.
		
stop_hp_package()->
	case get(hp_package_info) of
		undefined->
			nothing;
		{_ItemId,{BufferID,BuffLevel}}->
			role_op:remove_buffer({BufferID, BuffLevel}),
			clear()
	end.

clear()->
	case get(hp_package_info) of
		undefined->
			nothing;
		{ItemId,{_BufferID,_BuffLevel}}->%%@@wb20130426è§£å†³ä¸èƒ½åœæ­¢ä½¿ç”¨çš„é—®é¢˜
			Msg = role_packet:encode_hp_package_s2c(ItemId,0),
			role_op:send_data_to_gate(Msg),
			erase(hp_package_info)
	end.

export_for_copy()->
	get(hp_package_info).

load_by_copy(Info)->
	put(hp_package_info,Info).


