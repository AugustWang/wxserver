%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-4-14
%% Description: TODO: Add description to congratulations_db
-module(congratulations_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
%%
%% Exported Functions
%%
-export([get_congratulations_info/1,get_role_congratu_log/1,sync_update_role_congratu_log_to_mnesia/2]).

-export([get_coninfo_level/1,
		 get_coninfo_notice_count/1,
		 get_coninfo_becount/1,
		 get_coninfo_bereward/1,
		 get_coninfo_reward/1,
		 get_coninfo_range/1
		]).

-define(CONGRATULATIONS_ETS,'congratulations_ets').
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
	db_tools:create_table_disc(congratulations,record_info(fields,congratulations),[],set),
	db_tools:create_table_disc(role_congratu_log,record_info(fields,role_congratu_log),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{congratulations,proto},{role_congratu_log,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_congratu_log, RoleId).

create()->
	ets:new(?CONGRATULATIONS_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(congratulations, ?CONGRATULATIONS_ETS,#congratulations.level).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_congratulations_info(Level)->
	case ets:lookup(?CONGRATULATIONS_ETS,Level) of
		[{_,Term}]-> Term;
		_-> []
	end.

get_role_congratu_log(RoleId)->
	case dal:read_rpc(role_congratu_log,RoleId) of
		{ok,[]}-> {ok,[]};
		{ok,Result}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_role_congratu_log failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_role_congratu_log failed :~p~n",[Reason])
	end.

sync_update_role_congratu_log_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,role_congratu_log),
	dmp_op:sync_write(RoleId,Object).

%%
%% Local Functions
%%
get_coninfo_level(Info)->
	erlang:element(#congratulations.level, Info).

get_coninfo_range(Info)->
	erlang:element(#congratulations.notice_range, Info).

get_coninfo_becount(Info)->
	erlang:element(#congratulations.becount, Info).

get_coninfo_bereward(Info)->
	erlang:element(#congratulations.bereward, Info).

get_coninfo_reward(Info)->
	erlang:element(#congratulations.reward, Info).

get_coninfo_notice_count(Info)->
	erlang:element(#congratulations.notice_count, Info).
