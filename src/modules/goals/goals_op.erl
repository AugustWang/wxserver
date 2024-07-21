%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-7-18
%% Description: TODO: Add description to goals_op
-module(goals_op).

%%
%% Include files
%%
-define(MAX_PART_NUM,5).
%%
%% Exported Functions
%%
-export([load_role_goals_from_db/1,export_for_copy/0,save_to_db/0,load_by_copy/1,
		 goals_init/0,goals_update/2,goals_update/3,goals_reward/2,gm_clear_all_goals/0,
		 init_role_goals/0,role_attr_update/0,hook_on_swap_equipment/4]).
-include("error_msg.hrl").
-include("role_struct.hrl").
-include("item_struct.hrl").
-define(STATE_NOTOPEN,0).
-define(STATE_CANAWARD,1).
-define(STATE_RUNNING,2).
-define(STATE_FINISHED,3).
-define(LEVEL_OPEN_GOALS,[1,21,31,41,51,61,71]).
%%
%% API Functions
%%
export_for_copy()->
	{get(role_goals),get(goalslist)}.
	
save_to_db()->
	case get(role_goals) of
		[]->
			nothing;
		Term->
			goals_db:sync_update_goals_role_to_mnesia(Term)
	end.

load_by_copy({RoleGoals,GoalsList})->
	put(role_goals,RoleGoals),
	put(goalslist,GoalsList).

load_role_goals_from_db(RoleId)->
	case goals_db:get_role_goals(RoleId) of
		{ok,[]}->
			case goals_db:get_all_goals() of
				[]->
					put(goalslist,[]),
					put(role_goals,[]);
				AllGoals->
					RGoals = lists:map(fun(Info)->
									  GoalsId = goals_db:get_goals_id(Info),
									  {GoalsId,0,?STATE_RUNNING}
							  end, AllGoals),
					put(role_goals,{RoleId,RGoals}),
					goals_db:sync_update_goals_role_to_mnesia({RoleId,RGoals}),
					put(goalslist,AllGoals)
			end;
		{ok,RoleGoalsDB}->
			[{goals_role,MyRoleId,RGoals}] = RoleGoalsDB,
			put(role_goals,{MyRoleId,RGoals}),
			case goals_db:get_all_goals() of
				[]->
					put(goalslist,[]);
				AllGoals->
					put(goalslist,AllGoals)
			end
	end,
	goals_init().

init_role_goals()->
	RoleInfo = get(creature_info),
      goals_update({level},[0],role_op:get_level_from_roleinfo(RoleInfo)),
%%       goals_update({pet_level},[0],pet_level_op:get_pet_max_level()),
      goals_update({guildposting},[0],guild_util:get_guild_posting()),
      goals_update({venation},[0],venation_op:get_total_active_points()),
      goals_update({venation_advance},[0],venation_op:get_max_venation_advance()).

goals_init()->
	case get(role_goals) of
		[]->
			InitGoals = [];
		RoleGoals->
			{_MyRoleId,RGoals} = RoleGoals,
			RoleLevel = get(level),
			InitGolasFun = fun({{Level,Part},Finished,Status},Acc)->
				if
					RoleLevel >= Level->
						case Status of 
							?STATE_RUNNING->
								if
									Finished =/= 0->
										case lists:keyfind({Level,Part}, 2, get(goalslist)) of
											false->
												Acc;
											GoalsInfo->
												[{_,_,Count}]=goals_db:get_goals_require(GoalsInfo),
												Acc ++ [{Status,Level,Part,Finished,Count}]
										end;
									true->
										Acc ++ [{Status,Level,Part,Finished,0}]
								end;
							_->
								if (Part =:= 0) and (Status =:= ?STATE_CANAWARD) ->
									   Acc ++ [{Status,Level,Part,0,0}];
								   true->
										put(goalslist,lists:keydelete({Level,Part}, 2, get(goalslist))),
										Acc ++ [{Status,Level,Part,0,0}]
								end
						end;
					true->
						case Status of 
							?STATE_RUNNING->
								nothing;
							_->
								put(goalslist,lists:keydelete({Level,Part}, 2, get(goalslist)))
						end,
						Acc ++ [{0,Level,Part,0,0}]
				end
				end,
			InitGoals = lists:foldl(InitGolasFun, [], RGoals)
	end,
	send_goals_init(InitGoals).

send_goals_init(InitGoals)->
	InitGoalsRecord = util:term_to_record_for_list(InitGoals, ach),
	InitMessage = goals_packet:encode_goals_init_s2c(InitGoalsRecord),
	role_op:send_data_to_gate(InitMessage).

send_goals_update(GoalsPart)->
	{_,Level,_,_,_} = GoalsPart,
	RolLevel = get(level),
	if
		RolLevel >= Level->
			GoalsPartRecord = util:term_to_record(GoalsPart,ach),
			UpdateMessage = goals_packet:encode_goals_update_s2c(GoalsPartRecord),
			role_op:send_data_to_gate(UpdateMessage);
		true->
			nothing
	end.

