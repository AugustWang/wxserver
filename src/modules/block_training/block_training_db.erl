%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(block_training_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-define(BLOCK_TRAINING_ETS,block_training_ets).
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
	db_tools:create_table_disc(block_training, record_info(fields,block_training), [], set).		

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{block_training,proto}].

create()->
	ets:new(?BLOCK_TRAINING_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(block_training, ?BLOCK_TRAINING_ETS,#block_training.level).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_block_training(Level)->
	case ets:lookup(?BLOCK_TRAINING_ETS,Level) of
		[]-> [];
		[{_,TrianingInfo}]-> TrianingInfo
	end.

get_level(TrianingInfo)->
	element(#block_training.level,TrianingInfo).
get_growth(TrianingInfo)->
	element(#block_training.growth,TrianingInfo).
get_duration(TrianingInfo)->
	element(#block_training.duration,TrianingInfo).
get_spgrowth(TrianingInfo)->
	element(#block_training.spgrowth,TrianingInfo).
