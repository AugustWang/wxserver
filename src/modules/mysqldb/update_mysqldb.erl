%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-5-9
%% Description: TODO: Add description to uppdate_mysqldb
-module(update_mysqldb).
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

update_data(account,Object)->
	ValueList = lists:nthtail(2, tuple_to_list(Object)),
    [id | FieldList] = record_info(fields, account).

make_update_sql(TableName,FiedList,ValueList)->
	nothing.
	
replace_data(account,Object)->
	TermInfo=record_info(fields,account),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(account,NewInfo);

replace_data(achieve_role,Object)->
	TermInfo=record_info(fields,achieve_role),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(achieve_role,NewInfo);

replace_data(activity_info_db,Object)->
	TermInfo=record_info(fields,activity_info_db),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(activity_info_db,NewInfo);

replace_data(activity_test01_role,Object)->
	TermInfo=record_info(fields,activity_test01_role),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(activity_test01_role,NewInfo);

replace_data(answer_roleinfo,Object)->
	TermInfo=record_info(fields,answer_roleinfo),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(answer_roleinfo,NewInfo);

replace_data(auto_name_used,Object)->
	TermInfo=record_info(fields,auto_name_used),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(auto_name_used,NewInfo);

replace_data(background_welfare_data,Object)->
	TermInfo=record_info(fields,background_welfare_data),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(background_welfare_data,NewInfo);

replace_data(black,Object)->
	TermInfo=record_info(fields,black),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(black,NewInfo);

replace_data(christmas_tree_db,Object)->
	TermInfo=record_info(fields,christmas_tree_db),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(christmas_tree_db,NewInfo);

replace_data(consume,Object)->
	TermInfo=record_info(fields,consume),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(consume,NewInfo);


replace_data(consume_return_info,Object)->
	TermInfo=record_info(fields,consume_return_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(consume_return_info,NewInfo);

replace_data(country_record,Object)->
	TermInfo=record_info(fields,country_record),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(country_record,NewInfo);

replace_data(enchant_extremely_property_opt,Object)->
	TermInfo=record_info(fields,enchant_extremely_property_opt),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(enchant_extremely_property_opt,NewInfo);

replace_data(facebook_bind,Object)->
	TermInfo=record_info(fields,facebook_bind),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(facebook_bind,NewInfo);

replace_data(fatigue,Object)->
	TermInfo=record_info(fields,fatigue),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(fatigue,NewInfo);

replace_data(festival_recharge_gift_bg,Object)->
	TermInfo=record_info(fields,festival_recharge_gift_bg),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(festival_recharge_gift_bg,NewInfo);

replace_data(friend,Object)->
	TermInfo=record_info(fields,friend),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(friend,NewInfo);

replace_data(giftcards,Object)->
	TermInfo=record_info(fields,giftcards),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(giftcards,NewInfo);

replace_data(global_exp_addition_db,Object)->
	TermInfo=record_info(fields,global_exp_addition_db),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(global_exp_addition_db,NewInfo);

replace_data(global_monster_loot_db,Object)->
	TermInfo=record_info(fields,global_monster_loot_db),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(global_monster_loot_db,NewInfo);

replace_data(gm_blockade,Object)->
	TermInfo=record_info(fields,gm_blockade),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(gm_blockade,NewInfo);

replace_data(gm_notice,Object)->
	TermInfo=record_info(fields,gm_notice),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(gm_notice,NewInfo);

replace_data(goals_role,Object)->
	TermInfo=record_info(fields,goals_role),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(goals_role,NewInfo);

replace_data(guild_baseinfo,Object)->
	TermInfo=record_info(fields,guild_baseinfo),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_baseinfo,NewInfo);

replace_data(guild_battle_result,Object)->
	TermInfo=record_info(fields,guild_battle_result),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_battle_result,NewInfo);

replace_data(guild_battle_score,Object)->
	TermInfo=record_info(fields,guild_battle_score),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_battle_score,NewInfo);

replace_data(guild_events,Object)->
	TermInfo=record_info(fields,guild_events),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_events,NewInfo);

replace_data(guild_facility_info,Object)->
	TermInfo=record_info(fields,guild_facility_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_facility_info,NewInfo);

replace_data(guild_impeach_info,Object)->
	TermInfo=record_info(fields,guild_impeach_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_impeach_info,NewInfo);

replace_data(guild_leave_member,Object)->
	TermInfo=record_info(fields,guild_leave_member),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_leave_member,NewInfo);

replace_data(guild_log,Object)->
	TermInfo=record_info(fields,guild_log),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_log,NewInfo);

replace_data(guild_member_shop,Object)->
	TermInfo=record_info(fields,guild_member_shop),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_member_shop,NewInfo);

