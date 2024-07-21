%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-1-10
%% Description: TODO: Add description to loop_instance_proc_op
-module(loop_instance_proc_op).

%%
%% Include files
%%
-include("loop_instance_define.hrl").
-include("npc_define.hrl").

-define(DESTORY_INSTANCE_DELAY_TIME_S,1000).
-define(TURNBACK_PROC_DELAY_TIME_S,1500).
-define(DESTORY_SELF_DELAY_TIME_S,2000).
-define(CHECK_TIME_S,5000).
-define(FIRST_CHECK_TIME_S,20000).
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%

%%
%%instance_info {procname,groupid,type,creatorlevel,creatorid,layer}
%%instance_npcinfo [{npcproto,totalnum,killnum}]
%%instance_layer [{layer,memberlist,mapproc,besttime,starttime,duration}]

init(ProcName,{GroupId,Type,InstanceInfo})->
	{CreatorLevel,CreatorId} = InstanceInfo,
	put(instance_info,{ProcName,GroupId,Type,CreatorLevel,CreatorId,1}),
	put(instance_layer,[]),
	put(instance_npcinfo,[]),
	case start_instance(ProcName,1,GroupId,Type,CreatorLevel) of
		{ok,_}->
			erlang:send_after(?FIRST_CHECK_TIME_S,self(), {self_check});
		_->
			on_destory()
	end.

self_check()->
	Now = now(),
	{ProcName,CurGroupId,CurType,CreatorLevel,CreatorId,CurLayer} = get(instance_info),
	lists:foldr(fun(LayerInfo,Acc)->
					{Layer,Memberlist,Mapproc,Besttime,Starttime,Duration} = LayerInfo,
					CheckMember = (Memberlist =:= []),
					CheckTime = trunc(timer:now_diff(Now, Starttime)/1000000) >= Duration,
					if
						CheckTime->
							erlang:send_after(?DESTORY_INSTANCE_DELAY_TIME_S,Mapproc, {on_destroy}),
							erlang:send_after(?TURNBACK_PROC_DELAY_TIME_S,self(), {safe_turnback_proc,Mapproc}),
							if
								CheckMember,Acc->
									put(instance_layer,lists:keydelete(Layer,1,get(instance_layer))),
									Acc;
								CheckMember->
									if
										CurLayer =:= Layer->
											Acc;
										true->
											put(instance_layer,lists:keydelete(Layer,1,get(instance_layer))),
											Acc
									end;
								true->
									Acc
							end;
						true->
							if
								not CheckMember->
									false;
								Acc->
									erlang:send_after(?DESTORY_INSTANCE_DELAY_TIME_S,Mapproc, {on_destroy}),
									erlang:send_after(?TURNBACK_PROC_DELAY_TIME_S,self(), {safe_turnback_proc,Mapproc}),
									put(instance_layer,lists:keydelete(Layer,1,get(instance_layer))),
									Acc;
								true->
									Acc
							end
					end		
				end,true,get(instance_layer)),
	RemainLayers = length(get(instance_layer)),
	if
		RemainLayers =:= 0->
			erlang:send_after(?DESTORY_SELF_DELAY_TIME_S,self(), {destroy_self});		
		true->
			erlang:send_after(?CHECK_TIME_S,self(), {self_check})
	end.

safe_turnback_proc(MapProc)->
  instanceid_generator:safe_turnback_proc(MapProc).


on_destory()->
	{ProcName,CurGroupId,CurType,CreatorLevel,CreatorId,CurLayer} = get(instance_info),
	loop_instance_mgr:stop_loop_instance(CurGroupId,CurType,node(),ProcName).

%%
%%return {ok,mapproc} | limit | timeout |error
%%
get_instance(GroupId,Type,Layer)->
	%% check can transport
	{ProcName,CurGroupId,CurType,CreatorLevel,CreatorId,CurLayer} = get(instance_info),
	if
		((CurGroupId =/= GroupId) or (CurType =/= Type)) ->
