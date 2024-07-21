%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------

-module(battlefield_proto_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-define(BATTLE_PROTO_NAME,ets_battlefield_proto).
-define(TANGLE_REWARD_INFO_ETS,tangle_reward_info_ets).
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
	db_tools:create_table_disc(battlefield_proto,record_info(fields,battlefield_proto),[],set),
	db_tools:create_table_disc(tangle_reward_info,record_info(fields,tangle_reward_info),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{battlefield_proto,proto},{tangle_reward_info,proto}].

create()->
	ets:new(?BATTLE_PROTO_NAME, [set,named_table]),
	ets:new(?TANGLE_REWARD_INFO_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(battlefield_proto, ?BATTLE_PROTO_NAME, #battlefield_proto.protoid),
	db_operater_mod:init_ets(tangle_reward_info, ?TANGLE_REWARD_INFO_ETS, #tangle_reward_info.rankedge).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(ProtoId)->
	case ets:lookup(?BATTLE_PROTO_NAME,ProtoId) of
		[]->[];
		[{ProtoId,Term}]-> Term
	end.

get_protoid(ProtoInfo)->
	erlang:element(#battlefield_proto.protoid, ProtoInfo).

get_args(ProtoInfo)->
	erlang:element(#battlefield_proto.args, ProtoInfo).

get_start_line(ProtoInfo)->
	erlang:element(#battlefield_proto.start_line, ProtoInfo).

get_duration(ProtoInfo)->
	erlang:element(#battlefield_proto.duration, ProtoInfo).

get_instance_proto(ProtoInfo)->
	erlang:element(#battlefield_proto.instance_proto, ProtoInfo).

get_respawn_buff(ProtoInfo)->
	erlang:element(#battlefield_proto.respawn_buff, ProtoInfo).
