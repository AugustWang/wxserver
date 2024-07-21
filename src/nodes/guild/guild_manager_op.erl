%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(guild_manager_op).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("guild_define.hrl").
-include("string_define.hrl").
-include("little_garden.hrl").
-include("guildbattle_define.hrl").
%%------------------------------------------------------------------------------------------------------------
%%	guild_list : {Id,Name,Level,Silver,Gold,Notice,[memberid],CreateDate,LastActiveTime,SendWarningMail}
%%	member_list: {MemberId,Name,Gender,Level,Class,Posting,Contribution,TotleContribution,LastOnlineTime,NickName,TodayCount,TotalCount}														
%%	facility_list : {{GuildId,Facilityid},FaLevel,Upgrade_Start_Time,Fulltime,RequiredContributionOrLevel}
%%	apply_list : {Id,[MemberId]}
%%  guild_smith : {GuildId,LimitCountibution}
%%	apply_member_list :{MemberId,Name,Gender,Level,Class}
%%	log_list:{{Id,Type},[{id,context,date_time,time_stamp}]}
%%	today_online_record: {Id,OnlineMember,Date}
%%	quest_publish_record: {guildid,starttime,lefttime}
%%  guild_member_pos_info {guildid,[{roleid,lineid,mapid}]}
%%  guild_member_binmsg {{guildid,member}}
%%	guild_monster : {guildid,monsterlist}
%%	guild_treasure_transport {guildid,guild_treasure_transport_start_time}
%%  guild_rank_info {guildid,index}
%%------------------------------------------------------------------------------------------------------------
init()->
	guild_facility_op:init(),
	guild_apply_op:init(),
	guild_monster_op:init(),
	guild_member_op:init(),
	guild_shop:init(),
	guild_treasure:init(),
	guild_impeach:init(),
	ets:new(guild_list, [set, protected, named_table]),
	ets:new(log_list,[set,protected, named_table]),
	ets:new(quest_publish_record,[set,protected, named_table]),
	ets:new(guild_treasure_transport,[set,protected, named_table]),
	put(guildbattleplayer,[]),
	put(jszd_guild,[]),
	put(guild_rank_info,[]),
	put(yhzq_fight_guild,[]),
	put(money_log_check_timestamp,{0,0,0}).
	
get_guild_info(GuildId)->
	case ets:lookup(guild_list, GuildId) of
		[]-> [];
		[GuildInfo]->GuildInfo
	end.
	
get_all_guild()->
	case ets:tab2list(guild_list) of
		[]->
			[];
		Info->
			lists:map(fun({Id,_,_,_,_,_,_,_,_,_,_,_})->
							 Id
						 end,Info)
	end.

get_log_info({GuildId,Type})->
	case ets:lookup(log_list, {GuildId,Type}) of
		[]-> [];
		[GuildLog]->GuildLog
	end.

get_quest_info(GuildId)->
	case ets:lookup(quest_publish_record,GuildId) of
		[]->[];
		[QuestInfo]->QuestInfo
	end.

get_guild_treasure_transport_start_time(GuildId)->
	case ets:lookup(guild_treasure_transport,GuildId) of
		[]->[];
		[{_,StartTime}]->StartTime
	end.

update_guild_info(GuildInfo)->
	ets:insert(guild_list,GuildInfo).
	
update_log_info(LogInfo)->
	ets:insert(log_list,LogInfo).

update_quest_record(Info)->
	ets:insert(quest_publish_record,Info).

update_guild_treature_transport(Info)->
	ets:insert(guild_treasure_transport,Info).

add_log_info(GuildId,Type,LogInfo)->
	case get_log_info({GuildId,Type}) of
		[]->
			OldGuildLogList = [];
		{_,List}->
			OldGuildLogList = List
	end,
	LogList = [LogInfo] ++ OldGuildLogList,
	MaxCount = env:get2(logtypemax,Type, ?GUILD_LOG_DEFAULT_NUM),
	case length(LogList) > MaxCount of
		true->
			{NewLogList,_} = lists:split(MaxCount,LogList),			%%取前MaxCount个最新的
			NewGuildInfo = {{GuildId,Type},NewLogList};
		_->
			NewGuildInfo = {{GuildId,Type},LogList}
	end,
	update_log_info(NewGuildInfo).
	
%%如果Posting是帮众,则计算帮会是否已满	
is_posting_full(GuildId,Posting)->
	GuildInfo = get_guild_info(GuildId),
	GuildLevel = get_by_guild_item(level,GuildInfo),
	ProtoInfo = guild_proto_db:get_facility_info(?GUILD_FACILITY,GuildLevel),		
	if
		Posting =:= ?GUILD_POSE_LEADER->
			MaxNum = 1;
		Posting =:= ?GUILD_POSE_VICE_LEADER->
			MaxNum = lists:nth(?GUILD_ADDITION_MAX_VICELEADERNUM,guild_proto_db:get_facility_rate(ProtoInfo));
		Posting =:= ?GUILD_POSE_MASTER->
			MaxNum = lists:nth(?GUILD_ADDITION_MAX_MASTERNUM,guild_proto_db:get_facility_rate(ProtoInfo));
		true->					
			MaxNum = lists:nth(?GUILD_ADDITION_MAX_MEMBERNUM,guild_proto_db:get_facility_rate(ProtoInfo))
	end,
	MaxNum =< guild_member_op:get_member_num_by_posting(GuildId,Posting).
		
load_from_db()->
	init(),	
	AllGuild = guild_spawn_db:get_allguildInfo(),
	Now = timer_center:get_correct_now(),
	{Today,_} = calendar:now_to_local_time(Now),
	lists:foreach(fun(GuildBaseInfo)->
					Id = guild_spawn_db:get_guild_id(GuildBaseInfo),																		
					%%获取帮会成员信息列表
					slogger:msg("read guild_baseinfo ~p ~n",[Id]),
					MemberLists = lists:map(fun(MemberInfo)->		
							MemberId = guild_spawn_db:get_memberid_by_memberinfo(MemberInfo),							
							Contribution = guild_spawn_db:get_contribution_by_memberinfo(MemberInfo),					
							TContribution = guild_spawn_db:get_tcontribution_by_memberinfo(MemberInfo),					
							Posting = guild_spawn_db:get_authgroup_by_memberinfo(MemberInfo),
							NickName = guild_spawn_db:get_nickname_by_memberinfo(MemberInfo),
							TodayMoney = guild_spawn_db:get_todaymoney_by_memberinfo(MemberInfo),
							TotalMoney =  guild_spawn_db:get_totalmoney_by_memberinfo(MemberInfo),
							case guild_member_op:read_memberinfo_from_roledb(MemberId) of
								[]->
									slogger:msg("init guild ~p get ~p error ~n",[Id,MemberId]),
									[]; 															
								{RoleLevel,Role_Name,RoleClass,Gender,LastOnlineTime,LineId,MapId,FightForce}->
									if
										LastOnlineTime =< -1 ->
											guild_member_op:add_pos_info(MemberId,Id,LineId,MapId);
										true->
											nothing
									end,
									guild_member_op:update_member_info({MemberId,Role_Name,Gender,RoleLevel,RoleClass,Posting,Contribution,TContribution,LastOnlineTime,NickName,TodayMoney,TotalMoney,FightForce}),
									MemberId
							end																													
					end,guild_spawn_db:get_members_by_guild(Id)),																						
					%%获取帮会设施列表					
					lists:foreach( fun({_,_,GuildId,Facilityid,FaLevel,Upgrade_Start_Time,Upgrade_Left_Time,Required,Contribution})->						
						guild_facility_op:update_facility_info({{GuildId,Facilityid},FaLevel,Upgrade_Start_Time,Upgrade_Left_Time,Required,Contribution})					
					end,guild_spawn_db:get_guild_facility_infos(Id)),
					%%获取申请入帮人员列表
					ApplyInfo = guild_spawn_db:get_guild_applyinfo(GuildBaseInfo),
					lists:foreach(fun(RoleId)->
										case guild_member_op:read_memberinfo_from_roledb(RoleId) of
											[]->
												nothing;
											{RoleLevel,Role_Name,RoleClass,Gender,LastOnlineTime,LineId,MapId,_}->
												guild_apply_op:update_apply_member_info({RoleId,Role_Name,Gender,RoleLevel,RoleClass})
										end
									end,ApplyInfo),
					guild_apply_op:update_apply_info({Id,ApplyInfo}),
					%%获取帮会神兽
					case guild_spawn_db:get_guild_monsterinfo(Id) of
						[]->
							ignor;
						{_,Id,MonsterList,LeftTimes,Time,LastCallTime,ActivMonster} ->
							case timer_util:check_same_day(Now, Time) of
								true->
									guild_monster_op:update_guild_monster({Id,MonsterList,LeftTimes,Time,LastCallTime,ActivMonster}),
									guild_spawn_db:add_guild_monster({Id,MonsterList,LeftTimes,Time,LastCallTime,ActivMonster}),
									guild_monster_op:notify_all(Id,MonsterList,LeftTimes,0);
								_->
									guild_monster_op:update_guild_monster({Id,MonsterList,?CALL_GUILD_MONSTER_MAX_TIMES,Time,LastCallTime,ActivMonster}),
									guild_spawn_db:add_guild_monster({Id,MonsterList,?CALL_GUILD_MONSTER_MAX_TIMES,Time,LastCallTime,ActivMonster}),
									guild_monster_op:notify_all(Id,MonsterList,?CALL_GUILD_MONSTER_MAX_TIMES,0)
							end
					end,
					%%获取帮会日志信息
					load_guild_log(Id),	
					Name = guild_spawn_db:get_guild_name(GuildBaseInfo),
					Level = guild_spawn_db:get_guild_level(GuildBaseInfo),
					Silver = guild_spawn_db:get_guild_silver(GuildBaseInfo),
					Gold = guild_spawn_db:get_guild_gold(GuildBaseInfo),
					Notice = guild_spawn_db:get_guild_notice(GuildBaseInfo),
					CreateDate = guild_spawn_db:get_guild_createdate(GuildBaseInfo),																															
					ChatGroup = guild_spawn_db:get_guild_chatgroup(GuildBaseInfo),
					VoiceGroup = guild_spawn_db:get_guild_voicegroup(GuildBaseInfo),
					LastActiveTime = guild_spawn_db:get_guild_lastactivetime(GuildBaseInfo),
					SendWarningMail = guild_spawn_db:get_guild_sendwarningmail(GuildBaseInfo),
					Treasure_transport_start_Time = guild_spawn_db:get_guild_treasure_transport(GuildBaseInfo),
					update_guild_info({Id,Name,Level,Silver,Gold,Notice,MemberLists,CreateDate,ChatGroup,VoiceGroup,LastActiveTime,SendWarningMail}),
					guild_member_op:update_online_record({Id,Today,[]}),
					update_guild_treature_transport({Id,Treasure_transport_start_Time}),
					%%获取帮会任务发布信息
					case guild_spawn_db:get_questinfo_by_guild(Id) of
						[]->
							update_quest_record({Id,{0,0,0},0});
						QuestInfo->
							StartTime = guild_spawn_db:get_questinfo_starttime(QuestInfo),
							LeftTime = cal_quest_left_time(StartTime,Now),
							update_quest_record({Id,StartTime,LeftTime})
					end,
					case guild_spawn_db:get_guild_right_limit(Id) of
						[]->
							guild_spawn_db:set_guild_right_limit_to_ets({Id,0,0});
						{_,_,Smith,Battle}->
							guild_spawn_db:set_guild_right_limit_to_ets({Id,Smith,Battle})
					end
				end,AllGuild ),
	guild_impeach:load_db(),
	FirstWaitTime = 10*60*1000,
	erlang:send_after(FirstWaitTime,self(),{upgrade_timer}),
	guild_rank_sort_loop(),
	init_guild_score_rank().
	

