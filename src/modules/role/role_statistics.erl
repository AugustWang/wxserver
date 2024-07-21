%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhang
%% Created: 2011-1-24
%% Description: TODO: Add description to role_statistics
-module(role_statistics).

%%
%% Exported Functions
%%
-export([start_dps_st/0,init_role_dps_info/0,is_dps_st_start/0,update_role_dps_damage/1,stop_dps_st/0]).

%%
%% Include files
%%
-include("common_define.hrl").
-record(role_dps_info,{
		starttime,
		endtime,
		damage,
		b_st_start
	}).

%%
%% API Functions
%%

start_dps_st()->
	case is_dps_st_start()  of
		true ->
			{error,"DpsStRunning"};
		_->		
			reset_dps_damage(get_role_dps_info()),
			set_dps_st_start(get_role_dps_info(),true),
			update_dps_starttime(get_role_dps_info())
	end.

init_role_dps_info()->
	RoleDpsInfo = #role_dps_info{starttime = {0,0,0}, endtime = {0,0,0},damage = 0, b_st_start = false},
	put(role_dps_info,RoleDpsInfo).

is_dps_st_start()->
	case get_role_dps_info() of
		undefined->
			init_role_dps_info(),
			false;
		RoleDpsInfo->
			get_dps_st_start(RoleDpsInfo)
	end.

update_role_dps_damage(Damage)->
	case is_dps_st_start() of
		true ->
			add_dps_damage(get_role_dps_info(),Damage),
			update_dps_endtime(get_role_dps_info());
		_->
			nothing
	end.

stop_dps_st()->
	case is_dps_st_start() of
		true->
			DpsInfo = role_dps_statistics(get_role_dps_info()),
			set_dps_st_start(get_role_dps_info(),false),
			notify_dps_info(DpsInfo);
		_->
			nothing
	end.
%%
%% Local Functions
%%

notify_dps_info(DpsInfo)->
	{Dps,Damage,Time} = DpsInfo,
	%%ChatNode = lists:last(node_util:get_chatnodes()),
	BroadCastMsg = "dps:"++integer_to_list(Dps)++ " damage:"++integer_to_list(Damage)++" time:"++integer_to_list(Time),
	%%chat_op:send_privatechat(?CHAT_TYPE_PRIVATECHAT,get_name_from_roleinfo(get(creature_info)),BroadCastMsg,[]).
	chat_manager:system_to_someone(get(roleid),BroadCastMsg).

role_dps_statistics(RoleDpsInfo) when is_record(RoleDpsInfo, role_dps_info) ->
	TotalTime = timer:now_diff(get_dps_endtime(RoleDpsInfo),get_dps_starttime(RoleDpsInfo))/1000000,
	TotalDamage = get_dps_damage(RoleDpsInfo),
	if
		TotalTime =< 0 ->
			{0,0,0};
		true->
			{trunc(abs(TotalDamage)/TotalTime),abs(TotalDamage),trunc(TotalTime)}
	end.

get_role_dps_info()->
	get(role_dps_info).

get_dps_starttime(RoleDpsInfo) when is_record(RoleDpsInfo, role_dps_info) ->
	erlang:element(#role_dps_info.starttime, RoleDpsInfo).

update_dps_starttime(RoleDpsInfo) when is_record(RoleDpsInfo, role_dps_info) ->
	NewRoleDpsInfo = erlang:setelement(#role_dps_info.starttime, RoleDpsInfo, timer_center:get_correct_now()),
	put(role_dps_info,NewRoleDpsInfo).

get_dps_endtime(RoleDpsInfo) when is_record(RoleDpsInfo, role_dps_info) ->
	erlang:element(#role_dps_info.endtime, RoleDpsInfo).

update_dps_endtime(RoleDpsInfo) when is_record(RoleDpsInfo, role_dps_info) ->
	NewRoleDpsInfo = erlang:setelement(#role_dps_info.endtime, RoleDpsInfo, timer_center:get_correct_now()),
	put(role_dps_info,NewRoleDpsInfo).

get_dps_damage(RoleDpsInfo) when is_record(RoleDpsInfo, role_dps_info) ->
	erlang:element(#role_dps_info.damage, RoleDpsInfo).

reset_dps_damage(RoleDpsInfo) when is_record(RoleDpsInfo, role_dps_info) ->
	NewRoleDpsInfo = erlang:setelement(#role_dps_info.damage, RoleDpsInfo,0),
	put(role_dps_info,NewRoleDpsInfo).

add_dps_damage(RoleDpsInfo,Damage) when is_record(RoleDpsInfo, role_dps_info) ->
	RealDamage = get_dps_damage(RoleDpsInfo) + Damage,
	NewRoleDpsInfo = erlang:setelement(#role_dps_info.damage, RoleDpsInfo,RealDamage),
	put(role_dps_info,NewRoleDpsInfo).

get_dps_st_start(RoleDpsInfo) when is_record(RoleDpsInfo, role_dps_info) ->
	erlang:element(#role_dps_info.b_st_start, RoleDpsInfo).

set_dps_st_start(RoleDpsInfo,Bstart) when is_record(RoleDpsInfo, role_dps_info) ->
	NewRoleDpsInfo = erlang:setelement(#role_dps_info.b_st_start,RoleDpsInfo,Bstart),
	put(role_dps_info,NewRoleDpsInfo).

