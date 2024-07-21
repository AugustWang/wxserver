%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%%
%%
-module(item_template_db).


-include("mnesia_table_def.hrl").
%% 
%% define
%% 
-define(ITEM_TEMPLATE_ETS,item_template_table).


%% 
%% export
%% 
-export([get_item_templateinfo/1,get_name/1,get_clase/1,get_displayed/1,get_equipmentset/1,get_level/1,get_qualty/1,get_requiredlevel/1,
	get_stackable/1,get_maxdurability/1,get_iventorytype/1,get_sockettype/1,get_allowableclass/1,get_useable/1,get_sellprice/1,
	get_damage/1,get_defense/1,get_states/1,get_spellid/1,get_spellocatgory/1,get_spellcooldown/1,get_bonding/1,get_maxsocket/1,
	get_scriptname/1,get_questid/1,get_baserepaired/1,get_overdue_type/1,get_overdue_args/1,get_overdue_transform/1,get_enchant_ext/1]).
-export([get_items_by_itemset/1]).
-export([get_itemid_by_class/1,get_itemid_with_skill/1]).

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
	ets:new(?ITEM_TEMPLATE_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(item_template,?ITEM_TEMPLATE_ETS,#item_template.entry).

create_mnesia_table(disc)->
	db_tools:create_table_disc(item_template,record_info(fields,item_template),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{item_template,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_items_by_itemset(SetId)->
	if
		SetId=:=0->
			[];
		true->
			try
				ets:foldl(fun({ItemID,Value},AccTmp)->
								case get_equipmentset(Value) of
									SetId->
										[ItemID|AccTmp];
									_->
										AccTmp
								end end, [], ?ITEM_TEMPLATE_ETS)
			catch
				_:Reason->
					slogger:msg("get_creature_spawns_info error:~p~n",[Reason]), 
				[]
			end
	end.
   	

get_item_templateinfo(EntryId)->        
	case ets:lookup(?ITEM_TEMPLATE_ETS, EntryId) of
		[]->[];
        [{_Id,Value}]-> Value 
	end.

       
get_name(ItemTempInfo)->
	element(#item_template.name,ItemTempInfo).

get_clase(ItemTempInfo)->
	element(#item_template.class,ItemTempInfo).

get_displayed(ItemTempInfo)->
	element(#item_template.displayed,ItemTempInfo).

get_equipmentset(ItemTempInfo)->
	element(#item_template.equipmentset,ItemTempInfo).

get_level(ItemTempInfo)->
	element(#item_template.level,ItemTempInfo).

get_qualty(ItemTempInfo)->
	element(#item_template.qualty,ItemTempInfo).

get_requiredlevel(ItemTempInfo)->
	element(#item_template.requiredlevel,ItemTempInfo).

get_stackable(ItemTempInfo)->
	element(#item_template.stackable,ItemTempInfo).

get_maxdurability(ItemTempInfo)->
	element(#item_template.maxdurability,ItemTempInfo).

get_iventorytype(ItemTempInfo)->
	element(#item_template.inventorytype,ItemTempInfo).

get_sockettype(ItemTempInfo)->
	element(#item_template.sockettype,ItemTempInfo).

get_allowableclass(ItemTempInfo)->
	element(#item_template.allowableclass,ItemTempInfo).

get_useable(ItemTempInfo)->
	element(#item_template.useable,ItemTempInfo).

get_sellprice(ItemTempInfo)->
	element(#item_template.sellprice,ItemTempInfo).

get_damage(ItemTempInfo)->
	element(#item_template.damage,ItemTempInfo).

get_defense(ItemTempInfo)->
	element(#item_template.defense,ItemTempInfo).

get_states(ItemTempInfo)->
	element(#item_template.states,ItemTempInfo).

get_spellid(ItemTempInfo)->
	element(#item_template.spellid,ItemTempInfo).

get_spellocatgory(ItemTempInfo)->
	element(#item_template.spellcategory,ItemTempInfo).

get_spellcooldown(ItemTempInfo)->
	element(#item_template.spellcooldown,ItemTempInfo).

get_bonding(ItemTempInfo)->
	element(#item_template.bonding,ItemTempInfo).

get_maxsocket(ItemTempInfo)->
	element(#item_template.maxsoket,ItemTempInfo).

get_scriptname(ItemTempInfo)->
	element(#item_template.scriptname,ItemTempInfo).

get_questid(ItemTempInfo)->
	element(#item_template.questid,ItemTempInfo).

get_baserepaired(ItemTempInfo)->
	element(#item_template.baserepaired,ItemTempInfo).

get_overdue_type(ItemTempInfo)->
	element(#item_template.overdue_type,ItemTempInfo).

get_overdue_args(ItemTempInfo)->
	element(#item_template.overdue_args,ItemTempInfo).

get_overdue_transform(ItemTempInfo)->
	element(#item_template.overdue_transform,ItemTempInfo).

get_enchant_ext(ItemTempInfo)->
	element(#item_template.enchant_ext,ItemTempInfo).

get_itemid_by_class(Class)->
	try
		ets:foldl(fun({ItemID,Value},AccTmp)->
					case get_clase(Value) of
						Class->
							[ItemID|AccTmp];
						_->
							AccTmp
					end end, [], ?ITEM_TEMPLATE_ETS)
	catch
		_:_->
			[]	
	end.

get_itemid_with_skill(N)->
	try
		L = ets:foldl(fun({ItemID,Value},AccTmp)->
					case get_spellid(Value) of
						0->
							AccTmp;
						_->
							[ItemID|AccTmp]
					end end, [], ?ITEM_TEMPLATE_ETS),
		lists:sublist(lists:sort(L), N*50+1, 50)
	catch
		_:_->
			[]	
	end.