%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-3-2
%% Description: TODO: Add description to yhzq_battle
-module(yhzq_battle).

%%
%% Include files
%%
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("system_chat_define.hrl").
-include("little_garden.hrl").

-include("error_msg.hrl").
-include("battle_define.hrl").
-include("login_pb.hrl").
-include("string_define.hrl").
-include("npc_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

-include("mnesia_table_def.hrl").
%%
%% Define 
%%

-define(REWARD_TIME_S,120).			%%leave 2min to rewards
-define(INTERVAL_TIME_S,1).			%% check battle state per sec.
-define(INTERVAL_ZONE_SCORE_S,10).	%% per 10s get a score

-define(BATTLEWIN,1).
-define(BATTLRLOST,0).
-define(BATTLENOWINNER,3).

-define(BATTLESTATE_PROCESS,1).
-define(BATTLESTATE_REWARD,2).
-define(BATTLESTATE_TIMEOUT,3).		%% timeout
-define(BATTLESTATE_CLOSE,4).		%% close


-define(MAXSCORE,2000).

-define(PERSCORE,10).

-define(ZONECDTIME_S,10).

-define(POS_BRD_TIMER,3).	%%广播同阵营玩家位置时间间隔3s

%%
%%积分到达后 广播
%%
-define(BRD_RECORD,[{1000,33},{1500,34},{1800,35}]).

-ifdef(debug).
send_msg_to_someone(RoleId,BroadCastMsg)->
	chat_manager:system_to_someone(RoleId,BroadCastMsg).
-endif.

-ifdef(debug).
-define(SEND_CAMP_INFO(RoleId,RedNum,BlueNum,RedScore,BlueScore),send_camp_info(RoleId,RedNum,BlueNum,RedScore,BlueScore)).
send_camp_info(RoleId,RedNum,BlueNum,RedScore,BlueScore)->
	CampRed = language:get_string(?STR_YHZQ_LAN_RED),
	CampBlue = language:get_string(?STR_YHZQ_LAN_BLUE),
	Msg = CampRed++":"++integer_to_list(RedNum)++"/"++integer_to_list(RedScore)++CampBlue++":"++
				integer_to_list(BlueNum)++"/"++integer_to_list(BlueScore),
	send_msg_to_someone(RoleId,Msg).
-else.
-define(SEND_CAMP_INFO(RoleId,RedNum,BlueNum,RedScore,BlueScore),void).
-endif.
%%
%% API Functions
%%
on_init(ProcName,{Node,GuildA,GuildB})->
	ProtoInfo = battlefield_proto_db:get_info(?YHZQ_BATTLE),
	InstanceIds = battlefield_proto_db:get_instance_proto(ProtoInfo),
	Duration = battlefield_proto_db:get_duration(ProtoInfo),
	InstanceInfo = instance_proto_db:get_info(?YHZQ_INSTANCEID),
	MapId = instance_proto_db:get_level_mapid(InstanceInfo),
	MapProc = battle_ground_processor:make_map_proc_name(ProcName),
	case map_manager:start_instance(MapProc,{atom_to_list(ProcName),?YHZQ_INSTANCEID,{?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM}},MapId) of
		ok->
			init(GuildA,GuildB,Duration,Node,ProcName,MapProc,ProtoInfo),
			ok;
		error->
			on_destroy()
	end.

%%
%%	redlist [{roleid,roleinfo,killnum,bekillednum},...]
%%  bluelist
%%	redscore
%%  bluescore
%%  zoneinfo [{zoneid,zonestate,lasttime},...]
%% 
init(GuildA,GuildB,Duration,Node,ProcName,MapProc,ProtoInfo)->
	put(yhzq_info,{Node,ProcName,MapProc}),
	NpcInfoDB = npc_op:make_npcinfo_db_name(MapProc),
	put(npcinfo_db,NpcInfoDB),
	put(yhzq_battle_state,?BATTLESTATE_PROCESS),
	put(redlist,[]),
	put(bluelist,[]),
	put(redscore,0),
	put(bluescore,0),
	put(bestbornpos,0),
	put(has_reward,[]),
	Now = timer_center:get_correct_now(),
	put(start_time,Now),
	put(zoneinfo,[{?ZONEA,?ZONEIDLE,Now},{?ZONEB,?ZONEIDLE,Now},{?ZONEC,?ZONEIDLE,Now},{?ZONED,?ZONEIDLE,Now},{?ZONEE,?ZONEIDLE,Now}]),
	put(winner,?BATTLENOWINNER),
	put(red_brd_record,?BRD_RECORD),
	put(blue_brd_record,?BRD_RECORD),
	put(leavelist,[]),
	put(fighting_guild,[GuildA,GuildB]),
	guild_manager:notify_yhzq_start(GuildA,?YHZQ_CAMP_RED,Node,ProcName,MapProc),
	guild_manager:notify_yhzq_start(GuildB,?YHZQ_CAMP_BLUE,Node,ProcName,MapProc),
	erlang:send_after(?INTERVAL_TIME_S*1000, self(),{do_interval,0}),
	erlang:send_after(Duration, self(),{battle_timeout,[]}).	

on_role_join({RoleId,RoleName,RoleClass,RoleGender,RoleLevel,Camp})->
	case get(yhzq_battle_state) of
		?BATTLESTATE_PROCESS->
			case Camp of
				?YHZQ_CAMP_RED->
					RoleInfo = {RoleId,{RoleName,RoleClass,RoleGender,RoleLevel},0,0},
					NewRedList = lists:append(get(redlist),[RoleInfo]),
					put(redlist,NewRedList),
					send_camp_info_to_all();		
				?YHZQ_CAMP_BLUE->
					RoleInfo = {RoleId,{RoleName,RoleClass,RoleGender,RoleLevel},0,0},
					NewRedList = lists:append(get(bluelist),[RoleInfo]),
					put(bluelist,NewRedList),
					send_camp_info_to_all();			
				Other->
					slogger:msg("role ~p unknown camp ~p ~n",[RoleId,Other]),
					nothing
			end,
			send_other_join_info(RoleId,RoleName,RoleClass,RoleGender,RoleLevel,Camp),
			send_self_join_info(RoleId),
			send_zone_info_to_client(RoleId);
		_->
			nothing
	end.
	
on_role_chat({RoleId,Camp,{Type, RoleName, Msg, Details, RoleIden}})->
	case get(yhzq_battle_state) of
		?BATTLESTATE_PROCESS->
			case Camp of
				?YHZQ_CAMP_RED->
					Members = lists:map(fun({RedRoleId,_,_,_})->
									  RedRoleId
							  end, get(redlist)),
					Message = chat_packet:encode_chat_s2c(Type,?DEST_CHAT,RoleId,RoleName,Msg,Details,RoleIden),
					role_pos_util:send_to_clinet_list(Message, Members);
				?YHZQ_CAMP_BLUE->
					Members = lists:map(fun({BlueRoleId,_,_,_})->
												BlueRoleId
										end, get(bluelist)),
					Message = chat_packet:encode_chat_s2c(Type,?DEST_CHAT,RoleId,RoleName,Msg,Details,RoleIden),
					role_pos_util:send_to_clinet_list(Message, Members);
				Other->
					slogger:msg("role on chat ~p unknown camp ~p ~n",[RoleId,Other]),
					nothing
			end;
		_->
			nothing
	end.

on_role_leave(RoleId)->
	case get(yhzq_battle_state) of
		?BATTLESTATE_PROCESS->
			case lists:keyfind(RoleId,1,get(redlist)) of
				false ->
					case lists:keyfind(RoleId,1,get(bluelist)) of
						false ->
							nothing;
						_->
							put(bluelist,lists:keydelete(RoleId,1,get(bluelist))),
							send_camp_info_to_all()
					end;
				_->
					put(redlist,lists:keydelete(RoleId,1,get(redlist))),
					send_camp_info_to_all()
			end;
		_->
			%%记录在颁奖中 离开的用户
			put(leavelist,get(leavelist)++[RoleId])
	end.

on_killed({Killer,BeKilled})->
	case get(yhzq_battle_state) of
		?BATTLESTATE_PROCESS->
			case creature_op:what_creature(Killer) of
				npc->
					nothing;
				role->
					case creature_op:what_creature(BeKilled) of
						npc ->
							creature_killed_score(Killer,BeKilled);
						role->
							player_killed_score(Killer,BeKilled)
					end		
			end;
		_-> 
			nothing
	end.
	
on_destroy()->
	send_gm_reward_mail(),
	notify_guild_win_yhzq(),
	notify_guild_yhaq_end(),
	{_,_,MapProc} = get(yhzq_info),
	slogger:msg("yhzq on_destroy  ~p ~n",[MapProc]),	
	notify_all_yhzq_close(),
	erlang:send_after(?INTERVAL_TIME_S*1000,MapProc, {on_destroy}),
	erlang:send_after(?INTERVAL_TIME_S*1000,self(), {destroy_self}),
	notify_manager_yhzq_close(),
	%%保存战报
	save_battle_record().
	
	
destroy_self()->
	io:format("~p destory self ~n",[?MODULE]).
	
notify_guild_win_yhzq()->
	case get(fighting_guild) =/= [] of
		true->
			case get(winner) =/= ?BATTLENOWINNER of 
				true->
					Winner = lists:nth(get(winner),get(fighting_guild)),
					[Loser] = get(fighting_guild) -- [Winner],
					WinInfo = yhzq_battle_db:get_yhzq_reward_info(?BATTLEWIN),
					LoseInfo = yhzq_battle_db:get_yhzq_reward_info(?BATTLRLOST),
					GbScore = yhzq_battle_db:get_guild_add_score(WinInfo),
					LoseScore = yhzq_battle_db:get_guild_add_score(LoseInfo),
					Differential = abs(get(redscore) - get(bluescore)),
					WinScore = GbScore + (40 / 2000)*Differential,
					notify_guild_lose_yhzq(Loser,LoseScore,yhzq),
					guild_manager:add_guild_battle_score(Winner,trunc(WinScore),yhzq);
				_->
					ignor
			end;
		_->
			ignor
	end.
		
notify_guild_lose_yhzq(Loser,LoseScore,yhzq)->
	guild_manager:notify_guild_lose_battle(Loser,LoseScore,yhzq).
	
notify_guild_yhaq_end()->
	lists:foreach(fun(GuildId)->
						guild_manager:notify_yhzq_end(GuildId)
					end,get(fighting_guild)).

get_reward(LoseOrWin)->
	Info = yhzq_battle_db:get_yhzq_reward_info(LoseOrWin),
	yhzq_battle_db:get_role_rewards(Info).

on_reward(RoleId)->
	case get(yhzq_battle_state) of
		?BATTLESTATE_REWARD->
			case is_has_reward(RoleId) of
				true->
					[];
				_->
					put(has_reward,[RoleId|get(has_reward)]),
					case get(winner) of
						?YHZQ_CAMP_RED->
							case lists:keyfind(RoleId,1,get(redlist)) of
								false->
									get_reward(?BATTLRLOST);
								_->
									get_reward(?BATTLEWIN)
							end;
						?YHZQ_CAMP_BLUE->
	 						case lists:keyfind(RoleId,1,get(bluelist)) of
								false->
									get_reward(?BATTLRLOST);
								_->
									get_reward(?BATTLEWIN)
							end;
						_->
							case lists:keyfind(RoleId,1,get(bluelist)) of
								false->
									MyCamp = ?YHZQ_CAMP_RED;
								_->
									MyCamp = ?YHZQ_CAMP_BLUE
							end,
							get_reward(?BATTLENOWINNER)
					end			
			end;
		_->
			[]
	end.

get_map_proc()->
	{_,_,MapProc} = get(yhzq_info),
	atom_to_list(MapProc).

		
		
%%
%%参数 已发生次数
%%
do_interval(_Info)->
	case is_integer(_Info) of
		true->
			DurationTimer = _Info + 1;
		_->	
			DurationTimer = 1
	end,
	case get(yhzq_battle_state) of
		?BATTLESTATE_PROCESS->
			%%check zone state
			Now = timer_center:get_correct_now(),
			lists:foreach(fun({Id,State,Time})->
								Time_diff = timer:now_diff(Now,Time)/1000000,
								case State of
									?TAKEBYRED->
										if
											Time_diff >= ?INTERVAL_ZONE_SCORE_S ->
												put(redscore,get(redscore) + ?PERSCORE),
												update_zone_time(Id,State,Now),
												update_score_broad_cast(?YHZQ_CAMP_RED,get(redscore)),
												send_camp_info_to_all();											
											true->
												nothing
										end;	
									?TAKEBYBLUE->
										if
											Time_diff >= ?INTERVAL_ZONE_SCORE_S ->
												put(bluescore,get(bluescore) + ?PERSCORE),
												update_zone_time(Id,State,Now),
												update_score_broad_cast(?YHZQ_CAMP_BLUE,get(bluescore)),
												send_camp_info_to_all();
											true->
												nothing
										end;										
									Other->
										nothing
								end
							end,get(zoneinfo)),
			%% check score
			MaxScore = erlang:max(get(redscore),get(bluescore)),
			if
				MaxScore >= ?MAXSCORE ->
					judge_winner(),	%% it change state process to reward
					erlang:send_after(?REWARD_TIME_S*1000, self(),{do_interval,DurationTimer});
				true->
					erlang:send_after(?INTERVAL_TIME_S*1000, self(),{do_interval,DurationTimer})
			end,
			ThisTimer = DurationTimer rem ?POS_BRD_TIMER,
			case ThisTimer of
				0->
					update_palyer_pos_info();		%%更新一次玩家位置信息  待优化
				_->
					nothing
			end;
		?BATTLESTATE_REWARD->
			on_destroy();
		?BATTLESTATE_TIMEOUT->		
			judge_winner(),
			erlang:send_after(?REWARD_TIME_S*1000, self(),{do_interval,DurationTimer})
	end.

battle_timeout(Info)->
	case get(yhzq_battle_state) of
		?BATTLESTATE_PROCESS->
			change_battle_state(?BATTLESTATE_TIMEOUT);
		_->
			nothing
	end.
%%			
%% Local Functions
%%

is_has_reward(RoleId)->
	lists:member(RoleId, get(has_reward)).

judge_winner()->
	change_battle_state(?BATTLESTATE_REWARD),
	%% judge winner  
	RedScore = get(redscore),
	BlueScore = get(bluescore),	
	if 
		RedScore =:= BlueScore ->
			put(winner,?BATTLENOWINNER);
		RedScore > BlueScore ->
			put(winner,?YHZQ_CAMP_RED);
		true->
			put(winner,?YHZQ_CAMP_BLUE)
	end,	
	notify_manager_yhzq_reward(),
	notify_all_yhzq_reward().

update_zone_time(ZoneId,State,Now)->
	NewZoneInfo = {ZoneId,State,Now},
	put(zoneinfo,lists:keyreplace(ZoneId,1,get(zoneinfo),NewZoneInfo)).

%%
%% return {state,lasttime}
%%
get_zone_state(ZoneId)->
	case lists:keyfind(ZoneId,1,get(zoneinfo)) of
		false->
			[];
		{_,State,LastTime}->
			{State,LastTime}
	end.
		
change_zone_state(ZoneId,State,Now)->
	NewZoneInfo = {ZoneId,State,Now},
	put(zoneinfo,lists:keyreplace(ZoneId,1,get(zoneinfo),NewZoneInfo)),
%%	if
%%		ZoneId =:= ?KEYZONE ->
%%			case State of
%%				?TAKEBYRED->
%%					put(bestbornpos,?YHZQ_CAMP_RED);
%%				?TAKEBYBLUE->
%%					put(bestbornpos,?YHZQ_CAMP_BLUE);
%%				?REDGETFROMBLUE->
%%					put(bestbornpos,0);				
%%				?BLUEGETFROMRED->
%%					put(bestbornpos,0);
%%				Other->
%%					nothing
%%			end;
%%		true->
%%			nothing
%%	end,
	send_zone_info_to_all().

change_battle_state(State)->
	put(yhzq_battle_state,State).

send_camp_info_to_client(RoleId)->
	[RedGuild,BlueGuild] = get(fighting_guild),
	RGName = guild_manager:get_guild_name(RedGuild),
	BGName = guild_manager:get_guild_name(BlueGuild),
	Message = battle_ground_packet:encode_yhzq_camp_info_s2c(length(get(redlist)),length(get(bluelist)),get(redscore),get(bluescore),RGName,BGName),
%%	?SEND_CAMP_INFO(RoleId,length(get(redlist)),length(get(bluelist)),get(redscore),get(bluescore)),
	role_pos_util:send_to_role_clinet(RoleId,Message).

send_camp_info_to_all()->
	[RedGuild,BlueGuild] = get(fighting_guild),
	RGName = guild_manager:get_guild_name(RedGuild),
	BGName = guild_manager:get_guild_name(BlueGuild),
	Message = battle_ground_packet:encode_yhzq_camp_info_s2c(length(get(redlist)),length(get(bluelist)),get(redscore),get(bluescore),RGName,BGName),
	send_msg_to_client_in_ground(Message).

send_zone_info_to_client(RoleId)->
	ZoneList = lists:map(fun({Id,State,_})->{Id,State} end,get(zoneinfo)),
	Message = battle_ground_packet:encode_yhzq_zone_info_s2c(ZoneList),
	role_pos_util:send_to_role_clinet(RoleId,Message).
	
send_zone_info_to_all()->
	ZoneList = lists:map(fun({Id,State,_})->{Id,State} end,get(zoneinfo)),
	Message = battle_ground_packet:encode_yhzq_zone_info_s2c(ZoneList),
	send_msg_to_client_in_ground(Message).

send_msg_to_client_in_ground(Message)->
	FilitList  = get(leavelist),
	lists:foreach(fun({RoleId,_,_,_})->
					case lists:member(RoleId,FilitList) of
						true->
							nothing;
						_->
							role_pos_util:send_to_role_clinet(RoleId,Message)
					end
				end,get(redlist)),
	lists:foreach(fun({RoleId,_,_,_})->
					case lists:member(RoleId,FilitList) of
						true->
							nothing;
						_->
							role_pos_util:send_to_role_clinet(RoleId,Message)
					end
				end,get(bluelist)).

send_msg_to_role_in_ground(Msg)->
	FilitList  = get(leavelist),
	lists:foreach(fun({RoleId,_,KillNum,_})->
					case lists:member(RoleId,FilitList) of
						true->
							nothing;
						_->
							role_pos_util:send_to_role(RoleId,Msg)
					end
				end,get(redlist)),
	lists:foreach(fun({RoleId,_,KillNum,_})->
					case lists:member(RoleId,FilitList) of
						true->
							nothing;
						_->
							role_pos_util:send_to_role(RoleId,Msg)
					end
				end,get(bluelist)).

notify_manager_someone_leave(RoleId,Camp)->
	case get(yhzq_battle_state) of
		?BATTLESTATE_PROCESS->		
			send_someone_leave(RoleId,Camp);
		_->
			nothing
	end.

notify_all_yhzq_reward()->
	FilitList  = get(leavelist),
	WinInfo = yhzq_battle_db:get_yhzq_reward_info(?BATTLEWIN),
	LoseInfo = yhzq_battle_db:get_yhzq_reward_info(?BATTLRLOST),
	WinnerHonor = yhzq_battle_db:get_role_add_honor(WinInfo),
	WinnerExp = yhzq_battle_db:get_role_add_exp(WinInfo),
	LoserExp = yhzq_battle_db:get_role_add_exp(LoseInfo),
	LoserHonor = yhzq_battle_db:get_role_add_honor(LoseInfo),
	case get(winner) of
		?YHZQ_CAMP_RED->
			RHonorExt = WinnerHonor,
			RAddExp = WinnerExp,
			BHonorExt = LoserHonor,
			BAddExp = LoserExp;
		_->
			BHonorExt = WinnerHonor,
			BAddExp = WinnerExp,
			RHonorExt = LoserHonor,
			RAddExp = LoserExp
	end,	
	lists:foreach(fun({RoleId,BaseInfo,KillNum,_})->
						{_,_,_,RoleLevel} = BaseInfo,
						case lists:member(RoleId,FilitList) of
							true->
								nothing;
							_->
								TotleNum = get_totle_killnum(redlist),
								case TotleNum =< 0 of
									true->
										KillHonor=min(0,10);
									_->
										KillHonor=min((KillNum/TotleNum)*50,10)
								end,
								Honor = RHonorExt + KillHonor,
								role_pos_util:send_to_role(RoleId,{notify_yhzq_reward,get(winner),Honor,RoleLevel*RAddExp})
						end
					end,get(redlist)),
	lists:foreach(fun({RoleId,BaseInfo,KillNum,_})->
						{_,_,_,RoleLevel} = BaseInfo,
						case lists:member(RoleId,FilitList) of
							true->
								nothing;
							_->
								TotleNum = get_totle_killnum(bluelist),
								case TotleNum =< 0 of
									true->
										KillHonor=min(0,10);
									_->
										KillHonor=min((KillNum/TotleNum)*50,10)
								end,
								Honor = BHonorExt + KillHonor,
								role_pos_util:send_to_role(RoleId,{notify_yhzq_reward,get(winner),Honor,RoleLevel*BAddExp})
						end
					end,get(bluelist)).
					
get_totle_killnum(Camp)->
	lists:foldl(fun({_,_,KillNum,_},Acc)->
						Acc + KillNum
					end,1,get(Camp)).
					
notify_manager_yhzq_reward()->
	{_,Proc,_} = get(yhzq_info),
	battle_ground_manager:change_yhzq_state(reward,Proc).

notify_all_yhzq_close()->
	send_msg_to_role_in_ground({leave_yhzq_c2s}).

%%
%%通知manager杀掉自己进程  需要延时 执行完 self_destory后才能杀掉
%%
notify_manager_yhzq_close()->
	{Node,Proc,_} = get(yhzq_info),
	battle_ground_manager:change_yhzq_state(delayclose,{Node,Proc}).

get_keybornpos(Camp)->
	CheckBase = 
		case Camp of
			?YHZQ_CAMP_RED->
				case get_zone_state(?REDZONE) of
					[]->
						false;
					{State,_}->
						if
							State =:= ?TAKEBYRED ->
								true;
							true->
								false
						end			
				end;
			?YHZQ_CAMP_BLUE->
				case get_zone_state(?BLUEZONE) of
					[]->
						false;
					{State,_}->
						if
							State =:= ?TAKEBYBLUE ->
								true;
							true->
								false
						end			
				end;
			_->
				false
		end,
	if
		CheckBase->
			case get_zone_state(?KEYZONE) of
				[]->
					false;
				{State1,_}->
					State1 =:= Camp
			end;
		true->
			false
	end.	

take_a_zone({Camp,NpcId,PlayerId})->
	case get(yhzq_battle_state) of
		?BATTLESTATE_PROCESS->
			NpcInfo = creature_op:get_creature_info(NpcId),
			NpcName = get_name_from_npcinfo(NpcInfo),
			case Camp of
				?TAKEBYRED->
					take_zone_broad_cast(NpcName,Camp);
				?REDGETFROMBLUE->
					RoleInfo = creature_op:get_creature_info(PlayerId),
					take_zone_broad_cast(NpcName,RoleInfo,Camp);
				?TAKEBYBLUE->
					take_zone_broad_cast(NpcName,Camp);
				?BLUEGETFROMRED->
					RoleName = get_role_name(PlayerId,?YHZQ_CAMP_BLUE),
					RoleInfo = creature_op:get_creature_info(PlayerId),
					take_zone_broad_cast(NpcName,RoleInfo,Camp);
				_->
					nothing	
			end,	
			ZoneId = yhzq_battle_db:get_npcindex(NpcId),
		%%	io:format("~p take_a_zone ~p ~n",[?MODULE,{Camp,ZoneId}]),
			change_zone_state(ZoneId,Camp,timer_center:get_correct_now());
		_->
			nothing
	end.

%%
%%广播
%%

%%
%%刚占领一个旗帜
%%
take_zone_broad_cast(NpcName,RoleInfo,Camp)->	
	LeftBracket = language:get_string(?STR_LEFT_BRACKET),
	RightBracket = language:get_string(?STR_RIGHT_BRACKET),
	if
		Camp =:= ?REDGETFROMBLUE ->
			CampName = LeftBracket ++ language:get_string(?STR_YHZQ_LAN_RED) ++ RightBracket,
			Color = 16#FF0033 ;
		true->
			CampName = LeftBracket ++ language:get_string(?STR_YHZQ_LAN_BLUE) ++ RightBracket,
			Color = 16#0066CC 
	end,
	if 
		is_binary(NpcName)->
			NewNpcName =binary_to_list(NpcName);
		true->
			NewNpcName = NpcName
	end,
	ParamCamp = system_chat_util:make_string_param(CampName,Color),
	ParamNpc = system_chat_util:make_string_param(NewNpcName),
	case RoleInfo of
		undefined ->
			nothing;
		_ ->
			ParamRole = system_chat_util:make_role_param(RoleInfo,Color),
			MsgInfo = [ParamRole, ParamCamp, ParamNpc],
			system_chat_op:system_broadcast_instance(?SYSTEM_CHAT_YHZQ_GOT_FLAG,MsgInfo,get_map_proc())
	end.
%%
%%完全占领一个旗帜
%%
take_zone_broad_cast(NpcName,Camp)->
	LeftBracket = language:get_string(?STR_LEFT_BRACKET),
	RightBracket = language:get_string(?STR_RIGHT_BRACKET),
	if 
		is_binary(NpcName)->
			NewNpcName =binary_to_list(NpcName);
		true->
			NewNpcName = NpcName
	end,
	if
		Camp =:= ?TAKEBYRED ->
			CampName = LeftBracket ++ language:get_string(?STR_YHZQ_LAN_RED) ++ RightBracket,
			ReplaceColor = 16#FF0033;
		true->
			CampName = LeftBracket ++ language:get_string(?STR_YHZQ_LAN_BLUE) ++ RightBracket,
			ReplaceColor = 16#0066CC 
	end,
	ParamCamp = system_chat_util:make_string_param(CampName,ReplaceColor),
	ParamNpc = system_chat_util:make_string_param(NewNpcName),
	MsgInfo = [ParamCamp,ParamNpc],
	system_chat_op:system_broadcast_instance(?SYSTEM_CHAT_YHZQ_CONTROL_FLAG,MsgInfo,get_map_proc()).

%%
%%杀人
%%
kill_player_broad_cast(MyInfo,OtherInfo,MyCamp)->
try
	if
		MyCamp =:= ?YHZQ_CAMP_RED ->
			OtherColor = 16#0066CC,
			Color = 16#FF0033;
		true->
			OtherColor = 16#FF0033,
			Color = 16#0066CC 
	end,
	case (MyInfo=:=undefined)and (OtherInfo=:=undefined) of
		true ->
			nothing;
		_ ->
			ParamRole = system_chat_util:make_role_param(MyInfo,Color),
			ParamOther = system_chat_util:make_role_param(OtherInfo,OtherColor),
			MsgInfo = [ParamRole,ParamOther],
			system_chat_op:system_broadcast_instance(?SYSTEM_CHAT_YHZQ_ROLE_KILL,MsgInfo,get_map_proc())
	end
catch
	E:R->
		slogger:msg("kill_player_broad_cast error ~p ~p ~n ",[E,R]),
		error
end.

%%
%%得分广播
%%
score_broad_cast(Camp,Type)->
try
	LeftBracket = language:get_string(?STR_LEFT_BRACKET),
	RightBracket = language:get_string(?STR_RIGHT_BRACKET),
	if
		Camp =:= ?YHZQ_CAMP_RED ->
			CampName = LeftBracket ++ language:get_string(?STR_YHZQ_LAN_RED) ++ RightBracket,
			ReplaceColor = 16#FF0033;
		true->
			CampName = LeftBracket ++ language:get_string(?STR_YHZQ_LAN_BLUE) ++ RightBracket,
			ReplaceColor = 16#0066CC 
	end,
	ParamCamp = system_chat_util:make_string_param(CampName,ReplaceColor),
	system_chat_op:system_broadcast_instance(Type,[ParamCamp],get_map_proc())
catch
	E:R->
		slogger:msg("score_broad_cast error ~p ~p ~n ",[E,R]),
		error
end.


%%
%%
%%
update_score_broad_cast(Camp,Score)->
	DicKey = 
		if
			Camp =:= ?YHZQ_CAMP_RED->
				red_brd_record;
			true->
				blue_brd_record
		end,
	CurScoreLine = get(DicKey),
	case get_adapt_brd_type(Score,CurScoreLine) of
		[]->
			nothing;
		{Type,ScoreLine}->
			NewScoreLine = lists:keydelete(ScoreLine,1,CurScoreLine),
			put(DicKey,NewScoreLine),
			score_broad_cast(Camp,Type)
	end.

get_adapt_brd_type(_,[])->
	[];

get_adapt_brd_type(Socre,BrdConfig)->
	[ConfigHeader|ConfigTail] = BrdConfig,
	{ScoreLine,Type} = ConfigHeader,
	if
		Socre >= ScoreLine ->
			{Type,ScoreLine};
		true->
			[]
	end.
%%
%%将战场中所有人的信息发送给新加入者
%%
send_self_join_info(RoleId)->
%%	io:format("send_self_join_info red list ~p ~n",[get(redlist)]),
	RedInfo = case get(redlist) of
				  []->
					  [];
				  _->
		lists:map(fun(RoleInfo)->
					{OtherRoleId,BaseInfo,KillNum,BeKilledNum} = RoleInfo,
					{RoleName,RoleClass,RoleGender,RoleLevel} = BaseInfo,
					#tr{roleid = OtherRoleId,
						rolename = RoleName,
						rolegender = RoleGender,
						roleclass = RoleClass,
						rolelevel =  RoleLevel,
						kills = KillNum,
						score = KillNum}
				end,get(redlist))
			  end,
	case get(bluelist) of%%@@wb20130422
		[]->
			BlueInfo=[];
		_->
	BlueInfo = 
		lists:map(fun(RoleInfo)->
					{OtherRoleId,BaseInfo,KillNum,BeKilledNum} = RoleInfo,
					{RoleName,RoleClass,RoleGender,RoleLevel} = BaseInfo,
					#tr{roleid = OtherRoleId,
						rolename = RoleName,
						rolegender = RoleGender,
						roleclass = RoleClass,
						rolelevel =  RoleLevel,
						kills = KillNum,
						score = KillNum}
				end,get(bluelist))
	end,
	{_,BattleId,_} = get(yhzq_info),
	LeftTime = get_battle_lefttime(),
	Message = battle_ground_packet:encode_yhzq_battle_self_join_s2c(RedInfo,BlueInfo,BattleId,LeftTime),
	role_pos_util:send_to_role_clinet(RoleId,Message).

