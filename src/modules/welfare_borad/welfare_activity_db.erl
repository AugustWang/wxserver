%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-8-6
%% Description: TODO: Add description to welfare_activity_db
-module(welfare_activity_db).

%%
%% Include files
%%
-include("active_board_def.hrl").
-include("welfare_activity_define.hrl").

%%
%% Exported Functions
%%
-export([get_welfare_activity_data/1,get_starttime/1,get_endtime/1,get_isshow/1,get_gift/1,get_condition/1]).

-export([read_exchange_ticket_from_db/1,write_exchange_ticket/2]).

-export([get_welfare_activity_gift/1,get_welfare_activty_condition/1]).

-export([write_record/3,load_role/2]).

-export([update_welfare_activity_rpc/0]).

-export([delete_background_welfare_data/1,write_background_welfare_data/1]).
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
	db_tools:create_table_disc(role_welfare_activity_info,record_info(fields,role_welfare_activity_info),[],set),
	db_tools:create_table_disc(welfare_activity_data,record_info(fields,welfare_activity_data),[],set),						   
	db_tools:create_table_disc(role_gold_exchange_info,record_info(fields,role_gold_exchange_info),[],set),
	db_tools:create_table_disc(background_welfare_data,record_info(fields,background_welfare_data),[],set).	

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_gold_exchange_info,RoleId),
	case dal:read_rpc(role_welfare_activity_info) of
		{ok,Results}->
			lists:foreach(fun(Object)->
					case element(#role_welfare_activity_info.roleid_type,Object) of
						{RoleId,_}->
							dal:delete_object_rpc(Object);
						_->
							nothing
					end	 
			end, Results);
		_->
			nothing
	end.
	

tables_info()->
	[{welfare_activity_data,proto},{background_welfare_data,disc},{role_welfare_activity_info,disc},{role_gold_exchange_info,disc}].

create()->
	ets:new(?WELFARE_ACTIVITY_DATA,[set,public,named_table]).

init()->
	init_welfare_activity_data().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_welfare_activity_data()->
	ets:delete_all_objects(?WELFARE_ACTIVITY_DATA),
	case dal:read_rpc(welfare_activity_data) of
		{ok,Results}->
			[];
		_->
			Results =[]
	end,
	lists:foreach(fun(Term)-> 
			ActivityNumber = erlang:element(#welfare_activity_data.type, Term),
			case dal:read_rpc(background_welfare_data,ActivityNumber) of
				{ok,[]}->
					ets:insert(?WELFARE_ACTIVITY_DATA, {ActivityNumber,Term});
				{ok,[{_,_,Isshow,StartTime,EndTime}]}->
					Object =Term#welfare_activity_data{isshow = Isshow,starttime = StartTime,endtime = EndTime},
					ets:insert(?WELFARE_ACTIVITY_DATA, {ActivityNumber,Object});
				ERROR->
					ets:insert(?WELFARE_ACTIVITY_DATA, {ActivityNumber,Term}),
					slogger:msg("add_welfare_activity_data_to_ets,error,ERROR:~p~n",[ERROR])
			end	end, Results).
		

get_welfare_activity_data(ActivityNumber)->
	case ets:lookup(?WELFARE_ACTIVITY_DATA, ActivityNumber) of
		[]->
			[];
        [{ActivityNumber,ActivityInfo}]-> ActivityInfo 
	end.

get_starttime(ActivityInfo)->
	erlang:element(#welfare_activity_data.starttime,ActivityInfo).
get_endtime(ActivityInfo)->
	erlang:element(#welfare_activity_data.endtime, ActivityInfo).
get_isshow(ActivityInfo)->
	erlang:element(#welfare_activity_data.isshow,ActivityInfo).
get_gift(ActivityInfo)->
	erlang:element(#welfare_activity_data.gift,ActivityInfo).
get_condition(ActivityInfo)->
	erlang:element(#welfare_activity_data.condition, ActivityInfo).

get_welfare_activity_gift(ActivityNumber)->
	case ets:lookup(?WELFARE_ACTIVITY_DATA,ActivityNumber) of
		[]->
			slogger:msg("welfare table no activity gift data ,ActivityNumber:~p~n",[ActivityNumber]),
			[];
		[{ActivityNumber,ActivityInfo}]->
			erlang:element(#welfare_activity_data.gift, ActivityInfo)
	end.


get_welfare_activty_condition(ActivityNumber)->
	case ets:lookup(?WELFARE_ACTIVITY_DATA,ActivityNumber) of
		[]->
			slogger:msg("welfare table no activity condition data ,ActivityNumber:~p~n",[ActivityNumber]),
			[];
		[{ActivityNumber,ActivityInfo}]->
			erlang:element(#welfare_activity_data.condition, ActivityInfo)
	end.
	

%%write data to db 	
write_record(RoleId,ActivityNumber,SerialNumber)->
	case dal:read_rpc(role_welfare_activity_info, {RoleId,ActivityNumber}) of
		{ok,[]}->
			Object = #role_welfare_activity_info{roleid_type = {RoleId,ActivityNumber},serialnumber = [SerialNumber]},
			dal:write_rpc(Object);
		{ok,[{_,_,OldSerialNumber}]}->
			Object = #role_welfare_activity_info{roleid_type = {RoleId,ActivityNumber},serialnumber = [SerialNumber|OldSerialNumber]},
			dal:write_rpc(Object);
		ERROR->
			slogger:msg("gold_exchange,init,read table error:~p~n",[ERROR])
	end.		
load_role(RoleId,ActivityNumber)-> 
	case dal:read_rpc(role_welfare_activity_info, {RoleId,ActivityNumber}) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.

%%
%%db operate 
%% 
read_exchange_ticket_from_db(RoelId)->
	case dal:read_rpc(role_gold_exchange_info,RoelId) of
		{ok,[{_,_,ExchangeTicket}]}->
			ExchangeTicket;
		_->
			[]		
	end.

write_exchange_ticket(RoleId,ExchangeTicket)->
%% 	io:format("async_write,ExchangeTicket:~p~n",[ExchangeTicket]),
	Object =#role_gold_exchange_info{roleid=RoleId,exchange_ticket=ExchangeTicket},
	dal:write_rpc(Object).

delete_background_welfare_data(Id)->
	case dal:delete_rpc(background_welfare_data, Id) of
		{ok}->
			ok;
		_->
			error 
	end.

write_background_welfare_data(Term)->
	Object = util:term_to_record(Term,background_welfare_data),
	case dal:write_rpc(Object) of
		{ok}->
			ok;
		_->
			error
	end.

update_welfare_activity_rpc()->
	lists:foreach(fun(N)-> rpc:call(N,?MODULE,init,[]) end ,node_util:get_mapnodes()).
	