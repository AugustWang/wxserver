%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(guild_handle).

-compile(export_all).


-include("login_pb.hrl").
-include("data_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("guild_define.hrl").
-include("item_define.hrl").
-include("map_info_struct.hrl").
-record(guilditems,{id,ownerguid,entry,enchantments,count,slot,bound,sockets,duration,cooldowninfo,enchant,overdueinfo,state}).
-record(playeritems,{id,ownerguid,entry,enchantments,count,slot,isbond,sockets,duration,cooldowninfo,enchant,overdueinfo}).%%将帮会物品转化为人物身上物品记录
handle_guild_create_c2s(Name,Notice,Type)->%%创建帮会10月18日修改[xiaowu]
	case guild_util:is_have_guild() of
		false->
			case Type of
				1 ->
					AllCheck = guild_facility:falility_required_check(?GUILD_FACILITY,1);
				_ ->
					AllCheck = guild_facility:falility_required_check(?GUILD_FACILITY,2)
			end;
		_->
			AllCheck = ?GUILD_ERRNO_ALREADY_IN_GUILD
	end,
	if
		AllCheck->
			guild_op:create(Name,Notice,Type);
		true->
			Msg = guild_packet:encode_guild_opt_result_s2c(AllCheck),
			role_op:send_data_to_gate(Msg)
	end.

handle_guild_disband_c2s()->
	HasGuild = guild_util:is_have_guild(),
	CheckAuth = (guild_util:get_guild_posting() =:= ?GUILD_POSE_LEADER),
	case (HasGuild and CheckAuth) of
		true->
			guild_op:guild_disband();
		_->
			slogger:msg("handle_guild_disband_c2s maybe hack ~p ~n",[get(roleid)])
	end.

handle_guild_set_leader_c2s(Roleid)->
	BaseCheck = guild_util:is_have_guild() and guild_util:is_same_guild(Roleid) ,
	case  BaseCheck of
		true->
			case guild_util:is_have_right(?GUILD_AUTH_SETLEADER) of
				true->
					Errno = [],
					guild_op:set_leader(Roleid);				
				false->
					Errno = ?GUILD_ERRNO_LESS_AUTH	
			end;					
		_->
			slogger:msg("handle_guild_set_leader_c2s maybe hack ~p ~n",[get(roleid)]),
			Errno = ?GUILD_ERRNO_NOT_IN_GUILD	
	end,
	if
		Errno =:= []->
			nothing;
		true->
			Msg = guild_packet:encode_guild_opt_result_s2c(Errno),
			role_op:send_data_to_gate(Msg)
	end.

%%
%%return left time
%%
check_leave_time_restrict(MyRoleId)->
	case guild_spawn_db:get_member_leave_info(MyRoleId ) of
		[]->					
			0;
		LastLeaveInfo->
			LastLeaveTime = guild_spawn_db:get_leave_time(LastLeaveInfo),
			LeftTime = max(?GUILD_JOIN_RESTICT_TIME - trunc(timer:now_diff(now(),LastLeaveTime)/1000000),0),
			LeftTime
	end.
			
handle_guild_member_apply_c2s(GuildId)->
	MyRoleId = get(roleid),
	BaseCheck = not guild_util:is_have_guild(),									
	case BaseCheck of
		true->
			LeftTime = check_leave_time_restrict(MyRoleId),			
			case LeftTime =< 0 of
				true ->										
					guild_apply:apply_guild(GuildId);
				false->				
					Msg = guild_packet:encode_guild_join_lefttime_s2c(LeftTime),
					role_op:send_data_to_gate(Msg)
			end;
		false->
			slogger:msg("handle_guild_set_leader_c2s maybe hack BaseCheck false ~p ~n",[MyRoleId])
	end.
	
handle_guild_member_invite_c2s(InviterName)->
	RoleId = get(roleid),
	case role_pos_util:where_is_role(InviterName) of
		[]->								
			Errno = ?GUILD_ERRNO_CANNOT_FIND_ROLE;
		RolePos->
			InviterId = role_pos_db:get_role_id(RolePos),
			IsCheckin =  (RoleId =/= InviterId),		
			case IsCheckin of
				true ->
					HasGuild = guild_util:is_have_guild(),
					IsFull = guild_util:is_full(),					
					HasRight = guild_util:is_have_right(?GUILD_AUTH_INVITE),
					if
						not HasGuild ->
							Errno = ?GUILD_ERRNO_NOT_IN_GUILD ;
						IsFull ->
							Errno = ?GUILD_ERRNO_GUILD_FULL;
						not HasRight->
							Errno = ?GUILD_ERRNO_LESS_AUTH;																	
						true->
							Errno =[]
					end;
				false ->
					slogger:msg("handle_guild_member_invite_c2s IsCheckin error~n"),
					Errno = ?GUILD_ERRNO_UNKNOWN 
			end,
			if
				Errno =:= []->
					RemoteRoleInfo = make_roleinfo_for_othernode(get(creature_info)),
					role_pos_util:send_to_role_by_pos(RolePos,{guildmanager_msg,{guild_invite_you,{RemoteRoleInfo,guild_util:get_guild_id(),guild_util:get_guild_name()}}});
				true -> 
					nothing
			end
	end,
	if 
		Errno =/= []->
			Msg = guild_packet:encode_guild_opt_result_s2c(Errno),
			role_op:send_data_to_gate(Msg);
		true -> 
			nothing
	end.
	
handle_guild_member_decline_c2s(Inviterid)->
	HasbeenInvite = guild_apply:has_been_inveited_by(Inviterid),
	MyName = get_name_from_roleinfo(get(creature_info)),
	if
		HasbeenInvite ->
			guild_apply:remove_from_inviter(Inviterid),
			Message= guild_packet:encode_guild_member_decline_s2c(MyName),
			role_pos_util:send_to_role_clinet(Inviterid,Message);
		true->
			slogger:msg("handle_guild_member_decline_c2s maybe hack! has not be invited by ~p RoleId: ~n ",[Inviterid,get(roleid)])
	end.
		
handle_guild_member_accept_c2s(Inviterid)->
	HasbeenInvite = guild_apply:has_been_inveited_by(Inviterid),
	if
		HasbeenInvite ->
			GuildId = guild_apply:get_inviter_guild(Inviterid),
			guild_apply:remove_from_inviter(Inviterid),
			LeftTime = check_leave_time_restrict(get(roleid)),
			case LeftTime =< 0 of
				true ->										
					guild_op:join_guild(GuildId);
				false->
					Msg = guild_packet:encode_guild_join_lefttime_s2c(LeftTime),
					role_op:send_data_to_gate(Msg)
			end;
		true->
			slogger:msg("handle_guild_member_accept_c2s maybe hack! has not be invited by ~p RoleId: ~p~n ",[Inviterid,get(roleid)])
	end.
	
handle_guild_member_kickout_c2s(KickRoleId)->
	slogger:msg("handle_guild_member_kickout_c2s ~p~n",[KickRoleId]),
	Myid = get(roleid),
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_KICKOUT),
	IsSameGuild = guild_util:is_same_guild(KickRoleId), 
	BaseCheck = (KickRoleId =/= Myid) and HasGuild and HasRight and  IsSameGuild ,  	
	if
		not BaseCheck ->			
			slogger:msg("handle_guild_member_kickout_c2s maybe hack!BaseCheck ~p Roleid ~p KickRoleId ~p~n ",[BaseCheck,Myid,KickRoleId]);
		true->														
			guild_op:kick_out(KickRoleId)
	end.								
	
	
