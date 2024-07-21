%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-8-25
%% Description: TODO: Add description to pet_slot_db
-module(pet_slot_db).

%%
%% Include files
%%
-include("pet_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
-define(PET_SLOT_ETS,pet_slot_ets).

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
	db_tools:create_table_disc(pet_slot,record_info(fields,pet_slot),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_slot,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_SLOT_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_slot, ?PET_SLOT_ETS,#pet_slot.slot).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_info(Id)->
	case ets:lookup(?PET_SLOT_ETS,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.

get_price(Info)->
	element(#pet_slot.price,Info).

