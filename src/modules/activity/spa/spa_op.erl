%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-9-29
%% Description: TODO: Add description to spa_op
-module(spa_op).

%%
%% Include files
%%
-define(SPA_BUFFER_TIME_S,60).
-define(SPA_BUFFER_END_TIME_S,0).
-define(SPA_CHOPPING_GOLD,8).
-define(ROLE_SPA_INFO,role_spa_info).
-define(ROLE_SPA_STATE,role_spa_state).
-define(ROLE_SPA_ACTIVITY,role_spa_activity).
%%
%% Exported Functions
%%
-export([init/0,load_from_db/1,export_for_copy/0,load_by_copy/1,write_to_db/0,
		 spa_join_c2s/1,hook_on_online/0,hook_on_offline/0,
		 spa_request_spalist_c2s/0,spa_leave_c2s/0,get_map_proc_name/0,
		 spa_swimming_c2s/1,spa_chopping_c2s/1,check_cooltime/1,
		 handle_spa_touch/2,handle_be_spa_touch/2,is_in_spa/0,
		 spa_chopping_with_gold/1,hook_on_role_levelup/1,
		 spa_apply_stop_player/0,hook_on_vip_up/2]).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("instance_define.hrl").
-include("little_garden.hrl").
-include("activity_define.hrl").
-include("error_msg.hrl").
-include("game_map_define.hrl").
-include("map_info_struct.hrl").
-include("item_define.hrl").
-include("common_define.hrl").
%%
%% API Functions
%%
init()->
	%%role_spa_info={roleid,node,mapproc,spaid,spatime,
	%%{{chopping,bechopping,cool},{swimming,beswimming,cool}}}
	put(?ROLE_SPA_INFO,[]),
	put(?ROLE_SPA_STATE,?SPA_ROLE_STATE_LEAVE),
	put(?ROLE_SPA_ACTIVITY,?ACTIVITY_STATE_STOP),
	hook_on_online().

load_from_db(_RoleId)->
	todo.

export_for_copy()->
	{get(?ROLE_SPA_STATE),get(?ROLE_SPA_INFO),get(?ROLE_SPA_ACTIVITY)}.
	
write_to_db()->
	nothing.

load_by_copy({RoleSpaState,RoleSpaInfo,RoleSpaActivity})->
	put(?ROLE_SPA_STATE,RoleSpaState),
	put(?ROLE_SPA_INFO,RoleSpaInfo),
	put(?ROLE_SPA_ACTIVITY,RoleSpaActivity).

is_in_spa()->
	case get(?ROLE_SPA_STATE) of
		?SPA_ROLE_STATE_JOIN->
			true;
		_->
			false
	end.

spa_request_spalist_c2s()->
	activity_manager:request_spalist(get(roleid)).

get_map_proc_name()->
	case get(?ROLE_SPA_INFO) of
		[]->
			[];
		{_,_,MapProc,_,_,_}->
			MapProc
	end.

spa_join_c2s(SpaId)->
	Errno = 
	case get(?ROLE_SPA_STATE) of
		?SPA_ROLE_STATE_LEAVE->
			spa_join_request(SpaId);
		_->
			?ERRNO_NPC_EXCEPTION
	end,
	if 
		Errno =/= []->
			Message_failed = spa_packet:encode_spa_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