%%
%%加载帮会日志
%%
load_guild_log(GuildId)->
	TypeList = [?GUILD_LOG_MEMBER_MANAGER,
				?GUILD_LOG_UPGRADE,
				?GUILD_LOG_MODIFY_PRICES,
				?GUILD_LOG_CONTRIBUTION,
				?GUILD_LOG_MALL,
				?GUILD_LOG_QUEST,
				?GUILD_LOG_PACKAGE],
	lists:foreach(fun(Type)->
				load_guild_log(GuildId,Type)
			end,TypeList).
%%
load_guild_log(GuildId,Type)->
	LogInfo = guild_spawn_db:get_guild_loginfo(GuildId,Type),
	case LogInfo of
		[]->
			update_log_info({{GuildId,Type},[]});
		_->
			try
				GuildLog = lists:map(fun(Info)->
											Id = guild_spawn_db:get_guild_log_memberid(Info),
											Description = guild_spawn_db:get_guild_log_description(Info),
											Time = guild_spawn_db:get_guild_log_time(Info),
											Context = 
												case guild_log:format_log(Type,Description) of
													error->
														slogger:msg("read guild_log error ~p ~n",[Info]),
														[];
													{_,StrList}->
														StrList														
												end,
											Datetime = calendar:now_to_local_time(Time),
											{Id,Context,Datetime,Time}
								end,LogInfo),
					%%最新的在最前面
					SortFun = fun({_,_,_,Time1},{_,_,_,Time2})->
										timer:now_diff(Time1,Time2) > 0   %% Time2 > Time1
								end,
					
					update_log_info({{GuildId,Type},lists:sort(SortFun,GuildLog)})
				catch
					E:R->
						slogger:msg("read guild log E:~p R:~p Info:~p ~n",[E,R,LogInfo]),
						update_log_info({{GuildId,Type},[]})
				end
		end.

%%
%%删除帮会日志
%%
delete_guild_log(GuildId)->
	TypeList = [?GUILD_LOG_MEMBER_MANAGER,
				?GUILD_LOG_UPGRADE,
				?GUILD_LOG_MODIFY_PRICES,
				?GUILD_LOG_CONTRIBUTION,
				?GUILD_LOG_MALL,
				?GUILD_LOG_QUEST],
	lists:foreach(fun(Type)->
				ets:delete(facility_list,{GuildId,Type})
			end,TypeList).

proc_create(Roleid,Name,Notice,Create_Level)->
	case guild_spawn_db:create_guild(Name,Notice,Create_Level) of
		 {failed,invalid_name}->
		 		GuildObject = [],
		 		Errno = ?GUILD_ERRNO_CREATE_INVALIDNAME;		 		
		 {failed,repeaded_name}->
		 		GuildObject = [],
		 		Errno = ?GUILD_ERRNO_CREATE_REPEADNAME;
		 {failed,Other}->
		 		GuildObject = [],
		 		slogger:msg("guild_manager create_guild error:~p~n",[Other]),		 
		 		Errno = ?GUILD_ERRNO_UNKNOWN;
		 {ok,GuildObject}->		 	
		 		Errno = []
	end,	
	if
		Errno =/= []->
			MessageError = guild_packet:encode_guild_opt_result_s2c(Errno),
			role_pos_util:send_to_role_clinet(Roleid,MessageError),
			error;
		true->
			CreateId = guild_spawn_db:get_guild_id(GuildObject),
			CreateName = guild_spawn_db:get_guild_name(GuildObject),
			CreateLevel = guild_spawn_db:get_guild_level(GuildObject),
			CreateSilver = guild_spawn_db:get_guild_silver(GuildObject),%%游戏币，银币
			CreateGold = guild_spawn_db:get_guild_gold(GuildObject),
			CreateNotice = guild_spawn_db:get_guild_notice(GuildObject),
			CreateDate = guild_spawn_db:get_guild_createdate(GuildObject),
			LastActiveTime = guild_spawn_db:get_guild_lastactivetime(GuildObject),
			Treasure_transport_start_Time = guild_spawn_db:get_guild_treasure_transport(GuildObject),%%镖车（等级+经验+金钱）
			%%创建组员
			guild_spawn_db:add_member_to_guild(CreateId,Roleid,?GUILD_POSE_LEADER),
			%%创建设施
			guild_spawn_db:set_guild_facility(CreateId,?GUILD_FACILITY,1,0,0,0,0),
			guild_spawn_db:set_guild_facility(CreateId,?GUILD_FACILITY_SMITH,0,0,0,0,0),
			guild_spawn_db:set_guild_facility(CreateId,?GUILD_FACILITY_TREASURE,0,0,0,0,0),
			%%更新本地帮会信息
			guild_facility_op:create_guild_to_list({CreateId,CreateName,CreateLevel,CreateSilver,CreateGold,CreateNotice,[],CreateDate,[],[],LastActiveTime,false}),
			guild_member_op:add_online_member(CreateId,Roleid),
			%%更新人物信息				 		
			{Role_Level,Role_Name,Role_Class,Gender,Online,LineId,MapId,FightForce} = guild_member_op:read_memberinfo_from_remote(Roleid),
			guild_member_op:add_pos_info(Roleid,CreateId,LineId,MapId),	 
			MemberInfo = {Roleid,Role_Name,Gender,Role_Level,Role_Class,?GUILD_POSE_LEADER,0,0,Online,[],{{0,0,0},0},0,FightForce},		%%添加nickname
			guild_member_op:add_member_to_guild(CreateId,MemberInfo),		 			 		
			MessageGuild = {guildmanager_msg,{update_guild_info,guild_member_op:make_guild_info_for_member(Roleid,CreateId)}},				
			role_pos_util:send_to_role(Roleid,MessageGuild),
			send_guild_info_to_client(Roleid,CreateId),
			gm_logger_guild:guild_create(CreateId,CreateName,Roleid),
			gm_logger_role:role_join_guild(Roleid,CreateId),
			update_guild_treature_transport({CreateId,Treasure_transport_start_Time}),
			Now = now(),
			guild_monster_op:update_guild_monster({CreateId,[],?CALL_GUILD_MONSTER_MAX_TIMES,Now,{0,0,0},[]}),
			guild_spawn_db:add_guild_monster({CreateId,[],?CALL_GUILD_MONSTER_MAX_TIMES,Now,{0,0,0},[]}),
			guild_monster_op:notify_all(CreateId,[],?CALL_GUILD_MONSTER_MAX_TIMES,0),
			%%删除离开帮会记录
			case guild_spawn_db:get_member_leave_info(Roleid) of
				[]->
					nothing;
				LeaveInfo->
					guild_spawn_db:del_member_leave_info(LeaveInfo)
			end,
			MsgLimit = guild_packet:encode_change_guild_right_limit_s2c(0,0),
			guild_spawn_db:set_guild_right_limit_to_ets({CreateId,0,0}),
			role_pos_util:send_to_role_clinet(Roleid,MsgLimit),
			role_pos_util:send_to_role(Roleid, {quest_scripts,{quest_join_guild}}),
			Proc = guild_instance_sup:make_proc_name(guild_instance,{?GUILD_INSTANCEID,CreateId}),
			MapProc = battle_ground_processor:make_map_proc_name(Proc),
			ok
		end.
		
proc_change_notice(GuildId,Notice)->
	case get_guild_info(GuildId) of
		[]->
			slogger:msg("proc_guild_base_info_changed error GuildId ~p",[GuildId]);
		GuildInfo->
			NewNotice = get_filter_string(Notice),	
			NewInfo = set_by_guild_item(notice,NewNotice,GuildInfo),
			update_guild_info(NewInfo),
			guild_spawn_db:set_guild_notice(GuildId,NewNotice),
			broad_cast_guild_base_changed_to_client(NewInfo)			
	end.	

get_guild_name(GuildId)->
	case get_guild_info(GuildId) of
		[]->
			[];
		GuildInfo ->
			get_by_guild_item(name,GuildInfo)
	end.

%%
%%return guild_info
%%
resume_guild_money(RequiredMoneyList,GuildInfo,Reason)->
	GuildId = get_by_guild_item(id,GuildInfo),
	lists:foldl(fun({MoneyType,MoneyCount},GuildInfoTmp)->
				if
					GuildInfoTmp =/= []->
						if
							MoneyType =:= ?MONEY_BOUND_SILVER->
								Money = silver;								
							true->
								Money = gold										
						end,
						NowMoney = get_by_guild_item(Money,GuildInfoTmp),
						%%io:format("NowMoney ~p ~n",[NowMoney]),
						if
							 NowMoney >= MoneyCount->
								gm_logger_guild:guild_money_change(GuildId,NowMoney - MoneyCount,-MoneyCount,Reason),							
								set_by_guild_item(Money,NowMoney - MoneyCount,GuildInfoTmp);		
							true->
								[]
						end;						
					true->
						[]
				end end,GuildInfo,RequiredMoneyList).

%%
%%return guild_info
%%
add_guild_money(AddMoneyList,GuildInfo,Reason)->
	GuildId = get_by_guild_item(id,GuildInfo),
	lists:foldl(fun({MoneyType,MoneyCount},GuildInfoTmp)->
				if
					GuildInfoTmp =/= []->
						if
							MoneyType =:= ?MONEY_BOUND_SILVER->
								Money = silver;								
							true->
								Money = gold										
						end,
						NowMoney = get_by_guild_item(Money,GuildInfoTmp),
						if
							 MoneyCount >= 0->
								gm_logger_guild:guild_money_change(GuildId,NowMoney + MoneyCount,MoneyCount,Reason),							
								set_by_guild_item(Money,NowMoney + MoneyCount,GuildInfoTmp);
							true->
								[]
						end;						
					true->
						[]
				end end,GuildInfo,AddMoneyList).
			
proc_get_recruite_info(RoleId)->
	LeaderAndFormalFun =
		fun(MemberId,{TmpLeader,TmpFormalNum})->
			MemberInfo = guild_member_op:get_member_info(MemberId),						
			case guild_member_op:get_by_member_item(posting,MemberInfo) of
				?GUILD_POSE_LEADER->
					FormalNum = TmpFormalNum,
					Leader = MemberId;
				?GUILD_POSE_PREMEMBER ->
					Leader = TmpLeader,
					FormalNum = TmpFormalNum+1;
				_->
					Leader = TmpLeader,
					FormalNum = TmpFormalNum
			end,
			{Leader,FormalNum}			
		end,
				
	AllGuildRecuiInfo = ets:foldl(fun(GuildInfo,Acc)->
			GuildId = get_by_guild_item(id,GuildInfo),
			try
				GuildName = get_by_guild_item(name,GuildInfo),
				GuildLevel = get_by_guild_item(level,GuildInfo),
				Members = get_by_guild_item(members,GuildInfo),	
				Silver = get_by_guild_item(silver,GuildInfo),%%1月25日加【小五】	
				CreateDate = get_by_guild_item(createdate,GuildInfo),
				Membernum = erlang:length(Members),
				GuildFacilityInfo = guild_facility_op:get_facility_info(GuildId,?GUILD_FACILITY),
				Facslevel = [guild_facility_op:get_by_facility_item(level,guild_facility_op:get_facility_info(GuildId,?GUILD_FACILITY_TREASURE))] ++ 
							[guild_facility_op:get_by_facility_item(level,guild_facility_op:get_facility_info(GuildId,?GUILD_FACILITY_SMITH))],					
				Restrict = guild_facility_op:get_by_facility_item(restrict,GuildFacilityInfo),
				{Leader,FormalNum} = lists:foldl(LeaderAndFormalFun,{0,0},Members),
				MemberInfo = guild_member_op:get_member_info(Leader),
				LeaderName = guild_member_op:get_by_member_item(name,MemberInfo),
				IsFull = is_posting_full(GuildId,?GUILD_POSE_PREMEMBER),	
				IsApplyFull = (length(guild_apply_op:get_apply_info(GuildId)) >= ?GUILD_MAX_APPLY_NUM),
				if
					IsFull->
						ApplyFlag = ?GUILD_MEMBER_FULL;
					IsApplyFull->
						ApplyFlag = ?GUILD_APPLY_FULL;
					true->				
						case guild_apply_op:check_someone_in_applylist(GuildId,RoleId) of
							true->
								ApplyFlag = ?GUILD_ALREADY_APPLY;
							_->
								ApplyFlag = ?GUILD_CAN_APPLY
						end
				end,
				case lists:keyfind(GuildId,1,get(guild_rank_info)) of
					false->
						SortIndex = length(get(guild_rank_info)) + 1,
						put(guild_rank_info,[{GuildId,SortIndex}|get(guild_rank_info)]);
					{_,SortIndex}->
						nothing
				end,	
				[guild_packet:make_recruiteinfo(GuildId ,GuildName ,
				GuildLevel,Silver, Membernum,FormalNum,LeaderName, Restrict, Facslevel, ApplyFlag,CreateDate,SortIndex)] ++ Acc
			catch
				E:R->slogger:msg("GuildId ~p ~p ~p ~p~n",[GuildId,E,R,erlang:get_stacktrace()]),
				Acc
			end
		end,[],guild_list),
		Message = guild_packet:encode_guild_recruite_info_s2c(AllGuildRecuiInfo),
		role_pos_util:send_to_role_clinet(RoleId,Message).
						 				
