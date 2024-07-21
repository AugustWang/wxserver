%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-2-10
%% Description: TODO: Add description to role_level_bonefire_db
-module(role_level_bonefire_db).

%%
%% Include files
%%
-define(ETS_TABLE_NAME,role_level_bonfire_effect_ets).
%%
%% Exported Functions
%%
-compile(export_all).
-include("buffer_effect_def.hrl").
%%
%% API Functions
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,init/0,create/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?ETS_TABLE_NAME,[set,named_table]).

init()->
	db_operater_mod:init_ets(role_level_bonfire_effect_db, ?ETS_TABLE_NAME,#role_level_bonfire_effect_db.level).

create_mnesia_table(disc)->
	db_tools:create_table_disc(role_level_bonfire_effect_db,record_info(fields,role_level_bonfire_effect_db),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{role_level_bonfire_effect_db,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_bonefire_exp_info(Level)->
	case ets:lookup(?ETS_TABLE_NAME,Level) of
		[{_,Info}]->
			Info;
		_->
			[]
	end.

get_bonefire_exp(Info)->
	element(#role_level_bonfire_effect_db.exp,Info).

get_bonefire_soulpower(Info)->
	element(#role_level_bonfire_effect_db.soulpower,Info).
