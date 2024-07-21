%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-5-6
%% Description: TODO: Add description to mysql_change
-module(mysql_change).
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
create_table()->
	{ok,[Term|_]}=dal:read(role_instance_1_0),
	create_mysql_table:create_table_proto(Term).

write_term(Term)->
	 ValueList = lists:nthtail(1, tuple_to_list(Term)),
	 TableName=erlang:element(1, Term),
	 write(TableName,ValueList).

write(achieve_proto,ValueList)->
	  FieldList = record_info(fields, achieve_proto),
	  insert(achieve_proto, FieldList, ValueList);
write(achieve_fuwen,ValueList)->
	  FieldList = record_info(fields, achieve_fuwen),
	  insert(achieve_fuwen, FieldList, ValueList);
write(achieve_award,ValueList)->
	  FieldList = record_info(fields, achieve_award),
	  insert(achieve_award, FieldList, ValueList);
write(achieve,ValueList)->
	  FieldList = record_info(fields, achieve),
	  insert(achieve, FieldList, ValueList);

write(activity,ValueList)->
	  FieldList = record_info(fields, activity),
	  insert(activity, FieldList, ValueList);
write(activity_value_proto,ValueList)->
	  FieldList = record_info(fields, activity_value_proto),
	  insert(activity_value_proto, FieldList, ValueList);
write(activity_value_reward,ValueList)->
	  FieldList = record_info(fields, activity_value_reward),
	  insert(activity_value_reward, FieldList, ValueList);
write(ai_agents,ValueList)->
	  FieldList = record_info(fields, ai_agents),
	  insert(ai_agents, FieldList, ValueList);
write(achieve_award,ValueList)->
	  FieldList = record_info(fields, achieve_award),
	  insert(achieve_award, FieldList, ValueList);
write(answer,ValueList)->
	  FieldList = record_info(fields, answer),
	  insert(answer, FieldList, ValueList);
write(answer_option,ValueList)->
	  FieldList = record_info(fields, answer_option),
	  insert(answer_option, FieldList, ValueList);
write(attr_info,ValueList)->
	  FieldList = record_info(fields, attr_info),
	  insert(attr_info, FieldList, ValueList);
write(auto_name,ValueList)->
	  FieldList = record_info(fields, auto_name),
	  insert(auto_name, FieldList, ValueList);
write(back_echantment_stone,ValueList)->
	  FieldList = record_info(fields, back_echantment_stone),
	  insert(back_echantment_stone, FieldList, ValueList);
write(battlefield_proto,ValueList)->
	  FieldList = record_info(fields, battlefield_proto),
	  insert(battlefield_proto, FieldList, ValueList);
write(block_training,ValueList)->
	  FieldList = record_info(fields, block_training),
	  insert(block_training, FieldList, ValueList);
write(buffers,ValueList)->
	  FieldList = record_info(fields, buffers),
	  insert(buffers, FieldList, ValueList);
write(chat_condition,ValueList)->
	  FieldList = record_info(fields, chat_condition),
	  insert(chat_condition, FieldList, ValueList);
write(chess_spirit_config,ValueList)->
	  FieldList = record_info(fields, chess_spirit_config),
	  insert(chess_spirit_config, FieldList, ValueList);
write(chess_spirit_rewards,ValueList)->
	  FieldList = record_info(fields, chess_spirit_rewards),
	  insert(chess_spirit_rewards, FieldList, ValueList);
write(chess_spirit_section,ValueList)->
	  FieldList = record_info(fields, chess_spirit_section),
	  insert(chess_spirit_section, FieldList, ValueList);
write(christmas_activity_reward,ValueList)->
	  FieldList = record_info(fields, christmas_activity_reward),
	  insert(christmas_activity_reward, FieldList, ValueList);
write(achieve_award,ValueList)->
	  FieldList = record_info(fields, achieve_award),
	  insert(achieve_award, FieldList, ValueList);
write(christmas_tree_config,ValueList)->
	  FieldList = record_info(fields, christmas_tree_config),
	  insert(christmas_tree_config, FieldList, ValueList);
