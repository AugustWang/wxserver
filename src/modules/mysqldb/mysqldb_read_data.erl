%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-6-4
%% Description: TODO: Add description to mysqldb_read_data
-module(mysqldb_read_data).

%%
%% Include files
%%
-compile(export_all).
-include("config_db_def.hrl").
-define(DB, conn).
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

read_data_from_table(TableName,Key,Pos)->
	 read(TableName,Key,Pos).

read(achieve_proto,Key,Pos)->
	  FieldList= record_info(fields, achieve_proto),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(achieve_proto,KeyInfo);
read(achieve_fuwen,Key,Pos)->
	  FieldList = record_info(fields, achieve_fuwen),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(achieve_fuwen, KeyInfo);
read(achieve_award,Key,Pos)->
	  FieldList = record_info(fields, achieve_award),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(achieve_award, KeyInfo);
read(achieve,Key,Pos)->
	  FieldList= record_info(fields, achieve),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(achieve,KeyInfo);

read(activity,Key,Pos)->
	  FieldList= record_info(fields, activity),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(activity,KeyInfo);
read(activity_value_proto,Key,Pos)->
	  FieldList= record_info(fields, activity_value_proto),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(activity_value_proto,KeyInfo);
read(activity_value_reward,Key,Pos)->
	  FieldList= record_info(fields, activity_value_reward),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(activity_value_reward, KeyInfo);
read(ai_agents,Key,Pos)->
	  FieldList= record_info(fields, ai_agents),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(ai_agents, KeyInfo);
read(achieve_award,Key,Pos)->
	  FieldList = record_info(fields, achieve_award),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(achieve_award, KeyInfo);
read(answer,Key,Pos)->
	  FieldList = record_info(fields, answer),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(answer,KeyInfo);
read(answer_option,Key,Pos)->
	  FieldList = record_info(fields, answer_option),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(answer_option,KeyInfo);
read(attr_info,Key,Pos)->
	  FieldList = record_info(fields, attr_info),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(attr_info, KeyInfo);
read(auto_name,Key,Pos)->
	  FieldList= record_info(fields, auto_name),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(auto_name,KeyInfo);
read(back_echantment_stone,Key,Pos)->
	  FieldList = record_info(fields, back_echantment_stone),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(back_echantment_stone,KeyInfo);
read(battlefield_proto,Key,Pos)->
	  FieldList = record_info(fields, battlefield_proto),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(battlefield_proto, KeyInfo);
read(block_training,Key,Pos)->
	  FieldList = record_info(fields, block_training),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(block_training,KeyInfo);
read(buffers,Key,Pos)->
	  FieldList = record_info(fields, buffers),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(buffers, KeyInfo);
read(chat_condition,Key,Pos)->
	  FieldList = record_info(fields, chat_condition),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(chat_condition, KeyInfo);
read(chess_spirit_config,Key,Pos)->
	  FieldList = record_info(fields, chess_spirit_config),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(chess_spirit_config, KeyInfo);
read(chess_spirit_rewards,Key,Pos)->
	  FieldList = record_info(fields, chess_spirit_rewards),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(chess_spirit_rewards, KeyInfo);
read(chess_spirit_section,Key,Pos)->
	  FieldList = record_info(fields, chess_spirit_section),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(chess_spirit_section,KeyInfo);
read(christmas_activity_reward,Key,Pos)->
	  FieldList = record_info(fields, christmas_activity_reward),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(christmas_activity_reward,KeyInfo);
read(achieve_award,Key,Pos)->
	  FieldList = record_info(fields, achieve_award),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(achieve_award, KeyInfo);
read(christmas_tree_config,Key,Pos)->
	  FieldList = record_info(fields, christmas_tree_config),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(christmas_tree_config,KeyInfo);
read(classbase,Key,Pos)->
	  FieldList = record_info(fields, classbase),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(classbase, KeyInfo);
read(congratulations,Key,Pos)->
	  FieldList = record_info(fields, congratulations),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(congratulations, KeyInfo);
read(continuous_logging_gift,Key,Pos)->
	  FieldList = record_info(fields, continuous_logging_gift),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(continuous_logging_gift,KeyInfo);
read(country_proto,Key,Pos)->
	  FieldList = record_info(fields, country_proto),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(country_proto,KeyInfo);
read(creature_proto,Key,Pos)->
	  FieldList = record_info(fields, creature_proto),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(creature_proto,KeyInfo);
read(designation_data,Key,Pos)->
	  FieldList = record_info(fields, designation_data),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(designation_data, KeyInfo);
read(dragon_fight_db,Key,Pos)->
	  FieldList = record_info(fields, dragon_fight_db),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(dragon_fight_db, KeyInfo);
read(drop_rule,Key,Pos)->
	  FieldList = record_info(fields, drop_rule),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(drop_rule, KeyInfo);
read(enchantments,Key,Pos)->
	  FieldList = record_info(fields, enchantments),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(enchantments, KeyInfo);
read(enchantments_lucky,Key,Pos)->
	  FieldList = record_info(fields, enchantments_lucky),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(enchantments_lucky, KeyInfo);
read(enchant_convert,Key,Pos)->
	  FieldList = record_info(fields, enchant_convert),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(enchant_convert, KeyInfo);
read(enchant_opt,Key,Pos)->
	  FieldList = record_info(fields, enchant_opt),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(enchant_opt, KeyInfo);
read(enchant_property_opt,Key,Pos)->
	  FieldList = record_info(fields, enchant_property_opt),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(enchant_property_opt, KeyInfo);
read(equipmentset,Key,Pos)->
	  FieldList = record_info(fields, equipmentset),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(equipmentset,KeyInfo);
