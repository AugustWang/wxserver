%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-11-1
%% Description: TODO: Add description to guildbattle_op
-module(guildbattle_op).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("common_define.hrl").
-include("guildbattle_define.hrl").
-include("instance_define.hrl").
-include("game_map_define.hrl").
-include("map_info_struct.hrl").
-include("pvp_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").

-define(BATTLE_IDLE,0).			%%entry
-define(BATTLE_ENTRY,1).		%%entry
-define(BATTLE_READY,2).		%%ready
-define(BATTLE_FIGHT,3).		%%fight

-record(guildbattlestate,{mystate,mapproc,battlestate,bornposindex,starttime}).

%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%

init()->
	put(guildbattle_skillinfo,[]),
	put(myguildbattlestate,make_state()),
	case guild_util:get_guild_id() of
		{0,0}->
			nothing;
		GuildId->
			case check_battle_time() of
				true->
					guildbattle_manager:role_online(get(roleid),GuildId);
				_->
					nothing
			end
	end,
	ApplyLeftTime = check_battle_apply_time(),
	case ApplyLeftTime > 0 of
		true->
			StartApplyMsg = guildbattle_packet:encode_guild_battle_start_apply_s2c(ApplyLeftTime),
			role_op:send_data_to_gate(StartApplyMsg);
		_->
			nothing
	end.

export_for_copy()->
	{get(guildbattle_skillinfo),get(myguildbattlestate)}.

load_by_copy({SkillInfo,BattleState})->
	put(guildbattle_skillinfo,SkillInfo),
	put(myguildbattlestate,BattleState).

%%
%%return true|false
%%
is_in_battle()->
	case get_mystate() of
		?BATTLE_READY->
			true;
		?BATTLE_FIGHT->
			true;
		_->
			false
	end.

is_in_fight()->
	get_mystate() =:= ?BATTLE_FIGHT.

%%
%%return true|false|same_guild|nothing
%%
check_pvp(MyId,TargetId)->
	case get_mystate() of
		?BATTLE_READY->
			ErrMsg = guildbattle_packet:encode_guild_battle_opt_s2c(?ERRNO_GUILD_BATTLE_READY_CANNOT_ATTACK),
			role_op:send_data_to_gate(ErrMsg),
			false;
		?BATTLE_FIGHT->
			case guild_util:is_same_guild(TargetId) of
				true->
					same_guild;
				_->
					true
			end;
		_->
			nothing
	end.

%%
%%
%%
is_crime()->
	case get_mystate() of
		?BATTLE_FIGHT->
			false;
		_->
			true
	end.

