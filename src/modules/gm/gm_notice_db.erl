%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaodya
%% Created: 2010-10-26
%% Description: TODO: Add description to gm_notice_db
-module(gm_notice_db).
-include("mnesia_table_def.hrl").
-include("common_define.hrl").
-include_lib("stdlib/include/qlc.hrl").
%%
%% Include files
%%

-export([add_gm_notice/7,update_gm_notice/1,get_gm_notice/1,get_gm_notice/2,delete_gm_notice/1,hide_gm_notice/2]).
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
	db_tools:create_table_disc(gm_notice, record_info(fields,gm_notice) , [], set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{gm_notice,disc}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% Exported Functions
%%
add_gm_notice(Id, Ntype, Left_count, Begin_time, End_time, Interval_time, Notice_content) ->
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	Last_notice_time = MegaSec*1000000 + Sec,
	case dal:write_rpc({gm_notice,Id,Ntype,Left_count,Begin_time,End_time,Interval_time,Notice_content,Last_notice_time}) of
		{ok}->
			{ok,integer_to_list(Id)};
		_->
			{failed,[]}
	end.

delete_gm_notice(Id)->
	dal:delete_rpc(gm_notice,Id).

hide_gm_notice(Id,Count)->
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	CutTime = MegaSec*1000000 + Sec,
	case dal:read_rpc(gm_notice,Id) of
		{ok,[OldNotice]}->		
			New = OldNotice#gm_notice{left_count=Count,last_notice_time=CutTime}, 
			dal:write_rpc(New);
		_->
			nothing
	end.

update_gm_notice(Id)->
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	CutTime = MegaSec*1000000 + Sec,
	case dal:read_rpc(gm_notice,Id) of
		{ok,[OldNotice]}->
			Left_count = OldNotice#gm_notice.left_count - 1,
			New = OldNotice#gm_notice{left_count=Left_count,last_notice_time=CutTime}, 
			dal:write_rpc(New);
		_->
			nothing
	end.

get_gm_notice(CurTime,Id) ->
	slogger:msg("get_gm_notice Id: ~p~n",[Id]),
	case dal:read_rpc(gm_notice,Id) of
		{ok,[GmNotice]}->
			case (GmNotice#gm_notice.begin_time=<CurTime) and (GmNotice#gm_notice.end_time>=CurTime) of
			true->
				GmNotice;
				_->
					[]
				end;
		_->[]
	end.
	
get_gm_notice(CurTime) ->
	S = fun()->
		Q = qlc:q([X|| X<-mnesia:table(gm_notice),
					   X#gm_notice.begin_time=<CurTime,
					   X#gm_notice.end_time>=CurTime,
					   CurTime-X#gm_notice.last_notice_time>=X#gm_notice.interval_time/1000,
					   ((X#gm_notice.left_count>0) or (X#gm_notice.left_count=:=unlimited))
				  ]),
		qlc:e(Q)
		end,
	case dal:run_transaction_rpc(S) of
		{ok,Result}->
			Result;
		_->
			[]
	end.
		
	
%%
%% API Functions
%%



%%
%% Local Functions
%%

