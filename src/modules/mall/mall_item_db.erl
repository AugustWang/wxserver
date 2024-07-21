%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaodya
%% Created: 2010-11-3
%% Description: TODO: Add description to mall_proto_db
-module(mall_item_db).
%% 
%% define
%% 
-define(HOT_ITEM_INFO_ETS,hot_item_info_table).
-define(SPECIAL_TYPE_201,201). %%tianzhu
-define(SPECIAL_TYPE_202,202). %%offline
-define(SPECIAL_TYPE_203,203). %%vip
-define(SPECIAL_TYPE_204,204). %%venation
-define(SPECIAL_TYPE_205,205). %%hotitem
%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("common_define.hrl").
-include_lib("stdlib/include/qlc.hrl").
%%
%% Exported Functions
%%
-export([init_hot_item/0,get_hot_item/0,add_mall_item_info_to_mnesia/1,
		 get_allInfo/0,get_item_info/1,get_up_sales_info/1,import_mall_item_info/1,
		 update_mall_item_rpc_call/2,update_mall_item/2,
		 update_sales_item_rpc_call/2,update_sales_item/2,
		 sync_update_role_buy_mall_item_to_mnesia/2,sync_update_role_buy_log_to_mnesia/2,
		 get_mallinfo_by_type_rpc_call/1,
		 get_mallinfo_by_special_type_rpc_call/1,
		 get_mallinfo_by_sales_type_rpc_call/1,
		 get_sales_item_by_type_rpc_call/1,
		 get_mallinfo_by_type/1,
		 get_mallinfo_by_special_type/1,
		 get_mallinfo_by_sales_type/1,
		 get_sales_item_by_type/1,
		 get_all_sales_item_info/0,
		 get_role_buy_mall_item/1,
		 get_role_buy_log/1,
		 update_by_gm/7,
		 delete_up_sales_item/1,
		 add_sales_item_info_to_mnesia/1]).

