%%SKILL TYPE
-define(SKILL_TYPE_NOMAL,0).					%%普通攻击
-define(SKILL_TYPE_ACTIVE,1).					%%1:主动技能
-define(SKILL_TYPE_PASSIVE_ATTREXT,2).			%%2:属性类被动技能(学习后不用释放,直接加属性)
-define(SKILL_TYPE_PASSIVE_DEFENSE,3).			%%3:防御类被动技能(被攻击触发)
-define(SKILL_TYPE_PASSIVE_ATTACK,4).			%%4:释放类被动技能(攻击触发)
-define(SKILL_TYPE_ESPECIALLY_COLLECT,5).		%%5:特殊地采集技能
-define(SKILL_TYPE_SITDOWN,6).					%%6:打坐技能
-define(SKILL_TYPE_ATTACK_THRONE,7).			%%7:占领王座
-define(SKILL_TYPE_ACTIVE_WITHOUT_CHECK_SILENT,9).	%%无视沉默的主动技能(用在补血补篮技能中)

%%技能效果
-define(SKILL_NORMAL,0).						%%正常
-define(SKILL_MISS,1).							%%miss
-define(SKILL_CRITICAL,2).						%%暴击
-define(SKILL_RECOVER,3).						%%增益技能

%%技能目标
-define(SKILL_TARGET_TEAM,1).			%%组队
-define(SKILL_TARGET_SELF_ENEMY,2).		%%自己和敌人
-define(SKILL_TARGET_SELF,3).			%%自己
-define(SKILL_TARGET_ENEMY,4).			%%敌人
-define(SKILL_TARGET_SELF_DEBUFF,5).	%%对友方

%%
-define(SKILL_ROLE_STUDY,0).			%%人物可学

%%buff类型
-define(BUFF_CLASS_NORMAL,0).				%%普通buff
-define(BUFF_CLASS_RIDE,1).					%%坐骑buff
-define(BUFF_CLASS_AVATAR,2).				%%变身buff
-define(BUFF_CLASS_HPPACKAGE,3).			%%血瓶buff
-define(BUFF_CLASS_BATTLE_LAMSTER,4).		%%战场逃兵buff
-define(BUFF_CLASS_SITDOWN,5).				%%打坐/双修buff
-define(BUFF_CLASS_ITEM_AVATAR,6).			%%变身卡buff
-define(BUFF_CLASS_MPPACKAGE,7).			%%蓝屏buff

%%buff效果类型
-define(BUFF_FREEZING,1).						%%冰冻 %% 定身状态: 无法移动
-define(BUFF_SILENT,2).							%%沉默%% 沉默状态: 无法使用技能
-define(BUFF_COMA,3).							%%昏迷%% 昏迷状态: 无法移动和攻击
-define(BUFF_POISON,4).							%%中毒
-define(BUFF_RETARD,5).							%%减速
-define(BUFF_GOD,7).							%%无敌 %% 无敌状态: 无法移动; 无法被攻击
-define(BUFF_HATREDRATIO,8).					%%提高仇恨比率
-define(BUFF_EXPRATIO,9).						%%提高经验比率
-define(BUFF_PETEXPRATIO,10).					%%提高宠物经验比率
-define(BUFF_LAMSTER,11).						%%逃兵
%%buff取消事件
-define(BUFF_CANCEL_TYPE_DEAD,1).				%%死亡取消
-define(BUFF_CANCEL_TYPE_ATTACK,2).				%%攻击取消
-define(BUFF_CANCEL_TYPE_BEATTACK,3).			%%被攻击取消
