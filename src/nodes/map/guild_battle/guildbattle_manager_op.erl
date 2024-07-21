%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-11-1
%% Description: TODO: Add description to guildbattle_manager_op
-module(guildbattle_manager_op).

%%
%% Include files
%%
-include("common_define.hrl").
-include("guildbattle_define.hrl").
-include("string_define.hrl").
-include("error_msg.hrl").
-include("system_chat_define.hrl").
-include("npc_define.hrl").
-include("country_define.hrl").
-define(CHECK_TIME,2000).
-define(BATTLE_NAME,kingdom_battle).

%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%

init()->
	put(state,?GUILDBATTLE_IDLE),
	put(guildlist,[]),	%%{guildid,guildname,leaderid,leadername,index}
	put(applylist,[]),	%%{guildid,guildname,score,getthrone,applyindex}
	put(battleplayer,[]),	%%{guildid,bornposindex}
	put(battleinfo,[]),
	put(thronestate,[]),	%%{state,guildindex,roleid,rolename,roleclass,rolegender,starttime}
	put(role_list,[]),
	init_guildbattle_result(),
	send_check().

reinit()->
	put(state,?GUILDBATTLE_IDLE),
	put(guildlist,[]),	
	put(applylist,[]),	
	put(battleplayer,[]),	
	put(battleinfo,[]),
	put(thronestate,[]),	
	init_guildbattle_result(),
	put(role_list,[]).

init_guildbattle_result()->
	case guildbattle_db:get_guildbattle_score() of
		[]->
			put(guildbattle_result,[]);
		Info->
			Result = lists:map(fun({_,GuildName,Score,Rank})->
								  {GuildName,Score,Rank}
								end,Info),
			put(guildbattle_result,Result)
	end.

%%
%% {State,{Node,Proc},battleplayer}
%%
get_battle_info()->
	{get(state),get(battleinfo),get(battleplayer)}.

get_guild_info()->
	todo.

on_role_join(RoleId,_GuildId)->
	put(role_list,[RoleId|get(role_list)]),
	%%send init	
	Gbs = lists:map(fun({GuildId,Guildname,_,_,Index})-> 
							guildbattle_packet:make_gbs(Index,GuildId,Guildname) 
					end,get(applylist)),
	InitMsg = guildbattle_packet:encode_guild_battle_score_init_s2c(Gbs),
	role_pos_util:send_to_role_clinet(RoleId,InitMsg),
	case get(state) of
		?GUILDBATTLE_FAIGHT->
			%%send score
			lists:foreach(fun({_,_,Score,_,Index})->
							if
								Score =:= 0->
									nothing;
								true->
									ScoreUpdateMsg = guildbattle_packet:encode_guild_battle_score_update_s2c(Index,Score),
									role_pos_util:send_to_role_clinet(RoleId,ScoreUpdateMsg)
							end
				end,get(applylist)),
			%%send thronestate
			case get(thronestate) of
				{?THRONE_STATE_TAKING,GuildIndex,AttackRoleId,RoleName,RoleClass,RoleGender,StartTime}->
					LeftTimes = erlang:max(?THRONE_TAKE_TIME_S - trunc(timer:now_diff(now(), StartTime)/1000000),0), 
					ThroneMsg = guildbattle_packet:encode_guild_battle_status_update_s2c(?THRONE_STATE_TAKING,LeftTimes,GuildIndex,AttackRoleId,RoleName,RoleClass,RoleGender),
					role_pos_util:send_to_role_clinet(RoleId,ThroneMsg);
				_->
					ThroneMsg = guildbattle_packet:encode_guild_battle_status_update_s2c(?THRONE_STATE_NULL,0,0,0,[],0,0),
					role_pos_util:send_to_role_clinet(RoleId,ThroneMsg)
			end;
		_->
			nothing
	end.
	

on_role_leave(RoleId,GuildId)->
	put(role_list,get(role_list) -- [RoleId]).

on_kill_other(_RoleId,GuildId,_OtherId)->
	case get(state) of
		?GUILDBATTLE_FAIGHT->
			%%io:format("on_kill_other ~p ~p ~n",[get(applylist),GuildId]),
			case lists:keyfind(GuildId, 1, get(applylist)) of
				false->
					%%io:format("on_kill_other 1111===========~n"),
					nothing;
				{_,GuildName,OldScore,GetThrone,ApplyIndex}->
					NewScore = OldScore + ?GUILDBATTLE_KILL_SCORE,
					NewApplyList = lists:keyreplace(GuildId, 1, get(applylist), {GuildId,GuildName,NewScore,GetThrone,ApplyIndex}),
					put(applylist,NewApplyList),
					%%io:format("on_kill_other 22222222===========~n"),
					update_guild_score(ApplyIndex,NewScore)
			end;
		_->
			nothing
	end.

