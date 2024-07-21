%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-9-1
-module(tangle_battle_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("common_define.hrl").
-include_lib("stdlib/include/qlc.hrl").
-record(tangle_battle_kill_info,{date_class,info}).
-export([load_tangle_battle_info/0,sync_add_battle_info/5,delete_tangle_battle_info/1]).
-export([load_tangle_battle_kill_info/0,sync_add_tangle_battle_kill_info/4,delete_tangle_battle_kill_info/1,
		 get_role_totle_killnum/1,add_tangle_battle_role_killnum/2,clear_battle_info/0,clear_battle_kill_info/0]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(tangle_battle, record_info(fields,tangle_battle), [], set),
	db_tools:create_table_disc(tangle_battle_kill_info, record_info(fields,tangle_battle_kill_info), [], set),
	db_tools:create_table_disc(tangle_battle_role_killnum, record_info(fields,tangle_battle_role_killnum), [], set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{tangle_battle,disc},{tangle_battle_kill_info,disc},{tangle_battle_role_killnum,disc}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load_tangle_battle_info()->
	case dal:read_rpc(tangle_battle) of
		{ok,TangleBattleInfo}-> TangleBattleInfo;
		{failed,_Reason}-> [];
		{failed,badrpc,_Reason}-> []
	end.

sync_add_battle_info(Date,Class,Index,Info,RewardRecord)->
	dmp_op:sync_write({Date,Class,Index},{tangle_battle,{Date,Class,Index},Info,RewardRecord}).

clear_battle_info()->
	dal:clear_table_rpc(tangle_battle).

delete_tangle_battle_info(Key)->
	dal:delete_rpc(tangle_battle,Key).

load_tangle_battle_kill_info()->
	case dal:read_rpc(tangle_battle_kill_info) of
		{ok,TangleKillInfo}-> TangleKillInfo;
		{failed,_Reason}-> [];
		{failed,badrpc,_Reason}-> []
	end.

clear_battle_kill_info()->
	dal:clear_table_rpc(tangle_battle_kill_info).

sync_add_tangle_battle_kill_info(Date,Class,Index,KillInfo)->
	dmp_op:sync_write({Date,Class,Index},{tangle_battle_kill_info,{Date,Class,Index},KillInfo}).

delete_tangle_battle_kill_info(Key)->
	dal:delete_rpc(tangle_battle_kill_info,Key).

add_tangle_battle_role_killnum(RoleId,KillNum)->
	dal:write_rpc({tangle_battle_role_killnum,RoleId,KillNum}).

get_role_totle_killnum(RoleId)->
	case dal:read_rpc(tangle_battle_role_killnum,RoleId) of
		{ok,[{_,_,Num}]}->
			Num;
		_->
			0
	end.