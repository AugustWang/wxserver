%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-8-6
%% Description: TODO: Add description to welfare_activity_packet
-module(welfare_activity_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
handle(Msg,RolePid)->
	RolePid ! {welfare_activity,Msg}.

handle_message(#welfare_panel_init_c2s{})->
	welfare_activity_op:welfare_activity_init();

handle_message(#welfare_gold_exchange_init_c2s{})->
	gold_exchange:get_exchange_ticket_num();

handle_message(#welfare_gold_exchange_c2s{})->
	gold_exchange:exchange_item();

handle_message(#welfare_activity_update_c2s{typenumber = TypeNumber,serial_number = SerialNumber})->
%% 	io:format("welfare_activity_update_c2s,TypeNumber:~p,SerialNumber:~p~n",[TypeNumber,SerialNumber]),
	welfare_activity_op:serialnumber_activity_update(TypeNumber,SerialNumber);
					
handle_message(ErrorMsg)->
	slogger:msg("welfare_activity_packet:ErrorMsg:~p~n",[ErrorMsg]).



encode_welfare_panel_init_s2c(PacksStateList)->
	login_pb:encode_welfare_panel_init_s2c(#welfare_panel_init_s2c{packs_state = PacksStateList}).

encode_welfare_gifepacks_state_update_s2c(TypeNumber,TimeState,CompleteState)->
	login_pb:encode_welfare_gifepacks_state_update_s2c(#welfare_gifepacks_state_update_s2c{typenumber = TypeNumber,time_state = TimeState,complete_state = CompleteState}).

encode_welfare_gold_exchange_init_s2c(ConsumeGold)->
	login_pb:encode_welfare_gold_exchange_init_s2c(#welfare_gold_exchange_init_s2c{consume_gold = ConsumeGold}).

encode_welfare_activity_update_s2c(TypeNumber,State,Result)->
	login_pb:encode_welfare_activity_update_s2c(#welfare_activity_update_s2c{typenumber = TypeNumber,state = State,result = Result}).


%%
%% Local Functions
%%

