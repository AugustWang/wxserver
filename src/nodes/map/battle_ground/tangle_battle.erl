%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(tangle_battle).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("system_chat_define.hrl").
-include("string_define.hrl").
-include("error_msg.hrl").
-include("npc_define.hrl").

-compile(export_all).

-include("mnesia_table_def.hrl").

-define(BUFFER_TIME_S,130).				%%leave 2min to rewards

-define(POS_BROAD_TIME,3000).			%%every 3s broadcast Pos
-define(POS_BROAD_NUM,10).
-define(TANGLE_REWARD_INFO_ETS,tangle_reward_info_ets).

%%tangle_kill_info:[killinfo],
%%killinfo:{roleid,{[{bekillroleid,num}],[{killroleid,num}]}}
%%ranks_info:{RoleId,RoleName,ranks,kills,leave_time}
on_init(ProcName,{BattleType,BattleId})->
	ProtoInfo = battlefield_proto_db:get_info(?TANGLE_BATTLE),
	InstanceIds = battlefield_proto_db:get_instance_proto(ProtoInfo),
	Duration = battlefield_proto_db:get_duration(ProtoInfo),
	InstanceId = lists:nth(BattleType,InstanceIds),
	InstanceInfo = instance_proto_db:get_info(InstanceId),
	MapId = instance_proto_db:get_level_mapid(InstanceInfo),
	MapProc = battle_ground_processor:make_map_proc_name(ProcName),
	slogger:msg("ProcName Start ~p~n",[ProcName]),
	case map_manager:start_instance(MapProc,{atom_to_list(ProcName),InstanceId,{?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM}},MapId) of
		ok->
			init(Duration,BattleType,BattleId,MapProc,ProtoInfo),
			ok;
		error->
			on_destroy()
	end.

init(Duration,BattleType,BattleId,MapProc,ProtoInfo)->
	put(tangle_info,{BattleType,BattleId,MapProc}),
	NpcInfoDB = npc_op:make_npcinfo_db_name(MapProc),
	put(npcinfo_db,NpcInfoDB),
	put(ranks_info,[]),
	put(is_battling,true),
	put(has_reward,[]),
	put(can_reward,false),	%%是否能领奖
	put(has_leave,[]),
	put(tangle_kill_info,[]),
	%%erlang:send_after(?POS_BROAD_NUM*1000, self(),{do_interval,[]}), 客户端不需要显示前十名
	notify_manager_battle_start(BattleType,BattleId).

do_interval(_Info)->
	case get(is_battling) of
		true->
			case lists:sublist(get(ranks_info), ?POS_BROAD_NUM) of
				[]->
					nothing;
				TopTens->
					Poses = lists:map(fun({RoleId,_,_,_,_})->
								case creature_op:get_creature_info(RoleId) of
									undefined->
										battle_ground_packet:make_tp(RoleId,0,0);
									RoleInfo->
										{X,Y} = get_pos_from_roleinfo(RoleInfo),
										battle_ground_packet:make_tp(RoleId,X,Y)
								end end, TopTens),
					Msg = battle_ground_packet:encode_tangle_topman_pos_s2c(Poses),
					send_to_ground_client(Msg)
			end,
			erlang:send_after(?POS_BROAD_TIME, self(),{do_interval,[]});
		_->
			nothing
	end.

get_role_score(RoleId)->
	get_role_score(RoleId,get(ranks_info)).

get_role_score(RoleId,RanksInfo)->
	case lists:keyfind(RoleId,1,RanksInfo) of
		false->
			-1;
		{_,_,Ranks,_,_}->
			Ranks
	end.

is_has_reward(RoleId)->
	lists:member(RoleId, get(has_reward)).

%%return :[nowinfo]
add_role_score(RoleId,Score,Type)->
	case lists:keyfind(RoleId,1,get(ranks_info)) of
		false->
			[];
		{_,Name,OriScore,Kills,Time}->
			NewScore = erlang:max(OriScore+Score,0),
			if
				Type=:=killer->
					NewKills = Kills+1;
				true->
					%%NewKills = erlang:max(Kills-1,0)
					NewKills  = Kills
			end,
			put(ranks_info,lists:keyreplace(RoleId,1,get(ranks_info),{RoleId,Name,NewScore,NewKills,Time})),
			[{RoleId,Name,NewScore,NewKills,Time}]
	end.

get_role_level(RoleId)->
	case creature_op:get_creature_info(RoleId) of
		undefined->
			0;
		CreatureInfo->
			creature_op:get_level_from_creature_info(CreatureInfo)
	end.

