%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaowu
%% Created: 2013-5-2
%% Description: TODO: Add description to astrology_packet
-module(astrology_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-export([handle/2]).
-compile(export_all).
%%
%% API Functions
%%
handle(Message=#astrology_init_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_action_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_pickup_all_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_sale_all_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_add_money_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_sale_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_pickup_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_item_pos_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_mix_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_mix_all_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_lock_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_expand_package_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_active_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_swap_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_unlock_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message};

handle(Message=#astrology_open_panel_c2s{}, RolePid)->
	RolePid!{astrology_packet,Message}.

encode_tss(Slot,Tid)->
	#tss{slot=Slot, tid=Tid}.
		  
encode_astrology_init_s2c(Objs)->
	#astrology_init_s2c {objs=Objs}.

encode_astrology_action_s2c(Obj)->
	#astrology_action_s2c{obj=Obj}.

encode_astrology_pickup_all_s2c(Slots)->
	#astrology_pickup_all_s2c{slots=Slots}.
	
encode_astrology_sale_all_s2c(Slots)->	
	#astrology_sale_all_s2c{slots=Slots}.

encode_astrology_update_value_s2c(Value)->
	#astrology_update_value_s2c{value=Value}.

encode_astrology_money_and_pos_s2c(Money,Pos)->
	#astrology_money_and_pos_s2c{money=Money, pos=Pos}.

encode_astrology_error_s2c(Reason)->
	#astrology_error_s2c{reason=Reason}.

encode_astrology_sale_s2c(Slot)->
	#astrology_sale_s2c{slot=Slot}.

encode_astrology_pickup_s2c(Slot)->
	#astrology_pickup_s2c{slot=Slot}.

encode_astrology_add_s2c(Objs)->
	#astrology_add_s2c{objs=Objs}.

encode_ss(Slot, Level, Status, Id, Exp, Quality)->
	#ss{slot=Slot, level=Level, status=Status, id=Id, exp=Exp, quality=Quality}.

encode_astrology_package_size_s2c(Bodynum,Packnum)->
	#astrology_package_size_s2c{bodynum=Bodynum, packnum=Packnum}.

encode_astrology_update_s2c(Obj)->
	#astrology_update_s2c{obj=Obj}.

encode_astrology_delete_s2c(Slots)->
	#astrology_delete_s2c{slots=Slots}.

%%
%% Local Functions
%%

