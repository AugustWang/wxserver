-define(EASY,1).								%%关卡难度 容易
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

					