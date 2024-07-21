-include("pet_define.hrl").
-record(gm_pet_info,{
					id,
					master,				%%主人
					proto,				%%宠物模板
					level,				%%宠物级别
					name,				%%姓名
					gender,				%%性别
				%	life,				%%当前血量
					%mana,				%%当前蓝量
					quality,			%%品质
				%	exp,				%%经验
				%	totalexp,			%%总经验				
			%		hpmax,				%%最大血量	
			%		mpmax,				%%最大蓝量
					class,				%%类型（平衡，攻击，防御，生命）
					social,            %%阶级
					posx,
					posy,
					path,
					state,				%%状态
					last_cast_time,		%%攻击时间
					%power,				
					hitrate,		
					criticalrate,
					criticaldamage, 		
				%	stamina,
					fighting_force,		%%战斗力
					icon,				%%称号	
					growth_value,%%开始添加属性信息《枫少》
					meleepower,%%近攻
					rangepower,%%远攻
					magicpower,%%魔攻
					meleedefence,%%近防
					rangedefence,%%远防
					magicdefence,%%魔防
					hp,			 %%血量
					dodge,		 %%闪避
					toughness,   %%韧性
					meleeimu,    %%近程减免
					rangeimu,	%%远程减免
					magicimu,   %%魔法减免
					leveluptime_s,%%升级时间
					transform %%属性转换率
		       }).

create_petinfo(PetId,RoleId,Proto,Level,Name,Gender,Social,Quality,
				Class,State,{X,Y},HitRate,CriticalRate,CriticalDamage,Fighting_Force,Icon,Growthvalue,
			Meleepower,Rangepower,Magicpower,Meleedefence,Rangedefence,Magicdefence,Hp,Dodge,Toughness,Meleeimu,Rangeimu,
	 		Magicimu,Leveluptime,Transform)->
	#gm_pet_info{
			id =PetId,
			master = RoleId,
			proto = Proto,
			level = Level,
			name = Name,
			gender = Gender,
			%life = Life,
		%	mana = Mana,
			social=Social,
			quality = Quality,
		%	exp = Exp,
		%	totalexp = TotalExp,
		%	hpmax = Hpmax,
		%	mpmax = Mpmax,
			class = Class,
			last_cast_time={0,0,0},
			path = [],
			state = State,
			posx = X,
			posy = Y,
		%	power = Power,				
			hitrate = HitRate,		
			criticalrate = CriticalRate,
			criticaldamage = CriticalDamage, 		
			%stamina = Stamina,
			fighting_force = Fighting_Force,
			icon = Icon,
			growth_value=Growthvalue,%%开始添加属性信息《枫少》
			meleepower=Meleepower,
			rangepower=Rangepower,
			magicpower=Magicpower,
			meleedefence=Meleedefence,
			rangedefence=Rangedefence,
			magicdefence=Magicdefence,
			hp=Hp,
			dodge=Dodge,
			toughness=Toughness,
			meleeimu=Meleeimu,
			rangeimu=Rangeimu,
			magicimu=Magicimu,
			leveluptime_s=Leveluptime,
			transform=Transform
		}.

get_id_from_petinfo(PetInfo) ->
	#gm_pet_info{id=Id} = PetInfo,
	Id.
set_id_to_petinfo(PetInfo, Id) ->
	PetInfo#gm_pet_info{id=Id}.
	
get_master_from_petinfo(PetInfo) ->
	#gm_pet_info{master=Master} = PetInfo,
	Master.
set_master_to_petinfo(PetInfo, Master) ->
PetInfo#gm_pet_info{master=Master}.

get_pos_from_petinfo(PetInfo) ->
	#gm_pet_info{posx=X} = PetInfo,
	#gm_pet_info{posy=Y} = PetInfo,
	{X,Y}.
set_pos_to_petinfo(PetInfo, {X,Y}) ->
	PetInfo#gm_pet_info{posx=X,posy = Y}.	
	
get_proto_from_petinfo(PetInfo) ->
	#gm_pet_info{proto=Proto} = PetInfo,
	Proto.
set_proto_to_petinfo(PetInfo, Proto) ->
	PetInfo#gm_pet_info{proto=Proto}.
	
get_level_from_petinfo(PetInfo) ->
	#gm_pet_info{level=Level} = PetInfo,
	Level.
set_level_to_petinfo(PetInfo, Level) ->
	PetInfo#gm_pet_info{level=Level}.
	
