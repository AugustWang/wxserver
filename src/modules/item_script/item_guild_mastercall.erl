%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(item_guild_mastercall).
-export([use_item/1]).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("guild_define.hrl").
-include("error_msg.hrl").
-include("map_info_struct.hrl").

use_item(_ItemInfo)->
	Posting = guild_util:get_guild_posting(),
	if
		(Posting =:=?GUILD_POSE_MASTER ) or (Posting =:= ?GUILD_POSE_LEADER) or (Posting =:= ?GUILD_POSE_VICE_LEADER)->
			Line = get_lineid_from_mapinfo(get(map_info)),
			if
				Line=<0 ->
					Msg = role_packet:encode_use_item_error_s2c(?ERROR_USED_IN_INSTANCE),
					role_op:send_data_to_gate(Msg),
					false;
				true->
					GuildId = guild_util:get_guild_id(),
					GuildPosting = guild_util:get_guild_posting(),
					MapId = get_mapid_from_mapinfo(get(map_info)),
					Pos = get_pos_from_roleinfo(get(creature_info)),
					RoleName = get_name_from_roleinfo(get(creature_info)),
					Message = {guild_mastercall,{GuildId,GuildPosting,RoleName,Line,MapId,Pos}},
					MembersWithoutMe = lists:delete(get(roleid),guild_util:get_guild_members()),
					lists:foreach(fun(Roleid)-> role_pos_util:send_to_role(Roleid,Message) end,MembersWithoutMe),
					role_op:send_data_to_gate(guild_packet:encode_guild_mastercall_success_s2c()),
					true
			end;
		true->
			Msg = role_packet:encode_use_item_error_s2c(?GUILD_ERRNO_LESS_AUTH),
			role_op:send_data_to_gate(Msg),
			false
	end.