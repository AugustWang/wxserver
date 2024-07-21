%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: yanzengyan
%% Created: 2012-9-5
%% Description: TODO: Add description to payment_db
-module(payment_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").

%%
%% Exported Functions
%%

-export([start/0, create_mnesia_table/1, create_mnesia_split_table/2, delete_role_from_db/1, tables_info/0]).
-export([recharge/5, consume/10, read_recharge/0, read_consume/0]).

-behaviour(db_operater_mod).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(recharge1,record_info(fields,recharge1),[],bag),
	db_tools:create_table_disc(consume, record_info(fields,consume), [], bag).

create_mnesia_split_table(_, _)->
	nothing.

delete_role_from_db(_)->
	nothing.
	
tables_info()->
	[{recharge1,disc},{consume,disc}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% API Functions
%%

recharge(Time, Uid, MoneyCount, Platform, YellowVipLevel) ->
	Data = #recharge1{datetime = Time, uid = Uid, money = MoneyCount, platform = Platform,
					  vip_level = YellowVipLevel},
	dal:write_rpc(Data).

consume(BillNo, Uid, Time, BoundGold, QQGold, YellowVipLevel, Item, Count, Price, Platform) ->
	Data = #consume{billno = BillNo, uid = Uid, datetime = Time, bound_gold = BoundGold, 
					platform_gold = QQGold, vip_level = YellowVipLevel, item = Item, num = Count, price = Price, 
					platform = Platform},
	dal:write_rpc(Data).

read_recharge() ->
	case dal:read_rpc(recharge1) of
		{ok, Result} ->
			Result;
		_ ->
			slogger:msg("read recharge, no data"),
			[]
	end.

read_consume() ->
	case dal:read_rpc(consume) of
		{ok, Result} ->
			Result;
		_ ->
			slogger:msg("read recharge, no data"),
			[]
	end.

%%
%% Local Functions
%%



