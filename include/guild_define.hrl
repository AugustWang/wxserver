%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%					帮会
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(GUILD_FACILITY,1).									%%帮会
-define(GUILD_FACILITY_TREASURE,2).							%%百宝箱   (原铁匠铺)
-define(GUILD_FACILITY_SHOP,3).								%%帮会商城 (原百宝箱)
-define(GUILD_FACILITY_SMITH,4).							%%铁匠铺

-define(GUILD_FACILITY_TIMER,1000).							%%公会扫描时间间隔:1s

-define(GUILD_RANK_CHECK_TIMER,5*60).						%% 5 min

-define(GUILD_JOIN_RESTICT_TIME,5*60*60).					%%5小时
-define(GUILD_DISBAND_WARNING_TIME,20).						%%连续7天上线人数不足 发送警告邮件
-define(GUILD_DISBAND_TIME,30).								%%连续15天上线人数不足 解散帮会

-define(GUILD_MIN_ONLINE_MEMBER,1).							%%最少上线人数							

%%加成字段
-define(GUILD_ADDITION_MAX_MEMBERNUM,1).					
-define(GUILD_ADDITION_MAX_MASTERNUM,2).
-define(GUILD_ADDITION_MAX_VICELEADERNUM,3).
-define(GUILD_ADDITION_SMITH_RATE,1).

%%职位
-define(GUILD_POSE_LEADER,1).								%%帮主
-define(GUILD_POSE_VICE_LEADER,10).							%%副帮主
-define(GUILD_POSE_MASTER,20).								%%长老
-define(GUILD_POSE_MEMBER,30).								%%帮众
-define(GUILD_POSE_PREMEMBER,40).							%%帮闲

%%帮会权限
-define(GUILD_AUTH_INVITE,1).								%%邀请
-define(GUILD_AUTH_LEAVE,2).								%%离开
-define(GUILD_AUTH_SETLEADER,3).							%%禅让
-define(GUILD_AUTH_PROMOTION,4).							%%升职
-define(GUILD_AUTH_DEMOTION,5).								%%降职
-define(GUILD_AUTH_KICKOUT,6).								%%开除
-define(GUILD_AUTH_ACCEDE_RULE,7).							%%设置招募条件
-define(GUILD_AUTH_SMITH_USE,8).							%%使用铁匠铺
-define(GUILD_AUTH_TREASURE_USE,9).							%%使用百宝阁
-define(GUILD_AUTH_CONTRIBUTION,10).						%%捐献
-define(GUILD_AUTH_QUEST,11).								%%帮会任务
-define(GUILD_AUTH_NOTICE_MODIFY,12).						%%修改公告
-define(GUILD_AUTH_MAIL_ALL,13).							%%群发邮件
-define(GUILD_AUTH_UPGRADE,14).								%%升级设施
-define(GUILD_AUTH_UPGRADE_SPEEDUP,15).						%%加速升级
-define(GUILD_AUTH_CHANNEL,16).								%%帮会频道
-define(GUILD_AUTH_CHECKAPPLY,17).							%%审核帮会申请
-define(GUILD_AUTH_PUBLISHQUEST,18).						%%发布帮会任务
-define(GUILD_AUTH_SETPRICE,19).							%%设置百宝阁物品价钱
-define(GUILD_AUTH_SHOP_USE,20).							%%使用帮会商城
-define(GUILD_AUTH_CHANGE_NICKNAME,21).						%%修改称号
-define(GUILD_AUTH_TREASURE_TRANSPORT,22).					%%开启帮会运镖
-define(GUILD_UPGRADE_MONSTER,23).							%%升级帮会神兽

%%限制
-define(GUILD_NOTICE_LENGTH,400).								%%帮会通知长度
-define(GUILD_RECRUITE_TIME,1000*1000).							%%帮会信息请求间隔限制:1s
-define(GUILD_NICKNAME_LENGTH,50).								%%称号长度
-define(GUILD_APPLYINFO_TIME,1000*1000).						%%帮会申请信息请求间隔限制:1s

%%退出提示
-define(GUILD_DESTROY_BEKICKED,1).								%%被踢
-define(GUILD_DESTROY_LEAVE,2).									%%离开
-define(GUILD_DESTROY,3).										%%帮会被解散

