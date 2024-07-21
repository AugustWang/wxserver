%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: yanzengyan
%% Created: 2012-7-18
%% Description: 生成配置文件数据库
-module(config_db).

%%
%% Include files
%%
-include("config_db_def.hrl").
%%
%% Exported Functions
%%
-export([run/0, read/2]).

%%
%% API Functions
%%

read(Table, Key) ->
	mnesia:start(),
	mnesia:wait_for_tables(mnesia:system_info(tables), infinity),
	Result = mnesia:dirty_read(Table, Key),
	io:format("~p~n", [Result]),
	mnesia:stop().

run() ->
	mnesia:create_schema([node()]),
	mnesia:start(),
	mnesia:wait_for_tables(mnesia:system_info(tables), infinity),
	delete_all_tables(),
	create_all_tables(),
	gen_game_db(),
	gen_creature_db(),
	mnesia:stop(),
	mnesia:start(),
	mnesia:wait_for_tables(mnesia:system_info(tables), infinity),
	mnesia:stop(),
	io:format("yanzengyan, process finished!!!~n").


create_all_tables() ->
    db_tools:create_table_disc(achieve_proto, record_info(fields,achieve_proto), [], set),
	db_tools:create_table_disc(achieve_fuwen, record_info(fields,achieve_fuwen), [], set),
	db_tools:create_table_disc(achieve_award, record_info(fields,achieve_award), [], set),
