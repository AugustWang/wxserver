%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-8-23
%% Description: TODO: Add description to item_skill_book
-module(item_skill_book).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([use_item/2,handle_learn_skill_with_book/2]).
-include("item_struct.hrl").
-include("item_define.hrl").
-include("pet_define.hrl").
%%
%% API Functions
%%
use_item(ItemInfo,{PetId})->
	SkillBookInfo = get_states_from_iteminfo(ItemInfo),
	Class = get_class_from_iteminfo(ItemInfo),
%%	io:format("SkillBookInfo:~p Class:~p ~n",[SkillBookInfo,Class]),
	if
		Class =:= ?ITEM_TYPE_SKILL_BOOK->
			case lists:keyfind(skill_book, 1, SkillBookInfo) of
				{_,SkillId,SkillLevel}->
							npc_skill_study:do_pet_learn_without_npc(PetId, SkillId, SkillLevel);	
				true->
							false
					end;
		true->
			false
	end.
%%
%% Local Functions
%%
handle_learn_skill_with_book(PetId,Slot)->
	role_op:handle_use_item(Slot,[{PetId}]).
