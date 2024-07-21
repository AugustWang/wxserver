%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-8-22
%% Description: TODO: Add description to pet_quality_db
-module(pet_quality_db).

%%
%% Include files
%%
-include("pet_def.hrl").
-define(PET_QUALITY_ETS,pet_quality_ets).
-define(PET_QUALITY_UP_ETS,pet_quality_up_ets).
-define(WASH_PET_ATTR_POINT_ETS,wash_pet_attr_point_ets).

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
	db_tools:create_table_disc(pet_quality,record_info(fields,pet_quality),[],set),
	db_tools:create_table_disc(pet_quality_up,record_info(fields,pet_quality_up),[],set),
	db_tools:create_table_disc(pet_wash_attr_point,record_info(fields,pet_wash_attr_point),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_quality,proto},{pet_quality_up,proto},{pet_wash_attr_point,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_QUALITY_ETS,[set,named_table]),
	ets:new(?PET_QUALITY_UP_ETS,[set,named_table]),
	ets:new(?WASH_PET_ATTR_POINT_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_quality, ?PET_QUALITY_ETS,#pet_quality.quality_value),
	db_operater_mod:init_ets(pet_quality_up, ?PET_QUALITY_UP_ETS,#pet_quality_up.quality_value),
	db_operater_mod:init_ets(pet_wash_attr_point, ?WASH_PET_ATTR_POINT_ETS,#pet_wash_attr_point.key).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	

get_quality_info(QualityValue)->
	case ets:lookup(?PET_QUALITY_ETS,QualityValue) of
		[]->
			[];
		[{_,Info}]->
			Info
	end.

get_needs_with_qulity_info(Info)->
	element(#pet_quality.needs,Info).

get_rate_with_quality_info(Info)->
	element(#pet_quality.rate,Info).

get_protect_with_quality_info(Info)->
	element(#pet_quality.protect,Info).


get_quality_up_info(QualityUpValue)->
	case ets:lookup(?PET_QUALITY_UP_ETS,QualityUpValue) of
		[]->
			[];
		[{_,Info}]->
			Info
	end.


get_needs_with_quality_up_info(Info)->
	element(#pet_quality_up.needs,Info).


get_consumegold_with_quality_up_info(Info)->
	element(#pet_quality_up.consumegold,Info).

get_rate_with_quality_up_info(Info)->
	element(#pet_quality_up.rate,Info).

get_consumemoney_with_quality_up_info(Info)->
	element(#pet_quality_up.consumemoney,Info).

get_wash_point_info(Key)->
	case ets:lookup(?WASH_PET_ATTR_POINT_ETS,Key) of
		[]->
			[];
		[{_,Info}]->
			Info
	end.

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
