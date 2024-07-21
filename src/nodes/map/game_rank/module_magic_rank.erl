%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-14
%% Description: TODO: Add description to module_master_rank
-module(module_magic_rank).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("game_rank_define.hrl").

-define(MAGIC_RANK_LIST,magic_rank_list).
-define(COLLECT_MAGIC_LIST,collect_magic_list).
-define(MAGIC_TOP_LIST,magic_top_list).
-define(RANK_FRESH_MAGIC_LIST,rank_fresh_magic_list).
%%
%% Exported Functions
%%
-export([load_from_data/1,can_challenge_rank/1,challenge_rank/2,send_rank_list/1,gather/2,refresh_gather/0,is_top/1]).

%%
%% API Functions
%%
load_from_data(Data) ->
	game_rank_collect_util:load_from_data(Data,?MAGIC_RANK_LIST,?MAGIC_TOP_LIST,?RANK_FRESH_MAGIC_LIST,?COLLECT_MAGIC_LIST,?RANK_TYPE_MAGIC_POWER).

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
	game_rank_collect_util:is_top(RoleId,?MAGIC_TOP_LIST).

gather(RoleId,Attack)->
	game_rank_collect_util:gather(RoleId,Attack,?MAGIC_RANK_LIST,?MAGIC_TOP_LIST,?RANK_FRESH_MAGIC_LIST,?COLLECT_MAGIC_LIST,?RANK_TYPE_MAGIC_POWER).

refresh_gather()->
	game_rank_collect_util:refresh_gather(?MAGIC_RANK_LIST,?MAGIC_TOP_LIST,?RANK_FRESH_MAGIC_LIST,?COLLECT_MAGIC_LIST,[]).

send_rank_list(RoleId) ->
	Param = game_rank_collect_util:send_rank_list(RoleId,?MAGIC_RANK_LIST),
	Message = game_rank_packet:encode_rank_magic_power_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).


















