%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(quest_delete_buff).
-export([on_com_script/2]).

on_com_script(_QuestId,BuffInfo)->
	role_op:remove_buffer(BuffInfo),
	true.