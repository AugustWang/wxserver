%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-6
%% Description: TODO: Add description to guild_manster_op
-module(guild_monster_op).

%%
%% Include files
%%
-include("activity_define.hrl").
-include("guild_define.hrl").
-include("common_define.hrl").
-include("little_garden.hrl").
-include("error_msg.hrl").
-define(NPC_GUILD_INSTANCE,2030003).
%%
%% Exported Functions
%%
-compile(export_all).

-include("npc_struct.hrl").
%%
%% API Functions
%%
init()->
	ets:new(guild_monster,[set,protected, named_table]).

%% ===========================================================
%% opt data
%% ===========================================================
get_guild_monster_info(GuildId)->
	case ets:lookup(guild_monster,GuildId) of
		[Info]->Info;
		_->[]
	end.

update_guild_monster(Info)->
	ets:insert(guild_monster,Info).
%% ===========================================================
%% opt data
%% ===========================================================
upgrade_guild_monster(RoleId,GuildId,MonsterId)->
	{_,MonsterList,LeftTimes,Time,LastCallTime,ActivMonster} = get_guild_monster_info(GuildId),
	Now_CD = timer:now_diff(now(),LastCallTime),
	Call_CD = check_call_cd(Now_CD,?CALL_GUILD_MONSTER_CD),
	case lists:keyfind(MonsterId,1,MonsterList) of
		false->
			MonsterInfo = guild_proto_db:get_guild_monsterinfo(MonsterId),
			NeedLevel = guild_proto_db:get_guild_monster_needlevel(MonsterInfo),
			UpgradeMoney = guild_proto_db:get_guild_monster_upgrademoney(MonsterInfo),
			GuildInfo = guild_manager_op:get_guild_info(GuildId),
			GuildLevel = guild_manager_op:get_by_guild_item(level,GuildInfo),
			GuildMoney = guild_manager_op:get_by_guild_item(silver,GuildInfo),
			if
				GuildMoney >= UpgradeMoney ->
					if
						GuildLevel >= NeedLevel ->
							Errno = [],
							consume_guild_money(GuildId,GuildInfo,[{?MONEY_BOUND_SILVER,UpgradeMoney}],upgrade_monster),
							NewMonsterList = [{MonsterId,?STATE_NOT_ACTIVITED}|MonsterList],
							update_guild_monster({GuildId,NewMonsterList,LeftTimes,Time,LastCallTime,ActivMonster}),
							guild_spawn_db:add_guild_monster({GuildId,NewMonsterList,LeftTimes,Time,LastCallTime,ActivMonster}),
							Param = guild_packet:make_guild_monster_param(NewMonsterList),
							Msg = guild_packet:encode_get_guild_monster_info_s2c(Param,LeftTimes,Call_CD),
							guild_manager_op:send_to_all_client(GuildId,Msg);
						true->
							Errno = ?ERRNO_GUILD_LESS_LEVEL
					end;
				true->
					Errno = ?ERRNO_GUILD_LESS_MONEY
			end;
		_->
			Errno = ?ERRNO_ALREADY_UPGRADE
	end,
	if
		Errno =/= []->
			Message = guild_packet:encode_guild_monster_opt_result_s2c(Errno),
			role_pos_util:send_to_role_clinet(RoleId, Message);
		true->
			ignor
	end.

check_can_call_monster(GuildId,MonsterId)->
	GuildInfo = guild_manager_op:get_guild_info(GuildId),
	GuildMoney = guild_manager_op:get_by_guild_item(silver,GuildInfo),
	MonsterInfo = guild_proto_db:get_guild_monsterinfo(MonsterId),
	CallNeedMoney = guild_proto_db:get_guild_monster_callmoney(MonsterInfo),
	{_,MonsterList,LeftTimes,Time,LastCallTime,_} = get_guild_monster_info(GuildId),
	Now = now(),
	Now_CD = timer:now_diff(Now,LastCallTime),
	Call_CD = check_call_cd(Now_CD,?CALL_GUILD_MONSTER_CD),
	case Call_CD =:= 0 of
		true->
			if
				GuildMoney >= CallNeedMoney->
					IsSameDay = timer_util:check_same_day(Now, Time),
					if	
						IsSameDay->
							if
								LeftTimes >=1 ->
									consume_guild_money(GuildId,GuildInfo,[{?MONEY_BOUND_SILVER,CallNeedMoney}],call_monster),
									NewMonsterList = lists:keyreplace(MonsterId,1,MonsterList,{MonsterId,?STATE_ACTIVITED}),
									update_guild_monster({GuildId,NewMonsterList,LeftTimes -1,Time,Now,MonsterId}),
									guild_spawn_db:add_guild_monster({GuildId,NewMonsterList,LeftTimes-1,Time,Now,MonsterId}),
									notify_all(GuildId,NewMonsterList,LeftTimes-1,?CALL_GUILD_MONSTER_CD),
									true; 
								true->
									{lefttimes}
							end;
						true->
							consume_guild_money(GuildId,GuildInfo,[{?MONEY_BOUND_SILVER,CallNeedMoney}],call_monster),
							NewTimes = ?CALL_GUILD_MONSTER_MAX_TIMES -1,
							NewMonsterList = lists:keyreplace(MonsterId,1,MonsterList,{MonsterId,?STATE_ACTIVITED}),
							update_guild_monster({GuildId,NewMonsterList,NewTimes,Now,Now,MonsterId}),
							guild_spawn_db:add_guild_monster({GuildId,NewMonsterList,NewTimes,Now,Now,MonsterId}),
							notify_all(GuildId,NewMonsterList,NewTimes,?CALL_GUILD_MONSTER_CD),
							true
					end;
				true->
					{less_money}
			end;
		_->
			notify_all(GuildId,MonsterList,LeftTimes,Call_CD),
			{call_cd}
	end.

