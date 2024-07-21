%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-11-29
%% Description: TODO: Add description to skill_spirits_eruption
-module(skill_spirits_eruption).
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
	case spiritspower_op:check_state() of
		false->
			{[],[]};
		_->
			%%NewCastResult = lists:foldl(fun({Id,T2,T3},Acc)->
			%%									case creature_op:what_creature(Id) of
			%%										npc->
			%%											[{Id,T2,T3}|Acc];
			%%										_->
			%%											Acc
			%%									end
			%%							   end,[],CastResult),
			spiritspower_op:cleanup(),
			{ManaChanged,CastResult}
	end.


on_check(SkillInfo,OtherInfo)->
	case spiritspower_op:check_state() of
		true->
			TargetId = creature_op:get_id_from_creature_info(OtherInfo),
			MyId = creature_op:get_id_from_creature_info(get(creature_info)),
			if
				TargetId =:= MyId ->
					true;
				true->
					case creature_op:what_creature(TargetId) of
						npc->
							true;
						_->
							false
					end				
			end;
		_->
			false
	end.
	
%%
%% Local Functions
%%

