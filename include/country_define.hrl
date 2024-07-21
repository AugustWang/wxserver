%%
%%define for country 
%%
-define(POST_KING,1).	%%国王
-define(POST_GENERAL,2).%%将军
-define(POST_SOLIDER,3).%%护卫
-define(POST_COMMON,4).	%%平民

-define(POST_ICON_ID,[20,21,22]).		%%官员头顶图标id

-define(POST_STR,[?STR_KING,?STR_GENERAL,?STR_SOLIDER]).		%%官员对应字符串

-define(BLOCK_TALK_TIME_S,30*60).%%禁言时间  秒
-define(ADD_CRIME,100).			%%每次增加的罪恶值
-define(REDUCE_CRIME,100).		%%每次减少的罪恶值

-define(LEADER_PUNISH,1).		%%惩罚
-define(LEADER_REMIT,2).		%%赦免

-define(COUNTRY_FIRST,1).		%%国家编号  有可能会有多个国家
-define(TOTAL_COUNTRYS,1).		%%国家个数

-define(KING_ITEMS_USEFUL_TIME_S,7*24*60*60).		%%国王套装有效时间 秒

-define(LEADER_CAN_REWARD_TIME_S,24*60*60).			%%上任后1天可领取日常奖励
%%-define(LEADER_CAN_REWARD_TIME_S,60).			%%上任后1天可领取日常奖励