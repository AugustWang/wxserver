%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%% this file create by template
%% Author :
%% Created : 2011-06-01
%% Description : TODO

-module(venation_exp_proto_db).

-define(ETS_TABLE_NAME,venation_exp_proto_ets).
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% Include files 
%%
-include("venation_def.hrl").


%%
%% API Functions
%%
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
	db_tools:create_table_disc(venation_exp_proto,record_info(fields,venation_exp_proto),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{venation_exp_proto,proto}].

create()->
	ets:new(?ETS_TABLE_NAME, [set,named_table]).

init()->
	db_operater_mod:init_ets(venation_exp_proto, ?ETS_TABLE_NAME,#venation_exp_proto.level).

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
get_exp(TableInfo)->
	element(#venation_exp_proto.exp,TableInfo).

%%
%% return : Value | []
%%
get_shareexp(TableInfo)->
	element(#venation_exp_proto.shareexp,TableInfo).