%%
%%其他人加入 通知另外人
%%
send_other_join_info(RoleId,RoleName,RoleClass,RoleGender,RoleLevel,Camp)->
%%	io:format("send_other_join_info ~n"),
	RoleInfo = 
	#tr{roleid = RoleId,
						rolename = RoleName,
						rolegender = RoleGender,
						roleclass = RoleClass,
						rolelevel =  RoleLevel,
						kills = 0,
						score = 0},
	Message = battle_ground_packet:encode_yhzq_battle_other_join_s2c(RoleInfo,Camp),
	lists:foreach(fun({MyRoleId,_,_,_})->
			role_pos_util:send_to_role_clinet(MyRoleId,Message)
			end,get(redlist)),

	lists:foreach(fun({MyRoleId,_,_,_})->
			role_pos_util:send_to_role_clinet(MyRoleId,Message)
			end,get(bluelist)).

send_someone_leave(RoleId,Camp)->
	Message = battle_ground_packet:encode_yhzq_battle_remove_s2c(RoleId,Camp),
	lists:foreach(fun({MyRoleId,_,_,_})->
			role_pos_util:send_to_role_clinet(MyRoleId,Message)
			end,get(redlist)),

	lists:foreach(fun({MyRoleId,_,_,_})->
			role_pos_util:send_to_role_clinet(MyRoleId,Message)
			end,get(bluelist)).