read(equipment_fenjie,Key,Pos)->
	  FieldList = record_info(fields, equipment_fenjie),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(equipment_fenjie, KeyInfo);
read(equipment_move,Key,Pos)->
	  FieldList = record_info(fields, equipment_move),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(equipment_move,KeyInfo);
read(equipment_sysbrd,Key,Pos)->
	  FieldList = record_info(fields, equipment_sysbrd),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(equipment_sysbrd, KeyInfo);
read(equipment_upgrade,Key,Pos)->
	  FieldList = record_info(fields, equipment_upgrade),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(equipment_upgrade, KeyInfo);
read(everquests,Key,Pos)->
	  FieldList = record_info(fields, everquests),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(everquests, KeyInfo);
read(faction_relations,Key,Pos)->
	  FieldList = record_info(fields, faction_relations),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(faction_relations, KeyInfo);
read(festival_control,Key,Pos)->
	  FieldList = record_info(fields, festival_control),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(festival_control, KeyInfo);
read(festival_recharge_gift,Key,Pos)->
	  FieldList = record_info(fields, festival_recharge_gift),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(festival_recharge_gift, KeyInfo);
read(goals,Key,Pos)->
	  FieldList = record_info(fields, goals),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(goals, KeyInfo);
read(guild_authorities,Key,Pos)->
	  FieldList = record_info(fields, guild_authorities),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(guild_authorities, KeyInfo);
read(guild_auth_groups,Key,Pos)->
	  FieldList = record_info(fields, guild_auth_groups),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(guild_auth_groups, KeyInfo);
read(guild_battle_proto,Key,Pos)->
	  FieldList = record_info(fields, guild_battle_proto),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(guild_battle_proto, KeyInfo);
read(guild_facilities,Key,Pos)->
	  FieldList = record_info(fields, guild_facilities),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(guild_facilities, KeyInfo);
read(guild_monster_proto,Key,Pos)->
	  FieldList = record_info(fields, guild_monster_proto),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(guild_monster_proto, KeyInfo);
read(guild_setting,Key,Pos)->
	  FieldList = record_info(fields, guild_setting),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(guild_setting, KeyInfo);
read(guild_shop,Key,Pos)->
	  FieldList = record_info(fields, guild_shop),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(guild_shop, KeyInfo);
read(guild_shop_items,Key,Pos)->
	  FieldList = record_info(fields, guild_shop_items),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(guild_shop_items, KeyInfo);
read(guild_treasure,Key,Pos)->
	  FieldList = record_info(fields, guild_treasure),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(guild_treasure, KeyInfo);
read(guild_treasure_items,Key,Pos)->
	  FieldList = record_info(fields, guild_treasure_items),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(guild_treasure_items, KeyInfo);
read(guild_treasure_transport_consume,Key,Pos)->
	  FieldList = record_info(fields, guild_treasure_transport_consume),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(guild_treasure_transport_consume, KeyInfo);
read(honor_store_items,Key,Pos)->
	  FieldList = record_info(fields, honor_store_items),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(honor_store_items, KeyInfo);
read(inlay,Key,Pos)->
	  FieldList = record_info(fields, inlay),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(inlay, KeyInfo);
read(instance_proto,Key,Pos)->
	  FieldList = record_info(fields, instance_proto),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(instance_proto, KeyInfo);
read(item_identify,Key,Pos)->
	  FieldList = record_info(fields, item_identify),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(item_identify, KeyInfo);
read(item_template,Key,Pos)->
	  FieldList = record_info(fields, item_template),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(item_template, KeyInfo);
read(jszd_rank_option,Key,Pos)->
	  FieldList = record_info(fields, jszd_rank_option),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(jszd_rank_option, KeyInfo);
read(levelup_opt,Key,Pos)->
	  FieldList = record_info(fields, levelup_opt),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(levelup_opt, KeyInfo);
read(level_activity_rewards_db,Key,Pos)->
	  FieldList = record_info(fields, level_activity_rewards_db),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(level_activity_rewards_db, KeyInfo);
read(loop_instance,Key,Pos)->
	  FieldList = record_info(fields, loop_instance),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(loop_instance, KeyInfo);
read(loop_instance_proto,Key,Pos)->
	  FieldList = record_info(fields, loop_instance_proto),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(loop_instance_proto, KeyInfo);
read(loop_tower,Key,Pos)->
	  FieldList = record_info(fields, loop_tower),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(loop_tower, KeyInfo);
read(lottery_counts,Key,Pos)->
	  FieldList = record_info(fields, lottery_counts),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(lottery_counts, KeyInfo);
read(lottery_droplist,Key,Pos)->
	  FieldList = record_info(fields, lottery_droplist),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(lottery_droplist, KeyInfo);
read(mainline_defend_config,Key,Pos)->
	  FieldList = record_info(fields, mainline_defend_config),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(mainline_defend_config, KeyInfo);
read(mainline_proto,Key,Pos)->
	  FieldList = record_info(fields, mainline_proto),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(mainline_proto, KeyInfo);
read(mall_item_info,Key,Pos)->
	  FieldList = record_info(fields, mall_item_info),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(mall_item_info, KeyInfo);
read(mall_sales_item_info,Key,Pos)->
	  FieldList = record_info(fields, mall_sales_item_info),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(mall_sales_item_info, KeyInfo);
read(map_info,Key,Pos)->
	  FieldList = record_info(fields, map_info),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(map_info, KeyInfo);
read(npc_dragon_fight,Key,Pos)->
	  FieldList = record_info(fields, npc_dragon_fight),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(npc_dragon_fight, KeyInfo);
