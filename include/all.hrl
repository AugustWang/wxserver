%% Author:SQ.Wang
%% Created: 2011-7-11
%% Description: TODO: Add description to active_board_def

%%连续登录送礼
%%-record(continuous_logging_gift,{day,normal_gift,vip_gift}).
-record(continuous_logging_gift,{day,reward}).
-record(role_continuous_logging_info,{roleid,info}).

%%元宝福利大放送
%%{activity_test01,1,1,[{{12,0},{12,30}},{{20,0},{20,30}}],2,200}.
-record(activity_test01,{id,enabled,limit_times,money_type,money_count}).
-record(activity_test01_role,{roleid,info}).

%%é¦åç¤¼åé¢å
-record(role_first_charge_gift,{roleid,state,ext}).

%%每日首次登陆提醒
-record(everyday_show,{roleid,offlinetime}).

%%福利面板
-record(role_welfare_activity_info,{roleid_type,serialnumber}).
-record(welfare_activity_data,{type,isshow,starttime,endtime,gift,condition}).
-record(role_gold_exchange_info,{roleid,exchange_ticket}).
-record(background_welfare_data,{type,isshow,starttime,endtime}).
-record(consume_return_info,{roleid,consume_gold}).%% Author: SQ.Wang
%% Created: 2011-7-8
%% Description: TODO: Add description to active_board_def
-define(MAX_DAYS,7).
-define(CONTINUOUS_FROMNAME,63).
-define(CONTINUOUS_NORMAL_TITLE,64).
-define(CONTINUOUS_VIP_TITLE,65).
-define(CONTINUOUS_NORMAL_CONTEXT,66).
-define(CONTINUOUS_VIP_CONTEXT,67).
-define(NEED_LEVEL,25).
-define(CONTINUOUS_LOGIN,1).
-define(DISCONTINUOUS_LOGIN,2).
-define(SAMEDAY_LOGIN,3).
-define(NORMAL,0).
-define(VIP,1).
-define(AWARD_OK,0).
-define(CONTINUOUS_1,1).
-define(CONTINUOUS_2,2).
-define(CONTINUOUS_3,3).
-define(CONTINUOUS_4,4).
-define(ONEDAY,86400).       %%60*60*24

-define(ACTIVITY_STATE_OVER,1).
-define(ACTIVITY_STATE_PROCESS,2).
-define(ACTIVITY_STATE_NOTSTART,3).

-define(FIRST_CHARGE_GIFT_CAN_RECEIVE,1).
-define(FIRST_CHARGE_GIFT_RECEIVED,2).
-define(FIRST_CHARGE_GIFT_CAN_NOT_RECEIVE,3).

-define(FIRST_CHARGE_GIFT_ITEM,24000063).

-define(CLIENT_REQ_INTEVAL_S,60).
-record(activity_info_db,{activityid,activity_info}).

%%@spec activity define
-define(BUFFER_TIME_S,120).
-define(ACTIVITY_STATE_START,1).
-define(ACTIVITY_STATE_STOP,2).
-define(ACTIVITY_STATE_REWARD,3).
-define(ACTIVITY_STATE_INIT,4).
-define(ACTIVITY_STATE_SIGN,5).
-define(ACTIVITY_STATE_END,6).
-define(CANDIDATE_NODES_NUM,2).
-define(START_TYPE_DAY,1).
-define(START_TYPE_WEEK,2).
-define(CHECK_TIME,10000). %%check per 10s


%%
%%add new activity  please modify ACTIVITY_MAX_INDEX !!!!!!!
%%
-define(ANSWER_ACTIVITY,1).
-define(TEASURE_SPAWNS_ACTIVITY,2).
-define(TANGLE_BATTLE_ACTIVITY,3).
-define(YHZQ_BATTLE_ACTIVITY,4).
-define(DRAGON_FIGHT_ACTIVITY,5).
-define(STAR_SPAWNS_ACTIVITY,6).
-define(RIDE_SPAWNS_ACTIVITY,7).
-define(TREASURE_TRANSPORT_ACTIVITY,8).
-define(SPA_ACTIVITY,9).
-define(JSZD_BATTLE_ACTIVITY,10).
-define(GUILD_INSTANCE_ACTIVITY,11).
-define(ACTIVITY_MAX_INDEX,?GUILD_INSTANCE_ACTIVITY).  %% !!!!!!!!!!!!!!!!!

%%spa
-define(SPA_DEFAULT_ID,1).
-define(SPA_PASSIVE_COUNT,10).
-define(SPA_COOL_TIME,120000).
-define(SPA_ROLE_STATE_JOIN,1).
-define(SPA_ROLE_STATE_LEAVE,0).
-define(SPA_TOUCH_TYPE_CHOPPING,1).
-define(SPA_TOUCH_TYPE_SWIMMING,2).


%%treasure_spawns
-define(TREASURE_SPAWNS_DEFAULT_LINE,1).
-define(TREASURE_SPAWNS_TYPE_CHEST,1).		%%treasure chest
-define(TREASURE_SPAWNS_TYPE_STAR,2).		%%treasure star
-define(TREASURE_SPAWNS_TYPE_RIDE,3).		%%treasure ride

-define(ACTIVITY_FORECAST_TIME_S,5*60). 	%%5min

%%
-define(TYPE_CHRISTMAS_ACTIVITY,1).-record(level_activity_rewards_db,{level,dragon_fight_exp}). %%
%%模板表
%%com_condition = {{msg,value},op,targetvalue}
%%
-record(activity_value_proto,{id,type,maxtimes,time,com_condition,value,targetid}).

%%
%%奖励模板表
%%
-record(activity_value_reward,{value,reward}).

-record(role_activity_value,{roleid,state,value,reward}).
-define(MAX_ACTIVITY_VALUE,1000000).		%%最大活跃度

-define(ACTIVITY_TYPE_BOSS,1).			%%活动类型 击杀boss

-define(ACTIVITY_TYPE_ACTIVITY,3).		%%活动类型 活动


-define(UNCOMPLETED,0).
-define(COMPLETE,1).


%%npc的表现行为
-define(ACTION_RESET,0).				%%重置
-define(ACTION_IDLE,1).					%%巡逻
-define(ACTION_ATTACK_TARGET,2).		%%战斗
-define(ACTION_FOLLOW_TARGET,3).		%%跟随
-define(ACTION_RUN_AWAY,4).				%%逃跑

-define(NPC_FOLLOW_DISTANCE,1).			%%npc跟随距离
-define(NPC_FOLLOW_DURATION,1000).		%%跟随反映时间

-define(EVENT_ATTACK,0).				%%攻击
-define(EVENT_DIALOG,1).				%%有人请求npc功能
-define(EVENT_BE_ATTACK,2).				%%被人攻击	
-define(EVENT_SPAWN,3).					%%出生	
-define(EVENT_ENTER_ATTACK,4).			%%开始战斗	
-define(EVENT_LEAVE_COMBAT,5).			%%离开战斗	
-define(EVENT_FOLLOWOWNER,6).			%%跟随	
-define(EVENT_DIED,7).					%%死亡	
-define(EVENT_IDLE,8).					%%开始巡逻	
-define(EVENT_UNIDLE,9).				%%结束巡逻
-define(EVENT_QUEST_FINISHED,10).		%%任务完成
-define(EVENT_QUEST_ACCEPT,11).			%%接受任务
-define(EVENT_OTHER_PLAYER_DIED,12).	%%警戒范围内敌对玩家死亡
-define(EVENT_OTHER_NPC_DIED,13).		%%警戒范围内敌对npc死亡

-define(EVENT_SECTION_UNITS_SPAWN,101). %%npc按波数启动怪物
-define(EVENT_CHESS_SPIRIT_GAME_START,102). %%棋魂游戏开启


-define(EVENT_NULL,-1).					%%非触发

-define(AI_TYPE_SPELL,1).				%%技能释放
-define(AI_TYPE_HELP,2).				%%呼救
-define(AI_TYPE_SCRIPT,3).				%%脚本

-define(AI_TYPE_TARGET_NULL,0).			%%无目标释放(范围群攻)
-define(AI_TYPE_TARGET_ENEMY,1).		%%对敌人释放
-define(AI_TYPE_TARGET_SELF,2).			%%对自己释放
-define(AI_TYPE_TARGET_OWNNER,3).		%%对主人释放(召唤,求助自己的人)

-define(AI_TYPE_TARGET_MASTER,4).		%%对主人释放(生成自己的人)

-define(AI_TYPE_TARGET_HATRED_RAND,5).	%%自己的其他仇恨者随机
-define(AI_TYPE_TARGET_MASTER_HATRED_FIRST,6).	%%主人的第一仇恨者
-define(AI_TYPE_TARGET_MASTER_HATRED_RAND,7).	%%主人的其他仇恨者随机

-define(AI_SUMMON_POS_TYPE_MY,1).		%%在我的位置上召唤
-define(AI_SUMMON_POS_TYPE_DEAFUALT,2).			%%按默认复活


%%仇恨操作  
-define(NO_HATRED,0).

-define(NORMAL_HATRED,1).
-define(ACTIVE_HATRED,2).
-define(BOSS_HATRED,3).

-define(INVIEW_NPC_HATRED,5).
-define(INVIEW_ROLE_HATRED,10).
-define(HELP_HATRED,20).
-define(ATTACKER_HATRED,50).

%%移动类型
-define(MOVE_TYPE_AREA,1).
-define(MOVE_TYPE_PATH,2).
-define(MOVE_TYPE_POINT,3).
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
-define(ROLE_ATTR_PET_DROPRATE,556).		%%被攻击下马概率
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



%%{摊位号,玩家信息,摊位名称,拍卖物品,扩展}
-record(auction,{id,roleinfo,nickname,items,stallmoney,create_time,ext}).
-define(ACUTION_ITEMS_MAXNUM,8).
-define(ACUTION_SERCH_TYPE_ALL,0).
-define(ACUTION_SERCH_TYPE_ITEMNAME,1).

-define(ACUTION_MAX_LOG_NUM,10).

-define(ACUTION_SERCH_RECORD_NUM,20).
-define(ACUTION_SERCH_ITEM_RECORD_NUM,12).

-define(ACUTION_OVERDUA_CHECK_DURATION,600000).

-define(ACUTION_OVERDUA_TIME,86400000).

-define(REBACK_ITEM_NUM_ONCE_MAIL,3).-define(ERLNULL,undefined).-define(ZONEIDLE,0).			%%为占领
-define(TAKEBYRED,1).			%%红方占领
-define(TAKEBYBLUE,2).			%%蓝方占领
-define(REDGETFROMBLUE,3).		%%红方占领一半
-define(BLUEGETFROMRED,4).		%%蓝方占领一半

-define(ZONEA,1).			
-define(ZONEB,2).		
-define(ZONEC,3).			
-define(ZONED,4).			
-define(ZONEE,5).

-define(KEYZONE,?ZONEE).	%%关键区域
-define(REDZONE,?ZONEB).	%%红色区域
-define(BLUEZONE,?ZONED).	%%蓝色区域

-define(YHZQ_CHANGE_STATE_TIME_S,30).	%%旗帜转换时间 10s

%% YHZQ BORN POS   [[red],[blue],[best,....]]
-define(CAMP_RED_BORNPOS_INDEX,1).				%% red  born pos index in the map data
-define(CAMP_BLUE_BORNPOS_INDEX,2).				%% blue born pos index in the map data
-define(CAMP_BEST_BORNPOS_INDEX,3).				%% best born pos index in the map data


-define(YHZQ_ROLE_IDLE,1).
-define(YHZQ_ROLE_READY,2).
-define(YHZQ_ROLE_PROCESS,3).
-define(YHZQ_ROLE_AWARD,4).
-define(YHZQ_ROLE_OVER,5).

-define(YHZQ_SOMEONE_APPLY,1).
-define(YHZQ_GROUP_APPLY,2).

-define(LAMSTER_BUFF_ID,721000001).			%%逃兵buffer

%%
%%  yhzq 战场 类型
%%
-define(YHZQ_30_49,1).
-define(YHZQ_50_69,2).
-define(YHZQ_70_89,3).
-define(YHZQ_90,4).
-define(YHZQ_30_100,5).			%%不限制级别

%%
%% yhzq 战场状态
%%
-define(YHZQ_PROCESS,1).			%%正在进行
-define(YHZQ_AWARD,2).			%%正在颁奖

%%
%% yhzq 阵营
%%
-define(YHZQ_CAMP_RED,1).				%%
-define(YHZQ_CAMP_BLUE,2).


-define(YHZQ_GROUP_BY_LEVEL,1).	%%按级别分组
-define(YHZQ_GROUP_ALL,2).		%%所有级别一块分组
-define(DEFAULT_YHZQ_GROUP_TYPE,?YHZQ_GROUP_BY_LEVEL).

-define(YHZQ_JION_GUILD_NUM,10).	%%

%% for db
-define(YHZQ_KILL_HONER_ETS,yhzq_kill_honor_ets).
-record(role_level_sitdown_effect_db,{level,exp,soulpower,hppercent,mppercent,zhenqi}).


-record(role_level_bonfire_effect_db,{level,exp,soulpower}).

-record(chess_spirit_config,{npcid,type,fixed_skills,random_skills,max_section,section_duration,chess_skills,chess_max_power,chess_power_addation}).
-record(chess_spirit_section,{type_section,power_rewards,spawns,item_rewards,skills_level}).
-record(chess_spirit_rewards,{type_level,exp_args,expect_sec}).
-record(role_chess_spirit_log,{roleid,last_info,best_info,ext}).
-define(CHESS_SPIRIT_TYPE_SINGLE,1).
-define(CHESS_SPIRIT_TYPE_TEAM,2).

-define(CHESS_SPIRIT_SKILL_TYPE_SHARE,1).
-define(CHESS_SPIRIT_SKILL_TYPE_SELF,2).
-define(CHESS_SPIRIT_SKILL_TYPE_CHESS,3).

-define(CHESS_SPIRIT_RESULT_LEAVE,0).
-define(CHESS_SPIRIT_RESULT_FAILED,1).
-define(CHESS_SPIRIT_RESULT_SUCCESS,2).

-define(START_PREPARE_TIME,11000).
-define(GAME_OVER_KICK_TIME,10000).-record(christmas_tree_config,{npcid,init_hp,max_hp,next_proto}).
-record(christmas_tree_db,{npcid,now_hp,max_hp}).
-record(christmas_activity_reward,{type,consume,reward}).