write(classbase,ValueList)->
	  FieldList = record_info(fields, classbase),
	  insert(classbase, FieldList, ValueList);
write(congratulations,ValueList)->
	  FieldList = record_info(fields, congratulations),
	  insert(congratulations, FieldList, ValueList);
write(continuous_logging_gift,ValueList)->
	  FieldList = record_info(fields, continuous_logging_gift),
	  insert(continuous_logging_gift, FieldList, ValueList);
write(country_proto,ValueList)->
	  FieldList = record_info(fields, country_proto),
	  insert(country_proto, FieldList, ValueList);
write(creature_proto,ValueList)->
	  FieldList = record_info(fields, creature_proto),
	  insert(creature_proto, FieldList, ValueList);
write(designation_data,ValueList)->
	  FieldList = record_info(fields, designation_data),
	  insert(designation_data, FieldList, ValueList);
write(dragon_fight_db,ValueList)->
	  FieldList = record_info(fields, dragon_fight_db),
	  insert(dragon_fight_db, FieldList, ValueList);
write(drop_rule,ValueList)->
	  FieldList = record_info(fields, drop_rule),
	  insert(drop_rule, FieldList, ValueList);
write(enchantments,ValueList)->
	  FieldList = record_info(fields, enchantments),
	  insert(enchantments, FieldList, ValueList);
write(enchantments_lucky,ValueList)->
	  FieldList = record_info(fields, enchantments_lucky),
	  insert(enchantments_lucky, FieldList, ValueList);
write(enchant_convert,ValueList)->
	  FieldList = record_info(fields, enchant_convert),
	  insert(enchant_convert, FieldList, ValueList);
write(enchant_opt,ValueList)->
	  FieldList = record_info(fields, enchant_opt),
	  insert(enchant_opt, FieldList, ValueList);
write(enchant_property_opt,ValueList)->
	  FieldList = record_info(fields, enchant_property_opt),
	  insert(enchant_property_opt, FieldList, ValueList);
write(equipmentset,ValueList)->
	  FieldList = record_info(fields, equipmentset),
	  insert(equipmentset, FieldList, ValueList);
write(equipment_fenjie,ValueList)->
	  FieldList = record_info(fields, equipment_fenjie),
	  insert(equipment_fenjie, FieldList, ValueList);
write(equipment_move,ValueList)->
	  FieldList = record_info(fields, equipment_move),
	  insert(equipment_move, FieldList, ValueList);
write(equipment_sysbrd,ValueList)->
	  FieldList = record_info(fields, equipment_sysbrd),
	  insert(equipment_sysbrd, FieldList, ValueList);
write(equipment_upgrade,ValueList)->
	  FieldList = record_info(fields, equipment_upgrade),
	  insert(equipment_upgrade, FieldList, ValueList);
write(everquests,ValueList)->
	  FieldList = record_info(fields, everquests),
	  insert(everquests, FieldList, ValueList);
write(faction_relations,ValueList)->
	  FieldList = record_info(fields, faction_relations),
	  insert(faction_relations, FieldList, ValueList);
write(festival_control,ValueList)->
	  FieldList = record_info(fields, festival_control),
	  insert(festival_control, FieldList, ValueList);
write(festival_recharge_gift,ValueList)->
	  FieldList = record_info(fields, festival_recharge_gift),
	  insert(festival_recharge_gift, FieldList, ValueList);
write(goals,ValueList)->
	  FieldList = record_info(fields, goals),
	  insert(goals, FieldList, ValueList);
write(guild_authorities,ValueList)->
	  FieldList = record_info(fields, guild_authorities),
	  insert(guild_authorities, FieldList, ValueList);
write(guild_auth_groups,ValueList)->
	  FieldList = record_info(fields, guild_auth_groups),
	  insert(guild_auth_groups, FieldList, ValueList);
write(guild_battle_proto,ValueList)->
	  FieldList = record_info(fields, guild_battle_proto),
	  insert(guild_battle_proto, FieldList, ValueList);
