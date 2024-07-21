%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-8-31
%% Description: TODO: Add description to guild_proto_db
-module(guild_proto_db).

%%
%% Include files
%%
-include("guild_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
-export([validauthority/1,
		 get_authority_info/1,
		 get_authority_name/1,
		 get_authority_disabled/1]).


-export([validauthgroup/1,
		 get_authgroup_info/1,
		 get_authgroup_name/1,
		 get_authgroup_level/1,
		 get_authgroup_authids/1,
		 ishighergroup/2]).


-export([validfacility/1,
		 get_facility_info/2,
		 get_facility_name/1,
		 get_facility_level/1,
		 get_facility_rate/1,
		 get_facility_check_script/1,
		 get_facility_require_resource/1,
		 get_facility_require_time/1,
		 get_guild_treasureitem_info/1,
		 get_guild_treasure_info/0]).
-export([get_noidel_guilditem_by_guildid/1,update_guilditem_info/1]).
 

-define(GUILD_AUTHORITIES_ETS,'guild_authorities_ets').
-define(GUILD_AUTH_GROUP_ETS,'guild_auth_groups_ets').
-define(GUILD_FACILITIES_ETS,'guild_facilities_ets').

-define(GUILD_SETTING_ETS,'guild_setting_ets').
-define(GUILD_SHOP_ETS,'guild_shop_ets').
-define(GUILD_SHOP_ITEMS_ETS,'guild_shop_items_ets').
-define(GUILD_TREASURE_ETS,'guild_treasure_ets').
-define(GUILD_TREASURE_ITEMS_ETS,'guild_treasure_items_ets').
-define(GUILD_MONSTER_ETS,'guild_moster_ets').
-define(GUILD_PACKAGE_ETS,'guild_package_ets').
-define(GUILD_PACKAGE_APPLY,'guild_package_apply_ets').
-define(GUILID_PACLAGE_IDELITEM,0).%%帮会物品闲置

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
	ets:new(?GUILD_AUTHORITIES_ETS, [set,named_table]),
	ets:new(?GUILD_AUTH_GROUP_ETS, [set,named_table]),
	ets:new(?GUILD_FACILITIES_ETS, [set,named_table]),
	ets:new(?GUILD_SETTING_ETS, [set,named_table]),
	ets:new(?GUILD_SHOP_ETS, [set,named_table]),
	ets:new(?GUILD_SHOP_ITEMS_ETS, [set,named_table]),
	ets:new(?GUILD_TREASURE_ETS, [set,named_table]),
	ets:new(?GUILD_MONSTER_ETS, [set,named_table]),
	ets:new(?GUILD_TREASURE_ITEMS_ETS, [set,named_table]),
	ets:new(?GUILD_PACKAGE_ETS, [set,named_table,public]),%%帮会仓库《枫少》
	ets:new(?GUILD_PACKAGE_APPLY, [bag,named_table,public]).

init()->
	db_operater_mod:init_ets(guild_auth_groups, ?GUILD_AUTH_GROUP_ETS,#guild_auth_groups.id),
	db_operater_mod:init_ets(guild_authorities, ?GUILD_AUTHORITIES_ETS,#guild_authorities.id),
	db_operater_mod:init_ets(guild_facilities, ?GUILD_FACILITIES_ETS,[#guild_facilities.id,#guild_facilities.level]),
	db_operater_mod:init_ets(guild_setting, ?GUILD_SETTING_ETS,#guild_setting.id),
	db_operater_mod:init_ets(guild_shop, ?GUILD_SHOP_ETS,#guild_shop.level),
	db_operater_mod:init_ets(guild_shop_items, ?GUILD_SHOP_ITEMS_ETS,#guild_shop_items.id),
	db_operater_mod:init_ets(guild_treasure, ?GUILD_TREASURE_ETS,#guild_treasure.level),
	db_operater_mod:init_ets(guild_monster_proto, ?GUILD_MONSTER_ETS,#guild_monster_proto.monsterid),
	db_operater_mod:init_ets(guild_treasure_items, ?GUILD_TREASURE_ITEMS_ETS,#guild_treasure_items.id),
	db_operater_mod:init_ets(guilditems, ?GUILD_PACKAGE_ETS,#guilditems.id),
	db_operater_mod:init_ets(guildpackage_apply, ?GUILD_PACKAGE_APPLY,#guildpackage_apply.guildid).



create_mnesia_table(disc)->
	db_tools:create_table_disc(guild_authorities, record_info(fields,guild_authorities),[],set),
	db_tools:create_table_disc(guild_auth_groups, record_info(fields,guild_auth_groups), [], bag),
	db_tools:create_table_disc(guild_facilities, record_info(fields,guild_facilities), [], bag),
	db_tools:create_table_disc(guild_baseinfo, record_info(fields,guild_baseinfo), [], set),
	db_tools:create_table_disc(guild_monster, record_info(fields,guild_monster), [], set),
	db_tools:create_table_disc(guild_member, record_info(fields,guild_member), [guildid,memberid], set),
	db_tools:create_table_disc(guild_log, record_info(fields,guild_log), [guildid,time], set),
	db_tools:create_table_disc(guild_events, record_info(fields,guild_events), [guildid,time], set),
	db_tools:create_table_disc(guild_facility_info, record_info(fields,guild_facility_info), [guildid,facilityid], set),
	db_tools:create_table_disc(guild_leave_member,record_info(fields,guild_leave_member),[],set),
	db_tools:create_table_disc(guild_setting,record_info(fields,guild_setting),[],set),
	db_tools:create_table_disc(guild_shop,record_info(fields,guild_shop),[],set),
	db_tools:create_table_disc(guild_shop_items,record_info(fields,guild_shop_items),[],set),
	db_tools:create_table_disc(guild_treasure,record_info(fields,guild_treasure),[],set),
	db_tools:create_table_disc(guild_treasure_items,record_info(fields,guild_treasure_items),[],set),
	db_tools:create_table_disc(guild_member_shop,record_info(fields,guild_member_shop),[guildid,memberid],set),
	db_tools:create_table_disc(guild_member_treasure,record_info(fields,guild_member_treasure),[guildid,memberid],set),
	db_tools:create_table_disc(guild_treasure_price,record_info(fields,guild_treasure_price),[guildid],set),
	db_tools:create_table_disc(guild_monster_proto,record_info(fields,guild_monster_proto),[],set),
	db_tools:create_table_disc(guild_impeach_info,record_info(fields,guild_impeach_info),[],set),
	db_tools:create_table_disc(guild_battle_score,record_info(fields,guild_battle_score),[],set),
	db_tools:create_table_disc(guild_right_limit,record_info(fields,guild_right_limit),[],set),
	db_tools:create_table_disc(guilditems,record_info(fields,guilditems),[],set),			%%帮会仓库
	db_tools:create_table_disc(guildpackage_apply, record_info(fields,guildpackage_apply),[],bag).%%帮会仓库物品申请记录

create_mnesia_split_table(guilditems,TrueTabName)->
	nothing.

delete_role_from_db(RoleId)->
	guild_spawn_db:del_member_from_guild(RoleId),
	guild_spawn_db:delete_member_shopinfo(RoleId),
	guild_spawn_db:delete_member_treasureinfo(RoleId),
	case guild_spawn_db:get_member_leave_info(RoleId ) of
		[]->					
			nothing;
		LastLeaveInfo->
			guild_spawn_db:del_member_leave_info(LastLeaveInfo)
	end.

tables_info()->
	[
	{guild_leave_member,disc},
	{guild_authorities,proto},
	{guild_auth_groups,proto},
	{guild_facilities,proto},
	{guild_setting,proto},
	{guild_shop,proto},
	{guild_shop_items,proto},
	{guild_treasure,proto},
	{guild_treasure_items,proto},
	{guild_monster_proto,proto},
	{guild_member_shop,disc},
	{guild_member_treasure,disc},
	{guild_treasure_price,disc},
	{guild_baseinfo,disc},
	{guild_monster,disc},
	{guild_member,disc},
	{guild_log,disc},
	{guild_events,disc},													
	{guild_facility_info,disc},
	{guild_battle_score,disc},
	{guild_right_limit,disc},
	{guild_impeach_info,disc}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

validauthority(AuthorityId) when is_integer(AuthorityId) ->
	case ets:lookup(?GUILD_AUTHORITIES_ETS,AuthorityId) of
		[]-> false;
		_-> true
	end;
validauthority(AuthorityId) ->
	throw({invalid_authrityid, AuthorityId}).

get_authority_info(AuthorityId) when is_integer(AuthorityId) ->
	case ets:lookup(?GUILD_AUTHORITIES_ETS,AuthorityId) of
		[]-> [];
		[{_AuthorityId,Term}]-> Term
	end;

get_authority_info(AuthorityId)->
	throw({invalid_authrityid, AuthorityId}).

get_authority_name(AuthorityInfo)->
	erlang:element(#guild_authorities.name, AuthorityInfo).

get_authority_disabled(AuthorityInfo)->
	erlang:element(#guild_authorities.disabled, AuthorityInfo).

%%
%%
%%

validauthgroup(GroupId) when is_integer(GroupId) ->
	case ets:lookup(?GUILD_AUTH_GROUP_ETS,GroupId) of
		[]-> false;
		_-> true
	end;
validauthgroup(GroupId)->
	throw({invalid_auth_groups, GroupId}).
	
get_authgroup_info(GroupId) when is_integer(GroupId)->
	case ets:lookup(?GUILD_AUTH_GROUP_ETS,GroupId) of
		[]-> [];
		[{_GroupId,Term}]-> Term
	end;
get_authgroup_info(GroupId)->
	throw({invalid_auth_groups, GroupId}).

get_authgroup_name(GroupInfo)->
	erlang:element(#guild_auth_groups.name, GroupInfo).

get_authgroup_level(GroupInfo)->
	erlang:element(#guild_auth_groups.level, GroupInfo).

get_authgroup_authids(GroupInfo)->
	erlang:element(#guild_auth_groups.authids, GroupInfo).

ishighergroup(GroupId1,GroupId2)when is_integer(GroupId1),is_integer(GroupId2) ->
	if GroupId1 == GroupId2
		 -> false;
	  true->
		  GroupInfo1 = get_authgroup_info(GroupId1),
		  GroupInfo2 = get_authgroup_info(GroupId2),
		  get_authgroup_level(GroupInfo1) < get_authgroup_level(GroupInfo2)
	end;

ishighergroup(GroupId1,GroupId2)->
	throw({invalid_auth_groups, {GroupId1,GroupId2}}).

%%
%%
%%
validfacility(FacilityId) when is_integer(FacilityId)->
	o;
validfacility(FacilityId)->
	throw({invalid_facilityid, FacilityId}).


get_facility_info(FacilityId,Level) 
  when is_integer(FacilityId), is_integer(Level)->
	case ets:lookup(?GUILD_FACILITIES_ETS, {FacilityId,Level}) of
		[]-> [];
		[{_Key,Term}]-> Term
	end;

get_facility_info(FacilityId,Level) ->
	throw({invalid_facilityid, {FacilityId,Level}}).

get_facility_name(FacilityInfo)->
	erlang:element(#guild_facilities.name, FacilityInfo).

get_facility_level(FacilityInfo)->
	erlang:element(#guild_facilities.level, FacilityInfo).	

get_facility_rate(FacilityInfo)->
	erlang:element(#guild_facilities.rate, FacilityInfo).	

get_facility_check_script(FacilityInfo)->
	erlang:element(#guild_facilities.check_script, FacilityInfo).
	
get_facility_require_resource(FacilityInfo)->
	erlang:element(#guild_facilities.require_resource, FacilityInfo).

get_facility_require_time(FacilityInfo)->
	erlang:element(#guild_facilities.require_time, FacilityInfo).

get_settingvalue(Key)->
	case ets:lookup(?GUILD_SETTING_ETS,Key) of
		[]->[];
		[{_Id,Value}] -> 
			element(#guild_setting.value,Value)
	end.

get_guild_shop_info(Level)->
	case ets:lookup(?GUILD_SHOP_ETS,Level) of
		[]->[];
		[{_Id,Value}] -> Value
	end.

get_guild_shop_itemslist(TableInfo)->
	element(#guild_shop.itemslist,TableInfo).

get_guild_shop_preview_itemslist(TableInfo)->
	element(#guild_shop.preview_itemslist,TableInfo).

get_guild_shopitem_info(Id)->
	case ets:lookup(?GUILD_SHOP_ITEMS_ETS,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.

get_guild_shopitem_info_by_type(Id,Type)->
	case ets:match(?GUILD_SHOP_ITEMS_ETS,{'_',{'_',Id,'_','_','_','_','_','_','_',Type}}) of
		[]->[];
		[Value] -> Value
	end.

get_guild_shopitem_type(TableInfo)->
	element(#guild_shop_items.itemtype,TableInfo).

get_guild_shopitem_itemid(TableInfo)->
	element(#guild_shop_items.itemid,TableInfo).

get_guild_shopitem_showindex(TableInfo)->
	element(#guild_shop_items.showindex,TableInfo).

get_guild_shopitem_contribution(TableInfo)->
	element(#guild_shop_items.guild_contribution,TableInfo).

get_guild_shopitem_baseprice(TableInfo)->
	element(#guild_shop_items.base_price,TableInfo).

get_guild_shopitem_discount(TableInfo)->
	element(#guild_shop_items.discount,TableInfo).

get_guild_shopitem_minlevel(TableInfo)->
	element(#guild_shop_items.minlevel,TableInfo).

get_guild_shopitem_limitnum(TableInfo)->
	element(#guild_shop_items.limitnum,TableInfo).

add_guild_treasure_to_mnesia(Term)->
	try
		NewTerm = list_to_tuple([guild_treasure|tuple_to_list(Term)]),
		dal:write(NewTerm)
	catch
		E:R-> slogger:msg("Reason ~p: ~p~n",[E,R]),error
	end.

get_guild_treasure_info()->  
	ets:foldl(fun({_,Info},Acc)->
					  ItemLists = element(#guild_treasure.itemslist,Info),
					  ItemLists ++ Acc
				end,[],?GUILD_TREASURE_ETS).

get_guild_treasure_itemslist(TableInfo)->
	element(#guild_treasure.itemslist,TableInfo).


get_guild_treasureitem_info(Id)->
	case ets:lookup(?GUILD_TREASURE_ITEMS_ETS,Id) of
		[]->[];
		[{_,Value}] -> Value
	end.

get_guild_treasureitem_info_by_type(Id,Type)->
	case ets:match(?GUILD_TREASURE_ITEMS_ETS,{'Id',{'_',Id,'_','_','_','_','_','_',Type}}) of
		[]->[];
		[Value] -> Value
	end.
	
get_guild_treasureitem_type(TableInfo)->
	element(#guild_treasure_items.itemtype,TableInfo).

get_guild_treasureitem_itemid(TableInfo)->
	element(#guild_treasure_items.itemid,TableInfo).

get_guild_treasureitem_showindex(TableInfo)->
	element(#guild_treasure_items.showindex,TableInfo).

get_guild_treasureitem_contribution(TableInfo)->
	element(#guild_treasure_items.guild_contribution,TableInfo).

get_guild_treasureitem_baseprice(TableInfo)->
	element(#guild_treasure_items.base_price,TableInfo).

get_guild_treasureitem_minlevel(TableInfo)->
	element(#guild_treasure_items.minlevel,TableInfo).

get_guild_treasureitem_limitnum(TableInfo)->
	element(#guild_treasure_items.limitnum,TableInfo).

%% guild monster
get_guild_monsterinfo(MonsterId)->
	case ets:lookup(?GUILD_MONSTER_ETS,MonsterId) of
		[{_,Info}]->Info;
		_->[]
	end.

get_guild_monster_needlevel(MonsterInfo)->
	element(#guild_monster_proto.needlevel,MonsterInfo).

get_guild_monster_upgrademoney(MonsterInfo)->
	element(#guild_monster_proto.upgrademoney,MonsterInfo).

get_guild_monster_callmoney(MonsterInfo)->
	element(#guild_monster_proto.callmoney,MonsterInfo).

get_guild_monster_bornpos(MonsterInfo)->
	element(#guild_monster_proto.bornpos,MonsterInfo).

%%帮会仓库
add_guilditem_into_package(GuildItems)->
	dal:write_rpc(GuildItems).


delete_guilditem_from_package(Key)->
		dal:delete_rpc(guilditems, Key).
%%得到非闲置物品
get_noidel_guilditem_by_guildid({GuildId1,GuildId2})->
	ets:foldl(fun({_,Info},Acc)->
					  case get_guild_guildid_from_guilditem(Info) of
								   {X,Y}->{X,Y},
										  State=get_item_state_from_guildinfo(Info),
										    if (X=:=GuildId1) and (Y=:=GuildId2) and (?GUILID_PACLAGE_IDELITEM=:=State) ->
											 [Info]++Acc;
										 true->
											 Acc
					 				 end;
								   _Other->
									 Acc
							   end
					 end , [],?GUILD_PACKAGE_ETS).
%%得到闲置物品
get_idel_guilditem_by_guildid({GuildId1,GuildId2})->
		ets:foldl(fun({_,Info},Acc)->
					  case get_guild_guildid_from_guilditem(Info) of
								   {X,Y}->{X,Y},
										  State=get_item_state_from_guildinfo(Info),
										    if (X=:=GuildId1) and (Y=:=GuildId2) and (?GUILID_PACLAGE_IDELITEM=/=State) ->
											 [Info]++Acc;
										 true->
											 Acc
					 				 end;
								   _Other->
									 Acc
							   end
					 end , [],?GUILD_PACKAGE_ETS).

%%得到帮会仓库中所有物品
get_guilditem_by_guildid({GuildId1,GuildId2})->
			ets:foldl(fun({_,Info},Acc)->
					  case get_guild_guildid_from_guilditem(Info) of
								   {X,Y}->{X,Y},
										    if (X=:=GuildId1) and (Y=:=GuildId2) ->
											 [Info]++Acc;
										 true->
											 Acc
					 				 end;
								   _Other->
									 Acc
							   end
					 end , [],?GUILD_PACKAGE_ETS).
	
	
get_guilditem_info_by_itemid(ItemId)->
	try
		case ets:lookup(?GUILD_PACKAGE_ETS, ItemId) of
			[{_,Info}]->
				Info;
			_->
				[]
		end
	catch
		_:_Error->nothing
			%io:format("@@@@@@@@@@@@@@ Error   ~p~n",[Error])
	end.



get_guild_package(GuildInfo)->
	GuildPackageSize=erlang:element(#guild_baseinfo.package, GuildInfo),
	erlang:element(1, GuildPackageSize).

get_guild_package_limit(GuildInfo)->
	GuildPackageSize=erlang:element(#guild_baseinfo.package, GuildInfo),
	erlang:element(2, GuildPackageSize).
get_guild_package_info_from_guildbaseinfo(GuildInfo)->
	erlang:element(#guild_baseinfo.package, GuildInfo).

get_guild_id(GuildInfo)->
	erlang:element(#guild_baseinfo.id, GuildInfo).


get_item_id_from_guilditem(GuildInfo)->
	erlang:element(#guilditems.id,GuildInfo ).
get_item_low_id_from_guilditem(GuildInfo)->
	ItemId=erlang:element(#guilditems.id,GuildInfo ),
	erlang:element(2,ItemId).
get_item_high_id_from_guilditem(GuildInfo)->
	ItemId=erlang:element(#guilditems.id,GuildInfo ),
	erlang:element(1,ItemId).
get_guild_guildid_from_guilditem(GuildInfo)->
	erlang:element(#guilditems.ownerguid, GuildInfo).
get_item_proto_id_from_guilditem(GuildInfo)->
	erlang:element(#guilditems.entry, GuildInfo).
get_enchantments_from_guilditem(GuildInfo)->
	erlang:element(#guilditems.enchantments, GuildInfo).
get_item_count_from_guilditem(GuildInfo)->
	erlang:element(#guilditems.count, GuildInfo).
get_item_slot_from_guilditem(GuildInfo)->
	erlang:element(#guilditems.slot, GuildInfo).
get_item_bound_from_guilditem(GuildInfo)->
	erlang:element(#guilditems.bound,GuildInfo).
get_item_sockets_from_guilditem(GuildInfo)->
	erlang:element(#guilditems.sockets,GuildInfo).
get_item_duration_from_guilditem(GuildInfo)->
	erlang:element(#guilditems.duration, GuildInfo).
get_item_coordowninfo_from_guildiinfo(GuildInfo)->
	erlang:element(#guilditems.cooldowninfo, GuildInfo).
get_item_enchant_from_guilditem(GuildInfo)->
	erlang:element(#guilditems.enchant,GuildInfo).
get_item_overdueinfo_from_guilditem(GuildInfo)->
	erlang:element(#guilditems.overdueinfo,GuildInfo).
get_item_state_from_guildinfo(GuildInfo)->
	erlang:element(#guilditems.state, GuildInfo).
set_item_state_from_guildinfo(GuildInfo,State)->
	GuildInfo#guilditems{state=State}.
set_item_count_to_guilditem(GuildInfo,Count)->
	GuildInfo#guilditems{count=Count}.
set_item_slot_from_guilditem(GuildInfo,Slot)->
	GuildInfo#guilditems{slot=Slot}.


update_guilditem_info(GuildInfo)->
	ItemId=get_item_id_from_guilditem(GuildInfo),
	try
	ets:insert(?GUILD_PACKAGE_ETS, {ItemId,GuildInfo})
	catch
		_:_Error->nothing
			%io:format("@@@@@@@@@@update guilditems error is   ~p~n",[Error])
	end.

update_delete_guild_info(Key)->
	try
		ets:delete(?GUILD_PACKAGE_ETS, Key)
	catch
		_:Error->nothing
			%io:format("@@@@@@@@@@update guilditems error is   ~p~n",[Error])
	end.

delete_all_object_from_guildpackage()->
	try
		ets:delete_all_objects(?GUILD_PACKAGE_ETS),
		dal:clear_table_rpc(guilditems)
	catch
		_:_Error->nothing
			%io:format("@@@@@@@@@@@@@@@@@    clear table guilditems error: ~p~n",[Error])
	end.
		

get_guid_package_apply_info(GuildId)->
	ets:foldl(fun({_,Info},Acc)->
					case lists:keyfind(GuildId,#guildpackage_apply.guildid, [Info]) of
						false->
							Acc;
						Other->
							[Info]++Acc
					 end end 	 , [], ?GUILD_PACKAGE_APPLY).

insert_object_to_package_apply(Object,GuildId)->
	try
		ets:insert(?GUILD_PACKAGE_APPLY, {GuildId,Object}),
		dal:write_rpc(Object)
	catch
		_:_Error->nothing
			%io:format("@@@@@@@@@@@@@@    ~p~n",[Error])
	end.

delete_object_from_package_apply(GuildId,Object)->
	try
		ets:delete_object(?GUILD_PACKAGE_APPLY, {GuildId,Object}),
		dal:delete_object_rpc(Object)
	catch
		_:_Error->nothing
			%io:format("@@@@@@@@@@@@@@@   ~p~n",[Error])
	end.

delete_all_object_from_package_apply(Key)->
	try
		ets:delete(?GUILD_PACKAGE_APPLY, Key),
		dal:delete_rpc(guildpackage_apply, Key)
	catch
		_:_Error->nothing
				%io:format("@@@@@@@@@@@@@@@   ~p~n",[Error])
	end.

get_apply_role_id(Info)->
	erlang:element(#guildpackage_apply.roleid, Info).
get_apply_guildid(Info)->
	erlang:element(#guildpackage_apply.guildid,Info).
get_apply_item_count(Info)->
	erlang:element(#guildpackage_apply.count, Info).
get_apply_item_id(Info)->
	erlang:element(#guildpackage_apply.itemid, Info).
	
					

				


