%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(dragon_fight_manager).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_define.hrl").
-include("activity_define.hrl").
-compile(export_all).

-define(DRAGON_FIGHT_BUFFER_TIME_S,360).
-define(DRAGON_FIGHT_BUFFER_END_TIME_S,600).

init()->
	put(dragon_fight_running,false).

on_check()->
	AnswerInfoList = answer_db:get_activity_info(?DRAGON_FIGHT_ACTIVITY),
	CheckFun = fun(ActiveInfo)->
				{Type,StartLines} = answer_db:get_activity_start(ActiveInfo),
				activity_manager_op:activity_forecast_check(?DRAGON_FIGHT_ACTIVITY,Type,StartLines),
				case activity_manager_op:check_is_time_line(Type,StartLines,?DRAGON_FIGHT_BUFFER_TIME_S,?DRAGON_FIGHT_BUFFER_END_TIME_S) of
					{true,StartLine}->
						start_dragon_fight(ActiveInfo,StartLine),
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
			stopeds_all()
	end.

stopeds_all()->
	case get(dragon_fight_running) of
		true->
			rpc:call(node(),dragon_fight_sup,stop_child, []),
			put(dragon_fight_running,false);
		_->
			nothing
	end.

start_dragon_fight(ActiveInfo,StartLine)->
	[Type] = answer_db:get_activity_spec_info(ActiveInfo),
	Duration = answer_db:get_activity_duration(ActiveInfo),
	case get(dragon_fight_running) of
		false->
			rpc:call(node(),dragon_fight_sup,start_child,[{Type,StartLine,Duration}]),
			put(dragon_fight_running,true);
		_->
			nothing
	end.

check_dragon_start()->
	get(dragon_fight_running).
		