get_type()->
	{Type,_,_} = get(tangle_info),
	Type.


get_map_proc_name(Proc)->
	atom_to_list(Proc).

get_map_proc()->
	{_,_,MapProc} = get(tangle_info),
	MapProc.

get_role_name(RoleId)->
	case lists:keyfind(RoleId,1,get(ranks_info)) of
		false->
			[];
		{RoleId,RoleName,_Ranks,_Kills,_ExtInfo}->
			RoleName
	end.
	
on_role_join({RoleId,RoleName,RoleClass,RoleGender,RoleLevel})->
	put(has_leave,lists:delete(RoleId, get(has_leave))),
	case lists:keyfind(RoleId,1,get(ranks_info)) of
		false->
			put(ranks_info,get(ranks_info) ++ [{RoleId,RoleName,0,0,{RoleClass,RoleGender,RoleLevel}}]);
		{RoleId,RoleName,Ranks,Kills,ExtInfo}->		%%rejoin? now reset
			put(ranks_info,lists:keyreplace(RoleId,1, get(ranks_info), {RoleId,RoleName,0,0,ExtInfo})),
			put(ranks_info,lists:reverse(lists:keysort(3,get(ranks_info))))
	end,
	{BattleType,BattleId,_} = get(tangle_info),
	TempInfo = lists:filter(fun({_,_,ScoreTmp,_,_})-> ScoreTmp =/= -1 end,get(ranks_info)),
	AllInfo = lists:map(fun({RoleIdTmp,RoleNameTmp,ScoreTmp,KillsTmp,{ClassTmp,GenderTmp,LevelTmp}})-> battle_ground_packet:make_tangle_battle_role(RoleIdTmp,RoleNameTmp,KillsTmp,ScoreTmp,GenderTmp,ClassTmp,LevelTmp) end,TempInfo),
	case battle_ground_manager:get_battle_start(?TANGLE_BATTLE) of
		{0,0,0}->
			TimeValue = {0,0,0};
		Time->
			TimeValue = Time
	end,
	ProtoInfo = battlefield_proto_db:get_info(?TANGLE_BATTLE),
	Duration = battlefield_proto_db:get_duration(ProtoInfo),
	LeftTime = trunc((Duration - timer:now_diff(timer_center:get_correct_now(),TimeValue)/1000)/1000),
	Message = battle_ground_packet:encode_battle_self_join_s2c(AllInfo,BattleType,BattleId,LeftTime),
	role_pos_util:send_to_role_clinet(RoleId,Message),
	MessageAdd = battle_ground_packet:encode_battle_other_join_s2c(battle_ground_packet:make_tangle_battle_role(RoleId,RoleName,0,0,RoleGender,RoleClass,RoleLevel)),
	send_to_ground_client_but(MessageAdd,RoleId).

on_role_leave(RoleId)->
	case get(is_battling) of
		true->
			put(has_leave,[RoleId|get(has_leave)]),
			case lists:keyfind(RoleId,1,get(ranks_info)) of
				false->
					nothing;
				{RoleId,RoleName,_Ranks,Kills,ExtInfo}->
					put(ranks_info,lists:keyreplace(RoleId,1, get(ranks_info), {RoleId,RoleName,-1,Kills,ExtInfo})),
					put(ranks_info,lists:reverse(lists:keysort(3,get(ranks_info)))),
					delete_role_killinfo(RoleId)
			end,
			Message = battle_ground_packet:encode_tangle_remove_s2c(RoleId),
			send_to_ground_client(Message),
			notify_manager_role_leave();
		_->
			put(has_leave,[RoleId|get(has_leave)]),
			nothing
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
							%%io:format("tangle_battle on killed ~n"),
							update_killer_info(Killer,BeKilled),
							update_bekiller_info(Killer,BeKilled),
							player_killed_score(Killer,BeKilled)
					end,
					put(ranks_info,lists:reverse(lists:keysort(3,get(ranks_info))))			%%fresh ranks
			end;
		_->
			nothing
	end.
	
%%tangle_kill_info:[killinfo],
%%killinfo:{roleid,{[{bekillroleid,num}],[{killroleid,num}]}}
delete_role_killinfo(RoleId)->
	case lists:keyfind(RoleId,1,get(tangle_kill_info)) of
		false->
			ignor;
		_->
			lists:keydelete(RoleId, 1, get(tangle_kill_info))
	end.

