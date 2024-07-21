%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(series_kill).

-export([init/0,export_for_copy/0,load_by_copy/1,on_other_killed/1,on_offline/0,get_cur_series_kill_num/0]).
-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("login_pb.hrl").
-include("common_define.hrl").
-include("creature_define.hrl").
-include("system_chat_define.hrl").
-include("string_define.hrl").
-define(DEFAULT_DELAY_TIME,200).  %% delay DEFAULT_DELAY_TIME ms than client

%%series_kill_info:{last_series_kill_time,cur_level,cur_num,max_num_recode}

init()->
	put(series_kill_info,{{0,0,0},1,0,0}).
	
export_for_copy()->
	get(series_kill_info).

load_by_copy(Info)->
	put(series_kill_info,Info).

on_other_killed(_OtherId)->
	0.
	
on_other_killed_outdated(OtherId)->
	case creature_op:what_creature(OtherId) of
		npc->
			case creature_op:get_creature_info(OtherId) of
				undefined->
					get_cur_series_kill_num();
				NpcInfo->
					case get_npcflags_from_npcinfo(NpcInfo) of
						?CREATURE_MONSTER->
							Level = get_level_from_npcinfo(NpcInfo),
							{_,Cur_level,_,_} = get(series_kill_info),
							case series_kill_db:get_series_kill_info(Cur_level) of	
								[]->  %% may be the config error
									slogger:msg("get series_kill_info faild level ~p !~n",[Cur_level]),
									get_cur_series_kill_num();
								SeriesProtoInfo->
									case ((get_level_from_roleinfo(get(creature_info)) - Level) =< series_kill_db:get_npc_level_diff(SeriesProtoInfo)) of
										true->
											do_series_kill();
										false->
											get_cur_series_kill_num()
									end
							end;
						_->
							get_cur_series_kill_num()
					end
			end;
		_->
			get_cur_series_kill_num()
	end.

%%%local fun	check_time,add_kills,broad_cast,add_buff
do_series_kill()->
	Now = timer_center:get_correct_now(),
	{LastTime,Cur_level,CurNum,MaxSeriesNum} = get(series_kill_info),
	SeriesProtoInfo = series_kill_db:get_series_kill_info(Cur_level),
	Eff_Time = series_kill_db:get_effect_time(SeriesProtoInfo), 
	NextLevelNum= series_kill_db:get_kill_num(SeriesProtoInfo),
	NewNum = CurNum+1,
	LastTimes = (timer:now_diff(Now,LastTime)) div 1000000,
	case (LastTimes =< Eff_Time) of
		true->			%% success
			case NewNum >= NextLevelNum of
				true-> 		%% level up
					level_up(Cur_level,NewNum);
				false->
					update_series_kill_success(Cur_level,NewNum)
			end,
%% 			achieve_op:achieve_update({series_kill},[0],NewNum),
			NewNum;
		false->		%%time out
			update_role_record(),
			reset_series_kill_info(Now),
			1
	end.
get_cur_series_kill_num()->
	0.

get_cur_series_kill_num_outdated()->
	Now = timer_center:get_correct_now(),
	{LastTime,Cur_level,CurNum,MaxSeriesNum} = get(series_kill_info),
	case series_kill_db:get_series_kill_info(Cur_level) of
		[]->
			reset_series_kill_info(),
			0;
		SeriesProtoInfo->
			Eff_Time = series_kill_db:get_effect_time(SeriesProtoInfo),
			case ((timer:now_diff(Now,LastTime)- ?DEFAULT_DELAY_TIME*1000)/1000000 =< Eff_Time ) of
				true ->
					CurNum;
				false->
					update_role_record(),
					reset_series_kill_info(),
					0
			end		
	end.
	
	  
reset_series_kill_info()->
	{LastTime,_,_,Max_recode} = get(series_kill_info),
	put(series_kill_info,{LastTime,1,0,Max_recode}).

