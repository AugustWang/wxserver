%%@spec activity define
-define(BUFFER_TIME_S,120).
-define(ACTIVITY_STATE_START,1).
-define(ACTIVITY_STATE_STOP,2).
-define(ACTIVITY_STATE_REWARD,3).
-define(ACTIVITY_STATE_INIT,4).
-define(ACTIVITY_STATE_SIGN,5).
-define(ACTIVITY_STATE_END,6).
-define(CANDIDATE_NODES_NUM,2).
-define(START_TYPE_DAY,1).
-define(START_TYPE_WEEK,2).
-define(CHECK_TIME,10000). %%check per 10s
%%
%%add new activity  please modify ACTIVITY_MAX_INDEX !!!!!!!
%%
-define(ANSWER_ACTIVITY,1).
-define(TEASURE_SPAWNS_ACTIVITY,2).
-define(TANGLE_BATTLE_ACTIVITY,3).
-define(YHZQ_BATTLE_ACTIVITY,4).
-define(DRAGON_FIGHT_ACTIVITY,5).
-define(STAR_SPAWNS_ACTIVITY,6).
-define(RIDE_SPAWNS_ACTIVITY,7).
-define(TREASURE_TRANSPORT_ACTIVITY,8).
-define(SPA_ACTIVITY,9).
-define(JSZD_BATTLE_ACTIVITY,10).
-define(GUILD_INSTANCE_ACTIVITY,11).
-define(ACTIVITY_MAX_INDEX,?GUILD_INSTANCE_ACTIVITY).  %% !!!!!!!!!!!!!!!!!

%%spa
-define(SPA_DEFAULT_ID,1).
-define(SPA_PASSIVE_COUNT,10).
-define(SPA_COOL_TIME,120000).
-define(SPA_ROLE_STATE_JOIN,1).
-define(SPA_ROLE_STATE_LEAVE,0).
-define(SPA_TOUCH_TYPE_CHOPPING,1).
-define(SPA_TOUCH_TYPE_SWIMMING,2).
%%treasure_spawns
-define(TREASURE_SPAWNS_DEFAULT_LINE,1).
-define(TREASURE_SPAWNS_TYPE_CHEST,1).		%%treasure chest
-define(TREASURE_SPAWNS_TYPE_STAR,2).		%%treasure star
-define(TREASURE_SPAWNS_TYPE_RIDE,3).		%%treasure ride

-define(ACTIVITY_FORECAST_TIME_S,5*60). 	%%5min

%%
-define(TYPE_CHRISTMAS_ACTIVITY,1).