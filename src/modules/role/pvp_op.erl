%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pvp_op).

-export([init/0,can_be_attack/2,clear_crime/0,on_attack/2,on_other_killed/1,set_pkmodel/1,proc_set_pkmodel/2]).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("pet_struct.hrl").
-include("login_pb.hrl").
-include("common_define.hrl").
-include("map_info_struct.hrl").
-include("map_def.hrl").
-include("ai_define.hrl").
-include("system_chat_define.hrl").
-include("pvp_define.hrl").
-include("game_map_define.hrl").
%%duel_role:id,name
%%pvpinfo:{Model,Crime}
-compile(export_all).
    
init()->
	put(duel_role,{0,[]}),
	put(crime_black_name_time,timer_center:get_correct_now()),
	put(crime_time,timer_center:get_correct_now()).

on_other_killed(Otherid)->
	case creature_op:what_creature(Otherid) of
		npc->
			case creature_op:get_creature_info(Otherid) of
				undefined->
						nothing;
				NpcInfo ->
					killed_monster(NpcInfo)
			end;
		role->
			case creature_op:get_creature_info(Otherid) of
				undefined->
					nothing;
				RoleInfo->
					killed_other(RoleInfo)
			end
	end.

export_for_copy()->
	{get(crime_black_name_time),get(crime_time)}.

load_by_copy({BlackTime,CrimeTime})->
	put(duel_role,{0,[]}),
	put(crime_black_name_time,BlackTime),
	put(crime_time,CrimeTime).

killed_monster(NpcInfo)->
	killed_broad_cast(monster,get(creature_info),NpcInfo).

killed_other(OtherInfo)->
	OtherCrime = get_crime_from_roleinfo(OtherInfo),
	RoleInfo = get(creature_info), 
	case check_pvptag() of
		true ->
			nothing;
		false ->
			if 
				OtherCrime =:= 0->
					SelfCrime = get_crime_from_roleinfo(RoleInfo),
					if
						SelfCrime + ?KILL_ONE_ADD_CRIME >= ?ROLE_CRIME_EDGR ->
							NewSelfCrime = ?ROLE_CRIME_EDGR;
						(SelfCrime >= 0) and (SelfCrime + ?KILL_ONE_ADD_CRIME =< ?ROLE_CRIME_EDGR) ->
							NewSelfCrime = SelfCrime + ?KILL_ONE_ADD_CRIME;
						true->
							NewSelfCrime = ?KILL_ONE_ADD_CRIME
					end,
					{SelfModel,_} = get_pkmodel_from_roleinfo(RoleInfo),
					{OtherModel,_} = get_pkmodel_from_roleinfo(OtherInfo),
					gm_logger_role:role_change_crime_log(get(roleid),SelfModel,OtherModel,NewSelfCrime,SelfCrime,add),
					put(crime_time,timer_center:get_correct_now()),
					check_can_broadcast(SelfCrime,NewSelfCrime),
					NewInfo = set_crime_to_roleinfo(RoleInfo ,NewSelfCrime),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:self_update_and_broad([{crime,NewSelfCrime}]);
				true->
					nothing
			end
	end.

killed_broad_cast(Type,RoleInfo,OtherInfo)->
	MapId = get_mapid_from_mapinfo(get(map_info)),
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	MyServerId = get_serverid_from_roleinfo(RoleInfo),
	case role_server_travel:is_in_travel() of
		true->
			MyServerName = util:safe_binary_to_list(env:get_server_name(MyServerId)),
			ParamMS = system_chat_util:make_string_param(MyServerName),
			case Type of
				role->
					case  map_info_db:get_map_info(MapId) of
						[]->
							MapNameTmp = [];
						MapInfo->
							MapNameTmp =  util:safe_binary_to_list(map_info_db:get_map_name(MapInfo))
					end,
					SendType = ?SYSTEM_CHAT_TRAVEL_NORAML_KILL_ROLE,
					OtherServerId = get_serverid_from_roleinfo(OtherInfo),
					OtherServerName = util:safe_binary_to_list(env:get_server_name(OtherServerId)),
					ParamOS = system_chat_util:make_string_param(OtherServerName),
					ParamMap = system_chat_util:make_string_param(MapNameTmp),
					ParamOther = system_chat_util:make_role_param(OtherInfo),
					MsgInfo = [ParamMS,ParamRole,ParamMap,ParamOS,ParamOther],
					system_chat_op:system_broadcast(SendType,MsgInfo);
				_->
					NpcProtoId = get_templateid_from_npcinfo(OtherInfo),
					OtherName = get_name_from_npcinfo(OtherInfo),
					creature_sysbrd_util:sysbrd({monster_kill,true,NpcProtoId},{ParamMS,ParamRole,OtherName})
			end;
		_->
			case Type of
				role->
					SendType = ?SYSTEM_CHAT_NORAML_KILL_ROLE,
					ParamOther = system_chat_util:make_role_param(OtherInfo),
					MsgInfo = [ParamRole,ParamOther],
					system_chat_op:system_broadcast(SendType,MsgInfo);
				_->
					NpcProtoId = get_templateid_from_npcinfo(OtherInfo),
					OtherName = get_name_from_npcinfo(OtherInfo),
					creature_sysbrd_util:sysbrd({monster_kill,false,NpcProtoId},{[],ParamRole,OtherName})
			end
	end.

