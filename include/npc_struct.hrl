%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NPC 信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(gm_npc_info, {id, pid, pos, name,faction, 
					 runspeed,speed, life, path, state, level
					 ,mana,commoncool,
					 	extra_states,		%%buff状态
						npcflags,			%%npc类型
						templateid,			%%模板id
						hpmax,		
		       			mpmax,
						displayid,			%%显示
						attacktype,			%%攻击类型
						power,				%%攻击力
						touchred,			%%染红～～～！
						immunes,			%%免疫{近，远，魔}
						hitrate,			%%命中
						dodge,				%%闪避
						criticalrate,		%%暴击
						criticaldamage,		%%暴击伤害
						toughness,			%%韧性
						debuffimmunes,		%%debuff免疫
						skilllist,			%%技能[]
						exp,				%%携带经验
						minsilver,			%%携带金钱
						maxsilver,
						defenses,			%%防御力{近，远，魔}
						hatredratio,		%%TODO		
						script_hatred,		%%仇恨函数
						script_skill,		%%技能释放脚本
						acc_quest_list,
						com_quest_list,
						%%2010.9.20
						buffer,
						battle_state,		%%战场状态
						%%仇恨列表
						hatred_list,
						back_hatred_list
					 }).
		       
create_npcinfo(Id,Pid,Pos,Name,Faction,Speed,Life,Path,State,Level,
					Mana,Commoncool,Extra_states,Npcflags,Templateid,Hpmax,Mpmax,
					Displayid,Attacktype,Power,Touchred,Immunes,Hitrate,Dodge,Criticalrate,Criticaldamage,
					Toughness,Debuffimmunes,Skilllist,Exp,Minsilver,Maxsilver,Defenses,Hatredratio,
					Script_hatred,Script_skill,Acc_quest_list,Com_quest_list,Buffer) ->
	#gm_npc_info{
		id = Id, 
		pid = Pid, 
		pos = Pos, 
		name = Name,
		faction = Faction, 
		speed = Speed, 
		life = Life, 
		path = Path, 
		state = State, 
		level = Level,
		mana = Mana,
		commoncool = Commoncool,
		extra_states = Extra_states,
		npcflags = Npcflags,
		templateid = Templateid,
		hpmax = Hpmax,		
		mpmax = Mpmax,
		displayid = Displayid,
		attacktype = Attacktype,
		power = Power,
		touchred = Touchred,
		immunes = Immunes,
		hitrate = Hitrate,
		dodge = Dodge,
		criticalrate = Criticalrate,
		criticaldamage = Criticaldamage,
		toughness = Toughness,
		debuffimmunes = Debuffimmunes,
		skilllist = Skilllist,
		exp = Exp,			
		minsilver = Minsilver,	
		maxsilver = Maxsilver,
		defenses = Defenses,		
		hatredratio = Hatredratio,		
		script_hatred = Script_hatred,		
		script_skill = Script_skill,		
		acc_quest_list = Acc_quest_list,
		com_quest_list = Com_quest_list,
		buffer = Buffer,
		battle_state = 0,
		hatred_list = [],
		back_hatred_list = []
		}.

set_id_to_npcinfo(NpcInfo, Id) ->
	NpcInfo#gm_npc_info{id=Id}.
get_id_from_npcinfo(NpcInfo) ->
	#gm_npc_info{id=Id} = NpcInfo,
	Id.
	
set_templateid_to_npcinfo(NpcInfo, Id) ->
	NpcInfo#gm_npc_info{templateid=Id}.
get_templateid_from_npcinfo(NpcInfo) ->
	#gm_npc_info{templateid=Id} = NpcInfo,
	Id.	
			     			
set_hpmax_to_npcinfo(NpcInfo, Hpmax) ->
	NpcInfo#gm_npc_info{hpmax=Hpmax}.
get_hpmax_from_npcinfo(NpcInfo) ->
	#gm_npc_info{hpmax=Hpmax} = NpcInfo,
	Hpmax.

