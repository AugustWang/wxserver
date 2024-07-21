%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-9-27
%% Description: TODO: Add description to spa_manager_op
-module(spa_manager_op).

%%
%% Include files
%%
-define(SPA_BUFFER_TIME_S,70).
-define(SPA_BUFFER_END_TIME_S,120).
-define(SPA_SEND_NOTICE_BUFFER_TIME_S,60).
-define(SPA_MANAGER_STATE,spa_manager_state).
%%spa_info {SpaId,Node,MapProc,JoinCount,InstanceLimit}
-define(SPA_INFO,spa_info).
%%spa_role_info {RoleId,RoleName,SpaId,JoinState,
%%OtherInfo={choppinginfo,swimminginfo}}
-define(SPA_ROLE_INFO,spa_role_info).
-define(SPA_TIME,spa_time).
-define(SPA_MAX_MAP_NUM,5).


-include("activity_define.hrl").
-include("error_msg.hrl").
-include("npc_define.hrl").
%%
%% Exported Functions
%%
-export([init/0,on_check/0,
		 apply_stop_me/1,
		 get_activity_state/0,
		 apply_join_activity/1,
		 apply_leave_activity/1,
		 spa_start_notify/1,
		 request_spalist/1,
		 spa_touch_other_role/2,
		 spa_add_vip_count/2,
		 send_ground_role/1,
		 send_ground_role_client/1]).

%%
%% API Functions
%%
init()->
	put(?SPA_MANAGER_STATE,?ACTIVITY_STATE_STOP),
	put(?SPA_INFO,[]),
	put(?SPA_ROLE_INFO,[]),
	put(?SPA_TIME,{0,0,0}).

on_check()->
	InfoList = answer_db:get_activity_info(?SPA_ACTIVITY),
	CheckFun = fun(Info)->
				{Type,StartLines} = answer_db:get_activity_start(Info),
				activity_manager_op:activity_forecast_check(?SPA_ACTIVITY,Type,StartLines),
				Duration = answer_db:get_activity_duration(Info),
				SpecInfo = [?SPA_MAX_MAP_NUM],
				case activity_manager_op:check_is_time_line(Type,StartLines,?SPA_BUFFER_TIME_S,?SPA_BUFFER_END_TIME_S) of
					{true,_}->
						on_start_activity(Duration,SpecInfo),
						true;
					_->
						false
				end
	end,
	States = lists:map(CheckFun, InfoList),
	case lists:member(true,States) of
		true->
			nothing;
		_->
			on_stop_activity()
	end.

get_nodecount_by_onlinecount(OnlineCount,Limit)->
	if
		OnlineCount rem Limit > 0->
			OnlineCount div Limit + 1;
		true->
			OnlineCount div Limit
	end.

on_start_activity(Duration,Args)->
	case get(?SPA_MANAGER_STATE) of
		?ACTIVITY_STATE_STOP->
			SpaInfo = spa_db:get_option_info(?SPA_DEFAULT_ID),
			InstanceId = spa_db:get_spa_instance_proto(SpaInfo),
			InstanceInfo = instance_proto_db:get_info(InstanceId),
			{LevelStart,_LevelEnd} = instance_proto_db:get_level(InstanceInfo),
			{_,InstanceLimit} = instance_proto_db:get_membernum(InstanceInfo),
			MapId = instance_proto_db:get_level_mapid(InstanceInfo),
			case Args of
				[]->
					%%todo ccu config
					OnlineCount = role_pos_db:get_online_count(),
					Need_NodeCount = get_nodecount_by_onlinecount(OnlineCount,InstanceLimit) + 1;
				[NeedCount]->
					Need_NodeCount = NeedCount
			end,
			Nodes = node_util:get_low_load_node(Need_NodeCount),
			Fun = fun(Seq,Acc)->
					Node = lists:nth(Seq, Nodes),
					MapProc = make_map_proc_name(Seq),
					case rpc:call(Node,map_manager,start_instance, 
								  [MapProc,{atom_to_list(MapProc),InstanceId,{?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM}},MapId]) of
						ok->
							Acc ++ [{Seq,Node,MapProc,0,InstanceLimit}];
						error->
							Acc
					end
				  end,
			SPA_INFO = lists:foldl(Fun, [], lists:seq(1, erlang:length(Nodes))),
			put(?SPA_INFO,SPA_INFO),
			put(?SPA_MANAGER_STATE,?ACTIVITY_STATE_START),
			put(spa_time,timer_center:get_correct_now()),
			LocalTime = calendar:now_to_local_time(timer_center:get_correct_now()),
			erlang:send_after(?SPA_SEND_NOTICE_BUFFER_TIME_S*1000,self(),{spa_start_notify,LevelStart}),
			erlang:send_after(Duration + ?SPA_SEND_NOTICE_BUFFER_TIME_S*1000,self(),{apply_stop_me,{?SPA_ACTIVITY,[{send,Duration,LocalTime}]}});
		_->
			noting			
	end.