hook_on_swap_equipment(_SrcSlot,DesSlot,SrcInfo,DesInfo)->
	case package_op:where_slot(DesSlot) of
		body->
			Quality = get_qualty_from_iteminfo(SrcInfo),
			Star = get_enchantments_from_iteminfo(SrcInfo),
			Inventory = get_inventorytype_from_iteminfo(SrcInfo),
			Sockets = case get_socketsinfo_from_iteminfo(SrcInfo) of
						[]->
							[0];
						_->
							[0,0]
					  end;							
		_->
			if
				DesInfo =:= []->
					Quality = 0,
					Star = 0,
					Inventory = 0,
					Sockets = [0];
				true->
					Quality = get_qualty_from_iteminfo(DesInfo),
					Star = get_enchantments_from_iteminfo(DesInfo),
					Inventory = get_inventorytype_from_iteminfo(DesInfo),
					Sockets = case get_socketsinfo_from_iteminfo(DesInfo) of
								[]->
									[0];
								_->
									[0,0]
					  		  end
			end	
	end,			
	goals_update({body_equipment},[Quality]),
%% 	goals_update({enchantments},[Star]),
	goals_update({inlay},Sockets),
	goals_update({enchant},[Quality]),
	goals_update({target_equipment},[Inventory]),
	goals_update({target_enchant},[Inventory]),
	role_attr_update().

role_attr_update()->
	{Meleedefense,Rangedefense,Magicdefense} = get_defenses_from_roleinfo(get(creature_info)),
	goals_update({power},[0],get_power_from_roleinfo(get(creature_info))),
	goals_update({hpmax},[0],get_hpmax_from_roleinfo(get(creature_info))),
	goals_update({defense},[0],Meleedefense + Rangedefense + Magicdefense),
	goals_update({fighting_force},[0],get_fighting_force_from_roleinfo(get(creature_info))).

goals_update(Message,Match)->
	goals_update(Message,Match,1).

goals_update(Message,Match,MsgValue)->
	case get(goalslist) of 
		[]->
			nothing;
		GoalsList->
			lists:foreach(fun(GoalsInfo)->
						  {Level,Part} = goals_db:get_goals_id(GoalsInfo),
						  Target = goals_db:get_goals_require(GoalsInfo),
						  Type = goals_db:get_goals_type(GoalsInfo),
						  Script = goals_db:get_goals_script(GoalsInfo),
						  if Part =/= 0 ->
						  	[{Msg,TargetMatch,Count}] = Target,
						  	if 
							  Message =:= {Msg}->
								  MatchLength = case erlang:length(Match) of
													1 ->
														[M] = Match,
														1;
													Len->
														M = 0,
														Len
												end,
								  case Type of 
									  count->
										  MatchResult = lists:member(M, TargetMatch),
										  if TargetMatch=:=[0];MatchResult->
										  		count_function({Level,Part},Match,Count,MsgValue);
											 true->
												 nothing
										  end;
									  match->
										  MatchResult = lists:member(M, TargetMatch),
										  if 
											  MatchResult->
												  match_function({Level,Part},Match,Target,Count,MsgValue,Script);
											  MatchLength>1->
												  match_function({Level,Part},Match,Target,Count,MsgValue,Script);
											  true->
												 nothing
										  end;
									  matchnum->
										  if TargetMatch=:=[0];TargetMatch=:=Match->
										  		matchnum_function({Level,Part},Match,Count,MsgValue);
											 true->
												nothing
										  end;
									  _->
										  nothing
								  end;
							  true->
								  nothing
						  	end;
						  	true->
								nothing
						  end
						  end,GoalsList)
	end.

get_goalslist_by_level(Level)->
	case get(goalslist) of
		[]->
			[];
		GoalsList->
			lists:filter(fun(GoalsInfo)->
								 TempLevel = goals_db:get_goals_level(GoalsInfo),
								 TempLevel=:=Level
						 end, GoalsList)
	end.

