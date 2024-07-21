%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-7-13
%% Description: boss state
-module(activity_boss_state_op).

%%
%% Include files
%%
-include("active_board_define.hrl").
-include("base_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
init()->
	nothing.
	
process_message({activity_boss_born_init_c2s,_})->
	boss_state();
	%%nothing;

process_message(_)->
	nothing.
	
%%
%% Local Functions
%%
boss_state()->
	Now = now(),
	case get(last_boss_born_stamp) of
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
			BossList = activity_value_db:create_boss_born_msg(),
			NowDate = calendar:now_to_local_time(Now),
			BSInfo = lists:map(fun(Id)->
					Info = activity_value_db:get_info(Id),
					{Type,TimeLines} = activity_value_db:get_time(Info),
					active_borad_packet:make_bs(Id,get_next_time(NowDate,TimeLines))
				end,BossList),
			MsgBin = active_borad_packet:encode_activity_boss_born_init_s2c(BSInfo),
			role_op:send_data_to_gate(MsgBin),
			put(last_boss_born_stamp,Now);
		true->
			nothing
	end.
	
%%%%è¿”å›žä¸‹æ¬¡çš„æ—¶é—´ æè¿°
%%
%%è¿”å›žä¸‹æ¬¡çš„æ—¶é—´ æè¿°
%%
get_next_time(Now,TimeLines)->
	Result = lists:foldl(fun(TimeLine,Acc)->
							{_,Re} = Acc,
							if
								Re->
									Acc;
								true->
									{{NowY,NowM,NowD},{NowH,NowMin,_}} = Now,
									{{_,_,_},{StartH,StartMin,_}} = TimeLine,
%%									NowSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{NowH,NowMin,0}}),
%%									StartSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{StartH,StartMin,0}}),
%%									if
%%										NowSecs < StartSecs ->
									case timer_util:compare_time({NowH,NowMin,0},{StartH,StartMin,0}) of
										true->
											{StartH*60*60+StartMin*60,true};
										_->
											Acc 
									end
							end
						end,{0,false},TimeLines),
	{Time_S,Res} = Result,
	if
		Res->
			Time_S;
		true->
			{{_,_,_},{H,M,_}} = lists:nth(1,TimeLines),
			H*60*60 + M*60
	end.	