get_map_proc_name()->
	erlang:element(#guildbattlestate.mapproc,get(myguildbattlestate)).
		

process_client_message(#entry_guild_battle_c2s{})->
	case get_mystate() of
		?BATTLE_READY->
			nothing;
		?BATTLE_FIGHT->
			nothing;
		_->
			%%check self state  
			case transport_op:can_directly_telesport() of
				true->
					%% check battle time
					CheckTime  = check_battle_time(),
					CheckLevel = (?GUIDBATTLE_MIN_LEVEL =< get_level_from_roleinfo(get(creature_info))),
					GuildId = guild_util:get_guild_id(),
					CheckFightforce = get_fighting_force_from_roleinfo(get(creature_info)) >= get_guild_battle_limit(GuildId),
					if
						not CheckLevel->
							MsgBin = guildbattle_packet:encode_entry_guild_battle_s2c(?ERROR_LESS_LEVEL,0),
							role_op:send_data_to_gate(MsgBin);
						not CheckFightforce->
							MsgBin = guildbattle_packet:encode_entry_guild_battle_s2c(?ERROR_LESS_FIGHTFORCE,0),
							role_op:send_data_to_gate(MsgBin);
						CheckTime ->
							%% req battle state 
							case guildbattle_manager:get_battle_info() of
								[]->
									%%io:format("guildbattle_manager:get_battle_info [] ~n"),
									nothing;
								BattleInfo->
									{BattleState,BattleProc,GuildList} = BattleInfo,
									if
										BattleState =/= ?GUILDBATTLE_READY,BattleState =/=?GUILDBATTLE_FAIGHT->
											nothing;
										true->
											{Node,MapProc,BattleStartTime} = BattleProc,
											case lists:keyfind(guild_util:get_guild_id(),1,GuildList) of
												false->
													%%io:format("GuildList error ~n"),
													nothing;
												{_,BornPosIndex}->
													%% req join battle
													case instance_pos_db:get_instance_pos_from_mnesia(erlang:atom_to_list(MapProc)) of			
														[]->
															%%io:format("instance_pos_db error ~n"),
															nothing;
														{_Id,_Creation,StartTime,CanJoin,InstanceNode ,_Pid,MapId,ProtoId,Members}->
															if
																CanJoin->
																	ProtoInfo = instance_proto_db:get_info(ProtoId),
																	put(myguildbattlestate,make_state(?BATTLE_ENTRY,MapProc,BattleState,BornPosIndex,BattleStartTime)),
																	MyBornPos = get_my_bornpos(BornPosIndex),
																	instance_op:trans_to_dungeon(false,MapProc,get(map_info),MyBornPos,?INSTANCE_TYPE_GUILDBATTLE,ProtoInfo,InstanceNode,MapId);
																true->
																	%%io:format("CanJoin error ~n"),
																	nothing
															end
													end
											end
									end
							end;
						true->
							%%io:format("CanJoin errorq11111 ~n"),
							nothing
					end;
				_->
					%%io:format("CanJoin errorq2222 ~n"),
					nothing
			end
	end;

process_client_message(#leave_guild_battle_c2s{})->
	leave_battle();

process_client_message(#apply_guild_battle_c2s{})->
	apply_battle();

process_client_message(UnKnownMsg)->
	nothing.

process_proc_message(change_my_guildbattle_state)->
	case get_mystate() of
		?BATTLE_READY->
			set_mystate(?BATTLE_FIGHT);
		_->
			nothing
	end;

%%process_proc_message(guildbattle_reward)->
%%	role_op:add_buffers_by_self(?GUILDBATTLE_REWARD_BUFF);
	
process_proc_message(UnKnownMsg)->
	todo.

hook_offline()->
	leave_battle().
			
hook_on_kill(OtherId)->
	case get_mystate() of
		?BATTLE_FIGHT->
			case guild_util:is_same_guild(OtherId) of
				true->
					nothing;
				_->
					slogger:msg("~p guildbattle killed ~p ~n",[get(roleid),OtherId]),
					guildbattle_manager:kill_other(get(roleid),guild_util:get_guild_id(),OtherId)
			end;
		_->
			nothing
	end.

hook_map_complete()->
	case get_mystate() of
		?BATTLE_IDLE->
			nothing;
		?BATTLE_ENTRY->
			case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
				?MAP_TAG_GUILDBATTLE->
					pvp_op:set_pkmodel(?PVP_MODEL_GUILD),
					guildbattle_manager:role_join(get(roleid),guild_util:get_guild_id()),		%% reg to manager
					case get_battlestate() of
						?GUILDBATTLE_FAIGHT->
							set_mystate(?BATTLE_FIGHT);
						_->
							change_my_state(),
							set_mystate(?BATTLE_READY)
					end,
					%%entry success
					StartTime = get_starttime(),	
					TimeLeft_s = max(?GUILDBATTLE_DURATION_TIME_S - trunc(timer:now_diff(now(),StartTime)/1000000),0),		
					MsgBin = guildbattle_packet:encode_entry_guild_battle_s2c(?SUCCESS,TimeLeft_s),
					role_op:send_data_to_gate(MsgBin);
				_->
					nothing
			end;
		_->
			case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
				?MAP_TAG_GUILDBATTLE->
					nothing;
				_->
					guildbattle_manager:role_leave(get(roleid),guild_util:get_guild_id()),
					country_op:reinit(),
					init(),
					Leavemsg = guildbattle_packet:encode_leave_guild_battle_s2c(?SUCCESS),
					role_op:send_data_to_gate(Leavemsg)
			end
	end.

hook_on_dead()->
	nothing.

hook_cancel_sing()->
	case get(guildbattle_skillinfo) of	
		[]->
			nothing;
		{SkillInfo,TargetInfo}->
			NpcPid = creature_op:get_pid_from_creature_info(TargetInfo),
			gs_rpc:cast(NpcPid,{guildbattle_cancel_attack, {get(roleid)}}),
			put(guildbattle_skillinfo,[]);
		_->
			nothing
	end.

apply_battle()->
	case (check_battle_apply_time() > 0) of
		true->
			case guild_util:get_guild_id() of
				{0,0}->
					Errno = ?GUILD_ERRNO_NOT_IN_GUILD;
				GuildId->
					Errno = guildbattle_manager:apply_battle(get(roleid),GuildId)
			end;
		_->
			Errno = ?ERRNO_GUILDBATTLEAPPLY_TIME_ERROR
	end,
	RetMsg = guildbattle_packet:encode_guild_battle_opt_s2c(Errno),
	role_op:send_data_to_gate(RetMsg).

rename(NewName)->
	guildbattle_manager:change_role_name(get(roleid),NewName),
	[].
			
%%
%% Local Functions
%%
check_battle_time()->
	Now = timer_center:get_correct_now(),
	LocalTime = calendar:now_to_local_time(Now),
	{Today,NowTime} = LocalTime, 
	Week = calendar:day_of_the_week(Today),
	case guildbattle_db:get_info(Week) of
		[]->
			false;
		Info->
			BattleStartTime = guildbattle_db:get_starttime(Info),
			BattleStartTime_S = calendar:time_to_seconds(BattleStartTime),
			NowTime_S = calendar:time_to_seconds(NowTime),
			case timer_util:compare_time(NowTime,BattleStartTime) of
				true->		%% BattleStartTime > NowTime
					false;
				_->
					case ((BattleStartTime_S + ?GUILDBATTLE_DURATION_TIME_S) > NowTime_S) of
						true->
							true;
						_->
							false
					end
			end
	end.

%%
%%return lefttime > 0  | lefttime =< 0 
%%
check_battle_apply_time()->
	Now = timer_center:get_correct_now(),
	LocalTime = calendar:now_to_local_time(Now),
	{Today,NowTime} = LocalTime, 
	Week = calendar:day_of_the_week(Today),
	case guildbattle_db:get_info(Week) of
		[]->
			0;
		Info->
			ApplyStartTime = guildbattle_db:get_startapplytime(Info),
			ApplyStopTime = guildbattle_db:get_stopapplytime(Info),
			case timer_util:compare_time(NowTime,ApplyStartTime) of
				true->		%% BattleStartTime > NowTime
					0;
				_->
					case timer_util:compare_time(ApplyStopTime,NowTime) of
						true->
							0;
						_->
							calendar:time_to_seconds(ApplyStopTime) - calendar:time_to_seconds(NowTime)
					end
			end
	end.

make_state()->
	#guildbattlestate{
					  mystate = ?BATTLE_IDLE,
					  mapproc = [],
					  battlestate = ?GUILDBATTLE_IDLE,
					  bornposindex = 0}.

make_state(MyState,MapProc,BattleState,BornPosIndex,StartTime)->
	#guildbattlestate{
					  mystate = MyState,
					  mapproc = MapProc,
					  battlestate = BattleState,
					  bornposindex = BornPosIndex,
					  starttime = StartTime}.
		
get_mystate()->
	erlang:element(#guildbattlestate.mystate,get(myguildbattlestate)).

get_battlestate()->
	erlang:element(#guildbattlestate.battlestate,get(myguildbattlestate)).

set_mystate(MyState)->
	put(myguildbattlestate,setelement(#guildbattlestate.mystate,get(myguildbattlestate),MyState)).

set_battlestate(BattleState)->
	put(myguildbattlestate,setelement(#guildbattlestate.battlestate,get(myguildbattlestate),BattleState)).

change_my_state()->
	erlang:send_after(?GUILDBATTLE_PROTECT_TIME_S*1000,self(),{guildbattle_proc_msg,change_my_guildbattle_state}).

get_my_bornpos()->
	BornPosIndex =  erlang:element(#guildbattlestate.bornposindex,get(myguildbattlestate)),
	get_my_bornpos(BornPosIndex).

get_my_bornpos(Index)->
	PosList = lists:nth(Index,?GUILDBATTLE_BORNPOS),
	{{X1,Y1},{X2,Y2}} = PosList,
	PosX = (X1-1) + random:uniform((X2+1)-X1),
	PosY = (Y1-1) + random:uniform((Y2+1)-Y1),
	%%?GUILDBATTLE_BORNPOS
	{PosX,PosY}.


get_starttime()->
	erlang:element(#guildbattlestate.starttime,get(myguildbattlestate)).

leave_battle()->
	case is_in_battle() of
		true->
			case get_map_proc_name() of
				[]->
					nothing;
				MapProc->
					hook_cancel_sing(),
					guildbattle_manager:role_leave(get(roleid),guild_util:get_guild_id()),
					init(),
					Leavemsg = guildbattle_packet:encode_leave_guild_battle_s2c(?SUCCESS),
					role_op:send_data_to_gate(Leavemsg),
					instance_op:kick_instance_by_reason({?INSTANCE_TYPE_GUILDBATTLE,MapProc})
			end;
		_->
			nothing
	end.
	
get_guild_battle_limit(GuildId)->
	case guild_spawn_db:get_guild_right_limit(GuildId) of
		{_,_,_,Battle}->
			Battle;
		_->
			0
	end.