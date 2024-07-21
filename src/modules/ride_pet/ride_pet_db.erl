%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-8-17
%% Description: TODO: Add description to ride_pet_db
-module(ride_pet_db).

%%
%% Include files
%%
-include("ride_pet_def.hrl").


-define(RIDEPET_SYNTHESIS_ETS,ridepet_synthesis_ets).
-define(ITEM_IDENTIFY_ETS,item_identify_ets).
-define(RIDE_PROTO_ETS,ride_proto_db_ets).
-define(ATTR_INFO_ETS,attr_info_ets).
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
	db_tools:create_table_disc(item_identify,record_info(fields,item_identify),[],set),
	db_tools:create_table_disc(ridepet_synthesis,record_info(fields,ridepet_synthesis),[],set),
	db_tools:create_table_disc(ride_proto_db,record_info(fields,ride_proto_db),[],set),
	db_tools:create_table_disc(attr_info,record_info(fields,attr_info),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{item_identify,proto},{ridepet_synthesis,proto},{ride_proto_db,proto},{attr_info,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?ITEM_IDENTIFY_ETS,[set,named_table]),
	ets:new(?RIDEPET_SYNTHESIS_ETS,[set,named_table]),
	ets:new(?RIDE_PROTO_ETS,[set,named_table]),
	ets:new(?ATTR_INFO_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(item_identify, ?ITEM_IDENTIFY_ETS,#item_identify.item_class),
	db_operater_mod:init_ets(ridepet_synthesis, ?RIDEPET_SYNTHESIS_ETS,#ridepet_synthesis.quality),
	db_operater_mod:init_ets(ride_proto_db, ?RIDE_PROTO_ETS,#ride_proto_db.item_template_id),
	db_operater_mod:init_ets(attr_info, ?ATTR_INFO_ETS,#attr_info.quality).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_ridepet_synthesis_info(Quility)->
	case ets:lookup(?RIDEPET_SYNTHESIS_ETS, Quility) of
		[]-> [];
		[{_,Info}]-> Info
	end.

get_item_identify_info(ItemTempId)->
	case ets:lookup(?ITEM_IDENTIFY_ETS, ItemTempId) of
		[]-> [];
		[{_,Info}]-> Info
	end.

get_ridepet_synthesis_consume(SynthesisInfo)->
	element(#ridepet_synthesis.consume,SynthesisInfo).

get_ridepet_synthesis_rateinfo(SynthesisInfo)->
	element(#ridepet_synthesis.rateinfo,SynthesisInfo).

get_item_identify_consume(ItemIdentifyInfo)->
	element(#item_identify.consume,ItemIdentifyInfo).

get_item_identify_rateinfo(ItemIdentifyInfo)->
	element(#item_identify.rateinfo,ItemIdentifyInfo).

get_proto_info(Item_template_id)->
	case ets:lookup(?RIDE_PROTO_ETS,Item_template_id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.
%%
%%item_template_id,add_buff,drop_rate,ride_displayid
%% return : Value | []
%%
get_add_buff(TableInfo)->
	element(#ride_proto_db.add_buff,TableInfo).

get_drop_rate(TableInfo)->
	element(#ride_proto_db.drop_rate,TableInfo).

get_attr_info(Quality)->
	case ets:lookup(?ATTR_INFO_ETS,Quality) of
		[]->[];
		[{_Id,Value}] -> Value
	end.

get_attr_drop_num(AttrInfo)->
	element(#attr_info.dropnum,AttrInfo).

get_drop_rate_list(AttrInfo)->
	element(#attr_info.attrrate_list,AttrInfo).

















