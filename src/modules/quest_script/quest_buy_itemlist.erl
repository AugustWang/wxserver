%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-2-14
%% Description: TODO: Add description to quest_buy_itemlist
-module(quest_buy_itemlist).

-include("error_msg.hrl").
-export([com_script/1,on_com_script/1]).
%%
%% Include files
%%
com_script(Quest)->
	QuestInfo = quest_db:get_info(Quest),
	lists:map(fun(Object)->
			{{obt_item,ItemList} = Message,Op,ObjValue} = Object,
			NowCount = lists:foldl(fun(ItemTemplateId,Acc)->
										Acc + script_op:get_item_count_onhands(ItemTemplateId)  
									end, 0, ItemList),
			%%io:format("Quest ~p count ~p ~n",[Quest,NowCount]),
			{Message,quest_op:get_quest_states_by_op(Op,ObjValue,NowCount,0)}
		end, quest_db:get_objectivemsg(QuestInfo)).

on_com_script(Quest)->
	QuestInfo = quest_db:get_info(Quest),
	AllObjects = quest_db:get_objectivemsg(QuestInfo),
	IsHaveItem = lists:foldl(fun(Object,Acc)->
								{{_,[BoundItemId,ItemId]},_,ObjValue} = Object,
								case quest_destroy_items:check_item_has_count(BoundItemId,ObjValue) of
									{true,_}->
										script_op:destory_item(BoundItemId,ObjValue),
										[true|Acc];
									{false,{Num,LeftNum}}->
										case quest_destroy_items:check_item_has_count(ItemId,LeftNum) of
											{true,_}->
												script_op:destory_item(BoundItemId,Num),
												script_op:destory_item(ItemId,LeftNum),
												[true|Acc];
											_->
												[false|Acc]
										end
								end
							end,[],AllObjects),
	case lists:member(false,IsHaveItem) of
		true->
			{false,?QUEST_ITEM_MUST_IN_PACKAGE};
		_->
			true
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
