%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-28
%% Description: TODO: Add description to role_christmas_activity
-module(role_christmas_activity).

%%
%% Include files
%%
-define(ITEM_CHRISTMAS_SOCK,14090302).
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
get_reward(Type)->
	RewardInfo = christmas_activity_db:get_christmas_activity_reward_info(Type),
	{ItemClass,Count} = christmas_activity_db:get_christmas_activity_consume(RewardInfo),
	{Reward,Num} = christmas_activity_db:get_christmas_activity_reward(RewardInfo),
	HasItem = item_util:is_has_enough_item_in_package_by_class(ItemClass,Count),
	if
		HasItem ->
			case package_op:can_added_to_package_template_list([{Reward,Num}]) of
				false->
					Message = role_packet:encode_add_item_failed_s2c(?ERROR_PACKEGE_FULL),
					role_op:send_data_to_gate(Message);
				_->
					role_op:consume_items_by_classid(ItemClass,Count),
					role_op:auto_create_and_put(Reward,Num,christmas_activity)
			end;
		true->
			Msg = role_packet:encode_use_item_error_s2c(?ERROR_MISS_ITEM),
			role_op:send_data_to_gate(Msg)
	end.
						
