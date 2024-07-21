%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-3-1
%% Description: TODO: Add description to exchange_op
-module(exchange_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([enum_exchange_item/2,exchange_item/5]).
-include("map_info_struct.hrl").
%%
%% API Functions
%%
enum_exchange_item(RoleInfo, NpcID) ->
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	npc_function_frame:do_enum(Mapid,RoleInfo,NpcID,exchange).

exchange_item(RoleInfo, ItemClsid, Count, NpcID, Slots)->
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	npc_function_frame:do_action(Mapid,RoleInfo,NpcID,exchange,[exchange, ItemClsid, Count, Slots]).
%%
%% Local Functions
%%