%%帮会日志类型
-define(GUILD_LOG_MEMBER_MANAGER,1).							%%人员管理
-define(GUILD_LOG_UPGRADE,2).									%%帮会升级
-define(GUILD_LOG_MODIFY_PRICES,3).								%%调价
-define(GUILD_LOG_CONTRIBUTION,4).								%%捐献
-define(GUILD_LOG_MALL,5).										%%购买记录
-define(GUILD_LOG_QUEST,6).										%%帮务
-define(GUILD_LOG_PACKAGE,7).                              %%帮会仓库日志

-define(GUILD_MIN_LEVEL_CREATE,38).								%%建立帮会的最小级别
-define(GUILD_MIN_LEVEL_JOIN,35).								%%加入帮会最小级别


%%
%%配置key
%%
-define(GUILD_SILVER_TO_CONTRIBUTION_FACTOR_KEY,1).				%%游戏币兑换帮贡的比例 1帮贡需要的游戏币数
-define(GUILD_GOLD_TO_CONTRIBUTION_FACTOR_KEY,2).				%%元宝兑换帮贡的比例	1元宝兑换的帮贡数
-define(GUILD_ITEM_TO_CONTRIBUTION_FACTOR_KEY,3).				%%物品兑换帮贡的比例	1利川木 兑换的帮贡数
-define(GUILD_TREASURE_RESTORE_RATE,4).							%%百宝阁卖出物品后 返还给帮会的佣金 比例 百分比
-define(GUILD_QUEST_DURATION,5).								%%帮会任务发布后 额外奖励的限制时间	秒


-define(GUILD_MAX_APPLY_NUM,100).								%%最大申请人数

-define(GUILD_CAN_APPLY,1).
-define(GUILD_ALREADY_APPLY,2).
-define(GUILD_MEMBER_FULL,3).
-define(GUILD_APPLY_FULL,4).

-define(GUILD_ADD_APPLYER,1).
-define(GUILD_DEL_APPLYER,2).

-define(GUILD_APPLY_ACCEPT,1).
-define(GUILD_APPLY_REJECT,2).

-define(GUILD_LOG_DEFAULT_NUM,100).		%%默认保存帮会日志条数

-define(GUILD_MASTER_CALL_TIME,20000).							%%20s的帮会召唤有效时间

-define(GUILD_TREASURE_MAX_LEVEL,20).			%%百宝阁最高等级
-define(GUILD_SHOP_MAX_LEVEL,20).				%%商城最高等级

-define(UPDATE_MEMBERINFO_TO_CLIENT_INTERVAL,1000).	%%更新帮会成员信息给客户端的时间间隔

-define(TWO_HOUR,60*60*2).						%%两小时

-define(REASON_TREASURE_TRANSPORT,1).			%%原因运镖求救


-define(DEFAULT_FACILITY_LEVEL,1).
-define(DEFAULT_FACILITY_UPDATESTATUS,0).
-define(DEFAULT_FACILITY_FINISHEDTIME,0).

-define(IMPEACH_TIME_S,24*60*60).	%%24h

-define(IMPEACH_SUCCESS,1).
-define(GUILD_LEADER_IS_KING,2).
-define(OTHER_IMPEACH,3).

-define(ALREADY_VOTE,1).
-define(NOT_VOTE,0).

-define(VOTE_MIN_LEVEL,40).							%%最低投票等级
-define(IMPEACH_LEADER_OFFLINE_TIME,7*24*60*60*1000000).		%%7天不在线才能弹劾

-define(IMPEACH_SUCCESS_CHECK(Total,Support),(3*Support) >= (2*Total)). %%赞成数 大于等于总数的2/3

-define(GUILD_MONEYLOG_TIME,2000*1000).							%%帮会捐钱日志信息请求间隔限制:2s


-define(VOTE_SUPPORT,1).	
-define(VOTE_OPPOSITE,0).


-define(BEST_GUILD_TYPE,1).
-define(NORMAL_GUILD_TYPE,0).


-define(CALL_GUILD_MONSTER_MAX_TIMES,5).  		%%一天内能召唤怪物的最大次数
-define(CALL_GUILD_MONSTER_CD,10800).  				%%召唤怪物的cd

-define(STATE_NOT_ACTIVITED,0).  		%%帮会神兽状态未出战
-define(STATE_ACTIVITED,1).  		%%帮会神兽状态出战

-define(GUILD_STORAGE_SIZE,30).%%帮会等级为一时帮会仓库大小
