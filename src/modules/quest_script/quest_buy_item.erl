%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-1-27
%% Description: TODO: Add description to quest_buy_item
-module(quest_buy_item).
-include("error_msg.hrl").
-export([com_script/1,on_com_script/1]).
%%
%% Include files
%%
com_script(Quest)->
	QuestInfo = quest_db:get_info(Quest),
	lists:map(fun(Object)->
			{{obt_item,Item}=Message,Op,ObjValue} = Object,
			NowCount = script_op:get_item_count_onhands(Item),
		{Message,quest_op:get_quest_states_by_op(Op,ObjValue,NowCount,0)}
	end, quest_db:get_objectivemsg(QuestInfo)).

on_com_script(Quest)->
	QuestInfo = quest_db:get_info(Quest),
	AllObjects = quest_db:get_objectivemsg(QuestInfo),
	Res = lists:filter(fun(Object)->
			{{obt_item,Item},_,ObjValue} = Object,
			not script_op:has_item_in_package(Item,ObjValue)
		end,AllObjects),
	case Res of
		[]->
			lists:foreach(fun(Object)-> 
					{{obt_item,Item},_,ObjValue} = Object,			  
					script_op:destory_item(Item,ObjValue) 
			end, AllObjects),
			true;
		_->
			{false,?QUEST_ITEM_MUST_IN_PACKAGE}
	end.

%%
%% Exported Functions
%%


%%
%% API Functions
%%



%%
%% Local Functions
%%

