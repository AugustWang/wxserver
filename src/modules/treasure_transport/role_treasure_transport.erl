%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-10-8
%% Description: TODO: Add description to role_treasure_transport
-module(role_treasure_transport).

-compile(export_all).

-include("treasure_transport_define.hrl").
-include("system_chat_define.hrl").
-include("common_define.hrl").
-include("activity_define.hrl").
-include("little_garden.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").

%%==================================================================
%%rob_treasure_transport_times:last_rob_time,rob_times				%%
%%																	%%
%%role_treasure_transport:type,car_quality,bonus,accept_quest_time	%%
%%																	%%
%%is_treasure_transport:true/false									%%
%%==================================================================

load_from_db(RoleId)->
	case treasure_transport_db:get_role_treasure_transport_info(RoleId) of
		[] ->
			put(rob_treasure_transport_times,{{0,0,0},0}),
			put(role_treasure_transport,{0,0,0,{0,0},{0,0,0}}),
			put(is_treasure_transport,false);
		{_,RoleId,QuestId,Type,Quality,Bonus,Recev_time,Last_Rob_Time,Rob_times}->
			put(role_treasure_transport,{QuestId,Type,Quality,Bonus,Recev_time}),
			case timer_util:check_same_day(now(),Last_Rob_Time) of
				true ->
					put(rob_treasure_transport_times,{Last_Rob_Time,Rob_times});
				false ->
					put(rob_treasure_transport_times,{{0,0,0},0})
			end,
			check_transport_overdue()
	end.

hook_on_line()->
	activity_manager:treasure_transport_online_notic(get(roleid)).

export_for_copy()->
	{get(role_treasure_transport),get(is_treasure_transport),get(rob_treasure_transport_times)}.

load_by_copy(TransportInfo)->
	{Role_Transport,Is_Transport,Rob_times} = TransportInfo,
	put(role_treasure_transport,Role_Transport),
	put(is_treasure_transport,Is_Transport),
	put(rob_treasure_transport_times,Rob_times).

accept_treasure_transport_quest(QuestId,Quality)->
	achieve_op:achieve_update({treasure_transport},[0]),%%@@wb20130329 [quality]
	{Bonusexp,Bonusmoney} = get_reward_exp_money_bonus(),
	role_op:add_buffers_by_self([?ROLE_TREASURE_TRANSPORT_BUFFERS]),
	update_treasure_transport_to_role(Quality),   
	check_broadcast(?SYSTEM_CHAT_COM_TREASURE_TRANSPORT,get(creature_info),Quality),
	put(role_treasure_transport,{QuestId,Quality,Quality,{Bonusexp,Bonusmoney},now()}),
	put(is_treasure_transport,true),
	send_left_time_to_client(?ONE_HOUR).

treasure_transport_over()->
	role_op:remove_buffers([?ROLE_TREASURE_TRANSPORT_BUFFERS]),
	update_treasure_transport_to_role(?TREASURE_TRANSPORT_OVER),
	put(is_treasure_transport,false),
	put(role_treasure_transport,{0,0,0,{0,0},{0,0,0}}).

treasure_transport_failed(QuestId)->
	quest_op:proc_role_quest_quit(QuestId),
	{Rewardexp,_} = get_reward_exp_moneys(),%%@@wb20130420 é•–è½¦è¢«åŠ«åŽç»éªŒå¥–åŠ±ä¸å˜
	Message = treasure_transport_packet:encode_treasure_transport_failed_s2c(Rewardexp),
	role_op:send_data_to_gate(Message).

update_treasure_transport_to_role(Value)->
	NewInfo = set_treasure_transport_to_roleinfo(get(creature_info),Value),
	put(creature_info,NewInfo),
	role_op:update_role_info(get(roleid),NewInfo),
	role_op:self_update_and_broad([{treasure_transport,Value}]).

