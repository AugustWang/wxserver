%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-8-22
%% Description: TODO: Add description to pet_talent_db
-module(pet_talent_db).

%%
%% Include files
%%
-define(PET_TALENT_CONSUME_ETS,pet_talent_consume_ets).
-define(PET_TALENT_RATE_ETS,pet_talent_rate_ets).
-define(PET_TALNET_ITEM_ETS,pet_talnet_item_ets).
-define(PET_TALNET_PROTO_ETS,pet_talnet_proto_ets).
-define(PET_TALNET_TEMPLATE_ETS,pet_talnet_template_ets).

-include("pet_def.hrl").
%%
%% Exported Functions
%%
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
	db_tools:create_table_disc(pet_talent_consume,record_info(fields,pet_talent_consume),[],set),
	db_tools:create_table_disc(pet_talent_rate,record_info(fields,pet_talent_rate),[],bag),
	db_tools:create_table_disc(pet_talent_item,record_info(fields,pet_talent_item),[],set),
	db_tools:create_table_disc(pet_talent_proto,record_info(fields,pet_talent_proto),[],set),
	db_tools:create_table_disc(pet_talent_template, record_info(fields,pet_talent_template),[], bag).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_talent_consume,proto},{pet_talent_rate,proto},{pet_talent_item,proto},{pet_talent_proto,proto},{pet_talent_template,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_TALENT_CONSUME_ETS,[set,named_table]),
	ets:new(?PET_TALENT_RATE_ETS,[set,named_table]),
	ets:new(?PET_TALNET_ITEM_ETS,[set,named_table]),
	ets:new(?PET_TALNET_PROTO_ETS,[set,named_table]),
	ets:new(?PET_TALNET_TEMPLATE_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_talent_consume, ?PET_TALENT_CONSUME_ETS,#pet_talent_consume.type),
	db_operater_mod:init_ets(pet_talent_rate, ?PET_TALENT_RATE_ETS,[#pet_talent_rate.type,#pet_talent_rate.talent]),
	db_operater_mod:init_ets(pet_talent_item, ?PET_TALNET_ITEM_ETS, #pet_talent_item.level),
	db_operater_mod:init_ets(pet_talent_proto, ?PET_TALNET_PROTO_ETS, #pet_talent_proto.type),
	db_operater_mod:init_ets(pet_talent_template, ?PET_TALNET_TEMPLATE_ETS,[ #pet_talent_template.talnetid,#pet_talent_template.level]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_talent_consume_info(Type)->
	case ets:lookup(?PET_TALENT_CONSUME_ETS, Type) of
		[]-> [];
		[{_,Info}]-> Info
	end.

get_talent_rateinfo({Type,Talent})->
	case ets:lookup(?PET_TALENT_RATE_ETS, {Type,Talent}) of
		[]-> [];
		[{_,Info}]-> Info
	end.
	
get_talent_ratelist(RateInfo)->
	element(#pet_talent_rate.rateinfo,RateInfo).

get_pet_consume_detail(RateInfo)->
	element(#pet_talent_consume.consume,RateInfo).

get_talent_item_info(Level)->
	try
		case ets:lookup(?PET_TALNET_ITEM_ETS, Level) of
			[]->[];
			[{_,Info}]->Info
		end
	catch
		_Other:_Error->nothing
			%io:format("@@@@@@@   ~P~n",[Error])
	end.
get_neetitem_from_info(Info)->
	#pet_talent_item{item=Item}=Info,
	Item.
get_needmoney_from_info(Info)->
	#pet_talent_item{money=Money}=Info,
	Money.

get_pet_talent_proto_info(Type)->
	try
		case ets:lookup(?PET_TALNET_PROTO_ETS, Type) of
			[]->
				[];
			[{_,Info}]->Info
		end
	catch
		_Other:_Error->nothing%io:fromat("@@@@@@@@@  ~p~n",[Error])
	end.
get_talentid_from_talent_proto_info(Info)->
	#pet_talent_proto{talnetid=Talnetid}=Info,
	Talnetid.
get_required_from_talent_proto_info(Info)->
	#pet_talent_proto{required=Required}=Info,
	Required.
get_upgrade_from_talent_proto_info(Info)->
	#pet_talent_proto{upgrade=Upgrade}=Info,
	Upgrade.
get_talent_template_info(Talnetid,Level)->
	try
		case ets:lookup(?PET_TALNET_TEMPLATE_ETS,{Talnetid,Level}) of
			[]->[];
			[{_,Info}]->Info
		end
	catch
		_Other:_Error->nothing%io:fromat("@@@@@@@@@   ~p~n",[Error])
	end.

get_talnetid_from_talent_template_info(Info)->
	#pet_talent_template{talnetid=Talnetid}=Info,
	Talnetid.
get_level_from_talent_template_info(Info)->
	#pet_talent_template{level=Level}=Info,
	Level.
get_affect_from_talent_template_info(Info)->
	#pet_talent_template{affect=Affect}=Info,
	Affect.
get_init_pet_talent_info()->
	ets:foldl(fun({_,{pet_talent_proto,Type,TalentId,_,_,_}},Acc)->
					  [{0,TalentId,Type}]++Acc
					 end , [],?PET_TALNET_PROTO_ETS).
	
	