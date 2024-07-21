%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2010-11-9
%% Description: TODO: Add description to quest_120100004
-module(quest_120100004).

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
	script_op:has_been_finished(160100003) 
	or script_op:has_been_finished(160200003)  
	or script_op:has_been_finished(160300003).



%%
%% Local Functions
%%

