%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-2-24
%% Description: TODO: Add description to quest_venation
-module(quest_venation).

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
	Venation = venation_op:get_total_active_points(),
	QuestInfo = quest_db:get_info(QuestId),
	[{{venation},Op,ObjValue}] = quest_db:get_objectivemsg(QuestInfo),
	State = quest_op:get_quest_states_by_op(Op,ObjValue,Venation,0),
	[{{venation},State}].