%% 	db_tools:create_table_disc(achieve, record_info(fields,achieve), [], set),
	db_tools:create_table_disc(activity,record_info(fields,activity),[],bag),
	db_tools:create_table_disc(activity_value_proto,record_info(fields,activity_value_proto),[],set),
	db_tools:create_table_disc(activity_value_reward,record_info(fields,activity_value_reward),[],set),
	db_tools:create_table_disc(ai_agents,record_info(fields,ai_agents),[],bag),
	db_tools:create_table_disc(answer,record_info(fields,answer),[],set),
	db_tools:create_table_disc(answer_option,record_info(fields,answer_option),[],set),
	db_tools:create_table_disc(attr_info,record_info(fields,attr_info),[],set),
	db_tools:create_table_disc(auto_name,record_info(fields,auto_name),[],set),
	db_tools:create_table_disc(back_echantment_stone,record_info(fields,back_echantment_stone),[],set),
	db_tools:create_table_disc(battlefield_proto,record_info(fields,battlefield_proto),[],set),
	db_tools:create_table_disc(block_training, record_info(fields,block_training), [], set),
	db_tools:create_table_disc(buffers,record_info(fields,buffers),[],bag),
	db_tools:create_table_disc(chat_condition,record_info(fields,chat_condition),[],set),
	db_tools:create_table_disc(chess_spirit_config,record_info(fields,chess_spirit_config),[],set),
	db_tools:create_table_disc(chess_spirit_rewards,record_info(fields,chess_spirit_rewards),[],set),
	db_tools:create_table_disc(chess_spirit_section,record_info(fields,chess_spirit_section),[],set),
	db_tools:create_table_disc(christmas_activity_reward,record_info(fields,christmas_activity_reward),[],set),
	db_tools:create_table_disc(christmas_tree_config,record_info(fields,christmas_tree_config),[],set),
	db_tools:create_table_disc(classbase,record_info(fields,classbase),[],bag),
	db_tools:create_table_disc(congratulations,record_info(fields,congratulations),[],set),
	db_tools:create_table_disc(continuous_logging_gift,record_info(fields,continuous_logging_gift),[],set),
	db_tools:create_table_disc(country_proto,record_info(fields,country_proto),[],set),
	db_tools:create_table_disc(creature_proto,record_info(fields,creature_proto),[],set),
	db_tools:create_table_disc(designation_data,record_info(fields,designation_data),[],set),
	db_tools:create_table_disc(dragon_fight_db,record_info(fields,dragon_fight_db),[],set),
	db_tools:create_table_disc(drop_rule,record_info(fields,drop_rule),[],set),
	db_tools:create_table_disc(enchantments, record_info(fields,enchantments), [], set),
	db_tools:create_table_disc(enchantments_lucky, record_info(fields,enchantments_lucky), [], set),
	db_tools:create_table_disc(enchant_convert,record_info(fields,enchant_convert),[],set),
	db_tools:create_table_disc(enchant_opt,record_info(fields,enchant_opt),[],set),
	db_tools:create_table_disc(enchant_property_opt,record_info(fields,enchant_property_opt),[],bag),
	db_tools:create_table_disc(equipmentset,record_info(fields,equipmentset),[],bag),
	db_tools:create_table_disc(equipment_fenjie, record_info(fields,equipment_fenjie), [], set),
	db_tools:create_table_disc(equipment_move, record_info(fields,equipment_move),[], bag),%%枫少修改bag
	db_tools:create_table_disc(equipment_sysbrd,record_info(fields,equipment_sysbrd),[],set),
	db_tools:create_table_disc(equipment_upgrade, record_info(fields,equipment_upgrade), [], set),
	db_tools:create_table_disc(everquests,record_info(fields,everquests),[],set),
	db_tools:create_table_disc(faction_relations,record_info(fields,faction_relations),[],set),
	db_tools:create_table_disc(festival_control,record_info(fields,festival_control),[],set),
	db_tools:create_table_disc(festival_recharge_gift,record_info(fields,festival_recharge_gift),[],set),
	db_tools:create_table_disc(goals, record_info(fields,goals), [], set),
	db_tools:create_table_disc(guild_authorities, record_info(fields,guild_authorities),[],set),
	db_tools:create_table_disc(guild_auth_groups, record_info(fields,guild_auth_groups), [], bag),
	db_tools:create_table_disc(guild_battle_proto,record_info(fields,guild_battle_proto),[],set),
	db_tools:create_table_disc(guild_facilities, record_info(fields,guild_facilities), [], bag),
	db_tools:create_table_disc(guild_monster_proto,record_info(fields,guild_monster_proto),[],set),
	db_tools:create_table_disc(guild_setting,record_info(fields,guild_setting),[],set),
	db_tools:create_table_disc(guild_shop,record_info(fields,guild_shop),[],set),
	db_tools:create_table_disc(guild_shop_items,record_info(fields,guild_shop_items),[],set),
	db_tools:create_table_disc(guild_treasure,record_info(fields,guild_treasure),[],set),
	db_tools:create_table_disc(guild_treasure_items,record_info(fields,guild_treasure_items),[],set),
	db_tools:create_table_disc(guild_treasure_transport_consume,record_info(fields,guild_treasure_transport_consume),[],set),
	db_tools:create_table_disc(honor_store_items, record_info(fields,honor_store_items), [], set),
	db_tools:create_table_disc(inlay, record_info(fields,inlay), [], set),
	db_tools:create_table_disc(instance_proto, record_info(fields,instance_proto), [], set),
	db_tools:create_table_disc(item_identify,record_info(fields,item_identify),[],set),
	db_tools:create_table_disc(item_template,record_info(fields,item_template),[],set),
	db_tools:create_table_disc(jszd_rank_option, record_info(fields,jszd_rank_option), [], set),
	db_tools:create_table_disc(levelup_opt,record_info(fields,levelup_opt),[],set),
	db_tools:create_table_disc(level_activity_rewards_db,record_info(fields,level_activity_rewards_db),[],set),
	db_tools:create_table_disc(loop_instance, record_info(fields,loop_instance), [], set),
	db_tools:create_table_disc(loop_instance_proto, record_info(fields,loop_instance_proto), [], set),
	db_tools:create_table_disc(loop_tower, record_info(fields,loop_tower), [], set),
	db_tools:create_table_disc(lottery_counts, record_info(fields,lottery_counts), [], set),
	db_tools:create_table_disc(lottery_droplist, record_info(fields,lottery_droplist), [], set),
	db_tools:create_table_disc(mainline_defend_config,record_info(fields,mainline_defend_config),[],bag),
	db_tools:create_table_disc(mainline_proto,record_info(fields,mainline_proto),[],bag),
	db_tools:create_table_disc(mall_item_info, record_info(fields,mall_item_info), [], set),
	db_tools:create_table_disc(mall_sales_item_info, record_info(fields,mall_sales_item_info), [], set),
	db_tools:create_table_disc(map_info, record_info(fields,map_info), [], set),
	db_tools:create_table_disc(npc_dragon_fight,record_info(fields,npc_dragon_fight),[],set),
	db_tools:create_table_disc(npc_drop,record_info(fields,npc_drop),[],set),
	db_tools:create_table_disc(npc_exchange_list,record_info(fields,npc_exchange_list),[],set),
	db_tools:create_table_disc(everquest_list,record_info(fields,everquest_list),[],set),
	db_tools:create_table_disc(npc_sell_list,record_info(fields,npc_sell_list),[],set),
	db_tools:create_table_disc(npc_trans_list,record_info(fields,npc_trans_list),[],set),
	db_tools:create_table_disc(quest_npc,record_info(fields,quest_npc),[],set),
	db_tools:create_table_disc(npc_functions,record_info(fields,npc_functions),[],set),
	db_tools:create_table_disc(offline_everquests_exp,record_info(fields,offline_everquests_exp),[],set),
	db_tools:create_table_disc(offline_exp,record_info(fields,offline_exp),[],set),
	db_tools:create_table_disc(open_service_activities,record_info(fields,open_service_activities),[],set),
	db_tools:create_table_disc(open_service_activities_time,record_info(fields,open_service_activities_time),[],set),
	db_tools:create_table_disc(pet_evolution,record_info(fields,pet_evolution),[],set),
	db_tools:create_table_disc(pet_explore_gain,record_info(fields,pet_explore_gain),[],set),
	db_tools:create_table_disc(pet_explore_style,record_info(fields,pet_explore_style),[],set),
	db_tools:create_table_disc(pet_growth,record_info(fields,pet_growth),[],set),
	db_tools:create_table_disc(pet_happiness,record_info(fields,pet_happiness),[],set),
	db_tools:create_table_disc(pet_level,record_info(fields,pet_level),[],set),
	db_tools:create_table_disc(pet_proto,record_info(fields,pet_proto),[],set),
	db_tools:create_table_disc(pet_quality,record_info(fields,pet_quality),[],set),
	db_tools:create_table_disc(pet_quality_up,record_info(fields,pet_quality_up),[],set),
	db_tools:create_table_disc(pet_skill_slot,record_info(fields,pet_skill_slot),[],set),
	db_tools:create_table_disc(pet_slot,record_info(fields,pet_slot),[],set),
	db_tools:create_table_disc(pet_talent_consume,record_info(fields,pet_talent_consume),[],set),
	db_tools:create_table_disc(pet_talent_rate,record_info(fields,pet_talent_rate),[],bag),
	db_tools:create_table_disc(pet_wash_attr_point,record_info(fields,pet_wash_attr_point),[],set),
	db_tools:create_table_disc(pet_item_mall,record_info(fields,pet_item_mall),[],set),%%宠物商店初始化信息表《枫少》
	db_tools:create_table_disc(quests,record_info(fields,quests),[],set),
	db_tools:create_table_disc(refine_system,record_info(fields,refine_system),[],set),
	db_tools:create_table_disc(remove_seal, record_info(fields,remove_seal), [], set),
	db_tools:create_table_disc(ridepet_synthesis,record_info(fields,ridepet_synthesis),[],set),
	db_tools:create_table_disc(ride_proto_db,record_info(fields,ride_proto_db),[],set),
	db_tools:create_table_disc(role_level_bonfire_effect_db,record_info(fields,role_level_bonfire_effect_db),[],set),
	db_tools:create_table_disc(role_level_experience,record_info(fields,role_level_experience),[],set),
	db_tools:create_table_disc(role_level_sitdown_effect_db,record_info(fields,role_level_sitdown_effect_db),[],set),
	db_tools:create_table_disc(role_level_soulpower,record_info(fields,role_level_soulpower),[],set),
	db_tools:create_table_disc(role_petnum,record_info(fields,role_petnum),[],set),
	db_tools:create_table_disc(series_kill,record_info(fields,series_kill),[],set),
	db_tools:create_table_disc(skills,record_info(fields,skills),[],bag),
	db_tools:create_table_disc(sock, record_info(fields,sock), [], set),
	db_tools:create_table_disc(spa_exp,record_info(fields,spa_exp),[],set),
	db_tools:create_table_disc(spa_option,record_info(fields,spa_option),[],set),
	db_tools:create_table_disc(stonemix, record_info(fields,stonemix), [], set),
	db_tools:create_table_disc(system_chat, record_info(fields,system_chat), [], set),
	db_tools:create_table_disc(tangle_reward_info,record_info(fields,tangle_reward_info),[],set),
	db_tools:create_table_disc(template_itemproto, record_info(fields,template_itemproto), [], set),
	db_tools:create_table_disc(timelimit_gift,record_info(fields,timelimit_gift),[],set),
	db_tools:create_table_disc(transports,record_info(fields,transports),[],bag),
	db_tools:create_table_disc(transport_channel,record_info(fields,transport_channel),[],set),
	db_tools:create_table_disc(treasure_chest_drop,record_info(fields,treasure_chest_drop),[],set),
	db_tools:create_table_disc(treasure_chest_rate,record_info(fields,treasure_chest_rate),[],set),
	db_tools:create_table_disc(treasure_chest_times,record_info(fields,treasure_chest_times),[],set),
	db_tools:create_table_disc(treasure_chest_type,record_info(fields,treasure_chest_type),[],set),
	db_tools:create_table_disc(treasure_spawns,record_info(fields,treasure_spawns),[],set),
	db_tools:create_table_disc(treasure_transport,record_info(fields,treasure_transport),[],bag),
	db_tools:create_table_disc(treasure_transport_quality_bonus,record_info(fields,treasure_transport_quality_bonus),[],set),
	db_tools:create_table_disc(venation_advanced,record_info(fields,venation_advanced),[],bag),
	db_tools:create_table_disc(venation_exp_proto,record_info(fields,venation_exp_proto),[],set),
	db_tools:create_table_disc(venation_item_rate,record_info(fields,venation_item_rate),[],set),
	db_tools:create_table_disc(venation_point_proto,record_info(fields,venation_point_proto),[],set),
	db_tools:create_table_disc(venation_proto,record_info(fields,venation_proto),[],set),
	db_tools:create_table_disc(vip_level, record_info(fields,vip_level), [], set),
	db_tools:create_table_disc(welfare_activity_data,record_info(fields,welfare_activity_data),[],set),
	db_tools:create_table_disc(yhzq_battle,record_info(fields,yhzq_battle),[],set),
	db_tools:create_table_disc(yhzq_winner_raward,record_info(fields,yhzq_winner_raward),[],set),
	db_tools:create_table_disc(creature_spawns,record_info(fields,creature_spawns),[],set),
	db_tools:create_table_disc(template_roleattr,record_info(fields,roleattr),[account,name],set),
	db_tools:create_table_disc(template_role_quick_bar,record_info(fields,role_quick_bar),[],set),
	db_tools:create_table_disc(template_role_skill,record_info(fields,role_skill),[],set),
	db_tools:create_table_disc(template_quest_role,record_info(fields,quest_role),[],set),
	db_tools:create_table_disc(instance_quality_proto,record_info(fields,instance_quality_proto),[],set),
	%%宠物技能模板
	db_tools:create_table_disc(pet_skill_template, record_info(fields,pet_skill_template), [],bag),
	%%宠物技能槽位
	db_tools:create_table_disc(pet_skill_proto, record_info(fields,pet_skill_proto),[], set),
	%%副本元宝委托
	db_tools:create_table_disc(instance_entrust,record_info(fields,instance_entrust),[],set),
	db_tools:create_table_disc(activity_test01,record_info(fields,activity_test01),[],set),
	%%宠物属性转化率
	db_tools:create_table_disc(pet_attr_transform,record_info(fields,pet_attr_transform),[],set),
	%%宠物成长提升
	db_tools:create_table_disc(pet_up_growth,record_info(fields,pet_up_growth),[],set),
	%%批量合成概率  by zhangting%%
	db_tools:create_table_disc(stonemix_rateinfo,record_info(fields,stonemix_rateinfo),[],set),
	%%宠物技能
	db_tools:create_table_disc(pet_skill_book_rate,record_info(fields,pet_skill_book_rate),[],set),
	db_tools:create_table_disc(pet_skill_book,record_info(fields,pet_skill_book),[],set),
	db_tools:create_table_disc(pet_fresh_skill, record_info(fields,pet_fresh_skill), [], set),
	db_tools:create_table_disc(pet_base_attr, record_info(fields,pet_base_attr),[],set),
	%%宠物洗髓
     db_tools:create_table_disc(pet_xisui_rate, record_info(fields,pet_xisui_rate), [], set),
	db_tools:create_table_disc(pet_talent_item,record_info(fields,pet_talent_item),[],set),
	db_tools:create_table_disc(pet_talent_proto,record_info(fields,pet_talent_proto),[],set),
	db_tools:create_table_disc(pet_talent_template, record_info(fields,pet_talent_template),[], bag),
	%%宠物进阶
	db_tools:create_table_disc(pet_advance, record_info(fields,pet_advance),[],set),
	db_tools:create_table_disc(pet_advance_lucky, record_info(fields,pet_advance),[],bag),
	%%充值礼包
	db_tools:create_table_disc(charge_package_proto, record_info(fields,charge_package_proto),[], bag),
	db_tools:create_table_disc(item_can_used, record_info(fields,item_can_used),[], bag),
	%%飞剑
	db_tools:create_table_disc(wing_level,record_info(fields,wing_level),[],set),
	db_tools:create_table_disc(wing_phase,record_info(fields,wing_phase),[],set),
	db_tools:create_table_disc(wing_quality,record_info(fields,wing_quality),[],set),
	db_tools:create_table_disc(wing_intensify_up,record_info(fields,wing_intensify_up),[],set),
	db_tools:create_table_disc(wing_skill,record_info(fields,wing_skill),[],bag),
	db_tools:create_table_disc(item_gold_price,record_info(fields,item_gold_price),[],set),
	db_tools:create_table_disc(wing_echant,record_info(fields,wing_echant),[],set),
	db_tools:create_table_disc(wing_echant_lock,record_info(fields,wing_echant_lock),[],set).

