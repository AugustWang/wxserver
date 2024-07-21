%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(group_op).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%组队结构group_info:{groupid,leaderid,recruit,[{roleid,name,Info}]}TODO:把node节点信息存入,在上线下线时更新
%%被邀请列表invite_info:[{inviteId,Timer}],一定时间后删除,如果被主动清除,则取消此timer,Info = {level...}
%%队长的副本邀请 leader_instance_invite {InstanceProtoId,MapPos,InviteTime}
%%个人招募 role_recruitments_tag,标志是否申请了个人招募.true/false
%%组队信息里的info,是存库供招募信息用,如果是同节点,会及时填入,如果是远距离的,要等update_state的时候放入,只更新一次,所以,
%%招募信息里的队员如等级之类的具体信息,是不及时消息Info:{Isonline:1/0,Level,Class,Gender}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load_from_db(GroupID)->
	put(invite_info,[]),
	put(group_info,{0,0,0,[]}),
	put(leader_instance_invite,[]),
	put(role_recruitments_tag,false),
	if
		GroupID=:=0->
			GroupInfo = [];
		true->
			case group_manager:get_from_deposit_group(GroupID,get(roleid)) of
				[]->
					
					GroupInfo = group_db:get_group_by_id(GroupID);
				GroupInfo->			%%被托管的组队
					nothing
			end
	end,
	if
		GroupInfo =/= []->
			LeaderId = group_db:get_group_leaderid(GroupInfo),
			MembersInfo = group_db:get_group_members(GroupInfo),
			case lists:keyfind(get(roleid),1,MembersInfo) of
				false->			%%下线的时候被踢出队伍
					nothing;
				_->			
					Rec = group_db:get_group_isrecruite(GroupInfo),
					set_group_info({GroupID,LeaderId,Rec,MembersInfo})
			end;
		true->					%%下线的时候已解散
			nothing
	end.			
	
export_for_copy()->
	clear_timer(),
	{get(group_info),get(invite_info),get(leader_instance_invite),get(role_recruitments_tag)}.

load_by_copy({Group_info,Invite_info,LeaderInvite,Role_recruitments_tag})->
	put(group_info,Group_info),
	put(invite_info,Invite_info),
	put(leader_instance_invite,LeaderInvite),
	put(role_recruitments_tag,Role_recruitments_tag),
	init_invite_timer(),
	case has_group() of
		true ->
			set_update_timer();
		false ->
			nothing
	end.

group_id_changed(GroupId)->
	put(creature_info,set_group_id_to_roleinfo(get(creature_info),GroupId)),
	role_op:update_role_info(get(roleid),get(creature_info)).


%%进入队伍前会被预设Groupid
has_group()->
	{GroupId,_,_,_} = get(group_info),
	GroupId =/= 0.

has_group_truely()->
	case  get(group_info) of
		{_,0,0,[]}->
			false;
		_->
			true
	end.	 

is_group_recuitment()->
	{_,_,Rec,_} =  get(group_info),
	Rec =/= 0.

is_full()->
	get_member_count() >= ?MAX_GROUP_SIZE.

is_empty_exceptself()->
	get_member_count() =< 1.	
	
has_member(RoleId)->
	lists:member(RoleId,get_member_id_list()).
	
		
create()->	
	Roleid = get(roleid),
	Name = get_name_from_roleinfo(get(creature_info)),
	GroupId = {Roleid,timer_center:get_correct_now()},
	LeaderId = Roleid,
	Info = {1,get_level_from_roleinfo(get(creature_info)),get_class_from_roleinfo(get(creature_info)),get_gender_from_roleinfo(get(creature_info))},
	put(group_info,{GroupId,LeaderId,0,[{Roleid,Name,Info}]}),
	group_id_changed(GroupId),
	set_update_timer(),
	hook_to_delete_role_recruitment(?ERRNO_ROLE_UNRECRUITMENT_CREATE),
	save_to_db().

