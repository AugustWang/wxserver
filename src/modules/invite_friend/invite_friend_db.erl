%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhangting 
%% Created: 2012-7-10
%% Description: TODO: Add description to invite_friend_db
-module(invite_friend_db).

%%
%% Include files
%%
-define(ETS_TABLE_NAME,invite_friend_gift_ets).
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
-include("invite_friend_def.hrl").

-export([start/0,create_mnesia_table/1,delete_role_from_db/1,tables_info/0,create_mnesia_split_table/2]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(invite_friend,record_info(fields,invite_friend),[],set),
	db_tools:create_table_disc(role_invite_friend_info,record_info(fields,role_invite_friend_info),[],set).
	

tables_info()->
	[{invite_friend,proto},{role_invite_friend_info,disc}].

delete_role_from_db(RoleId)->
	 dal:delete_rpc(role_invite_friend_info,RoleId).


create_mnesia_split_table(_,_)->
	nothing.

create()->
	ets:new(?ETS_TABLE_NAME,[set,named_table]).

init()->
	db_operater_mod:init_ets(invite_friend, ?ETS_TABLE_NAME,#invite_friend.amount).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	

get_info_gift(Amount)->
	case ets:lookup(?ETS_TABLE_NAME,Amount) of
		[]->[];
		[{_Amount,Value}] -> Value
	end.



get_invite_friend_info(RoleId)->
	case dal:read_rpc(role_invite_friend_info,RoleId) of
		{ok,[]}-> [];
		{ok,[Info]}-> Info;
		{failed,badrpc,Reason}-> slogger:msg("get_invite_friend_bonus failed ~p:~p~n",[badrpc,Reason]),[];
		{failed,Reason}-> slogger:msg("get_invite_friend_bonus failed :~p~n",[Reason]),[]
	end.

	
sync_updata(Term)->
	try
		Object = util:term_to_record(Term,role_invite_friend_info),
		dal:write_rpc(Object)
	catch
		E:R->
			%io:format("error ~p reason~p~n",[E,R]),
			error
	end.





