%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(role_instance_db).

-include("mnesia_table_def.hrl").

-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	nothing.

create_mnesia_split_table(role_instance,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,role_instance),[],set).

delete_role_from_db(RoleId)->
	TableName = db_split:get_owner_table(role_instance, RoleId),
	dal:delete_rpc(TableName, RoleId).

tables_info()->
	[{role_instance,disc_split}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_role_instance_info(RoleId)->
	TableName = db_split:get_owner_table(role_instance, RoleId),
	case dal:read_rpc(TableName,RoleId) of
		{ok,[R]}-> R;
		{ok,[]}->[];
		{failed,badrpc,_Reason}->{TableName,RoleId,[]};
		{failed,_Reason}-> {TableName,RoleId,[]}
	end.
	
save_role_instance_info(RoleId,StartTime,InstanceId,LastPos,Log)->
	TableName = db_split:get_owner_table(role_instance, RoleId),
	dmp_op:sync_write(RoleId,{TableName,RoleId,StartTime,InstanceId,LastPos,Log}).

async_save_role_instance_info(RoleId,StartTime,InstanceId,LastPos,Log)->
	TableName = db_split:get_owner_table(role_instance, RoleId),
	dmp_op:async_write(RoleId,{TableName,RoleId,StartTime,InstanceId,LastPos,Log}).

get_instanceid(RoleInstanceInfo)->
	case RoleInstanceInfo of
		[]->[];
		_->
			erlang:element(#role_instance.instanceid, RoleInstanceInfo)
	end.
	
get_lastpostion(RoleInstanceInfo)->
	case RoleInstanceInfo of
		[]->[];
		_->
			erlang:element(#role_instance.lastpostion, RoleInstanceInfo)
	end.

get_starttime(RoleInstanceInfo)->
	case RoleInstanceInfo of
		[]->[];
		_->
			erlang:element(#role_instance.starttime, RoleInstanceInfo)
	end.

get_log(RoleInstanceInfo)->
	case RoleInstanceInfo of
		[]->[];
		_->
			erlang:element(#role_instance.log, RoleInstanceInfo)
	end.