%%捐献记录日志,但只有捐元宝,才会记入帮会贡献
%%帮会二期中 游戏币 元宝 利川木皆可按一定比例转换为帮贡
%%						 							
proc_contribute(GuildId,RoleId,MoneyTypeId,MoneyCount)->
	GuildInfo = get_guild_info(GuildId),
	MemberInfo = guild_member_op:get_member_info(RoleId),	
	case (GuildInfo=/=[]) and (MemberInfo=/=[]) of
		false->
			nothing,
			error;
		_->
			if
				MoneyTypeId =:= ?MONEY_SILVER->
					MoneyType = silver;
				true ->
					MoneyType = gold
			end,	
			NewMoneyValue = get_by_guild_item(MoneyType,GuildInfo)+MoneyCount,
			OldTotalMoney = guild_member_op:get_by_member_item(totalmoney,MemberInfo),			
			if
				MoneyType =:= gold->		
					guild_spawn_db:set_guild_gold(GuildId,NewMoneyValue),
					{A,B} = guild_proto_db:get_settingvalue(?GUILD_GOLD_TO_CONTRIBUTION_FACTOR_KEY),
					AddContribution = trunc(MoneyCount/A*B),
					NewMemberInfo = MemberInfo;
				true-> 
					guild_spawn_db:set_guild_silver(GuildId,NewMoneyValue),	
					{A,B} = guild_proto_db:get_settingvalue(?GUILD_SILVER_TO_CONTRIBUTION_FACTOR_KEY),
					NewTotalMoney = OldTotalMoney + MoneyCount,
					AddContribution = trunc(NewTotalMoney/A*B) - trunc(OldTotalMoney/A*B),
					{TimeStamp,OldTodayMoney} = guild_member_op:get_by_member_item(todaymoney,MemberInfo),					
					Now = now(),
					CheckTimeStamp = timer_util:check_same_day(Now,TimeStamp),
					if
						CheckTimeStamp->
							NewTodayMoney = OldTodayMoney + MoneyCount;
						true->
							NewTodayMoney = MoneyCount
					end,
					NewMemberInfo1 = guild_member_op:set_by_member_item(todaymoney,{Now,NewTodayMoney},MemberInfo),
					NewMemberInfo = guild_member_op:set_by_member_item(totalmoney,NewTotalMoney,NewMemberInfo1),
					guild_spawn_db:set_member_money(RoleId,{Now,NewTodayMoney},NewTotalMoney)										
			end,			
			if	
				AddContribution	> 0 ->
					NewContribution = guild_member_op:get_by_member_item(contribution,NewMemberInfo)+AddContribution,
					NewTContribution = guild_member_op:get_by_member_item(totlecontribution,NewMemberInfo)+AddContribution,
					NewMemberInfoFinal = guild_member_op:set_by_member_item(contribution,NewContribution,NewMemberInfo),
					NewMemberInfoFinal1 = guild_member_op:set_by_member_item(totlecontribution,NewTContribution,NewMemberInfoFinal),
					guild_member_op:update_member_info(NewMemberInfoFinal1),		
					guild_spawn_db:set_member_contribution(RoleId,NewContribution),
					guild_spawn_db:set_member_tcontribution(RoleId,NewTContribution),
					%%发送给进程
					send_base_info_update(RoleId,GuildId),
					%%广播贡献度变化给客户端
					guild_member_op:add_memberbinmsg_to_ets(GuildId,RoleId),	
					gm_logger_role:role_guild_contribution_change(RoleId,GuildId,AddContribution,money_contribute);	
				true->
					guild_member_op:update_member_info(NewMemberInfo)
			end,
			%%
			%%更新帮会日志
			%%
			MemberName = guild_member_op:get_member_name(RoleId),
			MemberPosting = guild_member_op:get_member_posting(RoleId),
			LogInfo = {money,MemberName,MemberPosting,{MoneyTypeId,MoneyCount}},
			add_log(GuildId,?GUILD_LOG_CONTRIBUTION,LogInfo),						
			NewInfo = set_by_guild_item(MoneyType,NewMoneyValue,GuildInfo),	
			gm_logger_guild:guild_money_change(GuildId,NewMoneyValue,MoneyCount,contribute),
			update_guild_info(NewInfo),			
			broad_cast_guild_base_changed_to_client(NewInfo),		
			ok
	end.

proc_add_contribute(GuildId,RoleId,Contribute)->
	MemberInfo = guild_member_op:get_member_info(RoleId),
	case MemberInfo=/=[] of	
		false ->
			nothing,
			error;
		_ ->
			OldContribution = guild_member_op:get_by_member_item(contribution,MemberInfo),
			case Contribute < 0 of
				true->
					 case (OldContribution + Contribute) <0 of
					 	true->
					 		error;
					 	_->
					 		NewContribution = OldContribution+Contribute,
					 		NewMemberInfo = guild_member_op:set_by_member_item(contribution,NewContribution,MemberInfo),
					 		guild_member_op:update_member_info(NewMemberInfo),
					 		guild_spawn_db:set_member_contribution(RoleId,NewContribution),	
					 		guild_member_op:add_memberbinmsg_to_ets(GuildId,RoleId),
					 		ok
					 end;
				_->
					NewContribution = OldContribution+Contribute,
					NewTContribution = guild_member_op:get_by_member_item(totlecontribution,MemberInfo)+Contribute,
					NewMemberInfo = guild_member_op:set_by_member_item(contribution,NewContribution,MemberInfo),
					NewMemberInfo1 = guild_member_op:set_by_member_item(totlecontribution,NewTContribution,NewMemberInfo),
					guild_member_op:update_member_info(NewMemberInfo1),
					guild_spawn_db:set_member_contribution(RoleId,NewContribution),								
					guild_spawn_db:set_member_tcontribution(RoleId,NewTContribution),								
					guild_member_op:add_memberbinmsg_to_ets(GuildId,RoleId),
					gm_logger_role:role_guild_contribution_change(RoleId,GuildId,Contribute,contribute_by_item),			
					ok
			end
	end.
%%
%%
%%
check_money_log(Now)->
	LastTimeStamp = get(money_log_check_timestamp),
	CheckLastTimeStamp = timer_util:check_same_day(Now,LastTimeStamp),
	if
		CheckLastTimeStamp->
			nothing;
		true->
			put(money_log_check_timestamp,Now),
			ets:foldl(fun(MemberInfo,Acc)->
							MemberId = guild_member_op:get_by_member_item(id,MemberInfo),
							{TimeStamp,TodayMoney} = guild_member_op:get_by_member_item(todaymoney,MemberInfo),
							TotalMoney = guild_member_op:get_by_member_item(totalmoney,MemberInfo),
							if
								TotalMoney > 0->
									CheckTimeStamp = timer_util:check_same_day(Now,TimeStamp),
									if
										CheckTimeStamp->
											nothing;
										true->
											NewMemberInfo = guild_member_op:set_by_member_item(todaymoney,{Now,0},MemberInfo),
											guild_member_op:update_member_info(NewMemberInfo),
											guild_spawn_db:set_member_money(MemberId,{Now,0},TotalMoney)
									end;
								true->
									nothing
							end,
							Acc		
						end,[],member_list)
	end.
%%
%%return bool()
%%
check_active_day(GuildId,Now)->
	{Today,_} = calendar:now_to_local_time(Now),
	case guild_member_op:get_online_info(GuildId) of
		[]->
			slogger:msg("check_active_day get_online_info [] GuildId ~p\n",[GuildId]),
			true;
		{_,RecordDay,RoleList}->
			if
				Today =:= RecordDay ->
					true;
				true->
					guild_member_op:update_online_record({GuildId,Today,[]}),
					case get_guild_info(GuildId) of
						[]->
							slogger:msg("check_active_day get_guild_info error GuildId ~p\n",[GuildId]),
							true;
						GuildInfo->	
							Num = length(RoleList),
							if
								Num < ?GUILD_MIN_ONLINE_MEMBER ->
									LastActiveTime = get_by_guild_item(lastactivetime,GuildInfo),
									{LastDay,_} = calendar:now_to_local_time(LastActiveTime),
									{Days,_} = calendar:time_difference({LastDay,{0,0,0}},{Today,{0,0,0}}),
									%%io:format("days ~p ~n",[Days]),
									if
										Days > ?GUILD_DISBAND_TIME->				%%解散帮会
											proc_guild_disband(system,GuildId),
											false;
										Days > ?GUILD_DISBAND_WARNING_TIME->		%%发送警告邮件
											SendMailFlag = get_by_guild_item(sendwarningmail,GuildInfo),
											if
												SendMailFlag ->
													nothing;
												true->
													guild_disband_warning_mail(GuildId,Today),
													NewInfo = set_by_guild_item(sendwarningmail,true,GuildInfo),
													update_guild_info(NewInfo),
													guild_spawn_db:set_guild_sendwarningmail(GuildId,true)
											end,
											true;
										true->
											true
									end;
								true->
									NewInfo = set_by_guild_item(lastactivetime,Now,GuildInfo),
									update_guild_info(NewInfo),
									%%更新数据库
									guild_spawn_db:set_guild_lastactivetime(GuildId,Now),
									true			
							end	
					end
			end;
		Other->
			slogger:msg("check_active_day get_online_info ~p GuildId ~p\n",[Other,GuildId]),
			true
	end.
%%
%%
%%						
update_quest_lefttime(GuildId,Now)->
		case get_quest_info(GuildId) of
			[]->
				nothing;
			{_,StartTime,LeftTime}->
				if
					LeftTime =< 0->
						nothing;
					true->
						CurLeftTime = cal_quest_left_time(StartTime,Now),
						update_quest_record({GuildId,StartTime,CurLeftTime})
					end;
			_->
				nothing
		end.
	
proc_change_chatandvoicegroup(LeaderId,GuildId,ChatGroup,VoiceGroup)->
	case get_guild_info(GuildId) of
		[]->
			slogger:msg("proc_change_chatandvoicegroup error GuildId ~p",[GuildId]);
		GuildInfo->	
			TempInfo = set_by_guild_item(chatgroup,ChatGroup,GuildInfo),
			NewInfo = set_by_guild_item(voicegroup,VoiceGroup,TempInfo),
			update_guild_info(NewInfo),
			guild_spawn_db:set_guild_chatgroup(GuildId,ChatGroup),
			guild_spawn_db:set_guild_voicegroup(GuildId,VoiceGroup),
			broad_cast_guild_base_changed_to_client(NewInfo)			
	end.	

%%
%%获取日志
%%
proc_get_guild_log(RoleId,GuildId,Type)->
	case get_log_info({GuildId,Type}) of
		[]->
			LogsRecord = [];
		{_,LogList}->
			LogsRecord = lists:map(fun({Id,Context,DateTime,_})->
										guild_packet:make_guildlog(Type,Id,Context,DateTime)
									end,LogList)	
	end,
	%%io:format("proc_get_guild_log ~p ~n",[LogsRecord]),
	Message = guild_packet:encode_guild_log_normal_s2c(LogsRecord),
	role_pos_util:send_to_role_clinet(RoleId,Message).	