get_name_from_petinfo(PetInfo) ->
	#gm_pet_info{name=Name} = PetInfo,
	Name.
set_name_to_petinfo(PetInfo,Name) ->
	PetInfo#gm_pet_info{name=Name}.
	
get_gender_from_petinfo(PetInfo) ->
	#gm_pet_info{gender=Gender} = PetInfo,
	Gender.
set_gender_to_petinfo(PetInfo, Gender) ->
	PetInfo#gm_pet_info{gender=Gender}.
	
%get_life_from_petinfo(PetInfo) ->
%	#gm_pet_info{life=Life} = PetInfo,
%	Life.
%set_life_to_petinfo(PetInfo, Life) ->
%	PetInfo#gm_pet_info{life=Life}.
	
%get_mana_from_petinfo(PetInfo) ->
%	#gm_pet_info{mana=Mana} = PetInfo,
%	Mana.
%set_mana_to_petinfo(PetInfo, Mana) ->
%	PetInfo#gm_pet_info{mana=Mana}.
get_social_from_petinfo(PetInfo)->
	#gm_pet_info{social=Social}=PetInfo,
	Social.
set_social_to_petinfo(PetInfo,Social)->
	PetInfo#gm_pet_info{social=Social}.
get_quality_from_petinfo(PetInfo) ->
	#gm_pet_info{quality=Quality} = PetInfo,
	Quality.
set_quality_to_petinfo(PetInfo, Quality) ->
	PetInfo#gm_pet_info{quality=Quality}.
	
%get_exp_from_petinfo(PetInfo) ->
%	#gm_pet_info{exp=Exp} = PetInfo,
	%Exp.
%set_exp_to_petinfo(PetInfo, Exp) ->
%	PetInfo#gm_pet_info{exp=Exp}.

%get_totalexp_from_petinfo(PetInfo) ->
%	#gm_pet_info{totalexp=Exp} = PetInfo,
%	Exp.
%set_totalexp_to_petinfo(PetInfo, Exp) ->
%	PetInfo#gm_pet_info{totalexp=Exp}.	
	
%get_hpmax_from_petinfo(PetInfo) ->
%	#gm_pet_info{hpmax=Hpmax} = PetInfo,
	%Hpmax.
%set_hpmax_to_petinfo(PetInfo, Hpmax) ->
	%PetInfo#gm_pet_info{hpmax=Hpmax}.
	
%get_mpmax_from_petinfo(PetInfo) ->
%	#gm_pet_info{mpmax=Mpmax} = PetInfo,
%	Mpmax.
%set_mpmax_to_petinfo(PetInfo, Mpmax) ->
	%PetInfo#gm_pet_info{mpmax=Mpmax}.
	
get_class_from_petinfo(PetInfo) ->
	#gm_pet_info{class=Class} = PetInfo,
	Class.
set_class_to_petinfo(PetInfo, Class) ->
	PetInfo#gm_pet_info{class=Class}.
	
get_last_cast_time_from_petinfo(PetInfo) ->
	#gm_pet_info{last_cast_time=Last_cast_time} = PetInfo,
	Last_cast_time.
set_last_cast_time_to_petinfo(PetInfo, Last_cast_time) ->
	PetInfo#gm_pet_info{last_cast_time=Last_cast_time}.	

get_state_from_petinfo(PetInfo) ->
	#gm_pet_info{state=State} = PetInfo,
	State.
set_state_to_petinfo(PetInfo, State) ->
	PetInfo#gm_pet_info{state=State}.
	
get_path_from_petinfo(PetInfo) ->
	#gm_pet_info{path=Path} = PetInfo,
	Path.			
set_path_to_petinfo(PetInfo, Path) ->
	PetInfo#gm_pet_info{path=Path}.

%get_power_from_petinfo(PetInfo)->
%	#gm_pet_info{power=Power} = PetInfo,
%	Power.	
%set_power_to_petinfo(PetInfo,Power)->
%	PetInfo#gm_pet_info{power=Power}.

get_hitrate_from_petinfo(PetInfo)->
	#gm_pet_info{hitrate=Hitrate} = PetInfo,
	Hitrate.	
set_hitrate_to_petinfo(PetInfo,Hitrate)->
	PetInfo#gm_pet_info{hitrate=Hitrate}.

get_criticalrate_from_petinfo(PetInfo)->
	#gm_pet_info{criticalrate=Criticalrate} = PetInfo,
	Criticalrate.	
