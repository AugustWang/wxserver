%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2010-11-9
%% Description: TODO: Add description to quest_140200003
-module(quest_140200003).
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
	script_op:has_been_finished(121200002) 
	or script_op:has_been_finished(122200002)  
	or script_op:has_been_finished(123200002).



%%
%% Local Functions
%%