replace_data(guild_member_treasure,Object)->
	TermInfo=record_info(fields,guild_member_treasure),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_member_treasure,NewInfo);

replace_data(guild_member,Object)->
	TermInfo=record_info(fields,guild_member),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_member,NewInfo);

replace_data(guild_right_limit,Object)->
	TermInfo=record_info(fields,guild_right_limit),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_right_limit,NewInfo);

replace_data(guild_treasure_price,Object)->
	TermInfo=record_info(fields,guild_treasure_price),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_treasure_price,NewInfo);

replace_data(guilditems,Object)->
	TermInfo=record_info(fields,guilditems),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guilditems,NewInfo);

replace_data(guildpackage_apply,Object)->
	TermInfo=record_info(fields,guildpackage_apply),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guildpackage_apply,NewInfo);

replace_data(idmax,Object)->
	TermInfo=record_info(fields,idmax),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(idmax,NewInfo);

replace_data(jszd_role_score_honor,Object)->
	TermInfo=record_info(fields,jszd_role_score_honor),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(jszd_role_score_honor,NewInfo);

replace_data(jszd_role_score_info,Object)->
	TermInfo=record_info(fields,jszd_role_score_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(jszd_role_score_info,NewInfo);

replace_data(loop_instance_record,Object)->
	TermInfo=record_info(fields,loop_instance_record),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(loop_instance_record,NewInfo);

replace_data(loop_tower_instance,Object)->
	TermInfo=record_info(fields,loop_tower_instance),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(loop_tower_instance,NewInfo);

replace_data(mail,Object)->
	TermInfo=record_info(fields,mail),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(mail,NewInfo);

replace_data(offline_exp_rolelog,Object)->
	TermInfo=record_info(fields,offline_exp_rolelog),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(offline_exp_rolelog,NewInfo);

replace_data(open_service_activitied_control,Object)->
	TermInfo=record_info(fields,open_service_activitied_control),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(open_service_activitied_control,NewInfo);

replace_data(pet_advance_reset_time,Object)->
	TermInfo=record_info(fields,pet_advance_reset_time),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(pet_advance_reset_time,NewInfo);

replace_data(pet_explore_background,Object)->
	TermInfo=record_info(fields,pet_explore_background),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(pet_explore_background,NewInfo);

replace_data(pet_explore_info,Object)->
	TermInfo=record_info(fields,pet_explore_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(pet_explore_info,NewInfo);

replace_data(pet_explore_storage,Object)->
	TermInfo=record_info(fields,pet_explore_storage),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(pet_explore_storage,NewInfo);

replace_data(pet_shop_info,Object)->
	TermInfo=record_info(fields,pet_shop_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(pet_shop_info,NewInfo);

replace_data(pets,Object)->
	TermInfo=record_info(fields,pets),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(pets,NewInfo);

replace_data(player_option,Object)->
	TermInfo=record_info(fields,player_option),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(player_option,NewInfo);

replace_data(playeritems,Object)->
	TermInfo=record_info(fields,playeritems),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(playeritems,NewInfo);

replace_data(quest_role,Object)->
	TermInfo=record_info(fields,quest_role),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(quest_role,NewInfo);

replace_data(recharge1,Object)->
	TermInfo=record_info(fields,recharge1),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(recharge1,NewInfo);

replace_data(role_activity_value,Object)->
	TermInfo=record_info(fields,role_activity_value),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_activity_value,NewInfo);

replace_data(role_buy_log,Object)->
	TermInfo=record_info(fields,role_buy_log),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_buy_log,NewInfo);

replace_data(role_buy_mall_item,Object)->
	TermInfo=record_info(fields,role_buy_mall_item),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_buy_mall_item,NewInfo);

replace_data(role_chess_spirit_log,Object)->
	TermInfo=record_info(fields,role_chess_spirit_log),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_chess_spirit_log,NewInfo);

replace_data(role_congratu_log,Object)->
	TermInfo=record_info(fields,role_congratu_log),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_congratu_log,NewInfo);

replace_data(role_continuous_logging_info,Object)->
	TermInfo=record_info(fields,role_continuous_logging_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_continuous_logging_info,NewInfo);

replace_data(role_designation_info,Object)->
	TermInfo=record_info(fields,role_designation_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_designation_info,NewInfo);

replace_data(role_favorite_gift_info,Object)->
	TermInfo=record_info(fields,role_favorite_gift_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_favorite_gift_info,NewInfo);

replace_data(role_festival_recharge_data,Object)->
	TermInfo=record_info(fields,role_festival_recharge_data),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_festival_recharge_data,NewInfo);

