
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
