%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_movement).

-include("common_define.hrl").
-include("ai_define.hrl").
-include("data_struct.hrl").
-include("npc_struct.hrl").

-compile(export_all).

init(PositionType,PositionValue)->
	put(postype,PositionType),
	put(waypoint,PositionValue),
	put(move_timer,0),
	%% once path find's result
	put(travel_path,[]).

start_idle_walk()->
	%%io:format("start_idle_walk ~n"),
	case get(postype) of
		?MOVE_TYPE_POINT ->
			npc_op:switch_to_gaming_state(get(id));
		_->
			Timer = gen_fsm:send_event_after(0, {start_idle_walk}),
			set_move_timer(Timer)
	end.
	
proc_idle_walk()->	
	npc_op:change_to_speed(walkspeed),
	CurrentInfo = get(creature_info),
	CurPos = get_pos_from_npcinfo(CurrentInfo),
	case get(travel_path) of
		[]->
			Travel_Path = idle_walk_path_find(CurPos),
			put(travel_path,Travel_Path);
		Travel_Path->
			nothing
	end,
	move_request(get(creature_info),Travel_Path).

move_to_point(Pos)->
	Pos_my = get_pos_from_npcinfo(get(creature_info)),
	Travel_Path =  npc_ai:path_find(Pos_my,Pos),
	put(travel_path,Travel_Path),
	move_request(get(creature_info),Travel_Path).

move_request(_,[])->
	on_move_finished();
move_request(SelfInfo,WholePath) ->
	case length(WholePath) >= ?PATH_POIN_NUMBER of
		true->
			{NewMovePath,LeftWholePath} = lists:split(?PATH_POIN_NUMBER, WholePath);
		_->
			LeftWholePath = [],NewMovePath = WholePath 
	end,		
	put(travel_path,LeftWholePath),
	clear_now_move(),
	creature_op:move_notify_aoi_roles(SelfInfo, NewMovePath),
	put(creature_info, set_path_to_npcinfo(SelfInfo,NewMovePath)),
	npc_op:update_npc_info(get(id),get(creature_info)),
	[NextPos|_T] = NewMovePath, 
	Speed = get_speed_from_npcinfo(SelfInfo),												
	RunTime = erlang:trunc(1000/Speed)*?PATH_POIN_NUMBER,
	Timer = erlang:send_after(RunTime, self(), {move_heartbeat, NextPos}),
	set_move_timer(Timer).

move_heartbeat(NpcInfo, MapInfo, Pos) ->		
	case npc_op:can_move(NpcInfo) of
		true ->
			case get_path_from_npcinfo(NpcInfo) of
				[Pos|_]->
					MoveRe = creature_op:move_heartbeat(NpcInfo, MapInfo, Pos),
					case on_move_pos_keep_on(Pos) of
						true->
							case MoveRe of
								{moving, RemainPath} ->		
									[NextPos|_T] = RemainPath,
									Speed = get_speed_from_npcinfo(NpcInfo),												
									RunTime = erlang:trunc(1000/Speed)*?PATH_POIN_NUMBER,								
									Timer = erlang:send_after(RunTime, self(), {move_heartbeat, NextPos}),
									set_move_timer(Timer);
								gaming ->	%%notify path move end,continue
									move_request(get(creature_info),get(travel_path))					
							end;
						_->
							nothing
					end;
				_->
					%%io:format("move_heartbeat error Pos ~p Path ~p ~n",[Pos,get_path_from_npcinfo(get(creature_info))]),
					nothing
			end;
		false ->	%% can't move,try again
				CommonCool = get_commoncool_from_npcinfo(NpcInfo),
				Timer = erlang:send_after(CommonCool, self(), {move_heartbeat, Pos}),
				set_move_timer(Timer)
	end.

stop_move()->
	clear_now_move(),
	notify_stop_move().

clear_now_move()->
	set_move_timer(0),
	set_path_to_npcinfo(get(creature_info),[]).

notify_stop_move() ->
	StopMsg = role_packet:encode_move_stop_s2c(get(id),get_pos_from_npcinfo(get(creature_info))),									       
	npc_op:broadcast_message_to_aoi_client(StopMsg).

%% full find path move end
on_move_finished()->
	case npc_action:get_now_action() of
		?ACTION_IDLE->			%% idle
			nothing;
		?ACTION_RESET->	%% reset finish
			util:send_state_event(self(), {reset_fin});
		?ACTION_ATTACK_TARGET->			%% move to attack
			npc_action:clear_now_action(),
			npc_op:move_to_attack();
		?ACTION_FOLLOW_TARGET->
			npc_action:clear_now_action(),
			npc_op:follow_target();
		?ACTION_RUN_AWAY->
			npc_action:set_state_to_idle()
	end.

%% return true/false to continue move
on_move_pos_keep_on(Pos)->
	case npc_action:get_now_action() of
		?ACTION_IDLE->						%% idle
			ContinueMove = true;
		?ACTION_RESET->				%% reset
			ContinueMove = true;
		?ACTION_ATTACK_TARGET->			%% move to attack
			{_SkillId,SkillTargetId} = get(next_skill_and_target),
			EnemyInfo = creature_op:get_creature_info(SkillTargetId),
			ContinueMove = not npc_op:stop_move_in_attack(EnemyInfo,Pos);
		?ACTION_FOLLOW_TARGET->
			TargetId = get(targetid),
			TargetInfo = creature_op:get_creature_info(TargetId),
			ContinueMove = not npc_op:stop_move_in_follow(TargetInfo,Pos);
		?ACTION_RUN_AWAY->
			ContinueMove = true
	end,
	ContinueMove.				

set_move_timer(NewTimer)->
	case get(move_timer)of
		0->
			put(move_timer,NewTimer);
		Timer->
			erlang:cancel_timer(Timer),
			put(move_timer,NewTimer)
	end.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				local		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idle_walk_path_find(CurPos)->
	case get(postype) of
		?MOVE_TYPE_AREA->  
			position_area_function(get(waypoint),CurPos);
		?MOVE_TYPE_PATH -> 						
			position_path_function(get(waypoint),CurPos);						
		?MOVE_TYPE_POINT-> 
			position_point_function(get(waypoint),CurPos)
	end.

position_point_function(_PosContext,_CurPos)->
	[].

position_path_function(PosContext,CurPos)->
	split_full_path_to_point(list_util:trunk(PosContext, CurPos)).

position_area_function(_PosContext,_CurPos)->
	todo,
	[].

split_full_path_to_point([])->
	[];
split_full_path_to_point(Path)->
	lists:reverse(split_full_path_to_point(Path,1,[])).
split_full_path_to_point([Point],_,[Point|_]=ResultPath)->
	ResultPath;
split_full_path_to_point([Point],_,ResultPath)->
	[Point|ResultPath];
split_full_path_to_point([Point|T],Num,[Point|_]=ResultPath)->
	split_full_path_to_point(T,Num,ResultPath);
split_full_path_to_point([Point|T],Num,ResultPath)->
	if
		((Num - 1) rem ?PATH_POIN_NUMBER) =:= 0->
			split_full_path_to_point(T,Num+1,[Point|ResultPath]);
		true->
			split_full_path_to_point(T,Num+1,ResultPath)
	end.
			
	
