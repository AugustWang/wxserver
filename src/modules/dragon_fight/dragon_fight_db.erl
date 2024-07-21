%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(dragon_fight_db).

-define(ETS_NAME,dragon_fight_ets).
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% Include files 
%%
-include("dragon_fight_def.hrl").

%%
%% API Functions
%%
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
	ets:new(?ETS_NAME,[set,named_table]).

init()->
	db_operater_mod:init_ets(dragon_fight_db, ?ETS_NAME,#dragon_fight_db.id).

create_mnesia_table(disc)->
	db_tools:create_table_disc(dragon_fight_db,record_info(fields,dragon_fight_db),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{dragon_fight_db,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

foldl(F,A)->
	ets:foldl(F, A, ?ETS_NAME).
%% 
%% get_info()
%% []
%% {...}
%%[error,....]
%%
get_info(Id)->
	try
		case ets:lookup(?ETS_NAME,Id) of
			[]->[];
			[{_Id,Value}] -> Value
		end
	catch
		_:_-> []
	end.

%%
%%format [{Index,Time,DropList}]
%%
%%
%% return : Value | []
%%
get_id(TableInfo)->
	element(#dragon_fight_db.id,TableInfo).

get_duration(TableInfo)->
	element(#dragon_fight_db.duration,TableInfo).
  
get_start_pos(TableInfo)->
	element(#dragon_fight_db.start_pos,TableInfo).

get_relation_questid(TableInfo)->
	element(#dragon_fight_db.relation_questid,TableInfo).

get_red_dragon_buff(TableInfo)->
	element(#dragon_fight_db.red_dragon_buff,TableInfo).

get_blue_dragon_buff(TableInfo)->
	element(#dragon_fight_db.blue_dragon_buff,TableInfo).

