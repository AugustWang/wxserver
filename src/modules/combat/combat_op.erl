%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : combat_op.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 15 Jul 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(combat_op).

-compile(export_all).

-include("data_struct.hrl").

-include("common_define.hrl").
-include("creature_define.hrl").
-include("skill_define.hrl").
-include("little_garden.hrl").

-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("pet_struct.hrl").

judge(SelfInfo, TargetInfo, SkillID, SkillLevel,SkillInfo) ->
	case target_can_be_cast(SelfInfo,TargetInfo,SkillInfo) of
		true->
			case role_base_check(SelfInfo,SkillID,SkillLevel,SkillInfo) of
				true->
					case is_target_in_range(SelfInfo, TargetInfo, SkillInfo) of		%%璺濈鍒ゆ柇
						true->
							true;
						false->
							range
					end;
				ErrorSelfCheck->
					ErrorSelfCheck
			end;
		TargetBaseCheck->
			TargetBaseCheck
	end.

%%鍙�傜敤浜庣帺瀹舵鏌�
role_base_check(SelfInfo,SkillID,SkillLevel,SkillInfo)->
	case is_cool_time_ok(SkillID, SkillLevel) and is_global_cooltime_ok(SelfInfo,SkillID) of	%% 鏀诲嚮闂撮殧鏄惁缁撴潫
		true->
			CheckSientAndComaFlag = need_check_silentandcoma(SkillInfo),
			case ( (not CheckSientAndComaFlag) or (not is_self_silent(SelfInfo)) or is_normal_attack(SkillID) ) of		%%娌夐粯鍒ゆ柇
				true->	
					%%鏃犳晫涓嶈兘鏀诲嚮
					case (not is_target_god(SelfInfo)) of						%%鏃犳晫鍒ゆ柇
						true->
							case is_enough_mp(SelfInfo, SkillInfo) of			%% 鏄惁鏈夎冻澶熺殑Mp
								true->
									case ((not CheckSientAndComaFlag) or (not is_self_coma(SelfInfo))) of		%%鐪╂檿
										true->
											true;
										false->
											coma
									end;
								_->
									mp
							end;		
						_->
							is_god
					end;														
				_->
					is_silent
			end;
		_->
			cooltime
	end.			

%%鍩烘湰椤规鏌�,鍚屾椂鐢ㄤ簬aoe鐨勬鏌�.
target_can_be_cast(SelfInfo,TargetInfo,SkillInfo) ->
	SelfId = creature_op:get_id_from_creature_info(SelfInfo),
	Otherid = creature_op:get_id_from_creature_info(TargetInfo),
	SelfTargetCheck =  (Otherid =:= SelfId) and can_self_be_target(SkillInfo),
	case is_live(TargetInfo) of
		true->
			case (not is_target_god_for_me(SelfInfo,TargetInfo,SkillInfo)) of
				true->
					case skill_script_check(SkillInfo,TargetInfo) of
						true->
							case pvp_op:can_be_attack(SelfInfo,TargetInfo) of
								true->
									true;
								ErrorPvP->
									case is_buff_skill(SkillInfo) or SelfTargetCheck or is_self_debuff(SkillInfo) of	
										true->
											true;
										_->
											ErrorPvP
									end	
							end;
						_->
							state
					end;	
				_->
					is_god
			end;		
		_->
			error_target
	end.
	
%%鎶�鑳借剼鏈鏌�	
skill_script_check(SkillInfo,OtherInfo)->
	case skill_db:get_script(SkillInfo) of
		[]-> 
			true;
		{SkillScript,_Args}->
			case exec_beam(SkillScript,on_check,[SkillInfo,OtherInfo]) of
				true->
					true;	
				State->	
					State
			end
	end.

process_delay_attack(RoleInfo, TargetID, SkillID, SkillLevel, FlyTime) ->
	SkillInfo = skill_db:get_skill_info(SkillID,SkillLevel),
	SingingTime = skill_db:get_cast_time(SkillInfo),
	Timer = gen_fsm:send_event_after(SingingTime, {sing_complete, TargetID, SkillID, SkillLevel, FlyTime}),
	set_sing_timer(Timer,SkillID).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%							鍚熷敱淇℃伅									%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_sing_timer(Timer,SkillID)->
	put(sing_timer,{Timer,SkillID}).

