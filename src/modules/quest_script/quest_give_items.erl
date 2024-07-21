%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(quest_give_items).

-include("error_msg.hrl").

-export([on_acc_script/2]).

on_acc_script(_QuestId,TempalteList)->
	case package_op:can_added_to_package_template_list(TempalteList) of
		true->
			lists:foreach(fun({TemplateTmp,Count})-> role_op:auto_create_and_put(TemplateTmp,Count,got_acc_quest)end,TempalteList),
			true;
		false->
			{false,?ERROR_PACKEGE_FULL}
	end.
