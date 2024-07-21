%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-4
%% Description: TODO: Add description to guild_facility_op
-module(guild_facility_op).

%%
%% Include files
%%
-include("guild_define.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-compile(export_all). 

%%
%% API Functions
%%
init()->
	ets:new(guild_right_limit_ets,[set,protected,named_table]),
	ets:new(facility_list, [set, protected, named_table]).

%% ===========================================================
%% opt data
%% ===========================================================
get_facility_info(GuildId,Facility)->
	case ets:lookup(facility_list, {GuildId,Facility}) of
		[]-> [];
		[FacInfo]->FacInfo
	end.

update_facility_info(FacilityInfo)->
	ets:insert(facility_list,FacilityInfo).

set_smith_need_contribution(GuildId,NewContribution)->
	case guild_spawn_db:get_guild_right_limit_from_ets(GuildId) of
		[]->
			ignor;
		{_,_,BattleLimit}->
			guild_spawn_db:set_guild_right_limit_to_ets({GuildId,NewContribution,BattleLimit}),
			guild_spawn_db:set_guild_right_limit(GuildId,NewContribution,BattleLimit),
			Message = guild_packet:encode_change_guild_right_limit_s2c(NewContribution,BattleLimit),
			guild_manager_op:send_to_all_client(GuildId,Message)
	end.

delete_guild_facilityid(GuildId)->
	FacList = [
				?GUILD_FACILITY,
				?GUILD_FACILITY_TREASURE,
				?GUILD_FACILITY_SMITH
				],
	lists:foreach(fun(Facilityid)->
				ets:delete(log_list,{GuildId,Facilityid})
			end,FacList).
%% ===========================================================
%% opt data
%% ===========================================================
create_guild_to_list(GuildInfo)->%%12æœˆ21æ—¥ä¿®æ”¹[xiaowu]
	guild_manager_op:update_guild_info(GuildInfo),
	GuildId = guild_manager_op:get_by_guild_item(id,GuildInfo),
	GuildLevel = guild_manager_op:get_by_guild_item(level,GuildInfo),%%12æœˆ21æ—¥åŠ [xiaowu]
	update_facility_info({{GuildId,?GUILD_FACILITY},GuildLevel,0,0,0,0}),%%12æœˆ21æ—¥ä¿®æ”¹[xiaowu]
	update_facility_info({{GuildId,?GUILD_FACILITY_SMITH},0,0,0,0,0}),
	update_facility_info({{GuildId,?GUILD_FACILITY_TREASURE},0,0,0,0,0}),
	guild_manager_op:update_quest_record({GuildId,{0,0,0},0}).

proc_facility_update(Type,GuildId,Facilityid,Value)->
	FacilityInfo = get_facility_info(GuildId,Facilityid),
	if 
		FacilityInfo =/= [] ->
			NewFainfo = guild_facility_op:set_by_facility_item(Type,Value,FacilityInfo),	
			update_facility_info(NewFainfo),
			guild_facility_op:change_facility_info(NewFainfo);
		true->
			nothing
	end.

proc_upgrade(GuildId,RoleId,FacilityId)->	
	OldGuildInfo = guild_manager_op:get_guild_info(GuildId),
	FacilityInfo = get_facility_info(GuildId,FacilityId),
	Level = get_by_facility_item(level,FacilityInfo),
	ProtoInfo = guild_proto_db:get_facility_info(FacilityId,Level+1),
	MemberInfo = guild_member_op:get_member_info(RoleId),	
	MemberPosting = guild_member_op:get_by_member_item(posting,MemberInfo),
	{RequiredMoneyList,_} = guild_proto_db:get_facility_require_resource(ProtoInfo),
	case guild_manager_op:resume_guild_money(RequiredMoneyList,OldGuildInfo,facility_upgrade) of
		[]->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_MONEY_NOT_ENOUGH),
			role_pos_util:send_to_role_clinet(RoleId,ErrnoMsg );
		GuildInfo->
			guild_manager_op:update_guild_info(GuildInfo),
			guild_manager_op:broad_cast_guild_base_changed_to_client(GuildInfo),
			guild_spawn_db:set_guild_silver(GuildId,guild_manager_op:get_by_guild_item(silver,GuildInfo)),	
			guild_spawn_db:set_guild_gold(GuildId,guild_manager_op:get_by_guild_item(gold,GuildInfo)),
			UpdateInfo = guild_proto_db:get_facility_info(FacilityId,Level+1),
			NeedTime = guild_proto_db:get_facility_require_time(UpdateInfo),
			UpgradeTime = now(),
			InFo1 = set_by_facility_item(upgradetime,UpgradeTime,FacilityInfo),	
			InFo2 = set_by_facility_item(fulltime,NeedTime,InFo1),	
			update_facility_info(InFo2),
			change_facility_info(InFo2),
			gm_logger_guild:guild_facility_begin_level_up(GuildId,FacilityId,Level,RoleId,MemberPosting)
	end.

