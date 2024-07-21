%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaodya
%% Created: 2010-11-3
%% Description: TODO: Add description to mall_op
-module(mall_op).

%%
%% Include files
%%
-define(BUY_MALL_ITEM,1).
-define(BUY_SALES_ITEM,2).
-define(ONE_MINUTE_SECOND,60).
-define(MINITE,60).
-define(ONE_HOUR_MINUTE,60).
-define(ONE_DAY_HOURS,24).
-define(BUFFERHOUR,2).

%%
%% Exported Functions
%%
-export([init_mall_item_list/1,get_mall_item_list/1,get_mall_item_list_special/1,get_mall_item_list_sales/1,
		 load_role_latest_from_db/1,load_role_buy_item_log_from_db/1,
		 init_role_latest_buy/0,init_hot_item/0,init_role_mall_integral/1,
		 flush_latest/3,save_to_db/0,export_for_copy/0,load_by_copy/1,
		 mall_buy_action/5,
		 flush_sales_item/0,
		 system_bodcast_flush_sales/4,
		 flush_sales_item_test/1,
		 change_role_integral/2,
		 add_role_charge_integral_by_value/1,
		 proc_msg/1]).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("mnesia_table_def.hrl").
-include("error_msg.hrl").
-include("common_define.hrl").
-include("system_chat_define.hrl").
-include("item_struct.hrl").
-include("login_pb.hrl").
%%
%% API Functions
%%
init()->
	put(role_latest_buy,[]).

init_role_buy_log()->
	put(flush_buylog,[]).

