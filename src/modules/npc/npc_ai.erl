%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_ai).
-compile(export_all).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("base_define.hrl").
-include("ai_define.hrl").

%%ActionList:{module,action,time,Args} 正常情况下npc的逻辑{行为,过期时间,参数}
%%normal_cur_act: {当前处在第几段,此段开始时间,Timer}
%%{ai类型,触发事件,几率,最大次数,技能id,冷却时间,喊话列表,上次释放时间,当前次数}
%%next_ai_agent:连招:[]/{AgentId,延迟时间ms}

-record(ai_agent,{key,type,events,conditions,rate,max_count,skillid,target,cooldown,msgs,script,next_ai,last_time,cur_count}).

init(ProtoId,ActionList)->
	put(normal_action_list,ActionList),
	put(normal_cur_act,{0,{0,0,0},0}),
	AllAgents = ai_agents_db:get_all_agents(ProtoId),
	put(my_ai_agents,lists:map(fun(AgentInfo)-> 
						make_ai_agent(AgentInfo) 
	end,AllAgents) ).

respawn()->
	put(my_ai_agents,lists:map(fun(Agent)->Agent#ai_agent{cur_count = 0,last_time = {0,0,0}} end,get(my_ai_agents))).

do_idle_action()->	
	case npc_op:should_be_hibernate() of
		false->
			case get(normal_cur_act) of
				{0,_,_}->					%%first
					case get(normal_action_list) of
						[]->
							nothing;
						_->
							apply_next_action()
					end;
				{LastState,LastTime,_}->
					{_,_,Dutime,_} = lists:nth(LastState,get(normal_action_list)),
					Overtime = trunc(timer:now_diff(now(),LastTime)/1000),
					case Overtime >= Dutime of
						true->		%%next
							apply_next_action();
						_->	
							Timer = gen_fsm:send_event_after(Dutime - Overtime,{do_idle_action}),
							put(normal_cur_act,{LastState,LastTime,Timer})
					end
			end;
		_->
			self() ! {hibernate}
	end.	
	
make_ai_agent(AgentInfo)->
	#ai_agent{
		key = ai_agents_db:get_id(AgentInfo),
		type =  ai_agents_db:get_type(AgentInfo),
		events = ai_agents_db:get_events(AgentInfo),
		conditions = ai_agents_db:get_conditions(AgentInfo),
		rate = ai_agents_db:get_chance(AgentInfo),
		max_count = ai_agents_db:get_maxcount(AgentInfo),
		skillid = ai_agents_db:get_skill(AgentInfo),
		target = ai_agents_db:get_target(AgentInfo),
		cooldown = ai_agents_db:get_cooldown(AgentInfo),
		msgs = ai_agents_db:get_msgs(AgentInfo),
		script = ai_agents_db:get_script(AgentInfo),
		next_ai = ai_agents_db:get_next_ai(AgentInfo),
		last_time = {0,0,0},
		cur_count = 0
	}.
	
handle_event(Type)->
	AdaptAgents = lists:filter(fun(AgentInfo)->
						get_adapt_ai_agent(Type,AgentInfo)	end,get(my_ai_agents)),
	if
		AdaptAgents =:= []->
			nothing;
		true->
			Agent = lists:nth(random:uniform(erlang:length(AdaptAgents)),AdaptAgents),
			apply_aigent(Agent)
	end.
			
handle_apply_next_ai(AgentId)->			
	case lists:keyfind(AgentId,#ai_agent.key,get(my_ai_agents)) of
		false->
			nothing;
		Agent->	
			apply_aigent(Agent)
	end.
	
check_target(TargetId)->
	(creature_op:is_in_aoi_list(TargetId) or (TargetId=:= get(id))).

apply_aigent(Agent)->
	Key = erlang:element(#ai_agent.key,Agent),
	Count = erlang:element(#ai_agent.cur_count,Agent),
	case erlang:element(#ai_agent.type,Agent) of
		?AI_TYPE_HELP->
			Applyed = true,
			call_help();
		?AI_TYPE_SPELL->
			case erlang:element(#ai_agent.skillid,Agent) of
				0->
					Applyed = true;			%%喊话
				SkillId->
					case is_skill_can_use(SkillId) of
						true->
							case get(next_skill_and_target) of						
								{0,_}->											%%当前无技能
									TargetType = erlang:element(#ai_agent.target,Agent),
									case TargetType of
										?AI_TYPE_TARGET_NULL->
											TargetId = get(id);
										?AI_TYPE_TARGET_ENEMY->
											TargetId = get(targetid);
										?AI_TYPE_TARGET_SELF->
											TargetId = get(id);
										?AI_TYPE_TARGET_OWNNER->	
											TargetId = get(ownnerid);
										?AI_TYPE_TARGET_MASTER->
											TargetId = get(creator_id);
										?AI_TYPE_TARGET_HATRED_RAND->
											TargetId = hatred_op:rand_target();
										?AI_TYPE_TARGET_MASTER_HATRED_FIRST->
											TargetId = hatred_op:get_other_nth_enemyid(get(creator_id),1);
										?AI_TYPE_TARGET_MASTER_HATRED_RAND->
											TargetId = hatred_op:rand_other_target(get(creator_id))
									end,
									case check_target(TargetId) of
										false->
											Applyed = false;
										_->	
											Applyed = true,
											put(next_skill_and_target,{SkillId,TargetId})
									end;
								_->												%%已有技能
											Applyed = false
							end;
						false->
							Applyed = false
					end
			end;
		?AI_TYPE_SCRIPT->
			Applyed = true,
			case erlang:element(#ai_agent.script,Agent) of
				[]->
					nothing;
				{Module,Fun,Args}->	
					exec_beam(Module,Fun,Args)
			end
	end,
	if
		Applyed->
			random_shout_to_aoi(erlang:element(#ai_agent.msgs,Agent)),
			put(my_ai_agents,lists:keyreplace(Key,#ai_agent.key,get(my_ai_agents),Agent#ai_agent{cur_count = Count+1,last_time = now()})),
			case erlang:element(#ai_agent.next_ai,Agent) of
				[]->
					nothing;
				{NextAi,Time}->
					erlang:send_after(Time,self(),{apply_next_ai,NextAi})
			end;	
		true->
			nothing
	end.	

get_adapt_ai_agent(Type,AgentInfo)->
	Events = erlang:element(#ai_agent.events,AgentInfo),
	Conditions = erlang:element(#ai_agent.conditions,AgentInfo),
	MaxCount = erlang:element(#ai_agent.max_count,AgentInfo),
	CurCount = erlang:element(#ai_agent.cur_count,AgentInfo),
	case lists:member(Type,Events) and ((CurCount<MaxCount) or (MaxCount=:=0)) of
		true->
			CheckCondtions =
				case Conditions of
					[]->
						true;
					_->	
						lists:foldl(fun({Module,Fun,Args},ReTmp)->
							if
								ReTmp->
									true;
								true->		
									case exec_beam(Module,Fun,Args) of
										true->
											true;
										_->
											false
									end	
							end end,false,Conditions)
				end,
			if
				CheckCondtions->
					LastCast = erlang:element(#ai_agent.last_time,AgentInfo),
					CoolDown = erlang:element(#ai_agent.cooldown,AgentInfo),
					case timer:now_diff(now(),LastCast) >= CoolDown*1000 of 
						true->
							RanV = random:uniform(100),
							Rate = erlang:element(#ai_agent.rate,AgentInfo),
							if
								RanV =< Rate ->
									true;
								true->
									false
							end;
						_->
							false
					end;	
				true->
					false
			end;
		_->
			false
	end.	
			
%%todo改为找一定距离里的帮手			
call_help()->
	MyInfo = get(creature_info),
	lists:foreach(fun(CreatureInfo)->
		case creature_op:get_state_from_creature_info(CreatureInfo) of
			gaming->
				call_help(CreatureInfo);
			_->
				nothing
		end
	end,creature_op:get_aoi_info_by_realation(MyInfo,friend)).	

call_help(undefined)-> nothing;
call_help(CreatureInfo)->
	Pid = creature_op:get_pid_from_creature_info(CreatureInfo),
	try
		util:send_state_event(Pid,{call_you_help,get(id),get(targetid)})
	catch
		_E:_R->
			nothing
	end.			

%%TODO:frineds?
do_help(CreatureId,TargetId)->
	HatredOp = get(hatred_fun),
	put(ownnerid,CreatureId),
	npc_hatred_op:HatredOp(call_help, TargetId),
	npc_op:update_attack().
	
clear_act()->
	clear_normal_act().

stop_cur_act()->
	case get(normal_cur_act) of
		{_,_,0}->
			nothing;
		{Sec,Time,Timer}->
			gen_fsm:cancel_timer(Timer),
			put(normal_cur_act,{Sec,Time,0})
	end.	
	
clear_normal_act()->
	case get(normal_cur_act) of
		{_,_,0}->
			put(normal_cur_act,{0,{0,0,0},0});
		{_,_,Timer}->
			gen_fsm:cancel_timer(Timer),
			put(normal_cur_act,{0,{0,0,0},0})
	end.
						
apply_next_action()->
	{CurSec,_,_} = get(normal_cur_act),
	ActList = get(normal_action_list),
	case (CurSec>= erlang:length(ActList)) or (CurSec =:= 0) of
		true->
			NextSec = 1;
		_->			
			NextSec = CurSec + 1
	end,
	{Module,Action,Dutime,Args} = lists:nth(NextSec,ActList),
	if
		Dutime=/=0->
			Timer = gen_fsm:send_event_after(Dutime,{do_idle_action}),
			put(normal_cur_act,{NextSec,now(),Timer});
		true->
			nothing
	end,	
	exec_beam(Module,Action,Args).

%%有人使用功能,TODO:如果是正常状态,打断当前动作,例如移动
call_function(AiEvent,RoleId)->
	put(targetid,RoleId),
	handle_event(AiEvent).

call_function_no_state(AiEvent)->
	handle_event(AiEvent).

%%Type:dialog/quest_finished
call_npc_function(_Type,undefined,_RoleId)->
	nothing;
call_npc_function(Type,NpcInfo,RoleId)->
	Pid = creature_op:get_pid_from_creature_info(NpcInfo),
	try
		util:send_state_event(Pid,{call_ai_event,Type,RoleId})
	catch
		_E:_R->nothing
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%距离判定
%%%%返回：距离的平方 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_distance_pow(PosMy,PosEnemy)->
	{Myx,Myy} = PosMy,
	{Enemyx,Enemyy} = PosEnemy,
	erlang:max(erlang:abs(Myx - Enemyx),erlang:abs(Myy - Enemyy)).
%%	(math:pow(Myy - Enemyy, 2) + math:pow(Myx - Enemyx, 2)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%警戒距离判定
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
is_in_alert_range(PosMy,PosEnemy)->
	try
		util:is_in_range(PosMy,PosEnemy,get(alert_radius))
	catch
		_:_-> false
	end.	

is_in_attack_range(PosMy,PosEnemy)->
	try
		util:is_in_range(PosMy,PosEnemy, get(attack_range))
	catch
		_:_-> false
	end.	

is_in_follow_range(PosMy,PosEnemy)->
	try
		util:is_in_range(PosMy,PosEnemy,?NPC_FOLLOW_DISTANCE)
	catch
		_:_-> false
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%警戒判定，返回警戒范围内的所有敌对阵营玩家
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
update_range_alert()->
	creature_op:get_nearest_from_aoi_by_radius(get(creature_info),enemy,get(alert_radius)).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%边界判定
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
is_outof_bound({MyX,MyY})-> %%按正方形算
	Bound = get(bounding_radius),
	{BornX,BornY} = get(bornposition),
	((MyY >= BornY + Bound) or ( MyY =< BornY - Bound ) or (MyX >= BornX + Bound) or (MyX =< BornX - Bound)).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%技能选择
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
choose_skill(SelfInfo,EnemyInfo)->
	case get(npc_script) of
		[]->			
			handle_event(?EVENT_ATTACK);
		_->		%%脚本优先取
			case npc_script:run_script(choose_skill,[SelfInfo,EnemyInfo]) of
				[]->
					handle_event(?EVENT_ATTACK);
				{SkillID,TargetId}->
					put(next_skill_and_target,{SkillID,TargetId})
			end					
	end,
	case get(next_skill_and_target) of
		{0,_}->					%%未取到技能
			case get_skilllist_from_npcinfo(SelfInfo) of
				[]->			%%无技能?
					put(next_skill_and_target,{0,get(targetid)});
				[{SkillIDNormal,_,_}|_T]->	
					put(next_skill_and_target,{SkillIDNormal,get(targetid)})
			end;
		_->
			nothing	
	end.				

is_skill_can_use(SkillId)->
	case lists:keyfind(SkillId,1,get_skilllist_from_npcinfo(get(creature_info))) of
		false->
			false;
		{SkillId,SkillLevel,LastCastTime}-> 
			CoolDown = skill_db:get_cooldown(skill_db:get_skill_info(SkillId,SkillLevel)),
			timer:now_diff(now(),LastCastTime) >= CoolDown*1000
	end.

%%base_skill_choose(SelfInfo)->			
%%	Skills = get_skilllist_from_npcinfo(SelfInfo),
%%	case erlang:length(Skills) of
%%		1->
%%			[Skill] = Skills,
%%			Skill;
%%		_->	 
%%			CanUseList = lists:filter(
%%							fun({SkillID,SkillLevel,LastCastTime})->
%%								CoolDown = skill_db:get_cooldown(skill_db:get_skill_info(SkillID,SkillLevel)),					
%%								timer:now_diff(now(),LastCastTime) >= CoolDown*1000 end
%%								,Skills),		
%%			ChooseList = lists:filter(
%%							fun({SkillId,_,_})->
%%								{_,Rates} = lists:keyfind(SkillId,1,get_skillrates_from_npcinfo(SelfInfo)),				
%%								random:uniform(100) =< Rates
%%							end,
%%							CanUseList),
%%			case  ChooseList of 
%%				[] -> [];
%%				_ ->[Skill|_T] = ChooseList,
%%					Skill
%%			end
%%	end.
			
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 寻路（假的）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path_find_by_range(Begin,End,Range)->
	{X1,Y1} = Begin,
	{X2,Y2} = End,
	AddX = erlang:abs(X1-X2),
	AddY = erlang:abs(Y1-Y2),
	MaxDis = erlang:max(AddY,AddX),
	AddMaxDis = erlang:max(MaxDis - Range,0),
	TrulyAddX = erlang:min(AddX,AddMaxDis),
	TrulyAddY = erlang:min(AddY,AddMaxDis),
	if
		X1 > X2 ->
			X3 = X1 - TrulyAddX;
		true->
			X3 = X1 + TrulyAddX
	end,
	if
		Y1 > Y2 ->
			Y3 = Y1 - TrulyAddY;
		true->
			Y3 = Y1 + TrulyAddY
	end,
	%%过滤不可行走区域
	case mapop:check_pos_is_valid({X3,Y3},get(map_db)) of
		true->
			EndPoint = {X3,Y3};
		_->
			EndPoint = End
	end,	
	lists:filter(fun(CheckPos)->mapop:check_pos_is_valid(CheckPos,get(map_db)) end,path_find(Begin,EndPoint)).

path_find(Begin,End)->
	try
		path_find(Begin,End,[])
	catch
		_:_ ->
			[]
	end.

path_find(Begin,End,Path)->
	{X1,Y1} = Begin,
	{X2,Y2} = End,
	if 
		(X1 =:= X2) and (Y1 =:= Y2) -> Path;
		true ->
			if 
				X2 > X1 -> NextX = X1 + erlang:min(?PATH_POIN_NUMBER,X2 - X1);
				X2 < X1 -> NextX = X1 - erlang:min(?PATH_POIN_NUMBER,X1 - X2);
				X1 =:= X2 -> NextX = X1
			end,
			if 
				Y2 > Y1 -> NextY = Y1 + erlang:min(?PATH_POIN_NUMBER,Y2 - Y1);
				Y2 < Y1 -> NextY = Y1 - erlang:min(?PATH_POIN_NUMBER,Y1 - Y2);
				Y2 =:= Y1 -> NextY = Y1
			end,
			NewPath = lists:append(Path,[{NextX,NextY}]),
			path_find({NextX,NextY},End,NewPath)
	end.
	
random_shout_to_aoi(Dialogues)->
	if
		Dialogues=:=[]->
			nothing;
		true->		
			Shout =  lists:nth(random:uniform(erlang:length(Dialogues)),Dialogues ),
			normal_ai:say(Shout)			
	end.
	
speak_to_aoi(Shout)->
	ShoutDialog = util:safe_binary_to_list(Shout),
	MyName = get_name_from_npcinfo(get(creature_info)),
	Message = chat_packet:encode_chat_s2c(?CHAT_TYPE_INTHEVIEW,?DEST_CHAT,get(id),MyName,ShoutDialog,[],?ROLE_IDLE_NPC),
	npc_op:broadcast_message_to_aoi_client(Message).	
	
speak_to_role(RoleId,MyWords)->	
	OriDialog = util:safe_binary_to_list(MyWords),
	MyName = get_name_from_npcinfo(get(creature_info)),
	Message = chat_packet:encode_chat_s2c(?CHAT_TYPE_INTHEVIEW,?DEST_CHAT,get(id),MyName,OriDialog,[],?ROLE_IDLE_NPC),
	npc_op:send_to_other_client(RoleId,Message).
exec_beam(Script,Fun,Args)->
	try
		apply(Script,Fun,Args)
	catch
		E:R->slogger:msg("npc ai error Script~p Reason ~p ~p ~n",[Script,R,erlang:get_stacktrace()]),[]
	end.		