read(npc_drop,Key,Pos)->
	  FieldList = record_info(fields, npc_drop),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(npc_drop, KeyInfo);
read(npc_exchange_list,Key,Pos)->
	  FieldList = record_info(fields, npc_exchange_list),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(npc_exchange_list, KeyInfo);
read(everquest_list,Key,Pos)->
	  FieldList = record_info(fields, everquest_list),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(everquest_list, KeyInfo);
read(npc_sell_list,Key,Pos)->
	  FieldList = record_info(fields, npc_sell_list),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(npc_sell_list, KeyInfo);
read(npc_trans_list,Key,Pos)->
	  FieldList = record_info(fields, npc_trans_list),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(npc_trans_list, KeyInfo);
read(quest_npc,Key,Pos)->
	  FieldList = record_info(fields, quest_npc),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(quest_npc, KeyInfo);
read(npc_functions,Key,Pos)->
	  FieldList = record_info(fields, npc_functions),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(npc_functions, KeyInfo);
read(offline_everquests_exp,Key,Pos)->
	  FieldList = record_info(fields, offline_everquests_exp),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(offline_everquests_exp, KeyInfo);
read(offline_exp,Key,Pos)->
	  FieldList = record_info(fields, offline_exp),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(offline_exp, KeyInfo);
read(open_service_activities,Key,Pos)->
	  FieldList = record_info(fields, open_service_activities),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(open_service_activities, KeyInfo);
read(open_service_activities_time,Key,Pos)->
	  FieldList = record_info(fields, open_service_activities_time),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(open_service_activities_time, KeyInfo);
read(pet_evolution,Key,Pos)->
	  FieldList = record_info(fields, pet_evolution),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_evolution, KeyInfo);
read(pet_explore_gain,Key,Pos)->
	  FieldList = record_info(fields, pet_explore_gain),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_explore_gain, KeyInfo);
read(pet_explore_style,Key,Pos)->
	  FieldList = record_info(fields, pet_explore_style),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_explore_style, KeyInfo);
read(pet_growth,Key,Pos)->
	  FieldList = record_info(fields, pet_growth),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_growth, KeyInfo);
read(pet_happiness,Key,Pos)->
	  FieldList = record_info(fields, pet_happiness),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_happiness, KeyInfo);
read(pet_level,Key,Pos)->
	  FieldList = record_info(fields, pet_level),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_level, KeyInfo);
read(pet_proto,Key,Pos)->
	  FieldList = record_info(fields, pet_proto),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_proto, KeyInfo);
read(pet_quality,Key,Pos)->
	  FieldList = record_info(fields, pet_quality),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_quality, KeyInfo);
read(pet_quality_up,Key,Pos)->
	  FieldList = record_info(fields, pet_quality_up),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_quality_up, KeyInfo);
read(pet_skill_slot,Key,Pos)->
	  FieldList = record_info(fields, pet_skill_slot),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_skill_slot, KeyInfo);
read(pet_slot,Key,Pos)->
	  FieldList = record_info(fields, pet_slot),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_slot, KeyInfo);
read(pet_talent_consume,Key,Pos)->
	  FieldList = record_info(fields, pet_talent_consume),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_talent_consume, KeyInfo);
read(pet_talent_rate,Key,Pos)->
	  FieldList = record_info(fields, pet_talent_rate),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_talent_rate, KeyInfo);
read(pet_wash_attr_point,Key,Pos)->
	  FieldList = record_info(fields, pet_wash_attr_point),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_wash_attr_point, KeyInfo);
read(pet_item_mall,Key,Pos)->
	  FieldList = record_info(fields, pet_item_mall),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_item_mall, KeyInfo);
read(quests,Key,Pos)->
	  FieldList = record_info(fields, quests),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(quests, KeyInfo);
read(refine_system,Key,Pos)->
	  FieldList = record_info(fields, refine_system),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(refine_system, KeyInfo);
read(remove_seal,Key,Pos)->
	  FieldList = record_info(fields, remove_seal),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(remove_seal, KeyInfo);
read(ridepet_synthesis,Key,Pos)->
	  FieldList = record_info(fields, ridepet_synthesis),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(ridepet_synthesis, KeyInfo);
read(ride_proto_db,Key,Pos)->
	  FieldList = record_info(fields, ride_proto_db),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(ride_proto_db, KeyInfo);
read(role_level_bonfire_effect_db,Key,Pos)->
	  FieldList = record_info(fields, role_level_bonfire_effect_db),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(role_level_bonfire_effect_db, KeyInfo);
read(role_level_experience,Key,Pos)->
	  FieldList = record_info(fields, role_level_experience),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(role_level_experience, KeyInfo);
read(role_level_sitdown_effect_db,Key,Pos)->
	  FieldList = record_info(fields, role_level_sitdown_effect_db),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(role_level_sitdown_effect_db, KeyInfo);
read(role_level_soulpower,Key,Pos)->
	  FieldList = record_info(fields, role_level_soulpower),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(role_level_soulpower, KeyInfo);
read(role_petnum,Key,Pos)->
	  FieldList = record_info(fields, role_petnum),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(role_petnum, KeyInfo);
read(series_kill,Key,Pos)->
	  FieldList = record_info(fields, series_kill),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(series_kill, KeyInfo);
read(skills,Key,Pos)->
	  FieldList = record_info(fields, skills),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(skills, KeyInfo);
read(sock,Key,Pos)->
	  FieldList = record_info(fields, sock),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(sock, KeyInfo);
