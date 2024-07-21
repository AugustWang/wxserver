%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-5-6
%% Description: TODO: Add description to create_mysql_table
-module(create_mysql_table).
-compile(export_all).
-define(DB, conn).
-include("config_db_def.hrl").
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

%% Author: Administrator
%% Created: 2013-5-6
%% Description: TODO: Add description to mysql_change

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
create_table_proto(Object)->
	 ValueList = lists:nthtail(1, tuple_to_list(Object)),
	 TableName=erlang:element(1, Object),
	 create(TableName,ValueList).

create(achieve_proto,ValueList)->
	  FieldList = record_info(fields, achieve_proto),
	  create_table(achieve_proto, FieldList, ValueList);
create(achieve_fuwen,ValueList)->
	  FieldList = record_info(fields, achieve_fuwen),
	  create_table(achieve_fuwen, FieldList, ValueList);
create(achieve_award,ValueList)->
	  FieldList = record_info(fields, achieve_award),
	  create_table(achieve_award, FieldList, ValueList);
create(achieve,ValueList)->
	  FieldList = record_info(fields, achieve),
	  create_table(achieve, FieldList, ValueList);

create(activity,ValueList)->
	  FieldList = record_info(fields, activity),
	  create_table(activity, FieldList, ValueList);
create(activity_value_proto,ValueList)->
	  FieldList = record_info(fields, activity_value_proto),
	  create_table(activity_value_proto, FieldList, ValueList);
create(activity_value_reward,ValueList)->
	  FieldList = record_info(fields, activity_value_reward),
	  create_table(activity_value_reward, FieldList, ValueList);
create(ai_agents,ValueList)->
	  FieldList = record_info(fields, ai_agents),
	  create_table(ai_agents, FieldList, ValueList);
create(achieve_award,ValueList)->
	  FieldList = record_info(fields, achieve_award),
	  create_table(achieve_award, FieldList, ValueList);
create(answer,ValueList)->
	  FieldList = record_info(fields, answer),
	  create_table(answer, FieldList, ValueList);
create(answer_option,ValueList)->
	  FieldList = record_info(fields, answer_option),
	  create_table(answer_option, FieldList, ValueList);
create(attr_info,ValueList)->
	  FieldList = record_info(fields, attr_info),
	  create_table(attr_info, FieldList, ValueList);
create(auto_name,ValueList)->
	  FieldList = record_info(fields, auto_name),
	  create_table(auto_name, FieldList, ValueList);
create(back_echantment_stone,ValueList)->
	  FieldList = record_info(fields, back_echantment_stone),
	  create_table(back_echantment_stone, FieldList, ValueList);
create(battlefield_proto,ValueList)->
	  FieldList = record_info(fields, battlefield_proto),
	  create_table(battlefield_proto, FieldList, ValueList);
create(block_training,ValueList)->
	  FieldList = record_info(fields, block_training),
	  create_table(block_training, FieldList, ValueList);
create(buffers,ValueList)->
	  FieldList = record_info(fields, buffers),
	  create_table(buffers, FieldList, ValueList);
create(chat_condition,ValueList)->
	  FieldList = record_info(fields, chat_condition),
	  create_table(chat_condition, FieldList, ValueList);
create(chess_spirit_config,ValueList)->
	  FieldList = record_info(fields, chess_spirit_config),
	  create_table(chess_spirit_config, FieldList, ValueList);
create(chess_spirit_rewards,ValueList)->
	  FieldList = record_info(fields, chess_spirit_rewards),
	  create_table(chess_spirit_rewards, FieldList, ValueList);
create(chess_spirit_section,ValueList)->
	  FieldList = record_info(fields, chess_spirit_section),
	  create_table(chess_spirit_section, FieldList, ValueList);
create(christmas_activity_reward,ValueList)->
	  FieldList = record_info(fields, christmas_activity_reward),
	  create_table(christmas_activity_reward, FieldList, ValueList);
create(achieve_award,ValueList)->
	  FieldList = record_info(fields, achieve_award),
	  create_table(achieve_award, FieldList, ValueList);
create(christmas_tree_config,ValueList)->
	  FieldList = record_info(fields, christmas_tree_config),
	  create_table(christmas_tree_config, FieldList, ValueList);
create(classbase,ValueList)->
	  FieldList = record_info(fields, classbase),
	  create_table(classbase, FieldList, ValueList);
create(congratulations,ValueList)->
	  FieldList = record_info(fields, congratulations),
	  create_table(congratulations, FieldList, ValueList);
create(continuous_logging_gift,ValueList)->
	  FieldList = record_info(fields, continuous_logging_gift),
	  create_table(continuous_logging_gift, FieldList, ValueList);
