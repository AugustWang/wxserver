%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaowu
%% Created: 2013-4-17
%% Description: TODO: Add description to furnace_handle
-module(furnace_handle).

%%
%% Include files
%%
-include("login_pb.hrl").

%%
%% Exported Functions
%%
-compile(export_all).
-export([]).

%%
%% API Functions
%%



%%
%% Local Functions
%%


handle(#get_furnace_queue_info_c2s{})->
	RoleId = get(roleid),
	furnace_op:furnace_queue_info(RoleId);

handle(#create_pill_c2s {pillid=Pillid, times=Times})->
	RoleId = get(roleid),
	furnace_op:create_pill(RoleId,Pillid,Times);

handle(#get_furnace_queue_item_c2s {queueid=Queueid})->
	RoleId = get(roleid),
	furnace_op:get_furnace_queue_item(RoleId,Queueid);

handle(#accelerate_furnace_queue_c2s {queueid=Queueid})->
	RoleId = get(roleid),
	furnace_op:accelerate_furnace_queue(RoleId,Queueid);

handle(#quit_furnace_queue_c2s {queueid=Queueid})->
	RoleId = get(roleid),
	furnace_op:quit_furnace_queue(RoleId,Queueid);

handle(#unlock_furnace_queue_c2s {unlock_type=Unlock_type, queueid=Queueid})->
	RoleId = get(roleid),
	furnace_op:unlock_furnace_queue(RoleId,Unlock_type,Queueid);

handle(#up_furnace_c2s {auto_buy=Auto_buy})->
	RoleId = get(roleid),
	furnace_op:up_furnace(RoleId,Auto_buy).
