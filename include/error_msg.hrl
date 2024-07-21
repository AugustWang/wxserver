%% Author: adrian
%% Created: 2010-6-25
%% Description: TODO: Add description to error_msg

%%creating role 
-define(ERR_CODE_ROLENAME_EXISTED,10001). %%用户名已存在
-define(ERR_CODE_ROLENAME_INVALID,10002). %%非法用户名
-define(ERR_CODE_CREATE_ROLE_INTERL,10003). %%创建失败
-define(ERR_CODE_CREATE_ROLE_REGISTER_DISABLE,10004). %%不允许创建新角色
-define(ERR_CODE_CREATE_ROLE_EXISTED,10005).		%%该账户下的角色已创建


-define(ERRNO_JOIN_MAP_ERROR_MAPID,10006).			%%当前地图无法进入
-define(ERRNO_JOIN_MAP_ERROR_UNKNOWN,10007).		%%无法登入服务器,请进入官网联系GM

%%PK
-define(ATTACK_ERROR_NOWEAPON, 10011).						%%没有武器
-define(ATTACK_ERROR_COOLTIME, 10012).						%%cd
-define(ATTACK_ERROR_MP, 10013).							%%Mp
-define(ATTACK_ERROR_SAFE_ZONE, 10014).						%%安全区
-define(ATTACK_ERROR_RANGE, 10015).							%%距离
-define(ATTACK_ERROR_ERROR_STATE, 10016).					%%cd
-define(ATTACK_ERROR_TARGET_GOD, 10017).					%%目标无敌	
-define(ATTACK_ERROR_SILENT, 10018).						%%沉默
-define(ATTACK_ERROR_COMA, 10019).							%%昏迷

%%帮会
-define(GUILD_ERRNO_UNKNOWN,10020).								%%未知
-define(GUILD_ERRNO_ALREADY_IN_GUILD,10022).					%%已经在公会
-define(GUILD_ERRNO_NOT_IN_GUILD,10023).						%%没有在公会
-define(GUILD_ERRNO_MONEY_NOT_ENOUGH,10008).					%%钱不够
-define(GUILD_ERRNO_ITEM_NOT_ENOUGH,10025).						%%缺少物品
-define(GUILD_ERRNO_CREATE_INVALIDNAME,10026).					%%名称错误
-define(GUILD_ERRNO_CREATE_REPEADNAME,10027).					%%名称重复
-define(GUILD_ERRNO_LESS_AUTH,10028).							%%权限不足 
-define(GUILD_ERRNO_GUILD_FULL,10029).							%%帮会已满
-define(GUILD_ERRNO_CANNOT_FIND_ROLE,10030).					%%角色不在线
-define(GUILD_ERRNO_HAS_BEEN_INVITED,10031).					%%已被邀请
-define(GUILD_ERRNO_GUILD_POST_FULL,10032).						%%职位人数上限
-define(GUILD_ERRNO_GUILD_UPGRADE_FULL,10033).					%%升级已达上限
-define(GUILD_ERRNO_GUILD_UPGRADING,10034).						%%正在升级中
-define(GUILD_ERRNO_GUILD_LEAVE_RESTRICT,10035).				%%距离上次离开帮会不足24小时
-define(GUILD_ERRNO_APPLYINFO_ALREADY_OP,10036).				%%已经被审核处理过
-define(GUILD_ERRNO_LESS_CONTRIBUTION,10037).					%%帮贡不足
-define(GUILD_ERRNO_LIMITNUM,10038).							%%到达限购数
-define(GUILD_ERRNO_APPLYNUM_FULL,10039).						%%申请人数已满
-define(GUILD_PACKAGE_LIMIT_BIND,1).      %%帮会仓库权限禁止
-define(GUILD_PACKAGE_LIMIT_NOBIND,0).%%帮会仓库权限不禁止

%%组队
-define(ERR_GROUP_UNKNOW,10040).								%%未知
-define(ERR_GROUP_NO_ERROR,10041).								%%组队已解散
-define(ERR_GROUP_IS_NOT_IN_YOUR_GROUP,10042).					%%不在你组
-define(ERR_GROUP_IS_FULL,10043).								%%组满
-define(ERR_GROUP_ALREADY_IN_GROUP,10044).						%%已经在组里
-define(ERR_GROUP_ALREADY_INVITE,10045).						%%已经邀请
-define(ERR_GROUP_YOU_ARENT_IN_A_GROUP,10046).					%%你尚未在组
-define(ERR_GROUP_YOU_ARE_NOT_LEADER,10047).					%%你不是队长
-define(ERR_GROUP_CANNOT_FIND_ROLE,10048).						%%找不到角色
-define(ERR_GROUP_UNRECRUITMENT_FULL,10049).					%%队伍人满,招募取消
-define(ERR_GROUP_UNRECRUITMENT_JOIN_INSTANCE,10050).					%%副本已开启,招募取消

