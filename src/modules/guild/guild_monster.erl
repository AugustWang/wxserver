%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-6
%% Description: TODO: Add description to guild_monster
-module(guild_monster).

%%
%% Include files
%%
-compile(export_all).

-include("guild_define.hrl").
-include("activity_define.hrl").
-include("npc_define.hrl").
-include("error_msg.hrl").
-include("little_garden.hrl").
-include("game_map_define.hrl").
-include("map_info_struct.hrl").
%%
%% Exported Functions
%%

%%
%% API Functions
%%
get_guild_monster_info()->
	{_,MonsterList,LeftTimes,_,LastCallTime,_} = guild_manager:get_guild_monster_info(guild_util:get_guild_id()),
	Now_CD = timer:now_diff(now(),LastCallTime),
	Call_CD = guild_monster_op:check_call_cd(Now_CD,?CALL_GUILD_MONSTER_CD),
	Param = guild_packet:make_guild_monster_param(MonsterList),
	Message = guild_packet:encode_get_guild_monster_info_s2c(Param,LeftTimes,Call_CD),
	role_op:send_data_to_gate(Message).

upgrade_guild_monster(MonsterId)->
	IsHasGuild = guild_util:is_have_guild(),
	IsHasRight = guild_util:is_have_right(?GUILD_AUTH_INVITE),
	if
		IsHasGuild ->
			if
				IsHasRight ->
					Errno = [],
					guild_manager:upgrade_guild_monster(get(roleid),guild_util:get_guild_id(),MonsterId);
				true->
					Errno = ?GUILD_ERRNO_LESS_AUTH
			end;
		true->
			Errno = ?GUILD_ERRNO_NOT_IN_GUILD
	end,
	if
		Errno =/= []->
			Message = guild_packet:encode_guild_monster_opt_result_s2c(Errno),
			role_op:send_data_to_gate(Message);
		true->
			ignor
	end.

call_guild_monster(MonsterId)->
	GuildId = guild_util:get_guild_id(),
	Proc = guild_instance_sup:make_proc_name(guild_instance,{?GUILD_INSTANCEID,GuildId}),
	MapProc = battle_ground_processor:make_map_proc_name(Proc),
	IsHasGuild = guild_util:is_have_guild(),
	IsHasRight = guild_util:is_have_right(?GUILD_AUTH_INVITE),
	if
		IsHasGuild ->
			if
				IsHasRight ->
					case guild_instance_processor:is_instance_start(MapProc) of
						false->
							Errno = [],
							case guild_instance:start_instance(GuildId,MapProc,Proc) of
								ok->
									call_guild_monster(MonsterId);
								_->
									error
							end;
						{Node,_,_}->
							case check_can_call_monster(GuildId,MonsterId) of
								true->
									Errno = [],
									MonsterInfo = guild_proto_db:get_guild_monsterinfo(MonsterId),
									BornPos = guild_proto_db:get_guild_monster_bornpos(MonsterInfo),
									{Proc,Node} ! {call_guild_monster,MonsterId,BornPos,GuildId};
								{less_money}->
									Errno = ?GUILD_ERRNO_MONEY_NOT_ENOUGH;
								{call_cd}->
									Errno = ?GUILD_ERRNO_CALL_CD;
								{lefttimes}->
									Errno = ?GUILD_ERRNO_CALL_NO_TIMES
							end
					end;
				true->
					Errno = ?GUILD_ERRNO_LESS_AUTH
			end;
		true->
			Errno = ?GUILD_ERRNO_NOT_IN_GUILD
	end,
	if
		Errno =/= []->
			Message = guild_packet:encode_guild_monster_opt_result_s2c(Errno),
			role_op:send_data_to_gate(Message);
		true->
			ignor
	end.

handle_call_guild_monster(MonsterId,Pos,GuildId)->
	InsProtoInfo = instance_proto_db:get_info(?GUILD_INSTANCEID),
	Proc = guild_instance_sup:make_proc_name(guild_instance,{?GUILD_INSTANCEID,GuildId}),
	MapId = instance_proto_db:get_level_mapid(InsProtoInfo),
	MapProc = battle_ground_processor:make_map_proc_name(Proc),
	NpcId = creature_op:call_creature_spawn_by_create(MonsterId,Pos,MapProc,-1,MapId,{?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM}),
	put(guild_monster_id,NpcId).

callback_guild_monster(MonsterId)->
	IsHasGuild = guild_util:is_have_guild(),
	IsHasRight = guild_util:is_have_right(?GUILD_AUTH_INVITE),
	GuildId = guild_util:get_guild_id(),
	Proc = guild_instance_sup:make_proc_name(guild_instance,{?GUILD_INSTANCEID,GuildId}),
	MapProc = battle_ground_processor:make_map_proc_name(Proc),
	if
		IsHasGuild ->
			if
				IsHasRight ->
					case guild_instance_processor:is_instance_start(MapProc) of
						false->
							Errno = ?ERRNO_INSTANCE_RESETING,
							guild_instance_processor:start_instance(GuildId,?GUILD_INSTANCEID,MapProc,Proc);
						{Node,_,_}->
							Errno = [],
							{Proc,Node} ! {callback_guild_monster,MonsterId,GuildId}
					end;
				true->
					Errno = ?GUILD_ERRNO_LESS_AUTH
			end;
		true->
			Errno = ?GUILD_ERRNO_NOT_IN_GUILD
	end,
	if
		Errno =/= []->
			Message = guild_packet:encode_guild_monster_opt_result_s2c(Errno),
			role_op:send_data_to_gate(Message);
		true->
			ignor
	end.
	
handle_callback_guild_monster(MonsterId,GuildId)->
	Proc = guild_instance_sup:make_proc_name(guild_instance,{?GUILD_INSTANCEID,GuildId}),
	MapProc = battle_ground_processor:make_map_proc_name(Proc), 
	NpcId = get(guild_monster_id),
	creature_op:unload_npc_from_map_ext(MapProc,NpcId),
	guild_manager:callback_guild_monster(MonsterId,GuildId).

on_killed_guild_monster(BeKiller)->
	case (mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info)))=:=?MAP_TAG_GUILD_INSTANCE) of
		true->
			guild_manager:on_killed_guild_monster(guild_util:get_guild_id(),get(roleid),BeKiller);
		_->
			ignor
	end.

check_can_call_monster(GuildId,MonsterId)->
	guild_manager:check_can_call_monster(GuildId,MonsterId).