on_attack(SelfInfo,TargetInfo) when (is_record(TargetInfo , gm_npc_info) or is_record(SelfInfo, gm_npc_info))->
	nothing;

on_attack(SelfInfo,TargetInfo) when (is_record(TargetInfo , gm_pet_info) or is_record(SelfInfo, gm_pet_info))->
	nothing;

on_attack(RoleInfo,TargetInfo) ->
	case not check_pvptag() of
		true->
			OtherId = get_id_from_roleinfo(TargetInfo),
			case is_duel_target(OtherId) of
				false->
					MyCrime =  get_crime_from_roleinfo(RoleInfo),
					OtherCrime = get_crime_from_roleinfo(TargetInfo),
					if 
						(OtherCrime =:= 0) and (MyCrime =:= 0)->
							NewInfo = set_crime_to_roleinfo(RoleInfo ,?CRIME_BLACK_NAME),
							put(creature_info,NewInfo),
							role_op:update_role_info(get_id_from_roleinfo(NewInfo),NewInfo),
							role_op:self_update_and_broad([{crime,?CRIME_BLACK_NAME}]),
							put(crime_black_name_time,timer_center:get_correct_now());
						(OtherCrime =:= 0) and (MyCrime =:= ?CRIME_BLACK_NAME)->
							put(crime_black_name_time,timer_center:get_correct_now());
						true->						
							nothing
					end;
				_->
					nothing
			end;
		_->
			nothing
	end.

clear_black_name()->
	DiffTime = trunc(timer:now_diff(timer_center:get_correct_now(), get(crime_black_name_time))/1000),
	case DiffTime >= ?CRIME_BLACK_NAME_TIME of
		true->
			Crime = get_crime_from_roleinfo(get(creature_info)),
			RoleInfo = get(creature_info),
			if
				Crime =:= -1->
					NewInfo = set_crime_to_roleinfo(RoleInfo,0),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:self_update_and_broad([{crime,0}]);
				true->
					nothing	
			end;
		_->
			LeftTime = ?CRIME_BLACK_NAME_TIME - DiffTime,
			Msg = pvp_packet:encode_clear_crime_time_s2c(LeftTime,?CLEAR_ROLE_BLACK_NAME),
			role_op:send_data_to_gate(Msg)
	end.

clear_crime()->
	DiffTime = trunc(timer:now_diff(timer_center:get_correct_now(), get(crime_time))/1000000),
	case DiffTime >= ?CRIME_CLEAR_TIME of
		true-> 
			RoleInfo = get(creature_info),
			Crime = get_crime_from_roleinfo(RoleInfo),
			if 
				Crime > 0 ->
					if (Crime - ?CLEAR_CRIME_PRE_TIME) =< 0 ->
				   			NewCrime = 0;
			   			true ->
				   			NewCrime = Crime - ?CLEAR_CRIME_PRE_TIME
					end,
					{SelfModel,_} = get_pkmodel_from_roleinfo(RoleInfo),
					gm_logger_role:role_change_crime_log(get(roleid),SelfModel,[],NewCrime,Crime,reduce),
					put(crime_time,timer_center:get_correct_now()),
					NewInfo = set_crime_to_roleinfo(RoleInfo,NewCrime),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:self_update_and_broad([{crime,NewCrime}]);
				true->
					nothing	
			end;
		_->
			LeftTime = ?CRIME_CLEAR_TIME - DiffTime,
			Msg = pvp_packet:encode_clear_crime_time_s2c(LeftTime,?CLEAR_CRIME),
			role_op:send_data_to_gate(Msg)
	end.