check_days_finished(Level)->
	case get(goalslist) of
		[]->
			nothing;
		GoalsList->
			DaysPartList = get_goalslist_by_level(Level),
			if erlang:length(DaysPartList) =:= 1->
				case get(role_goals) of
					[]->
						nothing;
					RoleGoals->
						{MyRoleId,RGoals} = RoleGoals,
						case lists:keyfind({Level,0}, 2, GoalsList) of
							false->
								Target = [];
							Info->
								Target = goals_db:get_goals_require(Info)
						end,
						CheckDaysPartFun = fun({GoalsId,_Target,Status},Acc)->
							{TempLevel,_} = GoalsId,
							if
								TempLevel=:=Level,Status=:=?STATE_FINISHED-> 
									Acc ++ [GoalsId];
								true->
									Acc
							end
						 end,
						FinishGoals = lists:foldl(CheckDaysPartFun, [], RGoals),
						SortedFinished = lists:sort(FinishGoals),
						if SortedFinished =:= Target->
							GoalsRoleUpdate={MyRoleId,lists:keyreplace({Level,0}, 1, RGoals, {{Level,0},0,?STATE_FINISHED})},
							goals_db:sync_update_goals_role_to_mnesia(GoalsRoleUpdate),
							put(role_goals,GoalsRoleUpdate),
							put(goalslist,lists:keydelete({Level,0}, 2, get(goalslist))),
							send_goals_update({?STATE_FINISHED,Level,0,0,0});
						   true->
							   nothing
						end
				end;
			   true->
				   nothing
   			end
	end.

goals_reward(Level,Part)->
	case get(role_goals) of
		[]->
			Errno=?ERRNO_NPC_EXCEPTION;
		{MyRoleId,RGoals}->
			case lists:keyfind({Level,Part}, 1, RGoals) of
				false->
					Errno=?ERROR_ACHIEVE_TARGET_NOEXSIT;
				{_,Finished,Status}->
					if 
						Status=:=?STATE_CANAWARD->
							case goals_db:get_goals_info({Level,Part}) of
								[]->
									Errno=?ERRNO_NPC_EXCEPTION;
								GoalsInfo->
									Bonus = goals_db:get_goals_bonus(GoalsInfo),
									Errno=[],
									Items = lists:filter(fun({Class,Count})->
								 								Class > 3
															end, Bonus),
									case package_op:can_added_to_package_template_list(Items) of
										false->
											Message = achieve_packet:encode_achieve_error_s2c(?ERROR_PACKEGE_FULL),
											role_op:send_data_to_gate(Message);
										_->
											achieve_op:achieve_bonus(Bonus,goals_bonus),
											gm_logger_role:goals_reward(get(roleid),get(level),Level,Part,Bonus),
											if 
												Errno =:= []->
													GoalsRoleUpdate={MyRoleId,lists:keyreplace({Level,Part}, 1, RGoals, {{Level,Part},Finished,?STATE_FINISHED})},
													goals_db:sync_update_goals_role_to_mnesia(GoalsRoleUpdate),
													put(role_goals,GoalsRoleUpdate),
													{_,RoleGoals} = get(role_goals),
													HasCanAward = lists:map(fun(PartNum)->
																		  		case lists:keyfind({Level,PartNum},1,RoleGoals) of
																			  		false->
																				  		false;
																	  				{_,_,State}->
																		  				if State =:= ?STATE_CANAWARD ->
																						 		true;
																					 		true->
																								false
																				  		end
																		  		end
																			end,lists:seq(1,?MAX_PART_NUM)),
													case lists:member(true,HasCanAward) of
														true->
															send_goals_update({?STATE_FINISHED,Level,Part,0,0});
														_->
															GoalsUpdate = {MyRoleId,lists:keyreplace({Level,0},1,RoleGoals,{{Level,0},0,?STATE_RUNNING})},
															goals_db:sync_update_goals_role_to_mnesia(GoalsUpdate),
															put(role_goals,GoalsUpdate),
															send_goals_update({?STATE_RUNNING,Level,0,0,0}),
															send_goals_update({?STATE_FINISHED,Level,Part,0,0})
													end,
													if 
														Part > 0->
															check_days_finished(Level);
										   				true->
															nothing
													end;
												true->
										   			nothing
											end
									end
							end;
						true->
							Errno=?ERROR_ACHIEVE_TARGET_NOT_FINISHED
					end
			end
	end,
	if 
		Errno =/= []->
			Message_failed = achieve_packet:encode_achieve_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.
%%
%% Local Functions
%%
check_part_is_finished(GoalsId,Target,Script)->
	case Script of
		[]->
			{other};
		Value->
			exec_beam(Value,todo,GoalsId,Target)
	end.

count_function(GoalsId,_Match,Count,MsgValue)->
	case get(role_goals) of
		[]->
			nothing;
		RoleGoals->
			{MyRoleId,RGoals} = RoleGoals,
			case lists:keyfind(GoalsId, 1, RGoals) of
				false->
					nothing;
				Target->
					{Level,Part} = GoalsId,
					{_,Finished,Status} = Target,
					if 
						Status=:=?STATE_RUNNING,Finished+MsgValue>=Count->
							gm_logger_role:goals_can_reward(get(roleid),get(level),Level,Part),
							NRoleGoles = lists:keyreplace(GoalsId, 1, RGoals, {GoalsId,0,?STATE_CANAWARD}),
							NewRoleGoles = lists:keyreplace({Level,0}, 1, NRoleGoles, {{Level,0},0,?STATE_CANAWARD}),
							GoalsRoleUpdate={MyRoleId,NewRoleGoles},
							goals_db:sync_update_goals_role_to_mnesia(GoalsRoleUpdate),
							put(role_goals,GoalsRoleUpdate),
							put(goalslist,lists:keydelete(GoalsId, 2, get(goalslist))),
							send_goals_update({?STATE_CANAWARD,Level,0,0,0}),
							send_goals_update({?STATE_CANAWARD,Level,Part,0,0});
						true->
							GoalsRoleUpdate={MyRoleId,lists:keyreplace(GoalsId, 1, RGoals, {GoalsId,Finished+MsgValue,?STATE_RUNNING})},
							put(role_goals,GoalsRoleUpdate)
					end
			end
	end.

