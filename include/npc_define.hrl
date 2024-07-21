
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				NPC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%动态npc存活时间
-define(DYNAMIC_NPC_LIFE_TIME,3600000).		%%60min


		

%%攻击移动间歇
-define(MOVE_TO_TARGET_DELAY_TIME,500).	
%%怪物死亡停留地图时间
-define(DEAD_LEAVE_TIME,1000).
%%警戒扫描间歇
-define(NPC_ALERT_TIME,2000).
%%移动间歇
-define(MOVE_DELAY_TIME,10000).	
%%默认攻击距离
-define(DEFAULT_ATTACK_RANGE,3).
%%喊话几率
-define(DEFAULT_SHOUT_RATE,100).
%%NPC功能key值
-define(NPC_FUNCTION_TRAD,1).					%%交易
-define(NPC_FUNCTION_TRANSPOT,2).				%%传送
-define(NPC_FUNCTION_QUEST,3).					%%任务
-define(NPC_FUNCTION_SKILL,4).					%%技能
-define(NPC_FUNCTION_GUILD,5).					%%公会
-define(NPC_FUNCTION_MAIL,6).					%%邮件
-define(NPC_FUNCTION_EQUIPMENT_ENCHANTMENT,7).	%%装备升星
-define(NPC_FUNCTION_EQUIPMENT_SOCK,8).			%%装备打孔，镶嵌
-define(NPC_FUNCTION_EQUIPMENT_STONEMIX,9).		%%宝石合成
-define(NPC_FUNCTION_STORAGE,10).				%%仓库
-define(NPC_FUNCTION_LOOP_TOWER,11).			%%轮回塔
-define(NPC_FUNCTION_BATTLE_WATCH,12).				%%战场查看
-define(NPC_FUNCTION_EVERQUEST,13).				%%循环任务
-define(NPC_FUNCTION_VIP,14).					%%VIP
-define(NPC_FUNCTION_PET_RESET,15).				%%pet_reset
-define(NPC_FUNCTION_PET_UP_GROWTH,16).			%%pet_upgrowth
-define(NPC_FUNCTION_PET_UP_STAMINAGROWTH,17).	%%pet_up_staminagrowth
-define(NPC_FUNCTION_EXCHANGE,18).				%%兑换
-define(NPC_FUNCTION_DRAGON_FIGHT,19).			%%暴龙
-define(NPC_FUNCTION_CHESS_SPIRIT,20).			%%棋魂
-define(NPC_FUNCTION_ITEM_IDENTIFY,21).			%%物品鉴定与合成
-define(NPC_FUNCTION_GUILD_TREASURE_TRANSPORT,22).			%%帮会运镖
-define(NPC_FUNCTION_GUILDBATTLE_APPLY,23).			%%帮会战报名
-define(NPC_FUNCTION_GUILD_IMPEACH,24).				%%帮会弹劾
-define(NPC_FUNCTION_LOOP_INSTANCE_JHBY,25).		%%极寒冰域
-define(NPC_FUNCTION_LOOP_INSTANCE_XYGJ,26).		%%雪域古迹
-define(NPC_FUNCTION_SMALL_TREE,33).				%%幼小的魔法圣诞树
-define(NPC_FUNCTION_FINAL_TREE,34).				%%华丽的魔法圣诞树
-define(NPC_FUNCTION_GUILDINSTANCE,36).				%%进入帮会副本




-define(CREATOR_LEVEL_BY_SYSTEM,0).			%%系统创建的NPC	等级参数
-define(CREATOR_BY_SYSTEM,0).				%%系统创建的NPC

