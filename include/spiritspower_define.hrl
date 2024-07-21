

-define(ADDPOWER_PER_MONSTER,1). %%杀死一个怪物后增加的灵魂力
-define(MONSTER_LEVEL_LIMIT,5).	 %%有效击杀怪物等级差
-define(MAX_SPIRITSPOWER,100).	%%最大灵魂力

-define(SPIRITSPOWER_STATE_NORMAL,0).%%普通状态	
-define(SPIRITSPOWER_STATE_BURNING,1).%%燃烧状态

-define(CONSUME_POWER_PER_SECOND,5).	%%燃烧状态下每秒钟消耗的灵魂力
-define(BURNING_DELAY_TIME_S,10).		%%燃烧延迟时间  相对客户端的延迟