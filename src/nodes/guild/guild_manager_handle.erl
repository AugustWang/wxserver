%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(guild_manager_handle).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("guild_define.hrl").

%%SomeInfo={level,lineid}
handle_member_online(Roleid,GuildId,SomeInfo)->
	guild_member_op:proc_member_online(Roleid,GuildId,SomeInfo).
	
%%create检测在role里
%handle_create(Roleid,GuildObject)->
%	guild_manager_op:proc_create(Roleid,GuildObject).	

%%xiaowujia
handle_create(Roleid,GuildObject,Notice,Create_Level)->
	guild_manager_op:proc_create(Roleid,GuildObject,Notice,Create_Level).	

%%被邀请来的,邀请前已有检测,proc_add_member里有满员检测	
handle_join_guild(Guildid,Roid)->
	GuildBattleCheck = guild_manager_op:is_in_guildbattle(Guildid),
	JszdBattleCheck = guild_manager_op:is_in_jszdbattle(Guildid),
	if
		GuildBattleCheck->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERRNO_IN_GUILDBATTLE),
			role_pos_util:send_to_role_clinet(Roid,ErrnoMsg);
		JszdBattleCheck->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERRNO_IN_GUILDBATTLE),
			role_pos_util:send_to_role_clinet(Roid,ErrnoMsg);
		true->		
			guild_member_op:proc_add_member(Guildid,Roid)
	end.

handle_set_leader(GuildId,LeaderId,Roleid)->
	case guild_manager_op:get_guild_info(GuildId) of
		[]->
			nothing;
		_GuildInfo->
			case guild_member_op:get_member_info(LeaderId) of
			[]->
				slogger:msg("set_leader leader is not exsit error!!! LeaderId ~p ~n",[LeaderId]);
			OldleaderInfo->
				case guild_member_op:get_by_member_item(posting,OldleaderInfo) =:= ?GUILD_POSE_LEADER of
					false->
						slogger:msg("set_leader is not leader error!!! OldleaderInfo ~p ~n",[OldleaderInfo]);
					_->						
						case guild_member_op:get_member_info(Roleid) of
							[]->
								slogger:msg("set_leader not has newleader error!!! Roleid ~p ~n",[Roleid]);
							NewleaderInfo->										
								Level = guild_member_op:get_by_member_item(level,NewleaderInfo),									
								FacilityInfo = guild_proto_db:get_facility_info(?GUILD_FACILITY,1),
								CheckList = guild_proto_db:get_facility_check_script(FacilityInfo),
								RolePosting = guild_member_op:get_by_member_item(posting,NewleaderInfo),
								{level,NeedLevel} = lists:keyfind(level,1,CheckList),
								CheckPosting = (RolePosting =/= ?GUILD_POSE_VICE_LEADER),		%%只有副帮主有资格继承帮主
								if 
									CheckPosting->
										nothing;
									Level < NeedLevel->			%%被禅让者验证等级	
										ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERROR_LESS_LEVEL),
										role_pos_util:send_to_role_clinet(LeaderId,ErrnoMsg);
									true->
										guild_member_op:proc_set_leader(GuildId,LeaderId,Roleid)	 																				 		
							 	end							 									 			
					 	end
				end
			end
	end.
	
%%由于是用户直接发起请求入会,再次之前无法得到帮会信息,所以要在此检测是否符合限制
handle_apply_guild(RoleId,GuildId)->
	GuildInfo = guild_manager_op:get_guild_info(GuildId),
	FacilityInfo = guild_facility_op:get_facility_info(GuildId,?GUILD_FACILITY),	
	{Role_Level,Role_Name,_Role_Class,_Gender,_,_,_,_} = guild_member_op:read_memberinfo_from_remote(RoleId),
	CheckGuildBattle = guild_manager_op:is_in_guildbattle(GuildId),
	CheckJszdBattle = guild_manager_op:is_in_jszdbattle(GuildId),
	if
		CheckGuildBattle ->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERRNO_IN_GUILDBATTLE),
			role_pos_util:send_to_role_clinet(RoleId,ErrnoMsg);
		CheckJszdBattle->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERRNO_IN_GUILDBATTLE),
			role_pos_util:send_to_role_clinet(RoleId,ErrnoMsg);
		(GuildInfo =/= []) and (FacilityInfo  =/= [])->
			if 			
				(Role_Level >= ?GUILD_MIN_LEVEL_JOIN)->					
					guild_apply_op:proc_add_applymember(GuildId,RoleId,Role_Level,Role_Name,_Role_Class,_Gender);
				true->
					ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERROR_LESS_LEVEL),
					role_pos_util:send_to_role_clinet(RoleId,ErrnoMsg),
					slogger:msg("proc_apply find hack GuildId not  restrict ! RoleId ~p GuildId ~p ~n",[RoleId,GuildId])					
			end;			
		true->
			slogger:msg("handle_apply_guild get_info error! RoleId ~p GuildId ~p ~n",[RoleId,GuildId])
	end.