spa_join_request(SpaId)->
	SpaOption = spa_db:get_option_info(?SPA_DEFAULT_ID),
	Duration = spa_db:get_spa_duration(SpaOption),
	InstanceId = spa_db:get_spa_instance_proto(SpaOption),
	RoleVipExt = vip_op:get_role_vip_ext(vip_op:get_role_vip()),
	case lists:keyfind(RoleVipExt, 1, spa_db:get_spa_vip_op_addition(SpaOption)) of
		false->
			VipOp = 0;
		{_,Op}->
			VipOp = Op
	end,
	Chopping = spa_db:get_spa_chopping(SpaOption)+VipOp,
	Swimming = spa_db:get_spa_swimming(SpaOption)+VipOp,
	InstanceInfo = instance_proto_db:get_info(InstanceId),
	{LevelStart,LevelEnd} = instance_proto_db:get_level(InstanceInfo),
	case  transport_op:can_directly_telesport() and (not role_op:is_dead()) of
		true->
			case activity_op:handle_join_without_instance(
		   		?SPA_ACTIVITY,
		   		LevelStart,
		   		LevelEnd,
		   		[SpaId,Chopping,Swimming]) of
				{ok,Node,MapProc,SpaTime,Info}->
					{{RealChopping,_,LastChoppingTime},{RealSwimming,_,LastSwimmingTime}} = Info,
					put(?ROLE_SPA_STATE,?SPA_ROLE_STATE_JOIN),
					put(?ROLE_SPA_INFO,{get(roleid),Node,MapProc,SpaId,SpaTime,Info}),
					LeftTime = trunc((Duration - timer:now_diff(timer_center:get_correct_now(),SpaTime)/1000)/1000),
					LeftChopping = trunc(timer:now_diff(timer_center:get_correct_now(),LastChoppingTime)/1000000),
					LeftSwimming = trunc(timer:now_diff(timer_center:get_correct_now(),LastSwimmingTime)/1000000),
					Message = spa_packet:encode_spa_join_s2c(SpaId, RealChopping, RealSwimming, LeftTime,LeftChopping,LeftSwimming),
					role_op:send_data_to_gate(Message),
					Errno=[],
					do_join_instance(InstanceId);
				joined->
					Errno=?ERROR_ACTIVITY_IS_JOINED;
				state_error->
					Errno=?ERROR_ACTIVITY_STATE_ERR;
				level_error->
					Errno=?ERROR_ACTIVITY_LEVEL_ERR;
				instance_error->
					Errno=?ERROR_ACTIVITY_INSTANCE_ERR;
				no_activity->
					Errno=?ERROR_ACTIVITY_NOT_EXSIT;
				full->
					Errno=?ERROR_ACTIVITY_IS_FULL;
				_->
					Errno=[]
			end;
		_->
			Errno=?ERROR_ACTIVITY_INSTANCE_ERR
	end,
	Errno.

do_join_instance(InstanceId)->
	case get(?ROLE_SPA_INFO) of
		[]->
			false;
		{_RoleId,_Node,MapProc,_SpaId,_SpaTime,_Info}->
			case instance_pos_db:get_instance_pos_from_mnesia(
				   instance_op:make_id_by_creationtag(atom_to_list(MapProc), InstanceId)) of			
				[]->
%% 					io:format("instance_pos_db:get_instance_pos_from_mnesia(erlang:atom_to_list(MapProc)) ~n"),
					false;
				{_Id,_Creation,_StartTime,CanJoin,InstanceNode ,_Pid,MapId,ProtoId,_Members}->
					ProtoInfo = instance_proto_db:get_info(ProtoId),
					if
						CanJoin->
							pet_op:call_back(),
							role_ride_op:hook_on_join_spar(),
							gm_logger_role:spa_log(get(roleid),get_level_from_roleinfo(get(creature_info)),1,0),
							activity_value_op:update({join_activity,?SPA_ACTIVITY}),
							Pos = lists:nth(random:uniform(erlang:length(?SPA_SPAWN_POS)),?SPA_SPAWN_POS),
							instance_op:trans_to_dungeon(false,MapProc,get(map_info),Pos ,
														 ?INSTANCE_TYPE_SPA,ProtoInfo,InstanceNode,MapId);
							true;
						true->
							false
					end	
			end
	end.

hook_on_online()->
	InfoList = answer_db:get_activity_info(?SPA_ACTIVITY),
	CheckFun = fun(Info)->
				{Type,StartLines} = answer_db:get_activity_start(Info),
				case activity_manager_op:check_is_time_line(Type,StartLines) of
					{true,_}->
						true;
					_->
						false
				end
	end,
	States = lists:map(CheckFun, InfoList),
	case lists:member(true,States) of
		true->
			case activity_manager:get_activity_state(?SPA_ACTIVITY) of
				?ACTIVITY_STATE_START->
					put(?ROLE_SPA_ACTIVITY,?ACTIVITY_STATE_START),
					SpaInfo = spa_db:get_option_info(?SPA_DEFAULT_ID),
					InstanceId = spa_db:get_spa_instance_proto(SpaInfo),
					InstanceInfo = instance_proto_db:get_info(InstanceId),
					{LevelStart,_LevelEnd} = instance_proto_db:get_level(InstanceInfo),
					Message = spa_packet:encode_spa_start_notice_s2c(LevelStart),
					role_op:send_data_to_gate(Message);
				_->
					nothing
			end;
		_->
			nothing
	end.

