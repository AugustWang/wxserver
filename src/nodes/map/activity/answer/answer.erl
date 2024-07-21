%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-3-31
%% Description: TODO: Add description to answer
-module(answer).

%%
%% Include files
%%
-include("activity_define.hrl").
-include("system_chat_define.hrl").
%%
%% Exported Functions
%%
-export([init/2,activity_sign_notify/1,activity_start_notify/0,apply_join_activity/1,apply_answer_question/1,
		 send_question_to_sign_user/2,generator_rank_list/0,get_activity_state/0,apply_leave_activity/1,
		 end_notice_to_sign_user/0]).

-include("data_struct.hrl").
-include("role_struct.hrl").
%%
%% API Functions
%%

%%rank_list : {Rid,Rname,Rscore,Index}
  
init(Duration,Args)->
	put(answer_info,{Args,Duration}),
	put(sign_list,[]),
	put(answer_list,[]),
	put(current_answer,[]),
	put(rank_list,[]),
	put(answer_state,?ACTIVITY_STATE_INIT),
	random:seed(timer_center:get_correct_now()),
	generator_answer_list(),
	erlang:send_after(30*1000,self(),{activity_sign_notify,Duration/1000}),
 	erlang:send_after(Duration + 30*1000,self(),{activity_start_notify}).

get_activity_state()->
	{_,Duration} = get(answer_info),
	{MSec1,Sec1,_}=timer_center:get_correct_now(),
	CurSec = MSec1*1000000+Sec1,
	case get(answer_sign_time) of
		undefined->
			nothing;
		{MSec2,Sec2,_}->
			SignSec = MSec2*1000000+Sec2,
			LeftTime = Duration/1000 - (CurSec-SignSec),
			{get(answer_state),LeftTime}
	end.

activity_sign_notify(LeftTime)->
	put(answer_state,?ACTIVITY_STATE_SIGN),
	put(answer_sign_time,timer_center:get_correct_now()),
%% 	system_chat_op:send_message(?SYSTEM_CHAT_ANSWER_DETAIL, [],[]),
	system_chat_op:system_broadcast(?SYSTEM_CHAT_ANSWER_DETAIL,[]),
	Message = answer_packet:encode_answer_sign_notice_s2c(LeftTime),
	role_pos_util:send_to_all_online_clinet(Message).

activity_start_notify()->
	put(answer_state,?ACTIVITY_STATE_START),
	put(answer_time,timer_center:get_correct_now()),
	AnswerOP = answer_db:get_answer_option_info(?ANSWER_ACTIVITY),
	Num = answer_db:get_answerop_nums(AnswerOP),
	Interval = answer_db:get_answerop_interval(AnswerOP),
%%  	Ids = generator_answer_list(Num),
	StartNoticeFun = fun(Number)->
							 case get(answer_list) of
								 []->
									 nothing;
								 AnswerList->
									 case lists:nth(Number, AnswerList) of
										 []->
											 nothing;
										 AnswerInfo->
											 AnswerId = answer_db:get_answer_id(AnswerInfo),
											 AnswerInterval = answer_db:get_answer_time(AnswerInfo),
											 if Number=:=1->
													erlang:send_after((Number)*(AnswerInterval+2)*1000, self(), {generator_rank_list});
												true->
													erlang:send_after(((Number-1)*(AnswerInterval+Interval)+AnswerInterval+2)*1000, self(), {generator_rank_list})
											 end,
											 %%end notice
											 if Number=:=Num->
													erlang:send_after(Number*(AnswerInterval+Interval)*1000, self(), {end_notice_to_sign_user});
												true->
													nothing
											 end,
											 erlang:send_after((Number-1)*(AnswerInterval+Interval)*1000, self(), {send_question_to_sign_user,AnswerId,Number})
									 end
							 end
					 end,
	lists:foreach(StartNoticeFun, lists:seq(1, Num)).
	
sorted_asc(L)->
	lists:usort(fun({_,_,Score1},{_,_,Score2})->
						Score1<Score2
				end, L).

sorted_desc(L)->
	lists:reverse(sorted_asc(L)).

generator_rank_list()->
	case get(sign_list) of
		[]->
			nothing;
		SignList->
			SortedList = sorted_desc(SignList),
			put(sign_list,SortedList),
			RankList = lists:map(fun(Num)->
								  {Rid,Rname,Rscore} = lists:nth(Num, SortedList),
								  {Rid,Rname,Rscore,Num}
						  end, lists:seq(1, erlang:length(SortedList))),
			put(rank_list,RankList),
			TempRankList = lists:foldl(fun(T,Acc)->
												  {_,_,_,N}=T,
												  if N>10->
														 Acc;
													 true->
														 Acc++[T]
												  end
										  end, [], RankList),
			MessageRankList = lists:map(fun({_,Rname,Rscore,_})->{aqrl,Rname,Rscore} end, TempRankList),
			Message = answer_packet:encode_answer_question_ranklist_s2c(MessageRankList),
			lists:foreach(fun({RoleId,_,_})-> role_pos_util:send_to_role_clinet(RoleId, Message)  end,SignList)
	end.

send_question_to_sign_user(Id,Num)->
	{MSec,Sec,_}=timer_center:get_correct_now(),
	CurSec = MSec*1000000+Sec,
	put(current_answer,{Id,Num,CurSec}),
	Message = answer_packet:encode_answer_start_notice_s2c(Id,Num),
	lists:foreach(fun({RoleId,_,_})-> role_pos_util:send_to_role_clinet(RoleId, Message)  end,get(sign_list)).

