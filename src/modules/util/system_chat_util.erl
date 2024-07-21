%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-6-30
%% Description: TODO: Add description to system_chat_util
-module(system_chat_util).

%%
%% Include files
%%
-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").


%%
%% API Functions
%%
make_role_param(RoleInfo) ->
	Name = get_name_from_roleinfo(RoleInfo),
	MyName = util:safe_binary_to_list(Name),
	RoleId = get_id_from_roleinfo(RoleInfo),
	ServerId = get_serverid_from_roleinfo(RoleInfo),
	chat_packet:makeparam(role,{MyName,RoleId,ServerId}).

make_role_param(RoleInfo,Color) ->
	Name = get_name_from_roleinfo(RoleInfo),
	MyName = util:safe_binary_to_list(Name),
	RoleId = get_id_from_roleinfo(RoleInfo),
	ServerId = get_serverid_from_roleinfo(RoleInfo),
	chat_packet:makeparam(role,{MyName,RoleId,ServerId,Color}).

make_equipment_param(Slot) ->
	chat_packet:makeparam(equipment,Slot).

make_int_param(Int) ->
	chat_packet:makeparam(int,Int).

make_item_param(Item) ->
	chat_packet:makeparam(item,Item).

make_string_param(String,Color) ->
	NewString = util:safe_binary_to_list(String),
	chat_packet:makeparam(string,{NewString,Color}).

make_string_param(String) ->
	NewString = util:safe_binary_to_list(String),
	chat_packet:makeparam(string,{NewString}).


%%
%% Local Functions
%%

