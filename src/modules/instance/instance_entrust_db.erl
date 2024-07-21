%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------

-module(instance_entrust_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-define(INSTANCE_ENTRUST_NAME,ets_instance_entrust).
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
	db_tools:create_table_disc(instance_entrust, record_info(fields,instance_entrust), [], set).	

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{instance_entrust,proto}].

create()->
	ets:new(?INSTANCE_ENTRUST_NAME, [set,named_table]).

init()->
	db_operater_mod:init_ets(instance_entrust, ?INSTANCE_ENTRUST_NAME,#instance_entrust.id).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(Id)->
	case ets:lookup(?INSTANCE_ENTRUST_NAME,Id) of
		[]->[];
		[{Id,Term}]-> Term
	end.


	