%%
%%添加日志
%%
add_log(GuildId,Type,Info)->
	case guild_log:format_log(Type,Info) of
		error->
			slogger:msg("add unknown log type:~p info:~p\n",[Type,Info]);
		{Id,StrList}->
			Now = timer_center:get_correct_now(),
			DateTime = calendar:now_to_local_time(Now),
			%%插入ets
			LogEtsInfo = {Id,StrList,DateTime,Now},
			add_log_info(GuildId,Type,LogEtsInfo),
			%%记入数据库
			guild_spawn_db:add_guild_log(GuildId,Type,Id,Info),
			%%广播给帮会成员
			LogMessage = guild_packet:make_guildlog(Type,Id,StrList,DateTime),
			Message = guild_packet:encode_guild_update_log_s2c(LogMessage),
			broad_cast_to_guild_client(GuildId,Message);
		_->
			slogger:msg("add unknown log type:~p info:~p\n",[Type,Info])
	end.

add_guild_package_log(RoleId,GuildId,Type,Info)->
	case guild_log:format_log(Type,Info) of
		error->
			slogger:msg("add unknown log type:~p info:~p\n",[Type,Info]);
		{Id,StrList}->
			Now = timer_center:get_correct_now(),
			DateTime = calendar:now_to_local_time(Now),
			%%插入ets
			LogEtsInfo = {Id,StrList,DateTime,Now},
			add_log_info(GuildId,Type,LogEtsInfo),
			%%记入数据库
			guild_spawn_db:add_guild_log(GuildId,Type,Id,Info);
			%Message = guild_packet:encode_guild_storage_log_s2c([StrList]),
		%	role_pos_util:send_to_role_clinet(RoleId,Message);
		_->
			slogger:msg("add unknown log type:~p info:~p\n",[Type,Info])
	end.

send_to_client_package_log(RoleId,GuildId)->
	case get_log_info({GuildId,?GUILD_LOG_PACKAGE}) of
		[]->nothing;
			%io:format("@@@@@@@@@@@@   no log~n",[]);
		{_,List}->
			LogLists=lists:map(fun({_,Info,_,_})->
									   case Info of
										   {RoleName,Operate,ItemId,DateTime,Count}->
											  {Month,Day,Hour,Min}=DateTime,
											  {gsl,RoleName,Operate,ItemId,Month,Day,Hour,Min,Count};
										   _->
											   []
									   end end, List),
			Message=guild_packet:encode_guild_storage_log_s2c(LogLists),
			role_pos_util:send_to_role_clinet(RoleId,Message)
	end.
		   

%%解散帮会
proc_guild_disband(RoleId,GuildId)->
	GuildInfo = get_guild_info(GuildId),	 
	case (GuildInfo=/=[]) of
		true->
			Members = get_by_guild_item(members,GuildInfo),
			%%踢出所有人
			lists:foreach(fun(MemberId)->
								%%发送离开									
								MsgDestroy = guild_packet:encode_guild_destroy_s2c(?GUILD_DESTROY),
								role_pos_util:send_to_role(MemberId,{guildmanager_msg,{guild_destroy}}),
								role_pos_util:send_to_role_clinet(MemberId,MsgDestroy),
								gm_logger_role:role_join_guild(MemberId,{0,0}),
								%%删除ets member_list
								ets:delete(member_list,MemberId)
							end,Members),
			guild_spawn_db:delete_all_member_by_guildid(GuildId),
			%%删除帮会信息
			ets:delete(guild_list,GuildId),
			guild_spawn_db:delete_guild(GuildId),
			%%删除日志
			delete_guild_log(GuildId),
			guild_spawn_db:delete_guild_log(GuildId),
			%%删除帮会设施
			guild_facility_op:delete_guild_facilityid(GuildId),
			guild_spawn_db:delete_guild_facility(GuildId),
			%%删除申请信息		
			MemberList= guild_apply_op:get_apply_info(GuildId),
			lists:foreach(fun(MemberId)->
							guild_apply_op:remove_info_from_applymemberinfo(MemberId)	
						end,MemberList),
			ets:delete(apply_list,GuildId),
			%%删除帮会上线记录
			ets:delete(today_online_record,GuildId),
			%%删除帮会商城记录
			guild_shop:delete_guild(GuildId),
			%%删除帮会任务记录
			ets:delete(quest_publish_record,GuildId),
			ets:delete(guild_treasure_transport,GuildId),
			guild_spawn_db:delete_questinfo_by_guild(GuildId),
			%%删除弹劾信息
			guild_spawn_db:del_impeach_info(GuildId),
			delete_guild_score(GuildId),
			%%gm log
			gm_logger_guild:guild_dissolve(GuildId,RoleId),
			guild_instance:stop_instance(GuildId);
		_->
			nothing
	end.

%%
%%获取已激活的物品
%%	
%proc_guild_get_shop_item(RoleId,GuildId,0)->
%	FacilityInfo = get_facility_info(GuildId,?GUILD_FACILITY_SHOP),
%	Level = get_by_facility_item(level,FacilityInfo),
%	GetItemFunc = fun(ShopType,{StartIndex,ResultItemList})->
%					case guild_proto_db:get_guild_shop_info(ShopType) of
%						[]->
%							io:format("proc_guild_get_shop_item []~n"),
%							{StartIndex,ResultItemList};	
%						Info->
%							io:format("proc_guild_get_shop_item ~p ~n",[Info]),
%							{NextIndex,ItemsResult} = 
%								lists:foldl(fun(Id,{CurIndex,ItemList})->
%										case guild_proto_db:get_guild_shopitem_info(Id) of
%											[]->
%												{CurIndex,ItemList};
%											ItemInfo->
%												{_,RealPrice} = guild_proto_db:get_guild_shopitem_discount(ItemInfo),
%												ItemPacket = guild_packet:make_guildshopitem(Id,CurIndex,RealPrice),
%												{CurIndex+1,ItemList ++ [ItemPacket]}
%										end
%									end,{StartIndex,ResultItemList},guild_proto_db:get_guild_shop_itemslist(Info)),
%							{NextIndex,ResultItemList ++ ItemsResult}
%					end
%				end,
%	{_,ResultItemsPacket} = lists:foldl(GetItemFunc,{1,[]},lists:sep(1,Level)),
%	Message = guild_packet:encode_guild_get_shop_item_s2c(ShopType,ResultItemsPacket),
%	role_pos_util:send_to_role_clinet(RoleId,Message).

%%
%%全部
%%
proc_guild_get_shop_item(RoleId,GuildId,0)->
	FacilityInfo = guild_facility_op:get_facility_info(GuildId,?GUILD_FACILITY_SHOP),
	Level = guild_facility_op:get_by_facility_item(level,FacilityInfo),
	%%Level = ?GUILD_SHOP_MAX_LEVEL,
	Now = timer_center:get_correct_now(),
	ItemList = 
		case guild_proto_db:get_guild_shop_info(Level) of
			[]->
				[];	
			Info->
				lists:foldl(fun(Id,ReList)->
							case guild_proto_db:get_guild_shopitem_info(Id) of
								[]->
									ReList;
								ItemInfo->
									{_,RealPrice} = guild_proto_db:get_guild_shopitem_discount(ItemInfo),
									BuyNum = guild_shop:get_item_buy_count_today({GuildId,RoleId,Id},Now),
									Re = guild_packet:make_guildshopitem(Id,
													guild_proto_db:get_guild_shopitem_showindex(ItemInfo),
													RealPrice,BuyNum),
									ReList ++ [Re]
							end
						end,[],guild_proto_db:get_guild_shop_itemslist(Info)++guild_proto_db:get_guild_shop_preview_itemslist(Info))
		end,
	SortFunc = fun(ItemA,ItemB)->
				IndexA = guild_packet:get_guildshopitemshowindex(ItemA),
				IndexB =  guild_packet:get_guildshopitemshowindex(ItemB),
				IndexA < IndexB
			end,
	SortItemList = lists:sort(SortFunc,ItemList),
	%%io:format("shop_item level ~p type ~p ~p ~n",[Level,0,SortItemList]),
	Message = guild_packet:encode_guild_get_shop_item_s2c(0,SortItemList),
	role_pos_util:send_to_role_clinet(RoleId,Message);

proc_guild_get_shop_item(RoleId,GuildId,ItemType)->
	FacilityInfo = guild_facility_op:get_facility_info(GuildId,?GUILD_FACILITY_SHOP),
	Level = guild_facility_op:get_by_facility_item(level,FacilityInfo),
	%%Level = ?GUILD_SHOP_MAX_LEVEL,
	Now = timer_center:get_correct_now(),
	ItemList = 
		case guild_proto_db:get_guild_shop_info(Level) of
			[]->
				[];	
			Info->
				lists:foldl(fun(Id,ReList)->
							case guild_proto_db:get_guild_shopitem_info(Id) of
								[]->
									ReList;
								ItemInfo->
									case guild_proto_db:get_guild_shopitem_type(ItemInfo) of
										ItemType->
											{_,RealPrice} = guild_proto_db:get_guild_shopitem_discount(ItemInfo),
											BuyNum = guild_shop:get_item_buy_count_today({GuildId,RoleId,Id},Now),
											Re = guild_packet:make_guildshopitem(Id,
													guild_proto_db:get_guild_shopitem_showindex(ItemInfo),
													RealPrice,BuyNum),
											ReList ++ [Re];
										_->
											ReList
									end
							end
						end,[],guild_proto_db:get_guild_shop_itemslist(Info)++guild_proto_db:get_guild_shop_preview_itemslist(Info))
		end,
	SortFunc = fun(ItemA,ItemB)->
				IndexA = guild_packet:get_guildshopitemshowindex(ItemA),
				IndexB =  guild_packet:get_guildshopitemshowindex(ItemB),
				IndexA < IndexB
			end,
	SortItemList = lists:sort(SortFunc,ItemList),
	%%io:format("shop_item level ~p type ~p ~p ~n",[Level,ItemType,SortItemList]),
	Message = guild_packet:encode_guild_get_shop_item_s2c(ItemType,SortItemList),
	role_pos_util:send_to_role_clinet(RoleId,Message).

proc_guild_shop_buy_item(RoleId,GuildId,ShopType,Id,Count,RoleMoney)->
	guild_shop:buy_item(RoleId,GuildId,ShopType,Id,Count,RoleMoney).

%%
%%全部
%%
proc_guild_get_treasure_item(RoleId,GuildId,0)->
	FacilityInfo = guild_facility_op:get_facility_info(GuildId,?GUILD_FACILITY_TREASURE),
	%%Level = get_by_facility_item(level,FacilityInfo),
	Now = timer_center:get_correct_now(),
	ItemList = 
		case guild_proto_db:get_guild_treasure_info() of
			[]->
				[];	
			ItemLists->
				lists:foldl(fun(Id,ReList)->
							case guild_proto_db:get_guild_treasureitem_info(Id) of
								[]->
									ReList;
								ItemInfo->
									{_,RealPrice} = guild_treasure:get_treasure_item_realprice({GuildId,Id}),
									BuyNum = guild_treasure:get_item_buy_count_today({GuildId,RoleId,Id},Now),
									Re = guild_packet:make_guildtreasureitem(Id,
													guild_proto_db:get_guild_treasureitem_showindex(ItemInfo),
													RealPrice,BuyNum),
									ReList ++ [Re]
							end
						end,[],ItemLists)
		end,
	SortFunc = fun(ItemA,ItemB)->
				IndexA = guild_packet:get_guildtreasureitemshowindex(ItemA),
				IndexB = guild_packet:get_guildtreasureitemshowindex(ItemB),
				IndexA < IndexB
			end,
	SortItemList = lists:sort(SortFunc,ItemList),
	Message = guild_packet:encode_guild_get_treasure_item_s2c(0,SortItemList),
	role_pos_util:send_to_role_clinet(RoleId,Message);

