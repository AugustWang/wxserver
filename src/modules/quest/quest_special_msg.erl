%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(quest_special_msg).

-compile(export_all).

-include("common_define.hrl").

proc_specail_msg({Msg,Value})->
	quest_op:update(Msg,Value).

%%specail msg define!!!!
dragon_fight_end()->
	{dragon_fight_end,1}.