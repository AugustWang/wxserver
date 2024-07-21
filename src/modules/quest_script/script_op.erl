%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(script_op).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").

has_item_in_package(TemplateId,Count)->
	item_util:is_has_enough_item_in_package(TemplateId,Count).

has_item_onhands(TemplateId,Count)->
	item_util:is_has_enough_item_onhands(TemplateId, Count).
	
destory_item(TemplateId,Count)->
	role_op:consume_items(TemplateId,Count).

get_item_count_onhands(TemplateId)->
	item_util:get_items_count_onhands(TemplateId).

has_money(MoneyType,MoneyCount)->
	role_op:check_money(MoneyType,MoneyCount).	

has_been_finished(Questid)->
	quest_op:has_been_finished(Questid).
	
is_has_quest(Questid)->
	quest_op:has_quest(Questid).
	
update_msg(Message,MsgValue)->
	quest_op:update(Message,MsgValue).

get_class()->
	get_class_from_roleinfo(get(creature_info)).

get_level()->
	get_level_from_roleinfo(get(creature_info)).

learn_skill(Skillid, Skilllevel)->
	skill_op:learn_skill(Skillid, Skilllevel),
	skill_op:async_save_to_db(),
	Msg = role_packet:encode_update_skill_s2c(get(roleid),Skillid, Skilllevel),
	role_op:send_data_to_gate(Msg).

%%return {ok,_} / full
award_item(Itemid,ItemCount)->
	role_op:auto_create_and_put(Itemid,ItemCount,got_quest).

skill_is_studied(Skillid)->
	skill_op:is_studied(Skillid).