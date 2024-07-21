%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-22
%% Description: TODO: Add description to rank_evaluation_db
-module(rank_judge_db).

%%
%% Include files
%%
-include("game_rank_def.hrl").

-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(role_judge_left_num,record_info(fields,role_judge_left_num),[],set),
	db_tools:create_table_disc(role_judge_num,record_info(fields,role_judge_num),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{role_judge_left_num,disc},{role_judge_num,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_judge_left_num,RoleId),
	dal:delete_rpc(role_judge_num,RoleId).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% API Functions
%%
get_role_judge_left_num(RoleId)->
	case dal:read_rpc(role_judge_left_num,RoleId) of
		{ok,[{_,RoleId,Info}]}->{RoleId,Info};
		_->[]
	end.

get_role_judge_num(RoleId)->
	case dal:read_rpc(role_judge_num,RoleId) of
		{ok,[{_,RoleId,DisdainNum,PraisedNum}]}->{RoleId,DisdainNum,PraisedNum};
		_-> []
	end.

add_to_judge_left_num(RoleId,{LeftNum,LastTime})->
	dal:write_rpc({role_judge_left_num,RoleId,{LeftNum,LastTime}}).

add_to_judge_num(RoleId,DisdainNum,PraisedNum)->
	dal:write_rpc({role_judge_num,RoleId,DisdainNum,PraisedNum}).

