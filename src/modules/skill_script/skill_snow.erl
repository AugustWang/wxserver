%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-12-2
%% Description: TODO: Add description to skill_snow
-module(skill_snow).

%%
%% Include files
%%
-include("effect_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
on_cast(OriTargetId,ManaChanged,CastResult,SkillID,SkillLevel,SingleOrAll)->
	case SingleOrAll of
		?EFFECT_FOR_ALL->
			Msg = activity_packet:encode_play_effects_s2c(SingleOrAll,get(roleid),?EFFECT_TYPE_SNOW),
			role_pos_util:send_to_all_online_clinet(Msg);
		?EFFECT_FOR_AOI->
			Msg = activity_packet:encode_play_effects_s2c(SingleOrAll,get(roleid),?EFFECT_TYPE_LANTERNS),
			RoleIdList = lists:foldl(fun({RoleId,_},Acc)->
											case creature_op:what_creature(RoleId) of
												role->
													[RoleId|Acc];
												_->
													Acc
											end
										end,[],get(aoi_list)),
			role_pos_util:send_to_clinet_list(Msg,[get(roleid)]++RoleIdList);
		_->
			Msg = activity_packet:encode_play_effects_s2c(SingleOrAll,get(roleid),?EFFECT_TYPE_SNOW),
			role_pos_util:send_to_clinet_list(Msg,[get(roleid),OriTargetId])
	end,
	[].

%%true/false
on_check(SkillInfo,TargetInfo)->
	true.