disband()->
	GroupId = get_id(),
	delete_from_db(),
	send_to_all({group_destroy,GroupId}),
%%	group_destroy(),
	instance_op:on_group_disband(GroupId).
	
clear_group_info()->	
	put(group_info,{0,0,0,[]}),
	put(leader_instance_invite,[]),
	group_id_changed(0).	
	
group_destroy()->
	GroupId = get_id(),
	clear_group_info(),
	%%此步可能会导致转换地图,换进程.
	instance_op:on_group_destroy(GroupId),
	loop_instance_op:hook_leave_group(),
	clear_timer(),
	Message = role_packet:encode_group_destroy_s2c(),
	role_op:send_data_to_gate(Message).

get_id()->
	{GroupId,_,_,_} = get(group_info),
	GroupId.
	
%%更新timer操作
set_update_timer()->
	case get(group_timer) of
		undefined->
			nothing;
		TimerOld->
			erlang:cancel_timer(TimerOld)
	end,
	Timer = erlang:send_after(?GROUP_UPDATE_TIME,self(),{group_update_timer}),
	put(group_timer,Timer).
	
clear_timer()->
	Timer = get(group_timer),
	case  Timer of
		undefined ->
			nothing;
		_ ->
			erlang:cancel_timer(Timer)
	end.	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%add/remove invite
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_invite_timer()->
	InviteInfo = lists:map( fun({InviteId,_})->  
					Timer = erlang:send_after(?INVITE_DELETE_TIME,self(),{delete_invite,InviteId}),
					{InviteId,Timer}
			end,get(invite_info)),
	put(invite_info,InviteInfo).
	
insert_to_inviteinfo(Roleid)->
	case has_been_inveited_by(Roleid) of
		false ->
			Timer = erlang:send_after(?INVITE_DELETE_TIME,self(),{delete_invite,Roleid}),
			put(invite_info, lists:append(get(invite_info),[{Roleid,Timer}]));
		true->
			nothing
	end.	

remove_from_inviteinfo(Roleid)->
	NowList = get(invite_info),
	case lists:keyfind(Roleid,1,NowList) of
		false ->
			nothing;
		{Roleid,Timer}->	
			put(invite_info, lists:keydelete(Roleid,1,NowList)),
			erlang:cancel_timer(Timer)
	end.
		
remove_from_inviteinfo_timeout(Roleid)->
	NowList = get(invite_info),
	case lists:keyfind(Roleid,1,NowList) of
		false ->
			slogger:msg("remove_from_inviteinfo_timeout error lists:keyfind false~n");
		{Roleid,_}->	
			put(invite_info, lists:keydelete(Roleid,1,NowList))
	end.

has_been_inveited_by(RoleId)->
	case lists:keyfind(RoleId,1,get(invite_info)) of
		false -> false;
		_ -> true
	end.	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%base op
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
regist_member_info(RoleId,GetInfo)->
	{TeamId,LeaderId,Rec,MemberList} = get(group_info),
	case lists:keyfind(RoleId,1,MemberList) of
		{RoleId,OriRoleName,_}->
			case GetInfo of
				{RealName,Info}->
					nothing;
				Info->
					RealName = OriRoleName
			end,	
			set_group_info({TeamId,LeaderId,Rec,lists:keyreplace(RoleId,1,MemberList,{RoleId,RealName,Info})} ),
			update_group_list_info_without_self();
		false->
			slogger:msg("regist_member_info error lists:keyfind false~n")
	end,
	save_to_db().					%%注册信息存库,供招募查询
	
get_members_info()->
	{_,_,_,MemberList} = get(group_info),
	MemberList.

get_member_info(Roleid)->
	{_,_,_,MemberList} = get(group_info),
	case lists:keyfind(Roleid,1,MemberList) of
		{Roleid,_,Info}->
			Info;
		_ ->[]
	end.
	