get_singing_skill()->
	case get(sing_timer) of
		{_,SkillID}->
			SkillID;
		_->
			[]
	end.	

clear_sing_timer()->
	put(sing_timer,[]).
	
cancel_sing_timer()->
	case get(sing_timer) of
		undefined ->
			nothing;
		[]->
			nothing;	
		{Timer,_SkillID}->
			gen_fsm:cancel_timer(Timer),
			clear_sing_timer()					
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%							鍚熷敱淇℃伅缁撴潫								%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

process_instant_attack(CreatureInfo, TargetInfo, SkillID, SkillLevel,SkillInfo) ->
	CastResult = cast_attack(CreatureInfo, TargetInfo, SkillInfo),	
	ManaChanged = special_combat:proc_mp_resume(CreatureInfo,SkillInfo),
	case skill_db:get_script(SkillInfo) of
		[]-> 
			{ManaChanged, CastResult};
		{SkillScript,Args}->
			TargetId = creature_op:get_id_from_creature_info(TargetInfo),			 
			case exec_beam(SkillScript,on_cast,[TargetId,ManaChanged,CastResult,SkillID,SkillLevel]++Args) of
				{SelfRe,NewCastResult}-> 
					{SelfRe,NewCastResult};
				[]->
					{ManaChanged, CastResult}
			end
	end.								 						 

process_sing_complete(RoleInfo, TargetInfo, SkillID, SkillLevel) ->
	clear_sing_timer(),
	SkillInfo = skill_db:get_skill_info(SkillID,SkillLevel),	
	case is_target_in_range(RoleInfo, TargetInfo, SkillInfo) of 
		true ->
			case is_enough_mp(RoleInfo, SkillInfo) of
				true->
					{ok, process_instant_attack(RoleInfo, TargetInfo, SkillID, SkillLevel,SkillInfo)};
				_->
					{error,mp}
			end;		
		false ->
			{error, out_range}
	end.

can_self_be_target(SkillInfo)->
	TargetType = skill_db:get_target_type(SkillInfo),
	if
		(TargetType =:= ?SKILL_TARGET_SELF_ENEMY) or (TargetType =:= ?SKILL_TARGET_ENEMY)->
			skill_db:get_max_distance(SkillInfo) =:= 0;
		true->
			true
	end.	
			

is_buff_skill(SkillInfo)->
	TargetType = skill_db:get_target_type(SkillInfo),
	(TargetType =:= ?SKILL_TARGET_TEAM) or (TargetType =:= ?SKILL_TARGET_SELF).
	
is_self_debuff(SkillInfo)->
	TargetType = skill_db:get_target_type(SkillInfo),
	(TargetType =:= ?SKILL_TARGET_SELF_DEBUFF).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CastResult:[{ID,Damage,BuffList}] BuffList:[{{Buff,Level},immune/hit}]
%%Damage = missing/{critical,CRD}/{normal,Dmg}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cast_attack(CreatureInfo, TargetInfo, SkillInfo) ->
	IsBuffSkill = is_buff_skill(SkillInfo), 
	case IsBuffSkill of
		true ->
			CastResult = proc_buff_skill(CreatureInfo, TargetInfo, SkillInfo);
		false->
			CastResult = proc_debuff_skill(CreatureInfo, TargetInfo, SkillInfo)
	end,
	CastResult.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 绉佹湁鍑芥暟 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%澶勭悊澧炵泭鎶�鑳�%%鏆傛椂鍏ㄩ儴閮藉仛鍒癰uff,鎵�浠ユ澶勮繑鍥�:{ID , recover,BuffList}
