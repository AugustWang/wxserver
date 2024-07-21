%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pets_db).

-include("pet_def.hrl").

-compile(export_all).

-export([get_pet_ownerid/1,get_pet_ownerid_in_db_node/1]).
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

create_mnesia_split_table(pets,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,pets),[masterid],set).

delete_role_from_db(RoleId)->
	TableName = db_split:get_owner_table(pets, RoleId),
	dal:delete_index_rpc(TableName, RoleId,#pets.masterid).

tables_info()->
	[{pets,disc_split}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_pet_ownerid(PetId)->
	case node_util:get_dbnode() of
		undefined-> [];
		DbNode-> case rpc:call(DbNode, ?MODULE, get_pet_ownerid_in_db_node, [PetId]) of
					 {badrpc,_Reason}-> [];
					 RoleId->
						 RoleId
				 end
	end.	
	
get_pet_ownerid_in_db_node(PetId)->	
	Tables = db_split:get_table_names(pets),
	lists:foldl(fun(Table,OwnerId)-> 
				case OwnerId of
					[]->
						case dal:read(Table,PetId) of
							{ok,[R]}-> get_masterid(R);
							{ok,[]}->[];
							_->
								[]
						end;
					_->
						OwnerId
				end
		end,[], Tables).
	

load_pets_info(Ownerguid)->
	TableName = db_split:get_owner_table(pets, Ownerguid),
	case dal:read_index_rpc(TableName, Ownerguid, #pets.masterid) of
		{ok,PetsRecordList}-> PetsRecordList;
		{failed,_Reason}-> [];
		{failed,badrpc,_Reason}-> []
	end.

get_pets_info(RoleId,PetId)->
	TableName = db_split:get_owner_table(pets, RoleId),
	case dal:read_rpc(TableName,PetId) of
		{ok,[R]}-> R;
		{ok,[]}->[];
		{failed,badrpc,_Reason}->{TableName,PetId,[]};
		{failed,_Reason}-> {TableName,PetId,[]}
	end.

save_pet_info(RoleId,Petid,Protoid,Petinfo,Skillinfo,EquipInfo,Ext1,Ext2)->
	TableName = db_split:get_owner_table(pets, RoleId),
	dmp_op:sync_write(RoleId,{TableName,Petid,RoleId,Protoid,Petinfo,Skillinfo,EquipInfo,Ext1,Ext2}).

async_save_pet_info(RoleId,Petid,Protoid,Petinfo,Skillinfo,EquipInfo,Ext1,Ext2)->
	TableName = db_split:get_owner_table(pets, RoleId),
	dmp_op:async_write(RoleId,{TableName,Petid,RoleId,Protoid,Petinfo,Skillinfo,EquipInfo,Ext1,Ext2}).

del_pet(Id,OwnerID)->	
	TableName = db_split:get_owner_table(pets, OwnerID),
	dmp_op:sync_delete(Id,TableName, Id).

get_petid(PetDbInfo)->
	erlang:element(#pets.petid, PetDbInfo).
	
get_masterid(PetDbInfo)->
	erlang:element(#pets.masterid, PetDbInfo).

get_protoid(PetDbInfo)->
	erlang:element(#pets.protoid, PetDbInfo).

get_petinfo(PetDbInfo)->
	erlang:element(#pets.petinfo, PetDbInfo).

get_equipinfo(PetDbInfo)->
	erlang:element(#pets.equipinfo, PetDbInfo).

get_skillinfo(PetDbInfo)->
	erlang:element(#pets.skillinfo, PetDbInfo).
