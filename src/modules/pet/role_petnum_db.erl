%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhang
%% Created: 2011-1-25
%% Description: TODO: Add description to role_petnum_db 
-module(role_petnum_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-define(ROLE_PETNUM_ETS,role_petnum_ets).
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
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
	db_tools:create_table_disc(role_petnum,record_info(fields,role_petnum),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{role_petnum,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?ROLE_PETNUM_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(role_petnum, ?ROLE_PETNUM_ETS,#role_petnum.level).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(Level)->
	case ets:lookup(?ROLE_PETNUM_ETS,Level) of
		[]->[];
		[{_Level,Value}] -> Value
	end.
%%
%%	 return : Value | []
%%
get_default_num(RolePetNumInfo)->
	element(#role_petnum.default_num,RolePetNumInfo).

%%
%%	 return : Value | []
%%
get_max_num(RolePetNumInfo)->
	element(#role_petnum.max_num,RolePetNumInfo).


