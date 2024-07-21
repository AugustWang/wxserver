%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-4-7
%% Description: TODO: Add description to package_dispatcher
-module(package_dispatcher).

%%
%% Include files
%%
-include("login_pb.hrl").

%%
%% Exported Functions
%%
-export([dispatch/4]).
%%
%%

%% dispatch(ID, Binary,FromProcName,RolePid)->
%% 	case ID of
%% 		410->
%% 			Message = login_pb:decode_user_auth_c2s(Binary),
%% 			login_package:handle(Message, FromProcName, RolePid);
%% 		400->
%% 			Message = login_pb:decode_create_role_request_c2s(Binary),
%% 			login_package:handle(Message, FromProcName, RolePid); 
%% 		10->
%% 			Message = login_pb:decode_player_select_role_c2s(Binary),
%% 			login_package:handle(Message, FromProcName, RolePid);
%% 		6->
%% 			Message = login_pb:decode_role_line_query_c2s(Binary),
%% 			login_package:handle(Message, FromProcName, RolePid);
%% 		13->
%% 			Message = login_pb:decode_map_complete_c2s(Binary),
%% 			role_packet:handle(Message, RolePid);
%% 		25->
%% 			Message = login_pb:decode_role_move_c2s(Binary),
%% 			role_packet:handle(Message, RolePid);
%% 		_UnknMsg -> slogger:msg("get unknown message ~p\n",[ID])
%% 	end.

%%
%% Local Functions
%%
dispatch(ID, Binary,FromProcName,RolePid)->
	RecordName = login_pb:get_record_name(ID),
	case RecordName of
		user_auth_c2s->  
			Message = login_pb:decode_user_auth_c2s(Binary),
			login_package:handle(Message, FromProcName, RolePid);
		player_select_role_c2s->
			Message = login_pb:decode_player_select_role_c2s(Binary),
			login_package:handle(Message, FromProcName, RolePid);
		role_line_query_c2s->
			Message = login_pb:decode_role_line_query_c2s(Binary),
			login_package:handle(Message, FromProcName, RolePid);
		create_role_request_c2s-> 
			Message = login_pb:decode_create_role_request_c2s(Binary),
			login_package:handle(Message, FromProcName, RolePid); 
%% 		is_visitor_c2s->
%% 			login_package:handle(Message, FromProcName, RolePid);
%% 		is_finish_visitor_c2s->
%% 			login_package:handle(Message, FromProcName, RolePid);
		reset_random_rolename_c2s->
			Message = login_pb:decode_reset_random_rolename_c2s(Binary),
			login_package:handle(Message, FromProcName, RolePid);
		%%spa
		spa_request_spalist_c2s->
			Message = login_pb:decode_spa_request_spalist_c2s(Binary),
			spa_packet:handle(Message,RolePid);
		spa_join_c2s->
			Message = login_pb:decode_spa_join_c2s(Binary),
			spa_packet:handle(Message,RolePid);
		spa_swimming_c2s->
			Message = login_pb:decode_spa_swimming_c2s(Binary),
			spa_packet:handle(Message,RolePid);
		spa_chopping_c2s->
			Message = login_pb:decode_spa_chopping_c2s(Binary),
			spa_packet:handle(Message,RolePid);
		spa_leave_c2s->
			Message = login_pb:decode_spa_leave_c2s(Binary),
			spa_packet:handle(Message,RolePid);
		%%jszd_battle
		jszd_join_c2s->
			Message = login_pb:decode_jszd_join_c2s(Binary),
			battle_jszd_packet:handle(Message,RolePid);
		jszd_leave_c2s->
			Message = login_pb:decode_jszd_leave_c2s(Binary),
			battle_jszd_packet:handle(Message,RolePid);
		jszd_reward_c2s->
			Message = login_pb:decode_jszd_reward_c2s(Binary),
			battle_jszd_packet:handle(Message,RolePid);
		%%mall
		init_mall_item_list_c2s->
			Message = login_pb:decode_init_mall_item_list_c2s(Binary),
			mall_packet:handle(Message,RolePid);
		mall_item_list_c2s->
			Message = login_pb:decode_mall_item_list_c2s(Binary),
			mall_packet:handle(Message,RolePid);
		mall_item_list_special_c2s->
			Message = login_pb:decode_mall_item_list_special_c2s(Binary),
			mall_packet:handle(Message,RolePid);
		mall_item_list_sales_c2s->
			Message = login_pb:decode_mall_item_list_sales_c2s(Binary),
			mall_packet:handle(Message,RolePid);
		buy_mall_item_c2s->
			Message = login_pb:decode_buy_mall_item_c2s(Binary),
			mall_packet:handle(Message,RolePid);
		%%friend
		add_black_c2s->
			Message = login_pb:decode_add_black_c2s(Binary),
			friend_packet:handle(Message,RolePid);
		myfriends_c2s->
			Message = login_pb:decode_myfriends_c2s(Binary),
			friend_packet:handle(Message,RolePid);
		add_friend_c2s->
			Message = login_pb:decode_add_friend_c2s(Binary),
			friend_packet:handle(Message, RolePid);
		add_friend_confirm_c2s->
			Message = login_pb:decode_add_friend_confirm_c2s(Binary),
			friend_packet:handle(Message, RolePid);
		delete_friend_c2s->
			Message = login_pb:decode_delete_friend_c2s(Binary),
			friend_packet:handle(Message, RolePid);
		detail_friend_c2s->
			Message = login_pb:decode_detail_friend_c2s(Binary),
			friend_packet:handle(Message, RolePid);
		position_friend_c2s->
			Message = login_pb:decode_position_friend_c2s(Binary),
			friend_packet:handle(Message, RolePid);
		add_signature_c2s->
			Message = login_pb:decode_add_signature_c2s(Binary),
			friend_packet:handle(Message, RolePid);
		get_friend_signature_c2s->
			Message = login_pb:decode_get_friend_signature_c2s(Binary),
			friend_packet:handle(Message, RolePid);
		set_black_c2s->
			Message = login_pb:decode_set_black_c2s(Binary),
			friend_packet:handle(Message, RolePid);
		revert_black_c2s->
			Message = login_pb:decode_revert_black_c2s(Binary),
			friend_packet:handle(Message, RolePid);
		delete_black_c2s->
			Message = login_pb:decode_delete_black_c2s(Binary),
			friend_packet:handle(Message, RolePid);
		auto_find_friend_c2s->%%一键征友【xiaowu】
			Message = login_pb:decode_auto_find_friend_c2s(Binary),
			friend_packet:handle(Message, RolePid);

		answer_sign_request_c2s->
			Message = login_pb:decode_answer_sign_request_c2s(Binary),
			answer_packet:handle(Message, RolePid);
		answer_question_c2s->
			Message = login_pb:decode_answer_question_c2s(Binary),
			answer_packet:handle(Message, RolePid);
		visitor_rename_c2s->
			Message = login_pb:decode_visitor_rename_c2s(Binary),
			role_packet:handle(Message, RolePid);
		role_change_line_c2s->	
			Message = login_pb:decode_role_change_line_c2s(Binary),		
			role_packet:handle(Message,RolePid);
		role_move_c2s->
			Message = login_pb:decode_role_move_c2s(Binary),
			role_packet:handle(Message, RolePid);
