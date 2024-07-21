%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_op).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("map_def.hrl").
-include("common_define.hrl").
-include("creature_define.hrl").
-include("npc_define.hrl").
-include("ai_define.hrl").
-include("error_msg.hrl").
-include("skill_define.hrl").
-include("system_chat_define.hrl").
-include("map_info_struct.hrl").

-compile(export_all).

init({{LineId,MapId},NpcSpwanInfo}, MapProc,NpcManager,CreateArg) ->
	NpcId = npc_db:get_spawn_id(NpcSpwanInfo),
	set_data_to_npcinfo(NpcSpwanInfo,NpcManager,CreateArg),
	NpcInfoDB = make_npcinfo_db_name(MapProc),
	put(npcinfo_db,NpcInfoDB),
	Map_db = mapdb_processor:make_db_name(MapId),
	put(map_db,Map_db),			
	put(map_info, create_mapinfo(MapId, LineId, node(), MapProc, ?GRID_WIDTH)),
	update_npc_info(NpcId,get(creature_info)).

set_data_to_npcinfo(NpcSpawnInfo,NpcManager,CreateArg) ->
	NpcId = npc_db:get_spawn_id(NpcSpawnInfo),
	Now = now(),
	{_,B,C} = Now,
	A = NpcId rem 32767,
	random:seed({A,B,C}),
	if
		NpcId >= ?DYNAMIC_NPC_INDEX->				%%动态npc
			erlang:send_after(?DYNAMIC_NPC_LIFE_TIME,self(),{forced_leave_map});
		true->	
			nothing
	end,
	ProtoId = npc_db:get_spawn_protoid(NpcSpawnInfo),
	OriBorn = npc_db:get_spawn_bornposition(NpcSpawnInfo),
	Action_list = npc_db:get_spawn_actionlist(NpcSpawnInfo),
	RespawnTime = npc_db:get_spawn_retime(NpcSpawnInfo),
	%%设置重生信息
	put(born_info,{OriBorn,RespawnTime}),
	npc_ai:init(ProtoId,Action_list),
	BornPos = get_next_respawn_pos(),
	case is_list(OriBorn) of
		true->
			PositionType = ?MOVE_TYPE_POINT,
			PositionValue = BornPos;
		_->	  
			PositionType = npc_db:get_spawn_movetype(NpcSpawnInfo),
			PositionValue = npc_db:get_spawn_waypoint(NpcSpawnInfo)
	end,
		
	HatredsRelation = npc_db:get_spawn_hatreds_list(NpcSpawnInfo),
	{CurrentAttributes,_CurrentBuffers, _ChangeAttribute} = compute_buffers:compute(ProtoId, [], [], [], []),
	put(current_attribute, CurrentAttributes),
	put(current_buffer, []),	
	case quest_npc_db:get_questinfo_by_npcid(NpcId) of
		[]->
			Acc_quest_list=[],
			Com_quest_list=[];
		NpcQuestInfo->
			{Acc_quest_list,Com_quest_list } = quest_npc_db:get_quest_action(NpcQuestInfo)
					
	end,
	{_TableName,ProtoId,Name,Level,Npcflags,Maxhp,Maxmp,Class,Power,Commoncool,Immunes,Hitrate,Dodge,Criticalrate,
					Criticaldamage,Toughness,Debuffimmunes,WalkSpeed,RunSpeed,Exp,MinMoney,MaxMoney,SkillList,HibernateTag,Defenses,Hatredratio,		
					Alert_radius,Bounding_radius,Script_hatred,Script_skill,Display,WalkDelayTime,Faction,IsShareForQuest,Script_BaseAttr} = npc_db:get_proto_info_by_id(ProtoId),		
	case Script_hatred of 
		?NO_HATRED -> HatredOp = nothing_hatred;
		?NORMAL_HATRED ->HatredOp = normal_hatred_update;%%normal_hatred_update;
		?ACTIVE_HATRED ->HatredOp = active_hatred_update;%%active_hatred_update;
		?BOSS_HATRED ->HatredOp = active_boss_hatred_update
	end,
	{CreatorLevel,CreatorId} = CreateArg,
	put(creator_id,CreatorId),
	case Script_BaseAttr of
		[]->
			NewLevel = Level,
			NewMaxhp = Maxhp,
			NewMaxmp = Maxmp,
			NewPower = Power,
			NewImmunes = Immunes,
			NewHitrate = Hitrate,
			NewDodge = Dodge,
			NewCriticalrate = Criticalrate,
			NewCriticaldamage = Criticaldamage,
			NewToughness = Toughness,
			NewDebuffimmunes = Debuffimmunes,
			NewExp = Exp,
			NewMinMoney = MinMoney,
			NewMaxMoney = MaxMoney,
			NewDefenses = Defenses;
		_->
			if
				CreatorLevel =:= ?CREATOR_LEVEL_BY_SYSTEM->
					NewLevel = Level,
					NewMaxhp = Maxhp,
					NewMaxmp = Maxmp,
					NewPower = Power,
					NewImmunes = Immunes,
					NewHitrate = Hitrate,
					NewDodge = Dodge,
					NewCriticalrate = Criticalrate,
					NewCriticaldamage = Criticaldamage,
					NewToughness = Toughness,
					NewDebuffimmunes = Debuffimmunes,
					NewExp = Exp,
					NewMinMoney = MinMoney,
					NewMaxMoney = MaxMoney,
					NewDefenses = Defenses;
				true->
					NewLevel = CreatorLevel,
					NewMaxhp = npc_baseattr:get_value(get_maxhp,NewLevel,Maxhp,Script_BaseAttr),
					NewMaxmp = npc_baseattr:get_value(get_maxmp,NewLevel,Maxmp,Script_BaseAttr),
					NewPower = npc_baseattr:get_value(get_power,NewLevel,Power,Script_BaseAttr),
					NewImmunes = npc_baseattr:get_value(get_immunes,NewLevel,Immunes,Script_BaseAttr),
					NewHitrate = npc_baseattr:get_value(get_hitrate,NewLevel,Hitrate,Script_BaseAttr),
					NewDodge = npc_baseattr:get_value(get_dodge,NewLevel,Dodge,Script_BaseAttr),
					NewCriticalrate = npc_baseattr:get_value(get_criticalrate,NewLevel,Criticalrate,Script_BaseAttr),
					NewCriticaldamage = npc_baseattr:get_value(get_criticaldamage,NewLevel,Criticaldamage,Script_BaseAttr),
					NewToughness = npc_baseattr:get_value(get_toughness,NewLevel,Toughness,Script_BaseAttr),
					NewDebuffimmunes = npc_baseattr:get_value(get_debuffimmunes,NewLevel,Debuffimmunes,Script_BaseAttr),
					NewExp = npc_baseattr:get_value(get_exp,NewLevel,Exp,Script_BaseAttr),
					NewMinMoney = npc_baseattr:get_value(get_minmoney,NewLevel,MinMoney,Script_BaseAttr),
					NewMaxMoney = npc_baseattr:get_value(get_maxmoney,NewLevel,MaxMoney,Script_BaseAttr),
					NewDefenses = npc_baseattr:get_value(get_defenses,NewLevel,Defenses,Script_BaseAttr)
			end
	end,	
	Skills = lists:map(fun({SkillId,SkillLevel})-> {SkillId,SkillLevel,{0,0,0}} end,SkillList),
	%%[{id,skillrates}]
	%%初始化仇恨列表
	npc_hatred_op:init(),
	buffer_op:init(),
	%%特殊常用字典
	
	put(npc_script,Script_skill),
	put(hatred_fun,HatredOp),
	put(can_hibernate,HibernateTag=:=0),
	put(npc_manager,NpcManager),
	put(id,NpcId),
	put(orinpcflag,Npcflags),
	put(last_cast_time,{0,0,0}),
	put(join_battle_time,{0,0,0}),
	put(aoi_list,[]),
	put(attack_range,?DEFAULT_ATTACK_RANGE),
	put(next_skill_and_target,{0,0}),
	put(ownnerid,0),
	put(hibernate_tag,false),
	put(hatreds_relations,HatredsRelation),
	put(is_death_share,IsShareForQuest=:=1),
	put(instanceid,[]),
	put(walk_speed,WalkSpeed),
	put(run_speed,RunSpeed),
	put(bornposition,BornPos),
	put(bounding_radius,Bounding_radius),
	put(alert_radius,Alert_radius),
	npc_movement:init(PositionType,PositionValue),
	npc_action:init(),
	%%creature info
	Life = NewMaxhp,
	Mana = NewMaxmp,
	Buffer = [],
	Touchred = 0,
	State = gaming,
	Extra_states = [],
	Path = [],
	put(creature_info,
			create_npcinfo(NpcId,self(),BornPos,Name,Faction,WalkSpeed,Life,Path,State,NewLevel,
					Mana,Commoncool,Extra_states,Npcflags,ProtoId,NewMaxhp,NewMaxmp,
					Display,Class,NewPower,Touchred,NewImmunes,NewHitrate,NewDodge,NewCriticalrate,NewCriticaldamage,
					NewToughness,NewDebuffimmunes,Skills,NewExp,NewMinMoney,NewMaxMoney,NewDefenses,Hatredratio,
					Script_hatred,Script_skill,Acc_quest_list,Com_quest_list,Buffer)),
	put(walkdelaytime, WalkDelayTime),
	npc_script:run_script(init,[]).
	
