%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(rename_op).


-export([proc_role_change_name/1,proc_guild_change_name/1]).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").

%% return : true/false
proc_role_change_name(NewNameStr)->
	RoleId = get(roleid),
	OldNameBin = get_name_from_roleinfo(get(creature_info)),
	OldNameStr = util:safe_binary_to_list(OldNameBin),
	NewNameBin = util:safe_list_to_binary(NewNameStr),
	case role_db:get_roleid_by_name_rpc(NewNameBin) of
		[]->
			case senswords:word_is_sensitive(NewNameBin) of
				false->
					put(creature_info, set_name_to_roleinfo(get(creature_info), NewNameBin )),
					role_op:update_role_info(RoleId ,get(creature_info)),
					role_op:self_update_and_broad([{name,NewNameStr}]),
					role_pos_util:update_role_pos_rolename(RoleId,NewNameBin),
					on_role_change_name_proc(RoleId,NewNameStr,NewNameBin),
					gm_logger_role:role_rename(RoleId,OldNameStr,NewNameStr,get(client_ip)),
					true;
				_->
					ReMsg = role_packet:encode_rename_result_s2c(?ERR_CODE_ROLENAME_INVALID),
					role_op:send_data_to_gate(ReMsg),
					false
			end;
		_->
			ReMsg = role_packet:encode_rename_result_s2c(?ERR_CODE_ROLENAME_EXISTED),
			role_op:send_data_to_gate(ReMsg),
			false
	end.

%% return : true/false
proc_guild_change_name(NewNameStr)->
	NewNameBin = util:safe_list_to_binary(NewNameStr),
	case senswords:word_is_sensitive(NewNameBin) of
		false->
			case guild_op:rename(NewNameStr) of
				true->
					gm_logger_guild:guild_rename(guild_util:get_guild_id(),NewNameStr),
					true;	
				_->
					false
			end;
		_->
			ReMsg = role_packet:encode_rename_result_s2c(?ERR_CODE_ROLENAME_INVALID),
			role_op:send_data_to_gate(ReMsg),
			false
	end.
	

on_role_change_name_proc(RoleId,NewNameStr,NewNameBin)->
	%%1.roleattr
	RoleInfoDB = role_db:get_role_info(RoleId),
	RoleInfoInDB1 = role_db:put_name(RoleInfoDB,NewNameBin),
	role_db:flush_role(RoleInfoInDB1),
	%%2.friend,
	friend_op:change_role_name(RoleId, NewNameBin),
	%%3.group
	group_op:hook_on_role_name_change(NewNameStr),
	%%4.game_rank
	role_game_rank:hook_on_role_name_change(NewNameStr),
	%%5.contry,
	country_op:hook_on_role_name_change(NewNameBin),
	%%guild
	guild_op:hook_on_role_name_change(NewNameBin),
	
	todo.
