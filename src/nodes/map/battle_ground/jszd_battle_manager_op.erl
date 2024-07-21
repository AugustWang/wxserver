%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-11-12
%% Description: TODO: Add description to jszd_manager_op
-module(jszd_battle_manager_op).

%%
%% Include files
%%
-define(JSZD_BUFFER_TIME_S,70).
-define(JSZD_BUFFER_END_TIME_S,120).
-define(JSZD_SEND_NOTICE_BUFFER_TIME_S,60).
-define(JSZD_MANAGER_STATE,jszd_manager_state).
-define(JSZD_INFO,jszd_info).
-define(JSZD_TOP_GUILD,jszd_top_guild).
-define(JSZD_TIME,jszd_time).
-define(JSZD_INSTANCEID,60002).
%% old is 10,鐜板彨鏀逛负20  zhangting
-define(JSZD_MAXGUILD,20).


%%
%% Exported Functions
%%
-export([init/0,on_check/0,battle_start_notify/1,apply_for_battle/1,
		 on_battle_end/0,check_battle_time/0]).
-include("activity_define.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
%%
%% API Functions
%%
init()->
	put(?JSZD_MANAGER_STATE,?ACTIVITY_STATE_STOP),
	put(?JSZD_INFO,[]),
	put(?JSZD_TIME,{0,0,0}),
	put(?JSZD_TOP_GUILD,[]).

on_check()->
	InfoList = answer_db:get_activity_info(?JSZD_BATTLE_ACTIVITY),
	CheckFun = fun(Info)->
		{Type,StartLines} = answer_db:get_activity_start(Info),
		Duration = answer_db:get_activity_duration(Info),
		SpecInfo = [{?JSZD_MAXGUILD,?JSZD_INSTANCEID}],
		case timer_util:check_is_time_line(Type,StartLines,?BUFFER_TIME_S) of
			true->
				on_start_battle(Duration,SpecInfo),
				true;
			_->
				false
		end
	end,
	States = lists:map(CheckFun, InfoList),
	case lists:member(true,States) of
		true->
			nothing;
		_->
			on_stop_battle()
	end.

battle_start_notify(Duration)->
	put(?JSZD_MANAGER_STATE,?ACTIVITY_STATE_START),
	put(?JSZD_TIME,timer_center:get_correct_now()),
	case get(?JSZD_INFO) of
		{Node,Proc,_MapProc,_}->
			{Proc,Node}!{sync_time,get(?JSZD_TIME)};
		_->
			nothing
	end,
	Message = battle_jszd_packet:encode_jszd_start_notice_s2c(trunc(Duration/1000)),
	role_pos_util:send_to_all_online_clinet(Message).

on_battle_end()->
	case get(?JSZD_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			put(?JSZD_MANAGER_STATE,?ACTIVITY_STATE_REWARD),
			case get(?JSZD_INFO) of
				{Node,Proc,_MapProc,_}->
					{Proc,Node}!{on_destroy};
				_->
					nothing
			end;
		_->
			nothing
	end.

apply_for_battle({RoleId,GuildName})->
	case get(?JSZD_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			case get(?JSZD_INFO) of
				{Node,Proc,MapProc,_}->
					case lists:keyfind(GuildName, 2, get(?JSZD_TOP_GUILD)) of
						false->
							Message = battle_jszd_packet:encode_jszd_error_s2c(?ERRNO_JSZD_GUILD_NOT_IN_TOP);
						_GuildInfo->
							Message = [],
							notify_role_join_battle(RoleId,Node,Proc,MapProc)
					end;
				_->
					Message = battle_jszd_packet:encode_jszd_error_s2c(?ERRNO_JSZD_BAD_STATE),
					role_pos_util:send_to_role_clinet(RoleId, Message)
			end;
		D->
			Message = battle_jszd_packet:encode_jszd_error_s2c(?ERRNO_JSZD_BAD_STATE)
	end,
	if
		Message =/= []->
			role_pos_util:send_to_role_clinet(RoleId, Message);
		true->
			nothing
	end.

check_battle_time()->
	case get(?JSZD_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			{_Node,_Proc,_MapProc,Duration} = get(?JSZD_INFO),
			{get(?JSZD_TIME),Duration};
		_->
			{0,0,0}
	end.	
%%
%% Local Functions
%%
on_start_battle(Duration,SpecInfo)->
	case get(?JSZD_MANAGER_STATE) of
		?ACTIVITY_STATE_STOP->
			start_process(Duration,SpecInfo),
			put(?JSZD_MANAGER_STATE,?ACTIVITY_STATE_INIT);
		_->
			noting			
	end.

on_stop_battle()->
	case get(?JSZD_MANAGER_STATE) of
		?ACTIVITY_STATE_STOP->
			nothing;
		_->
			put(?JSZD_MANAGER_STATE,?ACTIVITY_STATE_STOP),
			case get(?JSZD_INFO) of
				{Node,Proc,MapProc,_}->
					init(),
					erlang:send_after(1000,MapProc, {on_destroy}),
					rpc:call(Node,battle_ground_sup,stop_child, [Proc]);
				_->
					nothing
			end
	end.

start_process(Duration,SpecInfo)->
	Nodes = node_util:get_low_load_node(?CANDIDATE_NODES_NUM),
	Node = lists:nth(random:uniform(length(Nodes)),Nodes),
	[{Top,_}] = SpecInfo,	
	erlang:send_after(?JSZD_SEND_NOTICE_BUFFER_TIME_S*1000,self(),{battle_start_notify,{?JSZD_BATTLE,Duration}}),
	erlang:send_after(Duration + ?JSZD_SEND_NOTICE_BUFFER_TIME_S*1000,self(),{on_battle_end,?JSZD_BATTLE}),
	TopGuild = guild_manager:get_top_guild(Top),
	put(?JSZD_TOP_GUILD,TopGuild),
	rpc:call(Node,battle_ground_sup,start_child, [jszd_battle,{jszd_battle,Duration,SpecInfo,TopGuild}]),
	Proc = battle_ground_sup:make_battle_proc_name(jszd_battle,{jszd_battle,Duration,SpecInfo,TopGuild}),
	MapProc = battle_ground_processor:make_map_proc_name(Proc),
	put(?JSZD_INFO,{Node,Proc,MapProc,Duration}).

notify_role_join_battle(RoleId,Node,Proc,MapProc)->
	role_pos_util:send_to_role(RoleId,{battle_intive_to_join,{?JSZD_BATTLE,Node,Proc,MapProc}}).