proc_buff_skill(CreatureInfo, TargetInfo, SkillInfo)->
	TargetID= creature_op:get_id_from_creature_info(TargetInfo),
	SelfID = creature_op:get_id_from_creature_info(CreatureInfo),
	TargetType = skill_db:get_target_type(SkillInfo),
	case TargetType =:= ?SKILL_TARGET_TEAM of 		%%涓嶇壒娈婂鐞嗚嚜韬殑caster buff
		true ->
			case skill_db:get_isaoe(SkillInfo) =:= 1 of			
					false ->
						[{TargetID,recover,skill_db:get_target_buff(SkillInfo)}];
					true->			
						lists:map(fun(OtherInfo) ->		
									ID = creature_op:get_id_from_creature_info(OtherInfo),		  
									  {ID, recover, skill_db:get_target_buff(SkillInfo)}
			 				  end, get_team_targets(TargetInfo, SkillInfo))			 				  
			 end;
		false ->	%%SKILL_TARGET_SELF,缁欒嚜韬噴鏀剧殑鎶�鑳�,姝ゅTargetID=:=SelfID,
			case skill_db:get_isaoe(SkillInfo) =:= 1 of			
				false ->			%%鍗曚綋鍔犳垚,浣跨敤caster buff
						[{SelfID,recover,skill_db:get_caster_buff(SkillInfo)}];
				true->				%%缇や綋鍔犳垚,闃熷弸浣跨敤target buff,鑷繁caster buff
			 			lists:map(fun(OtherInfo) ->
			 							ID = creature_op:get_id_from_creature_info(OtherInfo),	
		 								case ID =:= SelfID of
			 									true ->{SelfID,recover,skill_db:get_caster_buff(SkillInfo)};				  
											  	_  ->{ID, recover, skill_db:get_target_buff(SkillInfo)}
										end
				 				 end, get_team_targets(CreatureInfo, SkillInfo))	 					
			end
	end.	
									
%%澶勭悊浼ゅ鎶�鑳�
proc_debuff_skill(CreatureInfo, TargetInfo, SkillInfo)->
	TargetID= creature_op:get_id_from_creature_info(TargetInfo),
	SelfID = creature_op:get_id_from_creature_info(CreatureInfo),
	TargetType = skill_db:get_target_type(SkillInfo),
	IsSelfContained = (TargetType =:= ?SKILL_TARGET_SELF_ENEMY),%%濡傛灉浼ゅ鍖呮嫭鑷繁,涓嶈绠梞iss鍜屾毚鍑�,璁＄畻self浼ゅ鍜岄噴鏀捐�卋uff
	case IsSelfContained of
		true ->					
%%			SelfResult1 = [{{normal,calculate_normal_damage(self,CreatureInfo, TargetInfo,SkillInfo)},
%%			skill_db:get_caster_buff(SkillInfo)}],
			SelfDamage1 =	calculate_normal_damage(self,CreatureInfo, TargetInfo,SkillInfo),
			SelfBuffer = skill_db:get_caster_buff(SkillInfo);		
		false ->	
			SelfDamage1 = 0,		
			SelfBuffer = []					 	 				  
	end,
	case skill_db:get_isaoe(SkillInfo) =:= 1 of
			false ->				%%鍗曚綋鏀诲嚮
				{Damage,BuffList} = damage_process(target, CreatureInfo, TargetInfo, SkillInfo),			
				RefectDamage = special_combat:proc_reflect_destory(TargetInfo,Damage),
				if
					((RefectDamage + SelfDamage1)=:=0) and (SelfBuffer =:= [])->
						[{TargetID, Damage, BuffList}];
					true->
						[{TargetID, Damage, BuffList}] ++ [{SelfID,{normal,RefectDamage + SelfDamage1},SelfBuffer}]
				end;		
			true ->					%%缇ゆ敾浼ゅ,鏍规嵁鏂芥硶璺濈鍒ゆ柇鏄惁鏄互鑷韩涓虹洰鏍囩殑
				TargetNum = skill_db:get_aoe_max_target(SkillInfo),	
				case skill_db:get_max_distance(SkillInfo) of
					0->
						Targets = get_target_round(CreatureInfo, SkillInfo,TargetNum ),
						TargetResult = [],
						RefectDamage = 0;
					_ ->
						Targets = get_target_round(TargetInfo, SkillInfo,TargetNum ),
						{TargetDamage,TargetBuffList} = damage_process(target, CreatureInfo, TargetInfo, SkillInfo),						
						TargetResult = [{TargetID,TargetDamage,TargetBuffList}],
						RefectDamage = special_combat:proc_reflect_destory(TargetInfo,TargetDamage) 	
				end,
				if
					((RefectDamage + SelfDamage1)=:=0) and (SelfBuffer =:= [])->
							SelfResult = [];
					true->	
				 			SelfResult = [{SelfID,{normal,RefectDamage + SelfDamage1},SelfBuffer}]
				 end,						
	 			AoeResult = 
	 				lists:map(fun(OtherInfo) ->
%%							  	OtherInfo = creature_op:get_creature_info(ID),
								OtherID = creature_op:get_id_from_creature_info(OtherInfo),								
								{Damage,BuffList} = damage_process(aoe, CreatureInfo, OtherInfo, SkillInfo),							  									  															  
							  	{OtherID, Damage, BuffList}							  
	 				  end, Targets ),  
	 			SelfResult ++ TargetResult ++ AoeResult
	 end.

