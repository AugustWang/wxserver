%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-7-11
%% Description: TODO: Add description to activity_value_op
-module(activity_value_op).

%%
%% Include files
%%
-include("activity_value_define.hrl").
-include("error_msg.hrl").
-include("common_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("string_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% dictionary define
%%

%% av_activity_msg [{id,{type,target}}]
%% av_activity_state {timestamp,[{id,onestep,times}]} %% 任务id  当前步骤完成的进度   总进度
%% av_activity_info {value,reward}		%%活跃度 是否领取过奖励

%%
%% API Functions
%%

init()->
	put(av_activity_msg,activity_value_db:create_av_msg()),
	Now = now(),			
	case activity_value_db:get_activity_value_info(get(roleid)) of
		[]->
			NewValue = 0,
			NewRewardFlag = false,
			put(av_activity_state,{Now,activity_value_db:create_av_state()});
		AVInfo->
			Value = activity_value_db:get_activity_value(AVInfo),
			RewardFlag = activity_value_db:get_activity_rewardflag(AVInfo),
			%%put(av_activity_info,{Value,RewardFlag}),
			StateInfo = activity_value_db:get_activity_value_state(AVInfo),
			{TimeStamp,State} =  StateInfo,
			case timer_util:check_same_day(TimeStamp,Now) of
				true->
					NewState = 
						lists:filter(fun({Id,OneStep,TotalTimes})->
									case lists:keyfind(Id,1,State) of
										false->
											true;
										_->
											false
									end
							end,activity_value_db:create_av_state()),
					put(av_activity_state,{TimeStamp,State ++ NewState}),
					NewValue = Value,
					NewRewardFlag = RewardFlag;
				_->
					put(av_activity_state,{Now,activity_value_db:create_av_state()}),
					if
						RewardFlag-> %%reward
							nothing;
						true->	%%
							RoleInfo = get(creature_info),
							RoleName = get_name_from_roleinfo(RoleInfo),
							RoleLevel = get_level_from_roleinfo(RoleInfo),
							send_remain_reward_delay(RoleName,RoleLevel,Value,TimeStamp)		
					end,
					NewValue = 0,
					NewRewardFlag = false,
					activity_value_db:update_activity_value(get(roleid),get(av_activity_state),NewValue,NewRewardFlag)
			end
	end,
	put(av_activity_info,{NewValue,NewRewardFlag}),
	{_,NewAVInfo} = get(av_activity_state),
	AvList = lists:map(fun({Id,_,Times})->
						activity_value_packet:make_av(Id,Times)
						end,NewAVInfo),
	%%{NewValue} = get(av_activity_info),
	if
		NewRewardFlag->
			Status = ?COMPLETE;
		true->
			Status = ?UNCOMPLETED
	end,
	MsgBin = activity_value_packet:encode_activity_value_init_s2c(AvList,NewValue,Status),
	role_op:send_data_to_gate(MsgBin).

export_for_copy()->
	{get(av_activity_msg),get(av_activity_state),get(av_activity_info)}.

load_by_copy(AVInfo)->
	{Msg,State,Info} = AVInfo,
	put(av_activity_msg,Msg),
	put(av_activity_state,State),
	put(av_activity_info,Info).

%%
%%初始化
%%
process_message({activity_value_init_c2s,_})->
	{TimeStamp,AVInfo} = get(av_activity_state),
	{Value,RewardFlag} = get(av_activity_info),
	Now = now(),
	case timer_util:check_same_day(TimeStamp,Now) of
		true->
			nothing;
		_->
			NewAVInfo = activity_value_db:create_av_state(),
			put(av_activity_state,{Now,NewAVInfo}),
			put(av_activity_info,{0,false}),
			if
				RewardFlag->
					nothing;
				true->
					RoleInfo = get(creature_info),
					RoleName = get_name_from_roleinfo(RoleInfo),
					RoleLevel = get_level_from_roleinfo(RoleInfo),
					send_remain_reward(RoleName,RoleLevel,Value,TimeStamp)
			end,
			%% update db
			activity_value_db:update_activity_value(get(roleid),get(av_activity_state),0,false),
			AvList = lists:map(fun({Id,_,Times})->
						activity_value_packet:make_av(Id,Times)
						end,NewAVInfo),
			MsgBin = activity_value_packet:encode_activity_value_init_s2c(AvList,0,?UNCOMPLETED),
			role_op:send_data_to_gate(MsgBin)
	end;
	

%%
%%领取奖励
%%TODO
process_message({activity_value_reward_c2s,_,Id})->
	%%check value
	{TimeStamp,_} = get(av_activity_state),
	{MyValue,RewardFlag} = get(av_activity_info),
	if
		RewardFlag->
			nothing;
		true->
			MyLevel = get_level_from_roleinfo(get(creature_info)),
			MyRewardId = active_board_util:get_reward_type(MyLevel),%%奖励物品按等级段配置  需要转换等级
			case activity_value_db:get_reward_info(Id) of
				[]->
					slogger:msg("~p activity_value_db:get_reward_info error id ~p",[get(roleid),Id]);
				TableInfo->
					Rewards = activity_value_db:get_reward(TableInfo),
					case get_my_reward(MyRewardId,Rewards) of
						[]->
							OptCode = ?ACTIVITY_VALUE_ITEM_NOT_EXIST,
							OptMsgBin = activity_value_packet:encode_activity_value_opt_s2c(OptCode),
							role_op:send_data_to_gate(OptMsgBin);
						{ItemId,ValueNeed}->
							if
								ValueNeed > MyValue->
									OptCode = ?ACTIVITY_VALUE_NOT_ENOUGH,
									OptMsgBin = activity_value_packet:encode_activity_value_opt_s2c(OptCode),
									role_op:send_data_to_gate(OptMsgBin);
								true->
									case role_op:auto_create_and_put(ItemId,1,got_activity_reward) of
										{ok,_} ->
											Exp = get_reward_exp(MyLevel,MyValue),
											role_op:obtain_exp(Exp),
											put(av_activity_info,{0,true}),
											gm_logger_role:role_activity_value_reward(get(roleid),ValueNeed,Id,0,get(level)),		
											OptCode = ?ACTIVITY_VALUE_REWARD_SUCCESS,
											OptMsgBin = activity_value_packet:encode_activity_value_opt_s2c(OptCode),
											role_op:send_data_to_gate(OptMsgBin),											
											UpdateMsgBin = activity_value_packet:encode_activity_value_update_s2c([],0,?COMPLETE),
											role_op:send_data_to_gate(UpdateMsgBin),
											%%update db
											activity_value_db:update_activity_value(get(roleid),get(av_activity_state),0,true);
										_->
											nothing
									end
							end
					end
			end
	end;
	
process_message({send_remain_reward,{RoleName,RoleLevel,Value,TimeStamp}})->
	send_remain_reward(RoleName,RoleLevel,Value,TimeStamp);	

process_message(_)->
	nothing.


	
%%
%%{monster_kill,ProtoId}杀怪
%%{instance,InstanceId}进入副本
%%{join_activity,ActivityId}参加活动
%%{complete_quest,QuestId}完成某个普通任务
%%{complete_everquest_by_section,EverQuestId}	完成日常任务按段计算
%%{complete_everquest_by_round,EverQuestId}		完成日常任务按轮计算
%%{complete_everquest,EverQuestId}		完成日常任务按任务数计算

update(Msg)->
	update(Msg,1).
	
%%
%% Local Functions
%%

%%
%%物品的格式  [[itemid1,value],[itemid2,value],[itemid3,value],[itemid4,value]]
%%
get_my_reward(LevelId,Rewards)->
	Result = lists:nth(LevelId,Rewards),
%%	io:format("get_my_reward ~p ~n",[Result]),
	case Result of
		[]->
			[];
		[ItemId,Value]->
			{ItemId,Value};
		_->
			[]
	end.
update(Msg,MsgValue)->
	update_public(Msg,MsgValue,1).

update_public(Msg,MsgValue,Times_param)->
	case get_msg_info(Msg) of
		[]->
			nothing;
		MsgInfo->
			{_,Op,MaxValue,Id} = MsgInfo,
			case activity_value_db:get_info(Id) of
				[]->
					slogger:msg("activity_value_db:get_info error id ~p",[Id]);
				Info->	
					update_av_state(),
					{CurValue,RewardFlag} = get(av_activity_info),
					MaxTimes = activity_value_db:get_maxtimes(Info),
					TimeLines = activity_value_db:get_time(Info),
					{TimeStamp,AVInfo} = get(av_activity_state),
					{_,CurTimes,TotalTimes} = lists:keyfind(Id,1,AVInfo), 				
					Add_Value = activity_value_db:get_value(Info),
					if
						MaxTimes =< TotalTimes,MaxTimes =/= 0 ->		%%已完成 （排除不限次数的）
							nothing;
						true ->%%
							CanContinue = 
								case check_time(TimeLines) of
									false->					%%时间不符
										false;
									_->
										true
								end,
							if
								CanContinue->
									case check_complete(Op,MsgValue,CurTimes,MaxValue) of
										true->									%%完成Times_param次
											NewTotalTimes = TotalTimes + Times_param,
											if
												RewardFlag->			%%已领取过奖励  不再增加
													NeedAddValue = false;
												MaxTimes =:= 0->		%%不限次数
													NeedAddValue = true;
												true->
													NeedAddValue = (NewTotalTimes >= MaxTimes)
											end,
											if	
												NeedAddValue->											
													NewValue = erlang:min(CurValue + Add_Value,?MAX_ACTIVITY_VALUE),
													gm_logger_role:role_activity_value(get(roleid),Add_Value,NewValue,Id,get(level));
												true->
													NewValue = CurValue
											end,
											gm_logger_role:role_activity_value_change(get(roleid),Id,get(level),NewTotalTimes,MaxTimes),
											NewCurTimes = 0,
											%%send update msg
											AVMsg = activity_value_packet:make_av(Id,NewTotalTimes), 
											MsgBin = activity_value_packet:encode_activity_value_update_s2c([AVMsg],NewValue,?UNCOMPLETED),
											role_op:send_data_to_gate(MsgBin);				
										false->										
											NewTotalTimes = TotalTimes,
											NewCurTimes =  CurTimes,
											NewValue = CurValue;
										NewCompleteValue->
											if
												NewCompleteValue>=MaxValue->	%%累加完成
													NewTotalTimes = TotalTimes + Times_param,	
													if
														RewardFlag->				%%已领取过奖励  不再增加
															NeedAddValue = false;
														MaxTimes =:= 0->		%%不限次数
															NeedAddValue = true;
														true->
															NeedAddValue = (NewTotalTimes >= MaxTimes)
													end,
													if	
														NeedAddValue->											
															NewValue = erlang:min(CurValue + Add_Value,?MAX_ACTIVITY_VALUE),
															gm_logger_role:role_activity_value(get(roleid),Add_Value,NewValue,Id,get(level));
														true->
															NewValue = CurValue
													end,
													gm_logger_role:role_activity_value_change(get(roleid),Id,get(level),NewTotalTimes,MaxTimes),										
													NewCurTimes = NewCompleteValue - MaxValue,		%%多余的部分累加到下一次
													%%send update msg
													AVMsg = activity_value_packet:make_av(Id,NewTotalTimes), 
													MsgBin = activity_value_packet:encode_activity_value_update_s2c([AVMsg],NewValue,?UNCOMPLETED),
													role_op:send_data_to_gate(MsgBin);
												true->
													NewTotalTimes = TotalTimes,
													NewCurTimes =  NewCompleteValue,
													NewValue = CurValue
											end
									end,
									NewAVInfo = lists:keyreplace(Id,1,AVInfo,{Id,NewCurTimes,NewTotalTimes}),
									put(av_activity_state,{TimeStamp,NewAVInfo}),
									put(av_activity_info,{NewValue,RewardFlag}),
									%%update db
									activity_value_db:update_activity_value(get(roleid),get(av_activity_state),NewValue,RewardFlag);
								true->
									nothing
							end
					end
			 end
	end.	


update_av_state()->
	{TimeStamp,AVInfo} = get(av_activity_state),
	Now = now(),
	case timer_util:check_same_day(TimeStamp,Now) of
		true->
			nothing;
		_->
			{CurValue,RewardFlag} = get(av_activity_info),
			if
				not RewardFlag ->
					RoleInfo = get(creature_info),
					RoleName = get_name_from_roleinfo(RoleInfo),
					RoleLevel = get_level_from_roleinfo(RoleInfo),
					send_remain_reward(RoleName,RoleLevel,CurValue,TimeStamp),
					put(av_activity_state,{now(),activity_value_db:create_av_state()}),
					activity_value_db:update_activity_value(get(roleid),get(av_activity_state),0,false),
					UpateMsgBin = activity_value_packet:encode_activity_value_update_s2c([],0,?UNCOMPLETED),
					role_op:send_data_to_gate(UpateMsgBin);
				true->
					nothing
			end,
			put(av_activity_info,{0,false}),
			put(av_activity_state,{Now,activity_value_db:create_av_state()})
	end.


gm_add_av_value(Add_Value)->
	{CurValue,_} = get(av_activity_info),
	if
		CurValue >= ?MAX_ACTIVITY_VALUE->
			nothing;
		Add_Value =:= 0->
			nothing;	
		true->
			MinValue = erlang:min(CurValue + Add_Value,?MAX_ACTIVITY_VALUE),
			NewValue = erlang:max(MinValue,0),
			put(av_activity_info,{NewValue,false}),
			UpdateMsgBin = activity_value_packet:encode_activity_value_update_s2c([],NewValue,?UNCOMPLETED),
			role_op:send_data_to_gate(UpdateMsgBin),
			%%update db
			activity_value_db:update_activity_value(get(roleid),get(av_activity_state),NewValue,false)
	end.
	
%%
%%
%%return [] | MsgInfo
%%

get_msg_info(Msg)->
	case lists:keyfind(Msg,1,get(av_activity_msg)) of
		false->
			[];
		Info->
			Info
	end.

%%
%%检查时间
%% return true | false
%%
check_time(TimeRange)->
	case TimeRange of
		[]->
			true;
		{?DUE_TYPE_DAY,TimeLines}->
			NowTime = calendar:now_to_local_time(timer_center:get_correct_now()),
			lists:foldl(fun(TimeLine,Acc)->
						if
							Acc->
								true;
							true->
								timer_util:check_sec_is_in_timeline_by_day(NowTime,TimeLine)
						end	
					end,false,TimeLines);
		_->
			false
	end.

%%
%%检查完成条件
%%return true|false|newvalue
%%
check_complete(Op,MsgValue,CurValue,MaxValue)->
	case Op of
		add_to->
			CurValue + MsgValue;
		eq->
			MsgValue =:= MaxValue;
		ge -> 
			MsgValue > MaxValue; 
		le ->
			MsgValue < MaxValue
	end.

%%
%%计算奖励经验
%%
get_reward_exp(Level,Value)->
	120*Level*Value.

%%
%%获取合适的奖励物品
%%
get_adapt_reward_item(Level,Value)->
	MyRewardId = active_board_util:get_reward_type(Level),%%奖励物品按等级段配置  需要转换等级
	AllRewards = activity_value_db:get_all_reward(),
	lists:foldl(fun(RewardList,{NeedValueAcc,ItemIdAcc})->
					case get_my_reward(MyRewardId,RewardList) of
						[]->
							{NeedValueAcc,ItemIdAcc};
						{ItemId,RewardValue}->
							if
								RewardValue > NeedValueAcc,RewardValue =< Value->
									{RewardValue,ItemId};	
								true->
									{NeedValueAcc,ItemIdAcc}
							end
					end
				end, {0,0}, AllRewards).
%%
%%发送未领取奖励
%%
send_remain_reward(Name,Level,Value,TimeStamp)->
	Exp = get_reward_exp(Level,Value),
	if
		Exp > 0->
			role_op:obtain_exp(Exp);
		true->
			nothing
	end,
	case get_adapt_reward_item(Level,Value) of
		{0,0}->
			nothing;
		{_,ItemProtoId}->
			MailTitle = language:get_string(?STR_ACTIVITY_VALUE_REWARD_TITLE),
			MailContent = language:get_string(?STR_ACTIVITY_VALUE_REWARD_CONTENT),
			MailSign = language:get_string(?STR_SYSTEM),
			gm_op:gm_send_rpc(MailSign,Name,MailTitle,MailContent,ItemProtoId,1,0)
	end.
	
	
send_remain_reward_delay(Name,Level,Value,TimeStamp)->
	erlang:send_after(1, self(),{activity_value,{send_remain_reward,{Name,Level,Value,TimeStamp}}}).
	