send_get_reward_to_all_user()->
	case get(rank_list) of
		[]->
			nothing;
		RankList->
			if erlang:length(RankList)>=3->
				   {RoleId1,RN1,Score1,_}=lists:nth(1, RankList),
				   {RoleId2,RN2,Score2,_}=lists:nth(2, RankList),
				   {RoleId3,RN3,Score3,_}=lists:nth(3, RankList),
				   ParamRole1 = chat_packet:makeparam(role,{RN1, RoleId1, 0}),
				   ParamRole2 = chat_packet:makeparam(role,{RN2, RoleId2, 0}),
				   ParamRole3 = chat_packet:makeparam(role,{RN3, RoleId3, 0}),
				   MsgInfo = [ParamRole1,ParamRole2,ParamRole3],
				   role_game_rank:hook_on_answer_log([{RoleId1,Score1},{RoleId2,Score2},{RoleId3,Score3}]),
				   system_chat_op:system_broadcast(?SYSTEM_CHAT_ANSWER_TOP3,MsgInfo);
			   true->
				   nothing
			end,
			S = fun(RolePos)->
				RoleNode = role_pos_db:get_role_mapnode(RolePos),
				RoleProc = role_pos_db:get_role_pid(RolePos),
				Id = role_pos_db:get_role_id(RolePos),
				case lists:keyfind(Id, 1, RankList) of
					{_,_,Score,Rank}->
						gs_rpc:cast(RoleNode,RoleProc,{answer_reward,Score,Rank});
					false->
						nothing
				end
			end,
			role_pos_db:foreach(S)
	end.

end_notice_to_sign_user()->
	case get(answer_state) of
		?ACTIVITY_STATE_START->
			put(answer_state,?ACTIVITY_STATE_STOP),
			send_get_reward_to_all_user();
		_->
			nothing
	end.

loop_fun(_Len,T,0)->
	T;

loop_fun(Len,T,Num)->
	Random = random:uniform(Len),
	case lists:member(Random, T) of
		true->
			loop_fun(Len,T,Num);
		false->
			loop_fun(Len,T++[Random],Num-1)
	end.

generator_answer_list()->
	AnswerOP = answer_db:get_answer_option_info(?ANSWER_ACTIVITY),
	Num = answer_db:get_answerop_nums(AnswerOP),
	%%AnswerList = answer_db:get_all_answer_info(),
	%%Len = erlang:length(AnswerList),
	Len = answer_db:get_answer_length(),
	T = loop_fun(Len,[],Num),
	io:format("T:~p~n",[T]),
%% 	L = lists:map(fun(Id)->lists:keyfind(Id, 2, AnswerList) end, T),
	L = lists:map(fun(Id)->answer_db:get_answer_info(Id) end, T),
	put(answer_list,L).

apply_join_activity(Args)->
	case get(answer_state) of
		?ACTIVITY_STATE_SIGN->
			{RoleId,RoleName,_} = Args,
			case get(sign_list) of
				[]->
					NewSignList = [{RoleId,RoleName,0}],
					put(sign_list,NewSignList),
					ok;
				SignList->
					case lists:keymember(RoleId, 1, SignList) of
						true->
							exist;
						false->
							NewSignList = SignList++[{RoleId,RoleName,0}],
							put(sign_list,NewSignList),
							ok
					end
			end;
		_->
			state_error
	end.

apply_leave_activity(RoleId)->
	put(sign_list,lists:keydelete(RoleId, 1, get(sign_list))),
	put(rank_list,lists:keydelete(RoleId, 1, get(rank_list))).

apply_answer_question(Args)->
	case get(answer_state) of
		?ACTIVITY_STATE_START->
			{RoleId,AnswerId,Flag} = Args,
			case get(sign_list) of
				[]->
					state_error;
				SignList->
					case lists:keyfind(RoleId, 1, SignList) of
						{_,RoleName,TotalScore}->
							if Flag=:=-1->
								  Rank = get_my_rank(RoleId),
								  {TotalScore,Rank};
							   true->
								   case get(current_answer) of
									   []->
										   state_error;
									   {Id,_Num,StartSec}->
										   if
											   AnswerId =:= Id->
												   case get(answer_list) of
													   []->
														   state_error;
													   AnswerList->
														   AnswerInfo = lists:keyfind(Id,2,AnswerList),
														   Score = answer_db:get_answer_score(AnswerInfo),
														   {MSec,Sec,_}=timer_center:get_correct_now(),
														   CurSec = MSec*1000000+Sec,
														   SpendTime = CurSec-StartSec,
														   if 
															   SpendTime>=0,SpendTime=<20->
																   if 
																	   SpendTime=:=0->
																		   CurScore = lists:nth(1, Score);
																	   true->
																		   CurScore = lists:nth(SpendTime, Score)
																   end;
															   true->
																   CurScore = lists:nth(erlang:length(Score),Score)
														   end,
														   if Flag=:=1->
																  FinalScore = CurScore*2;
															  true->
																  FinalScore = CurScore
														   end,
														   NewTotalScore = TotalScore+FinalScore,
														   put(sign_list,lists:keyreplace(RoleId, 1, SignList, {RoleId,RoleName,NewTotalScore})),
														   Rank = get_my_rank(RoleId),
														   gm_logger_role:answering_log(RoleId, 2, SpendTime,Flag, FinalScore),
														   {NewTotalScore,Rank}
												   end;
											   true->
												   state_error
										   end
								   end
							end;
						false->
							nosign
					end
			end;
		_->
			state_error
	end.

%%
%% Local Functions
%%
get_my_rank(RoleId)->
	case get(rank_list) of
		[]->
			0;
		RankList->
			case lists:keyfind(RoleId,1,RankList) of
				false->
					0;
				{_,_,_,Rank}->
					Rank
			end
	end.
			