%%return: {Damage,BuffList}, Damage = missing/{critical,CRD}/{normal,Dmg}
damage_process(Type,CreatureInfo, TargetInfo, SkillInfo) ->		
	pvp_op:on_attack(CreatureInfo,TargetInfo),
	case is_pvp(CreatureInfo, TargetInfo) of
		true->				%%pvp
			{_,Addtoin} = skill_db:get_hit_addition(SkillInfo);
		false->	
			{Addtoin,_} = skill_db:get_hit_addition(SkillInfo)
	end,
	Missing = is_missing(CreatureInfo, TargetInfo,Addtoin),
	Critical = is_critical(CreatureInfo, TargetInfo),
	if
		Missing ->														
			{missing,[]}; 			%%miss鐨勬椂鍊欎笉鍔燽uff
		Critical ->
			{{critical,calculate_critical_damage(Type,CreatureInfo, TargetInfo,SkillInfo)},
										buff_process(CreatureInfo, TargetInfo, SkillInfo)};
		true ->
			%% 鏅�氱殑浼ゅ
			{ {normal,calculate_normal_damage(Type,CreatureInfo, TargetInfo,SkillInfo)},
										buff_process(CreatureInfo, TargetInfo, SkillInfo)}
	end.

buff_process(CreatureInfo, TargetInfo, SkillInfo) ->
	BuffList = skill_db:get_target_buff(SkillInfo),
	lists:map(fun({BuffInfo,_} = FullBuffInfo)->
				  case is_buff_immunes(CreatureInfo,TargetInfo,FullBuffInfo) of 
				  		true->
				  			{BuffInfo,immune};
				  		_->
				  			{BuffInfo,hit}
				  end end,BuffList).

%%澶勭悊鏄惁鍛戒腑,鍙湪璐熼潰buff涓娇鐢�
%%Debuff瀹為檯鍛戒腑鐜�=debuff鑷韩鍛戒腑%*锛�1-绛夌骇宸櫨鍒嗘瘮锛�*锛�1-鐩爣瀵筪ebuff鐨勬姉鎬�%锛�
is_buff_immunes(AttackerInfo, TargetInfo,{{BuffId,BuffLevel},BuffHitRate})->
	AttackerLevel = creature_op:get_level_from_creature_info(AttackerInfo),
	TargetLevel = creature_op:get_level_from_creature_info(TargetInfo),
	DiffLevel =	AttackerLevel - TargetLevel,
	if 
		(DiffLevel > -5) -> 								Factor = 0;	
		(DiffLevel =< -5 )and(DiffLevel > -10)->			Factor = 30;	
		(DiffLevel =< -10)and(DiffLevel > -20)->			Factor = 50;
		(DiffLevel =< -20)and(DiffLevel > -30)->			Factor = 80;
		(DiffLevel =< -30)					->				Factor = 100;
		true -> Factor = 1
	end,
	ImmunesTrupe = creature_op:get_debuffimmunes_from_creature_info(TargetInfo),
	BufferInfo = buffer_db:get_buffer_info(BuffId,BuffLevel),
	Resisttype = buffer_db:get_buffer_resist_type(BufferInfo),
	case (Resisttype >= 1) and (Resisttype =< 5) of
		true ->
				BuuferImmues = erlang:element(Resisttype,ImmunesTrupe);						
		false ->
				BuuferImmues = 0
	end,
	BuffRateEndRate = erlang:trunc(BuffHitRate*(100 - Factor)*(1000 - BuuferImmues)), %%鍩烘暟涓�100	BuffHitRate [0,1000] BuuferImmues [0,1000]
	random:uniform(100*1000*1000) > BuffRateEndRate.

