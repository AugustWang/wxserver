%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : role_op.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created :  6 May 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(role_op).

-export([use_pet_egg_ext/3,can_use_egg/1,proc_use_iegg/4]).
-compile(export_all).

-include("login_pb.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("item_struct.hrl").
-include("map_def.hrl").
-include("common_define.hrl").
-include("creature_define.hrl").
-include("skill_define.hrl").
-include("error_msg.hrl").
-include("pet_struct.hrl").
-include("little_garden.hrl").
-include("mnesia_table_def.hrl").
-include("item_define.hrl").
-include("instance_define.hrl").
-include("map_info_struct.hrl").
-include("slot_define.hrl").
-include("string_define.hrl").
-include("system_chat_define.hrl").
-include("game_map_define.hrl").
-include("effect_define.hrl").
%%澧炲姞鏍囧噯鐨勬煡璇㈠簱  by zhangting
-include_lib("stdlib/include/qlc.hrl").

-define(SHOP,1).
-define(TRANS,2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鐢熸垚瑙掕壊杩涚▼鍚嶇О
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_role_proc_name(RoleId)->
	list_to_atom(integer_to_list(RoleId)).

%%faild/ok
init(GS_system_map_info, GS_system_gate_info, GS_system_role_info,AccountInfo) ->
	{Account,Pf,IsAdult,Ip,Is_yellow_vip,Is_yellow_year_vip,Yellow_vip_level,OpenId,OpenKey,PfKey} = AccountInfo ,
	put(client_ip,Ip),
	put(account_id,Account),
	put(is_adult,IsAdult),
	put(pf,Pf),
	put(login_time,timer_center:get_correct_now()),
	put(is_yellow_vip, Is_yellow_vip),
	put(is_yellow_year_vip, Is_yellow_year_vip),
	put(yellow_vip_level, Yellow_vip_level),
	put(openid, OpenId),
	put(openkey, OpenKey),
	put(pfkey, PfKey),
	%% 鎻愬彇鍩虹淇℃伅
	init_attribute(GS_system_map_info, GS_system_gate_info, GS_system_role_info),
	%%鍒濆鍖栬亰澶╄妭鐐逛俊鎭�
	GatePid = get_pid_from_gs_system_gateinfo(GS_system_gate_info),

	LineId = get_lineid_from_gs_system_mapinfo(GS_system_map_info),
	MapId = get_mapid_from_gs_system_mapinfo(GS_system_map_info),
	RoleId = get_id_from_gs_system_roleinfo(GS_system_role_info),
	Level = get(level),
	gm_logger_role:role_login(RoleId,Ip,Level),
	case tcp_client:role_process_started(GatePid, node(), make_role_proc_name(RoleId)) of
		error ->		%%鐜╁缃戝叧涓嶅瓨鍦�!
			self() ! {gm_kick_you},
			faild;
		{Chatnode,Chatproc}->
			tcp_client:role_into_map_success(GatePid),
			chat_op:init(Chatnode,Chatproc),
			
			%% 璇锋眰鍦板浘
			on_into_world(MapId, LineId),
			
			init_db_save_time(),
			start_all_timer(),
			ok
	end.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鍒濆鍖栬鑹叉暟鎹�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_attribute(GS_MapInfo, GS_GateInfo, GS_RoleInfo) ->
	RoleId = get_id_from_gs_system_roleinfo(GS_RoleInfo),
	role_private_option:load_rpc(),
	%% 璁剧疆鍦板浘淇℃伅
	case get_proc_from_gs_system_mapinfo(GS_MapInfo) of
		undefined->
			MapProc = undefined, 
			put(npcinfo_db,undefined);	
		MapProc->
			NpcInfoDB = npc_op:make_npcinfo_db_name(MapProc),
			put(npcinfo_db,NpcInfoDB)
	end,
	MapId = get_mapid_from_gs_system_mapinfo(GS_MapInfo),
	Map_db = mapdb_processor:make_db_name(MapId),
	put(map_db,Map_db),
	LineId = get_lineid_from_gs_system_mapinfo(GS_MapInfo),
	put(map_info, create_mapinfo(MapId, LineId, node(), MapProc, ?GRID_WIDTH)),			
	%% 璁剧疆缃戝叧淇℃伅
	put(gate_info, GS_GateInfo),	
	%% 鍒濆鍖栬鑹蹭俊鎭�
	init_roleinfo(RoleId,GS_MapInfo,GS_GateInfo,GS_RoleInfo),
	switch_to_gaming_state(RoleId).

on_into_world(MapId, LineId)->
	RoleInfo = get(creature_info),
	%%鍙戦�佽澶�
	send_items_onhands(),			
	%%鍙戦�佷换鍔�
	quest_op:send_quest_list(),
	everquest_op:send_everquest_list(),
	facebook:init(),
	%%鍙戦�佹妧鑳芥爮
	skill_op:send_skill_info(),
	send_display_hotbar(RoleInfo),
	%% 鐩存帴娣诲姞鍙戦�佹秷鎭紝鏀瑰彉浣嶇疆娑堟伅
	Position =  get_pos_from_roleinfo(RoleInfo),
	case instance_op:is_in_instance() of
		false->		
			case ?CHECK_INSTANCE_MAP(map_info_db:get_is_instance(map_info_db:get_map_info(MapId)))of
				true->			%%娌″湪鍓湰,浣嗘槸鍦ㄥ壇鏈湴鍥�,鏁版嵁瀛樺偍鏈夐敊璇�
%% 					{RespawnMapId,Pos} = mapop:get_respawn_pos(mapdb_processor:make_db_name(?DEFAULT_MAP)),
                    %%鐩墠娌℃湁../maps锛屾殏鏃跺皢姝ゆ椂澶嶆椿鐐规斁鍦▄300,{175,175}}
                    {RespawnMapId,Pos} = 
							case mapop:get_respawn_pos(mapdb_processor:make_db_name(?DEFAULT_MAP)) of
								[]->{300,{175,175}};
								MapPos->MapPos;
								_->{300,{175,175}}
								end,
					transport(RoleInfo, get(map_info),LineId,RespawnMapId,Pos);
				_->				%%鏈湪鍓湰鍦板浘
					case server_travels_util:is_share_maps(MapId) of
						true->				%%鐜╁鍦ㄨ法鏈嶅湴鍥�,浼犻�佸埌璺ㄦ湇鍦板浘
							transport(RoleInfo, get(map_info),LineId,MapId,Position);
						_->
							case mapop:check_pos_is_valid(Position,get(map_db)) of	
								false->						%%妫�鏌ュ潗鏍囨槸鍚﹀湪涓嶅彲琛岃蛋鍖哄煙
									{RespawnMapId,Pos} =  mapop:get_respawn_pos(get(map_db)), 
									transport(RoleInfo, get(map_info),LineId,RespawnMapId,Pos);
								true->
									Message = role_packet:encode_role_map_change_s2c(Position, MapId,LineId),
									send_data_to_gate(Message)
							end
					end	
			end;
		true->
			instance_op:on_line_by_instance(MapId,LineId,get(map_info))	
	end.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%local:for change map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
export_for_copy()->
	AccountInfo = {get(account_id),get(is_adult),get(client_ip),get(login_time),get(pf),get(is_yellow_vip),get(is_yellow_year_vip),get(yellow_vip_level),get(openid),get(openkey),get(pfkey)}, 
	{get(current_buffer),
	get(current_attribute),
	get(base_attr),
	get(other_attr),
	get(murderer),
	get(loot_index),
	continuous_logging_op:export_for_copy(),
	invite_friend_op:export_for_copy(), 
	role_game_rank:export_for_copy(),
	items_op:export_for_copy(),
	group_op:export_for_copy(),
	loop_instance_op:export_for_copy(),
	package_op:export_for_copy(),
	chat_op:export_for_copy(),
	quest_op:export_for_copy(),
	buffer_op:export_for_copy(),
	guild_op:export_for_copy(),
	skill_op:export_for_copy(),
	friend_op:export_for_copy(),
	achieve_op:export_for_copy(),
	instance_op:export_for_copy(),
	instance_quality_op:export_for_copy(),
	block_training_op:export_for_copy(),
	role_chess_spirits:export_for_copy(),
	activity_value_op:export_for_copy(),
	first_charge_gift_op:export_for_copy(),
	treasure_storage_op:export_for_copy(),
	role_mainline:export_for_copy(),
	guildbattle_op:export_for_copy(),
	country_op:export_for_copy(),
	spiritspower_op:export_for_copy(),
	AccountInfo,
	hp_package_gift:export_for_copy(),
	mp_package_gift:export_for_copy(),
	get(init_buffer_tmp),
	battle_ground_op:export_for_copy(),
	loop_tower_op:export_for_copy(),
	everquest_op:export_for_copy(),
	vip_op:export_for_copy(),
	series_kill:export_for_copy(),
	pet_op:export_for_copy(),
	role_soulpower:export_for_copy(),
	mall_op:export_for_copy(),
	timelimit_gift_op:export_for_copy(),
	role_private_option:export_for_copy(),
	answer_op:export_for_copy(),
	congratulations_op:export_for_copy(),
	auction_op:export_for_copy(),
	fatigue:export_for_copy(),
	venation_op:export_for_copy(),
	role_dragon_fight:export_for_copy(),
	role_global_op:export_for_copy(),
	role_server_travel:export_for_copy(),
	gm_role_privilege_op:export_for_copy(),
	offline_exp_op:export_for_copy(),
	goals_op:export_for_copy(),
	role_treasure_transport:export_for_copy(),
	gold_exchange:export_for_copy(),
	designation_op:export_for_copy(),
	consume_return:export_for_copy(),
	spa_op:export_for_copy(),
	pet_explore_op:export_for_copy(),
	open_service_activities:export_for_copy(),
	explore_storage_op:export_for_copy(),
	pvp_op:export_for_copy()
	}.
	
load_by_copy(CopyInfo)->
	{CurrentBuff,CurrentAttr,BaseAttr,OtherAttr,
	Murderer,Loot_index
	,Continuous_Info
	,Invite_friend_Info
	,JudgeInfo,ItemsInfo,GroupInfos,
	LoopInstanceInfo,
	PackageInfo,ChatInfo,QuestInfo,BufferInfo,GuildInfo,SkillInfo,FriendInfo,AchieveInfo,InstanceInfo,InstanceQualityInfo,TrainInfo,ChessInfo,
	ActivityValueInfo,
	FirstChargeGiftInfo,
	TreasureStorageInfo,
	MainLineInfo,
	GuildBattleInfo,
	CountryInfo,
	SpiritsPowerInfo,
	AccountInfo,HpPackage,MpPackage,InitBuffInfo,BattleGround,RoleLoopTower,EverQuestInfo,RoleVipInfo,SeriesKillInfo,PetsInfo,SoulPowerInfo,LatestBuyLog,TimeLimitGiftInfo,PriVateInfo,RoleAnswerInfo,
	RoleCongratuLog,AuctionInfo,FatigueInfo,VenationInfo,DragonFightInfo,GlobalInfo,ServertravelInfo,RolePrivilege,OfflineExpLog,GoalsInfo,TransportInfo,GoldConsumeInfo,DesignationInfo,ConsumeReturnInfo,
	SpaInfo,PetExploreInfo,OpenService,ExploreStorageInfo,PvpInfo} = CopyInfo,
	%%褰撳墠buff
 	{Account,IsAdult,Ip,LogInTime,Pf,Is_yellow_vip,Is_yellow_year_vip,Yellow_vip_level,OpenId,OpenKey,PfKey} = AccountInfo ,
	put(client_ip,Ip),
	put(account_id,Account),
	put(is_adult,IsAdult),
	put(login_time,LogInTime), 
	put(pf,Pf),
	put(is_yellow_vip, Is_yellow_vip),
	put(is_yellow_year_vip, Is_yellow_year_vip),
	put(yellow_vip_level, Yellow_vip_level),
	put(openid, OpenId),
	put(openkey, OpenKey),
	put(pfkey, PfKey),
	put(base_attr,BaseAttr),
	put(other_attr,OtherAttr),
	put(current_buffer, CurrentBuff),
	put(current_attribute,CurrentAttr),
	put(init_buffer_tmp,InitBuffInfo),
	put(murderer,Murderer),
	put(loot_index,Loot_index),
	trade_role:init(),
	spiritspower_op:load_by_copy(SpiritsPowerInfo),
	role_chess_spirits:load_by_copy(ChessInfo),
	role_global_op:load_by_copy(GlobalInfo),
	role_server_travel:load_by_copy(ServertravelInfo),
	role_private_option:load_by_copy(PriVateInfo),
	items_op:load_by_copy(ItemsInfo),
	group_op:load_by_copy(GroupInfos),
	loop_instance_op:load_by_copy(LoopInstanceInfo),
	package_op:load_by_copy(PackageInfo),
	quest_op:load_by_copy(QuestInfo),
	everquest_op:load_by_copy(EverQuestInfo),
	battle_ground_op:load_by_copy(BattleGround),
	role_dragon_fight:load_by_copy(DragonFightInfo),
	%%鍒濆鍖朿hat
	chat_op:load_by_copy(ChatInfo),
	%%閲嶆柊杞藉叆buffer
	buffer_op:init(),
	%%鍏細
	guild_op:load_by_copy(GuildInfo),
	country_op:load_by_copy(CountryInfo),
	guildbattle_op:load_by_copy(GuildBattleInfo),
	skill_op:load_by_copy(SkillInfo),
	block_training_op:load_by_copy(TrainInfo),
	instance_op:load_by_copy(InstanceInfo),
	instance_quality_op:load_by_copy(InstanceQualityInfo),
	friend_op:load_by_copy(FriendInfo),
	achieve_op:load_by_copy(AchieveInfo),
	goals_op:load_by_copy(GoalsInfo),
	loop_tower_op:load_by_copy(RoleLoopTower),
	vip_op:load_by_copy(RoleVipInfo),
	gm_role_privilege_op:load_by_copy(RolePrivilege),
	answer_op:load_by_copy(RoleAnswerInfo),
	spa_op:load_by_copy(SpaInfo),
	congratulations_op:load_by_copy(RoleCongratuLog),
	offline_exp_op:load_by_copy(OfflineExpLog),
	series_kill:load_by_copy(SeriesKillInfo),
	pet_op:load_by_copy(PetsInfo), 
	role_soulpower:load_by_copy(SoulPowerInfo),
	auction_op:load_by_copy(AuctionInfo),
	fatigue:load_by_copy(FatigueInfo),
	mall_op:load_by_copy(LatestBuyLog),
	role_mainline:load_by_copy(MainLineInfo),
	continuous_logging_op:load_by_copy(Continuous_Info),
	invite_friend_op:load_by_copy(Invite_friend_Info),
	
	role_game_rank:load_by_copy(JudgeInfo),
	pvp_op:load_by_copy(PvpInfo),
	activity_value_op:load_by_copy(ActivityValueInfo),
	first_charge_gift_op:load_by_copy(FirstChargeGiftInfo),
	treasure_storage_op:load_by_copy(TreasureStorageInfo),
	AllBufferInfo = buffer_op:get_from_copy(BufferInfo),
	hp_package_gift:load_by_copy(HpPackage),
	mp_package_gift:load_by_copy(MpPackage),
	timelimit_gift_op:load_by_copy(TimeLimitGiftInfo),
	venation_op:load_by_copy(VenationInfo),
	gold_exchange:load_by_copy(GoldConsumeInfo),
	role_treasure_transport:load_by_copy(TransportInfo),
	designation_op:load_by_copy(DesignationInfo),
	consume_return:load_by_copy(ConsumeReturnInfo),
	pet_explore_op:load_by_copy(PetExploreInfo),
	open_service_activities:load_by_copy(OpenService),
	explore_storage_op:load_by_copy(ExploreStorageInfo),
	init_buffers_by_node(AllBufferInfo).

%%杩斿洖鐢ㄦ埛褰撳墠鐘舵��	
copy_init(MapInfo, RoleInfo, GateInfo, X, Y,CopyInfo)->
	%%閲嶆柊娉ㄥ唽鍏ㄥ眬淇℃伅
	RoleId = get_id_from_roleinfo(RoleInfo),
	RoleName = get_name_from_roleinfo(RoleInfo),
	NewRoleproc = make_role_proc_name(RoleId),
	NewRolenode = get_node_from_mapinfo(MapInfo),
	MapProc = get_proc_from_mapinfo(MapInfo),
	NpcInfoDB = npc_op:make_npcinfo_db_name(MapProc),
	put(npcinfo_db,NpcInfoDB),		
	MapId = get_mapid_from_mapinfo(MapInfo),
	LineId = get_lineid_from_mapinfo(MapInfo),
	Map_db = mapdb_processor:make_db_name(MapId),
	put(map_db,Map_db),				
	%%瀵煎叆鏁版嵁		
	ClassId = get_class_from_roleinfo(RoleInfo),
	Level = get_level_from_roleinfo(RoleInfo),
	%%淇℃伅鍒濆鍖�
	put(map_info, MapInfo),	
	%%Pid宸茬粡鍦╮ole_manager鐨刢opy閲岃缃繃
	put(creature_info, RoleInfo),	
	GS_MapInfo = #gs_system_map_info{map_id=get_mapid_from_mapinfo(MapInfo),
						 line_id=get_lineid_from_mapinfo(MapInfo), 
						 map_proc=get_proc_from_mapinfo(MapInfo), 
						 map_node=get_node_from_mapinfo(MapInfo)},  
	put(creature_info, set_mapinfo_to_roleinfo(get(creature_info), GS_MapInfo)), 
	put(creature_info, set_node_to_roleinfo(get(creature_info), NewRolenode)),
	put(creature_info, set_pos_to_roleinfo(get(creature_info), {X, Y})), 	 
	put(gate_info, GateInfo),
	put(aoi_list,[]),
	put(classid, ClassId),
	put(level, Level),
	put(is_in_world,false),
	set_leave_attack_time([],{0,0,0}),
	put(last_cast_time,{0,0,0}),
	put(last_nor_cast_time,{0,0,0}),
	Expr = get_exp_from_roleinfo(get(creature_info)),
	NowLevelExp = role_level_db:get_level_experience(Level),	
	put(current_exp,Expr+NowLevelExp),		
	loot_op:init_loot_list(),
	block_training_op:init(),
	role_sitdown_op:init(),	
	load_by_copy(CopyInfo),

	
	%%娉ㄥ唽鐜╁淇℃伅
	update_role_info(RoleId,get(creature_info)),
	role_op:change_map_in_other_node_end(RoleInfo, MapInfo, X, Y),
	GateNode = get_node_from_gs_system_gateinfo(GateInfo),
	GateProc = get_proc_from_gs_system_gateinfo(GateInfo),
	role_pos_db:reg_role_pos_to_mnesia(RoleId,LineId,MapId,RoleName,NewRolenode,NewRoleproc,GateNode,GateProc),
  	%%鍒濆鍖栨娊濂�
  	lottery_op:on_playeronline(),	
	init_db_save_time(),
	start_all_timer(),
	case get(is_adult) of
		false-> fatigue:init();
		true-> ignor
	end.
	
get_processor_state_by_roleinfo()->	
	case get_state_from_roleinfo(get(creature_info)) of
		deading->
			deading;
		sitting->
			sitting;
		_->
			gaming
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鍙嶅垵濮嬪寲瑙掕壊鏁版嵁!!!缁勯槦杞Щ闃熼暱,鏇存柊缁勯槦淇℃伅,鏇存柊鍓湰淇℃伅
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
relocating_on_uninit()->
	%%浣嶇疆淇
	case is_dead() of
		true->	
			case get_my_respwan_pos() of
				[]->
					nothing;
				{RespawnMapId,RespawnPos}->
					put(creature_info, set_pos_to_roleinfo(get(creature_info), RespawnPos)),
					put(map_info,set_mapid_to_mapinfo(get(map_info), RespawnMapId))
			end;
		_->
			nothing
	end,
%%	end,
	%%琛�閲忎慨姝�
	case is_dead() of
		true->	
			ModifyHp = erlang:trunc(get_hpmax_from_roleinfo(get(creature_info))*10/100), 			
			put(creature_info, set_state_to_roleinfo(get(creature_info), gaming)),
			put(creature_info, set_life_to_roleinfo(get(creature_info), ModifyHp ));		
		_->
			nothing
	end.

uninit(uninit,RoleId) ->
	try
		relocating_on_uninit()
	catch
		E:R-> slogger:msg("role_op:uninit dead_on_uninit error ~p:~p ~p ~n",[E,R,erlang:get_stacktrace()])
	end,
	try
		group_op:hook_on_offline()			%%缁勯槦
	catch
		E1:R1-> slogger:msg("role_op:uninit group_op:logout error ~p:~p ~p ~n",[E1,R1,erlang:get_stacktrace()])
	end,
	try
		guild_op:on_leave()			%%鍏細
	catch
		E2:R2-> slogger:msg("role_op:uninit guild_op:on_leave error ~p:~p ~p ~n",[E2,R2,erlang:get_stacktrace()])
	end,
	try
		instance_op:on_offline()	%%鍓湰
	catch
		E3:R3-> slogger:msg("role_op:uninit instance_op:on_offline() error ~p:~p ~p ~n",[E3,R3,erlang:get_stacktrace()])
	end,
	try
		battle_ground_op:hook_on_offline()
	catch
		E31:R31-> slogger:msg("role_op:uninit battle_ground_op:hook_on_offline error ~p:~p ~p ~n",[E31,R31,erlang:get_stacktrace()])
	end,	
	try
		friend_op:offline_notice()	%%濂藉弸
	catch
		E4:R4-> slogger:msg("role_op:uninit friend_op:offline_notice() ~p:~p ~p ~n",[E4,R4,erlang:get_stacktrace()])
	end,
	try
		loop_tower_op:on_offline()	%%杞洖濉�
	catch
		E5:R5-> slogger:msg("role_op:uninit loop_tower_op:on_offline() error ~p:~p ~p ~n",[E5,R5,erlang:get_stacktrace()])
	end,
	try
		series_kill:on_offline()
	catch
		E6:R6-> slogger:msg("role_op:uninit series_kill:on_offline() error ~p:~p ~p ~n",[E6,R6,erlang:get_stacktrace()])
	end,
	try		
		timelimit_gift_op:on_playeroffline()
	catch
		E8:R8-> slogger:msg("role_op:uninit timelimit_gift_op:on_playeroffline() error ~p:~p ~p ~n",[E8,R8,erlang:get_stacktrace()])
	end,
	try
		answer_op:hook_on_offline()	%%绛旈
	catch
		E9:R9-> slogger:msg("role_op:uninit answer_op:hook_on_offline() error ~p:~p ~p ~n",[E9,R9,erlang:get_stacktrace()])
	end,
	try
		congratulations_op:hook_on_offline()	%%鏂版墜绁濊春
	catch
		E10:R10-> slogger:msg("role_op:uninit congratulations_op:hook_on_offline() error ~p:~p ~p ~n",[E10,R10,erlang:get_stacktrace()])
	end,
	try
		fatigue:on_playeroffline()
	catch
		E11:R11-> slogger:msg("role_op:uninit fatigue:on_playeroffline() error ~p:~p ~p ~n",[E11,R11,erlang:get_stacktrace()])
	end,
	try
		offline_exp_op:hook_on_offline()	%%绂荤嚎缁忛獙
	catch
		E12:R12-> slogger:msg("role_op:uninit offline_exp_op:hook_on_offline() error ~p:~p ~p ~n",[E12,R12,erlang:get_stacktrace()])
	end,
	try
		venation_op:hook_on_offline()	    %%缁忚剦
	catch
		E13:R13-> slogger:msg("role_op:uninit venation_op:hook_on_offline error ~p:~p ~p ~n",[E13,R13,erlang:get_stacktrace()])
	end,
	try
		continuous_logging_op:on_player_offline()	   
	catch
		E14:R14-> slogger:msg("role_op:uninit continuous_logging_op:on_player_offline error ~p:~p ~p ~n",[E14,R14,erlang:get_stacktrace()])
	end,
	try
		role_game_rank:on_player_offline()	   
	catch
		E15:R15-> slogger:msg("role_op:uninit role_game_rank:on_player_offline error ~p:~p ~p ~n",[E15,R15,erlang:get_stacktrace()])
	end,
	try			%%鍏冨疂娑堣�楀厬鎹㈢ぜ鍒�
		gold_exchange:hook_on_offline()
	catch
		E17:R17-> slogger:msg("role_op:uninit gold_exchage:hook_on_offline ~p:~p ~p ~n",[E17,R17,erlang:get_stacktrace()])
	end,
	try
		role_treasure_transport:hook_on_offline()
	catch
		E18:R18-> slogger:msg("role_op:uninit role_treasure_transport:hook_on_offline ~p:~p ~p ~n",[E18,R18,erlang:get_stacktrace()])
	end,
	try			%%鍏冨疂娑堣�楀厬鎹㈢墿鍝�
		consume_return:hook_on_offline()
	catch
		E19:R19-> slogger:msg("role_op:uninit consume_return:hook_on_offline ~p:~p ~p ~n",[E19,R19,erlang:get_stacktrace()])
	end,
	try			
		spa_op:hook_on_offline()
	catch
		E20:R20-> slogger:msg("role_op:uninit spa_op:hook_on_offline() ~p:~p ~p ~n",[E20,R20,erlang:get_stacktrace()])
	end,	
	try			%%涓荤嚎
		role_mainline:uninit()
	catch
		Emainline:Rmainline-> slogger:msg("role_op:uninit role_mainline:uninit ~p:~p ~p ~n",[Emainline,Rmainline,erlang:get_stacktrace()])
	end,
	try	
		guildbattle_op:hook_offline()
	catch
		Eguildbattle:Rguildbattle-> slogger:msg("role_op:uninit guildbattle_op:hook_offline() ~p:~p ~p ~n",[Eguildbattle,Rguildbattle,erlang:get_stacktrace()])
	end,
	try	
		loop_instance_op:uninit()
	catch
		ELoopInstance:RLoopInstance-> slogger:msg("role_op:uninit loop_Instance_op:uninit() ~p:~p ~p ~n",[ELoopInstance,RLoopInstance,erlang:get_stacktrace()])
	end,
	uninit(change_map,RoleId),
	OnlineTIME = trunc(timer:now_diff(timer_center:get_correct_now(),get(login_time))/1000000),	
	gm_logger_role:role_logout(RoleId,get(client_ip),OnlineTIME,get(level));

uninit(change_map,RoleId) ->
	async_save_to_roledb(),
	dmp_op:flush_bundle(RoleId),
	gm_logger_role:role_flush_items(RoleId,get(items_info)),
	trade_role:interrupt(),
	role_private_option:flush(),
	mall_op:save_to_db(),
	open_service_activities:on_player_off_line(),
	vip_op:hook_on_offline(),
	goals_op:save_to_db().
	%%fatigue:on_playeroffline().

