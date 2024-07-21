%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-11
%% Description: TODO: Add description to active_board_util
-module(active_board_util).

%%
%% Include files
%%
-include("active_board_define.hrl").
%%
%% Exported Functions
%%
-export([get_reward_type/1]).

%%Fun:
%%	make reward time
%%return:
%%	Type = int
get_reward_type(RoleLevel)->
	if
		(RoleLevel=<49)->
			?CONTINUOUS_1;
		(RoleLevel>=50) and (RoleLevel=<69)->
			?CONTINUOUS_2;
		(RoleLevel>=70) and (RoleLevel=<89)->
			?CONTINUOUS_3;
		(RoleLevel>=90)->
			?CONTINUOUS_4;
		true->
			0	
	end.