send_battle_update_info(RoleInfo,Camp)->
	Message = battle_ground_packet:encode_yhzq_battle_update_s2c(RoleInfo,Camp),
	lists:foreach(fun({RoleId,_,_,_})->
			role_pos_util:send_to_role_clinet(RoleId,Message)
			end,get(redlist)),
	lists:foreach(fun({RoleId,_,_,_})->
			role_pos_util:send_to_role_clinet(RoleId,Message)
			end,get(bluelist)).

%%
%%杀怪处理
%%
creature_killed_score(Killer,BeKilled)->
%%	CreatureInfo = creature_op:get_creature_info(BeKilled),
%%	CreatureV = get_maxsilver_from_npcinfo(CreatureInfo),
%%	killed_role_broad_cast(npc,get_role_name(Killer),get_name_from_npcinfo(CreatureInfo),CreatureV),
%%	case add_role_score(Killer,CreatureV,killer) of
%%		[]->
%%			nothing;
%%		[{_,RoleName,Score,Kills,{RoleClass,RoleGender,RoleLevel} }]->
%%			RoleInfo = battle_ground_packet:make_tangle_battle_role(Killer,RoleName,Kills,Score,RoleGender,RoleClass,RoleLevel),
%%			Message = battle_ground_packet:encode_tangle_update_s2c([RoleInfo]),
%%			send_to_ground_client(Message)
%%	end.
	nothing.