%%通用
-define(ERROR_LESS_LEVEL,10021).		%%等级不足
-define(ERROR_LESS_MONEY,10024).		%%钱不够
-define(ERROR_MISS_ITEM,10025).			%%缺少物品
-define(ERROR_PACKEGE_FULL,10051).		%%包裹满
-define(ERROR_LESS_HONOR,10052).		%%缺少荣誉
-define(ERROR_LESS_GOLD,10071).         %%元宝不够
-define(ERROR_LESS_TICKET,10072).       %%礼券不够
-define(ERROR_LESS_INTEGRAL,10070).		%%积分不够
-define(ERROR_NOT_LEAVE_ATTACK,10077).			%%尚未脱离战斗
-define(ERROR_UNKNOWN,10003).				%%未知错误

%%买卖
-define(ERROR_TRAD_CANNOT_SELL,10061).	%%不可出售

%%商城
-define(ERROR_LIMIT_COUNT,10073).			%%限量物品已卖空
-define(ERROR_LIMIT_TIME,10074).			%%限时物品已超时
-define(ERROR_PRICE_PREPAIR,10075).			%%与服务器价格不匹配，请刷新页面
-define(ERROR_MALL_ITEM_RESTRICT,10078).	%%你超过购买个数限制
-define(ERROR_SALES_ITEM_SHELVES,10079).	%%优惠物品已下架

%%副本
-define(ERRNO_INSTANCE_DATELINE,10080).			%%非进入时间段
-define(ERRNO_INSTANCE_LESSMEMBER,10081).		%%人数不足
-define(ERRNO_INSTANCE_QUEST,10082).			%%没有相应任务
-define(ERRNO_INSTANCE_BUFF,10083).				%%缺少buff
-define(ERRNO_INSTANCE_TIMES,10084).			%%次数已满
-define(ERRNO_INSTANCE_NOTEAM,10085).			%%没有组队
-define(ERRNO_INSTANCE_TEAMLEADER,10086).		%%需要队长先进入副本
-define(ERRNO_INSTANCE_NOGUILD,10087). 			%%没有公会
-define(ERRNO_INSTANCE_MOREMEMBER,10088). 		%%人数已满
-define(ERRNO_INSTANCE_RESETING,10089). 		%%副本重置中,稍后再试
-define(ERRNO_INSTANCE_UNKNOWN,10090).			%%使用过多,请稍后再试
-define(ERRNO_INSTANCE_FINQUEST,10091).			%%没有完成相应任务
-define(ERRNO_INSTANCE_LEVELRESTRICT,10092).	%%当前等级不能进入该副本
-define(ERRNO_INSTANCE_EXSIT,10093).			%%当前队伍已有副本,不能再进入新副本


%% 邮件
-define(ERRNO_MAILBOX_FULL,10100). %%对方邮箱已满
-define(ERRNO_MAIL_INTERL, 10101). %%服务器内部错误
-define(ERRNO_MAIL_NO_MAIL,10102). %%此邮件已经不存在
-define(ERRNO_MAIL_NO_ROLE,10103). %%此角色不存在
-define(ERRNO_MAIL_NO_ITEM,10104). %%物品不存在
-define(ERRNO_MAIL_ITEMBOND,10105). %%物品已经绑定
-define(ERRNO_MAIL_NOTENOUGH_SILVER,10107). %%游戏币不够
-define(ERRNO_MAIL_SILVER_LEVEL_RESTRICT,10108). %%低于40级不可邮寄金币

%%棋魂
-define(ERRNO_CHESS_SPIRIT_UP_LEVEL_MAX,10110).			%%技能已达到最大级别,无法升级
-define(ERRNO_CHESS_SPIRIT_REWARD_SUCCESS,10111).		%%领取奖励成功

%%好友
-define(ERROR_FRIEND_OFFLINE,10201).			%%此用户不在线，不能加为好友
-define(ERROR_FRIEND_FULL,10202).				%%你的好友超过最高限制
-define(ERROR_FRIEND_EXIST,10203).				%%已经是你的好友
-define(ERROR_FRIEND_NOEXIST,10204).			%%此人不是你的好友，不能删除
-define(ERROR_FRIEND_MYSELF,10205).				%%不能加自己为好友
-define(ERROR_FRIEND_NO_SIGNATURE,10206).		%%好友无签名
-define(ERROR_BLACK_NOEXIST,10207).				%%此人不在黑名单里
-define(ERROR_ISBLACK,10208).					%%此人在黑名单中，不能加为好友
-define(ERROR_BLACK_FULL,10209).				%%黑名单数已超过最高限制


