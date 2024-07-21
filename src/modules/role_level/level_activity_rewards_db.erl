%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(level_activity_rewards_db).

-define(ETS_TABLE_NAME,level_activity_rewards_ets).
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% Include files 
%%
-include("activity_rewards_rl_def.hrl").

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
	db_tools:create_table_disc(level_activity_rewards_db,record_info(fields,level_activity_rewards_db),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{level_activity_rewards_db,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?ETS_TABLE_NAME,[set,named_table]).

init()->
	db_operater_mod:init_ets(level_activity_rewards_db, ?ETS_TABLE_NAME,#level_activity_rewards_db.level).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get_info()
%% []
%% {...}
%%[error,....]
%%
get_info(Id)->
	case ets:lookup(?ETS_TABLE_NAME,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.

%%
%% return : Value | []
%%
get_level(TableInfo)->
	element(#level_activity_rewards_db.level,TableInfo).

%%
%% return : Value | []
%%	
get_dragon_fight_exp(TableInfo)->
	element(#level_activity_rewards_db.dragon_fight_exp,TableInfo).
