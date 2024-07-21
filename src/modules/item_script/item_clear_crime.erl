%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-9-27
%% Description: TODO: Add description to item_clear_crime
-module(item_clear_crime).

%%
%% Include files
%%
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-export([use_item/1]).

-include("data_struct.hrl").
-include("item_struct.hrl").
%%
%% API Functions
%%
use_item(ItemInfo)->
	States = get_states_from_iteminfo(ItemInfo),
	case lists:keyfind(clear_crime, 1, States) of
		{_,Value} ->
			case pvp_op:clear_crime_by_value(Value) of
				ok ->
					true;
				_ ->
					Msg = role_packet:encode_use_item_error_s2c(?ERRNO_IS_CLEARED_ALL_CRIME),
					role_op:send_data_to_gate(Msg),
					false
			end;
		_ ->
			false
	end.