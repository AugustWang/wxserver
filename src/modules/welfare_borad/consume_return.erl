%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-10-8
%% Description: TODO: Add description to consume_return
-module(consume_return).

%%
%% Include files
%%
-define(MAIL_TITLE,93).
-define(MAIL_CONTENT,94).
-define(MAIL_FROMNAME,63).
-define(CONSUME_ZERO_GOLD,0).
-include("welfare_activity_define.hrl").
%%
%% Exported Functions
%%
-export([init/1,export_for_copy/0,load_by_copy/1,hook_on_offline/0,gold_change/2]).
%%
%% API Functions
%%
init(RoleId)->
	ConsumeGold = read_consume_gold_from_db(RoleId),
	case welfare_activity_op:judge_activity_state(?CONSUME_RETRURN) of 
		true->
			put(consume_gold,ConsumeGold);
		_->
			put(consume_gold,?CONSUME_ZERO_GOLD)
	end.

		
export_for_copy()->
	get(consume_gold).

load_by_copy(ConsumeGold)->
	put(consume_gold,ConsumeGold).

hook_on_offline()->
	write_consume_gold_to_db(get(roleid),get(consume_gold)).

			
gold_change(GoldCount,Reason)->
	if
		GoldCount > ?CONSUME_ZERO_GOLD->
			if
				Reason =:= lost_stall_buy ->
					nothing;
				true->
					case welfare_activity_op:judge_activity_state(?CONSUME_RETRURN) of
						true->
							ActivityInfo1 = welfare_activity_db:get_welfare_activity_data(?CONSUME_RETRURN),
							NeedConsumeGold =  welfare_activity_db:get_condition(ActivityInfo1),
							Gift = welfare_activity_db:get_gift(ActivityInfo1),
							OldConsumeGold = get(consume_gold),
							NewConsumeGold = GoldCount+OldConsumeGold,
							if
								NewConsumeGold >= NeedConsumeGold ->
									RemainConsumeGold = NewConsumeGold rem NeedConsumeGold,
									GiftRate = NewConsumeGold div NeedConsumeGold,
									put(consume_gold,RemainConsumeGold),
									send_gift(Gift,GiftRate),
									gm_logger_role:consume_return_activity_log(get(roleid),get(level),GiftRate,RemainConsumeGold);
								true->
									put(consume_gold,NewConsumeGold)
							end;
						_->
							nothing
					end
			end;
		true->
			noting
	end.

						  
						
send_gift(Gift,GiftRate)->
	Title = language:get_string(?MAIL_TITLE),
	Content = language:get_string(?MAIL_CONTENT),
	FromName = language:get_string(?MAIL_FROMNAME),
	RoleName = creature_op:get_name_from_creature_info(get(creature_info)),
	SendMail = fun({Protoid,Count})->
					case gm_op:gm_send_rpc(FromName,RoleName,Title,Content,Protoid,Count*GiftRate,0) of
						{ok}->
							true;
						{error,Reason}->
							slogger:msg("gold_exchange,send_mail error,Reason:~p~n",[Reason])
					end
			   end,
	lists:map(SendMail,Gift).
	


%%db operate

read_consume_gold_from_db(RoleId)->
	case consume_return_db:read_consume_gold_from_db(RoleId) of
		[]->
			?CONSUME_ZERO_GOLD;
		ConsumeGold->
			ConsumeGold
	end.
	
write_consume_gold_to_db(RoleId,ConsumeGold)->
	consume_return_db:write_consume_gold_to_db(RoleId,ConsumeGold).
%%
%% Local Functions
%%