init_roleinfo(Role_id,GS_MapInfo,GS_GateInfo,GS_system_role_info) ->
	put(creature_info,create_roleinfo()),
	Role_pid = get_pid_from_gs_system_roleinfo(GS_system_role_info),
	Role_node = get_node_from_gs_system_roleinfo(GS_system_role_info),
	%%浠庢暟鎹簱涓鍙栦汉鐗╀俊鎭�
	{Role_pos,Silver,BoundSilver,Role_Level,Gold,Ticket,Role_Class,Expr,Hp,Mp,Role_name,_ClassBase,Commoncool,PackSize,GroupID,Gender,GuildId,AllBuffersInfo,TrainingInfo,OffLine,PvPInfo,PetInfo,SoulPowerInfo,StallName,Honor}
	= read_from_roledb(Role_id),
	MapId = get_mapid_from_mapinfo(get(map_info)),
	case OffLine of
		{0,0,0}->				%%鍙戦�佹柊鎵嬮�氱煡
			NewCommerMsg = role_packet:encode_is_jackaroo_s2c(),
			send_data_to_gate(NewCommerMsg);
		_->
			nothing
	end,	
	%% 娉ㄥ唽鍏ㄥ眬瑙掕壊淇℃伅
	RoleProc = role_op:make_role_proc_name(Role_id),
	Rolenode = get_node_from_gs_system_roleinfo(GS_system_role_info),
	Gatenode = get_node_from_gs_system_gateinfo(GS_GateInfo),
	Gateproc = get_proc_from_gs_system_gateinfo(GS_GateInfo),
	LineId = get_lineid_from_gs_system_mapinfo(GS_MapInfo),
	role_pos_db:reg_role_pos_to_mnesia(Role_id,LineId,MapId,Role_name,Rolenode,RoleProc,Gatenode,Gateproc),
	%%杩涚▼瀛楀吀
	put(aoi_list,[]),
	put(classid, Role_Class),
	put(level, Role_Level),
	put(is_in_world,false),
	put(current_buffer, []),	
	put(murderer,0),
	set_leave_attack_time([],{0,0,0}),
	put(last_cast_time,{0,0,0}),
	put(last_nor_cast_time,{0,0,0}),
	NowLevelExp = role_level_db:get_level_experience(Role_Level),
	NexLevelexp = role_level_db:get_level_experience(Role_Level+1),
	put(current_exp,Expr+NowLevelExp),							%%鍒濆鍖栨�荤粡楠�	
	case NexLevelexp of
		noleve -> LevelupExp = 0;
		_ -> %%LevelupExp = erlang:min(2147483647,NexLevelexp - NowLevelExp)				%%鍗囩骇鎵�闇�缁忛獙
			LevelupExp = NexLevelexp - NowLevelExp
	end,
	%%鍒濆鍖栧叏灞�杩涚▼淇℃伅
	role_global_op:init(),
	%%鍒濆鍖栦氦鏄�
	trade_role:init(),	
	%%鍒濆鍖栫墿鍝佷俊鎭�
	items_op:load_from_db(Role_id),
	%%鍒濆鍖朾uff		
	buffer_op:init(),		
	%%鍒濆鍖栨帀钀芥Ы鍒楄〃
	loot_op:init_loot_list(),
	%%鍒濆鍖栧寘瑁逛俊鎭紝瑁呭妲戒俊鎭�	
	package_op:init_package(PackSize),
	
	%%鍒濆鍖栦换鍔″垪琛�
	quest_op:init(),
	%%寰幆浠诲姟
	everquest_op:init(),
	quest_op:load_from_db(Role_id),
	%%鍒濆鍖栧ソ鍙嬪垪琛�,骞挎挱涓婄嚎閫氱煡
	friend_op:load_friend_from_db(Role_id),
	friend_op:load_befriend_from_db(Role_id),
	friend_op:load_black_from_db(Role_id),
	friend_op:load_signature_from_db(Role_id),
	%%鍒濆鍖栨垚灏变俊鎭�
	achieve_op:load_achieve_role_from_db(Role_id),
	%%涓硅嵂
	furnace_op:load_from_db(Role_id),
	%%鍗犳槦
	astrology_op:init(Role_id,Role_Level),%锛堝洜涓烘彁浜や腹鑽唬鐮侊紝鍗犳槦瀹屾垚鍔熻兘鍚庢墦寮�锛�
	%%鍒濆鍖栫洰鏍囦俊鎭�
	goals_op:load_role_goals_from_db(Role_id),
	%%鏂版墜绁濊春
	congratulations_op:load_from_db(Role_id),
	%%绂荤嚎缁忛獙
	offline_exp_op:load_from_db(Role_id),
	%%鍒濆鍖朾uff
	buffer_op:init(),
	%%鍒濆鍖栧壇鏈俊鎭�
	instance_op:load_from_db(Role_id),
	%% 鍒濆鍖栧壇鏈搧璐ㄤ俊鎭�
	instance_quality_op:load_from_db(Role_id),
	%%鍒濆鍖栨垬鍦轰俊鎭�
	battle_ground_op:init(),
	%%鍒濆鍖栬疆鍥炲淇℃伅
	loop_tower_op:load_from_db(Role_id),
	%%鍒濆鍖朧IP淇℃伅
	vip_op:load_from_db(Role_id),
	%%鍒濆鍖栨帓琛屾鏌ョ湅淇℃伅
	role_game_rank:load_from_db(Role_id),
	%%鍒濆鍖栬鑹叉潈闄�
	gm_role_privilege_op:load_from_db(Role_id),
	%%鍒濆鍖栨渶杩戣喘涔颁俊鎭�
	mall_op:load_role_latest_from_db(Role_id),
	mall_op:load_role_buy_item_log_from_db(Role_id),
	%%鍒濆鍖栧疂绠变粨搴�
	treasure_storage_op:init(),
	%%鍒濆鍖栧疂绠�
	role_levelup_opt:init(Role_id),
	Viptag = vip_op:get_role_vip(),
	%%鍒濆鍖栬繛鏂�
	series_kill:init(),
	%%鍒濆鍖栨墦鍧�
	role_sitdown_op:init(),
	random:seed(now()),
	%%鍒濆鍖栨妧鑳�
	skill_op:init_skill_info(Role_id),
	%%妫嬮瓊鍒濆鍖�
	role_chess_spirits:init(),
	%%鏆撮緳鍒濆鍖�
	role_dragon_fight:init(),
	%%鎽嗘憡
	case StallName of
		[]->
			auction_op:load_from_db(util:safe_binary_to_list(Role_name) ++ language:get_string(?STR_SELL_NAME));
		_->
			auction_op:load_from_db(StallName)
	end,
	%%鏂版墜鍗�
	role_giftcard_op:hook_on_online(Role_id),
	%%鍒濆鍖栧疇鐗�
	pet_op:load_from_db(PetInfo),
	
	%%鍒濆鍖栫粡鑴�
	venation_op:init(),
	%%鍒濆鍖栫О鍙�
	designation_op:init(Role_id),
	%%鍒濆鍖栭鍓戜俊鎭�
	wing_op:init_wing_info(Role_id),
	CurDesignation = get(cur_designation),
	%%璁＄畻鍒濆浜虹墿灞炴��,buffer鐨勫湪on_into_world閲屾坊鍔�
	{Power,Hprecover,CriDerate,Mprecover,MovespeedRate,Meleeimmunity,Rangeimmunity,Magicimmunity,Hpmax,Mpmax,Stamina,Strength,
	Intelligence,Agile,Meleedefense,Rangedefense,Magicdefense,Hitrate,Dodge,Criticalrate,Toughness,Imprisonment_resist,Silence_resist,
	Daze_resist,Poison_resist,Normal_resist,Fighting_Force} = compute_attrs(init,Role_Level),	
	%%鑾峰彇鍏細淇℃伅
	guild_op:init(GuildId,LineId,Role_Level,MapId),
  
	GuildName = guild_util:get_guild_name(),
	GuildPosting = guild_util:get_guild_posting(),
	%%澶磋
	AllIcons = role_game_rank:get_all_role_types(Role_id),
	%%PK淇℃伅
	{Pkmodel,Crime} = PvPInfo, 
	%%init
	RoleState = gaming,
	RoleSpeed = erlang:trunc(?BASE_MOVE_SPEED*(100+ MovespeedRate)/100),
	RoleLife = erlang:min(Hp, Hpmax),
	RoleMana = erlang:min(Mp, Mpmax),
	Path = [],
	RoleIimmunes = {Magicimmunity,Rangeimmunity,Meleeimmunity},
	RoleDebuffimmunes =  {Imprisonment_resist,Silence_resist,Daze_resist,Poison_resist,Normal_resist},
	RoleDefenses = {Magicdefense,Rangedefense,Meleedefense},
	RoleBuffs = get(current_buffer),
	RoleServerId = env:get(serverid,0),
	Treasure_transport = 0,
	%%init creature_info
	put(creature_info,
		set_roleinfo(get(creature_info),Role_id,Role_Class,Gender,Role_Level,RoleState,Role_pid,Role_node,Role_pos,
		Role_name,RoleSpeed,RoleLife,Hpmax,RoleMana,Mpmax,Expr,Silver,BoundSilver,LevelupExp,
		Gold,Ticket,Power,Commoncool,Hprecover,Mprecover,CriDerate,Criticalrate,Toughness,Dodge,
		Hitrate,Stamina,Agile,Strength,Intelligence,RoleIimmunes,RoleDebuffimmunes,RoleDefenses,GuildName,GuildPosting,
		RoleBuffs,Viptag,AllIcons,Crime,Pkmodel,Path,GS_GateInfo,GS_MapInfo,RoleServerId,CurDesignation,Treasure_transport,Fighting_Force,Honor)),
	%%娓╂硥
	spa_op:init(),
	%%鍒濆鍖栫绾跨粡楠�
	offline_exp_op:offline_exp_init(),
	%%鍒濆鍖栧叏鏈嶈繍闀�
	role_treasure_transport:hook_on_line(),
	%%鍒濆鍖栫伒鍔涗俊鎭�
	%%NewSoulPowerInfo = 
	role_soulpower:init(SoulPowerInfo),
	%%鍒濆鍖杙k
	pvp_op:init(),
	%%瑁呭淇℃伅
	{ClotheTemId,ArmTemId} = item_util:get_role_cloth_and_arm_dispaly(),
	put(creature_info,set_cloth_to_roleinfo(get(creature_info),ClotheTemId)),
	put(creature_info,set_arm_to_roleinfo(get(creature_info),ArmTemId)),
  	%%鍒濆鍖栨娊濂�
  	lottery_op:on_playeronline(),		
	%%鍒濆鍖栭檺鏃剁ぜ鍖�
	%%绗竴娆＄櫥闄� 灏忚姳鍥� 涓嶈繘琛屽垵濮嬪寲 淇敼鍒扮寮�灏忚姳鍥悗  so ugly!
	case MapId of
		?JACKAROO_MAP->	
			nothing;
		_->
			timelimit_gift_op:on_playeronline()
	end,
  	%%鎸傛満鍒濆鍖�
	block_training_op:load_from_db(TrainingInfo),
	case get(is_adult) of
		false-> fatigue:on_playeronline(get(account_id));
		true->ignor
	end,
	
	spiritspower_op:init(),
	
	%%init閲岄渶瑕佸彂缁欏鎴风鐨勪竴鍫嗕俊鎭�:
	%%鍙戦�佷汉鐗╂暟鎹�
	send_role_attribute(get(creature_info)),
	%%鍙戦�佸疇鐗╂暟鎹�
	pet_op:send_init_data(),
	%%鍒濆鍖栫粍闃熷垪琛�
	group_op:load_from_db(GroupID),
	update_role_info(Role_id,get(creature_info)),
	%%鍙戦�佸ソ鍙嬫暟鎹�
	friend_op:send_friend_list(),
	friend_op:send_black_list(),
	friend_op:send_signature(),
	
	%%閭欢鍒濆鍖�		搴旇鍦ㄦ墍鏈夌殑閭欢鍙戦�佷箣鍓�
  	mail_op:on_playeronline(),
  	
	%%鎴愬氨淇℃伅鍒濆鍖栫粰client
	achieve_op:achieve_init(),
	
	%%鍒濆鍖栨椿璺冨害
	activity_value_op:init(),
	
	%%鍙戦�乂IP鏃ュ鍔变俊鎭�
	vip_op:vip_init(),
	activity_state_op:init(),
	%%鍒濆鍖栦汉鐗╁晢鍩庣Н鍒�
	mall_op:init_role_mall_integral(Role_id),
	%%鍒濆鍖栧紑鏈嶆椿鍔�
	open_service_activities:load_from_db(Role_id),
	%%鍒濆鍖栧疇鐗╀粨搴�
%% 	explore_storage_op:init(Role_id),
	%%鍒濆鍖栧疇鐗╂帰闄�
%% 	pet_explore_op:on_playeronline(Role_id),
	first_charge_gift_op:init(),
	%%鍒濆鍖栫帺瀹舵渶杩戣喘涔扮墿鍝�
	mall_op:init_role_latest_buy(),
	mall_op:init_hot_item(),
	%%鍒濆鍖栧疇鐗╂帓琛屾
	pet_op:init_pet_talent_rank_sort(),
	
	%%鍒濆绛旈
	answer_op:init(Role_id),
  	role_server_travel:init(),
  	%%鍒濆鍖栨秷鑰楀厓瀹濆厬鎹㈢ぜ鍒告椿鍔�
	gold_exchange:init(),
	%%鍒濆鍖栨秷鑰楀厓瀹濆厬鎹㈢墿鍝佹椿鍔�
	consume_return:init(Role_id),
	%%鍒濆鍖栬繍闀�
	role_treasure_transport:load_from_db(Role_id),
	%%鍒濆鍖栦富绾�
	role_mainline:init(),
	%%鍒濆鍖栧府浼氬壇鏈�
	guild_instance:hook_on_line(),
	%%甯細鎴� 鍥界帇浜夊ず鎴�
	guildbattle_op:init(),
	%%鍥藉妯″潡 after guild init
	country_op:init(),
	festival_op:init_tab_isshow(),
	loop_instance_op:init(),
  	%%buff淇℃伅瑕佺瓑瀹㈡埛绔痬ap鍔犺浇瀹屾垚鍚庡彂閫�
	put(init_buffer_tmp,AllBuffersInfo),
	continuous_logging_op:load_from_db(Role_id),
    invite_friend_op:load_from_db(Role_id),
	goals_op:init_role_goals().

get_position_from_dbrecord(Result) ->
	{_, _, _,_,_,_,_,_, Location, _MapId} = Result,
	[X, Y] = string:tokens(binary_to_list(Location), ","),
	{list_to_integer(X), list_to_integer(Y)}.

roleinfo(AOI_roles_info) ->
	Extract_role_info = fun(RoleInfo) ->
					    Name = get_name_from_roleinfo(RoleInfo),
					    Id = get_id_from_roleinfo(RoleInfo),
					    {X, Y} = get_pos_from_roleinfo(RoleInfo),
					    #rl{roleid=Id, name=Name, x=X, y=Y, friendly=true}
			    end,
	lists:map(Extract_role_info, AOI_roles_info).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 瀹㈡埛绔彂閫佸湴鍥惧姞杞藉畬鎴愭秷鎭�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
map_complete_online()->
	items_op:check_item_overdue_interval(),
	battle_ground_op:hook_on_online(),
	Power = get_power_from_roleinfo(get(creature_info)),
	Class = get_class_from_roleinfo(get(creature_info)),
	gm_logger_role:role_power_gather(get(roleid),Power,Class,get(level)),
	pet_op:hook_on_online_join_map(),
	role_dragon_fight:hook_on_map_complate_online(),
	role_game_rank:gather_role_rank(),
	activity_manager:role_online_notify(get(roleid)).
	
map_complete(SelfInfo, MapInfo) ->	
	case get(init_buffer_tmp) of
		undefined->
			nothing;
		AllBuffersInfo->			%%璧板埌杩欓噷鏄涓�娆¤繘鍏ヤ笘鐣�,鎵�浠ュ彲浠ュ仛涓�涓猰ap_complete_online
			%%鍙戦�乥uffer淇℃伅:瀹㈡埛绔渶瑕乥uff鍦ㄨ繘鍏ヤ笘鐣屽悗鍐嶅彂閫�!
			erase(init_buffer_tmp),
			NowBuffers = buffer_op:load_from_db(AllBuffersInfo),	
			init_buffers_on_role(NowBuffers),
			map_complete_online()
	end,
	MapId = get_mapid_from_mapinfo(MapInfo),
	case map_info_db:get_map_info(MapId) of
		[]->
			nothing;
		MapProtoInfo->
			RestrictItems = map_info_db:get_restrict_items(MapProtoInfo),
			put(restrict_items,RestrictItems),
			map_script:run_script(on_join,MapProtoInfo)
	end,
	put(creature_info, set_path_to_roleinfo(get(creature_info), [])),
	RoleId = get_id_from_roleinfo(SelfInfo),
	%% 鍒囨崲涓烘父鎴忕姸鎬�
	creature_op:join(SelfInfo, MapInfo),		
	Role_Class = get_class_from_roleinfo( SelfInfo),
	Role_Level = get_level_from_roleinfo( SelfInfo),
	buffer_op:generate_hprecover(Role_Class,Role_Level),	
	buffer_op:generate_mprecover(Role_Class,Role_Level),
	update_role_info(RoleId, get(creature_info)),
	block_training_op:on_map_complete(),
	role_mainline:hook_map_complete(),
	battle_ground_op:hook_map_complete(),
	guildbattle_op:hook_map_complete(),
	loop_tower_op:on_map_complete(),
	loop_instance_op:hook_map_complete().

leave_map(RoleInfo,MapInfo)->
	set_move_timer(0),
	buffer_op:stop_mprecover(),
	buffer_op:stop_hprecover(),
	creature_op:leave_map(RoleInfo, MapInfo),
	object_update:send_pending_update().

send_role_attribute(RoleInfo) ->		
	CreateObj = object_update:make_create_data(?UPDATETYPE_SELF,RoleInfo),
	GateProc = get_proc_from_gs_system_gateinfo(get(gate_info)),
	tcp_client:object_update_create(GateProc,CreateObj),
  	object_update:send_pending_update().
	
send_items_onhands()->
	%%鍙戦��
	HandsonItemid = package_op:get_items_id_on_hands(),
	HandsonItemInfo = lists:map(fun(Id)->items_op:get_item_info(Id)end,HandsonItemid),
	Message = role_packet:encode_init_onhands_item_s2c(HandsonItemInfo),
	send_data_to_gate(Message).

send_items_on_storage(NpcId)->
	StorageIds = package_op:get_items_id_on_storage(),
	StorageInfo = lists:map(fun(Id)->items_op:get_item_info_storage(Id) end,StorageIds),
	Message = role_packet:encode_npc_storage_items_s2c(NpcId,StorageInfo),
	send_data_to_gate(Message).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%						鐜╁Timer					   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
do_role_game_interval()->
	Now = timer_center:get_correct_now(),
	handle_db_save_timer(Now),
	role_sitdown_op:check_sitdown_time(Now),
	pvp_op:clear_crime(Now),
	%%妫�鏌ョ伒榄傚姏娓呴浂
%TODO 鐏甸瓊鍔涳紵锛燂紵
	spiritspower_op:check_timer(Now),
	%%闄愭椂绀煎寘閲嶇疆
	timelimit_gift_op:reset_gift(Now),
	%%鎴愬氨涓嶉渶瑕佸湪姝ゆ洿鏂�
%% 	achieve_op:role_attr_update(),
	pet_op:send_levelup_message(),
	start_role_game_timer().

init_db_save_time()->
	put(db_save_time,timer_center:get_correct_now()).

start_all_timer()->
	start_role_game_timer().

start_role_game_timer()->
%% 	nothing.
	erlang:send_after(?ROLE_GAME_TIME,self(),{role_game_timer}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 闂撮殧瑙﹀彂瀛樺簱/閫�鍑哄墠瀛樺簱 ,1.鍒犻櫎杩囨湡鐗╁搧,2.瀛樺偍鏁版嵁搴�,3.鎺掕姒滄暟鎹洿鏂�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle_db_save_timer(Now)->
	Time = timer:now_diff(Now,get(db_save_time)) ,
	case Time >= ?DB_SAVE_TIME*1000 of
		true->
			RoleId = get(roleid),
			gm_logger_role:role_flush_items(RoleId,get(items_info)),
			%%鍒犻櫎杩囨湡鐗╁搧
			items_op:check_item_overdue_interval(),
			async_save_to_roledb(),
			dmp_op:flush_bundle(RoleId),
			%%鍋氫竴涓嬫帓琛屾鏁版嵁鏇存柊
			role_game_rank:gather_role_rank(),
			put(db_save_time,Now);
		false->
			nothing
	end.
	
async_save_to_roledb()->
	{A,B,C}=timer_center:get_correct_now(),%%%%%%%%%@@wb20130604 娴嬭瘯鍘嬪姏锛屼复鏃朵慨鏀�
	put(db_save_time,{A,B+random:uniform(10),C}),%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 	put(db_save_time,timer_center:get_correct_now()),
	async_write_to_roledb(),
	%%鐗╁搧瑕佸悓姝ュ啓
	items_op:save_to_db(),
	quest_op:async_write_to_db(),
	skill_op:async_save_to_db(),
	instance_op:write_to_db(),
	pet_op:save_to_db().
	%%timelimit_gift_op:save_to_db().
	
%%save_to_db()->
%%	write_to_roledb(),
%%	items_op:save_to_db(),
%%	quest_op:write_to_db(),
%%	skill_op:save_to_db(),
%%	instance_op:write_to_db(),
%%	pet_op:save_to_db().	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鏀诲嚮鍒汉浜�,缁欒鏀诲嚮鑰呭彂AttackInfo :{AttackerId, TargetID, ?SKILL_NORMAL, Damage, SkillId,SkillLevel}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
attacked_broadcast(SelfId, FlyTime, BeAttackedUnits) ->	
	lists:foreach(fun({CreatureId,Pid})->
			case lists:keyfind(CreatureId, 2, BeAttackedUnits)  of
				false->
					nothing;
				AttackInfo->
					erlang:send_after(FlyTime, Pid, {other_be_attacked,AttackInfo})
			end	
	end,get(aoi_list)),	
	case lists:keyfind(SelfId, 2, BeAttackedUnits) of
		false->
			nothing;
		AttackInfo->
			erlang:send_after(FlyTime, self(), {other_be_attacked,AttackInfo})
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鑷繁琚墦浜�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
other_be_attacked({EnemyId, _, _, Damage, _,_}, SelfInfo) ->
	SelfId = get(roleid),            
	OtherInfo = creature_op:get_creature_info(EnemyId),   
	IsGod = combat_op:is_target_god(SelfInfo),
	Now = timer_center:get_correct_now(),
	creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_BEATTACK),
	case ((OtherInfo=:=undefined) or IsGod or is_dead()) of
		true->
			NextState = get_state_from_roleinfo(SelfInfo);
		_->	                          
			trade_role:interrupt(),
			%% 浼ゅ鍒楄〃涓湁鑷繁	
			NowHp = get_life_from_roleinfo(SelfInfo),	
			MaxHp = get_hpmax_from_roleinfo(SelfInfo),
			set_leave_attack_time(EnemyId,Now),			
			NewLiftOri = erlang:min(MaxHp,erlang:max(NowHp + Damage, 0)),			 			
			if 
				NewLiftOri =/= NowHp->
					ChangedAttrLife = [{hp, NewLiftOri}];							
				true->
					ChangedAttrLife = []
			end,
			%%鎴樺＋鍔犳�掓皵
			case (get_class_from_roleinfo(SelfInfo) =:= ?CLASS_MELEE) and (NewLiftOri < NowHp) of
				true ->
					NewMana = erlang:min(get_mana_from_roleinfo(SelfInfo) + ?MELEE_MANA_ADD_BY_ATTACK, get_mpmax_from_roleinfo(SelfInfo)),
					ChangedAttrLife_Mana = ChangedAttrLife ++ [{mp, NewMana}];
				false->
					ChangedAttrLife_Mana = 	ChangedAttrLife											
			end,				
			%%buff 瀵逛激瀹崇殑褰卞搷
			AllChangedAttr = buffer_op:hook_on_beattack(Damage,ChangedAttrLife_Mana),
			case lists:keyfind(hp,1,AllChangedAttr) of
				false->
					NewLift = NewLiftOri;
				{hp,NewLift}->
					nothing
			end,	
			NewRoleInfo = apply_skill_attr_changed(SelfInfo,AllChangedAttr),
			put(creature_info,NewRoleInfo),
			case NewLift =< 0 of
				true ->
					case creature_op:get_state_from_creature_info(SelfInfo) of
						singing->
							process_cancel_attack(SelfId, interrupt_by_buff);
						_->
							nothing
					end,										
					EnemyName = creature_op:get_name_from_creature_info(OtherInfo),
					%% 琚潃瀹充簡	
					player_be_killed(EnemyId,EnemyName),
					NextState = deading,
					update_role_info(SelfId, get(creature_info));																		
				false->					
					NextState = get_state_from_roleinfo(NewRoleInfo),
					update_role_info(SelfId, get(creature_info)),
					pet_op:hook_on_be_attack(EnemyId),
					role_ride_op:hook_on_be_attack(EnemyId)					
			end,			
			items_op:consume_item(defence)
	end,
	NextState.

%%
%%閲囬泦鐗╁搧 鏉�姝荤帺瀹� 鎬墿 鍚庤璋冪敤
%%
other_be_killed({OtherId,EnemyId,EnemyName,Type,Pos}) ->
	case EnemyId =:= get(roleid) of
		true->			%%killed by me
			on_my_kill(OtherId),
			spiritspower_op:on_other_killed(OtherId),
			SeriesKill = series_kill:on_other_killed(OtherId);
		_->
			SeriesKill = series_kill:get_cur_series_kill_num()
	end,
	loop_tower_op:on_killed_monster(OtherId),
	Message = role_packet:encode_be_killed_s2c(OtherId, EnemyName,Type,Pos,SeriesKill),
	send_data_to_gate(Message).

on_my_kill(OtherId)->
	case creature_op:what_creature(OtherId) of
		role->
			nothing;
%% 			achieve_op:achieve_update({player_kill}, [0]);
		_->	
			nothing
	end,
	case battle_ground_op:is_in_battle_ground() of
		true->
			battle_ground_op:hook_on_kill(OtherId);
		false->
			case guildbattle_op:is_in_battle() of
				true->
					guildbattle_op:hook_on_kill(OtherId);
				_->
					pvp_op:on_other_killed(OtherId),
					guild_monster:on_killed_guild_monster(OtherId)
			end
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%								  %%
%%						%%		姝讳骸涓庡娲�	5.14	%%								  %%
%%						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%								  %%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
player_be_killed(EnemyId,EnemyName)->
	on_dead(),		
	put(murderer,EnemyId),
	Pos = get_pos_from_roleinfo(get(creature_info)),
	SelfId = get(roleid),				
	case creature_op:what_creature(EnemyId) of
		npc->
			Type = ?DEADTYPE_UNITS;			 
		role->
			guild_op:hook_on_bekilled(EnemyId,EnemyName),
			role_treasure_transport:hook_on_dead(EnemyId,EnemyName),	
			case pvp_op:should_respawn_in_prison() of
				true->
					case creature_op:get_creature_info(EnemyId) of
						undefined->
							broad_cast(?SYSTEM_CHAT_PUTIN_PRISON,EnemyId,EnemyName,0);
						EnemyInfo ->
							broad_cast(?SYSTEM_CHAT_PUTIN_PRISON,EnemyInfo)
					end,
					Type = ?DEADTYPE_PRISON;
				_->   
					Type = ?DEADTYPE_ROLES	
			end
	end,				
	Message2 = role_packet:encode_be_killed_s2c(SelfId, EnemyName,Type,Pos,series_kill:get_cur_series_kill_num()),					
	send_data_to_gate(Message2),
	broadcast_message_to_aoi({other_be_killed, {SelfId,EnemyId, EnemyName,Type,Pos}}),
	if
		Type =:= ?DEADTYPE_PRISON->
			respawn_normal_inpoint();
		true->
			nothing
	end.
	
%%鍒犻櫎buffer,娓呯┖璺緞
on_dead()->
	guildbattle_op:hook_on_dead(),
	trade_role:interrupt(),
	pet_op:hook_on_dead(),
	role_mainline:hook_be_killed(),	
	role_ride_op:hook_on_dead(),
	role_sitdown_op:hook_on_action_sync_interrupt(timer_center:get_correct_now(),on_dead),
	put(creature_info, set_path_to_roleinfo(get(creature_info),[])),
	put(creature_info, set_state_to_roleinfo(get(creature_info), deading)),
	buffer_op:stop_mprecover(),
	buffer_op:stop_hprecover(),
	self_update_and_broad([{state,?CREATURE_STATE_DEAD}]),
	creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_DEAD).
		
