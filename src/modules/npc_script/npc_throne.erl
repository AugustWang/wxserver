%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-11-2
%% Description: TODO: Add description to npc_throne
-module(npc_throne).

%%
%% Include files
%%
-include("common_define.hrl").
-include("guildbattle_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("error_msg.hrl").
-define(CHECK_READY_TIME_DURATION,1000).
-define(CHECK_TIME_DURATION,2000).
-define(THRONE_TAKE_DELAY_CHECK_S,10).		

%%-record(thronestate,{state,guildindex,roleid,rolename}).
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%s
init()->
	put(guildbattle_state,?GUILDBATTLE_READY),
	put(throne_state,{?THRONE_STATE_NULL,0,[],0,0,{0,0},{0,0,0}}),
	put(throne_timer,[]),
	%%change_my_state(?THRONE_STATE_NULL),
	send_check(?GUILDBATTLE_PROTECT_TIME_S).

proc_special_msg({guildbattle_ready_check,RemainTime})->
	ready(RemainTime);

proc_special_msg(npc_throne_check)->
	nothing;

proc_special_msg({guildbattle_special_attack, {RoleId,MyName,RoleClass,RoleGender,GuildId}})->
	case get(guildbattle_state) of 
		?GUILDBATTLE_FAIGHT->
			{State,_,_,_,_,_,_} = get(throne_state),
			case State of
				?THRONE_STATE_NULL->
					case get(throne_timer) of
						[]->
							nothing;
						Timer->
							erlang:cancel_timer(Timer)
					end,
					Now = now(),
					slogger:msg("guildbattle_special_attack ~p ~n",[RoleId]),
					put(throne_state,{?THRONE_STATE_TAKING,RoleId,MyName,RoleClass,RoleGender,GuildId,Now}),
					change_my_state(?THRONE_STATE_TAKING),
					guildbattle_manager:change_throne_state(?THRONE_STATE_TAKING,GuildId,RoleId,MyName,RoleClass,RoleGender,Now),
					NewTimer = erlang:send_after((?THRONE_TAKE_TIME_S+?THRONE_TAKE_DELAY_CHECK_S)*1000,self(),{guildbattle_cancel_attack,{RoleId}}),		%%cancel attack  when double attack time
					put(throne_timer,NewTimer);
				_->
					nothing
			end;
		_->
			ErrnoMsg = guildbattle_packet:encode_guild_battle_opt_s2c(?ERRNO_GUILD_BATTLE_THRONE_READY_CANNOT_ATTACK),
			npc_op:send_to_other_client(RoleId, ErrnoMsg),
			nothing
	end;

proc_special_msg({guildbattle_special_real_attack, {RoleId}})->
	case get(guildbattle_state) of 
		?GUILDBATTLE_FAIGHT->
			case get(throne_timer) of
				[]->
					nothing;
				Timer->
					erlang:cancel_timer(Timer)
			end,
			{State,_RoleId,RoleName,RoleClass,RoleGender,GuildId,StartTime} = get(throne_state),
			if
				_RoleId =/= RoleId ->
					nothing;
				State =:= ?THRONE_STATE_TAKING->
					put(throne_state,{?THRONE_STATE_TAKED,0,[],0,0,{0,0},{0,0,0}}),
					change_my_state(?THRONE_STATE_TAKED),
					slogger:msg("guildbattle_special_real_attack ~p ~n",[RoleId]),
					guildbattle_manager:change_throne_state(?THRONE_STATE_TAKED,GuildId,RoleId,RoleName,RoleClass,RoleGender,StartTime);
				true->
					nothing
			end;
		_->
			ErrnoMsg = guildbattle_packet:encode_guild_battle_opt_s2c(?ERRNO_GUILD_BATTLE_THRONE_READY_CANNOT_ATTACK),
			npc_op:send_to_other_client(RoleId, ErrnoMsg),
			nothing
	end;

proc_special_msg({guildbattle_cancel_attack, {RoleId}})->
	case get(guildbattle_state) of
		?GUILDBATTLE_FAIGHT->
			{_,LastRoleId,_,_,_,_,_} = get(throne_state),
			if
				LastRoleId =:= RoleId->
					case get(throne_timer) of
						[]->
							nothing;
						Timer->
							erlang:cancel_timer(Timer),
							put(throne_timer,[])
					end,
					slogger:msg("guildbattle_cancel_attack ~p ~n",[RoleId]),
					put(throne_state,{?THRONE_STATE_NULL,0,[],0,0,{0,0},{0,0,0}}),
					change_my_state(?THRONE_STATE_NULL),
					guildbattle_manager:change_throne_state(?THRONE_STATE_NULL,{0,0},0,[],0,0,{0,0,0});
				true->
					nothing
			end;
		_->
			nothing
	end;

%%proc_special_msg({throne_taked})->
%%	case get(guildbattle_state) of
%%		?GUILDBATTLE_FAIGHT->
%%			{State,RoleId,RoleName,RoleClass,RoleGender,GuildId,StartTime} = get(throne_state),
%%			if
%%				State =:= ?THRONE_STATE_TAKING->
%%					put(throne_state,{?THRONE_STATE_TAKED,0,[],0,0,{0,0},{0,0,0}}),
%%					change_my_state(?THRONE_STATE_TAKED),
%%					guildbattle_manager:change_throne_state(?THRONE_STATE_TAKED,GuildId,RoleId,RoleName,RoleClass,RoleGender,StartTime);
%%				true->
%%					nothing
%%			end;
%%		_->
%%			nothing
%%	end;

proc_special_msg(UnKnownMsg)->
	nothing.
%%
%% Local Functions
%%
ready(0)->
	broadcast_ready_msg_to_client(0),
	change_my_state(?THRONE_STATE_NULL),
	guildbattle_manager:change_battle_fight(),
	broadcast_change_state();

ready(RemainTime)->
	broadcast_ready_msg_to_client(RemainTime),
	send_check(RemainTime-1).

send_check(RemainTime)->
	erlang:send_after(?CHECK_READY_TIME_DURATION,self(),{guildbattle_ready_check,RemainTime}).

send_check()->
	Timer = erlang:send_after(?CHECK_TIME_DURATION,self(),npc_throne_check),
	put(mytimer,Timer).
	
change_my_state(State)->
	put(creature_info, set_battle_state_to_npcinfo(get(creature_info),State)),	
	npc_op:update_npc_info(get(id),get(creature_info)).

broadcast_ready_msg_to_client(RemainTime)->
	Msg = guildbattle_packet:encode_guild_battle_ready_s2c(RemainTime),
	broadcast_to_player_client(Msg).

broadcast_change_state()->
	put(guildbattle_state,?GUILDBATTLE_FAIGHT),
	Msg = {guildbattle_proc_msg,change_my_guildbattle_state},
	broadcast_to_play_proc(Msg).

broadcast_to_player_client(Msg)->
	lists:foreach(fun(RoleId)->npc_op:send_to_other_client(RoleId, Msg) end,mapop:get_map_roles_id()). 
	
broadcast_to_play_proc(Msg)->
	lists:foreach(fun(RoleId)->npc_op:send_to_creature(RoleId, Msg) end,mapop:get_map_roles_id()). 
