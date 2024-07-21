%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pet_util).

-compile(export_all).

-include("game_rank_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("mnesia_table_def.hrl").
-include("pet_struct.hrl").
-include("color_define.hrl").
-include("fighting_force_define.hrl").

	
%% recompute 3d
%%recompute_attr(OriPetInfo)->
%%	{NewQuality,SkillNum,NewSpeed,NewDisPlayId,NewDropRate} = update_quality_and_skillnum(OriPetInfo),
%%	PetInfo1 = OriPetInfo#gm_pet_info{quality = NewQuality,maxskillnum = SkillNum},
%%	{Strength,Intelligence,Agile,Stamina} = get_cur_four_d(PetInfo1),
%%	NewPetInfo = PetInfo1#gm_pet_info{quality = NewQuality,strength = Strength,intelligence = Intelligence,agile = Agile,
%%					stamina = Stamina,move_speed = NewSpeed,displayid = NewDisPlayId,drop_rate = NewDropRate},
%%	pet_op:update_pet_info_all(NewPetInfo),
%%	pet_attr:only_self_update(get_id_from_petinfo(NewPetInfo),
%%		[{strength , Strength},{intelligence , Intelligence},{agile , Agile},{stamina,Stamina},{pet_quality,NewQuality},{pet_skill_num,SkillNum},
%%		{movespeed,NewSpeed},{displayid,NewDisPlayId},{pet_drop_rate,NewDropRate}]).

%%
%%return {Min,Max}
%%
get_adapt_qualityinfo(Quality,QualityInfo)->
	case lists:keyfind(Quality,1,QualityInfo) of
		false->
			slogger:msg("find pet quality info error  ~p ~p ~n",[Quality,QualityInfo]),
			{0,0};
		{_,{Min,Max}}->
			{Min,Max};
		Result->
			slogger:msg("find pet quality info error ~p ~p ~p ~n",[Quality,QualityInfo,Result]),
			{0,0}
	end.

%%
%%return quality
%%
get_adapt_quality(Quality_Up_Value,QualityInfo)->
	lists:foldl(fun({Quality,{Min,Max}},Acc)->
					if
						Acc > 0->
							Acc;
						true->
							case (Min =< Quality_Up_Value) and (Max >= Quality_Up_Value) of
								true->
									Quality;
								_->
									Acc
							end
					end 
				end, 0 ,QualityInfo).

get_happiness_eff(Happiness)->
	EffValue = pet_happiness_db:get_happiness_eff(Happiness),
	EffValue/100.

%%
%%获取所有可分配点数(包含已分配)
%%todo
%%
get_totaluserattr(QualityUpValue,CurLevel)->
	if
		CurLevel < 0->
			0;
		true->
			Growth = pet_growth_db:get_adapt_growth(QualityUpValue),
			%Growth*(CurLevel - 1)				%%枫少修改
			Growth
	end.
%%
%%return {Power_Add,Hitrate_Add,Criticalrate_Add,Stamina_Add} 
%%
%%  value = attr/10*(0.5+qualityvalue/100)
%%		  = attr*(0.5+qualityvalue/100)/10
%%		  = attr*(0.05+qualityvalue/1000)
get_system_attr_add(Level,QualityValue)->
	LevelInfo = pet_level_db:get_info(Level),
	case pet_level_db:get_sysaddattr(LevelInfo) of
		[]->
			slogger:msg("pet_level_db:get_attr error level ~p ~n",[Level]),
			{0,0,0,0,0,0,0,0};
		%{Power,Hitrate,Criticalrate,Stamina}->
		{MeleePower,Rangepower,Magicpower,Hitrate,Meleedefence,Rangedefence,Magicdefence,Dodge,Criticalrate,CriticalDamage,Toughness,Meleeimu,Rangeimu,Magicimu}->
			Factor = 0.05 + QualityValue/1000,
			RetDodge=erlang:round(Dodge*Factor),
			Retmeleeimu=erlang:round(Meleeimu*Factor),
			Retrangeimu=erlang:round(Rangeimu*Factor),
			Retmagicimu=erlang:round(Magicimu*Factor),
			{MeleePower,Rangepower,Magicpower,Meleedefence,Rangedefence,Magicdefence,RetDodge,Hitrate,Criticalrate,CriticalDamage,Toughness,Retmeleeimu,Retrangeimu,Retmagicimu};
		_->
			slogger:msg("pet_level_db:get_attr error level ~p ~n",[Level]),
			{0,0,0,0}
	end.
			
%%
%%return {Power_Add,Hitrate_Add,Criticalrate_Add,Stamina_Add}
%%
compute_attr_add(BornAttr,SystemAddAttr,UserAdd)->
	AttrList = [BornAttr,SystemAddAttr,UserAdd],
	lists:foldl(fun({Power,Hitrate,Criticalrate,Stamina},Acc)->
						{OldPower,OldHitrate,OldCriticalrate,OldStamina} = Acc,
						{OldPower + Power,
						OldHitrate + Hitrate,
						OldCriticalrate + Criticalrate,
						OldStamina + Stamina}
					end,{0,0,0,0},AttrList).

%%
%%return {Power_Add,Hitrate_Add,Criticalrate_Add,Stamina_Add}
%%	
compute_talents(BronTalents,UserAdd)->
	{{Born_T_Power,Max_T_Power},
	{Born_T_HitRate,Max_T_HitRate},
	{Born_T_CriticalRate,Max_T_CriticalRate},
	{Born_T_Stamina,Max_T_Stamina}} = BronTalents,
	TalentsList = [{Born_T_Power,Born_T_HitRate,Born_T_CriticalRate,Born_T_Stamina},UserAdd],
	{T_Power,T_HitRate,T_CriticalRate,T_Stamina} = 
		lists:foldl(fun({Power,Hitrate,Criticalrate,Stamina},Acc)->
						{OldPower,OldHitrate,OldCriticalrate,OldStamina} = Acc,
						{OldPower + Power,
						OldHitrate + Hitrate,
						OldCriticalrate + Criticalrate,
						OldStamina + Stamina}
					end,{0,0,0,0},TalentsList),
	{min(T_Power,Max_T_Power),
	min(T_HitRate,Max_T_HitRate),
	min(T_CriticalRate,Max_T_CriticalRate),
	min(T_Stamina,Max_T_Stamina)}.

