%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(quest_sock_item).
-export([com_script/1]).

com_script(QuestId)->
	QuestInfo = quest_db:get_info(QuestId),
	case lists:keyfind(sock,1,quest_db:get_objectivemsg(QuestInfo)) of
		{_,Op,ObjValue}->
			MaxSockNum = item_util:get_max_socketnum_on_item_onhands(),
			State = quest_op:get_quest_states_by_op(Op,ObjValue,MaxSockNum,0),
			[{sock,State}];
		_->
			slogger:msg("error com_script QuestId ~p not a sock quest ~n",[QuestId]),
			[{sock,0}]
	end.
				