set_mpmax_to_npcinfo(NpcInfo, Mpmax) ->
	NpcInfo#gm_npc_info{mpmax=Mpmax}.
get_mpmax_from_npcinfo(NpcInfo) ->
	#gm_npc_info{mpmax=Mpmax} = NpcInfo,
	Mpmax.

set_pid_to_npcinfo(NpcInfo, Pid) ->
	NpcInfo#gm_npc_info{pid=Pid}.
get_pid_from_npcinfo(NpcInfo) ->
	#gm_npc_info{pid=Pid} = NpcInfo,
	Pid.

set_pos_to_npcinfo(NpcInfo, Pos) ->
	NpcInfo#gm_npc_info{pos=Pos}.
get_pos_from_npcinfo(NpcInfo) ->
	#gm_npc_info{pos=Pos} = NpcInfo,
	Pos.
	
set_speed_to_npcinfo(NpcInfo, Speed) ->
	NpcInfo#gm_npc_info{speed=Speed}.
get_speed_from_npcinfo(NpcInfo) ->
	#gm_npc_info{speed=Speed} = NpcInfo,
	Speed.

set_life_to_npcinfo(NpcInfo, Life) ->
	NpcInfo#gm_npc_info{life=Life}.
get_life_from_npcinfo(NpcInfo)  ->
	#gm_npc_info{life=Life} = NpcInfo,	
	Life.

set_faction_to_npcinfo(NpcInfo, Faction)  ->
	NpcInfo#gm_npc_info{faction=Faction}.
get_faction_from_npcinfo(NpcInfo) ->
	#gm_npc_info{faction=Faction} = NpcInfo,
	Faction.

set_name_to_npcinfo(NpcInfo, Name) ->
	NpcInfo#gm_npc_info{name=Name}.
get_name_from_npcinfo(NpcInfo) ->
	#gm_npc_info{name=Name} = NpcInfo,
	Name.

set_path_to_npcinfo(NpcInfo, Path) ->
	NpcInfo#gm_npc_info{path=Path}.
get_path_from_npcinfo(NpcInfo) ->
	#gm_npc_info{path=Path} = NpcInfo,
	Path.

set_state_to_npcinfo(NpcInfo, State) ->
	NpcInfo#gm_npc_info{state=State}.
get_state_from_npcinfo(NpcInfo) ->
	#gm_npc_info{state=State} = NpcInfo,
	State.

get_level_from_npcinfo(NpcInfo) ->
	#gm_npc_info{level=Level} = NpcInfo,	
	Level.
set_level_to_npcinfo(NpcInfo, Level) ->
	NpcInfo#gm_npc_info{level=Level}.
	
get_skilllist_from_npcinfo(NpcInfo) ->
	#gm_npc_info{skilllist=Skilllist} = NpcInfo,
	Skilllist.
set_skilllist_to_npcinfo(NpcInfo, SkillList) ->
	NpcInfo#gm_npc_info{skilllist=SkillList}.	
	
get_mana_from_npcinfo(NpcInfo) ->
	#gm_npc_info{mana=Mana} = NpcInfo,
	Mana.
set_mana_to_npcinfo(NpcInfo, Mana) ->
	NpcInfo#gm_npc_info{mana=Mana}.

get_exp_from_npcinfo(NpcInfo) ->
	#gm_npc_info{exp=Exp} = NpcInfo,
	Exp.
set_exp_to_npcinfo(NpcInfo, Exp) ->
	NpcInfo#gm_npc_info{exp=Exp}.	
					
get_minsilver_from_npcinfo(NpcInfo) ->
	#gm_npc_info{minsilver=Money} = NpcInfo,
	Money.
set_minsilver_to_npcinfo(NpcInfo, Money) ->
	NpcInfo#gm_npc_info{minsilver=Money}.	

get_maxsilver_from_npcinfo(NpcInfo) ->
	#gm_npc_info{maxsilver=Money} = NpcInfo,
	Money.
set_maxsilver_to_npcinfo(NpcInfo, Money) ->
	NpcInfo#gm_npc_info{maxsilver=Money}.	
						