%%role_mall_integral:{Charge_integral,Consume_integral}
%%Charge_integral : role charge integral
%%Consume_integral : role buy item integral
init_role_mall_integral(RoleId)->
	case mall_integral_db:get_tole_mall_integral(RoleId) of
		[]->
			Charge_integral = 0,
			Consume_integral = 0,
			put(role_mall_integral,{0,0});
		{_,_,Charge_integral,Consume_integral} ->
			put(role_mall_integral,{Charge_integral,Consume_integral})
	end,
	Message = login_pb:encode_change_role_mall_integral_s2c(#change_role_mall_integral_s2c{charge_integral=Charge_integral,by_item_integral=Consume_integral}),
	role_op:send_data_to_gate(Message).

load_role_latest_from_db(RoleId)->
	case mall_item_db:get_role_buy_log(RoleId) of
		[]->
			init();
		{role_buy_log,_RId,LogList}->
			case lists:keyfind(latest, 1, LogList) of
				false->
					init();
				{latest,LatestList}->
					case LatestList of
						[]->
							put(role_latest_buy,LatestList);
						_->
							L = lists:foldl(fun(Term,Acc)->
											  case Term of
												  {_,MitemId,Discount}->
													  case mall_item_db:get_item_info(MitemId) of
														  {ok,[]} -> 
															  Acc;
														  {ok,MitemInfo} ->
															  #mall_item_info{price=ServerPrice} = MitemInfo,
															  Acc ++ [{imi,MitemId,util:term_to_record_for_list(ServerPrice, ip),Discount}]
													  end;
												  _->
													  Acc ++ [Term]
											  end
									  end, [], LatestList),
							put(role_latest_buy,L)
					end
			end;
		_->
			init()
	end.

load_role_buy_item_log_from_db(RoleId)->
	case mall_item_db:get_role_buy_mall_item(RoleId) of
		[]->
			init_role_buy_log();
		#role_buy_mall_item{buylog=BuyLog}->
			put(flush_buylog,BuyLog)
	end.

export_for_copy()->
	{get(role_latest_buy),get(flush_buylog),get(role_mall_integral)}.

load_by_copy({LatestList,BuyList,RoleIntegral})->
	put(role_latest_buy,LatestList),
	put(flush_buylog,BuyList),
	put(role_mall_integral,RoleIntegral).

save_to_db()->
	RoleId = get(roleid),
	case mall_item_db:get_role_buy_log(RoleId) of
		[]->
			mall_item_db:sync_update_role_buy_log_to_mnesia(RoleId, {RoleId,[{latest,get(role_latest_buy)}]});
		{role_buy_log,_RId,LogList}->
			case lists:keymember(latest, 1, LogList) of
				false->
					mall_item_db:sync_update_role_buy_log_to_mnesia(RoleId, {RoleId,LogList++{latest,get(role_latest_buy)}});
				true->
					mall_item_db:sync_update_role_buy_log_to_mnesia(RoleId, {RoleId,lists:keyreplace(latest, 1, LogList, {latest,get(role_latest_buy)})})
			end
	end,
	case get(flush_buylog) of
		[]->
			nothing;
		BuyLog->
			mall_item_db:sync_update_role_buy_mall_item_to_mnesia(RoleId, {RoleId,BuyLog})
	end.

init_role_latest_buy()->
	Message = mall_packet:encode_init_latest_item_s2c(get(role_latest_buy)),
	role_op:send_data_to_gate(Message).

init_hot_item()->
	case mall_item_db:get_hot_item() of
		[]->
			HotItems = [];
		Items->
			SortItems = lists:foldl(fun(ItemId,Acc)-> 
							  case lists:keyfind(ItemId, 1, Items) of
								  false->
									  Acc;
								  Item->
									  Acc++[Item]
							  end
							  end , [], env:get(hot_item, [])),
			HotItems = util:term_to_record_for_list(SortItems, imi)
	end,
	Message = mall_packet:encode_init_hot_item_s2c(HotItems),
	role_op:send_data_to_gate(Message).

init_mall_item_list(Ntype) ->
	BackList = case mall_item_db:get_mallinfo_by_type_rpc_call(Ntype) of
				   []->
					   [];
				   MallItemList->
					   MallItemList
			   end,
	Message = mall_packet:encode_init_mall_item_list_s2c(BackList),
	role_op:send_data_to_gate(Message).

get_mall_item_list(Ntype) ->
	BackList = case mall_item_db:get_mallinfo_by_type_rpc_call(Ntype) of
				   []->
					   [];
				   MallItemList->
					   MallItemList
			   end,
	Message = mall_packet:encode_mall_item_list_s2c(BackList),
	role_op:send_data_to_gate(Message).
	
get_mall_item_list_special(Ntype2)->
	BackList = case mall_item_db:get_mallinfo_by_special_type_rpc_call(Ntype2) of
				   []->
					   [];
				   MallItemList->
					   MallItemList
			   end,
	Message = mall_packet:encode_mall_item_list_special_s2c(BackList),
	role_op:send_data_to_gate(Message).

get_mall_item_list_sales(Ntype)->
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	CurSec = MegaSec*1000000 + Sec,
	BuildFun = fun(Info)->
					   Id = mall_item_db:get_id_from_iteminfo(Info),
					   Sort = mall_item_db:get_sort_from_iteminfo(Info),
					   Price = util:term_to_record_for_list(mall_item_db:get_price_from_iteminfo(Info), ip),
					   Discount = util:term_to_record_for_list(mall_item_db:get_discount_from_iteminfo(Info), di),
					   Duration = mall_item_db:get_duration_from_iteminfo(Info),
					   Uptime = mall_item_db:get_uptime_from_iteminfo(Info),
					   Time = (Uptime+Duration*?MINITE)-CurSec,
					   MyCur = case get(flush_buylog) of
								   undefined->
									   0;
								   []->
									   0;
								   BuyLog->
									   case lists:keyfind(Id, 1, BuyLog) of
										   false->
											   0;
										   {_,_,BuyCount}->
											   BuyCount
									   end
							   end,
					   {smi,Id,Sort,Time,MyCur,Price,Discount}
			   end,
	BackList = case mall_item_db:get_mallinfo_by_sales_type_rpc_call(Ntype) of
				   []->
					   [];
				   MallItemList->
					   lists:map(BuildFun, MallItemList)
			   end,
	Message = mall_packet:encode_mall_item_list_sales_s2c(BackList),
	role_op:send_data_to_gate(Message).

check_expired_sales_item(OldSalesItems)->
	CheckExpiredFun = fun(Info)->
							  Id = mall_item_db:get_id_from_iteminfo(Info),
							  Uptime = mall_item_db:get_uptime_from_iteminfo(Info),
							  Duration = mall_item_db:get_duration_from_iteminfo(Info),
							  {MegaSec,Sec,_} = timer_center:get_correct_now(),
							  CurSec = MegaSec*1000000 + Sec,
							  if
								  CurSec>=(Uptime+Duration*?MINITE)->
									  mall_item_db:delete_up_sales_item(Id),
									  true;
								  true->
									  false
							  end
					  end,
	lists:filter(CheckExpiredFun, OldSalesItems).


flush_sales_item_test(ItemList)->
	dal:clear_table_rpc(mall_up_sales_table),
	flushfun(ItemList).

flush_sales_item()->
	FlushList = case mall_item_db:get_mallinfo_by_sales_type(0) of
		[]->
			random_sales_item([],[]);
		OldSalesItems->
			ExpiredItem = check_expired_sales_item(OldSalesItems),
			random_sales_item(OldSalesItems,ExpiredItem)
	end,
	flushfun(FlushList).
					   
flushfun(FlushList)->
	FlushFun = fun(Info)->					 
					   {MegaSec,Sec,_} = timer_center:get_correct_now(),
					   CurSec = MegaSec*1000000 + Sec,
					   Object = #mall_up_sales_table{id = mall_item_db:get_id_from_iteminfo(Info),
											ntype = mall_item_db:get_ntype_from_iteminfo(Info),
											name = mall_item_db:get_name_from_iteminfo(Info),
											sort = mall_item_db:get_sort_from_iteminfo(Info),
											price = mall_item_db:get_price_from_iteminfo(Info),
											discount = mall_item_db:get_discount_from_iteminfo(Info),
											duration = mall_item_db:get_duration_from_iteminfo(Info),
											uptime = CurSec,
											restrict = mall_item_db:get_restrict_from_iteminfo(Info),
											bodcast = mall_item_db:get_bodcast_from_iteminfo(Info)
										   },
					   dal:write_rpc(Object),
					   case mall_item_db:get_bodcast_from_iteminfo(Info) of
						   0->
							   nothing;
						   ?SYSTEM_CHAT_FLUSH_SALES_ITEM->
							   case server_travels_util:is_share_server() of
								   false->
									   Id = mall_item_db:get_id_from_iteminfo(Info),
									   Discount = mall_item_db:get_discount_from_iteminfo(Info),
									   LimitCount = get_intvalue_by_key(2,1,Discount,-1),
									   Gold = get_intvalue_by_key(1,1,Discount,-1),
									   if
										   Gold=:=-1;LimitCount=:=-1->
											   nothing;
										   true->
											   system_bodcast_flush_sales_rpc_call(?SYSTEM_CHAT_FLUSH_SALES_ITEM,Id,Gold,LimitCount)
									   end;
								   true->
									   nothing
							   end;
						   _->
							   nothing
					   end
			   end,
	case FlushList of
		[]->
			nothing;
		_->
			lists:foreach(FlushFun, FlushList)
	end.

