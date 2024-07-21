%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pet_combat_op).

-compile(export_all).

-include("data_struct.hrl").

-include("common_define.hrl").
-include("skill_define.hrl").
-include("little_garden.hrl").

-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("pet_struct.hrl").

pet_judge(PetInfo,SelfInfo, TargetInfo,SkillInfo)->
	ErrorPvP = pvp_op:can_be_attack(SelfInfo,TargetInfo),
	SelfId = creature_op:get_id_from_creature_info(SelfInfo),
	Otherid = creature_op:get_id_from_creature_info(TargetInfo),
	SelfTargetCheck =  (Otherid =:= SelfId) and combat_op:can_self_be_target(SkillInfo),
	TargetCheck = (not combat_op:is_target_god_for_me(SelfInfo,TargetInfo,SkillInfo)),
	%%只能释放普通攻击
	IsNomalAttack = skill_db:get_type(SkillInfo) =:= ?SKILL_TYPE_NOMAL,
	if
		IsNomalAttack ->			
			case combat_op:is_buff_skill(SkillInfo) or SelfTargetCheck or (ErrorPvP =:= true)  of				%%PVP条件是否符合
				true->
					case SelfTargetCheck or combat_op:is_target_in_range(PetInfo, TargetInfo, SkillInfo) of		%%距离判断
						true->
							case combat_op:is_live(TargetInfo) and TargetCheck of						%% 是否有目标
								true->
									case combat_op:is_enough_mp(PetInfo, SkillInfo) of			%% 是否有足够的Mp
										true->
											true;
										_->
											false%%{error, mp}
									end;		
								false->
									false%%error_target
							end;
						false->
							false%%{error, range}
					end;			
				_->
					false%%{error,ErrorPvP}
			end;
		true->
			false
	end.

%%return {skillid,skilllevel,target}
get_passive_skill_on_attack(SkillID, SkillLevel,PetInfo,RoleId,TargetId)->
	case random_passive_skill(?SKILL_TYPE_PASSIVE_ATTACK,PetInfo,RoleId,TargetId) of
		{[],[],[]}->		%%no need cast other skill
			{SkillID, SkillLevel,TargetId};
		RanResult->
			RanResult
	end.				

get_passive_skill_on_beattack(PetInfo,RoleInfo,TargetInfo)->
	todo.

%%SKILL_TYPE_PASSIVE_DEFENSE/SKILL_TYPE_PASSIVE_ATTACK,return {skillid,skilllevel,target}			
random_passive_skill(Type,PetInfo,RoleId,TargetId)->
	PetId = creature_op:get_id_from_creature_info(PetInfo),
	AllSkill = pet_skill_op:get_pet_bestskillinfo(PetId),			
	RandV = random:uniform(10000),
	{ResultInfo,_} = 
			lists:foldl(fun({SkillID,SkillLevel,CastTime},{{SkillTmp,SkillLevelTmp,TargetIdTmp},LastRandV})->
				if
					SkillTmp =/=[]->	%%got it
						{{SkillTmp,SkillLevelTmp,TargetIdTmp},LastRandV};
					true->
						SkillInfo = skill_db:get_skill_info(SkillID, SkillLevel),
						%%cd,mp
						IsCoolOk = pet_skill_op:is_cooldown_ok(SkillID,SkillLevel,CastTime),
						IsEnoughMp = combat_op:is_enough_mp(PetInfo, SkillInfo),
						case skill_db:get_type(SkillInfo) of
							Type->
								if
									IsCoolOk and IsEnoughMp->
										ThisRate = skill_db:get_rate(SkillInfo) + LastRandV,
										case ((RandV > LastRandV) and (RandV =< LastRandV + ThisRate)) of
											true->  
												case combat_op:is_buff_skill(SkillInfo) of
													true->
														{{SkillID,SkillLevel,RoleId},LastRandV + ThisRate};
													false->
														{{SkillID,SkillLevel,TargetId},LastRandV + ThisRate}
												end;
											false->
												{{[],[],[]},LastRandV + ThisRate}
										end;
									true->
										{{[],[],[]},LastRandV}
								end;
							_->
							 	{{[],[],[]},LastRandV}
						end
				end
			 end, {{[],[],[]},0},AllSkill),
			 ResultInfo.
	