%%
%%杀人处理
%%	
player_killed_score(Killer,BeKilled)->
	io:format("~p,player_killed_score,Killer=~p,BeKilled=~p~n",[?MODULE,Killer,BeKilled]),
	case lists:keyfind(Killer,1,get(redlist)) of
		false->
			case lists:keyfind(Killer,1,get(bluelist)) of			
				false->	
					nothing;
				{_,BaseInfo,Kill,_}->			%%杀人者为蓝方 刷新排行
					KillerInfo = creature_op:get_creature_info(Killer),
					BeKillerInfo = creature_op:get_creature_info(BeKilled),
					kill_player_broad_cast(KillerInfo,BeKillerInfo,?YHZQ_CAMP_BLUE),
					NewRoleInfo = {Killer,BaseInfo,Kill+1,0},
					put(bluelist,lists:keyreplace(Killer,1,get(bluelist),NewRoleInfo)),
					update_someoneinfo(NewRoleInfo,?YHZQ_CAMP_BLUE),
					put(bluelist,lists:reverse(lists:keysort(3,get(bluelist))))
			end;			
		{_,BaseInfo,Kill,_}->
			case creature_op:get_creature_info(Killer) of
				undefined->
					nothing;
				KillerInfo ->	
					BeKillerInfo = creature_op:get_creature_info(BeKilled),
					kill_player_broad_cast(KillerInfo,BeKillerInfo,?YHZQ_CAMP_RED),
					NewRoleInfo = {Killer,BaseInfo,Kill+1,0},
					put(redlist,lists:keyreplace(Killer,1,get(redlist),NewRoleInfo)),
					update_someoneinfo(NewRoleInfo,?YHZQ_CAMP_RED),
					put(redlist,lists:reverse(lists:keysort(3,get(redlist))))
			end
	end.	

