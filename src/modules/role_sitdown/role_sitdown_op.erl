%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(role_sitdown_op).

-export([init/0,can_sitdown/0,check_sitdown_time/1,hook_on_action_async_interrupt/2,hook_on_action_sync_interrupt/2,interrupt_sitdown_with_processor_state_change/0]).

-export([handle_start_sitdown_with_role/1,interrupt_companion_sitdown/0,handle_companion_sitdown/1,handle_other_role_msg/2]).

-export([del_role_from_companion/0]).

-include("sitdown_define.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("creature_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("login_pb.hrl").
-include("little_garden.hrl").

init()->
	put(last_action_time,timer_center:get_correct_now()).

interrupt_companion_sitdown()->
	case get_companion_role_from_roleinfo(get(creature_info)) of
		0->
			nothing;
		CompanionRoleId->
			del_role_from_companion(),
			role_op:self_update_and_broad([{companion_role,0}]),
			case creature_op:get_creature_info(CompanionRoleId) of
				undefined->
					nothing;
				CompanionRoleInfo->	
					send_to_other_role_del_companion(CompanionRoleInfo)
			end
	end.

hook_on_action_async_interrupt(Now,_Acation)->
	put(last_action_time,Now),
	case get_state_from_roleinfo(get(creature_info)) of
		sitting->
			util:send_state_event(self(),{interrupt_sitdown});
		_->
			nothing
	end.

%%do processor state change in call fun 
hook_on_action_sync_interrupt(Now,_Acation)->
	put(last_action_time,Now),
	case get_state_from_roleinfo(get(creature_info)) of
		sitting->
			interrupt_sitdown_with_processor_state_change();
		_->
			nothing
	end.

check_sitdown_time(Now)->
	case timer:now_diff(Now, get(last_action_time)) >= ?TIME_TO_SITDOWN*1000 of
		true->
			case can_sitdown() of
				true->
					sitdown_packet:handle(#sitdown_c2s{},self());
				_->
					put(last_action_time,Now)					
			end;
		_->
			nothing
	end.			

%%坐骑状态可以打做，原来不能打坐 by zhangting
can_sitdown()->
	CurState = get_state_from_roleinfo(get(creature_info)),
	StateCheck = (CurState=:=gaming) or (CurState=:=moving),
	
	WorldCheck = get(is_in_world),
	MapCheck = not block_training_op:is_in_training_map(),
	DisPlayChange = not role_op:is_in_avatar(),
	Treasure_transport_Check = not role_treasure_transport:is_treasure_transporting(),
	LevelCheck = (get(level)>=?ROLE_SITDOWN_RESTRICT_MIN_LEVEL),
	StateCheck and WorldCheck and MapCheck and DisPlayChange and LevelCheck and Treasure_transport_Check. 


can_sitdown_old()->
	CurState = get_state_from_roleinfo(get(creature_info)),
	StateCheck = (CurState=:=gaming) or (CurState=:=moving),
	RideCheck = not role_ride_op:is_on_ride(),
	WorldCheck = get(is_in_world),
	MapCheck = not block_training_op:is_in_training_map(),
	DisPlayChange = not role_op:is_in_avatar(),
	Treasure_transport_Check = not role_treasure_transport:is_treasure_transporting(),
	LevelCheck = (get(level)>=?ROLE_SITDOWN_RESTRICT_MIN_LEVEL),
	RideCheck and StateCheck and WorldCheck and MapCheck and DisPlayChange and LevelCheck and Treasure_transport_Check. 

can_companion_with(OtherInfo)->
	(get_companion_role_from_roleinfo(OtherInfo)=:=0) 
	and (get_state_from_roleinfo(OtherInfo) =:= sitting)
	and (get_gender_from_roleinfo(OtherInfo) =/= get_gender_from_roleinfo(get(creature_info))).

handle_companion_sitdown(#companion_sitdown_apply_c2s{roleid = RoleId})->
	case get_state_from_roleinfo(get(creature_info)) of
		sitting->
			case creature_op:is_in_aoi_list(RoleId) of
				true->
					Msg = sitdown_packet:encode_companion_sitdown_apply_s2c(get(roleid)),
					role_op:send_to_other_client(RoleId,Msg);
				_->
					Msg = sitdown_packet:encode_companion_sitdown_result_s2c(?SITDOWN_ERROR_NO_ROLE_INAOI),
					role_op:send_data_to_gate(Msg)
			end;
		_->
			nothing
	end;

handle_companion_sitdown(#companion_reject_c2s{roleid = RoleId})->
	Message = sitdown_packet:encode_companion_reject_s2c(get_name_from_roleinfo(get(creature_info))),
	role_pos_util:send_to_role_clinet(RoleId, Message);
	
handle_companion_sitdown(_)->
	todo.
			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%							state_change!!!!!!!!!!!!!!!!!!!!!!!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%other has add you!
handle_add_companion_role_when_sitdown(RoleId)->
	case creature_op:get_creature_info(RoleId) of
		undefined->
			nothing;
		OtherInfo->
			case can_companion_with(OtherInfo) of
				true->
					case call_companion_sitdown_with_me(OtherInfo) of
						ok->
							set_role_to_companion(RoleId),
							clear_sitdown_buff(),
							role_op:add_buffers_by_self([get_adapt_companion_sitdown_buff()]),
							role_op:update_role_info(get(roleid),get(creature_info)),
							role_op:self_update_and_broad([{companion_role,RoleId}]);
						_->
							nothing
					end;
				_->
					nothing
			end
	end.

handle_start_sitdown_with_role(RoleId)->
	put(creature_info, set_state_to_roleinfo(get(creature_info), sitting)),
	if
		RoleId =:=[]->
			UpdateValues = [{state,?CREATURE_STATE_SITDOWN}],
			Buff = ?SITDOWN_BUFF;%%COMPANION_ROLE_BUFF COMPANION_ROLE_POS_BUFF
		true->
			case creature_op:get_creature_info(RoleId) of
				undefined->
					UpdateValues = [{state,?CREATURE_STATE_SITDOWN}],
					Buff = ?SITDOWN_BUFF;
				OtherInfo->
					case can_companion_with(OtherInfo) of
						true ->
							case call_companion_sitdown_with_me(OtherInfo) of
								ok->
									set_role_to_companion(RoleId),
									UpdateValues = [{state,?CREATURE_STATE_SITDOWN},{companion_role,RoleId}],
									Buff = get_adapt_companion_sitdown_buff();
								_->
									UpdateValues = [{state,?CREATURE_STATE_SITDOWN}],
									Buff = ?SITDOWN_BUFF
							end;
						_->
							UpdateValues = [{state,?CREATURE_STATE_SITDOWN}],
							Buff = ?SITDOWN_BUFF
					end
			end
	end,
	role_op:add_buffers_by_self([Buff]),
	role_op:self_update_and_broad(UpdateValues).

%%del buf,start check 
%%call this fun ,processor state must change to gaming from sitting 
interrupt_sitdown_with_processor_state_change()->
	init(),
	interrupt_companion_sitdown(),
	put(creature_info, set_state_to_roleinfo(get(creature_info), gaming)),
	clear_sitdown_buff(),
	role_op:self_update_and_broad([{state,?CREATURE_STATE_GAME}]).

call_companion_sitdown_with_me(RoleInfo)->
	try
		Pid = get_pid_from_roleinfo(RoleInfo),
		role_processor:companion_sitdown_with_me(Pid,get(roleid))
	catch
		_E:_R->
			error
	end.
 
%%Type:add_companion_sitdown/
send_to_other_role_del_companion(RoleInfo)->
	try
		Pid = get_pid_from_roleinfo(RoleInfo),
		gen_fsm:send_event(Pid,{del_companion_sitdown,get(roleid)}),
		ok
	catch
		_E:_R->
			error
	end.

%%ok/error
handle_other_role_msg(add_companion_sitdown,RoleId)->
	case get_companion_role_from_roleinfo(get(creature_info))of
		0->
			set_role_to_companion(RoleId),
			clear_sitdown_buff(),
			role_op:add_buffers_by_self([get_adapt_companion_sitdown_buff()]),
			role_op:update_role_info(get(roleid),get(creature_info)),
			role_op:self_update_and_broad([{companion_role,RoleId}]),
			ok;
		CompanionNow->
			io:format("companion sitdown but receive add_companion_sitdown Companion Now ~p ~n",[CompanionNow]),
			error
	end;
handle_other_role_msg(del_companion_sitdown,RoleId)->
	case get_companion_role_from_roleinfo(get(creature_info))of
		RoleId->
			del_role_from_companion(),
			change_buff_from_companion_to_single(),
			role_op:self_update_and_broad([{companion_role,0}]);
		_->
			nothing
	end.

set_role_to_companion(RoleId)->
	put(creature_info, set_companion_role_to_roleinfo(get(creature_info), RoleId)).

del_role_from_companion()->
	put(creature_info, set_companion_role_to_roleinfo(get(creature_info), 0)).

%%clear all sitdown buff
clear_sitdown_buff()->
	role_op:remove_buffers([?SITDOWN_BUFF,?COMPANION_ROLE_BUFF,?COMPANION_ROLE_POS_BUFF]).

%%get_adapt_sitdown_buff
get_adapt_companion_sitdown_buff()->
	case mapop:is_companion_addation_pos(get_pos_from_roleinfo(get(creature_info)),get(map_db)) of
		true->
			?COMPANION_ROLE_POS_BUFF;
		_->
			?COMPANION_ROLE_BUFF
	end.

change_buff_from_companion_to_single()->
	case get_state_from_roleinfo(get(creature_info)) of
		sitting->
			clear_sitdown_buff(),
			role_op:add_buffers_by_self([?SITDOWN_BUFF]);
		_->
			clear_sitdown_buff()
	end.