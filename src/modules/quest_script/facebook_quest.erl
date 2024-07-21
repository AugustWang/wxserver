%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-7-28
%% Description: TODO: Add description to facebook_bind
-module(facebook_quest).

%%
%% Include files
%%
-define(UNFINISHED,0).
-define(SWITCH_OPEN,1).
-define(FINISHED,1).
-define(SWITCH_CLOSE,0).
%%
%% Exported Functions
%%
-export([com_script/1]).

%%
%% API Functions
%%
com_script(QuestId)->
	Switch = env:get(facebook_bind_switch,?SWITCH_CLOSE),
	if 
		Switch =:= ?SWITCH_OPEN->
%% 			io:format("Switch :facebook switch open~n"),
			QuestInfo = quest_db:get_info(QuestId),
			[{facebook_quest_state,_Op,ObjValue}] = quest_db:get_objectivemsg(QuestInfo),
%% 			io:format("facebook_quest script :ObjValue~p~n",[ObjValue]),
			State =case facebook:get_facebook_quest_state(get(roleid),ObjValue) of
					   ?FINISHED->
						  ?FINISHED;
					   ?UNFINISHED->
						   ?UNFINISHED
				   end,
%% 			io:format("State:~p~n",[State]),
			[{facebook_quest_state,State}];
		true->
%% 			io:format("Switch :facebook switch not open~n"),
			[{facebook_quest_state,0}]
	end.

				
					
%%
%% Local Functions
%%

