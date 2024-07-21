%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-1-7
%% Description: TODO: Add description to loop_instance_db
-module(loop_instance_db).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

%%
%% Include files
%%
-include("loop_instance_def.hrl").

-define(LOOP_INSTANCE_PROTO_TABLE,loop_instance_proto_ets).
-define(LOOP_INSTANCE_TABLE,loop_instance_ets).

%%
%% Exported Functions
%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(loop_instance_proto, record_info(fields,loop_instance_proto), [], set),
	db_tools:create_table_disc(loop_instance, record_info(fields,loop_instance), [], set),
	db_tools:create_table_disc(role_loop_instance, record_info(fields,role_loop_instance), [], set),
	db_tools:create_table_disc(loop_instance_record, record_info(fields,loop_instance_record), [], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{loop_instance_proto,proto},{loop_instance,proto},{role_loop_instance,disc},{loop_instance_record,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_loop_instance, RoleId).

create()->
	ets:new(?LOOP_INSTANCE_PROTO_TABLE,[set,public,named_table]),
	ets:new(?LOOP_INSTANCE_TABLE,[set,public,named_table]).

init()->
	db_operater_mod:init_ets(loop_instance_proto, ?LOOP_INSTANCE_PROTO_TABLE,#loop_instance_proto.layer),
	db_operater_mod:init_ets(loop_instance, ?LOOP_INSTANCE_TABLE,#loop_instance.id).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
async_update_role_loop_instance_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,role_loop_instance),
	dmp_op:async_write(RoleId,Object).

sync_update_role_loop_instance_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,role_loop_instance),
	dmp_op:sync_write(RoleId,Object).


async_update_loop_instance_record_to_mnesia(Layer,Term)->
	Object = util:term_to_record(Term,loop_instance_record),
	dmp_op:async_write(Layer,Object).

sync_update_loop_instance_record_to_mnesia(Layer,Term)->
	Object = util:term_to_record(Term,loop_instance_record),
	dmp_op:sync_write(Layer,Object).

get_role_loop_instance(RoleId)->
	case dal:read_rpc(role_loop_instance,RoleId) of
		{ok,[]}-> {ok,[]};
		{ok,[Result]}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_role_loop_instance failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_role_loop_instance failed :~p~n",[Reason])
	end.

get_loop_instance_record(Layer)->
	case dal:read_rpc(loop_instance_record,Layer) of
		{ok,[]}-> {ok,[]};
		{ok,[Result]}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_loop_instance_record failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_loop_instance_record failed :~p~n",[Reason])
	end.	


get_loop_instance_info(Id)->
	case ets:lookup(?LOOP_INSTANCE_TABLE, Id) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_times(Info)->
	erlang:element(#loop_instance.times, Info).

get_members(Info)->
	erlang:element(#loop_instance.members, Info).

get_levellimit(Info)->
	erlang:element(#loop_instance.levellimit, Info).

get_loop_instance_proto_info(Layer)->
	case ets:lookup(?LOOP_INSTANCE_PROTO_TABLE, Layer) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_exp(Info)->
	erlang:element(#loop_instance_proto.exp, Info).

get_money(Info)->
	erlang:element(#loop_instance_proto.money, Info).

get_bonus(Info)->
	erlang:element(#loop_instance_proto.bonus, Info).

get_soulpower(Info)->
	erlang:element(#loop_instance_proto.soulpower, Info).

get_instance_proto(Info)->
	erlang:element(#loop_instance_proto.instance_proto, Info).

get_monsters(Info)->
	erlang:element(#loop_instance_proto.monsters, Info).

get_type(Info)->
	erlang:element(#loop_instance_proto.type, Info).

get_limittime(Info)->
	erlang:element(#loop_instance_proto.time, Info).

get_targetnpclist(Info)->
	erlang:element(#loop_instance_proto.targetnpclist, Info).

get_bornpos(Info)->
	erlang:element(#loop_instance_proto.bornpos, Info).
%%
%% Local Functions
%%