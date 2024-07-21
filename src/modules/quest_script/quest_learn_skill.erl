%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-2-17
%% Description: TODO: Add description to quest_learn_skill
-module(quest_learn_skill).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([com_script/1]).

%%
%% API Functions
%%
com_script(QuestId)->
	QuestInfo = quest_db:get_info(QuestId),
	[{{_,SkillId}=Message,Op,ObjValue}] = quest_db:get_objectivemsg(QuestInfo),
	{_,_,SkillList} = get(skill_info),
	case lists:keyfind(SkillId,1,SkillList) of
		false->
			[{Message,0}];
		{_,SkillLevel,_}->
			State = quest_op:get_quest_states_by_op(Op,ObjValue,SkillLevel,0),
			[{Message,State}]
	end.
	


%%
%% Local Functions
%%