%%			io:format("get instance error ~n"),
			nothing;
		Layer =:= CurLayer+1->%%need create
			%%check create condition
			case check_mission_complete() of
				true->
					case start_instance(ProcName,Layer,GroupId,Type,CreatorLevel) of
						{ok,MapProc}->
							put(instance_info,{ProcName,CurGroupId,Type,CreatorLevel,CreatorId,Layer}),
							{ok,MapProc};
						_->
							error
					end;
				_->
					limit
			end;
		Layer =< CurLayer->	%% find exist instance
			case lists:keyfind(Layer,1,get(instance_layer)) of
				false->  %% already delete
					timeout;
				{_,_,MapProc,_,_,_}->
					{ok,MapProc};
				_->
					error
			end;
		true->
			error
	end.

member_entry(RoleId,Layer)->
	case lists:keyfind(Layer-1,1,get(instance_layer)) of
		false->
			nothing;
		{PreLayer,PreMemberlist,PreMapproc,PreBesttime,PreStarttime,PreDuration}->
			case lists:member(RoleId,PreMemberlist) of
				true->
					NewPreMemberlist = PreMemberlist -- [RoleId],
					put(instance_layer,lists:keyreplace(PreLayer,1,get(instance_layer),{PreLayer,NewPreMemberlist,PreMapproc,PreBesttime,PreStarttime,PreDuration}));
				_->
					nothing
			end
	end,
	case lists:keyfind(Layer,1,get(instance_layer)) of
		false->
			slogger:msg("~p get loop instance layer error ~p",[RoleId,Layer]);
		{_,Memberlist,Mapproc,Besttime,Starttime,Duration}->
			case lists:member(RoleId,Memberlist) of
				false->
					NewMemberlist = [RoleId|Memberlist],
					put(instance_layer,lists:keyreplace(Layer,1,get(instance_layer),{Layer,NewMemberlist,Mapproc,Besttime,Starttime,Duration})),
					%%
					%%instance_info {procname,groupid,type,creatorlevel,creatorid,layer}
					{_,_,CurType,_,_,CurLayer} = get(instance_info),					
					if
						CurLayer =:= Layer->
							case check_mission_complete() of
								true->
									Result = ?LOOP_INSTANCE_LAYER_COMPLETE;	
								_->
									Result = ?LOOP_INSTANCE_LAYER_UNCOMPLETE
							end;
						true->
							Result = ?LOOP_INSTANCE_LAYER_COMPLETE
					end,
					LeftTime_s = max(0,trunc(Duration - timer:now_diff(now(), Starttime)/1000000)),
					EntryMessage = loop_instance_packet:encode_entry_loop_instance_s2c(Layer,Result,LeftTime_s,Besttime,0),	
					role_pos_util:send_to_role_clinet(RoleId,EntryMessage),
					if
						Result =:= ?LOOP_INSTANCE_LAYER_UNCOMPLETE->
							%%init npc info
							NpcInfo = lists:map(fun({NpcProto,TotalNum,KillNum})->
														loop_instance_packet:make_kmi(NpcProto,TotalNum - KillNum)
												end, get(instance_npcinfo)),
							KillMonsterInfo = loop_instance_packet:encode_loop_instance_kill_monsters_info_init_s2c(NpcInfo,CurType,Layer),
							role_pos_util:send_to_role_clinet(RoleId,KillMonsterInfo);
						true->
							nothing
					end;
				_->
					nothing
			end
	end.

member_leave(RoleId,Layer)->
	{ProcName,CurGroupId,CurType,CreatorLevel,CreatorId,CurLayer} = get(instance_info),
	case lists:keyfind(Layer,1,get(instance_layer)) of
		false->
			nothing;
		{_,Memberlist,Mapproc,Besttime,Starttime,Duration}->
			case lists:member(RoleId,Memberlist) of
				true->
					NewMemberlist = Memberlist -- [RoleId],
					put(instance_layer,lists:keyreplace(Layer,1,get(instance_layer),{Layer,NewMemberlist,Mapproc,Besttime,Starttime,Duration}));
				_->
					nothing
			end
	end,
	if
		Layer =:= CurLayer ->
			case check_mission_complete() of
				true->
					Layer;
				_->
					Layer-1
			end;
		Layer < CurLayer->
			Layer -1;
		true->
			error
	end.