create(country_proto,ValueList)->
	  FieldList = record_info(fields, country_proto),
	  create_table(country_proto, FieldList, ValueList);
create(creature_proto,ValueList)->
	  FieldList = record_info(fields, creature_proto),
	  create_table(creature_proto, FieldList, ValueList);
create(designation_data,ValueList)->
	  FieldList = record_info(fields, designation_data),
	  create_table(designation_data, FieldList, ValueList);
create(dragon_fight_db,ValueList)->
	  FieldList = record_info(fields, dragon_fight_db),
	  create_table(dragon_fight_db, FieldList, ValueList);
create(drop_rule,ValueList)->
	  FieldList = record_info(fields, drop_rule),
	  create_table(drop_rule, FieldList, ValueList);
create(enchantments,ValueList)->
	  FieldList = record_info(fields, enchantments),
	  create_table(enchantments, FieldList, ValueList);
create(enchantments_lucky,ValueList)->
	  FieldList = record_info(fields, enchantments_lucky),
	  create_table(enchantments_lucky, FieldList, ValueList);
create(enchant_convert,ValueList)->
	  FieldList = record_info(fields, enchant_convert),
	  create_table(enchant_convert, FieldList, ValueList);
create(enchant_opt,ValueList)->
	  FieldList = record_info(fields, enchant_opt),
	  create_table(enchant_opt, FieldList, ValueList);
create(enchant_property_opt,ValueList)->
	  FieldList = record_info(fields, enchant_property_opt),
	  create_table(enchant_property_opt, FieldList, ValueList);
create(equipmentset,ValueList)->
	  FieldList = record_info(fields, equipmentset),
	  create_table(equipmentset, FieldList, ValueList);
create(equipment_fenjie,ValueList)->
	  FieldList = record_info(fields, equipment_fenjie),
	  create_table(equipment_fenjie, FieldList, ValueList);
create(equipment_move,ValueList)->
	  FieldList = record_info(fields, equipment_move),
	  create_table(equipment_move, FieldList, ValueList);
create(equipment_sysbrd,ValueList)->
	  FieldList = record_info(fields, equipment_sysbrd),
	  create_table(equipment_sysbrd, FieldList, ValueList);
create(equipment_upgrade,ValueList)->
	  FieldList = record_info(fields, equipment_upgrade),
	  create_table(equipment_upgrade, FieldList, ValueList);
create(everquests,ValueList)->
	  FieldList = record_info(fields, everquests),
	  create_table(everquests, FieldList, ValueList);
create(faction_relations,ValueList)->
	  FieldList = record_info(fields, faction_relations),
	  create_table(faction_relations, FieldList, ValueList);
create(festival_control,ValueList)->
	  FieldList = record_info(fields, festival_control),
	  create_table(festival_control, FieldList, ValueList);
create(festival_recharge_gift,ValueList)->
	  FieldList = record_info(fields, festival_recharge_gift),
	  create_table(festival_recharge_gift, FieldList, ValueList);
create(goals,ValueList)->
	  FieldList = record_info(fields, goals),
	  create_table(goals, FieldList, ValueList);
create(guild_authorities,ValueList)->
	  FieldList = record_info(fields, guild_authorities),
	  create_table(guild_authorities, FieldList, ValueList);
create(guild_auth_groups,ValueList)->
	  FieldList = record_info(fields, guild_auth_groups),
	  create_table(guild_auth_groups, FieldList, ValueList);
create(guild_battle_proto,ValueList)->
	  FieldList = record_info(fields, guild_battle_proto),
	  create_table(guild_battle_proto, FieldList, ValueList);
create(guild_facilities,ValueList)->
	  FieldList = record_info(fields, guild_facilities),
	  create_table(guild_facilities, FieldList, ValueList);
create(guild_monster_proto,ValueList)->
	  FieldList = record_info(fields, guild_monster_proto),
	  create_table(guild_monster_proto, FieldList, ValueList);
create(guild_setting,ValueList)->
	  FieldList = record_info(fields, guild_setting),
	  create_table(guild_setting, FieldList, ValueList);
create(guild_shop,ValueList)->
	  FieldList = record_info(fields, guild_shop),
	  create_table(guild_shop, FieldList, ValueList);
create(guild_shop_items,ValueList)->
	  FieldList = record_info(fields, guild_shop_items),
	  create_table(guild_shop_items, FieldList, ValueList);
create(guild_treasure,ValueList)->
	  FieldList = record_info(fields, guild_treasure),
	  create_table(guild_treasure, FieldList, ValueList);
create(guild_treasure_items,ValueList)->
	  FieldList = record_info(fields, guild_treasure_items),
	  create_table(guild_treasure_items, FieldList, ValueList);
