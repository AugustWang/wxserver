%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-5-7
%% Description: TODO: Add description to mnesia_operator
-module(mnesia_operator).
-compile(export_all).
%%
%% Author: adrianx
%% Created: 2010-10-25
%% Description: TODO: Add description to dal
-define(DAL_WRITE_RECORD,'ets_dal_write_record').
%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("common_define.hrl").
-include_lib("stdlib/include/qlc.hrl").
%%
%% Exported Functions
%%
-export([init/0,set_write_flag/0,get_write_flag/0]).

-export([read_rpc/2,read/2,read_index_rpc/3,read_index/3,read_rpc/1,read/1,run_transaction_rpc/1,run_transaction/1,index_match_object_rpc/2,index_match_object/2]).
-export([write_rpc/1,write_rpc/4,write_rpc/5,write/1,write/4,write/5,async_write_rpc/1,async_write/1]).
-export([delete_rpc/2,delete/2,delete/4,delete_rpc/4,delete_object_rpc/1,delete_object/1]).
-export([clear_table/1,clear_table_rpc/1,delete_index_rpc/3,delete_index/3]).

%%
%% API Functions
%%
init()->
	try 
		ets:new(?DAL_WRITE_RECORD, [set,named_table,public]) 
	catch 
		E:R-> 
			slogger:msg("init_dal_write_record Exception(~p:~p)~n", [E,R])
	end.

%%
%% Local Functions
%%