read(spa_exp,Key,Pos)->
	  FieldList = record_info(fields, spa_exp),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(spa_exp, KeyInfo);
read(spa_option,Key,Pos)->
	  FieldList = record_info(fields, spa_option),
      KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(spa_option, KeyInfo);
read(stonemix,Key,Pos)->
	  FieldList = record_info(fields, stonemix),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(stonemix, KeyInfo);
read(system_chat,Key,Pos)->
	  FieldList = record_info(fields, system_chat),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(system_chat, KeyInfo);
read(tangle_reward_info,Key,Pos)->
	  FieldList = record_info(fields, tangle_reward_info),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(tangle_reward_info, KeyInfo);
read(template_itemproto,Key,Pos)->
	  FieldList = record_info(fields, template_itemproto),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(template_itemproto, KeyInfo);
read(timelimit_gift,Key,Pos)->
	  FieldList = record_info(fields, timelimit_gift),
  	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(timelimit_gift, KeyInfo);
read(transports,Key,Pos)->
	  FieldList = record_info(fields, transports),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(transports, KeyInfo);
read(transport_channel,Key,Pos)->
	  FieldList = record_info(fields, transport_channel),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(transport_channel, KeyInfo);
read(treasure_chest_drop,Key,Pos)->
	  FieldList = record_info(fields, treasure_chest_drop),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(treasure_chest_drop, KeyInfo);
read(treasure_chest_rate,Key,Pos)->
	  FieldList = record_info(fields, treasure_chest_rate),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(treasure_chest_rate, KeyInfo);
read(treasure_chest_times,Key,Pos)->
	  FieldList = record_info(fields, treasure_chest_times),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(treasure_chest_times, KeyInfo);
read(treasure_chest_type,Key,Pos)->
	  FieldList = record_info(fields, treasure_chest_type),
  	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(treasure_chest_type, KeyInfo);
read(treasure_spawns,Key,Pos)->
	  FieldList = record_info(fields, treasure_spawns),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(treasure_spawns, KeyInfo);
read(treasure_transport,Key,Pos)->
	  FieldList = record_info(fields, treasure_transport),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(treasure_transport, KeyInfo);
read(treasure_transport_quality_bonus,Key,Pos)->
	  FieldList = record_info(fields, treasure_transport_quality_bonus),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(treasure_transport_quality_bonus, KeyInfo);
read(venation_advanced,Key,Pos)->
	  FieldList = record_info(fields, venation_advanced),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(venation_advanced, KeyInfo);
read(venation_exp_proto,Key,Pos)->
	  FieldList = record_info(fields, venation_exp_proto),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(venation_exp_proto, KeyInfo);
read(venation_item_rate,Key,Pos)->
	  FieldList = record_info(fields, venation_item_rate),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(venation_item_rate, KeyInfo);
read(venation_point_proto,Key,Pos)->
	  FieldList = record_info(fields, venation_point_proto),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(venation_point_proto, KeyInfo);
read(venation_proto,Key,Pos)->
	  FieldList = record_info(fields, venation_proto),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(venation_proto, KeyInfo);
read(vip_level,Key,Pos)->
	  FieldList = record_info(fields, vip_level),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(vip_level, KeyInfo);
read(welfare_activity_data,Key,Pos)->
	  FieldList = record_info(fields, welfare_activity_data),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(welfare_activity_data, KeyInfo);
read(yhzq_battle,Key,Pos)->
	  FieldList = record_info(fields, yhzq_battle),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(yhzq_battle, KeyInfo);
read(yhzq_winner_raward,Key,Pos)->
	  FieldList = record_info(fields, yhzq_winner_raward),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(yhzq_winner_raward, KeyInfo);
read(creature_spawns,Key,Pos)->
	  FieldList = record_info(fields, creature_spawns),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(creature_spawns, KeyInfo);
read(template_roleattr,Key,Pos)->
	  FieldList = record_info(fields, roleattr),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(template_roleattr, KeyInfo);
read(template_role_quick_bar,Key,Pos)->
	  FieldList = record_info(fields, role_quick_bar),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(template_role_quick_bar, KeyInfo);
read(template_role_skill,Key,Pos)->
	  FieldList = record_info(fields, role_skill),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(template_role_skill, KeyInfo);
read(template_quest_role,Key,Pos)->
	  FieldList = record_info(fields, quest_role),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(template_quest_role, KeyInfo);
read(instance_quality_proto,Key,Pos)->
	  FieldList = record_info(fields, instance_quality_proto),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(instance_quality_proto, KeyInfo);
read(pet_skill_template,Key,Pos)->
	  FieldList = record_info(fields, pet_skill_template),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_skill_template, KeyInfo);
read(pet_skill_proto,Key,Pos)->
	  FieldList = record_info(fields, pet_skill_proto),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_skill_proto, KeyInfo);
read(instance_entrust,Key,Pos)->
	  FieldList = record_info(fields, instance_entrust),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(instance_entrust, KeyInfo);
read(activity_test01,Key,Pos)->
	  FieldList = record_info(fields, activity_test01),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(activity_test01, KeyInfo);
read(pet_attr_transform,Key,Pos)->
	  FieldList = record_info(fields, pet_attr_transform),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_attr_transform, KeyInfo);
read(pet_up_growth,Key,Pos)->
	  FieldList = record_info(fields, pet_up_growth),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_up_growth, KeyInfo);
read(stonemix_rateinfo,Key,Pos)->
	  FieldList = record_info(fields, stonemix_rateinfo),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(stonemix_rateinfo, KeyInfo);
read(pet_skill_book_rate,Key,Pos)->
	  FieldList = record_info(fields, pet_skill_book_rate),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_skill_book_rate, KeyInfo);
