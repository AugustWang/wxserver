%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-8-29
%% Description: TODO: Add description to chat_interview
-module(chat_private).

%%
%% Exported Functions
%%
-export([process_message/1]).

-include("friend_struct_def.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("login_pb.hrl").
-include("error_msg.hrl").

process_message(#chat_private_c2s{roleid = OtherRoleId,serverid = SerId})->
	chat_private(OtherRoleId,SerId);

process_message({get_private_chat_info,OtherSerId,OtherRoleId})->
	handle_get_private_chat_info(OtherSerId,OtherRoleId).

chat_private(OtherRoleId,OtherSerId)->
	MySerId = get_serverid_from_roleinfo(get(creature_info)),
	case role_pos_util:where_is_role_by_serverid(OtherSerId, OtherRoleId) of
		[]->
			MessageErr = chat_packet:encode_chat_failed_s2c(?ERRNO_NOT_ONLINE),				 				
			role_op:send_data_to_gate(MessageErr);
		_->
			role_pos_util:send_to_role_by_serverid(OtherSerId, OtherRoleId, {chat_private,{get_private_chat_info,MySerId,get(roleid)}})
	end.
	
handle_get_private_chat_info(OtherSerId,OtherRoleId)->
	MySerId = get_serverid_from_roleinfo(get(creature_info)),
	RoleInfo = get(creature_info),
	Level = get(level),
	RoleId = get(roleid),
	RoleName = get_name_from_roleinfo(RoleInfo),
	RoleClass = role_op:get_class_from_roleinfo(RoleInfo),
	RoleGender = role_op:get_gender_from_roleinfo(RoleInfo),
	MyVipTag = get_viptag_from_roleinfo(get(creature_info)),
	case guild_util:get_guild_id() of
		0->
			MyGuildlId = 0,
			MyGuildhId = 0;
		{MyGuildlId,MyGuildhId}->
			nothing
	end,
	GuildName = guild_util:get_guild_name(),
	MySignature = friend_op:get_signature(),
	Message = chat_packet:encode_chat_private_s2c(RoleId,Level,RoleClass,RoleGender,MySignature,GuildName,MyGuildlId,MyGuildhId,MyVipTag,RoleName,MySerId),
	role_pos_util:send_to_role_clinet_by_serverid(OtherSerId,OtherRoleId, Message).
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	