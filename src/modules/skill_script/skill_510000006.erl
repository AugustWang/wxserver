%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(skill_510000006).
-export([on_cast/5,on_check/2]).

%%鍐扮伀閲嶇敓
on_cast(OriTargetId,ManaChanged,CastResult,SkillID,SkillLevel)->
	CreatureInfo = get(creature_info),
	MaxHp = creature_op:get_hpmax_from_creature_info(CreatureInfo),
	NowHp = creature_op:get_life_from_creature_info(CreatureInfo),
	MyId = 	creature_op:get_id_from_creature_info(CreatureInfo),
	TotalDamage = lists:foldl(fun({_,Result,_},TotalDamageTmp)->								
								case Result of
									{_,TargetDamage} ->	
										if
											is_number(TargetDamage)->
												TotalDamageTmp + TargetDamage;
											true->
												TotalDamageTmp
										end;
									_->
										TotalDamageTmp
								end
					end,0,CastResult),
	CanAddHp = - erlang:trunc(TotalDamage*0.2) ,			%%TODO:姣旂巼	
	if
		CanAddHp >= (MaxHp - NowHp)->
			AddHp  =  (MaxHp - NowHp);
		true->
			AddHp  = CanAddHp 			 
	end, 	 		
	{ManaChanged,CastResult ++ [{MyId,{normal,AddHp},[]}] }.

%%true/false
on_check(SkillInfo,OtherInfo)->
	true.