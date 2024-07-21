%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(trade_role).
-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("slot_define.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
-compile(export_all).
%%trade_info:{{silver,gold,ticket},[{Slot,PacketSlot}]}

%% trade_state:交易状态												接收事件(转向)
%% idle:空闲状态		   											trade_begin(trading)   
%% trading:交易状态 ,  						cancel(idle),set_money(trading),set_trade_item(trading),lock(locking),other_lock(trading_locking)
%% locking:自身封锁	   										cancel(idle),other_lock(dealing)
%% trading_locking:对方已经封锁,自身在trading					cancel(idle),lock(dealing)	 
%% dealing: 双方均封锁，等待完成								cancel(idle),deal(finishing),other_deal(dealing_finishing)
%% dealing_finishing 对方已确认								cancel(idle),deal(finishing)
%% finishing 自己已确认										other_deal(idle)	

%%event:trade_begin,lock,cancel,deal,complete

init()->
	put(trade_info,{{0,0,0},lists:map(fun(Index)->{Index,0}end,lists:seq(0,?TRADE_ROLE_SLOT))}),
	put(trade_state,idle),
	put(trade_inviter,[]),
	put(trade_target,0).

is_trading_slot(PackageSlot)->
	case is_trading() of
		false->
			false;
		true->	
			{Money,TradeSlots} = get(trade_info),
			lists:keymember(PackageSlot,2,TradeSlots)
	end.

insert_inviter(Roleid)->
	put(trade_inviter,[Roleid|get(trade_inviter)]).

is_in_inviter(RoleId)->
	lists:member(RoleId,get(trade_inviter)).

remove_from_inviter(RoleId)->
	lists:delete(RoleId,get(trade_inviter)).

is_trading()->
	get(trade_state) =/= idle.

interrupt()->
	case is_trading() of
		true->
			Msg = trade_role_packet:encode_cancel_trade_s2c(),
			role_op:send_data_to_gate(Msg),
			role_op:send_to_other_role(get(trade_target),cancel_trade),
			init();
		false->
			nothing
	end.
		

cancel()->
	Msg = trade_role_packet:encode_cancel_trade_s2c(),
	role_op:send_data_to_gate(Msg),
	init().
	

trade_role(Msg)->
	Fun = get(trade_state),
	apply(trade_role,Fun,[Msg]).

idle({trade_begin,Roleid})->
	put(trade_target,Roleid),
	put(trade_state,trading);

idle(_Msg)->
	slogger:msg("idle but recv _Msg:~p~n",[_Msg]),
	nothing.

trading({set_money,Money_type,MoneyCount})->
	if
		MoneyCount > 0 ->
			case role_op:check_money(Money_type,MoneyCount) of
				false->
					slogger:msg("trad find hack! Roleid ~p set_money ~p ~n",[get(roleid),MoneyCount]);
				true->
					Moneys = erlang:element(1, get(trade_info)),
					NewMoneys = erlang:setelement(Money_type, Moneys, MoneyCount),
					put(trade_info,erlang:setelement(1,get(trade_info),NewMoneys)),
					Msg = trade_role_packet:encode_update_trade_status_s2c(get(roleid),NewMoneys,[]),
					role_op:send_data_to_gate(Msg ),
					role_op:send_to_other_client(get(trade_target),Msg)
			end;
		true->
			slogger:msg("trad find hack! Roleid ~p set_money ~p ~n",[get(roleid),MoneyCount])
	end;

trading({set_trade_item,Trade_slot,Package_slot})->		%%TODO:检查绑定
	if							%%清空该槽
		Package_slot =:= 0->
			TradSlots = erlang:element(2, get(trade_info)),
			Moneys = erlang:element(1, get(trade_info)),
			put(trade_info,erlang:setelement(2,get(trade_info),lists:keyreplace(Trade_slot, 1,TradSlots,{Trade_slot,0}))),
			Msg = trade_role_packet:encode_update_trade_status_s2c(get(roleid),Moneys,[trade_role_packet:to_slot_info(Trade_slot,[])]),
			role_op:send_data_to_gate(Msg ),
			role_op:send_to_other_client(get(trade_target),Msg);
		true->	
			case package_op:get_iteminfo_in_package_slot(Package_slot) of
				[]->		
					nothing;
				ItemInfo->
					case get_isbonded_from_iteminfo(ItemInfo) of
						0->
							Moneys = erlang:element(1, get(trade_info)),
							TradSlots = erlang:element(2, get(trade_info)),
							case lists:keyfind(Package_slot,2,TradSlots ) of
								false->
									put(trade_info,erlang:setelement(2,get(trade_info),lists:keyreplace(Trade_slot, 1,TradSlots,{Trade_slot,Package_slot}))),
									Msg = trade_role_packet:encode_update_trade_status_s2c(get(roleid),Moneys,[trade_role_packet:to_slot_info(Trade_slot,ItemInfo)]),
									role_op:send_data_to_gate(Msg ),
									role_op:send_to_other_client(get(trade_target),Msg);
								_->
									slogger:msg("set_trade_item error maybe hack  dup package slot! role ~p ~n ",[get(roleid)])
							end;	
						_->
							slogger:msg("set_trade_item error maybe hack !!!! ItemBonded ~p ~n ",[ItemInfo])
					end	
			end
	end;
			
trading(cancel)->
	cancel();

trading(lock)->
	%%通知自己客户端
	Msg = trade_role_packet:encode_trade_role_lock_s2c(get(roleid)), 
	role_op:send_data_to_gate(Msg ),
	%%通知对方我锁定了
	role_op:send_to_other_role(get(trade_target),other_lock),
	put(trade_state,locking);

%%其他人锁定了,转向trading_locking状态
trading(other_lock)->
	%%通知自己客户端
	Msg = trade_role_packet:encode_trade_role_lock_s2c(get(trade_target)),
	role_op:send_data_to_gate(Msg ),
	%%转向半锁定状态
	put(trade_state,trading_locking);

trading(_Msg)->
	slogger:msg("trading but recv _Msg:~p~n",[_Msg]).
	
	
%%他已经锁定,我也锁定,跳过locking状态,直接转向dealing状态
trading_locking(lock)->
	%%通知自己客户端
	Msg = trade_role_packet:encode_trade_role_lock_s2c(get(roleid)),
	role_op:send_data_to_gate(Msg ),
	%%通知对方我锁定了
	role_op:send_to_other_role(get(trade_target),other_lock),
	put(trade_state,dealing);

trading_locking(cancel)->
	cancel();

trading_locking(_Msg)->
	trading(_Msg),
	put(trade_state,trading_locking).

locking(other_lock)->
	%%通知自己客户端
	Msg = trade_role_packet:encode_trade_role_lock_s2c(get(trade_target)),
	role_op:send_data_to_gate(Msg ),
	%%我已经锁定,她锁定了,转向dealing
	put(trade_state,dealing);

locking(cancel)->
	cancel();

locking(_Msg)->
	slogger:msg("locking but recv _Msg:~p~n",[_Msg]),
	nothing.

%%自己确认交易
dealing(deal)->
	case role_manager:get_role_info(get(trade_target)) of
		undefined ->
			cancel();
		RoleInfo ->
			RolePid = get_pid_from_roleinfo(RoleInfo),
			case role_processor:other_deal(RolePid) of
				ok->
					put(trade_state,finishing),
					Msg = trade_role_packet:encode_trade_role_dealit_s2c(get(roleid)), 
					role_op:send_data_to_gate(Msg );
				_->
					cancel()
			end
	end;

%%别人先确认了交易->状态变为:dealing_finishing
dealing(other_deal)->
	%%通知自己客户端她已经确定了
	Msg = trade_role_packet:encode_trade_role_dealit_s2c(get(trade_target)), 
	role_op:send_data_to_gate(Msg ),
	put(trade_state,dealing_finishing);

dealing(cancel)->
	cancel();

dealing(_Msg)->
	slogger:msg("dealing but recv _Msg:~p~n",[_Msg]),
	nothing.

%%别人已经完成,自己点击完成
dealing_finishing(deal)->
	put(trade_state,finishing),
	finish_trade();

dealing_finishing(cancel)->
	cancel();

dealing_finishing(_Msg)->
	slogger:msg("dealing_finishing but recv _Msg:~p~n",[_Msg]),
	nothing.

finishing(cancel)->	
	cancel();
	
finishing(_Msg)->
	slogger:msg("finishing but recv _Msg:~p~n",[_Msg]),
	nothing.

%%最终交易前检测是否交易物品正确
check_can_deal()->
	{{Silver,Gold,Ticket},Items} =  get(trade_info),
	CheckItemExsit = lists:foldl(fun({_,Package_slot},ReTmp)->
						if
							not ReTmp->
								ReTmp;
							Package_slot =:= 0->
								ReTmp;
							true->	
								package_op:is_has_item_in_slot(Package_slot)
						end
					end,true,Items),
	CheckItemExsit and role_op:check_money(?MONEY_SILVER,Silver) and role_op:check_money(?MONEY_GOLD,Gold) and role_op:check_money(?MONEY_TICKET,Ticket).

%%用自己的物品去 call 对方的self_finish,返回对方的物品,再做自己的self_finish....
finish_trade()->
	case check_can_deal() of
		true->
			case role_manager:get_role_info(get(trade_target)) of
				undefined ->
					cancel();
				RoleInfo ->
					case role_processor:trade_finish(get_pid_from_roleinfo(RoleInfo),make_trade_items()) of
						error->
							interrupt();
						{ok,cancel}->
							cancel();
						{ok,OtherItems}->
							OtherId = get(trade_target),		%%self_finish will reinit trade_target so ...
							case self_finish(OtherItems) of
								{MyMoney,MyItem}->
									{OtherMoney,OtherItem} = OtherItems,
									{MySilver,_,_} = MyMoney,
									{OtherSilver,_,_} = OtherMoney,
									gm_logger_role:role_new_trad_log(get(roleid),OtherId,MySilver,MyItem,OtherSilver,OtherItem);
								_->
									nothing
							end,
							init()							
					end		
			end;
		_->
			interrupt()
	end.	

self_finish({OtherMoneys,OtherItems})->
	case get(trade_state) of
		finishing->
			case check_can_deal() of			%%检测当前金钱和物品是否正确
				true->
					%%1.备份自己的物品
					AllTradeItems = make_trade_items(),
					%%2.减去自己的items和moneys
					destroy_items_for_trade(),
					%%3.获取OtherItems和OtherMoneys	
					{Silver,Gold,Ticket} = OtherMoneys,
					role_op:money_change(?MONEY_SILVER,Silver,got_tradplayer),
					items_op:obtain_from_trade_by_items(OtherItems),
					%%清空状态
					init(),
					%%发送客户端成功
					ErrMsg = trade_role_packet:encode_trade_success_s2c(),
					role_op:send_data_to_gate(ErrMsg),
					%%3.返回自己的items和moneys
					AllTradeItems;
				false->
					cancel(),
					cancel
			end;
		_->
			cancel(),
			cancel
	end.
	
destroy_items_for_trade()->
	%%1.取出物品和金钱
	{Moneys,Slots} = get(trade_info),
	%%2.清空当前交易物品状态,以保证销毁物品槽操作成功
	put(trade_info,{{0,0,0},lists:map(fun(Index)->{Index,0}end,lists:seq(0,?TRADE_ROLE_SLOT))}),
	%%3.删除物品和金钱
	lists:foreach(fun({_,PaSlot})->
			if
				PaSlot =/= 0->
					items_op:lost_from_trad_by_slot(PaSlot);
				true->
					nothing
			end	
			end,Slots),
	{Silver,Gold,Ticket} = Moneys,				%%暂时不支持gold和ticket
	role_op:money_change(?MONEY_SILVER,-Silver,lost_tradplayer).	
	
make_trade_items()->
	{Moneys,AllItems} = get(trade_info),
	TradItems = lists:foldl(fun({_,Package_slot},AccItems)->
			if
				Package_slot =:= 0->
					AccItems;
				true->	
					case package_op:get_item_id_in_slot(Package_slot) of
						[]->
							AccItems;
						ItemId->
							[items_op:make_playeritem(ItemId)|AccItems]
					end
			end end,[],AllItems),
	{Silver,_Gold,_Ticket} = Moneys,
%%	gm_logger_role:role_trad_log(get(roleid),get(trade_target),Silver,TradItems),
	{Moneys,TradItems}.		
