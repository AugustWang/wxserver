%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(role_dragon_fight).


-include("dragon_fight_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% Include files 
%%
init()->
	put(is_dragon_fighting,false).

hook_on_map_complate_online()->
	case dragon_fight_processor:hook_role_online({get(roleid)}) of
		{true,BuffInfo}->
			quest_special_msg:proc_specail_msg(quest_specialsg:dragon_fight_end()),
			put(is_dragon_fighting,false),
			role_op:remove_buffer(BuffInfo);
		fighting->
			put(is_dragon_fighting,true);
		_->	
			put(is_dragon_fighting,false)
	end.

is_in_dragon_fighting()->
	get(is_dragon_fighting).

export_for_copy()->
	get(is_dragon_fighting).

load_by_copy(Info)->
	put(is_dragon_fighting,Info).

handle_dragon_fight_join()->
	case transport_op:can_directly_telesport() of
		true->
			dragon_fight_processor:apply_join(get(roleid));
		_->
			nothing
	end.

dragon_fight_join_faction(BuffInfo,RemoveBuff)->
	role_op:remove_without_compute(RemoveBuff),
	role_op:add_buffers_by_self([BuffInfo]),
	pet_op:call_back(),
	role_ride_op:hook_on_dragon_fight_join_faction(),
	put(is_dragon_fighting,true).

dragon_fight_stop(BuffInfo)->
	put(is_dragon_fighting,false),
	quest_special_msg:proc_specail_msg(quest_special_msg:dragon_fight_end()),
	role_op:remove_buffer(BuffInfo).

get_reward_exp()->
	ReWardInfo = level_activity_rewards_db:get_info(get(level)),
	DefaultExp = level_activity_rewards_db:get_dragon_fight_exp(ReWardInfo),
	case dragon_fight_processor:get_user_result(get(roleid)) of
		?USER_RESULT_NOT_JOIN->
			0;
		?USER_RESULT_HALF->
			DefaultExp;
		?USER_RESULT_WIN->
			DefaultExp*2;
		?USER_RESULT_LOSE->
			DefaultExp;
		error->
			0
	end.