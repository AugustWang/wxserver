%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-1-6
%% Description: TODO: Add description to loop_instance_op
-module(loop_instance_op).

-compile(export_all).
%%
%% Include files
%%
-include("login_pb.hrl").
-include("error_msg.hrl").
-include("loop_instance_define.hrl").
-include("instance_define.hrl").
-include("game_map_define.hrl").
-include("role_struct.hrl").
%%
%% Exported Functions
%%
%%-export([]).


%% loop_instance_vote    {state,starttime,agreelist,instancetype,leaderid}
%% loop_instance_info    {state,instancetype,layer,node,proc}
%% loop_instance_mapinfo mapproc
%% API Functions
%%
init()->
	put(loop_instance_vote,{false,{0,0,0},[],0,0}),
	put(loop_instance_info,{false,0,0,[],[]}),
	put(loop_instance_mapinfo,[]),
	case loop_instance_db:get_role_loop_instance(get(roleid)) of
		{ok,TodayTimeRecord}->
			put(loop_instance_record,TodayTimeRecord);
		_->
			put(loop_instance_record,[])
	end.

uninit()->
	{EntryLoopInstance,InstanceType,Layer,Node,Proc} = get(loop_instance_info),
	if
		EntryLoopInstance->
			leave_loop_instance(InstanceType,Layer,Node,Proc);
		true->
			nothing
	end.

export_for_copy()->
	{get(loop_instance_vote),get(loop_instance_info),get(loop_instance_mapinfo),get(loop_instance_record)}.

load_by_copy(LoopInstanceDiscInfo)->
	{LoopInstanceVote,LoopInstanceInfo,MapInfo,Record} = LoopInstanceDiscInfo,
	put(loop_instance_vote,LoopInstanceVote),
	put(loop_instance_info,LoopInstanceInfo),
	put(loop_instance_mapinfo,MapInfo),
	put(loop_instance_record,Record).

reset()->
	put(loop_instance_vote,{false,{0,0,0},[],0,0}),
	put(loop_instance_info,{false,0,0,[],[]}),
	put(loop_instance_mapinfo,[]).

get_map_proc_name()->
	get(loop_instance_mapinfo).

hook_map_complete()->
	{EntryLoopInstance,InstanceType,Layer,Node,Proc} = get(loop_instance_info),
	if
		EntryLoopInstance->
			case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
				?MAP_LOOP_INSTANCE->
					loop_instance_proc:member_entry(get(roleid),Layer,Node,Proc);
				_->
					leave_loop_instance(InstanceType,Layer,Node,Proc)
			end;
		true->
			nothing
	end.

hook_kill_monster(NpcProtoId)->
	{EntryLoopInstance,InstanceType,Layer,Node,Proc} = get(loop_instance_info),
	if
		EntryLoopInstance->
			loop_instance_proc:kill_monster(get(roleid),Layer,NpcProtoId,Node,Proc);		
		true->
			nothing
	end.

hook_leave_group()->
	{EntryLoopInstance,InstanceType,Layer,Node,Proc} = get(loop_instance_info),
	if
		EntryLoopInstance->
			force_leave_loop_instance();
		true->
			nothing
	end.
