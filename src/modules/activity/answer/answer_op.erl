%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-3-28
%% Description: TODO: Add description to answer_op
-module(answer_op).

%%
%% Include files
%%
-include("activity_define.hrl").
-include("error_msg.hrl").
-define(ANSWER_BUFFER_TIME_S,60).
-define(ANSWER_BUFFER_END_TIME_S,0).
-define(ANSWER_START_LEVEL,35).
%%
%% Exported Functions
%%
-export([init/1,load_from_db/1,export_for_copy/0,load_by_copy/1,write_to_db/0,hook_on_online/0,hook_on_offline/0,
		 answer_sign_request_c2s/0,answer_question_c2s/3,answer_reward/2,hook_on_level_up/1]).
-include("data_struct.hrl").
-include("role_struct.hrl").
%%
%% API Functions
%%
init(RoleId)->
	load_from_db(RoleId),
	hook_on_online().
	
hook_on_level_up(NewLevel)->
	case NewLevel >= ?ANSWER_START_LEVEL of
		true->
			init(get(roleid));
		_->
			ignor
	end.

init_info()->
	put(role_answer_info,[]),
	put(role_answer_sign,{0,0,0}).

load_from_db(RoleId) ->
	case answer_db:get_answer_roleinfo(RoleId) of
		{ok,[]}->
			init_info();
		{ok,AnswerRoleInfo}->
			{_,_,AnswerLog} = AnswerRoleInfo,
			put(role_answer_info,[]),
			put(role_answer_sign,AnswerLog);
		_->
			init_info()
	end.

export_for_copy()->
	{get(role_answer_info),get(role_answer_sign)}.
	
write_to_db()->
	nothing.

load_by_copy({RoleAnswerInfo,RoleAnswerSign})->
	put(role_answer_info,RoleAnswerInfo),
	put(role_answer_sign,RoleAnswerSign).

get_vip_prop_count(VipAddition)->
	{Double,Auto} = VipAddition,
	VipLevel = vip_op:get_role_vip(),
	DoubleCount = case lists:keyfind(VipLevel, 1, Double) of
					  false->
						  0;
					  {_,C1}->
						  C1
				  end,
	AutoCount = case lists:keyfind(VipLevel,1, Auto) of
					false->
						0;
					{_,C2}->
						C2
				end,
	{DoubleCount,AutoCount}.

answer_sign_request_c2s()->
	Errno = answer_sign_request(),
	if 
		Errno =/= []->
			Message_failed = answer_packet:encode_answer_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			answer_db:sync_update_answer_roleinfo_to_mnesia(get(roleid),{get(roleid),timer_center:get_correct_now()})
	end.

answer_sign_request()->
	case get(role_answer_info) of
		[]->
			AnswerOption = answer_db:get_answer_option_info(?ANSWER_ACTIVITY),
			{LevelStart,LevelEnd} = answer_db:get_answerop_level(AnswerOption),
			VipProps = answer_db:get_answerop_vip_props(AnswerOption),
			case activity_op:handle_join_without_instance(?ANSWER_ACTIVITY,LevelStart,LevelEnd,[]) of
				ok->
					Errno=[],
					{Double,Auto} = get_vip_prop_count(VipProps),
					put(role_answer_info,{get(roleid),0,0,0,Double,Auto,[]}),
					gm_logger_role:answering_log(get(roleid),1,0,0,0),
					activity_value_op:update({join_activity,?ANSWER_ACTIVITY}),
					Message = answer_packet:encode_answer_sign_success_s2c(),
					role_op:send_data_to_gate(Message);
				exist->
					Errno=?ERROR_ANSWER_SIGN_EXIST;
				state_error->
					Errno=?ERROR_ANSWER_SIGN_STATE_ERR;
				level_error->
					Errno=?ERROR_ANSWER_SIGN_LEVEL_ERR;
				instance_error->
					Errno=?ERROR_ANSWER_SIGN_INSTANCE_ERR;
				no_activity->
					Errno=?ERROR_ANSWER_NO_ACTIVITY;
				_->
					Errno=?ERRNO_NPC_EXCEPTION
			end;
		_->
			Errno=?ERROR_ANSWER_SIGN_EXIST
	end,
	Errno.

send_question_s2c(Id,Score,Rank,Continu)->
	Message = answer_packet:encode_answer_question_s2c(Id,Score,Rank,Continu),
	role_op:send_data_to_gate(Message).

apply_answer_question_right(RoleId,Id,Flag,Continu,Double,Auto,NewAnsweredList)->
	case answer_processor:apply_answer_question({RoleId,Id,Flag}) of
		{Score,Rank}->
			send_question_s2c(Id,Score,Rank,Continu+1),
			put(role_answer_info,{RoleId,Score,Continu+1,Rank,Double,Auto,NewAnsweredList}),
			[];
		_->
			?ERROR_ANSWER_SIGN_STATE_ERR
	end.

apply_answer_question_wrong(RoleId,Id,Flag,Continu,Double,Auto,NewAnsweredList)->
	case answer_processor:apply_answer_question({RoleId,Id,Flag}) of
		{Score,Rank}->
			send_question_s2c(Id,Score,Rank,Continu),
			put(role_answer_info,{RoleId,Score,Continu,Rank,Double,Auto,NewAnsweredList}),
			[];
		_->
			?ERROR_ANSWER_SIGN_STATE_ERR
	end.

