%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-9-26
%% Description: TODO: Add description to designation_db
-module(designation_db).

%%
%% Include files
%%
-include("designation_def.hrl").
-define(DESIGNATION_DATA,designation_data_ets).
%%
%% Exported Functions
%%
-export([load_role_designation_info/1,get_designation_data/1,get_attr_addition/1,write_designationinfo_to_db/3]).

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
	db_tools:create_table_disc(designation_data,record_info(fields,designation_data),[],set),
	db_tools:create_table_disc(role_designation_info,record_info(fields,role_designation_info),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{role_designation_info,disc},{designation_data,proto}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_designation_info, RoleId).

create()->
	ets:new(?DESIGNATION_DATA,[named_table,set]).

init()->
	db_operater_mod:init_ets(designation_data, ?DESIGNATION_DATA,#designation_data.key).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% API Functions
%%
get_designation_data(Key)->
	case ets:lookup(?DESIGNATION_DATA, Key) of
		[]->
			slogger:msg("get_designation_data_by_key error,no data~n"),
			[];
		[{_,Term}]->
			Term
	end.


get_attr_addition(DesigationData)->
	erlang:element(#designation_data.attr_addition, DesigationData).

load_role_designation_info(RoleId)->
	case dal:read_rpc(role_designation_info, RoleId) of
		{ok,[]}->
			[];
		{ok,[DesignationInfo]}->
%% 			io:format("load_role_designation_info,DesignationInfo:~p~n",[DesignationInfo]),
			DesignationInfo;
		_->
			slogger:msg("read role_designation_info error,RoleId:~p~n",[RoleId]),
			[]
	end.

write_designationinfo_to_db(RoleId,CurDesignationList,DesignationInfo)->
	Object = #role_designation_info{roleid = RoleId,cur_designation = CurDesignationList,designation_info =DesignationInfo},
	dal:write_rpc(Object).

	
%%
%% Local Functions
%%

