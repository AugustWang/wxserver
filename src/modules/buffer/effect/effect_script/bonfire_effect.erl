%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-2-10
%% Description: TODO: Add description to bonfire_effect
-module(bonfire_effect).

%%
%% Include files
%%
-export([effect/2]).

-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("sitdown_define.hrl").
-include("map_define.hrl").
-include("effect_define.hrl").
%%
%% Exported Functions
%%
effect(_Value,_SkillInput)->
	CurInfo = get(creature_info),
	RoleID = get_id_from_roleinfo(CurInfo),
	CurLevel = get_level_from_roleinfo(CurInfo),
	case role_level_bonefire_db:get_bonefire_exp_info(CurLevel) of
		[]->
			nothing;
		Info->
			Exp = role_level_bonefire_db:get_bonefire_exp(Info),
			SoulPower = role_level_bonefire_db:get_bonefire_soulpower(Info),
			ExpRateList = get_expratio_from_roleinfo(get(creature_info)),
			case lists:keyfind(?EFFECT_EXP_BONFIRE,1,ExpRateList) of
				false->
					ExpRate = 1;
				{_,AddValue}->
					ExpRate = 1 + AddValue/100
			end,
			case vip_op:get_addition_with_vip(bonfire_addition) of
				0->
					VipAdd = 0;
				Value->
					VipAdd = Value
			end,
			AddExp = trunc(Exp * (ExpRate+VipAdd)),
			AddSoulPower = trunc(SoulPower * (ExpRate+VipAdd)),
			SelfEffUp = [{soulpower,AddExp},{expr,AddSoulPower}],
			SelfEffUpSend = lists:map(fun(OriAttrTmp)-> role_attr:to_role_attribute(OriAttrTmp) end, SelfEffUp),
			Message = role_packet:encode_buff_affect_attr_s2c(RoleID,SelfEffUpSend),
			role_op:send_data_to_gate(Message),
			role_op:obtain_exp(AddExp),
			role_op:obtain_soulpower(AddSoulPower)
	end,
	[].
