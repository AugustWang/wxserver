%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2010-11-15
%% Description: TODO: Add description to quest_140300126
-module(quest_140300126).
-export([acc_script/1]).
%%
%% Include files
%%
acc_script(_QuestId)->
	script_op:has_been_finished(140300123) 
	or script_op:has_been_finished(140300124)  
	or script_op:has_been_finished(140300125).
%%
%% Exported Functions
%%


%%
%% API Functions
%%



%%
%% Local Functions
%%

