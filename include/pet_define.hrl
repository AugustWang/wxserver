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







