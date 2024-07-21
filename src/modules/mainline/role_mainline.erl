%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(role_mainline).

-compile(export_all).

-include("mainline_def.hrl").
-include("mainline_define.hrl").
-include("login_pb.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("game_map_define.hrl").
-include("map_info_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("game_rank_define.hrl").
-include("npc_define.hrl").

%%
%%process dic define
%%
%%
%%mainline_info [{{chapter,stage},state,first_award_state,common_award_state,timerecord,bestrecord}]
%%
%%mainline_init_flag true|false
%%
%%mainline_state {chapter,stage,state}


%% state change   idle ->[entry]-> prepare ->[start]-> fight ->[result]-> reward ->[exit]-> idle
%%
%% every state ->[end form client] -> reward -> idle
%%

%% API
%%

%%
%% login
%%
init()->
	MyMainlineInfo = mainline_db:get_role_record(get(roleid)),
	put(mainline_info,MyMainlineInfo),
	put(mainline_init_flag,false),
	put(mainline_state,{[],[],[],[],[]}),
	check_active_stage(?BY_LEVELUP).
		
%%
%%logout
%%
uninit()->
	change_state_to_idle().

%%
%%levelup
%%
hook_level_up()->
	check_active_stage(?BY_LEVELUP).

%%
%%map change
%%
hook_map_complete()->
	case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
		?MAP_TAG_STAGE->
			case get(mainline_state) of
				{Chapter,Stage,Difficulty,?STAGE_BEFORE_ENTRY_MAP,[]}->
					NewState = {Chapter,Stage,Difficulty,?STAGE_ENTRY_MAP_AND_PREPARE,[]},
					put(mainline_state,NewState),
					send_update_message(Chapter,Stage,1),
					gm_logger_role:mainline_opt(get(roleid),
										get_level_from_roleinfo(get(creature_info)),
										Chapter,Stage,Difficulty,entry,ok),
					SuccessBinMsg = mainline_packet:encode_mainline_start_entry_s2c(Chapter,Stage,Difficulty,?SUCCESS),
					role_op:send_data_to_gate(SuccessBinMsg);
				_->
					slogger:msg("~p hook_map_complete entry stage map but not init [~p] ~n",[get(roleid),get(mainline_state)]),
					change_state_to_idle()
			end;
		_->
			case get(mainline_state) of
				{[],[],[],[],[]}->
					nothing;
				{Chapter,Stage,Difficulty,_,_}->
					mainline_defend_op:uninit(),
					put(mainline_state,{[],[],[],[],[]}),
					case role_op:is_dead() of
						true->
							role_op:respawn_normal_inpoint();
						_->
							nothing
					end,
					gm_logger_role:mainline_opt(get(roleid),
										get_level_from_roleinfo(get(creature_info)),
										Chapter,Stage,Difficulty,leave,[]),
					LeaveMsg = mainline_packet:encode_mainline_end_s2c(),
					role_op:send_data_to_gate(LeaveMsg)
			end
	end.

%%
%%dead
%%
hook_be_killed()->
			{Chapter,Stage,Difficulty,State,_FightInfo} = get(mainline_state),
			case State of
				?STAGE_STATE_FIGHT->
					gm_logger_role:mainline_opt(get(roleid),
										get_level_from_roleinfo(get(creature_info)),
										Chapter,Stage,Difficulty,faild,be_killed),
					change_state_to_reward(?FAILD);
				_->
					nothing
			end.

	
update({monster_kill,NpcProtoId})->
			{Chapter,Stage,Difficulty,State,FightInfo} = get(mainline_state),
			case State of
				?STAGE_STATE_FIGHT->
					{Type,StartTime,UpdateInfo} = FightInfo,
					gm_logger_role:mainline_killmonster(get(roleid),
														get_level_from_roleinfo(get(creature_info)),
														Chapter,Stage,Difficulty,NpcProtoId),
					case Type of
						?STAGE_KILLALL->
							AllMonsters = mapop:get_map_units_id(),
							KillMonsters = mapop:get_map_dead_units(AllMonsters),
							AllNum = erlang:length(AllMonsters),
							KillNum = erlang:min(erlang:length(KillMonsters),AllNum),
							RemainNum = AllNum - KillNum,
							RemainInfoMsg = mainline_packet:encode_mainline_remain_monsters_info_s2c(Chapter,Stage,KillNum,RemainNum),
							role_op:send_data_to_gate(RemainInfoMsg),
							case RemainNum =:= 0 of
								false->
									nothing;
								_->
									change_state_to_reward(?SUCCESS)
							end;
						?STAGE_KILLALL_AND_TIMELIMIT->
							MyClass = get_class_from_roleinfo(get(creature_info)),
							case mainline_db:get_info(Chapter,Stage,Difficulty,MyClass) of
								[]->
									nothing;	
								StageInfo->
									LeftTime = mainline_db:get_time_s(StageInfo),
									TimeDiff = timer:now_diff(timer_center:get_correct_now(),StartTime)/1000000,
									CheckTime = (LeftTime >= TimeDiff),
									if
										CheckTime->
											AllMonsters = mapop:get_map_units_id(),
											KillMonsters = mapop:get_map_dead_units(AllMonsters),
											AllNum = erlang:length(AllMonsters),
											KillNum = erlang:min(erlang:length(KillMonsters),AllNum),
											RemainNum = AllNum - KillNum,
											RemainInfoMsg = mainline_packet:encode_mainline_remain_monsters_info_s2c(Chapter,Stage,KillNum,RemainNum),
											role_op:send_data_to_gate(RemainInfoMsg),
											case RemainNum =:= 0 of
												false->
													nothing;
												_->
													change_state_to_reward(?SUCCESS)
											end;
										true->
											gm_logger_role:mainline_opt(get(roleid),
												get_level_from_roleinfo(get(creature_info)),
													Chapter,Stage,Difficulty,faild,timeout),
											change_state_to_reward(?FAILD)
									end
							end;
						?STAGE_KILLPART->
							case lists:keyfind(NpcProtoId,1,UpdateInfo) of
								false->
									nothing;
								{_,CurNum}->
									NewNum = erlang:max(0,CurNum-1),
									NewUpdateInfo = lists:keyreplace(NpcProtoId,1,UpdateInfo,{NpcProtoId,NewNum}),
									put(mainline_state,{Chapter,Stage,Difficulty,State,{Type,StartTime,NewUpdateInfo}}),
									NeedKillInfoMsg = mainline_packet:encode_mainline_kill_monsters_info_s2c(Chapter,Stage,NpcProtoId,NewNum),
									role_op:send_data_to_gate(NeedKillInfoMsg),
									ResultCheck = lists:foldl(fun({_,RemainNum},Acc)->
																	if
																		not Acc ->
																			Acc;
																		true->
																			RemainNum =< 0
																	end
																end,true,NewUpdateInfo),
									if
										ResultCheck->
											change_state_to_reward(?SUCCESS);
										true->
											nothing
									end				
							end;
						?STAGE_KILLPART_AND_TIMELIMIT->
							MyClass = get_class_from_roleinfo(get(creature_info)),
							case mainline_db:get_info(Chapter,Stage,Difficulty,MyClass) of
								[]->
									nothing;
								StageInfo->
									LeftTime = mainline_db:get_time_s(StageInfo),
									TimeDiff = timer:now_diff(timer_center:get_correct_now(),StartTime)/1000000,
									CheckTime = (LeftTime >= TimeDiff),
									if
										CheckTime->
											case lists:keyfind(NpcProtoId,1,UpdateInfo) of
												false->
													nothing;
												{_,CurNum}->
													NewNum = erlang:max(0,CurNum-1),
													NewUpdateInfo = lists:keyreplace(NpcProtoId,1,UpdateInfo,{NpcProtoId,NewNum}),
													put(mainline_state,{Chapter,Stage,Difficulty,State,{Type,StartTime,NewUpdateInfo}}),
													NeedKillInfoMsg = mainline_packet:encode_mainline_kill_monsters_info_s2c(Chapter,Stage,NpcProtoId,NewNum),
													role_op:send_data_to_gate(NeedKillInfoMsg),
													ResultCheck = lists:foldl(fun({_,RemainNum},Acc)->
																	if
																		not Acc ->
																			Acc;
																		true->
																			RemainNum =< 0
																	end
																end,true,NewUpdateInfo),
													if
														ResultCheck->
															change_state_to_reward(?SUCCESS);
														true->
															nothing
													end	
											end;
										true->
											gm_logger_role:mainline_opt(get(roleid),
												get_level_from_roleinfo(get(creature_info)),
												Chapter,Stage,Difficulty,faild,timeout),
											change_state_to_reward(?FAILD)
									end
							end;
						?STAGE_DEFEND_AND_PROTECT_NPC->
							AllMonsterIds = UpdateInfo,
							case mapop:is_all_dead_id(AllMonsterIds) of
								true->
									case mainline_defend_op:check_section_over() of
										true->
											change_state_to_reward(?SUCCESS);
										_->
											mainline_defend_op:force_update()
									end;
								_->
									nothing
							end;
						?STAGE_DEFEND->
							AllMonsterIds = UpdateInfo,
							case mapop:is_all_dead_id(AllMonsterIds) of
								true->
									case mainline_defend_op:check_section_over() of
										true->
											change_state_to_reward(?SUCCESS);
										_->
											mainline_defend_op:force_update()
									end;
								_->
									nothing
							end;
						_->
							todo
					end;
				_->
					nothing
			end;

update({add_monster,MonsterIds})->
	case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
		?MAP_TAG_STAGE->
			{Chapter,Stage,Difficulty,State,FightInfo} = get(mainline_state),		
			case State of
				?STAGE_STATE_FIGHT->
					{Type,StartTime,UpdateInfo} = FightInfo,
					if
						(Type =/= ?STAGE_DEFEND_AND_PROTECT_NPC) and (Type =/= ?STAGE_DEFEND)->
							nothing;
						true->
							NewUpdateInfo = UpdateInfo ++ MonsterIds,
							NewFightInfo = {Type,StartTime,NewUpdateInfo},
							put(mainline_state,{Chapter,Stage,Difficulty,State,NewFightInfo})						
					end;		
				_->
					nothing
			end;
		_->
			nothing
	end;

update({section,_SectionNum})->
	todo;

update({Msg,Value})->
	slogger:msg("~p update unknown msg ~p ~n",[?MODULE,{Msg,Value}]).
%%
%%export
%%
export_for_copy()->
	{get(mainline_info),get(mainline_init_flag),get(mainline_state)}.

%%
%%import
%%
load_by_copy(Info)->
	{MainLineInfo,MainLineInitFlag,MainLineState} = Info,
	put(mainline_info,MainLineInfo),
	put(mainline_init_flag,MainLineInitFlag),
	put(mainline_state,MainLineState).

%%
%%todo
%%
process_client_message(#mainline_init_c2s{})->
	send_init_message();

process_client_message(#mainline_start_entry_c2s{chapter = Chapter,stage = Stage,difficulty = Difficulty})->
	{_,_,_,CurState,_} = get(mainline_state),
	CheckDead = role_op:is_dead(),		
	if	
		CheckDead->
			ErrorMsg = mainline_packet:encode_mainline_start_entry_s2c(Chapter,Stage,Difficulty,?ERRNO_ROLE_DEAD),
			role_op:send_data_to_gate(ErrorMsg);
		(CurState =:= []) or (CurState =:= ?STAGE_BEFORE_ENTRY_MAP)->
			case lists:keyfind({Chapter,Stage},1,get(mainline_info)) of
				false->
					slogger:msg("~p entry ~p not open ~n",[get(roleid),{Chapter,Stage}]);
				Term->
					Now = timer_center:get_correct_now(),
					{_,_,_,_,{LastTimeStamp,LastTimes},_} = Term,
					case timer_util:check_same_day(Now,LastTimeStamp) of
							true->
								NewLastTimes = LastTimes;
							_->
								NewLastTimes = 0
					end,					
					MyClass = get_class_from_roleinfo(get(creature_info)),
					case mainline_db:get_info(Chapter,Stage,Difficulty,MyClass) of
						[]->
							slogger:msg("~p entry ~p can't find proto data ~n",[get(roleid),{Chapter,Stage}]);
						StageInfo->
							EntryTimes = mainline_db:get_entry_times(StageInfo),
							TravelCheck = role_server_travel:is_in_travel(),
							if
								TravelCheck->
									ErrorMsg = mainline_packet:encode_mainline_start_entry_s2c(Chapter,Stage,Difficulty,?ERRNO_MAINLINE_ENTRY_IN_TRAVEL_MAP),
									role_op:send_data_to_gate(ErrorMsg);
								EntryTimes > NewLastTimes->
									TransportId = mainline_db:get_transportid(StageInfo),
									case transport_op:can_directly_telesport() of
										true->
											case transport_op:can_teleport(get(creature_info),get(map_info),TransportId) of
												true->
													put(mainline_state,{Chapter,Stage,Difficulty,?STAGE_BEFORE_ENTRY_MAP,[]}),
													gm_logger_role:mainline_opt(get(roleid),
																				get_level_from_roleinfo(get(creature_info)),
																				Chapter,Stage,Difficulty,entry, start),
													transport_op:teleport(get(creature_info),get(map_info),TransportId);
												_->
													ErrorMsg = mainline_packet:encode_mainline_start_entry_s2c(Chapter,Stage,Difficulty,?ERRNO_INSTANCE_RESETING),
													role_op:send_data_to_gate(ErrorMsg)
											end;
										_->
											nothing
									end;
								true->
									ErrorMsg = mainline_packet:encode_mainline_start_entry_s2c(Chapter,Stage,Difficulty,?ERRNO_MAINLINE_ENTRY_TIME_LIMIT),
									role_op:send_data_to_gate(ErrorMsg)
							end
					end
			end;
		true->
			error,todo
	end;
				
process_client_message(#mainline_start_c2s{chapter = Chapter,stage = Stage})->
	case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
		?MAP_TAG_STAGE->
			case get(mainline_state) of
				{Chapter,Stage,Difficulty,?STAGE_ENTRY_MAP_AND_PREPARE,[]}->
					init_stage(Chapter,Stage,Difficulty);
				_->
					error,todo
			end;
		_->
			nothing
	end;	

process_client_message(#mainline_end_c2s{})->
	case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
		?MAP_TAG_STAGE->
			case get(mainline_state) of
				{_Chapter,_Stage,_Difficulty,State,_}->
					case State of
						?STAGE_STATE_REWARD->
							change_state_to_idle();
						_->
							change_state_to_reward(?FAILD)
					end;
				_->
					error,todo
			end;
		_->
			nothing
	end;

process_client_message(#mainline_reward_c2s{chapter = Chapter,stage = Stage,reward = Reward})-> 
	case lists:keyfind({Chapter,Stage},1,get(mainline_info)) of
		false->
			nothing;
		{_,State,FirstAwardState,CommonAwardState,{LastTimeStamp,LastTimes},BestScore}->
			MyClass = get_class_from_roleinfo(get(creature_info)),
			case Reward of
				?REWARD_STATE_FIRST->
					case FirstAwardState of
						?REWARD_STATE_NULL->
							CanDo = false,
							RewardMoney = 0,
							RewardExp = 0,
							RewardItems = [];
						_->
							case mainline_db:get_info(Chapter,Stage,FirstAwardState,MyClass) of
								[]->
									CanDo = false,
									RewardMoney = 0,
									RewardExp = 0,
									RewardItems = [];
								StageInfo->
									CanDo = true,
									RewardMoney = mainline_db:get_first_award_money(StageInfo),
									RewardExp = mainline_db:get_first_award_exp(StageInfo),
									RewardItems = mainline_db:get_first_award_items(StageInfo)
							end
					end,
					if
						CanDo->
							NewFirstAwardState = ?REWARD_STATE_NULL,
							NewCommonAwardState = CommonAwardState;
						true->
							NewFirstAwardState = FirstAwardState,
							NewCommonAwardState = CommonAwardState
					end;
				?REWARD_STATE_COMMON->
					case CommonAwardState of
						?REWARD_STATE_NULL->
							CanDo = false,
							RewardMoney = 0,
							RewardExp = 0,
							RewardItems = [];
						_->
							case mainline_db:get_info(Chapter,Stage,CommonAwardState,MyClass) of
								[]->
									CanDo = false,
									RewardMoney = 0,
									RewardExp = 0,
									RewardItems = [];
								StageInfo->
									CanDo = true,
									RewardMoney = mainline_db:get_first_award_money(StageInfo),
									RewardExp = mainline_db:get_first_award_exp(StageInfo),
									RewardItems = mainline_db:get_first_award_items(StageInfo)
							end
					end,
					if
						CanDo->
							NewFirstAwardState = FirstAwardState,
							NewCommonAwardState = ?REWARD_STATE_NULL;
						true->
							NewFirstAwardState = FirstAwardState,
							NewCommonAwardState = CommonAwardState
					end;	
				_->
					CanDo = false,
					RewardMoney = 0,
					RewardExp = 0,
					RewardItems = [],
					NewFirstAwardState = FirstAwardState,
					NewCommonAwardState = CommonAwardState
			end,
			if
				CanDo->
					%%check packet size 
					case package_op:can_added_to_package_template_list(RewardItems) of
						true->
							MyStageInfo = {{Chapter,Stage},State,NewFirstAwardState,NewCommonAwardState,{LastTimeStamp,LastTimes},BestScore},
							put(mainline_info,lists:keyreplace({Chapter,Stage},1,get(mainline_info),MyStageInfo)),
							%%save db
							mainline_db:save_record_to_db(get(roleid),get(mainline_info)),
							lists:foreach(fun({Itemid,ItemCount})->role_op:auto_create_and_put(Itemid,ItemCount,got_mainline) end,RewardItems),
							role_op:obtain_exp(RewardExp),
							role_op:money_change(?MONEY_BOUND_SILVER, RewardMoney, got_mainline),
							SuccessMsg = mainline_packet:encode_mainline_reward_success_s2c(Chapter,Stage),
							role_op:send_data_to_gate(SuccessMsg),
							send_update_message(Chapter,Stage,0),
							gm_logger_role:mainline_opt(get(roleid),
												get_level_from_roleinfo(get(creature_info)),
												Chapter,Stage,?EASY,reward,Reward);
						_->
							%%packet full
							ErrorMsg = mainline_packet:encode_mainline_opt_s2c(?ERROR_PACKEGE_FULL),
							role_op:send_data_to_gate(ErrorMsg)
							
					end;
				true->
					nothing
			end;
		_->
			nothing
	end;
		
	
process_client_message(#mainline_timeout_c2s{chapter = Chapter,stage = Stage})->
	case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
		?MAP_TAG_STAGE->
			case get(mainline_state) of
				{Chapter,Stage,Difficulty,?STAGE_STATE_FIGHT,FightInfo}->
					{Type,StartTime,_UpdateInfo} = FightInfo,
					if
						(Type =:= ?STAGE_KILLALL_AND_TIMELIMIT) or (Type =:= ?STAGE_KILLPART_AND_TIMELIMIT)->
							MyClass = get_class_from_roleinfo(get(creature_info)),
							case mainline_db:get_info(Chapter,Stage,Difficulty,MyClass) of
								[]->
									nothing;
								StageInfo->
									LeftTime = mainline_db:get_time_s(StageInfo),
									TimeDiff = timer:now_diff(timer_center:get_correct_now(),StartTime)/1000,
									CheckTime = (LeftTime =< TimeDiff),
									if
										CheckTime->
											change_state_to_reward(?FAILD);
										true->
											LeftTimeBinMsg = mainline_packet:encode_mainline_lefttime_s2c(Chapter,Stage,LeftTime - TimeDiff),
											role_op:send_data_to_gate(LeftTimeBinMsg)
									end
							end;
						true->
							nothing
					end;	
				_->
					error,todo
			end;
		_->
			nothing
	end;
																				  
process_client_message(Message)->
	slogger:msg("~p unknown client msg ~p ~n",[?MODULE,Message]).

process_internal_message({mainline_defend_next})->
	case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
		?MAP_TAG_STAGE->
			case get(mainline_state) of
				{Chapter,Stage,Difficulty,?STAGE_STATE_FIGHT,FightInfo}->
					{Type,StartTime,UpdateInfo} = FightInfo,
					if
						(Type =/= ?STAGE_DEFEND_AND_PROTECT_NPC) and (Type =/= ?STAGE_DEFEND)->
							nothing;
						true->
							mainline_defend_op:update()
					end;
				_->
					nothing
			end;
		_->
			nothing
	end;

process_internal_message({npc_bekilled,NpcProtoId})->
	case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
		?MAP_TAG_STAGE->
			case get(mainline_state) of
				{Chapter,Stage,Difficulty,?STAGE_STATE_FIGHT,FightInfo}->
					{Type,StartTime,UpdateInfo} = FightInfo,
					if
						Type =:= ?STAGE_DEFEND_AND_PROTECT_NPC->
							gm_logger_role:mainline_opt(get(roleid),
										get_level_from_roleinfo(get(creature_info)),
										Chapter,Stage,Difficulty,faild,npc_bekilled),
							change_state_to_reward(?FAILD);
						true->
							nothing
					end;
				_->
					nothing
			end;
		_->
			nothing
	end;

process_internal_message(Message)->
	slogger:msg("~p unknown node msg ~p ~n",[?MODULE,Message]).
	

gm_activity_stage(Chapter,Stage)->
	case lists:keyfind({Chapter,Stage},1,get(mainline_info)) of
		false->
			nothing;
		Info->
			NewInfo = setelement(2,Info,?STAGE_COMPLETE),
			put(mainline_info,lists:keyreplace({Chapter,Stage},1,get(mainline_info),NewInfo)),
			mainline_db:save_record_to_db(get(roleid),get(mainline_info)),
			send_update_message(Chapter,Stage,0),
			check_active_stage(?BY_COMPLETE)
	end.
			
	
gm_clear_stage(Chapter,Stage)->
	case lists:keyfind({Chapter,Stage},1,get(mainline_info)) of
		false->
			nothing;
		Info->
			NewInfo = setelement(5,Info,{{0,0,0},0}),
			put(mainline_info,lists:keyreplace({Chapter,Stage},1,get(mainline_info),NewInfo)),
			mainline_db:save_record_to_db(get(roleid),get(mainline_info)),
			send_update_message(Chapter,Stage,0),
			check_active_stage(?BY_COMPLETE)
	end.				
%%
%%Local Function
%%

check_active_stage(Reason)->
	MyClass = get_class_from_roleinfo(get(creature_info)),
	MainLineProto = mainline_db:get_allinfo(MyClass),
	MyLevel = get_level_from_roleinfo(get(creature_info)),
	ActiveStages = 
		lists:foldl(fun(Term,Acc)->
					Chapter = mainline_db:get_chapter(Term),
					Stage = mainline_db:get_stage(Term), 
					Pre_Stage = mainline_db:get_pre_stage(Term),
					PreStageCheck = 
						case lists:keyfind({Chapter,Stage},1,get(mainline_info)) of
							false->
								if
									Pre_Stage =:= []->
										true;
									true->
										case lists:keyfind(Pre_Stage,1,get(mainline_info)) of
											false->
												false;
											{_,PreState,_,_,_,_}->
													PreState =:= ?STAGE_COMPLETE
										end											
								end;
							_->
								false
						end,
					if
						PreStageCheck ->
							Conditions = mainline_db:get_entry_condition(Term),
							Condition_Check = lists:foldl(fun(Condition,Result)->
																  if
																		Result->
																			case Condition of
																				{level,Level}->
																					Level =< MyLevel;
																				_->
																					Result	
																			end;
																		true->
																			Result
																   end 
												 			end, true, Conditions),
							if
								Condition_Check->
									[{Chapter,Stage}|Acc];
								true->
									Acc
							end;
						true->
							Acc
					end
				end,[],MainLineProto),

	InitActiveStages = lists:map(fun({FindChapter,FindStage})->
										{{FindChapter,FindStage},?STAGE_INCOMPLETE,?REWARD_STATE_NULL,?REWARD_STATE_NULL,{{0,0,0},0},0}
									end,ActiveStages),
	if
		InitActiveStages =:= []->
			nothing;
		true->
			send_init_message(),
			put(mainline_info,get(mainline_info)++InitActiveStages),
			mainline_db:save_record_to_db(get(roleid),get(mainline_info)),
			lists:foreach(fun({Chapter,Stage})->
					St = mainline_packet:make_stage(Chapter,Stage,?STAGE_INCOMPLETE,0,?REWARD_STATE_NULL,0,get_best_recordinfo(Chapter,Stage)),
					BinMsg = mainline_packet:encode_mainline_update_s2c(St,Reason),
					role_op:send_data_to_gate(BinMsg)
				end, ActiveStages)
	end.

%%
%%send init message to client and update the flag
%%
send_init_message()->
	case get(mainline_init_flag) of
		undefined->
			nothing;
		true->
			nothing;
		_->		
			case get(mainline_info) of
				[]->
					StList = [];
				MainLineInfo->
					Now = timer_center:get_correct_now(),
					StList = lists:map(fun({{Chapter,Stage},State,FirstAwardState,CommonAwardState,TimeRecord,BestRecord})->
										   {LastTimeStamp,Times} = TimeRecord,
										   if
											   FirstAwardState =/= ?REWARD_STATE_NULL->
												   if
														FirstAwardState =:= ?DIFFICULT ->
															RewardFlag = ?REWARD_STATE_FIRST_DIFFICULT;
														true->
															RewardFlag = ?REWARD_STATE_FIRST
													end;
											   true->
												   if
													    CommonAwardState =:= ?REWARD_STATE_NULL->
															RewardFlag = ?REWARD_STATE_NULL;
														CommonAwardState =:= ?DIFFICULT ->
															RewardFlag = ?REWARD_STATE_COMMON_DIFFICULT;
														true->
															RewardFlag = ?REWARD_STATE_COMMON
													end
										   end,
										   case timer_util:check_same_day(Now,LastTimeStamp) of
											   true->
												  EntryTime = Times;
											   _->
												  EntryTime = 0														
										   end,
										  mainline_packet:make_stage(Chapter,Stage,State,BestRecord,RewardFlag,EntryTime,get_best_recordinfo(Chapter,Stage))
									end,MainLineInfo)
			end,		
			BinMsg = mainline_packet:encode_mainline_init_s2c(StList),
			role_op:send_data_to_gate(BinMsg),
			put(mainline_init_flag,true)
	end.

send_update_message(Chapter,Stage,AddEntryTime)->
	case lists:keyfind({Chapter,Stage},1,get(mainline_info)) of
		false->
			nothing;
		{_,State,FirstAwardState,CommonAwardState,{LastTimeStamp,LastTimes},BestScore}->
			Now = timer_center:get_correct_now(),
			case timer_util:check_same_day(Now,LastTimeStamp) of
				true->
					NewLastTimes = LastTimes + AddEntryTime;
				_->
					NewLastTimes = AddEntryTime
			end,
			NewMainLineInfo = lists:keyreplace({Chapter,Stage},1,get(mainline_info),
												{{Chapter,Stage},State,FirstAwardState,CommonAwardState,{Now,NewLastTimes},BestScore}),
			put(mainline_info,NewMainLineInfo),
			mainline_db:save_record_to_db(get(roleid),NewMainLineInfo),
			if
				FirstAwardState =/= ?REWARD_STATE_NULL->
					if
						FirstAwardState =:= ?DIFFICULT ->
							RewardFlag = ?REWARD_STATE_FIRST_DIFFICULT;
						true->
							RewardFlag = ?REWARD_STATE_FIRST
					end;
				true->
					if
						CommonAwardState =:= ?REWARD_STATE_NULL->
							RewardFlag = ?REWARD_STATE_NULL;
						CommonAwardState =:= ?DIFFICULT ->
							RewardFlag = ?REWARD_STATE_COMMON_DIFFICULT;
						true->
							RewardFlag = ?REWARD_STATE_COMMON
					end
			end,					
			StageInfo = mainline_packet:make_stage(Chapter,Stage,State,BestScore,RewardFlag,NewLastTimes,get_best_recordinfo(Chapter,Stage)),
			UpdateBinMsg = mainline_packet:encode_mainline_update_s2c(StageInfo,?BY_COMPLETE),
			role_op:send_data_to_gate(UpdateBinMsg);
		_->
			nothing
	end.

change_state_to_idle()->
	put(mainline_state,{[],[],[],[],[]}),
	case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
		?MAP_TAG_STAGE->
			mainline_defend_op:uninit(),
			LeaveMsg = mainline_packet:encode_mainline_end_s2c(),
			role_op:send_data_to_gate(LeaveMsg),
			case role_op:is_dead() of
				true->
					role_op:respawn_normal_inpoint();
				_->
					nothing
			end,
			instance_op:kick_from_cur_instance();
		_->
			nothing
	end.

change_state_to_reward(Result)->
	case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
		?MAP_TAG_STAGE->
			case get(mainline_state) of
				{Chapter,Stage,Difficulty,?STAGE_STATE_FIGHT,FightInfo}->
					{Type,StartTime,UpdateInfo} = FightInfo,
					mainline_defend_op:uninit(),
					kick_all_monster(),
					case Result of
						?SUCCESS->
							{_,State,FirstAwardState,CommonAwardState,{LastTimeStamp,LastTimes},BestScore} = lists:keyfind({Chapter,Stage},1,get(mainline_info)),
							Now = timer_center:get_correct_now(),
							Duration = erlang:max(erlang:trunc(timer:now_diff(Now,StartTime)/1000000),1),
							MyClass = get_class_from_roleinfo(get(creature_info)),
							case mainline_db:get_info(Chapter,Stage,Difficulty,MyClass) of
								[]->
									gm_logger_role:mainline_opt(get(roleid),
										get_level_from_roleinfo(get(creature_info)),
										Chapter,Stage,Difficulty,success,error_protodata),
									BinMsg = mainline_packet:encode_mainline_result_s2c(Chapter,Stage,Difficulty,?SUCCESS,?REWARD_STATE_NULL,BestScore,0,Duration),
									role_op:send_data_to_gate(BinMsg);
								StageInfo->
									if
										State =:= ?STAGE_INCOMPLETE->
											NewState = ?STAGE_COMPLETE,
											FirstRewardItems = mainline_db:get_first_award_items(StageInfo),
											FirstRewardMoney = mainline_db:get_first_award_money(StageInfo),
											FirstRewardExp = mainline_db:get_first_award_exp(StageInfo),
											if
												FirstRewardItems =:= [],FirstRewardMoney =:= 0, FirstRewardExp =:= 0 ->
													NewFirstAwardState = ?REWARD_STATE_NULL;
												true->
													NewFirstAwardState = Difficulty
											end,
											NewCommonAwardState = ?REWARD_STATE_NULL,
											if
												NewFirstAwardState =:= ?REWARD_STATE_NULL->
													RewardToClient = ?REWARD_STATE_NULL;
												NewFirstAwardState =:= ?DIFFICULT ->
													RewardToClient = ?REWARD_STATE_FIRST_DIFFICULT;
												true->
													RewardToClient = ?REWARD_STATE_FIRST
											end;
										true->
											NewState = State,
											CommonRewardItems = mainline_db:get_common_award_items(StageInfo),
											CommonRewardMoney = mainline_db:get_common_award_money(StageInfo),
											CommonRewardExp = mainline_db:get_common_award_exp(StageInfo),
											if
												CommonRewardItems=:=[],CommonRewardMoney=:=0,CommonRewardExp=:=0->
													NewCommonAwardState = ?REWARD_STATE_NULL;
												true->
													NewCommonAwardState = Difficulty
											end,
											NewFirstAwardState = FirstAwardState,
											if
												NewCommonAwardState =:= ?REWARD_STATE_NULL->
													RewardToClient = ?REWARD_STATE_NULL;
												NewCommonAwardState =:= ?DIFFICULT ->
													RewardToClient = ?REWARD_STATE_COMMON_DIFFICULT;
												true->
													RewardToClient = ?REWARD_STATE_COMMON
											end
									end,
									LevelFactor = mainline_db:get_level_factor(StageInfo),
									TimeFactor = mainline_db:get_time_factor(StageInfo),
									MyLevel = get_level_from_roleinfo(get(creature_info)),
									TimeScore = erlang:min(?MAX_TIME_SCORE,erlang:trunc(LevelFactor/MyLevel)),									
									CurScore = erlang:trunc(TimeFactor/Duration) + TimeScore,
									if
										CurScore >= BestScore->
											MyServerId = get_serverid_from_roleinfo(get(creature_info)),
											MyClass = get_class_from_roleinfo(get(creature_info)),
											MyName = get_name_from_roleinfo(get(creature_info)),
											game_rank_manager:challenge(get(roleid),
																		?RANK_TYPE_MAIN_LINE,
																		{Chapter,Stage,Difficulty,MyLevel,Duration,CurScore,MyName,MyClass,MyServerId});
										true->
											nothing
									end,
									Designation = mainline_db:get_designation(StageInfo),
									if
										State =:= ?STAGE_INCOMPLETE->
											take_designation(Designation);
										true->
											nothing
									end,
									if
										BestScore < CurScore ->
											NewBestScore = CurScore;
										true->
											NewBestScore = BestScore
									end,
									gm_logger_role:mainline_opt(get(roleid),
										get_level_from_roleinfo(get(creature_info)),
										Chapter,Stage,Difficulty,success,Duration),
									MyStageInfo = {{Chapter,Stage},NewState,NewFirstAwardState,NewCommonAwardState,{LastTimeStamp,LastTimes},NewBestScore},
									put(mainline_info,lists:keyreplace({Chapter,Stage},1,get(mainline_info),MyStageInfo)),
									send_update_message(Chapter,Stage,0),
									mainline_db:save_record_to_db(get(roleid),get(mainline_info)),
									BinMsg = mainline_packet:encode_mainline_result_s2c(Chapter,Stage,Difficulty,?SUCCESS,RewardToClient,NewBestScore,CurScore,Duration),
									role_op:send_data_to_gate(BinMsg),
									check_active_stage(?BY_COMPLETE)	
							end;
						_->
							BinMsg = mainline_packet:encode_mainline_result_s2c(Chapter,Stage,Difficulty,?FAILD,?REWARD_STATE_NULL,0,0,0),
							role_op:send_data_to_gate(BinMsg)
					end,
					put(mainline_state,{Chapter,Stage,Difficulty,?STAGE_STATE_REWARD,[]});	
				_->
					error,todo
			end;
		_->
			nothing
	end.
		
init_stage(Chapter,Stage,Difficulty)-> 
	MyClass = get_class_from_roleinfo(get(creature_info)),
	case mainline_db:get_info(Chapter,Stage,Difficulty,MyClass) of
		[]->
			error,todo;
		StageInfo->
			BinMsg = mainline_packet:encode_mainline_start_s2c(Chapter,Stage,Difficulty,?SUCCESS),
			role_op:send_data_to_gate(BinMsg), 
			MonstersList = mainline_db:get_monsterslist(StageInfo),
			Mylevel = get_level_from_roleinfo(get(creature_info)),
			creature_op:call_creature_spawns(MonstersList,{Mylevel,?CREATOR_BY_SYSTEM}),
			StageType = mainline_db:get_type(StageInfo),
			Now = timer_center:get_correct_now(),
			case StageType of
				?STAGE_KILLALL->
					Time = -1,
					Condition = [];
				?STAGE_KILLALL_AND_TIMELIMIT->
					Time = mainline_db:get_time_s(StageInfo),
					Condition = [];
				?STAGE_KILLPART->
					Time = -1,
					Condition = 
						lists:map(fun({NpcProtoId,Num,_})-> {NpcProtoId,Num} end,mainline_db:get_killmonsterlist(StageInfo));
				?STAGE_KILLPART_AND_TIMELIMIT->
					Time = mainline_db:get_time_s(StageInfo),
					Condition = 
						lists:map(fun({NpcProtoId,Num,_})-> {NpcProtoId,Num} end,mainline_db:get_killmonsterlist(StageInfo));
				?STAGE_DEFEND_AND_PROTECT_NPC->
					Time = -1,
					Condition = [],
					Duration = mainline_db:get_section_duration(StageInfo),
					MaxSection = mainline_db:get_defend_sections(StageInfo),
					[FirstMonester|_] = MonstersList,
					case get_monster_born_pos(FirstMonester) of
						[]->
							MonsterTargetPos = get_pos_from_roleinfo(get(creature_info));
						MonsterTargetPos->
							nothing
					end,
					mainline_defend_op:init(Chapter,Stage,MyClass,Difficulty,Duration,MaxSection,MonsterTargetPos);
				?STAGE_DEFEND->	
					Time = -1,
					Condition = [],
					Duration = mainline_db:get_section_duration(StageInfo),
					MaxSection = mainline_db:get_defend_sections(StageInfo),
					MonsterTargetPos = get_pos_from_roleinfo(get(creature_info)),
					mainline_defend_op:init(Chapter,Stage,MyClass,Difficulty,Duration,MaxSection,MonsterTargetPos);
				_->
					Time = -1,
					Condition = []
			end,
			put(mainline_state,{Chapter,Stage,Difficulty,?STAGE_STATE_FIGHT,{StageType,Now,Condition}}),
			gm_logger_role:mainline_opt(get(roleid),
										get_level_from_roleinfo(get(creature_info)),
										Chapter,Stage,Difficulty,start, []),
			LeftTimeBinMsg = mainline_packet:encode_mainline_lefttime_s2c(Chapter,Stage,Time),
			role_op:send_data_to_gate(BinMsg)
	end.

%%
%%todo
%%
get_best_recordinfo(Chapter,Stage)->
	get_best_recordinfo(Chapter,Stage,?EASY).

get_best_recordinfo(Chapter,Stage,Difficulty)->
	try
		case game_rank_manager:get_main_line_rank_top_role(Chapter,Stage,Difficulty) of
			{RoleId,RoleName,RoleServerId,Score}->
				mainline_packet:make_stagetop(RoleServerId,RoleId,RoleName,Score);
			OtherRep->
				mainline_packet:make_stagetop([])
		end
	catch
		E:R->
			slogger:msg("~p get_best_recordinfo E:~p R:~p S:~p ~n",[?MODULE,E,R,erlang:get_stacktrace()]),
			mainline_packet:make_stagetop([])
	end.
	
get_monster_born_pos(MonsterId)->
	case npc_db:get_creature_spawns_info_by_id(MonsterId) of
		[]->
			[];
		SpawnsInfo->
			npc_db:get_spawn_bornposition(SpawnsInfo)
	end.

take_designation([])->
  nothing;

take_designation(0)->
  nothing;

take_designation(Designation)->
  designation_op:change_designation(Designation).


kick_all_monster()->
	lists:foreach(fun(UnitId)->		
				npc_op:send_to_creature(UnitId,{forced_leave_map})		
	end,mapop:get_map_units_id()).
		
	
	