%%update killer's kill info
update_killer_info(Killer,BeKiller)->
	case lists:keyfind(Killer,1,get(tangle_kill_info)) of
		false->
			NewKillInfo = {Killer,{[{BeKiller,1}],[]}},
			put(tangle_kill_info,[NewKillInfo|get(tangle_kill_info)]);
		{Killer,{KillList,BeKillList}}->
			case lists:keyfind(BeKiller,1,KillList) of
				false->
					TmpKilllist = [{BeKiller,1}|KillList];
				{BeKiller,Times}->
					TmpKilllist = lists:keyreplace(BeKiller,1,KillList,{BeKiller,Times+1})
			end,
			NewKillList = lists:reverse(lists:keysort(2,TmpKilllist)),
			NewKillInfo = {Killer,{NewKillList,BeKillList}},
			put(tangle_kill_info,lists:keyreplace(Killer,1,get(tangle_kill_info),NewKillInfo))
	end.

%%update bekiller's kill info
update_bekiller_info(Killer,BeKiller)->
	case lists:keyfind(BeKiller,1,get(tangle_kill_info)) of
		false->
			NewKillInfo = {BeKiller,{[],[{Killer,1}]}},
			put(tangle_kill_info,[NewKillInfo|get(tangle_kill_info)]);
		{BeKiller,{KillList,BeKillList}}->
			case lists:keyfind(Killer,1,BeKillList) of
				false->
					TmpBeKillList = [{Killer,1}|BeKillList];
				{Killer,Times}->
					TmpBeKillList = lists:keyreplace(Killer,1,BeKillList,{Killer,Times+1})
			end,
			NewBeKillList =  lists:reverse(lists:keysort(2,TmpBeKillList)),
			NewKillInfo = {BeKiller,{KillList,NewBeKillList}},
			put(tangle_kill_info,lists:keyreplace(BeKiller,1,get(tangle_kill_info),NewKillInfo))
	end.
		
%%get self kill info
get_role_tangle_kill_info(RoleId)->
	{BattleType,BattleId,_MapProc} = get(tangle_info),
	{Date,{_,_,_}} = calendar:now_to_local_time(timer_center:get_correct_now()),
	AllKillInfo = get(tangle_kill_info),
	RankInfo = get(ranks_info),
	case lists:keyfind(RoleId,1,AllKillInfo) of
		false-> 
			Msg = battle_ground_packet:encode_tangle_kill_info_request_s2c(Date,BattleType,BattleId,[],[]);
		{RoleId,{KillInfo,BeKillInfo}}->
			CKillInfo = battle_ground_packet:make_ki(KillInfo,RankInfo),
			CBeKillInfo = battle_ground_packet:make_ki(BeKillInfo,RankInfo),
			Msg = battle_ground_packet:encode_tangle_kill_info_request_s2c(Date,BattleType,BattleId,CKillInfo,CBeKillInfo)
	end,
	role_pos_util:send_to_role_clinet(RoleId,Msg).


killed_role_broad_cast(Type,MyInfo,OtherInfo,Score)->
	ParamRole = system_chat_util:make_role_param(MyInfo),
	ParamInt = system_chat_util:make_int_param(Score),
	case (MyInfo=:=undefined) or (OtherInfo=:=undefined) of
		true ->
			nothing;
		_ ->
			if Type=:=role->
					ParamOther = system_chat_util:make_role_param(OtherInfo),
					MsgInfo = [ParamRole, ParamOther, ParamInt],
					system_chat_op:system_broadcast_instance(?SYSTEM_CHAT_TANGLE_BATTLE_ROLE_KILLED,MsgInfo,tangle_battle:get_map_proc_name(get_map_proc()));
				true->
					OtherName = get_name_from_npcinfo(OtherInfo),
					ParamString = system_chat_util:make_string_param(OtherName),
					MsgInfo = [ParamRole,ParamString],
					system_chat_op:system_broadcast_instance(?SYSTEM_CHAT_TANGLE_BATTLE_MONSTER_KILLED,MsgInfo,tangle_battle:get_map_proc_name(get_map_proc()))
			end
	end.		
	

on_destroy()->
	notify_role_reward(),
	put(is_battling,false),
	put(can_reward,true),
	MapProc = get_map_proc(),
	erlang:send_after(?BUFFER_TIME_S*1000,MapProc, {on_destroy}),
	erlang:send_after(?BUFFER_TIME_S*1000,self(), {destory_self}).
	
destroy_self()->
	send_to_ground({battle_leave_c2s}),
	send_reward_mail(),
	put(can_reward,false),
	write_to_db(),
	save_role_kill_num().

