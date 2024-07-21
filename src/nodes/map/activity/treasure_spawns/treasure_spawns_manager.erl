%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(treasure_spawns_manager).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_define.hrl").
-include("activity_define.hrl").
-compile(export_all).

-define(TREASURE_BUFFER_TIME_S,360).
-define(TREASURE_BUFFER_END_TIME_S,60).

init()->
	put(treasure_spawns_nodes,[]),
	put(treasure_spawns_running,false).

travel_check(?TEASURE_SPAWNS_ACTIVITY)->
	case server_travels_util:is_share_server() of
		true->			%%share server start
			true;
		_->
			case server_travels_util:is_has_share_map() of
				true->				%%has share map not start 
					false;
				_->
					true
			end
	end;
travel_check(_)->
	case server_travels_util:is_share_server() of
		true->			%%share server not start
			false;
		_->
			true
	end.

on_check()->
	AnswerInfoList = answer_db:get_activity_info(?TEASURE_SPAWNS_ACTIVITY),
	StarInfoList = answer_db:get_activity_info(?STAR_SPAWNS_ACTIVITY),
	RideInfoList = answer_db:get_activity_info(?RIDE_SPAWNS_ACTIVITY),

	CheckFun = fun(AnswerInfo)->
				{Type,StartLines} = answer_db:get_activity_start(AnswerInfo),
				%%activity_manager_op:activity_forecast_check( answer_db:get_activity_id(AnswerInfo),Type,StartLines),
				SpecInfo = answer_db:get_activity_spec_info(AnswerInfo),
				case activity_manager_op:check_is_time_line(Type,StartLines,?TREASURE_BUFFER_TIME_S,?TREASURE_BUFFER_END_TIME_S) of
					{true,StartLine}->
						case travel_check(answer_db:get_activity_id(AnswerInfo)) of
							true->
								start_treasure_spawns(SpecInfo,StartLine),
								true;
							_->
								false
						end;
					_->
						false
				end
	end,
	States = lists:map(CheckFun, AnswerInfoList++StarInfoList++RideInfoList),
	case lists:member(true,States) of
		true->
			nothing;
		_->
			stopeds_all()
	end.

stopeds_all()->
	case get(treasure_spawns_running) of
		true->
			lists:foreach(fun(Node)-> rpc:call(Node,treasure_spawns_sup,stop_child, []) end, get(treasure_spawns_nodes)),
			put(treasure_spawns_running,false);
		_->
			nothing
	end.

stoped(Node)->
	rpc:call(Node,treasure_spawns_sup,stop_child, []).

start_treasure_spawns([Type],StartLine)->
	case get(treasure_spawns_running) of
		false->
			io:format("start_treasure_spawns ~p ~n",[Type]),
			TreasureInfo = treasure_spawns_db:get_info(Type),
			Maps = treasure_spawns_db:get_maps(TreasureInfo),
			Nodes = lists:foldl(fun(MapId,AccNodes)->
					NodeTmp = lines_manager:get_map_node(?TREASURE_SPAWNS_DEFAULT_LINE, MapId),
					case lists:member(NodeTmp, AccNodes) or (NodeTmp=:= error) of
						true->
							AccNodes;
						_->
							[NodeTmp|AccNodes]
					end end, [], Maps),
			put(treasure_spawns_nodes,Nodes),
			lists:foreach(fun(Node)-> rpc:call(Node,treasure_spawns_sup,start_child, [{Type,StartLine}]) end, Nodes),
			put(treasure_spawns_running,true);
		_->
			nothing
	end.
