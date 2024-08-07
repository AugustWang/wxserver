%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
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
		NpcId >= ?DYNAMIC_NPC_INDEX->				%%鍔ㄦ�乶pc
			erlang:send_after(?DYNAMIC_NPC_LIFE_TIME,self(),{forced_leave_map});
		true->	
			nothing
	end,
	ProtoId = npc_db:get_spawn_protoid(NpcSpawnInfo),
	OriBorn = npc_db:get_spawn_bornposition(NpcSpawnInfo),
	Action_list = npc_db:get_spawn_actionlist(NpcSpawnInfo),
	RespawnTime = npc_db:get_spawn_retime(NpcSpawnInfo),
	%%璁剧疆閲嶇敓淇℃伅
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
	%%鍒濆鍖栦粐鎭ㄥ垪琛�
	npc_hatred_op:init(),
	buffer_op:init(),
	%%鐗规畩甯哥敤瀛楀吀
	
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
	
%%妫�鏌ヨ嚜宸辨墍鍦ㄦ牸鏄惁鍐峰嵈,濡傛灉鍐峰嵈涓攏pc鍙浼戠湢,杩涘叆浼戠湢鐘舵��
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
	
%%gaming鐘舵�佹椂琚紤鐪�
hibernate()->
	case get(can_hibernate) of
		true->
			case get(hibernate_tag) of
				false->		%%鏈紤鐪�
					put(hibernate_tag,true),
					clear_all_action();		
				true->
					nothing
			end;
		_->
			nothing
	end.	
			

%%婵�娲�
activate()->
	case get(hibernate_tag) of
		false->
			nothing;
		_->	%%浼戠湢涓�,婵�娲�
			put(hibernate_tag,false),
			perform_creature_duty()
	end.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 澶勭悊NPC鐨勮鎴掗�昏緫
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
start_alert()->
	case is_active_monster() of
		true ->
			Timer = gen_fsm:send_event_after(?NPC_ALERT_TIME, {alert_heartbeat}),
			npc_action:set_action_timer(Timer);
		false->
			nothing
	end.
	
%%鍒ゆ柇Aoi鍒楄〃閲屾槸鍚︽湁鐜╁杩涘叆浜嗚鎴掕寖鍥�
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
		true ->				%%鎵惧埌aoi鏈�杩戠殑鏁屼汉
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
%% NPC璺熼殢鐨勭Щ鍔�
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
				true->			%%鎵ц鑷繁鐨勭洰鏍囦涪澶辫剼鏈�
					nothing;
				_->
					erlang:send(self(), {leave_map})
			end,
			StopMove = true
	end,
	StopMove.
				
	
%%todo澶勭悊涓嶅湪鍚屼竴鍦板浘鍜岃妭鐐逛笂鐨刦ollow	
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
%% NPC鏀诲嚮鐨勭Щ鍔�
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
%% NPC鏀诲嚮閫夋嫨
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
			%%娓呯┖涔嬪墠鐨勭洰鏍囧拰鎶�鑳�
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
		
	
%%閫夋嫨鎶�鑳�
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
		{SkillId,TargetId} ->			%%濡傛灉宸茬粡閫夋嫨浜嗘妧鑳斤紝浣嗘槸涓婃鏀诲嚮娌℃斁鍑烘潵锛屼笉閲嶆柊閫夋嫨銆�
			{_,SkillLevel,_} = lists:keyfind(SkillId,1,get_skilllist_from_npcinfo(MyInfo)),
			SkillInfo = skill_db:get_skill_info(SkillId,SkillLevel),
			AttackRange = skill_db:get_max_distance(SkillInfo),
			put(attack_range,AttackRange),
			{SkillId,SkillLevel,TargetId}
	end.

%%鎶�鑳介噴鏀惧畬姣曪紝娓呴櫎	
update_skill(end_attack)->
	put(attack_range,?DEFAULT_ATTACK_RANGE),
	put(next_skill_and_target,{0,0}).	
	