process_pet_instant_attack(PetInfo,RoleInfo,TargetInfo, SkillID, SkillLevel,SkillInfo)->
	proc_pet_skill(PetInfo,RoleInfo,TargetInfo, SkillID, SkillLevel,SkillInfo).

proc_pet_skill(PetInfo,RoleInfo,TargetInfo, SkillID, SkillLevel,SkillInfo)->
	PetId = creature_op:get_id_from_creature_info(PetInfo),
	SelfId = get(roleid),
	Otherid = creature_op:get_id_from_creature_info(TargetInfo),
	case (SelfId =:= Otherid) or combat_op:is_buff_skill(SkillInfo) of
		true->
			  CastResult = combat_op:proc_buff_skill(RoleInfo, TargetInfo, SkillInfo);
		_->
			  CastResult = proc_pet_debuff_skill(PetInfo,TargetInfo, SkillInfo)
	end,
	pet_skill_op:set_casttime(PetId,SkillID,SkillLevel),
	case skill_db:get_script(SkillInfo) of
		[]-> 
			{[], CastResult};
		{SkillScript,Args}->
			case combat_op:exec_beam(SkillScript,on_cast,[CastResult,SkillID,SkillLevel]++Args) of
				{SelfRe,NewCastResult}-> 
					{SelfRe,NewCastResult};
				[]->
					{[], CastResult}
			end
	end.	


proc_pet_debuff_skill(PetInfo, TargetInfo, SkillInfo)->
	TargetID= creature_op:get_id_from_creature_info(TargetInfo),
	case skill_db:get_isaoe(SkillInfo) =:= 1 of
			false ->				%%单体攻击
				{Damage,BuffList} = pet_damage_process(target, PetInfo, TargetInfo, SkillInfo),			
				[{TargetID, Damage, BuffList}];
			true ->					%%群攻伤害,根据施法距离判断是否是以自身为目标的
				TargetNum = skill_db:get_aoe_max_target(SkillInfo),	
				case skill_db:get_max_distance(SkillInfo) of
					0->
						Targets = combat_op:get_target_round(PetInfo, SkillInfo,TargetNum ),
						TargetResult = [];
					_ ->
						Targets = combat_op:get_target_round(TargetInfo, SkillInfo,TargetNum ),
						{TargetDamage,TargetBuffList} = pet_damage_process(target, PetInfo, TargetInfo, SkillInfo),						
						TargetResult = [{TargetID,TargetDamage,TargetBuffList}]
				end,
	 			AoeResult = 
	 				lists:map(fun(OtherInfo) ->
								OtherID = creature_op:get_id_from_creature_info(OtherInfo),								
								{Damage,BuffList} = pet_damage_process(aoe, PetInfo, OtherInfo, SkillInfo),							  									  															  
							  	{OtherID, Damage, BuffList}							  
	 				  end, Targets ),  
	 			TargetResult ++ AoeResult
	 end.


pet_damage_process(Type,PetInfo, TargetInfo, SkillInfo) ->
	combat_op:damage_process(Type,PetInfo, TargetInfo, SkillInfo).	
	
proc_mp_resume(PetInfo,SkillInfo)->
	MP = skill_db:get_cost(SkillInfo),	
	case (MP =:= 0) of 	
		true->			
			[];
		_ -> 			
		%	MaxMp = get_mpmax_from_petinfo(PetInfo),
			%NewMp = erlang:min(get_mana_from_petinfo(PetInfo) + MP,MaxMp),
			NewMp=0,
			[{mp,NewMp}]		
	end.
	
