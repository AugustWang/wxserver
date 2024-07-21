%%攻击人后邪恶清除时间:1min
-define(CRIME_BLACK_NAME_TIME,50).			%%60000
-define(CRIME_CLEAR_TIME,60*60).				%%1小时比客户端时间稍短，便于验证
%%PK模式
-define(PVP_MODEL_PEACE,0).					%%和平模式
-define(PVP_MODEL_PUNISHER,1).				%%惩恶模式
-define(PVP_MODEL_GUILD,2).					%%公会模式
-define(PVP_MODEL_TEAM,3).					%%组队模式
-define(PVP_MODEL_KILLALL,4).				%%全体模式
%%PK切换
%%-define(PVP_SWITCH_MODEL_TIME_S,3600).			%%6*60*60
-define(PVP_SWITCH_MODEL_TIME_S,3600).			%%1*60*60

-define(KILLED_NUM_REACH_50,50).			%%罪恶值达到50
-define(KILLED_NUM_REACH_100,100).			%%罪恶值达到100

-define(CLEAR_ROLE_BLACK_NAME,1).			%%取消黑名字	
-define(CLEAR_CRIME,2).						%%减少罪恶值

-define(KILL_ONE_ADD_CRIME,10).				%%杀一人长多少罪恶值

-define(CRIME_BLACK_NAME,-1).				%%罪恶值-1为黑名

-define(CLEAR_CRIME_PRE_TIME,10).			%%单位时间内减少罪恶值点数

-define(CRIME_OUT_PRISON_EDGE,0).			%%罪恶小于0可出监狱

-define(ROLE_CRIME_EDGR,100).				%%人物罪恶值上限为100
