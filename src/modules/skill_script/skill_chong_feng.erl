%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(skill_chong_feng).
-export([on_cast/5,on_check/2]).

%%true/false
on_check(_,_)->
	role_op:can_move(get(creature_info)).

%%氓聠虏茅聰聥
on_cast(TargetId,ManaChanged,CastResult,SkillID,SkillLevel)->			
	[].