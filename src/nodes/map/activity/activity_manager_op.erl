%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-3-29
%% Description: TODO: Add description to activity_manager_op
-module(activity_manager_op).

%%
%% Include files
%%
-include("common_define.hrl").
-include("activity_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
-export([init/0,on_check/0,check_is_time_line/2,check_is_time_line/4,
		 apply_join_activity/2,
		 apply_leave_activity/2,
		 apply_stoped_activity/2,
		 get_activity_state/1,
		 activity_forecast_check/3,
		 role_online_notify/1]).

%%
%% API Functions
%%
init()->
	answer_manager_op:init(),
	spa_manager_op:init(),
	dragon_fight_manager:init(),
	treasure_spawns_manager:init(),
	treasure_transport_manager:init(),
	InitState = lists:map(fun(ActivityId)-> {ActivityId,false,[],[]} end,lists:seq(1,?ACTIVITY_MAX_INDEX)),
	put(forecast_state,InitState),
	send_check_message().

send_check_message()->
	erlang:send_after(?CHECK_TIME,self(),{activity_check}).

on_check()->
	try
		server_travels_util:do_in_not_share_node(answer_manager_op,on_check,[])
	catch
		E_ANSWER:R_ANSWER->
			slogger:msg("answer_manager_op:on_check() error ~p ~p ~n ",
						[E_ANSWER,R_ANSWER]),
			error
	end,
	
	try
		server_travels_util:do_in_not_share_node(spa_manager_op,on_check,[])
	catch
		E_SPA:R_SPA->
			slogger:msg("spa_manager_op:on_check() error ~p ~p ~n ",
						[E_SPA,R_SPA]),
			error
	end,
%% 	try
%% 		treasure_spawns_manager:on_check()
%% 	catch
%% 		E_TREASURE:R_TREASURE->
%% 			slogger:msg("treasure_spawns_manager:on_check() ~p ~p ~p ~n ",
%% 						[E_TREASURE,R_TREASURE,erlang:get_stacktrace()]),
%% 			error
%% 	end,
	try
		server_travels_util:do_in_not_share_node(?MODULE,battle_check,[])
	catch
		E_BATTLE:R_BATTLE->
			slogger:msg("battle_check() ~p ~p ~p ~n ",
						[E_BATTLE,R_BATTLE,erlang:get_stacktrace()]),
			error
	end,
	try
		server_travels_util:do_in_not_share_node(dragon_fight_manager,on_check,[])
	catch
		E_DRAGON:R_DRAGON->
			slogger:msg("dragon_fight_manager:on_check() ~p ~p ~p ~n ",
						[E_DRAGON,R_DRAGON,erlang:get_stacktrace()]),
			error
	end,
	try
		server_travels_util:do_in_not_share_node(treasure_transport_manager,on_check,[])
	catch
		E5:R5->
			slogger:msg("treasure_transport_manager:on_check() ~p ~p ~p ~n ",[E5,R5,erlang:get_stacktrace()]),
			error
	end,
	send_check_message().

get_activity_state(?ANSWER_ACTIVITY)->
	answer_manager_op:get_activity_state();
get_activity_state(?SPA_ACTIVITY)->
	spa_manager_op:get_activity_state();
get_activity_state(_)->
	nothing.

apply_join_activity(?SPA_ACTIVITY,Info)->
	spa_manager_op:apply_join_activity(Info);
apply_join_activity(_,_)->
	nothing.

apply_leave_activity(?SPA_ACTIVITY,Info)->
	spa_manager_op:apply_leave_activity(Info);
apply_leave_activity(_,_)->
	nothing.

apply_stoped_activity(?ANSWER_ACTIVITY,Info)->
	answer_manager_op:on_stop_activity(Info);
apply_stoped_activity(?TEASURE_SPAWNS_ACTIVITY,Info)->
	treasure_spawns_manager:stoped(Info);
apply_stoped_activity(?SPA_ACTIVITY,Info)->
	spa_manager_op:apply_stop_me(Info);
apply_stoped_activity(_,_Info)->
	nothing.

%%return : {true,Line}/{false,[]}
check_is_time_line(?START_TYPE_DAY,StartLines)->
	check_is_time_line(?START_TYPE_DAY,StartLines,0,0).
check_is_time_line(?START_TYPE_DAY,StartLines,StartBuff_s,EndBuff_s)->
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	lists:foldl(fun(StartLine,{Re,_}=TmpLine)->
					if
						Re->
							TmpLine;
						true->
							case is_in_startline(Now,StartLine,StartBuff_s,EndBuff_s) of
								true->
									{true,StartLine};
								_->
									{false,[]}
							end
					end end,{false,[]}, StartLines).

is_in_startline(Now,StartLine,StartBuff_s,EndBuff_s)->
	{{NowY,NowM,NowD},{NowH,NowMin,_}} = Now,
	{{{_,_,_},{StartH,StartMin,_}},{{_,_,_},{EndH,EndM,_}}} = StartLine,
	NowSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{NowH,NowMin,0}}),
	StartSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{StartH,StartMin,0}})- StartBuff_s,
	EndSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{EndH,EndM,0}}) + EndBuff_s,
	(NowSecs >= StartSecs) and (NowSecs =< EndSecs).	
	%%leave enough time for activity(it will stop in EndTime+BUFFER_TIME_S)  