handle_kick_out(GuildId,Roleid,KickRoleId)->
	GuildBattleCheck = guild_manager_op:is_in_guildbattle(GuildId),
	JszdBattleCheck = guild_manager_op:is_in_jszdbattle(GuildId),
	if
		GuildBattleCheck->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERRNO_IN_GUILDBATTLE),
			role_pos_util:send_to_role_clinet(Roleid,ErrnoMsg);
		JszdBattleCheck->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERRNO_IN_GUILDBATTLE),
			role_pos_util:send_to_role_clinet(Roleid,ErrnoMsg);
		true->
			case guild_impeach:check_in_impeach(GuildId,KickRoleId) of
				true->
						ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERRON_ROLE_IN_IMPEACH_CANNOT_LEAVE_GUILD),
						role_pos_util:send_to_role_clinet(Roleid,ErrnoMsg);
				_->
						GuildInfo = guild_manager_op:get_guild_info(GuildId),
						Members = guild_manager_op:get_by_guild_item(members,GuildInfo),
						case lists:member(Roleid,Members) and lists:member(KickRoleId,Members) of
							true->
								MemberInfo = guild_member_op:get_member_info(Roleid),
								KickMemberInfo = guild_member_op:get_member_info(KickRoleId),	
								MemberPosting = guild_member_op:get_by_member_item(posting,MemberInfo),
								KickMemberPosting= guild_member_op:get_by_member_item(posting,KickMemberInfo),	
								if 
									KickMemberPosting > MemberPosting ->				%%可以踢
										guild_member_op:proc_delete_member(?GUILD_DESTROY_BEKICKED,GuildId,KickRoleId);				
									true ->				%%职位不足
										slogger:msg("handle_kick_out find hack less posting RoleId ~p KickedRoleId ~p ~n",[Roleid,KickRoleId])
								end;							
							false->
								slogger:msg("handle_kick_out error:KickRoleId ~p Roleid ~p are not same guild~n",[KickRoleId,Roleid])
						end
			end
	end.
%%
%%升职
%%
handle_promotion(GuildId,Roleid,ProRoleid)->
	GuildInfo = guild_manager_op:get_guild_info(GuildId),
	Members = guild_manager_op:get_by_guild_item(members,GuildInfo),
	case lists:member(Roleid,Members) and lists:member(ProRoleid,Members) of
		true->
			MemberInfo = guild_member_op:get_member_info(Roleid),
			ProMemberInfo = guild_member_op:get_member_info(ProRoleid),	
			MemberPosting = guild_member_op:get_by_member_item(posting,MemberInfo),
			ProMemberPosting= guild_member_op:get_by_member_item(posting,ProMemberInfo),
			PostDiff = guild_util:post_diff(MemberPosting,ProMemberPosting),
			PrePost = guild_util:pre_post(ProMemberPosting),
			if 
				PostDiff < 2 ->			%%高两个职位才能提升职位
					Errno = ?GUILD_ERRNO_LESS_AUTH;
				true->			
					IsFull = guild_manager_op:is_posting_full(GuildId,PrePost),
					if
						not IsFull ->
							Errno = [],
							guild_member_op:proc_posting_change(promotion,GuildId,Roleid,ProRoleid);
						true->
							Errno = ?GUILD_ERRNO_GUILD_POST_FULL 
					end					
			end,
		if
			Errno =/= []->
				MessageError = guild_packet:encode_guild_opt_result_s2c(Errno),
				role_pos_util:send_to_role_clinet(Roleid,MessageError);
			true->
				nothing				
		end;						
		false->
			slogger:msg("handle_promotion error:ProRoleid ~p Roleid ~p are not same guild~n",[ProRoleid,Roleid])
	end.

%%
%%降职	
%%
handle_demotion(GuildId,Roleid,DeRoleid)->
	GuildInfo = guild_manager_op:get_guild_info(GuildId),
	Members = guild_manager_op:get_by_guild_item(members,GuildInfo),
	case lists:member(Roleid,Members) and lists:member(DeRoleid,Members) of
		true->
			MemberInfo = guild_member_op:get_member_info(Roleid),
			DeMemberInfo = guild_member_op:get_member_info(DeRoleid),	
			MemberPosting = guild_member_op:get_by_member_item(posting,MemberInfo),
			DeMemberPosting= guild_member_op:get_by_member_item(posting,DeMemberInfo),	
			PostDiff = guild_util:post_diff(MemberPosting,DeMemberPosting),	
			NextPost = guild_util:next_post(DeMemberPosting),	
			if 
				PostDiff < 1  ->							%%大个级别才能降级
					Errno = ?GUILD_ERRNO_LESS_AUTH;	
				NextPost =:= 0->		%%最小级别是帮众
					Errno = ?GUILD_ERRNO_LESS_AUTH;	
				true->			%%查看族长人数是否已满
					IsFull = guild_manager_op:is_posting_full(GuildId,NextPost),
					if
						not IsFull->
							Errno = [],
							guild_member_op:proc_posting_change(demotion,GuildId,Roleid,DeRoleid);
						true->
							Errno = ?GUILD_ERRNO_GUILD_POST_FULL 
					end						
			end,	
			if
				Errno =/= []->
					MessageError = guild_packet:encode_guild_opt_result_s2c(Errno),
					role_pos_util:send_to_role_clinet(Roleid,MessageError);
				true->
					nothing				
			end;
			false->
			slogger:msg("handle_demotion error:ProRoleid ~p Roleid ~p are not same guild~n",[DeRoleid,Roleid])
	end.	
	