join(NpcInfo, MapInfo) ->
	Id = get_id_from_npcinfo(NpcInfo),
	NpcInfoDB = get(npcinfo_db), 
	npc_manager:regist_npcinfo(NpcInfoDB, Id, NpcInfo),
	creature_op:join(NpcInfo, MapInfo),
	case get_lineid_from_mapinfo(MapInfo) of
		-1->			%%instance creature
			InstanceId = map_processor:get_instance_id(get_proc_from_mapinfo(MapInfo)),
			put(instanceid,InstanceId);
		_->
			put(instanceid,[])
	end,
	npc_ai:handle_event(?EVENT_SPAWN).

make_npcinfo_db_name(MapProcName)->
	Name = lists:append(["ets_npc_", atom_to_list(MapProcName)]),
	list_to_atom(Name).
	
is_active_monster()->
	(get(hatred_fun) =:= active_boss_hatred_update) or (get(hatred_fun) =:= active_hatred_update).	

call_duty()->
	util:send_state_event(self(), {perform_creature_duty}).
	
should_be_hibernate()->
	Grid = mapop:convert_to_grid_index(get_pos_from_npcinfo(get(creature_info) ), ?GRID_WIDTH),	
	MapProcName = get_proc_from_mapinfo( get(map_info)),	
	(not mapop:is_grid_active(MapProcName, Grid)) and get(can_hibernate).
	
%%检查自己所在格是否冷却,如果冷却且npc可被休眠,进入休眠状态
perform_creature_duty()->	
	clear_all_action(),
	npc_action:set_state_to_idle(),
	case should_be_hibernate() of
		false->
			npc_ai:handle_event(?EVENT_IDLE),
			npc_ai:do_idle_action(),
			npc_op:start_alert();
		true->	
			hibernate()		
	end.
	
%%gaming状态时被休眠
hibernate()->
	case get(can_hibernate) of
		true->
			case get(hibernate_tag) of
				false->		%%未休眠
					put(hibernate_tag,true),
					clear_all_action();		
				true->
					nothing
			end;
		_->
			nothing
	end.	
			

%%激活
activate()->
	case get(hibernate_tag) of
		false->
			nothing;
		_->	%%休眠中,激活
			put(hibernate_tag,false),
			perform_creature_duty()
	end.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 处理NPC的警戒逻辑
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
start_alert()->
	case is_active_monster() of
		true ->
			Timer = gen_fsm:send_event_after(?NPC_ALERT_TIME, {alert_heartbeat}),
			npc_action:set_action_timer(Timer);
		false->
			nothing
	end.
	
%%判断Aoi列表里是否有玩家进入了警戒范围
alert_heartbeat()->
	case npc_op:should_be_hibernate() of
		false->
			case check_inrange_alert() of
				{enemy_found,Enemy} ->
					util:send_state_event(self(), {enemy_found,Enemy}),
					{[],[]};						
				nothing_todo ->
					Timer = gen_fsm:send_event_after(?NPC_ALERT_TIME,{alert_heartbeat}),
					npc_action:set_action_timer(Timer)
			end;
		_->
			self() ! {hibernate}
	end.	
		
check_inrange_alert()->
	case  (is_active_monster() and ( (Enemys = npc_ai:update_range_alert()) =/= [])) of
		true ->				%%找到aoi最近的敌人
			HatredOp = get(hatred_fun),
			CheckResult = 
			lists:foldl(fun(EnemyId,LastRe)->
				case npc_hatred_op:HatredOp(other_into_view, EnemyId) of
					update_attack ->  {enemy_found,EnemyId};
					nothing_todo->  LastRe
				end end,nothing_todo,Enemys),
			CheckResult;
		false -> 
			nothing_todo
	end.

