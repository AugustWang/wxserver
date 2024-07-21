%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2010-10-6
%% Description: TODO: Add description to quest_170100007
-module(quest_170100007).
-export([com_script/1]).
%%
%% Include files
%%
com_script(_Quest)->
	case script_op:get_class() of
		1->
			SkillId = 713000001;
		2->
			SkillId = 712000001;
		3->
			SkillId = 711000001
	end,
	case script_op:skill_is_studied(SkillId) of
		false->
			[{{skill,SkillId},0}];
		true->
			[{{skill,SkillId},1}]
	end.
