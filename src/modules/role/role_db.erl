%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-15
%% Description: TODO: Add description to role_db
-module(role_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include_lib("stdlib/include/qlc.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").

-define(CLASS_BASE_ATTRIB_ETS,class_base_ets).
-define(ROLE_TABLE_BASE,roleattr).

%%
%% Exported Functions
%%
-export([get_role_info/1,get_account/1,put_account/2,get_role_list_by_account/1,get_role_list_by_account_rpc/1,
		 get_roleid/1,
		 get_name/1,name_can_change/1,get_roleid_by_name/1,get_roleid_by_name_rpc/1,put_name/2,get_sex/1,put_sex/2,
		 get_class/1,put_class/2,get_level/1,put_level/2,get_exp/1,put_exp/2,get_hp/1,put_hp/2,
		 get_mana/1,put_mana/2,
		 get_currencygold/1,put_currencygold/2,
		 get_gold_from_account/1,put_gold_to_account/2,
		 get_currencygift/1,put_currencygift/2,
		 get_boundsilver/1,put_boundsilver/2,
		 get_silver/1,put_silver/2,
		 get_mapid/1,put_mapid/2,get_coord/1,put_coord/2,
		 get_bufflist/1,put_bufflist/2,
		 get_training/1,put_training/2,
		 get_packagesize/1,put_packagesize/2,
		 get_groupid/1,put_groupid/2,
		 get_guildid/1,put_guildid/2,
		 get_pvpinfo/1,put_pvpinfo/2,
		 get_pet/1,put_pet/2,
		 get_honor/1,put_honor/2,
		 get_offline/1,put_offline/2,
		 get_soulpower/1,put_soulpower/2,
		 get_stallname/1,put_stallname/2,
		 async_write_roleattr/1,
		 update_role_pos/3,
		 get_fighting_force/1,
		 get_rolename_by_id_rpc/1,get_rolename_by_id/1]).

-export([get_class_base/2,get_class_strength/1,get_class_agile/1,get_class_intelligence/1,get_class_stamina/1,
		 get_class_hprecover/1,get_class_hprecoverinterval/1,get_class_mprecover/1,get_class_mprecoverinterval/1,
		 get_class_commoncool/1,get_class_power/1,get_class_magicdefense/1,get_class_rangedefense/1,get_class_meleedefense/1]).


-export([get_account_username/1,get_account_roleids/1,get_account_gold/1]).


-export([flush_role/1]).

-export([create_role/7,create_role_rpc/7]).

-export([start/0,init/0,create/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?CLASS_BASE_ATTRIB_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(classbase, ?CLASS_BASE_ATTRIB_ETS,[#classbase.classid,#classbase.level]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(classbase,record_info(fields,classbase),[],bag),
	db_tools:create_table_disc(idmax, record_info(fields,idmax), [], set),
	db_tools:create_table_disc(account, record_info(fields,account), [], set).

create_mnesia_split_table(roleattr,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,roleattr),[account,name],set).

delete_role_from_db(RoleId)->
	RoleTable = db_split:get_owner_table(?ROLE_TABLE_BASE, RoleId),
	case dal:read_rpc(RoleTable, RoleId) of
		{ok,[RoleAttr]}->
			AccountName = role_db:get_account(RoleAttr),
			case dal:read(account,AccountName) of
				{ok,[AllAccountRole]}->
					AllRoleId = element(#account.roleids,AllAccountRole),
					case AllRoleId -- [RoleId] of
						[]->
							delete_account_from_db(AccountName);
						NewRoleIds->
							dal:write_rpc(AllAccountRole#account{roleids = NewRoleIds})	
					end;
				_->
					slogger:msg("delelte_role_from_db not find account ~p ~n",[AccountName])
			end;
		_->
			nothing
	end,
	dal:delete_rpc(RoleTable, RoleId).
	
tables_info()->
	[{roleattr,disc_split},{classbase,proto},{idmax,disc},{account,disc}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delete_account_from_db(AccountName)->
	dal:delete_rpc(account, AccountName),
	fatigue_db:on_delete_account(AccountName).

%% -----------------------------------------------------------------------------------------
%%  For role attrib
%% -----------------------------------------------------------------------------------------

get_role_info(RoleId)->
	RoleTable = db_split:get_owner_table(?ROLE_TABLE_BASE, RoleId),
	case dal:read_rpc(RoleTable,RoleId) of
		{ok,[R]}->R;
		_->[]
	end.

update_role_pos(RoleId,MapId,Pos)->
	case get_role_info(RoleId) of
		[]->
			error;
		RoleInfo->
				RoleInfo1 = put_mapid(RoleInfo,MapId),
				RoleIno2 = put_coord(RoleInfo1,Pos),
				dal:write_rpc(RoleIno2)
	end.

get_account(RoleInfo)->
	element(#roleattr.account,RoleInfo).

put_account(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.account, RoleInfo, NewValue).

get_rolename(RoleNameTuple)->
	case RoleNameTuple of
		{visitor,RoleName}-> RoleName;
		_->RoleNameTuple
	end.
	
get_role_list_by_account_rpc(AccountName)->
	case node_util:get_dbnode() of
		undefined-> [];
		DbNode-> case rpc:call(DbNode, ?MODULE, get_role_list_by_account, [AccountName]) of
					 {badrpc,_Reason}-> [];
					 {failed,_Reason}-> [];
					 {ok,Result}-> Result;
					 _Any->[]
				 end
	end.	

get_role_list_by_account(AccountName)->
	case dal:read(account,AccountName) of
		{ok,[AllAccountRole]}->
			AllRoleId = element(#account.roleids,AllAccountRole),
			AllAttrs = 
			lists:foldl(fun(RoleId,Acc)->
				RoleTable = db_split:get_owner_table(?ROLE_TABLE_BASE, RoleId),			
				case dal:read(RoleTable, RoleId) of
					{ok,[RoleAttr]}->
						RoleName = get_rolename(element(#roleattr.name,RoleAttr)),
						LastMapId = element(#roleattr.mapid,RoleAttr),
						Classtype = element(#roleattr.class,RoleAttr),
						Gender = element(#roleattr.sex,RoleAttr),
						Level = element(#roleattr.level,RoleAttr),
						Acc ++ [pb_util:make_role_info(RoleId, RoleName, LastMapId,Classtype,Gender,Level)];
					_->
						Acc
				end end,[],AllRoleId),
			{ok,AllAttrs};
		_->
			{ok,[]}
	end.


get_roleid_by_name_rpc(Name)->
	case node_util:get_dbnode() of
		undefined-> [];
		DbNode-> case rpc:call(DbNode, ?MODULE, get_roleid_by_name, [Name]) of
					 {badrpc,_Reason}-> [];
					 {failed,_Reason}-> [];
					 {ok,Result}-> Result;
					 _Any->[]
				 end
	end.	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%add by wb 20130503
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_rolename_by_id_rpc(Id)->
	case node_util:get_mapnode() of
		undefined->[];
		MapNode-> case rpc:call(MapNode,?MODULE,get_rolename_by_id,[Id]) of
					  {badrpc,_Reason}->[badrpc];
					  {failed,_Reason}->[failed];
					  {ok,Result}->Result;
					  _Any->[any]
				  end
	end.

get_rolename_by_id(RoleId)->
	RoleInfo=get_role_info(RoleId),
	{ok,get_name(RoleInfo)}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% get_roleid_by_name() -> [integer] | []
%%
get_roleid_by_name(BinName) when is_binary(BinName)->
	BinName2 = {visitor,BinName},
	Tables = db_split:get_table_names(?ROLE_TABLE_BASE),
	SelTab = fun(TableName)->
				mnesia:index_read(TableName, BinName, #roleattr.name)
			end,
	SelTab2 = fun(TableName)->
				mnesia:index_read(TableName, BinName2, #roleattr.name)
			end,
	RoleIds = fun(E)->
					  element(#roleattr.roleid,E)
			  end,
	Q = fun()->
				lists:flatmap(fun(T)-> Rs = SelTab(T) ++ SelTab2(T),
									   lists:map(RoleIds, Rs)
							   end,Tables) 
		end,
	{_, ARoleIds} = mnesia:transaction(Q),
	{ok,ARoleIds};
	
get_roleid_by_name(Name) when is_list(Name)->
	BinName = list_to_binary(Name),
	get_roleid_by_name(BinName);
get_roleid_by_name(Name) when is_tuple(Name)->
	{visitor,VName} = Name,
	get_roleid_by_name(VName).


get_roleid(RoleInfo)->
	element(#roleattr.roleid,RoleInfo).

get_name(RoleInfo)->
	RoleName = element(#roleattr.name,RoleInfo),
	get_rolename(RoleName).

name_can_change(RoleInfo)->
	RoleName = element(#roleattr.name,RoleInfo),
	case RoleName of
		{visitor,_}-> true;
		_-> false
	end.

put_name(RoleInfo,NewValue) when  is_list(NewValue)->
	erlang:setelement(#roleattr.name, RoleInfo, list_to_binary(NewValue));
put_name(RoleInfo,NewValue) when  is_binary(NewValue)->
	erlang:setelement(#roleattr.name, RoleInfo, NewValue).
get_sex(RoleInfo)->
	element(#roleattr.sex,RoleInfo).
put_sex(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.sex, RoleInfo, NewValue).
get_class(RoleInfo)->
	element(#roleattr.class,RoleInfo).
put_class(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.class, RoleInfo, NewValue).
get_level(RoleInfo)->
	element(#roleattr.level,RoleInfo).
put_level(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.level, RoleInfo, NewValue).
get_exp(RoleInfo)->
	element(#roleattr.exp,RoleInfo).
put_exp(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.exp, RoleInfo, NewValue).
get_hp(RoleInfo)->
	element(#roleattr.hp,RoleInfo).
put_hp(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.hp, RoleInfo, NewValue).
get_mana(RoleInfo)->
	element(#roleattr.mana,RoleInfo).
put_mana(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.mana, RoleInfo, NewValue).
get_currencygold(RoleInfo)->
	element(#roleattr.currencygold,RoleInfo).
put_currencygold(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.currencygold, RoleInfo, NewValue).
get_gold_from_account(AccountName)->
	case dal:read_rpc(account,AccountName) of
		{ok,[Account]} ->
			element(#account.gold,Account);
		_ ->0
	end.

%%寰楀埌涓婃鐧诲綍鏃堕棿<鏋皯娣诲姞>
get_last_login_time_from_account(AccountName)->
	case dal:read_rpc(account,AccountName) of
		{ok,[Account]}->
			element(#account.last_login_time,Account);
		_->
			0
	end.
put_gold_to_account(AccountName,Gold)->
	case dal:read_rpc(account,AccountName) of
		{ok,[Account]} ->
			NewAccount = Account#account{gold=Gold},
			dal:async_write_rpc(NewAccount);
		_ ->0
	end.
get_currencygift(RoleInfo)->
	element(#roleattr.currencygift,RoleInfo).
put_currencygift(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.currencygift, RoleInfo, NewValue).
get_boundsilver(RoleInfo)->
	element(#roleattr.boundsilver,RoleInfo).
put_boundsilver(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.boundsilver, RoleInfo, NewValue).
get_silver(RoleInfo)->
	element(#roleattr.silver,RoleInfo).
put_silver(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.silver, RoleInfo, NewValue).
get_mapid(RoleInfo)->
	element(#roleattr.mapid,RoleInfo).
put_mapid(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.mapid, RoleInfo, NewValue).
get_coord(RoleInfo)->
	element(#roleattr.coord,RoleInfo).
put_coord(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.coord, RoleInfo, NewValue).
get_bufflist(RoleInfo)->
	element(#roleattr.bufflist,RoleInfo).
put_bufflist(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.bufflist, RoleInfo, NewValue).
get_training(RoleInfo)->
	element(#roleattr.training,RoleInfo).
put_training(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.training, RoleInfo, NewValue).
get_packagesize(RoleInfo)->
	element(#roleattr.packagesize,RoleInfo).
put_packagesize(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.packagesize, RoleInfo, NewValue).
get_groupid(RoleInfo)->
	element(#roleattr.groupid,RoleInfo).
put_groupid(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.groupid, RoleInfo, NewValue).
get_honor(RoleInfo)->
	element(#roleattr.honor,RoleInfo).
put_honor(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.honor, RoleInfo, NewValue).
get_fighting_force(RoleInfo)->
	element(#roleattr.fightforce,RoleInfo).
put_fighting_force(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.fightforce, RoleInfo, NewValue).
up_level_role(RoleId)->
	RoleInfo = get_role_info(RoleId),
	Level = get_level(RoleInfo),
	RoleInfo1=put_level(RoleInfo,Level+1),
	Exp = role_level_db:get_level_experience(Level+1),
	RoleInfo2=put_exp(RoleInfo1,Exp),
	flush_role(RoleInfo2).
put_guildid(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.guildid, RoleInfo, NewValue).
get_guildid(RoleInfo)->
	element(#roleattr.guildid,RoleInfo).
put_pvpinfo(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.pvpinfo, RoleInfo, NewValue).
get_pvpinfo(RoleInfo)->
	element(#roleattr.pvpinfo,RoleInfo).
put_pet(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.pet, RoleInfo, NewValue).
get_pet(RoleInfo)->
	element(#roleattr.pet,RoleInfo).
put_offline(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.offline, RoleInfo, NewValue).
get_offline(RoleInfo)->
	element(#roleattr.offline,RoleInfo).
put_soulpower(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.soulpower, RoleInfo, NewValue).
get_soulpower(RoleInfo)->
	element(#roleattr.soulpower,RoleInfo).
get_stallname(RoleInfo)->
	element(#roleattr.stallname,RoleInfo).
put_stallname(RoleInfo,NewValue)->
	erlang:setelement(#roleattr.stallname, RoleInfo, NewValue).

%%save
async_write_roleattr(RoleInfo)->
	{RoleId,Account,Name,Sex,Class,Level,Exp,Hp,Mana,Gold,Gift,Silver,BoundSilver,Mapid,Pos,Bufflist,Debufflist,Packagesize,Finished_quest,Guildid,Maxpet,Pet,Offline,SoulPower,StallName,Honor,FightForce} = RoleInfo, 
	TableName = db_split:get_owner_table(?ROLE_TABLE_BASE, RoleId),
	dmp_op:async_write(RoleId,{TableName,RoleId,Account,Name,Sex,Class,Level,Exp,Hp,Mana,Gold,Gift,Silver,BoundSilver,Mapid,Pos,Bufflist,Debufflist,Packagesize,Finished_quest,Guildid,Maxpet,Pet,Offline,SoulPower,StallName,Honor,FightForce}).

%% -----------------------------------------------------------------------------------------
%%  For account
%% -----------------------------------------------------------------------------------------
get_account_username(RoleInfo)->
	element(#account.username,RoleInfo).

get_account_roleids(RoleInfo)->
	element(#account.roleids,RoleInfo).

get_account_gold(RoleInfo)->
	element(#account.gold,RoleInfo).

%% -----------------------------------------------------------------------------------------
%%  For class base attrib
%% -----------------------------------------------------------------------------------------
get_class_base(ClassId,Level)->
	case ets:lookup(?CLASS_BASE_ATTRIB_ETS, {ClassId,Level}) of
		[]->[];
		[{{_,_},Value}] -> Value 
	end.
get_class_strength(ClassBase)->
	element(#classbase.strength,ClassBase).
get_class_agile(ClassBase)->
	element(#classbase.agile,ClassBase).
get_class_intelligence(ClassBase)->
	element(#classbase.intelligence,ClassBase).
get_class_stamina(ClassBase)->
	element(#classbase.stamina,ClassBase).
get_class_power(ClassBase)->
	element(#classbase.power,ClassBase).
get_class_magicdefense(ClassBase)->
	element(#classbase.magicdefense,ClassBase).
get_class_rangedefense(ClassBase)->
	element(#classbase.rangedefense,ClassBase).
get_class_meleedefense(ClassBase)->
	element(#classbase.meleedefense,ClassBase).
get_class_hprecover(ClassBase)->
	element(#classbase.hprecover,ClassBase).
get_class_hprecoverinterval(ClassBase)->
	element(#classbase.hprecoverinterval,ClassBase).
get_class_mprecover(ClassBase)->
	element(#classbase.mprecover,ClassBase).
get_class_mprecoverinterval(ClassBase)->
	element(#classbase.mprecoverinterval,ClassBase).
get_class_commoncool(ClassBase)->
	element(#classbase.commoncool,ClassBase).
flush_role(RoleInfo)->
	try
		dal:write_rpc(RoleInfo)
	catch
		_:_-> slogger:msg("fulsh role ~p failed ~n",[RoleInfo])
	end.
create_role_rpc(AccountId,AccountName,RoleName,Gender,ClassId,CreateIp,ServerId)->
	case node_util:get_dbnode() of
		undefined-> [];
		DbNode-> 
				io:format("role_db:create_role_rpc AccountName ~p DbNode ~p ~n",[DbNode,AccountName]),
				case rpc:call(DbNode, ?MODULE, create_role, [AccountId,AccountName,RoleName,Gender,ClassId,CreateIp,ServerId]) of
					 {failed,Reason}-> {failed,Reason};
					 {ok,Result}-> {ok,Result};
					 _Any->{failed,?ERR_CODE_CREATE_ROLE_INTERL}
				 end
	end.	
create_role(AccountId,AccountName,RoleName,Gender,ClassId,CreateIp,ServerId)->
	io:format("role_db:create_role AccountName ~p Node ~p ~n",[AccountName,node()]),
	case get_roleid_by_name(RoleName) of
		{ok,[]}->
			CreateMod = case env:get(create_role_base, []) of
							[]-> role_create_deploy;
							Mod -> Mod
						end,
			CreateMod:create(AccountId,AccountName,RoleName,Gender,ClassId,CreateIp,ServerId);
		{ok,_}-> {failed,?ERR_CODE_ROLENAME_EXISTED}
	end.
