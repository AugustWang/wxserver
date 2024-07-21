%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(item_avatar).

%%
%% Include files
%%
-include("error_msg.hrl").
-include("skill_define.hrl").
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
	AddBuffs = get_states_from_iteminfo(ItemInfo),
	IsInAvatar = role_op:is_in_avatar(),
	ItemAvatarBuffers =  buffer_op:get_buffers_by_class(?BUFF_CLASS_ITEM_AVATAR),
	case ( IsInAvatar and (ItemAvatarBuffers=/=[]) ) or (not IsInAvatar) of
		true->
			role_op:remove_buffers(ItemAvatarBuffers),
			role_op:add_buffers_by_self(AddBuffs),
			true;
		_->
			Msg = role_packet:encode_use_item_error_s2c(?ERRNO_CAN_NOT_DO_IN_AVATAR),
			role_op:send_data_to_gate(Msg),
			false
	end.
				