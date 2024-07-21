%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-12-2
%% Description: TODO: Add description to skill_lanterns
-module(skill_lanterns).

%%
%% Include files
%%
-include("common_define.hrl").
-include("effect_define.hrl").
-define(TYPE_MONEY,money).
-define(TYPE_EXP,exp).
-define(TYPE_SOULPOWER,soulpower).
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
on_cast(OriTargetId,ManaChanged,CastResult,SkillID,SkillLevel,SingleOrAll,Rewards)->
	case Rewards of
		[]->
			nothing;
		_->
			lists:foreach(fun({Type,Value})->
								  case Type of
									?TYPE_MONEY->
										role_op:money_change(?MONEY_BOUND_SILVER,Value,got_by_lanterns);
							  		?TYPE_EXP->
								  		role_op:obtain_exp(Value);
							  		?TYPE_SOULPOWER->
								  		role_op:obtain_soulpower(Value);
							  		_->
								  		nothing
						  		end
							end, Rewards)
	end,
	case SingleOrAll of
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
		?EFFECT_FOR_ALL->
			Msg = activity_packet:encode_play_effects_s2c(SingleOrAll,get(roleid),?EFFECT_TYPE_LANTERNS),
			role_pos_util:send_to_all_online_clinet(Msg);
		_->
			Msg = activity_packet:encode_play_effects_s2c(SingleOrAll,get(roleid),?EFFECT_TYPE_LANTERNS),
			role_pos_util:send_to_clinet_list(Msg,[get(roleid),OriTargetId])
	end,
	[].
	
%%true/false
on_check(SkillInfo,TargetInfo)->
	true.