set_join_battle_time()->
	case get(join_battle_time) of
		{0,0,0}->			%%鍒氳繘鍏ユ垬鏂�
			Ralations = get(hatreds_relations),
			%%浠囨仺鍏宠仈
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
%% attack TODO:杩斿洖鐘舵��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
attack(OriEnemyId)->
	%%choose skill->inrange->attack/move_to_attack
	MyInfo = get(creature_info),
	OriEnemyInfo = creature_op:get_creature_info(OriEnemyId),	
	case not creature_op:is_creature_dead(OriEnemyInfo) of
		true->
			set_join_battle_time(),
			%%鍙栨妧鑳藉拰鐩爣
			MySkill = update_skill(begin_attack,MyInfo,OriEnemyInfo),
			AttackDiffTime = erlang:trunc(timer:now_diff(now(), get(last_cast_time))/1000),
			CommonCool = get_commoncool_from_npcinfo(MyInfo),
			case AttackDiffTime >= CommonCool of 			%%妫�鏌ュ叕鍏卞喎鍗存椂闂�
				false ->				
					WaitTime =  CommonCool - AttackDiffTime,
					Timer = gen_fsm:send_event_after(WaitTime, {attack_heartbeat}),
					npc_action:set_action_timer(Timer);    %%杩囦細鍐嶆墦
				true ->	
					case (MySkill=/=[]) of
						false -> 								%%鏈彇鍒板彲鐢ㄦ妧鑳� ,杩囦細鍐嶇湅				
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
									case npc_ai:is_in_attack_range(Pos_my,Pos_Enemy) or (get(attack_range) =:= 0) of          %%鏌ョ湅鏄惁鍦ㄦ敾鍑昏寖鍥村唴    
										false ->
												npc_action:clear_now_action(),
												find_path_and_move_to(Pos_my,Pos_Enemy,get(attack_range));
										true ->								%%閲婃斁鎶�鑳斤紒
												NextState = start_attack(SkillId,SkillLevel,TargetInfo),
												case NextState of
													attack -> 				%%宸茬粡鎵撲簡涓�涓嬶紝寰呬細鍐嶆墦										
														Timer = gen_fsm:send_event_after(CommonCool, {attack_heartbeat}),
														update_skill(end_attack),
														npc_action:set_action_timer(Timer);
													singing ->				%%甯屾浖锛岃祼浜堟垜鍔涢噺鍚�......
														%%涓嶇浣犲悷鍞辨垚涓嶆垚,鏈夋湪鏈夎鎵撴柇,鎮插偓鐨勭瓥鍒掕姹�,浣犺繖涓凡缁忕畻浣跨敤杩囦簡(ps:涓庝汉鐗╀笉鍚�)
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
%% 鍙戣捣鏀诲嚮%%涓嶇浣犲悷鍞辨垚涓嶆垚,浣犺繖涓凡缁忕畻浣跨敤杩囦簡(涓庝汉鐗╀笉鍚�),闇�瑕佽缃喎鍗�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_attack(SkillID,SkillLevel,TargetInfo) ->
	SelfId = get(id),
	SkillInfo = skill_db:get_skill_info(SkillID,SkillLevel),
	%% 鑾峰彇鐢熺墿鐨勪俊鎭�
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
					%%鍙猵ut,涓嶉渶瑕乽pdate鍚屾鍒癳ts
					put(creature_info, set_skilllist_to_npcinfo(get(creature_info),NewSkillList)),
					NextState = singing;
				true ->
					%% 澶勭悊椤哄彂鏀诲嚮					
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
			%%鍏堥�氱煡浠栦滑鐨勫鎴风琚敾鍑讳簡
			AttackMsg = role_packet:encode_be_attacked_s2c(SelfId,SkillId,Units,FlyTime),                                                     			
			broadcast_message_to_aoi_client(AttackMsg),
			%%鏈嶅姟鍣ㄤ笂闇�瑕佹牴鎹甪lytime寤惰繜璁＄畻浼ゅ
			damages_broadcast(FlyTime,SelfId,Units);
		false ->
			nothing
	end.  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鑷繁琚墦浜�(鏈夊彲鑳芥槸鎴樺＋鍙嶄激!) return:deading(琚墦姝讳簡)/{be_attacked,Hatred}(浠囨仺)/nothing:鏃犱粐鎭ㄥ鐞�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