is_missing(AttackerInfo, TargetInfo,Addtoin) ->
	HitValue = (creature_op:get_hitrate_from_creature_info(AttackerInfo) - creature_op:get_dodge_from_creature_info(TargetInfo)) + Addtoin, %% [0,1000]
	RandomRange = erlang:max(HitValue,100),    %% 100/1000 = 10%
	random:uniform(1000) > RandomRange.

is_critical(AttackerInfo, TargetInfo) ->
	CriticalValue = (creature_op:get_criticalrate_from_creature_info(AttackerInfo) - creature_op:get_toughness_from_creature_info(TargetInfo)), %%[0,1000]
	RandomRange = erlang:max(CriticalValue,0),
	random:uniform(1000) =< RandomRange.

%%max(鎶�鑳戒激瀹�=锛堣嚜韬敾鍑诲姏-鐩爣闃插尽鍔涳級*锛�1+娴姩鐧惧垎姣旓級*锛�1-鍏嶇柅/1000锛�*浼ゅ鍊嶆暟(鎶�鑳�) 鑷韩鏀诲嚮鍔�*闅忔満鐧惧垎姣�)
%%-10%<=娴姩鐧惧垎姣�<=10%
%% pve 3%<=闅忔満鐧惧垎姣�<=10% pvp 2%<=闅忔満鐧惧垎姣�<=8% 
%%鍏嶇柅>800鐨勬椂鍊欐寜800璁＄畻 
%%
calculate_normal_damage(Type,AttackerInfo, TargetInfo,SkillInfo) ->
%%	TargetId = creature_op:get_id_from_creature_info(TargetInfo),
%%	AttackerId = creature_op:get_id_from_creature_info(AttackerInfo),
    Attack = creature_op:get_power_from_creature_info(AttackerInfo),
    AttackType = creature_op:get_class_from_creature_info(AttackerInfo),
    DefencesList = creature_op:get_defenses_from_creature_info(TargetInfo),
    ImmunesList  = creature_op:get_immunes_from_creature_info(TargetInfo),
    case Type of
    	aoe -> {SkillRatio,BaseDamage}   = skill_db:get_aoe_target_destroy(SkillInfo);
    	target   -> {SkillRatio,BaseDamage}   = skill_db:get_target_destroy(SkillInfo);
    	self	-> {SkillRatio,BaseDamage}   = skill_db:get_self_destroy(SkillInfo)
    end,
    case AttackType of
    	1 -> {Defence,_,_} = DefencesList,
    		 {Value,_,_}  = ImmunesList,Immune = erlang:min(800,Value);
    	2 -> {_,Defence,_} = DefencesList,
    		 {_,Value,_}  = ImmunesList,Immune = erlang:min(800,Value);
   		3 -> {_,_,Defence} = DefencesList,
   			 {_,_,Value}  = ImmunesList,Immune = erlang:min(800,Value)
   	end,
   	SkillPowerAddtion = skill_db:get_addtion_power(SkillInfo),
   	RealAttack = SkillPowerAddtion + Attack,
   	%% Immune [0,1000]
   	Damage = (RealAttack - Defence)*(90+random:uniform(20))*(1000 - Immune)*SkillRatio/100000 + BaseDamage,
	case is_pvp(AttackerInfo, TargetInfo) of
   		true -> TrueDamage = erlang:trunc(erlang:max(Damage*0.8,util:even_div(RealAttack*(1+random:uniform(7))/100,1)));    %%PVP
   		false->	TrueDamage = erlang:trunc(erlang:max(Damage,util:even_div(RealAttack*(2+random:uniform(8))/100,1)))
   	end,
  	-TrueDamage.