activity_forecast_check(Type,?START_TYPE_DAY,StartLines)->
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	lists:foldl(fun(StartLine,Re)->
					if
						Re->
							Re;
						true->
							{{{_,_,_},{StartH,StartMin,_}},{{_,_,_},{EndH,EndM,_}}} = StartLine,
							activity_forecast_check(Type,{StartH,StartMin,0},{EndH,EndM,0},Now)
					end end,false, StartLines);

activity_forecast_check(Type,?START_TYPE_WEEK,StartLines)->
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	{Today,_NowTime} = Now, 
	NowWeek = calendar:day_of_the_week(Today),
	lists:foldl(fun(StartLine,Re)->
					if
						Re->
							Re;
						true->
							{Week,{{_,_,_},{StartH,StartMin,_}},{{_,_,_},{EndH,EndM,_}}} = StartLine,
							if
								Week =:= NowWeek ->
									activity_forecast_check(Type,{StartH,StartMin,0},{EndH,EndM,0},Now);
								true->
									Re
							end
					end end,false, StartLines).
	
activity_forecast_check(Type,BeginTime,EndTime,Now)->
	{{NowY,NowM,NowD},{NowH,NowMin,NowSec}} = Now,
	{BeginH,BeginM,_} = BeginTime,
	{EndH,EndM,_} = EndTime,
	NowSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{NowH,NowMin,NowSec}}),
	StartSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{BeginH,BeginM,0}}),
	EndSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{EndH,EndM,0}}),
	CurState = get_forecast_state(Type),
	ForeCastTime = StartSecs - ?ACTIVITY_FORECAST_TIME_S,
	ForeCastBeginCheck = ((not CurState) and (NowSecs >= ForeCastTime) and (NowSecs < EndSecs)),
	ForeCastEndCheck = (CurState and (NowSecs >= EndSecs) and (NowSecs =< (EndSecs + ?CHECK_TIME/1000))),
	if
		ForeCastBeginCheck->	
			set_forecast_state(Type,true,BeginTime,EndTime),
			activity_forecast_begin(Type,BeginTime,EndTime);
		ForeCastEndCheck->
			activity_state_op:update_activity_state(),
			set_forecast_state(Type,false,[],[]),
			activity_forecast_end(Type);
		true->
			nothing
	end.
			
%%
%% Local Functions
%%
activity_forecast_begin(Type,BeginTime,EndTime)->
	{BeginH,BeginM,_} = BeginTime,
	{EndH,EndM,_} = EndTime,
	MessageBin = activity_packet:encode_activity_forecast_begin_s2c(
				Type,
				BeginH,
				BeginM,
				EndH,
				EndM),
	role_pos_util:send_to_all_online_clinet(MessageBin).
				
activity_forecast_end(Type)->
	MessageBin = activity_packet:encode_activity_forecast_end_s2c(Type),
	role_pos_util:send_to_all_online_clinet(MessageBin).

set_forecast_state(Type,State,BeginTime,EndTime)->
	StateList = get(forecast_state),
	NewStateList = lists:keyreplace(Type,1,StateList,{Type,State,BeginTime,EndTime}),
	put(forecast_state,NewStateList).

get_forecast_state(Type)->
	StateList = get(forecast_state),
	case lists:keyfind(Type,1,StateList) of
		false->
			false;
		{_,State,_,_}->
			State;
		_->
			false
	end.

battle_check()->
	TangleBattleInfoList = answer_db:get_activity_info(?TANGLE_BATTLE_ACTIVITY),
	CheckFun1 = fun(Info)->
				{Type,StartLines} = answer_db:get_activity_start(Info),
				activity_manager_op:activity_forecast_check(?TANGLE_BATTLE_ACTIVITY,Type,StartLines)
	end,
	lists:foreach(CheckFun1, TangleBattleInfoList),

	YhzqBattleInfoList = answer_db:get_activity_info(?YHZQ_BATTLE_ACTIVITY),
	CheckFun2 = fun(Info)->
				{Type,StartLines} = answer_db:get_activity_start(Info),
				activity_manager_op:activity_forecast_check(?YHZQ_BATTLE_ACTIVITY,Type,StartLines)
	end,
	lists:foreach(CheckFun2, YhzqBattleInfoList),

	Now = timer_center:get_correct_now(),
	LocalTime = calendar:now_to_local_time(Now),
	{Today,_NowTime} = LocalTime, 
	Week = calendar:day_of_the_week(Today),
	if
		Week=:=2;Week=:=4->
			JszdBattleInfoList = answer_db:get_activity_info(?JSZD_BATTLE_ACTIVITY),
			CheckFun3 = fun(Info)->
				{Type,StartLines} = answer_db:get_activity_start(Info),
				activity_manager_op:activity_forecast_check(?JSZD_BATTLE_ACTIVITY,Type,StartLines)
			end,
			lists:foreach(CheckFun3, JszdBattleInfoList);
		true->
			nothing
	end.

role_online_notify(RoleId)->
	lists:foreach(fun({Type,State,BeginTime,EndTime})->
					if
						State->
							{BeginH,BeginM,_} = BeginTime,
							{EndH,EndM,_} = EndTime,
							MessageBin = activity_packet:encode_activity_forecast_begin_s2c(
											Type,BeginH,BeginM,EndH,EndM),	
							role_pos_util:send_to_role_clinet(RoleId,MessageBin);
						true->
							nothing
					end
				end,get(forecast_state)).
	
	
		
	