random_sales_item(OldSalesItems,ExpiredItems)->
	NeedFlushCount = case OldSalesItems of
						 []->
							 3;
						 _->
							 OldLen = erlang:length(OldSalesItems),
							 if
								 OldLen>3->
									 erlang:length(ExpiredItems)-(OldLen-3);
								 OldLen=:=3->
									 erlang:length(ExpiredItems);
								 true->
									 (3-OldLen)+erlang:length(ExpiredItems)
							 end
					 end,
	if
		NeedFlushCount>0->
			InTimeList = get_intime_list(OldSalesItems,NeedFlushCount),
			InTimeLen = erlang:length(InTimeList),
			if
				InTimeLen >= NeedFlushCount->
					InTimeList;
				true->
					NoTimeList = get_random_notime_list(OldSalesItems,NeedFlushCount-InTimeLen),
					InTimeList ++ NoTimeList
			end;
		true->
			[]
	end.

get_random_notime_list(OldSalesItems,Count)->
	CheckFun = fun(Info)->
						Id = mall_item_db:get_id_from_iteminfo(Info),
						IsInOldList = lists:keymember(Id, 2, OldSalesItems),
						if
							IsInOldList->
								false;
							true->
								true
						end
				  end,
	case mall_item_db:get_sales_item_by_type_rpc_call(3) of
		[]->
			[];
		NoTimeList->
			NoTimeListLen = length(NoTimeList),
			if NoTimeListLen =< Count ->
				  NoTimeList;
			   true ->
				   util:get_random_list_from_list(lists:filter(CheckFun, NoTimeList), Count)
			end			
		end.

