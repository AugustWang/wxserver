%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-5
%% Description: TODO: Add description to guild_instance_manager_op
-module(guild_instance_manager_op).

%%
%% Include files
%%
-include("common_define.hrl").
-include("activity_define.hrl").
-include("treasure_transport_define.hrl").
-include("system_chat_define.hrl").
-define(SYNC_TIME,30000).
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
init()->
	put(guild_instance_activity_running,false),
	put(guild_instance_activity_start_time,{0,0,0}).

on_check()->
	ActivityInfoList = answer_db:get_activity_info(?GUILD_INSTANCE_ACTIVITY),
	CheckFun = fun(ActiveInfo)->
				{Type,StartLines} = answer_db:get_activity_start(ActiveInfo),
				case activity_manager_op:check_is_time_line(Type,StartLines) of
					{true,StartLine}->
						start_guild_instance_activity(StartLine),
						true;
					_->
						false
				end
	end,
	States = lists:map(CheckFun, ActivityInfoList),
	case lists:member(true,States) of
		true->
			nothing;
		_->
			stopeds_all()
	end.

stopeds_all()->
	case get(guild_instance_activity_running) of
		false->
			nothing;
		_->
			erlang:cancel_timer(get(bonfire_timer)),
			put(guild_instance_activity_running,false),
			Message = guild_packet:encode_guild_bonfire_end_s2c(),
			role_pos_util:send_to_all_online_clinet(Message),
			role_pos_util:send_to_all_role({guild_message,{guild_instance_end}})
	end.

start_guild_instance_activity(StartLines)->
	case get(guild_instance_activity_running) of
		true->
			nothing; 
		_->
			put(guild_instance_activity_start_time,now()),
			put(guild_instance_activity_running,true),
			system_chat_op:system_broadcast(?SYSTEM_CHAT_GUILD_BONFIRE_START,[]),
			role_pos_util:send_to_all_role({guild_message,{guild_instance_start}}),
			LeftTime = guild_instance:get_activity_lefttime(StartLines),
			Message = guild_packet:encode_guild_bonfire_start_s2c(LeftTime),
			TimeRef = erlang:send_after(?SYNC_TIME, self(), {syna_bonfire_time}),
			put(bonfire_timer,TimeRef),
			role_pos_util:send_to_all_online_clinet(Message)
	end.

syna_bonfire_time()->
	LeftTime = guild_instance:get_activity_lefttime(),
	Message = guild_packet:encode_sync_bonfire_time_s2c(LeftTime),
	role_pos_util:send_to_all_online_clinet(Message),
	TimeRef = erlang:send_after(?SYNC_TIME, self(), {syna_bonfire_time}),
	put(bonfire_timer,TimeRef).







