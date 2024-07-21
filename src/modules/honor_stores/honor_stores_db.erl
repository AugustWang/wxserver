%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-30
%% Description: TODO: Add description to honor_stores_db
-module(honor_stores_db).

%%
%% Include files
%%
-include("honor_stores_define.hrl").
-include("honor_stores_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
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
	db_tools:create_table_disc(honor_store_items, record_info(fields,honor_store_items), [], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{honor_store_items,proto}].

delete_role_from_db(_)->
	nothing.

create()->
	ets:new(?HONOR_STORE_ITEMS_ETS,[set,public,named_table]).

init()->
	db_operater_mod:init_ets(honor_store_items, ?HONOR_STORE_ITEMS_ETS,#honor_store_items.part).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_sell_items_by_type(TypePart)->
	case ets:lookup(?HONOR_STORE_ITEMS_ETS,TypePart) of
		[{_,Term}]->
			Term;
		_->
			[]
	end.