%%聊天
-define(ERRNO_NOT_ONLINE,10304).
-define(ERRNO_HAS_NOGROUP,10305).
-define(ERRNO_CHAT_COOLDOWN,10306).
-define(ERRNO_MAX_LOUDSPEAK,10307).                 %%喇叭使用排队人数到达上限
-define(ERRNO_HAS_NOBATTLE,10308).

%% npc 错误
-define(ERRNO_NPC_POSITION,10401).		%%不在可用范围内
-define(ERRNO_NPC_NOFUNCTION,10402).	%%无此功能
-define(ERRNO_NPC_EXCEPTION,10403).		%%未知错误

%%交易返回
-define(TRADE_ERROR_YOU_ARE_DEAD,10501).			%%你死了
-define(TRADE_ERROR_TARGET_ARE_DEAD,10502).			%%交易对象死亡
-define(TRADE_ERROR_IS_NOT_AOI,10503).				%%不在视野内
-define(TRADE_ERROR_NO_SUCH_ROLE,10504).			%%玩家未找到
-define(TRADE_ERROR_TRADING_NOW,10505).				%%正在交易中		
-define(TRADE_ERROR_EXCEPTION,10507).				%%系统错误

%%装备
-define(ERROR_EQUIPMENT_CANT_FENJIE,10598).			%%装备不可分解
-define(ERROR_EQUIPMENT_CANT_UPGRADE,10599).		%%装备不可升级
-define(ERROR_EQUIPMENT_CANT_SEAL,10600).			%%装备不可解封
-define(ERROR_EQUIPMENT_NOEXIST,10601).				%%装备不在包裹里
-define(ERROR_EQUIPMENT_RISEUP_NOEXIST,10602).		%%升星道具不在包裹里
-define(ERROR_EQUIPMENT_PROTECT_NOEXIST,10603).		%%升星保护道具不在包裹里
-define(ERROR_EQUIPMENT_RISEUP_NOT_MATCHED,10604).	%%升星道具不匹配
-define(ERROR_EQUIPMENT_MAX,10605).					%%星级已满，不能升星
-define(ERROR_SOCKETS_MAX,10606).					%%孔数达到最大值，不能打孔
-define(ERROR_EQUIPMENT_SOCKETS_NOEXIST,10607).		%%打孔道具不存在
-define(ERROR_EQUIPMENT_SOCKETS_NOT_MATCHED,10608).	%%打孔道具不匹配
-define(ERROR_SOCKETS_CANT_SOCK,10609).				%%该装备不能打孔
-define(ERROR_EQUIPMENT_INLAY_NOEXIST,10610).		%%镶嵌宝石不存在
-define(ERROR_EQUIPMENT_INLAY_TYPE_NOT_MATCHED,10611).		%%镶嵌宝石类型不匹配
-define(ERROR_EQUIPMENT_INLAY_LEVEL_NOT_MATCHED,10612).		%%镶嵌宝石等级不匹配
-define(ERROR_EQUIPMENT_CANT_INLAY,10613).					%%镶嵌孔不存在或者已有宝石
-define(ERROR_EQUIPMENT_REMOVE_NOEXIST,10614).				%%拆除宝石道具不存在
-define(ERROR_EQUIPMENT_REMOVE_PACKAGE_FULL,10615).			%%包裹满，不能拆除
-define(ERROR_EQUIPMENT_SOCKET_NOEXIST,10616).				%%孔不存在，不能拆除宝石
-define(ERROR_EQUIPMENT_STONE_NOEXIST,10617).				%%宝石不存在，不能拆除宝石
-define(ERROR_EQUIPMENT_STONE_TYPE_REPEAT,10618).			%%不能镶嵌同一类型宝石
-define(ERROR_EQUIPMENT_STONEMIX_FAILED,10619).				%%宝石合成失败
-define(ERROR_EQUIPMENT_STONEMIX_LESS_COUNT,10620).			%%宝石个数不够，不能合成
-define(ERROR_EQUIPMENT_UPGRADE_NOT_MATCHED,10621).			%%升阶道具不匹配
-define(ERROR_EQUIPMENT_UPGRADE_FAILED,10622).				%%升阶失败
-define(ERROR_EQUIPMENT_RECAST_NONE_ENCHANT,10623).			%%没有附魔不允许重铸
-define(ERROR_NOT_SAME_STONE,10624).						%%宝石类型不相同
-define(ERROR_HAVE_NOT_CONVERT_PROPERTY,10625).				%%没有可以转换的属性
-define(ERROR_EQUIPMENT_CONVERT_NONE_ENCHANT,10626).		%%没有附魔不允许转换
-define(ERROR_EQUIPMENT_MOVE_LEVEL,10627).					%%等级范围不匹配
-define(ERROR_EQUIPMENT_MOVE_INVENT,10628).					%%装备部位不匹配
-define(ERROR_EQUIPMENT_CANNOT_MOVE,10629).					%%装备不能转移

