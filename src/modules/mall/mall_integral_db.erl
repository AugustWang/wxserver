%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-4
%% Description: TODO: Add description to mall_integral
-module(mall_integral_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
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
	db_tools:create_table_disc(role_mall_integral,record_info(fields,role_mall_integral),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{role_mall_integral,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_mall_integral,RoleId).

create()->
	nothing.

init()->
	nothing.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_tole_mall_integral(RoleId)->
	case dal:read_rpc(role_mall_integral,RoleId) of
		{ok,[Result]}->Result;
		_->[]
	end.

add_role_mall_integral(RoleId,Charge_integral,Consume_integral)->
	dal:write_rpc({role_mall_integral,RoleId,Charge_integral,Consume_integral}).
