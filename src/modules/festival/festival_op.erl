%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-11-14
%% Description: TODO: Add description to festival_op
-module(festival_op).

%%
%% Include files
%%
-include("festival_def.hrl").
-include("festival_define.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-export([init/0,get_festival_state_by_id/1,get_festival_state_by_info/1,init_tab_isshow/0]).

%%
%% API Functions
%%
init_tab_isshow()->
	OSTabState = open_service_activities:check_label_is_show(),
	FestivalTabState = festival_tab_isshow(),
	TabState = [festival_packet:make_tab_state(?OPEN_SERVICE_TAB,OSTabState),festival_packet:make_tab_state(?Festival_TAB,FestivalTabState)],
	Msg = festival_packet:encode_activity_tab_isshow_s2c(TabState),
	role_op:send_data_to_gate(Msg).
							  

festival_tab_isshow()->
	ets:foldl(fun({_FestivalId,FestivalInfo},TmpRet)->
					  if 
						  TmpRet->
							  true;
						  true->
							  Ret = get_festival_state_by_info(FestivalInfo),
							  if
								  Ret =:=?CLOSE->
									  false;
								  true->
									  true
							  end
					  end
			   end,false,?FESTIVAL_CONTROL_ETS).
								    
 
init()->
	Result = ets:foldl(fun({FestivalId,FestivalInfo},TmpRet)->
							   if
								   TmpRet->
									   true;
								   true->
									   Ret = get_festival_state_by_info(FestivalInfo),
									   if
										   Ret =:=?CLOSE->
											   false;
										   true->
											   case festival_db:get_festival_mod_by_id(FestivalId) of
												   error->
													   false;
												   Mod->
													   Mod:init(),
													   true
											   end
									   end
							   end
					   end, false, ?FESTIVAL_CONTROL_ETS),
	if
		Result =:= false->
			Msg = festival_packet:encode_festival_error_s2c(?ERRNO_NO_FESTIVAL_ACTIVITY),
			role_op:send_data_to_gate(Msg);
		true->
			noting
	end.



%%
%% Local Functions
%%

%%return state: CLOSE,DURING_ACTIVTIY,DURING_AWARD
get_festival_state_by_id(FestivalId)->
	case festival_db:get_festival_control_info_by_id(FestivalId) of
		[]->
			?CLOSE;
		FestialInfo->
			get_festival_state_by_info(FestialInfo)
	end.
	

%%return state: CLOSE,DURING_ACTIVTIY,DURING_AWARD
get_festival_state_by_info(FestivalInfo)->
	Show = festival_db:get_festival_show_by_info(FestivalInfo),
	if
		Show =:= ?CLOSE->
			?CLOSE;
		Show =:= ?FOREVER->
			?DURING_ACTIVTIY;
		true->
			StartTime = festival_db:get_festival_starttime_by_info(FestivalInfo),
			EndTime = festival_db:get_festival_endtime_by_info(FestivalInfo),
			NowTime = calendar:local_time(),
			InActivityTime = timer_util:is_in_time_point(StartTime,EndTime,NowTime),
			AwardEndTime = festival_db:get_festival_award_limit_time_by_info(FestivalInfo),
			if 
				InActivityTime->
					?DURING_ACTIVTIY;
				true->
					InAwardTime = timer_util:is_in_time_point(StartTime,AwardEndTime,NowTime),
					if
						InAwardTime->
							?DURING_AWARD;
						true->
							?CLOSE
					end
			end
	end.