create(guild_treasure_transport_consume,ValueList)->
	  FieldList = record_info(fields, guild_treasure_transport_consume),
	  create_table(guild_treasure_transport_consume, FieldList, ValueList);
create(honor_store_items,ValueList)->
	  FieldList = record_info(fields, honor_store_items),
	  create_table(honor_store_items, FieldList, ValueList);
create(inlay,ValueList)->
	  FieldList = record_info(fields, inlay),
	  create_table(inlay, FieldList, ValueList);
create(instance_proto,ValueList)->
	  FieldList = record_info(fields, instance_proto),
	  create_table(instance_proto, FieldList, ValueList);
create(item_identify,ValueList)->
	  FieldList = record_info(fields, item_identify),
	  create_table(item_identify, FieldList, ValueList);
create(item_template,ValueList)->
	  FieldList = record_info(fields, item_template),
	  create_table(item_template, FieldList, ValueList);
create(jszd_rank_option,ValueList)->
	  FieldList = record_info(fields, jszd_rank_option),
	  create_table(jszd_rank_option, FieldList, ValueList);
create(levelup_opt,ValueList)->
	  FieldList = record_info(fields, levelup_opt),
	  create_table(levelup_opt, FieldList, ValueList);
create(level_activity_rewards_db,ValueList)->
	  FieldList = record_info(fields, level_activity_rewards_db),
	  create_table(level_activity_rewards_db, FieldList, ValueList);
create(loop_instance,ValueList)->
	  FieldList = record_info(fields, loop_instance),
	  create_table(loop_instance, FieldList, ValueList);
create(loop_instance_proto,ValueList)->
	  FieldList = record_info(fields, loop_instance_proto),
	  create_table(loop_instance_proto, FieldList, ValueList);
create(loop_tower,ValueList)->
	  FieldList = record_info(fields, loop_tower),
	  create_table(loop_tower, FieldList, ValueList);
create(lottery_counts,ValueList)->
	  FieldList = record_info(fields, lottery_counts),
	  create_table(lottery_counts, FieldList, ValueList);
create(lottery_droplist,ValueList)->
	  FieldList = record_info(fields, lottery_droplist),
	  create_table(lottery_droplist, FieldList, ValueList);
create(mainline_defend_config,ValueList)->
	  FieldList = record_info(fields, mainline_defend_config),
	  create_table(mainline_defend_config, FieldList, ValueList);
create(mainline_proto,ValueList)->
	  FieldList = record_info(fields, mainline_proto),
	  create_table(mainline_proto, FieldList, ValueList);
create(mall_item_info,ValueList)->
	  FieldList = record_info(fields, mall_item_info),
	  create_table(mall_item_info, FieldList, ValueList);
create(mall_sales_item_info,ValueList)->
	  FieldList = record_info(fields, mall_sales_item_info),
	  create_table(mall_sales_item_info, FieldList, ValueList);
create(map_info,ValueList)->
	  FieldList = record_info(fields, map_info),
	  create_table(map_info, FieldList, ValueList);
create(npc_dragon_fight,ValueList)->
	  FieldList = record_info(fields, npc_dragon_fight),
	  create_table(npc_dragon_fight, FieldList, ValueList);
create(npc_drop,ValueList)->
	  FieldList = record_info(fields, npc_drop),
	  create_table(npc_drop, FieldList, ValueList);
create(npc_exchange_list,ValueList)->
	  FieldList = record_info(fields, npc_exchange_list),
	  create_table(npc_exchange_list, FieldList, ValueList);
create(everquest_list,ValueList)->
	  FieldList = record_info(fields, everquest_list),
	  create_table(everquest_list, FieldList, ValueList);
create(npc_sell_list,ValueList)->
	  FieldList = record_info(fields, npc_sell_list),
	  create_table(npc_sell_list, FieldList, ValueList);
create(npc_trans_list,ValueList)->
	  FieldList = record_info(fields, npc_trans_list),
	  create_table(npc_trans_list, FieldList, ValueList);
create(quest_npc,ValueList)->
	  FieldList = record_info(fields, quest_npc),
	  create_table(quest_npc, FieldList, ValueList);
create(npc_functions,ValueList)->
	  FieldList = record_info(fields, npc_functions),
	  create_table(npc_functions, FieldList, ValueList);
create(offline_everquests_exp,ValueList)->
	  FieldList = record_info(fields, offline_everquests_exp),
	  create_table(offline_everquests_exp, FieldList, ValueList);
create(offline_exp,ValueList)->
	  FieldList = record_info(fields, offline_exp),
	  create_table(offline_exp, FieldList, ValueList);
create(open_service_activities,ValueList)->
	  FieldList = record_info(fields, open_service_activities),
	  create_table(open_service_activities, FieldList, ValueList);