clear_crime(Now)->
	RoleInfo = get(creature_info),
	Crime = get_crime_from_roleinfo(RoleInfo),
	if
		Crime > 0 ->
			case timer:now_diff(Now,get(crime_time)) >=?CRIME_CLEAR_TIME*1000000 of
				true->
					if (Crime - ?CLEAR_CRIME_PRE_TIME) =< 0 ->
				   			NewCrime = 0;
			   			true ->
				   			NewCrime = Crime - ?CLEAR_CRIME_PRE_TIME
					end,
					{SelfModel,_} = get_pkmodel_from_roleinfo(RoleInfo),
					gm_logger_role:role_change_crime_log(get(roleid),SelfModel,[],NewCrime,Crime,reduce),
					put(crime_time,timer_center:get_correct_now()),
					NewInfo = set_crime_to_roleinfo(RoleInfo,NewCrime),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:self_update_and_broad([{crime,NewCrime}]);
				_->
					nothing
			end;
		true->
			nothing
	end.
					
can_be_attack(SelfInfo,TargetInfo) when (is_record(SelfInfo , gm_npc_info) or is_record(TargetInfo , gm_npc_info))->
  	true;

can_be_attack(SelfInfo,TargetInfo) when (is_record(SelfInfo , gm_pet_info))->
  	true;

can_be_attack(SelfInfo,TargetInfo) when (is_record(TargetInfo , gm_pet_info))->
  	false;

can_be_attack(SelfInfo,TargetInfo)->			%%PVP	
	OtherId = get_id_from_roleinfo(TargetInfo),
	MyId = get_id_from_roleinfo(SelfInfo),
	OtherLevel = get_level_from_roleinfo(TargetInfo),
	MyLevel = get_level_from_roleinfo(SelfInfo),
	%%io:format("can_be_attack !!!!!!!!!!!!~n"),
	BattlePvpCheck = battle_ground_op:check_pvp(SelfInfo,TargetInfo),
	GuildBattlePvpPvpCheck = guildbattle_op:check_pvp(MyId,OtherId),
	case is_duel_target(OtherId ) of	
		true->					%%duel
			true;
		false->
			case BattlePvpCheck of
				true->
					true;
				false->
					error_model;
				_->
					case GuildBattlePvpPvpCheck of 
						true->
							true;
						same_guild->
							same_guild;
						false->
							guildbattle_ready;
						_->
							case (OtherLevel < 20) or (MyLevel < 20) or (OtherId =:= MyId)of 
								false->
									{SelfModel,_} = get_pkmodel_from_roleinfo(SelfInfo),
									{OtherModel,_} = get_pkmodel_from_roleinfo(TargetInfo),
									Crime = get_crime_from_roleinfo(TargetInfo),
									if  
										(SelfModel =:= ?PVP_MODEL_PEACE) or (OtherModel =:= ?PVP_MODEL_PEACE)->
												model_peace;
										SelfModel =:= ?PVP_MODEL_PUNISHER->
											if
												Crime =/= 0->
													case check_safe_zone(SelfInfo,TargetInfo) of
														false->
															true;
														_->
															safe_zone
													end;
												true->
													punisher
											end;
										SelfModel =:= ?PVP_MODEL_GUILD->
											case (not guild_util:is_same_guild(OtherId)) of
												true->
													case check_safe_zone(SelfInfo,TargetInfo) of
														false->
		 													true;
														_->
															safe_zone
													end;
												_->
													same_guild
											end;
										SelfModel =:= ?PVP_MODEL_TEAM->
											case (not  group_op:has_member(OtherId )) of
												true->
													case check_safe_zone(SelfInfo,TargetInfo) of
														false->
															true;
														_->
															safe_zone
													end;
												_->
													same_group
											end;
										SelfModel =:= ?PVP_MODEL_KILLALL->
											case check_safe_zone(SelfInfo,TargetInfo) of
												false->
													true;
												_->
													safe_zone
											end; 					
										true->
											error_model
									end;
								true->
									level
							end
					end
			end
	end.	

