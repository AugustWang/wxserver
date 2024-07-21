%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-12-27
%% Description: TODO: Add description to loop_tower_db
-module(loop_tower_db).
%% 
%% define
%% 
-define(LOOP_TOWER_ETS,loop_tower_table).
%%
%% Include files
%%
-include("mnesia_table_def.hrl").
%%
%% Exported Functions
%%
-export([
		 async_update_role_loop_tower_to_mnesia/2,sync_update_role_loop_tower_to_mnesia/2,
		 async_update_loop_tower_instance_to_mnesia/2,sync_update_loop_tower_instance_to_mnesia/2,
		 get_role_loop_tower/1,get_loop_tower_info/1,get_loop_tower_instance_info/1,
		 get_loop_tower_instance_info_by_roleid/1,delete_loop_tower_instance_by_roleid/1,
		 get_loop_tower_instance/0,clear_loop_tower_instance_rpc/0
		 ]).

-export([
		 get_layer_by_info/1,
		 get_consum_money_by_info/1,
		 get_enter_prop_by_info/1,
		 get_convey_prop_by_info/1,
		 get_exp_by_info/1,
		 get_bonus_by_info/1,
		 get_instance_id_by_info/1,
		 get_week_bonus_by_info/1,
		 get_monsters_by_info/1,
		 get_loop_prop_by_info/1
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
	db_tools:create_table_disc(loop_tower, record_info(fields,loop_tower), [], set),
	db_tools:create_table_disc(role_loop_tower, record_info(fields,role_loop_tower), [], set),
	db_tools:create_table_disc(loop_tower_instance, record_info(fields,loop_tower_instance), [roleid], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{loop_tower,proto},{loop_tower_instance,disc},{role_loop_tower,disc}].

delete_role_from_db(_)->
	nothing.

create()->
	ets:new(?LOOP_TOWER_ETS,[set,public,named_table]).

init()->
	db_operater_mod:init_ets(loop_tower, ?LOOP_TOWER_ETS,#loop_tower.layer).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
async_update_role_loop_tower_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,role_loop_tower),
	dmp_op:async_write(RoleId,Object).

sync_update_role_loop_tower_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,role_loop_tower),
	dmp_op:sync_write(RoleId,Object).

async_update_loop_tower_instance_to_mnesia(Layers,Term)->
	Object = util:term_to_record(Term,loop_tower_instance),
	dmp_op:async_write(Layers,Object).

sync_update_loop_tower_instance_to_mnesia(Layers,Term)->
	Object = util:term_to_record(Term,loop_tower_instance),
	dmp_op:sync_write(Layers,Object).

get_role_loop_tower(RoleId)->
	case dal:read_rpc(role_loop_tower,RoleId) of
		{ok,[]}-> {ok,[]};
		{ok,[Result]}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_role_loop_tower failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_role_loop_tower failed :~p~n",[Reason])
	end.

get_loop_tower_instance_info(Layer)->
	case dal:read_rpc(loop_tower_instance,Layer) of
		{ok,[]}-> [];
		{ok,[Result]}-> Result;
		{failed,badrpc,Reason}-> slogger:msg("get_loop_tower_instance_info failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_loop_tower_instance_info failed :~p~n",[Reason])
	end.

get_loop_tower_instance()->
	case dal:read_rpc(loop_tower_instance) of
		{ok,Result}-> Result;
		{failed,badrpc,Reason}-> slogger:msg("get_loop_tower_instance failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_loop_tower_instance failed :~p~n",[Reason])
	end.

clear_loop_tower_instance_rpc()->
	dal:clear_table_rpc(loop_tower_instance).

get_loop_tower_instance_info_by_roleid(RoleId)->
	case dal:read_index_rpc(loop_tower_instance, RoleId, #loop_tower_instance.roleid) of
		{ok,[]}-> [];
		{ok,[Result]}-> Result;
		{failed,badrpc,Reason}-> slogger:msg("get_loop_tower_instance_info_by_roleid failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_loop_tower_instance_info_by_roleid failed :~p~n",[Reason])
	end.

delete_loop_tower_instance_by_roleid(Object)->
	dal:delete_object_rpc(Object).

get_loop_tower_info(Layer)->
	case ets:lookup(?LOOP_TOWER_ETS, Layer) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_layer_by_info(Info)->
	erlang:element(#loop_tower.layer, Info).
get_consum_money_by_info(Info)->
	erlang:element(#loop_tower.consum_money, Info).
get_enter_prop_by_info(Info)->
	erlang:element(#loop_tower.enter_prop, Info).
get_convey_prop_by_info(Info)->
	erlang:element(#loop_tower.convey_prop, Info).
get_exp_by_info(Info)->
	erlang:element(#loop_tower.exp, Info).
get_bonus_by_info(Info)->
	erlang:element(#loop_tower.bonus, Info).
get_instance_id_by_info(Info)->
	erlang:element(#loop_tower.instance_id, Info).
get_week_bonus_by_info(Info)->
	erlang:element(#loop_tower.week_bonus, Info).
get_monsters_by_info(Info)->
	erlang:element(#loop_tower.monsters, Info).
get_loop_prop_by_info(Info)->
	erlang:element(#loop_tower.loop_prop, Info).
%%
%% Local Functions
%%

