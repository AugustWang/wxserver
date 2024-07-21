%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-9-29
%% Description: TODO: Add description to spa_db
-module(spa_db).

%%
%% Include files
%%
-include("spa_define.hrl").
-define(SPA_OPTION,ets_spa_option).
-define(SPA_EXP,ets_spa_exp).
%%
%% Exported Functions
%%
-export([get_option_info/1,get_spa_exp_info/1]).
-export([
		 get_spa_id/1,
		 get_spa_duration/1,
		 get_spa_instance_proto/1,
		 get_spa_looptime/1,
		 get_spa_chopping/1,
		 get_spa_swimming/1,
		 get_spa_vip_exp_addition/1,
		 get_spa_vip_op_addition/1,
		 get_spa_exp_level/1,
		 get_spa_exp_exp/1,
		 get_spa_exp_soulpower/1,
		 get_spa_exp_chopping_self/1,
		 get_spa_exp_chopping_be/1,
		 get_spa_exp_swimming_self/1,
		 get_spa_exp_swimming_be/1
		 ]).
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
	db_tools:create_table_disc(spa_option,record_info(fields,spa_option),[],set),
	db_tools:create_table_disc(spa_exp,record_info(fields,spa_exp),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{spa_option,proto},{spa_exp,proto}].

delete_role_from_db(_)->
	nothing.

create()->
	ets:new(?SPA_OPTION, [set,named_table]),
	ets:new(?SPA_EXP, [set,named_table]).

init()->
	db_operater_mod:init_ets(spa_option, ?SPA_OPTION,#spa_option.spa_id),
	db_operater_mod:init_ets(spa_exp, ?SPA_EXP,#spa_exp.level).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_option_info(SpaId)->
	case ets:lookup(?SPA_OPTION,SpaId) of
		[]->[];
		[{SpaId,Term}]-> Term
	end.

get_spa_exp_info(Level)->
	case ets:lookup(?SPA_EXP,Level) of
		[]->[];
		[{Level,Term}]-> Term
	end.

get_spa_id(Info)->
	erlang:element(#spa_option.spa_id, Info).

get_spa_duration(Info)->
	erlang:element(#spa_option.duration, Info).

get_spa_instance_proto(Info)->
	erlang:element(#spa_option.instance_proto, Info).

get_spa_looptime(Info)->
	erlang:element(#spa_option.looptime, Info).

get_spa_chopping(Info)->
	erlang:element(#spa_option.chopping, Info).

get_spa_swimming(Info)->
	erlang:element(#spa_option.swimming, Info).

get_spa_vip_exp_addition(Info)->
	erlang:element(#spa_option.vip_exp_addition, Info).

get_spa_vip_op_addition(Info)->
	erlang:element(#spa_option.vip_op_addition, Info).

get_spa_exp_level(Info)->
	erlang:element(#spa_exp.level, Info).

get_spa_exp_exp(Info)->
	erlang:element(#spa_exp.exp, Info).

get_spa_exp_soulpower(Info)->
	erlang:element(#spa_exp.soulpower, Info).

get_spa_exp_chopping_self(Info)->
	erlang:element(#spa_exp.chopping_self, Info).

get_spa_exp_chopping_be(Info)->
	erlang:element(#spa_exp.chopping_be, Info).

get_spa_exp_swimming_self(Info)->
	erlang:element(#spa_exp.swimming_self, Info).

get_spa_exp_swimming_be(Info)->
	erlang:element(#spa_exp.swimming_be, Info).

%%	
%% Local Functions
%%