make_checktime_list(TmpSalesTime)->
	case lists:keyfind(1, 1, TmpSalesTime) of 
		false->
			DynamicTime = [];
		{_,DynamicTime}->
			DynamicTime			
	end,
	case lists:keyfind(2, 1, TmpSalesTime) of
		false->
			FixTime = [];
		{_,{StartTime,EndTime}}->
			case util:get_server_start_time() of
				[]->
					{Date,_} = calendar:local_time(),
					SaleStartTime = {Date,{0,0,0}},
%% 					io:format("SaleStartTime:~p~n",[SaleStartTime]),
					TmpSaleEndTime = calendar:datetime_to_gregorian_seconds(SaleStartTime)+?ONE_DAY_HOURS*?ONE_HOUR_MINUTE*?ONE_MINUTE_SECOND,
					SaleEndTime = calendar:gregorian_seconds_to_datetime(TmpSaleEndTime),
					slogger:msg("not find server start time ~n"),
					FixTime = [{SaleStartTime,SaleEndTime}];
				ServerStartTime->
					BufferTime = ?BUFFERHOUR*?ONE_HOUR_MINUTE*?ONE_MINUTE_SECOND, 
					TmpServerStartTime = calendar:datetime_to_gregorian_seconds(ServerStartTime)-BufferTime,
					TmpSaleStartTime = TmpServerStartTime+StartTime*?ONE_MINUTE_SECOND,
					TmpSaleEndTime = TmpServerStartTime+EndTime*?ONE_MINUTE_SECOND,
					SaleStartTime = calendar:gregorian_seconds_to_datetime(TmpSaleStartTime),
					SaleEndTime = calendar:gregorian_seconds_to_datetime(TmpSaleEndTime),		
					FixTime = [{SaleStartTime,SaleEndTime}]
			end
	end,
%% 	io:format("TimeList:~p~n",[DynamicTime++FixTime]),
	DynamicTime++FixTime.

					

get_intime_list(OldSalesItems,Count)->
	IsInTimeFun = fun(Info)-> 
						TmpSalesTime = mall_item_db:get_sales_time_from_iteminfo(Info),
						Id = mall_item_db:get_id_from_iteminfo(Info),
						case TmpSalesTime of
							[]->
								false;
							_->
								SalesTime = make_checktime_list(TmpSalesTime),
%% 								io:format("SalesTime:~p~n",[SalesTime]),
								IsInTime = timer_util:check_dateline_by_range(SalesTime),
								if
									IsInTime->
										IsInOldList = lists:keymember(Id, 2, OldSalesItems),
										if
											IsInOldList->
												false;
											true->
												true
										end;
									true->
										false
								end
						end
				  end,
	L1List = case mall_item_db:get_sales_item_by_type_rpc_call(1) of
		[]->
			[];		
		L1->
			
			lists:filter(IsInTimeFun, L1)		
	end,
	L2List = case mall_item_db:get_sales_item_by_type_rpc_call(2) of
		[]->
			[];
		L2->
			lists:filter(IsInTimeFun, L2)
	end,
	L1Len = erlang:length(L1List),
	L2Len = erlang:length(L2List),
	if
		L1Len >= Count->
			lists:nthtail(L1Len-Count, L1List);
		true->
			if
				L2Len =< (Count-L1Len)->
					L1List++L2List;
				true->
					L1List ++ lists:nthtail(L2Len-(Count-L1Len), L2List)
			end
	end.

get_intvalue_by_key(Key,N,TupleList,Default)->
	case lists:keyfind(Key,N,TupleList) of
		{Key,Value} ->
			Value;
		false -> Default
	end.

