
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