set_criticalrate_to_petinfo(PetInfo,Criticalrate)->
	PetInfo#gm_pet_info{criticalrate=Criticalrate}.

get_criticaldamage_from_petinfo(PetInfo)->
	#gm_pet_info{criticaldamage=Value} = PetInfo,
	Value.	
set_criticaldamage_to_petinfo(PetInfo,Value)->
	PetInfo#gm_pet_info{criticaldamage=Value}.

%get_stamina_from_petinfo(PetInfo)->
%	#gm_pet_info{stamina = Stamina} = PetInfo,
%	Stamina.	
	
%set_stamina_to_petinfo(PetInfo,Stamina)->
	%PetInfo#gm_pet_info{stamina = Stamina}.	
	
get_fighting_force_from_petinfo(PetInfo)->
	#gm_pet_info{fighting_force = Fighting_Force} = PetInfo,
	Fighting_Force.

set_fighting_force_to_petinfo(PetInfo,Fighting_Force)->
	PetInfo#gm_pet_info{fighting_force = Fighting_Force}.
	
get_icon_from_pet_info(PetInfo)->
	#gm_pet_info{icon = Icon} = PetInfo,
	Icon.
	
set_icon_to_petinfo(PetInfo,Icon)->
	PetInfo#gm_pet_info{icon = Icon}.

get_growth_value_from_pet_info(PetInfo)->
	#gm_pet_info{growth_value = Growth_value} = PetInfo,
	Growth_value.
	
set_growth_to_petinfo(PetInfo,Growth_value)->
	PetInfo#gm_pet_info{growth_value = Growth_value}.

get_meleepower_value_from_pet_info(PetInfo)->
	#gm_pet_info{meleepower = MeleePower} = PetInfo,
	MeleePower.
	
set_meleepower_to_petinfo(PetInfo,MeleePower)->
	PetInfo#gm_pet_info{meleepower = MeleePower}.

get_rangepower_value_from_pet_info(PetInfo)->
	#gm_pet_info{rangepower = RangePower} = PetInfo,
	RangePower.
	
set_rangepower_to_petinfo(PetInfo,RangePower)->
	PetInfo#gm_pet_info{rangepower = RangePower}.

get_magicpower_value_from_pet_info(PetInfo)->
	#gm_pet_info{magicpower = MagicPower} = PetInfo,
	MagicPower.
	
set_magicpower_to_petinfo(PetInfo,MagicPower)->
	PetInfo#gm_pet_info{magicpower = MagicPower}.

get_meleedefence_value_from_pet_info(PetInfo)->
	#gm_pet_info{meleedefence = MeleeDefence} = PetInfo,
	MeleeDefence.
	
set_meleedefence_to_petinfo(PetInfo,MeleeDefence)->
	PetInfo#gm_pet_info{magicpower = MeleeDefence}.

get_rangedefence_value_from_pet_info(PetInfo)->
	#gm_pet_info{rangedefence = RangeDefence} = PetInfo,
	RangeDefence.
	
set_rangedefence_to_petinfo(PetInfo,RangeDefence)->
	PetInfo#gm_pet_info{rangedefence = RangeDefence}.

get_magicdefence_value_from_pet_info(PetInfo)->
	#gm_pet_info{magicdefence = MagicDefence} = PetInfo,
	MagicDefence.
	
set_magicdefence_to_petinfo(PetInfo,MagicDefence)->
	PetInfo#gm_pet_info{magicdefence = MagicDefence}.

get_hp_value_from_pet_info(PetInfo)->
	#gm_pet_info{hp = Hp} = PetInfo,
	Hp.

set_hp_to_petinfo(PetInfo,Hp)->
	PetInfo#gm_pet_info{hp = Hp}.

get_dodge_value_from_pet_info(PetInfo)->
	#gm_pet_info{dodge = Dodge} = PetInfo,
	Dodge.
	
set_dodge_to_petinfo(PetInfo,Dodge)->
	PetInfo#gm_pet_info{dodge = Dodge}.

get_toughness_value_from_pet_info(PetInfo)->
	#gm_pet_info{toughness = Toughness} = PetInfo,
	Toughness.
	
set_toughness_to_petinfo(PetInfo,Toughness)->
	PetInfo#gm_pet_info{toughness = Toughness}.