%%成就
-define(ERROR_ACHIEVE_OPENED,10630).				%%已经开启成就，不能再次开启
-define(ERROR_ACHIEVE_NOT_OPENED,10631).			%%成就没有开启
-define(ERROR_ACHIEVE_TARGET_NOEXSIT,10632).		%%达成条件不存在
-define(ERROR_ACHIEVE_TARGET_NOT_FINISHED,10633).	%%达成条件没完成

%%
-define(ERROR_LOOP_TOWER_PROP_NOEXIST,10640).		%%通行证道具不足
-define(ERROR_LOOP_TOWER_CONVEY_PROP_NOEXIST,10641).		%%传送道具不足
-define(ERROR_LOOP_TOWER_IS_LIMITED,10642).			%%超过当日次数限制
-define(ERROR_LOOP_TOWER_WRONG_LAYER,10643).			%%不能传送至该层
-define(ERROR_LOOP_TOWER_AGAIN_PROP_NOEXIST,10645).		%%轮回道具不足

%%
-define(ERROR_IS_NOT_VIP,10650).					%%您不是VIP
-define(ERROR_VIP_REWARDED_TODAY,10651).			%%您今天的奖励已经领取过了
-define(ERROR_NOT_VIP,10652).			%%您不是vip
-define(ERRNO_NO_VIP_FLYTIMES,10653).			%%vip小飞鞋剩余次数为0


%%宠物部分
-define(ERROR_PET_UP_RESET_NOEXIST,10660).			%%刷点道具不存在
-define(ERROR_PET_NOEXIST,10661).					%%宠物不存在
-define(ERROR_PET_UP_RESET_NEEDS_NOEXIST,10662).	%%道具不匹配
-define(ERROR_PET_NO_PACKAGE,10663).				%%宠物出战中不允许进行此操作
-define(ERROR_PET_NO_PET,10664).				%%该玩家没有宠物
-define(ERROR_PET_LEVEL_BIGER_THAN_MASTER,10665).%%宠物等级不可大于玩家等级

-define(ERROR_PET_TRAINING_ERROR,10700).					%%驯养失败
-define(ERROR_PET_TRAINING_NOT_ENOUGH_MONEY,10701). 		%%钱币或者道具不足
-define(ERROR_PET_SPEEDUP_TRAINING_ERROR,10706).			%%加速驯养失败


-define(ERROE_PET_QUALITY_UP_TO_TOP,10712).				%%宠物资质已经到达最大
-define(ERROR_PET_UPGRADE_QUALITT_UP_OK,10713).			%%宠物资质上限提升成功
-define(ERROR_PET_UPGRADE_QUALITT_UP_FAILED,10714).		%%宠物资质上限提升失败
-define(ERROR_PET_ADD_ATTR_BEYOND_REMAIN,10720).		%%所加属性点超过剩余点数
-define(ERROR_PET_ADD_ATTR_OK,10721).					%%玩家加点成功
-define(ERROR_PET_WASH_POINT_OK,10723).					%%洗点成功

-define(ERROR_PET_CAN_NOT_TAKE,10724).	                %%宠物不可携带
-define(ERROR_PED_EVOLUTION_FAILED,10725).              %%进化失败
-define(ERROR_PET_QUALITY_MAX,10726).					%%宠物已达最高代数
-define(ERROR_PET_NOT_ENOUGH_ITEM,10727).				%%道具不足
-define(ERROR_PET_NOT_ENOUGH_MONEY,10728).				%%钱币不足
-define(ERROR_PET_EVOLUTION_SUCCESS,10729).				%%提升成功

-define(ERROR_PET_START_EXPLORER_LEVEL_ERROR,10750).		%%宠物等级不足
-define(ERROR_PET_START_EXPLORER_STATE_ERROR,10751).		%%宠物状态不满足(不在idle状态)
-define(ERROR_PET_EXPLORER_NOT_ENOUGH_MONEY,10752).			%%金钱或者道具不足
-define(ERROR_PET_CAN_NOT_EXPLORE,10753).					%%宠物不能探险
-define(ERROR_PET_NOT_IN_TIME,10754).						%%探险地图未开启
-define(ERROR_PET_EXPLORE_TIMES_NOT_ENOUGH,10755).			%%探险次数不足
-define(ERROR_PET_EXPLORE_ATTR_NOT_ENOUGH,10756).			%%宠物属性点不足

-define(ERROR_PET_IS_EXPLORING,10757).					%%探险中无法进化



