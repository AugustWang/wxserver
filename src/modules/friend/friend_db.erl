%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-11-16
%% Description: TODO: Add description to friend_db
-module(friend_db).

%%
%% Include files
%%
-include("friend_struct_def.hrl").
-include("common_define.hrl").
-include_lib("stdlib/include/qlc.hrl").
%%
%% Exported Functions
%%


-export([get_friend_by_type/2,get_befriend_by_type/2,add_friend_to_mnesia/1,delete_friend_to_mnesia/1,
		 get_signature_by_roleid/1,add_signature_to_mnesia/1,add_black_to_mnesia/1,delete_black_to_mnesia/1]).

-export([change_role_name_in_db/2]).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(friend, record_info(fields,friend), [fid], bag),
	db_tools:create_table_disc(black, record_info(fields,black), [fid], bag),
	db_tools:create_table_disc(signature, record_info(fields,signature), [], set).		

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(RoleId)->
	dal:delete_rpc(signature,RoleId),
	case dal:read_rpc(friend,RoleId) of
		{ok,Results1}->
			lists:foreach(fun(Object)-> dal:delete_object_rpc(Object) end, Results1);
		_->
			nothing
	end,
	case dal:read_rpc(black,RoleId) of
		{ok,Results2}->
			lists:foreach(fun(Object)-> dal:delete_object_rpc(Object) end, Results2);
		_->
			nothing
	end,
	case dal:read_index_rpc(black,RoleId,#black.fid) of
		{ok,Results3}->
			lists:foreach(fun(Object)-> dal:delete_object_rpc(Object) end, Results3);
		_->
			nothing
	end,
	case dal:read_index_rpc(friend,RoleId,#friend.fid) of
		{ok,Results4}->
		  	lists:foreach(fun(Object)-> dal:delete_object_rpc(Object) end, Results4);
		_->
			nothing
	end.

tables_info()->
	[{friend,disc},{black,disc},{signature,disc}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
change_role_name_in_db(RoleId,NewName)->
	case dal:read_index_rpc(black,RoleId,#black.fid) of
		{ok,Results3}->
			dal:delete_index_rpc(black, RoleId, #black.fid),
			lists:foreach(fun(Object)-> dal:write_rpc(Object#black{fname = NewName}) end, Results3);
		_->
			nothing
	end,
	case dal:read_index_rpc(friend,RoleId,#friend.fid) of
		{ok,Results4}->
			dal:delete_index_rpc(friend, RoleId, #friend.fid),
		  	lists:foreach(fun(Object)->  dal:write_rpc(Object#friend{fname = NewName}) end, Results4);
		_->
			nothing
	end.

%%
%% API Functions
%%
get_friend_by_type(Ntype,RoldId)->
	try
%%		ReadFun = fun()->
			case Ntype of
				0 ->
					dal:read_rpc(friend,RoldId);
				_ ->
					dal:read_rpc(black,RoldId)
			end
	catch
		E:R-> slogger:msg("get_friend_by_type/2 ~pR~p~n",[E,R])
	end.

get_befriend_by_type(Ntype,RoleId)->
	try
			case Ntype of
				0 ->
					dal:read_index_rpc(friend,RoleId,#friend.fid);
				_ ->
					dal:read_index_rpc(black,RoleId,#friend.fid)
			end
	catch
		E:R-> slogger:msg("get_friend_by_type/2 ~pR~p~n",[E,R])
	end.

get_signature_by_roleid(RoleId)->
	try
		dal:read_rpc(signature,RoleId)	
	catch
		E:R-> slogger:msg("get_friend_by_type/2 ~pR~p~n",[E,R])
	end.

add_signature_to_mnesia(Record)->
	try
		dal:write_rpc(Record)
	catch
		E:R-> slogger:msg("add_signature_to_mnesia ~p exception E(~p):R(~p) \n",[Record,E,R])
	end.

add_friend_to_mnesia(Record)->
	try
		dal:write_rpc(Record)
	catch
		E:R-> slogger:msg("add_friend_to_mnesia ~p exception E(~p):R(~p) \n",[Record,E,R])
	end.

delete_friend_to_mnesia(Record)->
	try
		dal:delete_object_rpc(Record)
	catch
		E:R-> slogger:msg("delete_friend_to_mnesia ~p exception E(~p):R(~p) \n",[Record,E,R])
	end.

add_black_to_mnesia(Record)->
	try
		dal:write_rpc(Record)
	catch
		E:R-> slogger:msg("add_black_to_mnesia ~p exception E(~p):R(~p) \n",[Record,E,R])
	end.

delete_black_to_mnesia(Record)->
	try
		dal:delete_object_rpc(Record)
	catch
		E:R-> slogger:msg("delete_black_to_mnesia ~p exception E(~p):R(~p) \n",[Record,E,R])
	end.
	
	
%%
%% Local Functions
%%