reset_series_kill_info(Now)->
	{_,_,_,Max_recode} = get(series_kill_info),
	put(series_kill_info,{Now,1,1,Max_recode}).

level_up(Cur_level,KillNum)->
	NewLevel = Cur_level+1,
	case series_kill_db:get_series_kill_info(NewLevel) of
		[]->   %% cannot get new level info
			slogger:msg("get series_kill_info faild level ~p !~n",[Cur_level]),
			{_,_,_,MaxSeries} = get(series_kill_info),
			put(series_kill_info,{timer_center:get_correct_now(),Cur_level,KillNum,MaxSeries});
		SeriesKillInfo->
			{_,_,_,MaxSeries} = get(series_kill_info),
			put(series_kill_info,{timer_center:get_correct_now(),NewLevel,KillNum,MaxSeries}),
			world_broad_cast(get(creature_info),Cur_level),
			add_series_kill_buff(Cur_level)
	end.	
			
	

update_series_kill_success(Level,KillNum)->
	{_,_,_,MaxSeries} = get(series_kill_info),
	put(series_kill_info,{timer_center:get_correct_now(),Level,KillNum,MaxSeries}).

update_role_record()->
	{LastTime,Cur_level,CurNum,MaxSeriesNum} = get(series_kill_info),
	if
		CurNum>MaxSeriesNum->
			gm_logger_role:role_batter(get(roleid),CurNum,get(level)),
			put(series_kill_info,{LastTime,Cur_level,CurNum,CurNum});
		true->
			nothing
	end.

on_offline()->
	update_role_record().
	
world_broad_cast(RoleInfo,Level)->
	BrdType = get_brd_type(Level),
	BrdMsg =  get_brd_args(Level),
	case BrdMsg of
		[]->
			nothing;
		_->			
			ParamRole = system_chat_util:make_role_param(RoleInfo),
			ParamString = system_chat_util:make_string_param(BrdMsg),
			MsgInfo = [ParamRole,ParamString],
			system_chat_op:system_broadcast(BrdType,MsgInfo)
	end.

add_series_kill_buff(Level)->
	case series_kill_db:get_series_kill_info(Level) of
		[]->
			nothing;
		SeriesProtoInfo->
			Buffs = series_kill_db:get_buff_info(SeriesProtoInfo),
			role_op:add_buffers_by_self([Buffs])
	end.

get_brd_args(Level)->
	case Level of
		3->
			%%"ä¸‰ç™¾";
			language:get_string(?STR_SERIES_KILL_THREE_HUNDREDS);
		4->
			%%"å››ç™¾";
			language:get_string(?STR_SERIES_KILL_FOUR_HUNDREDS);
		5->
			%%"äº”ç™¾";
			language:get_string(?STR_SERIES_KILL_FIVE_HUNDREDS);
		6->
			%%"å…­ç™¾";
			language:get_string(?STR_SERIES_KILL_SIX_HUNDREDS);
		7->
			%%"ä¸ƒç™¾";
			language:get_string(?STR_SERIES_KILL_SEVEN_HUNDREDS);
		8->
			%%"å…«ç™¾";
			language:get_string(?STR_SERIES_KILL_EIGHT_HUNDREDS);
		9->
			%%"ä¹ç™¾æ–©";	
			language:get_string(?STR_SERIES_KILL_NINE_HUNDREDS);
		_->
			[]
	end.
	
get_brd_type(Level)->
	case Level of
		3->
			?SYSTEM_CHAT_SERIES_KILL_300;
		4->
			?SYSTEM_CHAT_SERIES_KILL_400;
		5->
			?SYSTEM_CHAT_SERIES_KILL_500;
		6->
			?SYSTEM_CHAT_SERIES_KILL_600;
		7->
			?SYSTEM_CHAT_SERIES_KILL_700;
		8->
			?SYSTEM_CHAT_SERIES_KILL_800;
		9->
			?SYSTEM_CHAT_SERIES_KILL_900;	
		_->
			[]
	end.	
			