%%max(鎶�鑳芥毚鍑婚�犳垚浼ゅ=銆愶紙1+鏆村嚮浼ゅ%-鐩爣闊ф��%锛�*鏀诲嚮鍔�-鐩爣闃插尽銆�*锛�1+娴姩鐧惧垎姣旓級*锛�1-鍏嶇柅%锛�*浼ゅ鍊嶆暟锛堟妧鑳斤級,鑷韩鏀诲嚮鍔�*闅忔満鐧惧垎姣�)
%%-10%<=娴姩鐧惧垎姣�<=10%
%% pve 3%<=闅忔満鐧惧垎姣�<=10% pvp 2%<=闅忔満鐧惧垎姣�<=8% 
%%鍏嶇柅>800鐨勬椂鍊欐寜800璁＄畻 
%%褰撴毚鍑讳激瀹�%-鐩爣闊ф��%<0鏃舵寜闆剁畻銆�
%%
calculate_critical_damage(Type,AttackerInfo, TargetInfo,SkillInfo) ->
%%	TargetId = creature_op:get_id_from_creature_info(TargetInfo),
%%	AttackerId = creature_op:get_id_from_creature_info(AttackerInfo),
    Critical  = creature_op:get_criticaldamage_from_creature_info(AttackerInfo),
    Toughness = creature_op:get_toughness_from_creature_info(TargetInfo),
    Attack = creature_op:get_power_from_creature_info(AttackerInfo),
    AttackType = creature_op:get_class_from_creature_info(AttackerInfo),
    DefencesList = creature_op:get_defenses_from_creature_info(TargetInfo),
    ImmunesList  = creature_op:get_immunes_from_creature_info(TargetInfo),
    case Type of
    	aoe -> {SkillRatio,BaseDamage}   = skill_db:get_aoe_target_destroy(SkillInfo);
    	target   -> {SkillRatio,BaseDamage}   = skill_db:get_target_destroy(SkillInfo);
    	self	-> {SkillRatio,BaseDamage}   = skill_db:get_self_destroy(SkillInfo)
    end,
    case AttackType of
    	1 -> {Defence,_,_} = DefencesList,
    		 {Value,_,_}  = ImmunesList,Immune = erlang:min(800,Value);
    	2 -> {_,Defence,_} = DefencesList,
    		 {_,Value,_}  = ImmunesList,Immune = erlang:min(800,Value);
   		3 -> {_,_,Defence} = DefencesList,
   			 {_,_,Value}  = ImmunesList,Immune = erlang:min(800,Value)
   	end,
   	SkillPowerAddtion = skill_db:get_addtion_power(SkillInfo),
   	RealAttack = SkillPowerAddtion + Attack,
   	%% Critical,Toughness,Immune [0,1000]
   	Damage = ( ((1000+erlang:max(Critical-Toughness,0))/1000)*RealAttack - Defence )*(90+random:uniform(20))*(1000 - Immune)*SkillRatio/100000 + BaseDamage,
   	case is_pvp(AttackerInfo, TargetInfo) of
   		true -> TrueDamage = erlang:trunc(erlang:max(Damage*0.8,util:even_div(RealAttack*(1+random:uniform(7))/100,1))); 		%%PVP
   		false->	TrueDamage = erlang:trunc(erlang:max(Damage,util:even_div(RealAttack*(2+random:uniform(8))/100,1)))
   	end,
  	-TrueDamage.
	
is_live(CreatureInfo)->
	 not creature_op:is_creature_dead(CreatureInfo).

