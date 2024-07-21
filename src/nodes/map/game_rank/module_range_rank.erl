%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-14
%% Description: TODO: Add description to module_shooter_rank
-module(module_range_rank).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("game_rank_define.hrl").

-define(RANGE_RANK_LIST,range_rank_list).
-define(COLLECT_RANGE_LIST,collect_range_list).
-define(RANGE_TOP_LIST,range_top_list).
-define(RANK_FRESH_RANGE_LIST,rank_fresh_range_list).
%%
%% Exported Functions
%%
-export([load_from_data/1,can_challenge_rank/1,challenge_rank/2,send_rank_list/1,
		 gather/2,refresh_gather/0,is_top/1]).

%%
%% API Functions
%%
load_from_data(Data) ->
	game_rank_collect_util:load_from_data(Data,?RANGE_RANK_LIST,?RANGE_TOP_LIST,?RANK_FRESH_RANGE_LIST,?COLLECT_RANGE_LIST,?RANK_TYPE_RANGE_POWER).

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
	game_rank_collect_util:is_top(RoleId,?RANGE_TOP_LIST).

gather(RoleId,Attack)->
	game_rank_collect_util:gather(RoleId,Attack,?RANGE_RANK_LIST,?RANGE_TOP_LIST,?RANK_FRESH_RANGE_LIST,?COLLECT_RANGE_LIST,?RANK_TYPE_RANGE_POWER).

refresh_gather()->
	game_rank_collect_util:refresh_gather(?RANGE_RANK_LIST,?RANGE_TOP_LIST,?RANK_FRESH_RANGE_LIST,?COLLECT_RANGE_LIST,[]).

send_rank_list(RoleId) ->
	Param = game_rank_collect_util:send_rank_list(RoleId,?RANGE_RANK_LIST),
	Message = game_rank_packet:encode_rank_range_power_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).









