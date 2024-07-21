%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-1-7
%% Description: TODO: Add description to vip_db
-module(vip_db).

%% 
%% define
%% 
-define(VIP_LEVEL_ETS,vip_level_table).
%%
%% Include files
%%
-include("mnesia_table_def.hrl").

%%
%% Exported Functions
%%
-export([
		 async_update_vip_role_to_mnesia/2,sync_update_vip_role_to_mnesia/2,delete_vip_role/1,
		 async_update_role_sum_gold_to_mnesia/2,sync_update_role_sum_gold_to_mnesia/2,
		 async_update_role_login_bonus_to_mnesia/2,sync_update_role_login_bonus_to_mnesia/2,
		 get_vip_level_info/1,get_vip_role/1,get_role_sum_gold/1,get_role_login_bonus/1,
		 get_all_vip_role/0,get_sumgold_from_suminfo/1]).

-export([get_vip_level/1]).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

-define(CHAT_FORMAT_ETS,'$chat_format_ets$').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(vip_level, record_info(fields,vip_level), [], set),
	db_tools:create_table_disc(vip_role, record_info(fields,vip_role), [], set),
	db_tools:create_table_disc(role_sum_gold, record_info(fields,role_sum_gold), [], set),
	db_tools:create_table_disc(role_login_bonus, record_info(fields,role_login_bonus), [], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{vip_level,proto},{vip_role,disc},{role_sum_gold,disc},{role_login_bonus,disc}].

delete_role_from_db(RoleId)->
	delete_vip_role(RoleId),
	dal:delete_rpc(role_sum_gold,RoleId),
	dal:delete_rpc(role_login_bonus,RoleId).

create()->
	ets:new(?VIP_LEVEL_ETS,[set,public,named_table]).

init()->
	db_operater_mod:init_ets(vip_level, ?VIP_LEVEL_ETS,#vip_level.level).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

async_update_vip_role_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,vip_role),
	dmp_op:async_write(RoleId,Object).

delete_vip_role(RoleId)->
	dal:delete_rpc(vip_role, RoleId).

sync_update_vip_role_to_mnesia(_RoleId,Term)->
	Object = util:term_to_record(Term,vip_role),
	dal:write_rpc(Object).

async_update_role_sum_gold_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,role_sum_gold),
	dmp_op:async_write(RoleId,Object).

sync_update_role_sum_gold_to_mnesia(_RoleId,Term)->
	Object = util:term_to_record(Term,role_sum_gold),
	dal:write_rpc(Object).

async_update_role_login_bonus_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,role_login_bonus),
	dmp_op:async_write(RoleId,Object).

sync_update_role_login_bonus_to_mnesia(_RoleId,Term)->
	Object = util:term_to_record(Term,role_login_bonus),
	dal:write_rpc(Object).

get_vip_level_info(Level)->
	case ets:lookup(?VIP_LEVEL_ETS, Level) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_vip_role(RoleId)->
	case dal:read_rpc(vip_role,RoleId) of
		{ok,[]}-> {ok,[]};
		{ok,[Result]}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_vip_role failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_vip_role failed :~p~n",[Reason])
	end.

get_all_vip_role()->
	case dal:read_rpc(vip_role) of
		{ok,[]}-> {ok,[]};
		{ok,Result}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_all_vip_role failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_all_vip_role failed :~p~n",[Reason])
	end.

get_vip_level(VipInfo)->
	erlang:element(#vip_role.level,VipInfo).

get_role_sum_gold(RoleId)->
	case dal:read_rpc(role_sum_gold,RoleId) of
		{ok,[]}-> {ok,[]};
		{ok,[Result]}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_role_sum_gold failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_role_sum_gold failed :~p~n",[Reason])
	end.

get_sumgold_from_suminfo(RoleSumInfo)->
	erlang:element(#role_sum_gold.sum_gold,RoleSumInfo).

get_role_login_bonus(RoleId)->
	case dal:read_rpc(role_login_bonus,RoleId) of
		{ok,[]}-> {ok,[]};
		{ok,[Result]}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_role_login_bonus failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_role_login_bonus failed :~p~n",[Reason])
	end.
%%
%% Local Functions
%%

