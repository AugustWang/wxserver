%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-11
%%% -------------------------------------------------------------------
-module(map_processor).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_define.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([start_link/2]).

-compile(export_all).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("data_struct.hrl").
-include("instance_define.hrl").
-include("npc_define.hrl").

%%mapinfo: {LineId,MapId}
-record(state, {mapinfo, aoidb, mapproc}).

-define(ETS_POS_GRID,1).
-define(ETS_POS_UNITS,2).
-define(ETS_POS_ROLES,3).
-define(ETS_POS_STATE,4).
%% ====================================================================
%% External functions
%% ====================================================================
start_link(MapProcName,{MapId_line,Tag})->
	gen_server:start_link({local,MapProcName},?MODULE,[MapProcName, {MapId_line,Tag}],[]).

join_grid(MapProcName,Grid,CreatureId)->
	gen_server:call(MapProcName,{join_grid,Grid,CreatureId},infinity).

leave_grid(MapProcName,Grid,CreatureId)->
	gen_server:call(MapProcName,{leave_grid,Grid,CreatureId}).

%%lefttime
get_instance_details(MapProcName,Node)->
	try
		gen_server:call({MapProcName,Node},get_instance_details)
	catch
		E:R->
			slogger:msg("get_instance_details error E ~p: R ~p",[E,R]),
			[]
	end.

join_instance(RoleId,MapProcName,Node)->
	try
		gen_server:call({MapProcName,Node},{role_come,RoleId})
	catch
		E:R->
			slogger:msg("join_instance error E ~p: R ~p",[E,R]),
			error
	end.
	
leave_instance(RoleId,MapProcName)->
	try
		gen_server:call(MapProcName,{role_leave,RoleId})
	catch
		E:R->
			slogger:msg("leave_instance RoleId ~p MapProcName~p error ~p:~p ~n",[RoleId,MapProcName,E,R]),
			nothing
	end.
	
leave_instance(RoleId,MapProcName,offline)->
	try
		gen_server:call(MapProcName,{role_leave,RoleId,offline})
	catch
		E:R-> 
			slogger:msg("leave_instance offline RoleId ~p MapProcName~p error ~p:~p ~n",[RoleId,MapProcName,E,R]),
				nothing
	end.

destroy_instance(Node,Proc)->
	gs_rpc:cast(Node,Proc,{on_destroy}).

destroy_instance(Node,Proc,TimeMs)->
	gs_rpc:cast(Node,Proc,{on_destroy,TimeMs}).

