%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-3-27
%% Description: TODO: Add description to quest_body_enchantments_item
-module(quest_body_enchantments_item).

-export([com_script/1]).


com_script(QuestId)->
	QuestInfo = quest_db:get_info(QuestId),
	case quest_db:get_objectivemsg(QuestInfo) of
		[{{equipment_enchantments,ObjValue},Op,Count}]->
			EnchantmentsNum = item_util:get_enchantments_on_item_body(ObjValue),
			State = quest_op:get_quest_states_by_op(Op,Count,EnchantmentsNum,0),
			 [{{equipment_enchantments,ObjValue},State}];
		_->
			slogger:msg("error com_script QuestId ~p not a enchantments quest ~n",[QuestId]),
			[{enchantment,0}]
	end.

