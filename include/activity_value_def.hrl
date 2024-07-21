%%
%%模板表
%%com_condition = {{msg,value},op,targetvalue}
%%
-record(activity_value_proto,{id,type,maxtimes,time,com_condition,value,targetid}).

%%
%%奖励模板表
%%
-record(activity_value_reward,{value,reward}).

-record(role_activity_value,{roleid,state,value,reward}).