role_online(RoleId,GuildId)->
	State =  get(state),
	%%io:format("role_online =============== ~n"),
	catch 	
		if
			State =/= ?GUILDBATTLE_FAIGHT, State =/= ?GUILDBATTLE_READY->
				throw(nothing);
			true->
				case lists:keyfind(GuildId,1,get(battleplayer)) of
					false->
						throw(nothing);
					_->
						%%io:format("role_online 111111111===============~n"),
						BinMsg = guildbattle_packet:encode_guild_battle_start_s2c(),
						role_pos_util:send_to_role_clinet(RoleId,BinMsg)
				end
		end.
change_throne_state(State,GuildId,RoleId,RoleName,RoleClass,RoleGender,StartTime)->
	%%io:format("change_throne_state ~p ~n",[{State,GuildId,RoleId,RoleName,StartTime}]),
	case get(state) of
		?GUILDBATTLE_FAIGHT->
			case State of
				?THRONE_STATE_TAKING->
					case lists:keyfind(GuildId, 1, get(applylist)) of
						false->
							nothing;
						{_,_,_,_,GuildIndex}->				
							put(thronestate,{State,GuildIndex,RoleId,RoleName,RoleClass,RoleGender,StartTime}),
							update_throne_state()
					end;
				?THRONE_STATE_TAKED->
					case lists:keyfind(GuildId, 1, get(applylist)) of
						false->
							nothing;
						{_,GuildName,Score,GetThrone,GuildIndex}->				
							put(thronestate,{State,GuildIndex,RoleId,RoleName,RoleClass,RoleGender,StartTime}),
							update_throne_state(),
							NewApplyList = lists:keyreplace(GuildId, 1, get(applylist), {GuildId,GuildName,Score,true,GuildIndex}),
							put(applylist,NewApplyList),
							battle_over(),
							reinit()
					end;
				_->
					put(thronestate,{State,0,0,[],0,0,{0,0,0}}),
					update_throne_state()
			end;
		_->
			nothing
	end.

change_battle_fight()->
	case get(state) of
		?GUILDBATTLE_READY->
			change(?GUILDBATTLE_FAIGHT);
		_->
			nothing
	end.
%%
%%return Errno
%%
apply_battle(RoleId,GuildId)->
	case get(state) of
		?GUILDBATTLE_APPLY->
			case lists:keyfind(GuildId, 1, get(guildlist)) of
				false->
					Errno = ?ERRNO_GUILDBATTLE_DISQUALIFIED;
				{GuildId,GuildName,RoleId,_,_}->
					case lists:keyfind(GuildId,1,get(applylist)) of
						false->
								case guild_manager:check_and_cast_money(GuildId,?GUILDBATTLE_APPLY_SILVER,apply_guild_battle) of
									ok->
										ApplyIndex = erlang:length(get(applylist)) + 1,
										put(applylist,[{GuildId,GuildName,0,false,ApplyIndex}|get(applylist)]),
										gm_logger_guild:guildbattle_apply(GuildId,RoleId,?BATTLE_NAME),
										Errno = ?ERRNO_GUILDBATTLE_APPLY;
									money_not_enough->
										Errno = ?ERRNO_GUILD_LESS_MONEY;
									_->
										Errno = ?ERROR_UNKNOWN
								end;							
						_->
							Errno = ?ERRNO_GUILDBATTLE_ALREADY_APPLY
					end;
				_->
					Errno = ?ERRNO_GUILDBATTLE_DISQUALIFIED
			end;				
		_->
			Errno = ?ERRNO_GUILDBATTLEAPPLY_TIME_ERROR
	end,
%%	io:format("apply_battle ~p ~n",[{RoleId,GuildId,Errno}]),
	Errno.


