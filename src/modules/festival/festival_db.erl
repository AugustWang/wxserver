%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-11-14
%% Description: TODO: Add description to festival_db
-module(festival_db).

%%
%% Include files
%%
-include("festival_def.hrl").
-include("festival_define.hrl").
%%
%% Exported Functions
%%
-export([get_festival_control_info_by_id/1,get_festival_show_by_info/1,get_festival_starttime_by_info/1,
		 get_festival_endtime_by_info/1,get_festival_mod_by_id/1,get_festival_award_limit_time_by_info/1
		,read_festival_control_info_from_db/1,gm_del_festival_control_from_ets_rpc/0,
		 gm_add_festival_control_to_ets_rpc/1,gm_add_festival_recharge_gift_to_ets_rpc/1,
		 insert_festival_control_to_ets/1,insert_festival_recharge_gift_to_ets/1,
		 update_festival_recharge_gift_rpc/0]).
-export([get_role_festival_recharge_data/1,put_role_festival_recharge_data/1,get_all_role_festival_recharge_data/0]).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(festival_control,record_info(fields,festival_control),[],set),
	db_tools:create_table_disc(festival_control_background,record_info(fields,festival_control_background),[],set),
	db_tools:create_table_disc(festival_recharge_gift,record_info(fields,festival_recharge_gift),[],set),
	db_tools:create_table_disc(festival_recharge_gift_bg,record_info(fields,festival_recharge_gift_bg),[],set),
	db_tools:create_table_disc(role_festival_recharge_data,record_info(fields,role_festival_recharge_data),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_festival_recharge_data,RoleId).

tables_info()->
	[{festival_control,proto},{festival_control_background,disc},{festival_recharge_gift,proto},{festival_recharge_gift_bg,disc},{role_festival_recharge_data,disc}].


create()->
	ets:new(?FESTIVAL_CONTROL_ETS,[set,public,named_table]),
	ets:new(?FESTIVAL_RECHARGE_GIFT_ETS,[set,public,named_table]).

init()->
	init_festival_control_ets(),
	init_festival_recharge_gift().


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% API Functions
%%

