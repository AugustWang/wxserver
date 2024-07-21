-define(Hp,1).%%飞剑洗练属性定义
-define(POWER,2).
-define(MELEEDEFENSE,3).
-define(RANGEDEFENSE,4).
-define(MAGICDEFENSE,5).
-define(HIRATE,6).%%命中
-define(DODGE,7).
-define(CRITICALRATE,8).
-define(CRITICALDAMAGE,9).
-define(TOUGHNESS,10).

%%飞剑升级
-record(wing_level,{level,item,money,power,defence,hpmax,mpmax}).
%%进阶
-record(wing_phase,{phase,item,money,speed,power,defense,hpmax,mpmax,maxintensity,failedbless,rate,addrate}).
-record(wing_quality,{quality,item,money,power,defense,hpmax,mpmax,skill}).
-record(wing_intensify_up,{intensify,item,money,maxperfectness,unlockskill,attrsate}).
-record(wing_skill,{skillid,level,item,money,effectinfo}).
-record(item_gold_price,{itemid,price}).
-record(wing_echant,{quality,item,money,maxnumber}).
-record(wing_echant_lock,{num,gold,item}).
%%获得飞剑
-record(wing_role,
		{roleid,
		 level,                  %%飞剑等级
		 social,                %%飞剑品阶
		quality,               %%飞剑品质
		streng,                %%强化
		streng_up,             %%强化上限
		perfect_value,         %%强化加成
		skills,                           %%飞剑技能
		echants,            %%洗练属性
		lucky                      %%进阶幸运值
		}).

-record(wing_game_info,
		{
		 level,   					%%等级
		socail,   				  %%品阶
		quality,    				 %%品质
		strength,  				   %%强化
		streng_up,  				 %%强化上限
		strength_add,     		%%强化加成<100+strength*10+perfect_value>
		perfect_value,          %%强化完美值
		skills,              			%%飞剑技能
		echants,            %%洗练属性
		lucky,                			%%飞剑进阶幸运值
		power,                          %%攻击
		magicdefense,                    %%魔防御
		rangedefense,                   %%远防
		meleedefense,                   %%近防
		hp,                           %%生命
		mp,                         %%法力
		speed                      %%附加任务身上的速度
		 }).

get_level_from_wing_info(Info)->
	#wing_game_info{level=Level}=Info,
	Level.
get_socail_from_wing_info(Info)->
	#wing_game_info{socail=Socail}=Info,
	Socail.
get_quality_from_wing_info(Info)->
	#wing_game_info{quality=Quality}=Info,
	Quality.
get_strength_from_wing_info(Info)->
	#wing_game_info{strength=Strength}=Info,
	Strength.

get_strength_up_from_wing_info(Info)->
	#wing_game_info{streng_up=Strength_up}=Info,
	Strength_up.

get_strength_add_from_wing_info(Info)->
	#wing_game_info{strength_add=Strength_add}=Info,
	Strength_add.
get_perfect_value_from_wing_info(Info)->
	#wing_game_info{perfect_value=Perfect_Value}=Info,
	Perfect_Value.

get_skills_from_wing_info(Info)->
	#wing_game_info{skills=Skill}=Info,
	Skill.
get_lucky_from_wing_info(Info)->
	#wing_game_info{lucky=Lucky}=Info,
	Lucky.
get_power_from_wing_info(Info)->
	#wing_game_info{power=Power}=Info,
	Power.
get_magicdefense_from_wing_info(Info)->
	#wing_game_info{magicdefense=Defense}=Info,
	Defense.
get_rangedefense_from_wing_info(Info)->
	#wing_game_info{rangedefense=Defense}=Info,
	Defense.
get_meleedefense_from_wing_info(Info)->
	#wing_game_info{meleedefense=Defense}=Info,
	Defense.
get_hp_from_wing_info(Info)->
	#wing_game_info{hp=Hp}=Info,
	Hp.
get_mp_from_wing_info(Info)->
	#wing_game_info{mp=Mp}=Info,
	Mp.
get_echants_from_wing_info(Info)->
	#wing_game_info{echants=Echants}=Info,
	Echants.

get_speed_from_wing_info(Info)->
	#wing_game_info{speed=Speed}=Info,
	Speed.