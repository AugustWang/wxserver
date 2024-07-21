%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-2-28
%% Description: TODO: Add description to pet_xisui_db
-module(pet_xisui_db).
-include("pet_def.hrl").
%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-export([get_pet_xisui_rate_info/1,get_pet_xisui_value_from_info/1,get_pet_xisui_rate_from_info/1]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
-define(PET_XISUI_ETS,pet_xisui).
%%
%% API Functions
%%
start()->
	db_operater_mod:start_module(?MODULE,[]).
create_mnesia_table(disc)->
	db_tools:create_table_disc(pet_xisui_rate, record_info(fields,pet_xisui_rate), [], set).
create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_xisui_rate,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_XISUI_ETS,[ordered_set,named_table,public]).
	
init()->
	db_operater_mod:init_ets(pet_xisui_rate, ?PET_XISUI_ETS,#pet_xisui_rate.xisui).


%%
%% Local Functions
%%

get_pet_xisui_rate_info(Xisui)->
	try
		case ets:lookup(?PET_XISUI_ETS, Xisui) of
			[{_,Object}]->
				Object;
			_->
				[]
		end
	catch
		_Other:_Error->nothing
			%io:format("@@@@@@@@@@   ~p~n",[Error])
	end.

get_pet_xisui_value_from_info(Info)->
	#pet_xisui_rate{xisui=Xs}=Info,
	Xs.
get_pet_xisui_rate_from_info(Info)->
	#pet_xisui_rate{rate=Rate}=Info,
	Rate.
