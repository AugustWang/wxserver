%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2010-10-22
%% Description: TODO: Add description to quest_200100015
-module(quest_200100015).
-export([on_com_script/1,com_script/1]).
%%
%% Include files
%%

%%
%% Exported Functions
%%


%%
%% API Functions
%%
com_script(_Quest)->
	Quest_level=script_op:get_level(),
	if 
		Quest_level>=8->
			[{{level},1}];
		true->
			[{{level},0}]
	end.	
on_com_script(_Quest)->
	case script_op:get_class() of
		1->
			SkillId = 510000001;
		2->
			SkillId = 520000001;
		3->
			SkillId = 530000001
	end,
	SkillLevel = 1,	
	script_op:learn_skill(SkillId ,SkillLevel),
	true.


%%
%% Local Functions
%%

