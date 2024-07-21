%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(role_private_option_db).
%%
%% behaviour export
%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).


-export([load/1,flush/2]).
  
-behaviour(db_operater_mod).
-include("mnesia_table_def.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	nothing.
	%db_tools:create_table_disc(player_option,record_info(fields,player_option),[],set).

create_mnesia_split_table(player_option,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,player_option),[],set).

delete_role_from_db(RoleId)->
	TableName = db_split:get_owner_table(player_option, RoleId),
	dal:delete_rpc(TableName, RoleId).

tables_info()->
	[{player_option,disc_split}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(RoleId)->
	TableName = db_split:get_owner_table(player_option, RoleId),
	case dal:read_rpc(TableName, RoleId) of
		{ok,[{_,_,Result}]}->
			Result;
		_->
			[]
	end.

flush(RoleId,Options)->
	TableName = db_split:get_owner_table(player_option, RoleId),
	dmp_op:sync_write(RoleId,{TableName,RoleId,Options}).