is_dead()->
	creature_op:is_creature_dead(get(creature_info)).

respawn_self_in_situ()->
	role_sitdown_op:hook_on_action_async_interrupt(timer_center:get_correct_now(),self_respawn),
	util:send_state_event(self(),{respawn_self,?RESPAWN_WITH_CHTHEAL_INSITU}).

respawn_self(?RESPAWN_WITH_CHTHEAL_INSITU)->
	respawn_chtheal_insitu().

%%RESPAWN_INPOINT	RESPAWN_WITH_CHTHEAL_INSITU  RESPAWN_WITH_CHTHEAL_INPOINT
%%姝讳骸闃舵閫�鍑虹殑,鍐嶈繘鍏ヤ箣鍚�,閮芥寜RESPAWN_INPOINT澶勭悊
proc_aplly_role_respawn(Tag)->
	role_sitdown_op:hook_on_action_async_interrupt(timer_center:get_correct_now(),respawn),
	case is_dead() of
		true->
			proc_respawn(Tag);
		false->
			get_state_from_roleinfo(get(creature_info))
	end.		

%%澶嶆椿鐐瑰娲� 杩斿洖澶嶆椿鍚庣姸鎬�
proc_respawn(?RESPAWN_INPOINT)->
	MurdererId = get(murderer),
	case creature_op:what_creature(MurdererId) of
		role->	%%婊¤涓嶆弧钃�
			respawn_chtheal_inpoint();
		_->		%%涓嶆弧琛�涓嶆弧钃�
			respawn_normal_inpoint()
	end,
	battle_ground_op:hook_on_respawn();				%%鎴樺満涓娲荤偣澶嶆椿鐨勫鐞�

%%鍘熷湴澶嶆椿 杩斿洖澶嶆椿鍚庣姸鎬�
proc_respawn(?RESPAWN_WITH_CHTHEAL_INSITU)->
	case (get(level) =< ?RESPAWN_NONEED_LEVEL) of
		true->
			respawn_chtheal_insitu();
		false->
			case item_util:is_has_enough_item_in_package_by_class(?ITEM_TYPE_RESAWN,1) of
				true->
					item_util:consume_items_by_classid(?ITEM_TYPE_RESAWN,1),
					respawn_chtheal_insitu();
				false->
					case check_money(?MONEY_GOLD,?RESPAWN_WITH_CHTHEAL_INSITU_GOLD) of
						true->
							money_change(?MONEY_GOLD,-?RESPAWN_WITH_CHTHEAL_INSITU_GOLD,lost_respawn),
							respawn_chtheal_insitu();
						_->	
							slogger:msg("proc_respawn insitu no item or money ~p ~n",[get(roleid)])
					end
			end
	end;	
	
proc_respawn(_)->
	nothing.	

%%鍘熷湴婊¤婊¤摑澶嶆椿		
respawn_chtheal_insitu()->
	MyInfo = get(creature_info),
	MyId = get_id_from_roleinfo(MyInfo),
	MaxHp = get_hpmax_from_roleinfo(MyInfo),
	MaxMp = get_mpmax_from_roleinfo(MyInfo),								
	put(creature_info, set_state_to_roleinfo(get(creature_info), gaming)),
	put(creature_info, set_life_to_roleinfo(get(creature_info), MaxHp )),
	put(creature_info, set_mana_to_roleinfo(get(creature_info), MaxMp )),					
	update_role_info(MyId ,get(creature_info)),
	self_update_and_broad([{mp,MaxMp},{hp,MaxHp},{state,?CREATURE_STATE_GAME}]),
	Role_Class = get_class_from_roleinfo( get(creature_info)),
	Role_Level = get_level_from_roleinfo( get(creature_info)),
	%%涓嶄細瑙﹀彂map_complate,闇�瑕佽嚜宸卞惎鍔ㄦ仮澶峛uff
	buffer_op:generate_hprecover(Role_Class,Role_Level),	
	buffer_op:generate_mprecover(Role_Class,Role_Level).

%%澶嶆椿鐐规弧琛�涓嶆弧钃濆娲�
respawn_chtheal_inpoint()->
	NewHp = get_hpmax_from_roleinfo(get(creature_info)),
	NewMp = get_mana_from_roleinfo(get(creature_info)),								
	respawn_inpoint_with_states(NewHp,NewMp).
	
%%鏅�氬娲�,淇濈暀10%鏈�澶ц閲�	
respawn_normal_inpoint()->
	NewHp = trunc(get_hpmax_from_roleinfo(get(creature_info))*0.1),
	NewMp = get_mana_from_roleinfo(get(creature_info)),								
	respawn_inpoint_with_states(NewHp,NewMp).

respawn_inpoint_with_states(NewHp,NewMp)->
	OriMapid = get_mapid_from_mapinfo(get(map_info)),
	{RespawnMapId,{RespawnPosX,RespawnPosY}} = get_my_respwan_pos(),
	put(creature_info, set_state_to_roleinfo(get(creature_info), gaming)),
	put(creature_info, set_life_to_roleinfo(get(creature_info), NewHp )),
	put(creature_info, set_mana_to_roleinfo(get(creature_info), NewMp )),
	if		
		RespawnMapId =:= OriMapid ->
			%%绂诲紑grid																																 
			leave_map(get(creature_info),get(map_info)),								
			put(creature_info, set_pos_to_roleinfo(get(creature_info), {RespawnPosX,RespawnPosY})),								
			update_role_info(get(roleid) ,get(creature_info)),
			only_self_update([{mp,NewMp},{hp,NewHp},{state,?CREATURE_STATE_GAME},{posx,RespawnPosX},{posy,RespawnPosY}]),
			%%鍔犲叆grid							
			map_complete(get(creature_info), get(map_info));									
		true->
			%%鍒囨崲鍦板浘	
			update_role_info(get(roleid) ,get(creature_info)),
			LineId = get_lineid_from_mapinfo(get(map_info)),							
			only_self_update([{mp,NewMp},{hp,NewHp},{state,?CREATURE_STATE_GAME}]),
			transport(get(creature_info), get(map_info),LineId,RespawnMapId,{RespawnPosX,RespawnPosY})	
	end.		
	
%%
%%鑾峰彇澶嶆椿鐐逛綅缃�
%%
get_my_respwan_pos()->
	case battle_ground_op:is_in_battle_ground() of
		true->
			case battle_ground_op:get_my_spawnpos() of
				[]->
					{get_mapid_from_mapinfo(get(map_info)),get_pos_from_roleinfo(get(creature_info))};
				RespawnPos->
					RespawnPos
			end;
		_->
			case guildbattle_op:is_in_battle() of
				true->
					{get_mapid_from_mapinfo(get(map_info)),guildbattle_op:get_my_bornpos()};
				_->
					case pvp_op:should_respawn_in_prison() of
						true->
							{?PRISON_MAP,?PRISON_POS};
						false->
							case mapop:get_respawn_pos(get(map_db)) of
								[]->	%%娌℃湁鍔犺浇鍦板浘鏂囦欢
									{get_mapid_from_mapinfo(get(map_info)),get_pos_from_roleinfo(get(creature_info))};
								DefaultRespawnPos->
									DefaultRespawnPos
							end
					end
			end	
	end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%								  %%
%%						%%		姝讳骸涓庡娲�	缁撴潫 	%%								  %%
%%						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%								  %%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%								%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%													   娑堟伅骞挎挱閮ㄥ垎					
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
broadcast_message_to_aoi(Message)->
	broadcast_message_to_aoi(0, Message).
	
broadcast_message_to_aoi(DelayTime, Message) ->	
	case DelayTime of
		0 ->			
			lists:foreach(fun({_Id, Pid}) ->
							gs_rpc:cast(Pid,Message)					
						 end, get(aoi_list));
		_ ->
			lists:foreach(fun({_Id, Pid}) ->
						      erlang:send_after(DelayTime, Pid, Message)
			 end, get(aoi_list))
	end.
			      
broadcast_message_to_aoi_role(Message) ->
	broadcast_message_to_aoi_role(0, Message).
	
broadcast_message_to_aoi_role(DelayTime, Message) ->	
	case DelayTime of
		0 ->			
			lists:foreach(fun({Id, Pid}) ->
					case creature_op:what_creature(Id) of
						 role->
						      gs_rpc:cast(Pid,Message);
						 _->
						 	nothing
					end end, get(aoi_list));
		_ ->
			lists:foreach(fun({Id, Pid}) ->
					case creature_op:what_creature(Id) of
						 role->
						      erlang:send_after(DelayTime, Pid, Message);
						 _->
						 	nothing
					end end, get(aoi_list))
	end.	
	
%%缁檃oi閲岀殑閮ㄥ垎鐜╁鍙戦�佹秷鎭疞isteners:{Id,Pid}
broadcast_message_to_aoi_part(0, Message, Listeners)->
	lists:foreach(fun({_ ,Pid}) ->				      				      			      						     
						      gs_rpc:cast(Pid,Message)
		      end, Listeners);
		      
broadcast_message_to_aoi_part(FlyTime, Message, Listeners)->
	lists:foreach(fun({_ ,Pid}) ->				      					      
						      erlang:send_after(FlyTime, Pid, Message)
		      end, Listeners).

%% 缁欑敱Listeners鎸囧畾瑙掕壊鍙戦�佷俊鎭�
broadcast_message_to_other_role(FlyTime, Message, ListenersInfos) ->
	lists:foreach(fun(CreatureInfo) ->
				      CreatureID = creature_op:get_id_from_creature_info(CreatureInfo),
				      case creature_op:what_creature(CreatureID) of
					      role ->
						      Pid = get_pid_from_roleinfo(CreatureInfo),
						      erlang:send_after(FlyTime, Pid, Message);
					      npc ->
						      nothing
				      end
		      end, ListenersInfos).
		      
broadcast_message_to_other_role(Message, ListenersInfos) ->
	lists:foreach(fun(CreatureInfo) ->
				      CreatureID = creature_op:get_id_from_creature_info(CreatureInfo),
				      case creature_op:what_creature(CreatureID) of
					      role ->
						      Pid = get_pid_from_roleinfo(CreatureInfo),
						      gs_rpc:cast(Pid,Message);
					      npc ->
						      nothing
				      end
		      end, ListenersInfos).

broadcast_message_to_aoi_client(Message)->
	lists:foreach(fun({RoleId,_})->
			case creature_op:what_creature(RoleId) of
				role-> 
					send_to_other_client(RoleId,Message);
				_->
					nothing
			end 
	end,get(aoi_list)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鍙戦�佹暟鎹粰瑙掕壊瀵瑰簲鐨勭綉鍏宠繘绋�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
send_data_to_gate(Message) ->
	%%@@slogger:msg("modules.role.role_op:send_data_to_gate/1 Message~p~n",[Message]),
	GateProc = get_proc_from_gs_system_gateinfo(get(gate_info)),
	tcp_client:send_data(GateProc, Message).
send_data_to_gate(DelayTime, Message) ->
	%%@@slogger:msg("modules.role.role_op:send_data_to_gate/2 Message~p~n",[Message]),
	GatePid = get_pid_from_gs_system_gateinfo(get(gate_info)),
	tcp_client:send_data_after(GatePid,Message,DelayTime).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 缁欏悓涓�鑺傜偣鐨剅ole杩涚▼鍙戦�佷俊鎭�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
send_to_other_role(RoleId,Message)->
	case creature_op:get_creature_info(RoleId) of
		undefined -> slogger:msg("send_to_role error!!RoleId ~p undefined Msg ~p!!!!!!!!!!!!!!!!!!!!!!!!!!!~n",[RoleId,Message]);
		RoleInfo ->
			Pid = get_pid_from_roleinfo(RoleInfo),
			gs_rpc:cast(Pid,Message)
	end.

send_to_other_client(RoleId,Message)->	
	send_to_other_client_roleinfo(creature_op:get_creature_info(RoleId),Message).

send_to_other_client_roleinfo(RoleInfo,Message)->
	case RoleInfo of	
		undefined ->
			nothing;
		_ ->
			GS_GateInfo = get_gateinfo_from_roleinfo(RoleInfo),
			Gateproc = get_proc_from_gs_system_gateinfo(GS_GateInfo),					
			tcp_client:send_data(Gateproc, Message)
	end.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%													娑堟伅骞挎挱閮ㄥ垎缁撴潫
%%								%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%									 					
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
			      
	
%%璁＄畻鐜╁灞炴�ф敼鍙橈紝鍗囩骇鍜屽垵濮嬪寲闇�瑕佸叏閮ㄩ噸鏂拌绠�

%%鍒濆鍖栬绠桾ODO:current_buffer鎻愬墠璁剧疆
compute_attrs(init,Level) ->
	Class = get(classid),
	%%鍒濆璁＄畻	
	{OriCurrentAttributes,_OriCurrentBuffers,_OriChangeAttribute} = compute_buffers:compute(Class, Level, [], [], [], [],[],[],[],[]),
	put(current_attribute,OriCurrentAttributes),
	%%鑾峰彇瑁呭灞炴��
	BaseAttr = get_role_base_attr(),
	OtherAttr = get_role_other_attr(),
	put(base_attr,BaseAttr),
	put(other_attr,OtherAttr),
	
	%%灞炴�ц绠�
	{CurrentAttributes,_CurrentBuffers, _ChangeAttribute} 
	= compute_buffers:compute(Class, Level, get(current_attribute), get(current_buffer), [], [],BaseAttr,[],OtherAttr,[]),
	put(current_attribute, CurrentAttributes),
	Power = attribute:get_current(CurrentAttributes,power),
	Hprecover = attribute:get_current(CurrentAttributes,hprecover),
	CriDerate = attribute:get_current(CurrentAttributes,criticaldestroyrate),
	Mprecover = attribute:get_current(CurrentAttributes,mprecover),
	MovespeedRate = attribute:get_current(CurrentAttributes,movespeed),
	Meleeimmunity = attribute:get_current(CurrentAttributes,meleeimmunity),
	Rangeimmunity = attribute:get_current(CurrentAttributes,rangeimmunity),
	Magicimmunity = attribute:get_current(CurrentAttributes,magicimmunity),
	Hpmax = attribute:get_current(CurrentAttributes,hpmax),
	Mpmax = attribute:get_current(CurrentAttributes,mpmax),
	Stamina = attribute:get_current(CurrentAttributes,stamina),
	Strength = attribute:get_current(CurrentAttributes,strength),
	Intelligence = attribute:get_current(CurrentAttributes,intelligence),
	Agile = attribute:get_current(CurrentAttributes,agile),
	Meleedefense = attribute:get_current(CurrentAttributes,meleedefense),
	Rangedefense = attribute:get_current(CurrentAttributes,rangedefense),
	Magicdefense = attribute:get_current(CurrentAttributes,magicdefense),
	Hitrate = attribute:get_current(CurrentAttributes,hitrate),
	Dodge = attribute:get_current(CurrentAttributes,dodge),
	Criticalrate = attribute:get_current(CurrentAttributes,criticalrate),
	Toughness = attribute:get_current(CurrentAttributes,toughness),
	Imprisonment_resist = attribute:get_current(CurrentAttributes,imprisonment_resist),
	Silence_resist = attribute:get_current(CurrentAttributes,silence_resist),
	Daze_resist = attribute:get_current(CurrentAttributes,daze_resist),
	Poison_resist = attribute:get_current(CurrentAttributes,poison_resist),
	Normal_resist = attribute:get_current(CurrentAttributes,normal_resist),
	Fighting_force = role_fighting_force:computter_fight_force(Hpmax,Power,Meleedefense,Rangedefense,Magicdefense,Hitrate,Dodge,Criticalrate,
					  CriDerate,Toughness,Meleeimmunity,Rangeimmunity,Magicimmunity),
	{Power,Hprecover,CriDerate,Mprecover,MovespeedRate,Meleeimmunity,Rangeimmunity,Magicimmunity,Hpmax,Mpmax,Stamina,Strength,
	Intelligence,Agile,Meleedefense,Rangedefense,Magicdefense,Hitrate,Dodge,Criticalrate,Toughness,Imprisonment_resist,Silence_resist,
	Daze_resist,Poison_resist,Normal_resist,Fighting_force}.
	
read_from_roledb(Role_id)->
	RoleInfo = role_db:get_role_info(Role_id),
	Role_pos = role_db:get_coord(RoleInfo),
	Silver = role_db:get_silver(RoleInfo),
	BoundSilver = role_db:get_boundsilver(RoleInfo),
	Role_Level = role_db:get_level(RoleInfo),
	Gold = role_db:get_gold_from_account(get(account_id)),
	Ticket= role_db:get_currencygift(RoleInfo),
	Role_Class = role_db:get_class(RoleInfo),
	Expr = role_db:get_exp(RoleInfo),
	Hp = role_db:get_hp(RoleInfo),
	Mp= role_db:get_mana(RoleInfo),
	Role_name = role_db:get_name(RoleInfo),
	PackSize = role_db:get_packagesize(RoleInfo),
	ClassBase = role_db:get_class_base(Role_Class,Role_Level),
	Commoncool = role_db:get_class_commoncool(ClassBase),
	GroupID = role_db:get_groupid(RoleInfo),
	Gender = role_db:get_sex(RoleInfo),
	GuildId = role_db:get_guildid(RoleInfo),
	OffLine = role_db:get_offline(RoleInfo),
	PvPinfo = role_db:get_pvpinfo(RoleInfo),
	PetInfo = role_db:get_pet(RoleInfo),
	AllBuffersInfo = role_db:get_bufflist(RoleInfo),
	SoulPowerInfo = role_db:get_soulpower(RoleInfo), 
	StallName = role_db:get_stallname(RoleInfo),
	TrainingInfo = role_db:get_training(RoleInfo),
	Honor = role_db:get_honor(RoleInfo),
	{Role_pos,Silver,BoundSilver,Role_Level,Gold,Ticket,Role_Class,Expr,Hp,Mp,Role_name,ClassBase,Commoncool,PackSize,GroupID,Gender,GuildId,AllBuffersInfo,TrainingInfo,OffLine,PvPinfo,PetInfo,SoulPowerInfo,StallName,Honor}.
	
async_write_to_roledb()->
	RoleInfo = get(creature_info),
	RoleId = get_id_from_roleinfo(RoleInfo),
	Pos = get_pos_from_roleinfo(RoleInfo),
	Silver = get_silver_from_roleinfo(RoleInfo),
	BoundSilver = get_boundsilver_from_roleinfo(RoleInfo),
	Level = get_level_from_roleinfo(RoleInfo),
	Gold = get_gold_from_roleinfo(RoleInfo),
	Gift = get_ticket_from_roleinfo(RoleInfo),
	Exp = get_exp_from_roleinfo(RoleInfo),
	Hp = get_life_from_roleinfo(RoleInfo),
	Mana = get_mana_from_roleinfo(RoleInfo),
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	Packagesize = package_op:get_size(),	
	Bufflist = buffer_op:export_for_db(),
	GroupId = group_op:get_id(),
	GuildId = guild_util:get_guild_id(),
	TrainInfo = block_training_op:export_for_db(),
	Account = get(account_id),
	Name = get_name_from_roleinfo(RoleInfo),
	Sex = get_gender_from_roleinfo(RoleInfo),
	Class = get_class_from_roleinfo(RoleInfo),
	Honor = get_honor_from_roleinfo(RoleInfo),
	FightForce = get_fighting_force_from_roleinfo(RoleInfo),
	PvPInfo = {get_pkmodel_from_roleinfo(RoleInfo),get_crime_from_roleinfo(RoleInfo)},
	Pet = pet_op:save_roleinfo_to_db(),
	Offline = timer_center:get_correct_now(),
	SoulPower = role_soulpower:export_for_db(),
	StallName = auction_op:export_for_db(),
	role_db:async_write_roleattr({RoleId,Account,Name,Sex,Class,Level,Exp,Hp,Mana,Gold,Gift,Silver,BoundSilver,Mapid,Pos,Bufflist,TrainInfo,Packagesize,GroupId,GuildId,PvPInfo,Pet,Offline,SoulPower,StallName,Honor,FightForce}).
		
	
%%write_to_roledb()->
%%	RoleInfo = get(creature_info),
%%	RoleId = get_id_from_roleinfo(RoleInfo),
%%	Role_pos = get_pos_from_roleinfo(RoleInfo),
%%	Silver = get_boundsilver_from_roleinfo(RoleInfo),
%%	Role_Level = get_level_from_roleinfo(RoleInfo),
%%	Gold = get_gold_from_roleinfo(RoleInfo),
%%	Ticket = get_ticket_from_roleinfo(RoleInfo),
%%	Expr = get_exp_from_roleinfo(RoleInfo),
%%	Hp = get_life_from_roleinfo(RoleInfo),
%%	Mp = get_mana_from_roleinfo(RoleInfo),
%%	Mapid = get_mapid_from_mapinfo(get(map_info)),
%%	PackSize = package_op:get_size(),	
%%	Buffer = buffer_op:export_for_db(),
%%	GroupId = group_op:get_id(),
%%	Pet = pet_op:get_petids(),
%%	TrainInfo = block_training_op:export_for_db(),
%%	RoleInfoInDB1 = role_db:put_level(role_db:get_role_info(RoleId),Role_Level),
%%	RoleInfoInDB2 = role_db:put_exp(RoleInfoInDB1,Expr),
%%	RoleInfoInDB3 = role_db:put_hp(RoleInfoInDB2,Hp),
%%	RoleInfoInDB4 = role_db:put_mana(RoleInfoInDB3,Mp),
%%	RoleInfoInDB5 = role_db:put_currencygold(RoleInfoInDB4,Gold),
%%	RoleInfoInDB6 = role_db:put_currencygift(RoleInfoInDB5,Ticket),
%%	RoleInfoInDB7 = role_db:put_currencysilver(RoleInfoInDB6,Silver),
%%	RoleInfoInDB8 = role_db:put_coord(RoleInfoInDB7,Role_pos),
%%	RoleInfoInDB9 = role_db:put_mapid(RoleInfoInDB8,Mapid),
%%	RoleInfoInDB10 = role_db:put_groupid(RoleInfoInDB9 ,GroupId),
%%	RoleInfoInDB11 = role_db:put_guildid(RoleInfoInDB10,guild_util:get_guild_id()),
%%	RoleInfoInDB12 = role_db:put_offline(RoleInfoInDB11,timer_center:get_correct_now()),
%%	RoleInfoInDB13 = role_db:put_bufflist(RoleInfoInDB12,Buffer),
%%	RoleInfoInDB14 = role_db:put_packagesize(RoleInfoInDB13,PackSize),
%%	RoleInfoInDB15 = role_db:put_training(RoleInfoInDB14,TrainInfo),	
%%	RoleInfoInDB16 = role_db:put_pet(RoleInfoInDB15,Pet),
%%	role_db:flush_role(RoleInfoInDB16).
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 澶勭悊绉诲姩璇锋眰
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
phy_check(Path,NewPos)->
	PhyCheck = mapop:check_path(Path,get(map_db)) and mapop:check_pos_is_valid(NewPos,get(map_db)),
	if
		(not PhyCheck)->
			case get(cheat_threat) of
				undefined->
					put(cheat_threat,2);
				Value->	
					put(cheat_threat,Value+2)
			end;
		true->
			nothing
	end,
	PhyCheck.

move_check(RoleInfo,TimeCNow,NewPos)->
	TimeSNow = util:now_to_ms(timer_center:get_time_of_day()),
	case get(last_move_time) of
		undefined->
			put(last_speed,get_speed_from_roleinfo(RoleInfo)),
			put(last_move_time,{TimeCNow,TimeSNow}),
			put(cheat_threat,0),
			put(last_req_pos,NewPos),
			true;
		{LastCTime,LastSTime}->	
			if
				(TimeCNow > TimeSNow)->
					async_time_with_clinet(),
					put(cheat_threat,get(cheat_threat)+1);
				true->
					nothing
			end,
			NowPos = get(last_req_pos), 
			LastSpeed = get(last_speed),
			put(last_move_time,{TimeCNow,TimeSNow}),
			put(last_req_pos,NewPos),
			put(last_speed,get_speed_from_roleinfo(RoleInfo)),
			DisTime =
			if
				LastSTime =:= TimeSNow->
					TimeCNow - LastCTime;
				true->
					TimeSNow - LastSTime
			end,	
			if
				DisTime =< 0->
					put(cheat_threat,get(cheat_threat)+1),
					true;
				true->
					CurSpeed = util:get_distance(NewPos,NowPos)*1000/DisTime,
					if 
						CurSpeed*?MOVE_CHEAT_TOLERANCE > LastSpeed*1.12->				%%浜屽垎涔嬫牴鍙蜂簲,瀹㈡埛绔渶蹇�熷害姣旂巼
							put(cheat_threat,get(cheat_threat)+1);
						true->
							case (get(cheat_threat) > 0) of
								true->	
									put(cheat_threat,get(cheat_threat)-0.5);
								_->
									nothing
							end	
					end,
					case get(cheat_threat) > ?MOVE_CHEAT_THREAT of
						true->
							slogger:msg("move_check maybe hack!!! cheat_threat more than ~p!RolId: ~p ~n",[?MOVE_CHEAT_THREAT,get(roleid)]),
							false;
						_->
							true
					end
			end
	end.	

set_move_timer(NewTimer)->
	case get(move_timer)of
		undefined->
			put(move_timer,NewTimer);
		0->
			put(move_timer,NewTimer);
		Timer->
			gen_fsm:cancel_timer(Timer),
			put(move_timer,NewTimer)
	end.

move_request(RoleInfo, MapInfo, {NowPos,Path,Time}, CanMove) when CanMove ->
	set_move_timer(0),
	RoleId = get_id_from_roleinfo(RoleInfo),
	MyPos = get_pos_from_roleinfo(RoleInfo),
	creature_op:move_notify_aoi_roles(RoleInfo,NowPos,Path,Time),
	PhyCheck = phy_check(Path,NowPos),
	case move_check(RoleInfo,Time,NowPos) of
		true ->					
			if
				PhyCheck->
					%% 鎶婅矾寰勫瓨鍌ㄥ埌瑙掕壊淇℃伅涓�		
					switch_to_moving_state(RoleId,Path),
					%%鎶婅矾寰勯噷鐨勭涓�涓牸璁剧疆涓哄綋鍓嶆牸.
					if
						NowPos =/= MyPos->
							move_heartbeat(get(creature_info), MapInfo, NowPos);
						true->
							nothing
					end,
					auto_amend_move(NowPos,Path);
				true->
					nothing
			end;			
		_ ->
			kick_out(RoleId)		
	end;	
	
move_request(RoleInfo, MapInfo, Path, CanMove) when not CanMove ->
	nothing.
%%	Posmy = get_pos_from_roleinfo(RoleInfo).
%%	Message = role_packet:encode_role_move_fail_s2c(Posmy),
%%	send_data_to_gate(Message). 

%%妯悜绉诲姩杈冩參鐨勬椂鍊�,涓嶈兘绛夊鎴风鍚屾,闇�瑕佽嚜宸辩籂姝ｄ綅缃�
auto_amend_move(Pos,Path)->
	case erlang:length(Path) >= (?MOVE_ASYNC_NUM -1)  of
		true->
			AmendPath = lists:sublist(Path,?MOVE_ASYNC_NUM -1),
			amend_move(Pos,AmendPath);
		false->
			nothing
	end.		
 
amend_move(BeginPos,Path)->
	if
		Path =:= []->
			nothing;
		true->
			[ NextPos | LeftPath ] = Path, 
			Time = util:get_adjust_move_time(BeginPos,pb_util:convert_to_pos(NextPos),get_speed_from_roleinfo(get(creature_info))),
			if
				Time > ?MOVE_MAX_DEALY_TIME->
					Timer = gen_fsm:send_event_after(Time, {move_admend_path,Path}),
					set_move_timer(Timer);
				true->
					amend_move(BeginPos,LeftPath)
			end
	end.								
 
move_admend_path(Path)->
 	[Coord|LeftPath] = Path,
 	Pos = pb_util:convert_to_pos(Coord),
 	move_heartbeat(get(creature_info), get(map_info), Pos),
 	amend_move(Pos,LeftPath).
 
stop_move_c2s({Time,NowPos})->
	set_move_timer(0),	
	SelfId = get(roleid),
	StopMsg = role_packet:encode_move_stop_s2c(SelfId,NowPos),
	broadcast_message_to_aoi_client(StopMsg),
	PhyCheck = phy_check([],NowPos),
	case move_check(get(creature_info),Time,NowPos) of
		true->
			case NowPos =/= get_pos_from_roleinfo(get(creature_info)) of
				true->
					if
						PhyCheck ->
							switch_to_moving_state(SelfId,[]),
							move_heartbeat(get(creature_info), get(map_info), NowPos);
						true->
							nothing
					end;
				_->
					nothing
			end;
		_->
			nothing
	end.	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 绉诲姩蹇冭烦
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
move_heartbeat(RoleInfo, MapInfo, Pos) ->
	Now = timer_center:get_correct_now(),
	role_sitdown_op:hook_on_action_async_interrupt(Now,move_heart_beat),
	case creature_op:move_heartbeat(RoleInfo, MapInfo, Pos) of
		gaming ->
			gaming;
		{moving, _RemainPath} ->		
			moving;
		_ ->
			%% 璇锋眰璺緞鍑洪敊
			get_state_from_roleinfo(RoleInfo)
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 閫氱煡瀹㈡埛绔叾浠栫帺瀹剁寮�鍦板浘
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
other_outof_view(OtherId) ->
	creature_op:remove_from_aoi_list(OtherId),
	out_of_view_notify_client(OtherId).
	
out_of_view_notify_client(OtherId)->
	DelData = object_update:make_delete_data(OtherId),
	GatePid = get_proc_from_gs_system_gateinfo(get(gate_info)),
	tcp_client:object_update_delete(GatePid,DelData).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鍙戣捣鏀诲嚮
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
attack_check(SelfId,TargetID,TargetInfo,SkillInfo)->
	BaseCheck = 
	not (
		(TargetInfo =:= undefined)
		or
		is_dead()
		or 
		((TargetID =/= SelfId) and (not creature_op:is_in_aoi_list(TargetID))) 
		),
	%%涓嶈兘閲婃斁琚姩鎶�鑳�
	case ((SkillInfo =/= []) and BaseCheck) of
		true->	
			SkillType = skill_db:get_type(SkillInfo),
			(
				(SkillType =:=?SKILL_TYPE_NOMAL) 
			or (SkillType =:=?SKILL_TYPE_ACTIVE)
			or (SkillType =:=?SKILL_TYPE_ACTIVE_WITHOUT_CHECK_SILENT)
			or (SkillType =:=?SKILL_TYPE_ESPECIALLY_COLLECT)
			or (SkillType =:=?SKILL_TYPE_ATTACK_THRONE)	
			);
		_->
			false	
	end.

%%杩斿洖鐜╁鐘舵��	
start_attack(SkillID, TargetID) ->
	%% 鑾峰彇鐢熺墿鐨勪俊鎭�	
	SelfId = get(roleid),
	SelfInfo = get(creature_info),
	SelfId = get_id_from_roleinfo(SelfInfo),
	%% 鑾峰彇鐢熺墿鐨勪俊鎭�
	TargetInfo = creature_op:get_creature_info(TargetID),
	SkillLevel = skill_op:get_skill_level(SkillID),	
	SkillInfo = skill_db:get_skill_info(SkillID, SkillLevel),
	Now = timer_center:get_correct_now(),
	role_sitdown_op:hook_on_action_async_interrupt(Now,start_attack),	
	case attack_check(SelfId,TargetID,TargetInfo,SkillInfo) of
		false ->
			get_state_from_roleinfo(get(creature_info));
		_->
			creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_ATTACK),
			proc_role_start_attack(skill_db:get_type(SkillInfo),SkillID,SkillLevel,SkillInfo,TargetInfo,TargetID)
	end.


