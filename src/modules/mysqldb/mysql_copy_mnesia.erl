%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-5-23
%% Description: TODO: Add description to mysql_copy_mnesia
-module(mysql_copy_mnesia).
-compile(export_all).
-include("config_db_def.hrl").
-define(DB, conn).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).

%%
%% API Functions
%%



%%
%% Local Functions
%%






copy_dyna_data()->
		copy(account),
		copy(achieve_role),
		copy(activity_info_db),
		copy(activity_test01_role),
		copy(answer_roleinfo),
		copy(auto_name_used),
		copy(background_welfare_data),
		copy(black),
		copy(christmas_tree_db),
		copy(consume),
		copy(consume_return_info),
		copy(country_record),
		copy(enchant_extremely_property_opt),
		copy(facebook_bind),
		copy(fatigue),
		copy(festival_control_background),
		copy(festival_recharge_gift_bg),
		copy(friend),
		copy(game_rank_db),
		copy(giftcards),
		copy(global_exp_addition_db),
		copy(global_monster_loot_db),
		copy(gm_blockade),
		copy(gm_notice),
		copy(gm_role_privilege),
		copy(goals_role),
		copy(guild_baseinfo),
		copy(guild_battle_result),
		copy(guild_battle_score),
		copy(guild_events),
		copy(guild_facility_info),
		copy(guild_impeach_info),
		copy(guild_leave_member),
		copy(guild_log),
		copy(guild_member),
		copy(guild_member_shop),
		copy(guild_member_treasure),
		copy(guild_monster),
		copy(guild_right_limit),
		copy(guild_treasure_price),
		copy(guilditems),
		copy(guildpackage_apply),
		copy(idmax),
		copy(invite_friend),
		copy(jszd_role_score_honor),
		copy(jszd_role_score_info),
		copy(loop_instance_record),
		copy(loop_tower_instance),
		copy(mail),
		copy(mall_up_sales_table),
		copy(offline_exp_rolelog),
		copy(open_service_activitied_control),
		copy(open_service_level_rank_db),
		copy(pet_advance_reset_time),
		copy(pet_explore_background),
		copy(pet_explore_info),
		copy(pet_shop_info),
		copy(pets),
		copy(player_option),
		copy(playeritems),
		copy(quest_role),
		copy(recharge1),
		copy(role_activity_value),
		copy(role_buy_log),
		copy(role_buy_mall_item),
		copy(role_chess_spirit_log),
		copy(role_congratu_log),
		copy(role_continuous_logging_info),
		copy(role_designation_info),
		copy(role_favorite_gift_info),
		copy(role_festival_recharge_data),
		copy(role_first_charge_gift),
		copy(role_gold_exchange_info),
		copy(role_instance),
		copy(role_invite_friend_info),
		copy(role_judge_left_num),
		copy(role_judge_num),
		copy(role_levelup_opt_record),
		copy(role_login_bonus),
		copy(role_loop_instance),
		copy(role_loop_tower),
		copy(role_lottery),
		copy(role_mainline),
		copy(role_mall_integral),
		copy(role_quick_bar),
		copy(role_service_activities_db),
		copy(role_skill),
		copy(role_sum_gold),
		copy(role_timelimit_gift),
		copy(role_treasure_transport_db),
		copy(role_venation),
		copy(role_venation_advanced),
		copy(role_welfare_activity_info),
		copy(roleattr),
		copy(signature),
		copy(tangle_battle),
		copy(tangle_battle_kill_info),
		copy(tangle_battle_role_killnum),
		copy(template_playeritems),
		copy(vip_role),
		copy(yhzq_battle_record),
		copy(furnace),
		copy(furnace_add_role_attribute),
		copy(astrology_add_role_attribute),
		copy(astrology_package).

copy(Table)->
	case mnesia_operator:read(Table) of
		{ok,[]}->
			nothing;
		{ok,Info}->
			lists:map(fun(Object)->
							  mysqldb_read:write(Object) end, Info)
	end.
	