set_member_online(online,Roleid)->
	{TeamId,LeaderId,Rec,MemberList} = get(group_info),
	case lists:keyfind(Roleid,1,MemberList) of
		{Roleid,RoleName,{_,Level,Class,Gender}}->
			put(group_info,{TeamId,LeaderId,Rec,lists:keyreplace(Roleid,1,MemberList,{Roleid,RoleName,{1,Level,Class,Gender}})} );
		false->
			slogger:msg("regist_member_info error lists:keyfind false~n")
	end;

set_member_online(offline,Roleid)->	
	{TeamId,LeaderId,Rec,MemberList} = get(group_info),
	case lists:keyfind(Roleid,1,MemberList) of
		{Roleid,RoleName,{_,Level,Class,Gender}}->
			put(group_info,{TeamId,LeaderId,Rec,lists:keyreplace(Roleid,1,MemberList,{Roleid,RoleName,{0,Level,Class,Gender}})} );
		false->
			slogger:msg("regist_member_info error lists:keyfind false~n")
	end.		

get_member_count()->
	erlang:length(get_member_id_list()).

get_member_id_list()->
	{_,_,_,MemberList} = get(group_info),
	lists:map(fun({ID,_,_})-> ID end,MemberList).

%%队长下线或者离队之前,选出下一任队长{InviterId, Inviternode,InviterPid}/[]
%%如果为[],则disband此队伍
hook_on_offline()->
	hook_to_delete_role_recruitment(),
	case is_leader() of
		true->
			case auto_set_leader_by_sys() of
				true->
					nothing;
				false->
					deposit_group();
				_->
					disband()
			end;
		false->
			nothing
	end.

%%下线托管当前组队
deposit_group()->
	set_to_unrecruitment(),
	case group_manager:apply_deposit_group(get_id()) of
		error->
			disband();
		_->
			nothing
	end.	

%%return true:设置成功/false:已无人在线/error:设置失败
auto_set_leader_by_sys()->
	Selfid = get(roleid),
	AllOtherRolePos = 
	lists:foldl(fun(RoleId,Result)->
				if
					RoleId =:= Selfid -> Result;
					true->
						case role_pos_util:where_is_role(RoleId) of
							[]->
								Result;
							RolePos ->
								[RolePos|Result]
						end
				end end,[],get_member_id_list()),
	if
		AllOtherRolePos=:=[]->
			false;
		true->			
			lists:foldl(fun(RolePos,Result)->
				if
					Result=:=true->
						true;
					true->	
						RoleNode = role_pos_db:get_role_mapnode(RolePos),
						RolePid = role_pos_db:get_role_pid(RolePos),
						RoleId = role_pos_db:get_role_id(RolePos),
						case set_leader({RoleId,RoleNode,RolePid}) of
							error->
								error;
							_->
								true
						end	
				end  
			end,error,AllOtherRolePos)
	end.	
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%add/remove member
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
add_member(RemoteInfo)->
	RoleId = get_id_from_othernode_roleinfo(RemoteInfo),
	Node = get_node_from_othernode_roleinfo(RemoteInfo),
	RoleProc = get_proc_from_othernode_roleinfo(RemoteInfo),
	{Groupid,Leaderid,OriRec,MemberList} = get(group_info),
	SetRe = role_processor:set_group_to_you(Node,RoleProc,Groupid),
	case (has_member(RoleId) or is_full() or  (not SetRe) ) of 
		false ->						
			%%此时队友信息是未知的
			Name = get_name_from_othernode_roleinfo(RemoteInfo),
			Info = {1,get_level_from_othernode_roleinfo(RemoteInfo),get_class_from_othernode_roleinfo(RemoteInfo),get_gender_from_othernode_roleinfo(RemoteInfo)},
			if
				(OriRec=:=1)->
					case erlang:length(MemberList)+1 >= ?MAX_GROUP_SIZE of
						true->
							NewRec = 0,
							notify_unrecruitment_reason(?ERR_GROUP_UNRECRUITMENT_FULL);
						_->
							NewRec = OriRec
					end;
				true->	
					NewRec = OriRec
			end,										
			%%给所有人更新队伍信息
			set_group_info({Groupid,Leaderid,NewRec,lists:append(MemberList,[{RoleId,Name,Info}])}),
			update_group_list_info_without_self();
		true->
			slogger:msg("add_member error has_member:~p,is_full:~p!!!!!~n",[has_member(RoleId),is_full()])
	end.

