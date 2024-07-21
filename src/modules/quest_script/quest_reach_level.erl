%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2010-10-25
%% Description: TODO: Add description to quest_ collect_equip
-module(quest_reach_level).
-export([com_script/1]).
%%
%% Include files
%%

%%
%% Exported Functions
%%
com_script(QuestId)->
	Mylevel=script_op:get_level(),
	QuestInfo = quest_db:get_info(QuestId),
	[{{level},Op,ObjValue}] = quest_db:get_objectivemsg(QuestInfo),
	State = quest_op:get_quest_states_by_op(Op,ObjValue,Mylevel,0),
	[{{level},State}].
%%
%% API Functions
%%



%%
%% Local Functions
%%