%%
%%
%%
compute_attr(Class,Talent,SkillEff,HappinessEff)->
	{MeleePower,RangePower,MagicPower,Meleedefence,Rangedefence,Magicdefence,Dodge,Hitrate,Criticalrate,CriticalDamage,
	 Toughness,Meleeimu,Trangeimu,Magicimu}=Talent,
	PowerKey = power_key(Class),
	{PowerEff,HitrateEff,CriticalrateEff,CriticaldamageEff,StaminaEff}
		= lists:foldl(fun({Key,Value},{AccPower,AccHit,AccCritiRate,AccCritiDamage,AccStamima})->
						case Key of
							PowerKey->
								{AccPower+Value,AccHit,AccCritiRate,AccCritiDamage,AccStamima};
							hitrate->
								{AccPower,AccHit+Value,AccCritiRate,AccCritiDamage,AccStamima};
							criticalrate->
								{AccPower,AccHit,AccCritiRate+Value,AccCritiDamage,AccStamima};
							criticaldestroyrate->
								{AccPower,AccHit,AccCritiRate,AccCritiDamage+Value,AccStamima};
							stamina_effect->
								{AccPower,AccHit,AccCritiRate,AccCritiDamage,AccStamima+Value};
							hpmax->
								{AccPower,AccHit,AccCritiRate,AccCritiDamage,AccStamima+Value};
							_->
								{AccPower,AccHit,AccCritiRate,AccCritiDamage,AccStamima}
						end 
					end,{0,0,0,0,0},SkillEff ),
	%Power = (Bpower + PowerAttr*1.5*T_Power/100 + PowerEff)*HappinessEff,
	%Hitrate = Bhitrate + HitrateAttr*0.08*T_Hitrate/100 + HitrateEff,
	%Criticalrate = Bcriticalrate + CriticalrateAttr*0.07*T_Criticalrate/100 + CriticalrateEff,
	%Criticaldamage = Bcriticaldamage + CriticalrateAttr*0.07*T_Criticalrate/100 + CriticaldamageEff,	
	%Stamina = (Bstamina + StaminaAttr*3*T_Stamina/100 + StaminaEff)*HappinessEff,
	Power = (MeleePower + PowerEff)*HappinessEff,
	Hitrate = Hitrate + HitrateEff,
	Criticalrate = Criticalrate  + CriticalrateEff,
	Criticaldamage = CriticalDamage + CriticaldamageEff,	
	Stamina = (Toughness + StaminaEff)*HappinessEff,
	
	{erlang:trunc(Power),erlang:trunc(Hitrate),erlang:trunc(Criticalrate),erlang:trunc(Criticaldamage),erlang:trunc(Stamina),Meleedefence,Rangedefence,Magicdefence,
	 Dodge,Meleeimu,Trangeimu,Magicimu}.

%compute_attr(Class,AttrAdd,Talent,BornAttr,HappinessEff)->
	%compute_attr(Class,AttrAdd,Talent,BornAttr,[],[],HappinessEff).
compute_attr(Class,Talent,HappinessEff)->
	compute_attr(Class,Talent,[],HappinessEff).


%%
%%recompute_attr 宠物属性计算包含与客户端通信及对AOI的广播
%%

