%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaowu
%% Created: 2013-5-2
%% Description: TODO: Add description to astrology_handle
-module(astrology_handle).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-export([]).
-compile(export_all).
%%
%% API Functions
%%



%%
%% Local Functions
%%

handle(#astrology_init_c2s {})->
	RoleId = get(roleid),
	astrology_op:astrology_init(RoleId);

handle(#astrology_action_c2s{position=Position})->
	RoleId = get(roleid),
	astrology_op:astrology_action(RoleId,Position);

handle(#astrology_pickup_all_c2s{position=Position})->
	RoleId = get(roleid),
	astrology_op:astrology_pickup_all(RoleId,Position);

handle(#astrology_sale_all_c2s{})->
	RoleId = get(roleid),
	astrology_op:astrology_sale_all(RoleId);

handle(#astrology_add_money_c2s{})->
	RoleId = get(roleid),
	astrology_op:astrology_add_money(RoleId);

handle(#astrology_sale_c2s{slot=Slot})->
	RoleId = get(roleid),
	astrology_op:astrology_sale(RoleId,Slot);

handle(#astrology_pickup_c2s{slot=Slot})->
	RoleId = get(roleid),
	astrology_op:astrology_pickup(RoleId,Slot);

handle(#astrology_item_pos_c2s{})->
	RoleId = get(roleid),
	astrology_op:astrology_item_pos(RoleId);

handle(#astrology_mix_c2s{to_slot=To_slot, from_slot=From_slot})->
	RoleId = get(roleid),
	astrology_op:astrology_mix(RoleId,To_slot,From_slot);

handle(#astrology_lock_c2s{slot=Slot})->
	RoleId = get(roleid),
	astrology_op:astrology_lock(RoleId,Slot);

handle(#astrology_expand_package_c2s{})->
	RoleId = get(roleid),
	astrology_op:astrology_expand_package(RoleId);

handle(#astrology_active_c2s{slot=Slot})->
	RoleId = get(roleid),
	astrology_op:astrology_active(RoleId,Slot);

handle(#astrology_swap_c2s{desslot=Desslot, srcslot=Srcslot})->
	RoleId = get(roleid),
	astrology_op:astrology_swap(RoleId,Desslot,Srcslot);

handle(#astrology_unlock_c2s{slot=Slot})->
	RoleId = get(roleid),
	astrology_op:astrology_unlock(RoleId,Slot);

handle(#astrology_open_panel_c2s{})->
	RoleId = get(roleid),
	astrology_op:get_astrology_value_by_time(RoleId);

handle(#astrology_mix_all_c2s{to_slot=To_slot, from_slot=From_slot})->
	RoleId = get(roleid),
	astrology_op:astrology_mix_all(RoleId,To_slot,From_slot).


