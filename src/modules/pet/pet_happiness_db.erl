%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-8-22
%% Description: TODO: Add description to pet_happiness_db
-module(pet_happiness_db).

%%
%% Include files
%%
-include("pet_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
-define(PET_HAPPINESS_ETS,pet_happiness_ets).
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
	db_tools:create_table_disc(pet_happiness,record_info(fields,pet_happiness),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_happiness,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_HAPPINESS_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_happiness, ?PET_HAPPINESS_ETS,#pet_happiness.range).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% API Functions
%%

get_info(Id)->
	case ets:lookup(?PET_HAPPINESS_ETS,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.

%%
%%	 return : Value | []
%%
get_percent(Info)->
	element(#pet_happiness.percent,Info).

get_happiness_eff(Happiness)->
	ets:foldl(fun({{A,B},Info},Acc)->
				case (A =< Happiness) and (Happiness =< B) of
					true->
						get_percent(Info);
					_->
						Acc
				end
			end,0,?PET_HAPPINESS_ETS).
%%
%% Local Functions
%%