read(pet_skill_book,Key,Pos)->
	  FieldList = record_info(fields, pet_skill_book),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_skill_book, KeyInfo);
read(pet_fresh_skill,Key,Pos)->
	  FieldList = record_info(fields, pet_fresh_skill),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_fresh_skill, KeyInfo);
read(pet_base_attr,Key,Pos)->
	  FieldList = record_info(fields, pet_base_attr),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_base_attr, KeyInfo);
read(pet_xisui_rate,Key,Pos)->
	  FieldList = record_info(fields, pet_xisui_rate),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_xisui_rate, KeyInfo);
read(pet_talent_item,Key,Pos)->
	  FieldList = record_info(fields, pet_talent_item),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_talent_item, KeyInfo);
read(pet_talent_proto,Key,Pos)->
	  FieldList = record_info(fields, pet_talent_proto),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_talent_proto, KeyInfo);
read(pet_talent_template,Key,Pos)->
	  FieldList = record_info(fields, pet_talent_template),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_talent_template, KeyInfo);
read(pet_advance,Key,Pos)->
	  FieldList = record_info(fields, pet_advance),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_advance, KeyInfo);
read(pet_advance_lucky,Key,Pos)->
	  FieldList = record_info(fields, pet_advance_lucky),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(pet_advance_lucky, KeyInfo);
read(wing_level,Key,Pos)->
	  FieldList = record_info(fields, wing_level),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(wing_level, KeyInfo);
read(wing_phase,Key,Pos)->
	  FieldList = record_info(fields, wing_phase),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(wing_phase, KeyInfo);
read(wing_intensify_up,Key,Pos)->
	  FieldList = record_info(fields, wing_intensify_up),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(wing_intensify_up, KeyInfo);
read(wing_quality,Key,Pos)->
	  FieldList = record_info(fields, wing_quality),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(wing_quality, KeyInfo);
read(wing_skill,Key,Pos)->
	  FieldList = record_info(fields, wing_skill),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(wing_skill, KeyInfo);
read(item_gold_price,Key,Pos)->
	  FieldList = record_info(fields, item_gold_price),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(item_gold_price, KeyInfo);
read(wing_echant,Key,Pos)->
	  FieldList = record_info(fields, wing_echant),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(wing_echant, KeyInfo);
read(wing_echant_lock,Key,Pos)->
	  FieldList = record_info(fields, wing_echant_lock),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(wing_echant_lock, KeyInfo);
read(charge_package_proto,Key,Pos)->
	  FieldList = record_info(fields, charge_package_proto),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(charge_package_proto, KeyInfo);
read(item_can_used,Key,Pos)->
	  FieldList = record_info(fields, item_can_used),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	  read_data(item_can_used, KeyInfo);


%%动态数据读取
read(account,Key,Pos)->
	FieldList=record_info(fields,account),
	KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(account,KeyInfo);

read(achieve_role,Key,Pos)->
	FieldList=record_info(fields,achieve_role),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(achieve_role,KeyInfo);

read(activity_info_db,Key,Pos)->
	FieldList=record_info(fields,activity_info_db),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(activity_info_db,KeyInfo);

read(activity_test01_role,Key,Pos)->
	FieldList=record_info(fields,activity_test01_role),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(activity_test01_role,KeyInfo);

read(answer_roleinfo,Key,Pos)->
	FieldList=record_info(fields,answer_roleinfo),
	  KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(answer_roleinfo,KeyInfo);

read(auto_name_used,Key,Pos)->
	FieldList=record_info(fields,auto_name_used),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(auto_name_used,KeyInfo);

read(background_welfare_data,Key,Pos)->
	FieldList=record_info(fields,background_welfare_data),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(background_welfare_data,KeyInfo);

read(black,Key,Pos)->
	FieldList=record_info(fields,black),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(black,KeyInfo);

read(christmas_tree_db,Key,Pos)->
	FieldList=record_info(fields,christmas_tree_db),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(christmas_tree_db,KeyInfo);

read(consume,Key,Pos)->
	FieldList=record_info(fields,consume),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(consume,KeyInfo);


read(consume_return_info,Key,Pos)->
	FieldList=record_info(fields,consume_return_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(consume_return_info,KeyInfo);

read(country_record,Key,Pos)->
	FieldList=record_info(fields,country_record),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(country_record,KeyInfo);

read(enchant_extremely_property_opt,Key,Pos)->
	FieldList=record_info(fields,enchant_extremely_property_opt),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(enchant_extremely_property_opt,KeyInfo);

read(facebook_bind,Key,Pos)->
	FieldList=record_info(fields,facebook_bind),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(facebook_bind,KeyInfo);

read(fatigue,Key,Pos)->
	FieldList=record_info(fields,fatigue),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(fatigue,KeyInfo);

read(festival_recharge_gift_bg,Key,Pos)->
	FieldList=record_info(fields,festival_recharge_gift_bg),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(festival_recharge_gift_bg,KeyInfo);

read(friend,Key,Pos)->
	FieldList=record_info(fields,friend),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(friend,KeyInfo);

read(giftcards,Key,Pos)->
	FieldList=record_info(fields,giftcards),
	KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(giftcards,KeyInfo);

read(global_exp_addition_db,Key,Pos)->
	FieldList=record_info(fields,global_exp_addition_db),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(global_exp_addition_db,KeyInfo);

read(global_monster_loot_db,Key,Pos)->
	FieldList=record_info(fields,global_monster_loot_db),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(global_monster_loot_db,KeyInfo);

read(gm_blockade,Key,Pos)->
	FieldList=record_info(fields,gm_blockade),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(gm_blockade,KeyInfo);

read(gm_notice,Key,Pos)->
	FieldList=record_info(fields,gm_notice),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(gm_notice,KeyInfo);

read(goals_role,Key,Pos)->
	FieldList=record_info(fields,goals_role),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(goals_role,KeyInfo);

read(guild_baseinfo,Key,Pos)->
	FieldList=record_info(fields,guild_baseinfo),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_baseinfo,KeyInfo);

