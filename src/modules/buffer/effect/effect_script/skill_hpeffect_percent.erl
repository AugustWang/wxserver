%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-22
%% Description: TODO: Add description to skill_hpeffect_percent
-module(skill_hpeffect_percent).

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
	[{hp,SkillInput*Value/100}].


%%
%% Local Functions
%%

