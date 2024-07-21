%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-8-26
%% Description: TODO: Add description to fatigue
-module(fatigue).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("login_pb.hrl").
-define(FATIGUE_CONTEXT,'$fatigue_context_value$').
-define(WARNING_TIMER_NAME,'$fatigue_timer_ref$').
-define(DEFAULT_CLEAR_RELEX_SECONDS,60*60*5).
-define(DEFAULT_GAIN_0PERCENT_SECONDS,60*60*5).
-define(DEFAULT_GAIN_50PERCENT_SECONDS,60*60*3).

-define(DEFAULT_ALERT_100PERCENT_INTERVAL_SECONDS,60*60). %%every hours
-define(DEFAULT_ALERT_50PERCENT_INTERVAL_SECONDS,30*60).  %%every 30min
-define(DEFAULT_ALERT_0PERCENT_INTERVAL_SECONDS,15*60).   %%every 15min

%%
%% Exported Functions
%%
-export([on_playeronline/1,on_playeroffline/0,
		get_gainrate/0,fatigue_message/1,set_adult/0,
		apply_get_gainrate/0,apply_set_adult/0,
		hook_online/1,hook_offline/0,
		apply_init/0,init/0,
		load_by_copy/1,export_for_copy/0]).


%%
%% API Functions
%%
init()->
	case env:get2(fatigue, disable, false) of
		true-> ignor;
		false->
			Module = env:get2(fatigue,version,fatigue),
			fatigue_apply(Module,apply_init,[])	
	end.
	
on_playeronline(Account)->
	case env:get2(fatigue, disable, false) of
		true-> ignor;
		false->
			Module = env:get2(fatigue,version,fatigue),
			fatigue_apply(Module,hook_online,[Account])	
	end.

on_playeroffline()->
	case env:get2(fatigue, disable, false) of
		true-> ignor;
		false->
			Module = env:get2(fatigue,version,fatigue),
			fatigue_apply(Module,hook_offline,[])	
	end.

set_adult()->
	Module = env:get2(fatigue,version,fatigue),
	fatigue_apply(Module,apply_set_adult,[]).

get_gainrate()->
	Module = env:get2(fatigue,version,fatigue),
	fatigue_apply(Module,apply_get_gainrate,[]).

load_by_copy(Info)->
	put(?FATIGUE_CONTEXT,Info).

export_for_copy()->
	get(?FATIGUE_CONTEXT).
%%
%% Local Functions
%%

apply_init()->
	case get(?FATIGUE_CONTEXT) of
		undefined->
			nothing;
		_->
			gen_next_warning()
	end.