%%检测在role进程里都已经完成	
handle_set_facility_rule(GuildId,RoleId,Facilityid,Requirevalue)->
	guild_facility_op:proc_facility_update(restrict,GuildId,Facilityid,Requirevalue),
	MemberInfo = guild_member_op:get_member_info(RoleId),		
	MemberPosting = guild_member_op:get_by_member_item(posting,MemberInfo),
	gm_logger_guild:guild_facility_required(GuildId,Facilityid,Requirevalue,RoleId,MemberPosting),
	gm_logger_guild:guild_facility_required(GuildId,Facilityid,Requirevalue,RoleId,MemberPosting).	
	
handle_set_notice(GuildId,RoleId,Notice)->
	guild_manager_op:proc_change_notice(GuildId,Notice),
	gm_logger_guild:guild_notice_change(GuildId,RoleId,Notice).	
	
handle_depart(GuildId,RoleId)->
	GuildBattleCheck = guild_manager_op:is_in_guildbattle(GuildId),
	JszdBattleCheck = guild_manager_op:is_in_jszdbattle(GuildId),
	if
		GuildBattleCheck->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERRNO_IN_GUILDBATTLE),
			role_pos_util:send_to_role_clinet(RoleId,ErrnoMsg);
		JszdBattleCheck->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERRNO_IN_GUILDBATTLE),
			role_pos_util:send_to_role_clinet(RoleId,ErrnoMsg);
		true->		
			guild_member_op:proc_delete_member(?GUILD_DESTROY_LEAVE,GuildId,RoleId)
	end.	
	
handle_upgrade(GuildId,RoleId,FacilityId)->
	FacilityInfo = guild_facility_op:get_facility_info(GuildId,FacilityId),
	GuildInfo = guild_manager_op:get_guild_info(GuildId),
	case (FacilityInfo =/=[]) and (GuildInfo =/= []) of
		false->
			slogger:msg("handle_upgrade GuildId ~p RoleId~p FacilityId ~p~n",[GuildId,RoleId,FacilityId]),
			error;
		_->
			GuildLevel = guild_manager_op:get_by_guild_item(level,GuildInfo),
			Level = guild_facility_op:get_by_facility_item(level,FacilityInfo),
			StartTime = guild_facility_op:get_by_facility_item(upgradetime,FacilityInfo ),
			if
				(StartTime =:= 0) and  ((FacilityId =:= ?GUILD_FACILITY) or (GuildLevel > Level))->  	
					guild_facility_op:proc_upgrade(GuildId,RoleId,FacilityId);
				true->
					slogger:msg("StartTime ~p FacilityId ~p GuildLevel~p Level~p~n",[StartTime,FacilityId,GuildLevel,Level]),										
					error
			end
	end.			
	
handle_upgrade_speedup(GuildId,RoleId,FacilityId,SpeedType,SpeedValue,ItemInfo)->
	FacilityInfo = guild_facility_op:get_facility_info(GuildId,FacilityId),
	case (FacilityInfo =/=[]) of
		false->
			slogger:msg("handle_upgrade_speedup GuildId ~p RoleId~p FacilityId ~p~n",[GuildId,RoleId,FacilityId]),
			error;
		_->			
			StartTime = guild_facility_op:get_by_facility_item(upgradetime,FacilityInfo ),
			if
				(StartTime =/= 0)->  	
					guild_facility_op:proc_upgrade_speedup(GuildId,RoleId,FacilityId,SpeedType,SpeedValue,ItemInfo);
				true->
					error
			end
	end.
		
handle_get_recruite_info(RoleId)->
	guild_manager_op:proc_get_recruite_info(RoleId).
			
handle_contribute(GuildId,RoleId,MoneyType,MoneyCount)->
	guild_manager_op:proc_contribute(GuildId,RoleId,MoneyType,MoneyCount).		
	
handle_add_contribute(GuildId,RoleId,Contribute)->
	guild_manager_op:proc_add_contribute(GuildId,RoleId,Contribute).		
	