handle_guild_member_promotion_c2s(RoleId)->
	Myid = get(roleid),
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_PROMOTION),
	IsSameGuild = guild_util:is_same_guild(RoleId),
	BaseCheck = (RoleId =/= Myid) and HasGuild and HasRight and  IsSameGuild ,
	if
		not BaseCheck ->			
			slogger:msg("handle_guild_member_promotion_c2s maybe hack!BaseCheck ~p Myid ~p Roleid ~p~n ",[BaseCheck,Myid,RoleId]);
		true->														
			guild_op:promotion(RoleId)
	end.	
	
handle_guild_member_demotion_c2s(RoleId)->
	Myid = get(roleid),
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_DEMOTION),
	IsSameGuild = guild_util:is_same_guild(RoleId),
	BaseCheck = (RoleId =/= Myid) and HasGuild and HasRight and  IsSameGuild ,  	
	if
		not BaseCheck ->			
			slogger:msg("handle_guild_member_demotion_c2s maybe hack!BaseCheck ~p Roleid ~p~n ",[BaseCheck,Myid]);
		true->														
			guild_op:demotion(RoleId)
	end.
%%1月28日写【小五】
handle_get_guild_space_info_c2s()->
	RoleId = get(roleid),
	Message = guild_packet:encode_get_guild_space_info_s2c(),
	role_pos_util:send_to_role_clinet(RoleId,Message).

