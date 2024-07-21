%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-11-12
%% Description: TODO: Add description to jszd_battle
-module(jszd_battle).

%%
%% Include files
%%
-define(RANK_BROAD_TIME,2).%%S
-define(DESTORY_TIME,60).%%S
%%
%% Exported Functions
%%
-export([on_init/2,destroy_self/0,do_interval/1,on_role_join/1,on_role_leave/1,
		 on_reward/1,sync_time/1,on_killed/1,on_destroy/0]).
-include("activity_define.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("system_chat_define.hrl").
-include("string_define.hrl").
-include("npc_define.hrl").
-include("mnesia_table_def.hrl").
%%
%% API Functions
%%
on_init(ProcName,{BattleType,Duration,SpecInfo,TopGuild})->
	[{_GuildLimit,InstanceId}] = SpecInfo,
	InstanceInfo = instance_proto_db:get_info(InstanceId),
	MapId = instance_proto_db:get_level_mapid(InstanceInfo),
	MapProc = battle_ground_processor:make_map_proc_name(ProcName),
	case map_manager:start_instance(MapProc,{atom_to_list(ProcName),InstanceId,{?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM}},MapId) of
		ok->
			init(BattleType,ProcName,MapProc,SpecInfo,TopGuild,Duration),
			ok;
		error->
			on_destroy()
	end.

init(BattleType,ProcName,MapProc,_SpecInfo,TopGuild,Duration)->
	put(jszd_battle,{BattleType,ProcName,MapProc}),
	NpcInfoDB = npc_op:make_npcinfo_db_name(MapProc),
	put(npcinfo_db,NpcInfoDB),
	put(jszd_duration,Duration),
	{RanksInfo,GRanks} = 
		lists:foldl(fun({GId,GName,Rank},{Acc1,Acc2})->
							%%id,name,grank,joinmembers,score,rank
							{Acc1++[{GId,GName,0,0,Rank}], Acc2++[{GId,Rank}]}
					end, {[],[]}, TopGuild),
	put(granks,GRanks),
	put(ranks_info,lists:reverse(RanksInfo)),
	put(role_info,[]),
	put(is_battling,true),
	put(has_reward,[]),
	put(can_reward,false),
	put(has_leave,[]),
	put(jszd_time,{0,0,0}).
%% 	erlang:send_after(?RANK_BROAD_TIME*1000, self(),{do_interval,[]}).

do_interval(_Info)->
	nothing.
%% 	put(ranks_info,lists:reverse(lists:keysort(4,get(ranks_info)))).

get_ranks_info()->
	case get(ranks_info) of
		[]->
			[];
		Ranks->
			lists:map(fun({GId,GName,JoinMembers,Score,Rank})->
							  {jszd,GId,GName,Score,Rank,JoinMembers}
					  end, Ranks)
	end.

get_guild_totle_score()->
	case get(ranks_info) of
		[]->
			0;
		Ranks->
			lists:foldl(fun({_,_,_,Score,_},Acc)->
								Score + Acc
							end,0,Ranks)
	end.

on_destroy()->
	put(is_battling,false),
	put(can_reward,true),
	MapProc = get_map_proc(),
	guild_reward(),
	save_record(),
	notify_role_reward(),
	guild_manager:notify_jszd_battle_stop(),
	erlang:send_after(?BUFFER_TIME_S*1000,MapProc, {on_destroy}),
	erlang:send_after(?DESTORY_TIME*1000,self(), {destory_self}).

notify_role_reward()->
	Guilds = get_ranks_info(),
	Fun = fun({RoleId,_,RoleLevel,_,_,_})->
				  {Exp,_,Honor} = get_reward_by_roleid_level(RoleId,RoleLevel),
				  role_pos_util:send_to_role(RoleId, {battle_reward_honor_exp,?JSZD_BATTLE,Honor,Exp}),
				  Message = battle_jszd_packet:encode_jszd_end_s2c(0, Guilds,Honor,Exp),
				  role_pos_util:send_to_role_clinet(RoleId, Message)
			end,
	lists:foreach(Fun, get(role_info)).

save_record()->
	clear_old_record(),
	case get(role_info) of
		[]->
			ignor;
		Info->
			lists:foreach(fun({RoleId,_,_,_,Score,KillNum})->
								  battle_jszd_db:save_record_to_db(RoleId,Score,KillNum)
							end,Info)
	end.

clear_old_record()->
	battle_jszd_db:clear_record_from_db().

destroy_self()->
	send_to_ground({battle_leave_c2s}).

sync_time(Time)->
	put(jszd_time,Time).

guild_reward()->
	case get(ranks_info) of
		undefined->
			nothing;
		RanksInfo->
			lists:foreach(fun(RankInfo)->
								  {GuildId,GuildName,_,_,Rank} = RankInfo,
								  case battle_jszd_db:get_info(Rank) of
									  []->
										  nothing;
									  Info->
										  GuildMoney = battle_jszd_db:get_guild_money(Info),
										  Money = [{?MONEY_BOUND_SILVER,GuildMoney*10000}],
										  Score = battle_jszd_db:get_guild_score(Info),
										  guild_manager:add_guild_battle_score(GuildId,Score,jszd_battle),
										  guild_manager:check_and_add_money(GuildId,Money,jszd_battle),
										  if
											  Rank =< 3->
												  system_bodcast(?SYSTEM_CHAT_JSZD_BATTLE_GUILD_REWARD,
																 GuildName,Rank,GuildMoney);
											  true->
												  nothing
										  end
								  end
						  end, lists:reverse(RanksInfo))
	end.
		
system_bodcast(SysId,GuildName,Rank,_) ->   
	ParamString = system_chat_util:make_string_param(GuildName),
	ParamIntRank = system_chat_util:make_int_param(Rank),
	MsgInfo = [ParamString,ParamIntRank],
	system_chat_op:system_broadcast(SysId,MsgInfo).

on_role_join({RoleId,RoleName,RoleLevel,GuildName})->
	case get(is_battling) of
		true->
			case lists:keyfind(GuildName, 2, get(ranks_info)) of
				false->
					nothing;
				{GId,GName,JoinMembers,Score,Rank}->
					put(ranks_info,lists:keyreplace(GuildName, 2, get(ranks_info), 
									 {GId,GName,JoinMembers+1,Score,Rank})),
					case lists:keyfind(RoleId, 1, get(role_info)) of
						false->
							%%roleid,rolename,guildname,score
							put(role_info,[{RoleId,RoleName,RoleLevel,GuildName,0,0}|get(role_info)]);
						{_,_,_,_,Score,KillNum}->
							put(role_info,lists:keyreplace(RoleId, 1, get(role_info), 
								{RoleId,RoleName,RoleLevel,GuildName,Score,KillNum}))	
					end,
					Duration = get(jszd_duration),
					Time = get(jszd_time),
					LeftTime = trunc((Duration - timer:now_diff(timer_center:get_correct_now(),Time)/1000)/1000), 
					Guilds = get_ranks_info(),
					Message = battle_jszd_packet:encode_jszd_join_s2c(LeftTime, Guilds),
					send_message_client(RoleId,Message)
			end;
		_->
			nothing
	end.

on_role_leave(RoleId)->
	case lists:keyfind(RoleId, 1, get(role_info)) of
		false->
			nothing;
		{_,RoleName,RoleLevel,GuildName,_,_}->
			on_reward_with_mail(RoleId,RoleName,RoleLevel),
			put(role_info,lists:keydelete(RoleId, 1, get(role_info))),
			case lists:keyfind(GuildName, 2, get(ranks_info)) of
				false->
					nothing;
				{GId,GName,JoinMembers,Score,Rank}->
					put(ranks_info,lists:keyreplace(GuildName, 2, get(ranks_info), 
									 {GId,GName,JoinMembers-1,Score,Rank})),
					guild_manager:leave_jszd_battle(GId)
			end
	end.

on_killed({Killer,BeKilled})->
	case get(is_battling) of
		true->
			case creature_op:what_creature(Killer) of
				npc->
					nothing;
				role->
					case creature_op:what_creature(BeKilled) of
						npc ->
							creature_killed_score(Killer,BeKilled);
						role->
							creature_killed_num(Killer)
					end
			end;
		_->
			nothing
	end.

creature_killed_num(Killer)->
	case lists:keyfind(Killer, 1, get(role_info)) of
		false->
			nothing;
		{Rid,Rname,RLevel,Rguild,Rscore,KillNum}->
			put(role_info,lists:keyreplace(Killer, 1, get(role_info), {Rid,Rname,RLevel,Rguild,Rscore,KillNum+1}))
	end.

creature_killed_score(Killer,BeKilled)->
	case lists:keyfind(Killer, 1, get(role_info)) of
		false->
			nothing;
		{Rid,Rname,RLevel,Rguild,Rscore,KillNum}->
			NpcInfo = creature_op:get_creature_info(BeKilled),
	 		KillerInfo = creature_op:get_creature_info(Killer),
	 		Score = get_maxsilver_from_npcinfo(NpcInfo),
			killed_role_broad_cast(npc,KillerInfo,NpcInfo,Score),
			case (NpcInfo =/= undefined) and (KillerInfo=/= undefined) of
				true->
					put(role_info,lists:keyreplace(Killer, 1, get(role_info), {Rid,Rname,RLevel,Rguild,Rscore+Score,KillNum})),
					case lists:keyfind(Rguild, 2, get(ranks_info)) of
						false->
							nothing;
						{Gid,Gname,Gmembers,Gscore,Grank}->
							Temp = lists:keyreplace(Gid, 1, get(ranks_info),{Gid,Gname,Gmembers,Gscore+Score,Grank}),
							put(ranks_info,rank(Temp)),
							Duration = get(jszd_duration),
							Time = get(jszd_time),
							LeftTime = trunc((Duration - timer:now_diff(timer_center:get_correct_now(),Time)/1000)/1000), 
							Guilds = get_ranks_info(),
							Message = battle_jszd_packet:encode_jszd_update_s2c(Killer,Rscore+Score,LeftTime,Guilds),
							send_all_around_client(Message)
					end;
				_->
					nothing
			end
	end. 

rank(GuildList)->
	RankList = lists:keysort(4, GuildList),
	{Ranks,_} = 
		lists:mapfoldl(fun(RankInfo,Acc)->
			{Rank_Gid,Rank_Gname,Rank_Gmember,Rank_Gscore,_Grank} = RankInfo,
			{{Rank_Gid,Rank_Gname,Rank_Gmember,Rank_Gscore,Acc},Acc-1}
		end, erlang:length(RankList), RankList),
	Ranks.

killed_role_broad_cast(Type,MyInfo,OtherInfo,Score)->
	ParamRole = system_chat_util:make_role_param(MyInfo),
	ParamInt = system_chat_util:make_int_param(Score),
	case (MyInfo=:=undefined) or (OtherInfo=:=undefined) of
		true ->
			nothing;
		_ ->
			if 
				Type=:=role->
					nothing;
				true->
					OtherName = get_name_from_npcinfo(OtherInfo),
					ParamString = system_chat_util:make_string_param(OtherName),
					MsgInfo = [ParamRole,ParamString,ParamInt],
					system_chat_op:system_broadcast_instance(
					  ?SYSTEM_CHAT_JSZD_BATTLE_KILL_SHUIJING,
					  MsgInfo,
					  atom_to_list(get_map_proc()))
			end
	end.	

on_reward({RoleId,RoleLevel})->
	case (not get(is_battling)) and (not is_has_reward(RoleId)) and (get(can_reward)) of
		true->
			put(has_reward,[RoleId|get(has_reward)]),
			get_reward_by_roleid_level(RoleId,RoleLevel);
		_->
			[]
	end.

get_reward_by_roleid_level(RoleId,RoleLevel)->
	case get_role_score(RoleId) of
		-1->
			[];
		Score->
			Rank = get_role_rank(RoleId),
			case battle_jszd_db:get_info(Rank) of
				[]->
					[];
				Info->
					Exp = get_exp_by_coeff(battle_jszd_db:get_exp(Info),Rank,RoleLevel),
					RankHonor = battle_jszd_db:get_role_rank_honor(Info),
					Honor = case lists:keyfind(RoleId,1,get(role_info)) of
								false ->
									0;
								{_,_,_,_,Score,_}->
									case get_guild_totle_score() of
										0 -> 20;
										AllScore ->
											min((Score/AllScore)*200,20)
									end									
							end,
					Bonus = battle_jszd_db:get_bonus(Info),
					{erlang:trunc(Exp),Bonus,Honor + RankHonor}
			end
	end.

on_reward_with_mail(RoleId,RoleName,RoleLevel)->
	case (not get(is_battling)) and (not is_has_reward(RoleId)) and (get(can_reward)) of
		true->
			put(has_reward,[RoleId|get(has_reward)]),
			case get_role_score(RoleId) of
				-1->
					[];
				Score->
					Rank = get_role_rank(RoleId),
					case battle_jszd_db:get_info(Rank) of
						[]->
							[];
						Info->
							Bonus = battle_jszd_db:get_bonus(Info),
							FromName = language:get_string(?STR_BATTLE_MAIL_SIGN),
							Title = language:get_string(?STR_JSZD_MAIL_TITLE),
							Context = language:get_string(?STR_JSZD_MAIL_CONTEXT),
							Add_Silver = 0,
							lists:foreach(fun({ItemId,Count})->
								gm_op:gm_send_rpc(FromName,RoleName,Title,Context,ItemId,Count,Add_Silver)	
							end,Bonus)
					end
			end;
		_->
			nothing
	end.

get_role_score(RoleId)->
	case lists:keyfind(RoleId, 1, get(role_info)) of
		false->
			-1;
		{_,_,_,_,Score,_}->
			Score
	end.

get_role_rank(RoleId)->
	case lists:keyfind(RoleId, 1, get(role_info)) of
		false->
			-1;
		{_,_,_,GName,_,_}->
			case lists:keyfind(GName, 2, get(ranks_info)) of
				false->
					-1;
				{_,_,_,_,Rank}->
					Rank
			end
	end.

get_exp_by_coeff(Coeff,Rank,Level)->
	Level * (Coeff + erlang:max(11 - Rank, 0) * 300).

is_has_reward(RoleId)->
	lists:member(RoleId, get(has_reward)).
%%
%% Local Functions
%%
get_map_proc()->
	{_,_,MapProc} = get(jszd_battle),
	MapProc.

send_to_ground(Message)->
	case get(role_info) of
		[]->
			nothing;
		RoleInfos->
			lists:foreach(fun({RoleId,_RoleName,_RoleLevel,_GuildName,_Score,_})->
								  send_message(RoleId,Message)
						  end, RoleInfos)
	end.

send_all_around_client(Message)->
	case get(role_info) of
		[]->
			nothing;
		RoleInfos->
			lists:foreach(fun({RoleId,_RoleName,_RoleLevel,_GuildName,_Score,_})->
								  send_message_client(RoleId,Message)
						  end, RoleInfos)
	end.

send_message(RoleId,Message)->
	role_pos_util:send_to_role(RoleId,Message).

send_message_client(RoleId,Message)->
	role_pos_util:send_to_role_clinet(RoleId, Message).

bs([]) -> [];
bs(List) -> bs(List, [], [], length(List)-1, 0).
bs([X], Temp, Final, Count, Swapped) ->
  case Swapped == Count of
    true -> lists:append(lists:reverse(Final), [X|Temp]);
    false -> bs(Temp, [], [X|Final], Count-1, 0)
  end;
bs([X,Y|Z], Temp, _Final, _Count, Swapped) ->
  case X>Y of
    true  -> bs([Y|Z], [X|Temp], _Final, _Count, Swapped+1);
    false -> bs([X|Z], [Y|Temp], _Final, _Count, Swapped)
  end.

selection([]) -> [];
selection([X|Y]) -> selection(Y, X, [], []).
 
selection([], X, [], Final) -> [X|Final];
 
selection([], Small, [X|Y], Final) ->
  selection(Y, X, [], [Small|Final]);
 
selection([X|Y], Small, Temp, _Final) ->
  case X<Small of
    true -> selection(Y, Small, [X|Temp], _Final);
    _ -> selection(Y, X, [Small|Temp], _Final)
  end.