%%鎴樺満閲囬泦鎶�鑳界殑鐗规畩澶勭悊
%%璺宠繃combat:judge鐨勭壒娈婃妧鑳�,鎵ц鑷繁鐨勬娴�
proc_role_start_attack(?SKILL_TYPE_ESPECIALLY_COLLECT,SkillID,SkillLevel,SkillInfo,TargetInfo,TargetID)->
	SelfInfo = get(creature_info),
	JudgeResult = combat_op:skill_script_check(SkillInfo,TargetInfo),
	if
		JudgeResult ->
			proc_cast_skill(SelfInfo, TargetInfo, SkillID, SkillLevel,SkillInfo,TargetID);
		true->
			proc_attack_judged_error(JudgeResult,get(roleid), SkillID, TargetID),
			get_state_from_roleinfo(get(creature_info))
	end;
	
%%鐜嬪骇鍗犻鎶�鑳界殑鐗规畩澶勭悊
%%璺宠繃combat:judge鐨勭壒娈婃妧鑳�,鎵ц鑷繁鐨勬娴�
proc_role_start_attack(?SKILL_TYPE_ATTACK_THRONE,SkillID,SkillLevel,SkillInfo,TargetInfo,TargetID)->
	SelfInfo = get(creature_info),
	JudgeResult = combat_op:skill_script_check(SkillInfo,TargetInfo),
	if
		JudgeResult ->
			proc_cast_skill(SelfInfo, TargetInfo, SkillID, SkillLevel,SkillInfo,TargetID);
		true->
			proc_attack_judged_error(JudgeResult,get(roleid), SkillID, TargetID),
			get_state_from_roleinfo(get(creature_info))
	end;

%%
%%鍏朵粬鎶�鑳�
%%
proc_role_start_attack(_,SkillID,SkillLevel,SkillInfo,TargetInfo,TargetID)->
	pet_op:hook_on_attack(),
	JudgeResult = combat_op:judge(get(creature_info), TargetInfo, SkillID, SkillLevel,SkillInfo),
	if
		JudgeResult ->
			role_ride_op:hook_on_attack(),				
			proc_cast_skill(get(creature_info), TargetInfo, SkillID, SkillLevel,SkillInfo,TargetID);
		true ->							 
			proc_attack_judged_error(JudgeResult,get(roleid), SkillID, TargetID),
			get_state_from_roleinfo(get(creature_info))
	end.

%%杩斿洖鐘舵��
proc_cast_skill(SelfInfo, TargetInfo, SkillID, SkillLevel,SkillInfo,TargetID)->
	SelfId = get(roleid),
	MyPos = creature_op:get_pos_from_creature_info(SelfInfo),
	MyTarget = creature_op:get_pos_from_creature_info(TargetInfo),
	Speed = skill_db:get_flyspeed(SkillInfo),
	FlyTime = Speed*util:get_distance(MyPos,MyTarget),
	case skill_db:get_cast_time(SkillInfo) of
		0 ->																			
			%% 澶勭悊椤哄彂鏀诲嚮
			{ChangedAttr, CastResult} = 
			combat_op:process_instant_attack(SelfInfo, TargetInfo, SkillID, SkillLevel,SkillInfo),													
			skill_op:set_casttime(SkillID),							
			%%鎵�鏈変激瀹充竴璧峰彂鍑哄幓
			process_damage_list(SelfId,SelfInfo,SkillID,SkillLevel, FlyTime, CastResult),
			%%澶勭悊buff
			creature_op:combat_bufflist_proc(SelfInfo,CastResult,FlyTime),
			Now = timer_center:get_correct_now(),
			set_leave_attack_time(creature_op:get_id_from_creature_info(TargetInfo),Now),
			case env:get(commoncdswitch,0) of
				0->
					put(last_cast_time,Now);
				1->					
					case combat_op:is_normal_attack(SkillID) of
						true->
							put(last_nor_cast_time,Now);
						false->	 
					 		put(last_cast_time,Now), 
					 		put(last_nor_cast_time,Now)
					end
			end,				      
			NewInfo2 = apply_skill_attr_changed(get(creature_info),ChangedAttr),
			put(creature_info, NewInfo2),								
			update_role_info(SelfId,NewInfo2),
			%%娑堣�楄澶�
			items_op:consume_item(attack),
			get_state_from_roleinfo(SelfInfo);
	_ ->	
			AttackMsg = role_packet:encode_role_attack_s2c(0, SelfId, SkillID, TargetID),
			send_data_to_gate(AttackMsg ),
			broadcast_message_to_aoi_client(AttackMsg),
			%% 澶勭悊寤惰繜鏀诲嚮
			combat_op:process_delay_attack(SelfInfo, TargetID, SkillID, SkillLevel, FlyTime),
			put(creature_info, set_state_to_roleinfo(get(creature_info),singing)),
			update_role_info(SelfId,get(creature_info)),
			singing
	end.											
		
proc_attack_judged_error(JudgeResult,SelfId, SkillID, TargetID)->
	case JudgeResult of
		cooltime ->
			send_data_to_gate(role_packet:encode_role_attack_s2c(?ATTACK_ERROR_COOLTIME, SelfId, SkillID, TargetID));
%%		mp ->
%%			send_data_to_gate(role_packet:encode_role_attack_s2c(?ATTACK_ERROR_MP, SelfId, SkillID, TargetID));
		safe_zone ->
			send_data_to_gate(role_packet:encode_role_attack_s2c(?ATTACK_ERROR_SAFE_ZONE, SelfId, SkillID, TargetID));
		range ->			%%璺濈閿欒涓嶅啀鍙戝寘
			send_data_to_gate(role_packet:encode_role_attack_s2c(?ATTACK_ERROR_RANGE, SelfId, SkillID, TargetID));
%%		global_cooltime ->
%%			send_data_to_gate(role_packet:encode_role_attack_s2c(?ATTACK_ERROR_GLOBALTIME, SelfId, SkillID, TargetID));
		is_god ->
			send_data_to_gate(role_packet:encode_role_attack_s2c(?ATTACK_ERROR_TARGET_GOD, SelfId, SkillID, TargetID));
		is_silent ->
			send_data_to_gate(role_packet:encode_role_attack_s2c(?ATTACK_ERROR_SILENT, SelfId, SkillID, TargetID));
		is_coma ->
			send_data_to_gate(role_packet:encode_role_attack_s2c(?ATTACK_ERROR_COMA, SelfId, SkillID, TargetID));
		state->
			send_data_to_gate(role_packet:encode_role_attack_s2c(?ATTACK_ERROR_ERROR_STATE, SelfId, SkillID, TargetID));	
		Error->
			nothing
	end.
		

apply_skill_attr_changed(SelfInfo,ChangedAttr)->
	lists:foldl(fun(Attr,Info)->
			self_update_and_broad([Attr]),					%%TODO:鎴栬鏈変竴浜涗笉闇�瑕佸箍鎾�,浠ュ悗鐪嬫妧鑳介渶姹�
			role_attr:to_creature_info(Attr,Info)						
		end,SelfInfo,ChangedAttr).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鍒囨崲骞舵洿鏂拌鑹茬姸鎬�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch_to_gaming_state(RoleId) ->
	put(creature_info, set_state_to_roleinfo(get(creature_info), gaming)),	    
	update_role_info(RoleId, get(creature_info)),
	gaming.

switch_to_moving_state(_RoleId,Path) ->
	if
		Path=:=[]->
			State = gaming;
		true->
			State = moving
	end,
	put(creature_info, set_path_to_roleinfo(set_state_to_roleinfo(get(creature_info), State),Path)),	
	State.

update_role_info()->
	update_role_info(get(roleid),get(creature_info)).	
update_role_info(RoleId, RoleInfo) ->
	role_manager:regist_role_info(RoleId, RoleInfo).

%%TODO:crash鍚庢殏鏃剁洿鎺ラ��鍑�
crash_store() ->
	RoleId = get(roleid),
	slogger:msg("crash_store: terminate RoleId ~p ~n",[RoleId ]),
	kick_out(RoleId).

kick_out(KickRoleId)->	
	GateInfo = get(gate_info),    
	case GateInfo of				
		undefined->
			nothing;
		_-> 					%%濡傛灉瀹㈡埛绔俊鎭繕鍦�,鏂紑瀹㈡埛绔摼鎺�
			GateProc = get_proc_from_gs_system_gateinfo(GateInfo),			
			tcp_client:kick_client(GateProc )
	end,
    %%%%濡傛灉鐜╁淇℃伅杩樺湪,杩涜閫�鍑烘竻鐞�
    do_cleanup(uninit,KickRoleId),
    %%鍋滄杩涚▼(涓嶉噸鍚�,鏃犺濡備綍閮借鍋氭姝�!)
	role_manager:stop_self_process(get(map_info),node(),KickRoleId).

crash_recovery(RoleInfo) ->
	%% 璇存槑: 鎴戜滑鍏堟殏鏃朵繚璇佹父鎴忕殑閫昏緫姝ｇ‘鎬�, 瀵逛簬娓告垙瀹归敊鐨勫鐞嗗鏋滃墠鏈熷仛鐨勫緢澶氾紝鍒欐湁寰堝闂涓嶈兘鍙婃椂鏆撮湶锛�
	%%      鎵�浠ユ垜浠厛涓嶉敊宕╂簝鎭㈠绛栫暐, 鐩存帴閫氱煡gate鍏抽棴璇ocket鍏抽棴
	GateInfo = get_gateinfo_from_roleinfo(RoleInfo),
	MapInfo = get_mapinfo_from_roleinfo(RoleInfo),
	put(map_info, MapInfo),
	put(gate_info, GateInfo),
	put(creature_info, RoleInfo).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 杩涚▼閫�鍑哄仛涓�浜涙竻鐞嗗伐浣�:Tag:change_map / uninit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
do_cleanup(Tag,RoleId)->
		MapInfo = get(map_info),
		RoleInfo = get(creature_info),						
		try	
			case Tag of 
				uninit->				%%涓嬬嚎涓嶄細鎵цchange_map閲岀殑script on_leave,鎵�浠ヨ繖閲岃涓诲姩鎺変竴涓�.	
					map_script:run_script(on_leave);
				_->
					nothing
			end,	
			leave_map(RoleInfo, MapInfo)		%%绂诲紑鍦板浘
		catch
			E1:R1-> slogger:msg("role_op:do_cleanup creature_op:leave_map error ~p:~p~n",[E1,R1])
		end,			
		try
			uninit(Tag,RoleId)							%%鍗歌浇
		catch
			E2:R2-> slogger:msg("role_op:do_cleanup uninit error ~p:~p ~p ~n",[E2,R2,erlang:get_stacktrace()])
		end,	
		if
			Tag =:= uninit-> 
				%%浠庡叏灞�瑙掕壊淇℃伅涓嵏杞�
				role_server_travel:hook_on_offline(),
				role_pos_db:unreg_role_pos_to_mnesia(RoleId);
			true->
				nothing
		end,
		try
			%%浠巈ts鍗歌浇
			role_manager:unregist_role_info(RoleId),
			pet_manager:unregist_pet_info(pet_op:get_out_pet_id())
		catch
			E4:R4-> slogger:msg("role_op:do_cleanup unregist_role_info error ~p:~p~n",[E4,R4])
		end.
	