proc_upgrade_speedup(GuildId,RoleId,FacilityId,SpeedType,SpeedValue,{ItemName,AddContribution})->
	FacilityInfo = get_facility_info(GuildId,FacilityId),
	FullTime = get_by_facility_item(fulltime,FacilityInfo),
	StartTime = get_by_facility_item(upgradetime,FacilityInfo),	
	MemberInfo = guild_member_op:get_member_info(RoleId),	
	MemberPosting = guild_member_op:get_by_member_item(posting,MemberInfo),		
	Left = erlang:trunc(FullTime - timer:now_diff(now(),StartTime)/(1000*1000)),	
	LeftTime  = erlang:max(Left,0), 						 	
	if
		SpeedType =:= reduce_time->
			NewFullTime = erlang:max(FullTime - SpeedValue,0);
		SpeedType =:= reduce_timerate->
			NewFullTime = FullTime - erlang:trunc(LeftTime*SpeedValue/100)
	end,
	SpeedUpTime_s = erlang:max(FullTime - NewFullTime,0),
	MemberName = guild_member_op:get_member_name(RoleId),
	
	LogInfo = {item,MemberName,MemberPosting,1,ItemName,FacilityId,SpeedUpTime_s},
	guild_manager_op:add_log(GuildId,?GUILD_LOG_CONTRIBUTION,LogInfo),
	if	
		AddContribution	> 0 ->
			NewContribution = guild_member_op:get_by_member_item(contribution,MemberInfo)+AddContribution,
			NewTContribution = guild_member_op:get_by_member_item(totlecontribution,MemberInfo)+AddContribution,
			NewMemberInfo = guild_member_op:set_by_member_item(contribution,NewContribution,MemberInfo),
			NewMemberInfo1 = guild_member_op:set_by_member_item(totlecontribution,NewTContribution,NewMemberInfo),
			guild_member_op:update_member_info(NewMemberInfo1),		
			guild_spawn_db:set_member_contribution(RoleId,NewContribution),
			guild_spawn_db:set_member_tcontribution(RoleId,NewTContribution),
			guild_manager_op:send_base_info_update(RoleId,GuildId),
			guild_member_op:add_memberbinmsg_to_ets(GuildId,RoleId),	
			gm_logger_role:role_guild_contribution_change(RoleId,GuildId,AddContribution,guild_upgrade_speedup);	
		true->
			nothing
	end,
	NewInfo = guild_facility_op:set_by_facility_item(fulltime,NewFullTime,FacilityInfo),
	update_facility_info(NewInfo),
	change_facility_info(NewInfo),
	gm_logger_guild:guild_facility_speed(GuildId,FacilityId,RoleId,MemberPosting,SpeedType,LeftTime,erlang:max(LeftTime - SpeedValue,0)),
	ok.	

is_upgrade_time_over(StartTime,FullTime,Now)->
	LeftTime = FullTime - timer:now_diff(Now,StartTime)/(1000*1000),
	if 
		LeftTime =< 0->			
			true;
		true->
			false
	end.

