%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-3-14
%% Description: TODO: Add description to yhzq_manager_op
-module(yhzq_manager_op).

%%
%% Exported Functions
%%
-compile(export_all).


%%
%% Include files
%%
-include("common_define.hrl").
-include("battle_define.hrl").
-include("error_msg.hrl").
-include("activity_define.hrl").

-define(RECORD_SAVE_DATE,7).			%%战报保存时间天

-define(ROLE_LEAVE,1).
-define(ROLE_APPLY,2).
-define(ROLE_BATTLE,3).

-define(CLOSEBATTLE_DELAYTIME_S,30).	%%30秒延迟关闭战场

-ifdef(debug).
send_msg_to_someone(RoleId,BroadCastMsg)->
	chat_manager:system_to_someone(RoleId,BroadCastMsg).
-endif.

-ifdef(debug).
-define(SEND_YHZQLIST(RoleId,ListNum,WaittingIndex),send_yhzq_list(RoleId,ListNum,WaittingIndex)).
send_yhzq_list(RoleId,ListNum,WaittingIndex)->
	Msg = "战场数:"++integer_to_list(ListNum)++" 排队人数:"++integer_to_list(WaittingIndex),
	send_msg_to_someone(RoleId,Msg).

-define(SEND_APPLYINFO(RoleId,QueueIndex),send_applyinfo(RoleId,QueueIndex)).
send_applyinfo(RoleId,QueueIndex)->
	Msg = "报名成功 排队位置:"++integer_to_list(QueueIndex),
	send_msg_to_someone(RoleId,Msg).
	
-define(SEND_JOINYHZQ(RoleId,BattleId,Camp),send_joinyhzq(RoleId,BattleId,Camp)).
send_joinyhzq(RoleId,BattleId,Camp)->
	Msg = "加入"++integer_to_list(BattleId)++"阵营:"++integer_to_list(Camp),
	send_msg_to_someone(RoleId,Msg).

-else.
-define(SEND_YHZQLIST(RoleId,ListNum,WaittingIndex),void).
-define(SEND_APPLYINFO(RoleId,QueueIndex),void).
-define(SEND_JOINYHZQ(RoleId,BattleId,Camp),void).
-endif.


%%
%% API Functions
%%
init()->
	%%put(yhzq_info,[]),
	put(group_guild,[]),
	put(all_battle,[]),
	put(yhzq_player,[]),  %% the player who in battle ground
	put(yhzq_can_start,false),
	put(yhzq_battle_records,[]),
	update_battle_record_info().

%%
%%
%%
on_check()->
	ActivityInfoList = answer_db:get_activity_info(?YHZQ_BATTLE_ACTIVITY),
	CheckFun = fun(ActiveInfo)->
				{Type,StartLines} = answer_db:get_activity_start(ActiveInfo),
				case timer_util:check_is_time_line(Type,StartLines,0) of
					true->
						on_start_notify(),
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
			on_stop_apply()
	end.
	
%%
%%yhzq开始
%%
on_start_notify()->
	case get(yhzq_can_start) of
		true->
			ignor;
		_->
			RightGuild = guild_manager:get_top_guild(?YHZQ_JION_GUILD_NUM),
			GuildList= lists:map(fun({GuildId,_,_})->
										GuildId
									end,RightGuild),
			GuildNum = length(GuildList),
			group_guild(GuildList),
			GroupGuild = get(group_guild),
			lists:foreach(fun({GuildA,GuildB})->
								start_yhzq_battle(GuildA,GuildB)
							end,GroupGuild),
			put(group_guild,[]),
			put(yhzq_can_start,true)
	end.
	
start_yhzq_battle(GuildA,GuildB)->
	Nodes = node_util:get_low_load_node(?CANDIDATE_NODES_NUM),
	Node = lists:nth(random:uniform(length(Nodes)),Nodes),
	rpc:call(Node,battle_ground_sup,start_child, [yhzq_battle,{Node,GuildA,GuildB}]),
	ProcName = battle_ground_sup:make_battle_proc_name(yhzq_battle,{Node,GuildA,GuildB}),
	MapProc = battle_ground_processor:make_map_proc_name(ProcName),
	put(all_battle,[{?YHZQ_PROCESS,Node,ProcName,MapProc}|get(all_battle)]).
			
group_guild(GuildList)->
	case length(GuildList) =< 1 of
		false->
			ValueA = random:uniform(length(GuildList)),
			GuildIdA = lists:nth(ValueA,GuildList),
			NewGuildList = GuildList -- [GuildIdA],
			ValueB = random:uniform(length(NewGuildList)),
			GuildIdB = lists:nth(ValueB,NewGuildList),
			put(group_guild,[{GuildIdA,GuildIdB}|get(group_guild)]),
			group_guild(NewGuildList -- [GuildIdB]);
		_->
			ignor
	end.
	
%%
%%切换到领奖状态
%%
change_yhzq_state({reward,Proc})->
	case lists:keyfind(Proc,3,get(all_battle)) of%%@@wb20130424 lists:keyfind(Proc,1,get(all_battle))
		false->
			ignor;
		{State,Node,Proc,MapProc}->
			case State of
				?YHZQ_PROCESS->
					NewBattleInfo = {?YHZQ_AWARD,Node,Proc,MapProc},
					put(all_battle,lists:keyreplace(Proc,3,get(all_battle),NewBattleInfo));	
				Other->
					nothing
			end
	end;

%%
%%切换到待关闭状态
%%
change_yhzq_state({delayclose,{Node,Proc}})->
	erlang:send_after(?CLOSEBATTLE_DELAYTIME_S*1000,self(),{change_yhzq_state,{close,Node,Proc}});
%%
%%切换到关闭状态
%%
change_yhzq_state({close,Node,Proc})->
	BattleList = get(all_battle),
	NewBattleList = lists:keydelete(Proc,3,BattleList),
	put(all_battle,NewBattleList),
	rpc:call(Node,battle_ground_sup,stop_child, [Proc]),
	update_battle_record_info().

%%
%%结束报名
%%
on_stop_apply()->
	case get(yhzq_can_start) of
		true->
			put(yhzq_can_start,false);
		_->
			nothing
	end.

update_battle_record_info()->
	case yhzq_battle_db:load_battle_record_info() of
		[]->
			nothing;
		Infos->
			NowDate = calendar:now_to_local_time(timer_center:get_correct_now()),
			%%删除过期的战报
			NewInfos = remove_overdue_battle_records(NowDate,Infos),
			put(yhzq_battle_records,NewInfos)
	end.


%%
%%删除过期战报
%% Now {{year,month,day},{hour,min,sec}}
%% return newinfo
remove_overdue_battle_records(Now,Infos)->
	{Today,{H,M,S}} = Now,
	lists:foldl(fun(Term,TempInfo)->
							{Type,{Date,Class,Index},_,_,_} = Term,
							case Type of
								yhzq_battle_record->
									{Day,Time} = calendar:time_difference({Date,{H,M,S}},Now),
									if
										Day > ?RECORD_SAVE_DATE->
											%%删除数据库中过期战报
											yhzq_battle_db:delete_battle_record_info({Date,Class,Index}),
											TempInfo;
										true->
											TempInfo ++ [Term]
									end;
								_->
									TempInfo ++ [Term]							
							end
						end,[],Infos).

%%
%%	
%%
notify_all_battle_over(RoleId)->
	Message = battle_ground_packet:encode_yhzq_all_battle_over_s2c(),
	role_pos_util:send_to_role_clinet(RoleId,Message).

	