create(open_service_activities_time,ValueList)->
	  FieldList = record_info(fields, open_service_activities_time),
	  create_table(open_service_activities_time, FieldList, ValueList);
create(pet_evolution,ValueList)->
	  FieldList = record_info(fields, pet_evolution),
	  create_table(pet_evolution, FieldList, ValueList);
create(pet_explore_gain,ValueList)->
	  FieldList = record_info(fields, pet_explore_gain),
	  create_table(pet_explore_gain, FieldList, ValueList);
create(pet_explore_style,ValueList)->
	  FieldList = record_info(fields, pet_explore_style),
	  create_table(pet_explore_style, FieldList, ValueList);
create(pet_growth,ValueList)->
	  FieldList = record_info(fields, pet_growth),
	  create_table(pet_growth, FieldList, ValueList);
create(pet_happiness,ValueList)->
	  FieldList = record_info(fields, pet_happiness),
	  create_table(pet_happiness, FieldList, ValueList);
create(pet_level,ValueList)->
	  FieldList = record_info(fields, pet_level),
	  create_table(pet_level, FieldList, ValueList);
create(pet_proto,ValueList)->
	  FieldList = record_info(fields, pet_proto),
	  create_table(pet_proto, FieldList, ValueList);
create(pet_quality,ValueList)->
	  FieldList = record_info(fields, pet_quality),
	  create_table(pet_quality, FieldList, ValueList);
create(pet_quality_up,ValueList)->
	  FieldList = record_info(fields, pet_quality_up),
	  create_table(pet_quality_up, FieldList, ValueList);
create(pet_skill_slot,ValueList)->
	  FieldList = record_info(fields, pet_skill_slot),
	  create_table(pet_skill_slot, FieldList, ValueList);
create(pet_slot,ValueList)->
	  FieldList = record_info(fields, pet_slot),
	  create_table(pet_slot, FieldList, ValueList);
create(pet_talent_consume,ValueList)->
	  FieldList = record_info(fields, pet_talent_consume),
	  create_table(pet_talent_consume, FieldList, ValueList);
create(pet_talent_rate,ValueList)->
	  FieldList = record_info(fields, pet_talent_rate),
	  create_table(pet_talent_rate, FieldList, ValueList);
create(pet_wash_attr_point,ValueList)->
	  FieldList = record_info(fields, pet_wash_attr_point),
	  create_table(pet_wash_attr_point, FieldList, ValueList);
create(pet_item_mall,ValueList)->
	  FieldList = record_info(fields, pet_item_mall),
	  create_table(pet_item_mall, FieldList, ValueList);
create(quests,ValueList)->
	  FieldList = record_info(fields, quests),
	  create_table(quests, FieldList, ValueList);
create(refine_system,ValueList)->
	  FieldList = record_info(fields, refine_system),
	  create_table(refine_system, FieldList, ValueList);
create(remove_seal,ValueList)->
	  FieldList = record_info(fields, remove_seal),
	  create_table(remove_seal, FieldList, ValueList);
create(ridepet_synthesis,ValueList)->
	  FieldList = record_info(fields, ridepet_synthesis),
	  create_table(ridepet_synthesis, FieldList, ValueList);
create(ride_proto_db,ValueList)->
	  FieldList = record_info(fields, ride_proto_db),
	  create_table(ride_proto_db, FieldList, ValueList);
create(role_level_bonfire_effect_db,ValueList)->
	  FieldList = record_info(fields, role_level_bonfire_effect_db),
	  create_table(role_level_bonfire_effect_db, FieldList, ValueList);
create(role_level_experience,ValueList)->
	  FieldList = record_info(fields, role_level_experience),
	  create_table(role_level_experience, FieldList, ValueList);
create(role_level_sitdown_effect_db,ValueList)->
	  FieldList = record_info(fields, role_level_sitdown_effect_db),
	  create_table(role_level_sitdown_effect_db, FieldList, ValueList);
create(role_level_soulpower,ValueList)->
	  FieldList = record_info(fields, role_level_soulpower),
	  create_table(role_level_soulpower, FieldList, ValueList);
create(role_petnum,ValueList)->
	  FieldList = record_info(fields, role_petnum),
	  create_table(role_petnum, FieldList, ValueList);
create(series_kill,ValueList)->
	  FieldList = record_info(fields, series_kill),
	  create_table(series_kill, FieldList, ValueList);
create(skills,ValueList)->
	  FieldList = record_info(fields, skills),
	  create_table(skills, FieldList, ValueList);
create(sock,ValueList)->
	  FieldList = record_info(fields, sock),
	  create_table(sock, FieldList, ValueList);
create(spa_exp,ValueList)->
	  FieldList = record_info(fields, spa_exp),
	  create_table(spa_exp, FieldList, ValueList);
