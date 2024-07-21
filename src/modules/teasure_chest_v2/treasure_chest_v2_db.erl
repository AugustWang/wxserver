%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: ChenXiaowei
%% Created: 2011-7-23
%% Description: TODO: Add description to treasure_chest_v2_db
-module(treasure_chest_v2_db).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("treasure_chest_def.hrl").
-define(TRESURE_CHEST_RATE,'$treasure_chest_rate$').
-define(TRESURE_CHEST_DROP,'$treasure_chest_drop$').
-define(TREASURE_CHEST_TIMES,'$treasure_chest_times$').
-define(TREASURE_CHEST_TYPE,'$treasure_chest_type$').
%%
%% Exported Functions
%%
-export([get_drops/3,get_rate/2,get_need_consume_gold/1,get_protoid/1]).

%%
%% API Functions
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,init/0,create/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?TRESURE_CHEST_DROP, [set,named_table]),
	ets:new(?TRESURE_CHEST_RATE, [set,named_table]),
	ets:new(?TREASURE_CHEST_TIMES,[set,named_table]),
	ets:new(?TREASURE_CHEST_TYPE,[set,named_table]).

init()->
	db_operater_mod:init_ets(treasure_chest_drop, ?TRESURE_CHEST_DROP,#treasure_chest_drop.proto_level1_level2_class),
	db_operater_mod:init_ets(treasure_chest_rate, ?TRESURE_CHEST_RATE,#treasure_chest_rate.proto_count),
	db_operater_mod:init_ets(treasure_chest_times, ?TREASURE_CHEST_TIMES,#treasure_chest_times.times),
	db_operater_mod:init_ets(treasure_chest_type, ?TREASURE_CHEST_TYPE,#treasure_chest_type.type).

create_mnesia_table(disc)->
	db_tools:create_table_disc(treasure_chest_rate,record_info(fields,treasure_chest_rate),[],set),
	db_tools:create_table_disc(treasure_chest_drop,record_info(fields,treasure_chest_drop),[],set),
	db_tools:create_table_disc(treasure_chest_times,record_info(fields,treasure_chest_times),[],set),
	db_tools:create_table_disc(treasure_chest_type,record_info(fields,treasure_chest_type),[],set).
	
create_mnesia_split_table(role_treasure_storage,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,role_treasure_storage),[],set).

delete_role_from_db(RoleId)->
	OwnerTable = db_split:get_owner_table(role_treasure_storage, RoleId),
	dal:delete_rpc(OwnerTable, RoleId).

tables_info()->
	[{treasure_chest_drop,proto},{treasure_chest_rate,proto},{treasure_chest_times,proto},{treasure_chest_type,proto},{role_treasure_storage,disc_split}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_drops(ItemProto,Level,Class)->
	ets:foldl(fun({Key,DropInfo},Acc)->
					  case Acc of
						  []->
							  {ProtoId,{Level1,Level2},ClassM}=Key,
							  Res = case ClassM of
										0->  
											(ProtoId =:=ItemProto )
												and ( Level >= Level1 )
												and (Level=<Level2 );
										_-> (ProtoId =:=ItemProto)
												and ( Level >= Level1 )
												and (Level=<Level2 )
												and (ClassM =:=Class)
									end,
							  if Res->erlang:element(#treasure_chest_drop.drops, DropInfo);
								 true-> []
							  end;
						  _->Acc
					  end
			  end, [], ?TRESURE_CHEST_DROP).

get_rate(ItemProto,Count)->
	case ets:lookup(?TRESURE_CHEST_RATE, {ItemProto,Count}) of
		[]-> slogger:msg("treasure chest exception itemproto,count have no rate!~n"),0;
		[{_,RateInfo}|_T]->erlang:element(#treasure_chest_rate.rate_base, RateInfo)
	end.
%% 
%%arg:treasure_chest_times
%%return:GoldList =[treasure_chest_correspond_Gold] 
%% 
get_need_consume_gold(Times)->
	case ets:lookup(?TREASURE_CHEST_TIMES,Times) of
		[]->
			slogger:msg("treasure_chest_v2_db: get_need_consume_gold(Times): error ~n"),
			[];
		[{_,Term}]->
			erlang:element(#treasure_chest_times.consume_gold_list,Term)
	end.
%% 
%%arg:treasure_chest_type
%%return:[BingProtoId,NonBingProtoId]
%% 
get_protoid(Type)->
	case ets:lookup(?TREASURE_CHEST_TYPE,Type) of
		[]->
			slogger:msg("treasure_chest_v2_db: get_protoid(Type) error~n"),
			[];
		[{_,Term}]->
			erlang:element(#treasure_chest_type.protoid_list,Term)
	end.
	