%%
%%apply entry instance 
%%
%%group leader  need 
%%
proc_client_msg(#entry_loop_instance_apply_c2s{type = Type})->
	%%check leader
	try
		%%check loop instance info and vote info
		{EntryLoopInstance,InstanceType,_,_,_} = get(loop_instance_info),
		{VoteFlag,StartTime,_,VoteType,_} = get(loop_instance_vote),
		if
			EntryLoopInstance->
				throw(error_alreadyentry);
			true->
				nothing
		end,
		if
			VoteFlag,VoteType =:= Type->
				TimeDiff = trunc(timer:now_diff(now(), StartTime)/1000000),
				if
					TimeDiff < ?VOTE_TIME_S->
						throw(?ERRON_LOOP_INSTANCE_INSTANCE_IN_VOTE);
					true->
						nothing
				end;
			true->
				nothing
		end,
		%%check group leader
		case group_op:is_leader() of
			false->
				throw(error_notleader);
			_->
				nothing
		end,
		%%check instance 
		case loop_instance_mgr:check_loop_instance(get_format_groupid(),Type) of
			ok->
				nothing;
			_->
				throw(?ERRON_LOOP_INSTANCE_INSTANCE_EXIST)
		end,
		%%check time and member
		case loop_instance_db:get_loop_instance_info(Type) of
			[]->
				throw(?ERROR_UNKNOWN);
			InstanceProtoInfo->
				EveryDayTimes = loop_instance_db:get_times(InstanceProtoInfo),
				MaxMemberNum = loop_instance_db:get_members(InstanceProtoInfo),
			%%	LevelLimit = loop_instance_db:get_level(InstanceProtoInfo),
				CurGroupMembers = group_op:get_member_count(),
				LevelLimit = loop_instance_db:get_levellimit(InstanceProtoInfo),
				MyLevel = get(level),
				if
					LevelLimit > MyLevel->
						throw(?ERROR_LESS_LEVEL);
					CurGroupMembers > MaxMemberNum ->
						throw(?ERRON_LOOP_INSTANCE_MEMBERS_LIMIT);
					true->						
						TodayTimeRecord = get(loop_instance_record),
						case TodayTimeRecord of
							[]->
								nothing;
							{_,_,RecordList}->
								case lists:keyfind(Type,1,RecordList) of
									false->
										nothing;
									{_,Times,Timestamp}->
										case timer_util:check_same_day(now(), Timestamp) of
											false->
												nothing;
											_->
												if
													Times >= EveryDayTimes->
														throw(?ERRON_LOOP_INSTANCE_TIMES_LIMIT);
													true->
														nothing
												end
										end
								end
						end
				end
		end,
		%%notify vote
		%%group_op:send_to_all_without_self({loop_instance_node,{?INTERNAL_MSG_NOTIFY_VOTE,Type,get(roleid)}}),	
		MemberIds = group_op:get_member_id_list(),
		SendMsg = {loop_instance_node,{?INTERNAL_MSG_NOTIFY_VOTE,Type,get(roleid)}},
		lists:foreach(fun(SendTo)-> role_pos_util:send_to_role(SendTo, SendMsg) end, MemberIds -- [get(roleid)]),
		LeaderVoteInfo = loop_instance_packet:make_votestate(get(roleid),?INTERNAL_STATE_AGREE),
		VoteInfos = lists:map(fun(MemberId)-> loop_instance_packet:make_votestate(MemberId,?INTERNAL_STATE_IDLE) end,MemberIds -- [get(roleid)]),
		VoteMsg = loop_instance_packet:encode_entry_loop_instance_vote_s2c(0,[LeaderVoteInfo|VoteInfos]),
		lists:foreach(fun(MemberId)-> role_pos_util:send_to_role_clinet(MemberId, VoteMsg) end,MemberIds),
		put(loop_instance_vote,{true,now(),[get(roleid)],Type,get(roleid)})
	catch
		E:R->
			case E of
				throw->
					if
						is_integer(R)->
							FaildMessage = loop_instance_packet:encode_loop_instance_opt_s2c(R),
							role_op:send_data_to_gate(FaildMessage);
						true->
							slogger:msg("~p E ~p R ~p ~n",[?MODULE,E,R])
					end;
				_->
					slogger:msg("~p E ~p R ~p S ~p ~n",[?MODULE,E,R,erlang:get_stacktrace()])
			end
	end;

%%
%%vote
%%
proc_client_msg(#entry_loop_instance_vote_c2s{state = State})->
	{VoteState,StartTime,_,Type,LeaderId} = get(loop_instance_vote),
	if
		VoteState->
			TimeDiff = trunc(timer:now_diff(now(), StartTime)/1000000),
			if
				TimeDiff > ?VOTE_TIME_S->
					nothing;
				true->
					send_vote_to_leader(State,LeaderId)			
			end;
		true->
			nothing
	end,
	put(loop_instance_vote,{false,{0,0,0},[],0,0});
	

%%
%%entry loop instance 
%%
proc_client_msg(#entry_loop_instance_c2s{layer = EntryLayer})->
	%%check loop instance info
	{EntryFlag,Type,Layer,Node,Proc} = get(loop_instance_info),
	if
		EntryFlag->
			if
				EntryLayer =:= Layer+1->
					entry_layer(EntryLayer);
				true->
					nothing
			end;
		EntryLayer =:= 1->
			entry_first_layer();
		true->
%%			io:format("entry layer error entryflag false and layer ~p ~n ~n",[EntryLayer]),
			error
	end;
%%
%%leave loop instance
%%
proc_client_msg(#leave_loop_instance_c2s{})->
	{EntryLoopInstance,InstanceType,Layer,Node,Proc} = get(loop_instance_info),
	if
		EntryLoopInstance->
			force_leave_loop_instance();
		true->
			nothing
	end;

%%
%%
%%
proc_client_msg(#loop_instance_reward_c2s{})->
	todo;

	
proc_client_msg(Msg)->
	slogger:msg("~p proc_client_msg error msg ~p ~n",[?MODULE,Msg]).


proc_node_msg({?INTERNAL_MSG_NOTIFY_VOTE,Type,LeaderId})->
	case check_instance_times(Type) of
		true->
			%%check level
			case loop_instance_db:get_loop_instance_info(Type) of
				[]->
					notify_vote_error();
				InstanceProtoInfo->
					LevelLimit = loop_instance_db:get_levellimit(InstanceProtoInfo),
					MyLevel = get(level),
					if
						LevelLimit > MyLevel->
							notify_vote_error();
						true->
							put(loop_instance_vote,{true,now(),[],Type,LeaderId})
					end
			end;
		_->
			notify_vote_error()
	end; 

proc_node_msg({?INTERNAL_MSG_VOTE,VoterId,State})->
	{VoteState,StartTime,AgreeList,Type,LeaderId} = get(loop_instance_vote),
%%	io:format("INTERNAL_MSG_VOTE ~p ~n",[{VoterId,State}]),
	if
		VoteState->
			TimeDiff = trunc(timer:now_diff(now(), StartTime)/1000000),
			if
				TimeDiff > ?VOTE_TIME_S->
					%%io:format("INTERNAL_MSG_VOTE error TimeDiff ~p ~n",[TimeDiff]),
					nothing;
				true->
					if
						State =:= ?INTERNAL_STATE_AGREE->
							case lists:member(VoterId,AgreeList) of
								true->
									NewAgreeList = AgreeList;
								_->
									NewAgreeList = [VoterId|AgreeList]
							end;
						true->
							NewAgreeList = AgreeList
					end,
					put(loop_instance_vote,{VoteState,StartTime,NewAgreeList,Type,LeaderId}),
					%%update votestate
					VoteMsg = loop_instance_packet:make_votestate(VoterId,State),
					UpdateMsg = loop_instance_packet:encode_entry_loop_instance_vote_update_s2c(VoteMsg),
%%					io:format("INTERNAL_MSG_VOTE send to client ~n"),
					lists:foreach(fun(MemberId)-> role_pos_util:send_to_role_clinet(MemberId, UpdateMsg) end, group_op:get_member_id_list())
			end;
		true->
			nothing
	end;

proc_node_msg({?INTERNAL_MSG_NOTIFY_ENTRY,Type,Node,ProcName})->
	put(loop_instance_info,{true,Type,1,Node,ProcName}),
	entry_layer(1);

proc_node_msg({gm_goto_next_layer,GotoLayer,LastLayer})->
	gm_goto_next_layer(GotoLayer,LastLayer);
	
proc_node_msg(Msg)->
	slogger:msg("~p proc_node_msg error msg ~p ~n",[?MODULE,Msg]).

%%
%%return [{instancetype,time}]
%%
get_instance_record()->
	TodayTimeRecord = get(loop_instance_record),
	case TodayTimeRecord of
		[]->
			[];
		{_,_,RecordList}->
			lists:map(fun({Type,Times,Timestamp})->
						case timer_util:check_same_day(now(), Timestamp) of
							false->
								{Type,0};	
							_->
								{Type,Times}
						end
					end,RecordList);
		_->
			[]
	end.

gm_goto_next_layer(GotoLayer,LastLayer)->
	%%check loop instance info
	{EntryFlag,Type,Layer,Node,Proc} = get(loop_instance_info),
	if
		EntryFlag->
			if
				LastLayer =:= Layer->
					nothing;
				GotoLayer > Layer->
					mapop:kill_all_monster(),
					entry_layer(Layer+1),
					%%gm_goto_next_layer(GotoLayer);
					erlang:send_after(1000, self(), {loop_instance_node,{gm_goto_next_layer,GotoLayer,Layer}});
				true->
					nothing
			end;
		true->
%%			io:format("entry layer error entryflag false and layer ~p ~n ~n",[EntryLayer]),
			error
	end.
%%
%% Local Functions
%%


notify_vote_error()->
	put(loop_instance_vote,{false,{0,0,0},[],0,0}),
	VoteMsg = loop_instance_packet:make_votestate(get(roleid),?INTERNAL_STATE_DONOT_MATCH),
	UpdateMessage = loop_instance_packet:encode_entry_loop_instance_vote_update_s2c(VoteMsg),
	lists:foreach(fun(MemberId)-> role_pos_util:send_to_role_clinet(MemberId, UpdateMessage) end, group_op:get_member_id_list()).
			
	
%%
%%return true|false
%%
check_instance_times(Type)->
	case loop_instance_db:get_loop_instance_info(Type) of
		[]->
			false;
		InstanceProtoInfo->
			EveryDayTimes = loop_instance_db:get_times(InstanceProtoInfo),		
			TodayTimeRecord = get(loop_instance_record),
			case TodayTimeRecord of
				[]->
					true;
				{_,_,RecordList}->
					case lists:keyfind(Type, 1, RecordList) of
						false->
							true;
						{_,Times,Timestamp}->
							case timer_util:check_same_day(now(), Timestamp) of
								false->
									true;
								_->
									if
										Times >= EveryDayTimes->
											false;
										true->
											true
									end
							end
					end								
			end
	end.

send_vote_to_leader(State,SendToLeaderId)->
	%%check group and leader
	LeaderId = group_op:get_leader(),
	case ((LeaderId =:= get(roleid)) or (LeaderId =/=SendToLeaderId))  of
		true->
			nothing;
		_->
			role_pos_util:send_to_role(LeaderId, {loop_instance_node,{?INTERNAL_MSG_VOTE,get(roleid),State}})
	end.

entry_first_layer()->
	%%check leader
	%%check vote
	{VoteState,StartTime,AgreeList,Type,LeaderId} = get(loop_instance_vote),
	MyId = get(roleid),
	CurLeaderId = group_op:get_leader(), 
	AgreeLen = length(AgreeList),
	GroupLen = group_op:get_member_count(),	
	if
		not VoteState->
			nothing;
		LeaderId =/= MyId->
			nothing;
		LeaderId =/= CurLeaderId->
			nothing;
		AgreeLen =/= GroupLen->
			Errno = ?ERRON_LOOP_INSTANCE_VOTE_FAILD,
			FaildMessage = loop_instance_packet:encode_loop_instance_opt_s2c(Errno),
			role_op:send_data_to_gate(FaildMessage);
		true->
			%%check vote time
			TimeDiff = trunc(timer:now_diff(now(), StartTime)/1000000),
			if
				TimeDiff > ?VOTE_TIME_S ->
					nothing;
				true->
					%%check instance times
					case check_instance_times(Type) of
						false->
%%							io:format("entry_first_layer error ERRON_LOOP_INSTANCE_TIMES_LIMIT ~n"),
							Errno = ?ERRON_LOOP_INSTANCE_TIMES_LIMIT,
							FaildMessage = loop_instance_packet:encode_loop_instance_opt_s2c(Errno),
							role_op:send_data_to_gate(FaildMessage);
						_->
							%%check can transport to instance
							case transport_op:can_directly_telesport() of
								true->
									%%create loop instance proc 
									MyLevel = get_level_from_roleinfo(get(creature_info)),
									GroupId = get_format_groupid(),
									case loop_instance_mgr:start_loop_instance(GroupId,Type,{MyLevel,MyId}) of									
										{ok,Node,ProcName}->
											%%io:format("loop_instance_mgr start_loop_instance ret ok ~p ~p ~n",[Node,ProcName]),										
											%%get mapnameproc
											case loop_instance_proc:entry_instance(GroupId,Type,1,Node,ProcName) of
												{ok,MapProcName}->
													%%io:format("loop_instance_mgr entry_instance ret ok ~p ~n",[MapProcName]),
													put(loop_instance_info,{true,Type,1,Node,ProcName}),
													put(loop_instance_mapinfo,MapProcName),
													%%notify members
													%%group_op:send_to_all_without_self({loop_instance_node,{?INTERNAL_MSG_NOTIFY_ENTRY,Type,Node,ProcName}}),
													lists:foreach(fun(NotifyMemberId)->
																		  role_pos_util:send_to_role(NotifyMemberId, {loop_instance_node,{?INTERNAL_MSG_NOTIFY_ENTRY,Type,Node,ProcName}})
																		  end,AgreeList -- [get(roleid)]),
													TodayTimeRecord = get(loop_instance_record),
													case TodayTimeRecord of
														[]->
															put(loop_instance_record,{loop_instance_record,MyId,[{Type,1,now()}]}),
															loop_instance_db:async_update_role_loop_instance_to_mnesia(MyId, {MyId,[{Type,1,now()}]});
														{_,_,RecordList}->
															case lists:keyfind(Type,1,RecordList) of
																{_,Times,Timestamp}->
																	case timer_util:check_same_day(now(), Timestamp) of
																		false->
																			NewRecordList = lists:keyreplace(Type,1,RecordList,{Type,1,now()}),
																			put(loop_instance_record,{loop_instance_record,MyId,NewRecordList}),
																			loop_instance_db:async_update_role_loop_instance_to_mnesia(MyId, {MyId,NewRecordList});
																		_->
																			NewRecordList = lists:keyreplace(Type,1,RecordList,{Type,Times+1,Timestamp}),
																			put(loop_instance_record,{loop_instance_record,MyId,NewRecordList}),
																			loop_instance_db:async_update_role_loop_instance_to_mnesia(MyId, {MyId,NewRecordList})
																	end;
																_->
																	NewRecordList = [{Type,1,now()}|RecordList],
																	put(loop_instance_record,{loop_instance_record,MyId,NewRecordList}),
																	loop_instance_db:async_update_role_loop_instance_to_mnesia(MyId, {MyId,NewRecordList})
															end
													end,
													%%
													activity_value_op:update({instance,Type}),
													transport_to_instance(MapProcName,Type,1);
												_->
													
													FaildMessage = loop_instance_packet:encode_loop_instance_opt_s2c(?ERRON_LOOP_INSTANCE_INSTANCE_EXIST),
													role_op:send_data_to_gate(FaildMessage),
													reset(),
													error
											end;
										exist->
											reset(),
											FaildMessage = loop_instance_packet:encode_loop_instance_opt_s2c(?ERRON_LOOP_INSTANCE_INSTANCE_EXIST),
											role_op:send_data_to_gate(FaildMessage);
										GetMapRetErrno->
											error
									end;							
								RetTranspoartErrno->
								 	nothing
							end
					end
			end
	end.

entry_layer(Layer)->
	{EntryFlag,Type,CurLayer,Node,ProcName} = get(loop_instance_info),
	GroupId = get_format_groupid(),
	case loop_instance_proc:entry_instance(GroupId,Type,Layer,Node,ProcName) of
		{ok,MapProc}->
%%			io:format("entry_layer ~p success ~n",[Layer]),
			if
				Layer =:= 1->
					MyId = get(roleid),
					TodayTimeRecord = get(loop_instance_record),
					case TodayTimeRecord of
						[]->
							put(loop_instance_record,{loop_instance_record,MyId,[{Type,1,now()}]}),
							loop_instance_db:async_update_role_loop_instance_to_mnesia(MyId, {MyId,[{Type,1,now()}]});
						{_,_,RecordList}->
							case lists:keyfind(Type,1,RecordList) of
								{_,Times,Timestamp}->
									case timer_util:check_same_day(now(), Timestamp) of
										false->
											NewRecordList = lists:keyreplace(Type,1,RecordList,{Type,1,now()}),
											put(loop_instance_record,{loop_instance_record,MyId,NewRecordList}),
											loop_instance_db:async_update_role_loop_instance_to_mnesia(MyId, {MyId,NewRecordList});
										_->
											NewRecordList = lists:keyreplace(Type,1,RecordList,{Type,Times+1,Timestamp}),
											put(loop_instance_record,{loop_instance_record,MyId,NewRecordList}),
											loop_instance_db:async_update_role_loop_instance_to_mnesia(MyId, {MyId,NewRecordList})
									end;
								_->
									NewRecordList = [{Type,1,now()}|RecordList],
									put(loop_instance_record,{loop_instance_record,MyId,NewRecordList}),
									loop_instance_db:async_update_role_loop_instance_to_mnesia(MyId, {MyId,NewRecordList})
							end
					end,
					activity_value_op:update({instance,Type});
				true->
					nothing
			end,
			put(loop_instance_info,{EntryFlag,Type,Layer,Node,ProcName}),
			put(loop_instance_mapinfo,MapProc),
			transport_to_instance(MapProc,Type,Layer);
		limit->
%%			io:format("entry_layer ~p error ~n",[Layer]),
			FaildMessage = loop_instance_packet:encode_loop_instance_opt_s2c(?ERRON_LOOP_INSTANCE_INSTANCE_MISSION_UNCOMPLETED),
			role_op:send_data_to_gate(FaildMessage);
		_->
%%			io:format("entry_layer ~p limit ~n",[Layer]),
			FaildMessage = loop_instance_packet:encode_loop_instance_opt_s2c(?ERRON_LOOP_INSTANCE_INSTANCE_TRANSPORT_ERROR),
			role_op:send_data_to_gate(FaildMessage)
	end.

transport_to_instance(MapProc,Type,Layer)->
	case instance_pos_db:get_instance_pos_from_mnesia(erlang:atom_to_list(MapProc)) of			
		[]->
			slogger:msg("~p get instance ~p pos error ~n",[?MODULE,MapProc]);
		{_Id,_Creation,StartTime,CanJoin,InstanceNode ,_Pid,MapId,ProtoId,Members}->
			ProtoInfo = instance_proto_db:get_info(ProtoId),
			LoopInstanceProtoInfo = loop_instance_db:get_loop_instance_proto_info({Type,Layer}),
			BornPos = loop_instance_db:get_bornpos(LoopInstanceProtoInfo),
			instance_op:trans_to_dungeon(false,MapProc,get(map_info),BornPos,?INSTANCE_TYPE_LOOP_INSTANCE,ProtoInfo,InstanceNode,MapId)
	end.

leave_loop_instance(Type,Layer,Node,Proc)->
	ReWardLayer = loop_instance_proc:member_leave(get(roleid),Layer,Node,Proc),
	if
		is_integer(ReWardLayer)->
			if
				ReWardLayer =:= 0->
	%%				io:format("leave_loop_instance s:~p ~n",[erlang:get_stacktrace()]),
					RewardMsg = loop_instance_packet:encode_loop_instance_reward_s2c(0,Type,Layer),
					role_op:send_data_to_gate(RewardMsg);
				true->
%%					io:format("leave_loop_instance s:~p ~n",[erlang:get_stacktrace()]),
					ProtoInfo = loop_instance_db:get_loop_instance_proto_info({Type,ReWardLayer}),
					Exp = loop_instance_db:get_exp(ProtoInfo),
					SoulPower = loop_instance_db:get_soulpower(ProtoInfo),
					role_op:obtain_exp(Exp),
					role_op:obtain_soulpower(SoulPower),
					RewardMsg = loop_instance_packet:encode_loop_instance_reward_s2c(ReWardLayer,Type,Layer),
					role_op:send_data_to_gate(RewardMsg)
			end;
		true->
			nothing
	end,	
	init().
	
force_leave_loop_instance()->
	case get_map_proc_name() of
		[]->
			nothing;
		MapProc->
			instance_op:kick_instance_by_reason({?INSTANCE_TYPE_LOOP_INSTANCE,MapProc})
	end.


get_format_groupid()->
	case group_op:get_id() of
		0->
			0;
		{LeaderId,{A,B,C}}->
			util:sprintf("~p_~p~p~p",[LeaderId,A,B,C])
	end.