find_path_and_move_to(Pos_my,Pos_want_to,Range)->
	case npc_ai:path_find_by_range(Pos_my,Pos_want_to,Range) of
		[]->
	 		slogger:msg("find_path_and_move_to pathfind ERROR Pos_my: ~p,Pos_end: ~p Range ~p Id ~p ~n",[Pos_my,Pos_want_to,Range,get(id)]);
	 	Path->
	 		npc_movement:move_request(get(creature_info),Path)
	 end.	
	 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NPC跟随的移动
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_follow_creature(NewFollowId)->
	clear_all_action(),
	npc_action:change_to_follow(NewFollowId),
	change_to_speed(runspeed),
	follow_target().
	
%% return: true/false	
stop_move_in_follow(FollowedInfo,Pos_my)->	
	case not creature_op:is_creature_dead(FollowedInfo) of	 
	 	true->	
			Pos_want_to = creature_op:get_pos_from_creature_info(FollowedInfo),
			case npc_ai:is_in_follow_range(Pos_my,Pos_want_to) of
				true->			
					Timer = gen_fsm:send_event_after(?NPC_FOLLOW_DURATION, {follow_heartbeat}),
					npc_action:set_action_timer(Timer),
					StopMove = true;
				_->
					StopMove = false
			end;
		_->
			case npc_script:run_script(follow_target_missed,[get(targetid)]) of
				true->			%%执行自己的目标丢失脚本
					nothing;
				_->
					erlang:send(self(), {leave_map})
			end,
			StopMove = true
	end,
	StopMove.
				
	
%%todo处理不在同一地图和节点上的follow	
follow_target()->
	FollowedId = get(targetid),
	FollowedInfo = creature_op:get_creature_info(FollowedId),
	MyInfo = get(creature_info),
	Pos_my = creature_op:get_pos_from_creature_info(MyInfo),
	case stop_move_in_follow(FollowedInfo,Pos_my) of
		false->
			Pos_want_to = creature_op:get_pos_from_creature_info(FollowedInfo),
			find_path_and_move_to(Pos_my,Pos_want_to,?NPC_FOLLOW_DISTANCE);
		_->
			nothing
	end.	 	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NPC攻击的移动
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% return: true/false
stop_move_in_attack(EnemyInfo,Pos_my)->
	case not creature_op:is_creature_dead(EnemyInfo) of
		true->
			TargetId = creature_op:get_id_from_creature_info(EnemyInfo),
			Pos_Enemy = creature_op:get_pos_from_creature_info(EnemyInfo),
			case npc_ai:is_outof_bound(Pos_Enemy) of
				true -> 
					npc_op:do_action_for_hatred_change(other_outof_bound,TargetId),
					CheckResult = true;
				_->
					case npc_ai:is_in_attack_range(Pos_my,Pos_Enemy) of
						true->
							case get_path_from_npcinfo(get(creature_info))=/=[] of
								true->
									npc_movement:stop_move();
								_->
									npc_movement:clear_now_move()
							end,
							npc_op:attack(TargetId),
							CheckResult = true;
						_->
							CheckResult = false
					end
			end;
		false->
			npc_op:do_action_for_hatred_change(other_dead,get(targetid)),
			CheckResult = true
	end,
	CheckResult.
			
move_to_attack() ->
	{_SkillId,SkillTargetId} = get(next_skill_and_target),
	EnemyInfo = creature_op:get_creature_info(SkillTargetId),
	Pos_my = get_pos_from_npcinfo(get(creature_info)),
	case stop_move_in_attack(EnemyInfo,Pos_my) of
		false->
			Pos_want_to = creature_op:get_pos_from_creature_info(EnemyInfo),
			find_path_and_move_to(Pos_my,Pos_want_to,get(attack_range));
		_->
			nothing
	end.
			 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NPC攻击选择
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
update_attack()->
	clear_all_action(),
	NewEnemyId = npc_hatred_op:get_target(),
	case (NewEnemyId=:=0) or creature_op:is_creature_dead(creature_op:get_creature_info(NewEnemyId)) of
		true ->
			do_action_for_hatred_change(other_dead,NewEnemyId);
		false -> 
			npc_action:change_to_attck(NewEnemyId),
			npc_op:broad_attr_changed([{targetid,NewEnemyId}]),
			%%清空之前的目标和技能
			put(next_skill_and_target,{0,0}),
			change_to_speed(runspeed),
			attack(NewEnemyId)		
	end.

do_action_for_hatred_change(Reason,NewEnemyId)->
	HatredOp = get(hatred_fun),
	case npc_hatred_op:HatredOp(Reason,NewEnemyId) of
		reset ->
				util:send_state_event(self(), {reset});
		update_attack -> 
				update_attack();
		nothing_todo ->
				util:send_state_event(self(), {reset})
	end.		
		
	
%%选择技能
update_skill(begin_attack,MyInfo,EnemyInfo)->
	case get(next_skill_and_target) of
		{0,_} ->	
			npc_ai:choose_skill(MyInfo,EnemyInfo),
			{SkillId,TargetId} = get(next_skill_and_target),	
			case SkillId of
				0 -> [];
				_ ->
					{_,SkillLevel,_} = lists:keyfind(SkillId,1,get_skilllist_from_npcinfo(MyInfo)),
					SkillInfo = skill_db:get_skill_info(SkillId,SkillLevel),
					AttackRange = skill_db:get_max_distance(SkillInfo),
					put(attack_range,AttackRange),
					{SkillId,SkillLevel,TargetId}
			end;
		{SkillId,TargetId} ->			%%如果已经选择了技能，但是上次攻击没放出来，不重新选择。
			{_,SkillLevel,_} = lists:keyfind(SkillId,1,get_skilllist_from_npcinfo(MyInfo)),
			SkillInfo = skill_db:get_skill_info(SkillId,SkillLevel),
			AttackRange = skill_db:get_max_distance(SkillInfo),
			put(attack_range,AttackRange),
			{SkillId,SkillLevel,TargetId}
	end.

%%技能释放完毕，清除	
update_skill(end_attack)->
	put(attack_range,?DEFAULT_ATTACK_RANGE),
	put(next_skill_and_target,{0,0}).	
	
set_join_battle_time()->
	case get(join_battle_time) of
		{0,0,0}->			%%刚进入战斗
			Ralations = get(hatreds_relations),
			%%仇恨关联
			lists:foreach(fun(CreatureId)-> CreatureInfo = creature_op:get_creature_info(CreatureId), npc_ai:call_help(CreatureInfo) end, Ralations),
			npc_ai:handle_event(?EVENT_ENTER_ATTACK),
			put(join_battle_time,now());
		_->
			nothing
	end.
	
clear_join_battle_time()->
	npc_ai:handle_event(?EVENT_LEAVE_COMBAT),
	put(join_battle_time,{0,0,0}).		
	