get_meleeimu_value_from_pet_info(PetInfo)->
	#gm_pet_info{meleeimu = Meleeimu} = PetInfo,
	Meleeimu.
	
set_meleeimu_to_petinfo(PetInfo,Meleeimu)->
	PetInfo#gm_pet_info{meleeimu = Meleeimu}.

get_rangeimu_value_from_pet_info(PetInfo)->
	#gm_pet_info{rangeimu = Rangeimu} = PetInfo,
	Rangeimu.
	
set_rangeimu_to_petinfo(PetInfo,Rangeimu)->
	PetInfo#gm_pet_info{rangeimu = Rangeimu}.

get_magicimu_value_from_pet_info(PetInfo)->
	#gm_pet_info{magicimu = Magicimu} = PetInfo,
		Magicimu.
	
set_magicimu_to_petinfo(PetInfo,Magicimu)->
	PetInfo#gm_pet_info{magicimu = Magicimu}.

get_leveluptime_s_value_from_pet_info(PetInfo)->
	#gm_pet_info{leveluptime_s = LevelupTime} = PetInfo,
	LevelupTime.
	
set_leveluptime_s_to_petinfo(PetInfo,LevelUptime)->
	PetInfo#gm_pet_info{leveluptime_s = LevelUptime}.

get_transform_value_from_pet_info(PetInfo)->
	#gm_pet_info{transform = TransForm} = PetInfo,
	TransForm.
	
set_transform_to_petinfo(PetInfo,TransForm)->
	PetInfo#gm_pet_info{transform = TransForm}.


	
-record(my_pet_info,{
			petid,	
		%attr_user_add,			%%玩家属性加点 {攻击,命中,暴击,体质}
			xs,					%%总属性点{攻击,命中,暴击,体质}
		%	talent_add,				%%天赋增加值{攻击,命中,暴击,体质}
			talent,              %%天赋{等级，id，槽位}
			skill,					%%技能
			%remain_attr,			%%剩余点数
			talent_score,			%%天赋分数
			talent_sort,			%%天赋排名	
			quality_value,			%%资质
			quality_up_value,		%%资质提升上限
			happiness,				%%快乐度
			%equipinfo,				%%宠物装备信息
			happinesseff,			%%欢乐度影响值
			trade_lock,				%%交易锁
			changenameflag,			%%是否修改过名字
			lucky                   %%祝福值(宠物进阶需要祝福值，每次进阶失败，祝福值+1，进阶成功祝福值清零)
		}).

get_id_from_mypetinfo(MyPetInfo)->	
	#my_pet_info{petid = Value} = MyPetInfo,
	Value.
set_id_to_mypetinfo(MyPetInfo,Value)->
	MyPetInfo#my_pet_info{petid = Value}.

%get_attr_user_add_from_mypetinfo(MyPetInfo)->	
	%#my_pet_info{attr_user_add = Value} = MyPetInfo,
%	Value.
%set_attr_user_add_to_mypetinfo(MyPetInfo,Value)->
%	MyPetInfo#my_pet_info{attr_user_add = Value}.

%get_attr_from_mypetinfo(MyPetInfo)->	
%	#my_pet_info{attr = Value} = MyPetInfo,
%	Value.
%set_attr_to_mypetinfo(MyPetInfo,Value)->
	%MyPetInfo#my_pet_info{attr = Value}.

%get_talent_add_from_mypetinfo(MyPetInfo)->	
	%#my_pet_info{talent_add = Value} = MyPetInfo,
%	Value.
%set_talent_add_to_mypetinfo(MyPetInfo,Value)->
	%MyPetInfo#my_pet_info{talent_add = Value}.

get_talent_from_mypetinfo(MyPetInfo)->	
	#my_pet_info{talent = Value} = MyPetInfo,
	Value.
set_talent_to_mypetinfo(MyPetInfo,Value)->
	MyPetInfo#my_pet_info{talent = Value}.

get_talent_score_from_mypetinfo(MyPetInfo)->	
	#my_pet_info{talent_score = Value} = MyPetInfo,
	Value.
set_talent_score_to_mypetinfo(MyPetInfo,Value)->
	MyPetInfo#my_pet_info{talent_score = Value}.

set_talent_sort_to_mypetinfo(MyPetInfo,Value)->
	MyPetInfo#my_pet_info{talent_sort = Value}.

get_talent_sort_from_mypetinfo(MyPetInfo)->	
	#my_pet_info{talent_sort = Value} = MyPetInfo,
	Value.

