%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: yanzengyan
%% Created: 2012-8-3
%% Description: TODO: Add description to instance_quality_db
-module(instance_quality_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-define(INSTANCE_QUALITY_PROTO_NAME,ets_instance_quality_proto).
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
	db_tools:create_table_disc(instance_quality_proto, record_info(fields,instance_quality_proto), [], set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(RoleId)->
	nothing.

tables_info()->
	[{instance_quality_proto,proto}].

create()->
	ets:new(?INSTANCE_QUALITY_PROTO_NAME, [set,named_table]).

init()->
	db_operater_mod:init_ets(instance_quality_proto, ?INSTANCE_QUALITY_PROTO_NAME,#instance_quality_proto.protoid).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(ProtoId)->
	case ets:lookup(?INSTANCE_QUALITY_PROTO_NAME,ProtoId) of
		[]->[];
		[{ProtoId,Term}]-> Term
	end.

get_protoid(ProtoInfo)->
	erlang:element(#instance_quality_proto.protoid, ProtoInfo).

get_npclist(ProtoInfo)->
	erlang:element(#instance_quality_proto.npclist, ProtoInfo).

get_freetime(ProtoInfo)->
	erlang:element(#instance_quality_proto.freetime, ProtoInfo).

get_itemtype(ProtoInfo)->
	erlang:element(#instance_quality_proto.itemtype, ProtoInfo).

get_gold(ProtoInfo)->
	erlang:element(#instance_quality_proto.gold, ProtoInfo).

get_rate(ProtoInfo)->
	erlang:element(#instance_quality_proto.rate, ProtoInfo).

get_addfac(ProtoInfo)->
	erlang:element(#instance_quality_proto.addfac, ProtoInfo).
