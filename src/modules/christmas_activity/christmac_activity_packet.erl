%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-29
%% Description: TODO: Add description to christmac_activity_packet
-module(christmac_activity_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
handle(Message,RolePid)->
	RolePid ! {christmas_activity,Message}.

process_message(#christmas_tree_grow_up_c2s{npcid=NpcId,slot=Slot})->
	item_grow_up_npc:handle_use_item(NpcId,Slot);

process_message(#christmas_activity_reward_c2s{type=Type})->
	role_christmas_activity:get_reward(Type).

encode_christmas_tree_hp_s2c(CurHp,MaxHp)->
	login_pb:encode_christmas_tree_hp_s2c(#christmas_tree_hp_s2c{curhp=CurHp,maxhp=MaxHp}).