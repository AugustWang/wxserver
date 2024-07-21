%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-7
%% Description: TODO: Add description to continuous_logging_db
-module(continuous_logging_db).

%%
%% Include files
%%
-define(ETS_TABLE_NAME1,continuous_logging_gift_ets).
-define(ETS_TABLE_NAME2,activity_test01_ets).
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
-include("active_board_def.hrl").

-export([load_first_charge_form_db/1,write_first_charge_form_db/2]).

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
   db_tools:create_table_disc(activity_test01,record_info(fields,activity_test01),[],set),	
   db_tools:create_table_disc(activity_test01_role,record_info(fields,activity_test01_role),[],set),	

	
    db_tools:create_table_disc(role_favorite_gift_info,record_info(fields,role_favorite_gift_info),[],set),	
	db_tools:create_table_disc(continuous_logging_gift,record_info(fields,continuous_logging_gift),[],set),
	db_tools:create_table_disc(role_continuous_logging_info,record_info(fields,role_continuous_logging_info),[],set),
	db_tools:create_table_disc(role_first_charge_gift,record_info(fields,role_first_charge_gift),[],set).


create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{activity_test01_role,disc},{activity_test01,proto},{role_favorite_gift_info,disc},{continuous_logging_gift,proto},{role_continuous_logging_info,disc},{role_first_charge_gift,disc}].

delete_role_from_db(RoleId)->
	 dal:delete_rpc(activity_test01_role,RoleId),
	 dal:delete_rpc(role_continuous_logging_info,RoleId),
	 dal:delete_rpc(role_first_charge_gift,RoleId),
    dal:delete_rpc(role_favorite_gift_info,RoleId).

create()->
	ets:new(?ETS_TABLE_NAME1,[set,named_table]),
	ets:new(?ETS_TABLE_NAME2,[set,named_table]).

init()->
	db_operater_mod:init_ets(continuous_logging_gift, ?ETS_TABLE_NAME1,#continuous_logging_gift.day),
	db_operater_mod:init_ets(activity_test01, ?ETS_TABLE_NAME2,#activity_test01.id).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	

get_info(Day)->
	case ets:lookup(?ETS_TABLE_NAME1,Day) of
		[]->[];
		[{_Day,Value}] -> Value
	end.

get_activity_test_info(Id)->
	case ets:lookup(?ETS_TABLE_NAME2,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.


get_normal_gift(TableInfo)->
	element(#continuous_logging_gift.reward,TableInfo).

get_vip_gift(TableInfo)->
	element(#continuous_logging_gift.reward,TableInfo).

get_continuous_logging_info(RoleId)->
	case dal:read_rpc(role_continuous_logging_info,RoleId) of
		{ok,[]}-> [];
		{ok,[{_,RoleId,Info}]}-> {RoleId,Info};
		{failed,badrpc,Reason}-> slogger:msg("get_continuous_logging_bonus failed ~p:~p~n",[badrpc,Reason]),[];
		{failed,Reason}-> slogger:msg("get_continuous_logging_bonus failed :~p~n",[Reason]),[]
	end.

get_favorite_gift_info(RoleId)->
	case dal:read_rpc(role_favorite_gift_info,RoleId) of
		{ok,[]}-> [];
		{ok,[{_,RoleId,Awarded}]}-> {RoleId,Awarded};
		{failed,badrpc,Reason}-> slogger:msg("get_favorite_gift_info failed ~p:~p~n",[badrpc,Reason]),[];
		{failed,Reason}-> slogger:msg("get_favorite_gift_infos failed :~p~n",[Reason]),[]
	end.

get_activity_test01_info(RoleId)->
	case dal:read_rpc(activity_test01_role,RoleId) of
		{ok,[]}-> [];
		{ok,[{_,RoleId,Info}]}-> Info;
		{failed,badrpc,Reason}-> slogger:msg("get_activity_test01_info failed ~p:~p~n",[badrpc,Reason]),[];
		{failed,Reason}-> slogger:msg("get_activity_test01_info failed :~p~n",[Reason]),[]
	end.



load_first_charge_form_db(RoleId)->
	case dal:read_rpc(role_first_charge_gift,RoleId) of
		{ok,[Info]}-> 
			Info;
		_-> 
			[]
	end.

write_first_charge_form_db(RoleId,State)->	
	dal:write_rpc(#role_first_charge_gift{roleid = RoleId,state = State}).
	
sync_updata(Term)->
	try
		Object = util:term_to_record(Term,role_continuous_logging_info),
		dal:write_rpc(Object)
	catch
		E:R->
			io:format("error ~p reason~p~n",[E,R]),
			error
	end.

sync_updata_new(Term,Table)->
	try
		Object = util:term_to_record(Term,Table),
		dal:write_rpc(Object)
	catch
		E:R->
			io:format("error ~p reason~p~n",[E,R]),
			error
	end.