other_be_attacked({EnemyId, _, _, Damage, SkillId,SkillLevel}, SelfInfo) ->
	SelfId = get_id_from_npcinfo(SelfInfo),
	SkillInfo = skill_db:get_skill_info(SkillId,SkillLevel),
	case npc_script:run_script(be_attacked,[EnemyId,SkillId,SkillLevel,Damage]) of
		[]->			%%鏃犺鏀诲嚮鑴氭湰
			OtherInfo = creature_op:get_creature_info(EnemyId),
			case OtherInfo =:= undefined of
				 false->
				 	creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_BEATTACK),
					case get_npcflags_from_npcinfo(SelfInfo) of				
						?CREATURE_COLLECTION->	%%閲囬泦鐗╀綋
							update_touchred_into_selfinfo(EnemyId),
							on_dead(OtherInfo),
							deading;	
						?CREATURE_YHZQ_NPC-> %%姘告亽涔嬫棗鐗规畩鐗╁搧
							{be_attacked,0};	
						_->						%%闈為噰闆嗙墿浣撹蛋鎴樻枟娴佺▼
							case get_touchred_from_npcinfo(get(creature_info)) of
								0 -> 			
									%%娌℃湁鏌撶孩锛岃缃煋绾�,閫氱煡鍛ㄥ洿浜烘煋绾�
									case creature_op:what_creature(EnemyId) of
										role->		
											update_touchred_into_selfinfo(EnemyId),
											npc_op:broad_attr_changed([{touchred,EnemyId}]);
										_->
											nothing
									end;
								_ ->			%%鏈夋煋绾�
									nothing
							end,
							Life = erlang:max(get_life_from_npcinfo(get(creature_info)) + Damage, 0),			
							put(creature_info, set_life_to_npcinfo(get(creature_info), Life)),
							case Life =< 0 of
								true ->
									on_dead(OtherInfo),
									deading;
								false ->
									%%澶勭悊鍑忚
									SkillHared = skill_db:get_addtion_threat(SkillInfo),
									update_npc_info(SelfId, get(creature_info)),
									npc_op:broad_attr_changed([{hp,Life}]),
									case npc_action:get_now_action() of
										?ACTION_RUN_AWAY->
											%%閫冭窇涓嶅弽鍑�
											nothing;
										_->	
											%%杩斿洖浠囨仺,浠ヤ緵鍙嶅嚮锛宒amage*rate + skillhared
											Rates = creature_op:get_hatredratio_from_creature_info(OtherInfo),		%%浠囨仺姣旂巼
											{be_attacked,-erlang:trunc(Damage*Rates) + SkillHared}
									end
							end
					end;
				true ->
					nothing
			end;
		ScriptResult->			%%琚敾鍑昏剼鏈�
			ScriptResult
	end.	
	
