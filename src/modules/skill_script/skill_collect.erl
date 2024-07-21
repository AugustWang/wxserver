%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-3-19
%% Description: TODO: Add description to skill_especially_collect
-module(skill_collect).
-export([on_cast/5,on_check/2]).
%%
%% Include files
%%
-include("battle_define.hrl").
-include("common_define.hrl").
-include("data_struct.hrl").
-include("npc_struct.hrl").
-include("role_struct.hrl").

on_cast(OriTargetId,ManaChanged,CastResult,SkillID,SkillLevel)->
	{[],[{OriTargetId,{normal,0},[]}]}.

%%true/false
on_check(SkillInfo,TargetInfo)->
	true.