%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(lottery_db).

-include("lottery_def.hrl").


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(LOTTERY_DROP_ETS,'$lottery_drop_ets$').
-define(LOTTERY_COUNTS_ETS,'$lottery_levelcount_ets$').

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-export([get_level_count/1,get_drop_by_level_and_class/2]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(lottery_droplist, record_info(fields,lottery_droplist), [], set),
	db_tools:create_table_disc(role_lottery, record_info(fields,role_lottery), [], set),
	db_tools:create_table_disc(lottery_counts, record_info(fields,lottery_counts), [], set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_lottery, RoleId).

tables_info()->
	[{lottery_droplist,proto},{lottery_counts,proto},{role_lottery,disc}].

create()->
	ets:new(?LOTTERY_DROP_ETS,[set,named_table]),
	ets:new(?LOTTERY_COUNTS_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(lottery_droplist, ?LOTTERY_DROP_ETS,[#lottery_droplist.class,#lottery_droplist.level]),
	db_operater_mod:init_ets(lottery_counts, ?LOTTERY_COUNTS_ETS,#lottery_counts.level).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_level_count(Level)->
	case ets:lookup(?LOTTERY_COUNTS_ETS,Level) of
		[{_,Term}]->
			erlang:element(#lottery_counts.count,Term);
		[]->
			0
	end.

get_drop_by_level_and_class(Level,ClassId)->
	case ets:lookup(?LOTTERY_DROP_ETS, {Level,ClassId}) of
		[]->[];
		[{_,Term}]-> erlang:element(#lottery_droplist.ruleids,Term)
	end.