callback_guild_monster(MonsterId,GuildId)->
	{_,MonsterList,LeftTimes,Time,LastCallTime,_} = get_guild_monster_info(GuildId),
	Now_CD = timer:now_diff(now(),LastCallTime),
	Call_CD = check_call_cd(Now_CD,?CALL_GUILD_MONSTER_CD),
	NewMonsterList = lists:keyreplace(MonsterId,1,MonsterList,{MonsterId,?STATE_NOT_ACTIVITED}),
	notify_all(GuildId,NewMonsterList,LeftTimes,Call_CD),
	update_guild_monster({GuildId,NewMonsterList,LeftTimes,Time,LastCallTime,[]}),
	guild_spawn_db:add_guild_monster({GuildId,NewMonsterList,LeftTimes,Time,LastCallTime,[]}).

notify_all(GuildId,MonsterList,LeftTimes,Call_CD)->
	Param = guild_packet:make_guild_monster_param(MonsterList),%%è¿”å›žä¸€ä¸ªè®°å½•
	Msg = guild_packet:encode_get_guild_monster_info_s2c(Param,LeftTimes,Call_CD),
	guild_manager_op:broad_cast_to_guild_client(GuildId,Msg).

make_guild_monster_procdict_name({GuildLId,GuildHId})->
	lists:append(["guildmonster_",integer_to_list(GuildLId),"_",integer_to_list(GuildHId)]).

check_call_cd(Now_CD,NeedCD)->
	if
		Now_CD >= NeedCD * 1000000 ->
			Call_CD = 0;
		true->
			Call_CD = NeedCD * 1000000 - Now_CD
	end,
	trunc(Call_CD/1000000).

consume_guild_money(GuildId,GuildInfo,ConsumeMoneyList,Reason)->
	case guild_manager_op:resume_guild_money(ConsumeMoneyList,GuildInfo,Reason) of
		[]->ignor;
		NewGuildInfo->
			guild_manager_op:update_guild_info(NewGuildInfo),
			guild_manager_op:broad_cast_guild_base_changed_to_client(NewGuildInfo),
			guild_spawn_db:set_guild_silver(GuildId,guild_manager_op:get_by_guild_item(silver,NewGuildInfo)),	
			guild_spawn_db:set_guild_gold(GuildId,guild_manager_op:get_by_guild_item(gold,NewGuildInfo))									
	end.

on_killed(GuildId,KillerId,BeKillId)->
	case creature_op:what_creature(KillerId) of
		npc->
			nothing;
		role->
			case creature_op:what_creature(BeKillId) of
				npc ->
					{_,MonsterList,LeftTimes,Time,LastCallTime,_} = get_guild_monster_info(GuildId),
					Now_CD = timer:now_diff(now(),LastCallTime),
					Call_CD = check_call_cd(Now_CD,?CALL_GUILD_MONSTER_CD),
					NewMonsterList = lists:map(fun({TempId,State})->
													   {TempId,?STATE_NOT_ACTIVITED}
												end,MonsterList),
					notify_all(GuildId,NewMonsterList,LeftTimes,Call_CD),
					update_guild_monster({GuildId,NewMonsterList,LeftTimes,Time,LastCallTime,[]}),
					guild_spawn_db:add_guild_monster({GuildId,NewMonsterList,LeftTimes,Time,LastCallTime,[]});
				role->
					ignor
			end
	end.

clear_cd_by_gm(GuildId)->
	{_,MonsterList,LeftTimes,Time,_,ActivMonster} = get_guild_monster_info(GuildId),
	update_guild_monster({GuildId,MonsterList,5,Time,{0,0,0},ActivMonster}).