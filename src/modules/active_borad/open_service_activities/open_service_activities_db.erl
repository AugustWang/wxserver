%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-14
%% Description: TODO: Add description to open_service_activities_db
-module(open_service_activities_db).

%%
%% Include files
%%
-include("open_service_activities_define.hrl").
-include("open_activities_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%
%% API Functions
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(role_service_activities_db,record_info(fields,role_service_activities_db),[],set),
	db_tools:create_table_disc(open_service_activities,record_info(fields,open_service_activities),[],set),
	db_tools:create_table_disc(open_service_activities_time,record_info(fields,open_service_activities_time),[],set),
	db_tools:create_table_disc(open_service_activitied_control,record_info(fields,open_service_activitied_control),[],set),
	db_tools:create_table_disc(open_service_level_rank_db,record_info(fields,open_service_level_rank_db),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{role_service_activities_db,disc},{open_service_activities,proto},
	 {open_service_activities_time,disc},{open_service_activitied_control,disc},
	 {open_service_level_rank_db,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_service_activities_db,RoleId).

create()->
	ets:new(?OPEN_SERVICE_ACTIVITIES_ETS,[set,named_table]),
	ets:new(?SERVICE_ACTIVITIES_TIME_ETS,[set,named_table]).

init()->
	init_open_service_activities_time_ets(),
	db_operater_mod:init_ets(open_service_activities, ?OPEN_SERVICE_ACTIVITIES_ETS, #open_service_activities.id).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_role_service_activities_info(RoleId)->
	case dal:read_rpc(role_service_activities_db,RoleId) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.

write_role_activities_to_db(RoleId,Info)->
	dal:write_rpc({role_service_activities_db,RoleId,Info}).

add_to_open_service_level_rank_db(Type,RankList)->
	dal:write_rpc({open_service_level_rank_db,Type,RankList}).

get_open_server_level_rank(Type)->
	case dal:read_rpc(open_service_level_rank_db,Type) of
		{ok,[RankList]}->
			RankList;
		_->
			[]
	end.

init_open_service_activities_time_ets()->
	case dal:read_rpc(open_service_activities_time) of
		{ok,Results}->
			Results;
		_->
			Results =[]
	end,
	ets:delete_all_objects(?SERVICE_ACTIVITIES_TIME_ETS),
	lists:foreach(fun(Term)-> 
			Id = erlang:element(#open_service_activities_time.id, Term),
			case dal:read_rpc(open_service_activitied_control,Id) of
				{ok,[]}->
					ets:insert(?SERVICE_ACTIVITIES_TIME_ETS, {Id,Term});
				{ok,[{_,_,Isshow,StartTime,EndTime}]}->
					Object =Term#open_service_activities_time{id = Id,show = Isshow,starttime = StartTime,endtime = EndTime},
					ets:insert(?SERVICE_ACTIVITIES_TIME_ETS, {Id,Object});
				ERROR->
					ets:insert(?SERVICE_ACTIVITIES_TIME_ETS, {Id,Term})
			end	end, Results).

get_open_service_activities_timeinfo(Id)->
	case ets:lookup(?SERVICE_ACTIVITIES_TIME_ETS,Id) of
		[]->
			[];
		[{_,Info}]->
			Info
	end.

get_service_activities_info(Id)->
	case ets:lookup(?OPEN_SERVICE_ACTIVITIES_ETS,Id) of
		[]->
			[];
		[{_,Info}]->
			Info
	end.

get_activities_part(ActivityInfo)->
	erlang:element(#open_service_activities.partinfolist,ActivityInfo).

get_open_service_activities_starttime(ActivityInfo)->
	erlang:element(#open_service_activities_time.starttime,ActivityInfo).

get_open_service_activities_endtime(ActivityInfo)->
	erlang:element(#open_service_activities_time.endtime,ActivityInfo).



























