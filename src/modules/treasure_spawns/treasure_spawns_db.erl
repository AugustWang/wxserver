%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%% copy following code to module db_ini
%%
	

%%
%% add table timelimit_gift config to ebin/game_server.option
%%

%%
%% this file create by template
%% Author :
%% Created : 2011-03-23
%% Description : TODO

-module(treasure_spawns_db).

-define(TREASURE_SWPANS_ETS,treasure_spawns_ets).
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
	db_tools:create_table_disc(treasure_spawns,record_info(fields,treasure_spawns),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{treasure_spawns,proto}].

delete_role_from_db(_)->
	nothing.

create()->
	ets:new(?TREASURE_SWPANS_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(treasure_spawns, ?TREASURE_SWPANS_ETS,#treasure_spawns.id).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% import file to ets table
%% 	
foldl(F,A)->
	ets:foldl(F, A, ?TREASURE_SWPANS_ETS).
%% 
%% get_info()
%% []
%% {...}
%%[error,....]
%%
get_info(Id)->
	try
		case ets:lookup(?TREASURE_SWPANS_ETS,Id) of
			[]->[];
			[{_Id,Value}] -> Value
		end
	catch
		_:_-> [error,"No this Term!"]
	end.

%%
%%format [{Index,Time,DropList}]
%%
%%
%% return : Value | []
%%
get_id(TableInfo)->
	element(#treasure_spawns.id,TableInfo).

get_type(TableInfo)->
	element(#treasure_spawns.type,TableInfo).

get_maps(TableInfo)->
	element(#treasure_spawns.maps,TableInfo).

get_interval(TableInfo)->
	element(#treasure_spawns.interval,TableInfo).

get_round_num(TableInfo)->
	element(#treasure_spawns.round_num,TableInfo).

get_spawn_num(TableInfo)->
	element(#treasure_spawns.spawn_num,TableInfo).

get_map_spawns(TableInfo)->
	element(#treasure_spawns.map_spawns,TableInfo).

