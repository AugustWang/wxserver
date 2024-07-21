%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-1-7
%% Description: TODO: Add description to vip_packet
-module(vip_packet).

%%
%% Include files
%%
-export([handle/2,send_data_to_gate/1]).
-export([encode_vip_ui_s2c/3,encode_vip_level_up_s2c/0,encode_vip_init_s2c/3,encode_vip_error_s2c/1,
		 encode_vip_npc_enum_s2c/2,encode_vip_role_use_flyshoes_s2c/2,process_msg/1]).
-include("login_pb.hrl").
-include("data_struct.hrl").
%%
%% Exported Functions
%%


%%
%% API Functions
%%
handle(#vip_ui_c2s{},RolePid)->
	role_processor:vip_ui_c2s(RolePid);
handle(#vip_reward_c2s{},RolePid)->
	role_processor:vip_reward_c2s(RolePid);
handle(#login_bonus_reward_c2s{},RolePid)->
	role_processor:login_bonus_reward_c2s(RolePid);
handle(Message,RolePid)->
	RolePid ! {vip,Message}.

process_msg(#join_vip_map_c2s{transid = TransId})->
	vip_op:join_vip_map(TransId);

process_msg(_)->
	ignor.

encode_vip_ui_s2c(VipLevel,Gold,EndTime)->
	login_pb:encode_vip_ui_s2c(#vip_ui_s2c{vip=VipLevel,gold=Gold,endtime=EndTime}).
encode_vip_level_up_s2c()->
	login_pb:encode_vip_level_up_s2c(#vip_level_up_s2c{}).
encode_vip_init_s2c(VipLevel,Type,Type2)->
	login_pb:encode_vip_init_s2c(#vip_init_s2c{vip=VipLevel,type=Type,type2=Type2}).
encode_vip_npc_enum_s2c(VipLevel,Bonus)->
	login_pb:encode_vip_npc_enum_s2c(#vip_npc_enum_s2c{vip=VipLevel,bonus=Bonus}).
encode_vip_error_s2c(Reason)->
	login_pb:encode_vip_error_s2c(#vip_error_s2c{reason=Reason}).

encode_vip_role_use_flyshoes_s2c(LeftNum,TotleNum)->
	login_pb:encode_vip_role_use_flyshoes_s2c(#vip_role_use_flyshoes_s2c{leftnum=LeftNum,totlenum=TotleNum}).

%%
%% Local Functions
%%
send_data_to_gate(Message) ->
	role_op:send_data_to_gate(Message).
