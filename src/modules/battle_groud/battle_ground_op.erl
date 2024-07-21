%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(battle_ground_op).

-compile(export_all).

-include("data_struct.hrl").
-include("little_garden.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("map_info_struct.hrl").
-include("battle_define.hrl").
-include("instance_define.hrl").
-include("activity_define.hrl").
-include("skill_define.hrl").
-include("game_map_define.hrl").
-include("pvp_define.hrl").

-ifdef(debug).
-define(SEND_REWARD(Winner),send_reward(Winner)).
send_reward(Winner)->
	BroadCastMsg = "winner:"++integer_to_list(Winner),
	chat_manager:system_to_someone(get(roleid),BroadCastMsg).
-else.
-define(SEND_REWARD(Winner),void).
-endif.

%%
%% battle_info {battle_type,node,proc,mapproc}
%%	
%% tangle_info {battletype,battleid}

%%
%% battle_info {bg_type,bg_node,bg_process,bg_map_process}
%%
init()->
	put(battle_info,{[],[],[],[]}),
	yhzq_init(),
	jszd_init().

export_for_copy()->
	{get(battle_info),get(yhzq_info),get(jszd_info)}.

load_by_copy(BattleGroundInfo)->
	{BattleInfo,YhzqInfo,JszdInfo} = BattleGroundInfo,
	put(battle_info,BattleInfo),
	put(yhzq_info,YhzqInfo),
	put(jszd_info,JszdInfo).

is_in_battle_ground()->
	get(battle_info) =/= {[],[],[],[]}.

is_in_jszd_battle()->
	case get(battle_info) of
		{[],[],[],[]}->
			false;
		{Type,_,_,_}->
			Type =:= ?JSZD_BATTLE
	end.

is_crime()->
	{BgType,_,_,_} = get(battle_info),
	case BgType of
		[]->
			true;
		?TANGLE_BATTLE->
			false;
		?YHZQ_BATTLE->
			false;
		?JSZD_BATTLE->
			false;
		_Other->
			true
	end.

is_can_chat()->
	{BgType,_,_,_} = get(battle_info),
	case BgType of
		[]->
			false;
		?TANGLE_BATTLE->
			false;
		?YHZQ_BATTLE->
			true;
		?JSZD_BATTLE->
			false;
		_Other->
			false
	end.

battle_chat(Msg)->
	{BgType,Node,Proc,_MapProc} = get(battle_info),
	case BgType of
		[]->
			nothing;
		?TANGLE_BATTLE->
			nothing;
		?YHZQ_BATTLE->
			{_,Camp,_Node,_Proc,_MapProc} = get(yhzq_info),
			battle_ground_processor:battle_chat(Node,Proc,{get(roleid),Camp,Msg});
		?JSZD_BATTLE->
			nothing;
		_Other->
			nothing
	end.

check_pvp(RoleInfo,OtherInfo)->
	{BgType,_,_,_} = get(battle_info),
%%	io:format("battle_info ~p ~n",[get(battle_info)]),
	case BgType of
		[]->
			nothing;
		?TANGLE_BATTLE->
			true;
		?YHZQ_BATTLE->  %%pvp
			{State,_,_,_,_} = get(yhzq_info),
			case State of
				?YHZQ_ROLE_PROCESS->
					MyCamp = get_camp_from_roleinfo(RoleInfo),
					OtherCamp = get_camp_from_roleinfo(OtherInfo),
%%					io:format("MyCamp ~p OtherCamp ~p ~n",[MyCamp,OtherCamp]),
					MyCamp =/= OtherCamp;
				_->
					nothing
			end;	
		?JSZD_BATTLE->
			MyGuild = get_guildname_from_roleinfo(RoleInfo),
			OtherGuild = get_guildname_from_roleinfo(OtherInfo),
			MyGuild =/= OtherGuild;
		Other->
			nothing
	end.


get_proc()->
	{_,_,Proc,_} = get(battle_info),
	Proc.

get_map_proc_name()->
	{_,_,_,MapProc} = get(battle_info),
	MapProc. 
	
get_node()->
	{_,Node,_,_} = get(battle_info),
	Node.

%%
%%join the battle
%%

handle_apply(?TANGLE_BATTLE)->
%%	io:format("handle_apply ~n"),
	RoleLevel = get_level_from_roleinfo(get(creature_info)),
	case (RoleLevel >= 30) and transport_op:can_directly_telesport() of
		true->
			battle_ground_manager:apply_for_battle(?TANGLE_BATTLE,{get(roleid),RoleLevel});
		_->
			nothing
	end;	

handle_apply({?YHZQ_BATTLE,Type})->
	noting;

handle_apply({?JSZD_BATTLE,GuildName})->
	battle_ground_manager:apply_for_battle(?JSZD_BATTLE,{get(roleid),GuildName});

handle_apply(_)->
	nothing.

handle_join(?TANGLE_BATTLE)->	
	case (get_level_from_roleinfo(get(creature_info)) >= 50) and transport_op:can_directly_telesport() and (not role_op:is_dead())of
		true->
			case get(battle_info) of
				{[],[],[],[]}->
					handle_apply(?TANGLE_BATTLE);
				{?TANGLE_BATTLE,Node,Proc,MapProc}->
%%					%%io:format("handle_join ~n"),
					%%MapProc = battle_ground_processor:make_map_proc_name(Proc),
					case instance_pos_db:get_instance_pos_from_mnesia(erlang:atom_to_list(MapProc)) of			
						[]->
%%							io:format("instance_pos_db:get_instance_pos_from_mnesia(erlang:atom_to_list(MapProc)) ~n"),
							todo_send;
						{_Id,_Creation,StartTime,CanJoin,InstanceNode ,_Pid,MapId,ProtoId,Members}->
							ProtoInfo = instance_proto_db:get_info(ProtoId),
							if
								CanJoin->
									RoleGender = get_gender_from_roleinfo(get(creature_info)),
									RoleName = get_name_from_roleinfo(get(creature_info)),
									RoleLevel = get_level_from_roleinfo(get(creature_info)),
									RoleClass = get_class_from_roleinfo(get(creature_info)),
									activity_value_op:update({join_activity,?TANGLE_BATTLE_ACTIVITY}),
									battle_ground_processor:join_battle(Node,Proc,{get(roleid),RoleName,RoleClass,RoleGender,RoleLevel}),
									Pos = lists:nth(random:uniform(erlang:length(?TANGLE_SPAWN_POS)),?TANGLE_SPAWN_POS),
									instance_op:trans_to_dungeon(false,MapProc,get(map_info),Pos ,?INSTANCE_TYPE_TANGLE_BATTLE,ProtoInfo,InstanceNode,MapId);
								true->
									todo_send
							end	
					end;
				_->
					nothing
			end;
		_->
			nothing
	end;

handle_join(?YHZQ_BATTLE)->
	case (get_level_from_roleinfo(get(creature_info)) >= 30) and transport_op:can_directly_telesport() and (not role_op:is_dead()) of
		true->
			case get(yhzq_info) of
				{1,[],[],[],[]}->
					ignor;
				{A,Camp,Node,Proc,MapProc} ->
					RoleLevel = get_level_from_roleinfo(get(creature_info)),
					case instance_pos_db:get_instance_pos_from_mnesia(erlang:atom_to_list(MapProc)) of			
						[]->
							slogger:msg("yhzq handle_join error instance_pos_db:get_instance_pos_from_mnesia [] ~n"),
							todo_send;
						{_Id,_Creation,StartTime,CanJoin,InstanceNode ,_Pid,MapId,ProtoId,Members}->
							ProtoInfo = instance_proto_db:get_info(ProtoId),
							if
								CanJoin->
									RoleGender = get_gender_from_roleinfo(get(creature_info)),
									RoleName = get_name_from_roleinfo(get(creature_info)),
									%%RoleLevel = get_level_from_roleinfo(get(creature_info)),
									RoleClass = get_class_from_roleinfo(get(creature_info)),
									%% update camp info
									put(creature_info,set_camp_to_roleinfo(get(creature_info),Camp)),
									role_op:update_role_info(get(roleid),get(creature_info)),
									put(yhzq_info,{?YHZQ_ROLE_PROCESS,Camp,Node,Proc,MapProc}),
									put(battle_info,{?YHZQ_BATTLE,Node,Proc,MapProc}),	
									role_op:self_update_and_broad([{faction,Camp}]),
									activity_value_op:update({join_activity,?YHZQ_BATTLE_ACTIVITY}),
									SpawnPosList = get_spawnpos(),
									battle_ground_processor:join_battle(Node,Proc,{get(roleid),RoleName,RoleClass,RoleGender,RoleLevel,Camp}),
									if
										Camp =:= ?YHZQ_CAMP_RED->
											BornPosList = lists:nth(?CAMP_RED_BORNPOS_INDEX,SpawnPosList);
										true->
											BornPosList = lists:nth(?CAMP_BLUE_BORNPOS_INDEX,SpawnPosList)
									end,		
									Pos = lists:nth(random:uniform(erlang:length(BornPosList)),BornPosList),
									instance_op:trans_to_dungeon(false,MapProc,get(map_info),Pos,?INSTANCE_TYPE_YHZQ,ProtoInfo,InstanceNode,MapId);
								true->
										slogger:msg("yhzq handle_join error can join false~n"),
										todo_send
							end
					end;
				_->
					slogger:msg("yhzq handle_join error get_instance_pos_from_mnesia unknown~n"),
					nothing
			end;
		_->
			slogger:msg("yhzq handle_join error ~n"),
			nothing	
	end;
	
handle_join(?JSZD_BATTLE)->
	case transport_op:can_directly_telesport() and (not role_op:is_dead()) of
		true->
			GuildName = get_guildname_from_roleinfo(get(creature_info)),
		case get(jszd_info) of
		[]->
			handle_apply({?JSZD_BATTLE,GuildName});
		{?JSZD_BATTLE,Node,Proc,MapProc}->
			case instance_pos_db:get_instance_pos_from_mnesia(erlang:atom_to_list(MapProc)) of			
				[]->
					io:format("JSZD_BATTLE instance_pos_db:get_instance_pos_from_mnesia(erlang:atom_to_list(MapProc)) ~n"),
					todo_send;
				{_Id,_Creation,_StartTime,CanJoin,InstanceNode ,_Pid,MapId,ProtoId,_Members}->
					ProtoInfo = instance_proto_db:get_info(ProtoId),
					if
						CanJoin->
							put(battle_info,{?JSZD_BATTLE,Node,Proc,MapProc}),
							RoleName = get_name_from_roleinfo(get(creature_info)),
							RoleLevel = get_level_from_roleinfo(get(creature_info)),
							GuildName = get_guildname_from_roleinfo(get(creature_info)),
							pvp_op:proc_set_pkmodel(?PVP_MODEL_GUILD, timer_center:get_correct_now()),
							gm_logger_role:jszd_battle_log(get(roleid), RoleLevel, 1, 0),
							activity_value_op:update({join_activity,?JSZD_BATTLE_ACTIVITY}),
							battle_ground_processor:join_battle(Node,Proc,{get(roleid),RoleName,RoleLevel,GuildName}),
							Pos = lists:nth(random:uniform(erlang:length(?JSZD_SPAWN_POS)),?JSZD_SPAWN_POS),
							instance_op:trans_to_dungeon(false,MapProc,get(map_info),Pos ,?INSTANCE_TYPE_JSZD,ProtoInfo,InstanceNode,MapId);
						true->
							todo_send
					end	
			end;
		_->
			nothing
		end;
		_->
			slogger:msg("jszd_battle handle_join error ~n"),
			nothing
	end;

handle_join(_)->
	nothing.

handle_battle_leave()->
%%  	io:format(" ~p handle_battle_leave ~n",[?MODULE]),
	case get(battle_info) of
		{[],[],[],[]}->
			{State,_,Node,Proc,MapProc} = get(yhzq_info),
			if
				State =/= ?YHZQ_ROLE_IDLE->
					put(creature_info,set_camp_to_roleinfo(get(creature_info), 0)),
					role_op:update_role_info(get(roleid),get(creature_info)),
					role_op:self_update_and_broad([{faction,0}]),
					init(),
					Message = battle_ground_packet:encode_yhzq_battle_end_s2c(),
					role_op:send_data_to_gate(Message);
				true->
					battle_ground_manager:cancel_apply_battle(?TANGLE_BATTLE,{{get(roleid),get_level_from_roleinfo(get(creature_info))}})
			end;
		{?TANGLE_BATTLE,Node,Proc,_}->	
			battle_ground_processor:leave_battle(Node,Proc,get(roleid)),
			init(),
			instance_op:kick_instance_by_reason({?INSTANCE_TYPE_TANGLE_BATTLE,Proc});
		{?YHZQ_BATTLE,Node,Proc,_}->
%%			io:format("~p handle_battle_leave ~n",[?MODULE]),
			battle_ground_processor:leave_battle(Node,Proc,get(roleid)),
			%%update camp info
			put(creature_info,set_camp_to_roleinfo(get(creature_info), 0)),
			role_op:update_role_info(get(roleid),get(creature_info)),
			role_op:self_update_and_broad([{faction,0}]),
			init(),
			Message = battle_ground_packet:encode_yhzq_battle_end_s2c(),
			role_op:send_data_to_gate(Message),
			instance_op:kick_instance_by_reason({?INSTANCE_TYPE_YHZQ,Proc});
		{?JSZD_BATTLE,Node,Proc,_}->
			battle_ground_processor:leave_battle(Node,Proc,get(roleid)),
			init(),
			Message = battle_jszd_packet:encode_jszd_leave_s2c(),
			role_op:send_data_to_gate(Message),
			instance_op:kick_instance_by_reason({?INSTANCE_TYPE_JSZD,Proc})
	end.

handle_battle_reward()->
	case get(battle_info) of
		{[],[],[],[]}->
			nothing;
		{?TANGLE_BATTLE,Node,Proc,_}->
			{_,_,Items} = battle_ground_processor:get_reward(Node,Proc,get(roleid)),
			lists:foreach(fun({Itemid,ItemCount})->role_op:auto_create_and_put(Itemid,ItemCount,got_tangle_battle) end,Items),
			gm_logger_role:get_battle_reward(get(roleid),tangle_battle,0,0,Items);
		{?YHZQ_BATTLE,Node,Proc,_}->
			Items = battle_ground_processor:get_reward(Node,Proc,get(roleid)),
			lists:foreach(fun({Itemid,ItemCount})->role_op:auto_create_and_put(Itemid,ItemCount,got_tangle_battle) end,Items),
			gm_logger_role:get_battle_reward(get(roleid),yhzq_battle,0,0,Items);
		{?JSZD_BATTLE,Node,Proc,_}->
			RoleId = get(roleid),
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			case battle_ground_processor:get_reward(Node,Proc,{RoleId,RoleLevel}) of
				[]->
					nothing;
				{_,Bonus,_}->
					gm_logger_role:jszd_battle_log(get(roleid), RoleLevel, 1, {0,Bonus}),
					lists:foreach(fun({Itemid,ItemCount})->
						role_op:auto_create_and_put(Itemid,ItemCount,got_jszd_battle) 
								  end,Bonus),
					gm_logger_role:get_battle_reward(get(roleid),jszd_battle,0,0,Bonus)
			end,
			handle_battle_leave();
		_Other->
			nothing
	end.

handle_battle_reward_by_records_c2s(Date,BattleType,BattleId)->
	battle_ground_manager:get_reward_by_manager(?TANGLE_BATTLE,get(roleid)).

%%
%% msg from battle manager
%%
battle_reward_from_manager({?TANGLE_BATTLE,{Honor,Exp,Items}})->
	role_op:obtain_honor(trunc(Honor)),
	role_op:obtain_exp(trunc(get(level)*Exp)),
	case package_op:can_added_to_package_template_list(Items) of
		true->
			lists:foreach(fun({Itemid,ItemCount})->role_op:auto_create_and_put(Itemid,ItemCount,got_tangle_battle) end,Items);
		_->
			battle_ground_manager:get_reward_error(get(roleid))
	end;
	
battle_reward_from_manager(_)->
	nothing.

hook_on_kill(KilledId)->
	case get(battle_info) of
		{[],[],[],[]}->
			nothing;
		{?TANGLE_BATTLE,Node,Proc,_}->
			case creature_op:what_creature(KilledId) of
				role->
					achieve_op:achieve_update({battle_player_kill}, [?TANGLE_BATTLE]);
				_->	
					nothing
			end,
			battle_ground_processor:on_kill(Node,Proc,{get(roleid),KilledId});
		{?YHZQ_BATTLE,Node,Proc,_}->
			case creature_op:what_creature(KilledId) of
				role->
					achieve_op:achieve_update({battle_player_kill}, [?YHZQ_BATTLE]);
				_->	
					nothing
			end,
			battle_ground_processor:on_kill(Node,Proc,{get(roleid),KilledId});
		{?JSZD_BATTLE,Node,Proc,_}->
			case creature_op:what_creature(KilledId) of
				role->
					battle_ground_processor:on_kill(Node,Proc,{get(roleid),KilledId}),
					achieve_op:achieve_update({battle_player_kill}, [?JSZD_BATTLE]);
				npc->	
					battle_ground_processor:on_kill(Node,Proc,{get(roleid),KilledId});
				_->
					nothing
			end;
		_->
			nothing
	end.

hook_on_offline()->
	case get(battle_info) of
		{[],[],[],[]}->
			ignor;
		{?TANGLE_BATTLE,Node,Proc,_}->
			battle_ground_processor:leave_battle(Node,Proc,get(roleid));
		{?YHZQ_BATTLE,Node,Proc,_}->
			{State,_,_,_,_} = get(yhzq_info),
			case State of
				?YHZQ_ROLE_PROCESS->  	%%lamster
					add_lamster_buff();
				_->
					nothing
			end,
			battle_ground_processor:leave_battle(Node,Proc,get(roleid));
		{?JSZD_BATTLE,Node,Proc,_}->
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			gm_logger_role:jszd_battle_log(get(roleid), RoleLevel, 2, 0),
			battle_ground_processor:leave_battle(Node,Proc,get(roleid))
	end.

hook_map_complete()->
	case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
		?MAP_TAG_TANGLE_BATTLE->
			nothing;
		?MAP_TAG_JSZD_BATTLE->
			pvp_op:proc_set_pkmodel(?PVP_MODEL_GUILD, timer_center:get_correct_now());
		_->
			case get_camp_from_roleinfo(get(creature_info)) of
				0->
					nothing;
				_->
					put(creature_info,set_camp_to_roleinfo(get(creature_info), 0)),
					role_op:update_role_info(get(roleid),get(creature_info)),
					role_op:self_update_and_broad([{faction,0}]),
					init(),
					Message = battle_ground_packet:encode_yhzq_battle_end_s2c(),
					role_op:send_data_to_gate(Message)
			end
	end.

hook_on_respawn()->
	case get(battle_info) of
		{[],[],[],[]}->
			nothing;
		{?TANGLE_BATTLE,_,_,_}->
			add_respawn_buff(?TANGLE_BATTLE);		
		{?YHZQ_BATTLE,_,_,_}->
			add_respawn_buff(?YHZQ_BATTLE);	
		_->
			nothing
	end.

add_respawn_buff(BattleId)->
	case battlefield_proto_db:get_info(BattleId) of
		[]->
			nothing;
		Info->
			case battlefield_proto_db:get_respawn_buff(Info) of
				[]->
					nothing;
				Buffs->
					role_op:add_buffers_by_self(Buffs)
			end
	end.

handle_tangle_records(Date,Class)->
	battle_ground_manager:get_tangle_records({get(roleid),Date,Class}).

handle_tangle_more_records()->
	battle_ground_manager:get_tangle_records({get(roleid)}).

hook_on_online()->
	check_battle_time(?TANGLE_BATTLE),
	check_battle_time(?JSZD_BATTLE).
	%% other battle todo 

check_battle_time(?TANGLE_BATTLE)->
	case battle_ground_manager:get_battle_start(?TANGLE_BATTLE) of
		{0,0,0}->
			nothing;
		Time->	
			case battlefield_proto_db:get_info(?TANGLE_BATTLE) of
				[]->
					nothing;
				ProtoInfo->
					Duration = battlefield_proto_db:get_duration(ProtoInfo),
					LeftTime = trunc((Duration - timer:now_diff(timer_center:get_correct_now(),Time)/1000)/1000),
					Message = battle_ground_packet:encode_battle_start_s2c(?TANGLE_BATTLE,LeftTime),
					role_op:send_data_to_gate(Message)
			end
	end;
	
check_battle_time(?JSZD_BATTLE)->
	case battle_ground_manager:get_battle_start(?JSZD_BATTLE) of
		{0,0,0}->
			nothing;
		{Time,Duration}->	
			LeftTime = trunc((Duration - timer:now_diff(timer_center:get_correct_now(),Time)/1000)/1000),
			Message = battle_jszd_packet:encode_jszd_start_notice_s2c(LeftTime),
			role_op:send_data_to_gate(Message)
	end;
	
check_battle_time(_)->
	nothing.
	

battle_intive_to_join({?TANGLE_BATTLE,_BattleId,Node,Proc,MapProc})->
%% 	BattleType = tangle_battle_manager_op:get_adapt_battle_ground_type(get_level_from_roleinfo(get(creature_info))),
	put(battle_info,{?TANGLE_BATTLE,Node,Proc,MapProc}),
	handle_join(?TANGLE_BATTLE);

battle_intive_to_join({?JSZD_BATTLE,Node,Proc,MapProc})->
	put(jszd_info,{?JSZD_BATTLE,Node,Proc,MapProc}),
	handle_join(?JSZD_BATTLE);

battle_intive_to_join(_)->
	nothing.	

%%
%%yhzq info {State,BattleId,Camp(red or blue),Node,Proc,MapProc}
%%
yhzq_init()->
	put(yhzq_info,{?YHZQ_ROLE_IDLE,[],[],[],[]}).

check_group_member_level(BattleType,MemberLevel)->
	Type =  env:get(yhzq_battle_group_type,?DEFAULT_YHZQ_GROUP_TYPE),
	if
		(MemberLevel>=30) and (MemberLevel=<100) and (Type =:= ?YHZQ_GROUP_ALL)->
			?YHZQ_30_100 =:= BattleType;
		(MemberLevel>=30) and (MemberLevel=<49)->
			?YHZQ_30_49 =:= BattleType;
		(MemberLevel>=50) and (MemberLevel=<69)->
			?YHZQ_50_69 =:= BattleType;
		(MemberLevel>=70) and (MemberLevel=<89)->
			?YHZQ_70_89 =:= BattleType;
		(MemberLevel>=90)->
			?YHZQ_90 =:= BattleType;
		true->
			false			%% faild
	end.	
	

%%
%% judge with battle type by role level
%%
get_adapt_yhzq_type(RoleLevel)->
	Type =  env:get(yhzq_battle_group_type,?DEFAULT_YHZQ_GROUP_TYPE),
	if

		(RoleLevel>=30) and (RoleLevel=<100) and (Type =:= ?YHZQ_GROUP_ALL)->
			?YHZQ_30_100;
		(RoleLevel>=30) and (RoleLevel=<49)->
			?YHZQ_30_49;
		(RoleLevel>=50) and (RoleLevel=<69)->
			?YHZQ_50_69;
		(RoleLevel>=70) and (RoleLevel=<89)->
			?YHZQ_70_89;
		(RoleLevel>=90)->
			?YHZQ_90;
		true->
			0			%% find faild
	end.	

%%
%% battle manager invite role join battle
%%
handle_notify_to_join_yhzq(Camp,Node,Proc,MapProc)->
	put(yhzq_info,{?YHZQ_ROLE_READY,Camp,Node,Proc,MapProc}),
	Battle_id=2,%%@@wb20130422鍔犲叆姘告亽涔嬫棗Id
	Message = battle_ground_packet:encode_notify_to_join_yhzq_s2c(Battle_id,Camp), 
	role_op:send_data_to_gate(Message). 


%%
%%leave battle
%%
handle_leave_yhzq_c2s()->
	{State,_,Node,Proc,MapProc} = get(yhzq_info),
%%	io:format(" ~p handle_battle_leave ~p ~n",[?MODULE,get(yhzq_info)]),
	case State of
		?YHZQ_ROLE_PROCESS->  	%%lamster
			add_lamster_buff(),
			handle_battle_leave();
		?YHZQ_ROLE_AWARD->
			handle_battle_leave();
		Other->
			nothing
	end.


%%
%% notify client battle end, reward ready
%%
handle_notify_yhzq_reward(Winner,Honor,AddExp)->
	battle_reward_honor_exp(?YHZQ_BATTLE,Honor,AddExp),
	{_,Camp,Node,Proc,MapProc} = get(yhzq_info),
	put(yhzq_info,{?YHZQ_ROLE_AWARD,Camp,Node,Proc,MapProc}),
	Message = battle_ground_packet:encode_yhzq_award_s2c(Winner,Honor,AddExp), 
	role_op:send_data_to_gate(Message).

%%
%%reward
%%
handle_yhzq_award_c2s()->
	{State,_,Node,Proc,MapProc} = get(yhzq_info),
	case State of
		?YHZQ_ROLE_AWARD->
			handle_battle_reward();
		Other->
			nothing
	end.

%%
%%check born point
%%
check_yhzq_keybornpos()->
	case get(battle_info) of	
		{?YHZQ_BATTLE,Node,Proc,_}->
			{_,Camp,_,_,_} = get(yhzq_info),
			 battle_ground_processor:get_keybornpos(Node,Proc,Camp);
		Other->
			false
	end.

%%
%%Occupied an area
%%
handle_yhzq_get_zone(Id)->
	case get(battle_info) of
		{[],[],[],[]}->
			nothing;
		{?TANGLE_BATTLE,Node,Proc,_}->
			nothing;
		{?YHZQ_BATTLE,Node,Proc,_}->
			{_,Camp,_,_,_} = get(yhzq_info),
			battle_ground_processor:take_a_zone(Node,Proc,{Camp,Id})
	end.
	
	
%%
%%get born point by pos
%%
get_spawnpos()->
	Info = yhzq_battle_db:get_info(1),
	yhzq_battle_db:get_spawnpos(Info).

get_my_spawnpos()->
	try
		{Type,_,_,_} = get(battle_info),
		case Type of
			?YHZQ_BATTLE->
				SpawnList = get_spawnpos(),
				case check_yhzq_keybornpos() of
					true->
						SpwanPoss = lists:nth(?CAMP_BEST_BORNPOS_INDEX,SpawnList);
					_->
						{_,Camp,_,_,_} = get(yhzq_info),
						SpwanPoss = lists:nth(Camp,SpawnList)
				end,
				Pos = lists:nth(random:uniform(erlang:length(SpwanPoss)),SpwanPoss),
				{get_mapid_from_mapinfo(get(map_info)),Pos};
			_->
				mapop:get_respawn_pos(get(map_db))
		end
	catch
		E:R->
			slogger:msg("role ~p get_my_spawnpos error E:~p R:~p S: ~p ~n",[get(roleid),E,R,erlang:get_stacktrace()]),
			mapop:get_respawn_pos(get(map_db))
	end.


%%
%%add deserter buff
%%
add_lamster_buff()->
	nothing.

%%
%%check deserter buff by myself
%%
check_lamster_buff()->
	%%buffer_op:has_buff(?LAMSTER_BUFF_ID).
	BufferList = get_buffer_from_roleinfo(get(creature_info)),
	check_lamster_buff(BufferList).

check_lamster_buff(BufferList)->
	lists:foldl(fun({BuffID,BuffLevel},Res)->
					if
						Res->
							Res;
						true->		
							BuffInfo = buffer_db:get_buffer_info(BuffID,BuffLevel),
							BuffClass = buffer_db:get_buffer_class(BuffInfo),
	%%						io:format("BufferInfo ~p BufferType ~p \n",[BuffInfo,BuffType]),
							BuffClass =:= ?BUFF_CLASS_BATTLE_LAMSTER
					end
				end,false,BufferList).
	

%%
%%leader check teammate deserter buff
%%
check_member_lamster_buffer(MemberInfo)->
	lists:foldl(fun({RoleId,Level},Res)->
						if
							Res->
								Res;
							true->
								check_remote_lamster_buffer(RoleId)	
						end			
						end,false,MemberInfo).

check_remote_lamster_buffer(RoleId)->
	case creature_op:get_remote_role_info(RoleId) of
		undefined->	
			false;
		RemoteInfo->
			BufferList = get_buffer_from_othernode_roleinfo(RemoteInfo),
			check_lamster_buff(BufferList)
	end.



%%jszd
jszd_init()->
	put(jszd_info,[]).

%%get tangle kill info
handle_tangle_kill_info_request(Date,BattleType,BattleId)->
	case get(battle_info) of
		{?TANGLE_BATTLE,Node,Proc,_}->
			battle_ground_processor:get_tangle_kill_info(Node,Proc,get(roleid));
		_->
			battle_ground_manager:get_tangle_kill_info({get(roleid),Date,BattleType,BattleId})
	end.

handle_rule_description(Battle)->
	case Battle of
		?TANGLE_BATTLE->
			KillNum = tangle_battle_db:get_role_totle_killnum(get(roleid)),
			{_,BattleInfo} = battle_ground_manager:get_tangle_battle_curenum(),
			Honor = get_honor_from_roleinfo(get(creature_info)),
			ParamBattle = battle_ground_packet:make_tangle_battle_num(BattleInfo),
			Message = battle_ground_packet:encode_tangle_battlefield_info_s2c(KillNum,Honor,ParamBattle),
			role_op:send_data_to_gate(Message);
		?YHZQ_BATTLE->
			GbInfo = guild_manager:get_guild_battle_wininfo(yhzq),
			ParamGbInfo = battle_ground_packet:make_yhzq_gbinfo_param(GbInfo),
			Message = battle_ground_packet:encode_yhzq_battlefield_info_s2c(ParamGbInfo),
			role_op:send_data_to_gate(Message);
		?JSZD_BATTLE->
			GbInfo = guild_manager:get_guild_battle_wininfo(jszd_battle),
			ParamGbInfo = battle_ground_packet:make_jszd_gbinfo_param(GbInfo),
			case battle_jszd_db:get_role_score_info(get(roleid)) of
				{_,_,Score,KillNum}->
					Honor = get_honor_from_roleinfo(get(creature_info)),
					Message = battle_ground_packet:encode_jszd_battlefield_info_s2c(Score,KillNum,Honor,ParamGbInfo),
					role_op:send_data_to_gate(Message);
				_->
					Message = battle_ground_packet:encode_battlefield_info_error_s2c(?ERROR_NOT_JION_IN),
					role_op:send_data_to_gate(Message)
			end;
		?GUILD_BATTLE->
			RankInfo = guildbattle_manager:get_guilebattle_rank_info(),
			ParamRank = battle_ground_packet:make_guildbattle_rankinfo(RankInfo),
			Message = battle_ground_packet:encode_guild_battlefield_info_s2c(ParamRank),
			role_op:send_data_to_gate(Message);
		_->
			GbInfo = guild_manager:get_guild_battle_wininfo(all),
			ParamGbInfo = battle_ground_packet:make_gbinfo_param(GbInfo),
			Message = battle_ground_packet:encode_battlefield_totle_info_s2c(ParamGbInfo),
			role_op:send_data_to_gate(Message)
	end.
	
battle_reward_honor_exp(?TANGLE_BATTLE,Honor,Exp)->
	Message = battle_ground_packet:encode_battle_end_s2c(Honor,get(level)*Exp),
	role_op:send_data_to_gate(Message),
	role_op:obtain_exp(trunc(get(level)*Exp)),
	role_op:obtain_honor(trunc(Honor)),
	gm_logger_role:get_battle_reward(get(roleid),?TANGLE_BATTLE,Honor,Exp,[]);

battle_reward_honor_exp(Battle,Honor,AddExp)->
	role_op:obtain_exp(trunc(AddExp)),
	role_op:obtain_honor(trunc(Honor)),
	gm_logger_role:get_battle_reward(get(roleid),Battle,Honor,AddExp,[]).

	
	
	
