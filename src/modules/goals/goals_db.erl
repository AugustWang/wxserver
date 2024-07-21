%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-7-18
%% Description: TODO: Add description to goals_db
-module(goals_db).

%%
%% Include files
%%
-define(GOALS_ETS,goals_table).
-include("goals_define.hrl").
%%
%% Exported Functions
%%
-export([
		 get_all_goals/0,get_goals_info/1,create_role_goals/1,
		 get_role_goals/1,sync_update_goals_role_to_mnesia/1]).
-export([
		 get_goals_id/1,
		 get_goals_level/1,
		 get_goals_part/1,
		 get_goals_require/1,
		 get_goals_bonus/1,
		 get_goals_type/1,
		 get_goals_script/1
		 ]).

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
	db_tools:create_table_disc(goals, record_info(fields,goals), [], set),
	db_tools:create_table_disc(goals_role, record_info(fields,goals_role), [], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{goals,proto},{goals_role,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(goals_role,RoleId).

create()->
	ets:new(?GOALS_ETS,[set,public,named_table]).

init()->
	db_operater_mod:init_ets(goals, ?GOALS_ETS, #goals.goalsid).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_all_goals()->
	case ets:tab2list(?GOALS_ETS) of
		[]->[];
		OriInfos-> lists:map(fun({_,Info})->Info end,OriInfos) 
	end.

get_goals_info(Id)->
	case ets:lookup(?GOALS_ETS, Id) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_role_goals(RoleId)->
	case dal:read_rpc(goals_role,RoleId) of
		{ok,[]}-> {ok,[]};
		{ok,Result}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_role_goals failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_role_goals failed :~p~n",[Reason])
	end.

create_role_goals(RoleId)->
	Object = {goals_role,RoleId,[]},
	dal:write_rpc(Object).

sync_update_goals_role_to_mnesia(Term)->
	Object = util:term_to_record(Term, goals_role),
	dal:write_rpc(Object).

%%
%% Local Functions
%%
get_goals_id(Info)->
	erlang:element(#goals.goalsid, Info).
get_goals_level(Info)->
	erlang:element(#goals.level, Info).
get_goals_part(Info)->
	erlang:element(#goals.part, Info).
get_goals_require(Info)->
	erlang:element(#goals.require, Info).
get_goals_bonus(Info)->
	erlang:element(#goals.bonus, Info).
get_goals_type(Info)->
	erlang:element(#goals.type, Info).
get_goals_script(Info)->
	erlang:element(#goals.script, Info).
