%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-5-26
%% Description: TODO: Add description to equipment_db
-module(equipment_db).

%%
%% Include files
%%
-include("equipment_up_def.hrl").
-include("equipment_define.hrl").

%%
%% Exported Functions
%%
-export([
		 get_back_echantment_stone_info/1,
		 get_back_echantment_stone_info/2,
		 get_enchant_opt_info/1,
		 get_enchant_property_opt_infos/1,
		 get_enchant_convert_info/1,
		 get_enchant_convert_all_info/0,
		 get_enchant_extremely_property_opt_infos/1
		]).

-export([get_info_back_stone/1,
		 get_info_enchant_prop/1,
		 get_info_recast_prop/1,
		 get_info_recast_gold/1,
		 get_info_enchant_gold/1,
		 get_info_convert_gold/1,
		 get_info_property_count/1,
		 get_info_property/1,
		 get_info_priority/1,
		 get_info_max_count/1,
		 get_info_group/1,
		 get_info_max_value/1,
		 get_info_min_value/1,
		 get_info_max_priority/1,
		 get_info_min_priority/1,
		 get_info_convert_property/1,
		 get_info_convert_convert/1
		]).

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
	db_tools:create_table_disc(back_echantment_stone,record_info(fields,back_echantment_stone),[],set),
	db_tools:create_table_disc(enchant_opt,record_info(fields,enchant_opt),[],set),
	db_tools:create_table_disc(enchant_property_opt,record_info(fields,enchant_property_opt),[],bag),
	db_tools:create_table_disc(enchant_convert,record_info(fields,enchant_convert),[],set),
	db_tools:create_table_disc(enchant_extremely_property_opt,record_info(fields,enchant_extremely_property_opt),[],bag).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{back_echantment_stone,proto},{enchant_opt,proto},{enchant_property_opt,proto},{enchant_convert,proto},{enchant_extremely_property_opt,proto}].

delete_role_from_db(_RoleId)->
	nothing.

create()->
	ets:new(?BACK_ECHANTMENT_STONE_ETS, [set,named_table]),
	ets:new(?ENCHANT_OPT_ETS, [set,named_table]),
	ets:new(?ENCHANT_PROPERTY_OPT_ETS, [bag,named_table]),
	ets:new(?ENCHANT_CONVERT_ETS, [set,named_table]),
	ets:new(?ENCHANT_EXTREMELY_PROPERTY_OPT_ETS, [bag,named_table]).

init()->
	db_operater_mod:init_ets(back_echantment_stone, ?BACK_ECHANTMENT_STONE_ETS,#back_echantment_stone.id),
	db_operater_mod:init_ets(enchant_opt, ?ENCHANT_OPT_ETS,#enchant_opt.id),
	db_operater_mod:init_ets(enchant_property_opt, ?ENCHANT_PROPERTY_OPT_ETS,#enchant_property_opt.id),
	db_operater_mod:init_ets(enchant_convert, ?ENCHANT_CONVERT_ETS,#enchant_convert.property),
	db_operater_mod:init_ets(enchant_extremely_property_opt, ?ENCHANT_EXTREMELY_PROPERTY_OPT_ETS,#enchant_extremely_property_opt.id).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_back_echantment_stone_info(Id)->
	case ets:lookup(?BACK_ECHANTMENT_STONE_ETS,Id) of
		[]-> [];
		[{_,Term}]-> Term
	end.

get_enchant_opt_info(Id)->
	case ets:lookup(?ENCHANT_OPT_ETS,Id) of
		[]-> [];
		[{_,Term}]-> Term
	end.

get_enchant_property_opt_infos(Id)->
	case ets:lookup(?ENCHANT_PROPERTY_OPT_ETS,Id) of
		[]-> [];
		Terms-> lists:map(fun({_,Info})-> Info end, Terms) 
	end.

get_enchant_convert_info(Id)->
	case ets:lookup(?ENCHANT_CONVERT_ETS,Id) of
		[]-> [];
		[{_,Term}]-> Term
	end.

get_enchant_convert_all_info()->
	case ets:tab2list(?ENCHANT_CONVERT_ETS) of
		[]-> [];
		Terms-> lists:map(fun({_,Info})-> Info end, Terms)
	end.

get_enchant_extremely_property_opt_infos(Id)->
	case ets:lookup(?ENCHANT_EXTREMELY_PROPERTY_OPT_ETS,Id) of
		[]-> [];
		Terms-> lists:map(fun({_,Info})-> Info end, Terms) 
	end.
get_back_echantment_stone_info(EquipmentLevel,EquipmentStar)->
	MatchFun = fun({LevelId,Term},Acc) ->
					   {StartLevel,EndLevel,Star} = LevelId,
					   if
						   EquipmentLevel>=StartLevel,EquipmentLevel=<EndLevel,EquipmentStar=:=Star->
							   Acc ++ [Term];
						   true->
							   Acc
					   end
			   end,
	ets:foldl(MatchFun, [], ?BACK_ECHANTMENT_STONE_ETS).

get_info_back_stone(Info)->
	erlang:element(#back_echantment_stone.back_stone, Info).

get_info_enchant_prop(Info)->
	erlang:element(#enchant_opt.enchant, Info).

get_info_recast_prop(Info)->
	erlang:element(#enchant_opt.recast, Info).

get_info_recast_gold(Info)->
	erlang:element(#enchant_opt.recast_gold, Info).

get_info_enchant_gold(Info)->
	erlang:element(#enchant_opt.enchant_gold, Info).

get_info_convert_gold(Info)->
	erlang:element(#enchant_opt.convert_gold, Info).
get_info_property_count(Info)->
	erlang:element(#enchant_opt.property_count, Info).

get_info_property(Info)->
	erlang:element(#enchant_property_opt.property, Info).

get_info_priority(Info)->
	erlang:element(#enchant_property_opt.priority, Info).

get_info_max_count(Info)->
	erlang:element(#enchant_property_opt.max_count, Info).

get_info_group(Info)->
	erlang:element(#enchant_property_opt.group, Info).

get_info_max_value(Info)->
	erlang:element(#enchant_property_opt.max_value, Info).

get_info_min_value(Info)->
	erlang:element(#enchant_property_opt.min_value, Info).

get_info_max_priority(Info)->
	erlang:element(#enchant_property_opt.max_priority, Info).

get_info_min_priority(Info)->
	erlang:element(#enchant_property_opt.min_priority, Info).

get_info_convert_property(Info)->
	erlang:element(#enchant_convert.property, Info).

get_info_convert_convert(Info)->
	erlang:element(#enchant_convert.convert, Info).
%%
%% Local Functions
%%

