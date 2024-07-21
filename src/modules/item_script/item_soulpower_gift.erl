%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-2-22
%% Description: TODO: Add description to item_soulpower_gift
-module(item_soulpower_gift).

%%
%% Exported Functions
%%
-export([use_item/1]).

%%
%% Include files
%%
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").



%%
%% API Functions
%%
use_item(ItemInfo)->
	[{value,SoulPowerValue }] = get_states_from_iteminfo(ItemInfo),
	MaxSpValue = role_soulpower:get_maxsoulpower(),
	CurSpValue = role_soulpower:get_cursoulpower(),
	if
		MaxSpValue > CurSpValue ->
			role_op:obtain_soulpower(SoulPowerValue),
			true;
		true->
			%%ERROR_SOULPOWER_FULL 
			Msg = role_packet:encode_use_item_error_s2c(?ERROR_SOULPOWER_FULL),
			role_op:send_data_to_gate(Msg),
			false
	end.


%%
%% Local Functions
%%

