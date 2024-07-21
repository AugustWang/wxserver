%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------

%%
%% this file create by template
%% Author :
%% Created : 2011-05-31
%% Description : TODO

-module(venation_db).

-define(ETS_TABLE_NAME,venation_ets).
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% Include files 
%%
-include("venation_def.hrl").

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
	db_tools:create_table_disc(venation_proto,record_info(fields,venation_proto),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{venation_proto,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?ETS_TABLE_NAME,[set,named_table]).

init()->
	db_operater_mod:init_ets(venation_proto, ?ETS_TABLE_NAME,#venation_proto.id).
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
	case ets:lookup(?ETS_TABLE_NAME,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.
	


%%
%% return : Value | []
%%
get_id(TableInfo)->
	element(#venation_proto.id,TableInfo).
	
%%
%% return : Value | []
%%
get_point_num(TableInfo)->
	element(#venation_proto.point_num,TableInfo).

get_attr_addition(TableInfo)->
	element(#venation_proto.attr_addition,TableInfo).