get_join_battle_time_micro_s()->
	case get(join_battle_time) of
		{0,0,0}->
			0;
		Time->	
			timer:now_diff(now(),Time)
	end.	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% attack TODO:返回状态
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
attack(OriEnemyId)->
	%%choose skill->inrange->attack/move_to_attack
	MyInfo = get(creature_info),
	OriEnemyInfo = creature_op:get_creature_info(OriEnemyId),	
	case not creature_op:is_creature_dead(OriEnemyInfo) of
		true->
			set_join_battle_time(),
			%%取技能和目标
			MySkill = update_skill(begin_attack,MyInfo,OriEnemyInfo),
			AttackDiffTime = erlang:trunc(timer:now_diff(now(), get(last_cast_time))/1000),
			CommonCool = get_commoncool_from_npcinfo(MyInfo),
			case AttackDiffTime >= CommonCool of 			%%检查公共冷却时间
				false ->				
					WaitTime =  CommonCool - AttackDiffTime,
					Timer = gen_fsm:send_event_after(WaitTime, {attack_heartbeat}),
					npc_action:set_action_timer(Timer);    %%过会再打
				true ->	
					case (MySkill=/=[]) of
						false -> 								%%未取到可用技能 ,过会再看				
							Timer = gen_fsm:send_event_after(CommonCool, {attack_heartbeat}),
							npc_action:set_action_timer(Timer);
						true ->
							{SkillId,SkillLevel,TargetId} = MySkill,
							if
								TargetId=:=OriEnemyId->
									TargetInfo = OriEnemyInfo;
								true->
									TargetInfo = creature_op:get_creature_info(TargetId)
							end,
							CanAttack = can_attack(MyInfo,TargetInfo),
							Pos_my = creature_op:get_pos_from_creature_info(MyInfo),
							Pos_Enemy = creature_op:get_pos_from_creature_info(TargetInfo),
							if
								not CanAttack->
									Timer = gen_fsm:send_event_after(CommonCool, {attack_heartbeat}),
									npc_action:set_action_timer(Timer);
								true->
									case npc_ai:is_in_attack_range(Pos_my,Pos_Enemy) or (get(attack_range) =:= 0) of          %%查看是否在攻击范围内    
										false ->
												npc_action:clear_now_action(),
												find_path_and_move_to(Pos_my,Pos_Enemy,get(attack_range));
										true ->								%%释放技能！
												NextState = start_attack(SkillId,SkillLevel,TargetInfo),
												case NextState of
													attack -> 				%%已经打了一下，待会再打										
														Timer = gen_fsm:send_event_after(CommonCool, {attack_heartbeat}),
														update_skill(end_attack),
														npc_action:set_action_timer(Timer);
													singing ->				%%希曼，赐予我力量吧......
														%%不管你吟唱成不成,有木有被打断,悲催的策划要求,你这个已经算使用过了(ps:与人物不同)
														update_skill(end_attack),
														put(creature_info,set_state_to_npcinfo(get(creature_info),singing)),
														npc_op:update_npc_info(get(), get(creature_info)),
														util:send_state_event(self(), {singing})
												end
									end
							end
					end
		end;
	false->
		do_action_for_hatred_change(other_dead,OriEnemyId)
	end. 					

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 发起攻击%%不管你吟唱成不成,你这个已经算使用过了(与人物不同),需要设置冷却
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_attack(SkillID,SkillLevel,TargetInfo) ->
	SelfId = get(id),
	SkillInfo = skill_db:get_skill_info(SkillID,SkillLevel),
	%% 获取生物的信息
	case not creature_op:is_creature_dead(TargetInfo) of
		true->			
			TargetID = creature_op:get_id_from_creature_info(TargetInfo),
			creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_ATTACK),
			SelfInfo = get(creature_info),
			MyPos = creature_op:get_pos_from_creature_info(SelfInfo),
			MyTarget = creature_op:get_pos_from_creature_info(TargetInfo),
			Speed = skill_db:get_flyspeed(SkillInfo),
			FlyTime = Speed*util:get_distance(MyPos,MyTarget),
			TimeNow = now(),			
			NewSkillList = lists:keyreplace(SkillID,1,get_skilllist_from_npcinfo(get(creature_info)),{SkillID,SkillLevel,TimeNow}),
			case skill_db:get_cast_time(SkillInfo) =:= 0 of 
				false->
					attack_broadcast(SelfInfo, role_packet:encode_role_attack_s2c(0, SelfId, SkillID, TargetID)),	
					combat_op:process_delay_attack(SelfInfo, TargetID, SkillID, SkillLevel, FlyTime),
					%%只put,不需要update同步到ets
					put(creature_info, set_skilllist_to_npcinfo(get(creature_info),NewSkillList)),
					NextState = singing;
				true ->
					%% 处理顺发攻击					
					{ChangedAttr, CastResult} = 
						combat_op:process_instant_attack(SelfInfo, TargetInfo, SkillID, SkillLevel,SkillInfo),	
					NewInfo2 = apply_skill_attr_changed(SelfInfo,ChangedAttr),									
					process_damage_list(SelfInfo,SkillID,SkillLevel, FlyTime, CastResult),
					creature_op:combat_bufflist_proc(SelfInfo,CastResult,FlyTime),
					NextState = attack,
					put(creature_info, set_skilllist_to_npcinfo(NewInfo2,NewSkillList)),
					update_npc_info(SelfId, get(creature_info))					
			end,
			put(last_cast_time,TimeNow),				
			NextState;
		false->
			attack
	end.

apply_skill_attr_changed(SelfInfo,ChangedAttr)->
	lists:foldl(fun(Attr,Info)->
			role_attr:to_creature_info(Attr,Info)			
		end,SelfInfo,ChangedAttr).