update_someoneinfo(RoleInfo,Camp)->
	{RoleId,BaseInfo,KillNum,BeKilledNum} = RoleInfo,
	{RoleName,RoleClass,RoleGender,RoleLevel} = BaseInfo,
	NewRoleInfo = 
		#tr{roleid = RoleId,
			rolename = RoleName,
			rolegender = RoleGender,
			roleclass = RoleClass,
			rolelevel =  RoleLevel,
			kills = KillNum,
			score = KillNum},
	send_battle_update_info(NewRoleInfo,Camp).					

%%
%%保存战报
%%格式 {day,type,id}, {redscore,bluescore,redinfo,blueinfo}, has_reward
save_battle_record()->
	{Today,_} = calendar:now_to_local_time(timer_center:get_correct_now()),
	{BattleType,BattleId,_} = get(yhzq_info),
	RedInfo = get(redlist),
	BlueInfo = get(bluelist),
	RedScore = get(redscore),
	BlueScore = get(bluescore),
	Has_Reward = get(has_reward),
	yhzq_battle_db:sync_add_battle_info(Today,BattleType,BattleId,{RedScore,BlueScore,RedInfo,BlueInfo},Has_Reward).

%%
%%更新玩家位置信息
%%
update_palyer_pos_info()->
	RedPlayerPos = lists:map(fun(RoleInfo)->
				{RoleId,_,_,_} = RoleInfo,
				case creature_op:get_creature_info(RoleId) of
					undefined->
						{RoleId,0,0};
					SomeRoleInfo->
						{X,Y} = get_pos_from_roleinfo(SomeRoleInfo),
						{RoleId,X,Y}
				end
			end,get(redlist)), 
	BluePlayerPos = lists:map(fun(RoleInfo)->
				{RoleId,_,_,_} = RoleInfo,
				case creature_op:get_creature_info(RoleId) of
					undefined->
						{RoleId,0,0};
					SomeRoleInfo->
						{X,Y} = get_pos_from_roleinfo(SomeRoleInfo),
						{RoleId,X,Y}
				end
			end,get(bluelist)), 
