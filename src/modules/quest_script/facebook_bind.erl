%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-7-28
%% Description: TODO: Add description to facebook_bind
-module(facebook_bind).

%%
%% Include files
%%
-define(SWITCH_CLOSE,0).
-define(SWITCH_OPEN,1).
-define(FB_NOT_BIND,0).
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
			NowState = facebook:get_facebook_bind_state(get(roleid)),
			QuestInfo = quest_db:get_info(QuestId),
			[{facebook_bind_state,Op,ObjValue}] = quest_db:get_objectivemsg(QuestInfo),
			State = quest_op:get_quest_states_by_op(Op,ObjValue,NowState,?FB_NOT_BIND),
%% 			io:format("State:~p~n",[State]),
			[{facebook_bind_state,State}];
		true->
%% 			io:format("Switch :facebook switch not open~n"),
			[{facebook_bind_state,0}]
	end.

				
					
%%
%% Local Functions
%%

