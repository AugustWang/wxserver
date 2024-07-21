%-define(NOT_FINISHED,0).			%%未完成
%-define(CAN_REWARD,2).				%%可以领取
%-define(FINISHED,1).				%%已完成

%%@@wb20130409
-define(NOT_FINISHED,0).			%%未完成
-define(CAN_REWARD,1).				%%可以领取
-define(FINISHED,2).				%%已完成
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
-define(OPEN_SERVICE_ACTIVITIES_ETS,open_service_activities_ets).