create_spa_list()->
	case get(?SPA_INFO) of
		[]->
			[];
		SpaInfo->
			lists:map(fun(Info)->
							  {SpaId,_,_,JoinCount,InstanceLimit} = Info,
							  {spa,SpaId,JoinCount,InstanceLimit}
					  end, SpaInfo)
	end.

spa_start_notify(InstanceLevel)->
	case get(?SPA_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			put(spa_time,timer_center:get_correct_now()),
			Message = spa_packet:encode_spa_start_notice_s2c(InstanceLevel),
			role_pos_util:send_to_all_online_clinet(Message);
		_->
			nothing
	end.

request_spalist(RoleId)->
	case get(?SPA_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			Message = spa_packet:encode_spa_request_spalist_s2c(create_spa_list()),
			role_pos_util:send_to_role_clinet(RoleId, Message);
		_->
			nothing
	end.

spa_add_vip_count(RoleId,AddCount)->
	case get(?SPA_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			SpaRole = get(?SPA_ROLE_INFO),
			case lists:keyfind(RoleId, 1, SpaRole) of
				false->
					nothing;
				{_,Name,SpaId,JoinState,
				{{Chopping,ChPassive,ChTime},{Swimming,SwPassive,SwTime}}}->
					NewRoleInfo = {RoleId,Name,SpaId,JoinState,
							{{Chopping+AddCount,ChPassive,ChTime},{Swimming+AddCount,SwPassive,SwTime}}},
					NewSpaRole = lists:keyreplace(RoleId, 1, SpaRole, NewRoleInfo),
					put(?SPA_ROLE_INFO,NewSpaRole)
			end;
		_->
			nothing
	end.

spa_touch_other_role(Type,Info)->
	case Type of
		?SPA_TOUCH_TYPE_CHOPPING->
			spa_chopping(Info);
		?SPA_TOUCH_TYPE_SWIMMING->
			spa_swimming(Info);
		_->
			nothing
	end.

spa_swimming(Info)->
	{_SpaId,MyRoleId,RoleId} = Info,
	Errno=
	case get(?SPA_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			SpaRole = get(?SPA_ROLE_INFO),
			case lists:keyfind(MyRoleId, 1, SpaRole) of
				false->
					?ERROR_ACTIVITY_STATE_ERR;
				{_,MyName,MySpa,MyJoinState,{MyChoppingInfo,{MySwimming,MyPassive,MyCoolTime}}}->
					CheckCoolTime = spa_op:check_cooltime(MyCoolTime),
					if
						MyJoinState=:=?SPA_ROLE_STATE_JOIN,CheckCoolTime->
							case lists:keyfind(RoleId, 1, SpaRole) of
								false->
									?ERROR_ACTIVITY_STATE_ERR;
								{_,BeName,BeSpa,BeJoinState,
								 {BeChoppingInfo,{BeSwimming,BePassive,BeCoolTime}}}->
									if
										BeJoinState=:=?SPA_ROLE_STATE_JOIN,BePassive>0->
											NowTime = timer_center:get_correct_now(),
											NewMy = {MyRoleId,MyName,MySpa,MyJoinState,
													{MyChoppingInfo,{MySwimming-1,MyPassive,NowTime}}},
											NewBe = {RoleId,BeName,BeSpa,BeJoinState,
								 					{BeChoppingInfo,{BeSwimming,BePassive-1,BeCoolTime}}},
											NewSpaRole = lists:keyreplace(MyRoleId, 1, SpaRole, NewMy),
											NewSpaRole2 = lists:keyreplace(RoleId, 1, NewSpaRole, NewBe),
											put(?SPA_ROLE_INFO,NewSpaRole2),
											send_message(MyRoleId,{handle_spa_touch,
																   ?SPA_TOUCH_TYPE_SWIMMING,
																   {BeName,MySwimming-1,NowTime}}),
											send_message(RoleId,{handle_be_spa_touch,
																 ?SPA_TOUCH_TYPE_SWIMMING,
																 {MyName,BePassive-1}}),
											[];
										true->
											?ERROR_SPA_CAN_NOT_TOUCH_SWIMMING_ERR
									end
							end;
						true->
							?ERROR_ACTIVITY_COOLTIME_SWIMMING_ERR
					end;
				_->
					?ERROR_ACTIVITY_STATE_ERR
			end;
		_->
			[]
	end,
	if
		Errno=/=[]->
			Message = spa_packet:encode_spa_error_s2c(Errno),
			send_message_client(MyRoleId,Message);
		true->
			nothing
	end.

spa_chopping(Info)->
	{_SpaId,MyRoleId,RoleId,IsGold} = Info,
	Errno=
	case get(?SPA_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			SpaRole = get(?SPA_ROLE_INFO),
			case lists:keyfind(MyRoleId, 1, SpaRole) of
				false->
					?ERROR_ACTIVITY_STATE_ERR;
				{_,MyName,MySpa,MyJoinState,{{MyChopping,MyPassive,_MyCoolTime},MySwimmingInfo}}->
					case MyJoinState of
						?SPA_ROLE_STATE_JOIN->
							case lists:keyfind(RoleId, 1, SpaRole) of
								false->
									?ERROR_ACTIVITY_STATE_ERR;
								{_,BeName,BeSpa,BeJoinState,
								 {{BeChopping,BePassive,BeCoolTime},BeSwimmingInfo}}->
									if
										BeJoinState=:=?SPA_ROLE_STATE_JOIN,BePassive>0->
											NowTime = timer_center:get_correct_now(),
											NewMy = {MyRoleId,MyName,MySpa,MyJoinState,
													{{MyChopping-1,MyPassive,NowTime},MySwimmingInfo}},
											NewBe = {RoleId,BeName,BeSpa,BeJoinState,
								 					{{BeChopping,BePassive-1,BeCoolTime},BeSwimmingInfo}},
											NewSpaRole = lists:keyreplace(MyRoleId, 1, SpaRole, NewMy),
											NewSpaRole2 = lists:keyreplace(RoleId, 1, NewSpaRole, NewBe),
											put(?SPA_ROLE_INFO,NewSpaRole2),
											send_message(MyRoleId,{handle_spa_touch,
																   ?SPA_TOUCH_TYPE_CHOPPING,
																   {BeName,MyChopping-1,NowTime,IsGold}}),
											send_message(RoleId,{handle_be_spa_touch,
																 ?SPA_TOUCH_TYPE_CHOPPING,
																 {MyName,BePassive-1}}),
											[];
										true->
											?ERROR_SPA_CAN_NOT_TOUCH_CHOPPING_ERR
									end
							end;
						_->
							?ERROR_ACTIVITY_COOLTIME_CHOPPING_ERR
					end;
				_->
					?ERROR_ACTIVITY_STATE_ERR
			end;
		_->
			[]
	end,
	if
		Errno=/=[]->
			Message = spa_packet:encode_spa_error_s2c(Errno),
			send_message_client(MyRoleId,Message);
		true->
			nothing
	end.

send_message(RoleId,Message)->
	role_pos_util:send_to_role(RoleId,Message).

send_message_client(RoleId,Message)->
	role_pos_util:send_to_role_clinet(RoleId, Message).

apply_stop_me(_Info)->
	case get(?SPA_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			put(?SPA_MANAGER_STATE,?ACTIVITY_STATE_END),
			apply_stop_player();
		_->
			nothing
	end.

on_stop_activity()->
	case get(?SPA_MANAGER_STATE) of
		?ACTIVITY_STATE_STOP->
			nothing;
		_->
			on_destroy_instance(),
			apply_stop_player(),
			init()
	end.

on_destroy_instance()->
	case get(?SPA_INFO) of
		[]->
			nothing;
		SpaInfos->
			lists:foreach(fun(Info)->
								  {_,Node,MapProc,_,_} = Info,
								  rpc:call(Node,erlang,send_after,[?SPA_BUFFER_TIME_S*1000,MapProc, {on_destroy}])
						  end, SpaInfos)
	end.

apply_stop_player()->
	case get(?SPA_ROLE_INFO) of
		[]->
			nothing;
		RoleInfos->
			Message = spa_packet:encode_spa_stop_s2c(),
			role_pos_util:send_to_all_online_clinet(Message),
			lists:foreach(fun(RoleInfo)->
								  {RoleId,_,_,JoinState,_} = RoleInfo,
%% 								  Message = spa_packet:encode_spa_stop_s2c(),
%% 								  send_message_client(RoleId, Message),
								  if
									  JoinState=:=?SPA_ROLE_STATE_JOIN->
								  		send_message(RoleId,{spa_apply_stop_player});
									  true->
										  nothing
								  end
						  end, RoleInfos)
	end.

send_ground_role(Message)->
	case get(?SPA_ROLE_INFO) of
		[]->
			nothing;
		RoleInfos->
			lists:foreach(fun(RoleInfo)->
								  {RoleId,_,_,_,_} = RoleInfo,
								  send_message(RoleId,Message)
						  end, RoleInfos)
	end.

send_ground_role_client(Message)->
	case get(?SPA_ROLE_INFO) of
		[]->
			nothing;
		RoleInfos->
			lists:foreach(fun(RoleInfo)->
								  {RoleId,_,_,_,_} = RoleInfo,
								  send_message_client(RoleId, Message)
						  end, RoleInfos)
	end.

check_role_joined(RoleId)->
	case lists:keyfind(RoleId, 1, get(?SPA_ROLE_INFO)) of
		false->
			true;
		{_,_,_,JoinState,_}->
			if
				JoinState =:= ?SPA_ROLE_STATE_JOIN->
					false;
				true->
					true
			end
	end.

apply_join_activity(Args)->
	case get(?SPA_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			{RoleId,RoleName,[SpaId,Chopping,Swimming]} = Args,
			case get(?SPA_INFO) of
				[]->
					sys_error;
				SpaInfo->
					case lists:keyfind(SpaId, 1, SpaInfo) of
						false->
							no_spaid;
						{_,Node,MapProc,JoinCount,InstanceLimit}->
							case check_role_joined(RoleId) of
								false->
									joined;
								true->
									if JoinCount+1 =< InstanceLimit->
										put(?SPA_INFO,lists:keyreplace(SpaId, 1, SpaInfo, 
										{SpaId,Node,MapProc,JoinCount+1,InstanceLimit})),
										case lists:keyfind(RoleId, 1, get(?SPA_ROLE_INFO)) of
											false->
												ChoppingInfo = {Chopping,?SPA_PASSIVE_COUNT,{0,0,0}},
												SwimmingInfo = {Swimming,?SPA_PASSIVE_COUNT,{0,0,0}},
												put(?SPA_ROLE_INFO,get(?SPA_ROLE_INFO)++
												[{RoleId,RoleName,SpaId,?SPA_ROLE_STATE_JOIN,
												  {ChoppingInfo,SwimmingInfo}}]),
												Info = {ChoppingInfo,SwimmingInfo};
											{_,_,_,_,Info}->
												put(?SPA_ROLE_INFO,lists:keyreplace(RoleId, 1, get(?SPA_ROLE_INFO), 
													{RoleId,RoleName,SpaId,?SPA_ROLE_STATE_JOIN,Info}))
										end,
										{ok,Node,MapProc,get(?SPA_TIME),Info};
									   true->
										full
									end
							end
					end
			end;
		_->
			state_error
	end.

apply_leave_activity(Info)->
	case get(?SPA_MANAGER_STATE) of
		State when State=:=?ACTIVITY_STATE_START;State=:=?ACTIVITY_STATE_END->
			case get(?SPA_INFO) of
				[]->
					nothing;
				SpaInfo->
					{RoleId,SpaId,LeaveState} = Info,
					case lists:keyfind(RoleId, 1, get(?SPA_ROLE_INFO)) of
						false->
							nothing;
						RoleInfo->
							{_,RoleName,_,JoinState,OpInfo} = RoleInfo,
							case JoinState of
								?SPA_ROLE_STATE_JOIN->
									case lists:keyfind(SpaId, 1, SpaInfo) of
										false->
											nothing;
										{_,Node,MapProc,JoinCount,InstanceLimit}->
											if
												JoinCount>=1->
													put(?SPA_INFO,lists:keyreplace(SpaId, 1, SpaInfo, 
													{SpaId,Node,MapProc,JoinCount-1,InstanceLimit}));
												true->
													nothing
											end
									end,
									NewRoleInfo = lists:keyreplace(RoleId, 1, get(?SPA_ROLE_INFO), 
														   {RoleId,RoleName,SpaId,LeaveState,OpInfo}),
									put(?SPA_ROLE_INFO,NewRoleInfo);
								_->
									nothing
							end
					end
			end;
		_->
			nothing
	end.

get_activity_state()->
	get(?SPA_MANAGER_STATE).

%%
%% Local Functions
%%
make_map_proc_name(SpaId)->
	MapProc = lists:append(["map_spa_",integer_to_list(SpaId)]),
	list_to_atom(MapProc).
