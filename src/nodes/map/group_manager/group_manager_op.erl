%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(group_manager_op).

%%
%% Include files
%%
-include("error_msg.hrl").
-compile(export_all).
-define(GROUP_CHECK_INTERVAL,1000*60).
-define(GROUP_OVERDUE_MICROSECONDS,1000*1000*60*1).

init()->
	put(deposit_group_list,[]),
	erlang:send_after(?GROUP_CHECK_INTERVAL,self(),over_due_check).

add_to_group_list(GroupId)->
	case lists:keymember(GroupId,1,get(deposit_group_list)) of
		false->
			put(deposit_group_list,[{GroupId,timer_center:get_correct_now()}|get(deposit_group_list)]);
		true->
			nothing
	end.

over_due_check()->
	delete_overdue_groups(),
	erlang:send_after(?GROUP_CHECK_INTERVAL,self(),over_due_check).
	
delete_overdue_groups()->
	NewGroupList = 
	lists:filter(fun({GroupId,LeaveTime})->
			case is_not_overdue(LeaveTime) of
				true->
					true;
				_->
					group_db:del_group(GroupId),
					false
			end		
		end, get(deposit_group_list)),
	put(deposit_group_list,NewGroupList).


is_not_overdue(LeaveTime)->
	timer:now_diff(timer_center:get_correct_now(),LeaveTime) < ?GROUP_OVERDUE_MICROSECONDS.

apply_deposit_group(GroupId)->
	add_to_group_list(GroupId),
	ok.
	
get_from_deposit_group(GroupId,RoleId)->
	case lists:keyfind(GroupId,1,get(deposit_group_list)) of
		{_GroupId,LeaveTime}->
			case is_not_overdue(LeaveTime) of
				true->
					case group_db:get_group_by_id(GroupId) of
						[]->
							[];
						GroupInfo->
							MembersInfo = group_db:get_group_members(GroupInfo),
							case lists:keymember(RoleId,1,MembersInfo) of
								true->
									NewGroupInfo = group_db:set_group_leaderid(GroupInfo,RoleId),
									group_db:write_group(NewGroupInfo),
									put(deposit_group_list,lists:keydelete(GroupId, 1, get(deposit_group_list))),
									NewGroupInfo;
								_->
									[]
							end
					end;
				_->
					[]
			end;
		_->
			[]
	end.