hook_online(Account)->
	Now = timer_center:get_correct_now(),
	{A,B,_C} = Now,
	NowSecond = A * 1000000 + B,
	#fatigue{fatigue=FatigueTime,offline=OfflineTime,relex=Relex} = FatigueInfo = read_fatigue(Account,NowSecond),
	TempRelex = Relex + NowSecond- OfflineTime,
	ClearFatigueTime = env:get2(fatigue, clear_relex_seconds,?DEFAULT_CLEAR_RELEX_SECONDS),
	{NewRelex,NewFatigue} = if TempRelex>=ClearFatigueTime->
									{0,0};
								true->
									{TempRelex,FatigueTime}
							end,
	slogger:msg("on_playeronline ~p~n",[FatigueInfo#fatigue{relex=NewRelex}]),
	put(?FATIGUE_CONTEXT,{FatigueInfo#fatigue{fatigue=NewFatigue,relex=NewRelex},NowSecond}),
	send_regurl(),
	gen_first_warning().


hook_offline()->
	case get(?FATIGUE_CONTEXT) of
		undefined-> slogger:msg("adult on_playeroffline, ignor ~n"),ignor;
		{FatigueInfo,LoginTime} ->
			Now = timer_center:get_correct_now(),
			{A,B,_C} = Now,
			NowSecond = A * 1000000 + B,
			Gain0PercentSeconds =  env:get2(fatigue, gain_0percent_seconds,?DEFAULT_GAIN_0PERCENT_SECONDS),
			FatigueTime = erlang:min(FatigueInfo#fatigue.fatigue+ NowSecond -LoginTime,Gain0PercentSeconds),
			slogger:msg("on_playeroffline ~p~n",[FatigueInfo#fatigue{fatigue=FatigueTime}]),
			write_fatigue(FatigueInfo#fatigue{fatigue=FatigueTime,offline=NowSecond})
	end	.


gen_first_warning()->
	{FatigueInfo,LoginTime} = get(?FATIGUE_CONTEXT),
	Now = timer_center:get_correct_now(),
	{A,B,_C} = Now,
	NowSecond = A * 1000000 + B,
	FatigueTime = FatigueInfo#fatigue.fatigue+ NowSecond -LoginTime,
	Gain50PercentSeconds = env:get2(fatigue, gain_50percent_seconds, ?DEFAULT_GAIN_50PERCENT_SECONDS),
	Gain0PercentSeconds =  env:get2(fatigue, gain_0percent_seconds, ?DEFAULT_GAIN_0PERCENT_SECONDS),
	Alert100percentInterval = env:get2(fatigue, alert_100percent_interval,?DEFAULT_ALERT_100PERCENT_INTERVAL_SECONDS),
	Alert50percentInterval = env:get2(fatigue, alert_50percent_interval, ?DEFAULT_ALERT_50PERCENT_INTERVAL_SECONDS),
	Alert0percentInterval = env:get2(fatigue, alert_0percent_interval,?DEFAULT_ALERT_0PERCENT_INTERVAL_SECONDS),
	if FatigueTime< Gain50PercentSeconds -> 
		   if FatigueTime> 2*Alert100percentInterval ->
		   		gen_timer(0,prompt,get_prompt_msg(prompt_msg2));
			  FatigueTime> Alert100percentInterval ->
		   		gen_timer(0,prompt,get_prompt_msg(prompt_msg1));
			  true->
		   		InterlVal = (Alert100percentInterval-FatigueTime)*1000,
		   		gen_timer(InterlVal,prompt,get_prompt_msg(prompt_msg1))
		   end;
	   FatigueTime<Gain0PercentSeconds ->
		   gen_timer(0,alert,get_prompt_msg(alert_msg1));
	   true->
		   gen_timer(0,alert,get_prompt_msg(alert_msg2))
	end.
		
gen_next_warning()->
	{FatigueInfo,LoginTime} = get(?FATIGUE_CONTEXT),
	Now = timer_center:get_correct_now(),
	{A,B,_C} = Now,
	NowSecond = A * 1000000 + B,
	FatigueTime = FatigueInfo#fatigue.fatigue+ NowSecond -LoginTime,
	Gain50PercentSeconds = env:get2(fatigue, gain_50percent_seconds, ?DEFAULT_GAIN_50PERCENT_SECONDS),
	Gain0PercentSeconds =  env:get2(fatigue, gain_0percent_seconds, ?DEFAULT_GAIN_0PERCENT_SECONDS),
	Alert100percentInterval = env:get2(fatigue, alert_100percent_interval,?DEFAULT_ALERT_100PERCENT_INTERVAL_SECONDS),
	Alert50percentInterval = env:get2(fatigue, alert_50percent_interval, ?DEFAULT_ALERT_50PERCENT_INTERVAL_SECONDS),
	Alert0percentInterval = env:get2(fatigue, alert_0percent_interval,?DEFAULT_ALERT_0PERCENT_INTERVAL_SECONDS),
	if FatigueTime< Gain50PercentSeconds -> 
		   if FatigueTime>= 2*Alert100percentInterval ->
				Interval = (Gain50PercentSeconds - FatigueTime)* 1000,
				gen_timer(Interval,alert,get_prompt_msg(alert_msg1));
			  FatigueTime>= Alert100percentInterval ->
		   		gen_timer(Alert100percentInterval*1000,prompt,get_prompt_msg(prompt_msg2));
			  true->
		   		Interval = (Alert100percentInterval-FatigueTime)*1000,
		   		gen_timer(Interval,prompt,get_prompt_msg(prompt_msg1)) %% run here is exception
		   end;
	   FatigueTime<Gain0PercentSeconds ->
		    Dur = Gain0PercentSeconds-FatigueTime,
			if Dur=< Alert50percentInterval ->
				   Interval = erlang:max(Dur,Alert50percentInterval)*1000,
				   gen_timer(Interval,alert,get_prompt_msg(alert_msg2));
			   true->
				   Interval = erlang:min(Dur,Alert50percentInterval)*1000,
				   gen_timer(Interval,alert,get_prompt_msg(alert_msg1))
  			end;
	   true->
		   gen_timer(Alert0percentInterval*1000,alert,get_prompt_msg(alert_msg2))
	end.



apply_set_adult()->
	put(?FATIGUE_CONTEXT,undefined).
	
apply_get_gainrate()->
	case get(?FATIGUE_CONTEXT) of
		undefined-> 1;
		{FatigueInfo,LoginTime}->
			Now = timer_center:get_correct_now(),
			{A,B,_C} = Now,
			NowSecond = A * 1000000 + B,
			FatigueTime = FatigueInfo#fatigue.fatigue+ NowSecond -LoginTime,
			Gain50PercentSeconds = env:get2(fatigue, gain_50percent_seconds, ?DEFAULT_GAIN_50PERCENT_SECONDS),
			Gain0PercentSeconds =  env:get2(fatigue, gain_0percent_seconds, ?DEFAULT_GAIN_0PERCENT_SECONDS),
			GainRate = if FatigueTime< Gain50PercentSeconds -> 1;
						  FatigueTime<Gain0PercentSeconds -> 0.50;
						  true-> 0
					   end,			
			GainRate
	end.
	

read_fatigue(Account,NowSecond)->
	fatigue_db:read_fatigue(Account,NowSecond).

write_fatigue(FatigueInfo)->
	fatigue_db:write_fatigue(FatigueInfo).

gen_timer(AfterInterval,Type,Message)->
	free_timer(),
	case AfterInterval of
		0-> self()!{fatigue,{Type,Message}};
		_->
			case timer_util:send_after(AfterInterval, {fatigue,{Type,Message}}) of
				{ok,TimerRef}->put(?WARNING_TIMER_NAME,TimerRef);
				{error,_Reason}->error
			end
	end.

free_timer()->
	case get(?WARNING_TIMER_NAME) of
		undefined -> ignor;
		TimerRef -> timer_util:cancel_timer(TimerRef),
					put(?WARNING_TIMER_NAME,undefined)
  	end.

fatigue_message({Type,Message})->
	case Message of
		""-> ignor;
		_-> 
		case Type of
			alert-> 
				%%	slogger:msg("fatigue system ~p~n",[Message]),
					send_alert(Message);
			prompt->%% slogger:msg("fatigue system ~p~n",[Message]),
					 send_prompt(Message);
			_-> ignor
		end
	end,
	gen_next_warning().

send_regurl()->
	URL = env:get2(fatigue,goto_url ,[]),
	case URL of 
		[]-> ignor;
		_->	SendPack = #finish_register_s2c{gourl=URL},
			BinSend = login_pb:encode_finish_register_s2c(SendPack),
			role_op:send_data_to_gate(BinSend)
	end.

send_prompt(Message)->
	SendPack = #fatigue_prompt_s2c{prompt=Message},
	BinSend = login_pb:encode_fatigue_prompt_s2c(SendPack),
	role_op:send_data_to_gate(BinSend).
	
send_alert(Message)->
	SendPack = #fatigue_alert_s2c{alter=Message},
	BinSend = login_pb:encode_fatigue_alert_s2c(SendPack),
	role_op:send_data_to_gate(BinSend).
	
get_prompt_msg(Key)->
	env:get2(fatigue, Key ,<<"">>).

fatigue_apply(M,F,A)->
	try
		erlang:apply(M,F,A)
	catch
		E:R->
			slogger:msg("fatigue_apply M:~p F:~p A: ~p ~n E:~p R:~p S:~p ~n",[M,F,A,E,R,erlang:get_stacktrace()])
	end.