change_leaderinfo(RoleId,GuildId)->
	case get(state) of
		?GUILDBATTLE_APPLY->
			case lists:keyfind(GuildId, 1, get(guildlist)) of
				false->
					nothing;
				{GuildId,GuildName,_RoleId,_,Index}->
					if
						_RoleId =:= RoleId->
							nothing;
						true->
							%% get rolename
							case role_db:get_role_info(RoleId) of
								[]->
									nothing;
								RoleAttrInfo->
				  					RoleName = role_db:get_name(RoleAttrInfo),
									NewGuildInfo = {GuildId,GuildName,RoleId,RoleName,Index},
									NewGuildList = lists:keyreplace(GuildId,1,get(guildlist),NewGuildInfo),
									put(guildlist,NewGuildList),
									slogger:msg("change leader info success old ~p new ~p guild ~p ~n",[_RoleId,RoleId,GuildId])
							end
					end;
				_->
					nothing
			end;				
		_->
			nothing
	end.

change_guild_name(GuildId,NewNameStr)->
	put(guildlist,[]),	%%{guildid,guildname,leaderid,leadername,index}
	case lists:keyfind(GuildId,1,get(guildlist)) of
		false->
			nothing;
		{_,_,LeaderId,LeaderName,Index}->
			NewGuildList = lists:keyreplace(GuildId,1,get(guildlist),{GuildId,NewNameStr,LeaderId,LeaderName,Index}),
			put(guildlist,NewGuildList)
	end.
	
change_role_name(RoldId,NewNameStr)->
	put(guildlist,[]),	%%{guildid,guildname,leaderid,leadername,index}
	case lists:keyfind(RoldId,3,get(guildlist)) of
		false->
			nothing;
		{GuildId,GuildName,_,_,Index}->
			NewGuildList = lists:keyreplace(GuildId,1,get(guildlist),{GuildId,NewNameStr,RoldId,NewNameStr,Index}),
			put(guildlist,NewGuildList)
	end.

%%
%% Local Functions
%%
send_check()->
	erlang:send_after(?CHECK_TIME,self(),{battle_check}).
	
on_check()->
	on_check(get(state)),
	send_check().
		
on_check(?GUILDBATTLE_IDLE)->
	Now = timer_center:get_correct_now(),
	LocalTime = calendar:now_to_local_time(Now),
	{Today,NowTime} = LocalTime, 
	Week = calendar:day_of_the_week(Today),
	case guildbattle_db:get_info(Week) of
		[]->
			nothing;
		Info->
			CheckTime = guildbattle_db:get_checktime(Info),
			ApplyStopTime = guildbattle_db:get_stopapplytime(Info),
			%%
			%%if now later than stop apply time   cancel check 
			%%
			case timer_util:compare_time(NowTime,CheckTime) of
				true->		%% CheckTime > NowTime
					nothing;
				_->
					case timer_util:compare_time(NowTime,ApplyStopTime) of
						true-> 	%% ApplyStopTime > NowTime
							check_guild();		
						_->
							nothing
					end
			end
	end;

on_check(?GUILDBATTLE_CHECK)->
	%%check apply start
	Now = timer_center:get_correct_now(),
	LocalTime = calendar:now_to_local_time(Now),
	{Today,NowTime} = LocalTime, 
	Week = calendar:day_of_the_week(Today),
	case guildbattle_db:get_info(Week) of
		[]->
			nothing;
		Info->
			ApplyStartTime = guildbattle_db:get_startapplytime(Info),
			ApplyStopTime = guildbattle_db:get_stopapplytime(Info),			
			case timer_util:compare_time(NowTime,ApplyStartTime) of
				true->		%% ApplyStartTime > NowTime
					nothing;
				_->
					case timer_util:compare_time(ApplyStopTime,NowTime) of
						true-> 	%% ApplyStopTime < NowTime
							reinit();
						_->
							put(applylist,[]),
							change(?GUILDBATTLE_APPLY),
							LeftTime = calendar:time_to_seconds(ApplyStopTime) - calendar:time_to_seconds(NowTime),
							StartApplyMsg = guildbattle_packet:encode_guild_battle_start_apply_s2c(LeftTime),
							broadcast_to_all(StartApplyMsg)
					end
			end
	end;

on_check(?GUILDBATTLE_APPLY)->
	%%check apply stop
	Now = timer_center:get_correct_now(),
	LocalTime = calendar:now_to_local_time(Now),
	{Today,NowTime} = LocalTime, 
	Week = calendar:day_of_the_week(Today),
	case guildbattle_db:get_info(Week) of
		[]->
			nothing;
		Info->
			ApplyStartTime = guildbattle_db:get_startapplytime(Info),
			ApplyStopTime = guildbattle_db:get_stopapplytime(Info),			
			case timer_util:compare_time(NowTime,ApplyStartTime) of
				true->		%% ApplyStartTime > NowTime
					put(guildlist,[]),
					change(?GUILDBATTLE_IDLE),
					send_stop_apply_message();
				_->
					case timer_util:compare_time(ApplyStopTime,NowTime) of
						false-> 	%% ApplyStopTime > NowTime
							nothing;
						_->
							ApplyLen = length(get(applylist)),
							if
								ApplyLen >= ?GUILDBATTLE_MIN_GUILD_NUM ->
									send_stop_apply_message(),
									change(?GUILDBATTLE_AFTER_APPLY);
								true->
									send_stop_apply_message(),
									country_manager:change_king_and_bestguild(0,{0,0},[]),
									reinit()
							end
					end
			end
	end;

