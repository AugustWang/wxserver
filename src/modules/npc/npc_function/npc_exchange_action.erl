%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-3-1
%% Description: TODO: Add description to npc_exchange_action
-module(npc_exchange_action).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-export([exchange_action/6]).

-export([import_npc_exchange_list/1]).

-export([init_func/0,registe_func/1,enum/3]).

-behaviour(npc_function_mod).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).

-include("item_struct.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("error_msg.hrl").
-include("npc_define.hrl").

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(npc_exchange_list,record_info(fields,npc_exchange_list),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{npc_exchange_list,proto}].

%%
%% API Functions
%%
init_func()->
	npc_function_frame:add_function(exchange,?NPC_FUNCTION_EXCHANGE, ?MODULE).

registe_func(NpcId)->
	ExchangeList = read_exchange_item_for_npc(NpcId),
	Mod= ?MODULE,
	Fun= exchange_action,
	Arg=  convert_to_exchange_items(ExchangeList),
	Response=#kl{key=?NPC_FUNCTION_EXCHANGE, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = convert_to_exchange_items(ExchangeList),
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.


%%
%% Local Functions
%%
enum(_RoleInfo,_TradeList,NpcId)->
	Message = exchange_packet:encode_enum_exchange_item_s2c(NpcId),
	role_op:send_data_to_gate(Message),		
	{ok}.



%%%%%%%%%%%%%%%
%%
%% db operator
%%
%%%%%%%%%%%%%%%
read_exchange_item_for_npc(NpcId)->
	case dal:read_rpc(npc_exchange_list, NpcId) of
		{ok,[ItemList]}->  element(#npc_exchange_list.exchangeitems,ItemList);
		_->[]
	end.
	
	
convert_to_exchange_items(ExchangeList)->
	%%exchange_item
	PricesFun = fun(Price,Acc)->
						if
							element(#itemprice.currencytype-1,Price)>10000->
								Acc;
							true->
								Acc ++ [#ip{moneytype = element(#itemprice.currencytype-1,Price),
									price = element(#itemprice.price-1,Price)}]
						end
				end,
	ExchangeFun = fun(Price,Acc)->
						if
							element(#itemprice.currencytype-1,Price)>10000->
								Acc ++ [#l{itemprotoid = element(#itemprice.currencytype-1,Price),
							 			count = element(#itemprice.price-1,Price)}];
							true->
								Acc
						end
				  end,
	ExchangeItemFun = fun(ExchangeItem)->
						   ItemClsId = element(#sellitem.itemid-1,ExchangeItem),
						   PricesList = element(#sellitem.prices-1,ExchangeItem),
						   ExchangeListRec = lists:foldl(ExchangeFun, [], PricesList),
						   PricesListRec = lists:foldl(PricesFun, [],PricesList),
						   #dh{itemclsid = ItemClsId,consume=ExchangeListRec,
										 money = PricesListRec}
				   end,
	lists:map(ExchangeItemFun, ExchangeList).
	

add_exchange_item_to_mnesia(Term)->
	dal:write(Term).

import_npc_exchange_list(File)->
	dal:clear_table(npc_exchange_list),
	case file:consult(File) of
		{ok, [Terms]} -> 
			lists:foreach(fun(Term)-> 
								  add_exchange_item_to_mnesia(Term)
								  end, Terms);
		{error, Reason} ->
			slogger:msg("import_npc_exchange_list error:~p~n",[Reason])
	end.

exchange_action(RoleInfo,ExchangeList,exchange,ItemClsid, ItemCount, Slots)->
	case do_exchange(RoleInfo,ExchangeList,ItemClsid, ItemCount, Slots) of
		{ok}-> nothing;
		{error,Code}->
			case Code of
				itemcount ->
					Message = exchange_packet:encode_exchange_item_fail_s2c(?ERROR_MISS_ITEM),	
					role_op:send_data_to_gate(Message);
				consume ->
					Message = exchange_packet:encode_exchange_item_fail_s2c(?ERROR_MISS_ITEM),	
					role_op:send_data_to_gate(Message);
				package -> 
					Message = exchange_packet:encode_exchange_item_fail_s2c(?ERROR_PACKEGE_FULL),	
					role_op:send_data_to_gate(Message);
				money ->
					Message = exchange_packet:encode_exchange_item_fail_s2c(?ERROR_LESS_MONEY),	
					role_op:send_data_to_gate(Message);
				noitem->   
					slogger:msg("exchange_action exchange_item error ,no item! maybe hack! Roleid: ~p ~n ",[get_id_from_roleinfo(RoleInfo)])
			end
	end.

do_exchange(RoleInfo,ExchangeList,ItemClsid, ItemCount, Slots)->
	if 
		ItemCount=:= 1->
		case lists:keyfind(ItemClsid, #dh.itemclsid, ExchangeList) of
		false->  {error,noitem};
		Exchange_item->
			Consume = erlang:element(#dh.consume, Exchange_item),
			[{_,ConsumeItem,ConsumeCount}|_] = Consume,
			Prices = erlang:element(#dh.money,Exchange_item),
			RoleId = role_op:get_id_from_roleinfo(RoleInfo),
			Level = role_op:get_level_from_roleinfo(RoleInfo),
			Silver = role_op:get_boundsilver_from_roleinfo(RoleInfo),
			Gold = role_op:get_gold_from_roleinfo(RoleInfo),
			Tick = role_op:get_ticket_from_roleinfo(RoleInfo),
			case check_consume(Consume,Slots) of
				false->
					{error,consume};
				true->
					case check_money({Silver,Gold,Tick}, ItemCount,Prices) of
						false-> {error,money};
						true->
							case role_op:auto_create_and_put(ItemClsid,ItemCount,got_npc_exchange) of
								full ->
									{error, package};
								{ok,_} ->
									creature_sysbrd_util:sysbrd({npc_exchange,ItemClsid},ItemCount),
									lists:foreach(fun(#l{itemprotoid=Slot,count=Count})-> 
														  case equipment_op:get_item_from_proc(Slot) of
															  []->
																  nothing;
															  ItemInfo->
																  ItemInfo =equipment_op:get_item_from_proc(Slot),
																  ProtoId = get_template_id_from_iteminfo(ItemInfo),
																  role_op:consume_items(ProtoId,Count) 
														  end end, Slots),
									MoneyItems = make_price_list(Prices,ItemCount),
									lists:foreach(fun(#ip{moneytype=MoneyType,price=MoneyCount})->
												  	role_op:money_change(MoneyType, -MoneyCount,lost_npctrad)
										  	end,MoneyItems),
									gm_logger_role:role_exchange_item(RoleId, Level, ItemClsid, ItemCount, ConsumeItem, ConsumeCount),
											{ok}
							end
					end
			end
		end;
		true->
			{error,itemcount}
	end.

make_price_list(Prices,Count)->
	lists:map(fun(#ip{price=PriceValue}=Price)-> 
					  Price#ip{price=PriceValue*Count}
					  end, Prices).

get_item_count_by_protoid(TmplateId)->
	item_util:get_items_count_in_package(TmplateId).
%%	PlayerItems = items_op:get_items_by_template(TmplateId),	
%%	F = fun(ItemId,Acc)->
%%				ItemInfo = items_op:get_item_info(ItemId),
%%				Count = get_count_from_iteminfo(ItemInfo),
%%				case Count of
%%					0->
%%						Acc+0;
%%					_->
%%						Acc+Count			    
%%				end
%%		end,				    
%%	lists:foldl(F,0,PlayerItems).

check_consume(Consume,Slots)->
	CheckFun = fun(#l{itemprotoid=Slot,count=Count}, Acc)->
					   case equipment_op:get_item_from_proc(Slot) of
						   []->
							   Acc;
						   ItemInfo->
							   ProtoId = get_template_id_from_iteminfo(ItemInfo),
							   ProtoCount = get_item_count_by_protoid(ProtoId),
							   case lists:keyfind(ProtoId, 2, Consume) of
								   false->
									   Acc;
								   {_,_,ICount}->
									   if 
										   ICount=:=Count,ProtoCount>=ICount->
											   case lists:keymember(ProtoId, 1, Acc) of
												   true->
													   Acc;
												   false->
													   Acc ++ [{ProtoId,ProtoCount}]
											   end;
										   true->
											   Acc
									   end
							   end
					   end
			   end,
	case Slots of
		[]->
			false;
		_->		
			CheckResult = lists:foldl(CheckFun, [], Slots),
			if
				erlang:length(CheckResult)=:=erlang:length(Consume)->
					true;
				true->
					false
			end
	end.
							   
						   

check_money(RoleMoney, ItemCount ,ItemPrices) ->
	F = fun(#ip{moneytype=MoneyType,price=Price} ,Acc)-> 
						case Acc of
							false-> false;
							true->
								Price*ItemCount =< element(MoneyType, RoleMoney)
						end
				end,
	lists:foldl(F, true, ItemPrices).