create(spa_option,ValueList)->
	  FieldList = record_info(fields, spa_option),
	  create_table(spa_option, FieldList, ValueList);
create(stonemix,ValueList)->
	  FieldList = record_info(fields, stonemix),
	  create_table(stonemix, FieldList, ValueList);
create(system_chat,ValueList)->
	  FieldList = record_info(fields, system_chat),
	  create_table(system_chat, FieldList, ValueList);
create(tangle_reward_info,ValueList)->
	  FieldList = record_info(fields, tangle_reward_info),
	  create_table(tangle_reward_info, FieldList, ValueList);
create(template_itemproto,ValueList)->
	  FieldList = record_info(fields, template_itemproto),
	  create_table(template_itemproto, FieldList, ValueList);
create(timelimit_gift,ValueList)->
	  FieldList = record_info(fields, timelimit_gift),
	  create_table(timelimit_gift, FieldList, ValueList);
create(transports,ValueList)->
	  FieldList = record_info(fields, transports),
	  create_table(transports, FieldList, ValueList);
create(transport_channel,ValueList)->
	  FieldList = record_info(fields, transport_channel),
	  create_table(transport_channel, FieldList, ValueList);
create(treasure_chest_drop,ValueList)->
	  FieldList = record_info(fields, treasure_chest_drop),
	  create_table(treasure_chest_drop, FieldList, ValueList);
create(treasure_chest_rate,ValueList)->
	  FieldList = record_info(fields, treasure_chest_rate),
	  create_table(treasure_chest_rate, FieldList, ValueList);
create(treasure_chest_times,ValueList)->
	  FieldList = record_info(fields, treasure_chest_times),
	  create_table(treasure_chest_times, FieldList, ValueList);
create(treasure_chest_type,ValueList)->
	  FieldList = record_info(fields, treasure_chest_type),
	  create_table(treasure_chest_type, FieldList, ValueList);
create(treasure_spawns,ValueList)->
	  FieldList = record_info(fields, treasure_spawns),
	  create_table(treasure_spawns, FieldList, ValueList);
create(treasure_transport,ValueList)->
	  FieldList = record_info(fields, treasure_transport),
	  create_table(treasure_transport, FieldList, ValueList);
create(treasure_transport_quality_bonus,ValueList)->
	  FieldList = record_info(fields, treasure_transport_quality_bonus),
	  create_table(treasure_transport_quality_bonus, FieldList, ValueList);
create(venation_advanced,ValueList)->
	  FieldList = record_info(fields, venation_advanced),
	  create_table(venation_advanced, FieldList, ValueList);
create(venation_exp_proto,ValueList)->
	  FieldList = record_info(fields, venation_exp_proto),
	  create_table(venation_exp_proto, FieldList, ValueList);
create(venation_item_rate,ValueList)->
	  FieldList = record_info(fields, venation_item_rate),
	  create_table(venation_item_rate, FieldList, ValueList);
create(venation_point_proto,ValueList)->
	  FieldList = record_info(fields, venation_point_proto),
	  create_table(venation_point_proto, FieldList, ValueList);
create(venation_proto,ValueList)->
	  FieldList = record_info(fields, venation_proto),
	  create_table(venation_proto, FieldList, ValueList);
create(vip_level,ValueList)->
	  FieldList = record_info(fields, vip_level),
	  create_table(vip_level, FieldList, ValueList);
create(welfare_activity_data,ValueList)->
	  FieldList = record_info(fields, welfare_activity_data),
	  create_table(welfare_activity_data, FieldList, ValueList);
create(yhzq_battle,ValueList)->
	  FieldList = record_info(fields, yhzq_battle),
	  create_table(yhzq_battle, FieldList, ValueList);
create(yhzq_winner_raward,ValueList)->
	  FieldList = record_info(fields, yhzq_winner_raward),
	  create_table(yhzq_winner_raward, FieldList, ValueList);
create(creature_spawns,ValueList)->
	  FieldList = record_info(fields, creature_spawns),
	  create_table(creature_spawns, FieldList, ValueList);
create(template_roleattr,ValueList)->
	  FieldList = record_info(fields, roleattr),
	  create_table(template_roleattr, FieldList, ValueList);
create(template_role_quick_bar,ValueList)->
	  FieldList = record_info(fields, role_quick_bar),
	  create_table(template_role_quick_bar, FieldList, ValueList);
create(template_role_skill,ValueList)->
	  FieldList = record_info(fields, role_skill),
	  create_table(template_role_skill, FieldList, ValueList);
create(template_quest_role,ValueList)->
	  FieldList = record_info(fields, quest_role),
	  create_table(template_quest_role, FieldList, ValueList);
create(instance_quality_proto,ValueList)->
	  FieldList = record_info(fields, instance_quality_proto),
	  create_table(instance_quality_proto, FieldList, ValueList);