%%活动 |spa|
-define(ERROR_ACTIVITY_IS_JOINED,10760).				%%已经加入活动
-define(ERROR_ACTIVITY_STATE_ERR,10761).				%%活动状态错误
-define(ERROR_ACTIVITY_LEVEL_ERR,10762).				%%等级限制
-define(ERROR_ACTIVITY_INSTANCE_ERR,10763).				%%副本中无法使用
-define(ERROR_ACTIVITY_NOT_EXSIT,10764).				%%活动不存在
-define(ERROR_ACTIVITY_IS_FULL,10765).					%%人数满
-define(ERROR_ACTIVITY_COOLTIME_CHOPPING_ERR,10766).	%%搓澡未冷却
-define(ERROR_ACTIVITY_COOLTIME_SWIMMING_ERR,10767).	%%戏水未冷却
-define(ERROR_SPA_CAN_NOT_TOUCH_CHOPPING_ERR,10768).	%%不能对她搓澡了
-define(ERROR_SPA_CAN_NOT_TOUCH_SWIMMING_ERR,10769).	%%不能对她戏水了
-define(ERROR_SPA_TOUCH_LIMIT_ERR,10770).				%%次数限制

-define(ERROR_PET_GOT_LEVEL,10800).					%%等级不匹配
-define(ERROR_BATTLEPET_GOT_SLOT,10801).					%%无空闲宠物槽位
-define(ERROR_PET_NAME,10802).						%%宠物名非法
-define(ERROR_RIDEPET_GOT_SLOT,10803).					%%无空闲坐骑槽位

%%使用物品
-define(ERROR_ITEMUSE_QUEST_CANNOT,10810).			%%不可接受此任务
-define(ERROR_ITEMUSE_OVERDUE,10811).				%%此物品已过期
-define(ERROR_SOULPOWER_FULL,10812).				%%灵力已满,不能使用灵力丹
-define(ERROR_USED_IN_INSTANCE,10813).				%%副本中无法使用
-define(ERROR_USED_IN_MAPPOS,10814).				%%当前位置无法使用
-define(ERROR_SOULPOWER_NOT_ENOUGH,10815).				%%灵力不足
-define(ERROR_SOULPOWER_NO_NEEDLE,10816).				%%没有对应的绣花针
-define(ERROR_SOULPOWER_NO_BABY,10817).				%%没有对应的充气娃娃

%%使用宝箱的错误号
-define(ERROR_TREASURE_CHEST_NOITEM,10820).		%%没道具刷新失败
-define(ERROR_TREASURE_CHEST_OPERATE,10821).		%%错误的操作

%%答题
-define(ERROR_ANSWER_SIGN_EXIST,10823).					%%不能重复报名
-define(ERROR_ANSWER_SIGN_STATE_ERR,10824).				%%没有报名状态
-define(ERROR_ANSWER_SIGN_LEVEL_ERR,10825).				%%等级不符合要求
-define(ERROR_ANSWER_NO_ACTIVITY,10826).				%%没有此活动
-define(ERROR_ANSWER_SIGN_INSTANCE_ERR,10827).			%%不能在副本里进行此操作

%%摆摊
-define(ERROR_STALL_ERROR_ID,10830).				%%摊位已被撤下
-define(ERROR_STALL_RECEDE_NO_ITEM,10831).			%%物品已被购买
-define(ERROR_STALL_RECEDE_NO_STALL,10832).			%%摊位不存在
-define(ERROR_STALL_BUY_ERROR_SELF,10833).			%%不能买自己的物品
-define(ERROR_STALL_SHANGJIA_CHENGGONG,10835).		%%上架成功 				2月19日加【xiaowu】
-define(ERROR_STALL_TANWEIMAN,10834).				%%摊位已满 				3月6日加【xiaowu】
-define(ERROR_STALL_XIAJIA_CHENGGONG,10836).		%%下架成功				3月6日加【xiaowu】
-define(ERROR_STALL_GOUMAI_CHENGGONG,10837).		%%够买成功				3月6日加【xiaowu】

%%新手祝贺
-define(ERROR_BE_CONGRATULATIONS_IS_LIMITED,10840).		%%对方已收到过10次祝贺，不能再次被祝贺，你来晚了
-define(ERROR_CONGRATULATIONS_IS_ERROR,10841).			%%对方不在线或者已不能被祝贺
-define(ERROR_CONGRATULATIONS_IS_LIMITED,10842).		%%你今天已经祝贺过20名玩家，不能再祝贺其他玩家了

%%离线经验
-define(ERRNO_LESS_OFFLINE_HOURS,10843).				%%你没有足够可兑换小时数

-define(ERROR_PET_TOO_FULL,10850).					%%宠物快乐度已满
-define(ERROR_PET_FEED_ITEM_NOT_ENOUGN,10851).		%%宠物饲料道具不足
-define(ERROR_NO_PET_IN_BATTLE,10852).				%%没有出战宠物

-define(ERROR_PET_SKILL_SLOT_LOCKER_LIMITED,10853).		%%宠物技能锁次数已用完
-define(ERROR_PET_SKILL_SLOT_LOCK_ITEM_NOT_ENOUGN,10854).	%%宠物技能锁道具不足
-define(ERROR_PET_SKILL_SLOT_CANNOT_BELOCKED,10855).		%%该技能槽位不能锁

