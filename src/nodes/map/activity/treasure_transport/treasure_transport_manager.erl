%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(treasure_transport_manager).

-compile(export_all).

-include("common_define.hrl").
-include("activity_define.hrl").
-include("treasure_transport_define.hrl").
-include("system_chat_define.hrl").

init()->
	put(treasure_transport_running,false),
	put(treasure_transport_start_time,{0,0,0}).

on_check()->
	ActivityInfoList = answer_db:get_activity_info(?TREASURE_TRANSPORT_ACTIVITY),
	CheckFun = fun(ActiveInfo)->
				{Type,StartLines} = answer_db:get_activity_start(ActiveInfo),
 				activity_manager_op:activity_forecast_check(?TREASURE_TRANSPORT_ACTIVITY,Type,StartLines),
				case activity_manager_op:check_is_time_line(Type,StartLines) of
					{true,StartLine}->
						start_treasure_transport(),
						true;
					_->
						false
				end
	end,
	States = lists:map(CheckFun, ActivityInfoList),
	case lists:member(true,States) of
		true->
			nothing;
		_->
			stopeds_all()
	end.

stopeds_all()->
	case get(treasure_transport_running) of
		false->
			nothing;
		_->
			put(treasure_transport_running,false),
			Message = treasure_transport_packet:encode_server_treasure_transport_end_s2c(),
			role_pos_util:send_to_all_online_clinet(Message)
	end.

start_treasure_transport()->
	case get(treasure_transport_running) of
		true-> 
			nothing; 
		_->
			put(treasure_transport_start_time,now()),
			put(treasure_transport_running,true),
			system_chat_op:system_broadcast(?SYSTEM_CHAT_SERVER_TREASURE_TRANSPORT_START,[]),  
			Message = treasure_transport_packet:encode_server_treasure_transport_start_s2c(?SERVER_DURATION_TIME),
			role_pos_util:send_to_all_online_clinet(Message)
	end.

role_on_line_notic(RoleId)->
	case get(treasure_transport_running) of
		true-> 
			Start_time = get(treasure_transport_start_time),
			LeftTime = ?SERVER_DURATION_TIME - trunc(timer:now_diff(now(),Start_time)/1000000),
			Message = treasure_transport_packet:encode_server_treasure_transport_start_s2c(LeftTime),
			role_pos_util:send_to_role_clinet(RoleId, Message);
		_->
			nothing
			
	end.









