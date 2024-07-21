%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-10
%% Description: TODO: Add description to guild_member_op
-module(guild_member_op).

%%
%% Include files
%%
-compile(export_all).


-include("data_struct.hrl").
-include("role_struct.hrl").
-include("guild_define.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%

%%
%% API Functions
%%
init()->
	ets:new(member_list, [set, protected, named_table]),
	ets:new(guild_member_pos_info,[set,protected,named_table]),
	ets:new(guild_member_binmsg,[set,protected,named_table]),
	ets:new(today_online_record,[set,protected, named_table]).

%% ===========================================================
%% opt data
%% ===========================================================
get_member_info(MemberId)->
	case ets:lookup(member_list, MemberId) of
		[]-> [];
		[MemberInfo]->MemberInfo
	end.

get_online_info(GuildId)->
	case ets:lookup(today_online_record, GuildId) of
		[]-> [];
		[OnLineInfo]->OnLineInfo
	end.

get_all_members_pos_info(GuildId)->
	case ets:lookup(guild_member_pos_info,GuildId) of
		[]->
			[];
		[{_,Info}]->
			Info
	end.

get_member_name(RoleId)->
	case guild_member_op:get_member_info(RoleId) of
		[]->
			error;
		MemberInfo->
			guild_member_op:get_by_member_item(name,MemberInfo)
	end.

get_member_posting(RoleId)->
	case guild_member_op:get_member_info(RoleId) of
		[]->
			error;
		MemberInfo->
			guild_member_op:get_by_member_item(posting,MemberInfo)
	end.
	
get_member_contribution(RoleId)->
	case guild_member_op:get_member_info(RoleId) of
		[]->
			0;
		MemberInfo->
			guild_member_op:get_by_member_item(contribution,MemberInfo)
	end.

get_member_tcontribution(RoleId)->
	case guild_member_op:get_member_info(RoleId) of
		[]->
			0;
		MemberInfo->
			guild_member_op:get_by_member_item(totlecontribution,MemberInfo)
	end.

update_member_info(Roleinfo)->
	ets:insert(member_list,Roleinfo).

update_online_record(OnlineInfo)->
	ets:insert(today_online_record,OnlineInfo).

update_pos_info(RoleId,GuildId,LineId,MapId)->
	case ets:lookup(guild_member_pos_info,GuildId) of
		[]->
			NewPosInfo = [{RoleId,LineId,MapId}];
		[{_,PosInfo}]->
			NewTerm = {RoleId,LineId,MapId},
			NewPosInfo = lists:keyreplace(RoleId,1,PosInfo,NewTerm)
	end,	
	ets:insert(guild_member_pos_info,{GuildId,NewPosInfo}).

add_pos_info(RoleId,GuildId,LineId,MapId)->
	case ets:lookup(guild_member_pos_info,GuildId) of
		[]->
			NewPosInfo = [{RoleId,LineId,MapId}];
		[{_,PosInfo}]->
			NewTerm = {RoleId,LineId,MapId},
			case lists:keyfind(RoleId,1,PosInfo) of
				false->
					NewPosInfo = [NewTerm|PosInfo];
				_->
					NewPosInfo = lists:keyreplace(RoleId,1,PosInfo,NewTerm)
			end
	end,	
	ets:insert(guild_member_pos_info,{GuildId,NewPosInfo}).

add_memberbinmsg_to_ets(GuildId,MemberId)->
	{GH,GL} = GuildId,
	EtsTerm = {{GH,GL,MemberId}},
	ets:insert(guild_member_binmsg,EtsTerm).

add_member_to_guild(GuildId,Roleinfo)->
	Roleid = get_by_member_item(id,Roleinfo), 
	case ets:lookup(guild_list, GuildId) of
		[]->
			slogger:msg("add_member_to_guild error GuildId ~p [] ~n",[GuildId]);
		[GuildInfo]->
			MemberList = guild_manager_op:get_by_guild_item(members,GuildInfo),
			NewMemberLists = MemberList ++ [Roleid],
			guild_manager_op:update_guild_info(guild_manager_op:set_by_guild_item(members,NewMemberLists,GuildInfo)),
			update_member_info(Roleinfo)
	end.

delete_pos_info(RoleId,GuildId)->
	case ets:lookup(guild_member_pos_info,GuildId) of
		[]->
			nothing;
		[Info]->
			{_,PosList} = Info,
			NewPosList = lists:keydelete(RoleId,1,PosList),
			ets:insert(guild_member_pos_info,{GuildId,NewPosList})
	end.

delete_member_from_guild(GuildId,Roleid)->
	case ets:lookup(guild_list, GuildId) of
		[]->
			slogger:msg("add_member_to_guild error GuildId ~p [] ~n",[GuildId]);
		[GuildInfo]->
			MemberList = guild_manager_op:get_by_guild_item(members,GuildInfo),
			NewMembers = lists:delete(Roleid,MemberList),
			guild_manager_op:update_guild_info(guild_manager_op:set_by_guild_item(members,NewMembers,GuildInfo)),
			ets:delete(member_list,Roleid)
	end.
%% ===========================================================
%% opt data
%% ===========================================================
add_online_member(GuildId,RoleId)->
	case get_online_info(GuildId) of
		[]->
			{Today,_} = calendar:now_to_local_time(timer_center:get_correct_now()),
			update_online_record({GuildId,Today,[RoleId]});
		{_,Time,RoleList}->
			case lists:member(RoleId,RoleList) of
				true->
					nothing;
				_->
					update_online_record({GuildId,Time,RoleList++[RoleId]})
			end;
		_->
			nothing
	end.

get_member_num_by_posting(GuildId,Posting)->
	GuildInfo = guild_manager_op:get_guild_info(GuildId),
	MembersId = guild_manager_op:get_by_guild_item(members,GuildInfo),
	if 
		Posting =:= ?GUILD_POSE_LEADER->
			1;
		Posting =:= ?GUILD_POSE_MEMBER->
			length(MembersId);
		Posting =:= ?GUILD_POSE_PREMEMBER->
			length(MembersId);		
		true->			
			lists:foldl(fun(Memberid,MasterNum)->
						MemberInfo = get_member_info(Memberid),
						case get_by_member_item(posting,MemberInfo) =:= Posting of
							true->
								MasterNum+1;
							_ ->
								MasterNum
						end			
			end,0,MembersId)
	end.

proc_member_online(Roleid,OriGuildId,{Level,LineId,MapId})->
	MemberInfo = get_member_info(Roleid),	
	case (MemberInfo =/= [])of
		true->
			case guild_spawn_db:get_guildinfo_of_member(Roleid) of
				[]->
					slogger:msg("guild_spawn_db:get_guildinfo_of_member Roleid error ~p ~n",[Roleid]),
					[];
				MemberDbInfo->
					GuildId = guild_spawn_db:get_guildid_by_memberinfo(MemberDbInfo),
					GuildInfo = guild_manager_op:get_guild_info(GuildId),	
					Members = guild_manager_op:get_by_guild_item(members,GuildInfo),
					case lists:member(Roleid,Members)  of
						false->	
							MsgDestroy = guild_packet:encode_guild_destroy_s2c(?GUILD_DESTROY_BEKICKED),
							role_pos_util:send_to_role_clinet(Roleid,MsgDestroy),
							[];
						_->	
							NewInfo1 = set_by_member_item(online,LineId,MemberInfo),
							NewMemberInfo = set_by_member_item(level,Level,NewInfo1),
							add_pos_info(Roleid,GuildId,LineId,MapId),
							add_memberbinmsg_to_ets(GuildId,Roleid),						
							update_member_info(NewMemberInfo),
							guild_manager_op:send_guild_info_to_client(Roleid,GuildId),
							add_online_member(GuildId,Roleid),
							{_,MonsterList,LeftTimes,Time,LastCallTime,_} = guild_monster_op:get_guild_monster_info(GuildId),
							Now = now(),
							Now_CD = timer:now_diff(Now,LastCallTime),
							Call_CD = guild_monster_op:check_call_cd(Now_CD,?CALL_GUILD_MONSTER_CD),
							case timer_util:check_same_day(Now, Time) of
								true->
									Times = LeftTimes;
								_->
									Times = ?CALL_GUILD_MONSTER_MAX_TIMES
							end,
							Param = guild_packet:make_guild_monster_param(MonsterList),
							Msg = guild_packet:encode_get_guild_monster_info_s2c(Param,Times,Call_CD),
							role_pos_util:send_to_role_clinet(Roleid,Msg),
							case guild_manager_op:get_guild_treasure_transport_start_time(GuildId) of
								[]->
									nothing;
								Treasure_Transport_Start_Time ->
									Transport_LeftTime = ?TWO_HOUR - trunc(timer:now_diff(now(),Treasure_Transport_Start_Time)/1000000),
									TransportMessage = treasure_transport_packet:encode_guild_transport_left_time_s2c(Transport_LeftTime),
									role_pos_util:send_to_role_clinet(Roleid,TransportMessage)
							end,
							case lists:keyfind(GuildId,1,get(yhzq_fight_guild)) of
								false->
									ignor;
								{GuildId,Camp,Node,ProcName,MapProc}->
									role_pos_util:send_to_role(Roleid,{notify_to_join_yhzq,Camp,Node,ProcName,MapProc})
							end,
							case guild_spawn_db:get_guild_right_limit_from_ets(GuildId) of
								[]->
									Smithlimit = 0,
									Battlelimit = 0;
								{_,SmithLimit,BattleLimit}->
									Smithlimit = SmithLimit,
									Battlelimit = BattleLimit
							end,
							MsgLimit = guild_packet:encode_change_guild_right_limit_s2c(Smithlimit,Battlelimit),
							role_pos_util:send_to_role_clinet(Roleid,MsgLimit),
							make_guild_info_for_member(Roleid,GuildId)
					end
				end;
		false->
			if
				OriGuildId=/=0->
					MsgDestroy = guild_packet:encode_guild_destroy_s2c(?GUILD_DESTROY_BEKICKED),				
					role_pos_util:send_to_role_clinet(Roleid,MsgDestroy);
				true->
					nothing
			end,
			[]
	end.

proc_member_offline(RoleId,GuildId)->
	if
		GuildId =:= 0->
			guild_apply_op:remove_someone_applyinfo(RoleId);
		true->
			case guild_manager_op:get_guild_info(GuildId) of
				[]->
					nothing;
				GuildInfo->		
					Members = guild_manager_op:get_by_guild_item(members,GuildInfo),
					MemberInfo = get_member_info(RoleId),	 
					case (MemberInfo =/= []) and lists:member(RoleId,Members)  of
						true->
							NewMemberInfo = set_by_member_item(online,now(),MemberInfo),
							update_member_info(NewMemberInfo), 
							delete_pos_info(RoleId,GuildId),
							add_memberbinmsg_to_ets(GuildId,RoleId);
						_->
							nothing
					end
			end
	end.
	
proc_member_levelup(RoleId,GuildId,NewLevel)->										
	case guild_manager_op:get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->		
			Members = guild_manager_op:get_by_guild_item(members,GuildInfo),
			MemberInfo = get_member_info(RoleId),	 
			case (MemberInfo =/= []) and lists:member(RoleId,Members)  of
				true->
					NewMemberInfo = set_by_member_item(level,NewLevel,MemberInfo),
					update_member_info(NewMemberInfo), 
					add_memberbinmsg_to_ets(GuildId,RoleId);	
				_->
					nothing
			end
	end.

proc_member_change_fightforce(RoleId,GuildId,FightForce)->										
	case guild_manager_op:get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->		
			Members = guild_manager_op:get_by_guild_item(members,GuildInfo),
			MemberInfo = get_member_info(RoleId),	 
			case (MemberInfo =/= []) and lists:member(RoleId,Members)  of
				true->
					NewMemberInfo = set_by_member_item(fightforce,FightForce,MemberInfo),
					update_member_info(NewMemberInfo), 
					add_memberbinmsg_to_ets(GuildId,RoleId);	
				_->
					nothing
			end
	end.

proc_member_change_map(RoleId,Guild,NewLine,NewMap)->
	update_pos_info(RoleId,Guild,NewLine,NewMap).
	
proc_set_leader(GuildId,LeaderId,Roleid)->	 	
	OldleaderInfo = get_member_info(LeaderId),
	NewleaderInfo = get_member_info(Roleid),																			 		
	NewInfo1 = set_by_member_item(posting,?GUILD_POSE_VICE_LEADER,OldleaderInfo),
	NewInfo2 = set_by_member_item(posting,?GUILD_POSE_LEADER,NewleaderInfo),
	LeaderName = get_member_name(LeaderId),
	LeaderPosting = get_member_posting(LeaderId),
	MemberName = get_member_name(Roleid),
	LogInfo = {promotion,LeaderName,LeaderPosting,MemberName,LeaderPosting},
	guild_manager_op:add_log(GuildId,?GUILD_LOG_MEMBER_MANAGER,LogInfo),

	update_member_info(NewInfo1),
	update_member_info(NewInfo2),	
	guild_manager_op:send_base_info_update(LeaderId,GuildId),
	guild_manager_op:send_base_info_update(Roleid,GuildId),					 				
	add_memberbinmsg_to_ets(GuildId,LeaderId),
	add_memberbinmsg_to_ets(GuildId,Roleid),
	guild_spawn_db:set_member_authgroup(Roleid,?GUILD_POSE_LEADER),
	guild_spawn_db:set_member_authgroup(LeaderId,?GUILD_POSE_VICE_LEADER),
	gm_logger_guild:guild_set_leader(GuildId,LeaderId,Roleid).
	
	
change_leader_for_impeach(GuildId,RoleId)->
	GuildInfo = guild_manager_op:get_guild_info(GuildId),
	Members = guild_manager_op:get_by_guild_item(members,GuildInfo),
	case guild_manager_op:get_guild_leader(GuildId,Members) of
		[]->
			error;	
		{LeaderId,_}->
			CheckRole = lists:member(RoleId,Members),
			if
				CheckRole->
					OldleaderInfo = get_member_info(LeaderId),
					NewleaderInfo = get_member_info(RoleId),																			 		
					NewInfo1 = set_by_member_item(posting,?GUILD_POSE_MEMBER,OldleaderInfo),
					NewInfo2 = set_by_member_item(posting,?GUILD_POSE_LEADER,NewleaderInfo),
					update_member_info(NewInfo1),
					update_member_info(NewInfo2),	
					guild_manager_op:send_base_info_update(LeaderId,GuildId),
					guild_manager_op:send_base_info_update(RoleId,GuildId),					 				
					add_memberbinmsg_to_ets(GuildId,LeaderId),
					add_memberbinmsg_to_ets(GuildId,RoleId),
					guild_spawn_db:set_member_authgroup(RoleId,?GUILD_POSE_LEADER),
					guild_spawn_db:set_member_authgroup(LeaderId,?GUILD_POSE_MEMBER),
					gm_logger_guild:guild_set_leader(GuildId,LeaderId,RoleId);
				true->
						error
			end
	end.

%%
%%return true | false
%%
proc_add_member(GuildId,NewComerId)->
	%%slogger:msg("proc_add_member GuildId ~p NewComerId ~p~n",[GuildId,NewComerId]),
	case get_member_info(NewComerId) of
		[]->
			IsFull = guild_manager_op:is_posting_full(GuildId,?GUILD_POSE_MEMBER),				
			if
				IsFull->
					ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
					role_pos_util:send_to_role_clinet(NewComerId,ErrnoMsg),
					false;
				true->
					{Role_Level,Role_Name,Role_Class,Gender,Online,LineId,MapId,FightForce} = read_memberinfo_from_remote(NewComerId),
					add_pos_info(NewComerId,GuildId,LineId,MapId),
					case guild_spawn_db:get_member_leave_info(NewComerId) of
						[]->
							OldContribution = 0,
							OldTContribution = 0;
						LeaveInfo->
							OldGuildId = guild_spawn_db:get_leave_guildid(LeaveInfo),
							OldContributionTemp = guild_spawn_db:get_leave_contribution(LeaveInfo), 
							OldTContributionTemp = guild_spawn_db:get_leave_tcontribution(LeaveInfo), 
							if
								OldGuildId =:= GuildId ->
									OldContribution = OldContributionTemp,
									OldTContribution = OldTContributionTemp;
								true->
									OldContribution = 0,
									OldTContribution = 0
							end,
							guild_spawn_db:del_member_leave_info(LeaveInfo)
					end,
					NewMemberInfo = {NewComerId,Role_Name,Gender,Role_Level,Role_Class,?GUILD_POSE_MEMBER,OldContribution,OldTContribution,Online,[],{{0,0,0},0},0,FightForce},
					Msg_Add_Proc = {guildmanager_msg,{guild_add_member,NewComerId}},
					Msg_Add_Client = guild_packet:encode_guild_member_add_s2c(guild_packet:make_roleinfo(NewMemberInfo)), 
					guild_manager_op:broad_cast_to_guild_proc(GuildId,Msg_Add_Proc),
					guild_manager_op:broad_cast_to_guild_client(GuildId,Msg_Add_Client),	
					add_member_to_guild(GuildId,NewMemberInfo),
					guild_spawn_db:add_member_to_guild(GuildId,NewComerId,?GUILD_POSE_MEMBER,OldContribution,OldTContribution),
					MessageGuild = {guildmanager_msg,{update_guild_info,make_guild_info_for_member(NewComerId,GuildId)}},				
					role_pos_util:send_to_role(NewComerId,MessageGuild),
					guild_manager_op:send_guild_info_to_client(NewComerId,GuildId),
					gm_logger_role:role_join_guild(NewComerId,GuildId),
					{_,MonsterList,LeftTimes,Time,LastCallTime,_} = guild_monster_op:get_guild_monster_info(GuildId),
					Now = now(),
					Now_CD = timer:now_diff(Now,LastCallTime),
					Call_CD = guild_monster_op:check_call_cd(Now_CD,?CALL_GUILD_MONSTER_CD),
					case timer_util:check_same_day(Now, Time) of
						true->
							Times = LeftTimes;
						_->
							Times = ?CALL_GUILD_MONSTER_MAX_TIMES
					end,
					Param = guild_packet:make_guild_monster_param(MonsterList),
					Msg = guild_packet:encode_get_guild_monster_info_s2c(Param,Times,Call_CD),
					role_pos_util:send_to_role_clinet(NewComerId,Msg),
					MemberName = get_member_name(NewComerId),
					LogInfo = {addmember,MemberName},
					guild_manager_op:add_log(GuildId,?GUILD_LOG_MEMBER_MANAGER,LogInfo),
					case guild_manager_op:get_guild_treasure_transport_start_time(GuildId) of
						[]->
							nothing;
						Treasure_Transport_Start_Time ->
							Transport_LeftTime = ?TWO_HOUR - trunc(timer:now_diff(now(),Treasure_Transport_Start_Time)/1000000),
							TransportMessage = treasure_transport_packet:encode_guild_transport_left_time_s2c(Transport_LeftTime),
							role_pos_util:send_to_role_clinet(NewComerId,TransportMessage)
					end,
					case guild_spawn_db:get_guild_right_limit_from_ets(GuildId) of
						[]->
							Smithlimit = 0,
							Battlelimit = 0;
						{_,SmithLimit,BattleLimit}->
							Smithlimit = SmithLimit,
							Battlelimit = BattleLimit
					end,
					MsgLimit = guild_packet:encode_change_guild_right_limit_s2c(Smithlimit,Battlelimit),
					role_pos_util:send_to_role_clinet(NewComerId,MsgLimit),
					role_pos_util:send_to_role(NewComerId, {quest_scripts,{quest_join_guild}}),
					true
			end;
		_->
			slogger:msg("proc_add_member error NewComerId ~p has guild!~n",[NewComerId]),
			false
	end.

proc_delete_member(Reason,GuildId,KickRoleId)->
	MemberName = get_member_name(KickRoleId),
	MemberPosting = get_member_posting(KickRoleId),
	Contribution = get_member_contribution(KickRoleId),
	TContribution = get_member_tcontribution(KickRoleId),
	LogInfo = {leavemember,MemberName,MemberPosting,Reason},
	guild_manager_op:add_log(GuildId,?GUILD_LOG_MEMBER_MANAGER,LogInfo),
	delete_pos_info(KickRoleId,GuildId),
	delete_member_from_guild(GuildId,KickRoleId),	
	guild_spawn_db:del_member_from_guild(KickRoleId,GuildId,Contribution,TContribution),
	guild_shop:delete_member(KickRoleId),
	Msg_del_Proc = {guildmanager_msg,{guild_delete_member,KickRoleId}},
	Msg_del_Client = guild_packet:encode_guild_member_delete_s2c(KickRoleId,Reason), 
	guild_manager_op:broad_cast_to_guild_proc(GuildId,Msg_del_Proc),
	guild_manager_op:broad_cast_to_guild_client(GuildId,Msg_del_Client),			 	
	MsgDestroy = guild_packet:encode_guild_destroy_s2c(Reason),
	role_pos_util:send_to_role(KickRoleId,{guildmanager_msg,{guild_destroy}}),
	role_pos_util:send_to_role_clinet(KickRoleId,MsgDestroy),
	gm_logger_role:role_leave_guild(KickRoleId,GuildId,Reason),
	gm_logger_role:role_join_guild(KickRoleId,{0,0}),
	guild_impeach:hook_role_leave_guild(GuildId,KickRoleId,MemberName).
	
proc_posting_change(Type,GuildId,RoleId,ProRoleid)->
	MemberInfo = get_member_info(ProRoleid),
	OldPosting = get_by_member_item(posting,MemberInfo ),
	if
		Type =:= demotion->
			NewPosting = guild_util:next_post(OldPosting);
		Type =:= promotion->
			NewPosting = guild_util:pre_post(OldPosting)	 
	end,		 																				 	
	NewInfo = set_by_member_item(posting,NewPosting,MemberInfo),
	update_member_info(NewInfo),	
	guild_manager_op:send_base_info_update(ProRoleid,GuildId),
	add_memberbinmsg_to_ets(GuildId,ProRoleid),
	guild_spawn_db:set_member_authgroup(ProRoleid,NewPosting),
	gm_logger_guild:guild_authrity_change(GuildId,RoleId,ProRoleid,OldPosting,NewPosting),
	LeaderName = get_member_name(RoleId),
	LeaderPosting = get_member_posting(RoleId),
	MemberName = get_member_name(ProRoleid), 
	MemberPosting = get_member_posting(ProRoleid),
	LogInfo = {Type,LeaderName,LeaderPosting,MemberName,MemberPosting},
	guild_manager_op:add_log(GuildId,?GUILD_LOG_MEMBER_MANAGER,LogInfo).	

proc_change_nickname(_,GuildId,RoleId,NickName)->
	case guild_manager_op:get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->		
			Members = guild_manager_op:get_by_guild_item(members,GuildInfo),
			MemberInfo = get_member_info(RoleId),	 
			case (MemberInfo =/= []) and lists:member(RoleId,Members)  of
				true->
					NewNickName = guild_manager_op:get_filter_string(NickName),
					NewMemberInfo = set_by_member_item(nickname,NewNickName,MemberInfo),
					update_member_info(NewMemberInfo), 
					guild_spawn_db:set_member_nickname(RoleId,NewNickName),
					add_memberbinmsg_to_ets(GuildId,RoleId);	
				_->
					nothing
			end
	end.

proc_clear_nickname(LeaderId,GuildId,RoleId)->
	case guild_manager_op:get_guild_info(GuildId) of
		[]->
			nothing;
		GuildInfo->		
			Members = guild_manager_op:get_by_guild_item(members,GuildInfo),
			MemberInfo = get_member_info(RoleId),	 
			case (MemberInfo =/= []) and lists:member(RoleId,Members)  of
				true->
					NewNickName = [],
					NewMemberInfo = set_by_member_item(nickname,NewNickName,MemberInfo),
					update_member_info(NewMemberInfo), 
					guild_spawn_db:set_member_nickname(RoleId,NewNickName),
					add_memberbinmsg_to_ets(GuildId,RoleId),
					MessageOpt = guild_packet:encode_guild_opt_result_s2c(?GUILD_CLEAR_NICKNAME_SUCCESS),
					role_pos_util:send_to_role_clinet(LeaderId,MessageOpt);	
				_->
					nothing
			end
	end.

proc_get_members_pos(RoleId,GuildId)->
	PosInfo = get_all_members_pos_info(GuildId),
	GmpList = lists:map(fun({OtherRoleId,LineId,MapId})->
						guild_packet:make_gmp(OtherRoleId,LineId,MapId)
					end,PosInfo),
	MessageBin = guild_packet:encode_guild_member_pos_s2c(GmpList),
	role_pos_util:send_to_role_clinet(RoleId,MessageBin).

check_someone_in_guild(RoleId)->	 	
	case get_member_info(RoleId) of
		[]->
			false;
		_->
			true
	end.

make_guild_info_for_member(Roleid,GuildId)->
	FullInfo = guild_manager_op:get_guild_info(GuildId),	
	GuildId = guild_manager_op:get_by_guild_item(id,FullInfo),
	GuildName = guild_manager_op:get_by_guild_item(name,FullInfo),
	GuildLevel= guild_manager_op:get_by_guild_item(level,FullInfo),
	MemberLists= guild_manager_op:get_by_guild_item(members,FullInfo),
	Facilitys = lists:map(fun(FacId)->
						FacInfo = guild_facility_op:get_facility_info(GuildId,FacId),
						{
							FacId,
							guild_facility_op:get_by_facility_item(level,FacInfo),
							guild_facility_op:get_by_facility_item(upgradetime,FacInfo),
							guild_facility_op:get_by_facility_item(fulltime,FacInfo),
							guild_facility_op:get_by_facility_item(restrict,FacInfo),
							guild_facility_op:get_by_facility_item(contribution,FacInfo)
						}
					end,[?GUILD_FACILITY,?GUILD_FACILITY_TREASURE,?GUILD_FACILITY_SMITH]), 
	MemberInfo = guild_member_op:get_member_info(Roleid),
	Posting = guild_member_op:get_by_member_item(posting,MemberInfo),
	Contribution = guild_member_op:get_by_member_item(contribution,MemberInfo),
	TContribution = guild_member_op:get_by_member_item(totlecontribution,MemberInfo),
	{GuildId,GuildName,GuildLevel,Posting,Contribution,TContribution,Facilitys,MemberLists}.

read_memberinfo_from_remote(RoleId)->
	case creature_op:get_remote_role_info(RoleId) of
		undefined->			
			read_memberinfo_from_roledb(RoleId);
		RemoteInfo->			
			Role_Level = get_level_from_othernode_roleinfo(RemoteInfo),
			Role_Name = get_name_from_othernode_roleinfo(RemoteInfo),
			Role_Class = get_class_from_othernode_roleinfo(RemoteInfo),
			Gender = get_gender_from_othernode_roleinfo(RemoteInfo),
			Online = get_lineid_from_othernode_roleinfo(RemoteInfo),
			LineId = Online,
			MapId = get_mapid_from_othernode_roleinfo(RemoteInfo),
			FightForce = get_fightforce_from_othernode_roleinfo(RemoteInfo),
			{Role_Level,Role_Name,Role_Class,Gender,Online,LineId,MapId,FightForce}
	end.

%%%{Role_Level,Role_Name,Role_Class,Gender,LastOnlineTime,Line,Map}/[]				
read_memberinfo_from_roledb(Role_id)->
	RoleInfo = role_db:get_role_info(Role_id),
	case RoleInfo of
		[]->
			slogger:msg("read_memberinfo_from_roledb error!~p~n",[Role_id]),
			[];
		_->	 
			Role_Level = role_db:get_level(RoleInfo),
			Role_Name = role_db:get_name(RoleInfo),
			Role_Class = role_db:get_class(RoleInfo),
			Gender = role_db:get_sex(RoleInfo),			
			FightForce = role_db:get_fighting_force(RoleInfo),
			case get_member_pos(Role_id) of
		 		[]->				
		 			Online = role_db:get_offline(RoleInfo);
		 		LineId->
		 			Online = LineId 	
		 	end,
			{Role_Level,Role_Name,Role_Class,Gender,Online,0,0,FightForce}
	end.

get_member_pos(Roleid)->
	case role_pos_util:where_is_role(Roleid) of
		[]->[];
		RolePos->
			role_pos_db:get_role_lineid(RolePos)
	end.
		
get_by_member_item(Item,{MemberId,Name,Gender,Level,Class,Posting,Contribution,TotleContribution,OnlineState,NickName,TodayMoney,TotalMoney,FightForce})->
	case Item of
		id->
			MemberId;
		name->
			Name;
		gender->
			Gender;
		level->
			Level;
		class->
			Class;
		posting->
			Posting;
		contribution->
			Contribution;
		totlecontribution->
			TotleContribution;
		online->
			OnlineState;
		nickname->
			NickName;
		todaymoney->
			TodayMoney;
		totalmoney->
			TotalMoney;
		fightforce->
			FightForce
	end.
	
set_by_member_item(Item,Value,{MemberId,Name,Gender,Level,Class,Posting,Contribution,TotleContribution,OnlineState,NickName,TodayMoney,TotalMoney,FightForce} )->
	case Item of
		id->
			{Value,Name,Gender,Level,Class,Posting,Contribution,TotleContribution,OnlineState,NickName,TodayMoney,TotalMoney,FightForce};
		name->
			{MemberId,Value,Gender,Level,Class,Posting,Contribution,TotleContribution,OnlineState,NickName,TodayMoney,TotalMoney,FightForce};
		gender->
			{MemberId,Name,Value,Level,Class,Posting,Contribution,TotleContribution,OnlineState,NickName,TodayMoney,TotalMoney,FightForce};
		level->
			{MemberId,Name,Gender,Value,Class,Posting,Contribution,TotleContribution,OnlineState,NickName,TodayMoney,TotalMoney,FightForce};
		class->
			{MemberId,Name,Gender,Level,Value,Posting,Contribution,TotleContribution,OnlineState,NickName,TodayMoney,TotalMoney,FightForce};
		posting->
			{MemberId,Name,Gender,Level,Class,Value,Contribution,TotleContribution,OnlineState,NickName,TodayMoney,TotalMoney,FightForce};
		contribution->
			{MemberId,Name,Gender,Level,Class,Posting,Value,TotleContribution,OnlineState,NickName,TodayMoney,TotalMoney,FightForce};
		totlecontribution->
			{MemberId,Name,Gender,Level,Class,Posting,Contribution,Value,OnlineState,NickName,TodayMoney,TotalMoney,FightForce};
		online->
			{MemberId,Name,Gender,Level,Class,Posting,Contribution,TotleContribution,Value,NickName,TodayMoney,TotalMoney,FightForce};
		nickname->
			{MemberId,Name,Gender,Level,Class,Posting,Contribution,TotleContribution,OnlineState,Value,TodayMoney,TotalMoney,FightForce};
		todaymoney->
			{MemberId,Name,Gender,Level,Class,Posting,Contribution,TotleContribution,OnlineState,NickName,Value,TotalMoney,FightForce};
		totalmoney->
			{MemberId,Name,Gender,Level,Class,Posting,Contribution,TotleContribution,OnlineState,NickName,TodayMoney,Value,FightForce};
		fightforce->
			{MemberId,Name,Gender,Level,Class,Posting,Contribution,TotleContribution,OnlineState,NickName,TodayMoney,TotalMoney,Value}
	end.