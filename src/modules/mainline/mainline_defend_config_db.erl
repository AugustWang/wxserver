%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-10-12
%% Description: TODO: Add description to mainline_defend_config_db
-module(mainline_defend_config_db).

%%
%% Include files
%%
-include("mainline_def.hrl").

%%
%% Exported Functions
%%
-define(ETS_TABLE,mainline_defend_config_ets).

-compile(export_all).
-export([init/0,create/0]).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(mainline_defend_config,record_info(fields,mainline_defend_config),[],bag).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{mainline_defend_config,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?ETS_TABLE, [set,named_table]).

init()->
	db_operater_mod:init_ets(mainline_defend_config, ?ETS_TABLE,[#mainline_defend_config.chapter,
																 #mainline_defend_config.stage,
																 #mainline_defend_config.difficulty,
																 #mainline_defend_config.class,
																 #mainline_defend_config.section]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_info(Chapter,Stage,Difficulty,Class,Section)->
	try
		case ets:lookup(?ETS_TABLE, {Chapter,Stage,Difficulty,Class,Section}) of
			[]->
				[];
            [Info]-> 
				{_,Term} = Info,
				Term
		end
	catch
		E:R-> 
			io:format("E:~p R:~p ~n",[E,R]),
			[]
	end.

get_spawns(Term)->
	erlang:element(#mainline_defend_config.spawns, Term).