%%	io:format("RedPos ~p BluePlayer ~p ~n",[RedPlayerPos,BluePlayerPos]),
	RedMessage = battle_ground_packet:encode_yhzq_battle_player_pos_s2c(RedPlayerPos),
	BlueMessage = battle_ground_packet:encode_yhzq_battle_player_pos_s2c(BluePlayerPos),
	lists:foreach(fun(RoleInfo)->
				{RoleId,_,_,_} = RoleInfo,
					role_pos_util:send_to_role_clinet(RoleId,RedMessage)
				end,get(redlist)), 

	lists:foreach(fun(RoleInfo)->
				{RoleId,_,_,_} = RoleInfo,
					role_pos_util:send_to_role_clinet(RoleId,BlueMessage)
				end,get(bluelist)).


get_role_name(RoleId,Camp)->
	case Camp of
		?YHZQ_CAMP_RED->
			case lists:keyfind(RoleId,1,get(redlist)) of
				false->
					[];
				{_,BaseInfo,_,_}->
					{RoleName,_,_,_} = BaseInfo,
					RoleName
			end;
		?YHZQ_CAMP_BLUE->
			case lists:keyfind(RoleId,1,get(bluelist)) of
				false->
					[];
				{_,BaseInfo,_,_}->
					{RoleName,_,_,_} = BaseInfo,
					RoleName
			end;
		_->	
			[]
	end.

