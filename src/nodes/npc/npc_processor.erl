%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-5-21
%%% -------------------------------------------------------------------
-module(npc_processor).

-behaviour(gen_fsm).
%% --------------------------------------------------------------------
%% External exports
-define(NPCID_DB,npcid_db).
-define(NPCID_MEM,npcid_mem).

-include("ai_define.hrl").

%% gen_fsm callbacks
-export([init/1, handle_event/3,
	 handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).

-record(state, {}).

%% state:init_npc,
%%      enter_map,
%%      aliving,
%%      dead,
%%      corpsedisappears,

-export([enter_map/2,gaming/2,deading/2,hiden/2,attack/2,reseting/2,singing/2]).

-export([start_link/5]).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("map_info_struct.hrl").
-include("common_define.hrl").

-compile(export_all).


%% ====================================================================
%% External functions
%% ====================================================================

start_link(MapProc,NpcId,NpcManager,NpcInfo,CreateArg)->
	gen_fsm:start_link(?MODULE,[NpcId, NpcManager, MapProc,NpcInfo,CreateArg],[]).

forced_leave_map(NpcPId)->
	try
		gen_fsm:sync_send_all_state_event(NpcPId, {forced_leave_map})
	catch
		E:R->slogger:msg("forced_leave_map Error ~p : ~p ~n",[E,R]),error
	end.
let_other_say(NpcPid,Dialogues)->
	NpcPid ! {let_other_say,Dialogues}.
	
%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok, StateName, StateData}          |
%%          {ok, StateName, StateData, Timeout} |
%%          ignore                              |
%%          {stop, StopReason}
%% --------------------------------------------------------------------
init([NpcId,NpcManager,MapProc,NpcSpwanInfo,CreateArg]) ->
	timer_center:start_at_process(),
	%%璁剧疆鍒濆鍖栦俊鎭�
	npc_op:init(NpcSpwanInfo, MapProc,NpcManager,CreateArg),
	%%杩欎釜鍦版柟涓嶈兘鐩存帴杩涘湴鍥�.鍥犱负鏄湴鍥捐繘鎶妌pc鍚屾鍚姩鐨�
	util:send_state_event(self(), {position}),
	{ok, enter_map, #state{}}.

enter_map({position},StateData)->
	%%鍚戝湴鍥剧殑Grid娉ㄥ唽
	NpcInfo = get(creature_info),
	MapInfo = get(map_info),
	npc_op:join(NpcInfo, MapInfo),
	npc_op:perform_creature_duty(),
	{next_state, gaming, StateData}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鐘舵�侊細绔欑珛
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 浜嬩欢锛氬紑濮嬬Щ鍔�;
%%      鐢变簬鏄疦PC绉诲姩锛屾墍浠ユ垜浠笉鐢–heckPath锛屽彧闇�瑕侀�氱煡鐩稿簲鐨勭帺瀹跺嵆鍙�
gaming({start_idle_walk}, StateData) ->
	npc_movement:proc_idle_walk(),
	{next_state, gaming, StateData};

gaming({perform_creature_duty}, StateData)->
	npc_op:perform_creature_duty(),
	{next_state, gaming, StateData};

%%婵�娲�
gaming({activate}, StateData)->
	npc_op:activate(),
	{next_state, gaming, StateData};	
	
gaming({hibernate}, StateData)->
	npc_op:hibernate(),
	{next_state, gaming, StateData};
	
gaming({provoke,ProvokerId}, StateData) ->
	npc_op:provoke(ProvokerId),
	{next_state, attack, StateData};

gaming({alert_heartbeat}, StateData) ->
	npc_op:alert_heartbeat(),
	{next_state, gaming, StateData};

gaming({do_idle_action},StateData) ->
	npc_ai:do_idle_action(),
	{next_state, gaming, StateData};
	
gaming({enemy_found,_InrangeEnemy},StateData)->
	npc_op:update_attack(),
	{next_state,attack,StateData};
	
gaming({follow_heartbeat},StateData)->	
	npc_op:follow_target(),
	{next_state,gaming,StateData};
	
gaming({call_ai_event,AiEvent,RoleId},StateData)->
	npc_ai:call_function(AiEvent,RoleId),
	{next_state,gaming,StateData};

gaming({call_you_help,CreatureId,TargetId},StateData)->
	npc_ai:do_help(CreatureId,TargetId),
	{next_state,attack,StateData};
	
gaming(_Event, StateData) ->
	{next_state, gaming, StateData}.

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鐘舵�侊細鎴樻枟鐘舵��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
attack({attack_heartbeat},StateData)-> %%鏀诲嚮涓�涓�
	npc_op:attack(get(targetid)),
	{next_state, attack, StateData};

attack({singing},StateData)-> %%寮�濮嬪悷鍞辨妧鑳�,杞悜singing鐘舵��
	{next_state, singing, StateData};	

attack({reset},StateData)-> %%reset
	npc_op:npc_reset(), 
	{next_state, reseting, StateData}; 

attack(_Event, StateData) ->
	{next_state, attack, StateData}.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鐘舵�侊細鍚熷敱鐘舵�侊紝涓巃tack鏉ュ洖鍒囨崲
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
singing({reset},StateData)-> 
	npc_op:process_cancel_attack(get(id),move),
	npc_op:npc_reset(),
	{next_state, reseting, StateData}; 
 
singing({sing_complete, TargetID, SkillID, SkillInfo, FlyTime}, State) ->
	NpcInfo = get(creature_info),
	npc_op:process_sing_complete(NpcInfo, TargetID, SkillID, SkillInfo, FlyTime),  %%sing_complete鍚庝細缁х画瑙﹀彂attackheartbeat
	{next_state, attack, State};
 
singing({interrupt_by_buff},State) ->
	SelfId = get(id),
	npc_op:process_cancel_attack(SelfId, interrupt_by_buff),    
	npc_op:update_attack(),
	{next_state, attack, State};	 
  
singing(_Event, StateData) ->
	{next_state, singing, StateData}.
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鐘舵�侊細reseting,涓嶆帴鏀朵换浣曟寫琛�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
reseting({reset_fin},StateData)->
	npc_action:on_reset_finish(),
	{next_state, gaming , StateData};	

reseting(_Event, StateData) ->
	{next_state, reseting, StateData}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鐘舵��: 姝讳骸(鍩庝腑鐨凬PC鏄惁鏈夎繖涓姸鎬佸憿)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deading({leavemap},StateData)->
	npc_op:proc_leave_map(),
	{next_state, deading, StateData};

%%琚枈鍑烘潵鐨�.
deading({respawn_by_call},StateData)->
	case get(is_in_world) of
		true->
			case get(respawn_timer) of
				 undefined->
				 	nothing;
				 Timer->
				 	gen_fsm:cancel_timer(Timer)
			end,
			creature_op:leave_map(get(creature_info),get(map_info));
		false->
			nothing
	end,			
	npc_op:npc_respawn(),
	npc_op:join(get(creature_info), get(map_info)),
	npc_op:call_duty(),
	{next_state, gaming, StateData};

%%respawn,
deading({respawn},StateData)->
	put(respawn_timer,undefined),
	npc_op:npc_respawn(),
	npc_op:join(get(creature_info), get(map_info)),
	npc_op:call_duty(),
	{next_state, gaming, StateData};
	
deading(_Msg,StateData)->
	{next_state, deading, StateData}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鐘舵��: 闅愯韩鐘舵��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hiden(_Msg,StateData)->
	{next_state, enter_map, StateData}.

%% --------------------------------------------------------------------
%% Func: handle_event/3
%% Returns: {next_state, NextStateName, NextStateData}          |
%%          {next_state, NextStateName, NextStateData, Timeout} |
%%          {stop, Reason, NewStateData}
%% --------------------------------------------------------------------
handle_event(_Event, StateName, StateData) ->
    {next_state, StateName, StateData}.

%% --------------------------------------------------------------------
%% Func: handle_sync_event/4
%% Returns: {next_state, NextStateName, NextStateData}            |
%%          {next_state, NextStateName, NextStateData, Timeout}   |
%%          {reply, Reply, NextStateName, NextStateData}          |
%%          {reply, Reply, NextStateName, NextStateData, Timeout} |
%%          {stop, Reason, NewStateData}                          |
%%          {stop, Reason, Reply, NewStateData}
%% --------------------------------------------------------------------

handle_sync_event({get_state}, _From, StateName, StateData) ->
    Reply = StateName,
    {reply, Reply, StateName, StateData};	

handle_sync_event({forced_leave_map},_From, StateName, StateData) ->
	npc_op:proc_force_leave_map(),
    {reply, ok, StateName, StateData};  
	
handle_sync_event(Info, _From, StateName, StateData) ->
	Reply = npc_script:run_script(proc_special_msg,[Info]),
    {reply, Reply, StateName, StateData}.

%% --------------------------------------------------------------------
%% Func: handle_info/3
%% Returns: {next_state, NextStateName, NextStateData}          |
%%          {next_state, NextStateName, NextStateData, Timeout} |
%%          {stop, Reason, NewStateData}
%% --------------------------------------------------------------------
handle_info({follow_me,RoleId}, StateName, StateData) ->
	npc_op:start_follow_creature(RoleId),
	{next_state,StateName, StateData}; 

handle_info({call_ai_event,Event}, StateName, StateData) ->
	npc_ai:call_function_no_state(Event),	
	{next_state,StateName, StateData}; 
	
handle_info({move_heartbeat, NewPos}, StateName, StateData) ->
	case (StateName =:= gaming) or (StateName =:= reseting) or (StateName =:= attack) of
		true->
			NpcInfo = get(creature_info),
			MapInfo = get(map_info),	
			npc_movement:move_heartbeat(NpcInfo, MapInfo, NewPos);
		_->
			nothing
	end,		
    {next_state,StateName, StateData}; 
    
handle_info({run_away_to_pos,Pos}, StateName, StateData) ->
	case (StateName =:= gaming) or (StateName =:= attack) of
		true->
			npc_op:run_away_to_pos(Pos);
		_->
			nothing
	end,		
    {next_state,gaming, StateData};    

handle_info({forced_leave_map}, StateName, StateData) ->
	npc_op:proc_force_leave_map(),
    {next_state,StateName, StateData}; 

handle_info({leave_map}, _StateName, StateData) ->	
	npc_op:proc_leave_map(),
	{next_state,deading, StateData};
	
handle_info({other_into_view, OtherId}, StateName, StateData) ->
	case creature_op:get_creature_info(OtherId) of
		undefined ->
			nothing;
		OtherInfo->			
			creature_op:handle_other_into_view(OtherInfo)
	end,	
	{next_state, StateName, StateData};

handle_info({other_outof_view, OtherId}, StateName, StateData) ->
	case npc_op:other_outof_view(OtherId) of 
		out_of_view ->
			if
				( StateName =:= attack) or (StateName=:= singing)->
					HatredOp = get(hatred_fun),
					case npc_hatred_op:HatredOp(other_outof_bound,OtherId) of 
						reset ->
								npc_op:npc_reset(),
								{next_state, reseting, StateData}; 
						nothing_todo ->
								{next_state, attack, StateData};
						update_attack ->
								npc_op:update_attack(),
								{next_state,attack, StateData}
					end;
				true->
					{next_state, StateName, StateData}
			end;
		_->		 
			{next_state, StateName, StateData}
	end;
	


handle_info({respawn}, StateName, StateData) ->
	util:send_state_event(self(),{respawn}),
	{next_state, StateName, StateData};

handle_info({other_be_killed,{PlayerId, _,_,_,Pos}}, StateName, StateData) ->
	npc_op:other_be_killed(PlayerId,Pos),
	if
		(StateName =:= singing) or (StateName =:= attack)->
			HatredOp = get(hatred_fun),
			case npc_hatred_op:HatredOp(other_dead,PlayerId) of 
				reset ->
						case (StateName=:=singing)of
							true->  
								npc_op:process_cancel_attack(get(id),move);
							_->
								nothing
						end,
						npc_op:npc_reset(),
						{next_state, reseting, StateData}; 
				nothing_todo ->							 
						{next_state, StateName, StateData};
				update_attack ->
						case (StateName=:=singing)of
							true->  
								npc_op:process_cancel_attack(get(id),move);
							_->
								nothing
						end,
						npc_op:update_attack(),
						{next_state,attack, StateData}
			end;
		true->
			nothing,
			{next_state, StateName, StateData}	
	end;

%%鍦ㄥ尯鍩熻鍐峰嵈鏃�,浼氭敹鍒癶ibernate
handle_info({hibernate}, StateName, StateData) ->
	if 		%%鍏朵粬鐘舵�佺殑浼氫緷闈爌erform_creature_duty閲屽幓hibernate
		StateName =:= gaming->	
			util:send_state_event(self(), {hibernate});
		true->
			nothing
	end,
	{next_state, StateName, StateData}; 		
	
handle_info({other_be_attacked, AttackInfo}, StateName, State) ->
	{EnemyId,_,_, _, _,_} = AttackInfo,
	if 
		(StateName =:= gaming) or (StateName =:= attack) or (StateName =:= singing)->
			SelfInfo = get(creature_info),
			case npc_op:other_be_attacked(AttackInfo, SelfInfo) of
				deading -> %%Npc姝讳簡
						Status = deading;				
				{be_attacked,Hatred} ->
						case (EnemyId =/= get_id_from_npcinfo(SelfInfo)) and (Hatred=/=0) of
							 true ->						
								HatredOp = get(hatred_fun),
								case  npc_hatred_op:HatredOp(is_attacked,{EnemyId,Hatred}) of
									update_attack ->
										if
											(StateName =:= singing)->
												Status = singing;
											true->
												Status = attack,
												npc_op:update_attack()
										end;
									nothing_todo -> 
										Status = StateName
								end;
							_->
								Status = StateName
						end,
						npc_ai:handle_event(?EVENT_BE_ATTACK);
				_ -> 
					slogger:msg("attack:other_be_attacked error~n"),Status = attack
			end;
		true->
			Status = StateName,
			nothing
	end,
	{next_state, Status, State};
	
%% 浜嬩欢锛氱敤浜庤繘琛宐uffer鐨勮绠桾ODO:浜ょ粰鍚勪釜鐘舵�佸鐞�?
handle_info( {buffer_interval, BufferInfo}, StateName, State) ->
	if 
		(StateName =:= gaming) or (StateName =:= attack) or (StateName =:= singing)->
			case buffer_op:do_interval(BufferInfo) of
				{remove,{BufferId,BufferLevel}}-> 
					NextState = StateName,
					npc_op:remove_buffer({BufferId,BufferLevel});
				{changattr,{BufferId,_Level},BuffChangeAttrs}->
					%%澶勭悊鍙樺寲灞炴��
					NextState = 
					case effect:proc_buffer_function_effects(BuffChangeAttrs) of
						[]->
							StateName;
						ChangedAttrs->
							NpcId = get(id),
							npc_op:update_npc_info(NpcId,get(creature_info)),
							npc_op:broad_attr_changed(ChangedAttrs),
							%%骞挎挱褰撳墠buff褰卞搷
							BuffChangesForSend = lists:map(fun({AttrTmp,ValueTmp})-> role_attr:to_role_attribute({AttrTmp,ValueTmp}) end,BuffChangeAttrs),
							Message = role_packet:encode_buff_affect_attr_s2c(NpcId,BuffChangesForSend),
							npc_op:broadcast_message_to_aoi_client(Message),
							%%妫�鏌ヤ竴涓嬫湁娌℃湁褰卞搷鍒拌閲�,濡傛灉鏈夌殑璇�,鐪嬫槸鍚﹀鑷存鎺�
							case lists:keyfind(hp,1,ChangedAttrs) of
								{_,HPNew}->
									if
										HPNew =< 0 ->
											{EnemyId,_EnemyName} = buffer_op:get_buff_casterinfo(BufferId),
											%% 琚潃瀹充簡	
											case creature_op:get_creature_info(EnemyId) of
												undefined->				%%鍑舵墜宸茬粡涓嶅湪浜�?
													npc_op:on_dead(get(creature_info));
												KillerInfo->
													npc_op:on_dead(KillerInfo)
											end,		
											deading;																				
										true->					
											StateName					
									end;
								false ->
									StateName
							end
					end;
				_Any -> 
					NextState = StateName
			end;
		true->
			NextState = StateName
	end,
	{next_state, NextState, State};

%%CasterInfo:{Id,Name}
handle_info({be_add_buffer, Buffers,CasterInfo}, StateName, StateData) ->
	if 
		(StateName =:= gaming) or (StateName =:= attack) or (StateName =:= singing)->
			npc_op:be_add_buffer(Buffers,CasterInfo);
		true->
			nothing
	end,
	{next_state, StateName, StateData};	

handle_info({let_other_say,Dialogues},StateName, StateData) ->
	normal_ai:say(Dialogues),
	{next_state, StateName, StateData};

handle_info({get_state}, StateName, StateData) ->	
	io:format("get_state ~p~n",[StateName]),	
	{next_state, StateName, StateData};
	
handle_info({provoke,ProvokerId}, StateName,StateData) ->
	gen_fsm:send_event(self(),{provoke,ProvokerId}),
	{next_state, StateName, StateData};
	
handle_info({apply_next_ai,NextAi},StateName,StateData) ->
	npc_ai:handle_apply_next_ai(NextAi),
	{next_state, StateName, StateData};
	
handle_info({christmas_activity,Msg},StateName,StateData) ->
	npc_christmas_tree:proc_msg(Msg),
    {next_state, StateName, StateData};

handle_info(Info, StateName, StateData) ->
	npc_script:run_script(proc_special_msg,[Info]),
    {next_state, StateName, StateData}.

%% --------------------------------------------------------------------
%% Func: terminate/3
%% Purpose: Shutdown the fsm
%% Returns: any
%% --------------------------------------------------------------------
terminate(Reason, _StateName, _StatData) ->
	slogger:msg("npc_processor terminate Reason~p Id ~p CreatureInfo ~p ~n",[Reason,get(id),get(creature_info)]),
	NpcInfo = get(creature_info),
	MapInfo = get(map_info),
	creature_op:leave_map(NpcInfo,MapInfo),
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/4
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState, NewStateData}
%% --------------------------------------------------------------------
code_change(_OldVsn, StateName, StateData, _Extra) ->
    {ok, StateName, StateData}.


get_option_value(Key,Options)->
	case lists:keyfind(Key, 1, Options) of
		false-> error;
		{_,OptValue}->OptValue
	end.

make_dialog_beam(NpcId)->
	list_to_atom(lists:append(["npc_dialog_",util:make_int_str4(NpcId)])).

has_type(Type)->
	lists:member(Type,get(type)).
