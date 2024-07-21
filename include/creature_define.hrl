%%生物状态
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

-define(DEFAULT_MAX_DISTANCE,10000000).	%%查找最近时的默认距离