-define(ERROR_PET_LESS_LEVEL,10856).	%%宠物等级不足
-define(ERROR_PET_CANNOT_LEARN_THIS_SKILL,10857). %%宠物无法学习该技能

-define(ERROR_PET_LEARN_SKILL_LESS_SOULPOWER,10858). %%宠物无法学习该技能 灵力不足

-define(ERROR_PET_LEARN_SKILL_LESS_SLOT,10859). %%宠物无法学习该技能  没有空闲技能槽

-define(ERROR_PET_MASTER_LESS_LEVEL,10860).		%%主人的等级不足，宠物无法出战

-define(ERROR_PET_LEARN_SKILL_SPECIES_NOT_MATCH,10861).	%%该物种不能学习这个技能

-define(ERROR_PET_LEARN_SKILL_LESS_NEED_SKILL,10862).	%%不能直接学习这个技能

-define(ERROR_PET_LEARN_SKILL_LESS_ITEM,10863).			%%缺少物品 不能学习技能

-define(ERROR_PET_LEARN_SKILL_SAME_SKILL,10864).		%%已学习过同样的技能

-define(ERROR_PET_LEARN_SKILL_SAME_SKILL_LOCK,10865).		%%技能被锁定不能学习


%%攻击打断
-define(ERROR_CANCEL_OUT_RANGE,10901).				%%目标超出攻击范围
-define(ERROR_CANCEL_MOVE,10902).					%%移动打断
-define(ERROR_CANCEL_INTERRUPT,10903).				%%被打断	
-define(ERROR_CANCEL_DEAD,10904).					%%死亡打断	

%%新手卡
-define(ERROR_CARD_UNKNOWN,10910).					%%未知错误
-define(ERROR_CARD_HAVE_GIFT,10911).				%%你已经领取过
-define(ERROR_CARD_NUMBER,10912).					%%错误的新手卡
-define(ERROR_CARD_HAVE_BEEN_GIFT,10913).			%%该新手卡已被使用


%%永恒之旗
-define(ERROR_YHZQ_MEMBER_ALWAYS_IN_BATTLES,10950).		%%队员已经在战场
-define(ERROR_YHZQ_MEMBER_HAS_LAMSTER_BUFFER,10951).	%%队员身上有逃兵buffer
-define(ERROR_YHZQ_HAS_LAMSTER_BUFFER,10952).			%%本人身上有逃兵buffer
-define(ERROR_YHZQ_CANNOT_ATTACK,10953).				%%不能采集 棋子已在我方控制下
-define(ERROR_YHZQ_MEMBER_LEVEL_ERROR,10954).			%%队员等级不符合条件
-define(ERRNO_BATTLE_FULL,10955).						%%副本人数满

%%帮会二期
-define(GUILD_APPLY_SUCCESS,11010).				%%申请加入帮会成功
-define(GUILD_CONTRIBUTION_SUCCESS,11011).		%%捐献成功
-define(GUILD_UPGREAD_SUCCESS,11012).			%%帮会升级完成
-define(GUILD_GET_CONTRIBUTION_ERROR,11013).	%%获取帮贡失败
-define(GUILD_CLEAR_NICKNAME_SUCCESS,11014).	%%清除昵称成功
-define(GUILD_INVITE_ERROR_LESS_LEVEL,11015).	%%等级不足，无法接收帮会邀请
-define(GUILD_ERRNO_CANNOT_BIGGER_THEN_GUILD,11016).	%%不能超过帮会等级
-define(GUILD_PACKAGE_UPDATE,11111).	%%帮会仓库更新
-define(GUILD_PACKAGE_UPDATE_FENPEI,11112).%%帮会仓库分配物品后更新
-define(GUILID_PACLAGE_IDELITEM,0).%%帮会物品闲置

%%任务
-define(QUEST_ITEM_MUST_IN_PACKAGE,11020).		%%任务物品未在包裹中
-define(QUEST_TIMEOUT,11021).					%%任务过期

%%连续登录
-define(ERROR_REWARDED_TODAY,11030).            %%今天领过奖励
-define(ERROR_NOT_REACH_LEVEL,11031).            %%等级不够

%%收藏有礼错误信息
-define(FAVORITE_GIFT_AWARDED,11034).            %%礼物已经领过

%%邀请好友送礼  by zhangting
-define(ERROR_NO_MATCH_GIFTS,11035).      %%好友送礼没有匹配的礼物
-define(ERROR_HAD_REWARDED,11036).        %%好友送礼该礼物已领取，不能重复领取

%%首充礼包奖励
-define(GET_FIRST_CHARGE_GIFT_ERROR,11040).		%%领取失败





