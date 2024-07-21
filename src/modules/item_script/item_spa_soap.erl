%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-10-12
%% Description: TODO: Add description to item_spa_soap
-module(item_spa_soap).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([use_item/2,handle_spa_soap/2]).
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
use_item(ItemInfo,RoleId)->
	States = get_states_from_iteminfo(ItemInfo),
	Class = get_class_from_iteminfo(ItemInfo),
	if
		Class =:= ?ITEM_TYPE_SPA_SOAP->
			case lists:keyfind(spa_exp_add, 1, States) of
				{_,_Value}->
					spa_op:spa_chopping_c2s(RoleId);
				_->
					false
			end;
		true->
			false
	end,
	false.

handle_spa_soap(RoleId,Slot)->
	role_op:handle_use_item(Slot,[RoleId]).
%%
%% Local Functions
%%