remove_member(RemoveId)->
	case has_member(RemoveId) of 
		true ->
			{Groupid,Leaderid,Rec,MemberList} = get(group_info),
			case RemoveId =:= Leaderid of
				true ->						 
					put(group_info, {Groupid,Leaderid,Rec,lists:keydelete(RemoveId,1,MemberList)}),
					case  auto_set_leader_by_sys() of
						false->	%%转移失败
							put(group_info, {Groupid,Leaderid,Rec,MemberList}),
							disband();
						_->	%%摧毁自己的
							group_handle:handle_group_destroy()
					end;
				false ->
					role_pos_util:send_to_role(RemoveId,{group_destroy,Groupid}),
					set_group_info({Groupid,Leaderid,Rec,lists:keydelete(RemoveId,1,MemberList)}),
					update_group_list_info_without_self()			
			end;					
		false->
			slogger:msg("remove_role not has this member error!!!!!~n")
	end.

%%aoiList里没有自己,所以取出的也没有自己
get_members_in_aoi()->
	MemberList = get_member_id_list(),
	lists:filter(fun(Id)->
					creature_op:is_in_aoi_list(Id)					
			end,MemberList).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%leader
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_leader()->
	{_,Leaderid,_,_} =get(group_info),
	Leaderid.

set_leader({NewLeader,NewLeaderNode,NewLeaderPid})->
	{TeamId,_,Rec,MemberList} =get(group_info),
	put(group_info,{TeamId,NewLeader,Rec,MemberList}),
	role_processor:set_leader_to_you(NewLeaderNode,NewLeaderPid,get(group_info)).

set_group_to_you(GroupId)->
	case has_group() of
		true->
			false;
		_->
			put(group_info,{GroupId,0,0,[]}),
			true
	end.	

set_me_leader(GroupInfo)->
	{TeamId,_,_,_} = GroupInfo,
	case TeamId =:= get_id() of
		true->  
			set_group_info(GroupInfo),
			update_group_list_info_without_self(),
			ok;
		_->
			error
	end.
		

is_leader()->
	get_leader() =:= get(roleid).

