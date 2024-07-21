-record(mainline_proto,
				{chapter,			%%章节
				  stage,			%%关卡
				  pre_stage,		%%上一关
				  entry_condition,	%%开启条件
				  entry_times,		%%每天可进入次数
				  difficulty,		%%难度 
				  class,			%%职业
				  transportid,		%%副本传送id
				  monsterslist,		%%怪物id列表
				  type,				%%关卡类型
				  time_s,			%%挑战时间
				  killmonsterlist,	%%击杀怪物列表
				  protectnpclist,	%%保护NPC列表
				  defend_sections,	%%防守波数
				  first_award_money,%%首次奖励金币
				  first_award_exp,	%%首次奖励经验
				  first_award_items,%%首次奖励物品
				  common_award_money,%%日常普通奖励金币
				  common_award_exp,		%%日常普通奖励经验
				  common_award_items,%%日常普通奖励物品
				  level_factor,		%%评分等级系数
				  time_factor,		%%评分时间系数
				  designation,		%%称号
				  section_duration	%%怪物刷新间隔
				  }).

%%
%%award_state {difficulty,flag} 
%%timerecord {lasttimestamp,times}
%%				  			  
-record(role_mainline,{roleid,record_list}).

-record(mainline_defend_config,
					{
						chapter,		%%章节
				 		stage,			%%关卡
				 		difficulty,		%%难度 
				  		class,			%%职业
				  		section,		%%波数
				  		spawns
					}).