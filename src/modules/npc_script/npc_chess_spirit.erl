%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_chess_spirit).

%%
%% Exported Functions
%%
-export([proc_special_msg/1,init/0,is_start_section/1,on_dead/0]).
-include("npc_define.hrl").
-include("npc_struct.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("login_pb.hrl").
-include("system_chat_define.hrl").
-include("ai_define.hrl").
-include("chess_spirit_define.hrl").
-include("error_msg.hrl").
-include("game_rank_define.hrl").



-define(CHECK_TIME_INTERVAL,2000).
%%
%% API Functions
%%
%% chess_spirit_share_skills:[skillid]
%% chess_spirit_random_skills:[skillid]
%% npc_chess_spirit_player_info [{Roleid,SelfRanSkills,Power}]
%% npc_chess_spirit_monster_info [{Section,[MonsterId]}]
%% npc_chess_spirit_complete_section [Section] -> sort list

init()->
	case chess_spirit_db:get_chess_spirit_config_info(get(id)) of
		[]->
			slogger:msg("npc_chess_spirit init error ~p ~n",[get(id)]);
		ConfigInfo->
			%%============config begin==========%%
			put(chess_spirit_max_section,chess_spirit_db:get_config_max_section(ConfigInfo)),
			put(chess_spirit_section_duration,chess_spirit_db:get_config_section_duration(ConfigInfo)),
			put(chess_spirit_type,chess_spirit_db:get_config_type(ConfigInfo)),
			{FixList,FixNum} = chess_spirit_db:get_config_fixed_skills(ConfigInfo),
			{RanList,RanNum} = chess_spirit_db:get_config_random_skills(ConfigInfo),
			ChessSkills= chess_spirit_db:get_config_chess_skills(ConfigInfo),
			{RoleMaxPower,ChessMaxPower} = chess_spirit_db:get_config_chess_max_power(ConfigInfo),
			ChessPowerAddation = chess_spirit_db:get_config_chess_power_addation(ConfigInfo),
			FunFilter = 
			fun(SkillId)->
				case lists:keymember(SkillId, 1, get_skilllist_from_npcinfo(get(creature_info))) of
					false->
						slogger:msg("SkillId not in creature_proto skill list !! NpcId ~p  SkillId ~p ~n",[get(id),SkillId]),
						false;
					_->
						true
				end 
			end,
			FilterFixList = lists:filter(FunFilter, FixList),
			FilterRanList = lists:filter(FunFilter, RanList),
			FixSkillList = ran_obt_by_num(FilterFixList,[],FixNum),
			RanSkillList = ran_obt_by_num(FilterRanList,[],RanNum),
			put(chess_spirit_share_skills,FixSkillList),
			put(chess_spirit_random_skills,RanSkillList),
			put(chess_spirit_chess_skills,ChessSkills),
			put(chess_spirit_chess_max_power,ChessMaxPower),
			put(chess_spirit_role_max_power,RoleMaxPower),					%%not use,to_do
			put(chess_spirit_power_addation,ChessPowerAddation),
			%%============config end============%%
			InitTime = now(),
			put(npc_chess_spirit_game_over,false),
			put(npc_chess_spirit_start_time,{0,0,0}),
			put(npc_chess_spirit_cur_section,0),
			put(npc_chess_spirit_last_spawn_time,InitTime),
			put(npc_chess_spirit_monster_info,[]),
			put(npc_chess_spirit_complete_section,[]),
			put(npc_chess_spirit_player_info,[]),
			put(npc_chess_spirit_cur_power,0),
			put(npc_chess_spirit_last_add_power,InitTime),
			put(npc_chess_spirit_npcids,[get(id)]),
			send_check()
	end.

proc_special_msg(npc_chess_spirit_check)->
	do_game_check();

proc_special_msg({chess_spirit_role_leave,RoleId})->
	proc_role_leave(RoleId);

proc_special_msg({role_cast_skill_self,RoleId,SkillId})->
	proc_role_cast_skill(RoleId,SkillId);

proc_special_msg({role_cast_skill_chess,RoleId})->
	proc_cast_chess_skill(RoleId);

proc_special_msg({role_up_share_skill,RoleId,SkillId})->
	proc_role_up_share_skill(RoleId,SkillId);

proc_special_msg({chess_spirit_call_one_skill,{NpcId,BuffId,BuffLevel}})->
	put(npc_chess_spirit_npcids,[NpcId|get(npc_chess_spirit_npcids)]),
	case creature_op:get_creature_info(NpcId) of
		undefined->
			slogger:msg("{chess_spirit_call_one_skill ERROR,{NpcId,SkillId,SkillLevel}} ~p npc not exsit ~n",[{NpcId,BuffId,BuffLevel}]);
		CreatureInfo->
			Pid = get_pid_from_npcinfo(CreatureInfo),
			gs_rpc:cast(Pid, {chess_helper_give_buff,{BuffId,BuffLevel}})
	end;
   
proc_special_msg(_)->
  	nothing.

on_dead()->
	game_over(?CHESS_SPIRIT_RESULT_FAILED).	

game_over(Result)->
	MyId = get(id),
	put(npc_chess_spirit_game_over,true),
	CurSection = get_cur_top_section(),
	UsedTime_S = 
	case get(npc_chess_spirit_start_time) of
		{0,0,0}->
			0;
		StartTime->
			trunc(timer:now_diff(now(),StartTime)/1000000)
	end,
	broad_msg_to_whole_map({npc_chess_spirit,{result,get(chess_spirit_type),CurSection,UsedTime_S,Result}}),
	lists:foreach(fun(UnitId)->
		if
			UnitId =/= MyId->
				npc_op:send_to_creature(UnitId,{forced_leave_map});
			true->
				nothing				
		end		
	end,mapop:get_map_units_id()),
	case mapop:get_map_roles_id() of
		[]->
			nothing;
		AllRoleIds->
			case get(chess_spirit_type) of
				?CHESS_SPIRIT_TYPE_SINGLE->
					[RoleId|_] = AllRoleIds,
					role_pos_util:send_to_role(RoleId,{open_service_activities,{chess_spirit,CurSection}}),
					game_rank_manager:challenge(RoleId, ?RANK_TYPE_CHESS_SPIRITS_SINGLE,{CurSection,UsedTime_S});
				?CHESS_SPIRIT_TYPE_TEAM->
					RoleNames = lists:foldl(fun(RoleIdTmp,AccRoleNames)->
									case creature_op:get_creature_info(RoleIdTmp) of
										undefined->
											AccRoleNames;
										RoleInfo->
											role_pos_util:send_to_role(RoleIdTmp,{goals,{chess_spirit_team,CurSection}}),
											RoleNameTmp = get_name_from_roleinfo(RoleInfo),
											[RoleNameTmp|AccRoleNames]
									end 
								end,[], AllRoleIds),
					case RoleNames of
						[]->
							nothing;
					 	_->
							game_rank_manager:challenge({RoleNames,timer_center:get_correct_now()}, ?RANK_TYPE_CHESS_SPIRITS_TEAM,{CurSection,UsedTime_S})
					end
			end
	end,
	normal_ai:stop_instance(?GAME_OVER_KICK_TIME).

%%npc ai
is_start_section(Section)->
	 (get(npc_chess_spirit_cur_section)=:=Section).

%%local
send_check()->
	erlang:send_after(?CHECK_TIME_INTERVAL,self(),npc_chess_spirit_check).

do_game_check()->
	RoleIds =  mapop:get_map_roles_id(),
	update_players_info(RoleIds),
	case get(npc_chess_spirit_game_over) of
		false->
			update_monster_info(),
			update_chess_power(),
			case get(npc_chess_spirit_cur_section) of
				0->		%%not start
					do_prepare(),
					send_check();
				NowSection->
					case NowSection>=get(chess_spirit_max_section) of 
						true->
							%%max section
							case is_all_monster_enemy_dead() of
								true->		%%foolish GD!!!
									finish_all_game();
								_->
									send_check()		
							end;		
						false->
							%%has start
							case is_all_monster_enemy_dead() of
								true->		%%all dead
									spawns_monster_for_section(NowSection+1);
								false->		%%not all dead
									case is_spawns_time_arrive() of
										true->
											spawns_monster_for_section(NowSection+1);
										_->
											nothing
									end
							end,
							update_section_info_to_all(),
							send_check()
					end
			end;
		true->		%%game_over
			nothing
	end.		

is_spawns_time_arrive()->
	timer:now_diff(now(), get(npc_chess_spirit_last_spawn_time)) >= get(chess_spirit_section_duration)*1000.

is_all_monster_enemy_dead()->
	ALLUnitsId = mapop:get_map_units_id() -- get(npc_chess_spirit_npcids),
	lists:foldl(fun(UnitId,Re)->
		if
			not Re->	
				Re;
			true->	
				case creature_op:get_creature_info(UnitId) of
					undefined->
							Re;
					CreatureInfo->
						(creature_op:is_creature_dead(CreatureInfo))
						or (not (creature_op:what_realation(get(creature_info),CreatureInfo)=:= enemy))
				end
	end	end,true,ALLUnitsId).

do_prepare()->
	case get(npc_chess_spirit_start_time) of
		{0,0,0}->
			%%prepare time
			prepare_brd(trunc(?START_PREPARE_TIME/1000)),
			npc_ai:handle_event(?EVENT_CHESS_SPIRIT_GAME_START),
			put(npc_chess_spirit_start_time,now());
		PreStartTime->
			LeftTime = (?START_PREPARE_TIME*1000 - timer:now_diff(now(), PreStartTime)),
			case LeftTime =< 0 of
				true->
					spawns_monster_for_section(1),
					set_chess_skill_cool(),
					put(npc_chess_spirit_start_time,now());
				_-> %%prepare time
					prepare_brd(trunc(LeftTime/1000000)+1)
			end
	end.

%%proc role leave and join
update_players_info(NewRoleIds)->
	lists:foreach(fun({RoleId,RandomSkills,_})-> 
		case lists:member(RoleId, NewRoleIds) of
			false->		%%some one leave
				proc_role_leave(RoleId,RandomSkills);		  
			_->
				nothing
		end end,get(npc_chess_spirit_player_info)),
	lists:foreach(fun(RoleId)->
		  case lists:keymember(RoleId,1, get(npc_chess_spirit_player_info) ) of
			false->
				proc_role_join(RoleId);	
			_->
				nothing
		end
	end,NewRoleIds).

proc_role_leave(RoleId)->
	case lists:keyfind(RoleId,1,get(npc_chess_spirit_player_info) ) of
		{RoleId,RandomSkills,_}->
			proc_role_leave(RoleId,RandomSkills);
		_->
			nothing
	end.

proc_role_leave(RoleId,RandomSkills)->
	put(npc_chess_spirit_player_info,lists:keydelete(RoleId,1, get(npc_chess_spirit_player_info))),
	put(chess_spirit_random_skills,get(chess_spirit_random_skills)++RandomSkills).

proc_role_join(RoleId)->
	case get(chess_spirit_random_skills) of
		[]->
			slogger:msg("distibut_skill_to_role(RoleId) error no skill NpcId ~p Assign: ~p ~n",[get(id),get(npc_chess_spirit_player_info)]);
		LeftSkillsList->
			RandomV = random:uniform(erlang:length(LeftSkillsList)),
			%%support for more skills
			RanSkill = lists:nth(RandomV, LeftSkillsList),
			RoleSelfSkills = [RanSkill], 
			MyPid = get_pid_from_npcinfo(get(creature_info)),
			role_pos_util:send_to_role(RoleId,{npc_chess_spirit,{init,get(chess_spirit_type),get(id),MyPid,RoleSelfSkills}}),
			put(npc_chess_spirit_player_info,[{RoleId,RoleSelfSkills,0}|get(npc_chess_spirit_player_info)]),
			put(chess_spirit_random_skills,get(chess_spirit_random_skills)--RoleSelfSkills),
			send_to_role_init_info(RoleId)
	end.

proc_allplayer_power_add(GivePower)->
	put(npc_chess_spirit_player_info,
		lists:map(fun({RoleId,RoleSelfSkills,OldPower})->
			send_role_update_power(RoleId,OldPower + GivePower),
			{RoleId,RoleSelfSkills,OldPower + GivePower}
		end, get(npc_chess_spirit_player_info))).
	

%%proc if has section complete
update_monster_info()->
	NewDestroySections = 
	lists:foldl(fun({SectionTmp,MonsterIds},Sections)->
		LiveMosters = lists:filter(fun(MoinsterId)->
						not creature_op:is_creature_dead(creature_op:get_creature_info(MoinsterId))
			end,MonsterIds),
		if
			LiveMosters=:=[]->		%%all clear
				put(npc_chess_spirit_monster_info,lists:keydelete(SectionTmp,1,get(npc_chess_spirit_monster_info))), 
				Sections++[SectionTmp];
			true->					%%not crear section
				Sections
		end				
	end,[],get(npc_chess_spirit_monster_info)),
	if
		NewDestroySections=:=[]->
			nothing;
		true->
			lists:foreach(fun(NewDesSec)->
					proc_section_complete(NewDesSec)				  
				end, NewDestroySections)
	end.

proc_section_complete(NewDesSec)->
	NewCompleteSecs = lists:sort([NewDesSec|get(npc_chess_spirit_complete_section)]),
	put(npc_chess_spirit_complete_section,NewCompleteSecs),
	SectionInfo = chess_spirit_db:get_chess_spirit_section_info(get(chess_spirit_type),NewDesSec),
	AllPower = chess_spirit_db:get_section_soulpower(SectionInfo),
	proc_allplayer_power_add(AllPower),
	CurTopSec = get_cur_top_section(),
	case (NewDesSec =<  CurTopSec )and (CurTopSec=:= erlang:length(get(npc_chess_spirit_complete_section))) of
		true->			%%connected or reached a new top
			broad_cast_to_world(section,CurTopSec);
		_->
			nothing
	end.

get_cur_top_section()->
	lists:foldl(fun(SecTmp,TopSec)->
		if 
			SecTmp =:= TopSec+1->
				SecTmp;
			true->
				SecTmp
		end
	end,0, get(npc_chess_spirit_complete_section)).					 
	
update_chess_power()->
	{Duration,AddPower} = get(chess_spirit_power_addation),
	case timer:now_diff(now(),get(npc_chess_spirit_last_add_power)) >= Duration*1000 of
		true->		%%add power to chess
			change_chess_power(AddPower);
		_->
			nothing
	end.

change_chess_power(AddPower)->
	put(npc_chess_spirit_last_add_power,now()),
	NewPower = erlang:min(get(npc_chess_spirit_cur_power) + AddPower,get(chess_spirit_chess_max_power)),
	put(npc_chess_spirit_cur_power,NewPower),
	send_to_all_update_chess_power(NewPower).

spawns_monster_for_section(Section)->
	put(npc_chess_spirit_cur_section,Section),
	put(npc_chess_spirit_last_spawn_time,now()),
	monster_spawns_brd(Section),
	SectionInfo = chess_spirit_db:get_chess_spirit_section_info(get(chess_spirit_type),Section),
	SpawnsInfo = chess_spirit_db:get_section_spawns(SectionInfo),
	MyPos = get_pos_from_npcinfo(get(creature_info)),
	AllSpawnsId = 
	lists:foldl(fun({CreatureProto,Pos},AllIds)->
			WayPoints = npc_ai:path_find(Pos,MyPos),
			case creature_op:call_creature_spawn_by_create(CreatureProto,Pos,?MOVE_TYPE_POINT,WayPoints,{?CREATOR_LEVEL_BY_SYSTEM,get(id)}) of
				error->
					slogger:msg("spawns_monster_for_section error CreatureProto ~p ~n",[CreatureProto]),
					AllIds;
				NpcId->					
					[NpcId|AllIds]
			end
	end, [],SpawnsInfo),
	put(npc_chess_spirit_monster_info,[{Section,AllSpawnsId}|get(npc_chess_spirit_monster_info)]),
	case chess_spirit_db:get_section_role_skills_level(SectionInfo) of
		[]->
			nothing;
		SkillsLevel ->		%%skill level changed!
			OriSkills = get_skilllist_from_npcinfo(get(creature_info)),
			NewSkillList = 
				lists:map(fun({SkillIdTmp,SkillLevelTmp,LastSkill})->
						case lists:keyfind(SkillIdTmp,1, SkillsLevel) of
							false->
								{SkillIdTmp,SkillLevelTmp,LastSkill};
							{SkillIdTmp,NewLevel}->
								{SkillIdTmp,NewLevel,LastSkill}
						end
				end,OriSkills),
			put(creature_info,set_skilllist_to_npcinfo(get(creature_info),NewSkillList)),
			%%send skill changed
			lists:foreach(fun({RoleId,RoleSelfSkills,_})-> send_role_update_skills(RoleId,RoleSelfSkills++[get(chess_spirit_chess_skills)]) end, get(npc_chess_spirit_player_info))
	end,
	%%shout
	npc_ai:handle_event(?EVENT_SECTION_UNITS_SPAWN).

%%power,skill info 
update_role_gameinfo(RoleId)->
	case lists:keyfind(RoleId, 1, get(npc_chess_spirit_player_info)) of
		false->
			slogger:msg("npc_chess_spirit update_role_gameinfo error RoleId ~p not in player_info ~n",[RoleId]);
		{_,RoleSelfSkills,RolePower}->
			ChessPower = get(npc_chess_spirit_cur_power),
			Share_skills = get_skills_send_record(get(chess_spirit_share_skills)),
			Self_skills = get_skills_send_record(RoleSelfSkills),
			Chess_skills = get_skills_send_record([get(chess_spirit_chess_skills)]),
			ChessMaxPower = get(chess_spirit_chess_max_power),
			RoleMaxPower = get(chess_spirit_role_max_power),	
			Msg = chess_spirit_packet:encode_chess_spirit_role_info_s2c(RolePower,ChessPower,RoleMaxPower,ChessMaxPower,Share_skills,Self_skills,Chess_skills,get(chess_spirit_type)),
			npc_op:send_to_other_client(RoleId, Msg)
	end.

update_section_info(RoleId)->
 	Msg = make_update_section_msg(),
	npc_op:send_to_other_client(RoleId, Msg).

update_section_info_to_all()->
	Msg = make_update_section_msg(),
	broad_msg_to_whole_map_clinet(Msg).	

make_update_section_msg()->	
	CurSection = get(npc_chess_spirit_cur_section),
	UsedTime_S = 
	case get(npc_chess_spirit_start_time) of
		{0,0,0}->
			0;
		StartTime->
			trunc(timer:now_diff(now(),StartTime)/1000000)
	end,
	NextSecTime_S = trunc((get(chess_spirit_section_duration) - timer:now_diff(now(),get(npc_chess_spirit_last_spawn_time))/1000)/1000),
	MaxHp = get_hpmax_from_npcinfo(get(creature_info)),
	CurHp = get_life_from_npcinfo(get(creature_info)),
	chess_spirit_packet:encode_chess_spirit_info_s2c(CurSection, UsedTime_S, NextSecTime_S, MaxHp, CurHp).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%									Cast Skill									%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc_role_cast_skill(RoleId,SkillId)->
	case lists:keyfind(RoleId, 1, get(npc_chess_spirit_player_info)) of
		false->
			nothing;
		{RoleId,SelfRanSkills,Power}->
			case lists:member(SkillId, SelfRanSkills) of
				true->
					{SkillId,SkillLevel,_} = lists:keyfind(SkillId,1, get_skilllist_from_npcinfo(get(creature_info))),
					case npc_ai:is_skill_can_use(SkillId) of
						true->
							CastPower = skill_db:get_soulpower(skill_db:get_skill_info(SkillId,SkillLevel)),
							NewPower = Power - CastPower,
							if
								NewPower >= 0->
									npc_op:start_attack(SkillId,SkillLevel,get(creature_info)),
									send_role_update_skills(RoleId,[SkillId]),
									update_role_power(RoleId,SelfRanSkills,NewPower);
								true->
									nothing
							end;
						_->
							nothing
					end
			end
	end.

proc_cast_chess_skill(RoleId)->
	case lists:keyfind(RoleId, 1, get(npc_chess_spirit_player_info)) of
		false->
			nothing;
		{RoleId,SelfRanSkills,Power}->
			case get(npc_chess_spirit_cur_section) of
				0->			%%not start game	
					nothing;
				_->
					SkillId = get(chess_spirit_chess_skills),
					{SkillId,SkillLevel,_} = lists:keyfind(SkillId,1, get_skilllist_from_npcinfo(get(creature_info))),
					CastPower = skill_db:get_soulpower(skill_db:get_skill_info(SkillId,SkillLevel)),
					NewPower = Power - CastPower,
					if
						NewPower >= 0->
							case npc_ai:is_skill_can_use(SkillId) of
								true->
									npc_op:start_attack(SkillId,SkillLevel,get(creature_info)),
									set_chess_skill_cool(),
									send_role_update_skills(RoleId,[SkillId]),
									update_role_power(RoleId,SelfRanSkills,NewPower);
								_->
									nothing
							end;
						true->
							nothing
					end
			end
	end.

set_chess_skill_cool()->
	SkillId = get(chess_spirit_chess_skills),
	MyOriSkillList = get_skilllist_from_npcinfo(get(creature_info)),
	{SkillId,SkillLevel,_} = lists:keyfind(SkillId,1, MyOriSkillList),
	put(creature_info,set_skilllist_to_npcinfo(get(creature_info),lists:keyreplace(SkillId,1, MyOriSkillList,{SkillId,SkillLevel,now()}))),	
	send_to_all_update_skills([SkillId]).

proc_role_up_share_skill(RoleId,SkillId)->
	case lists:keyfind(RoleId, 1, get(npc_chess_spirit_player_info)) of
		false->
			nothing;
		{RoleId,Skills,Power}->
			case lists:member(SkillId, get(chess_spirit_share_skills)) of
				true->
					MyOriSkillList = get_skilllist_from_npcinfo(get(creature_info)),
					{SkillId,SkillLevel,_} = lists:keyfind(SkillId,1,MyOriSkillList),
					NewSkillLevel = SkillLevel + 1,
					case skill_db:get_skill_info(SkillId,NewSkillLevel) of
						[]->
							send_role_error_msg(RoleId,?ERRNO_CHESS_SPIRIT_UP_LEVEL_MAX);
						SkillInfo->
							CastPower = skill_db:get_soulpower(SkillInfo),
							NewPower = Power - CastPower,  
							if
								 NewPower  >= 0 ->
									put(creature_info,set_skilllist_to_npcinfo(get(creature_info),lists:keyreplace(SkillId,1, MyOriSkillList,{SkillId,NewSkillLevel,{0,0,0}}))),
									npc_op:start_attack(SkillId,NewSkillLevel,get(creature_info)),
									send_to_all_update_skills([SkillId]),
									update_role_power(RoleId,Skills,NewPower);
								true->
									nothing		
							end
					end;
				_->
					nothing
			end
	end.

update_role_power(RoleId,Skills,NewPower)->
	put(npc_chess_spirit_player_info,lists:keyreplace(RoleId,1, get(npc_chess_spirit_player_info),{RoleId,Skills,NewPower})),
	send_role_update_power(RoleId,NewPower).

finish_all_game()->
	todo_brd,
	game_over(?CHESS_SPIRIT_RESULT_SUCCESS).

prepare_brd(LeftSecond)->
	Msg = chess_spirit_packet:encode_chess_spirit_prepare_s2c(LeftSecond),
	broad_msg_to_whole_map_clinet(Msg).

monster_spawns_brd(Section)->
	todo.

send_to_role_init_info(RoleId)->
	update_role_gameinfo(RoleId),
	update_section_info(RoleId).

send_role_update_power(RoleId,Power)->
	Msg = chess_spirit_packet:encode_chess_spirit_update_power_s2c(Power),
	npc_op:send_to_other_client(RoleId, Msg).

send_role_update_skills(RoleId,SkillIds)->
	SendSkills = get_skills_send_record(SkillIds),
	Msg = chess_spirit_packet:encode_chess_spirit_update_skill_s2c(SendSkills),
	npc_op:send_to_other_client(RoleId, Msg).

send_role_error_msg(RoleId,Errno)->
	Msg = chess_spirit_packet:encode_chess_spirit_opt_result_s2s(Errno),
	npc_op:send_to_other_client(RoleId, Msg).

send_to_all_update_skills(SkillIds)->
	SendSkills = get_skills_send_record(SkillIds),
	Msg = chess_spirit_packet:encode_chess_spirit_update_skill_s2c(SendSkills),
	broad_msg_to_whole_map_clinet(Msg).

send_to_all_update_chess_power(NewPower)->
	nothing.		%%7.19 delete chess power
	%%Msg = chess_spirit_packet:encode_chess_spirit_update_chess_power_s2c(NewPower),
	%%broad_msg_to_whole_map_clinet(Msg).
	
%%local util
broad_msg_to_whole_map_clinet(Msg)->
	lists:foreach(fun(RoleId)->npc_op:send_to_other_client(RoleId, Msg) end,mapop:get_map_roles_id()). 
broad_msg_to_whole_map(Msg)->
	lists:foreach(fun(RoleId)->npc_op:send_to_creature(RoleId,Msg) end,mapop:get_map_roles_id()). 

broad_cast_to_world(section,NewDesSec)->
	todo.
	
ran_obt_by_num(_,ReList,0)->
	ReList;
ran_obt_by_num([],ReList,0)->
	ReList;
ran_obt_by_num(List,ReList,LeftNum)->
	RandomV = random:uniform(erlang:length(List)),
	{L1,[MewItem|T]} = lists:split(RandomV - 1, List),
	ran_obt_by_num(L1++T,[MewItem|ReList],LeftNum-1).

get_skills_send_record(SkillIds)->
	lists:map(fun(SkillID)->
		{SkillID,SkillLevel,LastCastTime} = lists:keyfind(SkillID,1, get_skilllist_from_npcinfo(get(creature_info))),
		pb_util:to_skill_info(SkillID,SkillLevel,LastCastTime)		  
	end,SkillIds).