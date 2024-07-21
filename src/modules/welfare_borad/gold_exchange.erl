%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-8-6
%% Description: TODO: Add description to gold_exchange_activity
-module(gold_exchange).

%%
%% Include files
%%
-include("common_define.hrl").
-include("active_board_def.hrl").
-include("welfare_activity_define.hrl").
-define(ZERO_TICKET,0).
-define(MAIL_TITLE,68).
-define(MAIL_CONTENT,69).
-define(MAIL_FROMNAME,63).

%%
%% Exported Functions
%%
-compile(export_all).
%%
%% API Functions
%%

init()->
	ExchangeTicket = read_exchange_ticket_from_db(),
	case welfare_activity_op:judge_activity_state(?GOLD_EXCHANGE_ACTIVITY) of
		true->
			put(exchange_ticket,ExchangeTicket);
		_->
			if
				ExchangeTicket =:= ?ZERO_TICKET->
					put(exchange_ticket,?ZERO_TICKET);
				true->
					put(exchange_ticket,?ZERO_TICKET),
					async_write(?ZERO_TICKET),
					role_op:money_change( ?MONEY_TICKET, ExchangeTicket,got_gold_exchange_gift),
					send_mail()
			end
	end.


hook_on_offline()->
	async_write(get(exchange_ticket)).

export_for_copy()->
	get(exchange_ticket).
	
load_by_copy(ExchangeTicket)->
	put(exchange_ticket,ExchangeTicket).
			

get_exchange_ticket_num()->
	ExchangeTicket = get(exchange_ticket),
	if
		ExchangeTicket =:= 0->
			BinMsg = welfare_activity_packet:encode_welfare_gold_exchange_init_s2c(ExchangeTicket),
			role_op:send_data_to_gate(BinMsg);
		true->
			case welfare_activity_op:judge_activity_state(?GOLD_EXCHANGE_ACTIVITY) of 	
				true->
					BinMsg = welfare_activity_packet:encode_welfare_gold_exchange_init_s2c(ExchangeTicket),
					role_op:send_data_to_gate(BinMsg);
				_->
					put(exchange_ticket,?ZERO_TICKET),
					async_write(?ZERO_TICKET),
					role_op:money_change( ?MONEY_TICKET, ExchangeTicket,got_gold_exchange_gift),
					send_mail(),
					BinMsg = welfare_activity_packet:encode_welfare_gold_exchange_init_s2c(?ZERO_TICKET),
					role_op:send_data_to_gate(BinMsg)
			end
	end.
	
	


exchange_item()->
			ExchangeTicket = get(exchange_ticket),
			if 
				ExchangeTicket =:= 0->
					Msg = welfare_activity_packet:encode_welfare_gold_exchange_init_s2c(?ZERO_TICKET),
					role_op:send_data_to_gate(Msg);
				true->
					put(exchange_ticket,?ZERO_TICKET),
					async_write(?ZERO_TICKET),
					role_op:money_change( ?MONEY_TICKET, ExchangeTicket,got_gold_exchange_gift),
					Msg = welfare_activity_packet:encode_welfare_gold_exchange_init_s2c(?ZERO_TICKET),
					role_op:send_data_to_gate(Msg)
			end.
	


consume_gold_change(GoldCount,Reason)->
	if
		GoldCount>0->
			if
				Reason =:= lost_stall_buy ->
		  		 	nothing;
	   			true->
					case welfare_activity_op:judge_activity_state(?GOLD_EXCHANGE_ACTIVITY) of
					   	true->
						   	OldTicket = get(exchange_ticket),
							Rate = case welfare_activity_db:get_welfare_activty_condition(?GOLD_EXCHANGE_ACTIVITY) of
									   []->
										   1;
									   TmpRate->
										   TmpRate 
								   end,
							TicketCount = trunc(GoldCount*Rate),
							NewTicket = OldTicket+TicketCount,
							put(exchange_ticket,NewTicket);
						_->
							nothing
					end
			end;
		true->
			nothing
	end.


%%
%%db operate 
%% 
read_exchange_ticket_from_db()->
	case welfare_activity_db:read_exchange_ticket_from_db(get(roleid)) of
		[]->
			?ZERO_TICKET;
		ExchangeTicket->
			ExchangeTicket
	end.

async_write(ExchangeTicket)->
%% 	io:format("async_write,ExchangeTicket:~p~n",[ExchangeTicket]),
	welfare_activity_db:write_exchange_ticket(get(roleid),ExchangeTicket).


send_mail()->
	Title = language:get_string(?MAIL_TITLE),
	Content = language:get_string(?MAIL_CONTENT),
	FromName = language:get_string(?MAIL_FROMNAME),
	RoleName = creature_op:get_name_from_creature_info(get(creature_info)),
	case gm_op:gm_send_rpc(FromName,RoleName,Title,Content,0,0,0) of
		{ok}->
			nothing;
		{error,Reason}->
			slogger:msg("gold_exchange,send_mail error,Reason:~p~n",[Reason])
	end.

%%
%% Local Functions
%%

