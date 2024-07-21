%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-10-23
%% Description: TODO: Add description to line_util
-module(line_util).

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
-define(MAX_ROLE_COUNT,4294967295).	
get_min_count_of_lines(LineInfos)->
	MinLineInfo = lists:foldl(fun(X,Min)-> 
						  {_,RoleCount}=X,
						  {_,MinRoleCount}=Min,
						  if
							  RoleCount < MinRoleCount -> X;
							  true  -> Min
						  end
				  end,
				  {0,?MAX_ROLE_COUNT}, LineInfos),
	MinLineInfo.

%%
%% Local Functions
%%