replace_data(role_first_charge_gift,Object)->
	TermInfo=record_info(fields,role_first_charge_gift),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_first_charge_gift,NewInfo);

replace_data(role_gold_exchange_info,Object)->
	TermInfo=record_info(fields,role_gold_exchange_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_gold_exchange_info,NewInfo);

replace_data(role_instance,Object)->
	TermInfo=record_info(fields,role_instance),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_instance,NewInfo);

replace_data(role_instance_quality,Object)->
	TermInfo=record_info(fields,role_instance_quality),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_instance_quality,NewInfo);

replace_data(role_invite_friend_info,Object)->
	TermInfo=record_info(fields,role_invite_friend_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_invite_friend_info,NewInfo);

replace_data(role_judge_left_num,Object)->
	TermInfo=record_info(fields,role_judge_left_num),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_judge_left_num,NewInfo);

replace_data(role_judge_num,Object)->
	TermInfo=record_info(fields,role_judge_num),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_judge_num,NewInfo);

replace_data(role_levelup_opt_record,Object)->
	TermInfo=record_info(fields,role_levelup_opt_record),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_levelup_opt_record,NewInfo);

replace_data(role_login_bonus,Object)->
	TermInfo=record_info(fields,role_login_bonus),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_login_bonus,NewInfo);

replace_data(role_loop_instance,Object)->
	TermInfo=record_info(fields,role_loop_instance),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_loop_instance,NewInfo);

replace_data(role_loop_tower,Object)->
	TermInfo=record_info(fields,role_loop_tower),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_loop_tower,NewInfo);

replace_data(role_lottery,Object)->
	TermInfo=record_info(fields,role_lottery),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_lottery,NewInfo);

replace_data(role_mainline,Object)->
	TermInfo=record_info(fields,role_mainline),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_mainline,NewInfo);

replace_data(role_mall_integral,Object)->
	TermInfo=record_info(fields,role_mall_integral),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_mall_integral,NewInfo);

replace_data(role_quick_bar,Object)->
	TermInfo=record_info(fields,role_quick_bar),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_quick_bar,NewInfo);

replace_data(role_service_activities_db,Object)->
	TermInfo=record_info(fields,role_service_activities_db),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_service_activities_db,NewInfo);

replace_data(role_skill,Object)->
	TermInfo=record_info(fields,role_skill),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_skill,NewInfo);

replace_data(role_timelimit_gift,Object)->
	TermInfo=record_info(fields,role_timelimit_gift),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_timelimit_gift,NewInfo);

replace_data(role_treasure_storage,Object)->
	TermInfo=record_info(fields,role_treasure_storage),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_treasure_storage,NewInfo);

replace_data(role_treasure_transport_db,Object)->
	TermInfo=record_info(fields,role_treasure_transport_db),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_treasure_transport_db,NewInfo);

replace_data(role_venation,Object)->
	TermInfo=record_info(fields,role_venation),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_venation,NewInfo);

replace_data(role_venation_advanced,Object)->
	TermInfo=record_info(fields,role_venation_advanced),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_venation_advanced,NewInfo);

replace_data(role_welfare_activity_info,Object)->
	TermInfo=record_info(fields,role_welfare_activity_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_welfare_activity_info,NewInfo);

replace_data(roleattr,Object)->
	TermInfo=record_info(fields,roleattr),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(roleattr,NewInfo);

replace_data(signature,Object)->
	TermInfo=record_info(fields,signature),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(signature,NewInfo);

replace_data(tangle_battle,Object)->
	TermInfo=record_info(fields,tangle_battle),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(tangle_battle,NewInfo);

replace_data(tangle_battle_kill_info,Object)->
	TermInfo=record_info(fields,tangle_battle_kill_info),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(tangle_battle_kill_info,NewInfo);

replace_data(tangle_battle_role_killnum,Object)->
	TermInfo=record_info(fields,tangle_battle_role_killnum),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(tangle_battle_role_killnum,NewInfo);

replace_data(template_playeritems,Object)->
	TermInfo=record_info(fields,playeritems),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(template_playeritems,NewInfo);

replace_data(vip_role,Object)->
	TermInfo=record_info(fields,vip_role),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(vip_role,NewInfo);

replace_data(wing_role,Object)->
	TermInfo=record_info(fields,wing_role),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(wing_role,NewInfo);

replace_data(game_rank_db,Object)->
	TermInfo=record_info(fields,game_rank_db),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(game_rank_db,NewInfo);

replace_data(guild_monster,Object)->
	TermInfo=record_info(fields,guild_monster),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(guild_monster,NewInfo);

replace_data(yhzq_battle_record,Object)->
	TermInfo=record_info(fields,yhzq_battle_record),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(yhzq_battle_record,NewInfo);