proc_guild_get_treasure_item(RoleId,GuildId,ItemType)->
	FacilityInfo = guild_facility_op:get_facility_info(GuildId,?GUILD_FACILITY_TREASURE),
	%%Level = get_by_facility_item(level,FacilityInfo),
	Now = timer_center:get_correct_now(),
	ItemList = 
		case guild_proto_db:get_guild_treasure_info() of
			[]->
				[];	
			ItemLists->
				lists:foldl(fun(Id,ReList)->
							case guild_proto_db:get_guild_treasureitem_info(Id) of
								[]->
									ReList;
								ItemInfo->
									case guild_proto_db:get_guild_treasureitem_type(ItemInfo) of
										ItemType->
											{_,RealPrice} = guild_treasure:get_treasure_item_realprice({GuildId,Id}),
											BuyNum = guild_treasure:get_item_buy_count_today({GuildId,RoleId,Id},Now),
											Re = guild_packet:make_guildtreasureitem(Id,
													guild_proto_db:get_guild_treasureitem_showindex(ItemInfo),
													RealPrice,BuyNum),
											ReList ++ [Re];
										_->
											ReList
									end
							end
						end,[],ItemLists)
		end,
	SortFunc = fun(ItemA,ItemB)->
				IndexA = guild_packet:get_guildtreasureitemshowindex(ItemA),
				IndexB = guild_packet:get_guildtreasureitemshowindex(ItemB),
				IndexA < IndexB
			end,
	SortItemList = lists:sort(SortFunc,ItemList),
	Message = guild_packet:encode_guild_get_treasure_item_s2c(ItemType,SortItemList),
	role_pos_util:send_to_role_clinet(RoleId,Message).

proc_guild_treasure_buy_item(RoleId,GuildId,ShopType,Id,Count,RoleMoney)->
	guild_treasure:buy_item(RoleId,GuildId,ShopType,Id,Count,RoleMoney).

proc_guild_treasure_set_price(RoleId,GuildId,ShopType,Id,Price)->
	guild_treasure:change_treasure_price(RoleId,GuildId,ShopType,Id,Price).

proc_publish_guild_quest(RoleId,GuildId)->
	LeftTime = 
		case get_quest_info(GuildId) of
			[]->
				0;
			{_,_,TempLeftTime}->
				TempLeftTime;
			_->
				0
		end,
	if
		LeftTime =< 0->
			Now = timer_center:get_correct_now(),
			DurationTime = guild_proto_db:get_settingvalue(?GUILD_QUEST_DURATION),
			update_quest_record({GuildId,Now,DurationTime}), 
			guild_spawn_db:add_questinfo(GuildId,Now),
			QuestMessage = guild_packet:encode_update_guild_quest_info_s2c(LeftTime),
			broad_cast_to_guild_client(GuildId,QuestMessage);
		true->
			nothing
	end.

cal_quest_left_time(StartTime,Now)->
	DurationTime = guild_proto_db:get_settingvalue(?GUILD_QUEST_DURATION),
	Duration = trunc(timer:now_diff(Now,StartTime)/1000000),
	LeftTime = DurationTime - Duration,
	if
		LeftTime =<0 ->
			0;
		true->
			LeftTime
	end.	

can_get_premiums(GuildId)->
	case get_quest_info(GuildId) of
			[]->
				false;
			{_,_,LeftTime}->
				LeftTime > 0;
			_->
				false
	end.	

proc_get_guild_notice(RoleId,GuildId)->
	GuildInfo = get_guild_info(GuildId),	 
	case (GuildInfo=/=[]) of
		true->
			Notice = get_by_guild_item(notice,GuildInfo),
			Message = guild_packet:encode_send_guild_notice_s2c(GuildId,Notice),
%%			io:format("guild notice ~p ~n",[Message]),
			role_pos_util:send_to_role_clinet(RoleId,Message);
		_->
			nothing
	end.

%%
%%取前Top名帮会
%%	
get_top_guild(Top)->
	AllGuild = get(guild_rank_info),
	Ranks = lists:foldl(fun(Index, Acc)->
							case lists:keyfind(Index,2,AllGuild) of
								false->
									Acc;
								{GuildId,_}->
									Acc ++ [{GuildId,Index}]
							end
						end, [], lists:seq(1,Top)),
	RanksInfo = 
	lists:foldl(fun({GuildId,Rank},Acc)->
					GuildInfo = get_guild_info(GuildId),
					GuildName = get_by_guild_item(name,GuildInfo),
					Acc ++ [{GuildId,GuildName,Rank}]
				end, [], Ranks),
	put(jszd_guild,RanksInfo),
	RanksInfo.

%%
%%检查帮会国王争霸战资格
%% 
%%return [] | [{guildid,guildname,guildleaderid,guildleadername,index}]
guildbattle_check()->
	case length(get({guild_score_rank_info,all})) =:= 0 of
		true->
			AllGuild = get(guild_rank_info),
			check_guild(AllGuild);
		_->
			AllGuild = get({guild_score_rank_info,all}),
			check_guild(AllGuild)
	end.

check_guild(AllGuild)->
	MaxGuildNum = erlang:min(length(AllGuild),?GUILDBATTLE_MAX_GUILD_NUM),
	if
		MaxGuildNum < ?GUILDBATTLE_MIN_GUILD_NUM->
			[];
		true->
			FindList = lists:seq(1,MaxGuildNum),
			FindGuildList = lists:map(fun(Index)->
											  case lists:keyfind(Index,2,AllGuild) of
												  {GuildId,Index} ->
													  {GuildId,Index};
												  {GuildId,Index,_,_,_,_} ->
													  {GuildId,Index}
											  end
									  end,FindList),
			case get_bestguild() of
				{0,0}->
					NewFindGuildList = FindGuildList;
				BestGuildId->
					case lists:keyfind(BestGuildId,1,FindGuildList) of
						false->
							NewFindGuildList = [{BestGuildId,length(FindGuildList)+1}|FindGuildList];
						_->
							NewFindGuildList = FindGuildList
					end
			end,
			lists:foldl(fun({_GuildId,_Index},FindAcc)-> 
				case get_guild_info(_GuildId) of			
						[]->							%%帮会被解散了.........
							FindAcc;
						_GuildInfo->
							GuildName = get_by_guild_item(name,_GuildInfo),
							Members = get_by_guild_item(members,_GuildInfo),
							case get_guild_leader(_GuildId,Members) of
								[]->
									FindAcc;
								{RoleId,RoleName}->
									[{_GuildId,GuildName,RoleId,RoleName,_Index}|FindAcc]
							end	
			       end
			end ,[],NewFindGuildList)
	end.
	
guildbattle_check(overdue)->
	Func = fun(GuildInfo,Acc)->
			AccSize = erlang:length(Acc),
			
			if
				AccSize =:= ?GUILDBATTLE_MAX_GUILD_NUM-1 ->	%%刚满3个  升序排列
					lists:sort(fun(GuildA,GuildB)->
									not compare_fun(GuildA,GuildB)	  
								end ,[GuildInfo|Acc]);
				AccSize < ?GUILDBATTLE_MAX_GUILD_NUM->			%%不满3个的时候 直接追加
					[GuildInfo|Acc];
				true-> %%满足了3个    
					BetterGuild = lists:filter(fun(FGuildInfo)-> compare_fun(FGuildInfo,GuildInfo)	end,Acc),
					BadGuild = Acc -- BetterGuild,
					if
						BadGuild =:= [] ->
							Acc;
						true->
							[_|RemainBadGuild] = BadGuild,
							NewBetterGuild = [GuildInfo|BetterGuild],
							RemainBadGuild ++ NewBetterGuild
					end
			end
		end,		
	ResultGuilds = ets:foldl(Func,[],guild_list),
	case get_bestguild() of
		{0,0}->
			TempResult = ResultGuilds;
		BestGuild->		
			case lists:keyfind(BestGuild,1,ResultGuilds) of
				false->
					case get_guild_info(BestGuild) of			
						[]->							%%国王帮会被解散了.........
							TempResult = ResultGuilds;			
						BestGuildInfo->
							TempResult = [BestGuildInfo|ResultGuilds]
					end;
				_->
					TempResult = ResultGuilds
			end		
	end,
	%%升序
	NewResult = lists:sort(fun(GuildA,GuildB)-> not compare_fun(GuildA,GuildB) end ,TempResult),
	%%降序
	{Return,_} = 	
	lists:foldl(fun(_GuildInfo,{Acc,IndexAcc})-> 
				%%io:format("_GuildInfo ~p ~n",[_GuildInfo]),
				GuildId = get_by_guild_item(id,_GuildInfo),
				GuildName = get_by_guild_item(name,_GuildInfo),
				Members = get_by_guild_item(members,_GuildInfo),
				case get_guild_leader(GuildId,Members) of
					[]->
						{Acc,IndexAcc};
					{RoleId,RoleName}->
						NewIndexAcc = IndexAcc + 1,
						{[{GuildId,GuildName,RoleId,RoleName,NewIndexAcc}|Acc],NewIndexAcc}
				end	
			end ,{[],0},NewResult),
	%%io:format("guildbattle_check ~p ~n",[Return]),
	Return.
	
notify_guild_have_guildbattle_right(GuildIds)->
	lists:foreach(fun({GuildId,_,_,_,_})->
						Message = guild_packet:encode_guild_have_guildbattle_right_s2c(?HAVE_RIGHT),
						send_to_all_client(GuildId,Message)
				end,GuildIds),
	AllGuild = get_all_guild(),
	LeftGuild = AllGuild -- GuildIds,
	lists:foreach(fun(GuildId)->
						Message = guild_packet:encode_guild_have_guildbattle_right_s2c(?NOTHAVE_RIGHT),
						send_to_all_client(GuildId,Message)
					end,LeftGuild).
	
%%
%%国王争霸赛开始
%%
guild_battle_start(GuildIds)->
	put(guildbattleplayer,GuildIds),
	BinMsg = guildbattle_packet:encode_guild_battle_start_s2c(),
	lists:foreach(fun(GuildId)-> broad_cast_to_guild_client(GuildId,BinMsg) end,GuildIds).
	
%%
%%国王争霸赛结束
%%
guild_battle_stop(_BestGuild)->
	put({guild_score_rank_info,all},[]),
	put({guild_score_rank_info,yhzq},[]),
	put({guild_score_rank_info,jszd_battle},[]),
	guild_spawn_db:clear_guild_score(),
	GuildIds = get(guildbattleplayer),
	BinMsg = guildbattle_packet:encode_guild_battle_stop_s2c(),
	lists:foreach(fun(GuildId)-> broad_cast_to_guild_client(GuildId,BinMsg) end,GuildIds),
	put(guildbattleplayer,[]),
	case _BestGuild of
		[]->				
			nothing;
		{0,0}->
			nothing;
		_->
			BestGuild = _BestGuild,
			Title = language:get_string(?STR_GUILDBATTLE_KING_REWARD_MAIL_TITLE),
			Content = language:get_string(?STR_GUILDBATTLE_REWARD_MAIL_CONTENT),
			mail_to_all_online_member(system,BestGuild,Title,Content,?GUILDBATTLE_REWARD_ITEM_TEMPLATEID,1)
			%%broad_cast_to_guild_proc(BestGuild,{guildbattle_proc_msg,guildbattle_reward})
	end.
	
jszd_battle_stop()->
	put(jszd_guild,[]).

%%
%%
%%
is_in_guildbattle(GuildId)->
	lists:member(GuildId,get(guildbattleplayer)). 

leave_jszd_battle(GuildId)->%%2013.6.26[xiaowu]
	New_jszd_guild = lists:keydelete(GuildId, 1, get(jszd_guild)),
	put(jszd_guild,New_jszd_guild).

is_in_jszdbattle(GuildId)->
	lists:keymember(GuildId, 1, get(jszd_guild)).
%%
%% GuildA > GuildB
%%
compare_fun(GuildA,GuildB)->
	LevelA = get_by_guild_item(level,GuildA),
	LevelB = get_by_guild_item(level,GuildB),
	if
		LevelA =:= LevelB->						%%level
			MembersA = get_by_guild_item(members,GuildA),
			MembersB = get_by_guild_item(members,GuildB),
			MemberANum = erlang:length(MembersA),
			MemberBNum = erlang:length(MembersB),
			if 	
				MemberANum =:= MemberBNum ->	%%members
					TotalMemLevelA = guild_members_total_level(MembersA),
					TotalMemLevelB = guild_members_total_level(MembersB),
					if
						TotalMemLevelA =:= TotalMemLevelB ->
							{IdHA,IdLA} = get_by_guild_item(id,GuildA),
							{IdHB,IdLB} = get_by_guild_item(id,GuildB),
							if
								IdHA =:= IdHB ->
									IdLA < IdLB;
								true->
									IdHA < IdHB
							end;
						true->
							TotalMemLevelA > TotalMemLevelB
					end;
				true->
					MemberANum > MemberBNum
			end;
		true->
			LevelA > LevelB
	end.
	
