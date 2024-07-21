%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(login_pb).
-include("login_pb.hrl").
-compile(export_all).
-export([create/0,init/0]).

-behaviour(ets_operater_mod).

create()->
	ets:new(proto_msg_id_record_map,[set,named_table]).

get_record_name(ID)->
	case ets:lookup(proto_msg_id_record_map,ID) of
		[]->error;
		[{_Id,Rec}]->
			Rec
	end.

init()->
	ets:insert(proto_msg_id_record_map,{5,'player_role_list_s2c'}),
	ets:insert(proto_msg_id_record_map,{6,'role_line_query_c2s'}),
	ets:insert(proto_msg_id_record_map,{7,'role_line_query_ok_s2c'}),
	ets:insert(proto_msg_id_record_map,{9,'role_change_line_c2s'}),
	ets:insert(proto_msg_id_record_map,{10,'player_select_role_c2s'}),
	ets:insert(proto_msg_id_record_map,{13,'map_complete_c2s'}),
	ets:insert(proto_msg_id_record_map,{14,'role_map_change_s2c'}),
	ets:insert(proto_msg_id_record_map,{15,'npc_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{16,'other_role_map_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{22,'role_change_map_c2s'}),
	ets:insert(proto_msg_id_record_map,{23,'role_change_map_ok_s2c'}),
	ets:insert(proto_msg_id_record_map,{24,'role_change_map_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{25,'role_move_c2s'}),
	ets:insert(proto_msg_id_record_map,{26,'heartbeat_c2s'}),
	ets:insert(proto_msg_id_record_map,{27,'other_role_move_s2c'}),
	ets:insert(proto_msg_id_record_map,{28,'role_move_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{29,'role_attack_c2s'}),
	ets:insert(proto_msg_id_record_map,{31,'role_attack_s2c'}),
	ets:insert(proto_msg_id_record_map,{32,'role_cancel_attack_s2c'}),
	ets:insert(proto_msg_id_record_map,{33,'be_attacked_s2c'}),
	ets:insert(proto_msg_id_record_map,{34,'be_killed_s2c'}),
	ets:insert(proto_msg_id_record_map,{35,'other_role_into_view_s2c'}),
	ets:insert(proto_msg_id_record_map,{36,'npc_into_view_s2c'}),
	ets:insert(proto_msg_id_record_map,{37,'creature_outof_view_s2c'}),
	ets:insert(proto_msg_id_record_map,{38,'debug_c2s'}),
	ets:insert(proto_msg_id_record_map,{39,'use_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{40,'auto_equip_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{41,'change_item_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{42,'use_item_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{43,'buff_immune_s2c'}),
	ets:insert(proto_msg_id_record_map,{53,'role_attribute_s2c'}),
	ets:insert(proto_msg_id_record_map,{54,'npc_attribute_s2c'}),
	ets:insert(proto_msg_id_record_map,{55,'role_rename_c2s'}),
	ets:insert(proto_msg_id_record_map,{56,'guild_rename_c2s'}),
	ets:insert(proto_msg_id_record_map,{57,'rename_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{61,'role_map_change_c2s'}),
	ets:insert(proto_msg_id_record_map,{62,'npc_map_change_c2s'}),
	ets:insert(proto_msg_id_record_map,{63,'map_change_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{70,'skill_panel_c2s'}),
	ets:insert(proto_msg_id_record_map,{71,'learned_skill_s2c'}),
	ets:insert(proto_msg_id_record_map,{72,'display_hotbar_s2c'}),
	ets:insert(proto_msg_id_record_map,{73,'update_hotbar_c2s'}),
	ets:insert(proto_msg_id_record_map,{74,'update_hotbar_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{75,'update_skill_s2c'}),
	ets:insert(proto_msg_id_record_map,{81,'quest_list_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{82,'quest_list_remove_s2c'}),
	ets:insert(proto_msg_id_record_map,{83,'quest_list_add_s2c'}),
	ets:insert(proto_msg_id_record_map,{84,'quest_statu_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{85,'questgiver_hello_c2s'}),
	ets:insert(proto_msg_id_record_map,{86,'questgiver_quest_details_s2c'}),
	ets:insert(proto_msg_id_record_map,{87,'questgiver_accept_quest_c2s'}),
	ets:insert(proto_msg_id_record_map,{88,'quest_quit_c2s'}),
	ets:insert(proto_msg_id_record_map,{89,'questgiver_complete_quest_c2s'}),
	ets:insert(proto_msg_id_record_map,{90,'quest_complete_s2c'}),
	ets:insert(proto_msg_id_record_map,{91,'quest_complete_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{92,'questgiver_states_update_c2s'}),
	ets:insert(proto_msg_id_record_map,{93,'questgiver_states_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{94,'quest_details_c2s'}),
	ets:insert(proto_msg_id_record_map,{95,'quest_details_s2c'}),
	ets:insert(proto_msg_id_record_map,{96,'quest_get_adapt_c2s'}),
	ets:insert(proto_msg_id_record_map,{97,'quest_get_adapt_s2c'}),
	ets:insert(proto_msg_id_record_map,{98,'quest_accept_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{99,'quest_direct_complete_c2s'}),
	ets:insert(proto_msg_id_record_map,{101,'add_buff_s2c'}),
	ets:insert(proto_msg_id_record_map,{102,'del_buff_s2c'}),
	ets:insert(proto_msg_id_record_map,{103,'buff_affect_attr_s2c'}),
	ets:insert(proto_msg_id_record_map,{104,'move_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{105,'loot_s2c'}),
	ets:insert(proto_msg_id_record_map,{106,'loot_query_c2s'}),
	ets:insert(proto_msg_id_record_map,{107,'loot_response_s2c'}),
	ets:insert(proto_msg_id_record_map,{108,'loot_pick_c2s'}),
	ets:insert(proto_msg_id_record_map,{109,'loot_remove_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{110,'loot_release_s2c'}),
	ets:insert(proto_msg_id_record_map,{111,'player_level_up_s2c'}),
	ets:insert(proto_msg_id_record_map,{112,'cancel_buff_c2s'}),
	ets:insert(proto_msg_id_record_map,{113,'money_from_monster_s2c'}),
	ets:insert(proto_msg_id_record_map,{120,'update_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{121,'add_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{122,'add_item_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{123,'destroy_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{124,'delete_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{125,'split_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{126,'swap_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{127,'init_onhands_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{128,'npc_storage_items_c2s'}),
	ets:insert(proto_msg_id_record_map,{129,'npc_storage_items_s2c'}),
	ets:insert(proto_msg_id_record_map,{130,'arrange_items_c2s'}),
	ets:insert(proto_msg_id_record_map,{131,'arrange_items_s2c'}),
	ets:insert(proto_msg_id_record_map,{140,'chat_c2s'}),
	ets:insert(proto_msg_id_record_map,{141,'chat_s2c'}),
	ets:insert(proto_msg_id_record_map,{142,'chat_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{143,'loudspeaker_queue_num_c2s'}),
	ets:insert(proto_msg_id_record_map,{144,'loudspeaker_queue_num_s2c'}),
	ets:insert(proto_msg_id_record_map,{145,'loudspeaker_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{146,'chat_private_c2s'}),
	ets:insert(proto_msg_id_record_map,{147,'chat_private_s2c'}),
	ets:insert(proto_msg_id_record_map,{150,'group_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{151,'group_agree_c2s'}),
	ets:insert(proto_msg_id_record_map,{152,'group_create_c2s'}),
	ets:insert(proto_msg_id_record_map,{153,'group_invite_c2s'}),
	ets:insert(proto_msg_id_record_map,{154,'group_accept_c2s'}),
	ets:insert(proto_msg_id_record_map,{155,'group_decline_c2s'}),
	ets:insert(proto_msg_id_record_map,{156,'group_kickout_c2s'}),
	ets:insert(proto_msg_id_record_map,{157,'group_setleader_c2s'}),
	ets:insert(proto_msg_id_record_map,{158,'group_disband_c2s'}),
	ets:insert(proto_msg_id_record_map,{159,'group_depart_c2s'}),
	ets:insert(proto_msg_id_record_map,{160,'group_invite_s2c'}),
	ets:insert(proto_msg_id_record_map,{161,'group_decline_s2c'}),
	ets:insert(proto_msg_id_record_map,{162,'group_destroy_s2c'}),
	ets:insert(proto_msg_id_record_map,{163,'group_list_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{164,'group_cmd_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{165,'group_member_stats_s2c'}),
	ets:insert(proto_msg_id_record_map,{166,'group_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{167,'recruite_c2s'}),
	ets:insert(proto_msg_id_record_map,{168,'recruite_cancel_c2s'}),
	ets:insert(proto_msg_id_record_map,{169,'recruite_query_c2s'}),
	ets:insert(proto_msg_id_record_map,{170,'recruite_query_s2c'}),
	ets:insert(proto_msg_id_record_map,{171,'recruite_cancel_s2c'}),
	ets:insert(proto_msg_id_record_map,{172,'role_recruite_c2s'}),
	ets:insert(proto_msg_id_record_map,{173,'role_recruite_cancel_c2s'}),
	ets:insert(proto_msg_id_record_map,{174,'role_recruite_cancel_s2c'}),
	ets:insert(proto_msg_id_record_map,{175,'aoi_role_group_c2s'}),
	ets:insert(proto_msg_id_record_map,{176,'aoi_role_group_s2c'}),
	ets:insert(proto_msg_id_record_map,{300,'npc_fucnction_common_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{301,'npc_function_c2s'}),
	ets:insert(proto_msg_id_record_map,{302,'npc_function_s2c'}),
	ets:insert(proto_msg_id_record_map,{310,'enum_shoping_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{311,'enum_shoping_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{312,'enum_shoping_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{313,'buy_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{314,'buy_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{315,'sell_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{316,'sell_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{317,'repair_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{340,'fatigue_prompt_with_type_s2c'}),
	ets:insert(proto_msg_id_record_map,{341,'fatigue_login_disabled_s2c'}),
	ets:insert(proto_msg_id_record_map,{350,'fatigue_prompt_s2c'}),
	ets:insert(proto_msg_id_record_map,{351,'fatigue_alert_s2c'}),
	ets:insert(proto_msg_id_record_map,{352,'finish_register_s2c'}),
	ets:insert(proto_msg_id_record_map,{353,'object_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{354,'guild_monster_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{355,'upgrade_guild_monster_c2s'}),
	ets:insert(proto_msg_id_record_map,{357,'change_smith_need_contribution_c2s'}),
	ets:insert(proto_msg_id_record_map,{2270,'get_guild_space_info_c2s'}),%%1月27日加【小五】
	ets:insert(proto_msg_id_record_map,{2271,'open_guild_space_c2s'}),%%1月29日加【小五】
	ets:insert(proto_msg_id_record_map,{2272,'start_qunmojiuxian_c2s'}),%%4月9日加【小五】
	ets:insert(proto_msg_id_record_map,{2278,'qunmojiuxian_vote_c2s'}),%%4月10日加【小五】
	ets:insert(proto_msg_id_record_map,{2277,'qunmojiuxian_accept_vote_c2s'}),%%4月10日加【小五】
	ets:insert(proto_msg_id_record_map,{1961,'guild_storage_init_c2s'}),%%帮会仓库《枫少》
	ets:insert(proto_msg_id_record_map,{1963,'guild_storage_donate_c2s'}),%%帮会仓库存储《枫少》
	ets:insert(proto_msg_id_record_map,{1964,'guild_storage_take_out_c2s'}),%%帮会仓库取出物品《枫少》
	ets:insert(proto_msg_id_record_map,{1980,'guild_storage_log_c2s'}),%%帮会仓库日志《枫少》guild_storage_cancel_apply_c2s
	ets:insert(proto_msg_id_record_map,{1976,'guild_storage_apply_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1971,'guild_storage_init_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{1973,'guild_storage_approve_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{1974,'guild_storage_refuse_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{1975,'guild_storage_refuse_all_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{1968,'guild_storage_distribute_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1977,'guild_storage_self_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{1979,'guild_storage_cancel_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{1969,'guild_storage_set_state_c2s'}),
	ets:insert(proto_msg_id_record_map,{1982,'guild_storage_set_item_state_c2s'}),
	ets:insert(proto_msg_id_record_map,{1983,'guild_storage_sort_items_c2s'}),
	ets:insert(proto_msg_id_record_map,{358,'leave_guild_instance_c2s'}),
	ets:insert(proto_msg_id_record_map,{359,'join_guild_instance_c2s'}),
	ets:insert(proto_msg_id_record_map,{360,'guild_create_c2s'}),
	ets:insert(proto_msg_id_record_map,{361,'guild_disband_c2s'}),
	ets:insert(proto_msg_id_record_map,{362,'guild_member_invite_c2s'}),
	ets:insert(proto_msg_id_record_map,{363,'guild_member_decline_c2s'}),
	ets:insert(proto_msg_id_record_map,{364,'guild_member_accept_c2s'}),
	ets:insert(proto_msg_id_record_map,{365,'guild_member_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{366,'guild_member_depart_c2s'}),
	ets:insert(proto_msg_id_record_map,{367,'guild_member_kickout_c2s'}),
	ets:insert(proto_msg_id_record_map,{368,'guild_set_leader_c2s'}),
	ets:insert(proto_msg_id_record_map,{369,'guild_member_promotion_c2s'}),
	ets:insert(proto_msg_id_record_map,{370,'guild_member_demotion_c2s'}),
	ets:insert(proto_msg_id_record_map,{371,'guild_log_normal_c2s'}),
	ets:insert(proto_msg_id_record_map,{372,'guild_log_event_c2s'}),
	ets:insert(proto_msg_id_record_map,{373,'guild_notice_modify_c2s'}),
	ets:insert(proto_msg_id_record_map,{374,'guild_facilities_accede_rules_c2s'}),
	ets:insert(proto_msg_id_record_map,{375,'guild_facilities_upgrade_c2s'}),
	ets:insert(proto_msg_id_record_map,{376,'guild_facilities_speed_up_c2s'}),
	ets:insert(proto_msg_id_record_map,{377,'guild_rewards_c2s'}),
	ets:insert(proto_msg_id_record_map,{378,'guild_recruite_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{379,'guild_member_contribute_c2s'}),
	ets:insert(proto_msg_id_record_map,{380,'guild_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{381,'guild_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{382,'guild_base_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{383,'guild_member_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{384,'guild_facilities_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{385,'guild_member_delete_s2c'}),
	ets:insert(proto_msg_id_record_map,{386,'guild_member_add_s2c'}),
	ets:insert(proto_msg_id_record_map,{387,'guild_destroy_s2c'}),
	ets:insert(proto_msg_id_record_map,{388,'guild_member_decline_s2c'}),
	ets:insert(proto_msg_id_record_map,{389,'guild_member_invite_s2c'}),
	ets:insert(proto_msg_id_record_map,{391,'guild_recruite_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{392,'guild_log_normal_s2c'}),
	ets:insert(proto_msg_id_record_map,{393,'guild_log_event_s2c'}),
	ets:insert(proto_msg_id_record_map,{394,'guild_get_application_c2s'}),
	ets:insert(proto_msg_id_record_map,{395,'guild_get_application_s2c'}),
	ets:insert(proto_msg_id_record_map,{396,'guild_application_op_c2s'}),
	ets:insert(proto_msg_id_record_map,{397,'guild_change_nickname_c2s'}),
	ets:insert(proto_msg_id_record_map,{398,'guild_change_chatandvoicegroup_c2s'}),
	ets:insert(proto_msg_id_record_map,{399,'guild_update_log_s2c'}),
	ets:insert(proto_msg_id_record_map,{400,'create_role_request_c2s'}),
	ets:insert(proto_msg_id_record_map,{401,'create_role_sucess_s2c'}),
	ets:insert(proto_msg_id_record_map,{402,'create_role_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{403,'inspect_c2s'}),
	ets:insert(proto_msg_id_record_map,{404,'inspect_s2c'}),
	ets:insert(proto_msg_id_record_map,{405,'inspect_faild_s2c'}),
	ets:insert(proto_msg_id_record_map,{410,'user_auth_c2s'}),
	ets:insert(proto_msg_id_record_map,{411,'user_auth_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{412,'enum_skill_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{413,'enum_skill_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{414,'enum_skill_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{415,'skill_learn_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{2055,'skill_auto_learn_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{416,'skill_learn_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{417,'feedback_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{418,'feedback_info_ret_s2c'}),
	ets:insert(proto_msg_id_record_map,{419,'role_respawn_c2s'}),
	ets:insert(proto_msg_id_record_map,{420,'other_login_s2c'}),
	ets:insert(proto_msg_id_record_map,{421,'block_s2c'}),
	ets:insert(proto_msg_id_record_map,{422,'is_jackaroo_s2c'}),
	ets:insert(proto_msg_id_record_map,{423,'is_visitor_c2s'}),
	ets:insert(proto_msg_id_record_map,{425,'is_finish_visitor_c2s'}),
	ets:insert(proto_msg_id_record_map,{426,'visitor_rename_s2c'}),
	ets:insert(proto_msg_id_record_map,{427,'visitor_rename_c2s'}),
	ets:insert(proto_msg_id_record_map,{428,'visitor_rename_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{429,'mall_item_list_c2s'}),
	ets:insert(proto_msg_id_record_map,{430,'mall_item_list_s2c'}),
	ets:insert(proto_msg_id_record_map,{438,'init_mall_item_list_c2s'}),
	ets:insert(proto_msg_id_record_map,{439,'init_mall_item_list_s2c'}),
	ets:insert(proto_msg_id_record_map,{431,'buy_mall_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{432,'init_hot_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{433,'init_latest_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{434,'mall_item_list_special_c2s'}),
	ets:insert(proto_msg_id_record_map,{435,'mall_item_list_special_s2c'}),
	ets:insert(proto_msg_id_record_map,{436,'mall_item_list_sales_c2s'}),
	ets:insert(proto_msg_id_record_map,{437,'mall_item_list_sales_s2c'}),
	ets:insert(proto_msg_id_record_map,{440,'change_role_mall_integral_s2c'}),
	ets:insert(proto_msg_id_record_map,{450,'query_player_option_c2s'}),
	ets:insert(proto_msg_id_record_map,{451,'query_player_option_s2c'}),
	ets:insert(proto_msg_id_record_map,{452,'replace_player_option_c2s'}),
	ets:insert(proto_msg_id_record_map,{453,'info_back_c2s'}),
	ets:insert(proto_msg_id_record_map,{469,'revert_black_c2s'}),
	ets:insert(proto_msg_id_record_map,{470,'revert_black_s2c'}),
	ets:insert(proto_msg_id_record_map,{471,'init_signature_s2c'}),
	ets:insert(proto_msg_id_record_map,{472,'add_signature_c2s'}),
	ets:insert(proto_msg_id_record_map,{473,'get_friend_signature_c2s'}),
	ets:insert(proto_msg_id_record_map,{474,'get_friend_signature_s2c'}),
	ets:insert(proto_msg_id_record_map,{475,'set_black_c2s'}),
	ets:insert(proto_msg_id_record_map,{476,'set_black_s2c'}),
	ets:insert(proto_msg_id_record_map,{477,'delete_black_c2s'}),
	ets:insert(proto_msg_id_record_map,{478,'delete_black_s2c'}),
	ets:insert(proto_msg_id_record_map,{479,'black_list_s2c'}),
	ets:insert(proto_msg_id_record_map,{480,'myfriends_c2s'}),
	ets:insert(proto_msg_id_record_map,{481,'myfriends_s2c'}),
	ets:insert(proto_msg_id_record_map,{482,'add_friend_c2s'}),
	ets:insert(proto_msg_id_record_map,{483,'add_friend_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{484,'add_friend_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{485,'becare_friend_s2c'}),
	ets:insert(proto_msg_id_record_map,{486,'delete_friend_c2s'}),
	ets:insert(proto_msg_id_record_map,{487,'delete_friend_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{488,'delete_friend_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{489,'online_friend_s2c'}),
	ets:insert(proto_msg_id_record_map,{490,'offline_friend_s2c'}),
	ets:insert(proto_msg_id_record_map,{491,'detail_friend_c2s'}),
	ets:insert(proto_msg_id_record_map,{492,'detail_friend_s2c'}),
	ets:insert(proto_msg_id_record_map,{493,'detail_friend_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{494,'position_friend_c2s'}),
	ets:insert(proto_msg_id_record_map,{495,'position_friend_s2c'}),
	ets:insert(proto_msg_id_record_map,{496,'position_friend_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{497,'add_black_c2s'}),
	ets:insert(proto_msg_id_record_map,{498,'add_black_s2c'}),
	ets:insert(proto_msg_id_record_map,{501,'lottery_lefttime_s2c'}),
	ets:insert(proto_msg_id_record_map,{502,'lottery_leftcount_s2c'}),
	ets:insert(proto_msg_id_record_map,{504,'lottery_clickslot_c2s'}),
	ets:insert(proto_msg_id_record_map,{505,'lottery_clickslot_s2c'}),
	ets:insert(proto_msg_id_record_map,{506,'lottery_otherslot_s2c'}),
	ets:insert(proto_msg_id_record_map,{507,'lottery_notic_s2c'}),
	ets:insert(proto_msg_id_record_map,{508,'lottery_clickslot_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{509,'lottery_querystatus_c2s'}),
	ets:insert(proto_msg_id_record_map,{510,'start_block_training_c2s'}),
	ets:insert(proto_msg_id_record_map,{511,'start_block_training_s2c'}),
	ets:insert(proto_msg_id_record_map,{512,'end_block_training_c2s'}),
	ets:insert(proto_msg_id_record_map,{513,'end_block_training_s2c'}),
	ets:insert(proto_msg_id_record_map,{530,'mail_status_query_c2s'}),
	ets:insert(proto_msg_id_record_map,{531,'mail_status_query_s2c'}),
	ets:insert(proto_msg_id_record_map,{532,'mail_arrived_s2c'}),
	ets:insert(proto_msg_id_record_map,{533,'mail_query_detail_c2s'}),
	ets:insert(proto_msg_id_record_map,{534,'mail_query_detail_s2c'}),
	ets:insert(proto_msg_id_record_map,{535,'mail_get_addition_c2s'}),
	ets:insert(proto_msg_id_record_map,{536,'mail_get_addition_s2c'}),
	ets:insert(proto_msg_id_record_map,{537,'mail_send_c2s'}),
	ets:insert(proto_msg_id_record_map,{538,'mail_delete_c2s'}),
	ets:insert(proto_msg_id_record_map,{539,'mail_delete_s2c'}),
	ets:insert(proto_msg_id_record_map,{540,'mail_operator_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{541,'mail_sucess_s2c'}),
	ets:insert(proto_msg_id_record_map,{560,'trade_role_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{561,'trade_role_accept_c2s'}),
	ets:insert(proto_msg_id_record_map,{562,'trade_role_decline_c2s'}),
	ets:insert(proto_msg_id_record_map,{563,'set_trade_money_c2s'}),
	ets:insert(proto_msg_id_record_map,{564,'set_trade_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{565,'cancel_trade_c2s'}),
	ets:insert(proto_msg_id_record_map,{566,'trade_role_lock_c2s'}),
	ets:insert(proto_msg_id_record_map,{567,'trade_role_dealit_c2s'}),
	ets:insert(proto_msg_id_record_map,{570,'trade_role_errno_s2c'}),
	ets:insert(proto_msg_id_record_map,{571,'trade_begin_s2c'}),
	ets:insert(proto_msg_id_record_map,{572,'update_trade_status_s2c'}),
	ets:insert(proto_msg_id_record_map,{573,'trade_role_lock_s2c'}),
	ets:insert(proto_msg_id_record_map,{574,'trade_role_dealit_s2c'}),
	ets:insert(proto_msg_id_record_map,{575,'trade_role_decline_s2c'}),
	ets:insert(proto_msg_id_record_map,{576,'trade_role_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{577,'cancel_trade_s2c'}),
	ets:insert(proto_msg_id_record_map,{578,'trade_success_s2c'}),
	%%飞剑功能
    ets:insert(proto_msg_id_record_map,{2290,'wing_level_up_c2s'}),
	ets:insert(proto_msg_id_record_map,{2291,'wing_phase_up_c2s'}),
	ets:insert(proto_msg_id_record_map,{2293,'wing_quality_up_c2s'}),
	ets:insert(proto_msg_id_record_map,{2292,'wing_intensify_c2s'}),
	ets:insert(proto_msg_id_record_map,{2295,'wing_enchant_c2s'}),
	ets:insert(proto_msg_id_record_map,{2297,'wing_enchant_replace_c2s'}),
	
	ets:insert(proto_msg_id_record_map,{600,'equipment_riseup_c2s'}),
	ets:insert(proto_msg_id_record_map,{601,'equipment_riseup_s2c'}),
	ets:insert(proto_msg_id_record_map,{602,'equipment_riseup_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{603,'equipment_sock_c2s'}),
	ets:insert(proto_msg_id_record_map,{604,'equipment_sock_s2c'}),
	ets:insert(proto_msg_id_record_map,{605,'equipment_sock_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{606,'equipment_inlay_c2s'}),
	ets:insert(proto_msg_id_record_map,{607,'equipment_inlay_s2c'}),
	ets:insert(proto_msg_id_record_map,{608,'equipment_inlay_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{609,'equipment_stone_remove_c2s'}),
	ets:insert(proto_msg_id_record_map,{610,'equipment_stone_remove_s2c'}),
	ets:insert(proto_msg_id_record_map,{611,'equipment_stone_remove_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{612,'equipment_stonemix_single_c2s'}),
     %%批量合成%%
    ets:insert(proto_msg_id_record_map,{599,'equipment_stonemix_c2s'}),
    ets:insert(proto_msg_id_record_map,{595,'equipment_stonemix_bat_result_s2c'}),

	ets:insert(proto_msg_id_record_map,{613,'equipment_stonemix_s2c'}),
	ets:insert(proto_msg_id_record_map,{614,'equipment_stonemix_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{615,'equipment_upgrade_c2s'}),
	ets:insert(proto_msg_id_record_map,{616,'equipment_upgrade_s2c'}),
	ets:insert(proto_msg_id_record_map,{617,'equipment_enchant_c2s'}),
	ets:insert(proto_msg_id_record_map,{618,'equipment_enchant_s2c'}),
	ets:insert(proto_msg_id_record_map,{619,'equipment_recast_c2s'}),
	ets:insert(proto_msg_id_record_map,{620,'equipment_recast_s2c'}),
	ets:insert(proto_msg_id_record_map,{621,'equipment_recast_confirm_c2s'}),
	ets:insert(proto_msg_id_record_map,{622,'equipment_convert_c2s'}),
	ets:insert(proto_msg_id_record_map,{623,'equipment_convert_s2c'}),
	ets:insert(proto_msg_id_record_map,{624,'equipment_move_c2s'}),
	ets:insert(proto_msg_id_record_map,{625,'equipment_move_s2c'}),
	ets:insert(proto_msg_id_record_map,{626,'equipment_remove_seal_s2c'}),
	ets:insert(proto_msg_id_record_map,{627,'equipment_remove_seal_c2s'}),
	ets:insert(proto_msg_id_record_map,{628,'equipment_fenjie_c2s'}),
	ets:insert(proto_msg_id_record_map,{629,'equip_fenjie_optresult_s2c'}),
	%%ets:insert(proto_msg_id_record_map,{630,'achieve_open_c2s'}),%%@@wb
    ets:insert(proto_msg_id_record_map,{630,'achieve_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{631,'achieve_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{632,'achieve_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{633,'achieve_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{634,'achieve_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{640,'goals_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{641,'goals_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{642,'goals_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{643,'goals_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{644,'goals_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{650,'loop_tower_enter_c2s'}),
	ets:insert(proto_msg_id_record_map,{651,'loop_tower_enter_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{652,'loop_tower_masters_c2s'}),
	ets:insert(proto_msg_id_record_map,{653,'loop_tower_masters_s2c'}),
	ets:insert(proto_msg_id_record_map,{654,'loop_tower_enter_s2c'}),
	ets:insert(proto_msg_id_record_map,{655,'loop_tower_challenge_c2s'}),
	ets:insert(proto_msg_id_record_map,{656,'loop_tower_challenge_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{657,'loop_tower_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{658,'loop_tower_challenge_again_c2s'}),
	ets:insert(proto_msg_id_record_map,{659,'loop_tower_enter_higher_s2c'}),
	ets:insert(proto_msg_id_record_map,{670,'vip_ui_c2s'}),
	ets:insert(proto_msg_id_record_map,{671,'vip_ui_s2c'}),
	ets:insert(proto_msg_id_record_map,{672,'vip_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{673,'vip_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{674,'vip_level_up_s2c'}),
	ets:insert(proto_msg_id_record_map,{675,'vip_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{676,'vip_npc_enum_s2c'}),
	ets:insert(proto_msg_id_record_map,{677,'login_bonus_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{678,'vip_role_use_flyshoes_s2c'}),
	ets:insert(proto_msg_id_record_map,{679,'join_vip_map_c2s'}),
	ets:insert(proto_msg_id_record_map,{700,'query_system_switch_c2s'}),
	ets:insert(proto_msg_id_record_map,{701,'system_status_s2c'}),
	ets:insert(proto_msg_id_record_map,{710,'duel_invite_c2s'}),
	ets:insert(proto_msg_id_record_map,{711,'duel_decline_c2s'}),
	ets:insert(proto_msg_id_record_map,{712,'duel_accept_c2s'}),
	ets:insert(proto_msg_id_record_map,{720,'duel_invite_s2c'}),
	ets:insert(proto_msg_id_record_map,{721,'duel_decline_s2c'}),
	ets:insert(proto_msg_id_record_map,{722,'duel_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{723,'duel_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{730,'set_pkmodel_c2s'}),
	ets:insert(proto_msg_id_record_map,{731,'set_pkmodel_faild_s2c'}),
	ets:insert(proto_msg_id_record_map,{733,'clear_crime_c2s'}),
	ets:insert(proto_msg_id_record_map,{734,'clear_crime_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{740,'query_time_c2s'}),
	ets:insert(proto_msg_id_record_map,{741,'query_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{742,'stop_move_c2s'}),
	ets:insert(proto_msg_id_record_map,{800,'identify_verify_c2s'}),
	ets:insert(proto_msg_id_record_map,{801,'identify_verify_s2c'}),
	ets:insert(proto_msg_id_record_map,{809,'mp_package_s2c'}),
	ets:insert(proto_msg_id_record_map,{810,'fly_shoes_c2s'}),
	ets:insert(proto_msg_id_record_map,{811,'hp_package_s2c'}),
	ets:insert(proto_msg_id_record_map,{812,'npc_swap_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{813,'use_target_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{818,'join_battle_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{819,'tangle_battlefield_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{820,'battle_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{821,'battle_join_c2s'}),
	ets:insert(proto_msg_id_record_map,{822,'battle_leave_c2s'}),
	ets:insert(proto_msg_id_record_map,{823,'battle_self_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{824,'tangle_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{825,'tangle_remove_s2c'}),
	ets:insert(proto_msg_id_record_map,{826,'battle_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{827,'battle_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{828,'battle_other_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{829,'battle_waiting_s2c'}),
	ets:insert(proto_msg_id_record_map,{830,'instance_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{831,'get_instance_log_c2s'}),
	ets:insert(proto_msg_id_record_map,{832,'get_instance_log_s2c'}),
	ets:insert(proto_msg_id_record_map,{833,'tangle_records_s2c'}),
	ets:insert(proto_msg_id_record_map,{834,'tangle_records_c2s'}),
	ets:insert(proto_msg_id_record_map,{835,'tangle_topman_pos_s2c'}),
	ets:insert(proto_msg_id_record_map,{836,'tangle_more_records_c2s'}),
	ets:insert(proto_msg_id_record_map,{837,'tangle_more_records_s2c'}),
	ets:insert(proto_msg_id_record_map,{838,'instance_exit_c2s'}),
	ets:insert(proto_msg_id_record_map,{840,'instance_leader_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{841,'instance_leader_join_c2s'}),
	ets:insert(proto_msg_id_record_map,{850,'start_everquest_s2c'}),
	ets:insert(proto_msg_id_record_map,{851,'update_everquest_s2c'}),
	ets:insert(proto_msg_id_record_map,{852,'refresh_everquest_c2s'}),
	ets:insert(proto_msg_id_record_map,{853,'refresh_everquest_s2c'}),
	ets:insert(proto_msg_id_record_map,{854,'npc_start_everquest_c2s'}),
	ets:insert(proto_msg_id_record_map,{855,'npc_everquests_enum_c2s'}),
	ets:insert(proto_msg_id_record_map,{856,'npc_everquests_enum_s2c'}),
	ets:insert(proto_msg_id_record_map,{857,'everquest_list_s2c'}),
	ets:insert(proto_msg_id_record_map,{858,'instance_end_seconds_s2c'}),
	ets:insert(proto_msg_id_record_map,{859,'refresh_everquest_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{900,'init_pets_s2c'}),
	ets:insert(proto_msg_id_record_map,{901,'create_pet_s2c'}),
	ets:insert(proto_msg_id_record_map,{902,'summon_pet_c2s'}),
	ets:insert(proto_msg_id_record_map,{903,'pet_move_c2s'}),
	ets:insert(proto_msg_id_record_map,{904,'pet_stop_move_c2s'}),
	ets:insert(proto_msg_id_record_map,{905,'pet_attack_c2s'}),
	ets:insert(proto_msg_id_record_map,{906,'pet_rename_c2s'}),
	ets:insert(proto_msg_id_record_map,{907,'pet_levelup_c2s'}),
	ets:insert(proto_msg_id_record_map,{908,'pet_speed_levelup_c2s'}),
	ets:insert(proto_msg_id_record_map,{909,'pet_present_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{910,'pet_talent_levelup_c2s'}),
	ets:insert(proto_msg_id_record_map,{911,'pet_talent_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{912,'pet_xs_c2s'}),
	ets:insert(proto_msg_id_record_map,{913,'pet_xs_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{914,'pet_up_growth_s2c'}),
	ets:insert(proto_msg_id_record_map,{4000,'use_pet_egg_ext_c2s'}),
	ets:insert(proto_msg_id_record_map,{916,'pet_opt_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{917,'pet_learn_skill_c2s'}),
	ets:insert(proto_msg_id_record_map,{918,'pet_unlock_skill_c2s'}),
	ets:insert(proto_msg_id_record_map,{919,'pet_forget_skill_c2s'}),
	ets:insert(proto_msg_id_record_map,{920,'pet_delete_s2c'}),
	ets:insert(proto_msg_id_record_map,{921,'pet_swap_slot_c2s'}),
	ets:insert(proto_msg_id_record_map,{922,'inspect_pet_c2s'}),
	ets:insert(proto_msg_id_record_map,{923,'inspect_pet_s2c'}),
	ets:insert(proto_msg_id_record_map,{924,'pet_riseup_c2s'}),
	ets:insert(proto_msg_id_record_map,{925,'pet_riseup_s2c'}),
	%%ets:insert(proto_msg_id_record_map,{926,'pet_skill_slot_lock_c2s'}),
	%%ets:insert(proto_msg_id_record_map,{927,'update_pet_skill_slot_s2c'}),
	ets:insert(proto_msg_id_record_map,{928,'update_pet_skill_s2c'}),
	ets:insert(proto_msg_id_record_map,{929,'pet_skill_book_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{930,'pet_skill_book_refresh_c2s'}),
	ets:insert(proto_msg_id_record_map,{931,'pet_learn_skill_cover_best_s2c'}),
	ets:insert(proto_msg_id_record_map,{932,'pet_inheritance_c2s'}),
	ets:insert(proto_msg_id_record_map,{933,'pet_inheritance_s2c'}),
	ets:insert(proto_msg_id_record_map,{934,'pet_shop_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{936,'pet_shop_buy_c2s'}),
	ets:insert(proto_msg_id_record_map,{937,'pet_get_skill_book_c2s'}),
	ets:insert(proto_msg_id_record_map,{938,'pet_shop_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{940,'buy_pet_slot_c2s'}),
	ets:insert(proto_msg_id_record_map,{941,'update_pet_slot_num_s2c'}),
	ets:insert(proto_msg_id_record_map,{942,'pet_feed_c2s'}),
	ets:insert(proto_msg_id_record_map,{945,'pet_advance_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{946,'pet_advance_c2s'}),
	ets:insert(proto_msg_id_record_map,{947,'pet_auto_advance_c2s'}),
	ets:insert(proto_msg_id_record_map,{948,'pet_auto_advance_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{950,'pet_training_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{951,'pet_start_training_c2s'}),
	ets:insert(proto_msg_id_record_map,{952,'pet_stop_training_c2s'}),
	ets:insert(proto_msg_id_record_map,{953,'pet_speedup_training_c2s'}),
	ets:insert(proto_msg_id_record_map,{954,'pet_training_init_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{960,'explore_storage_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{961,'explore_storage_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{962,'explore_storage_init_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{963,'explore_storage_getitem_c2s'}),
	ets:insert(proto_msg_id_record_map,{964,'explore_storage_getallitems_c2s'}),
	ets:insert(proto_msg_id_record_map,{965,'explore_storage_updateitem_s2c'}),
	ets:insert(proto_msg_id_record_map,{966,'explore_storage_additem_s2c'}),
	ets:insert(proto_msg_id_record_map,{967,'explore_storage_delitem_s2c'}),
	ets:insert(proto_msg_id_record_map,{968,'explore_storage_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{970,'pet_explore_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{971,'pet_explore_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{972,'pet_explore_start_c2s'}),
	ets:insert(proto_msg_id_record_map,{973,'pet_explore_speedup_c2s'}),
	ets:insert(proto_msg_id_record_map,{974,'pet_explore_stop_c2s'}),
	ets:insert(proto_msg_id_record_map,{975,'pet_explore_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{976,'pet_explore_gain_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{981,'treasure_chest_flush_c2s'}),
	ets:insert(proto_msg_id_record_map,{982,'treasure_chest_flush_ok_s2c'}),
	ets:insert(proto_msg_id_record_map,{983,'treasure_chest_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{984,'treasure_chest_raffle_c2s'}),
	ets:insert(proto_msg_id_record_map,{985,'treasure_chest_raffle_ok_s2c'}),
	ets:insert(proto_msg_id_record_map,{986,'treasure_chest_obtain_c2s'}),
	ets:insert(proto_msg_id_record_map,{987,'treasure_chest_obtain_ok_s2c'}),
	ets:insert(proto_msg_id_record_map,{989,'treasure_chest_query_c2s'}),
	ets:insert(proto_msg_id_record_map,{990,'treasure_chest_query_s2c'}),
	ets:insert(proto_msg_id_record_map,{991,'treasure_chest_broad_s2c'}),
	ets:insert(proto_msg_id_record_map,{992,'treasure_chest_disable_c2s'}),
	ets:insert(proto_msg_id_record_map,{995,'beads_pray_request_c2s'}),
	ets:insert(proto_msg_id_record_map,{996,'beads_pray_response_s2c'}),
	ets:insert(proto_msg_id_record_map,{997,'beads_pray_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{1001,'enum_exchange_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1002,'enum_exchange_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{1003,'enum_exchange_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{1004,'exchange_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1005,'exchange_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{1010,'battle_reward_by_records_c2s'}),
	ets:insert(proto_msg_id_record_map,{1020,'timelimit_gift_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1021,'get_timelimit_gift_c2s'}),
	ets:insert(proto_msg_id_record_map,{1022,'timelimit_gift_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1023,'timelimit_gift_over_s2c'}),
	ets:insert(proto_msg_id_record_map,{2020,'paimai_sell_c2s'}),%%2月18日加【xiaowu】
	ets:insert(proto_msg_id_record_map,{2023,'paimai_detail_c2s'}),%%2月18日加【xiaowu】
	ets:insert(proto_msg_id_record_map,{2021,'paimai_recede_c2s'}),%%2月25日加【xiaowu】
	ets:insert(proto_msg_id_record_map,{2029,'paimai_search_by_sort_c2s'}),%%3月4日加【xiaowu】
	ets:insert(proto_msg_id_record_map,{2027,'paimai_search_by_string_c2s'}),%%3月4日加【xiaowu】
	ets:insert(proto_msg_id_record_map,{2028,'paimai_search_by_grade_c2s'}),%%3月4日加【xiaowu】
	ets:insert(proto_msg_id_record_map,{2022,'paimai_buy_c2s'}),%%3月7日加【xiaowu】
	ets:insert(proto_msg_id_record_map,{1030,'stall_sell_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1031,'stall_recede_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1033,'stalls_search_c2s'}),
	ets:insert(proto_msg_id_record_map,{1034,'stall_detail_c2s'}),
	ets:insert(proto_msg_id_record_map,{1035,'stall_buy_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1036,'stall_rename_c2s'}),
	ets:insert(proto_msg_id_record_map,{1037,'stalls_search_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1040,'stall_detail_s2c'}),
	ets:insert(proto_msg_id_record_map,{1041,'stalls_search_s2c'}),
	ets:insert(proto_msg_id_record_map,{1042,'stall_log_add_s2c'}),
	ets:insert(proto_msg_id_record_map,{1043,'stall_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1044,'stall_role_detail_c2s'}),
	ets:insert(proto_msg_id_record_map,{1045,'stalls_search_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{1087,'guild_battlefield_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1088,'battlefield_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{1089,'battlefield_info_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1090,'battlefield_totle_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1091,'yhzq_battlefield_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1098,'yhzq_all_battle_over_s2c'}),
	ets:insert(proto_msg_id_record_map,{1099,'yhzq_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1105,'notify_to_join_yhzq_s2c'}),
	ets:insert(proto_msg_id_record_map,{1106,'join_yhzq_c2s'}),
	ets:insert(proto_msg_id_record_map,{1107,'leave_yhzq_c2s'}),
	ets:insert(proto_msg_id_record_map,{1108,'yhzq_award_s2c'}),
	ets:insert(proto_msg_id_record_map,{1109,'yhzq_award_c2s'}),
	ets:insert(proto_msg_id_record_map,{1110,'yhzq_camp_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1111,'yhzq_zone_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1114,'yhzq_battle_self_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{1115,'yhzq_battle_other_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{1116,'yhzq_battle_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1117,'yhzq_battle_remove_s2c'}),
	ets:insert(proto_msg_id_record_map,{1118,'yhzq_battle_player_pos_s2c'}),
	ets:insert(proto_msg_id_record_map,{1119,'yhzq_battle_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1120,'init_random_rolename_s2c'}),
	ets:insert(proto_msg_id_record_map,{1121,'reset_random_rolename_c2s'}),
	ets:insert(proto_msg_id_record_map,{1122,'answer_sign_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1123,'answer_sign_request_c2s'}),
	ets:insert(proto_msg_id_record_map,{1124,'answer_sign_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{1125,'answer_start_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1126,'answer_question_c2s'}),
	ets:insert(proto_msg_id_record_map,{1127,'answer_question_s2c'}),
	ets:insert(proto_msg_id_record_map,{1128,'answer_question_ranklist_s2c'}),
	ets:insert(proto_msg_id_record_map,{1129,'answer_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1130,'answer_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1131,'offline_exp_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1132,'offline_exp_quests_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1133,'offline_exp_exchange_c2s'}),
	ets:insert(proto_msg_id_record_map,{1134,'offline_exp_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1135,'offline_exp_exchange_gold_c2s'}),
	ets:insert(proto_msg_id_record_map,{1140,'congratulations_levelup_remind_s2c'}),
	ets:insert(proto_msg_id_record_map,{1141,'congratulations_levelup_c2s'}),
	ets:insert(proto_msg_id_record_map,{1142,'congratulations_levelup_s2c'}),
	ets:insert(proto_msg_id_record_map,{1143,'congratulations_receive_s2c'}),
	ets:insert(proto_msg_id_record_map,{1144,'congratulations_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1145,'congratulations_received_c2s'}),
	ets:insert(proto_msg_id_record_map,{1160,'treasure_buffer_s2c'}),
	ets:insert(proto_msg_id_record_map,{1161,'gift_card_state_s2c'}),
	ets:insert(proto_msg_id_record_map,{1162,'gift_card_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{1163,'gift_card_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{1170,'chess_spirit_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1171,'chess_spirit_role_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1172,'chess_spirit_update_power_s2c'}),
	ets:insert(proto_msg_id_record_map,{1173,'chess_spirit_update_skill_s2c'}),
	ets:insert(proto_msg_id_record_map,{1174,'chess_spirit_update_chess_power_s2c'}),
	ets:insert(proto_msg_id_record_map,{1175,'chess_spirit_skill_levelup_c2s'}),
	ets:insert(proto_msg_id_record_map,{1176,'chess_spirit_cast_skill_c2s'}),
	ets:insert(proto_msg_id_record_map,{1177,'chess_spirit_cast_chess_skill_c2s'}),
	ets:insert(proto_msg_id_record_map,{1178,'chess_spirit_opt_result_s2s'}),
	ets:insert(proto_msg_id_record_map,{1179,'chess_spirit_log_c2s'}),
	ets:insert(proto_msg_id_record_map,{1180,'chess_spirit_log_s2c'}),
	ets:insert(proto_msg_id_record_map,{1181,'chess_spirit_get_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1182,'chess_spirit_quit_c2s'}),
	ets:insert(proto_msg_id_record_map,{1183,'chess_spirit_game_over_s2c'}),
	ets:insert(proto_msg_id_record_map,{1184,'chess_spirit_prepare_s2c'}),
	ets:insert(proto_msg_id_record_map,{1200,'guild_get_shop_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1201,'guild_get_shop_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{1202,'guild_shop_buy_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1203,'guild_get_treasure_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1204,'guild_get_treasure_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{1205,'guild_treasure_buy_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1206,'guild_treasure_set_price_c2s'}),
	ets:insert(proto_msg_id_record_map,{1207,'guild_treasure_update_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{1208,'publish_guild_quest_c2s'}),
	ets:insert(proto_msg_id_record_map,{1209,'update_guild_quest_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1210,'update_guild_apply_state_s2c'}),
	ets:insert(proto_msg_id_record_map,{1211,'update_guild_update_apply_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1212,'guild_update_apply_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1213,'get_guild_notice_c2s'}),
	ets:insert(proto_msg_id_record_map,{1214,'send_guild_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1215,'guild_shop_update_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{1216,'change_guild_battle_limit_c2s'}),
	ets:insert(proto_msg_id_record_map,{1217,'change_guild_right_limit_s2c'}),
	ets:insert(proto_msg_id_record_map,{1218,'guild_have_guildbattle_right_s2c'}),
	ets:insert(proto_msg_id_record_map,{1219,'guild_bonfire_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{1220,'add_levelup_opt_levels_s2c'}),
	ets:insert(proto_msg_id_record_map,{1221,'levelup_opt_c2s'}),
	ets:insert(proto_msg_id_record_map,{1222,'guild_bonfire_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1230,'activity_forecast_begin_s2c'}),
	ets:insert(proto_msg_id_record_map,{1231,'activity_forecast_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1235,'system_broadcast_s2c'}),
	ets:insert(proto_msg_id_record_map,{1240,'moneygame_left_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{1241,'moneygame_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1242,'moneygame_prepare_s2c'}),
	ets:insert(proto_msg_id_record_map,{1243,'moneygame_cur_sec_s2c'}),
	ets:insert(proto_msg_id_record_map,{1245,'guild_mastercall_s2c'}),
	ets:insert(proto_msg_id_record_map,{1246,'guild_mastercall_accept_c2s'}),
	ets:insert(proto_msg_id_record_map,{1247,'guild_mastercall_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{1248,'guild_member_pos_c2s'}),
	ets:insert(proto_msg_id_record_map,{1249,'guild_member_pos_s2c'}),
	ets:insert(proto_msg_id_record_map,{1250,'sitdown_c2s'}),
	ets:insert(proto_msg_id_record_map,{1251,'stop_sitdown_c2s'}),
	ets:insert(proto_msg_id_record_map,{1252,'companion_sitdown_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{1253,'companion_sitdown_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{1254,'companion_sitdown_start_c2s'}),
	ets:insert(proto_msg_id_record_map,{1255,'companion_sitdown_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1256,'companion_reject_c2s'}),
	ets:insert(proto_msg_id_record_map,{1257,'companion_reject_s2c'}),
	ets:insert(proto_msg_id_record_map,{1258,'dragon_fight_faction_s2c'}),
	ets:insert(proto_msg_id_record_map,{1259,'dragon_fight_left_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{1260,'dragon_fight_state_s2c'}),
	ets:insert(proto_msg_id_record_map,{1261,'dragon_fight_num_c2s'}),
	ets:insert(proto_msg_id_record_map,{1262,'dragon_fight_num_s2c'}),
	ets:insert(proto_msg_id_record_map,{1263,'dragon_fight_faction_c2s'}),
	ets:insert(proto_msg_id_record_map,{1264,'dragon_fight_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{1265,'dragon_fight_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1266,'dragon_fight_join_c2s'}),
	ets:insert(proto_msg_id_record_map,{1267,'star_spawns_section_s2c'}),
	ets:insert(proto_msg_id_record_map,{1276,'venation_advanced_start_c2s'}),
	ets:insert(proto_msg_id_record_map,{1277,'venation_advanced_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1278,'venation_advanced_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1280,'venation_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1281,'venation_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1282,'venation_shareexp_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1283,'venation_active_point_start_c2s'}),
	ets:insert(proto_msg_id_record_map,{1284,'venation_active_point_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1285,'venation_active_point_end_c2s'}),
	ets:insert(proto_msg_id_record_map,{1286,'venation_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1287,'venation_time_countdown_s2c'}),
	ets:insert(proto_msg_id_record_map,{1288,'other_venation_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1290,'server_travel_tag_s2c'}),
	ets:insert(proto_msg_id_record_map,{1300,'continuous_logging_gift_c2s'}),
	ets:insert(proto_msg_id_record_map,{1301,'continuous_logging_board_c2s'}),
	ets:insert(proto_msg_id_record_map,{1302,'continuous_days_clear_c2s'}),
	ets:insert(proto_msg_id_record_map,{1303,'continuous_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1304,'continuous_logging_board_s2c'}),
	ets:insert(proto_msg_id_record_map,{1310,'treasure_storage_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1311,'treasure_storage_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1312,'treasure_storage_init_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1313,'treasure_storage_getitem_c2s'}),
	ets:insert(proto_msg_id_record_map,{1314,'treasure_storage_getallitems_c2s'}),
	ets:insert(proto_msg_id_record_map,{1315,'treasure_storage_updateitem_s2c'}),
	ets:insert(proto_msg_id_record_map,{1316,'treasure_storage_additem_s2c'}),
	ets:insert(proto_msg_id_record_map,{1317,'treasure_storage_delitem_s2c'}),
	ets:insert(proto_msg_id_record_map,{1318,'treasure_storage_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1400,'activity_value_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1401,'activity_value_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1402,'activity_value_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1403,'activity_value_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1404,'activity_value_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1410,'activity_state_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1411,'activity_state_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1412,'activity_state_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1413,'activity_boss_born_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1414,'activity_boss_born_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1415,'activity_boss_born_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1416,'first_charge_gift_state_s2c'}),
	ets:insert(proto_msg_id_record_map,{1417,'first_charge_gift_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1418,'first_charge_gift_reward_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1428,'rank_get_rank_c2s'}),
	ets:insert(proto_msg_id_record_map,{1429,'rank_get_rank_role_c2s'}),
	ets:insert(proto_msg_id_record_map,{1430,'rank_loop_tower_s2c'}),
	ets:insert(proto_msg_id_record_map,{1431,'rank_killer_s2c'}),
	ets:insert(proto_msg_id_record_map,{1432,'rank_moneys_s2c'}),
	ets:insert(proto_msg_id_record_map,{1433,'rank_melee_power_s2c'}),
	ets:insert(proto_msg_id_record_map,{1434,'rank_range_power_s2c'}),
	ets:insert(proto_msg_id_record_map,{1435,'rank_magic_power_s2c'}),
	ets:insert(proto_msg_id_record_map,{1436,'rank_loop_tower_num_s2c'}),
	ets:insert(proto_msg_id_record_map,{1437,'rank_level_s2c'}),
	ets:insert(proto_msg_id_record_map,{1438,'rank_answer_s2c'}),
	ets:insert(proto_msg_id_record_map,{1439,'rank_get_rank_role_s2c'}),
	ets:insert(proto_msg_id_record_map,{1440,'rank_disdain_role_c2s'}),
	ets:insert(proto_msg_id_record_map,{1441,'rank_praise_role_c2s'}),
	ets:insert(proto_msg_id_record_map,{1442,'rank_judge_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1443,'rank_chess_spirits_single_s2c'}),
	ets:insert(proto_msg_id_record_map,{1444,'rank_chess_spirits_team_s2c'}),
	ets:insert(proto_msg_id_record_map,{1445,'facebook_bind_check_c2s'}),
	ets:insert(proto_msg_id_record_map,{1446,'facebook_bind_check_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1447,'guild_clear_nickname_c2s'}),
	ets:insert(proto_msg_id_record_map,{1448,'everyday_show_s2c'}),
	ets:insert(proto_msg_id_record_map,{1450,'rank_judge_to_other_s2c'}),
	ets:insert(proto_msg_id_record_map,{1451,'rank_talent_score_s2c'}),
	ets:insert(proto_msg_id_record_map,{1452,'rank_mail_line_s2c'}),
	ets:insert(proto_msg_id_record_map,{1453,'rank_get_main_line_rank_c2s'}),
	ets:insert(proto_msg_id_record_map,{1454,'rank_fighting_force_s2c'}),
	ets:insert(proto_msg_id_record_map,{1460,'welfare_panel_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1461,'welfare_panel_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1462,'welfare_gifepacks_state_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1463,'welfare_gold_exchange_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1464,'welfare_gold_exchange_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1465,'welfare_gold_exchange_c2s'}),
	ets:insert(proto_msg_id_record_map,{1466,'ride_opt_c2s'}),
	ets:insert(proto_msg_id_record_map,{1467,'ride_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1480,'item_identify_c2s'}),
	ets:insert(proto_msg_id_record_map,{1481,'item_identify_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1482,'ride_pet_synthesis_c2s'}),
	ets:insert(proto_msg_id_record_map,{1483,'ridepet_synthesis_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1484,'ridepet_synthesis_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1485,'pet_random_talent_c2s'}),
	ets:insert(proto_msg_id_record_map,{1486,'pet_change_talent_c2s'}),
	ets:insert(proto_msg_id_record_map,{1487,'pet_random_talent_s2c'}),
	ets:insert(proto_msg_id_record_map,{1488,'item_identify_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1489,'pet_evolution_c2s'}),
	ets:insert(proto_msg_id_record_map,{1490,'pet_qualification_c2s'}),
	ets:insert(proto_msg_id_record_map,{1491,'pet_qualification_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1500,'pet_upgrade_quality_c2s'}),
	ets:insert(proto_msg_id_record_map,{1501,'pet_upgrade_quality_up_c2s'}),
	ets:insert(proto_msg_id_record_map,{1492,'pet_evolution_growthvalue_c2s'}),
	ets:insert(proto_msg_id_record_map,{1494,'pet_growup_c2s'}),
	ets:insert(proto_msg_id_record_map,{1502,'pet_add_attr_c2s'}),
	ets:insert(proto_msg_id_record_map,{1503,'pet_wash_attr_c2s'}),
	ets:insert(proto_msg_id_record_map,{1504,'pet_upgrade_quality_s2c'}),
	ets:insert(proto_msg_id_record_map,{1505,'pet_upgrade_quality_up_s2c'}),
	ets:insert(proto_msg_id_record_map,{1510,'update_item_for_pet_s2c'}),
	ets:insert(proto_msg_id_record_map,{1511,'equip_item_for_pet_c2s'}),
	ets:insert(proto_msg_id_record_map,{1512,'unequip_item_for_pet_c2s'}),
	ets:insert(proto_msg_id_record_map,{1513,'pet_item_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1520,'refine_system_c2s'}),
	ets:insert(proto_msg_id_record_map,{1521,'refine_system_s2c'}),
	ets:insert(proto_msg_id_record_map,{1530,'welfare_activity_update_c2s'}),
	ets:insert(proto_msg_id_record_map,{1531,'welfare_activity_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1540,'designation_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1541,'designation_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1542,'inspect_designation_s2c'}),
	ets:insert(proto_msg_id_record_map,{1550,'treasure_transport_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{1551,'treasure_transport_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{1552,'start_guild_transport_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{1553,'rob_treasure_transport_s2c'}),
	ets:insert(proto_msg_id_record_map,{1554,'server_treasure_transport_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{1555,'server_treasure_transport_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1556,'role_treasure_transport_time_check_c2s'}),
	ets:insert(proto_msg_id_record_map,{1557,'guild_transport_left_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{1558,'start_guild_treasure_transport_c2s'}),
	ets:insert(proto_msg_id_record_map,{1559,'treasure_transport_call_guild_help_s2c'}),
	ets:insert(proto_msg_id_record_map,{1560,'mainline_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1561,'mainline_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1562,'mainline_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1563,'mainline_start_entry_c2s'}),
	ets:insert(proto_msg_id_record_map,{1564,'mainline_start_entry_s2c'}),
	ets:insert(proto_msg_id_record_map,{1565,'mainline_start_c2s'}),
	ets:insert(proto_msg_id_record_map,{1566,'mainline_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{1567,'mainline_end_c2s'}),
	ets:insert(proto_msg_id_record_map,{1568,'mainline_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1569,'mainline_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1570,'mainline_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1571,'mainline_lefttime_s2c'}),
	ets:insert(proto_msg_id_record_map,{1572,'mainline_timeout_c2s'}),
	ets:insert(proto_msg_id_record_map,{1573,'mainline_remain_monsters_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1574,'mainline_kill_monsters_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1575,'mainline_section_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1576,'mainline_protect_npc_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1577,'mainline_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1578,'mainline_reward_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{1600,'spa_start_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1601,'spa_request_spalist_c2s'}),
	ets:insert(proto_msg_id_record_map,{1602,'spa_request_spalist_s2c'}),
	ets:insert(proto_msg_id_record_map,{1603,'spa_join_c2s'}),
	ets:insert(proto_msg_id_record_map,{1604,'spa_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{1605,'spa_chopping_s2c'}),
	ets:insert(proto_msg_id_record_map,{1607,'spa_swimming_c2s'}),
	ets:insert(proto_msg_id_record_map,{1608,'spa_swimming_s2c'}),
	ets:insert(proto_msg_id_record_map,{1610,'spa_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1611,'spa_leave_c2s'}),
	ets:insert(proto_msg_id_record_map,{1612,'spa_leave_s2c'}),
	ets:insert(proto_msg_id_record_map,{1613,'spa_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{1614,'spa_chopping_c2s'}),
	ets:insert(proto_msg_id_record_map,{1615,'spa_update_count_s2c'}),
	ets:insert(proto_msg_id_record_map,{1620,'treasure_transport_call_guild_help_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1621,'treasure_transport_call_guild_help_c2s'}),
	ets:insert(proto_msg_id_record_map,{1630,'server_version_c2s'}),
	ets:insert(proto_msg_id_record_map,{1631,'server_version_s2c'}),
	ets:insert(proto_msg_id_record_map,{1640,'country_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1641,'change_country_notice_c2s'}),
	ets:insert(proto_msg_id_record_map,{1642,'change_country_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1643,'change_country_transport_c2s'}),
	ets:insert(proto_msg_id_record_map,{1644,'change_country_transport_s2c'}),
	ets:insert(proto_msg_id_record_map,{1645,'country_leader_promotion_c2s'}),
	ets:insert(proto_msg_id_record_map,{1646,'country_leader_demotion_c2s'}),
	ets:insert(proto_msg_id_record_map,{1647,'country_leader_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1648,'country_block_talk_c2s'}),
	ets:insert(proto_msg_id_record_map,{1649,'country_change_crime_c2s'}),
	ets:insert(proto_msg_id_record_map,{1650,'country_leader_online_s2c'}),
	ets:insert(proto_msg_id_record_map,{1651,'country_leader_get_itmes_c2s'}),
	ets:insert(proto_msg_id_record_map,{1652,'country_leader_ever_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1653,'guild_battle_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{1654,'entry_guild_battle_c2s'}),
	ets:insert(proto_msg_id_record_map,{1655,'entry_guild_battle_s2c'}),
	ets:insert(proto_msg_id_record_map,{1656,'leave_guild_battle_c2s'}),
	ets:insert(proto_msg_id_record_map,{1657,'leave_guild_battle_s2c'}),
	ets:insert(proto_msg_id_record_map,{1658,'guild_battle_score_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1659,'guild_battle_score_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1660,'guild_battle_status_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1661,'guild_battle_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1662,'country_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1663,'guild_battle_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1664,'guild_battle_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{1665,'country_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1666,'guild_battle_ready_s2c'}),
	ets:insert(proto_msg_id_record_map,{1667,'apply_guild_battle_c2s'}),
	ets:insert(proto_msg_id_record_map,{1668,'guild_battle_start_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{1669,'guild_battle_stop_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{1680,'init_open_service_activities_s2c'}),
	ets:insert(proto_msg_id_record_map,{1681,'open_sercice_activities_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1682,'open_service_activities_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1683,'init_open_service_activities_c2s'}),
	ets:insert(proto_msg_id_record_map,{1690,'activity_tab_isshow_s2c'}),
	ets:insert(proto_msg_id_record_map,{1691,'festival_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1692,'festival_recharge_s2c'}),
	ets:insert(proto_msg_id_record_map,{1693,'festival_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1694,'festival_recharge_exchange_c2s'}),
	ets:insert(proto_msg_id_record_map,{1695,'festival_recharge_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1696,'festival_recharge_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1700,'jszd_start_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1701,'jszd_join_c2s'}),
	ets:insert(proto_msg_id_record_map,{1702,'jszd_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{1703,'jszd_leave_c2s'}),
	ets:insert(proto_msg_id_record_map,{1704,'jszd_leave_s2c'}),
	ets:insert(proto_msg_id_record_map,{1705,'jszd_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1706,'jszd_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1707,'jszd_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1708,'jszd_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1709,'jszd_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{1710,'jszd_battlefield_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1720,'guild_contribute_log_c2s'}),
	ets:insert(proto_msg_id_record_map,{1721,'guild_contribute_log_s2c'}),
	ets:insert(proto_msg_id_record_map,{1722,'guild_impeach_c2s'}),
	ets:insert(proto_msg_id_record_map,{1723,'guild_impeach_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1724,'guild_impeach_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{1725,'guild_impeach_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1726,'guild_impeach_vote_c2s'}),
	ets:insert(proto_msg_id_record_map,{1727,'guild_impeach_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{1728,'guild_join_lefttime_s2c'}),
	ets:insert(proto_msg_id_record_map,{1729,'sync_bonfire_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{1730,'spiritspower_state_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1731,'spiritspower_reset_c2s'}),
	ets:insert(proto_msg_id_record_map,{1740,'christmas_tree_grow_up_c2s'}),
	ets:insert(proto_msg_id_record_map,{1741,'christmas_activity_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1742,'christmas_tree_hp_s2c'}),
	ets:insert(proto_msg_id_record_map,{1743,'play_effects_s2c'}),
	ets:insert(proto_msg_id_record_map,{1751,'tangle_kill_info_request_c2s'}),
	ets:insert(proto_msg_id_record_map,{1752,'tangle_kill_info_request_s2c'}),
	ets:insert(proto_msg_id_record_map,{1760,'get_guild_monster_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1761,'call_guild_monster_c2s'}),
	ets:insert(proto_msg_id_record_map,{1762,'callback_guild_monster_c2s'}),
	ets:insert(proto_msg_id_record_map,{1764,'get_guild_monster_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{1800,'entry_loop_instance_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{1801,'entry_loop_instance_vote_s2c'}),
	ets:insert(proto_msg_id_record_map,{1802,'entry_loop_instance_vote_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1803,'entry_loop_instance_vote_c2s'}),
	ets:insert(proto_msg_id_record_map,{1804,'entry_loop_instance_c2s'}),
	ets:insert(proto_msg_id_record_map,{1805,'entry_loop_instance_s2c'}),
	ets:insert(proto_msg_id_record_map,{1806,'leave_loop_instance_c2s'}),
	ets:insert(proto_msg_id_record_map,{1807,'leave_loop_instance_s2c'}),
	ets:insert(proto_msg_id_record_map,{1808,'loop_instance_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1809,'loop_instance_reward_s2c'}),
	ets:insert(proto_msg_id_record_map,{1810,'loop_instance_remain_monsters_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1811,'loop_instance_kill_monsters_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1812,'loop_instance_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1813,'loop_instance_kill_monsters_info_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1821,'honor_stores_buy_items_c2s'}),
	ets:insert(proto_msg_id_record_map,{1822,'buy_honor_item_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1823,'monster_section_update_s2c'}),
    %%zhangting邀请好友送礼
    ets:insert(proto_msg_id_record_map,{2301,'invite_friend_gift_get_c2s'}),
    ets:insert(proto_msg_id_record_map,{2302,'invite_friend_gift_get_ret_s2c'}),
    ets:insert(proto_msg_id_record_map,{2303,'invite_friend_add_c2s'}),
    ets:insert(proto_msg_id_record_map,{2304,'invite_friend_board_c2s'}),
    ets:insert(proto_msg_id_record_map,{2305,'invite_friend_board_s2c'}),
	

     
	 %%zhangting 收藏送礼
    ets:insert(proto_msg_id_record_map,{1890,'collect_page_c2s'}),
    ets:insert(proto_msg_id_record_map,{1891,'collect_page_s2c'}),
	
	%% 经验台刷品refresh_instance_quality_result_s2c
	ets:insert(proto_msg_id_record_map, {1952, 'init_instance_quality_c2s'}),
	ets:insert(proto_msg_id_record_map, {1950, 'refresh_instance_quality_c2s'}),
	ets:insert(proto_msg_id_record_map, {1953, 'refresh_instance_quality_result_s2c'}),
	ets:insert(proto_msg_id_record_map, {1951, 'refresh_instance_quality_s2c'}),
	%%副本元宝委托送礼
	ets:insert(proto_msg_id_record_map,{1900,'instance_entrust_c2s'}),
	ets:insert(proto_msg_id_record_map,{1875,'qz_get_balance_c2s'}),
	
	ets:insert(proto_msg_id_record_map,{3000,'activity_test01_display_s2c'}),
	ets:insert(proto_msg_id_record_map,{3001,'activity_test01_hidden_s2c'}),
	ets:insert(proto_msg_id_record_map,{3002,'activity_test01_recv_c2s'}),
	%%好友信息验证
	ets:insert(proto_msg_id_record_map,{2259,'add_friend_confirm_s2c'}),
	ets:insert(proto_msg_id_record_map,{2258,'add_friend_confirm_c2s'}),
	ets:insert(proto_msg_id_record_map,{2250,'add_friend_reject_s2c'}),
	ets:insert(proto_msg_id_record_map,{2249,'search_role_error_s2c'}),
	%%ets:insert(proto_msg_id_record_map,{2251,'msg_auto_find_friend_c2s'}),
	ets:insert(proto_msg_id_record_map,{2252,'friend_intimacy_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{2255,'friend_update_level_s2c'}),
	ets:insert(proto_msg_id_record_map,{2256,'friend_send_flower_c2s'}),
	ets:insert(proto_msg_id_record_map,{2257,'friend_send_flower_s2c'}),
	ets:insert(proto_msg_id_record_map,{2260,'search_role_c2s'}),
	ets:insert(proto_msg_id_record_map,{2261,'search_role_s2c'}),
	ets:insert(proto_msg_id_record_map,{2262,'friend_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{2263,'friend_init_recent_s2c'}),
	ets:insert(proto_msg_id_record_map,{2264,'friend_init_enemy_s2c'}),
	
	%%一键征友
	ets:insert(proto_msg_id_record_map,{2251,'auto_find_friend_c2s'}),
	
	%%丹药【xiaowu】
	ets:insert(proto_msg_id_record_map,{2411,'get_furnace_queue_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{2418,'create_pill_c2s'}),
	ets:insert(proto_msg_id_record_map,{2412,'get_furnace_queue_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{2419,'accelerate_furnace_queue_c2s'}),	
	ets:insert(proto_msg_id_record_map,{2410,'quit_furnace_queue_c2s'}),
	ets:insert(proto_msg_id_record_map,{2416,'unlock_furnace_queue_c2s'}),
	ets:insert(proto_msg_id_record_map,{2414,'up_furnace_c2s'}),
	%%占星
	ets:insert(proto_msg_id_record_map,{2192,'astrology_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{2190,'astrology_action_c2s'}),
	ets:insert(proto_msg_id_record_map,{2196,'astrology_pickup_all_c2s'}),
	ets:insert(proto_msg_id_record_map,{2200,'astrology_sale_all_c2s'}),
	ets:insert(proto_msg_id_record_map,{2100,'astrology_open_panel_c2s'}),
	ets:insert(proto_msg_id_record_map,{2216,'astrology_add_money_c2s'}),
	ets:insert(proto_msg_id_record_map,{2198,'astrology_sale_c2s'}),
	ets:insert(proto_msg_id_record_map,{2194,'astrology_pickup_c2s'}),
	ets:insert(proto_msg_id_record_map,{2219,'astrology_item_pos_c2s'}),
	ets:insert(proto_msg_id_record_map,{2203,'astrology_mix_c2s'}),
	ets:insert(proto_msg_id_record_map,{2204,'astrology_mix_all_c2s'}),
	ets:insert(proto_msg_id_record_map,{2205,'astrology_lock_c2s'}),
	ets:insert(proto_msg_id_record_map,{2206,'astrology_unlock_c2s'}),
	ets:insert(proto_msg_id_record_map,{2214,'astrology_expand_package_c2s'}),
	ets:insert(proto_msg_id_record_map,{2215,'astrology_swap_c2s'}),
	ets:insert(proto_msg_id_record_map,{2220,'astrology_active_c2s'}),

	%%战场@@wb20130419
	ets:insert(proto_msg_id_record_map,{1850,'camp_battle_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{1851,'camp_battle_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{1852,'camp_battle_entry_c2s'}),
	ets:insert(proto_msg_id_record_map,{1853,'camp_battle_entry_s2c'}),
	ets:insert(proto_msg_id_record_map,{1854,'camp_battle_leave_c2s'}),
	ets:insert(proto_msg_id_record_map,{1855,'camp_battle_leave_s2c'}),
	ets:insert(proto_msg_id_record_map,{1856,'camp_battle_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1857,'camp_battle_otherrole_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1858,'camp_battle_otherrole_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1859,'camp_battle_otherrole_leave_s2c'}),
	ets:insert(proto_msg_id_record_map,{1860,'camp_battle_info_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1861,'camp_battle_record_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1862,'camp_battle_record_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1863,'camp_battle_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1864,'camp_battle_player_num_c2s'}),
	ets:insert(proto_msg_id_record_map,{1865,'camp_battle_player_num_s2c'}),
	ets:insert(proto_msg_id_record_map,{1866,'camp_battle_last_record_c2s'}),
	ets:insert(proto_msg_id_record_map,{1867,'camp_battle_last_record_s2c'}),
	ets:insert(proto_msg_id_record_map,{1868,'camp_battle_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1910,'travel_battle_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{1911,'travel_battle_entry_c2s'}),
	ets:insert(proto_msg_id_record_map,{1912,'travel_battle_entry_s2c'}),
	ets:insert(proto_msg_id_record_map,{1913,'travel_battle_leave_c2s'}),
	ets:insert(proto_msg_id_record_map,{1914,'travel_battle_leave_s2c'}),
	ets:insert(proto_msg_id_record_map,{1915,'travel_battle_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{1916,'travel_battle_reward_s2c'}),
	ets:insert(proto_msg_id_record_map,{1917,'travel_battle_all_result_c2s'}),
	ets:insert(proto_msg_id_record_map,{1918,'travel_battle_all_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1919,'travel_battle_player_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1920,'travel_battle_add_player_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1921,'travel_battle_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1922,'travel_battle_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1923,'travel_battle_update_score_s2c'}),
	ets:insert(proto_msg_id_record_map,{1924,'travel_battle_self_result_c2s'}),
	ets:insert(proto_msg_id_record_map,{1925,'travel_battle_self_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1926,'travel_battle_killinfo_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1927,'travel_battle_bekillinfo_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1928,'travel_battle_next_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{1929,'travel_battle_forecast_s2c'}),
	ets:insert(proto_msg_id_record_map,{1711,'notify_all_battle_end_s2c'}),
	ok.

%% %% encode_player_role_list_s2c(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% %% encode_role_line_query_c2s(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% %% encode_role_line_query_ok_s2c(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% encode_role_change_line_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% %% encode_player_select_role_c2s(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% %% encode_map_complete_c2s(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% %% encode_role_map_change_s2c(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% encode_npc_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_other_role_map_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_change_map_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_change_map_ok_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_change_map_fail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% %% encode_role_move_c2s(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% encode_heartbeat_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_other_role_move_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_move_fail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_attack_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_attack_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_cancel_attack_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_be_attacked_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_be_killed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_other_role_into_view_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_npc_into_view_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_creature_outof_view_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_debug_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_use_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_auto_equip_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_change_item_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_use_item_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_buff_immune_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_attribute_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_npc_attribute_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_rename_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_rename_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rename_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_map_change_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_npc_map_change_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% %% encode_map_change_failed_s2c(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% encode_skill_panel_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_learned_skill_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_display_hotbar_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_hotbar_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_hotbar_fail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_skill_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_list_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_list_remove_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_list_add_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_statu_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_questgiver_hello_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_questgiver_quest_details_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_questgiver_accept_quest_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_quit_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_questgiver_complete_quest_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_complete_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_complete_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_questgiver_states_update_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_questgiver_states_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_details_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_details_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_get_adapt_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_get_adapt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_accept_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_quest_direct_complete_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_add_buff_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_del_buff_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_buff_affect_attr_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_move_stop_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loot_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loot_query_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loot_response_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loot_pick_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loot_remove_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loot_release_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_player_level_up_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_cancel_buff_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_money_from_monster_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_add_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_add_item_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_destroy_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_delete_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_split_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_swap_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_init_onhands_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_npc_storage_items_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_npc_storage_items_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_arrange_items_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_arrange_items_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chat_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chat_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chat_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loudspeaker_queue_num_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loudspeaker_queue_num_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loudspeaker_opt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chat_private_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chat_private_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_apply_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_agree_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_create_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_invite_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_accept_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_decline_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_kickout_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_setleader_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_disband_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_depart_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_invite_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_decline_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_destroy_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_list_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_cmd_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_member_stats_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_group_apply_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_recruite_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_recruite_cancel_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_recruite_query_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_recruite_query_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_recruite_cancel_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_recruite_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_recruite_cancel_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_recruite_cancel_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_aoi_role_group_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_aoi_role_group_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_npc_fucnction_common_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_npc_function_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_npc_function_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_enum_shoping_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_enum_shoping_item_fail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_enum_shoping_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_buy_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_buy_item_fail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_sell_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_sell_item_fail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_repair_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_fatigue_prompt_with_type_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_fatigue_login_disabled_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_fatigue_prompt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_fatigue_alert_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_finish_register_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% %% encode_object_update_s2c(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% encode_guild_monster_opt_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_upgrade_guild_monster_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_change_smith_need_contribution_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_leave_guild_instance_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_join_guild_instance_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_create_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_disband_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_invite_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_decline_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_accept_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_apply_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_depart_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_kickout_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_set_leader_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_promotion_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_demotion_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_log_normal_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_log_event_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_notice_modify_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_facilities_accede_rules_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_facilities_upgrade_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_facilities_speed_up_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_rewards_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_recruite_info_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_contribute_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_opt_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_base_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_facilities_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_delete_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_add_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_destroy_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_decline_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_invite_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_recruite_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_log_normal_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_log_event_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_get_application_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_get_application_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_application_op_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_change_nickname_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_change_chatandvoicegroup_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_update_log_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% %% encode_create_role_request_c2s(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% %% encode_create_role_sucess_s2c(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% %% encode_create_role_failed_s2c(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% encode_inspect_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_inspect_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_inspect_faild_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% %% encode_user_auth_c2s(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% encode_user_auth_fail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_enum_skill_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_enum_skill_item_fail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_enum_skill_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_skill_learn_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_skill_learn_item_fail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_feedback_info_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_feedback_info_ret_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_respawn_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_other_login_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_block_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% %% encode_is_jackaroo_s2c(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% encode_is_visitor_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_is_finish_visitor_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_visitor_rename_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_visitor_rename_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_visitor_rename_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mall_item_list_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mall_item_list_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_init_mall_item_list_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_init_mall_item_list_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_buy_mall_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_init_hot_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_init_latest_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mall_item_list_special_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mall_item_list_special_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mall_item_list_sales_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mall_item_list_sales_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_change_role_mall_integral_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_query_player_option_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_query_player_option_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_replace_player_option_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_info_back_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_revert_black_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_revert_black_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_init_signature_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_add_signature_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_get_friend_signature_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_get_friend_signature_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_set_black_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_set_black_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_delete_black_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_delete_black_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_black_list_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_myfriends_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_myfriends_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_add_friend_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_add_friend_success_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_add_friend_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_becare_friend_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_delete_friend_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_delete_friend_success_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_delete_friend_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_online_friend_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_offline_friend_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_detail_friend_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_detail_friend_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_detail_friend_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_position_friend_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_position_friend_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_position_friend_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_add_black_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_add_black_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_lottery_lefttime_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_lottery_leftcount_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_lottery_clickslot_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_lottery_clickslot_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_lottery_otherslot_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_lottery_notic_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_lottery_clickslot_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_lottery_querystatus_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_start_block_training_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_start_block_training_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_end_block_training_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_end_block_training_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mail_status_query_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mail_status_query_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mail_arrived_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mail_query_detail_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mail_query_detail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mail_get_addition_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mail_get_addition_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mail_send_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mail_delete_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mail_delete_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mail_operator_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mail_sucess_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_trade_role_apply_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_trade_role_accept_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_trade_role_decline_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_set_trade_money_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_set_trade_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_cancel_trade_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_trade_role_lock_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_trade_role_dealit_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_trade_role_errno_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_trade_begin_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_trade_status_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_trade_role_lock_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_trade_role_dealit_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_trade_role_decline_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_trade_role_apply_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_cancel_trade_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_trade_success_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_riseup_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_riseup_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_riseup_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_sock_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_sock_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_sock_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_inlay_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_inlay_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_inlay_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_stone_remove_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_stone_remove_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_stone_remove_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% encode_equipment_stonemix_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% %%批量合成 zhangting
%% encode_equipment_stonemix_bat_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% 
%% encode_equipment_stonemix_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% 
%% encode_equipment_stonemix_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_upgrade_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_upgrade_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_enchant_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_enchant_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_recast_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_recast_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_recast_confirm_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_convert_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_convert_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_move_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_move_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_remove_seal_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_remove_seal_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equipment_fenjie_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equip_fenjie_optresult_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_achieve_open_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_achieve_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_achieve_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_achieve_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_achieve_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% %% encode_goals_init_s2c(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% encode_goals_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_goals_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_goals_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_goals_init_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_tower_enter_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_tower_enter_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_tower_masters_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_tower_masters_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_tower_enter_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_tower_challenge_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_tower_challenge_success_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_tower_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_tower_challenge_again_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_tower_enter_higher_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_vip_ui_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_vip_ui_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_vip_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_vip_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_vip_level_up_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_vip_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_vip_npc_enum_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_login_bonus_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_vip_role_use_flyshoes_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_join_vip_map_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_query_system_switch_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_system_status_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_duel_invite_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_duel_decline_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_duel_accept_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_duel_invite_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_duel_decline_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_duel_start_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_duel_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_set_pkmodel_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_set_pkmodel_faild_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_clear_crime_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_clear_crime_time_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_query_time_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_query_time_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stop_move_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_identify_verify_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_identify_verify_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mp_package_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_fly_shoes_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_hp_package_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_npc_swap_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_use_target_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_join_battle_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_tangle_battlefield_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_battle_start_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_battle_join_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_battle_leave_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_battle_self_join_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_tangle_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_tangle_remove_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_battle_end_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_battle_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_battle_other_join_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_battle_waiting_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_instance_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_get_instance_log_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_get_instance_log_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_tangle_records_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_tangle_records_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_tangle_topman_pos_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_tangle_more_records_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_tangle_more_records_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_instance_exit_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_instance_leader_join_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_instance_leader_join_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_start_everquest_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_everquest_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_refresh_everquest_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_refresh_everquest_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_npc_start_everquest_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_npc_everquests_enum_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_npc_everquests_enum_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_everquest_list_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_instance_end_seconds_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_init_pets_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_create_pet_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_summon_pet_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_move_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_stop_move_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_attack_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_rename_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_present_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_present_apply_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_present_apply_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_up_reset_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_up_reset_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_up_growth_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_up_stamina_growth_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_up_growth_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_up_stamina_growth_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_opt_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_learn_skill_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_up_exp_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_forget_skill_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_delete_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_swap_slot_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_inspect_pet_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_inspect_pet_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_riseup_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_riseup_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_skill_slot_lock_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_pet_skill_slot_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_pet_skill_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_learned_pet_skill_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_init_pet_skill_slots_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_learn_skill_cover_best_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_buy_pet_slot_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_pet_slot_num_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_feed_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_training_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_start_training_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_stop_training_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_speedup_training_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_training_init_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_explore_storage_init_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_explore_storage_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_explore_storage_init_end_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_explore_storage_getitem_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_explore_storage_getallitems_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_explore_storage_updateitem_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_explore_storage_additem_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_explore_storage_delitem_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_explore_storage_opt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_explore_info_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_explore_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_explore_start_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_explore_speedup_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_explore_stop_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_explore_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_explore_gain_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_chest_flush_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_chest_flush_ok_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_chest_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_chest_raffle_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_chest_raffle_ok_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_chest_obtain_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_chest_obtain_ok_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_chest_query_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_chest_query_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_chest_broad_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_chest_disable_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_beads_pray_request_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_beads_pray_response_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_beads_pray_fail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_enum_exchange_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_enum_exchange_item_fail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_enum_exchange_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_exchange_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_exchange_item_fail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_battle_reward_by_records_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_timelimit_gift_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_get_timelimit_gift_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_timelimit_gift_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_timelimit_gift_over_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stall_sell_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stall_recede_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stalls_search_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stall_detail_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stall_buy_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stall_rename_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stalls_search_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stall_detail_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stalls_search_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stall_log_add_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stall_opt_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stall_role_detail_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stalls_search_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_battlefield_info_s2c(Term)->%%点击晶石争夺战回复
%% 	T2 = erlang:setelement(1,Term,[]),
%%	erlang:term_to_binary(T2).
%% encode_battlefield_info_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_battlefield_info_error_s2c(Term)->%%点击天山斗法回复
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_battlefield_totle_info_s2c(Term)->%%点击国王争夺战回复
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_battlefield_info_s2c(Term)->%%点击群雄逐鹿回复
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_all_battle_over_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_notify_to_join_yhzq_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_join_yhzq_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_leave_yhzq_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_award_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_award_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_camp_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_zone_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_battle_self_join_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_battle_other_join_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_battle_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_battle_remove_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_battle_player_pos_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_yhzq_battle_end_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% %% encode_init_random_rolename_s2c(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% encode_reset_random_rolename_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_answer_sign_notice_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_answer_sign_request_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_answer_sign_success_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_answer_start_notice_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_answer_question_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_answer_question_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_answer_question_ranklist_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_answer_end_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_answer_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_offline_exp_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_offline_exp_quests_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_offline_exp_exchange_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_offline_exp_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_offline_exp_exchange_gold_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_congratulations_levelup_remind_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_congratulations_levelup_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_congratulations_levelup_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_congratulations_receive_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_congratulations_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_congratulations_received_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_buffer_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% %% encode_gift_card_state_s2c(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% encode_gift_card_apply_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_gift_card_apply_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_role_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_update_power_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_update_skill_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_update_chess_power_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_skill_levelup_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_cast_skill_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_cast_chess_skill_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_opt_result_s2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_log_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_log_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_get_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_quit_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_game_over_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_chess_spirit_prepare_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_get_shop_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_get_shop_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_shop_buy_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_get_treasure_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_get_treasure_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_treasure_buy_item_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_treasure_set_price_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_treasure_update_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_publish_guild_quest_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_guild_quest_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_guild_apply_state_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_guild_update_apply_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_update_apply_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_get_guild_notice_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_send_guild_notice_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_shop_update_item_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_change_guild_battle_limit_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_change_guild_right_limit_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_have_guildbattle_right_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_bonfire_start_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% %% encode_add_levelup_opt_levels_s2c(Term)->
%% %% 	T2 = erlang:setelement(1,Term,[]),
%% %% 	erlang:term_to_binary(T2).
%% encode_levelup_opt_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_bonfire_end_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_forecast_begin_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_forecast_end_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_system_broadcast_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_moneygame_left_time_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_moneygame_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_moneygame_prepare_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_moneygame_cur_sec_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_mastercall_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_mastercall_accept_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_mastercall_success_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_pos_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_member_pos_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_sitdown_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_stop_sitdown_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_companion_sitdown_apply_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_companion_sitdown_apply_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_companion_sitdown_start_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_companion_sitdown_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_companion_reject_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_companion_reject_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_dragon_fight_faction_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_dragon_fight_left_time_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_dragon_fight_state_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_dragon_fight_num_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_dragon_fight_num_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_dragon_fight_faction_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_dragon_fight_start_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_dragon_fight_end_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_dragon_fight_join_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_star_spawns_section_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_venation_advanced_start_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_venation_advanced_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_venation_advanced_opt_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_venation_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_venation_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_venation_shareexp_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_venation_active_point_start_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_venation_active_point_opt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_venation_active_point_end_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_venation_opt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_venation_time_countdown_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_other_venation_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_server_travel_tag_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_continuous_logging_gift_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_continuous_logging_board_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_continuous_days_clear_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_continuous_opt_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_continuous_logging_board_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_storage_init_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_storage_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_storage_init_end_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_storage_getitem_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_storage_getallitems_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_storage_updateitem_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_storage_additem_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_storage_delitem_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_storage_opt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_value_init_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_value_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_value_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_value_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_value_opt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_state_init_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_state_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_state_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_boss_born_init_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_boss_born_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_boss_born_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_first_charge_gift_state_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_first_charge_gift_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_first_charge_gift_reward_opt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_get_rank_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_get_rank_role_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_loop_tower_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_killer_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_moneys_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_melee_power_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_range_power_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_magic_power_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_loop_tower_num_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_level_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_answer_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_get_rank_role_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_disdain_role_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_praise_role_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_judge_opt_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_chess_spirits_single_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_chess_spirits_team_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_facebook_bind_check_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_facebook_bind_check_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_clear_nickname_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_everyday_show_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_judge_to_other_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_talent_score_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_mail_line_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_get_main_line_rank_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rank_fighting_force_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_welfare_panel_init_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_welfare_panel_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_welfare_gifepacks_state_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_welfare_gold_exchange_init_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_welfare_gold_exchange_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_welfare_gold_exchange_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_ride_opt_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_ride_opt_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_item_identify_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_item_identify_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_ride_pet_synthesis_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_ridepet_synthesis_opt_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_ridepet_synthesis_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_random_talent_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_change_talent_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_random_talent_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_item_identify_opt_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_evolution_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_upgrade_quality_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_upgrade_quality_up_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_add_attr_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_wash_attr_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_upgrade_quality_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_upgrade_quality_up_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_update_item_for_pet_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_equip_item_for_pet_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_unequip_item_for_pet_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_pet_item_opt_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_refine_system_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_refine_system_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_welfare_activity_update_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_welfare_activity_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_designation_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_designation_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_inspect_designation_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_transport_time_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_transport_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_start_guild_transport_failed_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_rob_treasure_transport_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_server_treasure_transport_start_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_server_treasure_transport_end_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_role_treasure_transport_time_check_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_transport_left_time_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_start_guild_treasure_transport_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_transport_call_guild_help_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_init_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_start_entry_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_start_entry_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_start_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_start_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_end_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_end_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_lefttime_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_timeout_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_remain_monsters_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_kill_monsters_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_section_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_protect_npc_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_opt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_mainline_reward_success_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_start_notice_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_request_spalist_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_request_spalist_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_join_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_join_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_chopping_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_swimming_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_swimming_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_leave_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_leave_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_stop_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_chopping_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spa_update_count_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_transport_call_guild_help_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_treasure_transport_call_guild_help_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_server_version_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_server_version_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_country_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_change_country_notice_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_change_country_notice_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_change_country_transport_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_change_country_transport_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_country_leader_promotion_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_country_leader_demotion_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_country_leader_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_country_block_talk_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_country_change_crime_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_country_leader_online_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_country_leader_get_itmes_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_country_leader_ever_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_battle_start_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_entry_guild_battle_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_entry_guild_battle_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_leave_guild_battle_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_leave_guild_battle_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_battle_score_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_battle_score_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_battle_status_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_battle_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_country_opt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_battle_opt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_battle_stop_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_country_init_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_battle_ready_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_apply_guild_battle_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_battle_start_apply_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_battle_stop_apply_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_init_open_service_activities_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_open_sercice_activities_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_open_service_activities_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_init_open_service_activities_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_tab_isshow_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_festival_init_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_festival_recharge_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_festival_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_festival_recharge_exchange_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_festival_recharge_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_festival_recharge_notice_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_jszd_start_notice_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_jszd_join_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_jszd_join_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_jszd_leave_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_jszd_leave_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_jszd_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_jszd_end_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_jszd_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_jszd_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_jszd_stop_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_jszd_battlefield_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_contribute_log_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_contribute_log_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_impeach_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_impeach_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_impeach_info_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_impeach_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_impeach_vote_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_impeach_stop_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_guild_join_lefttime_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_sync_bonfire_time_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spiritspower_state_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_spiritspower_reset_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_christmas_tree_grow_up_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_christmas_activity_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_christmas_tree_hp_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_play_effects_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_tangle_kill_info_request_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_tangle_kill_info_request_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%%encode_get_guild_monster_info_s2c(Term)->
%%	T2 = erlang:setelement(1,Term,[]),
%%	erlang:term_to_binary(T2).
%% encode_call_guild_monster_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_callback_guild_monster_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_get_guild_monster_info_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_entry_loop_instance_apply_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_entry_loop_instance_vote_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_entry_loop_instance_vote_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_entry_loop_instance_vote_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_entry_loop_instance_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_entry_loop_instance_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_leave_loop_instance_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_leave_loop_instance_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_instance_reward_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_instance_reward_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_instance_remain_monsters_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_instance_kill_monsters_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_instance_opt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_loop_instance_kill_monsters_info_init_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_honor_stores_buy_items_c2s(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_buy_honor_item_error_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_monster_section_update_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% %%邀请好友送礼协议 by zhangting
%% encode_invite_friend_board_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% encode_invite_friend_gift_get_ret_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% encode_favorite_gift_info_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% encode_tgw_gateway_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% 
%% encode_refresh_instance_quality_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% encode_refresh_instance_quality_opt_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% encode_refresh_instance_quality_result_s2c(Term)->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% encode_refresh_everquest_result_s2c(Term) ->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% encode_qz_get_balance_error_s2c(Term) ->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% 
%% encode_activity_test01_display_s2c(Term) ->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).
%% encode_activity_test01_hidden_s2c(Term) ->
%% 	T2 = erlang:setelement(1,Term,[]),
%% 	erlang:term_to_binary(T2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
encode_string(Str)->
	case Str of
		[]->
			<<0:16, <<>>/binary>>;
		_->
			case is_list(Str) of
				true->
					Bin = list_to_binary(Str);
				false->
					case is_binary(Str) of
						true->
							Bin = Str;
						false->
							Bin=term_to_binary(Str)
					end
			end,
				
			HL = byte_size(Bin),
		    <<HL:16, Bin/binary>>
	end.

encode_int64_list([])->
	<<0:16, <<>>/binary>>;
encode_int64_list(List)->
    Rlen = length(List),
    RB = list_to_binary([<<D:64>> || D <- List]),
    <<Rlen:16, RB/binary>>.

encode_int32_list([])->
	<<0:16, <<>>/binary>>;
encode_int32_list(List)->
    Rlen = length(List),
    RB = list_to_binary([<<D:32>> || D <- List]),
    <<Rlen:16, RB/binary>>.

encode_float_list([])->
	<<0:16, <<>>/binary>>;
encode_float_list(List)->
    Rlen = length(List),
    RB = list_to_binary([<<D:32/float>> || D <- List]),
    <<Rlen:16, RB/binary>>.

encode_int16_list([])->
	<<0:16, <<>>/binary>>;
encode_int16_list(List)->
    Rlen = length(List),
    RB = list_to_binary([<<D:16>> || D <- List]),
    <<Rlen:16, RB/binary>>.

encode_int8_list([])->
	<<0:16, <<>>/binary>>;
encode_int8_list(List)->
    Rlen = length(List),
    RB = list_to_binary([<<D:8>> || D <- List]),
    <<Rlen:16, RB/binary>>.

encode_string_list([])->
	<<0:16, <<>>/binary>>;
encode_string_list(List)->
    Rlen = length(List),
    RB = list_to_binary([encode_string(D) || D <- List]),
    <<Rlen:16, RB/binary>>.

read_int64(Bin) ->
    case Bin of
        <<Value:64, Bin1/binary>> ->
            {Value,Bin1};
        _R1 ->
            {[],<<>>}
    end.
read_int32(Bin) ->
    case Bin of
        <<Value:32, Bin1/binary>> ->
            {Value,Bin1};
        _R1 ->
            {[],<<>>}
    end.
read_int16(Bin) ->
    case Bin of
        <<Value:16, Bin1/binary>> ->
            {Value,Bin1};
        _R1 ->
            {[],<<>>}
    end.
read_int8(Bin) ->
    case Bin of
        <<Value:8, Bin1/binary>> ->
            {Value,Bin1};
        _R1 ->
            {[],<<>>}
    end.
read_float(Bin) ->
    case Bin of
        <<Value:32/float, Bin1/binary>> ->
            {Value,Bin1};
        _R1 ->
            {[],<<>>}
    end.
%%读取字符串
read_string(Bin) ->
    case Bin of
        <<Len:16, Bin1/binary>> ->
            case Bin1 of
                <<Str:Len/binary-unit:8, Rest/binary>> ->
                    {binary_to_list(Str), Rest};
                _R1 ->
                    {[],<<>>}
            end;
        _R1 ->
            {[],<<>>}
    end.


encode_list([], Fun) ->
    <<0:16, <<>>/binary>>;
encode_list(DefList, Fun) ->
    Rlen = length(DefList),
    RB = list_to_binary([Fun(D) || D <- DefList]),
    <<Rlen:16, RB/binary>>.

%% AccList列表累加器，使用时初始为[]
get_list(AccList, Bin, N, Fun) when N > 0 ->
	{Term, Rest} = Fun(Bin),
	NewList = AccList ++ [Term],
	get_list(NewList, Rest, N - 1, Fun);
get_list(AccList, Bin, _, _) ->
    {AccList, Bin}.

decode_list(Binary, Fun)->
	case Binary of
		<<Len:16, Binary1/binary>>->
			get_list([], Binary1, Len, Fun);
		_R->
			{[], Binary}
	end.

read_int64_list(Binary)->
	decode_list(Binary, fun read_int64/1).
read_int32_list(Binary)->
	decode_list(Binary, fun read_int32/1).
read_int16_list(Binary)->
	decode_list(Binary, fun read_int16/1).
read_int8_list(Binary)->
	decode_list(Binary, fun read_int8/1).
read_float_list(Binary)->
	decode_list(Binary, fun read_float/1).
read_string_list(Binary)->
	decode_list(Binary, fun read_string/1).


encode_k(Term)->
	Key=Term#k.key,
	Value=Term#k.value,
	if 
		Key>=0, Key=<999 ->
		   <<Key:32, Value:32>>;
	   Key>=1000, Key=<1999 ->
		   Value1 = encode_string(Value),
		   <<Key:32, Value1/binary>>;
	   Key>=2000, Key=<2999 ->
		   if Key==2015->
				  V = trunc(Value),
				  <<Key:32, V:64>>;
			  true->
		   		<<Key:32, Value:64>>
		   end;
	   Key>=3000, Key=<3999 ->
		   if Key==3005; Key==3111; Key==3006; Key==3007; Key==3108; Key==3109 ->
				  Value1 = encode_int32_list(Value),
				  <<Key:32, Value1/binary>>;
			  true->
				  Value1= encode_int32_list(Value),
		   		  <<Key:32, Value1/binary>>
			  end;
       Key>=4000, Key=<4999 ->
		   Value1 = encode_string_list(Value),
           <<Key:32, Value1/binary>>;
       true->
		   <<Key:32, Value:32>>
    end.

encode_bool(Term)->
	case Term of
		true-><<1:8>>;
		false-><<0:8>>
	end.

decode_bool(Binary)->
	case Binary of
		<<0:16,Binary1/binary>>->false;
		<<1:16,Binary1/binary>>->true
	end.

%%
encode_hc(Term)->
	Clsid=Term#hc.clsid,
	Entryid=Term#hc.entryid,
	Pos=Term#hc.pos,
%% 	<<Clsid:32, Entryid:64, Pos:32>>.
	case is_list(Pos) of
		true ->
			PosBin = encode_int32_list(Pos),
			<<Clsid:32, Entryid:64, PosBin/binary>>;
		false->
			<<Clsid:32, Entryid:64, Pos:32>>
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
encode_kmi(Term)->
	Npcproto=Term#kmi.npcproto,
	Neednum=Term#kmi.neednum,
	Data = <<Npcproto:32, Neednum:32>>,
	Data.

%%
encode_guildlog(Term)->
	Type=Term#guildlog.type,
	Id=Term#guildlog.id,
	Keystr=encode_string_list(Term#guildlog.keystr),
	Year=Term#guildlog.year,
	Month=Term#guildlog.month,
	Day=Term#guildlog.day,
	Hour=Term#guildlog.hour,
	Min=Term#guildlog.min,
	Sec=Term#guildlog.sec,
	Data = <<Type:32, Id:32, Keystr/binary, Year:32, Month:32, Day:32, Hour:32, Min:32, Sec:32>>,
	Data.

%%
encode_kl(Term)->
	Key=Term#kl.key,
	Value=encode_int32_list(Term#kl.value),
	Data = <<Key:32, Value/binary>>,
	Data.

%%
encode_mf(Term)->
	Creatureid=Term#mf.creatureid,
	Buffid=Term#mf.buffid,
	Bufflevel=Term#mf.bufflevel,
	Data = <<Creatureid:64, Buffid:32, Bufflevel:32>>,
	Data.

%%
encode_bs(Term)->
	Bossid=Term#bs.bossid,
	State=Term#bs.state,
	Data = <<Bossid:32, State:32>>,
	Data.

%%
encode_ach(Term)->
	Isreward=Term#ach.isreward,
	Chapter=Term#ach.chapter,
	Part=Term#ach.part,
	Cur=Term#ach.cur,
	Target=Term#ach.target,
	Data = <<Isreward:32, Chapter:32, Part:32, Cur:32, Target:32>>,
	Data.

%%
encode_votestate(Term)->
	Roleid=Term#votestate.roleid,
	State=Term#votestate.state,
	Data = <<Roleid:64, State:32>>,
	Data.

%%
encode_ic(Term)->
	Itemid_low=Term#ic.itemid_low,
	Itemid_high=Term#ic.itemid_high,
	Attrs=encode_list(Term#ic.attrs, fun encode_k/1),
	Ext_enchant=encode_list(Term#ic.ext_enchant, fun encode_k/1),
	Data = <<Itemid_low:32, Itemid_high:32, Attrs/binary, Ext_enchant/binary>>,
	Data.

%%
encode_av(Term)->
	Id=Term#av.id,
	Completed=Term#av.completed,
	Data = <<Id:32, Completed:32>>,
	Data.

%%
encode_time_struct(Term)->
	Year=Term#time_struct.year,
	Month=Term#time_struct.month,
	Day=Term#time_struct.day,
	Hour=Term#time_struct.hour,
	Minute=Term#time_struct.minute,
	Second=Term#time_struct.second,
	Data = <<Year:32, Month:32, Day:32, Hour:32, Minute:32, Second:32>>,
	Data.

%%
encode_rkv(Term)->
	Kv=encode_list(Term#rkv.kv, fun encode_k/1),
	Kv_plus=encode_list(Term#rkv.kv_plus, fun encode_k/1),
	Color=Term#rkv.color,
	Data = <<Kv/binary, Kv_plus/binary, Color:32>>,
	Data.

%%
encode_ip(Term)->
	Moneytype=Term#ip.moneytype,
	Price=Term#ip.price,
	Data = <<Moneytype:32, Price:32>>,
	Data.

%%
encode_gps(Term)->
	Typenumber=Term#gps.typenumber,
	Time_state=Term#gps.time_state,
	Complete_state=Term#gps.complete_state,
	Data = <<Typenumber:32, Time_state:32, Complete_state:32>>,
	Data.

%%
encode_sp(Term)->
	Itemclsid=Term#sp.itemclsid,
	Price=encode_list(Term#sp.price, fun encode_ip/1),
	Data = <<Itemclsid:32, Price/binary>>,
	Data.

%%
encode_charge(Term)->
	Id=Term#charge.id,
	Awarddate=encode_time_struct(Term#charge.awarddate),
	Charge_num=Term#charge.charge_num,
	State=Term#charge.state,
	Data = <<Id:32, Awarddate/binary, Charge_num:32, State:32>>,
	Data.

%%
encode_vp(Term)->
	Id=Term#vp.id,
	Points=encode_int32_list(Term#vp.points),
	Data = <<Id:32, Points/binary>>,
	Data.

%%
%encode_vb(Term)->
%	Id=Term#vb.id,
%	Bone=encode_string(Term#vb.bone),
%	Data = <<Id:32, Bone/binary>>,
%	Data.

encode_vb(Term)->
	Id=Term#vb.id,
	Bone=Term#vb.bone,
	Data = <<Id:32, Bone:32>>,
	Data.

%%
encode_giftinfo(Term)->
	Needcharge=Term#giftinfo.needcharge,
	Items=encode_list(Term#giftinfo.items, fun encode_lti/1),
	Data = <<Needcharge:32, Items/binary>>,
	Data.

%%
encode_aqrl(Term)->
	Rolename=encode_string(Term#aqrl.rolename),
	Score=Term#aqrl.score,
	Data = <<Rolename/binary, Score:32>>,
	Data.

%%
%encode_recharge(Term)->
%	Id=Term#recharge.id,
%	State=Term#recharge.state,
%	Data = <<Id:32, State:32>>,
%	Data.

encode_recharge(Term)->
	Id=Term#tab_state.id,
	State=Term#tab_state.state,
	Data = <<Id:32, State:32>>,
	Data.

%%
encode_li(Term)->
	Lineid=Term#li.lineid,
	Rolecount=Term#li.rolecount,
	Data = <<Lineid:32, Rolecount:32>>,
	Data.

%%
encode_stage(Term)->
	Chapter=Term#stage.chapter,
	Stageindex=Term#stage.stageindex,
	State=Term#stage.state,
	Bestscore=Term#stage.bestscore,
	Rewardflag=Term#stage.rewardflag,
	Entrytime=Term#stage.entrytime,
	Topone=encode_stagetop(Term#stage.topone),
	Data = <<Chapter:32, Stageindex:32, State:32, Bestscore:32, Rewardflag:32, Entrytime:32, Topone/binary>>,
	Data.

%%
encode_gsi(Term)->
	Id=Term#gsi.id,
	Showindex=Term#gsi.showindex,
	Realprice=Term#gsi.realprice,
	Buynum=Term#gsi.buynum,
	Data = <<Id:32, Showindex:32, Realprice:32, Buynum:32>>,
	Data.

%%
encode_acs(Term)->
	Id=Term#acs.id,
	State=Term#acs.state,
	Data = <<Id:32, State:32>>,
	Data.

%%
encode_a(Term)->
	Id=Term#a.id,
	Name=encode_string(Term#a.name),
	Ownerid=Term#a.ownerid,
	Ownername=encode_string(Term#a.ownername),
	Ownerlevel=Term#a.ownerlevel,
	Itemnum=Term#a.itemnum,
	Data = <<Id:64, Name/binary, Ownerid:64, Ownername/binary, Ownerlevel:32, Itemnum:32>>,
	Data.

%%
encode_b(Term)->
	Creatureid=Term#b.creatureid,
	Damagetype=Term#b.damagetype,
	Damage=Term#b.damage,
	Data = <<Creatureid:64, Damagetype:32, Damage:32>>,
	Data.

%%
encode_c(Term)->
	X=Term#c.x,
	Y=Term#c.y,
	Data = <<X:32, Y:32>>,
	Data.

%%
encode_f(Term)->
	Id=Term#f.id,
	Level=Term#f.level,
	Lefttime=Term#f.lefttime,
	Fulltime=Term#f.fulltime,
	Requirevalue=Term#f.requirevalue,
	Contribution=Term#f.contribution,
	Tcontribution=Term#f.tcontribution,
	Data = <<Id:32, Level:32, Lefttime:32, Fulltime:32, Requirevalue:32, Contribution:32, Tcontribution:32>>,
	Data.

%%
encode_g(Term)->
	Roleid=Term#g.roleid,
	Rolename=encode_string(Term#g.rolename),
	Rolelevel=Term#g.rolelevel,
	Gender=Term#g.gender,
	Classtype=Term#g.classtype,
	Posting=Term#g.posting,
	Contribution=Term#g.contribution,
	Online=Term#g.online,
	Nickname=encode_string(Term#g.nickname),
	Tcontribution=Term#g.tcontribution,
	Fightforce=Term#g.fightforce,
	Data = <<Roleid:64, Rolename/binary, Rolelevel:32, Gender:32, Classtype:32, Posting:32, Contribution:32, Online:32, Nickname/binary, Tcontribution:32, Fightforce:32>>,
	Data.

%%
encode_i(Term)->
	Itemid_low=Term#i.itemid_low,
	Itemid_high=Term#i.itemid_high,
	Protoid=Term#i.protoid,
	Enchantments=Term#i.enchantments,
	Count=Term#i.count,
	Slot=Term#i.slot,
	Isbonded=Term#i.isbonded,
	Socketsinfo=encode_int32_list(Term#i.socketsinfo),
	Duration=Term#i.duration,
	Enchant=encode_list(Term#i.enchant, fun encode_k/1),
	Lefttime_s=Term#i.lefttime_s,
	Data = <<Itemid_low:32, Itemid_high:32, Protoid:32, Enchantments:32, Count:32, Slot:32, Isbonded:32, Socketsinfo/binary, Duration:32, Enchant/binary, Lefttime_s:32>>,
	Data.

%%
encode_m(Term)->
	Roleid=Term#m.roleid,
	Rolename=encode_string(Term#m.rolename),
	Level=Term#m.level,
	Classtype=Term#m.classtype,
	Gender=Term#m.gender,
	Data = <<Roleid:64, Rolename/binary, Level:32, Classtype:32, Gender:32>>,
	Data.

%%
encode_l(Term)->
	Itemprotoid=Term#l.itemprotoid,
	Count=Term#l.count,
	Data = <<Itemprotoid:32, Count:32>>,
	Data.

%%
encode_rl(Term)->
	Roleid=Term#rl.roleid,
	Name=encode_string(Term#rl.name),
	X=Term#rl.x,
	Y=Term#rl.y,
	Friendly=Term#rl.friendly,
	Attrs=encode_list(Term#rl.attrs, fun encode_k/1),
	Data = <<Roleid:64, Name/binary, X:32, Y:32, Friendly:8, Attrs/binary>>,
	Data.

%%
encode_o(Term)->
	Objectid=Term#o.objectid,
	Objecttype=Term#o.objecttype,
	Attrs=encode_list(Term#o.attrs, fun encode_k/1),
	Data = <<Objectid:64, Objecttype:32, Attrs/binary>>,
	Data.

%%
%%encode_p(Term)->
%	Petid=Term#p.petid,
%	Protoid=Term#p.protoid,
%	Level=Term#p.level,
%	Name=encode_string(Term#p.name),
%	Gender=Term#p.gender,
%	Mana=Term#p.mana,
%	Quality=Term#p.quality,
%	Exp=Term#p.exp,
%	Power=Term#p.power,
%	Hitrate=Term#p.hitrate,
%	Criticalrate=Term#p.criticalrate,
%	Stamina=Term#p.stamina,
%	Fighting_force=Term#p.fighting_force,
%	Power_attr=Term#p.power_attr,
%%	Hitrate_attr=Term#p.hitrate_attr,
%	Criticalrate_attr=Term#p.criticalrate_attr,
%	Stamina_attr=Term#p.stamina_attr,
%	Happiness=Term#p.happiness,
%	Remain_attr=Term#p.remain_attr,
%	Mpmax=Term#p.mpmax,
%	Class_type=Term#p.class_type,
%	State=Term#p.state,
%	Quality_value=Term#p.quality_value,
%	T_power=Term#p.t_power,
%	T_hitrate=Term#p.t_hitrate,
%	T_critical=Term#p.t_critical,
%	T_stamina=Term#p.t_stamina,
%	T_gs=Term#p.t_gs,
%	Gs_sort=Term#p.gs_sort,
%	Quality_up_value=Term#p.quality_up_value,
%	Criticaldestoryrate=Term#p.criticaldestoryrate,
%	Pet_equips=encode_list(Term#p.pet_equips, fun encode_i/1),
%	Trade_lock=Term#p.trade_lock,
%	Data = <<Petid:64, Protoid:32, Level:32, Name/binary, Gender:32, Mana:32, Quality:32, Exp:64, Power:32, Hitrate:32, Criticalrate:32, Stamina:32, Fighting_force:32, Power_attr:32, Hitrate_attr:32, Criticalrate_attr:32, Stamina_attr:32, Happiness:32, Remain_attr:32, Mpmax:32, Class_type:32, State:32, Quality_value:32, T_power:32, T_hitrate:32, T_critical:32, T_stamina:32, T_gs:32, Gs_sort:32, Quality_up_value:32, Criticaldestoryrate:32, Pet_equips/binary, Trade_lock:32>>,
%	Data.
%%宠物相关信息
encode_p(Term)->
	Petid=Term#p.petid,
	Protoid=Term#p.protoid,
	Level=Term#p.level,
	Name=encode_string(Term#p.name),
	Quality=Term#p.quality,
	Hitrate=Term#p.hitrate,
	Criticalrate=Term#p.criticalrate,
	Happiness=Term#p.happiness,
	Class_type=Term#p.class_type,
	State=Term#p.state,
	Quality_value=Term#p.quality_value,
	Growth_value=Term#p.growth_value,
	Meleepower=Term#p.meleepower,
	Rangepower=Term#p.rangepower,
	Magicpower=Term#p.magicpower,
	Meleedefence=Term#p.meleedefence,
	Rangedefence=Term#p.rangedefence,
	Magicdefence=Term#p.magicdefence,
	Hp=Term#p.hp,
	Dodge=Term#p.dodge,
	Criticaldestroyrate=Term#p.criticaldestroyrate,
	Toughness=Term#p.toughness,
	Meleeimu=Term#p.meleeimu,
	Rangeimu=Term#p.rangeimu,
	Magicimu=Term#p.magicimu,
	Leveluptime_s=Term#p.leveluptime_s,
	Transform=Term#p.transform,
	Talentlist=encode_list(Term#p.talentlist, fun encode_pt/1),
	Skilllist=encode_list(Term#p.skilllist, fun encode_psk/1),
	Xs=encode_pxs(Term#p.xs),
	Advlucky=Term#p.advlucky,
	Fightforce=Term#p.fighting_force,
	Data = <<Petid:64, Protoid:32, Level:32, Name/binary, Quality:32, Hitrate:32, Criticalrate:32, Happiness:32, Class_type:32, State:32, Quality_value:32, Growth_value:32, Meleepower:32, Rangepower:32, Magicpower:32, Meleedefence:32, Rangedefence:32, Magicdefence:32, Hp:32, Dodge:32, Criticaldestroyrate:32, Toughness:32, Meleeimu:32, Rangeimu:32, Magicimu:32, Leveluptime_s:32, Transform:32, Talentlist/binary, Skilllist/binary, Xs/binary, Advlucky:32, Fightforce:32>>,
	Data.


%%宠物天赋
encode_pt(Term)->
	Level=Term#pt.level,
	Talentid=Term#pt.talentid,
	Id=Term#pt.id,
	Data = <<Level:32, Talentid:32, Id:32>>,
	Data.

encode_psk(Term)->
	Slot=Term#psk.slot,
	Skillid=Term#psk.skillid,
	Level=Term#psk.level,
	Data = <<Slot:32, Skillid:32, Level:32>>,
	Data.
%%洗髓
encode_pxs(Term)->
	Xshpmax=Term#pxs.xshpmax,
	Basemagicpower=Term#pxs.basemagicpower,
	Baserangedefence=Term#pxs.baserangedefence,
	Xsmeleepower=Term#pxs.xsmeleepower,
	Basemagicdefence=Term#pxs.basemagicdefence,
	Xsmeleedefence=Term#pxs.xsmeleedefence,
	Basemeleepower=Term#pxs.basemeleepower,
	Xsrangepower=Term#pxs.xsrangepower,
	Basehpmax=Term#pxs.basehpmax,
	Basemeleedefence=Term#pxs.basemeleedefence,
	Xsrangedefence=Term#pxs.xsrangedefence,
	Xsmagicpower=Term#pxs.xsmagicpower,
	Baserangepower=Term#pxs.baserangepower,
	Xsmagicdefence=Term#pxs.xsmagicdefence,
	Data = <<Xshpmax:32, Basemagicpower:32, Baserangedefence:32, Xsmeleepower:32, Basemagicdefence:32, Xsmeleedefence:32, Basemeleepower:32, Xsrangepower:32, Basehpmax:32, Basemeleedefence:32, Xsrangedefence:32, Xsmagicpower:32, Baserangepower:32, Xsmagicdefence:32>>,
	Data.

encode_q(Term)->
	Questid=Term#q.questid,
	Status=Term#q.status,
	Values=encode_int32_list(Term#q.values),
	Lefttime=Term#q.lefttime,
	Data = <<Questid:32, Status:32, Values/binary, Lefttime:32>>,
	Data.

%%
encode_r(Term)->
	Roleid=Term#r.roleid,
	Name=encode_string(Term#r.name),
	Lastmapid=Term#r.lastmapid,
	Classtype=Term#r.classtype,
	Gender=Term#r.gender,
	Level=Term#r.level,
	Data = <<Roleid:64, Name/binary, Lastmapid:32, Classtype:32, Gender:32, Level:32>>,
	Data.

%%
encode_s(Term)->
	Skillid=Term#s.skillid,
	Level=Term#s.level,
	Lefttime=Term#s.lefttime,
	Data = <<Skillid:32, Level:32, Lefttime:32>>,
	Data.

%%
encode_t(Term)->
	Roleid=Term#t.roleid,
	Level=Term#t.level,
	Life=Term#t.life,
	Maxhp=Term#t.maxhp,
	Mana=Term#t.mana,
	Maxmp=Term#t.maxmp,
	Posx=Term#t.posx,
	Posy=Term#t.posy,
	Mapid=Term#t.mapid,
	Lineid=Term#t.lineid,
	Cloth=Term#t.cloth,
	Arm=Term#t.arm,
	Data = <<Roleid:64, Level:32, Life:32, Maxhp:32, Mana:32, Maxmp:32, Posx:32, Posy:32, Mapid:32, Lineid:32, Cloth:32, Arm:32>>,
	Data.

%%
encode_ms(Term)->
	Mailid=encode_mid(Term#ms.mailid),
	From=encode_string(Term#ms.from),
	Titile=encode_string(Term#ms.titile),
	Status=encode_bool(Term#ms.status),
	Type=Term#ms.type,
	Has_add=encode_bool(Term#ms.has_add),
	Leftseconds=Term#ms.leftseconds,
	Month=Term#ms.month,
	Day=Term#ms.day,
	Data = <<Mailid/binary, From/binary, Titile/binary, Status/binary, Type:32, Has_add/binary, Leftseconds:32, Month:32, Day:32>>,
	Data.
%%
encode_nl(Term)->
	Npcid=Term#nl.npcid,
	Name=encode_string(Term#nl.name),
	X=Term#nl.x,
	Y=Term#nl.y,
	Friendly=Term#nl.friendly,
	Attrs=encode_list(Term#nl.attrs, fun encode_k/1),
	Data = <<Npcid:64, Name/binary, X:32, Y:32, Friendly:8, Attrs/binary>>,
	Data.

%%
encode_imi(Term)->
	Mitemid=Term#imi.mitemid,
	Price=encode_list(Term#imi.price, fun encode_ip/1),
	Discount=encode_list(Term#imi.discount, fun encode_di/1),
	Data = <<Mitemid:32, Price/binary, Discount/binary>>,
	Data.

%%
encode_duel_start_s2c(Term)->
	Roleid=Term#duel_start_s2c.roleid,
	Data = <<Roleid:64>>,
	Data.

%%
encode_eq(Term)->
	Everqid=Term#eq.everqid,
	Questid=Term#eq.questid,
	Free_fresh_times=Term#eq.free_fresh_times,
	Round=Term#eq.round,
	Section=Term#eq.section,
	Quality=Term#eq.quality,
	Data = <<Everqid:32, Questid:32, Free_fresh_times:32, Round:32, Section:32, Quality:32>>,
	Data.

%%
encode_ltm(Term)->
	Layer=Term#ltm.layer,
	Rolename=encode_string(Term#ltm.rolename),
	Time=Term#ltm.time,
	Data = <<Layer:32, Rolename/binary, Time:32>>,
	Data.

%%
encode_md(Term)->
	Mailid=encode_mid(Term#md.mailid),
	Content=encode_string(Term#md.content),
	Add_silver=Term#md.add_silver,
	Add_gold=Term#md.add_gold,
	Add_item=encode_list(Term#md.add_item, fun encode_i/1),
	Data = <<Mailid/binary, Content/binary, Add_silver:64, Add_gold:32, Add_item/binary>>,
	Data.

%%
encode_tsi(Term)->
	Itemprotoid=Term#tsi.itemprotoid,
	Solt=Term#tsi.solt,
	Count=Term#tsi.count,
	Itemsign=Term#tsi.itemsign,
	Data = <<Itemprotoid:32, Solt:32, Count:32, Itemsign:32>>,
	Data.

%%
encode_gbs(Term)->
	Index=Term#gbs.index,
	Guildlid=Term#gbs.guildlid,
	Guildhid=Term#gbs.guildhid,
	Guildname=encode_string(Term#gbs.guildname),
	Data = <<Index:32, Guildlid:32, Guildhid:32, Guildname/binary>>,
	Data.

%%
encode_si(Term)->
	Item=encode_i(Term#si.item),
	Money=Term#si.money,
	Gold=Term#si.gold,
	Silver=Term#si.silver,
	Data = <<Item/binary, Money:32, Gold:32, Silver:32>>,
	Data.

%%
encode_dfr(Term)->
	Fn=encode_string(Term#dfr.fn),
	Level=Term#dfr.level,
	Job=Term#dfr.job,
	Guildname=encode_string(Term#dfr.guildname),
	Gender=Term#dfr.gender,
	Data = <<Fn/binary, Level:32, Job:32, Guildname/binary, Gender:32>>,
	Data.

%%
encode_pp(Term)->
	Protoid=Term#pp.protoid,
	Quality=Term#pp.quality,
	Strength=Term#pp.strength,
	Agile=Term#pp.agile,
	Intelligence=Term#pp.intelligence,
	Stamina=Term#pp.stamina,
	Growth=Term#pp.growth,
	Stamina_growth=Term#pp.stamina_growth,
	Class_type=Term#pp.class_type,
	Talents=encode_int32_list(Term#pp.talents),
	Data = <<Protoid:32, Quality:32, Strength:32, Agile:32, Intelligence:32, Stamina:32, Growth:32, Stamina_growth:32, Class_type:32, Talents/binary>>,
	Data.

%%排行榜结构
encode_rk(Term)->
	Kv=encode_list(Term#rk.kv, fun encode_k/1),
	Args=encode_int32_list(Term#rk.args),
	Data = <<Kv/binary, Args/binary>>,
	Data.


%%
encode_gmp(Term)->
	Roleid=Term#gmp.roleid,
	Lineid=Term#gmp.lineid,
	Mapid=Term#gmp.mapid,
	Data = <<Roleid:64, Lineid:32, Mapid:32>>,
	Data.

%%
encode_rr(Term)->
	Id=Term#rr.id,
	Name=encode_string(Term#rr.name),
	Level=Term#rr.level,
	Classid=Term#rr.classid,
	Instance=Term#rr.instance,
	Data = <<Id:64, Name/binary, Level:32, Classid:32, Instance:32>>,
	Data.

%%
encode_psl(Term)->
	Petid=Term#psl.petid,
	Slots=encode_list(Term#psl.slots, fun encode_psll/1),
	Data = <<Petid:64, Slots/binary>>,
	Data.

%%
encode_ssi(Term)->
	Item=encode_si(Term#ssi.item),
	Stallid=Term#ssi.stallid,
	Ownerid=Term#ssi.ownerid,
	Ownername=encode_string(Term#ssi.ownername),
	Itemnum=Term#ssi.itemnum,
	Isonline=Term#ssi.isonline,
	Data = <<Item/binary, Stallid:64, Ownerid:64, Ownername/binary, Itemnum:32, Isonline:32>>,
	Data.

%%
encode_tr(Term)->
	Roleid=Term#tr.roleid,
	Rolename=encode_string(Term#tr.rolename),
	Rolegender=Term#tr.rolegender,
	Roleclass=Term#tr.roleclass,
	Rolelevel=Term#tr.rolelevel,
	Kills=Term#tr.kills,
	Score=Term#tr.score,
	Data = <<Roleid:64, Rolename/binary, Rolegender:32, Roleclass:32, Rolelevel:32, Kills:32, Score:32>>,
	Data.

%%
encode_spa(Term)->
	Spaid=Term#spa.spaid,
	Join_count=Term#spa.join_count,
	Limit=Term#spa.limit,
	Data = <<Spaid:32, Join_count:32, Limit:32>>,
	Data.

%%
encode_lti(Term)->
	Protoid=Term#lti.protoid,
	Item_count=Term#lti.item_count,
	Data = <<Protoid:32, Item_count:32>>,
	Data.

%%
encode_dh(Term)->
	Itemclsid=Term#dh.itemclsid,
	Consume=encode_list(Term#dh.consume, fun encode_l/1),
	Money=encode_list(Term#dh.money, fun encode_ip/1),
	Data = <<Itemclsid:32, Consume/binary, Money/binary>>,
	Data.

%%
encode_zoneinfo(Term)->
	Zoneid=Term#zoneinfo.zoneid,
	State=Term#zoneinfo.state,
	Data = <<Zoneid:32, State:32>>,
	Data.

%%
encode_rc(Term)->
	Rolename=encode_string_list(Term#rc.rolename),
	Args=encode_int32_list(Term#rc.args),
	Data = <<Rolename/binary, Args/binary>>,
	Data.

%%
encode_rp(Term)->
	Petid=Term#rp.petid,
	Petname=encode_string(Term#rp.petname),
	Rolename=encode_string(Term#rp.rolename),
	Args=Term#rp.args,
	Data = <<Petid:64, Petname/binary, Rolename/binary, Args:32>>,
	Data.

%%
encode_ps(Term)->
	Slot=Term#ps.slot,
	Proto=Term#ps.proto,
	Price=Term#ps.price,
	Quality=Term#ps.quality,
	Data = <<Slot:32, Proto:32, Price:32, Quality:32>>,
	Data.

%%
encode_gti(Term)->
	Id=Term#gti.id,
	Showindex=Term#gti.showindex,
	Realprice=Term#gti.realprice,
	Buynum=Term#gti.buynum,
	Data = <<Id:32, Showindex:32, Realprice:32, Buynum:32>>,
	Data.

%%


%%
encode_stagetop(Term)->
	Serverid=Term#stagetop.serverid,
	Roleid=Term#stagetop.roleid,
	Name=encode_string(Term#stagetop.name),
	Bestscore=Term#stagetop.bestscore,
	Data = <<Serverid:32, Roleid:64, Name/binary, Bestscore:32>>,
	Data.

%%
encode_psll(Term)->
	Slot=Term#psll.slot,
	Status=Term#psll.status,
	Data = <<Slot:32, Status:32>>,
	Data.

%%
encode_mid(Term)->
	Midlow=Term#mid.midlow,
	Midhigh=Term#mid.midhigh,
	Data = <<Midlow:32, Midhigh:32>>,
	Data.

%%
encode_pfr(Term)->
	Fn=encode_string(Term#pfr.fn),
	Lineid=Term#pfr.lineid,
	Mapid=Term#pfr.mapid,
	Posx=Term#pfr.posx,
	Posy=Term#pfr.posy,
	Data = <<Fn/binary, Lineid:32, Mapid:32, Posx:32, Posy:32>>,
	Data.

%%
encode_jszd(Term)->
	Id=encode_string(Term#jszd.id),
	Name=encode_string(Term#jszd.name),
	Score=Term#jszd.score,
	Rank=Term#jszd.rank,
	Peoples=Term#jszd.peoples,
	Data = <<Id/binary, Name/binary, Score:32, Rank:32, Peoples:32>>,
	Data.

%%
encode_ki(Term)->
	Roleid=Term#ki.roleid,
	Rolename=encode_string(Term#ki.rolename),
	Roleclass=Term#ki.roleclass,
	Rolelevel=Term#ki.rolelevel,
	Times=Term#ki.times,
	Data = <<Roleid:64, Rolename/binary, Roleclass:32, Rolelevel:32, Times:32>>,
	Data.

%%
encode_oqe(Term)->
	Questid=Term#oqe.questid,
	Addition=Term#oqe.addition,
	Data = <<Questid:32, Addition:32>>,
	Data.

%%
encode_ti(Term)->
	Trade_slot=Term#ti.trade_slot,
	Item_attrs=encode_i(Term#ti.item_attrs),
	Data = <<Trade_slot:32, Item_attrs/binary>>,
	Data.

%%
encode_gr(Term)->
	Guildlid=Term#gr.guildlid,
	Guildhid=Term#gr.guildhid,
	Guildname=encode_string(Term#gr.guildname),
	Level=Term#gr.level,
	Membernum=Term#gr.membernum,
	Formalnum=Term#gr.formalnum,
	Leader=encode_string(Term#gr.leader),
	Restrict=Term#gr.restrict,
	Facslevel=encode_int32_list(Term#gr.facslevel),
	Applyflag=Term#gr.applyflag,
	Createyear=Term#gr.createyear,
	Createmonth=Term#gr.createmonth,
	Createday=Term#gr.createday,
	Sort=Term#gr.sort,
	Guild_strength=Term#gr.guild_strength,
	Guild_silver=Term#gr.guild_silver,
	Data = <<Guildlid:32, Guildhid:32, Guildname/binary, Level:32, Membernum:32, Formalnum:32, Leader/binary, Restrict:32, Facslevel/binary, Applyflag:32, Createyear:32, Createmonth:32, Createday:32, Sort:32, Guild_strength:32, Guild_silver:64>>,
	Data.

%%
encode_bf(Term)->
	Bufferid=Term#bf.bufferid,
	Bufferlevel=Term#bf.bufferlevel,
	Durationtime=Term#bf.durationtime,
	Data = <<Bufferid:32, Bufferlevel:32, Durationtime:32>>,
	Data.

%%
encode_tp(Term)->
	Roleid=Term#tp.roleid,
	X=Term#tp.x,
	Y=Term#tp.y,
	Data = <<Roleid:64, X:32, Y:32>>,
	Data.

%%
encode_cl(Term)->
	Post=Term#cl.post,
	Postindex=Term#cl.postindex,
	Roleid=Term#cl.roleid,
	Name=encode_string(Term#cl.name),
	Gender=Term#cl.gender,
	Roleclass=Term#cl.roleclass,
	Data = <<Post:32, Postindex:32, Roleid:64, Name/binary, Gender:32, Roleclass:32>>,
	Data.

%%
encode_fr(Term)->
	Id=Term#fr.id,
	Fn=encode_string(Term#fr.fn),
	Classid=Term#fr.classid,
	Gender=Term#fr.gender,
	Online=Term#fr.online,
	Sign=encode_string(Term#fr.sign),
	Intimacy=Term#fr.intimacy,
	Level=Term#fr.level,
	Data = <<Id:64, Fn/binary, Classid:32, Gender:32, Online:32, Sign/binary, Intimacy:32, Level:32>>,
	Data.

%%
encode_ag(Term)->
	Roleid=Term#ag.roleid,
	Leaderid=Term#ag.leaderid,
	Leadername=encode_string(Term#ag.leadername),
	Leaderlevel=Term#ag.leaderlevel,
	Member_num=Term#ag.member_num,
	Data = <<Roleid:64, Leaderid:64, Leadername/binary, Leaderlevel:32, Member_num:32>>,
	Data.

%%
encode_di(Term)->
	Disctype=Term#di.disctype,
	Count=Term#di.count,
	Data = <<Disctype:32, Count:32>>,
	Data.

%%
encode_mi(Term)->
	Mitemid=Term#mi.mitemid,
	Ntype=Term#mi.ntype,
	Ishot=Term#mi.ishot,
	Sort=Term#mi.sort,
	Price=encode_list(Term#mi.price, fun encode_ip/1),
	Discount=encode_list(Term#mi.discount, fun encode_di/1),
	Data = <<Mitemid:32, Ntype:32, Ishot:32, Sort:32, Price/binary, Discount/binary>>,
	Data.

%%
encode_br(Term)->
	Id=Term#br.id,
	Fn=encode_string(Term#br.fn),
	Classid=Term#br.classid,
	Gender=Term#br.gender,
	Data = <<Id:64, Fn/binary, Classid:32, Gender:32>>,
	Data.

%%
encode_ri(Term)->
	Leader_id=Term#ri.leader_id,
	Leader_line=Term#ri.leader_line,
	Instance=Term#ri.instance,
	Members=encode_list(Term#ri.members, fun encode_m/1),
	Description=encode_string(Term#ri.description),
	Data = <<Leader_id:64, Leader_line:32, Instance:32, Members/binary, Description/binary>>,
	Data.

%%
encode_tab_state(Term)->
	Id=Term#tab_state.id,
	State=Term#tab_state.state,
	Data = <<Id:32, State:32>>,
	Data.

%%
encode_rcs(Term)->
	Roleid=Term#rcs.roleid,
	Today_count=Term#rcs.today_count,
	Total_count=Term#rcs.total_count,
	Data = <<Roleid:64, Today_count:32, Total_count:32>>,
	Data.

%%
encode_smi(Term)->
	Mitemid=Term#smi.mitemid,
	Sort=Term#smi.sort,
	Uptime=Term#smi.uptime,
	Mycount=Term#smi.mycount,
	Price=encode_list(Term#smi.price, fun encode_ip/1),
	Discount=encode_list(Term#smi.discount, fun encode_di/1),
	Data = <<Mitemid:32, Sort:32, Uptime:32, Mycount:32, Price/binary, Discount/binary>>,
	Data.

%%
encode_tbi(Term)->
	Battleid=Term#tbi.battleid,
	Curnum=Term#tbi.curnum,
	Totlenum=Term#tbi.totlenum,
	Data = <<Battleid:32, Curnum:32, Totlenum:32>>,
	Data.

%%
encode_chess_spirit_role_info_s2c(Term)->
	Power=Term#chess_spirit_role_info_s2c.power,
	Chesspower=Term#chess_spirit_role_info_s2c.chesspower,
	Max_power=Term#chess_spirit_role_info_s2c.max_power,
	Max_chesspower=Term#chess_spirit_role_info_s2c.max_chesspower,
	Share_skills=encode_list(Term#chess_spirit_role_info_s2c.share_skills, fun encode_s/1),
	Self_skills=encode_list(Term#chess_spirit_role_info_s2c.self_skills, fun encode_s/1),
	Chess_skills=encode_list(Term#chess_spirit_role_info_s2c.chess_skills, fun encode_s/1),
	Type=Term#chess_spirit_role_info_s2c.type,
	Data = <<Power:32, Chesspower:32, Max_power:32, Max_chesspower:32, Share_skills/binary, Self_skills/binary, Chess_skills/binary, Type:32>>,
	<<1171:16, Data/binary>>.

%%
encode_moneygame_prepare_s2c(Term)->
	Second=Term#moneygame_prepare_s2c.second,
	Data = <<Second:32>>,
	<<1242:16, Data/binary>>.

%%
encode_guild_bonfire_start_s2c(Term)->
	Lefttime=Term#guild_bonfire_start_s2c.lefttime,
	Data = <<Lefttime:32>>,
	<<1219:16, Data/binary>>.

%%
encode_money_from_monster_s2c(Term)->
	Npcid=Term#money_from_monster_s2c.npcid,
	Npcproto=Term#money_from_monster_s2c.npcproto,
	Money=Term#money_from_monster_s2c.money,
	Data = <<Npcid:64, Npcproto:32, Money:32>>,
	<<113:16, Data/binary>>.

%%
encode_battlefield_info_c2s(Term)->
	Battle=Term#battlefield_info_c2s.battle,
	Data = <<Battle:32>>,
	<<1088:16, Data/binary>>.

%%
encode_chess_spirit_game_over_s2c(Term)->
	Type=Term#chess_spirit_game_over_s2c.type,
	Section=Term#chess_spirit_game_over_s2c.section,
	Used_time_s=Term#chess_spirit_game_over_s2c.used_time_s,
	Reason=Term#chess_spirit_game_over_s2c.reason,
	Data = <<Type:32, Section:32, Used_time_s:32, Reason:32>>,
	<<1183:16, Data/binary>>.

%%
encode_guild_monster_opt_result_s2c(Term)->
	Result=Term#guild_monster_opt_result_s2c.result,
	Data = <<Result:32>>,
	<<354:16, Data/binary>>.

%%
encode_activity_state_update_s2c(Term)->
	Updateas=encode_acs(Term#activity_state_update_s2c.updateas),
	Data = <<Updateas/binary>>,
	<<1412:16, Data/binary>>.

%%
encode_change_smith_need_contribution_c2s(Term)->
	Contribution=Term#change_smith_need_contribution_c2s.contribution,
	Data = <<Contribution:32>>,
	<<357:16, Data/binary>>.

%%
encode_equipment_fenjie_c2s(Term)->
	Equipment=encode_int32_list(Term#equipment_fenjie_c2s.equipment),
	Data = <<Equipment/binary>>,
	<<628:16, Data/binary>>.

%%
encode_equip_fenjie_optresult_s2c(Term)->
	Result=Term#equip_fenjie_optresult_s2c.result,
	Data = <<Result:32>>,
	<<629:16, Data/binary>>.

%%
encode_vip_role_use_flyshoes_s2c(Term)->
	Leftnum=Term#vip_role_use_flyshoes_s2c.leftnum,
	Totlenum=Term#vip_role_use_flyshoes_s2c.totlenum,
	Data = <<Leftnum:32, Totlenum:32>>,
	<<678:16, Data/binary>>.

%%
encode_join_vip_map_c2s(Term)->
	Transid=Term#join_vip_map_c2s.transid,
	Data = <<Transid:32>>,
	<<679:16, Data/binary>>.

%%
encode_mp_package_s2c(Term)->
	Itemidl=Term#mp_package_s2c.itemidl,
	Itemidh=Term#mp_package_s2c.itemidh,
	Buffid=Term#mp_package_s2c.buffid,
	Data = <<Itemidl:32, Itemidh:32, Buffid:32>>,
	<<809:16, Data/binary>>.

%%
encode_join_battle_error_s2c(Term)->
	Errno=Term#join_battle_error_s2c.errno,
	Data = <<Errno:32>>,
	<<818:16, Data/binary>>.

%%
encode_leave_guild_instance_c2s(Term)->
	Data = <<>>,
	<<358:16, Data/binary>>.

%%
encode_join_guild_instance_c2s(Term)->
	Type=Term#join_guild_instance_c2s.type,
	Data = <<Type:32>>,
	<<359:16, Data/binary>>.

%%
encode_sell_item_fail_s2c(Term)->
	Reason=Term#sell_item_fail_s2c.reason,
	Data = <<Reason:32>>,
	<<316:16, Data/binary>>.

%%
encode_treasure_chest_broad_s2c(Term)->
	Rolename=encode_string(Term#treasure_chest_broad_s2c.rolename),
	Item=encode_lti(Term#treasure_chest_broad_s2c.item),
	Data = <<Rolename/binary, Item/binary>>,
	<<991:16, Data/binary>>.

%%
encode_npc_function_c2s(Term)->
	Npcid=Term#npc_function_c2s.npcid,
	Data = <<Npcid:64>>,
	<<301:16, Data/binary>>.

%%
encode_pet_rename_c2s(Term)->
	Petid=Term#pet_rename_c2s.petid,
	Newname=encode_string(Term#pet_rename_c2s.newname),
	Slot=Term#pet_rename_c2s.slot,
	Type=Term#pet_rename_c2s.type,
	Data = <<Petid:64, Newname/binary, Slot:32, Type:32>>,
	<<906:16, Data/binary>>.

%%
encode_welfare_activity_update_s2c(Term)->
	Typenumber=Term#welfare_activity_update_s2c.typenumber,
	State=Term#welfare_activity_update_s2c.state,
	Result=Term#welfare_activity_update_s2c.result,
	Data = <<Typenumber:32, State:32, Result:32>>,
	<<1531:16, Data/binary>>.

%%
encode_equipment_enchant_c2s(Term)->
	Equipment=Term#equipment_enchant_c2s.equipment,
	Enchant=Term#equipment_enchant_c2s.enchant,
	Data = <<Equipment:32, Enchant:32>>,
	<<617:16, Data/binary>>.

%%
encode_reset_random_rolename_c2s(Term)->
	Data = <<>>,
	<<1121:16, Data/binary>>.

%%
encode_treasure_chest_failed_s2c(Term)->
	Reason=Term#treasure_chest_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<983:16, Data/binary>>.

%%
encode_activity_forecast_begin_s2c(Term)->
	Type=Term#activity_forecast_begin_s2c.type,
	Beginhour=Term#activity_forecast_begin_s2c.beginhour,
	Beginmin=Term#activity_forecast_begin_s2c.beginmin,
	Beginsec=Term#activity_forecast_begin_s2c.beginsec,
	Endhour=Term#activity_forecast_begin_s2c.endhour,
	Endmin=Term#activity_forecast_begin_s2c.endmin,
	Endsec=Term#activity_forecast_begin_s2c.endsec,
	Data = <<Type:32, Beginhour:32, Beginmin:32, Beginsec:32, Endhour:32, Endmin:32, Endsec:32>>,
	<<1230:16, Data/binary>>.

%%
encode_moneygame_cur_sec_s2c(Term)->
	Cursec=Term#moneygame_cur_sec_s2c.cursec,
	Maxsec=Term#moneygame_cur_sec_s2c.maxsec,
	Data = <<Cursec:32, Maxsec:32>>,
	<<1243:16, Data/binary>>.

%%
encode_npc_function_s2c(Term)->
	Npcid=Term#npc_function_s2c.npcid,
	Values=encode_list(Term#npc_function_s2c.values, fun encode_kl/1),
	Quests=encode_int32_list(Term#npc_function_s2c.quests),
	Queststate=encode_int32_list(Term#npc_function_s2c.queststate),
	Everquests=encode_int32_list(Term#npc_function_s2c.everquests),
	Data = <<Npcid:64, Values/binary, Quests/binary, Queststate/binary, Everquests/binary>>,
	<<302:16, Data/binary>>.

%%
encode_set_black_c2s(Term)->
	Fn=encode_string(Term#set_black_c2s.fn),
	Data = <<Fn/binary>>,
	<<475:16, Data/binary>>.

%%
encode_fatigue_prompt_s2c(Term)->
	Prompt=encode_string(Term#fatigue_prompt_s2c.prompt),
	Data = <<Prompt/binary>>,
	<<350:16, Data/binary>>.

%%
encode_quest_complete_failed_s2c(Term)->
	Questid=Term#quest_complete_failed_s2c.questid,
	Errno=Term#quest_complete_failed_s2c.errno,
	Data = <<Questid:32, Errno:32>>,
	<<91:16, Data/binary>>.

%%
encode_pet_skill_slot_lock_c2s(Term)->
	Petid=Term#pet_skill_slot_lock_c2s.petid,
	Slot=Term#pet_skill_slot_lock_c2s.slot,
	Status=Term#pet_skill_slot_lock_c2s.status,
	Data = <<Petid:64, Slot:32, Status:32>>,
	<<926:16, Data/binary>>.

%%
encode_treasure_storage_delitem_s2c(Term)->
	Start=Term#treasure_storage_delitem_s2c.start,
	Length=Term#treasure_storage_delitem_s2c.length,
	Data = <<Start:32, Length:32>>,
	<<1317:16, Data/binary>>.

%%
encode_unequip_item_for_pet_c2s(Term)->
	Petid=Term#unequip_item_for_pet_c2s.petid,
	Slot=Term#unequip_item_for_pet_c2s.slot,
	Data = <<Petid:64, Slot:32>>,
	<<1512:16, Data/binary>>.

%%
encode_congratulations_levelup_c2s(Term)->
	Roleid=Term#congratulations_levelup_c2s.roleid,
	Level=Term#congratulations_levelup_c2s.level,
	Type=Term#congratulations_levelup_c2s.type,
	Data = <<Roleid:64, Level:32, Type:32>>,
	<<1141:16, Data/binary>>.

%%
encode_goals_error_s2c(Term)->
	Reason=Term#goals_error_s2c.reason,
	Data = <<Reason:32>>,
	<<643:16, Data/binary>>.

%%
%%encode_achieve_open_c2s(Term)->
%%	Data = <<>>,
%%	<<630:16, Data/binary>>.

%%
%encode_chat_c2s(Term)->
%	Type=Term#chat_c2s.type,
%	Desserverid=Term#chat_c2s.desserverid,
%	Desrolename=encode_string(Term#chat_c2s.desrolename),
%	Msginfo=encode_string(Term#chat_c2s.msginfo),
%	Details=encode_string_list(Term#chat_c2s.details),
%	Data = <<Type:32, Desserverid:32, Desrolename/binary, Msginfo/binary, Details/binary>>,
%	<<140:16, Data/binary>>.

encode_chat_c2s(Term)->
	Type=Term#chat_c2s.type,
	Desserverid=Term#chat_c2s.desserverid,
	Desrolename=encode_string(Term#chat_c2s.desrolename),
	Msginfo=encode_string(Term#chat_c2s.msginfo),
	Details=encode_string_list(Term#chat_c2s.details),
	Reptype=Term#chat_c2s.reptype,
	Data = <<Type:32, Desserverid:32, Desrolename/binary, Msginfo/binary, Details/binary, Reptype:32>>,
	<<140:16, Data/binary>>.
%%
encode_equipment_enchant_s2c(Term)->
	Enchants=encode_list(Term#equipment_enchant_s2c.enchants, fun encode_k/1),
	Data = <<Enchants/binary>>,
	<<618:16, Data/binary>>.

%%
encode_treasure_storage_opt_s2c(Term)->
	Code=Term#treasure_storage_opt_s2c.code,
	Data = <<Code:32>>,
	<<1318:16, Data/binary>>.

%%
encode_answer_sign_notice_s2c(Term)->
	Lefttime=Term#answer_sign_notice_s2c.lefttime,
	Data = <<Lefttime:32/float>>,
	<<1122:16, Data/binary>>.

%%
encode_call_guild_monster_c2s(Term)->
	Monsterid=Term#call_guild_monster_c2s.monsterid,
	Data = <<Monsterid:32>>,
	<<1761:16, Data/binary>>.

%%
encode_ride_pet_synthesis_c2s(Term)->
	Slot_a=Term#ride_pet_synthesis_c2s.slot_a,
	Slot_b=Term#ride_pet_synthesis_c2s.slot_b,
	Itemslot=Term#ride_pet_synthesis_c2s.itemslot,
	Type=Term#ride_pet_synthesis_c2s.type,
	Data = <<Slot_a:32, Slot_b:32, Itemslot:32, Type:32>>,
	<<1482:16, Data/binary>>.

%%
encode_guild_info_s2c(Term)->
	Guildname=encode_string(Term#guild_info_s2c.guildname),
	Level=Term#guild_info_s2c.level,
	Silver=Term#guild_info_s2c.silver,
	Gold=Term#guild_info_s2c.gold,
	Notice=encode_string(Term#guild_info_s2c.notice),
	Roleinfos=encode_list(Term#guild_info_s2c.roleinfos, fun encode_g/1),
	Facinfos=encode_list(Term#guild_info_s2c.facinfos, fun encode_f/1),
	Chatgroup=encode_string(Term#guild_info_s2c.chatgroup),
	Voicegroup=encode_string(Term#guild_info_s2c.voicegroup),
	Guild_strength=Term#guild_info_s2c.guild_strength,
	Data = <<Guildname/binary, Level:32, Silver:32, Gold:32, Notice/binary, Roleinfos/binary, Facinfos/binary, Chatgroup/binary, Voicegroup/binary, Guild_strength:32>>,
	<<380:16, Data/binary>>.

%%成就初始化
%%encode_achieve_init_s2c(Term)->
%%	Parts=encode_list(Term#achieve_init_s2c.parts, fun encode_ach/1),
%%	Data = <<Parts/binary>>,
%%	<<631:16, Data/binary>>.

encode_achieve_init_s2c(Term)->
	Achieve_value=Term#achieve_init_s2c.achieve_value,
	Recent_achieve=encode_list(Term#achieve_init_s2c.recent_achieve, fun encode_ach_id/1),
	Fuwen=encode_list(Term#achieve_init_s2c.fuwen, fun encode_fw/1),
	Achieve_info=encode_list(Term#achieve_init_s2c.achieve_info, fun encode_achieve_info/1),
	Award=encode_list(Term#achieve_init_s2c.award, fun encode_award_state/1),
	Data = <<Achieve_value:32, Recent_achieve/binary, Fuwen/binary, Achieve_info/binary, Award/binary>>,
	<<631:16, Data/binary>>.

encode_ach_id(Term)->
	Type=Term#ach_id.type,
	Part=Term#ach_id.part,
	Data = <<Type:32, Part:32>>,
	Data.

%%
encode_fw(Term)->
	Id=Term#fw.id,
	Level=Term#fw.level,
	Data = <<Id:32, Level:32>>,
	Data.

%%
encode_achieve_info(Term)->
	State=Term#achieve_info.state,
	Achieve_id=encode_ach_id(Term#achieve_info.achieve_id),
	Finished=Term#achieve_info.finished,
	Data = <<State:32, Achieve_id/binary, Finished:32>>,
	Data.

%%
encode_award_state(Term)->
	State=Term#award_state.state,
	Id=Term#award_state.id,
	Data = <<State:32, Id:32>>,
	Data.

%%
encode_questgiver_states_update_c2s(Term)->
	Npcid=encode_int64_list(Term#questgiver_states_update_c2s.npcid),
	Data = <<Npcid/binary>>,
	<<92:16, Data/binary>>.

%%
encode_activity_boss_born_init_c2s(Term)->
	Data = <<>>,
	<<1413:16, Data/binary>>.

%%
encode_play_effects_s2c(Term)->
	Type=Term#play_effects_s2c.type,
	Optroleid=Term#play_effects_s2c.optroleid,
	Effectid=Term#play_effects_s2c.effectid,
	Data = <<Type:32, Optroleid:64, Effectid:32>>,
	<<1743:16, Data/binary>>.

%%
encode_festival_recharge_s2c(Term)->
	Festival_id=Term#festival_recharge_s2c.festival_id,
	State=Term#festival_recharge_s2c.state,
	Starttime=encode_time_struct(Term#festival_recharge_s2c.starttime),
	Endtime=encode_time_struct(Term#festival_recharge_s2c.endtime),
	Award_limit_time=encode_time_struct(Term#festival_recharge_s2c.award_limit_time),
	Lefttime=Term#festival_recharge_s2c.lefttime,
	Today_charge_num=Term#festival_recharge_s2c.today_charge_num,
	Exchange_info=encode_list(Term#festival_recharge_s2c.exchange_info, fun encode_charge/1),
	Gift=encode_list(Term#festival_recharge_s2c.gift, fun encode_giftinfo/1),
	Data = <<Festival_id:32, State:32, Starttime/binary, Endtime/binary, Award_limit_time/binary, Lefttime:64, Today_charge_num:32, Exchange_info/binary, Gift/binary>>,
	<<1692:16, Data/binary>>.

%%
encode_entry_loop_instance_vote_s2c(Term)->
	Type=Term#entry_loop_instance_vote_s2c.type,
	State=encode_list(Term#entry_loop_instance_vote_s2c.state, fun encode_votestate/1),
	Data = <<Type:32, State/binary>>,
	<<1801:16, Data/binary>>.

%%
encode_facebook_bind_check_c2s(Term)->
	Data = <<>>,
	<<1445:16, Data/binary>>.

%%
encode_chess_spirit_quit_c2s(Term)->
	Data = <<>>,
	<<1182:16, Data/binary>>.

%%
encode_spa_update_count_s2c(Term)->
	Chopping=Term#spa_update_count_s2c.chopping,
	Swimming=Term#spa_update_count_s2c.swimming,
	Data = <<Chopping:32, Swimming:32>>,
	<<1615:16, Data/binary>>.

%%收藏送礼
encode_collect_page_c2s(Term)->
	Data = <<>>,
	<<1890:16, Data/binary>>.

%%
encode_guild_update_apply_result_s2c(Term)->
	Guildlid=Term#guild_update_apply_result_s2c.guildlid,
	Guildhid=Term#guild_update_apply_result_s2c.guildhid,
	Result=Term#guild_update_apply_result_s2c.result,
	Data = <<Guildlid:32, Guildhid:32, Result:32>>,
	<<1212:16, Data/binary>>.

%%
encode_equipment_recast_c2s(Term)->
	Equipment=Term#equipment_recast_c2s.equipment,
	Recast=Term#equipment_recast_c2s.recast,
	Type=Term#equipment_recast_c2s.type,
	Lock_arr=encode_int32_list(Term#equipment_recast_c2s.lock_arr),
	Data = <<Equipment:32, Recast:32, Type:32, Lock_arr/binary>>,
	<<619:16, Data/binary>>.

%%
encode_answer_sign_request_c2s(Term)->
	Data = <<>>,
	<<1123:16, Data/binary>>.

%%
encode_rank_disdain_role_c2s(Term)->
	Roleid=Term#rank_disdain_role_c2s.roleid,
	Data = <<Roleid:64>>,
	<<1440:16, Data/binary>>.

%%
encode_treasure_chest_raffle_c2s(Term)->
	Data = <<>>,
	<<984:16, Data/binary>>.

%%
encode_pet_upgrade_quality_up_s2c(Term)->
	Type=Term#pet_upgrade_quality_up_s2c.type,
	Result=Term#pet_upgrade_quality_up_s2c.result,
	Value=Term#pet_upgrade_quality_up_s2c.value,
	Data = <<Type:32, Result:32, Value:32>>,
	<<1505:16, Data/binary>>.

%%
encode_activity_value_init_c2s(Term)->
	Data = <<>>,
	<<1400:16, Data/binary>>.

%%
encode_chess_spirit_log_s2c(Term)->
	Type=Term#chess_spirit_log_s2c.type,
	Lastsec=Term#chess_spirit_log_s2c.lastsec,
	Lasttime=Term#chess_spirit_log_s2c.lasttime,
	Bestsec=Term#chess_spirit_log_s2c.bestsec,
	Bestsectime=Term#chess_spirit_log_s2c.bestsectime,
	Canreward=Term#chess_spirit_log_s2c.canreward,
	Rewardexp=Term#chess_spirit_log_s2c.rewardexp,
	Rewarditems=encode_list(Term#chess_spirit_log_s2c.rewarditems, fun encode_l/1),
	Data = <<Type:32, Lastsec:32, Lasttime:32, Bestsec:32, Bestsectime:32, Canreward:32, Rewardexp:32, Rewarditems/binary>>,
	<<1180:16, Data/binary>>.

%%
encode_mail_get_addition_s2c(Term)->
	Mailid=encode_mid(Term#mail_get_addition_s2c.mailid),
	Data = <<Mailid/binary>>,
	<<536:16, Data/binary>>.

%%
encode_offline_exp_error_s2c(Term)->
	Reason=Term#offline_exp_error_s2c.reason,
	Data = <<Reason:32>>,
	<<1134:16, Data/binary>>.

%%
encode_inspect_pet_c2s(Term)->
	Serverid=Term#inspect_pet_c2s.serverid,
	Rolename=encode_string(Term#inspect_pet_c2s.rolename),
	Petid=Term#inspect_pet_c2s.petid,
	Data = <<Serverid:32, Rolename/binary, Petid:64>>,
	<<922:16, Data/binary>>.

%%
encode_christmas_activity_reward_c2s(Term)->
	Type=Term#christmas_activity_reward_c2s.type,
	Data = <<Type:32>>,
	<<1741:16, Data/binary>>.

%%
encode_answer_sign_success_s2c(Term)->
	Data = <<>>,
	<<1124:16, Data/binary>>.

%%
encode_rank_praise_role_c2s(Term)->
	Roleid=Term#rank_praise_role_c2s.roleid,
	Data = <<Roleid:64>>,
	<<1441:16, Data/binary>>.

%%收藏送礼
encode_collect_page_s2c(Term)->
	Data = <<>>,
	<<1891:16, Data/binary>>.

%%
encode_sitdown_c2s(Term)->
	Data = <<>>,
	<<1250:16, Data/binary>>.

%%
encode_activity_boss_born_init_s2c(Term)->
	Bslist=encode_list(Term#activity_boss_born_init_s2c.bslist, fun encode_bs/1),
	Data = <<Bslist/binary>>,
	<<1414:16, Data/binary>>.

%%
encode_activity_boss_born_update_s2c(Term)->
	Updatebs=encode_bs(Term#activity_boss_born_update_s2c.updatebs),
	Data = <<Updatebs/binary>>,
	<<1415:16, Data/binary>>.

%%
%encode_chat_s2c(Term)->
%	Type=Term#chat_s2c.type,
%	Serverid=Term#chat_s2c.serverid,
%	Privateflag=Term#chat_s2c.privateflag,
%	Desroleid=Term#chat_s2c.desroleid,
%	Desrolename=encode_string(Term#chat_s2c.desrolename),
%	Msginfo=encode_string(Term#chat_s2c.msginfo),
%	Details=encode_string_list(Term#chat_s2c.details),
%	Identity=Term#chat_s2c.identity,
%	Data = <<Type:32, Serverid:32, Privateflag:32, Desroleid:64, Desrolename/binary, Msginfo/binary, Details/binary, Identity:32>>,
%	<<141:16, Data/binary>>.

encode_chat_s2c(Term)->
	Type=Term#chat_s2c.type,
	Serverid=Term#chat_s2c.serverid,
	Privateflag=Term#chat_s2c.privateflag,
	Desroleid=Term#chat_s2c.desroleid,
	Desrolename=encode_string(Term#chat_s2c.desrolename),
	Msginfo=encode_string(Term#chat_s2c.msginfo),
	Details=encode_string_list(Term#chat_s2c.details),
	Identity=Term#chat_s2c.identity,
	Reptype=Term#chat_s2c.reptype,
	Data = <<Type:32, Serverid:32, Privateflag:32, Desroleid:64, Desrolename/binary, Msginfo/binary, Details/binary, Identity:32, Reptype:32>>,
	<<141:16, Data/binary>>.
%%
encode_enum_shoping_item_c2s(Term)->
	Npcid=Term#enum_shoping_item_c2s.npcid,
	Data = <<Npcid:64>>,
	<<310:16, Data/binary>>.

%%
encode_answer_start_notice_s2c(Term)->
	Num=Term#answer_start_notice_s2c.num,
	Id=Term#answer_start_notice_s2c.id,
	Data = <<Num:32, Id:32>>,
	<<1125:16, Data/binary>>.

%%
encode_entry_loop_instance_vote_update_s2c(Term)->
	State=encode_votestate(Term#entry_loop_instance_vote_update_s2c.state),
	Data = <<State/binary>>,
	<<1802:16, Data/binary>>.

%%
encode_tangle_kill_info_request_c2s(Term)->
	Year=Term#tangle_kill_info_request_c2s.year,
	Month=Term#tangle_kill_info_request_c2s.month,
	Day=Term#tangle_kill_info_request_c2s.day,
	Battletype=Term#tangle_kill_info_request_c2s.battletype,
	Battleid=Term#tangle_kill_info_request_c2s.battleid,
	Data = <<Year:32, Month:32, Day:32, Battletype:32, Battleid:32>>,
	<<1751:16, Data/binary>>.

%%
encode_equipment_recast_s2c(Term)->
	Enchants=encode_list(Term#equipment_recast_s2c.enchants, fun encode_k/1),
	Data = <<Enchants/binary>>,
	<<620:16, Data/binary>>.

%%
encode_activity_forecast_end_s2c(Term)->
	Type=Term#activity_forecast_end_s2c.type,
	Data = <<Type:32>>,
	<<1231:16, Data/binary>>.

%%
encode_treasure_chest_raffle_ok_s2c(Term)->
	Slot=Term#treasure_chest_raffle_ok_s2c.slot,
	Data = <<Slot:32>>,
	<<985:16, Data/binary>>.

%%
encode_mail_operator_failed_s2c(Term)->
	Reason=Term#mail_operator_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<540:16, Data/binary>>.

%%
encode_update_item_for_pet_s2c(Term)->
	Petid=Term#update_item_for_pet_s2c.petid,
	Items=encode_list(Term#update_item_for_pet_s2c.items, fun encode_ic/1),
	Data = <<Petid:64, Items/binary>>,
	<<1510:16, Data/binary>>.

%%
encode_stop_sitdown_c2s(Term)->
	Data = <<>>,
	<<1251:16, Data/binary>>.

%%
encode_rank_get_rank_role_s2c(Term)->
	Roleid=Term#rank_get_rank_role_s2c.roleid,
	Rolename=encode_string(Term#rank_get_rank_role_s2c.rolename),
	Classtype=Term#rank_get_rank_role_s2c.classtype,
	Gender=Term#rank_get_rank_role_s2c.gender,
	Guildname=encode_string(Term#rank_get_rank_role_s2c.guildname),
	Level=Term#rank_get_rank_role_s2c.level,
	Cloth=Term#rank_get_rank_role_s2c.cloth,
	Arm=Term#rank_get_rank_role_s2c.arm,
	Vip_tag=Term#rank_get_rank_role_s2c.vip_tag,
	Items_attr=encode_list(Term#rank_get_rank_role_s2c.items_attr, fun encode_i/1),
	Be_disdain=Term#rank_get_rank_role_s2c.be_disdain,
	Be_praised=Term#rank_get_rank_role_s2c.be_praised,
	Left_judge=Term#rank_get_rank_role_s2c.left_judge,
	Data = <<Roleid:64, Rolename/binary, Classtype:32, Gender:32, Guildname/binary, Level:32, Cloth:32, Arm:32, Vip_tag:32, Items_attr/binary, Be_disdain:32, Be_praised:32, Left_judge:32>>,
	<<1439:16, Data/binary>>.

%%
encode_first_charge_gift_state_s2c(Term)->
	State=Term#first_charge_gift_state_s2c.state,
	Data = <<State:32>>,
	<<1416:16, Data/binary>>.

%%
encode_enum_shoping_item_fail_s2c(Term)->
	Reason=Term#enum_shoping_item_fail_s2c.reason,
	Data = <<Reason:32>>,
	<<311:16, Data/binary>>.

%%
encode_entry_loop_instance_vote_c2s(Term)->
	State=Term#entry_loop_instance_vote_c2s.state,
	Data = <<State:32>>,
	<<1803:16, Data/binary>>.

%%
encode_answer_question_c2s(Term)->
	Id=Term#answer_question_c2s.id,
	Answer=Term#answer_question_c2s.answer,
	Flag=Term#answer_question_c2s.flag,
	Data = <<Id:32, Answer:32, Flag:32>>,
	<<1126:16, Data/binary>>.

%%
encode_quest_details_c2s(Term)->
	Questid=Term#quest_details_c2s.questid,
	Data = <<Questid:32>>,
	<<94:16, Data/binary>>.

%%返回角色列表给玩家
encode_player_role_list_s2c(Term)->
	Roles=encode_list(Term#player_role_list_s2c.roles, fun encode_r/1),
	Data = <<Roles/binary>>,
	<<5:16, Data/binary>>.

%%
encode_activity_value_init_s2c(Term)->
	Avlist=encode_list(Term#activity_value_init_s2c.avlist, fun encode_av/1),
	Value=Term#activity_value_init_s2c.value,
	Status=Term#activity_value_init_s2c.status,
	Data = <<Avlist/binary, Value:32, Status:32>>,
	<<1401:16, Data/binary>>.

%%
encode_equipment_recast_confirm_c2s(Term)->
	Equipment=Term#equipment_recast_confirm_c2s.equipment,
	Data = <<Equipment:32>>,
	<<621:16, Data/binary>>.

%%
encode_ridepet_synthesis_error_s2c(Term)->
	Error=Term#ridepet_synthesis_error_s2c.error,
	Data = <<Error:32>>,
	<<1484:16, Data/binary>>.

%%
%%encode_achieve_update_s2c(Term)->
%%	Part=encode_ach(Term#achieve_update_s2c.part),
%%	Data = <<Part/binary>>,
%%	<<632:16, Data/binary>>.

%%
encode_companion_sitdown_apply_c2s(Term)->
	Roleid=Term#companion_sitdown_apply_c2s.roleid,
	Data = <<Roleid:64>>,
	<<1252:16, Data/binary>>.

%%
encode_guild_opt_result_s2c(Term)->
	Errno=Term#guild_opt_result_s2c.errno,
	Data = <<Errno:32>>,
	<<381:16, Data/binary>>.

%%
encode_get_guild_notice_c2s(Term)->
	Guildlid=Term#get_guild_notice_c2s.guildlid,
	Guildhid=Term#get_guild_notice_c2s.guildhid,
	Data = <<Guildlid:32, Guildhid:32>>,
	<<1213:16, Data/binary>>.

%%
encode_treasure_transport_time_s2c(Term)->
	Left_time=Term#treasure_transport_time_s2c.left_time,
	Data = <<Left_time:32>>,
	<<1550:16, Data/binary>>.

%%
encode_update_item_s2c(Term)->
	Items=encode_list(Term#update_item_s2c.items, fun encode_ic/1),
	Data = <<Items/binary>>,
	<<120:16, Data/binary>>.

%%
encode_refine_system_c2s(Term)->
	Serial_number=Term#refine_system_c2s.serial_number,
	Times=Term#refine_system_c2s.times,
	Data = <<Serial_number:32, Times:32>>,
	<<1520:16, Data/binary>>.

%%
encode_first_charge_gift_reward_c2s(Term)->
	Data = <<>>,
	<<1417:16, Data/binary>>.

%%
encode_equipment_convert_c2s(Term)->
	Equipment=Term#equipment_convert_c2s.equipment,
	Convert=Term#equipment_convert_c2s.convert,
	Type=Term#equipment_convert_c2s.type,
	Data = <<Equipment:32, Convert:32, Type:32>>,
	<<622:16, Data/binary>>.

%%
encode_chess_spirit_get_reward_c2s(Term)->
	Type=Term#chess_spirit_get_reward_c2s.type,
	Data = <<Type:32>>,
	<<1181:16, Data/binary>>.

%%
encode_system_broadcast_s2c(Term)->
	Id=Term#system_broadcast_s2c.id,
	Param=encode_list(Term#system_broadcast_s2c.param, fun encode_rkv/1),
	Data = <<Id:32, Param/binary>>,
	<<1235:16, Data/binary>>.

%%
encode_quest_details_s2c(Term)->
	Npcid=Term#quest_details_s2c.npcid,
	Questid=Term#quest_details_s2c.questid,
	Queststate=Term#quest_details_s2c.queststate,
	Data = <<Npcid:64, Questid:32, Queststate:32>>,
	<<95:16, Data/binary>>.

%%
encode_fatigue_alert_s2c(Term)->
	Alter=encode_string(Term#fatigue_alert_s2c.alter),
	Data = <<Alter/binary>>,
	<<351:16, Data/binary>>.

%%
encode_guild_base_update_s2c(Term)->
	Guildname=encode_string(Term#guild_base_update_s2c.guildname),
	Level=Term#guild_base_update_s2c.level,
	Silver=Term#guild_base_update_s2c.silver,
	Gold=Term#guild_base_update_s2c.gold,
	Notice=encode_string(Term#guild_base_update_s2c.notice),
	Chatgroup=encode_string(Term#guild_base_update_s2c.chatgroup),
	Voicegroup=encode_string(Term#guild_base_update_s2c.voicegroup),
	Data = <<Guildname/binary, Level:32, Silver:32, Gold:32, Notice/binary, Chatgroup/binary, Voicegroup/binary>>,
	<<382:16, Data/binary>>.

%%
encode_treasure_chest_obtain_c2s(Term)->
	Data = <<>>,
	<<986:16, Data/binary>>.

%%
encode_welfare_gifepacks_state_update_s2c(Term)->
	Typenumber=Term#welfare_gifepacks_state_update_s2c.typenumber,
	Time_state=Term#welfare_gifepacks_state_update_s2c.time_state,
	Complete_state=Term#welfare_gifepacks_state_update_s2c.complete_state,
	Data = <<Typenumber:32, Time_state:32, Complete_state:32>>,
	<<1462:16, Data/binary>>.

%%
%encode_achieve_reward_c2s(Term)->
%	Chapter=Term#achieve_reward_c2s.chapter,
%	Part=encode_ach(Term#achieve_reward_c2s.part),
%	Data = <<Chapter:32, Part/binary>>,
%	<<633:16, Data/binary>>.

encode_achieve_reward_c2s(Term)->
	Id=Term#achieve_reward_c2s.id,
	Data = <<Id:32>>,
	<<633:16, Data/binary>>.

%%
encode_init_onhands_item_s2c(Term)->
	Item_attrs=encode_list(Term#init_onhands_item_s2c.item_attrs, fun encode_i/1),
	Data = <<Item_attrs/binary>>,
	<<127:16, Data/binary>>.

%%
encode_first_charge_gift_reward_opt_s2c(Term)->
	Code=Term#first_charge_gift_reward_opt_s2c.code,
	Data = <<Code:32>>,
	<<1418:16, Data/binary>>.

%%
encode_chat_failed_s2c(Term)->
	Reasonid=Term#chat_failed_s2c.reasonid,
	Cdtime=Term#chat_failed_s2c.cdtime,
	Data = <<Reasonid:32, Cdtime:32>>,
	<<142:16, Data/binary>>.

%%
encode_moneygame_result_s2c(Term)->
	Result=Term#moneygame_result_s2c.result,
	Use_time=Term#moneygame_result_s2c.use_time,
	Section=Term#moneygame_result_s2c.section,
	Data = <<Result:32, Use_time:32, Section:32>>,
	<<1241:16, Data/binary>>.

%%
encode_treasure_chest_disable_c2s(Term)->
	Slots=encode_int32_list(Term#treasure_chest_disable_c2s.slots),
	Data = <<Slots/binary>>,
	<<992:16, Data/binary>>.

%%
encode_beads_pray_request_c2s(Term)->
	Type=Term#beads_pray_request_c2s.type,
	Times=Term#beads_pray_request_c2s.times,
	Consume_type=Term#beads_pray_request_c2s.consume_type,
	Data = <<Type:32, Times:32, Consume_type:32>>,
	<<995:16, Data/binary>>.

%%
encode_chess_spirit_log_c2s(Term)->
	Type=Term#chess_spirit_log_c2s.type,
	Data = <<Type:32>>,
	<<1179:16, Data/binary>>.

%%
encode_tangle_kill_info_request_s2c(Term)->
	Year=Term#tangle_kill_info_request_s2c.year,
	Month=Term#tangle_kill_info_request_s2c.month,
	Day=Term#tangle_kill_info_request_s2c.day,
	Battletype=Term#tangle_kill_info_request_s2c.battletype,
	Battleid=Term#tangle_kill_info_request_s2c.battleid,
	Killinfo=encode_list(Term#tangle_kill_info_request_s2c.killinfo, fun encode_ki/1),
	Bekillinfo=encode_list(Term#tangle_kill_info_request_s2c.bekillinfo, fun encode_ki/1),
	Data = <<Year:32, Month:32, Day:32, Battletype:32, Battleid:32, Killinfo/binary, Bekillinfo/binary>>,
	<<1752:16, Data/binary>>.

%%
encode_enum_shoping_item_s2c(Term)->
	Npcid=Term#enum_shoping_item_s2c.npcid,
	Sps=encode_list(Term#enum_shoping_item_s2c.sps, fun encode_sp/1),
	Data = <<Npcid:64, Sps/binary>>,
	<<312:16, Data/binary>>.

%%
encode_guild_get_shop_item_c2s(Term)->
	Shoptype=Term#guild_get_shop_item_c2s.shoptype,
	Data = <<Shoptype:32>>,
	<<1200:16, Data/binary>>.

%%
encode_answer_question_s2c(Term)->
	Id=Term#answer_question_s2c.id,
	Score=Term#answer_question_s2c.score,
	Rank=Term#answer_question_s2c.rank,
	Continu=Term#answer_question_s2c.continu,
	Data = <<Id:32, Score:32, Rank:32, Continu:32>>,
	<<1127:16, Data/binary>>.

%%
encode_activity_value_update_s2c(Term)->
	Avlist=encode_list(Term#activity_value_update_s2c.avlist, fun encode_av/1),
	Value=Term#activity_value_update_s2c.value,
	Status=Term#activity_value_update_s2c.status,
	Data = <<Avlist/binary, Value:32, Status:32>>,
	<<1402:16, Data/binary>>.

%%
encode_chess_spirit_update_chess_power_s2c(Term)->
	Newpower=Term#chess_spirit_update_chess_power_s2c.newpower,
	Data = <<Newpower:32>>,
	<<1174:16, Data/binary>>.

%%
encode_equipment_convert_s2c(Term)->
	Enchants=encode_list(Term#equipment_convert_s2c.enchants, fun encode_k/1),
	Data = <<Enchants/binary>>,
	<<623:16, Data/binary>>.

%%
encode_add_item_s2c(Term)->
	Item_attr=encode_i(Term#add_item_s2c.item_attr),
	Data = <<Item_attr/binary>>,
	<<121:16, Data/binary>>.

%%
encode_achieve_error_s2c(Term)->
	Reason=Term#achieve_error_s2c.reason,
	Data = <<Reason:32>>,
	<<634:16, Data/binary>>.

%%
encode_tangle_update_s2c(Term)->
	Trs=encode_list(Term#tangle_update_s2c.trs, fun encode_tr/1),
	Data = <<Trs/binary>>,
	<<824:16, Data/binary>>.

%%
encode_treasure_chest_obtain_ok_s2c(Term)->
	Data = <<>>,
	<<987:16, Data/binary>>.

%%查询分线服务器
encode_role_line_query_c2s(Term)->
	Mapid=Term#role_line_query_c2s.mapid,
	Data = <<Mapid:32>>,
	<<6:16, Data/binary>>.

%%
encode_loudspeaker_queue_num_c2s(Term)->
	Data = <<>>,
	<<143:16, Data/binary>>.

%%
encode_chess_spirit_opt_result_s2s(Term)->
	Errno=Term#chess_spirit_opt_result_s2s.errno,
	Data = <<Errno:32>>,
	<<1178:16, Data/binary>>.

%%
encode_pet_random_talent_c2s(Term)->
	Petid=Term#pet_random_talent_c2s.petid,
	Type=Term#pet_random_talent_c2s.type,
	Data = <<Petid:64, Type:32>>,
	<<1485:16, Data/binary>>.

%%
encode_country_leader_demotion_c2s(Term)->
	Post=Term#country_leader_demotion_c2s.post,
	Postindex=Term#country_leader_demotion_c2s.postindex,
	Data = <<Post:32, Postindex:32>>,
	<<1646:16, Data/binary>>.

%%
encode_inspect_pet_s2c(Term)->
	Rolename=encode_string(Term#inspect_pet_s2c.rolename),
	Petattr=encode_p(Term#inspect_pet_s2c.petattr),
	Skillinfo=encode_list(Term#inspect_pet_s2c.skillinfo, fun encode_psk/1),
	Slot=encode_list(Term#inspect_pet_s2c.slot, fun encode_psll/1),
	Data = <<Rolename/binary, Petattr/binary, Skillinfo/binary, Slot/binary>>,
	<<923:16, Data/binary>>.

%%
encode_buy_item_c2s(Term)->
	Npcid=Term#buy_item_c2s.npcid,
	Item_clsid=Term#buy_item_c2s.item_clsid,
	Count=Term#buy_item_c2s.count,
	Data = <<Npcid:64, Item_clsid:32, Count:32>>,
	<<313:16, Data/binary>>.

%%
encode_treasure_transport_failed_s2c(Term)->
	Reward=Term#treasure_transport_failed_s2c.reward,
	Data = <<Reward:32>>,
	<<1551:16, Data/binary>>.

%%
encode_add_item_failed_s2c(Term)->
	Errno=Term#add_item_failed_s2c.errno,
	Data = <<Errno:32>>,
	<<122:16, Data/binary>>.

%%
encode_loudspeaker_queue_num_s2c(Term)->
	Num=Term#loudspeaker_queue_num_s2c.num,
	Data = <<Num:32>>,
	<<144:16, Data/binary>>.

%%
encode_equipment_move_c2s(Term)->
	Fromslot=Term#equipment_move_c2s.fromslot,
	Toslot=Term#equipment_move_c2s.toslot,
	Data = <<Fromslot:32, Toslot:32>>,
	<<624:16, Data/binary>>.

%%
encode_server_version_c2s(Term)->
	Data = <<>>,
	<<1630:16, Data/binary>>.

%%
encode_activity_value_reward_c2s(Term)->
	Itemid=Term#activity_value_reward_c2s.itemid,
	Data = <<Itemid:32>>,
	<<1403:16, Data/binary>>.

%%
encode_send_guild_notice_s2c(Term)->
	Guildlid=Term#send_guild_notice_s2c.guildlid,
	Guildhid=Term#send_guild_notice_s2c.guildhid,
	Notice=encode_string(Term#send_guild_notice_s2c.notice),
	Data = <<Guildlid:32, Guildhid:32, Notice/binary>>,
	<<1214:16, Data/binary>>.

%%
encode_rob_treasure_transport_s2c(Term)->
	Othername=encode_string(Term#rob_treasure_transport_s2c.othername),
	Rewardmoney=Term#rob_treasure_transport_s2c.rewardmoney,
	Data = <<Othername/binary, Rewardmoney:32>>,
	<<1553:16, Data/binary>>.

%%
encode_refine_system_s2c(Term)->
	Result=Term#refine_system_s2c.result,
	Data = <<Result:32>>,
	<<1521:16, Data/binary>>.

%%
encode_country_leader_update_s2c(Term)->
	Leader=encode_cl(Term#country_leader_update_s2c.leader),
	Data = <<Leader/binary>>,
	<<1647:16, Data/binary>>.

%%
encode_venation_init_s2c(Term)->
	Venation=encode_list(Term#venation_init_s2c.venation, fun encode_vp/1),
	Venationbone=encode_list(Term#venation_init_s2c.venationbone, fun encode_vb/1),
	Attr=encode_list(Term#venation_init_s2c.attr, fun encode_k/1),
	Remaintime=Term#venation_init_s2c.remaintime,
	Totalexp=Term#venation_init_s2c.totalexp,
	Data = <<Venation/binary, Venationbone/binary, Attr/binary, Remaintime:32, Totalexp:64>>,
	<<1280:16, Data/binary>>.

%%
encode_pet_training_info_s2c(Term)->
	Petid=Term#pet_training_info_s2c.petid,
	Totaltime=Term#pet_training_info_s2c.totaltime,
	Remaintime=Term#pet_training_info_s2c.remaintime,
	Data = <<Petid:64, Totaltime:32, Remaintime:32>>,
	<<950:16, Data/binary>>.

%%
encode_guild_member_update_s2c(Term)->
	Roleinfo=encode_g(Term#guild_member_update_s2c.roleinfo),
	Data = <<Roleinfo/binary>>,
	<<383:16, Data/binary>>.

%%
encode_moneygame_left_time_s2c(Term)->
	Left_seconds=Term#moneygame_left_time_s2c.left_seconds,
	Data = <<Left_seconds:32>>,
	<<1240:16, Data/binary>>.

%%
encode_answer_question_ranklist_s2c(Term)->
	Ranklist=encode_list(Term#answer_question_ranklist_s2c.ranklist, fun encode_aqrl/1),
	Data = <<Ranklist/binary>>,
	<<1128:16, Data/binary>>.

%%
encode_activity_value_opt_s2c(Term)->
	Code=Term#activity_value_opt_s2c.code,
	Data = <<Code:32>>,
	<<1404:16, Data/binary>>.

%%
encode_rank_judge_to_other_s2c(Term)->
	Type=Term#rank_judge_to_other_s2c.type,
	Othername=encode_string(Term#rank_judge_to_other_s2c.othername),
	Data = <<Type:32, Othername/binary>>,
	<<1450:16, Data/binary>>.

%%
encode_equipment_move_s2c(Term)->
	Data = <<>>,
	<<625:16, Data/binary>>.

%%
encode_destroy_item_c2s(Term)->
	Slot=Term#destroy_item_c2s.slot,
	Data = <<Slot:32>>,
	<<123:16, Data/binary>>.

%%
encode_companion_sitdown_apply_s2c(Term)->
	Roleid=Term#companion_sitdown_apply_s2c.roleid,
	Data = <<Roleid:64>>,
	<<1253:16, Data/binary>>.

%%
encode_qz_get_balance_c2s(Term)->
	Data = <<>>,
	<<1875:16, Data/binary>>.

%%
encode_sell_item_c2s(Term)->
	Npcid=Term#sell_item_c2s.npcid,
	Slot=Term#sell_item_c2s.slot,
	Data = <<Npcid:64, Slot:32>>,
	<<315:16, Data/binary>>.

%%成功查询分线服务器
encode_role_line_query_ok_s2c(Term)->
	Lines=encode_list(Term#role_line_query_ok_s2c.lines, fun encode_li/1),
	Data = <<Lines/binary>>,
	<<7:16, Data/binary>>.

%%
encode_start_guild_transport_failed_s2c(Term)->
	Reason=Term#start_guild_transport_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<1552:16, Data/binary>>.

%%
encode_festival_error_s2c(Term)->
	Error=Term#festival_error_s2c.error,
	Data = <<Error:32>>,
	<<1693:16, Data/binary>>.

%%
encode_guild_facilities_update_s2c(Term)->
	Facinfo=encode_f(Term#guild_facilities_update_s2c.facinfo),
	Data = <<Facinfo/binary>>,
	<<384:16, Data/binary>>.

%%
encode_country_init_s2c(Term)->
	Leaders=encode_list(Term#country_init_s2c.leaders, fun encode_cl/1),
	Notice=encode_string(Term#country_init_s2c.notice),
	Tp_start=Term#country_init_s2c.tp_start,
	Tp_stop=Term#country_init_s2c.tp_stop,
	Bestguildlid=Term#country_init_s2c.bestguildlid,
	Bestguildhid=Term#country_init_s2c.bestguildhid,
	Bestguildname=encode_string(Term#country_init_s2c.bestguildname),
	Data = <<Leaders/binary, Notice/binary, Tp_start:32, Tp_stop:32, Bestguildlid:32, Bestguildhid:32, Bestguildname/binary>>,
	<<1640:16, Data/binary>>.

%%
encode_equipment_remove_seal_s2c(Term)->
	Data = <<>>,
	<<626:16, Data/binary>>.

%%
encode_levelup_opt_c2s(Term)->
	Level=Term#levelup_opt_c2s.level,
	Data = <<Level:32>>,
	<<1221:16, Data/binary>>.

%%
encode_answer_end_s2c(Term)->
	Exp=Term#answer_end_s2c.exp,
	Data = <<Exp:32>>,
	<<1129:16, Data/binary>>.

%%
encode_delete_item_s2c(Term)->
	Itemid_low=Term#delete_item_s2c.itemid_low,
	Itemid_high=Term#delete_item_s2c.itemid_high,
	Reason=Term#delete_item_s2c.reason,
	Data = <<Itemid_low:32, Itemid_high:32, Reason:32>>,
	<<124:16, Data/binary>>.

%%
encode_treasure_chest_query_s2c(Term)->
	Items=encode_list(Term#treasure_chest_query_s2c.items, fun encode_lti/1),
	Slots=encode_int32_list(Term#treasure_chest_query_s2c.slots),
	Data = <<Items/binary, Slots/binary>>,
	<<990:16, Data/binary>>.

%%
encode_treasure_chest_query_c2s(Term)->
	Data = <<>>,
	<<989:16, Data/binary>>.

%%
encode_get_guild_monster_info_c2s(Term)->
	Data = <<>>,
	<<1764:16, Data/binary>>.

%%
encode_loop_instance_opt_s2c(Term)->
	Code=Term#loop_instance_opt_s2c.code,
	Data = <<Code:32>>,
	<<1812:16, Data/binary>>.

%%选定某个角色
encode_player_select_role_c2s(Term)->
	Roleid=Term#player_select_role_c2s.roleid,
	Lineid=Term#player_select_role_c2s.lineid,
	Data = <<Roleid:64, Lineid:32>>,
	<<10:16, Data/binary>>.

%%
encode_country_leader_promotion_c2s(Term)->
	Post=Term#country_leader_promotion_c2s.post,
	Postindex=Term#country_leader_promotion_c2s.postindex,
	Name=encode_string(Term#country_leader_promotion_c2s.name),
	Data = <<Post:32, Postindex:32, Name/binary>>,
	<<1645:16, Data/binary>>.

%%
encode_rank_get_rank_role_c2s(Term)->
	Roleid=Term#rank_get_rank_role_c2s.roleid,
	Data = <<Roleid:64>>,
	<<1429:16, Data/binary>>.

%%
encode_identify_verify_c2s(Term)->
	Truename=encode_string(Term#identify_verify_c2s.truename),
	Card=encode_string(Term#identify_verify_c2s.card),
	Data = <<Truename/binary, Card/binary>>,
	<<800:16, Data/binary>>.

%%
encode_battle_other_join_s2c(Term)->
	Commer=encode_tr(Term#battle_other_join_s2c.commer),
	Data = <<Commer/binary>>,
	<<828:16, Data/binary>>.

%%
encode_beads_pray_response_s2c(Term)->
	Type=Term#beads_pray_response_s2c.type,
	Times=Term#beads_pray_response_s2c.times,
	Itemslist=encode_list(Term#beads_pray_response_s2c.itemslist, fun encode_lti/1),
	Data = <<Type:32, Times:32, Itemslist/binary>>,
	<<996:16, Data/binary>>.

%%
encode_welfare_activity_update_c2s(Term)->
	Typenumber=Term#welfare_activity_update_c2s.typenumber,
	Serial_number=encode_string(Term#welfare_activity_update_c2s.serial_number),
	Data = <<Typenumber:32, Serial_number/binary>>,
	<<1530:16, Data/binary>>.

%%
encode_inspect_c2s(Term)->
	Serverid=Term#inspect_c2s.serverid,
	Rolename=encode_string(Term#inspect_c2s.rolename),
	Data = <<Serverid:32, Rolename/binary>>,
	<<403:16, Data/binary>>.

%%
encode_add_levelup_opt_levels_s2c(Term)->
	Levels=encode_int32_list(Term#add_levelup_opt_levels_s2c.levels),
	Data = <<Levels/binary>>,
	<<1220:16, Data/binary>>.

%%
encode_goals_update_s2c(Term)->
	Part=encode_ach(Term#goals_update_s2c.part),
	Data = <<Part/binary>>,
	<<641:16, Data/binary>>.

%%
encode_guild_member_delete_s2c(Term)->
	Roleid=Term#guild_member_delete_s2c.roleid,
	Reason=Term#guild_member_delete_s2c.reason,
	Data = <<Roleid:64, Reason:32>>,
	<<385:16, Data/binary>>.

%%
encode_country_block_talk_c2s(Term)->
	Name=encode_string(Term#country_block_talk_c2s.name),
	Data = <<Name/binary>>,
	<<1648:16, Data/binary>>.

%%equipment_remove_seal_c2s
encode_equipment_remove_seal_c2s(Term)->
	Equipment=Term#equipment_remove_seal_c2s.equipment,
	Data = <<Equipment:32>>,
	<<627:16, Data/binary>>.

%%
encode_guild_transport_left_time_s2c(Term)->
	Left_time=Term#guild_transport_left_time_s2c.left_time,
	Data = <<Left_time:32>>,
	<<1557:16, Data/binary>>.

%%
encode_repair_item_c2s(Term)->
	Npcid=Term#repair_item_c2s.npcid,
	Slot=Term#repair_item_c2s.slot,
	Data = <<Npcid:64, Slot:32>>,
	<<317:16, Data/binary>>.

%%
encode_answer_error_s2c(Term)->
	Reason=Term#answer_error_s2c.reason,
	Data = <<Reason:32>>,
	<<1130:16, Data/binary>>.

%%
encode_pet_change_talent_c2s(Term)->
	Petid=Term#pet_change_talent_c2s.petid,
	Data = <<Petid:64>>,
	<<1486:16, Data/binary>>.

%%
encode_other_venation_info_s2c(Term)->
	Roleid=Term#other_venation_info_s2c.roleid,
	Venation=encode_list(Term#other_venation_info_s2c.venation, fun encode_vp/1),
	Attr=encode_list(Term#other_venation_info_s2c.attr, fun encode_k/1),
	Remaintime=Term#other_venation_info_s2c.remaintime,
	Totalexp=Term#other_venation_info_s2c.totalexp,
	Venationbone=encode_list(Term#other_venation_info_s2c.venationbone, fun encode_vb/1),
	Data = <<Roleid:64, Venation/binary, Attr/binary, Remaintime:32, Totalexp:64, Venationbone/binary>>,
	<<1288:16, Data/binary>>.

%%
encode_chess_spirit_update_skill_s2c(Term)->
	Update_skills=encode_list(Term#chess_spirit_update_skill_s2c.update_skills, fun encode_s/1),
	Data = <<Update_skills/binary>>,
	<<1173:16, Data/binary>>.

%%
encode_festival_recharge_exchange_c2s(Term)->
	Id=Term#festival_recharge_exchange_c2s.id,
	Data = <<Id:32>>,
	<<1694:16, Data/binary>>.

%%
encode_rank_get_rank_c2s(Term)->
	Type=Term#rank_get_rank_c2s.type,
	Data = <<Type:32>>,
	<<1428:16, Data/binary>>.

%%
encode_role_attribute_s2c(Term)->
	Roleid=Term#role_attribute_s2c.roleid,
	Attrs=encode_list(Term#role_attribute_s2c.attrs, fun encode_k/1),
	Data = <<Roleid:64, Attrs/binary>>,
	<<53:16, Data/binary>>.

%%
encode_battle_join_c2s(Term)->
	Type=Term#battle_join_c2s.type,
	Data = <<Type:32>>,
	<<821:16, Data/binary>>.

%%
encode_identify_verify_s2c(Term)->
	Code=Term#identify_verify_s2c.code,
	Data = <<Code:32>>,
	<<801:16, Data/binary>>.

%%
encode_chess_spirit_info_s2c(Term)->
	Cur_section=Term#chess_spirit_info_s2c.cur_section,
	Used_time_s=Term#chess_spirit_info_s2c.used_time_s,
	Next_sec_time_s=Term#chess_spirit_info_s2c.next_sec_time_s,
	Spiritmaxhp=Term#chess_spirit_info_s2c.spiritmaxhp,
	Spiritcurhp=Term#chess_spirit_info_s2c.spiritcurhp,
	Data = <<Cur_section:32, Used_time_s:32, Next_sec_time_s:32, Spiritmaxhp:32, Spiritcurhp:32>>,
	<<1170:16, Data/binary>>.

%%
encode_start_guild_treasure_transport_c2s(Term)->
	Data = <<>>,
	<<1558:16, Data/binary>>.

%%
encode_stall_role_detail_c2s(Term)->
	Rolename=encode_string(Term#stall_role_detail_c2s.rolename),
	Data = <<Rolename/binary>>,
	<<1044:16, Data/binary>>.

%%
encode_festival_recharge_update_s2c(Term)->
	Id=Term#festival_recharge_update_s2c.id,
	State=Term#festival_recharge_update_s2c.state,
	Today_charge_num=Term#festival_recharge_update_s2c.today_charge_num,
	Data = <<Id:32, State:32, Today_charge_num:32>>,
	<<1695:16, Data/binary>>.

%%换线
encode_role_change_line_c2s(Term)->
	Lineid=Term#role_change_line_c2s.lineid,
	Data = <<Lineid:32>>,
	<<9:16, Data/binary>>.

%%
encode_split_item_c2s(Term)->
	Slot=Term#split_item_c2s.slot,
	Split_num=Term#split_item_c2s.split_num,
	Data = <<Slot:32, Split_num:32>>,
	<<125:16, Data/binary>>.

%%
encode_group_member_stats_s2c(Term)->
	State=encode_t(Term#group_member_stats_s2c.state),
	Data = <<State/binary>>,
	<<165:16, Data/binary>>.

%%
encode_buy_item_fail_s2c(Term)->
	Reason=Term#buy_item_fail_s2c.reason,
	Data = <<Reason:32>>,
	<<314:16, Data/binary>>.

%%
encode_guild_member_add_s2c(Term)->
	Roleinfo=encode_g(Term#guild_member_add_s2c.roleinfo),
	Data = <<Roleinfo/binary>>,
	<<386:16, Data/binary>>.

%%
encode_congratulations_levelup_remind_s2c(Term)->
	Roleid=Term#congratulations_levelup_remind_s2c.roleid,
	Rolename=encode_string(Term#congratulations_levelup_remind_s2c.rolename),
	Level=Term#congratulations_levelup_remind_s2c.level,
	Data = <<Roleid:64, Rolename/binary, Level:32>>,
	<<1140:16, Data/binary>>.

%%
encode_rank_get_main_line_rank_c2s(Term)->
	Type=Term#rank_get_main_line_rank_c2s.type,
	Chapter=Term#rank_get_main_line_rank_c2s.chapter,
	Festival=Term#rank_get_main_line_rank_c2s.festival,
	Difficulty=Term#rank_get_main_line_rank_c2s.difficulty,
	Data = <<Type:32, Chapter:32, Festival:32, Difficulty:32>>,
	<<1453:16, Data/binary>>.

%%
encode_treasure_transport_call_guild_help_c2s(Term)->
	Data = <<>>,
	<<1621:16, Data/binary>>.

%%
encode_activity_state_init_c2s(Term)->
	Data = <<>>,
	<<1410:16, Data/binary>>.

%%
encode_questgiver_states_update_s2c(Term)->
	Npcid=encode_int64_list(Term#questgiver_states_update_s2c.npcid),
	Queststate=encode_int32_list(Term#questgiver_states_update_s2c.queststate),
	Data = <<Npcid/binary, Queststate/binary>>,
	<<93:16, Data/binary>>.

%%
encode_stall_sell_item_c2s(Term)->
	Slot=Term#stall_sell_item_c2s.slot,
	Silver=Term#stall_sell_item_c2s.silver,
	Gold=Term#stall_sell_item_c2s.gold,
	Ticket=Term#stall_sell_item_c2s.ticket,
	Data = <<Slot:32, Silver:32, Gold:32, Ticket:32>>,
	<<1030:16, Data/binary>>.

%%
encode_entry_loop_instance_s2c(Term)->
	Layer=Term#entry_loop_instance_s2c.layer,
	Result=Term#entry_loop_instance_s2c.result,
	Lefttime=Term#entry_loop_instance_s2c.lefttime,
	Besttime=Term#entry_loop_instance_s2c.besttime,
	Type=Term#entry_loop_instance_s2c.type,
	Data = <<Layer:32, Result:32, Lefttime:32, Besttime:32, Type:32>>,
	<<1805:16, Data/binary>>.

%%
encode_mail_sucess_s2c(Term)->
	Data = <<>>,
	<<541:16, Data/binary>>.

%%
encode_ridepet_synthesis_opt_result_s2c(Term)->
	Pettmpid=Term#ridepet_synthesis_opt_result_s2c.pettmpid,
	Resultattr=encode_list(Term#ridepet_synthesis_opt_result_s2c.resultattr, fun encode_k/1),
	Data = <<Pettmpid:32, Resultattr/binary>>,
	<<1483:16, Data/binary>>.

%%
encode_pet_start_training_c2s(Term)->
	Petid=Term#pet_start_training_c2s.petid,
	Totaltime=Term#pet_start_training_c2s.totaltime,
	Type=Term#pet_start_training_c2s.type,
	Data = <<Petid:64, Totaltime:32, Type:32>>,
	<<951:16, Data/binary>>.

%%
encode_treasure_transport_call_guild_help_s2c(Term)->
	Data = <<>>,
	<<1559:16, Data/binary>>.

%%
encode_npc_attribute_s2c(Term)->
	Npcid=Term#npc_attribute_s2c.npcid,
	Attrs=encode_list(Term#npc_attribute_s2c.attrs, fun encode_k/1),
	Data = <<Npcid:64, Attrs/binary>>,
	<<54:16, Data/binary>>.

%%
encode_finish_register_s2c(Term)->
	Gourl=encode_string(Term#finish_register_s2c.gourl),
	Data = <<Gourl/binary>>,
	<<352:16, Data/binary>>.

%%
encode_activity_state_init_s2c(Term)->
	Aslist=encode_list(Term#activity_state_init_s2c.aslist, fun encode_acs/1),
	Data = <<Aslist/binary>>,
	<<1411:16, Data/binary>>.

%%
encode_pet_explore_speedup_c2s(Term)->
	Petid=Term#pet_explore_speedup_c2s.petid,
	Data = <<Petid:64>>,
	<<973:16, Data/binary>>.

%%
encode_qz_get_balance_error_s2c(Term)->
	Error=Term#qz_get_balance_error_s2c.error,
	Data = <<Error:32>>,
	<<1877:16, Data/binary>>.

%%
encode_delete_friend_failed_s2c(Term)->
	Reason=Term#delete_friend_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<488:16, Data/binary>>.

%%
encode_pet_upgrade_quality_up_c2s(Term)->
	Type=Term#pet_upgrade_quality_up_c2s.type,
	Petid=Term#pet_upgrade_quality_up_c2s.petid,
	Needs=Term#pet_upgrade_quality_up_c2s.needs,
	Data = <<Type:32, Petid:64, Needs:32>>,
	<<1501:16, Data/binary>>.

%%
encode_congratulations_error_s2c(Term)->
	Reason=Term#congratulations_error_s2c.reason,
	Data = <<Reason:32>>,
	<<1144:16, Data/binary>>.

%%
encode_loop_tower_challenge_again_c2s(Term)->
	Type=Term#loop_tower_challenge_again_c2s.type,
	Again=Term#loop_tower_challenge_again_c2s.again,
	Data = <<Type:32, Again:32>>,
	<<658:16, Data/binary>>.

%%
encode_leave_loop_instance_c2s(Term)->
	Data = <<>>,
	<<1806:16, Data/binary>>.

%%
encode_continuous_logging_gift_c2s(Term)->
	Type=Term#continuous_logging_gift_c2s.type,
	Nowawardday=Term#continuous_logging_gift_c2s.nowawardday,
	Data = <<Type:32, Nowawardday:32>>,
	<<1300:16, Data/binary>>.

%%
encode_start_everquest_s2c(Term)->
	Everqid=Term#start_everquest_s2c.everqid,
	Questid=Term#start_everquest_s2c.questid,
	Free_fresh_times=Term#start_everquest_s2c.free_fresh_times,
	Round=Term#start_everquest_s2c.round,
	Section=Term#start_everquest_s2c.section,
	Quality=Term#start_everquest_s2c.quality,
	Npcid=Term#start_everquest_s2c.npcid,
	Resettime=Term#start_everquest_s2c.resettime,
	Data = <<Everqid:32, Questid:32, Free_fresh_times:32, Round:32, Section:32, Quality:32, Npcid:64, Resettime:32>>,
	<<850:16, Data/binary>>.

%%
encode_mainline_protect_npc_info_s2c(Term)->
	Npcprotoid=Term#mainline_protect_npc_info_s2c.npcprotoid,
	Maxhp=Term#mainline_protect_npc_info_s2c.maxhp,
	Curhp=Term#mainline_protect_npc_info_s2c.curhp,
	Data = <<Npcprotoid:32, Maxhp:32, Curhp:32>>,
	<<1576:16, Data/binary>>.


%%
encode_leave_loop_instance_s2c(Term)->
	Layer=Term#leave_loop_instance_s2c.layer,
	Result=Term#leave_loop_instance_s2c.result,
	Data = <<Layer:32, Result:32>>,
	<<1807:16, Data/binary>>.

%%
encode_rank_judge_opt_result_s2c(Term)->
	Roleid=Term#rank_judge_opt_result_s2c.roleid,
	Disdainnum=Term#rank_judge_opt_result_s2c.disdainnum,
	Praisednum=Term#rank_judge_opt_result_s2c.praisednum,
	Leftnum=Term#rank_judge_opt_result_s2c.leftnum,
	Data = <<Roleid:32, Disdainnum:32, Praisednum:32, Leftnum:32>>,
	<<1442:16, Data/binary>>.

%%
encode_companion_sitdown_start_c2s(Term)->
	Roleid=Term#companion_sitdown_start_c2s.roleid,
	Data = <<Roleid:64>>,
	<<1254:16, Data/binary>>.

%%
encode_pet_explore_stop_c2s(Term)->
	Petid=Term#pet_explore_stop_c2s.petid,
	Data = <<Petid:64>>,
	<<974:16, Data/binary>>.

%%
encode_companion_sitdown_result_s2c(Term)->
	Result=Term#companion_sitdown_result_s2c.result,
	Data = <<Result:32>>,
	<<1255:16, Data/binary>>.

%%
encode_stall_recede_item_c2s(Term)->
	Itemlid=Term#stall_recede_item_c2s.itemlid,
	Itemhid=Term#stall_recede_item_c2s.itemhid,
	Data = <<Itemlid:32, Itemhid:32>>,
	<<1031:16, Data/binary>>.

%%
encode_guild_impeach_c2s(Term)->
	Notice=encode_string(Term#guild_impeach_c2s.notice),
	Data = <<Notice/binary>>,
	<<1722:16, Data/binary>>.

%%
encode_continuous_logging_board_c2s(Term)->
	Data = <<>>,
	<<1301:16, Data/binary>>.

%%
encode_guild_contribute_log_s2c(Term)->
	Roles=encode_list(Term#guild_contribute_log_s2c.roles, fun encode_rcs/1),
	Data = <<Roles/binary>>,
	<<1721:16, Data/binary>>.

%%
encode_user_auth_c2s(Term)->
	Username=encode_string(Term#user_auth_c2s.username),
	Userid=encode_string(Term#user_auth_c2s.userid),
	Time=encode_string(Term#user_auth_c2s.time),
	Cm=encode_string(Term#user_auth_c2s.cm),
	Flag=encode_string(Term#user_auth_c2s.flag),
	Userip=encode_string(Term#user_auth_c2s.userip),
	Type=encode_string(Term#user_auth_c2s.type),
	Sid=encode_string(Term#user_auth_c2s.sid),
	Serverid=Term#user_auth_c2s.serverid,
	Openid=encode_string(Term#user_auth_c2s.openid),
	Openkey=encode_string(Term#user_auth_c2s.openkey),
	Appid=encode_string(Term#user_auth_c2s.appid),
	Pf=encode_string(Term#user_auth_c2s.pf),
	Pfkey=encode_string(Term#user_auth_c2s.pfkey),
	Data = <<Username/binary, Userid/binary, Time/binary, Cm/binary, Flag/binary, Userip/binary, Type/binary, Sid/binary, Serverid:32, Openid/binary, Openkey/binary, Appid/binary, Pf/binary, Pfkey/binary>>,
	<<410:16, Data/binary>>.

%%
encode_loop_instance_reward_c2s(Term)->
	Data = <<>>,
	<<1808:16, Data/binary>>.

%%
encode_dragon_fight_left_time_s2c(Term)->
	Left_seconds=Term#dragon_fight_left_time_s2c.left_seconds,
	Data = <<Left_seconds:32>>,
	<<1259:16, Data/binary>>.

%%
encode_pet_explore_error_s2c(Term)->
	Error=Term#pet_explore_error_s2c.error,
	Data = <<Error:32>>,
	<<975:16, Data/binary>>.

%%
encode_be_killed_s2c(Term)->
	Creatureid=Term#be_killed_s2c.creatureid,
	Murderer=encode_string(Term#be_killed_s2c.murderer),
	Deadtype=Term#be_killed_s2c.deadtype,
	Posx=Term#be_killed_s2c.posx,
	Posy=Term#be_killed_s2c.posy,
	Series_kills=Term#be_killed_s2c.series_kills,
	Data = <<Creatureid:64, Murderer/binary, Deadtype:32, Posx:32, Posy:32, Series_kills:32>>,
	<<34:16, Data/binary>>.

%%
encode_update_pet_skill_s2c(Term)->
	Petid=Term#update_pet_skill_s2c.petid,
	Skills=encode_psk(Term#update_pet_skill_s2c.skills),
	Data = <<Petid:64, Skills/binary>>,
	<<928:16, Data/binary>>.

%%
encode_continuous_days_clear_c2s(Term)->
	Data = <<>>,
	<<1302:16, Data/binary>>.

%%
encode_set_black_s2c(Term)->
	Roleid=Term#set_black_s2c.roleid,
	Data = <<Roleid:64>>,
	<<476:16, Data/binary>>.

%%
encode_congratulations_receive_s2c(Term)->
	Exp=Term#congratulations_receive_s2c.exp,
	Soulpower=Term#congratulations_receive_s2c.soulpower,
	Type=Term#congratulations_receive_s2c.type,
	Rolename=encode_string(Term#congratulations_receive_s2c.rolename),
	Level=Term#congratulations_receive_s2c.level,
	Roleid=Term#congratulations_receive_s2c.roleid,
	Data = <<Exp:32, Soulpower:32, Type:32, Rolename/binary, Level:32, Roleid:64>>,
	<<1143:16, Data/binary>>.

%%
encode_guild_impeach_result_s2c(Term)->
	Result=Term#guild_impeach_result_s2c.result,
	Data = <<Result:32>>,
	<<1723:16, Data/binary>>.

%%
encode_mainline_opt_s2c(Term)->
	Errno=Term#mainline_opt_s2c.errno,
	Data = <<Errno:32>>,
	<<1577:16, Data/binary>>.

%%
encode_country_opt_s2c(Term)->
	Code=Term#country_opt_s2c.code,
	Data = <<Code:32>>,
	<<1662:16, Data/binary>>.

%%
encode_stalls_search_c2s(Term)->
	Index=Term#stalls_search_c2s.index,
	Data = <<Index:32>>,
	<<1033:16, Data/binary>>.

%%
encode_mainline_init_s2c(Term)->
	St=encode_list(Term#mainline_init_s2c.st, fun encode_stage/1),
	Data = <<St/binary>>,
	<<1561:16, Data/binary>>.

%%
encode_init_mall_item_list_c2s(Term)->
	Ntype=Term#init_mall_item_list_c2s.ntype,
	Data = <<Ntype:32>>,
	<<438:16, Data/binary>>.

%%
%%
encode_continuous_opt_result_s2c(Term)->
	Result=Term#continuous_opt_result_s2c.result,
	Awarddays=encode_int32_list(Term#continuous_opt_result_s2c.awarddays),
	Data = <<Result:32, Awarddays/binary>>,
	<<1303:16, Data/binary>>.

%%
encode_loop_instance_reward_s2c(Term)->
	Layer=Term#loop_instance_reward_s2c.layer,
	Type=Term#loop_instance_reward_s2c.type,
	Curlayer=Term#loop_instance_reward_s2c.curlayer,
	Data = <<Layer:32, Type:32, Curlayer:32>>,
	<<1809:16, Data/binary>>.

%%
encode_rank_answer_s2c(Term)->
	Param=encode_list(Term#rank_answer_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1430:16, 5:32, Data/binary>>.

%%
encode_myfriends_s2c(Term)->
	Friendinfos=encode_list(Term#myfriends_s2c.friendinfos, fun encode_fr/1),
	Data = <<Friendinfos/binary>>,
	<<481:16, Data/binary>>.

%%
encode_leave_guild_battle_c2s(Term)->
	Data = <<>>,
	<<1656:16, Data/binary>>.

%%
encode_pet_explore_gain_info_s2c(Term)->
	Petid=Term#pet_explore_gain_info_s2c.petid,
	Gainitem=encode_list(Term#pet_explore_gain_info_s2c.gainitem, fun encode_lti/1),
	Data = <<Petid:64, Gainitem/binary>>,
	<<976:16, Data/binary>>.

%%
encode_mainline_update_s2c(Term)->
	St=encode_stage(Term#mainline_update_s2c.st),
	Type=Term#mainline_update_s2c.type,
	Data = <<St/binary, Type:32>>,
	<<1562:16, Data/binary>>.

%%
encode_guild_update_log_s2c(Term)->
	Log=encode_guildlog(Term#guild_update_log_s2c.log),
	Data = <<Log/binary>>,
	<<399:16, Data/binary>>.

%%
encode_mail_status_query_s2c(Term)->
	Mail_status=encode_list(Term#mail_status_query_s2c.mail_status, fun encode_ms/1),
	Data = <<Mail_status/binary>>,
	<<531:16, Data/binary>>.

%%
encode_chat_private_c2s(Term)->
	Serverid=Term#chat_private_c2s.serverid,
	Roleid=Term#chat_private_c2s.roleid,
	Data = <<Serverid:32, Roleid:64>>,
	<<146:16, Data/binary>>.

%%
encode_duel_result_s2c(Term)->
	Winner=Term#duel_result_s2c.winner,
	Data = <<Winner:64>>,
	<<723:16, Data/binary>>.

%%
encode_guild_impeach_info_c2s(Term)->
	Data = <<>>,
	<<1724:16, Data/binary>>.

%%
encode_mail_send_c2s(Term)->
	Toi=encode_string(Term#mail_send_c2s.toi),
	Title=encode_string(Term#mail_send_c2s.title),
	Content=encode_string(Term#mail_send_c2s.content),
	Add_silver=Term#mail_send_c2s.add_silver,
	Add_item=encode_int32_list(Term#mail_send_c2s.add_item),
	Data = <<Toi/binary, Title/binary, Content/binary, Add_silver:64, Add_item/binary>>,
	<<537:16, Data/binary>>.

%%
encode_stalls_search_item_c2s(Term)->
	Searchstr=encode_string(Term#stalls_search_item_c2s.searchstr),
	Index=Term#stalls_search_item_c2s.index,
	Data = <<Searchstr/binary, Index:32>>,
	<<1037:16, Data/binary>>.

%%
encode_init_mall_item_list_s2c(Term)->
	Mitemlists=encode_list(Term#init_mall_item_list_s2c.mitemlists, fun encode_mi/1),
	Data = <<Mitemlists/binary>>,
	<<439:16, Data/binary>>.

%%
encode_spa_join_c2s(Term)->
	Spaid=Term#spa_join_c2s.spaid,
	Data = <<Spaid:32>>,
	<<1603:16, Data/binary>>.

%%
encode_other_role_into_view_s2c(Term)->
	Other=encode_rl(Term#other_role_into_view_s2c.other),
	Data = <<Other/binary>>,
	<<35:16, Data/binary>>.

%%
encode_continuous_logging_board_s2c(Term)->
	Days=Term#continuous_logging_board_s2c.days,
	Awarddays=encode_int32_list(Term#continuous_logging_board_s2c.awarddays),
	Data = <<Days:32, Awarddays/binary>>,
	<<1304:16, Data/binary>>.

%%
encode_pet_stop_training_c2s(Term)->
	Petid=Term#pet_stop_training_c2s.petid,
	Data = <<Petid:64>>,
	<<952:16, Data/binary>>.

%%
encode_loop_instance_remain_monsters_info_s2c(Term)->
	Kill_num=Term#loop_instance_remain_monsters_info_s2c.kill_num,
	Remain_num=Term#loop_instance_remain_monsters_info_s2c.remain_num,
	Type=Term#loop_instance_remain_monsters_info_s2c.type,
	Layer=Term#loop_instance_remain_monsters_info_s2c.layer,
	Data = <<Kill_num:32, Remain_num:32, Type:32, Layer:32>>,
	<<1810:16, Data/binary>>.

%%
encode_pet_add_attr_c2s(Term)->
	Petid=Term#pet_add_attr_c2s.petid,
	Power_add=Term#pet_add_attr_c2s.power_add,
	Hitrate_add=Term#pet_add_attr_c2s.hitrate_add,
	Criticalrate_add=Term#pet_add_attr_c2s.criticalrate_add,
	Stamina_add=Term#pet_add_attr_c2s.stamina_add,
	Data = <<Petid:64, Power_add:32, Hitrate_add:32, Criticalrate_add:32, Stamina_add:32>>,
	<<1502:16, Data/binary>>.

%%
encode_rank_chess_spirits_single_s2c(Term)->
	Param=encode_list(Term#rank_chess_spirits_single_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1430:16, 6:32, Data/binary>>.

%%
encode_battle_waiting_s2c(Term)->
	Waitingtime=Term#battle_waiting_s2c.waitingtime,
	Data = <<Waitingtime:32>>,
	<<829:16, Data/binary>>.

%%
encode_companion_reject_c2s(Term)->
	Roleid=Term#companion_reject_c2s.roleid,
	Data = <<Roleid:64>>,
	<<1256:16, Data/binary>>.

%%
encode_change_country_notice_s2c(Term)->
	Notice=encode_string(Term#change_country_notice_s2c.notice),
	Data = <<Notice/binary>>,
	<<1642:16, Data/binary>>.


%%
encode_guild_impeach_info_s2c(Term)->
	Roleid=Term#guild_impeach_info_s2c.roleid,
	Notice=encode_string(Term#guild_impeach_info_s2c.notice),
	Support=Term#guild_impeach_info_s2c.support,
	Opposite=Term#guild_impeach_info_s2c.opposite,
	Vote=Term#guild_impeach_info_s2c.vote,
	Lefttime_s=Term#guild_impeach_info_s2c.lefttime_s,
	Data = <<Roleid:64, Notice/binary, Support:32, Opposite:32, Vote:32, Lefttime_s:32>>,
	<<1725:16, Data/binary>>.

%%
encode_mail_arrived_s2c(Term)->
	Mail_status=encode_list(Term#mail_arrived_s2c.mail_status, fun encode_ms/1),
	Data = <<Mail_status/binary>>,
	<<532:16, Data/binary>>.

%%
encode_mainline_start_entry_c2s(Term)->
	Chapter=Term#mainline_start_entry_c2s.chapter,
	Stage=Term#mainline_start_entry_c2s.stage,
	Difficulty=Term#mainline_start_entry_c2s.difficulty,
	Data = <<Chapter:32, Stage:32, Difficulty:32>>,
	<<1563:16, Data/binary>>.

%%
encode_leave_guild_battle_s2c(Term)->
	Result=Term#leave_guild_battle_s2c.result,
	Data = <<Result:32>>,
	<<1657:16, Data/binary>>.

%%
encode_loop_instance_kill_monsters_info_s2c(Term)->
	Npcprotoid=Term#loop_instance_kill_monsters_info_s2c.npcprotoid,
	Neednum=Term#loop_instance_kill_monsters_info_s2c.neednum,
	Type=Term#loop_instance_kill_monsters_info_s2c.type,
	Layer=Term#loop_instance_kill_monsters_info_s2c.layer,
	Data = <<Npcprotoid:32, Neednum:32, Type:32, Layer:32>>,
	<<1811:16, Data/binary>>.

%%
encode_guild_battle_opt_s2c(Term)->
	Code=Term#guild_battle_opt_s2c.code,
	Data = <<Code:32>>,
	<<1663:16, Data/binary>>.

%%
encode_buff_affect_attr_s2c(Term)->
	Roleid=Term#buff_affect_attr_s2c.roleid,
	Attrs=encode_list(Term#buff_affect_attr_s2c.attrs, fun encode_k/1),
	Data = <<Roleid:64, Attrs/binary>>,
	<<103:16, Data/binary>>.

%%
encode_pet_swap_slot_c2s(Term)->
	Petid=Term#pet_swap_slot_c2s.petid,
	Slot=Term#pet_swap_slot_c2s.slot,
	Data = <<Petid:64, Slot:32>>,
	<<921:16, Data/binary>>.

%%
encode_mall_item_list_c2s(Term)->
	Ntype=Term#mall_item_list_c2s.ntype,
	Data = <<Ntype:32>>,
	<<429:16, Data/binary>>.

%%
encode_stall_detail_c2s(Term)->
	Stallid=Term#stall_detail_c2s.stallid,
	Data = <<Stallid:64>>,
	<<1034:16, Data/binary>>.

%%
encode_add_friend_c2s(Term)->
	Fn=encode_string(Term#add_friend_c2s.fn),
	Data = <<Fn/binary>>,
	<<482:16, Data/binary>>.

%%
encode_npc_into_view_s2c(Term)->
	Npc=encode_nl(Term#npc_into_view_s2c.npc),
	Data = <<Npc/binary>>,
	<<36:16, Data/binary>>.

%%
encode_rank_chess_spirits_team_s2c(Term)->
	Param=encode_list(Term#rank_chess_spirits_team_s2c.param, fun encode_rc/1),
	Data = <<Param/binary>>,
	<<1430:16, 7:32, Data/binary>>.

%%
encode_online_friend_s2c(Term)->
	FId=Term#online_friend_s2c.fid,
	Data = <<FId:64>>,
	<<489:16, Data/binary>>.

%%
encode_spa_join_s2c(Term)->
	Spaid=Term#spa_join_s2c.spaid,
	Chopping=Term#spa_join_s2c.chopping,
	Swimming=Term#spa_join_s2c.swimming,
	Lefttime=Term#spa_join_s2c.lefttime,
	Choppingtime=Term#spa_join_s2c.choppingtime,
	Swimmingtime=Term#spa_join_s2c.swimmingtime,
	Data = <<Spaid:32, Chopping:32, Swimming:32, Lefttime:32, Choppingtime:32, Swimmingtime:32>>,
	<<1604:16, Data/binary>>.

%%
encode_loudspeaker_opt_s2c(Term)->
	Reasonid=Term#loudspeaker_opt_s2c.reasonid,
	Data = <<Reasonid:32>>,
	<<145:16, Data/binary>>.

%%
encode_star_spawns_section_s2c(Term)->
	Section=Term#star_spawns_section_s2c.section,
	Data = <<Section:32>>,
	<<1267:16, Data/binary>>.

%%
encode_guild_battle_stop_s2c(Term)->
	Data = <<>>,
	<<1664:16, Data/binary>>.

%%
encode_everquest_list_s2c(Term)->
	Everquests=encode_list(Term#everquest_list_s2c.everquests, fun encode_eq/1),
	Data = <<Everquests/binary>>,
	<<857:16, Data/binary>>.

%%
encode_user_auth_fail_s2c(Term)->
	Reasonid=Term#user_auth_fail_s2c.reasonid,
	Data = <<Reasonid:32>>,
	<<411:16, Data/binary>>.

%%
encode_treasure_storage_init_c2s(Term)->
	Data = <<>>,
	<<1310:16, Data/binary>>.

%%
encode_revert_black_c2s(Term)->
	Fn=encode_string(Term#revert_black_c2s.fn),
	Data = <<Fn/binary>>,
	<<469:16, Data/binary>>.

%%
encode_pet_up_stamina_growth_s2c(Term)->
	Result=Term#pet_up_stamina_growth_s2c.result,
	Next=Term#pet_up_stamina_growth_s2c.next,
	Data = <<Result:32, Next:32>>,
	<<915:16, Data/binary>>.

%%
encode_loop_instance_kill_monsters_info_init_s2c(Term)->
	Info=encode_list(Term#loop_instance_kill_monsters_info_init_s2c.info, fun encode_kmi/1),
	Type=Term#loop_instance_kill_monsters_info_init_s2c.type,
	Layer=Term#loop_instance_kill_monsters_info_init_s2c.layer,
	Data = <<Info/binary, Type:32, Layer:32>>,
	<<1813:16, Data/binary>>.

%%
encode_stall_buy_item_c2s(Term)->
	Stallid=Term#stall_buy_item_c2s.stallid,
	Itemlid=Term#stall_buy_item_c2s.itemlid,
	Itemhid=Term#stall_buy_item_c2s.itemhid,
	Data = <<Stallid:64, Itemlid:32, Itemhid:32>>,
	<<1035:16, Data/binary>>.

%%
encode_guild_recruite_info_s2c(Term)->
	Recinfos=encode_list(Term#guild_recruite_info_s2c.recinfos, fun encode_gr/1),
	Data = <<Recinfos/binary>>,
	<<391:16, Data/binary>>.

%%
encode_mall_item_list_s2c(Term)->
	Mitemlists=encode_list(Term#mall_item_list_s2c.mitemlists, fun encode_mi/1),
	Data = <<Mitemlists/binary>>,
	<<430:16, Data/binary>>.

%%
encode_mainline_start_entry_s2c(Term)->
	Chapter=Term#mainline_start_entry_s2c.chapter,
	Stage=Term#mainline_start_entry_s2c.stage,
	Difficulty=Term#mainline_start_entry_s2c.difficulty,
	Opcode=Term#mainline_start_entry_s2c.opcode,
	Data = <<Chapter:32, Stage:32, Difficulty:32, Opcode:32>>,
	<<1564:16, Data/binary>>.

%%
encode_pet_delete_s2c(Term)->
	Petid=Term#pet_delete_s2c.petid,
	Data = <<Petid:64>>,
	<<920:16, Data/binary>>.

%%
encode_pet_speedup_training_c2s(Term)->
	Petid=Term#pet_speedup_training_c2s.petid,
	Speeduptime=Term#pet_speedup_training_c2s.speeduptime,
	Data = <<Petid:64, Speeduptime:32>>,
	<<953:16, Data/binary>>.

%%
encode_creature_outof_view_s2c(Term)->
	Creature_id=Term#creature_outof_view_s2c.creature_id,
	Data = <<Creature_id:64>>,
	<<37:16, Data/binary>>.

%%
encode_companion_reject_s2c(Term)->
	Rolename=encode_string(Term#companion_reject_s2c.rolename),
	Data = <<Rolename/binary>>,
	<<1257:16, Data/binary>>.

%%
encode_rank_loop_tower_s2c(Term)->
	Param=encode_list(Term#rank_loop_tower_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1430:16, Data/binary>>.

%%
encode_enum_skill_item_c2s(Term)->
	Npcid=Term#enum_skill_item_c2s.npcid,
	Data = <<Npcid:64>>,
	<<412:16, Data/binary>>.

%%
encode_change_country_transport_c2s(Term)->
	Tp_start=Term#change_country_transport_c2s.tp_start,
	Data = <<Tp_start:32>>,
	<<1643:16, Data/binary>>.

%%
encode_congratulations_received_c2s(Term)->
	Level=Term#congratulations_received_c2s.level,
	Rolename=encode_string(Term#congratulations_received_c2s.rolename),
	Data = <<Level:32, Rolename/binary>>,
	<<1145:16, Data/binary>>.

%%
encode_role_map_change_c2s(Term)->
	Seqid=Term#role_map_change_c2s.seqid,
	Transid=Term#role_map_change_c2s.transid,
	Data = <<Seqid:32, Transid:32>>,
	<<61:16, Data/binary>>.

%%
encode_guild_impeach_vote_c2s(Term)->
	Type=Term#guild_impeach_vote_c2s.type,
	Data = <<Type:32>>,
	<<1726:16, Data/binary>>.

%%
encode_update_everquest_s2c(Term)->
	Everqid=Term#update_everquest_s2c.everqid,
	Questid=Term#update_everquest_s2c.questid,
	Free_fresh_times=Term#update_everquest_s2c.free_fresh_times,
	Round=Term#update_everquest_s2c.round,
	Section=Term#update_everquest_s2c.section,
	Quality=Term#update_everquest_s2c.quality,
	Data = <<Everqid:32, Questid:32, Free_fresh_times:32, Round:32, Section:32, Quality:32>>,
	<<851:16, Data/binary>>.

%%
encode_mall_item_list_special_c2s(Term)->
	Ntype2=Term#mall_item_list_special_c2s.ntype2,
	Data = <<Ntype2:32>>,
	<<434:16, Data/binary>>.

%%
encode_offline_friend_s2c(Term)->
	Fid= Term#offline_friend_s2c.fid,
	Data = <<Fid:64>>,
	<<490:16, Data/binary>>.

%%
encode_dragon_fight_start_s2c(Term)->
	Duration=Term#dragon_fight_start_s2c.duration,
	Data = <<Duration:32>>,
	<<1264:16, Data/binary>>.

%%
%%encode_pet_present_s2c(Term)->
%%	Present_pets=encode_list(Term#pet_present_s2c.present_pets, fun encode_pp/1),
%%	%%Data = <<Present_pets/binary>>,
%%	<<907:16, Data/binary>>.

%%
encode_role_change_map_c2s(Term)->
	Data = <<>>,
	<<22:16, Data/binary>>.

%%
encode_rank_killer_s2c(Term)->
	Param=encode_list(Term#rank_killer_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1430:16, 4:32, Data/binary>>.

%%
encode_battle_start_s2c(Term)->
	Type=Term#battle_start_s2c.type,
	Lefttime=Term#battle_start_s2c.lefttime,
	Data = <<Type:32, Lefttime:32>>,
	<<820:16, Data/binary>>.

%%
encode_fatigue_prompt_with_type_s2c(Term)->
	Prompt=encode_string(Term#fatigue_prompt_with_type_s2c.prompt),
	Type=Term#fatigue_prompt_with_type_s2c.type,
	Data = <<Prompt/binary, Type:32>>,
	<<340:16, Data/binary>>.

%%
encode_guild_clear_nickname_c2s(Term)->
	Roleid=Term#guild_clear_nickname_c2s.roleid,
	Data = <<Roleid:64>>,
	<<1447:16, Data/binary>>.

%%
encode_role_change_map_ok_s2c(Term)->
	Data = <<>>,
	<<23:16, Data/binary>>.

%%
encode_enum_skill_item_fail_s2c(Term)->
	Reason=Term#enum_skill_item_fail_s2c.reason,
	Data = <<Reason:32>>,
	<<413:16, Data/binary>>.

%%
encode_offline_exp_init_s2c(Term)->
	Hour=Term#offline_exp_init_s2c.hour,
	Totalexp=Term#offline_exp_init_s2c.totalexp,
	Data = <<Hour:32, Totalexp:32>>,
	<<1131:16, Data/binary>>.

%%
encode_stall_rename_c2s(Term)->
	Stall_name=encode_string(Term#stall_rename_c2s.stall_name),
	Data = <<Stall_name/binary>>,
	<<1036:16, Data/binary>>.

%%
encode_treasure_storage_info_s2c(Term)->
	Items=encode_list(Term#treasure_storage_info_s2c.items, fun encode_tsi/1),
	Data = <<Items/binary>>,
	<<1311:16, Data/binary>>.

%%
encode_loop_tower_challenge_success_s2c(Term)->
	Layer=Term#loop_tower_challenge_success_s2c.layer,
	Bonus=Term#loop_tower_challenge_success_s2c.bonus,
	Data = <<Layer:32, Bonus:32>>,
	<<656:16, Data/binary>>.

%%
encode_mall_item_list_special_s2c(Term)->
	Mitemlists=encode_list(Term#mall_item_list_special_s2c.mitemlists, fun encode_mi/1),
	Data = <<Mitemlists/binary>>,
	<<435:16, Data/binary>>.

%%
encode_revert_black_s2c(Term)->
	Friendinfo=encode_fr(Term#revert_black_s2c.friendinfo),
	Data = <<Friendinfo/binary>>,
	<<470:16, Data/binary>>.

%%
encode_detail_friend_c2s(Term)->
	Fn=encode_string(Term#detail_friend_c2s.fn),
	Data = <<Fn/binary>>,
	<<491:16, Data/binary>>.

%%
encode_pet_present_apply_c2s(Term)->
	Slot=Term#pet_present_apply_c2s.slot,
	Data = <<Slot:32>>,
	<<908:16, Data/binary>>.

%%
encode_spa_leave_s2c(Term)->
	Data = <<>>,
	<<1612:16, Data/binary>>.

%%
encode_mainline_start_c2s(Term)->
	Chapter=Term#mainline_start_c2s.chapter,
	Stage=Term#mainline_start_c2s.stage,
	Data = <<Chapter:32, Stage:32>>,
	<<1565:16, Data/binary>>.

%%
encode_fly_shoes_c2s(Term)->
	Mapid=Term#fly_shoes_c2s.mapid,
	Posx=Term#fly_shoes_c2s.posx,
	Posy=Term#fly_shoes_c2s.posy,
	Slot=Term#fly_shoes_c2s.slot,
	Data = <<Mapid:32, Posx:32, Posy:32, Slot:32>>,
	<<810:16, Data/binary>>.

%%
encode_spa_leave_c2s(Term)->
	Data = <<>>,
	<<1611:16, Data/binary>>.

%%
encode_rank_moneys_s2c(Term)->
	Param=encode_list(Term#rank_moneys_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1430:16, 2:32, Data/binary>>.

%%
encode_country_init_c2s(Term)->
	Data = <<>>,
	<<1665:16, Data/binary>>.

%%
encode_role_change_map_fail_s2c(Term)->
	Data = <<>>,
	<<24:16, Data/binary>>.

%%
encode_guild_mastercall_success_s2c(Term)->
	Data = <<>>,
	<<1247:16, Data/binary>>.

%%
encode_welfare_panel_init_c2s(Term)->
	Data = <<>>,
	<<1460:16, Data/binary>>.

%%
encode_guild_join_lefttime_s2c(Term)->
	Lefttime=Term#guild_join_lefttime_s2c.lefttime,
	Data = <<Lefttime:32>>,
	<<1728:16, Data/binary>>.

%%
encode_add_black_c2s(Term)->
	Bn=encode_string(Term#add_black_c2s.bn),
	Data = <<Bn/binary>>,
	<<497:16, Data/binary>>.

%%
encode_guild_impeach_stop_s2c(Term)->
	Data = <<>>,
	<<1727:16, Data/binary>>.

%%
encode_pet_riseup_c2s(Term)->
	Petid=Term#pet_riseup_c2s.petid,
	Needs=Term#pet_riseup_c2s.needs,
	Protect=Term#pet_riseup_c2s.protect,
	Data = <<Petid:64, Needs:32, Protect:32>>,
	<<924:16, Data/binary>>.

%%
encode_role_move_c2s(Term)->
	Time=Term#role_move_c2s.time,
	Posx=Term#role_move_c2s.posx,
	Posy=Term#role_move_c2s.posy,
	Path=encode_list(Term#role_move_c2s.path, fun encode_c/1),
	Data = <<Time:32, Posx:32, Posy:32, Path/binary>>,
	<<25:16, Data/binary>>.

%%
encode_pet_present_apply_s2c(Term)->
	Delete_slot=Term#pet_present_apply_s2c.delete_slot,
	Data = <<Delete_slot:32>>,
	<<909:16, Data/binary>>.

%%
encode_trade_role_apply_c2s(Term)->
	Roleid=Term#trade_role_apply_c2s.roleid,
	Data = <<Roleid:64>>,
	<<560:16, Data/binary>>.

%%
encode_mall_item_list_sales_c2s(Term)->
	Ntype=Term#mall_item_list_sales_c2s.ntype,
	Data = <<Ntype:32>>,
	<<436:16, Data/binary>>.

%%
encode_skill_panel_c2s(Term)->
	Data = <<>>,
	<<70:16, Data/binary>>.

%%
encode_treasure_storage_init_end_s2c(Term)->
	Data = <<>>,
	<<1312:16, Data/binary>>.

%%
encode_get_instance_log_c2s(Term)->
	Data = <<>>,
	<<831:16, Data/binary>>.

%%
encode_spa_chopping_c2s(Term)->
	Roleid=Term#spa_chopping_c2s.roleid,
	Slot=Term#spa_chopping_c2s.slot,
	Data = <<Roleid:64, Slot:32>>,
	<<1614:16, Data/binary>>.

%%
encode_rank_melee_power_s2c(Term)->
	Param=encode_list(Term#rank_melee_power_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1433:16, Data/binary>>.

%%
encode_treasure_storage_getitem_c2s(Term)->
	Slot=Term#treasure_storage_getitem_c2s.slot,
	Itemsign=Term#treasure_storage_getitem_c2s.itemsign,
	Data = <<Slot:32, Itemsign:32>>,
	<<1313:16, Data/binary>>.

%%
encode_pet_wash_attr_c2s(Term)->
	Petid=Term#pet_wash_attr_c2s.petid,
	Type=Term#pet_wash_attr_c2s.type,
	Data = <<Petid:64, Type:32>>,
	<<1503:16, Data/binary>>.

%%
encode_battle_self_join_s2c(Term)->
	Trs=encode_list(Term#battle_self_join_s2c.trs, fun encode_tr/1),
	Battletype=Term#battle_self_join_s2c.battletype,
	Battleid=Term#battle_self_join_s2c.battleid,
	Lefttime=Term#battle_self_join_s2c.lefttime,
	Data = <<Trs/binary, Battletype:32, Battleid:32, Lefttime:32>>,
	<<823:16, Data/binary>>.

%%
encode_chat_private_s2c(Term)->
	Roleid=Term#chat_private_s2c.roleid,
	Level=Term#chat_private_s2c.level,
	Roleclass=Term#chat_private_s2c.roleclass,
	Rolegender=Term#chat_private_s2c.rolegender,
	Signature=encode_string(Term#chat_private_s2c.signature),
	Guildname=encode_string(Term#chat_private_s2c.guildname),
	Guildlid=Term#chat_private_s2c.guildlid,
	Guildhid=Term#chat_private_s2c.guildhid,
	Viptag=Term#chat_private_s2c.viptag,
	Rolename=encode_string(Term#chat_private_s2c.rolename),
	Serverid=Term#chat_private_s2c.serverid,
	Data = <<Roleid:64, Level:32, Roleclass:32, Rolegender:32, Signature/binary, Guildname/binary, Guildlid:32, Guildhid:32, Viptag:32, Rolename/binary, Serverid:32>>,
	<<147:16, Data/binary>>.

%%
encode_spiritspower_state_update_s2c(Term)->
	State=Term#spiritspower_state_update_s2c.state,
	Lefttime=Term#spiritspower_state_update_s2c.lefttime,
	Curvalue=Term#spiritspower_state_update_s2c.curvalue,
	Data = <<State:32, Lefttime:32, Curvalue:32>>,
	<<1730:16, Data/binary>>.

%%
encode_guild_battle_score_init_s2c(Term)->
	Guildlist=encode_list(Term#guild_battle_score_init_s2c.guildlist, fun encode_gbs/1),
	Data = <<Guildlist/binary>>,
	<<1658:16, Data/binary>>.

%%
encode_get_instance_log_s2c(Term)->
	Instance_id=encode_int32_list(Term#get_instance_log_s2c.instance_id),
	Times=encode_int32_list(Term#get_instance_log_s2c.times),
	Data = <<Instance_id/binary, Times/binary>>,
	<<832:16, Data/binary>>.

%%
encode_loop_tower_masters_s2c(Term)->
	Ltms=encode_list(Term#loop_tower_masters_s2c.ltms, fun encode_ltm/1),
	Data = <<Ltms/binary>>,
	<<653:16, Data/binary>>.

%%
encode_trade_role_accept_c2s(Term)->
	Roleid=Term#trade_role_accept_c2s.roleid,
	Data = <<Roleid:64>>,
	<<561:16, Data/binary>>.

%%
encode_mall_item_list_sales_s2c(Term)->
	Mitemlists=encode_list(Term#mall_item_list_sales_s2c.mitemlists, fun encode_smi/1),
	Data = <<Mitemlists/binary>>,
	<<437:16, Data/binary>>.

%%
encode_mainline_start_s2c(Term)->
	Chapter=Term#mainline_start_s2c.chapter,
	Stage=Term#mainline_start_s2c.stage,
	Difficulty=Term#mainline_start_s2c.difficulty,
	Opcode=Term#mainline_start_s2c.opcode,
	Data = <<Chapter:32, Stage:32, Difficulty:32, Opcode:32>>,
	<<1566:16, Data/binary>>.

%%
encode_stall_detail_s2c(Term)->
	Ownerid=Term#stall_detail_s2c.ownerid,
	Stallid=Term#stall_detail_s2c.stallid,
	Stallname=encode_string(Term#stall_detail_s2c.stallname),
	Stallitems=encode_list(Term#stall_detail_s2c.stallitems, fun encode_si/1),
	Logs=encode_string_list(Term#stall_detail_s2c.logs),
	Isonline=Term#stall_detail_s2c.isonline,
	Data = <<Ownerid:64, Stallid:64, Stallname/binary, Stallitems/binary, Logs/binary, Isonline:32>>,
	<<1040:16, Data/binary>>.

%%
encode_npc_swap_item_c2s(Term)->
	Npcid=Term#npc_swap_item_c2s.npcid,
	Srcslot=Term#npc_swap_item_c2s.srcslot,
	Desslot=Term#npc_swap_item_c2s.desslot,
	Data = <<Npcid:64, Srcslot:32, Desslot:32>>,
	<<812:16, Data/binary>>.

%%
encode_enum_skill_item_s2c(Term)->
	Npcid=Term#enum_skill_item_s2c.npcid,
	Data = <<Npcid:64>>,
	<<414:16, Data/binary>>.

%%
encode_detail_friend_s2c(Term)->
	Defr=encode_dfr(Term#detail_friend_s2c.defr),
	Data = <<Defr/binary>>,
	<<492:16, Data/binary>>.

%%
encode_rank_range_power_s2c(Term)->
	Param=encode_list(Term#rank_range_power_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1434:16, Data/binary>>.

%%
encode_spa_stop_s2c(Term)->
	Data = <<>>,
	<<1613:16, Data/binary>>.

%%
encode_delete_black_c2s(Term)->
	Fn=encode_string(Term#delete_black_c2s.fn),
	Data = <<Fn/binary>>,
	<<477:16, Data/binary>>.

%%
encode_dragon_fight_join_c2s(Term)->
	Data = <<>>,
	<<1266:16, Data/binary>>.

%%
encode_guild_battle_ready_s2c(Term)->
	Remaintime=Term#guild_battle_ready_s2c.remaintime,
	Data = <<Remaintime:32>>,
	<<1666:16, Data/binary>>.

%%
encode_dragon_fight_end_s2c(Term)->
	Rednum=Term#dragon_fight_end_s2c.rednum,
	Bluenum=Term#dragon_fight_end_s2c.bluenum,
	Winfaction=Term#dragon_fight_end_s2c.winfaction,
	Data = <<Rednum:32, Bluenum:32, Winfaction:32>>,
	<<1265:16, Data/binary>>.

%%
encode_pet_learn_skill_cover_best_s2c(Term)->
	Petid=Term#pet_learn_skill_cover_best_s2c.petid,
	Slot=Term#pet_learn_skill_cover_best_s2c.slot,
	Skillid=Term#pet_learn_skill_cover_best_s2c.skillid,
	Oldlevel=Term#pet_learn_skill_cover_best_s2c.oldlevel,
	Newlevel=Term#pet_learn_skill_cover_best_s2c.newlevel,
	Data = <<Petid:64, Slot:32, Skillid:32, Oldlevel:32, Newlevel:32>>,
	<<931:16, Data/binary>>.

%%
encode_init_hot_item_s2c(Term)->
	Lists=encode_list(Term#init_hot_item_s2c.lists, fun encode_imi/1),
	Data = <<Lists/binary>>,
	<<432:16, Data/binary>>.

%%
encode_stop_move_c2s(Term)->
	Time=Term#stop_move_c2s.time,
	Posx=Term#stop_move_c2s.posx,
	Posy=Term#stop_move_c2s.posy,
	Data = <<Time:32, Posx:32, Posy:32>>,
	<<742:16, Data/binary>>.

%%
encode_spa_chopping_s2c(Term)->
	Name=encode_string(Term#spa_chopping_s2c.name),
	Bename=encode_string(Term#spa_chopping_s2c.bename),
	Remain=Term#spa_chopping_s2c.remain,
	Data = <<Name/binary, Bename/binary, Remain:32>>,
	<<1605:16, Data/binary>>.

%%
encode_add_friend_confirm_s2c(Term)->
	Roleid=Term#add_friend_confirm_s2c.roleid,
	Level=Term#add_friend_confirm_s2c.level,
	Name=encode_string(Term#add_friend_confirm_s2c.rolename),
	Data = <<Roleid:64, Level:32, Name/binary>>,
	<<2259:16, Data/binary>>.

%%拒绝加为好友
encode_add_friend_reject_s2c(Term)->
	Name=encode_string(Term#add_friend_reject_s2c.name),
	Data = <<Name/binary>>,
	<<2250:16, Data/binary>>.
	
	

encode_add_friend_success_s2c(Term)->
	Friendinfo=encode_fr(Term#add_friend_success_s2c.friendinfo),
	Data = <<Friendinfo/binary>>,
	<<483:16, Data/binary>>.

%%找人结果
encode_search_role_s2c(Term)->
	Gender=Term#search_role_s2c.gender,
	Level=Term#search_role_s2c.level,
	Roleclass=Term#search_role_s2c.roleclass,
	Name=encode_string(Term#search_role_s2c.name),
	Roleid=Term#search_role_s2c.roleid,
	Online=Term#search_role_s2c.online,
	Guildname=encode_string(Term#search_role_s2c.guildname),
	Data = <<Gender:32, Level:32, Roleclass:32, Name/binary, Roleid:64, Online:32, Guildname/binary>>,
	<<2261:16, Data/binary>>.

%%查找好友失败
encode_search_role_error_s2c(Term)->
	Errno=Term#search_role_error_s2c.errno,
	Data = <<Errno:32>>,
	<<2249:16, Data/binary>>.
%%
encode_loop_tower_enter_c2s(Term)->
	Layer=Term#loop_tower_enter_c2s.layer,
	Enter=Term#loop_tower_enter_c2s.enter,
	Convey=Term#loop_tower_enter_c2s.convey,
	Data = <<Layer:32, Enter:32, Convey:32>>,
	<<650:16, Data/binary>>.

%%
encode_chess_spirit_cast_chess_skill_c2s(Term)->
	Data = <<>>,
	<<1177:16, Data/binary>>.

%%
encode_spiritspower_reset_c2s(Term)->
	Data = <<>>,
	<<1731:16, Data/binary>>.

%%
encode_detail_friend_failed_s2c(Term)->
	Reason=Term#detail_friend_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<493:16, Data/binary>>.

%%
encode_battle_reward_c2s(Term)->
	Data = <<>>,
	<<827:16, Data/binary>>.

%%
encode_rank_magic_power_s2c(Term)->
	Param=encode_list(Term#rank_magic_power_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1435:16, Data/binary>>.

%%
encode_skill_learn_item_c2s(Term)->
	Skillid=Term#skill_learn_item_c2s.skillid,
	Data = <<Skillid:32>>,
	<<415:16, Data/binary>>.

%%
encode_mainline_end_c2s(Term)->
	Chapter=Term#mainline_end_c2s.chapter,
	Stage=Term#mainline_end_c2s.stage,
	Data = <<Chapter:32, Stage:32>>,
	<<1567:16, Data/binary>>.

%%
encode_group_apply_c2s(Term)->
	Username=encode_string(Term#group_apply_c2s.username),
	Data = <<Username/binary>>,
	<<150:16, Data/binary>>.

%%
encode_treasure_storage_getallitems_c2s(Term)->
	Data = <<>>,
	<<1314:16, Data/binary>>.

%%
encode_callback_guild_monster_c2s(Term)->
	Monsterid=Term#callback_guild_monster_c2s.monsterid,
	Data = <<Monsterid:32>>,
	<<1762:16, Data/binary>>.

%%
encode_pet_upgrade_quality_s2c(Term)->
	Result=Term#pet_upgrade_quality_s2c.result,
	Value=Term#pet_upgrade_quality_s2c.value,
	Data = <<Result:32, Value:32>>,
	<<1504:16, Data/binary>>.

%%
encode_init_latest_item_s2c(Term)->
	Lists=encode_list(Term#init_latest_item_s2c.lists, fun encode_imi/1),
	Data = <<Lists/binary>>,
	<<433:16, Data/binary>>.

%%
encode_battle_reward_by_records_c2s(Term)->
	Year=Term#battle_reward_by_records_c2s.year,
	Month=Term#battle_reward_by_records_c2s.month,
	Day=Term#battle_reward_by_records_c2s.day,
	Battletype=Term#battle_reward_by_records_c2s.battletype,
	Battleid=Term#battle_reward_by_records_c2s.battleid,
	Data = <<Year:32, Month:32, Day:32, Battletype:32, Battleid:32>>,
	<<1010:16, Data/binary>>.

%%
encode_treasure_storage_updateitem_s2c(Term)->
	Itemlist=encode_list(Term#treasure_storage_updateitem_s2c.itemlist, fun encode_tsi/1),
	Data = <<Itemlist/binary>>,
	<<1315:16, Data/binary>>.

%%
encode_spa_swimming_c2s(Term)->
	Roleid=Term#spa_swimming_c2s.roleid,
	Data = <<Roleid:64>>,
	<<1607:16, Data/binary>>.

%%
encode_christmas_tree_grow_up_c2s(Term)->
	Npcid=Term#christmas_tree_grow_up_c2s.npcid,
	Slot=Term#christmas_tree_grow_up_c2s.slot,
	Data = <<Npcid:64, Slot:32>>,
	<<1740:16, Data/binary>>.

%%
encode_guild_mastercall_accept_c2s(Term)->
	Data = <<>>,
	<<1246:16, Data/binary>>.

%%
encode_loop_tower_reward_c2s(Term)->
	Bonus=Term#loop_tower_reward_c2s.bonus,
	Data = <<Bonus:32>>,
	<<657:16, Data/binary>>.

%%
encode_guild_member_pos_c2s(Term)->
	Data = <<>>,
	<<1248:16, Data/binary>>.

%%
encode_position_friend_c2s(Term)->
	Fn=encode_string(Term#position_friend_c2s.fn),
	Data = <<Fn/binary>>,
	<<494:16, Data/binary>>.

%%
encode_skill_learn_item_fail_s2c(Term)->
	Reason=Term#skill_learn_item_fail_s2c.reason,
	Data = <<Reason:32>>,
	<<416:16, Data/binary>>.

%%
encode_pet_training_init_info_s2c(Term)->
	Petid=Term#pet_training_init_info_s2c.petid,
	Totaltime=Term#pet_training_init_info_s2c.totaltime,
	Remaintime=Term#pet_training_init_info_s2c.remaintime,
	Data = <<Petid:64, Totaltime:32, Remaintime:32>>,
	<<954:16, Data/binary>>.

%%
encode_heartbeat_c2s(Term)->
	Beat_time=Term#heartbeat_c2s.beat_time,
	Data = <<Beat_time:32>>,
	<<26:16, Data/binary>>.

%%
encode_mainline_end_s2c(Term)->
	Data = <<>>,
	<<1568:16, Data/binary>>.

%%
encode_delete_black_s2c(Term)->
	Roleid = Term#delete_black_s2c.bid,
	Data= <<Roleid:64>>,
	<<478:16, Data/binary>>.

%%
encode_treasure_storage_additem_s2c(Term)->
	Items=encode_list(Term#treasure_storage_additem_s2c.items, fun encode_tsi/1),
	Data = <<Items/binary>>,
	<<1316:16, Data/binary>>.

%%
encode_rank_loop_tower_num_s2c(Term)->
	Param=encode_list(Term#rank_loop_tower_num_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1436:16, Data/binary>>.

%%
encode_change_role_mall_integral_s2c(Term)->
	Charge_integral=Term#change_role_mall_integral_s2c.charge_integral,
	By_item_integral=Term#change_role_mall_integral_s2c.by_item_integral,
	Data = <<Charge_integral:32, By_item_integral:32>>,
	<<440:16, Data/binary>>.

%%
encode_spa_swimming_s2c(Term)->
	Name=encode_string(Term#spa_swimming_s2c.name),
	Bename=encode_string(Term#spa_swimming_s2c.bename),
	Remain=Term#spa_swimming_s2c.remain,
	Data = <<Name/binary, Bename/binary, Remain:32>>,
	<<1608:16, Data/binary>>.

%%
encode_change_country_transport_s2c(Term)->
	Tp_start=Term#change_country_transport_s2c.tp_start,
	Tp_stop=Term#change_country_transport_s2c.tp_stop,
	Data = <<Tp_start:32, Tp_stop:32>>,
	<<1644:16, Data/binary>>.

%%
encode_apply_guild_battle_c2s(Term)->
	Data = <<>>,
	<<1667:16, Data/binary>>.

%%
encode_guild_treasure_update_item_s2c(Term)->
	Treasuretype=Term#guild_treasure_update_item_s2c.treasuretype,
	Item=encode_gti(Term#guild_treasure_update_item_s2c.item),
	Data = <<Treasuretype:32, Item/binary>>,
	<<1207:16, Data/binary>>.

%%
encode_swap_item_c2s(Term)->
	Srcslot=Term#swap_item_c2s.srcslot,
	Desslot=Term#swap_item_c2s.desslot,
	Data = <<Srcslot:32, Desslot:32>>,
	<<126:16, Data/binary>>.

%%
encode_christmas_tree_hp_s2c(Term)->
	Curhp=Term#christmas_tree_hp_s2c.curhp,
	Maxhp=Term#christmas_tree_hp_s2c.maxhp,
	Data = <<Curhp:32, Maxhp:32>>,
	<<1742:16, Data/binary>>.

%%
encode_mainline_result_s2c(Term)->
	Chapter=Term#mainline_result_s2c.chapter,
	Stage=Term#mainline_result_s2c.stage,
	Difficulty=Term#mainline_result_s2c.difficulty,
	Result=Term#mainline_result_s2c.result,
	Reward=Term#mainline_result_s2c.reward,
	Bestscore=Term#mainline_result_s2c.bestscore,
	Score=Term#mainline_result_s2c.score,
	Duration=Term#mainline_result_s2c.duration,
	Data = <<Chapter:32, Stage:32, Difficulty:32, Result:32, Reward:32, Bestscore:32, Score:32, Duration:32>>,
	<<1569:16, Data/binary>>.

%%
encode_beads_pray_fail_s2c(Term)->
	Type=Term#beads_pray_fail_s2c.type,
	Data = <<Type:32>>,
	<<997:16, Data/binary>>.

%%
encode_explore_storage_init_c2s(Term)->
	Data = <<>>,
	<<960:16, Data/binary>>.

%%
encode_rank_level_s2c(Term)->
	Param=encode_list(Term#rank_level_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1430:16, 1:32, Data/binary>>.

%%
encode_pet_random_talent_s2c(Term)->
	Power=Term#pet_random_talent_s2c.power,
	Hitrate=Term#pet_random_talent_s2c.hitrate,
	Criticalrate=Term#pet_random_talent_s2c.criticalrate,
	Stamina=Term#pet_random_talent_s2c.stamina,
	Data = <<Power:32, Hitrate:32, Criticalrate:32, Stamina:32>>,
	<<1487:16, Data/binary>>.

%%
encode_venation_update_s2c(Term)->
	Venation=Term#venation_update_s2c.venation,
	Point=Term#venation_update_s2c.point,
	Attr=encode_list(Term#venation_update_s2c.attr, fun encode_k/1),
	Data = <<Venation:32, Point:32, Attr/binary>>,
	<<1281:16, Data/binary>>.

%%
encode_trade_role_decline_c2s(Term)->
	Roleid=Term#trade_role_decline_c2s.roleid,
	Data = <<Roleid:64>>,
	<<562:16, Data/binary>>.

%%
encode_guild_get_shop_item_s2c(Term)->
	Shoptype=Term#guild_get_shop_item_s2c.shoptype,
	Itemlist=encode_list(Term#guild_get_shop_item_s2c.itemlist, fun encode_gsi/1),
	Data = <<Shoptype:32, Itemlist/binary>>,
	<<1201:16, Data/binary>>.

%%
encode_explore_storage_info_s2c(Term)->
	Items=encode_list(Term#explore_storage_info_s2c.items, fun encode_tsi/1),
	Data = <<Items/binary>>,
	<<961:16, Data/binary>>.

%%
encode_treasure_transport_call_guild_help_result_s2c(Term)->
	Result=Term#treasure_transport_call_guild_help_result_s2c.result,
	Data = <<Result:32>>,
	<<1620:16, Data/binary>>.

%%
encode_set_trade_money_c2s(Term)->
	Moneytype=Term#set_trade_money_c2s.moneytype,
	Moneycount=Term#set_trade_money_c2s.moneycount,
	Data = <<Moneytype:32, Moneycount:32>>,
	<<563:16, Data/binary>>.

%%
encode_buy_mall_item_c2s(Term)->
	Mitemid=Term#buy_mall_item_c2s.mitemid,
	Count=Term#buy_mall_item_c2s.count,
	Price=encode_ip(Term#buy_mall_item_c2s.price),
	Type=Term#buy_mall_item_c2s.type,
	Data = <<Mitemid:32, Count:32, Price/binary, Type:32>>,
	<<431:16, Data/binary>>.

%%
encode_group_agree_c2s(Term)->
	Roleid=Term#group_agree_c2s.roleid,
	Data = <<Roleid:64>>,
	<<151:16, Data/binary>>.

%%
encode_add_black_s2c(Term)->
	Blackinfo=encode_br(Term#add_black_s2c.blackinfo),
	Data = <<Blackinfo/binary>>,
	<<498:16, Data/binary>>.

%%
encode_instance_info_s2c(Term)->
	Protoid=Term#instance_info_s2c.protoid,
	Times=Term#instance_info_s2c.times,
	Left_time=Term#instance_info_s2c.left_time,
	Data = <<Protoid:32, Times:32, Left_time:32>>,
	<<830:16, Data/binary>>.

%%
encode_end_block_training_c2s(Term)->
	Data = <<>>,
	<<512:16, Data/binary>>.

%%
encode_rank_fighting_force_s2c(Term)->
	Param=encode_list(Term#rank_fighting_force_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1430:16,3:32,Data/binary>>.

%%
encode_dragon_fight_state_s2c(Term)->
	Npcid=Term#dragon_fight_state_s2c.npcid,
	Faction=Term#dragon_fight_state_s2c.faction,
	State=Term#dragon_fight_state_s2c.state,
	Data = <<Npcid:64, Faction:32, State:32>>,
	<<1260:16, Data/binary>>.

%%
encode_loot_s2c(Term)->
	Packetid=Term#loot_s2c.packetid,
	Npcid=Term#loot_s2c.npcid,
	Posx=Term#loot_s2c.posx,
	Posy=Term#loot_s2c.posy,
	Data = <<Packetid:32, Npcid:64, Posx:32, Posy:32>>,
	<<105:16, Data/binary>>.

%%
encode_guild_member_pos_s2c(Term)->
	Posinfo=encode_list(Term#guild_member_pos_s2c.posinfo, fun encode_gmp/1),
	Data = <<Posinfo/binary>>,
	<<1249:16, Data/binary>>.

%%
encode_explore_storage_init_end_s2c(Term)->
	Data = <<>>,
	<<962:16, Data/binary>>.

%%
encode_stalls_search_s2c(Term)->
	Index=Term#stalls_search_s2c.index,
	Totalnum=Term#stalls_search_s2c.totalnum,
	Stalls=encode_list(Term#stalls_search_s2c.stalls, fun encode_a/1),
	Data = <<Index:32, Totalnum:32, Stalls/binary>>,
	<<1041:16, Data/binary>>.

%%
encode_chess_spirit_cast_skill_c2s(Term)->
	Skillid=Term#chess_spirit_cast_skill_c2s.skillid,
	Data = <<Skillid:32>>,
	<<1176:16, Data/binary>>.

%%
encode_honor_stores_buy_items_c2s(Term)->
	Type=Term#honor_stores_buy_items_c2s.type,
	Itemid=Term#honor_stores_buy_items_c2s.itemid,
	Count=Term#honor_stores_buy_items_c2s.count,
	Data = <<Type:32, Itemid:32, Count:32>>,
	<<1821:16, Data/binary>>.

%%
encode_arrange_items_c2s(Term)->
	Type=Term#arrange_items_c2s.type,
	Data = <<Type:32>>,
	<<130:16, Data/binary>>.

%%
encode_server_treasure_transport_start_s2c(Term)->
	Left_time=Term#server_treasure_transport_start_s2c.left_time,
	Data = <<Left_time:32>>,
	<<1554:16, Data/binary>>.



%%
encode_venation_shareexp_update_s2c(Term)->
	Remaintime=Term#venation_shareexp_update_s2c.remaintime,
	Totalexp=Term#venation_shareexp_update_s2c.totalexp,
	Data = <<Remaintime:32, Totalexp:64>>,
	<<1282:16, Data/binary>>.

%%
encode_update_pet_skill_slot_s2c(Term)->
	Petid=Term#update_pet_skill_slot_s2c.petid,
	Slot=encode_psll(Term#update_pet_skill_slot_s2c.slot),
	Data = <<Petid:64, Slot/binary>>,
	<<927:16, Data/binary>>.

%%
encode_group_accept_c2s(Term)->
	Roleid=Term#group_accept_c2s.roleid,
	Data = <<Roleid:64>>,
	<<154:16, Data/binary>>.

%%
encode_recruite_query_s2c(Term)->
	Instance=Term#recruite_query_s2c.instance,
	Rec_infos=encode_list(Term#recruite_query_s2c.rec_infos, fun encode_ri/1),
	Role_rec_infos=encode_list(Term#recruite_query_s2c.role_rec_infos, fun encode_rr/1),
	Usedtimes=Term#recruite_query_s2c.usedtimes,
	Isaddtime=Term#recruite_query_s2c.isaddtime,
	Lefttime=Term#recruite_query_s2c.lefttime,
	Data = <<Instance:32, Rec_infos/binary, Role_rec_infos/binary, Usedtimes:32, Isaddtime:32, Lefttime:32>>,
	<<170:16, Data/binary>>.

%%
encode_rank_talent_score_s2c(Term)->
	Param=encode_list(Term#rank_talent_score_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1430:16, 12:32, Data/binary>>.
%%【小五加】
encode_rank_pet_fighting_force_s2c(Term)->
	Param=encode_list(Term#rank_talent_score_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1430:16, 10:32, Data/binary>>.
%%【小五加】
encode_rank_quality_value_s2c(Term)->
	Param=encode_list(Term#rank_talent_score_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1430:16, 8:32, Data/binary>>.
%%【小五加】
encode_rank_growth_s2c(Term)->
	Param=encode_list(Term#rank_talent_score_s2c.param, fun encode_rk/1),
	Data = <<Param/binary>>,
	<<1430:16, 11:32, Data/binary>>.
%%
encode_end_block_training_s2c(Term)->
	Roleid=Term#end_block_training_s2c.roleid,
	Data = <<Roleid:64>>,
	<<513:16, Data/binary>>.

%%
encode_npc_storage_items_s2c(Term)->
	Npcid=Term#npc_storage_items_s2c.npcid,
	Item_attrs=encode_list(Term#npc_storage_items_s2c.item_attrs, fun encode_i/1),
	Data = <<Npcid:64, Item_attrs/binary>>,
	<<129:16, Data/binary>>.

%%
encode_init_signature_s2c(Term)->
	Signature=encode_string(Term#init_signature_s2c.signature),
	Data = <<Signature/binary>>,
	<<471:16, Data/binary>>.

%%
encode_explore_storage_getitem_c2s(Term)->
	Slot=Term#explore_storage_getitem_c2s.slot,
	Itemsign=Term#explore_storage_getitem_c2s.itemsign,
	Data = <<Slot:32, Itemsign:32>>,
	<<963:16, Data/binary>>.

%%
encode_goals_init_c2s(Term)->
	Data = <<>>,
	<<644:16, Data/binary>>.

%%
encode_inspect_faild_s2c(Term)->
	Errno=Term#inspect_faild_s2c.errno,
	Data = <<Errno:32>>,
	<<405:16, Data/binary>>.

%%
encode_country_change_crime_c2s(Term)->
	Name=encode_string(Term#country_change_crime_c2s.name),
	Type=Term#country_change_crime_c2s.type,
	Data = <<Name/binary, Type:32>>,
	<<1649:16, Data/binary>>.

%%
encode_facebook_bind_check_result_s2c(Term)->
	Fbid=encode_string(Term#facebook_bind_check_result_s2c.fbid),
	Data = <<Fbid/binary>>,
	<<1446:16, Data/binary>>.

%%
encode_battle_leave_c2s(Term)->
	Data = <<>>,
	<<822:16, Data/binary>>.

%%
encode_yhzq_battle_self_join_s2c(Term)->
	Redroles=encode_list(Term#yhzq_battle_self_join_s2c.redroles, fun encode_tr/1),
	Blueroles=encode_list(Term#yhzq_battle_self_join_s2c.blueroles, fun encode_tr/1),
	Battleid=Term#yhzq_battle_self_join_s2c.battleid,
	Lefttime=Term#yhzq_battle_self_join_s2c.lefttime,
	Data = <<Redroles/binary, Blueroles/binary, Battleid:32, Lefttime:32>>,
	<<1114:16, Data/binary>>.

%%
encode_loop_tower_enter_s2c(Term)->
	Layer=Term#loop_tower_enter_s2c.layer,
	Trans=Term#loop_tower_enter_s2c.trans,
	Data = <<Layer:32, Trans:32>>,
	<<654:16, Data/binary>>.

%%
encode_guild_shop_buy_item_c2s(Term)->
	Shoptype=Term#guild_shop_buy_item_c2s.shoptype,
	Id=Term#guild_shop_buy_item_c2s.id,
	Itemid=Term#guild_shop_buy_item_c2s.itemid,
	Count=Term#guild_shop_buy_item_c2s.count,
	Data = <<Shoptype:32, Id:32, Itemid:32, Count:32>>,
	<<1202:16, Data/binary>>.

%%
encode_monster_section_update_s2c(Term)->
	Mapid=Term#monster_section_update_s2c.mapid,
	Section=Term#monster_section_update_s2c.section,
	Data = <<Mapid:32, Section:32>>,
	<<1823:16, Data/binary>>.

%%
encode_server_treasure_transport_end_s2c(Term)->
	Data = <<>>,
	<<1555:16, Data/binary>>.

%%
encode_rank_mail_line_s2c(Term)->
	Chapter=Term#rank_mail_line_s2c.chapter,
	Festival=Term#rank_mail_line_s2c.festival,
	Difficulty=Term#rank_mail_line_s2c.difficulty,
	Param=encode_list(Term#rank_mail_line_s2c.param, fun encode_rk/1),
	Data = <<Chapter:32, Festival:32, Difficulty:32, Param/binary>>,
	<<1430:16, 21:32, Data/binary>>.

%%
encode_lottery_lefttime_s2c(Term)->
	Leftseconds=Term#lottery_lefttime_s2c.leftseconds,
	Data = <<Leftseconds:32>>,
	<<501:16, Data/binary>>.

%%
encode_loot_query_c2s(Term)->
	Packetid=Term#loot_query_c2s.packetid,
	Data = <<Packetid:32>>,
	<<106:16, Data/binary>>.

%%
encode_country_leader_online_s2c(Term)->
	Post=Term#country_leader_online_s2c.post,
	Postindex=Term#country_leader_online_s2c.postindex,
	Name=encode_string(Term#country_leader_online_s2c.name),
	Data = <<Post:32, Postindex:32, Name/binary>>,
	<<1650:16, Data/binary>>.

%%
encode_set_trade_item_c2s(Term)->
	Trade_slot=Term#set_trade_item_c2s.trade_slot,
	Package_slot=Term#set_trade_item_c2s.package_slot,
	Data = <<Trade_slot:32, Package_slot:32>>,
	<<564:16, Data/binary>>.

%%
encode_guild_mastercall_s2c(Term)->
	Posting=Term#guild_mastercall_s2c.posting,
	Name=encode_string(Term#guild_mastercall_s2c.name),
	Lineid=Term#guild_mastercall_s2c.lineid,
	Mapid=Term#guild_mastercall_s2c.mapid,
	Posx=Term#guild_mastercall_s2c.posx,
	Posy=Term#guild_mastercall_s2c.posy,
	Reasonid=Term#guild_mastercall_s2c.reasonid,
	Data = <<Posting:32, Name/binary, Lineid:32, Mapid:32, Posx:32, Posy:32, Reasonid:32>>,
	<<1245:16, Data/binary>>.

%%
encode_block_s2c(Term)->
	Type=Term#block_s2c.type,
	Time=Term#block_s2c.time,
	Data = <<Type:32, Time:32>>,
	<<421:16, Data/binary>>.

%%
encode_other_login_s2c(Term)->
	Data = <<>>,
	<<420:16, Data/binary>>.

%%
encode_enum_exchange_item_c2s(Term)->
	Npcid=Term#enum_exchange_item_c2s.npcid,
	Data = <<Npcid:64>>,
	<<1001:16, Data/binary>>.

%%
encode_publish_guild_quest_c2s(Term)->
	Data = <<>>,
	<<1208:16, Data/binary>>.

%%
encode_explore_storage_getallitems_c2s(Term)->
	Data = <<>>,
	<<964:16, Data/binary>>.

%%
encode_item_identify_opt_result_s2c(Term)->
	Itemtmpid=Term#item_identify_opt_result_s2c.itemtmpid,
	Data = <<Itemtmpid:32>>,
	<<1488:16, Data/binary>>.

%%
encode_role_treasure_transport_time_check_c2s(Term)->
	Data = <<>>,
	<<1556:16, Data/binary>>.

%%
encode_lottery_leftcount_s2c(Term)->
	Leftcount=Term#lottery_leftcount_s2c.leftcount,
	Data = <<Leftcount:32>>,
	<<502:16, Data/binary>>.

%%
encode_yhzq_battle_other_join_s2c(Term)->
	Role=encode_tr(Term#yhzq_battle_other_join_s2c.role),
	Camp=Term#yhzq_battle_other_join_s2c.camp,
	Data = <<Role/binary, Camp:32>>,
	<<1115:16, Data/binary>>.

%%
encode_role_rename_c2s(Term)->
	Slot=Term#role_rename_c2s.slot,
	Newname=encode_string(Term#role_rename_c2s.newname),
	Data = <<Slot:32, Newname/binary>>,
	<<55:16, Data/binary>>.

%%
encode_group_decline_c2s(Term)->
	Roleid=Term#group_decline_c2s.roleid,
	Data = <<Roleid:64>>,
	<<155:16, Data/binary>>.

%%
encode_explore_storage_updateitem_s2c(Term)->
	Itemlist=encode_list(Term#explore_storage_updateitem_s2c.itemlist, fun encode_tsi/1),
	Data = <<Itemlist/binary>>,
	<<965:16, Data/binary>>.

%%
encode_venation_active_point_start_c2s(Term)->
	Venation=Term#venation_active_point_start_c2s.venation,
	Point=Term#venation_active_point_start_c2s.point,
	Itemnum=Term#venation_active_point_start_c2s.itemnum,
	Data = <<Venation:32, Point:32, Itemnum:32>>,
	<<1283:16, Data/binary>>.

%%
encode_inspect_s2c(Term)->
	Roleid=Term#inspect_s2c.roleid,
	Rolename=encode_string(Term#inspect_s2c.rolename),
	Classtype=Term#inspect_s2c.classtype,
	Gender=Term#inspect_s2c.gender,
	Guildname=encode_string(Term#inspect_s2c.guildname),
	Level=Term#inspect_s2c.level,
	Cloth=Term#inspect_s2c.cloth,
	Arm=Term#inspect_s2c.arm,
	Maxhp=Term#inspect_s2c.maxhp,
	Maxmp=Term#inspect_s2c.maxmp,
	Power=Term#inspect_s2c.power,
	Magic_defense=Term#inspect_s2c.magic_defense,
	Range_defense=Term#inspect_s2c.range_defense,
	Melee_defense=Term#inspect_s2c.melee_defense,
	Stamina=Term#inspect_s2c.stamina,
	Strength=Term#inspect_s2c.strength,
	Intelligence=Term#inspect_s2c.intelligence,
	Agile=Term#inspect_s2c.agile,
	Hitrate=Term#inspect_s2c.hitrate,
	Criticalrate=Term#inspect_s2c.criticalrate,
	Criticaldamage=Term#inspect_s2c.criticaldamage,
	Dodge=Term#inspect_s2c.dodge,
	Toughness=Term#inspect_s2c.toughness,
	Meleeimmunity=Term#inspect_s2c.meleeimmunity,
	Rangeimmunity=Term#inspect_s2c.rangeimmunity,
	Magicimmunity=Term#inspect_s2c.magicimmunity,
	Imprisonment_resist=Term#inspect_s2c.imprisonment_resist,
	Silence_resist=Term#inspect_s2c.silence_resist,
	Daze_resist=Term#inspect_s2c.daze_resist,
	Poison_resist=Term#inspect_s2c.poison_resist,
	Normal_resist=Term#inspect_s2c.normal_resist,
	Vip_tag=Term#inspect_s2c.vip_tag,
	Items_attr=encode_list(Term#inspect_s2c.items_attr, fun encode_i/1),
	Guildpost=Term#inspect_s2c.guildpost,
	Exp=Term#inspect_s2c.exp,
	%%Levelupexp=Term#inspect_s2c.levelupexp,
	Levelupexp=round(Term#inspect_s2c.levelupexp),%%角色超过一百级后Levelupexp为小数会报错  于是乎加round函数对其取整  成功！！【xiaowu】
	Soulpower=Term#inspect_s2c.soulpower,
	Maxsoulpower=Term#inspect_s2c.maxsoulpower,
	Guildlid=Term#inspect_s2c.guildlid,
	Guildhid=Term#inspect_s2c.guildhid,
	Cur_designation=encode_int32_list(Term#inspect_s2c.cur_designation),
	Role_crime=Term#inspect_s2c.role_crime,
	Fighting_force=Term#inspect_s2c.fighting_force,
	Curhp=Term#inspect_s2c.curhp,
	Curmp=Term#inspect_s2c.curmp,
	Data = <<Roleid:64, Rolename/binary, Classtype:32, Gender:32, Guildname/binary, Level:32, Cloth:32, Arm:32, Maxhp:32, Maxmp:32, Power:32, Magic_defense:32, Range_defense:32, Melee_defense:32, Stamina:32, Strength:32, Intelligence:32, Agile:32, Hitrate:32, Criticalrate:32, Criticaldamage:32, Dodge:32, Toughness:32, Meleeimmunity:32, Rangeimmunity:32, Magicimmunity:32, Imprisonment_resist:32, Silence_resist:32, Daze_resist:32, Poison_resist:32, Normal_resist:32, Vip_tag:32, Items_attr/binary, Guildpost:32, Exp:64, Levelupexp:64, Soulpower:32, Maxsoulpower:32, Guildlid:32, Guildhid:32, Cur_designation/binary, Role_crime:32, Fighting_force:32, Curhp:32, Curmp:32>>,
	<<404:16, Data/binary>>.

%%
encode_guild_battle_score_update_s2c(Term)->
	Index=Term#guild_battle_score_update_s2c.index,
	Score=Term#guild_battle_score_update_s2c.score,
	Data = <<Index:32, Score:32>>,
	<<1659:16, Data/binary>>.

%%
encode_role_respawn_c2s(Term)->
	Type=Term#role_respawn_c2s.type,
	Data = <<Type:32>>,
	<<419:16, Data/binary>>.

%%
encode_guild_battle_status_update_s2c(Term)->
	State=Term#guild_battle_status_update_s2c.state,
	Lefttime=Term#guild_battle_status_update_s2c.lefttime,
	Guildindex=Term#guild_battle_status_update_s2c.guildindex,
	Roleid=Term#guild_battle_status_update_s2c.roleid,
	Rolename=encode_string(Term#guild_battle_status_update_s2c.rolename),
	Roleclass=Term#guild_battle_status_update_s2c.roleclass,
	Rolegender=Term#guild_battle_status_update_s2c.rolegender,
	Data = <<State:32, Lefttime:32, Guildindex:32, Roleid:64, Rolename/binary, Roleclass:32, Rolegender:32>>,
	<<1660:16, Data/binary>>.

%%
encode_enum_exchange_item_fail_s2c(Term)->
	Reason=Term#enum_exchange_item_fail_s2c.reason,
	Data = <<Reason:32>>,
	<<1002:16, Data/binary>>.

%%
encode_mainline_reward_c2s(Term)->
	Chapter=Term#mainline_reward_c2s.chapter,
	Stage=Term#mainline_reward_c2s.stage,
	Reward=Term#mainline_reward_c2s.reward,
	Data = <<Chapter:32, Stage:32, Reward:32>>,
	<<1570:16, Data/binary>>.

%%
encode_questgiver_accept_quest_c2s(Term)->
	Npcid=Term#questgiver_accept_quest_c2s.npcid,
	Questid=Term#questgiver_accept_quest_c2s.questid,
	Data = <<Npcid:64, Questid:32>>,
	<<87:16, Data/binary>>.

%%
encode_recruite_cancel_s2c(Term)->
	Reason=Term#recruite_cancel_s2c.reason,
	Data = <<Reason:32>>,
	<<171:16, Data/binary>>.

%%
encode_add_friend_failed_s2c(Term)->
	Reason=Term#add_friend_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<484:16, Data/binary>>.

%%
encode_spa_start_notice_s2c(Term)->
	Level=Term#spa_start_notice_s2c.level,
	Data = <<Level:32>>,
	<<1600:16, Data/binary>>.

%%
encode_yhzq_battle_update_s2c(Term)->
	Camp=Term#yhzq_battle_update_s2c.camp,
	Role=encode_tr(Term#yhzq_battle_update_s2c.role),
	Data = <<Camp:32, Role/binary>>,
	<<1116:16, Data/binary>>.

%%
encode_server_version_s2c(Term)->
	V=encode_string(Term#server_version_s2c.v),
	Data = <<V/binary>>,
	<<1631:16, Data/binary>>.

%%
encode_loot_response_s2c(Term)->
	Packetid=Term#loot_response_s2c.packetid,
	Slots=encode_list(Term#loot_response_s2c.slots, fun encode_l/1),
	Data = <<Packetid:32, Slots/binary>>,
	<<107:16, Data/binary>>.

%%
encode_venation_active_point_opt_s2c(Term)->
	Reason=Term#venation_active_point_opt_s2c.reason,
	Data = <<Reason:32>>,
	<<1284:16, Data/binary>>.

%%
encode_stalls_search_item_s2c(Term)->
	Index=Term#stalls_search_item_s2c.index,
	Totalnum=Term#stalls_search_item_s2c.totalnum,
	Serchitems=encode_list(Term#stalls_search_item_s2c.serchitems, fun encode_ssi/1),
	Data = <<Index:32, Totalnum:32, Serchitems/binary>>,
	<<1045:16, Data/binary>>.

%%
encode_explore_storage_additem_s2c(Term)->
	Items=encode_list(Term#explore_storage_additem_s2c.items, fun encode_tsi/1),
	Data = <<Items/binary>>,
	<<966:16, Data/binary>>.

%%
encode_chess_spirit_update_power_s2c(Term)->
	Newpower=Term#chess_spirit_update_power_s2c.newpower,
	Data = <<Newpower:32>>,
	<<1172:16, Data/binary>>.

%%
encode_tangle_records_c2s(Term)->
	Year=Term#tangle_records_c2s.year,
	Month=Term#tangle_records_c2s.month,
	Day=Term#tangle_records_c2s.day,
	Type=Term#tangle_records_c2s.type,
	Data = <<Year:32, Month:32, Day:32, Type:32>>,
	<<834:16, Data/binary>>.

%%
encode_tangle_remove_s2c(Term)->
	Roleid=Term#tangle_remove_s2c.roleid,
	Data = <<Roleid:64>>,
	<<825:16, Data/binary>>.

%%
encode_group_kickout_c2s(Term)->
	Roleid=Term#group_kickout_c2s.roleid,
	Data = <<Roleid:64>>,
	<<156:16, Data/binary>>.

%%
encode_guild_rename_c2s(Term)->
	Slot=Term#guild_rename_c2s.slot,
	Newname=encode_string(Term#guild_rename_c2s.newname),
	Data = <<Slot:32, Newname/binary>>,
	<<56:16, Data/binary>>.

%%
encode_dragon_fight_num_c2s(Term)->
	Npcid=Term#dragon_fight_num_c2s.npcid,
	Data = <<Npcid:64>>,
	<<1261:16, Data/binary>>.

%%
encode_update_guild_quest_info_s2c(Term)->
	Lefttime=Term#update_guild_quest_info_s2c.lefttime,
	Data = <<Lefttime:32>>,
	<<1209:16, Data/binary>>.

%%
encode_role_recruite_c2s(Term)->
	Instanceid=Term#role_recruite_c2s.instanceid,
	Data = <<Instanceid:32>>,
	<<172:16, Data/binary>>.

%%
encode_mainline_reward_success_s2c(Term)->
	Chapter=Term#mainline_reward_success_s2c.chapter,
	Stage=Term#mainline_reward_success_s2c.stage,
	Data = <<Chapter:32, Stage:32>>,
	<<1578:16, Data/binary>>.

%%
encode_lottery_clickslot_c2s(Term)->
	Clickslot=Term#lottery_clickslot_c2s.clickslot,
	Data = <<Clickslot:32>>,
	<<504:16, Data/binary>>.

%%
encode_spa_request_spalist_c2s(Term)->
	Data = <<>>,
	<<1601:16, Data/binary>>.

%%
encode_change_country_notice_c2s(Term)->
	Notice=encode_string(Term#change_country_notice_c2s.notice),
	Data = <<Notice/binary>>,
	<<1641:16, Data/binary>>.

%%
%%创建帮会
encode_guild_create_c2s(Term)->
	Name=encode_string(Term#guild_create_c2s.name),
	Notice=encode_string(Term#guild_create_c2s.notice),
	Type=Term#guild_create_c2s.type,
	Data = <<Name/binary, Notice/binary, Type:32>>,
	<<360:16, Data/binary>>.
%%
encode_venation_active_point_end_c2s(Term)->
	Data = <<>>,
	<<1285:16, Data/binary>>.

%%
encode_becare_friend_s2c(Term)->
	Fn=encode_string(Term#becare_friend_s2c.fn),
	Fid=Term#becare_friend_s2c.fid,
	Data = <<Fn/binary, Fid:64>>,
	<<485:16, Data/binary>>.

%%
encode_quest_list_add_s2c(Term)->
	Quest=encode_q(Term#quest_list_add_s2c.quest),
	Data = <<Quest/binary>>,
	<<83:16, Data/binary>>.

%%
encode_explore_storage_delitem_s2c(Term)->
	Start=Term#explore_storage_delitem_s2c.start,
	Length=Term#explore_storage_delitem_s2c.length,
	Data = <<Start:32, Length:32>>,
	<<967:16, Data/binary>>.

%%
encode_yhzq_battle_remove_s2c(Term)->
	Camp=Term#yhzq_battle_remove_s2c.camp,
	Roleid=Term#yhzq_battle_remove_s2c.roleid,
	Data = <<Camp:32, Roleid:64>>,
	<<1117:16, Data/binary>>.

%%
encode_venation_advanced_start_c2s(Term)->
	Venationid=Term#venation_advanced_start_c2s.venationid,
	Bone=Term#venation_advanced_start_c2s.bone,
	Useitem=Term#venation_advanced_start_c2s.useitem,
	Type=Term#venation_advanced_start_c2s.type,
	Data = <<Venationid:32, Bone:32, Useitem:32, Type:32>>,
	<<1276:16, Data/binary>>.

%%
encode_guild_disband_c2s(Term)->
	Data = <<>>,
	<<361:16, Data/binary>>.


%%
encode_mainline_lefttime_s2c(Term)->
	Chapter=Term#mainline_lefttime_s2c.chapter,
	Stage=Term#mainline_lefttime_s2c.stage,
	Lefttime=Term#mainline_lefttime_s2c.lefttime,
	Data = <<Chapter:32, Stage:32, Lefttime:32>>,
	<<1571:16, Data/binary>>.

%%
encode_role_recruite_cancel_c2s(Term)->
	Data = <<>>,
	<<173:16, Data/binary>>.

%%
encode_arrange_items_s2c(Term)->
	Type=Term#arrange_items_s2c.type,
	Items=encode_list(Term#arrange_items_s2c.items, fun encode_ic/1),
	Lowids=encode_int32_list(Term#arrange_items_s2c.lowids),
	Highids=encode_int32_list(Term#arrange_items_s2c.highids),
	Data = <<Type:32, Items/binary, Lowids/binary, Highids/binary>>,
	<<131:16, Data/binary>>.

%%
encode_stall_log_add_s2c(Term)->
	Stallid=Term#stall_log_add_s2c.stallid,
	Logs=encode_string_list(Term#stall_log_add_s2c.logs),
	Data = <<Stallid:64, Logs/binary>>,
	<<1042:16, Data/binary>>.

%%
encode_rename_result_s2c(Term)->
	Errno=Term#rename_result_s2c.errno,
	Data = <<Errno:32>>,
	<<57:16, Data/binary>>.

%%
encode_guild_member_invite_c2s(Term)->
	Name=encode_string(Term#guild_member_invite_c2s.name),
	Data = <<Name/binary>>,
	<<362:16, Data/binary>>.

%%
encode_enum_exchange_item_s2c(Term)->
	Npcid=Term#enum_exchange_item_s2c.npcid,
	Dhs=encode_list(Term#enum_exchange_item_s2c.dhs, fun encode_dh/1),
	Data = <<Npcid:64, Dhs/binary>>,
	<<1003:16, Data/binary>>.

%%
encode_loot_pick_c2s(Term)->
	Packetid=Term#loot_pick_c2s.packetid,
	Slot_num=Term#loot_pick_c2s.slot_num,
	Data = <<Packetid:32, Slot_num:32>>,
	<<108:16, Data/binary>>.

%%
encode_quest_quit_c2s(Term)->
	Questid=Term#quest_quit_c2s.questid,
	Data = <<Questid:32>>,
	<<88:16, Data/binary>>.

%%
encode_pet_evolution_c2s(Term)->
	Petid=Term#pet_evolution_c2s.petid,
	Itemslot=Term#pet_evolution_c2s.itemslot,
	Data = <<Petid:64, Itemslot:32>>,
	<<1489:16, Data/binary>>.

%%
encode_country_leader_get_itmes_c2s(Term)->
	Data = <<>>,
	<<1651:16, Data/binary>>.

%%
encode_role_recruite_cancel_s2c(Term)->
	Reason=Term#role_recruite_cancel_s2c.reason,
	Data = <<Reason:32>>,
	<<174:16, Data/binary>>.

%%
encode_lottery_querystatus_c2s(Term)->
	Data = <<>>,
	<<509:16, Data/binary>>.

%%
encode_tangle_records_s2c(Term)->
	Year=Term#tangle_records_s2c.year,
	Month=Term#tangle_records_s2c.month,
	Day=Term#tangle_records_s2c.day,
	Type=Term#tangle_records_s2c.type,
	Totalbattle=Term#tangle_records_s2c.totalbattle,
	Mybattleid=encode_int32_list(Term#tangle_records_s2c.mybattleid),
	Data = <<Year:32, Month:32, Day:32, Type:32, Totalbattle:32, Mybattleid/binary>>,
	<<833:16, Data/binary>>.

%%
encode_lottery_clickslot_s2c(Term)->
	Lottery_slot=Term#lottery_clickslot_s2c.lottery_slot,
	Item=encode_lti(Term#lottery_clickslot_s2c.item),
	Data = <<Lottery_slot:32, Item/binary>>,
	<<505:16, Data/binary>>.

%%
encode_questgiver_complete_quest_c2s(Term)->
	Questid=Term#questgiver_complete_quest_c2s.questid,
	Npcid=Term#questgiver_complete_quest_c2s.npcid,
	Choiceslot=Term#questgiver_complete_quest_c2s.choiceslot,
	Data = <<Questid:32, Npcid:64, Choiceslot:32>>,
	<<89:16, Data/binary>>.

%%
encode_designation_init_s2c(Term)->
	Designationid=encode_int32_list(Term#designation_init_s2c.designationid),
	Data = <<Designationid/binary>>,
	<<1540:16, Data/binary>>.

%%
encode_loot_remove_item_s2c(Term)->
	Packetid=Term#loot_remove_item_s2c.packetid,
	Slot_num=Term#loot_remove_item_s2c.slot_num,
	Data = <<Packetid:32, Slot_num:32>>,
	<<109:16, Data/binary>>.

%%
encode_add_signature_c2s(Term)->
	Signature=encode_string(Term#add_signature_c2s.signature),
	Data = <<Signature/binary>>,
	<<472:16, Data/binary>>.

%%
encode_cancel_buff_c2s(Term)->
	Buffid=Term#cancel_buff_c2s.buffid,
	Data = <<Buffid:32>>,
	<<112:16, Data/binary>>.

%%
encode_goals_reward_c2s(Term)->
	Days=Term#goals_reward_c2s.days,
	Part=Term#goals_reward_c2s.part,
	Data = <<Days:32, Part:32>>,
	<<642:16, Data/binary>>.

%%
encode_guild_member_decline_c2s(Term)->
	Roleid=Term#guild_member_decline_c2s.roleid,
	Data = <<Roleid:64>>,
	<<363:16, Data/binary>>.

%%
encode_explore_storage_opt_s2c(Term)->
	Code=Term#explore_storage_opt_s2c.code,
	Data = <<Code:32>>,
	<<968:16, Data/binary>>.

%%
encode_dragon_fight_faction_s2c(Term)->
	Newfaction=Term#dragon_fight_faction_s2c.newfaction,
	Data = <<Newfaction:32>>,
	<<1258:16, Data/binary>>.

%%
encode_cancel_trade_c2s(Term)->
	Data = <<>>,
	<<565:16, Data/binary>>.

%%
encode_quest_statu_update_s2c(Term)->
	Quests=encode_q(Term#quest_statu_update_s2c.quests),
	Data = <<Quests/binary>>,
	<<84:16, Data/binary>>.

%%
encode_group_apply_s2c(Term)->
	Roleid=Term#group_apply_s2c.roleid,
	Username=encode_string(Term#group_apply_s2c.username),
	Data = <<Roleid:64, Username/binary>>,
	<<166:16, Data/binary>>.

%%
encode_exchange_item_c2s(Term)->
	Npcid=Term#exchange_item_c2s.npcid,
	Item_clsid=Term#exchange_item_c2s.item_clsid,
	Count=Term#exchange_item_c2s.count,
	Slots=encode_list(Term#exchange_item_c2s.slots, fun encode_l/1),
	Data = <<Npcid:64, Item_clsid:32, Count:32, Slots/binary>>,
	<<1004:16, Data/binary>>.

%%
encode_group_setleader_c2s(Term)->
	Roleid=Term#group_setleader_c2s.roleid,
	Data = <<Roleid:64>>,
	<<157:16, Data/binary>>.

%%
encode_welfare_gold_exchange_init_c2s(Term)->
	Data = <<>>,
	<<1463:16, Data/binary>>.

%%
encode_pet_forget_skill_c2s(Term)->
	Petid=Term#pet_forget_skill_c2s.petid,
	Slot=Term#pet_forget_skill_c2s.slot,
	Skillid=Term#pet_forget_skill_c2s.skillid,
	Data = <<Petid:64, Slot:32, Skillid:32>>,
	<<919:16, Data/binary>>.

%%
encode_use_item_c2s(Term)->
	Slot=Term#use_item_c2s.slot,
	Data = <<Slot:32>>,
	<<39:16, Data/binary>>.

%%
encode_stall_opt_result_s2c(Term)->
	Errno=Term#stall_opt_result_s2c.errno,
	Data = <<Errno:32>>,
	<<1043:16, Data/binary>>.

%%
encode_feedback_info_ret_s2c(Term)->
	Reason=Term#feedback_info_ret_s2c.reason,
	Data = <<Reason:32>>,
	<<418:16, Data/binary>>.

%%
encode_buy_honor_item_error_s2c(Term)->
	Error=Term#buy_honor_item_error_s2c.error,
	Data = <<Error:32>>,
	<<1822:16, Data/binary>>.

%%
encode_venation_advanced_opt_result_s2c(Term)->
	Result=Term#venation_advanced_opt_result_s2c.result,
	Bone=Term#venation_advanced_opt_result_s2c.bone,
	Data = <<Result:32, Bone:32>>,
	<<1278:16, Data/binary>>.

%%
encode_instance_leader_join_s2c(Term)->
	Instanceid=Term#instance_leader_join_s2c.instanceid,
	Data = <<Instanceid:32>>,
	<<840:16, Data/binary>>.

%%
encode_pet_explore_info_c2s(Term)->
	Petid=Term#pet_explore_info_c2s.petid,
	Data = <<Petid:64>>,
	<<970:16, Data/binary>>.

%%
encode_spa_request_spalist_s2c(Term)->
	Spas=encode_list(Term#spa_request_spalist_s2c.spas, fun encode_spa/1),
	Data = <<Spas/binary>>,
	<<1602:16, Data/binary>>.

%%
encode_guild_member_accept_c2s(Term)->
	Roleid=Term#guild_member_accept_c2s.roleid,
	Data = <<Roleid:64>>,
	<<364:16, Data/binary>>.

%%
encode_yhzq_zone_info_s2c(Term)->
	Zonelist=encode_list(Term#yhzq_zone_info_s2c.zonelist, fun encode_zoneinfo/1),
	Data = <<Zonelist/binary>>,
	<<1111:16, Data/binary>>.

%%
encode_get_friend_signature_c2s(Term)->
	Fn=encode_string(Term#get_friend_signature_c2s.fn),
	Data = <<Fn/binary>>,
	<<473:16, Data/binary>>.

%%
encode_loot_release_s2c(Term)->
	Packetid=Term#loot_release_s2c.packetid,
	Data = <<Packetid:32>>,
	<<110:16, Data/binary>>.

%%
encode_lottery_clickslot_failed_s2c(Term)->
	Reason=Term#lottery_clickslot_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<508:16, Data/binary>>.

%%
encode_designation_update_s2c(Term)->
	Designationid=encode_int32_list(Term#designation_update_s2c.designationid),
	Data = <<Designationid/binary>>,
	<<1541:16, Data/binary>>.

%%
encode_update_guild_apply_state_s2c(Term)->
	Guildlid=Term#update_guild_apply_state_s2c.guildlid,
	Guildhid=Term#update_guild_apply_state_s2c.guildhid,
	Applyflag=Term#update_guild_apply_state_s2c.applyflag,
	Data = <<Guildlid:32, Guildhid:32, Applyflag:32>>,
	<<1210:16, Data/binary>>.

%%
encode_gift_card_apply_s2c(Term)->
	Errno=Term#gift_card_apply_s2c.errno,
	Data = <<Errno:32>>,
	<<1163:16, Data/binary>>.

%%
encode_guild_shop_update_item_s2c(Term)->
	Shoptype=Term#guild_shop_update_item_s2c.shoptype,
	Item=encode_gsi(Term#guild_shop_update_item_s2c.item),
	Data = <<Shoptype:32, Item/binary>>,
	<<1215:16, Data/binary>>.

%%
encode_auto_equip_item_c2s(Term)->
	Slot=Term#auto_equip_item_c2s.slot,
	Data = <<Slot:32>>,
	<<40:16, Data/binary>>.

%%
encode_mainline_remain_monsters_info_s2c(Term)->
	Kill_num=Term#mainline_remain_monsters_info_s2c.kill_num,
	Remain_num=Term#mainline_remain_monsters_info_s2c.remain_num,
	Chapter=Term#mainline_remain_monsters_info_s2c.chapter,
	Stage=Term#mainline_remain_monsters_info_s2c.stage,
	Data = <<Kill_num:32, Remain_num:32, Chapter:32, Stage:32>>,
	<<1573:16, Data/binary>>.



%%
encode_mainline_timeout_c2s(Term)->
	Chapter=Term#mainline_timeout_c2s.chapter,
	Stage=Term#mainline_timeout_c2s.stage,
	Data = <<Chapter:32, Stage:32>>,
	<<1572:16, Data/binary>>.

%%
encode_inspect_designation_s2c(Term)->
	Roleid=Term#inspect_designation_s2c.roleid,
	Designationid=encode_int32_list(Term#inspect_designation_s2c.designationid),
	Data = <<Roleid:64, Designationid/binary>>,
	<<1542:16, Data/binary>>.

%%
encode_instance_leader_join_c2s(Term)->
	Data = <<>>,
	<<841:16, Data/binary>>.

%%
encode_item_identify_error_s2c(Term)->
	Error=Term#item_identify_error_s2c.error,
	Data = <<Error:32>>,
	<<1481:16, Data/binary>>.

%%
encode_guild_member_apply_c2s(Term)->
	Guildlid=Term#guild_member_apply_c2s.guildlid,
	Guildhid=Term#guild_member_apply_c2s.guildhid,
	Data = <<Guildlid:32, Guildhid:32>>,
	<<365:16, Data/binary>>.

%%
encode_lottery_otherslot_s2c(Term)->
	Items=encode_list(Term#lottery_otherslot_s2c.items, fun encode_lti/1),
	Data = <<Items/binary>>,
	<<506:16, Data/binary>>.

%%
encode_pet_explore_info_s2c(Term)->
	Petid=Term#pet_explore_info_s2c.petid,
	Remaintimes=Term#pet_explore_info_s2c.remaintimes,
	Siteid=Term#pet_explore_info_s2c.siteid,
	Explorestyle=Term#pet_explore_info_s2c.explorestyle,
	Lefttime=Term#pet_explore_info_s2c.lefttime,
	Data = <<Petid:64, Remaintimes:32, Siteid:32, Explorestyle:32, Lefttime:32>>,
	<<971:16, Data/binary>>.

%%
encode_pet_up_growth_s2c(Term)->
	Result=Term#pet_up_growth_s2c.result,
	Next=Term#pet_up_growth_s2c.next,
	Data = <<Result:32, Next:32>>,
	<<914:16, Data/binary>>.

%%
encode_venation_advanced_update_s2c(Term)->
	Attr=encode_list(Term#venation_advanced_update_s2c.attr, fun encode_k/1),
	Data = <<Attr/binary>>,
	<<1277:16, Data/binary>>.

%%
encode_group_disband_c2s(Term)->
	Data = <<>>,
	<<158:16, Data/binary>>.

%%
%encode_pet_upgrade_quality_c2s(Term)->
	%Petid=Term#pet_upgrade_quality_c2s.petid,
%	Needs=Term#pet_upgrade_quality_c2s.needs,
	%%Protect=Term#pet_upgrade_quality_c2s.protect,
%	Data = <<Petid:64, Needs:32, Protect:32>>,
	%<<1500:16, Data/binary>>.

%%
encode_guild_log_normal_s2c(Term)->
	Logs=encode_list(Term#guild_log_normal_s2c.logs, fun encode_guildlog/1),
	Data = <<Logs/binary>>,
	<<392:16, Data/binary>>.

%%
encode_exchange_item_fail_s2c(Term)->
	Reason=Term#exchange_item_fail_s2c.reason,
	Data = <<Reason:32>>,
	<<1005:16, Data/binary>>.

%%
encode_hp_package_s2c(Term)->
	Itemidl=Term#hp_package_s2c.itemidl,
	Itemidh=Term#hp_package_s2c.itemidh,
	Buffid=Term#hp_package_s2c.buffid,
	Data = <<Itemidl:32, Itemidh:32, Buffid:32>>,
	<<811:16, Data/binary>>.

%%
encode_tangle_more_records_c2s(Term)->
	Year=Term#tangle_more_records_c2s.year,
	Month=Term#tangle_more_records_c2s.month,
	Day=Term#tangle_more_records_c2s.day,
	Type=Term#tangle_more_records_c2s.type,
	Battleid=Term#tangle_more_records_c2s.battleid,
	Data = <<Year:32, Month:32, Day:32, Type:32, Battleid:32>>,
	<<836:16, Data/binary>>.

%%
encode_trade_role_lock_c2s(Term)->
	Data = <<>>,
	<<566:16, Data/binary>>.

%%
encode_get_friend_signature_s2c(Term)->
	Signature=encode_string(Term#get_friend_signature_s2c.signature),
	Data = <<Signature/binary>>,
	<<474:16, Data/binary>>.

%%
encode_everyday_show_s2c(Term)->
	Data = <<>>,
	<<1448:16, Data/binary>>.

%%
encode_dragon_fight_faction_c2s(Term)->
	Npcid=Term#dragon_fight_faction_c2s.npcid,
	Data = <<Npcid:64>>,
	<<1263:16, Data/binary>>.

%%
encode_change_item_failed_s2c(Term)->
	Itemid_low=Term#change_item_failed_s2c.itemid_low,
	Itemid_high=Term#change_item_failed_s2c.itemid_high,
	Errno=Term#change_item_failed_s2c.errno,
	Data = <<Itemid_low:32, Itemid_high:32, Errno:32>>,
	<<41:16, Data/binary>>.

%%
encode_country_leader_ever_reward_c2s(Term)->
	Data = <<>>,
	<<1652:16, Data/binary>>.

%%
encode_guild_battle_start_s2c(Term)->
	Data = <<>>,
	<<1653:16, Data/binary>>.

%%
encode_ride_opt_c2s(Term)->
	Opcode=Term#ride_opt_c2s.opcode,
	Data = <<Opcode:32>>,
	<<1466:16, Data/binary>>.

%%
encode_npc_map_change_c2s(Term)->
	Npcid=Term#npc_map_change_c2s.npcid,
	Id=Term#npc_map_change_c2s.id,
	Data = <<Npcid:64, Id:32>>,
	<<62:16, Data/binary>>.

%%
encode_delete_friend_c2s(Term)->
	Fn=encode_string(Term#delete_friend_c2s.fn),
	Data = <<Fn/binary>>,
	<<486:16, Data/binary>>.

%%
encode_lottery_notic_s2c(Term)->
	Rolename=encode_string(Term#lottery_notic_s2c.rolename),
	Item=encode_lti(Term#lottery_notic_s2c.item),
	Data = <<Rolename/binary, Item/binary>>,
	<<507:16, Data/binary>>.

%%
encode_venation_opt_s2c(Term)->
	Reason=Term#venation_opt_s2c.reason,
	Roleid=Term#venation_opt_s2c.roleid,
	Data = <<Reason:32, Roleid:64>>,
	<<1286:16, Data/binary>>.

%%副本元宝委托
encode_instance_entrust_c2s(Term)->
	Instance_id=Term#instance_entrust_c2s.instance_id,
	Times=Term#instance_entrust_c2s.times,
	Data = <<Instance_id:32, Times:32>>,
	<<1900:16, Data/binary>>.

%%
encode_loop_tower_challenge_c2s(Term)->
	Type=Term#loop_tower_challenge_c2s.type,
	Data = <<Type:32>>,
	<<655:16, Data/binary>>.

%%
encode_guild_member_depart_c2s(Term)->
	Data = <<>>,
	<<366:16, Data/binary>>.

%%
encode_instance_end_seconds_s2c(Term)->
	Kicktime_s=Term#instance_end_seconds_s2c.kicktime_s,
	Data = <<Kicktime_s:32>>,
	<<858:16, Data/binary>>.

%%
encode_ride_opt_result_s2c(Term)->
	Errno=Term#ride_opt_result_s2c.errno,
	Data = <<Errno:32>>,
	<<1467:16, Data/binary>>.

%%
encode_npc_storage_items_c2s(Term)->
	Npcid=Term#npc_storage_items_c2s.npcid,
	Data = <<Npcid:64>>,
	<<128:16, Data/binary>>.

%%
encode_chess_spirit_skill_levelup_c2s(Term)->
	Skillid=Term#chess_spirit_skill_levelup_c2s.skillid,
	Data = <<Skillid:32>>,
	<<1175:16, Data/binary>>.

%%
encode_gift_card_state_s2c(Term)->
	Weburl=encode_string(Term#gift_card_state_s2c.weburl),
	State=Term#gift_card_state_s2c.state,
	Data = <<Weburl/binary, State:32>>,
	<<1161:16, Data/binary>>.

%%
encode_map_change_failed_s2c(Term)->
	Reasonid=Term#map_change_failed_s2c.reasonid,
	Data = <<Reasonid:32>>,
	<<63:16, Data/binary>>.

%%
encode_gift_card_apply_c2s(Term)->
	Key=encode_string(Term#gift_card_apply_c2s.key),
	Data = <<Key/binary>>,
	<<1162:16, Data/binary>>.

%%
encode_guild_member_kickout_c2s(Term)->
	Roleid=Term#guild_member_kickout_c2s.roleid,
	Data = <<Roleid:64>>,
	<<367:16, Data/binary>>.

%%
encode_delete_friend_success_s2c(Term)->
	Fid=Term#delete_friend_success_s2c.fn,
	Type=Term#delete_friend_success_s2c.type,%%@@wb
	Data = <<Fid:64,Type:32>>,%%@@wb
	<<487:16, Data/binary>>.

%%
encode_group_depart_c2s(Term)->
	Data = <<>>,
	<<159:16, Data/binary>>.

%%
encode_venation_time_countdown_s2c(Term)->
	Roleid=Term#venation_time_countdown_s2c.roleid,
	Time=Term#venation_time_countdown_s2c.time,
	Data = <<Roleid:64, Time:32>>,
	<<1287:16, Data/binary>>.

%%
encode_mainline_init_c2s(Term)->
	Data = <<>>,
	<<1560:16, Data/binary>>.

%%
encode_pet_learn_skill_c2s(Term)->
	Petid=Term#pet_learn_skill_c2s.petid,
	Slot=Term#pet_learn_skill_c2s.slot,
	Data = <<Petid:64, Slot:32>>,
	<<917:16, Data/binary>>.

%%
encode_use_item_error_s2c(Term)->
	Errno=Term#use_item_error_s2c.errno,
	Data = <<Errno:32>>,
	<<42:16, Data/binary>>.

%%
encode_timelimit_gift_info_s2c(Term)->
	Nextindex=Term#timelimit_gift_info_s2c.nextindex,
	Nexttime=Term#timelimit_gift_info_s2c.nexttime,
	Itmes=encode_list(Term#timelimit_gift_info_s2c.itmes, fun encode_lti/1),
	Data = <<Nextindex:32, Nexttime:32, Itmes/binary>>,
	<<1020:16, Data/binary>>.

%%
encode_instance_exit_c2s(Term)->
	Data = <<>>,
	<<838:16, Data/binary>>.

%%
encode_entry_guild_battle_s2c(Term)->
	Result=Term#entry_guild_battle_s2c.result,
	Lefttime=Term#entry_guild_battle_s2c.lefttime,
	Data = <<Result:32, Lefttime:32>>,
	<<1655:16, Data/binary>>.

%%
encode_pet_explore_start_c2s(Term)->
	Petid=Term#pet_explore_start_c2s.petid,
	Explorestyle=Term#pet_explore_start_c2s.explorestyle,
	Siteid=Term#pet_explore_start_c2s.siteid,
	Lucky=Term#pet_explore_start_c2s.lucky,
	Data = <<Petid:64, Explorestyle:32, Siteid:32, Lucky:32>>,
	<<972:16, Data/binary>>.

%%
encode_tangle_more_records_s2c(Term)->
	Trs=encode_list(Term#tangle_more_records_s2c.trs, fun encode_tr/1),
	Year=Term#tangle_more_records_s2c.year,
	Month=Term#tangle_more_records_s2c.month,
	Day=Term#tangle_more_records_s2c.day,
	Type=Term#tangle_more_records_s2c.type,
	Myrank=Term#tangle_more_records_s2c.myrank,
	Battleid=Term#tangle_more_records_s2c.battleid,
	Has_reward=Term#tangle_more_records_s2c.has_reward,
	Data = <<Trs/binary, Year:32, Month:32, Day:32, Type:32, Myrank:32, Battleid:32, Has_reward:32>>,
	<<837:16, Data/binary>>.

%%
encode_yhzq_battle_player_pos_s2c(Term)->
	Players=encode_list(Term#yhzq_battle_player_pos_s2c.players, fun encode_tp/1),
	Data = <<Players/binary>>,
	<<1118:16, Data/binary>>.

%%
encode_dragon_fight_num_s2c(Term)->
	Npcid=Term#dragon_fight_num_s2c.npcid,
	Faction=Term#dragon_fight_num_s2c.faction,
	Num=Term#dragon_fight_num_s2c.num,
	Data = <<Npcid:64, Faction:32, Num:32>>,
	<<1262:16, Data/binary>>.

%%
encode_pet_item_opt_result_s2c(Term)->
	Errno=Term#pet_item_opt_result_s2c.errno,
	Data = <<Errno:32>>,
	<<1513:16, Data/binary>>.

%%
encode_npc_fucnction_common_error_s2c(Term)->
	Reasonid=Term#npc_fucnction_common_error_s2c.reasonid,
	Data = <<Reasonid:32>>,
	<<300:16, Data/binary>>.

%%
encode_guild_set_leader_c2s(Term)->
	Roleid=Term#guild_set_leader_c2s.roleid,
	Data = <<Roleid:64>>,
	<<368:16, Data/binary>>.

%%
encode_update_guild_update_apply_info_s2c(Term)->
	Role=encode_g(Term#update_guild_update_apply_info_s2c.role),
	Type=Term#update_guild_update_apply_info_s2c.type,
	Data = <<Role/binary, Type:32>>,
	<<1211:16, Data/binary>>.

%%
encode_battle_end_s2c(Term)->
	Exp=Term#battle_end_s2c.exp,
	Honor=Term#battle_end_s2c.honor,
	Data = <<Exp:64, Honor:32>>,
	<<826:16, Data/binary>>.

%%
encode_mail_status_query_c2s(Term)->
	Data = <<>>,
	<<530:16, Data/binary>>.

%%
encode_yhzq_battle_end_s2c(Term)->
	Data = <<>>,
	<<1119:16, Data/binary>>.

%%
encode_treasure_buffer_s2c(Term)->
	Buffs=encode_list(Term#treasure_buffer_s2c.buffs, fun encode_bf/1),
	Data = <<Buffs/binary>>,
	<<1160:16, Data/binary>>.

%%
encode_group_invite_s2c(Term)->
	Roleid=Term#group_invite_s2c.roleid,
	Username=encode_string(Term#group_invite_s2c.username),
	Data = <<Roleid:64, Username/binary>>,
	<<160:16, Data/binary>>.

%%
encode_init_random_rolename_s2c(Term)->
	Bn=encode_string(Term#init_random_rolename_s2c.bn),
	Gn=encode_string(Term#init_random_rolename_s2c.gn),
	Data = <<Bn/binary, Gn/binary>>,
	<<1120:16, Data/binary>>.

%%
encode_mainline_kill_monsters_info_s2c(Term)->
	Npcprotoid=Term#mainline_kill_monsters_info_s2c.npcprotoid,
	Neednum=Term#mainline_kill_monsters_info_s2c.neednum,
	Chapter=Term#mainline_kill_monsters_info_s2c.chapter,
	Stage=Term#mainline_kill_monsters_info_s2c.stage,
	Data = <<Npcprotoid:32, Neednum:32, Chapter:32, Stage:32>>,
	<<1574:16, Data/binary>>.

%%
encode_entry_loop_instance_apply_c2s(Term)->
	Type=Term#entry_loop_instance_apply_c2s.type,
	Data = <<Type:32>>,
	<<1800:16, Data/binary>>.

%%
encode_timelimit_gift_error_s2c(Term)->
	Reason=Term#timelimit_gift_error_s2c.reason,
	Data = <<Reason:32>>,
	<<1022:16, Data/binary>>.

%%
encode_guild_get_treasure_item_c2s(Term)->
	Treasuretype=Term#guild_get_treasure_item_c2s.treasuretype,
	Data = <<Treasuretype:32>>,
	<<1203:16, Data/binary>>.

%%
encode_buff_immune_s2c(Term)->
	Enemyid=Term#buff_immune_s2c.enemyid,
	Immune_buffs=encode_list(Term#buff_immune_s2c.immune_buffs, fun encode_mf/1),
	Flytime=Term#buff_immune_s2c.flytime,
	Data = <<Enemyid:64, Immune_buffs/binary, Flytime:32>>,
	<<43:16, Data/binary>>.

%%
encode_equip_item_for_pet_c2s(Term)->
	Petid=Term#equip_item_for_pet_c2s.petid,
	Slot=Term#equip_item_for_pet_c2s.slot,
	Data = <<Petid:64, Slot:32>>,
	<<1511:16, Data/binary>>.

%%
encode_server_travel_tag_s2c(Term)->
	Istravel=Term#server_travel_tag_s2c.istravel,
	Data = <<Istravel:32>>,
	<<1290:16, Data/binary>>.

%%
encode_welfare_gold_exchange_init_s2c(Term)->
	Consume_gold=Term#welfare_gold_exchange_init_s2c.consume_gold,
	Data = <<Consume_gold:32>>,
	<<1464:16, Data/binary>>.

%%
encode_quest_complete_s2c(Term)->
	Questid=Term#quest_complete_s2c.questid,
	Data = <<Questid:32>>,
	<<90:16, Data/binary>>.

%%
encode_chess_spirit_prepare_s2c(Term)->
	Time_s=Term#chess_spirit_prepare_s2c.time_s,
	Data = <<Time_s:32>>,
	<<1184:16, Data/binary>>.

%%
encode_role_move_fail_s2c(Term)->
	Pos=encode_c(Term#role_move_fail_s2c.pos),
	Data = <<Pos/binary>>,
	<<28:16, Data/binary>>.

%%
encode_query_time_c2s(Term)->
	Data = <<>>,
	<<740:16, Data/binary>>.

%%
encode_set_pkmodel_faild_s2c(Term)->
	Errno=Term#set_pkmodel_faild_s2c.errno,
	Data = <<Errno:32>>,
	<<731:16, Data/binary>>.

%%
encode_is_jackaroo_s2c(Term)->
	Data = <<>>,
	<<422:16, Data/binary>>.

%%
encode_mainline_section_info_s2c(Term)->
	Cur_section=Term#mainline_section_info_s2c.cur_section,
	Next_section_s=Term#mainline_section_info_s2c.next_section_s,
	Data = <<Cur_section:32, Next_section_s:32>>,
	<<1575:16, Data/binary>>.

%%
encode_guild_member_promotion_c2s(Term)->
	Roleid=Term#guild_member_promotion_c2s.roleid,
	Data = <<Roleid:64>>,
	<<369:16, Data/binary>>.

%%
encode_equipment_sock_c2s(Term)->
	Equipment=Term#equipment_sock_c2s.equipment,
	Sock=Term#equipment_sock_c2s.sock,
	Data = <<Equipment:32, Sock:32>>,
	<<603:16, Data/binary>>.

%%
encode_vip_level_up_s2c(Term)->
	Data = <<>>,
	<<674:16, Data/binary>>.

%%
encode_init_pets_s2c(Term)->
	Pets=encode_list(Term#init_pets_s2c.pets, fun encode_p/1),
	Max_pet_num=Term#init_pets_s2c.max_pet_num,
	Present_slot=Term#init_pets_s2c.present_slot,
	Data = <<Pets/binary, Max_pet_num:32, Present_slot:32>>,
	<<900:16, Data/binary>>.

%%
encode_offline_exp_exchange_c2s(Term)->
	Type=Term#offline_exp_exchange_c2s.type,
	Hours=Term#offline_exp_exchange_c2s.hours,
	Data = <<Type:32, Hours:32>>,
	<<1133:16, Data/binary>>.

%%
encode_entry_guild_battle_c2s(Term)->
	Data = <<>>,
	<<1654:16, Data/binary>>.

%%
encode_guild_destroy_s2c(Term)->
	Reason=Term#guild_destroy_s2c.reason,
	Data = <<Reason:32>>,
	<<387:16, Data/binary>>.

%%
encode_get_timelimit_gift_c2s(Term)->
	Data = <<>>,
	<<1021:16, Data/binary>>.

%%
encode_query_time_s2c(Term)->
	Time_async=Term#query_time_s2c.time_async,
	Data = <<Time_async:32>>,
	<<741:16, Data/binary>>.

%%
encode_update_skill_s2c(Term)->
	Creatureid=Term#update_skill_s2c.creatureid,
	Skillid=Term#update_skill_s2c.skillid,
	Level=Term#update_skill_s2c.level,
	Data = <<Creatureid:64, Skillid:32, Level:32>>,
	<<75:16, Data/binary>>.

%%
encode_timelimit_gift_over_s2c(Term)->
	Data = <<>>,
	<<1023:16, Data/binary>>.

%%
encode_black_list_s2c(Term)->
	Friendinfos=encode_list(Term#black_list_s2c.friendinfos, fun encode_br/1),
	Data = <<Friendinfos/binary>>,
	<<479:16, Data/binary>>.

%%
encode_is_visitor_c2s(Term)->
	T=Term#is_visitor_c2s.t,
	F=encode_string(Term#is_visitor_c2s.f),
	Data = <<T:32, F/binary>>,
	<<423:16, Data/binary>>.

%%
encode_quest_accept_failed_s2c(Term)->
	Errno=Term#quest_accept_failed_s2c.errno,
	Data = <<Errno:32>>,
	<<98:16, Data/binary>>.

%%
encode_other_role_move_s2c(Term)->
	Other_id=Term#other_role_move_s2c.other_id,
	Time=Term#other_role_move_s2c.time,
	Posx=Term#other_role_move_s2c.posx,
	Posy=Term#other_role_move_s2c.posy,
	Path=encode_list(Term#other_role_move_s2c.path, fun encode_c/1),
	Data = <<Other_id:64, Time:32, Posx:32, Posy:32, Path/binary>>,
	<<27:16, Data/binary>>.

%%
encode_festival_recharge_notice_s2c(Term)->
	Data = <<>>,
	<<1696:16, Data/binary>>.

%%
encode_pet_riseup_s2c(Term)->
	Result=Term#pet_riseup_s2c.result,
	Next=Term#pet_riseup_s2c.next,
	Data = <<Result:32, Next:32>>,
	<<925:16, Data/binary>>.

%%
encode_trade_role_dealit_c2s(Term)->
	Data = <<>>,
	<<567:16, Data/binary>>.

%%
encode_guild_battle_start_apply_s2c(Term)->
	Lefttime=Term#guild_battle_start_apply_s2c.lefttime,
	Data = <<Lefttime:32>>,
	<<1668:16, Data/binary>>.

%%
encode_update_hotbar_c2s(Term)->
	Clsid=Term#update_hotbar_c2s.clsid,
	Entryid=Term#update_hotbar_c2s.entryid,
	Pos=Term#update_hotbar_c2s.pos,
	Data = <<Clsid:32, Entryid:64, Pos:32>>,
	<<73:16, Data/binary>>.

%%
encode_guild_member_demotion_c2s(Term)->
	Roleid=Term#guild_member_demotion_c2s.roleid,
	Data = <<Roleid:64>>,
	<<370:16, Data/binary>>.

%%
encode_guild_member_decline_s2c(Term)->
	Rolename=encode_string(Term#guild_member_decline_s2c.rolename),
	Data = <<Rolename/binary>>,
	<<388:16, Data/binary>>.

%%
encode_yhzq_all_battle_over_s2c(Term)->
	Data = <<>>,
	<<1098:16, Data/binary>>.

%%
encode_guild_application_op_c2s(Term)->
	Roleid=Term#guild_application_op_c2s.roleid,
	Reject=Term#guild_application_op_c2s.reject,
	Data = <<Roleid:64, Reject:32>>,
	<<396:16, Data/binary>>.

%%
encode_guild_battle_result_s2c(Term)->
	Index=Term#guild_battle_result_s2c.index,
	Data = <<Index:32>>,
	<<1661:16, Data/binary>>.

%%
encode_loop_tower_enter_higher_s2c(Term)->
	Higher=Term#loop_tower_enter_higher_s2c.higher,
	Data = <<Higher:32>>,
	<<659:16, Data/binary>>.

%%
encode_equipment_sock_s2c(Term)->
	Result=Term#equipment_sock_s2c.result,
	Sock=Term#equipment_sock_s2c.sock,
	Data = <<Result:32, Sock:32>>,
	<<604:16, Data/binary>>.

%%
encode_jszd_start_notice_s2c(Term)->
	Lefttime=Term#jszd_start_notice_s2c.lefttime,
	Data = <<Lefttime:32>>,
	<<1700:16, Data/binary>>.

%%
encode_set_pkmodel_c2s(Term)->
	Pkmodel=Term#set_pkmodel_c2s.pkmodel,
	Data = <<Pkmodel:32>>,
	<<730:16, Data/binary>>.

%%
encode_vip_init_s2c(Term)->
	Vip=Term#vip_init_s2c.vip,
	Type=Term#vip_init_s2c.type,
	Type2=Term#vip_init_s2c.type2,
	Data = <<Vip:32, Type:32, Type2:32>>,
	<<675:16, Data/binary>>.

%%
encode_create_pet_s2c(Term)->
	Pet=encode_p(Term#create_pet_s2c.pet),
	Data = <<Pet/binary>>,
	<<901:16, Data/binary>>.

%%
encode_trade_role_errno_s2c(Term)->
	Errno=Term#trade_role_errno_s2c.errno,
	Data = <<Errno:32>>,
	<<570:16, Data/binary>>.

%%
encode_position_friend_s2c(Term)->
	Posfr=encode_pfr(Term#position_friend_s2c.posfr),
	Data = <<Posfr/binary>>,
	<<495:16, Data/binary>>.

%%
encode_is_finish_visitor_c2s(Term)->
	T=Term#is_finish_visitor_c2s.t,
	F=encode_string(Term#is_finish_visitor_c2s.f),
	U=encode_string(Term#is_finish_visitor_c2s.u),
	Data = <<T:32, F/binary, U/binary>>,
	<<425:16, Data/binary>>.

%%
encode_yhzq_error_s2c(Term)->
	Reason=Term#yhzq_error_s2c.reason,
	Data = <<Reason:32>>,
	<<1099:16, Data/binary>>.

%%
encode_guild_member_invite_s2c(Term)->
	Roleid=Term#guild_member_invite_s2c.roleid,
	Rolename=encode_string(Term#guild_member_invite_s2c.rolename),
	Guildlid=Term#guild_member_invite_s2c.guildlid,
	Guildhid=Term#guild_member_invite_s2c.guildhid,
	Guildname=encode_string(Term#guild_member_invite_s2c.guildname),
	Data = <<Roleid:64, Rolename/binary, Guildlid:32, Guildhid:32, Guildname/binary>>,
	<<389:16, Data/binary>>.

%%
encode_guild_log_normal_c2s(Term)->
	Type=Term#guild_log_normal_c2s.type,
	Data = <<Type:32>>,
	<<371:16, Data/binary>>.

%%
encode_welfare_gold_exchange_c2s(Term)->
	Data = <<>>,
	<<1465:16, Data/binary>>.

%%
encode_pet_up_exp_c2s(Term)->
	Petid=Term#pet_up_exp_c2s.petid,
	Needs=Term#pet_up_exp_c2s.needs,
	Data = <<Petid:64, Needs:32>>,
	<<918:16, Data/binary>>.

%%
encode_guild_battle_stop_apply_s2c(Term)->
	Data = <<>>,
	<<1669:16, Data/binary>>.

%%
encode_duel_invite_c2s(Term)->
	Roleid=Term#duel_invite_c2s.roleid,
	Data = <<Roleid:64>>,
	<<710:16, Data/binary>>.

%%
encode_init_open_service_activities_c2s(Term)->
	Activeid=Term#init_open_service_activities_c2s.activeid,
	Data = <<Activeid:32>>,
	<<1683:16, Data/binary>>.

%%
encode_jszd_join_c2s(Term)->
	Data = <<>>,
	<<1701:16, Data/binary>>.

%%
encode_trade_begin_s2c(Term)->
	Roleid=Term#trade_begin_s2c.roleid,
	Data = <<Roleid:64>>,
	<<571:16, Data/binary>>.

%%
encode_clear_crime_c2s(Term)->
	Type=Term#clear_crime_c2s.type,
	Data = <<Type:32>>,
	<<733:16, Data/binary>>.

%%
encode_guild_get_treasure_item_s2c(Term)->
	Treasuretype=Term#guild_get_treasure_item_s2c.treasuretype,
	Itemlist=encode_list(Term#guild_get_treasure_item_s2c.itemlist, fun encode_gti/1),
	Data = <<Treasuretype:32, Itemlist/binary>>,
	<<1204:16, Data/binary>>.

%%
encode_guild_log_event_c2s(Term)->
	Data = <<>>,
	<<372:16, Data/binary>>.

%%
encode_update_hotbar_fail_s2c(Term)->
	Data = <<>>,
	<<74:16, Data/binary>>.

%%
encode_aoi_role_group_c2s(Term)->
	Data = <<>>,
	<<175:16, Data/binary>>.

%%
encode_fatigue_login_disabled_s2c(Term)->
	Lefttime=Term#fatigue_login_disabled_s2c.lefttime,
	Prompt=encode_string(Term#fatigue_login_disabled_s2c.prompt),
	Data = <<Lefttime:32, Prompt/binary>>,
	<<341:16, Data/binary>>.

%%
encode_position_friend_failed_s2c(Term)->
	Reason=Term#position_friend_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<496:16, Data/binary>>.

%%客户端加载地图数据完成
encode_map_complete_c2s(Term)->
	Data = <<>>,
	<<13:16, Data/binary>>.

%%
encode_visitor_rename_s2c(Term)->
	Data = <<>>,
	<<426:16, Data/binary>>.

%%
encode_object_update_s2c(Term)->
	Deleteids=encode_list(Term#object_update_s2c.deleteids, fun encode_o/1),
	Create_attrs=encode_list(Term#object_update_s2c.create_attrs, fun encode_o/1),
	Change_attrs=encode_list(Term#object_update_s2c.change_attrs, fun encode_o/1),
	Data = <<Deleteids/binary, Create_attrs/binary, Change_attrs/binary>>,
	<<353:16, Data/binary>>.

%%
encode_myfriends_c2s(Term)->
	Ntype=Term#myfriends_c2s.ntype,
	Data = <<Ntype:32>>,
	<<480:16, Data/binary>>.

%%
encode_group_decline_s2c(Term)->
	Roleid=Term#group_decline_s2c.roleid,
	Username=encode_string(Term#group_decline_s2c.username),
	Data = <<Roleid:64, Username/binary>>,
	<<161:16, Data/binary>>.

%%
encode_guild_notice_modify_c2s(Term)->
	Notice=encode_string(Term#guild_notice_modify_c2s.notice),
	Data = <<Notice/binary>>,
	<<373:16, Data/binary>>.

%%
encode_role_cancel_attack_s2c(Term)->
	Roleid=Term#role_cancel_attack_s2c.roleid,
	Reason=Term#role_cancel_attack_s2c.reason,
	Data = <<Roleid:64, Reason:32>>,
	<<32:16, Data/binary>>.

%%
encode_pet_opt_error_s2c(Term)->
	Reason=Term#pet_opt_error_s2c.reason,
	Data = <<Reason:32>>,
	<<916:16, Data/binary>>.

%%
encode_mail_delete_c2s(Term)->
	Mailid=encode_mid(Term#mail_delete_c2s.mailid),
	Data = <<Mailid/binary>>,
	<<538:16, Data/binary>>.

%%
encode_clear_crime_time_s2c(Term)->
	Lefttime=Term#clear_crime_time_s2c.lefttime,
	Type=Term#clear_crime_time_s2c.type,
	Data = <<Lefttime:32, Type:32>>,
	<<734:16, Data/binary>>.

%%
encode_spa_error_s2c(Term)->
	Reason=Term#spa_error_s2c.reason,
	Data = <<Reason:32>>,
	<<1610:16, Data/binary>>.

%%
encode_welfare_panel_init_s2c(Term)->
	Packs_state=encode_list(Term#welfare_panel_init_s2c.packs_state, fun encode_gps/1),
	Data = <<Packs_state/binary>>,
	<<1461:16, Data/binary>>.

%%
encode_vip_ui_c2s(Term)->
	Data = <<>>,
	<<670:16, Data/binary>>.

%%
encode_learned_skill_s2c(Term)->
	Creatureid=Term#learned_skill_s2c.creatureid,
	Skills=encode_list(Term#learned_skill_s2c.skills, fun encode_s/1),
	Data = <<Creatureid:64, Skills/binary>>,
	<<71:16, Data/binary>>.

%%
encode_equipment_inlay_c2s(Term)->
	Equipment=Term#equipment_inlay_c2s.equipment,
	Inlay=Term#equipment_inlay_c2s.inlay,
	Socknum=Term#equipment_inlay_c2s.socknum,
	Data = <<Equipment:32, Inlay:32, Socknum:32>>,
	<<606:16, Data/binary>>.

%%
encode_jszd_join_s2c(Term)->
	Lefttime=Term#jszd_join_s2c.lefttime,
	Guilds=encode_list(Term#jszd_join_s2c.guilds, fun encode_jszd/1),
	Data = <<Lefttime:32, Guilds/binary>>,
	<<1702:16, Data/binary>>.

%%
encode_equipment_sock_failed_s2c(Term)->
	Reason=Term#equipment_sock_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<605:16, Data/binary>>.

%%
encode_vip_ui_s2c(Term)->
	Vip=Term#vip_ui_s2c.vip,
	Gold=Term#vip_ui_s2c.gold,
	Endtime=Term#vip_ui_s2c.endtime,
	Data = <<Vip:32, Gold:32, Endtime:32>>,
	<<671:16, Data/binary>>.

%%玩家初始化数据
encode_role_map_change_s2c(Term)->
	X=Term#role_map_change_s2c.x,
	Y=Term#role_map_change_s2c.y,
	Lineid=Term#role_map_change_s2c.lineid,
	Mapid=Term#role_map_change_s2c.mapid,
	Data = <<X:32, Y:32, Lineid:32, Mapid:32>>,
	<<14:16, Data/binary>>.

%%
encode_update_trade_status_s2c(Term)->
	Roleid=Term#update_trade_status_s2c.roleid,
	Silver=Term#update_trade_status_s2c.silver,
	Gold=Term#update_trade_status_s2c.gold,
	Ticket=Term#update_trade_status_s2c.ticket,
	Slot_infos=encode_list(Term#update_trade_status_s2c.slot_infos, fun encode_ti/1),
	Data = <<Roleid:64, Silver:32, Gold:32, Ticket:32, Slot_infos/binary>>,
	<<572:16, Data/binary>>.

%%
%encode_init_open_service_activities_s2c(Term)->
%	Activeid=Term#init_open_service_activities_s2c.activeid,
%	Partinfo=encode_list(Term#init_open_service_activities_s2c.partinfo, fun encode_recharge/1),
%	Starttime=encode_time_struct(Term#init_open_service_activities_s2c.starttime),
%	Endtime=encode_time_struct(Term#init_open_service_activities_s2c.endtime),
%	Lefttime=Term#init_open_service_activities_s2c.lefttime,
%	Info=Term#init_open_service_activities_s2c.info,
%	State=Term#init_open_service_activities_s2c.state,
%	Data = <<Activeid:32, Partinfo/binary, Starttime/binary, Endtime/binary, Lefttime:32, Info:32, State:32>>,
%	<<1680:16, Data/binary>>.

encode_init_open_service_activities_s2c(Term)->
	Info=encode_list(Term#init_open_service_activities_s2c.info, fun encode_nsr/1),
	Data = <<Info/binary>>,
	<<1680:16, Data/binary>>.

encode_nsr(Term)->
	Activeid=Term#nsr.activeid,
	Starttime=encode_time_struct(Term#nsr.starttime),
	Endtime=encode_time_struct(Term#nsr.endtime),
	Info=Term#nsr.info,
	State=Term#nsr.state,
	Part=encode_list(Term#nsr.part, fun encode_nsp/1),
	Data = <<Activeid:32, Starttime/binary, Endtime/binary, Info:32, State:32, Part/binary>>,
	Data.

encode_nsp(Term)->
	State=Term#nsp.state,
	Id=Term#nsp.id,
	Data = <<State:32, Id:32>>,
	Data.

%%
encode_visitor_rename_failed_s2c(Term)->
	Reason=Term#visitor_rename_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<428:16, Data/binary>>.

%%
encode_guild_treasure_buy_item_c2s(Term)->
	Treasuretype=Term#guild_treasure_buy_item_c2s.treasuretype,
	Id=Term#guild_treasure_buy_item_c2s.id,
	Itemid=Term#guild_treasure_buy_item_c2s.itemid,
	Count=Term#guild_treasure_buy_item_c2s.count,
	Data = <<Treasuretype:32, Id:32, Itemid:32, Count:32>>,
	<<1205:16, Data/binary>>.

%%
encode_visitor_rename_c2s(Term)->
	N=encode_string(Term#visitor_rename_c2s.n),
	Data = <<N/binary>>,
	<<427:16, Data/binary>>.

%%
encode_buy_pet_slot_c2s(Term)->
	Data = <<>>,
	<<940:16, Data/binary>>.

%%
encode_duel_decline_c2s(Term)->
	Roleid=Term#duel_decline_c2s.roleid,
	Data = <<Roleid:64>>,
	<<711:16, Data/binary>>.

%%
encode_loop_tower_enter_failed_s2c(Term)->
	Reason=Term#loop_tower_enter_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<651:16, Data/binary>>.

%%
encode_congratulations_levelup_s2c(Term)->
	Exp=Term#congratulations_levelup_s2c.exp,
	Soulpower=Term#congratulations_levelup_s2c.soulpower,
	Remain=Term#congratulations_levelup_s2c.remain,
	Data = <<Exp:32, Soulpower:32, Remain:32>>,
	<<1142:16, Data/binary>>.

%%
encode_guild_facilities_accede_rules_c2s(Term)->
	Facilityid=Term#guild_facilities_accede_rules_c2s.facilityid,
	Requirevalue=Term#guild_facilities_accede_rules_c2s.requirevalue,
	Data = <<Facilityid:32, Requirevalue:32>>,
	<<374:16, Data/binary>>.

%%
encode_update_pet_slot_num_s2c(Term)->
	Num=Term#update_pet_slot_num_s2c.num,
	Data = <<Num:32>>,
	<<941:16, Data/binary>>.

%%
encode_guild_log_event_s2c(Term)->
	Data = <<>>,
	<<393:16, Data/binary>>.

%%
encode_equipment_inlay_s2c(Term)->
	Data = <<>>,
	<<607:16, Data/binary>>.

%%
encode_query_player_option_c2s(Term)->
	Key=encode_int32_list(Term#query_player_option_c2s.key),
	Data = <<Key/binary>>,
	<<450:16, Data/binary>>.

%%
encode_guild_facilities_upgrade_c2s(Term)->
	Facilityid=Term#guild_facilities_upgrade_c2s.facilityid,
	Data = <<Facilityid:32>>,
	<<375:16, Data/binary>>.

%%已经存在于地图的角色数据
encode_other_role_map_init_s2c(Term)->
	Others=encode_list(Term#other_role_map_init_s2c.others, fun encode_rl/1),
	Data = <<Others/binary>>,
	<<16:16, Data/binary>>.

%%
encode_query_system_switch_c2s(Term)->
	Sysid=Term#query_system_switch_c2s.sysid,
	Data = <<Sysid:32>>,
	<<700:16, Data/binary>>.

%%
encode_use_target_item_c2s(Term)->
	Targetid=Term#use_target_item_c2s.targetid,
	Slot=Term#use_target_item_c2s.slot,
	Data = <<Targetid:64, Slot:32>>,
	<<813:16, Data/binary>>.

%%
encode_tangle_topman_pos_s2c(Term)->
	Roleposes=encode_list(Term#tangle_topman_pos_s2c.roleposes, fun encode_tp/1),
	Data = <<Roleposes/binary>>,
	<<835:16, Data/binary>>.

%%
encode_group_destroy_s2c(Term)->
	Data = <<>>,
	<<162:16, Data/binary>>.

%%
encode_equipment_inlay_failed_s2c(Term)->
	Reason=Term#equipment_inlay_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<608:16, Data/binary>>.

%%
encode_pet_feed_c2s(Term)->
	Petid=Term#pet_feed_c2s.petid,
	Slot=Term#pet_feed_c2s.slot,
	Data = <<Petid:64, Slot:32>>,
	<<942:16, Data/binary>>.

%%
encode_create_role_request_c2s(Term)->
	Role_name=encode_string(Term#create_role_request_c2s.role_name),
	Gender=Term#create_role_request_c2s.gender,
	Classtype=Term#create_role_request_c2s.classtype,
	Data = <<Role_name/binary, Gender:32, Classtype:32>>,
	<<400:16, Data/binary>>.

%%
encode_add_buff_s2c(Term)->
	Targetid=Term#add_buff_s2c.targetid,
	Buffers=encode_list(Term#add_buff_s2c.buffers, fun encode_bf/1),
	Data = <<Targetid:64, Buffers/binary>>,
	<<101:16, Data/binary>>.

%%
encode_system_status_s2c(Term)->
	Sysid=Term#system_status_s2c.sysid,
	Status=Term#system_status_s2c.status,
	Data = <<Sysid:32, Status:32>>,
	<<701:16, Data/binary>>.

%%
encode_jszd_leave_c2s(Term)->
	Data = <<>>,
	<<1703:16, Data/binary>>.

%%NPC的初始信息
encode_npc_init_s2c(Term)->
	Npcs=encode_list(Term#npc_init_s2c.npcs, fun encode_nl/1),
	Data = <<Npcs/binary>>,
	<<15:16, Data/binary>>.

%%
encode_quest_list_update_s2c(Term)->
	Quests=encode_list(Term#quest_list_update_s2c.quests, fun encode_q/1),
	Data = <<Quests/binary>>,
	<<81:16, Data/binary>>.

%%
encode_query_player_option_s2c(Term)->
	Kv=encode_list(Term#query_player_option_s2c.kv, fun encode_k/1),
	Data = <<Kv/binary>>,
	<<451:16, Data/binary>>.

%%
encode_trade_role_lock_s2c(Term)->
	Roleid=Term#trade_role_lock_s2c.roleid,
	Data = <<Roleid:64>>,
	<<573:16, Data/binary>>.

%%
encode_guild_facilities_speed_up_c2s(Term)->
	Facilityid=Term#guild_facilities_speed_up_c2s.facilityid,
	Slotnum=Term#guild_facilities_speed_up_c2s.slotnum,
	Data = <<Facilityid:32, Slotnum:32>>,
	<<376:16, Data/binary>>.

%%
encode_item_identify_c2s(Term)->
	Slot=Term#item_identify_c2s.slot,
	Itemslot=Term#item_identify_c2s.itemslot,
	Type=Term#item_identify_c2s.type,
	Data = <<Slot:32, Itemslot:32, Type:32>>,
	<<1480:16, Data/binary>>.

%%
encode_duel_accept_c2s(Term)->
	Roleid=Term#duel_accept_c2s.roleid,
	Data = <<Roleid:64>>,
	<<712:16, Data/binary>>.

%%
encode_vip_npc_enum_s2c(Term)->
	Vip=Term#vip_npc_enum_s2c.vip,
	Bonus=encode_list(Term#vip_npc_enum_s2c.bonus, fun encode_l/1),
	Data = <<Vip:32, Bonus/binary>>,
	<<676:16, Data/binary>>.

%%
encode_loop_tower_masters_c2s(Term)->
	Master=Term#loop_tower_masters_c2s.master,
	Data = <<Master:32>>,
	<<652:16, Data/binary>>.

%%
encode_npc_everquests_enum_c2s(Term)->
	Npcid=Term#npc_everquests_enum_c2s.npcid,
	Data = <<Npcid:64>>,
	<<855:16, Data/binary>>.

%%
encode_jszd_update_s2c(Term)->
	Roleid=Term#jszd_update_s2c.roleid,
	Score=Term#jszd_update_s2c.score,
	Lefttime=Term#jszd_update_s2c.lefttime,
	Guilds=encode_list(Term#jszd_update_s2c.guilds, fun encode_jszd/1),
	Data = <<Roleid:64, Score:32, Lefttime:32, Guilds/binary>>,
	<<1705:16, Data/binary>>.

%%
encode_equipment_stone_remove_c2s(Term)->
	Equipment=Term#equipment_stone_remove_c2s.equipment,
	Remove=Term#equipment_stone_remove_c2s.remove,
	Socknum=Term#equipment_stone_remove_c2s.socknum,
	Data = <<Equipment:32, Remove:32, Socknum:32>>,
	<<609:16, Data/binary>>.

%%
encode_open_sercice_activities_update_s2c(Term)->
	Id=Term#open_sercice_activities_update_s2c.id,
	Part=Term#open_sercice_activities_update_s2c.part,
	State=Term#open_sercice_activities_update_s2c.state,
	Data = <<Id:32, Part:32, State:32>>,
	<<1681:16, Data/binary>>.

%%
encode_del_buff_s2c(Term)->
	Buffid=Term#del_buff_s2c.buffid,
	Target=Term#del_buff_s2c.target,
	Data = <<Buffid:32, Target:64>>,
	<<102:16, Data/binary>>.

%%
encode_jszd_leave_s2c(Term)->
	Data = <<>>,
	<<1704:16, Data/binary>>.

%%
encode_pet_move_c2s(Term)->
	Petid=Term#pet_move_c2s.petid,
	Time=Term#pet_move_c2s.time,
	Posx=Term#pet_move_c2s.posx,
	Posy=Term#pet_move_c2s.posy,
	Path=encode_list(Term#pet_move_c2s.path, fun encode_c/1),
	Data = <<Petid:64, Time:32, Posx:32, Posy:32, Path/binary>>,
	<<903:16, Data/binary>>.

%%
encode_guild_get_application_c2s(Term)->
	Data = <<>>,
	<<394:16, Data/binary>>.

%%
encode_replace_player_option_c2s(Term)->
	Kv=encode_list(Term#replace_player_option_c2s.kv, fun encode_k/1),
	Data = <<Kv/binary>>,
	<<452:16, Data/binary>>.

%%
encode_quest_get_adapt_c2s(Term)->
	Data = <<>>,
	<<96:16, Data/binary>>.

%%
encode_trade_role_dealit_s2c(Term)->
	Roleid=Term#trade_role_dealit_s2c.roleid,
	Data = <<Roleid:64>>,
	<<574:16, Data/binary>>.

%%
encode_group_list_update_s2c(Term)->
	Leaderid=Term#group_list_update_s2c.leaderid,
	Members=encode_list(Term#group_list_update_s2c.members, fun encode_m/1),
	Data = <<Leaderid:64, Members/binary>>,
	<<163:16, Data/binary>>.

%%
encode_equipment_riseup_c2s(Term)->
	Equipment=Term#equipment_riseup_c2s.equipment,
	Riseup=Term#equipment_riseup_c2s.riseup,
	Protect=Term#equipment_riseup_c2s.protect,
	Lucky=encode_int32_list(Term#equipment_riseup_c2s.lucky),
	Data = <<Equipment:32, Riseup:32, Protect:32, Lucky/binary>>,
	<<600:16, Data/binary>>.

%%
encode_npc_everquests_enum_s2c(Term)->
	Everquests=encode_int32_list(Term#npc_everquests_enum_s2c.everquests),
	Npcid=Term#npc_everquests_enum_s2c.npcid,
	Data = <<Everquests/binary, Npcid:64>>,
	<<856:16, Data/binary>>.

%%
encode_guild_rewards_c2s(Term)->
	Data = <<>>,
	<<377:16, Data/binary>>.

%%
encode_vip_reward_c2s(Term)->
	Data = <<>>,
	<<672:16, Data/binary>>.

%%
encode_offline_exp_quests_init_s2c(Term)->
	Questinfos=encode_list(Term#offline_exp_quests_init_s2c.questinfos, fun encode_oqe/1),
	Data = <<Questinfos/binary>>,
	<<1132:16, Data/binary>>.

%%
encode_quest_direct_complete_c2s(Term)->
	Questid=Term#quest_direct_complete_c2s.questid,
	Data = <<Questid:32>>,
	<<99:16, Data/binary>>.

%%
encode_questgiver_hello_c2s(Term)->
	Npcid=Term#questgiver_hello_c2s.npcid,
	Data = <<Npcid:64>>,
	<<85:16, Data/binary>>.

%%
encode_group_cmd_result_s2c(Term)->
	Roleid=Term#group_cmd_result_s2c.roleid,
	Username=encode_string(Term#group_cmd_result_s2c.username),
	Reslut=Term#group_cmd_result_s2c.reslut,
	Data = <<Roleid:64, Username/binary, Reslut:32>>,
	<<164:16, Data/binary>>.

%%
encode_guild_recruite_info_c2s(Term)->
	Data = <<>>,
	<<378:16, Data/binary>>.

%%
encode_info_back_c2s(Term)->
	Type=Term#info_back_c2s.type,
	Info=encode_string(Term#info_back_c2s.info),
	Version=encode_string(Term#info_back_c2s.version),
	Data = <<Type:32, Info/binary, Version/binary>>,
	<<453:16, Data/binary>>.

%%
encode_move_stop_s2c(Term)->
	Id=Term#move_stop_s2c.id,
	X=Term#move_stop_s2c.x,
	Y=Term#move_stop_s2c.y,
	Data = <<Id:64, X:32, Y:32>>,
	<<104:16, Data/binary>>.

%%
encode_notify_to_join_yhzq_s2c(Term)->
	Battle_id=Term#notify_to_join_yhzq_s2c.battle_id,
	%Battle_id = 1,
	Camp=Term#notify_to_join_yhzq_s2c.camp,
	Data = <<Battle_id:32, Camp:32>>,
	<<1105:16, Data/binary>>.

%%
encode_role_attack_c2s(Term)->
	Skillid=Term#role_attack_c2s.skillid,
	Creatureid=Term#role_attack_c2s.creatureid,
	Data = <<Skillid:32, Creatureid:64>>,
	<<29:16, Data/binary>>.

%%
encode_guild_treasure_set_price_c2s(Term)->
	Treasuretype=Term#guild_treasure_set_price_c2s.treasuretype,
	Id=Term#guild_treasure_set_price_c2s.id,
	Itemid=Term#guild_treasure_set_price_c2s.itemid,
	Price=Term#guild_treasure_set_price_c2s.price,
	Data = <<Treasuretype:32, Id:32, Itemid:32, Price:32>>,
	<<1206:16, Data/binary>>.

%%
encode_trade_role_apply_s2c(Term)->
	Roleid=Term#trade_role_apply_s2c.roleid,
	Data = <<Roleid:64>>,
	<<576:16, Data/binary>>.

%%
encode_jszd_end_s2c(Term)->
	Myrank=Term#jszd_end_s2c.myrank,
	Guilds=encode_list(Term#jszd_end_s2c.guilds, fun encode_jszd/1),
	Honor=Term#jszd_end_s2c.honor,
	Exp=Term#jszd_end_s2c.exp,
	Data = <<Myrank:32, Guilds/binary, Honor:32, Exp:64>>,
	<<1706:16, Data/binary>>.

%%
encode_equipment_stone_remove_s2c(Term)->
	Data = <<>>,
	<<610:16, Data/binary>>.

%%
encode_guild_member_contribute_c2s(Term)->
	Moneytype=Term#guild_member_contribute_c2s.moneytype,
	Moneycount=Term#guild_member_contribute_c2s.moneycount,
	Data = <<Moneytype:32, Moneycount:32>>,
	<<379:16, Data/binary>>.

%%
encode_recruite_c2s(Term)->
	Instance=Term#recruite_c2s.instance,
	Description=encode_string(Term#recruite_c2s.description),
	Data = <<Instance:32, Description/binary>>,
	<<167:16, Data/binary>>.

%%
encode_duel_invite_s2c(Term)->
	Roleid=Term#duel_invite_s2c.roleid,
	Data = <<Roleid:64>>,
	<<720:16, Data/binary>>.

%%
encode_equipment_stone_remove_failed_s2c(Term)->
	Reason=Term#equipment_stone_remove_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<611:16, Data/binary>>.

%%
encode_mail_query_detail_s2c(Term)->
	Mail_detail=encode_md(Term#mail_query_detail_s2c.mail_detail),
	Data = <<Mail_detail/binary>>,
	<<534:16, Data/binary>>.

%%
encode_npc_start_everquest_c2s(Term)->
	Npcid=Term#npc_start_everquest_c2s.npcid,
	Everqid=Term#npc_start_everquest_c2s.everqid,
	Data = <<Npcid:64, Everqid:32>>,
	<<854:16, Data/binary>>.

%%
encode_login_bonus_reward_c2s(Term)->
	Data = <<>>,
	<<677:16, Data/binary>>.

%%
encode_guild_change_chatandvoicegroup_c2s(Term)->
	Chatgroup=encode_string(Term#guild_change_chatandvoicegroup_c2s.chatgroup),
	Voicegroup=encode_string(Term#guild_change_chatandvoicegroup_c2s.voicegroup),
	Data = <<Chatgroup/binary, Voicegroup/binary>>,
	<<398:16, Data/binary>>.

%%
encode_aoi_role_group_s2c(Term)->
	Groups_role=encode_list(Term#aoi_role_group_s2c.groups_role, fun encode_ag/1),
	Data = <<Groups_role/binary>>,
	<<176:16, Data/binary>>.

%%
encode_pet_attack_c2s(Term)->
	Petid=Term#pet_attack_c2s.petid,
	Skillid=Term#pet_attack_c2s.skillid,
	Creatureid=Term#pet_attack_c2s.creatureid,
	Data = <<Petid:64, Skillid:32, Creatureid:64>>,
	<<905:16, Data/binary>>.

%%
encode_trade_role_decline_s2c(Term)->
	Roleid=Term#trade_role_decline_s2c.roleid,
	Data = <<Roleid:64>>,
	<<575:16, Data/binary>>.

%%
encode_quest_get_adapt_s2c(Term)->
	Questids=encode_int32_list(Term#quest_get_adapt_s2c.questids),
	Everqids=encode_int32_list(Term#quest_get_adapt_s2c.everqids),
	Data = <<Questids/binary, Everqids/binary>>,
	<<97:16, Data/binary>>.

%%
encode_role_attack_s2c(Term)->
	Result=Term#role_attack_s2c.result,
	Skillid=Term#role_attack_s2c.skillid,
	Enemyid=Term#role_attack_s2c.enemyid,
	Creatureid=Term#role_attack_s2c.creatureid,
	Data = <<Result:32, Skillid:32, Enemyid:64, Creatureid:64>>,
	<<31:16, Data/binary>>.

%%
encode_join_yhzq_c2s(Term)->
	Reject=Term#join_yhzq_c2s.reject,
	Data = <<Reject:32>>,
	<<1106:16, Data/binary>>.

%%
encode_jszd_reward_c2s(Term)->
	Data = <<>>,
	<<1707:16, Data/binary>>.

%%
encode_player_level_up_s2c(Term)->
	Roleid=Term#player_level_up_s2c.roleid,
	Attrs=encode_list(Term#player_level_up_s2c.attrs, fun encode_k/1),
	Data = <<Roleid:64, Attrs/binary>>,
	<<111:16, Data/binary>>.

%%
encode_treasure_chest_flush_c2s(Term)->
	Slot=Term#treasure_chest_flush_c2s.slot,
	Data = <<Slot:32>>,
	<<981:16, Data/binary>>.

%%
encode_recruite_cancel_c2s(Term)->
	Data = <<>>,
	<<168:16, Data/binary>>.

%%
encode_feedback_info_c2s(Term)->
	Type=Term#feedback_info_c2s.type,
	Title=encode_string(Term#feedback_info_c2s.title),
	Content=encode_string(Term#feedback_info_c2s.content),
	Contactway=encode_string(Term#feedback_info_c2s.contactway),
	Data = <<Type:32, Title/binary, Content/binary, Contactway/binary>>,
	<<417:16, Data/binary>>.

%%
encode_offline_exp_exchange_gold_c2s(Term)->
	Type=Term#offline_exp_exchange_gold_c2s.type,
	Hours=Term#offline_exp_exchange_gold_c2s.hours,
	Data = <<Type:32, Hours:32>>,
	<<1135:16, Data/binary>>.

%%
encode_equipment_riseup_s2c(Term)->
	Result=Term#equipment_riseup_s2c.result,
	Star=Term#equipment_riseup_s2c.star,
	Data = <<Result:32, Star:32>>,
	<<601:16, Data/binary>>.

%%
encode_equipment_stonemix_single_c2s(Term)->
	Stonelist=encode_list(Term#equipment_stonemix_single_c2s.stonelist, fun encode_l/1),
	Data = <<Stonelist/binary>>,
	<<612:16, Data/binary>>.

%%
encode_display_hotbar_s2c(Term)->
	Things=encode_list(Term#display_hotbar_s2c.things, fun encode_hc/1),
	Data = <<Things/binary>>,
	<<72:16, Data/binary>>.

%%
encode_jszd_error_s2c(Term)->
	Reason=Term#jszd_error_s2c.reason,
	Data = <<Reason:32>>,
	<<1708:16, Data/binary>>.

%%
encode_refresh_everquest_c2s(Term)->
	Everqid=Term#refresh_everquest_c2s.everqid,
	Freshtype=Term#refresh_everquest_c2s.freshtype,
	Maxquality=Term#refresh_everquest_c2s.maxquality,
	Maxtimes=Term#refresh_everquest_c2s.maxtimes,
	Data = <<Everqid:32, Freshtype:32, Maxquality:32, Maxtimes:32>>,
	<<852:16, Data/binary>>.

%%
encode_mail_delete_s2c(Term)->
	Mailid=encode_mid(Term#mail_delete_s2c.mailid),
	Data = <<Mailid/binary>>,
	<<539:16, Data/binary>>.

%%
encode_equipment_riseup_failed_s2c(Term)->
	Reason=Term#equipment_riseup_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<602:16, Data/binary>>.

%%
encode_recruite_query_c2s(Term)->
	Instance=Term#recruite_query_c2s.instance,
	Data = <<Instance:32>>,
	<<169:16, Data/binary>>.

%%
encode_cancel_trade_s2c(Term)->
	Data = <<>>,
	<<577:16, Data/binary>>.

%%
encode_leave_yhzq_c2s(Term)->
	Data = <<>>,
	<<1107:16, Data/binary>>.

%%
encode_group_create_c2s(Term)->
	Data = <<>>,
	<<152:16, Data/binary>>.

%%
encode_guild_get_application_s2c(Term)->
	Roles=encode_list(Term#guild_get_application_s2c.roles, fun encode_g/1),
	Data = <<Roles/binary>>,
	<<395:16, Data/binary>>.

%%
encode_duel_decline_s2c(Term)->
	Roleid=Term#duel_decline_s2c.roleid,
	Data = <<Roleid:64>>,
	<<721:16, Data/binary>>.

%%
encode_goals_init_s2c(Term)->
	Parts=encode_list(Term#goals_init_s2c.parts, fun encode_ach/1),
	Data = <<Parts/binary>>,
	<<640:16, Data/binary>>.

%%
encode_activity_tab_isshow_s2c(Term)->
	Ts=encode_list(Term#activity_tab_isshow_s2c.ts, fun encode_tab_state/1),
	Data = <<Ts/binary>>,
	<<1690:16, Data/binary>>.

%%
encode_yhzq_award_s2c(Term)->
	Winner=Term#yhzq_award_s2c.winner,
	Honor=Term#yhzq_award_s2c.honor,
	Exp=Term#yhzq_award_s2c.exp,
	Data = <<Winner:32, Honor:32, Exp:64>>,
	<<1108:16, Data/binary>>.

%%
encode_pet_stop_move_c2s(Term)->
	Petid=Term#pet_stop_move_c2s.petid,
	Time=Term#pet_stop_move_c2s.time,
	Posx=Term#pet_stop_move_c2s.posx,
	Posy=Term#pet_stop_move_c2s.posy,
	Data = <<Petid:64, Time:32, Posx:32, Posy:32>>,
	<<904:16, Data/binary>>.

%%
encode_create_role_sucess_s2c(Term)->
	Role_id=Term#create_role_sucess_s2c.role_id,
	Data = <<Role_id:64>>,
	<<401:16, Data/binary>>.

%%
encode_trade_success_s2c(Term)->
	Data = <<>>,
	<<578:16, Data/binary>>.

%%
encode_questgiver_quest_details_s2c(Term)->
	Npcid=Term#questgiver_quest_details_s2c.npcid,
	Quests=encode_int32_list(Term#questgiver_quest_details_s2c.quests),
	Queststate=encode_int32_list(Term#questgiver_quest_details_s2c.queststate),
	Data = <<Npcid:64, Quests/binary, Queststate/binary>>,
	<<86:16, Data/binary>>.

%%
encode_mail_get_addition_c2s(Term)->
	Mailid=encode_mid(Term#mail_get_addition_c2s.mailid),
	Data = <<Mailid/binary>>,
	<<535:16, Data/binary>>.

%%
encode_equipment_stonemix_s2c(Term)->
	Newstone=Term#equipment_stonemix_s2c.newstone,
	Data = <<Newstone:32>>,
	<<613:16, Data/binary>>.

%%
encode_equipment_upgrade_c2s(Term)->
	Equipment=Term#equipment_upgrade_c2s.equipment,
	Data = <<Equipment:32>>,
	<<615:16, Data/binary>>.

%%
encode_jszd_stop_s2c(Term)->
	Data = <<>>,
	<<1709:16, Data/binary>>.

%%
encode_debug_c2s(Term)->
	Msg=encode_string(Term#debug_c2s.msg),
	Data = <<Msg/binary>>,
	<<38:16, Data/binary>>.

%%
encode_refresh_everquest_s2c(Term)->
	Everqid=Term#refresh_everquest_s2c.everqid,
	Questid=Term#refresh_everquest_s2c.questid,
	Quality=Term#refresh_everquest_s2c.quality,
	Free_fresh_times=Term#refresh_everquest_s2c.free_fresh_times,
	Resettime=Term#refresh_everquest_s2c.resettime,
	Data = <<Everqid:32, Questid:32, Quality:32, Free_fresh_times:32, Resettime:32>>,
	<<853:16, Data/binary>>.

%%
encode_be_attacked_s2c(Term)->
	Enemyid=Term#be_attacked_s2c.enemyid,
	Skill=Term#be_attacked_s2c.skill,
	Units=encode_list(Term#be_attacked_s2c.units, fun encode_b/1),
	Flytime=Term#be_attacked_s2c.flytime,
	Data = <<Enemyid:64, Skill:32, Units/binary, Flytime:32>>,
	<<33:16, Data/binary>>.

%%
encode_treasure_chest_flush_ok_s2c(Term)->
	Items=encode_list(Term#treasure_chest_flush_ok_s2c.items, fun encode_lti/1),
	Data = <<Items/binary>>,
	<<982:16, Data/binary>>.

%%
encode_mail_query_detail_c2s(Term)->
	Mailid=encode_mid(Term#mail_query_detail_c2s.mailid),
	Data = <<Mailid/binary>>,
	<<533:16, Data/binary>>.

%%
encode_group_invite_c2s(Term)->
	Username=encode_string(Term#group_invite_c2s.username),
	Data = <<Username/binary>>,
	<<153:16, Data/binary>>.

%%
encode_vip_error_s2c(Term)->
	Reason=Term#vip_error_s2c.reason,
	Data = <<Reason:32>>,
	<<673:16, Data/binary>>.

%%
encode_yhzq_award_c2s(Term)->
	Data = <<>>,
	<<1109:16, Data/binary>>.

%%
encode_start_block_training_c2s(Term)->
	Data = <<>>,
	<<510:16, Data/binary>>.

%%
encode_summon_pet_c2s(Term)->
	Type=Term#summon_pet_c2s.type,
	Petid=Term#summon_pet_c2s.petid,
	Data = <<Type:32, Petid:64>>,
	<<902:16, Data/binary>>.

%%
encode_guild_change_nickname_c2s(Term)->
	Roleid=Term#guild_change_nickname_c2s.roleid,
	Nickname=encode_string(Term#guild_change_nickname_c2s.nickname),
	Data = <<Roleid:64, Nickname/binary>>,
	<<397:16, Data/binary>>.

%%
encode_equipment_stonemix_failed_s2c(Term)->
	Reason=Term#equipment_stonemix_failed_s2c.reason,
	Data = <<Reason:32>>,
	<<614:16, Data/binary>>.

%%
encode_quest_list_remove_s2c(Term)->
	Questid=Term#quest_list_remove_s2c.questid,
	Data = <<Questid:32>>,
	<<82:16, Data/binary>>.

%%
encode_create_role_failed_s2c(Term)->
	Reasonid=Term#create_role_failed_s2c.reasonid,
	Data = <<Reasonid:32>>,
	<<402:16, Data/binary>>.

%%
encode_guild_contribute_log_c2s(Term)->
	Data = <<>>,
	<<1720:16, Data/binary>>.

%%
encode_start_block_training_s2c(Term)->
	Roleid=Term#start_block_training_s2c.roleid,
	Lefttime=Term#start_block_training_s2c.lefttime,
	Data = <<Roleid:64, Lefttime:32>>,
	<<511:16, Data/binary>>.

%%
encode_open_service_activities_reward_c2s(Term)->
	Id=Term#open_service_activities_reward_c2s.id,
	Part=Term#open_service_activities_reward_c2s.part,
	Data = <<Id:32, Part:32>>,
	<<1682:16, Data/binary>>.

%%
encode_yhzq_camp_info_s2c(Term)->
	Redplayernum=Term#yhzq_camp_info_s2c.redplayernum,
	Blueplayernum=Term#yhzq_camp_info_s2c.blueplayernum,
	Redscore=Term#yhzq_camp_info_s2c.redscore,
	Bluescore=Term#yhzq_camp_info_s2c.bluescore,
	Redguild=encode_string(Term#yhzq_camp_info_s2c.redguild),
	Blueguild=encode_string(Term#yhzq_camp_info_s2c.blueguild),
	Data = <<Redplayernum:32, Blueplayernum:32, Redscore:32, Bluescore:32, Redguild/binary, Blueguild/binary>>,
	<<1110:16, Data/binary>>.

%%
encode_equipment_upgrade_s2c(Term)->
	Data = <<>>,
	<<616:16, Data/binary>>.

%%
encode_festival_init_c2s(Term)->
	Festival_id=Term#festival_init_c2s.festival_id,
	Data = <<Festival_id:32>>,
	<<1691:16, Data/binary>>.

%%
encode_invite_friend_board_s2c(Term)->
	Friends_size=Term#invite_friend_board_s2c.friends_size,
	Amount_awards=encode_int32_list(Term#invite_friend_board_s2c.amount_awards),
	Data = <<Friends_size:32, Amount_awards/binary>>,
	<<2305:16, Data/binary>>.

%%
encode_tangle_battlefield_info_s2c(Term)->
	Killnum=Term#tangle_battlefield_info_s2c.killnum,
	Honor=Term#tangle_battlefield_info_s2c.honor,
	Battleinfo=encode_list(Term#tangle_battlefield_info_s2c.battleinfo, fun encode_tbi/1),
	Data = <<Killnum:32, Honor:32, Battleinfo/binary>>,
	<<819:16, Data/binary>>.

%%宠物初始化
encode_pet_shop_init_c2s(Term)->
	Type=Term#pet_shop_init_c2s.type,
	Data = <<Type:32>>,
	<<938:16, Data/binary>>.

%%丹药
%encode_get_furnace_queue_info_c2s(Term)->
%	Data = <<>>,
%	<<2411:16, Data/binary>>.

%%武斗大会
encode_world_cup_cur_section_info_c2s(Term)->
	Data = <<>>,
	<<2068:16, Data/binary>>.

%%
encode_sync_bonfire_time_s2c(Term)->
	Lefttime=Term#sync_bonfire_time_s2c.lefttime,
	Data = <<Lefttime:32/float>>,
	<<1729:16, Data/binary>>.
%%帮会bos
encode_get_guild_monster_info_s2c(Term)->
	Call_cd=Term#get_guild_monster_info_s2c.call_cd,
	Monster=encode_list(Term#get_guild_monster_info_s2c.monster, fun encode_gm/1),
	Lefttimes=Term#get_guild_monster_info_s2c.lefttimes,
	Data = <<Call_cd:32, Monster/binary, Lefttimes:32>>,
	<<1760:16, Data/binary>>.
encode_gm(Term)->
	State=Term#gm.state,
	Monsterid=Term#gm.monsterid,
	Data = <<State:32, Monsterid:32>>,
	Data.

encode_change_guild_right_limit_s2c(Term)->
	Smith=Term#change_guild_right_limit_s2c.smith,
	Battle=Term#change_guild_right_limit_s2c.battle,
	Data = <<Smith:32, Battle:32>>,
	<<1217:16, Data/binary>>.

%%宠物商城初始化
encode_pet_shop_init_s2c(Term)->
	Remain_s=Term#pet_shop_init_s2c.remain_s,
	Shops=encode_list(Term#pet_shop_init_s2c.shops, fun encode_ps/1),
	Data = <<Remain_s:32, Shops/binary>>,
	<<934:16, Data/binary>>.
%%宠物资质提升<枫少>
encode_pet_qualification_result_s2c(Term)->
	Petid=Term#pet_qualification_result_s2c.petid,
	QualificationValue=Term#pet_qualification_result_s2c.qualificationValue,
	Result=Term#pet_qualification_result_s2c.result,
	Data = <<Petid:64, QualificationValue:32, Result:32>>,
	<<1491:16, Data/binary>>.

%%宠物成长
encode_pet_evolution_growthvalue_s2c(Term)->
	Hp=Term#pet_evolution_growthvalue_s2c.hp,
	Meleeattack=Term#pet_evolution_growthvalue_s2c.meleeattack,
	Rangeattack=Term#pet_evolution_growthvalue_s2c.rangeattack,
	Magicattack=Term#pet_evolution_growthvalue_s2c.magicattack,
	Meleedefence=Term#pet_evolution_growthvalue_s2c.meleedefence,
	Rangedefence=Term#pet_evolution_growthvalue_s2c.rangedefence,
	Magicdefence=Term#pet_evolution_growthvalue_s2c.magicdefence,
	Data = <<Hp:32, Meleeattack:32, Rangeattack:32, Magicattack:32, Meleedefence:32, Rangedefence:32, Magicdefence:32>>,
	<<1493:16, Data/binary>>.
%%宠物成长提升
encode_pet_growup_result_s2c(Term)->
	Petid=Term#pet_growup_result_s2c.petid,
	Result=Term#pet_growup_result_s2c.result,
	Growth=Term#pet_growup_result_s2c.growth,
	Data = <<Petid:64, Result:32,Growth:32>>,
	<<1495:16, Data/binary>>.
%%经验太副本
encode_refresh_instance_quality_s2c(Term)->
	Instanceid=Term#refresh_instance_quality_s2c.instanceid,
	Freetime=Term#refresh_instance_quality_s2c.freetime,
	Totalfreetime=Term#refresh_instance_quality_s2c.totalfreetime,
	Npclist=encode_list(Term#refresh_instance_quality_s2c.npclist, fun encode_nq/1),
	Data = <<Instanceid:32, Freetime:32, Totalfreetime:32, Npclist/binary>>,
	<<1951:16, Data/binary>>.

encode_refresh_instance_quality_result_s2c(Term)->
	Gold=Term#refresh_instance_quality_result_s2c.gold,
	Itemtimes=Term#refresh_instance_quality_result_s2c.itemtimes,
	Freetimes=Term#refresh_instance_quality_result_s2c.freetimes,
	Data = <<Gold:32, Itemtimes:32, Freetimes:32>>,
	<<1953:16, Data/binary>>.

encode_nq(Term)->
	Npcproto=Term#nq.npcproto,
	Expfac=Term#nq.expfac,
	Quality=Term#nq.quality,
	Data = <<Npcproto:32, Expfac:32, Quality:32>>,
	Data.
%%宠物刷新技能
encode_pet_skill_book_refresh_c2s(Term)->
	Type=Term#pet_skill_book_refresh_c2s.type,
	Moneytype=Term#pet_skill_book_refresh_c2s.moneytype,
	Data = <<Type:32, Moneytype:32>>,
	<<930:16, Data/binary>>.

%%宠物技能
encode_pet_skill_book_init_s2c(Term)->
	Bound=Term#pet_skill_book_init_s2c.bound,
	Lucky=Term#pet_skill_book_init_s2c.lucky,
	Books=encode_list(Term#pet_skill_book_init_s2c.books, fun encode_psb/1),
	Data = <<Bound:32, Lucky:32, Books/binary>>,
	<<929:16, Data/binary>>.

encode_psb(Term)->
	Skilllevel=Term#psb.skilllevel,
	Skillid=Term#psb.skillid,
	Slot=Term#psb.slot,
	Data = <<Skilllevel:32, Skillid:32, Slot:32>>,
	Data.

%%宠物进阶更新
encode_pet_advance_update_s2c(Term)->
	Value=Term#pet_advance_update_s2c.value,
	Petid=Term#pet_advance_update_s2c.petid,
	Data = <<Value:32, Petid:64>>,
	<<945:16, Data/binary>>.
%%宠物自动进阶结果
encode_pet_auto_advance_result_s2c(Term)->
	Money=Term#pet_auto_advance_result_s2c.money,
	Petid=Term#pet_auto_advance_result_s2c.petid,
	Itemnum=Term#pet_auto_advance_result_s2c.itemnum,
	Result=Term#pet_auto_advance_result_s2c.result,
	Value=Term#pet_auto_advance_result_s2c.value,
	Data = <<Money:32, Petid:64, Itemnum:32, Result:32, Value:32>>,
	<<948:16, Data/binary>>.

%%天赋提升
encode_pet_talent_levelup_c2s(Term)->
	Petid=Term#pet_talent_levelup_c2s.petid,
	Id=Term#pet_talent_levelup_c2s.id,
	Data = <<Petid:64, Id:32>>,
	<<910:16, Data/binary>>.

%%
encode_pet_talent_update_s2c(Term)->
	Petid=Term#pet_talent_update_s2c.petid,
	Talent=encode_pt(Term#pet_talent_update_s2c.talent),
	Data = <<Petid:64, Talent/binary>>,
	<<911:16, Data/binary>>.

%%洗髓
%%
encode_pet_xs_update_s2c(Term)->
	Change=encode_pxs(Term#pet_xs_update_s2c.change),
	Petid=Term#pet_xs_update_s2c.petid,
	Data = <<Change/binary, Petid:64>>,
	<<913:16, Data/binary>>.

%%继承
encode_pet_inheritance_s2c(Term)->
	Data = <<>>,
	<<933:16, Data/binary>>.

%%帮会仓库
encode_guild_storage_init_s2c(Term)->
	Items=encode_list(Term#guild_storage_init_s2c.items, fun encode_gi/1),
	State=encode_list(Term#guild_storage_init_s2c.state, fun encode_oprate_state/1),
	Storage_size=Term#guild_storage_init_s2c.storage_size,
	Data = <<Items/binary, State/binary, Storage_size:32>>,
	<<1962:16, Data/binary>>.

encode_gi(Term)->
	Idle_state=Term#gi.idle_state,
	Idle=Term#gi.idel,
	Item_attrs=encode_i(Term#gi.item_attrs),
	Data = <<Idle_state:32, Idle:32, Item_attrs/binary>>,
	Data.
encode_oprate_state(Term)->
	State=Term#oprate_state.state,
	Type=Term#oprate_state.type,
	Data = <<State:32, Type:32>>,
	Data.

%%公会仓库添加物品
encode_guild_storage_add_item_s2c(Term)->
	Add_item=encode_list(Term#guild_storage_add_item_s2c.add_item, fun encode_gi/1),
	Data = <<Add_item/binary>>,
	<<1965:16, Data/binary>>.

%%帮会仓库中仓库记录
encode_guild_storage_log_s2c(Term)->
	Loglist=encode_list(Term#guild_storage_log_s2c.loglist, fun encode_gsl/1),
	Data = <<Loglist/binary>>,
	<<1981:16, Data/binary>>.

encode_gsl(Term)->
	Rolename=encode_string(Term#gsl.rolename),
	Operate=Term#gsl.operate,
	Templateid=Term#gsl.templateid,
	Month=Term#gsl.month,
	Day=Term#gsl.day,
	Hour=Term#gsl.hour,
	Min=Term#gsl.min,
	Count=Term#gsl.count,
	Data = <<Rolename/binary, Operate:32, Templateid:32, Month:32, Day:32, Hour:32, Min:32, Count:32>>,
	Data.

%%申请道具初始化
encode_guild_storage_init_apply_s2c(Term)->
	Applylist=encode_list(Term#guild_storage_init_apply_s2c.applylist, fun encode_al/1),
	Data = <<Applylist/binary>>,
	<<1972:16, Data/binary>>.

%%
encode_al(Term)->
	Item=encode_list(Term#al.item, fun encode_i/1),
	Applyrole=encode_list(Term#al.applyrole, fun encode_ar/1),
	Data = <<Item/binary, Applyrole/binary>>,
	Data.

encode_ar(Term)->
	Rolename=encode_string(Term#ar.rolename),
	Roleid=Term#ar.roleid,
	Count=Term#ar.count,
	Data = <<Rolename/binary, Roleid:64, Count:32>>,
	Data.
%%帮会成员查看申请列表
encode_guild_storage_self_apply_s2c(Term)->
	Apply=encode_list(Term#guild_storage_self_apply_s2c.apply, fun encode_spl/1),
	Data = <<Apply/binary>>,
	<<1978:16, Data/binary>>.
%%
encode_spl(Term)->
	Item=encode_i(Term#spl.item),
	Count=Term#spl.count,
	Data = <<Item/binary, Count:32>>,
	Data.

%%置为闲置结果
encode_guild_storage_update_state_s2c(Term)->
	State=encode_list(Term#guild_storage_update_state_s2c.state, fun encode_oprate_state/1),
	Data = <<State/binary>>,
	<<1970:16, Data/binary>>.

%%开启飞剑
encode_wing_open_s2c (Term)->
	Data = <<>>,
	<<2300:16, Data/binary>>.
%%角色飞剑信息
encode_update_role_wing_info_s2c (Term)->
	State=Term#update_role_wing_info_s2c .state,
	Roleid=Term#update_role_wing_info_s2c .roleid,
	Wing_intensify=encode_wing_intensify(Term#update_role_wing_info_s2c .wing_intensify),
	Level=Term#update_role_wing_info_s2c .level,
	Skills=encode_list(Term#update_role_wing_info_s2c .skills, fun encode_slv/1),
	Failed_num=Term#update_role_wing_info_s2c .failed_num,
	Enchants=encode_list(Term#update_role_wing_info_s2c .enchants, fun encode_enchant/1),
	Phase=Term#update_role_wing_info_s2c .phase,
	Quality=Term#update_role_wing_info_s2c .quality,
	Data = <<State:32, Roleid:32, Wing_intensify/binary, Level:32, Skills/binary, Failed_num:32, Enchants/binary, Phase:32, Quality:32>>,
	<<2298:16, Data/binary>>.

%%更新飞剑信息
encode_update_wing_base_info_s2c (Term)->
	Base_attr=encode_list(Term#update_wing_base_info_s2c .base_attr, fun encode_k/1),
	Data = <<Base_attr/binary>>,
	<<2299:16, Data/binary>>.

%%

encode_wing_intensify(Term)->
	Level=Term#wing_intensify.level,
	Add_percent=Term#wing_intensify.add_percent,
	Perfect_value=Term#wing_intensify.perfect_value,
	Data = <<Level:32, Add_percent:32, Perfect_value:32>>,
	Data.

%%技能等级信息
encode_slv(Term)->
	Level=Term#slv.level,
	Skillid=Term#slv.skillid,
	Data = <<Level:32, Skillid:32>>,
	Data.

%%
encode_enchant(Term)->
	Attr=encode_k(Term#enchant.attr),
	Quality=Term#enchant.quality,
	Data = <<Attr/binary, Quality:32>>,
	Data.

%%飞剑结果
encode_wing_opt_result_s2c (Term)->
	Result=Term#wing_opt_result_s2c .result,
	Data = <<Result:32>>,
	<<2294:16, Data/binary>>.

%%飞剑技能开始
encode_wing_skill_open_s2c (Term)->
	Skillid=Term#wing_skill_open_s2c .skillid,
	Data = <<Skillid:32>>,
	<<2302:16, Data/binary>>.

%%飞剑洗练结果
encode_wing_enchant_s2c (Term)->
	Enchants=encode_list(Term#wing_enchant_s2c .enchants, fun encode_enchant/1),
	Data = <<Enchants/binary>>,
	<<2296:16, Data/binary>>.

%%

encode_refresh_instance_quality_opt_s2c(Term)->
	Errno=Term#refresh_instance_quality_opt_s2c.errno,
	Data = <<Errno:32>>,
	<<1954:16, Data/binary>>.

%%
decode_refresh_instance_quality_opt_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #refresh_instance_quality_opt_s2c{errno=Errno},
	Term.

%%
decode_kmi(Binary0)->
	{Npcproto, Binary1}=read_int32(Binary0),
	{Neednum, Binary2}=read_int32(Binary1),
	Term = #kmi{npcproto=Npcproto, neednum=Neednum},
	{Term, Binary2}.


%%
decode_guildlog(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Id, Binary2}=read_int32(Binary1),
	{Keystr, Binary3}=read_string_list(Binary2),
	{Year, Binary4}=read_int32(Binary3),
	{Month, Binary5}=read_int32(Binary4),
	{Day, Binary6}=read_int32(Binary5),
	{Hour, Binary7}=read_int32(Binary6),
	{Min, Binary8}=read_int32(Binary7),
	{Sec, Binary9}=read_int32(Binary8),
	Term = #guildlog{type=Type, id=Id, keystr=Keystr, year=Year, month=Month, day=Day, hour=Hour, min=Min, sec=Sec},
	{Term, Binary9}.

%%
decode_kl(Binary0)->
	{Key, Binary1}=read_int32(Binary0),
	{Value, Binary2}=read_int32_list(Binary1),
	Term = #kl{key=Key, value=Value},
	{Term, Binary2}.

%%
decode_mf(Binary0)->
	{Creatureid, Binary1}=read_int64(Binary0),
	{Buffid, Binary2}=read_int32(Binary1),
	{Bufflevel, Binary3}=read_int32(Binary2),
	Term = #mf{creatureid=Creatureid, buffid=Buffid, bufflevel=Bufflevel},
	{Term, Binary3}.

%%
decode_bs(Binary0)->
	{Bossid, Binary1}=read_int32(Binary0),
	{State, Binary2}=read_int32(Binary1),
	Term = #bs{bossid=Bossid, state=State},
	{Term, Binary2}.

%%
decode_ach(Binary0)->
	{Isreward, Binary1}=read_int32(Binary0),
	{Chapter, Binary2}=read_int32(Binary1),
	{Part, Binary3}=read_int32(Binary2),
	{Cur, Binary4}=read_int32(Binary3),
	{Target, Binary5}=read_int32(Binary4),
	Term = #ach{isreward=Isreward, chapter=Chapter, part=Part, cur=Cur, target=Target},
	{Term, Binary5}.

%%
decode_votestate(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{State, Binary2}=read_int32(Binary1),
	Term = #votestate{roleid=Roleid, state=State},
	{Term, Binary2}.

%%
decode_ic(Binary0)->
	{Itemid_low, Binary1}=read_int32(Binary0),
	{Itemid_high, Binary2}=read_int32(Binary1),
	{Attrs, Binary3}=decode_list(Binary2, fun decode_k/1),
	{Ext_enchant, Binary4}=decode_list(Binary3, fun decode_k/1),
	Term = #ic{itemid_low=Itemid_low, itemid_high=Itemid_high, attrs=Attrs, ext_enchant=Ext_enchant},
	{Term, Binary4}.

%%
decode_av(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{Completed, Binary2}=read_int32(Binary1),
	Term = #av{id=Id, completed=Completed},
	{Term, Binary2}.

%%
decode_time_struct(Binary0)->
	{Year, Binary1}=read_int32(Binary0),
	{Month, Binary2}=read_int32(Binary1),
	{Day, Binary3}=read_int32(Binary2),
	{Hour, Binary4}=read_int32(Binary3),
	{Minute, Binary5}=read_int32(Binary4),
	{Second, Binary6}=read_int32(Binary5),
	Term = #time_struct{year=Year, month=Month, day=Day, hour=Hour, minute=Minute, second=Second},
	{Term, Binary6}.

%%
decode_rkv(Binary0)->
	{Kv, Binary1}=decode_list(Binary0, fun decode_k/1),
	{Kv_plus, Binary2}=decode_list(Binary1, fun decode_k/1),
	{Color, Binary3}=read_int32(Binary2),
	Term = #rkv{kv=Kv, kv_plus=Kv_plus, color=Color},
	{Term, Binary3}.

%%
decode_ip(Binary0)->
	{Moneytype, Binary1}=read_int32(Binary0),
	{Price, Binary2}=read_int32(Binary1),
	Term = #ip{moneytype=Moneytype, price=Price},
	{Term, Binary2}.

%%
decode_gps(Binary0)->
	{Typenumber, Binary1}=read_int32(Binary0),
	{Time_state, Binary2}=read_int32(Binary1),
	{Complete_state, Binary3}=read_int32(Binary2),
	Term = #gps{typenumber=Typenumber, time_state=Time_state, complete_state=Complete_state},
	{Term, Binary3}.

%%
decode_sp(Binary0)->
	{Itemclsid, Binary1}=read_int32(Binary0),
	{Price, Binary2}=decode_list(Binary1, fun decode_ip/1),
	Term = #sp{itemclsid=Itemclsid, price=Price},
	{Term, Binary2}.

%%
decode_charge(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{Awarddate, Binary2}=decode_time_struct(Binary1),
	{Charge_num, Binary3}=read_int32(Binary2),
	{State, Binary4}=read_int32(Binary3),
	Term = #charge{id=Id, awarddate=Awarddate, charge_num=Charge_num, state=State},
	{Term, Binary4}.

%%
decode_vp(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{Points, Binary2}=read_int32_list(Binary1),
	Term = #vp{id=Id, points=Points},
	{Term, Binary2}.

%%
%decode_vb(Binary0)->
% 	{Id, Binary1}=read_int32(Binary0),
% 	{Bone, Binary2}=read_string(Binary1),
% 	Term = #vb{id=Id, bone=Bone},
% 	{Term, Binary2}.

decode_vb(Binary0)->
 	{Id, Binary1}=read_int32(Binary0),
 	{Bone, Binary2}=read_int32(Binary1),
 	Term = #vb{id=Id, bone=Bone},
 	{Term, Binary2}.

%%
decode_giftinfo(Binary0)->
	{Needcharge, Binary1}=read_int32(Binary0),
	{Items, Binary2}=decode_list(Binary1, fun decode_lti/1),
	Term = #giftinfo{needcharge=Needcharge, items=Items},
	{Term, Binary2}.

%%
decode_aqrl(Binary0)->
	{Rolename, Binary1}=read_string(Binary0),
	{Score, Binary2}=read_int32(Binary1),
	Term = #aqrl{rolename=Rolename, score=Score},
	{Term, Binary2}.

%%
%decode_recharge(Binary0)->
%	{Id, Binary1}=read_int32(Binary0),
%	{State, Binary2}=read_int32(Binary1),
%	Term = #recharge{id=Id, state=State},
%	{Term, Binary2}.

decode_recharge(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{State, Binary2}=read_int32(Binary1),
	Term = #tab_state{id=Id, state=State},
	{Term, Binary2}.

%%
decode_li(Binary0)->
	{Lineid, Binary1}=read_int32(Binary0),
	{Rolecount, Binary2}=read_int32(Binary1),
	Term = #li{lineid=Lineid, rolecount=Rolecount},
	{Term, Binary2}.

%%
decode_stage(Binary0)->
	{Chapter, Binary1}=read_int32(Binary0),
	{Stageindex, Binary2}=read_int32(Binary1),
	{State, Binary3}=read_int32(Binary2),
	{Bestscore, Binary4}=read_int32(Binary3),
	{Rewardflag, Binary5}=read_int32(Binary4),
	{Entrytime, Binary6}=read_int32(Binary5),
	{Topone, Binary7}=decode_stagetop(Binary6),
	Term = #stage{chapter=Chapter, stageindex=Stageindex, state=State, bestscore=Bestscore, rewardflag=Rewardflag, entrytime=Entrytime, topone=Topone},
	{Term, Binary7}.

%%
decode_gsi(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{Showindex, Binary2}=read_int32(Binary1),
	{Realprice, Binary3}=read_int32(Binary2),
	{Buynum, Binary4}=read_int32(Binary3),
	Term = #gsi{id=Id, showindex=Showindex, realprice=Realprice, buynum=Buynum},
	{Term, Binary4}.

%%
decode_acs(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{State, Binary2}=read_int32(Binary1),
	Term = #acs{id=Id, state=State},
	{Term, Binary2}.

%%
decode_a(Binary0)->
	{Id, Binary1}=read_int64(Binary0),
	{Name, Binary2}=read_string(Binary1),
	{Ownerid, Binary3}=read_int64(Binary2),
	{Ownername, Binary4}=read_string(Binary3),
	{Ownerlevel, Binary5}=read_int32(Binary4),
	{Itemnum, Binary6}=read_int32(Binary5),
	Term = #a{id=Id, name=Name, ownerid=Ownerid, ownername=Ownername, ownerlevel=Ownerlevel, itemnum=Itemnum},
	{Term, Binary6}.

%%
decode_b(Binary0)->
	{Creatureid, Binary1}=read_int64(Binary0),
	{Damagetype, Binary2}=read_int32(Binary1),
	{Damage, Binary3}=read_int32(Binary2),
	Term = #b{creatureid=Creatureid, damagetype=Damagetype, damage=Damage},
	{Term, Binary3}.

%%
decode_c(Binary0)->
	{X, Binary1}=read_int32(Binary0),
	{Y, Binary2}=read_int32(Binary1),
	Term = #c{x=X, y=Y},
	{Term, Binary2}.

%%
decode_f(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{Level, Binary2}=read_int32(Binary1),
	{Lefttime, Binary3}=read_int32(Binary2),
	{Fulltime, Binary4}=read_int32(Binary3),
	{Requirevalue, Binary5}=read_int32(Binary4),
	{Contribution, Binary6}=read_int32(Binary5),
	{Tcontribution, Binary7}=read_int32(Binary6),
	Term = #f{id=Id, level=Level, lefttime=Lefttime, fulltime=Fulltime, requirevalue=Requirevalue, contribution=Contribution, tcontribution=Tcontribution},
	{Term, Binary7}.

%%
decode_g(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Rolename, Binary2}=read_string(Binary1),
	{Rolelevel, Binary3}=read_int32(Binary2),
	{Gender, Binary4}=read_int32(Binary3),
	{Classtype, Binary5}=read_int32(Binary4),
	{Posting, Binary6}=read_int32(Binary5),
	{Contribution, Binary7}=read_int32(Binary6),
	{Online, Binary8}=read_int32(Binary7),
	{Nickname, Binary9}=read_string(Binary8),
	{Tcontribution, Binary10}=read_int32(Binary9),
	{Fightforce, Binary11}=read_int32(Binary10),
	Term = #g{roleid=Roleid, rolename=Rolename, rolelevel=Rolelevel, gender=Gender, classtype=Classtype, posting=Posting, contribution=Contribution, online=Online, nickname=Nickname, tcontribution=Tcontribution, fightforce=Fightforce},
	{Term, Binary11}.

%%
decode_i(Binary0)->
	{Itemid_low, Binary1}=read_int32(Binary0),
	{Itemid_high, Binary2}=read_int32(Binary1),
	{Protoid, Binary3}=read_int32(Binary2),
	{Enchantments, Binary4}=read_int32(Binary3),
	{Count, Binary5}=read_int32(Binary4),
	{Slot, Binary6}=read_int32(Binary5),
	{Isbonded, Binary7}=read_int32(Binary6),
	{Socketsinfo, Binary8}=read_int32_list(Binary7),
	{Duration, Binary9}=read_int32(Binary8),
	{Enchant, Binary10}=decode_list(Binary9, fun decode_k/1),
	{Lefttime_s, Binary11}=read_int32(Binary10),
	Term = #i{itemid_low=Itemid_low, itemid_high=Itemid_high, protoid=Protoid, enchantments=Enchantments, count=Count, slot=Slot, isbonded=Isbonded, socketsinfo=Socketsinfo, duration=Duration, enchant=Enchant, lefttime_s=Lefttime_s},
	{Term, Binary11}.

%%
decode_k(Binary0)->
	{Key, Binary1}=read_int32(Binary0),
	{Value, Binary2}=read_int32(Binary1),
	Term = #k{key=Key, value=Value},
	{Term, Binary2}.

%%
decode_m(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Rolename, Binary2}=read_string(Binary1),
	{Level, Binary3}=read_int32(Binary2),
	{Classtype, Binary4}=read_int32(Binary3),
	{Gender, Binary5}=read_int32(Binary4),
	Term = #m{roleid=Roleid, rolename=Rolename, level=Level, classtype=Classtype, gender=Gender},
	{Term, Binary5}.

%%
decode_l(Binary0)->
	{Itemprotoid, Binary1}=read_int32(Binary0),
	{Count, Binary2}=read_int32(Binary1),
	Term = #l{itemprotoid=Itemprotoid, count=Count},
	{Term, Binary2}.

%%
decode_rl(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Name, Binary2}=read_string(Binary1),
	{X, Binary3}=read_int32(Binary2),
	{Y, Binary4}=read_int32(Binary3),
	{Friendly, Binary5}=read_int8(Binary4),
	{Attrs, Binary6}=decode_list(Binary5, fun decode_k/1),
	Term = #rl{roleid=Roleid, name=Name, x=X, y=Y, friendly=Friendly, attrs=Attrs},
	{Term, Binary6}.

%%
decode_o(Binary0)->
	{Objectid, Binary1}=read_int64(Binary0),
	{Objecttype, Binary2}=read_int32(Binary1),
	{Attrs, Binary3}=decode_list(Binary2, fun decode_k/1),
	Term = #o{objectid=Objectid, objecttype=Objecttype, attrs=Attrs},
	{Term, Binary3}.


%%
decode_q(Binary0)->
	{Questid, Binary1}=read_int32(Binary0),
	{Status, Binary2}=read_int32(Binary1),
	{Values, Binary3}=read_int32_list(Binary2),
	{Lefttime, Binary4}=read_int32(Binary3),
	Term = #q{questid=Questid, status=Status, values=Values, lefttime=Lefttime},
	{Term, Binary4}.

%%
decode_r(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Name, Binary2}=read_string(Binary1),
	{Lastmapid, Binary3}=read_int32(Binary2),
	{Classtype, Binary4}=read_int32(Binary3),
	{Gender, Binary5}=read_int32(Binary4),
	{Level, Binary6}=read_int32(Binary5),
	Term = #r{roleid=Roleid, name=Name, lastmapid=Lastmapid, classtype=Classtype, gender=Gender, level=Level},
	{Term, Binary6}.

%%
decode_s(Binary0)->
	{Skillid, Binary1}=read_int32(Binary0),
	{Level, Binary2}=read_int32(Binary1),
	{Lefttime, Binary3}=read_int32(Binary2),
	Term = #s{skillid=Skillid, level=Level, lefttime=Lefttime},
	{Term, Binary3}.

%%
decode_t(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Level, Binary2}=read_int32(Binary1),
	{Life, Binary3}=read_int32(Binary2),
	{Maxhp, Binary4}=read_int32(Binary3),
	{Mana, Binary5}=read_int32(Binary4),
	{Maxmp, Binary6}=read_int32(Binary5),
	{Posx, Binary7}=read_int32(Binary6),
	{Posy, Binary8}=read_int32(Binary7),
	{Mapid, Binary9}=read_int32(Binary8),
	{Lineid, Binary10}=read_int32(Binary9),
	{Cloth, Binary11}=read_int32(Binary10),
	{Arm, Binary12}=read_int32(Binary11),
	Term = #t{roleid=Roleid, level=Level, life=Life, maxhp=Maxhp, mana=Mana, maxmp=Maxmp, posx=Posx, posy=Posy, mapid=Mapid, lineid=Lineid, cloth=Cloth, arm=Arm},
	{Term, Binary12}.

%%
decode_ms(Binary0)->
	{Mailid, Binary1}=decode_mid(Binary0),
	{From, Binary2}=read_string(Binary1),
	{Titile, Binary3}=read_string(Binary2),
	{Status, Binary4}=read_int8(Binary3),
	{Type, Binary5}=read_int32(Binary4),
	{Has_add, Binary6}=read_int8(Binary5),
	{Leftseconds, Binary7}=read_int32(Binary6),
	{Month, Binary8}=read_int32(Binary7),
	{Day, Binary9}=read_int32(Binary8),
	Term = #ms{mailid=Mailid, from=From, titile=Titile, status=Status, type=Type, has_add=Has_add, leftseconds=Leftseconds, month=Month, day=Day},
	{Term, Binary9}.

%%
decode_nl(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Name, Binary2}=read_string(Binary1),
	{X, Binary3}=read_int32(Binary2),
	{Y, Binary4}=read_int32(Binary3),
	{Friendly, Binary5}=read_int8(Binary4),
	{Attrs, Binary6}=decode_list(Binary5, fun decode_k/1),
	Term = #nl{npcid=Npcid, name=Name, x=X, y=Y, friendly=Friendly, attrs=Attrs},
	{Term, Binary6}.

%%
decode_imi(Binary0)->
	{Mitemid, Binary1}=read_int32(Binary0),
	{Price, Binary2}=decode_list(Binary1, fun decode_ip/1),
	{Discount, Binary3}=decode_list(Binary2, fun decode_di/1),
	Term = #imi{mitemid=Mitemid, price=Price, discount=Discount},
	{Term, Binary3}.

%%
decode_duel_start_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #duel_start_s2c{roleid=Roleid},
	{Term, Binary1}.

%%
decode_eq(Binary0)->
	{Everqid, Binary1}=read_int32(Binary0),
	{Questid, Binary2}=read_int32(Binary1),
	{Free_fresh_times, Binary3}=read_int32(Binary2),
	{Round, Binary4}=read_int32(Binary3),
	{Section, Binary5}=read_int32(Binary4),
	{Quality, Binary6}=read_int32(Binary5),
	Term = #eq{everqid=Everqid, questid=Questid, free_fresh_times=Free_fresh_times, round=Round, section=Section, quality=Quality},
	{Term, Binary6}.

%%
decode_ltm(Binary0)->
	{Layer, Binary1}=read_int32(Binary0),
	{Rolename, Binary2}=read_string(Binary1),
	{Time, Binary3}=read_int32(Binary2),
	Term = #ltm{layer=Layer, rolename=Rolename, time=Time},
	{Term, Binary3}.

%%
decode_md(Binary0)->
	{Mailid, Binary1}=decode_mid(Binary0),
	{Content, Binary2}=read_string(Binary1),
	{Add_silver, Binary3}=read_int64(Binary2),
	{Add_gold, Binary4}=read_int32(Binary3),
	{Add_item, Binary5}=decode_list(Binary4, fun decode_i/1),
	Term = #md{mailid=Mailid, content=Content, add_silver=Add_silver, add_gold=Add_gold, add_item=Add_item},
	{Term, Binary5}.

%%
decode_tsi(Binary0)->
	{Itemprotoid, Binary1}=read_int32(Binary0),
	{Solt, Binary2}=read_int32(Binary1),
	{Count, Binary3}=read_int32(Binary2),
	{Itemsign, Binary4}=read_int32(Binary3),
	Term = #tsi{itemprotoid=Itemprotoid, solt=Solt, count=Count, itemsign=Itemsign},
	{Term, Binary4}.

%%
decode_gbs(Binary0)->
	{Index, Binary1}=read_int32(Binary0),
	{Guildlid, Binary2}=read_int32(Binary1),
	{Guildhid, Binary3}=read_int32(Binary2),
	{Guildname, Binary4}=read_string(Binary3),
	Term = #gbs{index=Index, guildlid=Guildlid, guildhid=Guildhid, guildname=Guildname},
	{Term, Binary4}.

%%
decode_si(Binary0)->
	{Item, Binary1}=decode_i(Binary0),
	{Money, Binary2}=read_int32(Binary1),
	{Gold, Binary3}=read_int32(Binary2),
	{Silver, Binary4}=read_int32(Binary3),
	Term = #si{item=Item, money=Money, gold=Gold, silver=Silver},
	{Term, Binary4}.

%%
decode_dfr(Binary0)->
	{Fn, Binary1}=read_string(Binary0),
	{Level, Binary2}=read_int32(Binary1),
	{Job, Binary3}=read_int32(Binary2),
	{Guildname, Binary4}=read_string(Binary3),
	{Gender, Binary5}=read_int32(Binary4),
	Term = #dfr{fn=Fn, level=Level, job=Job, guildname=Guildname, gender=Gender},
	{Term, Binary5}.

%%
decode_pp(Binary0)->
	{Protoid, Binary1}=read_int32(Binary0),
	{Quality, Binary2}=read_int32(Binary1),
	{Strength, Binary3}=read_int32(Binary2),
	{Agile, Binary4}=read_int32(Binary3),
	{Intelligence, Binary5}=read_int32(Binary4),
	{Stamina, Binary6}=read_int32(Binary5),
	{Growth, Binary7}=read_int32(Binary6),
	{Stamina_growth, Binary8}=read_int32(Binary7),
	{Class_type, Binary9}=read_int32(Binary8),
	{Talents, Binary10}=read_int32_list(Binary9),
	Term = #pp{protoid=Protoid, quality=Quality, strength=Strength, agile=Agile, intelligence=Intelligence, stamina=Stamina, growth=Growth, stamina_growth=Stamina_growth, class_type=Class_type, talents=Talents},
	{Term, Binary10}.

%%排行榜结构
decode_rk(Binary0)->
	{Kv, Binary1}=decode_list(Binary0, fun decode_k/1),
	{Args, Binary2}=read_int32_list(Binary1),
	Term = #rk{kv=Kv, args=Args},
	{Term, Binary2}.

%%
decode_gmp(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Lineid, Binary2}=read_int32(Binary1),
	{Mapid, Binary3}=read_int32(Binary2),
	Term = #gmp{roleid=Roleid, lineid=Lineid, mapid=Mapid},
	{Term, Binary3}.

%%
decode_rr(Binary0)->
	{Id, Binary1}=read_int64(Binary0),
	{Name, Binary2}=read_string(Binary1),
	{Level, Binary3}=read_int32(Binary2),
	{Classid, Binary4}=read_int32(Binary3),
	{Instance, Binary5}=read_int32(Binary4),
	Term = #rr{id=Id, name=Name, level=Level, classid=Classid, instance=Instance},
	{Term, Binary5}.

%%
decode_psl(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Slots, Binary2}=decode_list(Binary1, fun decode_psll/1),
	Term = #psl{petid=Petid, slots=Slots},
	{Term, Binary2}.

%%
decode_ssi(Binary0)->
	{Item, Binary1}=decode_si(Binary0),
	{Stallid, Binary2}=read_int64(Binary1),
	{Ownerid, Binary3}=read_int64(Binary2),
	{Ownername, Binary4}=read_string(Binary3),
	{Itemnum, Binary5}=read_int32(Binary4),
	{Isonline, Binary6}=read_int32(Binary5),
	Term = #ssi{item=Item, stallid=Stallid, ownerid=Ownerid, ownername=Ownername, itemnum=Itemnum, isonline=Isonline},
	{Term, Binary6}.

%%
decode_tr(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Rolename, Binary2}=read_string(Binary1),
	{Rolegender, Binary3}=read_int32(Binary2),
	{Roleclass, Binary4}=read_int32(Binary3),
	{Rolelevel, Binary5}=read_int32(Binary4),
	{Kills, Binary6}=read_int32(Binary5),
	{Score, Binary7}=read_int32(Binary6),
	Term = #tr{roleid=Roleid, rolename=Rolename, rolegender=Rolegender, roleclass=Roleclass, rolelevel=Rolelevel, kills=Kills, score=Score},
	{Term, Binary7}.

%%
decode_spa(Binary0)->
	{Spaid, Binary1}=read_int32(Binary0),
	{Join_count, Binary2}=read_int32(Binary1),
	{Limit, Binary3}=read_int32(Binary2),
	Term = #spa{spaid=Spaid, join_count=Join_count, limit=Limit},
	{Term, Binary3}.

%%
decode_lti(Binary0)->
	{Protoid, Binary1}=read_int32(Binary0),
	{Item_count, Binary2}=read_int32(Binary1),
	Term = #lti{protoid=Protoid, item_count=Item_count},
	{Term, Binary2}.

%%
decode_dh(Binary0)->
	{Itemclsid, Binary1}=read_int32(Binary0),
	{Consume, Binary2}=decode_list(Binary1, fun decode_l/1),
	{Money, Binary3}=decode_list(Binary2, fun decode_ip/1),
	Term = #dh{itemclsid=Itemclsid, consume=Consume, money=Money},
	{Term, Binary3}.

%%
decode_zoneinfo(Binary0)->
	{Zoneid, Binary1}=read_int32(Binary0),
	{State, Binary2}=read_int32(Binary1),
	Term = #zoneinfo{zoneid=Zoneid, state=State},
	{Term, Binary2}.

%%
decode_rc(Binary0)->
	{Rolename, Binary1}=read_string_list(Binary0),
	{Args, Binary2}=read_int32_list(Binary1),
	Term = #rc{rolename=Rolename, args=Args},
	{Term, Binary2}.

%%
decode_rp(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Petname, Binary2}=read_string(Binary1),
	{Rolename, Binary3}=read_string(Binary2),
	{Args, Binary4}=read_int32(Binary3),
	Term = #rp{petid=Petid, petname=Petname, rolename=Rolename, args=Args},
	{Term, Binary4}.


%%
decode_gti(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{Showindex, Binary2}=read_int32(Binary1),
	{Realprice, Binary3}=read_int32(Binary2),
	{Buynum, Binary4}=read_int32(Binary3),
	Term = #gti{id=Id, showindex=Showindex, realprice=Realprice, buynum=Buynum},
	{Term, Binary4}.

%%
decode_psk(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Skillid, Binary2}=read_int32(Binary1),
	{Level, Binary3}=read_int32(Binary2),
	Term = #psk{slot=Slot, skillid=Skillid, level=Level},
	{Term, Binary3}.

%%
decode_stagetop(Binary0)->
	{Serverid, Binary1}=read_int32(Binary0),
	{Roleid, Binary2}=read_int64(Binary1),
	{Name, Binary3}=read_string(Binary2),
	{Bestscore, Binary4}=read_int32(Binary3),
	Term = #stagetop{serverid=Serverid, roleid=Roleid, name=Name, bestscore=Bestscore},
	{Term, Binary4}.

%%
decode_psll(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Status, Binary2}=read_int32(Binary1),
	Term = #psll{slot=Slot, status=Status},
	{Term, Binary2}.

%%
decode_mid(Binary0)->
	{Midlow, Binary1}=read_int32(Binary0),
	{Midhigh, Binary2}=read_int32(Binary1),
	Term = #mid{midlow=Midlow, midhigh=Midhigh},
	{Term, Binary2}.

%%
decode_pfr(Binary0)->
	{Fn, Binary1}=read_string(Binary0),
	{Lineid, Binary2}=read_int32(Binary1),
	{Mapid, Binary3}=read_int32(Binary2),
	{Posx, Binary4}=read_int32(Binary3),
	{Posy, Binary5}=read_int32(Binary4),
	Term = #pfr{fn=Fn, lineid=Lineid, mapid=Mapid, posx=Posx, posy=Posy},
	{Term, Binary5}.

%%
decode_jszd(Binary0)->
	{Id, Binary1}=read_string(Binary0),
	{Name, Binary2}=read_string(Binary1),
	{Score, Binary3}=read_int32(Binary2),
	{Rank, Binary4}=read_int32(Binary3),
	{Peoples, Binary5}=read_int32(Binary4),
	Term = #jszd{id=Id, name=Name, score=Score, rank=Rank, peoples=Peoples},
	{Term, Binary5}.

%%
decode_ki(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Rolename, Binary2}=read_string(Binary1),
	{Roleclass, Binary3}=read_int32(Binary2),
	{Rolelevel, Binary4}=read_int32(Binary3),
	{Times, Binary5}=read_int32(Binary4),
	Term = #ki{roleid=Roleid, rolename=Rolename, roleclass=Roleclass, rolelevel=Rolelevel, times=Times},
	{Term, Binary5}.

%%
decode_oqe(Binary0)->
	{Questid, Binary1}=read_int32(Binary0),
	{Addition, Binary2}=read_int32(Binary1),
	Term = #oqe{questid=Questid, addition=Addition},
	{Term, Binary2}.

%%
decode_ti(Binary0)->
	{Trade_slot, Binary1}=read_int32(Binary0),
	{Item_attrs, Binary2}=decode_i(Binary1),
	Term = #ti{trade_slot=Trade_slot, item_attrs=Item_attrs},
	{Term, Binary2}.

%%
decode_gr(Binary0)->
	{Guildlid, Binary1}=read_int32(Binary0),
	{Guildhid, Binary2}=read_int32(Binary1),
	{Guildname, Binary3}=read_string(Binary2),
	{Level, Binary4}=read_int32(Binary3),
	{Membernum, Binary5}=read_int32(Binary4),
	{Formalnum, Binary6}=read_int32(Binary5),
	{Leader, Binary7}=read_string(Binary6),
	{Restrict, Binary8}=read_int32(Binary7),
	{Facslevel, Binary9}=read_int32_list(Binary8),
	{Applyflag, Binary10}=read_int32(Binary9),
	{Createyear, Binary11}=read_int32(Binary10),
	{Createmonth, Binary12}=read_int32(Binary11),
	{Createday, Binary13}=read_int32(Binary12),
	{Sort, Binary14}=read_int32(Binary13),
	{Guild_strength, Binary15}=read_int32(Binary14),
	{Guild_silver, Binary16}=read_int64(Binary15),
	Term = #gr{guildlid=Guildlid, guildhid=Guildhid, guildname=Guildname, level=Level, membernum=Membernum, formalnum=Formalnum, leader=Leader, restrict=Restrict, facslevel=Facslevel, applyflag=Applyflag, createyear=Createyear, createmonth=Createmonth, createday=Createday, sort=Sort, guild_strength=Guild_strength, guild_silver=Guild_silver},
	{Term, Binary16}.



%%
decode_bf(Binary0)->
	{Bufferid, Binary1}=read_int32(Binary0),
	{Bufferlevel, Binary2}=read_int32(Binary1),
	{Durationtime, Binary3}=read_int32(Binary2),
	Term = #bf{bufferid=Bufferid, bufferlevel=Bufferlevel, durationtime=Durationtime},
	{Term, Binary3}.

%%
decode_tp(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{X, Binary2}=read_int32(Binary1),
	{Y, Binary3}=read_int32(Binary2),
	Term = #tp{roleid=Roleid, x=X, y=Y},
	{Term, Binary3}.

%%
decode_cl(Binary0)->
	{Post, Binary1}=read_int32(Binary0),
	{Postindex, Binary2}=read_int32(Binary1),
	{Roleid, Binary3}=read_int64(Binary2),
	{Name, Binary4}=read_string(Binary3),
	{Gender, Binary5}=read_int32(Binary4),
	{Roleclass, Binary6}=read_int32(Binary5),
	Term = #cl{post=Post, postindex=Postindex, roleid=Roleid, name=Name, gender=Gender, roleclass=Roleclass},
	{Term, Binary6}.

%%
decode_fr(Binary0)->%%@@wb
	{Id, Binary1}=read_int64(Binary0),
	{Fn, Binary2}=read_string(Binary1),
	{Classid, Binary3}=read_int32(Binary2),
	{Gender, Binary4}=read_int32(Binary3),
	{Online, Binary5}=read_int32(Binary4),
	{Sign, Binary6}=read_string(Binary5),
    {Intimacy, Binary7}=read_int32(Binary6),
    {Level, Binary8}=read_int32(Binary7),
	Term = #fr{id=Id, fn=Fn, classid=Classid, gender=Gender, online=Online, sign=Sign,intimacy=Intimacy,level=Level},
	{Term, Binary8}.

%%
decode_ag(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Leaderid, Binary2}=read_int64(Binary1),
	{Leadername, Binary3}=read_string(Binary2),
	{Leaderlevel, Binary4}=read_int32(Binary3),
	{Member_num, Binary5}=read_int32(Binary4),
	Term = #ag{roleid=Roleid, leaderid=Leaderid, leadername=Leadername, leaderlevel=Leaderlevel, member_num=Member_num},
	{Term, Binary5}.

%%
decode_hc(Binary0)->
	{Clsid, Binary1}=read_int32(Binary0),
	{Entryid, Binary2}=read_int64(Binary1),
	{Pos, Binary3}=read_int32(Binary2),
	Term = #hc{clsid=Clsid, entryid=Entryid, pos=Pos},
	{Term, Binary3}.

%%
decode_di(Binary0)->
	{Disctype, Binary1}=read_int32(Binary0),
	{Count, Binary2}=read_int32(Binary1),
	Term = #di{disctype=Disctype, count=Count},
	{Term, Binary2}.

%%
decode_mi(Binary0)->
	{Mitemid, Binary1}=read_int32(Binary0),
	{Ntype, Binary2}=read_int32(Binary1),
	{Ishot, Binary3}=read_int32(Binary2),
	{Sort, Binary4}=read_int32(Binary3),
	{Price, Binary5}=decode_list(Binary4, fun decode_ip/1),
	{Discount, Binary6}=decode_list(Binary5, fun decode_di/1),
	Term = #mi{mitemid=Mitemid, ntype=Ntype, ishot=Ishot, sort=Sort, price=Price, discount=Discount},
	{Term, Binary6}.

%%
decode_br(Binary0)->
	{Id, Binary1}=read_int64(Binary0),
	{Fn, Binary2}=read_string(Binary1),
	{Classid, Binary3}=read_int32(Binary2),
	{Gender, Binary4}=read_int32(Binary3),
	Term = #br{id=Id, fn=Fn, classid=Classid, gender=Gender},
	{Term, Binary4}.

%%
decode_ri(Binary0)->
	{Leader_id, Binary1}=read_int64(Binary0),
	{Leader_line, Binary2}=read_int32(Binary1),
	{Instance, Binary3}=read_int32(Binary2),
	{Members, Binary4}=decode_list(Binary3, fun decode_m/1),
	{Description, Binary5}=read_string(Binary4),
	Term = #ri{leader_id=Leader_id, leader_line=Leader_line, instance=Instance, members=Members, description=Description},
	{Term, Binary5}.

%%
decode_tab_state(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{State, Binary2}=read_int32(Binary1),
	Term = #tab_state{id=Id, state=State},
	{Term, Binary2}.

%%
decode_rcs(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Today_count, Binary2}=read_int32(Binary1),
	{Total_count, Binary3}=read_int32(Binary2),
	Term = #rcs{roleid=Roleid, today_count=Today_count, total_count=Total_count},
	{Term, Binary3}.

%%
decode_smi(Binary0)->
	{Mitemid, Binary1}=read_int32(Binary0),
	{Sort, Binary2}=read_int32(Binary1),
	{Uptime, Binary3}=read_int32(Binary2),
	{Mycount, Binary4}=read_int32(Binary3),
	{Price, Binary5}=decode_list(Binary4, fun decode_ip/1),
	{Discount, Binary6}=decode_list(Binary5, fun decode_di/1),
	Term = #smi{mitemid=Mitemid, sort=Sort, uptime=Uptime, mycount=Mycount, price=Price, discount=Discount},
	{Term, Binary6}.

%%
decode_tbi(Binary0)->
	{Battleid, Binary1}=read_int32(Binary0),
	{Curnum, Binary2}=read_int32(Binary1),
	{Totlenum, Binary3}=read_int32(Binary2),
	Term = #tbi{battleid=Battleid, curnum=Curnum, totlenum=Totlenum},
	{Term, Binary3}.

%%
decode_chess_spirit_role_info_s2c(Binary0)->
	{Power, Binary1}=read_int32(Binary0),
	{Chesspower, Binary2}=read_int32(Binary1),
	{Max_power, Binary3}=read_int32(Binary2),
	{Max_chesspower, Binary4}=read_int32(Binary3),
	{Share_skills, Binary5}=decode_list(Binary4, fun decode_s/1),
	{Self_skills, Binary6}=decode_list(Binary5, fun decode_s/1),
	{Chess_skills, Binary7}=decode_list(Binary6, fun decode_s/1),
	{Type, Binary8}=read_int32(Binary7),
	Term = #chess_spirit_role_info_s2c{power=Power, chesspower=Chesspower, max_power=Max_power, max_chesspower=Max_chesspower, share_skills=Share_skills, self_skills=Self_skills, chess_skills=Chess_skills, type=Type},
	Term.

%%
decode_moneygame_prepare_s2c(Binary0)->
	{Second, Binary1}=read_int32(Binary0),
	Term = #moneygame_prepare_s2c{second=Second},
	Term.

%%
decode_guild_bonfire_start_s2c(Binary0)->
	{Lefttime, Binary1}=read_int32(Binary0),
	Term = #guild_bonfire_start_s2c{lefttime=Lefttime},
	Term.

%%
decode_money_from_monster_s2c(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Npcproto, Binary2}=read_int32(Binary1),
	{Money, Binary3}=read_int32(Binary2),
	Term = #money_from_monster_s2c{npcid=Npcid, npcproto=Npcproto, money=Money},
	Term.

%%
decode_battlefield_info_c2s(Binary0)->
	{Battle, Binary1}=read_int32(Binary0),
	Term = #battlefield_info_c2s{battle=Battle},
	Term.

%%
decode_chess_spirit_game_over_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Section, Binary2}=read_int32(Binary1),
	{Used_time_s, Binary3}=read_int32(Binary2),
	{Reason, Binary4}=read_int32(Binary3),
	Term = #chess_spirit_game_over_s2c{type=Type, section=Section, used_time_s=Used_time_s, reason=Reason},
	Term.

%%
decode_guild_monster_opt_result_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	Term = #guild_monster_opt_result_s2c{result=Result},
	Term.

%%
decode_activity_state_update_s2c(Binary0)->
	{Updateas, Binary1}=decode_acs(Binary0),
	Term = #activity_state_update_s2c{updateas=Updateas},
	Term.

%%
decode_change_smith_need_contribution_c2s(Binary0)->
	{Contribution, Binary1}=read_int32(Binary0),
	Term = #change_smith_need_contribution_c2s{contribution=Contribution},
	Term.

%%
decode_equipment_fenjie_c2s(Binary0)->
	{Equipment, Binary1}=read_int32_list(Binary0),
	Term = #equipment_fenjie_c2s{equipment=Equipment},
	Term.

%%
decode_equip_fenjie_optresult_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	Term = #equip_fenjie_optresult_s2c{result=Result},
	Term.

%%
decode_vip_role_use_flyshoes_s2c(Binary0)->
	{Leftnum, Binary1}=read_int32(Binary0),
	{Totlenum, Binary2}=read_int32(Binary1),
	Term = #vip_role_use_flyshoes_s2c{leftnum=Leftnum, totlenum=Totlenum},
	Term.

%%
decode_join_vip_map_c2s(Binary0)->
	{Transid, Binary1}=read_int32(Binary0),
	Term = #join_vip_map_c2s{transid=Transid},
	Term.

%%
decode_mp_package_s2c(Binary0)->
	{Itemidl, Binary1}=read_int32(Binary0),
	{Itemidh, Binary2}=read_int32(Binary1),
	{Buffid, Binary3}=read_int32(Binary2),
	Term = #mp_package_s2c{itemidl=Itemidl, itemidh=Itemidh, buffid=Buffid},
	Term.

%%
decode_join_battle_error_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #join_battle_error_s2c{errno=Errno},
	Term.

%%
decode_leave_guild_instance_c2s(Binary0)->
	Term = #leave_guild_instance_c2s{},
	Term.

%%
decode_join_guild_instance_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #join_guild_instance_c2s{type=Type},
	Term.

%%
decode_sell_item_fail_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #sell_item_fail_s2c{reason=Reason},
	Term.

%%
decode_treasure_chest_broad_s2c(Binary0)->
	{Rolename, Binary1}=read_string(Binary0),
	{Item, Binary2}=decode_lti(Binary1),
	Term = #treasure_chest_broad_s2c{rolename=Rolename, item=Item},
	Term.

%%
decode_npc_function_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	Term = #npc_function_c2s{npcid=Npcid},
	Term.

%%
decode_pet_rename_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Newname, Binary2}=read_string(Binary1),
	{Slot, Binary3}=read_int32(Binary2),
	{Type, Binary4}=read_int32(Binary3),
	Term = #pet_rename_c2s{petid=Petid, newname=Newname, slot=Slot, type=Type},
	Term.

%%
decode_welfare_activity_update_s2c(Binary0)->
	{Typenumber, Binary1}=read_int32(Binary0),
	{State, Binary2}=read_int32(Binary1),
	{Result, Binary3}=read_int32(Binary2),
	Term = #welfare_activity_update_s2c{typenumber=Typenumber, state=State, result=Result},
	Term.

%%
decode_equipment_enchant_c2s(Binary0)->
	{Equipment, Binary1}=read_int32(Binary0),
	{Enchant, Binary2}=read_int32(Binary1),
	Term = #equipment_enchant_c2s{equipment=Equipment, enchant=Enchant},
	Term.

%%
decode_reset_random_rolename_c2s(Binary0)->
	Term = #reset_random_rolename_c2s{},
	Term.

%%
decode_treasure_chest_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #treasure_chest_failed_s2c{reason=Reason},
	Term.

%%
decode_activity_forecast_begin_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Beginhour, Binary2}=read_int32(Binary1),
	{Beginmin, Binary3}=read_int32(Binary2),
	{Beginsec, Binary4}=read_int32(Binary3),
	{Endhour, Binary5}=read_int32(Binary4),
	{Endmin, Binary6}=read_int32(Binary5),
	{Endsec, Binary7}=read_int32(Binary6),
	Term = #activity_forecast_begin_s2c{type=Type, beginhour=Beginhour, beginmin=Beginmin, beginsec=Beginsec, endhour=Endhour, endmin=Endmin, endsec=Endsec},
	Term.

%%
decode_moneygame_cur_sec_s2c(Binary0)->
	{Cursec, Binary1}=read_int32(Binary0),
	{Maxsec, Binary2}=read_int32(Binary1),
	Term = #moneygame_cur_sec_s2c{cursec=Cursec, maxsec=Maxsec},
	Term.

%%
decode_npc_function_s2c(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Values, Binary2}=decode_list(Binary1, fun decode_kl/1),
	{Quests, Binary3}=read_int32_list(Binary2),
	{Queststate, Binary4}=read_int32_list(Binary3),
	{Everquests, Binary5}=read_int32_list(Binary4),
	Term = #npc_function_s2c{npcid=Npcid, values=Values, quests=Quests, queststate=Queststate, everquests=Everquests},
	Term.

%%
decode_set_black_c2s(Binary0)->
	{Fn, Binary1}=read_string(Binary0),
	Term = #set_black_c2s{fn=Fn},
	Term.

%%
decode_fatigue_prompt_s2c(Binary0)->
	{Prompt, Binary1}=read_string(Binary0),
	Term = #fatigue_prompt_s2c{prompt=Prompt},
	Term.

%%
decode_quest_complete_failed_s2c(Binary0)->
	{Questid, Binary1}=read_int32(Binary0),
	{Errno, Binary2}=read_int32(Binary1),
	Term = #quest_complete_failed_s2c{questid=Questid, errno=Errno},
	Term.

%%
decode_pet_skill_slot_lock_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	{Status, Binary3}=read_int32(Binary2),
	Term = #pet_skill_slot_lock_c2s{petid=Petid, slot=Slot, status=Status},
	Term.

%%
decode_treasure_storage_delitem_s2c(Binary0)->
	{Start, Binary1}=read_int32(Binary0),
	{Length, Binary2}=read_int32(Binary1),
	Term = #treasure_storage_delitem_s2c{start=Start, length=Length},
	Term.

%%
decode_unequip_item_for_pet_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	Term = #unequip_item_for_pet_c2s{petid=Petid, slot=Slot},
	Term.

%%
decode_congratulations_levelup_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Level, Binary2}=read_int32(Binary1),
	{Type, Binary3}=read_int32(Binary2),
	Term = #congratulations_levelup_c2s{roleid=Roleid, level=Level, type=Type},
	Term.

%%
decode_goals_error_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #goals_error_s2c{reason=Reason},
	Term.

%%@@wb
%%decode_achieve_open_c2s(Binary0)->
%%	Term = #achieve_open_c2s{},
%%	Term.

%%
%decode_chat_c2s(Binary0)->
%	{Type, Binary1}=read_int32(Binary0),
%	{Desserverid, Binary2}=read_int32(Binary1),
%	{Desrolename, Binary3}=read_string(Binary2),
%	{Msginfo, Binary4}=read_string(Binary3),
%	{Details, Binary5}=read_string_list(Binary4),
%	Term = #chat_c2s{type=Type, desserverid=Desserverid, desrolename=Desrolename, msginfo=Msginfo, details=Details},
%	Term.
%%@@wb20130428 add chat reptype
decode_chat_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Desserverid, Binary2}=read_int32(Binary1),
	{Desrolename, Binary3}=read_string(Binary2),
	{Msginfo, Binary4}=read_string(Binary3),
	{Details, Binary5}=read_string_list(Binary4),
	{Reptype, Binary6}=read_int32(Binary5),
	Term = #chat_c2s{type=Type, desserverid=Desserverid, desrolename=Desrolename, msginfo=Msginfo, details=Details, reptype=Reptype},
	Term.
%%
decode_equipment_enchant_s2c(Binary0)->
	{Enchants, Binary1}=decode_list(Binary0, fun decode_k/1),
	Term = #equipment_enchant_s2c{enchants=Enchants},
	Term.

%%
decode_treasure_storage_opt_s2c(Binary0)->
	{Code, Binary1}=read_int32(Binary0),
	Term = #treasure_storage_opt_s2c{code=Code},
	Term.

%%
decode_answer_sign_notice_s2c(Binary0)->
	{Lefttime, Binary1}=read_float(Binary0),
	Term = #answer_sign_notice_s2c{lefttime=Lefttime},
	Term.

%%
decode_call_guild_monster_c2s(Binary0)->
	{Monsterid, Binary1}=read_int32(Binary0),
	Term = #call_guild_monster_c2s{monsterid=Monsterid},
	Term.

%%
decode_ride_pet_synthesis_c2s(Binary0)->
	{Slot_a, Binary1}=read_int32(Binary0),
	{Slot_b, Binary2}=read_int32(Binary1),
	{Itemslot, Binary3}=read_int32(Binary2),
	{Type, Binary4}=read_int32(Binary3),
	Term = #ride_pet_synthesis_c2s{slot_a=Slot_a, slot_b=Slot_b, itemslot=Itemslot, type=Type},
	Term.

%%
decode_guild_info_s2c(Binary0)->
	{Guildname, Binary1}=read_string(Binary0),
	{Level, Binary2}=read_int32(Binary1),
	{Silver, Binary3}=read_int32(Binary2),
	{Gold, Binary4}=read_int32(Binary3),
	{Notice, Binary5}=read_string(Binary4),
	{Roleinfos, Binary6}=decode_list(Binary5, fun decode_g/1),
	{Facinfos, Binary7}=decode_list(Binary6, fun decode_f/1),
	{Chatgroup, Binary8}=read_string(Binary7),
	{Voicegroup, Binary9}=read_string(Binary8),
	{Guild_strength, Binary10}=read_int32(Binary9),
	Term = #guild_info_s2c{guildname=Guildname, level=Level, silver=Silver, gold=Gold, notice=Notice, roleinfos=Roleinfos, facinfos=Facinfos, chatgroup=Chatgroup, voicegroup=Voicegroup, guild_strength=Guild_strength},
	Term.

%%
%decode_achieve_init_s2c(Binary0)->
%	{Parts, Binary1}=decode_list(Binary0, fun decode_ach/1),
%	Term = #achieve_init_s2c{parts=Parts},
%	Term.


%%
decode_questgiver_states_update_c2s(Binary0)->
	{Npcid, Binary1}=read_int64_list(Binary0),
	Term = #questgiver_states_update_c2s{npcid=Npcid},
	Term.

%%
decode_activity_boss_born_init_c2s(Binary0)->
	Term = #activity_boss_born_init_c2s{},
	Term.

%%
decode_play_effects_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Optroleid, Binary2}=read_int64(Binary1),
	{Effectid, Binary3}=read_int32(Binary2),
	Term = #play_effects_s2c{type=Type, optroleid=Optroleid, effectid=Effectid},
	Term.

%%
decode_festival_recharge_s2c(Binary0)->
	{Festival_id, Binary1}=read_int32(Binary0),
	{State, Binary2}=read_int32(Binary1),
	{Starttime, Binary3}=decode_time_struct(Binary2),
	{Endtime, Binary4}=decode_time_struct(Binary3),
	{Award_limit_time, Binary5}=decode_time_struct(Binary4),
	{Lefttime, Binary6}=read_int64(Binary5),
	{Today_charge_num, Binary7}=read_int32(Binary6),
	{Exchange_info, Binary8}=decode_list(Binary7, fun decode_charge/1),
	{Gift, Binary9}=decode_list(Binary8, fun decode_giftinfo/1),
	Term = #festival_recharge_s2c{festival_id=Festival_id, state=State, starttime=Starttime, endtime=Endtime, award_limit_time=Award_limit_time, lefttime=Lefttime, today_charge_num=Today_charge_num, exchange_info=Exchange_info, gift=Gift},
	Term.

%%
decode_entry_loop_instance_vote_s2c(Binary0)->
	{State, Binary1}=read_int32_list(Binary0),
	Term = #entry_loop_instance_vote_s2c{state=State},
	Term.

%%
decode_facebook_bind_check_c2s(Binary0)->
	Term = #facebook_bind_check_c2s{},
	Term.

%%
decode_chess_spirit_quit_c2s(Binary0)->
	Term = #chess_spirit_quit_c2s{},
	Term.

%%
decode_spa_update_count_s2c(Binary0)->
	{Chopping, Binary1}=read_int32(Binary0),
	{Swimming, Binary2}=read_int32(Binary1),
	Term = #spa_update_count_s2c{chopping=Chopping, swimming=Swimming},
	Term.

%%收藏送礼
decode_collect_page_c2s(Binary0)->
	Term = #collect_page_c2s{},
	Term.

%%
decode_guild_update_apply_result_s2c(Binary0)->
	{Guildlid, Binary1}=read_int32(Binary0),
	{Guildhid, Binary2}=read_int32(Binary1),
	{Result, Binary3}=read_int32(Binary2),
	Term = #guild_update_apply_result_s2c{guildlid=Guildlid, guildhid=Guildhid, result=Result},
	Term.

%%
decode_equipment_recast_c2s(Binary0)->
	{Equipment, Binary1}=read_int32(Binary0),
	{Recast, Binary2}=read_int32(Binary1),
	{Type, Binary3}=read_int32(Binary2),
	{Lock_arr, Binary4}=read_int32_list(Binary3),
	Term = #equipment_recast_c2s{equipment=Equipment, recast=Recast, type=Type, lock_arr=Lock_arr},
	Term.

%%
decode_answer_sign_request_c2s(Binary0)->
	Term = #answer_sign_request_c2s{},
	Term.

%%
decode_rank_disdain_role_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #rank_disdain_role_c2s{roleid=Roleid},
	Term.

%%
decode_treasure_chest_raffle_c2s(Binary0)->
	Term = #treasure_chest_raffle_c2s{},
	Term.

%%
decode_pet_upgrade_quality_up_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Result, Binary2}=read_int32(Binary1),
	{Value, Binary3}=read_int32(Binary2),
	Term = #pet_upgrade_quality_up_s2c{type=Type, result=Result, value=Value},
	Term.

%%
decode_activity_value_init_c2s(Binary0)->
	Term = #activity_value_init_c2s{},
	Term.

%%
decode_chess_spirit_log_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Lastsec, Binary2}=read_int32(Binary1),
	{Lasttime, Binary3}=read_int32(Binary2),
	{Bestsec, Binary4}=read_int32(Binary3),
	{Bestsectime, Binary5}=read_int32(Binary4),
	{Canreward, Binary6}=read_int32(Binary5),
	{Rewardexp, Binary7}=read_int32(Binary6),
	{Rewarditems, Binary8}=decode_list(Binary7, fun decode_l/1),
	Term = #chess_spirit_log_s2c{type=Type, lastsec=Lastsec, lasttime=Lasttime, bestsec=Bestsec, bestsectime=Bestsectime, canreward=Canreward, rewardexp=Rewardexp, rewarditems=Rewarditems},
	Term.

%%
decode_mail_get_addition_s2c(Binary0)->
	{Mailid, Binary1}=decode_mid(Binary0),
	Term = #mail_get_addition_s2c{mailid=Mailid},
	Term.

%%
decode_offline_exp_error_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #offline_exp_error_s2c{reason=Reason},
	Term.

%%
decode_inspect_pet_c2s(Binary0)->
	{Serverid, Binary1}=read_int32(Binary0),
	{Rolename, Binary2}=read_string(Binary1),
	{Petid, Binary3}=read_int64(Binary2),
	Term = #inspect_pet_c2s{serverid=Serverid, rolename=Rolename, petid=Petid},
	Term.

%%
decode_christmas_activity_reward_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #christmas_activity_reward_c2s{type=Type},
	Term.

%%
decode_answer_sign_success_s2c(Binary0)->
	Term = #answer_sign_success_s2c{},
	Term.

%%
decode_rank_praise_role_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #rank_praise_role_c2s{roleid=Roleid},
	Term.

%%收藏送礼
decode_collect_page_s2c(Binary0)->
	Term = #collect_page_s2c{},
	Term.

%%
decode_sitdown_c2s(Binary0)->
	Term = #sitdown_c2s{},
	Term.

%%
decode_activity_boss_born_init_s2c(Binary0)->
	{Bslist, Binary1}=decode_list(Binary0, fun decode_bs/1),
	Term = #activity_boss_born_init_s2c{bslist=Bslist},
	Term.

%%
decode_activity_boss_born_update_s2c(Binary0)->
	{Updatebs, Binary1}=decode_bs(Binary0),
	Term = #activity_boss_born_update_s2c{updatebs=Updatebs},
	Term.

%%
%decode_chat_s2c(Binary0)->
%	{Type, Binary1}=read_int32(Binary0),
%	{Serverid, Binary2}=read_int32(Binary1),
%	{Privateflag, Binary3}=read_int32(Binary2),
%	{Desroleid, Binary4}=read_int64(Binary3),
%	{Desrolename, Binary5}=read_string(Binary4),
%	{Msginfo, Binary6}=read_string(Binary5),
%	{Details, Binary7}=read_string_list(Binary6),
%	{Identity, Binary8}=read_int32(Binary7),
%	Term = #chat_s2c{type=Type, serverid=Serverid, privateflag=Privateflag, desroleid=Desroleid, desrolename=Desrolename, msginfo=Msginfo, details=Details, identity=Identity},
%	Term.

decode_chat_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Serverid, Binary2}=read_int32(Binary1),
	{Privateflag, Binary3}=read_int32(Binary2),
	{Desroleid, Binary4}=read_int64(Binary3),
	{Desrolename, Binary5}=read_string(Binary4),
	{Msginfo, Binary6}=read_string(Binary5),
	{Details, Binary7}=read_string_list(Binary6),
	{Identity, Binary8}=read_int32(Binary7),
	{Reptype, Binary9}=read_int32(Binary8),
	Term = #chat_s2c{type=Type, serverid=Serverid, privateflag=Privateflag, desroleid=Desroleid, desrolename=Desrolename, msginfo=Msginfo, details=Details, identity=Identity, reptype=Reptype},
	Term.
%%
decode_enum_shoping_item_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	Term = #enum_shoping_item_c2s{npcid=Npcid},
	Term.

%%
decode_answer_start_notice_s2c(Binary0)->
	{Num, Binary1}=read_int32(Binary0),
	{Id, Binary2}=read_int32(Binary1),
	Term = #answer_start_notice_s2c{num=Num, id=Id},
	Term.

%%
decode_entry_loop_instance_vote_update_s2c(Binary0)->
	{State, Binary1}=decode_votestate(Binary0),
	Term = #entry_loop_instance_vote_update_s2c{state=State},
	Term.

%%
decode_tangle_kill_info_request_c2s(Binary0)->
	{Year, Binary1}=read_int32(Binary0),
	{Month, Binary2}=read_int32(Binary1),
	{Day, Binary3}=read_int32(Binary2),
	{Battletype, Binary4}=read_int32(Binary3),
	{Battleid, Binary5}=read_int32(Binary4),
	Term = #tangle_kill_info_request_c2s{year=Year, month=Month, day=Day, battletype=Battletype, battleid=Battleid},
	Term.

%%
decode_equipment_recast_s2c(Binary0)->
	{Enchants, Binary1}=decode_list(Binary0, fun decode_k/1),
	Term = #equipment_recast_s2c{enchants=Enchants},
	Term.

%%
decode_activity_forecast_end_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #activity_forecast_end_s2c{type=Type},
	Term.

%%
decode_treasure_chest_raffle_ok_s2c(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #treasure_chest_raffle_ok_s2c{slot=Slot},
	Term.

%%
decode_mail_operator_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #mail_operator_failed_s2c{reason=Reason},
	Term.

%%
decode_update_item_for_pet_s2c(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Items, Binary2}=decode_list(Binary1, fun decode_ic/1),
	Term = #update_item_for_pet_s2c{petid=Petid, items=Items},
	Term.

%%
decode_stop_sitdown_c2s(Binary0)->
	Term = #stop_sitdown_c2s{},
	Term.

%%
decode_rank_get_rank_role_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Rolename, Binary2}=read_string(Binary1),
	{Classtype, Binary3}=read_int32(Binary2),
	{Gender, Binary4}=read_int32(Binary3),
	{Guildname, Binary5}=read_string(Binary4),
	{Level, Binary6}=read_int32(Binary5),
	{Cloth, Binary7}=read_int32(Binary6),
	{Arm, Binary8}=read_int32(Binary7),
	{Vip_tag, Binary9}=read_int32(Binary8),
	{Items_attr, Binary10}=decode_list(Binary9, fun decode_i/1),
	{Be_disdain, Binary11}=read_int32(Binary10),
	{Be_praised, Binary12}=read_int32(Binary11),
	{Left_judge, Binary13}=read_int32(Binary12),
	Term = #rank_get_rank_role_s2c{roleid=Roleid, rolename=Rolename, classtype=Classtype, gender=Gender, guildname=Guildname, level=Level, cloth=Cloth, arm=Arm, vip_tag=Vip_tag, items_attr=Items_attr, be_disdain=Be_disdain, be_praised=Be_praised, left_judge=Left_judge},
	Term.

%%
decode_first_charge_gift_state_s2c(Binary0)->
	{State, Binary1}=read_int32(Binary0),
	Term = #first_charge_gift_state_s2c{state=State},
	Term.

%%
decode_enum_shoping_item_fail_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #enum_shoping_item_fail_s2c{reason=Reason},
	Term.

%%
decode_entry_loop_instance_vote_c2s(Binary0)->
	{State, Binary1}=read_int32(Binary0),
	Term = #entry_loop_instance_vote_c2s{state=State},
	Term.

%%
decode_answer_question_c2s(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{Answer, Binary2}=read_int32(Binary1),
	{Flag, Binary3}=read_int32(Binary2),
	Term = #answer_question_c2s{id=Id, answer=Answer, flag=Flag},
	Term.

%%
decode_quest_details_c2s(Binary0)->
	{Questid, Binary1}=read_int32(Binary0),
	Term = #quest_details_c2s{questid=Questid},
	Term.

%%返回角色列表给玩家
decode_player_role_list_s2c(Binary0)->
	{Roles, Binary1}=decode_list(Binary0, fun decode_r/1),
	Term = #player_role_list_s2c{roles=Roles},
	Term.

%%
decode_activity_value_init_s2c(Binary0)->
	{Avlist, Binary1}=decode_list(Binary0, fun decode_av/1),
	{Value, Binary2}=read_int32(Binary1),
	{Status, Binary3}=read_int32(Binary2),
	Term = #activity_value_init_s2c{avlist=Avlist, value=Value, status=Status},
	Term.

%%
decode_equipment_recast_confirm_c2s(Binary0)->
	{Equipment, Binary1}=read_int32(Binary0),
	Term = #equipment_recast_confirm_c2s{equipment=Equipment},
	Term.

%%
decode_ridepet_synthesis_error_s2c(Binary0)->
	{Error, Binary1}=read_int32(Binary0),
	Term = #ridepet_synthesis_error_s2c{error=Error},
	Term.

%%
%%decode_achieve_update_s2c(Binary0)->
%%	{Part, Binary1}=decode_ach(Binary0),
%%	Term = #achieve_update_s2c{part=Part},
%%	Term.

%%成就更新
encode_achieve_update_s2c(Term)->
	Achieve_value=Term#achieve_update_s2c.achieve_value,
	Recent_achieve=encode_list(Term#achieve_update_s2c.recent_achieve, fun encode_ach_id/1),
	Fuwen=encode_list(Term#achieve_update_s2c.fuwen, fun encode_fw/1),
	Achieve_info=encode_list(Term#achieve_update_s2c.achieve_info, fun encode_achieve_info/1),
	Award=encode_list(Term#achieve_update_s2c.award, fun encode_award_state/1),
	Data = <<Achieve_value:32, Recent_achieve/binary, Fuwen/binary, Achieve_info/binary, Award/binary>>,
	<<632:16, Data/binary>>.

%%
decode_companion_sitdown_apply_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #companion_sitdown_apply_c2s{roleid=Roleid},
	Term.

%%
decode_guild_opt_result_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #guild_opt_result_s2c{errno=Errno},
	Term.

%%
decode_get_guild_notice_c2s(Binary0)->
	{Guildlid, Binary1}=read_int32(Binary0),
	{Guildhid, Binary2}=read_int32(Binary1),
	Term = #get_guild_notice_c2s{guildlid=Guildlid, guildhid=Guildhid},
	Term.

%%
decode_treasure_transport_time_s2c(Binary0)->
	{Left_time, Binary1}=read_int32(Binary0),
	Term = #treasure_transport_time_s2c{left_time=Left_time},
	Term.

%%
decode_update_item_s2c(Binary0)->
	{Items, Binary1}=decode_list(Binary0, fun decode_ic/1),
	Term = #update_item_s2c{items=Items},
	Term.

%%
decode_refine_system_c2s(Binary0)->
	{Serial_number, Binary1}=read_int32(Binary0),
	{Times, Binary2}=read_int32(Binary1),
	Term = #refine_system_c2s{serial_number=Serial_number, times=Times},
	Term.

%%
decode_first_charge_gift_reward_c2s(Binary0)->
	Term = #first_charge_gift_reward_c2s{},
	Term.

%%
decode_equipment_convert_c2s(Binary0)->
	{Equipment, Binary1}=read_int32(Binary0),
	{Convert, Binary2}=read_int32(Binary1),
	{Type, Binary3}=read_int32(Binary2),
	Term = #equipment_convert_c2s{equipment=Equipment, convert=Convert, type=Type},
	Term.

%%
decode_chess_spirit_get_reward_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #chess_spirit_get_reward_c2s{type=Type},
	Term.

%%
decode_system_broadcast_s2c(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{Param, Binary2}=decode_list(Binary1, fun decode_rkv/1),
	Term = #system_broadcast_s2c{id=Id, param=Param},
	Term.

%%
decode_quest_details_s2c(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Questid, Binary2}=read_int32(Binary1),
	{Queststate, Binary3}=read_int32(Binary2),
	Term = #quest_details_s2c{npcid=Npcid, questid=Questid, queststate=Queststate},
	Term.

%%
decode_fatigue_alert_s2c(Binary0)->
	{Alter, Binary1}=read_string(Binary0),
	Term = #fatigue_alert_s2c{alter=Alter},
	Term.

%%
decode_guild_base_update_s2c(Binary0)->
	{Guildname, Binary1}=read_string(Binary0),
	{Level, Binary2}=read_int32(Binary1),
	{Silver, Binary3}=read_int32(Binary2),
	{Gold, Binary4}=read_int32(Binary3),
	{Notice, Binary5}=read_string(Binary4),
	{Chatgroup, Binary6}=read_string(Binary5),
	{Voicegroup, Binary7}=read_string(Binary6),
	Term = #guild_base_update_s2c{guildname=Guildname, level=Level, silver=Silver, gold=Gold, notice=Notice, chatgroup=Chatgroup, voicegroup=Voicegroup},
	Term.

%%
decode_treasure_chest_obtain_c2s(Binary0)->
	Term = #treasure_chest_obtain_c2s{},
	Term.

%%
decode_welfare_gifepacks_state_update_s2c(Binary0)->
	{Typenumber, Binary1}=read_int32(Binary0),
	{Time_state, Binary2}=read_int32(Binary1),
	{Complete_state, Binary3}=read_int32(Binary2),
	Term = #welfare_gifepacks_state_update_s2c{typenumber=Typenumber, time_state=Time_state, complete_state=Complete_state},
	Term.

%%领取成就奖励请求
%decode_achieve_reward_c2s(Binary0)->
%	{Chapter, Binary1}=read_int32(Binary0),
%	{Part, Binary2}=decode_ach(Binary1),
%	Term = #achieve_reward_c2s{chapter=Chapter, part=Part},
%	Term.

decode_achieve_reward_c2s(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	Term = #achieve_reward_c2s{id=Id},
	Term.

%%
decode_init_onhands_item_s2c(Binary0)->
	{Item_attrs, Binary1}=decode_list(Binary0, fun decode_i/1),
	Term = #init_onhands_item_s2c{item_attrs=Item_attrs},
	Term.

%%
decode_first_charge_gift_reward_opt_s2c(Binary0)->
	{Code, Binary1}=read_int32(Binary0),
	Term = #first_charge_gift_reward_opt_s2c{code=Code},
	Term.

%%
decode_chat_failed_s2c(Binary0)->
	{Reasonid, Binary1}=read_int32(Binary0),
	{Cdtime, Binary2}=read_int32(Binary1),
	Term = #chat_failed_s2c{reasonid=Reasonid, cdtime=Cdtime},
	Term.

%%
decode_moneygame_result_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	{Use_time, Binary2}=read_int32(Binary1),
	{Section, Binary3}=read_int32(Binary2),
	Term = #moneygame_result_s2c{result=Result, use_time=Use_time, section=Section},
	Term.

%%
decode_treasure_chest_disable_c2s(Binary0)->
	{Slots, Binary1}=read_int32_list(Binary0),
	Term = #treasure_chest_disable_c2s{slots=Slots},
	Term.

%%
decode_beads_pray_request_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Times, Binary2}=read_int32(Binary1),
	{Consume_type, Binary3}=read_int32(Binary2),
	Term = #beads_pray_request_c2s{type=Type, times=Times, consume_type=Consume_type},
	Term.

%%
decode_chess_spirit_log_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #chess_spirit_log_c2s{type=Type},
	Term.

%%
decode_tangle_kill_info_request_s2c(Binary0)->
	{Year, Binary1}=read_int32(Binary0),
	{Month, Binary2}=read_int32(Binary1),
	{Day, Binary3}=read_int32(Binary2),
	{Battletype, Binary4}=read_int32(Binary3),
	{Battleid, Binary5}=read_int32(Binary4),
	{Killinfo, Binary6}=decode_list(Binary5, fun decode_ki/1),
	{Bekillinfo, Binary7}=decode_list(Binary6, fun decode_ki/1),
	Term = #tangle_kill_info_request_s2c{year=Year, month=Month, day=Day, battletype=Battletype, battleid=Battleid, killinfo=Killinfo, bekillinfo=Bekillinfo},
	Term.

%%
decode_enum_shoping_item_s2c(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Sps, Binary2}=decode_list(Binary1, fun decode_sp/1),
	Term = #enum_shoping_item_s2c{npcid=Npcid, sps=Sps},
	Term.

%%
decode_guild_get_shop_item_c2s(Binary0)->
	{Shoptype, Binary1}=read_int32(Binary0),
	Term = #guild_get_shop_item_c2s{shoptype=Shoptype},
	Term.

%%
decode_answer_question_s2c(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{Score, Binary2}=read_int32(Binary1),
	{Rank, Binary3}=read_int32(Binary2),
	{Continu, Binary4}=read_int32(Binary3),
	Term = #answer_question_s2c{id=Id, score=Score, rank=Rank, continu=Continu},
	Term.

%%
decode_activity_value_update_s2c(Binary0)->
	{Avlist, Binary1}=decode_list(Binary0, fun decode_av/1),
	{Value, Binary2}=read_int32(Binary1),
	{Status, Binary3}=read_int32(Binary2),
	Term = #activity_value_update_s2c{avlist=Avlist, value=Value, status=Status},
	Term.

%%
decode_chess_spirit_update_chess_power_s2c(Binary0)->
	{Newpower, Binary1}=read_int32(Binary0),
	Term = #chess_spirit_update_chess_power_s2c{newpower=Newpower},
	Term.

%%
decode_equipment_convert_s2c(Binary0)->
	{Enchants, Binary1}=decode_list(Binary0, fun decode_k/1),
	Term = #equipment_convert_s2c{enchants=Enchants},
	Term.

%%
decode_add_item_s2c(Binary0)->
	{Item_attr, Binary1}=decode_i(Binary0),
	Term = #add_item_s2c{item_attr=Item_attr},
	Term.

%%
decode_achieve_error_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #achieve_error_s2c{reason=Reason},
	Term.

%%
decode_tangle_update_s2c(Binary0)->
	{Trs, Binary1}=decode_list(Binary0, fun decode_tr/1),
	Term = #tangle_update_s2c{trs=Trs},
	Term.

%%
decode_treasure_chest_obtain_ok_s2c(Binary0)->
	Term = #treasure_chest_obtain_ok_s2c{},
	Term.

%%查询分线服务器
decode_role_line_query_c2s(Binary0)->
	{Mapid, Binary1}=read_int32(Binary0),
	Term = #role_line_query_c2s{mapid=Mapid},
	Term.

%%
decode_loudspeaker_queue_num_c2s(Binary0)->
	Term = #loudspeaker_queue_num_c2s{},
	Term.

%%
decode_chess_spirit_opt_result_s2s(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #chess_spirit_opt_result_s2s{errno=Errno},
	Term.

%%
decode_pet_random_talent_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Type, Binary2}=read_int32(Binary1),
	Term = #pet_random_talent_c2s{petid=Petid, type=Type},
	Term.

%%
decode_country_leader_demotion_c2s(Binary0)->
	{Post, Binary1}=read_int32(Binary0),
	{Postindex, Binary2}=read_int32(Binary1),
	Term = #country_leader_demotion_c2s{post=Post, postindex=Postindex},
	Term.


%%
decode_buy_item_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Item_clsid, Binary2}=read_int32(Binary1),
	{Count, Binary3}=read_int32(Binary2),
	Term = #buy_item_c2s{npcid=Npcid, item_clsid=Item_clsid, count=Count},
	Term.

%%
decode_treasure_transport_failed_s2c(Binary0)->
	{Reward, Binary1}=read_int32(Binary0),
	Term = #treasure_transport_failed_s2c{reward=Reward},
	Term.

%%
decode_add_item_failed_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #add_item_failed_s2c{errno=Errno},
	Term.

%%
decode_loudspeaker_queue_num_s2c(Binary0)->
	{Num, Binary1}=read_int32(Binary0),
	Term = #loudspeaker_queue_num_s2c{num=Num},
	Term.

%%
%%转移(添加所需材料位置)
decode_equipment_move_c2s(Binary0)->
	{Fromslot, Binary1}=read_int32(Binary0),
	{Toslot, Binary2}=read_int32(Binary1),
	Term = #equipment_move_c2s{fromslot=Fromslot, toslot=Toslot},
	Term.

%%
decode_server_version_c2s(Binary0)->
	Term = #server_version_c2s{},
	Term.

%%
decode_activity_value_reward_c2s(Binary0)->
	{Itemid, Binary1}=read_int32(Binary0),
	Term = #activity_value_reward_c2s{itemid=Itemid},
	Term.

%%
decode_send_guild_notice_s2c(Binary0)->
	{Guildlid, Binary1}=read_int32(Binary0),
	{Guildhid, Binary2}=read_int32(Binary1),
	{Notice, Binary3}=read_string(Binary2),
	Term = #send_guild_notice_s2c{guildlid=Guildlid, guildhid=Guildhid, notice=Notice},
	Term.

%%
decode_rob_treasure_transport_s2c(Binary0)->
	{Othername, Binary1}=read_string(Binary0),
	{Rewardmoney, Binary2}=read_int32(Binary1),
	Term = #rob_treasure_transport_s2c{othername=Othername, rewardmoney=Rewardmoney},
	Term.

%%
decode_refine_system_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	Term = #refine_system_s2c{result=Result},
	Term.

%%
decode_country_leader_update_s2c(Binary0)->
	{Leader, Binary1}=decode_cl(Binary0),
	Term = #country_leader_update_s2c{leader=Leader},
	Term.

%%
decode_venation_init_s2c(Binary0)->
	{Venation, Binary1}=decode_list(Binary0, fun decode_vp/1),
	{Venationbone, Binary2}=decode_list(Binary1, fun decode_vb/1),
	{Attr, Binary3}=decode_list(Binary2, fun decode_k/1),
	{Remaintime, Binary4}=read_int32(Binary3),
	{Totalexp, Binary5}=read_int64(Binary4),
	Term = #venation_init_s2c{venation=Venation, venationbone=Venationbone, attr=Attr, remaintime=Remaintime, totalexp=Totalexp},
	Term.

%%
decode_pet_training_info_s2c(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Totaltime, Binary2}=read_int32(Binary1),
	{Remaintime, Binary3}=read_int32(Binary2),
	Term = #pet_training_info_s2c{petid=Petid, totaltime=Totaltime, remaintime=Remaintime},
	Term.

%%
decode_guild_member_update_s2c(Binary0)->
	{Roleinfo, Binary1}=decode_g(Binary0),
	Term = #guild_member_update_s2c{roleinfo=Roleinfo},
	Term.

%%
decode_moneygame_left_time_s2c(Binary0)->
	{Left_seconds, Binary1}=read_int32(Binary0),
	Term = #moneygame_left_time_s2c{left_seconds=Left_seconds},
	Term.

%%
decode_answer_question_ranklist_s2c(Binary0)->
	{Ranklist, Binary1}=decode_list(Binary0, fun decode_aqrl/1),
	Term = #answer_question_ranklist_s2c{ranklist=Ranklist},
	Term.

%%
decode_activity_value_opt_s2c(Binary0)->
	{Code, Binary1}=read_int32(Binary0),
	Term = #activity_value_opt_s2c{code=Code},
	Term.

%%
decode_rank_judge_to_other_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Othername, Binary2}=read_string(Binary1),
	Term = #rank_judge_to_other_s2c{type=Type, othername=Othername},
	Term.

%%
decode_equipment_move_s2c(Binary0)->
	Term = #equipment_move_s2c{},
	Term.

%%
decode_destroy_item_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #destroy_item_c2s{slot=Slot},
	Term.

%%
decode_companion_sitdown_apply_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #companion_sitdown_apply_s2c{roleid=Roleid},
	Term.

%%
decode_qz_get_balance_c2s(Binary0)->
	Term = #qz_get_balance_c2s{},
	Term.

%%
decode_sell_item_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	Term = #sell_item_c2s{npcid=Npcid, slot=Slot},
	Term.

%%成功查询分线服务器
decode_role_line_query_ok_s2c(Binary0)->
	{Lines, Binary1}=decode_list(Binary0, fun decode_li/1),
	Term = #role_line_query_ok_s2c{lines=Lines},
	Term.

%%
decode_start_guild_transport_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #start_guild_transport_failed_s2c{reason=Reason},
	Term.

%%
decode_festival_error_s2c(Binary0)->
	{Error, Binary1}=read_int32(Binary0),
	Term = #festival_error_s2c{error=Error},
	Term.

%%
decode_guild_facilities_update_s2c(Binary0)->
	{Facinfo, Binary1}=decode_f(Binary0),
	Term = #guild_facilities_update_s2c{facinfo=Facinfo},
	Term.

%%
decode_country_init_s2c(Binary0)->
	{Leaders, Binary1}=decode_list(Binary0, fun decode_cl/1),
	{Notice, Binary2}=read_string(Binary1),
	{Tp_start, Binary3}=read_int32(Binary2),
	{Tp_stop, Binary4}=read_int32(Binary3),
	{Bestguildlid, Binary5}=read_int32(Binary4),
	{Bestguildhid, Binary6}=read_int32(Binary5),
	{Bestguildname, Binary7}=read_string(Binary6),
	Term = #country_init_s2c{leaders=Leaders, notice=Notice, tp_start=Tp_start, tp_stop=Tp_stop, bestguildlid=Bestguildlid, bestguildhid=Bestguildhid, bestguildname=Bestguildname},
	Term.

%%
decode_equipment_remove_seal_s2c(Binary0)->
	Term = #equipment_remove_seal_s2c{},
	Term.

%%
decode_levelup_opt_c2s(Binary0)->
	{Level, Binary1}=read_int32(Binary0),
	Term = #levelup_opt_c2s{level=Level},
	Term.

%%
decode_answer_end_s2c(Binary0)->
	{Exp, Binary1}=read_int32(Binary0),
	Term = #answer_end_s2c{exp=Exp},
	Term.

%%
decode_delete_item_s2c(Binary0)->
	{Itemid_low, Binary1}=read_int32(Binary0),
	{Itemid_high, Binary2}=read_int32(Binary1),
	{Reason, Binary3}=read_int32(Binary2),
	Term = #delete_item_s2c{itemid_low=Itemid_low, itemid_high=Itemid_high, reason=Reason},
	Term.

%%
decode_treasure_chest_query_s2c(Binary0)->
	{Items, Binary1}=decode_list(Binary0, fun decode_lti/1),
	{Slots, Binary2}=read_int32_list(Binary1),
	Term = #treasure_chest_query_s2c{items=Items, slots=Slots},
	Term.

%%
decode_treasure_chest_query_c2s(Binary0)->
	Term = #treasure_chest_query_c2s{},
	Term.

%%
decode_get_guild_monster_info_c2s(Binary0)->
	Term = #get_guild_monster_info_c2s{},
	Term.

%%
decode_loop_instance_opt_s2c(Binary0)->
	{Code, Binary1}=read_int32(Binary0),
	Term = #loop_instance_opt_s2c{code=Code},
	Term.

%%选定某个角色
decode_player_select_role_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Lineid, Binary2}=read_int32(Binary1),
	Term = #player_select_role_c2s{roleid=Roleid, lineid=Lineid},
	Term.

%%
decode_country_leader_promotion_c2s(Binary0)->
	{Post, Binary1}=read_int32(Binary0),
	{Postindex, Binary2}=read_int32(Binary1),
	{Name, Binary3}=read_string(Binary2),
	Term = #country_leader_promotion_c2s{post=Post, postindex=Postindex, name=Name},
	Term.

%%
decode_rank_get_rank_role_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #rank_get_rank_role_c2s{roleid=Roleid},
	Term.

%%
decode_identify_verify_c2s(Binary0)->
	{Truename, Binary1}=read_string(Binary0),
	{Card, Binary2}=read_string(Binary1),
	Term = #identify_verify_c2s{truename=Truename, card=Card},
	Term.

%%
decode_battle_other_join_s2c(Binary0)->
	{Commer, Binary1}=decode_tr(Binary0),
	Term = #battle_other_join_s2c{commer=Commer},
	Term.

%%
decode_beads_pray_response_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Times, Binary2}=read_int32(Binary1),
	{Itemslist, Binary3}=decode_list(Binary2, fun decode_lti/1),
	Term = #beads_pray_response_s2c{type=Type, times=Times, itemslist=Itemslist},
	Term.

%%
decode_welfare_activity_update_c2s(Binary0)->
	{Typenumber, Binary1}=read_int32(Binary0),
	{Serial_number, Binary2}=read_string(Binary1),
	Term = #welfare_activity_update_c2s{typenumber=Typenumber, serial_number=Serial_number},
	Term.

%%
decode_inspect_c2s(Binary0)->
	{Serverid, Binary1}=read_int32(Binary0),
	{Rolename, Binary2}=read_string(Binary1),
	Term = #inspect_c2s{serverid=Serverid, rolename=Rolename},
	Term.

%%
decode_add_levelup_opt_levels_s2c(Binary0)->
	{Levels, Binary1}=read_int32_list(Binary0),
	Term = #add_levelup_opt_levels_s2c{levels=Levels},
	Term.

%%
decode_goals_update_s2c(Binary0)->
	{Part, Binary1}=decode_ach(Binary0),
	Term = #goals_update_s2c{part=Part},
	Term.

%%
decode_guild_member_delete_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Reason, Binary2}=read_int32(Binary1),
	Term = #guild_member_delete_s2c{roleid=Roleid, reason=Reason},
	Term.

%%
decode_country_block_talk_c2s(Binary0)->
	{Name, Binary1}=read_string(Binary0),
	Term = #country_block_talk_c2s{name=Name},
	Term.

%%
decode_equipment_remove_seal_c2s(Binary0)->
	{Equipment, Binary1}=read_int32(Binary0),
	Term = #equipment_remove_seal_c2s{equipment=Equipment},
	Term.

%%
decode_guild_transport_left_time_s2c(Binary0)->
	{Left_time, Binary1}=read_int32(Binary0),
	Term = #guild_transport_left_time_s2c{left_time=Left_time},
	Term.

%%
decode_repair_item_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	Term = #repair_item_c2s{npcid=Npcid, slot=Slot},
	Term.

%%
decode_answer_error_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #answer_error_s2c{reason=Reason},
	Term.

%%
decode_pet_change_talent_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	Term = #pet_change_talent_c2s{petid=Petid},
	Term.

%%
decode_other_venation_info_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Venation, Binary2}=decode_list(Binary1, fun decode_vp/1),
	{Attr, Binary3}=decode_list(Binary2, fun decode_k/1),
	{Remaintime, Binary4}=read_int32(Binary3),
	{Totalexp, Binary5}=read_int64(Binary4),
	{Venationbone, Binary6}=decode_list(Binary5, fun decode_vb/1),
	Term = #other_venation_info_s2c{roleid=Roleid, venation=Venation, attr=Attr, remaintime=Remaintime, totalexp=Totalexp, venationbone=Venationbone},
	Term.

%%
decode_chess_spirit_update_skill_s2c(Binary0)->
	{Update_skills, Binary1}=decode_list(Binary0, fun decode_s/1),
	Term = #chess_spirit_update_skill_s2c{update_skills=Update_skills},
	Term.

%%
decode_festival_recharge_exchange_c2s(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	Term = #festival_recharge_exchange_c2s{id=Id},
	Term.

%%
decode_rank_get_rank_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #rank_get_rank_c2s{type=Type},
	Term.

%%
decode_role_attribute_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Attrs, Binary2}=decode_list(Binary1, fun decode_k/1),
	Term = #role_attribute_s2c{roleid=Roleid, attrs=Attrs},
	Term.

%%
decode_battle_join_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #battle_join_c2s{type=Type},
	Term.

%%
decode_identify_verify_s2c(Binary0)->
	{Code, Binary1}=read_int32(Binary0),
	Term = #identify_verify_s2c{code=Code},
	Term.

%%
decode_chess_spirit_info_s2c(Binary0)->
	{Cur_section, Binary1}=read_int32(Binary0),
	{Used_time_s, Binary2}=read_int32(Binary1),
	{Next_sec_time_s, Binary3}=read_int32(Binary2),
	{Spiritmaxhp, Binary4}=read_int32(Binary3),
	{Spiritcurhp, Binary5}=read_int32(Binary4),
	Term = #chess_spirit_info_s2c{cur_section=Cur_section, used_time_s=Used_time_s, next_sec_time_s=Next_sec_time_s, spiritmaxhp=Spiritmaxhp, spiritcurhp=Spiritcurhp},
	Term.

%%
decode_start_guild_treasure_transport_c2s(Binary0)->
	Term = #start_guild_treasure_transport_c2s{},
	Term.

%%
decode_stall_role_detail_c2s(Binary0)->
	{Rolename, Binary1}=read_string(Binary0),
	Term = #stall_role_detail_c2s{rolename=Rolename},
	Term.

%%
decode_festival_recharge_update_s2c(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{State, Binary2}=read_int32(Binary1),
	{Today_charge_num, Binary3}=read_int32(Binary2),
	Term = #festival_recharge_update_s2c{id=Id, state=State, today_charge_num=Today_charge_num},
	Term.

%%换线
decode_role_change_line_c2s(Binary0)->
	{Lineid, Binary1}=read_int32(Binary0),
	Term = #role_change_line_c2s{lineid=Lineid},
	Term.

%%
decode_split_item_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Split_num, Binary2}=read_int32(Binary1),
	Term = #split_item_c2s{slot=Slot, split_num=Split_num},
	Term.

%%
decode_group_member_stats_s2c(Binary0)->
	{State, Binary1}=decode_t(Binary0),
	Term = #group_member_stats_s2c{state=State},
	Term.

%%
decode_buy_item_fail_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #buy_item_fail_s2c{reason=Reason},
	Term.

%%
decode_guild_member_add_s2c(Binary0)->
	{Roleinfo, Binary1}=decode_g(Binary0),
	Term = #guild_member_add_s2c{roleinfo=Roleinfo},
	Term.

%%
decode_congratulations_levelup_remind_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Rolename, Binary2}=read_string(Binary1),
	{Level, Binary3}=read_int32(Binary2),
	Term = #congratulations_levelup_remind_s2c{roleid=Roleid, rolename=Rolename, level=Level},
	Term.

%%
decode_rank_get_main_line_rank_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Chapter, Binary2}=read_int32(Binary1),
	{Festival, Binary3}=read_int32(Binary2),
	{Difficulty, Binary4}=read_int32(Binary3),
	Term = #rank_get_main_line_rank_c2s{type=Type, chapter=Chapter, festival=Festival, difficulty=Difficulty},
	Term.

%%
decode_treasure_transport_call_guild_help_c2s(Binary0)->
	Term = #treasure_transport_call_guild_help_c2s{},
	Term.

%%
decode_activity_state_init_c2s(Binary0)->
	Term = #activity_state_init_c2s{},
	Term.

%%
decode_questgiver_states_update_s2c(Binary0)->
	{Npcid, Binary1}=read_int64_list(Binary0),
	{Queststate, Binary2}=read_int32_list(Binary1),
	Term = #questgiver_states_update_s2c{npcid=Npcid, queststate=Queststate},
	Term.

%%
decode_stall_sell_item_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Silver, Binary2}=read_int32(Binary1),
	{Gold, Binary3}=read_int32(Binary2),
	{Ticket, Binary4}=read_int32(Binary3),
	Term = #stall_sell_item_c2s{slot=Slot, silver=Silver, gold=Gold, ticket=Ticket},
	Term.
%%2月18日加【xiaowu】
decode_paimai_sell_c2s(Binary0)->
	{Gold, Binary1}=read_int32(Binary0),
	{Duration_type, Binary2}=read_int32(Binary1),
	{Silver, Binary3}=read_int32(Binary2),
	{Value, Binary4}=read_int32(Binary3),
	{Type, Binary5}=read_int32(Binary4),
	{Slot, Binary6}=read_int32(Binary5),
	Term = #paimai_sell_c2s{gold=Gold, duration_type=Duration_type, silver=Silver, value=Value, type=Type, slot=Slot},
	Term.

%%2月18日加【xiaowu】
decode_paimai_detail_c2s(Binary0)->
	{Stallid, Binary1}=read_int64(Binary0),
	Term = #paimai_detail_c2s{stallid=Stallid},
	Term.

%%
encode_paimai_sell_c2s(Term)->
	Gold=Term#paimai_sell_c2s.gold,
	Duration_type=Term#paimai_sell_c2s.duration_type,
	Silver=Term#paimai_sell_c2s.silver,
	Value=Term#paimai_sell_c2s.value,
	Type=Term#paimai_sell_c2s.type,
	Slot=Term#paimai_sell_c2s.slot,
	Data = <<Gold:32, Duration_type:32, Silver:32, Value:32, Type:32, Slot:32>>,
	<<2020:16, Data/binary>>.

%%
encode_paimai_detail_c2s(Term)->
	Stallid=Term#paimai_detail_c2s.stallid,
	Data = <<Stallid:64>>,
	<<2023:16, Data/binary>>.

%%2月19日加【xiaowu】
encode_paimai_opt_result_s2c(Term)->
	Errno=Term#paimai_opt_result_s2c.errno,
	Data = <<Errno:32>>,
	<<2033:16, Data/binary>>.

%%2月22日加【xiaowu】
encode_paimai_detail_s2c(Term)->
	Stallitems=encode_list(Term#paimai_detail_s2c.stallitems, fun encode_siv/1),
	Isonline=Term#paimai_detail_s2c.isonline,
	Stallname=encode_string(Term#paimai_detail_s2c.stallname),
	Ownerid=Term#paimai_detail_s2c.ownerid,
	Stallmoney=encode_list(Term#paimai_detail_s2c.stallmoney, fun encode_sm/1),
	Stallid=Term#paimai_detail_s2c.stallid,
	Logs=encode_string_list(Term#paimai_detail_s2c.logs),
	Data = <<Stallitems/binary, Isonline:32, Stallname/binary, Ownerid:64, Stallmoney/binary, Stallid:64, Logs/binary>>,
	<<2025:16, Data/binary>>.

%%2月22日加【xiaowu】
decode_paimai_detail_s2c(Binary0)->
	{Stallitems, Binary1}=decode_list(Binary0, fun decode_siv/1),
	{Isonline, Binary2}=read_int32(Binary1),
	{Stallname, Binary3}=read_string(Binary2),
	{Ownerid, Binary4}=read_int64(Binary3),
	{Stallmoney, Binary5}=decode_list(Binary4, fun decode_sm/1),
	{Stallid, Binary6}=read_int64(Binary5),
	{Logs, Binary7}=read_string_list(Binary6),
	Term = #paimai_detail_s2c{stallitems=Stallitems, isonline=Isonline, stallname=Stallname, ownerid=Ownerid, stallmoney=Stallmoney, stallid=Stallid, logs=Logs},
	Term.

%%2月22日加【xiaowu】
decode_sm(Binary0)->
	{Gold, Binary1}=read_int32(Binary0),
	{Value, Binary2}=read_int32(Binary1),
	{Type, Binary3}=read_int32(Binary2),
	{Silver, Binary4}=read_int32(Binary3),
	{Indexid, Binary5}=read_int32(Binary4),
	Term = #sm{gold=Gold, value=Value, type=Type, silver=Silver, indexid=Indexid},
	{Term, Binary5}.
%%2月22日加【xiaowu】
encode_sm(Term)->
	Gold=Term#sm.gold,
	Value=Term#sm.value,
	Type=Term#sm.type,
	Silver=Term#sm.silver,
	Indexid=Term#sm.indexid,
	Data = <<Gold:32, Value:32, Type:32, Silver:32, Indexid:32>>,
	Data.

%%2月22日加【xiaowu】
encode_siv(Term)->
	Gold=Term#siv.gold,
	Item=encode_i(Term#siv.item),
	Type=Term#siv.type,
	Silver=Term#siv.silver,
	Indexid=Term#siv.indexid,
	Data = <<Gold:32, Item/binary, Type:32, Silver:32, Indexid:32>>,
	Data.
%%2月22日加【xiaowu】
decode_siv(Binary0)->
	{Gold, Binary1}=read_int32(Binary0),
	{Item, Binary2}=decode_i(Binary1),
	{Type, Binary3}=read_int32(Binary2),
	{Silver, Binary4}=read_int32(Binary3),
	{Indexid, Binary5}=read_int32(Binary4),
	Term = #siv{gold=Gold, item=Item, type=Type, silver=Silver, indexid=Indexid},
	{Term, Binary5}.

%%2月25日加【xiaowu】
encode_paimai_recede_c2s(Term)->
	Type=Term#paimai_recede_c2s.type,
	Stallid=Term#paimai_recede_c2s.stallid,
	Indexid=Term#paimai_recede_c2s.indexid,
	Data = <<Type:32, Stallid:64, Indexid:32>>,
	<<2021:16, Data/binary>>.
%%2月25日加【xiaowu】
decode_paimai_recede_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Stallid, Binary2}=read_int64(Binary1),
	{Indexid, Binary3}=read_int32(Binary2),
	Term = #paimai_recede_c2s{type=Type, stallid=Stallid, indexid=Indexid},
	Term.

%%3月4日加【xiaowu】
encode_paimai_search_by_sort_c2s(Term)->
	Subsortkey=Term#paimai_search_by_sort_c2s.subsortkey,
	Sortkey=Term#paimai_search_by_sort_c2s.sortkey,
	Levelsort=Term#paimai_search_by_sort_c2s.levelsort,
	Index=Term#paimai_search_by_sort_c2s.index,
	Mainsort=Term#paimai_search_by_sort_c2s.mainsort,
	Moneysort=Term#paimai_search_by_sort_c2s.moneysort,
	Data = <<Subsortkey:32, Sortkey:32, Levelsort:32, Index:32, Mainsort:32, Moneysort:32>>,
	<<2029:16, Data/binary>>.
%%3月4日加【xiaowu】
decode_paimai_search_by_sort_c2s(Binary0)->	
	{Subsortkey, Binary1}=read_int32(Binary0),
	{Sortkey, Binary2}=read_int32(Binary1),
	{Levelsort, Binary3}=read_int32(Binary2),
	{Index, Binary4}=read_int32(Binary3),
	{Mainsort, Binary5}=read_int32(Binary4),
	{Moneysort, Binary6}=read_int32(Binary5),
	Term = #paimai_search_by_sort_c2s{subsortkey=Subsortkey, sortkey=Sortkey, levelsort=Levelsort, index=Index, mainsort=Mainsort, moneysort=Moneysort},
	Term.

%%3月4日加【xiaowu】
encode_paimai_search_by_string_c2s(Term)->
	Levelsort=Term#paimai_search_by_string_c2s.levelsort,
	Str=encode_string(Term#paimai_search_by_string_c2s.str),
	Index=Term#paimai_search_by_string_c2s.index,
	Mainsort=Term#paimai_search_by_string_c2s.mainsort,
	Moneysort=Term#paimai_search_by_string_c2s.moneysort,
	Data = <<Levelsort:32, Str/binary, Index:32, Mainsort:32, Moneysort:32>>,
	<<2027:16, Data/binary>>.
%%3月4日加【xiaowu】
decode_paimai_search_by_string_c2s(Binary0)->
	{Levelsort, Binary1}=read_int32(Binary0),
	{Str, Binary2}=read_string(Binary1),
	{Index, Binary3}=read_int32(Binary2),
	{Mainsort, Binary4}=read_int32(Binary3),
	{Moneysort, Binary5}=read_int32(Binary4),
	Term = #paimai_search_by_string_c2s{levelsort=Levelsort, str=Str, index=Index, mainsort=Mainsort, moneysort=Moneysort},
	Term.
%%3月4日加【xiaowu】
encode_paimai_search_by_grade_c2s(Term)->
	Levelsort=Term#paimai_search_by_grade_c2s.levelsort,
	Index=Term#paimai_search_by_grade_c2s.index,
	Allowableclass=Term#paimai_search_by_grade_c2s.allowableclass,
	Mainsort=Term#paimai_search_by_grade_c2s.mainsort,
	Levelgrade=Term#paimai_search_by_grade_c2s.levelgrade,
	Moneysort=Term#paimai_search_by_grade_c2s.moneysort,
	Qualitygrade=Term#paimai_search_by_grade_c2s.qualitygrade,
	Data = <<Levelsort:32, Index:32, Allowableclass:32, Mainsort:32, Levelgrade:32, Moneysort:32, Qualitygrade:32>>,
	<<2028:16, Data/binary>>.
%%3月4日加【xiaowu】
decode_paimai_search_by_grade_c2s(Binary0)->
	{Levelsort, Binary1}=read_int32(Binary0),
	{Index, Binary2}=read_int32(Binary1),
	{Allowableclass, Binary3}=read_int32(Binary2),
	{Mainsort, Binary4}=read_int32(Binary3),
	{Levelgrade, Binary5}=read_int32(Binary4),
	{Moneysort, Binary6}=read_int32(Binary5),
	{Qualitygrade, Binary7}=read_int32(Binary6),
	Term = #paimai_search_by_grade_c2s{levelsort=Levelsort, index=Index, allowableclass=Allowableclass, mainsort=Mainsort, levelgrade=Levelgrade, moneysort=Moneysort, qualitygrade=Qualitygrade},
	Term.
%%3月4日加【xiaowu】
encode_paimai_search_item_s2c(Term)->
	Totalnum=Term#paimai_search_item_s2c.totalnum,
	Index=Term#paimai_search_item_s2c.index,
	Searchitems=encode_list(Term#paimai_search_item_s2c.searchitems, fun encode_ssiv/1),
	Searchmoney=encode_list(Term#paimai_search_item_s2c.searchmoney, fun encode_ssm/1),
	Data = <<Totalnum:32, Index:32, Searchitems/binary, Searchmoney/binary>>,
	<<2031:16, Data/binary>>.
%%3月4日加【xiaowu】
decode_paimai_search_item_s2c(Binary0)->
	{Totalnum, Binary1}=read_int32(Binary0),
	{Index, Binary2}=read_int32(Binary1),
	{Searchitems, Binary3}=decode_list(Binary2, fun decode_ssiv/1),
	{Searchmoney, Binary4}=decode_list(Binary3, fun decode_ssm/1),
	Term = #paimai_search_item_s2c{totalnum=Totalnum, index=Index, searchitems=Searchitems, searchmoney=Searchmoney},
	Term.
%%3月4日加【xiaowu】
encode_ssiv(Term)->
	Itemnum=Term#ssiv.itemnum,
	Ownerid=Term#ssiv.ownerid,
	Item=encode_siv(Term#ssiv.item),
	Stallid=Term#ssiv.stallid,
	Isonline=Term#ssiv.isonline,
	Ownername=encode_string(Term#ssiv.ownername),
	Data = <<Itemnum:32, Ownerid:64, Item/binary, Stallid:64, Isonline:32, Ownername/binary>>,
	Data.
%%3月4日加【xiaowu】
decode_ssiv(Binary0)->
	{Itemnum, Binary1}=read_int32(Binary0),
	{Ownerid, Binary2}=read_int64(Binary1),
	{Item, Binary3}=decode_siv(Binary2),
	{Stallid, Binary4}=read_int64(Binary3),
	{Isonline, Binary5}=read_int32(Binary4),
	{Ownername, Binary6}=read_string(Binary5),
	Term = #ssiv{itemnum=Itemnum, ownerid=Ownerid, item=Item, stallid=Stallid, isonline=Isonline, ownername=Ownername},
	{Term, Binary6}.
%%3月4日加【xiaowu】
encode_ssm(Term)->
	Money=encode_sm(Term#ssm.money),
	Ownerid=Term#ssm.ownerid,
	Itemnum=Term#ssm.itemnum,
	Stallid=Term#ssm.stallid,
	Isonline=Term#ssm.isonline,
	Ownername=encode_string(Term#ssm.ownername),
	Data = <<Money/binary, Ownerid:64, Itemnum:32, Stallid:64, Isonline:32, Ownername/binary>>,
	Data.
%%3月4日加【xiaowu】
decode_ssm(Binary0)->
	{Money, Binary1}=decode_sm(Binary0),
	{Ownerid, Binary2}=read_int64(Binary1),
	{Itemnum, Binary3}=read_int32(Binary2),
	{Stallid, Binary4}=read_int64(Binary3),
	{Isonline, Binary5}=read_int32(Binary4),
	{Ownername, Binary6}=read_string(Binary5),
	Term = #ssm{money=Money, ownerid=Ownerid, itemnum=Itemnum, stallid=Stallid, isonline=Isonline, ownername=Ownername},
	{Term, Binary6}.
%%3月7日加【xiaowu】
encode_paimai_buy_c2s(Term)->
	Type=Term#paimai_buy_c2s.type,
	Stallid=Term#paimai_buy_c2s.stallid,
	Indexid=Term#paimai_buy_c2s.indexid,
	Data = <<Type:32, Stallid:64, Indexid:32>>,
	<<2022:16, Data/binary>>.
%%3月7日加【xiaowu】
decode_paimai_buy_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Stallid, Binary2}=read_int64(Binary1),
	{Indexid, Binary3}=read_int32(Binary2),
	Term = #paimai_buy_c2s{type=Type, stallid=Stallid, indexid=Indexid},
	Term.
%%
decode_entry_loop_instance_s2c(Binary0)->
	{Layer, Binary1}=read_int32(Binary0),
	{Result, Binary2}=read_int32(Binary1),
	{Lefttime, Binary3}=read_int32(Binary2),
	{Besttime, Binary4}=read_int32(Binary3),
	Term = #entry_loop_instance_s2c{layer=Layer, result=Result, lefttime=Lefttime, besttime=Besttime},
	Term.

%%
decode_mail_sucess_s2c(Binary0)->
	Term = #mail_sucess_s2c{},
	Term.

%%
decode_ridepet_synthesis_opt_result_s2c(Binary0)->
	{Pettmpid, Binary1}=read_int32(Binary0),
	{Resultattr, Binary2}=decode_list(Binary1, fun decode_k/1),
	Term = #ridepet_synthesis_opt_result_s2c{pettmpid=Pettmpid, resultattr=Resultattr},
	Term.

%%
decode_pet_start_training_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Totaltime, Binary2}=read_int32(Binary1),
	{Type, Binary3}=read_int32(Binary2),
	Term = #pet_start_training_c2s{petid=Petid, totaltime=Totaltime, type=Type},
	Term.

%%
decode_treasure_transport_call_guild_help_s2c(Binary0)->
	Term = #treasure_transport_call_guild_help_s2c{},
	Term.

%%
decode_npc_attribute_s2c(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Attrs, Binary2}=decode_list(Binary1, fun decode_k/1),
	Term = #npc_attribute_s2c{npcid=Npcid, attrs=Attrs},
	Term.

%%
decode_finish_register_s2c(Binary0)->
	{Gourl, Binary1}=read_string(Binary0),
	Term = #finish_register_s2c{gourl=Gourl},
	Term.

%%
decode_activity_state_init_s2c(Binary0)->
	{Aslist, Binary1}=decode_list(Binary0, fun decode_acs/1),
	Term = #activity_state_init_s2c{aslist=Aslist},
	Term.

%%
decode_pet_explore_speedup_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	Term = #pet_explore_speedup_c2s{petid=Petid},
	Term.

%%
decode_qz_get_balance_error_s2c(Binary0)->
	{Error, Binary1}=read_int32(Binary0),
	Term = #qz_get_balance_error_s2c{error=Error},
	Term.

%%
decode_delete_friend_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #delete_friend_failed_s2c{reason=Reason},
	Term.

%%
decode_pet_upgrade_quality_up_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Petid, Binary2}=read_int64(Binary1),
	{Needs, Binary3}=read_int32(Binary2),
	Term = #pet_upgrade_quality_up_c2s{type=Type, petid=Petid, needs=Needs},
	Term.

%%
decode_congratulations_error_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #congratulations_error_s2c{reason=Reason},
	Term.

%%
decode_loop_tower_challenge_again_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Again, Binary2}=read_int32(Binary1),
	Term = #loop_tower_challenge_again_c2s{type=Type, again=Again},
	Term.

%%
decode_leave_loop_instance_c2s(Binary0)->
	Term = #leave_loop_instance_c2s{},
	Term.

%%
decode_continuous_logging_gift_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Nowawardday, Binary2}=read_int32(Binary1),
	Term = #continuous_logging_gift_c2s{type=Type, nowawardday=Nowawardday},
	Term.

%%
decode_start_everquest_s2c(Binary0)->
	{Everqid, Binary1}=read_int32(Binary0),
	{Questid, Binary2}=read_int32(Binary1),
	{Free_fresh_times, Binary3}=read_int32(Binary2),
	{Round, Binary4}=read_int32(Binary3),
	{Section, Binary5}=read_int32(Binary4),
	{Quality, Binary6}=read_int32(Binary5),
	{Npcid, Binary7}=read_int64(Binary6),
	{Resettime, Binary8}=read_int32(Binary7),
	Term = #start_everquest_s2c{everqid=Everqid, questid=Questid, free_fresh_times=Free_fresh_times, round=Round, section=Section, quality=Quality, npcid=Npcid, resettime=Resettime},
	Term.

%%
decode_mainline_protect_npc_info_s2c(Binary0)->
	{Npcprotoid, Binary1}=read_int32(Binary0),
	{Maxhp, Binary2}=read_int32(Binary1),
	{Curhp, Binary3}=read_int32(Binary2),
	Term = #mainline_protect_npc_info_s2c{npcprotoid=Npcprotoid, maxhp=Maxhp, curhp=Curhp},
	Term.


%%
decode_leave_loop_instance_s2c(Binary0)->
	{Layer, Binary1}=read_int32(Binary0),
	{Result, Binary2}=read_int32(Binary1),
	Term = #leave_loop_instance_s2c{layer=Layer, result=Result},
	Term.

%%
decode_rank_judge_opt_result_s2c(Binary0)->
	{Roleid, Binary1}=read_int32(Binary0),
	{Disdainnum, Binary2}=read_int32(Binary1),
	{Praisednum, Binary3}=read_int32(Binary2),
	{Leftnum, Binary4}=read_int32(Binary3),
	Term = #rank_judge_opt_result_s2c{roleid=Roleid, disdainnum=Disdainnum, praisednum=Praisednum, leftnum=Leftnum},
	Term.

%%
%%decode_learned_pet_skill_s2c(Binary0)->
%	{Pskills, Binary1}=decode_ps(Binary0),
%	Term = #learned_pet_skill_s2c{pskills=Pskills},
%	Term.

%%
decode_companion_sitdown_start_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #companion_sitdown_start_c2s{roleid=Roleid},
	Term.

%%
decode_pet_explore_stop_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	Term = #pet_explore_stop_c2s{petid=Petid},
	Term.

%%
decode_companion_sitdown_result_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	Term = #companion_sitdown_result_s2c{result=Result},
	Term.

%%
decode_stall_recede_item_c2s(Binary0)->
	{Itemlid, Binary1}=read_int32(Binary0),
	{Itemhid, Binary2}=read_int32(Binary1),
	Term = #stall_recede_item_c2s{itemlid=Itemlid, itemhid=Itemhid},
	Term.

%%
decode_guild_impeach_c2s(Binary0)->
	{Notice, Binary1}=read_string(Binary0),
	Term = #guild_impeach_c2s{notice=Notice},
	Term.

%%
decode_continuous_logging_board_c2s(Binary0)->
	Term = #continuous_logging_board_c2s{},
	Term.

%%
decode_guild_contribute_log_s2c(Binary0)->
	{Roles, Binary1}=decode_list(Binary0, fun decode_rcs/1),
	Term = #guild_contribute_log_s2c{roles=Roles},
	Term.

%%
decode_user_auth_c2s(Binary0)->
	{Username, Binary1}=read_string(Binary0),
	{Userid, Binary2}=read_string(Binary1),
	{Time, Binary3}=read_string(Binary2),
	{Cm, Binary4}=read_string(Binary3),
	{Flag, Binary5}=read_string(Binary4),
	{Userip, Binary6}=read_string(Binary5),
	{Type, Binary7}=read_string(Binary6),
	{Sid, Binary8}=read_string(Binary7),
	{Serverid, Binary9}=read_int32(Binary8),
	{Openid, Binary10}=read_string(Binary9),
	{Openkey, Binary11}=read_string(Binary10),
	{Appid, Binary12}=read_string(Binary11),
	{Pf, Binary13}=read_string(Binary12),
	{Pfkey, Binary14}=read_string(Binary13),
	Term = #user_auth_c2s{username=Username, userid=Userid, time=Time, cm=Cm, flag=Flag, userip=Userip, type=Type, sid=Sid, serverid=Serverid, openid=Openid, openkey=Openkey, appid=Appid, pf=Pf, pfkey=Pfkey},
	Term.

%%
decode_loop_instance_reward_c2s(Binary0)->
	Term = #loop_instance_reward_c2s{},
	Term.

%%
decode_dragon_fight_left_time_s2c(Binary0)->
	{Left_seconds, Binary1}=read_int32(Binary0),
	Term = #dragon_fight_left_time_s2c{left_seconds=Left_seconds},
	Term.

%%
decode_pet_explore_error_s2c(Binary0)->
	{Error, Binary1}=read_int32(Binary0),
	Term = #pet_explore_error_s2c{error=Error},
	Term.

%%
decode_be_killed_s2c(Binary0)->
	{Creatureid, Binary1}=read_int64(Binary0),
	{Murderer, Binary2}=read_string(Binary1),
	{Deadtype, Binary3}=read_int32(Binary2),
	{Posx, Binary4}=read_int32(Binary3),
	{Posy, Binary5}=read_int32(Binary4),
	{Series_kills, Binary6}=read_int32(Binary5),
	Term = #be_killed_s2c{creatureid=Creatureid, murderer=Murderer, deadtype=Deadtype, posx=Posx, posy=Posy, series_kills=Series_kills},
	Term.

%%
decode_update_pet_skill_s2c(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Skills, Binary2}=decode_psk(Binary1),
	Term = #update_pet_skill_s2c{petid=Petid, skills=Skills},
	Term.

%%
decode_continuous_days_clear_c2s(Binary0)->
	Term = #continuous_days_clear_c2s{},
	Term.

%%
decode_set_black_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #set_black_s2c{roleid=Roleid},
	Term.

%%
decode_congratulations_receive_s2c(Binary0)->
	{Exp, Binary1}=read_int32(Binary0),
	{Soulpower, Binary2}=read_int32(Binary1),
	{Type, Binary3}=read_int32(Binary2),
	{Rolename, Binary4}=read_string(Binary3),
	{Level, Binary5}=read_int32(Binary4),
	{Roleid, Binary6}=read_int64(Binary5),
	Term = #congratulations_receive_s2c{exp=Exp, soulpower=Soulpower, type=Type, rolename=Rolename, level=Level, roleid=Roleid},
	Term.

%%
decode_guild_impeach_result_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	Term = #guild_impeach_result_s2c{result=Result},
	Term.

%%
decode_mainline_opt_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #mainline_opt_s2c{errno=Errno},
	Term.

%%
decode_country_opt_s2c(Binary0)->
	{Code, Binary1}=read_int32(Binary0),
	Term = #country_opt_s2c{code=Code},
	Term.

%%
decode_stalls_search_c2s(Binary0)->
	{Index, Binary1}=read_int32(Binary0),
	Term = #stalls_search_c2s{index=Index},
	Term.

%%
decode_mainline_init_s2c(Binary0)->
	{St, Binary1}=decode_list(Binary0, fun decode_stage/1),
	Term = #mainline_init_s2c{st=St},
	Term.

%%
decode_init_mall_item_list_c2s(Binary0)->
	{Ntype, Binary1}=read_int32(Binary0),
	Term = #init_mall_item_list_c2s{ntype=Ntype},
	Term.

%%
decode_continuous_opt_result_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	Term = #continuous_opt_result_s2c{result=Result},
	Term.

%%
decode_loop_instance_reward_s2c(Binary0)->
	{Layer, Binary1}=read_int32(Binary0),
	{Type, Binary2}=read_int32(Binary1),
	{Curlayer, Binary3}=read_int32(Binary2),
	Term = #loop_instance_reward_s2c{layer=Layer, type=Type, curlayer=Curlayer},
	Term.

%%
decode_rank_answer_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rk/1),
	Term = #rank_answer_s2c{param=Param},
	Term.

%%
decode_myfriends_s2c(Binary0)->
	{Friendinfos, Binary1}=decode_list(Binary0, fun decode_fr/1),
	Term = #myfriends_s2c{friendinfos=Friendinfos},
	Term.

%%
decode_leave_guild_battle_c2s(Binary0)->
	Term = #leave_guild_battle_c2s{},
	Term.

%%
decode_pet_explore_gain_info_s2c(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Gainitem, Binary2}=decode_list(Binary1, fun decode_lti/1),
	Term = #pet_explore_gain_info_s2c{petid=Petid, gainitem=Gainitem},
	Term.

%%
decode_mainline_update_s2c(Binary0)->
	{St, Binary1}=decode_stage(Binary0),
	{Type, Binary2}=read_int32(Binary1),
	Term = #mainline_update_s2c{st=St, type=Type},
	Term.

%%
decode_guild_update_log_s2c(Binary0)->
	{Log, Binary1}=decode_guildlog(Binary0),
	Term = #guild_update_log_s2c{log=Log},
	Term.

%%
decode_mail_status_query_s2c(Binary0)->
	{Mail_status, Binary1}=decode_list(Binary0, fun decode_ms/1),
	Term = #mail_status_query_s2c{mail_status=Mail_status},
	Term.

%%
decode_chat_private_c2s(Binary0)->
	{Serverid, Binary1}=read_int32(Binary0),
	{Roleid, Binary2}=read_int64(Binary1),
	Term = #chat_private_c2s{serverid=Serverid, roleid=Roleid},
	Term.

%%
decode_duel_result_s2c(Binary0)->
	{Winner, Binary1}=read_int64(Binary0),
	Term = #duel_result_s2c{winner=Winner},
	Term.

%%
decode_guild_impeach_info_c2s(Binary0)->
	Term = #guild_impeach_info_c2s{},
	Term.

%%
decode_mail_send_c2s(Binary0)->
	{Toi, Binary1}=read_string(Binary0),
	{Title, Binary2}=read_string(Binary1),
	{Content, Binary3}=read_string(Binary2),
	{Add_silver, Binary4}=read_int64(Binary3),
	{Add_item, Binary5}=read_int32_list(Binary4),
	Term = #mail_send_c2s{toi=Toi, title=Title, content=Content, add_silver=Add_silver, add_item=Add_item},
	Term.

%%
decode_stalls_search_item_c2s(Binary0)->
	{Searchstr, Binary1}=read_string(Binary0),
	{Index, Binary2}=read_int32(Binary1),
	Term = #stalls_search_item_c2s{searchstr=Searchstr, index=Index},
	Term.

%%
decode_init_mall_item_list_s2c(Binary0)->
	{Mitemlists, Binary1}=decode_list(Binary0, fun decode_mi/1),
	Term = #init_mall_item_list_s2c{mitemlists=Mitemlists},
	Term.

%%
decode_spa_join_c2s(Binary0)->
	{Spaid, Binary1}=read_int32(Binary0),
	Term = #spa_join_c2s{spaid=Spaid},
	Term.

%%
decode_other_role_into_view_s2c(Binary0)->
	{Other, Binary1}=decode_rl(Binary0),
	Term = #other_role_into_view_s2c{other=Other},
	Term.

%%
decode_continuous_logging_board_s2c(Binary0)->
	{Days, Binary1}=read_int32(Binary0),
	{Awarddays, Binary2}=read_int32_list(Binary1),
	Term = #continuous_logging_board_s2c{days=Days, awarddays=Awarddays},
	Term.


%%
decode_pet_stop_training_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	Term = #pet_stop_training_c2s{petid=Petid},
	Term.

%%
decode_loop_instance_remain_monsters_info_s2c(Binary0)->
	{Kill_num, Binary1}=read_int32(Binary0),
	{Remain_num, Binary2}=read_int32(Binary1),
	{Type, Binary3}=read_int32(Binary2),
	{Layer, Binary4}=read_int32(Binary3),
	Term = #loop_instance_remain_monsters_info_s2c{kill_num=Kill_num, remain_num=Remain_num, type=Type, layer=Layer},
	Term.

%%
decode_pet_add_attr_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Power_add, Binary2}=read_int32(Binary1),
	{Hitrate_add, Binary3}=read_int32(Binary2),
	{Criticalrate_add, Binary4}=read_int32(Binary3),
	{Stamina_add, Binary5}=read_int32(Binary4),
	Term = #pet_add_attr_c2s{petid=Petid, power_add=Power_add, hitrate_add=Hitrate_add, criticalrate_add=Criticalrate_add, stamina_add=Stamina_add},
	Term.

%%
decode_rank_chess_spirits_single_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rk/1),
	Term = #rank_chess_spirits_single_s2c{param=Param},
	Term.

%%
decode_battle_waiting_s2c(Binary0)->
	{Waitingtime, Binary1}=read_int32(Binary0),
	Term = #battle_waiting_s2c{waitingtime=Waitingtime},
	Term.

%%
decode_companion_reject_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #companion_reject_c2s{roleid=Roleid},
	Term.

%%
decode_change_country_notice_s2c(Binary0)->
	{Notice, Binary1}=read_string(Binary0),
	Term = #change_country_notice_s2c{notice=Notice},
	Term.


%%
decode_guild_impeach_info_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Notice, Binary2}=read_string(Binary1),
	{Support, Binary3}=read_int32(Binary2),
	{Opposite, Binary4}=read_int32(Binary3),
	{Vote, Binary5}=read_int32(Binary4),
	{Lefttime_s, Binary6}=read_int32(Binary5),
	Term = #guild_impeach_info_s2c{roleid=Roleid, notice=Notice, support=Support, opposite=Opposite, vote=Vote, lefttime_s=Lefttime_s},
	Term.

%%
decode_mail_arrived_s2c(Binary0)->
	{Mail_status, Binary1}=decode_list(Binary0, fun decode_ms/1),
	Term = #mail_arrived_s2c{mail_status=Mail_status},
	Term.

%%
decode_mainline_start_entry_c2s(Binary0)->
	{Chapter, Binary1}=read_int32(Binary0),
	{Stage, Binary2}=read_int32(Binary1),
	{Difficulty, Binary3}=read_int32(Binary2),
	Term = #mainline_start_entry_c2s{chapter=Chapter, stage=Stage, difficulty=Difficulty},
	Term.

%%
decode_leave_guild_battle_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	Term = #leave_guild_battle_s2c{result=Result},
	Term.

%%
decode_loop_instance_kill_monsters_info_s2c(Binary0)->
	{Npcprotoid, Binary1}=read_int32(Binary0),
	{Neednum, Binary2}=read_int32(Binary1),
	{Type, Binary3}=read_int32(Binary2),
	{Layer, Binary4}=read_int32(Binary3),
	Term = #loop_instance_kill_monsters_info_s2c{npcprotoid=Npcprotoid, neednum=Neednum, type=Type, layer=Layer},
	Term.

%%
decode_guild_battle_opt_s2c(Binary0)->
	{Code, Binary1}=read_int32(Binary0),
	Term = #guild_battle_opt_s2c{code=Code},
	Term.

%%
decode_buff_affect_attr_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Attrs, Binary2}=decode_list(Binary1, fun decode_k/1),
	Term = #buff_affect_attr_s2c{roleid=Roleid, attrs=Attrs},
	Term.

%%
decode_pet_swap_slot_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	Term = #pet_swap_slot_c2s{petid=Petid, slot=Slot},
	Term.

%%
decode_mall_item_list_c2s(Binary0)->
	{Ntype, Binary1}=read_int32(Binary0),
	Term = #mall_item_list_c2s{ntype=Ntype},
	Term.

%%
decode_stall_detail_c2s(Binary0)->
	{Stallid, Binary1}=read_int64(Binary0),
	Term = #stall_detail_c2s{stallid=Stallid},
	Term.

%%好好友信息
decode_add_friend_c2s(Binary0)->
	{Fn, Binary1}=read_string(Binary0),
	Term = #add_friend_c2s{fn=Fn},
	Term.

%%
decode_add_friend_confirm_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Type, Binary2}=read_int32(Binary1),
	Term = #add_friend_confirm_c2s{roleid=Roleid, type=Type},
	Term.

%%找人
decode_search_role_c2s(Binary0)->
	{Name, Binary1}=read_string(Binary0),
	Term = #search_role_c2s{name=Name},
	Term.

decode_npc_into_view_s2c(Binary0)->
	{Npc, Binary1}=decode_nl(Binary0),
	Term = #npc_into_view_s2c{npc=Npc},
	Term.

%%
decode_rank_chess_spirits_team_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rc/1),
	Term = #rank_chess_spirits_team_s2c{param=Param},
	Term.



%%
decode_spa_join_s2c(Binary0)->
	{Spaid, Binary1}=read_int32(Binary0),
	{Chopping, Binary2}=read_int32(Binary1),
	{Swimming, Binary3}=read_int32(Binary2),
	{Lefttime, Binary4}=read_int32(Binary3),
	{Choppingtime, Binary5}=read_int32(Binary4),
	{Swimmingtime, Binary6}=read_int32(Binary5),
	Term = #spa_join_s2c{spaid=Spaid, chopping=Chopping, swimming=Swimming, lefttime=Lefttime, choppingtime=Choppingtime, swimmingtime=Swimmingtime},
	Term.

%%
decode_loudspeaker_opt_s2c(Binary0)->
	{Reasonid, Binary1}=read_int32(Binary0),
	Term = #loudspeaker_opt_s2c{reasonid=Reasonid},
	Term.

%%
decode_star_spawns_section_s2c(Binary0)->
	{Section, Binary1}=read_int32(Binary0),
	Term = #star_spawns_section_s2c{section=Section},
	Term.

%%
decode_guild_battle_stop_s2c(Binary0)->
	Term = #guild_battle_stop_s2c{},
	Term.

%%
decode_everquest_list_s2c(Binary0)->
	{Everquests, Binary1}=decode_list(Binary0, fun decode_eq/1),
	Term = #everquest_list_s2c{everquests=Everquests},
	Term.

%%
decode_user_auth_fail_s2c(Binary0)->
	{Reasonid, Binary1}=read_int32(Binary0),
	Term = #user_auth_fail_s2c{reasonid=Reasonid},
	Term.

%%
decode_treasure_storage_init_c2s(Binary0)->
	Term = #treasure_storage_init_c2s{},
	Term.

%%
decode_revert_black_c2s(Binary0)->
	{Fn, Binary1}=read_string(Binary0),
	Term = #revert_black_c2s{fn=Fn},
	Term.

%%
decode_pet_up_stamina_growth_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	{Next, Binary2}=read_int32(Binary1),
	Term = #pet_up_stamina_growth_s2c{result=Result, next=Next},
	Term.

%%
decode_loop_instance_kill_monsters_info_init_s2c(Binary0)->
	{Info, Binary1}=decode_list(Binary0, fun decode_kmi/1),
	{Type, Binary2}=read_int32(Binary1),
	{Layer, Binary3}=read_int32(Binary2),
	Term = #loop_instance_kill_monsters_info_init_s2c{info=Info, type=Type, layer=Layer},
	Term.

%%
decode_stall_buy_item_c2s(Binary0)->
	{Stallid, Binary1}=read_int64(Binary0),
	{Itemlid, Binary2}=read_int32(Binary1),
	{Itemhid, Binary3}=read_int32(Binary2),
	Term = #stall_buy_item_c2s{stallid=Stallid, itemlid=Itemlid, itemhid=Itemhid},
	Term.

%%
decode_guild_recruite_info_s2c(Binary0)->
	{Recinfos, Binary1}=decode_list(Binary0, fun decode_gr/1),
	Term = #guild_recruite_info_s2c{recinfos=Recinfos},
	Term.

%%
decode_mall_item_list_s2c(Binary0)->
	{Mitemlists, Binary1}=decode_list(Binary0, fun decode_mi/1),
	Term = #mall_item_list_s2c{mitemlists=Mitemlists},
	Term.

%%
decode_mainline_start_entry_s2c(Binary0)->
	{Chapter, Binary1}=read_int32(Binary0),
	{Stage, Binary2}=read_int32(Binary1),
	{Difficulty, Binary3}=read_int32(Binary2),
	{Opcode, Binary4}=read_int32(Binary3),
	Term = #mainline_start_entry_s2c{chapter=Chapter, stage=Stage, difficulty=Difficulty, opcode=Opcode},
	Term.

%%
decode_pet_delete_s2c(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	Term = #pet_delete_s2c{petid=Petid},
	Term.

%%
decode_pet_speedup_training_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Speeduptime, Binary2}=read_int32(Binary1),
	Term = #pet_speedup_training_c2s{petid=Petid, speeduptime=Speeduptime},
	Term.

%%
decode_creature_outof_view_s2c(Binary0)->
	{Creature_id, Binary1}=read_int64(Binary0),
	Term = #creature_outof_view_s2c{creature_id=Creature_id},
	Term.

%%
decode_companion_reject_s2c(Binary0)->
	{Rolename, Binary1}=read_string(Binary0),
	Term = #companion_reject_s2c{rolename=Rolename},
	Term.

%%
decode_rank_loop_tower_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rk/1),
	Term = #rank_loop_tower_s2c{param=Param},
	Term.

%%
decode_enum_skill_item_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	Term = #enum_skill_item_c2s{npcid=Npcid},
	Term.

%%
decode_change_country_transport_c2s(Binary0)->
	{Tp_start, Binary1}=read_int32(Binary0),
	Term = #change_country_transport_c2s{tp_start=Tp_start},
	Term.

%%
decode_congratulations_received_c2s(Binary0)->
	{Level, Binary1}=read_int32(Binary0),
	{Rolename, Binary2}=read_string(Binary1),
	Term = #congratulations_received_c2s{level=Level, rolename=Rolename},
	Term.

%%
decode_role_map_change_c2s(Binary0)->
	{Seqid, Binary1}=read_int32(Binary0),
	{Transid, Binary2}=read_int32(Binary1),
	Term = #role_map_change_c2s{seqid=Seqid, transid=Transid},
	Term.

%%
decode_guild_impeach_vote_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #guild_impeach_vote_c2s{type=Type},
	Term.

%%
decode_update_everquest_s2c(Binary0)->
	{Everqid, Binary1}=read_int32(Binary0),
	{Questid, Binary2}=read_int32(Binary1),
	{Free_fresh_times, Binary3}=read_int32(Binary2),
	{Round, Binary4}=read_int32(Binary3),
	{Section, Binary5}=read_int32(Binary4),
	{Quality, Binary6}=read_int32(Binary5),
	Term = #update_everquest_s2c{everqid=Everqid, questid=Questid, free_fresh_times=Free_fresh_times, round=Round, section=Section, quality=Quality},
	Term.

%%
decode_mall_item_list_special_c2s(Binary0)->
	{Ntype2, Binary1}=read_int32(Binary0),
	Term = #mall_item_list_special_c2s{ntype2=Ntype2},
	Term.

%%


%%
decode_dragon_fight_start_s2c(Binary0)->
	{Duration, Binary1}=read_int32(Binary0),
	Term = #dragon_fight_start_s2c{duration=Duration},
	Term.

%%
decode_pet_present_s2c(Binary0)->
	{Present_pets, Binary1}=decode_list(Binary0, fun decode_pp/1).
	%%Term = #pet_present_s2c{present_pets=Present_pets},
	%%Term.

%%
decode_role_change_map_c2s(Binary0)->
	Term = #role_change_map_c2s{},
	Term.

%%
decode_rank_killer_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rk/1),
	Term = #rank_killer_s2c{param=Param},
	Term.

%%
decode_battle_start_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Lefttime, Binary2}=read_int32(Binary1),
	Term = #battle_start_s2c{type=Type, lefttime=Lefttime},
	Term.

%%
decode_fatigue_prompt_with_type_s2c(Binary0)->
	{Prompt, Binary1}=read_string(Binary0),
	{Type, Binary2}=read_int32(Binary1),
	Term = #fatigue_prompt_with_type_s2c{prompt=Prompt, type=Type},
	Term.

%%
decode_guild_clear_nickname_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #guild_clear_nickname_c2s{roleid=Roleid},
	Term.

%%
decode_role_change_map_ok_s2c(Binary0)->
	Term = #role_change_map_ok_s2c{},
	Term.

%%
decode_enum_skill_item_fail_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #enum_skill_item_fail_s2c{reason=Reason},
	Term.

%%
decode_offline_exp_init_s2c(Binary0)->
	{Hour, Binary1}=read_int32(Binary0),
	{Totalexp, Binary2}=read_int32(Binary1),
	Term = #offline_exp_init_s2c{hour=Hour, totalexp=Totalexp},
	Term.

%%
decode_stall_rename_c2s(Binary0)->
	{Stall_name, Binary1}=read_string(Binary0),
	Term = #stall_rename_c2s{stall_name=Stall_name},
	Term.

%%
decode_treasure_storage_info_s2c(Binary0)->
	{Items, Binary1}=decode_list(Binary0, fun decode_tsi/1),
	Term = #treasure_storage_info_s2c{items=Items},
	Term.

%%
decode_loop_tower_challenge_success_s2c(Binary0)->
	{Layer, Binary1}=read_int32(Binary0),
	{Bonus, Binary2}=read_int32(Binary1),
	Term = #loop_tower_challenge_success_s2c{layer=Layer, bonus=Bonus},
	Term.

%%
decode_mall_item_list_special_s2c(Binary0)->
	{Mitemlists, Binary1}=decode_list(Binary0, fun decode_mi/1),
	Term = #mall_item_list_special_s2c{mitemlists=Mitemlists},
	Term.

%%
decode_revert_black_s2c(Binary0)->
	{Friendinfo, Binary1}=decode_fr(Binary0),
	Term = #revert_black_s2c{friendinfo=Friendinfo},
	Term.

%%
decode_detail_friend_c2s(Binary0)->
	{Fn, Binary1}=read_string(Binary0),
	Term = #detail_friend_c2s{fn=Fn},
	Term.

%%
decode_pet_present_apply_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #pet_present_apply_c2s{slot=Slot},
	Term.

%%
decode_spa_leave_s2c(Binary0)->
	Term = #spa_leave_s2c{},
	Term.

%%
decode_mainline_start_c2s(Binary0)->
	{Chapter, Binary1}=read_int32(Binary0),
	{Stage, Binary2}=read_int32(Binary1),
	Term = #mainline_start_c2s{chapter=Chapter, stage=Stage},
	Term.

%%
decode_fly_shoes_c2s(Binary0)->
	{Mapid, Binary1}=read_int32(Binary0),
	{Posx, Binary2}=read_int32(Binary1),
	{Posy, Binary3}=read_int32(Binary2),
	{Slot, Binary4}=read_int32(Binary3),
	Term = #fly_shoes_c2s{mapid=Mapid, posx=Posx, posy=Posy, slot=Slot},
	Term.

%%
decode_spa_leave_c2s(Binary0)->
	Term = #spa_leave_c2s{},
	Term.

%%
decode_rank_moneys_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rk/1),
	Term = #rank_moneys_s2c{param=Param},
	Term.

%%
decode_country_init_c2s(Binary0)->
	Term = #country_init_c2s{},
	Term.

%%
decode_role_change_map_fail_s2c(Binary0)->
	Term = #role_change_map_fail_s2c{},
	Term.

%%
decode_guild_mastercall_success_s2c(Binary0)->
	Term = #guild_mastercall_success_s2c{},
	Term.

%%
decode_welfare_panel_init_c2s(Binary0)->
	Term = #welfare_panel_init_c2s{},
	Term.

%%
decode_guild_join_lefttime_s2c(Binary0)->
	{Lefttime, Binary1}=read_int32(Binary0),
	Term = #guild_join_lefttime_s2c{lefttime=Lefttime},
	Term.

%%
decode_add_black_c2s(Binary0)->
	{Bn, Binary1}=read_string(Binary0),
	Term = #add_black_c2s{bn=Bn},
	Term.

%%
decode_guild_impeach_stop_s2c(Binary0)->
	Term = #guild_impeach_stop_s2c{},
	Term.

%%
decode_pet_riseup_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Needs, Binary2}=read_int32(Binary1),
	{Protect, Binary3}=read_int32(Binary2),
	Term = #pet_riseup_c2s{petid=Petid, needs=Needs, protect=Protect},
	Term.

%%
decode_role_move_c2s(Binary0)->
	{Time, Binary1}=read_int32(Binary0),
	{Posx, Binary2}=read_int32(Binary1),
	{Posy, Binary3}=read_int32(Binary2),
	{Path, Binary4}=decode_list(Binary3, fun decode_c/1),
	Term = #role_move_c2s{time=Time, posx=Posx, posy=Posy, path=Path},
	Term.

%%
decode_pet_present_apply_s2c(Binary0)->
	{Delete_slot, Binary1}=read_int32(Binary0),
	Term = #pet_present_apply_s2c{delete_slot=Delete_slot},
	Term.

%%
decode_trade_role_apply_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #trade_role_apply_c2s{roleid=Roleid},
	Term.

%%
decode_mall_item_list_sales_c2s(Binary0)->
	{Ntype, Binary1}=read_int32(Binary0),
	Term = #mall_item_list_sales_c2s{ntype=Ntype},
	Term.

%%
decode_skill_panel_c2s(Binary0)->
	Term = #skill_panel_c2s{},
	Term.

%%
decode_treasure_storage_init_end_s2c(Binary0)->
	Term = #treasure_storage_init_end_s2c{},
	Term.

%%
decode_get_instance_log_c2s(Binary0)->
	Term = #get_instance_log_c2s{},
	Term.

%%
decode_spa_chopping_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	Term = #spa_chopping_c2s{roleid=Roleid, slot=Slot},
	Term.

%%
decode_rank_melee_power_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rk/1),
	Term = #rank_melee_power_s2c{param=Param},
	Term.

%%
decode_treasure_storage_getitem_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Itemsign, Binary2}=read_int32(Binary1),
	Term = #treasure_storage_getitem_c2s{slot=Slot, itemsign=Itemsign},
	Term.

%%
decode_pet_wash_attr_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Type, Binary2}=read_int32(Binary1),
	Term = #pet_wash_attr_c2s{petid=Petid, type=Type},
	Term.

%%
decode_battle_self_join_s2c(Binary0)->
	{Trs, Binary1}=decode_list(Binary0, fun decode_tr/1),
	{Battletype, Binary2}=read_int32(Binary1),
	{Battleid, Binary3}=read_int32(Binary2),
	{Lefttime, Binary4}=read_int32(Binary3),
	Term = #battle_self_join_s2c{trs=Trs, battletype=Battletype, battleid=Battleid, lefttime=Lefttime},
	Term.

%%
decode_chat_private_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Level, Binary2}=read_int32(Binary1),
	{Roleclass, Binary3}=read_int32(Binary2),
	{Rolegender, Binary4}=read_int32(Binary3),
	{Signature, Binary5}=read_string(Binary4),
	{Guildname, Binary6}=read_string(Binary5),
	{Guildlid, Binary7}=read_int32(Binary6),
	{Guildhid, Binary8}=read_int32(Binary7),
	{Viptag, Binary9}=read_int32(Binary8),
	{Rolename, Binary10}=read_string(Binary9),
	{Serverid, Binary11}=read_int32(Binary10),
	Term = #chat_private_s2c{roleid=Roleid, level=Level, roleclass=Roleclass, rolegender=Rolegender, signature=Signature, guildname=Guildname, guildlid=Guildlid, guildhid=Guildhid, viptag=Viptag, rolename=Rolename, serverid=Serverid},
	Term.

%%
decode_spiritspower_state_update_s2c(Binary0)->
	{State, Binary1}=read_int32(Binary0),
	{Lefttime, Binary2}=read_int32(Binary1),
	{Curvalue, Binary3}=read_int32(Binary2),
	Term = #spiritspower_state_update_s2c{state=State, lefttime=Lefttime, curvalue=Curvalue},
	Term.

%%
decode_guild_battle_score_init_s2c(Binary0)->
	{Guildlist, Binary1}=decode_list(Binary0, fun decode_gbs/1),
	Term = #guild_battle_score_init_s2c{guildlist=Guildlist},
	Term.

%%
decode_get_instance_log_s2c(Binary0)->
	{Instance_id, Binary1}=read_int32_list(Binary0),
	{Times, Binary2}=read_int32_list(Binary1),
	Term = #get_instance_log_s2c{instance_id=Instance_id, times=Times},
	Term.

%%
decode_loop_tower_masters_s2c(Binary0)->
	{Ltms, Binary1}=decode_list(Binary0, fun decode_ltm/1),
	Term = #loop_tower_masters_s2c{ltms=Ltms},
	Term.

%%
decode_trade_role_accept_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #trade_role_accept_c2s{roleid=Roleid},
	Term.

%%
decode_mall_item_list_sales_s2c(Binary0)->
	{Mitemlists, Binary1}=decode_list(Binary0, fun decode_smi/1),
	Term = #mall_item_list_sales_s2c{mitemlists=Mitemlists},
	Term.

%%
decode_mainline_start_s2c(Binary0)->
	{Chapter, Binary1}=read_int32(Binary0),
	{Stage, Binary2}=read_int32(Binary1),
	{Difficulty, Binary3}=read_int32(Binary2),
	{Opcode, Binary4}=read_int32(Binary3),
	Term = #mainline_start_s2c{chapter=Chapter, stage=Stage, difficulty=Difficulty, opcode=Opcode},
	Term.

%%
decode_stall_detail_s2c(Binary0)->
	{Ownerid, Binary1}=read_int64(Binary0),
	{Stallid, Binary2}=read_int64(Binary1),
	{Stallname, Binary3}=read_string(Binary2),
	{Stallitems, Binary4}=decode_list(Binary3, fun decode_si/1),
	{Logs, Binary5}=read_string_list(Binary4),
	{Isonline, Binary6}=read_int32(Binary5),
	Term = #stall_detail_s2c{ownerid=Ownerid, stallid=Stallid, stallname=Stallname, stallitems=Stallitems, logs=Logs, isonline=Isonline},
	Term.

%%
decode_npc_swap_item_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Srcslot, Binary2}=read_int32(Binary1),
	{Desslot, Binary3}=read_int32(Binary2),
	Term = #npc_swap_item_c2s{npcid=Npcid, srcslot=Srcslot, desslot=Desslot},
	Term.

%%
decode_enum_skill_item_s2c(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	Term = #enum_skill_item_s2c{npcid=Npcid},
	Term.

%%
decode_detail_friend_s2c(Binary0)->
	{Defr, Binary1}=decode_dfr(Binary0),
	Term = #detail_friend_s2c{defr=Defr},
	Term.

%%
decode_rank_range_power_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rk/1),
	Term = #rank_range_power_s2c{param=Param},
	Term.

%%
decode_spa_stop_s2c(Binary0)->
	Term = #spa_stop_s2c{},
	Term.

%%
decode_delete_black_c2s(Binary0)->
	{Fn, Binary1}=read_string(Binary0),
	Term = #delete_black_c2s{fn=Fn},
	Term.

%%
decode_dragon_fight_join_c2s(Binary0)->
	Term = #dragon_fight_join_c2s{},
	Term.

%%
decode_guild_battle_ready_s2c(Binary0)->
	{Remaintime, Binary1}=read_int32(Binary0),
	Term = #guild_battle_ready_s2c{remaintime=Remaintime},
	Term.

%%
decode_dragon_fight_end_s2c(Binary0)->
	{Rednum, Binary1}=read_int32(Binary0),
	{Bluenum, Binary2}=read_int32(Binary1),
	{Winfaction, Binary3}=read_int32(Binary2),
	Term = #dragon_fight_end_s2c{rednum=Rednum, bluenum=Bluenum, winfaction=Winfaction},
	Term.

%%
decode_pet_learn_skill_cover_best_s2c(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	{Skillid, Binary3}=read_int32(Binary2),
	{Oldlevel, Binary4}=read_int32(Binary3),
	{Newlevel, Binary5}=read_int32(Binary4),
	Term = #pet_learn_skill_cover_best_s2c{petid=Petid, slot=Slot, skillid=Skillid, oldlevel=Oldlevel, newlevel=Newlevel},
	Term.

%%
decode_init_hot_item_s2c(Binary0)->
	{Lists, Binary1}=decode_list(Binary0, fun decode_imi/1),
	Term = #init_hot_item_s2c{lists=Lists},
	Term.

%%
decode_stop_move_c2s(Binary0)->
	{Time, Binary1}=read_int32(Binary0),
	{Posx, Binary2}=read_int32(Binary1),
	{Posy, Binary3}=read_int32(Binary2),
	Term = #stop_move_c2s{time=Time, posx=Posx, posy=Posy},
	Term.

%%
decode_spa_chopping_s2c(Binary0)->
	{Name, Binary1}=read_string(Binary0),
	{Bename, Binary2}=read_string(Binary1),
	{Remain, Binary3}=read_int32(Binary2),
	Term = #spa_chopping_s2c{name=Name, bename=Bename, remain=Remain},
	Term.

%%
decode_add_friend_success_s2c(Binary0)->
	{Friendinfo, Binary1}=decode_fr(Binary0),
	Term = #add_friend_success_s2c{friendinfo=Friendinfo},
	Term.

%%
decode_loop_tower_enter_c2s(Binary0)->
	{Layer, Binary1}=read_int32(Binary0),
	{Enter, Binary2}=read_int32(Binary1),
	{Convey, Binary3}=read_int32(Binary2),
	Term = #loop_tower_enter_c2s{layer=Layer, enter=Enter, convey=Convey},
	Term.

%%
decode_chess_spirit_cast_chess_skill_c2s(Binary0)->
	Term = #chess_spirit_cast_chess_skill_c2s{},
	Term.

%%
decode_spiritspower_reset_c2s(Binary0)->
	Term = #spiritspower_reset_c2s{},
	Term.

%%
decode_detail_friend_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #detail_friend_failed_s2c{reason=Reason},
	Term.

%%
decode_battle_reward_c2s(Binary0)->
	Term = #battle_reward_c2s{},
	Term.

%%
decode_rank_magic_power_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rk/1),
	Term = #rank_magic_power_s2c{param=Param},
	Term.

%%
decode_skill_learn_item_c2s(Binary0)->
	{Skillid, Binary1}=read_int32(Binary0),
	Term = #skill_learn_item_c2s{skillid=Skillid},
	Term.

%%
decode_mainline_end_c2s(Binary0)->
	{Chapter, Binary1}=read_int32(Binary0),
	{Stage, Binary2}=read_int32(Binary1),
	Term = #mainline_end_c2s{chapter=Chapter, stage=Stage},
	Term.

%%
decode_group_apply_c2s(Binary0)->
	{Username, Binary1}=read_string(Binary0),
	Term = #group_apply_c2s{username=Username},
	Term.

%%
decode_treasure_storage_getallitems_c2s(Binary0)->
	Term = #treasure_storage_getallitems_c2s{},
	Term.

%%
decode_callback_guild_monster_c2s(Binary0)->
	{Monsterid, Binary1}=read_int32(Binary0),
	Term = #callback_guild_monster_c2s{monsterid=Monsterid},
	Term.

%%
decode_pet_upgrade_quality_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	{Value, Binary2}=read_int32(Binary1),
	Term = #pet_upgrade_quality_s2c{result=Result, value=Value},
	Term.

%%
decode_init_latest_item_s2c(Binary0)->
	{Lists, Binary1}=decode_list(Binary0, fun decode_imi/1),
	Term = #init_latest_item_s2c{lists=Lists},
	Term.

%%
decode_battle_reward_by_records_c2s(Binary0)->
	{Year, Binary1}=read_int32(Binary0),
	{Month, Binary2}=read_int32(Binary1),
	{Day, Binary3}=read_int32(Binary2),
	{Battletype, Binary4}=read_int32(Binary3),
	{Battleid, Binary5}=read_int32(Binary4),
	Term = #battle_reward_by_records_c2s{year=Year, month=Month, day=Day, battletype=Battletype, battleid=Battleid},
	Term.

%%
decode_treasure_storage_updateitem_s2c(Binary0)->
	{Itemlist, Binary1}=decode_list(Binary0, fun decode_tsi/1),
	Term = #treasure_storage_updateitem_s2c{itemlist=Itemlist},
	Term.

%%
decode_spa_swimming_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #spa_swimming_c2s{roleid=Roleid},
	Term.

%%
decode_christmas_tree_grow_up_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	Term = #christmas_tree_grow_up_c2s{npcid=Npcid, slot=Slot},
	Term.

%%
decode_guild_mastercall_accept_c2s(Binary0)->
	Term = #guild_mastercall_accept_c2s{},
	Term.

%%
decode_loop_tower_reward_c2s(Binary0)->
	{Bonus, Binary1}=read_int32(Binary0),
	Term = #loop_tower_reward_c2s{bonus=Bonus},
	Term.

%%
decode_guild_member_pos_c2s(Binary0)->
	Term = #guild_member_pos_c2s{},
	Term.

%%
decode_position_friend_c2s(Binary0)->
	{Fn, Binary1}=read_string(Binary0),
	Term = #position_friend_c2s{fn=Fn},
	Term.

%%
decode_skill_learn_item_fail_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #skill_learn_item_fail_s2c{reason=Reason},
	Term.

%%
decode_pet_training_init_info_s2c(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Totaltime, Binary2}=read_int32(Binary1),
	{Remaintime, Binary3}=read_int32(Binary2),
	Term = #pet_training_init_info_s2c{petid=Petid, totaltime=Totaltime, remaintime=Remaintime},
	Term.

%%
decode_heartbeat_c2s(Binary0)->
	{Beat_time, Binary1}=read_int32(Binary0),
	Term = #heartbeat_c2s{beat_time=Beat_time},
	Term.

%%
decode_mainline_end_s2c(Binary0)->
	Term = #mainline_end_s2c{},
	Term.

%%
decode_delete_black_s2c(Binary0)->
	Term = #delete_black_s2c{},
	Term.

%%
decode_treasure_storage_additem_s2c(Binary0)->
	{Items, Binary1}=decode_list(Binary0, fun decode_tsi/1),
	Term = #treasure_storage_additem_s2c{items=Items},
	Term.

%%
decode_rank_loop_tower_num_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rk/1),
	Term = #rank_loop_tower_num_s2c{param=Param},
	Term.

%%
decode_change_role_mall_integral_s2c(Binary0)->
	{Charge_integral, Binary1}=read_int32(Binary0),
	{By_item_integral, Binary2}=read_int32(Binary1),
	Term = #change_role_mall_integral_s2c{charge_integral=Charge_integral, by_item_integral=By_item_integral},
	Term.

%%
decode_spa_swimming_s2c(Binary0)->
	{Name, Binary1}=read_string(Binary0),
	{Bename, Binary2}=read_string(Binary1),
	{Remain, Binary3}=read_int32(Binary2),
	Term = #spa_swimming_s2c{name=Name, bename=Bename, remain=Remain},
	Term.

%%
decode_change_country_transport_s2c(Binary0)->
	{Tp_start, Binary1}=read_int32(Binary0),
	{Tp_stop, Binary2}=read_int32(Binary1),
	Term = #change_country_transport_s2c{tp_start=Tp_start, tp_stop=Tp_stop},
	Term.

%%
decode_apply_guild_battle_c2s(Binary0)->
	Term = #apply_guild_battle_c2s{},
	Term.

%%
decode_guild_treasure_update_item_s2c(Binary0)->
	{Treasuretype, Binary1}=read_int32(Binary0),
	{Item, Binary2}=decode_gti(Binary1),
	Term = #guild_treasure_update_item_s2c{treasuretype=Treasuretype, item=Item},
	Term.

%%
decode_swap_item_c2s(Binary0)->
	{Srcslot, Binary1}=read_int32(Binary0),
	{Desslot, Binary2}=read_int32(Binary1),
	Term = #swap_item_c2s{srcslot=Srcslot, desslot=Desslot},
	Term.

%%
decode_christmas_tree_hp_s2c(Binary0)->
	{Curhp, Binary1}=read_int32(Binary0),
	{Maxhp, Binary2}=read_int32(Binary1),
	Term = #christmas_tree_hp_s2c{curhp=Curhp, maxhp=Maxhp},
	Term.

%%
decode_mainline_result_s2c(Binary0)->
	{Chapter, Binary1}=read_int32(Binary0),
	{Stage, Binary2}=read_int32(Binary1),
	{Difficulty, Binary3}=read_int32(Binary2),
	{Result, Binary4}=read_int32(Binary3),
	{Reward, Binary5}=read_int32(Binary4),
	{Bestscore, Binary6}=read_int32(Binary5),
	{Score, Binary7}=read_int32(Binary6),
	{Duration, Binary8}=read_int32(Binary7),
	Term = #mainline_result_s2c{chapter=Chapter, stage=Stage, difficulty=Difficulty, result=Result, reward=Reward, bestscore=Bestscore, score=Score, duration=Duration},
	Term.

%%
decode_beads_pray_fail_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #beads_pray_fail_s2c{type=Type},
	Term.

%%
decode_explore_storage_init_c2s(Binary0)->
	Term = #explore_storage_init_c2s{},
	Term.

%%
decode_rank_level_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rk/1),
	Term = #rank_level_s2c{param=Param},
	Term.

%%
decode_pet_random_talent_s2c(Binary0)->
	{Power, Binary1}=read_int32(Binary0),
	{Hitrate, Binary2}=read_int32(Binary1),
	{Criticalrate, Binary3}=read_int32(Binary2),
	{Stamina, Binary4}=read_int32(Binary3),
	Term = #pet_random_talent_s2c{power=Power, hitrate=Hitrate, criticalrate=Criticalrate, stamina=Stamina},
	Term.

%%
decode_venation_update_s2c(Binary0)->
	{Venation, Binary1}=read_int32(Binary0),
	{Point, Binary2}=read_int32(Binary1),
	{Attr, Binary3}=decode_list(Binary2, fun decode_k/1),
	Term = #venation_update_s2c{venation=Venation, point=Point, attr=Attr},
	Term.

%%
decode_trade_role_decline_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #trade_role_decline_c2s{roleid=Roleid},
	Term.

%%
decode_guild_get_shop_item_s2c(Binary0)->
	{Shoptype, Binary1}=read_int32(Binary0),
	{Itemlist, Binary2}=decode_list(Binary1, fun decode_gsi/1),
	Term = #guild_get_shop_item_s2c{shoptype=Shoptype, itemlist=Itemlist},
	Term.

%%
decode_explore_storage_info_s2c(Binary0)->
	{Items, Binary1}=decode_list(Binary0, fun decode_tsi/1),
	Term = #explore_storage_info_s2c{items=Items},
	Term.

%%
decode_treasure_transport_call_guild_help_result_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	Term = #treasure_transport_call_guild_help_result_s2c{result=Result},
	Term.

%%
decode_set_trade_money_c2s(Binary0)->
	{Moneytype, Binary1}=read_int32(Binary0),
	{Moneycount, Binary2}=read_int32(Binary1),
	Term = #set_trade_money_c2s{moneytype=Moneytype, moneycount=Moneycount},
	Term.

%%
decode_buy_mall_item_c2s(Binary0)->
	{Mitemid, Binary1}=read_int32(Binary0),
	{Count, Binary2}=read_int32(Binary1),
	{Price, Binary3}=decode_ip(Binary2),
	{Type, Binary4}=read_int32(Binary3),
	Term = #buy_mall_item_c2s{mitemid=Mitemid, count=Count, price=Price, type=Type},
	Term.

%%
decode_group_agree_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #group_agree_c2s{roleid=Roleid},
	Term.

%%
decode_add_black_s2c(Binary0)->
	{Blackinfo, Binary1}=decode_br(Binary0),
	Term = #add_black_s2c{blackinfo=Blackinfo},
	Term.

%%
decode_instance_info_s2c(Binary0)->
	{Protoid, Binary1}=read_int32(Binary0),
	{Times, Binary2}=read_int32(Binary1),
	{Left_time, Binary3}=read_int32(Binary2),
	Term = #instance_info_s2c{protoid=Protoid, times=Times, left_time=Left_time},
	Term.

%%
decode_end_block_training_c2s(Binary0)->
	Term = #end_block_training_c2s{},
	Term.

%%
decode_rank_fighting_force_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rk/1),
	Term = #rank_fighting_force_s2c{param=Param},
	Term.

%%
decode_dragon_fight_state_s2c(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Faction, Binary2}=read_int32(Binary1),
	{State, Binary3}=read_int32(Binary2),
	Term = #dragon_fight_state_s2c{npcid=Npcid, faction=Faction, state=State},
	Term.

%%
decode_loot_s2c(Binary0)->
	{Packetid, Binary1}=read_int32(Binary0),
	{Npcid, Binary2}=read_int64(Binary1),
	{Posx, Binary3}=read_int32(Binary2),
	{Posy, Binary4}=read_int32(Binary3),
	Term = #loot_s2c{packetid=Packetid, npcid=Npcid, posx=Posx, posy=Posy},
	Term.

%%
decode_guild_member_pos_s2c(Binary0)->
	{Posinfo, Binary1}=decode_list(Binary0, fun decode_gmp/1),
	Term = #guild_member_pos_s2c{posinfo=Posinfo},
	Term.

%%
decode_explore_storage_init_end_s2c(Binary0)->
	Term = #explore_storage_init_end_s2c{},
	Term.

%%
decode_stalls_search_s2c(Binary0)->
	{Index, Binary1}=read_int32(Binary0),
	{Totalnum, Binary2}=read_int32(Binary1),
	{Stalls, Binary3}=decode_list(Binary2, fun decode_a/1),
	Term = #stalls_search_s2c{index=Index, totalnum=Totalnum, stalls=Stalls},
	Term.

%%
decode_chess_spirit_cast_skill_c2s(Binary0)->
	{Skillid, Binary1}=read_int32(Binary0),
	Term = #chess_spirit_cast_skill_c2s{skillid=Skillid},
	Term.

%%
decode_honor_stores_buy_items_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Itemid, Binary2}=read_int32(Binary1),
	{Count, Binary3}=read_int32(Binary2),
	Term = #honor_stores_buy_items_c2s{type=Type, itemid=Itemid, count=Count},
	Term.

%%
decode_arrange_items_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #arrange_items_c2s{type=Type},
	Term.

%%
decode_server_treasure_transport_start_s2c(Binary0)->
	{Left_time, Binary1}=read_int32(Binary0),
	Term = #server_treasure_transport_start_s2c{left_time=Left_time},
	Term.


%%
decode_venation_shareexp_update_s2c(Binary0)->
	{Remaintime, Binary1}=read_int32(Binary0),
	{Totalexp, Binary2}=read_int64(Binary1),
	Term = #venation_shareexp_update_s2c{remaintime=Remaintime, totalexp=Totalexp},
	Term.

%%
decode_update_pet_skill_slot_s2c(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=decode_psll(Binary1),
	Term = #update_pet_skill_slot_s2c{petid=Petid, slot=Slot},
	Term.

%%
decode_group_accept_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #group_accept_c2s{roleid=Roleid},
	Term.

%%
decode_recruite_query_s2c(Binary0)->
	{Instance, Binary1}=read_int32(Binary0),
	{Rec_infos, Binary2}=decode_list(Binary1, fun decode_ri/1),
	{Role_rec_infos, Binary3}=decode_list(Binary2, fun decode_rr/1),
	{Usedtimes, Binary4}=read_int32(Binary3),
	{Isaddtime, Binary5}=read_int32(Binary4),
	{Lefttime, Binary6}=read_int32(Binary5),
	Term = #recruite_query_s2c{instance=Instance, rec_infos=Rec_infos, role_rec_infos=Role_rec_infos, usedtimes=Usedtimes, isaddtime=Isaddtime, lefttime=Lefttime},
	Term.

%%
decode_rank_talent_score_s2c(Binary0)->
	{Param, Binary1}=decode_list(Binary0, fun decode_rp/1),
	Term = #rank_talent_score_s2c{param=Param},
	Term.

%%
decode_end_block_training_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #end_block_training_s2c{roleid=Roleid},
	Term.

%%
decode_npc_storage_items_s2c(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Item_attrs, Binary2}=decode_list(Binary1, fun decode_i/1),
	Term = #npc_storage_items_s2c{npcid=Npcid, item_attrs=Item_attrs},
	Term.

%%
decode_init_signature_s2c(Binary0)->
	{Signature, Binary1}=read_string(Binary0),
	Term = #init_signature_s2c{signature=Signature},
	Term.

%%
decode_explore_storage_getitem_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Itemsign, Binary2}=read_int32(Binary1),
	Term = #explore_storage_getitem_c2s{slot=Slot, itemsign=Itemsign},
	Term.

%%
decode_goals_init_c2s(Binary0)->
	Term = #goals_init_c2s{},
	Term.

%%
decode_inspect_faild_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #inspect_faild_s2c{errno=Errno},
	Term.

%%
decode_country_change_crime_c2s(Binary0)->
	{Name, Binary1}=read_string(Binary0),
	{Type, Binary2}=read_int32(Binary1),
	Term = #country_change_crime_c2s{name=Name, type=Type},
	Term.

%%
decode_facebook_bind_check_result_s2c(Binary0)->
	{Fbid, Binary1}=read_string(Binary0),
	Term = #facebook_bind_check_result_s2c{fbid=Fbid},
	Term.

%%
decode_battle_leave_c2s(Binary0)->
	Term = #battle_leave_c2s{},
	Term.

%%
decode_yhzq_battle_self_join_s2c(Binary0)->
	{Redroles, Binary1}=decode_list(Binary0, fun decode_tr/1),
	{Blueroles, Binary2}=decode_list(Binary1, fun decode_tr/1),
	{Battleid, Binary3}=read_int32(Binary2),
	{Lefttime, Binary4}=read_int32(Binary3),
	Term = #yhzq_battle_self_join_s2c{redroles=Redroles, blueroles=Blueroles, battleid=Battleid, lefttime=Lefttime},
	Term.

%%
decode_loop_tower_enter_s2c(Binary0)->
	{Layer, Binary1}=read_int32(Binary0),
	{Trans, Binary2}=read_int32(Binary1),
	Term = #loop_tower_enter_s2c{layer=Layer, trans=Trans},
	Term.

%%
decode_guild_shop_buy_item_c2s(Binary0)->
	{Shoptype, Binary1}=read_int32(Binary0),
	{Id, Binary2}=read_int32(Binary1),
	{Itemid, Binary3}=read_int32(Binary2),
	{Count, Binary4}=read_int32(Binary3),
	Term = #guild_shop_buy_item_c2s{shoptype=Shoptype, id=Id, itemid=Itemid, count=Count},
	Term.

%%
decode_monster_section_update_s2c(Binary0)->
	{Mapid, Binary1}=read_int32(Binary0),
	{Section, Binary2}=read_int32(Binary1),
	Term = #monster_section_update_s2c{mapid=Mapid, section=Section},
	Term.

%%
decode_server_treasure_transport_end_s2c(Binary0)->
	Term = #server_treasure_transport_end_s2c{},
	Term.

%%
decode_rank_mail_line_s2c(Binary0)->
	{Chapter, Binary1}=read_int32(Binary0),
	{Festival, Binary2}=read_int32(Binary1),
	{Difficulty, Binary3}=read_int32(Binary2),
	{Param, Binary4}=decode_list(Binary3, fun decode_rk/1),
	Term = #rank_mail_line_s2c{chapter=Chapter, festival=Festival, difficulty=Difficulty, param=Param},
	Term.

%%
decode_lottery_lefttime_s2c(Binary0)->
	{Leftseconds, Binary1}=read_int32(Binary0),
	Term = #lottery_lefttime_s2c{leftseconds=Leftseconds},
	Term.

%%
decode_loot_query_c2s(Binary0)->
	{Packetid, Binary1}=read_int32(Binary0),
	Term = #loot_query_c2s{packetid=Packetid},
	Term.

%%
decode_country_leader_online_s2c(Binary0)->
	{Post, Binary1}=read_int32(Binary0),
	{Postindex, Binary2}=read_int32(Binary1),
	{Name, Binary3}=read_string(Binary2),
	Term = #country_leader_online_s2c{post=Post, postindex=Postindex, name=Name},
	Term.

%%
decode_set_trade_item_c2s(Binary0)->
	{Trade_slot, Binary1}=read_int32(Binary0),
	{Package_slot, Binary2}=read_int32(Binary1),
	Term = #set_trade_item_c2s{trade_slot=Trade_slot, package_slot=Package_slot},
	Term.

%%
decode_guild_mastercall_s2c(Binary0)->
	{Posting, Binary1}=read_int32(Binary0),
	{Name, Binary2}=read_string(Binary1),
	{Lineid, Binary3}=read_int32(Binary2),
	{Mapid, Binary4}=read_int32(Binary3),
	{Posx, Binary5}=read_int32(Binary4),
	{Posy, Binary6}=read_int32(Binary5),
	{Reasonid, Binary7}=read_int32(Binary6),
	Term = #guild_mastercall_s2c{posting=Posting, name=Name, lineid=Lineid, mapid=Mapid, posx=Posx, posy=Posy, reasonid=Reasonid},
	Term.

%%
decode_block_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Time, Binary2}=read_int32(Binary1),
	Term = #block_s2c{type=Type, time=Time},
	Term.

%%
decode_other_login_s2c(Binary0)->
	Term = #other_login_s2c{},
	Term.

%%
decode_enum_exchange_item_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	Term = #enum_exchange_item_c2s{npcid=Npcid},
	Term.

%%
decode_publish_guild_quest_c2s(Binary0)->
	Term = #publish_guild_quest_c2s{},
	Term.

%%
decode_explore_storage_getallitems_c2s(Binary0)->
	Term = #explore_storage_getallitems_c2s{},
	Term.

%%
decode_item_identify_opt_result_s2c(Binary0)->
	{Itemtmpid, Binary1}=read_int32(Binary0),
	Term = #item_identify_opt_result_s2c{itemtmpid=Itemtmpid},
	Term.

%%
decode_role_treasure_transport_time_check_c2s(Binary0)->
	Term = #role_treasure_transport_time_check_c2s{},
	Term.

%%
decode_lottery_leftcount_s2c(Binary0)->
	{Leftcount, Binary1}=read_int32(Binary0),
	Term = #lottery_leftcount_s2c{leftcount=Leftcount},
	Term.

%%
decode_yhzq_battle_other_join_s2c(Binary0)->
	{Role, Binary1}=decode_tr(Binary0),
	{Camp, Binary2}=read_int32(Binary1),
	Term = #yhzq_battle_other_join_s2c{role=Role, camp=Camp},
	Term.

%%
decode_role_rename_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Newname, Binary2}=read_string(Binary1),
	Term = #role_rename_c2s{slot=Slot, newname=Newname},
	Term.

%%
decode_group_decline_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #group_decline_c2s{roleid=Roleid},
	Term.

%%
decode_explore_storage_updateitem_s2c(Binary0)->
	{Itemlist, Binary1}=decode_list(Binary0, fun decode_tsi/1),
	Term = #explore_storage_updateitem_s2c{itemlist=Itemlist},
	Term.

%%
decode_venation_active_point_start_c2s(Binary0)->
	{Venation, Binary1}=read_int32(Binary0),
	{Point, Binary2}=read_int32(Binary1),
	{Itemnum, Binary3}=read_int32(Binary2),
	Term = #venation_active_point_start_c2s{venation=Venation, point=Point, itemnum=Itemnum},
	Term.

%%
decode_inspect_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Rolename, Binary2}=read_string(Binary1),
	{Classtype, Binary3}=read_int32(Binary2),
	{Gender, Binary4}=read_int32(Binary3),
	{Guildname, Binary5}=read_string(Binary4),
	{Level, Binary6}=read_int32(Binary5),
	{Cloth, Binary7}=read_int32(Binary6),
	{Arm, Binary8}=read_int32(Binary7),
	{Maxhp, Binary9}=read_int32(Binary8),
	{Maxmp, Binary10}=read_int32(Binary9),
	{Power, Binary11}=read_int32(Binary10),
	{Magic_defense, Binary12}=read_int32(Binary11),
	{Range_defense, Binary13}=read_int32(Binary12),
	{Melee_defense, Binary14}=read_int32(Binary13),
	{Stamina, Binary15}=read_int32(Binary14),
	{Strength, Binary16}=read_int32(Binary15),
	{Intelligence, Binary17}=read_int32(Binary16),
	{Agile, Binary18}=read_int32(Binary17),
	{Hitrate, Binary19}=read_int32(Binary18),
	{Criticalrate, Binary20}=read_int32(Binary19),
	{Criticaldamage, Binary21}=read_int32(Binary20),
	{Dodge, Binary22}=read_int32(Binary21),
	{Toughness, Binary23}=read_int32(Binary22),
	{Meleeimmunity, Binary24}=read_int32(Binary23),
	{Rangeimmunity, Binary25}=read_int32(Binary24),
	{Magicimmunity, Binary26}=read_int32(Binary25),
	{Imprisonment_resist, Binary27}=read_int32(Binary26),
	{Silence_resist, Binary28}=read_int32(Binary27),
	{Daze_resist, Binary29}=read_int32(Binary28),
	{Poison_resist, Binary30}=read_int32(Binary29),
	{Normal_resist, Binary31}=read_int32(Binary30),
	{Vip_tag, Binary32}=read_int32(Binary31),
	{Items_attr, Binary33}=decode_list(Binary32, fun decode_i/1),
	{Guildpost, Binary34}=read_int32(Binary33),
	{Exp, Binary35}=read_int64(Binary34),
	{Levelupexp, Binary36}=read_int64(Binary35),
	{Soulpower, Binary37}=read_int32(Binary36),
	{Maxsoulpower, Binary38}=read_int32(Binary37),
	{Guildlid, Binary39}=read_int32(Binary38),
	{Guildhid, Binary40}=read_int32(Binary39),
	{Cur_designation, Binary41}=read_int32_list(Binary40),
	{Role_crime, Binary42}=read_int32(Binary41),
	{Fighting_force, Binary43}=read_int32(Binary42),
	{Curhp, Binary44}=read_int32(Binary43),
	{Curmp, Binary45}=read_int32(Binary44),
	Term = #inspect_s2c{roleid=Roleid, rolename=Rolename, classtype=Classtype, gender=Gender, guildname=Guildname, level=Level, cloth=Cloth, arm=Arm, maxhp=Maxhp, maxmp=Maxmp, power=Power, magic_defense=Magic_defense, range_defense=Range_defense, melee_defense=Melee_defense, stamina=Stamina, strength=Strength, intelligence=Intelligence, agile=Agile, hitrate=Hitrate, criticalrate=Criticalrate, criticaldamage=Criticaldamage, dodge=Dodge, toughness=Toughness, meleeimmunity=Meleeimmunity, rangeimmunity=Rangeimmunity, magicimmunity=Magicimmunity, imprisonment_resist=Imprisonment_resist, silence_resist=Silence_resist, daze_resist=Daze_resist, poison_resist=Poison_resist, normal_resist=Normal_resist, vip_tag=Vip_tag, items_attr=Items_attr, guildpost=Guildpost, exp=Exp, levelupexp=Levelupexp, soulpower=Soulpower, maxsoulpower=Maxsoulpower, guildlid=Guildlid, guildhid=Guildhid, cur_designation=Cur_designation, role_crime=Role_crime, fighting_force=Fighting_force, curhp=Curhp, curmp=Curmp},
	Term.

%%
decode_guild_battle_score_update_s2c(Binary0)->
	{Index, Binary1}=read_int32(Binary0),
	{Score, Binary2}=read_int32(Binary1),
	Term = #guild_battle_score_update_s2c{index=Index, score=Score},
	Term.

%%
decode_role_respawn_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #role_respawn_c2s{type=Type},
	Term.

%%
decode_guild_battle_status_update_s2c(Binary0)->
	{State, Binary1}=read_int32(Binary0),
	{Lefttime, Binary2}=read_int32(Binary1),
	{Guildindex, Binary3}=read_int32(Binary2),
	{Roleid, Binary4}=read_int64(Binary3),
	{Rolename, Binary5}=read_string(Binary4),
	{Roleclass, Binary6}=read_int32(Binary5),
	{Rolegender, Binary7}=read_int32(Binary6),
	Term = #guild_battle_status_update_s2c{state=State, lefttime=Lefttime, guildindex=Guildindex, roleid=Roleid, rolename=Rolename, roleclass=Roleclass, rolegender=Rolegender},
	Term.

%%
decode_enum_exchange_item_fail_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #enum_exchange_item_fail_s2c{reason=Reason},
	Term.

%%
decode_mainline_reward_c2s(Binary0)->
	{Chapter, Binary1}=read_int32(Binary0),
	{Stage, Binary2}=read_int32(Binary1),
	{Reward, Binary3}=read_int32(Binary2),
	Term = #mainline_reward_c2s{chapter=Chapter, stage=Stage, reward=Reward},
	Term.

%%
decode_questgiver_accept_quest_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Questid, Binary2}=read_int32(Binary1),
	Term = #questgiver_accept_quest_c2s{npcid=Npcid, questid=Questid},
	Term.

%%
decode_recruite_cancel_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #recruite_cancel_s2c{reason=Reason},
	Term.

%%
decode_add_friend_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #add_friend_failed_s2c{reason=Reason},
	Term.

%%
decode_spa_start_notice_s2c(Binary0)->
	{Level, Binary1}=read_int32(Binary0),
	Term = #spa_start_notice_s2c{level=Level},
	Term.

%%
decode_yhzq_battle_update_s2c(Binary0)->
	{Camp, Binary1}=read_int32(Binary0),
	{Role, Binary2}=decode_tr(Binary1),
	Term = #yhzq_battle_update_s2c{camp=Camp, role=Role},
	Term.

%%
decode_server_version_s2c(Binary0)->
	{V, Binary1}=read_string(Binary0),
	Term = #server_version_s2c{v=V},
	Term.

%%
decode_loot_response_s2c(Binary0)->
	{Packetid, Binary1}=read_int32(Binary0),
	{Slots, Binary2}=decode_list(Binary1, fun decode_l/1),
	Term = #loot_response_s2c{packetid=Packetid, slots=Slots},
	Term.

%%
decode_venation_active_point_opt_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #venation_active_point_opt_s2c{reason=Reason},
	Term.

%%
decode_stalls_search_item_s2c(Binary0)->
	{Index, Binary1}=read_int32(Binary0),
	{Totalnum, Binary2}=read_int32(Binary1),
	{Serchitems, Binary3}=decode_list(Binary2, fun decode_ssi/1),
	Term = #stalls_search_item_s2c{index=Index, totalnum=Totalnum, serchitems=Serchitems},
	Term.

%%
decode_explore_storage_additem_s2c(Binary0)->
	{Items, Binary1}=decode_list(Binary0, fun decode_tsi/1),
	Term = #explore_storage_additem_s2c{items=Items},
	Term.

%%
decode_chess_spirit_update_power_s2c(Binary0)->
	{Newpower, Binary1}=read_int32(Binary0),
	Term = #chess_spirit_update_power_s2c{newpower=Newpower},
	Term.

%%
decode_tangle_records_c2s(Binary0)->
	{Year, Binary1}=read_int32(Binary0),
	{Month, Binary2}=read_int32(Binary1),
	{Day, Binary3}=read_int32(Binary2),
	{Type, Binary4}=read_int32(Binary3),
	Term = #tangle_records_c2s{year=Year, month=Month, day=Day, type=Type},
	Term.

%%
decode_tangle_remove_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #tangle_remove_s2c{roleid=Roleid},
	Term.

%%
decode_group_kickout_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #group_kickout_c2s{roleid=Roleid},
	Term.

%%
decode_guild_rename_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Newname, Binary2}=read_string(Binary1),
	Term = #guild_rename_c2s{slot=Slot, newname=Newname},
	Term.

%%
decode_dragon_fight_num_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	Term = #dragon_fight_num_c2s{npcid=Npcid},
	Term.

%%
decode_update_guild_quest_info_s2c(Binary0)->
	{Lefttime, Binary1}=read_int32(Binary0),
	Term = #update_guild_quest_info_s2c{lefttime=Lefttime},
	Term.

%%
decode_role_recruite_c2s(Binary0)->
	{Instanceid, Binary1}=read_int32(Binary0),
	Term = #role_recruite_c2s{instanceid=Instanceid},
	Term.

%%
decode_mainline_reward_success_s2c(Binary0)->
	{Chapter, Binary1}=read_int32(Binary0),
	{Stage, Binary2}=read_int32(Binary1),
	Term = #mainline_reward_success_s2c{chapter=Chapter, stage=Stage},
	Term.

%%
decode_lottery_clickslot_c2s(Binary0)->
	{Clickslot, Binary1}=read_int32(Binary0),
	Term = #lottery_clickslot_c2s{clickslot=Clickslot},
	Term.

%%
decode_spa_request_spalist_c2s(Binary0)->
	Term = #spa_request_spalist_c2s{},
	Term.

%%
decode_change_country_notice_c2s(Binary0)->
	{Notice, Binary1}=read_string(Binary0),
	Term = #change_country_notice_c2s{notice=Notice},
	Term.

%%创建帮会10月18日修改
decode_guild_create_c2s(Binary0)->
	{Name, Binary1}=read_string(Binary0),
	{Notice, Binary2}=read_string(Binary1),
	{Type, Binary3}=read_int32(Binary2),
	Term = #guild_create_c2s{name=Name, notice=Notice, type=Type},
	Term.

%%
decode_venation_active_point_end_c2s(Binary0)->
	Term = #venation_active_point_end_c2s{},
	Term.

%%
decode_becare_friend_s2c(Binary0)->
	{Fn, Binary1}=read_string(Binary0),
	{Fid, Binary2}=read_int64(Binary1),
	Term = #becare_friend_s2c{fn=Fn, fid=Fid},
	Term.

%%
decode_quest_list_add_s2c(Binary0)->
	{Quest, Binary1}=decode_q(Binary0),
	Term = #quest_list_add_s2c{quest=Quest},
	Term.

%%
decode_explore_storage_delitem_s2c(Binary0)->
	{Start, Binary1}=read_int32(Binary0),
	{Length, Binary2}=read_int32(Binary1),
	Term = #explore_storage_delitem_s2c{start=Start, length=Length},
	Term.

%%
decode_yhzq_battle_remove_s2c(Binary0)->
	{Camp, Binary1}=read_int32(Binary0),
	{Roleid, Binary2}=read_int64(Binary1),
	Term = #yhzq_battle_remove_s2c{camp=Camp, roleid=Roleid},
	Term.

%%
decode_venation_advanced_start_c2s(Binary0)->
	{Venationid, Binary1}=read_int32(Binary0),
	{Bone, Binary2}=read_int32(Binary1),
	{Useitem, Binary3}=read_int32(Binary2),
	{Type, Binary4}=read_int32(Binary3),
	Term = #venation_advanced_start_c2s{venationid=Venationid, bone=Bone, useitem=Useitem, type=Type},
	Term.

%%
decode_guild_disband_c2s(Binary0)->
	Term = #guild_disband_c2s{},
	Term.


%%
decode_mainline_lefttime_s2c(Binary0)->
	{Chapter, Binary1}=read_int32(Binary0),
	{Stage, Binary2}=read_int32(Binary1),
	{Lefttime, Binary3}=read_int32(Binary2),
	Term = #mainline_lefttime_s2c{chapter=Chapter, stage=Stage, lefttime=Lefttime},
	Term.

%%
decode_role_recruite_cancel_c2s(Binary0)->
	Term = #role_recruite_cancel_c2s{},
	Term.

%%
decode_arrange_items_s2c(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Items, Binary2}=decode_list(Binary1, fun decode_ic/1),
	{Lowids, Binary3}=read_int32_list(Binary2),
	{Highids, Binary4}=read_int32_list(Binary3),
	Term = #arrange_items_s2c{type=Type, items=Items, lowids=Lowids, highids=Highids},
	Term.

%%
decode_stall_log_add_s2c(Binary0)->
	{Stallid, Binary1}=read_int64(Binary0),
	{Logs, Binary2}=read_string_list(Binary1),
	Term = #stall_log_add_s2c{stallid=Stallid, logs=Logs},
	Term.

%%
decode_rename_result_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #rename_result_s2c{errno=Errno},
	Term.

%%
decode_guild_member_invite_c2s(Binary0)->
	{Name, Binary1}=read_string(Binary0),
	Term = #guild_member_invite_c2s{name=Name},
	Term.

%%
decode_enum_exchange_item_s2c(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Dhs, Binary2}=decode_list(Binary1, fun decode_dh/1),
	Term = #enum_exchange_item_s2c{npcid=Npcid, dhs=Dhs},
	Term.

%%
decode_loot_pick_c2s(Binary0)->
	{Packetid, Binary1}=read_int32(Binary0),
	{Slot_num, Binary2}=read_int32(Binary1),
	Term = #loot_pick_c2s{packetid=Packetid, slot_num=Slot_num},
	Term.

%%
decode_quest_quit_c2s(Binary0)->
	{Questid, Binary1}=read_int32(Binary0),
	Term = #quest_quit_c2s{questid=Questid},
	Term.

%%
decode_pet_evolution_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Itemslot, Binary2}=read_int32(Binary1),
	Term = #pet_evolution_c2s{petid=Petid, itemslot=Itemslot},
	Term.

%%
decode_country_leader_get_itmes_c2s(Binary0)->
	Term = #country_leader_get_itmes_c2s{},
	Term.

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%帮会副本新加消息【xiaowu】
encode_get_guild_space_info_c2s(Term)->
	Data = <<>>,
	<<2270:16, Data/binary>>.
%%
decode_get_guild_space_info_c2s(Binary0)->
	Term = #get_guild_space_info_c2s{},
	Term.

%%
encode_get_guild_space_info_s2c(Term)->
	Data = <<>>,
	<<2426:16, Data/binary>>.


decode_open_guild_space_c2s(Binary0)->
	{Spaceid, Binary1}=read_int32(Binary0),
	Term = #open_guild_space_c2s{spaceid=Spaceid},
	Term.

encode_open_guild_space_c2s(Term)->
	Spaceid=Term#open_guild_space_c2s.spaceid,
	Data = <<Spaceid:32>>,
	<<2271:16, Data/binary>>.

encode_get_space_info_s2c(Term)->
	Spaceinfo=encode_list(Term#get_space_info_s2c.spaceinfo, fun encode_qmjx/1),
	Lefttimes=Term#get_space_info_s2c.lefttimes,
	Data = <<Spaceinfo/binary, Lefttimes:32>>,
	<<2276:16, Data/binary>>.

decode_get_space_info_s2c(Binary0)->
	{Spaceinfo, Binary1}=decode_list(Binary0, fun decode_qmjx/1),
	{Lefttimes, Binary2}=read_int32(Binary1),
	Term = #get_space_info_s2c{spaceinfo=Spaceinfo, lefttimes=Lefttimes},
	Term.

encode_qmjx(Term)->
	State=Term#qmjx.state,
	Spaceid=Term#qmjx.spaceid,
	Data = <<State:32, Spaceid:32>>,
	Data.

decode_qmjx(Binary0)->
	{State, Binary1}=read_int32(Binary0),
	{Spaceid, Binary2}=read_int32(Binary1),
	Term = #qmjx{state=State, spaceid=Spaceid},
	{Term, Binary2}.

%%发起召唤
encode_qunmojiuxian_vote_c2s(Term)->%%
	Spaceid=Term#qunmojiuxian_vote_c2s.spaceid,
	Data = <<Spaceid:32>>,
	<<2278:16, Data/binary>>.

%%发起召唤结果
encode_qunmojiuxian_vote_num_s2c(Term)->
	Num=Term#qunmojiuxian_vote_num_s2c.num,
	Data = <<Num:32>>,
	<<2274:16, Data/binary>>.
%%召唤通知
encode_qunmojiuxian_vote_s2c(Term)->
	Spaceid=Term#qunmojiuxian_vote_s2c.spaceid,
	Data = <<Spaceid:32>>,
	<<2275:16, Data/binary>>.

%%召唤通知
decode_qunmojiuxian_vote_s2c(Binary0)->
	{Spaceid, Binary1}=read_int32(Binary0),
	Term = #qunmojiuxian_vote_s2c{spaceid=Spaceid},
	Term.
%%相应召唤
encode_qunmojiuxian_accept_vote_c2s(Term)->
	Data = <<>>,
	<<2277:16, Data/binary>>.
%%相应召唤
decode_qunmojiuxian_accept_vote_c2s(Binary0)->
	Term = #qunmojiuxian_accept_vote_c2s{},
	Term.
%%开启空间
encode_start_qunmojiuxian_c2s(Term)->
	Spaceid=Term#start_qunmojiuxian_c2s.spaceid,
	Data = <<Spaceid:32>>,
	<<2272:16, Data/binary>>.

%%发起召唤
decode_qunmojiuxian_vote_c2s(Binary0)->
	{Spaceid, Binary1}=read_int32(Binary0),
	Term = #qunmojiuxian_vote_c2s{spaceid=Spaceid},
	Term.

%%发起召唤结果
decode_qunmojiuxian_vote_num_s2c(Binary0)->
	{Num, Binary1}=read_int32(Binary0),
	Term = #qunmojiuxian_vote_num_s2c{num=Num},
	Term.

%%开启空间
decode_start_qunmojiuxian_c2s(Binary0)->
	{Spaceid, Binary1}=read_int32(Binary0),
	Term = #start_qunmojiuxian_c2s{spaceid=Spaceid},
	Term.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
decode_role_recruite_cancel_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #role_recruite_cancel_s2c{reason=Reason},
	Term.

%%
decode_lottery_querystatus_c2s(Binary0)->
	Term = #lottery_querystatus_c2s{},
	Term.

%%
decode_tangle_records_s2c(Binary0)->
	{Year, Binary1}=read_int32(Binary0),
	{Month, Binary2}=read_int32(Binary1),
	{Day, Binary3}=read_int32(Binary2),
	{Type, Binary4}=read_int32(Binary3),
	{Totalbattle, Binary5}=read_int32(Binary4),
	{Mybattleid, Binary6}=read_int32_list(Binary5),
	Term = #tangle_records_s2c{year=Year, month=Month, day=Day, type=Type, totalbattle=Totalbattle, mybattleid=Mybattleid},
	Term.

%%
decode_lottery_clickslot_s2c(Binary0)->
	{Lottery_slot, Binary1}=read_int32(Binary0),
	{Item, Binary2}=decode_lti(Binary1),
	Term = #lottery_clickslot_s2c{lottery_slot=Lottery_slot, item=Item},
	Term.

%%
decode_questgiver_complete_quest_c2s(Binary0)->
	{Questid, Binary1}=read_int32(Binary0),
	{Npcid, Binary2}=read_int64(Binary1),
	{Choiceslot, Binary3}=read_int32(Binary2),
	Term = #questgiver_complete_quest_c2s{questid=Questid, npcid=Npcid, choiceslot=Choiceslot},
	Term.

%%
decode_designation_init_s2c(Binary0)->
	{Designationid, Binary1}=read_int32_list(Binary0),
	Term = #designation_init_s2c{designationid=Designationid},
	Term.

%%
decode_loot_remove_item_s2c(Binary0)->
	{Packetid, Binary1}=read_int32(Binary0),
	{Slot_num, Binary2}=read_int32(Binary1),
	Term = #loot_remove_item_s2c{packetid=Packetid, slot_num=Slot_num},
	Term.

%%
decode_add_signature_c2s(Binary0)->
	{Signature, Binary1}=read_string(Binary0),
	Term = #add_signature_c2s{signature=Signature},
	Term.

%%
decode_cancel_buff_c2s(Binary0)->
	{Buffid, Binary1}=read_int32(Binary0),
	Term = #cancel_buff_c2s{buffid=Buffid},
	Term.

%%
decode_goals_reward_c2s(Binary0)->
	{Days, Binary1}=read_int32(Binary0),
	{Part, Binary2}=read_int32(Binary1),
	Term = #goals_reward_c2s{days=Days, part=Part},
	Term.

%%
decode_guild_member_decline_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #guild_member_decline_c2s{roleid=Roleid},
	Term.

%%
decode_explore_storage_opt_s2c(Binary0)->
	{Code, Binary1}=read_int32(Binary0),
	Term = #explore_storage_opt_s2c{code=Code},
	Term.

%%
decode_dragon_fight_faction_s2c(Binary0)->
	{Newfaction, Binary1}=read_int32(Binary0),
	Term = #dragon_fight_faction_s2c{newfaction=Newfaction},
	Term.

%%
decode_cancel_trade_c2s(Binary0)->
	Term = #cancel_trade_c2s{},
	Term.

%%
decode_quest_statu_update_s2c(Binary0)->
	{Quests, Binary1}=decode_q(Binary0),
	Term = #quest_statu_update_s2c{quests=Quests},
	Term.

%%
decode_group_apply_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Username, Binary2}=read_string(Binary1),
	Term = #group_apply_s2c{roleid=Roleid, username=Username},
	Term.

%%
decode_exchange_item_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Item_clsid, Binary2}=read_int32(Binary1),
	{Count, Binary3}=read_int32(Binary2),
	{Slots, Binary4}=decode_list(Binary3, fun decode_l/1),
	Term = #exchange_item_c2s{npcid=Npcid, item_clsid=Item_clsid, count=Count, slots=Slots},
	Term.

%%
decode_group_setleader_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #group_setleader_c2s{roleid=Roleid},
	Term.

%%
decode_welfare_gold_exchange_init_c2s(Binary0)->
	Term = #welfare_gold_exchange_init_c2s{},
	Term.

%%
decode_pet_forget_skill_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	{Skillid, Binary3}=read_int32(Binary2),
	Term = #pet_forget_skill_c2s{petid=Petid, slot=Slot, skillid=Skillid},
	Term.

%%
decode_use_item_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #use_item_c2s{slot=Slot},
	Term.

%%
decode_stall_opt_result_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #stall_opt_result_s2c{errno=Errno},
	Term.

%%
decode_feedback_info_ret_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #feedback_info_ret_s2c{reason=Reason},
	Term.

%%
decode_buy_honor_item_error_s2c(Binary0)->
	{Error, Binary1}=read_int32(Binary0),
	Term = #buy_honor_item_error_s2c{error=Error},
	Term.

%%
decode_venation_advanced_opt_result_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	{Bone, Binary2}=read_int32(Binary1),
	Term = #venation_advanced_opt_result_s2c{result=Result, bone=Bone},
	Term.

%%
decode_instance_leader_join_s2c(Binary0)->
	{Instanceid, Binary1}=read_int32(Binary0),
	Term = #instance_leader_join_s2c{instanceid=Instanceid},
	Term.

%%
decode_pet_explore_info_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	Term = #pet_explore_info_c2s{petid=Petid},
	Term.

%%
decode_spa_request_spalist_s2c(Binary0)->
	{Spas, Binary1}=decode_list(Binary0, fun decode_spa/1),
	Term = #spa_request_spalist_s2c{spas=Spas},
	Term.

%%
decode_guild_member_accept_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #guild_member_accept_c2s{roleid=Roleid},
	Term.

%%
decode_yhzq_zone_info_s2c(Binary0)->
	{Zonelist, Binary1}=decode_list(Binary0, fun decode_zoneinfo/1),
	Term = #yhzq_zone_info_s2c{zonelist=Zonelist},
	Term.

%%
decode_get_friend_signature_c2s(Binary0)->
	{Fn, Binary1}=read_string(Binary0),
	Term = #get_friend_signature_c2s{fn=Fn},
	Term.

%%
decode_loot_release_s2c(Binary0)->
	{Packetid, Binary1}=read_int32(Binary0),
	Term = #loot_release_s2c{packetid=Packetid},
	Term.

%%
decode_lottery_clickslot_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #lottery_clickslot_failed_s2c{reason=Reason},
	Term.

%%
decode_designation_update_s2c(Binary0)->
	{Designationid, Binary1}=read_int32_list(Binary0),
	Term = #designation_update_s2c{designationid=Designationid},
	Term.

%%
decode_update_guild_apply_state_s2c(Binary0)->
	{Guildlid, Binary1}=read_int32(Binary0),
	{Guildhid, Binary2}=read_int32(Binary1),
	{Applyflag, Binary3}=read_int32(Binary2),
	Term = #update_guild_apply_state_s2c{guildlid=Guildlid, guildhid=Guildhid, applyflag=Applyflag},
	Term.

%%
decode_gift_card_apply_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #gift_card_apply_s2c{errno=Errno},
	Term.

%%
decode_guild_shop_update_item_s2c(Binary0)->
	{Shoptype, Binary1}=read_int32(Binary0),
	{Item, Binary2}=decode_gsi(Binary1),
	Term = #guild_shop_update_item_s2c{shoptype=Shoptype, item=Item},
	Term.

%%
decode_auto_equip_item_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #auto_equip_item_c2s{slot=Slot},
	Term.

%%
decode_mainline_remain_monsters_info_s2c(Binary0)->
	{Kill_num, Binary1}=read_int32(Binary0),
	{Remain_num, Binary2}=read_int32(Binary1),
	{Chapter, Binary3}=read_int32(Binary2),
	{Stage, Binary4}=read_int32(Binary3),
	Term = #mainline_remain_monsters_info_s2c{kill_num=Kill_num, remain_num=Remain_num, chapter=Chapter, stage=Stage},
	Term.


%%
decode_mainline_timeout_c2s(Binary0)->
	{Chapter, Binary1}=read_int32(Binary0),
	{Stage, Binary2}=read_int32(Binary1),
	Term = #mainline_timeout_c2s{chapter=Chapter, stage=Stage},
	Term.

%%
decode_inspect_designation_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Designationid, Binary2}=read_int32_list(Binary1),
	Term = #inspect_designation_s2c{roleid=Roleid, designationid=Designationid},
	Term.

%%
decode_instance_leader_join_c2s(Binary0)->
	Term = #instance_leader_join_c2s{},
	Term.

%%
decode_item_identify_error_s2c(Binary0)->
	{Error, Binary1}=read_int32(Binary0),
	Term = #item_identify_error_s2c{error=Error},
	Term.

%%
decode_guild_member_apply_c2s(Binary0)->
	{Guildlid, Binary1}=read_int32(Binary0),
	{Guildhid, Binary2}=read_int32(Binary1),
	Term = #guild_member_apply_c2s{guildlid=Guildlid, guildhid=Guildhid},
	Term.

%%
decode_lottery_otherslot_s2c(Binary0)->
	{Items, Binary1}=decode_list(Binary0, fun decode_lti/1),
	Term = #lottery_otherslot_s2c{items=Items},
	Term.

%%
decode_pet_explore_info_s2c(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Remaintimes, Binary2}=read_int32(Binary1),
	{Siteid, Binary3}=read_int32(Binary2),
	{Explorestyle, Binary4}=read_int32(Binary3),
	{Lefttime, Binary5}=read_int32(Binary4),
	Term = #pet_explore_info_s2c{petid=Petid, remaintimes=Remaintimes, siteid=Siteid, explorestyle=Explorestyle, lefttime=Lefttime},
	Term.

%%
decode_pet_up_growth_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	{Next, Binary2}=read_int32(Binary1),
	Term = #pet_up_growth_s2c{result=Result, next=Next},
	Term.

%%
decode_venation_advanced_update_s2c(Binary0)->
	{Attr, Binary1}=decode_list(Binary0, fun decode_k/1),
	Term = #venation_advanced_update_s2c{attr=Attr},
	Term.

%%
decode_group_disband_c2s(Binary0)->
	Term = #group_disband_c2s{},
	Term.

%%
%decode_pet_upgrade_quality_c2s(Binary0)->
%	{Petid, Binary1}=read_int64(Binary0),
%	{Needs, Binary2}=read_int32(Binary1),
%	{Protect, Binary3}=read_int32(Binary2),
%	Term = #pet_upgrade_quality_c2s{petid=Petid, needs=Needs, protect=Protect},
%	Term.

%%
decode_guild_log_normal_s2c(Binary0)->
	{Logs, Binary1}=decode_list(Binary0, fun decode_guildlog/1),
	Term = #guild_log_normal_s2c{logs=Logs},
	Term.

%%
decode_exchange_item_fail_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #exchange_item_fail_s2c{reason=Reason},
	Term.

%%
decode_hp_package_s2c(Binary0)->
	{Itemidl, Binary1}=read_int32(Binary0),
	{Itemidh, Binary2}=read_int32(Binary1),
	{Buffid, Binary3}=read_int32(Binary2),
	Term = #hp_package_s2c{itemidl=Itemidl, itemidh=Itemidh, buffid=Buffid},
	Term.

%%
decode_tangle_more_records_c2s(Binary0)->
	{Year, Binary1}=read_int32(Binary0),
	{Month, Binary2}=read_int32(Binary1),
	{Day, Binary3}=read_int32(Binary2),
	{Type, Binary4}=read_int32(Binary3),
	{Battleid, Binary5}=read_int32(Binary4),
	Term = #tangle_more_records_c2s{year=Year, month=Month, day=Day, type=Type, battleid=Battleid},
	Term.

%%
decode_trade_role_lock_c2s(Binary0)->
	Term = #trade_role_lock_c2s{},
	Term.

%%
decode_get_friend_signature_s2c(Binary0)->
	{Signature, Binary1}=read_string(Binary0),
	Term = #get_friend_signature_s2c{signature=Signature},
	Term.

%%
decode_everyday_show_s2c(Binary0)->
	Term = #everyday_show_s2c{},
	Term.

%%
decode_dragon_fight_faction_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	Term = #dragon_fight_faction_c2s{npcid=Npcid},
	Term.

%%
decode_change_item_failed_s2c(Binary0)->
	{Itemid_low, Binary1}=read_int32(Binary0),
	{Itemid_high, Binary2}=read_int32(Binary1),
	{Errno, Binary3}=read_int32(Binary2),
	Term = #change_item_failed_s2c{itemid_low=Itemid_low, itemid_high=Itemid_high, errno=Errno},
	Term.

%%
decode_country_leader_ever_reward_c2s(Binary0)->
	Term = #country_leader_ever_reward_c2s{},
	Term.

%%
decode_guild_battle_start_s2c(Binary0)->
	Term = #guild_battle_start_s2c{},
	Term.

%%
decode_ride_opt_c2s(Binary0)->
	{Opcode, Binary1}=read_int32(Binary0),
	Term = #ride_opt_c2s{opcode=Opcode},
	Term.

%%
decode_npc_map_change_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Id, Binary2}=read_int32(Binary1),
	Term = #npc_map_change_c2s{npcid=Npcid, id=Id},
	Term.

%%
decode_delete_friend_c2s(Binary0)->
	{Fn, Binary1}=read_string(Binary0),
	Term = #delete_friend_c2s{fn=Fn},
	Term.

%%
decode_lottery_notic_s2c(Binary0)->
	{Rolename, Binary1}=read_string(Binary0),
	{Item, Binary2}=decode_lti(Binary1),
	Term = #lottery_notic_s2c{rolename=Rolename, item=Item},
	Term.

%%
decode_venation_opt_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	{Roleid, Binary2}=read_int64(Binary1),
	Term = #venation_opt_s2c{reason=Reason, roleid=Roleid},
	Term.

%%副本元宝委托
decode_instance_entrust_c2s(Binary0)->
	{Instance_id, Binary1}=read_int32(Binary0),
	{Times, Binary2}=read_int32(Binary1),
	Term = #instance_entrust_c2s{instance_id=Instance_id, times=Times},
	Term.

%%
decode_loop_tower_challenge_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #loop_tower_challenge_c2s{type=Type},
	Term.

%%
decode_guild_member_depart_c2s(Binary0)->
	Term = #guild_member_depart_c2s{},
	Term.

%%
decode_instance_end_seconds_s2c(Binary0)->
	{Kicktime_s, Binary1}=read_int32(Binary0),
	Term = #instance_end_seconds_s2c{kicktime_s=Kicktime_s},
	Term.

%%
decode_ride_opt_result_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #ride_opt_result_s2c{errno=Errno},
	Term.

%%
decode_npc_storage_items_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	Term = #npc_storage_items_c2s{npcid=Npcid},
	Term.

%%
decode_chess_spirit_skill_levelup_c2s(Binary0)->
	{Skillid, Binary1}=read_int32(Binary0),
	Term = #chess_spirit_skill_levelup_c2s{skillid=Skillid},
	Term.

%%
decode_gift_card_state_s2c(Binary0)->
	{Weburl, Binary1}=read_string(Binary0),
	{State, Binary2}=read_int32(Binary1),
	Term = #gift_card_state_s2c{weburl=Weburl, state=State},
	Term.

%%
decode_map_change_failed_s2c(Binary0)->
	{Reasonid, Binary1}=read_int32(Binary0),
	Term = #map_change_failed_s2c{reasonid=Reasonid},
	Term.

%%
decode_gift_card_apply_c2s(Binary0)->
	{Key, Binary1}=read_string(Binary0),
	Term = #gift_card_apply_c2s{key=Key},
	Term.

%%
decode_guild_member_kickout_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #guild_member_kickout_c2s{roleid=Roleid},
	Term.

%%
decode_delete_friend_success_s2c(Binary0)->
	{Fn, Type,Binary1}=read_string(Binary0),
	Term = #delete_friend_success_s2c{fn=Fn,type=Type},%%@@wb
	Term.

%%
decode_group_depart_c2s(Binary0)->
	Term = #group_depart_c2s{},
	Term.

%%
decode_venation_time_countdown_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Time, Binary2}=read_int32(Binary1),
	Term = #venation_time_countdown_s2c{roleid=Roleid, time=Time},
	Term.

%%
decode_mainline_init_c2s(Binary0)->
	Term = #mainline_init_c2s{},
	Term.

%%
decode_pet_learn_skill_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	Term = #pet_learn_skill_c2s{petid=Petid, slot=Slot},
	Term.

%%
decode_use_item_error_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #use_item_error_s2c{errno=Errno},
	Term.

%%
decode_timelimit_gift_info_s2c(Binary0)->
	{Nextindex, Binary1}=read_int32(Binary0),
	{Nexttime, Binary2}=read_int32(Binary1),
	{Itmes, Binary3}=decode_list(Binary2, fun decode_lti/1),
	Term = #timelimit_gift_info_s2c{nextindex=Nextindex, nexttime=Nexttime, itmes=Itmes},
	Term.

%%
decode_instance_exit_c2s(Binary0)->
	Term = #instance_exit_c2s{},
	Term.

%%
decode_entry_guild_battle_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	{Lefttime, Binary2}=read_int32(Binary1),
	Term = #entry_guild_battle_s2c{result=Result, lefttime=Lefttime},
	Term.

%%
decode_pet_explore_start_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Explorestyle, Binary2}=read_int32(Binary1),
	{Siteid, Binary3}=read_int32(Binary2),
	{Lucky, Binary4}=read_int32(Binary3),
	Term = #pet_explore_start_c2s{petid=Petid, explorestyle=Explorestyle, siteid=Siteid, lucky=Lucky},
	Term.

%%
decode_tangle_more_records_s2c(Binary0)->
	{Trs, Binary1}=decode_list(Binary0, fun decode_tr/1),
	{Year, Binary2}=read_int32(Binary1),
	{Month, Binary3}=read_int32(Binary2),
	{Day, Binary4}=read_int32(Binary3),
	{Type, Binary5}=read_int32(Binary4),
	{Myrank, Binary6}=read_int32(Binary5),
	{Battleid, Binary7}=read_int32(Binary6),
	{Has_reward, Binary8}=read_int32(Binary7),
	Term = #tangle_more_records_s2c{trs=Trs, year=Year, month=Month, day=Day, type=Type, myrank=Myrank, battleid=Battleid, has_reward=Has_reward},
	Term.

%%
decode_yhzq_battle_player_pos_s2c(Binary0)->
	{Players, Binary1}=decode_list(Binary0, fun decode_tp/1),
	Term = #yhzq_battle_player_pos_s2c{players=Players},
	Term.

%%
decode_dragon_fight_num_s2c(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Faction, Binary2}=read_int32(Binary1),
	{Num, Binary3}=read_int32(Binary2),
	Term = #dragon_fight_num_s2c{npcid=Npcid, faction=Faction, num=Num},
	Term.

%%
decode_pet_item_opt_result_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #pet_item_opt_result_s2c{errno=Errno},
	Term.

%%
decode_npc_fucnction_common_error_s2c(Binary0)->
	{Reasonid, Binary1}=read_int32(Binary0),
	Term = #npc_fucnction_common_error_s2c{reasonid=Reasonid},
	Term.

%%
decode_guild_set_leader_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #guild_set_leader_c2s{roleid=Roleid},
	Term.

%%
decode_update_guild_update_apply_info_s2c(Binary0)->
	{Role, Binary1}=decode_g(Binary0),
	{Type, Binary2}=read_int32(Binary1),
	Term = #update_guild_update_apply_info_s2c{role=Role, type=Type},
	Term.

%%
decode_battle_end_s2c(Binary0)->
	{Exp, Binary1}=read_int64(Binary0),
	{Honor, Binary2}=read_int32(Binary1),
	Term = #battle_end_s2c{exp=Exp, honor=Honor},
	Term.

%%
decode_mail_status_query_c2s(Binary0)->
	Term = #mail_status_query_c2s{},
	Term.

%%
decode_yhzq_battle_end_s2c(Binary0)->
	Term = #yhzq_battle_end_s2c{},
	Term.

%%
decode_treasure_buffer_s2c(Binary0)->
	{Buffs, Binary1}=decode_list(Binary0, fun decode_bf/1),
	Term = #treasure_buffer_s2c{buffs=Buffs},
	Term.

%%
decode_group_invite_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Username, Binary2}=read_string(Binary1),
	Term = #group_invite_s2c{roleid=Roleid, username=Username},
	Term.

%%
decode_init_random_rolename_s2c(Binary0)->
	{Bn, Binary1}=read_string(Binary0),
	{Gn, Binary2}=read_string(Binary1),
	Term = #init_random_rolename_s2c{bn=Bn, gn=Gn},
	Term.

%%
decode_mainline_kill_monsters_info_s2c(Binary0)->
	{Npcprotoid, Binary1}=read_int32(Binary0),
	{Neednum, Binary2}=read_int32(Binary1),
	{Chapter, Binary3}=read_int32(Binary2),
	{Stage, Binary4}=read_int32(Binary3),
	Term = #mainline_kill_monsters_info_s2c{npcprotoid=Npcprotoid, neednum=Neednum, chapter=Chapter, stage=Stage},
	Term.

%%
decode_entry_loop_instance_apply_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #entry_loop_instance_apply_c2s{type=Type},
	Term.

%%
decode_timelimit_gift_error_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #timelimit_gift_error_s2c{reason=Reason},
	Term.

%%
decode_guild_get_treasure_item_c2s(Binary0)->
	{Treasuretype, Binary1}=read_int32(Binary0),
	Term = #guild_get_treasure_item_c2s{treasuretype=Treasuretype},
	Term.

%%
decode_buff_immune_s2c(Binary0)->
	{Enemyid, Binary1}=read_int64(Binary0),
	{Immune_buffs, Binary2}=decode_list(Binary1, fun decode_mf/1),
	{Flytime, Binary3}=read_int32(Binary2),
	Term = #buff_immune_s2c{enemyid=Enemyid, immune_buffs=Immune_buffs, flytime=Flytime},
	Term.

%%
decode_equip_item_for_pet_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	Term = #equip_item_for_pet_c2s{petid=Petid, slot=Slot},
	Term.

%%
decode_server_travel_tag_s2c(Binary0)->
	{Istravel, Binary1}=read_int32(Binary0),
	Term = #server_travel_tag_s2c{istravel=Istravel},
	Term.

%%
decode_welfare_gold_exchange_init_s2c(Binary0)->
	{Consume_gold, Binary1}=read_int32(Binary0),
	Term = #welfare_gold_exchange_init_s2c{consume_gold=Consume_gold},
	Term.

%%
decode_quest_complete_s2c(Binary0)->
	{Questid, Binary1}=read_int32(Binary0),
	Term = #quest_complete_s2c{questid=Questid},
	Term.

%%
decode_chess_spirit_prepare_s2c(Binary0)->
	{Time_s, Binary1}=read_int32(Binary0),
	Term = #chess_spirit_prepare_s2c{time_s=Time_s},
	Term.

%%
decode_role_move_fail_s2c(Binary0)->
	{Pos, Binary1}=decode_c(Binary0),
	Term = #role_move_fail_s2c{pos=Pos},
	Term.

%%
decode_query_time_c2s(Binary0)->
	Term = #query_time_c2s{},
	Term.

%%
decode_set_pkmodel_faild_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #set_pkmodel_faild_s2c{errno=Errno},
	Term.

%%
decode_is_jackaroo_s2c(Binary0)->
	Term = #is_jackaroo_s2c{},
	Term.

%%
decode_mainline_section_info_s2c(Binary0)->
	{Cur_section, Binary1}=read_int32(Binary0),
	{Next_section_s, Binary2}=read_int32(Binary1),
	Term = #mainline_section_info_s2c{cur_section=Cur_section, next_section_s=Next_section_s},
	Term.

%%
decode_guild_member_promotion_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #guild_member_promotion_c2s{roleid=Roleid},
	Term.

%%
decode_equipment_sock_c2s(Binary0)->
	{Equipment, Binary1}=read_int32(Binary0),
	{Sock, Binary2}=read_int32(Binary1),
	Term = #equipment_sock_c2s{equipment=Equipment, sock=Sock},
	Term.

%%
decode_vip_level_up_s2c(Binary0)->
	Term = #vip_level_up_s2c{},
	Term.


%%
decode_offline_exp_exchange_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Hours, Binary2}=read_int32(Binary1),
	Term = #offline_exp_exchange_c2s{type=Type, hours=Hours},
	Term.

%%
decode_entry_guild_battle_c2s(Binary0)->
	Term = #entry_guild_battle_c2s{},
	Term.

%%
decode_guild_destroy_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #guild_destroy_s2c{reason=Reason},
	Term.

%%
decode_get_timelimit_gift_c2s(Binary0)->
	Term = #get_timelimit_gift_c2s{},
	Term.

%%
decode_query_time_s2c(Binary0)->
	{Time_async, Binary1}=read_int32(Binary0),
	Term = #query_time_s2c{time_async=Time_async},
	Term.

%%
decode_update_skill_s2c(Binary0)->
	{Creatureid, Binary1}=read_int64(Binary0),
	{Skillid, Binary2}=read_int32(Binary1),
	{Level, Binary3}=read_int32(Binary2),
	Term = #update_skill_s2c{creatureid=Creatureid, skillid=Skillid, level=Level},
	Term.

%%
decode_timelimit_gift_over_s2c(Binary0)->
	Term = #timelimit_gift_over_s2c{},
	Term.

%%
decode_black_list_s2c(Binary0)->
	{Friendinfos, Binary1}=decode_list(Binary0, fun decode_br/1),
	Term = #black_list_s2c{friendinfos=Friendinfos},
	Term.

%%
decode_is_visitor_c2s(Binary0)->
	{T, Binary1}=read_int32(Binary0),
	{F, Binary2}=read_string(Binary1),
	Term = #is_visitor_c2s{t=T, f=F},
	Term.

%%
decode_quest_accept_failed_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #quest_accept_failed_s2c{errno=Errno},
	Term.

%%
decode_other_role_move_s2c(Binary0)->
	{Other_id, Binary1}=read_int64(Binary0),
	{Time, Binary2}=read_int32(Binary1),
	{Posx, Binary3}=read_int32(Binary2),
	{Posy, Binary4}=read_int32(Binary3),
	{Path, Binary5}=decode_list(Binary4, fun decode_c/1),
	Term = #other_role_move_s2c{other_id=Other_id, time=Time, posx=Posx, posy=Posy, path=Path},
	Term.

%%
decode_festival_recharge_notice_s2c(Binary0)->
	Term = #festival_recharge_notice_s2c{},
	Term.

%%
decode_pet_riseup_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	{Next, Binary2}=read_int32(Binary1),
	Term = #pet_riseup_s2c{result=Result, next=Next},
	Term.

%%
decode_trade_role_dealit_c2s(Binary0)->
	Term = #trade_role_dealit_c2s{},
	Term.

%%
decode_guild_battle_start_apply_s2c(Binary0)->
	{Lefttime, Binary1}=read_int32(Binary0),
	Term = #guild_battle_start_apply_s2c{lefttime=Lefttime},
	Term.

%%
decode_update_hotbar_c2s(Binary0)->
	{Clsid, Binary1}=read_int32(Binary0),
	{Entryid, Binary2}=read_int64(Binary1),
	{Pos, Binary3}=read_int32(Binary2),
	Term = #update_hotbar_c2s{clsid=Clsid, entryid=Entryid, pos=Pos},
	Term.

%%
decode_guild_member_demotion_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #guild_member_demotion_c2s{roleid=Roleid},
	Term.

%%
decode_guild_member_decline_s2c(Binary0)->
	{Rolename, Binary1}=read_string(Binary0),
	Term = #guild_member_decline_s2c{rolename=Rolename},
	Term.

%%
decode_yhzq_all_battle_over_s2c(Binary0)->
	Term = #yhzq_all_battle_over_s2c{},
	Term.

%%
decode_guild_application_op_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Reject, Binary2}=read_int32(Binary1),
	Term = #guild_application_op_c2s{roleid=Roleid, reject=Reject},
	Term.

%%
decode_guild_battle_result_s2c(Binary0)->
	{Index, Binary1}=read_int32(Binary0),
	Term = #guild_battle_result_s2c{index=Index},
	Term.

%%
decode_loop_tower_enter_higher_s2c(Binary0)->
	{Higher, Binary1}=read_int32(Binary0),
	Term = #loop_tower_enter_higher_s2c{higher=Higher},
	Term.

%%
decode_equipment_sock_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	{Sock, Binary2}=read_int32(Binary1),
	Term = #equipment_sock_s2c{result=Result, sock=Sock},
	Term.

%%
decode_jszd_start_notice_s2c(Binary0)->
	{Lefttime, Binary1}=read_int32(Binary0),
	Term = #jszd_start_notice_s2c{lefttime=Lefttime},
	Term.

%%
decode_set_pkmodel_c2s(Binary0)->
	{Pkmodel, Binary1}=read_int32(Binary0),
	Term = #set_pkmodel_c2s{pkmodel=Pkmodel},
	Term.

%%
decode_vip_init_s2c(Binary0)->
	{Vip, Binary1}=read_int32(Binary0),
	{Type, Binary2}=read_int32(Binary1),
	{Type2, Binary3}=read_int32(Binary2),
	Term = #vip_init_s2c{vip=Vip, type=Type, type2=Type2},
	Term.


%%
decode_trade_role_errno_s2c(Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #trade_role_errno_s2c{errno=Errno},
	Term.

%%
decode_position_friend_s2c(Binary0)->
	{Posfr, Binary1}=decode_pfr(Binary0),
	Term = #position_friend_s2c{posfr=Posfr},
	Term.

%%
decode_is_finish_visitor_c2s(Binary0)->
	{T, Binary1}=read_int32(Binary0),
	{F, Binary2}=read_string(Binary1),
	{U, Binary3}=read_string(Binary2),
	Term = #is_finish_visitor_c2s{t=T, f=F, u=U},
	Term.

%%
decode_yhzq_error_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #yhzq_error_s2c{reason=Reason},
	Term.

%%
decode_guild_member_invite_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Rolename, Binary2}=read_string(Binary1),
	{Guildlid, Binary3}=read_int32(Binary2),
	{Guildhid, Binary4}=read_int32(Binary3),
	{Guildname, Binary5}=read_string(Binary4),
	Term = #guild_member_invite_s2c{roleid=Roleid, rolename=Rolename, guildlid=Guildlid, guildhid=Guildhid, guildname=Guildname},
	Term.

%%
decode_guild_log_normal_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #guild_log_normal_c2s{type=Type},
	Term.

%%
decode_welfare_gold_exchange_c2s(Binary0)->
	Term = #welfare_gold_exchange_c2s{},
	Term.

%%
decode_pet_up_exp_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Needs, Binary2}=read_int32(Binary1),
	Term = #pet_up_exp_c2s{petid=Petid, needs=Needs},
	Term.

%%
decode_guild_battle_stop_apply_s2c(Binary0)->
	Term = #guild_battle_stop_apply_s2c{},
	Term.

%%
decode_duel_invite_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #duel_invite_c2s{roleid=Roleid},
	Term.

%%
decode_init_open_service_activities_c2s(Binary0)->
	{Activeid, Binary1}=read_int32(Binary0),
	Term = #init_open_service_activities_c2s{activeid=Activeid},
	Term.

%%
decode_jszd_join_c2s(Binary0)->
	Term = #jszd_join_c2s{},
	Term.

%%
decode_trade_begin_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #trade_begin_s2c{roleid=Roleid},
	Term.

%%
decode_clear_crime_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #clear_crime_c2s{type=Type},
	Term.

%%
decode_guild_get_treasure_item_s2c(Binary0)->
	{Treasuretype, Binary1}=read_int32(Binary0),
	{Itemlist, Binary2}=decode_list(Binary1, fun decode_gti/1),
	Term = #guild_get_treasure_item_s2c{treasuretype=Treasuretype, itemlist=Itemlist},
	Term.

%%
decode_guild_log_event_c2s(Binary0)->
	Term = #guild_log_event_c2s{},
	Term.

%%
decode_update_hotbar_fail_s2c(Binary0)->
	Term = #update_hotbar_fail_s2c{},
	Term.

%%
decode_aoi_role_group_c2s(Binary0)->
	Term = #aoi_role_group_c2s{},
	Term.

%%
decode_fatigue_login_disabled_s2c(Binary0)->
	{Lefttime, Binary1}=read_int32(Binary0),
	{Prompt, Binary2}=read_string(Binary1),
	Term = #fatigue_login_disabled_s2c{lefttime=Lefttime, prompt=Prompt},
	Term.

%%
decode_position_friend_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #position_friend_failed_s2c{reason=Reason},
	Term.

%%客户端加载地图数据完成
decode_map_complete_c2s(Binary0)->
	Term = #map_complete_c2s{},
	Term.

%%
decode_visitor_rename_s2c(Binary0)->
	Term = #visitor_rename_s2c{},
	Term.

%%
decode_object_update_s2c(Binary0)->
	{Deleteids, Binary1}=decode_list(Binary0, fun decode_o/1),
	{Create_attrs, Binary2}=decode_list(Binary1, fun decode_o/1),
	{Change_attrs, Binary3}=decode_list(Binary2, fun decode_o/1),
	Term = #object_update_s2c{deleteids=Deleteids, create_attrs=Create_attrs, change_attrs=Change_attrs},
	Term.

%%
decode_myfriends_c2s(Binary0)->
	{Ntype, Binary1}=read_int32(Binary0),
	Term = #myfriends_c2s{ntype=Ntype},
	Term.

%%
decode_group_decline_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Username, Binary2}=read_string(Binary1),
	Term = #group_decline_s2c{roleid=Roleid, username=Username},
	Term.

%%
decode_guild_notice_modify_c2s(Binary0)->
	{Notice, Binary1}=read_string(Binary0),
	Term = #guild_notice_modify_c2s{notice=Notice},
	Term.

%%
decode_role_cancel_attack_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Reason, Binary2}=read_int32(Binary1),
	Term = #role_cancel_attack_s2c{roleid=Roleid, reason=Reason},
	Term.

%%
decode_pet_opt_error_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #pet_opt_error_s2c{reason=Reason},
	Term.

%%
decode_mail_delete_c2s(Binary0)->
	{Mailid, Binary1}=decode_mid(Binary0),
	Term = #mail_delete_c2s{mailid=Mailid},
	Term.

%%
decode_clear_crime_time_s2c(Binary0)->
	{Lefttime, Binary1}=read_int32(Binary0),
	{Type, Binary2}=read_int32(Binary1),
	Term = #clear_crime_time_s2c{lefttime=Lefttime, type=Type},
	Term.

%%
decode_spa_error_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #spa_error_s2c{reason=Reason},
	Term.

%%
decode_welfare_panel_init_s2c(Binary0)->
	{Packs_state, Binary1}=decode_list(Binary0, fun decode_gps/1),
	Term = #welfare_panel_init_s2c{packs_state=Packs_state},
	Term.

%%
decode_vip_ui_c2s(Binary0)->
	Term = #vip_ui_c2s{},
	Term.

%%
decode_learned_skill_s2c(Binary0)->
	{Creatureid, Binary1}=read_int64(Binary0),
	{Skills, Binary2}=decode_list(Binary1, fun decode_s/1),
	Term = #learned_skill_s2c{creatureid=Creatureid, skills=Skills},
	Term.

%%
decode_equipment_inlay_c2s(Binary0)->
	{Equipment, Binary1}=read_int32(Binary0),
	{Inlay, Binary2}=read_int32(Binary1),
	{Socknum, Binary3}=read_int32(Binary2),
	Term = #equipment_inlay_c2s{equipment=Equipment, inlay=Inlay, socknum=Socknum},
	Term.

%%
decode_jszd_join_s2c(Binary0)->
	{Lefttime, Binary1}=read_int32(Binary0),
	{Guilds, Binary2}=decode_list(Binary1, fun decode_jszd/1),
	Term = #jszd_join_s2c{lefttime=Lefttime, guilds=Guilds},
	Term.

%%
decode_equipment_sock_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #equipment_sock_failed_s2c{reason=Reason},
	Term.

%%
decode_vip_ui_s2c(Binary0)->
	{Vip, Binary1}=read_int32(Binary0),
	{Gold, Binary2}=read_int32(Binary1),
	{Endtime, Binary3}=read_int32(Binary2),
	Term = #vip_ui_s2c{vip=Vip, gold=Gold, endtime=Endtime},
	Term.

%%玩家初始化数据
decode_role_map_change_s2c(Binary0)->
	{X, Binary1}=read_int32(Binary0),
	{Y, Binary2}=read_int32(Binary1),
	{Lineid, Binary3}=read_int32(Binary2),
	{Mapid, Binary4}=read_int32(Binary3),
	Term = #role_map_change_s2c{x=X, y=Y, lineid=Lineid, mapid=Mapid},
	Term.

%%
decode_update_trade_status_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Silver, Binary2}=read_int32(Binary1),
	{Gold, Binary3}=read_int32(Binary2),
	{Ticket, Binary4}=read_int32(Binary3),
	{Slot_infos, Binary5}=decode_list(Binary4, fun decode_ti/1),
	Term = #update_trade_status_s2c{roleid=Roleid, silver=Silver, gold=Gold, ticket=Ticket, slot_infos=Slot_infos},
	Term.

%%
%decode_init_open_service_activities_s2c(Binary0)->
%	{Activeid, Binary1}=read_int32(Binary0),
%	{Partinfo, Binary2}=decode_list(Binary1, fun decode_recharge/1),
%	{Starttime, Binary3}=decode_time_struct(Binary2),
%	{Endtime, Binary4}=decode_time_struct(Binary3),
%	{Lefttime, Binary5}=read_int32(Binary4),
%	{Info, Binary6}=read_int32(Binary5),
%	{State, Binary7}=read_int32(Binary6),
%	Term = #init_open_service_activities_s2c{activeid=Activeid, partinfo=Partinfo, starttime=Starttime, endtime=Endtime, lefttime=Lefttime, info=Info, state=State},
%	Term.

decode_init_open_service_activities_s2c(Binary0)->
	{Info, Binary1}=decode_list(Binary0, fun decode_nsr/1),
	Term = #init_open_service_activities_s2c{info=Info},
	Term.

decode_nsr(Binary0)->
	{Activeid, Binary1}=read_int32(Binary0),
	{Starttime, Binary2}=decode_time_struct(Binary1),
	{Endtime, Binary3}=decode_time_struct(Binary2),
	{Info, Binary4}=read_int32(Binary3),
	{State, Binary5}=read_int32(Binary4),
	{Part, Binary6}=decode_list(Binary5, fun decode_nsp/1),
	Term = #nsr{activeid=Activeid, starttime=Starttime, endtime=Endtime, info=Info, state=State, part=Part},
	{Term, Binary6}.

decode_nsp(Binary0)->
	{State, Binary1}=read_int32(Binary0),
	{Id, Binary2}=read_int32(Binary1),
	Term = #nsp{state=State, id=Id},
	{Term, Binary2}.

%%
decode_visitor_rename_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #visitor_rename_failed_s2c{reason=Reason},
	Term.

%%
decode_guild_treasure_buy_item_c2s(Binary0)->
	{Treasuretype, Binary1}=read_int32(Binary0),
	{Id, Binary2}=read_int32(Binary1),
	{Itemid, Binary3}=read_int32(Binary2),
	{Count, Binary4}=read_int32(Binary3),
	Term = #guild_treasure_buy_item_c2s{treasuretype=Treasuretype, id=Id, itemid=Itemid, count=Count},
	Term.

%%
decode_visitor_rename_c2s(Binary0)->
	{N, Binary1}=read_string(Binary0),
	Term = #visitor_rename_c2s{n=N},
	Term.

%%
decode_buy_pet_slot_c2s(Binary0)->
	Term = #buy_pet_slot_c2s{},
	Term.

%%
decode_duel_decline_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #duel_decline_c2s{roleid=Roleid},
	Term.

%%
decode_loop_tower_enter_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #loop_tower_enter_failed_s2c{reason=Reason},
	Term.

%%
decode_congratulations_levelup_s2c(Binary0)->
	{Exp, Binary1}=read_int32(Binary0),
	{Soulpower, Binary2}=read_int32(Binary1),
	{Remain, Binary3}=read_int32(Binary2),
	Term = #congratulations_levelup_s2c{exp=Exp, soulpower=Soulpower, remain=Remain},
	Term.

%%
decode_guild_facilities_accede_rules_c2s(Binary0)->
	{Facilityid, Binary1}=read_int32(Binary0),
	{Requirevalue, Binary2}=read_int32(Binary1),
	Term = #guild_facilities_accede_rules_c2s{facilityid=Facilityid, requirevalue=Requirevalue},
	Term.

%%
decode_update_pet_slot_num_s2c(Binary0)->
	{Num, Binary1}=read_int32(Binary0),
	Term = #update_pet_slot_num_s2c{num=Num},
	Term.

%%
decode_guild_log_event_s2c(Binary0)->
	Term = #guild_log_event_s2c{},
	Term.

%%equipment_inlay_s2c
decode_equipment_inlay_s2c(Binary0)->
	Term = #equipment_inlay_s2c{},
	Term.

%%
decode_query_player_option_c2s(Binary0)->
	{Key, Binary1}=read_int32_list(Binary0),
	Term = #query_player_option_c2s{key=Key},
	Term.

%%
decode_guild_facilities_upgrade_c2s(Binary0)->
	{Facilityid, Binary1}=read_int32(Binary0),
	Term = #guild_facilities_upgrade_c2s{facilityid=Facilityid},
	Term.

%%已经存在于地图的角色数据
decode_other_role_map_init_s2c(Binary0)->
	{Others, Binary1}=decode_list(Binary0, fun decode_rl/1),
	Term = #other_role_map_init_s2c{others=Others},
	Term.

%%
decode_query_system_switch_c2s(Binary0)->
	{Sysid, Binary1}=read_int32(Binary0),
	Term = #query_system_switch_c2s{sysid=Sysid},
	Term.

%%
decode_use_target_item_c2s(Binary0)->
	{Targetid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	Term = #use_target_item_c2s{targetid=Targetid, slot=Slot},
	Term.

%%
decode_tangle_topman_pos_s2c(Binary0)->
	{Roleposes, Binary1}=decode_list(Binary0, fun decode_tp/1),
	Term = #tangle_topman_pos_s2c{roleposes=Roleposes},
	Term.

%%
decode_group_destroy_s2c(Binary0)->
	Term = #group_destroy_s2c{},
	Term.

%%
decode_equipment_inlay_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #equipment_inlay_failed_s2c{reason=Reason},
	Term.

%%
decode_pet_feed_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	Term = #pet_feed_c2s{petid=Petid, slot=Slot},
	Term.

%%
decode_create_role_request_c2s(Binary0)->
	{Role_name, Binary1}=read_string(Binary0),
	{Gender, Binary2}=read_int32(Binary1),
	{Classtype, Binary3}=read_int32(Binary2),
	Term = #create_role_request_c2s{role_name=Role_name, gender=Gender, classtype=Classtype},
	Term.

%%
decode_add_buff_s2c(Binary0)->
	{Targetid, Binary1}=read_int64(Binary0),
	{Buffers, Binary2}=decode_list(Binary1, fun decode_bf/1),
	Term = #add_buff_s2c{targetid=Targetid, buffers=Buffers},
	Term.

%%
decode_system_status_s2c(Binary0)->
	{Sysid, Binary1}=read_int32(Binary0),
	{Status, Binary2}=read_int32(Binary1),
	Term = #system_status_s2c{sysid=Sysid, status=Status},
	Term.

%%
decode_jszd_leave_c2s(Binary0)->
	Term = #jszd_leave_c2s{},
	Term.

%%NPC的初始信息
decode_npc_init_s2c(Binary0)->
	{Npcs, Binary1}=decode_list(Binary0, fun decode_nl/1),
	Term = #npc_init_s2c{npcs=Npcs},
	Term.

%%
decode_quest_list_update_s2c(Binary0)->
	{Quests, Binary1}=decode_list(Binary0, fun decode_q/1),
	Term = #quest_list_update_s2c{quests=Quests},
	Term.

%%
decode_query_player_option_s2c(Binary0)->
	{Kv, Binary1}=decode_list(Binary0, fun decode_k/1),
	Term = #query_player_option_s2c{kv=Kv},
	Term.

%%
decode_trade_role_lock_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #trade_role_lock_s2c{roleid=Roleid},
	Term.

%%
decode_guild_facilities_speed_up_c2s(Binary0)->
	{Facilityid, Binary1}=read_int32(Binary0),
	{Slotnum, Binary2}=read_int32(Binary1),
	Term = #guild_facilities_speed_up_c2s{facilityid=Facilityid, slotnum=Slotnum},
	Term.

%%
decode_item_identify_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Itemslot, Binary2}=read_int32(Binary1),
	{Type, Binary3}=read_int32(Binary2),
	Term = #item_identify_c2s{slot=Slot, itemslot=Itemslot, type=Type},
	Term.

%%
decode_duel_accept_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #duel_accept_c2s{roleid=Roleid},
	Term.

%%
decode_vip_npc_enum_s2c(Binary0)->
	{Vip, Binary1}=read_int32(Binary0),
	{Bonus, Binary2}=decode_list(Binary1, fun decode_l/1),
	Term = #vip_npc_enum_s2c{vip=Vip, bonus=Bonus},
	Term.

%%
decode_loop_tower_masters_c2s(Binary0)->
	{Master, Binary1}=read_int32(Binary0),
	Term = #loop_tower_masters_c2s{master=Master},
	Term.

%%
decode_npc_everquests_enum_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	Term = #npc_everquests_enum_c2s{npcid=Npcid},
	Term.

%%
decode_jszd_update_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Score, Binary2}=read_int32(Binary1),
	{Lefttime, Binary3}=read_int32(Binary2),
	{Guilds, Binary4}=decode_list(Binary3, fun decode_jszd/1),
	Term = #jszd_update_s2c{roleid=Roleid, score=Score, lefttime=Lefttime, guilds=Guilds},
	Term.

%%
decode_equipment_stone_remove_c2s(Binary0)->
	{Equipment, Binary1}=read_int32(Binary0),
	{Remove, Binary2}=read_int32(Binary1),
	{Socknum, Binary3}=read_int32(Binary2),
	Term = #equipment_stone_remove_c2s{equipment=Equipment, remove=Remove, socknum=Socknum},
	Term.

%%
decode_open_sercice_activities_update_s2c(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{Part, Binary2}=read_int32(Binary1),
	{State, Binary3}=read_int32(Binary2),
	Term = #open_sercice_activities_update_s2c{id=Id, part=Part, state=State},
	Term.

%%
decode_del_buff_s2c(Binary0)->
	{Buffid, Binary1}=read_int32(Binary0),
	{Target, Binary2}=read_int64(Binary1),
	Term = #del_buff_s2c{buffid=Buffid, target=Target},
	Term.

%%
decode_jszd_leave_s2c(Binary0)->
	Term = #jszd_leave_s2c{},
	Term.

%%
decode_pet_move_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Time, Binary2}=read_int32(Binary1),
	{Posx, Binary3}=read_int32(Binary2),
	{Posy, Binary4}=read_int32(Binary3),
	{Path, Binary5}=decode_list(Binary4, fun decode_c/1),
	Term = #pet_move_c2s{petid=Petid, time=Time, posx=Posx, posy=Posy, path=Path},
	Term.

%%
decode_guild_get_application_c2s(Binary0)->
	Term = #guild_get_application_c2s{},
	Term.

%%
decode_replace_player_option_c2s(Binary0)->
	{Kv, Binary1}=decode_list(Binary0, fun decode_k/1),
	Term = #replace_player_option_c2s{kv=Kv},
	Term.

%%
decode_quest_get_adapt_c2s(Binary0)->
	Term = #quest_get_adapt_c2s{},
	Term.

%%
decode_trade_role_dealit_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #trade_role_dealit_s2c{roleid=Roleid},
	Term.

%%
decode_group_list_update_s2c(Binary0)->
	{Leaderid, Binary1}=read_int64(Binary0),
	{Members, Binary2}=decode_list(Binary1, fun decode_m/1),
	Term = #group_list_update_s2c{leaderid=Leaderid, members=Members},
	Term.

%%
decode_equipment_riseup_c2s(Binary0)->
	{Equipment, Binary1}=read_int32(Binary0),
	{Riseup, Binary2}=read_int32(Binary1),
	{Protect, Binary3}=read_int32(Binary2),
	{Lucky, Binary4}=read_int32_list(Binary3),
	Term = #equipment_riseup_c2s{equipment=Equipment, riseup=Riseup, protect=Protect, lucky=Lucky},
	Term.

%%
decode_npc_everquests_enum_s2c(Binary0)->
	{Everquests, Binary1}=read_int32_list(Binary0),
	{Npcid, Binary2}=read_int64(Binary1),
	Term = #npc_everquests_enum_s2c{everquests=Everquests, npcid=Npcid},
	Term.

%%
decode_guild_rewards_c2s(Binary0)->
	Term = #guild_rewards_c2s{},
	Term.

%%
decode_vip_reward_c2s(Binary0)->
	Term = #vip_reward_c2s{},
	Term.

%%
decode_offline_exp_quests_init_s2c(Binary0)->
	{Questinfos, Binary1}=decode_list(Binary0, fun decode_oqe/1),
	Term = #offline_exp_quests_init_s2c{questinfos=Questinfos},
	Term.

%%
decode_quest_direct_complete_c2s(Binary0)->
	{Questid, Binary1}=read_int32(Binary0),
	Term = #quest_direct_complete_c2s{questid=Questid},
	Term.

%%
decode_questgiver_hello_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	Term = #questgiver_hello_c2s{npcid=Npcid},
	Term.

%%
decode_group_cmd_result_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Username, Binary2}=read_string(Binary1),
	{Reslut, Binary3}=read_int32(Binary2),
	Term = #group_cmd_result_s2c{roleid=Roleid, username=Username, reslut=Reslut},
	Term.

%%
decode_guild_recruite_info_c2s(Binary0)->
	Term = #guild_recruite_info_c2s{},
	Term.

%%
decode_info_back_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Info, Binary2}=read_string(Binary1),
	{Version, Binary3}=read_string(Binary2),
	Term = #info_back_c2s{type=Type, info=Info, version=Version},
	Term.

%%
decode_move_stop_s2c(Binary0)->
	{Id, Binary1}=read_int64(Binary0),
	{X, Binary2}=read_int32(Binary1),
	{Y, Binary3}=read_int32(Binary2),
	Term = #move_stop_s2c{id=Id, x=X, y=Y},
	Term.

%%
decode_notify_to_join_yhzq_s2c(Binary0)->
	{Battle_id, Binary1}=read_int32(Binary0),
	{Camp, Binary2}=read_int32(Binary1),
	Term = #notify_to_join_yhzq_s2c{battle_id=Battle_id, camp=Camp},
	Term.

%%
decode_role_attack_c2s(Binary0)->
	{Skillid, Binary1}=read_int32(Binary0),
	{Creatureid, Binary2}=read_int64(Binary1),
	Term = #role_attack_c2s{skillid=Skillid, creatureid=Creatureid},
	Term.

%%
decode_guild_treasure_set_price_c2s(Binary0)->
	{Treasuretype, Binary1}=read_int32(Binary0),
	{Id, Binary2}=read_int32(Binary1),
	{Itemid, Binary3}=read_int32(Binary2),
	{Price, Binary4}=read_int32(Binary3),
	Term = #guild_treasure_set_price_c2s{treasuretype=Treasuretype, id=Id, itemid=Itemid, price=Price},
	Term.

%%
decode_trade_role_apply_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #trade_role_apply_s2c{roleid=Roleid},
	Term.

%%
decode_jszd_end_s2c(Binary0)->
	{Myrank, Binary1}=read_int32(Binary0),
	{Guilds, Binary2}=decode_list(Binary1, fun decode_jszd/1),
	{Honor, Binary3}=read_int32(Binary2),
	{Exp, Binary4}=read_int64(Binary3),
	Term = #jszd_end_s2c{myrank=Myrank, guilds=Guilds, honor=Honor, exp=Exp},
	Term.

%%
decode_equipment_stone_remove_s2c(Binary0)->
	Term = #equipment_stone_remove_s2c{},
	Term.

%%
decode_guild_member_contribute_c2s(Binary0)->
	{Moneytype, Binary1}=read_int32(Binary0),
	{Moneycount, Binary2}=read_int32(Binary1),
	Term = #guild_member_contribute_c2s{moneytype=Moneytype, moneycount=Moneycount},
	Term.

%%
decode_recruite_c2s(Binary0)->
	{Instance, Binary1}=read_int32(Binary0),
	{Description, Binary2}=read_string(Binary1),
	Term = #recruite_c2s{instance=Instance, description=Description},
	Term.

%%
decode_duel_invite_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #duel_invite_s2c{roleid=Roleid},
	Term.

%%
decode_equipment_stone_remove_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #equipment_stone_remove_failed_s2c{reason=Reason},
	Term.

%%
decode_mail_query_detail_s2c(Binary0)->
	{Mail_detail, Binary1}=decode_md(Binary0),
	Term = #mail_query_detail_s2c{mail_detail=Mail_detail},
	Term.

%%
decode_npc_start_everquest_c2s(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Everqid, Binary2}=read_int32(Binary1),
	Term = #npc_start_everquest_c2s{npcid=Npcid, everqid=Everqid},
	Term.

%%
decode_login_bonus_reward_c2s(Binary0)->
	Term = #login_bonus_reward_c2s{},
	Term.

%%
decode_guild_change_chatandvoicegroup_c2s(Binary0)->
	{Chatgroup, Binary1}=read_string(Binary0),
	{Voicegroup, Binary2}=read_string(Binary1),
	Term = #guild_change_chatandvoicegroup_c2s{chatgroup=Chatgroup, voicegroup=Voicegroup},
	Term.

%%
decode_aoi_role_group_s2c(Binary0)->
	{Groups_role, Binary1}=decode_list(Binary0, fun decode_ag/1),
	Term = #aoi_role_group_s2c{groups_role=Groups_role},
	Term.

%%
decode_pet_attack_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Skillid, Binary2}=read_int32(Binary1),
	{Creatureid, Binary3}=read_int64(Binary2),
	Term = #pet_attack_c2s{petid=Petid, skillid=Skillid, creatureid=Creatureid},
	Term.

%%
decode_trade_role_decline_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #trade_role_decline_s2c{roleid=Roleid},
	Term.

%%
decode_quest_get_adapt_s2c(Binary0)->
	{Questids, Binary1}=read_int32_list(Binary0),
	{Everqids, Binary2}=read_int32_list(Binary1),
	Term = #quest_get_adapt_s2c{questids=Questids, everqids=Everqids},
	Term.

%%
decode_role_attack_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	{Skillid, Binary2}=read_int32(Binary1),
	{Enemyid, Binary3}=read_int64(Binary2),
	{Creatureid, Binary4}=read_int64(Binary3),
	Term = #role_attack_s2c{result=Result, skillid=Skillid, enemyid=Enemyid, creatureid=Creatureid},
	Term.

%%
decode_join_yhzq_c2s(Binary0)->
	{Reject, Binary1}=read_int32(Binary0),
	Term = #join_yhzq_c2s{reject=Reject},
	Term.

%%
decode_jszd_reward_c2s(Binary0)->
	Term = #jszd_reward_c2s{},
	Term.

%%
decode_player_level_up_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Attrs, Binary2}=decode_list(Binary1, fun decode_k/1),
	Term = #player_level_up_s2c{roleid=Roleid, attrs=Attrs},
	Term.

%%
decode_treasure_chest_flush_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #treasure_chest_flush_c2s{slot=Slot},
	Term.

%%
decode_recruite_cancel_c2s(Binary0)->
	Term = #recruite_cancel_c2s{},
	Term.

%%
decode_feedback_info_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Title, Binary2}=read_string(Binary1),
	{Content, Binary3}=read_string(Binary2),
	{Contactway, Binary4}=read_string(Binary3),
	Term = #feedback_info_c2s{type=Type, title=Title, content=Content, contactway=Contactway},
	Term.

%%
decode_offline_exp_exchange_gold_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Hours, Binary2}=read_int32(Binary1),
	Term = #offline_exp_exchange_gold_c2s{type=Type, hours=Hours},
	Term.

%%
decode_equipment_riseup_s2c(Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	{Star, Binary2}=read_int32(Binary1),
	Term = #equipment_riseup_s2c{result=Result, star=Star},
	Term.

%%
decode_equipment_stonemix_single_c2s(Binary0)->
	{Stonelist, Binary1}=decode_list(Binary0, fun decode_l/1),
	Term = #equipment_stonemix_single_c2s{stonelist=Stonelist},
	Term.

%%
decode_display_hotbar_s2c(Binary0)->
	{Things, Binary1}=decode_list(Binary0, fun decode_hc/1),
	Term = #display_hotbar_s2c{things=Things},
	Term.

%%
decode_equipment_stonemix_c2s(Binary0)->
	{Times, Binary1}=read_int32(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	{Count, Binary3}=read_int32(Binary2),
	Term = #equipment_stonemix_c2s{stoneSlot=Slot, numRequire=Count,numMix=Times},
	Term.

%%
decode_jszd_error_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #jszd_error_s2c{reason=Reason},
	Term.

%%
decode_refresh_everquest_c2s(Binary0)->
	{Everqid, Binary1}=read_int32(Binary0),
	{Freshtype, Binary2}=read_int32(Binary1),
	{Maxquality, Binary3}=read_int32(Binary2),
	{Maxtimes, Binary4}=read_int32(Binary3),
	Term = #refresh_everquest_c2s{everqid=Everqid, freshtype=Freshtype, maxquality=Maxquality, maxtimes=Maxtimes},
	Term.

%%
decode_mail_delete_s2c(Binary0)->
	{Mailid, Binary1}=decode_mid(Binary0),
	Term = #mail_delete_s2c{mailid=Mailid},
	Term.

%%
decode_equipment_riseup_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #equipment_riseup_failed_s2c{reason=Reason},
	Term.

%%
decode_recruite_query_c2s(Binary0)->
	{Instance, Binary1}=read_int32(Binary0),
	Term = #recruite_query_c2s{instance=Instance},
	Term.

%%
decode_cancel_trade_s2c(Binary0)->
	Term = #cancel_trade_s2c{},
	Term.

%%
decode_leave_yhzq_c2s(Binary0)->
	Term = #leave_yhzq_c2s{},
	Term.

%%
decode_group_create_c2s(Binary0)->
	Term = #group_create_c2s{},
	Term.

%%
decode_guild_get_application_s2c(Binary0)->
	{Roles, Binary1}=decode_list(Binary0, fun decode_g/1),
	Term = #guild_get_application_s2c{roles=Roles},
	Term.

%%
decode_duel_decline_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #duel_decline_s2c{roleid=Roleid},
	Term.

%%
decode_goals_init_s2c(Binary0)->
	{Parts, Binary1}=decode_list(Binary0, fun decode_ach/1),
	Term = #goals_init_s2c{parts=Parts},
	Term.

%%
decode_activity_tab_isshow_s2c(Binary0)->
	{Ts, Binary1}=decode_list(Binary0, fun decode_tab_state/1),
	Term = #activity_tab_isshow_s2c{ts=Ts},
	Term.

%%
decode_yhzq_award_s2c(Binary0)->
	{Winner, Binary1}=read_int32(Binary0),
	{Honor, Binary2}=read_int32(Binary1),
	{Exp, Binary3}=read_int64(Binary2),
	Term = #yhzq_award_s2c{winner=Winner, honor=Honor, exp=Exp},
	Term.

%%
decode_pet_stop_move_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Time, Binary2}=read_int32(Binary1),
	{Posx, Binary3}=read_int32(Binary2),
	{Posy, Binary4}=read_int32(Binary3),
	Term = #pet_stop_move_c2s{petid=Petid, time=Time, posx=Posx, posy=Posy},
	Term.

%%
decode_create_role_sucess_s2c(Binary0)->
	{Role_id, Binary1}=read_int64(Binary0),
	Term = #create_role_sucess_s2c{role_id=Role_id},
	Term.

%%
decode_trade_success_s2c(Binary0)->
	Term = #trade_success_s2c{},
	Term.

%%
decode_questgiver_quest_details_s2c(Binary0)->
	{Npcid, Binary1}=read_int64(Binary0),
	{Quests, Binary2}=read_int32_list(Binary1),
	{Queststate, Binary3}=read_int32_list(Binary2),
	Term = #questgiver_quest_details_s2c{npcid=Npcid, quests=Quests, queststate=Queststate},
	Term.

%%
decode_mail_get_addition_c2s(Binary0)->
	{Mailid, Binary1}=decode_mid(Binary0),
	Term = #mail_get_addition_c2s{mailid=Mailid},
	Term.




%%
decode_equipment_upgrade_c2s(Binary0)->
	{Equipment, Binary1}=read_int32(Binary0),
	Term = #equipment_upgrade_c2s{equipment=Equipment},
	Term.

%%
decode_jszd_stop_s2c(Binary0)->
	Term = #jszd_stop_s2c{},
	Term.

%%
decode_debug_c2s(Binary0)->
	{Msg, Binary1}=read_string(Binary0),
	Term = #debug_c2s{msg=Msg},
	Term.

%%
decode_refresh_everquest_s2c(Binary0)->
	{Everqid, Binary1}=read_int32(Binary0),
	{Questid, Binary2}=read_int32(Binary1),
	{Quality, Binary3}=read_int32(Binary2),
	{Free_fresh_times, Binary4}=read_int32(Binary3),
	{Resettime, Binary5}=read_int32(Binary4),
	Term = #refresh_everquest_s2c{everqid=Everqid, questid=Questid, quality=Quality, free_fresh_times=Free_fresh_times, resettime=Resettime},
	Term.

%%
decode_be_attacked_s2c(Binary0)->
	{Enemyid, Binary1}=read_int64(Binary0),
	{Skill, Binary2}=read_int32(Binary1),
	{Units, Binary3}=decode_list(Binary2, fun decode_b/1),
	{Flytime, Binary4}=read_int32(Binary3),
	Term = #be_attacked_s2c{enemyid=Enemyid, skill=Skill, units=Units, flytime=Flytime},
	Term.

%%
decode_treasure_chest_flush_ok_s2c(Binary0)->
	{Items, Binary1}=decode_list(Binary0, fun decode_lti/1),
	Term = #treasure_chest_flush_ok_s2c{items=Items},
	Term.

%%
decode_mail_query_detail_c2s(Binary0)->
	{Mailid, Binary1}=decode_mid(Binary0),
	Term = #mail_query_detail_c2s{mailid=Mailid},
	Term.

%%
decode_group_invite_c2s(Binary0)->
	{Username, Binary1}=read_string(Binary0),
	Term = #group_invite_c2s{username=Username},
	Term.

%%
decode_vip_error_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #vip_error_s2c{reason=Reason},
	Term.

%%
decode_yhzq_award_c2s(Binary0)->
	Term = #yhzq_award_c2s{},
	Term.

%%
decode_start_block_training_c2s(Binary0)->
	Term = #start_block_training_c2s{},
	Term.

%%
decode_summon_pet_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Petid, Binary2}=read_int64(Binary1),
	Term = #summon_pet_c2s{type=Type, petid=Petid},
	Term.

%%
decode_guild_change_nickname_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Nickname, Binary2}=read_string(Binary1),
	Term = #guild_change_nickname_c2s{roleid=Roleid, nickname=Nickname},
	Term.

%%
decode_equipment_stonemix_failed_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #equipment_stonemix_failed_s2c{reason=Reason},
	Term.

%%
decode_quest_list_remove_s2c(Binary0)->
	{Questid, Binary1}=read_int32(Binary0),
	Term = #quest_list_remove_s2c{questid=Questid},
	Term.

%%
decode_create_role_failed_s2c(Binary0)->
	{Reasonid, Binary1}=read_int32(Binary0),
	Term = #create_role_failed_s2c{reasonid=Reasonid},
	Term.

%%
decode_guild_contribute_log_c2s(Binary0)->
	Term = #guild_contribute_log_c2s{},
	Term.

%%
decode_start_block_training_s2c(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Lefttime, Binary2}=read_int32(Binary1),
	Term = #start_block_training_s2c{roleid=Roleid, lefttime=Lefttime},
	Term.

%%
decode_open_service_activities_reward_c2s(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{Part, Binary2}=read_int32(Binary1),
	Term = #open_service_activities_reward_c2s{id=Id, part=Part},
	Term.

%%
decode_yhzq_camp_info_s2c(Binary0)->
	{Redplayernum, Binary1}=read_int32(Binary0),
	{Blueplayernum, Binary2}=read_int32(Binary1),
	{Redscore, Binary3}=read_int32(Binary2),
	{Bluescore, Binary4}=read_int32(Binary3),
	{Redguild, Binary5}=read_string(Binary4),
	{Blueguild, Binary6}=read_string(Binary5),
	Term = #yhzq_camp_info_s2c{redplayernum=Redplayernum, blueplayernum=Blueplayernum, redscore=Redscore, bluescore=Bluescore, redguild=Redguild, blueguild=Blueguild},
	Term.

%%
decode_equipment_upgrade_s2c(Binary0)->
	Term = #equipment_upgrade_s2c{},
	Term.

%%
decode_festival_init_c2s(Binary0)->
	{Festival_id, Binary1}=read_int32(Binary0),
	Term = #festival_init_c2s{festival_id=Festival_id},
	Term.

%%
decode_invite_friend_board_s2c(Binary0)->
	{Friends_size, Binary1}=read_int32(Binary0),
	{Amount_awards, Binary2}=read_int32_list(Binary1),
	Term = #invite_friend_board_s2c{friends_size=Friends_size, amount_awards=Amount_awards},
	Term.

%%
decode_tangle_battlefield_info_s2c(Binary0)->
	{Killnum, Binary1}=read_int32(Binary0),
	{Honor, Binary2}=read_int32(Binary1),
	{Battleinfo, Binary3}=decode_list(Binary2, fun decode_tbi/1),
	Term = #tangle_battlefield_info_s2c{killnum=Killnum, honor=Honor, battleinfo=Battleinfo},
	Term.

%%
decode_sync_bonfire_time_s2c(Binary0)->
	{Lefttime, Binary1}=read_float(Binary0),
	Term = #sync_bonfire_time_s2c{lefttime=Lefttime},
	Term.
%%使用宠物蛋《枫少》
decode_use_pet_egg_ext_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	{Proto, Binary3}=read_int32(Binary2),
	Term = #use_pet_egg_ext_c2s{type=Type, slot=Slot, proto=Proto},
	Term.

%%宠物初始化
decode_pet_shop_init_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	Term = #pet_shop_init_c2s{type=Type},
	Term.


encode_guild_bonfire_end_s2c(Term)->
	<<1222:16>>.
%%购买宠物《枫少》
decode_pet_shop_buy_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #pet_shop_buy_c2s{slot=Slot},
	Term.
%%宠物资质提升
decode_pet_qualification_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Opt, Binary2}=read_int32(Binary1),
	{Useprotect, Binary3}=read_int32(Binary2),
	{Luckystonenum, Binary4}=read_int32(Binary3),
	{LuckystoneSlot, Binary5}=read_int32(Binary4),
	Term = #pet_qualification_c2s{petid=Petid, opt=Opt, useprotect=Useprotect, luckystonenum=Luckystonenum, luckystonesolt=LuckystoneSlot},
	Term.
%%%%加速升级
decode_pet_speed_levelup_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	Term = #pet_speed_levelup_c2s{petid=Petid},
	Term.
%%宠物成长
decode_pet_evolution_growthvalue_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	Term = #pet_evolution_growthvalue_c2s{petid=Petid},
	Term.
%%宠物成长提升
decode_pet_growup_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{NeedItemSlot, Binary2}=read_int32(Binary1),
	Term = #pet_growup_c2s{petid=Petid, needitemslot=NeedItemSlot},
	Term.

%%成就初始化请求(@@wb)
decode_achieve_init_c2s(Binary0)->
	Term = #achieve_init_c2s{},
	Term.

decode_ach_id(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Part, Binary2}=read_int32(Binary1),
	Term = #ach_id{type=Type, part=Part},
	{Term, Binary2}.

decode_fw(Binary0)->
	{Id, Binary1}=read_int32(Binary0),
	{Level, Binary2}=read_int32(Binary1),
	Term = #fw{id=Id, level=Level},
	{Term, Binary2}.

decode_achieve_info(Binary0)->
	{State, Binary1}=read_int32(Binary0),
	{Achieve_id, Binary2}=decode_ach_id(Binary1),
	{Finished, Binary3}=read_int32(Binary2),
	Term = #achieve_info{state=State, achieve_id=Achieve_id, finished=Finished},
	{Term, Binary3}.

decode_award_state(Binary0)->
	{State, Binary1}=read_int32(Binary0),
	{Id, Binary2}=read_int32(Binary1),
	Term = #award_state{state=State, id=Id},
	{Term, Binary2}.


%%初始化经验台副本
decode_init_instance_quality_c2s(Binary0)->
	{Instanceid, Binary1}=read_int32(Binary0),
	Term = #init_instance_quality_c2s{instanceid=Instanceid},
	Term.
%%经验太副本摔刷新
decode_refresh_instance_quality_c2s(Binary0)->
	{Usegold, Binary1}=read_int32(Binary0),
	{Auto, Binary2}=read_int32(Binary1),
	{Instanceid, Binary3}=read_int32(Binary2),
	{Maxqua, Binary4}=read_int32(Binary3),
	Term = #refresh_instance_quality_c2s{usegold=Usegold, auto=Auto, instanceid=Instanceid, maxqua=Maxqua},
	Term.
%%宠物刷新技能
decode_pet_skill_book_refresh_c2s(Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Moneytype, Binary2}=read_int32(Binary1),
	Term = #pet_skill_book_refresh_c2s{type=Type, moneytype=Moneytype},
	Term.
%%宠物抄写技能
decode_pet_get_skill_book_c2s(Binary0)->
	{Usegold, Binary1}=read_int32(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	Term = #pet_get_skill_book_c2s{usegold=Usegold, slot=Slot},
	Term.
%%宠物进阶
decode_pet_advance_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	Term = #pet_advance_c2s{petid=Petid},
	Term.
%%自动进阶
decode_pet_auto_advance_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	Term = #pet_auto_advance_c2s{petid=Petid},
	Term.
%%宠物天赋
%%天赋提升
decode_pet_talent_levelup_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Id, Binary2}=read_int32(Binary1),
	Term = #pet_talent_levelup_c2s{petid=Petid, id=Id},
	Term.
%%洗髓
decode_pet_xs_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Usegold, Binary2}=read_int32(Binary1),
	Term = #pet_xs_c2s{petid=Petid, usegold=Usegold},
	Term.
%%继承
decode_pet_inheritance_c2s(Binary0)->
	{Mainpet, Binary1}=read_int64(Binary0),
	{Secondpet, Binary2}=read_int64(Binary1),
	Term = #pet_inheritance_c2s{mainpet=Mainpet, secondpet=Secondpet},
	Term.
%%副本极寒
%%进入极寒冰域
decode_entry_loop_instance_c2s(Binary0)->
	{Layer, Binary1}=read_int32(Binary0),
	Term = #entry_loop_instance_c2s{layer=Layer},
	Term.

%%技能等级信息
decode_slv(Binary0)->
	{Level, Binary1}=read_int32(Binary0),
	{Skillid, Binary2}=read_int32(Binary1),
	Term = #slv{level=Level, skillid=Skillid},
	{Term, Binary2}.

%%一键学习技能
decode_skill_auto_learn_item_c2s(Binary0)->
	{Skillvo, Binary1}=decode_list(Binary0, fun decode_slv/1),
	Term = #skill_auto_learn_item_c2s{skillvo=Skillvo},
	Term.
%%帮助仓库初始化
decode_guild_storage_init_c2s(Binary0)->
	Term = #guild_storage_init_c2s{},
	Term.

%%帮会仓库中捐献确定按钮
decode_guild_storage_donate_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Count, Binary2}=read_int32(Binary1),
	Term = #guild_storage_donate_c2s{slot=Slot, count=Count},
	Term.
%%帮会仓库取出物品
decode_guild_storage_take_out_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Itemidh, Binary2}=read_int32(Binary1),
	{Itemidl, Binary3}=read_int32(Binary2),
	{Count, Binary4}=read_int32(Binary3),
	Term = #guild_storage_take_out_c2s{slot=Slot, itemidh=Itemidh, itemidl=Itemidl, count=Count},
	Term.

%%帮会仓库中仓库记录按钮
decode_guild_storage_log_c2s(Binary0)->
	Term = #guild_storage_log_c2s{},
	Term.
%%申请公会仓库物品
decode_guild_storage_apply_item_c2s(Binary0)->
	{Count, Binary1}=read_int32(Binary0),
	{Itemidh, Binary2}=read_int32(Binary1),
	{Itemidl, Binary3}=read_int32(Binary2),
	{Slot, Binary4}=read_int32(Binary3),
	Term = #guild_storage_apply_item_c2s{count=Count, itemidh=Itemidh, itemidl=Itemidl, slot=Slot},
	Term.
%%初始化批准申请
%%初始化批准申请
decode_guild_storage_init_apply_c2s(Binary0)->
	Term = #guild_storage_init_apply_c2s{},
	Term.
%%批准申请
decode_guild_storage_approve_apply_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Itemidh, Binary2}=read_int32(Binary1),
	{Itemidl, Binary3}=read_int32(Binary2),
	Term = #guild_storage_approve_apply_c2s{roleid=Roleid, itemidh=Itemidh, itemidl=Itemidl},
	Term.

%%拒绝
decode_guild_storage_refuse_apply_c2s(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Itemidh, Binary2}=read_int32(Binary1),
	{Itemidl, Binary3}=read_int32(Binary2),
	Term = #guild_storage_refuse_apply_c2s{roleid=Roleid, itemidh=Itemidh, itemidl=Itemidl},
	Term.

%%全部拒绝
decode_guild_storage_refuse_all_apply_c2s(Binary0)->
	Term = #guild_storage_refuse_all_apply_c2s{},
	Term.

%%分配物品
decode_guild_storage_distribute_item_c2s(Binary0)->
	{Itemidl, Binary1}=read_int32(Binary0),
	{Count, Binary2}=read_int32(Binary1),
	{Roleid, Binary3}=read_int64(Binary2),
	{Itemidh, Binary4}=read_int32(Binary3),
	{Slot, Binary5}=read_int32(Binary4),
	Term = #guild_storage_distribute_item_c2s{itemidl=Itemidl, count=Count, roleid=Roleid, itemidh=Itemidh, slot=Slot},
	Term.
%%帮会成员初始化申请列表
decode_guild_storage_self_apply_c2s(Binary0)->
	Term = #guild_storage_self_apply_c2s{},
	Term.
%%取消申请列表
decode_guild_storage_cancel_apply_c2s(Binary0)->
	{Itemidh, Binary1}=read_int32(Binary0),
	{Itemidl, Binary2}=read_int32(Binary1),
	Term = #guild_storage_cancel_apply_c2s{itemidh=Itemidh, itemidl=Itemidl},
	Term.

%%帮会仓库限制
decode_guild_storage_set_state_c2s(Binary0)->
	{State, Binary1}=decode_oprate_state(Binary0),
	Term = #guild_storage_set_state_c2s{state=State},
	Term.

%%
decode_oprate_state(Binary0)->
	{State, Binary1}=read_int32(Binary0),
	{Type, Binary2}=read_int32(Binary1),
	Term = #oprate_state{state=State, type=Type},
	{Term, Binary2}.

%%帮会仓库物品设为闲置状态
decode_guild_storage_set_item_state_c2s(Binary0)->
	{State, Binary1}=read_int32(Binary0),
	{Itemidh, Binary2}=read_int32(Binary1),
	{Itemidl, Binary3}=read_int32(Binary2),
	Term = #guild_storage_set_item_state_c2s{state=State, itemidh=Itemidh, itemidl=Itemidl},
	Term.

%%帮会仓库整理按钮
decode_guild_storage_sort_items_c2s(Binary0)->
	Term = #guild_storage_sort_items_c2s{},
	Term.
%%元宝开启
decode_pet_unlock_skill_c2s(Binary0)->
	{Petid, Binary1}=read_int64(Binary0),
	{Slot, Binary2}=read_int32(Binary1),
	Term = #pet_unlock_skill_c2s{petid=Petid, slot=Slot},
	Term.


%%飞剑功能开始
%%飞剑等级提升
decode_wing_level_up_c2s(Binary0)->
	Term = #wing_level_up_c2s{},
	Term.
%%飞剑进阶
decode_wing_phase_up_c2s(Binary0)->
	{Is_use_gold, Binary1}=read_int32(Binary0),
	Term = #wing_phase_up_c2s{is_use_gold=Is_use_gold},
	Term.

%%战场
%%
decode_travel_battle_all_result_s2c (Binary0)->
	{Result, Binary1}=decode_list(Binary0, fun decode_tpr/1),
	Term = #travel_battle_all_result_s2c {result=Result},
	Term.

%%飞剑品质提升
decode_wing_quality_up_c2s(Binary0)->
	Term = #wing_quality_up_c2s{},
	Term.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%丹药%%4月17日加【xiaowu】
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%请求丹药队列信息
encode_get_furnace_queue_info_c2s (Term)->
	Data = <<>>,
	<<2411:16, Data/binary>>.
%%相应丹药队列信息
encode_furnace_queue_info_s2c (Term)->
	Queues=encode_list(Term#furnace_queue_info_s2c.queues, fun encode_furnace_queue_info_unit/1),
	Data = <<Queues/binary>>,
	<<2413:16, Data/binary>>.
encode_furnace_queue_info_unit(Term)->
	Queueid=Term#furnace_queue_info_unit.queueid,
	Num=Term#furnace_queue_info_unit.num,
	Status=Term#furnace_queue_info_unit.status,
	Pillid=Term#furnace_queue_info_unit.pillid,
	Queue_remained_time=Term#furnace_queue_info_unit.queue_remained_time,
	Create_pill_remained_time=Term#furnace_queue_info_unit.create_pill_remained_time,
	Data = <<Queueid:32, Num:32, Status:32, Pillid:32, Queue_remained_time:32, Create_pill_remained_time:32>>,
	Data.
decode_furnace_queue_info_unit(Binary0)->
	{Queueid, Binary1}=read_int32(Binary0),
	{Num, Binary2}=read_int32(Binary1),
	{Status, Binary3}=read_int32(Binary2),
	{Pillid, Binary4}=read_int32(Binary3),
	{Queue_remained_time, Binary5}=read_int32(Binary4),
	{Create_pill_remained_time, Binary6}=read_int32(Binary5),
	Term = #furnace_queue_info_unit{queueid=Queueid, num=Num, status=Status, pillid=Pillid, queue_remained_time=Queue_remained_time, create_pill_remained_time=Create_pill_remained_time},
	{Term, Binary6}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%丹药%%xiaowu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%请求丹药队列信息
decode_get_furnace_queue_info_c2s (Binary0)->
	Term = #get_furnace_queue_info_c2s{},
	Term.
%%相应丹药队列信息
decode_furnace_queue_info_s2c (Binary0)->
	{Queues, Binary1}=decode_list(Binary0, fun decode_furnace_queue_info_unit/1),
	Term = #furnace_queue_info_s2c {queues=Queues},
	Term.
%%
decode_travel_battle_start_s2c (Binary0)->
	Term = #travel_battle_start_s2c {},
	Term.

%%飞剑强化
decode_wing_intensify_c2s(Binary0)->
	{Is_use_gold, Binary1}=read_int32(Binary0),
	Term = #wing_intensify_c2s{is_use_gold=Is_use_gold},
	Term.

%%开始炼丹
encode_create_pill_c2s (Term)->
	Pillid=Term#create_pill_c2s .pillid,
	Times=Term#create_pill_c2s .times,
	Data = <<Pillid:32, Times:32>>,
	<<2418:16, Data/binary>>.
%%开始炼丹
decode_create_pill_c2s (Binary0)->
	{Pillid, Binary1}=read_int32(Binary0),
	{Times, Binary2}=read_int32(Binary1),
	Term = #create_pill_c2s {pillid=Pillid, times=Times},
	Term.	
%%提取炼丹
encode_get_furnace_queue_item_c2s (Term)->
	Queueid=Term#get_furnace_queue_item_c2s .queueid,
	Data = <<Queueid:32>>,
	<<2412:16, Data/binary>>.	
%%提取炼丹
decode_get_furnace_queue_item_c2s (Binary0)->
	{Queueid, Binary1}=read_int32(Binary0),
	Term = #get_furnace_queue_item_c2s {queueid=Queueid},
	Term.	
%%炼丹加速
encode_accelerate_furnace_queue_c2s (Term)->
	Queueid=Term#accelerate_furnace_queue_c2s .queueid,
	Data = <<Queueid:32>>,
	<<2419:16, Data/binary>>.

%%飞剑洗练请求
decode_wing_enchant_c2s (Binary0)->
	{Type, Binary1}=read_int32(Binary0),
	{Lock_list, Binary2}=read_int32_list(Binary1),
	Term = #wing_enchant_c2s {type=Type, lock_list=Lock_list},
	Term.

decode_travel_battle_entry_c2s (Binary0)->
	Term = #travel_battle_entry_c2s {},
	Term.



%%洗练替换
decode_wing_enchant_replace_c2s (Binary0)->
	Term = #wing_enchant_replace_c2s {},
	Term.



%%炼丹加速
decode_accelerate_furnace_queue_c2s (Binary0)->
	{Queueid, Binary1}=read_int32(Binary0),
	Term = #accelerate_furnace_queue_c2s {queueid=Queueid},
	Term.

%%
decode_travel_battle_entry_s2c (Binary0)->
	{Remain_sec, Binary1}=read_int32(Binary0),
	Term = #travel_battle_entry_s2c {remain_sec=Remain_sec},
	Term.

%%丹药返回的信息
encode_pill_error_s2c (Term)->
	Errorid=Term#pill_error_s2c .errorid,
	Data = <<Errorid:32>>,
	<<2420:16, Data/binary>>.
%%

%%丹药返回的信息
decode_pill_error_s2c (Binary0)->
	{Errorid, Binary1}=read_int32(Binary0),
	Term = #pill_error_s2c {errorid=Errorid},
	Term.
%%终止炼丹
encode_quit_furnace_queue_c2s (Term)->
	Queueid=Term#quit_furnace_queue_c2s .queueid,
	Data = <<Queueid:32>>,
	<<2410:16, Data/binary>>.
%%终止炼丹
decode_quit_furnace_queue_c2s (Binary0)->
	{Queueid, Binary1}=read_int32(Binary0),
	Term = #quit_furnace_queue_c2s {queueid=Queueid},
	Term.
	
%%开启炼炉
encode_unlock_furnace_queue_c2s (Term)->
	Unlock_type=Term#unlock_furnace_queue_c2s .unlock_type,
	Queueid=Term#unlock_furnace_queue_c2s .queueid,
	Data = <<Unlock_type:32, Queueid:32>>,
	<<2416:16, Data/binary>>.
%%开启炼炉
decode_unlock_furnace_queue_c2s (Binary0)->
	{Unlock_type, Binary1}=read_int32(Binary0),
	{Queueid, Binary2}=read_int32(Binary1),
	Term = #unlock_furnace_queue_c2s {unlock_type=Unlock_type, queueid=Queueid},
	Term.

%%炼炉升级
encode_up_furnace_c2s (Term)->
	Auto_buy=encode_bool(Term#up_furnace_c2s .auto_buy),
	Data = <<Auto_buy/binary>>,
	<<2414:16, Data/binary>>.
%%炼炉升级
decode_up_furnace_c2s (Binary0)->
	{Auto_buy, Binary1}=read_int8(Binary0),
	Term = #up_furnace_c2s {auto_buy=Auto_buy},
	Term.

%%炼炉信息
encode_furnace_info_s2c (Term)->
	Level=Term#furnace_info_s2c .level,
	Data = <<Level:32>>,
	<<2415:16, Data/binary>>.
%%炼炉信息
decode_furnace_info_s2c (Binary0)->
	{Level, Binary1}=read_int32(Binary0),
	Term = #furnace_info_s2c {level=Level},
	Term.
%%炼丹信息
encode_pill_info_s2c (Term)->
	Pills=encode_list(Term#pill_info_s2c .pills, fun encode_pill/1),
	Data = <<Pills/binary>>,
	<<2417:16, Data/binary>>.
%%炼丹信息
decode_pill_info_s2c (Binary0)->
	{Pills, Binary1}=decode_list(Binary0, fun decode_pill/1),
	Term = #pill_info_s2c {pills=Pills},
	Term.	

encode_pill(Term)->
	Cur_value=Term#pill.cur_value,
	Pillid=Term#pill.pillid,
	Data = <<Cur_value:32, Pillid:32>>,
	Data.
decode_pill(Binary0)->
	{Cur_value, Binary1}=read_int32(Binary0),
	{Pillid, Binary2}=read_int32(Binary1),
	Term = #pill{cur_value=Cur_value, pillid=Pillid},
	{Term, Binary2}.
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%占星%%xiaowu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
encode_tss(Term)->
	Slot=Term#tss.slot,
	Tid=Term#tss.tid,
	Data = <<Slot:32, Tid:32>>,
	Data.

%%
decode_tss(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Tid, Binary2}=read_int32(Binary1),
	Term = #tss{slot=Slot, tid=Tid},
	{Term, Binary2}.

%%占星初始化
encode_astrology_init_c2s (Term)->
	Data = <<>>,
	<<2192:16, Data/binary>>.

%%占星初始化
decode_astrology_init_c2s (Binary0)->
	Term = #astrology_init_c2s {},
	Term.

%%占星初始化结果
encode_astrology_init_s2c (Term)->
	Objs=encode_list(Term#astrology_init_s2c .objs, fun encode_tss/1),
	Data = <<Objs/binary>>,
	<<2193:16, Data/binary>>.

%%占星初始化结果
decode_astrology_init_s2c (Binary0)->
	{Objs, Binary1}=decode_list(Binary0, fun decode_tss/1),
	Term = #astrology_init_s2c {objs=Objs},
	Term.

%%一键占星（多次的占星）,单独占星
encode_astrology_action_c2s(Term)->
	Position=Term#astrology_action_c2s.position,
	Data = <<Position:32>>,
	<<2190:16, Data/binary>>.

%%一键占星
decode_astrology_action_c2s(Binary0)->
	{Position, Binary1}=read_int32(Binary0),
	Term = #astrology_action_c2s{position=Position},
	Term.

%%一键占星结果
encode_astrology_action_s2c(Term)->
	Obj=encode_tss(Term#astrology_action_s2c.obj),
	Data = <<Obj/binary>>,
	<<2191:16, Data/binary>>.

%%一键占星结果
decode_astrology_action_s2c(Binary0)->
	{Obj, Binary1}=decode_tss(Binary0),
	Term = #astrology_action_s2c{obj=Obj},
	Term.

%%一键拾取
encode_astrology_pickup_all_c2s(Term)->
	Position=Term#astrology_pickup_all_c2s.position,
	Data = <<Position:32>>,
	<<2196:16, Data/binary>>.

%%一键拾取
decode_astrology_pickup_all_c2s(Binary0)->
	{Position, Binary1}=read_int32(Binary0),
	Term = #astrology_pickup_all_c2s{position=Position},
	Term.

%%一键拾取结果
encode_astrology_pickup_all_s2c(Term)->
	Slots=encode_int32_list(Term#astrology_pickup_all_s2c.slots),
	Data = <<Slots/binary>>,
	<<2197:16, Data/binary>>.

%%一键拾取结果
decode_astrology_pickup_all_s2c(Binary0)->
	{Slots, Binary1}=read_int32_list(Binary0),
	Term = #astrology_pickup_all_s2c{slots=Slots},
	Term.

%%一键卖出
encode_astrology_sale_all_c2s(Term)->
	Data = <<>>,
	<<2200:16, Data/binary>>.

%%一键卖出
decode_astrology_sale_all_c2s(Binary0)->
	Term = #astrology_sale_all_c2s{},
	Term.

%%一键卖出结果
encode_astrology_sale_all_s2c(Term)->
	Slots=encode_int32_list(Term#astrology_sale_all_s2c.slots),
	Data = <<Slots/binary>>,
	<<2201:16, Data/binary>>.

%%一键卖出结果
decode_astrology_sale_all_s2c(Binary0)->
	{Slots, Binary1}=read_int32_list(Binary0),
	Term = #astrology_sale_all_s2c{slots=Slots},
	Term.

%%充值补充星魂值
encode_astrology_add_money_c2s(Term)->
	Data = <<>>,
	<<2216:16, Data/binary>>.

%%补充星魂值
decode_astrology_add_money_c2s(Binary0)->
	Term = #astrology_add_money_c2s{},
	Term.

%%开面板定时补充星魂值
encode_astrology_open_panel_c2s(Term)->
	Data = <<>>,
	<<2100:16, Data/binary>>.


%%开面板定时补充星魂值
decode_astrology_open_panel_c2s(Binary0)->
	Term = #astrology_open_panel_c2s{},
	Term.

%%星魂值更新
encode_astrology_update_value_s2c(Term)->
	Value=Term#astrology_update_value_s2c.value,
	Data = <<Value:32>>,
	<<2217:16, Data/binary>>.

%%星魂值更新
decode_astrology_update_value_s2c(Binary0)->
	{Value, Binary1}=read_int32(Binary0),
	Term = #astrology_update_value_s2c{value=Value},
	Term.


%%
encode_astrology_money_and_pos_s2c(Term)->
	Money=Term#astrology_money_and_pos_s2c.money,
	Pos=Term#astrology_money_and_pos_s2c.pos,
	Data = <<Money:32, Pos:32>>,
	<<2202:16, Data/binary>>.

%%
decode_astrology_money_and_pos_s2c(Binary0)->
	{Money, Binary1}=read_int32(Binary0),
	{Pos, Binary2}=read_int32(Binary1),
	Term = #astrology_money_and_pos_s2c{money=Money, pos=Pos},
	Term.

%%
encode_astrology_error_s2c(Term)->
	Reason=Term#astrology_error_s2c.reason,
	Data = <<Reason:32>>,
	<<2209:16, Data/binary>>.

%%
decode_astrology_error_s2c(Binary0)->
	{Reason, Binary1}=read_int32(Binary0),
	Term = #astrology_error_s2c{reason=Reason},
	Term.

%%卖出
encode_astrology_sale_c2s(Term)->
	Slot=Term#astrology_sale_c2s.slot,
	Data = <<Slot:32>>,
	<<2198:16, Data/binary>>.

%%卖出
decode_astrology_sale_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #astrology_sale_c2s{slot=Slot},
	Term.

%%卖出结果
encode_astrology_sale_s2c(Term)->
	Slot=Term#astrology_sale_s2c.slot,
	Data = <<Slot:32>>,
	<<2199:16, Data/binary>>.

%%卖出结果
decode_astrology_sale_s2c(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #astrology_sale_s2c{slot=Slot},
	Term.

%%拾取
encode_astrology_pickup_c2s(Term)->
	Slot=Term#astrology_pickup_c2s.slot,
	Data = <<Slot:32>>,
	<<2194:16, Data/binary>>.

%%拾取
decode_astrology_pickup_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #astrology_pickup_c2s{slot=Slot},
	Term.


%%拾取结果
encode_astrology_pickup_s2c(Term)->
	Slot=Term#astrology_pickup_s2c.slot,
	Data = <<Slot:32>>,
	<<2195:16, Data/binary>>.

%%拾取结果
decode_astrology_pickup_s2c(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #astrology_pickup_s2c{slot=Slot},
	Term.

%%道具开启
encode_astrology_item_pos_c2s(Term)->
	Data = <<>>,
	<<2219:16, Data/binary>>.

%%道具开启
decode_astrology_item_pos_c2s(Binary0)->
	Term = #astrology_item_pos_c2s{},
	Term.

%%
encode_ss(Term)->
	Slot=Term#ss.slot,
	Level=Term#ss.level,
	Status=Term#ss.status,
	Id=Term#ss.id,
	Exp=Term#ss.exp,
	Quality=Term#ss.quality,
	Data = <<Slot:32, Level:32, Status:32, Id:32, Exp:32, Quality:32>>,
	Data.
%%
decode_ss(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	{Level, Binary2}=read_int32(Binary1),
	{Status, Binary3}=read_int32(Binary2),
	{Id, Binary4}=read_int32(Binary3),
	{Exp, Binary5}=read_int32(Binary4),
	{Quality, Binary6}=read_int32(Binary5),
	Term = #ss{slot=Slot, level=Level, status=Status, id=Id, exp=Exp, quality=Quality},
	{Term, Binary6}.

%%星座合成
encode_astrology_mix_c2s(Term)->
	To_slot=Term#astrology_mix_c2s.to_slot,
	From_slot=Term#astrology_mix_c2s.from_slot,
	Data = <<To_slot:32, From_slot:32>>,
	<<2203:16, Data/binary>>.

%%星座合成
decode_astrology_mix_c2s(Binary0)->
	{To_slot, Binary1}=read_int32(Binary0),
	{From_slot, Binary2}=read_int32(Binary1),
	Term = #astrology_mix_c2s{to_slot=To_slot, from_slot=From_slot},
	Term.

%%一键合成
encode_astrology_mix_all_c2s(Term)->
	To_slot=Term#astrology_mix_all_c2s.to_slot,
	From_slot=Term#astrology_mix_all_c2s.from_slot,
	Data = <<To_slot:32, From_slot:32>>,
	<<2204:16, Data/binary>>.

%%一键合成
decode_astrology_mix_all_c2s(Binary0)->
	{To_slot, Binary1}=read_int32(Binary0),
	{From_slot, Binary2}=read_int32(Binary1),
	Term = #astrology_mix_all_c2s{to_slot=To_slot, from_slot=From_slot},
	Term.

%%星座锁定
encode_astrology_lock_c2s(Term)->
	Slot=Term#astrology_lock_c2s.slot,
	Data = <<Slot:32>>,
	<<2205:16, Data/binary>>.

%%星座锁定
decode_astrology_lock_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #astrology_lock_c2s{slot=Slot},
	Term.


%%星座解锁
encode_astrology_unlock_c2s(Term)->
	Slot=Term#astrology_unlock_c2s.slot,
	Data = <<Slot:32>>,
	<<2206:16, Data/binary>>.

%%星座解锁
decode_astrology_unlock_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #astrology_unlock_c2s{slot=Slot},
	Term.

%%星座包裹大小
encode_astrology_package_size_s2c(Term)->
	Bodynum=Term#astrology_package_size_s2c.bodynum,
	Packnum=Term#astrology_package_size_s2c.packnum,
	Data = <<Bodynum:32, Packnum:32>>,
	<<2207:16, Data/binary>>.

%%星座包裹大小
decode_astrology_package_size_s2c(Binary0)->
	{Bodynum, Binary1}=read_int32(Binary0),
	{Packnum, Binary2}=read_int32(Binary1),
	Term = #astrology_package_size_s2c{bodynum=Bodynum, packnum=Packnum},
	Term.

%%星座包裹初始化
encode_astrology_init_package_s2c(Term)->
	Objs=encode_list(Term#astrology_init_package_s2c.objs, fun encode_ss/1),
	Data = <<Objs/binary>>,
	<<2208:16, Data/binary>>.

%%星座包裹初始化
decode_astrology_init_package_s2c(Binary0)->
	{Objs, Binary1}=decode_list(Binary0, fun decode_ss/1),
	Term = #astrology_init_package_s2c{objs=Objs},
	Term.

%%星座添加(人物身上)
encode_astrology_add_s2c(Term)->
	Objs=encode_list(Term#astrology_add_s2c.objs, fun encode_ss/1),
	Data = <<Objs/binary>>,
	<<2211:16, Data/binary>>.

%%星座添加
decode_astrology_add_s2c(Binary0)->
	{Objs, Binary1}=decode_list(Binary0, fun decode_ss/1),
	Term = #astrology_add_s2c{objs=Objs},
	Term.

%%删除星座
encode_astrology_delete_s2c(Term)->
	Slots=encode_int32_list(Term#astrology_delete_s2c.slots),
	Data = <<Slots/binary>>,
	<<2212:16, Data/binary>>.

%%删除星座
decode_astrology_delete_s2c(Binary0)->
	{Slots, Binary1}=read_int32_list(Binary0),
	Term = #astrology_delete_s2c{slots=Slots},
	Term.

%%更新星座
encode_astrology_update_s2c(Term)->
	Obj=encode_ss(Term#astrology_update_s2c.obj),
	Data = <<Obj/binary>>,
	<<2213:16, Data/binary>>.

%%更新星座
decode_astrology_update_s2c(Binary0)->
	{Obj, Binary1}=decode_ss(Binary0),
	Term = #astrology_update_s2c{obj=Obj},
	Term.

%%扩展星魂包裹
encode_astrology_expand_package_c2s(Term)->
	Data = <<>>,
	<<2214:16, Data/binary>>.

%%扩展星魂包裹
decode_astrology_expand_package_c2s(Binary0)->
	Term = #astrology_expand_package_c2s{},
	Term.

%%
encode_astrology_swap_c2s(Term)->
	Desslot=Term#astrology_swap_c2s.desslot,
	Srcslot=Term#astrology_swap_c2s.srcslot,
	Data = <<Desslot:32, Srcslot:32>>,
	<<2215:16, Data/binary>>.

%%
decode_astrology_swap_c2s(Binary0)->
	{Desslot, Binary1}=read_int32(Binary0),
	{Srcslot, Binary2}=read_int32(Binary1),
	Term = #astrology_swap_c2s{desslot=Desslot, srcslot=Srcslot},
	Term.

%%
encode_other_astrology_info_s2c(Term)->
	Value=Term#other_astrology_info_s2c.value,
	Objs=encode_list(Term#other_astrology_info_s2c.objs, fun encode_ss/1),
	Packnum=Term#other_astrology_info_s2c.packnum,
	Data = <<Value:32, Objs/binary, Packnum:32>>,
	<<2218:16, Data/binary>>.

%%
decode_other_astrology_info_s2c(Binary0)->
	{Value, Binary1}=read_int32(Binary0),
	{Objs, Binary2}=decode_list(Binary1, fun decode_ss/1),
	{Packnum, Binary3}=read_int32(Binary2),
	Term = #other_astrology_info_s2c{value=Value, objs=Objs, packnum=Packnum},
	Term.

%%
encode_astrology_active_c2s(Term)->
	Slot=Term#astrology_active_c2s.slot,
	Data = <<Slot:32>>,
	<<2220:16, Data/binary>>.

%%
decode_astrology_active_c2s(Binary0)->
	{Slot, Binary1}=read_int32(Binary0),
	Term = #astrology_active_c2s{slot=Slot},
	Term.
%%
decode_travel_battle_leave_c2s (Binary0)->
	Term = #travel_battle_leave_c2s {},
	Term.

%%
decode_travel_battle_leave_s2c (Binary0)->
	Term = #travel_battle_leave_s2c {},
	Term.

%%
decode_travel_battle_stop_s2c (Binary0)->
	Term = #travel_battle_stop_s2c {},
	Term.

%%
decode_travel_battle_reward_s2c (Binary0)->
	Term = #travel_battle_reward_s2c {},
	Term.

%%
decode_travel_battle_all_result_c2s (Binary0)->
	Term = #travel_battle_all_result_c2s {},
	Term.

%%
decode_travel_battle_player_info_s2c (Binary0)->
	{Players, Binary1}=decode_list(Binary0, fun decode_tpi/1),
	{Killinfo, Binary2}=decode_list(Binary1, fun decode_cbk/1),
	{Bekilledinfo, Binary3}=decode_list(Binary2, fun decode_cbbk/1),
	Term = #travel_battle_player_info_s2c {players=Players, killinfo=Killinfo, bekilledinfo=Bekilledinfo},
	Term.

%%
decode_travel_battle_add_player_info_s2c (Binary0)->
	{Player, Binary1}=decode_list(Binary0, fun decode_tpi/1),
	Term = #travel_battle_add_player_info_s2c {player=Player},
	Term.

%%
decode_travel_battle_reward_c2s (Binary0)->
	Term = #travel_battle_reward_c2s {},
	Term.

%%
decode_travel_battle_opt_s2c (Binary0)->
	{Optno, Binary1}=read_int32(Binary0),
	Term = #travel_battle_opt_s2c {optno=Optno},
	Term.

%%
decode_travel_battle_update_score_s2c (Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Newscore, Binary2}=read_int32(Binary1),
	Term = #travel_battle_update_score_s2c {roleid=Roleid, newscore=Newscore},
	Term.

%%
decode_travel_battle_self_result_c2s (Binary0)->
	Term = #travel_battle_self_result_c2s {},
	Term.

%%
decode_travel_battle_self_result_s2c (Binary0)->
	{Players, Binary1}=decode_list(Binary0, fun decode_tpi/1),
	{Killinfo, Binary2}=decode_list(Binary1, fun decode_cbk/1),
	{Bekilledinfo, Binary3}=decode_list(Binary2, fun decode_cbbk/1),
	Term = #travel_battle_self_result_s2c {players=Players, killinfo=Killinfo, bekilledinfo=Bekilledinfo},
	Term.

%%
decode_travel_battle_killinfo_update_s2c (Binary0)->
	{Killinfo, Binary1}=decode_list(Binary0, fun decode_cbk/1),
	Term = #travel_battle_killinfo_update_s2c {killinfo=Killinfo},
	Term.

%%
decode_travel_battle_bekillinfo_update_s2c (Binary0)->
	{Bekilledinfo, Binary1}=decode_list(Binary0, fun decode_cbbk/1),
	Term = #travel_battle_bekillinfo_update_s2c {bekilledinfo=Bekilledinfo},
	Term.

%%
decode_travel_battle_next_time_s2c (Binary0)->
	{Month, Binary1}=read_int32(Binary0),
	{Hour, Binary2}=read_int32(Binary1),
	{Min, Binary3}=read_int32(Binary2),
	{Day, Binary4}=read_int32(Binary3),
	{Year, Binary5}=read_int32(Binary4),
	Term = #travel_battle_next_time_s2c {month=Month, hour=Hour, min=Min, day=Day, year=Year},
	Term.

%%
decode_tpr(Binary0)->
	{Battleid, Binary1}=read_int32(Binary0),
	{Roleinfo, Binary2}=decode_list(Binary1, fun decode_tpei/1),
	Term = #tpr{battleid=Battleid, roleinfo=Roleinfo},
	{Term, Binary2}.

%%
decode_travel_battle_forecast_s2c (Binary0)->
	{Remain_s, Binary1}=read_int32(Binary0),
	Term = #travel_battle_forecast_s2c {remain_s=Remain_s},
	Term.

%%
decode_cbbk(Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	{Num, Binary2}=read_int32(Binary1),
	{Serverid, Binary3}=read_int32(Binary2),
	Term = #cbbk{roleid=Roleid, num=Num, serverid=Serverid},
	{Term, Binary3}.

%%
decode_cbk(Binary0)->
	{H, Binary1}=read_int32(Binary0),
	{Name, Binary2}=read_string(Binary1),
	{M, Binary3}=read_int32(Binary2),
	{Value, Binary4}=read_int32(Binary3),
	{Score, Binary5}=read_int32(Binary4),
	{S, Binary6}=read_int32(Binary5),
	{Type, Binary7}=read_int32(Binary6),
	{Id, Binary8}=read_int64(Binary7),
	{Serverid, Binary9}=read_int32(Binary8),
	Term = #cbk{h=H, name=Name, m=M, value=Value, score=Score, s=S, type=Type, id=Id, serverid=Serverid},
	{Term, Binary9}.

%%
decode_tpi(Binary0)->
	{Ff, Binary1}=read_int32(Binary0),
	{Gender, Binary2}=read_int32(Binary1),
	{Level, Binary3}=read_int32(Binary2),
	{Equiset, Binary4}=read_int32(Binary3),
	{Roleid, Binary5}=read_int64(Binary4),
	{Score, Binary6}=read_int32(Binary5),
	{Entryindex, Binary7}=read_int32(Binary6),
	{Classtype, Binary8}=read_int32(Binary7),
	{Name, Binary9}=read_string(Binary8),
	{Serverid, Binary10}=read_int32(Binary9),
	Term = #tpi{ff=Ff, gender=Gender, level=Level, equiset=Equiset, roleid=Roleid, score=Score, entryindex=Entryindex, classtype=Classtype, name=Name, serverid=Serverid},
	{Term, Binary10}.

%%
decode_tpei(Binary0)->
	{Items, Binary1}=decode_list(Binary0, fun decode_i/1),
	{Role, Binary2}=decode_tpi(Binary1),
	{Cloth, Binary3}=read_int32(Binary2),
	{Arm, Binary4}=read_int32(Binary3),
	Term = #tpei{items=Items, role=Role, cloth=Cloth, arm=Arm},
	{Term, Binary4}.

%%
decode_gbr(Binary0)->
	{Score, Binary1}=read_int32(Binary0),
	{Rank, Binary2}=read_int32(Binary1),
	{Guildname, Binary3}=read_string(Binary2),
	Term = #gbr{score=Score, rank=Rank, guildname=Guildname},
	{Term, Binary3}.

%%
decode_guild_battlefield_info_s2c (Binary0)->
	{Rankinfo, Binary1}=decode_list(Binary0, fun decode_gbr/1),
	Term = #guild_battlefield_info_s2c {rankinfo=Rankinfo},
	Term.

%%
decode_battlefield_info_error_s2c (Binary0)->
	{Error, Binary1}=read_int32(Binary0),
	Term = #battlefield_info_error_s2c {error=Error},
	Term.

%%
decode_battlefield_totle_info_s2c (Binary0)->
	{Gbinfo, Binary1}=decode_list(Binary0, fun decode_gbt/1),
	Term = #battlefield_totle_info_s2c {gbinfo=Gbinfo},
	Term.

%%
decode_gbt(Binary0)->
	{Rankscore, Binary1}=read_int32(Binary0),
	{Yhzqscore, Binary2}=read_int32(Binary1),
	{Index, Binary3}=read_int32(Binary2),
	{Score, Binary4}=read_int32(Binary3),
	{Name, Binary5}=read_string(Binary4),
	{Jszdscore, Binary6}=read_int32(Binary5),
	Term = #gbt{rankscore=Rankscore, yhzqscore=Yhzqscore, index=Index, score=Score, name=Name, jszdscore=Jszdscore},
	{Term, Binary6}.

%%
decode_yhzq_battlefield_info_s2c (Binary0)->
	{Gbinfo, Binary1}=decode_list(Binary0, fun decode_gbw/1),
	Term = #yhzq_battlefield_info_s2c {gbinfo=Gbinfo},
	Term.

%%
decode_gbw(Binary0)->
	{Losenum, Binary1}=read_int32(Binary0),
	{Score, Binary2}=read_int32(Binary1),
	{Index, Binary3}=read_int32(Binary2),
	{Winnum, Binary4}=read_int32(Binary3),
	{Name, Binary5}=read_string(Binary4),
	Term = #gbw{losenum=Losenum, score=Score, index=Index, winnum=Winnum, name=Name},
	{Term, Binary5}.

%%
decode_camp_battle_start_s2c (Binary0)->
	Term = #camp_battle_start_s2c {},
	Term.

%%
decode_camp_battle_stop_s2c (Binary0)->
	Term = #camp_battle_stop_s2c {},
	Term.

%%
decode_camp_battle_entry_c2s (Binary0)->
	Term = #camp_battle_entry_c2s {},
	Term.

%%
decode_camp_battle_entry_s2c (Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	Term = #camp_battle_entry_s2c {result=Result},
	Term.

%%
decode_camp_battle_leave_c2s (Binary0)->
	Term = #camp_battle_leave_c2s {},
	Term.

%%
decode_camp_battle_leave_s2c (Binary0)->
	{Result, Binary1}=read_int32(Binary0),
	Term = #camp_battle_leave_s2c {result=Result},
	Term.

%%
decode_camp_battle_init_s2c (Binary0)->
	{Deserters, Binary1}=decode_list(Binary0, fun decode_fbr/1),
	{Campbnum, Binary2}=read_int32(Binary1),
	{Campanum, Binary3}=read_int32(Binary2),
	{Lefttime_s, Binary4}=read_int32(Binary3),
	{Campbscore, Binary5}=read_int32(Binary4),
	{Campascore, Binary6}=read_int32(Binary5),
	{Roles, Binary7}=decode_list(Binary6, fun decode_fbr/1),
	Term = #camp_battle_init_s2c {deserters=Deserters, campbnum=Campbnum, campanum=Campanum, lefttime_s=Lefttime_s, campbscore=Campbscore, campascore=Campascore, roles=Roles},
	Term.

%%
decode_camp_battle_otherrole_update_s2c (Binary0)->
	{Campscore, Binary1}=read_int32(Binary0),
	{Camp, Binary2}=read_int32(Binary1),
	{Roleid, Binary3}=read_int64(Binary2),
	{Newscore, Binary4}=read_int32(Binary3),
	Term = #camp_battle_otherrole_update_s2c {campscore=Campscore, camp=Camp, roleid=Roleid, newscore=Newscore},
	Term.

%%
decode_camp_battle_otherrole_init_s2c (Binary0)->
	{Role, Binary1}=decode_list(Binary0, fun decode_fbr/1),
	Term = #camp_battle_otherrole_init_s2c {role=Role},
	Term.

%%
decode_camp_battle_otherrole_leave_s2c (Binary0)->
	{Roleid, Binary1}=read_int64(Binary0),
	Term = #camp_battle_otherrole_leave_s2c {roleid=Roleid},
	Term.

%%
decode_camp_battle_info_update_s2c (Binary0)->
	{Campbscore, Binary1}=read_int32(Binary0),
	{Campascore, Binary2}=read_int32(Binary1),
	Term = #camp_battle_info_update_s2c {campbscore=Campbscore, campascore=Campascore},
	Term.

%%
decode_camp_battle_record_init_s2c (Binary0)->
	{Bekilled, Binary1}=decode_list(Binary0, fun decode_cbbk/1),
	{Kill, Binary2}=decode_list(Binary1, fun decode_cbk/1),
	Term = #camp_battle_record_init_s2c {bekilled=Bekilled, kill=Kill},
	Term.

%%
decode_camp_battle_record_update_s2c (Binary0)->
	{Bekilled, Binary1}=decode_list(Binary0, fun decode_cbbk/1),
	{Kill, Binary2}=decode_list(Binary1, fun decode_cbk/1),
	Term = #camp_battle_record_update_s2c {bekilled=Bekilled, kill=Kill},
	Term.

%%
decode_camp_battle_result_s2c (Binary0)->
	{Items, Binary1}=decode_list(Binary0, fun decode_l/1),
	{Honor, Binary2}=read_int32(Binary1),
	{Exp, Binary3}=read_int32(Binary2),
	{Winner, Binary4}=read_int32(Binary3),
	Term = #camp_battle_result_s2c {items=Items, honor=Honor, exp=Exp, winner=Winner},
	Term.

%%国王资格战中查看帮战信息
decode_camp_battle_player_num_c2s (Binary0)->
	Term = #camp_battle_player_num_c2s {},
	Term.

%%
decode_camp_battle_player_num_s2c (Binary0)->
	{Playnum, Binary1}=decode_list(Binary0, fun decode_cbpn/1),
	Term = #camp_battle_player_num_s2c {playnum=Playnum},
	Term.

%%
decode_camp_battle_last_record_c2s (Binary0)->
	Term = #camp_battle_last_record_c2s {},
	Term.

%%
decode_camp_battle_last_record_s2c (Binary0)->
	{Bekilled, Binary1}=decode_list(Binary0, fun decode_cbbk/1),
	{Campbnum, Binary2}=read_int32(Binary1),
	{Campanum, Binary3}=read_int32(Binary2),
	{Campbscore, Binary4}=read_int32(Binary3),
	{Deserters, Binary5}=decode_list(Binary4, fun decode_fbr/1),
	{Campascore, Binary6}=read_int32(Binary5),
	{Roles, Binary7}=decode_list(Binary6, fun decode_fbr/1),
	{Kill, Binary8}=decode_list(Binary7, fun decode_cbk/1),
	Term = #camp_battle_last_record_s2c {bekilled=Bekilled, campbnum=Campbnum, campanum=Campanum, campbscore=Campbscore, deserters=Deserters, campascore=Campascore, roles=Roles, kill=Kill},
	Term.

%%
decode_fbr(Binary0)->
	{Rolename, Binary1}=read_string(Binary0),
	{Rolelevel, Binary2}=read_int32(Binary1),
	{Guildhid, Binary3}=read_int32(Binary2),
	{Roleid, Binary4}=read_int64(Binary3),
	{Score, Binary5}=read_int32(Binary4),
	{Guildlid, Binary6}=read_int32(Binary5),
	{Camp, Binary7}=read_int32(Binary6),
	{Roleclass, Binary8}=read_int32(Binary7),
	{Guildname, Binary9}=read_string(Binary8),
	Term = #fbr{rolename=Rolename, rolelevel=Rolelevel, guildhid=Guildhid, roleid=Roleid, score=Score, guildlid=Guildlid, camp=Camp, roleclass=Roleclass, guildname=Guildname},
	{Term, Binary9}.

%%
decode_camp_battle_opt_s2c (Binary0)->
	{Errno, Binary1}=read_int32(Binary0),
	Term = #camp_battle_opt_s2c {errno=Errno},
	Term.

%%
decode_cbpn(Binary0)->
	{Max, Binary1}=read_int32(Binary0),
	{Total, Binary2}=read_int32(Binary1),
	{Type, Binary3}=read_int32(Binary2),
	Term = #cbpn{max=Max, total=Total, type=Type},
	{Term, Binary3}.

%%
decode_jszd_battlefield_info_s2c (Binary0)->
	{Killnum, Binary1}=read_int32(Binary0),
	{Gbinfo, Binary2}=decode_list(Binary1, fun decode_gbw/1),
	{Honor, Binary3}=read_int32(Binary2),
	{Score, Binary4}=read_int32(Binary3),
	Term = #jszd_battlefield_info_s2c {killnum=Killnum, gbinfo=Gbinfo, honor=Honor, score=Score},
	Term.

%%
decode_notify_all_battle_end_s2c (Binary0)->
	{Battle, Binary1}=read_int32(Binary0),
	Term = #notify_all_battle_end_s2c {battle=Battle},
	Term.

%%神行刷新结果
decode_refresh_everquest_result_s2c(Binary0)->
	{Freetime, Binary1}=read_int32(Binary0),
	{Sliver, Binary2}=read_int32(Binary1),
	{Itemcount, Binary3}=read_int32(Binary2),
	Term = #refresh_everquest_result_s2c{freetime=Freetime, sliver=Sliver, itemcount=Itemcount},
	Term.

%%
encode_camp_battle_start_s2c (Term)->
	Data = <<>>,
	<<1850:16, Data/binary>>.

%%
encode_camp_battle_stop_s2c (Term)->
	Data = <<>>,
	<<1851:16, Data/binary>>.

%%
encode_camp_battle_entry_c2s (Term)->
	Data = <<>>,
	<<1852:16, Data/binary>>.

%%
encode_camp_battle_entry_s2c (Term)->
	Result=Term#camp_battle_entry_s2c .result,
	Data = <<Result:32>>,
	<<1853:16, Data/binary>>.

%%
encode_camp_battle_leave_c2s (Term)->
	Data = <<>>,
	<<1854:16, Data/binary>>.

%%
encode_camp_battle_leave_s2c (Term)->
	Result=Term#camp_battle_leave_s2c .result,
	Data = <<Result:32>>,
	<<1855:16, Data/binary>>.

%%
encode_camp_battle_init_s2c (Term)->
	Deserters=encode_list(Term#camp_battle_init_s2c .deserters, fun encode_fbr/1),
	Campbnum=Term#camp_battle_init_s2c .campbnum,
	Campanum=Term#camp_battle_init_s2c .campanum,
	Lefttime_s=Term#camp_battle_init_s2c .lefttime_s,
	Campbscore=Term#camp_battle_init_s2c .campbscore,
	Campascore=Term#camp_battle_init_s2c .campascore,
	Roles=encode_list(Term#camp_battle_init_s2c .roles, fun encode_fbr/1),
	Data = <<Deserters/binary, Campbnum:32, Campanum:32, Lefttime_s:32, Campbscore:32, Campascore:32, Roles/binary>>,
	<<1856:16, Data/binary>>.

%%
encode_camp_battle_otherrole_update_s2c (Term)->
	Campscore=Term#camp_battle_otherrole_update_s2c .campscore,
	Camp=Term#camp_battle_otherrole_update_s2c .camp,
	Roleid=Term#camp_battle_otherrole_update_s2c .roleid,
	Newscore=Term#camp_battle_otherrole_update_s2c .newscore,
	Data = <<Campscore:32, Camp:32, Roleid:64, Newscore:32>>,
	<<1857:16, Data/binary>>.

%%
encode_camp_battle_otherrole_init_s2c (Term)->
	Role=encode_list(Term#camp_battle_otherrole_init_s2c .role, fun encode_fbr/1),
	Data = <<Role/binary>>,
	<<1858:16, Data/binary>>.

%%
encode_camp_battle_otherrole_leave_s2c (Term)->
	Roleid=Term#camp_battle_otherrole_leave_s2c .roleid,
	Data = <<Roleid:64>>,
	<<1859:16, Data/binary>>.

%%
encode_camp_battle_info_update_s2c (Term)->
	Campbscore=Term#camp_battle_info_update_s2c .campbscore,
	Campascore=Term#camp_battle_info_update_s2c .campascore,
	Data = <<Campbscore:32, Campascore:32>>,
	<<1860:16, Data/binary>>.

%%
encode_camp_battle_record_init_s2c (Term)->
	Bekilled=encode_list(Term#camp_battle_record_init_s2c .bekilled, fun encode_cbbk/1),
	Kill=encode_list(Term#camp_battle_record_init_s2c .kill, fun encode_cbk/1),
	Data = <<Bekilled/binary, Kill/binary>>,
	<<1861:16, Data/binary>>.

%%
encode_camp_battle_record_update_s2c (Term)->
	Bekilled=encode_list(Term#camp_battle_record_update_s2c .bekilled, fun encode_cbbk/1),
	Kill=encode_list(Term#camp_battle_record_update_s2c .kill, fun encode_cbk/1),
	Data = <<Bekilled/binary, Kill/binary>>,
	<<1862:16, Data/binary>>.

%%
encode_camp_battle_result_s2c (Term)->
	Items=encode_list(Term#camp_battle_result_s2c .items, fun encode_l/1),
	Honor=Term#camp_battle_result_s2c .honor,
	Exp=Term#camp_battle_result_s2c .exp,
	Winner=Term#camp_battle_result_s2c .winner,
	Data = <<Items/binary, Honor:32, Exp:32, Winner:32>>,
	<<1863:16, Data/binary>>.

%%国王资格战中查看帮战信息
encode_camp_battle_player_num_c2s (Term)->
	Data = <<>>,
	<<1864:16, Data/binary>>.

%%
encode_camp_battle_player_num_s2c (Term)->
	Playnum=encode_list(Term#camp_battle_player_num_s2c .playnum, fun encode_cbpn/1),
	Data = <<Playnum/binary>>,
	<<1865:16, Data/binary>>.

%%
encode_camp_battle_last_record_c2s (Term)->
	Data = <<>>,
	<<1866:16, Data/binary>>.

%%
encode_camp_battle_last_record_s2c (Term)->
	Bekilled=encode_list(Term#camp_battle_last_record_s2c .bekilled, fun encode_cbbk/1),
	Campbnum=Term#camp_battle_last_record_s2c .campbnum,
	Campanum=Term#camp_battle_last_record_s2c .campanum,
	Campbscore=Term#camp_battle_last_record_s2c .campbscore,
	Deserters=encode_list(Term#camp_battle_last_record_s2c .deserters, fun encode_fbr/1),
	Campascore=Term#camp_battle_last_record_s2c .campascore,
	Roles=encode_list(Term#camp_battle_last_record_s2c .roles, fun encode_fbr/1),
	Kill=encode_list(Term#camp_battle_last_record_s2c .kill, fun encode_cbk/1),
	Data = <<Bekilled/binary, Campbnum:32, Campanum:32, Campbscore:32, Deserters/binary, Campascore:32, Roles/binary, Kill/binary>>,
	<<1867:16, Data/binary>>.

%%
encode_camp_battle_opt_s2c (Term)->
	Errno=Term#camp_battle_opt_s2c .errno,
	Data = <<Errno:32>>,
	<<1868:16, Data/binary>>.

%%
encode_travel_battle_all_result_s2c (Term)->
	Result=encode_list(Term#travel_battle_all_result_s2c .result, fun encode_tpr/1),
	Data = <<Result/binary>>,
	<<1918:16, Data/binary>>.

%%
encode_travel_battle_start_s2c (Term)->
	Data = <<>>,
	<<1910:16, Data/binary>>.

%%
encode_travel_battle_entry_c2s (Term)->
	Data = <<>>,
	<<1911:16, Data/binary>>.

%%
encode_travel_battle_entry_s2c (Term)->
	Remain_sec=Term#travel_battle_entry_s2c .remain_sec,
	Data = <<Remain_sec:32>>,
	<<1912:16, Data/binary>>.

%%
encode_travel_battle_leave_c2s (Term)->
	Data = <<>>,
	<<1913:16, Data/binary>>.

%%
encode_travel_battle_leave_s2c (Term)->
	Data = <<>>,
	<<1914:16, Data/binary>>.

%%
encode_travel_battle_stop_s2c (Term)->
	Data = <<>>,
	<<1915:16, Data/binary>>.

%%
encode_travel_battle_reward_s2c (Term)->
	Data = <<>>,
	<<1916:16, Data/binary>>.

%%
encode_travel_battle_all_result_c2s (Term)->
	Data = <<>>,
	<<1917:16, Data/binary>>.

%%
encode_travel_battle_player_info_s2c (Term)->
	Players=encode_list(Term#travel_battle_player_info_s2c .players, fun encode_tpi/1),
	Killinfo=encode_list(Term#travel_battle_player_info_s2c .killinfo, fun encode_cbk/1),
	Bekilledinfo=encode_list(Term#travel_battle_player_info_s2c .bekilledinfo, fun encode_cbbk/1),
	Data = <<Players/binary, Killinfo/binary, Bekilledinfo/binary>>,
	<<1919:16, Data/binary>>.

%%
encode_travel_battle_add_player_info_s2c (Term)->
	Player=encode_list(Term#travel_battle_add_player_info_s2c .player, fun encode_tpi/1),
	Data = <<Player/binary>>,
	<<1920:16, Data/binary>>.

%%
encode_travel_battle_reward_c2s (Term)->
	Data = <<>>,
	<<1921:16, Data/binary>>.

%%
encode_travel_battle_opt_s2c (Term)->
	Optno=Term#travel_battle_opt_s2c .optno,
	Data = <<Optno:32>>,
	<<1922:16, Data/binary>>.

%%
encode_travel_battle_update_score_s2c (Term)->
	Roleid=Term#travel_battle_update_score_s2c .roleid,
	Newscore=Term#travel_battle_update_score_s2c .newscore,
	Data = <<Roleid:64, Newscore:32>>,
	<<1923:16, Data/binary>>.

%%
encode_travel_battle_self_result_c2s (Term)->
	Data = <<>>,
	<<1924:16, Data/binary>>.

%%
encode_travel_battle_self_result_s2c (Term)->
	Players=encode_list(Term#travel_battle_self_result_s2c .players, fun encode_tpi/1),
	Killinfo=encode_list(Term#travel_battle_self_result_s2c .killinfo, fun encode_cbk/1),
	Bekilledinfo=encode_list(Term#travel_battle_self_result_s2c .bekilledinfo, fun encode_cbbk/1),
	Data = <<Players/binary, Killinfo/binary, Bekilledinfo/binary>>,
	<<1925:16, Data/binary>>.

%%
encode_travel_battle_killinfo_update_s2c (Term)->
	Killinfo=encode_list(Term#travel_battle_killinfo_update_s2c .killinfo, fun encode_cbk/1),
	Data = <<Killinfo/binary>>,
	<<1926:16, Data/binary>>.

%%
encode_travel_battle_bekillinfo_update_s2c (Term)->
	Bekilledinfo=encode_list(Term#travel_battle_bekillinfo_update_s2c .bekilledinfo, fun encode_cbbk/1),
	Data = <<Bekilledinfo/binary>>,
	<<1927:16, Data/binary>>.

%%
encode_travel_battle_next_time_s2c (Term)->
	Month=Term#travel_battle_next_time_s2c .month,
	Hour=Term#travel_battle_next_time_s2c .hour,
	Min=Term#travel_battle_next_time_s2c .min,
	Day=Term#travel_battle_next_time_s2c .day,
	Year=Term#travel_battle_next_time_s2c .year,
	Data = <<Month:32, Hour:32, Min:32, Day:32, Year:32>>,
	<<1928:16, Data/binary>>.

%%
encode_travel_battle_forecast_s2c (Term)->
	Remain_s=Term#travel_battle_forecast_s2c .remain_s,
	Data = <<Remain_s:32>>,
	<<1929:16, Data/binary>>.

%%
encode_tpr(Term)->
	Battleid=Term#tpr.battleid,
	Roleinfo=encode_list(Term#tpr.roleinfo, fun encode_tpei/1),
	Data = <<Battleid:32, Roleinfo/binary>>,
	Data.

%%
encode_cbbk(Term)->
	Roleid=Term#cbbk.roleid,
	Num=Term#cbbk.num,
	Serverid=Term#cbbk.serverid,
	Data = <<Roleid:64, Num:32, Serverid:32>>,
	Data.

%%
encode_cbk(Term)->
	H=Term#cbk.h,
	Name=encode_string(Term#cbk.name),
	M=Term#cbk.m,
	Value=Term#cbk.value,
	Score=Term#cbk.score,
	S=Term#cbk.s,
	Type=Term#cbk.type,
	Id=Term#cbk.id,
	Serverid=Term#cbk.serverid,
	Data = <<H:32, Name/binary, M:32, Value:32, Score:32, S:32, Type:32, Id:64, Serverid:32>>,
	Data.

%%
encode_tpi(Term)->
	Ff=Term#tpi.ff,
	Gender=Term#tpi.gender,
	Level=Term#tpi.level,
	Equiset=Term#tpi.equiset,
	Roleid=Term#tpi.roleid,
	Score=Term#tpi.score,
	Entryindex=Term#tpi.entryindex,
	Classtype=Term#tpi.classtype,
	Name=encode_string(Term#tpi.name),
	Serverid=Term#tpi.serverid,
	Data = <<Ff:32, Gender:32, Level:32, Equiset:32, Roleid:64, Score:32, Entryindex:32, Classtype:32, Name/binary, Serverid:32>>,
	Data.

%%
encode_tpei(Term)->
	Items=encode_list(Term#tpei.items, fun encode_i/1),
	Role=encode_tpi(Term#tpei.role),
	Cloth=Term#tpei.cloth,
	Arm=Term#tpei.arm,
	Data = <<Items/binary, Role/binary, Cloth:32, Arm:32>>,
	Data.

%%
encode_guild_battlefield_info_s2c (Term)->
	Rankinfo=encode_list(Term#guild_battlefield_info_s2c .rankinfo, fun encode_gbr/1),
	Data = <<Rankinfo/binary>>,
	<<1087:16, Data/binary>>.

%%
encode_gbr(Term)->
	Score=Term#gbr.score,
	Rank=Term#gbr.rank,
	Guildname=encode_string(Term#gbr.guildname),
	Data = <<Score:32, Rank:32, Guildname/binary>>,
	Data.

%%
encode_battlefield_info_error_s2c (Term)->
	Error=Term#battlefield_info_error_s2c .error,
	Data = <<Error:32>>,
	<<1089:16, Data/binary>>.

%%
encode_battlefield_totle_info_s2c (Term)->
	Gbinfo=encode_list(Term#battlefield_totle_info_s2c .gbinfo, fun encode_gbt/1),
	Data = <<Gbinfo/binary>>,
	<<1090:16, Data/binary>>.

%%
encode_gbt(Term)->
	Rankscore=Term#gbt.rankscore,
	Yhzqscore=Term#gbt.yhzqscore,
	Index=Term#gbt.index,
	Score=Term#gbt.score,
	Name=encode_string(Term#gbt.name),
	Jszdscore=Term#gbt.jszdscore,
	Data = <<Rankscore:32, Yhzqscore:32, Index:32, Score:32, Name/binary, Jszdscore:32>>,
	Data.

%%
encode_yhzq_battlefield_info_s2c (Term)->
	Gbinfo=encode_list(Term#yhzq_battlefield_info_s2c .gbinfo, fun encode_gbw/1),
	Data = <<Gbinfo/binary>>,
	<<1091:16, Data/binary>>.

%%
encode_gbw(Term)->
	Losenum=Term#gbw.losenum,
	Score=Term#gbw.score,
	Index=Term#gbw.index,
	Winnum=Term#gbw.winnum,
	Name=encode_string(Term#gbw.name),
	Data = <<Losenum:32, Score:32, Index:32, Winnum:32, Name/binary>>,
	Data.

%%
encode_fbr(Term)->
	Rolename=encode_string(Term#fbr.rolename),
	Rolelevel=Term#fbr.rolelevel,
	Guildhid=Term#fbr.guildhid,
	Roleid=Term#fbr.roleid,
	Score=Term#fbr.score,
	Guildlid=Term#fbr.guildlid,
	Camp=Term#fbr.camp,
	Roleclass=Term#fbr.roleclass,
	Guildname=encode_string(Term#fbr.guildname),
	Data = <<Rolename/binary, Rolelevel:32, Guildhid:32, Roleid:64, Score:32, Guildlid:32, Camp:32, Roleclass:32, Guildname/binary>>,
	Data.

%%
encode_cbpn(Term)->
	Max=Term#cbpn.max,
	Total=Term#cbpn.total,
	Type=Term#cbpn.type,
	Data = <<Max:32, Total:32, Type:32>>,
	Data.

%%
encode_jszd_battlefield_info_s2c (Term)->
	Killnum=Term#jszd_battlefield_info_s2c .killnum,
	Gbinfo=encode_list(Term#jszd_battlefield_info_s2c .gbinfo, fun encode_gbw/1),
	Honor=Term#jszd_battlefield_info_s2c .honor,
	Score=Term#jszd_battlefield_info_s2c .score,
	Data = <<Killnum:32, Gbinfo/binary, Honor:32, Score:32>>,
	<<1710:16, Data/binary>>.

%%
encode_notify_all_battle_end_s2c (Term)->
	Battle=Term#notify_all_battle_end_s2c .battle,
	Data = <<Battle:32>>,
	<<1711:16, Data/binary>>.

%%神行刷新结果
encode_refresh_everquest_result_s2c(Term)->
	Freetime=Term#refresh_everquest_result_s2c.freetime,
	Sliver=Term#refresh_everquest_result_s2c.sliver,
	Itemcount=Term#refresh_everquest_result_s2c.itemcount,
	Data = <<Freetime:32, Sliver:32, Itemcount:32>>,
	<<859:16, Data/binary>>.

%%一键征友【xiaowu】2013.6.25
encode_auto_find_friend_c2s(Term)->
	Data = <<>>,
	<<2251:16, Data/binary>>.

%%
decode_auto_find_friend_c2s(Binary0)->
	Term = #auto_find_friend_c2s{},
	Term.

%%
encode_auto_find_friend_s2c(Term)->
	Friend=encode_list(Term#auto_find_friend_s2c.friend, fun encode_br/1),
	Data = <<Friend/binary>>,
	<<2269:16, Data/binary>>.

%%
decode_auto_find_friend_s2c(Binary0)->
	{Friend, Binary1}=decode_list(Binary0, fun decode_br/1),
	Term = #auto_find_friend_s2c{friend=Friend},
	Term.