%%		role_move_heartbeat_c2s ->
%%			role_packet:handle(Message, RolePid);
		heartbeat_c2s->
			Message = login_pb:decode_heartbeat_c2s(Binary),
			Msg = login_pb:encode_heartbeat_c2s(Message),
			tcp_client:send_data(self(),Msg);
		map_complete_c2s ->
			Message = login_pb:decode_map_complete_c2s(Binary),
			role_packet:handle(Message, RolePid);
		role_attack_c2s ->	
			Message = login_pb:decode_role_attack_c2s(Binary),		
			role_packet:handle(Message, RolePid);
		role_map_change_c2s->
			Message = login_pb:decode_role_map_change_c2s(Binary),
			role_packet:handle(Message, RolePid);       
		npc_function_c2s->
			Message = login_pb:decode_npc_function_c2s(Binary),
			role_packet:handle(Message, RolePid);
		npc_map_change_c2s->
			Message = login_pb:decode_npc_map_change_c2s(Binary),
			role_packet:handle(Message, RolePid);
		skill_panel_c2s ->
			Message = login_pb:decode_skill_panel_c2s(Binary),
			role_packet:handle(Message, RolePid);
		update_hotbar_c2s ->
			Message = login_pb:decode_update_hotbar_c2s(Binary),
			role_packet:handle(Message, RolePid);
		loot_query_c2s->
			Message = login_pb:decode_loot_query_c2s(Binary),
			role_packet:handle(Message, RolePid);	
		loot_pick_c2s->
			Message = login_pb:decode_loot_pick_c2s(Binary),
			role_packet:handle(Message, RolePid);	
		destroy_item_c2s->
			Message = login_pb:decode_destroy_item_c2s(Binary),
			role_packet:handle(Message, RolePid);	
		split_item_c2s->
			Message = login_pb:decode_split_item_c2s(Binary),
			role_packet:handle(Message, RolePid);	
		swap_item_c2s->	
			Message = login_pb:decode_swap_item_c2s(Binary),
			role_packet:handle(Message, RolePid);
		auto_equip_item_c2s->	
			Message = login_pb:decode_auto_equip_item_c2s(Binary),
			role_packet:handle(Message, RolePid);
		enum_shoping_item_c2s ->
			Message = login_pb:decode_enum_shoping_item_c2s(Binary),
			role_packet:handle(Message, RolePid);
		buy_item_c2s ->
			Message = login_pb:decode_buy_item_c2s(Binary),
			role_packet:handle(Message, RolePid);
		sell_item_c2s ->
			Message = login_pb:decode_sell_item_c2s(Binary),
			role_packet:handle(Message, RolePid);
		use_item_c2s->
			Message = login_pb:decode_use_item_c2s(Binary),
			role_packet:handle(Message, RolePid);
		group_apply_c2s->
			Message = login_pb:decode_group_apply_c2s(Binary),
			role_packet:handle(Message, RolePid);
		group_agree_c2s->
			Message = login_pb:decode_group_agree_c2s(Binary),
			role_packet:handle(Message, RolePid);
		group_create_c2s->
			Message = login_pb:decode_group_create_c2s(Binary),
			role_packet:handle(Message, RolePid);
		aoi_role_group_c2s->
			Message = login_pb:decode_aoi_role_group_c2s(Binary),
			role_packet:handle(Message, RolePid);
		group_invite_c2s->
			Message = login_pb:decode_group_invite_c2s(Binary),
			role_packet:handle(Message, RolePid);
		group_accept_c2s->
			Message = login_pb:decode_group_accept_c2s(Binary),
			role_packet:handle(Message, RolePid);
		group_decline_c2s->
			Message = login_pb:decode_group_decline_c2s(Binary),
			role_packet:handle(Message, RolePid);
		group_kickout_c2s->
			Message = login_pb:decode_group_kickout_c2s(Binary),
			role_packet:handle(Message, RolePid);
		group_setleader_c2s->
			Message = login_pb:decode_group_setleader_c2s(Binary),
			role_packet:handle(Message, RolePid);
		group_disband_c2s->
			Message = login_pb:decode_group_disband_c2s(Binary),
			role_packet:handle(Message, RolePid);
		group_depart_c2s->
			Message = login_pb:decode_group_depart_c2s(Binary),
			role_packet:handle(Message, RolePid);
		recruite_c2s->
			Message = login_pb:decode_recruite_c2s(Binary),
			role_packet:handle(Message, RolePid);
		recruite_cancel_c2s->
			Message = login_pb:decode_recruite_cancel_c2s(Binary),
			role_packet:handle(Message, RolePid);
		role_recruite_c2s->
			Message = login_pb:decode_role_recruite_c2s(Binary),
			role_packet:handle(Message, RolePid);
		role_recruite_cancel_c2s->
			Message = login_pb:decode_role_recruite_cancel_c2s(Binary),
		  	role_packet:handle(Message, RolePid);
		recruite_query_c2s->
			Message = login_pb:decode_recruite_query_c2s(Binary),
			role_packet:handle(Message, RolePid);	
		inspect_c2s->
			Message = login_pb:decode_inspect_c2s(Binary),
			role_packet:handle(Message, RolePid);
		inspect_pet_c2s->
			Message = login_pb:decode_inspect_pet_c2s(Binary),
			role_packet:handle(Message, RolePid);
		role_respawn_c2s->
			Message = login_pb:decode_role_respawn_c2s(Binary),
			role_packet:handle(Message, RolePid);			
		repair_item_c2s->
			Message = login_pb:decode_repair_item_c2s(Binary),
			role_packet:handle(Message, RolePid);			
		questgiver_hello_c2s->
			Message = login_pb:decode_questgiver_hello_c2s(Binary),
			quest_packet:handle(Message,RolePid);
		questgiver_accept_quest_c2s->
			Message = login_pb:decode_questgiver_accept_quest_c2s(Binary),
			quest_packet:handle(Message,RolePid);
		quest_quit_c2s->
			Message = login_pb:decode_quest_quit_c2s(Binary),
			quest_packet:handle(Message, RolePid);
		questgiver_complete_quest_c2s->
			Message = login_pb:decode_questgiver_complete_quest_c2s(Binary),
			quest_packet:handle(Message, RolePid);
		questgiver_states_update_c2s->
			Message = login_pb:decode_questgiver_states_update_c2s(Binary),
			quest_packet:handle(Message, RolePid);
		quest_details_c2s->
			Message = login_pb:decode_quest_details_c2s(Binary),
			quest_packet:handle(Message, RolePid);		
		quest_get_adapt_c2s->	
			Message = login_pb:decode_quest_get_adapt_c2s(Binary),
			quest_packet:handle(Message, RolePid);
		refresh_everquest_c2s->
			Message = login_pb:decode_refresh_everquest_c2s(Binary),
			quest_packet:handle(Message, RolePid);
		npc_start_everquest_c2s->
			Message = login_pb:decode_npc_start_everquest_c2s(Binary),
			quest_packet:handle(Message, RolePid);
		npc_everquests_enum_c2s->
			Message = login_pb:decode_npc_everquests_enum_c2s(Binary),
		  	quest_packet:handle(Message, RolePid);
		quest_direct_complete_c2s->
			Message = login_pb:decode_quest_direct_complete_c2s(Binary),
			quest_packet:handle(Message, RolePid);
		enum_skill_item_c2s->
			Message = login_pb:decode_enum_skill_item_c2s(Binary),
		  role_packet:handle(Message, RolePid);	 		
		skill_learn_item_c2s ->
			Message = login_pb:decode_skill_learn_item_c2s(Binary),
		   role_packet:handle(Message, RolePid);	 
	   skill_auto_learn_item_c2s->
		   Message=login_pb:decode_skill_auto_learn_item_c2s(Binary),
		    role_packet:handle(Message,RolePid);
		feedback_info_c2s->
			Message = login_pb:decode_feedback_info_c2s(Binary),
		  role_packet:handle(Message, RolePid);	
		role_rename_c2s->
			Message = login_pb:decode_role_rename_c2s(Binary),
		   role_packet:handle(Message, RolePid);	
		guild_rename_c2s->
			Message = login_pb:decode_guild_rename_c2s(Binary),
			role_packet:handle(Message, RolePid);
		spiritspower_reset_c2s->
			Message = login_pb:decode_spiritspower_reset_c2s(Binary),
			role_packet:handle(Message, RolePid);
		
		%%guild 
		change_guild_battle_limit_c2s->
			Message = login_pb:decode_change_guild_battle_limit_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		upgrade_guild_monster_c2s->
			Message = login_pb:decode_upgrade_guild_monster_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		get_guild_monster_info_c2s->
			Message = login_pb:decode_get_guild_monster_info_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		call_guild_monster_c2s->
			Message = login_pb:decode_call_guild_monster_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		callback_guild_monster_c2s->
			Message = login_pb:decode_callback_guild_monster_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		change_smith_need_contribution_c2s->
			Message = login_pb:decode_change_smith_need_contribution_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_create_c2s->
			Message = login_pb:decode_guild_create_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		get_guild_space_info_c2s->%%1月27日加【小五】
			Message = login_pb:decode_get_guild_space_info_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		open_guild_space_c2s->%%1月29日加【小五】
			Message = login_pb:decode_open_guild_space_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		start_qunmojiuxian_c2s->%%4月9日加【小五】
			Message = login_pb:decode_start_qunmojiuxian_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		qunmojiuxian_vote_c2s->%%4月10日加【小五】
			Message = login_pb:decode_qunmojiuxian_vote_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		qunmojiuxian_accept_vote_c2s->
			Message = login_pb:decode_qunmojiuxian_accept_vote_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		join_guild_instance_c2s->
			Message = login_pb:decode_join_guild_instance_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		%%帮会仓库
		guild_storage_sort_items_c2s->
			Message=login_pb:decode_guild_storage_sort_items_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_set_item_state_c2s->
			Message=login_pb:decode_guild_storage_set_item_state_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_set_state_c2s->
			Message=login_pb:decode_guild_storage_set_state_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_cancel_apply_c2s->
			Message=login_pb:decode_guild_storage_cancel_apply_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_self_apply_c2s->
			Message=login_pb:decode_guild_storage_self_apply_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_distribute_item_c2s->
			Message=login_pb:decode_guild_storage_distribute_item_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_refuse_all_apply_c2s->
			Message=login_pb:decode_guild_storage_refuse_all_apply_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_refuse_apply_c2s->
			Message=login_pb:decode_guild_storage_refuse_apply_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_approve_apply_c2s->
			Message=login_pb:decode_guild_storage_approve_apply_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_init_apply_c2s->
			Message=login_pb:decode_guild_storage_init_apply_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_apply_item_c2s->
			Message=login_pb:decode_guild_storage_apply_item_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_init_c2s->
			Message=login_pb:decode_guild_storage_init_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_donate_c2s->
			Message=login_pb:decode_guild_storage_donate_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_take_out_c2s->
			Message=login_pb:decode_guild_storage_take_out_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_storage_log_c2s->
			Message=login_pb:decode_guild_storage_log_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		join_guild_instance_c2s->
			Message = login_pb:decode_join_guild_instance_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_disband_c2s->
			Message = login_pb:decode_guild_disband_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_member_invite_c2s->
			Message = login_pb:decode_guild_member_invite_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_member_decline_c2s->
			Message = login_pb:decode_guild_member_decline_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_member_accept_c2s->
			Message = login_pb:decode_guild_member_accept_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_member_apply_c2s->
			Message = login_pb:decode_guild_member_apply_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_member_depart_c2s->
			Message = login_pb:decode_guild_member_depart_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_member_kickout_c2s->
			Message = login_pb:decode_guild_member_kickout_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_set_leader_c2s->
			Message = login_pb:decode_guild_set_leader_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_member_promotion_c2s->
			Message = login_pb:decode_guild_member_promotion_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_member_demotion_c2s->
			Message = login_pb:decode_guild_member_demotion_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_log_normal_c2s->
			Message = login_pb:decode_guild_log_normal_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_log_event_c2s->
			Message = login_pb:decode_guild_log_event_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_notice_modify_c2s->
			Message = login_pb:decode_guild_notice_modify_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_facilities_accede_rules_c2s->
			Message = login_pb:decode_guild_facilities_accede_rules_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_facilities_upgrade_c2s->
			Message = login_pb:decode_guild_facilities_upgrade_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_facilities_speed_up_c2s->
			Message = login_pb:decode_guild_facilities_speed_up_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_rewards_c2s->
			Message = login_pb:decode_guild_rewards_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_recruite_info_c2s->
			Message = login_pb:decode_guild_recruite_info_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_member_contribute_c2s->
			Message = login_pb:decode_guild_member_contribute_c2s(Binary),
			guild_packet:handle(Message, RolePid);	
		
		%%guild add
		guild_contribute_log_c2s->
			Message = login_pb:decode_guild_contribute_log_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_impeach_c2s->
			Message = login_pb:decode_guild_impeach_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_impeach_info_c2s->
			Message = login_pb:decode_guild_impeach_info_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_impeach_vote_c2s->
			Message = login_pb:decode_guild_impeach_vote_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		
		chat_c2s->
			Message = login_pb:decode_chat_c2s(Binary),
			chat_packet:handle(Message, RolePid);
 		chat_private_c2s->
			Message = login_pb:decode_chat_private_c2s(Binary),
 			chat_packet:handle(Message, RolePid);
			
		loudspeaker_queue_num_c2s->
			Message = login_pb:decode_loudspeaker_queue_num_c2s(Binary),
			chat_packet:handle(Message, RolePid);	
		
		query_player_option_c2s->
			Message = login_pb:decode_query_player_option_c2s(Binary),
			role_packet:handle(Message, RolePid);
		
		replace_player_option_c2s->
			Message = login_pb:decode_replace_player_option_c2s(Binary),
			role_packet:handle(Message, RolePid);
		
		info_back_c2s->
			Message = login_pb:decode_info_back_c2s(Binary),
			role_packet:handle(Message, RolePid);
		
		lottery_clickslot_c2s->
			Message = login_pb:decode_lottery_clickslot_c2s(Binary),
			role_packet:handle(Message, RolePid);
		lottery_querystatus_c2s->
			Message = login_pb:decode_lottery_querystatus_c2s(Binary),
			role_packet:handle(Message, RolePid);
		start_block_training_c2s->
			Message = login_pb:decode_start_block_training_c2s(Binary),
			role_packet:handle(Message, RolePid);
		end_block_training_c2s->
			Message = login_pb:decode_end_block_training_c2s(Binary),
			role_packet:handle(Message, RolePid);
		query_time_c2s->
			Message = login_pb:decode_query_time_c2s(Binary),
			role_packet:handle(Message, RolePid);
		stop_move_c2s->
			Message = login_pb:decode_stop_move_c2s(Binary),
			role_packet:handle(Message, RolePid);

		%%identify_verify
		identify_verify_c2s->
			Message = login_pb:decode_identify_verify_c2s(Binary),
			role_packet:handle(Message, RolePid);		
		
		mail_status_query_c2s->
			Message = login_pb:decode_mail_status_query_c2s(Binary),
			mail_packet:handle(Message, RolePid);
		mail_query_detail_c2s->
			Message = login_pb:decode_mail_query_detail_c2s(Binary),
			mail_packet:handle(Message, RolePid);
		
		mail_send_c2s->
			Message = login_pb:decode_mail_send_c2s(Binary),
			mail_packet:handle(Message, RolePid);
		
		mail_get_addition_c2s->
			Message = login_pb:decode_mail_get_addition_c2s(Binary),
			mail_packet:handle(Message, RolePid);
		
		mail_delete_c2s->
			Message = login_pb:decode_mail_delete_c2s(Binary),
			mail_packet:handle(Message, RolePid);

		%%trade
		trade_role_apply_c2s->
			Message = login_pb:decode_trade_role_apply_c2s(Binary),
			trade_role_packet:handle(Message, RolePid);
		trade_role_accept_c2s->
			Message = login_pb:decode_trade_role_accept_c2s(Binary),
			trade_role_packet:handle(Message, RolePid);
		trade_role_decline_c2s->
			Message = login_pb:decode_trade_role_decline_c2s(Binary),
			trade_role_packet:handle(Message, RolePid);
		set_trade_money_c2s->
			Message = login_pb:decode_set_trade_money_c2s(Binary),
			trade_role_packet:handle(Message, RolePid);
		set_trade_item_c2s->
			Message = login_pb:decode_set_trade_item_c2s(Binary),
			trade_role_packet:handle(Message, RolePid);
		cancel_trade_c2s->
			Message = login_pb:decode_cancel_trade_c2s(Binary),
			trade_role_packet:handle(Message, RolePid);
		trade_role_lock_c2s->
			Message = login_pb:decode_trade_role_lock_c2s(Binary),
			trade_role_packet:handle(Message, RolePid);
		trade_role_dealit_c2s->
			Message = login_pb:decode_trade_role_dealit_c2s(Binary),
			trade_role_packet:handle(Message, RolePid);
		
		%% query_system_switch_c2s
		query_system_switch_c2s->
			Message = login_pb:decode_query_system_switch_c2s(Binary),
			system_switch:handle(Message,RolePid);
		
		%% equipment
		equipment_riseup_c2s->
			Message = login_pb:decode_equipment_riseup_c2s(Binary),
			equipment_packet:handle(Message,RolePid);
		equipment_sock_c2s->
			Message = login_pb:decode_equipment_sock_c2s(Binary),
			equipment_packet:handle(Message,RolePid);
		equipment_inlay_c2s->
			Message = login_pb:decode_equipment_inlay_c2s(Binary),
			equipment_packet:handle(Message,RolePid);
		equipment_stone_remove_c2s->
			Message = login_pb:decode_equipment_stone_remove_c2s(Binary),
			equipment_packet:handle(Message,RolePid);
		equipment_stonemix_single_c2s->
			Message = login_pb:decode_equipment_stonemix_single_c2s(Binary),
			equipment_packet:handle(Message,RolePid);
		
		equipment_stonemix_c2s->
			Message = login_pb:decode_equipment_stonemix_c2s(Binary),
			equipment_packet:handle(Message,RolePid);		
		
		equipment_upgrade_c2s->
			Message = login_pb:decode_equipment_upgrade_c2s(Binary),
			equipment_packet:handle(Message,RolePid);		
		equipment_enchant_c2s->
			Message = login_pb:decode_equipment_enchant_c2s(Binary),
			equipment_packet:handle(Message,RolePid);
		equipment_recast_c2s->
			Message = login_pb:decode_equipment_recast_c2s(Binary),
			equipment_packet:handle(Message,RolePid);
		equipment_recast_confirm_c2s->
			Message = login_pb:decode_equipment_recast_confirm_c2s(Binary),
			equipment_packet:handle(Message,RolePid);
		equipment_convert_c2s->
			Message = login_pb:decode_equipment_convert_c2s(Binary),
			equipment_packet:handle(Message,RolePid);
		equipment_move_c2s->
			Message = login_pb:decode_equipment_move_c2s(Binary),
			equipment_packet:handle(Message,RolePid);
		equipment_remove_seal_c2s->
			Message = login_pb:decode_equipment_remove_seal_c2s(Binary),
			equipment_packet:handle(Message,RolePid);
		equipment_fenjie_c2s->
			Message = login_pb:decode_equipment_fenjie_c2s(Binary),
			equipment_packet:handle(Message,RolePid);
		
		%% achieve