process_damage_list(SelfInfo,SkillId,SkillLevel, FlyTime, CastResult)->
	SelfId = get_id_from_npcinfo(SelfInfo),
	Units = lists:foldl(fun({TargetID, DamageInfo, _},Units1 ) ->
				 case DamageInfo of
				 	missing ->
				 		Units1 ++ [{SelfId, TargetID, 1, 0, SkillId,SkillLevel}];
				 	{critical,Damage} ->
				 	 	Units1 ++ [{SelfId,TargetID, 2, Damage, SkillId,SkillLevel}];
				 	{normal, Damage} ->
				 		Units1 ++ [{SelfId, TargetID, 0, Damage, SkillId,SkillLevel}];
				 	recover ->
				 		Units1		
				 end									     
	end,[],CastResult),
	
	case Units =/= [] of
		true ->						
			%%先通知他们的客户端被攻击了
			AttackMsg = role_packet:encode_be_attacked_s2c(SelfId,SkillId,Units,FlyTime),                                                     			
			broadcast_message_to_aoi_client(AttackMsg),
			%%服务器上需要根据flytime延迟计算伤害
			damages_broadcast(FlyTime,SelfId,Units);
		false ->
			nothing
	end.  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 自己被打了(有可能是战士反伤!) return:deading(被打死了)/{be_attacked,Hatred}(仇恨)/nothing:无仇恨处理
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
other_be_attacked({EnemyId, _, _, Damage, SkillId,SkillLevel}, SelfInfo) ->
	SelfId = get_id_from_npcinfo(SelfInfo),
	SkillInfo = skill_db:get_skill_info(SkillId,SkillLevel),
	case npc_script:run_script(be_attacked,[EnemyId,SkillId,SkillLevel,Damage]) of
		[]->			%%无被攻击脚本
			OtherInfo = creature_op:get_creature_info(EnemyId),
			case OtherInfo =:= undefined of
				 false->
				 	creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_BEATTACK),
					case get_npcflags_from_npcinfo(SelfInfo) of				
						?CREATURE_COLLECTION->	%%采集物体
							update_touchred_into_selfinfo(EnemyId),
							on_dead(OtherInfo),
							deading;	
						?CREATURE_YHZQ_NPC-> %%永恒之旗特殊物品
							{be_attacked,0};	
						_->						%%非采集物体走战斗流程
							case get_touchred_from_npcinfo(get(creature_info)) of
								0 -> 			
									%%没有染红，设置染红,通知周围人染红
									case creature_op:what_creature(EnemyId) of
										role->		
											update_touchred_into_selfinfo(EnemyId),
											npc_op:broad_attr_changed([{touchred,EnemyId}]);
										_->
											nothing
									end;
								_ ->			%%有染红
									nothing
							end,
							Life = erlang:max(get_life_from_npcinfo(get(creature_info)) + Damage, 0),			
							put(creature_info, set_life_to_npcinfo(get(creature_info), Life)),
							case Life =< 0 of
								true ->
									on_dead(OtherInfo),
									deading;
								false ->
									%%处理减血
									SkillHared = skill_db:get_addtion_threat(SkillInfo),
									update_npc_info(SelfId, get(creature_info)),
									npc_op:broad_attr_changed([{hp,Life}]),
									case npc_action:get_now_action() of
										?ACTION_RUN_AWAY->
											%%逃跑不反击
											nothing;
										_->	
											%%返回仇恨,以供反击，damage*rate + skillhared
											Rates = creature_op:get_hatredratio_from_creature_info(OtherInfo),		%%仇恨比率
											{be_attacked,-erlang:trunc(Damage*Rates) + SkillHared}
									end
							end
					end;
				true ->
					nothing
			end;
		ScriptResult->			%%被攻击脚本
			ScriptResult
	end.	
	
%%
%%aoi里有人被杀	
%%
other_be_killed(OtherId,Pos)->
	MyInfo = get(creature_info),
	MyPos = creature_op:get_pos_from_creature_info(MyInfo),
	case npc_ai:is_in_alert_range(MyPos,Pos) of
		true->
			CreatureType = creature_op:what_creature(OtherId),
			case creature_op:get_creature_info(OtherId) of
				undefined->
					nothing;
				OtherInfo->
					case creature_op:what_realation(MyInfo,OtherInfo) of
						enemy->
							case CreatureType of
								role->
									npc_ai:handle_event(?EVENT_OTHER_PLAYER_DIED);
								npc->
									npc_ai:handle_event(?EVENT_OTHER_NPC_DIED);
								_->
									nothing
							end;
						_->
							nothing
					end
			end;		
		_->
			false
	end.	

attack_broadcast(SelfInfo,  Message) ->
	broadcast_message_to_aoi_client(Message).	
	
damages_broadcast(FlyTime,SelfId, BeAttackedUnits) ->
	lists:foreach(fun({CreatureId,Pid})->
		case lists:keyfind(CreatureId, 2, BeAttackedUnits)  of
			false->
				nothing;
			AttackInfo->
				erlang:send_after(FlyTime, Pid, {other_be_attacked,AttackInfo})
		end	
	end,get(aoi_list)),	
	case lists:keyfind(SelfId, 2, BeAttackedUnits) of
		false->
			nothing;
		AttackInfo->
			erlang:send_after(FlyTime, self(), {other_be_attacked,AttackInfo})
	end.
	
process_sing_complete(NpcInfo, TargetID, SkillID, SkillLevel, FlyTime) ->
	case creature_op:get_creature_info(TargetID) of
		undefined->
			process_cancel_attack(get(id),out_range);
		TargetInfo->	
			case combat_op:process_sing_complete(NpcInfo, TargetInfo, SkillID, SkillLevel) of
				{ok, {ChangedAttr, CastResult}} ->								
					NewInfo2 = apply_skill_attr_changed(NpcInfo,ChangedAttr),		
					put(creature_info, NewInfo2),		
					process_damage_list(NpcInfo,SkillID,SkillLevel, FlyTime, CastResult),
					creature_op:combat_bufflist_proc(NpcInfo,CastResult,FlyTime),
					update_npc_info(get(id), NewInfo2);	
				_ ->
					process_cancel_attack(get(id),out_range)
			end
	end,	 	
	put(creature_info,set_state_to_npcinfo(get(creature_info),gaming)),
	npc_op:update_npc_info(get(id), get(creature_info)),
	CommonCool = get_commoncool_from_npcinfo(NpcInfo),
	Timer = gen_fsm:send_event_after(CommonCool, {attack_heartbeat}),
	npc_action:set_action_timer(Timer).%%继续攻击

process_cancel_attack(RoleID, Reason) ->
	case Reason of
		out_range ->
			Message = role_packet:encode_role_cancel_attack_s2c(RoleID,?ERROR_CANCEL_OUT_RANGE);
		move ->
			Message = role_packet:encode_role_cancel_attack_s2c(RoleID, ?ERROR_CANCEL_MOVE);
		interrupt_by_buff ->
			Message = role_packet:encode_role_cancel_attack_s2c(RoleID, ?ERROR_CANCEL_INTERRUPT)
	end,
	combat_op:cancel_sing_timer(),
	put(creature_info,set_state_to_npcinfo(get(creature_info),gaming)),
	npc_op:update_npc_info(get(id), get(creature_info)),
	broadcast_message_to_aoi_client(Message).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Buffer Begin%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%添加Buffer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