get_bestguild()->
	country_manager:get_bestguild().
	
	
%%
%%
%%
guild_members_total_level(Members)->
	lists:foldl(fun(Memberid,LevelAcc)->
				  MemberInfo = guild_member_op:get_member_info(Memberid),
				  LevelAcc + guild_member_op:get_by_member_item(level,MemberInfo)
			end,0,Members).
			
get_guild_leader(GuildId)->
	case get_guild_info(GuildId) of
		[]->
			[];
		GuildInfo->
			Members = get_by_guild_item(members,GuildInfo),
			get_guild_leader(GuildId,Members)
	end.
	
get_guild_leader(GuildId,Members)->		
	lists:foldl(fun(MemberId,Acc)->
			case Acc of
				[]->
					MemberInfo = guild_member_op:get_member_info(MemberId),
					Posting = guild_member_op:get_by_member_item(posting,MemberInfo),
					if
						Posting =:= ?GUILD_POSE_LEADER->
							RoleId = guild_member_op:get_by_member_item(id,MemberInfo),
							RoleName = guild_member_op:get_by_member_item(name,MemberInfo),
							{RoleId,RoleName};
						true->
							Acc
					end;
				_->
					Acc
			end
		end,[],Members).
		

%%
%%return error | ok |money_not_enough
%%
check_and_cast_money(GuildId,Money,Reason)->
	case get_guild_info(GuildId) of
		[]->
			%%io:format("[] ~p ~n",[Money]),
			error;
		OldGuildInfo -> 
			case resume_guild_money(Money,OldGuildInfo,Reason) of
				[]->
					%%io:format("money_not_enough ~p ~n",[Money]),
					money_not_enough;
				GuildInfo->
					update_guild_info(GuildInfo),
					%%广播公会金钱变化
					broad_cast_guild_base_changed_to_client(GuildInfo),
					guild_spawn_db:set_guild_silver(GuildId,get_by_guild_item(silver,GuildInfo)),	
					guild_spawn_db:set_guild_gold(GuildId,get_by_guild_item(gold,GuildInfo)),
					ok
			end
	end.
	
check_and_add_money(GuildId,Money,Reason)->
	case get_guild_info(GuildId) of
		[]->
			error;
		OldGuildInfo -> 
			case add_guild_money(Money,OldGuildInfo,Reason) of
				[]->
					error;
				GuildInfo->
					update_guild_info(GuildInfo),
					%%广播公会金钱变化
					broad_cast_guild_base_changed_to_client(GuildInfo),
					guild_spawn_db:set_guild_silver(GuildId,get_by_guild_item(silver,GuildInfo)),	
					guild_spawn_db:set_guild_gold(GuildId,get_by_guild_item(gold,GuildInfo)),
					ok
			end
	end.
	
		
guild_rank_sort_loop()->
	put(guild_rank_info,[]),
	%%降序				
	SortList = lists:sort(fun(GuildIdA,GuildIdB)->
								 compare_fun(GuildIdA,GuildIdB) 
							end,ets:tab2list(guild_list)),
	SortResult = lists:foldl(fun(GuildInfo,Acc)->
									CurIndex = length(Acc),
									GuildId = get_by_guild_item(id,GuildInfo),
									[{GuildId,CurIndex+1}|Acc] 
							end,[],SortList),
	put(guild_rank_info,SortResult),
%%	io:format("result ~p ~n",[SortResult]),
	erlang:send_after(?GUILD_RANK_CHECK_TIMER*1000,self(),{guild_rank_sort_loop}).
		
change_rolename(GuildId,RoleId,NewName)->
	case guild_member_op:get_member_info(RoleId) of
		[]->
			nothing;
		MemberInfo->
			NewMemberInfo = guild_member_op:set_by_member_item(name,NewName,MemberInfo),			
			guild_member_op:add_memberbinmsg_to_ets(GuildId,RoleId),						
			guild_member_op:update_member_info(NewMemberInfo)
	end.	
	
	
get_guild_contribute_log(GuildId,RoleId)->
	case get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->
			Members = get_by_guild_item(members,GuildInfo),		
			ResultList = 
					lists:foldl(fun(MemberId,Acc)->
									MemberInfo = guild_member_op:get_member_info(MemberId),
									{TimeStamp,TodayMoney} = guild_member_op:get_by_member_item(todaymoney,MemberInfo),
									TotalMoney = guild_member_op:get_by_member_item(totalmoney,MemberInfo),
									if
										TotalMoney =:= 0->
											Acc;
										true->
											[guild_packet:make_rcs(MemberId,TodayMoney,TotalMoney)|Acc]
									end
								end,[],Members),
			Message = guild_packet:encode_guild_contribute_log_s2c(ResultList),
			role_pos_util:send_to_role_clinet(RoleId,Message)
	end.
	
	
add_impeach(GuildId,RoleId,Notice)->
	case get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->
			Members = get_by_guild_item(members,GuildInfo),
			Check = 
				lists:foldl(fun(MemberId,Acc)->
					case Acc of
						[]->
							MemberInfo = guild_member_op:get_member_info(MemberId),
							Posting = guild_member_op:get_by_member_item(posting,MemberInfo),
							if
								Posting =:= ?GUILD_POSE_LEADER->
									LeaderId = guild_member_op:get_by_member_item(id,MemberInfo),
									Online = guild_member_op:get_by_member_item(online,MemberInfo),
									if
										is_integer(Online)->
											online_error;
										true->
											TimeCheck = (timer:now_diff(now(),Online) >= ?IMPEACH_LEADER_OFFLINE_TIME),
											if
												TimeCheck->
													KingId = country_manager:get_king_roleid(),
													if
														KingId =:= LeaderId->
															king_error;
														true->
															guild_impeach:add_impeach(GuildId,RoleId,Notice)
													end;
												true->
													online_error
											end
									end;
								true->
									Acc
							end;
						_->
							Acc
					end
				end,[],Members),
			case Check of
				[]->
					nothing;
				online_error->
					ResultMsg = guild_packet:encode_guild_impeach_result_s2c(?ERRON_GUILD_IMPEACH_LEADER_OFFLINE_TOO_SHORT),
					role_pos_util:send_to_role_clinet(RoleId,ResultMsg),
					false;
				king_error->
					ResultMsg = guild_packet:encode_guild_impeach_result_s2c(?GUILD_LEADER_IS_KING),
					role_pos_util:send_to_role_clinet(RoleId,ResultMsg),
					false;
				_->
					Check	
			end
	end.
	
gm_change_someone_offline(GuildId,NewOffline,RoleId)->
	case guild_member_op:get_member_info(RoleId) of
		[]->
			nothing;
		MemberInfo->
			NewMemberInfo = guild_member_op:set_by_member_item(online,NewOffline,MemberInfo),			
			guild_member_op:add_memberbinmsg_to_ets(GuildId,RoleId),						
			guild_member_op:update_member_info(NewMemberInfo)
	end.
	
rename(GuildId,NewNameStr)->
	case get_guild_info(GuildId) of
		[]->
			false;
		GuildInfo->
			OldName = get_by_guild_item(name,GuildInfo),
			NewGuildInfo = set_by_guild_item(name,NewNameStr,GuildInfo),
			update_guild_info(NewGuildInfo),
			broad_cast_guild_base_changed_to_client(NewGuildInfo),
			guild_spawn_db:set_guild_name(GuildId,NewNameStr),
			%%send rename mail
			MailTitle = language:get_string(?STR_GUILD_RENAME_MAIL_TITLE),
			MailContextFormat = language:get_string(?STR_GUILD_RENAME_MAIL_CONTEXT),
			MailContext = util:sprintf(MailContextFormat,[OldName,NewNameStr]),
			mail_to_all_member(system,GuildId,MailTitle,MailContext),
			send_base_info_update_to_all(GuildId),
			country_manager:change_guild_name(GuildId,NewNameStr),
			guildbattle_manager:change_guild_name(GuildId,NewNameStr),
			true	
	end.
	
				 								 					
%%---------------------------------------------------------------------------
%%							通知客户端
%%---------------------------------------------------------------------------	
%%silver,gold,notice
broad_cast_guild_base_changed_to_client(NewGuildInfo)->
	GuildId = get_by_guild_item(id,NewGuildInfo),			
	%%广播给client:不需要广播给role进程
	Message = guild_packet:encode_guild_base_update_s2c(
					get_by_guild_item(name,NewGuildInfo),
					get_by_guild_item(level,NewGuildInfo),
					get_by_guild_item(silver,NewGuildInfo),
					get_by_guild_item(gold,NewGuildInfo),
					get_by_guild_item(notice,NewGuildInfo),
					get_by_guild_item(chatgroup,NewGuildInfo),
					get_by_guild_item(voicegroup,NewGuildInfo)),					
	broad_cast_to_guild_client(GuildId,Message ).
	
broad_cast_to_guild_client(GuildId,Message)->
	case get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->
			Members = get_by_guild_item(members,GuildInfo),
			lists:foreach(fun(Memberid)->
							MemberInfo = guild_member_op:get_member_info(Memberid),
							RoleId = guild_member_op:get_by_member_item(id,MemberInfo),
							Online = guild_member_op:get_by_member_item(online,MemberInfo),
							if
								is_integer(Online)-> 
									role_pos_util:send_to_role_clinet(RoleId,Message);
								true->
									nothing
							end
					end,Members)						
	end.

broad_cast_to_guild_role(GuildId,Message)->
	case get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->
			Members = get_by_guild_item(members,GuildInfo),
			lists:foreach(fun(Memberid)->
							MemberInfo = guild_member_op:get_member_info(Memberid),
							RoleId = guild_member_op:get_by_member_item(id,MemberInfo),
							Online = guild_member_op:get_by_member_item(online,MemberInfo),
							if
								is_integer(Online)-> 
									role_pos_util:send_to_role(RoleId,Message);
								true->
									nothing
							end
					end,Members)						
	end.

send_guild_info_to_client(Roleid,GuildId)->
	GuildInfo = get_guild_info(GuildId),
	try 
	MemberLists = get_by_guild_item(members,GuildInfo),
	SendMembers = lists:map(fun(Memberid)->
						MemberInfo = guild_member_op:get_member_info(Memberid),
						guild_packet:make_roleinfo(MemberInfo)											
						end ,MemberLists),
	SendFacilitys = lists:map(fun(FacId)->
								FacInfo = guild_facility_op:get_facility_info(GuildId,FacId),
								guild_packet:make_facilityinfo({
									FacId,
									guild_facility_op:get_by_facility_item(level,FacInfo),
									guild_facility_op:get_by_facility_item(upgradetime,FacInfo),
									guild_facility_op:get_by_facility_item(fulltime,FacInfo),
									guild_facility_op:get_by_facility_item(restrict,FacInfo),
									guild_facility_op:get_by_facility_item(contribution,FacInfo)
									})		
	 						end,[1,2,4]),
	Message = guild_packet:encode_guild_info_s2c(get_by_guild_item(name,GuildInfo), 											 
											get_by_guild_item(level,GuildInfo),
											get_by_guild_item(silver,GuildInfo),
											get_by_guild_item(gold,GuildInfo),
											get_by_guild_item(notice,GuildInfo),
											SendMembers,
											SendFacilitys,												 
											get_by_guild_item(chatgroup,GuildInfo),											 
											get_by_guild_item(voicegroup,GuildInfo)),
	role_pos_util:send_to_role_clinet(Roleid,Message)
	catch
	E:R->slogger:msg("send_guild_info_to_client error ~p ~p ~n",[E,R])
	end.	

