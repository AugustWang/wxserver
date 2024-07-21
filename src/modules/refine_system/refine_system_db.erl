%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-9-16
%% Description: TODO: Add description to refine_system_db
-module(refine_system_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-define(REFINE_SYSTEM_ETS,refine_system_ets).
%%
%% Exported Functions
%%
-compile(export_all).
-export([init/0,create/0]).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(refine_system,record_info(fields,refine_system),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{refine_system,proto}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(refine_system, RoleId).

create()->
	ets:new(?REFINE_SYSTEM_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(refine_system, ?REFINE_SYSTEM_ETS, #refine_system.serial_number).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_refine_info_by_key(SerialNumber)->
	case ets:lookup(?REFINE_SYSTEM_ETS, SerialNumber)of
		[]->
			[];
		[{_,Term}]->
			Term
	end.
			
get_refine_need_money(RefineInfo)->
	#refine_system{need_money = NeedMoney} = RefineInfo,
	NeedMoney.

get_refine_output_type(RefineInfo)->
	#refine_system{output_type = OutputType} = RefineInfo,
	OutputType.

get_refine_need_items(RefineInfo)->
	#refine_system{need_items = NeedItems} = RefineInfo,
	NeedItems.

get_refine_output_bond_item(RefineInfo)->
	#refine_system{output_bond_item = OutputBondItem} = RefineInfo,
	OutputBondItem.

get_refine_output_unbond_item(RefineInfo)->
	#refine_system{output_unbond_item = OutputUnbondItem} = RefineInfo,
	OutputUnbondItem.

get_refine_rate(RefineInfo)->
	#refine_system{rate = Rate} = RefineInfo,
	Rate.
%%
%% Local Functions
%%