on_change_map(_NewMapId,_LineId,NewMapProcName)->
	map_script:run_script(on_leave),
	instance_op:on_change_map(NewMapProcName),
	%%杩欎釜鎿嶄綔鍙兘浼氬鑷寸帺瀹惰繘绋嬬姸鎬佸彉鍖�,鐢眒ap_complate閲嶆柊杩涘叆鍦板浘鐨勬椂鍊�,鍐嶈缃帺瀹惰繘绋嬬姸鎬�
	role_sitdown_op:hook_on_action_sync_interrupt(timer_center:get_correct_now(),leave_map).	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鍦ㄥ悓涓�鑺傜偣鏇存崲鍦板浘
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
change_map_in_same_node(MapInfo,NewNode,NewMapProcName,NewMapId,LineId,X,Y) ->
	on_change_map(NewMapId,LineId,NewMapProcName),
	RoleInfo = get(creature_info),
	leave_map(RoleInfo, MapInfo),
	GS_system_map_info = #gs_system_map_info{map_id=NewMapId,
						 line_id=LineId, 
						 map_proc=NewMapProcName, 
						 map_node=NewNode},                                    
	put(map_info, create_mapinfo(NewMapId, LineId,NewNode, NewMapProcName, ?GRID_WIDTH)),	
	put(creature_info, set_path_to_roleinfo(get(creature_info), [])),
	put(creature_info, set_pos_to_roleinfo(get(creature_info), {X, Y})),
	put(creature_info, set_mapinfo_to_roleinfo(get(creature_info), GS_system_map_info)), 
	update_role_info(get(roleid), get(creature_info)),
	%%node鏈敼鍙�,闇�瑕佹洿鏂癓ine,MapId
	role_pos_util:update_role_line_map(get(roleid),LineId,NewMapId),
	NpcInfoDB = npc_op:make_npcinfo_db_name(NewMapProcName),
	put(npcinfo_db,NpcInfoDB),
	Map_db = mapdb_processor:make_db_name(NewMapId),
	put(map_db,Map_db),			
	put(last_req_pos,{X, Y}),
	%%閫氱煡guild鑺傜偣 鏇存柊line mapid
	guild_op:change_map(LineId,NewMapId),
	notify_gate_map_change(RoleInfo, NewMapId),
	notify_client_map_change(NewMapId, LineId, X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鍦ㄤ笉鍚屼竴鑺傜偣鏇存崲鍦板浘: 寮�濮嬮樁娈�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
change_map_in_other_node_begin(MapInfo, NewNode, NewMapProcName, NewMapId, LineId, X, Y) ->
	on_change_map(NewMapId,LineId,NewMapProcName),
	RoleInfo = get(creature_info),
	Gs_New_Map_info = set_proc_to_mapinfo(MapInfo, NewMapProcName),
	Gs_New_Map_info1 = set_node_to_mapinfo(Gs_New_Map_info, NewNode),
	Gs_New_Map_info2 = set_mapid_to_mapinfo(Gs_New_Map_info1, NewMapId),
	Gs_New_Map_info3 = set_lineid_to_mapinfo(Gs_New_Map_info2,LineId),
	role_server_travel:hook_on_trans_map_by_node(Gs_New_Map_info3),
	case role_manager:start_copy_role(Gs_New_Map_info3, RoleInfo, get(gate_info),X,Y,
	export_for_copy()) of
		error->
			role_server_travel:hook_on_trans_map_faild(),
			Message = role_packet:encode_map_change_failed_s2c(?ERRNO_JOIN_MAP_ERROR_MAPID),
			send_data_to_gate(Message),						
			slogger:msg("change_map_in_other_node_begin error ~p ~n",[get(roleid)]);
		ok->
			%%鍏堟妸鍐呭瓨鎷疯礉杩囧幓,鎵嶇寮�褰撳墠鍦板浘,鎵�浠ュ湪do_cleanup(change_map)閲屼笉鑳藉仛鏀瑰彉鍐呭瓨鐨勬搷浣�
			do_cleanup(change_map,get(roleid)),
			role_manager:stop_self_process(get(map_info),node(),get(roleid))
	end.
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鍦ㄤ笉鍚屼竴鑺傜偣鏇存崲鍦板浘: 鍒囨崲闃舵
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
change_map_in_other_node_end(RoleInfo, MapInfo, X, Y) ->
        %%鍚慼ttp_client 鍙戦�佹洿鏀筸ap娑堟伅
	MapInfo = get(map_info),
	LineId = get_lineid_from_mapinfo(MapInfo),
	NewMapId = get_mapid_from_mapinfo(MapInfo),
	%%閫氱煡guild鑺傜偣 鏇存柊line mapid
	guild_op:change_map(LineId,NewMapId),
	%% 閫氱煡鏈嶅姟鍣ㄩ�氱煡瀹㈡埛绔�
	notify_gate_map_change(RoleInfo, NewMapId),
	notify_client_map_change(NewMapId, LineId, X, Y).

notify_client_map_change(NewMapId, LineId, X, Y) ->
	send_data_to_gate(role_packet:encode_role_map_change_s2c({X,Y}, NewMapId, LineId)).

notify_gate_map_change(RoleInfo, NewMapId) ->
	GateProc = get_proc_from_gs_system_gateinfo(get(gate_info)),
	GateNode = get_node_from_gs_system_gateinfo(get(gate_info)),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	tcp_client:mapid_change(GateNode, GateProc, node(), NewMapId, role_op:make_role_proc_name(RoleId)).

change_line(LineId)->
	MapInfo = get(map_info),
	RoleInfo = get(creature_info),
	MapId = get_mapid_from_mapinfo(MapInfo ),
	OldMapNode = get_node_from_mapinfo(MapInfo),
	{X,Y} = get_pos_from_roleinfo(RoleInfo ),
	BaseCheck = (not instance_op:is_in_instance()) and (not is_dead()), 
	if
		BaseCheck->									%%鍓湰涓笉鍏佽鎹㈢嚎
			case is_leave_attack() of
				true->
				    case lines_manager:get_map_name(LineId, MapId) of
						{ok,{MapNode,MapProcName}}->
							case OldMapNode =:= MapNode of
								true ->				
									change_map_in_same_node(MapInfo,MapNode,MapProcName,MapId,LineId,X,Y);
								false ->				
									change_map_in_other_node_begin(MapInfo,MapNode,MapProcName,MapId,LineId,X,Y)
							end;
						_->
							nothing
					end;
				_->
					Message = role_packet:encode_map_change_failed_s2c(?ERROR_NOT_LEAVE_ATTACK),
					send_data_to_gate(Message)			
			end;
		true->
			nothing
	end.
	
%%瑙﹀彂浼犻�佺偣	
touch_teleporter(RoleInfo, MapInfo, TargetMap, TransId) ->
	CruMap = get_mapid_from_mapinfo(MapInfo), %%鑾峰緱褰撳墠鐨勫満鏅�
	case transport_db:get_transport_info(CruMap, TargetMap) of
    	 	[] ->		
				Message = role_packet:encode_map_change_failed_s2c(?ERRNO_JOIN_MAP_ERROR_MAPID),
				send_data_to_gate(Message);			
			TransInfo ->		%%寰楀埌褰撳墠鍦板浘鍓嶅線鐩爣鍦板浘鐨勪紶閫侀�氶亾id
				ToTransId = transport_db:get_transport_transid(TransInfo),
				TransPointPos = transport_db:get_transport_coord(TransInfo),		
				PosCheck = util:is_in_range(TransPointPos,get_pos_from_roleinfo(RoleInfo),?NPC_FUNCTION_DISTANCE),	
				if 
					(ToTransId =:= TransId) and PosCheck ->
						gm_logger_role:role_map_change(get(roleid),CruMap,TargetMap),
						transport_op:teleport(RoleInfo, MapInfo, TransId);												
					true ->	
						slogger:msg("map change is_in_range false find hack: CruMap:~p, TargetMap:~p PosCheck~p ~n", [CruMap, TargetMap,PosCheck]),	
						Message = role_packet:encode_map_change_failed_s2c(?ERRNO_JOIN_MAP_ERROR_MAPID),
						send_data_to_gate(Message)							                                
                end   		
        end.
%%	end.

get_best_map(MapId,LineIdOri)->
	case (LineIdOri =:= ?INSTANCE_LINEID) and instance_op:is_in_instance() of		%%transport in instance
		true->
			LineId = instance_op:get_old_line();
		_->
			LineId = LineIdOri
	end,
	case lines_manager:get_map_name(LineId, MapId) of
			{ok,{MapNode,MapProcName}}->{ok,{LineId,MapNode,MapProcName}};
			{error}-> %%褰撳墠鍦板浘瀵瑰簲鐨勭嚎璺敊璇�
				case lines_manager:get_line_status(MapId)  of	 %%鑾峰彇绾胯矾鐘舵��
					error-> {error};
					LineInfos->
						{NewLineId,_RoleCount}=line_util:get_min_count_of_lines(LineInfos), %%寰楀埌鏈�灏忎汉鏁扮殑绾胯矾
						case lines_manager:get_map_name(NewLineId, MapId) of %%鍐嶆鏌ヨ鍦板浘鍜岃妭鐐�
							{ok,{MapNode,MapProcName}}->{ok,{NewLineId,MapNode,MapProcName}};
							{error}-> {error}
						end
				end
	end.
transport(RoleInfo, MapInfo,LineId,MapId,{X,Y} = Coord) ->		
        OldMapNode = get_node_from_mapinfo(MapInfo),
        case get_best_map(MapId,LineId) of
			{ok,{NewLineId,MapNode,MapProcName}}->
				case OldMapNode =:= MapNode of
					true ->
						change_map_in_same_node(MapInfo,MapNode,MapProcName,MapId,NewLineId,X,Y);
					false ->
						change_map_in_other_node_begin(MapInfo,MapNode,MapProcName,MapId,NewLineId,X,Y)
				end;
			{error}->
				Message = role_packet:encode_map_change_failed_s2c(?ERRNO_JOIN_MAP_ERROR_MAPID),
				send_data_to_gate(Message),
				slogger:msg("MAP CHANGE failed lines_manager:get_map_name error!!!!!!!!!\n")
		end.  


transport_by_npc(RoleInfo, MapInfo, NpcId,Id)->
	Mapid = get_mapid_from_mapinfo(MapInfo),	
	npc_function_frame:do_action(Mapid,RoleInfo,NpcId,transport,[Id,MapInfo,NpcId]).
	
timer_check(RoleInfo, LastTick, NowTime) ->
	case LastTick of
		undefined ->
			put(last_tick, NowTime);
		_Any->
			MSecs = timer:now_diff(NowTime, LastTick),
			case (MSecs > ?TIME_OUT_ACTION)	of
				true ->
					%% 瓒呮椂浜�
%%					slogger:msg("too long time no event ,exit this processor \n"),
					%%RoleId = get_id_from_roleinfo(RoleInfo),
					%%Pid = creature_op:get_pid_from_creature_info(get(creature_info)),
					%%role_manager:stop_role_processor(node(),RoleId,Pid,uninit);
					todo;
				false ->
					%% 鏈秴鏃�
					nothing
			end
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 杩斿洖蹇嵎鏍忕殑鍐呭
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
send_display_hotbar(RoleInfo) ->
	RoleId = get_id_from_roleinfo(RoleInfo),
	EntryList = skill_db:get_quick_bar(RoleId),
	Message = role_packet:encode_display_hotbar_s2c(EntryList),
	send_data_to_gate(Message).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鏇存柊蹇嵎鏍忕殑鍐呭
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_hotbar(SlotId, ClassId, EntryId) ->
	skill_db:update_quick_bar(get(roleid), SlotId, ClassId, EntryId).

process_sing_complete(RoleInfo, TargetID, SkillID, SkillLevel, FlyTime) ->
	SelfID = get_id_from_roleinfo(RoleInfo),
	Now = timer_center:get_correct_now(),
	role_sitdown_op:hook_on_action_async_interrupt(Now,sing_complate),
	case creature_op:get_creature_info(TargetID) of
		undefined->
			 process_cancel_attack(SelfID, out_range);
		TargetInfo->	 
			case combat_op:process_sing_complete(RoleInfo, TargetInfo, SkillID, SkillLevel) of
				{ok, {ChangedAttr, CastResult}} ->					
					skill_op:set_casttime(SkillID),					
					process_damage_list(SelfID,RoleInfo,SkillID,SkillLevel,FlyTime, CastResult),
					creature_op:combat_bufflist_proc(RoleInfo,CastResult,FlyTime),
					set_leave_attack_time(TargetID,Now), 
					case env:get(commoncdswitch,0) of
							0->
								put(last_cast_time,Now);
							1->				
								case combat_op:is_normal_attack(SkillID) of
										true->
											put(last_nor_cast_time,Now);
										false->	 
											 put(last_cast_time,Now), 
											 put(last_nor_cast_time,Now)
								end
					end,
					NewInfo2 = apply_skill_attr_changed(RoleInfo,ChangedAttr),	
					put(creature_info, NewInfo2),
					update_role_info(SelfID, NewInfo2);	
				{error, out_range} ->
					process_cancel_attack(SelfID, out_range);
				{error,mp}->
					process_cancel_attack(SelfID, mp)	
			end
	end.

process_cancel_attack(RoleID, Reason) ->
	case Reason of
		out_range ->
			Message = role_packet:encode_role_cancel_attack_s2c(RoleID,?ERROR_CANCEL_OUT_RANGE);
		move ->
			Message = role_packet:encode_role_cancel_attack_s2c(RoleID, ?ERROR_CANCEL_MOVE);
		interrupt_by_buff ->
			Message = role_packet:encode_role_cancel_attack_s2c(RoleID, ?ERROR_CANCEL_INTERRUPT);
		mp->
			Message = role_packet:encode_role_cancel_attack_s2c(RoleID, ?ATTACK_ERROR_MP)
	end,
	combat_op:cancel_sing_timer(),
	guildbattle_op:hook_cancel_sing(),
	send_data_to_gate(Message),	
	broadcast_message_to_aoi_client(Message),
	put(creature_info, set_state_to_roleinfo(get(creature_info), gaming)).


process_damage_list(TrueId,SelfInfo,SkillId,SkillLevel,FlyTime, CastResult)->
	SelfId = get_id_from_roleinfo(SelfInfo),
	Units = lists:foldl(fun({TargetID, DamageInfo, _},Units1 ) ->
				 case DamageInfo of
				 	missing ->
				 		Units1 ++ [{SelfId, TargetID, ?SKILL_MISS, 0, SkillId,SkillLevel}];
				 	{critical,Damage} ->
				 		role_statistics:update_role_dps_damage(Damage),
				 	 	Units1 ++ [{SelfId,TargetID, ?SKILL_CRITICAL, Damage, SkillId,SkillLevel}];
				 	{normal, Damage} ->
				 		role_statistics:update_role_dps_damage(Damage),
				 		Units1 ++ [{SelfId, TargetID, ?SKILL_NORMAL, Damage, SkillId,SkillLevel}];
				 	recover ->
				 		Units1 ++ [{SelfId, TargetID, ?SKILL_RECOVER, 0, SkillId,SkillLevel}]
				 end									     
	end,[],CastResult),
	%%鏈嶅姟鍣ㄤ笂闇�瑕佹牴鎹甪lytime寤惰繜璁＄畻浼ゅ
	attacked_broadcast(SelfId, FlyTime,Units),
	%%鍏堥�氱煡浠栦滑鐨勫鎴风琚敾鍑讳簡
	AttackMsg = role_packet:encode_be_attacked_s2c(TrueId,SkillId,Units,FlyTime),                                                     
	send_data_to_gate(AttackMsg),
	broadcast_message_to_aoi_client(AttackMsg).

%%涓嶇敤recompute_attr閲嶆柊璁＄畻灞炴��:init鏃剁畻瑁呭鏃朵細绠�,璺ㄨ妭鐐规椂浼氱洿鎺ュ鍒�,璋冪敤姝ゅ嚱鏁伴渶鍦ㄥ閮ㄨ嚜宸辫绠�
%%NewBuffers_with_Time:[{BuffId,BuffLevel,CastTime,CasterInfo}]
apply_buffers_with_starttime(NewBuffers_with_Time)->
	put(creature_info,set_buffer_to_roleinfo(get(creature_info),get(current_buffer))),
	RoleId = get(roleid),
	%% 璁剧疆Buffer缁欎汉鐗╅�犳垚鐨勭姸鎬佹敼鍙�
	lists:foreach(fun({BufferID, BufferLevel,_StartTime,_}) ->
				      BufferInfo = buffer_db:get_buffer_info(BufferID, BufferLevel),
				      put(creature_info, buffer_extra_effect:add(get(creature_info),BufferInfo))
		      end, NewBuffers_with_Time),
	%% 瑙﹀彂鐢盉uffer瀵艰嚧鐨勪簨浠�
 	lists:foreach(fun({BufferID, BufferLevel,StartTime,CasterInfo}) ->
				      buffer_op:generate_interval(BufferID, BufferLevel, 0,StartTime,CasterInfo)
 		      end, NewBuffers_with_Time),
 	
 	%%鑾峰彇鍓╀綑鏃堕棿
 	NewBuffers_with_LeftTime 
 		= lists:map(fun({BufferID, BufferLevel,StartTime,_})->
				 		BufferInfo = buffer_db:get_buffer_info(BufferID, BufferLevel),						
						DurationTime = buffer_db:get_buffer_duration(BufferInfo),
						UsedTime = erlang:trunc(timer:now_diff(timer_center:get_correct_now(),StartTime)/1000),
						if 
							(UsedTime <1000) or (DurationTime=:= -1)  ->LeftTime = DurationTime;
							true -> LeftTime = DurationTime - UsedTime
						end,
						{BufferID, BufferLevel,LeftTime } end,NewBuffers_with_Time),					
					
	%% 骞挎挱涓簡Buff鐨勬秷鎭�
	Message3 = role_packet:encode_add_buff_s2c(RoleId, NewBuffers_with_LeftTime),
	send_data_to_gate(Message3),  
	broadcast_message_to_aoi_client(Message3),
	%%骞挎挱鍋滄绉诲姩
	case can_move(get(creature_info)) of 
		false ->%%娓呯┖璺緞
				stop_move(get(creature_info));
		true ->
				nothing
	end.
	
init_buffers_by_node(NewBuffers_with_Time)->
	%% 瑙﹀彂鐢盉uffer瀵艰嚧鐨勪簨浠�
 	lists:foreach(fun({BufferID, BufferLevel,StartTime,CasterInfo}) ->
				      buffer_op:generate_interval(BufferID, BufferLevel, 0,StartTime,CasterInfo)
			  end, NewBuffers_with_Time).
	
%%init浣跨敤,涓嶇敤澶勭悊瑕嗙洊
init_buffers_on_role(NewBuffers_with_Time)->
	NewBuffers = lists:map(fun({Id,Level,_,_})-> {Id,Level} end,NewBuffers_with_Time),	
	case (NewBuffers =/= []) of
		true->
			recompute_attr( NewBuffers, []),					
			put(current_buffer, lists:ukeymerge(1, NewBuffers, get(current_buffer))),		
			apply_buffers_with_starttime(NewBuffers_with_Time);
		false->
			nothing
	end.

add_buffers_by_self(NewBuffersOri)->
	be_add_buffer(NewBuffersOri,{get(roleid),get_name_from_roleinfo(get(creature_info))}).	
	
add_buffers_by_self(NewBuffersOri,RemainTime)->
	be_add_buffer(NewBuffersOri,{get(roleid),get_name_from_roleinfo(get(creature_info))}).
			
%%娣诲姞buff  NewBuffersOri:[{Id,Level}] CasterInfo:{CasterId,CasterName}	
be_add_buffer(NewBuffersOri,CasterInfo) ->
	NewBuffers = lists:ukeysort(1,NewBuffersOri),
	case is_dead() of
		false->
			%% 澶勭悊Buffer鐨勮鐩栨儏鍐�		
			Fun = fun({BufferID, BufferLevel},{TmpNewBuffer,TmpRemoveBuffer}) ->
					      case lists:keyfind(BufferID, 1, get(current_buffer)) of
						      false ->
							      %% 璇uff娌℃湁琚姞杩囷紝鎵�浠ュ彲浠ュ姞					      		      
							      {TmpNewBuffer++[{BufferID, BufferLevel}],TmpRemoveBuffer};					      
						      {_, OldBufferLeve} ->
							      case BufferLevel >= OldBufferLeve of
								      false ->
									      %% 鍔犺繃,鏂癇uff鐨勭骇鍒綆
									      {TmpNewBuffer,TmpRemoveBuffer};
								      true ->
									      %% 鍔犺繃锛屼絾鏄柊Buff鐨勭骇鍒珮
										  remove_without_compute({BufferID, OldBufferLeve}),							    
									      {TmpNewBuffer ++ [{BufferID, BufferLevel}],TmpRemoveBuffer ++ [{BufferID, OldBufferLeve}]}
							      end
					      end
			      end,   	      	      
			{NewBuffers2,RemoveBuff} = lists:foldl(Fun,{[],[]},NewBuffers),
			case (RemoveBuff =/= []) or (NewBuffers2 =/= []) of
				true->			
					recompute_attr( NewBuffers2, RemoveBuff),
					put(current_buffer, lists:ukeymerge(1, NewBuffers2, get(current_buffer))),
					NewBuffers_with_Time = lists:map(fun({BufferID, BufferLevel})->{BufferID, BufferLevel,timer_center:get_correct_now(),CasterInfo} end,NewBuffers2),
					apply_buffers_with_starttime(NewBuffers_with_Time),
					combat_op:interrupt_state_with_buff(get(creature_info));
				false->
					nothing
			end,
			update_role_info(get(roleid),get(creature_info));
		_->
			nothing
	end.

stop_move(RoleInfo)->
	SelfId = get_id_from_roleinfo(RoleInfo),
	put(creature_info, set_path_to_roleinfo(RoleInfo, [])),
	StopMsg = role_packet:encode_move_stop_s2c(SelfId,get_pos_from_roleinfo(RoleInfo)),
	send_data_to_gate(StopMsg),												       
	broadcast_message_to_aoi_client(StopMsg).

%%鍗曠嫭瀹屾暣鍒犻櫎涓�涓猙uff
remove_buffer({BufferId,BufferLevel}) ->
	remove_without_compute({BufferId,BufferLevel}),
	recompute_attr([],[{BufferId,BufferLevel}]).

%%鍒犻櫎澶氫釜BuffList:{BuffId,Level}	
remove_buffers([])->
	nothing;
remove_buffers(OriBuffList)->
	BuffList = lists:filter(fun({BuffIdTmp,_})-> buffer_op:has_buff(BuffIdTmp) end,OriBuffList),
	lists:foreach(fun(BuffInfo)->
			remove_without_compute(BuffInfo)
		end,BuffList),
	recompute_attr([],BuffList).	

%%娌℃湁update_role_info&&娌℃湁閲嶆柊璁＄畻灞炴��
remove_without_compute({BufferId,BufferLevel})->
	RoleId = get(roleid),
	case buffer_op:has_buff(BufferId) of
		true->
			buffer_op:remove_buffer(BufferId),
			put(current_buffer, lists:keydelete(BufferId, 1, get(current_buffer))),
			BufferInfo2 = buffer_db:get_buffer_info(BufferId, BufferLevel),
			%% 浠庝汉鐗╃姸鎬佷腑鍒犻櫎
			put(creature_info,buffer_extra_effect:remove(get(creature_info),BufferInfo2)),
			put(creature_info,set_buffer_to_roleinfo(get(creature_info),get(current_buffer))),	
			%%鍙戦��	
			Message = role_packet:encode_del_buff_s2c(RoleId,BufferId),
			send_data_to_gate(Message),
			broadcast_message_to_aoi_client(Message);
		_->
			nothing
	end.

%%閲嶆柊璁＄畻buff
recompute_attr(NewBuffers2,RemoveBuff)->
	BaseAttr = get(base_attr),
	RemoveBaseAttr = [],
	OtherAttr = get(other_attr),
	RemoveAotherAttr = [], 
	recompute_attr(NewBuffers2,RemoveBuff,BaseAttr,RemoveBaseAttr,OtherAttr,RemoveAotherAttr).

%%閲嶆柊璁＄畻鍩虹灞炴�э紙瑁呭锛屼慨涓猴紝鎶�鑳� 锛�	
recompute_base_attr()->
	RemoveBaseAttr = get(base_attr),
	NewBaseAttr = lists:filter(fun({_,Value})->Value=/=0 end,get_role_base_attr()),
	put(base_attr,NewBaseAttr),
	OtherAttr = get(other_attr),
	RemoveOtherAttr = [], 
	recompute_attr([], [],NewBaseAttr,RemoveBaseAttr,OtherAttr,RemoveOtherAttr).
	
%%閲嶆柊璁＄畻鍏朵粬灞炴�э紙瀹犵墿绛夛級	
recompute_other_attr()->
	RemoveOtherAttr = get(other_attr),
	OtherAttr = lists:filter(fun({_,Value})->Value=/=0 end,get_role_other_attr()),
	put(other_attr,OtherAttr),
	BaseAttr = get(base_attr),
	RemoveBaseAttr = [], 
	recompute_attr([], [],BaseAttr,RemoveBaseAttr,OtherAttr,RemoveOtherAttr).
	

%%
%%閲嶆柊璁＄畻瑁呭鐨勫睘鎬�
%%
recompute_equipment_attr()->
	recompute_base_attr().
	
recompute_venation_attr()->
	recompute_base_attr().	

recompute_designation_attr()->
	recompute_other_attr().
	
recompute_skill_attr()->
	recompute_base_attr().
	
recompute_pet_attr()->
	recompute_other_attr().
	
		
%%閲嶆柊璁＄畻鎵�鏈夊睘鎬у拰buff	鏂板buff,鍒犻櫎buff,璋冪敤鍦ㄥ垹闄ゆ垨鏂板buff涔嬪悗鍙堥渶瑕佽绠楄澶囨洿鎹㈡椂,鐪佸幓涓�娆ecompute_attr
recompute_all_attr_after_buff(NewBuffers,RemoveBuff)->
	RemoveBaseAttr = get(base_attr),
	NewBaseAttr = lists:filter(fun({_,Value})->Value=/=0 end,get_role_base_attr()),
	put(base_attr,NewBaseAttr),
	RemoveOtherAttr = get(other_attr),
	OtherAttr = lists:filter(fun({_,Value})->Value=/=0 end,get_role_other_attr()),		 
	put(other_attr,OtherAttr),
	recompute_attr(NewBuffers,RemoveBuff,NewBaseAttr,RemoveBaseAttr,OtherAttr,RemoveOtherAttr).		

recompute_attr(NewBuffers2,RemoveBuff,BaseAttr,RemoveAttr,OtherAttr,RemoveOtherAttr)->
	SelfId = get(roleid),
	{NewAttributes, _CurrentBuffers, ChangeAttribute} = 
	compute_buffers:compute(get(classid), get(level), get(current_attribute), get(current_buffer), NewBuffers2, RemoveBuff,BaseAttr,RemoveAttr,OtherAttr,RemoveOtherAttr),
	%%搴旂敤灞炴�ф敼鍙�
	put(current_attribute, NewAttributes),
	OriInfo = get(creature_info),
	NewInfo = lists:foldl(fun(Attr,Info)->					
				 	role_attr:to_creature_info(Attr,Info)
				 end,OriInfo,ChangeAttribute),	
	put(creature_info,NewInfo),
	update_role_info(SelfId,get(creature_info)),
	%%鍙戦�佸睘鎬ф敼鍙�
	ChangeAttribute_Hp_Mp = role_attr:preform_to_attrs(ChangeAttribute),
	self_update_and_broad(ChangeAttribute_Hp_Mp).

can_move(RoleInfo) ->
	Deading = is_dead(),
	Freezing = lists:member(freezing, get_extra_state_from_roleinfo(RoleInfo)),
	Coma = lists:member(coma, get_extra_state_from_roleinfo(RoleInfo)),
	not (Freezing or Coma or Deading).    %% 鍙婊¤冻涓�绉嶅氨涓嶈兘绉诲姩.

is_in_avatar()->
	get_displayid_from_roleinfo(get(creature_info))=/=?DEFAULT_ROLE_DISPLAYID.	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%							 缁忛獙閲戦挶鐨勮幏鍙�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%閲戦挶锛岀粡楠�:涓汉鑾峰緱 = 鎬墿鍥烘湁*绛夌骇宸郴鏁�/闃熶紞鍏变韩浜烘暟*缁勯槦鍔犳垚(绛夌骇宸郴鏁版斁鍒颁釜浜虹殑loot閲屽仛)
loot_exp_and_money(OriMinMoney,OriMaxMoney,OriExp)->	
	case OriMaxMoney - OriMinMoney of
		0 ->	RanMoney = 0;
		Value -> RanMoney  = random:uniform(Value )
	end, 
	%%鍓湰涓病鏈夐槦浼嶅姞鎴�
	case instance_op:is_in_instance() of
		true->	 
			AoiMemberNum = 1,
			TeamAddation = 1;
		_->	
			case erlang:length(group_op:get_members_in_aoi()) + 1 of
				1 -> 
					AoiMemberNum = 1,
					TeamAddation = 1;
				2 ->
					AoiMemberNum = 2,
					TeamAddation = 1.3;
				3 ->
					AoiMemberNum = 3,
					TeamAddation = 1.5;	
				4 ->
					AoiMemberNum = 4,
					TeamAddation = 1.8;		
				5 ->
					AoiMemberNum = 5,
					TeamAddation = 2.0		 
			end
	end,
	OriMoney = OriMinMoney + RanMoney,
	ObMoney = erlang:trunc(OriMoney*TeamAddation/AoiMemberNum),
	ObExp = erlang:trunc(OriExp*TeamAddation/AoiMemberNum), 
	{ObMoney,ObExp}. 	
	
%%return: level_up/_	
obtain_exp(0)->
	nothing;
obtain_exp(AddExp)->
	Exp = trunc(AddExp),	
	RoleInfo = get(creature_info),
	RoleId = get_id_from_roleinfo(RoleInfo),
	OriLevel = get_level_from_roleinfo(RoleInfo),
	{NewLevel,TotalExp} = role_level_db:obtain_experience(Exp),
	NewExp  = TotalExp - role_level_db:get_level_experience(NewLevel),
	case NewLevel > OriLevel of			
		false ->				%%娌″崌绾э紝鏀瑰彉灞炴��
			%%Send add exp,Money,NewExp,NewMoney.
			put(creature_info,set_exp_to_roleinfo(get(creature_info),NewExp)),			
			update_role_info(RoleId,get(creature_info)),
			if
				(Exp =/= 0) -> 
					only_self_update([{expr, NewExp}]);
				true->
					nothing
			end; 	
		true ->
			level_up(NewLevel,NewExp),
			level_up						
	end.

%%
%%鑾峰緱鑽ｈ獕
%%
obtain_honor(AddValue)->
	Value = trunc(AddValue),
	Honor = get_honor_from_roleinfo(get(creature_info)),
	CurHonor = Honor + AddValue,
	put(creature_info,set_honor_to_roleinfo(get(creature_info),CurHonor)),
	only_self_update([{honor, CurHonor}]).

%%
%%鑾峰緱鐏靛姏
%%
obtain_soulpower(AddValue)->
	Value = trunc(AddValue),
	case role_soulpower:add_soulpower(Value) of
		true->
			RoleInfo = get(creature_info),
			update_role_info(get_id_from_roleinfo(RoleInfo),RoleInfo),
			CurSoulPower = role_soulpower:get_cursoulpower(),
			only_self_update([{soulpower, CurSoulPower}]);
		_->
			nothing
	end.
			
%%
%%娑堣�楃伒鍔�
%%		
consume_soulpower(Value)->
	case role_soulpower:consume_soulpower(Value) of
		true->
			RoleInfo = get(creature_info),
			update_role_info(get_id_from_roleinfo(RoleInfo),RoleInfo),
			CurSoulPower = role_soulpower:get_cursoulpower(),
			only_self_update([{soulpower, CurSoulPower}]);
		_->
			nothing
	end. 

%%
%%鏇存柊鏈�澶х伒鍔�
%%
update_maxsoulpower()->
	MaxValue = role_soulpower:get_maxsoulpower(),
	update_maxsoulpower(MaxValue).

update_maxsoulpower(MaxValue)->
	RoleInfo = get(creature_info),
	CurSoulPower = role_soulpower:get_cursoulpower(),
	update_role_info(get_id_from_roleinfo(RoleInfo),RoleInfo),
	only_self_update([{soulpower, CurSoulPower}]),
	only_self_update([{maxsoulpower, MaxValue}]).
	
%%鍗囩骇,灞炴�ф敼鍙�
level_up(NewLevel,LeftExp)->
	RoleId = get(roleid),
	role_game_rank:hook_on_levelup(NewLevel),
	quest_op:update({level},NewLevel),
	achieve_op:achieve_update({level},[0],NewLevel),
	goals_op:goals_update({level},[0],NewLevel),%%@@wb20130311
	OldLevel = get(level),
	put(level,NewLevel),
	gm_logger_role:role_level_up(RoleId,NewLevel),	
	pet_op:hook_on_role_levelup(NewLevel),
	role_soulpower:hook_on_role_levelup(OldLevel,NewLevel),
	congratulations_op:hook_on_role_levelup(NewLevel),
	{Power,Hprecover,CriDerate,Mprecover,MovespeedRate,Meleeimmunity,Rangeimmunity,Magicimmunity,Hpmax,Mpmax,Stamina,Strength,
	Intelligence,Agile,Meleedefense,Rangedefense,Magicdefense,Hitrate,Dodge,Criticalrate,Toughness,Imprisonment_resist,Silence_resist,
	Daze_resist,Poison_resist,Normal_resist,Fighting_Force} = compute_attrs(init,NewLevel),
	MoveSpeed = erlang:trunc(?BASE_MOVE_SPEED*(100+ MovespeedRate)/100),
	put(creature_info, set_level_to_roleinfo(get(creature_info), NewLevel)),
	put(creature_info, set_speed_to_roleinfo(get(creature_info),  MoveSpeed)),
	put(creature_info, set_life_to_roleinfo(get(creature_info), Hpmax)),		%%婊¤
	put(creature_info, set_hpmax_to_roleinfo(get(creature_info), Hpmax)),
	put(creature_info, set_mana_to_roleinfo(get(creature_info),  Mpmax)),		%%婊¤摑
	put(creature_info, set_mpmax_to_roleinfo(get(creature_info), Mpmax)),
	put(creature_info, set_exp_to_roleinfo(get(creature_info), LeftExp)),
	NowLevelExp = role_level_db:get_level_experience(NewLevel),
	NexLevelexp = role_level_db:get_level_experience(NewLevel+1),	
	case NexLevelexp of
		nolevel -> LevelupExp = 0;
		_ -> LevelupExp = NexLevelexp - NowLevelExp				%%鍗囩骇鎵�闇�缁忛獙
	end,
	put(creature_info, set_levelupexp_to_roleinfo(get(creature_info),LevelupExp)),
	put(creature_info, set_power_to_roleinfo(get(creature_info), Power)),
	put(creature_info, set_hprecover_to_roleinfo(get(creature_info), Hprecover)),
	put(creature_info, set_mprecover_to_roleinfo(get(creature_info), Mprecover)),
	put(creature_info, set_criticaldamage_to_roleinfo(get(creature_info), CriDerate)),
	put(creature_info, set_criticalrate_to_roleinfo(get(creature_info), Criticalrate)),
	put(creature_info, set_toughness_to_roleinfo(get(creature_info), Toughness)),
	put(creature_info, set_dodge_to_roleinfo(get(creature_info), Dodge)),
	put(creature_info, set_hitrate_to_roleinfo(get(creature_info), Hitrate)),
	put(creature_info, set_stamina_to_roleinfo(get(creature_info), Stamina)),	
	put(creature_info, set_agile_to_roleinfo(get(creature_info), Agile)),
	put(creature_info, set_strength_to_roleinfo(get(creature_info), Strength)),
	put(creature_info, set_intelligence_to_roleinfo(get(creature_info), Intelligence)),
	put(creature_info, set_immunes_to_roleinfo(get(creature_info), {Magicimmunity,Rangeimmunity,Meleeimmunity})),
	put(creature_info, set_debuffimmunes_to_roleinfo(get(creature_info), 
							 {Imprisonment_resist,Silence_resist,Daze_resist,Poison_resist,Normal_resist})),
	put(creature_info, set_defenses_to_roleinfo( get(creature_info), {Magicdefense,Rangedefense,Meleedefense})),
	put(creature_info, set_fighting_force_to_roleinfo(get(creature_info),Fighting_Force)),
	update_role_info(RoleId,get(creature_info)),
	Attributes = 
			    [
				{level, NewLevel},
				{expr, LeftExp},
				{hp, Hpmax},
				{mp, Mpmax},
				{power, Power},
				{hprecover, Hprecover},
  				{criticaldestroyrate,CriDerate},
  				{mprecover,Mprecover},
  				{movespeed, MoveSpeed},
  				{meleeimmunity,Meleeimmunity},
  				{rangeimmunity,Rangeimmunity},
  				{magicimmunity,Magicimmunity},
  				{hpmax,Hpmax},
  				{mpmax, Mpmax},
  				{stamina, Stamina},
  				{strength,Strength },
  				{intelligence, Intelligence},
  				{agile,Agile},
  				{meleedefense, Meleedefense},
  				{rangedefense, Rangedefense},
  				{magicdefense, Magicdefense},
 				{hitrate, Hitrate},
  				{dodge, Dodge},
  				{criticalrate, Criticalrate},
  				{toughness, Toughness},
  				{levelupexpr,LevelupExp},
  				{silver,get_silver_from_roleinfo(get(creature_info))},
  				{boundsilver,get_boundsilver_from_roleinfo(get(creature_info))},
				{maxsoulpower,role_soulpower:get_maxsoulpower()},
				{fighting_force, Fighting_Force}
  				],  				
  	self_update_and_broad(Attributes),
  	%%鍗囩骇璋冪敤鎶藉
	role_mainline:hook_level_up(),
  	lottery_op:on_playerlevelup(),
  	group_op:update_reg_self_info(),
  	spa_op:hook_on_role_levelup(NewLevel),
	%%濡傛灉鏂扮瓑绾ф湭鑳藉紑鍚柊鐨勭洰鏍囩珷鑺俒1,21,31,41,51,61,71]锛屼笉闇�瑕佸湪姝ゅ垵濮嬪寲锛屾墍浠ュ姞鍒ゆ柇  @@wb20130605
%% 	goals_op:goals_init(),
  	Result=lists:any(fun(OpenLevel)->
							 if
								 (OpenLevel>OldLevel) and (OpenLevel=<NewLevel)->
									 true;
								 true->
									 false
							 end
					 end,[1,21,31,41,51,61,71]),
	if Result=:=true ->
		   goals_op:goals_init();
	   true->
		   nothing
	end,
	achieve_op:role_attr_update(),
	astrology_op:astrology_money_init(NewLevel),
 	wing_op:honk_on_role_levelup(NewLevel),
	answer_op:hook_on_level_up(NewLevel),
	%%鍗囩骇鍒版寚瀹氱殑绾у埆鏃讹紝鍚姩杩炵画鐧诲綍鐨勯潰鏉垮拰鏀惰棌濂界ぜ鐨勬寜閽�%%
	continuous_logging_op:enable_continuous_favorite_board(NewLevel),
	
 	guild_op:hook_on_levelup(NewLevel).	
  
    

	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%								鐗╁搧鐨勬帀钀�,鍒涘缓								  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
generate_lootid()->
	Index = get(loot_index),
	case Index  of
		undefined ->
			put(loot_index,1);
		_ ->
			if 
				Index > 1000*1000 -> Index = 0;
				true -> nothing
			end, 
			put(loot_index,Index+1)
	end,
	get(loot_index).
	