get_hatredratio_from_npcinfo(NpcInfo) ->
	#gm_npc_info{hatredratio=Hatredratio} = NpcInfo,
	Hatredratio.
set_hatredratio_to_npcinfo(NpcInfo, Hatredratio) ->
	NpcInfo#gm_npc_info{hatredratio=Hatredratio}.						

get_script_hatred_from_npcinfo(NpcInfo) ->
	#gm_npc_info{script_hatred=Script_hatred} = NpcInfo,
	Script_hatred.
set_script_hatred_to_npcinfo(NpcInfo, Script_hatred) ->
	NpcInfo#gm_npc_info{script_hatred=Script_hatred}.
		
get_script_skill_from_npcinfo(NpcInfo) ->
	#gm_npc_info{script_skill=Script_skill} = NpcInfo,
	Script_skill.
set_script_skill_to_npcinfo(NpcInfo, Script_skill) ->
	NpcInfo#gm_npc_info{script_skill=Script_skill}.	

get_displayid_from_npcinfo(NpcInfo) ->
	#gm_npc_info{displayid=Displayid} = NpcInfo,
	Displayid.
set_displayid_to_npcinfo(NpcInfo, Displayid) ->
	NpcInfo#gm_npc_info{displayid=Displayid}.
												
get_npcflags_from_npcinfo(NpcInfo) ->
	#gm_npc_info{npcflags=Npcflags} = NpcInfo,
	Npcflags.
set_npcflags_to_npcinfo(NpcInfo, Npcflags) ->
	NpcInfo#gm_npc_info{npcflags=Npcflags}.	

get_class_from_npcinfo(NpcInfo) ->
	#gm_npc_info{attacktype=Class} = NpcInfo,
	Class.
set_class_to_npcinfo(NpcInfo, Class) ->
	NpcInfo#gm_npc_info{attacktype=Class}.

get_power_from_npcinfo(NpcInfo) ->
	#gm_npc_info{power=Attack} = NpcInfo,
	Attack.
set_power_to_npcinfo(NpcInfo, Attack) ->
	NpcInfo#gm_npc_info{power=Attack}.

get_commoncool_from_npcinfo(NpcInfo) ->
	#gm_npc_info{commoncool=FZTime} = NpcInfo,
	FZTime.
set_commoncool_to_npcinfo(NpcInfo, FZTime) ->
	NpcInfo#gm_npc_info{commoncool=FZTime}.	
	
get_immunes_from_npcinfo(NpcInfo) ->
	#gm_npc_info{immunes=Immunes} = NpcInfo,
	Immunes.
set_immunes_to_npcinfo(NpcInfo, Immunes) ->
	NpcInfo#gm_npc_info{immunes=Immunes}.
	
get_hitrate_from_npcinfo(NpcInfo) ->
	#gm_npc_info{hitrate=Hitrate} = NpcInfo,
	Hitrate.
set_hitrate_to_npcinfo(NpcInfo, Hitrate) ->
	NpcInfo#gm_npc_info{hitrate=Hitrate}.		
	
get_dodge_from_npcinfo(NpcInfo) ->
	#gm_npc_info{dodge=Missrate} = NpcInfo,
	Missrate.
set_dodge_to_npcinfo(NpcInfo, Missrate) ->
	NpcInfo#gm_npc_info{dodge=Missrate}.	
	
get_criticalrate_from_npcinfo(NpcInfo) ->
	#gm_npc_info{criticalrate=Criticalrate} = NpcInfo,
	Criticalrate.
set_criticalrate_to_npcinfo(NpcInfo, Criticalrate) ->
	NpcInfo#gm_npc_info{criticalrate=Criticalrate}.
	
get_toughness_from_npcinfo(NpcInfo) ->
	#gm_npc_info{toughness=Toughness} = NpcInfo,
	Toughness.
set_toughness_to_npcinfo(NpcInfo, Toughness) ->
	NpcInfo#gm_npc_info{toughness=Toughness}.
	