-define(NPC_FINAL_TREE,2063099).		%%大圣诞树
-define(NPC_MIDDLE_TREE,2062099).		%%中圣诞树
-define(NPC_SMALL_TREE,2061099).		%%小圣诞树
-define(CHRISTMAS_TREE_BORN_LINE,1).	%%只在1线刷
-define(COLOR_WHITE,16#ffffff).
-define(COLOR_GREEN,16#00FF00).
-define(COLOR_BLUE,16#3399ff).
-define(COLOR_PURPLE,16#ff00ff).
-define(COLOR_GOLDEN,16#CD7F32).

-ifndef(COMMON_DEFINE_H).
-define(COMMON_DEFINE_H,true).


-define(SERVER_MAX_ROLE_NUMBER,50000000).
-define(MIN_ROLE_ID,10000000).
-define(DYNAMIC_NPC_INDEX,9000000).
-define(DYNAMIC_NPC_NUM_MAX,999999).
-define(MIN_PET_ID,1000000000).


%%生物阵营
-define(FACTION_NORMAL_MAN,0).
%%人物移动
-define(BASE_MOVE_SPEED,7).	
-define(MOVE_ASYNC_NUM,3).
-define(MOVE_MAX_DEALY_TIME,500).
-define(MOVE_CHEAT_THREAT,100).
-define(MOVE_CHEAT_TOLERANCE,0.7).
%%脱离战斗时间
-define(LEAVE_ATTACK_TIME,5000).
%%玩家视野
-define(CREATURE_VIEW_RANGE,28).
%%Db存储间歇
-define(DB_SAVE_TIME,300000).
%%最大等级
-define(ROLE_MAX_LEVEL,100).
%%性别
-define(GENDER_MALE,1).				
-define(GENDER_FEMALE,0).
%%移动更新距离间隔
-define(MOVE_UPDATE_RANGE,3).
%%路径长度
-define(PATH_POIN_NUMBER,3).
%%玩家路径长度
-define(ROLE_PATHLEN_MAX,9).
%%Npc功能使用距离
-define(NPC_FUNCTION_DISTANCE,10).			%%功能使用距离,包括传送和npc等
%%包裹停留时间
-define(LOOT_DELEAY_TIME,30000).
%%死亡标志
-define(DEADTYPE_UNITS,1).						%%被怪物杀死
-define(DEADTYPE_ROLES,2).						%%被玩家杀死
-define(DEADTYPE_PRISON,3).						%%被送入监狱

-define(EQUIPMENT_CONSUME_RATE,2).				%%装备消耗几率

%%重生标志
-define(RESPAWN_INPOINT,1).						%%回到重生点的普通复活(打怪死亡)
-define(RESPAWN_WITH_CHTHEAL_INSITU,2).			%%狂.春哥之庇护->满血满蓝原地复活(打怪死亡):要令牌
-define(RESPAWN_WITH_CHTHEAL_INPOINT,3).		%%回到重生点,满血满蓝(PK死亡)
-define(RESPAWN_NONEED_LEVEL,20).				%%免费复活级别

%%职业
-define(CLASS_MAGIC,1).					%%法师
-define(CLASS_RANGE,2).					%%射手
-define(CLASS_MELEE,3).					%%战士
-define(MELEE_MANA_ADD_BY_ATTACK,3).	%%战士被攻击时的怒气增长

%%金钱
-define(MONEY_BOUND_SILVER,1).			%%绑定游戏币
-define(MONEY_GOLD,2).					%%充值元宝
-define(MONEY_TICKET,3).				%%礼券
-define(MONEY_CHARGE_INTEGRAL,4).		%%充值积分
-define(MONEY_CONSUMPTION_INTEGRAL,5).	%%消费积分
-define(MONEY_SILVER,6).				%%游戏币
-define(MONEY_HONOR,7).					%%荣誉
-define(TYPE_GUILD_CONTRIBUTION,10).	%%帮贡

-define(TIME_OUT_ACTION,(6000*1000*1000)).

%%拾取距离
-define(LOOT_DISTANSE,15).
%%最大生星级别
-define(MAX_ENCHANTMENTS,12).
-define(MAX_SOCKET_NUM,4).	%%最大槽数

%%组队
-define(MAX_GROUP_SIZE,5).
-define(INVITE_DELETE_TIME,25*1000).
-define(GROUP_UPDATE_TIME,5000).

%%chat 定义
-define(CHAT_TYPE_WORLD,1).       %% 世界
-define(CHAT_TYPE_INTHEVIEW,2).       %% 附近
-define(CHAT_TYPE_PRIVATECHAT,3).       %% 私聊
-define(CHAT_TYPE_GROUP,4).       %% 组队
-define(CHAT_TYPE_SYSTEM,5).       %% 系统消息
-define(CHAT_TYPE_GM_NOTICE,6).       %%Gm喊话
-define(CHAT_TYPE_LARGE_EXPRESSION,14). %%大表情

-define(CHAT_TYPE_GUILD,7).
-define(CHAT_TYPE_ROLLTEXT,8).
-define(CHAT_TYPE_GENERAL,9).
-define(CHAT_TYPE_LOUDSPEAKER,12).
-define(CHAT_TYPE_BATTLE,13).

-define(SRC_CHAT,1). %% 私聊发起者聊天
-define(DEST_CHAT,2). %% 私聊接收者聊天

%%更新信息
-define(UPDATETYPE_ROLE,1).		%%玩家
-define(UPDATETYPE_NPC,2).		%%Npc/怪物
-define(UPDATETYPE_PET,3).		%%物品
-define(UPDATETYPE_SELF,0).		%%自己
-define(ROLE_GAME_TIME,10000).	%%玩家timer,10秒一次

%%GM:
-define(GM_BLOCK_TYPE_LOGIN,1).									%%禁登录
-define(GM_BLOCK_TYPE_TALK,2).									%%禁言

%%挂机涨经验间隔
-define(TRAINING_TIME,10000).			%%10s
-define(CHARGE_SYSTEM_KEY,1).               %%充值开放标志

%%战场类型
-define(TANGLE_BATTLE,1).					%%群p
-define(YHZQ_BATTLE,2).					%%阵营对战  资源占领   
-define(JSZD_BATTLE,3).					%%帮会抢夺资源   
-define(GUILD_BATTLE,4).					%%帮会战 

%%群p类型
-define(TANGLE_BATTLE_50_100,1).
%%最大的上榜排名
-define(MAX_TANGLE_RECORD_RANK,10).

%%时间计算:清空类型
-define(DUE_TYPE_DAY,1).

%%普通攻击释放间隔 0.8s
-define(NORMALSKILLCD,800).

%%非普通攻击公共冷却时间 0.5s 
-define(UNNORMALSKILLCD,500).

%%
-define(REGISTER_ENABLE,1).	%%开放新角色注册 

%%角色身份
-define(ROLE_IDEN_COM,0).		%%普通玩家
-define(ROLE_IDEN_GM,1).		%%GM
-define(ROLE_IDEN_GUIDE,2).		%%指导员
-define(ROLE_IDLE_NPC,3).		%%NPC
-define(ROLE_IDLE_KING,10).		%%国王
-define(ROLE_IDLE_GENERAL,11).		%%将军
-define(ROLE_IDLE_SOLIDER,12).		%%卫队


-define(GM_ACCOUNT_FLAG,3).		%%gm帐号标志 能使用GM命令


-define(DEFAULT_ROLE_DISPLAYID,0).		






-endif.		%%请在这个上面定义

-record(country_proto,{post,	%%职位
					   num,		%%个数
					   items_l30,	%%level30专属道具
					   items_l50,	%%level50专属道具
					   items_l70,	%%level70专属道具
					   reward,	%%日常奖励
					   blocktalktimes,%%禁言次数
					   remittimes,	%%赦免次数
					   punishtimes, %%惩罚次数
					   appointtimes, %%任命次数
					   items_useful_time_s	%%专属道具有效时间
					  }).

-record(country_record,{countryid,postinfo,countryinfo,ext}).%%
%%define for country 
%%
-define(POST_KING,1).	%%国王
-define(POST_GENERAL,2).%%将军
-define(POST_SOLIDER,3).%%护卫
-define(POST_COMMON,4).	%%平民

-define(POST_ICON_ID,[20,21,22]).		%%官员头顶图标id

-define(POST_STR,[?STR_KING,?STR_GENERAL,?STR_SOLIDER]).		%%官员对应字符串

-define(BLOCK_TALK_TIME_S,30*60).%%禁言时间  秒
-define(ADD_CRIME,100).			%%每次增加的罪恶值
-define(REDUCE_CRIME,100).		%%每次减少的罪恶值

-define(LEADER_PUNISH,1).		%%惩罚
-define(LEADER_REMIT,2).		%%赦免

-define(COUNTRY_FIRST,1).		%%国家编号  有可能会有多个国家
-define(TOTAL_COUNTRYS,1).		%%国家个数

-define(KING_ITEMS_USEFUL_TIME_S,7*24*60*60).		%%国王套装有效时间 秒

-define(LEADER_CAN_REWARD_TIME_S,24*60*60).			%%上任后1天可领取日常奖励
%%-define(LEADER_CAN_REWARD_TIME_S,60).			%%上任后1天可领取日常奖励%%生物状态
-define(CREATURE_STATE_DEAD,0).						%%死亡
-define(CREATURE_STATE_GAME,1).						%%正常
-define(CREATURE_STATE_BLOCK_TRAINING,2).			%%密修打坐
-define(CREATURE_STATE_SITDOWN,3).					%%打坐

%%生物标志
-define(CREATURE_ROLE,0).				%%玩家
-define(CREATURE_NPC,1).				%%npc
-define(CREATURE_MONSTER,2).			%%怪物
-define(CREATURE_COLLECTION,3).			%%可采集的物体
-define(CREATURE_PET,4).				%%宠物
-define(CREATURE_YHZQ_NPC,5).			%%永恒之旗战场特殊NPC
-define(CREATURE_THRONE,6).				%%战场王座
-define(CREATURE_KING_STATUE,7).		%%国王雕像

-define(DEFAULT_MAX_DISTANCE,10000000).	%%查找最近时的默认距离%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 说明: 
%%     gs 表示该 record 是在game_server内部用的数据结构;
%%     system 表示该 record 的信息是基础系统的信息, 与游戏逻辑系统没有关系;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 基础系统的地图数据 Map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-ifndef(DATA_STRUCT_H).
-define(DATA_STRUCT_H,true).

-record(gs_system_map_info, {map_id, line_id, map_proc, map_node}).

get_proc_from_gs_system_mapinfo(GS_system_mapinfo)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	#gs_system_map_info{map_proc=Proc} = GS_system_mapinfo,
	Proc.
set_proc_to_gs_system_mapinfo(GS_system_mapinfo, Proc)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	GS_system_mapinfo#gs_system_map_info{map_proc=Proc}.

get_node_from_gs_system_mapinfo(GS_system_mapinfo)    
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	#gs_system_map_info{map_node=Node} = GS_system_mapinfo,
	Node.
set_node_to_gs_system_mapinfo(GS_system_mapinfo, Node)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	GS_system_mapinfo#gs_system_map_info{map_node=Node}.

get_mapid_from_gs_system_mapinfo(GS_system_mapinfo)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	#gs_system_map_info{map_id=Id} = GS_system_mapinfo,
	Id.
set_mapid_to_gs_system_mapinfo(GS_system_mapinfo, Id)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	GS_system_mapinfo#gs_system_map_info{map_id=Id}.

get_lineid_from_gs_system_mapinfo(GS_system_mapinfo)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	#gs_system_map_info{line_id=Line_id} = GS_system_mapinfo,
	Line_id.
set_lineid_to_gs_system_mapinfo(GS_system_mapinfo, Line_id)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	GS_system_mapinfo#gs_system_map_info{line_id=Line_id}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 基础系统的角色数据 Role
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-compile({inline, [{get_id_from_gs_system_roleinfo,1}]}).

-record(gs_system_role_info, {role_id, role_pid,role_node}).

get_id_from_gs_system_roleinfo(GS_system_role_info) 
  when is_record(GS_system_role_info, gs_system_role_info) ->
	#gs_system_role_info{role_id=Id} = GS_system_role_info,
	Id.
set_id_to_gs_system_roleinfo(GS_system_role_info, Id)
  when is_record(GS_system_role_info, gs_system_role_info) ->
	GS_system_role_info#gs_system_role_info{role_id=Id}.

get_pid_from_gs_system_roleinfo(GS_system_role_info)
  when is_record(GS_system_role_info, gs_system_role_info) ->
	#gs_system_role_info{role_pid=Pid} = GS_system_role_info,
	Pid.
set_pid_to_gs_system_roleinfo(GS_system_role_info, Pid)
  when is_record(GS_system_role_info, gs_system_role_info) ->
	GS_system_role_info#gs_system_role_info{role_pid=Pid}.
	
get_node_from_gs_system_roleinfo(GS_system_role_info)
  when is_record(GS_system_role_info, gs_system_role_info) ->
	#gs_system_role_info{role_node=Role_node} = GS_system_role_info,
	Role_node.
set_node_to_gs_system_roleinfo(GS_system_role_info, Role_node)
  when is_record(GS_system_role_info, gs_system_role_info) ->
	GS_system_role_info#gs_system_role_info{role_node=Role_node}.	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 基础系统的网关信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(gs_system_gate_info, {gate_proc, gate_node, gate_pid}).

get_proc_from_gs_system_gateinfo(GS_system_gate_info)
  when is_record(GS_system_gate_info, gs_system_gate_info) ->
	#gs_system_gate_info{gate_proc=Proc} = GS_system_gate_info,
	Proc.
set_proc_to_gs_system_gateinfo(GS_system_gate_info, Proc)
  when is_record(GS_system_gate_info, gs_system_gate_info) ->
	GS_system_gate_info#gs_system_gate_info{gate_proc=Proc}.

get_node_from_gs_system_gateinfo(GS_system_gate_info)
  when is_record(GS_system_gate_info, gs_system_gate_info) ->
	#gs_system_gate_info{gate_node=Node} = GS_system_gate_info,
	Node.
set_node_to_gs_system_gateinfo(GS_system_gate_info, Node)
  when is_record(GS_system_gate_info, gs_system_gate_info) ->
	GS_system_gate_info#gs_system_gate_info{gate_node=Node}.

get_pid_from_gs_system_gateinfo(GS_system_gate_info)
  when is_record(GS_system_gate_info, gs_system_gate_info) ->
	#gs_system_gate_info{gate_pid=Pid} = GS_system_gate_info,
	Pid.
set_pid_to_gs_system_gateinfo(GS_system_gate_info, Pid)
  when is_record(GS_system_gate_info, gs_system_gate_info) ->
	GS_system_gate_info#gs_system_gate_info{gate_pid=Pid}.
	
-endif.
-record(role_designation_info,{roleid,cur_designation,designation_info}).
-record(designation_data,{key,attr_addition}).
-record(dragon_fight_db,{id,start_pos,duration,relation_questid,red_dragon_buff,blue_dragon_buff}).
-record(npc_dragon_fight,{npcid,faction}).
-define(DRAGON_FIGHT_FACTION_BLUE,1).			%%blue dragon
-define(DRAGON_FIGHT_FACTION_RED,2).			%%red dragon

-define(DRAGON_NPC_STATE_NOTSTART,0).		%%notstart
-define(DRAGON_NPC_STATE_NOQUEST,1).		%%no_quest
-define(DRAGON_NPC_STATE_IN_FACTION,2).		%%has in this faction
-define(DRAGON_NPC_STATE_NOTIN_FACTION,3).	%%not in this faction
-define(DRAGON_NPC_STATE_END,4).			%%gameover


-define(USER_RESULT_NOT_JOIN,1).			%%not join 
-define(USER_RESULT_HALF,2).				%%half match
-define(USER_RESULT_WIN,3).					%%win
-define(USER_RESULT_LOSE,4).				%%lose-define(EFFECT_FOR_PRISON,1).   %%对全服使用
-define(EFFECT_FOR_ALL,2).		%%对单个人使用
-define(EFFECT_FOR_AOI,3).		%%对aoi中人使用
-define(EFFECT_TYPE_ROSE,1).	%%特效类型雪花
-define(EFFECT_TYPE_SNOW,2).	%%特效类型雪花
-define(EFFECT_TYPE_LANTERNS,3).%%特效类型孔明灯

-define(EFFECT_EXP_COMMON,1).	%%普通经验 只对打怪有效
%%-define(EFFECT_EXP_BLOCK_TRAINING,2).%%	密修经验	只对密修有效
-define(EFFECT_EXP_SPA,2).		%%温泉加成
-define(EFFECT_EXP_BONFIRE,3).	%%篝火加成


-define(BACK_ECHANTMENT_STONE_ETS,back_echantment_stone_ets).

-define(ENCHANT_OPT_ETS,enchant_opt_ets).

-define(ENCHANT_PROPERTY_OPT_ETS,enchant_propery_opt_ets).

-define(ENCHANT_CONVERT_ETS,enchant_convert_ets).

-define(ENCHANT_EXTREMELY_PROPERTY_OPT_ETS,enchant_extremely_propery_opt_ets).

-define(ENCHANTMENTS_ETS,enchantments_table).

-define(SOCK_ETS,sock_table).

-define(INLAY_ETS,inlay_table).

-define(REMOVE_SEAL_ETS,remove_seal_table).

-define(EQUIPMENT_MOVE_ETS,move_table).

-define(STONEMIX_ETS,stonemix_table).

-define(EQUIPMENT_UPGRADE_ETS,equipment_upgrade_table).

-define(EQUIPMENT_FENJIE_ETS,equipment_fenjie).

-define(ITEM_QUALITY_WHITE,0).

-define(SUCCESS,1).
-record(enchantments,{level,bonuses,consum,riseup,successrate,failure,protect,return,lucky,set_attr,add_attr,successsysbrd,faildsysbrd,faildsysbrdwithprotect}).
-record(sock,{punchnum,consume,money,rate}).    
-record(inlay,{level,type,stonelevel,remove}).
-record(stonemix,{stoneclass,rate,silver,gold,result}).
-record(remove_seal,{equipid,needitem,needitemcount,needmoney,resultid}).
-record(back_echantment_stone,{id,back_stone}).
-record(equipment_upgrade,{equipid,needitem,needitemcount,needmoney,resultid}).
-record(equipment_fenjie,{quality,needmoney,result,resultcount}).
-record(enchant_opt,{id,enchant,recast,recast_gold,enchant_gold,convert_gold,property_count}).
-record(enchant_property_opt,{id,property,priority,max_count,group,min_value,max_value,min_priority,max_priority,max_quality_range}).
-record(enchant_convert,{property,convert}).
-record(enchant_extremely_property_opt,{id,property,priority,max_count,group,min_value,max_value,min_priority,max_priority,max_quality_range}).
-record(enchantments_lucky,{id,rate}).
-record(equipment_move,{flevel,tlevel,needmoney,needitem}).




-define(MAX_LUCKY_ITEM_NUM,5).	%%

-define(MIN_SYSBRD_STAR,5).	

-define(MIN_ENCHANTMENTS_TO_NEVER_EXPIRES,8).
%% Author: adrian
%% Created: 2010-6-25
%% Description: TODO: Add description to error_msg

%%creating role 
-define(ERR_CODE_ROLENAME_EXISTED,10001). %%用户名已存在
-define(ERR_CODE_ROLENAME_INVALID,10002). %%非法用户名
-define(ERR_CODE_CREATE_ROLE_INTERL,10003). %%创建失败
-define(ERR_CODE_CREATE_ROLE_REGISTER_DISABLE,10004). %%不允许创建新角色
-define(ERR_CODE_CREATE_ROLE_EXISTED,10005).		%%该账户下的角色已创建


-define(ERRNO_JOIN_MAP_ERROR_MAPID,10006).			%%当前地图无法进入
-define(ERRNO_JOIN_MAP_ERROR_UNKNOWN,10007).		%%无法登入服务器,请进入官网联系GM

%%PK
-define(ATTACK_ERROR_NOWEAPON, 10011).						%%没有武器
-define(ATTACK_ERROR_COOLTIME, 10012).						%%cd
-define(ATTACK_ERROR_MP, 10013).							%%Mp
-define(ATTACK_ERROR_SAFE_ZONE, 10014).						%%安全区
-define(ATTACK_ERROR_RANGE, 10015).							%%距离
-define(ATTACK_ERROR_ERROR_STATE, 10016).					%%cd
-define(ATTACK_ERROR_TARGET_GOD, 10017).					%%目标无敌	
-define(ATTACK_ERROR_SILENT, 10018).						%%沉默
-define(ATTACK_ERROR_COMA, 10019).							%%昏迷

%%帮会
-define(GUILD_ERRNO_UNKNOWN,10020).								%%未知
-define(GUILD_ERRNO_ALREADY_IN_GUILD,10022).					%%已经在公会
-define(GUILD_ERRNO_NOT_IN_GUILD,10023).						%%没有在公会
-define(GUILD_ERRNO_MONEY_NOT_ENOUGH,10008).					%%钱不够
-define(GUILD_ERRNO_ITEM_NOT_ENOUGH,10025).						%%缺少物品
-define(GUILD_ERRNO_CREATE_INVALIDNAME,10026).					%%名称错误
-define(GUILD_ERRNO_CREATE_REPEADNAME,10027).					%%名称重复
-define(GUILD_ERRNO_LESS_AUTH,10028).							%%权限不足 
-define(GUILD_ERRNO_GUILD_FULL,10029).							%%帮会已满
-define(GUILD_ERRNO_CANNOT_FIND_ROLE,10030).					%%角色不在线
-define(GUILD_ERRNO_HAS_BEEN_INVITED,10031).					%%已被邀请
-define(GUILD_ERRNO_GUILD_POST_FULL,10032).						%%职位人数上限
-define(GUILD_ERRNO_GUILD_UPGRADE_FULL,10033).					%%升级已达上限
-define(GUILD_ERRNO_GUILD_UPGRADING,10034).						%%正在升级中
-define(GUILD_ERRNO_GUILD_LEAVE_RESTRICT,10035).				%%距离上次离开帮会不足24小时
-define(GUILD_ERRNO_APPLYINFO_ALREADY_OP,10036).				%%已经被审核处理过
-define(GUILD_ERRNO_LESS_CONTRIBUTION,10037).					%%帮贡不足
-define(GUILD_ERRNO_LIMITNUM,10038).							%%到达限购数
-define(GUILD_ERRNO_APPLYNUM_FULL,10039).						%%申请人数已满
-define(GUILD_PACKAGE_LIMIT_BIND,1).      %%帮会仓库权限禁止
-define(GUILD_PACKAGE_LIMIT_NOBIND,0).%%帮会仓库权限不禁止

%%组队
-define(ERR_GROUP_UNKNOW,10040).								%%未知
-define(ERR_GROUP_NO_ERROR,10041).								%%组队已解散
-define(ERR_GROUP_IS_NOT_IN_YOUR_GROUP,10042).					%%不在你组
-define(ERR_GROUP_IS_FULL,10043).								%%组满
-define(ERR_GROUP_ALREADY_IN_GROUP,10044).						%%已经在组里
-define(ERR_GROUP_ALREADY_INVITE,10045).						%%已经邀请
-define(ERR_GROUP_YOU_ARENT_IN_A_GROUP,10046).					%%你尚未在组
-define(ERR_GROUP_YOU_ARE_NOT_LEADER,10047).					%%你不是队长
-define(ERR_GROUP_CANNOT_FIND_ROLE,10048).						%%找不到角色
-define(ERR_GROUP_UNRECRUITMENT_FULL,10049).					%%队伍人满,招募取消
-define(ERR_GROUP_UNRECRUITMENT_JOIN_INSTANCE,10050).					%%副本已开启,招募取消

%%通用
-define(ERROR_LESS_LEVEL,10021).		%%等级不足
-define(ERROR_LESS_MONEY,10024).		%%钱不够
-define(ERROR_MISS_ITEM,10025).			%%缺少物品
-define(ERROR_PACKEGE_FULL,10051).		%%包裹满
-define(ERROR_LESS_HONOR,10052).		%%缺少荣誉
-define(ERROR_LESS_GOLD,10071).         %%元宝不够
-define(ERROR_LESS_TICKET,10072).       %%礼券不够
-define(ERROR_LESS_INTEGRAL,10070).		%%积分不够
-define(ERROR_NOT_LEAVE_ATTACK,10077).			%%尚未脱离战斗
-define(ERROR_UNKNOWN,10003).				%%未知错误

%%买卖
-define(ERROR_TRAD_CANNOT_SELL,10061).	%%不可出售

%%商城
-define(ERROR_LIMIT_COUNT,10073).			%%限量物品已卖空
-define(ERROR_LIMIT_TIME,10074).			%%限时物品已超时
-define(ERROR_PRICE_PREPAIR,10075).			%%与服务器价格不匹配，请刷新页面
-define(ERROR_MALL_ITEM_RESTRICT,10078).	%%你超过购买个数限制
-define(ERROR_SALES_ITEM_SHELVES,10079).	%%优惠物品已下架

%%副本
-define(ERRNO_INSTANCE_DATELINE,10080).			%%非进入时间段
-define(ERRNO_INSTANCE_LESSMEMBER,10081).		%%人数不足
-define(ERRNO_INSTANCE_QUEST,10082).			%%没有相应任务
-define(ERRNO_INSTANCE_BUFF,10083).				%%缺少buff
-define(ERRNO_INSTANCE_TIMES,10084).			%%次数已满
-define(ERRNO_INSTANCE_NOTEAM,10085).			%%没有组队
-define(ERRNO_INSTANCE_TEAMLEADER,10086).		%%需要队长先进入副本
-define(ERRNO_INSTANCE_NOGUILD,10087). 			%%没有公会
-define(ERRNO_INSTANCE_MOREMEMBER,10088). 		%%人数已满
-define(ERRNO_INSTANCE_RESETING,10089). 		%%副本重置中,稍后再试
-define(ERRNO_INSTANCE_UNKNOWN,10090).			%%使用过多,请稍后再试
-define(ERRNO_INSTANCE_FINQUEST,10091).			%%没有完成相应任务
-define(ERRNO_INSTANCE_LEVELRESTRICT,10092).	%%当前等级不能进入该副本
-define(ERRNO_INSTANCE_EXSIT,10093).			%%当前队伍已有副本,不能再进入新副本


%% 邮件
-define(ERRNO_MAILBOX_FULL,10100). %%对方邮箱已满
-define(ERRNO_MAIL_INTERL, 10101). %%服务器内部错误
-define(ERRNO_MAIL_NO_MAIL,10102). %%此邮件已经不存在
-define(ERRNO_MAIL_NO_ROLE,10103). %%此角色不存在
-define(ERRNO_MAIL_NO_ITEM,10104). %%物品不存在
-define(ERRNO_MAIL_ITEMBOND,10105). %%物品已经绑定
-define(ERRNO_MAIL_NOTENOUGH_SILVER,10107). %%游戏币不够
-define(ERRNO_MAIL_SILVER_LEVEL_RESTRICT,10108). %%低于40级不可邮寄金币

%%棋魂
-define(ERRNO_CHESS_SPIRIT_UP_LEVEL_MAX,10110).			%%技能已达到最大级别,无法升级
-define(ERRNO_CHESS_SPIRIT_REWARD_SUCCESS,10111).		%%领取奖励成功

%%好友
-define(ERROR_FRIEND_OFFLINE,10201).			%%此用户不在线，不能加为好友
-define(ERROR_FRIEND_FULL,10202).				%%你的好友超过最高限制
-define(ERROR_FRIEND_EXIST,10203).				%%已经是你的好友
-define(ERROR_FRIEND_NOEXIST,10204).			%%此人不是你的好友，不能删除
-define(ERROR_FRIEND_MYSELF,10205).				%%不能加自己为好友
-define(ERROR_FRIEND_NO_SIGNATURE,10206).		%%好友无签名
-define(ERROR_BLACK_NOEXIST,10207).				%%此人不在黑名单里
-define(ERROR_ISBLACK,10208).					%%此人在黑名单中，不能加为好友
-define(ERROR_BLACK_FULL,10209).				%%黑名单数已超过最高限制
-define(ERROR_FRIEND_OFFLINE,10210).				%%您的好友已经下线，不能添加


%%聊天
-define(ERRNO_NOT_ONLINE,10304).
-define(ERRNO_HAS_NOGROUP,10305).
-define(ERRNO_CHAT_COOLDOWN,10306).
-define(ERRNO_MAX_LOUDSPEAK,10307).                 %%喇叭使用排队人数到达上限
-define(ERRNO_HAS_NOBATTLE,10308).

%% npc 错误
-define(ERRNO_NPC_POSITION,10401).		%%不在可用范围内
-define(ERRNO_NPC_NOFUNCTION,10402).	%%无此功能
-define(ERRNO_NPC_EXCEPTION,10403).		%%未知错误

%%交易返回
-define(TRADE_ERROR_YOU_ARE_DEAD,10501).			%%你死了
-define(TRADE_ERROR_TARGET_ARE_DEAD,10502).			%%交易对象死亡
-define(TRADE_ERROR_IS_NOT_AOI,10503).				%%不在视野内
-define(TRADE_ERROR_NO_SUCH_ROLE,10504).			%%玩家未找到
-define(TRADE_ERROR_TRADING_NOW,10505).				%%正在交易中		
-define(TRADE_ERROR_EXCEPTION,10507).				%%系统错误

%%装备
-define(ERROR_EQUIPMENT_CANT_FENJIE,10598).			%%装备不可分解
-define(ERROR_EQUIPMENT_CANT_UPGRADE,10599).		%%装备不可升级
-define(ERROR_EQUIPMENT_CANT_SEAL,10600).			%%装备不可解封
-define(ERROR_EQUIPMENT_NOEXIST,10601).				%%装备不在包裹里
-define(ERROR_EQUIPMENT_RISEUP_NOEXIST,10602).		%%升星道具不在包裹里
-define(ERROR_EQUIPMENT_PROTECT_NOEXIST,10603).		%%升星保护道具不在包裹里
-define(ERROR_EQUIPMENT_RISEUP_NOT_MATCHED,10604).	%%升星道具不匹配
-define(ERROR_EQUIPMENT_MAX,10605).					%%星级已满，不能升星
-define(ERROR_SOCKETS_MAX,10606).					%%孔数达到最大值，不能打孔
-define(ERROR_EQUIPMENT_SOCKETS_NOEXIST,10607).		%%打孔道具不存在
-define(ERROR_EQUIPMENT_SOCKETS_NOT_MATCHED,10608).	%%打孔道具不匹配
-define(ERROR_SOCKETS_CANT_SOCK,10609).				%%该装备不能打孔
-define(ERROR_EQUIPMENT_INLAY_NOEXIST,10610).		%%镶嵌宝石不存在
-define(ERROR_EQUIPMENT_INLAY_TYPE_NOT_MATCHED,10611).		%%镶嵌宝石类型不匹配
-define(ERROR_EQUIPMENT_INLAY_LEVEL_NOT_MATCHED,10612).		%%镶嵌宝石等级不匹配
-define(ERROR_EQUIPMENT_CANT_INLAY,10613).					%%镶嵌孔不存在或者已有宝石
-define(ERROR_EQUIPMENT_REMOVE_NOEXIST,10614).				%%拆除宝石道具不存在
-define(ERROR_EQUIPMENT_REMOVE_PACKAGE_FULL,10615).			%%包裹满，不能拆除
-define(ERROR_EQUIPMENT_SOCKET_NOEXIST,10616).				%%孔不存在，不能拆除宝石
-define(ERROR_EQUIPMENT_STONE_NOEXIST,10617).				%%宝石不存在，不能拆除宝石
-define(ERROR_EQUIPMENT_STONE_TYPE_REPEAT,10618).			%%不能镶嵌同一类型宝石
-define(ERROR_EQUIPMENT_STONEMIX_FAILED,10619).				%%宝石合成失败
-define(ERROR_EQUIPMENT_STONEMIX_LESS_COUNT,10620).			%%宝石个数不够，不能合成
-define(ERROR_EQUIPMENT_UPGRADE_NOT_MATCHED,10621).			%%升阶道具不匹配
-define(ERROR_EQUIPMENT_UPGRADE_FAILED,10622).				%%升阶失败
-define(ERROR_EQUIPMENT_RECAST_NONE_ENCHANT,10623).			%%没有附魔不允许重铸
-define(ERROR_NOT_SAME_STONE,10624).						%%宝石类型不相同
-define(ERROR_HAVE_NOT_CONVERT_PROPERTY,10625).				%%没有可以转换的属性
-define(ERROR_EQUIPMENT_CONVERT_NONE_ENCHANT,10626).		%%没有附魔不允许转换
-define(ERROR_EQUIPMENT_MOVE_LEVEL,10627).					%%等级范围不匹配
-define(ERROR_EQUIPMENT_MOVE_INVENT,10628).					%%装备部位不匹配
-define(ERROR_EQUIPMENT_CANNOT_MOVE,10629).					%%装备不能转移

%%成就
-define(ERROR_ACHIEVE_OPENED,10630).				%%已经开启成就，不能再次开启
-define(ERROR_ACHIEVE_NOT_OPENED,10631).			%%成就没有开启
-define(ERROR_ACHIEVE_TARGET_NOEXSIT,10632).		%%达成条件不存在
-define(ERROR_ACHIEVE_TARGET_NOT_FINISHED,10633).	%%达成条件没完成

%%
-define(ERROR_LOOP_TOWER_PROP_NOEXIST,10640).		%%通行证道具不足
-define(ERROR_LOOP_TOWER_CONVEY_PROP_NOEXIST,10641).		%%传送道具不足
-define(ERROR_LOOP_TOWER_IS_LIMITED,10642).			%%超过当日次数限制
-define(ERROR_LOOP_TOWER_WRONG_LAYER,10643).			%%不能传送至该层
-define(ERROR_LOOP_TOWER_AGAIN_PROP_NOEXIST,10645).		%%轮回道具不足

%%
-define(ERROR_IS_NOT_VIP,10650).					%%您不是VIP
-define(ERROR_VIP_REWARDED_TODAY,10651).			%%您今天的奖励已经领取过了
-define(ERROR_NOT_VIP,10652).			%%您不是vip
-define(ERRNO_NO_VIP_FLYTIMES,10653).			%%vip小飞鞋剩余次数为0


%%宠物部分
-define(ERROR_PET_UP_RESET_NOEXIST,10660).			%%刷点道具不存在
-define(ERROR_PET_NOEXIST,10661).					%%宠物不存在
-define(ERROR_PET_UP_RESET_NEEDS_NOEXIST,10662).	%%道具不匹配
-define(ERROR_PET_NO_PACKAGE,10663).				%%宠物出战中不允许进行此操作
-define(ERROR_PET_NO_PET,10664).				%%该玩家没有宠物
-define(ERROR_PET_LEVEL_BIGER_THAN_MASTER,10665).%%宠物等级不可大于玩家等级

-define(ERROR_PET_TRAINING_ERROR,10700).					%%驯养失败
-define(ERROR_PET_TRAINING_NOT_ENOUGH_MONEY,10701). 		%%钱币或者道具不足
-define(ERROR_PET_SPEEDUP_TRAINING_ERROR,10706).			%%加速驯养失败


-define(ERROE_PET_QUALITY_UP_TO_TOP,10712).				%%宠物资质已经到达最大
-define(ERROR_PET_UPGRADE_QUALITT_UP_OK,10713).			%%宠物资质上限提升成功
-define(ERROR_PET_UPGRADE_QUALITT_UP_FAILED,10714).		%%宠物资质上限提升失败
-define(ERROR_PET_ADD_ATTR_BEYOND_REMAIN,10720).		%%所加属性点超过剩余点数
-define(ERROR_PET_ADD_ATTR_OK,10721).					%%玩家加点成功
-define(ERROR_PET_WASH_POINT_OK,10723).					%%洗点成功

-define(ERROR_PET_CAN_NOT_TAKE,10724).	                %%宠物不可携带
-define(ERROR_PED_EVOLUTION_FAILED,10725).              %%进化失败
-define(ERROR_PET_QUALITY_MAX,10726).					%%宠物已达最高代数
-define(ERROR_PET_NOT_ENOUGH_ITEM,10727).				%%道具不足
-define(ERROR_PET_NOT_ENOUGH_MONEY,10728).				%%钱币不足
-define(ERROR_PET_EVOLUTION_SUCCESS,10729).				%%提升成功

-define(ERROR_PET_START_EXPLORER_LEVEL_ERROR,10750).		%%宠物等级不足
-define(ERROR_PET_START_EXPLORER_STATE_ERROR,10751).		%%宠物状态不满足(不在idle状态)
-define(ERROR_PET_EXPLORER_NOT_ENOUGH_MONEY,10752).			%%金钱或者道具不足
-define(ERROR_PET_CAN_NOT_EXPLORE,10753).					%%宠物不能探险
-define(ERROR_PET_NOT_IN_TIME,10754).						%%探险地图未开启
-define(ERROR_PET_EXPLORE_TIMES_NOT_ENOUGH,10755).			%%探险次数不足
-define(ERROR_PET_EXPLORE_ATTR_NOT_ENOUGH,10756).			%%宠物属性点不足

-define(ERROR_PET_IS_EXPLORING,10757).					%%探险中无法进化



%%活动 |spa|
-define(ERROR_ACTIVITY_IS_JOINED,10760).				%%已经加入活动
-define(ERROR_ACTIVITY_STATE_ERR,10761).				%%活动状态错误
-define(ERROR_ACTIVITY_LEVEL_ERR,10762).				%%等级限制
-define(ERROR_ACTIVITY_INSTANCE_ERR,10763).				%%副本中无法使用
-define(ERROR_ACTIVITY_NOT_EXSIT,10764).				%%活动不存在
-define(ERROR_ACTIVITY_IS_FULL,10765).					%%人数满
-define(ERROR_ACTIVITY_COOLTIME_CHOPPING_ERR,10766).	%%搓澡未冷却
-define(ERROR_ACTIVITY_COOLTIME_SWIMMING_ERR,10767).	%%戏水未冷却
-define(ERROR_SPA_CAN_NOT_TOUCH_CHOPPING_ERR,10768).	%%不能对她搓澡了
-define(ERROR_SPA_CAN_NOT_TOUCH_SWIMMING_ERR,10769).	%%不能对她戏水了
-define(ERROR_SPA_TOUCH_LIMIT_ERR,10770).				%%次数限制

-define(ERROR_PET_GOT_LEVEL,10800).					%%等级不匹配
-define(ERROR_BATTLEPET_GOT_SLOT,10801).					%%无空闲宠物槽位
-define(ERROR_PET_NAME,10802).						%%宠物名非法
-define(ERROR_RIDEPET_GOT_SLOT,10803).					%%无空闲坐骑槽位

%%使用物品
-define(ERROR_ITEMUSE_QUEST_CANNOT,10810).			%%不可接受此任务
-define(ERROR_ITEMUSE_OVERDUE,10811).				%%此物品已过期
-define(ERROR_SOULPOWER_FULL,10812).				%%灵力已满,不能使用灵力丹
-define(ERROR_USED_IN_INSTANCE,10813).				%%副本中无法使用
-define(ERROR_USED_IN_MAPPOS,10814).				%%当前位置无法使用

%%使用宝箱的错误号
-define(ERROR_TREASURE_CHEST_NOITEM,10820).		%%没道具刷新失败
-define(ERROR_TREASURE_CHEST_OPERATE,10821).		%%错误的操作

%%答题
-define(ERROR_ANSWER_SIGN_EXIST,10823).					%%不能重复报名
-define(ERROR_ANSWER_SIGN_STATE_ERR,10824).				%%没有报名状态
-define(ERROR_ANSWER_SIGN_LEVEL_ERR,10825).				%%等级不符合要求
-define(ERROR_ANSWER_NO_ACTIVITY,10826).				%%没有此活动
-define(ERROR_ANSWER_SIGN_INSTANCE_ERR,10827).			%%不能在副本里进行此操作

%%摆摊
-define(ERROR_STALL_ERROR_ID,10830).				%%摊位已被撤下
-define(ERROR_STALL_RECEDE_NO_ITEM,10831).			%%物品已被购买
-define(ERROR_STALL_RECEDE_NO_STALL,10832).			%%摊位不存在
-define(ERROR_STALL_BUY_ERROR_SELF,10833).			%%不能买自己的物品
-define(ERROR_STALL_SHANGJIA_CHENGGONG,10835).		%%上架成功 				2月19日加【xiaowu】
-define(ERROR_STALL_TANWEIMAN,10834).				%%摊位已满 				3月6日加【xiaowu】
-define(ERROR_STALL_XIAJIA_CHENGGONG,10836).		%%下架成功				3月6日加【xiaowu】
-define(ERROR_STALL_GOUMAI_CHENGGONG,10837).		%%够买成功				3月13日加【xiaowu】

%%新手祝贺
-define(ERROR_BE_CONGRATULATIONS_IS_LIMITED,10840).		%%对方已收到过10次祝贺，不能再次被祝贺，你来晚了
-define(ERROR_CONGRATULATIONS_IS_ERROR,10841).			%%对方不在线或者已不能被祝贺
-define(ERROR_CONGRATULATIONS_IS_LIMITED,10842).		%%你今天已经祝贺过20名玩家，不能再祝贺其他玩家了

%%离线经验
-define(ERRNO_LESS_OFFLINE_HOURS,10843).				%%你没有足够可兑换小时数

-define(ERROR_PET_TOO_FULL,10850).					%%宠物快乐度已满
-define(ERROR_PET_FEED_ITEM_NOT_ENOUGN,10851).		%%宠物饲料道具不足
-define(ERROR_NO_PET_IN_BATTLE,10852).				%%没有出战宠物

-define(ERROR_PET_SKILL_SLOT_LOCKER_LIMITED,10853).		%%宠物技能锁次数已用完
-define(ERROR_PET_SKILL_SLOT_LOCK_ITEM_NOT_ENOUGN,10854).	%%宠物技能锁道具不足
-define(ERROR_PET_SKILL_SLOT_CANNOT_BELOCKED,10855).		%%该技能槽位不能锁

-define(ERROR_PET_LESS_LEVEL,10856).	%%宠物等级不足
-define(ERROR_PET_CANNOT_LEARN_THIS_SKILL,10857). %%宠物无法学习该技能

-define(ERROR_PET_LEARN_SKILL_LESS_SOULPOWER,10858). %%宠物无法学习该技能 灵力不足

-define(ERROR_PET_LEARN_SKILL_LESS_SLOT,10859). %%宠物无法学习该技能  没有空闲技能槽

-define(ERROR_PET_MASTER_LESS_LEVEL,10860).		%%主人的等级不足，宠物无法出战

-define(ERROR_PET_LEARN_SKILL_SPECIES_NOT_MATCH,10861).	%%该物种不能学习这个技能

-define(ERROR_PET_LEARN_SKILL_LESS_NEED_SKILL,10862).	%%不能直接学习这个技能

-define(ERROR_PET_LEARN_SKILL_LESS_ITEM,10863).			%%缺少物品 不能学习技能

-define(ERROR_PET_LEARN_SKILL_SAME_SKILL,10864).		%%已学习过同样的技能

-define(ERROR_PET_LEARN_SKILL_SAME_SKILL_LOCK,10865).		%%技能被锁定不能学习


%%攻击打断
-define(ERROR_CANCEL_OUT_RANGE,10901).				%%目标超出攻击范围
-define(ERROR_CANCEL_MOVE,10902).					%%移动打断
-define(ERROR_CANCEL_INTERRUPT,10903).				%%被打断	
-define(ERROR_CANCEL_DEAD,10904).					%%死亡打断	

%%新手卡
-define(ERROR_CARD_UNKNOWN,10910).					%%未知错误
-define(ERROR_CARD_HAVE_GIFT,10911).				%%你已经领取过
-define(ERROR_CARD_NUMBER,10912).					%%错误的新手卡
-define(ERROR_CARD_HAVE_BEEN_GIFT,10913).			%%该新手卡已被使用


%%永恒之旗
-define(ERROR_YHZQ_MEMBER_ALWAYS_IN_BATTLES,10950).		%%队员已经在战场
-define(ERROR_YHZQ_MEMBER_HAS_LAMSTER_BUFFER,10951).	%%队员身上有逃兵buffer
-define(ERROR_YHZQ_HAS_LAMSTER_BUFFER,10952).			%%本人身上有逃兵buffer
-define(ERROR_YHZQ_CANNOT_ATTACK,10953).				%%不能采集 棋子已在我方控制下
-define(ERROR_YHZQ_MEMBER_LEVEL_ERROR,10954).			%%队员等级不符合条件
-define(ERRNO_BATTLE_FULL,10955).						%%副本人数满

%%帮会二期
-define(GUILD_APPLY_SUCCESS,11010).				%%申请加入帮会成功
-define(GUILD_CONTRIBUTION_SUCCESS,11011).		%%捐献成功
-define(GUILD_UPGREAD_SUCCESS,11012).			%%帮会升级完成
-define(GUILD_GET_CONTRIBUTION_ERROR,11013).	%%获取帮贡失败
-define(GUILD_CLEAR_NICKNAME_SUCCESS,11014).	%%清除昵称成功
-define(GUILD_INVITE_ERROR_LESS_LEVEL,11015).	%%等级不足，无法接收帮会邀请
-define(GUILD_ERRNO_CANNOT_BIGGER_THEN_GUILD,11016).	%%不能超过帮会等级
-define(GUILD_PACKAGE_UPDATE,11111).%%帮会仓库更新
-define(GUILD_PACKAGE_UPDATE_FENPEI,11112).%%帮会仓库分配物品后更新
-define(GUILID_PACLAGE_IDELITEM,0).%%帮会物品闲置

%%任务
-define(QUEST_ITEM_MUST_IN_PACKAGE,11020).		%%任务物品未在包裹中
-define(QUEST_TIMEOUT,11021).					%%任务过期

%%连续登录
-define(ERROR_REWARDED_TODAY,11030).            %%今天领过奖励
-define(ERROR_NOT_REACH_LEVEL,11031).            %%等级不够

%%首充礼包奖励
-define(GET_FIRST_CHARGE_GIFT_ERROR,11040).		%%领取失败

%%打坐未在视野
-define(SITDOWN_ERROR_NO_ROLE_INAOI,11101).

%%祈福仓库
-define(TREASURE_STORAGE_GET_ITEM_ERROR,11200).		%%领取物品失败 请稍候
%%祈福
-define(TREASURE_CHEST_GOLD_NOT_ENOUGH,11201).           			%%元宝不足
-define(TREASURE_CHEST_ITEM_NOT_ENOUGH,11202).						%%天珠不足
-define(TREASURE_CHEST_PACKET_NOT_ENOUGH,11203).  	%%祈福背包空间不足

%%活跃度
-define(ACTIVITY_VALUE_NOT_ENOUGH,11300).		%%活跃度不足
-define(ACTIVITY_VALUE_ITEM_NOT_EXIST,11301).		%%没有该物品
-define(ACTIVITY_VALUE_REWARD_SUCCESS,11302).		%%领取成功

%%修为精通
-define(VENATION_NOT_OPEN,11400).           %%修为没开启
-define(VENATION_NO_ITEM,11401).			%%没有提升符
-define(VENATION_NO_MONEY,11402).			%%没有钱
-define(VENATION_FAILED,11403).				%%提升失败

%%坐骑相关
-define(ERROR_IDENTIFY_NO_ITEM,11410).      %%坐骑鉴定
-define(ERROR_NOT_SAME_QULITY,11411).		%%坐骑合成

-define(ERRNO_ALREADY_IN_INSTANCE,11420).		%%已在副本中,无法传送
-define(ERRNO_ROLE_UNRECRUITMENT_CREATE,11421).		%%创建队伍,求组删除
-define(ERRNO_ROLE_UNRECRUITMENT_JOIN,11422).		%%加入队伍,求组删除
-define(ERROR_CANT_SYNTHESIS,11423).			%%国王坐骑不能合成


%%炼制相关
-define(ERROR_REFINE_OK,11425).		%%炼制成功
-define(ERROR_REFINE_FAILED,11426). %%炼制失败


%%福利面板活动
-define(ERROR_ACTIVITY_UPDATE_OK,11430).  %%活动更新成功
-define(ERROR_SERIAL_NUMBER_ERROR,11431).	%%激活码错误
-define(ERROR_USED_SERIAL_NUMBER,11432).  %%无效激活码
-define(ERROR_HAS_FINISHED,11433).	 		%%已经完成活动


%%背包仓库
-define(ERRNO_PACKAGE_EXPAND_FULL,11440).		%%背包已扩充满
-define(ERRNO_STORAGE_EXPAND_FULL,11441).		%%仓库已扩充满

%%变身
-define(ERRNO_CAN_NOT_DO_IN_AVATAR,11444).		%%变身中无法进行本次操作

%%运镖
-define(ERRNO_CAN_NOT_DO_IN_TREASURE_TRANSPORT,11445).		%%正在运镖,无法进行本次操作

%%Spa
-define(ERRNO_CAN_NOT_DO_IN_SPA,11446).		%%正在泡澡,无法进行本次操作

%%pvp
-define(ERRNO_IS_CLEARED_ALL_CRIME,11450).		%%罪恶值已经为0，无法清除
-define(ERRNO_CAN_NOT_DO_IN_PRISON,11451).		%%正在服刑,无法进行本次操作

-define(ERRNO_GUILD_TREASURE_TRANSPORT_ALREADY_START,11452).	%%帮会运镖已开启
-define(ERRNO_GUILD_TREASURE_TRANSPORT_TIME_LIMIT,11453).	%%帮会运镖次数已用完
-define(ERRNO_NO_RIGHT_TO_START_TREASURE_TRANSPORT,11454).	%%只有帮主才能开启帮会运镖

-define(ERRNO_MAINLINE_ENTRY_TIME_LIMIT,11500).	%%今天进入次数已满
-define(ERRNO_MAINLINE_ENTRY_IN_TRAVEL_MAP,11501). %%跨服地图中无法进行挑战
-define(ERRNO_ROLE_DEAD,10501).					%%死亡

-define(ERRNO_CAN_ONLY_USE_IN_PRISON,11505).            %%该物品只能在监狱中使用 

-define(ERRNO_SENSWORDS,11510).							%%含有敏感文字
-define(ERRNO_GUILDBATTLEAPPLY_TIME_ERROR,11511).		%%现在不是报名时间
-define(ERRNO_GUILDBATTLE_ALREADY_APPLY,11512).			%%帮会已报名成功
-define(ERRNO_GUILDBATTLE_DISQUALIFIED,11513).			%%没有报名资格
-define(ERRNO_GUILDBATTLE_APPLY,11514).					%%报名成功
-define(ERRNO_IN_GUILDBATTLE,11515).					%%帮会正在帮战中
-define(ERRNO_NO_RIGHT,11516).							%%没有权限		
-define(ERRNO_NO_TIMES_TODAY,11517).					%%今天次数已经用完
-define(ERRNO_ALREADY_GET_TODAY,11518).					%%今天已领取过
-define(ERRNO_COUNTRY_LEADER_LESS_TIME,11519).			%%上任未满一天 不能领取
-define(ERRNO_GUILD_BATTLE_READY_CANNOT_ATTACK,11520).	%%战场准备中，不能攻击
-define(ERRNO_GUILD_BATTLE_THRONE_READY_CANNOT_ATTACK,11521).	%%战场准备中，王座不能占领
-define(ERRNO_GUILD_LESS_MONEY,11522).						%%帮会资金不足
-define(ERRNO_NOT_SAME_GUILD,11523).						%%不在同一帮会
-define(ERRNO_SAME_ROLE,11524).								%%不能对自己这样
-define(ERRNO_TIME_NOT_ACHIEVE,11525).						%%领取时间未到

%%节日活动
-define(ERRNO_NO_FESTIVAL_ACTIVITY,11535).				%%没有节日活动
-define(ERRNO_FESTIVAL_EXPIRED,11536).				%%活动未开启
-define(ERROR_CHRISTMAS_TREE_FULL,11537).				%%圣诞树成长以满

%%晶石争夺
-define(ERRNO_JSZD_BAD_STATE,11540).				%%活动状态错误
-define(ERRNO_JSZD_GUILD_NOT_IN_TOP,11541).			%%你所在帮会没资格参加此战场

-define(ERRNO_ROLE_NOT_EXIST,10103).						%%用户不存在

-define(ERRON_GUILD_IMPEACH_LEADER_OFFLINE_TOO_SHORT,11560).	%%帮会离线时间不足一周，不能弹劾
-define(ERRON_ROLE_IN_IMPEACH_CANNOT_LEAVE_GUILD,11561).		%%正在参与弹劾的人 不能开除出帮

-define(ERRNO_GUILD_LESS_LEVEL,11570).						%%帮会等级不足
-define(ERRNO_ALREADY_UPGRADE,11571).						%%帮会神兽已经提升过
-define(GUILD_ERRNO_CALL_CD,11572).							%%帮会神兽CD中
-define(GUILD_ERRNO_CALL_NO_TIMES,11573).					%%剩余次数不足，不能召唤帮会神兽

%%组队多层副本
-define(ERRON_LOOP_INSTANCE_MEMBERS_LIMIT,12000).			%%队伍人太多
-define(ERRON_LOOP_INSTANCE_TIMES_LIMIT,12001).				%%次数已用完
-define(ERRON_LOOP_INSTANCE_INSTANCE_EXIST,12002).			%%上次副本还未结束,请稍后重试或者更换队伍
-define(ERRON_LOOP_INSTANCE_INSTANCE_IN_VOTE,12003).		%%投票尚未结束，请稍后重试
-define(ERRON_LOOP_INSTANCE_INSTANCE_MISSION_UNCOMPLETED,12004).		%%传送失败 击杀目标尚未完成
-define(ERRON_LOOP_INSTANCE_INSTANCE_TRANSPORT_ERROR,12005).		%%传送失败 
-define(ERRON_LOOP_INSTANCE_VOTE_FAILD,12006).						%%投票失败
%%战场
-define(ERRNO_BATTLE_NOT_START,12020).				%%战场未开启
-define(ERROR_NOT_JION_IN,12021).					%%没有参加过战场

-define(ERROR_LESS_FIGHTFORCE,12030).				%%战斗力不足
-define(NORMAL_EVERQUEST,1).
-define(CYCLE_EVERQUEST,2).

-define(SPECIAL_TAG_NORMAL,0).
-define(SPECIAL_TAG_TREASURE_TRANSPORT,1).

-define(EVERQYEST_QUALITY_WHITE,1).
-define(EVERQYEST_QUALITY_GREEN,2).
-define(EVERQYEST_QUALITY_BLUE,3).
-define(EVERQYEST_QUALITY_PURPLE,4).
-define(EVERQYEST_QUALITY_GOLDEN,5).

-define(MAX_QUALITY,5).
%%quest_random
-define(CUR_SECTION_RATE,100).
-define(QUALITY_ADDATION,[0,40,80,130,200]).

-define(FRESH_TYPE_FREE,1).
-define(FRESH_TYPE_GOLD,2).
-define(FRESH_TYPE_TICKET,3).
-define(FRESH_TYPE_ITEM,4).

-define(REWARD_TYPE_NUM,0).			%%Num
-define(REWARD_TYPE_LEVEL_NUM,1).	%%Level*Num
-define(REWARD_TYPE_DRAGON_FIGHT,2).	%%dragon_fight
-define(REWARD_TYPE_TREASURE_TRANSPORT,3).	%%treasure_transport

-define(DIRECT_COMPLETE_MAX_ROUND,10).-record(festival_control,{id,show,starttime,endtime,award_limit_time}).
-record(festival_recharge_gift,{id,needcount,gift}).
-record(festival_recharge_gift_bg,{id,needcount,gift}).
-record(festival_recharge_info,{roleid,lasttime,crystal_num,exchange_info}).
-record(festival_control_background,{id,show,starttime,endtime,award_limit_time}).
-record(role_festival_recharge_data,{roleid,exchange_info}).
-define(UNCERTAIN_FESTIVAL,0).
-define(FESTIVAL_RECHARGE,1).
-define(FESTIVAL_CONTROL_ETS,festival_control_ets).
-define(FESTIVAL_RECHARGE_GIFT_ETS,festival_recharge_gift_ets).
-define(FOREVER,1).
-define(CLOSE,0).
-define(DURING_ACTIVTIY,1).
-define(DURING_AWARD,2).
-define(ZORE_CRYSTAL,0).
-define(ZORE_CHARGE,0).
-define(CANNOTFINISH,0).
-define(FINISH,1).
-define(UNFINISH,2).
-define(CANNOTOBTAIN,0).
-define(HASOBTAIN,1).
-define(CANOBTAIN,2).
-define(CUROBTAIN,3).
-define(EXCHANGERATE,10).
-define(ZORE_Silver,0).
-define(SECONDS_PER_MINUTE, 60).
-define(SECONDS_PER_HOUR, 3600).
-define(SECONDS_PER_DAY, 86400).
-define(ZORE_SECOND,0).
-define(Festival_TAB,9).
-define(OPEN_SERVICE_TAB,10).
-define(SHOW,1).
-define(NOTSHOW,0).
-define(ZORE,0).
-define(ZORE_HOUR,0).
-define(ZORE_MINUTE,0).
-define(OPEN,1).
-define(MAIL_TITLE,116).
-define(MAIL_CONTENT,117).
-define(MAIL_FROMNAME,63).%% Author: SQ.Wang
%% Created: 2011-11-7
%% Description: TODO: Add description to fighting_force_define

%%战斗力各属性系数
-define(FIGHT_FORCE_HP,0.2).
-define(FIGHT_FORCE_POWER,2).
-define(FIGHT_FORCE_DEFINSES,2).
-define(FIGHT_FORCE_HITRATE,2).
-define(FIGHT_FORCE_DODGE,2).
-define(FIGHT_FORCE_CRITICALRATE,2).
-define(FIGHT_FORCE_CRITICALDAMA,2).
-define(FIGHT_FORCE_TOUGHNESS,2).
-define(FIGHT_FORCE_IMMUNITY,2).
-define(FIGHT_FORCE_RESIST,50).
-define(FIGHT_FORCE_STRENGTH,5).
-define(FIGHT_FORCE_AGILE,5).
-define(FIGHT_FORCE_INTELLIGENCE,5).
-define(FIGHT_FORCE_STAMINA,5).
-record(friend,{owner,fid,fname,finfo}).
-record(signature,{roleid,sign}).
-record(black,{owner,fid,fname,finfo}).
%%PK地图数据
-define(PVPMAP_TAG_OFF,0).				%%PK地图
-define(PVPMAP_TAG_ON,1).				%%安全地图
-define(PVPMAP_TAG_PART,2).				%%区域PK
%%地图类型
-define(MAP_TAG_NORMAL,0).				%%普通地图
-define(MAP_TAG_LITTLE_GARDEN,1).		%%小花园
-define(MAP_TAG_BLOCK_TRAINING,2).		%%密修地图
-define(MAP_TAG_TANGLE_BATTLE,3).		%%混战地图
-define(MAP_TAG_LOOP_TOWER,4).			%%轮回塔地图
-define(MAP_TAG_PRISON,5).				%%监狱地图
-define(MAP_TAG_SPA,6).					%%温泉地图
-define(MAP_TAG_STAGE,8).				%%关卡地图
-define(MAP_TAG_GUILDBATTLE,9).			%%帮会国王争夺战地图
-define(MAP_TAG_JSZD_BATTLE,10).		%%晶石争夺战地图
-define(MAP_TAG_GUILD_INSTANCE,11).		%%帮会驻地地图

-define(MAP_LOOP_INSTANCE,12).			%%组队多层副本

-define(CHECK_INSTANCE_MAP(IsInstance),(IsInstance =:= 1)).


-define(MAP_PVP_ADD_CRIME_TAG,1).
-define(MAP_PVP_ADD_NOTHING_TAG,0).
-record(game_rank_db,{type_roleid,rank_info,record_time}).

%%baseinfo:{RoleName,RoleClass,RoleGender,RoleServerId}
-record(rank_role_db,{roleid,baseinfo,equipments,guild_name,level,viptag,disdain_num,praised_num}).

-record(role_judge_left_num,{roleid,info}).

-record(role_judge_num,{roleid,disdain_num,praised_num}).
-define(RANK_TYPE_ROLE_LEVEL,1).			%%challenge
-define(RANK_TYPE_ROLE_SILVER,2).
-define(RANK_TYPE_LOOP_TOWER_MASTER,9).		%%challenge
-define(RANK_TYPE_MAGIC_POWER,11).
-define(RANK_TYPE_RANGE_POWER,19).
-define(RANK_TYPE_FIGHTING_FORCE,3).
-define(RANK_TYPE_ROLE_TANGLE_KILL,4).
-define(RANK_TYPE_LOOP_TOWER_NUM,118).		%%challenge
-define(RANK_TYPE_ANSWER,5).
-define(RANK_TYPE_CHESS_SPIRITS_SINGLE,6).        %%challenge
-define(RANK_TYPE_CHESS_SPIRITS_TEAM,7).        %%challenge
-define(RANK_TYPE_PET_TALENT_SCORE,12).        %%challenge
-define(RANK_TYPE_PET_FIGHTING_FORCE,10).%加【小五】
-define(RANK_TYPE_PET_QUALITY_VALUE,8).%加【小五】
-define(RANK_TYPE_PET_GROWTH,11).%加【小五】
-define(RANK_TYPE_MAIN_LINE,21).				%%challenge
-define(RANK_TYPE_MELLE_POWER,14).
-define(RANK_TYPE_ACHIEVE_VALUE,16).%%@@wb20130409


-define(RANK_TYPE_ENDEX,14).

-define(RANK_TYPE_GUILD,100).			%%guild rank  process by guild_manager 

-define(COLLECT_LIST_MAX_NUM,2000).
-define(RANK_MAX_TOP_NUM,10).
-define(RANK_TOTLE_NUM,100).
-define(MAIN_LINE_RANK_TOTLE_NUM,20).   %%主线排行榜总共20人
-define(RANK_ANSWER_TOTLE_NUM,3).

-define(DISDAIN,1).
-define(PARISED,0).

%%è¢«è¯ä»·æ»æ¬¡æ°ï¼ç¨äºç³»ç»å¹¿æ­
-define(JUDGE_RANK_NUM_1,200).				
-define(JUDGE_RANK_NUM_2,500).
-define(JUDGE_RANK_NUM_3,800).
-define(JUDGE_RANK_NUM_4,1000).


-define(TALENT_RANK_TOP_NUM,3).  %%宠物天赋排行前三名
-define(ICON_TYPE_PET_TALENT,1). %%宠物称号类型（宠物天赋）

-define(CAN_CHALLENGE_NEED_LEVEL,30).  %排行榜开启等级
-record(giftcards,{cardid,roleid}). 
-record(global_exp_addition_db,{key,typeid,line,map,class,minlevel,maxlevel,starttime,endtime,numerator,denominator}).
%%typeid 1:quest/2:monster/3:sitdown/4:companion_sitdown/5:block_training
-record(global_monster_loot_db,{id,npclist,minlevel,dropids,start_time,end_time}). 
-record(goals,{goalsid,level,part,require,bonus,type,script}).
-record(goals_role,{roleid,goals}).
-record(guild_battle_proto,{week,checktime,startapplytime,stopapplytime,starttime}).
-record(guild_battle_result,{guildname,score,rank}).
-define(THRONE_STATE_NULL,0).		%%未占领
-define(THRONE_STATE_TAKING,1).	%%占领中
-define(THRONE_STATE_TAKED,2).	%%已占领

-define(THRONE_TAKE_TIME_S,90).		%%占领时间

-define(GUILDBATTLE_IDLE,1).			%%空闲
-define(GUILDBATTLE_CHECK,2).			%%检查
-define(GUILDBATTLE_APPLY,3).			%%报名
-define(GUILDBATTLE_AFTER_APPLY,4).		%%报名
-define(GUILDBATTLE_READY,5).			%%准备
-define(GUILDBATTLE_FAIGHT,6).			%%战斗
-define(GUILDBATTLE_GAMEOVER,7).		%%结束
-define(GUILDBATTLE_ERROR,8).			%%错误的状态


-define(GUILDBATTLE_MAX_GUILD_NUM,3).	%%除种子帮会外的 最多可报名帮会数
-define(GUILDBATTLE_MIN_GUILD_NUM,1).	%%最少参战帮会数
-define(GUILDBATTLE_DURATION_TIME_S,30*60).%%帮会战持续时间

-define(GUILDBATTLE_KILL_SCORE,1).			%%杀人积分

%%-define(GUILDBATTLE_REWARD_BUFF,[{600000065,1}]).		%%奖励buffer todo
-define(GUILDBATTLE_REWARD_ITEM_TEMPLATEID,19050031).		%%奖励物品

-define(GUILDBATTLE_PROTECT_TIME_S,10*6).		%%进入战场后的保护时间

-define(GUILDBATTLE_INSTANCEID,60001).		%%帮会战副本id

%%-define(GUILDBATTLE_APPLY_SILVER,[{?MONEY_SILVER,500000}]).	%%报名费 50G
-define(GUILDBATTLE_APPLY_SILVER,[]).	%%报名费 

-define(GUILDBATTLE_LEAVE_DELAY_S,30).						%%离开战场时间

-define(GUIDBATTLE_MIN_LEVEL,30).						%%参加帮会战最低等级


%%
%% 四个复活点 矩形
-define(GUILDBATTLE_BORNPOS,[
								{{158,173},{169,182}},
								{{158,87},{169,96}},
								{{114,173},{124,182}},
								{{114,92},{124,101}}
							]).


-define(SUCCESS,1).

-define(HAVE_RIGHT,0).			%%有资格参加帮会战
-define(NOTHAVE_RIGHT,1).		%%没有资格参加帮会战

%%%%%%%%%%%%%%%%%%%%%%%proto%%%%%%%%%%%%%%%%%%%%%%%

-record(guild_authorities,{id,name,disabled=0}).
-record(guild_auth_groups,{id,level,name,authids}). %% bag
-record(guild_facilities,{id,level,name,rate,check_script,require_resource,require_time}). %% bag
-record(guild_shop,{level,itemslist,preview_itemslist}).
-record(guild_shop_items,{id,itemid,showindex,guild_contribution,base_price,discount,minlevel,limitnum,itemtype}).
-record(guild_setting,{id,value}).
-record(guild_treasure,{level,itemslist}).
-record(guild_treasure_items,{id,itemid,showindex,guild_contribution,base_price,minlevel,limitnum,itemtype}).
-record(guild_monster_proto,{monsterid,needlevel,upgrademoney,callmoney,bornpos}).

%%%%%%%%%%%%%%%%%%%%%%%disc%%%%%%%%%%%%%%%%%%%%%%%

-record(guild_baseinfo,{id,name,level,silver,gold,notice,createtime,chatgroup,voicegroup,lastactivetime,sendwarningmail,applyinfo,treasure_transport}).
-record(guild_member,{key_id_member,guildid,memberid,contribution,tcontribution,authgroup,nickname,todaymoney,totalmoney}). %% memberid
-record(guild_log,{key_guild_time,guildid,memberid,logtype,description,time}).%%bag 
-record(guild_events,{key_guild_time,guildid,description,time}). %%bag
-record(guild_monster,{guildid,monster,lefttimes,time,lastcalltime,activmonster}).
-record(guild_battle_score,{guildid,gbscore,totlescore,wininfo}).
%%%% upgradestatus:starttime 0 ->not in upgrade
-record(guild_facility_info,{key_id_fac,guildid,facilityid,level,upgradestatus,upgrade_finished_time,required,contribution}).
-record(guild_leave_member,{roleid,time,lastguildid,contribution,tcontribution}).
-record(guild_member_shop,{key_id_member,guildid,memberid,count,time,ext}). 
-record(guild_member_treasure,{key_id_member,guildid,memberid,count,time,ext}).
-record(guild_treasure_price,{key_guild_id,guildid,price,ext}).
-record(guild_quest_info,{guildid,starttime,ext}).
-record(guild_impeach_info,{guildid,roleid,notice,support,opposite,starttime,voteids}).
-record(guild_right_limit,{guildid,smith,battle}).
-record(guild_instance_gate,{id,state,gilog}).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%					帮会
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(GUILD_FACILITY,1).									%%帮会
-define(GUILD_FACILITY_TREASURE,2).							%%百宝箱   (原铁匠铺)
-define(GUILD_FACILITY_SHOP,3).								%%帮会商城 (原百宝箱)
-define(GUILD_FACILITY_SMITH,4).							%%铁匠铺

-define(GUILD_FACILITY_TIMER,1000).							%%公会扫描时间间隔:1s

-define(GUILD_RANK_CHECK_TIMER,5*60).						%% 5 min

-define(GUILD_JOIN_RESTICT_TIME,5*60*60).					%%5小时
-define(GUILD_DISBAND_WARNING_TIME,20).						%%连续7天上线人数不足 发送警告邮件
-define(GUILD_DISBAND_TIME,30).								%%连续15天上线人数不足 解散帮会

-define(GUILD_MIN_ONLINE_MEMBER,1).							%%最少上线人数							

%%加成字段
-define(GUILD_ADDITION_MAX_MEMBERNUM,1).					
-define(GUILD_ADDITION_MAX_MASTERNUM,2).
-define(GUILD_ADDITION_MAX_VICELEADERNUM,3).
-define(GUILD_ADDITION_SMITH_RATE,1).

%%职位
-define(GUILD_POSE_LEADER,1).								%%帮主
-define(GUILD_POSE_VICE_LEADER,10).							%%副帮主
-define(GUILD_POSE_MASTER,20).								%%长老
-define(GUILD_POSE_MEMBER,30).								%%帮众
-define(GUILD_POSE_PREMEMBER,40).							%%帮闲

%%帮会权限
-define(GUILD_AUTH_INVITE,1).								%%邀请
-define(GUILD_AUTH_LEAVE,2).								%%离开
-define(GUILD_AUTH_SETLEADER,3).							%%禅让
-define(GUILD_AUTH_PROMOTION,4).							%%升职
-define(GUILD_AUTH_DEMOTION,5).								%%降职
-define(GUILD_AUTH_KICKOUT,6).								%%开除
-define(GUILD_AUTH_ACCEDE_RULE,7).							%%设置招募条件
-define(GUILD_AUTH_SMITH_USE,8).							%%使用铁匠铺
-define(GUILD_AUTH_TREASURE_USE,9).							%%使用百宝阁
-define(GUILD_AUTH_CONTRIBUTION,10).						%%捐献
-define(GUILD_AUTH_QUEST,11).								%%帮会任务
-define(GUILD_AUTH_NOTICE_MODIFY,12).						%%修改公告
-define(GUILD_AUTH_MAIL_ALL,13).							%%群发邮件
-define(GUILD_AUTH_UPGRADE,14).								%%升级设施
-define(GUILD_AUTH_UPGRADE_SPEEDUP,15).						%%加速升级
-define(GUILD_AUTH_CHANNEL,16).								%%帮会频道
-define(GUILD_AUTH_CHECKAPPLY,17).							%%审核帮会申请
-define(GUILD_AUTH_PUBLISHQUEST,18).						%%发布帮会任务
-define(GUILD_AUTH_SETPRICE,19).							%%设置百宝阁物品价钱
-define(GUILD_AUTH_SHOP_USE,20).							%%使用帮会商城
-define(GUILD_AUTH_CHANGE_NICKNAME,21).						%%修改称号
-define(GUILD_AUTH_TREASURE_TRANSPORT,22).					%%开启帮会运镖
-define(GUILD_UPGRADE_MONSTER,23).							%%升级帮会神兽

%%限制
-define(GUILD_NOTICE_LENGTH,400).								%%帮会通知长度
-define(GUILD_RECRUITE_TIME,1000*1000).							%%帮会信息请求间隔限制:1s
-define(GUILD_NICKNAME_LENGTH,50).								%%称号长度
-define(GUILD_APPLYINFO_TIME,1000*1000).						%%帮会申请信息请求间隔限制:1s

%%退出提示
-define(GUILD_DESTROY_BEKICKED,1).								%%被踢
-define(GUILD_DESTROY_LEAVE,2).									%%离开
-define(GUILD_DESTROY,3).										%%帮会被解散

%%帮会日志类型
-define(GUILD_LOG_MEMBER_MANAGER,1).							%%人员管理
-define(GUILD_LOG_UPGRADE,2).									%%帮会升级
-define(GUILD_LOG_MODIFY_PRICES,3).								%%调价
-define(GUILD_LOG_CONTRIBUTION,4).								%%捐献
-define(GUILD_LOG_MALL,5).										%%购买记录
-define(GUILD_LOG_QUEST,6).										%%帮务
-define(GUILD_LOG_PACKAGE,7).                              %%帮会仓库日志

-define(GUILD_MIN_LEVEL_CREATE,38).								%%建立帮会的最小级别
-define(GUILD_MIN_LEVEL_JOIN,35).								%%加入帮会最小级别


%%
%%配置key
%%
-define(GUILD_SILVER_TO_CONTRIBUTION_FACTOR_KEY,1).				%%游戏币兑换帮贡的比例 1帮贡需要的游戏币数
-define(GUILD_GOLD_TO_CONTRIBUTION_FACTOR_KEY,2).				%%元宝兑换帮贡的比例	1元宝兑换的帮贡数
-define(GUILD_ITEM_TO_CONTRIBUTION_FACTOR_KEY,3).				%%物品兑换帮贡的比例	1利川木 兑换的帮贡数
-define(GUILD_TREASURE_RESTORE_RATE,4).							%%百宝阁卖出物品后 返还给帮会的佣金 比例 百分比
-define(GUILD_QUEST_DURATION,5).								%%帮会任务发布后 额外奖励的限制时间	秒


-define(GUILD_MAX_APPLY_NUM,100).								%%最大申请人数

-define(GUILD_CAN_APPLY,1).
-define(GUILD_ALREADY_APPLY,2).
-define(GUILD_MEMBER_FULL,3).
-define(GUILD_APPLY_FULL,4).

-define(GUILD_ADD_APPLYER,1).
-define(GUILD_DEL_APPLYER,2).

-define(GUILD_APPLY_ACCEPT,1).
-define(GUILD_APPLY_REJECT,2).

-define(GUILD_LOG_DEFAULT_NUM,100).		%%默认保存帮会日志条数

-define(GUILD_MASTER_CALL_TIME,20000).							%%20s的帮会召唤有效时间

-define(GUILD_TREASURE_MAX_LEVEL,20).			%%百宝阁最高等级
-define(GUILD_SHOP_MAX_LEVEL,20).				%%商城最高等级

-define(UPDATE_MEMBERINFO_TO_CLIENT_INTERVAL,1000).	%%更新帮会成员信息给客户端的时间间隔

-define(TWO_HOUR,60*60*2).						%%两小时

-define(REASON_TREASURE_TRANSPORT,1).			%%原因运镖求救


-define(DEFAULT_FACILITY_LEVEL,1).
-define(DEFAULT_FACILITY_UPDATESTATUS,0).
-define(DEFAULT_FACILITY_FINISHEDTIME,0).

-define(IMPEACH_TIME_S,24*60*60).	%%24h

-define(IMPEACH_SUCCESS,1).
-define(GUILD_LEADER_IS_KING,2).
-define(OTHER_IMPEACH,3).

-define(ALREADY_VOTE,1).
-define(NOT_VOTE,0).

-define(VOTE_MIN_LEVEL,40).							%%最低投票等级
-define(IMPEACH_LEADER_OFFLINE_TIME,7*24*60*60*1000000).		%%7天不在线才能弹劾

-define(IMPEACH_SUCCESS_CHECK(Total,Support),(3*Support) >= (2*Total)). %%赞成数 大于等于总数的2/3

-define(GUILD_MONEYLOG_TIME,2000*1000).							%%帮会捐钱日志信息请求间隔限制:2s


-define(VOTE_SUPPORT,1).	
-define(VOTE_OPPOSITE,0).


-define(BEST_GUILD_TYPE,1).
-define(NORMAL_GUILD_TYPE,0).


-define(CALL_GUILD_MONSTER_MAX_TIMES,5).  		%%一天内能召唤怪物的最大次数
-define(CALL_GUILD_MONSTER_CD,10800).  				%%召唤怪物的cd

-define(STATE_NOT_ACTIVITED,0).  		%%帮会神兽状态未出战
-define(STATE_ACTIVITED,1).  		%%帮会神兽状态出战
-record(honor_store_items,{part,items}).-define(HONOR_STORE_ITEMS_ETS,honor_store_items_ets).
%%传送类型:
-define(CHANEL_TYPE_NORMAL,0).									%%普通传送
-define(CHANEL_TYPE_INSTANCE,1).								%%副本传送

%%副本类型:
-define(INSTANCE_TYPE_SINGLE,1).								%%单人
-define(INSTANCE_TYPE_GROUP,2).									%%组队
-define(INSTANCE_TYPE_GUILD,3).									%%公会
-define(INSTANCE_TYPE_TANGLE_BATTLE,4).							%%群p
-define(INSTANCE_TYPE_LOOP_TOWER,5).							%%轮回塔
-define(INSTANCE_TYPE_YHZQ,6).									%%永恒之旗
-define(INSTANCE_TYPE_SPA,7).									%%温泉
-define(INSTANCE_TYPE_GUILDBATTLE,8).							%%国王争夺战
-define(INSTANCE_TYPE_JSZD,9).									%%晶石争夺战
-define(INSTANCE_TYPE_LOOP_INSTANCE,10).						%%组队多层副本

%%副本lineid定义
-define(INSTANCE_LINEID,-1).

-define(INSTANCE_DESTROY_WAIT_TIME,10000).						%%10000		
%%有过期时间的物品
-define(ITEM_NONE_OVERDUE_LEFTTIME,-1).		%%永不过期的物品的时间定义
%%过期类型 
-define(ITEM_OVERDUE_TYPE_NONE,0).			%%永不过期
-define(ITEM_OVERDUE_TYPE_OBTAIN,1).		%%获取后激活过期
-define(ITEM_OVERDUE_TYPE_EQUIP,2).			%%装备后激活过期

%%物品类型 0消耗品，1武器2副手3头盔4护肩5胸甲6腰带7护手8鞋子9项链10手镯11戒指12披风13勋章14时装15宝石16包裹17任务18帮会加速
-define(ITEM_TYPE_CONSUMABLE,0).
%%可修理的:1-11,24
-define(ITEM_TYPE_MAINHAND,1).
-define(ITEM_TYPE_OFFHAND,2).
-define(ITEM_TYPE_HEAD,3).
-define(ITEM_TYPE_SHOULDER,4).
-define(ITEM_TYPE_CHEST,5).
-define(ITEM_TYPE_BELT,6).
-define(ITEM_TYPE_GLOVE,7).
-define(ITEM_TYPE_SHOES,8).
-define(ITEM_TYPE_NECK,9).
-define(ITEM_TYPE_ARMBAND,10).
-define(ITEM_TYPE_FINGER,11).
-define(ITEM_TYPE_SHIELD,24).							%%盾
-define(ITEM_TYPE_MANTEAU,12).
-define(ITEM_TYPE_AMULET,13).
-define(ITEM_TYPE_FASHION,14).							%%时装
-define(ITEM_TYPE_RIDE,39).								%%坐骑

-define(ITEM_TYPE_GEMSTONE,15).
-define(ITEM_TYPE_PACKAGE,16).
-define(ITEM_TYPE_QUEST,17).
-define(ITEM_TYPE_GUILD_SPEEDUP,18).
-define(ITEM_TYPE_FLY_SHOES,25).						%%飞鞋
-define(ITEM_TYPE_PET_RENAME,26).						%%宠物改名道具
-define(ITEM_TYPE_UP_GROWTH,28).						%%练骨
-define(ITEM_TYPE_UP_STAMINA,29).						%%易筋
-define(ITEM_TYPE_UP_GROWTH_PROTECT,31).				%%练骨保护符
-define(ITEM_TYPE_UP_STAMINA_PROTECT,32).				%%易筋保护符
-define(ITEM_TYPE_PET_UP_EXP,34).						%%宠物经验丹
-define(ITEM_TYPE_TREASURE_CHEST,35).					%%天珠
-define(ITEM_TYPE_TARGET_USE,36).						%%使用需要目标的道具
-define(ITEM_TYPE_RUBBISH,37).							%%垃圾
-define(ITEM_TYPE_PET_UP_RIDE,38).						%%坐骑升星

-define(ITEM_TYPE_RESAWN,40).							%%复活卷
-define(ITEM_TYPE_UPGRADE,42).							%%装备升阶石
-define(ITEM_TYPE_GIFT_PACKAGE,43).						%%礼包
-define(ITEM_TYPE_VENATION,44).							%%经脉道具物品类型
-define(ITEM_TYPE_ITEM_IDENTIFY,48).					%%可鉴定物品
%-define(ITEM_TYPE_SKILL_BOOK,49).						%%技能书
-define(ITEM_TYPE_SKILL_BOOK,130).						%%技能书
														%%50资质上限提升道具
-define(ITEM_TYPE_FEED_PET,51).							%%宠物饲料
-define(ITEM_TYPE_PET_SKILL_SOLT_LOCK,52).				%%宠物技能锁
%%
%%53宠物进化石 54宠物宝石
%%
-define(ITEM_TYPE_PET_HEAD,55).							%%宠物头盔
-define(ITEM_TYPE_PET_NECK,56).							%%宠物项链
-define(ITEM_TYPE_PET_GIFT,57).							%%宠物挂件
-define(ITEM_TYPE_PET_BELT,58).							%%宠物腰带
-define(ITEM_TYPE_PET_SHOES,59).						%%宠物足链

-define(ITEM_TYPE_SPA_SOAP,77).							%%搓澡肥皂
-define(ITEM_TYPE_TREASURE_TRANSPORT_FRESH,78).			%%刷镖令


%%
%%60天赋符 61洗点水 
%%65白资质符 66绿资质符 67蓝资质符 68紫资质符 69金资质符 
%%70白资质保护符 71绿资质保护符 72蓝资质保护符 73紫资质保护符 74金资质保护符  75宠物技能锁 79加血药品 80加蓝药品
%%

-define(ITEM_TYPE_PET_EXPLORE_SPEEDUP,81).	%%宠物加速探险
-define(ITEM_TYPE_PET_LUCKY_MEDAL,82).		%%宠物探险 幸运奖章

-define(ITEM_TYPE_GUILD_RENAME,86).			%%帮会改名卡
-define(ITEM_TYPE_ROLE_RENAME,87).			%%人物改名卡

-define(ITEM_TYPE_GUILD_IMPEACH,88).		%%帮会弹劾道具

%%节日活动
-define(ITEM_TYPE_CHRISTMAS_BALL,90).		%%圣诞彩球
-define(ITEM_TYPE_CHRISTMAS_SOCKS,91).		%%圣诞袜子


%%
%%装备相关
%%
-define(ITEM_TYPE_EQUIP_JIEFENG_CHUJI,100).				%%初级解封材料
-define(ITEM_TYPE_EQUIP_JIEFENG_ZHONGJI,101).				%%中级解封材料
-define(ITEM_TYPE_EQUIP_JIEFENG_GAOJI,102).				%%高级解封材料
-define(ITEM_TYPE_EQUIP_JIEFENG_TEJI,103).				%%特级解封材料
-define(ITEM_TYPE_EQUIP_SOCK_CHUJI,105).				%%初级打孔石
-define(ITEM_TYPE_EQUIP_SOCK_ZHONGJI,106).				%%中级打孔石
-define(ITEM_TYPE_EQUIP_SOCK_GAOJI,107).				%%高级打孔石

-define(ITEM_TYPE_EQUIP_SEAL,108).						%%可解封的装备

%%
%%玩家可装备类型
-define(PLAYER_ITEM_TYPES,[?ITEM_TYPE_MAINHAND,?ITEM_TYPE_OFFHAND,?ITEM_TYPE_HEAD,?ITEM_TYPE_SHOULDER,
							?ITEM_TYPE_CHEST,?ITEM_TYPE_BELT,?ITEM_TYPE_GLOVE,?ITEM_TYPE_SHOES,?ITEM_TYPE_NECK,
							?ITEM_TYPE_ARMBAND,?ITEM_TYPE_FINGER,?ITEM_TYPE_SHIELD,?ITEM_TYPE_MANTEAU,?ITEM_TYPE_AMULET,
							?ITEM_TYPE_FASHION,?ITEM_TYPE_RIDE]).
				
%%宠物可装备类型
-define(PET_ITEM_TYPES,[?ITEM_TYPE_PET_HEAD,?ITEM_TYPE_PET_NECK,
					?ITEM_TYPE_PET_GIFT,?ITEM_TYPE_PET_BELT,?ITEM_TYPE_PET_SHOES]).

%%物品绑定
-define(ITEM_BIND_TYPE_NEVER,0).		%%永不绑定
-define(ITEM_BIND_TYPE_PICK,1).			%%装备绑定
-define(ITEM_BIND_TYPE_OBTAIN,2).		%%获取绑定
-define(ITEM_BIND_TYPE_USE,3).		%%使用绑定


%%物品摧毁提示
-define(ITEM_DESTROY_NOTICE_NONE,0).		%%无提示:整理消失或堆叠消失
-define(ITEM_DESTROY_NOTICE_OVERDUE,1).		%%过期
-define(ITEM_DESTROY_NOTICE_CONSUMEUP,2).	%%消耗
-define(ITEM_DESTROY_NOTICE_DESTROY,3).		%%摧毁
-define(ITEM_DESTROY_NOTICE_STALL,4).		%%上摊位
-define(ITEM_DESTROY_NOTICE_TRADROLE,5).	%%交易
-define(ITEM_DESTROY_NOTICE_SENDMAIL,6).	%%邮件发送

-define(FASHION_DEACTIVE_OVERDUE_ENCHANMENTS,8).		%%8星后取消过期




-record(item_info,{	
				id,								%%武器id
				ownerid,						%%所属者id								
				template_id,					%%模板信息id
				enchantments,					%%生星级别
				count,							%%数量/使用次数
				slot,							%%所在背包槽位0为未在任何
				isbonded,						%%是否已绑定
				socketsinfo,					%%孔信息[{0,itemid}...]
				duration,						%%耐久
				cooldowninfo,					%%冷却信息
				enchant,						%%附魔
				overdueinfo,					%%过期参数{激活时间,剩余秒数}
				%%模板信息
				name,							%%物品名
				class,							%%类型
				displayed,						%%显示相关
				equipmentset,					%%套装id
				level,							%%物品等级
				qualty,							%%品质
				requiredlevel,					%%{minlevel,maxlevel}
				stackable,						%%可堆叠数量
				max_duration,					%%最大耐久
				inventory_type,					%%佩戴位置
				socket_type,					%%宝石可镶嵌class
				allowableclass,					%%允许职业[]
				useable,						%%可用次数
				sellprice,						%%0为不可卖
				damage,							%%{魔，远，近}
				defense,						%%{魔，远，近}
				states,							%%附加属性[{type,value}]
				spellid,						%%触发技能id，0为无
				spellcategory,					%%效果组类型
				spellcooldown,					%%cd
				bonding,						%%绑定类型
				maxsocket,						%%最大可开孔数
				scripts,						%%触发脚本
				questid,						%%触发任务
				baserepaired,					%%修理系数
				overdue_type					%%过期类型
				}).	
								
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	装备定义
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				

create_item_baseinfo(Id,Owner,TemplateID,Enchantments,Count,Slot,Isbonded,SocketsInfo,Duration,CoolDownInfo,Enchant,OverDueInfo)->
	#item_info{	id = Id,
				ownerid = Owner,				
				template_id = TemplateID,		
				enchantments = Enchantments,			
				count = Count,					
				slot = Slot,					
				isbonded = Isbonded,
				socketsinfo = SocketsInfo,
				duration = Duration,
				cooldowninfo = CoolDownInfo,
				enchant = Enchant,
				overdueinfo = OverDueInfo
				}.
				
set_protoinfo_to_iteminfo(Iteminfo,{_,Entry,Name,Class,Displayed,Equipmentset,Level,Qualty,Requiredlevel,			%%FK 26!!!!
							Stackable,Max_duration,Inventory_type,Socket_type,Allowableclass,
							Useable,Sellprice,Damage,Defense,States,Spellid,Spellcategory,Spellcooldown,
							Bonding,Maxsocket,Scripts,Questid,Baserepaired,Overdue_type,_Overdueargs,_Overduetransform,_EnchantExt})->
				Iteminfo#item_info{
				template_id = Entry,
				name	= Name,
				class	= Class,
				displayed = Displayed,
				equipmentset = Equipmentset,
				level = Level,
				qualty = Qualty,
				requiredlevel = Requiredlevel,
				stackable  = Stackable,
				max_duration = Max_duration,
				inventory_type = Inventory_type,
				socket_type = Socket_type,
				allowableclass = Allowableclass,
				useable = Useable,
				sellprice = Sellprice,
				damage = Damage,
				defense= Defense,
				states = States,
				spellid= Spellid,
				spellcategory= Spellcategory,
				spellcooldown= Spellcooldown,
				bonding= Bonding,
				maxsocket= Maxsocket,
				scripts= Scripts,
				questid= Questid,
				baserepaired= Baserepaired,
				overdue_type = Overdue_type
				}.

get_id_from_iteminfo(Iteminfo)->
	#item_info{id=TemId} = Iteminfo,
	TemId.
	
get_lowid_from_iteminfo(Iteminfo)->
	#item_info{id=TemId} = Iteminfo,
	get_lowid_from_itemid(TemId).
get_highid_from_iteminfo(Iteminfo)->
	#item_info{id=TemId} = Iteminfo,
	get_highid_from_itemid(TemId).

get_lowid_from_itemid(ItemId)->			
	{_,Low} = ItemId,
	Low.
get_highid_from_itemid(ItemId)->
	{High,_} = ItemId,
	High.

get_itemid_by_low_high_id(High,Low)->
	{High,Low}.

set_template_id_to_iteminfo(Iteminfo,TemId)->
	Iteminfo#item_info{template_id=TemId}.
get_template_id_from_iteminfo(Iteminfo)->
	#item_info{template_id=TemId} = Iteminfo,
	TemId.

	
get_cooldowninfo_from_iteminfo(Iteminfo)->
	#item_info{cooldowninfo=Cooldowninfo} = Iteminfo,
	Cooldowninfo.	
set_cooldowninfo_to_iteminfo(Iteminfo,Cooldowninfo)->
	Iteminfo#item_info{cooldowninfo = Cooldowninfo}.	

get_overdueinfo_from_iteminfo(Iteminfo)->
	#item_info{overdueinfo=Overdueinfo} = Iteminfo,
	Overdueinfo.	
set_overdueinfo_to_iteminfo(Iteminfo,Overdueinfo)->
	Iteminfo#item_info{overdueinfo = Overdueinfo}.

set_ownerid_to_iteminfo(Iteminfo,Id)->
	Iteminfo#item_info{ownerid = Id}.
get_ownerid_from_iteminfo(Iteminfo)->
	#item_info{ownerid=ID} = Iteminfo,
	ID.
				
set_enchantments_to_iteminfo(Iteminfo,StarLevel)->
	Iteminfo#item_info{enchantments = StarLevel}.
get_enchantments_from_iteminfo(Iteminfo)->
	#item_info{enchantments=StarLevel} = Iteminfo,
	StarLevel.

set_enchant_to_iteminfo(Iteminfo,Enchant)->
	Iteminfo#item_info{enchant = Enchant}.
get_enchant_from_iteminfo(Iteminfo)->
	#item_info{enchant=Enchant} = Iteminfo,
	Enchant.

set_count_to_iteminfo(Iteminfo,Count)->
	Iteminfo#item_info{count = Count}.
get_count_from_iteminfo(Iteminfo)->
	#item_info{count=Count} = Iteminfo,
	Count.						
	
set_slot_to_iteminfo(Iteminfo,Slot)->
	Iteminfo#item_info{slot = Slot}.
get_slot_from_iteminfo(Iteminfo)->
	#item_info{slot=Slot} = Iteminfo,
	Slot.	
	
set_isbonded_to_iteminfo(Iteminfo,Isbonded)->
	Iteminfo#item_info{isbonded = Isbonded}.
get_isbonded_from_iteminfo(Iteminfo)->
	#item_info{isbonded=Isbonded} = Iteminfo,
	Isbonded.								
				
				
set_socketsinfo_to_iteminfo(Iteminfo,Socketsinfo)->
	Iteminfo#item_info{socketsinfo = Socketsinfo}.
get_socketsinfo_from_iteminfo(Iteminfo)->
	#item_info{socketsinfo=Socketsinfo} = Iteminfo,
	Socketsinfo.
	
%%孔操作
add_socket_to_iteminfo(Iteminfo)->
	Sockets = get_socketsinfo_from_iteminfo(Iteminfo),
	set_socketsinfo_to_iteminfo(Iteminfo,lists:append(Sockets,[{erlang:length(Sockets)+1,0}])).
set_stone_to_iteminfo(Iteminfo,StoneTemid,SlotNum)->
	Sockets = get_socketsinfo_from_iteminfo(Iteminfo),
	set_socketsinfo_to_iteminfo(Iteminfo,lists:keyreplace(SlotNum,1,Sockets,{SlotNum,StoneTemid})).
get_stone_from_iteminfo(Iteminfo,SlotNum)->
	{SlotNum,Stoneid} = lists:keyfind(SlotNum,1,get_socketsinfo_from_iteminfo(Iteminfo)),
	Stoneid.			
	
set_duration_to_iteminfo(Iteminfo,Duration)->
	Iteminfo#item_info{duration = Duration}.
get_duration_from_iteminfo(Iteminfo)->
	#item_info{duration=Duration} = Iteminfo,
	Duration.					

%%生星会改变实例攻击和防御属性	 
get_damage_from_iteminfo(Iteminfo )->
	#item_info{ damage = Damage} = Iteminfo,
	Damage.	
set_damage_from_iteminfo(Iteminfo,Damage)->
	Iteminfo#item_info{damage = Damage}.
	
get_defense_from_iteminfo(Iteminfo )->
	#item_info{defense = Defense} = Iteminfo,
	Defense.
set_defense_from_iteminfo(Iteminfo,Defense)->
	Iteminfo#item_info{defense = Defense}.	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%								以下均为不可变的模板信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_name_from_iteminfo(Iteminfo )->
	#item_info{ name = Name } = Iteminfo,
	Name.		
	 
get_class_from_iteminfo(Iteminfo )->
	#item_info{ class = Class} = Iteminfo,
	Class.	
	 
get_displayed_from_iteminfo(Iteminfo )->
	#item_info{ displayed = Displayed} = Iteminfo,
	Displayed.

get_equipmentset_from_iteminfo(Iteminfo )->
	#item_info{ equipmentset = Equipmentset} = Iteminfo,
	Equipmentset.	

get_level_from_iteminfo(Iteminfo )->
	#item_info{ level = Level } = Iteminfo,
	Level.	
	 
get_qualty_from_iteminfo(Iteminfo )->
	#item_info{ qualty = Qualty} = Iteminfo,
	Qualty.	
	 
get_requiredlevel_from_iteminfo(Iteminfo )->
	#item_info{ requiredlevel = Requiredlevel} = Iteminfo,
	Requiredlevel.	

get_stackable_from_iteminfo(Iteminfo )->
	#item_info{stackable = Stackable} = Iteminfo,
	Stackable.
	 
get_maxduration_from_iteminfo(Iteminfo )->
	#item_info{ max_duration = Max_duration} = Iteminfo,
	Max_duration.	

get_inventorytype_from_iteminfo(Iteminfo )->
	#item_info{inventory_type =Inventory_type } = Iteminfo,
	Inventory_type.	

get_socket_type_from_iteminfo(Iteminfo )->
	#item_info{socket_type = Socket_type } = Iteminfo,
	Socket_type.	
	 
get_allowableclass_from_iteminfo(Iteminfo )->
	#item_info{ allowableclass = Allowableclass} = Iteminfo,
	Allowableclass.	
	 
get_useable_from_iteminfo(Iteminfo )->
	#item_info{ useable = Useable} = Iteminfo,
	Useable.	

get_sellprice_from_iteminfo(Iteminfo )->
	#item_info{ sellprice = Sellprice} = Iteminfo,
	Sellprice.		
	 
get_states_from_iteminfo(Iteminfo )->
	#item_info{ states = States} = Iteminfo,
	States.	
	 
get_spellid_from_iteminfo(Iteminfo )->
	#item_info{ spellid = Spellid} = Iteminfo,
	Spellid.	

get_spellcategory_from_iteminfo(Iteminfo )->
	#item_info{ spellcategory = Spellcategory} = Iteminfo,
	Spellcategory.	
	 
get_spellcooldown_from_iteminfo(Iteminfo )->
	#item_info{ spellcooldown = Spellcooldown} = Iteminfo,
	Spellcooldown.			 
	 
get_bonding_from_iteminfo(Iteminfo )->
	#item_info{ bonding = Bonding} = Iteminfo,
	 Bonding.	

get_maxsocket_from_iteminfo(Iteminfo )->
	#item_info{ maxsocket = Maxsocket} = Iteminfo,
	Maxsocket.	
	 
get_scripts_from_iteminfo(Iteminfo )->
	#item_info{ scripts = Scripts} = Iteminfo,
	Scripts.	
	 
get_questid_from_iteminfo(Iteminfo )->
	#item_info{ questid = Questid} = Iteminfo,
	Questid.	
	 
get_baserepaired_from_iteminfo(Iteminfo )->
	#item_info{ baserepaired = Baserepaired} = Iteminfo,
	Baserepaired.								

get_overdue_type_from_iteminfo(Iteminfo )->
	#item_info{ overdue_type = Overdue_type} = Iteminfo,
	Overdue_type.	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%chat info
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
-record(chat_info,{chatnode,chatproc,last_time,talk_block}).

get_chatnode_from_chat_info(Chatinfo)->
	#chat_info{ chatnode = Chatnode} = Chatinfo,
	Chatnode.								
	
get_chatproc_from_chat_info(Chatinfo)->
	#chat_info{ chatproc = Chatproc} = Chatinfo,
	Chatproc.
	
set_chat_info(ChatNode,ChatProc,Time,Tag)->
	#chat_info{chatnode = ChatNode,chatproc = ChatProc,last_time = Time,talk_block = Tag}.								

get_last_time_from_chat_info(Chatinfo)->
	#chat_info{ last_time = Last_Time} = Chatinfo,
	Last_Time.	
	
set_chat_last_time(ChatInfo,Time)->
	ChatInfo#chat_info{last_time = Time}.	
	
get_talk_block(ChatInfo)->
	#chat_info{ talk_block = BlockTime} = ChatInfo,
	BlockTime.
	
set_talk_block(ChatInfo,Tag)->
	ChatInfo#chat_info{talk_block = Tag}.	
-record(levelup_opt,{level,items,script}).
-record(role_levelup_opt_record,{roleid_level,roleid,ext}). 
-record(role_level_experience,{level,experience}).-define(MAP_PROC_DB, map_proc_db).


-define(ETS_LINE_PROC_DB,line_proc_db).
-define(ETS_MAP_MANAGER_DB,map_manager_db).
-define(ETS_MAP_LINE_DB,map_line_db).
-define(ETS_CHAT_MANAGER_DB,chat_manager_db).
-define(LONELY_MAPS,[]).

-define(MAPCONFIG_FROM_DATA,1).
-define(MAPCONFIG_FROM_OPTION,2).



%%fix value!!!

%%jackaroo mapId
-define(JACKAROO_MAP,101).
-define(BORN_POS,{123,22}).
-define(WOLF_POS,{20,19}).
-define(WOLF_SKILL,560000001).
-define(CRITICAL_RATE,75).
-define(WOLF_LOOT,[{25000007,1}]).
-define(WOLF_HP_LEFT,29).

%%default map
-define(DEFAULT_MAP,300).
-define(DEFAULT_POS,{158,170}).
%%监狱地图
-define(PRISON_MAP,339).
-define(PRISON_POS,{93,68}).
%%item
%%respawn
-define(RESPAWN_ITEM,14000020).
-define(RESPAWN_ITEM_BOND,24000020).

%%combat
-define(COMBAT_MP_BUFF,600000014).
-define(COMBAT_RELECT_BUFF,600000026).
-define(MAGIC_SHIELD_BUFF,713100003).

-define(NARMAL_MAGIC_ATTACK,510000011).
-define(NARMAL_RANGE_ATTACK,520000011).
-define(NARMAL_MELEE_ATTACK,530000011).
-define(NARMAL_MAGIC_ATTACK_NPC,540000001).
-define(NARMAL_RANGE_ATTACK_NPC,550000001).
-define(NARMAL_MELEE_ATTACK_NPC,560000001).

-define(NARMAL_MAGIC_ATTACK_PET,700000001).
-define(NARMAL_RANGE_ATTACK_PET,700000002).
-define(NARMAL_MELEE_ATTACK_PET,700000003).

%%剑灵
-define(JIANLING_CALL_1,603039).
-define(JIANLING_CALL_2,603041).
%%群p战场进入位置
-define(TANGLE_SPAWN_POS,[{91,92},{129,111},{136,159},{177,105},{177,186},{120,197},{45,143},{109,147}]).
%%进入温泉位置 
-define(SPA_SPAWN_POS,[{32,78},{76,122},{128,86},{85,40},{95,95}]).
%%晶石争夺进入位置
-define(JSZD_SPAWN_POS,[{150,225},{60,115},{120,60},{230,150},{220,215},{110,220},{85,75},{145,80}]).
%%普通打坐
-define(SITDOWN_BUFF,{100000000,1}).
%%双修buff
-define(COMPANION_ROLE_BUFF,{200000000,1}).
%%广场双修buff
-define(COMPANION_ROLE_POS_BUFF,{300000000,1}).
%%运镖buff
-define(ROLE_TREASURE_TRANSPORT_BUFFERS,{611111121,1}).		
%%篝火buff
-define(BONFIRE_BUFFERS,{500000005,1}).    		

%%复活需要的元宝
-define(RESPAWN_WITH_CHTHEAL_INSITU_GOLD,18).
%%轮回需要的元宝
-define(LOOP_TOWER_CHALLENGE_AGAIN_GOLD,28).
-define(OFFLINE_2_GOLD,8).
-define(OFFLINE_4_GOLD,18).

%%宠物改名需要的元宝
-define(PET_RENAME_GOLD,18).

%%帮会驻地副本id
-define(GUILD_INSTANCEID,60003).
-define(YHZQ_INSTANCEID,40004).

-record(playerinfo, {playerid,roles,roleid,mapid,lineid,mapnode,mapproc,roleproc,role_node}).

-record(mail_query_detail_c2s, {msgid=533,mailid}).
-record(equipment_sock_c2s, {msgid=603,equipment,sock}).
-record(item_identify_error_s2c, {msgid=1481,error}).
-record(loop_tower_enter_s2c, {msgid=654,layer,trans}).
-record(get_instance_log_s2c, {msgid=832,instance_id,times}).
-record(apply_guild_battle_c2s, {msgid=1667}).
-record(treasure_chest_query_s2c, {msgid=990,items,slots}).
-record(system_status_s2c, {msgid=701,sysid,status}).
-record(equipment_stonemix_s2c, {msgid=613,newstone}).
-record(npc_function_s2c, {msgid=302,npcid,values,quests,queststate,everquests}).
-record(object_update_s2c, {msgid=353,create_attrs,change_attrs,deleteids}).
-record(ip, {moneytype,price}).
-record(init_hot_item_s2c, {msgid=432,lists}).
-record(chess_spirit_cast_chess_skill_c2s, {msgid=1177}).
-record(welfare_gifepacks_state_update_s2c, {msgid=1462,typenumber,time_state,complete_state}).
-record(vip_init_s2c, {msgid=675,vip,type,type2}).
-record(rm, {roleid,rolename,guildname,classtype,serverid,money}).
-record(stall_opt_result_s2c, {msgid=1043,errno}).
-record(heartbeat_c2s, {msgid=26,beat_time}).
-record(continuous_opt_result_s2c, {msgid=1303,result}).
-record(add_signature_c2s, {msgid=472,signature}).
-record(loop_tower_challenge_success_s2c, {msgid=656,layer,bonus}).
-record(rank_killer_s2c, {msgid=1431,param}).
-record(enum_shoping_item_fail_s2c, {msgid=311,reason}).
-record(guild_member_kickout_c2s, {msgid=367,roleid}).
-record(loop_tower_reward_c2s, {msgid=657,bonus}).
-record(guild_notice_modify_c2s, {msgid=373,notice}).
-record(spa_join_s2c, {msgid=1604,spaid,chopping,swimming,lefttime,choppingtime,swimmingtime}).
-record(npc_init_s2c, {msgid=15,npcs}).
-record(guild_mastercall_success_s2c, {msgid=1247}).
-record(role_cancel_attack_s2c, {msgid=32,roleid,reason}).
-record(timelimit_gift_over_s2c, {msgid=1023}).
-record(i, {itemid_low,itemid_high,protoid,enchantments,count,slot,isbonded,socketsinfo,duration,enchant,lefttime_s}).
-record(guild_member_decline_c2s, {msgid=363,roleid}).
-record(mainline_opt_s2c, {msgid=1577,errno}).
-record(mainline_start_s2c, {msgid=1566,chapter,stage,difficulty,opcode}).
-record(npc_storage_items_c2s, {msgid=128,npcid}).
-record(join_battle_error_s2c, {msgid=818,errno}).
-record(npc_attribute_s2c, {msgid=54,npcid,attrs}).
-record(treasure_transport_time_s2c, {msgid=1550,left_time}).
-record(sell_item_fail_s2c, {msgid=316,reason}).
-record(sell_item_c2s, {msgid=315,npcid,slot}).
-record(end_block_training_s2c, {msgid=513,roleid}).
-record(stagetop, {serverid,roleid,name,bestscore}).
-record(jszd, {id,name,score,rank,peoples}).
-record(treasure_chest_flush_c2s, {msgid=981,slot}).
-record(use_target_item_c2s, {msgid=813,targetid,slot}).
-record(stall_recede_item_c2s, {msgid=1031,itemlid,itemhid}).
-record(recruite_cancel_c2s, {msgid=168}).
-record(lottery_clickslot_s2c, {msgid=505,lottery_slot,item}).
-record(mainline_protect_npc_info_s2c, {msgid=1576,npcprotoid,maxhp,curhp}).
-record(guild_battle_result_s2c, {msgid=1661,index}).
-record(stalls_search_item_s2c, {msgid=1045,index,totalnum,serchitems}).
-record(swap_item_c2s, {msgid=126,srcslot,desslot}).
-record(exchange_item_fail_s2c, {msgid=1005,reason}).
-record(visitor_rename_s2c, {msgid=426}).
-record(server_travel_tag_s2c, {msgid=1290,istravel}).
-record(debug_c2s, {msgid=38,msg}).
-record(trade_role_dealit_s2c, {msgid=574,roleid}).
-record(mainline_result_s2c, {msgid=1569,chapter,stage,difficulty,result,reward,bestscore,score,duration}).
-record(query_player_option_c2s, {msgid=450,key}).
-record(offline_exp_quests_init_s2c, {msgid=1132,questinfos}).
-record(gti, {id,showindex,realprice,buynum}).
-record(yhzq_all_battle_over_s2c, {msgid=1098}).
-record(guild_get_treasure_item_s2c, {msgid=1204,treasuretype,itemlist}).
-record(update_pet_skill_s2c, {msgid=928,petid,skills}).
-record(aoi_role_group_s2c, {msgid=176,groups_role}).
-record(chess_spirit_log_s2c, {msgid=1180,type,lastsec,lasttime,bestsec,bestsectime,canreward,rewardexp,rewarditems}).
-record(explore_storage_init_end_s2c, {msgid=962}).
-record(gbt, {index,name,yhzqscore,jszdscore,score}).
-record(ach, {isreward,chapter,part,cur,target}).
-record(ach_send,{achieve_value,recent_achieve,fuwen,achieve_info,award}).%%@@wb20130301服务器回复客服端的角色成就内容
-record(treasure_chest_obtain_c2s, {msgid=986}).
-record(guild_facilities_update_s2c, {msgid=384,facinfo}).
-record(buff_affect_attr_s2c, {msgid=103,roleid,attrs}).
-record(npc_swap_item_c2s, {msgid=812,npcid,srcslot,desslot}).
-record(lottery_leftcount_s2c, {msgid=502,leftcount}).
-record(activity_boss_born_init_s2c, {msgid=1414,bslist}).
-record(first_charge_gift_reward_opt_s2c, {msgid=1418,code}).
-record(get_friend_signature_c2s, {msgid=473,fn}).
-record(is_finish_visitor_c2s, {msgid=425,t,f,u}).
-record(query_time_s2c, {msgid=741,time_async}).
-record(pp, {protoid,quality,strength,agile,intelligence,stamina,growth,stamina_growth,class_type,talents}).
-record(mainline_reward_success_s2c, {msgid=1578,chapter,stage}).
-record(role_line_query_ok_s2c, {msgid=7,lines}).
-record(update_guild_update_apply_info_s2c, {msgid=1211,role,type}).
-record(beads_pray_request_c2s, {msgid=995,type,times,consume_type}).
-record(treasure_transport_call_guild_help_c2s, {msgid=1621}).
-record(end_block_training_c2s, {msgid=512}).
-record(group_kickout_c2s, {msgid=156,roleid}).
-record(equip_item_for_pet_c2s, {msgid=1511,petid,slot}).
-record(guild_base_update_s2c, {msgid=382,guildname,level,silver,gold,notice,chatgroup,voicegroup}).
-record(av, {id,completed}).
-record(treasure_chest_raffle_ok_s2c, {msgid=985,slot}).
-record(login_bonus_reward_c2s, {msgid=677}).
-record(buy_pet_slot_c2s, {msgid=940}).
-record(vip_reward_c2s, {msgid=672}).
-record(dragon_fight_faction_c2s, {msgid=1263,npcid}).
-record(npc_everquests_enum_s2c, {msgid=856,everquests,npcid}).
-record(timelimit_gift_info_s2c, {msgid=1020,nextindex,nexttime,itmes}).
-record(dragon_fight_faction_s2c, {msgid=1258,newfaction}).
-record(activity_forecast_begin_s2c, {msgid=1230,type,beginhour,beginmin,beginsec,endhour,endmin,endsec}).
-record(role_change_map_ok_s2c, {msgid=23}).
-record(other_role_into_view_s2c, {msgid=35,other}).
-record(guild_rename_c2s, {msgid=56,slot,newname}).
-record(auto_equip_item_c2s, {msgid=40,slot}).
-record(pet_upgrade_quality_s2c, {msgid=1504,result,value}).
-record(guild_battle_stop_s2c, {msgid=1664}).
-record(guild_log_event_c2s, {msgid=372}).
-record(timelimit_gift_error_s2c, {msgid=1022,reason}).
-record(chat_private_c2s, {msgid=146,serverid,roleid}).
-record(guild_member_promotion_c2s, {msgid=369,roleid}).
-record(stall_rename_c2s, {msgid=1036,stall_name}).
-record(continuous_logging_board_c2s, {msgid=1301}).
-record(companion_sitdown_result_s2c, {msgid=1255,result}).
-record(country_leader_online_s2c, {msgid=1650,post,postindex,name}).
-record(role_move_fail_s2c, {msgid=28,pos}).
-record(clear_crime_time_s2c, {msgid=734,lefttime,type}).
-record(pet_up_stamina_growth_s2c, {msgid=915,result,next}).
-record(pet_up_exp_c2s, {msgid=918,petid,needs}).
-record(rc, {rolename,args}).
-record(spa_swimming_c2s, {msgid=1607,roleid}).
-record(spa_chopping_s2c, {msgid=1605,name,bename,remain}).
-record(rank_melee_power_s2c, {msgid=1433,param}).
-record(explore_storage_info_s2c, {msgid=961,items}).
-record(identify_verify_c2s, {msgid=800,truename,card}).
-record(be_attacked_s2c, {msgid=33,enemyid,skill,units,flytime}).
-record(quest_quit_c2s, {msgid=88,questid}).
-record(money_from_monster_s2c, {msgid=113,npcid,npcproto,money}).
-record(server_version_s2c, {msgid=1631,v}).
-record(welfare_gold_exchange_c2s, {msgid=1465}).
-record(revert_black_c2s, {msgid=469,fn}).
-record(enum_shoping_item_c2s, {msgid=310,npcid}).
-record(delete_friend_c2s, {msgid=486,fn}).
-record(role_attack_c2s, {msgid=29,skillid,creatureid}).
-record(start_guild_treasure_transport_c2s, {msgid=1558}).
-record(guild_member_update_s2c, {msgid=383,roleinfo}).
-record(questgiver_states_update_s2c, {msgid=93,npcid,queststate}).
-record(unequip_item_for_pet_c2s, {msgid=1512,petid,slot}).
-record(stalls_search_item_c2s, {msgid=1037,searchstr,index}).
-record(answer_question_ranklist_s2c, {msgid=1128,ranklist}).
-record(server_version_c2s, {msgid=1630}).
-record(buff_immune_s2c, {msgid=43,enemyid,immune_buffs,flytime}).
-record(rank_disdain_role_c2s, {msgid=1440,roleid}).
-record(lottery_lefttime_s2c, {msgid=501,leftseconds}).
-record(mail_get_addition_s2c, {msgid=536,mailid}).
-record(pet_up_growth_c2s, {msgid=912,petid,needs,protect}).
-record(entry_loop_instance_vote_c2s, {msgid=1803,state}).
-record(country_change_crime_c2s, {msgid=1649,name,type}).
-record(activity_forecast_end_s2c, {msgid=1231,type}).
-record(mall_item_list_s2c, {msgid=430,mitemlists}).
-record(battle_reward_c2s, {msgid=827}).
-record(spa_leave_s2c, {msgid=1612}).
-record(congratulations_levelup_c2s, {msgid=1141,roleid,level,type}).
-record(battle_leave_c2s, {msgid=822}).
-record(guild_change_nickname_c2s, {msgid=397,roleid,nickname}).
-record(battle_reward_by_records_c2s, {msgid=1010,year,month,day,battletype,battleid}).
-record(set_pkmodel_c2s, {msgid=730,pkmodel}).
-record(treasure_storage_init_end_s2c, {msgid=1312}).
-record(position_friend_s2c, {msgid=495,posfr}).
-record(fatigue_login_disabled_s2c, {msgid=341,lefttime,prompt}).
-record(group_apply_c2s, {msgid=150,username}).
-record(battle_other_join_s2c, {msgid=828,commer}).
-record(equipment_fenjie_c2s, {msgid=628,equipment}).
-record(yhzq_battle_player_pos_s2c, {msgid=1118,players}).
-record(treasure_chest_failed_s2c, {msgid=983,reason}).
-record(guildlog, {type,id,keystr,year,month,day,hour,min,sec}).
-record(entry_guild_battle_c2s, {msgid=1654}).
-record(country_init_s2c, {msgid=1640,leaders,notice,tp_start,tp_stop,bestguildlid,bestguildhid,bestguildname}).
-record(equip_fenjie_optresult_s2c, {msgid=629,result}).
-record(beads_pray_response_s2c, {msgid=996,type,times,itemslist}).
-record(hp_package_s2c, {msgid=811,itemidl,itemidh,buffid}).
-record(cancel_buff_c2s, {msgid=112,buffid}).
-record(venation_active_point_end_c2s, {msgid=1285}).
-record(get_guild_monster_info_c2s, {msgid=1764}).
-record(trade_role_apply_s2c, {msgid=576,roleid}).
-record(equipment_remove_seal_c2s, {msgid=627,equipment,reseal}).
-record(treasure_storage_init_c2s, {msgid=1310}).
-record(equipment_stonemix_single_c2s, {msgid=612,stonelist}).
-record(add_buff_s2c, {msgid=101,targetid,buffers}).
-record(g, {roleid,rolename,rolelevel,gender,classtype,posting,contribution,tcontribution,online,nickname,fightforce}).
-record(mail_arrived_s2c, {msgid=532,mail_status}).
-record(update_pet_slot_num_s2c, {msgid=941,num}).
-record(equipment_riseup_c2s, {msgid=600,equipment,riseup,protect,lucky}).
-record(guild_recruite_info_s2c, {msgid=391,recinfos}).
-record(pet_start_training_c2s, {msgid=951,petid,totaltime,type}).
-record(mall_item_list_special_c2s, {msgid=434,ntype2}).
-record(quest_accept_failed_s2c, {msgid=98,errno}).
-record(lottery_clickslot_c2s, {msgid=504,clickslot}).
-record(companion_reject_s2c, {msgid=1257,rolename}).
-record(dragon_fight_state_s2c, {msgid=1260,npcid,faction,state}).
-record(summon_pet_c2s, {msgid=902,type,petid}).
-record(change_role_mall_integral_s2c, {msgid=440,charge_integral,by_item_integral}).
-record(explore_storage_getitem_c2s, {msgid=963,slot,itemsign}).
-record(loot_release_s2c, {msgid=110,packetid}).
-record(group_cmd_result_s2c, {msgid=164,roleid,username,reslut}).
-record(equipment_riseup_s2c, {msgid=601,result,star}).
-record(guild_disband_c2s, {msgid=361}).
-record(delete_item_s2c, {msgid=124,itemid_low,itemid_high,reason}).
-record(pet_delete_s2c, {msgid=920,petid}).
-record(inspect_pet_c2s, {msgid=922,serverid,rolename,petid}).
-record(chess_spirit_role_info_s2c, {msgid=1171,power,chesspower,max_power,max_chesspower,share_skills,self_skills,chess_skills,type}).
-record(o, {objectid,objecttype,attrs}).
-record(festival_recharge_s2c, {msgid=1692,festival_id,state,starttime,endtime,award_limit_time,lefttime,today_charge_num,exchange_info,gift}).
-record(guild_member_accept_c2s, {msgid=364,roleid}).
-record(role_recruite_cancel_c2s, {msgid=173}).
-record(gps, {typenumber,time_state,complete_state}).
-record(guild_facilities_upgrade_c2s, {msgid=375,facilityid}).
-record(everquest_list_s2c, {msgid=857,everquests}).
-record(equipment_inlay_s2c, {msgid=607}).
-record(start_block_training_c2s, {msgid=510}).
-record(pet_move_c2s, {msgid=903,petid,time,posx,posy,path}).
-record(achieve_open_c2s, {msgid=630}).
-record(other_login_s2c, {msgid=420}).
-record(venation_advanced_start_c2s, {msgid=1276,venationid,bone,useitem,type}).
-record(questgiver_hello_c2s, {msgid=85,npcid}).
-record(stop_sitdown_c2s, {msgid=1251}).
-record(treasure_storage_getitem_c2s, {msgid=1313,slot,itemsign}).
-record(mail_operator_failed_s2c, {msgid=540,reason}).
-record(tangle_battlefield_info_s2c, {msgid=819,killnum,honor,battleinfo}).
-record(ms, {mailid,from,titile,status,type,has_add,leftseconds,month,day}).
-record(stall_detail_s2c, {msgid=1040,ownerid,stallid,stallname,stallitems,logs,isonline}).
-record(spa, {spaid,join_count,limit}).
-record(guild_battle_status_update_s2c, {msgid=1660,state,lefttime,guildindex,roleid,rolename,roleclass,rolegender}).
-record(spa_request_spalist_c2s, {msgid=1601}).
-record(enum_skill_item_fail_s2c, {msgid=413,reason}).
-record(stall_buy_item_c2s, {msgid=1035,stallid,itemlid,itemhid}).
-record(leave_guild_battle_s2c, {msgid=1657,result}).
-record(tangle_kill_info_request_c2s, {msgid=1751,year,month,day,battletype,battleid}).
-record(treasure_storage_delitem_s2c, {msgid=1317,start,length}).
-record(imi, {mitemid,price,discount}).
-record(pet_explore_error_s2c, {msgid=975,error}).
-record(group_agree_c2s, {msgid=151,roleid}).
-record(star_spawns_section_s2c, {msgid=1267,section}).
-record(role_rename_c2s, {msgid=55,slot,newname}).
-record(activity_state_init_s2c, {msgid=1411,aslist}).
-record(map_complete_c2s, {msgid=13}).
-record(monster_section_update_s2c, {msgid=1823,mapid,section}).
-record(init_open_service_activities_c2s, {msgid=1683,activeid}).
-record(kmi, {npcproto,neednum}).
-record(guild_facilities_speed_up_c2s, {msgid=376,facilityid,slotnum}).
-record(stop_move_c2s, {msgid=742,time,posx,posy}).
-record(guild_battle_start_s2c, {msgid=1653}).
-record(tp, {roleid,x,y}).
-record(stage, {chapter,stageindex,state,bestscore,rewardflag,entrytime,topone}).
-record(entry_loop_instance_vote_s2c, {msgid=1801,state}).
-record(loop_tower_enter_failed_s2c, {msgid=651,reason}).
-record(gm, {monsterid,state}).
-record(get_guild_notice_c2s, {msgid=1213,guildlid,guildhid}).
-record(b, {creatureid,damagetype,damage}).
-record(guild_treasure_set_price_c2s, {msgid=1206,treasuretype,id,itemid,price}).
-record(honor_stores_buy_items_c2s, {msgid=1821,type,itemid,count}).
-record(tangle_remove_s2c, {msgid=825,roleid}).
-record(npc_into_view_s2c, {msgid=36,npc}).
-record(questgiver_complete_quest_c2s, {msgid=89,questid,npcid,choiceslot}).
-record(mid, {midlow,midhigh}).
-record(trade_role_lock_s2c, {msgid=573,roleid}).
-record(display_hotbar_s2c, {msgid=72,things}).
-record(fly_shoes_c2s, {msgid=810,mapid,posx,posy,slot}).
-record(br, {id,fn,classid,gender}).
-record(equipment_recast_c2s, {msgid=619,equipment,recast,type}).
-record(t, {roleid,level,life,maxhp,mana,maxmp,posx,posy,mapid,lineid,cloth,arm}).
-record(questgiver_states_update_c2s, {msgid=92,npcid}).
-record(loop_instance_remain_monsters_info_s2c, {msgid=1810,kill_num,remain_num,type,layer}).
-record(battlefield_info_c2s, {msgid=1088,battle}).
-record(role_change_line_c2s, {msgid=9,lineid}).
-record(mail_get_addition_c2s, {msgid=535,mailid}).
-record(battlefield_info_error_s2c, {msgid=1089,error}).
-record(treasure_storage_updateitem_s2c, {msgid=1315,itemlist}).
-record(is_visitor_c2s, {msgid=423,t,f}).
-record(equipment_stone_remove_failed_s2c, {msgid=611,reason}).
-record(venation_advanced_opt_result_s2c, {msgid=1278,result,bone}).
-record(chat_private_s2c, {msgid=147,roleid,level,roleclass,rolegender,signature,guildname,guildlid,guildhid,viptag,rolename,serverid}).
-record(chess_spirit_info_s2c, {msgid=1170,cur_section,used_time_s,next_sec_time_s,spiritmaxhp,spiritcurhp}).
-record(query_player_option_s2c, {msgid=451,kv}).
-record(rank_get_rank_c2s, {msgid=1428,type}).
-record(enum_exchange_item_s2c, {msgid=1003,npcid,dhs}).
-record(system_broadcast_s2c, {msgid=1235,id,param}).
-record(role_attribute_s2c, {msgid=53,roleid,attrs}).
-record(welfare_activity_update_s2c, {msgid=1531,typenumber,state,result}).
-record(other_role_move_s2c, {msgid=27,other_id,time,posx,posy,path}).
-record(loop_tower_challenge_c2s, {msgid=655,type}).
-record(delete_black_c2s, {msgid=477,fn}).
-record(trade_role_apply_c2s, {msgid=560,roleid}).
-record(jszd_update_s2c, {msgid=1705,roleid,score,lefttime,guilds}).
-record(upgrade_guild_monster_c2s, {msgid=355,monsterid}).
-record(trade_role_lock_c2s, {msgid=566}).
-record(guild_treasure_update_item_s2c, {msgid=1207,treasuretype,item}).
-record(spa_leave_c2s, {msgid=1611}).
-record(charge, {id,awarddate,charge_num,state}).
-record(offline_friend_s2c, {msgid=490,fn}).
-record(quest_complete_failed_s2c, {msgid=91,questid,errno}).
-record(quest_details_s2c, {msgid=95,npcid,questid,queststate}).
-record(enum_skill_item_s2c, {msgid=414,npcid}).
-record(yhzq_camp_info_s2c, {msgid=1110,redplayernum,blueplayernum,redscore,bluescore,redguild,blueguild}).
-record(bf, {bufferid,bufferlevel,durationtime}).
-record(use_item_c2s, {msgid=39,slot}).
-record(change_guild_battle_limit_c2s, {msgid=1216,fightforce}).
-record(leave_yhzq_c2s, {msgid=1107}).
-record(rank_get_main_line_rank_c2s, {msgid=1453,type,chapter,festival,difficulty}).
-record(npc_everquests_enum_c2s, {msgid=855,npcid}).
-record(yhzq_battle_update_s2c, {msgid=1116,camp,role}).
-record(guild_treasure_buy_item_c2s, {msgid=1205,treasuretype,id,itemid,count}).
-record(fr, {id,fn,classid,gender,online,sign,intimacy,level}).
-record(dragon_fight_num_s2c, {msgid=1262,npcid,faction,num}).
-record(equipment_sock_s2c, {msgid=604,result,sock}).
-record(equipment_inlay_failed_s2c, {msgid=608,reason}).
-record(player_role_list_s2c, {msgid=5,roles,nickname,is_yellow_vip,is_yellow_year_vip,yellow_vip_level}).
-record(myfriends_s2c, {msgid=481,friendinfos}).
-record(start_block_training_s2c, {msgid=511,roleid,lefttime}).
-record(continuous_days_clear_c2s, {msgid=1302}).
-record(ride_opt_c2s, {msgid=1466,opcode}).
-record(welfare_panel_init_s2c, {msgid=1461,packs_state}).
-record(ri, {leader_id,leader_line,instance,members,description}).
-record(open_service_activities_reward_c2s, {msgid=1682,id,part}).
-record(be_killed_s2c, {msgid=34,creatureid,murderer,deadtype,posx,posy,series_kills}).
-record(equipment_stonemix_failed_s2c, {msgid=614,reason}).
-record(recruite_query_c2s, {msgid=169,instance}).
-record(role_attack_s2c, {msgid=31,result,skillid,enemyid,creatureid}).
-record(guild_get_application_c2s, {msgid=394}).
-record(gift_card_apply_s2c, {msgid=1163,errno}).
-record(guild_mastercall_accept_c2s, {msgid=1246}).
-record(companion_sitdown_apply_s2c, {msgid=1253,roleid}).
-record(npc_fucnction_common_error_s2c, {msgid=300,reasonid}).
-record(replace_player_option_c2s, {msgid=452,kv}).
-record(detail_friend_s2c, {msgid=492,defr}).
-record(npc_map_change_c2s, {msgid=62,npcid,id}).
-record(mainline_lefttime_s2c, {msgid=1571,chapter,stage,lefttime}).
-record(feedback_info_ret_s2c, {msgid=418,reason}).
-record(buy_mall_item_c2s, {msgid=431,mitemid,count,price,type}).
-record(guild_member_apply_c2s, {msgid=365,guildlid,guildhid}).
-record(guild_member_demotion_c2s, {msgid=370,roleid}).
-record(quest_list_add_s2c, {msgid=83,quest}).
-record(christmas_tree_grow_up_c2s, {msgid=1740,npcid,slot}).
-record(start_everquest_s2c, {msgid=850,everqid,questid,free_fresh_times,round,section,quality,npcid}).
-record(pet_up_reset_c2s, {msgid=910,petid,reset,protect,locked,pattr,lattr}).
-record(trade_begin_s2c, {msgid=571,roleid}).
-record(pet_skill_slot_lock_c2s, {msgid=926,petid,slot,status}).
-record(explore_storage_getallitems_c2s, {msgid=964}).
-record(achieve_init_s2c, {msgid=632,parts}).
-record(ach_id,{type,part}).
-record(fw,{id,level}).
-record(award_state,{state,id}).
-record(achieve_info,{state,achieve_id,finished}).
-record(guild_bonfire_start_s2c, {msgid=1219,lefttime}).
-record(si, {item,money,gold,silver}).
-record(ki, {roleid,rolename,roleclass,rolelevel,times}).
-record(update_hotbar_c2s, {msgid=73,clsid,entryid,pos}).
-record(facebook_bind_check_result_s2c, {msgid=1446,fbid}).
-record(equipment_recast_confirm_c2s, {msgid=621,equipment}).
-record(christmas_activity_reward_c2s, {msgid=1741,type}).
-record(rank_judge_to_other_s2c, {msgid=1450,type,othername}).
-record(call_guild_monster_c2s, {msgid=1761,monsterid}).
-record(mainline_remain_monsters_info_s2c, {msgid=1573,kill_num,remain_num,chapter,stage}).
-record(explore_storage_init_c2s, {msgid=960}).
-record(loop_tower_masters_c2s, {msgid=652,master}).
-record(vb, {id,bone}).
-record(cl, {post,postindex,roleid,name,gender,roleclass}).
-record(npc_start_everquest_c2s, {msgid=854,npcid,everqid}).
-record(li, {lineid,rolecount}).
-record(dh, {itemclsid,consume,money}).
-record(guild_member_pos_c2s, {msgid=1248}).
-record(ride_opt_result_s2c, {msgid=1467,errno}).
-record(c, {x,y}).
-record(guild_bonfire_end_s2c, {msgid=1222}).
-record(rank_talent_score_s2c, {msgid=1451,param}).
-record(treasure_storage_opt_s2c, {msgid=1318,code}).
-record(guild_get_shop_item_s2c, {msgid=1201,shoptype,itemlist}).
-record(rcs, {roleid,today_count,total_count}).
-record(country_opt_s2c, {msgid=1662,code}).
-record(add_item_s2c, {msgid=121,item_attr}).
-record(instance_leader_join_c2s, {msgid=841}).
-record(group_setleader_c2s, {msgid=157,roleid}).
-record(ag, {roleid,leaderid,leadername,leaderlevel,member_num}).
-record(rank_moneys_s2c, {msgid=1432,param}).
-record(init_onhands_item_s2c, {msgid=127,item_attrs}).
-record(del_buff_s2c, {msgid=102,buffid,target}).
-record(guild_member_decline_s2c, {msgid=388,rolename}).
-record(group_destroy_s2c, {msgid=162}).
-record(offline_exp_error_s2c, {msgid=1134,reason}).
-record(festival_error_s2c, {msgid=1693,error}).
-record(visitor_rename_c2s, {msgid=427,n}).
-record(get_instance_log_c2s, {msgid=831}).
-record(companion_sitdown_start_c2s, {msgid=1254,roleid}).
-record(loop_instance_reward_s2c, {msgid=1809,layer,type,curlayer}).
-record(rl, {roleid,name,x,y,friendly,attrs}).
-record(vip_error_s2c, {msgid=673,reason}).
-record(guild_shop_update_item_s2c, {msgid=1215,shoptype,item}).
-record(rob_treasure_transport_s2c, {msgid=1553,othername,rewardmoney}).
-record(mainline_section_info_s2c, {msgid=1575,cur_section,next_section_s}).
-record(activity_boss_born_init_c2s, {msgid=1413}).
-record(leave_guild_instance_c2s, {msgid=358}).
-record(facebook_bind_check_c2s, {msgid=1445}).
-record(guild_shop_buy_item_c2s, {msgid=1202,shoptype,id,itemid,count}).
-record(add_friend_failed_s2c, {msgid=484,reason}).
-record(tsi, {itemprotoid,solt,count,itemsign}).
-record(is_jackaroo_s2c, {msgid=422}).
-record(loop_tower_masters_s2c, {msgid=653,ltms}).
-record(eq, {everqid,questid,free_fresh_times,round,section,quality}).
-record(loudspeaker_queue_num_c2s, {msgid=143}).
-record(pet_stop_training_c2s, {msgid=952,petid}).
-record(pet_change_talent_c2s, {msgid=1486,petid}).
-record(position_friend_c2s, {msgid=494,fn}).
-record(tangle_more_records_c2s, {msgid=836,year,month,day,type,battleid}).
-record(rp, {petid,petname,rolename,args}).
-record(trade_role_decline_s2c, {msgid=575,roleid}).
-record(join_guild_instance_c2s, {msgid=359,type}).
-record(jszd_start_notice_s2c, {msgid=1700,lefttime}).
-record(equipment_riseup_failed_s2c, {msgid=602,reason}).
-record(mall_item_list_sales_c2s, {msgid=436,ntype}).
-record(spa_update_count_s2c, {msgid=1615,chopping,swimming}).
-record(rank_mail_line_s2c, {msgid=1452,chapter,festival,difficulty,param}).
-record(enum_exchange_item_c2s, {msgid=1001,npcid}).
-record(join_vip_map_c2s, {msgid=679,transid}).
-record(guild_log_event_s2c, {msgid=393}).
-record(vip_ui_s2c, {msgid=671,vip,gold,endtime}).
-record(mail_delete_c2s, {msgid=538,mailid}).
-record(chess_spirit_update_chess_power_s2c, {msgid=1174,newpower}).
-record(chess_spirit_update_skill_s2c, {msgid=1173,update_skills}).
-record(gsi, {id,showindex,realprice,buynum}).
-record(battle_join_c2s, {msgid=821,type}).
-record(congratulations_levelup_s2c, {msgid=1142,exp,soulpower,remain}).
-record(tangle_records_s2c, {msgid=833,year,month,day,type,totalbattle,mybattleid}).
-record(group_depart_c2s, {msgid=159}).
-record(equipment_move_c2s, {msgid=624,fromslot,toslot}).
-record(guild_battlefield_info_s2c, {msgid=1087,rankinfo}).
-record(stall_sell_item_c2s, {msgid=1030,slot,silver,gold,ticket}).
-record(paimai_sell_c2s,{msgid=2020,gold, duration_type, silver, value, type, slot}).%%2月18日加【xiaowu】
-record(paimai_detail_c2s,{msgid=2023,stallid}).%%2月18日加【xiaowu】
-record(paimai_opt_result_s2c,{msgid=2033,errno}).%%2月19日加【xiaowu】
-record(paimai_detail_s2c,{msgid=2025, stallitems, isonline, stallname, ownerid, stallmoney, stallid, logs}).%%2月22日加【xiaowu】
-record(siv,{gold, item, type, silver, indexid}).%%2月22日加【xiaowu】
-record(sm, {gold, value, type, silver, indexid}).%%2月22日加【xiaowu】
-record(paimai_recede_c2s, {type, stallid, indexid}).%%2月25日加【xiaowu】
-record(paimai_search_by_sort_c2s, {msgid=2029, subsortkey, sortkey, levelsort, index, mainsort, moneysort}).%%3月4日加【xiaowu】
-record(paimai_search_by_string_c2s, {msgid=2027, levelsort, str, index, mainsort, moneysort}).%%3月4日加【xiaowu】
-record(paimai_search_by_grade_c2s, {msgid=2028, levelsort, index, allowableclass, mainsort, levelgrade, moneysort, qualitygrade}).%%3月4日加【xiaowu】
-record(paimai_search_item_s2c, {totalnum, index, searchitems, searchmoney}).%%3月4日加【xiaowu】
-record(ssiv, {itemnum, ownerid, item, stallid, isonline, ownername}).%%3月4日加【xiaowu】
-record(ssm, {money, ownerid, itemnum, stallid, isonline, ownername}).%%3月4日加【xiaowu】
-record(paimai_buy_c2s, {msgid=2022, type, stallid, indexid}).%%3月7日加【xiaowu】
-record(init_latest_item_s2c, {msgid=433,lists}).
-record(aoi_role_group_c2s, {msgid=175}).
-record(mall_item_list_sales_s2c, {msgid=437,mitemlists}).
-record(chess_spirit_skill_levelup_c2s, {msgid=1175,skillid}).
-record(pet_up_stamina_growth_c2s, {msgid=913,petid,needs,protect}).
-record(companion_sitdown_apply_c2s, {msgid=1252,roleid}).
-record(update_hotbar_fail_s2c, {msgid=74}).
-record(moneygame_prepare_s2c, {msgid=1242,second}).
-record(explore_storage_opt_s2c, {msgid=968,code}).
-record(ridepet_synthesis_opt_result_s2c, {msgid=1483,pettmpid,resultattr}).
-record(guild_impeach_info_c2s, {msgid=1724}).
-record(create_pet_s2c, {msgid=901,pet}).
-record(explore_storage_additem_s2c, {msgid=966,items}).
-record(add_black_s2c, {msgid=498,blackinfo}).
-record(loop_instance_kill_monsters_info_init_s2c, {msgid=1813,info,type,layer}).
-record(ltm, {layer,rolename,time}).
-record(init_mall_item_list_s2c, {msgid=439,mitemlists}).
-record(update_pet_skill_slot_s2c, {msgid=927,petid,slot}).
-record(loot_remove_item_s2c, {msgid=109,packetid,slot_num}).
-record(fatigue_prompt_s2c, {msgid=350,prompt}).
-record(detail_friend_failed_s2c, {msgid=493,reason}).
-record(inspect_s2c, {msgid=404,roleid,rolename,classtype,gender,guildname,level,cloth,arm,maxhp,maxmp,power,magic_defense,range_defense,melee_defense,stamina,strength,intelligence,agile,hitrate,criticalrate,criticaldamage,dodge,toughness,meleeimmunity,rangeimmunity,magicimmunity,imprisonment_resist,silence_resist,daze_resist,poison_resist,normal_resist,vip_tag,items_attr,guildpost,exp,levelupexp,soulpower,maxsoulpower,guildlid,guildhid,cur_designation,role_crime,fighting_force,curhp,curmp}).
-record(guild_battle_ready_s2c, {msgid=1666,remaintime}).
-record(jszd_reward_c2s, {msgid=1707}).
-record(vip_role_use_flyshoes_s2c, {msgid=678,leftnum,totlenum}).
-record(answer_sign_notice_s2c, {msgid=1122,lefttime}).
-record(creature_outof_view_s2c, {msgid=37,creature_id}).
-record(ssi, {item,stallid,ownerid,ownername,itemnum,isonline}).
-record(add_item_failed_s2c, {msgid=122,errno}).
-record(mainline_kill_monsters_info_s2c, {msgid=1574,npcprotoid,neednum,chapter,stage}).
-record(pet_present_apply_c2s, {msgid=908,slot}).
-record(treasure_chest_obtain_ok_s2c, {msgid=987}).
-record(role_recruite_c2s, {msgid=172,instanceid}).
-record(f, {id,level,lefttime,fulltime,requirevalue,contribution,tcontribution}).
-record(guild_get_treasure_item_c2s, {msgid=1203,treasuretype}).
-record(tr, {roleid,rolename,rolegender,roleclass,rolelevel,kills,score}).
-record(guild_impeach_info_s2c, {msgid=1725,roleid,notice,support,opposite,vote,lefttime_s}).
-record(add_levelup_opt_levels_s2c, {msgid=1220,levels}).
-record(delete_black_s2c, {msgid=478}).
-record(time_struct, {year,month,day,hour,minute,second}).
-record(equipment_remove_seal_s2c, {msgid=626}).
-record(mail_status_query_s2c, {msgid=531,mail_status}).
-record(chess_spirit_cast_skill_c2s, {msgid=1176,skillid}).
-record(duel_accept_c2s, {msgid=712,roleid}).
-record(inspect_pet_s2c, {msgid=923,rolename,petattr,skillinfo,slot}).
-record(loot_s2c, {msgid=105,packetid,npcid,posx,posy}).
-record(join_yhzq_c2s, {msgid=1106,reject}).
-record(loot_query_c2s, {msgid=106,packetid}).
-record(quest_get_adapt_s2c, {msgid=97,questids,everqids}).
-record(acs, {id,state}).
-record(m, {roleid,rolename,level,classtype,gender}).
-record(feedback_info_c2s, {msgid=417,type,title,content,contactway}).
-record(venation_init_s2c, {msgid=1280,venation,venationbone,attr,remaintime,totalexp}).
-record(refresh_everquest_s2c, {msgid=853,everqid,questid,quality,free_fresh_times}).
-record(rank_magic_power_s2c, {msgid=1435,param}).
-record(yhzq_award_s2c, {msgid=1108,winner,honor,exp}).
-record(guild_contribute_log_s2c, {msgid=1721,roles}).
-record(rank_range_power_s2c, {msgid=1434,param}).
-record(questgiver_quest_details_s2c, {msgid=86,npcid,quests,queststate}).
-record(lottery_clickslot_failed_s2c, {msgid=508,reason}).
-record(rank_praise_role_c2s, {msgid=1441,roleid}).
-record(gr, {guildlid,guildhid,guildname,level,guild_silver,membernum,formalnum,leader,restrict,facslevel,applyflag,createyear,createmonth,createday,sort,guild_strength}).
-record(guild_change_chatandvoicegroup_c2s, {msgid=398,chatgroup,voicegroup}).
-record(ride_pet_synthesis_c2s, {msgid=1482,slot_a,slot_b,itemslot,type}).
-record(change_smith_need_contribution_c2s, {msgid=357,contribution}).
-record(guild_rewards_c2s, {msgid=377}).
-record(skill_learn_item_c2s, {msgid=415,skillid}).
-record(explore_storage_delitem_s2c, {msgid=967,start,length}).
-record(answer_end_s2c, {msgid=1129,exp}).
-record(guild_get_application_s2c, {msgid=395,roles}).
-record(mall_item_list_special_s2c, {msgid=435,mitemlists}).
-record(guild_mastercall_s2c, {msgid=1245,posting,name,lineid,mapid,posx,posy,reasonid}).
-record(yhzq_battle_self_join_s2c, {msgid=1114,redroles,blueroles,battleid,lefttime}).
-record(k, {key,value}).
-record(player_select_role_c2s, {msgid=10,roleid,lineid}).
-record(rank_get_rank_role_s2c, {msgid=1439,roleid,rolename,classtype,gender,guildname,level,cloth,arm,vip_tag,items_attr,be_disdain,be_praised,left_judge}).
-record(venation_shareexp_update_s2c, {msgid=1282,remaintime,totalexp}).
-record(init_pets_s2c, {msgid=900,pets,max_pet_num,present_slot}).
-record(pet_rename_c2s, {msgid=906,petid,newname,slot,type}).
-record(chess_spirit_prepare_s2c, {msgid=1184,time_s}).
-record(pet_item_opt_result_s2c, {msgid=1513,errno}).
-record(sync_bonfire_time_s2c, {msgid=1729,lefttime}).
-record(guild_battle_start_apply_s2c, {msgid=1668,lefttime}).
-record(r, {roleid,name,lastmapid,classtype,gender,level}).
-record(activity_value_init_c2s, {msgid=1400}).
-record(gift_card_state_s2c, {msgid=1161,weburl,state}).
-record(oqe, {questid,addition}).
-record(inspect_faild_s2c, {msgid=405,errno}).
-record(votestate, {roleid,state}).
-record(lottery_notic_s2c, {msgid=507,rolename,item}).
-record(tab_state, {id,state}).
-record(pet_explore_info_s2c, {msgid=971,petid,remaintimes,siteid,explorestyle,lefttime}).
-record(companion_reject_c2s, {msgid=1256,roleid}).
-record(everyday_show_s2c, {msgid=1448}).
-record(loop_tower_enter_c2s, {msgid=650,layer,enter,convey}).
-record(equipment_move_s2c, {msgid=625}).
-record(group_invite_s2c, {msgid=160,roleid,username}).
-record(notify_to_join_yhzq_s2c, {msgid=1105,battle_id,camp}).
-record(battle_end_s2c, {msgid=826,honor,exp}).
-record(arrange_items_s2c, {msgid=131,type,items,lowids,highids}).
-record(set_pkmodel_faild_s2c, {msgid=731,errno}).
-record(use_item_error_s2c, {msgid=42,errno}).
-record(buy_item_fail_s2c, {msgid=314,reason}).
-record(item_identify_c2s, {msgid=1480,slot,itemslot,type}).
-record(jszd_error_s2c, {msgid=1708,reason}).
-record(goals_init_s2c, {msgid=640,parts}).
-record(guild_transport_left_time_s2c, {msgid=1557,left_time}).
-record(mainline_start_entry_c2s, {msgid=1563,chapter,stage,difficulty}).
-record(guild_create_c2s, {msgid=360,name,notice,type}).%%加入money_type,notice[xiaowu]
-record(congratulations_receive_s2c, {msgid=1143,exp,soulpower,type,rolename,level,roleid}).
-record(tangle_records_c2s, {msgid=834,year,month,day,type}).
-record(treasure_chest_broad_s2c, {msgid=991,rolename,item}).
-record(yhzq_zone_info_s2c, {msgid=1111,zonelist}).
-record(open_sercice_activities_update_s2c, {msgid=1681,id,part,state}).
-record(ridepet_synthesis_error_s2c, {msgid=1484,error}).
-record(trade_role_dealit_c2s, {msgid=567}).
-record(pfr, {fn,lineid,mapid,posx,posy}).
-record(vip_level_up_s2c, {msgid=674}).
-record(guild_member_add_s2c, {msgid=386,roleinfo}).
-record(query_time_c2s, {msgid=740}).
-record(guild_get_shop_item_c2s, {msgid=1200,shoptype}).
-record(pet_evolution_c2s, {msgid=1489,petid,itemslot}).
-record(gift_card_apply_c2s, {msgid=1162,key}).
-record(group_disband_c2s, {msgid=158}).
-record(nl, {npcid,name,x,y,friendly,attrs}).
-record(map_change_failed_s2c, {msgid=63,reasonid}).
-record(answer_question_c2s, {msgid=1126,id,answer,flag}).
-record(visitor_rename_failed_s2c, {msgid=428,reason}).
-record(set_black_s2c, {msgid=476}).
-record(pet_present_s2c, {msgid=907,present_pets}).
-record(update_trade_status_s2c, {msgid=572,roleid,silver,gold,ticket,slot_infos}).
-record(guild_facilities_accede_rules_c2s, {msgid=374,facilityid,requirevalue}).
-record(rank_judge_opt_result_s2c, {msgid=1442,roleid,disdainnum,praisednum,leftnum}).
-record(jszd_battlefield_info_s2c, {msgid=1710,score,killnum,honor,gbinfo}).
-record(guild_battle_stop_apply_s2c, {msgid=1669}).
-record(loudspeaker_queue_num_s2c, {msgid=144,num}).
-record(quest_direct_complete_c2s, {msgid=99,questid}).
-record(equipment_stone_remove_s2c, {msgid=610}).
-record(trade_role_decline_c2s, {msgid=562,roleid}).
-record(country_leader_promotion_c2s, {msgid=1645,post,postindex,name}).
-record(recharge, {id,state}).
-record(equipment_stone_remove_c2s, {msgid=609,equipment,remove,socknum}).
-record(fatigue_alert_s2c, {msgid=351,alter}).
-record(publish_guild_quest_c2s, {msgid=1208}).
-record(stalls_search_s2c, {msgid=1041,index,totalnum,stalls}).
-record(treasure_chest_query_c2s, {msgid=989}).
-record(refine_system_s2c, {msgid=1521,result}).
-record(chat_s2c, {msgid=141,type,serverid,privateflag,desroleid,desrolename,msginfo,details,identity}).
-record(answer_sign_success_s2c, {msgid=1124}).
-record(welfare_gold_exchange_init_c2s, {msgid=1463}).
-record(country_leader_get_itmes_c2s, {msgid=1651}).
-record(offline_exp_exchange_c2s, {msgid=1133,type,hours}).
-record(sp, {itemclsid,price}).
-record(kl, {key,value}).
-record(stall_detail_c2s, {msgid=1034,stallid}).
-record(pet_forget_skill_c2s, {msgid=919,petid,slot,skillid}).
-record(guild_impeach_c2s, {msgid=1722,notice}).
-record(item_identify_opt_result_s2c, {msgid=1488,itemtmpid}).
-record(country_init_c2s, {msgid=1665}).
-record(jszd_end_s2c, {msgid=1706,myrank,guilds,honor,exp}).
-record(instance_info_s2c, {msgid=830,protoid,times,left_time}).
-record(pet_add_attr_c2s, {msgid=1502,petid,power_add,hitrate_add,criticalrate_add,stamina_add}).
-record(activity_state_init_c2s, {msgid=1410}).
-record(jszd_stop_s2c, {msgid=1709}).
-record(info_back_c2s, {msgid=453,type,info,version}).
-record(position_friend_failed_s2c, {msgid=496,reason}).
-record(add_black_c2s, {msgid=497,bn}).
-record(instance_leader_join_s2c, {msgid=840,instanceid}).
-record(l, {itemprotoid,count}).
-record(di, {disctype,count}).
-record(activity_boss_born_update_s2c, {msgid=1415,updatebs}).
-record(init_mall_item_list_c2s, {msgid=438,ntype}).
-record(delete_friend_failed_s2c, {msgid=488,reason}).
-record(answer_sign_request_c2s, {msgid=1123}).
-record(get_friend_signature_s2c, {msgid=474,signature}).
-record(send_guild_notice_s2c, {msgid=1214,guildlid,guildhid,notice}).
-record(achieve_update_s2c, {msgid=632,achieve_value,recent_achieve,fuwen,achieve_info,award}).
-record(equipment_convert_c2s, {msgid=622,equipment,convert,type}).
-record(ic, {itemid_low,itemid_high,attrs,ext_enchant}).
-record(quest_complete_s2c, {msgid=90,questid}).
-record(yhzq_battle_remove_s2c, {msgid=1117,camp,roleid}).
-record(pet_upgrade_quality_up_s2c, {msgid=1505,type,result,value}).
-record(spa_join_c2s, {msgid=1603,spaid}).
-record(pet_wash_attr_c2s, {msgid=1503,petid,type}).
-record(welfare_panel_init_c2s, {msgid=1460}).
-record(recruite_c2s, {msgid=167,instance,description}).
-record(block_s2c, {msgid=421,type,time}).
-record(online_friend_s2c, {msgid=489,fid}).
-record(role_line_query_c2s, {msgid=6,mapid}).
-record(update_skill_s2c, {msgid=75,creatureid,skillid,level}).
-record(equipment_upgrade_s2c, {msgid=616}).
-record(guild_opt_result_s2c, {msgid=381,errno}).
-record(bs, {bossid,state}).
-record(moneygame_result_s2c, {msgid=1241,result,use_time,section}).
-record(instance_exit_c2s, {msgid=838}).
-record(loop_instance_kill_monsters_info_s2c, {msgid=1811,npcprotoid,neednum,type,layer}).
-record(pet_learn_skill_c2s, {msgid=917,petid,slot,force}).
-record(gbr, {guildname,score,rank}).
-record(update_item_for_pet_s2c, {msgid=1510,petid,items}).
-record(lottery_querystatus_c2s, {msgid=509}).
-record(get_guild_space_info_c2s, {msgid=2270}).%%1月27日加【小五】
-record(open_guild_space_c2s, {msgid=2271,spaceid}).%%1月29日加【小五】
-record(get_space_info_s2c, {msgid=2276,spaceinfo,lefttimes}).%%1月29日加【小五】
-record(start_qunmojiuxian_c2s,{msgid=2272, spaceid}).%%4月9日加【小五】
-record(qunmojiuxian_vote_c2s,{msgid=2278, spaceid}).%%4月10日加【小五】
-record(qunmojiuxian_vote_num_s2c,{msgid=2274, num}).%%4月10日加【小五】
-record(qunmojiuxian_vote_s2c, {msgid=2275,spaceid}).%%4月10日加【小五】
-record(qunmojiuxian_accept_vote_c2s, {msgid=2277}).%%4月10日加【小五】
-record(qmjx, {state,spaceid}).
-record(achieve_error_s2c, {msgid=634,reason}).
-record(answer_question_s2c, {msgid=1127,id,score,rank,continu}).
-record(battle_waiting_s2c, {msgid=829,waitingtime}).
-record(change_item_failed_s2c, {msgid=41,itemid_low,itemid_high,errno}).
-record(init_random_rolename_s2c, {msgid=1120,bn,gn}).
-record(pet_explore_stop_c2s, {msgid=974,petid}).
-record(jszd_leave_s2c, {msgid=1704}).
-record(dragon_fight_end_s2c, {msgid=1265,rednum,bluenum,winfaction}).
-record(battlefield_totle_info_s2c, {msgid=1090,gbinfo}).
-record(battle_start_s2c, {msgid=820,type,lefttime}).
-record(identify_verify_s2c, {msgid=801,code}).
-record(venation_update_s2c, {msgid=1281,venation,point,attr}).
-record(duel_invite_s2c, {msgid=720,roleid}).
-record(tbi, {msgid,battleid,curnum,totlenum}).
-record(play_effects_s2c, {msgid=1743,type,optroleid,effectid}).
-record(duel_invite_c2s, {msgid=710,roleid}).
-record(chess_spirit_log_c2s, {msgid=1179,type}).
-record(role_move_c2s, {msgid=25,time,posx,posy,path}).
-record(answer_error_s2c, {msgid=1130,reason}).
-record(npc_storage_items_s2c, {msgid=129,npcid,item_attrs}).
-record(stall_log_add_s2c, {msgid=1042,stallid,logs}).
-record(get_guild_monster_info_s2c, {msgid=1760,monster,lefttimes,call_cd}).
-record(rr, {id,name,level,classid,instance}).
-record(psk, {slot,skillid,level}).
-record(pet_stop_move_c2s, {msgid=904,petid,time,posx,posy}).
-record(mi, {mitemid,ntype,ishot,sort,price,discount}).
-record(change_country_transport_c2s, {msgid=1643,tp_start}).
-record(repair_item_c2s, {msgid=317,npcid,slot}).
-record(mainline_start_c2s, {msgid=1565,chapter,stage}).
-record(beads_pray_fail_s2c, {msgid=997,type}).
-record(guild_update_log_s2c, {msgid=399,log}).
-record(mainline_timeout_c2s, {msgid=1572,chapter,stage}).
-record(vip_ui_c2s, {msgid=670}).
-record(rkv, {kv,kv_plus,color}).
-record(split_item_c2s, {msgid=125,slot,split_num}).
-record(group_invite_c2s, {msgid=153,username}).
-record(yhzq_award_c2s, {msgid=1109}).
-record(callback_guild_monster_c2s, {msgid=1762,monsterid}).
-record(loop_instance_reward_c2s, {msgid=1808}).
-record(init_pet_skill_slots_s2c, {msgid=930,pslots}).
-record(jszd_join_s2c, {msgid=1702,lefttime,guilds}).
-record(moneygame_cur_sec_s2c, {msgid=1243,cursec,maxsec}).
-record(goals_error_s2c, {msgid=643,reason}).
-record(group_member_stats_s2c, {msgid=165,state}).
-record(spa_stop_s2c, {msgid=1613}).
-record(dragon_fight_start_s2c, {msgid=1264,duration}).
-record(sitdown_c2s, {msgid=1250}).
-record(group_accept_c2s, {msgid=154,roleid}).
-record(set_trade_money_c2s, {msgid=563,moneytype,moneycount}).
-record(quest_list_remove_s2c, {msgid=82,questid}).
-record(recruite_cancel_s2c, {msgid=171,reason}).
-record(equipment_enchant_s2c, {msgid=618,enchants}).
-record(guild_member_invite_c2s, {msgid=362,name}).
-record(rank_fighting_force_s2c, {msgid=1454,param}).
-record(leave_loop_instance_s2c, {msgid=1807,layer,result}).
-record(quest_statu_update_s2c, {msgid=84,quests}).
-record(hc, {clsid,entryid,pos}).
-record(welfare_activity_update_c2s, {msgid=1530,typenumber,serial_number}).
-record(congratulations_error_s2c, {msgid=1144,reason}).
-record(s, {skillid,level,lefttime}).
-record(mail_status_query_c2s, {msgid=530}).
-record(tangle_update_s2c, {msgid=824,trs}).
-record(continuous_logging_board_s2c, {msgid=1304,normalawardday,vipawardday,days}).
-record(continuous_logging_gift_c2s, {msgid=1300,type,nowawardday}).
-record(pet_training_info_s2c, {msgid=950,petid,totaltime,remaintime}).
-record(role_recruite_cancel_s2c, {msgid=174,reason}).
-record(spa_start_notice_s2c, {msgid=1600,level}).
-record(chat_c2s, {msgid=140,type,desserverid,desrolename,msginfo,details}).
-record(revert_black_s2c, {msgid=470,friendinfo}).
-record(equipment_inlay_c2s, {msgid=606,equipment,inlay,socknum}).
-record(treasure_storage_info_s2c, {msgid=1311,items}).
-record(entry_loop_instance_s2c, {msgid=1805,layer,result,lefttime,besttime}).
-record(equipment_recast_s2c, {msgid=620,enchants}).
-record(zoneinfo, {zoneid,state}).
-record(welfare_gold_exchange_init_s2c, {msgid=1464,consume_gold}).
-record(spiritspower_reset_c2s, {msgid=1731}).
-record(duel_result_s2c, {msgid=723,winner}).
-record(guild_impeach_result_s2c, {msgid=1723,result}).
-record(npc_function_c2s, {msgid=301,npcid}).
-record(pet_up_reset_s2c, {msgid=911,petid,strength,agile,intelligence}).
-record(entry_loop_instance_c2s, {msgid=1804,layer}).
-record(pet_learn_skill_cover_best_s2c, {msgid=931,petid,slot,skillid,oldlevel,newlevel}).
-record(create_role_request_c2s, {msgid=400,role_name,gender,classtype}).
-record(aqrl, {rolename,score}).
-record(first_charge_gift_reward_c2s, {msgid=1417}).
-record(country_leader_demotion_c2s, {msgid=1646,post,postindex}).
-record(role_map_change_c2s, {msgid=61,seqid,transid}).
-record(quest_details_c2s, {msgid=94,questid}).
-record(rank_chess_spirits_team_s2c, {msgid=1444,param}).
-record(arrange_items_c2s, {msgid=130,type}).
-record(psl, {petid,slots}).
-record(mainline_end_s2c, {msgid=1568}).
-record(guild_impeach_stop_s2c, {msgid=1727}).
-record(entry_loop_instance_vote_update_s2c, {msgid=1802,state}).
-record(first_charge_gift_state_s2c, {msgid=1416,state}).
-record(venation_advanced_update_s2c, {msgid=1277,attr}).
-record(other_venation_info_s2c, {msgid=1288,roleid,venation,attr,remaintime,totalexp,venationbone}).
-record(battle_self_join_s2c, {msgid=823,trs,battletype,battleid,lefttime}).
-record(festival_recharge_notice_s2c, {msgid=1696}).
-record(quest_list_update_s2c, {msgid=81,quests}).
-record(spiritspower_state_update_s2c, {msgid=1730,state,lefttime,curvalue}).
-record(equipment_convert_s2c, {msgid=623,enchants}).
-record(treasure_chest_raffle_c2s, {msgid=984}).
-record(recruite_query_s2c, {msgid=170,instance,rec_infos,role_rec_infos,usedtimes,isaddtime,lefttime}).
-record(pet_speedup_training_c2s, {msgid=953,petid,speeduptime}).
-record(treasure_transport_call_guild_help_result_s2c, {msgid=1620,result}).
-record(create_role_sucess_s2c, {msgid=401,role_id}).
-record(mainline_update_s2c, {msgid=1562,st,type}).
-record(loot_response_s2c, {msgid=107,packetid,slots}).
-record(delete_friend_success_s2c, {msgid=487,fn}).%%@@??
-record(treasure_storage_additem_s2c, {msgid=1316,items}).
-record(change_country_notice_s2c, {msgid=1642,notice}).
-record(designation_init_s2c, {msgid=1540,designationid}).
-record(pet_feed_c2s, {msgid=942,petid,slot}).
-record(q, {questid,status,values,lefttime}).
-record(guild_contribute_log_c2s, {msgid=1720}).
-record(buy_honor_item_error_s2c, {msgid=1822,error}).
-record(rank_answer_s2c, {msgid=1438,param}).
-record(guild_have_guildbattle_right_s2c, {msgid=1218,right}).
-record(chess_spirit_opt_result_s2s, {msgid=1178,errno}).
-record(goals_update_s2c, {msgid=641,part}).
-record(yhzq_battle_end_s2c, {msgid=1119,honor,exp}).
-record(pet_attack_c2s, {msgid=905,petid,skillid,creatureid}).
-record(vp, {id,points}).
-record(guild_log_normal_s2c, {msgid=392,logs}).
-record(rank_get_rank_role_c2s, {msgid=1429,roleid}).
-record(activity_value_opt_s2c, {msgid=1404,code}).
-record(offline_exp_init_s2c, {msgid=1131,hour,totalexp}).
-record(role_change_map_c2s, {msgid=22}).
-record(trade_success_s2c, {msgid=578}).
-record(query_system_switch_c2s, {msgid=700,sysid}).
-record(venation_active_point_opt_s2c, {msgid=1284,reason}).
-record(guild_battle_opt_s2c, {msgid=1663,code}).
-record(country_leader_ever_reward_c2s, {msgid=1652}).
-record(fatigue_prompt_with_type_s2c, {msgid=340,prompt,type}).
-record(add_friend_success_s2c, {msgid=483,friendinfo}).
-record(activity_value_reward_c2s, {msgid=1403,itemid}).
-record(dragon_fight_join_c2s, {msgid=1266}).
-record(treasure_chest_flush_ok_s2c, {msgid=982,items}).
-record(jszd_leave_c2s, {msgid=1703}).
-record(mainline_end_c2s, {msgid=1567,chapter,stage}).
-record(gbs, {index,guildlid,guildhid,guildname}).
-record(questgiver_accept_quest_c2s, {msgid=87,npcid,questid}).
-record(treasure_buffer_s2c, {msgid=1160,buffs}).
-record(role_respawn_c2s, {msgid=419,type}).
-record(stall_role_detail_c2s, {msgid=1044,rolename}).
-record(tangle_more_records_s2c, {msgid=837,trs,year,month,day,type,myrank,battleid,has_reward}).
-record(guild_join_lefttime_s2c, {msgid=1728,lefttime}).
-record(treasure_storage_getallitems_c2s, {msgid=1314}).
-record(yhzq_error_s2c, {msgid=1099,reason}).
-record(p, {petid,protoid,level,name,gender,mana,quality,exp,power,hitrate,criticalrate,stamina,fighting_force,power_attr,hitrate_attr,criticalrate_attr,stamina_attr,happiness,remain_attr,mpmax,class_type,state,quality_value,t_power,t_hitrate,t_critical,t_stamina,t_gs,gs_sort,quality_up_value,criticaldestoryrate,pet_equips,trade_lock}).
-record(guild_recruite_info_c2s, {msgid=378}).
-record(mainline_init_s2c, {msgid=1561,st}).
-record(spa_chopping_c2s, {msgid=1614,roleid,slot}).
-record(loop_instance_opt_s2c, {msgid=1812,code}).
-record(explore_storage_updateitem_s2c, {msgid=965,itemlist}).
-record(myfriends_c2s, {msgid=480,ntype}).
-record(treasure_chest_disable_c2s, {msgid=992,slots}).
-record(mainline_start_entry_s2c, {msgid=1564,chapter,stage,difficulty,opcode}).
-record(cancel_trade_s2c, {msgid=577}).
-record(update_everquest_s2c, {msgid=851,everqid,questid,free_fresh_times,round,section,quality}).
-record(group_apply_s2c, {msgid=166,roleid,username}).
-record(equipment_sock_failed_s2c, {msgid=605,reason}).
-record(rank_loop_tower_num_s2c, {msgid=1436,param}).
-record(mf, {creatureid,buffid,bufflevel}).
-record(pet_riseup_s2c, {msgid=925,result,next}).
-record(guild_battle_score_update_s2c, {msgid=1659,index,score}).
-record(enum_shoping_item_s2c, {msgid=312,npcid,sps}).
-record(skill_panel_c2s, {msgid=70}).
-record(trade_role_errno_s2c, {msgid=570,errno}).
-record(giftinfo, {needcharge,items}).
-record(duel_start_s2c, {msgid=722,roleid}).
-record(venation_opt_s2c, {msgid=1286,roleid,reason}).
-record(create_role_failed_s2c, {msgid=402,reasonid}).
-record(spa_swimming_s2c, {msgid=1608,name,bename,remain}).
-record(activity_value_update_s2c, {msgid=1402,avlist,value,status}).
-record(mall_item_list_c2s, {msgid=429,ntype}).
-record(change_country_transport_s2c, {msgid=1644,tp_start,tp_stop}).
-record(role_change_map_fail_s2c, {msgid=24}).
-record(black_list_s2c, {msgid=479,friendinfos}).
-record(instance_end_seconds_s2c, {msgid=858,kicktime_s}).
-record(yhzq_battlefield_info_s2c, {msgid=1091,gbinfo}).
-record(update_guild_quest_info_s2c, {msgid=1209,lefttime}).
-record(guild_battle_score_init_s2c, {msgid=1658,guildlist}).
-record(pet_swap_slot_c2s, {msgid=921,petid,slot}).
-record(pet_training_init_info_s2c, {msgid=954,petid,totaltime,remaintime}).
-record(group_create_c2s, {msgid=152}).
-record(yhzq_battle_other_join_s2c, {msgid=1115,role,camp}).
-record(festival_init_c2s, {msgid=1691,festival_id}).
-record(refine_system_c2s, {msgid=1520,serial_number,times}).
-record(ti, {trade_slot,item_attrs}).
-record(mail_send_c2s, {msgid=537,toi,title,content,add_silver,add_item}).
-record(activity_state_update_s2c, {msgid=1412,updateas}).
-record(spa_request_spalist_s2c, {msgid=1602,spas}).
-record(rk, {kv,args}).
-record(gbw, {index,name,score,winnum,losenum}).
-record(change_guild_right_limit_s2c, {msgid=1217,smith,battle}).
-record(stalls_search_c2s, {msgid=1033,index}).
-record(loop_tower_challenge_again_c2s, {msgid=658,type,again}).
-record(exchange_item_c2s, {msgid=1004,npcid,item_clsid,count,slots}).
-record(guild_set_leader_c2s, {msgid=368,roleid}).
-record(loot_pick_c2s, {msgid=108,packetid,slot_num}).
-record(change_country_notice_c2s, {msgid=1641,notice}).
-record(guild_member_invite_s2c, {msgid=389,roleid,rolename,guildlid,guildhid,guildname}).
-record(guild_member_contribute_c2s, {msgid=379,moneytype,moneycount}).
-record(guild_log_normal_c2s, {msgid=371,type}).
-record(equipment_enchant_c2s, {msgid=617,equipment,enchant}).
-record(treasure_transport_failed_s2c, {msgid=1551,reward}).
-record(ps, {slot,proto,price,quality}).
-record(destroy_item_c2s, {msgid=123,slot}).
-record(gmp, {roleid,lineid,mapid}).
-record(pet_present_apply_s2c, {msgid=909,delete_slot}).
-record(rank_loop_tower_s2c, {msgid=1430,param}).
-record(enum_exchange_item_fail_s2c, {msgid=1002,reason}).
-record(moneygame_left_time_s2c, {msgid=1240,left_seconds}).
-record(skill_learn_item_fail_s2c, {msgid=416,reason}).
-record(guild_impeach_vote_c2s, {msgid=1726,type}).
-record(leave_loop_instance_c2s, {msgid=1806}).
-record(set_trade_item_c2s, {msgid=564,trade_slot,package_slot}).
-record(guild_update_apply_result_s2c, {msgid=1212,guildlid,guildhid,result}).
-record(server_treasure_transport_end_s2c, {msgid=1555}).
-record(psll, {slot,status}).
-record(role_treasure_transport_time_check_c2s, {msgid=1556}).
-record(move_stop_s2c, {msgid=104,id,x,y}).
-record(jszd_join_c2s, {msgid=1701}).
-record(inspect_designation_s2c, {msgid=1542,roleid,designationid}).
-record(pet_upgrade_quality_c2s, {msgid=1500,petid,needs,protect}).
-record(guild_info_s2c, {msgid=380,guildname,level,silver,gold,notice,roleinfos,facinfos,chatgroup,voicegroup,guild_strength}).
-record(activity_value_init_s2c, {msgid=1401,avlist,value,status}).
-record(trade_role_accept_c2s, {msgid=561,roleid}).
-record(activity_tab_isshow_s2c, {msgid=1690,ts}).
-record(tangle_topman_pos_s2c, {msgid=835,roleposes}).
-record(country_block_talk_c2s, {msgid=1648,name}).
-record(pet_riseup_c2s, {msgid=924,petid,needs,protect}).
-record(guild_clear_nickname_c2s, {msgid=1447,roleid}).
-record(mainline_reward_c2s, {msgid=1570,chapter,stage,reward}).
-record(group_decline_c2s, {msgid=155,roleid}).
-record(user_auth_c2s, {msgid=410,username,userid,time,cm,flag,userip,type,sid,serverid,openid,openkey,appid,pf}).
-record(guild_member_pos_s2c, {msgid=1249,posinfo}).
-record(finish_register_s2c, {msgid=352,gourl}).
-record(dragon_fight_left_time_s2c, {msgid=1259,left_seconds}).
-record(answer_start_notice_s2c, {msgid=1125,num,id}).
-record(guild_monster_opt_result_s2c, {msgid=354,result}).
-record(rank_chess_spirits_single_s2c, {msgid=1443,param}).
-record(entry_guild_battle_s2c, {msgid=1655,result,lefttime}).
-record(goals_init_c2s, {msgid=644}).
-record(festival_recharge_exchange_c2s, {msgid=1694,id}).
-record(buy_item_c2s, {msgid=313,npcid,item_clsid,count}).
-record(mp_package_s2c, {msgid=809,itemidl,itemidh,buffid}).
-record(festival_recharge_update_s2c, {msgid=1695,id,state,today_charge_num}).
-record(group_decline_s2c, {msgid=161,roleid,username}).
-record(update_guild_apply_state_s2c, {msgid=1210,guildlid,guildhid,applyflag}).
-record(inspect_c2s, {msgid=403,serverid,rolename}).
-record(md, {mailid,content,add_silver,add_gold,add_item}).
-record(chess_spirit_get_reward_c2s, {msgid=1181,type}).
-record(duel_decline_c2s, {msgid=711,roleid}).
-record(duel_decline_s2c, {msgid=721,roleid}).
-record(refresh_everquest_c2s, {msgid=852,everqid,freshtype}).
-record(mail_sucess_s2c, {msgid=541}).
-record(pet_up_growth_s2c, {msgid=914,result,next}).
-record(pet_opt_error_s2c, {msgid=916,reason}).
-record(levelup_opt_c2s, {msgid=1221,level}).
-record(country_leader_update_s2c, {msgid=1647,leader}).
-record(quest_get_adapt_c2s, {msgid=96}).
-record(loop_tower_enter_higher_s2c, {msgid=659,higher}).
-record(mail_query_detail_s2c, {msgid=534,mail_detail}).
-record(vip_npc_enum_s2c, {msgid=676,vip,bonus}).
-record(init_open_service_activities_s2c, {msgid=1680,activeid,partinfo,starttime,endtime,lefttime,info,state}).
-record(spa_error_s2c, {msgid=1610,reason}).
-record(dragon_fight_num_c2s, {msgid=1261,npcid}).
-record(congratulations_levelup_remind_s2c, {msgid=1140,roleid,rolename,level}).
-record(venation_time_countdown_s2c, {msgid=1287,roleid,time}).
-record(guild_destroy_s2c, {msgid=387,reason}).
-record(achieve_reward_c2s, {msgid=631,id}).
-record(christmas_tree_hp_s2c, {msgid=1742,curhp,maxhp}).
-record(pet_random_talent_c2s, {msgid=1485,petid,type}).
-record(pet_upgrade_quality_up_c2s, {msgid=1501,type,petid,needs}).
-record(update_item_s2c, {msgid=120,items}).
-record(dfr, {fn,level,job,guildname,gender}).
-record(init_signature_s2c, {msgid=471,signature}).
-record(chess_spirit_quit_c2s, {msgid=1182}).
-record(chess_spirit_update_power_s2c, {msgid=1172,newpower}).
-record(offline_exp_exchange_gold_c2s, {msgid=1135,type,hours}).
-record(reset_random_rolename_c2s, {msgid=1121}).
-record(guild_application_op_c2s, {msgid=396,roleid,reject}).
-record(mail_delete_s2c, {msgid=539,mailid}).
-record(user_auth_fail_s2c, {msgid=411,reasonid}).
-record(chat_failed_s2c, {msgid=142,reasonid,cdtime}).
-record(rank_level_s2c, {msgid=1437,param}).
-record(cancel_trade_c2s, {msgid=565}).
-record(clear_crime_c2s, {msgid=733,type}).
-record(lottery_otherslot_s2c, {msgid=506,items}).
-record(add_friend_c2s, {msgid=482,fn}).
-record(designation_update_s2c, {msgid=1541,designationid}).
-record(enum_skill_item_c2s, {msgid=412,npcid}).
-record(mainline_init_c2s, {msgid=1560}).
-record(venation_active_point_start_c2s, {msgid=1283,venation,point,itemnum}).
-record(guild_member_depart_c2s, {msgid=366}).
-record(server_treasure_transport_start_s2c, {msgid=1554,left_time}).
-record(pet_explore_start_c2s, {msgid=972,petid,explorestyle,siteid,lucky}).
-record(congratulations_received_c2s, {msgid=1145,level,rolename}).
-record(leave_guild_battle_c2s, {msgid=1656}).
-record(becare_friend_s2c, {msgid=485,fn,fid}).
-record(pet_explore_info_c2s, {msgid=970,petid}).
-record(equipment_upgrade_c2s, {msgid=615,equipment,upgrade}).
-record(other_role_map_init_s2c, {msgid=16,others}).
-record(role_map_change_s2c, {msgid=14,x,y,lineid,mapid}).
-record(start_guild_transport_failed_s2c, {msgid=1552,reason}).
-record(goals_reward_c2s, {msgid=642,days,part}).
-record(entry_loop_instance_apply_c2s, {msgid=1800,type}).
-record(chess_spirit_game_over_s2c, {msgid=1183,type,section,used_time_s,reason}).
-record(lti, {protoid,item_count}).
-record(tangle_kill_info_request_s2c, {msgid=1752,year,month,day,battletype,battleid,killinfo,bekillinfo}).
-record(set_black_c2s, {msgid=475,fn}).
-record(pet_random_talent_s2c, {msgid=1487,power,hitrate,criticalrate,stamina}).
-record(learned_skill_s2c, {msgid=71,creatureid,skills}).
-record(pet_explore_gain_info_s2c, {msgid=976,petid,gainitem}).
-record(player_level_up_s2c, {msgid=111,roleid,attrs}).
-record(loudspeaker_opt_s2c, {msgid=145,reasonid}).
-record(a, {id,name,ownerid,ownername,ownerlevel,itemnum}).
-record(smi, {mitemid,sort,uptime,mycount,price,discount}).
-record(pet_explore_speedup_c2s, {msgid=973,petid}).
-record(group_list_update_s2c, {msgid=163,leaderid,members}).
-record(get_timelimit_gift_c2s, {msgid=1021}).
-record(guild_member_delete_s2c, {msgid=385,roleid,reason}).
-record(rename_result_s2c, {msgid=57,errno}).
-record(treasure_transport_call_guild_help_s2c, {msgid=1559}).
-record(learned_pet_skill_s2c, {msgid=929,pskills}).
-record(detail_friend_c2s, {msgid=491,fn}).
%%丹药【小五】
-record(get_furnace_queue_info_c2s,{msgid=2411}).
-record(furnace_queue_info_s2c,{msgid=2413,queues}).
-record(furnace_queue_info_unit,{queueid, num, status, pillid, queue_remained_time, create_pill_remained_time}).
-record(create_pill_c2s,{msgid=2418, pillid, times}).
-record(get_furnace_queue_item_c2s,{msgid=2412, queueid}).
-record(accelerate_furnace_queue_c2s, {msgid=2419,queueid}).
-record(pill_error_s2c, {msgid=2420, errorid}).
-record(quit_furnace_queue_c2s, {msgid=2410,queueid}).
-record(unlock_furnace_queue_c2s, {msgid=2416,unlock_type, queueid}).
-record(up_furnace_c2s, {msgid=2414,auto_buy}).
-record(furnace_info_s2c, {msgid=2415,level}).
-record(pill_info_s2c, {msgid=2417,pills}).
-record(pill,{cur_value, pillid}).


%%占星
-record(astrology_init_c2s,{msgid=2192}).
-record(astrology_init_s2c,{msgid=2193,objs}).
-record(tss,{slot, tid}).
-record(astrology_action_c2s,{msgid=2190,position}).
-record(astrology_action_s2c,{msgid=2191,obj}).
-record(astrology_pickup_all_c2s,{msgid=2196,position}).
-record(astrology_pickup_all_s2c,{msgid=2197,slots}).
-record(astrology_sale_all_c2s,{msgid=2200}).
-record(astrology_sale_all_s2c,{msgid=2201,slots}).
-record(astrology_add_money_c2s,{msgid=2216}).
-record(astrology_open_panel_c2s,{msgid=2100}).
-record(astrology_update_value_s2c,{msgid=2217,value}).
-record(astrology_money_and_pos_s2c,{msgid=2202,money, pos}).
-record(astrology_error_s2c,{msgid=2209, reason}).
-record(astrology_sale_c2s,{msgid=2198, slot}).
-record(astrology_sale_s2c,{msgid=2199, slot}).
-record(astrology_pickup_c2s,{msgid=2194, slot}).
-record(astrology_pickup_s2c,{msgid=2195, slot}).
-record(astrology_item_pos_c2s,{msgid=2219}).
-record(ss,{slot, level, status, id, exp, quality}).
-record(astrology_mix_c2s,{msgid=2203,to_slot, from_slot}).
-record(astrology_mix_all_c2s,{msgid=2204,to_slot, from_slot}).
-record(astrology_lock_c2s,{msgid=2205,slot}).
-record(astrology_unlock_c2s,{msgid=2206,slot}).
-record(astrology_package_size_s2c,{msgid=2207,bodynum, packnum}).
-record(astrology_init_package_s2c,{msgid=2208,objs}).
-record(astrology_add_s2c,{msgid=2211,objs}).
-record(astrology_delete_s2c,{msgid=2212,slots}).
-record(astrology_update_s2c,{msgid=2213,obj}).
-record(astrology_expand_package_c2s,{msgid=2214}).
-record(astrology_swap_c2s,{msgid=2215,desslot, srcslot}).
-record(other_astrology_info_s2c,{msgid=2218,value, objs, packnum}).
-record(astrology_active_c2s,{msgid=2220,slot}).

%%一键征友【小五】
-record(auto_find_friend_c2s,{msgid=2251}).
-record(auto_find_friend_s2c,{msgid=2269,friend}).

%% Author: zhanglei
%% Created: 2012-1-6

-record(loop_instance_proto,{layer,exp,money,bonus,soulpower,instance_proto,type,monsters,time,targetnpclist,bornpos}). %% proto
-record(loop_instance,{id,times,members,levellimit}). %% proto

-record(role_loop_instance,{roleid,record}). %%disc

-record(loop_instance_record,{layer,besttime}).
%% Author: zhanglei
%% Created: 2012-1-6

%%
%%internal msg 
%%
-define(INTERNAL_MSG_NOTIFY_VOTE,1).
-define(INTERNAL_MSG_VOTE,2).
-define(INTERNAL_MSG_NOTIFY_ENTRY,3).


%%
%%
%%
-define(INTERNAL_STATE_IDLE,0).	 		%%未投票
-define(INTERNAL_STATE_AGREE,1).		%%同意
-define(INTERNAL_STATE_DISAGREE,2).		%%不同意
-define(INTERNAL_STATE_DONOT_MATCH,3).	%%不符合条件


-define(VOTE_TIME_S,10).		%%投票持续时间


-define(LOOP_INSTANCE_LAYER_COMPLETE,1).			%%已通关
-define(LOOP_INSTANCE_LAYER_UNCOMPLETE,2).			%%未通关%%抽奖规则
-record(lottery_droplist,{class_level_id,class,level,ruleids}).
-record(lottery_counts,{level,count}).
-record(role_lottery,{roleid,last_lottery,leftcount,status}). %%statue = open |closed
%%邮件

%% type: 1->sys | 2->normal
%% stastus: true->read | false-> unread
-record(mail,{mailid,from,toid,title,content,add_items,add_gold,add_silver,status,send_time,type}). 

-record(mainline_proto,
				{chapter,			%%章节
				  stage,			%%关卡
				  pre_stage,		%%上一关
				  entry_condition,	%%开启条件
				  entry_times,		%%每天可进入次数
				  difficulty,		%%难度 
				  class,			%%职业
				  transportid,		%%副本传送id
				  monsterslist,		%%怪物id列表
				  type,				%%关卡类型
				  time_s,			%%挑战时间
				  killmonsterlist,	%%击杀怪物列表
				  protectnpclist,	%%保护NPC列表
				  defend_sections,	%%防守波数
				  first_award_money,%%首次奖励金币
				  first_award_exp,	%%首次奖励经验
				  first_award_items,%%首次奖励物品
				  common_award_money,%%日常普通奖励金币
				  common_award_exp,		%%日常普通奖励经验
				  common_award_items,%%日常普通奖励物品
				  level_factor,		%%评分等级系数
				  time_factor,		%%评分时间系数
				  designation,		%%称号
				  section_duration	%%怪物刷新间隔
				  }).

%%
%%award_state {difficulty,flag} 
%%timerecord {lasttimestamp,times}
%%				  			  
-record(role_mainline,{roleid,record_list}).

-record(mainline_defend_config,
					{
						chapter,		%%章节
				 		stage,			%%关卡
				 		difficulty,		%%难度 
				  		class,			%%职业
				  		section,		%%波数
				  		spawns
					}).-define(EASY,1).								%%关卡难度 容易
-define(DIFFICULT,2).							%%关卡难度 困难

-define(SUCCESS,1).								%%挑战结果 成功
-define(FAILD,2).								%%挑战结果 失败

%%
%%奖励状态
%%
-define(REWARD_STATE_NULL,0).					%%无奖励
-define(REWARD_STATE_FIRST,1).					%%首次奖励 简单					
-define(REWARD_STATE_COMMON,2).					%%日常奖励 简单
-define(REWARD_STATE_FIRST_DIFFICULT,3).		%%首次奖励 困难
-define(REWARD_STATE_COMMON_DIFFICULT,4).		%%日常奖励 困难


-define(STAGE_INCOMPLETE,1).					%%未通关
-define(STAGE_COMPLETE,2).						%%已通关

-define(STAGE_BEFORE_ENTRY_MAP,1).			%%进入地图之前
-define(STAGE_ENTRY_MAP_AND_PREPARE,2).		%%进入地图之后 开始挑战之间
-define(STAGE_STATE_FIGHT,3).				%%正在挑战
-define(STAGE_STATE_REWARD,4).				%%领取奖励


-define(MAX_TIME_SCORE,600).				%%最高时间分数

%%
%%关卡脚本模块名
%% 
%%1.击杀所有怪物
%%2.限时击杀所有怪物
%%3.击杀指定怪物
%%4.限时击杀指定怪物
%%5.防守类型 击杀指定波数的怪物 并保证特定npc不死
%%6.防守类型副本 击杀指定波数的怪物 不管npc的死活
%% 持续更新中
%%

-define(STAGE_KILLALL,1).
-define(STAGE_KILLALL_AND_TIMELIMIT,2).
-define(STAGE_KILLPART,3).
-define(STAGE_KILLPART_AND_TIMELIMIT,4).
-define(STAGE_DEFEND_AND_PROTECT_NPC,5).
-define(STAGE_DEFEND,6).


-define(BY_LEVELUP,1).
-define(BY_COMPLETE,2).

					%%% File    : map_def.hrl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 17 Jun 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

%% 定义地图格子的宽度
-define(GRID_WIDTH, 28).
-define(MAP_DATA_TAG_NORMAL,0).
-define(MAP_DATA_TAG_CANNOT_WALK,1).
-define(MAP_DATA_TAG_SITDOWN_ADDATION,2).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 地图信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-ifndef(MAP_INFO_STRUCT_H).
-define(MAP_INFO_STRUCT_H,true).
-compile({inline, [{get_grid_width_from_mapinfo, 1},
		   {get_proc_from_mapinfo, 1}
		  ]}).

-record(gm_map_info, {map_id, line_id, map_proc, map_node, grid_width, width}).

create_mapinfo(MapId,LineId,MapNode,MapProc,GridWith) ->
	#gm_map_info{map_id = MapId, line_id = LineId, map_proc = MapProc, map_node = MapNode, grid_width = GridWith}.

get_grid_width_from_mapinfo(MapInfo) ->
	#gm_map_info{grid_width=Grid_width} = MapInfo,
	Grid_width.
set_grid_width_to_mapinfo(MapInfo, Grid_width) ->
	MapInfo#gm_map_info{grid_width=Grid_width}.

get_proc_from_mapinfo(MapInfo) ->
	#gm_map_info{map_proc=MapProc} = MapInfo,
	MapProc.
set_proc_to_mapinfo(MapInfo, Proc) ->
	MapInfo#gm_map_info{map_proc=Proc}.

get_node_from_mapinfo(MapInfo) ->
	#gm_map_info{map_node=Map_node} = MapInfo,
	Map_node.
set_node_to_mapinfo(MapInfo, Node) ->
	MapInfo#gm_map_info{map_node=Node}.
	
get_mapid_from_mapinfo(MapInfo) ->
	#gm_map_info{map_id=MapId} = MapInfo,
	MapId.
set_mapid_to_mapinfo(MapInfo, MapId) ->
	MapInfo#gm_map_info{map_id=MapId}.

get_lineid_from_mapinfo(MapInfo) ->
	#gm_map_info{line_id=LineId} = MapInfo,
	LineId.
set_lineid_to_mapinfo(MapInfo, LineId) ->
	MapInfo#gm_map_info{line_id=LineId}.

-endif.%% Author: adrian
%% Created: 2010-7-7
%% Description: TODO: Add description to mnesia_table_def

-record(npc_drop,{npcid,rate,ruleids}).		%%set, rate = percent
-record(drop_rule,{ruleid,name,roleflag,itemsdroprate}).

-record(quest_role,{roleid,quest_list}).
-record(quest_npc,{npcid,quest_action}).

-record(quests,{id,isactivity,
				level,limittime,required,prevquestid,nextquestid,
				rewrules,rewitem,choiceitemid,rewxp,reworreqmoney,
				reqmob,reqmobitem,objectivemsg,objectivetext,acc_script,on_acc_script,com_script,on_com_script,direct_com_disable}).

-record(roleattr,{roleid,account,name,sex,class,level,exp,hp,
				  mana,currencygold,currencygift,silver,boundsilver,mapid,coord,
				  bufflist,training,packagesize,groupid,guildid,pvpinfo,pet,offline,soulpower,stallname,honor,fightforce}).		%%set

-record(classbase,{classid,level,strength,agile,intelligence,stamina,power,magicdefense,rangedefense,meleedefense,hprecover,hprecoverinterval,mprecover,mprecoverinterval,commoncool}). %% bag

-record(rolepro,{roleid,rolename,playerid,image,vocation,bluename}).
-record(transports, {mapid,tranportid,coord,transid,description}).
-record(skills,{id,level,name,
	       type,rate,target_type,max_distance,
	       isaoe,aoeradius,interrupt,aoe_max_target,
	       target_destroy,aoe_target_destroy,self_destroy,
	       cooldown,cast_type,cast_time,addtion_threat,
	       target_buff,caster_buff,remove_buff,cost,flyspeed,learn_level,class,script,money,required_skills,hit_addition,soulpower,creature,items,addtion_power}).%%bag
	       
	       
-record(skillinfo,{skillid,skilllevel,casttime}).	
-record(role_skill,{roleid,skillinfo}). %% set

-record(quickbarinfo,{bar_pos,classid,objectid}).
-record(role_quick_bar,{roleid,quickbarinfo}). %% set

%% for items
-record(item_template,{entry,name,class,displayed,equipmentset,level,qualty,requiredlevel,stackable,maxdurability,inventorytype,sockettype,allowableclass,useable,sellprice,damage,defense,states,spellid,spellcategory,spellcooldown,bonding,maxsoket,scriptname,questid,baserepaired,overdue_type,overdue_args,overdue_transform,enchant_ext}).
-record(equipmentset,{id,num,states,includeids}).
-record(playeritems,{id,ownerguid,entry,enchantments,count,slot,isbond,sockets,duration,cooldowninfo,enchant,overdueinfo}). %% set index[ownerguid]

-record(creature_proto,{
					id,  				%%模板id
					name,	
					level,
					npcflags,			%%npc类型
					hpmax,
					mpmax,
					attacktype,	
					power,		
					commoncool,			%%公共冷却
					immunes,			%%免疫{近，远，魔}
					hitrate,			%%命中
					dodge,			%%闪避
					criticalrate,		%%暴击
					criticaldestroyrate,		%%暴击伤害
					toughness,			%%韧性
					debuff_resist,		%%debuff免疫{imprisonment_resist,silence_resist,daze_resist,poison_resist,normal_resist}
					walkspeed,			%%行走速度
					runspeed,			%%跑动速度
					exp,				%%携带经验
					min_money,		%%掉落最小金币
					max_money,		%%掉落最大金币
					skills,				%%技能[]
					skillrates,			%%技能释放几率,0为条件触发[]
					defense,			%%防御力{近，远，魔}
					hatredratio,		%%仇恨比率
					alert_radius,		%%警戒区域半径
					bounding_radius,	%%领土范围半径
					script_hatred,		%%仇恨函数
					script_skill,		%%技能释放脚本
					displayid,
					walkdelaytime,				%%行走停留					
					faction,			%%种族
					death_share,			%%是否是任务共享怪
					script_baseattr			%%基础属性计算脚本
					}).

-record(creature_spawns,{
					id,
					protoid,
					mapid,
					bornposition,
					movetype,
					waypoint,					
					respawntime,
					actionlist,
					hatreds_list,
					born_with_map
					}).

					
-record(buffers,{id,level,name,description,class,resist_type,duration,effect_interval,addition_threat,effectlist,effect_argument,deadcancel,can_active_cancel}).

-record(role_pos,{roleid, lineid, mapid , rolename, rolenode,roleproc,gatenode,gateproc}). %% set ram
-record(chat_condition,{id, items,level}).

-record(groups,{groupid,isrecruite,leaderid,instance,members,description}). %% set [isrecruite]

-record(idmax,{idtype,maxvalue}). %% set

%%
%% npc functions
%%
-record(npc_functions,{npcid,function}).%% set


%%物品价格 currencytype: 1-> 银  2->金  3->礼金
-record(itemprice,{currencytype,price}).

%%售卖列表,{物品id,一捆的个数,价格：为物品价格的列表}
-record(sellitem,{itemid,prices}).
%%ipc售卖列表
-record(npc_sell_list,{npcid,sellitems}). 
-record(npc_exchange_list,{npcid,exchangeitems}).

-record(npc_quest_accept,{npcid,questid}).	%%bag

-record(npc_quest_submit,{npcid,questid}).	%%bag

-record(transport_channel,{id,mapid,coord,type,level,items,money,viplevel}). %%set

-record(npc_trans_list,{npcid,id}). %%set

-record(fatigue,{userid,fatigue,offline,relex}).

-record(levelitem, {level, prices}).

-record(skillitem,{skillid,levelitems}). 

%%npc技能学习
-record(everquest_list,{npcid,everlist}). %set


%%gm封禁表
-record(gm_blockade,{roleid_type,start_time,duration_time}).

%%gm 通知管理
-record(gm_notice,{id,ntype,left_count,begin_time,end_time,interval_time,notice_content,last_notice_time}).
-record(gm_role_privilege,{roleid,privilege}).

-record(player_option,{roleid,options}).

%%商城
-record(mall_item_info,{id,ntype,special_type,ishot,name,sort,price,discount,tips,displayid,restrict,bodcast}).
-record(mall_sales_item_info,{id,ntype,name,sort,price,discount,duration,sales_time,restrict,bodcast}).
-record(mall_up_sales_table,{id,ntype,name,sort,price,discount,duration,uptime,restrict,bodcast}).
-record(role_buy_mall_item,{roleid,buylog}).%%buylog{id,time,count}
-record(role_buy_log,{roleid,buylog}).%%buylog[{latest,tuple},{something,tuple},{something,tuple}......] 
-record(role_mall_integral,{roleid,charge_integral,consumption_integral}).
%%账号，充值
-record(account,{username,roleids,gold,qq_gold,local_gold,nickname,gender,first_login_ip,first_login_time,last_login_ip,last_login_time,login_days,is_yellow_vip,is_yellow_year_vip,yellow_vip_level,first_login_platform,login_platform}).
-record(account_old,{username,roleids,gold}).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%				副本
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%副本模板表
-record(instance_proto,{protoid,type,create_leadertag,create_item,level,membernum,dateline,
						quests,item_need,can_direct_exit,datetimes,restrict_items,level_mapid,duration_time,nextproto}).	%%set
%%玩家副本表
-record(role_instance,{roleid,starttime,instanceid,lastpostion,log}).	%%set
%%副本位置表
-record(instance_pos,{instance_id,creation,starttime,can_join,node,pid,mapid,protoid,members}).%% set ram

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				挂机
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(block_training,{level,growth,duration,spgrowth}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				地图信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(map_info,{mapid,map_name,is_instance,map_tag,restrict_items,script,can_flyshoes,linetag,serverdataname,pvptag}).

%%成就
-record(achieve,{achieveid,chapter,part,target,bonus,bonus2,type,script}).
-record(achieve_role,{roleid,achieves}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				个人pk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%战场日志表:日期,类型:1:30-49 2:50-69 3:70-89 4:90
-record(battlefield_proto,{protoid,args,start_line,duration,instance_proto,respawn_buff}).
-record(tangle_battle,{date_class,info,has_record}).
-record(tangle_reward_info,{rankedge,honor,exp,item}).
-record(role_tangle_battle,{roleid,selfinfo}).
-record(tangle_battle_role_killnum,{roleid,killnum}).
-record(yhzq_winner_raward,{type,score,honor,exp,item}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				轮回塔
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(loop_tower,{layer,consum_money,enter_prop,convey_prop,exp,bonus,instance_id,week_bonus,monsters,loop_prop}).
-record(role_loop_tower,{roleid,layertime,highest,log}).
-record(loop_tower_instance,{layer,roleid,rolename,time}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%					日常
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(everquests,{id,type,special_tag,required,datelines,guild_required,qualityrates,refresh_info,rounds_num,clear_time,quests,sections,section_counts,section_rewards,reward_exp_type,quality_extra_rewards,free_recover_interval}).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				VIP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(vip_level,{level,gold,addition,bonus}).
-record(vip_role,{roleid,start_time,duration,level,bonustime,logintime,flyshoes}).
-record(role_login_bonus,{roleid,bonustime}).
-record(role_sum_gold,{roleid,sum_gold,duration_sum_gold}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%			series_kill
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(series_kill,{level,kill_num,effect_time,buff_info,npc_level_diff,instance_power_effect}).

-record(role_petnum,{level,default_num,max_num}).	

-record(pet_up_reset,{protoid,main_growth_rate,consume,needs,protect,locked}).
-record(pet_up_abilities,{protoid_growth,rate,next,failure,consume,needs,protect}).
-record(pet_up_stamina,{protoid_growth,rate,next,failure,consume,needs,protect}).						
-record(pet_up_riseup,{protoid,rate,next,failure,consume,needs,protect}).						

-record(pet_explorer,{mapid,pet_level,normal_consume,special_consume,time,date_line,normal_drops,special_drops}).
-record(pet_present,{level,drop_rules}).

-record(role_level_soulpower,{level,maxpower,spreward}).
							
-record(faction_relations,{id,friendly,opposite}).

-record(ai_agents,{id,entry,type,events,conditions,chance,maxcount,skill,target,cooldown,msgs,script,next_ai}).

-record(auto_name,{id,last_name,first_name}).
-record(auto_name_used,{name,roleid,roleinfo}).
-record(activity,{id,start,duration,spec_info}).
-record(answer_option,{id,level,start,sign_before,nums,interval,vip_addtion,all_addtion,rewards,vip_props,base_exp}).
-record(answer,{id,correct,score,time}).
-record(answer_roleinfo,{roleid,roleinfo}).
-record(equipment_sysbrd,{id,itemlist,brdid}).
-record(congratulations,{level,notice_range,becount,bereward,reward,notice_count}).
-record(role_congratu_log,{roleid,log}).

-record(yhzq_battle,{id,spawnpos,npcproto,lamsterbuff}).
%%-record(yhzq_battle,{id,playersnum,spawnpos,npcproto}).
-record(yhzq_battle_record,{date_class,info,has_record,ext}).			%%永恒之旗战场记录

-record(timelimit_gift,{id,droplist}).

-record(role_timelimit_gift,{roleid,last_gift_index,last_gift_time,last_gift,ext}).

-record(treasure_spawns,{id,type,maps,interval,round_num,spawn_num,map_spawns}).
-record(loudspeaker,{id,loudspeaker_details}).
-record(facebook_bind,{roleid,fb_quest}).	%%fb_quest:[{fb_id,msgid}]

-record(refine_system,{serial_number,output_bond_item,output_unbond_item,need_items,rate,need_money,output_type}). %%need_items:[{[bond_protoid,unbond_protoid],count}];rate:100;needmoney:300;output_type:judge output_item_type

-record(jszd_rank_option,{rank,guild_money,guild_score,rolehonor,exp,bonus}).
-record(jszd_role_score_honor,{numedge,honor}).
-record(jszd_role_score_info,{roleid,score,killnum}).
%% MySQL result record:
-record(mysql_result,
	{fieldinfo=[],
	 rows=[],
	 affectedrows=0,
	 error=""}).
%% packet max size 64kb and safety ,otherwise may be there is too large packet
-define(TCP_OPT_PACKET,{packet, 2}).
-define(PACKAGE_HEADER_BIT_LENGTH,16).

-define(INIT_PACKET,{packet,0}).

-define(TCP_OPTIONS,[binary,?INIT_PACKET, {reuseaddr, true},{keepalive, true}, {backlog, 256}, {active, false}]).

-define(TCP_CLIENT_SOCKET_OPTIONS,[binary, {active, once}, ?TCP_OPT_PACKET]).

-define(ORI_TCP_CLIENT_SOCKET_OPTIONS,[binary, {active, false},?INIT_PACKET]).

%% equal to <<"<policy-file-request/>\0">>
-define(CROSS_DOMAIN_FLAG, <<60,112,111,108,105,99,121,45,102,105,108,101,45,114,101,113,117,101,115,116,47,62,0>>).

-define(CROSS_DOMAIN_FLAG_HEADER,<<60,112,111,108>>).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				NPC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%动态npc存活时间
-define(DYNAMIC_NPC_LIFE_TIME,3600000).		%%60min


		

%%攻击移动间歇
-define(MOVE_TO_TARGET_DELAY_TIME,500).	
%%怪物死亡停留地图时间
-define(DEAD_LEAVE_TIME,1000).
%%警戒扫描间歇
-define(NPC_ALERT_TIME,2000).
%%移动间歇
-define(MOVE_DELAY_TIME,10000).	
%%默认攻击距离
-define(DEFAULT_ATTACK_RANGE,3).
%%喊话几率
-define(DEFAULT_SHOUT_RATE,100).
%%NPC功能key值
-define(NPC_FUNCTION_TRAD,1).					%%交易
-define(NPC_FUNCTION_TRANSPOT,2).				%%传送
-define(NPC_FUNCTION_QUEST,3).					%%任务
-define(NPC_FUNCTION_SKILL,4).					%%技能
-define(NPC_FUNCTION_GUILD,5).					%%公会
-define(NPC_FUNCTION_MAIL,6).					%%邮件
-define(NPC_FUNCTION_EQUIPMENT_ENCHANTMENT,7).	%%装备升星
-define(NPC_FUNCTION_EQUIPMENT_SOCK,8).			%%装备打孔，镶嵌
-define(NPC_FUNCTION_EQUIPMENT_STONEMIX,9).		%%宝石合成
-define(NPC_FUNCTION_STORAGE,10).				%%仓库
-define(NPC_FUNCTION_LOOP_TOWER,11).			%%轮回塔
-define(NPC_FUNCTION_BATTLE_WATCH,12).				%%战场查看
-define(NPC_FUNCTION_EVERQUEST,13).				%%循环任务
-define(NPC_FUNCTION_VIP,14).					%%VIP
-define(NPC_FUNCTION_PET_RESET,15).				%%pet_reset
-define(NPC_FUNCTION_PET_UP_GROWTH,16).			%%pet_upgrowth
-define(NPC_FUNCTION_PET_UP_STAMINAGROWTH,17).	%%pet_up_staminagrowth
-define(NPC_FUNCTION_EXCHANGE,18).				%%兑换
-define(NPC_FUNCTION_DRAGON_FIGHT,19).			%%暴龙
-define(NPC_FUNCTION_CHESS_SPIRIT,20).			%%棋魂
-define(NPC_FUNCTION_ITEM_IDENTIFY,21).			%%物品鉴定与合成
-define(NPC_FUNCTION_GUILD_TREASURE_TRANSPORT,22).			%%帮会运镖
-define(NPC_FUNCTION_GUILDBATTLE_APPLY,23).			%%帮会战报名
-define(NPC_FUNCTION_GUILD_IMPEACH,24).				%%帮会弹劾
-define(NPC_FUNCTION_LOOP_INSTANCE_JHBY,25).		%%极寒冰域
-define(NPC_FUNCTION_LOOP_INSTANCE_XYGJ,26).		%%雪域古迹
-define(NPC_FUNCTION_SMALL_TREE,33).				%%幼小的魔法圣诞树
-define(NPC_FUNCTION_FINAL_TREE,34).				%%华丽的魔法圣诞树
-define(NPC_FUNCTION_GUILDINSTANCE,36).				%%进入帮会副本




-define(CREATOR_LEVEL_BY_SYSTEM,0).			%%系统创建的NPC	等级参数
-define(CREATOR_BY_SYSTEM,0).				%%系统创建的NPC

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
	
		
	-record(offline_exp,{level,hourexp,exchange}).
-record(offline_everquests_exp,{id,quest_ids,level_range,exp,max,addcount}).
-record(offline_exp_rolelog,{roleid,offline_log}).
-record(role_service_activities_db,{roleid,activities_info}).

-record(open_service_activities,{id,partinfolist}).

-record(open_service_activities_time,{id,show,starttime,endtime}).

-record(open_service_activitied_control,{id,show,starttime,endtime}).

-record(open_service_level_rank_db,{type,ranklist}).

%%开服活动
-define(NOT_FINISHED,0).			%%未完成
-define(CAN_REWARD,2).				%%可以领取
-define(FINISHED,1).				%%已完成
-define(ACTIVITY_OVERDUE,3).		%%活动超时
-define(NOT_OVERDUE,2).		%%活动进行中

-define(TYPE_COLLECT_EQUIPMENT,4).  %%搜集金装
-define(TYPE_FIGHTING_FORCE,1).     %%战力排行
-define(TYPE_ENCHANTMENT,5).        %%装备升星 wb20130409
-define(TYPE_VENATION_ADVANCE,6).   %%修为顿悟 wb20130409
-define(TYPE_LEVEL_RANK,2).  		%%等级排行
-define(TYPE_PET_TALENT_SCORE,7). 	%%宠物天赋
-define(TYPE_LOOP_TOWER,8). 		%%轮回地宫
-define(TYPE_CHESS_SPIRIT,3). 		%%棋魂
-define(FOREVER,1).
-define(EQUIP_TYPE_GOLD,4). 		%%金装的品质

-define(OPEN_SERVICE_FIGHTING_FORCE,314).
-define(OPEN_SERVICE_ROLE_LEVEL,315).
-define(OPEN_SERVICE_ROLE_SPIRIT,316).
-define(OPEN_SERVICE_PET_FIGHTING_FORCE,317).

-define(SERVICE_ACTIVITIES_TIME_ETS,service_activities_time_ets).
-define(OPEN_SERVICE_ACTIVITIES_ETS,open_service_activities_ets).%%
%%pet table define
%%
-record(pet_item_mall,{proto,name,price,quality}).
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

-define(PET_STATE_IDLE,1).			%%备战
-define(PET_STATE_BATTLE,2).		%%出战
-define(PET_STATE_EXPEDITION,3).	%%探险
-define(PET_STATE_DOMESTIC,4).		%%驯养
-define(PET_STATE_STORE,5).			%%存入仓库
-define(PET_STATE_RIDING,6).		%%骑乘


-define(PET_OPT_CALLBACK,1).	%%召回
-define(PET_OPT_CALLOUT,2).		%%召唤
-define(PET_OPT_EXPLORE,3).		%%探险
-define(PET_OPT_DOMESION,4).	%%驯养
-define(PET_OPT_DELETE,5).		%%放生
-define(PET_OPT_STORE,6).		%%存入仓库
-define(PET_OPT_RIDING,7).		%%骑乘
-define(PET_OPT_DISMOUNT,8).	%%下马

-define(PET_FUNC_BATLLE,1).		%%战斗宠
-define(PET_FUNC_RIDE,2).		%%坐骑宠

-define(PET_TALENT_TYPE_HOT,1).		%%热血
-define(PET_TALENT_TYPE_TOUGH,2).	%%坚韧
-define(PET_TALENT_TYPE_CALM,3).	%%冷静

-define(PET_TALENT_HOT_RATIO,1).		%%热血加成
-define(PET_TALENT_TOUGH_RATIO,1).	%%坚韧加成

-define(PET_ATTACK_RATIO,0.15).		%%攻击系数

-define(PET_ATTACK_TIME,1000).		%%攻击间隔

-define(PET_TRAINING_TIME_UNIT,60).	%%驯养的时间计算单位
-define(NORMAL_PET_TRAINING,1).		%%普通驯养
-define(ADVANCED_PET_TRAINING,2).	%%高级驯养

-define(PET_PRESENT_TIME,360000).		%%领养间隔 1hour

-define(NORMAL_PET_EXPLORE,1).		%%普通探险
-define(ADVANCED_PET_EXPLORE,2).	%%高级探险

-define(MAX_PETNAME_LEN,50).		%%最长宠物名

-define(PET_SWITCH_COOLTIME,2000).	%%切换冷却
-define(RIDE_SWITCH_COOLTIME,3000).	%%切换冷却

-define(PET_STAMINA_FACTOR,1).		%%宠物体质转换为主人血量上限时的系数

-define(PET_MAX_HAPPINESS,100).	%%最大快乐度

-define(PET_MIN_QUALITY,10).			%%最低品质

-define(PET_TALENTS_SORT_FAILED,0).		%%天赋排行 名落孙三

-define(PET_TRADE_LOCK,1).					%%不可交易(绑定)
-define(PET_TRADE_UNLOCK,0).				%%可交易(未绑定)

-define(PET_TOTAL_SKILL_SLOT,10).			%%宠物技能槽位
-define(PET_BORN_SKILL_SLOT,4).				%%天生技能槽位
-define(PET_COMMON_SKILL_SLOT,0).			%%普通攻击技能槽位

-define(PET_SKILL_SLOT_INACTIVE,0).			%%技能槽位未开启
-define(PET_SKILL_SLOT_ACTIVE,1).			%%技能槽位开启
-define(PET_SKILL_SLOT_ACTIVE_AND_LOCK,2).  %%技能槽位开启并锁定

-define(PET_SKILL_SLOT_LOCK_NUM,2).			%%可使用的技能锁的总数
-define(PET_SKILL_SLOTLIST_CAN_LOCK,[1,2,3,4]).	%%只有前四个技能槽能锁定

-define(PET_CAN_DELETE,1).					%%是否可放生

-define(PET_CHANGE_NAME,true).				%%修改过名字


-define(FIRST_TALENT_BROADCAST_EDGE,150).	%%第1次天赋广播界限
-define(SEC_TALENT_BROADCAST_EDGE,200).		%%第2次天赋广播界限
-define(THIRD_TALENT_BROADCAST_EDGE,250).	%%第3次天赋广播界限
-define(FOR_TALENT_BROADCAST_EDGE,300).		%%第4次天赋广播界限

-define(TYPE_POWER,1).						%%攻击天赋
-define(TYPE_HITRATE,2).					%%命中天赋
-define(TYPE_CRITICALRATE,3).				%%暴击天赋
-define(TYPE_STAMINA,4).					%%体制天赋

-define(BROADCAST_QUALITY_EDGE_REACH_31,31).	%%宠物资质上限第1次广播界限
-define(BROADCAST_QUALITY_EDGE_REACH_61,61).	%%宠物资质上限第2次广播界限
-define(BROADCAST_QUALITY_EDGE_REACH_91,91).	%%宠物资质上限第3次广播界限
-define(BROADCAST_QUALITY_EDGE_REACH_121,121).	%%宠物资质上限第4次广播界限


-define(BROADCAST_RANDOM_QUALITY_EDGE,3).	%%资质随机出3广播
-define(BROADCAST_PET_QUALITY_EDGE,61).		%%资质在61以上广播

-define(BROADCAST_QUALITY_REACH_30,30).		%%资质达到30广播
-define(BROADCAST_QUALITY_REACH_60,60).		%%资质达到60广播
-define(BROADCAST_QUALITY_REACH_90,90).		%%资质达到90广播
-define(BROADCAST_QUALITY_REACH_120,120).	%%资质达到120广播
-define(BROADCAST_QUALITY_REACH_150,150).	%%资质达到150广播


-define(LEARN_SKILL_FORCE,1).			%%强制学习技能



-define(USE_ITEM_RENAME,0).
-define(USE_GOLD_RENAME,1).

-define(PET_SPEEDUP_EXPLORE_TIME,1800).







-include("pet_define.hrl").

-record(gm_pet_info,{
					id,
					master,				%%主人
					proto,				%%宠物模板
					level,				%%宠物级别
					name,				%%姓名
					gender,				%%性别
					life,				%%当前血量
					mana,				%%当前蓝量
					quality,			%%品质
					exp,				%%经验
					totalexp,			%%总经验				
					hpmax,				%%最大血量	
					mpmax,				%%最大蓝量
					class,				%%职业
					posx,
					posy,
					path,
					state,				%%状态
					last_cast_time,		%%攻击时间
					power,				
					hitrate,		
					criticalrate,
					criticaldamage, 		
					stamina,
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
					transform,  %%属性转换率
					talentlist,%%才能
					skilllist	%%技能列表	
		       }).

create_petinfo(PetId,RoleId,Proto,Level,Name,Gender,Life,Mana,Quality,
				Hpmax,Mpmax,Class,State,{X,Y},Exp,TotalExp,Power,HitRate,CriticalRate,Stamina,CriticalDamage,Fighting_Force,Icon)->
	#gm_pet_info{
			id =PetId,
			master = RoleId,
			proto = Proto,
			level = Level,
			name = Name,
			gender = Gender,
			life = Life,
			mana = Mana,
			quality = Quality,
			exp = Exp,
			totalexp = TotalExp,
			hpmax = Hpmax,
			mpmax = Mpmax,
			class = Class,
			last_cast_time={0,0,0},
			path = [],
			state = State,
			posx = X,
			posy = Y,
			power = Power,				
			hitrate = HitRate,		
			criticalrate = CriticalRate,
			criticaldamage = CriticalDamage, 		
			stamina = Stamina,
			fighting_force = Fighting_Force,
			icon = Icon
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
	
get_life_from_petinfo(PetInfo) ->
	#gm_pet_info{life=Life} = PetInfo,
	Life.
set_life_to_petinfo(PetInfo, Life) ->
	PetInfo#gm_pet_info{life=Life}.
	
get_mana_from_petinfo(PetInfo) ->
	#gm_pet_info{mana=Mana} = PetInfo,
	Mana.
set_mana_to_petinfo(PetInfo, Mana) ->
	PetInfo#gm_pet_info{mana=Mana}.
	
get_quality_from_petinfo(PetInfo) ->
	#gm_pet_info{quality=Quality} = PetInfo,
	Quality.
set_quality_to_petinfo(PetInfo, Quality) ->
	PetInfo#gm_pet_info{quality=Quality}.
	
get_exp_from_petinfo(PetInfo) ->
	#gm_pet_info{exp=Exp} = PetInfo,
	Exp.
set_exp_to_petinfo(PetInfo, Exp) ->
	PetInfo#gm_pet_info{exp=Exp}.

get_totalexp_from_petinfo(PetInfo) ->
	#gm_pet_info{totalexp=Exp} = PetInfo,
	Exp.
set_totalexp_to_petinfo(PetInfo, Exp) ->
	PetInfo#gm_pet_info{totalexp=Exp}.	
	
get_hpmax_from_petinfo(PetInfo) ->
	#gm_pet_info{hpmax=Hpmax} = PetInfo,
	Hpmax.
set_hpmax_to_petinfo(PetInfo, Hpmax) ->
	PetInfo#gm_pet_info{hpmax=Hpmax}.
	
get_mpmax_from_petinfo(PetInfo) ->
	#gm_pet_info{mpmax=Mpmax} = PetInfo,
	Mpmax.
set_mpmax_to_petinfo(PetInfo, Mpmax) ->
	PetInfo#gm_pet_info{mpmax=Mpmax}.
	
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

get_power_from_petinfo(PetInfo)->
	#gm_pet_info{power=Power} = PetInfo,
	Power.	
set_power_to_petinfo(PetInfo,Power)->
	PetInfo#gm_pet_info{power=Power}.

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

get_stamina_from_petinfo(PetInfo)->
	#gm_pet_info{stamina = Stamina} = PetInfo,
	Stamina.	
	
set_stamina_to_petinfo(PetInfo,Stamina)->
	PetInfo#gm_pet_info{stamina = Stamina}.	
	
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
	
-record(my_pet_info,{
			petid,	
			attr_user_add,			%%玩家属性加点 {攻击,命中,暴击,体质}
			attr,					%%总属性点{攻击,命中,暴击,体质}
			talent_add,				%%天赋增加值{攻击,命中,暴击,体质}
			talent,					%%天赋{攻击,命中,暴击,体质}
			remain_attr,			%%剩余点数
			talent_score,			%%天赋分数
			talent_sort,			%%天赋排名	
			quality_value,			%%资质
			quality_up_value,		%%资质提升上限
			happiness,				%%快乐度
			equipinfo,				%%宠物装备信息
			happinesseff,			%%欢乐度影响值
			trade_lock,				%%交易锁
			changenameflag			%%是否修改过名字
		}).

get_id_from_mypetinfo(MyPetInfo)->	
	#my_pet_info{petid = Value} = MyPetInfo,
	Value.
set_id_to_mypetinfo(MyPetInfo,Value)->
	MyPetInfo#my_pet_info{petid = Value}.

get_attr_user_add_from_mypetinfo(MyPetInfo)->	
	#my_pet_info{attr_user_add = Value} = MyPetInfo,
	Value.
set_attr_user_add_to_mypetinfo(MyPetInfo,Value)->
	MyPetInfo#my_pet_info{attr_user_add = Value}.

get_attr_from_mypetinfo(MyPetInfo)->	
	#my_pet_info{attr = Value} = MyPetInfo,
	Value.
set_attr_to_mypetinfo(MyPetInfo,Value)->
	MyPetInfo#my_pet_info{attr = Value}.

get_talent_add_from_mypetinfo(MyPetInfo)->	
	#my_pet_info{talent_add = Value} = MyPetInfo,
	Value.
set_talent_add_to_mypetinfo(MyPetInfo,Value)->
	MyPetInfo#my_pet_info{talent_add = Value}.

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

get_remain_attr_from_mypetinfo(MyPetInfo)->	
	#my_pet_info{remain_attr = Value} = MyPetInfo,
	Value.
set_remain_attr_to_mypetinfo(MyPetInfo,Value)->
	MyPetInfo#my_pet_info{remain_attr = Value}.

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
	
get_equipinfo_from_mypetinfo(PetInfo)->	
	#my_pet_info{equipinfo = Value} = PetInfo,
	Value.
set_equipinfo_to_mypetinfo(PetInfo,Value)->
	PetInfo#my_pet_info{equipinfo = Value}.	

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

create_mypetinfo(PetId,Quality_Value,Quality_Up_Value,Happiness,
				Power_Add,HitRate_Add,CriticalRate_Add,Stamina_Add,
				Power_Attr,HitRate_Attr,CriticalRate_Attr,Stamina_Attr,
				T_Power_Add,T_HitRate_Add,T_CriticalRate_Add,T_Stamina_Add,
				T_Power,T_HitRate,T_CriticalRate,T_Stamina,RemainAttr,
				HappinessEff,TalentScore,TalentSort,TradeLock,Equipinfo,ChangeNameFlag
				)->
	#my_pet_info{
			petid = PetId,
			attr_user_add = {Power_Add,HitRate_Add,CriticalRate_Add,Stamina_Add},			
			attr = {Power_Attr,HitRate_Attr,CriticalRate_Attr,Stamina_Attr},		
			talent_add = {T_Power_Add,T_HitRate_Add,T_CriticalRate_Add,T_Stamina_Add},			
			talent = {T_Power,T_HitRate,T_CriticalRate,T_Stamina},		
			remain_attr = RemainAttr,			
			quality_value = Quality_Value,
			quality_up_value = Quality_Up_Value,					
			happiness = Happiness,
			happinesseff = HappinessEff,
			talent_score = TalentScore,
			talent_sort = TalentSort,
			trade_lock = TradeLock,
			equipinfo = Equipinfo,
			changenameflag = ChangeNameFlag
	}.



					%%攻击人后邪恶清除时间:1min
-define(CRIME_BLACK_NAME_TIME,50).			%%60000
-define(CRIME_CLEAR_TIME,60*60).				%%1小时比客户端时间稍短，便于验证
%%PK模式
-define(PVP_MODEL_PEACE,0).					%%和平模式
-define(PVP_MODEL_PUNISHER,1).				%%惩恶模式
-define(PVP_MODEL_GUILD,2).					%%公会模式
-define(PVP_MODEL_TEAM,3).					%%组队模式
-define(PVP_MODEL_KILLALL,4).				%%全体模式
%%PK切换
%%-define(PVP_SWITCH_MODEL_TIME_S,3600).			%%6*60*60
-define(PVP_SWITCH_MODEL_TIME_S,3600).			%%1*60*60

-define(KILLED_NUM_REACH_50,50).			%%罪恶值达到50
-define(KILLED_NUM_REACH_100,100).			%%罪恶值达到100

-define(CLEAR_ROLE_BLACK_NAME,1).			%%取消黑名字	
-define(CLEAR_CRIME,2).						%%减少罪恶值

-define(KILL_ONE_ADD_CRIME,10).				%%杀一人长多少罪恶值

-define(CRIME_BLACK_NAME,-1).				%%罪恶值-1为黑名

-define(CLEAR_CRIME_PRE_TIME,10).			%%单位时间内减少罪恶值点数

-define(CRIME_OUT_PRISON_EDGE,0).			%%罪恶小于0可出监狱

-define(ROLE_CRIME_EDGR,100).				%%人物罪恶值上限为100
%%任务扫描等级
-define(QUEST_SCAN_RANGE,5).
%%任务状态
-define(QUEST_STATUS_COMPLETE,1).
-define(QUEST_STATUS_INCOMPLETE,2).
-define(QUEST_STATUS_AVAILABLE,3).
-define(QUEST_STATUS_UNAVAILABLE,4).-ifdef(DEBUG).
-define(RELOADER_RUN,reloader:start_link()).
-else.
-define(RELOADER_RUN,nothing).
-endif.
%%consume:消耗的物品包括钱级物品，rateinfo：概率和改概率下的物品
-record(item_identify,{item_class,consume,rateinfo}).

%%坐骑合成
-record(ridepet_synthesis,{quality,consume,rateinfo}).

-record(ride_proto_db,{item_template_id,add_buff,drop_rate}). 

%%坐骑属性表
-record(attr_info,{quality,dropnum,attrrate_list}).





-define(USEITEM,1).			%%消耗物品
-define(USEGOLD,2).			%%消耗YB

-record(role_recruitments,{id,name,level,class,instance}).%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 角色信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("common_define.hrl").
-include("data_struct.hrl").
-include("map_info_struct.hrl").
-compile({inline, [{get_id_from_roleinfo, 1},
		   {get_pos_from_roleinfo, 1},
		   {get_life_from_roleinfo, 1}]}).

-record(gm_role_info, {gs_system_role_info, 
		       gs_system_map_info,
		       gs_system_gate_info,
		       pos, name, 
			   view,				%%星级
			   life, mana,
		       gender,				%%性别
		       icon,				%%头衔
		       speed, state,  
		       extra_states,
		       path, level,
		       silver,				%%游戏币，银币
		       boundsilver,			%%绑定游戏币,银币
		       gold,				%%元宝
		       ticket,				%%礼券
		       hatredratio,			%%仇恨比率
		       expratio,			%%经验比率
		       lootflag,			%%掉落系数
		       exp,					%%经验
		       levelupexp,			%%升级所需经验
		       agile,				%%敏
		       strength,			%%力
		       intelligence,		%%智
		       stamina,				%%体质
		       hpmax,		
		       mpmax,
		       hprecover,
		       mprecover,
		       power,				%%攻击力
		       class,				%%职业
		       commoncool,			%%公共冷却
		       immunes,				%%免疫力{魔，远，近}
		       hitrate,				%%命中
		       dodge,				%%闪避
		       criticalrate,		%%暴击
		       criticaldamage,		%%暴击伤害
		       toughness,			%%韧性
		       debuffimmunes,		%%debuff免疫{定身，沉默，昏迷，抗毒,一般}
		       defenses,			%%防御力{魔，远，近}
		       %%2010.9.20
		       buffer,				%%buffer
		       guildname,			%%公会名
		       guildposting,	    %%职位
		       cloth,				%%衣服
		       arm,					%%武器
		       pkmodel,				%%PK模式
		       crime,				%%罪恶值
			   viptag,				%%vip标志
		       %%2010.1.18
		       pet_id,
		       ride_display,		%%坐骑模型	
			   %%
			   camp,				%%阵营(0无1红2蓝)
			   displayid,			%%人物模型
			   companion_role,		%%双修对象
			   serverid,			%%当前服务器id
			   cur_designation,		%%人物称号
			   treasure_transport,	%%镖车
			   petexpratio,			%%宠物经验比率
			   group_id,			%%组队id
			   fighting_force,		%%战斗力
			   guildtype,			%%帮会类型
			   honor				%%荣誉值
		       }).

create_roleinfo() ->
	#gm_role_info{gs_system_role_info=#gs_system_role_info{},
		      icon = 0,
		      path=[],
			  view = 0,
		      hatredratio = 1,
		      expratio = [],
		      lootflag = 1,
		      extra_states = [],
		   	  debuffimmunes = {0,0,0,0,0},
		   	  immunes = {0,0,0},
		   	  defenses = {0,0,0},
		   	  buffer= [],
		      pet_id = 0,
			  camp = 0,
			  ride_display = 0,
			  companion_role = 0,
			  displayid = ?DEFAULT_ROLE_DISPLAYID,
			  treasure_transport = 0,
			  petexpratio = 1,
			  group_id = 0,
			  fighting_force = 0,
			  guildtype = 0,
			  honor = 0
		     }.	

set_roleinfo(RoleInfo,Role_id,Role_Class,Gender,Role_Level,RoleState,Role_pid,Role_node,Role_pos,
						Role_name,RoleSpeed,RoleLife,Hpmax,RoleMana,Mpmax,Expr,Silver,BoundSilver,LevelupExp,
						Gold,Ticket,Power,Commoncool,Hprecover,Mprecover,CriDerate,Criticalrate,Toughness,Dodge,
						Hitrate,Stamina,Agile,Strength,Intelligence,RoleIimmunes,RoleDebuffimmunes,RoleDefenses,GuildName,GuildPosting,
						RoleBuffs,Viptag,AllIcons,Crime,Pkmodel,Path,GS_GateInfo,GS_MapInfo,RoleServerId,CurDesignation,Treasure_Transport,Fighting_force,Honor)->
		RoleInfo#gm_role_info{
				gs_system_role_info=#gs_system_role_info{role_id = Role_id, role_pid = Role_pid,role_node = Role_node},
				gs_system_map_info = GS_MapInfo,
				gs_system_gate_info = GS_GateInfo,
				pos = Role_pos, 
				name = Role_name, 
				life = RoleLife, 
				mana = RoleMana,
				gender = Gender,
				icon = AllIcons,
				speed = RoleSpeed, 
				state = RoleState,  
				path = Path, 
				level = Role_Level,
				silver = Silver,
				boundsilver = BoundSilver,
				gold = Gold,
				ticket = Ticket,
				exp = Expr,	
				levelupexp = LevelupExp,
				agile = Agile,
				strength = Strength,
				intelligence = Intelligence,
				stamina = Stamina,
				hpmax = Hpmax,		
				mpmax = Mpmax,
				hprecover = Hprecover,
				mprecover = Mprecover,
				power = Power,	
				class = Role_Class,
				commoncool = Commoncool,
				immunes = RoleIimmunes,		
				hitrate = Hitrate,	
				dodge = Dodge,
				criticalrate = Criticalrate,
				criticaldamage = CriDerate,
				toughness = Toughness,			
				debuffimmunes = RoleDebuffimmunes,	
				defenses = RoleDefenses,	
				buffer = RoleBuffs,	
				guildname = GuildName,
				guildposting = GuildPosting,
				pkmodel = Pkmodel,
				crime = Crime,
				viptag = Viptag,
				serverid = RoleServerId,
				cur_designation = CurDesignation,
				treasure_transport = Treasure_Transport,		
				fighting_force = Fighting_force,
				honor = Honor
			}.
		
get_camp_from_roleinfo(RoleInfo)->
	#gm_role_info{camp=Camp} = RoleInfo,
	Camp.

set_camp_to_roleinfo(RoleInfo, Camp)->
	RoleInfo#gm_role_info{camp=Camp}.


get_pet_id_from_roleinfo(RoleInfo) ->
	#gm_role_info{pet_id=Pet_id} = RoleInfo,
	Pet_id.
set_pet_id_to_roleinfo(RoleInfo, Pet_id) ->
	RoleInfo#gm_role_info{_id=Pet_id}.

get_id_from_roleinfo(RoleInfo) ->
	#gm_role_info{gs_system_role_info=GS_system_role_info} = RoleInfo,
	get_id_from_gs_system_roleinfo(GS_system_role_info).
set_id_to_roleinfo(RoleInfo, Id) ->
	#gm_role_info{gs_system_role_info=GS_system_role_info} = RoleInfo,
	New_gs_system_roleinfo = set_id_to_gs_system_roleinfo(GS_system_role_info, Id),
	RoleInfo#gm_role_info{gs_system_role_info=New_gs_system_roleinfo}.

get_gender_from_roleinfo(RoleInfo) ->
	#gm_role_info{gender=Gender} = RoleInfo,
	Gender.
set_gender_to_roleinfo(RoleInfo, Gender) ->
	RoleInfo#gm_role_info{gender=Gender}.

get_icon_from_roleinfo(RoleInfo) ->
	#gm_role_info{icon=Icon} = RoleInfo,
	Icon.
set_icon_to_roleinfo(RoleInfo, Icon) ->
	RoleInfo#gm_role_info{icon=Icon}.
	
get_name_from_roleinfo(RoleInfo) ->
	#gm_role_info{name=Name} = RoleInfo,
	Name.
set_name_to_roleinfo(RoleInfo, Name) ->
	RoleInfo#gm_role_info{name=Name}.

get_pid_from_roleinfo(RoleInfo) ->
	#gm_role_info{gs_system_role_info=GS_system_role_info} = RoleInfo,
	get_pid_from_gs_system_roleinfo(GS_system_role_info).
set_pid_to_roleinfo(RoleInfo, Pid) ->
	#gm_role_info{gs_system_role_info=GS_system_role_info} = RoleInfo,
	New_gs_system_roleinfo = set_pid_to_gs_system_roleinfo(GS_system_role_info, Pid),
	RoleInfo#gm_role_info{gs_system_role_info=New_gs_system_roleinfo}.

get_node_from_roleinfo(RoleInfo) ->
	#gm_role_info{gs_system_role_info=GS_system_role_info} = RoleInfo,
	get_node_from_gs_system_roleinfo(GS_system_role_info).
set_node_to_roleinfo(RoleInfo, Node) ->
	#gm_role_info{gs_system_role_info=GS_system_role_info} = RoleInfo,
	New_gs_system_roleinfo = set_node_to_gs_system_roleinfo(GS_system_role_info, Node),
	RoleInfo#gm_role_info{gs_system_role_info=New_gs_system_roleinfo}.

get_pos_from_roleinfo(RoleInfo) ->
	#gm_role_info{pos=Pos} = RoleInfo,
	Pos.
set_pos_to_roleinfo(RoleInfo, Pos) ->
	RoleInfo#gm_role_info{pos=Pos}.

get_speed_from_roleinfo(RoleInfo) ->
	#gm_role_info{speed=Speed} = RoleInfo,
	Speed.
set_speed_to_roleinfo(RoleInfo, Speed) ->
	RoleInfo#gm_role_info{speed=Speed}.

get_life_from_roleinfo(RoleInfo) ->
	#gm_role_info{life=Life} = RoleInfo,
	Life.
set_life_to_roleinfo(RoleInfo, Life) ->
	RoleInfo#gm_role_info{life=Life}.

get_view_from_roleinfo(RoleInfo) ->
	#gm_role_info{view=View} = RoleInfo,
	View.
set_view_to_roleinfo(RoleInfo, View) ->
	RoleInfo#gm_role_info{view=View}.

get_state_from_roleinfo(RoleInfo) ->
	#gm_role_info{state=State} = RoleInfo,
	State.
set_state_to_roleinfo(RoleInfo, State) ->
	RoleInfo#gm_role_info{state=State}.

get_path_from_roleinfo(RoleInfo) ->
	#gm_role_info{path=Path} = RoleInfo,
	Path.
set_path_to_roleinfo(RoleInfo, Path) ->
	RoleInfo#gm_role_info{path=Path}.

get_level_from_roleinfo(RoleInfo) ->
	#gm_role_info{level=Level} = RoleInfo,
	Level.
set_level_to_roleinfo(RoleInfo, Level) ->
	RoleInfo#gm_role_info{level=Level}.

set_silver_to_roleinfo(RoleInfo, Money) ->
	RoleInfo#gm_role_info{silver=Money}.
get_silver_from_roleinfo(RoleInfo) ->
	#gm_role_info{silver=Money} = RoleInfo,
	Money.		       	 
 
set_boundsilver_to_roleinfo(RoleInfo, Money) ->
	RoleInfo#gm_role_info{boundsilver=Money}.
get_boundsilver_from_roleinfo(RoleInfo) ->
	#gm_role_info{boundsilver=Money} = RoleInfo,
	Money.		       	 

set_ticket_to_roleinfo(RoleInfo, Ticket) ->
	RoleInfo#gm_role_info{ticket=Ticket}.
get_ticket_from_roleinfo(RoleInfo) ->
	#gm_role_info{ticket=Ticket} = RoleInfo,
	Ticket.
	
set_gold_to_roleinfo(RoleInfo, Gold) ->
	RoleInfo#gm_role_info{gold=Gold}.
get_gold_from_roleinfo(RoleInfo) ->
	#gm_role_info{gold=Gold} = RoleInfo,
	Gold.	
	
set_hatredratio_to_roleinfo(RoleInfo, Hatredratio) ->
	RoleInfo#gm_role_info{hatredratio=Hatredratio}.
get_hatredratio_from_roleinfo(RoleInfo) ->
	#gm_role_info{hatredratio=Hatredratio} = RoleInfo,
	Hatredratio.

set_expratio_to_roleinfo(RoleInfo, ExpRate) ->
	RoleInfo#gm_role_info{expratio=ExpRate}.
get_expratio_from_roleinfo(RoleInfo) ->
	#gm_role_info{expratio=ExpRate} = RoleInfo,
	ExpRate.
	
set_petexpratio_to_roleinfo(RoleInfo, ExpRate) ->
	RoleInfo#gm_role_info{petexpratio=ExpRate}.
get_petexpratio_from_roleinfo(RoleInfo) ->
	#gm_role_info{petexpratio=ExpRate} = RoleInfo,
	ExpRate.

set_lootflag_to_roleinfo(RoleInfo, Lootflag) ->
	RoleInfo#gm_role_info{lootflag=Lootflag}.
get_lootflag_from_roleinfo(RoleInfo) ->
	#gm_role_info{lootflag=Lootflag} = RoleInfo,
	Lootflag.

set_gateinfo_to_roleinfo(RoleInfo, GateInfo) ->
	RoleInfo#gm_role_info{gs_system_gate_info=GateInfo}.
get_gateinfo_from_roleinfo(RoleInfo) ->
	#gm_role_info{gs_system_gate_info=GateInfo} = RoleInfo,
	GateInfo.

set_mapinfo_to_roleinfo(RoleInfo, MapInfo) ->
	RoleInfo#gm_role_info{gs_system_map_info=MapInfo}.
get_mapinfo_from_roleinfo(RoleInfo) ->
	#gm_role_info{gs_system_map_info=MapInfo} = RoleInfo,
	MapInfo.

get_mana_from_roleinfo(RoleInfo) ->
	#gm_role_info{mana=Mana} = RoleInfo,
	Mana.
set_mana_to_roleinfo(RoleInfo, Mana) ->
	RoleInfo#gm_role_info{mana=Mana}.
	
get_exp_from_roleinfo(RoleInfo) ->
	#gm_role_info{exp=Exp} = RoleInfo,
	Exp.
set_exp_to_roleinfo(RoleInfo, Exp) ->
	RoleInfo#gm_role_info{exp=Exp}.

get_levelupexp_from_roleinfo(RoleInfo) ->
	#gm_role_info{levelupexp=Exp} = RoleInfo,
	Exp.
set_levelupexp_to_roleinfo(RoleInfo, Exp) ->
	RoleInfo#gm_role_info{levelupexp=Exp}.

get_agile_from_roleinfo(RoleInfo) ->
	#gm_role_info{agile=Agile} = RoleInfo,
	Agile.
set_agile_to_roleinfo(RoleInfo, Agile) ->
	RoleInfo#gm_role_info{agile=Agile}.

get_strength_from_roleinfo(RoleInfo) ->
	#gm_role_info{strength=Strength} = RoleInfo,
	Strength.
set_strength_to_roleinfo(RoleInfo, Strength) ->
	RoleInfo#gm_role_info{strength=Strength}.

get_intelligence_from_roleinfo(RoleInfo) ->
	#gm_role_info{intelligence=Intelligence} = RoleInfo,
	Intelligence.
set_intelligence_to_roleinfo(RoleInfo, Intelligence) ->
	RoleInfo#gm_role_info{intelligence=Intelligence}.
	
get_stamina_from_roleinfo(RoleInfo) ->
	#gm_role_info{stamina=Stamina} = RoleInfo,
	Stamina.
set_stamina_to_roleinfo(RoleInfo, Stamina) ->
	RoleInfo#gm_role_info{stamina=Stamina}.	
	
get_hpmax_from_roleinfo(RoleInfo) ->
	#gm_role_info{hpmax=Hpmax} = RoleInfo,
	Hpmax.
set_hpmax_to_roleinfo(RoleInfo, Hpmax) ->
	RoleInfo#gm_role_info{hpmax=Hpmax}.	
	
get_mpmax_from_roleinfo(RoleInfo) ->
	#gm_role_info{mpmax=Mpmax} = RoleInfo,
	Mpmax.
set_mpmax_to_roleinfo(RoleInfo, Mpmax) ->
	RoleInfo#gm_role_info{mpmax=Mpmax}.		

get_hprecover_from_roleinfo(RoleInfo) ->
	#gm_role_info{hprecover=Hprecover} = RoleInfo,
	Hprecover.
set_hprecover_to_roleinfo(RoleInfo, Hprecover) ->
	RoleInfo#gm_role_info{hprecover=Hprecover}.		
	
get_mprecover_from_roleinfo(RoleInfo) ->
	#gm_role_info{mprecover=Mprecover} = RoleInfo,
	Mprecover.
set_mprecover_to_roleinfo(RoleInfo, Mprecover) ->
	RoleInfo#gm_role_info{mprecover=Mprecover}.		
	
get_class_from_roleinfo(RoleInfo) ->
	#gm_role_info{class=Class} = RoleInfo,
	Class.
set_class_to_roleinfo(RoleInfo, Class) ->
	RoleInfo#gm_role_info{class=Class}.

get_power_from_roleinfo(RoleInfo) ->
	#gm_role_info{power=Attack} = RoleInfo,
	Attack.
set_power_to_roleinfo(RoleInfo, Attack) ->
	RoleInfo#gm_role_info{power=Attack}.

get_commoncool_from_roleinfo(RoleInfo) ->
	#gm_role_info{commoncool=Commoncool} = RoleInfo,
	Commoncool.
set_commoncool_to_roleinfo(RoleInfo, Commoncool) ->
	RoleInfo#gm_role_info{commoncool=Commoncool}.
	
get_immunes_from_roleinfo(RoleInfo) ->
	#gm_role_info{immunes=Immunes} = RoleInfo,
	Immunes.
set_immunes_to_roleinfo(RoleInfo, Immunes) ->
	RoleInfo#gm_role_info{immunes=Immunes}.
	
get_hitrate_from_roleinfo(RoleInfo) ->
	#gm_role_info{hitrate=Hitrate} = RoleInfo,
	Hitrate.
set_hitrate_to_roleinfo(RoleInfo, Hitrate) ->
	RoleInfo#gm_role_info{hitrate=Hitrate}.		
	
get_dodge_from_roleinfo(RoleInfo) ->
	#gm_role_info{dodge=Missrate} = RoleInfo,
	Missrate.
set_dodge_to_roleinfo(RoleInfo, Missrate) ->
	RoleInfo#gm_role_info{dodge=Missrate}.	
	
get_criticalrate_from_roleinfo(RoleInfo) ->
	#gm_role_info{criticalrate=Criticalrate} = RoleInfo,
	Criticalrate.
set_criticalrate_to_roleinfo(RoleInfo, Criticalrate) ->
	RoleInfo#gm_role_info{criticalrate=Criticalrate}.
	
get_criticaldamage_from_roleinfo(RoleInfo) ->
	#gm_role_info{criticaldamage=Criticaldamage} = RoleInfo,
	Criticaldamage.
set_criticaldamage_to_roleinfo(RoleInfo, Criticaldamage) ->
	RoleInfo#gm_role_info{criticaldamage=Criticaldamage}.	
	
get_toughness_from_roleinfo(RoleInfo) ->
	#gm_role_info{toughness=Toughness} = RoleInfo,
	Toughness.
set_toughness_to_roleinfo(RoleInfo, Toughness) ->
	RoleInfo#gm_role_info{toughness=Toughness}.
	
get_debuffimmunes_from_roleinfo(RoleInfo) ->
	#gm_role_info{debuffimmunes=Debuffimmune} = RoleInfo,
	Debuffimmune.
set_debuffimmunes_to_roleinfo(RoleInfo, Debuffimmune) ->
	RoleInfo#gm_role_info{debuffimmunes=Debuffimmune}.	
	
get_defenses_from_roleinfo(RoleInfo) ->
	#gm_role_info{defenses=Resistances} = RoleInfo,
	Resistances.
set_defenses_to_roleinfo(RoleInfo, Resistances) ->
	RoleInfo#gm_role_info{defenses=Resistances}.

add_extra_state_to_roleinfo(RoleInfo, State) ->
	#gm_role_info{extra_states=ExtraState} = RoleInfo,
	%%RoleInfo#gm_role_info{extra_states=lists:delete(State,ExtraState) ++ [State]}.
	RoleInfo#gm_role_info{extra_states=ExtraState ++ [State]}.
get_extra_state_from_roleinfo(RoleInfo) ->
	#gm_role_info{extra_states=ExtraState} = RoleInfo,
	ExtraState.
remove_extra_state_to_roleinfo(RoleInfo, State) ->
	#gm_role_info{extra_states=ExtraState} = RoleInfo,
	RoleInfo#gm_role_info{extra_states=lists:delete(State,ExtraState)}.

get_buffer_from_roleinfo(RoleInfo) ->
	#gm_role_info{buffer=Buffer} = RoleInfo,
	Buffer.
set_buffer_to_roleinfo(RoleInfo, Buffer) ->
	RoleInfo#gm_role_info{buffer=Buffer}.

get_guildname_from_roleinfo(RoleInfo) ->
	#gm_role_info{guildname=Guildname} = RoleInfo,
	Guildname.
set_guildname_to_roleinfo(RoleInfo, Guildname) ->
	RoleInfo#gm_role_info{guildname=Guildname}.	

get_guildposting_from_roleinfo(RoleInfo) ->
	#gm_role_info{guildposting=Guildposting} = RoleInfo,
	Guildposting.
set_guildposting_to_roleinfo(RoleInfo, Guildposting) ->
	RoleInfo#gm_role_info{guildposting=Guildposting}.		
	
get_cloth_from_roleinfo(RoleInfo) ->
	#gm_role_info{cloth=Cloth} = RoleInfo,
	Cloth.
set_cloth_to_roleinfo(RoleInfo,Cloth) ->
	RoleInfo#gm_role_info{cloth=Cloth}.	

get_arm_from_roleinfo(RoleInfo) ->
	#gm_role_info{arm=Arm} = RoleInfo,
	Arm.
set_arm_to_roleinfo(RoleInfo,ItemId) ->
	RoleInfo#gm_role_info{arm=ItemId}.	

get_pkmodel_from_roleinfo(RoleInfo) ->
	#gm_role_info{pkmodel=Pkmodel} = RoleInfo,
	Pkmodel.
set_pkmodel_to_roleinfo(RoleInfo,Pkmodel) ->
	RoleInfo#gm_role_info{pkmodel=Pkmodel}.	

get_crime_from_roleinfo(RoleInfo) ->
	#gm_role_info{crime=Crime} = RoleInfo,
	Crime.
set_crime_to_roleinfo(RoleInfo,Crime) ->
	RoleInfo#gm_role_info{crime=Crime}.	

get_ride_display_from_roleinfo(RoleInfo) ->
	#gm_role_info{ride_display=Ride_display} = RoleInfo,
	Ride_display.	
set_ride_display_to_roleinfo(RoleInfo,Ride_display) ->
	RoleInfo#gm_role_info{ride_display=Ride_display}.		

get_viptag_from_roleinfo(RoleInfo)->
	#gm_role_info{viptag=Viptag} = RoleInfo,
	Viptag.
set_viptag_to_roleinfo(RoleInfo,Viptag) ->
	RoleInfo#gm_role_info{viptag=Viptag}.	

get_companion_role_from_roleinfo(RoleInfo)->
	#gm_role_info{companion_role=Companion_role} = RoleInfo,
	Companion_role.
set_companion_role_to_roleinfo(RoleInfo,Companion_role) ->
	RoleInfo#gm_role_info{companion_role=Companion_role}.	
	
get_displayid_from_roleinfo(RoleInfo)->
	#gm_role_info{displayid=Displayid} = RoleInfo,
	Displayid.
set_displayid_to_roleinfo(RoleInfo,Displayid) ->
	RoleInfo#gm_role_info{displayid=Displayid}.	

get_serverid_from_roleinfo(RoleInfo)->
	#gm_role_info{serverid=ServerId} = RoleInfo,
	ServerId.
set_serverid_to_roleinfo(RoleInfo,ServerId) ->
	RoleInfo#gm_role_info{serverid=ServerId}.

get_group_id_from_roleinfo(RoleInfo)->
	#gm_role_info{group_id=Group_id} = RoleInfo,
	Group_id.
set_group_id_to_roleinfo(RoleInfo,Group_id) ->
	RoleInfo#gm_role_info{group_id=Group_id}.


get_treasure_transport_from_roleinfo(RoleInfo)->
	#gm_role_info{treasure_transport=Treasure_Transport} = RoleInfo,
	Treasure_Transport.
	
set_treasure_transport_to_roleinfo(RoleInfo,Treasure_Transport) ->
	RoleInfo#gm_role_info{treasure_transport=Treasure_Transport}.
	
	
		
get_cur_designation_from_roleinfo(RoleInfo)->
	#gm_role_info{cur_designation=CurDesignation} = RoleInfo,
	CurDesignation.
	
set_cur_designation_to_roleinfo(RoleInfo,CurDesignation) ->
	RoleInfo#gm_role_info{cur_designation=CurDesignation}.	
	
get_fighting_force_from_roleinfo(RoleInfo)->
	#gm_role_info{fighting_force=Fighting_force} = RoleInfo,
	Fighting_force.
	
set_fighting_force_to_roleinfo(RoleInfo,Fighting_force) ->
	RoleInfo#gm_role_info{fighting_force=Fighting_force}.
	
get_guildtype_from_roleinfo(RoleInfo)->
	#gm_role_info{guildtype=Value} = RoleInfo,
	Value.
	
set_guildtype_to_roleinfo(RoleInfo,Value) ->
	RoleInfo#gm_role_info{guildtype=Value}.
	
get_honor_from_roleinfo(RoleInfo)->
	#gm_role_info{honor=Value} = RoleInfo,
	Value.
	
set_honor_to_roleinfo(RoleInfo,Value) ->
	RoleInfo#gm_role_info{honor=Value}.
	
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				发送给在不同节点上的人物信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
-record(othernode_role_info,{id,proc,mapid,lineid,name,class,level,gender,life,hpmax,mana,mpmax,node,pos,icon,cloth,arm,buffer,fightforce}).

make_roleinfo_for_othernode(RoleInfo)->
	#othernode_role_info{id = get_id_from_roleinfo(RoleInfo),
						lineid = get_lineid_from_gs_system_mapinfo(get_mapinfo_from_roleinfo(RoleInfo)),
						proc = list_to_atom(integer_to_list(get_id_from_roleinfo(RoleInfo))),
						mapid = get_mapid_from_gs_system_mapinfo(get_mapinfo_from_roleinfo(RoleInfo)),
						name = get_name_from_roleinfo(RoleInfo),
						gender = get_gender_from_roleinfo(RoleInfo),
						class = get_class_from_roleinfo(RoleInfo),
						level = get_level_from_roleinfo(RoleInfo),
						pos = get_pos_from_roleinfo(RoleInfo),
						life = get_life_from_roleinfo(RoleInfo),
						hpmax = get_hpmax_from_roleinfo(RoleInfo),
						mana = get_mana_from_roleinfo(RoleInfo),
						mpmax = get_mpmax_from_roleinfo(RoleInfo),
						node = get_node_from_roleinfo(RoleInfo),
						icon = get_icon_from_roleinfo(RoleInfo),
						cloth =get_cloth_from_roleinfo(RoleInfo),
						arm =get_arm_from_roleinfo(RoleInfo),
						buffer = get_buffer_from_roleinfo(RoleInfo),
						fightforce = get_fighting_force_from_roleinfo(RoleInfo)
						}.
						
get_id_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{id=ID} = OutRangeRoleInfo,
	ID.

get_lineid_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{lineid=Lineid} = OutRangeRoleInfo,
	Lineid.

get_proc_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{proc=Proc} = OutRangeRoleInfo,
	Proc.

get_mapid_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{mapid=Mapid} = OutRangeRoleInfo,
	Mapid.
	
get_fightforce_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{fightforce=FightForce} = OutRangeRoleInfo,
	FightForce.
		
get_gender_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{gender=Gender} = OutRangeRoleInfo,
	Gender.

get_icon_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{icon=Icon} = OutRangeRoleInfo,
	Icon.
	
get_name_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{name=Name} = OutRangeRoleInfo,
	Name.
	
get_class_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{class=Class} = OutRangeRoleInfo,
	Class.
	
get_level_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{level=Level} = OutRangeRoleInfo,
	Level.
	
get_pos_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{pos=Pos} = OutRangeRoleInfo,
	Pos.
	
get_life_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{life=Life} = OutRangeRoleInfo,
	Life.
	
get_hpmax_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{hpmax=Hpmax} = OutRangeRoleInfo,
	Hpmax.
	
get_mana_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{mana=Mana} = OutRangeRoleInfo,
	Mana.
	
get_mpmax_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{mpmax=Mpmax} = OutRangeRoleInfo,
	Mpmax.
	
get_node_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{node=Node} = OutRangeRoleInfo,
	Node.	

get_cloth_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{cloth=Cloth} = OutRangeRoleInfo,
	Cloth.	

get_arm_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{arm=Arm} = OutRangeRoleInfo,
	Arm.					

get_buffer_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{buffer=Buffer} = OutRangeRoleInfo,
	Buffer.
-record(template_itemproto,{setid,entry}).
-define(SMANAGER_PROC,'server_manager').
-define(SMANAGER_NODE,'server_manager@127.0.0.1').
-define(TIME_TO_SITDOWN,30000).		%%30s

-define(COMPANION_ADD_EXT,0.5).		%%

-define(COMPANION_ADD_POSITION_EXT,0.5).		%%

-define(ROLE_SITDOWN_RESTRICT_MIN_LEVEL,35).-record(role_level_sitdown_effect_db,{level,exp,soulpower,hppercent,mppercent,zhenqi}).

%%SKILL TYPE
-define(SKILL_TYPE_NOMAL,0).					%%普通攻击
-define(SKILL_TYPE_ACTIVE,1).					%%1:主动技能
-define(SKILL_TYPE_PASSIVE_ATTREXT,2).			%%2:属性类被动技能(学习后不用释放,直接加属性)
-define(SKILL_TYPE_PASSIVE_DEFENSE,3).			%%3:防御类被动技能(被攻击触发)
-define(SKILL_TYPE_PASSIVE_ATTACK,4).			%%4:释放类被动技能(攻击触发)
-define(SKILL_TYPE_ESPECIALLY_COLLECT,5).		%%5:特殊地采集技能
-define(SKILL_TYPE_SITDOWN,6).					%%6:打坐技能
-define(SKILL_TYPE_ATTACK_THRONE,7).			%%7:占领王座
-define(SKILL_TYPE_ACTIVE_WITHOUT_CHECK_SILENT,9).	%%无视沉默的主动技能(用在补血补篮技能中)

%%技能效果
-define(SKILL_NORMAL,0).						%%正常
-define(SKILL_MISS,1).							%%miss
-define(SKILL_CRITICAL,2).						%%暴击
-define(SKILL_RECOVER,3).						%%增益技能

%%技能目标
-define(SKILL_TARGET_TEAM,1).			%%组队
-define(SKILL_TARGET_SELF_ENEMY,2).		%%自己和敌人
-define(SKILL_TARGET_SELF,3).			%%自己
-define(SKILL_TARGET_ENEMY,4).			%%敌人
-define(SKILL_TARGET_SELF_DEBUFF,5).	%%对友方

%%
-define(SKILL_ROLE_STUDY,0).			%%人物可学

%%buff类型
-define(BUFF_CLASS_NORMAL,0).				%%普通buff
-define(BUFF_CLASS_RIDE,1).					%%坐骑buff
-define(BUFF_CLASS_AVATAR,2).				%%变身buff
-define(BUFF_CLASS_HPPACKAGE,3).			%%血瓶buff
-define(BUFF_CLASS_BATTLE_LAMSTER,4).		%%战场逃兵buff
-define(BUFF_CLASS_SITDOWN,5).				%%打坐/双修buff
-define(BUFF_CLASS_ITEM_AVATAR,6).			%%变身卡buff
-define(BUFF_CLASS_MPPACKAGE,7).			%%蓝屏buff

%%buff效果类型
-define(BUFF_FREEZING,1).						%%冰冻 %% 定身状态: 无法移动
-define(BUFF_SILENT,2).							%%沉默%% 沉默状态: 无法使用技能
-define(BUFF_COMA,3).							%%昏迷%% 昏迷状态: 无法移动和攻击
-define(BUFF_POISON,4).							%%中毒
-define(BUFF_RETARD,5).							%%减速
-define(BUFF_GOD,7).							%%无敌 %% 无敌状态: 无法移动; 无法被攻击
-define(BUFF_HATREDRATIO,8).					%%提高仇恨比率
-define(BUFF_EXPRATIO,9).						%%提高经验比率
-define(BUFF_PETEXPRATIO,10).					%%提高宠物经验比率
-define(BUFF_LAMSTER,11).						%%逃兵
%%buff取消事件
-define(BUFF_CANCEL_TYPE_DEAD,1).				%%死亡取消
-define(BUFF_CANCEL_TYPE_ATTACK,2).				%%攻击取消
-define(BUFF_CANCEL_TYPE_BEATTACK,3).			%%被攻击取消
%%槽定位
-define(MAX_PACKAGE_SLOT,180).	%%包裹最大槽位
-define(MAX_STORAGE_SLOT,240).	%%仓库最大槽位
-define(SLOT_BODY_INDEX,0).
-define(SLOT_BODY_ENDEX,16).
-define(SLOT_PET_BODY_INDEX,20).
-define(SLOT_PET_BODY_ENDEX,25).
-define(SLOT_PACKAGE_INDEX,1000).
-define(SLOT_PACKAGE_ENDEX,1999).
%%SLOT_PACKAGE_ENDEX 以上的槽位的物品将被加载入items_info

-define(SLOT_STORAGES_INDEX,2000).
-define(SLOT_STORAGES_ENDEX,2999).

-define(MAIL_SLOT,10000).

-define(TRADE_ROLE_SLOT,12).

-define(HEAD_SLOT,1).		%%头盔
-define(SHOULDER_SLOT,2).	%%护肩
-define(GLOVE_SLOT,3).		%%护手
-define(BELT_SLOT,4).		%%腰带
-define(SHOES_SLOT,5).		%%鞋
-define(CHEST_SLOT,6).		%%胸甲
-define(MAINHAND_SLOT,7). 	%%主手
-define(OFFHAND_SLOT,8).	%%副手
-define(LFINGER_SLOT,9).	%%左手戒指
-define(RFINGER_SLOT,10).	%%右手戒指
-define(LARMBAND_SLOT,11).	%%左手手镯
-define(RARMBAND_SLOT,12).	%%右手手镯
-define(NECK_SLOT,13).		%%项链
-define(FASHION_SLOT,14).	%%时装
-define(RIDE_SLOT,15).		%%坐骑
-define(MANTEAU_SLOT,16).	%%披风

-define(DISPLAY_SLOTS,[?CHEST_SLOT,?MAINHAND_SLOT,?FASHION_SLOT]).
-record(spa_option,{spa_id,instance_proto,looptime,duration,chopping,swimming,vip_exp_addition,vip_op_addition}).
-record(spa_exp,{level,exp,soulpower,chopping_self,chopping_be,swimming_self,swimming_be}).

-define(ADDPOWER_PER_MONSTER,1). %%杀死一个怪物后增加的灵魂力
-define(MONSTER_LEVEL_LIMIT,5).	 %%有效击杀怪物等级差
-define(MAX_SPIRITSPOWER,100).	%%最大灵魂力

-define(SPIRITSPOWER_STATE_NORMAL,0).%%普通状态	
-define(SPIRITSPOWER_STATE_BURNING,1).%%燃烧状态

-define(CONSUME_POWER_PER_SECOND,5).	%%燃烧状态下每秒钟消耗的灵魂力
-define(BURNING_DELAY_TIME_S,10).		%%燃烧延迟时间  相对客户端的延迟%%
%%define your string id 
%%

-define(STR_SERIES_KILL_THREE_HUNDREDS,1).		%%三百
-define(STR_SERIES_KILL_FOUR_HUNDREDS,2).		%%四百
-define(STR_SERIES_KILL_FIVE_HUNDREDS,3).		%%五百
-define(STR_SERIES_KILL_SIX_HUNDREDS,4).			%%六百
-define(STR_SERIES_KILL_SEVEN_HUNDREDS,5).		%%七百
-define(STR_SERIES_KILL_EIGHT_HUNDREDS,6).		%%八百
-define(STR_SERIES_KILL_NINE_HUNDREDS,7).		%%九百斩

-define(STR_GUILD_PROMOTION,8).				%%升职
-define(STR_GUILD_DEMOTION,9).				%%降职
-define(STR_GUILD_JOIN,10).					%%加入
-define(STR_GUILD_LEAVE,11).				%%离开
-define(STR_GUILD_LEADER,12).				%%帮主
-define(STR_GUILD_MASTER,13).				%%长老
-define(STR_GUILD_MEMBER,14).				%%帮众
-define(STR_GUILD_PREMEMBER,15).			%%帮闲
-define(STR_GUILD_FACILITY,16).				%%帮会
-define(STR_GUILD_FACILITY_TREASURE,17).	%%帮会
-define(STR_GUILD_FACILITY_SHOP,18).		%%帮会
-define(STR_GUILD_MAIL_TITLE,19).			%%帮会系统提醒
-define(STR_GUILD_MAIL_SIGN,20).			%%邮件署名
-define(STR_GUILD_MAIL_CONTEXT,21).			%%邮件正文	
-define(STR_GUILD_BEKICKED,22).				%%被逐出
-define(STR_GUILD_VICE_LEADER,23).			
-define(STR_GUILD_FACILITY_SMITH,24).

%%战场
-define(STR_YHZQ_MAIL_TITLE,30).			%%永恒之旗战场奖励发放
-define(STR_BATTLE_MAIL_SIGN,31).				%%邮件署名
-define(STR_YHZQ_MAIL_CONTEXT,32).			%%邮件正文
-define(STR_JSZD_MAIL_TITLE,35).			%%晶石争夺奖励邮件标题
-define(STR_JSZD_MAIL_CONTEXT,36).			%%晶石争夺奖励邮件正文

-define(STR_YHZQ_LAN_RED,33).      %%red
-define(STR_YHZQ_LAN_BLUE,34).     %%blue

%%摆摊
-define(STR_AUCTION_SELL_MAIL_TITLE,40).	%%摆摊物品售出邮件标题
-define(STR_AUCTION_SELL_MAIL_CONTEXT1,41).	%%摆摊物品售出正文第一段
-define(STR_AUCTION_SELL_MAIL_CONTEXT2,42).	%%摆摊物品售出正文第二段
-define(STR_AUCTION_SELL_MAIL_CONTEXT3,43).	%%摆摊物品售出正文第三段
-define(STR_AUCTION_OVERDUE_MAIL_TITLE,44).	%%摊位过期邮件标题
-define(STR_AUCTION_OVERDUE_MAIL_CONTEXT,45).%%摊位过期邮件正文
-define(STR_AUCTION_SELL_MAIL_RECEDE_TITLE,310).	%%物品下架邮件标题【小五】
-define(STR_AUCTION_SELL_MAIL_RECEDE_CONTEXT,311).	%%收到下架邮件正文【小五】
-define(STR_AUCTION_SELL_MAIL_GET_ITEM_TITLE,312).	%%收到物品邮件标题【小五】
-define(STR_AUCTION_SELL_MAIL_ITEM_CONTEXT,313).	%%收到物品邮件正文【小五】
-define(STR_AUCTION_DEAL_LOG,46).			%%购买记录

-define(STR_SILVER_10000,50).				%%金(单位10000游戏币)
-define(STR_SILVER_100,51).					%%银(单位100游戏币)
-define(STR_SILVER_1,52).					%%铜(单位1游戏币)
-define(STR_GOLD,53).						%%元宝(单位)
-define(STR_GIFT_GOLD,54).					%%礼券(单位)
-define(STR_YEAR,55).						%%年
-define(STR_MONTH,56).						%%月
-define(STR_DAY,57).						%%日
-define(STR_ONEDAY,58).						%%天
-define(STR_ONEHOUR,59).					%%小时
-define(STR_HOUR,60).						%%时
-define(STR_MINUTER,61).					%%分
-define(STR_SECOND,62).						%%秒	
-define(STR_SYSTEM,63).						%%系统

-define(STR_SELL_NAME,70).					%%摊位名字

-define(STR_MONEY,71).						%%钱币
-define(STR_BOUNDMONEY,72).					%%绑定钱币

%%宠物系统
-define(STR_SEND_RIDE_TITLE,80).			%%发送坐骑物品标题
-define(STR_SEND_RIDE_CONTEXT,81).			%%发送坐骑物品正文	

-define(STR_GREEN,82).					%%绿色
-define(STR_BLUE,83).					%%蓝色
-define(STR_PURPLE,84).					%%紫色
-define(STR_GOLDEND,85).				%%金色

-define(STR_PET_ORDER_1,86).						%%宠物阶数1阶
-define(STR_PET_ORDER_2,87).						%%宠物阶数2阶
-define(STR_PET_ORDER_3,88).						%%宠物阶数3阶
-define(STR_PET_ORDER_4,89).						%%宠物阶数4阶
-define(STR_PET_ORDER_5,90).						%%宠物阶数5阶			

%%坐骑补偿
-define(STR_SEND_RIDE_REWARD_TITLE,91).			%%发送坐骑物品标题
-define(STR_SEND_RIDE_REWARD_CONTEXT,92).			%%发送坐骑物品正文

%%帮会战
-define(STR_GUILD_BATTLE_INVITE_MAIL_TITLE,100).		%%帮会战邀请信标题
-define(STR_GUILD_BATTLE_INVITE_MAIL_CONTENT,101).		%%帮会战邀请信正文
-define(STR_GUILD_BATTLE_INVITE_MAIL_SIGN,102).			%%邮件署名
-define(STR_KING_FORMAT,103).
-define(STR_KING,104).
-define(STR_GENERAL,105).
-define(STR_SOLIDER,106).
-define(WOODEN_MAN_PART,107).							%%本次伤害~p，攻击强劲，气力十足！

%%帮会弹劾
-define(STR_GUILD_IMPEACH_FAILD_MAIL_TITLE,110).
-define(STR_GUILD_IMPEACH_FAILD_MAIL_CONTEXT,111).
-define(STR_GUILD_IMPEACH_SUCCESS_MAIL_TITLE,112).
-define(STR_GUILD_IMPEACH_SUCCESS_MAIL_CONTEXT,113).

%%帮会改名
-define(STR_GUILD_RENAME_MAIL_TITLE,114).
-define(STR_GUILD_RENAME_MAIL_CONTEXT,115).

%%国王战奖励
-define(STR_GUILDBATTLE_REWARD_MAIL_TITLE,128).	%%标题
-define(STR_GUILDBATTLE_REWARD_MAIL_CONTENT,129).	%%内容

%%装备升星返还
-define(STR_EQUIPMENT_RISEUP_RETURN_MAIL_TITLE,300).%%升星失败返还邮件标题
-define(STR_EQUIPMENT_RISEUP_RETURN_MAIL_CONTENT,301).	%%邮件正文

%%永恒之旗广播括号
-define(STR_LEFT_BRACKET,302). 						%%左
-define(STR_RIGHT_BRACKET,303). 					%%右

%%活跃度返还
-define(STR_ACTIVITY_VALUE_REWARD_TITLE,304).			%%邮件标题
-define(STR_ACTIVITY_VALUE_REWARD_CONTENT,305).			%%正文


%%国王战国王奖励
-define(STR_GUILDBATTLE_KING_REWARD_MAIL_TITLE,306).
-define(STR_GUILDBATTLE_KING_REWARD_MAIL_CONTENT,307).

%%群雄逐鹿奖励
-define(STR_TANGLE_BATTLE_MAIL_TITLE,308).
-define(STR_TANGLE_BATTLE_MAIL_CONTENT,309).

%% Author: adrian
%% Created: 2010-6-25
%% Description: TODO: Add description to string_table

-define(ACCEPT_QUEST_NPC_TOO_FARAWAY,"接任务失败，任务NPC太远!").
-define(ACCEPT_QUEST_HAVE_BEEN_ACCEPTED,"接任务失败，已经接此任务!").
-define(SUBMIT_QUEST_NPC_TOO_FARAWAY,"交任务失败，任务NPC太远!").
-define(SUBMIT_QUEST_NOT_ACCEPTED,"交任务失败，未接任务!").
-define(SUBMIT_QUEST_UNACCOMPLISHED,"交任务失败，未完成任务!").
-define(SUBMIT_QUEST_NO_CHOICEITEM,"交任务失败，未选择正确的可选奖励!").



%%系统消息定义
-record(system_chat,{id,type,scope,color,msg,color_replace}). 

-define(SYSTEM_CHAT_NORAML_KILL_ROLE,1).
-define(SYSTEM_CHAT_ENCHANMENTS,2).
-define(SYSTEM_CHAT_STONEMIX,3).
-define(SYSTEM_CHAT_BOSS_BORN,4).
-define(SYSTEM_CHAT_MONSTER_KILLED,5).
-define(SYSTEM_CHAT_TANGLE_BATTLE_ROLE_KILLED,6).
-define(SYSTEM_CHAT_TANGLE_BATTLE_MONSTER_KILLED,7).
-define(SYSTEM_CHAT_TANGLE_BATTLE_TOP_FIVE,8).
-define(SYSTEM_CHAT_LOOP_TOWER_MASTER,9).
-define(SYSTEM_CHAT_SERIES_KILL_300,10).
-define(SYSTEM_CHAT_SERIES_KILL_400,11).
-define(SYSTEM_CHAT_SERIES_KILL_500,12).
-define(SYSTEM_CHAT_SERIES_KILL_600,13).
-define(SYSTEM_CHAT_SERIES_KILL_700,14).
-define(SYSTEM_CHAT_SERIES_KILL_800,15).
-define(SYSTEM_CHAT_SERIES_KILL_900,16).
-define(SYSTEM_CHAT_VIP_1,17).
-define(SYSTEM_CHAT_VIP_2,18).
-define(SYSTEM_CHAT_VIP_3,19).
-define(SYSTEM_CHAT_VIP_LEVEL_1,20).
-define(SYSTEM_CHAT_VIP_LEVEL_2,21).
-define(SYSTEM_CHAT_VIP_LEVEL_3,22).
-define(SYSTEM_CHAT_SERVICE_SHUTDOWN_AFTER,23).
-define(SYSTEM_CHAT_CHEST_TREASURE,24).
-define(SYSTEM_CHAT_INSTANCE_XUESHAN,25).
-define(SYSTEM_CHAT_INSTANCE_YUHAI,26).
-define(SYSTEM_CHAT_INSTANCE_MOYANLING,27).
-define(SYSTEM_CHAT_INSTANCE_WANMOKU,28).
-define(SYSTEM_CHAT_INSTANCE_DUOLONG,29).
-define(SYSTEM_CHAT_YHZQ_ROLE_KILL,30).
-define(SYSTEM_CHAT_YHZQ_GOT_FLAG,31).
-define(SYSTEM_CHAT_YHZQ_CONTROL_FLAG,32).
-define(SYSTEM_CHAT_YHZQ_SOURCE_1000,33).
-define(SYSTEM_CHAT_YHZQ_SOURCE_1500,34).
-define(SYSTEM_CHAT_YHZQ_SOURCE_1800,35).
-define(SYSTEM_CHAT_FIRST_CHARGE,36).
-define(SYSTEM_CHAT_MALL_RESTRICT,37).
-define(SYSTEM_CHAT_GUILD_ROLE_KILLED,38).
-define(SYSTEM_CHAT_TREASURE_SPAWNS_LAST_SECTION,49).
-define(SYSTEM_CHAT_TREASURE_SPAWNS_PREPARE,50).
-define(SYSTEM_CHAT_TREASURE_SPAWNS_FIRST_SECTION,51).
-define(SYSTEM_CHAT_TREASURE_SPAWNS_END,52).
-define(SYSTEM_CHAT_TREASURE_SPAWNS_SECTION,53).
-define(SYSTEM_CHAT_TREASURE_SPAWNS_DETAIL,54).
-define(SYSTEM_CHAT_TREASURE_SPAWNS_GOT,55).
-define(SYSTEM_CHAT_ANSWER_TOP3,56).
-define(SYSTEM_CHAT_ANSWER_DETAIL,57).
-define(SYSTEM_CHAT_BOSS_TREASURE_1,58).
-define(SYSTEM_CHAT_BOSS_TREASURE_2,59).
-define(SYSTEM_CHAT_BOSS_TREASURE_3,60).
-define(SYSTEM_CHAT_ZULONG_TREASURE_BOSS_1,61).
-define(SYSTEM_CHAT_ZULONG_TREASURE_BOSS_2,62).
-define(SYSTEM_CHAT_ZULONG_TREASURE_BOSS_3,63).
-define(SYSTEM_CHAT_ZULONG_TREASURE_BOSS_4,64).
-define(SYSTEM_CHAT_ZULONG_TREASURE_BOSS_KILL,65).
-define(SYSTEM_CHAT_VIP_4,72).
-define(SYSTEM_CHAT_VIP_LEVEL_4,73).
-define(SYSTEM_CHAT_EQUIPMENT_EHCHANT,74).
-define(SYSTEM_CHAT_EQUIPMENT_RECAST,75).
-define(SYSTEM_CHAT_FLUSH_SALES_ITEM,79).
-define(SYSTEM_CHAT_QUALITY_REACH_INDEX,110).
-define(SYSTEM_CHAT_QUALITY_EDGE_31,120).
-define(SYSTEM_CHAT_QUALITY_EDGE_61,121).
-define(SYSTEM_CHAT_QUALITY_EDGE_91,122).
-define(SYSTEM_CHAT_QUALITY_EDGE_121,123).
-define(SYSTEM_CHAT_RANDOM_QUALITY,130).				%%pet quality random with 3
-define(SYSTEM_CHAT_PET_TALENT_POWER,140).
-define(SYSTEM_CHAT_PET_TALENT_HITRATE,141).
-define(SYSTEM_CHAT_PET_TALENT_CRITICALRATE,142).
-define(SYSTEM_CHAT_PET_TALENT_STAMINA,143).
-define(SYSTEM_CHAT_CHAT_EVOLUTION,150).

%%programe use
-define(SYSTEM_CHAT_DRAGON_FIGHT_START,1000).
-define(SYSTEM_CHAT_STAR_SPAWNS_PREPARE,1001).
-define(SYSTEM_CHAT_STAR_SPAWNS_FIRST_SECTION,1002).
-define(SYSTEM_CHAT_STAR_SPAWNS_SECTION,1003).
-define(SYSTEM_CHAT_STAR_SPAWNS_LAST_SECTION,1004).
-define(SYSTEM_CHAT_STAR_SPAWNS_END,1005).
-define(SYSTEM_CHAT_EQUIPMENT_UPGRADE,1006).
-define(SYSTEM_CHAT_TRAVEL_BOSS_BORN,1007).
-define(SYSTEM_CHAT_TRAVEL_NORAML_KILL_ROLE,1008).
-define(SYSTEM_CHAT_TRAVEL_MONSTER_KILLED,1009).
-define(SYSTEM_CHAT_GET_MALL_ITEM,1011).
-define(SYSTEM_CHAT_RIDE_SPAWNS_DETAIL,1020).
-define(SYSTEM_CHAT_RIDE_SPAWNS_PREPARE,1021).
-define(SYSTEM_CHAT_RIDE_SPAWNS_FIRST_SECTION,1022).
-define(SYSTEM_CHAT_RIDE_SPAWNS_SECTION,1023).
-define(SYSTEM_CHAT_RIDE_SPAWNS_LAST_SECTION,1024).
-define(SYSTEM_CHAT_RIDE_SPAWNS_END,1025).

-define(SYSTEM_CHAT_EVERQUEST_REFRESH,1090).
-define(SYSTEM_CHAT_TREASURE_TRANSPORT_REFRESH,1091).

-define(SYSTEM_CHAT_RANK_TYPE_1,1101).
-define(SYSTEM_CHAT_RANK_TYPE_2,1102).
-define(SYSTEM_CHAT_RANK_TYPE_3,1103).
-define(SYSTEM_CHAT_RANK_TYPE_4,1104).
-define(SYSTEM_CHAT_RANK_TYPE_5,1105).
-define(SYSTEM_CHAT_RANK_TYPE_6,1106).
-define(SYSTEM_CHAT_RANK_TYPE_7,1107).
-define(SYSTEM_CHAT_RANK_TYPE_8,1108).

-define(SYSTEM_CHAT_ITEM_IDENTIFY,1112).
-define(SYSTEM_CHAT_PET_SYNTHESIS,1113).

-define(SYSTEM_CHAT_ROLE_KILL_50,1120).
-define(SYSTEM_CHAT_ROLE_KILL_100,1121).
-define(SYSTEM_CHAT_GOT_OUT_PRISON,1122).
-define(SYSTEM_CHAT_PUTIN_PRISON,1123).

-define(SYSTEM_CHAT_COM_TREASURE_TRANSPORT,1125).
-define(SYSTEM_CHAT_ROB_TREASURE_TRANSPORT,1127).
-define(SYSTEM_CHAT_SERVER_TREASURE_TRANSPORT_START,1128).

-define(SYSTEM_CHAT_GUILDBATTLE_WINNER,1129).
-define(SYSTEM_CHAT_COUNTRY_GENERAL,1130).
-define(SYSTEM_CHAT_COUNTRY_SOLIDER,1131).
-define(SYSTEM_CHAT_KING_BLOCKTALK,1132).
-define(SYSTEM_CHAT_KING_REMIT,1133).
-define(SYSTEM_CHAT_KING_PUNISH,1134).

-define(SYSTEM_CHAT_JSZD_BATTLE_KILL_SHUIJING,1136).
-define(SYSTEM_CHAT_JSZD_BATTLE_GUILD_REWARD,1137).

-define(SYSTEM_CHAT_GUILD_BONFIRE_START,1139).

-define(SYSTEM_CHAT_MALL_9999,9999).





































%%宝箱物品抽中概率表
-record(treasure_chest_rate,{proto_count,rate_base}).
-record(treasure_chest_drop,{proto_level1_level2_class,drops}).
-record(treasure_chest_type,{type,protoid_list}).				%%天珠类型，对应的模板Id[绑定模板Id,非绑定模板Id]
-record(treasure_chest_times,{times,consume_gold_list}).		%%祈福次数，[对应天珠类型消耗的元宝数]	
-record(role_treasure_storage,{roleid,itemlist,max_item_id,ext}).	%%角色  物品模板id-record(treasure_transport,{level,rewardexp,reward_money}).

-record(role_treasure_transport_db,{roleid,questid,type,quality,bonus,recev_time,last_rob_time,rob_times}).

-record(treasure_transport_quality_bonus,{quality,bonus}).

-record(guild_treasure_transport_consume,{guildlevel,consume}).



-define(ONE_HOUR,60*60).											%%一小时

-define(SERVER_DURATION_TIME,60*30).							%%全服运镖持续时间
 
-define(ONE_HOUR_FOR_CHECK,60*59).								%%一小时比客户端时间少用于验证

-define(TREASURE_TRANSPORT_OVER,0).								%%没有运镖

-define(ROLE_ROB_MAX_TIMES,10).									%%每日最大劫镖次数

-define(TREASURE_TRANSPORT_CAR,[95,96,97,98,99]).				%%品质，用来广播

-define(BROADCAST_CAR_EDGE,4).									%%达到紫色广播

-define(NORMAL_TRANSPORT_BONUS,1).								%%普通运镖加成

-define(SERVER_TRANSPORT_BONUS,1).								%%全服运镖加成

-define(GUILD_TRANSPORT_BONUS,0.5).	 							%%帮会运镖加成-record(user_auth, {username,userid,lgtime,cm,flag,userip,type,sid,openid,openkey,appid,pf}).

�%%经脉配置
-record(venation_proto,{id,point_num,attr_addition}).

%%经脉穴位
-record(venation_point_proto,{id,venation,parent_point,attr_addition,soulpower,money,active_rate,needlevel}).

%%经脉穴位
%%-record(venation_point_proto,{id,venation,parent_point,attr_addition,soulpower,money,active_rate}).

%%经脉信息记录
-record(role_venation,{roleid,active_point,share_exp,ext}).

-record(share_exp,{total_share_exp,remain_share_time,last_time}).

%%经脉道具加� ��
-record(venation_item_rate,{num,rate}).

%%冲穴经验奖励
-record(venation_exp_proto,{level,exp,shareexp}).

%%人物经脉领悟精通信息
%%venation_info = {venationid,venation_bone}
-record(role_venation_advanced,{roleid,venation_info}). 

%%经脉领悟精通信息
-record(venation_advanced,{venationinfo,effect,success_rate,need_money,need_gold,useitem,protect_item}).  


-define(SHARE_EXP_TIME_PERDAY,24).		%%明天增加的共享经验数

-define(SHARE_EXP_RADIUS,6).			%%共享经验有效范围半径格数
-define(VENATION_ITEM_MAXNUM,10).		%%一次可使用的最大经脉道具数	
-define(VENATION_OPEN_LEVEL,35).		%%开始等级

-define(VENATION_NUM,8).				%%经脉条数


-define(VENATION_OPT_SUCCESS,1).

-define(VENATION_SUCCESS,5).			%%提升成功

-define(VENATION_MAX_NUM,10).			%%最大升星数

-define(NOT_USE_ITEM,0).				%%不用保护符

-define(USE_ITEM,1).					%%用保护符

-define(VENATION_OPT_FAILD,2).

%%-define(VENATION_TIME_S,10).			%%冲穴倒计时
-define(VENATION_TIME_S,0).			%%冲穴倒计时

-define(TYPE_GOLD,1).			%%用YB顿悟-define(ITEM_TYPE_VIP_CARD_MONTH,1).
-define(ITEM_TYPE_VIP_CARD_SEASON,2).
-define(ITEM_TYPE_VIP_CARD_HALFYEAR,3).
-define(ITEM_TYPE_VIP_CARD_WEEK,4).
-define(ITEM_TYPE_VIP_CARD_NEW_MONTH,5).
-define(ITEM_TYPE_VIP_CARD_NEW_SEASON,6).
-define(ITEM_TYPE_VIP_CARD_NEW_HALFYEAR,7).
-define(ITEM_TYPE_VIP_CARD_EXPERIENCE,8).
-define(ITEM_TYPE_VIP_CARD_3DAY,9).


-define(INFINITE,0).

-define(WELFARE_ACTIVITY_DATA,welfare_activity_data).
-define(FIRST_PAY,1).
-define(NEW_BIRD,2).
-define(TW_MEMBER,3).
-define(TW_NEW_BIRD,4).
-define(TW_FIRST_PAY,5).
-define(GOLD_EXCHANGE_ACTIVITY,6).
-define(TW_OTHER,7).
-define(GOLDEN_PLUME_AWARDS,8).
-define(CONSUME_RETRURN,9).
-define(UNFINISHED,0).
-define(FINISHED,1).
-define(OPEN,1).
-define(CLOSE,0).
-define(PACKAGE_FULL,0).
-define(NOGIFT,0).

-record(instance_quality_proto,{protoid,npclist,freetime,itemtype,gold,rate,addfac}).
-record(role_instance_quality, {roleid, info, ext, quality}).

%% 充值与消费
-record(recharge1, {datetime, uid, money, platform, vip_level}).
-record(consume, {billno, uid, datetime, bound_gold, platform_gold, vip_level, item, num, price, platform}).
-record(ps, {slot,proto,price,quality}).