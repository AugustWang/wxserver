%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(hp_package).
-export([effect/2]).
-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").

effect(Value,SkillInput)->
	CurInfo = get(creature_info),
	RoleID = get_id_from_roleinfo(CurInfo),
	HPMax  = get_hpmax_from_roleinfo(CurInfo),
	HPNow = get_life_from_roleinfo(CurInfo),
	case (HPNow < HPMax) and (HPNow >0) of 
		true ->
			case  get(hp_package_info) of
				undefined->
					remove;
				{ItemId,_}->
					case items_op:get_item_info(ItemId) of
						[]->
							hp_package_gift:clear(),
							remove;
						ItemInfo->
							NowCount = get_duration_from_iteminfo(ItemInfo),
							BufferValue = erlang:min(erlang:min(HPMax -HPNow,Value),NowCount),				
							HPNew = HPNow+ BufferValue,
							put(creature_info, set_life_to_roleinfo(CurInfo, HPNew)),
							role_op:update_role_info(RoleID,get(creature_info)),
							role_op:self_update_and_broad([{hp,HPNew}]),
							Message = role_packet:encode_buff_affect_attr_s2c(RoleID,[role_attr:to_role_attribute({hp,BufferValue})]),
							role_op:send_data_to_gate(Message ),
							role_op:broadcast_message_to_aoi_client(Message),
							case items_op:resume_item_duration(ItemId,BufferValue) of
								nothing->
									hp_package_gift:clear(),
									remove;
								NewDuration->
									if
										NewDuration =:= 0->
											hp_package_gift:clear(),
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