%%璁＄畻缁勯槦閲戦挶鍜岀粡楠岃幏鍙�,缁欏懆鍥存椿鐫�鐨勯槦鍙嬪彂閫乼eamate_killed,{NpcId,Pos,Money,Exp}銆�
on_creature_killed(NpcId,ProtoId,Pos,QuestShareRoles)->
	case creature_op:get_creature_info(NpcId) of
		undefined->				%%璇ユ�墿宸茬粡琚Щ闄�,鐢ㄦā鏉胯绠�
			NpcProtoInfo = npc_db:get_proto_info_by_id(ProtoId),
			OriMinMoney = npc_db:get_proto_min_money(NpcProtoInfo),
			OriMaxMoney = npc_db:get_proto_max_money(NpcProtoInfo),
			OriExp   = npc_db:get_proto_exp(NpcProtoInfo);
		NpcInfo->	
			OriMinMoney = get_minsilver_from_npcinfo(NpcInfo),
			OriMaxMoney = get_maxsilver_from_npcinfo(NpcInfo),		
			OriExp = get_exp_from_npcinfo(NpcInfo)
	end,
	QualityExp = cal_quality_exp(ProtoId, OriExp),
	{Money,Exp} = loot_exp_and_money(OriMinMoney,OriMaxMoney,QualityExp),
	MemberIds = group_op:get_members_in_aoi(),
	case MemberIds of
		[] ->
			nothing;
		_->	
			Message = {teamate_killed,{NpcId,ProtoId,Pos,Money,Exp}},
			lists:foreach(fun(MemberId)->send_to_other_role(MemberId,Message) end ,MemberIds)
	end,
	%%浠诲姟鍒嗕韩
	case QuestShareRoles -- [get(roleid)|MemberIds] of
		[]->
			nothing;
		SendShareRoles->
			MessageShare = {death_share_killed,{NpcId,ProtoId}},
			lists:foreach(fun(ShareId)->
				case creature_op:is_in_aoi_list(ShareId) of
					true->
						send_to_other_role(ShareId,MessageShare);
					_->
						nothing
				end	
			 end ,SendShareRoles)	
	end,
	teams_loot(NpcId,ProtoId,Pos,Money,Exp),
	role_mainline:update({monster_kill,ProtoId}),
	loop_instance_op:hook_kill_monster(ProtoId).

%%浼氬垎浜殑鎬墿:鍒嗕韩浠诲姟,鍒嗕韩娲昏穬搴�,鍒嗕韩鎴愬氨
death_share_killed(_NpcId,ProtoId)->
	quest_op:update({monster_kill,ProtoId}),
	activity_value_op:update({monster_kill,ProtoId}),
	goals_op:goals_update({monster_kill},[ProtoId]),
	achieve_op:achieve_update({monster_kill},[ProtoId]).
%%璁＄畻鐤插姵搴�
teams_loot(NpcId,ProtoId,Pos,OriMoney,OriExp)->
	case creature_op:get_creature_info(NpcId) of
		undefined->			%%璇ユ�墿宸茬粡琚Щ闄�,鐢ㄦā鏉胯绠�
			NpcProtoInfo  = npc_db:get_proto_info_by_id(ProtoId),
			NpcLevel = npc_db:get_proto_level(NpcProtoInfo),
			NpcType = npc_db:get_proto_npcflags(NpcProtoInfo);
		NpcInfo->
			ProtoId = get_templateid_from_npcinfo(NpcInfo),
			NpcLevel = 	get_level_from_npcinfo(NpcInfo),
			NpcType = get_npcflags_from_npcinfo(NpcInfo)
	end,
	DiffLevel = erlang:abs(get_level_from_roleinfo(get(creature_info)) - NpcLevel),
	if 
		(DiffLevel =< 6) -> 						Factor = 1;	
		(DiffLevel>6 )and(DiffLevel=<10)->			Factor = 0.5;
		DiffLevel>10					->			Factor = 0;	
		true -> Factor = 0
	end,	
	Rate = fatigue:get_gainrate(),
	%%鏉�鎬娇鐢ㄧ粡楠屾瘮鐜�
	ExpRateList = get_expratio_from_roleinfo(get(creature_info)),
	case lists:keyfind(?EFFECT_EXP_COMMON,1,ExpRateList) of
		false->
			ExpRate = 1;
		{_,Value}->
			ExpRate = 1 + Value/100
	end,
	PetExpRate = get_petexpratio_from_roleinfo(get(creature_info)),
	%%Vip
	VipAdd = vip_op:get_addition_with_vip(kill_monster)/100,
	GlobalRate = global_exp_addition:get_role_exp_addition(monster),
	Exp = erlang:trunc(Rate*OriExp*(ExpRate+VipAdd+GlobalRate)*Factor),
	PetExp = erlang:trunc(Rate*OriExp*Factor*PetExpRate),
	Money = erlang:trunc(Rate*OriMoney*Factor),
	
	%%缁欓挶	
	if
		Money=/=0->
			%% send to client 
			SendMoneyMsg = role_packet:encode_money_from_monster_s2c(NpcId,ProtoId,Money),
			send_data_to_gate(SendMoneyMsg),
			money_change(?MONEY_BOUND_SILVER,Money,got_monster); 		%%鎬墿鍙帀鏅�氶噾甯�
		true->
			nothing
	end,
	%%缁欑粡楠�
	if
		Exp=/=0->
			obtain_exp(Exp);
		true->
			nothing
	end,
	%%缁欏疇鐗╃粡楠�
	if
		PetExp=/=0->
			pet_op:hook_on_got_exp(PetExp);
		true->
			nothing
	end,		
	%%缁欐帀钀�
	if
		Rate=:=0->		%%闃叉矇杩蜂笉璧版帀钀�
			nothing;		
		true->	
			item_loot(NpcId,ProtoId,Pos,NpcLevel)
	end,
	quest_op:update({monster_kill,ProtoId}),
	activity_value_op:update({monster_kill,ProtoId}),
	if
		NpcType =:= ?CREATURE_MONSTER->
			goals_op:goals_update({monster_kill},[ProtoId]),%%@@wb20130311
			achieve_op:achieve_update({monster_kill},[ProtoId]);
		true->
			nothing
	end.	
	
%%搴旂敤瑙勫垯,鍒ゆ柇鏄惁缁欏鎴风鍖呰９	
item_loot(NpcId,NpcProtoId,Pos,NpcLevel)->
	GenLootInfo = create_loot_items(NpcProtoId,NpcLevel),
	case GenLootInfo of
		[]-> nothing;
		_->
			LootId = generate_lootid(),
			loot_op:add_loot_to_list(LootId,GenLootInfo,NpcId,NpcProtoId,Pos),
			Message = role_packet:encode_loot_s2c(LootId,NpcId,Pos),
			send_data_to_gate(Message)
	end.

%%鐩存帴鍙戦�佺墿鍝佸埌瀹㈡埛绔�
item_show_with_lootinfo(NpcId,NpcProtoId,GenLootInfo,Pos)->
	case GenLootInfo of
		[]-> nothing;
		_->
			LootId = generate_lootid(),
			loot_op:add_loot_to_list(LootId,GenLootInfo,NpcId,NpcProtoId,Pos),
			query_loot(LootId)
	end.
	
query_loot(LootId) ->		
	case loot_op:get_loot_info(LootId) of
		false ->
			nothing;
		{LootId,LootInfo,_,_,_,{LootX,LootY}}	->	
%%			{MyX,MyY} = get_pos_from_roleinfo(get(creature_info)),
%%			case (erlang:abs(MyX - LootX) > ?LOOT_DISTANSE ) or (erlang:abs(MyY - LootY) > ?LOOT_DISTANSE ) of
%%				true ->%%璺濈楠岃瘉澶辫触
%%					slogger:msg("query_loot(LootId) ~p error distance  ~n",[LootId]),
%%					nothing;
%%				false ->
					SendLootInfo = lists:map(fun(SlotInfo)->role_attr:to_slot_info(SlotInfo) end,LootInfo),
					%%璁剧疆鐘舵�乭old
					loot_op:set_loot_to_hold(LootId),
					Message = role_packet:encode_loot_response_s2c(LootId,SendLootInfo),
					send_data_to_gate(Message)
%%			end
	end.
	
pick_loot(LootId,SlotNum)->
	case loot_op:get_item_from_loot(LootId,SlotNum) of
		{0,0}->
			todo;		
		{ItemProtoId,Count}->
			case auto_create_and_put(ItemProtoId,Count,got_monster)	of
				{ok,_} ->
					case loot_op:get_npc_protoid_from_loot(LootId) of
						0->
							nothing;
						NpcProtoId->
							creature_sysbrd_util:sysbrd({loot,NpcProtoId},{ItemProtoId,Count}),
							MapId = get_mapid_from_mapinfo(get(map_info)),
							creature_sysbrd_util:sysbrd({boss_loot,NpcProtoId,MapId},{ItemProtoId,Count})
					end,	
					case loot_op:remove_item_from_loot(LootId,SlotNum) of
						{remove,NewLootInfo}->
								Message = role_packet:encode_loot_remove_item_s2c(LootId,SlotNum),
								send_data_to_gate(Message),				%%鍙戠粰瀹㈡埛绔Щ闄�
								case loot_op:is_empty_loot(NewLootInfo) of 					
									0 -> 
										%%涓滆タ鍙栧畬浜嗭紝鍒犻櫎loot
										delete_loot(LootId,1);					
									_ ->
										nothing
								end;		
						_ ->
							nothing
					end;		
				_ ->
					nothing
			end	
	end.
		
delete_loot(LootId,Statu)->
	case loot_op:delete_loot_from_list(LootId,Statu) of
		release ->
			Message = role_packet:encode_loot_release_s2c(LootId),
			send_data_to_gate(Message);
		_ ->
			nothing
	end.
	
%%鐢熸垚鎺夎惤鐗╁搧						
create_loot_items(Templateid,NpcLevel)->
	LootFlag = get_lootflag_from_roleinfo(get(creature_info)),
	Mylevel = get_level_from_roleinfo(get(creature_info)),
	drop:apply_npc_droplist(Templateid,LootFlag,NpcLevel,Mylevel).	
	
%%妫�鏌ュ寘瀹归噺锛屽垱寤虹帺瀹剁墿鍝侊紝鏀惧埌鍖呴噷return: {ok,ItemIds}/Reason,ItemIds:鍫嗗彔鎴栧垱寤虹殑鐗╁搧id
auto_create_and_put(ItemProtoId,Count,Reason)->	
	TmpTempInfo = item_template_db:get_item_templateinfo(ItemProtoId),	
	MaxStack = item_template_db:get_stackable(TmpTempInfo),
	Result = case package_op:can_added_to_package(ItemProtoId,Count) of
		0 ->	%%涓嶅彲娣诲姞锛屽寘瑁规弧銆�
			Message = role_packet:encode_add_item_failed_s2c(?ERROR_PACKEGE_FULL),
			send_data_to_gate(Message),
			ItemIds = [],
			full;
		{stack,SlotNums} ->
			%%鍫嗗彔妲�
			{_,ItemIds} = items_op:auto_stack_to_slots(Count,SlotNums,MaxStack),						
			ok;
		{slot,SlotNums}->
			ItemIds = items_op:auto_multi_create(Count,SlotNums,MaxStack,ItemProtoId),			
			ok;
		{both,StackSlots,Empty_slots}->					%%鏃㈡湁鍙犲姞鍙堟湁鍒涘缓
			{LeftCount,ItemIds1} = items_op:auto_stack_to_slots(Count,StackSlots,MaxStack),	
			ItemIds2 = items_op:auto_multi_create(LeftCount,Empty_slots,MaxStack,ItemProtoId),
			ItemIds = ItemIds1 ++ ItemIds2,
			ok			
	end,
	case Result of
		ok->
			quest_op:update({obt_item,ItemProtoId}),
%% 			achieve_op:achieve_update({item},[ItemProtoId],Count),
			gm_logger_role:role_get_item(get(roleid),ItemIds,Count,ItemProtoId,Reason,get(level)),
			{ok,ItemIds};
		_->
			Result
	end.		

%%鍖哄埆瀵瑰緟鎹㈣澶囧拰鍖呰９妲戒氦鎹�	
swap_item(Srcslot,Desslot)->	 
	IsIllegal = (Srcslot =:= Desslot) or (not package_op:is_has_item_in_slot(Srcslot)) or is_dead() ,
	ErrorSlot = (package_op:where_slot(Srcslot)=:= error) or (package_op:where_slot(Desslot)=:= error),
	case IsIllegal or ErrorSlot of
		true ->						%%fuck hack!
			nothing;
		false ->
			SrcPos = package_op:where_slot(Srcslot),
			DesPos = package_op:where_slot(Desslot),
			if
				(SrcPos =:= package) and (DesPos =:= package) ->								%%鐩存帴鍋氭Ы浜ゆ崲
					process_swap_item(Srcslot,Desslot);
				((SrcPos =:= body) and ((DesPos =:= package) or (DesPos =:= body))) 
					or
				((DesPos =:= body) and ((SrcPos =:= package) or (SrcPos =:= body)))->			%%瑁呭浜ゆ崲
					process_swap_equip(Srcslot,Desslot);
				true->
					slogger:msg("swap_item maybe hack!!! Srcslot ~p Desslot ~p ~n",[Srcslot,Desslot])
			end
	end.


%%鐗╁搧浜ゆ崲		
process_swap_item(Srcslot,Desslot)->		
	{SrcItemid,SrcCount} = package_op:get_item_id_and_count_in_slot(Srcslot),
	SrcPos = package_op:where_slot(Srcslot),
	DesPos = package_op:where_slot(Desslot),
	SrcInfo = items_op:get_item_info_by_pos(SrcPos,SrcItemid),
	SrcTmplate = get_template_id_from_iteminfo(SrcInfo),
	case package_op:get_item_id_and_count_in_slot(Desslot) of
		[]->								%%绌烘Ы锛屾崲妲�
			DesTmplate = 0,	
			package_op:set_item_to_slot(Desslot,SrcItemid,SrcCount),
			package_op:del_item_from_slot(Srcslot),
			items_op:set_item_slot_by_pos(SrcPos,SrcItemid,Desslot),
			ChangeAttrs = [role_attr:to_item_attribute({slot,Desslot})],
			ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(SrcItemid),
														get_highid_from_itemid(SrcItemid),
														ChangeAttrs,[]),
			Message = role_packet:encode_update_item_s2c([ChangeInfo]),
			send_data_to_gate(Message);
		{DesItemid,DesCount}->				%%鐩爣妲芥湁涓滆タ
			SrcInfo = items_op:get_item_info_by_pos(SrcPos,SrcItemid),
			DesInfo = items_op:get_item_info_by_pos(DesPos,DesItemid),
			Stackable = get_stackable_from_iteminfo(SrcInfo),
			DesTmplate = get_template_id_from_iteminfo(DesInfo),
			%%鏄惁鏄悓绉嶇绫�
			IsSameProto = (SrcTmplate =:= DesTmplate),
			%%鏄惁鍙爢鍙�
			IsStackable = (Stackable > 1) and ( DesCount < Stackable) and ( SrcCount < Stackable ),
			case (IsSameProto and IsStackable) of
				false ->					%%浜ゆ崲					
					package_op:set_item_to_slot(Desslot,SrcItemid,SrcCount),
					package_op:set_item_to_slot(Srcslot,DesItemid,DesCount),
					items_op:set_item_slot_by_pos(SrcPos,SrcItemid,Desslot),
					items_op:set_item_slot_by_pos(DesPos,DesItemid,Srcslot),
					SrcChangeAttrs = [role_attr:to_item_attribute({slot,Desslot})],
					SrcChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(SrcItemid),
																get_highid_from_itemid(SrcItemid),
																SrcChangeAttrs,[]),
					DesChangeAttrs = [role_attr:to_item_attribute({slot,Srcslot})],
					DesChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(DesItemid),
																get_highid_from_itemid(DesItemid),
																DesChangeAttrs,[]),																																
					Message = role_packet:encode_update_item_s2c([SrcChangeInfo]++[DesChangeInfo]),
					send_data_to_gate(Message);
				true ->						%%鍙爢鍙�
					SrcLeft = SrcCount + DesCount - Stackable,
					case SrcLeft =< 0 of
						true ->				%%娌″墿浣欎簡锛屽爢鍙狅紝鍒犻櫎Src						
							package_op:set_item_to_slot(Desslot,DesItemid,SrcCount+DesCount),
							items_op:set_item_count_by_pos(DesPos,DesItemid,SrcCount+DesCount),									
							items_op:delete_item_from_itemsinfo_by_pos(SrcPos,SrcItemid),
							package_op:del_item_from_slot(Srcslot),
							gm_logger_role:role_release_item(get(roleid),SrcItemid,SrcTmplate,0,lost_swap_stack,get(level)),																		
							DesChangeAttrs = [role_attr:to_item_attribute({count,SrcCount + DesCount})],
							DesChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(DesItemid),
																		get_highid_from_itemid(DesItemid),
																		DesChangeAttrs,[]),		
							MessageDelete = role_packet:encode_delete_item_s2c(SrcItemid,?ITEM_DESTROY_NOTICE_NONE),
							send_data_to_gate(MessageDelete),																																																	
							MessageModify = role_packet:encode_update_item_s2c([DesChangeInfo]),
							send_data_to_gate(MessageModify);								
						false ->				%%鏈夊墿浣欙紝淇敼鍚勮嚜鏁伴噺			
							package_op:set_item_to_slot(Desslot,DesItemid,Stackable),
							package_op:set_item_to_slot(Srcslot,SrcItemid,SrcLeft),
							items_op:set_item_count_by_pos(DesPos,DesItemid,Stackable),
							items_op:set_item_count_by_pos(SrcPos,SrcItemid,SrcLeft),
							%%Send:
							SrcChangeAttrs = [role_attr:to_item_attribute({count,SrcLeft})],
							SrcChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(SrcItemid),
																		get_highid_from_itemid(SrcItemid),
																		SrcChangeAttrs,[]),
							DesChangeAttrs = [role_attr:to_item_attribute({count,Stackable})],
							DesChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(DesItemid),
																		get_highid_from_itemid(DesItemid),
																		DesChangeAttrs,[]),																																
							Message = role_packet:encode_update_item_s2c([SrcChangeInfo]++[DesChangeInfo]),
							send_data_to_gate(Message)
					end
			end			
	end,
	if
		SrcPos =/= DesPos->
			quest_op:update({obt_item,SrcTmplate}); 
		true->
			nothing
	end,
	if
		(SrcPos =/= DesPos) and (SrcTmplate =/= DesTmplate) and (DesTmplate=/=0)->
			quest_op:update({obt_item,DesTmplate});
		true->
			nothing
	end.
	
split_item(Slotnum,SplitNum)->
	case package_op:get_item_id_and_count_in_slot(Slotnum) of
	[]->						%%fuck hack!
		slogger:msg("split_item error,find hack!!Wrong Slot!Rolid ~p ~n",[get(roleid)]);
	{Itemid,Count} ->
		case package_op:get_empty_slot_in_package(1) of
			0->		
				Message = role_packet:encode_add_item_failed_s2c(?ERROR_PACKEGE_FULL),
				send_data_to_gate(Message),
				full;
			NewSlots->
				[NewSlot|_] = NewSlots, 
				ItemInfo = items_op:get_item_info(Itemid),
                case (ItemInfo=:=[]) or (SplitNum =< 0) of
                    true->
                        slogger:msg("split_item error,error Id ~p ~p ~p ~n",[Itemid,get(account_id),get(client_ip)]);
					_ ->
						case (get_stackable_from_iteminfo(ItemInfo) > 1) and (SplitNum< Count) of
							true->
								RoleId = get(roleid),
								ItemProtoId = get_template_id_from_iteminfo(ItemInfo),
								CoolDown =  get_cooldowninfo_from_iteminfo(ItemInfo),
								{NewId,NewItemInfo} = items_op:create_objects(NewSlot,ItemProtoId,SplitNum,CoolDown),
								package_op:set_item_to_slot(NewSlot,NewId,SplitNum),	%%鍔犲叆鑳屽寘
								Messageadd = role_packet:encode_add_item_s2c(NewItemInfo),
								send_data_to_gate(Messageadd),
								%%淇敼婧愭暟閲�
								package_op:set_item_to_slot(Slotnum,Itemid,Count - SplitNum),
								items_op:set_item_count(Itemid,Count - SplitNum),
								ChangeAttrs = [role_attr:to_item_attribute({count,Count - SplitNum})],
								ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(Itemid),
																				get_highid_from_itemid(Itemid),
																				ChangeAttrs,[]),
								gm_logger_role:role_get_item(RoleId,[NewId],SplitNum,ItemProtoId,split_item,get(level)),
								LeftNum = Count - SplitNum,
								gm_logger_role:role_consume_item(RoleId,Itemid,ItemProtoId,SplitNum,LeftNum),																								
								Message = role_packet:encode_update_item_s2c([ChangeInfo]),
								send_data_to_gate(Message);
							_->
								slogger:msg("split_item error,error ItemInfo ~p SplitNum ~p ~n",[ItemInfo,SplitNum])
						end
				end													
		end
	end.
	
handle_destroy_item(Slotnum)->
	ItemPos = package_op:where_slot(Slotnum),
	case (ItemPos=:=body) or (ItemPos=:=package) of
		true->
			case package_op:get_iteminfo_in_package_slot(Slotnum) of
				[]->						
					nothing;
				ItemInfo->
					proc_destroy_item(ItemInfo,role_destroy)
			end;
		_->
			nothing
	end.	

proc_destroy_item_without_db(Slotnum,Reason)->
	case package_op:get_iteminfo_in_normal_slot(Slotnum) of
		[]->						%%fuck hack!
			nothing;
		ItemInfo->
			Itemid = get_id_from_iteminfo(ItemInfo),
			ItemProtoId = get_template_id_from_iteminfo(ItemInfo),
			ProptoId = get_template_id_from_iteminfo(ItemInfo),
			%%浠庣墿鍝佷俊鎭噷鍒犻櫎
			items_op:delete_item_from_itemsinfo_without_db(Itemid),
			%%浠庤儗鍖呭垹闄�
			package_op:del_item_from_slot(Slotnum),
			gm_logger_role:role_release_item(get(roleid),Itemid,ProptoId,0,Reason,get(level)),
			%%鍙戦�佸垹闄や俊鎭�
			LostReason = items_op:get_lost_reason_for_client(Reason),
			MessageDelete = role_packet:encode_delete_item_s2c(Itemid,LostReason),
			send_data_to_gate(MessageDelete),
			quest_op:update({obt_item,ItemProtoId})
	end.

%%澶勭悊鍒犻櫎,缁欏鎴风鍙戦�佸垹闄や俊鎭�
proc_destroy_item(ItemInfo,Reason)->
	Itemid = get_id_from_iteminfo(ItemInfo),
	Slotnum = get_slot_from_iteminfo(ItemInfo),
	ItemPos = package_op:where_slot(Slotnum),
	ProptoId = get_template_id_from_iteminfo(ItemInfo),
	%%浠庣墿鍝佷俊鎭噷鍒犻櫎
	items_op:delete_item_from_itemsinfo_by_pos(ItemPos,Itemid),
	%%浠庤儗鍖呭垹闄�
	package_op:del_item_from_slot(Slotnum),
	gm_logger_role:role_release_item(get(roleid),Itemid,ProptoId,0,Reason,get(level)),
	quest_op:update({obt_item,ProptoId}),
	%%鍙戦�佸垹闄や俊鎭�
	%%slogger:msg("role_op:proc_destroy_item 20120720 Reason:~p ~n",[Reason]),
	LostReason = items_op:get_lost_reason_for_client(Reason),
	MessageDelete = role_packet:encode_delete_item_s2c(Itemid,LostReason),
	send_data_to_gate(MessageDelete).		
			
npc_function_list(NpcId)->
	RoleInfo = get(creature_info),
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	npc_function_frame:list_npc_function(Mapid,RoleInfo,NpcId).
	       		
%%瑙傚療鍒汉
handle_inspect({ServerId,RoleName})->
	MyRoldId = get(roleid),
	MyServerId = get_serverid_from_roleinfo(get(creature_info)),
	case role_pos_util:where_is_role_by_serverid(ServerId,RoleName) of
		[]->
			Msg = role_packet:encode_inspect_faild_s2c(?ERRNO_NOT_ONLINE),
			send_data_to_gate(Msg);
		RolePos->
			TargetRoleId = role_pos_db:get_role_id(RolePos),
			role_pos_util:send_to_role_by_serverid(ServerId,TargetRoleId,{other_inspect_you,{MyServerId,MyRoldId}}),
			%%璇锋眰缁忚剦淇℃伅
			role_pos_util:send_to_role_by_serverid(ServerId,TargetRoleId,{venation,{other_inspect_you,MyServerId,MyRoldId}}),
			role_pos_util:send_to_role_by_serverid(ServerId,TargetRoleId,{designation,{other_inspect_you,MyServerId,MyRoldId}})
	end.
			
handle_inspect_pet_c2s({ServerId,RoleName,PetId})->
	MyRoldId = get(roleid),
	MyServerId = get_serverid_from_roleinfo(get(creature_info)),
	case role_pos_util:where_is_role_by_serverid(ServerId,RoleName) of
		[]->
			Msg = role_packet:encode_inspect_faild_s2c(?ERRNO_NOT_ONLINE),
			send_data_to_gate(Msg);
		RolePos->
			role_pos_util:send_to_role_by_serverid(ServerId,role_pos_db:get_role_id(RolePos),{other_inspect_your_pet,{MyServerId,MyRoldId,PetId}})
	end.

%%鏈変汉瑙傚療鎴�,鐩存帴鎵撳寘鍙戠粰浠栫殑瀹㈡埛绔�	
handle_other_inspect_you({ServerId,RoldId})->
	BodyItemsId = package_op:get_body_items_id(),
	BodyItemsInfo = lists:map(fun(Id)->items_op:get_item_info(Id)end,BodyItemsId),
	GuildInfo= {guild_util:get_guild_id(),guild_util:get_guild_name(),guild_util:get_guild_posting()},
	SoulPowerInfo = {role_soulpower:get_cursoulpower(),role_soulpower:get_maxsoulpower()},
	Msg = role_packet:encode_inspect_s2c(get(creature_info),BodyItemsInfo,GuildInfo,SoulPowerInfo),	
	role_pos_util:send_to_role_clinet_by_serverid(ServerId,RoldId,Msg). 

handle_other_inspect_your_pet({ServerId,RoldId,PetId})->
	if 
		PetId =:= 0 ->
			case pet_op:get_out_pet() of
				[]->
					Msg = role_packet:encode_inspect_faild_s2c(?ERROR_PET_NO_PET),
					role_pos_util:send_to_role_clinet_by_serverid(ServerId,RoldId,Msg);
				GmPetInfo->
					send_pet_info_from_gmpetinfo(ServerId,GmPetInfo,RoldId)
			end;
		true->
			case pet_op:get_pet_gminfo(PetId) of
				[]->
					Msg = role_packet:encode_inspect_faild_s2c(?ERROR_PET_NOEXIST),
					role_pos_util:send_to_role_clinet_by_serverid(ServerId,RoldId,Msg);
				GmPetInfo->
					send_pet_info_from_gmpetinfo(ServerId,GmPetInfo,RoldId)
			end
	end.		

send_pet_info_from_gmpetinfo(ServerId,GmPetInfo,RoldId)->
	PetId = get_id_from_petinfo(GmPetInfo),
	case pet_op:get_pet_info(PetId) of
		[]->
			Msg = role_packet:encode_inspect_faild_s2c(?ERROR_PET_NOEXIST),
			role_pos_util:send_to_role_clinet_by_serverid(ServerId,RoldId,Msg);
		PetInfo->
			SkillInfo = pet_skill_op:get_pet_skillallinfo(PetId),
			%% pet skill slot info 
			SlotInfo = lists:map(fun({Slot,_,SlotState})-> pet_packet:make_psll(Slot,SlotState) end,SkillInfo),
			%%pet skill info
			Skills = lists:map(fun({Slot,{SkillId,Level,_CastTime},_})-> pet_packet:make_psk(Slot,SkillId,Level) end,SkillInfo),
			MyName = get_name_from_roleinfo(get(creature_info)),
			%PetEquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
			PetEquipInfo=[],
			PetAllInfo = pet_packet:make_pet(PetInfo,GmPetInfo,pet_equip_op:get_body_items_info(PetEquipInfo)),
			Msg = role_packet:encode_inspect_pet_s2c(MyName,PetAllInfo,SlotInfo,Skills),
			role_pos_util:send_to_role_clinet_by_serverid(ServerId,RoldId,Msg)
	end.

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%										鐗╁搧鐨勪娇鐢ㄥ拰瑁呭
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
%%鑾峰彇浜虹墿鐨勫熀纭�灞炴�� 鍖呭惈瑁呭鍜屼慨涓�
%%
get_role_base_attr()->
	%venation_op:get_venation_attr() ++ get_all_bodyitems_attr() ++ get_skill_add_attr()++wing_op:wing_to_attr_role().
	venation_op:get_venation_attr() ++ get_all_bodyitems_attr() ++ get_skill_add_attr().
	