%%
%%点数变化后计算属性
%%调用前，请保证玩家分配点数，可分配点数和总点数已更改
%%
recompute_attr(attr,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GmPetInfo = pet_op:get_gm_petinfo(PetId),
		%	RemainAttr = get_remain_attr_from_mypetinfo(PetInfo),
			%AttrAdd = get_attr_from_mypetinfo(PetInfo),
			Talent = get_talent_from_mypetinfo(PetInfo),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			PetProtoInfo = pet_proto_db:get_info(ProtoId),
			BronAbilities = pet_proto_db:get_born_abilities(PetProtoInfo),
			HappinessEff = get_happinesseff_from_mypetinfo(PetInfo),
			SkillEff = get_skill_attr_self(PetId),
			%EquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
			%EquipEff = pet_equip_op:get_attr_by_equipinfo(EquipInfo),
			Class = pet_proto_db:get_class(PetProtoInfo),
			{Power,Hitrate,Criticalrate,CriticalDamage,Toughness}=
				compute_attr(Class,Talent,SkillEff,HappinessEff),
	
			NewGmPetInfo = GmPetInfo#gm_pet_info{
											meleepower=Power,
											rangepower=Power,
											magicpower=Power,
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage,
											toughness=Toughness
											},
			
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			%{PowerAttr,HitrateAttr,CriticalAttr,StaminaAttr} = AttrAdd,
			pet_attr:only_self_update(PetId,
									[{meleepower=Power},
									 {rangepower=Power},
									 {magicpower=Power},
									 {hitrate,Hitrate},
									 {criticalrate,Criticalrate},
									 {criticaldestroyrate,CriticalDamage},
									 {toughness,Toughness}
									]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			case get_state_from_petinfo(GmPetInfo) of
				?PET_STATE_BATTLE->
					role_op:recompute_pet_attr();
				_->
					nothing
			end,
			pet_op:save_pet_to_db(PetId)
	end;
%%
%%天赋变化后计算属性
%%调用前确保天赋点数已更改
%%
recompute_attr(talent,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GmPetInfo = pet_op:get_gm_petinfo(PetId),
		%	AttrAdd = get_attr_from_mypetinfo(PetInfo),
			Talent = get_talent_from_mypetinfo(PetInfo),
			%ProtoId = get_proto_from_petinfo(GmPetInfo),
			%PetProtoInfo = pet_proto_db:get_info(ProtoId),
			%BronAbilities = pet_proto_db:get_born_abilities(PetProtoInfo),
			HappinessEff = get_happinesseff_from_mypetinfo(PetInfo),
			SkillEff = get_skill_attr_self(PetId),
			
			%EquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
			%EquipEff = pet_equip_op:get_attr_by_equipinfo(EquipInfo),
			%Class = pet_proto_db:get_class(PetProtoInfo),
			%{Power,Hitrate,Criticalrate,CriticalDamage,Toughness}=
				%compute_attr(Class,Talent,SkillEff,HappinessEff),
			%NewGmPetInfo = GmPetInfo#gm_pet_info{
										%	meleepower=Power,
										%	rangepower=Power,
										%	magicpower=Power,
											%power = Power,				
										%	hitrate = Hitrate,		
										%	criticalrate = Criticalrate,
										%	criticaldamage = CriticalDamage,
										%	toughness=Toughness
										%	},
			%pet_op:update_gm_pet_info_all(NewGmPetInfo),
			%{T_Power,T_Hitrate,T_Critical,T_Stamina} = Talent,
		%	pet_attr:only_self_update(PetId,
							%		[{meleepower=Power},
								%	 {rangepower=Power},
								%%	 {magicpower=Power},
								%	 {hitrate,Hitrate},
								%	 {criticalrate,Criticalrate},
								%	 {criticaldestroyrate,CriticalDamage},
								%	 {toughness,Toughness}
								%	]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			case get_state_from_petinfo(GmPetInfo) of
				?PET_STATE_BATTLE->
					role_op:recompute_pet_attr(),
					   role_fighting_force:hook_on_change_role_fight_force();
				_->
					nothing
			end,
			SortTalent=lists:sort(Talent),
			[NewSort|_]=SortTalent,
			TLevel=erlang:element(1, NewSort),
			pet_op:save_pet_to_db(PetId),
			game_pet_fighting_force_rank(PetId),
			game_pet_talent_score_rank(PetId),%%天赋
			achieve_op:achieve_update({pet_talent},[0],TLevel)
	end;

%%
%%天赋排名发生变化
%%
recompute_attr(talent_sort,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			TalentScore = get_talent_score_from_mypetinfo(PetInfo),
			TalentSort = get_talent_sort_from_mypetinfo(PetInfo),
			pet_attr:only_self_update(PetId,
									[
									 {pet_t_gs,TalentScore},
									 {pet_gs_sort,TalentSort}
									])
	end;

%%
%%资质变化后计算属性
%%调用前保证资质已修改
%%影响系统分配属性点数
%%Slot,SkillId,SkillLevel
recompute_attr(quality_value,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GmPetInfo = pet_op:get_gm_petinfo(PetId),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			QualityValue = get_quality_value_from_mypetinfo(PetInfo),
			SkillInfo=get_skill_from_mypetinfo(PetInfo),
			NewSkillInfo=pet_skill_op:pet_quality_to_change_skillinfo(QualityValue, SkillInfo),
			if NewSkillInfo=:=[]->
				   nothing;
			   true->
				   NewPetInfo = PetInfo#my_pet_info{
										skill=NewSkillInfo
											},
					pet_op:update_pet_info_all(NewPetInfo),
				   SkillSlotResult=lists:filter(fun({SlotNum,_,L})->( L=/=-1) and(SlotNum=<6) end, NewSkillInfo),
				   {Slot,SkillId,SkillLevel}=lists:max(SkillSlotResult),
				    Message=pet_packet:encode_update_pet_skill_s2c(PetId, {psk,Slot,SkillId,SkillLevel}),
					 role_op:send_data_to_gate(Message)
			 end,
			Transform=pet_proto_db:get_pet_transform_by_quality(QualityValue),
			NewGmPetInfo = GmPetInfo#gm_pet_info{
										transform=Transform
											},
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			pet_attr:only_self_update(PetId,
									[
									 {transform,Transform}
									]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			case get_state_from_petinfo(GmPetInfo) of
				?PET_STATE_BATTLE->
					role_op:recompute_pet_attr(),
					   role_fighting_force:hook_on_change_role_fight_force();
				_->
					nothing
			end,
			pet_op:save_pet_to_db(PetId),
			achieve_op:achieve_update({pet_quality},[0],QualityValue),
			game_pet_fighting_force_rank(PetId),
			game_pet_quality_value_rank(PetId)%%资质
	end;

%%
%%资质上限变化后计算属性
%%资质上限影响成长值
%%成长值影响影响玩家可分配点数
%%
recompute_attr(quality_up_value,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GmPetInfo = pet_op:get_gm_petinfo(PetId),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			PetProtoInfo = pet_proto_db:get_info(ProtoId),
			QualityUpValue = get_quality_up_value_from_mypetinfo(PetInfo),
			QualityInfo = pet_proto_db:get_quality_to_growth(PetProtoInfo),
			NewQuality = pet_util:get_adapt_quality(QualityUpValue,QualityInfo),
			OldQuality = get_quality_from_petinfo(GmPetInfo),
			Level = get_level_from_petinfo(GmPetInfo),
			RemainAttr=0,
			pet_attr:only_self_update(PetId,[
											{pet_quality_up_value,QualityUpValue},
											{pet_remain_attr,RemainAttr}
											]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			if
				NewQuality =:= OldQuality ->
					nothing;
				true->
					NewGmPetInfo = set_quality_to_petinfo(GmPetInfo,NewQuality),			
					pet_op:update_gm_pet_info_all(NewGmPetInfo),
					pet_attr:self_update_and_broad(PetId,[{pet_quality,NewQuality}])
			end,
			pet_op:save_pet_to_db(PetId)
	end;

%%
%%技能变化后重新计算人物属性（宠物学习技能后对宠物的属性没有影响，技能效果直接附加到主人身上）
%%
recompute_attr(skill,PetId)->	
	case pet_op:get_gm_petinfo(PetId) of
		[]->
			nothing;
		GmPetInfo->
			case get_state_from_petinfo(GmPetInfo) of
				?PET_STATE_BATTLE->
					role_op:recompute_pet_attr(),
					   role_fighting_force:hook_on_change_role_fight_force();
				_->
					nothing
			end,
			pet_op:save_pet_to_db(PetId),
			
			game_pet_fighting_force_rank(PetId)%%战力
	end;

%%
%%装备变化后计算属性
%%
recompute_attr(equip,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GmPetInfo = pet_op:get_gm_petinfo(PetId),
			%AttrAdd = get_attr_from_mypetinfo(PetInfo),
			Talent = get_talent_from_mypetinfo(PetInfo),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			PetProtoInfo = pet_proto_db:get_info(ProtoId),
			%BronAbilities = pet_proto_db:get_born_abilities(PetProtoInfo),
			HappinessEff = get_happinesseff_from_mypetinfo(PetInfo),
			SkillEff = get_skill_attr_self(PetId),
			%EquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
			%EquipEff = pet_equip_op:get_attr_by_equipinfo(EquipInfo),
			Class = pet_proto_db:get_class(PetProtoInfo),
			{Power,Hitrate,Criticalrate,CriticalDamage,Toughness}=
				compute_attr(Class,Talent,SkillEff,HappinessEff),
			NewGmPetInfo = GmPetInfo#gm_pet_info{
											meleepower=Power,
											rangepower=Power,
											magicpower=Power,
											%power = Power,				
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage,
											toughness=Toughness
											},
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			pet_attr:only_self_update(PetId,
									[
									 {meleepower=Power},
									 {rangepower=Power},
									 {magicpower=Power},
									 {hitrate,Hitrate},
									 {criticalrate,Criticalrate},
									 {criticaldestroyrate,CriticalDamage},
									 {toughness,Toughness}
									]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			case get_state_from_petinfo(GmPetInfo) of
				?PET_STATE_BATTLE->
					role_op:recompute_pet_attr(),
					   role_fighting_force:hook_on_change_role_fight_force();
				_->
					nothing
			end,
			pet_op:save_pet_to_db(PetId)
	end;

%% 
%%等级变化后计算属性 
%%
%%等级影响系统加成点 和玩家可分配点数
%% 
recompute_attr(levelup,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			Xs=get_xisui_from_mypetinfo(PetInfo),
			GmPetInfo = pet_op:get_gm_petinfo(PetId),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			Step=get_social_from_petinfo(GmPetInfo),
			Class=get_class_from_petinfo(GmPetInfo),
			HappinessEff = get_happinesseff_from_mypetinfo(PetInfo),
			PetLevel=get_level_from_petinfo(GmPetInfo),
			PetLevelInfo=pet_level_db:get_info(PetLevel),
			{Power,Rangepower,Magicpower,Hitrate,Meleedefence,Rangedefence,Magicdefence,Dodge,Criticalrate,CriticalDamage,Stamina,Meleeimu,Rangeimu,Magicimu}=case PetLevelInfo of
																[]->{0,0,0,0,0,0,0,0,0,0,0,0,0,0};
																_->pet_level_db:get_sysaddattr(PetLevelInfo)
										  end,
			
			PetMp=pet_level_db:get_maxmp(PetLevelInfo),
			if Step=:=1->
				   Attrid=Class;
			   true->
				   Attrid=Step*1000+Class
			end,
				Attrinfo=pet_advanced_db:get_pet_attr_base_info(Attrid),
			if Attrinfo=:=[]->
				   NewHp=0,
				   NewPower=0,
				   NewDefence=0;
			   true->
			 		NewHp=pet_advanced_db:get_hp_from_base(Attrinfo),
				  NewPower=pet_advanced_db:get_power_from_base(Attrinfo),
				   NewDefence=pet_advanced_db:get_defence_from_base(Attrinfo)
				end,
			{Newhp,NewMeleepower,NewRangepower,NewMagicpower,NewMeleedefence,NewRangedefence,NewMagicdefence}=
			recount_pet_attr(PetId,PetMp+NewHp,Power+NewPower,Rangepower+NewPower,Magicpower+NewPower,Meleedefence+NewDefence,
							 Rangedefence+NewDefence,Magicdefence+NewDefence,Xs),
			NewGmPetInfo = GmPetInfo#gm_pet_info{
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage, 		
											meleepower=NewMeleepower,
											rangepower=NewRangepower,
											magicpower=NewMagicpower,		
											meleedefence=NewMeleedefence,
											rangedefence=NewRangedefence,
											magicdefence=NewMagicdefence,	
											dodge=Dodge,
											toughness=Stamina,
											meleeimu=Meleeimu,
											rangeimu=Rangeimu,
											magicimu=Magicimu,
											hp=Newhp
											},
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			pet_attr:only_self_update(PetId,
									[
									 {meleepower,NewMeleepower},
									 {rangepower,NewRangepower},
									 {magicpower,NewMagicpower},
									  { meleedefense,NewMeleedefence},
									   {rangedefense,NewRangedefence},
									  {magicdefense,NewMagicdefence},	
									 {hitrate,Hitrate},
									 {criticalrate,Criticalrate},
									 {criticaldestroyrate,CriticalDamage},
									 {dodge,Dodge},
									 {toughness,Stamina},
									 {	meleeimmunity,Meleeimu},
									{rangeimmunity,Rangeimu},
									{magicimmunity,Magicimu},
									 {level,PetLevel},
									 {hpmax,Newhp}
									]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			case get_state_from_petinfo(GmPetInfo) of
				?PET_STATE_BATTLE->
					role_op:recompute_pet_attr(),
					   role_fighting_force:hook_on_change_role_fight_force();
				_->
					nothing
			end,
			pet_op:save_pet_to_db(PetId),
			game_pet_fighting_force_rank(PetId)%%战力
	end;

%%
%%欢乐度变化
%%
%%
recompute_attr(happiness,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			OldHappinessEff = get_happinesseff_from_mypetinfo(PetInfo),
			Happiness = get_happiness_from_mypetinfo(PetInfo),
			NewHappinessEff = get_happiness_eff(Happiness),
			pet_attr:only_self_update(PetId,[{pet_happiness,Happiness}]),
			if
				OldHappinessEff =:= NewHappinessEff ->
					nothing;
				true->
						GmPetInfo = pet_op:get_gm_petinfo(PetId),
						Talent = get_talent_from_mypetinfo(PetInfo),
						ProtoId = get_proto_from_petinfo(GmPetInfo),
						PetProtoInfo = pet_proto_db:get_info(ProtoId),
						SkillEff = get_skill_attr_self(PetId),
						Class = pet_proto_db:get_class(PetProtoInfo),
						{Power,Hitrate,Criticalrate,CriticalDamage,Stamina}=
							compute_attr(Class,Talent,SkillEff,NewHappinessEff),
						NewGmPetInfo = GmPetInfo#gm_pet_info{
											meleepower = Power,		
											rangepower=Power,
											magicpower=Power,		
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage, 		
											toughness = Stamina
											},
						pet_op:update_gm_pet_info_all(NewGmPetInfo),
						NewPetInfo = set_happinesseff_to_mypetinfo(PetInfo,NewHappinessEff),
						pet_op:update_pet_info_all(NewPetInfo),
						pet_attr:only_self_update(PetId,
									[
									 {power,Power},
									 {hitrate,Hitrate},
									 {criticalrate,Criticalrate},
									 {criticaldestroyrate,CriticalDamage},
									 {toughness,Stamina}
									]),
						case get_state_from_petinfo(GmPetInfo) of
							?PET_STATE_BATTLE->
								role_op:recompute_pet_attr(),
								  role_fighting_force:hook_on_change_role_fight_force();
							_->
								nothing
						end,
						pet_op:save_pet_to_db(PetId)
			end
	end;

%% 
%%宠物模板变换
%%
%% 
recompute_attr(proto,{PetId,OldProtoId})->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GmPetInfo = pet_op:get_gm_petinfo(PetId),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			PetProtoInfo = pet_proto_db:get_info(ProtoId),
			OldProtoInfo = pet_proto_db:get_info(OldProtoId),
			Level = get_level_from_petinfo(GmPetInfo),		
			QualityValue = get_quality_value_from_mypetinfo(PetInfo),
			QualityUpValue = get_quality_up_value_from_mypetinfo(PetInfo),
			{NewQuality,NewQualityValue,NewQualityUpValue} = 
				change_quality({QualityValue,QualityUpValue},OldProtoInfo,PetProtoInfo),			
			Talent = get_talent_from_mypetinfo(PetInfo),
			BronAbilities = pet_proto_db:get_born_abilities(PetProtoInfo),
			HappinessEff = get_happinesseff_from_mypetinfo(PetInfo),
			SkillEff = get_skill_attr_self(PetId),
			Class = pet_proto_db:get_class(PetProtoInfo),
			{Power,Hitrate,Criticalrate,CriticalDamage,Stamina}=
				compute_attr(Class,Talent,SkillEff,HappinessEff),
			Name = get_name_from_petinfo(GmPetInfo),
			NewGmPetInfo = GmPetInfo#gm_pet_info{
											meleepower = Power,	
											rangepower=Power,
											magicpower=Power,			
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage, 		
											toughness = Stamina,
											name = Name,
											quality = NewQuality
											},
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			NewPetInfo = PetInfo#my_pet_info{
												%attr = AttrAdd,
												quality_value = NewQualityValue,
												quality_up_value = NewQualityUpValue
											%	talent = NewTalent											
											},
			pet_op:update_pet_info_all(NewPetInfo),
			%{PowerAttr,HitrateAttr,CriticalAttr,StaminaAttr} = AttrAdd,
			%{NewTPower,NewTHitrate,NewTCriticalrate,NewTStamina} = NewTalent,
			pet_attr:only_self_update(PetId,
									[
									 {meleepower,Power},
									 {hitrate,Hitrate},
									 {criticalrate,Criticalrate},
									 {criticaldestroyrate,CriticalDamage},
									 {stamina,Stamina}
						
									]),
			case get_state_from_petinfo(GmPetInfo) of
				?PET_STATE_BATTLE->
					pet_attr:self_update_and_broad(PetId,
									[{pet_proto,ProtoId},
									 {name,Name},
									 {pet_quality,NewQuality}
									]),
					role_op:recompute_pet_attr();
				_->
					pet_attr:only_self_update(PetId,
									[{pet_proto,ProtoId},
									 {name,Name},
									 {pet_quality,NewQuality}
									]),
					nothing
			end,
			pet_op:save_pet_to_db(PetId)
	end;

recompute_attr(advance,PetId)->
	case pet_op:get_gm_petinfo(PetId) of
		[]->
			io:format("pet is not fine~n",[]);
		PetInfo->
			Step=get_social_from_petinfo(PetInfo),
			Class=get_class_from_petinfo(PetInfo),
			Proto=get_proto_from_petinfo(PetInfo),
			Ostep=Step-1,
				if Ostep=:=1->
				   OAttrid=Class;
			   true->
				   OAttrid=Ostep*1000+Class
				end,
			if Step=:=1->
				   Attrid=Class;
			   true->
				   Attrid=Step*1000+Class
			end,
			Attrinfo=pet_advanced_db:get_pet_attr_base_info(Attrid),
			if Attrinfo =:=[]->
				   nothing;
			   true->
					OAttrinfo=pet_advanced_db:get_pet_attr_base_info(OAttrid),
					if OAttrinfo=:=[]->
						Ohp=0,
						Opower=0,
						Odefence=0;
					true->
						Ohp=pet_advanced_db:get_hp_from_base(OAttrinfo),
						Opower=pet_advanced_db:get_power_from_base(OAttrinfo),
						Odefence=pet_advanced_db:get_defence_from_base(OAttrinfo)
					end,
				   Hp=pet_advanced_db:get_hp_from_base(Attrinfo)-Ohp,
				   Power=pet_advanced_db:get_power_from_base(Attrinfo)-Opower,
				   Defence=pet_advanced_db:get_defence_from_base(Attrinfo)-Odefence,
				 {Hpnew,MeleePowernew,RangepowerNew,MagicPowerNew,MeleeDefencenew,RangeDefencenew,MagicDefencenew}
																					=get_pet_attr_by_advanced( Hp, Power,Defence,PetId),
				   			NewGmPetInfo = PetInfo#gm_pet_info{
											meleepower=MeleePowernew,
											rangepower=RangepowerNew,
											magicpower=MagicPowerNew,		
											meleedefence=MeleeDefencenew,
											rangedefence=RangeDefencenew,
											magicdefence=MagicDefencenew,	
											hp=Hpnew
											},
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			pet_attr:only_self_update(PetId,
									[
									 {meleepower,MeleePowernew},
									 {rangepower,RangepowerNew},
									 {magicpower,MagicPowerNew},
									  { meleedefense,MeleeDefencenew},
									   {rangedefense,RangeDefencenew},
									  {magicdefense,MagicDefencenew},	
									 {hpmax,Hpnew},
									 {pet_proto,Proto}
									]),
			pet_op:save_pet_to_db(PetId),
			game_pet_fighting_force_rank(PetId),%%战力
			case get_state_from_petinfo(PetInfo) of
				?PET_STATE_BATTLE->
					role_op:recompute_pet_attr();
				_->
					nothing
			end
			end

	end;
	
%%洗髓属性改变
recompute_attr(xisui,PetId)->
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GamePetInfo=pet_op:get_gm_petinfo(PetId),
			Level = get_level_from_petinfo(GamePetInfo),
			Step=get_social_from_petinfo(GamePetInfo),
			Class=get_class_from_petinfo(GamePetInfo),
			XisuiInfo=get_xisui_from_mypetinfo(PetInfo),
			PetLevelInfo=pet_level_db:get_info(Level),
			{Power,Rangepower,Magicpower,Hitrate,Meleedefence,Rangedefence,
			 Magicdefence,Dodge,Criticalrate,CriticalDamage,Stamina,Meleeimu,Rangeimu,Magicimu}=
				case PetLevelInfo of
					[]->{0,0,0,0,0,0,0,0,0,0,0,0,0,0};
					_->pet_level_db:get_sysaddattr(PetLevelInfo)
				end,
			Pethp=pet_level_db:get_maxmp(PetLevelInfo),
			if Step=:=1->
				   Attrid=Class;
			   true->
				   Attrid=Step*1000+Class
			end,
			Attrinfo=pet_advanced_db:get_pet_attr_base_info(Attrid),
				if Attrinfo=:=[]->
				   NewHp=0,
				   NewPower=0,
				   NewDefence=0;
			   true->
			 		NewHp=pet_advanced_db:get_hp_from_base(Attrinfo),
				  NewPower=pet_advanced_db:get_power_from_base(Attrinfo),
				   NewDefence=pet_advanced_db:get_defence_from_base(Attrinfo)
				end,
			{Newhp,NewMeleepower,NewRangepower,NewMagicpower,NewMeleedefence,NewRangedefence,NewMagicdefence}=
			recount_pet_attr(PetId,Pethp+NewHp,Power+NewPower,Rangepower+NewPower,Magicpower+NewPower,Meleedefence+NewDefence,
							 Rangedefence+NewDefence,Magicdefence+NewDefence,XisuiInfo),
			NewGmPetInfo = GamePetInfo#gm_pet_info{
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage, 		
											meleepower=NewMeleepower,
											rangepower=NewRangepower,
											magicpower=NewMagicpower,		
											meleedefence=NewMeleedefence,
											rangedefence=NewRangedefence,
											magicdefence=NewMagicdefence,	
											dodge=Dodge,
											toughness=Stamina,
											meleeimu=Meleeimu,
											rangeimu=Rangeimu,
											magicimu=Magicimu,
											hp=Newhp
											},
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			pet_attr:only_self_update(PetId,
									[
									 {meleepower,NewMeleepower},
									 {rangepower,NewRangepower},
									 {magicpower,NewMagicpower},
									  { meleedefense,NewMeleedefence},
									   {rangedefense,NewRangedefence},
									  {magicdefense,NewMagicdefence},	
									 {hitrate,Hitrate},
									 {criticalrate,Criticalrate},
									 {criticaldestroyrate,CriticalDamage},
									 {dodge,Dodge},
									 {toughness,Stamina},
									 {	meleeimmunity,Meleeimu},
									{rangeimmunity,Rangeimu},
									{magicimmunity,Magicimu},
									 {level,Level},
									 {hpmax,Newhp}
									]),
				pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			case get_state_from_petinfo(NewGmPetInfo) of
				?PET_STATE_BATTLE->
					role_op:recompute_pet_attr(),
					   role_fighting_force:hook_on_change_role_fight_force();
				_->
					nothing
			end,
			pet_op:save_pet_to_db(PetId),
			game_pet_fighting_force_rank(PetId)%%战力
	end;
			
%%继承后宠物重新计算属性
recompute_attr(inherit,PetId)->
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GamePetInfo=pet_op:get_gm_petinfo(PetId),
			Talent=get_talent_from_mypetinfo(PetInfo),
			Skill=get_skill_from_mypetinfo(PetInfo),
			 Proto=get_proto_from_petinfo(GamePetInfo),
			Level = get_level_from_petinfo(GamePetInfo),
			Step=get_social_from_petinfo(GamePetInfo),
			Class=get_class_from_petinfo(GamePetInfo),
			XisuiInfo=get_xisui_from_mypetinfo(PetInfo),
			PetLevelInfo=pet_level_db:get_info(Level),
			{Power,Rangepower,Magicpower,Hitrate,Meleedefence,Rangedefence,
			 Magicdefence,Dodge,Criticalrate,CriticalDamage,Stamina,Meleeimu,Rangeimu,Magicimu}=
				case PetLevelInfo of
					[]->{0,0,0,0,0,0,0,0,0,0,0,0,0,0};
					_->pet_level_db:get_sysaddattr(PetLevelInfo)
				end,
			Pethp=pet_level_db:get_maxmp(PetLevelInfo),
			if Step=:=1->
				   Attrid=Class;
			   true->
				   Attrid=Step*1000+Class
			end,
			Attrinfo=pet_advanced_db:get_pet_attr_base_info(Attrid),
				if Attrinfo=:=[]->
				   NewHp=0,
				   NewPower=0,
				   NewDefence=0;
			   true->
			 	NewHp=pet_advanced_db:get_hp_from_base(Attrinfo),
				  NewPower=pet_advanced_db:get_power_from_base(Attrinfo),
				   NewDefence=pet_advanced_db:get_defence_from_base(Attrinfo)
				end,
			{Newhp,NewMeleepower,NewRangepower,NewMagicpower,NewMeleedefence,NewRangedefence,NewMagicdefence}=
			recount_pet_attr(PetId,Pethp+NewHp,Power+NewPower,Rangepower+NewPower,Magicpower+NewPower,Meleedefence+NewDefence,
							 Rangedefence+NewDefence,Magicdefence+NewDefence,XisuiInfo),
			NewGmPetInfo = GamePetInfo#gm_pet_info{
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage, 		
											meleepower=NewMeleepower,
											rangepower=NewRangepower,
											magicpower=NewMagicpower,		
											meleedefence=NewMeleedefence,
											rangedefence=NewRangedefence,
											magicdefence=NewMagicdefence,	
											dodge=Dodge,
											toughness=Stamina,
											meleeimu=Meleeimu,
											rangeimu=Rangeimu,
											magicimu=Magicimu,
											hp=Newhp
											},
				pet_op:update_gm_pet_info_all(NewGmPetInfo),
				CreatePet = pet_packet:make_pet(PetInfo,NewGmPetInfo,pet_equip_op:get_body_items_info([])),%%宠物继承后创建新宠物，新宠物id为继承中主宠物id
				Msg = pet_packet:encode_create_pet_s2c(CreatePet),
				role_op:send_data_to_gate(Msg),
		%	pet_attr:only_self_update(PetId,
							%		[
								%	 {meleepower,NewMeleepower},
								%	 {rangepower,NewRangepower},
								%	 {magicpower,NewMagicpower},
								%	  { meleedefense,NewMeleedefence},
									%   {rangedefense,NewRangedefence},
									%  {magicdefense,NewMagicdefence},	
									 %{hitrate,Hitrate},
									 %{criticalrate,Criticalrate},
									 %{criticaldestroyrate,CriticalDamage},
									 %{dodge,Dodge},
									% {toughness,Stamina},
									% {	meleeimmunity,Meleeimu},
									%{rangeimmunity,Rangeimu},
									%{magicimmunity,Magicimu},
								%	 {level,Level},
								%	 {hpmax,Newhp},
								%	 {pet_talents,EncodeT},
									% {pet_quality_value,Quality},
									% {pet_quality_up_value,QualityUp},
									% {pet_growth,Growth},
									% {pet_proto,Proto}
								%	]),
				pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			case get_state_from_petinfo(NewGmPetInfo) of
				?PET_STATE_BATTLE->
					role_op:recompute_pet_attr(),
					   role_fighting_force:hook_on_change_role_fight_force();
				_->
					nothing
			end,
			pet_op:save_pet_to_db(PetId),
			game_pet_all_rank(PetId)
	end;
%% 
%%重新计算所有属性 
%% 
	
recompute_attr(all,PetId)->	
	todo.
recompute_attr(growthvalue,PetId,Value)->
	GameInfo=pet_op:get_gm_petinfo(PetId),
	GrowthValue=get_growth_value_from_pet_info(GameInfo),
	New_hp=get_hp_value_from_pet_info(GameInfo)+Value*10,
	Meleepower=get_meleepower_value_from_pet_info(GameInfo)+Value*2,
	Rangepower=get_rangepower_value_from_pet_info(GameInfo)+Value*2,
	Magicpower=get_magicpower_value_from_pet_info(GameInfo)+Value*2,
	Meleedefence=get_meleedefence_value_from_pet_info(GameInfo)+Value*1,
	Rangedefence=get_rangedefence_value_from_pet_info(GameInfo)+Value*1,
	Magicdefence=get_magicdefence_value_from_pet_info(GameInfo)+Value*1,
	NewGameInfo=GameInfo#gm_pet_info{hp=New_hp,
							 						meleepower=Meleepower,
							 						rangepower=Rangepower,
							 						magicpower=Magicpower,
							 						meleedefence=Meleedefence,
							 						rangedefence=Rangedefence,
							 						magicdefence=Magicdefence},
	pet_op:update_gm_pet_info_all(NewGameInfo),
	pet_attr:only_self_update(PetId,[{hpmax,New_hp},
									 					{meleepower,Meleepower},
							 							{rangepower,Rangepower},
							 							{magicpower,Magicpower},
							 							{meleedefense,Meleedefence},
							 							{rangedefense,Rangedefence},
							 							{magicdefense,Magicdefence}]),
	case get_state_from_petinfo(GameInfo) of
				?PET_STATE_BATTLE->
					role_op:recompute_pet_attr(),
					   role_fighting_force:hook_on_change_role_fight_force();
				_->
					nothing
			end,
			pet_op:save_pet_to_db(PetId),
			game_pet_growth_rank(PetId),
			achieve_op:achieve_update({pet_growth},[0],GrowthValue),
			game_pet_fighting_force_rank(PetId).
	

%%
%%更新宠物交易锁定状态
%%
update_pet_lock_state(PetId,LockState)->
	pet_attr:only_self_update(PetId,[{pet_lock,LockState}]).

get_skill_attr_self(PetId)->
	pet_skill_op:get_skill_addition_for_pet(PetId).

get_skill_attr_master(PetId)->
	pet_skill_op:get_skill_addition_for_role(PetId).
get_talent_attr_master(PetId)->
	pet_talent_op:get_talent_addition_for_role(PetId).

compute_talent_score(PetId,PetName,Dodge,Hitrate,Criticalrate,CriticalDamage,Toughness,Meleeimu,Trangeimu,Magicimu)->
	RoleInfo = get(creature_info),
	RoleName = get_name_from_roleinfo(RoleInfo),
	[S_Dodge,S_Hitrate,S_Criticalrate,S_CriticalDamage,S_Toughness,S_Meleeimu,S_Trangeimu,S_Magicimu]=lists:foldl(fun(Talent,Acc)->
																	Score = trunc(250+math:pow(Talent-0,1.45)),	
																	[Score|Acc]
																end,[],[Dodge,Hitrate,Criticalrate,CriticalDamage,Toughness,Meleeimu,Trangeimu,Magicimu]),
	%Talent_Score = S_Power+S_HitRate+S_Criticalrate+S_Stamina,
	Talent_Score=S_Dodge+S_Hitrate+S_Criticalrate+S_CriticalDamage+S_Toughness+S_Meleeimu+S_Trangeimu+S_Magicimu,
	game_rank_manager:challenge(PetId, ?RANK_TYPE_PET_TALENT_SCORE,{PetName,RoleName,Talent_Score}),
	RankNum = game_rank_manager:sync_get_pet_talent_rank(PetId),
	{Talent_Score,RankNum}.
%%3.25写【xiaowu】%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
game_pet_all_rank(PetId)->
	GmPetInfo = pet_op:get_gm_petinfo(PetId),
	MyPetInfo = pet_op:get_pet_info(PetId),
	Quality_Value = get_quality_value_from_mypetinfo(MyPetInfo),
	PetName = get_name_from_petinfo(GmPetInfo),
	Growth_Value = get_growth_value_from_pet_info(GmPetInfo),
	RoleInfo = get(creature_info),
	RoleName = get_name_from_roleinfo(RoleInfo),
	Fighting_Force = get_fighting_force_from_petinfo(GmPetInfo),
	Talent_Score = get_talent_levelalll_to_rank(PetId),
	game_rank_manager:challenge(PetId, ?RANK_TYPE_PET_FIGHTING_FORCE,{PetName,RoleName,Fighting_Force}),%1月10日加 【小五】
	game_rank_manager:challenge(PetId, ?RANK_TYPE_PET_GROWTH,{PetName,RoleName,Growth_Value}),
	game_rank_manager:challenge(PetId, ?RANK_TYPE_PET_QUALITY_VALUE,{PetName,RoleName,Quality_Value}),
	game_rank_manager:challenge(PetId, ?RANK_TYPE_PET_TALENT_SCORE,{PetName,RoleName,Talent_Score}).
game_pet_fighting_force_rank(PetId)->
	GmPetInfo = pet_op:get_gm_petinfo(PetId),
	PetName = get_name_from_petinfo(GmPetInfo),
	Fighting_Force = get_fighting_force_from_petinfo(GmPetInfo),
	RoleInfo = get(creature_info),
	RoleName = get_name_from_roleinfo(RoleInfo),
	game_rank_manager:challenge(PetId, ?RANK_TYPE_PET_FIGHTING_FORCE,{PetName,RoleName,Fighting_Force}).%1月10日加 【小五】
game_pet_growth_rank(PetId)->
	GmPetInfo = pet_op:get_gm_petinfo(PetId),
	PetName = get_name_from_petinfo(GmPetInfo),
	Growth_Value = get_growth_value_from_pet_info(GmPetInfo),
	RoleInfo = get(creature_info),
	RoleName = get_name_from_roleinfo(RoleInfo),
	game_rank_manager:challenge(PetId, ?RANK_TYPE_PET_GROWTH,{PetName,RoleName,Growth_Value}).
game_pet_quality_value_rank(PetId)->
	GmPetInfo = pet_op:get_gm_petinfo(PetId),
	MyPetInfo = pet_op:get_pet_info(PetId),
	PetName = get_name_from_petinfo(GmPetInfo),
	Quality_Value = get_quality_value_from_mypetinfo(MyPetInfo),
	RoleInfo = get(creature_info),
	RoleName = get_name_from_roleinfo(RoleInfo),
	game_rank_manager:challenge(PetId, ?RANK_TYPE_PET_QUALITY_VALUE,{PetName,RoleName,Quality_Value}).
game_pet_talent_score_rank(PetId)->
	GmPetInfo = pet_op:get_gm_petinfo(PetId),
	PetName = get_name_from_petinfo(GmPetInfo),
	Talent_Score = get_talent_levelalll_to_rank(PetId),
	RoleInfo = get(creature_info),
	RoleName = get_name_from_roleinfo(RoleInfo),
	game_rank_manager:challenge(PetId, ?RANK_TYPE_PET_TALENT_SCORE,{PetName,RoleName,Talent_Score}).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_talent_levelalll_to_rank(PetId)->
	case pet_op:get_pet_info(PetId) of
		[]->
			nothing;
		GamePetInfo->
			TalentList=get_talent_from_mypetinfo(GamePetInfo),
			lists:foldl(fun({Level,_,_},Acc)->
								Acc+Level
								end , 0,TalentList)
	end.
	
power_key(Class)->
	case Class of
		?CLASS_MAGIC ->
			magicpower;		       
		?CLASS_RANGE ->
			rangepower;
		?CLASS_MELEE ->
			meleepower;
		_->
			nothing
	end.

%%
%%return {Quality,QualityValue,QualityUpValue}
%%
change_quality({OldQualityValue,OldQualityUpValue},OldProtoInfo,NewProtoInfo)->
	OldQualityInfo = pet_proto_db:get_quality_to_growth(OldProtoInfo),
	NewQualityInfo = pet_proto_db:get_quality_to_growth(NewProtoInfo),
	{OldQualityValueMin,_} = get_adapt_qualityinfo(?PET_MIN_QUALITY,OldQualityInfo),
	{NewQualityValueMin,_} = get_adapt_qualityinfo(?PET_MIN_QUALITY,NewQualityInfo),
	NewQualityValue = OldQualityValue - OldQualityValueMin + NewQualityValueMin,
	NewQualityUpValue =  OldQualityUpValue - OldQualityValueMin + NewQualityValueMin,
	NewQuality = get_adapt_quality(NewQualityUpValue,NewQualityInfo),
	{NewQuality,NewQualityValue,NewQualityUpValue}.

change_talent({OldTPower,OldTHitrate,OldTCriticalrate,OldTStamina},OldProtoInfo,NewProtoInfo)->
	{{Obp,_},{Obh,_},{Obc,_},{Obs,_}} = pet_proto_db:get_born_talents(OldProtoInfo),
	{{Nbp,_},{Nbh,_},{Nbc,_},{Nbs,_}} = pet_proto_db:get_born_talents(NewProtoInfo),
	NewTPower = OldTPower - Obp + Nbp,
	NewTHitrate = OldTHitrate - Obh + Nbh,
	NewTCriticalrate = OldTCriticalrate - Obc + Nbc,
	NewTStamina = OldTStamina - Obs + Nbs,
	{NewTPower,NewTHitrate,NewTCriticalrate,NewTStamina}.


get_pet_quality_color(Quality)->
	case Quality of
		1->?COLOR_WHITE;
		2->?COLOR_GREEN;
		3->?COLOR_BLUE;
		4->?COLOR_PURPLE;
		5->?COLOR_GOLDEN;
		_->0
	end.	
	
get_pet_attr_by_advanced( Hp, Power,Defence,Pid)->
	case pet_op:get_gm_petinfo(Pid) of
		[]->
			io:format("pet is not fine~n",[]);
		Gameinfo->
			Hpold=get_hp_value_from_pet_info(Gameinfo),
			MeleePowerold=get_meleepower_value_from_pet_info(Gameinfo),
			RangePowerold=get_rangepower_value_from_pet_info(Gameinfo),
			MagicPowerold=get_magicpower_value_from_pet_info(Gameinfo),
			MeleeDefenceold=get_meleedefence_value_from_pet_info(Gameinfo),
			RangeDefenceold=get_rangedefence_value_from_pet_info(Gameinfo),
			MagicDefenceold=get_magicdefence_value_from_pet_info(Gameinfo),
			Hpnew=Hpold+Hp,
			MeleePowernew=MeleePowerold+Power,
			RangepowerNew=RangePowerold+Power,
			MagicPowerNew=MagicPowerold+Power,
			MeleeDefencenew=MeleeDefenceold+Defence,
			RangeDefencenew=RangeDefenceold+Defence,
			MagicDefencenew=MagicDefenceold+Defence,
			{Hpnew,MeleePowernew,RangepowerNew,MagicPowerNew,MeleeDefencenew,RangeDefencenew,MagicDefencenew}
	end.

recount_pet_attr(PetId,Hp,MeleePower,RangePower,MagicPower,Meleedefence,Rangedefence,Magicdefence,Xs)->
	Xsmeleepower=pet_packet:get_meleepower_xs(Xs)-100,
	Xsrangepower=pet_packet:get_rangpower_xs(Xs)-100,
	Xsmagicpower=pet_packet:get_magicpower_xs(Xs)-100,
	Xsmeleedefence=pet_packet:get_meleedefence_xs(Xs)-100,
	Xsrangedefence=pet_packet:get_rangedefence_xs(Xs)-100,
	Xsmagicdefence=pet_packet:get_magicdefence_xs(Xs)-100,
	Xshp=pet_packet:get_hp_xs(Xs)-100,
	GameInfo=pet_op:get_gm_petinfo(PetId),
	Growth=get_growth_value_from_pet_info(GameInfo),
	NewMeleepower=erlang:round(MeleePower*(Xsmeleepower / 100))+MeleePower+(Growth-20)*2,
	NewRangepower=erlang:round(RangePower*(Xsrangepower / 100))+RangePower+(Growth-20)*2,
	NewMagicpower=erlang:round(MagicPower*(Xsmagicpower / 100))+MagicPower+(Growth-20)*2,
	NewRangedefence=erlang:round(Meleedefence*(Xsmeleedefence / 100))+Meleedefence+(Growth-20)*1,
	NewMeleedefence=erlang:round(Rangedefence*(Xsrangedefence / 100))+Rangedefence+(Growth-20)*1,
	NewMagicdefence=erlang:round(Magicdefence*(Xsmagicdefence / 100))+Magicdefence+(Growth-20)*1,
	Newhp=erlang:round(Hp*(Xshp / 100))+Hp+(Growth-20)*10,
	{Newhp,NewMeleepower,NewRangepower,NewMagicpower,NewMeleedefence,NewRangedefence,NewMagicdefence}.
	
	encode_pet_talent(PetTalent)->
		lists:map(fun({Level,Pid,Type})->
							  {pt,Level,Pid,Type} end,PetTalent).
		%NumList=lists:seq(1,11),
		%LevelList=lists:map(fun(Num)->
									%lists:foldl(fun({Level,PtId,Type},Acc)->
														%if Type=:=Num->
															   %Level;
														 %  true->
															 %  Acc
														%end end, 0, PetTalent) end, NumList),
%LevelList.
			
	
	
	