write(guild_facilities,ValueList)->
	  FieldList = record_info(fields, guild_facilities),
	  insert(guild_facilities, FieldList, ValueList);
write(guild_monster_proto,ValueList)->
	  FieldList = record_info(fields, guild_monster_proto),
	  insert(guild_monster_proto, FieldList, ValueList);
write(guild_setting,ValueList)->
	  FieldList = record_info(fields, guild_setting),
	  insert(guild_setting, FieldList, ValueList);
write(guild_shop,ValueList)->
	  FieldList = record_info(fields, guild_shop),
	  insert(guild_shop, FieldList, ValueList);
write(guild_shop_items,ValueList)->
	  FieldList = record_info(fields, guild_shop_items),
	  insert(guild_shop_items, FieldList, ValueList);
write(guild_treasure,ValueList)->
	  FieldList = record_info(fields, guild_treasure),
	  insert(guild_treasure, FieldList, ValueList);
write(guild_treasure_items,ValueList)->
	  FieldList = record_info(fields, guild_treasure_items),
	  insert(guild_treasure_items, FieldList, ValueList);
write(guild_treasure_transport_consume,ValueList)->
	  FieldList = record_info(fields, guild_treasure_transport_consume),
	  insert(guild_treasure_transport_consume, FieldList, ValueList);
write(honor_store_items,ValueList)->
	  FieldList = record_info(fields, honor_store_items),
	  insert(honor_store_items, FieldList, ValueList);
write(inlay,ValueList)->
	  FieldList = record_info(fields, inlay),
	  insert(inlay, FieldList, ValueList);
write(instance_proto,ValueList)->
	  FieldList = record_info(fields, instance_proto),
	  insert(instance_proto, FieldList, ValueList);
write(item_identify,ValueList)->
	  FieldList = record_info(fields, item_identify),
	  insert(item_identify, FieldList, ValueList);
write(item_template,ValueList)->
	  FieldList = record_info(fields, item_template),
	  insert(item_template, FieldList, ValueList);
write(jszd_rank_option,ValueList)->
	  FieldList = record_info(fields, jszd_rank_option),
	  insert(jszd_rank_option, FieldList, ValueList);
write(levelup_opt,ValueList)->
	  FieldList = record_info(fields, levelup_opt),
	  insert(levelup_opt, FieldList, ValueList);
write(level_activity_rewards_db,ValueList)->
	  FieldList = record_info(fields, level_activity_rewards_db),
	  insert(level_activity_rewards_db, FieldList, ValueList);
write(loop_instance,ValueList)->
	  FieldList = record_info(fields, loop_instance),
	  insert(loop_instance, FieldList, ValueList);
write(loop_instance_proto,ValueList)->
	  FieldList = record_info(fields, loop_instance_proto),
	  insert(loop_instance_proto, FieldList, ValueList);
write(loop_tower,ValueList)->
	  FieldList = record_info(fields, loop_tower),
	  insert(loop_tower, FieldList, ValueList);
write(lottery_counts,ValueList)->
	  FieldList = record_info(fields, lottery_counts),
	  insert(lottery_counts, FieldList, ValueList);
write(lottery_droplist,ValueList)->
	  FieldList = record_info(fields, lottery_droplist),
	  insert(lottery_droplist, FieldList, ValueList);
write(mainline_defend_config,ValueList)->
	  FieldList = record_info(fields, mainline_defend_config),
	  insert(mainline_defend_config, FieldList, ValueList);
write(mainline_proto,ValueList)->
	  FieldList = record_info(fields, mainline_proto),
	  insert(mainline_proto, FieldList, ValueList);
write(mall_item_info,ValueList)->
	  FieldList = record_info(fields, mall_item_info),
	  insert(mall_item_info, FieldList, ValueList);
write(mall_sales_item_info,ValueList)->
	  FieldList = record_info(fields, mall_sales_item_info),
	  insert(mall_sales_item_info, FieldList, ValueList);
write(map_info,ValueList)->
	  FieldList = record_info(fields, map_info),
	  insert(map_info, FieldList, ValueList);