%%
%%鑾峰彇浜虹墿鐨勫叾浠栧睘鎬�,WB20130417 add achieve
%%
get_role_other_attr()->
	designation_op:get_designation_attr() ++ get_pet_add_attr()++achieve_op:get_achieve_add_attr()++furnace_op:get_furnace_add_attribute()++astrology_op:get_astrology_add_attribute().
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%寰楀埌鐩墠韬笂鎵�鏈夌墿鍝佸睘鎬э紝璁＄畻濂楄鍜屽叏鏄熻Е鍙�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%						
get_all_bodyitems_attr()->
	BodyItemsId = package_op:get_body_items_id(),
	BodyItemsInfo = lists:map(fun(Id)-> items_op:get_item_info(Id) end,BodyItemsId ),
	ItemsAttr1 = lists:foldl(fun(ItemInfo,Attr)->
			case ItemInfo =/= [] of
				true ->
					items_op:get_item_attr(ItemInfo)++Attr ;
				false ->	
					slogger:msg("get_all_bodyitems_attr,error Itemid in ~p ~n",[BodyItemsId]),
					Attr
			end
			end,[],BodyItemsInfo),
	EnchantmensetsItems = lists:filter(fun(ItemInfoTmp)->
					Slot = get_slot_from_iteminfo(ItemInfoTmp),
					(Slot =/= ?MANTEAU_SLOT) and (Slot =/= ?FASHION_SLOT) and (Slot =/= ?RIDE_SLOT)
				end,BodyItemsInfo),
	case erlang:length(EnchantmensetsItems) >= ?SLOT_BODY_ENDEX -3 of
		true ->				%% 鍘熷瑁呭灞炴��+鍏ㄦ槦灞炴��+濂楄灞炴�� 
			MinEnchant = get_item_enchantmentset(BodyItemsInfo),
			apply_enchantments_changed(MinEnchant),
			ItemsAttr2 = get_item_enchantmentset_attr(MinEnchant) ++  get_equip_set_attr(BodyItemsInfo)++ItemsAttr1;							
		false ->			%%瑁呭涓嶈冻锛屽彧璁＄畻濂楄灞炴��
			apply_enchantments_changed(0),
			ItemsAttr2 =  get_equip_set_attr(BodyItemsInfo) ++ ItemsAttr1
	end,
	%% 褰撳墠瀹犵墿娣诲姞鐨勫睘鎬�
%%	ItemsAttr3 = get_pet_add_attr() ++ get_skill_add_attr() ++ ItemsAttr2,
	%% 缁忚剦娣诲姞鐨勫睘鎬�
%%	ItemsAttr4 = venation_op:get_venation_attr() ++ ItemsAttr3,
%%	ItemsAttr5 = designation_op:get_designation_attr()++ItemsAttr4,
%%	ItemsAttr5.
	ItemsAttr2.

%%寰楀埌褰撳墠瀹犵墿闄勫姞缁欒鑹茬殑灞炴��
get_pet_add_attr()->
	pet_op:get_pet_add_attr().

%%琚姩鎶�鑳介檮鍔犲睘鎬�	
get_skill_add_attr()->
	SkillBuff = skill_op:get_skill_add_attr(),
	SkillBuff.	
	
%%褰撳墠鐢熸槦濂楄{MinLevel,MinEnchant}	
%%get_item_enchantmentset(BodyItemsInfo)->
%%	{MinLevel,MinEnchant} = lists:foldl(fun(Info,{MinLevelTmp,MinEnt})->
%%									Ent = get_enchantments_from_iteminfo(Info),
%%									Level = get_level_from_iteminfo(Info),
%%									Slot = get_slot_from_iteminfo(Info),
%%									case (Slot =:= ?MANTEAU_SLOT) or (Slot =:= ?FASHION_SLOT) or (Slot =:= ?RIDE_SLOT) of
%%										true ->
%%											 {MinLevelTmp,MinEnt};
%%										false ->	 
%%											if
%%												(Level < MinLevelTmp)->
%%													NewLevel = Level ;
%%												true->
%%													NewLevel = MinLevelTmp
%%											end, 	 
%%											if 
%%												(Ent < MinEnt) -> {NewLevel,Ent};
%%												true -> {NewLevel,MinEnt}
%%											end
%%									end
%%								end,{?ROLE_MAX_LEVEL,?MAX_ENCHANTMENTS+1},BodyItemsInfo),
%%	if
%%		MinEnchant=:= ?MAX_ENCHANTMENTS+1->
%%			{MinLevel,0};
%%		true->	
%%			{MinLevel,MinEnchant}
%%	end.

get_item_enchantmentset(BodyItemsInfo)->
	MinEnchant = lists:foldl(fun(Info,MinEnt)->
		Ent = get_enchantments_from_iteminfo(Info),
		Level = get_level_from_iteminfo(Info),
		Slot = get_slot_from_iteminfo(Info),
		case (Slot =:= ?MANTEAU_SLOT) or (Slot =:= ?FASHION_SLOT) or (Slot =:= ?RIDE_SLOT) of
			true ->
				MinEnt;
			false ->	 
				if 
					(Ent < MinEnt) -> 
						Ent;
					true -> 
						MinEnt
				end
		end
	end,?MAX_ENCHANTMENTS+1,BodyItemsInfo),
	if
		MinEnchant=:= ?MAX_ENCHANTMENTS+1->
			0;
		true->	
			MinEnchant
	end.
	
%%鐢熸槦濂楄灞炴��
%%get_item_enchantmentset_attr(MinLevel,MinEnchant)->
%%	if 
%%		(MinEnchant=:=0)->
%%			[];
%%		true ->
%%			case enchantments_db:get_enchantments_info(equipment_op:get_item_level_star(MinLevel,MinEnchant)) of
%%				[]->
%%					[];
%%				EnchantmentInfo->
%%					enchantments_db:get_enchantments_set_attr(EnchantmentInfo)
%%			end
%%	end.

get_item_enchantmentset_attr(MinEnchant)->
	if 
		(MinEnchant=:=0)->
			[];
		true ->
			case enchantments_db:get_enchantments_info(MinEnchant) of
				[]->
					[];
				EnchantmentInfo->
					enchantments_db:get_enchantments_set_attr(EnchantmentInfo)
			end
	end.

apply_enchantments_changed(Enchant)->
	case get_view_from_roleinfo(get(creature_info)) of
		Enchant->
			nothing;
		_->
			put(creature_info,set_view_to_roleinfo(get(creature_info),Enchant)),
			self_update_and_broad([{view,Enchant}])
	end.
					
%%濂楄灞炴��
get_equip_set_attr(BodyItemsInfo)->
	ItemSets = lists:foldl(fun(ItemInfo,SetsTmp)->
								SetId = get_equipmentset_from_iteminfo(ItemInfo),
								ItemTmpId = get_template_id_from_iteminfo(ItemInfo),
								if
									SetId =/= 0 -> 
											case lists:keyfind(SetId,1,SetsTmp) of
												false ->
													Sets = [{SetId,[ItemTmpId]}]++SetsTmp;
												{SetId,ItemTmpIds} ->
													ItemSetTempIds = equipmentset_db:get_equipmentset_includes(SetId),
													lists:foldl(fun([NotBound,Bound],Acc)->
																	case lists:member(ItemTmpId,[NotBound,Bound]) of
																		true->
																			[LeftId] = lists:delete([NotBound,Bound],[ItemTmpId]),
																			case lists:member(LeftId,ItemTmpIds) of
																				true->
																					Acc;
																				_->
																					lists:keyreplace(SetId,1,SetsTmp,{SetId,[ItemTmpId|ItemTmpIds]})
																			end;
																		_->
																			Acc
																	end
																end,SetsTmp,ItemSetTempIds),
													Sets  = lists:keyreplace(SetId,1,SetsTmp,{SetId,[ItemTmpId|ItemTmpIds]})
											end,
											Sets;
									true ->
											SetsTmp								
								end end,[],BodyItemsInfo),								
	ItemsSetAttr = lists:foldl( fun ({SetId,ItemIdTmps},Attrs)->
									ItemSetTmpIds = equipmentset_db:get_equipmentset_includes(SetId),
									Count = length(ItemIdTmps),
									Attr = equipmentset_db:get_equipmentset_states(SetId,Count),
									Attr ++ Attrs
								end,[],ItemSets),
	ItemsSetAttr.
	

%%鑷姩瑁呭/鑷姩鍗歌浇	
auto_equip_item(SrcSlot)->
	case creature_op:is_creature_dead(get(creature_info)) of
		true ->
			nothing;
		_ ->		
			case package_op:where_slot(SrcSlot) of
				body ->			%%鍗镐笅
					auto_equip_item(unequip,SrcSlot);
				package->		%%瑁呰浇
					auto_equip_item(equip,SrcSlot);
				_->
					slogger:msg("Error auto_equip_item SrcSlot ~p~n",[SrcSlot])
			end
	end.
	

%%鏌ユ壘鐩稿簲浣嶇疆瑁呭鐗╁搧
auto_equip_item(equip,SrcSlot)->
	case package_op:get_iteminfo_in_normal_slot(SrcSlot) of
		[] ->						%%fuck hack!
			nothing;
		ItemInfo ->											 
			case get_inventorytype_from_iteminfo(ItemInfo) of 	%%鑾峰彇鍙澶囦綅缃�
				0 -> 
					nothing;
				EquitSlot ->
					case package_op:get_iteminfo_in_normal_slot(EquitSlot) of
						[] -> 
							DesSlot = EquitSlot;
						ItemInfo1 -> 							%%鐩爣妲芥湁涓滆タ
							case ( (EquitSlot=:= ?LFINGER_SLOT) or (EquitSlot=:= ?LARMBAND_SLOT) )  of							
								true ->					%%鍙澶囧乏鍙虫墜鐨勮澶�
									case package_op:get_iteminfo_in_normal_slot(EquitSlot+1) of
										[]->			%%鍙虫墜鏃犺澶�,鐩存帴瑁呭鍒板彸鎵�
											DesSlot = EquitSlot + 1;
										ItemInfo2->				%%鍙虫墜鏈夎澶�,鏍规嵁瑁呭濂藉潖鍐冲畾鎹㈠乏鎵嬭繕鏄彸鎵�
											case items_op:is_item_better_than(ItemInfo1,ItemInfo2) of
												true->
													DesSlot = EquitSlot + 1;
												_->
													DesSlot = EquitSlot
											end	
									end;	
								false ->
									DesSlot = EquitSlot													
							end						
					end,
				process_swap_equip(SrcSlot,DesSlot)	
			end		
	end;
												
auto_equip_item(unequip,SrcSlot)->
	case package_op:get_iteminfo_in_normal_slot(SrcSlot) of
		[] ->
			nothing;
		ItemInfo ->
			ItemProtoId = get_template_id_from_iteminfo(ItemInfo),
			Count = get_count_from_iteminfo(ItemInfo),
			case package_op:can_added_to_package(ItemProtoId,Count) of
				{slot,DessLots}->
					[DessLot|_T] =DessLots, 
					process_swap_equip(SrcSlot,DessLot);
				_ ->	%%涓嶅彲鑴变笅锛屽寘瑁规弧銆�
					Message = role_packet:encode_change_item_failed_s2c(ItemInfo,?ERROR_PACKEGE_FULL),
					send_data_to_gate(Message)	
			end					
	end.

%%妫�娴嬫槸鍚﹁兘瑁呭姝ょ墿鍝�	
can_equip_item(ItemInfo)->
	{MinLevel,MaxLevel} = get_requiredlevel_from_iteminfo(ItemInfo),
	AllowClass = get_allowableclass_from_iteminfo(ItemInfo),
	MyLevel = get(level),
	LevelCheck = ((MyLevel>=MinLevel) and (MyLevel=<MaxLevel)), 	
	ItemClassCheck = lists:member(get_class_from_iteminfo(ItemInfo),?PLAYER_ITEM_TYPES),
	RoleClassCheck = ( (AllowClass =:= 0) or (AllowClass =:= get(classid)) ),
	ItemClassCheck and RoleClassCheck and LevelCheck.

%%瑁呭鏄惁鑳借澶囧埌鏌愪釜妲戒綅			
can_equip_item_to(ItemInfo,Slot)->
	if
		Slot =< ?SLOT_BODY_ENDEX->
			EquitSlot = get_inventorytype_from_iteminfo(ItemInfo),
			case ( (EquitSlot=:= ?LFINGER_SLOT) or (EquitSlot=:= ?LARMBAND_SLOT) ) of
				true->
					(Slot =:= EquitSlot) or (Slot =:= EquitSlot+1);
				false ->
					EquitSlot =:= Slot
			end;
		true->
			false
	end.
		
%%鎹㈣澶�
process_swap_equip(SrcSlot,DesSlot)->
	SrcId = package_op:get_item_id_in_slot(SrcSlot),
	SrcInfo = items_op:get_item_info(SrcId),
	case package_op:where_slot(DesSlot) of
		package->
			SrcCanPut = true;
		body ->
			SrcCanPut = can_equip_item(SrcInfo) and can_equip_item_to(SrcInfo,DesSlot);		
		_ ->
			SrcCanPut = false
	end,	
	case package_op:get_item_id_in_slot(DesSlot) of
		[] ->				%%鐩爣妲戒负绌�
			DesInfo = [],
			DesId = 0,
			DesCanPut = true;						
		DesId ->
			DesInfo = items_op:get_item_info(DesId),
			case DesInfo of
				[] ->
					DesCanPut = false;
				_ ->
					case package_op:where_slot(SrcSlot) of
						body ->
							DesCanPut = can_equip_item(DesInfo) and can_equip_item_to(DesInfo,SrcSlot);
						_ ->
							DesCanPut = true 
					end							
			end
	end,
	case DesCanPut and SrcCanPut of
		true ->			
			process_swap_item(SrcSlot,DesSlot),					%%浜ゆ崲妲戒綅
			recompute_base_attr(),	
			achieve_op:hook_on_swap_equipment(SrcSlot,DesSlot,SrcInfo,DesInfo),
			goals_op:hook_on_swap_equipment(SrcSlot,DesSlot,SrcInfo,DesInfo),
			role_fighting_force:hook_on_change_role_fight_force(),
			proc_equip_changed_for_equip(SrcSlot),
			proc_equip_changed_for_equip(DesSlot),
			role_ride_op:hook_on_swap_item(DesSlot,SrcSlot),
			open_service_activities:collect_equipment(),
			case lists:member(SrcSlot,?DISPLAY_SLOTS) or  lists:member(DesSlot,?DISPLAY_SLOTS) of
				true->
					redisplay_cloth_and_arm();
				_->
					nothing
			end;
		false ->
			nothing
	end.			

redisplay_cloth_and_arm()->
	{ClotheTemId,ArmItemId} = item_util:get_role_cloth_and_arm_dispaly(),
	put(creature_info,set_cloth_to_roleinfo(get(creature_info),ClotheTemId)),
	put(creature_info,set_arm_to_roleinfo(get(creature_info),ArmItemId)),
	update_role_info(get(roleid),get(creature_info)),
	self_update_and_broad([{arm,ArmItemId},{cloth,ClotheTemId}]).	

%%澶勭悊瑁呭瑁呭缁戝畾鍜屾縺娲昏繃鏈�
proc_equip_changed_for_equip(Slot)->
	case package_op:where_slot(Slot) of
		body->
			case package_op:get_item_id_in_slot(Slot) of
				[]->
					nothing;
				ItemId->
					proc_equip_changed_for_equip_by_itemid(ItemId)
			end;
		_->
			nothing	
	end.	
	
proc_equip_changed_for_equip_by_itemid(ItemId)->
	case items_op:get_item_info(ItemId) of
		[]->
			nothing;
		ItemInfo->
			NewItemInfo = items_op:hook_item_bond_by_type(?ITEM_BIND_TYPE_PICK,ItemInfo),
			case items_op:should_be_actived_by_type(?ITEM_OVERDUE_TYPE_EQUIP,NewItemInfo) of
				true->
					items_op:active_item_overdue(get_id_from_iteminfo(NewItemInfo));
				_->
					nothing
			end			
	end.

not_restrict_item(ItemTmpId)->
	case get(restrict_items) of
		undefined->
			true;
		Temps->
			not lists:member(ItemTmpId,Temps)
	end.	

handle_use_target_item_c2s(TargetId,Slot)->
	handle_use_item(Slot,[],TargetId).

%%妫�娴嬫槸鍚﹁兘鐢ㄦ鐗╁搧:绛夌骇,鑱屼笟,鏄惁鍙敤(鏈塻pell鎴杝cript鎴杚uest),cd
can_use_item(ItemInfo)->
	{MinLevel,MaxLevel} = get_requiredlevel_from_iteminfo(ItemInfo),
	AllowClass = get_allowableclass_from_iteminfo(ItemInfo),
	MyLevel = get(level),
	QuestId = get_questid_from_iteminfo(ItemInfo),
	Spellid = get_spellid_from_iteminfo(ItemInfo),
	Script = get_scripts_from_iteminfo(ItemInfo),
	IsDead =  is_dead(),
	NotIsRestrict = not_restrict_item(get_template_id_from_iteminfo(ItemInfo)),
	case ( (AllowClass =:= 0) or (AllowClass =:= get(classid)) and (not IsDead) ) and NotIsRestrict of
		false ->
			false;
		true ->
			if
				((MyLevel>=MinLevel) and (MyLevel=<MaxLevel))-> 
						if
						( QuestId =/=0) or (Spellid=/=0) or (Script=/=0) ->
								case items_op:check_item_can_use(ItemInfo) of
									true ->	
										true;
									cooldown->
										Msg = role_packet:encode_use_item_error_s2c(?ATTACK_ERROR_COOLTIME),
										send_data_to_gate(Msg),
										false;
									overdue->
										Msg = role_packet:encode_use_item_error_s2c(?ERROR_ITEMUSE_OVERDUE),
										send_data_to_gate(Msg),
										false
								end; 		
						true ->
							false
						end;							
				true ->
					false
			end
	end.

%%TODO:鎸夐『搴忔娴嬩换鍔�,鑴氭湰,涔嬪悗鎵嶆槸spellid			
handle_use_item(Slot)->
%% 	io:format("use slot ~p ~n",[Slot]),
	handle_use_item(Slot,[]).

handle_use_item(Slot,ScriptArgs)->
%% 	io:format("use slot ~p ScriptArgs ~p ~n",[Slot,ScriptArgs]),
	handle_use_item(Slot,ScriptArgs,get(roleid)).
	
handle_use_item(Slot,ScriptArgs,TargetId)->
	case is_dead() of
		false->
			case package_op:get_iteminfo_in_package_slot(Slot) of
				[] ->
					nothing;			
				ItemInfo ->					
				%%	case creature_op:is_creature_dead(get(creature_info)) of 宸茬粡妫�鏌ヨ繃姝讳骸涓嶇敤閲嶅<鏋皯>
				%%		true ->
				%%			nothing;
				%%		_->			
							case can_use_item(ItemInfo) of
								true ->
									proc_use_item(ItemInfo,ScriptArgs,TargetId);
								false ->	
									nothing	
							end			
				%%	end			
			end;
		_->
			nothing
	end.
	
proc_use_item(ItemInfoTmp,ScriptArgs,TargetId)->	
	ItemInfo = items_op:hook_item_bond_by_type(?ITEM_BIND_TYPE_USE,ItemInfoTmp),
	QuestId = get_questid_from_iteminfo(ItemInfo),
	SpellId = get_spellid_from_iteminfo(ItemInfo),
	Script = get_scripts_from_iteminfo(ItemInfo),
	if
		QuestId =/= 0 -> Result1 = proc_item_quest(ItemInfo,QuestId);
		SpellId =/= 0 -> Result1 = cast_item_spell(ItemInfo,SpellId,TargetId);
		true -> Result1 = []
	end,
	%%鑴氭湰蹇呴』鎵ц
	if
		Script =/= 0 -> Result = proc_item_script(ItemInfo,Script,ScriptArgs);
		true-> Result =  Result1
	end,	
	case Result of
		ok->
			%%澶勭悊缁勫喎鍗�
			CoolDowninfo = {timer_center:get_correct_now(),get_spellcooldown_from_iteminfo(ItemInfo)},
			items_op:set_cooldowninfo(ItemInfo,CoolDowninfo),	
			%%澶勭悊娑堣��		
			consume_item(ItemInfo,1);
		_->
			nothing
	end.
	
%%鐗╁搧浣跨敤:鍙拡瀵逛娇鐢ㄨ��,娌℃湁鍚熷敱,鎶�鑳界瓑绾т负1,涓嶅弬涓庢垬鏂梒d璁＄畻绛�,鎵�浠ヤ笉鐢ㄨ蛋澶嶆潅鐨勬垬鏂楅�昏緫	
cast_item_spell(ItemInfo,SpellId,TargetId)->
	SelfId = get(roleid),
	SelfInfo = get(creature_info),
	SkillLevel = 1,
	case (((TargetId =:= SelfId) or (get_class_from_iteminfo(ItemInfo)=:=?ITEM_TYPE_TARGET_USE))
	and
		 ((TargetId=:= SelfId) or (creature_op:is_in_aoi_list(TargetId)))) of
		true->
			if
				TargetId =/= SelfId->
					TargetInfo = creature_op:get_creature_info(TargetId);
				true->	
					TargetInfo= SelfInfo
			end,
			case (TargetInfo=/=undefined) of
				true->
					SkillInfo = skill_db:get_skill_info(SpellId, SkillLevel),
					case combat_op:judge(SelfInfo, TargetInfo, SpellId, SkillLevel,SkillInfo) of
						true->
							{_ChangedAttr, CastResult} = 
								combat_op:process_instant_attack(SelfInfo, TargetInfo, SpellId, SkillLevel,SkillInfo),
							role_op:process_damage_list(get(roleid),SelfInfo,SpellId,SkillLevel, 0, CastResult),
							creature_op:combat_bufflist_proc(SelfInfo,CastResult,0),
							ok;
						JudgeResult->
							role_op:proc_attack_judged_error(JudgeResult,get(roleid), SpellId, TargetId),
							false
					end;
				_->
				 	false
			end;
		_->	
			false
	end.


%%			SelfInfo = get(creature_info),
%%			SkillLevel = 1,			
%%			%%鐩存帴骞挎挱鏁堟灉
%%			Units = [{SelfId, SelfId, ?SKILL_RECOVER, 0, SkillID,SkillLevel}],		
%%			SkillMsg = role_packet:encode_be_attacked_s2c(SelfId,SkillID,Units,0),                                                     
%%			send_data_to_gate(SkillMsg),
%%			broadcast_message_to_aoi_client(SkillMsg),
%%			SkillInfo = skill_db:get_skill_info(SkillID, SkillLevel),	
%%			%%閲婃斁鑰呭拰鐩爣閮芥槸鑷繁			
%%			CastResult = combat_op:cast_attack(SelfInfo, SelfInfo,SkillInfo),
%%			%%鍙鐞哹uff
%%			lists:foreach(fun({TargetID, _, OriBuffList}) ->
%%							BuffList = lists:map(fun({BuffTmp,_RateTmp})->BuffTmp end,OriBuffList),
%%							creature_op:process_buff_list(SelfInfo, TargetID, 0, BuffList)									     
%%				      end, CastResult),

proc_item_quest(ItemInfo,QuestId)->
	case quest_op:start_quest(QuestId,0) of		
		error->
			Msg = role_packet:encode_use_item_error_s2c(?ERROR_ITEMUSE_QUEST_CANNOT),
			send_data_to_gate(Msg),
			error;
		_->
			ok
	end.
		
proc_item_script(ItemInfo,Script,ScriptArgs)->
	%%items_op:exec_item_beam(Script,[ItemInfo|ScriptArgs]).
	items_op:exec_item_beam(Script,[ItemInfo|ScriptArgs]).%%鏋皯
proc_egg_script(Type,ItemInfo,Script,Proto)->
	items_op:exec_egg_beam(Script,[Type,ItemInfo,Script,Proto]).
	


%%
%%return true|false
%%	
check_money_old(MoneyType, MoneyCount)->
	case MoneyType of
		?MONEY_BOUND_SILVER ->
			BoundSilver = get_boundsilver_from_roleinfo(get(creature_info)),
			Silver = get_silver_from_roleinfo(get(creature_info)),
			(BoundSilver + Silver) >= abs(MoneyCount);
		?MONEY_SILVER ->
			get_silver_from_roleinfo(get(creature_info)) >= abs(MoneyCount);
		?MONEY_GOLD ->
			AccountName = get(account_id),
			case dal:read_rpc(account, AccountName) of
				{ok,[Account]}->
					#account{username=User,roleids=RoleIds,gold=OGold} = Account,
					if 
						OGold >= abs(MoneyCount) ->
							true;
						true->
							false
					end;
				_->
					slogger:msg(" check_money error !!! ~p ~n",[AccountName]),
					false		
			end;			
		?MONEY_TICKET->
			get_ticket_from_roleinfo(get(creature_info))>= abs(MoneyCount);
		?MONEY_CHARGE_INTEGRAL->
			{Charge_integral,_} = get(role_mall_integral),
			Charge_integral >= abs(MoneyCount);
		?MONEY_CONSUMPTION_INTEGRAL->
			{_,Consume_integral} = get(role_mall_integral),
			Consume_integral >= abs(MoneyCount);
		?MONEY_HONOR-> 
			Honor = get_honor_from_roleinfo(get(creature_info)) >= abs(MoneyCount);
		_->
			false
	end.

account_charge(IncGold,NewGold)->
	put(creature_info,set_gold_to_roleinfo(get(creature_info), NewGold)),
	NewAttrGold =[{gold, NewGold}],
	only_self_update(NewAttrGold).
%% 	achieve_op:achieve_update({money},[?MONEY_GOLD],NewGold).

%%zhangting 鑾峰彇褰撳墠璐︽埛
get_curr_account()->
	 AccountName = get(account_id),
	 case dal:read_rpc(account, AccountName) of
				{ok,[Account]}->
					Account;
				_->
					slogger:msg(" get_curr_account error !!! ~p ~n",[AccountName]),
					[]		
	 end.			

check_money(MoneyType, MoneyCount)->
	case MoneyType of
		?MONEY_BOUND_SILVER ->
			BoundSilver = get_boundsilver_from_roleinfo(get(creature_info)),
			Silver = get_silver_from_roleinfo(get(creature_info)),
			(BoundSilver + Silver) >= abs(MoneyCount);
		?MONEY_SILVER ->
			get_silver_from_roleinfo(get(creature_info)) >= abs(MoneyCount);
		?MONEY_GOLD ->
			AccountName = get(account_id),
			case dal:read_rpc(account, AccountName) of
				{ok,[Account]}->
					#account{username=User,roleids=RoleIds,gold=OGold,qq_gold=QQ_gold,local_gold=Local_gold} = Account,
				   case env:get(use_qq_pay_flag, 0) of
				     0-> 
					     if Local_gold >= abs(MoneyCount) ->true;true->false end;
					 1-> 
					     if QQ_gold >= abs(MoneyCount) ->true;true->false end;   
				     2->	  
					     if OGold >= abs(MoneyCount) ->true;true->false end
				   end;
					
				_->
					slogger:msg(" check_money error !!! ~p ~n",[AccountName]),
					false		
			end;			
		?MONEY_TICKET->
			get_ticket_from_roleinfo(get(creature_info))>= abs(MoneyCount);
		?MONEY_CHARGE_INTEGRAL->
			{Charge_integral,_} = get(role_mall_integral),
			Charge_integral >= abs(MoneyCount);
		?MONEY_CONSUMPTION_INTEGRAL->
			{_,Consume_integral} = get(role_mall_integral),
			Consume_integral >= abs(MoneyCount);
		?MONEY_HONOR-> 
			Honor = get_honor_from_roleinfo(get(creature_info)) >= abs(MoneyCount);
		_->
			false
	end.


