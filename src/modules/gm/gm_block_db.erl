%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(gm_block_db).
-include("mnesia_table_def.hrl").
-include("common_define.hrl").
-include_lib("stdlib/include/qlc.hrl").

-export([add_user/3,get_block_info/2,get_start_time/1,get_duration_time/1,delete_user/2,check_block_info/2]).

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
	db_tools:create_table_disc(gm_blockade, record_info(fields,gm_blockade),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(RoleId)->
	dal:delete_rpc(gm_blockade,{RoleId,talk}),
	dal:delete_rpc(gm_blockade,{RoleId,login}),
	dal:delete_rpc(gm_blockade,{RoleId,connect}).

tables_info()->
	[{gm_blockade,disc}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%DurationTime<=2147483647,forever DurationTime=0,
add_user(UserId,talk,DurationTime)->
	StartTime = timer_center:get_correct_now(),
	dal:write_rpc({gm_blockade,{UserId,talk},StartTime ,DurationTime});
	
add_user(UserId,login,DurationTime)->
	StartTime = timer_center:get_correct_now(),
	dal:write_rpc({gm_blockade,{UserId,login},StartTime ,DurationTime});

add_user(IpAddress,connect,DurationTime)->
	StartTime = timer_center:get_correct_now(),
	dal:write_rpc({gm_blockade,{IpAddress,connect},StartTime ,DurationTime}).

delete_user(UserId,login)->
	dal:delete_rpc(gm_blockade,{UserId,login});

delete_user(UserId,talk)->
	dal:delete_rpc(gm_blockade,{UserId,talk});

delete_user(IpAddress,connect)->
	dal:delete_rpc(gm_blockade,{IpAddress,connect}).
	
get_block_info(UserId,talk)->
	case dal:read_rpc(gm_blockade,{UserId,talk}) of
		{ok,[BlockInfo]}->
			BlockInfo;
		_->
			[]
	end;
	
get_block_info(UserId,login)->
	case dal:read_rpc(gm_blockade,{UserId,login}) of
		{ok,[BlockInfo]}->
			BlockInfo;
		_->
			[]
	end;

get_block_info(IpAddress,connect)->
	case dal:read_rpc(gm_blockade,{IpAddress,connect}) of
		{ok,[BlockInfo]}->
			BlockInfo;
		_->
			[]
	end.
	
get_start_time(BlockInfo)->
	erlang:element(#gm_blockade.start_time, BlockInfo).

get_duration_time(BlockInfo)->
	erlang:element(#gm_blockade.duration_time, BlockInfo).

check_block_info(ClientContext,BlockType)->
	case gm_block_db:get_block_info(ClientContext,BlockType) of
		[]->
			BlockTime = -1;
		BlockInfo->
			StartTime = gm_block_db:get_start_time(BlockInfo),
			DurationTime = gm_block_db:get_duration_time(BlockInfo),
			LeftTime = erlang:trunc(DurationTime - (timer:now_diff(timer_center:get_correct_now(),StartTime) )/(1000*1000)),
			if
				DurationTime =:= 0->
					BlockTime = 0;
				LeftTime <0->
					BlockTime = -1,
					gm_block_db:delete_user(ClientContext,BlockType);
				true->
					BlockTime = LeftTime
			end
	end.