check_safe_zone(RoleInfo,TargetInfo)->
	case is_safe_zone(RoleInfo) or is_safe_zone(TargetInfo) of
		true->
			true;
		_->
			false
	end.

is_safe_zone(RoleInfo)->			
	RolePos = get_pos_from_roleinfo(RoleInfo),		
	RoleGrid = mapop:convert_to_grid_index(RolePos ,?GRID_WIDTH),
	mapop:check_safe_grid(get(map_db),RoleGrid).

%%is not self! TODO
start_duel(SelfInfo,TargetInfo)->
	OtherId = get_id_from_roleinfo(TargetInfo),
	OtherName = get_name_from_roleinfo(TargetInfo),
	put(duel_role,{OtherId,OtherName}).

is_duel_target(RoleId)->
	case get(duel_role) of
		{RoleId,_}->
			true;
		_->
			false
	end.

get_pkmodel()->
	{OriModel,_} = get_pkmodel_from_roleinfo(get(creature_info)),
	OriModel.

set_pkmodel(PkModel)->
	{OriModel,LastTime} = get_pkmodel_from_roleinfo(get(creature_info)),
	GuildBattleCheck = guildbattle_op:is_in_battle(),
	JSZDBattleCheck = battle_ground_op:is_in_jszd_battle(),
	TreasureTransportChcek = 
		case role_treasure_transport:is_treasure_transporting() of
			true->
				if
					PkModel =:= ?PVP_MODEL_PEACE->
						false;
					true->
						true
				end;
			_->
				true
		end,
	RoleCrime = get_crime_from_roleinfo(get(creature_info)),
	CheckCrime = case RoleCrime > 0 of
					 true->
						 if
							PkModel =:= ?PVP_MODEL_PEACE->
								false;
							true->
								true
						 end;
					 _->
						 true
				 end,
	TimeCheck = 
	if
		(PkModel=:=?PVP_MODEL_PEACE) or (PkModel=:=?PVP_MODEL_PUNISHER)->
			if
				(OriModel=:=?PVP_MODEL_GUILD) or (OriModel=:=?PVP_MODEL_KILLALL) or (OriModel=:=?PVP_MODEL_TEAM)->
					NewTime = LastTime,
					LeftTime = trunc(timer:now_diff(timer_center:get_correct_now(), LastTime)/1000000 - ?PVP_SWITCH_MODEL_TIME_S),
					LeftTime > 0;
				true->
					NewTime = LastTime,
					LeftTime = 0,
					true
			end;
		true->
			if
				(OriModel=:=?PVP_MODEL_PEACE) or (OriModel=:=?PVP_MODEL_PUNISHER)->
					NewTime = timer_center:get_correct_now();
				true->
					NewTime = LastTime
			end,
			LeftTime = 0,
			true
	end,
	if
		GuildBattleCheck->
			nothing;
		JSZDBattleCheck->
			nothing;
		not TreasureTransportChcek->
			nothing;
		not CheckCrime->
			nothing;
		TimeCheck->
			proc_set_pkmodel(PkModel,NewTime);
		true->
			Msg = pvp_packet:encode_set_pkmodel_faild_s2c(-LeftTime),
			role_op:send_data_to_gate(Msg)
	end.

proc_set_pkmodel(PkModel,NewTime)->
	NewInfo = set_pkmodel_to_roleinfo(get(creature_info),{PkModel,NewTime}),
	put(creature_info,NewInfo ),
	role_op:update_role_info(get_id_from_roleinfo(NewInfo),NewInfo),
	role_op:self_update_and_broad([{pkmodel,PkModel}]).

check_can_broadcast(LastCrime,Crime)->
	if 
		(LastCrime < ?KILLED_NUM_REACH_50) and (Crime >= ?KILLED_NUM_REACH_50) ->
			system_broadcast(?SYSTEM_CHAT_ROLE_KILL_50,get(creature_info));
		(LastCrime < ?KILLED_NUM_REACH_100) and (Crime >= ?KILLED_NUM_REACH_100)->
			system_broadcast(?SYSTEM_CHAT_ROLE_KILL_100,get(creature_info));
		true ->
			nothing
	end.

