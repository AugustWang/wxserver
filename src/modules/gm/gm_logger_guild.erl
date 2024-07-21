%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-10-11
%% Description: TODO: Add description to gm_logger_guild
-module(gm_logger_guild).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).
-compile(export_all).
%%
%% API Functions
%%
guild_create(GuildId,GuildName,CreatorId)->
	LineKeyValue = [{"cmd","guild_create"},
					{"guildid",GuildId},
					{"guildname",list_to_binary(mysql_util:escape(GuildName))},
					{"guildcreator",CreatorId}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"guildname",list_to_binary(mysql_util:escape(GuildName))},
					{"guildcreator",CreatorId}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_create, Log),
	gm_msgwrite:write(guild_create,LineKeyValue).

guild_dissolve(GuildId,DissolveRole)->
	LineKeyValue = [{"cmd","guild_dissolve"},
					{"guildid",GuildId},
					{"dissolveid",DissolveRole}
		 ],
	Log = [
		   	{"guildid",GuildId},
					{"dissolveid",DissolveRole}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_dissolve, Log),
	gm_msgwrite:write(guild_dissolve,LineKeyValue).

guild_join_member(GuildId,RoleId)->
	LineKeyValue = [{"cmd","guild_join_member"},
					{"guildid",GuildId},
					{"member",RoleId}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"member",RoleId}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_join_member, Log),
	gm_msgwrite:write(guild_join_member,LineKeyValue).

guild_leave_member(GuildId,RoleId)->
	LineKeyValue = [{"cmd","guild_leave_member"},
					{"guildid",GuildId},
					{"member",RoleId}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"member",RoleId}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_leave_member, Log),
	gm_msgwrite:write(guild_leave_member,LineKeyValue).

guild_facility_begin_level_up(GuildId,FacilityId,CurLevel,RoleId,Job)->
	LineKeyValue = [{"cmd","guild_facility_begin_level_up"},
					{"guildid",GuildId},
					{"facility",FacilityId},
					{"curlevel",CurLevel},
					{"roleid",RoleId},
					{"curjob",Job}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"facility",FacilityId},
					{"curlevel",CurLevel},
					{"roleid",RoleId},
					{"curjob",Job}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_facility_begin_level_up, Log),
	gm_msgwrite:write(guild_facility_begin_level_up,LineKeyValue).

guild_facility_finish_level_up(GuildId,FacilityId,NewLevel)->
	LineKeyValue = [{"cmd","guild_facility_finish_level_up"},
					{"guildid",GuildId},
					{"facility",FacilityId},
					{"newlevel",NewLevel}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"facility",FacilityId},
					{"newlevel",NewLevel}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_facility_finish_level_up, Log),
	gm_msgwrite:write(guild_facility_finish_level_up,LineKeyValue).


guild_facility_speed(GuildId,FacilityId,RoleId,Job,Type,BeforLeftTime,AfterLeftTime)->
	LineKeyValue = [{"cmd","guild_facility_speed"},
					{"guildid",GuildId},
					{"facility",FacilityId},
					{"roleid",RoleId},
					{"curjob",Job},
					{"type",Type},
					{"beforelefttime",BeforLeftTime},
					{"afterlefttime",AfterLeftTime}
		 ],
	Log = [
		  	{"guildid",GuildId},
					{"facility",FacilityId},
					{"roleid",RoleId},
					{"curjob",Job},
					{"type",Type},
					{"beforelefttime",BeforLeftTime},
					{"afterlefttime",AfterLeftTime}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_facility_speed, Log),
	gm_msgwrite:write(guild_facility_speed,LineKeyValue).

guild_facility_required(GuildId,FacilityId,Contribution,RoleId,Job)->
	LineKeyValue = [{"cmd","guild_facility_required"},
					{"guildid",GuildId},
					{"facility",FacilityId},
					{"contribution",Contribution},
					{"roleid",RoleId},
					{"curjob",Job}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"facility",FacilityId},
					{"contribution",Contribution},
					{"roleid",RoleId},
					{"curjob",Job}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_facility_required, Log),
	gm_msgwrite:write(guild_facility_required,LineKeyValue).

guild_contribute(GuildId,RoleId,Contribute)->
	LineKeyValue = [{"cmd","guild_contribute"},
					{"guildid",GuildId},
					{"contribute",Contribute},
					{"roleid",RoleId}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"contribute",Contribute},
					{"roleid",RoleId}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_contribute, Log),
	gm_msgwrite:write(guild_contribute,LineKeyValue).

guild_set_leader(GuildId,RoleId,NewLeaderId)->
	LineKeyValue = [{"cmd","guild_set_leader"},
					{"guildid",GuildId},
					{"roleid",RoleId},
					{"newleader",NewLeaderId}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"roleid",RoleId},
					{"newleader",NewLeaderId}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_set_leader, Log),
	gm_msgwrite:write(guild_set_leader,LineKeyValue).

guild_authrity_change(GuildId,ActionRole,RoleId,OldAuthrity,NewAuthrity)->
	LineKeyValue = [{"cmd","guild_authrity_change"},
					{"guildid",GuildId},
					{"action_roleid",ActionRole},
					{"target_roleid",RoleId},
					{"oldauthrity",OldAuthrity},
					{"newauthrity",NewAuthrity}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"action_roleid",ActionRole},
					{"target_roleid",RoleId},
					{"oldauthrity",OldAuthrity},
					{"newauthrity",NewAuthrity}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_authrity_change, Log),
	gm_msgwrite:write(guild_authrity_change,LineKeyValue).