read(guild_battle_result,Key,Pos)->
	FieldList=record_info(fields,guild_battle_result),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_battle_result,KeyInfo);

read(guild_battle_score,Key,Pos)->
	FieldList=record_info(fields,guild_battle_score),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_battle_score,KeyInfo);

read(guild_events,Key,Pos)->
	FieldList=record_info(fields,guild_events),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_events,KeyInfo);

read(guild_facility_info,Key,Pos)->
	FieldList=record_info(fields,guild_facility_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_facility_info,KeyInfo);

read(guild_impeach_info,Key,Pos)->
	FieldList=record_info(fields,guild_impeach_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_impeach_info,KeyInfo);

read(guild_leave_member,Key,Pos)->
	FieldList=record_info(fields,guild_leave_member),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_leave_member,KeyInfo);

read(guild_log,Key,Pos)->
	FieldList=record_info(fields,guild_log),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_log,KeyInfo);

read(guild_member_shop,Key,Pos)->
	FieldList=record_info(fields,guild_member_shop),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_member_shop,KeyInfo);

read(guild_member_treasure,Key,Pos)->
	FieldList=record_info(fields,guild_member_treasure),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_member_treasure,KeyInfo);

read(guild_member,Key,Pos)->
	FieldList=record_info(fields,guild_member),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_member,KeyInfo);

read(guild_right_limit,Key,Pos)->
	FieldList=record_info(fields,guild_right_limit),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_right_limit,KeyInfo);

read(guild_treasure_price,Key,Pos)->
	FieldList=record_info(fields,guild_treasure_price),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_treasure_price,KeyInfo);

read(guilditems,Key,Pos)->
	FieldList=record_info(fields,guilditems),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guilditems,KeyInfo);

read(guildpackage_apply,Key,Pos)->
	FieldList=record_info(fields,guildpackage_apply),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guildpackage_apply,KeyInfo);

read(idmax,Key,Pos)->
	FieldList=record_info(fields,idmax),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(idmax,KeyInfo);

read(jszd_role_score_honor,Key,Pos)->
	FieldList=record_info(fields,jszd_role_score_honor),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(jszd_role_score_honor,KeyInfo);

read(jszd_role_score_info,Key,Pos)->
	FieldList=record_info(fields,jszd_role_score_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(jszd_role_score_info,KeyInfo);

read(loop_instance_record,Key,Pos)->
	FieldList=record_info(fields,loop_instance_record),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(loop_instance_record,KeyInfo);

read(loop_tower_instance,Key,Pos)->
	FieldList=record_info(fields,loop_tower_instance),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(loop_tower_instance,KeyInfo);

read(mail,Key,Pos)->
	FieldList=record_info(fields,mail),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(mail,KeyInfo);

read(offline_exp_rolelog,Key,Pos)->
	FieldList=record_info(fields,offline_exp_rolelog),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(offline_exp_rolelog,KeyInfo);

read(open_service_activitied_control,Key,Pos)->
	FieldList=record_info(fields,open_service_activitied_control),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(open_service_activitied_control,KeyInfo);

read(pet_advance_reset_time,Key,Pos)->
	FieldList=record_info(fields,pet_advance_reset_time),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(pet_advance_reset_time,KeyInfo);

read(pet_explore_background,Key,Pos)->
	FieldList=record_info(fields,pet_explore_background),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(pet_explore_background,KeyInfo);

read(pet_explore_info,Key,Pos)->
	FieldList=record_info(fields,pet_explore_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(pet_explore_info,KeyInfo);

read(pet_explore_storage,Key,Pos)->
	FieldList=record_info(fields,pet_explore_storage),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(pet_explore_storage,KeyInfo);

read(pet_shop_info,Key,Pos)->
	FieldList=record_info(fields,pet_shop_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(pet_shop_info,KeyInfo);

read(pets,Key,Pos)->
	FieldList=record_info(fields,pets),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(pets,KeyInfo);

read(player_option,Key,Pos)->
	FieldList=record_info(fields,player_option),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(player_option,KeyInfo);

read(playeritems,Key,Pos)->
	FieldList=record_info(fields,playeritems),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(playeritems,KeyInfo);

read(quest_role,Key,Pos)->
	FieldList=record_info(fields,quest_role),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(quest_role,KeyInfo);

read(recharge1,Key,Pos)->
	FieldList=record_info(fields,recharge1),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(recharge1,KeyInfo);

read(role_activity_value,Key,Pos)->
	FieldList=record_info(fields,role_activity_value),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_activity_value,KeyInfo);

read(role_buy_log,Key,Pos)->
	FieldList=record_info(fields,role_buy_log),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_buy_log,KeyInfo);

read(role_buy_mall_item,Key,Pos)->
	FieldList=record_info(fields,role_buy_mall_item),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_buy_mall_item,KeyInfo);

read(role_chess_spirit_log,Key,Pos)->
	FieldList=record_info(fields,role_chess_spirit_log),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_chess_spirit_log,KeyInfo);

read(role_congratu_log,Key,Pos)->
	FieldList=record_info(fields,role_congratu_log),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_congratu_log,KeyInfo);