system_broadcast(SysId,RoleInfo)->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	system_chat_op:system_broadcast(SysId,[ParamRole]).

%%
%%return:true/false
%%
is_crime_to_prison()->
  get_crime_from_roleinfo(get(creature_info))>=?KILLED_NUM_REACH_100.

should_respawn_in_prison()->
	MurdererId = get(murderer),
	case is_crime_to_prison() of
		true->
			(mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info)))=:=?MAP_TAG_NORMAL) 
				and
			(not instance_op:is_in_instance()) and (creature_op:what_creature(MurdererId) =/= npc);
		_->
			false	
	end.

clear_crime_by_value(Value)->
	Crime = role_op:get_crime_from_roleinfo(get(creature_info)),
	if
		Crime =< 0 ->
			false;
		true ->
			if (Crime - Value) =< 0 ->
				   NewCrime = 0;
			   true ->
				   NewCrime = Crime - Value
			end,
			{SelfModel,_} = get_pkmodel_from_roleinfo(get(creature_info)),
			gm_logger_role:role_change_crime_log(get(roleid),SelfModel,[],NewCrime,Crime,reduce_by_value),
			NewInfo = set_crime_to_roleinfo(get(creature_info),NewCrime),
			put(creature_info,NewInfo),
			role_op:update_role_info(get(roleid),NewInfo),
			role_op:self_update_and_broad([{crime,NewCrime}]),
			ok
	end.

add_crime_by_value(Value)->
	Crime = get_crime_from_roleinfo(get(creature_info)),
	case (Crime + Value) >= ?KILLED_NUM_REACH_100 of
		true->
			NewCrime = ?KILLED_NUM_REACH_100;
		_->
			NewCrime = Crime + Value
	end,
	{SelfModel,_} = get_pkmodel_from_roleinfo(get(creature_info)),
	gm_logger_role:role_change_crime_log(get(roleid),SelfModel,[],NewCrime,Crime,add_by_value),
	NewInfo = set_crime_to_roleinfo(get(creature_info),NewCrime),
	put(creature_info,NewInfo),
	put(crime_time,timer_center:get_correct_now()),
	role_op:update_role_info(get(roleid),NewInfo),
	role_op:self_update_and_broad([{crime,NewCrime}]).

%%return :true/false
can_get_outof_prison()->
	Crime = get_crime_from_roleinfo(get(creature_info)),
	if 
		Crime =< ?CRIME_OUT_PRISON_EDGE ->
			true;
		true ->
			false
	end.

change_crime_by_gm(AddValue)->
	Crime = role_op:get_crime_from_roleinfo(get(creature_info)),
	NewInfo = set_crime_to_roleinfo(get(creature_info),Crime+AddValue),
	put(creature_info,NewInfo),
	role_op:update_role_info(get(roleid),NewInfo),
	role_op:self_update_and_broad([{crime,Crime+AddValue}]).

%%return :true/false
is_in_prison()->
	mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) =:= ?MAP_TAG_PRISON.

check_pvptag()->
	mapop:get_map_pvptag(get_mapid_from_mapinfo(get(map_info))) =:= ?MAP_PVP_ADD_NOTHING_TAG.
%% 
%% clear_crime_by_gold(Gold)->
%% 	Crime = role_op:get_crime_from_roleinfo(get(creature_info)),
%% 	if
%% 		(Crime =:=0) ->
%% 			nothing;
%% 		true ->
%% 			if 
%% 				Gold =< Crime ->
%% 					Clear_Num = Gold;
%% 				true ->
%% 					Clear_Num = Crime
%% 			end,
%% 			CheckMoney = role_op:check_money(?MONEY_GOLD,Clear_Num),
%% 			if 
%% 				CheckMoney ->
%% 					NewInfo = set_crime_to_roleinfo(get(creature_info),Crime - Clear_Num),
%% 					put(creature_info,NewInfo),
%% 					role_op:update_role_info(get(roleid),NewInfo),
%% 					role_op:self_update_and_broad([{crime,Crime - Clear_Num}]),
%% 					role_op:money_change(?MONEY_GOLD, -Clear_Num, clear_crime),
%% 					can_update_quest(Crime - Clear_Num);
%% 				true ->
%% 					nothing
%% 			end
%% 	end.

%% get_role_crime()->
%% 



	