notify_role_reward()->
	Fun = fun({RoleId,_,_,_,_})->
					{Honor,Exp,_} = case get_role_score(RoleId) of
										-1->
											{0,0,[]};
										Score->
											Rank = get_my_rank_by_score(Score),
											get_rewards_by_rank(Rank)
									end,
					role_pos_util:send_to_role(RoleId, {battle_reward_honor_exp,?TANGLE_BATTLE,Honor,Exp})
			end,
	lists:foreach(Fun, get(ranks_info)).

send_reward_mail()->
	Fun = fun({RoleId,RoleName,_,_,_})->
				  case lists:member(RoleId, get(has_reward)) of
					  false->
						put(has_reward,[RoleId|get(has_reward)]),
				    	FromName = language:get_string(?STR_BATTLE_MAIL_SIGN),
						Title = language:get_string(?STR_TANGLE_BATTLE_MAIL_TITLE),
						ContextFormat = language:get_string(?STR_TANGLE_BATTLE_MAIL_CONTENT),
						{_,_,Items} = case get_role_score(RoleId) of
										-1->
											{0,0,[]};
										Score->
											Rank = get_my_rank_by_score(Score),
											get_rewards_by_rank(Rank)
									end,
						lists:foreach(fun({ItemId,Count})->
											gm_op:gm_send_rpc(FromName,RoleName,Title,ContextFormat,ItemId,Count,0)	
										end,Items);
					  _->
						  ignor
				  end
			end,
	lists:foreach(Fun, get(ranks_info)).
	
save_role_kill_num()->
	lists:foreach(fun({RoleId,{KillInfo,_}})->
						Num = lists:foldl(fun({_,Num},Acc)->
												Acc+Num
											end,0,KillInfo),
						Old_KillNum = tangle_battle_db:get_role_totle_killnum(RoleId),
						NewNum = Old_KillNum + Num,
						tangle_battle_db:add_tangle_battle_role_killnum(RoleId,NewNum)
					end,get(tangle_kill_info)).

write_to_db()->
	{Class,Index,MapProc} = get(tangle_info),
	{Part1,{_,_,_}} = calendar:now_to_local_time(timer_center:get_correct_now()),
	Date = Part1,
	Info = get(ranks_info),
	RewardRecord = get(has_reward),	
	TangleKillInfo = get(tangle_kill_info),
	tangle_battle_db:clear_battle_info(),
	tangle_battle_db:clear_battle_kill_info(),
	tangle_battle_db:sync_add_tangle_battle_kill_info(Date,Class,Index,TangleKillInfo),
	tangle_battle_db:sync_add_battle_info(Date,Class,Index,Info,RewardRecord).

on_reward(RoleId)->
	case (not get(is_battling)) and (not is_has_reward(RoleId)) and (get(can_reward)) of
		true->
			put(has_reward,[RoleId|get(has_reward)]),
			case get_role_score(RoleId) of
				-1->
					{0,0,[]};
				Score->
					Rank = get_my_rank_by_score(Score),
					get_rewards_by_rank(Rank)
			end;
		_->
			{0,0,[]}
	end.

%%
%%根据rankinfo计算RoleId的奖励
%%
get_reward_by_rankinfo(RoleId,RankInfo)->
	Score = get_role_score(RoleId,RankInfo),
	Rank = get_my_rank_by_score(Score,RankInfo),
	get_rewards_by_rank(Rank).
	
get_my_rank_by_score(Score)->
	get_my_rank_by_score(Score,get(ranks_info)).
get_my_rank_by_score(Score,RanksInfo)->
	{_,Tmprank} = lists:foldl(fun({_,_,Ranks,_,_},{Re,Tmprank})->
				if
					Re or (Ranks=:=Score)->
						{true,Tmprank};
					true->
						{false,Tmprank+1}
				end
		end,{false,1},RanksInfo),
	Tmprank.				   


get_rewards_by_rank(Rank)->
	if
		Rank>?MAX_TANGLE_RECORD_RANK->
			EndRank = util:even_div(Rank,?MAX_TANGLE_RECORD_RANK)*?MAX_TANGLE_RECORD_RANK;
		true ->
			EndRank = Rank
	end,
	get_addapt_battlefield_reward_info(EndRank).
	
get_addapt_battlefield_reward_info(Rank)->
	ets:foldl(fun({_,Info},{HonorTemp,ExpTemp,ItemTemp})->
					[UpEdge,DownEdge] = Info#tangle_reward_info.rankedge,
					if
						(Rank >= UpEdge) and (Rank =< DownEdge) ->
							Honor = Info#tangle_reward_info.honor,
							Exp = Info#tangle_reward_info.exp,
							Items = Info#tangle_reward_info.item, 
							{Honor,Exp,Items};
						true->
							{HonorTemp,ExpTemp,ItemTemp}
					end
				end,{0,0,[]},?TANGLE_REWARD_INFO_ETS).

