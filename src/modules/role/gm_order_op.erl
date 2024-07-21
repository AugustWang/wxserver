%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(gm_order_op).
-export([power_gather/0,move_user_by_name/4,move_user/4,block_user/2,block_user_talk/2,kick_user/1,
		 kick_all/0,set_attr/3,block_ip/2,start_dps_stat/0,stop_dps_stat/0,change_role_name/2
		]).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").

power_gather()->
	F = fun(RolePos)->
			RoleNode = role_pos_db:get_role_mapnode(RolePos),
			RoleProc = role_pos_db:get_role_pid(RolePos),
			gs_rpc:cast(RoleNode,RoleProc,{power_gather})
		end,
		role_pos_db:foreach(F).


move_user_by_name(OtherName,MapId,PosX,PosY)->
	case role_db:get_roleid_by_name_rpc(OtherName) of
		[]->
			nothing;
		[UserId]->
			move_user(UserId,MapId,PosX,PosY)
	end.
		
move_user(UserId,MapId,PosX,PosY)->
	case role_pos_util:where_is_role(UserId) of
		[]->
			role_db:update_role_pos(UserId,MapId,{PosX,PosY});
		RolePos->
			role_pos_util:send_to_role_by_pos(RolePos,{gm_move_you,MapId,PosX,PosY})
	end.
  
block_user(UserId,Time_s)->
	case role_pos_util:where_is_role(UserId) of
		[]->
			nothing;
		RolePos->
			role_pos_util:send_to_role_by_pos(RolePos,{gm_kick_you})
	end,
	gm_block_db:add_user(UserId,login,Time_s).

block_user_talk(UserId,Time_s)->
	case role_pos_util:where_is_role(UserId) of
		[]->
			nothing;
		RolePos->
			role_pos_util:send_to_role_by_pos(RolePos,{gm_block_talk,Time_s})
	end,
	gm_block_db:add_user(UserId,talk,Time_s).

kick_user(UserId)->
	case role_pos_util:where_is_role(UserId) of
		[]->
			nothing;
		RolePos->
			role_pos_util:send_to_role_by_pos(RolePos,{gm_kick_you})
	end.
	
kick_all()->
	F = fun(RolePos)->
			role_pos_util:send_to_role_by_pos(RolePos,{gm_kick_you})
		end,
		role_pos_db:foreach(F).
	
set_attr(UserId,Attr,Value)->
	case role_pos_util:where_is_role(UserId) of
		[]->
			nothing;
		RolePos->
			role_pos_util:send_to_role_by_pos(RolePos,{gm_set_attr,{Attr,Value}})
	end.	
	
block_ip(IpAddress,Time_s)->
	gm_block_db:add_user(IpAddress,connect,Time_s).

start_dps_stat()->
	role_statistics:start_dps_st().

stop_dps_stat()->
	role_statistics:stop_dps_st().

change_role_name(RoleId,NewName) when is_binary(NewName)->
	case role_pos_util:where_is_role(RoleId) of
		[]->
			UsedNum = length(role_db:get_roleid_by_name_rpc(NewName)),
			if
				UsedNum > 0->
					{error,"beused"};
				true->
					RoleInfoDB = role_db:get_role_info(RoleId),
					OldName = role_db:get_name(RoleInfoDB),
					NewRoleInfoInDB = role_db:put_name(RoleInfoDB,NewName),
					role_db:flush_role(NewRoleInfoInDB),
					gm_logger_role:role_rename(RoleId,OldName,NewName,0),
					{ok}
			end;
		_->
			{error,"online"}
	end;

change_role_name(RoleId,NewName) when is_list(NewName)->
	change_role_name(RoleId,list_to_binary(NewName));

change_role_name(_RoleId,_NewName)->
	{error,"badarg"}.


	