init_festival_control_ets()->
	ets:delete_all_objects(?FESTIVAL_CONTROL_ETS),
	case dal:read_rpc(festival_control) of
		{ok,Results}->
			[];
		_->
			Results =[]
	end,
	lists:foreach(fun(Term)-> 
			Id = erlang:element(#festival_control.id, Term),
			case dal:read_rpc(festival_control_background,Id) of
				{ok,[]}->
					ets:insert(?FESTIVAL_CONTROL_ETS, {Id,Term});
				{ok,[BGFesitvalInfo]}->
					Isshow = BGFesitvalInfo#festival_control_background.show,
					StartTime = BGFesitvalInfo#festival_control_background.starttime,
					EndTime = BGFesitvalInfo#festival_control_background.endtime,
					AwardEndTime = BGFesitvalInfo#festival_control_background.award_limit_time,
					Object =Term#festival_control{show = Isshow,starttime = StartTime,endtime = EndTime,award_limit_time = AwardEndTime},
					ets:insert(?FESTIVAL_CONTROL_ETS, {Id,Object});
				ERROR->
					ets:insert(?FESTIVAL_CONTROL_ETS, {Id,Term}),
					slogger:msg("init_festival_control_ets,error,ERROR:~p~n",[ERROR])
			end	end, Results).


init_festival_recharge_gift()->
	ets:delete_all_objects(?FESTIVAL_RECHARGE_GIFT_ETS),
	case dal:read_rpc(festival_recharge_gift) of
		{ok,Results}->
			[];
		_->
			Results =[]
	end,
	lists:foreach(fun(Term)-> 
						  Id = erlang:element(#festival_recharge_gift.id, Term),
						  case dal:read_rpc(festival_recharge_gift_bg,Id) of
							  {ok,[]}->
								  ets:insert(?FESTIVAL_RECHARGE_GIFT_ETS, {Id,Term});
							  {ok,[BGGiftInfo]}->
								  NeedCount = BGGiftInfo#festival_recharge_gift_bg.needcount,
								  Gift = BGGiftInfo#festival_recharge_gift_bg.gift,
								  Object = Term#festival_recharge_gift{needcount = NeedCount,gift = Gift},
								  ets:insert(?FESTIVAL_RECHARGE_GIFT_ETS, {Id,Object});
							  ERROR->
								  ets:insert(?FESTIVAL_RECHARGE_GIFT_ETS, {Id,Term}),
								  slogger:msg("init_festival_recharge_gift,error,ERROR:~p~n",[ERROR])
						  end
				  	end, Results).


gm_add_festival_control_to_ets_rpc(Object)->
	lists:foreach(fun(N)-> rpc:call(N,?MODULE,insert_festival_control_to_ets,[Object])
				   end ,node_util:get_mapnodes()).

insert_festival_control_to_ets(Object)->
	try
		Id = erlang:element(#festival_control.id, Object),
		ets:insert(?FESTIVAL_CONTROL_ETS, {Id,Object})
	catch
		E:R->
			slogger:msg("insert_festival_control_to_ets error,E:~p,R:~p~n",[E,R])
	end.


gm_del_festival_control_from_ets_rpc()->
	lists:foreach(fun(N)-> rpc:call(N,?MODULE,init,[]) end ,node_util:get_mapnodes()).



update_festival_recharge_gift_rpc()->
	lists:foreach(fun(N)-> rpc:call(N,?MODULE,init_festival_recharge_gift,[])
				   end ,node_util:get_mapnodes()).


gm_add_festival_recharge_gift_to_ets_rpc(Object)->
	lists:foreach(fun(N)-> rpc:call(N,?MODULE,insert_festival_recharge_gift_to_ets,[Object])
				   end ,node_util:get_mapnodes()).

insert_festival_recharge_gift_to_ets(Object)->
	try
		Id = erlang:element(#festival_recharge_gift.id, Object),
		ets:insert(?FESTIVAL_RECHARGE_GIFT_ETS, {Id,Object})
	catch
		E:R->
			slogger:msg("insert_festival_recharge_gift_to_ets error,E:~p,R:~p~n",[E,R])
	end.
	

read_festival_control_info_from_db(FestivalId)->
	case dal:read_rpc(festival_control_background,FestivalId) of 
		{ok,[]}->
			case dal:read_rpc(festival_control,FestivalId) of
				{ok,[ReChargeInfo]}->
					ReChargeInfo;
				Error->
					slogger:msg("read_festival_recharge_control_info error,reason:~p~n",[Error]),
					[]
			end;
	   {ok,[TReChargeInfo]}->
			Isshow = TReChargeInfo#festival_control_background.show,
			StartTime = TReChargeInfo#festival_control_background.starttime,
			EndTime = TReChargeInfo#festival_control_background.endtime,
			AwardEndTime = TReChargeInfo#festival_control_background.award_limit_time,
			#festival_control{show = Isshow,starttime = StartTime,endtime = EndTime,award_limit_time = AwardEndTime};
		Error->
			slogger:msg("read_festival_recharge_control_info error,reason:~p~n",[Error]),
			[]
	end.
	


%%festival control info db operate
%%return [] or FestivalInfo
get_festival_control_info_by_id(FestialId)->
	try
		case ets:lookup(?FESTIVAL_CONTROL_ETS,FestialId) of
			[]->
				slogger:msg("not find festial info,festialid:~p~n",[FestialId]),
				[];
			[{_,FestialInfo}]->
				FestialInfo
		end
	catch
		_E:R->
			slogger:msg("get_festival_control_by_id error,Reason:~p~n",[R]),
			[]
	end.

get_festival_show_by_info(FestivalInfo)->
	try
		erlang:element(#festival_control.show,FestivalInfo)
	catch
		_E:R->
		slogger:msg("get_festival_show_by_info error,R:~p~n",[R]),
		?CLOSE
	end.

get_festival_starttime_by_info(FestivalInfo)->
	try
		erlang:element(#festival_control.starttime,FestivalInfo)
	catch
		_E:R->
			slogger:msg("get_festival_starttime_by_info,error,R:~p~n",[R]),
			{{2011,1,1},{1,1,1}}
	end.

get_festival_endtime_by_info(FestivalInfo)->
	try
		erlang:element(#festival_control.endtime,FestivalInfo)
	catch
		_E:R->
			slogger:msg("get_festival_endtime_by_info,error,R:~p~n",[R]),
			{{2011,1,1},{1,1,1}}
	end.

get_festival_award_limit_time_by_info(FestivalInfo)->
	try
		erlang:element(#festival_control.award_limit_time,FestivalInfo)
	catch
		_E:R->
			slogger:msg("get_festival_endtime_by_info,error,R:~p~n",[R]),
			{{2011,1,1},{1,1,1}}
	end.

get_festival_mod_by_id(FestivalId)->
	if
		FestivalId =:= ?UNCERTAIN_FESTIVAL->
			festival_op;
		FestivalId =:=?FESTIVAL_RECHARGE->
			festival_recharge;
		true->
%% 			slogger:msg("get_festival_mod_by_id error,FestivalId:~p~n",[FestivalId]),
			error
	end.



%%role_festival_recharge_db
get_role_festival_recharge_data(RoleId)->
	try
		case dal:read_rpc(role_festival_recharge_data,RoleId) of
			{ok,[]}->
				[];
			{ok,[ReChargeInfo]}->
				ReChargeInfo
		end
	catch
		_E:R->
			slogger:msg("get_role_recharge_info error,R:~p~n",[R]),
			[]
	end.


put_role_festival_recharge_data(Object)->
	case dal:write_rpc(Object) of 
		{ok}->
			nothing;
		{error,Error}->
			slogger:msg("put_role_festival_recharge_data error,Reason:~p~n",[Error]);
		Other->
			slogger:msg("put_role_festival_recharge_data error,return:~p~n",[Other])
	end.

get_all_role_festival_recharge_data()->
	case dal:read_rpc(role_festival_recharge_data) of
		{ok,Result}->
			 Result;
		Error->
			slogger:msg("read festival_recharge_data failed:~p~n",[Error]),
			[]
	end.


