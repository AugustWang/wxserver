%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-5-7
%% Description: TODO: Add description to mysqldb_read
-module(mysqldb_read).
-compile(export_all).
-define(DB, conn).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).

%%
%% API Functions
%%

-include("mnesia_table_def.hrl").

%%
%% Local Functions
%%

read_rpc(Table)->
	case node_util:get_dbnode() of
		undefined->{nonode};
		DbNode->
			case rpc:call(DbNode, ?MODULE, read, [Table]) of
				{badrpc,Reason}->slogger:msg("read_rpc error ~p  Table ~p~n",[Reason,Table]),{failed,badrpc,Reason};
				{failed,Reason}->slogger:msg("read_rpc failed ~p   table ~p~n",[Reason,Table]),{failed,Reason};
				{ok,Result}->{ok,Result};
				_Any->{failed,"read_rpc Unknown error"}
			end
	end.


read_rpc(Table,Key)->
		case node_util:get_dbnode() of
		undefined->{nonode};
		DbNode->
			case rpc:call(DbNode, ?MODULE, read, [Table,Key]) of
				{badrpc,Reason}->slogger:msg("read_rpc error ~p  Table ~p~n",[Reason,Table]),{failed,badrpc,Reason};
				{failed,Reason}->slogger:msg("read_rpc failed ~p   table ~p~n",[Reason,Table]),{failed,Reason};
				{ok,Result}->{ok,Result};
				_Any->{failed,"read_rpc Unknown error"}
			end
		end.

read_index_rpc(Table,Key,Pos)->
	case node_util:get_dbnode()of
		undefined->{nonode};
		DbNode->
			case rpc:call(DbNode,?MODULE,read_index,[Table,Key,Pos])of
				{badrpc,Reason}->slogger:msg("read_index_rpc  error   ~p    Table ~p~n",[Reason,Table]),{failed,badrpc,Reason};
				{failed,Reason}->slogger:msg("read_index_rpc failed ~p   table ~p~n",[Reason,Table]),{failed,Reason};
				{ok,Result}->{ok,Result};
				_Any->{failed,"read_index_rpc Unknown error "}
			end
	end.