handle_open_guild_space_c2s(Spaceid)->
	RoleId = get(roleid),
	Message = guild_packet:encode_get_space_info_s2c(Spaceid),
	role_pos_util:send_to_role_clinet(RoleId,Message).
	
handle_guild_facilities_accede_rules_c2s(Facilityid,Requirevalue)->
	Myid = get(roleid),
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_ACCEDE_RULE),
	BaseCheck = HasGuild and HasRight,	
	if
		not BaseCheck ->			
			slogger:msg("handle_guild_facilities_accede_rules_c2s maybe hack!BaseCheck ~p Roleid ~p~n ",[BaseCheck,Myid]);
		true->
			Required = guild_facility:get_guild_facility_required(Facilityid),
			if 
				(Required =/=  Requirevalue) and (Required  =/= [])->
					guild_facility:set_facility_rule(Facilityid,Requirevalue);
				true->
					nothing
			end
	end.	
	
handle_guild_notice_modify_c2s(Notice)->
	Myid = get(roleid),
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_NOTICE_MODIFY),
	LengthCheck = erlang:length(Notice) < ?GUILD_NOTICE_LENGTH,
	BaseCheck = HasGuild and HasRight and LengthCheck,	
	if
		not BaseCheck->			
			slogger:msg("handle_guild_notice_modify_c2s maybe hack!BaseCheck ~p Roleid ~p~n ",[BaseCheck,Myid]);
		true->
			guild_op:set_notice(Notice)	
	end	.

handle_guild_member_depart_c2s()->
	Myid = get(roleid),
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_LEAVE),
	BaseCheck = HasGuild and HasRight,
	if
		not BaseCheck->			
			slogger:msg("handle_guild_member_depart_c2s maybe hack!BaseCheck ~p Roleid ~p~n ",[BaseCheck,Myid]);
		true->
			guild_op:depart()	
	end.	
	
handle_guild_log_normal_c2s(Type)->
	HasGuild = guild_util:is_have_guild(),
	if
		HasGuild->
			guild_util:get_guild_log(Type);
		true->
			nothing
	end.

handle_guild_log_event_c2s()->
	todo.
	
handle_guild_facilities_upgrade_c2s(Facilitieid)->
	Myid = get(roleid),
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_UPGRADE),
	BaseCheck = HasGuild and HasRight,
	if
		not BaseCheck->			
			slogger:msg("handle_guild_facilities_upgrade_c2s maybe hack!BaseCheck ~p Roleid ~p~n ",[BaseCheck,Myid]);
		true->			
			case guild_util:get_guild_facility_info(Facilitieid) of
				[] ->
					slogger:msg("handle_guild_facilities_upgrade_c2s error facilityid ~p ~n",[Facilitieid]);										
				{Facilitieid,FaLevel,_,LeftTime,_,_}->
					GuildLevel = guild_util:get_guild_level(),
					if 
						(LeftTime =/= 0)->					
							Errno = ?GUILD_ERRNO_GUILD_UPGRADING;
						(Facilitieid =/= ?GUILD_FACILITY) and (FaLevel >= GuildLevel)->
							Errno = ?GUILD_ERRNO_CANNOT_BIGGER_THEN_GUILD;
						true->
							Errno  = true,
							guild_facility:upgrade(Facilitieid)						
					end,
					if
						Errno =/= true->
							Msg = guild_packet:encode_guild_opt_result_s2c(Errno),
							role_op:send_data_to_gate(Msg);
						true->
							nothing
					end					
			end	
	end.	
	
handle_guild_facilities_speed_up_c2s(Facilitieid,SlotNum)->
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_UPGRADE_SPEEDUP),
	case package_op:get_iteminfo_in_package_slot(SlotNum) of
		[]->
			nothing;
		ItemsInfo->	
			FacilityInfo = guild_util:get_guild_facility_info(Facilitieid),
			if 
				(ItemsInfo =/= []) and (FacilityInfo =/= [])->
					ItemId = get_id_from_iteminfo(ItemsInfo),
					ItemType = get_class_from_iteminfo(ItemsInfo),
					{Facilitieid,_FaLevel,_,LeftTime,_,_} = FacilityInfo,
					BaseCheck = HasGuild and HasRight and (LeftTime =/= 0) and( ItemType =:= ?ITEM_TYPE_GUILD_SPEEDUP),																	
					if
						not BaseCheck->
							nothing;			
						true->
							guild_facility:upgrade_speedup(Facilitieid,ItemId)	
					end;	
				true->
					nothing	
			end
	end.	
	
