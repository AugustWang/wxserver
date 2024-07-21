%% Author: SQ.Wang
%% Created: 2011-7-8
%% Description: TODO: Add description to active_board_def
%% modi by zhangting  20120625
-define(MAX_DAYS,8). %% old is 7 zhangting

%% add by zhangting, old value is 7
-define(MAX_DAYS_NEW,8).
-define(INIT_NORMAL_AWARD_DAY_LIST,[{8,0},{7,0},{6,0},{5,0},{4,0},{3,0},{2,0},{1,0}]).

-define(CONTINUOUS_FROMNAME,63).
-define(CONTINUOUS_NORMAL_TITLE,64).
-define(CONTINUOUS_VIP_TITLE,65).
-define(CONTINUOUS_NORMAL_CONTEXT,66).
-define(CONTINUOUS_VIP_CONTEXT,67).
-define(NEED_LEVEL,25). %% zhangting old value  is 25
-define(CONTINUOUS_LOGIN,1).
-define(DISCONTINUOUS_LOGIN,2).
-define(SAMEDAY_LOGIN,3).
-define(NORMAL,0).
-define(VIP,1).
-define(AWARD_OK,0).
-define(CONTINUOUS_1,1).
-define(CONTINUOUS_2,2).
-define(CONTINUOUS_3,3).
-define(CONTINUOUS_4,4).
-define(ONEDAY,86400).       %%60*60*24

%%收藏领取好礼 by zhangting
-define(NEED_FAVORITE_LEVEL,10).
%%元宝福利大放送%%
-define(ACTIVITY_TEST01_AWARDED,50).
-define(ACTIVITY_STATE_OVER,1).
-define(ACTIVITY_STATE_PROCESS,2).
-define(ACTIVITY_STATE_NOTSTART,3).

-define(FIRST_CHARGE_GIFT_CAN_RECEIVE,1).
-define(FIRST_CHARGE_GIFT_RECEIVED,2).
-define(FIRST_CHARGE_GIFT_CAN_NOT_RECEIVE,3).

-define(FIRST_CHARGE_GIFT_ITEM,24000063).

-define(CLIENT_REQ_INTEVAL_S,60).
