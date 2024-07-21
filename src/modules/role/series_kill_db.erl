%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(series_kill_db).
%% 
%% define
%% 
-define(SERIES_KILL_ETS,series_kill_table).
%%
%% Include files
%%
-include("mnesia_table_def.hrl").

%%
%% Exported Functions
%%
-export([
		get_series_kill_info/1,
		get_level/1,
		get_kill_num/1,
		get_effect_time/1,
		get_buff_info/1,
		get_npc_level_diff/1,
		get_instance_power_effect/1]).

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
	db_tools:create_table_disc(series_kill,record_info(fields,series_kill),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{series_kill,proto}].

delete_role_from_db(_RoleId)->
	nothing.

create()->
	ets:new(?SERIES_KILL_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(series_kill, ?SERIES_KILL_ETS,#series_kill.level).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% recode max series kill for every role
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%async_update_series_kill_recode_to_mnesia(RoleId,Term)->
%%	Object = util:term_to_record(Term,series_kill_recod),
%%	dmp_op:async_write(RoleId,Object).

%%sync_update_series_kill_recode_to_mnesia(RoleId,Term)->
%%	Object = util:term_to_record(Term,series_kill_recod),
%%	dmp_op:sync_write(RoleId,Object).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get role series kill info.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%get_role_series_kill_info(RoleId)->
%%	case dal:read_rpc(series_kill_recod,RoleId) of
%%		{ok,[]}-> {ok,[]};
%%		{ok,[Result]}-> {ok,Result};
%%		{failed,badrpc,Reason}-> slogger:msg("get_role_series_kill_info failed ~p:~p~n",[badrpc,Reason]);
%%		{failed,Reason}-> slogger:msg("get_role_series_kill_info failed :~p~n",[Reason])
%%	end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get series kill config
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_series_kill_info(Level)->
	case ets:lookup(?SERIES_KILL_ETS, Level) of
			[]->[];
            [{Level,Term}]-> Term
	end.

get_level(Series_Kill_Info)->
	erlang:element(#series_kill.level, Series_Kill_Info).

get_kill_num(Series_Kill_Info)->
	erlang:element(#series_kill.kill_num, Series_Kill_Info).

get_effect_time(Series_Kill_Info)->	
	erlang:element(#series_kill.effect_time, Series_Kill_Info).

get_buff_info(Series_Kill_Info)->
	erlang:element(#series_kill.buff_info, Series_Kill_Info).

get_npc_level_diff(Series_Kill_Info)->
	erlang:element(#series_kill.npc_level_diff, Series_Kill_Info).

get_instance_power_effect(Series_Kill_Info)->
	erlang:element(#series_kill.instance_power_effect, Series_Kill_Info).