create(pet_skill_template,ValueList)->
	  FieldList = record_info(fields, pet_skill_template),
	  create_table(pet_skill_template, FieldList, ValueList);
create(pet_skill_proto,ValueList)->
	  FieldList = record_info(fields, pet_skill_proto),
	  create_table(pet_skill_proto, FieldList, ValueList);
create(instance_entrust,ValueList)->
	  FieldList = record_info(fields, instance_entrust),
	  create_table(instance_entrust, FieldList, ValueList);
create(activity_test01,ValueList)->
	  FieldList = record_info(fields, activity_test01),
	  create_table(activity_test01, FieldList, ValueList);
create(pet_attr_transform,ValueList)->
	  FieldList = record_info(fields, pet_attr_transform),
	  create_table(pet_attr_transform, FieldList, ValueList);
create(pet_up_growth,ValueList)->
	  FieldList = record_info(fields, pet_up_growth),
	  create_table(pet_up_growth, FieldList, ValueList);
create(stonemix_rateinfo,ValueList)->
	  FieldList = record_info(fields, stonemix_rateinfo),
	  create_table(stonemix_rateinfo, FieldList, ValueList);
create(pet_skill_book_rate,ValueList)->
	  FieldList = record_info(fields, pet_skill_book_rate),
	  create_table(pet_skill_book_rate, FieldList, ValueList);
create(pet_skill_book,ValueList)->
	  FieldList = record_info(fields, pet_skill_book),
	  create_table(pet_skill_book, FieldList, ValueList);
create(pet_fresh_skill,ValueList)->
	  FieldList = record_info(fields, pet_fresh_skill),
	  create_table(pet_fresh_skill, FieldList, ValueList);
create(pet_base_attr,ValueList)->
	  FieldList = record_info(fields, pet_base_attr),
	  create_table(pet_base_attr, FieldList, ValueList);
create(pet_xisui_rate,ValueList)->
	  FieldList = record_info(fields, pet_xisui_rate),
	  create_table(pet_xisui_rate, FieldList, ValueList);
create(pet_talent_item,ValueList)->
	  FieldList = record_info(fields, pet_talent_item),
	  create_table(pet_talent_item, FieldList, ValueList);
create(pet_talent_proto,ValueList)->
	  FieldList = record_info(fields, pet_talent_proto),
	  create_table(pet_talent_proto, FieldList, ValueList);
create(pet_talent_template,ValueList)->
	  FieldList = record_info(fields, pet_talent_template),
	  create_table(pet_talent_template, FieldList, ValueList);
create(pet_advance,ValueList)->
	  FieldList = record_info(fields, pet_advance),
	  create_table(pet_advance, FieldList, ValueList);
create(pet_advance_lucky,ValueList)->
	  FieldList = record_info(fields, pet_advance_lucky),
	  create_table(pet_advance_lucky, FieldList, ValueList);
create(wing_level,ValueList)->
	  FieldList = record_info(fields, wing_level),
	  create_table(wing_level, FieldList, ValueList);
create(wing_phase,ValueList)->
	  FieldList = record_info(fields, wing_phase),
	  create_table(wing_phase, FieldList, ValueList);
create(wing_intensify_up,ValueList)->
	  FieldList = record_info(fields, wing_intensify_up),
	  create_table(wing_intensify_up, FieldList, ValueList);
create(wing_quality,ValueList)->
	  FieldList = record_info(fields, wing_quality),
	  create_table(wing_quality, FieldList, ValueList);
create(wing_skill,ValueList)->
	  FieldList = record_info(fields, wing_skill),
	  create_table(wing_skill, FieldList, ValueList);
create(item_gold_price,ValueList)->
	  FieldList = record_info(fields, item_gold_price),
	  create_table(item_gold_price, FieldList, ValueList);
create(wing_echant,ValueList)->
	  FieldList = record_info(fields, wing_echant),
	  create_table(wing_echant, FieldList, ValueList);
create(wing_echant_lock,ValueList)->
	  FieldList = record_info(fields, wing_echant_lock),
	  create_table(wing_echant_lock, FieldList, ValueList);
create(charge_package_proto,ValueList)->
	  FieldList = record_info(fields, charge_package_proto),
	  create_table(charge_package_proto, FieldList, ValueList);
create(item_can_used,ValueList)->
	  FieldList = record_info(fields, item_can_used),
	  create_table(item_can_used, FieldList, ValueList);

create(account,ValueList)->
	  FieldList = record_info(fields, account),
	  create_table(account, FieldList, ValueList);

create(activity_info_db,ValueList)->
	  FieldList = record_info(fields, activity_info_db),
	  create_table(activity_info_db, FieldList, ValueList);
