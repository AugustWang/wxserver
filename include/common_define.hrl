
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