read_rpc(Table)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode->case rpc:call(DbNode, ?MODULE, read, [Table]) of
					 {badrpc,Reason}-> slogger:msg("read_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("read_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
					 {ok,Result}-> {ok,Result};
					 _Any-> {failed,"read_rpc Unknown error"}
				 end
	end.

read_rpc(Table,Key)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> 
				case rpc:call(DbNode, ?MODULE, read, [Table,Key]) of
					 {badrpc,Reason}-> slogger:msg("read_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("read_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
					 {ok,Result}-> {ok,Result};
					 _Any-> {failed,"read_rpc Unknown error"}
				 end
	end.

read_index_rpc(Table,SecondaryKey,Pos)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> case rpc:call(DbNode, ?MODULE, read_index, [Table,SecondaryKey,Pos]) of
					 {badrpc,Reason}-> slogger:msg("read_index_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("read_index_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
					 {ok,Result}-> {ok,Result};
					 _Any-> {failed,"read_rpc Unknown error"}
				 end
	end.

run_transaction_rpc(Trascation)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> case rpc:call(DbNode, ?MODULE, run_transaction, [Trascation]) of
					 {badrpc,Reason}-> slogger:msg("run_transaction_rpc error ~p ~n",[Reason]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("run_transaction_rpc error ~p ~n",[Reason]),{failed,Reason};
					 {ok,Result}-> {ok,Result};
					 _Any-> {failed,"read_rpc Unknown error"}
				 end
	end.

index_match_object_rpc(Pattern,Pos)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> case rpc:call(DbNode, ?MODULE, index_match_object, [Pattern,Pos]) of
					 {badrpc,Reason}-> slogger:msg("index_match_object_rpc error ~p Pattern ~p ~n",[Reason,Pattern]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("index_match_object_rpc error ~p Pattern ~p ~n",[Reason,Pattern]),{failed,Reason};
					 {ok,Result}-> {ok,Result};
					 _Any-> {failed,"read_rpc Unknown error"}
				 end
	end.
  
index_match_object(Pattern,Pos)-> 
	case catch mnesia:dirty_index_match_object(Pattern,Pos) of
		{'EXIT', Reason} ->
	    	slogger:msg("index_match_object error ~p Pattern ~p ~n",[Reason,Pattern]),{failed,Reason};
		Result when is_list(Result) -> {ok,Result};
		Result->
			slogger:msg("index_match_object error ~p Pattern ~p ~n",[Result,Pattern]),{failed,Result}
	end.

read(Table)->
	ReadFun = fun()-> qlc:e(qlc:q([X || X <- mnesia:table(Table)])) end,
	case mnesia:transaction(ReadFun) of
		{aborted,Reason} -> slogger:msg("read error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
		{atomic, []}	 -> {ok,[]};
		{atomic, Result}-> {ok,Result}
	end.
	
read(Table,Key)->
	case catch  mnesia:dirty_read({Table,Key}) of
		{'EXIT',Reason} -> slogger:msg("read error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
		Result when is_list(Result) -> {ok,Result};
		Result->
			slogger:msg("read error ~p ~n",[Result]),{failed,Result}
	end.

read_index(Table,SecondaryKey,Pos)->
	case catch  mnesia:dirty_index_read(Table, SecondaryKey, Pos) of
		{'EXIT',Reason} -> slogger:msg("read_index error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
		Result when is_list(Result)-> {ok,Result};
		Result->
			slogger:msg("read_index error ~p ~n",[Result]),{failed,Result}
	end.

run_transaction(Transaction)->
	case mnesia:transaction(Transaction) of
		{aborted,Reason} -> slogger:msg("run_transaction error ~p ~n",[Reason]),{failed,Reason};
		{atomic, []}	 -> {ok,[]};
		{atomic, Result}-> {ok,Result}
	end.

delete_rpc(Table,Key)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> case rpc:call(DbNode, ?MODULE, delete, [Table,Key]) of
					 {badrpc,Reason}-> slogger:msg("delete_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("delete_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
					 {ok}-> {ok};
					 _Any-> {failed,"delete_rpc Unknown error"}
				 end
	end.

delete(Table,Key)->
	case catch mnesia:dirty_delete({Table,Key}) of
		{'EXIT',Reason} -> {failed,Reason};
		ok	 -> {ok}
	end.

delete_rpc(Table,TableKey,FieldIndex,FieldKey)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> case rpc:call(DbNode, ?MODULE, delete, [Table,TableKey,FieldIndex,FieldKey]) of
					 {badrpc,Reason}-> slogger:msg("delete_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("delete_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
					 {ok}-> {ok};
					 _Any-> {failed,"delete_rpc Unknown error"}
				 end
	end.
	
delete(Table,TableKey,FieldIndex,FieldKey)->
	WriteFun = fun()->
					case mnesia:read(Table,TableKey) of
						[]-> failed;
						[Term]-> FieldValues = erlang:element(FieldIndex, Term),
								 case lists:keyfind(FieldKey, 1, FieldValues) of
									 false->
										 case lists:member(FieldKey, FieldValues) of
											 false-> ok;
											 _-> FieldValue = lists:delete(FieldKey, FieldValues),
												 Object = erlang:setelement(FieldIndex, Term, FieldValue),
												 mnesia:write(Object)
										 end;
									 _-> FieldValue = lists:keydelete(FieldKey, 1, FieldValues),
										 Object = erlang:setelement(FieldIndex, Term, FieldValue),
										 mnesia:write(Object)
								 end
					end
			   end,
	case mnesia:transaction(WriteFun) of
		{aborted,Reason} -> slogger:msg("delete_object error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
		{atomic, failed} -> slogger:msg("delete_object Table ~p ~n",[Table]),{failed,"read table failed when write"};
		{atomic, ok}	 -> {ok}
	end.

delete_object_rpc(Object)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> case rpc:call(DbNode, ?MODULE, delete_object, [Object]) of
					 {badrpc,Reason}-> slogger:msg("delete_object error ~p Object ~p ~n",[Reason,Object]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("delete_object error ~p Object ~p ~n",[Reason,Object]),{failed,Reason};
					 {ok}-> {ok};
					 _Any-> {failed,"delete_object_rpc Unknown error"}
				 end
	end.

delete_object(Object)->
	case catch mnesia:dirty_delete_object(Object) of
		{'EXIT',Reason} -> slogger:msg("delete_object error ~p Object ~p ~n",[Reason,Object]),{failed,Reason};
		ok	 -> {ok}
	end.

delete_index_rpc(Table,SecondaryKey,Pos)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> 
			case rpc:call(DbNode, ?MODULE, delete_index, [Table,SecondaryKey,Pos]) of
				 {badrpc,Reason}-> slogger:msg("delete_index_rpc error ~p~n",[Reason]),{failed,badrpc,Reason};
				 {failed,Reason}-> slogger:msg("delete_index_rpc error ~p~n",[Reason]),{failed,Reason};
				 {ok}-> {ok};
				 _Any-> {failed,"delete_index_rpc Unknown error"}
			end
	end.
 
delete_index(Table,SecondaryKey,Pos)->
	case read_index(Table,SecondaryKey,Pos) of
		{ok,Results}->
			lists:foreach(fun(Object)-> dal:delete_object(Object) end, Results),{ok};
		{failed,Result}->
			slogger:msg("delete_index read_index error ~p ~n",[Result]),
			{failed,Result}
	end.

write_rpc(Object)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> case rpc:call(DbNode, ?MODULE, write, [Object]) of
					 {badrpc,Reason}-> slogger:msg("write_rpc error ~p Object ~p ~n",[Reason,Object]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("write_rpc error ~p Object ~p ~n",[Reason,Object]),{failed,Reason};
					 {ok}-> {ok};
					 _Any-> slogger:msg("write_rpc exception Object ~p ~n",[Object]),{failed,"write_rpc Unknown error"}
				 end
	end.
	
write_rpc(Table,TableKey,FieldIndex,Value)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> case rpc:call(DbNode, ?MODULE, write, [Table,TableKey,FieldIndex,Value]) of
					 {badrpc,Reason}-> slogger:msg("write_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("write_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
					 {ok}-> {ok};
					 _Any-> {failed,"write_rpc Unknown error"}
				 end
	end.

write_rpc(Table,TableKey,FieldIndex,FieldKey,FieldTupleValue)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> case rpc:call(DbNode, ?MODULE, write, [Table,TableKey,FieldIndex,FieldKey,FieldTupleValue]) of
					 {badrpc,Reason}-> slogger:msg("write_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("write_rpc error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
					 {ok}-> {ok};
					 _Any-> {failed,"write_rpc Unknown error"}
				 end
	end.



write(Object)->
	case catch mnesia:dirty_write(Object) of
		{'EXIT',Reason} -> slogger:msg("write error ~p Object ~p ~n",[Reason,Object]),{failed,Reason};
		ok	 -> {ok}
	end.

write(Table,TableKey,FieldIndex,Value)->
	WriteFun = fun()->
					case mnesia:read(Table,TableKey) of
						[]-> error;
						[Term]-> Object = erlang:setelement(FieldIndex, Term, Value),
								 mnesia:write(Object)
					end
			   end ,
	case mnesia:transaction(WriteFun) of
		{aborted,Reason} -> slogger:msg("write error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
		{atomic, failed} -> slogger:msg("write error Table ~p ~n",[Table]),{failed,"read table failed when write"};
		{atomic, ok}	 -> {ok}
	end.

write(Table,TableKey,FieldIndex,FieldKey,FieldTupleValue)->
	WriteFun = fun()->
					case mnesia:read(Table,TableKey) of
						[]-> failed;
						[Term]-> FieldValues = erlang:element(FieldIndex, Term),
								 NewFieldValue = case is_tuple(FieldTupleValue) of
												  true->
													  if erlang:element(1, FieldTupleValue) == FieldKey->
															 case lists:keyfind(FieldKey, 1, FieldValues) of
																 false-> FieldValues ++ [FieldTupleValue];
																 _-> lists:keyreplace(FieldKey, 1, FieldValues, FieldTupleValue)
															 end;
														 true->
															 case lists:member(FieldTupleValue, FieldValues) of
																 false-> FieldValues ++ [FieldTupleValue];
																 _-> FieldValues
															 end
													  end;
												  false->
													  case lists:member(FieldTupleValue, FieldValues) of
														  false-> FieldValues ++ [FieldTupleValue];
														  _-> FieldValues
													  end
											  end,			 
								 Object = erlang:setelement(FieldIndex, Term, NewFieldValue),
								 mnesia:write(Object)
					end
			   end ,
	case mnesia:transaction(WriteFun) of
		{aborted,Reason} -> slogger:msg("write error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
		{atomic, failed} -> slogger:msg("write error Table ~p ~n",[Table]),{failed,"read table failed when write"};
		{atomic, ok}	 -> {ok}
	end.
	
async_write_rpc(Object)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> case rpc:call(DbNode, ?MODULE, async_write, [Object]) of
					 {badrpc,Reason}-> slogger:msg("async_write_rpc error ~p Object ~p ~n",[Reason,Object]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("async_write_rpc error ~p Object ~p ~n",[Reason,Object]),{failed,Reason};
					 {ok}-> {ok};
					 _Any-> {failed,"write_rpc Unknown error"}
				 end
	end.

async_write(Object)->
	try
		WriteFun = fun()->mnesia:write(Object)end,
		mnesia:activity(async_dirty,WriteFun),
		{ok}
	catch
		_E:Reason-> slogger:msg("async_write error ~p Object ~p ~n",[Reason,Object]),{failed,Reason}
	end.

clear_table_rpc(Object)->
	case node_util:get_dbnode() of
		undefined-> {nonode};
		DbNode-> case rpc:call(DbNode, ?MODULE, clear_table, [Object]) of
					 {badrpc,Reason}-> slogger:msg("clear_table_rpc error ~p Object ~p ~n",[Reason,Object]),{failed,badrpc,Reason};
					 {failed,Reason}-> slogger:msg("clear_table_rpc error ~p Object ~p ~n",[Reason,Object]),{failed,Reason};
					 {ok}-> {ok};
					 _Any-> {failed,"write_rpc Unknown error"}
				 end
	end.

clear_table(TableName)->
	case mnesia:clear_table(TableName) of
		{aborted,Reason} -> slogger:msg("clear_table error ~p TableName ~p ~n",[Reason,Reason]),{failed,Reason};
		{atomic, ok}	 -> {ok}
	end.

set_write_flag()->
	ets:insert(?DAL_WRITE_RECORD,{1,now()}).

get_write_flag()->
	case ets:lookup(?DAL_WRITE_RECORD, 1) of
		[]-> undefined;
		[{_,Time}]->Time
	end.

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