hook_on_role_levelup(Level)->
	ActivityState = get(?ROLE_SPA_ACTIVITY),
	RoleSpaState = get(?ROLE_SPA_STATE),
	if
		ActivityState=:=?ACTIVITY_STATE_START,
		RoleSpaState=/=?SPA_ROLE_STATE_JOIN->
			SpaInfo = spa_db:get_option_info(?SPA_DEFAULT_ID),
			InstanceId = spa_db:get_spa_instance_proto(SpaInfo),
			InstanceInfo = instance_proto_db:get_info(InstanceId),
			{LevelStart,_LevelEnd} = instance_proto_db:get_level(InstanceInfo),
			if
				Level >= LevelStart->
					Message = spa_packet:encode_spa_start_notice_s2c(LevelStart),
					role_op:send_data_to_gate(Message);
				true->
					nothing
			end;
		true->
			nothing
	end.

hook_on_vip_up(OriLevel,NewLevel)->
	if
		NewLevel>OriLevel->
			SpaOption = spa_db:get_option_info(?SPA_DEFAULT_ID),
			OriVipExt = vip_op:get_role_vip_ext(OriLevel),
			NewVipExt = vip_op:get_role_vip_ext(NewLevel),
			OriCount =
			case lists:keyfind(OriVipExt, 1, spa_db:get_spa_vip_op_addition(SpaOption)) of
				false->
					0;
				{_,OriOp}->
					OriOp
			end,
			NewCount =
			case lists:keyfind(NewVipExt, 1, spa_db:get_spa_vip_op_addition(SpaOption)) of
				false->
					0;
				{_,NewOp}->
					NewOp
			end,
			AddCount = NewCount - OriCount,
			if
				AddCount>0->
					case get(?ROLE_SPA_INFO) of
						[]->
							nothing;
						RoleSpaInfo->
							{RoleId,Node,MapProc,SpaId,SpaTime,
							 {{Chopping,ChPassive,ChTime},{Swimming,SwPassive,SwTime}}} = RoleSpaInfo,
							NewRoleSpaInfo = {RoleId,Node,MapProc,SpaId,SpaTime,
							{{Chopping+AddCount,ChPassive,ChTime},{Swimming+AddCount,SwPassive,SwTime}}},
							put(?ROLE_SPA_INFO,NewRoleSpaInfo),
							activity_manager:spa_add_vip_count(RoleId,AddCount),
							Message = spa_packet:encode_spa_update_count_s2c(Chopping+AddCount, Swimming+AddCount),
							role_op:send_data_to_gate(Message)
					end;
				true->
					nothing
			end;
		true->
			nothing
	end.

hook_on_offline()->
	case get(?ROLE_SPA_STATE) of
		?SPA_ROLE_STATE_LEAVE->
			nothing;
		_->
			case get(?ROLE_SPA_INFO) of
				[]->
					nothing;
				RoleSpaInfo->
					{RoleId,_,_,SpaId,_,_} = RoleSpaInfo,
					activity_manager:apply_leave_activity(?SPA_ACTIVITY,
														  {RoleId,SpaId,?SPA_ROLE_STATE_LEAVE})
			end
	end.

spa_apply_stop_player()->
	case get(?ROLE_SPA_STATE) of
		?SPA_ROLE_STATE_LEAVE->
			nothing;
		_->
			case get(?ROLE_SPA_INFO) of
				[]->
					nothing;
				RoleSpaInfo->
					{RoleId,Node,MapProc,SpaId,_SpaTime,Info} = RoleSpaInfo,
					activity_manager:apply_leave_activity(?SPA_ACTIVITY,{RoleId,SpaId,?SPA_ROLE_STATE_LEAVE}),
					put(?ROLE_SPA_STATE,?SPA_ROLE_STATE_LEAVE),
					put(?ROLE_SPA_ACTIVITY,?ACTIVITY_STATE_STOP),
					put(?ROLE_SPA_INFO,{RoleId,Node,MapProc,SpaId,{0,0,0},Info}),
					Message = spa_packet:encode_spa_leave_s2c(),
					role_op:send_data_to_gate(Message),
					instance_op:kick_instance_by_reason({?INSTANCE_TYPE_SPA,MapProc})
			end
	end.

spa_leave_c2s()->
	case get(?ROLE_SPA_STATE) of
		?SPA_ROLE_STATE_LEAVE->
			nothing;
		_->
			case get(?ROLE_SPA_INFO) of
				[]->
					nothing;
				RoleSpaInfo->
					{RoleId,Node,MapProc,SpaId,_SpaTime,Info} = RoleSpaInfo,
					activity_manager:apply_leave_activity(?SPA_ACTIVITY,{RoleId,SpaId,?SPA_ROLE_STATE_LEAVE}),
					put(?ROLE_SPA_STATE,?SPA_ROLE_STATE_LEAVE),
					put(?ROLE_SPA_INFO,{RoleId,Node,MapProc,SpaId,{0,0,0},Info}),
					Message = spa_packet:encode_spa_leave_s2c(),
					role_op:send_data_to_gate(Message),
					instance_op:kick_instance_by_reason({?INSTANCE_TYPE_SPA,MapProc})
			end
	end.

