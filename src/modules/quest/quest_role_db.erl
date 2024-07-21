%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-6-24
%% Description: TODO: Add description to quest_role
-module(quest_role_db).
-include("mnesia_table_def.hrl").
%%
%% Include files
%%
%%
%% Exported Functions
%%
-export([get_questinfo_by_roleid/1,get_quest_list/1,async_update_quest_role/2,update_quest_role_now/2]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	nothing.

create_mnesia_split_table(quest_role,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,quest_role),[],set).

delete_role_from_db(RoleId)->
	OwnerTable = db_split:get_owner_table(quest_role, RoleId),
	dal:delete_rpc(OwnerTable, RoleId).

tables_info()->
	[{quest_role,disc_split}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% API Functions
%%
get_questinfo_by_roleid(RoleId)->
	TableName = db_split:get_owner_table(quest_role, RoleId),
	case dal:read_rpc(TableName,RoleId) of
		{ok,[]}-> {TableName,RoleId,[]};
		{ok,[Result]}-> Result;
		{failed,badrpc,Reason}-> slogger:msg("get_questinfo_by_roleid failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_questinfo_by_roleid failed :~p~n",[Reason])
	end.
        
get_quest_list(QuestRole)->
	try
		element(#quest_role.quest_list,QuestRole)
	catch
		_:_-> []
	end.

async_update_quest_role(RoleId,Quest_list)->	
	TableName = db_split:get_owner_table(quest_role, RoleId),
	dmp_op:async_write(RoleId,{TableName,RoleId,Quest_list}).

update_quest_role_now(RoleId,Quest_list)->
	TableName = db_split:get_owner_table(quest_role, RoleId),
	dmp_op:sync_write(RoleId,{TableName,RoleId,Quest_list}).
