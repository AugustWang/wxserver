%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-7-18
%% Description: TODO: Add description to goals_packet
-module(goals_packet).

%%
%% Include files
%%
-export([handle/2,process_goals/1]).
-export([encode_goals_init_s2c/1,encode_goals_update_s2c/1,encode_goals_error_s2c/1]).
-include("login_pb.hrl").
-include("data_struct.hrl").
%%
%% Exported Functions
%%

%%
%% API Functions
%%
handle(Message=#goals_reward_c2s{}, RolePid)->
	RolePid!{goals,Message};
handle(Message=#goals_init_c2s{}, RolePid)->
	RolePid!{goals,Message}.

process_goals(#goals_init_c2s{})->
	goals_op:goals_init();
process_goals(#goals_reward_c2s{days=Days,part=Part})->
	goals_op:goals_reward(Days,Part);
process_goals({chess_spirit_team,CurSection})->
	achieve_op:chess_spirit_team(CurSection).

encode_goals_init_s2c(InitGoals)->
	login_pb:encode_goals_init_s2c(#goals_init_s2c{parts=InitGoals}).
encode_goals_update_s2c(GoalsPart)->
	login_pb:encode_goals_update_s2c(#goals_update_s2c{part=GoalsPart}).
encode_goals_error_s2c(Reason)->
	login_pb:encode_goals_error_s2c(#goals_error_s2c{reason=Reason}).


%%
%% Local Functions
%%

