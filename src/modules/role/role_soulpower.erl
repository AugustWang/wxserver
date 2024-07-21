%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-2-15
%% Description: TODO: Add description to role_soulpower
-module(role_soulpower).

%%
%% Include files
%%

-include("data_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("little_garden.hrl").
-include("role_struct.hrl").

-define(SENDDELAYTIME,1).
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%

init([])->
	SoulPowerLevelInfo = role_level_soulpower_db:get_info(get(level)),	
	MaxPower = role_level_soulpower_db:get_maxpower(SoulPowerLevelInfo),
	put(soulpowervalue,{0,MaxPower});

init(SoulPowerInfo)->
	SoulPowerLevelInfo = role_level_soulpower_db:get_info(get(level)),	
	MaxPower = role_level_soulpower_db:get_maxpower(SoulPowerLevelInfo),
	{CurValue,_} = SoulPowerInfo,
	if
		CurValue < MaxPower ->
			NewCurValue = CurValue;
		true->
			NewCurValue = MaxPower
	end,	
	%%{NewCurValue,MaxPower}.
	put(soulpowervalue,{NewCurValue,MaxPower}).
	

export_for_copy()->
	get(soulpowervalue).

load_by_copy(SoulPower)->
	put(soulpowervalue,SoulPower).

export_for_db()->
	{CurValue,_} = get(soulpowervalue),
	{CurValue,undefined}.

get_cursoulpower()->
	{CurSoulPower,_} = get(soulpowervalue),
	CurSoulPower.

get_maxsoulpower()->
	{_,MaxSoulPower} = get(soulpowervalue),
	MaxSoulPower.

%%
%% return 
%%
%% true: success
%% false: faild
%% nothing:
%%
consume_soulpower(0)->
	nothing;
consume_soulpower(Value)->
	if 
		Value > 0 ->
			{CurValue,MaxValue} = get(soulpowervalue),
			if
				CurValue =< 0 ->
					nothing;
				CurValue < Value ->		%%so many
					false;
				true->
					Remain = CurValue - Value,
					put(soulpowervalue,{Remain,MaxValue}),
					gm_logger_role:role_soulpower(get(roleid),Value,Remain,get(level)),
					true
			end;
		true->
			false
	end.

%%
%%
%%
add_soulpower(0)->
	nothing;
add_soulpower(Value)->
	if 
		(Value > 0) ->
			{CurValue,MaxValue} = get(soulpowervalue),	
			if
				CurValue >= MaxValue ->
					nothing;
				CurValue + Value > MaxValue->
					NewVaule = MaxValue,
					put(soulpowervalue,{NewVaule,MaxValue}),
					true;
				true->
					NewVaule = CurValue + Value,
					put(soulpowervalue,{NewVaule,MaxValue}),
					true
			end;
		true->
			false
	end.

%%
%% return 
%% false :
%% true :
%%

%%add_limitplus(CommonPlusValue,Usefullife)->
%%	if
%%		CommonPlusValue > 0 ->
%%			Now = timer_center:get_correct_now(),
%%			{_,StartTime,UsefulLife} = get(soulpowerinfo),
%%			TimeDiff = trunc((timer:now_diff(Now,StartTime))/1000000),
%%			if
%%				TimeDiff < UsefulLife ->
%%					false;
%%				true->
%%					put(soulpowerinfo,{CommonPlusValue,Now,Usefullife}),
%%					erlang:send_after((UsefulLife+?SENDDELAYTIME)*1000,self(),{update_soulpower_maxvalue}),
%%					true
%%			end;
%%		true->
%%			false
%%	end.
				
%%return new soulpowerinfo 
hook_on_role_levelup(OldLevel,NewLevel)->
	if
		NewLevel >= OldLevel->
			LevelLists = lists:seq(OldLevel, NewLevel)--[OldLevel];
		true->
			LevelLists = lists:seq(NewLevel,OldLevel)--[OldLevel]
	end,
	SoulPowerLevelInfo = role_level_soulpower_db:get_info(NewLevel),
	MaxPower = role_level_soulpower_db:get_maxpower(SoulPowerLevelInfo),
	CurSoulPower =
	lists:foldl(fun(LevelTmp,AccSoulPower)->
				SoulPowerLevelInfoTmp = role_level_soulpower_db:get_info(LevelTmp),				
				AccSoulPower + role_level_soulpower_db:get_spreward(SoulPowerLevelInfoTmp)
		end,get_cursoulpower(),LevelLists),
	if
		CurSoulPower < MaxPower ->
			NewCurValue = CurSoulPower;
		true->
			NewCurValue = MaxPower
	end,	
	%%put(creature_info,set_soulpowerinfo_to_roleinfo(RoleInfo,{CurSoulPower,MaxPower})),
	put(soulpowervalue,{NewCurValue,MaxPower}),
	update_maxsoulpower().


%%handle_update_maxsoulpower()->
%%	update_maxsoulpower().

%%
%% Local Functions
%%

%%get_maxsoulpowerplus(SoulPowerInfo)->
%%	{LimitPlus,StartTime,UsefulLife} = SoulPowerInfo,
%%	Now = timer_center:get_correct_now(),
%%	TimeDiff = trunc(timer:now_diff(Now,StartTime)/1000000),
%%	if
%%		TimeDiff >= UsefulLife ->
%%			put(soulpowerinfo,{0,{0,0,0},0}),
%%			0;
%%		true->
%%			erlang:send_after(((UsefulLife-TimeDiff)+?SENDDELAYTIME)*1000,self(),{update_soulpower_maxvalue}),
%%			LimitPlus			
%%	end.

update_maxsoulpower()->
	SoulPowerLevelInfo = role_level_soulpower_db:get_info(get(level)),
	NewMaxPower = role_level_soulpower_db:get_maxpower(SoulPowerLevelInfo),
	CurSoulPower = get_cursoulpower(),
	if
		CurSoulPower < NewMaxPower ->
			NewSoulPower = CurSoulPower;
		true->
			NewSoulPower = NewMaxPower
	end,
	put(soulpowervalue,{NewSoulPower,NewMaxPower}),
	role_op:update_maxsoulpower().		
	
