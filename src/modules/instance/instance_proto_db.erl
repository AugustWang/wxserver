%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------

-module(instance_proto_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-define(INSTANCE_PROTO_NAME,ets_instance_proto).
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
	db_tools:create_table_disc(instance_proto, record_info(fields,instance_proto), [], set).	

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{instance_proto,proto}].

create()->
	ets:new(?INSTANCE_PROTO_NAME, [set,named_table]).

init()->
	db_operater_mod:init_ets(instance_proto, ?INSTANCE_PROTO_NAME,#instance_proto.protoid).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(ProtoId)->
	case ets:lookup(?INSTANCE_PROTO_NAME,ProtoId) of
		[]->[];
		[{ProtoId,Term}]-> Term
	end.

get_protoid(ProtoInfo)->
	erlang:element(#instance_proto.protoid, ProtoInfo).

get_type(ProtoInfo)->
	erlang:element(#instance_proto.type, ProtoInfo).

get_create_leadertag(ProtoInfo)->
	erlang:element(#instance_proto.create_leadertag, ProtoInfo).

get_create_item(ProtoInfo)->
	erlang:element(#instance_proto.create_item, ProtoInfo).

get_level(ProtoInfo)->
	erlang:element(#instance_proto.level, ProtoInfo).

get_membernum(ProtoInfo)->
	erlang:element(#instance_proto.membernum, ProtoInfo).

get_dateline(ProtoInfo)->
	erlang:element(#instance_proto.dateline, ProtoInfo).

get_quests(ProtoInfo)->
	erlang:element(#instance_proto.quests, ProtoInfo).

get_item_need(ProtoInfo)->
	erlang:element(#instance_proto.item_need, ProtoInfo).

get_can_direct_exit(ProtoInfo)->
	erlang:element(#instance_proto.can_direct_exit, ProtoInfo).

get_datetimes(ProtoInfo)->
	erlang:element(#instance_proto.datetimes, ProtoInfo).

get_restrict_items(ProtoInfo)->
	erlang:element(#instance_proto.restrict_items, ProtoInfo).

get_level_mapid(ProtoInfo)->
	erlang:element(#instance_proto.level_mapid, ProtoInfo).

get_duration_time(ProtoInfo)->
	erlang:element(#instance_proto.duration_time, ProtoInfo).

get_nextproto(ProtoInfo)->
	erlang:element(#instance_proto.nextproto, ProtoInfo).
	
