%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Wang.SQ
%% Created: 2011-5-5
%% Description: TODO: Add description to item_contribute_gift
-module(item_contribute_gift).

-export([use_item/1]).
%%
%% Include files
%%
-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("error_msg.hrl").

%%
%% API Functions
%%
use_item(ItemInfo)->
	Contributes = get_states_from_iteminfo(ItemInfo),
	case guild_util:is_have_guild() of
		false ->
			AllCheck = ?GUILD_ERRNO_NOT_IN_GUILD,
			Msg = guild_packet:encode_guild_opt_result_s2c(AllCheck),
			role_op:send_data_to_gate(Msg),
			false;
		_ ->
			[{_,Contribute}] = Contributes,
			case guild_op:contribute(Contribute) of
				true ->
%% 					achieve_op:achieve_update({contribute_guild},[?TYPE_GUILD_CONTRIBUTION],Contribute),
					true;
				_ ->
					false
			end
	end.