handle_guild_rewards_c2s()->
	todo.

handle_guild_recruite_info_c2s()->
	Now = now(),
	case get(last_recruite_info) of
		undefined->
			put(last_recruite_info,Now),
			guild_util:get_recruite_info();
		LastTime->
			case timer:now_diff(Now,LastTime) > ?GUILD_RECRUITE_TIME of
				true->
					put(last_recruite_info,Now),
					guild_util:get_recruite_info();
				false->
					nothing
			end
	end.	

handle_guild_member_contribute_c2s(MoneyType,MoneyCount)->
	Myid = get(roleid),
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_CONTRIBUTION),
	EnoughMoney = script_op:has_money(MoneyType,MoneyCount),
	BaseCheck = ((MoneyType =:= ?MONEY_BOUND_SILVER)or(MoneyType=:=?MONEY_GOLD)) and (MoneyCount>0) and HasGuild and HasRight and EnoughMoney,
	if
		not BaseCheck->			
			slogger:msg("handle_guild_member_contribute_c2s maybe hack!BaseCheck ~p Roleid ~p MoneyCount ~p~n ",[BaseCheck,Myid,MoneyCount]);
		true->		
			guild_op:contribute(MoneyType,MoneyCount)		
	end	.

handle_guild_invite_you(RemoteInviterInfo,GuildId,GuildName)->
	InviterId = get_id_from_othernode_roleinfo(RemoteInviterInfo),
	InviterName = get_name_from_othernode_roleinfo(RemoteInviterInfo),	
	HasGuild = guild_util:is_have_guild(),	
	HasbeenInvite = guild_apply:has_been_inveited_by(InviterId),
	CheckLevel = ( get(level) >= ?GUILD_MIN_LEVEL_JOIN ),
	if   
		HasbeenInvite ->
			Errno = ?GUILD_ERRNO_HAS_BEEN_INVITED;
		HasGuild ->
			Errno = ?GUILD_ERRNO_ALREADY_IN_GUILD;
		not CheckLevel->
			Errno = ?GUILD_INVITE_ERROR_LESS_LEVEL;
		true ->
			Errno = []
	end,
		
	if
		Errno =/= [] ->
			Message = guild_packet:encode_guild_opt_result_s2c(Errno),			
			role_pos_util:send_to_role_clinet(InviterId,Message);			
		true ->
			guild_apply:insert_to_inviter(InviterId,GuildId),
			Message = guild_packet:encode_guild_member_invite_s2c(InviterId,InviterName,GuildId,GuildName),			
			role_op:send_data_to_gate(Message)
	end.
		
handle_update_guild_info(FullInfo)->
	guild_op:update_guild_info(FullInfo).
	
handle_update_guild_base_info(BaseInfo)->	
	guild_op:update_guild_base_info(BaseInfo).
		
handle_update_facility_info(Facilityid,FaciltiyInfo)->
	guild_facility:update_facility_info(Facilityid,FaciltiyInfo).
	
handle_add_member(NewComerId)->
	guild_op:add_member(NewComerId).		
	
handle_delete_member(KickId)->
	guild_op:delele_member(KickId).	
	
handle_guild_destroy()->
	guild_op:destroy().

handle_guild_get_application()->
	HasGuild = guild_util:is_have_guild(),				
	HasRight = guild_util:is_have_right(?GUILD_AUTH_CHECKAPPLY),
	case (HasGuild and HasRight) of
		true->
			case get(last_apply_info_time) of
				undefined->
					put(last_apply_info_time,now()),
					guild_apply:get_application();
				LastTime->
					case timer:now_diff(now(),LastTime) > ?GUILD_APPLYINFO_TIME of
						true->					
							guild_apply:get_application();
						false->
							slogger:msg("handle_guild_get_application too frequent maybe hack! Roleid ~p~n ",[get(roleid)])
					end
			end;
		_->
			slogger:msg("handle_guild_get_application maybe hack! Roleid ~p~n ",[get(roleid)])
	end.
	
handle_guild_application_op(RoleId,Reject)->
	HasGuild = guild_util:is_have_guild(),				
	HasRight = guild_util:is_have_right(?GUILD_AUTH_CHECKAPPLY),
	case (HasGuild and HasRight) of
		true->
			guild_apply:application_op(RoleId,Reject);
		_->
			slogger:msg("handle_guild_application_op maybe hack! Roleid ~p~n ",[get(roleid)])
	end.


