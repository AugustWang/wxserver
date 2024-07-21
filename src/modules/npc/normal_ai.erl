%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(normal_ai).

-compile(export_all).

-include("npc_define.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("base_define.hrl").
-include("ai_define.hrl").
-include("map_info_struct.hrl").

%%action
talk_to_target(MyWordsBin)->
	case get(targetid) of
		0->
			nothing;
		RoleId->
			case creature_op:get_creature_info(RoleId) of
				?ERLNULL->
					nothing;
				CreatureInfo->
					MyWords = util:safe_binary_to_list(MyWordsBin), 
					RoleName = util:safe_binary_to_list(creature_op:get_name_from_creature_info(CreatureInfo)),
					ShoutDialog = list_util:replace(MyWords,"#n",RoleName),
					npc_ai:speak_to_role(RoleId,ShoutDialog)
			end
	end.

say(BinOriDialogues)->
	OriDialogues = util:safe_binary_to_list(BinOriDialogues),
	Dialogues = 
	case list_util:is_part_of("#n",OriDialogues) of
		true->
			case creature_op:get_nearest_role_from_aoi() of
				0->
					OriDialogues;
				RoleId->
					case creature_op:get_creature_info(RoleId) of
						?ERLNULL->
							nothing;
						CreatureInfo->
							RoleName = util:safe_binary_to_list(creature_op:get_name_from_creature_info(CreatureInfo)),
							list_util:replace(OriDialogues,"#n",RoleName)
					end
			end;
		_->
			OriDialogues
	end,
	npc_ai:speak_to_aoi(Dialogues).

let_other_say(NpcId,Dialogues)->
	case creature_op:get_creature_info(NpcId) of
		?ERLNULL->
			nothing;
		CreatureInfo->
			npc_processor:let_other_say(creature_op:get_pid_from_creature_info(CreatureInfo),Dialogues)	
	end.
	
stop_move()->
	npc_movement:stop_move().

wait()->
	nothing.

move()->
	npc_movement:start_idle_walk().	

move_to(Pos)->
	self() ! {run_away_to_pos,Pos}.

give_self_buff(BuffList)->
	give_target_buff(get(id),BuffList).	
give_target_buff(BuffList)->
	give_target_buff(get(targetid),BuffList).	
give_target_buff(Id,BuffList)->	
	creature_op:process_buff_list(get(creature_info),Id, 0, BuffList). 

update_touchred()->
	EnemyId = get(targetid),
	npc_op:update_touchred_into_selfinfo(EnemyId),
	npc_op:broad_attr_changed([{touchred,EnemyId}]).

summon_creature_in_pos(?AI_SUMMON_POS_TYPE_MY,NpcIds)->
	Pos = creature_op:get_pos_from_creature_info(get(creature_info)),
	creature_op:call_creature_spawns_with_pos(NpcIds,Pos,{?CREATOR_LEVEL_BY_SYSTEM,get(id)});

summon_creature_in_pos(?AI_SUMMON_POS_TYPE_DEAFUALT,NpcIds)->
  	creature_op:call_creature_spawns(NpcIds,{?CREATOR_LEVEL_BY_SYSTEM,get(id)}).

summon_creature_in_pos_auto_level(?AI_SUMMON_POS_TYPE_MY,NpcIds)->
	MyLevel = creature_op:get_level_from_creature_info(get(creature_info)),
	Pos = creature_op:get_pos_from_creature_info(get(creature_info)),
	creature_op:call_creature_spawns_with_pos(NpcIds,Pos,{MyLevel,get(id)});

summon_creature_in_pos_auto_level(?AI_SUMMON_POS_TYPE_DEAFUALT,NpcIds)->
	MyLevel = creature_op:get_level_from_creature_info(get(creature_info)),
	creature_op:call_creature_spawns(NpcIds,{MyLevel,get(id)}).

summon_creature_by_proto(ProtoId)->
	MyPos = creature_op:get_pos_from_creature_info(get(creature_info)),
	creature_op:call_creature_spawn_by_create(ProtoId,MyPos,{?CREATOR_LEVEL_BY_SYSTEM,get(id)}).

summon_creature_by_proto(ProtoId,Pos)->
	creature_op:call_creature_spawn_by_create(ProtoId,Pos,{?CREATOR_LEVEL_BY_SYSTEM,get(id)}).

%%æ·»åŠ é‡‘é“¶æ®¿å‰¯æœ¬åˆ›å»ºç”Ÿç‰©å‡½æ•°
summon_creature_by_proto_auto_level(?A1_SUMMON_POS_TY_BY_PROTO,CreaturesInfos)->
	[Creatures|C]=CreaturesInfos,
	ProtoId=element(1,Creatures),
	Num=element(2,Creatures),
	Poss=element(3,Creatures),
	MyLevel=creature_op:get_level_from_creature_info(get(creature_info)),
	lists:map(fun(Pos)->
					  creature_op:call_creature_spawn_by_create(ProtoId,Pos,{MyLevel,get(id)})  end, Poss).
													 	
send_selfdef_event_to(Event,NpcIds)->
	lists:foreach(fun(NpcId)->
		npc_op:send_to_creature(NpcId,{call_ai_event,Event})
	end, NpcIds).

stop_instance()->
	Proc = get_proc_from_mapinfo(get(map_info)),
	map_processor:destroy_instance(node(),Proc).

stop_instance(WaitTime)->
	Proc = get_proc_from_mapinfo(get(map_info)),
	map_processor:destroy_instance(node(),Proc,WaitTime).

leave_map_after_second(Time)->
	erlang:send_after(Time*1000, self(),{forced_leave_map}).

copy_master_all_hatred()->
	hatred_op:copy_other_all_enemyid_list(get(creator_id)).	

copy_master_one_hatred()->
	hatred_op:copy_other_one_enemyid(get(creator_id)).

clear_hatred()->
	npc_hatred_op:clear().

%%condition
selfhp_less_than(Value)->
	get_life_from_npcinfo(get(creature_info)) =< Value.

selfhppercent_less_than(Value)->
	NpcInfo = get(creature_info),
	get_life_from_npcinfo(NpcInfo) =< (get_hpmax_from_npcinfo(NpcInfo) * Value / 100).

enemysnum_more_than(Value)->
	hatred_op:get_enemy_num() >= Value.

enemylevel_bigger_than(Value)->
	creature_op:get_level_from_creature_info(creature_op:get_creature_info(get(targetid))) >= Value.

battletime_more_than(Value)->
	npc_op:get_join_battle_time_micro_s()>=Value*1000.

is_has_dead(CreatureList)->
	lists:foldl(fun(CreatureId,Re)->
					if
						Re->
							true;
						true->
							is_other_dead(CreatureId)
					end end, false, CreatureList).

is_other_dead(CreatureId)->
	creature_op:is_creature_dead(creature_op:get_creature_info(CreatureId)).
	
%%
%%random
%%
run_away_normal()->
	todo.

%%
%% opposite direction
%%
run_away_boss()->
	todo.
	
	