proc_upgrade_timer()->
	Now = now(),
	ets:foldl(fun(FacInfo,_)->
			{GuildId,Facid} = guild_facility_op:get_by_facility_item(id,FacInfo),		
			Level = guild_facility_op:get_by_facility_item(level,FacInfo),
			StartTime = guild_facility_op:get_by_facility_item(upgradetime,FacInfo),
			FullTime = guild_facility_op:get_by_facility_item(fulltime,FacInfo),					
			if 	
				StartTime =/= 0->			
					case is_upgrade_time_over(StartTime,FullTime,Now) of
						true->				
							FacInfo1 = guild_facility_op:set_by_facility_item(upgradetime,0,FacInfo),
							FacInfo2 = guild_facility_op:set_by_facility_item(fulltime,0,FacInfo1),
							FacInfo3 = guild_facility_op:set_by_facility_item(level,Level + 1,FacInfo2 ),
							if
								Facid =:= ?GUILD_FACILITY->		
									NewGuildInfo = guild_manager_op:set_by_guild_item(level,Level+1,guild_manager_op:get_guild_info(GuildId)),
									guild_manager_op:update_guild_info(NewGuildInfo),																	
									guild_spawn_db:set_guild_level(GuildId,Level+1);
								true->
									nothing
							end,	
							guild_facility_op:update_facility_info(FacInfo3),
							guild_facility_op:change_facility_info(FacInfo3),
							gm_logger_guild:guild_facility_finish_level_up(GuildId,Facid,Level + 1),
							LogInfo = {Facid,Level + 1},
							guild_manager_op:add_log(GuildId,?GUILD_LOG_UPGRADE,LogInfo);			
						false->							
							nothing
					end;
				true->
					nothing
			end,
			guild_manager_op:check_active_day(GuildId,Now),
			guild_manager_op:update_quest_lefttime(GuildId,Now)
		end,[],facility_list),
	guild_manager_op:check_money_log(Now),	
	guild_impeach:check_result(Now),
	erlang:send_after(?GUILD_FACILITY_TIMER,self(),{upgrade_timer}).

get_by_facility_item_xiaowu(Item,{f,Facilityid,FaLevel,Upgrade_Start_Time,Fulltime,Restrict,Contribution,_})->
	case Item of
		id->
			Facilityid;
		level->
			FaLevel;
		upgradetime->
			Upgrade_Start_Time;
		fulltime->
			Fulltime;
		restrict->	
			Restrict;
		contribution->
			Contribution
	end.

get_by_facility_item(Item,{Facilityid,FaLevel,Upgrade_Start_Time,Fulltime,Restrict,Contribution})->
	case Item of
		id->
			Facilityid;
		level->
			FaLevel;
		upgradetime->
			Upgrade_Start_Time;
		fulltime->
			Fulltime;
		restrict->	
			Restrict;
		contribution->
			Contribution
	end.

set_by_facility_item(Item,Value,{Facilityid,FaLevel,Upgrade_Start_Time,Upgrade_Left_Time,Restrict,Contribution})->
	case Item of
		id->
			{Value,FaLevel,Upgrade_Start_Time,Upgrade_Left_Time,Restrict,Contribution};
		level->
			{Facilityid,Value,Upgrade_Start_Time,Upgrade_Left_Time,Restrict,Contribution};
		upgradetime->
			{Facilityid,FaLevel,Value,Upgrade_Left_Time,Restrict,Contribution};
		fulltime->
			{Facilityid,FaLevel,Upgrade_Start_Time,Value,Restrict,Contribution};
		restrict->	
			{Facilityid,FaLevel,Upgrade_Start_Time,Upgrade_Left_Time,Value,Contribution};
		contribution->	
			{Facilityid,FaLevel,Upgrade_Start_Time,Upgrade_Left_Time,Restrict,Value}
	end.

change_facility_info(NewFainfo)->
	{GuildId,FacilityId} = get_by_facility_item(id,NewFainfo),
	FacInfoWithoutGuildid = set_by_facility_item(id,FacilityId,NewFainfo),	
	MessagePro = {guildmanager_msg,{update_facility_info,{FacilityId,FacInfoWithoutGuildid}}},
	guild_manager_op:broad_cast_to_guild_proc(GuildId,MessagePro),
	Message = guild_packet:encode_guild_facilities_update_s2c(guild_packet:make_facilityinfo(FacInfoWithoutGuildid)),
	guild_manager_op:broad_cast_to_guild_client(GuildId,Message ),
	Level=get_by_facility_item(level,NewFainfo),
				case guild_spawn_db:get_guildinfo(GuildId) of
				[]->
					nothing;
				GuildBaseInfo->
					{Nowsize,Maxsize}=guild_proto_db:get_guild_package(GuildBaseInfo),
					PackageSize=guild_package_op:get_guild_package_size_of_level(Level),
					guild_spawn_db:set_guild_package(GuildId, {Nowsize,PackageSize})	%%å¸®ä¼šå‡çº§å½±å“å¸®ä¼šä»“åº“å¤§å°
				end,
	guild_manager_op:broad_cast_to_guild_role(GuildId, {guild_message,{reset_guild_package_falg,0}}),
	guild_spawn_db:set_guild_facility(
	GuildId,
	FacilityId,
	Level,
	get_by_facility_item(upgradetime,NewFainfo),
	get_by_facility_item(fulltime,NewFainfo),
	get_by_facility_item(restrict,NewFainfo),
	get_by_facility_item(contribution,NewFainfo)).
