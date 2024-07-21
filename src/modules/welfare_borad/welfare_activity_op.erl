%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-8-6
%% Description: TODO: Add description to welfare_activity_op
-module(welfare_activity_op).

%%
%% Include files
%%
-include("error_msg.hrl").
-include("welfare_activity_define.hrl").
%%
%% Exported Functions
%%
-export([welfare_activity_init/0,judge_activity_state/1,
		 serialnumber_activity_update/2,serialnumber_activity_result/1]).

%%
%% API Functions
%%

%%welfare borad init 
%%activity state:[{gps,ActivityNumber,IsOpen,FinishState}]
welfare_activity_init()->
%% 	io:format("welfare_activity_init state~n"),
	InitState = fun({ActivityNumber,_},Acc)->
				  case judge_activity_state(ActivityNumber) of
					  true->
						  State = get_activity_finish_state(ActivityNumber),
						  [{gps,ActivityNumber,?OPEN,State}|Acc];
					  _->
						  [{gps,ActivityNumber,?CLOSE,?UNFINISHED}|Acc]
				  end
		  end,
	PacksStateList = ets:foldl(InitState,[],?WELFARE_ACTIVITY_DATA),
	BinMsg = welfare_activity_packet:encode_welfare_panel_init_s2c(PacksStateList),
	role_op:send_data_to_gate(BinMsg).


%%get activity finished state 
%%return:?UNFINISHED ,?FINISHED
get_activity_finish_state(ActivityNumber)->
	RoleId = get(roleid),
	case welfare_activity_db:load_role(RoleId,ActivityNumber) of
		[]->
			?UNFINISHED;
		_->
			?FINISHED
	end.


%%check the serial number and update activity state
serialnumber_activity_update(ActivityNumber,SerialNumber)->
	case get_activity_finish_state(ActivityNumber) of
		?FINISHED ->
%% 			io:format("get_activity_finish_state FINISHED~n"),
			Msg = welfare_activity_packet:encode_welfare_activity_update_s2c(ActivityNumber,?FINISHED,?ERROR_HAS_FINISHED),
			role_op:send_data_to_gate(Msg);
		?UNFINISHED ->
			Gift = welfare_activity_db:get_welfare_activity_gift(ActivityNumber),
			case package_op:can_added_to_package_template_list(Gift)of
				false->
					Msg = welfare_activity_packet:encode_welfare_activity_update_s2c(ActivityNumber,?UNFINISHED,?ERROR_PACKEGE_FULL),
					role_op:send_data_to_gate(Msg);
				true->
					serialnumber_activity_script:process_rpc(ActivityNumber,SerialNumber)
			end
	end.
		

				
%%	result process				
serialnumber_activity_result({Result,ActivityNumber,SerialNumber})->
	if 
		Result =:= ?ERROR_ACTIVITY_UPDATE_OK->
			welfare_activity_db:write_record(get(roleid),ActivityNumber,SerialNumber),
			GiftList =  welfare_activity_db:get_welfare_activity_gift(ActivityNumber),
			lists:map(fun({Protoid,Count})->
							  role_op:auto_create_and_put(Protoid,Count,welfare_activity)
					  end,GiftList),
			gm_logger_role:golden_plume_awards_log(get(roleid),get(rolelevel),sucess,?ERROR_ACTIVITY_UPDATE_OK,ActivityNumber),
			Msg = welfare_activity_packet:encode_welfare_activity_update_s2c(ActivityNumber,?FINISHED,?ERROR_ACTIVITY_UPDATE_OK),
			role_op:send_data_to_gate(Msg);
		true->
			gm_logger_role:golden_plume_awards_log(get(roleid),get(rolelevel),sucess,Result,ActivityNumber),
			Msg = welfare_activity_packet:encode_welfare_activity_update_s2c(ActivityNumber,?UNFINISHED,Result),
			role_op:send_data_to_gate(Msg)
	end.

		
%% return activity time state:true or false
judge_activity_state(ActivityNumber)->
	case welfare_activity_db:get_welfare_activity_data(ActivityNumber) of
		[]->
			no_activity_data;
		ActivityInfo->
			StartTime = welfare_activity_db:get_starttime(ActivityInfo),
			EndTime = welfare_activity_db:get_endtime(ActivityInfo),
			IsShow = welfare_activity_db:get_isshow(ActivityInfo),
			NowTime = calendar:local_time(),
			
			if
				IsShow =:= ?OPEN->
					true;
				IsShow =:= ?CLOSE->
					false;
				true->
					timer_util:is_in_time_point(StartTime,EndTime,NowTime)
			end
	end.
				

%%
%% Local Functions
%%

