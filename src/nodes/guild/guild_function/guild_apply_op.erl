%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-10
%% Description: TODO: Add description to guild_apply_op
-module(guild_apply_op).

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
	ets:new(apply_list,[set,protected, named_table]),
	ets:new(apply_member_list,[set,protected, named_table]).

%% ===========================================================
%% opt data
%% ===========================================================
get_apply_info(GuildId)->
	case ets:lookup(apply_list, GuildId) of
		[]-> [];
		[ApplyInfo]->
			{GuildId,ApplyList} = ApplyInfo,
			ApplyList
	end.

get_apply_member_info(MemberId)->
	case ets:lookup(apply_member_list, MemberId) of
		[]-> [];
		[ApplyInfo]->ApplyInfo
	end.

update_apply_info(ApplyInfo)->
	ets:insert(apply_list,ApplyInfo).

update_apply_member_info(MemberInfo)->
	ets:insert(apply_member_list,MemberInfo).
%% ============================================================
%% opt data end
%% ============================================================

add_member_to_guild(GuildId,Roleinfo)->
	Roleid = guild_member_op:get_by_member_item(id,Roleinfo), 
	case ets:lookup(guild_list, GuildId) of
		[]->
			slogger:msg("add_member_to_guild error GuildId ~p [] ~n",[GuildId]);
		[GuildInfo]->
			MemberList = guild_manager_op:get_by_guild_item(members,GuildInfo),
			NewMemberLists = MemberList ++ [Roleid],
			guild_manager_op:update_guild_info(guild_manager_op:set_by_guild_item(members,NewMemberLists,GuildInfo)),
			guild_member_op:update_member_info(Roleinfo)
	end.

check_someone_in_applylist(GuildId,RoleId)->
	case get_apply_info(GuildId) of	
		[]->
			false;
		ApplyList->
			lists:member(RoleId,ApplyList)
	end.

get_someone_apply_info(RoleId)->
	FliterFun = fun({GuildId,MemberList},TempGuildList)->
					case lists:member(RoleId,MemberList) of
						true->
							TempGuildList ++ [GuildId];
						_->
							TempGuildList
					end
				end,
	ets:foldl(FliterFun,[],apply_list). 

proc_get_applicationinfo(RoleId,GuildId)->
	MemberList= get_apply_info(GuildId),
	SendMembers = lists:map(fun(MemberId)->
						case get_apply_member_info(MemberId) of
							[]->
								[];
							{_,Name,Gender,Level,Class}->
								{_,_,_,_,_,_,_,FightForce} = guild_member_op:read_memberinfo_from_remote(MemberId),
								guild_packet:make_roleinfo({MemberId,
															Name,
															Gender,
															Level,
															Class,
															0,0,0,0,[],{{0,0,0},0},0,FightForce})
						end											
					end ,MemberList),
	Message = guild_packet:encode_guild_get_application_s2c(SendMembers),
	role_pos_util:send_to_role_clinet(RoleId,Message).

proc_application_op(RoleId,LeaderId,GuildId,Reject)->
	MemberList = get_apply_info(GuildId),
	case lists:member(RoleId,MemberList) of
		true->
			case guild_member_op:check_someone_in_guild(RoleId) of
				true->	
					remove_someone_applyinfo(RoleId),
					Message = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_ALREADY_IN_GUILD),
					role_pos_util:send_to_role_clinet(LeaderId,Message);
				_->
					if
						Reject =:= 1 ->		
							NewMemberList = lists:delete(RoleId,MemberList),
							update_apply_info({GuildId,NewMemberList}),
							remove_info_from_applymemberinfo(RoleId),	
							guild_spawn_db:set_guild_applyinfo(GuildId,NewMemberList),
							Message = guild_packet:encode_guild_update_apply_result_s2c(GuildId,?GUILD_APPLY_ACCEPT),
							role_pos_util:send_to_role_clinet(RoleId,Message);	
						true->	
							case guild_member_op:proc_add_member(GuildId,RoleId) of
								true->
									remove_someone_applyinfo(RoleId),
									Message = guild_packet:encode_guild_update_apply_result_s2c(GuildId,?GUILD_APPLY_REJECT),
									role_pos_util:send_to_role_clinet(RoleId,Message);
								_->
									nothing
							end
					end
			end;	
		_->
			Message = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_APPLYINFO_ALREADY_OP),
			role_pos_util:send_to_role_clinet(LeaderId,Message),
			nothing
	end.

