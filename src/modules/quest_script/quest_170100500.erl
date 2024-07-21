%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2010-10-8
%% Description: TODO: Add description to quest_170100500
-module(quest_170100500).
-export([on_com_script/1]).
on_com_script(_Quest)->
	case script_op:get_class() of
		1->
			Itemid = 11001061;
		2->
			Itemid = 11001041;
		3->
			Itemid = 11001021
	end,
	ItemCount = 1,	
	case script_op:award_item(Itemid,ItemCount) of
		{ok,_}->
			true;
		full->	
			false
	end.


