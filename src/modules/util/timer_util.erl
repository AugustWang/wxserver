%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-include("common_define.hrl").
-include("activity_define.hrl").
-module(timer_util).
-define(DAYS_FROM_0_TO_1970, 719528).
-define(SECONDS_PER_DAY, 86400).
-export([send_after/2,
		 send_after/3,
		 cancel_timer/1,
		 check_is_overdue/3,get_time_compare_trunc/1,
		 check_sec_is_in_timeline_by_day/2,check_dateline/1,check_dateline_by_range/1,
		 get_natural_days_from_now/1,
		 check_same_day/2,
		 is_in_time_point/3]).
-compile(export_all).		 
		 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 姣忛棿闅擭绉掑彂閫佷竴娆�, 涓�鍏盡绉�, 濡傛灉涓嶈兘鐩镐簰鏁撮櫎, 鍒欏彇鍚戜笅琛ラ綈鐨勫師鍒�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
send_interval2(N, M, Msg) ->
	Times = gm_math:floor(M / N),
	Send_event = fun(X) ->
				     timer:send_after(X, Msg)
		     end,
	lists:foreach(Send_event, lists:seq(0, Times, N)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 姣忛棿闅擭绉掑彂閫佷竴娆＄姸鎬佷簨浠�, 涓�鍏盡绉�, 濡傛灉涓嶈兘鐩镐簰鏁撮櫎, 鍒欏彇鍚戜笅琛ラ綈鐨勫師鍒�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
send_state_event_interval(N, M, Msg) ->
	Times = gm_math:floor(M / N),
	Send_event_after = fun(X) ->
					   gen_fsm:send_event_after(X, Msg)
			   end,
	lists:foreach(Send_event_after, lists:seq(0, Times, N)).
	
send_after(Time,Message)->
	try
		TimeRef = erlang:send_after(trunc(Time),self(),Message),
		{ok,TimeRef}
	catch
		_:R-> {error,R}
	end.
	
send_after(Time,Pid,Message)->
	try
		TimeRef = erlang:send_after(trunc(Time),Pid,Message),
		{ok,TimeRef}
	catch
		_:R-> {error,R}
	end.
	
cancel_timer(TimeRef)->
	erlang:cancel_timer(TimeRef).

check_is_overdue(?DUE_TYPE_DAY,{ClearH,ClearMin,ClearSec},FristTime)->
	NowTime = timer_center:get_correct_now(),
	NowDate = calendar:now_to_local_time(NowTime),
	FirstDate = calendar:now_to_local_time(FristTime),
	{{FirstY,FirstM,FirstD},{FirstH,FirstMin,FirstSec}} = FirstDate, 
	{{NowY ,NowM,NowD},{NowH,NowMin,NowSec}} = NowDate,
	if
		(FirstY < NowY) or  (FirstM < NowM) or (NowD > FirstD + 1)->
			true;
		true->
			if
				NowD >= FirstD->
					FirstSecs = {{FirstY,FirstM,FirstD},{FirstH,FirstMin,FirstSec}},
					NowSecs = {{NowY ,NowM,NowD},{NowH,NowMin,NowSec}},
					(
					(compare_datatime(FirstSecs,{{FirstY,FirstM,FirstD},{ClearH,ClearMin,ClearSec}})=:=true) and
					(compare_datatime({{FirstY,FirstM,FirstD},{ClearH,ClearMin,ClearSec}},NowSecs)=:=true)
					)
					or
					(
					(compare_datatime(FirstSecs,{{NowY ,NowM,NowD},{ClearH,ClearMin,ClearSec}})=:=true ) and
					(compare_datatime({{NowY ,NowM,NowD},{ClearH,ClearMin,ClearSec}},NowSecs)=:=true )	 
					 );
				true->
					false
			end
	end.	

check_sec_is_in_timeline_by_day(CheckTime,TimeLine) ->
	{{{_,_,_},StartHourMinSec},EndTime} = TimeLine,
	is_in_time_point({{0,0,0},StartHourMinSec},EndTime,CheckTime).
	
check_dateline(DateLines)->
	if
		DateLines =:= []->
			true;
		true->
			NowTime = calendar:now_to_local_time(timer_center:get_correct_now()),
			check_dateline(NowTime,DateLines)
	end.
	
check_dateline(NowTime,DateLines)->	
	lists:foldl(fun({BeginTime,EndTime},Result)->
	if
		Result->
			true;
		true->
			is_in_time_point(BeginTime,EndTime,NowTime)
	end end,false,DateLines).	

check_dateline_by_range(DateLines)->
	if
		DateLines =:= []->
			true;
		true->
			NowTime = calendar:now_to_local_time(timer_center:get_correct_now()),
			lists:foldl(fun({BeginTime,EndTime},Result)->
						if
							Result->
								true;
							true->
								is_in_time_point(BeginTime,EndTime,NowTime)
						end end,false,DateLines)
	end.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%								鍒ゆ柇褰撳墠鏃堕棿鏄惁鍦ㄤ袱涓椂闂寸偣涔嬮棿 is_in_time_point
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%濡傛灉璧峰骞存湀鏃ヤ负0,鍒欏彧鍒ゆ柇鏃跺垎绉�.
is_in_time_point({{0,0,0},BeginHourMinSec}=_StartTime,{_,EndHourMinSec}=_EndTime,{_,NowHourMinSec}=_NowTime)->
	(compare_time(BeginHourMinSec,NowHourMinSec)=/=false)
	and	
	(compare_time(NowHourMinSec,EndHourMinSec)=/=false);
is_in_time_point(StartTime,EndTime,NowTime)->
	(compare_datatime(StartTime,NowTime) =/= false)
	and
	(compare_datatime(NowTime,EndTime) =/= false).	


%%鐢ㄤ簬涓�涓椂闂寸偣涓庝护涓�涓椂闂寸偣鐨勫厛鍚庢瘮杈�		
%%杩斿洖true(Time2澶т簬Time1)/false(Time2灏忎簬Time1)/equal(Time2绛変簬Time1)
compare_datatime({YearMonthDay1,HourMinSec1},{YearMonthDay2,HourMinSec2})->
	case compare_time(YearMonthDay1,YearMonthDay2) of
		true->			
			true;
		equal->			%%涓や釜鏃堕棿鐐瑰湪鍚屼竴澶�,妫�娴嬫椂鍒嗙
			compare_time(HourMinSec1,HourMinSec2);
		false->
			false
	end.	

%%鐢ㄤ簬骞存湀鏃�/鏃跺垎绉掔殑姣旇緝
%%杩斿洖true(Time2澶т簬Time1)/false(Time2灏忎簬Time1)/equal(Time2绛変簬Time1)
compare_time({A1,B1,C1},{A2,B2,C2})->
	if
		A2>A1->
			true;
		A2=:=A1->
			if
				B2>B1->
					true;
				B2=:=B1->
					if
						C2>C1->
							true;
						C2=:=C1->
							equal;
						true->
							false
					end;		
				true->
					false
			end;			
		true->
			false
	end.

get_time_compare_trunc({hour,CompareTime})->
	CheckTime = calendar:now_to_local_time(CompareTime),
	NowTime = calendar:now_to_local_time(timer_center:get_correct_now()),
	CheckSecs = calendar:datetime_to_gregorian_seconds(CheckTime),
	NowSecs = calendar:datetime_to_gregorian_seconds(NowTime),
	if
		NowSecs > CheckSecs->
			MiddleSecs = NowSecs - CheckSecs,
			erlang:trunc(MiddleSecs/3600);
		true->
			0
	end;

get_time_compare_trunc({min,CompareTime})->
	CheckTime = calendar:now_to_local_time(CompareTime),
	NowTime = calendar:now_to_local_time(timer_center:get_correct_now()),
	CheckSecs = calendar:datetime_to_gregorian_seconds(CheckTime),
	NowSecs = calendar:datetime_to_gregorian_seconds(NowTime),
	if
		NowSecs > CheckSecs->
			MiddleSecs = NowSecs - CheckSecs,
			erlang:trunc(MiddleSecs/60);
		true->
			0
	end;

get_time_compare_trunc({day,CompareTime})->
	CheckTime = calendar:now_to_local_time(CompareTime),
	NowTime = calendar:now_to_local_time(timer_center:get_correct_now()),
	CheckSecs = calendar:datetime_to_gregorian_seconds(CheckTime),
	NowSecs = calendar:datetime_to_gregorian_seconds(NowTime),
	if
		NowSecs > CheckSecs->
			MiddleSecs = NowSecs - CheckSecs,
			erlang:trunc(MiddleSecs/86400);
		true->
			0
	end.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鍙栧緱褰撳墠鏃堕棿涓庝紶鍏ュ弬鏁版椂闂寸殑鑷劧澶╅棿闅旀暟锛屽弬鏁版槸Unix鏃堕棿鎴�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
get_natural_days_from_now(CheckTime)->
	{NowDate,_NowTime} = calendar:now_to_local_time(timer_center:get_correct_now()),
	NowDays = calendar:date_to_gregorian_days(NowDate),
	{CheckDate,_CheckTime} = CheckTime,
	CheckDays = calendar:date_to_gregorian_days(CheckDate),
	if
		NowDays > CheckDays->
			NowDays - CheckDays;
		true->
			0
	end.
%%
%% 
%%

%%
%%妫�娴嬩袱涓椂闂存槸鍚︿负鍚屼竴澶�
%%
%% T1 = T2 = {X,Y,Z}
%% return true | false
check_same_day(T1,T2)->
	{Date1,_} = calendar:now_to_local_time(T1),
	{Date2,_} = calendar:now_to_local_time(T2),
	Date1 =:= Date2.
	
%%
%% 娲诲姩鏃堕棿妫�鏌�
%%
check_is_time_line(?START_TYPE_DAY,TimeLines,BuffTime)->
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	lists:foldl(fun({StartLine,EndLine},Re)->
					if
						Re->
							Re;
						true->
							is_in_startline(Now,StartLine,EndLine,BuffTime)
					end end,false, TimeLines);

check_is_time_line(?START_TYPE_WEEK,TimeLines,BuffTime)->
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	{Today,_NowTime} = Now, 
	Week = calendar:day_of_the_week(Today),
	lists:foldl(fun({Day,StartLine,EndLine},Re)->
					if
						Re->
							Re;
						true->
							if
								Week =:= Day ->
									is_in_startline(Now,StartLine,EndLine,BuffTime);
								true->
									false
							end
					end end,false, TimeLines);

check_is_time_line(_,_,_)->
	false.
  
is_in_startline(Now,StartLine,EndLine,BuffTime)->
	{{NowY,NowM,NowD},{NowH,NowMin,_}} = Now,
	{{_,_,_},{StartH,StartMin,_}} = StartLine,
	{{_,_,_},{EndH,EndMin,_}} = EndLine,
	NowSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{NowH,NowMin,0}}),
	StartSecs = calendar:datetime_to_gregorian_seconds({{NowY ,NowM,NowD},{StartH,StartMin,0}}) - BuffTime,
	EndSecs = calendar:datetime_to_gregorian_seconds({{NowY ,NowM,NowD},{EndH,EndMin,0}}),
	(NowSecs >= StartSecs) and (NowSecs < EndSecs + 2*BuffTime).		

%%鏃堕棿鏍煎紡convert to now by zhangting
datetime_to_now(DateTime)->
	seconds_to_now(calendar:datetime_to_gregorian_seconds(DateTime)).

%%绉抍onvert to now by zhangting
seconds_to_now(SecsNow) ->
    Dlocal= calendar:universal_time_to_local_time({{1970, 1, 1},{0,0,0}}),  %褰撳湴1970骞�
    D1970 = calendar:datetime_to_gregorian_seconds(Dlocal),
	SecsNew=SecsNow-D1970,
	Tmp1=1000*1000,
	Val = trunc(SecsNew/Tmp1),
	{Val,(SecsNew-Val*Tmp1),0}.


time11()  ->
    integer_to_list(current_seconds()).

current_seconds()  ->
    %褰撴椂鏃堕棿
    Dlocal= calendar:universal_time_to_local_time({{1970, 1, 1},{0,0,0}}),  %褰撳湴1970骞�
    D1970 = calendar:datetime_to_gregorian_seconds(Dlocal),
    Nlocal= calendar:local_time(),
    Now   = calendar:datetime_to_gregorian_seconds(Nlocal),
    Now - D1970.

































  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  