%%
%%return [{roleid,level},...]
%%
get_online_members_info()->
	MembersList = get_members_info(),
	lists:foldl(fun({RoleId,_,Info},List)->
					{IsOnLine,Level,_,_} = Info,
					if
						IsOnLine =:= 1 ->
							List ++ [{RoleId,Level}];
						true->
							List
					end
				end,[],MembersList).		
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%1.发送在同一个node上,但没在aoi范围内的队友,及掉线的队友信息给自己的客户端 (在aoi范围内的,客户端自己做)
%%2.发送给不在同一个节点上的队友客户端direct send自己的信息.
%%3.队长额外要做的:设置队员是否在线标识,给新上线的队友发送队伍信息
%%TODO:发送变化!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_invisible_info()->
	{_,LeaderId,_,MemberList} = get(group_info),
	MyRemoteInfo = make_roleinfo_for_othernode(get(creature_info)),
	MyId =get(roleid), 
	lists:foreach(fun({ID,Name,Info})->
			if   
				MyId =/= ID->
					case role_pos_util:where_is_role(ID) of
						[]->							%%不在线,发送给客户端掉线
							case Info of
								{IsOnline,_,_Class,_Gender} ->
									if
										 (MyId =:= LeaderId) and (IsOnline=:= 1)->
										 	 	set_member_online(offline,ID);
										 true-> nothing
									end;
								[] ->
									nothing
							end,
							{_,Level,_,_} = Info,
							State = pb_util:to_teammate_state(ID, Level, 0, 0, 0, 0, 0, 0, 0, 0,0,0),
							Message = role_packet:encode_group_member_stats_s2c(State),
							role_op:send_data_to_gate(Message);
						RolePos->%%在线
							ID = role_pos_db:get_role_id(RolePos),
							Node = role_pos_db:get_role_mapnode(RolePos),
							case Info of
								{IsOnline,_,_Class,_Gender} ->
										if
											 (MyId =:= LeaderId) and (IsOnline=:= 0)->
											 	 	set_member_online(online,ID);
											 true-> nothing
										end;
								[]->				%%尚未得到队员信息
									nothing
							end,
							case node()=:= Node of     
								true->					
									case lists:member(ID,get_members_in_aoi()) of
										false->			%%在同一节点,但未在aoi内,发送他们的信息给自己的客户端												
											case creature_op:get_creature_info(ID) of
												undefined->
													nothing;
												HisInfo->																		
													HisRemoteInfo = make_roleinfo_for_othernode(HisInfo),											
													Message = role_packet:encode_group_member_stats_s2c(role_attr:to_teammate_state(HisRemoteInfo)),
													role_op:send_data_to_gate(Message)
											end;	
										true->
											nothing
									end;
								false->					%%未在同一节点,直接发送自己的信息到他们的客户端			
									Message = role_packet:encode_group_member_stats_s2c(role_attr:to_teammate_state(MyRemoteInfo)),			
									role_pos_util:send_to_clinet_by_pos(RolePos,Message)
							end
					end;%% end of MyId =/= ID
				true->
					nothing
			end											
	end,MemberList).
		
update_by_timer()->
	update_invisible_info(),
	set_update_timer().
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	更新队伍信息到客户端
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_group_list_to_client()-> %%group_list_s2c {leaderid,[{id,name}]}	
	{_,Leaderid,_,MemberList} = get(group_info),
	SendList = lists:map(fun({RoleId,RoleName,Info})->
				case Info of
					[]->
						Level = 0,Class = 0,Gender = 0;
					{_,Level,Class,Gender}->
						nothing
				end,
				pb_util:to_group_member(RoleId,RoleName,Level,Class,Gender) end,MemberList),
	Message = role_packet:encode_group_list_update_s2c(Leaderid,SendList),
	role_op:send_data_to_gate(Message).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	发送队伍信息的改变给所有队员,跳过不在线的,只队长调用
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
update_group_list_info()->
	Message = {update_group_list,get(group_info)},
	send_to_all(Message),
	save_to_db().

update_group_list_info_without_self()->
	Message = {update_group_list,get(group_info)},
	send_to_all_without_self(Message),
	save_to_db().	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	直接发送给全部小组队友
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
send_to_all_without_self(Message)->
	MyId = get(roleid),
	lists:foreach(fun(Roleid)->
		if
			MyId =/= Roleid->
				role_pos_util:send_to_role(Roleid,Message);
			true->
				nothing
		end
	end,get_member_id_list()).

send_to_all(Message)->	
	lists:foreach(fun(Roleid)->
		role_pos_util:send_to_role(Roleid,Message)
	end,get_member_id_list()).
	
%%更新活注册自己的信息
update_reg_self_info()->
	update_reg_self_info(false).
	
