%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-3-29
%% Description: TODO: Add description to answer_manager_op
-module(answer_manager_op).

%%
%% Include files
%%
-define(ANSWER_BUFFER_TIME_S,60).
-define(ANSWER_BUFFER_END_TIME_S,0).
-include("activity_define.hrl").
%%
%% Exported Functions
%%
-export([init/0,on_check/0,apply_join_activity/1,on_stop_activity/1,get_activity_state/0]).

%%
%% API Functions
%%
init()->
	put(answer_manager_state,?ACTIVITY_STATE_STOP).

on_check()->
	AnswerInfoList = answer_db:get_activity_info(?ANSWER_ACTIVITY),
	CheckFun = fun(AnswerInfo)->
				{Type,StartLines} = answer_db:get_activity_start(AnswerInfo),
				activity_manager_op:activity_forecast_check(?ANSWER_ACTIVITY,Type,StartLines),
				Duration = answer_db:get_activity_duration(AnswerInfo),
				SpecInfo = answer_db:get_activity_spec_info(AnswerInfo),
				case activity_manager_op:check_is_time_line(Type,StartLines) of
					{true,_}->
						on_start_activity(Duration,SpecInfo),
						true;
					_->
						false
				end
	end,
	States = lists:map(CheckFun, AnswerInfoList),
	case lists:member(true,States) of
		true->
			nothing;
		_->
			on_stop_activity(node())
	end.
	
%% stopeds_all()->
%% 	case get(answer_manager_state) of
%% 		?ACTIVITY_STATE_START->
%% 			lists:foreach(fun(Node)-> rpc:call(Node,treasure_spawns_sup,stop_child, []) end, get(answer_nodes)),
%% 			put(treasure_spawns_running,false);
%% 		_->
%% 			nothing
%% 	end.

on_start_activity(Duration,Args)->
	case get(answer_manager_state) of
		?ACTIVITY_STATE_STOP->
			start_process(Duration,Args),
			put(answer_manager_state,?ACTIVITY_STATE_START);
		_->
			noting			
	end.

on_stop_activity(Node)->
	case get(answer_manager_state) of
		?ACTIVITY_STATE_STOP->
			nothing;
		_->
			rpc:call(Node,answer_sup,stop_child, []),
			put(answer_manager_state,?ACTIVITY_STATE_STOP)
	end.

apply_join_activity(_Info)->
	nothing.

get_activity_state()->
	get(answer_manager_state).
			
%%
%% Local Functions
%%
start_process(Duration,[Args])->
	rpc:call(node(),answer_sup,start_child, [Duration,Args]).