mall_buy_action(RoleInfo,MitemId,Count,Price,BuyType) ->
	if
		Count>=0-> 
			case BuyType of
				?BUY_MALL_ITEM->
					case buy_mall_item(RoleInfo,MitemId,Count,Price,BuyType) of
						{ok}-> 
							Ret = [];
						{error,Code}->
							Ret = Code
					end;
				?BUY_SALES_ITEM->
					case buy_sales_item(RoleInfo,MitemId,Count,Price,BuyType) of
						{ok}-> 
							Ret = [];
						{error,Code}->
							Ret = Code
					end;
				_->
					Ret = noitem
			end,
			case Ret of
				[]->
					Errno = [];
				package-> 
					Errno = ?ERROR_PACKEGE_FULL;
				count-> 
					Errno = ?ERROR_LIMIT_COUNT;
				time-> 
					Errno = ?ERROR_LIMIT_TIME;
				gold->
					Errno = ?ERROR_LESS_GOLD;
				ticket->
					Errno = ?ERROR_LESS_TICKET;
				integral->
					Errno = ?ERROR_LESS_INTEGRAL;
				prepair->
					Errno = ?ERROR_PRICE_PREPAIR;
				restrict->
					Errno = ?ERROR_MALL_ITEM_RESTRICT;
				shelves->
					Errno = ?ERROR_SALES_ITEM_SHELVES;
				noitem->
					Errno = ?ERRNO_NPC_EXCEPTION,
					slogger:msg("mall_buy_action buy  error ,no item! maybe hack! Roleid: ~p ~n ",[get_id_from_roleinfo(RoleInfo)])
			end;
		true->
			Errno = ?ERRNO_NPC_EXCEPTION,
			slogger:msg("mall_buy_action hack error Count!!!! Count ~p ~n",[Count])
	end,
	if 
		Errno =/= []->
			Message_failed = mall_packet:encode_buy_item_fail_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.	

is_packege_full(MItemId,Count)->
	case package_op:can_added_to_package(MItemId,Count) of
		0 -> %% full bag
			full;
		_OK ->
			ok
	end.

buy_mall_item_impl(MItemId,LimitCount,Count,BuyType,Reason)->
	case role_op:auto_create_and_put(MItemId, Count, Reason) of
		full->
			full;
		{ok,_}->
			if 
				LimitCount >= Count->
					case BuyType of 
						?BUY_MALL_ITEM->
							case mall_item_db:update_mall_item_rpc_call(MItemId,Count) of
								{failed,Reason}->
									slogger:msg("mall_buy_action update limitCount error,Reason: ~p ~n ",[Reason]);
								{ok,_ItemId}->
									ok
							end;
						?BUY_SALES_ITEM->
							case mall_item_db:update_sales_item_rpc_call(MItemId,Count) of
								{failed,Reason}->
									slogger:msg("mall_buy_action update limitCount error,Reason: ~p ~n ",[Reason]);
								{ok,_ItemId}->
									ok
							end
					end;
				true->
					ok
			end
	end.

flush_latest(ItemId,Price,Discount)->
	case get(role_latest_buy) of
		LatestList->
			case lists:keymember(ItemId, 2, LatestList) of
				true->
					nothing;
				false->
					if 
						erlang:length(LatestList) < 2->
							UpdateLatestList = LatestList ++ [{imi,ItemId,util:term_to_record_for_list(Price, ip),util:term_to_record_for_list(Discount,di)}],
							put(role_latest_buy,UpdateLatestList);
						true->
							UpdateLatestList = lists:nthtail(1, LatestList) ++ [{imi,ItemId,util:term_to_record_for_list(Price, ip),util:term_to_record_for_list(Discount,di)}],
							put(role_latest_buy,UpdateLatestList)
					end,
					init_role_latest_buy()
			end
	end.

check_count_by_sales(Restrict,MitemId,BuyCount,Uptime)->
	case Restrict of
		[]->
			true;
		{Type,Overdue,Count}->
			if BuyCount=<Count->
				NowTime = timer_center:get_correct_now(),
				case get(flush_buylog) of
					[]->
						put(flush_buylog,[{MitemId,NowTime,BuyCount}]),
						true;
					BuyLog->
						case lists:keyfind(MitemId, 1, BuyLog) of
							false->
								put(flush_buylog,[{MitemId,NowTime,BuyCount}|BuyLog]),
								true;
							{_,Ftime,DCount}->
								{Fmsec,Fsec,_} = Ftime,
								FSec = Fmsec*1000000+Fsec,
								if
									FSec < Uptime->
										put(flush_buylog,[{MitemId,NowTime,BuyCount}]),
										true;
									true->
										if
											Type=:=1->
												{_YYMMDD,HHMMSS} = Overdue,
												case timer_util:check_is_overdue(Type,HHMMSS,Ftime) of
													true->
														put(flush_buylog,
															lists:keyreplace(MitemId, 1, BuyLog, 
																	 {MitemId,NowTime,BuyCount})),
														true;
													false->
														if
															DCount+BuyCount=<Count->
																put(flush_buylog,
																	lists:keyreplace(MitemId, 1, 
																			 BuyLog, 
																			 {MitemId,Ftime,DCount+BuyCount})),
																true;
															true->
																false
														end
												end;
											Type=:=0->
												if 
													DCount+BuyCount=<Count->
														put(flush_buylog,
															lists:keyreplace(MitemId, 1, BuyLog, 
																	 {MitemId,Ftime,DCount+BuyCount})),
														true;
													true->
														false
												end;
											true->
												false
										end
								end
						end
				end;
			   true->
				   false
			end
	end.