%%给领导发消息(帮主，长老)
send_message_to_leaders(GuildId,Message)->
	case get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->
			Members = get_by_guild_item(members,GuildInfo),
			lists:foreach(fun(Memberid)->
							MemberInfo = guild_member_op:get_member_info(Memberid),
							RoleId = guild_member_op:get_by_member_item(id,MemberInfo),
							Online = guild_member_op:get_by_member_item(online,MemberInfo),
							Posting = guild_member_op:get_by_member_item(posting,MemberInfo),
							CheckPosting = ((Posting =:= ?GUILD_POSE_LEADER)or(Posting =:= ?GUILD_POSE_MASTER)or(Posting =:= ?GUILD_POSE_VICE_LEADER)), 
							if
								is_integer(Online),CheckPosting-> 
									role_pos_util:send_to_role_clinet(RoleId,Message);
								true->
									nothing
							end
					end,Members)						
	end.								
											 							
%%---------------------------------------------------------------------------
%%							通知role进程
%%---------------------------------------------------------------------------
broad_cast_to_guild_proc(GuildId,Message)->
	case get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->
			Members = get_by_guild_item(members,GuildInfo),
			lists:foreach(fun(Memberid)->
							MemberInfo = guild_member_op:get_member_info(Memberid), 
							RoleId = guild_member_op:get_by_member_item(id,MemberInfo),
							role_pos_util:send_to_role(RoleId,Message)
					end,Members)						
	end.
	
%%基础信息变化,发送除memberlist和facilitylist以外的信息
send_base_info_update(Roleid,GuildId)->
	FullInfo = get_guild_info(GuildId),	
	GuildId = get_by_guild_item(id,FullInfo),
	GuildName = get_by_guild_item(name,FullInfo),
	GuildLevel= get_by_guild_item(level,FullInfo),
	case guild_member_op:get_member_info(Roleid) of
		[] ->
			slogger:msg("send_update_guild_info lists:keyfind false ~p~n",[Roleid]);
		MemberInfo->
			Posting = guild_member_op:get_by_member_item(posting,MemberInfo),
			Contribution = guild_member_op:get_by_member_item(contribution,MemberInfo),	
			TContribution = guild_member_op:get_by_member_item(totlecontribution,MemberInfo),	
			Message = {guildmanager_msg,{update_guild_base_info,{GuildId,GuildName,GuildLevel,Posting,Contribution,TContribution}}},
			role_pos_util:send_to_role(Roleid,Message)
	end.
	
send_base_info_update_to_all(GuildId)->
	FullInfo = get_guild_info(GuildId),	
	GuildId = get_by_guild_item(id,FullInfo),
	GuildName = get_by_guild_item(name,FullInfo),
	GuildLevel= get_by_guild_item(level,FullInfo),
	MemberIds = get_by_guild_item(members,FullInfo),
	lists:foreach(fun(RoleId)->
			case guild_member_op:get_member_info(RoleId) of
				[] ->
					nothing;
				MemberInfo->
					Posting = guild_member_op:get_by_member_item(posting,MemberInfo),
					Contribution = guild_member_op:get_by_member_item(contribution,MemberInfo),
					TContribution = guild_member_op:get_by_member_item(totlecontribution,MemberInfo),%%wb20130622解决更名掉线
					Message = {guildmanager_msg,{update_guild_base_info,{GuildId,GuildName,GuildLevel,Posting,Contribution,TContribution}}},
					role_pos_util:send_to_role(RoleId,Message)
			end
		end,MemberIds).

send_to_role_delete_item(ItemInfo,Count,RoleId)->
	Message={guild_role_package_update,ItemInfo,Count},
	role_pos_util:send_to_role(RoleId,{role_packet,Message}).
			
%%---------------------------------------------------------------------------
%%						data struct
%%--------------------------------------------------------------------------- 
get_by_guild_item(Item,{Id,Name,Level,Silver,Gold,Notice,MemberLists,CreateDate,ChatGroup,VoiceGroup,LastActiveTime,SendWarningMail})->
	case Item of
		id->
			Id;
		name->
			Name;
		level->
			Level;
		silver->
			Silver;
		gold->
			Gold;
		notice->
			Notice;
		members->
			MemberLists;
		createdate->
			CreateDate;
		chatgroup->
			ChatGroup;
		voicegroup->
			VoiceGroup;
		lastactivetime->
			LastActiveTime;
		sendwarningmail->
			SendWarningMail
	end.

set_by_guild_item(Item,Value,{Id,Name,Level,Silver,Gold,Notice,MemberLists,CreateDate,ChatGroup,VoiceGroup,LastActiveTime,SendWarningMail})->
	case Item of
		id->
			{Value,Name,Level,Silver,Gold,Notice,MemberLists,CreateDate,ChatGroup,VoiceGroup,LastActiveTime,SendWarningMail};
		name->
			{Id,Value,Level,Silver,Gold,Notice,MemberLists,CreateDate,ChatGroup,VoiceGroup,LastActiveTime,SendWarningMail};
		level->
			{Id,Name,Value,Silver,Gold,Notice,MemberLists,CreateDate,ChatGroup,VoiceGroup,LastActiveTime,SendWarningMail};
		silver->
			{Id,Name,Level,Value,Gold,Notice,MemberLists,CreateDate,ChatGroup,VoiceGroup,LastActiveTime,SendWarningMail};
		gold->
			{Id,Name,Level,Silver,Value,Notice,MemberLists,CreateDate,ChatGroup,VoiceGroup,LastActiveTime,SendWarningMail};
		notice->
			{Id,Name,Level,Silver,Gold,Value,MemberLists,CreateDate,ChatGroup,VoiceGroup,LastActiveTime,SendWarningMail};
		members->
			{Id,Name,Level,Silver,Gold,Notice,Value,CreateDate,ChatGroup,VoiceGroup,LastActiveTime,SendWarningMail};
		createdate->
			{Id,Name,Level,Silver,Gold,Notice,MemberLists,Value,ChatGroup,VoiceGroup,LastActiveTime,SendWarningMail};
		chatgroup->
			{Id,Name,Level,Silver,Gold,Notice,MemberLists,CreateDate,Value,VoiceGroup,LastActiveTime,SendWarningMail};
		voicegroup->
			{Id,Name,Level,Silver,Gold,Notice,MemberLists,CreateDate,ChatGroup,Value,LastActiveTime,SendWarningMail};
		lastactivetime->
			{Id,Name,Level,Silver,Gold,Notice,MemberLists,CreateDate,ChatGroup,VoiceGroup,Value,SendWarningMail};
		sendwarningmail->
			{Id,Name,Level,Silver,Gold,Notice,MemberLists,CreateDate,ChatGroup,VoiceGroup,LastActiveTime,Value}
	end.
	
guild_disband_warning_mail(GuildId,Today)->
	Title = language:get_string(?STR_GUILD_MAIL_TITLE),
	{Y,M,D} = Today,
	ContextFormat = language:get_string(?STR_GUILD_MAIL_CONTEXT),
	Context = util:sprintf(ContextFormat,[?GUILD_DISBAND_WARNING_TIME,?GUILD_MIN_ONLINE_MEMBER,?GUILD_DISBAND_TIME,?GUILD_MIN_ONLINE_MEMBER,Y,M,D]),
%%	io:format("Title ~p ~nContextFormat ~p ~n Context ~p ~n",[Title,ContextFormat,Context]),
	mail_to_all_member(system,GuildId,Title,Context).	

%%
%%向帮会的全体成员发送邮件
%%
mail_to_all_member(system,GuildId,Title,Context)->
	case get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->
			Members = get_by_guild_item(members,GuildInfo),
			SignName = language:get_string(?STR_GUILD_MAIL_SIGN),
			lists:foreach(fun(RoleId)->
					case guild_member_op:get_member_name(RoleId) of
						error->
							nothing;
						RoleName->
							Ret = gm_op:gm_send_rpc(SignName,RoleName,Title,Context,0,0,0)
					end						
				end,Members)
	end.

mail_to_all_online_member(system,GuildId,Title,Context,ItemProto,ItemCount)->
	case get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->
			Members = get_by_guild_item(members,GuildInfo),
			SignName = language:get_string(?STR_SYSTEM),
			lists:foreach(fun(RoleId)->
								case guild_member_op:get_member_info(RoleId) of
									[]->
										nothing;
									MemberInfo->
										IsOnline = guild_member_op:get_by_member_item(online,MemberInfo),
										if
											is_integer(IsOnline)->
												RoleName = guild_member_op:get_by_member_item(name,MemberInfo),
												rpc:call(node_util:get_mapnode(),gm_op,gm_send_rpc,[SignName,RoleName,Title,Context,ItemProto,ItemCount,0]);
											true->
												nothing
										end
								end		
							end,Members)
	end.

unique_name(GuildName)->
	case ets:match_object(guild_list,{'_',GuildName,'_','_','_','_','_','_','_','_','_','_'}) of
		[]->
			true;
		_->
			false
	end.

get_filter_string(InputString)->
	try
		senswords:replace_sensitive(list_to_binary(InputString))
	catch
		E:R ->slogger:msg("~p get_filter_msg excption:(~p:~p)~n",[?MODULE,E,R]),
			InputString
	end.



sent_memberbinmsg_to_client()->
	case ets:first(guild_member_binmsg) of
		'$end_of_table' ->
				%io:format("sent_memberbinmsg_to_client end_of_table ~n",[]),
				nothing;
		{error, _}->
				%io:format("sent_memberbinmsg_to_client error ~n"),
				nothing;
		FirstKey->
				{GH,GL,MemberId} = FirstKey,
				%%io:format("get_member_info MemberId ~p ~n",[MemberId]),
				case guild_member_op:get_member_info(MemberId) of
					[]->
						%%io:format("get_member_info [] ~n"),
						nothing;
					MemberInfo->
						MessageMember = guild_packet:encode_guild_member_update_s2c(guild_packet:make_roleinfo(MemberInfo)),
						broad_cast_to_guild_client({GH,GL},MessageMember)
				end,
				sent_memberbinmsg_to_client_step(FirstKey)
	end,
	ets:delete_all_objects(guild_member_binmsg).

sent_memberbinmsg_to_client_step(PreKey)->
	case ets:next(guild_member_binmsg,PreKey) of
		'$end_of_table' ->
				nothing;
		{error, _}->
				nothing;
		NextKey->
				{GH,GL,MemberId} = NextKey,
				case guild_member_op:get_member_info(MemberId) of
					[]->
						nothing;
					MemberInfo->
						MessageMember = guild_packet:encode_guild_member_update_s2c(guild_packet:make_roleinfo(MemberInfo)),
						broad_cast_to_guild_client({GH,GL},MessageMember)
				end,
				sent_memberbinmsg_to_client_step(NextKey)
	end.	

%%---------------------------------------------------------------------------------------------------
%%											guild_treasure_transport
%%---------------------------------------------------------------------------------------------------

%%
%%return:true/false
%%
check_is_guild_transport(GuildId)->
	case get_guild_treasure_transport_start_time(GuildId) of
		[]->
			false;
		Treasure_Transport_Start_Time ->
			case check_is_overdue(now(),Treasure_Transport_Start_Time) of
				true->
					false;
				false->
					true
			end
	end.

