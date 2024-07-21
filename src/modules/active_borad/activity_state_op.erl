%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-7-13
%% Description: æ´»åŠ¨çŠ¶æ€
-module(activity_state_op).

%%
%% Include files
%%
-include("activity_define.hrl").
-include("active_board_define.hrl").
-include("base_define.hrl").
-define(ACTIVITY_LIST,lists:seq(1, ?ACTIVITY_MAX_INDEX)).
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
init()->
	Now = now(),
	put(last_activity_timestamp,Now),
	NowDate = calendar:now_to_local_time(Now),
	{Today,_NowTime} = NowDate, 
	NowWeek = calendar:day_of_the_week(Today),
	StateInfo = activity_state(NowDate,NowWeek),
	send_to_client(StateInfo).

process_message({activity_state_init_c2s,_})->
	Now = now(),
	case get(last_activity_timestamp) of
		?ERLNULL->
			ReSend = true;
		TimeStamp->
			TimeDiff = erlang:abs((timer:now_diff(TimeStamp,Now)/1000000)),
			if
				TimeDiff > ?CLIENT_REQ_INTEVAL_S->
					ReSend = true;
				true->
					ReSend = false
			end
	end,
	if
		ReSend->
			NowDate = calendar:now_to_local_time(Now),
			{Today,_NowTime} = NowDate, 
			NowWeek = calendar:day_of_the_week(Today),
			StateInfo = activity_state(NowDate,NowWeek),
			send_to_client(StateInfo),
			put(last_activity_timestamp,Now);
		true->
			nothing
	end;

process_message(_)->
	nothing.


%%
%%æ´»åŠ¨ç»“æŸæ—¶é€šçŸ¥æ‰€æœ‰ç”¨æˆ·
%%
update_activity_state()->
	Now = calendar:now_to_local_time(now()),
	{Today,_NowTime} = Now, 
	NowWeek = calendar:day_of_the_week(Today),
	StateInfo = activity_state(Now,NowWeek),
	MsgBin = active_borad_packet:encode_activity_state_init_s2c(StateInfo),
	role_pos_util:send_to_all_online_clinet(MsgBin).

%%
%% Local Functions
%%
activity_state(Now,NowWeek)->
	StateList = lists:map(fun({RealId,Id})->
					InfoList = answer_db:get_activity_info(Id),				
					Result = lists:foldl(fun(Info,Acc)->
											{Type,StartLines} = answer_db:get_activity_start(Info),
											if
												Acc->
													Acc;
												true->
													case Type of 
														?START_TYPE_DAY->
															check_is_time_line(Now,StartLines);
														_->
															lists:foldl(fun({Week,Start,End},Acc1)->
																			if Week =:= NowWeek ->
																					check_is_time_line(Now,[{Start,End}]);
																				true->
																					Acc1
																			end
																		end,Acc,StartLines)
													end
											end
										end,false,InfoList),
					if
						Result->
							active_borad_packet:make_acs(RealId,?ACTIVITY_STATE_NOTSTART);
						true->
							active_borad_packet:make_acs(RealId,?ACTIVITY_STATE_OVER)
					end
				end,get_activity_id(?ACTIVITY_LIST)).


check_is_time_line(Now,StartLines)->
%%	io:format("StartLines ~p now ~p ~n",[StartLines,Now]),
	lists:foldl(fun(StartLine,Re)->
					if
						Re->
							Re;
						true->
							case is_in_startline(Now,StartLine) of
								true->
									true;
								_->
									false
							end
					end 
				end,false,StartLines).

is_in_startline(Now,StartLine)->
	{{NowY,NowM,NowD},{NowH,NowMin,_}} = Now,
	{{{_,_,_},{StartH,StartMin,_}},{{_,_,_},{EndH,EndM,_}}} = StartLine,
%%	NowSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{NowH,NowMin,0}}),
%%	EndSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{EndH,EndM,0}}),
	timer_util:compare_time({NowH,NowMin,0},{EndH,EndM,0})=:=true.
%%	NowSecs < EndSecs.	

send_to_client(StateInfo)->
%%	io:format("send_to_client stateinfo ~p ~n",[StateInfo]),
	MsgBin = active_borad_packet:encode_activity_state_init_s2c(StateInfo),
	role_op:send_data_to_gate(MsgBin).


get_activity_id(ActivityList)->
	RelationList = activity_value_db:create_activity_relation(),
	lists:map(fun(Id)->
					case lists:keyfind(Id,1,RelationList) of
						false->
							{Id,Id};
						{_,RealId}->
							{RealId,Id};
						_->
							{Id,Id}
					end
				end,ActivityList).