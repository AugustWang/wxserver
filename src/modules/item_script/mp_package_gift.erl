%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2011-12-28
%% Description: TODO: Add description to mp_package_info
-module(mp_package_gift).

-compile(export_all).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").

use_item(ItemInfo)->
	ItemId = get_id_from_iteminfo(ItemInfo),
	case get(mp_package_info) of
		undefined->	
			start_mp_package(ItemId);
		_->
			stop_mp_package()
	end,
	false.


start_mp_package(ItemId)->
	case items_op:get_item_info(ItemId) of
		[]->
			nothing;
		ItemInfo->
			Buffs = get_states_from_iteminfo(ItemInfo),
			role_op:add_buffers_by_self(Buffs),
			[{BuffId,BuffLevel}|_T] = Buffs,
			put(mp_package_info,{ItemId,{BuffId,BuffLevel}}),
			Msg = role_packet:encode_mp_package_s2c(ItemId,BuffId),
			role_op:send_data_to_gate(Msg)
	end.
		
stop_mp_package()->
	case get(mp_package_info) of
		undefined->
			nothing;
		{_ItemId,{BufferID,BuffLevel}}->
			role_op:remove_buffer({BufferID, BuffLevel}),
			clear()
	end.

clear()->
	case get(mp_package_info) of
		undefined->
			nothing;
		{ItemId,_}->
			Msg = role_packet:encode_mp_package_s2c(ItemId,0),
			role_op:send_data_to_gate(Msg),
			erase(mp_package_info)
	end.

export_for_copy()->
	get(mp_package_info).

load_by_copy(Info)->
	put(mp_package_info,Info).

