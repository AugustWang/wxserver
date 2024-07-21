%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(role_ride_op).

-include("slot_define.hrl").
-include("item_struct.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

is_on_ride()->
	get_role_ride()=/=0.

get_role_ride()->	
	get_ride_display_from_roleinfo(get(creature_info)).

proc_role_ride(0)->
	proc_dismount_ride();
proc_role_ride(1)->
	proc_on_ride().

hook_on_be_attack(_EnemyId)->
	case get_role_ride() of
		0->
			nothing;
		ItemTempalte->
			RideProtoInfo = ride_pet_db:get_proto_info(ItemTempalte),
			case random:uniform(100)>=ride_pet_db:get_drop_rate(RideProtoInfo) of
				true->
					nothing;
				false->
					proc_dismount_ride()
			end
	end.

hook_on_attack()->
	proc_dismount_ride().

hook_on_swap_item(DesSlot,SrcSlot)->
	if
		(DesSlot=:= ?RIDE_SLOT) or (SrcSlot=:=?RIDE_SLOT)->
			proc_dismount_ride();
		true->
			nothing
	end.

hook_on_dead()->
	proc_dismount_ride().

hook_on_dragon_fight_join_faction()->
	proc_dismount_ride().

hook_on_treasure_transport()->
	proc_dismount_ride().
	
hook_on_join_spar()->
	proc_dismount_ride().

%%true/ERRNO
check_can_ride()->
	case role_op:is_in_avatar() of
		true->
			?ERRNO_CAN_NOT_DO_IN_AVATAR;
		_->
			case role_op:is_leave_attack() of
				false->
					?ERROR_NOT_LEAVE_ATTACK;
				_->
					case role_treasure_transport:is_treasure_transporting() of
						true->
							?ERRNO_CAN_NOT_DO_IN_TREASURE_TRANSPORT;
						_->
							case spa_op:is_in_spa() of
								true->
									?ERRNO_CAN_NOT_DO_IN_SPA;
								_->
									true
							end
					end
			end
	end.
		
					
proc_on_ride()->
	ItemInfo =  package_op:get_iteminfo_in_normal_slot(?RIDE_SLOT),
	BaseCheck = (not is_on_ride()) and (ItemInfo =/= []),
	if
		BaseCheck->
			case check_can_ride() of
				true->
					role_sitdown_op:hook_on_action_async_interrupt(timer_center:get_correct_now(),ride_pet),
					TemplateId = get_template_id_from_iteminfo(ItemInfo),
					RideProtoInfo = ride_pet_db:get_proto_info(TemplateId),
					RideBuffs = ride_pet_db:get_add_buff(RideProtoInfo),
					put(creature_info, set_ride_display_to_roleinfo(get(creature_info), TemplateId)),
					role_op:self_update_and_broad([{ride_display,TemplateId}]),
					role_op:be_add_buffer(RideBuffs,{0,ride});
				ERRNO->
					role_op:send_data_to_gate(ride_pet_packet:encode_ride_opt_result_s2c(ERRNO))
			end;
		true->
			nothing
	end.

proc_dismount_ride()->
	case is_on_ride() of
		true->
			put(creature_info, set_ride_display_to_roleinfo(get(creature_info),0)),
			role_op:self_update_and_broad([{ride_display,0}]),
			RideBuffers = buffer_op:get_buffers_cast_by_ride(),
			role_op:remove_buffers(RideBuffers);
		_->
			nothing
	end.
  