get_instance_id(MapProcName)->
	try
		gen_server:call(MapProcName,{get_instance_id})
	catch
		E:R-> 
			slogger:msg("get_instance_id MapProcName~p error ~p:~p ~n",[MapProcName,E,R]),
			[]
	end.
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([MapProcName, {{LineId,MapId}, Tag}])->
	process_flag(trap_exit, true),
	AOIdb = ets:new(MapProcName, [set, public, named_table]),
	NpcInfoDB = npc_op:make_npcinfo_db_name(MapProcName),
	ets:new(NpcInfoDB, [set,public,named_table]),
	put(npcinfo_db,NpcInfoDB),	
	npc_sup:start_link(MapId,MapProcName,NpcInfoDB),
	case Tag of
			map->
				Creation = [],
				ProtoId = [],
				ProtoInfo = [],
				InstanceId = [],
				CreatorTag = {?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM};
			{Creation,ProtoId,CreatorTag}->						%%instance
				ProtoInfo = instance_proto_db:get_info(ProtoId),
				case instance_proto_db:get_type(ProtoInfo) of
					?INSTANCE_TYPE_TANGLE_BATTLE->
						InstanceId = atom_to_list(MapProcName);
					?INSTANCE_TYPE_YHZQ->
						InstanceId = atom_to_list(MapProcName);
					?INSTANCE_TYPE_GUILDBATTLE->
						InstanceId = atom_to_list(MapProcName);
					?INSTANCE_TYPE_JSZD->
						InstanceId = atom_to_list(MapProcName);
					?INSTANCE_TYPE_GUILD->
						InstanceId = atom_to_list(MapProcName);
					?INSTANCE_TYPE_LOOP_INSTANCE->
						InstanceId = atom_to_list(MapProcName);
					_->
						InstanceId = instance_op:make_id_by_creationtag(Creation,ProtoId)
				end
	end,
	StartNpcTag = 
	case map_info_db:get_map_info(MapId) of
		[]->
			true;
		MapInfo->
			case map_info_db:get_is_instance(MapInfo) of
				1->
					LineId =:= -1;
				0->
					true
			end
	end,
	if
		StartNpcTag->
			NpcManagerProc = npc_manager:make_npc_manager_proc(MapProcName),
			NpcInfos = npc_db:get_creature_spawns_info(MapId) ++
							%%special line monster for map	   
							npc_db:get_creature_spawns_info({LineId,MapId}),
			
			lists:foreach(fun(NpcInfo)->
				      NpcId = npc_db:get_spawn_id(NpcInfo),
					  case npc_db:get_born_with_map(NpcInfo) of
						  1->
					 		npc_manager:add_npc_by_option(NpcManagerProc,NpcId,LineId,MapId,NpcInfo,CreatorTag);
						  0->
							  nothing
					 end
				  end,NpcInfos);
		true->
			nothing	
	end,
	MapDb = mapdb_processor:make_db_name(MapId),
	case ets:info(MapDb) of
		undefined->
			ets:new(MapDb, [set,named_table]),	%% first new the database, and then register proc
			case map_info_db:get_map_info(MapId) of
				[]->
					nothing;
				MapInfo_->
					MapDataId = map_info_db:get_serverdataname(MapInfo_),
					map_db:load_map_ext_file(MapDataId,MapDb),
					map_db:load_map_file(MapDataId,MapDb)
			end;
		_->
			nothing
	end,
	if
		InstanceId =/=[]->
			instance_pos_db:reg_instance_pos_to_mnesia(InstanceId,Creation,now(),true,node(),MapProcName,MapId,ProtoId,[]),
			put(instanceid,InstanceId),
			case ProtoInfo of
				[]->
					slogger:msg("error instance proto info ProtoId ~p,Del_Time default:60000 ~n",[ProtoId]),
					DurationTime = 60000;
				_->
					DurationTime =	instance_proto_db:get_duration_time(ProtoInfo)
			end;
		true->
			DurationTime = 0,
			put(instanceid,[])
	end,
	put(map_start_time,timer_center:get_correct_now()),
	if
		DurationTime =/= 0->
			erlang:send_after(DurationTime,self(),{on_destroy});
		true->
			nothing
	end,
	{ok, #state{mapinfo={LineId,MapId}, aoidb=AOIdb, mapproc=MapProcName}}.

%%lefttime
handle_call(get_instance_details,_From,State) ->
	Reply = 
	case get(instanceid) of
		[]->		%%not instance
			{0,0};
		_->
			StartTime = get(map_start_time),
			trunc(timer:now_diff(timer_center:get_correct_now(),StartTime)/1000000)
	end,
	{reply, Reply,State};
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call({get_instance_id}, _From,ProcState) ->
	Reply = get(instanceid),
	{reply, Reply,ProcState};

handle_call({role_come,RoleId}, _From,ProcState) ->	
	case  get(instanceid) of
		[]->
			Reply = error;
		InstanceId-> 
			case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of			
				[]->
					Reply = error;
				{Id,Creation,StartTime,CanJoin,InstanceNode ,Pid,MapId,Protoid,Members}->
					if
						not CanJoin->
							Reply = error;
						true->
							case lists:member(RoleId,Members) of
								true->
									nothing;
								false->
									instance_pos_db:reg_instance_pos_to_mnesia(Id,Creation,StartTime,CanJoin,InstanceNode ,Pid,MapId,Protoid,[RoleId|Members])
							end,
							Reply = {ok,StartTime}
					end
			end
	end,
	{reply, Reply,ProcState};

handle_call({role_leave,RoleId}, _From,ProcState) ->
	case  get(instanceid) of
		[]->
			Reply = error;
		InstanceId-> 
			case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of			
				[]->
					Reply = error;
				{Id,Creation,StartTime,CanJoin,InstanceNode ,Pid,MapId,Protoid,Members}->
					Reply = ok,
					NewMemerbList = lists:delete(RoleId, Members),
					instance_pos_db:reg_instance_pos_to_mnesia(Id,Creation,StartTime,CanJoin,InstanceNode ,Pid,MapId,Protoid,NewMemerbList),
					case NewMemerbList of
						[]->
							ProtoInfo = instance_proto_db:get_info(Protoid),
							case ProtoInfo of
								[]->
									self() ! {on_destroy};
								_->
									InsType = instance_proto_db:get_type(ProtoInfo),
									if
										(InsType=:= ?INSTANCE_TYPE_SINGLE )or (InsType=:=?INSTANCE_TYPE_GROUP) or (InsType=:=?INSTANCE_TYPE_LOOP_TOWER)->
											self() ! {on_destroy};
										true->
											nothing
									end
							end;
						_->
							nothing
					end
			end
	end,
	{reply, Reply, ProcState};

%%if last one is offline ,not delete the instance
handle_call({role_leave,RoleId,offline}, _From,ProcState) ->
	case  get(instanceid) of
		[]->
			Reply = error;
		InstanceId-> 
			case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of			
				[]->
					Reply = error;
				{Id,Creation,StartTime,CanJoin,InstanceNode ,Pid,MapId,Protoid,Members}->
					Reply = ok,
					NewMemerbList = lists:delete(RoleId, Members),
					instance_pos_db:reg_instance_pos_to_mnesia(Id,Creation,StartTime,CanJoin,InstanceNode ,Pid,MapId,Protoid,NewMemerbList),
					case NewMemerbList of
						[]->
							ProtoInfo = instance_proto_db:get_info(Protoid),
							case ProtoInfo of
								[]->
									self() ! {on_destroy};
								_->
									InsType = instance_proto_db:get_type(ProtoInfo),
									if
										(InsType=:= ?INSTANCE_TYPE_LOOP_TOWER )->
											self() ! {on_destroy};
										true->
											nothing
									end
							end;
						_->
							nothing
					end
			end
	end,
	{reply, Reply,ProcState};
  
handle_call({join_grid,Grid,CreatureId}, _From,#state{mapproc=MapProcName}=ProcState) ->
	case creature_op:what_creature(CreatureId) of
		role->
			case ets:lookup(MapProcName, Grid) of
				[] ->										
					ets:insert(MapProcName, {Grid, [],[CreatureId],true});			
				[{_, _,Roles,_}] ->			
					case lists:member(CreatureId,Roles) of
						false-> 
							ets:update_element(MapProcName,Grid,{?ETS_POS_ROLES,[CreatureId]++Roles});
						_->
							nothing
					end												
			end;
		npc->
			case ets:lookup(MapProcName, Grid) of
				[] ->						
					ets:insert(MapProcName, {Grid, [CreatureId],[],false});			
				[{_, Units,_,_}] ->	
					case lists:member(CreatureId,Units) of
						false-> 
							ets:update_element(MapProcName,Grid,{?ETS_POS_UNITS,[CreatureId]++Units});
						_->
							nothing
					end															
			end
	end,	
  	Reply = ok,
	{reply, Reply,ProcState}; 

handle_call({leave_grid,Grid,CreatureId}, _From,#state{mapproc=MapProcName}=ProcState) ->
  	case ets:lookup(MapProcName, Grid) of
		[] ->
			nothing;			
		[{_,Units,Roles,_}] ->
			case creature_op:what_creature(CreatureId) of
				role ->																												
					ets:update_element(MapProcName,Grid,{?ETS_POS_ROLES,lists:delete(CreatureId,Roles)});
				npc->
					ets:update_element(MapProcName,Grid,{?ETS_POS_UNITS,lists:delete(CreatureId,Units)})
			end					
	end,
	Reply = ok,
	{reply, Reply, ProcState};
  
handle_call(Request, From, State) ->
	Reply = ok,
	{reply, Reply, State}.


%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
	{noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({on_destroy,WaitTime},ProcState)->
	erlang:send_after(WaitTime,self(),{on_destroy}),
	case  get(instanceid) of
		[]->
			nothing;
		InstanceId->
			case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of
				[]->
					nothing;
				{Id,Creation,StartTime,_CanJoin,InstanceNode ,Pid,MapId,Protoid,Members}->
					instance_pos_db:reg_instance_pos_to_mnesia(Id,Creation,StartTime,false,InstanceNode ,Pid,MapId,Protoid,Members),
					Msg = role_packet:encode_instance_end_seconds_s2c(trunc(WaitTime/1000)), 
					role_pos_util:send_to_clinet_list(Msg, Members)
			end
	end,
	{noreply,ProcState};

handle_info({on_destroy},#state{mapproc=MapProcName}=ProcState)->
	case  get(instanceid) of
		[]->
			nothing;
		InstanceId->
			case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of
				[]->
					nothing;
				{Id,Creation,StartTime,CanJoin,InstanceNode ,Pid,MapId,Protoid,Members}->
					lists:foreach(fun(MemberId)->
						RoleProc = role_op:make_role_proc_name(MemberId),
						send_kick_out(RoleProc,MapProcName)
					end,Members),
					if
						CanJoin->
							instance_pos_db:reg_instance_pos_to_mnesia(Id,Creation,StartTime,false,InstanceNode ,Pid,MapId,Protoid,[]);
						true->
							nothing
					end,
					erlang:send_after(10000,self(),{destory_self})
			end
	end,
	{noreply,ProcState};

handle_info({destory_self},#state{mapproc=MapProcName}=ProcState)->
	case  get(instanceid) of
		[]->
			nothing;
		InstanceId->
			instance_pos_db:unreg_instance_pos_to_mnesia(InstanceId),
			npc_manager:remove_all_npc(npc_manager:make_npc_manager_proc(MapProcName)),
			map_manager:stop_instance(node(),MapProcName),
			instanceid_generator:safe_turnback_proc(MapProcName)
	end,
	{stop,normal,ProcState};

handle_info(Info, State) ->
	{noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason,#state{mapproc=MapProcName}=ProcState) ->
	case  get(instanceid) of
		[]->
			nothing;
		InstanceId->
			case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of
				[]->
					nothing;
				_->
					instance_pos_db:unreg_instance_pos_to_mnesia(MapProcName),
					instanceid_generator:safe_turnback_proc(MapProcName)
			end
	end,
	ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
	{ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
send_kick_out(Proc,MapProcName)->
	try
		Proc ! {kick_from_instance,MapProcName}
	catch
		E:R->slogger:msg("MapProcName~p send_kick_out Proc ~p ~p~p ~p ~n",[MapProcName,Proc,E,R,erlang:get_stacktrace()])
	end.