%%打坐未在视野
-define(SITDOWN_ERROR_NO_ROLE_INAOI,11101).

%%祈福仓库
-define(TREASURE_STORAGE_GET_ITEM_ERROR,11200).		%%领取物品失败 请稍候
%%祈福
-define(TREASURE_CHEST_GOLD_NOT_ENOUGH,11201).           			%%元宝不足
-define(TREASURE_CHEST_ITEM_NOT_ENOUGH,11202).						%%天珠不足
-define(TREASURE_CHEST_PACKET_NOT_ENOUGH,11203).  	%%祈福背包空间不足

%%活跃度
-define(ACTIVITY_VALUE_NOT_ENOUGH,11300).		%%活跃度不足
-define(ACTIVITY_VALUE_ITEM_NOT_EXIST,11301).		%%没有该物品
-define(ACTIVITY_VALUE_REWARD_SUCCESS,11302).		%%领取成功

%%修为精通
-define(VENATION_NOT_OPEN,11400).           %%修为没开启
-define(VENATION_NO_ITEM,11401).			%%没有提升符
-define(VENATION_NO_MONEY,11402).			%%没有钱
-define(VENATION_FAILED,11403).				%%提升失败

%%坐骑相关
-define(ERROR_IDENTIFY_NO_ITEM,11410).      %%坐骑鉴定
-define(ERROR_NOT_SAME_QULITY,11411).		%%坐骑合成

-define(ERRNO_ALREADY_IN_INSTANCE,11420).		%%已在副本中,无法传送
-define(ERRNO_ROLE_UNRECRUITMENT_CREATE,11421).		%%创建队伍,求组删除
-define(ERRNO_ROLE_UNRECRUITMENT_JOIN,11422).		%%加入队伍,求组删除
-define(ERROR_CANT_SYNTHESIS,11423).			%%国王坐骑不能合成


%%炼制相关
-define(ERROR_REFINE_OK,11425).		%%炼制成功
-define(ERROR_REFINE_FAILED,11426). %%炼制失败


%%福利面板活动
-define(ERROR_ACTIVITY_UPDATE_OK,11430).  %%活动更新成功
-define(ERROR_SERIAL_NUMBER_ERROR,11431).	%%激活码错误
-define(ERROR_USED_SERIAL_NUMBER,11432).  %%无效激活码
-define(ERROR_HAS_FINISHED,11433).	 		%%已经完成活动


%%背包仓库
-define(ERRNO_PACKAGE_EXPAND_FULL,11440).		%%背包已扩充满
-define(ERRNO_STORAGE_EXPAND_FULL,11441).		%%仓库已扩充满

%%变身
-define(ERRNO_CAN_NOT_DO_IN_AVATAR,11444).		%%变身中无法进行本次操作

%%运镖
-define(ERRNO_CAN_NOT_DO_IN_TREASURE_TRANSPORT,11445).		%%正在运镖,无法进行本次操作

%%Spa
-define(ERRNO_CAN_NOT_DO_IN_SPA,11446).		%%正在泡澡,无法进行本次操作

%%pvp
-define(ERRNO_IS_CLEARED_ALL_CRIME,11450).		%%罪恶值已经为0，无法清除
-define(ERRNO_CAN_NOT_DO_IN_PRISON,11451).		%%正在服刑,无法进行本次操作

-define(ERRNO_GUILD_TREASURE_TRANSPORT_ALREADY_START,11452).	%%帮会运镖已开启
-define(ERRNO_GUILD_TREASURE_TRANSPORT_TIME_LIMIT,11453).	%%帮会运镖次数已用完
-define(ERRNO_NO_RIGHT_TO_START_TREASURE_TRANSPORT,11454).	%%只有帮主才能开启帮会运镖

-define(ERRNO_MAINLINE_ENTRY_TIME_LIMIT,11500).	%%今天进入次数已满
-define(ERRNO_MAINLINE_ENTRY_IN_TRAVEL_MAP,11501). %%跨服地图中无法进行挑战
-define(ERRNO_ROLE_DEAD,10501).					%%死亡

-define(ERRNO_CAN_ONLY_USE_IN_PRISON,11505).            %%该物品只能在监狱中使用 

