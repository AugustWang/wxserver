
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
-define(A1_SUMMON_POS_TY_BY_PROTO,3).%%金银殿副本召唤位置自己定


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