be_add_buffer(NewAddBuffersOri,CasterInfo) ->
	NewAddBuffers = lists:ukeysort(1,NewAddBuffersOri),
	NpcId = get(id),
	%% 处理Buffer的覆盖情况
	Fun = fun({BufferID, BufferLevel},{TmpNewBuffer,TmpRemoveBuffer}) ->
			      case lists:keyfind(BufferID, 1, get(current_buffer)) of
				      false ->
					      %% 该Buff没有被加过，所以可以加					      		      
					      {TmpNewBuffer++[{BufferID, BufferLevel}],TmpRemoveBuffer};					      
				      {_, OldBufferLeve} ->
					      case BufferLevel > OldBufferLeve of
						      false ->
							      %% 加过,新Buff的级别低
							      {TmpNewBuffer,TmpRemoveBuffer};
						      true ->
							      %% 加过，但是新Buff的级别高
								  remove_without_compute({BufferID, OldBufferLeve}),							    
							      {TmpNewBuffer ++ [{BufferID, BufferLevel}],TmpRemoveBuffer ++ [{BufferID, OldBufferLeve}]}
					      end
			      end
	      end,   	      	      
	{NewBuffers2,RemoveBuff} = lists:foldl(Fun,{[],[]},NewAddBuffers),
	case (RemoveBuff =/= []) or (NewBuffers2 =/= []) of
		true->			
				%% 设置Buffer给Npc造成的状态改变
			lists:foreach(fun({BufferID, BufferLevel}) ->
						      BufferInfo = buffer_db:get_buffer_info(BufferID, BufferLevel),
						      put(creature_info, buffer_extra_effect:add(get(creature_info),BufferInfo))
				      end, NewBuffers2),
			%% 触发由Buffer导致的事件
		 	lists:foreach(fun({BufferID, BufferLevel}) ->						 									
					     	buffer_op:generate_interval(BufferID, BufferLevel, 0,timer_center:get_correct_now(),CasterInfo)
			      end, NewBuffers2 ),				      	 		      		     								
			%%更新
			put(creature_info,set_buffer_to_npcinfo(get(creature_info),get(current_buffer))),
			%% 广播中了Buff的消息
			Buffers_WithTime = lists:map(fun({BufferID, BufferLevel}) ->  
					BufferInfo = buffer_db:get_buffer_info(BufferID, BufferLevel),
					DurationTime = buffer_db:get_buffer_duration(BufferInfo),
					{BufferID, BufferLevel,DurationTime} end,NewBuffers2),
			Message3 = role_packet:encode_add_buff_s2c(NpcId, Buffers_WithTime),
			broadcast_message_to_aoi_client(Message3),
			recompute_attr(NewBuffers2,RemoveBuff),
			put(current_buffer, lists:ukeymerge(1, NewBuffers2, get(current_buffer))),
			%%广播停止移动,但timer不能停.move_heartbeat里会自动检测能否移动
			case can_move(get(creature_info)) of 
				false ->
						npc_movement:notify_stop_move();
				true ->
						nothing
			end,
			combat_op:interrupt_state_with_buff(get(creature_info)),
			update_npc_info(NpcId, get(creature_info));
	false->
		nothing
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 移除buffer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
remove_buffers(BuffList)->
	lists:foreach(fun(BuffInfo)->
			remove_without_compute(BuffInfo)
		end,BuffList),
	recompute_attr([],BuffList).	

remove_buffer(BufferInfo) ->
	remove_without_compute(BufferInfo),
	recompute_attr([],[BufferInfo]).

remove_without_compute({BufferId,BufferLevel}) ->
	NpcInfo = get(creature_info),
	NpcId = get(id),
	case buffer_op:has_buff(BufferId) of
		true->
			buffer_op:remove_buffer(BufferId), %% 从Buffer定时器中删除该BufferID
			put(current_buffer, lists:keydelete(BufferId, 1, get(current_buffer))),
			%%更新creature info
			BufferInfo2 = buffer_db:get_buffer_info(BufferId, BufferLevel),
			put(creature_info,buffer_extra_effect:remove(NpcInfo,BufferInfo2)),
			put(creature_info,set_buffer_to_npcinfo(get(creature_info),get(current_buffer))),
			%%发送
			Message = role_packet:encode_del_buff_s2c(NpcId,BufferId),
			broadcast_message_to_aoi_client(Message);	
		_->
			nothing
	end.	
    	
	
recompute_attr(NewBuffers2,RemoveBuff)->
	OriInfo = get(creature_info),
	SelfId = get_id_from_npcinfo(OriInfo),
	{NewAttributes, _CurrentBuffers, ChangeAttribute} = 
	compute_buffers:compute(get_templateid_from_npcinfo(OriInfo), get(current_attribute), get(current_buffer), NewBuffers2, RemoveBuff),
	%%应用属性改变
	put(current_attribute, NewAttributes),
	NewInfo = lists:foldl(fun(Attr,Info)->					
				 	role_attr:to_creature_info(Attr,Info)
				 end,OriInfo,ChangeAttribute),
	put(creature_info,NewInfo),
	update_npc_info(SelfId,get(creature_info)),
	%%发送属性改变
	ChangeAttribute_Hp_Mp = role_attr:preform_to_attrs(ChangeAttribute),
	npc_op:broad_attr_changed(ChangeAttribute_Hp_Mp).		 

can_move(NpcInfo) ->
	ExtState = get_extra_state_from_npcinfo(NpcInfo),
	Freezing = lists:member(freezing,ExtState ), 	%%冰冻
	Coma = lists:member(coma,ExtState),			%%昏迷
	IsDeading = creature_op:is_creature_dead(NpcInfo),
	not (Freezing or Coma or IsDeading ).  
	
can_attack(NpcInfo,TargetInfo)->
	ExtState = get_extra_state_from_npcinfo(NpcInfo),
	Coma = lists:member(coma,ExtState),			%%昏迷
	God = lists:member(god,ExtState),			%%无敌
	OtherGod = combat_op:is_target_god(TargetInfo),
	not (God or Coma or OtherGod).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Buffer End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%						 离开地图
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc_leave_map()->
	creature_op:leave_map(get(creature_info),get(map_info)),
	RespawnTime = npc_op:get_next_respawn_time(),
	if
		RespawnTime =/= 0->						
			Timer = gen_fsm:send_event_after(RespawnTime, {respawn}), %%离开地图一会后重生
			put(respawn_timer,Timer );
		true->										%%no_need_respawn unload
			creature_op:unload_npc_from_map(get_proc_from_mapinfo(get(map_info)),get(id))
	end.

proc_force_leave_map()->
	case get(is_in_world) of
   		true->
   			creature_op:leave_map(get(creature_info),get(map_info)),
   			creature_op:unload_npc_from_map(get_proc_from_mapinfo(get(map_info)),get(id));
   		_->
   			nothing
   	end.


