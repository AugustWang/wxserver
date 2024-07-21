%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2010-12-31
%% Description: TODO: Add description to quest_mall_item
-module(quest_mall_item).
-export([com_script/1]).
%%
%% Include files
%%

com_script(Quest)->
	QuestInfo = quest_db:get_info(Quest),
	[{Message,_Op,_ObjValue}] = quest_db:get_objectivemsg(QuestInfo),
	[{Message,0}].
%%
%% Exported Functions
%%


%%
%% API Functions
%%



%%
%% Local Functions
%%

