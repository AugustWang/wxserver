%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(trade_role_packet).

-compile(export_all).

-include("login_pb.hrl").
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("item_define.hrl").
handle(#trade_role_apply_c2s{roleid=RoleId},RolePid)->
	role_processor:trade_role_apply_c2s(RolePid,RoleId);

handle(#trade_role_accept_c2s{roleid=RoleId},RolePid)->
	role_processor:trade_role_accept_c2s(RolePid,RoleId);

handle(#trade_role_decline_c2s{roleid=RoleId},RolePid)->
	role_processor:trade_role_decline_c2s(RolePid,RoleId);

handle(#set_trade_money_c2s{moneytype=MoneyType,moneycount = MoneyCount},RolePid)->
	role_processor:set_trade_money_c2s(RolePid,MoneyType,MoneyCount);

handle(#set_trade_item_c2s{trade_slot=Trade_slot,package_slot = Package_slot},RolePid)->
	role_processor:set_trade_item_c2s(RolePid,Trade_slot,Package_slot);

handle(#cancel_trade_c2s{},RolePid)->
	role_processor:cancel_trade_c2s(RolePid);

handle(#trade_role_lock_c2s{},RolePid)->
	role_processor:trade_role_lock_c2s(RolePid);

handle(#trade_role_dealit_c2s{},RolePid)->
	role_processor:trade_role_dealit_c2s(RolePid);

handle(_Msg,RolePid)->
	nothing.

encode_trade_role_errno_s2c(Errno)->
	login_pb:encode_trade_role_errno_s2c(#trade_role_errno_s2c{errno = Errno}).

encode_trade_begin_s2c(RoleId)->
	login_pb:encode_trade_begin_s2c(#trade_begin_s2c{roleid = RoleId}).

encode_trade_role_lock_s2c(RoleId)->
	login_pb:encode_trade_role_lock_s2c(#trade_role_lock_s2c{roleid = RoleId}).

encode_trade_role_dealit_s2c(RoleId)->
	login_pb:encode_trade_role_dealit_s2c(#trade_role_dealit_s2c{roleid = RoleId}).

encode_trade_role_apply_s2c(RoleId)->
	login_pb:encode_trade_role_apply_s2c(#trade_role_apply_s2c{roleid = RoleId}).

encode_trade_role_decline_s2c(RoleId)->
	login_pb:encode_trade_role_decline_s2c(#trade_role_decline_s2c{roleid = RoleId}).

encode_update_trade_status_s2c(RoleId,{Silver,Gold,Ticket},Slot_Infos)->
	login_pb:encode_update_trade_status_s2c(#update_trade_status_s2c{roleid = RoleId,silver = Silver,gold = Gold,ticket = Ticket,slot_infos = Slot_Infos}).

encode_cancel_trade_s2c()->
	login_pb:encode_cancel_trade_s2c(#cancel_trade_s2c{}).

encode_trade_success_s2c()->
	login_pb:encode_trade_success_s2c(#trade_success_s2c{}).

to_slot_info(Trade_Slot,ItemInfo)->
	#ti{trade_slot = Trade_Slot,item_attrs = pb_util:to_item_info(ItemInfo)}.


