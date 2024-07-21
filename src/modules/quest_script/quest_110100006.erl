%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2010-11-5
%% Description: TODO: Add description to quest_110100006
-module(quest_110100006).
-export([acc_script/1]).
%%
%% Include files
%%

%%
%% Exported Functions
%%


%%
%% API Functions
%%
acc_script(_QuestId)->
	script_op:has_been_finished(170100007) 
	or script_op:has_been_finished(270100007)  
	or script_op:has_been_finished(370100007).


%%
%% Local Functions
%%