answer_question_c2s(Id,Answer,Flag)->
	case answer_db:get_answer_info(Id) of
		[]->
			Errno=?ERRNO_NPC_EXCEPTION;
		AnswerInfo->
			AnswerId = answer_db:get_answer_id(AnswerInfo),
			Correct = answer_db:get_answer_correct(AnswerInfo),
			if
				Id=:=AnswerId->
					case get(role_answer_info) of
						[]->
							Errno=?ERRNO_NPC_EXCEPTION;
						{RoleId,_OScore,Continu,_ORank,Double,Auto,AnsweredList}->
							case lists:member(Id, AnsweredList) of
								false->
									NewAnsweredList = AnsweredList++[Id],
									if
										Answer=:=Correct->
											if 
												Flag=:=1,Double>=1->
													Errno = apply_answer_question_right(RoleId,Id,Flag,Continu,Double-1,Auto,NewAnsweredList);
												Flag=:=2,Auto>=1->
													Errno = apply_answer_question_right(RoleId,Id,Flag,Continu,Double,Auto-1,NewAnsweredList);
												true->
													if Flag=:=2->
														   Errno = apply_answer_question_wrong(RoleId,Id,-1,0,Double,Auto,NewAnsweredList);
									 				  true->
														   Errno = apply_answer_question_right(RoleId,Id,0,Continu,Double,Auto,NewAnsweredList)
													end
											end;
										true->
											Errno = apply_answer_question_wrong(RoleId,Id,-1,0,Double,Auto,NewAnsweredList)
									end;
								true->
									Errno=[],
									nothing
							end
					end;
				true->
					Errno=?ERROR_ANSWER_SIGN_STATE_ERR
			end
								  
	end,
	if 
		Errno =/= []->
			Message_failed = answer_packet:encode_answer_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

answer_reward(Score,Rank)->
 	RoleLevel = get_level_from_roleinfo(get(creature_info)),
	VipLevel = vip_op:get_role_vip(),
	AnswerOptionInfo = answer_db:get_answer_option_info(?ANSWER_ACTIVITY),
	Nums = answer_db:get_answerop_nums(AnswerOptionInfo),
	VipAddition = answer_db:get_answerop_vip_addition(AnswerOptionInfo),
	AllAddtion = answer_db:get_answerop_all_addition(AnswerOptionInfo),
	Reward = answer_db:get_answerop_rewards(AnswerOptionInfo),
	BaseExp = lists:keyfind(RoleLevel, 1, answer_db:get_answerop_base_exp(AnswerOptionInfo)),
	case get(role_answer_info) of
		[]->
			nothing;
		{RoleId,_Score,Continu,_Rank,_Double,_Auto,_}->
			if
				BaseExp=/=[]->
					FinalBaseExp=element(2,BaseExp);
				true->
					FinalBaseExp=50
			end,
			if
				VipLevel>0->
					case lists:keyfind(VipLevel, 1, VipAddition) of
						false->
							FinalVipAddition = 0;
						{_,0}->
							FinalVipAddition = 0;
						{_,Value}->
							FinalVipAddition = Value/100
					end;
				true->
					FinalVipAddition = 0
			end,
			if
				Continu=:=Nums->
					FinalAllAddition = AllAddtion/100;
				true->
					FinalAllAddition = 0
			end,
			if
				Rank>0,Rank=<3->
					FinalRank = element(2,lists:keyfind(Rank, 1, Reward))/100;
				true->
					FinalRank = 0
			end,
			FinalExp = erlang:trunc((Score+120)*FinalBaseExp*(1+FinalVipAddition+FinalAllAddition+FinalRank)),
			role_op:obtain_exp(FinalExp),
			put(role_answer_info,[]),
			gm_logger_role:answer_log(RoleId, Score, Rank, FinalExp,RoleLevel),
			Message = answer_packet:encode_answer_end_s2c(FinalExp),
			role_op:send_data_to_gate(Message),
			init_info()
	end.

hook_on_online()->
	AnswerInfoList = answer_db:get_activity_info(?ANSWER_ACTIVITY),
	CheckFun = fun(AnswerInfo)->
				{Type,StartLines} = answer_db:get_activity_start(AnswerInfo),
				case activity_manager_op:check_is_time_line(Type,StartLines) of
					{true,_}->
						true;
					_->
						false
				end
	end,
	States = lists:map(CheckFun, AnswerInfoList),
	case lists:member(true,States) of
		true->
			case answer_processor:get_activity_state() of
				{?ACTIVITY_STATE_SIGN,LeftTime}->
					Message = answer_packet:encode_answer_sign_notice_s2c(LeftTime),
					role_op:send_data_to_gate(Message),
					case get(role_answer_sign) of
						{0,0,0}->
							nothing;
						SignTime->
							{{_,_,Day},_} = calendar:now_to_local_time(timer_center:get_correct_now()),
							CheckTime = calendar:now_to_local_time(SignTime),
							{{_,_,CheckDay},_} =  CheckTime,
							if
								Day=:=CheckDay->
									Result = lists:foldl(fun(AnswerInfo2,Re)->
										{_Type2,[StartLines2]} = answer_db:get_activity_start(AnswerInfo2),
										if
											Re->
												Re;	
											true->
												R=timer_util:check_sec_is_in_timeline_by_day(CheckTime, StartLines2),
												if 
													R->
														true;
													true->
														false
												end
										end 
									end, false, AnswerInfoList),
									case Result of
										true->
											answer_sign_request();
										false->
											nothing
									end;
								true->
									nothing
							end
					end;
				_->
					nothing
			end;
		_->
			nothing
	end.
	
hook_on_offline()->
	AnswerInfoList = answer_db:get_activity_info(?ANSWER_ACTIVITY),
	CheckFun = fun(AnswerInfo)->
				{Type,StartLines} = answer_db:get_activity_start(AnswerInfo),
				case activity_manager_op:check_is_time_line(Type,StartLines) of
					{true,_}->
						RoleId = get(roleid),
						answer_processor:apply_leave_activity(RoleId);
					_->
						nothing
				end
	end,
	lists:foreach(CheckFun, AnswerInfoList).
	

%%
%% Local Functions
%%

