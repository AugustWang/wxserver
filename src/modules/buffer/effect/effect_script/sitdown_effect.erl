%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(sitdown_effect).
-export([effect/2]).
-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("sitdown_define.hrl").
-include("map_define.hrl").

effect(_Value,_SkillInput)->
	CurInfo = get(creature_info),
	RoleID = get_id_from_roleinfo(CurInfo),
	CurLevel = get_level_from_roleinfo(CurInfo),
	case get_state_from_roleinfo(get(creature_info)) of 
		sitting ->
			CompanoinAddExt =
			case get_companion_role_from_roleinfo(CurInfo) of
				0->
					GlobalRate = global_exp_addition:get_role_exp_addition(sitdown),
					0;
				CompanionRoleId->
					case creature_op:get_creature_info(CompanionRoleId) of
						undefined->
							role_sitdown_op:del_role_from_companion(),
							role_op:self_update_and_broad([{companion_role,0}]),
							GlobalRate = global_exp_addition:get_role_exp_addition(sitdown),
							0;
						CompanionRoleInfo->
							BaseCheck = 
							(get_companion_role_from_roleinfo(CompanionRoleInfo) =:= RoleID) 
							and (get_state_from_roleinfo(CompanionRoleInfo)=:=sitting),
							if
								BaseCheck->
									GlobalRate = global_exp_addition:get_role_exp_addition(companion_sitdown),
									case mapop:is_companion_addation_pos(get_pos_from_roleinfo(CurInfo),get(map_db)) of
										true->
											?COMPANION_ADD_EXT+?COMPANION_ADD_POSITION_EXT;
										_->
											?COMPANION_ADD_EXT
									end;
								true->
									role_sitdown_op:del_role_from_companion(),
									role_op:self_update_and_broad([{companion_role,0}]),
									GlobalRate = global_exp_addition:get_role_exp_addition(sitdown),
									0
							end
					end
			end,
			case vip_op:get_addition_with_vip(sitdown_addition) of
				0->
					VipAdd = 0;
				Value->
					VipAdd = Value
			end,
			EffectInfo = role_level_sitdown_effect_db:get_info(CurLevel),
			AddExp = trunc(role_level_sitdown_effect_db:get_exp(EffectInfo)*(1+CompanoinAddExt+GlobalRate+VipAdd)),
			AddHpPerCent = role_level_sitdown_effect_db:get_hppercent(EffectInfo),
			AddMpPerCent = role_level_sitdown_effect_db:get_mppercent(EffectInfo),
			AddSoulPower = trunc(role_level_sitdown_effect_db:get_soulpower(EffectInfo)*(1+CompanoinAddExt+VipAdd)),
			AddZhenQi = role_level_sitdown_effect_db:get_zhenqi(EffectInfo),
			%%Hp			
			HPMax  = get_hpmax_from_roleinfo(CurInfo),
			HPNow = get_life_from_roleinfo(CurInfo),
			AddHp = trunc((AddHpPerCent/100)*HPMax),
			HpNew = erlang:min(AddHp + HPNow,HPMax),
			BufferHpValue = HpNew - HPNow,
			%%Mp
			MpMax  = get_mpmax_from_roleinfo(CurInfo),
			MpNow = get_mana_from_roleinfo(CurInfo),
			AddMp = trunc((AddMpPerCent/100)*MpMax),
			MpNew = erlang:min(AddMp + MpNow,MpMax),
			BufferMpValue = MpNew - MpNow,		
			MpNew = erlang:min(AddMp + MpNow,MpMax),
			%%no role_op:update_role_info done in other
			%%todo AddZhenQi
			if
				BufferHpValue=/=0->
					HpCurUp = [{hp,HpNew}],
					HpEffUp = [{hp,BufferHpValue}];
				true->
					HpCurUp = [],HpEffUp = []
			end,
			if
				BufferMpValue=/=0->
					MpCurUp = [{mp,MpNew}],
					MpEffUp = [{mp,BufferMpValue}];
				true->
					MpCurUp = [],MpEffUp = []
			end,
			SelfCurUp = MpCurUp ++ HpCurUp,  
			SelfEffUp = MpEffUp ++ HpEffUp ++ [{soulpower,AddSoulPower},{expr,AddExp}],
			%%1.set value
			put(creature_info, set_mana_to_roleinfo(get(creature_info), MpNew)),
			put(creature_info, set_life_to_roleinfo(get(creature_info), HpNew)),
			%%2.broad effect first
			SelfEffUpSend = lists:map(fun(OriAttrTmp)-> role_attr:to_role_attribute(OriAttrTmp) end, SelfEffUp),
			Message = role_packet:encode_buff_affect_attr_s2c(RoleID,SelfEffUpSend),
			role_op:send_data_to_gate(Message ),
%%			role_op:broadcast_message_to_aoi_client(Message),  not send to aoi
			%%3.broad mp hp update
			role_op:self_update_and_broad(SelfCurUp),
			%%get exp,soulpower and broad
			role_op:obtain_exp(AddExp),
			role_op:obtain_soulpower(AddSoulPower),			
			[];	
		_->
			remove
	end.