read(role_continuous_logging_info,Key,Pos)->
	FieldList=record_info(fields,role_continuous_logging_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_continuous_logging_info,KeyInfo);

read(role_designation_info,Key,Pos)->
	FieldList=record_info(fields,role_designation_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_designation_info,KeyInfo);

read(role_favorite_gift_info,Key,Pos)->
	FieldList=record_info(fields,role_favorite_gift_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_favorite_gift_info,KeyInfo);

read(role_festival_recharge_data,Key,Pos)->
	FieldList=record_info(fields,role_festival_recharge_data),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_festival_recharge_data,KeyInfo);

read(role_first_charge_gift,Key,Pos)->
	FieldList=record_info(fields,role_first_charge_gift),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_first_charge_gift,KeyInfo);

read(role_gold_exchange_info,Key,Pos)->
	FieldList=record_info(fields,role_gold_exchange_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_gold_exchange_info,KeyInfo);

read(role_instance,Key,Pos)->
	FieldList=record_info(fields,role_instance),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_instance,KeyInfo);

read(role_instance_quality,Key,Pos)->
	FieldList=record_info(fields,role_instance_quality),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_instance_quality,KeyInfo);

read(role_invite_friend_info,Key,Pos)->
	FieldList=record_info(fields,role_invite_friend_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_invite_friend_info,KeyInfo);

read(role_judge_left_num,Key,Pos)->
	FieldList=record_info(fields,role_judge_left_num),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_judge_left_num,KeyInfo);

read(role_judge_num,Key,Pos)->
	FieldList=record_info(fields,role_judge_num),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_judge_num,KeyInfo);

read(role_levelup_opt_record,Key,Pos)->
	FieldList=record_info(fields,role_levelup_opt_record),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_levelup_opt_record,KeyInfo);

read(role_login_bonus,Key,Pos)->
	FieldList=record_info(fields,role_login_bonus),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_login_bonus,KeyInfo);

read(role_loop_instance,Key,Pos)->
	FieldList=record_info(fields,role_loop_instance),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_loop_instance,KeyInfo);

read(role_loop_tower,Key,Pos)->
	FieldList=record_info(fields,role_loop_tower),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_loop_tower,KeyInfo);

read(role_lottery,Key,Pos)->
	FieldList=record_info(fields,role_lottery),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_lottery,KeyInfo);

read(role_mainline,Key,Pos)->
	FieldList=record_info(fields,role_mainline),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_mainline,KeyInfo);

read(role_mall_integral,Key,Pos)->
	FieldList=record_info(fields,role_mall_integral),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_mall_integral,KeyInfo);

read(role_quick_bar,Key,Pos)->
	FieldList=record_info(fields,role_quick_bar),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_quick_bar,KeyInfo);

read(role_service_activities_db,Key,Pos)->
	FieldList=record_info(fields,role_service_activities_db),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_service_activities_db,KeyInfo);

read(role_skill,Key,Pos)->
	FieldList=record_info(fields,role_skill),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_skill,KeyInfo);

read(role_timelimit_gift,Key,Pos)->
	FieldList=record_info(fields,role_timelimit_gift),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_timelimit_gift,KeyInfo);

read(role_treasure_storage,Key,Pos)->
	FieldList=record_info(fields,role_treasure_storage),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_treasure_storage,KeyInfo);

read(role_treasure_transport_db,Key,Pos)->
	FieldList=record_info(fields,role_treasure_transport_db),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_treasure_transport_db,KeyInfo);

read(role_venation,Key,Pos)->
	FieldList=record_info(fields,role_venation),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_venation,KeyInfo);

read(role_venation_advanced,Key,Pos)->
	FieldList=record_info(fields,role_venation_advanced),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_venation_advanced,KeyInfo);

read(role_welfare_activity_info,Key,Pos)->
	FieldList=record_info(fields,role_welfare_activity_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_welfare_activity_info,KeyInfo);

read(roleattr,Key,Pos)->
	FieldList=record_info(fields,roleattr),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(roleattr,KeyInfo);

read(signature,Key,Pos)->
	FieldList=record_info(fields,signature),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(signature,KeyInfo);

read(tangle_battle,Key,Pos)->
	FieldList=record_info(fields,tangle_battle),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(tangle_battle,KeyInfo);

read(tangle_battle_kill_info,Key,Pos)->
	FieldList=record_info(fields,tangle_battle_kill_info),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(tangle_battle_kill_info,KeyInfo);

read(tangle_battle_role_killnum,Key,Pos)->
	FieldList=record_info(fields,tangle_battle_role_killnum),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(tangle_battle_role_killnum,KeyInfo);

read(template_playeritems,Key,Pos)->
	FieldList=record_info(fields,playeritems),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(template_playeritems,KeyInfo);

read(vip_role,Key,Pos)->
	FieldList=record_info(fields,vip_role),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(vip_role,KeyInfo);

read(wing_role,Key,Pos)->
	FieldList=record_info(fields,wing_role),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(wing_role,KeyInfo);

read(game_rank_db,Key,Pos)->
	FieldList=record_info(fields,game_rank_db),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(game_rank_db,KeyInfo);

read(guild_monster,Key,Pos)->
	FieldList=record_info(fields,guild_monster),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(guild_monster,KeyInfo);

read(yhzq_battle_record,Key,Pos)->
	FieldList=record_info(fields,yhzq_battle_record),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(yhzq_battle_record,KeyInfo);

read(mall_up_sales_table,Key,Pos)->
	FieldList=record_info(fields,mall_up_sales_table),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(mall_up_sales_table,KeyInfo);

