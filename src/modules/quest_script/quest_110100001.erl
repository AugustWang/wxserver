%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2010-10-13
%% Description: TODO: Add description to quest_110100001
-module(quest_110100001).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([acc_script/1]).

%%
%% API Functions
%%
acc_script(_QuestId)->
	script_op:has_been_finished(11401000) 
	or script_op:has_been_finished(21401000)  
	or script_op:has_been_finished(31401000).
%%
%% Local Functions
%%

