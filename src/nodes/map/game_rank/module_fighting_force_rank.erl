%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-5
%% Description: TODO: Add description to module_fighting_force_rank
-module(module_fighting_force_rank).

%%
%% Include files
%%
-define(FIGHTING_FORCE_RANK_LIST,fight_force_rank_list).
-define(FIGHTING_FORCE_TOP_LIST,fight_force_top_list).
-define(RANK_FRESH_FIGHTING_FORCE_LIST,rank_fresh_fighting_force_list).
-define(COLLECT_FIGHTING_FORCE_LIST,collect_fighting_force_list).
-include("login_pb.hrl").
-include("game_rank_define.hrl").
%%
%% Exported Functions
%%
-export([load_from_data/1,can_challenge_rank/1,challenge_rank/2,send_rank_list/1,gather/2,refresh_gather/0,is_top/1]).

%%
%% API Functions
%%
load_from_data(Data) ->
	game_rank_collect_util:load_from_data(Data,?FIGHTING_FORCE_RANK_LIST,?FIGHTING_FORCE_TOP_LIST,?RANK_FRESH_FIGHTING_FORCE_LIST,?COLLECT_FIGHTING_FORCE_LIST,?RANK_TYPE_FIGHTING_FORCE).

can_challenge_rank(_)->
	todo.

challenge_rank(_,_) ->
	todo.

is_top(RoleId)->
	game_rank_collect_util:is_top(RoleId,?FIGHTING_FORCE_TOP_LIST).

gather(RoleId,FightForce)->
	game_rank_collect_util:gather(RoleId,FightForce,?FIGHTING_FORCE_RANK_LIST,?FIGHTING_FORCE_TOP_LIST,?RANK_FRESH_FIGHTING_FORCE_LIST,?COLLECT_FIGHTING_FORCE_LIST,?RANK_TYPE_FIGHTING_FORCE).
			
refresh_gather()->
	game_rank_collect_util:refresh_gather(?FIGHTING_FORCE_RANK_LIST,?FIGHTING_FORCE_TOP_LIST,?RANK_FRESH_FIGHTING_FORCE_LIST,?COLLECT_FIGHTING_FORCE_LIST,?RANK_TYPE_FIGHTING_FORCE).

send_rank_list(RoleId) ->
	RankList = get(?FIGHTING_FORCE_RANK_LIST),
	case RankList of
		[] ->
			Param = [];
		_ ->
			Param = lists:map(fun({RoleIdTemp,Infos,_})->
									  case game_rank_manager_op:get_role_baseinfo(RoleIdTemp) of
								  		[] ->
									  		game_rank_packet:make_param([],1,1,1,1,1,[]);
								  		{RoleName,RoleClass,RoleGender,RoleServerId,GuildName}->
							  		  		game_rank_packet:make_param(RoleIdTemp,RoleName,GuildName,RoleClass,RoleServerId,RoleGender,[Infos])
							  		end
								end,RankList)
	end,
	Message = game_rank_packet:encode_rank_fighting_force_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).





