write(npc_dragon_fight,ValueList)->
	  FieldList = record_info(fields, npc_dragon_fight),
	  insert(npc_dragon_fight, FieldList, ValueList);
write(npc_drop,ValueList)->
	  FieldList = record_info(fields, npc_drop),
	  insert(npc_drop, FieldList, ValueList);
write(npc_exchange_list,ValueList)->
	  FieldList = record_info(fields, npc_exchange_list),
	  insert(npc_exchange_list, FieldList, ValueList);
write(everquest_list,ValueList)->
	  FieldList = record_info(fields, everquest_list),
	  insert(everquest_list, FieldList, ValueList);
write(npc_sell_list,ValueList)->
	  FieldList = record_info(fields, npc_sell_list),
	  insert(npc_sell_list, FieldList, ValueList);
write(npc_trans_list,ValueList)->
	  FieldList = record_info(fields, npc_trans_list),
	  insert(npc_trans_list, FieldList, ValueList);
write(quest_npc,ValueList)->
	  FieldList = record_info(fields, quest_npc),
	  insert(quest_npc, FieldList, ValueList);
write(npc_functions,ValueList)->
	  FieldList = record_info(fields, npc_functions),
	  insert(npc_functions, FieldList, ValueList);
write(offline_everquests_exp,ValueList)->
	  FieldList = record_info(fields, offline_everquests_exp),
	  insert(offline_everquests_exp, FieldList, ValueList);
write(offline_exp,ValueList)->
	  FieldList = record_info(fields, offline_exp),
	  insert(offline_exp, FieldList, ValueList);
write(open_service_activities,ValueList)->
	  FieldList = record_info(fields, open_service_activities),
	  insert(open_service_activities, FieldList, ValueList);
write(open_service_activities_time,ValueList)->
	  FieldList = record_info(fields, open_service_activities_time),
	  insert(open_service_activities_time, FieldList, ValueList);
write(pet_evolution,ValueList)->
	  FieldList = record_info(fields, pet_evolution),
	  insert(pet_evolution, FieldList, ValueList);
write(pet_explore_gain,ValueList)->
	  FieldList = record_info(fields, pet_explore_gain),
	  insert(pet_explore_gain, FieldList, ValueList);
write(pet_explore_style,ValueList)->
	  FieldList = record_info(fields, pet_explore_style),
	  insert(pet_explore_style, FieldList, ValueList);
write(pet_growth,ValueList)->
	  FieldList = record_info(fields, pet_growth),
	  insert(pet_growth, FieldList, ValueList);
write(pet_happiness,ValueList)->
	  FieldList = record_info(fields, pet_happiness),
	  insert(pet_happiness, FieldList, ValueList);
write(pet_level,ValueList)->
	  FieldList = record_info(fields, pet_level),
	  insert(pet_level, FieldList, ValueList);
write(pet_proto,ValueList)->
	  FieldList = record_info(fields, pet_proto),
	  insert(pet_proto, FieldList, ValueList);
write(pet_quality,ValueList)->
	  FieldList = record_info(fields, pet_quality),
	  insert(pet_quality, FieldList, ValueList);
write(pet_quality_up,ValueList)->
	  FieldList = record_info(fields, pet_quality_up),
	  insert(pet_quality_up, FieldList, ValueList);
write(pet_skill_slot,ValueList)->
	  FieldList = record_info(fields, pet_skill_slot),
	  insert(pet_skill_slot, FieldList, ValueList);
write(pet_slot,ValueList)->
	  FieldList = record_info(fields, pet_slot),
	  insert(pet_slot, FieldList, ValueList);
write(pet_talent_consume,ValueList)->
	  FieldList = record_info(fields, pet_talent_consume),
	  insert(pet_talent_consume, FieldList, ValueList);
write(pet_talent_rate,ValueList)->
	  FieldList = record_info(fields, pet_talent_rate),
	  insert(pet_talent_rate, FieldList, ValueList);
write(pet_wash_attr_point,ValueList)->
	  FieldList = record_info(fields, pet_wash_attr_point),
	  insert(pet_wash_attr_point, FieldList, ValueList);
