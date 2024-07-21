%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-12-27
%% Description: TODO: Add description to loop_tower_packet
-module(loop_tower_packet).

%%
%% Include files
%%
-export([handle/2,send_data_to_gate/1]).
-export([encode_loop_tower_masters_s2c/1,encode_loop_tower_enter_failed_s2c/1,encode_loop_tower_enter_s2c/2,
		 encode_loop_tower_challenge_success_s2c/2,encode_loop_tower_enter_higher_s2c/1]).
-include("login_pb.hrl").
-include("data_struct.hrl").
%%
%% Exported Functions
%%

%%
%% API Functions
%%
handle(#loop_tower_enter_c2s{layer=Layer,enter=Enter,convey=Convey},RolePid)->
	role_processor:loop_tower_enter_c2s(RolePid,Layer,Enter,Convey);
handle(#loop_tower_masters_c2s{master=Master},RolePid)->
	role_processor:loop_tower_masters_c2s(RolePid,Master);
handle(#loop_tower_challenge_c2s{type=Type},RolePid)->
	role_processor:loop_tower_challenge_c2s(RolePid,Type);
handle(#loop_tower_reward_c2s{bonus=Bonus},RolePid)->
	role_processor:loop_tower_reward_c2s(RolePid,Bonus);
handle(#loop_tower_challenge_again_c2s{type=Type,again=Again},RolePid)->
	role_processor:loop_tower_challenge_again_c2s(RolePid,Type,Again);
handle(_Message,_RolePid)->
	ok.

encode_loop_tower_masters_s2c(LoopTowerMasters)->
	login_pb:encode_loop_tower_masters_s2c(#loop_tower_masters_s2c{ltms=LoopTowerMasters}).
encode_loop_tower_enter_failed_s2c(Reason)->
	login_pb:encode_loop_tower_enter_failed_s2c(#loop_tower_enter_failed_s2c{reason=Reason}).
encode_loop_tower_enter_s2c(Layer,Trans)->
	login_pb:encode_loop_tower_enter_s2c(#loop_tower_enter_s2c{layer=Layer,trans=Trans}).
encode_loop_tower_challenge_success_s2c(Layer,Bonus)->
	login_pb:encode_loop_tower_challenge_success_s2c(#loop_tower_challenge_success_s2c{layer=Layer,bonus=Bonus}).
encode_loop_tower_enter_higher_s2c(Higher)->
	login_pb:encode_loop_tower_enter_higher_s2c(#loop_tower_enter_higher_s2c{higher=Higher}).

send_data_to_gate(Message) ->
	role_op:send_data_to_gate(Message).


%%
%% Local Functions
%%