handle_guild_change_nickname(RoleId,NickName)->
	HasGuild = guild_util:is_have_guild(),				
	HasRight = guild_util:is_have_right(?GUILD_AUTH_CHANGE_NICKNAME),
	CheckNickNameLen = (length(NickName) =< ?GUILD_NICKNAME_LENGTH),
	case (HasGuild and HasRight and CheckNickNameLen) of
		true->
			guild_op:change_nickname(RoleId,NickName);
		_->
			slogger:msg("handle_guild_change_nickname maybe hack! Roleid ~p~n ",[get(roleid)])
	end.

handle_guild_change_chatandvoicegroup(ChatGroup,VoiceGroup)->
	HasGuild = guild_util:is_have_guild(),				
	HasRight = guild_util:is_have_right(?GUILD_AUTH_NOTICE_MODIFY),
	CheckLen = (length(ChatGroup) =< 50) and (length(VoiceGroup) =< 50),		
	case (HasGuild and HasRight and CheckLen) of
		true->
			guild_op:change_chatandvoicegroup(ChatGroup,VoiceGroup);
		_->
			slogger:msg("handle_guild_change_chatandvoicegroup maybe hack! Roleid ~p~n ",[get(roleid)])
	end.

handle_guild_get_treasure_item(ShopType)->
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_TREASURE_USE),
	case (HasGuild and HasRight) of
		true->
			guild_treasure_item:guild_get_treasure_item(ShopType);
		_->
			slogger:msg("handle_guild_get_treasure_item maybe hack! Roleid ~p~n ",[get(roleid)])
	end.	

handle_guild_treasure_buy_item(ShopType,Id,ItemId,Count)->
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_TREASURE_USE),
	CheckCount = (Count > 0),
	case (HasGuild and HasRight and CheckCount) of
		true->
			guild_treasure_item:guild_treasure_buy_item(ShopType,Id,ItemId,Count);
		_->
			slogger:msg("handle_guild_treasure_buy_item maybe hack! Roleid ~p~n ",[get(roleid)])
	end.

handle_guild_treasure_set_price(ShopType,Id,Price,ItemId)->
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_SETPRICE),
	CheckPrice = (Price >= 0),
	case (HasGuild and HasRight and CheckPrice) of
		true->
			guild_treasure_item:guild_treasure_set_price(ShopType,Id,Price,ItemId);
		_->
			slogger:msg("handle_guild_treasure_set_price maybe hack! Roleid ~p~n ",[get(roleid)])
	end.			
	
handle_publish_guild_quest()->
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_PUBLISHQUEST),	
	case (HasGuild and HasRight) of
		true->
			guild_quest:guild_publish_guild_quest();
		_->
			slogger:msg("handle_publish_guild_quest maybe hack! Roleid ~p~n ",[get(roleid)])
	end.			
		
handle_get_guild_notice(GuildId)->
	guild_op:get_guild_notice(GuildId).	
	
handle_guild_mastercall(CallsInfo)->
	guild_op:guild_mastercall(CallsInfo).
	
handle_mastercall_accept_c2s()->
	guild_op:mastercall_accept().	
	
handle_guild_treasure_transport()->
	HasGuild = guild_util:is_have_guild(),
	HasRight = guild_util:is_have_right(?GUILD_AUTH_TREASURE_TRANSPORT),
	GuildId = guild_util:get_guild_id(),
	case HasGuild of
		true->
			case HasRight of
				true->
					guild_manager:start_guild_treasure_transport(get(roleid),GuildId);
				false->
					Message = treasure_transport_packet:encode_start_guild_transport_failed_s2c(?ERRNO_NO_RIGHT_TO_START_TREASURE_TRANSPORT),
					role_op:send_data_to_gate(Message)
			end;
		false->
			Message = treasure_transport_packet:encode_start_guild_transport_failed_s2c(?GUILD_ERRNO_NOT_IN_GUILD),
			role_op:send_data_to_gate(Message)
	end.
	
handle_treasure_transport_call_guild_help()->
	HasGuild = guild_util:is_have_guild(),
	case HasGuild of
		true->
			RoleInfo = get(creature_info),
			GuildPosting = guild_util:get_guild_posting(),
			MapId = get_mapid_from_mapinfo(get(map_info)),
			LineId = get_lineid_from_mapinfo(get(map_info)),
			RoleName = get_name_from_roleinfo(RoleInfo),
			RolePos = get_pos_from_roleinfo(RoleInfo),
			guild_manager:treasure_transport_call_guild_help(guild_util:get_guild_id(),get(roleid),GuildPosting,RoleName,LineId,MapId,RolePos);
		false->
			Result = ?GUILD_ERRNO_NOT_IN_GUILD,
			Message = treasure_transport_packet:encode_treasure_transport_call_guild_help_result_s2c(Result),
			role_op:send_data_to_gate(Message)
	end.
		
