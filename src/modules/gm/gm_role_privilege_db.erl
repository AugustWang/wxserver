%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-5-11
%% Description: TODO: Add description to gm_user_db
-module(gm_role_privilege_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
%%
%% Exported Functions
%%
-export([add_gm_role/2,delete_gm_role/1,get_role_privilege/1]).

%%
%% API Functions
%%
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
	db_tools:create_table_disc(gm_role_privilege, record_info(fields,gm_role_privilege) , [], set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{gm_role_privilege,disc}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

add_gm_role(RoleName,Privilege)->
	case role_db:get_roleid_by_name_rpc(RoleName) of
		[]->
			{error,"norole"};
		[RoleId]->
			dal:write_rpc({gm_role_privilege,RoleId,Privilege})		
	end.

delete_gm_role(RoleName)->
	case role_db:get_roleid_by_name_rpc(RoleName) of
		[]->
			{error,"norole"};
		[RoleId]->
			dal:delete_rpc(gm_role_privilege, RoleId)
	end.

get_role_privilege(RoleId)->
	case dal:read_rpc(gm_role_privilege,RoleId) of
		{ok,[]}-> {ok,[]};
		{ok,[Result]}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_role_privilege failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_role_privilege failed :~p~n",[Reason])
	end.
%%
%% Local Functions
%%

