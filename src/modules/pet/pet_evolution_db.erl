%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-8-26
%% Description: TODO: Add description to pet_evolution_db
-module(pet_evolution_db).

%%
%% Include files
%%
-define(PET_EVOLUTION_ETS,pet_evolution_ets).
-include("pet_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
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
	db_tools:create_table_disc(pet_evolution,record_info(fields,pet_evolution),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_evolution,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_EVOLUTION_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_evolution, ?PET_EVOLUTION_ETS,#pet_evolution.petproto).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


get_pet_evolution_info(PetProto)->
	case ets:lookup(?PET_EVOLUTION_ETS, PetProto) of
		[]-> [];
		[{_,Info}]-> Info
	end.

get_pet_evolution_consume(EvoluntionInfo)->
	element(#pet_evolution.consume,EvoluntionInfo).

get_evolution_rate(EvoluntionInfo)->
	element(#pet_evolution.rate,EvoluntionInfo).

get_evolution_protoid(EvoluntionInfo)->
	element(#pet_evolution.result_petproto,EvoluntionInfo).

get_pet_evolution_order(EvoluntionInfo)->
	element(#pet_evolution.order,EvoluntionInfo).





								  