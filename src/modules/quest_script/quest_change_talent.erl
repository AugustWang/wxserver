%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-9-19
%% Description: TODO: Add description to quest_change_talent
-module(quest_change_talent).

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
com_script(Quest)->
	QuestInfo = quest_db:get_info(Quest),
	[{Message,_Op,_ObjValue}] = quest_db:get_objectivemsg(QuestInfo),
	[{Message,0}].
