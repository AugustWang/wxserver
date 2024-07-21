%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-14
%% Description: TODO: Add description to module_fighter_attack_rank
-module(module_melee_rank).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("game_rank_define.hrl").

-define(MELEE_RANK_LIST,melee_rank_list).
-define(COLLECT_MELEE_LIST,collect_melee_list).
-define(MELEE_TOP_LIST,melee_top_list).
-define(RANK_FRESH_MELEE_LIST,rank_fresh_melee_list).
%%
%% Exported Functions
%%
-export([load_from_data/1,can_challenge_rank/1,challenge_rank/2,send_rank_list/1,gather/2,refresh_gather/0,is_top/1]).

%%
%% API Functions
%%
load_from_data(Data) ->
	game_rank_collect_util:load_from_data(Data,?MELEE_RANK_LIST,?MELEE_TOP_LIST,?RANK_FRESH_MELEE_LIST,?COLLECT_MELEE_LIST,?RANK_TYPE_MELLE_POWER).

%%Return:
%%	true|false
%%Args:
%%	Attack = int
can_challenge_rank(Attack)->
	todo.

%%Return:
%%	ok|failed
%%Args:
%%	RoleId
%%	Attack = int
challenge_rank(RoleId,Attack) ->
	todo.

is_top(RoleId)->
	game_rank_collect_util:is_top(RoleId,?MELEE_TOP_LIST).

gather(RoleId,Attack)->
	game_rank_collect_util:gather(RoleId,Attack,?MELEE_RANK_LIST,?MELEE_TOP_LIST,?RANK_FRESH_MELEE_LIST,?COLLECT_MELEE_LIST,?RANK_TYPE_MELLE_POWER).

refresh_gather()->
	game_rank_collect_util:refresh_gather(?MELEE_RANK_LIST,?MELEE_TOP_LIST,?RANK_FRESH_MELEE_LIST,?COLLECT_MELEE_LIST,[]).

send_rank_list(RoleId) ->
	Param = game_rank_collect_util:send_rank_list(RoleId,?MELEE_RANK_LIST),
	Message = game_rank_packet:encode_rank_melee_power_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).