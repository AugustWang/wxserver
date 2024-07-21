%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-7-13
%% Description: TODO: Add description to active_borad_packet
-module(active_borad_packet).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).
-include("login_pb.hrl").

%%
%% API Functions
%%
handle(Message=#activity_state_init_c2s{},RolePid)->
	RolePid ! {active_board,activity_state_op,Message};

handle(Message=#activity_boss_born_init_c2s{},RolePid)->
	RolePid ! {active_board,activity_boss_state_op,Message};

handle(Message=#first_charge_gift_reward_c2s{},RolePid)->
	RolePid ! {active_board,first_charge_gift_op,Message};

handle(_,_)->
	nothing.

make_acs(Id,State)->
	#acs{id = Id,state = State}.

make_bs(BossId,State)->
	#bs{bossid = BossId,state = State}.


encode_first_charge_gift_state_s2c(State)->
	login_pb:encode_first_charge_gift_state_s2c(#first_charge_gift_state_s2c{state = State}).

encode_first_charge_gift_reward_opt_s2c(Code)->
	login_pb:encode_first_charge_gift_reward_opt_s2c(#first_charge_gift_reward_opt_s2c{code = Code}).

encode_activity_state_init_s2c(StateInfo)->
	login_pb:encode_activity_state_init_s2c(#activity_state_init_s2c{aslist = StateInfo}).

encode_activity_boss_born_init_s2c(BsInfo)->
	login_pb:encode_activity_boss_born_init_s2c(#activity_boss_born_init_s2c{bslist = BsInfo}).

%%
%% Local Functions
%%

