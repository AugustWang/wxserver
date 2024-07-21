%%槽定位
-define(MAX_PACKAGE_SLOT,180).	%%包裹最大槽位
-define(MAX_STORAGE_SLOT,240).	%%仓库最大槽位
-define(SLOT_BODY_INDEX,0).
-define(SLOT_BODY_ENDEX,16).
-define(SLOT_PET_BODY_INDEX,20).
-define(SLOT_PET_BODY_ENDEX,25).
-define(SLOT_PACKAGE_INDEX,1000).
-define(SLOT_PACKAGE_ENDEX,1999).
%%SLOT_PACKAGE_ENDEX 以上的槽位的物品将被加载入items_info

-define(SLOT_STORAGES_INDEX,2000).
-define(SLOT_STORAGES_ENDEX,2999).

-define(MAIL_SLOT,10000).

-define(TRADE_ROLE_SLOT,12).

-define(HEAD_SLOT,1).		%%头盔
-define(SHOULDER_SLOT,2).	%%护肩
-define(GLOVE_SLOT,3).		%%护手
-define(BELT_SLOT,4).		%%腰带
-define(SHOES_SLOT,5).		%%鞋
-define(CHEST_SLOT,6).		%%胸甲
-define(MAINHAND_SLOT,7). 	%%主手
-define(OFFHAND_SLOT,8).	%%副手
-define(LFINGER_SLOT,9).	%%左手戒指
-define(RFINGER_SLOT,10).	%%右手戒指
-define(LARMBAND_SLOT,11).	%%左手手镯
-define(RARMBAND_SLOT,12).	%%右手手镯
-define(NECK_SLOT,13).		%%项链
-define(FASHION_SLOT,14).	%%时装
-define(RIDE_SLOT,15).		%%坐骑
-define(MANTEAU_SLOT,16).	%%披风

-define(DISPLAY_SLOTS,[?CHEST_SLOT,?MAINHAND_SLOT,?FASHION_SLOT]).