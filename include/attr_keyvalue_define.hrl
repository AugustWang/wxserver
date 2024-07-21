%% 0~ 999    类型为整型
%% 1000~1999 类型为string
%% 2000~2999 类型为bigint
%% 3000~3999 类型为int_list


%%人物属性keyvalue对应
-define(ROLE_ATTR_CLASS,0).						%%职业
-define(ROLE_ATTR_LEVEL,1).						%%等级
-define(ROLE_ATTR_POSX,3).						%%位置x
-define(ROLE_ATTR_POSY,4).						%%位置y
-define(ROLE_ATTR_GENDER,5).					%%性别
-define(ROLE_ATTR_STATE,6).						%%状态
-define(ROLE_ATTR_ENCHANT,7).					%%升星套
-define(ROLE_ATTR_HP,11).						%%HP
-define(ROLE_ATTR_MP,12).						%%MP
-define(ROLE_ATTR_MPMAX,13).					%%最大魔力
-define(ROLE_ATTR_HPMAX,14).					%%最大血量
-define(ROLE_ATTR_GOLD,17).						%%元宝
-define(ROLE_ATTR_TICKET,18).					%%礼券
-define(ROLE_ATTR_GUILDTYPE,19).				%%帮会类型 	1为王国帮会 其他无意义
-define(ROLE_ATTR_HPRECOVER,201).				%%血量回复
-define(ROLE_ATTR_CRITICALDESTROYRATE,202).		%%暴击伤害
-define(ROLE_ATTR_MPRECOVER,203).				%%魔力回复
-define(ROLE_ATTR_MOVESPEED,204).				%%移动速度
-define(ROLE_ATTR_MELEEIMU,205).				%%近战免疫
-define(ROLE_ATTR_RANGEIMU,206).				%%远程免疫
-define(ROLE_ATTR_MAGICIMU,207).				%%魔法免疫
-define(ROLE_ATTR_HPMAX_PERCENT,208).			%%血量百分比
-define(ROLE_ATTR_MELEEPOWER_PERCENT,209).		%%近攻百分比
-define(ROLE_ATTR_RANGEPOWER_PERCENT,210).		%%远攻百分比
-define(ROLE_ATTR_MAGICPOWER_PERCENT,211).		%%魔攻百分比
-define(ROLE_ATTR_MOVESPEED_PERCENT,212).		%%移动速度百分比
-define(ROLE_ATTR_STAMINA,301).					%%体力
-define(ROLE_ATTR_STRENGTH,302).				%%力量
-define(ROLE_ATTR_INTELLIGENCE,303).			%%智力
-define(ROLE_ATTR_AGILE,304).					%%敏捷
-define(ROLE_ATTR_MAGIC_POWER,305).				%%魔攻
-define(ROLE_ATTR_MELEE_POWER,306).				%%近攻
-define(ROLE_ATTR_RANGE_POWER,307).				%%远攻
-define(ROLE_ATTR_MELEE_DEFENCE,308).			%%近防
-define(ROLE_ATTR_RANGE_DEFENCE,309).			%%远防
-define(ROLE_ATTR_MAGIC_DEFENCE,310).			%%魔防
-define(ROLE_ATTR_HITRATE,311).					%%命中
-define(ROLE_ATTR_DODGE,312).					%%闪避
-define(ROLE_ATTR_CRITICALRATE,313).			%%暴击
-define(ROLE_ATTR_TOUGHNESS,314).				%%韧性
-define(ROLE_ATTR_POWER,315).					%%攻击
-define(ROLE_ATTR_PACKSIZE,401).				%%包裹大小
-define(ROLE_ATTR_STORAGESIZE,402).				%%仓库大小
-define(ROLE_ATTR_IMPRISONMENT_RESIST,601).		%%定身抵抗
-define(ROLE_ATTR_SILENCE_RESIST,602).			%%沉默抵抗
-define(ROLE_ATTR_DAZE_RESIST,603).				%%昏迷抵抗
-define(ROLE_ATTR_POISON_RESIST,604).			%%中毒抵抗
-define(ROLE_ATTR_NORMAL_RESIST,605).			%%普通抵抗
-define(ROLE_ATTR_PK_MODEL,606).				%%pk标志
-define(ROLE_ATTR_CRIME_VALUE,607).				%%罪恶值
-define(ROLE_ATTR_CREATURE_FLAG,700).			%%生物标志
-define(ROLE_ATTR_DISPLAYID,702).				%%资源id
-define(ROLE_ATTR_PROTOID,703).					%%模板id
-define(ROLE_ATTR_GUILD_POSTING,805).			%%帮会职位
-define(ROLE_ATTR_LOOKS_CLOTH,907).				%%衣服显示
-define(ROLE_ATTR_LOOKS_ARM,908).				%%武器显示
-define(ROLE_ATTR_VIPTAG,909).					%%Vip标志
-define(ROLE_ATTR_FACTION,910).					%%阵营信息 0为无阵营 1为红  2为蓝 (目前只在战场内有用)
-define(ROLE_ATTR_RIDEDISPLAY,911).				%%坐骑资源
-define(ROLE_ATTR_SERVERID,912).				%%服务器id		
-define(ROLE_ATTR_TREASURE_TRANSPORT,913).		%%镖车
-define(ROLE_ATTR_FIGHTING_FORCE,914).			%%战斗力
-define(ROLE_ATTR_HONOR,915).					%%荣誉值
%%灵力
-define(ROLE_ATTR_SOULPOWER,50).				%%灵力
-define(ROLE_ATTR_MAXSOULPOWER,51).				%%最大灵力

