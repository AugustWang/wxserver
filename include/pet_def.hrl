%%
%%pet table define
%%pet商店(id,名字，物品栏id，价格，资质)
-record(pet_item_mall,{keynum,protoid,playid,classtype,price,quality}).
%%
-record(pet_proto,{
					protoid,				%%模板id
					name,					%%宠物姓名
					species,				%%物种
					femina_rate,			%%雌性概率
					class,					%%魔|远|攻
					min_take_level,			%%最低携带玩家等级
					quality_to_growth,		%%品质对应成长值段[{品质,{资质下限,资质上限},{成长值}}]
					born_abilities,			%%出生能力值 {攻击,命中,暴击,暴击伤害,体质加成}
					born_attr,				%%出生属性点 {攻击点,命中点,暴击点,体质加成点}
					born_talents,			%%出生天赋 {{攻击下限,攻击上限},{命中下限,命中上限},{暴击下限,暴击上限},{体质加成下限,体质上限}}
					born_skills,			%%出生随机技能列表[{技能id,概率},....]
					happiness_cast,			%%欢乐度消耗概率{概率,消耗点数}
					born_quality,			%%出生资质	[{品质,[{{下限,上限},概率(1-100)}]}]		
					born_quality_up,		%%出生资质上限 [{品质,[{{下限,上限},概率(1-100)}]}]
					can_delete,				%%放生标志 1为可放生
					can_explore				%%探险标志 1为可探险	
				}).

-record(pets,{petid,masterid,protoid,petinfo,skillinfo,equipinfo,ext1,ext2}).

-record(pet_level,{level,exp,maxhp,sysaddattr}).

-record(pet_happiness,{range,percent}).

-record(pet_growth,{quality,growth}).

-record(pet_talent_consume,{type,consume}).
-record(pet_talent_rate,{type,talent,rateinfo}).
-record(pet_slot,{slot,price}).
-record(pet_wash_attr_point,{key,needs,consumegold}).	%%属性洗点：key:wash_point;needs:消耗道具protoid;consumegold:元宝消耗所需元宝数
-record(pet_evolution,{petproto,consume,rate,result_petproto,order}).

-record(pet_quality,{quality_value,rate,needs,protect,money}).%%宠物资质提升表：quality_value:资质值；rate:概率；needs:消耗道具；protect:保护符

-record(pet_quality_up,{quality_value,rate,consumemoney,needs,consumegold}).%%宠物资质上限提升表：资质上限值；rate:概率；consumemoney：消耗金币；needs：消耗道具；consumegold:元宝消耗所需元宝数


-record(pet_explore_gain,{id,level_limit,limit_attr,attr_value,general_drop,special_drop,add_mystery_drop,unadd_mystery_drop,starttime,endtime,week}).
%%探险获得物品数据 
%%level_limit:宠物等级限制;limit_attr:探险的限制属性;attr_value:限制的属性点最低值;general_drop:普通物品掉落规则,不同的属性点数不同的掉落规则[{attr_point,[drup_rule]}];
%%special_drop:特殊物品掉落规则,不同的属性点数不同的掉落规则[{attr_point,[drup_rule]}];add_mystery_drop:带有加成概率的神秘物品掉落规则[drup_rule];
%%unadd_mystery_drop:不带加成概率的神秘物品掉落规则[drup_rule];starttime:开始时间{{syear,smonth,sday},{shour,sminute,ssecond}};
%%endtime:结束时间{{eyear,emonth,eday},{ehour,eminute,esecond}};week:星期开放[1,2]
%%宠物探险后台控制表
-record(pet_explore_background,{id,mapid,starttime,endtime,week}).

-record(pet_explore_style,{id,time,rate}).
%%探险方式表 
%%id:探险方式id;time:探险时间;rate:收益倍数
-record(pet_explore_info,{petid,masterid,remaintimes,siteid,styleid,starttime,duration_time,lacky,last_time,ext}).
%%探险角色数据表
%%styleid:探险方式id;starttime:探险开始时间;speedtime:使用道具加速的时间
%%
%%宠物技能槽位开启概率
%%
-record(pet_skill_slot,{index,rate}).
%%宠物探险仓库
-record(pet_explore_storage,{roleid,itemlist,max_item_id,ext}).
%%宠物加速升级
-record(pet_level_speed,{pid,speedtime}).
% 宠物加速升级
-record(pet_attr_transform,{quality,transform}).
%宠物成长提升
-record(pet_up_growth,{growth,ratevalue,needitem}).
%%宠物技能
-record(pet_skill_book_rate,{lucky,rate}).
-record(pet_skill_book,{level,skill}).
-record(pet_fresh_skill,{roleid,lucky,skillinfo}).
-record(pet_skill_proto,{slot,required,money}).
%每一阶的宠物初始属性
-record(pet_base_attr,{proto,hp,power,defence,hprate,powerrate,defencerate,data1,data2}).
%%宠物洗髓
-record(pxs,
		{xshpmax,
		basemagicpower,
		baserangedefence,
		xsmeleepower,
		basemagicdefence,
		xsmeleedefence,
		basemeleepower,
		xsrangepower,
		basehpmax,
		basemeleedefence,
		xsrangedefence,
		xsmagicpower,
		baserangepower,
		xsmagicdefence}).
%%宠物洗髓
-record(pet_xisui_rate,{xisui,rate}).
%%宠物天赋
-record(pet_talent_item,{level,item,money}).
%%天赋类型，所需条件，是否可升级(生命，攻击，防御不可升级)，名字
-record(pet_talent_proto,{type,talnetid,required,upgrade,name}).
-record(pet_talent_template,{talnetid,level,affect}).
%%宠物进阶
-record(pet_advance,{step,itemnum,money}).
-record(pet_advance_lucky,{step,lucky,rate}).
%%宠物商店记录，因为需要时间更新，所以需要记录到数据库
-record(pet_shop_info,{roleid,shopinfo,time}).
%6点重置宠物进阶祝福值
-record(pet_advance_reset_time,{roleid,time}).