get_role_level(RoleId,Camp)->
	case Camp of
		?YHZQ_CAMP_RED->
			case lists:keyfind(RoleId,1,get(redlist)) of
				false->
					[];
				{_,BaseInfo,_,_}->
					{_,_,_,RoleLevel} = BaseInfo,
					RoleLevel
			end;
		?YHZQ_CAMP_BLUE->
			case lists:keyfind(RoleId,1,get(bluelist)) of
				false->
					[];
				{_,BaseInfo,_,_}->
					{_,_,_,RoleLevel} = BaseInfo,
					RoleLevel
			end;
		_->	
			[]
	end.

get_battle_lefttime()->
	ProtoInfo = battlefield_proto_db:get_info(?YHZQ_BATTLE),
	InstanceIds = battlefield_proto_db:get_instance_proto(ProtoInfo),
	Duration = battlefield_proto_db:get_duration(ProtoInfo),
	StartTime = get(start_time),
	Now = timer_center:get_correct_now(),
	LeftTime = trunc((Duration*1000 - timer:now_diff(Now,StartTime))/1000000),
	erlang:max(LeftTime,0).

	
send_gm_reward_mail()->
	FromName = language:get_string(?STR_BATTLE_MAIL_SIGN),
	Title = language:get_string(?STR_YHZQ_MAIL_TITLE),
	ContextFormat = language:get_string(?STR_YHZQ_MAIL_CONTEXT),
	Add_Silver = 0,
	SubFun = fun({RoleId,BaseInfo,_,_})->
				{RoleName,_,_,_} = BaseInfo,
				RewardList = on_reward(RoleId),
				lists:foreach(fun({ItemId,Count})->
							gm_op:gm_send_rpc(FromName,RoleName,Title,ContextFormat,ItemId,Count,Add_Silver)	
							end,RewardList)
			end,
	
	lists:foreach(SubFun,get(redlist)),
	lists:foreach(SubFun,get(bluelist)).

	


	
				