remove_someone_applyinfo(RoleId)->
	ets:foldl(fun({GuildId,MemberList},_)->
					case lists:member(RoleId,MemberList) of
						true->	
							{Level,Name,Class,Gender,_,_,_,FightForce} = guild_member_op:read_memberinfo_from_remote(RoleId),
							RoleInfo = guild_packet:make_roleinfo({RoleId,
																	Name,
																	Gender,
																	Level,
																	Class,
																	0,0,0,0,[],{{0,0,0},0},0,FightForce}),	
							UpdateApplyMessage = guild_packet:encode_update_guild_update_apply_info_s2c(RoleInfo,?GUILD_DEL_APPLYER),
							guild_manager_op:send_message_to_leaders(GuildId,UpdateApplyMessage),
							NewMemberList = lists:delete(RoleId,MemberList),	
							update_apply_info({GuildId,NewMemberList}),
							guild_spawn_db:set_guild_applyinfo(GuildId,NewMemberList);						
						_->
							nothing
					end
				end,[],apply_list),
	ets:delete(apply_member_list,RoleId).

remove_info_from_applymemberinfo(RoleId)->
	BeCheck = 
			ets:foldl(fun({_,MemberList},Acc)->
					if
						Acc-> 
							Acc;
						true->
							lists:member(RoleId,MemberList)
					end
				end,false,apply_list),
	if
		BeCheck->
			nothing;
		true->
			ets:delete(apply_member_list,RoleId)
	end.

	
proc_add_applymember(GuildId,RoleId,RoleLevel,Role_Name,RoleClass,Gender)->
	IsFull = guild_manager_op:is_posting_full(GuildId,?GUILD_POSE_PREMEMBER),	
	IsApplyFull = (length(get_apply_info(GuildId)) >= ?GUILD_MAX_APPLY_NUM),
	if
		IsFull->
			MessageError = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
			role_pos_util:send_to_role_clinet(RoleId,MessageError),
			ApplyFlag = ?GUILD_MEMBER_FULL;
		IsApplyFull->
			MessageError = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_APPLYNUM_FULL),
			role_pos_util:send_to_role_clinet(RoleId,MessageError),
			ApplyFlag = ?GUILD_APPLY_FULL;
		true->
			MemberList = get_apply_info(GuildId),				
			case check_someone_in_applylist(GuildId,RoleId) of
				true->
					ApplyFlag = ?GUILD_ALREADY_APPLY;
				_->
					{_,_,_,_,_,_,_,FightForce} = guild_member_op:read_memberinfo_from_remote(RoleId),
					ApplyFlag = ?GUILD_ALREADY_APPLY,
					NewMemberList = MemberList ++ [RoleId],
					update_apply_info({GuildId,NewMemberList}),
					guild_spawn_db:set_guild_applyinfo(GuildId,NewMemberList),
					update_apply_member_info({RoleId,Role_Name,Gender,RoleLevel,RoleClass}),
					MessageSuccess = guild_packet:encode_guild_opt_result_s2c(?GUILD_APPLY_SUCCESS),
					role_pos_util:send_to_role_clinet(RoleId,MessageSuccess),
					RoleInfo = guild_packet:make_roleinfo({RoleId,
															Role_Name,
															Gender,
															RoleLevel,
															RoleClass,
															0,0,0,0,[],{{0,0,0},0},0,FightForce}),
					UpdateApplyMessage = guild_packet:encode_update_guild_update_apply_info_s2c(RoleInfo,?GUILD_ADD_APPLYER),
					guild_manager_op:send_message_to_leaders(GuildId,UpdateApplyMessage)
			end
	end,
	Message = guild_packet:encode_update_guild_apply_state_s2c(GuildId,ApplyFlag),
	role_pos_util:send_to_role_clinet(RoleId,Message).