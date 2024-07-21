%% Author:SQ.Wang
%% Created: 2011-7-11
%% Description: TODO: Add description to active_board_def
%%-record(continuous_logging_gift,{day,normal_gift,vip_gift}).%%

-record(continuous_logging_gift,{day,reward}).
-record(role_continuous_logging_info,{roleid,info}).

%%元宝福利大放送
%%{activity_test01,1,1,[{{12,0},{12,30}},{{20,0},{20,30}}],2,200}.
-record(activity_test01,{id,enabled,limit_times,money_type,money_count}).
-record(activity_test01_role,{roleid,info}).

%%zhangting 收藏有礼
-record(role_favorite_gift_info,{roleid,awarded}).


%%é¦åç¤¼åé¢å
-record(role_first_charge_gift,{roleid,state,ext}).

%%每日首次登陆提醒
-record(everyday_show,{roleid,offlinetime}).

%%福利面板
-record(role_welfare_activity_info,{roleid_type,serialnumber}).
-record(welfare_activity_data,{type,isshow,starttime,endtime,gift,condition}).
-record(role_gold_exchange_info,{roleid,exchange_ticket}).
-record(background_welfare_data,{type,isshow,starttime,endtime}).
-record(consume_return_info,{roleid,consume_gold}).