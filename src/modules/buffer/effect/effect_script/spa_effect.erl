%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-10-10
%% Description: TODO: Add description to spa_effect
-module(spa_effect).

%%
%% Include files
%%

%%
%% Exported Functions
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
%% API Functions
%%
effect(_Value,_SkillInput)->
	CurInfo = get(creature_info),
	RoleID = get_id_from_roleinfo(CurInfo),
	CurLevel = get_level_from_roleinfo(CurInfo),
	case spa_db:get_spa_exp_info(CurLevel) of
		[]->
			nothing;
		Info->
			Exp = spa_db:get_spa_exp_exp(Info),
			SoulPower = spa_db:get_spa_exp_soulpower(Info),
			SelfEffUp = [{soulpower,SoulPower},{expr,Exp}],
			SelfEffUpSend = lists:map(fun(OriAttrTmp)-> role_attr:to_role_attribute(OriAttrTmp) end, SelfEffUp),
			Message = role_packet:encode_buff_affect_attr_s2c(RoleID,SelfEffUpSend),
			role_op:send_data_to_gate(Message),
	%%		ExpRate = get_expratio_from_roleinfo(get(creature_info)),
			ExpRateList = get_expratio_from_roleinfo(get(creature_info)),
			case lists:keyfind(?EFFECT_EXP_SPA,1,ExpRateList) of
				false->
					ExpRate = 1;
				{_,AddValue}->
					ExpRate = 1 + AddValue/100
			end,
			case vip_op:get_addition_with_vip(spa_addition) of
				0->
					VipAdd = 0;
				Value->
					VipAdd = Value
			end,
			role_op:obtain_exp(trunc(Exp*(ExpRate+VipAdd))),
			role_op:obtain_soulpower(trunc(SoulPower*(ExpRate+VipAdd)))
	end,
	[].

%%
%% Local Functions
%%