%%
%%aoi閲屾湁浜鸿鏉�	
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
	npc_action:set_action_timer(Timer).%%缁х画鏀诲嚮

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
%%娣诲姞Buffer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
be_add_buffer(NewAddBuffersOri,CasterInfo) ->
	NewAddBuffers = lists:ukeysort(1,NewAddBuffersOri),
	NpcId = get(id),
	%% 澶勭悊Buffer鐨勮鐩栨儏鍐�
	Fun = fun({BufferID, BufferLevel},{TmpNewBuffer,TmpRemoveBuffer}) ->
			      case lists:keyfind(BufferID, 1, get(current_buffer)) of
				      false ->
					      %% 璇uff娌℃湁琚姞杩囷紝鎵�浠ュ彲浠ュ姞					      		      
					      {TmpNewBuffer++[{BufferID, BufferLevel}],TmpRemoveBuffer};					      
				      {_, OldBufferLeve} ->
					      case BufferLevel > OldBufferLeve of
						      false ->
							      %% 鍔犺繃,鏂癇uff鐨勭骇鍒綆
							      {TmpNewBuffer,TmpRemoveBuffer};
						      true ->
							      %% 鍔犺繃锛屼絾鏄柊Buff鐨勭骇鍒珮
								  remove_without_compute({BufferID, OldBufferLeve}),							    
							      {TmpNewBuffer ++ [{BufferID, BufferLevel}],TmpRemoveBuffer ++ [{BufferID, OldBufferLeve}]}
					      end
			      end
	      end,   	      	      
	{NewBuffers2,RemoveBuff} = lists:foldl(Fun,{[],[]},NewAddBuffers),
	case (RemoveBuff =/= []) or (NewBuffers2 =/= []) of
		true->			
				%% 璁剧疆Buffer缁橬pc閫犳垚鐨勭姸鎬佹敼鍙�
			lists:foreach(fun({BufferID, BufferLevel}) ->
						      BufferInfo = buffer_db:get_buffer_info(BufferID, BufferLevel),
						      put(creature_info, buffer_extra_effect:add(get(creature_info),BufferInfo))
				      end, NewBuffers2),
			%% 瑙﹀彂鐢盉uffer瀵艰嚧鐨勪簨浠�
		 	lists:foreach(fun({BufferID, BufferLevel}) ->						 									
					     	buffer_op:generate_interval(BufferID, BufferLevel, 0,timer_center:get_correct_now(),CasterInfo)
			      end, NewBuffers2 ),				      	 		      		     								
			%%鏇存柊
			put(creature_info,set_buffer_to_npcinfo(get(creature_info),get(current_buffer))),
			%% 骞挎挱涓簡Buff鐨勬秷鎭�
			Buffers_WithTime = lists:map(fun({BufferID, BufferLevel}) ->  
					BufferInfo = buffer_db:get_buffer_info(BufferID, BufferLevel),
					DurationTime = buffer_db:get_buffer_duration(BufferInfo),
					{BufferID, BufferLevel,DurationTime} end,NewBuffers2),
			Message3 = role_packet:encode_add_buff_s2c(NpcId, Buffers_WithTime),
			broadcast_message_to_aoi_client(Message3),
			recompute_attr(NewBuffers2,RemoveBuff),
			put(current_buffer, lists:ukeymerge(1, NewBuffers2, get(current_buffer))),
			%%骞挎挱鍋滄绉诲姩,浣唗imer涓嶈兘鍋�.move_heartbeat閲屼細鑷姩妫�娴嬭兘鍚︾Щ鍔�
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
%% 绉婚櫎buffer
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
			buffer_op:remove_buffer(BufferId), %% 浠嶣uffer瀹氭椂鍣ㄤ腑鍒犻櫎璇ufferID
			put(current_buffer, lists:keydelete(BufferId, 1, get(current_buffer))),
			%%鏇存柊creature info
			BufferInfo2 = buffer_db:get_buffer_info(BufferId, BufferLevel),
			put(creature_info,buffer_extra_effect:remove(NpcInfo,BufferInfo2)),
			put(creature_info,set_buffer_to_npcinfo(get(creature_info),get(current_buffer))),
			%%鍙戦��
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
	%%搴旂敤灞炴�ф敼鍙�
	put(current_attribute, NewAttributes),
	NewInfo = lists:foldl(fun(Attr,Info)->					
				 	role_attr:to_creature_info(Attr,Info)
				 end,OriInfo,ChangeAttribute),
	put(creature_info,NewInfo),
	update_npc_info(SelfId,get(creature_info)),
	%%鍙戦�佸睘鎬ф敼鍙�
	ChangeAttribute_Hp_Mp = role_attr:preform_to_attrs(ChangeAttribute),
	npc_op:broad_attr_changed(ChangeAttribute_Hp_Mp).		 

