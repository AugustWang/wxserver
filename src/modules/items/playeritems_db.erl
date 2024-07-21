%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%%goodsclass
%%
-module(playeritems_db).
%% 
%% define
%% 
-include("mnesia_table_def.hrl").
-include("slot_define.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% 
%% export
%%  

-export([get_id/1,
		 get_ownerguid/1,
		 get_entry/1,
		 get_enchantments/1,
		 get_count/1,
		 get_slot/1,
		 set_count/2,
		 set_slot/2,
		 get_isbond/1,
		 get_sockets/1,
		 get_duration/1,
		 get_cooldowninfo/1,
		 get_overdueinfo/1,
		 load_role_equipments/1,
		 get_enchant/1]).

-export([async_add_playeritems/2,add_playeritems/1,add_playeritems/2,add_playeritems/12,add_playeritems/13,del_playeritems/2,del_playeritems/3,async_del_playeritems/3,async_add_playeritems/13]).

-export([loadrole/1,load_item_info/2]).

-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%						 behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	nothing.

create_mnesia_split_table(playeritems,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,playeritems),[ownerguid],set).

delete_role_from_db(RoleId)->
	TableName = db_split:get_owner_table(playeritems, RoleId),
	dal:delete_index_rpc(TableName, RoleId, #playeritems.ownerguid).

tables_info()->
	[{playeritems,disc_split}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loadrole(Ownerguid)->
	TableName = db_split:get_owner_table(playeritems, Ownerguid),
	case dal:read_index_rpc(TableName, Ownerguid, #playeritems.ownerguid) of
		{ok,ItemsRecordList}-> ItemsRecordList;
		{failed,_Reason}-> [];
		{failed,badrpc,_Reason}-> []
	end.

load_role_equipments(Ownerguid)->
	TableName = db_split:get_owner_table(playeritems, Ownerguid),
	case node_util:get_dbnode() of
		undefined-> slogger:msg("load_role_equipments get_dbnode undefined ~n"),[];
		DbNode->
			case rpc:call(DbNode, ?MODULE, load_role_equipments_in_db_node, [Ownerguid,TableName]) of
				{badrpc,Reason}->
					slogger:msg("load_role_equipments badrpc Reason ~p ~n",[Reason]),[];
				Result->
					Result
			end
	end.
	
load_role_equipments_in_db_node(Ownerguid,TableName)->	
	case dal:read_index(TableName, Ownerguid, #playeritems.ownerguid) of
		{ok,ItemsRecordList}->
			lists:filter(fun(Playeriteminfo)-> 
							Slot = get_slot(Playeriteminfo),
							(Slot > ?SLOT_BODY_INDEX ) and  (Slot =< ?SLOT_BODY_ENDEX)
						end, ItemsRecordList);
		_->
			[]
	end.
		
%%	F = fun()->
		%%{id,ownerguid,entry,enchantments,count,slot,isbond,sockets,duration,cooldowninfo,enchant,overdue}
%%		MatchHead = {'_','_',Ownerguid,'_','_','_','$1','_','_','_','_','_','_'},
%%		Guard = [{'>', '$1', ?SLOT_BODY_INDEX},{'=<','$1',?SLOT_BODY_ENDEX}],
%%		Result = ['$_'],
%%		mnesia:select(TableName,[{MatchHead,Guard, Result}])
%%	end,
%%	case dal:run_transaction_rpc(F) of
%%		{ok,Result}->
%%			Result;
%%		_->
%%			[]
%%	end.

load_item_info(PlayerItemId,Ownerguid)->
	TableName = db_split:get_owner_table(playeritems, Ownerguid),
	case dal:read_rpc(TableName, PlayerItemId) of
		{ok,ItemsRecordList}-> ItemsRecordList;
		{failed,_Reason}-> [];
		{failed,badrpc,_Reason}-> []
	end.


get_id(Playeriteminfo)->
	element(#playeritems.id,Playeriteminfo).

get_ownerguid(Playeriteminfo)->
	element(#playeritems.ownerguid,Playeriteminfo).

get_entry(Playeriteminfo)->
	element(#playeritems.entry,Playeriteminfo).

get_enchantments(Playeriteminfo)->
	element(#playeritems.enchantments,Playeriteminfo).

set_count(Count,Playeriteminfo)->
	setelement(#playeritems.count,Playeriteminfo,Count).

set_slot(Slot,Playeriteminfo)->
	setelement(#playeritems.slot,Playeriteminfo,Slot).

get_count(Playeriteminfo)->
	element(#playeritems.count,Playeriteminfo).

get_slot(Playeriteminfo)->
	element(#playeritems.slot,Playeriteminfo).

get_isbond(Playeriteminfo)->
	element(#playeritems.isbond,Playeriteminfo).

get_sockets(Playeriteminfo)->
	element(#playeritems.sockets,Playeriteminfo).

get_duration(Playeriteminfo)->
	element(#playeritems.duration,Playeriteminfo).

get_cooldowninfo(Playeriteminfo)->
	element(#playeritems.cooldowninfo,Playeriteminfo).

get_enchant(Playeriteminfo)->
	element(#playeritems.enchant,Playeriteminfo).

get_overdueinfo(Playeriteminfo)->
	element(#playeritems.overdueinfo,Playeriteminfo).

add_playeritems(PlayerItem)->
	#playeritems{
		id = Itemid,
		ownerguid = Ownerguid,
		entry = Entry,
		enchantments = Enchantments,
		count = Count,
		slot = Slot,
		isbond = Isbonded,
		sockets = Sockets,
		cooldowninfo = CoolDownInfo,
		duration = Duration,
		enchant = Enchant,
		overdueinfo = OverDueInfo} = PlayerItem,
	TableName = db_split:get_owner_table(playeritems, Ownerguid),
	PlayerItemDB = {TableName,Itemid,Ownerguid,Entry,Enchantments,Count,Slot,Isbonded,Sockets,Duration,CoolDownInfo,Enchant,OverDueInfo},
	dmp_op:sync_write(Itemid,PlayerItemDB).

add_playeritems(TableName,PlayerItem)->
	#playeritems{
		id = Itemid,
		ownerguid = Ownerguid,
		entry = Entry,
		enchantments = Enchantments,
		count = Count,
		slot = Slot,
		isbond = Isbonded,
		sockets = Sockets,
		cooldowninfo = CoolDownInfo,
		duration = Duration,
		enchant = Enchant,
		overdueinfo = OverDueInfo} = PlayerItem,
	PlayerItemDB = {TableName,Itemid,Ownerguid,Entry,Enchantments,Count,Slot,Isbonded,Sockets,Duration,CoolDownInfo,Enchant,OverDueInfo},
	dmp_op:sync_write(Itemid,PlayerItemDB).

async_add_playeritems(TableName,PlayerItem)->
	#playeritems{
		id = Itemid,
		ownerguid = Ownerguid,
		entry = Entry,
		enchantments = Enchantments,
		count = Count,
		slot = Slot,
		isbond = Isbonded,
		sockets = Sockets,
		cooldowninfo = CoolDownInfo,
		duration = Duration,
		enchant = Enchant,
		overdueinfo = OverDueInfo} = PlayerItem,
	PlayerItemDB = {TableName,Itemid,Ownerguid,Entry,Enchantments,Count,Slot,Isbonded,Sockets,Duration,CoolDownInfo,Enchant,OverDueInfo},
	dmp_op:async_write(Itemid,PlayerItemDB).

add_playeritems(Id,OwnerID,Entry,Enchantments,Count,Slot,Isbonded,Sockets,Duration,Cooldowninfo,Enchant,OverDueInfo)->
	TableName = db_split:get_owner_table(playeritems, OwnerID),
	PlayerItem = {TableName,Id,OwnerID,Entry,Enchantments,Count,Slot,Isbonded,Sockets,Duration,Cooldowninfo,Enchant,OverDueInfo},
	dmp_op:sync_write(Id,PlayerItem).

del_playeritems(Id,OwnerID)->	
	TableName = db_split:get_owner_table(playeritems, OwnerID),
	dmp_op:sync_delete(Id,TableName, Id).

add_playeritems(TableName,Id,OwnerID,Entry,Enchantments,Count,Slot,Isbonded,Sockets,Duration,Cooldowninfo,Enchant,OverDueInfo)->
	PlayerItem = {TableName,Id,OwnerID,Entry,Enchantments,Count,Slot,Isbonded,Sockets,Duration,Cooldowninfo,Enchant,OverDueInfo},
	dmp_op:sync_write(Id,PlayerItem).

del_playeritems(TableName,Id,OwnerID)->	
	dmp_op:sync_delete(Id,TableName, Id).

async_add_playeritems(TableName,Id,OwnerID,Entry,Enchantments,Count,Slot,Isbonded,Sockets,Duration,Cooldowninfo,Enchant,OverDueInfo)->
	PlayerItem = {TableName,Id,OwnerID,Entry,Enchantments,Count,Slot,Isbonded,Sockets,Duration,Cooldowninfo,Enchant,OverDueInfo},
	dmp_op:async_write(Id,PlayerItem).
  
async_del_playeritems(TableName,Id,OwnerID)->	
	dmp_op:async_delete(Id,TableName, Id).