get_debuffimmunes_from_npcinfo(NpcInfo) ->
	#gm_npc_info{debuffimmunes=Debuffimmune} = NpcInfo,
	Debuffimmune.
set_debuffimmunes_to_npcinfo(NpcInfo, Debuffimmune) ->
	NpcInfo#gm_npc_info{debuffimmunes=Debuffimmune}.	
	
get_defenses_from_npcinfo(NpcInfo) ->
	#gm_npc_info{defenses=Resistances} = NpcInfo,
	Resistances.
set_defenses_to_npcinfo(NpcInfo, Resistances) ->
	NpcInfo#gm_npc_info{defenses=Resistances}.		

get_criticaldamage_from_npcinfo(NpcInfo) ->
	#gm_npc_info{criticaldamage=Criticaldamage} = NpcInfo,
	Criticaldamage.
set_criticaldamage_to_npcinfo(NpcInfo, Criticaldamage) ->
	NpcInfo#gm_npc_info{criticaldamage=Criticaldamage}.
	
get_touchred_from_npcinfo(NpcInfo) ->
	#gm_npc_info{touchred=Touchred} = NpcInfo,
	Touchred.
set_touchred_to_npcinfo(NpcInfo, Touchred) ->
	NpcInfo#gm_npc_info{touchred=Touchred}.	


set_extra_state_to_npcinfo(NpcInfo, States) ->
	NpcInfo#gm_npc_info{extra_states=States}.
add_extra_state_to_npcinfo(NpcInfo, State) ->
	#gm_npc_info{extra_states=ExtraState} = NpcInfo,
	NpcInfo#gm_npc_info{extra_states=lists:delete(State,ExtraState) ++ [State]}.
get_extra_state_from_npcinfo(NpcInfo) ->
	#gm_npc_info{extra_states=ExtraState} = NpcInfo,
	ExtraState.
remove_extra_state_to_npcinfo(NpcInfo, State) ->
	#gm_npc_info{extra_states=ExtraState} = NpcInfo,
	NpcInfo#gm_npc_info{extra_states=lists:delete(State,ExtraState)}.	

set_acc_quest_list_to_npcinfo(NpcInfo, Acc_quest_list) ->
	NpcInfo#gm_npc_info{acc_quest_list=Acc_quest_list}.
get_acc_quest_list_from_npcinfo(NpcInfo) ->
	#gm_npc_info{acc_quest_list=Acc_quest_list} = NpcInfo,
	Acc_quest_list.
									
set_com_quest_list_to_npcinfo(NpcInfo, Com_quest_list) ->
	NpcInfo#gm_npc_info{com_quest_list=Com_quest_list}.
get_com_quest_list_from_npcinfo(NpcInfo) ->
	#gm_npc_info{com_quest_list=Com_quest_list} = NpcInfo,
	Com_quest_list.

get_buffer_from_npcinfo(NpcInfo) ->
	#gm_npc_info{buffer=Buffer} = NpcInfo,
	Buffer.
set_buffer_to_npcinfo(NpcInfo, Buffer) ->
	NpcInfo#gm_npc_info{buffer=Buffer}.	
		
get_battle_state_from_npcinfo(NpcInfo) ->
	#gm_npc_info{battle_state=Value} = NpcInfo,
	Value.
set_battle_state_to_npcinfo(NpcInfo, Value) ->
	NpcInfo#gm_npc_info{battle_state=Value}.

get_hatred_list_from_npcinfo(NpcInfo)->
	#gm_npc_info{hatred_list=Value} = NpcInfo,
	Value.	
set_hatred_list_to_npcinfo(NpcInfo, Value)->
	NpcInfo#gm_npc_info{hatred_list=Value}.	
		
get_back_hatred_list_from_npcinfo(NpcInfo)->
	#gm_npc_info{back_hatred_list=Value} = NpcInfo,
	Value.	
set_back_hatred_list_to_npcinfo(NpcInfo, Value)->
	NpcInfo#gm_npc_info{back_hatred_list=Value}.
	
		
	