handle_guild_contribute_log_c2s()->
	HasGuild = guild_util:is_have_guild(),
	case HasGuild of
		true->
			Now = now(),
			case get(last_contribute_info) of
				undefined->
					put(last_contribute_info,Now),
					guild_manager:get_guild_contribute_log(guild_util:get_guild_id(),get(roleid));
				LastTime->
					case timer:now_diff(Now,LastTime) > ?GUILD_MONEYLOG_TIME of
						true->	
							put(last_contribute_info,Now),
							guild_manager:get_guild_contribute_log(guild_util:get_guild_id(),get(roleid));
						false->
							nothing
					end
			end;
		false->
			nothing
	end.

handle_guild_impeach_c2s(Notice)->
	HasGuild = guild_util:is_have_guild(),
	case HasGuild of
		true->
			case senswords:word_is_sensitive(Notice) of
				true-> 
					error;
				_-> 
					%%check item 
					case item_util:is_has_enough_item_in_package_by_class(?ITEM_TYPE_GUILD_IMPEACH,1) of
						true->
							case guild_manager:add_impeach(guild_util:get_guild_id(),get(roleid),Notice) of
								true->
									item_util:consume_items_by_classid(?ITEM_TYPE_GUILD_IMPEACH,1);
								_->
									nothing
							end;
						_->
							nothing
					end
			end;
		false->
			nothing
	end.
		
handle_guild_impeach_info_c2s()->
	HasGuild = guild_util:is_have_guild(),
	case HasGuild of
		true->
			guild_manager:get_impeach_info(guild_util:get_guild_id(),get(roleid));
		false->
			nothing
	end.

handle_guild_impeach_vote_c2s(Type)->
	HasGuild = guild_util:is_have_guild(),
	case HasGuild of
		true->
			guild_manager:impeach_vote(guild_util:get_guild_id(),get(roleid),Type);
		false->
			nothing
	end.

gm_change_impeach_time(Time_S)->
	HasGuild = guild_util:is_have_guild(),
	case HasGuild of
		true->
			guild_manager:gm_change_impeach_time(guild_util:get_guild_id(),Time_S);
		false->
			nothing
	end.

gm_change_someone_offline(NewOffline,RoleId)->
	case guild_util:is_same_guild(RoleId) of
		true->
			guild_manager:gm_change_someone_offline(guild_util:get_guild_id(),NewOffline,RoleId);
		_->
			nothing
	end.
handle_reset_guild_package_flag(Num)->
	guild_op:set_guild_storage_flag(Num).
handle_guild_package_init_s2c()->
	GuildId=guild_util:get_guild_id(),
	case guild_spawn_db:get_guildinfo(GuildId) of
		[]->
				ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
			   role_op:send_data_to_gate(ErrnoMsg);
		GuildInfo->
			Flag=guild_op:get_guild_storage_flag(),
			if Flag =:=1->
				   nothing;
			   true->
					guild_manager:init_guild_package(GuildInfo,get(roleid)),
					guild_op:set_guild_storage_flag(1)
			end
	end.

handle_guild_package_storage(Slot,Count)->
	case package_op:get_iteminfo_in_package_slot(Slot) of
		[]->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
		ItemInfo->
			AllCount=get_count_from_iteminfo(ItemInfo),
			IsBound=get_isbonded_from_iteminfo(ItemInfo),
			if (AllCount>=Count) and (IsBound=:=0)->
					guild_manager:item_to_guild_package(ItemInfo,Count,get(roleid));
			true->
				nothing
			end
end.
handle_guild_storage_take_out_c2s(Slot,ItemId,Count)->
	GuildId=guild_util:get_guild_id(),
	if GuildId=:=0 ->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
		true->
			Position=guild_util:get_guild_posting(),
			if (Position=:=?GUILD_POSE_LEADER) or (Position=:=?GUILD_POSE_VICE_LEADER)->
				  guild_manager:take_out_item_from_guild_package(Slot,ItemId,Count,GuildId,get(roleid));
			   true->
				     ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_LESS_AUTH),
		  			role_op:send_data_to_gate(ErrnoMsg)
			end
	end.
