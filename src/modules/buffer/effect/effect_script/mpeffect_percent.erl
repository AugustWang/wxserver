%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-21
%% Description: TODO: Add description to mpeffect_percent
-module(mpeffect_percent).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([effect/2]).

%%
%% API Functions
%%

effect(Value,SkillInput)->
	if
		Value >= 0 ->
			[{mp,util:even_div(creature_op:get_mpmax_from_creature_info(get(creature_info))*Value,100)}];
		true->
			[{mp,0-util:even_div(creature_op:get_mpmax_from_creature_info(get(creature_info))*(0-Value),100)}]
	end.


%%
%% Local Functions
%%