write(pet_item_mall,ValueList)->
	  FieldList = record_info(fields, pet_item_mall),
	  insert(pet_item_mall, FieldList, ValueList);
write(quests,ValueList)->
	  FieldList = record_info(fields, quests),
	  insert(quests, FieldList, ValueList);
write(refine_system,ValueList)->
	  FieldList = record_info(fields, refine_system),
	  insert(refine_system, FieldList, ValueList);
write(remove_seal,ValueList)->
	  FieldList = record_info(fields, remove_seal),
	  insert(remove_seal, FieldList, ValueList);
write(ridepet_synthesis,ValueList)->
	  FieldList = record_info(fields, ridepet_synthesis),
	  insert(ridepet_synthesis, FieldList, ValueList);
write(ride_proto_db,ValueList)->
	  FieldList = record_info(fields, ride_proto_db),
	  insert(ride_proto_db, FieldList, ValueList);
write(role_level_bonfire_effect_db,ValueList)->
	  FieldList = record_info(fields, role_level_bonfire_effect_db),
	  insert(role_level_bonfire_effect_db, FieldList, ValueList);
write(role_level_experience,ValueList)->
	  FieldList = record_info(fields, role_level_experience),
	  insert(role_level_experience, FieldList, ValueList);
write(role_level_sitdown_effect_db,ValueList)->
	  FieldList = record_info(fields, role_level_sitdown_effect_db),
	  insert(role_level_sitdown_effect_db, FieldList, ValueList);
write(role_level_soulpower,ValueList)->
	  FieldList = record_info(fields, role_level_soulpower),
	  insert(role_level_soulpower, FieldList, ValueList);
write(role_petnum,ValueList)->
	  FieldList = record_info(fields, role_petnum),
	  insert(role_petnum, FieldList, ValueList);
write(series_kill,ValueList)->
	  FieldList = record_info(fields, series_kill),
	  insert(series_kill, FieldList, ValueList);
write(skills,ValueList)->
	  FieldList = record_info(fields, skills),
	  insert(skills, FieldList, ValueList);
write(sock,ValueList)->
	  FieldList = record_info(fields, sock),
	  insert(sock, FieldList, ValueList);
write(spa_exp,ValueList)->
	  FieldList = record_info(fields, spa_exp),
	  insert(spa_exp, FieldList, ValueList);
write(spa_option,ValueList)->
	  FieldList = record_info(fields, spa_option),
	  insert(spa_option, FieldList, ValueList);
write(stonemix,ValueList)->
	  FieldList = record_info(fields, stonemix),
	  insert(stonemix, FieldList, ValueList);
write(system_chat,ValueList)->
	  FieldList = record_info(fields, system_chat),
	  insert(system_chat, FieldList, ValueList);
write(tangle_reward_info,ValueList)->
	  FieldList = record_info(fields, tangle_reward_info),
	  insert(tangle_reward_info, FieldList, ValueList);
write(template_itemproto,ValueList)->
	  FieldList = record_info(fields, template_itemproto),
	  insert(template_itemproto, FieldList, ValueList);
write(timelimit_gift,ValueList)->
	  FieldList = record_info(fields, timelimit_gift),
	  insert(timelimit_gift, FieldList, ValueList);
write(transports,ValueList)->
	  FieldList = record_info(fields, transports),
	  insert(transports, FieldList, ValueList);
write(transport_channel,ValueList)->
	  FieldList = record_info(fields, transport_channel),
	  insert(transport_channel, FieldList, ValueList);
write(treasure_chest_drop,ValueList)->
	  FieldList = record_info(fields, treasure_chest_drop),
	  insert(treasure_chest_drop, FieldList, ValueList);
write(treasure_chest_rate,ValueList)->
	  FieldList = record_info(fields, treasure_chest_rate),
	  insert(treasure_chest_rate, FieldList, ValueList);
write(treasure_chest_times,ValueList)->
	  FieldList = record_info(fields, treasure_chest_times),
	  insert(treasure_chest_times, FieldList, ValueList);