%get_remain_attr_from_mypetinfo(MyPetInfo)->	
	%#my_pet_info{remain_attr = Value} = MyPetInfo,
%Value.
%set_remain_attr_to_mypetinfo(MyPetInfo,Value)->
	%MyPetInfo#my_pet_info{remain_attr = Value}.

get_happiness_from_mypetinfo(PetInfo)->
	#my_pet_info{happiness=Happiness} = PetInfo,
	Happiness.	
set_happiness_to_mypetinfo(PetInfo,Happiness)->
	PetInfo#my_pet_info{happiness=Happiness}.

get_quality_value_from_mypetinfo(PetInfo)->
	#my_pet_info{quality_value=QualityValue} = PetInfo,
	QualityValue.	
set_quality_value_to_mypetinfo(PetInfo,QualityValue)->
	PetInfo#my_pet_info{quality_value=QualityValue}.

get_quality_up_value_from_mypetinfo(PetInfo)->
	#my_pet_info{quality_up_value = Value} = PetInfo,
	Value.	
set_quality_up_value_to_mypetinfo(PetInfo,Value)->
	PetInfo#my_pet_info{quality_up_value = Value}.
	
%get_equipinfo_from_mypetinfo(PetInfo)->	
	%#my_pet_info{equipinfo = Value} = PetInfo,
	%Value.
%set_equipinfo_to_mypetinfo(PetInfo,Value)->
	%PetInfo#my_pet_info{equipinfo = Value}.	

get_happinesseff_from_mypetinfo(PetInfo)->	
	#my_pet_info{happinesseff = Value} = PetInfo,
	Value.
set_happinesseff_to_mypetinfo(PetInfo,Value)->
	PetInfo#my_pet_info{happinesseff = Value}.	

get_trade_lock_from_mypetinfo(PetInfo)->	
	#my_pet_info{trade_lock = Value} = PetInfo,
	Value.
set_trade_lock_to_mypetinfo(PetInfo,Value)->
	PetInfo#my_pet_info{trade_lock = Value}.

get_changenameflag_from_mypetinfo(PetInfo)->	
	#my_pet_info{changenameflag = Value} = PetInfo,
	Value.
set_changenameflag_to_mypetinfo(PetInfo,Value)->
	PetInfo#my_pet_info{changenameflag = Value}.	

get_xisui_from_mypetinfo(PetInfo)->	
	#my_pet_info{xs = Value} = PetInfo,
	Value.
set_xisui_to_mypetinfo(PetInfo,Value)->
	PetInfo#my_pet_info{xs = Value}.	

get_skill_from_mypetinfo(PetInfo)->	
	#my_pet_info{skill = Value} = PetInfo,
	Value.
set_skill_to_mypetinfo(PetInfo,Value)->
	PetInfo#my_pet_info{skill = Value}.	

get_lucky_from_mypetinfo(PetInfo)->	
	#my_pet_info{lucky = Value} = PetInfo,
	Value.
set_lucky_to_mypetinfo(PetInfo,Value)->
	PetInfo#my_pet_info{lucky = Value}.	


%create_mypetinfo(PetId,Quality_Value,Quality_Up_Value,Happiness,
%				Power_Add,HitRate_Add,CriticalRate_Add,Stamina_Add,
%				Power_Attr,HitRate_Attr,CriticalRate_Attr,Stamina_Attr,
%				T_Power_Add,T_HitRate_Add,T_CriticalRate_Add,T_Stamina_Add,
%				T_Power,T_HitRate,T_CriticalRate,T_Stamina,RemainAttr,
%				HappinessEff,TalentScore,TalentSort,TradeLock,Equipinfo,ChangeNameFlag
%				)->
create_mypetinfo(PetId,Xs,Quality_Value,Quality_Up_Value,Happiness,HappinessEff,TalentScore,RankNum,Talent,Skill,TradeLock,ChangeNameFlag,Lucky)->
	#my_pet_info{
			petid = PetId,
			xs=Xs,
			talent=Talent,
			skill=Skill,	%%技能列表{slot,skillid,skilllevel}
			quality_value = Quality_Value,
			quality_up_value = Quality_Up_Value,					
			happiness = Happiness,
			happinesseff = HappinessEff,
			talent_score = TalentScore,
			talent_sort = RankNum,
			trade_lock = TradeLock,
			changenameflag = ChangeNameFlag,
			lucky=Lucky
		
	}.






					