%%灵魂力
-define(ROLE_ATTR_SPIRITSPOWER,52).				%%灵魂力
-define(ROLE_ATTR_MAXSPIRITSPOWER,53).			%%最大灵魂力


-define(ATTR_INT,999).                      	
-define(ATTR_STRING,1133).   
 
-define(ROLE_ATTR_NAME,1002).					%%名字
-define(ROLE_ATTR_GUILD_NAME,1004).				%%帮会名
-define(ROLE_ATTR_PET_NAME,1005).				%%宠物姓名

-define(ROLE_ATTR_EXPR,2010).					%%经验
-define(ROLE_ATTR_COMPANION_ROLE,2011).			%%密修对象
-define(ROLE_ATTR_LEVELUPEXP,2015).				%%升级所需经验
-define(ROLE_ATTR_BOUND_SILVER,2016).			%%绑定游戏币
-define(ROLE_ATTR_SILVER,2017).					%%游戏币
-define(ROLE_ATTR_TOUCHRED,2701).				%%染红
-define(ROLE_ATTR_TARGETID,2702).				%%目标

-define(ROLE_ATTR_ID,2800).                     %%人物ID		bigint
-define(ROLE_ATTR_PET_ID,2801).					%%宠物id		bigint
-define(ROLE_ATTR_BODY_BUFFER,3006).			%%身上所带buffer
-define(ROLE_ATTR_BODY_BUFF_LEVEL,3007).		%%buffer等级
-define(ROLE_ATTR_HONOUR,3005).					%%人物头衔
-define(PET_ATTR_HONOUR,5005).					%%宠物头衔  ======== 《枫少》

-define(ROLE_ATTR_PATH_X,3108).					%%移动路径x坐标
-define(ROLE_ATTR_PATH_Y,3109).					%%移动路径y坐标
-define(ROLE_ATTR_CUR_DESIGNATION,3111).		%%称号

%%宠物
-define(ROLE_ATTR_PET_QUALITY,551).			%%宠物质量	
-define(ROLE_ATTR_PET_GROWTH,552).			%%宠物成长值	 
-define(ROLE_ATTR_PET_PROTO,553).			%%宠物模板
-define(ROLE_ATTR_PET_SLOT,554).			%%宠物槽位
-define(ROLE_ATTR_PET_SKILLNUM,555).		%%宠物技能个数
-define(ROLE_ATTR_PET_TRANSFORM,556).		%%被攻击下马概率
-define(ROLE_ATTR_PET_TALENTS,3008).		%%宠物天赋
-define(ROLE_ATTR_PET_MASTER,2020).			%%宠物主人

-define(ROLE_ATTR_PET_HAPPINESS,560).		%%宠物快乐度
-define(ROLE_ATTR_T_POWER,561).				%%攻击天赋
-define(ROLE_ATTR_T_HITRATE,562).			%%命中天赋
-define(ROLE_ATTR_T_CRITICALRATE,563).		%%暴击天赋
-define(ROLE_ATTR_T_STAMINA,564).			%%体质天赋
-define(ROLE_ATTR_T_GS,565).				%%天赋评分
-define(ROLE_ATTR_GS_SORT,566).				%%天赋评分排名

-define(ROLE_ATTR_PET_POWER,567).				%%攻击点数
-define(ROLE_ATTR_PET_HITRATE,568).				%%命中点数
-define(ROLE_ATTR_PET_CRITICALRATE,569).		%%暴击点数
-define(ROLE_ATTR_PET_STAMINA_ATTR,570).		%%体质点数
-define(ROLE_ATTR_PET_REMAINATTR,571).			%%剩余点数

-define(ROLE_ATTR_PET_QUALITY_VALUE,572).		%%宠物资质
-define(ROLE_ATTR_PET_QUALITY_UP_VALUE,573).	%%宠物资质上限
-define(ROLE_ATTR_PET_LOCK,574).				%%宠物交易锁定 0未锁定1锁定
-define(ROLE_ATTR_PET_RAMINTIME,557).%%宠物升级升级剩余时间
%%物品属性keyvalue对应
-define(ITEM_ATTR_ENCH,501).
-define(ITEM_ATTR_COUNT,502).
-define(ITEM_ATTR_SLOT,503).
-define(ITEM_ATTR_ISBONDED,504).
-define(ITEM_ATTR_DURATION,506).
-define(ITEM_ATTR_OWNERID,507).
-define(ITEM_ATTR_TEMPLATE_ID,508).
-define(ITEM_ATTR_LEFTTIME,509).
-define(ITEM_ATTR_SOCKETS,3509).
%%飞剑对应属性
-define(WING_SHOW,50).

