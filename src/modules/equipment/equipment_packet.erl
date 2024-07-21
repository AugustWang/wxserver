%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-11-25
%% Description: TODO: Add description to equipment_packet
-module(equipment_packet).

%%
%% Include files
%%
-export([handle/2,process_equipment/1,send_data_to_gate/1]).
-export([encode_equipment_riseup_s2c/2,encode_equipment_riseup_failed_s2c/1,
		 encode_equipment_sock_s2c/2,encode_equipment_sock_failed_s2c/1,
		 encode_equipment_inlay_s2c/0,encode_equipment_inlay_failed_s2c/1,
		 encode_equipment_stone_remove_s2c/0,encode_equipment_stone_remove_failed_s2c/1,
		 encode_equipment_stonemix_s2c/1,encode_equipment_stonemix_failed_s2c/1,
		 encode_equipment_upgrade_s2c/0,encode_equipment_enchant_s2c/1,encode_equipment_recast_s2c/1,
		 encode_equipment_convert_s2c/1,encode_equipment_move_s2c/0,encode_equipment_remove_seal_s2c/0,
		 encode_equip_fenjie_optresult_s2c/1
		 ]).

-export([encode_equipment_stonemix_bat_result_s2c/4]).


-include("login_pb.hrl").
-include("data_struct.hrl").

%%
%% Exported Functions
%%
handle(Message,RolePid) ->
	RolePid ! {equipment,Message}.

process_equipment(#equipment_riseup_c2s{equipment=Equipment,riseup=Riseup,protect=Protect,lucky = LuckySolts})->
	equipment_op:equipment_riseup(Equipment,Riseup,Protect,LuckySolts);
process_equipment(#equipment_sock_c2s{equipment=Equipment,sock=Sock})->
	equipment_punch:equipment_punch(Equipment,Sock);
process_equipment(#equipment_inlay_c2s{equipment=Equipment,inlay=Inlay,socknum=SockNum})->
	equipment_op:equipment_inlay(Equipment,Inlay,SockNum);
process_equipment(#equipment_stone_remove_c2s{equipment=Equipment,remove=Remove,socknum=SockNum})->
	equipment_op:equipment_stone_remove(Equipment,Remove,SockNum);
process_equipment(#equipment_stonemix_single_c2s{stonelist=StoneSlotList})->
	equipment_op:equipment_stonemix(StoneSlotList);

%%鎵归噺鍚堟垚鍔熻兘,鍓嶇鍙玡quipment_stonemix_c2s
process_equipment(#equipment_stonemix_c2s{stoneSlot=StoneSlot,numRequire=NumRequire,numMix=NumMix})->
	equipment_op:equipment_stonemix_batch(StoneSlot,NumRequire,NumMix);


process_equipment(#equipment_upgrade_c2s{equipment=Equipment})->
	equipment_upgrade:equipment_upgrade(Equipment);
process_equipment(#equipment_enchant_c2s{equipment=Equipment,enchant=Enchant})->
	equipment_op:equipment_enchant(Equipment,Enchant);
process_equipment(#equipment_recast_c2s{equipment=Equipment,recast=Recast,type=Type,lock_arr=LockArr})->
	equipment_op:equipment_recast(Equipment,Recast,Type,LockArr);
process_equipment(#equipment_recast_confirm_c2s{equipment=Equipment})->
	equipment_op:equipment_recast_confirm(Equipment);
process_equipment(#equipment_convert_c2s{equipment=Equipment,convert=Convert,type=Type})->
	equipment_op:equipment_convert(Equipment,Convert,Type);
process_equipment(#equipment_move_c2s{fromslot=Fromslot, toslot=Toslot})->
	equipment_move:equipment_move(Fromslot,Toslot);
process_equipment(#equipment_remove_seal_c2s{equipment=Equipment})-> 
	equipment_remove_seal:equipment_remove_seal(Equipment);
process_equipment(#equipment_fenjie_c2s{equipment=Equipment})-> 
	equipment_fenjie:equipment_fenjie(Equipment);
process_equipment(_)->
	ignoe.
%%
%% API Functions
%%

 

%%
%% Local Functions
%%
encode_equipment_riseup_s2c(Result,Estar)->
	login_pb:encode_equipment_riseup_s2c(#equipment_riseup_s2c{result=Result,star=Estar}).
encode_equipment_riseup_failed_s2c(Reason)->
	login_pb:encode_equipment_riseup_failed_s2c(#equipment_riseup_failed_s2c{reason=Reason}).
encode_equipment_sock_s2c(Result,Esock)->
	login_pb:encode_equipment_sock_s2c(#equipment_sock_s2c{result=Result,sock=Esock}).
encode_equipment_sock_failed_s2c(Reason)->
	login_pb:encode_equipment_sock_failed_s2c(#equipment_sock_failed_s2c{reason=Reason}).
encode_equipment_inlay_s2c()->
	login_pb:encode_equipment_inlay_s2c(#equipment_inlay_s2c{}).
encode_equipment_inlay_failed_s2c(Reason)->
	login_pb:encode_equipment_inlay_failed_s2c(#equipment_inlay_failed_s2c{reason=Reason}).
encode_equipment_stone_remove_s2c()->
	login_pb:encode_equipment_stone_remove_s2c(#equipment_stone_remove_s2c{}).
encode_equipment_stone_remove_failed_s2c(Reason)->
	login_pb:encode_equipment_stone_remove_failed_s2c(#equipment_stone_remove_failed_s2c{reason=Reason}).
encode_equipment_stonemix_s2c(NewStone)->
	login_pb:encode_equipment_stonemix_s2c(#equipment_stonemix_s2c{newstone=NewStone}).


encode_equipment_stonemix_failed_s2c(Reason)->
	login_pb:encode_equipment_stonemix_failed_s2c(#equipment_stonemix_failed_s2c{reason=Reason}).

%% 鎵归噺鍚堟垚 by zhangting
encode_equipment_stonemix_bat_result_s2c(Succ_times1,Fau_times1,Used_stones1,Moneys1)->
	login_pb:encode_equipment_stonemix_bat_result_s2c(#equipment_stonemix_bat_result_s2c
              {succ_times=Succ_times1
              ,fau_times=Fau_times1
              ,used_stones=Used_stones1
              ,moneys=Moneys1}).


encode_equipment_upgrade_s2c()->
	login_pb:encode_equipment_upgrade_s2c(#equipment_upgrade_s2c{}).

encode_equipment_enchant_s2c(Enchants)->
	login_pb:encode_equipment_enchant_s2c(#equipment_enchant_s2c{enchants=Enchants}).

encode_equipment_recast_s2c(Enchants)->
	login_pb:encode_equipment_recast_s2c(#equipment_recast_s2c{enchants=Enchants}).
encode_equipment_convert_s2c(Enchants)->
	login_pb:encode_equipment_convert_s2c(#equipment_convert_s2c{enchants=Enchants}).
encode_equipment_move_s2c()->
	login_pb:encode_equipment_move_s2c(#equipment_move_s2c{}).
encode_equipment_remove_seal_s2c()->
	login_pb:encode_equipment_remove_seal_s2c(#equipment_remove_seal_s2c{}).
encode_equip_fenjie_optresult_s2c(Result)->
	login_pb:encode_equip_fenjie_optresult_s2c(#equip_fenjie_optresult_s2c{result=Result}).

send_data_to_gate(Message) ->
	role_op:send_data_to_gate(Message).