is_target_god(TargetInfo) when is_record(TargetInfo, gm_pet_info) ->	%%瀹犵墿鏃犳晫
	true;
	
is_target_god(TargetInfo)->	
	(creature_op:get_npcflags_from_creature_info(TargetInfo) > ?CREATURE_MONSTER)
	or
	lists:member(god,creature_op:get_extra_state_from_creature_info(TargetInfo)).
	
is_target_god_for_me(SelfInfo,TargetInfo,_SkillInfo) when (is_record(TargetInfo, gm_role_info) and is_record(SelfInfo, gm_role_info)) ->
	is_target_god(TargetInfo);
is_target_god_for_me(_,TargetInfo,_SkillInfo) when is_record(TargetInfo, gm_pet_info)->	
	is_target_god(TargetInfo);
is_target_god_for_me(SelfInfo,TargetInfo,SkillInfo)->
	case creature_op:get_id_from_creature_info(SelfInfo) =:=  creature_op:get_id_from_creature_info(TargetInfo) of
		true->
			 is_target_god(TargetInfo);
		_->	 
			is_target_god(TargetInfo)			%%瀵规柟鏃犳晫鍒欐棤鏁� 
			or 
			case is_buff_skill(SkillInfo) or is_self_debuff(SkillInfo) of
				true->						%%濡傛灉鏄鐩婃妧鑳芥垨鑰呭鍙嬫柟鐨勫噺鐩婃妧鑳�,鍏崇郴涓嶄负鍙嬪ソ,鍒欏垽瀹氭棤鏁�
					not (creature_op:what_realation(SelfInfo,TargetInfo)=:= friend);
				_->						 	%%濡傛灉涓哄噺鐩婃妧鑳�,鍏崇郴涓嶄负鏁屽,鍒欏垽瀹氭棤鏁�	
					not (creature_op:what_realation(SelfInfo,TargetInfo)=:= enemy)		
			end	
	end.

is_self_silent(SelfInfo)->
	lists:member(silent, creature_op:get_extra_state_from_creature_info(SelfInfo)).

is_self_coma(SelfInfo) ->
	lists:member(coma, creature_op:get_extra_state_from_creature_info(SelfInfo)).
	

need_check_silentandcoma(SkillInfo)->
	skill_db:get_type(SkillInfo) =/= ?SKILL_TYPE_ACTIVE_WITHOUT_CHECK_SILENT.

is_normal_attack(SkillID) ->
	(SkillID =:= ?NARMAL_MAGIC_ATTACK) or (SkillID =:= ?NARMAL_RANGE_ATTACK) or (SkillID =:= ?NARMAL_MELEE_ATTACK).

is_cool_time_ok(SkillID, SkillLevel) ->					%%TODO
	skill_op:is_cooldown_ok(SkillID, SkillLevel).

is_enough_mp(RoleInfo, SkillInfo) ->
	creature_op:get_mana_from_creature_info(RoleInfo) >= -skill_db:get_cost(SkillInfo).
	
is_target_in_range(RoleInfo, TargetInfo, SkillInfo) ->
	Range = skill_db:get_max_distance(SkillInfo),
	if
		Range =:= 0->
			true;
		true->	
			case TargetInfo of
				undefined ->
					false;
				_ ->
					{X1, Y1} = creature_op:get_pos_from_creature_info(RoleInfo),
					{X2, Y2} = creature_op:get_pos_from_creature_info(TargetInfo),
					erlang:max(abs(X1 - X2), abs(Y1 - Y2)) =< Range + ?PATH_POIN_NUMBER*2			%%鏀惧紑涓や釜绉诲姩澶ф牸鐨勬楠�
			end		 
	end.