replace_data(mall_up_sales_table,Object)->
	TermInfo=record_info(fields,mall_up_sales_table),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(mall_up_sales_table,NewInfo);

replace_data(instance_pos,Object)->
	TermInfo=record_info(fields,instance_pos),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(instance_pos,NewInfo);

replace_data(open_service_level_rank_db,Object)->
	TermInfo=record_info(fields,open_service_level_rank_db),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(open_service_level_rank_db,NewInfo);

replace_data(gm_role_privilege,Object)->
	TermInfo=record_info(fields,gm_role_privilege),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(gm_role_privilege,NewInfo);

replace_data(role_sum_gold,Object)->
	TermInfo=record_info(fields,role_sum_gold),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(role_sum_gold,NewInfo);

replace_data(furnace,Object)->
	TermInfo=record_info(fields,furnace),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(furnace,NewInfo);

replace_data(furnace_add_role_attribute,Object)->
	TermInfo=record_info(fields,furnace_add_role_attribute),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(furnace_add_role_attribute,NewInfo);

replace_data(astrology_add_role_attribute,Object)->
	TermInfo=record_info(fields,astrology_add_role_attribute),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(astrology_add_role_attribute,NewInfo);

replace_data(astrology_package,Object)->
	TermInfo=record_info(fields,astrology_package),
	ValueList = lists:nthtail(1, tuple_to_list(Object)),
	NewInfo=lists:zip(TermInfo, ValueList),
	replace(astrology_package,NewInfo);


replace_data(_,Object)->
	nothing.


%% 修改数据表(replace方式)
replace(Table_name, Field_Value_List) ->
	Sql = make_replace_sql(Table_name, Field_Value_List),
	execute(Sql).


make_replace_sql(Table_name, Field_Value_List) ->
 	{Vsql, _Count1} =
		lists:mapfoldl(
	  		fun(Field_value, Sum) ->	
				Expr = case Field_value of
						 {Field, Val} -> 
						if Val=:=undefined ->
								NewVal=[];
						true->
								NewVal=Val
						end,
							 case is_binary(NewVal) orelse is_list(NewVal)  orelse is_tuple(NewVal) orelse is_atom(NewVal)of 
								 true -> 
										if is_atom(NewVal)->
												 ["`", mysql_db_tool:to_list(Field),"`='",mysql_db_tool:get_sql_val(NewVal),"'"];
										   is_tuple(NewVal)->
												io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(NewVal))]);
											true->
												case mysql_db_tool:is_string(NewVal)of
													yes->
														if NewVal=:=[]->
															   io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(NewVal))]);
														   true->
																%io_lib:format("`~s`='~s'",[Field,auth_util:escape_uri(NewVal)])
																io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(NewVal))])
														end;
													_->
														io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(NewVal))])
												end
%% 												%io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(NewVal))])
%% 												Result=io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(NewVal))]),
%% 												%auth_util:escape_uri(Result)
%% 												Result
										end;
							 	 _-> io_lib:format("`~s`=~p",[Field, NewVal])
							 end
					end,
				S1 = if Sum == length(Field_Value_List) -> io_lib:format("~s ",[Expr]);
						true -> io_lib:format("~s,",[Expr])
					 end,
 				{S1, Sum+1}
			end,
			1, Field_Value_List),
	lists:concat(["replace into `", Table_name, "` set ",
	 			  lists:flatten(Vsql)
				 ]).


%% 执行一个SQL查询,返回影响的行数
execute(Sql) ->
    case mysql:fetch(?DB, Sql) of
        {updated, {_, _, _, R, _}} -> {ok};
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.
execute(Sql, Args) when is_atom(Sql) ->
    case mysql:execute(?DB, Sql, Args) of
        {updated, {_, _, _, R, _}} -> {ok};
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end;
execute(Sql, Args) ->
    mysql:prepare(s, Sql),
    case mysql:execute(?DB, s, Args) of
        {updated, {_, _, _, R, _}} ->{ok};
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.

%% @doc 显示人可以看得懂的错误信息
mysql_halt([Sql, Reason]) ->
    catch erlang:error({db_error, [Sql, Reason]}).


%% replace_new(TabelName,TermInfo,ValueList)->
%% 	Sql=make_sql(TabelName,TermInfo,ValueList),
%% 	io:format("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   Sql   ~p~n",[Sql]),
%% 	execute(Sql).
%% 
%% 
%% make_sql(TableName,TermInfo,ValueList)->
%% 	L=mysql_db_tool:make_conn_sql(TermInfo,ValueList, []),
%% 	lists:concat(["replace into `",TableName,"` set ", L]).










