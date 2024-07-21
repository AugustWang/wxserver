
%%有过期时间的物品
-define(ITEM_NONE_OVERDUE_LEFTTIME,-1).		%%永不过期的物品的时间定义
%%过期类型 
-define(ITEM_OVERDUE_TYPE_NONE,0).			%%永不过期
-define(ITEM_OVERDUE_TYPE_OBTAIN,1).		%%获取后激活过期
-define(ITEM_OVERDUE_TYPE_EQUIP,2).			%%装备后激活过期

%%物品类型 0消耗品，1武器2副手3头盔4护肩5胸甲6腰带7护手8鞋子9项链10手镯11戒指12披风13勋章14时装15宝石16包裹17任务18帮会加速
-define(ITEM_TYPE_CONSUMABLE,0).
%%可修理的:1-11,24
-define(ITEM_TYPE_MAINHAND,1).
-define(ITEM_TYPE_OFFHAND,2).
-define(ITEM_TYPE_HEAD,3).
-define(ITEM_TYPE_SHOULDER,4).
-define(ITEM_TYPE_CHEST,5).
-define(ITEM_TYPE_BELT,6).
-define(ITEM_TYPE_GLOVE,7).
-define(ITEM_TYPE_SHOES,8).
-define(ITEM_TYPE_NECK,9).
-define(ITEM_TYPE_ARMBAND,10).
-define(ITEM_TYPE_FINGER,11).
-define(ITEM_TYPE_SHIELD,24).							%%盾
-define(ITEM_TYPE_MANTEAU,12).
-define(ITEM_TYPE_AMULET,13).
-define(ITEM_TYPE_FASHION,14).							%%时装
-define(ITEM_TYPE_RIDE,39).								%%坐骑

-define(ITEM_TYPE_GEMSTONE,15).
-define(ITEM_TYPE_PACKAGE,16).
-define(ITEM_TYPE_QUEST,17).
-define(ITEM_TYPE_GUILD_SPEEDUP,18).
-define(ITEM_TYPE_FLY_SHOES,25).						%%飞鞋
-define(ITEM_TYPE_PET_RENAME,26).						%%宠物改名道具
-define(ITEM_TYPE_UP_GROWTH,28).						%%练骨
-define(ITEM_TYPE_UP_STAMINA,29).						%%易筋
-define(ITEM_TYPE_UP_GROWTH_PROTECT,31).				%%练骨保护符
-define(ITEM_TYPE_UP_STAMINA_PROTECT,32).				%%易筋保护符
-define(ITEM_TYPE_PET_UP_EXP,34).						%%宠物经验丹
-define(ITEM_TYPE_TREASURE_CHEST,35).					%%天珠
-define(ITEM_TYPE_TARGET_USE,36).						%%使用需要目标的道具
-define(ITEM_TYPE_RUBBISH,37).							%%垃圾
-define(ITEM_TYPE_PET_UP_RIDE,38).						%%坐骑升星

-define(ITEM_TYPE_RESAWN,40).							%%复活卷
-define(ITEM_TYPE_UPGRADE,42).							%%装备升阶石
-define(ITEM_TYPE_GIFT_PACKAGE,43).						%%礼包
-define(ITEM_TYPE_VENATION,44).							%%经脉道具物品类型
-define(ITEM_TYPE_ITEM_IDENTIFY,48).					%%可鉴定物品
%-define(ITEM_TYPE_SKILL_BOOK,49).						%%技能书
-define(ITEM_TYPE_SKILL_BOOK,130).						%%技能书
														%%50资质上限提升道具
-define(ITEM_TYPE_FEED_PET,51).							%%宠物饲料
-define(ITEM_TYPE_PET_SKILL_SOLT_LOCK,52).				%%宠物技能锁
%%
%%53宠物进化石 54宠物宝石
%%
-define(ITEM_TYPE_PET_HEAD,55).							%%宠物头盔
-define(ITEM_TYPE_PET_NECK,56).							%%宠物项链
-define(ITEM_TYPE_PET_GIFT,57).							%%宠物挂件
-define(ITEM_TYPE_PET_BELT,58).							%%宠物腰带
-define(ITEM_TYPE_PET_SHOES,59).						%%宠物足链