on_check(?GUILDBATTLE_AFTER_APPLY)->
	%%check battle start
	Now = timer_center:get_correct_now(),
	LocalTime = calendar:now_to_local_time(Now),
	{Today,NowTime} = LocalTime, 
	Week = calendar:day_of_the_week(Today),
	case guildbattle_db:get_info(Week) of
		[]->
			nothing;
		Info->
			BattleStartTime = guildbattle_db:get_starttime(Info),
			BattleStartTime_S = calendar:time_to_seconds(BattleStartTime),
			NowTime_S = calendar:time_to_seconds(NowTime),
			case timer_util:compare_time(NowTime,BattleStartTime) of
				true->		%% BattleStartTime > NowTime
					nothing;
				_->
					case ((BattleStartTime_S + ?GUILDBATTLE_DURATION_TIME_S) > NowTime_S) of
						true->
							%%start battle 
							start_battle();
						_->
							cancel_battle(),
							reinit()
					end
			end
	end;

on_check(?GUILDBATTLE_FAIGHT)->
	%%check battle stop
	Now = timer_center:get_correct_now(),
	LocalTime = calendar:now_to_local_time(Now),
	{Today,NowTime} = LocalTime, 
	Week = calendar:day_of_the_week(Today),
	case guildbattle_db:get_info(Week) of
		[]->
			nothing;
		Info->
			BattleStartTime = guildbattle_db:get_starttime(Info),
			BattleStartTime_S = calendar:time_to_seconds(BattleStartTime),
			NowTime_S = calendar:time_to_seconds(NowTime),
			case timer_util:compare_time(NowTime,BattleStartTime) of
				true->		%% BattleStartTime > NowTime
					battle_stop(),
					reinit();
				_->
					case ((BattleStartTime_S + ?GUILDBATTLE_DURATION_TIME_S) > NowTime_S) of
						true->
							nothing;
						_->
							battle_over(),
							reinit()
					end
			end
	end;
	
on_check(_)->
	nothing.

check_guild()->
	RetGuild = guild_manager:guildbattle_check(),
	if 
		is_list(RetGuild)->
			put(guildlist,RetGuild),
			lists:foreach(fun({GuildId,_,_,_,Index})->
								gm_logger_guild:guildbattle_check(GuildId,Index,?BATTLE_NAME) 
			  				end,get(guildlist)),
			send_mail_to_guildleader(),
			guild_manager:notify_guild_have_guildbattle_right(RetGuild),
			change(?GUILDBATTLE_CHECK);
		true->
			nothing
	end.

change(NewState)->
	%%io:format("=========~p change ~p ~n",[?MODULE,NewState]),
	put(state,NewState).

send_mail_to_guildleader()->
	%%io:format("send_mail_to_guildleader ======================= ~n"),
	{Today,_} = calendar:now_to_local_time(now()),
	Week = calendar:day_of_the_week(Today),
	case guildbattle_db:get_info(Week) of
		[]->
			nothing;
		BattleProtoInfo->
			send_mail_to_guildleader(Today,BattleProtoInfo)
	end.

send_mail_to_guildleader({Year,Mon,Day},BattleProtoInfo)->
	MailTitle = language:get_string(?STR_GUILD_BATTLE_INVITE_MAIL_TITLE),
	MailContent = language:get_string(?STR_GUILD_BATTLE_INVITE_MAIL_CONTENT),
	MailSign = language:get_string(?STR_GUILD_BATTLE_INVITE_MAIL_SIGN),
	{ApplyH,ApplyM,_} = guildbattle_db:get_stopapplytime(BattleProtoInfo),
	lists:foreach(fun({_,GuildName,_,LeaderName,_})->
						case is_binary(GuildName) of
							true->
								NewGuildName = binary_to_list(GuildName);
							_->
								NewGuildName = GuildName
						end,

						case is_binary(LeaderName) of
							true->
								NewLeaderName = binary_to_list(LeaderName);
							_->
								NewLeaderName = LeaderName
						end,
						
						RealMailContent = util:sprintf(MailContent,[NewLeaderName,NewGuildName,Year,Mon,Day]),
						gm_op:gm_send_rpc(MailSign,LeaderName,MailTitle,RealMailContent,0,0,0)
				 	end, get(guildlist)).