start_guild_treasure_transport(RoleId,GuildId)->
	case get_guild_treasure_transport_start_time(GuildId) of
		[]->
			Result = ?ERRNO_GUILD_TREASURE_TRANSPORT_ALREADY_START;
		Treasure_Transport_Start_Time ->
			Now = now(),
			case timer_util:check_same_day(Now,Treasure_Transport_Start_Time) of
				true->
					Result = ?ERRNO_GUILD_TREASURE_TRANSPORT_TIME_LIMIT;
				false->
					GuildInfo = get_guild_info(GuildId),
					GuildLevel = get_by_guild_item(level,GuildInfo),
					GuildSilver = get_by_guild_item(silver,GuildInfo),
					ConsumeInfo = guild_treasure_transport_db:get_guild_treasure_transport_consume_info(GuildLevel),
					ConsumeSilver = guild_treasure_transport_db:get_guild_treasure_transport_consume(ConsumeInfo),
					if ConsumeSilver =< GuildSilver -> 
							ConsumeMoneyList = [{?MONEY_BOUND_SILVER,ConsumeSilver}],
							case resume_guild_money(ConsumeMoneyList,GuildInfo,guild_treasure_transport) of
								[]->Result = ?GUILD_ERRNO_MONEY_NOT_ENOUGH;
								NewGuildInfo->
									Result = [],
									update_guild_info(NewGuildInfo),
									%%广播公会金钱变化
									broad_cast_guild_base_changed_to_client(NewGuildInfo),
									guild_spawn_db:set_guild_silver(GuildId,get_by_guild_item(silver,NewGuildInfo)),	
									guild_spawn_db:set_guild_gold(GuildId,get_by_guild_item(gold,NewGuildInfo))									
							end,
							update_guild_treature_transport({GuildId,Now}),
							guild_spawn_db:set_guild_treasure_transport(GuildId,Now),
							Message = treasure_transport_packet:encode_guild_transport_left_time_s2c(?TWO_HOUR),
							broad_cast_to_guild_client(GuildId,Message);
						true->
							Result=?GUILD_ERRNO_MONEY_NOT_ENOUGH
					end
			end
	end.
	
	%Msg = treasure_transport_packet:encode_start_guild_transport_failed_s2c(Result),
	%role_pos_util:send_to_role_clinet(RoleId, Msg).

treasure_transport_call_guild_help(GuildId,RoleId,GuildPosting,RoleName,LineId,MapId,RolePos)->
	GuildInfo = get_guild_info(GuildId),
	Members = get_by_guild_item(members,GuildInfo),
	send_to_all_whitout_self(Members,RoleId,{guildmanager_msg,{guild_mastercall,{GuildId,GuildPosting,RoleName,LineId,MapId,RolePos,?REASON_TREASURE_TRANSPORT}}}).

check_is_overdue(NowTime,Treasure_Transport_Start_Time)->
	LeftTime = trunc(timer:now_diff(NowTime,Treasure_Transport_Start_Time)/1000000),
	if LeftTime < ?TWO_HOUR ->
		   false;
	   true ->
		   true
	end.	
	
send_to_all_whitout_self(Members,MyRoleId,Message)->	
	lists:foreach(fun(Memberid)->
			MemberInfo = guild_member_op:get_member_info(Memberid),
			RoleId = guild_member_op:get_by_member_item(id,MemberInfo),
			Online = guild_member_op:get_by_member_item(online,MemberInfo),
			if MyRoleId =:= RoleId ->
					nothing;
				true->
					if
						is_integer(Online)-> 
							role_pos_util:send_to_role(RoleId,Message);
						true->
							nothing
					end
			end
	end,Members).
	
get_member_totle_contribution(RoleId)->
	MemberInfo = guild_member_op:get_member_info(RoleId),
	guild_member_op:get_by_member_item(totlecontribution,MemberInfo).	
	
send_to_all_client(GuildId,Message)->
	GuildInfo = get_guild_info(GuildId),
	Members = get_by_guild_item(members,GuildInfo),
	lists:foreach(fun(Memberid)->
			MemberInfo = guild_member_op:get_member_info(Memberid),
			RoleId = guild_member_op:get_by_member_item(id,MemberInfo),
			Online = guild_member_op:get_by_member_item(online,MemberInfo),
			if
				is_integer(Online)-> 
					role_pos_util:send_to_role_clinet(RoleId, Message);
				true->
					nothing
			end
	end,Members).
	
send_to_all_role(GuildId,Message)->
	GuildInfo = get_guild_info(GuildId),
	Members = get_by_guild_item(members,GuildInfo),
	lists:foreach(fun(Memberid)->
			MemberInfo = guild_member_op:get_member_info(Memberid),
			RoleId = guild_member_op:get_by_member_item(id,MemberInfo),
			Online = guild_member_op:get_by_member_item(online,MemberInfo),
			if
				is_integer(Online)-> 
					role_pos_util:send_to_role(RoleId, Message);
				true->
					nothing
			end
	end,Members).
	
%%battle ground
notify_yhzq_start(GuildId,Camp,Node,ProcName,MapProc)->
	put(yhzq_fight_guild,[{GuildId,Camp,Node,ProcName,MapProc}|get(yhzq_fight_guild)]),
	send_to_all_role(GuildId,{notify_to_join_yhzq,Camp,Node,ProcName,MapProc}).
	
notify_yhzq_end(GuildId)->
	put(yhzq_fight_guild,lists:keydelete(GuildId,1,get(yhzq_fight_guild))).

%%	
%% GBScore = guild battle score
%%
add_guild_battle_score(GuildId,GbScore,Battle)->
	case guild_spawn_db:get_guild_battle_score_info(GuildId) of
		[]->
			guild_spawn_db:add_guild_battle_score_info(GuildId,[{Battle,GbScore}],GbScore,[{Battle,1,0}]);
		{_,_,Score,TScore,WinInfo}->
			case lists:keyfind(Battle,1,WinInfo) of
				false->
					case lists:keyfind(Battle,1,Score) of
						false->
							guild_spawn_db:add_guild_battle_score_info(GuildId,[{Battle,GbScore}|Score],GbScore+TScore,[{Battle,1,0}|WinInfo]);
						{_,OldScore}->
							guild_spawn_db:add_guild_battle_score_info(GuildId,lists:keyreplace(Battle,1,Score,{Battle,OldScore+GbScore}),GbScore+TScore,[{Battle,1,0}|WinInfo])
					end;
				{_,Win,Lose}->
					case lists:keyfind(Battle,1,Score) of
						false->
							guild_spawn_db:add_guild_battle_score_info(GuildId,[{Battle,GbScore}|Score],GbScore+TScore,lists:keyreplace(Battle,1,WinInfo,{Battle,Win + 1,Lose}));
						{_,OldScore}->
							guild_spawn_db:add_guild_battle_score_info(GuildId,lists:keyreplace(Battle,1,Score,{Battle,OldScore+GbScore}),GbScore+TScore,lists:keyreplace(Battle,1,WinInfo,{Battle,Win + 1,Lose}))
					end
			end
	end,
	sort_guild_battle_score(Battle),
	sort_guild_score(),
	gm_logger_guild:guild_add_battle_score(GuildId,GbScore,Battle).
	
sort_guild_battle_score(Battle)->
	AllGuild = guild_spawn_db:get_all_guild_battle_score(),
	RightGuild = lists:foldl(fun({_,GuildId,Score,_,WinInfo},Acc)->
							case lists:keyfind(Battle,1,Score) of
								false->
									Acc;
								{_,GScore}->
									[{GuildId,GScore,WinInfo}|Acc]
							end
						end,[],AllGuild),
	GuildList = lists:sort(fun({GuildA,ScoreA,_},{GuildB,ScoreB,_})->
					if ScoreA > ScoreB ->
							true;
						ScoreA =:= ScoreB->
							case lists:keyfind(GuildA,1,get(guild_rank_info)) of
								false->
									false;
								{_,RankA}->
									case lists:keyfind(GuildB,1,get(guild_rank_info)) of
										false->
											true;
										{_,RankB}->
											if
												RankA =< RankB ->
													true;
												true->
													false
											end
									end
							end;
						true->
							false
					end
				end,RightGuild),
	SortResult = lists:foldl(fun({GuildId,Score,WinInfo},Acc)->
									CurIndex = length(Acc),
									case get_guild_info(GuildId) of
										[]->
											Acc;
										GuildInfo ->
											GuildName = get_by_guild_item(name,GuildInfo),
											[{GuildId,CurIndex+1,GuildName,Score,WinInfo}|Acc]
									end
							end,[],GuildList),
	put({guild_score_rank_info,Battle},SortResult).

notify_guild_lose_battle(GuildId,GbScore,Battle)->
	case guild_spawn_db:get_guild_battle_score_info(GuildId) of
		[]->
			guild_spawn_db:add_guild_battle_score_info(GuildId,[{Battle,GbScore}],GbScore,[{Battle,0,1}]);
		{_,_,Score,TScore,WinInfo}->
			case lists:keyfind(Battle,1,WinInfo) of
				false->
					case lists:keyfind(Battle,1,Score) of
						false->
							guild_spawn_db:add_guild_battle_score_info(GuildId,[{Battle,GbScore}|Score],GbScore+TScore,[{Battle,0,1}|WinInfo]);
						{_,OldScore}->
							guild_spawn_db:add_guild_battle_score_info(GuildId,lists:keyreplace(Battle,1,Score,{Battle,OldScore+GbScore}),GbScore+TScore,[{Battle,0,1}|WinInfo])
					end;
				{_,Win,Lose}->
					case lists:keyfind(Battle,1,Score) of
						false->
							guild_spawn_db:add_guild_battle_score_info(GuildId,[{Battle,GbScore}|Score],GbScore+TScore,lists:keyreplace(Battle,1,WinInfo,{Battle,Win,Lose + 1}));
						{_,OldScore}->
							guild_spawn_db:add_guild_battle_score_info(GuildId,lists:keyreplace(Battle,1,Score,{Battle,OldScore+GbScore}),GbScore+TScore,lists:keyreplace(Battle,1,WinInfo,{Battle,Win,Lose + 1}))
					end
			end
	end,
	sort_guild_battle_score(Battle),
	sort_guild_score(),
	gm_logger_guild:guild_add_battle_score(GuildId,GbScore,Battle).
	
sort_guild_score()->
	AllGuild = guild_spawn_db:get_all_guild_battle_score(),
	GuildList = lists:sort(fun({_,GuildA,_,ScoreA,_},{_,GuildB,_,ScoreB,_})->
					if ScoreA > ScoreB ->
							true;
						ScoreA =:= ScoreB->
							case lists:keyfind(GuildA,1,get(guild_rank_info)) of
								false->
									false;
								{_,RankA}->
									case lists:keyfind(GuildB,1,get(guild_rank_info)) of
										false->
											true;
										{_,RankB}->
											if
												RankA =< RankB ->
													true;
												true->
													false
											end
									end
							end;
						true->
							false
					end
				end,AllGuild),
	SortResult = lists:foldl(fun({_,GuildId,Score,TScore,WinInfo},Acc)->
									case get_guild_info(GuildId) of
										[]->
											Acc;
										GuildInfo->
											CurIndex = length(Acc),
											GuildInfo = get_guild_info(GuildId),
											GuildName = get_by_guild_item(name,GuildInfo),
											[{GuildId,CurIndex+1,GuildName,Score,TScore,WinInfo}|Acc] 
									end
							end,[],GuildList),
	put({guild_score_rank_info,all},SortResult).
			
get_guild_battle_wininfo(Battle)->
	case get({guild_score_rank_info,Battle}) of
		undefined->
			[];
		Info->
			Info
	end.	
	
change_guild_battle_limit(GuildId,BattleLimit)->
	case guild_spawn_db:get_guild_right_limit_from_ets(GuildId) of
		[]->
			ignor;
		{_,SmithLimit,_}->
			guild_spawn_db:set_guild_right_limit_to_ets({GuildId,SmithLimit,BattleLimit}),
			guild_spawn_db:set_guild_right_limit(GuildId,SmithLimit,BattleLimit),
			Message = guild_packet:encode_change_guild_right_limit_s2c(SmithLimit,BattleLimit),
			guild_manager_op:send_to_all_client(GuildId,Message)
	end.	
	
delete_guild_score(GuildId)->
	Func = fun(Battle)->
				case lists:keyfind(GuildId,1,get({guild_score_rank_info,Battle})) of
					false->
						ignor;
					_->
						put({guild_score_rank_info,Battle},lists:keydelete(GuildId,1,get({guild_score_rank_info,Battle})))
				end
			end,
	lists:foreach(Func,[all,yhzq,jszd]),
	guild_spawn_db:delete_guild_score(GuildId).
	
gm_add_guild_score(GuildId,Value)->	
	add_guild_battle_score(GuildId,Value,yhzq).
	
init_guild_score_rank()->
	sort_guild_score(),
	sort_guild_battle_score(jszd),
	sort_guild_battle_score(yhzq).
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
