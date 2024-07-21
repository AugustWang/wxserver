%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-30
%% Description: TODO: Add description to activity_db
-module(activity_db).

%%
%% Include files
%%
-include("activity_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
%%
%% API Functions
%%
-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(activity_info_db,record_info(fields,activity_info_db),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{activity_info_db,disc}].

delete_role_from_db(_)->
	ignor.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_activity_info(ActivityId)->
	case dal:read_rpc(activity_info_db,ActivityId) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.

add_to_activity_db(ActivityId,Info)->
	dal:write_rpc({activity_info_db,ActivityId,Info}).