kill_monster(_,Layer,NpcProto)->
	{ProcName,CurGroupId,CurType,CreatorLevel,CreatorId,CurLayer} = get(instance_info),
	if
		Layer =/= CurLayer ->
			nothing;
		true->
			case lists:keyfind(NpcProto,1,get(instance_npcinfo)) of
				false->
					nothing;
				{_,TotalNum,OldKillNum}->
					if
						TotalNum =:= OldKillNum->
							nothing;
						true->
							NewKillNum = OldKillNum + 1,
							put(instance_npcinfo,lists:keyreplace(NpcProto,1,get(instance_npcinfo),{NpcProto,TotalNum,NewKillNum})),
							case lists:keyfind(Layer,1,get(instance_layer)) of
								false->
									nothing;
								{_,Memberlist,Mapproc,Besttime,Starttime,Duration}->
									%% update msg to member
									KillMonsterMsg = loop_instance_packet:encode_loop_instance_kill_monsters_info_s2c(NpcProto,TotalNum - NewKillNum,CurType,Layer),
									lists:foreach(fun(MemberId)->
														 role_pos_util:send_to_role_clinet(MemberId,KillMonsterMsg)
												  end,Memberlist),
									case check_mission_complete() of
										true->
											%%check best time
											CastTime = trunc(timer:now_diff(now(), Starttime)/1000000),
											if
												Besttime > CastTime ->
													update_layer_record(CurType,Layer,CastTime),
													%%refresh rank list
													todo;
												true->
													nothing	
											end;
										_->
											nothing
									end
									
							end
					end	
			end
	end.
					 		
make_mapproc_name(ProcName,Layer)->
	MapProcName = util:sprintf("map_~p_~p",[ProcName,Layer]),
	list_to_atom(MapProcName).

%%
%% Local Functions
%%

%%
%%return {ok,mapproc} |error
%%
start_instance(ProcName,Layer,GroupId,Type,CreatorLevel)->
	ProtoInfo = loop_instance_db:get_loop_instance_proto_info({Type,Layer}),
	InstanceProto = loop_instance_db:get_instance_proto(ProtoInfo),
	InstanceInfo = instance_proto_db:get_info(InstanceProto),
	MapId = instance_proto_db:get_level_mapid(InstanceInfo),
	case instanceid_generator:get_procname({GroupId,Type,Layer}) of
		[]->
			error;
		{exsit,_MapProc}->
			exist;
		MapProc->
			case map_manager:start_instance(MapProc,{atom_to_list(ProcName),InstanceProto,{CreatorLevel,?CREATOR_BY_SYSTEM}},MapId) of
				ok->
					%% spawn npc
					NpcIdList = loop_instance_db:get_monsters(ProtoInfo),
					lists:foreach(fun(NpcId)-> creature_op:call_creature_spawn_in_instance(MapProc,MapId,NpcId,{CreatorLevel,?CREATOR_BY_SYSTEM}) end,NpcIdList),
					TargetNpcInfo = loop_instance_db:get_targetnpclist(ProtoInfo),
					TargetNpcList = lists:map(fun({NpcProto,TotalNum,_})-> {NpcProto,TotalNum,0} end,TargetNpcInfo),
					put(instance_npcinfo,TargetNpcList),
					case loop_instance_db:get_loop_instance_record({Type,Layer}) of
						{ok,[]}->
							BestTime = 0;
						{ok,{_,_,BestTime}}->
							nothing;
						_->
							BestTime = 0
					end,
					DurationTime = loop_instance_db:get_limittime(ProtoInfo),
					put(instance_layer,[{Layer,[],MapProc,BestTime,now(),DurationTime}|get(instance_layer)]),
					slogger:msg("map_manager:start_instance ~p ok~n",[MapProc]),
					{ok,MapProc};		
				Other->
					instanceid_generator:safe_turnback_proc(MapProc),
					slogger:msg("map_manager:start_instance return ~p ~n",[Other]),
					error
			end
	end.

check_mission_complete()->
	lists:foldl(fun({_,Total,Killed},Acc)->
						if
							Acc->
								Total =< Killed;
							true->
								Acc
						end
				end,true,get(instance_npcinfo)).

update_layer_record(Type,Layer,BestTime)->
	ReplaceFlag = 
		case loop_instance_db:get_loop_instance_record({Type,Layer}) of
				{ok,[]}->
					true;
				{ok,{_,_,BestTimeRecord}}->
					BestTimeRecord > BestTime;
				_->
					false
		end,
	if
		ReplaceFlag->
			loop_instance_db:sync_update_loop_instance_record_to_mnesia({Type,Layer},{{Type,Layer},BestTime});
		true->
			nothing
	end.