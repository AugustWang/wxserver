%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_action).

-include("common_define.hrl").
-include("ai_define.hrl").
-include("data_struct.hrl").
-include("npc_struct.hrl").

-compile(export_all).

%%last_action_backup:{action_state,targetid,pos,travel_path}
init()->
	put(targetid,0),
	put(action_timer,0),
	put(action_state,?ACTION_IDLE),
	put(last_action_backup,[]).

change_to_attck(NewEnemyId)->
%%	io:format("change_to_attck ~p get(action_state) ~p ~n",[NewEnemyId,get(action_state)]),
	%%attack from idle or follow
	backup_action_states_on_attack(get(action_state)),
	put(targetid,NewEnemyId),
	put(action_state,?ACTION_ATTACK_TARGET).

change_to_follow(NewFollowId)->
	put(targetid,NewFollowId),
	put(action_state,?ACTION_FOLLOW_TARGET).

change_to_runaway()->
	put(targetid,0),
	put(action_state,?ACTION_RUN_AWAY).

on_reset_get_return_pos()->
	put(targetid,0),
	put(action_state,?ACTION_RESET),
%%	io:format("on_reset_get_return_pos ~p ~n",[get(last_action_backup)]),
	case get(last_action_backup) of
		[]->
			get(bornposition);
		{_Action_state,_Targetid,Pos,_Travel_path}->
			Pos
	end.

set_state_to_idle()->
	put(targetid,0),
	put(action_state,?ACTION_IDLE).

on_reset_finish()->
	Last_action_backup = get(last_action_backup), 
	put(last_action_backup,[]),
	case Last_action_backup of
		[]->
			npc_op:call_duty();
		{?ACTION_IDLE,_CurTarget,_CurPos,TravelPath}->
		  	put(travel_path,TravelPath),
			npc_op:call_duty();
		{?ACTION_FOLLOW_TARGET,CurTarget,_CurPos,_TravelPath}->
			npc_op:start_follow_creature(CurTarget)
	end.

get_now_action()->
	get(action_state).

clear_now_action()->
	set_action_timer(0).

set_action_timer(NewTimer)->
	case get(action_timer)of
		0->
			put(action_timer,NewTimer);
		Timer->
			gen_fsm:cancel_timer(Timer),
			put(action_timer,NewTimer)
	end.

%%local

backup_action_states_on_attack(?ACTION_IDLE)->
	CurTarget = 0,
	CurPos = get_pos_from_npcinfo(get(creature_info)),
	TravelPath = get_path_from_npcinfo(get(creature_info)) ++ get(travel_path),
	put(last_action_backup,{?ACTION_IDLE,CurTarget,CurPos,TravelPath});

backup_action_states_on_attack(?ACTION_FOLLOW_TARGET)->
	CurTarget = get(targetid),
	CurPos = get_pos_from_npcinfo(get(creature_info)),
	TravelPath = [],
	put(last_action_backup,{?ACTION_FOLLOW_TARGET,CurTarget,CurPos,TravelPath});
	
backup_action_states_on_attack(_LastActionState)->
	nothing.
	

	
	
	
	