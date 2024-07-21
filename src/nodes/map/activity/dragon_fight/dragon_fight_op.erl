%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(dragon_fight_op).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports

-compile(export_all).

%% gen_server callbacks
-include("data_struct.hrl").
-include("activity_define.hrl").
-include("dragon_fight_define.hrl").
-include("system_chat_define.hrl").

-define(TIME_FOR_SYNC,10000).
%%cur_state:not_start->running->end

init({Id,StartLine,Duration})->
	TreasureInfo = dragon_fight_db:get_info(Id),
	QuestId = dragon_fight_db:get_relation_questid(TreasureInfo),
	RedBuff = dragon_fight_db:get_red_dragon_buff(TreasureInfo),
	BlueBuff = dragon_fight_db:get_blue_dragon_buff(TreasureInfo),
	Pos = dragon_fight_db:get_start_pos(TreasureInfo),
	put(blue_faction,[]),
	put(red_faction,[]),
	put(running_state,false),
	put(realation_questid,QuestId),
	put(red_dragon_buff,RedBuff),
	put(blue_dragon_buff,BlueBuff),
	put(winner,[]),
	put(has_rewards,[]),
	put(start_pos,Pos),
	put(duration,Duration),
	random:seed(now()),
	{{_,{StartH,StartMin,_}},_} = StartLine,
	NowDate = calendar:now_to_local_time(timer_center:get_correct_now()),
	{Today,_} = NowDate,
	NowSecs = calendar:datetime_to_gregorian_seconds(NowDate),
	StartSecs = calendar:datetime_to_gregorian_seconds({Today,{StartH,StartMin,0}}),
	LeftTime =  max(StartSecs - NowSecs,0),
	erlang:send_after(LeftTime*1000,self(),start_dragon_fight).

start()->
	put(running_state,true),
	put(start_time,now()),
	erlang:send_after(?TIME_FOR_SYNC,self(),{left_time_check}),
	Message = dragon_fight_packet:encode_dragon_fight_start_s2c(trunc(get(duration)/1000)),
	role_pos_util:send_to_all_online_clinet(Message),
	sys_broad_cast(start,[]).

left_time_check()->
	LeftTime_ms = get(duration) - trunc(timer:now_diff(now(), get(start_time) )/1000),
	if
		LeftTime_ms =< 1000-> 			%%less than 1s
			stop();
		true->
			adjust_time(trunc(LeftTime_ms/1000)),
			if
				LeftTime_ms >= ?TIME_FOR_SYNC->
					erlang:send_after(?TIME_FOR_SYNC,self(),{left_time_check});
				true->
					erlang:send_after(LeftTime_ms,self(),{left_time_check})
			end
	end.

adjust_time(LeftTime_S)->
	Message = dragon_fight_packet:encode_dragon_fight_left_time_s2c(LeftTime_S),
	role_pos_util:send_to_all_online_clinet(Message).

stop()->
	LengthBlue = length(get(blue_faction)),
	LengthRed = length(get(red_faction)),
	if
		LengthBlue=:=LengthRed ->
			put(winner,0);						%%
		LengthBlue>LengthRed->
			put(winner,?DRAGON_FIGHT_FACTION_RED);
		true->
			put(winner,?DRAGON_FIGHT_FACTION_BLUE)
	end,
	broad_cast_to_blue({dragon_fight_stop,get(blue_dragon_buff)}),
	broad_cast_to_red({dragon_fight_stop,get(red_dragon_buff)}),
	Message = dragon_fight_packet:encode_dragon_fight_end_s2c(LengthRed,LengthBlue,get(winner)),
	role_pos_util:send_to_all_online_clinet(Message),
	put(running_state,game_over).

apply_join(RoleId)->
	case get(running_state) of
		true->
			{MapId,X,Y} = get(start_pos),
			role_pos_util:send_to_role(RoleId,{gm_move_you,MapId,X,Y});
		_->
			nothing
	end.