read(instance_pos,Key,Pos)->
	FieldList=record_info(fields,instance_pos),
KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(instance_pos,KeyInfo);

read(open_service_level_rank_db,Key,Pos)->
	FieldList=record_info(fields,open_service_level_rank_db),
	KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(open_service_level_rank_db,KeyInfo);

read(role_sum_gold,Key,Pos)->
	FieldList=record_info(fields,role_sum_gold),
	KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(role_sum_gold,KeyInfo);
read(gm_role_privilege,Key,Pos)->
	FieldList=record_info(fields,gm_role_privilege),
	KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(gm_role_privilege,KeyInfo);

read(furnace,Key,Pos)->
	FieldList=record_info(fields,furnace),
	KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(furnace,KeyInfo);

read(furnace_add_role_attribute,Key,Pos)->
	FieldList=record_info(fields,furnace_add_role_attribute),
	KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(furnace_add_role_attribute,KeyInfo);

read(astrology_add_role_attribute,Key,Pos)->
	FieldList=record_info(fields,astrology_add_role_attribute),
	KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(astrology_add_role_attribute,KeyInfo);

read(astrology_package,Key,Pos)->
	FieldList=record_info(fields,astrology_package),
	KeyInfo=make_key_info(FieldList,Key,Pos),
	read_data(astrology_package,KeyInfo);


read(_,Key,Pos)->
	nothing.

make_key_info(FieldList,Key,Pos)->
	FieldTuple=erlang:list_to_tuple(FieldList),
	PosKey=erlang:element(Pos, FieldTuple),
	[{PosKey,Key}].

read_data(TableName,KeyInfo)->
	Sql=make_select_sql(TableName,KeyInfo),
	case mysql:fetch(?DB,Sql) of
		 {data, {_, _, R, _, _}} -> 
			 Values=lists:foldl(fun(Info,Acc)->
								 ListInfo= lists:map(fun(Value)->
													ListValue=mysql_db_tool:check_value(Value) end, Info),
								TupleInfo=erlang:list_to_tuple([TableName|ListInfo]),
								[TupleInfo]++Acc end,[],  R),
			 {ok,Values};
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.

make_select_sql(Table_name,Where_List)->
	{Wsql, Count1} = get_where_sql(Where_List),
	WhereSql = 
		if Count1 > 1 -> lists:concat(["where ", lists:flatten(Wsql)]);
	   			 true -> ""
		end,
	lists:concat(["select *"," from `", Table_name, "` ", WhereSql]).

get_where_sql(Where_List) ->
%%  条件用列表方式：[{},{},{}]
%%  每一个条件形式(一共三种)：
%%		1、{idA, "<>", 10, "or"}   	<===> {字段名, 操作符, 值，下一个条件的连接符}
%% 	    2、{idB, ">", 20}   			<===> {idB, ">", 20，"and"}
%% 	    3、{idB, 20}   				<===> {idB, "=", 20，"and"}		
	lists:mapfoldl(
  		fun(Field_Operator_Val, Sum) ->	
			[Expr, Or_And_1] = 
				case Field_Operator_Val of   
					{Field, Operator, Val, Or_And} ->
								 case is_binary(Val) orelse is_list(Val)  orelse is_tuple(Val) orelse is_atom(Val)of 
								 true -> 
										if is_atom(Val)->
												ValueList=atom_to_list(Val),
												Result=io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(ValueList))]),
												[Result,Or_And];
										   is_tuple(Val)->
												Result=io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(Val))]),
												[Result,Or_And];
											true->
												%io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(NewVal))])
												Result=io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(Val))]),
												%auth_util:escape_uri(Result)
												[Result,Or_And]
										end;
							 	 _-> [io_lib:format("`~s`=~p",[Field, Val]),Or_And]
							 end;
					{Field, Operator, Val} ->
								 case is_binary(Val) orelse is_list(Val)  orelse is_tuple(Val) orelse is_atom(Val)of 
								 true -> 
										if is_atom(Val)->
												ValueList=atom_to_list(Val),
												[io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(ValueList))]),"and"];
										   is_tuple(Val)->
												[io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(Val))]),"and"];
											true->
												%io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(NewVal))])
												Result=io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(Val))]),
												%auth_util:escape_uri(Result)
												[Result,"and"]
										end;
							 	 _-> [io_lib:format("`~s`=~p",[Field, Val]),"and"]
							 end;
					{Field, Val} ->  
								 case is_binary(Val) orelse is_list(Val)  orelse is_tuple(Val) orelse is_atom(Val)of 
								 true -> 
										if is_atom(Val)->
												[ ["`", mysql_db_tool:to_list(Field),"`='",mysql_db_tool:get_sql_val(Val),"'"],"and"];
										   is_tuple(Val)->
												[io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(Val))]),"and"];
											true->
												case mysql_db_tool:is_string(Val)of
													yes->
														%[io_lib:format("`~s`='~s'",[Field,auth_util:escape_uri(Val)]),"and"];
														[io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(Val))]),"and"];
													_->
														[io_lib:format("`~s`='~s'",[Field,lists:flatten(io_lib:write(Val))]),"and"]
												end
										end;
							 	 _-> [io_lib:format("`~s`=~p",[Field, Val]),"and"]
							 end;
					 _-> ""
				   end,
			S1 = if Sum == length(Where_List) -> io_lib:format("~s ",[Expr]);
					true ->	io_lib:format("~s ~s ",[Expr, Or_And_1])
				 end,
			{S1, Sum+1}
		end,
		1, Where_List).


mysql_halt([Sql, Reason]) ->
    catch erlang:error({db_error, [Sql, Reason]}).
