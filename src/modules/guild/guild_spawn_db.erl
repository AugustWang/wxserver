%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-9-1
%% Description: TODO: Add description to guild_spawn_db
-module(guild_spawn_db).

%%
%% Include files
%%
-include("guild_def.hrl").
-include("common_define.hrl").
-include_lib("stdlib/include/qlc.hrl").
-include("guild_define.hrl").


%%
%% Exported Functions
%%
-compile(export_all).
-export([create_guild/3,%%10月18日修改create_guild/1为create_guild/3[xiaowu]
		 get_allguildInfo/0,
		 get_guildinfo/1,
		 get_guild_id/1,
		 get_guild_name/1,
		 get_guild_level/1,
		 get_guild_silver/1,
		 get_guild_gold/1,
		 get_guild_notice/1,
		 set_guild_notice/2,
		 set_guild_level/2,
		 set_guild_silver/2,
		 set_guild_gold/2,
		 set_guild_name/2,
		 add_guild_level/2,
		 add_guild_silver/2,
		 add_guild_gold/2,
		 get_members_by_guild/1,
		 add_member_to_guild/3,
		 del_member_from_guild/1,
		 del_member_from_guild/4,
		 get_guildinfo_of_member/1,
		 get_guildid_by_memberinfo/1,
		 get_contribution_by_memberinfo/1,
		 get_tcontribution_by_memberinfo/1,
		 get_authgroup_by_memberinfo/1,
		 set_member_contribution/2,
		 set_member_tcontribution/2,
		 set_member_authgroup/2,
		 delete_guild_score/1,
		 
		 
		 get_guild_facility_infos/1,
		 get_guild_facility_info/2,
		 get_facility_level_from_guildfacilityinfo/1,
		 get_facility_level_from_guildfacilityinfos/2,
		 get_facility_upgradestatus_from_guildfacilityinfo/1,
		 get_facility_upgradestatus_from_guildfacilityinfos/2,
		 get_facility_upgrade_finished_time_from_guildfacilityinfo/1,
		 get_facility_upgrade_finished_time_from_guildfacilityinfos/2,
		 set_guild_facility/7,
		 get_facility_required_from_guildfacilityinfo/1,
		 
		 get_member_leave_info/1,
		 get_leave_time/1,
		 del_member_leave_info/1,
		 get_guild_logs/1,
		 get_guild_logs/2,
		 add_guild_log/4,
		 get_guild_log_memberid/1,
 		 get_guild_log_description/1,
		 get_guild_log_time/1,
		 get_guild_events/1,
		 add_guild_event/2,
		 get_guild_event_descroption/1,
		 get_guild_event_time/1,
		 get_guild_createdate/1	 	
		 ]).

%%
%% API Functions
%%

%%
%% create_guild() return -> {ok,GuildInfo} | {failed,Reason}
%%
create_guild(GuildName,Notice,Create_Level)->%%加入Create_Level参数[xiaowu]
	case valid_name(GuildName) of
		false-> {failed,invalid_name};
		_->
			case guild_manager_op:unique_name(GuildName) of
				false->{failed,repeaded_name};
				_-> 
					StorageSize=guild_package_op:get_guild_package_size_of_level(Create_Level),
					GuildObject = get_guild_at_create_moment(GuildName,Notice,Create_Level,StorageSize),%%加入Notice,Create_Level参数[xiaowu]
					case dal:write_rpc(GuildObject) of
						{ok}->
							{ok,GuildObject};
						_->
							{failed,[]}
					end
			end
	end.

delete_guild(GuildId)->
	dal:delete_rpc(guild_baseinfo,GuildId).

get_allguildInfo()->
	case dal:read_rpc(guild_baseinfo) of
		{ok,GuildInfos}->GuildInfos;
		_->[]
	end.
get_guildinfo(GuildId)->
	case dal:read_rpc(guild_baseinfo,GuildId) of
		{ok,[GuildInfo]}->GuildInfo;
		_->	[]
	end.