-define(ITEM_TYPE_SPA_SOAP,77).							%%搓澡肥皂
-define(ITEM_TYPE_TREASURE_TRANSPORT_FRESH,78).			%%刷镖令


%%
%%60天赋符 61洗点水 
%%65白资质符 66绿资质符 67蓝资质符 68紫资质符 69金资质符 
%%70白资质保护符 71绿资质保护符 72蓝资质保护符 73紫资质保护符 74金资质保护符  75宠物技能锁 79加血药品 80加蓝药品
%%

-define(ITEM_TYPE_PET_EXPLORE_SPEEDUP,81).	%%宠物加速探险
-define(ITEM_TYPE_PET_LUCKY_MEDAL,82).		%%宠物探险 幸运奖章

-define(ITEM_TYPE_GUILD_RENAME,86).			%%帮会改名卡
-define(ITEM_TYPE_ROLE_RENAME,87).			%%人物改名卡

-define(ITEM_TYPE_GUILD_IMPEACH,88).		%%帮会弹劾道具

%%节日活动
-define(ITEM_TYPE_CHRISTMAS_BALL,90).		%%圣诞彩球
-define(ITEM_TYPE_CHRISTMAS_SOCKS,91).		%%圣诞袜子


%%
%%装备相关
%%
-define(ITEM_TYPE_EQUIP_JIEFENG_CHUJI,100).				%%初级解封材料
-define(ITEM_TYPE_EQUIP_JIEFENG_ZHONGJI,101).				%%中级解封材料
-define(ITEM_TYPE_EQUIP_JIEFENG_GAOJI,102).				%%高级解封材料
-define(ITEM_TYPE_EQUIP_JIEFENG_TEJI,103).				%%特级解封材料
-define(ITEM_TYPE_EQUIP_SOCK_CHUJI,105).				%%初级打孔石
-define(ITEM_TYPE_EQUIP_SOCK_ZHONGJI,106).				%%中级打孔石
-define(ITEM_TYPE_EQUIP_SOCK_GAOJI,107).				%%高级打孔石

-define(ITEM_TYPE_EQUIP_SEAL,108).						%%可解封的装备

%%
%%玩家可装备类型
-define(PLAYER_ITEM_TYPES,[?ITEM_TYPE_MAINHAND,?ITEM_TYPE_OFFHAND,?ITEM_TYPE_HEAD,?ITEM_TYPE_SHOULDER,
							?ITEM_TYPE_CHEST,?ITEM_TYPE_BELT,?ITEM_TYPE_GLOVE,?ITEM_TYPE_SHOES,?ITEM_TYPE_NECK,
							?ITEM_TYPE_ARMBAND,?ITEM_TYPE_FINGER,?ITEM_TYPE_SHIELD,?ITEM_TYPE_MANTEAU,?ITEM_TYPE_AMULET,
							?ITEM_TYPE_FASHION,?ITEM_TYPE_RIDE]).
				
%%宠物可装备类型
-define(PET_ITEM_TYPES,[?ITEM_TYPE_PET_HEAD,?ITEM_TYPE_PET_NECK,
					?ITEM_TYPE_PET_GIFT,?ITEM_TYPE_PET_BELT,?ITEM_TYPE_PET_SHOES]).

%%物品绑定
-define(ITEM_BIND_TYPE_NEVER,0).		%%永不绑定
-define(ITEM_BIND_TYPE_PICK,1).			%%装备绑定
-define(ITEM_BIND_TYPE_OBTAIN,2).		%%获取绑定
-define(ITEM_BIND_TYPE_USE,3).		%%使用绑定


%%物品摧毁提示
-define(ITEM_DESTROY_NOTICE_NONE,0).		%%无提示:整理消失或堆叠消失
-define(ITEM_DESTROY_NOTICE_OVERDUE,1).		%%过期
-define(ITEM_DESTROY_NOTICE_CONSUMEUP,2).	%%消耗
-define(ITEM_DESTROY_NOTICE_DESTROY,3).		%%摧毁
-define(ITEM_DESTROY_NOTICE_STALL,4).		%%上摊位
-define(ITEM_DESTROY_NOTICE_TRADROLE,5).	%%交易
-define(ITEM_DESTROY_NOTICE_SENDMAIL,6).	%%邮件发送

-define(FASHION_DEACTIVE_OVERDUE_ENCHANMENTS,8).		%%8星后取消过期