%%帮会申请物品GUILD_ERRNO_NOT_IN_GUILD
handle_guild_storage_apply_item(Count,ItemId,Slot)->
	GuildId=guild_util:get_guild_id(),
	if GuildId=:=0->
		  ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
	   true->
		   guild_manager:guild_package_item_apply(get(roleid), GuildId, Count, ItemId, Slot)
	end.

handle_guild_storage_apply_init()->
	GuildId=guild_util:get_guild_id(),
	if GuildId=:=0->
		   ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
	   true->
		  guild_manager:guild_storage_apply_init(GuildId,get(roleid))
	end.

handle_guild_storage_approve_apply(RoleId,ItemId)->
	GuildId=guild_util:get_guild_id(),
	if GuildId=:=0->
		      ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
	   true->
		   Position=guild_util:get_guild_posting(),
		   if(Position=:=?GUILD_POSE_LEADER) or (Position=:=?GUILD_POSE_VICE_LEADER)->
				guild_manager:guild_storage_approve_apply(RoleId,ItemId,GuildId,get(roleid));
			 true->
				   ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_LESS_AUTH),
		  		role_op:send_data_to_gate(ErrnoMsg)
			 end
end.
%%拒绝申请
handle_guild_storage_refuse_apply(RoleId,ItemId)->
	GuildId=guild_util:get_guild_id(),
	if GuildId=:=0->
		      ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
	   true->
		   Position=guild_util:get_guild_posting(),
		   if(Position=:=?GUILD_POSE_LEADER) or (Position=:=?GUILD_POSE_VICE_LEADER)->
				guild_manager:guild_storage_refuse_apply(RoleId,ItemId,GuildId);
			 true->
				   ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_LESS_AUTH),
		  		role_op:send_data_to_gate(ErrnoMsg)
			 end
end.

handle_guild_storage_refuse_all_apply()->
	GuildId=guild_util:get_guild_id(),
	if GuildId=:=0->
		      ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
	   true->
		   Position=guild_util:get_guild_posting(),
		   if(Position=:=?GUILD_POSE_LEADER) or (Position=:=?GUILD_POSE_VICE_LEADER)->
				guild_manager:guild_storage_refuse_all_apply(GuildId);
			 true->
				   ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_LESS_AUTH),
		  		role_op:send_data_to_gate(ErrnoMsg)
			 end
end.

handle_guild_storage_distribute_item(ItemId,Count,ToRoleid,Slot)->
		GuildId=guild_util:get_guild_id(),
	if GuildId=:=0->
		      ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
	   true->
		   Position=guild_util:get_guild_posting(),
		   if(Position=:=?GUILD_POSE_LEADER) or (Position=:=?GUILD_POSE_VICE_LEADER)->
				guild_manager:guild_storage_distribute_item(ItemId,Count,ToRoleid,Slot,GuildId,get(roleid));
			 true->
				   ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_LESS_AUTH),
		  		role_op:send_data_to_gate(ErrnoMsg)
			 end
end.

handle_storage_self_apply()->
			GuildId=guild_util:get_guild_id(),
	if GuildId=:=0->
		      ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
	   true->
				guild_manager:guild_storage_self_apply(GuildId,get(roleid))
	end.

handle_storage_cancel_apply(ItemId)->
	GuildId=guild_util:get_guild_id(),
	if GuildId=:=0->
		      ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
	   true->
				guild_manager:guild_storage_cancel_apply(GuildId,get(roleid),ItemId)
	end.

%%帮会仓库权限设置，因为涉及比较简单，所以就直接在map节点上完成
handle_guild_storage_set_state(#oprate_state{state=State,type=Type})->
	GuildId=guild_util:get_guild_id(),
	if GuildId=:=0->
		      ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
	   true->
		   Position=guild_util:get_guild_posting(),
		   if(Position=:=?GUILD_POSE_LEADER) or (Position=:=?GUILD_POSE_VICE_LEADER)->
				guild_package_op:guild_storage_set_state(Type,State,GuildId,get(roleid));
			 true->
				   ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_LESS_AUTH),
		  		role_op:send_data_to_gate(ErrnoMsg)
			 end
end.

handle_guild_storage_set_item_state(State,ItemId)->
	GuildId=guild_util:get_guild_id(),
	if GuildId=:=0->
		      ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
	   true->
		   Position=guild_util:get_guild_posting(),
		   if(Position=:=?GUILD_POSE_LEADER) or (Position=:=?GUILD_POSE_VICE_LEADER)->
				guild_manager:guild_storage_set_item_state(ItemId,State,GuildId);
			 true->
				   ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_LESS_AUTH),
		  		role_op:send_data_to_gate(ErrnoMsg)
			 end