start_battle()->
	InstanceInfo = instance_proto_db:get_info(?GUILDBATTLE_INSTANCEID),
	MapId = instance_proto_db:get_level_mapid(InstanceInfo),
	[Node] = node_util:get_low_load_node(1),
	MapProc = guild_battle,			%%todo
	case rpc:call(Node,map_manager,start_instance,[MapProc,{atom_to_list(MapProc),?GUILDBATTLE_INSTANCEID,{?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM}},MapId]) of
		ok->
			put(battleinfo,{Node,MapProc,now()}),
			init_battle_states(),
			notify_battle_start(),
			change(?GUILDBATTLE_READY);
		error->
			nothing
	end.

battle_over()->
	%%check result 
	ResultList = lists:sort(fun(GuildA,GuildB)->
					   			{GuildAId,_,GuildASorce,GuildAGetThrone,_} = GuildA,
								{GuildBId,_,GuildBSorce,GuildBGetThrone,_} = GuildB,
								if
									GuildAGetThrone->
										true;
									GuildBGetThrone->
										false;
									true->
										if
											GuildASorce =:= GuildBSorce->
												{_,_,_,_,IndexA} = lists:keyfind(GuildAId,1,get(guildlist)),
												{_,_,_,_,IndexB} = lists:keyfind(GuildBId,1,get(guildlist)),
												IndexA < IndexB;
											true->
												GuildASorce > GuildBSorce
										end
								end
							end ,get(applylist)),
	{Result,_} = lists:foldl(fun({_,GuildName,GuildScore,_,_},{Acc,Index})->
								 {[{GuildName,GuildScore,Index+1}|Acc],Index+1}
							end,{[],0},ResultList),
	put(guildbattle_result,Result),
	guildbattle_db:clear_guildbattle_last_score(),
	guildbattle_db:add_guildbattle_score(Result),
	lists:foreach(fun({_GuildId,_,_GuildSorce,_GuildAGetThrone,_})-> 
						  gm_logger_guild:guildbattle_result(_GuildId,_GuildSorce,_GuildAGetThrone,?BATTLE_NAME)
						  end,ResultList),
	{GuildId,GuildName,GuildSorce,GuildAGetThrone,GuildIndex} = lists:nth(1,ResultList),
	{_,_,RoleId,RoleName,_} =  lists:keyfind(GuildId,1,get(guildlist)),
	ResultMsg = guildbattle_packet:encode_guild_battle_result_s2c(GuildIndex),
	broadcast_to_all_in_battle_client(ResultMsg),
	winner_broadcast(RoleId,RoleName,GuildName),
	gm_logger_guild:guildbattle_winner(GuildId,RoleId,?BATTLE_NAME),
	%%
	%% broadcast  to all noline  todo 
	%%
	battle_stop(GuildId,GuildName,RoleId).
	
battle_stop()->
	destroy_battle_delay(),
	guild_manager:notify_guild_battle_stop({0,0}).

cancel_battle()->
	country_manager:change_king_and_bestguild(0,{0,0},[]).

destroy_battle_delay()->
	case get(battleinfo) of
		[]->
			nothing;
		{Node,MapProc,_}->
			rpc:call(Node,erlang,send_after,[?GUILDBATTLE_LEAVE_DELAY_S*1000,MapProc, {on_destroy}])
	end.

battle_stop(BestGuild,GuildName,RoleId)->
	destroy_battle_delay(),
	%%
	%% notify guild manager
	%%	
	notify_battle_stop(BestGuild,GuildName,RoleId).

notify_battle_start()->
	Guilds = lists:map(fun({GuildId,_,_,_,_})->
						GuildId
				 	end, get(applylist)),
	guild_manager:notify_guild_battle_start(Guilds).

notify_battle_stop(BestGuild,GuildName,RoleId)->
	guild_manager:notify_guild_battle_stop(BestGuild),
	country_manager:change_king_and_bestguild(RoleId,BestGuild,GuildName).

