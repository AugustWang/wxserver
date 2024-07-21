%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-8-25
%% Description: TODO: Add description to item_feed_pet
-module(item_feed_pet).

-export([use_item/2]).
-export([handle_use_item/2]).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("error_msg.hrl").
-include("item_define.hrl").
		
use_item(ItemInfo,PetId)->
	[{pet_happiness,Happiness}] = get_states_from_iteminfo(ItemInfo),
	Class = get_class_from_iteminfo(ItemInfo),
	if
		Class =:= ?ITEM_TYPE_FEED_PET->
			case pet_op:add_pet_happiness(PetId,Happiness) of
				true->
					true;
				full->
					MessageBin = pet_packet:encode_pet_opt_error_s2c(?ERROR_PET_TOO_FULL),
					role_op:send_data_to_gate(MessageBin),
					false;
				_->
					MessageBin = pet_packet:encode_pet_opt_error_s2c(?ERROR_NO_PET_IN_BATTLE),
					role_op:send_data_to_gate(MessageBin),
					false
			end;
		true->
			false
	end.


handle_use_item(PetId,Slot)->
	role_op:handle_use_item(Slot,[PetId]).	