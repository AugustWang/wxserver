%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-10-31
%% Description: TODO: Add description to country_op
-module(country_op).

%%
%% Include files
%%
-include("string_define.hrl").
-include("country_define.hrl").
-include("login_pb.hrl").
-include("error_msg.hrl").
-include("system_chat_define.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("guild_define.hrl").

%%
%% API Functions
%%
init()->
	{MyPost,BestGuildId} = country_manager:member_online({get(roleid)}),
	put(mycountrypost,MyPost),
	put(mycountrybestguildid,BestGuildId),
	update_my_icon(MyPost),
	if
		MyPost < ?POST_COMMON->
			MyName = get_name_from_roleinfo(get(creature_info)),
			OnLineMsg = country_packet:encode_country_leader_online_s2c(MyPost, 1, MyName),
			broadcast_to_all(OnLineMsg);
		true->
			nothing
	end,
	BestGuildCheck = guild_util:get_guild_id() =:= get_bestguild(),
	if
		BestGuildCheck->
			put(creature_info, set_guildtype_to_roleinfo( get(creature_info),?BEST_GUILD_TYPE)),		
			ChangeAttr= [{guildtype,?BEST_GUILD_TYPE}],
			role_op:self_update_and_broad(ChangeAttr);
		true->
			nothing
	end.

get_bestguild()->
	case get(mycountrybestguildid) of
		undefined->
			{0,0};
		GuildId->
			GuildId
	end.		

get_mypost()->
	get(mycountrypost).

reinit()->
	{MyPost,BestGuildId} = country_manager:member_online({get(roleid)}),
	put(mycountrypost,MyPost),
	case get_bestguild() =:= BestGuildId of
		true->
			nothing;
		_->
			put(mycountrybestguildid,BestGuildId),
			bestguild_change()		
	end,
	update_my_icon(MyPost).

export_for_copy()->
	{get(mycountrypost),get(mycountrybestguildid)}.

load_by_copy({CountryPost,CountryBestGuild})->
	put(mycountrypost,CountryPost),
	put(mycountrybestguildid,CountryBestGuild).

process_client_message(#country_init_c2s{})->
	country_manager:init_client_country(get(roleid));

process_client_message(#change_country_notice_c2s{notice = Notice})->
	case get(mycountrypost) of
		?POST_KING->
			case senswords:word_is_sensitive(Notice) of
				true->
					ErrorMsg = country_packet:encode_country_opt_s2c(?ERRNO_SENSWORDS),
					role_op:send_data_to_gate(ErrorMsg);
				_->
					country_manager:change_country_notice(get(roleid),Notice)
			end;
		_->
			nothing
	end;

%%
process_client_message(#change_country_transport_c2s{tp_start = TpStart})->
	todo;

%%
process_client_message(#country_leader_promotion_c2s{post = Post,postindex = PostIndex,name = Name})->
	MyPost = get(mycountrypost),
%%	io:format("country_leader_promotion_c2s ~p ~n",[{Post,PostIndex,Name,MyPost}]),
	try
	 if
		MyPost >= Post->
			nothing;
		true->
			case get_other_info(Name) of
				[]->
					case get_other_info_from_db(Name) of
						[]->
							{RoleId,RoleName,Class,Gender} = {0,[],0,0},
							ErrnoMsg = country_packet:encode_country_opt_s2c(?ERRNO_ROLE_NOT_EXIST),
							role_op:send_data_to_gate(ErrnoMsg),
							throw(role_not_exist);
						{RoleId,RoleName,Class,Gender}->
							nothing
					end;
				{RoleId,RoleName,Class,Gender}->
							nothing
			end,
			MyId = get(roleid),
			if
				RoleId =:= MyId->
					ErrnoMsg1 = country_packet:encode_country_opt_s2c(?ERRNO_SAME_ROLE),
					role_op:send_data_to_gate(ErrnoMsg1);
				true->
					case guild_util:is_same_guild(RoleId) of
						true->
							country_manager:country_leader_promotion(Post,PostIndex,{RoleId,RoleName,Class,Gender},MyId);
						_->
							ErrnoMsg2 = country_packet:encode_country_opt_s2c(?ERRNO_NOT_SAME_GUILD),
							role_op:send_data_to_gate(ErrnoMsg2)
					end
			end
	end
	catch
		E:R->slogger:msg("E ~p R ~p S ~p ~n",[E,R,erlang:get_stacktrace()])
	end;

%%
process_client_message(#country_leader_demotion_c2s{post = Post,postindex = PostIndex})->
	MyPost = get(mycountrypost),
	if
		MyPost >= Post->
			nothing;
		true->		
			country_manager:country_leader_demotion(Post,PostIndex,get(roleid))
	end;

%%
process_client_message(#country_block_talk_c2s{name = RoleName})->
	MyPost = get(mycountrypost),
	if
		MyPost < ?POST_COMMON->
			case role_pos_util:where_is_role(RoleName) of
				[]->	
					case get_other_info_from_db(RoleName) of
						[]->
							Errno = ?ERRNO_ROLE_NOT_EXIST;
						_->
							Errno = ?ERRNO_NOT_ONLINE
					end;
				RolePos->
					TargetRoleId = role_pos_db:get_role_id(RolePos),
					case get(roleid) of
						TargetRoleId->
							Errno = ?ERRNO_SAME_ROLE;
						MyId->
							case country_manager:check_country_leader_right(block_talk,get(roleid)) of
								ok->
									role_pos_util:send_to_role_by_pos(RolePos,{gm_block_talk,?BLOCK_TALK_TIME_S}),
									TargetRoleId = role_pos_db:get_role_id(RolePos),
									gm_block_db:add_user(TargetRoleId,talk,?BLOCK_TALK_TIME_S),
									
									LeaderStr = language:get_string(lists:nth(MyPost,?POST_STR)),
									NewLeaderStr = 	util:safe_binary_to_list(LeaderStr),
									ParamLeaderStr = system_chat_util:make_string_param(NewLeaderStr),
							
									ParamLeader =  system_chat_util:make_role_param(get(creature_info)),
									NewRoleName = util:safe_binary_to_list(RoleName),
									ParamTarget = chat_packet:makeparam(role,{NewRoleName,TargetRoleId,0}),
									MsgInfo = [ParamTarget,ParamLeaderStr,ParamLeader],
									system_chat_op:system_broadcast(?SYSTEM_CHAT_KING_BLOCKTALK,MsgInfo),
									gm_logger_role:country_leader_opt(get(roleid),MyPost,TargetRoleId,block_talk),
									Errno = [];
								Errno->
									nothing
							end
					end
			end,
			if
				Errno =:= []->
					nothing;
				true->
					ErrorMsg = country_packet:encode_country_opt_s2c(Errno),
					role_op:send_data_to_gate(ErrorMsg)
			end;
		true->
			nothing
	end;

%%
process_client_message(#country_change_crime_c2s{name = RoleName,type = Type})->
	MyPost = get(mycountrypost),
	if
		MyPost < ?POST_COMMON->
			case role_pos_util:where_is_role(RoleName) of
				[]->
					case get_other_info_from_db(RoleName) of
						[]->
							Errno = ?ERRNO_ROLE_NOT_EXIST;
						_->
							Errno = ?ERRNO_NOT_ONLINE
					end;
				RolePos->
					TargetRoleId = role_pos_db:get_role_id(RolePos),
					case get(roleid) of
						TargetRoleId->
							Errno = ?ERRNO_SAME_ROLE;
						MyId->
							if
								Type =:= ?LEADER_REMIT->
									ReqType = remit,
									OtherProcMsg = {country_proc_msg,{king_remit}},
									BrdId = ?SYSTEM_CHAT_KING_REMIT;
								true->
									ReqType = punish,
									OtherProcMsg = {country_proc_msg,{king_punish}},
									BrdId = ?SYSTEM_CHAT_KING_PUNISH
							end,
							case country_manager:check_country_leader_right(ReqType,get(roleid)) of
								ok->
									role_pos_util:send_to_role_by_pos(RolePos,OtherProcMsg),
									LeaderStr = language:get_string(lists:nth(MyPost,?POST_STR)),
									NewLeaderStr = 	util:safe_binary_to_list(LeaderStr),
									ParamLeaderStr = system_chat_util:make_string_param(NewLeaderStr),
									ParamLeader =  system_chat_util:make_role_param(get(creature_info)),
									NewRoleName = util:safe_binary_to_list(RoleName),
									ParamTarget = chat_packet:makeparam(role,{NewRoleName,TargetRoleId,0}),
									if
										Type =:= ?LEADER_REMIT->
											MsgInfo = [ParamLeaderStr,ParamLeader,ParamTarget];
										true->
											MsgInfo = [ParamTarget,ParamLeaderStr,ParamLeader]
									end,
									system_chat_op:system_broadcast(BrdId,MsgInfo),
									gm_logger_role:country_leader_opt(get(roleid),MyPost,TargetRoleId,ReqType),
									Errno = [];
								Errno->
									nothing
							end
					end
			end,
			if
				Errno =:= []->
					nothing;
				true->
					ErrorMsg = country_packet:encode_country_opt_s2c(Errno),
					role_op:send_data_to_gate(ErrorMsg)
			end;
		true->
			nothing
	end;

%%


process_client_message(#country_leader_ever_reward_c2s{})->
	MyPost = get(mycountrypost),
	try
	if
		MyPost >= ?POST_COMMON->
			nothing;
		true->
			case country_db:get_info(MyPost) of
				[]->
					nothing;
				MyPostProto->
					case country_db:get_reward(MyPostProto) of
						[]->
							nothing;
						RewardItems->
							%% check package
								CheckPackage = package_op:can_added_to_package_template_list(RewardItems),
								if
									not CheckPackage ->
										ErrorMsg = country_packet:encode_country_opt_s2c(?ERROR_PACKEGE_FULL),
										role_op:send_data_to_gate(ErrorMsg),
										throw(package_full);
									true->
										nothing
								end,
								case country_manager:get_leader_ever_reward(get(roleid)) of
									ok->
										lists:foreach(fun({ItemProtoId,Count}) -> 
													  role_op:auto_create_and_put(ItemProtoId,Count,get_leader_everitem)
											end,RewardItems);
									alreay_get->
									%%	io:format("~p ~n",[?ERRNO_ALREADY_GET_TODAY]),
										ErrorMsg1 = country_packet:encode_country_opt_s2c(?ERRNO_ALREADY_GET_TODAY),
										role_op:send_data_to_gate(ErrorMsg1);
									less_time-> 
									%%	io:format("~p ~n",[?ERRNO_COUNTRY_LEADER_LESS_TIME]),
										ErrorMsg1 = country_packet:encode_country_opt_s2c(?ERRNO_COUNTRY_LEADER_LESS_TIME),
										role_op:send_data_to_gate(ErrorMsg1);
									_->
									%%	io:format("~p ~n",[?ERRNO_NO_RIGHT]),
										ErrorMsg1 = country_packet:encode_country_opt_s2c(?ERRNO_NO_RIGHT),
										role_op:send_data_to_gate(ErrorMsg1)
								end							
					end
			end
	end
	catch
		E:R->slogger:msg("E ~p R ~p S ~p ~n",[E,R,erlang:get_stacktrace()])
  	end;

%%
process_client_message(UnKnownMsg)->
	nothing.

process_client_message_outdated(#country_leader_get_itmes_c2s{})->	
	MyPost = get(mycountrypost),
	try 
	if
		MyPost >= ?POST_COMMON->
			nothing;
		true->
			case country_db:get_info(MyPost) of
				[]->
					nothing;
				MyPostProto->
					MyLevel = get_level_from_roleinfo(get(creature_info)),
					case country_db:get_items_by_level(MyPostProto,MyLevel) of
						[]->
							nothing;
						Items->
							%% check package
								CheckPackage = package_op:can_added_to_package_template_list(Items),
								if
									not CheckPackage ->
										ErrorMsg = country_packet:encode_country_opt_s2c(?ERROR_PACKEGE_FULL),
										role_op:send_data_to_gate(ErrorMsg),
										throw(package_full);
									true->
										nothing
								end,
								CheckRight = country_manager:get_leader_items(get(roleid),MyLevel),
								if
									CheckRight =:= []->										
										ErrorMsg1 = country_packet:encode_country_opt_s2c(?ERRNO_NO_RIGHT),
										role_op:send_data_to_gate(ErrorMsg1),
										throw(no_right);
									true->
										nothing
								end,
								UsefulTimeH = country_db:get_items_useful_time_s(MyPostProto),
								TimeDiff = trunc(timer:now_diff(now(),CheckRight)/1000000),
								if
									TimeDiff < 0->
										ErrorMsg2 = country_packet:encode_country_opt_s2c(?ERRNO_TIME_NOT_ACHIEVE),
										role_op:send_data_to_gate(ErrorMsg2),
										throw(time_limit);
									true->
										nothing
								end,
								LeftTime = UsefulTimeH*60*60 - TimeDiff,
								if
									LeftTime =< 0->
										ErrorMsg3 = country_packet:encode_country_opt_s2c(?ERRNO_NO_RIGHT),
										role_op:send_data_to_gate(ErrorMsg3),
										throw(no_right);
									true->
										nothing
								end,
								lists:foreach(fun({ItemProtoId,Count}) -> 
													  case role_op:auto_create_and_put(ItemProtoId,Count,get_king_item) of
														  {ok,GetItemIds}->
															  	lists:foreach(fun(ItemId)->	
																			%% first set enchantment 
																			items_op:set_item_enchantment(ItemId, 9),
																			%% set overdue
														  					items_op:set_item_overdue(ItemId,LeftTime)	  
																			end,GetItemIds);														  		
															_->
																nothing
													  end
											end,Items)							
					end
			end
	end
	catch
		E:R->slogger:msg("E ~p R ~p S ~p ~n",[E,R,erlang:get_stacktrace()])
	end.

process_proc_message({country_post_change,Post})->
	OldPost = get(mycountrypost),
	put(mycountrypost,Post),
	update_my_icon(OldPost,Post);

process_proc_message({king_punish})->
	pvp_op:add_crime_by_value(?ADD_CRIME);

process_proc_message({king_remit})->
	pvp_op:clear_crime_by_value(?REDUCE_CRIME);

process_proc_message({bestguildchange,BestGuildId})->
	put(mycountrybestguildid,BestGuildId),
	bestguild_change();
	
process_proc_message(UnKnownMsg)->
	nothing.


hook_on_role_name_change(NewNameStr)->
	case get_mypost() of
		?POST_COMMON->
			[];
		_->
			country_manager:change_leader_name(get(roleid),NewNameStr),
			[]
	end.

%%
%% Local Functions
%%
%% return []| {RoleId,RoleName,Class,Gender}
get_other_info(_RoleName) when is_list(_RoleName)->
	RoleName = list_to_binary(_RoleName),
	get_other_info(RoleName);

get_other_info(RoleName) when is_binary(RoleName)->
	case role_pos_util:where_is_role(RoleName) of
		[]->									
			[];
		RolePos->
			RoleId = role_pos_db:get_role_id(RolePos),
			case creature_op:get_creature_info(RoleId) of
				undefined->
					[];
				RoleInfo ->	
					Class = get_class_from_roleinfo(RoleInfo),
					Gender = get_gender_from_roleinfo(RoleInfo),
					{RoleId,RoleName,Class,Gender}
			end
	end;

get_other_info(_Name)->
	[].

%%
%%return []| {RoleId,RoleName,Class,Gender}
%%
get_other_info_from_db(_RoleName) when is_list(_RoleName)->
	RoleName = list_to_binary(_RoleName),
	get_other_info_from_db(RoleName);

get_other_info_from_db(RoleName) when is_binary(RoleName)->
	case role_db:get_roleid_by_name_rpc(RoleName) of
		[]->
			[];
		[RoleId|_]->
			case role_db:get_role_info(RoleId) of
				[]->
					[];
				RoleAttrInfo->
				  Gender = role_db:get_sex(RoleAttrInfo),
				  Class = role_db:get_class(RoleAttrInfo),
				  {RoleId,RoleName,Class,Gender}
			end
	end;

get_other_info_from_db(_Name)->
	[].

update_my_icon(MyPost)->
	update_my_icon(?POST_COMMON,MyPost).

update_my_icon(OldPost,NewPost) when (OldPost =:= NewPost)->
	nothing;
update_my_icon(OldPost,NewPost)->
	if
		OldPost =:= ?POST_COMMON->
			nothing;
		true->
			DelIcon = lists:nth(OldPost,?POST_ICON_ID),
			role_game_rank:delete_role_icon(DelIcon)
	end,
	if
		NewPost =:= ?POST_COMMON->
			nothing;
		true->
			AddIcon = lists:nth(NewPost,?POST_ICON_ID),
			role_game_rank:add_role_icon(AddIcon)
	end.

broadcast_to_all(Message)->
	S = fun(RolePos)->
					GateProc = role_pos_db:get_role_gateproc(RolePos),
					tcp_client:send_data( GateProc, Message)
				end,
	role_pos_db:foreach(S).

bestguild_change()->
	BestGuildCheck = guild_util:get_guild_id() =:= get_bestguild(),
	if
		BestGuildCheck->
			put(creature_info, set_guildtype_to_roleinfo( get(creature_info),?BEST_GUILD_TYPE)),		
			ChangeAttr= [{guildtype,?BEST_GUILD_TYPE}];		
		true->
			put(creature_info, set_guildtype_to_roleinfo( get(creature_info),?NORMAL_GUILD_TYPE)),		
			ChangeAttr= [{guildtype,?NORMAL_GUILD_TYPE}]
	end,
	role_op:self_update_and_broad(ChangeAttr).