%%{finish quest,remove buff}/nothing:not join /fighting:not end
role_online({RoleId})->
	case get(running_state) of
		game_over->			%%online when game_over
			case lists:member(RoleId, get(has_rewards)) of
				true->
					nothing;
				_->
					BlueCkeck = lists:member(RoleId,get(blue_faction)),
					RedCkeck = lists:member(RoleId,get(red_faction)),
					if
						BlueCkeck->
							{true,get(blue_dragon_buff)};
						RedCkeck->
							{true,get(red_dragon_buff)};
						true->
							nothing
					end
			end;
		true->
			case lists:member(RoleId,get(blue_faction)) or lists:member(RoleId,get(red_faction)) of
				true->
					fighting;
				_->			%%not join
					LeftTime_S = trunc((get(duration) - trunc(timer:now_diff(now(), get(start_time) )/1000))/1000),
					Message = dragon_fight_packet:encode_dragon_fight_start_s2c(LeftTime_S),
					role_pos_util:send_to_role_clinet(RoleId,Message),
					nothing
			end;
		_->
			nothing
	end.

get_user_result(RoleId)->
	put(has_rewards,[RoleId|get(has_rewards)]),
	MyFaction = 
		case lists:member(RoleId,get(blue_faction)) of
			true->
				?DRAGON_FIGHT_FACTION_BLUE;
			_->
				case lists:member(RoleId,get(red_faction)) of
					true->
						?DRAGON_FIGHT_FACTION_RED;
					_->
						0
				end
		end,
	if
		MyFaction=:=0->
			slogger:msg("not join in dragon_fight but call user_result!!!! roleid ~p ~n",[RoleId]),
			?USER_RESULT_NOT_JOIN;
		true->		
			case get(winner) of
				[]->
					slogger:msg("dragon_fight not end but call user_result !!! roleid ~p ~n",[RoleId]),
					error;
				0->
					?USER_RESULT_HALF;
				MyFaction->
					?USER_RESULT_WIN;
				_->
					?USER_RESULT_LOSE
			end
	end.

%%return ?DRAGON_NPC_STATE_NOTSTART/?DRAGON_NPC_STATE_IN_FACTION/{?DRAGON_NPC_STATE_NOTIN_FACTION,realation_questid}
get_state_for_faction({RoleId,Faction})->
	HasInFaction = 
	case Faction of
		?DRAGON_FIGHT_FACTION_BLUE->
			lists:member(RoleId,get(blue_faction));
		?DRAGON_FIGHT_FACTION_RED->
		 	lists:member(RoleId,get(red_faction))
	end,
	case get(running_state) of
		true->
			if
				HasInFaction->
					?DRAGON_NPC_STATE_IN_FACTION;
				true->
					{?DRAGON_NPC_STATE_NOTIN_FACTION,get(realation_questid)}
			end;
		false->
			?DRAGON_NPC_STATE_NOTSTART;
		_->
			?DRAGON_NPC_STATE_END
	end.

get_faction_num(FactionType)->
	case get(running_state) of
		true->
			case FactionType of
				?DRAGON_FIGHT_FACTION_BLUE->
					length(get(blue_faction));
				?DRAGON_FIGHT_FACTION_RED->
					length(get(red_faction));
				_->
					0
			end;
		_->
			error
	end.

%%return :{removebuff,addbuff}
change_faction({RoleId,?DRAGON_FIGHT_FACTION_BLUE})->
	case get(running_state) of
		true->
			case lists:member(RoleId,get(blue_faction)) of
				true->
					nothing;
				_->
					put(red_faction,lists:delete(RoleId, get(red_faction))),
					put(blue_faction,[RoleId|get(blue_faction)]),
					{get(red_dragon_buff),get(blue_dragon_buff)}
			end;
		_->
			error
	end;
change_faction({RoleId,?DRAGON_FIGHT_FACTION_RED})->
	case get(running_state) of
		true->
			case lists:member(RoleId,get(red_faction)) of
				true->
					nothing;
				_->
					put(blue_faction,lists:delete(RoleId, get(blue_faction))),
					put(red_faction,[RoleId|get(red_faction)]),
					{get(blue_dragon_buff),get(red_dragon_buff)}
			end;
		_->
			error
	end;
change_faction(_)->
  	error.

broad_cast_to_blue(Msg)->
	lists:foreach(fun(RoleId)->
			role_pos_util:send_to_role(RoleId,Msg)
	end,get(blue_faction)).
broad_cast_to_red(Msg)->	
	lists:foreach(fun(RoleId)->
			role_pos_util:send_to_role(RoleId,Msg)
	end,get(red_faction)).

sys_broad_cast(start,_)->
	system_chat_op:system_broadcast(?SYSTEM_CHAT_DRAGON_FIGHT_START,[]),
	todo;

sys_broad_cast(Type,Info)->
	nothing.
		
	
		