write(treasure_chest_type,ValueList)->
	  FieldList = record_info(fields, treasure_chest_type),
	  insert(treasure_chest_type, FieldList, ValueList);
write(treasure_spawns,ValueList)->
	  FieldList = record_info(fields, treasure_spawns),
	  insert(treasure_spawns, FieldList, ValueList);
write(treasure_transport,ValueList)->
	  FieldList = record_info(fields, treasure_transport),
	  insert(treasure_transport, FieldList, ValueList);
write(treasure_transport_quality_bonus,ValueList)->
	  FieldList = record_info(fields, treasure_transport_quality_bonus),
	  insert(treasure_transport_quality_bonus, FieldList, ValueList);
write(venation_advanced,ValueList)->
	  FieldList = record_info(fields, venation_advanced),
	  insert(venation_advanced, FieldList, ValueList);
write(venation_exp_proto,ValueList)->
	  FieldList = record_info(fields, venation_exp_proto),
	  insert(venation_exp_proto, FieldList, ValueList);
write(venation_item_rate,ValueList)->
	  FieldList = record_info(fields, venation_item_rate),
	  insert(venation_item_rate, FieldList, ValueList);
write(venation_point_proto,ValueList)->
	  FieldList = record_info(fields, venation_point_proto),
	  insert(venation_point_proto, FieldList, ValueList);
write(venation_proto,ValueList)->
	  FieldList = record_info(fields, venation_proto),
	  insert(venation_proto, FieldList, ValueList);
write(vip_level,ValueList)->
	  FieldList = record_info(fields, vip_level),
	  insert(vip_level, FieldList, ValueList);
write(welfare_activity_data,ValueList)->
	  FieldList = record_info(fields, welfare_activity_data),
	  insert(welfare_activity_data, FieldList, ValueList);
write(yhzq_battle,ValueList)->
	  FieldList = record_info(fields, yhzq_battle),
	  insert(yhzq_battle, FieldList, ValueList);
write(yhzq_winner_raward,ValueList)->
	  FieldList = record_info(fields, yhzq_winner_raward),
	  insert(yhzq_winner_raward, FieldList, ValueList);
write(creature_spawns,ValueList)->
	  FieldList = record_info(fields, creature_spawns),
	  insert(creature_spawns, FieldList, ValueList);
write(template_roleattr,ValueList)->
	  FieldList = record_info(fields, roleattr),
	  insert(template_roleattr, FieldList, ValueList);
write(template_role_quick_bar,ValueList)->
	  FieldList = record_info(fields, role_quick_bar),
	  insert(template_role_quick_bar, FieldList, ValueList);
write(template_role_skill,ValueList)->
	  FieldList = record_info(fields, role_skill),
	  insert(template_role_skill, FieldList, ValueList);
write(template_quest_role,ValueList)->
	  FieldList = record_info(fields, quest_role),
	  insert(template_quest_role, FieldList, ValueList);
write(instance_quality_proto,ValueList)->
	  FieldList = record_info(fields, instance_quality_proto),
	  insert(instance_quality_proto, FieldList, ValueList);
write(pet_skill_template,ValueList)->
	  FieldList = record_info(fields, pet_skill_template),
	  insert(pet_skill_template, FieldList, ValueList);
write(pet_skill_proto,ValueList)->
	  FieldList = record_info(fields, pet_skill_proto),
	  insert(pet_skill_proto, FieldList, ValueList);
write(instance_entrust,ValueList)->
	  FieldList = record_info(fields, instance_entrust),
	  insert(instance_entrust, FieldList, ValueList);
write(activity_test01,ValueList)->
	  FieldList = record_info(fields, activity_test01),
	  insert(activity_test01, FieldList, ValueList);
write(pet_attr_transform,ValueList)->
	  FieldList = record_info(fields, pet_attr_transform),
	  insert(pet_attr_transform, FieldList, ValueList);
write(pet_up_growth,ValueList)->
	  FieldList = record_info(fields, pet_up_growth),
	  insert(pet_up_growth, FieldList, ValueList);