is_global_cooltime_ok(RoleInfo,SkillID) ->
	case env:get(commoncdswitch,0) of
		0->
			timer:now_diff(timer_center:get_correct_now(),get(last_cast_time)) + 500000 >=  get_commoncool_from_roleinfo(RoleInfo)*1000;	
		1->	
			case is_normal_attack(SkillID) of
				true->
					timer:now_diff(timer_center:get_correct_now(),get(last_nor_cast_time)) >= ?NORMALSKILLCD *1000;
				false->
					timer:now_diff(timer_center:get_correct_now(),get(last_cast_time)) >= ?UNNORMALSKILLCD *1000
			end
	end.

%%杩斿洖鐨勫垪琛ㄤ腑涓嶅寘鎷嚜宸卞拰target
get_target_round(TargetInfo, SkillInfo,Num) ->
	Radius = skill_db:get_aoeradius(SkillInfo),
	TargetId = creature_op:get_id_from_creature_info(TargetInfo),
	Center = creature_op:get_pos_from_creature_info(TargetInfo),	
	SelfInfo = get(creature_info),
	lists:foldl(fun({Id,_},InfosTmp)->
			case erlang:length(InfosTmp) >= Num of
				true->
					InfosTmp;
				_->					
					case creature_op:get_creature_info(Id) of
						undefined->
							InfosTmp;
						CreatureInfo->
							CreaturePos = creature_op:get_pos_from_creature_info(CreatureInfo),	
							CanAttack = util:is_in_range(Center, CreaturePos, Radius) and (TargetId =/= Id) and (target_can_be_cast(SelfInfo ,CreatureInfo,SkillInfo)=:=true),		 								
							if
								CanAttack->
									[CreatureInfo|InfosTmp];
								true->
									InfosTmp
							end
					end
			end
		end,[],get(aoi_list)).
	
%%杩斿洖鍒楄〃鍖呮嫭鑷繁,TODO:鎶�鑳界粰缁勯槦	
get_team_targets(TargetInfo, SkillInfo)->
	SelfInfo = get(creature_info),	
	case is_record(SelfInfo, gm_role_info) of
		true->			%%濡傛灉鏄帺瀹�,閫夋嫨闃熷弸鍜屽弸濂介樀钀�
			MemberInfo = lists:map(fun(ID)->creature_op:get_creature_info(ID) end,group_op:get_members_in_aoi())++creature_op:get_aoi_info_by_realation(SelfInfo,friend);
		_->				%%濡傛灉鏄�墿,鍒欓�夋嫨鍛ㄥ洿鍙嬪ソ闃佃惀
			MemberInfo = creature_op:get_aoi_info_by_realation(SelfInfo,friend)							
	end,
	AoiMembers_Info_With_Self = [get(creature_info)|MemberInfo],	
	Radius = skill_db:get_aoeradius(SkillInfo),
	Center = creature_op:get_pos_from_creature_info(TargetInfo),
	Fun = fun(CreatureInfo) ->
			      CreaturePos = creature_op:get_pos_from_creature_info(CreatureInfo),
			      util:is_in_range(Center, CreaturePos, Radius) and (target_can_be_cast(SelfInfo,CreatureInfo,SkillInfo)=:=true)
	      end,
	[X || X <- AoiMembers_Info_With_Self , Fun(X)].
	
interrupt_state_with_buff(SelfInfo)->
	case creature_op:get_state_from_creature_info(SelfInfo) of
		singing->
			case ( combat_op:is_self_coma(SelfInfo) or combat_op:is_self_silent(SelfInfo) ) of
				true->
					util:send_state_event(self(), {interrupt_by_buff});
				_->
					nothing
			end;
		_->
			nothing
	end.
	
exec_beam(Mod,Fun,Args)->
	try 
		apply(Mod,Fun,Args)
	catch
		_Errno:Reason -> 	
			slogger:msg("Mod ~p Fun ~p ~p ~p~n",[Fun,Fun,Reason,erlang:get_stacktrace()]),
			[]
	end.

%%
%%return true|false
%%
%% pet attack role
%% role attack role
%%
is_pvp(CreatureInfo, TargetInfo)->
	( (is_record(CreatureInfo, gm_role_info)) or (is_record(TargetInfo, gm_pet_info)) ) and 
 	( is_record(TargetInfo, gm_role_info) ).		
			
	