end.
%%帮会仓库整理
handle_guild_storage_sort_items()->
		GuildId=guild_util:get_guild_id(),
	if GuildId=:=0->
		      ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_GUILD_FULL),
		  role_op:send_data_to_gate(ErrnoMsg);
	   true->
		   Position=guild_util:get_guild_posting(),
		   if(Position=:=?GUILD_POSE_LEADER) or (Position=:=?GUILD_POSE_VICE_LEADER)->
				guild_manager:guild_storage_sort_items(GuildId);
			 true->
				   ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_LESS_AUTH),
		  		role_op:send_data_to_gate(ErrnoMsg)
			 end
end.
	
	

handle_guild_storage_log()->
	guild_manager:get_guild_storage_log(get(roleid)).

make_guilditem_info(ItemId,Protoid,Enchantments,Count,State,Isbonded,Socket,Duration,Coordown,Enchant,Lefttime_s,NewSlot,GuildId)->
	maket_guilditem_info(ItemId,Protoid,Enchantments,Count,NewSlot,Isbonded,Socket,Duration,Coordown,Enchant,Lefttime_s,GuildId,State).

maket_guilditem_info(Id,Entry,Enchantments,Count,Slot,Isbond,Sockets,Duration,Coordown,Enchant,Overdueinfo,GuildId,State)->
#guilditems{
					id=Id,
				 ownerguid=GuildId,
				 entry=Entry,
				 enchantments=Enchantments,
				 count=Count,
				 slot=Slot,
				 bound=Isbond,
				 sockets=Sockets,
				 duration=Duration,
				cooldowninfo=Coordown,
				 enchant=Enchant,
				 overdueinfo=Overdueinfo,
				state=State
		   }.

make_guilditem_s2c(GuildItemInfo,Count)->
		ItemAttr=#i{
		itemid_low = guild_proto_db:get_item_low_id_from_guilditem(GuildItemInfo),
	   itemid_high = guild_proto_db:get_item_high_id_from_guilditem(GuildItemInfo),
	   protoid = guild_proto_db:get_item_proto_id_from_guilditem(GuildItemInfo),
	   enchantments = guild_proto_db:get_enchantments_from_guilditem(GuildItemInfo),
	   count = guild_proto_db:get_item_count_from_guilditem(GuildItemInfo),
	   slot = guild_proto_db:get_item_slot_from_guilditem(GuildItemInfo),
	   isbonded = guild_proto_db:get_item_bound_from_guilditem(GuildItemInfo),
	   socketsinfo = lists:map(fun({_Slot,Stone})->Stone end,guild_proto_db:get_item_sockets_from_guilditem(GuildItemInfo)),
	   duration = guild_proto_db:get_item_duration_from_guilditem(GuildItemInfo),
	   enchant = role_attr:to_item_attribute({enchant,guild_proto_db:get_item_enchant_from_guilditem(GuildItemInfo)}),
	   lefttime_s = items_op:get_left_time_by_overdueinfo(guild_proto_db:get_item_overdueinfo_from_guilditem(GuildItemInfo))
			},
	#gi{idle_state=Count,
		idel=guild_proto_db:get_item_state_from_guildinfo(GuildItemInfo),
		item_attrs=ItemAttr}.

make_playeritems_to_role(GuildtemInfo,RoleId,Count)->
	PlayItem=#playeritems{
			id=guild_proto_db:get_item_id_from_guilditem(GuildtemInfo),
			ownerguid=RoleId,
			entry=guild_proto_db:get_item_proto_id_from_guilditem(GuildtemInfo),
			enchantments=guild_proto_db:get_enchantments_from_guilditem(GuildtemInfo),
			count=Count,
			slot=guild_proto_db:get_item_slot_from_guilditem(GuildtemInfo),
			isbond=guild_proto_db:get_item_bound_from_guilditem(GuildtemInfo),
			sockets=guild_proto_db:get_item_sockets_from_guilditem(GuildtemInfo),
			duration=guild_proto_db:get_item_duration_from_guilditem(GuildtemInfo),
			cooldowninfo=guild_proto_db:get_item_coordowninfo_from_guildiinfo(GuildtemInfo),
			enchant=guild_proto_db:get_item_enchant_from_guilditem(GuildtemInfo),
			overdueinfo=guild_proto_db:get_item_overdueinfo_from_guilditem(GuildtemInfo)
			}.


		
		
		
		
		
		 	
	
	
	
	