%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%% copy following code to module db_ini
%%
	

%%
%% add table role_level_soulpower config to ebin/game_server.option
%%

%%
%% this file create by template
%% Author :
%% Created : 2011-02-15
%% Description : TODO

-module(role_level_soulpower_db).

-define(ETS_TABLE_NAME,role_level_soulpower_ets).
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
	db_tools:create_table_disc(role_level_soulpower,record_info(fields,role_level_soulpower),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{role_level_soulpower,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?ETS_TABLE_NAME,[set,named_table]).

init()->
	db_operater_mod:init_ets(role_level_soulpower, ?ETS_TABLE_NAME,#role_level_soulpower.level).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_info(Id)->
	case ets:lookup(?ETS_TABLE_NAME,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.

%%
%% return : Value | []
%%
get_maxpower(TableInfo)->
	element(#role_level_soulpower.maxpower,TableInfo).

%%
%% return : Value | []
%%	
get_spreward(TableInfo)->
	element(#role_level_soulpower.spreward,TableInfo).
