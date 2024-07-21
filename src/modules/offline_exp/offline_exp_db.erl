%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-6-2
%% Description: TODO: Add description to offline_exp_db
-module(offline_exp_db).

%%
%% Include files
%%
-include("offline_exp_define.hrl").
%%
%% Exported Functions
%%
-export([
		 get_offline_exp_info/1,
		 get_all_offline_everquests_exp_info/0,
		 get_offline_exp_rolelog/1,
		 sync_update_offline_exp_rolelog/2]).

-export([get_offline_exp_level/1,
		 get_offline_exp_hourexp/1,
		 get_offline_exp_exchange/1,
		 get_offline_everquests_id/1,
		 get_offline_everquests_questsids/1,
		 get_offline_everquests_levelrange/1,
		 get_offline_everquests_exp/1,
		 get_offline_everquests_addcount/1,
		 get_offline_log/1,
		 get_offline_everquests_max_exp/1
		 ]).

-define(OFFLINE_EXP_ETS,'offline_exp_ets').
-define(OFFLINE_EVERQUESTS_EXP_ETS,'offline_everquests_exp_ets').

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
	db_tools:create_table_disc(offline_exp,record_info(fields,offline_exp),[],set),
	db_tools:create_table_disc(offline_everquests_exp,record_info(fields,offline_everquests_exp),[],set),
	db_tools:create_table_disc(offline_exp_rolelog,record_info(fields,offline_exp_rolelog),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{offline_exp,proto},{offline_everquests_exp,proto},{offline_exp_rolelog,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(offline_exp_rolelog, RoleId).

create()->
	ets:new(?OFFLINE_EXP_ETS, [set,named_table]),
	ets:new(?OFFLINE_EVERQUESTS_EXP_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(offline_exp, ?OFFLINE_EXP_ETS,#offline_exp.level),
	db_operater_mod:init_ets(offline_everquests_exp, ?OFFLINE_EVERQUESTS_EXP_ETS,#offline_everquests_exp.id).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_offline_exp_info(Level)->
	case ets:lookup(?OFFLINE_EXP_ETS,Level) of
		[]-> [];
		[{_,Term}]-> Term
	end.

get_all_offline_everquests_exp_info()->
	ets:tab2list(?OFFLINE_EVERQUESTS_EXP_ETS).

get_offline_exp_rolelog(RoleId)->
	case dal:read_rpc(offline_exp_rolelog,RoleId) of
		{ok,[]}-> {ok,[]};
		{ok,[Result]}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_offline_exp_rolelog failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_offline_exp_rolelog failed :~p~n",[Reason])
	end.

sync_update_offline_exp_rolelog(RoleId,Term)->
	Object = util:term_to_record(Term,offline_exp_rolelog),
	dmp_op:sync_write(RoleId,Object).

get_offline_exp_level(Info)->
	erlang:element(#offline_exp.level, Info).

get_offline_exp_hourexp(Info)->
	erlang:element(#offline_exp.hourexp, Info).

get_offline_exp_exchange(Info)->
	erlang:element(#offline_exp.exchange, Info).

get_offline_everquests_id(Info)->
	erlang:element(#offline_everquests_exp.id, Info).

get_offline_everquests_exp(Info)->
	erlang:element(#offline_everquests_exp.exp, Info).

get_offline_everquests_addcount(Info)->
	erlang:element(#offline_everquests_exp.addcount, Info).

get_offline_everquests_max_exp(Info)->
	erlang:element(#offline_everquests_exp.max, Info).

get_offline_everquests_questsids(Info)->
	erlang:element(#offline_everquests_exp.quest_ids, Info).

get_offline_everquests_levelrange(Info)->
	erlang:element(#offline_everquests_exp.level_range, Info).

get_offline_log(Info)->
	erlang:element(#offline_exp_rolelog.offline_log, Info).

%%
%% Local Functions
%%