check_count(Restrict,MitemId,BuyCount)->
	case Restrict of
		[]->
			true;
		{Type,Overdue,Count}->
			if BuyCount=<Count->
				NowTime = timer_center:get_correct_now(),
				case get(flush_buylog) of
					[]->
						put(flush_buylog,[{MitemId,NowTime,BuyCount}]),
						true;
					BuyLog->
						case lists:keyfind(MitemId, 1, BuyLog) of
							false->
								put(flush_buylog,[{MitemId,NowTime,BuyCount}|BuyLog]),
								true;
							{_,Ftime,DCount}->
							if
								Type=:=1->
									{_YYMMDD,HHMMSS} = Overdue,
									case timer_util:check_is_overdue(Type,HHMMSS,Ftime) of
										true->
											put(flush_buylog,lists:keyreplace(MitemId, 1, BuyLog, {MitemId,NowTime,BuyCount})),
											true;
										false->
											if
												DCount+BuyCount=<Count->
													put(flush_buylog,lists:keyreplace(MitemId, 1, BuyLog, {MitemId,Ftime,DCount+BuyCount})),
													true;
												true->
													false
											end
									end;
								Type=:=0->
									if 
										DCount+BuyCount=<Count->
											put(flush_buylog,lists:keyreplace(MitemId, 1, BuyLog, {MitemId,Ftime,DCount+BuyCount})),
											true;
										true->
											false
									end;
								true->
									false
							end
					end
				end;
			   true->
				   false
			end
	end.

buy_mall_item(RoleInfo,MitemId,Count,Price,BuyType) ->
	case mall_item_db:get_item_info(MitemId) of
		{ok,[]} -> 
			{error,noitem};
		{ok,MitemInfo} ->
			#mall_item_info{price=ServerPrice,
							discount=ServerDiscount,
							restrict=Restrict,
							bodcast=Bodcast} = MitemInfo,
			LimitPrice = get_intvalue_by_key(1,1,ServerDiscount,-1),%%优惠价格《枫少》
			LimitCount = get_intvalue_by_key(2,1,ServerDiscount,-1),
			LimitTime = get_intvalue_by_key(3,1,ServerDiscount,-1),
			YServerPrice = get_intvalue_by_key(2,1,ServerPrice,-1),%%真实价格《枫少》
			LServerPrice = get_intvalue_by_key(3,1,ServerPrice,-1),
			CHServerPrice = get_intvalue_by_key(4,1,ServerPrice,-1),     %%CHServerPrice is Charge integral
			COServerPrice = get_intvalue_by_key(5,1,ServerPrice,-1),	 %%COServerPrice is Consumption integral
			Ticket = role_op:get_ticket_from_roleinfo(RoleInfo),
			Charge_integral = get_role_charge_integral(),
			Consum_integral = get_role_consum_integral(),%%真实数量《枫少》
			case check_count(Restrict,MitemId,Count) of
				true->
					case is_packege_full(MitemId,Count) of
						full ->
							{error, package};
						ok ->
							case Price of 
								{ip,?MONEY_GOLD,YMoney} ->
									manager_buy_mall_item(LimitPrice,LimitCount,LimitTime,ServerDiscount,Bodcast,ServerPrice,YServerPrice,MitemId,YMoney,Count,BuyType,?MONEY_GOLD,got_fromgold);
								{ip,?MONEY_TICKET,LMoney} ->
									manager_buy_mall_item(LimitPrice,LimitCount,LimitTime,ServerDiscount,Bodcast,ServerPrice,LServerPrice,MitemId,LMoney,Count,BuyType,?MONEY_TICKET,got_giftplayer);
								{ip,?MONEY_CHARGE_INTEGRAL,CHMoney}->
									manager_buy_mall_item(LimitPrice,LimitCount,LimitTime,ServerDiscount,Bodcast,ServerPrice,CHServerPrice,MitemId,CHMoney,Count,BuyType,?MONEY_CHARGE_INTEGRAL,got_charge_integral);
								{ip,?MONEY_CONSUMPTION_INTEGRAL,COMoney}->
									manager_buy_mall_item(LimitPrice,LimitCount,LimitTime,ServerDiscount,Bodcast,ServerPrice,COServerPrice,MitemId,COMoney,Count,BuyType,?MONEY_CONSUMPTION_INTEGRAL,got_consum_integral);
								{ip,_,_} ->
									{error,noitem}
							end
					end;
				false->
					{error,restrict}
			end
	end.