delete_all_tables() ->
%% 	mnesia:delete_table(achieve),
	mnesia:delete_table(activity),
	mnesia:delete_table(activity_value_proto),
	mnesia:delete_table(activity_value_reward),
	mnesia:delete_table(ai_agents),
	mnesia:delete_table(answer),
	mnesia:delete_table(answer_option),
	mnesia:delete_table(attr_info),
	mnesia:delete_table(auto_name),
	mnesia:delete_table(back_echantment_stone),
	mnesia:delete_table(battlefield_proto),
	mnesia:delete_table(block_training),
	mnesia:delete_table(buffers),
	mnesia:delete_table(chat_condition),
	mnesia:delete_table(chess_spirit_config),
	mnesia:delete_table(chess_spirit_rewards),
	mnesia:delete_table(chess_spirit_section),
	mnesia:delete_table(christmas_activity_reward),
	mnesia:delete_table(christmas_tree_config),
	mnesia:delete_table(classbase),
	mnesia:delete_table(congratulations),
	mnesia:delete_table(continuous_logging_gift),
	mnesia:delete_table(country_proto),
	mnesia:delete_table(creature_proto),
	mnesia:delete_table(designation_data),
	mnesia:delete_table(dragon_fight_db),
	mnesia:delete_table(drop_rule),
	mnesia:delete_table(enchantments),
	mnesia:delete_table(enchantments_lucky),
	mnesia:delete_table(enchant_convert),
	mnesia:delete_table(enchant_opt),
	mnesia:delete_table(enchant_property_opt),
	mnesia:delete_table(equipmentset),
	mnesia:delete_table(equipment_fenjie),
	mnesia:delete_table(equipment_move),
	mnesia:delete_table(equipment_sysbrd),
	mnesia:delete_table(equipment_upgrade),
	mnesia:delete_table(everquests),
	mnesia:delete_table(faction_relations),
	mnesia:delete_table(festival_control),
	mnesia:delete_table(festival_recharge_gift),
	mnesia:delete_table(goals),
	mnesia:delete_table(guild_authorities),
	mnesia:delete_table(guild_auth_groups),
	mnesia:delete_table(guild_battle_proto),
	mnesia:delete_table(guild_facilities),
	mnesia:delete_table(guild_monster_proto),
	mnesia:delete_table(guild_setting),
	mnesia:delete_table(guild_shop),
	mnesia:delete_table(guild_shop_items),
	mnesia:delete_table(guild_treasure),
	mnesia:delete_table(guild_treasure_items),
	mnesia:delete_table(guild_treasure_transport_consume),
	mnesia:delete_table(honor_store_items),
	mnesia:delete_table(inlay),
	mnesia:delete_table(instance_proto),
	mnesia:delete_table(item_identify),
	mnesia:delete_table(item_template),
	mnesia:delete_table(jszd_rank_option),
	mnesia:delete_table(levelup_opt),
	mnesia:delete_table(level_activity_rewards_db),
	mnesia:delete_table(loop_instance),
	mnesia:delete_table(loop_instance_proto),
	mnesia:delete_table(loop_tower),
	mnesia:delete_table(lottery_counts),
	mnesia:delete_table(lottery_droplist),
	mnesia:delete_table(mainline_defend_config),
	mnesia:delete_table(mainline_proto),
	mnesia:delete_table(mall_item_info),
	mnesia:delete_table(mall_sales_item_info),
	mnesia:delete_table(map_info),
	mnesia:delete_table(npc_dragon_fight),
	mnesia:delete_table(npc_drop),
	mnesia:delete_table(npc_exchange_list),
	mnesia:delete_table(everquest_list),
	mnesia:delete_table(npc_sell_list),
	mnesia:delete_table(npc_trans_list),
	mnesia:delete_table(quest_npc),
	mnesia:delete_table(npc_functions),
	mnesia:delete_table(offline_everquests_exp),
	mnesia:delete_table(offline_exp),
	mnesia:delete_table(open_service_activities),
	mnesia:delete_table(open_service_activities_time),
	mnesia:delete_table(pet_evolution),
	mnesia:delete_table(pet_explore_gain),
	mnesia:delete_table(pet_explore_style),
	mnesia:delete_table(pet_growth),
	mnesia:delete_table(pet_happiness),
	mnesia:delete_table(pet_level),
	mnesia:delete_table(pet_proto),
	mnesia:delete_table(pet_quality),
	mnesia:delete_table(pet_quality_up),
	mnesia:delete_table(pet_skill_slot),
	mnesia:delete_table(pet_slot),
	mnesia:delete_table(pet_talent_consume),
	mnesia:delete_table(pet_talent_rate),
	mnesia:delete_table(pet_wash_attr_point),
	mnesia:delete_table(pet_item_mall),
	mnesia:delete_table(quests),
	mnesia:delete_table(refine_system),
	mnesia:delete_table(remove_seal),
	mnesia:delete_table(ridepet_synthesis),
	mnesia:delete_table(ride_proto_db),
	mnesia:delete_table(role_level_bonfire_effect_db),
	mnesia:delete_table(role_level_experience),
	mnesia:delete_table(role_level_sitdown_effect_db),
	mnesia:delete_table(role_level_soulpower),
	mnesia:delete_table(role_petnum),
	mnesia:delete_table(series_kill),
	mnesia:delete_table(skills),
	mnesia:delete_table(sock),
	mnesia:delete_table(spa_exp),
	mnesia:delete_table(spa_option),
	mnesia:delete_table(stonemix),
	mnesia:delete_table(system_chat),
	mnesia:delete_table(tangle_reward_info),
	mnesia:delete_table(template_itemproto),
	mnesia:delete_table(timelimit_gift),
	mnesia:delete_table(transports),
	mnesia:delete_table(transport_channel),
	mnesia:delete_table(treasure_chest_drop),
	mnesia:delete_table(treasure_chest_rate),
	mnesia:delete_table(treasure_chest_times),
	mnesia:delete_table(treasure_chest_type),
	mnesia:delete_table(treasure_spawns),
	mnesia:delete_table(treasure_transport),
	mnesia:delete_table(treasure_transport_quality_bonus),
	mnesia:delete_table(venation_advanced),
	mnesia:delete_table(venation_exp_proto),
	mnesia:delete_table(venation_item_rate),
	mnesia:delete_table(venation_point_proto),
	mnesia:delete_table(venation_proto),
	mnesia:delete_table(vip_level),
	mnesia:delete_table(welfare_activity_data),
	mnesia:delete_table(yhzq_battle),
	mnesia:delete_table(yhzq_winner_raward),
	mnesia:delete_table(creature_spawns),
	mnesia:delete_table(template_roleattr),
	mnesia:delete_table(template_role_quick_bar),
	mnesia:delete_table(template_role_skill),
	mnesia:delete_table(template_quest_role),
	mnesia:delete_table(instance_quality_proto),
	%%宠物升级
	mnesia:delete_table(pet_skill_template),
	%%副本元宝委托
	mnesia:delete_table(instance_entrust),
	mnesia:delete_table(activity_test01),
	%%批量合成概率  by zhangting%%
    mnesia:delete_table(stonemix_rateinfo),
	mnesia:delete_table(pet_up_growth),

	mnesia:delete_table(pet_attr_transform),
    %%成就按客户端要求  @@wb20130301
    mnesia:delete_table(achieve_proto),
	mnesia:delete_table(achieve_award),
	mnesia:delete_table(achieve_fuwen),

	mnesia:delete_table(pet_attr_transform),
	mnesia:delete_table(pet_skill_book_rate),
	mnesia:delete_table(pet_skill_book),
	mnesia:delete_table(pet_fresh_skill),
	mnesia:delete_table(pet_xisui_rate),

	mnesia:delete_table(pet_base_attr),
	mnesia:delete_table(pet_talent_item),
	mnesia:delete_table(pet_talent_proto),
	mnesia:delete_table(pet_talent_template),
	mnesia:delete_table(pet_advance),
	mnesia:delete_table(pet_advance_lucky),
	mnesia:delete_table(pet_skill_proto),
	mnesia:delete_table(charge_package_proto),
	mnesia:delete_table(item_can_used),
	%%飞剑
	mnesia:delete_table(wing_level),
	mnesia:delete_table(wing_phase),
	mnesia:delete_table(wing_quality),
	mnesia:delete_table(wing_intensify_up),
	mnesia:delete_table(wing_skill),
	mnesia:delete_table(item_gold_price),
	mnesia:delete_table(wing_echant),
	mnesia:delete_table(wing_echant_lock).