creature_killed_score(Killer,BeKilledNpc)->
	 NpcInfo = creature_op:get_creature_info(BeKilledNpc),
	 KillerInfo = creature_op:get_creature_info(Killer),
	 CreatureV = get_maxsilver_from_npcinfo(NpcInfo),
	 killed_role_broad_cast(npc,KillerInfo,NpcInfo,CreatureV),
	 case add_role_score(Killer,CreatureV,killer) of
		[]->
			nothing;
		[{_,RoleName,Score,Kills,{RoleClass,RoleGender,RoleLevel} }]->
			RoleInfo = battle_ground_packet:make_tangle_battle_role(Killer,RoleName,Kills,Score,RoleGender,RoleClass,RoleLevel),
			Message = battle_ground_packet:encode_tangle_update_s2c([RoleInfo]),
			send_to_ground_client(Message)
	end.

player_killed_score(Killer,BeKilled)->
	{AddScore,SubScore} = calculate_player_killed_score(Killer,BeKilled),
	BeKillInfo = creature_op:get_creature_info(BeKilled),
	KillerInfo = creature_op:get_creature_info(Killer),
	case (BeKillInfo =/= undefined) and (KillerInfo=/= undefined) of
		true->   
			killed_role_broad_cast(role,KillerInfo,BeKillInfo,AddScore),
			Infos = add_role_score(Killer,AddScore,killer) ++ add_role_score(BeKilled,SubScore,bekiller),
			RoleInfos = lists:map(fun({RoleId,RoleName,Score,Kills,{RoleClass,RoleGender,RoleLevel}})-> battle_ground_packet:make_tangle_battle_role(RoleId,RoleName,Kills,Score,RoleGender,RoleClass,RoleLevel) end,Infos),
			if
				RoleInfos =/= []->
					Message = battle_ground_packet:encode_tangle_update_s2c(RoleInfos),
					send_to_ground_client(Message);
				true->
					nothing
			end
	end.

get_score_rate_by_rank(Rank)->
	if
		Rank=:=1 ->
			5;
		Rank=<3->
			5.5;
		Rank=<6->
			6;
		Rank=<8->
			6.5;
		Rank=<10->
			7;
		Rank=<20->
			8;
		Rank=<30->
			9;
		true->
			10
	end.
		
%%returen{AddScore,SubScore}
%%max(roundup((other_level - self_level + other_score )/score_rate),1)
calculate_player_killed_score(KillerRole,BeKilledRole)->
	BeKilledScore = get_role_score(BeKilledRole),
	BeKilledRank = get_my_rank_by_score(BeKilledScore),
	ScroreRate = get_score_rate_by_rank(BeKilledRank),
	AddScore = erlang:max(1,util:even_div(get_role_level(BeKilledRole) - get_role_level(KillerRole) + BeKilledScore, ScroreRate)),
	if
		BeKilledRank=<10->
			{AddScore,-trunc(AddScore/2)};
		true->
			{AddScore,0}
	end.

send_to_ground(Message)->
	lists:foreach(fun({RoleId,_,_,_,_})->
			case lists:member(RoleId, get(has_leave)) of
				false->
					role_op:send_to_other_role(RoleId,Message);
				_->
					nothing
			end
			end,get(ranks_info)).
	
send_to_ground_client(Message)->
	lists:foreach(fun({RoleId,_,_,_,_})->
			case lists:member(RoleId, get(has_leave)) of
				false->
					role_op:send_to_other_client(RoleId,Message);
				_->
					nothing
			end			  
			end,get(ranks_info)). 
	
send_to_ground_client_but(Message,NotId)->
	lists:foreach(fun({RoleId,_,_,_,_})->
				case (NotId=/=RoleId) and (not lists:member(RoleId, get(has_leave))) of
					true-> 
						role_op:send_to_other_client(RoleId,Message);
					_->
						nothing
				end
	end,get(ranks_info)). 

%%
%%֪ͨmanagerս���Ѿ�����
%%
notify_manager_battle_start(BattleType,BattleId)->
	battle_ground_manager:notify_manager_battle_start(?TANGLE_BATTLE,{BattleType,BattleId}).

notify_manager_role_leave()->
%%	io:format("notify_manager_role_leave ~n"),
	{BattleType,BattleId,_} = get(tangle_info),
	battle_ground_manager:notify_manager_role_leave(?TANGLE_BATTLE,{BattleType,BattleId}).
