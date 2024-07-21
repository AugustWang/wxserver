%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2010-11-9
%% Description: TODO: Add description to quest_silenttrader
-module(quest_silenttrader).
-export([on_com_script/1]).
%%
%% Include files
%%
on_com_script(_Quest)->
	case script_op:get_class() of
		1->
			Itemid = 11001012;
		2->
			Itemid = 11001032;
		3->
			Itemid = 11001052
	end,
	ItemCount = 1,	
	case script_op:award_item(Itemid,ItemCount) of
		{ok,_}->
			true;
		full->	
			false
	end.

%%
%% Exported Functions
%%


%%
%% API Functions
%%



%%
%% Local Functions
%%

