%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(trade_role_handle).
-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").

%%鐢宠浜ゆ槗
handle_trade_role_apply_c2s(RoleId)->
	case role_manager:get_role_info(RoleId) of
		undefined ->
			slogger:msg("role: ~p  trade_role_apply_c2s  RoleId ~p undefined ~n",[get(roleid),RoleId]);
		RoleInfo ->
			ServerCkeck = get_serverid_from_roleinfo(RoleInfo) =:= get_serverid_from_roleinfo(get(creature_info)),
			NotTradingNow = not trade_role:is_trading(),
			case NotTradingNow and ServerCkeck of
				true->
					SelfState = get_state_from_roleinfo(get(creature_info)),
					OtherState = get_state_from_roleinfo(RoleInfo ),
					IsInAoi = creature_op:is_in_aoi_list(RoleId),
					if
						SelfState =:= deading->
							Errno = ?TRADE_ERROR_YOU_ARE_DEAD;
						OtherState =:= deading->
							Errno = ?TRADE_ERROR_TARGET_ARE_DEAD;
						not IsInAoi->
							Errno = ?TRADE_ERROR_IS_NOT_AOI;	
						true->
							Errno = []
					end,
					if
						Errno =/= []->
							ErrMsg = trade_role_packet:encode_trade_role_errno_s2c(Errno),
							role_op:send_data_to_gate(ErrMsg);
						true->			
							Msg = {trade_role_apply,get(roleid)},
							role_op:send_to_other_role(RoleId,Msg )
					end;
				_->
					slogger:msg("maybe hack handle_trade_role_apply_c2s is trading now! ~p ",[get(roleid)])
			end
	end.

%%鎺ュ彈浜ゆ槗
handle_trade_role_accept_c2s(RoleId)->
	case trade_role:is_in_inviter(RoleId) of
		true->
			case trade_role:is_trading() of
				false->
					case role_manager:get_role_info(RoleId) of
						undefined ->
							slogger:msg("role: ~p  trade_role_accept_c2s  RoleId ~p undefined ~n",[get(roleid),RoleId]);
						_ ->
							trade_role:remove_from_inviter(RoleId),
							%%閫氱煡瀵规柟寮�鍚�
							Msg = {trade_role_accept,get(roleid)},
							role_op:send_to_other_role(RoleId,Msg),
							%%閫氱煡瀹㈡埛绔紑鍚氦鏄�
							MsgBegin = trade_role_packet:encode_trade_begin_s2c(RoleId),
							role_op:send_data_to_gate(MsgBegin),
							%%寮�鍚氦鏄�
							trade_role:trade_role({trade_begin,RoleId})
					end;
				true->
					ErrMsg = trade_role_packet:encode_trade_role_errno_s2c(?TRADE_ERROR_TRADING_NOW),
					role_op:send_data_to_gate(ErrMsg)
			end;	
		false->
			slogger:msg("RoleId maybe hack  ~p, accpet trad with who not inviter him ~n",[get(roleid)])
	end.
	
%%鎷掔粷浜ゆ槗
handle_trade_role_decline_c2s(RoleId)->
	case trade_role:is_in_inviter(RoleId) of
		true->
			trade_role:remove_from_inviter(RoleId),
			case role_manager:get_role_info(RoleId) of
				undefined ->
					nothing;
				RoleInfo->
					MsgDecline  = trade_role_packet:encode_trade_role_decline_s2c(get(roleid)),
					role_op:send_to_other_client_roleinfo(RoleInfo,MsgDecline)
			end;
		false->
			nothing
	end.

%%璁剧疆閲戦挶
handle_set_trade_money_c2s(Money_type,Moneycount)->
	trade_role:trade_role({set_money,Money_type,Moneycount}).

%%璁剧疆鐗╁搧
handle_set_trade_item_c2s(Trade_slot,Package_slot)->
	trade_role:trade_role({set_trade_item,Trade_slot,Package_slot}).

%%閿佸畾
handle_trade_role_lock_c2s()->
	trade_role:trade_role(lock).

%%鍙栨秷
handle_cancel_trade_c2s()->
	case trade_role:is_trading() of
		true->
			role_op:send_to_other_role(get(trade_target),cancel_trade),
			trade_role:trade_role(cancel);
		_->
			nothing
	end.	

%%瀹屾垚浜ゆ槗
handle_trade_role_dealit_c2s()->
	trade_role:trade_role(deal).


%%%%%%%%%%%%%%%%%%
%% 杩涚▼闂�
%%%%%%%%%%%%%%%%%%

%%鏈変汉鐢宠鍜屼綘浜ゆ槗
handle_trade_role_apply(RoleId)->
	case role_manager:get_role_info(RoleId) of
		undefined ->
			nothing;
		RoleInfo ->	
			case trade_role:is_trading() of
				true->
					ErrMsg = trade_role_packet:encode_trade_role_errno_s2c(?TRADE_ERROR_TRADING_NOW),
					role_op:send_to_other_client_roleinfo(RoleInfo,ErrMsg);
				false->
						trade_role:insert_inviter(RoleId),
						%%閫氱煡瀹㈡埛绔湁浜哄拰浣犱氦鏄�
						Msg =  trade_role_packet:encode_trade_role_apply_s2c(RoleId),
						role_op:send_data_to_gate(Msg )
			end
	end.


%%鍒汉鎺ュ彈浜嗗拰浣犱氦鏄�
handle_trade_role_accept(RoleId)->
	case role_manager:get_role_info(RoleId) of
		undefined ->
			nothing;
		_ ->
			%%閫氱煡瀹㈡埛绔氦鏄撳紑鍚�
			MsgBegin = trade_role_packet:encode_trade_begin_s2c(RoleId),
			role_op:send_data_to_gate(MsgBegin),
			%%寮�鍚氦鏄�
			trade_role:trade_role({trade_begin,RoleId})
	end.

%%鍒汉閿佸畾浜�
handle_other_lock()->
	%%鍙戦�佸埆浜洪攣瀹�
	trade_role:trade_role(other_lock).

handle_other_deal()->
	trade_role:trade_role(other_deal).

handle_cancel_trade()->
	trade_role:trade_role(cancel).
	
handle_trade_error()->
	trade_role:trade_role(trade_error).