update_reg_self_info(IsNameChanged)->		
	case get_leader() of
		0->		%%未在队伍中
			nothing;
		LeaderId->	
			UpInfo = {1,get_level_from_roleinfo(get(creature_info)),get_class_from_roleinfo(get(creature_info))
					,get_gender_from_roleinfo(get(creature_info))},
			Info = 		
			if
				IsNameChanged->
					{get_name_from_roleinfo(get(creature_info)),UpInfo};
				true->	
					UpInfo
			end,				
			Message = {regist_member_info,{get(roleid),Info}},
			role_pos_util:send_to_role(LeaderId,Message)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	设置队伍信息改变,发送到客户端
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_group_info({GroupId,_,_,_} = GroupInfo)->
	OriHas = has_group_truely(),
	put(group_info,GroupInfo),
	case  OriHas  of
		true->
			nothing;
		false-> 		%%第一次加入队伍或者断线重连,1,设置更新timer
			hook_to_delete_role_recruitment(?ERRNO_ROLE_UNRECRUITMENT_JOIN),
			group_id_changed(GroupId),
			set_update_timer()	
	end,
	update_group_list_to_client().
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% db op
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
save_to_db()->
	{GroupId,LeaderId,Rec,MembersInfo} = get(group_info),
	case group_db:get_group_by_id(GroupId) of
		[]->		%%first save
			Instance = 0,
			Description = [];
		GroupInfo->			
			Instance = group_db:get_group_instance(GroupInfo),
			Description = group_db:get_group_description(GroupInfo)
	end,
	group_db:add_group(GroupId,Rec,LeaderId,Instance,MembersInfo,Description).	
	
delete_from_db()->
	group_db:del_group(get_id()).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%%%%%%%%%%%%%%%%%%%							招募										%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%组队招募
set_to_recruitment(Instance,Description)->
	{GroupId,LeaderId,_,MembersInfo} = get(group_info),
	put(group_info,{GroupId,LeaderId,1,MembersInfo}),
	group_db:add_group(GroupId,1,LeaderId,Instance,MembersInfo,Description),
	update_group_list_info_without_self().

%%取消组队招募
set_to_unrecruitment()->
	{GroupId,LeaderId,_,MembersInfo} = get(group_info),
	put(group_info,{GroupId,LeaderId,0,MembersInfo}),
	group_db:add_group(GroupId,0,LeaderId,[],MembersInfo,[]),
	update_group_list_info_without_self().

%%进入副本时取消组队招募
hook_on_join_instance()->
	case has_group() and is_leader() and is_group_recuitment() of
		true->
			set_to_unrecruitment(),
			notify_unrecruitment_reason(?ERR_GROUP_UNRECRUITMENT_JOIN_INSTANCE);
		_->
			nothing
	end.	

%%得到组队招募队伍信息
get_all_recruit_teaminfo(InstanceId)->
	GroupsInfo = group_db:get_groups_by_isrecruite(1,InstanceId),
	Fun = fun(Members)->
				lists:map(
					fun({ID,Name,Info})->
						case Info of
							[] ->		%%尚未注册
								Level = 0,
								Class = 0,
								Gender = 0;
							{_,Level,Class,Gender}->
									nothing
						end,
						pb_util:to_group_member(ID,Name,Level,Class,Gender)
					end,Members)
		 end,	
	Rec_infos = lists:map(fun(GroupInfo)->
			Leaderid = group_db:get_group_leaderid(GroupInfo),
			case role_pos_util:where_is_role(Leaderid) of
				[]->
					Leader_line = 0;
				RolePos->
					Leader_line = role_pos_db:get_role_lineid(RolePos)
			end,		 			 		 		
	 		Members = group_db:get_group_members(GroupInfo),
	 		Instance = group_db:get_group_instance(GroupInfo),
	 		Description = group_db:get_group_description(GroupInfo),
			pb_util:to_recruite_info(Leaderid,Leader_line,Instance,erlang:apply(Fun,[Members]),Description)
	end,GroupsInfo),
	
	RoleRecs = 	role_recruitments_db:get_role_recruitments_by_isrecruite_from_db(InstanceId),
	Role_rec_infos = lists:map(fun(RolerecruitmentInfo)->
						RoleId = role_recruitments_db:get_role_recruitment_id(RolerecruitmentInfo),
						Name = role_recruitments_db:get_role_recruitment_name(RolerecruitmentInfo),
						Level = role_recruitments_db:get_role_recruitment_level(RolerecruitmentInfo),
						ClassId = role_recruitments_db:get_role_recruitment_class(RolerecruitmentInfo),
						Instance = role_recruitments_db:get_role_recruitment_instance(RolerecruitmentInfo),
						pb_util:to_role_recruite_info(RoleId,Name,Level,ClassId,Instance)
					end,RoleRecs),
	 
	{Rec_infos,Role_rec_infos}.
	