%% 给由Listeners指定角色发送信息
send_to_creature(RoleId,Message)->
	RoleInfo = creature_op:get_creature_info(RoleId),
	case RoleInfo of
		undefined -> nothing;
		_ ->
			Pid = creature_op:get_pid_from_creature_info(RoleInfo),
			gs_rpc:cast(Pid,Message)
	end.

broadcast_message_to_aoi_role(Message) ->
	broadcast_message_to_aoi_role(0,Message).
broadcast_message_to_aoi_role(DelayTime,Message) ->
	lists:foreach(fun({ID, Pid}) ->
					case creature_op:what_creature(ID) of
						role->
				      		case DelayTime =:= 0 of
					      		true ->
						      		gs_rpc:cast(Pid,Message);
					      		false ->					    
						      		timer_util:send_after(DelayTime, Pid, Message)
				      		end;
				      	_->
				      		nothing
				    end	
		      end, get(aoi_list)).   	
	      	
broadcast_message_to_aoi(Message) ->
	broadcast_message_to_aoi(0, Message).
broadcast_message_to_aoi(DelayTime, Message) ->
	case DelayTime of
		0 ->			
			lists:foreach(fun({_ID, Pid}) ->
						      gs_rpc:cast(Pid,Message)
					end, get(aoi_list));
		_ ->
			lists:foreach(fun({_ID, Pid}) ->
						      timer_util:send_after(DelayTime, Pid, Message)
					end, get(aoi_list))
	end.


broadcast_message_to_aoi_client(Message)->
	lists:foreach(fun({RoleId,_})->
			case creature_op:what_creature(RoleId) of
				role-> 
					send_to_other_client(RoleId,Message);
				_->
					nothing
			end 
	end,get(aoi_list)).

send_to_other_client(RoleId,Message)->	
	case creature_op:get_creature_info(RoleId) of
		undefined -> nothing;
		RoleInfo->
			send_to_other_client_by_roleinfo(RoleInfo,Message)
	end.
	
send_to_other_client_by_roleinfo(RoleInfo,Message)->
	GS_GateInfo = get_gateinfo_from_roleinfo(RoleInfo),
	Gateproc = get_proc_from_gs_system_gateinfo(GS_GateInfo),					
	tcp_client:send_data(Gateproc, Message).	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 被挑衅!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
provoke(ProvokerId)->
	%%设置可攻击
	put(creature_info, set_npcflags_to_npcinfo(get(creature_info), ?CREATURE_MONSTER)),
	%%设置仇恨
	HatredOp = get(hatred_fun),
	npc_hatred_op:HatredOp(is_attacked,{ProvokerId,?HELP_HATRED}),	
	%%设置染红
	update_touchred_into_selfinfo(ProvokerId),
	%%通知状态变化
	npc_op:broad_attr_changed([{touchred,ProvokerId},{creature_flag,?CREATURE_MONSTER}]),
	%%去干他!
	update_attack().
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 逃跑
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run_away()->
	todo_find_pos.
%%脱战,逃跑
run_away_to_pos(Pos)->
	%%清除当前行动
	clear_all_action(),
	%%清除仇恨列表
	npc_hatred_op:clear(),
	put(attack_range,?DEFAULT_ATTACK_RANGE),
	put(next_skill_and_target,{0,0}),
	%%清除当前目标,设置逃跑行为
	npc_op:broad_attr_changed([{targetid,0}]),
	npc_action:change_to_runaway(),	
	npc_movement:move_to_point(Pos),
	%%不被优化,防止走到未激活区域被停住
	put(can_hibernate,false),
	switch_to_gaming_state(get(id)).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 死亡
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
on_dead(KillerInfo)->
	EnemyId = creature_op:get_id_from_creature_info(KillerInfo),
	EnemyName = creature_op:get_name_from_creature_info(KillerInfo),
	NpcInfo = get(creature_info),
	case npc_action:get_now_action() of
		?ACTION_IDLE->			%%直接被秒
			npc_action:change_to_attck(EnemyId);
		_->
			nothing
	end,	
	MyPos = get_pos_from_npcinfo(NpcInfo),	
	%%删除buff
	creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_DEAD),
	%%更新当前状态
	put(creature_info,set_buffer_to_npcinfo(get(creature_info),[])),
	put(creature_info, set_state_to_npcinfo(get(creature_info), deading)),
	update_npc_info(get(id),get(creature_info)),
	%%处理死亡事件
	npc_ai:handle_event(?EVENT_DIED),
	%%通知死亡
	broadcast_message_to_aoi({other_be_killed, {get(id),EnemyId,EnemyName ,0,MyPos}}),
	%%掉落
	QuestShareRoles = lists:filter(fun(CreatureIdTmp)->creature_op:what_creature(CreatureIdTmp)=:= role end,npc_hatred_op:get_all_enemys()),
	case get_touchred_from_npcinfo(NpcInfo) of
		0->
			nothing;
		Roleid->	
			ProtoId = get_templateid_from_npcinfo(NpcInfo),
			case get(is_death_share) of
				true->
					Message = {creature_killed,{get(id),ProtoId,MyPos,QuestShareRoles}};
				_->
					Message = {creature_killed,{get(id),ProtoId,MyPos,[]}}
			end,		
			send_to_creature(Roleid,Message)
	end,	
	case get_npcflags_from_npcinfo(NpcInfo) =/= ?CREATURE_COLLECTION of
		true->																	%%怪物趴一会后离开地图
			gen_fsm:send_event_after(?DEAD_LEAVE_TIME, {leavemap});				
		false->																	%%立刻离开
			util:send_state_event(self(),{leavemap})
	end.		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% respawn Npc idle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
get_next_respawn_pos()->
	{OriBorn,_} = get(born_info),
	case is_list(OriBorn) of
		true->
			lists:nth(random:uniform(erlang:length(OriBorn)),OriBorn);
		_->	  
			OriBorn
	end.
	
get_next_respawn_time()->	
	{_,OriRespawnTime} = get(born_info),
	if
		is_list(OriRespawnTime)->
			[RespawnTmp|_T] = OriRespawnTime,
			if
				is_integer(RespawnTmp)->		%%重生时间的随机列表
					lists:nth(random:uniform(erlang:length(OriRespawnTime)),OriRespawnTime);
				true->								%%[重生时间点{时,分,秒}]
					{{_,_,_},{Hnow,Mnow,Snow}} = calendar:now_to_local_time(timer_center:get_correct_now()),
					NowSec = calendar:datetime_to_gregorian_seconds({{1,1,1},{Hnow,Mnow,Snow}}),
					SectlistTmp =
						lists:foldl(fun({Htmp,Mtmp,Stmp},ReTmp)->
						ReTmp ++
						[
							calendar:datetime_to_gregorian_seconds({{1,1,1},{Htmp,Mtmp,Stmp}}) - NowSec,
							calendar:datetime_to_gregorian_seconds({{1,1,2},{Htmp,Mtmp,Stmp}}) - NowSec
						]
						end,[],OriRespawnTime),
					case lists:filter(fun(SecTmp)-> SecTmp>0 end,SectlistTmp) of
						[]->
							slogger:msg("error get_next_respawn_time time [] ~p ~n",[get(id)]),
							0;
						WaitSecsList->
							lists:min(WaitSecsList)*1000
					end	
			end;	
		true->	  
			OriRespawnTime
	end.	