check_transport_overdue()->
	{QuestId,Type,Quality,{Bonusexp,Bonusmoney},Recev_time} = get(role_treasure_transport),
	if Type =/= 0 ->
			case check_is_overdue(now(),Recev_time) of
				true ->
					gm_logger_role:treasure_transport_failed(get(roleid),Quality,Bonusexp,Bonusmoney,overdue),
					treasure_transport_failed(QuestId);
				false ->
					role_op:add_buffers_by_self([?ROLE_TREASURE_TRANSPORT_BUFFERS]),
					LeftTime = ?ONE_HOUR - trunc(timer:now_diff(now(),Recev_time)/1000000),
					send_left_time_to_client(LeftTime),
					update_treasure_transport_to_role(Quality),
					put(is_treasure_transport,true)
			end;
	   true->
		   put(is_treasure_transport,false)
	end.

%%
%%return:{Rewardexp,[{Type,RewardeMoney}]}
%%
get_reward_exp_moneys()->
	{_,Type,Quality,{Bonusexp,Bonusmoney},_} = get(role_treasure_transport),
	TransportInfo = treasure_transport_db:get_treasure_transport_info(get(level)),
	case Quality =/=0 of
		true->
			Quality_bonus_info = treasure_transport_db:get_treasure_transport_quality_bonus_info(Quality),
			Quality_bonus = treasure_transport_db:get_treasure_transport_quality_bonus(Quality_bonus_info),
			RewardExp = treasure_transport_db:get_treasure_transport_rewardexp(TransportInfo),
			{MoneyType,RewardMoney} = treasure_transport_db:get_treasure_transport_reward_money(TransportInfo),
			case Type of
				?TREASURE_TRANSPORT_OVER->
					{trunc(RewardExp*Quality_bonus*Bonusexp),[]};
				_ ->
					{trunc(RewardExp*Quality_bonus*Bonusexp),[{MoneyType,trunc(RewardMoney*Quality_bonus*Bonusmoney)}]}
			end;
		_->
			{0,[{?MONEY_BOUND_SILVER,0}]}
	end.
			
%%return:0/1/2/3/4/5
get_transport_type()->
	{_,Type,_,_,_} = get(role_treasure_transport),
	Type.
%%
%%return:true/false
%%
is_treasure_transporting()->
	get(is_treasure_transport).

check_is_overdue(NowTime,Recev_time)->
	LeftTime = trunc(timer:now_diff(NowTime,Recev_time)/1000000),
	if LeftTime < ?ONE_HOUR_FOR_CHECK ->
		   false;
	   true ->
		   true
	end.

send_left_time_to_client(Left_time)->
	Message = treasure_transport_packet:encode_treasure_transport_time_s2c(Left_time),
	role_op:send_data_to_gate(Message).

system_broadcast(SysId,RoleInfo,EnemyInfo)->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamOther = system_chat_util:make_role_param(EnemyInfo),
	MsgInfo = [ParamOther,ParamRole],
	system_chat_op:system_broadcast(SysId,MsgInfo).

check_broadcast(SysId,RoleInfo,Quality)->
	case Quality >= ?BROADCAST_CAR_EDGE of
		true->
			QualityNum = lists:nth(Quality,?TREASURE_TRANSPORT_CAR),
			String = language:get_string(QualityNum),
			Color = pet_util:get_pet_quality_color(Quality),
			ParamRole = system_chat_util:make_role_param(RoleInfo),
			ParamString = system_chat_util:make_string_param(String,Color),
			MsgInfo = [ParamRole,ParamString],
			system_chat_op:system_broadcast(SysId,MsgInfo);
		false->
			nothing
	end.

system_broadcast(SysId,RoleInfo,EnemyId,EnemyName,EnemyServerId)->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamOther = chat_packet:makeparam(role,{EnemyId,EnemyName,EnemyServerId}),
	MsgInfo = [ParamOther,ParamRole],
	system_chat_op:system_broadcast(SysId,MsgInfo).
	  
