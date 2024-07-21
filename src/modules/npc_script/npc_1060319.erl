%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_1060319).

-export([choose_skill/2]).

-include("data_struct.hrl").
-include("little_garden.hrl").
-include("npc_struct.hrl").

%%return {SkillID,TargetId}
choose_skill(SelfInfo,EnameyInfo)->
	Skills = get_skilllist_from_npcinfo(SelfInfo),
	Life = get_life_from_npcinfo(SelfInfo), 
	MaxHp = get_hpmax_from_npcinfo(SelfInfo),
	%%è¡€é‡å°äº30%,å°æ€ªé‡Œæœ‰æ­»çš„.åˆ™å¬å”¤!
	NpcId1 = ?JIANLING_CALL_1,
	NpcId2 = ?JIANLING_CALL_2,
	case (Life =< MaxHp*0.3) of
		true->
			case lists:keyfind(680000001,1,Skills) of
				{SkillID,SkillLevel,LastCastTime}->
					CoolDown = skill_db:get_cooldown(skill_db:get_skill_info(SkillID,SkillLevel)),					
					case (timer:now_diff(now(),LastCastTime) >= CoolDown*1000) of
						true->
							case (creature_op:is_creature_dead(creature_op:get_creature_info(NpcId1))) or
								(creature_op:is_creature_dead(creature_op:get_creature_info(NpcId2))) of	 
								true->
									{SkillID,creature_op:get_id_from_creature_info(EnameyInfo)};
								_->
									[]
							end;
						_->
							[]
					end;
				_->
					[]
			end;
		false->
			[]
	end.