npc_respawn()->
	%%初始化路径
	Pos_born = get_next_respawn_pos(),
	update_touchred_into_selfinfo(0),
	%%清空染红
	npc_hatred_op:clear(),
	%%血蓝回满
	Life = get_hpmax_from_npcinfo(get(creature_info)),
	Mp = get_mpmax_from_npcinfo(get(creature_info)), 
	put(creature_info, set_npcflags_to_npcinfo(get(creature_info), get(orinpcflag))),
	put(creature_info, set_life_to_npcinfo(get(creature_info), Life)),
	put(creature_info, set_mana_to_npcinfo(get(creature_info), Mp)),
	put(creature_info, set_pos_to_npcinfo(get(creature_info), Pos_born)),
	put(creature_info, set_state_to_npcinfo(get(creature_info), gaming)),
	put(creature_info, set_speed_to_npcinfo(get(creature_info),get(walk_speed))),
	update_npc_info(get(id),get(creature_info)),
	%%初始化动作
	npc_action:init(),
	%%清除技能目标
	put(next_skill_and_target,{0,0}),
	put(attack_range,?DEFAULT_ATTACK_RANGE),
	%%清除战斗时间	
	clear_join_battle_time(),
	put(ownnerid,0),
	%%ai重置
	npc_ai:respawn(),
	put(bornposition,Pos_born),
	%%广播
	MyName = get_name_from_npcinfo(get(creature_info)),
	NpcProtoId = get_templateid_from_npcinfo(get(creature_info)),
	MapId = get_mapid_from_mapinfo(get(map_info)),
	LineId = get_lineid_from_mapinfo(get(map_info)),
	creature_sysbrd_util:sysbrd({monster_born,server_travels_util:is_share_server(),NpcProtoId},{LineId,MapId,MyName}).
	
clear_all_action()->	
	%清除ai_timer
	npc_ai:clear_act(),
	%%清除移动timer
	npc_movement:clear_now_move(),
	%%清除行动timer
	npc_action:clear_now_action().
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% resset Npc idle,back to born,status recover
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
npc_reset()->
	%%清除buff
	creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_DEAD),
	clear_all_action(),
	%%清空染红
	update_touchred_into_selfinfo(0),
	npc_hatred_op:clear(),
	clear_join_battle_time(),
	Pos_my = get_pos_from_npcinfo(get(creature_info)),
	Pos_born = npc_action:on_reset_get_return_pos(),
	Path = npc_ai:path_find(Pos_my,Pos_born),
	%%血量回满
	SelfId = get(id),
	HPMax = get_hpmax_from_npcinfo(get(creature_info)),
	put(creature_info, set_life_to_npcinfo(get(creature_info),HPMax)),
	npc_op:broad_attr_changed([{targetid,0}]),
	put(attack_range,?DEFAULT_ATTACK_RANGE),
	put(next_skill_and_target,{0,0}),
	put(ownnerid,0),
	put(creature_info, set_npcflags_to_npcinfo(get(creature_info), get(orinpcflag))),
	npc_op:broad_attr_changed([{touchred,0},{hp,HPMax}]),
	switch_to_gaming_state(SelfId),
	if
		Path=:=[] ->		%% at reset point
			case (get_path_from_npcinfo(get(creature_info))=/=[]) of
				true->
					npc_movement:stop_move();
				_->
					nothing
			end,
			update_npc_info(get(id),get(creature_info)),
			util:send_state_event(self(), {reset_fin});	
		true->
			%%update_npc_info in move_request
			npc_movement:move_request(get(creature_info),Path)
	end.
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% switch state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_touchred_into_selfinfo(Touchred) -> 
	put(creature_info, set_touchred_to_npcinfo(get(creature_info), Touchred)).

%%转变走姿态
change_to_speed(walkspeed)->
	CreatureInfo = get(creature_info),
	SelfId = get(id),
	CurrentSpeed = get_speed_from_npcinfo(CreatureInfo),
	MovespeedRate = attribute:get_current(get(current_attribute),movespeed),
	WalkSpeed = get(walk_speed),
	case role_attr:calculate_movespeed(MovespeedRate,WalkSpeed) of
		CurrentSpeed->
			nothing;
		RealWalkSpeed->	
			put(creature_info, set_speed_to_npcinfo(CreatureInfo,RealWalkSpeed)),
			update_npc_info(SelfId, get(creature_info)),
			npc_op:broad_attr_changed([{movespeed,RealWalkSpeed}])
	end;

%%转变跑姿态
change_to_speed(runspeed)->
	CreatureInfo = get(creature_info),
	SelfId = get(id),
	MovespeedRate = attribute:get_current(get(current_attribute),movespeed),
	CurrentSpeed = get_speed_from_npcinfo(CreatureInfo),
	RunSpeed = get(run_speed),
	case role_attr:calculate_movespeed(MovespeedRate,RunSpeed) of
		CurrentSpeed->				
			nothing;
		RealRunSpeed->
			put(creature_info, set_speed_to_npcinfo(CreatureInfo,RealRunSpeed)),
			update_npc_info(SelfId, get(creature_info)),	
			npc_op:broad_attr_changed([{movespeed,RealRunSpeed}])
	end.												

switch_to_gaming_state(SelfId) ->
	put(creature_info, set_state_to_npcinfo(get(creature_info), gaming)),
	update_npc_info(SelfId, get(creature_info)),
	gaming.
	
update_npc_info(SelfId, NpcInfo) ->
	NpcInfoDB = get(npcinfo_db),
	npc_manager:regist_npcinfo(NpcInfoDB, SelfId, NpcInfo).


other_outof_view(OtherId) ->
	case creature_op:is_in_aoi_list(OtherId) of
		true ->		
			creature_op:remove_from_aoi_list(OtherId),
			out_of_view;
		false ->
			nothing
	end.

broad_attr_changed(ChangedAttrs)->
	UpdateObj = object_update:make_update_attr(?UPDATETYPE_NPC,get(id),ChangedAttrs),
	creature_op:direct_broadcast_to_aoi_gate({object_update_update,UpdateObj}).
	
	
	