%%通知组队招募取消原因	
notify_unrecruitment_reason(Reason)->
	Msg = role_packet:encode_recruite_cancel_s2c(Reason),
	role_op:send_data_to_gate(Msg).

%%发布个人招募	
set_role_to_recruitment(Instance)->
	put(role_recruitments_tag,true),
	RoleName = util:safe_binary_to_list(get_name_from_roleinfo(get(creature_info))),
	role_recruitments_db:add_role_recruitment(get(roleid),RoleName,get(level),get_class_from_roleinfo(get(creature_info)),Instance).
%%取消个人招募	
set_role_to_unrecruitment()->
	put(role_recruitments_tag,false),
	role_recruitments_db:del_role_recruitment(get(roleid)).

hook_to_delete_role_recruitment()->
	hook_to_delete_role_recruitment([]).	
hook_to_delete_role_recruitment(Reason)->
	case get(role_recruitments_tag) of
		true->			
			set_role_to_unrecruitment(),
			if
				Reason =/=[]->
					notify_role_unrecruitment_reason(Reason);
				true->
					nothing
			end;	
		_->
			nothing
	end.	
	
notify_role_unrecruitment_reason(Reason)->
	Msg = role_packet:encode_role_recruite_cancel_s2c(Reason),
	role_op:send_data_to_gate(Msg).
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%%%%%%%%%%%%%%%%%%%							招募结束									%%%%%%%%%%%%%%%%%%%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	


%%队长召唤
proc_leader_instance_invite(InstanceProtoId,MapPos)->
	put(leader_instance_invite,{InstanceProtoId,MapPos,timer_center:get_correct_now()}),
	role_op:send_data_to_gate(instance_packet:encode_instance_leader_join_s2c(InstanceProtoId)).

%%处理队长召唤
proc_group_instance_join()->
	case get(leader_instance_invite) of
		[]->
			nothing;
		{InstanceProtoId,MapPos,Time}->
			put(leader_instance_invite,[]),
			case timer:now_diff(timer_center:get_correct_now(),Time) >= ?INVITE_DELETE_TIME*1000 of
				true->		%%邀请已经超时
					nothing;
				_->	
					case transport_op:can_directly_telesport() of
						false->
							Msg = role_packet:encode_map_change_failed_s2c(?ERRNO_ALREADY_IN_INSTANCE),
							role_op:send_data_to_gate(Msg);
						_->
							instance_op:instance_trans(get(map_info),InstanceProtoId,MapPos)
					end	
			end
	end.		

%%改名接口,返回要集体通知改名的人
%%因为自己做了改名更新.所以不用再集体通知
hook_on_role_name_change(_NewNameStr)->
	update_reg_self_info(true),
	[].
	
proc_get_aoi_role_group()->
	AoiGroupRoles = 
	lists:foldl(fun({MemberId,GroupId},AccRoleGroupTmp)->
			case group_db:get_group_by_id(GroupId) of
				[]->
					AccRoleGroupTmp;
				GroupInfo->
					Members = group_db:get_group_members(GroupInfo),
					MemberNum = length(Members),
					LeaderId = group_db:get_group_leaderid(GroupInfo),
					{LeaderId,LeaderName,{_Isonline,LeaderLevel,_Class,_Gender}} = lists:keyfind(LeaderId,1, Members),
					[pb_util:to_aoi_group_role(MemberId,LeaderId,LeaderName,LeaderLevel,MemberNum)|AccRoleGroupTmp]
			end
		end,[],creature_op:get_aoi_grouped_role_groupid()),
	Msg = role_packet:encode_aoi_role_group_s2c(AoiGroupRoles),
	role_op:send_data_to_gate(Msg).	
		
	
