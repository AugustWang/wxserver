%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-11-1
%% Description: TODO: Add description to guildbattle_packet
-module(guildbattle_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% API Functions
%%
handle(Message,RolePid)->
	RolePid ! {guildbattle_client_msg,Message}.

make_gbs(Index,{Lid,Hid},Name)->
	#gbs{index= Index,
		 guildlid= Lid,
		 guildhid = Hid,
		 guildname = Name}.

encode_guild_battle_start_s2c()->
	%%io:format("~p ~n",[encode_guild_battle_start_s2c]),
	login_pb:encode_guild_battle_start_s2c(#guild_battle_start_s2c{}).

encode_entry_guild_battle_s2c(Result,Lefttime)->
	%%io:format("~p ~n",[encode_entry_guild_battle_s2c]),
	login_pb:encode_entry_guild_battle_s2c(#entry_guild_battle_s2c{result = Result,lefttime = Lefttime}).

encode_leave_guild_battle_s2c(Result)->
	%%io:format("~p ~n",[encode_leave_guild_battle_s2c]),
	login_pb:encode_leave_guild_battle_s2c(#leave_guild_battle_s2c{result = Result}).

encode_guild_battle_score_init_s2c(GuildList)->
	%%io:format("~p ~p ~n",[encode_guild_battle_score_init_s2c,GuildList]),
	login_pb:encode_guild_battle_score_init_s2c(
	  			#guild_battle_score_init_s2c{guildlist = GuildList}).

encode_guild_battle_score_update_s2c(Index,Score)->
	%%io:format("~p ~p ~n",[encode_guild_battle_score_update_s2c,{Index,Score}]),
	login_pb:encode_guild_battle_score_update_s2c(
	  				#guild_battle_score_update_s2c{index = Index,
												   score = Score}).

encode_guild_battle_status_update_s2c(State,LeftTimes,Index,RoleId,RoleName,RoleClass,RoleGender)->
	%%io:format("~p ~p ~n",[encode_guild_battle_status_update_s2c,{RoleId}]),
	login_pb:encode_guild_battle_status_update_s2c(
	  			#guild_battle_status_update_s2c{
												state = State,
												lefttime = LeftTimes,
												guildindex = Index,
 												roleid  =  RoleId,
  												rolename = RoleName,
												roleclass = RoleClass,
												rolegender = RoleGender}).

encode_guild_battle_result_s2c(Index)->
	%%io:format("~p ~p ~n",[encode_guild_battle_result_s2c,Index]),
	login_pb:encode_guild_battle_result_s2c(
	  			#guild_battle_result_s2c{index = Index}).

encode_guild_battle_stop_s2c()->
	%%io:format("~p ~n",[encode_guild_battle_stop_s2c]),
	login_pb:encode_guild_battle_stop_s2c(#guild_battle_stop_s2c{}).

encode_guild_battle_opt_s2c(Code)->
	login_pb:encode_guild_battle_opt_s2c(#guild_battle_opt_s2c{code = Code}).

encode_guild_battle_ready_s2c(RemainTime)->
	%%io:format("~p ~p ~n",[encode_guild_battle_ready_s2c,{RemainTime}]),
	login_pb:encode_guild_battle_ready_s2c(#guild_battle_ready_s2c{remaintime = RemainTime}).

encode_guild_battle_start_apply_s2c(LeftTime)->
	login_pb:encode_guild_battle_start_apply_s2c(#guild_battle_start_apply_s2c{lefttime = LeftTime}).

encode_guild_battle_stop_apply_s2c()->
	login_pb:encode_guild_battle_stop_apply_s2c(#guild_battle_stop_apply_s2c{}).

%%
%% Local Functions
%%

