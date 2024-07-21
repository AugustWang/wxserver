%% Author: zhanglei
%% Created: 2012-1-6

%%
%%internal msg 
%%
-define(INTERNAL_MSG_NOTIFY_VOTE,1).
-define(INTERNAL_MSG_VOTE,2).
-define(INTERNAL_MSG_NOTIFY_ENTRY,3).


%%
%%
%%
-define(INTERNAL_STATE_IDLE,0).	 		%%未投票
-define(INTERNAL_STATE_AGREE,1).		%%同意
-define(INTERNAL_STATE_DISAGREE,2).		%%不同意
-define(INTERNAL_STATE_DONOT_MATCH,3).	%%不符合条件


-define(VOTE_TIME_S,10).		%%投票持续时间


-define(LOOP_INSTANCE_LAYER_COMPLETE,1).			%%已通关
-define(LOOP_INSTANCE_LAYER_UNCOMPLETE,2).			%%未通关