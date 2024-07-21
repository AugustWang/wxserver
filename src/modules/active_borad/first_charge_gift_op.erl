%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-7-13
%% Description:棣栧厖
-module(first_charge_gift_op).

%%
%% Include files
%%
-include("active_board_define.hrl").
-include("active_board_def.hrl").
-include("error_msg.hrl").
-include("system_chat_define.hrl").
%%
%% Exported Functions
%%

-compile(export_all).

%%
%% API Functions
%%
init()->
	State = get_state(get(roleid)),
	put(first_charge_gift_state,State),
	MsgBin = active_borad_packet:encode_first_charge_gift_state_s2c(State),
	role_op:send_data_to_gate(MsgBin).
		

process_message({first_charge_gift_reward_c2s,_})->
	case get(first_charge_gift_state) of
		?FIRST_CHARGE_GIFT_CAN_RECEIVE->
			case package_op:get_empty_slot_in_package() of
				0->
					Message = role_packet:encode_add_item_failed_s2c(?ERROR_PACKEGE_FULL),
					role_op:send_data_to_gate(Message);
				_->	
					State = ?FIRST_CHARGE_GIFT_RECEIVED,
					put(first_charge_gift_state,State),
					write_record(get(roleid),State),
					MsgBin = active_borad_packet:encode_first_charge_gift_state_s2c(State),
					role_op:send_data_to_gate(MsgBin),
					ItemId = env:get(first_charge_gift_itemid,?FIRST_CHARGE_GIFT_ITEM),
					role_op:auto_create_and_put(ItemId,1,first_charge_gift),
					SysBrdRole = system_chat_util:make_role_param(get(creature_info)),
					SysBrdItem = system_chat_util:make_item_param(ItemId),
					MsgInfo = [SysBrdRole,SysBrdItem],
					system_chat_op:system_broadcast(?SYSTEM_CHAT_FIRST_CHARGE,MsgInfo),
					gm_logger_role:role_first_charge_gift(get(roleid),has_get_reward,get(level))
			end;
		_->
			OptCode = ?GET_FIRST_CHARGE_GIFT_ERROR,
			MsgBin = active_borad_packet:encode_first_charge_gift_reward_opt_s2c(OptCode),
			role_op:send_data_to_gate(MsgBin)
	end;

process_message(_)->
	nothing.

reinit(State)->
	put(first_charge_gift_state,State),
	MsgBin = active_borad_packet:encode_first_charge_gift_state_s2c(State),
	role_op:send_data_to_gate(MsgBin).

write_record(RoleId)->
	State = ?FIRST_CHARGE_GIFT_CAN_RECEIVE,
	Info = #role_first_charge_gift{roleid = RoleId,state = State},
	dal:write_rpc(Info),
	case role_pos_util:where_is_role(RoleId) of
		[]->
			nothing;
		RolePos->
			Node = role_pos_db:get_role_mapnode(RolePos),
			Proc = role_pos_db:get_role_pid(RolePos),
			try
				gen_fsm:sync_send_all_state_event({Proc,Node}, {first_charge_gift,State},1000)
			catch
				E:R -> slogger:msg("~p ~p write_record E ~p Reason:~p ~n",[Proc,?MODULE,E,R]),error
			end
	end.
			
export_for_copy()->
	get(first_charge_gift_state).

load_by_copy(Info)->
	put(first_charge_gift_state,Info).

%%
%% Local Functions
%%
load_form_db(RoleId)->
	continuous_logging_db:load_first_charge_form_db(RoleId).


write_record(RoleId,State)->
	continuous_logging_db:write_first_charge_form_db(RoleId,State).
%%
%%
%%
get_state(RoleId)->
	case load_form_db(RoleId) of
		[]->
			?FIRST_CHARGE_GIFT_CAN_NOT_RECEIVE;
			%%?FIRST_CHARGE_GIFT_CAN_RECEIVE;					%%for debug
		Info->
			element(#role_first_charge_gift.state,Info)
	end.	
