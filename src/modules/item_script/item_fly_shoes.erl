%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(item_fly_shoes).
-export([use_item/4,handle_fly_shoes/4]).
-include("map_info_struct.hrl").
-include("common_define.hrl").
-include("item_define.hrl").
-include("item_struct.hrl").
-include("error_msg.hrl").

use_item(ItemInfo,MapId,Posx,Posy)->
	Qua = get_qualty_from_iteminfo(ItemInfo),
	case get_class_from_iteminfo(ItemInfo) of
		?ITEM_TYPE_FLY_SHOES->
			
					self() ! {gm_move_you,MapId,Posx,Posy},
					if
						Qua>1->
							false;
						true->
							true
					end;
		_->
			false
	end.

handle_fly_shoes(MapId,Posx,Posy,Slot)->
	OriMapId = get_mapid_from_mapinfo(get(map_info)),
	BaseCheck = 
		mapop:check_point_with_mapid(MapId,{Posx,Posy}) 
		and can_fly_shoes(OriMapId) 
		and can_fly_shoes(MapId)
		and transport_op:can_directly_telesport(),
	if
		not BaseCheck->
			nothing;
		true->
			case role_op:is_leave_attack() of
				true->
					case vip_op:check_have_vip_addition() of
						true->
							self() ! {gm_move_you,MapId,Posx,Posy};
						_->
							if
								Slot=/= 0->
									role_op:handle_use_item(Slot,[MapId,Posx,Posy]);
								true->
									Msg = vip_packet:encode_vip_error_s2c(?ERRNO_NO_VIP_FLYTIMES),
									role_op:send_data_to_gate(Msg)
							end
					end;
				_->
					Message = role_packet:encode_map_change_failed_s2c(?ERROR_NOT_LEAVE_ATTACK),
					role_op:send_data_to_gate(Message)
			end	
	end.

can_fly_shoes(MapId)->
	case map_info_db:get_map_info(MapId) of
		[]->
			true;
		MapInfo->
			(map_info_db:get_can_flyshoes(MapInfo) =:= 1)
	end.
	 