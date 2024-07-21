%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-1-27
%% Description: TODO: Add description to quest_buy_item
-module(quest_dragon_fight).
-include("error_msg.hrl").

-export([com_script/1,on_com_script/1]).

com_script(_Quest)->
	[{dragon_fight_end,0}].

on_com_script(_Quest)->
	true.		
		