write(stonemix_rateinfo,ValueList)->
	  FieldList = record_info(fields, stonemix_rateinfo),
	  insert(stonemix_rateinfo, FieldList, ValueList);
write(pet_skill_book_rate,ValueList)->
	  FieldList = record_info(fields, pet_skill_book_rate),
	  insert(pet_skill_book_rate, FieldList, ValueList);
write(pet_skill_book,ValueList)->
	  FieldList = record_info(fields, pet_skill_book),
	  insert(pet_skill_book, FieldList, ValueList);
write(pet_fresh_skill,ValueList)->
	  FieldList = record_info(fields, pet_fresh_skill),
	  insert(pet_fresh_skill, FieldList, ValueList);
write(pet_base_attr,ValueList)->
	  FieldList = record_info(fields, pet_base_attr),
	  insert(pet_base_attr, FieldList, ValueList);
write(pet_xisui_rate,ValueList)->
	  FieldList = record_info(fields, pet_xisui_rate),
	  insert(pet_xisui_rate, FieldList, ValueList);
write(pet_talent_item,ValueList)->
	  FieldList = record_info(fields, pet_talent_item),
	  insert(pet_talent_item, FieldList, ValueList);
write(pet_talent_proto,ValueList)->
	  FieldList = record_info(fields, pet_talent_proto),
	  insert(pet_talent_proto, FieldList, ValueList);
write(pet_talent_template,ValueList)->
	  FieldList = record_info(fields, pet_talent_template),
	  insert(pet_talent_template, FieldList, ValueList);
write(pet_advance,ValueList)->
	  FieldList = record_info(fields, pet_advance),
	  insert(pet_advance, FieldList, ValueList);
write(pet_advance_lucky,ValueList)->
	  FieldList = record_info(fields, pet_advance_lucky),
	  insert(pet_advance_lucky, FieldList, ValueList);
write(wing_level,ValueList)->
	  FieldList = record_info(fields, wing_level),
	  insert(wing_level, FieldList, ValueList);
write(wing_phase,ValueList)->
	  FieldList = record_info(fields, wing_phase),
	  insert(wing_phase, FieldList, ValueList);
write(wing_intensify_up,ValueList)->
	  FieldList = record_info(fields, wing_intensify_up),
	  insert(wing_intensify_up, FieldList, ValueList);
write(wing_quality,ValueList)->
	  FieldList = record_info(fields, wing_quality),
	  insert(wing_quality, FieldList, ValueList);
write(wing_skill,ValueList)->
	  FieldList = record_info(fields, wing_skill),
	  insert(wing_skill, FieldList, ValueList);
write(item_gold_price,ValueList)->
	  FieldList = record_info(fields, item_gold_price),
	  insert(item_gold_price, FieldList, ValueList);
write(wing_echant,ValueList)->
	  FieldList = record_info(fields, wing_echant),
	  insert(wing_echant, FieldList, ValueList);
write(wing_echant_lock,ValueList)->
	  FieldList = record_info(fields, wing_echant_lock),
	  insert(wing_echant_lock, FieldList, ValueList);
write(charge_package_proto,ValueList)->
	  FieldList = record_info(fields, charge_package_proto),
	  insert(charge_package_proto, FieldList, ValueList);
write(item_can_used,ValueList)->
	  FieldList = record_info(fields, item_can_used),
	  insert(item_can_used, FieldList, ValueList);

write(account,ValueList)->
	  FieldList = record_info(fields, account),
	  insert(account, FieldList, ValueList);



write(_,_)->
	  nothing.

insert(TableName, FieldList, ValueList)->
Sql =make_insert_sql(TableName, FieldList, ValueList),
execute(Sql).


make_insert_sql(Table_name, FieldList, ValueList) ->
    L = mysql_db_tool:make_conn_sql(FieldList, ValueList, []),
    lists:concat(["insert into `", Table_name, "` set ", L]).

execute(Sql) ->
    case mysql:fetch(?DB, Sql) of
        {updated, {_, _, _, R, _}} -> R;
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.

mysql_halt([Sql, Reason]) ->
    catch erlang:error({db_error, [Sql, Reason]}).
