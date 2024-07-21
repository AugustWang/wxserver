%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(item_role_rename).
-export([use_item/2,handle_role_rename/2]).
-include("item_define.hrl").
-include("item_struct.hrl").
-include("error_msg.hrl").

use_item(ItemInfo,NewName)->
	case get_class_from_iteminfo(ItemInfo) of
		?ITEM_TYPE_ROLE_RENAME->
			case rename_op:proc_role_change_name(NewName) of
				true->
					true;
				_->
					false
			end;
		_->
			false
	end.

handle_role_rename(Slot,NewName)->
	role_op:handle_use_item(Slot,[NewName]).

