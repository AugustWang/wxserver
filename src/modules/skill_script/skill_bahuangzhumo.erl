%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(skill_bahuangzhumo).
-export([on_cast/5,on_check/2]).
-include("data_struct.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("little_garden.hrl").

on_cast(OriTargetId,ManaChanged,CastResult,SkillID,SkillLevel)->
	ReLen = erlang:length(CastResult),
	case lists:keyfind(mp,1, ManaChanged) of
		false->
			{ManaChanged ++ [{mp,ReLen}],CastResult};
		{mp,OriMana}->
			{lists:keyreplace(mp, 1, ManaChanged, {mp,OriMana+ReLen}),CastResult}
	end.

%%true/false
on_check(SkillInfo,TargetInfo)->
	true.