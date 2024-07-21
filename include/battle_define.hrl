-define(ZONEIDLE,0).			%%为占领
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