gen_game_db() ->
%% 	FileName = "../config/game.config",
%% 	case file:open(FileName,[read]) of 
%% 		{ok,Fd}->
%% 			write_game_db(Fd);
%% 		{error,Reason}-> 
%% 			slogger:msg("Consult error:~p~n",[Reason])
%% 	end.
 	FilePath="../config/config",
	read_from_txt:get_object(FilePath).

write_game_db_old_zt(Fd) ->
	case io:read(Fd,'') of
		{error,Reason}->
		 	slogger:msg("reovery_from failed: ~p~n",[Reason]),
		 	file:close(Fd);
		eof ->
			file:close(Fd);
		{ok,Term}->
%% 			io:format("yanzengyan, Term: ~p~n", [Term]),
           if  element(1,Term) =:= continuous_logging_gift ->
				  io:format("continuous_logging_op:init_data() 02 Item:~p~n",[Term]),
				  if erlang:size(Term)=:=3 -> 
					   dal:write( erlang:append_element(Term,[]));
					   true->	  dal:write(Term)
				  end;	 
			 true->
    		 	 	dal:write(Term)
            end,           
			 write_game_db(Fd),
			 ok
	end.

write_game_db(Fd) ->
	case io:read(Fd,'') of
		{error,Reason}->
		 	slogger:msg("reovery_from failed: ~p~n",[Reason]),
		 	file:close(Fd);
		eof ->
			file:close(Fd);
		{ok,Term}->
    		 dal:write(Term),
		 write_game_db(Fd),
			 ok
	end.


gen_creature_db() ->
	FileName = "../config/creature_spawns.config",
	case file:consult(FileName) of
		{ok,[Terms]}->
			lists:foreach(fun(Term)->add_creature_spawns_to_mnesia(Term)
						  end,Terms);
		{error,Reason} ->
			slogger:msg("import_creature_spawns error:~p~n",[Reason])
	end.

add_creature_spawns_to_mnesia(Term)->
	try
		NewTerm = list_to_tuple([creature_spawns|tuple_to_list(Term)]),
		dal:write(NewTerm)
	catch
		E:R-> io:format("Reason ~p: ~p~n",[E,R]),error
	end.


	



