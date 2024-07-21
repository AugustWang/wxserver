%%抽奖规则
-record(lottery_droplist,{class_level_id,class,level,ruleids}).
-record(lottery_counts,{level,count}).
-record(role_lottery,{roleid,last_lottery,leftcount,status}). %%statue = open |closed