read(Table)->
	Sql="select * from  "++lists:flatten(io_lib:write(Table)),
	case mysql:fetch(?DB,Sql) of
		 {data, {_, _, R, _, _}} -> 
			 Values=lists:foldl(fun(Info,Acc)->
								 ListInfo= lists:map(fun(Value)->
										 ListValue=mysql_db_tool:check_value(Value) end, Info),
										 TupleInfo=erlang:list_to_tuple([Table|ListInfo]),
								[TupleInfo]++Acc end,[], R),
			 				{ok,Values};
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.
read(Table,Key)->
%% 	Sql="select * from  "++lists:flatten(io_lib:write(Table)),
%% 	case mysql:fetch(?DB,Sql) of
%% 		 {data, {_, _, R, _, _}} -> 
%% 			 Values=lists:foldl(fun(Info,Acc)->
%% 								 ListInfo= lists:map(fun(Value)->
%% 													ListValue=mysql_db_tool:check_value(Value) end, Info),
%% 								TupleInfo=erlang:list_to_tuple([Table|ListInfo]),
%% 								[TupleInfo]++Acc end,[],  R),
%% 			 Result=get_keyvalue_from_listinfo(Values,Key),
%% 			 {ok,Result};
%%         {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
%%     end.
	mysqldb_read_data:read_data_from_table(Table,Key,1).

read_index(Table,Key,Pos)->
%% 	Sql="select * from  "++lists:flatten(io_lib:write(Table)),
%% 		case mysql:fetch(?DB,Sql) of
%% 		 {data, {_, _, R, _, _}} -> 
%% 			 Values=lists:foldl(fun(Info,Acc)->
%% 								 ListInfo= lists:map(fun(Value)->
%% 													ListValue=mysql_db_tool:check_value(Value) end, Info),
%% 								TupleInfo=erlang:list_to_tuple([Table|ListInfo]),
%% 								[TupleInfo]++Acc end,[],  R),
%% 			 Result=get_keyvalue_from_listinfo(Values,Key,Pos),
%% 			 {ok,Result};
%%         {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
%%     end.
		mysqldb_read_data:read_data_from_table(Table,Key,Pos-1).

index_match_object(Pattern,Pos)-> 
	Table=erlang:element(1, Pattern),
	Key=erlang:element(Pos, Pattern),
	read_index(Table,Key,Pos).

get_keyvalue_from_listinfo(ListInfo,Key)->
	case lists:keyfind(Key, 2, ListInfo) of
		false->
			case lists:keyfind([Key], 2, ListInfo) of
				false->[];
				NewInfo->
					[NewInfo]
			end;
		Info->
			[Info]
	end.

get_keyvalue_from_listinfo(Values,Key,Pos)->
	lists:foldl(fun(Info,Acc)->
						Value=erlang:element(Pos,Info),
						if Value=:=Key ->
							   [Info]++Acc;
						   true->
							   Acc
						end end , [],Values).

%% @doc æ˜¾ç¤ºäººå¯ä»¥çœ‹å¾—æ‡‚çš„é”™è¯¯ä¿¡æ¯
mysql_halt([Sql, Reason]) ->
    catch erlang:error({db_error, [Sql, Reason]}).

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

write(Object)->
		 TableName=erlang:element(1, Object),
		 Key=erlang:element(2, Object),
		 case read(TableName,Key) of
			 {ok,[]}->
					update_mysqldb:replace_data(TableName,Object);
			 {ok,[Info]}->
					mysqldb_updata:update_data(TableName,Object);
			 _->
				io:format("@@@@@@@@@@@@@@@@@@@@@@@     write error   Object  ~p ~n!",[Object]), {ok}
		 end.

write(Table,TableKey,FieldIndex,Value)->
%% 	WriteFun = fun()->
					case read(Table,TableKey) of
						{ok,[]}-> error;
						{ok,[Term]}->Object = erlang:setelement(FieldIndex, Term, Value),
								 write(Object)
					end.
%% 			   end .

write(Table,TableKey,FieldIndex,FieldKey,FieldTupleValue)->
%% 	WriteFun = fun()->
					case read(Table,TableKey) of
						{ok,[]}-> failed;
						{ok,[Term]}-> FieldValues = erlang:element(FieldIndex, Term),
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
								 write(Object)
					end.
%% 			   end.
	
delete(Table,Key)->
	case read(Table,Key) of
		{ok,[]}->
			nohting;
		{ok,[Object]}->
			mysql_data_update_delete:delete_data(Table,Object);
		_->
			nothing
	end.

delete(Table,TableKey,FieldIndex,FieldKey)->
		WriteFun = fun()->
					case read(Table,TableKey) of
						{ok,[]}-> failed;
						{ok,[Term]}-> FieldValues = erlang:element(FieldIndex, Term),
								 case lists:keyfind(FieldKey, 1, FieldValues) of
									 false->
										 case lists:member(FieldKey, FieldValues) of
											 false-> ok;
											 _-> FieldValue = lists:delete(FieldKey, FieldValues),
												 Object = erlang:setelement(FieldIndex, Term, FieldValue),
%% 												 mysql_data_update_delete:delete_data(Table,Object),
%% 												 write(Object)
												mysqldb_updata:update_data(Table,Object)
										 end;
									 _-> FieldValue = lists:keydelete(FieldKey, 1, FieldValues),
										 Object = erlang:setelement(FieldIndex, Term, FieldValue),
%% 										 mysql_data_update_delete:delete_data(Table,Object),
%% 										 write(Object)
										 mysqldb_updata:update_data(Table,Object)
								 end
						end
			   end.

delete_object(Object)->
	Table=erlang:element(1, Object),
	mysql_data_update_delete:delete(Table,Object).


clear_table(TableName)->
	msql_data_delete:delete(TableName).

get_mallinfo_by_type(NType)->
		try
%% 		S = fun()->
			case NType of
				0 ->
					Sql="select id,ishot,sort,price,discount from mall_item_info where ishot=1",
						case mysql:fetch(?DB,Sql) of
							 {data, {_, _, R, _, _}} -> 
								 				 Values=lists:foldl(fun(Info,Acc)->
													{Value1,Value2,Value3,Value4,Value5}=erlang:list_to_tuple(Info),
													NewValue1=mysql_db_tool:check_value(Value1),
													NewValue2=mysql_db_tool:check_value(Value2),
													NewValue3=mysql_db_tool:check_value(Value3),
													NewValue4=util:term_to_record_for_list(mysql_db_tool:check_value(Value4),ip),
													NewValue5=util:term_to_record_for_list(mysql_db_tool:check_value(Value5),di),
													ListInfo=[NewValue1,0,NewValue2,NewValue3,NewValue4,NewValue5],
													TupleInfo=erlang:list_to_tuple(ListInfo),
													[TupleInfo]++Acc end,[],  R),
								 util:term_to_record_for_list(Values,mi);		
					        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
   						 end;
				101 ->
					Sql="select id,ishot,sort,price,discount from mall_item_info",
						case mysql:fetch(?DB,Sql) of
							 {data, {_, _, R, _, _}} -> 
								 Values=lists:foldl(fun(Info,Acc)->
													{Value1,Value2,Value3,Value4,Value5}=erlang:list_to_tuple(Info),
													NewValue1=mysql_db_tool:check_value(Value1),
													NewValue2=mysql_db_tool:check_value(Value2),
													NewValue3=mysql_db_tool:check_value(Value3),
													NewValue4=util:term_to_record_for_list(mysql_db_tool:check_value(Value4),ip),
													NewValue5=util:term_to_record_for_list(mysql_db_tool:check_value(Value5),di),
													ListInfo=[NewValue1,101,NewValue2,NewValue3,NewValue4,NewValue5],
													TupleInfo=erlang:list_to_tuple(ListInfo),
													[TupleInfo]++Acc end,[],  R),
								 util:term_to_record_for_list(Values,mi);		
					        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
   						 end;
				_ ->
						Sql1="select id,ntype,ishot,sort,price,discount from mall_item_info where ntype= ",
						Sql=string:concat(Sql1,lists:flatten(io_lib:write(NType))),
						case mysql:fetch(?DB,Sql) of
							 {data, {_, _, R, _, _}} -> 
								 Values=lists:foldl(fun(Info,Acc)->
													{Value1,Value2,Value3,Value4,Value5,Value6}=erlang:list_to_tuple(Info),
													NewValue1=mysql_db_tool:check_value(Value1),
													NewValue2=mysql_db_tool:check_value(Value2),
													NewValue3=mysql_db_tool:check_value(Value3),
													NewValue4=mysql_db_tool:check_value(Value3),
													NewValue5=util:term_to_record_for_list(mysql_db_tool:check_value(Value5),ip),
													NewValue6=util:term_to_record_for_list(mysql_db_tool:check_value(Value6),di),
													ListInfo=[NewValue1,NewValue2,NewValue3,NewValue4,NewValue5,NewValue6],
													TupleInfo=erlang:list_to_tuple(ListInfo),
													[TupleInfo]++Acc end,[],  R),
								 util:term_to_record_for_list(Values,mi);		
					        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
 						end
			end
%% 		end,						
%% 		case mnesia:transaction(S) of
%% 			{aborted, _Reason} -> [];
%% 			{atomic, []}	-> [];
%% 			{atomic, MallItemList} -> 
%% 	\			util:term_to_record_for_list(MallItemList,mi)		
%% 		end
	catch
		E:R1-> slogger:msg("get_mallinfo_by_type/1 ~pR~p~n",[E,R1])
	end.
get_mallinfo_by_special_type(Ntype)->
	try
		Sql1="select id,special_type,ishot,sort,price,discount from mall_item_info where special_type=",
		Sql=string:concat(Sql1,lists:flatten(io_lib:write(Ntype))),
		case mysql:fetch(?DB,Sql) of
			{data, {_, _, R, _, _}} -> 
				Values=lists:foldl(fun(Info,Acc)->
					   {Value1,Value2,Value3,Value4,Value5,Value6}=erlang:list_to_tuple(Info),
					   NewValue1=mysql_db_tool:check_value(Value1),
					   NewValue2=mysql_db_tool:check_value(Value2),
					   NewValue3=mysql_db_tool:check_value(Value3),
					   NewValue4=mysql_db_tool:check_value(Value3),
					   NewValue5=util:term_to_record_for_list(mysql_db_tool:check_value(Value5),ip),
					   NewValue6=util:term_to_record_for_list(mysql_db_tool:check_value(Value6),di),
					   ListInfo=[NewValue1,NewValue2,NewValue3,NewValue4,NewValue5,NewValue6],
					   TupleInfo=erlang:list_to_tuple(ListInfo),
			                      [TupleInfo]++Acc end,[],  R),
					   util:term_to_record_for_list(Values,mi);		
			 {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
 		end
	catch
		E:R1-> slogger:msg("get_mallinfo_by_special_type/1 ~pR~p~n",[E,R1])
	end.

get_sales_item_by_type(Ntype)->
	try
		case read_index(mall_sales_item_info,Ntype,#mall_item_info.ntype) of
			{ok,[Values]}->
				Values;
			_->
				[]
		end
	catch
		E:R-> slogger:msg("get_sales_item_by_type/1 ~pR~p~n",[E,R])
	end.

update_mall_item(ItemId,ItemCount)->
		try
			case read_index(mall_item_info,ItemId,#mall_item_info.id) of
				{ok,[OldItem]}->
					Discount = OldItem#mall_item_info.discount,
					{2,LimitCount} = lists:keyfind(2, 1, Discount),
					NewDiscount = lists:keyreplace(2, 1, Discount, {2,LimitCount-ItemCount}),
					New = OldItem#mall_item_info{discount=NewDiscount}, 
					dal:write(New);
				_->
					nothing
			end
	catch
		E:R-> slogger:msg("get_sales_item_by_type/1 ~pR~p~n",[E,R])
	end.
update_sales_item(ItemId,ItemCount)->
	io:format("@@@@@@@@@@@@@@@@@@@@@@  sdfsdfsdf 1~n",[]),
			try
			case read_index(mall_up_sales_table,ItemId,#mall_up_sales_table.id) of
				{ok,[OldItem]}->
					Discount = OldItem#mall_up_sales_table.discount,
					{2,LimitCount} = lists:keyfind(2, 1, Discount),
					NewDiscount = lists:keyreplace(2, 1, Discount, {2,LimitCount-ItemCount}),
					New = OldItem#mall_up_sales_table{discount=NewDiscount}, 
					case dal:write(New) of
						{ok}->
							io:format("@@@@@@@@@@@@@@@@@@@@@@  sdfsdfsdf2 ~n",[]),
							{ok,ItemId};
						Reason->
							io:format("@@@@@@@@@@@@@@@@@@@@@@  sdfsdfsdf3 ~n",[]),
							{failed,Reason}
					end;
				_->
					io:format("@@@@@@@@@@@@@@@@@@@@@@  sdfsdfsdf4 ~n",[]),
					nothing
			end
	catch
		E:R-> slogger:msg("get_sales_item_by_type/1 ~pR~p~n",[E,R])
	end.

update_by_gm(ItemId,Ntype,SpecialType,Ishot,Sort,Price,Discount)->
	try
		case read_index(mall_up_sales_table,ItemId,#mall_up_sales_table.id) of
			{ok,[OldItem]}->
				New = OldItem#mall_item_info{ntype=Ntype,special_type=SpecialType,ishot=Ishot,sort=Sort,price=Price,discount=Discount}, 
				mnesia:write(New);
			_->
				nothing
		end
	catch
		E:R-> slogger:msg("get_sales_item_by_type/1 ~pR~p~n",[E,R])
	end.

import_mall_item_info(File)->
	clear_table(mall_item_info),
	case file:consult(File) of
			{ok,[Terms]}->
				lists:foreach(fun(Term)-> add_mall_item_info_to_db(Term) end,Terms);
			{error,Reason} ->
				slogger:msg("import_mall_item_info error:~p~n",[Reason])
	end.
add_mall_item_info_to_db(Term)->
	try
		Object = util:term_to_record(Term,mall_item_info),
		dal:write(Object)
	catch
		_:_-> error
	end.