buy_sales_item(RoleInfo,MitemId,Count,Price,BuyType) ->
	case mall_item_db:get_up_sales_info(MitemId) of
		{ok,[]} -> 
			{error,shelves};
		{ok,MitemInfo} ->
			#mall_up_sales_table{price=ServerPrice,
								 discount=ServerDiscount,
								 uptime=Uptime, 
								 restrict=Restrict,
								 bodcast=Bodcast} = MitemInfo,
			LimitPrice = get_intvalue_by_key(1,1,ServerDiscount,-1),
			LimitCount = get_intvalue_by_key(2,1,ServerDiscount,-1),
			LimitTime = get_intvalue_by_key(3,1,ServerDiscount,-1),
			YServerPrice = get_intvalue_by_key(2,1,ServerPrice,-1),
			Charge_integral = get_role_charge_integral(),
			Consum_integral = get_role_consum_integral(),
			case check_count_by_sales(Restrict,MitemId,Count,Uptime) of
				true->
					case is_packege_full(MitemId,Count) of
						full->
							{error, package};
						ok->
							case Price of 
								{ip,?MONEY_GOLD,YMoney} ->
									manager_buy_mall_item(LimitPrice,LimitCount,LimitTime,ServerDiscount,Bodcast,ServerPrice,YServerPrice,MitemId,YMoney,Count,BuyType,?MONEY_GOLD,got_sales);
								{ip,_,_} ->
									{error,noitem}
							end
					end;
				false->
					{error,restrict}
			end
	end.