handle_member_offline(RoleId,Guildid)->
	guild_member_op:proc_member_offline(RoleId,Guildid).	
					
handle_member_levelup(Roleid,GuildId,NewLevel)->
	guild_member_op:proc_member_levelup(Roleid,GuildId,NewLevel).

handle_member_change_fightforce(Roleid,GuildId,FightForce)->
	guild_member_op:proc_member_change_fightforce(Roleid,GuildId,FightForce).

handle_get_applicationinfo(Roleid,GuildId)->
	guild_apply_op:proc_get_applicationinfo(Roleid,GuildId).

handle_application_op(RoleId,LeaderId,GuildId,Reject)->
	guild_apply_op:proc_application_op(RoleId,LeaderId,GuildId,Reject).

handle_change_nickname(LeaderId,GuildId,RoleId,NickName)->
	guild_member_op:proc_change_nickname(LeaderId,GuildId,RoleId,NickName).

handle_change_chatandvoicegroup(LeaderId,GuildId,ChatGroup,VoiceGroup)->
	guild_manager_op:proc_change_chatandvoicegroup(LeaderId,GuildId,ChatGroup,VoiceGroup).

handle_get_guild_log(RoleId,GuildId,Type)->
	guild_manager_op:proc_get_guild_log(RoleId,GuildId,Type).

handle_guild_disband(RoleId,GuildId)->
	GuildBattleCheck = guild_manager_op:is_in_guildbattle(GuildId),
	JszdBattleCheck = guild_manager_op:is_in_jszdbattle(GuildId),
	if
		GuildBattleCheck->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERRNO_IN_GUILDBATTLE),
			role_pos_util:send_to_role_clinet(RoleId,ErrnoMsg),
			false;
		JszdBattleCheck->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?ERRNO_IN_GUILDBATTLE),
			role_pos_util:send_to_role_clinet(RoleId,ErrnoMsg),
			false;
		true->		
			guild_manager_op:proc_guild_disband(RoleId,GuildId),
			true
	end.

handle_guild_get_shop_item(RoleId,GuildId,ItemType)->
	if
		ItemType < 0->
			slogger:msg("GuildId ~p RoleId ~p guild_get_shop_item type ~p\n",[GuildId,RoleId,ItemType]),
			error;	
		true->
			guild_manager_op:proc_guild_get_shop_item(RoleId,GuildId,ItemType)
	end.

handle_guild_shop_buy_item(RoleId,GuildId,ItemType,Id,Count,RoleMoney)->
	if
		ItemType < 0->	
			slogger:msg("GuildId ~p RoleId ~p handle_guild_shop_buy_item type ~p\n",[GuildId,RoleId,ItemType]),
			error;	
		true->	
			guild_manager_op:proc_guild_shop_buy_item(RoleId,GuildId,ItemType,Id,Count,RoleMoney)
	end.


handle_guild_get_treasure_item(RoleId,GuildId,ItemType)->
	if
		ItemType < 0->
			slogger:msg("GuildId ~p RoleId ~p guild_get_treasure_item type ~p\n",[GuildId,RoleId,ItemType]),
			error;	
		true->
			guild_manager_op:proc_guild_get_treasure_item(RoleId,GuildId,ItemType)
	end.

handle_guild_treasure_buy_item(RoleId,GuildId,ItemType,Id,Count,RoleMoney)->
	if
		ItemType < 0->
			slogger:msg("GuildId ~p RoleId ~p handle_guild_treasure_buy_item type ~p\n",[GuildId,RoleId,ItemType]),
			error;	
		true->		
			guild_manager_op:proc_guild_treasure_buy_item(RoleId,GuildId,ItemType,Id,Count,RoleMoney)
	end.

handle_guild_treasure_set_price(RoleId,GuildId,ItemType,Id,Price)->	
	guild_manager_op:proc_guild_treasure_set_price(RoleId,GuildId,ItemType,Id,Price).

handle_publish_guild_quest(RoleId,GuildId)->
	nothing.
	%%guild_manager_op:proc_publish_guild_quest(RoleId,GuildId).

handle_can_get_premiums(GuildId)->
	guild_manager_op:can_get_premiums(GuildId).

handle_get_guild_notice(RoleId,GuildId)->
	guild_manager_op:proc_get_guild_notice(RoleId,GuildId).

handle_get_members_pos(RoleId,GuildId)->
	guild_member_op:proc_get_members_pos(RoleId,GuildId).

handle_clear_nickname(LeaderId,GuildId,RoleId)->
	guild_member_op:proc_clear_nickname(LeaderId,GuildId,RoleId).

handle_change_map(RoleId,GuildId,NewLine,NewMap)->
	guild_member_op:proc_member_change_map(RoleId,GuildId,NewLine,NewMap).