-define(ERRNO_SENSWORDS,11510).							%%含有敏感文字
-define(ERRNO_GUILDBATTLEAPPLY_TIME_ERROR,11511).		%%现在不是报名时间
-define(ERRNO_GUILDBATTLE_ALREADY_APPLY,11512).			%%帮会已报名成功
-define(ERRNO_GUILDBATTLE_DISQUALIFIED,11513).			%%没有报名资格
-define(ERRNO_GUILDBATTLE_APPLY,11514).					%%报名成功
-define(ERRNO_IN_GUILDBATTLE,11515).					%%帮会正在帮战中
-define(ERRNO_NO_RIGHT,11516).							%%没有权限		
-define(ERRNO_NO_TIMES_TODAY,11517).					%%今天次数已经用完
-define(ERRNO_ALREADY_GET_TODAY,11518).					%%今天已领取过
-define(ERRNO_COUNTRY_LEADER_LESS_TIME,11519).			%%上任未满一天 不能领取
-define(ERRNO_GUILD_BATTLE_READY_CANNOT_ATTACK,11520).	%%战场准备中，不能攻击
-define(ERRNO_GUILD_BATTLE_THRONE_READY_CANNOT_ATTACK,11521).	%%战场准备中，王座不能占领
-define(ERRNO_GUILD_LESS_MONEY,11522).						%%帮会资金不足
-define(ERRNO_NOT_SAME_GUILD,11523).						%%不在同一帮会
-define(ERRNO_SAME_ROLE,11524).								%%不能对自己这样
-define(ERRNO_TIME_NOT_ACHIEVE,11525).						%%领取时间未到

%%节日活动
-define(ERRNO_NO_FESTIVAL_ACTIVITY,11535).				%%没有节日活动
-define(ERRNO_FESTIVAL_EXPIRED,11536).				%%活动未开启
-define(ERROR_CHRISTMAS_TREE_FULL,11537).				%%圣诞树成长以满

%%晶石争夺
-define(ERRNO_JSZD_BAD_STATE,11540).				%%活动状态错误
-define(ERRNO_JSZD_GUILD_NOT_IN_TOP,11541).			%%你所在帮会没资格参加此战场

-define(ERRNO_ROLE_NOT_EXIST,10103).						%%用户不存在

-define(ERRON_GUILD_IMPEACH_LEADER_OFFLINE_TOO_SHORT,11560).	%%帮会离线时间不足一周，不能弹劾
-define(ERRON_ROLE_IN_IMPEACH_CANNOT_LEAVE_GUILD,11561).		%%正在参与弹劾的人 不能开除出帮

-define(ERRNO_GUILD_LESS_LEVEL,11570).						%%帮会等级不足
-define(ERRNO_ALREADY_UPGRADE,11571).						%%帮会神兽已经提升过
-define(GUILD_ERRNO_CALL_CD,11572).							%%帮会神兽CD中
-define(GUILD_ERRNO_CALL_NO_TIMES,11573).					%%剩余次数不足，不能召唤帮会神兽

%%组队多层副本
-define(ERRON_LOOP_INSTANCE_MEMBERS_LIMIT,12000).			%%队伍人太多
-define(ERRON_LOOP_INSTANCE_TIMES_LIMIT,12001).				%%次数已用完
-define(ERRON_LOOP_INSTANCE_INSTANCE_EXIST,12002).			%%上次副本还未结束,请稍后重试或者更换队伍
-define(ERRON_LOOP_INSTANCE_INSTANCE_IN_VOTE,12003).		%%投票尚未结束，请稍后重试
-define(ERRON_LOOP_INSTANCE_INSTANCE_MISSION_UNCOMPLETED,12004).		%%传送失败 击杀目标尚未完成
-define(ERRON_LOOP_INSTANCE_INSTANCE_TRANSPORT_ERROR,12005).		%%传送失败 
-define(ERRON_LOOP_INSTANCE_VOTE_FAILD,12006).						%%投票失败
%%战场
-define(ERRNO_BATTLE_NOT_START,12020).				%%战场未开启
-define(ERROR_NOT_JION_IN,12021).					%%没有参加过战场

-define(ERROR_LESS_FIGHTFORCE,12030).				%%战斗力不足
-define(MAX_QUALITY_ALREADY, 12070).				%% 怪物品质已达到上限
-define(MAX_QUALITY_SET_ALREADY, 12071).			%% 怪物品质已达到设定上限

%%飞剑错误信息返回
-define(WING_LEVEL_UP_SUCCESS,12213).%%飞剑升级成功
-define(WING_LEVEL_UP_FAILED,12214).%%飞剑升级失败
-define(WING_PHASE_UP_SUCCESS,12215).%%飞剑升阶成功
-define(WING_PHASE_UP_FAILED,12216).%%飞剑圣阶失败
-define(WING_PHASE_ITEM_NOT_ENOUGH,12217).%%升阶物品不足
-define(WING_INSTENFY_SUCCESS,12218).%%飞剑强化成功
-define(WING_INSTENFY_FAILED,12219).%%飞剑强化失败
-define(WING_QUALITY_SUCCESS,12220).%%飞剑提升品质成功
-define(WING_QUALITY_FAILED,12221).%%飞剑提升品质失败
-define(WING_INSTENFY_UP,12222).%%飞剑强化达到上限
-define(WING_THING_NOT_ENOUGH,12223).%%飞剑提升物品或者钱币不足