manager_buy_mall_item(LimitPrice,LimitCount,LimitTime,ServerDiscount,Bodcast,ServerPrice,Server_Price,MitemId,Money,Count,BuyType,MoneyType,Reason)->
	if 
		((LimitPrice > 0) and (LimitPrice =:= Money)) or ((LimitPrice =:= -1) and (Server_Price =:= Money)) ->
			if 
				(LimitCount =:= -1) or (LimitCount >= Count) ->
					{MegaSec,Sec,_} = timer_center:get_correct_now(),
					CurTime = MegaSec*1000000 + Sec,
					if 
						(LimitTime =:= -1) or (LimitTime > CurTime) ->
							CostMoney = Money*Count,
							case role_op:check_money(MoneyType, CostMoney) of
								true->
									case buy_mall_item_impl(MitemId,LimitCount,Count,BuyType,Reason) of
										full -> 
											{error, package};
										ok -> 
											RoleInfo = get(creature_info),
											quest_op:update({mall_item,MitemId},Count),
											role_op:money_change(MoneyType, -Money*Count,lost_mall),
											gm_logger_role:role_buy_mall_item(get_id_from_roleinfo(RoleInfo),MitemId,Money,Count,MoneyType,get_level_from_roleinfo(RoleInfo)),
											case MoneyType of
												?MONEY_GOLD->
													flush_latest(MitemId,ServerPrice,ServerDiscount),
													{Charge_integral,Consume_integral} = get(role_mall_integral),
													NewConsume_integral = Consume_integral + trunc(CostMoney/10),
													put(role_mall_integral,{Charge_integral,NewConsume_integral}),
													Message = login_pb:encode_change_role_mall_integral_s2c(#change_role_mall_integral_s2c{charge_integral=Charge_integral,by_item_integral=NewConsume_integral}),
													role_op:send_data_to_gate(Message),
													mall_integral_db:add_role_mall_integral(get(roleid),Charge_integral,NewConsume_integral);
												_->
													nothing
											end,
											Remain = LimitCount - Count,
											case Bodcast of
												0->
													nothing;
												SysId->
													abstract_bodcast(SysId,{MitemId,Remain})
											end,
											{ok};
										_->
											{error,noitem}
									end;
								false->
									case MoneyType of
										?MONEY_GOLD->
											{error,gold};
										?MONEY_TICKET->
											{error,ticket};
										_->
											{error,integral}
									end
							end;
						true->
							{error,time}
					end;
				true->
					{error,count}
			end;	 
		true ->
			{error,prepair}
	end.

abstract_bodcast(SysId,{MitemId,Remain})->
	case SysId of
		?SYSTEM_CHAT_GET_MALL_ITEM->
			system_bodcast_for_getitem(SysId,get(creature_info),MitemId);
		?SYSTEM_CHAT_MALL_RESTRICT->
			if 
				Remain > 0 ->
					system_bodcast(SysId,get(creature_info),MitemId,Remain);
				true->
					nothing
			end;
		?SYSTEM_CHAT_MALL_9999->
			system_bodcast_for_getitem(SysId,get(creature_info),MitemId);
		_->
			nothing
	end.

system_bodcast_for_getitem(SysId,RoleInfo,ItemTempId)->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamItem = system_chat_util:make_item_param(ItemTempId),
	MsgInfo = [ParamRole,ParamItem],
	system_chat_op:system_broadcast(SysId,MsgInfo).

system_bodcast(SysId,RoleInfo,ItemTempId,Remain) ->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamItem = system_chat_util:make_item_param(ItemTempId),
	ParamInt = system_chat_util:make_int_param(Remain),
	MsgInfo = [ParamRole,ParamItem,ParamInt],
	system_chat_op:system_broadcast(SysId,MsgInfo).

system_bodcast_flush_sales_rpc_call(SysId,ItemTempId,Price,Count)->
	rpc:call(node_util:get_mapnode(), ?MODULE, system_bodcast_flush_sales, [SysId,ItemTempId,Price,Count]).

system_bodcast_flush_sales(SysId,ItemTempId,Price,Count) ->
	ParamItem = system_chat_util:make_item_param(ItemTempId),
	ParamIntPrice = system_chat_util:make_int_param(Price),
	ParamIntCount = system_chat_util:make_int_param(Count),
	MsgInfo = [ParamItem,ParamIntPrice,ParamIntCount],
	system_chat_op:system_broadcast(SysId,MsgInfo).

%%
%% Local Functions
%%
change_role_integral(Gold,RoleId)->
	AddIntegral = trunc(Gold/10),
	case mall_integral_db:get_tole_mall_integral(RoleId) of
		[]->
			NewChargeIntegral = AddIntegral,
			Consume_integral = 0,
			mall_integral_db:add_role_mall_integral(RoleId,NewChargeIntegral,Consume_integral);
		RoleIntegral->
			Charge_integral = element(#role_mall_integral.charge_integral,RoleIntegral),
			Consume_integral = element(#role_mall_integral.consumption_integral,RoleIntegral),
			NewChargeIntegral = Charge_integral + AddIntegral,
			mall_integral_db:add_role_mall_integral(RoleId,NewChargeIntegral,Consume_integral)
	end,
	case role_pos_util:where_is_role(RoleId) of
		[]->
			nothing;
		RolePos->
			role_pos_util:send_to_role_by_pos(RolePos, {role_mall_integral,{role_integral_change,NewChargeIntegral,Consume_integral}}),
			Message = login_pb:encode_change_role_mall_integral_s2c(#change_role_mall_integral_s2c{charge_integral=NewChargeIntegral,by_item_integral=Consume_integral}),
			role_pos_util:send_to_clinet_by_pos(RolePos, Message)
	end.

proc_msg({role_integral_change,ChargeIntegral,Consume_integral})->
	put(role_mall_integral,{ChargeIntegral,Consume_integral}).

add_role_charge_integral_by_value(Value)->
	{Charge_integral,Consume_integral} = get(role_mall_integral),
	NewChargeIntegral = Charge_integral + Value,
	put(role_mall_integral,{NewChargeIntegral,Consume_integral}),
	Message = login_pb:encode_change_role_mall_integral_s2c(#change_role_mall_integral_s2c{charge_integral=NewChargeIntegral,by_item_integral=Consume_integral}),
	role_op:send_data_to_gate(Message),
	ok.

get_role_charge_integral()->
	{Charge_integral,_} = get(role_mall_integral),
	Charge_integral.

get_role_consum_integral()->
	{_,Consume_integral} = get(role_mall_integral),
	Consume_integral.
