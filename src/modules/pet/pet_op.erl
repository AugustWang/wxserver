%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pet_op).

-compile(export_all).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("common_define.hrl").
-include("game_rank_define.hrl").
-include("skill_define.hrl").
-include("error_msg.hrl").
-include("mnesia_table_def.hrl").
-include("pet_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("pet_def.hrl").
-define(PET_LEVEL_ETS,pet_level_ets).
-define(PET_SHOP_GOLD,10).%%宠物商店10元宝刷新一次
init()->
	put(gm_pets_info,[]),
	put(pets_info,[]),
	put(last_pet_switch_time,{0,0,0}),
	put(max_pet_num,0),
	put(buy_pet_slot,0),	
	put(present_pet_slot,0),		%%赠送的宠物槽位
	put(pet_shop_init_time,0),%%宠物商店初始化时间
	put(mypets_add_talent,[]),
	pet_skill_op:init_pet_skill_info(),
	put(pet_level_time_limit,0).   %%设定宠物升级时间检测

hook_on_got_exp(Value)->
	case get_out_pet() of
		[]->
			nothing;
		PetInfo->
			pet_level_op:obt_exp(PetInfo, Value)
	end.

hook_on_role_levelup(Level)->
	LevelInfo = role_petnum_db:get_info(Level),
	LevelDefault = role_petnum_db:get_default_num(LevelInfo),
	CurSlot = get(max_pet_num) - get(buy_pet_slot) - get(present_pet_slot),
	case LevelDefault > CurSlot of
		true->
			put(max_pet_num,LevelDefault+get(buy_pet_slot)+get(present_pet_slot));
		_->
			nothing
	end. 

hook_on_be_attack(_EnemyId)->
	nothing.

hook_on_attack()->
	nothing.

hook_on_dead()->
	call_back().

load_from_db(RolePetInfo)->
	case RolePetInfo of
		{{buy_pet_slot,BuyPetSlotNum},{present_pet_slot,PresentPetSlot}}->
			nothing;
		_->
			BuyPetSlotNum = 0,
			PresentPetSlot = 0
	end,
	init_form_dbinfo(BuyPetSlotNum,PresentPetSlot).	

init_form_dbinfo(BuyPetSlotNum,PresentPetSlot)->
	init(),
	pet_skill_book_db:init(),
	put(buy_pet_slot,BuyPetSlotNum),
	put(present_pet_slot,PresentPetSlot),
	hook_on_role_levelup(get(level)),
	lists:foreach(fun(PetDbInfo)->
					{GmPetInfo,PetInfo} = load_pet_from_db(PetDbInfo),
					put(gm_pets_info,[GmPetInfo|get(gm_pets_info)]),
					put(pets_info,[PetInfo|get(pets_info)])
				end,pets_db:load_pets_info(get(roleid))).
	
init_pet_talent_rank_sort()->
	lists:foreach(fun(PetInfo)->
						PetId=get_id_from_mypetinfo(PetInfo),
						TalentInfo=pet_talent_op:get_talent_addition_for_role(PetId),
						{Hitrate,Dodge,Criticalrate,Criticaldestroyrate,Toughness,Meleeimmunity,Rangeimmunity,Magicimmunity,Hpmax,Meleepower,Meleedefense}=
																																											pet_talent_op:get_talent_value_from_pet_talent_info(TalentInfo),
						GmPetInfo = get_gm_petinfo(PetId),
						PetName=get_name_from_petinfo(GmPetInfo),
						{Tanelt_Score,RankNum} = pet_util:compute_talent_score(PetId,PetName,Hitrate,Dodge,Criticalrate,Criticaldestroyrate,Toughness,Meleeimmunity,Rangeimmunity,Magicimmunity),
						NewPetInfo =  PetInfo#my_pet_info{talent_score=Tanelt_Score,talent_sort=RankNum},
						put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
						pet_util:recompute_attr(talent_sort,PetId)
					end,get(pets_info)).

%宠物升级信息读取
hook_on_online_join_map()->	
	case get_out_pet() of
		[]->
			nothing;
		OutGmPetInfo->
			%%jia[xiaowu]
			%PetId = get_id_from_petinfo(OutGmPetInfo),
			%PetName = get_name_from_petinfo(OutGmPetInfo),
			%Quality = get_quality_from_petinfo(OutGmPetInfo),
			%Growth = get_growth_value_from_pet_info(OutGmPetInfo),
			%RoleInfo = get(creature_info),
			%RoleName = get_name_from_roleinfo(RoleInfo),
			%Fighting_Force = get_fighting_force_from_petinfo(OutGmPetInfo),
			%game_rank_manager:challenge(PetId, ?RANK_TYPE_PET_FIGHTING_FORCE,{PetName,RoleName,Fighting_Force}),%1月10日加 【小五】
			%game_rank_manager:challenge(PetId, ?RANK_TYPE_PET_GROWTH,{PetName,RoleName,Growth}),
			%game_rank_manager:challenge(PetId, ?RANK_TYPE_PET_QUALITY_VALUE,{PetName,RoleName,Quality}),
			%%jia[xiaowu]
			NewInfo = change_pet_state(OutGmPetInfo,?PET_STATE_BATTLE),
			switch_pet_to_battle([],NewInfo)
	end.

get_gm_petinfo(PetId)->
	case lists:keyfind(PetId,#gm_pet_info.id,get(gm_pets_info)) of
		false->
			[];
		GmPetInfo->
			GmPetInfo
	end.	

send_init_data()->
	SendPets = lists:map(fun(PetInfo)->	
							#my_pet_info{petid = PetId} =PetInfo,
							%PetEquipInfo = get_equipinfo_from_mypetinfo(PetInfo),%%获得宠物装备信息
							PetEquipInfo=[],
							pet_packet:make_pet(PetInfo,get_gm_petinfo(PetId),pet_equip_op:get_body_items_info(PetEquipInfo)) 
						end, get(pets_info)),
	PetsMsg = pet_packet:encode_init_pets_s2c(SendPets,get(max_pet_num),get(present_pet_slot)),
	role_op:send_data_to_gate(PetsMsg),
	%pet_skill_op:send_init_data() ,
	%%枫少修改
	pet_skill_book:init_pet_skill_book(),
%% 	send_levelup_message(),
	init_pet_advance_luvky_value(),
	send_reset_advance_lucky_time().

send_levelup_message()->
	Time=get(pet_level_time_limit),
	if Time>=60->
		 put(pet_level_time_limit,0),
		GamePetinfo1=lists:foldl(fun(PetInfo,Acc)->
										 if Acc=/=[]->
												Acc;
											true->
												if element(#gm_pet_info.state,PetInfo)=:=2->
													Acc++ [PetInfo];
													true->Acc
													end
										end
						end, [],get(gm_pets_info)),
		if  GamePetinfo1=:=[]->
	%% 			erlang:send_after(60000, self(),{pet_levelup,0});
				nothing;
		true->
			[GameInfo|G]=GamePetinfo1,
			Pid=get_id_from_petinfo(GameInfo),
			PetRemainTime=get_leveluptime_s_value_from_pet_info(GameInfo),
			Level=get_level_from_petinfo(GameInfo),
			UpTime=pet_level_db:get_time_of_level(Level),
			if UpTime=:=-1->
			  	    nothing;
		  		true->
			   		pet_attr:only_self_update(Pid,[{remain_time,UpTime-PetRemainTime}])
			end,
	%% 		erlang:send_after(60000, self(),{pet_levelup,Pid})
		pet_level_op:pet_level_up(Pid)
	end;
	true->
		put(pet_level_time_limit,get(pet_level_time_limit)+10)
	end.

save_to_db()->
	lists:foreach(fun(PetInfo)->
		#my_pet_info{petid = PetId} =PetInfo,
		save_pet_by_info(PetInfo,get_gm_petinfo(PetId)) end, get(pets_info)).

save_roleinfo_to_db()->
	{{buy_pet_slot,get(buy_pet_slot)},{present_pet_slot,get(present_pet_slot)}}.

get_max_petnum()->
	get(max_pet_num).

get_cur_petnum()->
	erlang:length(get(pets_info)).

get_petids()->
	lists:map(fun(PetInfo)->
		get_id_from_mypetinfo(PetInfo) end, get(pets_info)).

%%return true |false
get_empty_pet_slot()->	
	get(max_pet_num) > length(get(pets_info)).

swap_slot(_PetId,_Slot)->
%%	case lists:keyfind(PetId,#my_pet_info.petid, get(pets_info)) of
%%		false->
%%			slogger:msg("swap slot error PetId ~p [] Slot ~p ~n",[PetId,Slot]);
%%		PetInfo->
%%			case get(max_pet_num) >= Slot of
%%				true->
%%					case lists:keyfind(Slot,#my_pet_info.slot, get(pets_info)) of
%%						false->
%%							change_slot(PetInfo,Slot);
%%						SlotPetInfo->
%%							MySlot = get_slot_from_mypetinfo(PetInfo),
%%							change_slot(PetInfo,Slot),
%%							change_slot(SlotPetInfo,MySlot)
%%					end;	
%%				_->
%%					slogger:msg("swap slot error PetId ~p Slot ~p ~n",[PetId,Slot])
%%			end
%%	end.
	nothing.

%%change_slot(PetInfo,NewSlot)->
%%	case PetInfo of
%%		[]->
%%			nothing;
%%		_->
%%			PetId = get_id_from_mypetinfo(PetInfo),
%%			put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),set_slot_to_mypetinfo(PetInfo,NewSlot))),
%%			pet_attr:only_self_update(PetId,[{pet_slot,NewSlot}])
%%	end.
			
save_pet_to_db(PetId)->
	case get_pet_info(PetId) of
		[]->
			slogger:msg("save_pet_to_db [] RoleId ~p PetId ~p ~n ",[get(roleid),PetId]);
		PetInfo->
			save_pet_by_info(PetInfo,get_gm_petinfo(PetId))
	end.

load_pet_from_db([])->
	{[],[]};
load_pet_from_db(PetDbInfo)->
	PetId = pets_db:get_petid(PetDbInfo),
	Proto = pets_db:get_protoid(PetDbInfo),
	create_petinfo_bydbinfo(PetId,Proto,pets_db:get_petinfo(PetDbInfo),pets_db:get_skillinfo(PetDbInfo),pets_db:get_equipinfo(PetDbInfo)).

save_pet_by_info(PetInfo,GmPetInfo)->
	#gm_pet_info{id =PetId,master = RoleId,proto = Proto} = GmPetInfo,
	SavePetinfo = make_dbinfo_from_petinfo(PetInfo,GmPetInfo),
	SkillInfo = pet_skill_op:get_pet_skillallinfo(PetId),
	pets_db:save_pet_info(RoleId,PetId,Proto,SavePetinfo,SkillInfo,[],[],[]).

load_by_copy({PetNum,BuyPetSolt,PresentPetSlot,PetInfos,GmPetInfos,Last_switch_time,SkillInfo,TalentInfo})->
	put(max_pet_num,PetNum),
	put(buy_pet_slot,BuyPetSolt),
	put(present_pet_slot,PresentPetSlot),
	put(pets_info,PetInfos),
	put(gm_pets_info,GmPetInfos),
	put(last_pet_switch_time,Last_switch_time),
	case get_out_pet() of
		[]->
			nothing;
		OutGmPetInfo->
			update_gm_pet_info_all(OutGmPetInfo)
	end,
	pet_skill_op:load_by_copy(SkillInfo),
	pet_talent_op:load_by_copy(TalentInfo).


export_for_copy()->
	{
	 get(max_pet_num),
	 get(buy_pet_slot),
	 get(present_pet_slot),
	 get(pets_info),
	 get(gm_pets_info),
	 get(last_pet_switch_time),
	 pet_skill_op:export_for_copy(),
	 pet_talent_op:export_for_copy()
	}.

%%true/false
pet_rename(PetId,NewName)->
	case lists:keyfind(PetId,#gm_pet_info.id, get(gm_pets_info)) of
		false->
			slogger:msg("pet_rename error PetId ~p Roleid ~p ~n",[PetId,get(roleid)]),
			false;
		GmPetInfo->
			NewGmPetInfo = set_name_to_petinfo(GmPetInfo,NewName),
			update_gm_pet_info_all(NewGmPetInfo),
			PetInfo = get_pet_info(PetId),
			NewPetInfo = set_changenameflag_to_mypetinfo(PetInfo,?PET_CHANGE_NAME),
			update_pet_info_all(NewPetInfo),
			game_rank_manager:updata_pet_rank_info(PetId,NewName),
			case get_state_from_petinfo(NewGmPetInfo) of
				?PET_STATE_BATTLE->
					pet_attr:self_update_and_broad(PetId, [{name,NewName}]);
				_->
					pet_attr:only_self_update(PetId, [{name,NewName}])
			end,
			true
	end.

pet_move(PetId,{PosX,PosY},Path,Time)->
	case lists:keyfind(PetId,#gm_pet_info.id, get(gm_pets_info)) of
		false->
			nothing;
		GmPetInfo->
			State = get_state_from_petinfo(GmPetInfo),
			if
				State =:= ?PET_STATE_BATTLE->
					NewGmInfo = GmPetInfo#gm_pet_info{posx = PosX,posy = PosY,path = Path},
					update_gm_pet_info_all(NewGmInfo),
					pet_attr:move_notify_aoi_roles(PetId,{PosX,PosY},Path,Time);
				true->
					nothing
			end
	end.

pet_stop_move(PetId,{PosX,PosY},_Time)->
	case lists:keyfind(PetId,#gm_pet_info.id, get(gm_pets_info)) of
		false->
			nothing;
		GmPetInfo->
			State = get_state_from_petinfo(GmPetInfo),
			if
				State =:= ?PET_STATE_BATTLE->
					NewGmPetInfo = GmPetInfo#gm_pet_info{posx = PosX,posy = PosY,path = []},	
					update_gm_pet_info_all(NewGmPetInfo),
					StopMsg = role_packet:encode_move_stop_s2c(PetId,{PosX,PosY}),
					role_op:broadcast_message_to_aoi_client(StopMsg);
				true->
					nothing
			end
	end.
					
pet_attack(PetId,OriSkillID,OriTargetID)->
	case lists:keyfind(PetId,#gm_pet_info.id, get(gm_pets_info)) of
		false->
			nothing;
		PetInfo->
			case get_state_from_petinfo(PetInfo) of
				?PET_STATE_BATTLE->
					SelfInfo = get(creature_info),
					SelfId = get(roleid),
					PetClass = get_class_from_petinfo(PetInfo),
					OriTargetInfo = creature_op:get_creature_info(OriTargetID),
					case pet_skill_op:check_common_skill(PetClass,OriSkillID) of
						true->
							OriSkillLevel = 1,	%%common skill level	
							OriSkillInfo = skill_db:get_skill_info(OriSkillID, OriSkillLevel),
							case role_op:attack_check(SelfId,OriTargetID,OriTargetInfo,OriSkillInfo) of
								false ->
									nothing;
				 				_->		 	
									Now = timer_center:get_correct_now(),
									CoolCheck = pet_skill_op:check_common_cool(Now),
									JudgeResult = pet_combat_op:pet_judge(PetInfo,SelfInfo, OriTargetInfo,OriSkillInfo),
									if
										JudgeResult and CoolCheck ->			
										%%maybe cast passive skill
										{SkillID,SkillLevel,TargetId} = pet_combat_op:get_passive_skill_on_attack(OriSkillID, OriSkillLevel,PetInfo,SelfId,OriTargetID),
										SkillInfo = skill_db:get_skill_info(SkillID, SkillLevel),
										MyPos = creature_op:get_pos_from_creature_info(SelfInfo),
										if
											TargetId =:= SelfId->
												TargetInfo = SelfInfo;
											true->
												TargetInfo = OriTargetInfo
										end,
										MyTarget = creature_op:get_pos_from_creature_info(TargetInfo),
										Speed = skill_db:get_flyspeed(SkillInfo),
										FlyTime = Speed*util:get_distance(MyPos,MyTarget),	
										case skill_db:get_cast_time(SkillInfo) of
											0 ->
												{ChangedAttr, CastResult} = 
													pet_combat_op:process_pet_instant_attack(PetInfo,SelfInfo, TargetInfo, SkillID, SkillLevel,SkillInfo),
													role_op:process_damage_list(PetId,SelfInfo,SkillID,SkillLevel, FlyTime, CastResult),
													creature_op:combat_bufflist_proc(SelfInfo,CastResult,FlyTime),
													NewInfo2 = role_op:apply_skill_attr_changed(get(creature_info),ChangedAttr),
													put(creature_info, NewInfo2),								
													role_op:update_role_info(SelfId,NewInfo2),
													case pet_combat_op:proc_mp_resume(PetInfo,SkillInfo) of
														[]->
															nothing;
														UpdateAttr->
															[{mp,NewMp}] = UpdateAttr,
															%put(gm_pets_info,lists:keyreplace(PetId, #gm_pet_info.id,  get(gm_pets_info),  set_mana_to_petinfo(PetInfo,NewMp))),
															pet_attr:only_self_update(PetId,UpdateAttr)
													end,
													pet_happiness_cast(PetId);
											_->					%%not support not now
											
												nothing
										end;
									true->
										nothing
								end
						end;
					_->
						nothing
				end;
			_->
				nothing
		end		
	end.

pet_happiness_cast(PetId)->
	case lists:keyfind(PetId, #my_pet_info.petid, get(pets_info)) of
		false->
			slogger:msg("roleid ~p call out PetId ~p error ~n",[get(roleid),PetId]);
		PetInfo->
			GmInfo = get_gm_petinfo(PetId),
			Proto = get_proto_from_petinfo(GmInfo),
			ProtoInfo = pet_proto_db:get_info(Proto),
			{CastRateA,CastRateB} = pet_proto_db:get_happiness_cast(ProtoInfo),
			RandV = random:uniform(CastRateB),
			if
				RandV =< CastRateA->
					OldHappiness = get_happiness_from_mypetinfo(PetInfo),
					NewHappiness = erlang:max(OldHappiness-1,0),
					NewPetInfo = set_happiness_to_mypetinfo(PetInfo,NewHappiness),
					put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
					pet_util:recompute_attr(happiness,PetId),
					if
						NewHappiness =:= 0->
							call_back_by_info(GmInfo);
						true->
							nothing
					end;
				true->
					nothing
			end
	end.

call_out(PetId)->
	case spa_op:is_in_spa() of
		true->
			ErrorMsg = pet_packet:encode_pet_opt_error_s2c(?ERRNO_CAN_NOT_DO_IN_SPA),
			role_op:send_data_to_gate(ErrorMsg);
		_->
			Now = timer_center:get_correct_now(),
			case lists:keyfind(PetId, #gm_pet_info.id, get(gm_pets_info)) of
				false->
					slogger:msg("roleid ~p call out PetId ~p error ~n",[get(roleid),PetId]);
				GmPetInfo->
					case timer:now_diff(timer_center:get_correct_now(),get(last_pet_switch_time)) >= ?PET_SWITCH_COOLTIME*1000 of
						true->
							put(last_pet_switch_time,Now),
							case get_state_from_petinfo(GmPetInfo) of
								?PET_STATE_IDLE->
									Proto = get_proto_from_petinfo(GmPetInfo),
									ProtoInfo = pet_proto_db:get_info(Proto),
									MinTakeLevel =pet_proto_db:get_min_take_level(ProtoInfo),
									case MinTakeLevel > get(level) of
										true->
											Msg = pet_packet:encode_pet_opt_error_s2c(?ERROR_PET_MASTER_LESS_LEVEL),
											role_op:send_data_to_gate(Msg);
										_->
											case lists:keyfind(?PET_STATE_BATTLE, #gm_pet_info.state, get(gm_pets_info)) of
												false->
													OldGmPetInfo = [],
													NewGmPetInfo = change_pet_state(GmPetInfo,?PET_STATE_BATTLE),
													switch_pet_to_battle(OldGmPetInfo,NewGmPetInfo);
												OldGmPetInfo->
													case get_id_from_petinfo(OldGmPetInfo) =/= PetId of
														true->
															NewInfo1 = change_pet_state(OldGmPetInfo,?PET_STATE_IDLE),
															NewInfo2 = change_pet_state(GmPetInfo,?PET_STATE_BATTLE),
															switch_pet_to_battle(NewInfo1,NewInfo2);
														_->
															nothing
													end
											end
									end;
								OtherState->
									slogger:msg("call_out()PetId ~p State ~p roleid ~p ~n",[PetId,OtherState,get(roleid)])
							end;
						_->
							nothing
					end
			end
	end.

call_back(PetId)->
	case lists:keyfind(PetId, #gm_pet_info.id, get(gm_pets_info)) of
		false->
			slogger:msg("roleid ~p call out PetId ~p error ~n",[get(roleid),PetId]);
		PetInfo->
			call_back_by_info(PetInfo)
	end.

%%
%%return true|false|full
%%
add_pet_happiness(PetId,Value)->
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			false;
		PetsInfo->
			case get_happiness_from_mypetinfo(PetsInfo) of
				?PET_MAX_HAPPINESS->
					full;
				Happiness->
					NewHappiness = erlang:min(Happiness+Value,?PET_MAX_HAPPINESS),
					NewPetInfo = set_happiness_to_mypetinfo(PetsInfo,NewHappiness),
					put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
					pet_attr:only_self_update(PetId,[{pet_happiness,NewHappiness}]),
					%pet_util:recompute_attr(happiness,PetId),
					case lists:keyfind(PetId, #gm_pet_info.id, get(gm_pets_info)) of
						false->
							nothing;
						GmPetInfo->
							PetProto = get_proto_from_petinfo(GmPetInfo),
							gm_logger_role:pet_feed(get(roleid),PetId,NewHappiness,PetProto)
					end,					
					true
			end
	end.
	
buy_pet_slot()->
	CurNum = get(buy_pet_slot),
	NewNum = CurNum + 1,
	case pet_slot_db:get_info(NewNum) of
		[]->
			nothing;
		SlotInfo->
			{MoneyType, MoneyCount} = pet_slot_db:get_price(SlotInfo),
			case role_op:check_money(MoneyType, MoneyCount) of
				true->
					role_op:money_change( MoneyType, -MoneyCount,buy_pet_slot),
					put(buy_pet_slot,NewNum),
					put(max_pet_num,get(max_pet_num)+1),
					MessageBin = pet_packet:encode_update_pet_slot_num_s2c(get(max_pet_num)),
					role_op:send_data_to_gate(MessageBin);
				_->
					MessageBin = pet_packet:encode_pet_opt_error_s2c(?ERROR_LESS_GOLD),
					role_op:send_data_to_gate(MessageBin)
			end
	end.
	
dismount_pet(PetId)->
%%	role_sitdown_op:hook_on_action_async_interrupt(timer_center:get_correct_now(),dismount_pet),
	case lists:keyfind(PetId, #gm_pet_info.id, get(gm_pets_info)) of
		false->
			nothing;
		PetInfo->
			dismount_by_info(PetInfo)
	end.

call_back()->
	case get_out_pet() of
		[]->
			nothing;
		GmPetInfo->
			call_back_by_info(GmPetInfo)
	end.
			
call_back_by_info(GmPetInfo)->
	case get_state_from_petinfo(GmPetInfo) of
		?PET_STATE_BATTLE->
			NewInfo = change_pet_state(GmPetInfo,?PET_STATE_IDLE),
			switch_pet_to_battle(NewInfo,[]);
		_->
			nothing
	end.

dismount_by_info(PetInfo)->
	nothing.

change_pet_state(GmPetInfo,Type)->
	PetId = get_id_from_petinfo(GmPetInfo),
	case Type of
		?PET_STATE_BATTLE->
			{PosX,PosY} = get_pos_from_roleinfo(get(creature_info)),
			NewGmInfo = GmPetInfo#gm_pet_info{state = Type,posx =PosX + 2,posy = PosY,path=[]};
		_->
			NewGmInfo = GmPetInfo#gm_pet_info{state = Type,path=[]}
	end,
	put(gm_pets_info,lists:keyreplace(PetId, #gm_pet_info.id,  get(gm_pets_info), NewGmInfo)),
	UpdateAttr = [{state, Type}],
	pet_attr:only_self_update(PetId,UpdateAttr),
	NewGmInfo.

%%no buffer 
switch_pet_to_battle(OldGmPetInfo,GmPetInfo)->
	case OldGmPetInfo of
		[]->	
			OutPetId = 0,
			OldPetProto = 0,
			nothing;
		_->			
			OutPetId = get_id_from_petinfo(OldGmPetInfo),
			OldPetProto = get_proto_from_petinfo(OldGmPetInfo),
			pet_manager:unregist_pet_info(OutPetId),
			pet_attr:pet_out_view_broad(OutPetId)
	end,
	case GmPetInfo of
		[]->
			PetProto = 0,
			PetId = 0;
		_->
			PetId = get_id_from_petinfo(GmPetInfo),
			pet_manager:regist_pet_info(PetId, GmPetInfo),
			pet_attr:pet_into_view_broad(GmPetInfo),
			PetProto = get_proto_from_petinfo(GmPetInfo)
	end,
	gm_logger_role:pet_change(get(roleid),OldPetProto,OutPetId,PetProto,PetId),
	put(creature_info, set_pet_id_to_roleinfo(get(creature_info), PetId)),
	role_op:recompute_pet_attr(),
	   role_fighting_force:hook_on_change_role_fight_force().

update_gm_pet_info_all(NewGmPetInfo)->
	PetId = get_id_from_petinfo(NewGmPetInfo),
	put(gm_pets_info,lists:keyreplace(PetId, #gm_pet_info.id,  get(gm_pets_info), NewGmPetInfo)),
	case get_state_from_petinfo(NewGmPetInfo) of
		?PET_STATE_BATTLE->
			pet_manager:regist_pet_info(PetId , NewGmPetInfo);
		_->
			nothing
	end.

update_pet_info_all(NewInfo)->
	PetId = get_id_from_mypetinfo(NewInfo),
	put(pets_info,lists:keyreplace(PetId, #my_pet_info.petid,  get(pets_info), NewInfo)).
%%returen :true / false
apply_create_pet(ProtoId,Type,Quality)->
	case pet_proto_db:get_info(ProtoId) of
		[]->
			slogger:msg("apply_create_pet error ProtoId ~p Quality ~p ~n",[ProtoId,Quality]),
			false;
		PetProtoInfo->
			case pet_proto_db:get_min_take_level(PetProtoInfo) =< get(level) of
				true->
					case get_empty_pet_slot() of
						false->
							Errno = ?ERROR_BATTLEPET_GOT_SLOT;
						_->
							Errno  = [],
							create_pet(ProtoId,Type,Quality,PetProtoInfo)
					end;
				_->
					Errno = ?ERROR_PET_GOT_LEVEL
			end,
			if
				Errno=:=[]->
					true;
				true->
					role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno)),
					false
			end
	end.

%%apply_create_pet_by_info(PetInfo)->
%%	ProtoId = get_proto_from_petinfo(PetInfo),
%%	PetProtoInfo = pet_proto_db:get_info(ProtoId),
%%	case pet_proto_db:get_min_take_level(PetProtoInfo) =< get(level) of
%%		true->
%%			case get_new_pet_slot(PetProtoInfo) of
%%				{full,Errno}->
%%					nothing;
%%				Slot->
%%					Errno  = [],
%%					create_pet(PetInfo,PetProtoInfo,Slot)
%%			end;
%%		_->
%%			Errno = ?ERROR_PET_GOT_LEVEL
%%	end,
%%	if
%%		Errno=:=[]->
%%			true;
%%		true->
%%			role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno)),
%%			false
%%	end.
	
%%create_pet(PetInfo,PetProtoInfo,Slot)->
%%	PetId = petid_generator:gen_newid(),
%%	NewPetInfo = PetInfo#gm_pet_info{id = PetId,slot = Slot},
%%	add_pet_by_petinfo(NewPetInfo,PetProtoInfo).

create_pet(ProtoId,Type,Quality,PetProtoInfo)->
	PetId = petid_generator:gen_newid(),
	{PetInfo,GmPetInfo} = apply_info_with_args(PetProtoInfo,ProtoId,Type,Quality,PetId),
	add_pet_by_petinfo(PetInfo,GmPetInfo,PetProtoInfo).

add_pet_by_petinfo(PetInfo,GmPetInfo,PetProtoInfo)->	
	PetId = get_id_from_mypetinfo(PetInfo),
	put(pets_info,[PetInfo|get(pets_info)]),
	put(gm_pets_info,[GmPetInfo|get(gm_pets_info)]),
	PetEquipInfo=[],
	CreatePet = pet_packet:make_pet(PetInfo,GmPetInfo,pet_equip_op:get_body_items_info(PetEquipInfo)),
	Msg = pet_packet:encode_create_pet_s2c(CreatePet),
	role_op:send_data_to_gate(Msg),
	save_pet_to_db(PetId),
	Quality=get_quality_from_petinfo(GmPetInfo),
	achieve_op:achieve_update({pet},[Quality],1),
	pet_util:game_pet_all_rank(PetId).

apply_info_with_args(PetProtoInfo,ProtoId,Type,Quality,PetId)->
	Level = 1,
	Life = 0,
	Exp = 0,
	Xs=pet_packet:make_pet_xs(100, 120, 120, 100, 120, 100, 120, 100, 120, 120, 100, 100, 120, 100),
	PetLevelInfo = pet_level_db:get_info(Level),
	TotalExp = pet_level_db:get_exp(PetLevelInfo),
	Mana = pet_level_db:get_maxmp(PetLevelInfo),%%血量
	Mpmax = 0,
	Hpmax = 0,
	Lucky=0,
	%Icon = [],					%%称号《枫少》
	RandomV0 = random:uniform(100),
	Gender = 
		case pet_proto_db:get_femina_rate(PetProtoInfo) >= RandomV0 of
			true->
				?GENDER_FEMALE;
			_->
				?GENDER_MALE
		end,
	Name = pet_proto_db:get_name(PetProtoInfo),
	Class =Type,	
	Pos = get_pos_from_roleinfo(get(creature_info)),
	State = ?PET_STATE_IDLE,
	Quality_Up_Value=get_pet_born_quality_up_value(Quality),
	Quality_Value=get_pet_born_quality_value(Quality),
	Happiness = ?PET_MAX_HAPPINESS,
	SystemAttr = pet_util:get_system_attr_add(Level,Quality_Value),
	{MeleePower,RangePower,MagicPower,Meleedefence,Rangedefence,Magicdefence,Dodge_Attr,Hitrate_attr,Criticalrate_attr,CriticalDamage_attr,
	 Toughness_attr,Meleeimu_attr,Trangeimu_attr,Magicimu_attr}=SystemAttr,
	Talent=pet_talent_db:get_init_pet_talent_info(),
	HappinessEff = pet_util:get_happiness_eff(Happiness),
	TradeLock = ?PET_TRADE_UNLOCK,
	Power=MeleePower,%%枫少修改所有数据后边均从数据库中取得
	HitRate=Hitrate_attr,
	CriticalRate=Criticalrate_attr,
	CriticalDamage=CriticalDamage_attr,
	Stamina=Toughness_attr,
	Icon=[],
	Attrinfo=pet_advanced_db:get_pet_attr_base_info(Type),
	if Attrinfo=:=[]->
		   Newpower=0,
		   Newhp=0,
		   Newdefence=0;
	   true->
		   Newpower=pet_advanced_db:get_power_from_base(Attrinfo),
		   Newhp=pet_advanced_db:get_hp_from_base(Attrinfo),
		   Newdefence=pet_advanced_db:get_defence_from_base(Attrinfo)
	end,
	Growthvalue=20,
	Meleepower=MeleePower,
	Rangepower=RangePower,
	Magicpower=MagicPower,
	Hp=Mana,
	Dodge=Dodge_Attr,
	Toughness=Toughness_attr,
	Meleeimu=Meleeimu_attr,
	Rangeimu=Trangeimu_attr,
	Magicimu=Magicimu_attr,
	Leveluptime=60,
	Transform=pet_proto_db:get_pet_transform_by_quality(Quality_Value),%%宠物属性转换率
	Social=1,
	Skill=pet_skill_op:create_pet_init_skill(Quality_Value),
	Fighting_Force = pet_fighting_force:computter_fight_force(Hp+Newhp,Meleepower+Newpower,Rangepower+Newpower,Magicpower+Newpower,Meleedefence+Newdefence,Rangedefence+Newdefence,Magicdefence+Newdefence),
	GmPetInfo = create_petinfo(PetId,get(roleid),ProtoId,Level,Name,Gender,Social,Quality,
				Class,State,Pos,HitRate,CriticalRate,CriticalDamage,Fighting_Force,Icon,
				Growthvalue,Meleepower+Newpower,Rangepower+Newpower,Magicpower+Newpower,Meleedefence+Newdefence,Rangedefence+Newdefence,Magicdefence+Newdefence,Hp+Newhp,Dodge,Toughness,Meleeimu,Rangeimu,
	 		    Magicimu,Leveluptime,Transform),
	PetInfo=create_mypetinfo(PetId,Xs,Quality_Value,Quality_Up_Value,Happiness,HappinessEff,0,0,Talent,Skill,TradeLock,(not ?PET_CHANGE_NAME),Lucky),
	{PetInfo,GmPetInfo}.

delete_pet(PetId,NeedCheck)->
	case get_pet_gminfo(PetId) of
		[]->
			slogger:msg("delete_pet error PetId [] ~p ~n",[PetId]);
		GmPetInfo->
			case get_state_from_petinfo(GmPetInfo) of
				?PET_STATE_IDLE->
					Proto = get_proto_from_petinfo(GmPetInfo),
					CanDelete = pet_proto_db:get_can_delete(pet_proto_db:get_info(Proto)),
					case NeedCheck and (CanDelete =/= ?PET_CAN_DELETE) of
						true->
							nothing;
						_->
							PetInfo = get_pet_info(PetId), 
							put(pets_info,lists:keydelete(PetId, #my_pet_info.petid, get(pets_info))),
							put(gm_pets_info,lists:keydelete(PetId, #gm_pet_info.id, get(gm_pets_info))),
							pet_equip_op:hook_on_pet_destroy(PetInfo),
							pet_skill_op:delete_pet(PetId),
							pets_db:del_pet(PetId,get(roleid)),	
							%game_rank_manager:pet_lose_rank(PetId),	
							game_rank_db:delete_role_from_db(PetId),			
							Msg = pet_packet:encode_pet_delete_s2c(PetId),
							role_op:send_data_to_gate(Msg),
							gm_logger_role:pet_delete(get(roleid),PetId,NeedCheck,Proto)
					end;
				State->
					slogger:msg("delete_pet error PetId  ~p State ~p ~n",[PetId,State])
			end
	end.		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Base op%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

has_out_pet()->
	lists:keymember(fight,#gm_pet_info.state, get(gm_pets_info)).

is_out_pet(PetId)->
	case lists:keyfind(?PET_STATE_BATTLE,#gm_pet_info.state, get(gm_pets_info)) of
		false->
			false;
		PetInfo->
			PetId=:= get_id_from_petinfo(PetInfo)
	end.

get_pet_info(PetId)->
	case lists:keyfind(PetId, #my_pet_info.petid, get(pets_info)) of
		false->
			[];
		PetInfo->
			PetInfo
	end.

get_pet_gminfo(PetId)->
	case lists:keyfind(PetId, #gm_pet_info.id, get(gm_pets_info)) of
		false->
			[];
		PetInfo->
			PetInfo
	end.

get_out_pet_id()->
	case lists:keyfind(?PET_STATE_BATTLE,#gm_pet_info.state, get(gm_pets_info)) of
		false->
			0;
		Info->
			get_id_from_petinfo(Info)
	end.

get_out_pet()->
	case lists:keyfind(?PET_STATE_BATTLE,#gm_pet_info.state, get(gm_pets_info)) of
		false->
			[];
		Info->
			Info
	end.

make_dbinfo_from_petinfo(PetInfo,GmPetInfo)->
	#my_pet_info{			
				%attr_user_add = AttrUserAddInfo,
			%	talent_add = TalentAddInfo,
				xs=Xs,
				talent=Talent,
				skill=Skill,
				happiness = Happiness,
				quality_value = Quality_Value,
				quality_up_value = Quality_Up_Value,
				trade_lock = TradeLock,
				changenameflag = ChangeNameFlag,
				lucky=Lucky
				} = PetInfo,
	#gm_pet_info{level = Level,
				name = Name,
				gender = Gender,
			%	mana = Mana,
			%	exp = Exp,
				quality=Quality,
				class=Class,
				social=Social,            %%阶级=
				growth_value=Growth_value,
				leveluptime_s=LevelTime,
				state = State,
				proto = Proto,
				 hp=Hp
				}=GmPetInfo,
	{Level,Name,Gender,Class,Quality,Social,Growth_value,LevelTime,Xs,Talent,Skill,Quality_Value,Quality_Up_Value,Happiness,State,TradeLock,ChangeNameFlag,Lucky}.

get_pet_add_attr()->
	get_add_attr(get_out_pet()).

%%
%%出战宠物体质对主人血量上限的加成
%% hpmax = pet_stamina * PET_STAMINA_FACTOR
%%

get_add_attr([])->
	[];
get_add_attr(GmPetInfo)->
	PetId = get_id_from_petinfo(GmPetInfo),
	Power=get_meleepower_value_from_pet_info(GmPetInfo),
	TransFormRate=get_transform_value_from_pet_info(GmPetInfo),%%宠物属性转换（转换率*属性值）（枫少）
	Hp=get_hp_value_from_pet_info(GmPetInfo),
	Meleedefence=get_meleedefence_value_from_pet_info(GmPetInfo),
	Rangedefence=get_rangedefence_value_from_pet_info(GmPetInfo),
	Magicdefence=get_magicdefence_value_from_pet_info(GmPetInfo),
	TalentInfo=pet_util:get_talent_attr_master(PetId),
	TalentInfo++[{hpmax,Hp*TransFormRate div 100},{power,Power*TransFormRate div 100},
				 {meleedefense,Meleedefence*TransFormRate div 100},{rangedefense,Rangedefence*TransFormRate div 100},
				 {magicdefense,Magicdefence*TransFormRate div 100}]++ pet_util:get_skill_attr_master(PetId).

create_petinfo_bydbinfo(PetId,Proto,PetDBInfo,PetDbSkillInfo,EquipInfo)->
	case PetDBInfo of
			{Level,Name,Gender,Class,Quality,Social,Growth_value,LevelupTime,Xs,Talent,Skill,Quality_Value,Quality_Up_Value,Happiness,State,TradeLock,ChangeNameFlag,Lucky}->
			Pos = {0,0},
			PetLevelInfo = pet_level_db:get_info(Level),
			Icon = [],
			ProtoInfo = pet_proto_db:get_info(Proto),
			SystemAttr = pet_util:get_system_attr_add(Level,Quality_Value),
			{MeleePower,RangePower,MagicPower,Meleedefence,Rangedefence,Magicdefence,Dodge,Hitrate,Criticalrate,CriticalDamage,
			 Toughness,Meleeimu,Trangeimu,Magicimu}=SystemAttr,
			Hp = pet_level_db:get_maxmp(PetLevelInfo),%%血量
			if Social=:=1->
				   Attrid=Class;
			  true->
				   Attrid=Social*1000+Class
			end,
			Attrinfo=pet_advanced_db:get_pet_attr_base_info(Attrid),
				if Attrinfo =:=[]->
				   Hpbase=0,
				   Powerbase=0,
				   Defencebase=0;
			   true->
				   Hpbase=pet_advanced_db:get_hp_from_base(Attrinfo),
				   Powerbase=pet_advanced_db:get_power_from_base(Attrinfo),
				   Defencebase=pet_advanced_db:get_defence_from_base(Attrinfo)
				end,
					Transform=Transform=pet_proto_db:get_pet_transform_by_quality(Quality_Value),%%宠物属性转换率,	
					pet_skill_op:init_pet_skill(PetId,PetDbSkillInfo),		
					Xsmeleepower=pet_packet:get_meleepower_xs(Xs),
					Xsrangepower=pet_packet:get_rangpower_xs(Xs),
					Xsmagicpower=pet_packet:get_magicpower_xs(Xs),
					Xsmeleedefence=pet_packet:get_meleedefence_xs(Xs),
					Xsrangedefence=pet_packet:get_rangedefence_xs(Xs),
					Xsmagicdefence=pet_packet:get_magicdefence_xs(Xs),
					Xshp=pet_packet:get_hp_xs(Xs),
					NewMeleepower=erlang:round((MeleePower+ Powerbase)*(Xsmeleepower/100))+(Growth_value-20)*2,
					NewRangepower=erlang:round((MeleePower+ Powerbase)*(Xsrangepower/100))+(Growth_value-20)*2,
					NewMagicpower=erlang:round((MeleePower+ Powerbase)*(Xsmagicpower/100))+(Growth_value-20)*2,
					NewRangedefence=erlang:round((Meleedefence+Defencebase)*(Xsmeleedefence/100))+(Growth_value-20)*1,
					NewMeleedefence=erlang:round((Meleedefence+Defencebase)*(Xsmeleedefence/100))+(Growth_value-20)*1,
					NewMagicdefence=erlang:round((Meleedefence+Defencebase)*(Xsmagicdefence/100))+(Growth_value-20)*1,
					Newhp=erlang:round((Hp+Hpbase)*(Xshp/100))+(Growth_value-20)*10,
					Fighting_Force = pet_fighting_force:computter_fight_force(Newhp,NewMeleepower,NewRangepower,NewMagicpower,NewMeleedefence,NewRangedefence,NewMagicdefence),
					GmPetInfo = create_petinfo(PetId,get(roleid),Proto,Level,Name,Gender,Social,Quality,                                                                        %%枫少《宠物信息更改》
					Class,State,Pos,Hitrate,Criticalrate,CriticalDamage,Fighting_Force,Icon,Growth_value,
					NewMeleepower,NewRangepower,NewMagicpower,NewMeleedefence,NewRangedefence,NewMagicdefence,Newhp,Dodge,Toughness,Meleeimu,Trangeimu,
			 		Magicimu,LevelupTime,Transform),
					PetInfo = create_mypetinfo(PetId,Xs,Quality_Value,Quality_Up_Value,Happiness,Happiness,0,?PET_TALENTS_SORT_FAILED,Talent,Skill,TradeLock,ChangeNameFlag,Lucky),
					{GmPetInfo,PetInfo};
		_->
			slogger:msg("load pet_from_db error format PetDBInfo ~p ~n ",[PetDBInfo]),
			{[],[]}
	end.
			
create_petinfo_byproto()->
	todo.
create_petinfo_bybaseinfo()->
	todo.

proc_pet_item_equip(equip,PetId,Slot)->
	case get_pet_info(PetId) of
		[]->
			nothing;
		MyPetInfo->
			case pet_equip_op:proc_equip_pet_item(PetId,MyPetInfo,Slot) of
				[]->
					nothing;
				NewEquipInfo->
					%NewPetInfo = set_equipinfo_to_mypetinfo(MyPetInfo,NewEquipInfo),
					%put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
					pet_util:recompute_attr(equip,PetId)
			end
	end;
proc_pet_item_equip(unequip,PetId,Slot)->
	case get_pet_info(PetId) of
		[]->
			nothing;
		MyPetInfo->
			case pet_equip_op:proc_unequip_pet_item(PetId,MyPetInfo,Slot) of
				[]->
					nothing;
				NewEquipInfo->
				%	NewPetInfo = set_equipinfo_to_mypetinfo(MyPetInfo,NewEquipInfo),
					%put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
					pet_util:recompute_attr(equip,PetId)
			end
	end.

hook_item_destroy_on_pet(ItemInfo)->
	ItemId = get_id_from_iteminfo(ItemInfo),
	case lists:filter(fun(MyPetInfo)-> pet_equip_op:is_in_pet_body(MyPetInfo,ItemId) end,get(pets_info)) of
		[]->
			nothing;
		[MyPetInfo]->
			PetId = get_id_from_mypetinfo(MyPetInfo),
			NewEquipInfo = pet_equip_op:proc_item_destroy_on_pet(MyPetInfo,ItemId),
			%NewPetInfo = set_equipinfo_to_mypetinfo(MyPetInfo,NewEquipInfo),
			%put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
			pet_util:recompute_attr(equip,PetId)
	end.
	
hook_item_attr_changed(ItemId)->
	case lists:filter(fun(MyPetInfo)-> pet_equip_op:is_in_pet_body(MyPetInfo,ItemId) end,get(pets_info)) of
		[]->
			nothing;
		[MyPetInfo]->
			PetId = get_id_from_mypetinfo(MyPetInfo),
			pet_util:recompute_attr(equip,PetId)
	end.

create_petinfo_byoldinfo(PetId,PetProto,PetInfo,GmPetInfo)->
	#my_pet_info{
				petid = OldPetId,			
				%attr_user_add = AttrUserAddInfo,
				%talent_add = TalentAddInfo,
				happiness = Happiness,
				quality_value = Quality_Value,
				quality_up_value = Quality_Up_Value,
				trade_lock = TradeLock,
				changenameflag = ChangeNameFlag
				} = PetInfo,
	#gm_pet_info{level = Level,
				name = Name,
				gender = Gender,
		   %	mana = Mana,
			%	exp = Exp,
				state = State,
				proto = Proto
				}=GmPetInfo,
	ProtoInfo = pet_proto_db:get_info(Proto),	
	QualityInfo = pet_proto_db:get_quality_to_growth(ProtoInfo),
	{Quality_Value_Min,Quality_Value_Max} = pet_util:get_adapt_qualityinfo(1,QualityInfo),
	Quality_Up_Value_Add = erlang:max(Quality_Up_Value - Quality_Value_Min,0),
	Quality_Value_Add = erlang:max(Quality_Value - Quality_Value_Min,0),
	PetEquipInfo = pet_equip_op:init_pet_equipinfo(),
	PetDbInfo = {Level,Name,Gender,Quality_Value,Quality_Up_Value,Happiness,State,TradeLock,ChangeNameFlag},
	create_petinfo_bydbinfo(PetId,PetProto,PetDbInfo,SkillInfo = pet_skill_op:get_pet_skillallinfo(OldPetId),PetEquipInfo).


%% for [{{X1,Y2},Rate1},{{X2,Y2},Rate2}] list.
apply_ran_list(RandomList)->
	MaxRate = lists:foldl(fun(ItemRate,LastRate)->
						LastRate +element(2,ItemRate)
				end, 0, RandomList),
	RandomV = random:uniform(MaxRate),
	{Value,_} = lists:foldl(fun({{X1,X2},RateTmp},{Value,LastRate})->
						if
							Value=/= []->
								{Value,0};
							true->
								if
									LastRate+RateTmp >= RandomV->
										%{X1 + (RandomV rem (X2-X1+1)),0};
											{X2,0};
									true->
										{[],LastRate+RateTmp}
								end
						end
				end, {[],0}, RandomList),
	Value,
	Quality_Value=if Value <10->
						 10;
					 true->Value
				  end,
	Quality_Value.
	
	
	
gm_change_happiness(Value)->
	case get_out_pet() of
		[]->
			nothing;
		GmPetInfo->
			PetId = get_id_from_petinfo(GmPetInfo),
			PetInfo = get_pet_info(PetId),
			OldHappiness = get_happiness_from_mypetinfo(PetInfo),
			NewHappiness = OldHappiness + Value,
			NewPetInfo = set_happiness_to_mypetinfo(PetInfo,erlang:min(erlang:max(NewHappiness,0),?PET_MAX_HAPPINESS)),
			put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
			pet_util:recompute_attr(happiness,PetId)
	end.

get_pet_shop_item_list(Type)->
	if Type=:=0->
			case pet_proto_db:get_pet_shopinfo(get(roleid)) of
				[]->
					pet_shop_init_s2c();
				Info->
					Shopinfo=pet_proto_db:get_pet_shopinfo_from_shopinfo(Info),
					Time=pet_proto_db:get_pet_shoptime_from_shopinfo(Info),
					{Time1,Time2}=calendar:now_to_local_time(now()),
					Secounds=calendar:time_to_seconds(Time2),
					RemainTime=Secounds-Time,
					NewRemainTime=
						if RemainTime>=0->
							   RemainTime;
						   true->
							   -RemainTime
						end,
					if NewRemainTime>=3600->
						   pet_shop_init_s2c();
					   true->
						   Message=pet_packet:encode_pet_shop_init_s2c(3600-NewRemainTime,Shopinfo),
							role_op:send_data_to_gate(Message)
					end
			end;
	   Type=:=1->
		  HasMoney= role_op:check_money(?MONEY_GOLD, ?PET_SHOP_GOLD),
		  if not HasMoney->
				 nothing;
			 true->
				 pet_shop_init_s2c(),
				 role_op:money_change(?MONEY_GOLD, -?PET_SHOP_GOLD, fresh_pet_shop)
		  end;
	   true->
		   nothing
	end.
		   
pet_shop_init_s2c()->
			RandomList=create_random([random:uniform(16),random:uniform(12)],0),
			PetItemInfo=pet_proto_db:get_pet_item_info(RandomList),
			SoltNum=1,
			ShopInfo=pet_packet:create_pet_shopinfo(PetItemInfo,SoltNum,[]),
			pet_proto_db:write_pet_shopinfo_to_mnesia(ShopInfo),
			Message=pet_packet:encode_pet_shop_init_s2c(3600,ShopInfo),
			role_op:send_data_to_gate(Message).

create_random(Random,Num)->
	Rand=random:uniform(8),
	NewNum=Num+1,
	if NewNum>=5->NewRandom=[Rand|Random];
		    true->
				create_random([Rand|Random],NewNum)
	end.

get_petproto_id(Slot)->
	case  pet_proto_db:get_pet_shopinfo(get(roleid))  of
		[]->
				role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(10881));
		Info->
			Shopinfo=pet_proto_db:get_pet_shopinfo_from_shopinfo(Info),
			Time=pet_proto_db:get_pet_shoptime_from_shopinfo(Info),
			case lists:keyfind(Slot, 2, Shopinfo) of
				false->
						role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(10881));
				{ps,_,Proto,Money,Quality}->
					case role_op:check_money(?MONEY_BOUND_SILVER, Money) of
						true->
							case pet_proto_db:get_pet_item_info([Slot]) of
								[]->nothing;
								[ItemShopInfo]->
									PetProto=pet_proto_db:get_pet_proto_from_itemshop(ItemShopInfo),
									Type=pet_proto_db:ge_pet_classtype_from_itemshop(ItemShopInfo),
								case pet_proto_db:get_info(PetProto) of
									[]->
										slogger:msg("apply_create_pet error ProtoId ~p Quality ~p ~n",[PetProto,Quality]),
										false;
									Petinfo->
											 role_op:money_change(?MONEY_BOUND_SILVER, -Money, lost_equip_move),
											case apply_create_pet(Proto,Type,Quality) of
												true->
														 update_pet_shop_info_s2c(Shopinfo,Time,Slot);
											   false->
												   nothing
											end
									end
							end;
						Other->
								Errno=?ERROR_LESS_MONEY,
									role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno))
					end
			end
	end.

%宠物加速升级
pet_addspeed_levelup(Pid)->
	GamePetInfo= get_pet_gminfo(Pid),
	if GamePetInfo=:=[]->
		   nothing;
		erlang:element(#gm_pet_info.state, GamePetInfo)=/=2->
			nothing;
	   true->
	   Petleveltime=get_leveluptime_s_value_from_pet_info(GamePetInfo),
	   Petlevel=get_level_from_petinfo(GamePetInfo),
	   Ntime=pet_level_db:get_time_of_level(Petlevel),
	   Remain=Ntime-Petleveltime,
	   Ngold=Remain/120,
	   Gold=ceil(Ngold),
	   Hasgold=role_op:check_money(?MONEY_GOLD, Gold),
	   RoleLevel=get_level_from_roleinfo(get(creature_info)),
	   if not Hasgold->
			  Error=?ERROR_LESS_GOLD,
		  	  MessageBin = pet_packet:encode_pet_opt_error_s2c(?ERROR_LESS_GOLD),
			role_op:send_data_to_gate(MessageBin);
		  true->
			  if Petlevel>=100->
					 nothing;
				 Petlevel-RoleLevel>=5->
					 nothing;
				 true->
					 Var=pet_level_op:pet_levelup_add_speed(Petlevel+1, Pid),
			        role_op:money_change(?MONEY_GOLD, -Gold, pet_levelspeed)
			  end
	   end
			  
end.
	   
ceil(N)->
	T=erlang:trunc(N),
	if T==N->
		   T;
	   true->
		   T+1
	end.

%%购买宠物猴更新宠物商店
update_pet_shop_info_s2c(ShopInfo,Time,Slot)->
	NewShopInfo= lists:keydelete(Slot,2, ShopInfo),
	 pet_proto_db:pet_shopinfo_update(NewShopInfo, Time),
	{Time1,Time2}=calendar:now_to_local_time(now()),
	Secounds=calendar:time_to_seconds(Time2),
	RemainTime=Secounds-Time,
	if RemainTime>=3600->
		   pet_shop_init_s2c();
	   true->
		   Message=pet_packet:encode_pet_shop_init_s2c(3600-RemainTime,NewShopInfo),
			role_op:send_data_to_gate(Message)
	end.

%%宠物出生资质写死<白色 10，绿色15，蓝色20，紫色25>
get_pet_born_quality_value(Quality)->
	if Quality=:=1->
		   10;                   
	   Quality=:=2->
		   15;
	   Quality=:=3->
		   20;
	   Quality=:=4->
		   25
	end.
get_pet_born_quality_up_value(Quality)->
	if Quality=:=1->
		   30;
	   Quality=:=2->
		   50;
	   Quality=:=3->
		   75;
	   Quality=:=4->
		   100;
	   true->
		   30
	end.

%%玩家上线检测	
init_pet_advance_luvky_value()->
	Info=pet_advanced_db:get_advance_reset_time_info(get(roleid)),
	if Info=:=[]->
		  nothing;
	   true->
			Time=pet_advanced_db:get_advance_reset_time(Info),
			IsReset=role_op:reset_pet_advance_lucky(Time),
			if IsReset->
				   lists:map(fun(MyPetInfo)->
									 Lucky=get_lucky_from_mypetinfo(MyPetInfo),
									 PetId=get_id_from_mypetinfo(MyPetInfo),
									 if Lucky=:=0->
											nothing;
										true->
											NewInfo=MyPetInfo#my_pet_info{lucky=0},
											pet_op:update_pet_info_all(NewInfo),
											pet_op:save_pet_to_db(PetId)
									 end end , get(pets_info));
			   true->
					nothing
			end
	end,
	 Time1=calendar:now_to_local_time(now()),
	pet_advanced_db:insert_advance_reset_time(Time1, get(roleid)).

%%玩家在线检测检查祝福值重置时间
send_reset_advance_lucky_time()->
	{{_,_,_},{Hour,_,_}}=calendar:now_to_local_time(now()),
	if Hour=:=6->
		      lists:map(fun(MyPetInfo)->
									 Lucky=get_lucky_from_mypetinfo(MyPetInfo),
									 PetId=get_id_from_mypetinfo(MyPetInfo),
									 if Lucky=:=0->
											nothing;
										true->
											NewInfo=MyPetInfo#my_pet_info{lucky=0},
											pet_op:update_pet_info_all(NewInfo),
											pet_op:save_pet_to_db(PetId)
									 end end , get(pets_info));
	   true->
		   nothing
	end,
	erlang:send_after(60000*30,self(),{reset_advance_time}).

%%检查宠物饱食度
check_pet_hanpyness(PetId)->
	case pet_op:get_pet_info(PetId) of
		[]->
			nothing;
		PetInfo->
			Hanpyness=get_happiness_from_mypetinfo(PetInfo),
			NewHappiness = erlang:max(Hanpyness-1,0),
			NewPetInfo = set_happiness_to_mypetinfo(PetInfo,NewHappiness),
			put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
			pet_attr:only_self_update(PetId,[{pet_happiness,NewHappiness}]),
					if
						NewHappiness =:= 0->
							GmInfo=pet_op:get_gm_petinfo(PetId),
							call_back_by_info(GmInfo);
						true->
							nothing
					end
		end.
			
	
		   


	   
	   
		
	

	
	
	
	