-export([get_sales_time_from_iteminfo/1,
		 get_sort_from_iteminfo/1,
		 get_price_from_iteminfo/1,
		 get_discount_from_iteminfo/1,
		 get_duration_from_iteminfo/1,
		 get_restrict_from_iteminfo/1,
		 get_bodcast_from_iteminfo/1,
		 get_uptime_from_iteminfo/1,
		 get_id_from_iteminfo/1,
		 get_ntype_from_iteminfo/1,
		 get_name_from_iteminfo/1
		]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
	db_tools:create_table_disc(mall_item_info, record_info(fields,mall_item_info), [], set),
	db_tools:create_table_disc(role_buy_mall_item, record_info(fields,role_buy_mall_item), [], set),
	db_tools:create_table_disc(role_buy_log, record_info(fields,role_buy_log), [], set),
	db_tools:create_table_disc(mall_sales_item_info, record_info(fields,mall_sales_item_info), [], set),
	db_tools:create_table_disc(mall_up_sales_table, record_info(fields,mall_up_sales_table), [], set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_buy_log, RoleId),
	dal:delete_rpc(role_buy_mall_item, RoleId).

tables_info()->
	[{mall_item_info,proto},{role_buy_mall_item,disc},{role_buy_log,disc},{mall_sales_item_info,proto},{mall_up_sales_table,disc}].

create()->
	ets:new(?HOT_ITEM_INFO_ETS,[set,public,named_table]).

init()->
	ets:delete_all_objects(?HOT_ITEM_INFO_ETS),
	init_hot_item().
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init_hot_item()->
	case get_mallinfo_by_type_rpc_call(101) of
		[]->
			slogger:msg("init_hot_item failed!~n");
		Result->
			lists:foreach(fun(Term)->
								  {_,ItemId,_,_,_,Price,Discount} = Term,
								  case lists:member(ItemId,env:get(hot_item, [])) of
									  true->
										  add_hot_item_to_ets(ItemId,Price,Discount);
									  false->
										  nothing
								  end
						  end, Result)
	end.

add_hot_item_to_ets(ItemId,Price,Discount)->
	try
		ets:insert(?HOT_ITEM_INFO_ETS, {ItemId,Price,Discount})
	catch
		_:_->
			error
	end.

get_hot_item()->
    try
		ets:tab2list(?HOT_ITEM_INFO_ETS)
	catch
		_:_-> []
	end.

get_allInfo()->
	case dal:read_rpc(mall_item_info) of
		{ok,[]}-> {ok,[]};
		{ok,Result}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("mall_item_db:get_allInfo failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("mall_item_db:get_allInfo failed :~p~n",[Reason])
	end.

get_mallinfo_by_type_rpc_call(Ntype)->
	rpc:call(node_util:get_dbnode(), ?MODULE, get_mallinfo_by_type, [Ntype]).

get_mallinfo_by_special_type_rpc_call(Ntype2)->
	rpc:call(node_util:get_dbnode(), ?MODULE, get_mallinfo_by_special_type, [Ntype2]).

get_mallinfo_by_sales_type_rpc_call(Ntype)->
	rpc:call(node_util:get_dbnode(), ?MODULE, get_mallinfo_by_sales_type, [Ntype]).

get_sales_item_by_type_rpc_call(Ntype)->
	rpc:call(node_util:get_dbnode(), ?MODULE, get_sales_item_by_type, [Ntype]).

get_mallinfo_by_type(Ntype)->
	try
		S = fun()->
			case Ntype of
				0 ->
					Q = qlc:q([{X#mall_item_info.id,
								0,
								X#mall_item_info.ishot,
								X#mall_item_info.sort,
								util:term_to_record_for_list(X#mall_item_info.price, ip),
								util:term_to_record_for_list(X#mall_item_info.discount,di)} || X<-mnesia:table(mall_item_info),
																							   X#mall_item_info.ishot =:= 1
 					  ]),
 					qlc:e(Q);
				101 ->
					Q = qlc:q([{X#mall_item_info.id,
								101,
								X#mall_item_info.ishot,
								X#mall_item_info.sort,
								util:term_to_record_for_list(X#mall_item_info.price, ip),
								util:term_to_record_for_list(X#mall_item_info.discount,di)} || X<-mnesia:table(mall_item_info)
 					  ]),
 					qlc:e(Q);
				_ ->
					Q = qlc:q([{X#mall_item_info.id,
								X#mall_item_info.ntype,
								X#mall_item_info.ishot,
								X#mall_item_info.sort,
								util:term_to_record_for_list(X#mall_item_info.price, ip),
								util:term_to_record_for_list(X#mall_item_info.discount,di)} || X<-mnesia:table(mall_item_info),
																							   X#mall_item_info.ntype=:=Ntype
 					  ]),
 					qlc:e(Q)
 			end
		end,						
		case mnesia:transaction(S) of
			{aborted, _Reason} -> [];
			{atomic, []}	-> [];
			{atomic, MallItemList} -> 
				util:term_to_record_for_list(MallItemList,mi)		
		end
	catch
		E:R-> slogger:msg("get_mallinfo_by_type/1 ~pR~p~n",[E,R])
	end.

get_mallinfo_by_special_type(Ntype2)->
	try
		S = fun()->
				Q = qlc:q([{X#mall_item_info.id,
							X#mall_item_info.special_type,
							X#mall_item_info.ishot,
							X#mall_item_info.sort,
							util:term_to_record_for_list(X#mall_item_info.price, ip),
							util:term_to_record_for_list(X#mall_item_info.discount,di)} || X<-mnesia:table(mall_item_info),
																						   X#mall_item_info.special_type=:=Ntype2
				  ]),
				qlc:e(Q)
 			end,
		case mnesia:transaction(S) of
			{aborted, _Reason} -> [];
			{atomic, []}	-> [];
			{atomic, MallItemList} -> 
				util:term_to_record_for_list(MallItemList,mi)		
		end
	catch
		E:R-> slogger:msg("get_mallinfo_by_special_type/1 ~pR~p~n",[E,R])
	end.

get_mallinfo_by_sales_type(_Ntype)->
	case dal:read_rpc(mall_up_sales_table) of
		{ok,[]}->
			[];
		{ok,Result}->
			Result
	end.

delete_up_sales_item(Id)->
	dal:delete_rpc(mall_up_sales_table, Id).

get_all_sales_item_info()->
	case dal:read_rpc(mall_sales_item_info) of
		{ok,[]}->
			[];
		{ok,Result}->
			Result
	end.

get_sales_item_by_type(Ntype)->
	try
		S = fun()->
				Q = qlc:q([X || X<-mnesia:table(mall_sales_item_info),
								X#mall_item_info.ntype=:=Ntype
				  ]),
				qlc:e(Q)
 			end,
		case mnesia:transaction(S) of
			{aborted, _Reason} -> [];
			{atomic, []}	-> [];
			{atomic, MallItemList} -> MallItemList
		end
	catch
		E:R-> slogger:msg("get_sales_item_by_type/1 ~pR~p~n",[E,R])
	end.
	
get_item_info(ItemId)->
	case dal:read_rpc(mall_item_info,ItemId) of
		{ok,[]}-> {ok,[]};
		{ok,[Result]}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_item_info failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_item_info failed :~p~n",[Reason])
	end.

get_up_sales_info(ItemId)->
	case dal:read_rpc(mall_up_sales_table,ItemId) of
		{ok,[]}-> {ok,[]};
		{ok,[Result]}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_up_sales_info failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_up_sales_info failed :~p~n",[Reason])
	end.

get_role_buy_mall_item(RoleId)->
	case dal:read_rpc(role_buy_mall_item,RoleId) of
		{ok,[]}-> [];
		{ok,[Result]}-> Result;
		{failed,badrpc,Reason}-> slogger:msg("get_role_buy_mall_item failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_role_buy_mall_item failed :~p~n",[Reason])
	end.

get_role_buy_log(RoleId)->
	case dal:read_rpc(role_buy_log,RoleId) of
		{ok,[]}-> [];
		{ok,[Result]}-> Result;
		{failed,badrpc,Reason}-> slogger:msg("get_role_buy_log failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_role_buy_log failed :~p~n",[Reason])
	end.

update_mall_item_rpc_call(ItemId,ItemCount)->
	rpc:call(node_util:get_dbnode(), ?MODULE, update_mall_item, [ItemId,ItemCount]).

update_sales_item_rpc_call(ItemId,ItemCount)->
	rpc:call(node_util:get_dbnode(), ?MODULE, update_sales_item, [ItemId,ItemCount]).

update_mall_item(ItemId,ItemCount)->
	Q = fun()->
			[OldItem] = mnesia:read(mall_item_info,ItemId),
			Discount = OldItem#mall_item_info.discount,
			{2,LimitCount} = lists:keyfind(2, 1, Discount),
			NewDiscount = lists:keyreplace(2, 1, Discount, {2,LimitCount-ItemCount}),
			New = OldItem#mall_item_info{discount=NewDiscount}, 
			dal:write(New)
		end,
	case mnesia:transaction(Q) of
		{aborted, Reason} ->
			{failed,Reason};
		{atomic,_}-> {ok,ItemId}
	end.

update_sales_item(ItemId,ItemCount)->
	Q = fun()->
			case mnesia:read(mall_up_sales_table,ItemId) of
				[]->
					nothing;
				[OldItem]->
					Discount = OldItem#mall_up_sales_table.discount,
					{2,LimitCount} = lists:keyfind(2, 1, Discount),
					NewDiscount = lists:keyreplace(2, 1, Discount, {2,LimitCount-ItemCount}),
					New = OldItem#mall_up_sales_table{discount=NewDiscount}, 
					dal:write(New)
			end
		end,
	case mnesia:transaction(Q) of
		{aborted, Reason} ->
			{failed,Reason};
		{atomic,_}-> {ok,ItemId}
	end.

update_by_gm(ItemId,Ntype,SpecialType,Ishot,Sort,Price,Discount)->
	Q = fun()->
			[OldItem] = mnesia:read(mall_item_info,ItemId),
			New = OldItem#mall_item_info{ntype=Ntype,special_type=SpecialType,ishot=Ishot,sort=Sort,price=Price,discount=Discount}, 
			mnesia:write(New)
		end,
	case mnesia:transaction(Q) of
		{aborted, Reason} ->
			{error,Reason};
		{atomic,_}-> {ok,integer_to_list(ItemId)}
	end.
%%
%% Local Functions
%%
import_mall_item_info(File)->
	mnesia:clear_table(mall_item_info),
	case file:consult(File) of
			{ok,[Terms]}->
				lists:foreach(fun(Term)-> add_mall_item_info_to_mnesia(Term) end,Terms);
			{error,Reason} ->
				slogger:msg("import_mall_item_info error:~p~n",[Reason])
	end.

add_mall_item_info_to_mnesia(Term)->
	try
		Object = util:term_to_record(Term,mall_item_info),
		S = fun()->
			mnesia:write(Object)
			end,
		mnesia:transaction(S)
	catch
		_:_-> error
	end.

add_sales_item_info_to_mnesia(Term)->
	try
		Object = util:term_to_record(Term,mall_sales_item_info),
		S = fun()->
			mnesia:write(Object)
			end,
		mnesia:transaction(S)
	catch
		_:_-> error
	end.

sync_update_role_buy_mall_item_to_mnesia(_RoleId,Term)->
	Object = util:term_to_record(Term,role_buy_mall_item),
	dal:write_rpc(Object).

sync_update_role_buy_log_to_mnesia(_RoleId,Term)->
	Object = util:term_to_record(Term,role_buy_log),
	dal:write_rpc(Object).



get_id_from_iteminfo(Info)->
	erlang:element(#mall_sales_item_info.id, Info).

get_ntype_from_iteminfo(Info)->
	erlang:element(#mall_sales_item_info.ntype, Info).

get_name_from_iteminfo(Info)->
	erlang:element(#mall_sales_item_info.name, Info).
	
get_sales_time_from_iteminfo(Info)->
	erlang:element(#mall_sales_item_info.sales_time, Info).

get_price_from_iteminfo(Info)->
	erlang:element(#mall_sales_item_info.price, Info).

get_discount_from_iteminfo(Info)->
	erlang:element(#mall_sales_item_info.discount, Info).

get_sort_from_iteminfo(Info)->
	erlang:element(#mall_sales_item_info.sort, Info).

get_duration_from_iteminfo(Info)->
	erlang:element(#mall_sales_item_info.duration, Info).

get_restrict_from_iteminfo(Info)->
	erlang:element(#mall_sales_item_info.restrict, Info).

get_bodcast_from_iteminfo(Info)->
	erlang:element(#mall_sales_item_info.bodcast, Info).

get_uptime_from_iteminfo(Info)->
	erlang:element(#mall_up_sales_table.uptime, Info).