can_move(NpcInfo) ->
	ExtState = get_extra_state_from_npcinfo(NpcInfo),
	Freezing = lists:member(freezing,ExtState ), 	%%鍐板喕
	Coma = lists:member(coma,ExtState),			%%鏄忚糠
	IsDeading = creature_op:is_creature_dead(NpcInfo),
	not (Freezing or Coma or IsDeading ).  
	
can_attack(NpcInfo,TargetInfo)->
	ExtState = get_extra_state_from_npcinfo(NpcInfo),
	Coma = lists:member(coma,ExtState),			%%鏄忚糠
	God = lists:member(god,ExtState),			%%鏃犳晫
	OtherGod = combat_op:is_target_god(TargetInfo),
	not (God or Coma or OtherGod).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Buffer End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%						 绂诲紑鍦板浘
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc_leave_map()->
	creature_op:leave_map(get(creature_info),get(map_info)),
	RespawnTime = npc_op:get_next_respawn_time(),
	if
		RespawnTime =/= 0->						
			Timer = gen_fsm:send_event_after(RespawnTime, {respawn}), %%绂诲紑鍦板浘涓�浼氬悗閲嶇敓
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


%% 缁欑敱Listeners鎸囧畾瑙掕壊鍙戦�佷俊鎭�
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
%% 琚寫琛�!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
provoke(ProvokerId)->
	%%璁剧疆鍙敾鍑�
	put(creature_info, set_npcflags_to_npcinfo(get(creature_info), ?CREATURE_MONSTER)),
	%%璁剧疆浠囨仺
	HatredOp = get(hatred_fun),
	npc_hatred_op:HatredOp(is_attacked,{ProvokerId,?HELP_HATRED}),	
	%%璁剧疆鏌撶孩
	update_touchred_into_selfinfo(ProvokerId),
	%%閫氱煡鐘舵�佸彉鍖�
	npc_op:broad_attr_changed([{touchred,ProvokerId},{creature_flag,?CREATURE_MONSTER}]),
	%%鍘诲共浠�!
	update_attack().
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 閫冭窇
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run_away()->
	todo_find_pos.