spa_swimming_c2s(RoleId)->
	case get(?ROLE_SPA_INFO) of
		[]->
			nothing;
		{MyRoleId,_Node,_MapProc,SpaId,_SpaTime,OpInfo}->
			{_,{Swimming,_,CoolTime}} = OpInfo,
			CheckCoolTime = check_cooltime(CoolTime),
			if RoleId=/=0-> 
				if Swimming>0->
					if CheckCoolTime->
						Errno=[],
						activity_manager:spa_touch_other_role(?SPA_TOUCH_TYPE_SWIMMING,{SpaId, MyRoleId, RoleId});
					   true->
						Errno=?ERROR_ACTIVITY_COOLTIME_SWIMMING_ERR
			    	end;
				   true->
					   Errno=?ERROR_SPA_TOUCH_LIMIT_ERR
				end;
			   true->
				   Errno=[]
			end,
			achieve_op:achieve_update({spa},[0],1),%%@@wb20130410鏇存柊鎴忔按鎴愬氨
			if Errno=/=[]->
				Message = spa_packet:encode_spa_error_s2c(Errno),
				role_op:send_data_to_gate(Message);
			   true->
				nothing
			end
	end.

spa_chopping_c2s(RoleId)->
	case get(?ROLE_SPA_INFO) of
		[]->
			nothing;
		{MyRoleId,_Node,_MapProc,SpaId,_SpaTime,OpInfo}->
			{{Chopping,_,CoolTime},_} = OpInfo,
			CheckCoolTime = check_cooltime(CoolTime),
			if RoleId=/=0-> 
				if Chopping>0->
					if CheckCoolTime->
						Errno=[],
						activity_manager:spa_touch_other_role(?SPA_TOUCH_TYPE_CHOPPING,{SpaId, MyRoleId, RoleId,false});
					   true->
						Errno=?ERROR_ACTIVITY_COOLTIME_CHOPPING_ERR
			    	end;
				   true->
					   Errno=?ERROR_SPA_TOUCH_LIMIT_ERR
				end;
			   true->
				   Errno=[]
			end,
			achieve_op:achieve_update({spa_rub},[0],1),%%@@wb20130410鏇存柊鎼撴尽鎴愬氨
			if Errno=/=[]->
				Message = spa_packet:encode_spa_error_s2c(Errno),
				role_op:send_data_to_gate(Message);
			   true->
				nothing
			end
	end.

spa_chopping_with_gold(RoleId)->
	case get(?ROLE_SPA_INFO) of
		[]->
			nothing;
		{MyRoleId,_Node,_MapProc,SpaId,_SpaTime,OpInfo}->
			{{Chopping,_,CoolTime},_} = OpInfo,
			CheckCoolTime = check_cooltime(CoolTime),
			if RoleId=/=0-> 
				if Chopping>0->
					if CheckCoolTime->
						case role_op:check_money(?MONEY_GOLD, ?SPA_CHOPPING_GOLD) of
							true->
								Errno=[],
								activity_manager:spa_touch_other_role(?SPA_TOUCH_TYPE_CHOPPING,{SpaId, MyRoleId, RoleId,true});
							false->
								Errno=?ERROR_LESS_MONEY
						end;
					   true->
						Errno=?ERROR_ACTIVITY_COOLTIME_CHOPPING_ERR
			    	end;
				   true->
					   Errno=?ERROR_SPA_TOUCH_LIMIT_ERR
				end;
			   true->
				   Errno=[]
			end,
			if Errno=/=[]->
				Message = spa_packet:encode_spa_error_s2c(Errno),
				role_op:send_data_to_gate(Message);
			   true->
				nothing
			end
	end.

check_cooltime(CoolTime)->
	case CoolTime of
		{0,0,0}->
			true;
		_->
			timer:now_diff(timer_center:get_correct_now(),CoolTime) >= ?SPA_COOL_TIME*1000
	end.
%%
%% Local Functions
%%
handle_spa_touch(Type,Message)->
	case Type of
		?SPA_TOUCH_TYPE_CHOPPING->
			handle_spa_chopping(Message);
		?SPA_TOUCH_TYPE_SWIMMING->
			handle_spa_swimming(Message);
		_->
			nothing
	end.
		