money_change(MoneyType, MoneyCount,Reason) ->
  if 	(MoneyType =:= ?MONEY_GOLD ) and (MoneyCount =/= 0) ->
	   if MoneyCount>0 ->
       	  case env:get(use_qq_pay_flag, 0) of
			     1-> 
				    nothing;
			     _->	
				     #account{username=User, gold=OGold,qq_gold=QQ_gold,local_gold=Local_gold} = get_curr_account(),
                   money_change_gold(MoneyType, MoneyCount,Reason,0,MoneyCount+Local_gold)
			    end;
		true->
          online_gold_change(MoneyType, MoneyCount,Reason)
		end;
  true->
      money_change_not_gold(MoneyType, MoneyCount,Reason)
  end.


online_gold_change(MoneyType, MoneyCount,Reason) ->
	ReasonList=
		case erlang:is_atom(Reason)		of
			true->erlang:atom_to_list(Reason);
			_->Reason
		end,
													  
    #account{username=User, gold=OGold,qq_gold=QQ_gold,local_gold=Local_gold} = get_curr_account(),
	Amt=abs(MoneyCount),
	 case env:get(use_qq_pay_flag, 0) of
	  0->	 money_change_gold(MoneyType, MoneyCount,Reason,0,Local_gold-Amt);
	  1-> 
          {ok,Balance}= qq_gold_op:do_qq_pay(Amt,ReasonList),
          money_change_gold(MoneyType, MoneyCount,Reason,Balance,0);
	  2->	  
       
		  if QQ_gold> Amt ->
		     {ok,Balance}=  qq_gold_op:do_qq_pay(Amt,ReasonList),
			  money_change_gold(MoneyType, MoneyCount,Reason,Balance,Local_gold);
		  true->
			  if QQ_gold>0 ->
                {ok,Balance} = qq_gold_op:do_qq_pay(QQ_gold,ReasonList), 
                  money_change_gold(MoneyType, MoneyCount,Reason,Balance,Local_gold - (Amt-QQ_gold));
             true->
  				  money_change_gold(MoneyType, MoneyCount,Reason,0,Local_gold-Amt)
			  end
         end
	  end.


money_change_gold(MoneyType, MoneyCount,Reason,QQ_gold,Local_gold) ->
	RoleInfo = get(creature_info),
	AccountName = get(account_id),
	Roleid = get(roleid),
	Transaction = 
	fun()->
		case mnesia:read(account, AccountName) of
			[]->
				[];
			[Account]->
				#account{username=User, gold=OGold} = Account,
				NewGold = OGold+MoneyCount,
				NewAccount = Account#account{gold=NewGold,qq_gold=QQ_gold,local_gold=Local_gold},
				mnesia:write(NewAccount),
				NewAccount
		end
	end,
	case dal:run_transaction_rpc(Transaction) of
		{failed,badrpc,_Reason}->
			slogger:msg("money_change gold badrpc error!!!! (account,~p) error! Gold ~p ",[AccountName,MoneyCount]);
		{faild,Reason}->
			slogger:msg("money_change gold faild error!!!! (account,~p) error! Gold ~p ",[AccountName,MoneyCount]);
		{ok,[]}->
			slogger:msg("money_change gold Account error!!!! (account,~p) error! Gold ~p ",[AccountName,MoneyCount]);
		{ok,Result}->
			#account{username=User,roleids=RoleIds,gold=ReGold} = Result,
			NewRoleInfo = set_gold_to_roleinfo(RoleInfo, ReGold),
			NewAttrGold =[{gold, ReGold}],
			only_self_update(NewAttrGold),
			put(creature_info, NewRoleInfo),
%% 			achieve_op:achieve_update({money},[?MONEY_GOLD],ReGold),	
			gold_exchange:consume_gold_change(-MoneyCount,Reason),
			consume_return:gold_change(-MoneyCount,Reason),
			gm_logger_role:role_gold_change(User,Roleid,MoneyCount,ReGold,Reason),
			FRole = fun(RoleId) ->
				case role_pos_util:where_is_role(RoleId) of
					[]->
						nothing;
					RolePos->
						if
							RoleId =/= Roleid->
								Node = role_pos_db:get_role_mapnode(RolePos),
								Proc = role_pos_db:get_role_pid(RolePos),
								role_processor:account_charge(Node, Proc, {account_charge,MoneyCount,ReGold});
							true->
								nothing
						end
				end
			end,
			lists:foreach(FRole, RoleIds);
		_->
			slogger:msg("money_change gold unknow error!!!! (account,~p) error! Gold ~p ",[AccountName,MoneyCount])
	end.


  
money_change_not_gold(MoneyType, MoneyCount,Reason) ->
	RoleInfo = get(creature_info),
	if
		(MoneyType =:=?MONEY_BOUND_SILVER) and (MoneyCount=/= 0) ->
			%% 閾跺竵	
			HasBoundSilver = get_boundsilver_from_roleinfo(RoleInfo),
			case HasBoundSilver + MoneyCount < 0 of
				true->		
					NewSilver = 0,
					money_change(?MONEY_SILVER,HasBoundSilver + MoneyCount,Reason);
				_->
					NewSilver = HasBoundSilver + MoneyCount
			end,
			NewRoleInfo = set_boundsilver_to_roleinfo(get(creature_info), NewSilver),
			NewAttrSilver = [{boundsilver, NewSilver}],
			only_self_update(NewAttrSilver),
			gm_logger_role:role_boundsilver_change(get(roleid),MoneyCount,NewSilver,Reason,get(level)),
			put(creature_info, NewRoleInfo);
%% 			achieve_op:achieve_update({money},[?MONEY_BOUND_SILVER],NewSilver);	
		(MoneyType =:= ?MONEY_SILVER) and (MoneyCount=/= 0) ->
			NewSilver = get_silver_from_roleinfo(RoleInfo)+ MoneyCount,	
			NewRoleInfo = set_silver_to_roleinfo(RoleInfo, NewSilver),
			NewAttrSilver = [{silver, NewSilver}],	
			only_self_update(NewAttrSilver),
			gm_logger_role:role_silver_change(get(roleid),MoneyCount,NewSilver,Reason,get(level)),
			put(creature_info, NewRoleInfo);
		(MoneyType =:= ?MONEY_TICKET) and (MoneyCount=/= 0)->
			%% 绀煎埜
			NewTick = get_ticket_from_roleinfo(RoleInfo) + MoneyCount,
			NewRoleInfo = set_ticket_to_roleinfo(RoleInfo, NewTick),
			NewAttrTick = [{ticket, NewTick}],
			only_self_update(NewAttrTick),
			gm_logger_role:role_ticket_change(get(roleid),MoneyCount,NewTick,Reason,get(level)),
			put(creature_info, NewRoleInfo);
%% 			achieve_op:achieve_update({money},[?MONEY_TICKET],NewTick);
		(MoneyType =:= ?MONEY_CHARGE_INTEGRAL) and (MoneyCount=/= 0)->
			{Charge_integral,Consume_integral} = get(role_mall_integral),
			NewCharge_Integral = Charge_integral + MoneyCount,
			put(role_mall_integral,{NewCharge_Integral,Consume_integral}),
			mall_integral_db:add_role_mall_integral(get(roleid),NewCharge_Integral,Consume_integral),
			Message = login_pb:encode_change_role_mall_integral_s2c(#change_role_mall_integral_s2c{charge_integral=NewCharge_Integral,by_item_integral=Consume_integral}),
			role_op:send_data_to_gate(Message),
			gm_logger_role:role_charge_integral_change(get(roleid),MoneyCount,NewCharge_Integral,Reason,get(level));
		(MoneyType =:= ?MONEY_CONSUMPTION_INTEGRAL) and (MoneyCount=/= 0)->
			{Charge_integral,Consume_integral} = get(role_mall_integral),
			NewConsum_Integral = Consume_integral + MoneyCount,
			put(role_mall_integral,{Charge_integral,NewConsum_Integral}),
			mall_integral_db:add_role_mall_integral(get(roleid),Charge_integral,NewConsum_Integral),
			Message = login_pb:encode_change_role_mall_integral_s2c(#change_role_mall_integral_s2c{charge_integral=Charge_integral,by_item_integral=NewConsum_Integral}),
			role_op:send_data_to_gate(Message),
			gm_logger_role:role_consume_integral_change(get(roleid),MoneyCount,NewConsum_Integral,Reason,get(level));
		(MoneyType =:= ?MONEY_HONOR) and (MoneyCount=/= 0)->
			NewHonor = get_honor_from_roleinfo(RoleInfo) + MoneyCount,
			NewRoleInfo = set_honor_to_roleinfo(RoleInfo, NewHonor),
			NewAttrHonor = [{honor, NewHonor}],
			only_self_update(NewAttrHonor),
			put(creature_info, NewRoleInfo),
			gm_logger_role:role_honor_change(get(roleid),MoneyCount,NewHonor,Reason,get(level));
		(MoneyType =:= ?TYPE_GUILD_CONTRIBUTION) and (MoneyCount=/= 0)->
			case guild_util:is_have_guild() of
				true->
					guild_op:contribute(MoneyCount);
				_->
					ignor
			end;
		true->
			nothing
	end.


money_change_old(MoneyType, MoneyCount,Reason) ->
	RoleInfo = get(creature_info),
	if
		(MoneyType =:=?MONEY_BOUND_SILVER) and (MoneyCount=/= 0) ->
			%% 閾跺竵	
			HasBoundSilver = get_boundsilver_from_roleinfo(RoleInfo),
			case HasBoundSilver + MoneyCount < 0 of
				true->		
					NewSilver = 0,
					money_change(?MONEY_SILVER,HasBoundSilver + MoneyCount,Reason);
				_->
					NewSilver = HasBoundSilver + MoneyCount
			end,
			NewRoleInfo = set_boundsilver_to_roleinfo(get(creature_info), NewSilver),
			NewAttrSilver = [{boundsilver, NewSilver}],
			only_self_update(NewAttrSilver),
			gm_logger_role:role_boundsilver_change(get(roleid),MoneyCount,NewSilver,Reason,get(level)),
			put(creature_info, NewRoleInfo);
%% 			achieve_op:achieve_update({money},[?MONEY_BOUND_SILVER],NewSilver);	
		(MoneyType =:= ?MONEY_SILVER) and (MoneyCount=/= 0) ->
			NewSilver = get_silver_from_roleinfo(RoleInfo)+ MoneyCount,	
			NewRoleInfo = set_silver_to_roleinfo(RoleInfo, NewSilver),
			NewAttrSilver = [{silver, NewSilver}],	
			only_self_update(NewAttrSilver),
			gm_logger_role:role_silver_change(get(roleid),MoneyCount,NewSilver,Reason,get(level)),
			put(creature_info, NewRoleInfo);
		(MoneyType =:= ?MONEY_GOLD ) and (MoneyCount =/= 0)->
			AccountName = get(account_id),
			Roleid = get(roleid),
			Transaction = 
			fun()->
				case mnesia:read(account, AccountName) of
					[]->
						[];
					[Account]->
						#account{username=User, gold=OGold} = Account,
						NewGold = OGold+MoneyCount,
						NewAccount = Account#account{gold=NewGold},
						mnesia:write(NewAccount),
						NewAccount
				end
			end,



			case dal:run_transaction_rpc(Transaction) of
				{failed,badrpc,_Reason}->
					slogger:msg("money_change gold badrpc error!!!! (account,~p) error! Gold ~p ",[AccountName,MoneyCount]);
				{faild,Reason}->
					slogger:msg("money_change gold faild error!!!! (account,~p) error! Gold ~p ",[AccountName,MoneyCount]);
				{ok,[]}->
					slogger:msg("money_change gold Account error!!!! (account,~p) error! Gold ~p ",[AccountName,MoneyCount]);
				{ok,Result}->
					#account{username=User,roleids=RoleIds,gold=ReGold} = Result,
					NewRoleInfo = set_gold_to_roleinfo(RoleInfo, ReGold),
					NewAttrGold =[{gold, ReGold}],
					only_self_update(NewAttrGold),
					put(creature_info, NewRoleInfo),
%% 					achieve_op:achieve_update({money},[?MONEY_GOLD],ReGold),	
					gold_exchange:consume_gold_change(-MoneyCount,Reason),
					consume_return:gold_change(-MoneyCount,Reason),
					gm_logger_role:role_gold_change(User,Roleid,MoneyCount,ReGold,Reason),
					FRole = fun(RoleId) ->
						case role_pos_util:where_is_role(RoleId) of
							[]->
								nothing;
							RolePos->
								if
									RoleId =/= Roleid->
										Node = role_pos_db:get_role_mapnode(RolePos),
										Proc = role_pos_db:get_role_pid(RolePos),
										role_processor:account_charge(Node, Proc, {account_charge,MoneyCount,ReGold});
									true->
										nothing
								end
						end
					end,
					lists:foreach(FRole, RoleIds);
				_->
					slogger:msg("money_change gold unknow error!!!! (account,~p) error! Gold ~p ",[AccountName,MoneyCount])
			end;	
		(MoneyType =:= ?MONEY_TICKET) and (MoneyCount=/= 0)->
			%% 绀煎埜
			NewTick = get_ticket_from_roleinfo(RoleInfo) + MoneyCount,
			NewRoleInfo = set_ticket_to_roleinfo(RoleInfo, NewTick),
			NewAttrTick = [{ticket, NewTick}],
			only_self_update(NewAttrTick),
			gm_logger_role:role_ticket_change(get(roleid),MoneyCount,NewTick,Reason,get(level)),
			put(creature_info, NewRoleInfo);
%% 			achieve_op:achieve_update({money},[?MONEY_TICKET],NewTick);
		(MoneyType =:= ?MONEY_CHARGE_INTEGRAL) and (MoneyCount=/= 0)->
			{Charge_integral,Consume_integral} = get(role_mall_integral),
			NewCharge_Integral = Charge_integral + MoneyCount,
			put(role_mall_integral,{NewCharge_Integral,Consume_integral}),
			mall_integral_db:add_role_mall_integral(get(roleid),NewCharge_Integral,Consume_integral),
			Message = login_pb:encode_change_role_mall_integral_s2c(#change_role_mall_integral_s2c{charge_integral=NewCharge_Integral,by_item_integral=Consume_integral}),
			role_op:send_data_to_gate(Message),
			gm_logger_role:role_charge_integral_change(get(roleid),MoneyCount,NewCharge_Integral,Reason,get(level));
		(MoneyType =:= ?MONEY_CONSUMPTION_INTEGRAL) and (MoneyCount=/= 0)->
			{Charge_integral,Consume_integral} = get(role_mall_integral),
			NewConsum_Integral = Consume_integral + MoneyCount,
			put(role_mall_integral,{Charge_integral,NewConsum_Integral}),
			mall_integral_db:add_role_mall_integral(get(roleid),Charge_integral,NewConsum_Integral),
			Message = login_pb:encode_change_role_mall_integral_s2c(#change_role_mall_integral_s2c{charge_integral=Charge_integral,by_item_integral=NewConsum_Integral}),
			role_op:send_data_to_gate(Message),
			gm_logger_role:role_consume_integral_change(get(roleid),MoneyCount,NewConsum_Integral,Reason,get(level));
		(MoneyType =:= ?MONEY_HONOR) and (MoneyCount=/= 0)->
			NewHonor = get_honor_from_roleinfo(RoleInfo) + MoneyCount,
			NewRoleInfo = set_honor_to_roleinfo(RoleInfo, NewHonor),
			NewAttrHonor = [{honor, NewHonor}],
			only_self_update(NewAttrHonor),
			put(creature_info, NewRoleInfo),
			gm_logger_role:role_honor_change(get(roleid),MoneyCount,NewHonor,Reason,get(level));
		(MoneyType =:= ?TYPE_GUILD_CONTRIBUTION) and (MoneyCount=/= 0)->
			case guild_util:is_have_guild() of
				true->
					guild_op:contribute(MoneyCount);
				_->
					ignor
			end;
		true->
			nothing
	end.
	
%%鏀瑰彉鍚屼竴妯℃澘鐗╁搧涓暟	
consume_items(TmplateId,Count)->
	ItemIds = items_op:get_items_by_template(TmplateId),
	consume_items_by_ids_count(Count,ItemIds).

%%鏀瑰彉鍚屼竴绫荤墿鍝佺殑鐨勪釜鏁�,缁戝畾鐗╁搧浼樺厛娑堣��
consume_items_by_classid(ClassId,Count)->
	ItemIds = items_op:get_items_by_class_sort_by_bond(ClassId),
	consume_items_by_ids_count(Count,ItemIds).

%%鍦ㄤ竴缁勭墿鍝乮d閲屾秷鑰楀浐瀹氫釜鏁扮殑鐗╁搧	
consume_items_by_ids_count(Count,ItemIds)->	
	F = fun(ItemId,Sum)->
			    case Sum of
				    0 ->
					    0;
				    _->
					    Item = items_op:get_item_info(ItemId),
					    NCount = get_count_from_iteminfo(Item),
					    case NCount >=Sum of
						    true -> 					    
							    role_op:consume_item(Item,Sum),
							    0;
						    false ->
							    role_op:consume_item(Item,NCount),
							    Sum - NCount
					    end			    
			    end
            end,				    
	lists:foldl(F,Count,ItemIds).
      			
%%浣跨敤ItemInfo娑堣�楀崟涓墿鍝�
consume_item(ItemInfo,DelCount)->
	ItemId = get_id_from_iteminfo(ItemInfo),
	Count = get_count_from_iteminfo(ItemInfo),
	SlotNum = get_slot_from_iteminfo(ItemInfo),
	ProtoId = get_template_id_from_iteminfo(ItemInfo),
	LeftCount = Count - DelCount,  
	if 
		LeftCount =< 0->
			proc_destroy_item(ItemInfo,consume_up);
		true ->
			package_op:set_item_to_slot(SlotNum,ItemId,LeftCount),
			items_op:set_item_count(ItemId,LeftCount),
			Attrs = [role_attr:to_item_attribute({count,LeftCount})],
			ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(ItemId),get_highid_from_itemid(ItemId),Attrs,[]),				
 			MessageModify = role_packet:encode_update_item_s2c([ChangeInfo]),
			role_op:send_data_to_gate(MessageModify),
			RoleInfo = get(creature_info),
			RoleId = get_id_from_roleinfo(RoleInfo),
			quest_op:update({obt_item,ProtoId}),
			gm_logger_role:role_consume_item(RoleId,ItemId,ProtoId,DelCount,LeftCount)
	end.	

consume_item_buff(ItemInfo,DelCount)-> 
	Items_buff = get(items_buff),
	case Items_buff=:=undefined orelse  Items_buff =:=[]  of
	   true->
		   put(items_buff,[{ItemInfo,DelCount}]);
	   false->
           Items_buff_new = 
           case  lists:keyfind(ItemInfo, 1, Items_buff) of
           {_,DelCountAll}-> lists:keyreplace(ItemInfo, 1, Items_buff,{ItemInfo,DelCountAll+DelCount});           
           false->[{ItemInfo,DelCount}|Items_buff]
           end,
           put(items_buff,Items_buff_new)
	end.

consume_item_buff_do()-> 
	Items_buff = get(items_buff),
    slogger:msg("consume_item_buff_do Items_buff:~p ~n",[Items_buff]),
	put(items_buff,[]),
	case Items_buff=:=undefined orelse  Items_buff =:=[]  of
	   true->
		   nothing;
	   false->
           lists:foreach(
			     fun({ItemInfo,DelCount})->
					   consume_item(ItemInfo,DelCount)		 
            end,Items_buff) 
	end.


stop_move_broadcast_with_self(SelfInfo) ->
	StopMsg = role_packet:encode_move_stop_s2c(get_id_from_roleinfo(SelfInfo),get_pos_from_roleinfo(SelfInfo)),
	send_data_to_gate(StopMsg),									       
	broadcast_message_to_aoi_client(StopMsg).	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%									灞炴�у箍鎾�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
only_self_update([])->
	nothing;
only_self_update(UpdateAttr)->
	UpdateObj = object_update:make_update_attr(?UPDATETYPE_SELF,get(roleid),UpdateAttr),
	GateProc = get_proc_from_gs_system_gateinfo(get(gate_info)),
	tcp_client:object_update_update(GateProc,UpdateObj).
	
self_update_and_broad([])->
	nothing;
self_update_and_broad(UpdateAttr)->
	only_self_update(UpdateAttr),
	UpdateObj = object_update:make_update_attr(?UPDATETYPE_ROLE,get(roleid),UpdateAttr),
	creature_op:direct_broadcast_to_aoi_gate({object_update_update,UpdateObj}).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%									灞炴�у箍鎾�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
%%鍏朵粬浜虹櫥褰曚簡	
handle_other_login(RoleId)->
	Message = role_packet:encode_other_login_s2c(),
	send_data_to_gate(Message),
	slogger:msg("handle_other_login RoleId~p~n",[RoleId]),
	kick_out(RoleId).	
	
async_time_with_clinet()->
	Time = util:now_to_ms(timer_center:get_time_of_day()),
	Message = role_packet:encode_query_time_s2c(Time),
	send_data_to_gate(Message).	

set_leave_attack_time([],Time)->
	put(leave_attack_time,Time);
				
set_leave_attack_time(EnemyId,Time)->
	case (creature_op:what_creature(EnemyId)=:=role) and (EnemyId=/=get(roleid)) of
		true->
			put(leave_attack_time,Time);
		_->
			nothing
	end.					
				
is_leave_attack()->
	timer:now_diff(timer_center:get_correct_now(),get(leave_attack_time)) > ?LEAVE_ATTACK_TIME*1000.
				
update_dsp_info(Damage)->
	todo.	

broad_cast(SysId,EnemyId,EnemyName,ServerId)->
	ParamMyInfo = system_chat_util:make_role_param(get(creature_info)),
	ParamOther = chat_packet:makeparam(role,{EnemyId,EnemyName,ServerId}),
	MsgInfo = [ParamOther,ParamMyInfo],
	system_chat_op:system_broadcast(SysId,MsgInfo).
	
broad_cast(SysId,EnemyInfo)->
	ParamMyInfo = system_chat_util:make_role_param(get(creature_info)),
	ParamOther = system_chat_util:make_role_param(EnemyInfo),
	MsgInfo = [ParamOther,ParamMyInfo],
	system_chat_op:system_broadcast(SysId,MsgInfo).


%%鑾峰彇鍦ㄧ嚎鐨剅oles by zhangting
get_online_roles(Count) ->
    QH = qlc:q([X#role_pos.rolename || X <- role_pos_db:get_all_rolepos()]),
    qlc:eval(QH,[{max_list_size,Count}]).

cal_quality_exp(NpcId, OriExp)->
	%%鍓湰涓病鏈夐槦浼嶅姞鎴�
	case instance_op:is_in_instance() of
		true->	 
			case get(instance) of
				undefined -> 
					OriExp;
				Instance ->
					{_,_,ProtoId,_,_} = Instance,
					Quality = instance_quality_op:get_real_quality(ProtoId, NpcId),
					if Quality =:= -1 ->
						   OriExp;
					   true ->
							AddFac = instance_quality_op:get_addfac(ProtoId, Quality),
							trunc(OriExp * AddFac)
					end
			end;
		_->	
			OriExp
	end.

%%浣跨敤瀹犵墿铔嬨�婃灚灏戙��
use_pet_egg_ext(Type,Slot,Proto)->
	case is_dead() of
		false->
			case package_op:get_iteminfo_in_package_slot(Slot) of
				[] ->
					nothing;			
				ItemInfo ->	
							case can_use_egg(ItemInfo) of
								true ->
									proc_use_iegg(Type,ItemInfo,Proto,get(roleid));
								false ->
									nothing	
							end			
			end;
		_->
			nothing
end.

%%妫�鏌ユ槸鍚﹀彲浠ヤ娇鐢ㄥ疇鐗╄泲<鏋皯>
can_use_egg(ItemInfo)->
	{MinLevel,MaxLevel} = get_requiredlevel_from_iteminfo(ItemInfo),
	AllowClass=get_allowableclass_from_iteminfo(ItemInfo),
	MyLeve=get(level),
	Spellid=get_spellid_from_iteminfo(ItemInfo),
	Script = get_scripts_from_iteminfo(ItemInfo),
	NotIsRestrict = not_restrict_item(get_template_id_from_iteminfo(ItemInfo)),
	case is_dead() of
		false->
		case ((AllowClass=:=0) or (AllowClass=:=get(classid))) and NotIsRestrict of
				true->
			if
				(Spellid=/=0) or (Script=/=0)->
				case items_op:check_item_can_use(ItemInfo) of
					true->
						true;
					cooldown->
						Msg = role_packet:encode_use_item_error_s2c(?ATTACK_ERROR_COOLTIME),
						send_data_to_gate(Msg),
						false;
					overdue->
						Msg = role_packet:encode_use_item_error_s2c(?ERROR_ITEMUSE_OVERDUE),
						send_data_to_gate(Msg),
						false
				end;
			true->
				false
			end;
		false->
			false
		end;
		true->
			false
	end.

%%浣跨敤瀹犵墿铔�<鏋皯>
proc_use_iegg(Type,ItemInfoTmp,Proto,TargetId)->
	ItemInfo = items_op:hook_item_bond_by_type(?ITEM_BIND_TYPE_USE,ItemInfoTmp),
	SpellId = get_spellid_from_iteminfo(ItemInfo),
	Script = get_scripts_from_iteminfo(ItemInfo),
	if
		SpellId =/= 0 -> Result1 = cast_item_spell(ItemInfo,SpellId,TargetId);
		true -> Result1 = []
	end,
	%%鑴氭湰蹇呴』鎵ц
	if
		Script =/= 0 -> Result = proc_egg_script(Type,ItemInfo,Script,Proto);
		true-> Result =  Result1
	end,		
	case Result of
		ok->
			%%澶勭悊缁勫喎鍗�
			CoolDowninfo = {timer_center:get_correct_now(),get_spellcooldown_from_iteminfo(ItemInfo)},
			items_op:set_cooldowninfo(ItemInfo,CoolDowninfo),	
			%%澶勭悊娑堣��		
			consume_item(ItemInfo,1);
		_->
			nothing
	end.

%%鍏呭��
role_recharge(Name,Money)->
	{Ok,RoleId}=role_db:get_roleid_by_name(Name),
	if RoleId=:=[]->
		   nothing;
	   true->
		   case role_pos_util:where_is_role(RoleId) of
			   []->
				   nothing;
			   RolePos->
				   role_pos_util:send_to_role_by_pos(RolePos, {role_recharge,RoleId,Money})
		   end
	end.

role_online_recharge(RoleId,Money)->
			role_op:money_change(?MONEY_GOLD,Money*10,role_recharge).

reset_pet_advance_lucky({{Oyear,Omonth,Oday},{Ohour,_,_}})->
			{{Nyear,Nmonth,Nday},{Nhour,_,_}}=calendar:now_to_local_time(now()),
			if Nyear>Oyear->
					true;
				Nmonth>Omonth->
					true;
				(Nday>(Oday+1))->
					true;
				(Nday=:=(Oday+1)) and (Nhour>=6)->
					true;
			true->
					false
			end.
				
		   
		   
				   
	

						
					
			
	
	
	
	