%%鑴辨垬,閫冭窇
run_away_to_pos(Pos)->
	%%娓呴櫎褰撳墠琛屽姩
	clear_all_action(),
	%%娓呴櫎浠囨仺鍒楄〃
	npc_hatred_op:clear(),
	put(attack_range,?DEFAULT_ATTACK_RANGE),
	put(next_skill_and_target,{0,0}),
	%%娓呴櫎褰撳墠鐩爣,璁剧疆閫冭窇琛屼负
	npc_op:broad_attr_changed([{targetid,0}]),
	npc_action:change_to_runaway(),	
	npc_movement:move_to_point(Pos),
	%%涓嶈浼樺寲,闃叉璧板埌鏈縺娲诲尯鍩熻鍋滀綇
	put(can_hibernate,false),
	switch_to_gaming_state(get(id)).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 姝讳骸
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
on_dead(KillerInfo)->
	EnemyId = creature_op:get_id_from_creature_info(KillerInfo),
	EnemyName = creature_op:get_name_from_creature_info(KillerInfo),
	NpcInfo = get(creature_info),
	case npc_action:get_now_action() of
		?ACTION_IDLE->			%%鐩存帴琚
			npc_action:change_to_attck(EnemyId);
		_->
			nothing
	end,	
	MyPos = get_pos_from_npcinfo(NpcInfo),	
	%%鍒犻櫎buff
	creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_DEAD),
	%%鏇存柊褰撳墠鐘舵��
	put(creature_info,set_buffer_to_npcinfo(get(creature_info),[])),
	put(creature_info, set_state_to_npcinfo(get(creature_info), deading)),
	update_npc_info(get(id),get(creature_info)),
	%%澶勭悊姝讳骸浜嬩欢
	npc_ai:handle_event(?EVENT_DIED),
	%%閫氱煡姝讳骸
	broadcast_message_to_aoi({other_be_killed, {get(id),EnemyId,EnemyName ,0,MyPos}}),
	%%鎺夎惤
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
		true->																	%%鎬墿瓒翠竴浼氬悗绂诲紑鍦板浘
			gen_fsm:send_event_after(?DEAD_LEAVE_TIME, {leavemap});				
		false->																	%%绔嬪埢绂诲紑
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
				is_integer(RespawnTmp)->		%%閲嶇敓鏃堕棿鐨勯殢鏈哄垪琛�
					lists:nth(random:uniform(erlang:length(OriRespawnTime)),OriRespawnTime);
				true->								%%[閲嶇敓鏃堕棿鐐箋鏃�,鍒�,绉拀]
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
	%%鍒濆鍖栬矾寰�
	Pos_born = get_next_respawn_pos(),
	update_touchred_into_selfinfo(0),
	%%娓呯┖鏌撶孩
	npc_hatred_op:clear(),
	%%琛�钃濆洖婊�
	Life = get_hpmax_from_npcinfo(get(creature_info)),
	Mp = get_mpmax_from_npcinfo(get(creature_info)), 
	put(creature_info, set_npcflags_to_npcinfo(get(creature_info), get(orinpcflag))),
	put(creature_info, set_life_to_npcinfo(get(creature_info), Life)),
	put(creature_info, set_mana_to_npcinfo(get(creature_info), Mp)),
	put(creature_info, set_pos_to_npcinfo(get(creature_info), Pos_born)),
	put(creature_info, set_state_to_npcinfo(get(creature_info), gaming)),
	put(creature_info, set_speed_to_npcinfo(get(creature_info),get(walk_speed))),
	update_npc_info(get(id),get(creature_info)),
	%%鍒濆鍖栧姩浣�
	npc_action:init(),
	%%娓呴櫎鎶�鑳界洰鏍�
	put(next_skill_and_target,{0,0}),
	put(attack_range,?DEFAULT_ATTACK_RANGE),
	%%娓呴櫎鎴樻枟鏃堕棿	
	clear_join_battle_time(),
	put(ownnerid,0),
	%%ai閲嶇疆
	npc_ai:respawn(),
	put(bornposition,Pos_born),
	%%骞挎挱
	MyName = get_name_from_npcinfo(get(creature_info)),
	NpcProtoId = get_templateid_from_npcinfo(get(creature_info)),
	MapId = get_mapid_from_mapinfo(get(map_info)),
	LineId = get_lineid_from_mapinfo(get(map_info)),
	creature_sysbrd_util:sysbrd({monster_born,server_travels_util:is_share_server(),NpcProtoId},{LineId,MapId,MyName}).
	
clear_all_action()->	
	%娓呴櫎ai_timer
	npc_ai:clear_act(),
	%%娓呴櫎绉诲姩timer
	npc_movement:clear_now_move(),
	%%娓呴櫎琛屽姩timer
	npc_action:clear_now_action().
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% resset Npc idle,back to born,status recover
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
npc_reset()->
	%%娓呴櫎buff
	creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_DEAD),
	clear_all_action(),
	%%娓呯┖鏌撶孩
	update_touchred_into_selfinfo(0),
	npc_hatred_op:clear(),
	clear_join_battle_time(),
	Pos_my = get_pos_from_npcinfo(get(creature_info)),
	Pos_born = npc_action:on_reset_get_return_pos(),
	Path = npc_ai:path_find(Pos_my,Pos_born),
	%%琛�閲忓洖婊�
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

%%杞彉璧板Э鎬�
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

%%杞彉璺戝Э鎬�
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
	
	
	

