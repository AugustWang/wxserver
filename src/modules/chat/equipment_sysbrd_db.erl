%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%% copy following code to module db_ini
%%
	

%%
%% add table equipment_sysbrd config to ebin/game_server.option
%%

%%
%% this file create by template
%% Author :
%% Created : 2011-03-21
%% Description : TODO

-module(equipment_sysbrd_db).

-define(ETS_TABLE_NAME,equipment_sysbrd_ets).
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% Include files 
%%
-include("mnesia_table_def.hrl").

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
	db_tools:create_table_disc(equipment_sysbrd,record_info(fields,equipment_sysbrd),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{equipment_sysbrd,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?ETS_TABLE_NAME,[set,named_table]).

init()->
	db_operater_mod:init_ets(equipment_sysbrd, ?ETS_TABLE_NAME,#equipment_sysbrd.id).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get_info()
%% []
%% {...}
%%[error,....]
%%
get_info(Id)->
	case ets:lookup(?ETS_TABLE_NAME,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.
%%
%% return : Value | []
%%
get_brdid(TableInfo)->
	element(#equipment_sysbrd.brdid,TableInfo).

%%
%% return : Value | []
%%
get_itemlist(TableInfo)->
	element(#equipment_sysbrd.itemlist,TableInfo).
