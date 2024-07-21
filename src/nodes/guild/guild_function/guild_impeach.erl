%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-11-19
%% Description: TODO: Add description to guild_impeach
-module(guild_impeach).

%%
%% Include files
%%
-include("guild_define.hrl").
-include("guild_def.hrl").
-include("string_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
%%
%%guild_impeach_list

init()->
	put(guild_impeach_list,[]).

load_db()->
	%%ImpeachInfos = lists:map(fun(ImpeachInfo)->
						%%	GuildId = guild_spawn_db:get_impeach_guildid(ImpeachInfo),
						%%	RoleId = guild_spawn_db:get_impeach_roleid(ImpeachInfo),
						%%	Notice = guild_spawn_db:get_impeach_notice(ImpeachInfo),
						%%	Support = guild_spawn_db:get_impeach_support(ImpeachInfo),
						%%	Opposite = guild_spawn_db:get_impeach_opposite(ImpeachInfo),
						%%	StartTime = guild_spawn_db:get_impeach_starttime(ImpeachInfo),
						%%	VoteIds = guild_spawn_db:get_impeach_voteids(ImpeachInfo),
						%%	{GuildId,RoleId,Notice,Support,Opposite,StartTime,VoteIds}
						%%end,guild_spawn_db:get_allimpeach()),
	ImpeachInfos = guild_spawn_db:get_allimpeach(),
	put(guild_impeach_list,ImpeachInfos).

check_result()->
	Now = now(),
	check_result(Now).

check_result(Now)->
	RemainInfos = 
				lists:foldl(fun(ImpeachInfo,Acc)->	
								StartTime = guild_spawn_db:get_impeach_starttime(ImpeachInfo),
								Diff_S = trunc(timer:now_diff(Now, StartTime)/1000000),
								if
									Diff_S >= ?IMPEACH_TIME_S ->
										%%process result
										process_impeach_result(ImpeachInfo),
										GuildId = guild_spawn_db:get_impeach_guildid(ImpeachInfo),
										guild_spawn_db:del_impeach_info(GuildId),
										notify_all_stop_impeach(GuildId),
										Acc;
									true->
										[ImpeachInfo|Acc]
								end
				 			end, [], get(guild_impeach_list)),
	put(guild_impeach_list,RemainInfos).

%%
%%return true|false
%%
add_impeach(GuildId,RoleId,Notice)->
	ImpeachList = get(guild_impeach_list),
	case lists:keyfind(GuildId,#guild_impeach_info.guildid,ImpeachList) of
		false->
			ImpeachInfo = guild_spawn_db:add_impeach_info(GuildId,RoleId,Notice),
			put(guild_impeach_list,[ImpeachInfo|ImpeachList]),
			notify_all_start_impeach(ImpeachInfo),
			gm_logger_guild:guild_impeach(GuildId,RoleId),
			ResultNo = ?IMPEACH_SUCCESS,
			Return = true;
		_->
			ResultNo = ?OTHER_IMPEACH,
			Return = other_impeach
	end,
	ResultMsg = guild_packet:encode_guild_impeach_result_s2c(ResultNo),
	role_pos_util:send_to_role_clinet(RoleId,ResultMsg),
	Return.


hook_leader_online(GuildId,RoleId)->
	nothing.

hook_role_leave_guild(GuildId,RoleId,RoleName)->
	ImpeachList = get(guild_impeach_list),
	case lists:keyfind(GuildId,#guild_impeach_info.guildid,ImpeachList) of
		false->
			nothing;
		ImpeachInfo->
			case guild_spawn_db:get_impeach_roleid(ImpeachInfo) of
				RoleId->
					guild_spawn_db:del_impeach_info(GuildId),
					NewImpeachList = lists:keydelete(GuildId,#guild_impeach_info.guildid,ImpeachList),
					put(guild_impeach_list,NewImpeachList),
					send_faild_mail(GuildId,RoleName),
					notify_all_stop_impeach(GuildId);
				_->
					nothing
			end
	end.




%%
%%
%%

impeach_vote(GuildId,RoleId,Type)->
	if
		Type =:= ?VOTE_SUPPORT->
			Vote = support;
		Type =:= ?VOTE_OPPOSITE->
			Vote = opposite;		
		true->
			Vote = false
	end,
	case Vote of
		false->
			nothing;
		_->
			vote(GuildId,RoleId,Vote)
	end.

get_impeach_info(GuildId,RoleId)->
	ImpeachList = get(guild_impeach_list),
	case lists:keyfind(GuildId,#guild_impeach_info.guildid,ImpeachList) of
		false->
			nothing;
		ImpeachInfo->
			update_impeach_info_to_someone(ImpeachInfo,RoleId)
	end.

gm_change_impeach_time(GuildId,Time_S)->
	ImpeachList = get(guild_impeach_list),
	case lists:keyfind(GuildId,#guild_impeach_info.guildid,ImpeachList) of
		false->
			nothing;
		ImpeachInfo->
			StartTime = guild_spawn_db:get_impeach_starttime(ImpeachInfo),
			NewStartTime = util:ms_to_now(max(util:now_to_ms(StartTime) - Time_S*1000,0)),
			NewImpeachInfo = ImpeachInfo#guild_impeach_info{starttime = NewStartTime},
			dal:write_rpc(NewImpeachInfo),
			NewImpeachList = lists:keyreplace(GuildId, #guild_impeach_info.guildid,ImpeachList,NewImpeachInfo),
			put(guild_impeach_list,NewImpeachList)
	end.

%%
%%return true|false
%%
check_in_impeach(GuildId,RoleId)->
	ImpeachList = get(guild_impeach_list),
	case lists:keyfind(GuildId,#guild_impeach_info.guildid,ImpeachList) of
		false->
			false;
		ImpeachInfo->
			RoleId =:= guild_spawn_db:get_impeach_roleid(ImpeachInfo)
	end.
	
%%
%% Local Functions
%%

vote(GuildId,RoleId,Vote)->
	ImpeachList = get(guild_impeach_list),
	case lists:keyfind(GuildId, #guild_impeach_info.guildid, ImpeachList) of
		false->
			error;
		ImpeachInfo->
			ImpeacherId = guild_spawn_db:get_impeach_roleid(ImpeachInfo),
			Support = guild_spawn_db:get_impeach_support(ImpeachInfo),
			Opposite = guild_spawn_db:get_impeach_opposite(ImpeachInfo),
			VoteIds = guild_spawn_db:get_impeach_voteids(ImpeachInfo),
			if
				RoleId =:= ImpeacherId ->
					error;
				true->
					case lists:member(RoleId,VoteIds) of
						true->
							error;
						_->
							case Vote of
								support->
									NewSupport = Support + 1,
									NewOpposite = Opposite,
									guild_spawn_db:set_impeach_support(GuildId,NewSupport,RoleId);
								_->
									NewSupport = Support,
									NewOpposite = Opposite + 1,
									guild_spawn_db:set_impeach_opposite(GuildId,NewOpposite,RoleId)
							end,
							gm_logger_guild:guild_impeach_vote(GuildId,RoleId,Vote),
							NewImpeachInfo = ImpeachInfo#guild_impeach_info{support = NewSupport,
																			opposite = NewOpposite,
																			voteids = [RoleId|VoteIds]},
							NewImpeachList = lists:keyreplace(GuildId, #guild_impeach_info.guildid,ImpeachList,NewImpeachInfo),
							put(guild_impeach_list,NewImpeachList),
							%%notify impeach change 
							update_impeach_info_to_someone(NewImpeachInfo,RoleId)
					end
			end
	end.


process_impeach_result(ImpeachInfo)->
	GuildId = guild_spawn_db:get_impeach_guildid(ImpeachInfo),
	RoleId = guild_spawn_db:get_impeach_roleid(ImpeachInfo),
	Support = guild_spawn_db:get_impeach_support(ImpeachInfo),
	Opposite = guild_spawn_db:get_impeach_opposite(ImpeachInfo),
	TotalNum = Support + Opposite,
	if
		TotalNum =:= 0->
			Result = false;
		?IMPEACH_SUCCESS_CHECK(TotalNum,Support)->
			Result = true;
		true->
			Result = false
	end,
	RoleName = guild_manager_op:get_member_name(RoleId),
	if
		Result->
			send_success_mail(GuildId,RoleName),
			guild_manager_op:change_leader_for_impeach(GuildId,RoleId);
		true->
			send_faild_mail(GuildId,RoleName)
	end.

notify_all_start_impeach(ImpeachInfo)->
	GuildId = guild_spawn_db:get_impeach_guildid(ImpeachInfo),
	RoleId = guild_spawn_db:get_impeach_roleid(ImpeachInfo),
	Notice = guild_spawn_db:get_impeach_notice(ImpeachInfo),
	StartImpeachMsg = guild_packet:encode_guild_impeach_info_s2c(RoleId,Notice,0,0,?NOT_VOTE,?IMPEACH_TIME_S),
	guild_manager_op:broad_cast_to_guild_client(GuildId,StartImpeachMsg).

notify_all_stop_impeach(GuildId)->
	StopImpeachMsg = guild_packet:encode_guild_impeach_stop_s2c(),
	guild_manager_op:broad_cast_to_guild_client(GuildId,StopImpeachMsg).

send_faild_mail(GuildId,RoleName)->
	Title = language:get_string(?STR_GUILD_IMPEACH_FAILD_MAIL_TITLE),
	ContextFormat = language:get_string(?STR_GUILD_IMPEACH_FAILD_MAIL_CONTEXT),
	Context = util:sprintf(ContextFormat,[RoleName]),
	guild_manager_op:mail_to_all_member(system,GuildId,Title,Context).	
		
send_success_mail(GuildId,RoleName)->
	TitleFormat = language:get_string(?STR_GUILD_IMPEACH_SUCCESS_MAIL_TITLE),
	Title = util:sprintf(TitleFormat,[RoleName]),
	ContextFormat = language:get_string(?STR_GUILD_IMPEACH_SUCCESS_MAIL_CONTEXT),
	Context = util:sprintf(ContextFormat,[RoleName]),
	guild_manager_op:mail_to_all_member(system,GuildId,Title,Context).

update_impeach_info_to_someone(ImpeachInfo,SendToRoleId)->
	update_impeach_info_to_someone(ImpeachInfo,SendToRoleId,now()).

update_impeach_info_to_someone(ImpeachInfo,SendToRoleId,Now)->
	RoleId = guild_spawn_db:get_impeach_roleid(ImpeachInfo),
	Notice = guild_spawn_db:get_impeach_notice(ImpeachInfo),
	Support = guild_spawn_db:get_impeach_support(ImpeachInfo),
	Opposite = guild_spawn_db:get_impeach_opposite(ImpeachInfo),
	StartTime = guild_spawn_db:get_impeach_starttime(ImpeachInfo),
	VoteIds = guild_spawn_db:get_impeach_voteids(ImpeachInfo),
	LeftTime = erlang:max(0,?IMPEACH_TIME_S - trunc(timer:now_diff(Now, StartTime)/1000000)),
	CheckVote = lists:member(SendToRoleId,VoteIds),
	if
		CheckVote->
			VoteFlag = ?ALREADY_VOTE;
		true->
			VoteFlag = ?NOT_VOTE
	end,
	UpdateImpeachMsg = guild_packet:encode_guild_impeach_info_s2c(RoleId,Notice,Support,Opposite,?NOT_VOTE,LeftTime),
	role_pos_util:send_to_role_clinet(SendToRoleId,UpdateImpeachMsg).