handle_spa_chopping(Message)->
	case get(?ROLE_SPA_INFO) of
		[]->
			nothing;
		{RoleId,Node,MapProc,SpaId,SpaTime,Info}->
			Name = get_name_from_roleinfo(get(creature_info)),
			{BeName,NewChopping,NewTime,IsGold} = Message,
			{{_,Passive,_},SwimmingInfo} = Info,
			NewInfo = {{NewChopping,Passive,NewTime},SwimmingInfo},
			put(?ROLE_SPA_INFO,{RoleId,Node,MapProc,SpaId,SpaTime,NewInfo}),
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			SpaExpInfo = spa_db:get_spa_exp_info(RoleLevel),
			AddExp = spa_db:get_spa_exp_chopping_self(SpaExpInfo),
			if
				IsGold->
					role_op:money_change(?MONEY_GOLD, -?SPA_CHOPPING_GOLD, lost_spa_chopping);
				true->
					item_util:consume_items_by_classid(?ITEM_TYPE_SPA_SOAP,1)
			end,
			role_op:obtain_exp(AddExp),
			MessageData = spa_packet:encode_spa_chopping_s2c(Name, BeName, NewChopping),
			role_op:send_data_to_gate(MessageData),
			role_op:broadcast_message_to_aoi_client(MessageData)
	end.

handle_spa_swimming(Message)->
	case get(?ROLE_SPA_INFO) of
		[]->
			nothing;
		{RoleId,Node,MapProc,SpaId,SpaTime,Info}->
			Name = get_name_from_roleinfo(get(creature_info)),
			{BeName,NewSwimming,NewTime} = Message,
			{ChoppingInfo,{_,Passive,_}} = Info,
			NewInfo = {ChoppingInfo,{NewSwimming,Passive,NewTime}},
			put(?ROLE_SPA_INFO,{RoleId,Node,MapProc,SpaId,SpaTime,NewInfo}),
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			SpaExpInfo = spa_db:get_spa_exp_info(RoleLevel),
			AddExp = spa_db:get_spa_exp_swimming_self(SpaExpInfo),
			role_op:obtain_exp(AddExp),
			MessageData = spa_packet:encode_spa_swimming_s2c(Name, BeName, NewSwimming),
			role_op:send_data_to_gate(MessageData),
			role_op:broadcast_message_to_aoi_client(MessageData)
	end.


			
handle_be_spa_touch(Type,Message)->
	case Type of
		?SPA_TOUCH_TYPE_CHOPPING->
			handle_be_spa_chopping(Message);
		?SPA_TOUCH_TYPE_SWIMMING->
			handle_be_spa_swimming(Message);
		_->
			nothing
	end.
			
handle_be_spa_chopping(Message)->
	case get(?ROLE_SPA_INFO) of
		[]->
			nothing;
		{RoleId,Node,MapProc,SpaId,SpaTime,Info}->
			_BeName = get_name_from_roleinfo(get(creature_info)),
			{_Name,NewPassive} = Message,
			{{Chopping,_Passive,CoolTime},SwimmingInfo} = Info,
			NewInfo = {{Chopping,NewPassive,CoolTime},SwimmingInfo},
			put(?ROLE_SPA_INFO,{RoleId,Node,MapProc,SpaId,SpaTime,NewInfo}),
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			SpaExpInfo = spa_db:get_spa_exp_info(RoleLevel),
			AddExp = spa_db:get_spa_exp_chopping_be(SpaExpInfo),
			role_op:obtain_exp(AddExp)
	end.

handle_be_spa_swimming(Message)->
	case get(?ROLE_SPA_INFO) of
		[]->
			nothing;
		{RoleId,Node,MapProc,SpaId,SpaTime,Info}->
			_BeName = get_name_from_roleinfo(get(creature_info)),
			{_Name,NewPassive} = Message,
			{ChoppingInfo,{Swimming,_Passive,CoolTime}} = Info,
			NewInfo = {ChoppingInfo,{Swimming,NewPassive,CoolTime}},
			put(?ROLE_SPA_INFO,{RoleId,Node,MapProc,SpaId,SpaTime,NewInfo}),
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			SpaExpInfo = spa_db:get_spa_exp_info(RoleLevel),
			AddExp = spa_db:get_spa_exp_swimming_be(SpaExpInfo),
			role_op:obtain_exp(AddExp)
	end.
