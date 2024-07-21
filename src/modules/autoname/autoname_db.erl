%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-3-20
%% Description: TODO: Add description to autoname_db
-module(autoname_db).
-define(AUTONAME_ETS,autoname_table).
%%
%% Include files
%%
-include("mnesia_table_def.hrl").
%%
%% Exported Functions
%%
-export([create/0,init/0,
		 get_autoname_info/1,sync_update_autoname_used_to_mnesia/1,
		 get_autoname_used/1]).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(auto_name,record_info(fields,auto_name),[],set),
	db_tools:create_table_disc(auto_name_used,record_info(fields,auto_name_used),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{auto_name,proto},{auto_name_used,disc}].

delete_role_from_db(_)->
	nothing.

create()->
	ets:new(?AUTONAME_ETS,[set,public,named_table]).

init()->
	db_operater_mod:init_ets(auto_name, ?AUTONAME_ETS,#auto_name.id).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_autoname_info(Id)->
	case ets:lookup(?AUTONAME_ETS, Id) of
		[]->[];
        [{_,Info}]-> Info 
	end.

sync_update_autoname_used_to_mnesia(Term)->
	Object = util:term_to_record(Term,auto_name_used),
	dal:write_rpc(Object).

get_autoname_used(RoleName)->
	case dal:read_rpc(auto_name_used,RoleName) of
		{ok,[]}-> {ok,[]};
		{ok,Result}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_autoname_used failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_autoname_used failed :~p~n",[Reason])
	end.
%%
%% Local Functions
%%

