%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-10-31
%% Description: TODO: Add description to country_db
-module(country_db).

%%
%% Include files
%%
-include("country_def.hrl").

-define(ETS_TABLE,country_proto_ets).
%%
%% Exported Functions
%%
-export([get_info/1,get_allinfo/0]).

-export([get_num/1,get_items_by_level/2,get_reward/1,get_blocktalktimes/1,get_remittimes/1,get_punishtimes/1,get_appointtimes/1]).
-export([get_items_useful_time_s/1]).

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
	db_tools:create_table_disc(country_proto,record_info(fields,country_proto),[],set),
	db_tools:create_table_disc(country_record,record_info(fields,country_record),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{country_proto,proto},{country_record,disc}].

delete_role_from_db(_)->
	nothing.

create()->
	ets:new(?ETS_TABLE,[set,public,named_table]).

init()->
	db_operater_mod:init_ets(country_proto, ?ETS_TABLE,#country_proto.post).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_allinfo()->
	ets:foldl(fun({Id,Term},Acc)->
					  Num = get_num(Term),
					  Acc ++ lists:map(fun(Index)-> {Id,Index} end, lists:seq(1, Num))
			end, [], ?ETS_TABLE).

get_info(Id)->
	try
		case ets:lookup(?ETS_TABLE, Id) of
			[]->
				[];
            [Info]-> 
				{_,Term} = Info,
				Term
		end
	catch
		_:_-> []
	end.

get_num(Term)->
	erlang:element(#country_proto.num,Term).

get_items_by_level(Term,Level)->
	if
		Level < 50->				%% level 1 - 49
			erlang:element(#country_proto.items_l30,Term);
		Level < 70->				%% level 50 -69
			erlang:element(#country_proto.items_l50,Term);
		true->						%% level 70 - 100
			erlang:element(#country_proto.items_l70,Term)
	end.

get_reward(Term)->
	erlang:element(#country_proto.reward,Term).

get_blocktalktimes(Term)->
	erlang:element(#country_proto.blocktalktimes,Term).

get_remittimes(Term)->
	erlang:element(#country_proto.remittimes,Term).

get_punishtimes(Term)->
	erlang:element(#country_proto.punishtimes,Term).

get_appointtimes(Term)->
	erlang:element(#country_proto.appointtimes,Term).

get_items_useful_time_s(Term)->
	erlang:element(#country_proto.items_useful_time_s,Term).