match_function(GoalsId,_Match,TargetMatch,Count,_MsgValue,Script)->
	case get(role_goals) of
		[]->
			nothing;
		RoleGoals->
			{MyRoleId,RGoals} = RoleGoals,
			case lists:keyfind(GoalsId, 1, RGoals) of
				false->
					nothing;
				Target->
					{Level,Part} = GoalsId,
					{_,Finished,Status} = Target,
					if 
						Status=:=?STATE_RUNNING->
							case check_part_is_finished(GoalsId,TargetMatch,Script) of
								{true,MatchResult}->
									gm_logger_role:goals_can_reward(get(roleid),get(level),Level,Part),
									NRoleGoles = lists:keyreplace(GoalsId, 1, RGoals, {GoalsId,0,?STATE_CANAWARD}),
									NewRoleGoles = lists:keyreplace({Level,0}, 1, NRoleGoles, {{Level,0},0,?STATE_CANAWARD}),
									GoalsRoleUpdate={MyRoleId,NewRoleGoles},
									goals_db:sync_update_goals_role_to_mnesia(GoalsRoleUpdate),
									put(role_goals,GoalsRoleUpdate),
									put(goalslist,lists:keydelete(GoalsId, 2, get(goalslist))),
									send_goals_update({?STATE_CANAWARD,Level,0,0,0}),
									send_goals_update({?STATE_CANAWARD,Level,Part,0,0});
								{false,MatchResult}->
									if 
										MatchResult>Finished->
											GoalsRoleUpdate={MyRoleId,lists:keyreplace(GoalsId, 1, RGoals, {GoalsId,MatchResult,?STATE_RUNNING})},
											put(role_goals,GoalsRoleUpdate);
										true->
											nothing
									end;
								_->
									nothing
							end;
						true->
							nothing
					end
			end
	end.

matchnum_function(GoalsId,_Match,Count,MsgValue)->
	case get(role_goals) of
		[]->
			nothing;
		RoleGoals->
			{MyRoleId,RGoals} = RoleGoals,
			case lists:keyfind(GoalsId, 1, RGoals) of
				false->
					nothing;
				Target->
					{Level,Part} = GoalsId,
					{_,_,Status} = Target,
					if 
						Status=:=?STATE_RUNNING,MsgValue>=Count->
							gm_logger_role:goals_can_reward(get(roleid),get(level),Level,Part),
							NRoleGoles = lists:keyreplace(GoalsId, 1, RGoals, {GoalsId,0,?STATE_CANAWARD}),
							NewRoleGoles = lists:keyreplace({Level,0}, 1, NRoleGoles, {{Level,0},0,?STATE_CANAWARD}),
							GoalsRoleUpdate={MyRoleId,NewRoleGoles},
							goals_db:sync_update_goals_role_to_mnesia(GoalsRoleUpdate),
							put(role_goals,GoalsRoleUpdate),
							put(goalslist,lists:keydelete(GoalsId, 2, get(goalslist))),
							send_goals_update({?STATE_CANAWARD,Level,0,0,0}),
							send_goals_update({?STATE_CANAWARD,Level,Part,0,0});
						true->
							nothing
					end
			end
	end.

exec_beam(Mod,Fun,GoalsId,Target)->
	try 
		Mod:Fun(GoalsId,Target) 
	catch
		Errno:Reason -> 	
			slogger:msg("exec_beam error Script : ~p fun:~p GoalsId: ~p Target: ~p ~p:~p ~n",[Mod,Fun,GoalsId,Target,Errno,Reason]),
			false
	end.

gm_clear_all_goals()->
	case get(role_goals) of
		[]->
			nothing;
		{MyRoleId,RoleGoals}->
			NRGoals = lists:map(fun({{Level,Part},_,_})->
								  {{Level,Part},0,?STATE_RUNNING}
								end,RoleGoals),
			GoalsRoleUpdate = {MyRoleId,NRGoals},
			put(role_goals,GoalsRoleUpdate),
			goals_db:sync_update_goals_role_to_mnesia(GoalsRoleUpdate)
	end.

		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