get_guild_id(GuildInfo)->
	erlang:element(#guild_baseinfo.id, GuildInfo).
	
get_guild_name(GuildInfo)->
	erlang:element(#guild_baseinfo.name, GuildInfo).

get_guild_notice(GuildInfo)->
	erlang:element(#guild_baseinfo.notice, GuildInfo).

get_guild_level(GuildInfo)->
	erlang:element(#guild_baseinfo.level, GuildInfo).

get_guild_silver(GuildInfo)->
	erlang:element(#guild_baseinfo.silver, GuildInfo).

get_guild_gold(GuildInfo)->
	erlang:element(#guild_baseinfo.gold, GuildInfo).

get_guild_chatgroup(GuildInfo)->
	erlang:element(#guild_baseinfo.chatgroup, GuildInfo).

get_guild_voicegroup(GuildInfo)->
	erlang:element(#guild_baseinfo.voicegroup, GuildInfo).

get_guild_createdate(GuildInfo)->
	erlang:element(#guild_baseinfo.createtime, GuildInfo).
	
get_guild_lastactivetime(GuildInfo)->
	erlang:element(#guild_baseinfo.lastactivetime, GuildInfo).

get_guild_sendwarningmail(GuildInfo)->
	erlang:element(#guild_baseinfo.sendwarningmail, GuildInfo).

get_guild_applyinfo(GuildInfo)->
	erlang:element(#guild_baseinfo.applyinfo, GuildInfo).

get_guild_treasure_transport(GuildInfo)->
	%%erlang:element(#guild_baseinfo.treasure_transport, GuildInfo).
	case erlang:element(#guild_baseinfo.treasure_transport, GuildInfo) of
		undefined->
			{0,0,0};
		Time->
			Time
	end.


set_guild_treasure_transport(GuildId,NewInfo)->
	GuildInfo = get_guildinfo(GuildId),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.treasure_transport, GuildInfo, NewInfo),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.	

set_guild_level(GuildId,NewLevel)->
	GuildInfo = get_guildinfo(GuildId),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.level, GuildInfo , NewLevel),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.	
	
set_guild_notice(GuildId,Notice)->
	GuildInfo = get_guildinfo(GuildId),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.notice, GuildInfo , Notice),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.	
	
set_guild_name(GuildId,Name)->
	GuildInfo = get_guildinfo(GuildId),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.name, GuildInfo , Name),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.
	
set_guild_silver(GuildId,NewSilver)->
	GuildInfo = get_guildinfo(GuildId),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.silver, GuildInfo , NewSilver),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.
	
set_guild_gold(GuildId,NewGold)->
	GuildInfo = get_guildinfo(GuildId),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.gold, GuildInfo , NewGold),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.

set_guild_chatgroup(GuildId,ChatGroupNo)->
	GuildInfo = get_guildinfo(GuildId),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.chatgroup, GuildInfo , ChatGroupNo),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.
	
set_guild_voicegroup(GuildId,VoiceGroupId)->
	GuildInfo = get_guildinfo(GuildId),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.voicegroup, GuildInfo , VoiceGroupId),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.

set_guild_createdate(GuildId,CreateTime)->
	GuildInfo = get_guildinfo(GuildId),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.createtime, GuildInfo , CreateTime),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.

set_guild_lastactivetime(GuildId,ActiveTime)->
	GuildInfo = get_guildinfo(GuildId),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.lastactivetime, GuildInfo , ActiveTime),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.

set_guild_sendwarningmail(GuildId,SendFlag)->
	GuildInfo = get_guildinfo(GuildId),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.sendwarningmail, GuildInfo , SendFlag),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.
	
set_guild_applyinfo(GuildId,ApplyInfo)->
	GuildInfo = get_guildinfo(GuildId),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.applyinfo, GuildInfo , ApplyInfo),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.

set_guild_package(GuildId,Package)->
	GuildInfo = get_guildinfo(GuildId),
	PackageLimit=guild_proto_db:get_guild_package_limit(GuildInfo),
	NewGuildInfo = erlang:setelement(#guild_baseinfo.package, GuildInfo , {Package,PackageLimit}),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.

set_guild_info(GuildInfo)->
	case dal:write_rpc(GuildInfo) of
		{ok}->
			GuildInfo;
		_->
			[]
	end.

add_guild_level(GuildId,Level)->
	GuildInfo = get_guildinfo(GuildId),
	OldLevel = GuildInfo#guild_baseinfo.level,
	NewGuildInfo = erlang:setelement(#guild_baseinfo.level, GuildInfo ,  OldLevel + Level),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.

add_guild_silver(GuildId,Silver)->
	GuildInfo = get_guildinfo(GuildId),
	OldSilver = GuildInfo#guild_baseinfo.silver,
	NewGuildInfo = erlang:setelement(#guild_baseinfo.silver, GuildInfo ,  OldSilver+ Silver),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.

add_guild_gold(GuildId,Gold)->
	GuildInfo = get_guildinfo(GuildId),
	OldGold = GuildInfo#guild_baseinfo.gold,
	NewGuildInfo = erlang:setelement(#guild_baseinfo.gold, GuildInfo , OldGold + Gold),
	case dal:write_rpc(NewGuildInfo) of
		{ok}->
			NewGuildInfo;
		_->
			[]
	end.


get_members_by_guild(GuildId)->
	case dal:read_index_rpc(guild_member,GuildId ,#guild_member.guildid) of
		{ok,GuildMemberInfo}->GuildMemberInfo;
		_->[]
	end.

add_member_to_guild(GuildId,MemberId,AuthGroupId)->
	MemberInfo = #guild_member{key_id_member = {GuildId,MemberId},
								guildid = GuildId,
								memberid = MemberId,
								contribution = 0,
							    tcontribution = 0,
								authgroup = AuthGroupId,
								nickname = [],
								todaymoney = {{0,0,0},0},
								totalmoney = 0},
	dal:write_rpc(MemberInfo).
	
add_member_to_guild(GuildId,MemberId,AuthGroupId,OldContribution,OldTContribution)->
	MemberInfo = #guild_member{key_id_member = {GuildId,MemberId},
								guildid = GuildId,
								memberid = MemberId,
								contribution = OldContribution,
							    tcontribution = OldTContribution,
								authgroup = AuthGroupId,
								nickname = [],
								todaymoney = {{0,0,0},0},
								totalmoney = 0},
	dal:write_rpc(MemberInfo).
	
	
		
get_member_leave_info(MemberId)->
	case dal:read_rpc(guild_leave_member,MemberId) of
		{ok,[LeaveInfo]}->LeaveInfo;
		_->[]
	end.

del_member_leave_info(LevelInfo)->
	dal:delete_object_rpc(LevelInfo).

get_leave_time(LeaveInfo)->
	erlang:element(#guild_leave_member.time,LeaveInfo).
	
get_leave_guildid(LeaveInfo)->
	erlang:element(#guild_leave_member.lastguildid,LeaveInfo).
	
get_leave_contribution(LeaveInfo)->
	erlang:element(#guild_leave_member.contribution,LeaveInfo).

%%1月23日写[xiaowu]
get_leave_tcontribution(LeaveInfo)->
	erlang:element(#guild_leave_member.tcontribution,LeaveInfo).
%%
	
del_member_from_guild(MemberId)->
	case dal:read_index_rpc(guild_member,MemberId,#guild_member.memberid) of
		{ok,[]}->[];
		{ok,[GuildMember]}->		
			dal:delete_object_rpc(GuildMember);
		_->
			[]
	end.
	
del_member_from_guild(MemberId,LeaveGuildId,Contrubution,TContrubution)->
	case dal:read_index_rpc(guild_member,MemberId,#guild_member.memberid) of
		{ok,[]}->[];
		{ok,[GuildMember]}->
			LocalTime = erlang:now(),	
			dal:write_rpc({guild_leave_member,MemberId,LocalTime,LeaveGuildId,Contrubution,TContrubution}),			
			dal:delete_object_rpc(GuildMember);
		_->
			[]
	end.	

delete_all_member_by_guildid(GuildId)->
	case get_members_by_guild(GuildId) of
		[]-> [];
		GuildMembers-> 
			lists:foreach(fun(Info)->dal:delete_object_rpc(Info) end,GuildMembers)
	end.

get_guildinfo_of_member(MemberId)->
	case dal:read_index_rpc(guild_member,MemberId ,#guild_member.memberid) of
		{ok,[]}->[];
		{ok,[GuildMemberInfo]}->GuildMemberInfo;
		_->[]
	end.

get_memberid_by_memberinfo(GuildMemberInfo)->
	erlang:element(#guild_member.memberid	, GuildMemberInfo).
	
get_guildid_by_memberinfo(GuildMemberInfo)->
	erlang:element(#guild_member.guildid	, GuildMemberInfo).

get_contribution_by_memberinfo(GuildMemberInfo)->
	erlang:element(#guild_member.contribution , GuildMemberInfo).

get_tcontribution_by_memberinfo(GuildMemberInfo)->
	erlang:element(#guild_member.tcontribution , GuildMemberInfo).

get_authgroup_by_memberinfo(GuildMemberInfo)->
	erlang:element(#guild_member.authgroup , GuildMemberInfo).

get_nickname_by_memberinfo(GuildMemberInfo)->
	erlang:element(#guild_member.nickname , GuildMemberInfo).
	
get_todaymoney_by_memberinfo(GuildMemberInfo)->
	erlang:element(#guild_member.todaymoney , GuildMemberInfo).
	
get_totalmoney_by_memberinfo(GuildMemberInfo)->
	erlang:element(#guild_member.totalmoney , GuildMemberInfo).

		
set_member_contribution(MemberId,Contribution)->
	GuildMemberInfo = get_guildinfo_of_member(MemberId),
	NewMemberInfo = setelement(#guild_member.contribution,GuildMemberInfo,Contribution),				
	dal:async_write_rpc(NewMemberInfo).

set_member_tcontribution(MemberId,TContribution)->
	GuildMemberInfo = get_guildinfo_of_member(MemberId),
	NewMemberInfo = setelement(#guild_member.tcontribution,GuildMemberInfo,TContribution),
	dal:async_write_rpc(NewMemberInfo).
			
set_member_authgroup(MemberId,AuthGroup)->
	GuildMemberInfo =get_guildinfo_of_member(MemberId),
	NewMemberInfo = setelement(#guild_member.authgroup,GuildMemberInfo,AuthGroup),				
	dal:async_write_rpc(NewMemberInfo).

set_member_nickname(MemberId,NickName)->
	GuildMemberInfo = get_guildinfo_of_member(MemberId),
	NewMemberInfo = setelement(#guild_member.nickname,GuildMemberInfo,NickName),				
	dal:async_write_rpc(NewMemberInfo).
	
set_member_money(MemberId,TodayMoney,TotalMoney)->
	GuildMemberInfo = get_guildinfo_of_member(MemberId),
	NewMemberInfo = GuildMemberInfo#guild_member{todaymoney = TodayMoney, totalmoney = TotalMoney},			
	dal:async_write_rpc(NewMemberInfo).
			
		
%%
%% facility of guild
%%
delete_guild_facility(GuildId)->
	case get_guild_facility_infos(GuildId) of
		[]->
			nothing;
		FacInfos->
			lists:foreach(fun(Info)->
								dal:delete_object_rpc(Info)
							end,FacInfos)
	end.

get_guild_facility_infos(GuildId)->
	Pattern = #guild_facility_info{guildid=GuildId,_='_'},
	case dal:index_match_object_rpc(Pattern,#guild_facility_info.guildid) of
		{ok,Result}->Result;
		_->[]
	end.
	
get_guild_facility_info(GuildId,FacilityId)->
	Pattern = #guild_facility_info{guildid=GuildId,facilityid=FacilityId,_='_'},
	case dal:index_match_object_rpc(Pattern,#guild_facility_info.guildid) of
		{ok,Result}->Result;
		_->[]
	end.

get_facility_level_from_guildfacilityinfo(GuildFacilityInfo)->
	case GuildFacilityInfo of
		[]-> ?DEFAULT_FACILITY_LEVEL;
		[FacilityInfo]-> erlang:element(#guild_facility_info.level, FacilityInfo);
		_->?DEFAULT_FACILITY_LEVEL
	end.

get_facility_level_from_guildfacilityinfos(GuildFacilityInfos,FacilityId)->
	case lists:keyfind(FacilityId, #guild_facility_info.facilityid, GuildFacilityInfos) of
		false-> ?DEFAULT_FACILITY_LEVEL;
		GuildFacilityInfo-> erlang:element(#guild_facility_info.level, GuildFacilityInfo)
	end.
get_facility_upgradestatus_from_guildfacilityinfo(GuildFacilityInfo)->
	case GuildFacilityInfo of
		[]-> ?DEFAULT_FACILITY_UPDATESTATUS;
		[FacilityInfo]-> erlang:element(#guild_facility_info.upgradestatus, FacilityInfo);
		_->?DEFAULT_FACILITY_UPDATESTATUS
	end.


get_facility_upgradestatus_from_guildfacilityinfos(GuildFacilityInfos,FacilityId)->
	case lists:keyfind(FacilityId, #guild_facility_info.facilityid, GuildFacilityInfos) of
		false-> ?DEFAULT_FACILITY_UPDATESTATUS;
		GuildFacilityInfo-> erlang:element(#guild_facility_info.upgradestatus, GuildFacilityInfo)
	end.

get_facility_upgrade_finished_time_from_guildfacilityinfo(GuildFacilityInfo)->
	case GuildFacilityInfo of
		[]-> ?DEFAULT_FACILITY_FINISHEDTIME;
		[FacilityInfo]-> erlang:element(#guild_facility_info.upgrade_finished_time, FacilityInfo);
		_->?DEFAULT_FACILITY_FINISHEDTIME
	end.
	
get_facility_required_from_guildfacilityinfo(GuildFacilityInfo)->	
	case GuildFacilityInfo of
		[]-> 0;
		[FacilityInfo]-> erlang:element(#guild_facility_info.required, FacilityInfo);
		_-> 0 
	end.

get_facility_upgrade_finished_time_from_guildfacilityinfos(GuildFacilityInfos,FacilityId)->
	case lists:keyfind(FacilityId, #guild_facility_info.facilityid, GuildFacilityInfos) of
		false-> ?DEFAULT_FACILITY_FINISHEDTIME;
		GuildFacilityInfo-> erlang:element(#guild_facility_info.upgrade_finished_time, GuildFacilityInfo)
	end.


set_guild_facility(GuildId,FacilityId,Level,UpgradeStatus,Upgrade_Finished_Time,Required,Contribution)->
	dal:write_rpc(#guild_facility_info{key_id_fac={GuildId,FacilityId},
									  guildid=GuildId,
									  facilityid=FacilityId,
									  level=Level,
									  upgradestatus=UpgradeStatus,
									  upgrade_finished_time=Upgrade_Finished_Time,
									  required = Required,
									  contribution = Contribution}). 

%%
%% log  -record(guild_log,{key_guild_time,guildid,logid,logtype,description,time}).
%%
get_guild_loginfo(GuildId)->
	case get_guild_logs(GuildId) of
		{ok,Logs}->
			Logs;
		_->
			[]
	end.

get_guild_loginfo(GuildId,Type)->
	case get_guild_logs(GuildId,Type) of
		{ok,Logs}->
			Logs;
		_->
			[]
	end.


get_guild_logs(GuildId)->
	Pattern = #guild_log{guildid=GuildId,_='_'},
	case dal:index_match_object_rpc(Pattern,#guild_log.guildid) of
		{ok,Result}->{ok,Result};
		_->{failed}
	end.

get_guild_logs(GuildId,LogType)->
	Pattern = #guild_log{guildid=GuildId,logtype=LogType,_='_'},
	case dal:index_match_object_rpc(Pattern,#guild_log.guildid) of
		{ok,Result}->{ok,Result};
		_->{failed}
	end.

delete_guild_log(GuildId)->
	case get_guild_loginfo(GuildId)	of
		[]->
			nothing;
		Logs->
			lists:foreach(fun(Info)->
				dal:delete_object_rpc(Info)
			end,Logs)
	end.
	

%%
%%memberid == logid
%%
add_guild_log(GuildId,LogType,MemberId,Description)->
	MaxCount = env:get2(logtypemax,LogType, ?GUILD_LOG_DEFAULT_NUM),
	case get_guild_logs(GuildId,LogType) of
		{ok,OldLogs}->
			nothing;
		_->
			OldLogs = []
	end,
	Count = length(OldLogs),
	if Count >= MaxCount ->
			Find = fun(X,Acc)->
						   case Acc of
							   []-> X;
							   _-> Diff = timer:now_diff(X#guild_log.time,Acc#guild_log.time),
								   if Diff=<0 -> X;
									  true-> Acc
									end
							end
				   end,
			case lists:foldl(Find, [], OldLogs) of
				[]-> ignor;
				MaxTime-> dal:delete_object_rpc(MaxTime)
			end;
	   true -> ignor
	end,
	Record = #guild_log{key_guild_time = {GuildId,now()},
				  			guildid=GuildId,memberid=MemberId,
							logtype=LogType,description=Description,time=now()},
	dal:write_rpc(Record),
	Record.
		
get_guild_log_type(GuildLog)->
	element(#guild_log.logtype, GuildLog).
	
get_guild_log_memberid(GuildLog)->
	element(#guild_log.memberid, GuildLog).

get_guild_log_description(GuildLog)->
	element(#guild_log.description, GuildLog).
	
get_guild_log_time(GuildLog)->
	element(#guild_log.time, GuildLog).

get_guild_events(GuildId)->
	Pattern = #guild_events{guildid=GuildId,_='_'},
	case dal:index_match_object_rpc(Pattern,#guild_events.guildid) of
		{ok,Result}->{ok,Result};
		_->{failed}
	end.
	
get_guild_event_descroption(GuildEvent)->
	element(#guild_events.description, GuildEvent).
	
get_guild_event_time(GuildEvent)->
	element(#guild_events.time, GuildEvent).
	
add_guild_event(GuildId,Description)->
	Now = now(),
	Record = #guild_events{key_guild_time = {GuildId,Now},
						  			guildid=GuildId,description=Description,time=Now},
	case dal:write_rpc(Record) of
		{ok}-> {ok,Record};
		_->{failed}
	end.

get_allmembershopinfo()->
	case dal:read_rpc(guild_member_shop) of
		{ok,MemberShopInfo}->
			MemberShopInfo;
		_->
			[]
	end.

get_member_shopinfo_by_guild(GuildId)->
	case dal:read_index_rpc(guild_member_shop,GuildId ,#guild_member_shop.guildid) of
		{ok,MemberShopInfo}->MemberShopInfo;
		_->[]
	end.

get_member_shopinfo_by_member(MemberId)->
	case dal:read_index_rpc(guild_member_shop,MemberId ,#guild_member_shop.memberid) of
		{ok,MemberShopInfo}->MemberShopInfo;
		_->[]
	end.

add_info_to_membershopinfo(GuildId,MemberId,Id,Count,Time)->
	Object = #guild_member_shop{key_id_member = {GuildId,MemberId,Id},
									guildid = GuildId,
									memberid = MemberId,
									count = Count,
									time = Time,
									ext = undefined},	
	dal:write_rpc(Object).

delete_member_shopinfo(MemberId)->
	case get_member_shopinfo_by_member(MemberId) of
		[]->
			nothing;
		InfoList->
			lists:foreach(fun(Info)-> dal:delete_object_rpc(Info) end,InfoList)
	end.

delete_member_shopinfo_by_guild(GuildId)->
	case get_member_shopinfo_by_guild(GuildId) of
		[]->
			nothing;
		InfoList->
			lists:foreach(fun(Info)-> dal:delete_object_rpc(Info) end,InfoList)
	end.

get_membershopinfo_key(Info)->
	element(#guild_member_shop.key_id_member, Info).

get_membershopinfo_memberid(Info)->
	element(#guild_member_shop.memberid, Info).

get_membershopinfo_guildid(Info)->
	element(#guild_member_shop.guildid, Info).

get_membershopinfo_count(Info)->
	element(#guild_member_shop.count, Info).

get_membershopinfo_time(Info)->
	element(#guild_member_shop.time, Info).

get_allmembertreasureinfo()->
	case dal:read_rpc(guild_member_treasure) of
		{ok,MemberShopInfo}->
			MemberShopInfo;
		_->
			[]
	end.

get_member_treasureinfo_by_guild(GuildId)->
	case dal:read_index_rpc(guild_member_treasure,GuildId ,#guild_member_treasure.guildid) of
		{ok,MemberShopInfo}->MemberShopInfo;
		_->[]
	end.

get_member_treasureinfo_by_member(MemberId)->
	case dal:read_index_rpc(guild_member_treasure,MemberId ,#guild_member_treasure.memberid) of
		{ok,MemberShopInfo}->MemberShopInfo;
		_->[]
	end.

add_info_to_membertreasureinfo(GuildId,MemberId,Id,Count,Time)->
	Object = #guild_member_treasure{key_id_member = {GuildId,MemberId,Id},
									guildid = GuildId,
									memberid = MemberId,
									count = Count,
									time = Time,
									ext = undefined},	
	dal:write_rpc(Object).

delete_member_treasureinfo(MemberId)->
	case get_member_treasureinfo_by_member(MemberId) of
		[]->
			nothing;
		InfoList->
			lists:foreach(fun(Info)-> dal:delete_object_rpc(Info) end,InfoList)
	end.

delete_member_treasureinfo_by_guild(GuildId)->
	case get_member_treasureinfo_by_guild(GuildId) of
		[]->
			nothing;
		InfoList->
			lists:foreach(fun(Info)-> dal:delete_object_rpc(Info) end,InfoList)
	end.

get_membertreasureinfo_key(Info)->
	element(#guild_member_treasure.key_id_member, Info).

get_membertreasureinfo_memberid(Info)->
	element(#guild_member_treasure.memberid, Info).

get_membertreasureinfo_guildid(Info)->
	element(#guild_member_treasure.guildid, Info).

get_membertreasureinfo_count(Info)->
	element(#guild_member_treasure.count, Info).

get_membertreasureinfo_time(Info)->
	element(#guild_member_treasure.time, Info).

get_treasurepriceinfo()->
	case dal:read_rpc(guild_treasure_price) of
		{ok,MemberShopInfo}->
			MemberShopInfo;
		_->
			[]
	end.

get_treasurepriceinfo_by_guildid(GuildId)->
	case dal:read_index_rpc(guild_treasure_price,GuildId ,#guild_treasure_price.guildid) of
		{ok,MemberShopInfo}->MemberShopInfo;
		_->[]
	end.

add_treasurepriceinfo(GuildId,Id,ModifyPrice)->
	Object = #guild_treasure_price{key_guild_id ={GuildId,Id},guildid = GuildId,price = ModifyPrice,ext = undefined },			
	dal:write_rpc(Object).

delete_treasureprice_by_guildid(GuildId)->
	case get_treasurepriceinfo_by_guildid(GuildId) of
		[]->
			nothing;
		InfoList->
			lists:foreach(fun(Info)-> dal:delete_object_rpc(Info) end,InfoList)
	end.


get_membertreasurepriceinfo_key(Info)->
	element(#guild_treasure_price.key_guild_id, Info).

get_membertreasurepriceinfo_guildid(Info)->
	element(#guild_treasure_price.guildid, Info).

get_membertreasurepriceinfo_price(Info)->
	element(#guild_treasure_price.price, Info).

get_allquestinfo()->
	case dal:read_rpc(guild_quest_info) of
		{ok,QuestInfos}->
			QuestInfos;
		_->
			[]
	end.

get_questinfo_by_guild(GuildId)->
%%	case dal:read_index_rpc(guild_quest_info,GuildId ,#guild_quest_info.guildid) of
%%		{ok,QuestInfos}->QuestInfos;
%%		_->[]
%%	end.
	[].

get_questinfo_starttime(Info)->
	element(#guild_quest_info.starttime, Info).

get_questinfo_guildid(Info)->
	element(#guild_quest_info.guildid, Info).

add_questinfo(GuildId,StartTime)->
	Object = #guild_quest_info{guildid = GuildId,starttime = StartTime,ext = undefined },			
	dal:write_rpc(Object).

delete_questinfo_by_guild(GuildId)->
	case get_questinfo_by_guild(GuildId) of
		[]->
			nothing;
		InfoList->
			lists:foreach(fun(Info)-> dal:delete_object_rpc(Info) end,InfoList)
	end.
	
	
add_impeach_info(GuildId,RoleId,Notice)->
	ImpeachInfo = #guild_impeach_info{
						guildid = GuildId,
						roleid = RoleId,
						notice = Notice,
						support = 0,
						opposite = 0,
						starttime = now(),
						voteids = []},
	dal:write_rpc(ImpeachInfo),
	ImpeachInfo.
	

get_allimpeach()->
	case dal:read_rpc(guild_impeach_info) of
		{ok,GuildInfos}->GuildInfos;
		_->[]
	end.
	
get_impeach_info(GuildId)->
	case dal:read_rpc(guild_impeach_info,GuildId) of
		{ok,[ImpeachInfo]}->ImpeachInfo;
		_->[]
	end.

get_impeach_guildid(ImpeachInfo)->
	element(#guild_impeach_info.guildid, ImpeachInfo).
	
get_impeach_roleid(ImpeachInfo)->
	element(#guild_impeach_info.roleid, ImpeachInfo).
	
get_impeach_notice(ImpeachInfo)->
	element(#guild_impeach_info.notice, ImpeachInfo).
	
get_impeach_support(ImpeachInfo)->
	element(#guild_impeach_info.support, ImpeachInfo).
	
get_impeach_opposite(ImpeachInfo)->
	element(#guild_impeach_info.opposite, ImpeachInfo).
	
get_impeach_starttime(ImpeachInfo)->
	element(#guild_impeach_info.starttime, ImpeachInfo).
	
get_impeach_voteids(ImpeachInfo)->
	element(#guild_impeach_info.voteids, ImpeachInfo).
		
set_impeach_support(GuildId,Support,VoteId)->
	case get_impeach_info(GuildId) of
		[]->
			nothing;
		ImpeachInfo->
			OldVoteIds = get_impeach_voteids(ImpeachInfo),			
			NewImpeachInfo1 = setelement(#guild_impeach_info.support,ImpeachInfo,Support),
			NewImpeachInfo = setelement(#guild_impeach_info.voteids,NewImpeachInfo1,[VoteId|OldVoteIds]),
			dal:async_write_rpc(NewImpeachInfo)
	end.
	
set_impeach_opposite(GuildId,Opposite,VoteId)->
	case get_impeach_info(GuildId) of
		[]->
			nothing;
		ImpeachInfo->
			OldVoteIds = get_impeach_voteids(ImpeachInfo),			
			NewImpeachInfo1 = setelement(#guild_impeach_info.voteids,ImpeachInfo,[VoteId|OldVoteIds]),
			NewImpeachInfo = setelement(#guild_impeach_info.opposite,NewImpeachInfo1,Opposite),
			dal:async_write_rpc(NewImpeachInfo)
	end.
	
set_impeach_support(GuildId,Support)->
	case get_impeach_info(GuildId) of
		[]->
			nothing;
		ImpeachInfo->
			NewImpeachInfo = setelement(#guild_impeach_info.support,ImpeachInfo,Support),
			dal:async_write_rpc(NewImpeachInfo)
	end.
	
del_impeach_info(GuildId)->
	case get_impeach_info(GuildId) of
		[]->
			nothing;	
		ImpeachInfo->
			dal:delete_object_rpc(ImpeachInfo)
	end.

%%
%% Local Functions
%%


valid_name(GuildName)->
	%%check len and blanks
	NewGuildName = string:strip(GuildName),
	Length = erlang:length(NewGuildName),
	if
		Length > 0->
			case senswords:word_is_sensitive(GuildName) of
				true-> false;
				_-> true
			end;
		true->
			false
	end.

unique_name(GuildName)->
	F = fun() ->
		Q = qlc:q([X|| X<-mnesia:table(guild_baseinfo),X#guild_baseinfo.name==GuildName]),
		qlc:e(Q)
	end,
	case dal:run_transaction_rpc(F) of
		{ok,[]}->true;
		{ok,_}->false;
		_->true
	end.
	
get_guild_at_create_moment(GuildName,Notice,Create_Level,StorageSize)->%%加入Create_Level参数[xiaowu]
	Id = guildid_generator:gen_newid(),
	Now = timer_center:get_correct_now(),
	{NowDate,_} = calendar:now_to_local_time(Now),
	#guild_baseinfo{
					id = Id,
					name = GuildName,
					level = Create_Level,%%修改level=1为level=Create_Level[xiaowu]
					silver = 0,
					gold = 0,
					notice = Notice,%%修改notice=[]为notice=Notice[xiaowu]
					createtime = NowDate,
					chatgroup = [],
					voicegroup = [],
					lastactivetime = Now,
					sendwarningmail = false,
					applyinfo = [],
					treasure_transport = {0,0,0},
					package={{0,StorageSize},[{1,0},{2,0},{3,0}]}
			}.
			
%%guild monster
get_guild_monsterinfo(GuildId)->
	case dal:read_rpc(guild_monster,GuildId) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.

add_guild_monster({GuildId,NewMonsterList,LeftTimes,Time,LastCallTime,ActivMonster})->
	dal:write_rpc({guild_monster,GuildId,NewMonsterList,LeftTimes,Time,LastCallTime,ActivMonster}).

get_guild_battle_score_info(GuildId)->
	case dal:read_rpc(guild_battle_score,GuildId) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.

add_guild_battle_score_info(GuildId,GbScore,TScore,WinInfo)->
	dal:write_rpc({guild_battle_score,GuildId,GbScore,TScore,WinInfo}).

delete_guild_score(GuildId)->
	dal:delete_rpc(guild_battle_score, GuildId).

get_all_guild_battle_score()->		
	case dal:read_rpc(guild_battle_score) of
		{ok,Info}->
			Info;
		_->[]
	end.

clear_guild_score()->
	dal:clear_table_rpc(guild_battle_score).
		
set_guild_right_limit(GuildId,SmithLimit,BattleLimit)->
	dal:write_rpc({guild_right_limit,GuildId,SmithLimit,BattleLimit}).

get_guild_right_limit(GuildId)->
	case dal:read_rpc(guild_right_limit,GuildId) of	
		{ok,[Info]}->
			Info;
		_->
			[]
	end.

get_guild_right_limit_from_ets(GuildId)->
	case ets:lookup(guild_right_limit_ets,GuildId) of
		[Info]->Info;
		D->[]
	end.

set_guild_right_limit_to_ets(Info)->
	ets:insert(guild_right_limit_ets,Info).