create(auction,ValueList)->
	  FieldList = record_info(fields, auction),
	  create_table(auction, FieldList, ValueList);
create(auto_name_used,ValueList)->
	  FieldList = record_info(fields, auto_name_used),
	  create_table(auto_name_used, FieldList, ValueList);
create(consume_return_info,ValueList)->
	  FieldList = record_info(fields, consume_return_info),
	  create_table(consume_return_info, FieldList, ValueList);
create(country_record,ValueList)->
	  FieldList = record_info(fields, country_record),
	  create_table(country_record, FieldList, ValueList);
create(friend,ValueList)->
	  FieldList = record_info(fields, friend),
	  create_table(friend, FieldList, ValueList);
create(game_rank_db,ValueList)->
	  FieldList = record_info(fields, game_rank_db),
	  create_table(game_rank_db, FieldList, ValueList);

create(gm_role_privilege,ValueList)->
	  FieldList = record_info(fields, gm_role_privilege),
	  create_table(gm_role_privilege, FieldList, ValueList);

create(guild_battle_score,ValueList)->
	  FieldList = record_info(fields, guild_battle_score),
	  create_table(guild_battle_score, FieldList, ValueList);

create(guild_leave_member,ValueList)->
	  FieldList = record_info(fields, guild_leave_member),
	  create_table(guild_leave_member, FieldList, ValueList);
create(guild_log,ValueList)->
	  FieldList = record_info(fields, guild_log),
	  create_table(guild_log, FieldList, ValueList);
create(guild_member_treasure,ValueList)->
	  FieldList = record_info(fields, guild_member_treasure),
	  create_table(guild_member_treasure, FieldList, ValueList);
create(guild_right_limit,ValueList)->
	  FieldList = record_info(fields, guild_right_limit),
	  create_table(guild_member_treasure, FieldList, ValueList);
create(guilditems,ValueList)->
	  FieldList = record_info(fields, guilditems),
	  create_table(guilditems, FieldList, ValueList);
create(guildpackage_apply,ValueList)->
	  FieldList = record_info(fields, guildpackage_apply),
	  create_table(guildpackage_apply, FieldList, ValueList);
create(idmax,ValueList)->
	  FieldList = record_info(fields, idmax),
	  create_table(idmax, FieldList, ValueList);
create(mail,ValueList)->
	  FieldList = record_info(fields, mail),
	  create_table(mail, FieldList, ValueList);
create(mall_up_sales_table,ValueList)->
	  FieldList = record_info(fields, mall_up_sales_table),
	  create_table(mall_up_sales_table, FieldList, ValueList);
create(offline_exp_rolelog,ValueList)->
	  FieldList = record_info(fields, offline_exp_rolelog),
	  create_table(offline_exp_rolelog, FieldList, ValueList);
create(pet_shop_info,ValueList)->
	  FieldList = record_info(fields, pet_shop_info),
	  create_table(pet_shop_info, FieldList, ValueList);
create(role_activity_value,ValueList)->
	  FieldList = record_info(fields, role_activity_value),
	  create_table(role_activity_value, FieldList, ValueList);
create(role_buy_log,ValueList)->
	  FieldList = record_info(fields, role_buy_log),
	  create_table(role_buy_log, FieldList, ValueList);
create(role_buy_mall_item,ValueList)->
	  FieldList = record_info(fields, role_buy_mall_item),
	  create_table(role_buy_mall_item, FieldList, ValueList);
create(role_chess_spirit_log,ValueList)->
	  FieldList = record_info(fields, role_chess_spirit_log),
	  create_table(role_chess_spirit_log, FieldList, ValueList);
create(role_congratu_log,ValueList)->
	  FieldList = record_info(fields, role_congratu_log),
	  create_table(role_congratu_log, FieldList, ValueList);
create(role_continuous_logging_info,ValueList)->
	  FieldList = record_info(fields, role_continuous_logging_info),
	  create_table(role_continuous_logging_info, FieldList, ValueList);
create(role_designation_info,ValueList)->
	  FieldList = record_info(fields, role_designation_info),
	  create_table(role_designation_info, FieldList, ValueList);
create(role_gold_exchange_info,ValueList)->
	  FieldList = record_info(fields, role_gold_exchange_info),
	  create_table(role_gold_exchange_info, FieldList, ValueList);
create(role_judge_left_num,ValueList)->
	  FieldList = record_info(fields, role_judge_left_num),
	  create_table(role_judge_left_num, FieldList, ValueList);
create(role_judge_num,ValueList)->
	  FieldList = record_info(fields, role_judge_num),
	  create_table(role_judge_num, FieldList, ValueList);
create(role_login_bonus,ValueList)->
	  FieldList = record_info(fields, role_login_bonus),
	  create_table(role_login_bonus, FieldList, ValueList);
