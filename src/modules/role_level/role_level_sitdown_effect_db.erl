%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%% this file create by template
%% Author :
%% Created : 2011-02-15
%% Description : TODO

-module(role_level_sitdown_effect_db).

-define(ETS_TABLE_NAME,role_level_sitdown_effect_ets).
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% Include files 
%%
-include("buffer_effect_def.hrl").

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
	ets:new(?ETS_TABLE_NAME,[set,named_table]).

init()->
	db_operater_mod:init_ets(role_level_sitdown_effect_db, ?ETS_TABLE_NAME,#role_level_sitdown_effect_db.level).

create_mnesia_table(disc)->
	db_tools:create_table_disc(role_level_sitdown_effect_db,record_info(fields,role_level_sitdown_effect_db),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{role_level_sitdown_effect_db,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
%% get_info()
%% []
%% {...}
%%[error,....]
%%
get_info(Id)->
	try
		case ets:lookup(?ETS_TABLE_NAME,Id) of
			[]->[];
			[{_Id,Value}] -> Value
		end
	catch
		_:_-> []
	end.


%%
%% return : Value | []
%%
get_exp(TableInfo)->
	element(#role_level_sitdown_effect_db.exp,TableInfo).

%%
%% return : Value | []
%%	
get_soulpower(TableInfo)->
	element(#role_level_sitdown_effect_db.soulpower,TableInfo).

get_hppercent(TableInfo)->
	element(#role_level_sitdown_effect_db.hppercent,TableInfo).

get_mppercent(TableInfo)->
	element(#role_level_sitdown_effect_db.mppercent,TableInfo).

get_zhenqi(TableInfo)->
	element(#role_level_sitdown_effect_db.zhenqi,TableInfo).