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