hook_on_dead(EnemyId,EnemyName)->
	case is_treasure_transporting() of
		true ->
			{QuestId,_,Quality,{Bonusexp,Bonusmoney},_} = get(role_treasure_transport),
			RewardInfo = treasure_transport_db:get_treasure_transport_info(get(level)),
			{_,RewardMoney} = treasure_transport_db:get_treasure_transport_reward_money(RewardInfo),
			Quality_bonus_info = treasure_transport_db:get_treasure_transport_quality_bonus_info(Quality),
			Quality_bonus = treasure_transport_db:get_treasure_transport_quality_bonus(Quality_bonus_info),
			OtherReward = trunc(get(level)/100*RewardMoney*Quality_bonus),
			MyName = get_name_from_roleinfo(get(creature_info)),
			role_pos_util:send_to_role(EnemyId,{treasure_transport,{rob_treasure_transport,MyName,OtherReward}}),
			{Rewardexp,_} = get_reward_exp_moneys(),
			treasure_transport_failed(QuestId),
			gm_logger_role:treasure_transport_failed(get(roleid),Quality,Bonusexp,Bonusmoney,be_killed),
			role_op:obtain_exp(trunc(Rewardexp)),
			case creature_op:get_creature_info(EnemyId) of
				undefined->
					system_broadcast(?SYSTEM_CHAT_ROB_TREASURE_TRANSPORT,get(creature_info),EnemyId,EnemyName,0);
				EnemyInfo ->
					system_broadcast(?SYSTEM_CHAT_ROB_TREASURE_TRANSPORT,get(creature_info),EnemyInfo)
			end;
		_ ->
			nothing
	end.
	
rob_treasure_transport(OtherName,RewardMoney)->
	{_,Rob_times} = get(rob_treasure_transport_times),
	case Rob_times < ?ROLE_ROB_MAX_TIMES of
		true->
			Message = treasure_transport_packet:encode_rob_treasure_transport_s2c(OtherName,RewardMoney),
			role_op:send_data_to_gate(Message),
			role_op:money_change(?MONEY_SILVER,RewardMoney,rob_treasure_transport),
			put(rob_treasure_transport_times,{now(),Rob_times+1});
		false->
			nothing
	end.

hook_on_offline()->
	case get(role_treasure_transport) of
		{QuestId,Type,Quality,Bonus,Recev_time}->
			case get(rob_treasure_transport_times) of
				{Last_Rob_Time,Rob_times}->
					treasure_transport_db:add_role_treasure_transport(get(roleid),QuestId,Type,Quality,Bonus,Recev_time,Last_Rob_Time,Rob_times);
				_->
					nothing
			end;
		_->
			nothing
	end.

%%return:{Bonusexp,Bnusmoney}
get_reward_exp_money_bonus()->
	InfoList = answer_db:get_activity_info(?TREASURE_TRANSPORT_ACTIVITY),
	NowTime = calendar:now_to_local_time(now()),
	IsServer_Transport = lists:foldl(fun(Info,Acc)->
										{_,StartLines} = answer_db:get_activity_start(Info),
										if
											Acc->
												Acc;
											true->
												timer_util:check_dateline(NowTime,StartLines)
										end
									end,false,InfoList),
	IsGuild_Transport = guild_manager:check_is_guild_transport(guild_util:get_guild_id()),
	if
		IsServer_Transport and IsGuild_Transport->
			{?NORMAL_TRANSPORT_BONUS + ?SERVER_TRANSPORT_BONUS + ?GUILD_TRANSPORT_BONUS,?NORMAL_TRANSPORT_BONUS + ?SERVER_TRANSPORT_BONUS};
		IsServer_Transport and (not IsGuild_Transport)->
			{?NORMAL_TRANSPORT_BONUS + ?SERVER_TRANSPORT_BONUS,?NORMAL_TRANSPORT_BONUS + ?SERVER_TRANSPORT_BONUS};
		IsGuild_Transport and (not IsServer_Transport)->
			{?NORMAL_TRANSPORT_BONUS + ?GUILD_TRANSPORT_BONUS,?NORMAL_TRANSPORT_BONUS};
		true->
			{?NORMAL_TRANSPORT_BONUS,?NORMAL_TRANSPORT_BONUS}
	end.
	
start_guild_treasure_transport()->
	guild_handle:handle_guild_treasure_transport().
	
treasure_transport_call_guild_help()->
	case get(is_treasure_transport) of
		false->
			ignor;
		_->
			guild_handle:handle_treasure_transport_call_guild_help()
	end.			