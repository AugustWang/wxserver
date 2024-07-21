%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-28
%% Description: TODO: Add description to npc_trad
-module(npc_trad_action).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-export([trad_action/4,trad_action/5]).

-export([import_npc_sell_list/1]).

-export([init_func/0,registe_func/1,enum/3]).

-behaviour(npc_function_mod).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).

-include("item_struct.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("error_msg.hrl").
-include("npc_define.hrl").


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(npc_sell_list,record_info(fields,npc_sell_list),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{npc_sell_list,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
init_func()->
	npc_function_frame:add_function(trad,?NPC_FUNCTION_TRAD, ?MODULE).

registe_func(NpcId)->
	TradeList = read_sell_item_for_npc(NpcId),
	Mod= ?MODULE,
	Fun= trad_action,
	Arg=  convert_to_shopping_items(TradeList),
	Response=#kl{key=?NPC_FUNCTION_TRAD, value=[]},
	EnumMod = ?MODULE,
	EnumFun = enum,
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,Arg},
	{Response,Action,Enum}.

%%
%% Local Functions
%%
enum(_RoleInfo,_TradeList,NpcId)->
	Message = role_packet:encode_enum_shoping_item_s2c(NpcId),
	role_op:send_data_to_gate(Message),		
	{ok}.

trad_action(RoleInfo,_TradeList,sell,Slot)->
	case do_sell(RoleInfo,Slot) of
		{ok}-> ignor;
		{error,Code}->
		case Code of
			cannot_sell->
				Message = role_packet:encode_sell_item_fail_s2c(?ERROR_TRAD_CANNOT_SELL),	
				role_op:send_data_to_gate(Message);
			_->
				nothing									
		end		
	end;

trad_action(RoleInfo,_TradeList,repair,Slot)->
	if
		Slot =:= 0->
				case items_op:repair_item_all() of
					less_money->
						Message = mall_packet:encode_buy_item_fail_s2c(?ERROR_LESS_MONEY),	
						role_op:send_data_to_gate(Message);
					_->
						nothing
				end;
		true->
			case items_op:repair_item(Slot) of
				less_money->
					Message = mall_packet:encode_buy_item_fail_s2c(?ERROR_LESS_MONEY),	
					role_op:send_data_to_gate(Message);
				_->
					nothing
			end	
	end.

trad_action(RoleInfo,TradeList,buy,ItemClsid, ItemCount)->
	case do_buy(RoleInfo,TradeList,ItemClsid, ItemCount) of
		{ok}-> nothing;%%achieve_op:achieve_update({buy_item}, [ItemClsid], ItemCount);
		{error,Code}->
			case Code of
				package -> 
					%%Message = mall_packet:encode_buy_item_fail_s2c(?ERROR_PACKEGE_FULL),	
					%%role_op:send_data_to_gate(Message);
					nothing;
				money ->
					Message = mall_packet:encode_buy_item_fail_s2c(?ERROR_LESS_MONEY),	
					role_op:send_data_to_gate(Message);
				noitem->   
					slogger:msg("trad_action buy  error ,no item! maybe hack! Roleid: ~p ~n ",[get_id_from_roleinfo(RoleInfo)])
			end
	end.

do_sell(RoleInfo,Slot)->
	  case package_op:get_iteminfo_in_package_slot(Slot) of
		 []-> {error,slot};
		 ItemInfo->
			 Count = get_count_from_iteminfo(ItemInfo),
			 Money = get_sellprice_from_iteminfo(ItemInfo)*Count,
			 if 
			 	Money =:= 0->
			 		{error,cannot_sell};
			 	true->	
					 role_op:consume_item(ItemInfo,Count),
					 role_op:money_change(1,Money,got_npctrad),
			 		{ok}
			 end
	 end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Private
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_money(RoleMoney, ItemCount ,ItemPrices) ->
	F = fun(#ip{moneytype=MoneyType,price=Price} ,Acc)-> 
						case Acc of
							false-> false;
							true->
								Price*ItemCount =< element(MoneyType, RoleMoney)
						end
				end,
	lists:foldl(F, true, ItemPrices).

do_buy(RoleInfo,TradeList,ItemClsid, ItemCount)->
	case lists:keyfind(ItemClsid, #sp.itemclsid, TradeList) of
		false->  {error,noitem};
		Shoping_item->
			Prices = erlang:element(#sp.price,Shoping_item),
			BoundSilver = role_op:get_boundsilver_from_roleinfo(RoleInfo),
			Silver = role_op:get_silver_from_roleinfo(RoleInfo),
			Gold = role_op:get_gold_from_roleinfo(RoleInfo),
			Tick = role_op:get_ticket_from_roleinfo(RoleInfo),
			case check_money({BoundSilver+Silver,Gold,Tick}, ItemCount,Prices) and (ItemCount>=0) of
				false-> {error,money};
				true->
					case role_op:auto_create_and_put(ItemClsid,ItemCount,got_npctrad) of
						full ->
							{error, package};
						{ok,_} ->
							MoneyItems = make_price_list(Prices,ItemCount),
							lists:foreach(fun(#ip{moneytype=MoneyType,price=MoneyCount})->
												  role_op:money_change(MoneyType, -MoneyCount,lost_npctrad)
										  end,MoneyItems),
							{ok}
					end
			end
	end.

%%%%%%%%%%%%%%%
%%
%% db operator
%%
%%%%%%%%%%%%%%%
read_sell_item_for_npc(NpcId)->
	case dal:read_rpc(npc_sell_list, NpcId) of
		{ok,[ItemList]}->  element(#npc_sell_list.sellitems,ItemList);
		_->[]
	end.
	
	
convert_to_shopping_items(TradList)->
	%%shoping_item
	PricesFun = fun(Price)->
						#ip{moneytype = element(#itemprice.currencytype-1,Price),
									price = element(#itemprice.price-1,Price)}
				end,
	ShoppItemFun = fun(ShopingItem)->
						   ItemClsId = element(#sellitem.itemid-1,ShopingItem),
						   PricesList = element(#sellitem.prices-1,ShopingItem),
						   PricesListRec = lists:map(PricesFun, PricesList),
						   #sp{itemclsid = ItemClsId,
										 price = PricesListRec}
				   end,
	lists:map(ShoppItemFun, TradList).
	

add_sell_item_to_mnesia(Term)->
	dal:write(Term).

import_npc_sell_list(File)->
	dal:clear_table(npc_sell_list),
	case file:consult(File) of
		{ok, [Terms]} -> 
			lists:foreach(fun(Term)-> 
								  add_sell_item_to_mnesia(Term)
								  end, Terms);
		{error, Reason} ->
			slogger:msg("import_npc_sell_list error:~p~n",[Reason])
	end.
  
make_price_list(Prices,Count)->
	lists:map(fun(#ip{price=PriceValue}=Price)-> 
					  Price#ip{price=PriceValue*Count}
					  end, Prices).