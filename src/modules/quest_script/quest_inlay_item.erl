%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(quest_inlay_item).
-export([com_script/1]).

com_script(QuestId)->
	QuestInfo = quest_db:get_info(QuestId),
	case lists:keyfind(inlay,1,quest_db:get_objectivemsg(QuestInfo)) of
		{_,Op,ObjValue}->
			MaxInlayLevel = item_util:get_max_stone_level_on_item_onhands(),
			State = quest_op:get_quest_states_by_op(Op,ObjValue,MaxInlayLevel,0),
			[{inlay,State}];
		_->
			slogger:msg("error com_script QuestId ~p not a inlay quest ~n",[QuestId]),
			[{inlay,0}]
	end.