update_throne_state()->
	case get(thronestate) of
		{?THRONE_STATE_TAKING,GuildIndex,RoleId,RoleName,RoleClass,RoleGender,StartTime}->
			LeftTimes = erlang:max(?THRONE_TAKE_TIME_S - trunc(timer:now_diff(now(), StartTime)/1000000),0), 
			ThroneMsg = guildbattle_packet:encode_guild_battle_status_update_s2c(?THRONE_STATE_TAKING,LeftTimes,GuildIndex,RoleId,RoleName,RoleClass,RoleGender);
		{?THRONE_STATE_TAKED,GuildIndex,RoleId,RoleName,RoleClass,RoleGender,StartTime}->
			ThroneMsg = guildbattle_packet:encode_guild_battle_status_update_s2c(?THRONE_STATE_TAKED,0,GuildIndex,RoleId,RoleName,RoleClass,RoleGender);
		_->
			ThroneMsg = guildbattle_packet:encode_guild_battle_status_update_s2c(?THRONE_STATE_NULL,0,0,0,[],0,0)
	end,
	broadcast_to_all_in_battle_client(ThroneMsg).

update_guild_score(GuildId)->
	todo.
	
update_guild_score(GuildIndex,NewScore)->
	Msg = guildbattle_packet:encode_guild_battle_score_update_s2c(GuildIndex,NewScore),
	broadcast_to_all_in_battle_client(Msg).
	
init_battle_states()->
	put(thronestate,{?THRONE_STATE_NULL,0,0,[],0,0,{0,0,0}}),
	{BattlePlayer,_} = 
			lists:foldl(fun({GuildId,_,_,_,_},{BattlePlayerAcc,IndexListAcc})->
					Rand = random:uniform(length(IndexListAcc)),
					BornIndex = lists:nth(Rand,IndexListAcc),
					NewBattlePlayerAcc = [{GuildId,BornIndex}|BattlePlayerAcc],
					NewIndexListAcc = IndexListAcc -- [BornIndex],
					{NewBattlePlayerAcc,NewIndexListAcc}
			end,{[],lists:seq(1,length(get(applylist)))},get(applylist)),
	put(battleplayer,BattlePlayer),
	put(role_list,[]).
	
broadcast_to_all_in_battle_client(Msg)->
	lists:foreach(fun(RoleId)->
						 role_pos_util:send_to_role_clinet(RoleId,Msg)
				end,get(role_list)).

winner_broadcast(RoleId,RoleName,GuildName)->
	ParamGuildName = system_chat_util:make_string_param(GuildName),	
	MyName = util:safe_binary_to_list(RoleName),
	ServerId = 0,
	ParamRole = chat_packet:makeparam(role,{MyName,RoleId,ServerId}),
	MsgInfo = [ParamGuildName,ParamRole],
	system_chat_op:system_broadcast(?SYSTEM_CHAT_GUILDBATTLE_WINNER,MsgInfo),
	case country_db:get_info(?POST_KING) of
		[]->
			[];
		LeaderProtoInfo->
			case creature_op:get_creature_info(RoleId) of
				undefined->		%%read from db
					Level = 0;		%%shit
				RoleInfo->
					Level = creature_op:get_level_from_creature_info(RoleInfo)
			end,
			Items = country_db:get_items_by_level(LeaderProtoInfo,Level),				
			send_king_reward(RoleName,Items,GuildName)
	end.

broadcast_to_all(Message)->
	S = fun(RolePos)->
					GateProc = role_pos_db:get_role_gateproc(RolePos),
					tcp_client:send_data( GateProc, Message)
				end,
	role_pos_db:foreach(S).

send_stop_apply_message()->
	StopApplyMsg = guildbattle_packet:encode_guild_battle_stop_apply_s2c(),
	broadcast_to_all(StopApplyMsg).

get_guilebattle_rank_info()->
	case get(guildbattle_result) of
		undefined->
			[];
		Info->
			Info
	end.

send_king_reward(RoleName,ItemProtoIdList,GuildName)->
	MailTitle = language:get_string(?STR_GUILDBATTLE_KING_REWARD_MAIL_TITLE),
	MailContent = language:get_string(?STR_GUILDBATTLE_KING_REWARD_MAIL_CONTENT),
	MailSign = language:get_string(?STR_GUILD_BATTLE_INVITE_MAIL_SIGN),
	RealMailContent = util:sprintf(MailContent,[GuildName]),
	lists:foreach(fun({ItemProtoId,ItemCount}) ->
						gm_op:gm_send_rpc(MailSign,RoleName,MailTitle,RealMailContent,ItemProtoId,ItemCount,0)  
					end,ItemProtoIdList).
	
	
