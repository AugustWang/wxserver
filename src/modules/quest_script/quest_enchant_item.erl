%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-3-27
%% Description: TODO: Add description to quest_enchant_item
-module(quest_enchant_item).

-export([com_script/1]).


com_script(QuestId)->
		QuestInfo = quest_db:get_info(QuestId),
	case lists:keyfind(enchant,1,quest_db:get_objectivemsg(QuestInfo)) of
		{_,Op,ObjValue}->
			EnchantNum= item_util:get_enchant_on_item_onhands(),
			State = quest_op:get_quest_states_by_op(Op,ObjValue,EnchantNum,0),
			[{enchant,State}];
		_->
			slogger:msg("error com_script QuestId ~p not a enchantments quest ~n",[QuestId]),
			[{enchant,0}]
	end.

			