guild_notice_change(GuildId,ActionRole,NewNotice)->
	LineKeyValue = [{"cmd","guild_notice_change"},
					{"guildid",GuildId},
					{"action_roleid",ActionRole},
					{"notice",NewNotice}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"action_roleid",ActionRole},
					{"notice",NewNotice}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_notice_change, Log),
	gm_msgwrite:write(guild_notice_change,LineKeyValue).
%%no need
guild_join_required_change(GuildId,ActionRole,RequiredLevel)->
	LineKeyValue = [{"cmd","guild_join_required_change"},
					{"guildid",GuildId},
					{"action_roleid",ActionRole},
					{"require_level",RequiredLevel}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"action_roleid",ActionRole},
					{"require_level",RequiredLevel}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_join_required_change, Log),
	gm_msgwrite:write(guild_join_required_change,LineKeyValue).


guild_money_change(GuildId,NewCount,ChangeCount,Type)->
	LineKeyValue = [{"cmd","guild_money_change"},
					{"guildid",GuildId},
					{"newcount",NewCount},
					{"changecount",ChangeCount},
					{"type",Type}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"newcount",NewCount},
					{"changecount",ChangeCount},
					{"type",Type}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_money_change, Log),
	gm_msgwrite:write(guild_money_change,LineKeyValue).

guildbattle_check(GuildId,Index,Type)->
	LineKeyValue = [{"cmd","guildbattle_check_log"},
					{"guildid",GuildId},
					{"index",Index},
					{"type",Type}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"index",Index},
					{"type",Type}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guildbattle_check_log, Log),
	gm_msgwrite:write(guildbattle_check_log,LineKeyValue).

guildbattle_apply(GuildId,RoleId,Type)->
	LineKeyValue = [{"cmd","guildbattle_apply_log"},
					{"guildid",GuildId},
					{"roleid",RoleId},
					{"type",Type}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"roleid",RoleId},
					{"type",Type}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guildbattle_apply_log, Log),
	gm_msgwrite:write(guildbattle_apply_log,LineKeyValue).

guildbattle_result(GuildId,Score,Throne,Type)->
	LineKeyValue = [{"cmd","guildbattle_result_log"},
					{"guildid",GuildId},
					{"score",Score},
					{"throne",Throne},
					{"type",Type}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"score",Score},
					{"throne",Throne},
					{"type",Type}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guildbattle_result_log, Log),
	gm_msgwrite:write(guildbattle_result_log,LineKeyValue).

guildbattle_winner(GuildId,KingId,Type)->
	LineKeyValue = [{"cmd","guildbattle_winner_log"},
					{"guildid",GuildId},
					{"kingid",KingId},
					{"type",Type}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"kingid",KingId},
					{"type",Type}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guildbattle_winner_log, Log),
	gm_msgwrite:write(guildbattle_winner_log,LineKeyValue).

guild_impeach(GuildId,RoleId)->
	LineKeyValue = [{"cmd","guild_impeach_log"},
					{"guildid",GuildId},
					{"roleid",RoleId}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"roleid",RoleId}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_impeach_log, Log),
	gm_msgwrite:write(guild_impeach_log,LineKeyValue).


guild_impeach_vote(GuildId,RoleId,Type)->
	LineKeyValue = [{"cmd","guild_impeach_vote_log"},
					{"guildid",GuildId},
					{"roleid",RoleId},
					{"type",Type}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"roleid",RoleId},
					{"type",Type}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_impeach_vote_log, Log),
	gm_msgwrite:write(guild_impeach_vote_log,LineKeyValue).



%%
%%Type = get | lost
%%
country_leader_change(RoleId,Post,Type)->
	LineKeyValue = [{"cmd","country_leader_change_log"},
					{"roleid",RoleId},
					{"post",Post},
					{"type",Type}
		 ],
	Log = [
		   {"roleid",RoleId},
					{"post",Post},
					{"type",Type}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), country_leader_change_log, Log),
	gm_msgwrite:write(country_leader_change_log,LineKeyValue).

guild_rename(GuildId,NewName)->
	LineKeyValue = [{"cmd","guild_rename_log"},
					{"guildid",GuildId},
					{"newname",NewName}
		 ],
	Log = [
		   {"guildid",GuildId},
					{"newname",NewName}
		   ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), guild_rename_log, Log),
	gm_msgwrite:write(guild_rename_log,LineKeyValue),
	gm_msgwrite_mysql:update_db_buffer("log_guild_create", ["guildname"], 
								[mysql_util:escape(NewName)], 
								"guildid='"++gm_msgwrite_mysql:value_to_list(GuildId)++"'").
	
guild_add_battle_score(GuildId,GbScore,Reason)->
	LineKeyValue = [{"cmd","guild_add_battle_score_log"},
					{"guildId",GuildId},
					{"gbscore",GbScore},
					{"reason",Reason}
		 ],
	Log = [
		   {"guildId",GuildId},
					{"gbscore",GbScore},
					{"reason",Reason}
		   ],
	stattool:stat(get(roleid), get(pf), get(level), guild_add_battle_score_log, Log),
	gm_msgwrite:write(guild_add_battle_score_log,LineKeyValue).