create(role_loop_instance,ValueList)->
	  FieldList = record_info(fields, role_loop_instance),
	  create_table(role_loop_instance, FieldList, ValueList);
create(role_loop_tower,ValueList)->
	  FieldList = record_info(fields, role_loop_tower),
	  create_table(role_loop_tower, FieldList, ValueList);
create(role_mall_integral,ValueList)->
	  FieldList = record_info(fields, role_mall_integral),
	  create_table(role_mall_integral, FieldList, ValueList);
create(role_service_activities_db,ValueList)->
	  FieldList = record_info(fields, role_service_activities_db),
	  create_table(role_service_activities_db, FieldList, ValueList);
create(role_sum_gold,ValueList)->
	  FieldList = record_info(fields, role_sum_gold),
	  create_table(role_sum_gold, FieldList, ValueList);
create(role_treasure_transport_db,ValueList)->
	  FieldList = record_info(fields, role_treasure_transport_db),
	  create_table(role_treasure_transport_db, FieldList, ValueList);
create(role_venation,ValueList)->
	  FieldList = record_info(fields, role_venation),
	  create_table(role_venation, FieldList, ValueList);
create(role_venation_advanced,ValueList)->
	  FieldList = record_info(fields, role_venation_advanced),
	  create_table(role_venation_advanced, FieldList, ValueList);

create(role_welfare_activity_info,ValueList)->
	  FieldList = record_info(fields, role_welfare_activity_info),
	  create_table(role_welfare_activity_info, FieldList, ValueList);
create(tangle_battle,ValueList)->
	  FieldList = record_info(fields, tangle_battle),
	  create_table(tangle_battle, FieldList, ValueList);
create(tangle_battle_kill_info,ValueList)->
	  FieldList = record_info(fields, tangle_battle_kill_info),
	  create_table(tangle_battle_kill_info, FieldList, ValueList);
create(vip_role,ValueList)->
	  FieldList = record_info(fields, vip_role),
	  create_table(vip_role, FieldList, ValueList);
create(yhzq_battle_record,ValueList)->
	  FieldList = record_info(fields, yhzq_battle_record),
	  create_table(yhzq_battle_record, FieldList, ValueList);
create(player_option,ValueList)->
	  FieldList = record_info(fields, player_option),
	  create_table(player_option, FieldList, ValueList);
create(playeritems,ValueList)->
	  FieldList = record_info(fields, playeritems),
	  create_table(playeritems, FieldList, ValueList);
create(pets,ValueList)->
	  FieldList = record_info(fields, pets),
	  create_table(pets, FieldList, ValueList);
create(quest_role,ValueList)->
	  FieldList = record_info(fields, quest_role),
	  create_table(quest_role, FieldList, ValueList);

create(role_mainline,ValueList)->
	  FieldList = record_info(fields, role_mainline),
	  create_table(role_mainline, FieldList, ValueList);

create(role_quick_bar,ValueList)->
	  FieldList = record_info(fields, role_quick_bar),
	  create_table(role_quick_bar, FieldList, ValueList);

create(role_skill,ValueList)->
	  FieldList = record_info(fields, role_skill),
	  create_table(role_skill, FieldList, ValueList);

create(roleattr,ValueList)->
	  FieldList = record_info(fields, roleattr),
	  create_table(roleattr, FieldList, ValueList);

create(role_instance,ValueList)->
	  FieldList = record_info(fields, role_instance),
	  create_table(role_instance, FieldList, ValueList);
create(_,_)->
	  nothing.

create_table(TableName, FieldList, ValueList)->
	CreateSql=make_create_table_sql(FieldList,ValueList),
	Sql="create table "++lists:flatten(io_lib:write(TableName)) ++"("++CreateSql++")",
	mysql:fetch(?DB, Sql) .

make_create_table_sql(FieldList,ValueList)->
	TermInfo=lists:zip(FieldList, ValueList),
	Str=lists:foldl(fun({Key,Value},Acc)->
						StrKey=Acc++"`"++lists:flatten(io_lib:write(Key))++"`"++check_data(Value)++","
						end, "", TermInfo),
	NewStr=string:left(Str, string:len(Str)-1).

check_data(Value) when is_atom(Value)->
	" varchar(10)";
check_data(Value) when is_list(Value)->
	" varchar(256)";
check_data(Value) when is_tuple(Value)->
	" varchar(256)";
check_data(Value) when erlang:is_integer(Value)->
	" int";
check_data(Value) when erlang:is_float(Value)->
	" float";
check_data(Value) when erlang:is_binary(Value)->
	check_data(binary_to_list(Value));
check_data(Value) ->
	io:format("error   ~n",[]).

	

