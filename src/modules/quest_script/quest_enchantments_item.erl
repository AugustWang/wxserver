%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(quest_enchantments_item).
-export([com_script/1]).


com_script(QuestId)->
		QuestInfo = quest_db:get_info(QuestId),
	case lists:keyfind(enchantments,1,quest_db:get_objectivemsg(QuestInfo)) of
		{_,Op,ObjValue}->
			MaxEnchantments = item_util:get_max_enchantments_on_item_onhands(),
			State = quest_op:get_quest_states_by_op(Op,ObjValue,MaxEnchantments,0),
			[{enchantments,State}];
		_->
			slogger:msg("error com_script QuestId ~p not a enchantments quest ~n",[QuestId]),
			[{enchantments,0}]
	end.

			