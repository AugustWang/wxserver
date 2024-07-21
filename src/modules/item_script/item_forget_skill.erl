%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(item_forget_skill).
-export([use_item/3,handle_pet_forget_skill_c2s/3]).
-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").

use_item(ItemInfo,PetId,SkillId)->
	todo.
%%	case get_class_from_iteminfo(ItemInfo) of
%%		?ITEM_TYPE_PET_FORGET->
%%			case npc_skill_study:do_pet_forget_skill(PetId, SkillId) of
%%				true->
%%					true;
%%				_->
%%					false
%%			end;
%%		_->
%%			false
%%	end.

handle_pet_forget_skill_c2s(PetId,SkillId,Slot)->
	role_op:handle_use_item(Slot,[PetId,SkillId]).