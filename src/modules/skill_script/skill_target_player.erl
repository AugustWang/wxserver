%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-2-2
%% Description: TODO: Add description to skill_target_player
-module(skill_target_player).

-export([on_cast/5,on_check/2]).
%%
%% Include files
%%

%%
%% Exported Functions
%%

%%
%% API Functions
%%
on_cast(OriTargetId,ManaChanged,CastResult,SkillID,SkillLevel)->
	{ManaChanged,CastResult}.


on_check(SkillInfo,OtherInfo)->
	TargetId = creature_op:get_id_from_creature_info(OtherInfo),			
	case creature_op:what_creature(TargetId) of
		role->
			true;
		_->
			false
	end.
	
%%
%% Local Functions
%%

