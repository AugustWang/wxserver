%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%%
%%
-module(equipmentset_db).
%% 
%% define
%% 
-define(EQUIPMENTSET_TABLE,equipmentset_table).

-include("mnesia_table_def.hrl").
%% 
%% export
%% 
-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,init/0,create/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?EQUIPMENTSET_TABLE,[set,named_table]).

init()->
	db_operater_mod:init_ets(equipmentset, ?EQUIPMENTSET_TABLE,[#equipmentset.id,#equipmentset.num]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(equipmentset,record_info(fields,equipmentset),[],bag).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{equipmentset,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_equipmentset_states(Id,Num)->        
	case ets:lookup(?EQUIPMENTSET_TABLE, {Id,Num}) of
		[]->[];
        [{_,Info}]-> erlang:element(#equipmentset.states, Info) 
	end.

get_equipmentset_includes(Id)->
	case ets:lookup(?EQUIPMENTSET_TABLE, {Id,1}) of
		[]->[];
        [{_,Info}]-> erlang:element(#equipmentset.includeids, Info)  
	end.
	