%% 		achieve_open_c2s->
%% 			Message = login_pb:decode_achieve_open_c2s(Binary),
%% 			achieve_packet:handle(Message,RolePid);
		achieve_reward_c2s->
			Message = login_pb:decode_achieve_reward_c2s(Binary),
			achieve_packet:handle(Message,RolePid);
		achieve_init_c2s->
			Message = login_pb:decode_achieve_init_c2s(Binary),
			achieve_packet:handle(Message, RolePid);%%@@wb20130228
		
		%% goals
		goals_reward_c2s->
			Message = login_pb:decode_goals_reward_c2s(Binary),
			goals_packet:handle(Message, RolePid);
		goals_init_c2s->
			Message = login_pb:decode_goals_init_c2s(Binary),
			goals_packet:handle(Message, RolePid);
		
		%%loop_tower
		loop_tower_enter_c2s->
			Message = login_pb:decode_loop_tower_enter_c2s(Binary),
			loop_tower_packet:handle(Message, RolePid);
		loop_tower_challenge_c2s->
			Message = login_pb:decode_loop_tower_challenge_c2s(Binary),
			loop_tower_packet:handle(Message, RolePid);
		loop_tower_reward_c2s->
			Message = login_pb:decode_loop_tower_reward_c2s(Binary),
			loop_tower_packet:handle(Message, RolePid);
		loop_tower_challenge_again_c2s->
			Message = login_pb:decode_loop_tower_challenge_again_c2s(Binary),
			loop_tower_packet:handle(Message, RolePid);
		loop_tower_masters_c2s->
			Message = login_pb:decode_loop_tower_masters_c2s(Binary),
			loop_tower_packet:handle(Message, RolePid);
		
		%%VIP
		vip_ui_c2s->
			Message = login_pb:decode_vip_ui_c2s(Binary),
			vip_packet:handle(Message, RolePid);
		vip_reward_c2s->
			Message = login_pb:decode_vip_reward_c2s(Binary),
			vip_packet:handle(Message, RolePid);
		login_bonus_reward_c2s->
			Message = login_pb:decode_login_bonus_reward_c2s(Binary),
			vip_packet:handle(Message, RolePid); 
		join_vip_map_c2s->
			Message = login_pb:decode_join_vip_map_c2s(Binary),
			vip_packet:handle(Message, RolePid);
		%%petup
		pet_up_reset_c2s->
			Message = login_pb:decode_pet_up_reset_c2s(Binary),
			petup_packet:handle(Message, RolePid);
		pet_up_growth_c2s->
			Message = login_pb:decode_pet_up_growth_c2s(Binary),
			petup_packet:handle(Message, RolePid);
		pet_up_stamina_growth_c2s->
			Message = login_pb:decode_pet_up_stamina_growth_c2s(Binary),
			petup_packet:handle(Message, RolePid);
		pet_up_exp_c2s->
			Message = login_pb:decode_pet_up_exp_c2s(Binary),
			petup_packet:handle(Message, RolePid);
		pet_riseup_c2s->
			Message = login_pb:decode_pet_riseup_c2s(Binary),
			petup_packet:handle(Message, RolePid);
		%%PVP
		set_pkmodel_c2s->
			Message = login_pb:decode_set_pkmodel_c2s(Binary),
			pvp_packet:handle(Message,RolePid);
		duel_invite_c2s->
			Message = login_pb:decode_duel_invite_c2s(Binary),
			pvp_packet:handle(Message,RolePid);
		duel_decline_c2s->
			Message = login_pb:decode_duel_decline_c2s(Binary),
			pvp_packet:handle(Message,RolePid);
		duel_accept_c2s->
			Message = login_pb:decode_duel_accept_c2s(Binary),
			pvp_packet:handle(Message,RolePid);  
		npc_storage_items_c2s->
			Message = login_pb:decode_npc_storage_items_c2s(Binary),
			role_packet:handle(Message,RolePid);
		arrange_items_c2s->
			Message = login_pb:decode_arrange_items_c2s(Binary),
			role_packet:handle(Message,RolePid);
		fly_shoes_c2s->
			Message = login_pb:decode_fly_shoes_c2s(Binary),
			role_packet:handle(Message,RolePid);
		use_target_item_c2s->
			Message = login_pb:decode_use_target_item_c2s(Binary),
			role_packet:handle(Message,RolePid);
		npc_swap_item_c2s->
			Message = login_pb:decode_npc_swap_item_c2s(Binary),
			role_packet:handle(Message,RolePid);
		battle_join_c2s->
			Message = login_pb:decode_battle_join_c2s(Binary),
			battle_ground_packet:handle(Message,RolePid);
		battle_leave_c2s->
			Message = login_pb:decode_battle_leave_c2s(Binary),
			battle_ground_packet:handle(Message,RolePid);
		battle_reward_c2s->
			Message = login_pb:decode_battle_reward_c2s(Binary),
			battle_ground_packet:handle(Message,RolePid);
		get_instance_log_c2s->
			Message = login_pb:decode_get_instance_log_c2s(Binary),
			battle_ground_packet:handle(Message,RolePid);
		tangle_records_c2s->
			Message = login_pb:decode_tangle_records_c2s(Binary),
			battle_ground_packet:handle(Message,RolePid);
		tangle_more_records_c2s->
			Message = login_pb:decode_tangle_more_records_c2s(Binary),
			battle_ground_packet:handle(Message,RolePid);
		tangle_kill_info_request_c2s->
			Message = login_pb:decode_tangle_kill_info_request_c2s(Binary),
			battle_ground_packet:handle(Message,RolePid);
		clear_crime_c2s->
			Message = login_pb:decode_clear_crime_c2s(Binary),
			pvp_packet:handle(Message, RolePid);
		summon_pet_c2s->
			Message = login_pb:decode_summon_pet_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_move_c2s->
			Message = login_pb:decode_pet_move_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_stop_move_c2s->
			Message = login_pb:decode_pet_stop_move_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_attack_c2s->
			Message = login_pb:decode_pet_attack_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_rename_c2s->
			Message = login_pb:decode_pet_rename_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_learn_skill_c2s->
			Message = login_pb:decode_pet_learn_skill_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_forget_skill_c2s->
			Message = login_pb:decode_pet_forget_skill_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_start_training_c2s->
			Message = login_pb:decode_pet_start_training_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_stop_training_c2s->
			Message = login_pb:decode_pet_stop_training_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_speedup_training_c2s->
			Message = login_pb:decode_pet_speedup_training_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		%%pet explore 
		pet_explore_info_c2s->
			Message = login_pb:decode_pet_explore_info_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_explore_start_c2s->
			Message = login_pb:decode_pet_explore_start_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_explore_speedup_c2s->
			Message = login_pb:decode_pet_explore_speedup_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_explore_stop_c2s->
			Message = login_pb:decode_user_pet_explore_stop_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_swap_slot_c2s->
			Message = login_pb:decode_pet_swap_slot_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		%%pet exlore storage 
		explore_storage_init_c2s->
			Message = login_pb:decode_explore_storage_init_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		explore_storage_getitem_c2s->
			Message = login_pb:decode_explore_storage_getitem_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		explore_storage_getallitems_c2s->
			Message = login_pb:decode_explore_storage_getallitems_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		%%treasure_chest
		treasure_chest_flush_c2s->
			Message = login_pb:decode_treasure_chest_flush_c2s(Binary),
			treasure_chest_packet:handle(Message,RolePid);
		
		treasure_chest_raffle_c2s->
			Message = login_pb:decode_treasure_chest_raffle_c2s(Binary),
			treasure_chest_packet:handle(Message,RolePid);
		
		treasure_chest_obtain_c2s->
			Message = login_pb:decode_treasure_chest_obtain_c2s(Binary),
			treasure_chest_packet:handle(Message,RolePid);
			
		treasure_chest_query_c2s->
			Message = login_pb:decode_treasure_chest_query_c2s(Binary),
			treasure_chest_packet:handle(Message,RolePid);
		treasure_chest_disable_c2s->
			Message = login_pb:decode_treasure_chest_disable_c2s(Binary),
			treasure_chest_packet:handle(Message,RolePid);
		%%treasure_chest_v2
		beads_pray_request_c2s->
			Message = login_pb:decode_beads_pray_request_c2s(Binary),
			treasure_chest_v2_packet:handle(Message,RolePid);
		
		%%congratulations
		congratulations_levelup_c2s->
			Message = login_pb:decode_congratulations_levelup_c2s(Binary),
			congratulations_packet:handle(Message, RolePid);
		congratulations_received_c2s->
			Message = login_pb:decode_congratulations_received_c2s(Binary),
			congratulations_packet:handle(Message, RolePid);
		%%offline_exp
		offline_exp_exchange_c2s->
			Message = login_pb:decode_offline_exp_exchange_c2s(Binary),
			offline_exp_packet:handle(Message, RolePid);
		offline_exp_exchange_gold_c2s->
			Message = login_pb:decode_offline_exp_exchange_gold_c2s(Binary),
			offline_exp_packet:handle(Message, RolePid);
		%%exchange item
		enum_exchange_item_c2s ->
			Message = login_pb:decode_enum_exchange_item_c2s(Binary),
			exchange_packet:handle(Message, RolePid);
		exchange_item_c2s ->
			Message = login_pb:decode_exchange_item_c2s(Binary),
			exchange_packet:handle(Message, RolePid);
		battle_reward_by_records_c2s ->
			Message = login_pb:decode_battle_reward_by_records_c2s(Binary),
			battle_ground_packet:handle(Message, RolePid);

		get_timelimit_gift_c2s->
			Message = login_pb:decode_get_timelimit_gift_c2s(Binary),
			timelimit_gift_packet:handle(Message,RolePid);
		join_yhzq_c2s ->
			Message = login_pb:decode_join_yhzq_c2s(Binary),
			battle_ground_packet:handle(Message, RolePid);
		leave_yhzq_c2s->
			Message = login_pb:decode_leave_yhzq_c2s(Binary),
			battle_ground_packet:handle(Message, RolePid);
		yhzq_award_c2s->
			Message = login_pb:decode_yhzq_award_c2s(Binary),
			battle_ground_packet:handle(Message, RolePid);
		gift_card_apply_c2s->
			Message = login_pb:decode_gift_card_apply_c2s(Binary),
			giftcard_packet:handle(Message, RolePid);
		stall_sell_item_c2s->
			Message = login_pb:decode_stall_sell_item_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		paimai_sell_c2s->%%%%2月18日加【xiaowu】(上架)
			Message = login_pb:decode_paimai_sell_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		paimai_detail_c2s->%%%%2月18日加【xiaowu】（上架物品）
			Message = login_pb:decode_paimai_detail_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		paimai_search_by_sort_c2s->%%%%3月4日加【xiaowu】（左侧搜索）
			Message = login_pb:decode_paimai_search_by_sort_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		paimai_search_by_string_c2s->%%%%3月6日加【xiaowu】（下面搜索）
			Message = login_pb:decode_paimai_search_by_string_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		paimai_search_by_grade_c2s->%%3月7日加【xiaowu】（上面搜索）
			Message = login_pb:decode_paimai_search_by_grade_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		paimai_buy_c2s->%%3月7日加【xiaowu】（购买）
			Message = login_pb:decode_paimai_buy_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		paimai_recede_c2s->%%【xiaowu】（下架）
			Message = login_pb:decode_paimai_recede_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		stall_recede_item_c2s->
			Message = login_pb:decode_stall_recede_item_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		stalls_search_c2s->
			Message = login_pb:decode_stalls_search_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		stalls_search_item_c2s->
			Message = login_pb:decode_stalls_search_item_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		stall_detail_c2s->
			Message = login_pb:decode_stall_detail_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		stall_buy_item_c2s->
			Message = login_pb:decode_stall_buy_item_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		stall_rename_c2s->
			Message = login_pb:decode_stall_rename_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		stall_role_detail_c2s->
			Message = login_pb:decode_stall_role_detail_c2s(Binary),
			auction_packet:handle(Message, RolePid);
		
		guild_get_application_c2s->
			Message = login_pb:decode_guild_get_application_c2s(Binary),
			guild_packet:handle(Message, RolePid);	
		guild_application_op_c2s->
			Message = login_pb:decode_guild_application_op_c2s(Binary),
			guild_packet:handle(Message, RolePid);	
		guild_change_nickname_c2s->
			Message = login_pb:decode_guild_change_nickname_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_change_chatandvoicegroup_c2s->
			Message = login_pb:decode_guild_change_chatandvoicegroup_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_get_shop_item_c2s->
			Message = login_pb:decode_guild_get_shop_item_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_shop_buy_item_c2s->
			Message = login_pb:decode_guild_shop_buy_item_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_get_treasure_item_c2s->
			Message = login_pb:decode_guild_get_treasure_item_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_treasure_buy_item_c2s->
			Message = login_pb:decode_guild_treasure_buy_item_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_treasure_set_price_c2s->
			Message = login_pb:decode_guild_treasure_set_price_c2s(Binary),
			guild_packet:handle(Message, RolePid);	
		guild_member_pos_c2s->
			Message = login_pb:decode_guild_member_pos_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_clear_nickname_c2s->
			Message = login_pb:decode_guild_clear_nickname_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		levelup_opt_c2s->
			Message = login_pb:decode_levelup_opt_c2s(Binary),
			role_level_packet:handle(Message, RolePid);
		publish_guild_quest_c2s->
			Message = login_pb:decode_publish_guild_quest_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		get_guild_notice_c2s->
			Message = login_pb:decode_get_guild_notice_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		guild_mastercall_accept_c2s->
			Message = login_pb:decode_guild_mastercall_accept_c2s(Binary),
			guild_packet:handle(Message, RolePid);
		activity_value_init_c2s->
			Message = login_pb:decode_activity_value_init_c2s(Binary),
			activity_value_packet:handle(Message, RolePid);
		activity_value_reward_c2s->
			Message = login_pb:decode_activity_value_reward_c2s(Binary),
			activity_value_packet:handle(Message, RolePid);
		activity_state_init_c2s->
			Message = login_pb:decode_activity_state_init_c2s(Binary),
			active_borad_packet:handle(Message, RolePid);
		activity_boss_born_init_c2s->
			Message = login_pb:decode_activity_boss_born_init_c2s(Binary),
			active_borad_packet:handle(Message, RolePid);
		sitdown_c2s->
			Message = login_pb:decode_sitdown_c2s(Binary),
			sitdown_packet:handle(Message,RolePid);
		stop_sitdown_c2s->
			Message = login_pb:decode_stop_sitdown_c2s(Binary),
			sitdown_packet:handle(Message,RolePid);
		companion_sitdown_apply_c2s->
			Message = login_pb:decode_companion_sitdown_apply_c2s(Binary),
			sitdown_packet:handle_companion_sitdown(Message,RolePid);
		companion_sitdown_start_c2s->
			Message = login_pb:decode_companion_sitdown_start_c2s(Binary),
			sitdown_packet:handle(Message,RolePid);
		companion_reject_c2s->
			Message = login_pb:decode_companion_reject_c2s(Binary),
			sitdown_packet:handle_companion_sitdown(Message,RolePid);
		dragon_fight_num_c2s->
			Message = login_pb:decode_dragon_fight_num_c2s(Binary),
			dragon_fight_packet:handle(Message,RolePid);
		dragon_fight_faction_c2s->
			Message = login_pb:decode_dragon_fight_faction_c2s(Binary),
			dragon_fight_packet:handle(Message,RolePid);
		dragon_fight_join_c2s->
			Message = login_pb:decode_dragon_fight_join_c2s(Binary),
			dragon_fight_packet:handle(Message,RolePid);			
		venation_active_point_start_c2s->
			Message = login_pb:decode_venation_active_point_start_c2s(Binary),
			venation_packet:handle(Message,RolePid);
		venation_advanced_start_c2s->
			Message = login_pb:decode_venation_advanced_start_c2s(Binary),
			venation_packet:handle(Message,RolePid);
		
		%% 好友邀请送礼%%
		invite_friend_gift_get_c2s->
			Message = login_pb:decode_invite_friend_gift_get_c2s(Binary),
			invite_friend_packet:handle(Message,RolePid);
		invite_friend_add_c2s->
			Message = login_pb:decode_invite_friend_add_c2s(Binary),
			invite_friend_packet:handle(Message,RolePid);
		invite_friend_board_c2s->
			Message = login_pb:decode_invite_friend_board_c2s(Binary),
			invite_friend_packet:handle(Message,RolePid);
		
		%%连续登录送礼
		continuous_logging_gift_c2s->
			Message = login_pb:decode_continuous_logging_gift_c2s(Binary),
			continuous_logging_packet:handle(Message,RolePid);
		continuous_logging_board_c2s->
			Message = login_pb:decode_continuous_logging_board_c2s(Binary),
			continuous_logging_packet:handle(Message,RolePid);
		continuous_days_clear_c2s->
			Message = login_pb:decode_continuous_days_clear_c2s(Binary),
			continuous_logging_packet:handle(Message,RolePid);
		
		%%收藏送礼
       collect_page_c2s->
			Message = login_pb:decode_collect_page_c2s(Binary),
			continuous_logging_packet:handle(Message,RolePid);
		
		activity_test01_recv_c2s->
			Message = login_pb:decode_activity_test01_recv_c2s(Binary),
			continuous_logging_packet:handle(Message,RolePid);
		
		first_charge_gift_reward_c2s->
			Message = login_pb:decode_first_charge_gift_reward_c2s(Binary),
			active_borad_packet:handle(Message,RolePid);
		treasure_storage_init_c2s->
			Message = login_pb:decode_treasure_storage_init_c2s(Binary),
			treasure_storage_packet:handle(Message,RolePid);
		treasure_storage_getitem_c2s->
			Message = login_pb:decode_treasure_storage_getitem_c2s(Binary),
			treasure_storage_packet:handle(Message,RolePid);
		treasure_storage_getallitems_c2s->
			Message = login_pb:decode_treasure_storage_getallitems_c2s(Binary),
			treasure_storage_packet:handle(Message,RolePid);		
		chess_spirit_skill_levelup_c2s->
			Message = login_pb:decode_chess_spirit_skill_levelup_c2s(Binary),
			chess_spirit_packet:handle(Message, RolePid);
		chess_spirit_cast_skill_c2s->
			Message = login_pb:decode_chess_spirit_cast_skill_c2s(Binary),
			chess_spirit_packet:handle(Message, RolePid);
		chess_spirit_cast_chess_skill_c2s->
			Message = login_pb:decode_chess_spirit_cast_chess_skill_c2s(Binary),
			chess_spirit_packet:handle(Message, RolePid);
		chess_spirit_log_c2s->
			Message = login_pb:decode_chess_spirit_log_c2s(Binary),
			chess_spirit_packet:handle(Message, RolePid);
		chess_spirit_get_reward_c2s->
			Message = login_pb:decode_chess_spirit_get_reward_c2s(Binary),
			chess_spirit_packet:handle(Message, RolePid);
		chess_spirit_quit_c2s->
			Message = login_pb:decode_chess_spirit_quit_c2s(Binary),
			chess_spirit_packet:handle(Message, RolePid);
		rank_get_rank_c2s->
			Message = login_pb:decode_rank_get_rank_c2s(Binary),
			game_rank_packet:handle(Message, RolePid);
		rank_get_rank_role_c2s->
			Message = login_pb:decode_rank_get_rank_role_c2s(Binary),
			game_rank_packet:handle(Message, RolePid);
		rank_disdain_role_c2s->
			Message = login_pb:decode_rank_disdain_role_c2s(Binary),
			game_rank_packet:handle(Message, RolePid);
		rank_praise_role_c2s->
			Message = login_pb:decode_rank_praise_role_c2s(Binary),
			game_rank_packet:handle(Message, RolePid);
		facebook_bind_check_c2s->
			Message = login_pb:decode_facebook_bind_check_c2s(Binary),
			facebook:handle(Message,RolePid);
		welfare_panel_init_c2s->
			Message = login_pb:decode_welfare_panel_init_c2s(Binary),
			welfare_activity_packet:handle(Message,RolePid);
		welfare_gold_exchange_init_c2s->
			Message = login_pb:decode_welfare_gold_exchange_init_c2ss(Binary),
			welfare_activity_packet:handle(Message,RolePid);
		welfare_gold_exchange_c2s->
			Message = login_pb:decode_welfare_gold_exchange_c2s(Binary),
			welfare_activity_packet:handle(Message,RolePid);
		welfare_activity_update_c2s->
			Message = login_pb:decode_welfare_activity_update_c2s(Binary),
				welfare_activity_packet:handle(Message,RolePid);
		item_identify_c2s->  
			Message = login_pb:decode_item_identify_c2s(Binary),
			ride_pet_packet:handle(Message,RolePid);
		ride_pet_synthesis_c2s-> 
			Message = login_pb:decode_ride_pet_synthesis_c2s(Binary),
			ride_pet_packet:handle(Message,RolePid);
		%%pet upgrade quality 
		pet_growup_c2s->
			Message = login_pb:decode_pet_growup_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_upgrade_quality_up_c2s->
			Message = login_pb:decode_pet_upgrade_quality_up_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		%%pet add attr and wash attr point
		pet_add_attr_c2s->
			Message = login_pb:decode_pet_add_attr_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_wash_attr_c2s->
			Message = login_pb:decode_pet_wash_attr_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		ride_opt_c2s->
			Message = login_pb:decode_ride_opt_c2s(Binary),
			ride_pet_packet:handle(Message,RolePid);
		pet_random_talent_c2s-> 
			Message = login_pb:decode_pet_random_talent_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_change_talent_c2s-> 
			Message = login_pb:decode_pet_change_talent_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_evolution_c2s-> 
			Message = login_pb:decode_pet_evolution_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		equip_item_for_pet_c2s->
			Message = login_pb:decode_equip_item_for_pet_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		unequip_item_for_pet_c2s->
			Message = login_pb:decode_unequip_item_for_pet_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_skill_slot_lock_c2s->
			Message = login_pb:decode_pet_skill_slot_lock_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_unlock_skill_c2s->
			Message=login_pb:decode_pet_unlock_skill_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		buy_pet_slot_c2s->
			Message = login_pb:decode_buy_pet_slot_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_feed_c2s->
			Message = login_pb:decode_pet_feed_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		refine_system_c2s->
			Message = login_pb:decode_refine_system_c2s(Binary),
			refine_system_packet:handle(Message,RolePid);
		instance_leader_join_c2s->
			Message = login_pb:decode_instance_leader_join_c2s(Binary),
			instance_packet:handle(Message, RolePid);
		instance_exit_c2s->
			Message = login_pb:decode_instance_exit_c2s(Binary),
			instance_packet:handle(Message, RolePid);

       %%副本元宝委托%
	   instance_entrust_c2s->
			Message = login_pb:decode_instance_entrust_c2s(Binary),
			instance_packet:handle(Message, RolePid);


		cancel_buff_c2s->
			Message = login_pb:decode_cancel_buff_c2s(Binary),
			buffer_packet:handle(Message, RolePid);
		role_treasure_transport_time_check_c2s->
			Message = login_pb:decode_role_treasure_transport_time_check_c2s(Binary),
			treasure_transport_packet:handle(Message, RolePid);
		start_guild_treasure_transport_c2s->
			Message = login_pb:decode_start_guild_treasure_transport_c2s(Binary),
			treasure_transport_packet:handle(Message, RolePid);	
		
		mainline_init_c2s->
			Message = login_pb:decode_mainline_init_c2s(Binary),
			mainline_packet:handle(Message, RolePid);
		mainline_start_entry_c2s->
			Message = login_pb:decode_mainline_start_entry_c2s(Binary),
			mainline_packet:handle(Message, RolePid);
		mainline_start_c2s->
			Message = login_pb:decode_mainline_start_c2s(Binary),
			mainline_packet:handle(Message, RolePid);
		mainline_end_c2s->
			Message = login_pb:decode_mainline_end_c2s(Binary),
			mainline_packet:handle(Message, RolePid);
		mainline_reward_c2s->
			Message = login_pb:decode_mainline_reward_c2s(Binary),
			mainline_packet:handle(Message, RolePid);
		mainline_timeout_c2s->
			Message = login_pb:decode_mainline_timeout_c2s(Binary),
			mainline_packet:handle(Message, RolePid);
		
		country_init_c2s->
			Message = login_pb:decode_country_init_c2s(Binary),
			country_packet:handle(Message, RolePid);
		change_country_notice_c2s->
			Message = login_pb:decode_change_country_notice_c2s(Binary),
			country_packet:handle(Message, RolePid);
		change_country_transport_c2s->
			Message = login_pb:decode_change_country_transport_c2s(Binary),
			country_packet:handle(Message, RolePid);		
		country_leader_promotion_c2s->
			Message = login_pb:decode_country_leader_promotion_c2s(Binary),
			country_packet:handle(Message, RolePid);
		country_leader_demotion_c2s->
			Message = login_pb:decode_country_leader_demotion_c2s(Binary),
			country_packet:handle(Message, RolePid);
		country_block_talk_c2s->
			Message = login_pb:decode_country_block_talk_c2s(Binary),
			country_packet:handle(Message, RolePid);
		country_change_crime_c2s->
			Message = login_pb:decode_country_change_crime_c2s(Binary),
			country_packet:handle(Message, RolePid);
		country_leader_get_itmes_c2s->
			Message = login_pb:decode_country_leader_get_itmes_c2s(Binary),
			country_packet:handle(Message, RolePid);
		country_leader_ever_reward_c2s->
			Message = login_pb:decode_country_leader_ever_reward_c2s(Binary),
			country_packet:handle(Message, RolePid);
		
		entry_guild_battle_c2s->
			Message = login_pb:decode_entry_guild_battle_c2s(Binary),
			guildbattle_packet:handle(Message, RolePid);
		leave_guild_battle_c2s->
			Message = login_pb:decode_leave_guild_battle_c2s(Binary),
			guildbattle_packet:handle(Message, RolePid);
		apply_guild_battle_c2s->
			Message = login_pb:decode_apply_guild_battle_c2s(Binary),
			guildbattle_packet:handle(Message, RolePid);
		rank_get_main_line_rank_c2s->
			Message = login_pb:decode_rank_get_main_line_rank_c2s(Binary),
			game_rank_packet:handle(Message, RolePid);	
		server_version_c2s->
			Message = login_pb:decode_server_version_c2s(Binary),
			try
				Msg = version:make_version(),
				tcp_client:send_data(self(),Msg)
			catch
				_:_->nothing
			end;
		treasure_transport_call_guild_help_c2s->
			Message = login_pb:decode_treasure_transport_call_guild_help_c2s(Binary),
			treasure_transport_packet:handle(Message, RolePid);
		
		%%festival activity 		
		festival_init_c2s->
			Message = login_pb:decode_festival_init_c2s(Binary),
			festival_packet:handle(Message,RolePid);
		festival_recharge_exchange_c2s->
			Message = login_pb:decode_festival_recharge_exchange_c2s(Binary),
			festival_packet:handle(Message,RolePid);
		init_open_service_activities_c2s->
			Message = login_pb:decode_init_open_service_activities_c2s(Binary),
			open_service_activities_packet:handle(Message,RolePid);
		open_service_activities_reward_c2s->
			Message = login_pb:decode_open_service_activities_reward_c2s(Binary),
			open_service_activities_packet:handle(Message,RolePid);
		christmas_tree_grow_up_c2s->
			Message = login_pb:decode_christmas_tree_grow_up_c2s(Binary),
			christmac_activity_packet:handle(Message,RolePid);
		christmas_activity_reward_c2s->
			Message = login_pb:decode_christmas_activity_reward_c2s(Binary),
			christmac_activity_packet:handle(Message,RolePid);
		
		%% loop instance
		entry_loop_instance_apply_c2s->
			Message = login_pb:decode_entry_loop_instance_apply_c2s(Binary),
			loop_instance_packet:handle(Message,RolePid);
		entry_loop_instance_vote_c2s->
			Message = login_pb:decode_entry_loop_instance_vote_c2s(Binary),
			loop_instance_packet:handle(Message,RolePid);
		entry_loop_instance_c2s->
			Message = login_pb:decode_entry_loop_instance_c2s(Binary),
			loop_instance_packet:handle(Message,RolePid);
		leave_loop_instance_c2s->
			Message = login_pb:decode_leave_loop_instance_c2s(Binary),
			loop_instance_packet:handle(Message,RolePid);
		%%honor shop
		honor_stores_buy_items_c2s->
			Message = login_pb:decode_honor_stores_buy_items_c2s(Binary),
			honor_stores_packet:handle(Message,RolePid);
		battlefield_info_c2s->
			Message = login_pb:decode_battlefield_info_c2s(Binary),
			battle_ground_packet:handle(Message,RolePid);
		init_instance_quality_c2s ->
			Message = login_pb:decode_init_instance_quality_c2s(Binary),
			instance_packet:handle(Message, RolePid);
		refresh_instance_quality_c2s ->
			Message = login_pb:decode_refresh_instance_quality_c2s(Binary),
			instance_packet:handle(Message, RolePid);
		qz_get_balance_c2s ->
			Message = login_pb:decode_qz_get_balance_c2s(Binary),
			payment_packet:handle(Message, RolePid);
		pet_forget_skill_c2s->%%宠物遗忘技能
			Message=login_pb:decode_pet_forget_skill_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		use_pet_egg_ext_c2s ->                                                %%使用宠物蛋<枫少>
			Message=login_pb:decode_use_pet_egg_ext_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_shop_init_c2s->
			Message=login_pb:decode_pet_shop_init_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_shop_buy_c2s->
			Message=login_pb:decode_pet_shop_buy_c2s(Binary),
			pet_packet:handle(Message,RolePid);
		pet_speed_levelup_c2s->
			Message=login_pb:decode_pet_speed_levelup_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_evolution_growthvalue_c2s->
			Message=login_pb:decode_pet_evolution_growthvalue_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_qualification_c2s->
			Message=login_pb:decode_pet_qualification_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_skill_book_refresh_c2s->
			Message=login_pb:decode_pet_skill_book_refresh_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_get_skill_book_c2s->
			Message=login_pb:decode_pet_get_skill_book_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_auto_advance_c2s->
			Message=login_pb:decode_pet_auto_advance_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_advance_c2s->
			Message=login_pb:decode_pet_advance_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_talent_levelup_c2s->
			Message=login_pb:decode_pet_talent_levelup_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_xs_c2s->
			Message=login_pb:decode_pet_xs_c2s(Binary),
			pet_packet:handle(Message, RolePid);
		pet_inheritance_c2s->
			Message=login_pb:decode_pet_inheritance_c2s(Binary),
			pet_packet:handle(Message, RolePid);

		wing_level_up_c2s->
			Message=login_pb:decode_wing_level_up_c2s(Binary),
			wing_packet:handle(Message, RolePid);
		wing_phase_up_c2s->
			Message=login_pb:decode_wing_phase_up_c2s(Binary),
			wing_packet:handle(Message, RolePid);
		wing_quality_up_c2s->
			Message=login_pb:decode_wing_quality_up_c2s(Binary),
			wing_packet:handle(Message, RolePid);
		wing_intensify_c2s->
			Message=login_pb:decode_wing_intensify_c2s(Binary),
			wing_packet:handle(Message, RolePid);
		wing_enchant_c2s->
			Message=login_pb:decode_wing_enchant_c2s(Binary),
			wing_packet:handle(Message, RolePid);
		wing_enchant_replace_c2s->
			Message=login_pb:decode_wing_enchant_replace_c2s(Binary),
			wing_packet:handle(Message, RolePid);

		
		%%丹药【xiaowu】
		get_furnace_queue_info_c2s->%%请求丹药队列信息
			Message=login_pb:decode_get_furnace_queue_info_c2s(Binary),
			furnace_packet:handle(Message, RolePid);
		create_pill_c2s->%%开始炼丹
			Message=login_pb:decode_create_pill_c2s(Binary),
			furnace_packet:handle(Message, RolePid);
		get_furnace_queue_item_c2s->%%提取炼丹
			Message=login_pb:decode_get_furnace_queue_item_c2s(Binary),
			furnace_packet:handle(Message, RolePid);
		accelerate_furnace_queue_c2s->%%炼丹加速
			Message=login_pb:decode_accelerate_furnace_queue_c2s(Binary),
			furnace_packet:handle(Message, RolePid);
		quit_furnace_queue_c2s->%%终止炼丹
			Message=login_pb:decode_quit_furnace_queue_c2s(Binary),
			furnace_packet:handle(Message, RolePid);
		unlock_furnace_queue_c2s->%%开启炼炉
			Message=login_pb:decode_unlock_furnace_queue_c2s(Binary),
			furnace_packet:handle(Message, RolePid);
		up_furnace_c2s->%%炼炉升级
			Message=login_pb:decode_up_furnace_c2s(Binary),
			furnace_packet:handle(Message, RolePid);
		
		
		%%占星
		astrology_init_c2s->%%占星初始化
			Message=login_pb:decode_astrology_init_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_action_c2s->%%一键占星
			Message=login_pb:decode_astrology_action_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_pickup_all_c2s->%%一键拾取
			Message=login_pb:decode_astrology_pickup_all_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_sale_all_c2s->%%一键卖出
			Message=login_pb:decode_astrology_sale_all_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_open_panel_c2s->%%打开面板计时
			Message=login_pb:decode_astrology_open_panel_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_add_money_c2s->%%补充星魂值
			Message=login_pb:decode_astrology_add_money_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_sale_c2s->%%卖出
			Message=login_pb:decode_astrology_sale_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_pickup_c2s->%%拾取
			Message=login_pb:decode_astrology_pickup_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_item_pos_c2s->%%道具开启
			Message=login_pb:decode_astrology_item_pos_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_mix_c2s->%%星座合成
			Message=login_pb:decode_astrology_mix_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_mix_all_c2s->%%一键合成
			Message=login_pb:decode_astrology_mix_all_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_lock_c2s->%%星座锁定
			Message=login_pb:decode_astrology_lock_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_expand_package_c2s->%%扩展星魂包裹
			Message=login_pb:decode_astrology_expand_package_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_active_c2s->%%开启人物身上星槽
			Message=login_pb:decode_astrology_active_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		search_role_c2s->%%@@wb20130509 查找角色
			Message=login_pb:decode_search_role_c2s(Binary),
			friend_packet:handle(Message, RolePid);
		astrology_swap_c2s->%%吞噬
			Message=login_pb:decode_astrology_swap_c2s(Binary),
			astrology_packet:handle(Message, RolePid);
		astrology_unlock_c2s->%%星座解锁
			Message=login_pb:decode_astrology_unlock_c2s(Binary),
			astrology_packet:handle(Message, RolePid);

		_UnknMsg -> slogger:msg("get unknown message ~p\n",[ID])
	end.
