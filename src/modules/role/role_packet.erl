%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : role_packet.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 26 Apr 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(role_packet).

-compile(export_all).

-include("login_pb.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("item_struct.hrl").
%% 消息: 移动开始
handle(#role_move_c2s{posx = PosX,posy = PosY,path=Path,time = Time},RolePid)->
	role_processor:role_move_request(RolePid, {{PosX,PosY},Path,Time});
	
handle(#stop_move_c2s{posx = PosX,posy = PosY,time = Time},RolePid)->
	role_processor:stop_move_c2s(RolePid, {Time,{PosX,PosY}});

%% 消息: 发起攻击
handle(#role_attack_c2s{skillid=SkillID, creatureid=TargetID},RolePid)->
	role_processor:start_attack(RolePid, SkillID, TargetID);
	
%%使用物品
handle(#use_item_c2s{slot = SrcSlotNum},RolePid) ->
	role_processor:use_item(RolePid,SrcSlotNum);
	
%% 消息: 地图加载完毕
handle(#map_complete_c2s{},RolePid)-> 
	role_processor:map_complete(RolePid);
	
handle(#role_respawn_c2s{type = Type},RolePid) ->
	role_processor:role_respawn(RolePid,Type);	
	
handle(#start_block_training_c2s{},RolePid) ->
	role_processor:start_block_training_c2s(RolePid);

handle(Message,RolePid)->
	RolePid ! {role_packet,Message}.		


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 编码函数集合
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
encode_other_role_into_view_s2c(RoleId, RoleName, RolePos,Attrs) ->
	{X, Y} = RolePos,
	Other = #rl{roleid=RoleId, name=RoleName, x=X, y=Y, friendly=1, attrs=Attrs},
	login_pb:encode_other_role_into_view_s2c(#other_role_into_view_s2c{other=Other}).

encode_npc_into_view_s2c(Id, Name, Pos,Attrs) ->
	{X, Y} = Pos,
	Npc = #nl{npcid=Id, name=Name, x=X, y=Y, friendly=true,attrs=Attrs},
	login_pb:encode_npc_into_view_s2c(#npc_into_view_s2c{npc=Npc}).

encode_creature_outof_view_s2c(RoleId) ->
	login_pb:encode_creature_outof_view_s2c(#creature_outof_view_s2c{creature_id=RoleId}).

encode_other_role_move_s2c(OtherId, Time,{Posx,Posy}, Path) ->
	CoordS = lists:map(fun(X) -> pb_util:convert_pos_to_coord(X) end, Path),
	login_pb:encode_other_role_move_s2c(#other_role_move_s2c{other_id=OtherId, time=Time, path=CoordS,posx = Posx,posy = Posy}).

encode_role_map_change_s2c({X, Y}, NewMapId, LineId) ->
	login_pb:encode_role_map_change_s2c(#role_map_change_s2c{x=X, y=Y, lineid=LineId, mapid = NewMapId}).

encode_other_role_map_init_s2c(OtherRoleInfo) ->
	Converter = fun(RoleInfo) ->
				  Id = get_id_from_roleinfo(RoleInfo),
				  Name = get_name_from_roleinfo(RoleInfo),
				  {X, Y} = get_pos_from_roleinfo(RoleInfo),
				  #rl{roleid=Id, name=Name, x=X, y=Y, friendly=true}
		  end,
	Others = lists:map(Converter, OtherRoleInfo),
	login_pb:encode_other_role_map_init_s2c(#other_role_map_init_s2c{others=Others}).

encode_role_move_fail_s2c({X, Y}) ->
	Pos = #c{x=X, y=Y},
	login_pb:encode_role_move_fail_s2c(#role_move_fail_s2c{pos=Pos}).

encode_npc_init_s2c(NpcInfos) ->
	Converter = fun(NpcInfo) ->
					OtherLife = get_life_from_npcinfo(NpcInfo),
					OtherFullLife = get_hpmax_from_npcinfo(NpcInfo),
					OtherLevel = get_level_from_npcinfo(NpcInfo),
					NpcFlags = get_npcflags_from_npcinfo(NpcInfo),
					Movespeed = get_speed_from_npcinfo(NpcInfo),
					Touchred = get_touchred_from_npcinfo(NpcInfo),
					AttrS = [role_attr:to_role_attribute({hp, OtherLife}),
					 		role_attr:to_role_attribute({hpmax, OtherFullLife}),
					 		role_attr:to_role_attribute({level, OtherLevel}),
					 		role_attr:to_role_attribute({creature_flag, NpcFlags}),
					 		role_attr:to_role_attribute({movespeed, Movespeed}),
					 		role_attr:to_role_attribute({touchred, Touchred})
					 		],
				    Id = get_id_from_npcinfo(NpcInfo),
				    Name = get_name_from_npcinfo(NpcInfo),
				    {X, Y} = get_pos_from_npcinfo(NpcInfo),
				    #nl{npcid=Id, name=Name, x=X, y=Y, friendly=true,attrs=AttrS}
		    end,
	Npcs = lists:map(Converter, NpcInfos),
	login_pb:encode_npc_init_s2c(#npc_init_s2c{npcs=Npcs}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 攻击消息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
encode_be_attacked_s2c(AttackerId,Skill,Units,FlyTime) ->
	Converter = fun({_, CreatureId, DamageType, Damage, _,_SkillLevel}) ->
				    #b{ 
				      creatureid=CreatureId, 
				      damagetype=DamageType, 
				      damage=Damage}
		    end,
	BeAttackedUnits = lists:map(Converter, Units),
	login_pb:encode_be_attacked_s2c(#be_attacked_s2c{enemyid=AttackerId,skill=Skill,units=BeAttackedUnits,flytime = FlyTime}).

encode_be_killed_s2c(CreatureId, EnemyName,DeadType,{PosX,PosY},Series_Kills) ->
	login_pb:encode_be_killed_s2c(#be_killed_s2c{creatureid=CreatureId, murderer=EnemyName,deadtype = DeadType,posx = PosX,posy = PosY,series_kills = Series_Kills}).

encode_role_attack_s2c(Result, CasterId, SkillID, TargetId) ->
	login_pb:encode_role_attack_s2c(#role_attack_s2c{result=Result, enemyid=CasterId, skillid=SkillID, creatureid=TargetId}).

encode_role_attribute_s2c(RoleId, Attrs) ->
	login_pb:encode_role_attribute_s2c(#role_attribute_s2c{roleid=RoleId, attrs=Attrs}).

encode_npc_attribute_s2c(NpcId, Attrs) ->
	login_pb:encode_npc_attribute_s2c(#npc_attribute_s2c{npcid = NpcId,attrs=Attrs}).

encode_display_hotbar_s2c(EntryList) ->
	Fun = fun({Pos, ClassId ,EntryID}) ->
			      #hc{clsid=ClassId,
					      entryid=EntryID,					      
					      pos=Pos}
	      end,
	Things = lists:map(Fun, EntryList),
	login_pb:encode_display_hotbar_s2c(#display_hotbar_s2c{things=Things}).

encode_learned_skill_s2c(ID,SkillsRecord) ->
	login_pb:encode_learned_skill_s2c(#learned_skill_s2c{creatureid = ID,skills=SkillsRecord}).

encode_update_hotbar_fail_s2c() ->
	login_pb:encode_update_hotbar_fail_s2c(#update_hotbar_fail_s2c{}).
	
encode_role_cancel_attack_s2c(RoleID, Reason) ->
	login_pb:encode_role_cancel_attack_s2c(#role_cancel_attack_s2c{roleid=RoleID, reason=Reason}).

encode_add_buff_s2c(TargetID, Buffers) ->
	BuffersInfo = lists:map(fun({BuffId,BuffLevel,Lefttime})-> #bf{bufferid = BuffId, bufferlevel = BuffLevel, durationtime=Lefttime} end,Buffers),	
 	login_pb:encode_add_buff_s2c(#add_buff_s2c{targetid=TargetID,
 						   buffers=BuffersInfo}).
 						   
encode_del_buff_s2c(TargetId,BufferId)->
	login_pb:encode_del_buff_s2c(#del_buff_s2c{target=TargetId,buffid=BufferId}).

encode_buff_affect_attr_s2c(RoleID, Attributes) ->
	login_pb:encode_buff_affect_attr_s2c(#buff_affect_attr_s2c{roleid=RoleID, attrs=Attributes}).
	
encode_move_stop_s2c(ID,{X,Y})->
	login_pb:encode_move_stop_s2c(#move_stop_s2c{id=ID,x=X,y=Y}).
	
encode_loot_s2c(PacketId,NpcId,{PosX,PosY})->
	login_pb:encode_loot_s2c(#loot_s2c{packetid = PacketId,npcid = NpcId,posx = PosX,posy = PosY}).
	
encode_loot_release_s2c(PacketId)->
	login_pb:encode_loot_release_s2c(#loot_release_s2c{packetid = PacketId}).
	
encode_loot_remove_item_s2c(PacketId,SlotNum)->
	login_pb:encode_loot_remove_item_s2c(#loot_remove_item_s2c{packetid = PacketId,slot_num = SlotNum}).
	
encode_loot_response_s2c(PacketId,SlotsInfo)->
	login_pb:encode_loot_response_s2c(#loot_response_s2c{packetid = PacketId,slots = SlotsInfo}).
	
encode_add_item_s2c(ItemInfo)->
	login_pb:encode_add_item_s2c(#add_item_s2c{item_attr = pb_util:to_item_info(ItemInfo)}).
	
encode_add_item_failed_s2c(Errno)->
	login_pb:encode_add_item_failed_s2c(#add_item_failed_s2c{errno = Errno}).	
	
encode_delete_item_s2c(Itemid,Reason)->
	login_pb:encode_delete_item_s2c(#delete_item_s2c{itemid_low = get_lowid_from_itemid(Itemid),itemid_high = get_highid_from_itemid(Itemid),reason = Reason}).	

encode_update_item_s2c(ItemsChangedInfo)->
	login_pb:encode_update_item_s2c(#update_item_s2c{items = ItemsChangedInfo}).

encode_arrange_items_s2c(Type,ItemsChangedInfo,DeletesIds)->
	LowIds = lists:map(fun(ItemId)-> get_lowid_from_itemid(ItemId) end,DeletesIds),
	HighIds = lists:map(fun(ItemId)-> get_highid_from_itemid(ItemId) end,DeletesIds),
	login_pb:encode_arrange_items_s2c(#arrange_items_s2c{type = Type,items = ItemsChangedInfo,lowids = LowIds,highids = HighIds}).

encode_init_onhands_item_s2c(ItemInfos)->
	login_pb:encode_init_onhands_item_s2c(#init_onhands_item_s2c{
			item_attrs = lists:map(fun(ItemInfo)->
							pb_util:to_item_info(ItemInfo) 
						end	,ItemInfos)}).	
				
encode_player_level_up_s2c(RoleId,Attrs)->
	login_pb:encode_player_level_up_s2c(#player_level_up_s2c{roleid = RoleId,attrs = Attrs}).

encode_map_change_failed_s2c(ReasonId)->
	login_pb:encode_map_change_failed_s2c(#map_change_failed_s2c{reasonid = ReasonId}).
						
encode_npc_function_s2c(NpcId,Func,Quests,QuestsStates,Evers)->
%%	io:format("encode_npc_function_s2c ~p ~n",[{NpcId,Func,Quests,QuestsStates,Evers}]),
	login_pb:encode_npc_function_s2c(#npc_function_s2c{npcid = NpcId, values  = Func,quests = Quests,queststate = QuestsStates,everquests = Evers}).
	
encode_change_item_failed_s2c(ItemInfo,Errno)->
	login_pb:encode_change_item_failed_s2c(#change_item_failed_s2c{ itemid_low = get_lowid_from_iteminfo(ItemInfo),
									itemid_high = get_highid_from_iteminfo(ItemInfo),
									errno = Errno}).

encode_enum_shoping_item_s2c(NpcId) ->
	login_pb:encode_enum_shoping_item_s2c(#enum_shoping_item_s2c{npcid=NpcId,sps = []}).
	
encode_enum_skill_item_s2c(NpcId) ->
	login_pb:encode_enum_skill_item_s2c(#enum_skill_item_s2c{npcid=NpcId}).
	
	
encode_enum_shoping_item_fail_s2c(ErrorCode) ->	
	login_pb:encode_enum_shoping_item_fail_s2c(#enum_shoping_item_fail_s2c{reason=ErrorCode}).

encode_sell_item_fail_s2c(ErrorCode) ->
	login_pb:encode_sell_item_fail_s2c(#sell_item_fail_s2c{reason=ErrorCode}).	

%% 技能学习失败
encode_skill_learn_item_fail_s2c(ErrorCode) ->
	login_pb:encode_skill_learn_item_fail_s2c(#skill_learn_item_fail_s2c{reason=ErrorCode}).


%% 反馈消息成功
encode_feedback_info_ret_s2c(ErrorCode) ->
	login_pb:encode_feedback_info_ret_s2c(#feedback_info_ret_s2c{reason=ErrorCode}).

	 
encode_inspect_s2c(RoleInfo,ItemInfos,GuildInfo,SoulPowerInfo)->
	{GuildId,GuildName,GuildPost} = GuildInfo,
	case GuildId of
		{GLid,GHid}->
			nothing;
		_->
			GLid = 0,
			GHid = 0
	end,		
	{CurSp,MaxSp} = SoulPowerInfo,
	login_pb:encode_inspect_s2c(#inspect_s2c{
			roleid = get_id_from_roleinfo(RoleInfo),
			rolename = get_name_from_roleinfo(RoleInfo),
			gender = get_gender_from_roleinfo(RoleInfo),
			guildname = GuildName,
			classtype = get_class_from_roleinfo(RoleInfo),
			level = get_level_from_roleinfo(RoleInfo),
			cloth = get_cloth_from_roleinfo(RoleInfo),
			arm = get_arm_from_roleinfo(RoleInfo),
			maxhp = get_hpmax_from_roleinfo(RoleInfo),
			maxmp = get_mpmax_from_roleinfo(RoleInfo),
			power = get_power_from_roleinfo(RoleInfo),
			magic_defense = erlang:element(1,get_defenses_from_roleinfo(RoleInfo)),
			range_defense = erlang:element(2,get_defenses_from_roleinfo(RoleInfo)),
			melee_defense = erlang:element(3,get_defenses_from_roleinfo(RoleInfo)),
			stamina = get_stamina_from_roleinfo(RoleInfo),
			strength = get_strength_from_roleinfo(RoleInfo),
			intelligence = get_intelligence_from_roleinfo(RoleInfo),
			agile = get_agile_from_roleinfo(RoleInfo),
			hitrate = get_hitrate_from_roleinfo(RoleInfo),
			criticalrate = get_criticalrate_from_roleinfo(RoleInfo),
			criticaldamage = get_criticaldamage_from_roleinfo(RoleInfo),
			dodge = get_dodge_from_roleinfo(RoleInfo),
			toughness = get_toughness_from_roleinfo(RoleInfo),
			meleeimmunity = erlang:element(3,get_immunes_from_roleinfo(RoleInfo)),
			rangeimmunity = erlang:element(2,get_immunes_from_roleinfo(RoleInfo)),
			magicimmunity = erlang:element(1,get_immunes_from_roleinfo(RoleInfo)),
			imprisonment_resist = erlang:element(1,get_debuffimmunes_from_roleinfo(RoleInfo)),
			silence_resist = erlang:element(2,get_debuffimmunes_from_roleinfo(RoleInfo)),
			daze_resist = erlang:element(3,get_debuffimmunes_from_roleinfo(RoleInfo)),
			poison_resist = erlang:element(4,get_debuffimmunes_from_roleinfo(RoleInfo)),
			normal_resist = erlang:element(5,get_debuffimmunes_from_roleinfo(RoleInfo)),
			vip_tag = get_viptag_from_roleinfo(RoleInfo),
			items_attr = lists:map(fun(ItemInfo)->
							pb_util:to_item_info(ItemInfo) 
						end	, ItemInfos),
			guildpost = GuildPost,
			exp = get_exp_from_roleinfo(RoleInfo),
			levelupexp = get_levelupexp_from_roleinfo(RoleInfo),
			soulpower = CurSp,
			maxsoulpower = MaxSp,
			guildlid = GLid,
			guildhid = GHid,
			cur_designation = get_cur_designation_from_roleinfo(RoleInfo),
			role_crime = get_crime_from_roleinfo(RoleInfo),
			fighting_force = get_fighting_force_from_roleinfo(RoleInfo),
			curhp = get_life_from_roleinfo(RoleInfo),
			curmp = get_mana_from_roleinfo(RoleInfo)
		}).	
						
encode_inspect_pet_s2c(Myname,PetAllInfo,SlotInfo,Skills)->	
	login_pb:encode_inspect_pet_s2c(#inspect_pet_s2c{rolename = Myname,petattr = PetAllInfo,skillinfo = Skills,slot = SlotInfo}).					
					
encode_inspect_faild_s2c(Errno)->
	login_pb:encode_inspect_faild_s2c(#inspect_faild_s2c{errno = Errno}).
						
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%							组队相关
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
encode_group_apply_s2c(Roleid,RoleName) ->	
	login_pb:encode_group_apply_s2c(#group_apply_s2c{roleid = Roleid,username = RoleName}).

encode_aoi_role_group_s2c(Groups_role)->
	login_pb:encode_aoi_role_group_s2c(#aoi_role_group_s2c{groups_role = Groups_role}).

encode_group_invite_s2c(Roleid,RoleName) ->	
	login_pb:encode_group_invite_s2c(#group_invite_s2c{roleid = Roleid,username = RoleName}).

encode_group_decline_s2c(Roleid,RoleName) ->
	login_pb:encode_group_decline_s2c(#group_decline_s2c{roleid = Roleid,username = RoleName}).
	
encode_group_destroy_s2c()->
	login_pb:encode_group_destroy_s2c(#group_destroy_s2c{}).
	
encode_group_cmd_result_s2c(Roleid, Username, Reslut)->
	login_pb:encode_group_cmd_result_s2c(#group_cmd_result_s2c{roleid = Roleid, username = Username, reslut = Reslut}).

encode_group_member_stats_s2c(State)->
	login_pb:encode_group_member_stats_s2c(#group_member_stats_s2c{state = State}).

encode_group_list_update_s2c(Leaderid,Members)->
	login_pb:encode_group_list_update_s2c(#group_list_update_s2c{leaderid = Leaderid,members = Members}).
	
encode_recruite_query_s2c(InstanceId,Rec_infos,Role_rec_infos,JoinTimes,NeedAddTime,UsedTime_S)->
	login_pb:encode_recruite_query_s2c(#recruite_query_s2c{
											instance=InstanceId,
											rec_infos = Rec_infos,
											role_rec_infos = Role_rec_infos,
											usedtimes = JoinTimes,
											isaddtime = NeedAddTime,
											lefttime = UsedTime_S											
											}).

encode_recruite_cancel_s2c(Reason)->
	login_pb:encode_recruite_cancel_s2c(#recruite_cancel_s2c{reason = Reason}).
	
encode_role_recruite_cancel_s2c(Reason)->
	login_pb:encode_role_recruite_cancel_s2c(#role_recruite_cancel_s2c{reason = Reason}).
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				属性更新	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
encode_object_update_s2c(Create_attrs, Change_attrs, Deleteids)->
	login_pb:encode_object_update_s2c(
						#object_update_s2c{
						create_attrs = Create_attrs,
						change_attrs = Change_attrs,
						deleteids = Deleteids}).
						
encode_other_login_s2c()->
	login_pb:encode_other_login_s2c(#other_login_s2c{}).				
	
encode_block_s2c(Type,Time)->
	login_pb:encode_block_s2c(#block_s2c{type = Type,time = Time}).	

encode_is_jackaroo_s2c()->	
	login_pb:encode_is_jackaroo_s2c(#is_jackaroo_s2c{}).		
	
encode_update_skill_s2c(ID,SkillId,Level)->
	login_pb:encode_update_skill_s2c(#update_skill_s2c{creatureid = ID,skillid = SkillId,level = Level}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    游客模式
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	


%%挂机
encode_start_block_training_s2c(Roleid,Time)->
	login_pb:encode_start_block_training_s2c(#start_block_training_s2c{roleid = Roleid,lefttime = Time}).

encode_end_block_training_s2c(Roleid)->
	login_pb:encode_end_block_training_s2c(#end_block_training_s2c{roleid = Roleid}).
	
encode_query_time_s2c(Time)->
	login_pb:encode_query_time_s2c(#query_time_s2c{time_async = Time}).
	
make_item_by_playeritem(PlayerItemInfo)->	
	pb_util:to_item_info_by_playeritem(PlayerItemInfo).
		
encode_npc_storage_items_s2c(NpcId,StorageInfos)->
	login_pb:encode_npc_storage_items_s2c(#npc_storage_items_s2c{
			npcid = NpcId,
			item_attrs = lists:map(fun(PlayerItemInfo)->
							make_item_by_playeritem(PlayerItemInfo)	 
						end	,StorageInfos)}).
							
encode_hp_package_s2c(Itemid,BuffId)->	
	login_pb:encode_hp_package_s2c(#hp_package_s2c{itemidl = get_lowid_from_itemid(Itemid),itemidh = get_highid_from_itemid(Itemid),buffid = BuffId}).
encode_mp_package_s2c(Itemid,BuffId)->	
	login_pb:encode_mp_package_s2c(#mp_package_s2c{itemidl = get_lowid_from_itemid(Itemid),itemidh = get_highid_from_itemid(Itemid),buffid = BuffId}).

encode_instance_info_s2c(ProtoId,Times,Duration)->
	login_pb:encode_instance_info_s2c(#instance_info_s2c{protoid=ProtoId,times=Times,left_time = Duration}).
	
encode_get_instance_log_s2c(Ids,Times)->
	login_pb:encode_get_instance_log_s2c(#get_instance_log_s2c{instance_id = Ids,times = Times}).

encode_use_item_error_s2c(Errno)->
	login_pb:encode_use_item_error_s2c(#use_item_error_s2c{errno = Errno}).
	
encode_buff_immune_s2c(SelfId,Flytime,Immunebuffs)->
	ImmBuffs = lists:map(fun({Id,Buffs})-> [{{BuffId,BuffLevel},_}|_T]=Buffs,#mf{creatureid = Id,buffid = BuffId,bufflevel = BuffLevel} end,Immunebuffs),
	login_pb:encode_buff_immune_s2c(#buff_immune_s2c{enemyid = SelfId,flytime = Flytime,immune_buffs = ImmBuffs}).	

encode_treasure_buffer_s2c(BuffList)->
	BuffersInfo = lists:map(fun({BuffId,BuffLevel})-> #bf{bufferid = BuffId, bufferlevel = BuffLevel, durationtime=0} end,BuffList),
	login_pb:encode_treasure_buffer_s2c(#treasure_buffer_s2c{buffs = BuffersInfo}).	

encode_instance_end_seconds_s2c(Time_S)->
	login_pb:encode_instance_end_seconds_s2c(#instance_end_seconds_s2c{kicktime_s = Time_S}).
	
encode_rename_result_s2c(Result)->
	login_pb:encode_rename_result_s2c(#rename_result_s2c{errno = Result}).
	
encode_spiritspower_state_update_s2c(State,LeftTime,CurValue)->
	login_pb:encode_spiritspower_state_update_s2c(
					#spiritspower_state_update_s2c{state = State,lefttime = LeftTime,curvalue = CurValue}).


encode_money_from_monster_s2c(NpcId,NpcProto,Money)->
	login_pb:encode_money_from_monster_s2c(
	  				#money_from_monster_s2c{npcid = NpcId,npcproto = NpcProto,money = Money}).
	

encode_monster_section_update_s2c(MapId,Section)->
	login_pb:encode_monster_section_update_s2c(
	  				#monster_section_update_s2c{mapid = MapId,section = Section}).

