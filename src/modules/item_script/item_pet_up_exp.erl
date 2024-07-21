%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-2-24
%% Description: TODO: Add description to item_pet_up_exp
-module(item_pet_up_exp).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([use_item/1,use_item/2,handle_pet_exp/2]).
-include("item_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("pet_struct.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("item_define.hrl").
%%
%% API Functions
%%
use_item(ItemInfo,PetId)->
	Moneys = get_states_from_iteminfo(ItemInfo),
	Class = get_class_from_iteminfo(ItemInfo),
	if
		Class =:= ?ITEM_TYPE_PET_UP_EXP->
			case lists:keyfind(pet_exp_add, 1, Moneys) of
				{_,Value}->
					GmPetsInfo = get(gm_pets_info),
					case lists:keyfind(PetId, 2, GmPetsInfo) of
						false->
							false;
						MyPet->
								case pet_level_op:obt_exp(MyPet,Value) of
									true->
										true;
									_->
										Msg = role_packet:encode_use_item_error_s2c(?ERROR_PET_LEVEL_BIGER_THAN_MASTER),
										role_op:send_data_to_gate(Msg),
										false
								end
					end;
				_->
					false
			end;
		true->
			false
	end.

use_item(ItemInfo)->
	States = get_states_from_iteminfo(ItemInfo),
	Class = get_class_from_iteminfo(ItemInfo),
	if
		Class =:= ?ITEM_TYPE_PET_UP_EXP->
			case lists:keyfind(pet_exp_add, 1, States) of
				{_,Value}->
					GmPetsInfo = pet_op:get_out_pet(),
					case GmPetsInfo of
						[]->
							Msg = role_packet:encode_use_item_error_s2c(?ERROR_NO_PET_IN_BATTLE),
							role_op:send_data_to_gate(Msg),
							false;
						MyPet->
								case pet_level_op:obt_exp(MyPet,Value) of
									true->
										true;
									_->
										Msg = role_packet:encode_use_item_error_s2c(?ERROR_PET_LEVEL_BIGER_THAN_MASTER),
										role_op:send_data_to_gate(Msg),
										false
								end
					end;
				_->
					false
			end;
		true->
			false
	end.

handle_pet_exp(PetId,Slot)->
	role_op:handle_use_item(Slot,[PetId]).
%%
%% Local Functions
%%

