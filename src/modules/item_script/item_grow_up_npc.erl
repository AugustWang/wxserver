%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-12-1
%% Description: TODO: Add description to item_grow_up_npc
-module(item_grow_up_npc).

%%
%% Include files
%%
-export([use_item/2,handle_use_item/2]).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("error_msg.hrl").
-include("item_define.hrl").
-define(ITEM_TYPE_CHRISTMAS_SOCK,14090302).
%%
%% Exported Functions
%%
%%
%% API Functions
%%
use_item(ItemInfo,NpcId)->
	Class = get_class_from_iteminfo(ItemInfo),
	case Class =:= ?ITEM_TYPE_CHRISTMAS_BALL of
		true->
			case creature_op:get_creature_info(NpcId) of
				[]->
					Msg = role_packet:encode_use_item_error_s2c(?ERROR_UNKNOWN),
					role_op:send_data_to_gate(Msg),
					false;
				NpcInfo->
					case package_op:can_added_to_package_template_list([{?ITEM_TYPE_CHRISTMAS_SOCK,1}]) of
						false->
							Message = role_packet:encode_add_item_failed_s2c(?ERROR_PACKEGE_FULL),
							role_op:send_data_to_gate(Message),
							false;
						_->
							try
								NpcPid = npc_op:get_pid_from_npcinfo(NpcInfo),
								NpcPid ! {christmas_activity,{up_christmas_tree,get(roleid),1}},
								role_op:auto_create_and_put(?ITEM_TYPE_CHRISTMAS_SOCK, 1, christmas_tree_grow),
								true
							catch
								E:R->
									false
							end
					end
			end;
		_->
			Msg = role_packet:encode_use_item_error_s2c(?ERROR_MISS_ITEM),
			role_op:send_data_to_gate(Msg),
			false
	end.

handle_use_item(NpcId,Slot)->
	role_op:handle_use_item(Slot,[NpcId]).





