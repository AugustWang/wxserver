%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: KONGJUN
%% Created: 2010-7-9
%% Description: TODO: Add description to transport_db
-module(transport_db).

%%
%% Include files
%%
-include_lib("stdlib/include/qlc.hrl").
-include("mnesia_table_def.hrl").


-define(TRANSPORT_TABLE_ETS, ets_transports_info).
-define(TRANSPORT_CHANNEL_TABLE_ETS, ets_transport_channel_info).
-define(NPC_TRANSPORT_LIST_TABLE_ETS, ets_npc_transports_list_info).

%%npc_trans:


%%
%% Exported Functions
%%
-export([get_transport_info/2,get_transport_coord/1,get_transport_transid/1,get_transport_description/1]).


%%transport_channel:
-export([get_transport_channel_info/1,
		 get_channel_id/1,get_channel_mapid/1,get_channel_coord/1,get_channel_type/1,get_channel_level/1,
	get_channel_items/1,get_channel_money/1,get_channel_viplevel/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,init/0,create/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?TRANSPORT_TABLE_ETS, [set,named_table]),
	ets:new(?TRANSPORT_CHANNEL_TABLE_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(transports, ?TRANSPORT_TABLE_ETS,[#transports.mapid,#transports.tranportid]),
	db_operater_mod:init_ets(transport_channel, ?TRANSPORT_CHANNEL_TABLE_ETS,#transport_channel.id).

create_mnesia_table(disc)->
	db_tools:create_table_disc(transports,record_info(fields,transports),[],bag),
	db_tools:create_table_disc(transport_channel,record_info(fields,transport_channel),[],set). %set

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{transports,proto},{transport_channel,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_transport_info(MapId, TranportId)->
	case ets:lookup(?TRANSPORT_TABLE_ETS,{MapId, TranportId}) of
		[]->
			[];
		[{_, TransInfo}] ->
			TransInfo
	end.	

get_transport_coord(TransInfo)->
	erlang:element(#transports.coord,TransInfo).

get_transport_transid(TransInfo)->
	erlang:element(#transports.transid,TransInfo).
  
get_transport_description(TransInfo)->
	erlang:element(#transports.description,TransInfo).

get_transport_channel_info(Id)->
	case ets:lookup(?TRANSPORT_CHANNEL_TABLE_ETS,Id) of
		[]->
			[];
		[{Id,Values}] ->
			Values
	end.	

get_channel_id(Npc_Trans_Info)->
	element(#transport_channel.id,Npc_Trans_Info).

get_channel_mapid(Npc_Trans_Info)->
	element(#transport_channel.mapid,Npc_Trans_Info).

get_channel_coord(Npc_Trans_Info)->
	element(#transport_channel.coord,Npc_Trans_Info).

get_channel_type(Npc_Trans_Info)->
	element(#transport_channel.type,Npc_Trans_Info).

get_channel_level(Npc_Trans_Info)->
	element(#transport_channel.level,Npc_Trans_Info).

get_channel_items(Npc_Trans_Info)->
	element(#transport_channel.items,Npc_Trans_Info).

get_channel_money(Npc_Trans_Info)->
	element(#transport_channel.money,Npc_Trans_Info).

get_channel_viplevel(Npc_Trans_Info)->
	element(#transport_channel.viplevel,Npc_Trans_Info).
