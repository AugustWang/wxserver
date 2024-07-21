%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2011-12-28
%% Description: TODO: Add description to mp_package
-module(mp_package).
-export([effect/2]).
-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").

effect(Value,_SkillInput)->
	CurInfo = get(creature_info),
	RoleID = get_id_from_roleinfo(CurInfo),
	MPMax  = get_mpmax_from_roleinfo(CurInfo),
	MPNow = get_mana_from_roleinfo(CurInfo),
	case (MPNow < MPMax) and (MPNow >0) of 
		true ->
			case  get(mp_package_info) of
				undefined->
					remove;
				{ItemId,_}->
					case items_op:get_item_info(ItemId) of
						[]->
							mp_package_gift:clear(),
							remove;
						ItemInfo->
							NowCount = get_duration_from_iteminfo(ItemInfo),
							BufferValue = erlang:min(erlang:min(MPMax -MPNow,Value),NowCount),				
							MPNew = MPNow+ BufferValue,
							put(creature_info, set_mana_to_roleinfo(CurInfo, MPNew)),
							role_op:update_role_info(RoleID,get(creature_info)),
							role_op:self_update_and_broad([{mp,MPNew}]),
							Message = role_packet:encode_buff_affect_attr_s2c(RoleID,[role_attr:to_role_attribute({mp,BufferValue})]),
							role_op:send_data_to_gate(Message),
							role_op:broadcast_message_to_aoi_client(Message),
							case items_op:resume_item_duration(ItemId,BufferValue) of
								nothing->
									mp_package_gift:clear(),
									remove;
								NewDuration->
									if
										NewDuration =:= 0->
											mp_package_gift:clear(),
											remove;
										true->
											[]
									end
							end
					end
			end;
		_->
			[]
	end.

