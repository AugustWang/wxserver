%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(quest_give_buff).
-export([on_acc_script/2]).

on_acc_script(_QuestId,BuffInfo)->
	role_op:add_buffers_by_self([BuffInfo]),
	true.