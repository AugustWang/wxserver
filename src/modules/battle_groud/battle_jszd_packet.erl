%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-11-18
%% Description: TODO: Add description to battle_jszd_packet
-module(battle_jszd_packet).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([handle/2,process_jszd_battle/1]).
-export([encode_jszd_start_notice_s2c/1,
		 encode_jszd_join_s2c/2,
		 encode_jszd_leave_s2c/0,
		 encode_jszd_update_s2c/4,
		 encode_jszd_end_s2c/4,
		 encode_jszd_error_s2c/1,
		 encode_jszd_stop_s2c/0
		 ]).
-include("login_pb.hrl"). 
-include("common_define.hrl").
%%
%% API Functions
%%
handle(Message=#jszd_join_c2s{},RolePid)->
	RolePid!{jszd_battle,Message};
handle(Message=#jszd_leave_c2s{},RolePid)->
	RolePid!{jszd_battle,Message};
handle(Message=#jszd_reward_c2s{},RolePid)->
	RolePid!{jszd_battle,Message};
handle(_Message,_RolePid)->
	nothing.

process_jszd_battle(#jszd_join_c2s{})->
	battle_ground_op:handle_join(?JSZD_BATTLE);
process_jszd_battle(#jszd_leave_c2s{})->
	battle_ground_op:handle_battle_leave();
process_jszd_battle(#jszd_reward_c2s{})->
	battle_ground_op:handle_battle_reward().
%%
%% Local Functions
%%
encode_jszd_start_notice_s2c(LeftTime)->
	login_pb:encode_jszd_start_notice_s2c(#jszd_start_notice_s2c{lefttime=LeftTime}).
encode_jszd_join_s2c(LeftTime,Guilds)->
	login_pb:encode_jszd_join_s2c(#jszd_join_s2c{lefttime=LeftTime,guilds=Guilds}).
encode_jszd_leave_s2c()->
	login_pb:encode_jszd_leave_s2c(#jszd_leave_s2c{}).
encode_jszd_update_s2c(RoleId,Score,LeftTime,Guilds)->
	login_pb:encode_jszd_update_s2c(#jszd_update_s2c{roleid=RoleId,score=Score,lefttime=LeftTime,guilds=Guilds}).
encode_jszd_end_s2c(MyRank,Guilds,Honor,Exp)->
	login_pb:encode_jszd_end_s2c(#jszd_end_s2c{myrank=MyRank,guilds=Guilds,honor = Honor,exp = Exp}).
encode_jszd_stop_s2c()->
	login_pb:encode_jszd_stop_s2c(#jszd_stop_s2c{}).
encode_jszd_error_s2c(Reason)->
	login_pb:encode_jszd_error_s2c(#jszd_error_s2c{reason=Reason}).
