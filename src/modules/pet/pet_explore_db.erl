%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-10-10
%% Description: TODO: Add description to pet_explore_db
-module(pet_explore_db).

%%
%% Include files
%%
-include("pet_def.hrl").
-define(PET_EXPLORE_GAIN_ETS,pet_explore_gain_ets).
-define(PET_EXPLORE_STYLE_ETS,pet_explore_style_ets).
%%
%% Exported Functions
%%
-export([save_explore_to_db/3,load_explore_form_db/1]).

-export([load_pet_explore_info_by_roleid/1,save_pet_explore_info_to_db/1,
		 get_explore_styleinfo/1,get_explore_gaininfo/1,update_pet_explore_map_data_rpc/0]).
-export([create/0,init/0]).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(pet_explore_gain,record_info(fields,pet_explore_gain),[],set),
	db_tools:create_table_disc(pet_explore_style,record_info(fields,pet_explore_style),[],set),
	db_tools:create_table_disc(pet_explore_info,record_info(fields,pet_explore_info),[masterid],set),
	db_tools:create_table_disc(pet_explore_background,record_info(fields,pet_explore_background),[mapid],set).

create_mnesia_split_table(pet_explore_storage,TableName)->
	db_tools:create_table_disc(TableName,record_info(fields,pet_explore_storage),[],set).

tables_info()->
	[{pet_explore_gain,proto},{pet_explore_style,proto},{pet_explore_info,disc},{pet_explore_background,disc},{pet_explore_storage,disc_split}].

delete_role_from_db(RoleId)->
	OwnerTable = db_split:get_owner_table(pet_explore_storage, RoleId),
	dal:delete_rpc(OwnerTable, RoleId),
	lists:foreach(fun(Object)-> dal:delete_object_rpc(Object) end,load_pet_explore_info_by_roleid(RoleId)).

create()->
	ets:new(?PET_EXPLORE_GAIN_ETS,[set,named_table]),
	ets:new(?PET_EXPLORE_STYLE_ETS,[set,named_table]).

init()->
	init_pet_explore_gain(),
	db_operater_mod:init_ets(pet_explore_style, ?PET_EXPLORE_STYLE_ETS,#pet_explore_style.id).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

update_pet_explore_map_data_rpc()->
	lists:foreach(fun(N)-> rpc:call(N,?MODULE,init,[]) end ,node_util:get_mapnodes()).

init_pet_explore_gain()->
	ets:delete_all_objects(?PET_EXPLORE_GAIN_ETS),
	case dal:read_rpc(pet_explore_gain) of
		{ok,Results}->
			[];
		_->
			Results =[]
	end,
	lists:foreach(fun(Term)->
			Id = erlang:element(#pet_explore_gain.id,Term),
			case dal:read_index_rpc(pet_explore_background,Id,#pet_explore_background.mapid) of
				{ok,[]}->
					ets:insert(?PET_EXPLORE_GAIN_ETS,{Id,Term});
				{ok,[{_TableName,_KeyId,_MapId,StartTime,EndTime,Week}|_]}->
					TmpTerm = Term#pet_explore_gain{starttime = StartTime,endtime = EndTime,week = Week},
					ets:insert(?PET_EXPLORE_GAIN_ETS,{Id,TmpTerm});
				Reason->
					slogger:msg("read pet_explore_background error,Reason:~p~n",[Reason]),
					ets:insert(?PET_EXPLORE_GAIN_ETS,{Id,Term})
			end	end, Results).


get_explore_styleinfo(StyleId)->
		case ets:lookup(?PET_EXPLORE_STYLE_ETS,StyleId) of
			[]->
				[];
			[{_,StyleInfo}]->
				StyleInfo
		end.

get_explore_gaininfo(SiteId)->
		case ets:lookup(?PET_EXPLORE_GAIN_ETS,SiteId) of
			[]->
				[];
			[{_,GainInfo}]->
				GainInfo
		end.

%%pet explore info
load_pet_explore_info_by_roleid(RoleId)->
	case dal:read_index_rpc(pet_explore_info,RoleId,#pet_explore_info.masterid) of
		{ok,[]}->
			[];
		{ok,PetExploreInfo}->
%% 			io:format("PetExploreInfo:~p~n",[PetExploreInfo]),
			PetExploreInfo;
		Error->
			slogger:msg("load_pet_explore_info_by_roleid,Error:~p~n",[Error]),
			[]
	end.

save_pet_explore_info_to_db(PetExploreInfo)->
	lists:map(fun(PetExploreRecord)->
					  dal:write_rpc(PetExploreRecord)
			  end,PetExploreInfo).

save_explore_to_db(RoleId,ItemList,MaxItemId)->
%%	io:format("save_to_db MaxItemId:~p~n",[MaxItemId]),
	OwnerTable = db_split:get_owner_table(pet_explore_storage, RoleId),
	dal:write_rpc({OwnerTable,RoleId,ItemList,MaxItemId,undefined}).

load_explore_form_db(RoleId)->
	OwnerTable = db_split:get_owner_table(pet_explore_storage, RoleId),
	case dal:read_rpc(OwnerTable,RoleId) of
		{ok,[Record]}->
			Record;
		_->[]
	end.	
