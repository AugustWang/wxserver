%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-6-2
%% Description: TODO: Add description to offline_exp_op
-module(offline_exp_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([init/0,load_from_db/1,export_for_copy/0,load_by_copy/1,write_to_db/0,
		 offline_exp_init/0,hook_on_offline/0,offline_exp_exchange_c2s/2,handle_everquest_finished/1,
		 offline/1,offline_exp_exchange_gold_c2s/2
		]).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").
-include("common_define.hrl").
-include("little_garden.hrl").
%%
%% API Functions
%%
init()->
	%% {offline_time,offline_hour,total_exp,quests_log}.
	put(offline_exp_rolelog,[]).

load_from_db(RoleId)->
	case offline_exp_db:get_offline_exp_rolelog(RoleId) of
		{ok,[]}->
			init();
		{ok,Info}->
			OfflineLog = offline_exp_db:get_offline_log(Info),
			put(offline_exp_rolelog,OfflineLog);
		_->
			init()
	end.

export_for_copy()->
	get(offline_exp_rolelog).

load_by_copy(OfflineLog)->
	put(offline_exp_rolelog,OfflineLog).

write_to_db()->
	ok.

offline_exp_init()->
	case get(offline_exp_rolelog) of
		[]->
			nothing;
		OfflineLog->
			{LastTime,Hours,_TotalExp,QuestsLog} = OfflineLog,
			MiddleHours = timer_util:get_time_compare_trunc({hour,LastTime}),
			if
				(Hours + MiddleHours)>72->
					THour=72;
				true->
					THour = Hours + MiddleHours
			end,
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			TotalHour = if%%@@wb20130507 根据要求，30级开始计算离线经验
							RoleLevel >=30 ->
								THour;
							true ->
								0
						end,
			case offline_exp_db:get_offline_exp_info(RoleLevel) of
				[]->
					PerHourExp = 0;
				OEInfo->
					if%%@@wb20130507 根据要求，30级开始计算离线经验
						RoleLevel >= 30 ->
					PerHourExp = offline_exp_db:get_offline_exp_hourexp(OEInfo);
						true ->
							PerHourExp = 0
					end
			end,
			NewTotalExp = PerHourExp * TotalHour,
			Message = offline_exp_packet:encode_offline_exp_init_s2c(TotalHour, NewTotalExp),
			role_op:send_data_to_gate(Message),
			case offline_exp_db:get_all_offline_everquests_exp_info() of
				[]->
					nothing;
				QuestInfos->
					QuestInitFun = fun({_,QuestInfo},Acc)->
						{StarLevel,EndLevel} = offline_exp_db:get_offline_everquests_levelrange(QuestInfo),
						Id = offline_exp_db:get_offline_everquests_id(QuestInfo),
						QuestIds = offline_exp_db:get_offline_everquests_questsids(QuestInfo),
						QuestAddition = offline_exp_db:get_offline_everquests_exp(QuestInfo),
						MaxAddition = offline_exp_db:get_offline_everquests_max_exp(QuestInfo),
						AddCount = offline_exp_db:get_offline_everquests_addcount(QuestInfo),
						if
							RoleLevel>=StarLevel,RoleLevel=<EndLevel->	
								case lists:keyfind(Id, 1, QuestsLog) of
									false->
										Now = timer_center:get_correct_now(),
										Acc ++ [{Id,QuestIds,Now,100,0}];
									{QID,QIds,QLastFinishTime,QExp,QAddCount}->
										if
											QExp=:=MaxAddition,QAddCount=:=AddCount->
												Acc ++ [{QID,QIds,QLastFinishTime,QExp,QAddCount}];
											true->
												MiddleDays = timer_util:get_time_compare_trunc({day,QLastFinishTime}),
												if
													MiddleDays=:=0->
														if
															QAddCount>0->
																Acc ++ [{QID,QIds,QLastFinishTime,QExp,QAddCount}];
															true->
																Acc ++ [{QID,QIds,QLastFinishTime,100,0}]
														end;
													MiddleDays>1->
														case lists:keyfind(MiddleDays-1, 1, QuestAddition) of
															false->
																Acc ++ [{QID,QIds,QLastFinishTime,MaxAddition,AddCount}];
															{_Days,Addition}->
																Acc ++ [{QID,QIds,QLastFinishTime,Addition,AddCount}]
														end;
													true->
														Acc ++ [{QID,QIds,QLastFinishTime,100,0}]
												end
										end
								end;
							true->
								Acc
						end
					end,
					NewQustesLog = lists:foldl(QuestInitFun, [], QuestInfos),
					send_quests_data(NewQustesLog),
					put(offline_exp_rolelog,{LastTime,TotalHour,NewTotalExp,NewQustesLog}),
					RoleId = get(roleid),
					offline_exp_db:sync_update_offline_exp_rolelog(RoleId,{RoleId,{LastTime,TotalHour,NewTotalExp,NewQustesLog}})
			end
	end.

check_consume_item(Items,ConsumeItems)->
	CheckFun = fun({_,TemplateId,Counts},Acc)->
		case lists:keymember(TemplateId, 1, Items) of
			false->
				0;
			true->
				ItemCounts = item_util:get_items_count_in_package(TemplateId),
				if
					Counts=<ItemCounts->
						Acc+Counts;
					true->
						0
				end
		end
	end,
	lists:foldl(CheckFun, 0, ConsumeItems).

offline_exp_exchange_c2s(0,_Hours)->
	nothing;
offline_exp_exchange_c2s(Type,Hours)->
	case get(offline_exp_rolelog) of
		[]->
			Errno = ?ERRNO_NPC_EXCEPTION;
		{LastTime,DHours,_TotalExp,QuestsLog}->
			if
				DHours<Hours,Hours>0->
					Errno = ?ERRNO_LESS_OFFLINE_HOURS;
				true->
					RoleId = get(roleid),
					RoleLevel = get_level_from_roleinfo(get(creature_info)),
					case offline_exp_db:get_offline_exp_info(RoleLevel) of
						[]->
							Errno = ?ERRNO_NPC_EXCEPTION;
						Info->
							HourExp = offline_exp_db:get_offline_exp_hourexp(Info),
							Exchange = offline_exp_db:get_offline_exp_exchange(Info),
							case lists:nth(Type,Exchange) of
								{Multi,MoneyInfo}->
									if
										MoneyInfo =:= []->
											Errno = [],
											role_op:obtain_exp(HourExp*Hours*Multi);
										true->
											[{MoneyType,Count}] = MoneyInfo,
											case role_op:check_money(MoneyType, Count*Hours) of
												true->
													Errno = [],
													role_op:money_change(MoneyType, -Count*Hours,lost_offline_exp),
													role_op:obtain_exp(HourExp*Hours*Multi);
												false->
													Errno = ?ERROR_LESS_MONEY
											end
									end;
								_->
									Multi = 0,
									Errno = ?ERRNO_NPC_EXCEPTION
							end,
							if
								Errno=:=[]->
									put(offline_exp_rolelog,{LastTime,DHours-Hours,(DHours-Hours)*HourExp,QuestsLog}),
									Term = {RoleId,get(offline_exp_rolelog)},
									offline_exp_db:sync_update_offline_exp_rolelog(RoleId, Term),
									Exp = Multi*HourExp*Hours,
									gm_logger_role:role_offline_exp(RoleId,RoleLevel,Hours,Exp,Multi),
									Message = offline_exp_packet:encode_offline_exp_init_s2c(DHours-Hours, (DHours-Hours)*HourExp),
									role_op:send_data_to_gate(Message);
								true->
									nothing
							end
					end
			end
	end,
	if 
		Errno =/= []->
			Message_failed = offline_exp_packet:encode_offline_exp_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

offline_exp_exchange_gold_c2s(Type,Hours)->
	case get(offline_exp_rolelog) of
		[]->
			Errno = ?ERRNO_NPC_EXCEPTION;
		{LastTime,DHours,_TotalExp,QuestsLog}->
			if
				DHours<Hours,Hours>0->
					Errno = ?ERRNO_LESS_OFFLINE_HOURS;
				true->
					RoleId = get(roleid),
					RoleLevel = get_level_from_roleinfo(get(creature_info)),
					case offline_exp_db:get_offline_exp_info(RoleLevel) of
						[]->
							Errno = ?ERRNO_NPC_EXCEPTION;
						Info->
							HourExp = offline_exp_db:get_offline_exp_hourexp(Info),
							case check_gold(Type,Hours) of
								false->
									if
										Type=:=0->
											Errno = 0,
											gm_logger_role:role_offline_exp(RoleId,RoleLevel,Hours,HourExp,Type);
										true->
											Errno = ?ERROR_LESS_GOLD,
											nothing
									end;
								Gold->
									role_op:money_change(?MONEY_GOLD, -Gold,lost_offline_exp),
									role_op:obtain_exp(Type*HourExp*Hours),
									Errno = []
							end,
							if
								Errno=:=[]->
									put(offline_exp_rolelog,{LastTime,DHours-Hours,(DHours-Hours)*HourExp,QuestsLog}),
									Term = {RoleId,get(offline_exp_rolelog)},
									offline_exp_db:sync_update_offline_exp_rolelog(RoleId, Term),
									Exp = Type*HourExp*Hours,
									gm_logger_role:role_offline_exp(RoleId,RoleLevel,Hours,Exp,Type+10),
									Message = offline_exp_packet:encode_offline_exp_init_s2c(DHours-Hours, (DHours-Hours)*HourExp),
									role_op:send_data_to_gate(Message);
								true->
									nothing
							end
					end
			end
	end,
	if 
		Errno =/= []->
			if
				Errno=:=0->
					nothing;
				true->
					Message_failed = offline_exp_packet:encode_offline_exp_error_s2c(Errno),
					role_op:send_data_to_gate(Message_failed)
			end;
 		true->
			nothing
	end.

check_gold(Type,Hours)->
	case Type of 
		2->
			case role_op:check_money(?MONEY_GOLD, Hours*?OFFLINE_2_GOLD) of
				true->
					Hours*?OFFLINE_2_GOLD;
				_->
					false
			end;
		4->
			case role_op:check_money(?MONEY_GOLD, Hours*?OFFLINE_4_GOLD) of
				true->
					Hours*?OFFLINE_4_GOLD;
				_->
					false
			end;
		_->
			false
	end.

hook_on_offline()->
	RoleId = get(roleid),
	Now = timer_center:get_correct_now(),
	case get(offline_exp_rolelog) of
		[]->
			offline_exp_db:sync_update_offline_exp_rolelog(RoleId, {RoleId,{Now,0,0,[]}});
		{_LastTime,Hours,TotalExp,QuestsLog}->
			offline_exp_db:sync_update_offline_exp_rolelog(RoleId,{RoleId,{Now,Hours,TotalExp,QuestsLog}})
	end.

send_quests_data(NewQustesLog)->
	MessageObject = lists:foldl(fun({A,_B,_C,D,_E},Acc)->
										 if
											 D>100->
												 Acc ++ [{oqe,A,D}];
											 true->
												 Acc
										 end
					end, [], NewQustesLog),
	QuestInitMessage = offline_exp_packet:encode_offline_exp_quests_init_s2c(MessageObject),
	role_op:send_data_to_gate(QuestInitMessage).

handle_everquest_finished(EverQuestId)->
	Now = timer_center:get_correct_now(),
	RoleId = get(roleid),
	RoleLevel = get_level_from_roleinfo(get(creature_info)),
	case get(offline_exp_rolelog) of
		[]->
			1;
		{_LastTime,Hours,TotalExp,QuestsLog}->
			QuestFinishedFun = fun({QID,QIds,_QLastFinishTime,QExp,QAddCount},Acc)->
				case lists:member(EverQuestId, QIds) of
					false->
						Acc;
					true->
						if
							QAddCount > 0->
								if
									QAddCount=:=1->
										NewQustesLog = lists:keyreplace(QID, 1, QuestsLog, {QID,QIds,Now,100,QAddCount-1}),
										put(offline_exp_rolelog,{Now,Hours,TotalExp,NewQustesLog}),
										send_quests_data(NewQustesLog),
										Acc+QExp;
									true->
										NewQustesLog = lists:keyreplace(QID, 1, QuestsLog, {QID,QIds,Now,QExp,QAddCount-1}),
										put(offline_exp_rolelog,{Now,Hours,TotalExp,NewQustesLog}),
										Acc+QExp
								end;
							true->
								NewQustesLog = lists:keyreplace(QID, 1, QuestsLog,{QID,QIds,Now,100,0}),
								put(offline_exp_rolelog,{Now,Hours,TotalExp,NewQustesLog}),
								Acc+100
						end
				end
			end,
			Result = lists:foldl(QuestFinishedFun, 0, QuestsLog),
			if
				Result=:=0->
					1;
				true->
					gm_logger_role:role_offline_everquest(RoleId,EverQuestId,RoleLevel,Result),
					Result/100
			end
	end.

offline(Offline)->
	Hours = list_to_integer(Offline),
	case get(offline_exp_rolelog) of
		[]->
			nothing;
		{LastTime,DHours,_TotalExp,QuestsLog}->
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			case offline_exp_db:get_offline_exp_info(RoleLevel) of
				[]->
					nothing;
				Info->
					HourExp = offline_exp_db:get_offline_exp_hourexp(Info),
					RoleId = get(roleid),
					NewQuestsLog = lists:map(fun({QId,QIDs,QTime,QExp,QCount})->
													 {MSec,Sec,USec} = QTime,
													 {QId,QIDs,{MSec,Sec-Hours*3600,USec},QExp,QCount} 
											 end,QuestsLog),
					put(offline_exp_rolelog,{LastTime,DHours+Hours,(DHours+Hours)*HourExp,NewQuestsLog}),
					send_quests_data(NewQuestsLog),
					Term = {RoleId,get(offline_exp_rolelog)},
					offline_exp_db:sync_update_offline_exp_rolelog(RoleId, Term),
					Message = offline_exp_packet:encode_offline_exp_init_s2c(DHours+Hours, (DHours+Hours)*HourExp),
					role_op:send_data_to_gate(Message)
			end
	end,
	case get(role_goals) of
		[]->
			nothing;
		RoleGoals->
			{MyRoleId,RegTime,RGoals} = RoleGoals,
			NewRegSec = calendar:datetime_to_gregorian_seconds(RegTime)-Hours*3600,
			NewRegTime = calendar:gregorian_seconds_to_datetime(NewRegSec),
			put(role_goals,{MyRoleId,NewRegTime,RGoals}),
			goals_db:sync_update_goals_role_to_mnesia({MyRoleId,NewRegTime,RGoals})
	end.

%%
%% Local Functions
%%

