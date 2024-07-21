%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pet_skill_op).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("mnesia_table_def.hrl").
-include("skill_define.hrl").
-include("item_define.hrl").
-include("little_garden.hrl").
-include("error_msg.hrl").
-include("pet_struct.hrl").
-define(FORGET_USE_ITEM_NUM,1).
-define(FORGET_SKILL_ITEM_CLASS,132).    %%遗忘技能所需物品
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%s
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%pet_skillinfo [{PetId,[{Slot,{SkillId,SkillLevel,CastTime},SlotState}]}]

init_pet_skill_info() ->
	put(pets_skill_info,[]).

save_to_db()->
	todo.
	
async_save_to_db()->
	todo.

initskillinfo()->
	BornSkillInfo = lists:map(fun(SlotId)-> {SlotId,{0,0,0},?PET_SKILL_SLOT_ACTIVE} end,lists:seq(1,?PET_BORN_SKILL_SLOT)),
	OtherSkillInfo = lists:map(fun(SlotId)-> {SlotId,{0,0,0},?PET_SKILL_SLOT_INACTIVE} end,lists:seq(?PET_BORN_SKILL_SLOT+1,?PET_TOTAL_SKILL_SLOT)),
	BornSkillInfo ++ OtherSkillInfo.

init_pet_skill(PetId,SkillInfo)->
	NewSkillInfo = lists:ukeymerge(1, SkillInfo, initskillinfo()),
	put(pets_skill_info,[{PetId,NewSkillInfo}|get(pets_skill_info)]).
	
send_init_data()->
	lists:foreach(fun({PetId,SkillInfo})->
				%% slot info 
				SlotInfo = lists:map(fun({Slot,_,SlotState})-> pet_packet:make_psll(Slot,SlotState) end,SkillInfo),
				SlotInitMsg = pet_packet:encode_init_pet_skill_slots_s2c(pet_packet:make_psl(PetId,SlotInfo))
				%%role_op:send_data_to_gate(SlotInitMsg),
				%%skill info
				%%Skills = lists:map(fun({Slot,{SkillId,Level,CastTime},_})-> pet_packet:make_psk(Slot,SkillId,Level) end,SkillInfo)
				%%SendSkillInfo = pet_packet:encode_learned_pet_skill_s2c(pet_packet:make_ps(PetId,Skills))
				%%role_op:send_data_to_gate(SendSkillInfo)		  
			end, get(pets_skill_info)).

send_init_data(PetId)->
	case lists:keyfind(PetId,1,get(pets_skill_info)) of
		false->
			nothing;
		{_,SkillInfo}->
			%% slot info 
			SlotInfo = lists:map(fun({Slot,_,SlotState})-> pet_packet:make_psll(Slot,SlotState) end,SkillInfo),
			SlotInitMsg = pet_packet:encode_init_pet_skill_slots_s2c(pet_packet:make_psl(PetId,SlotInfo)),
		%%	role_op:send_data_to_gate(SlotInitMsg),
			%%skill info
			Skills = lists:map(fun({Slot,{SkillId,Level,CastTime},_})-> pet_packet:make_psk(Slot,SkillId,Level) end,SkillInfo),
			SendSkillInfo = pet_packet:encode_learned_pet_skill_s2c(pet_packet:make_ps(PetId,Skills))
			%%role_op:send_data_to_gate(SendSkillInfo)
	end.
%%
%%
%%
create_pet_skill(PetId,RandomSkillList)->
	RandListLen = length(RandomSkillList),
	%% init skill slot state
	BornSkillInfo = lists:map(fun(SlotId)->
								if
									RandListLen >= SlotId->
										SkillInfo = lists:nth(SlotId,RandomSkillList),
										{SlotId,SkillInfo,?PET_SKILL_SLOT_ACTIVE};
									true->
										{SlotId,{0,0,0},?PET_SKILL_SLOT_ACTIVE}
								end 
							end,lists:seq(1,?PET_BORN_SKILL_SLOT)),
	OtherSkillInfo = 
		lists:map(fun(SlotId)-> {SlotId,{0,0,0},?PET_SKILL_SLOT_INACTIVE} end,lists:seq(?PET_BORN_SKILL_SLOT+1,?PET_TOTAL_SKILL_SLOT)),
	add_pet(PetId,BornSkillInfo ++ OtherSkillInfo).
	
add_pet(PetId,SkillInfo)->
	put(pets_skill_info,[{PetId,SkillInfo}|get(pets_skill_info)]).

delete_pet(PetId)->
	put(pets_skill_info,lists:keydelete(PetId, 1, get(pets_skill_info))).

%%
%%return true|false
%%
learn_skill(PetId,SkillId,SkillLevel) ->
	case lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			nothing;
		{PetId,OriSkillsInfo}->
			{ActiveSlot,InActiviveSlot,SameSkillSlot} 
				= lists:foldl(fun({Slot,{CurSlotSkill,_,_},Status},{ActiveAcc,InActiveAcc,SameSkillSlotAcc})->
								if
									SameSkillSlotAcc =/= 0->
										{ActiveAcc,InActiveAcc,SameSkillSlotAcc};
									CurSlotSkill =:= SkillId->
									  	{ActiveAcc,InActiveAcc,Slot};
									true->
										case Status of
											?PET_SKILL_SLOT_INACTIVE->
												if
													InActiveAcc =:= []->
														NewInActiveAcc = [Slot];
													true->
														NewInActiveAcc = InActiveAcc
												end,
												{ActiveAcc,NewInActiveAcc,SameSkillSlotAcc};
											?PET_SKILL_SLOT_ACTIVE->
												NewActiveAcc = [Slot|ActiveAcc],
												{NewActiveAcc,InActiveAcc,SameSkillSlotAcc};
											_->
												{ActiveAcc,InActiveAcc,SameSkillSlotAcc}
										end
								end
							end,{[],[],0},OriSkillsInfo),
			if
				SameSkillSlot =/= 0->	%%find same skill 
					{_,{_,_,_},SameSkillSlotStatus} = lists:keyfind(SameSkillSlot,1,OriSkillsInfo),
					if
						SameSkillSlotStatus =:= ?PET_SKILL_SLOT_ACTIVE_AND_LOCK->
							role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(?ERROR_PET_LEARN_SKILL_SAME_SKILL_LOCK)),
							false;
						true->
							NewSkillInfo = lists:keyreplace(SameSkillSlot,1,OriSkillsInfo,{SameSkillSlot,{SkillId,SkillLevel,{0,0,0}},SameSkillSlotStatus}),
							put(pets_skill_info,lists:keyreplace(PetId, 1, get(pets_skill_info), {PetId,NewSkillInfo})),
							SkillMsgBin = pet_packet:encode_update_pet_skill_s2c(PetId,pet_packet:make_psk(SameSkillSlot,SkillId,SkillLevel)),
							role_op:send_data_to_gate(SkillMsgBin),
							pet_util:recompute_attr(skill,PetId),
							true
					end;
				true->
					if
						ActiveSlot =:= []->
							[FindSlot] = InActiviveSlot;
						InActiviveSlot =:= []->
							FindSlot = lists:nth(random:uniform(length(ActiveSlot)),ActiveSlot);
						true->
							[FindInActiviveSlot] = InActiviveSlot,
							SkillRateInfo = pet_skill_slot_db:get_info(FindInActiviveSlot),
							{RandA,RandB} = pet_skill_slot_db:get_rate(SkillRateInfo),
							case (random:uniform(RandB) =< RandA) of
								true->
									FindSlot = FindInActiviveSlot;
								_->
									FindSlot = lists:nth(random:uniform(length(ActiveSlot)),ActiveSlot)
							end
					end,
					{_,{OldSkillId,_,_},FindSlotStatus} = lists:keyfind(FindSlot,1,OriSkillsInfo),
					case FindSlotStatus of
						?PET_SKILL_SLOT_INACTIVE->
						   	MsgBin = pet_packet:encode_update_pet_skill_slot_s2c(PetId,pet_packet:make_psll(FindSlot,?PET_SKILL_SLOT_ACTIVE)),
							role_op:send_data_to_gate(MsgBin);
						_->
							nothing
					end,
					%%find empty solt and fill it
					FindSlotInfo = {FindSlot,{0,0,0},?PET_SKILL_SLOT_ACTIVE},
					SkillsInfo = lists:keyreplace(FindSlot,1,OriSkillsInfo,FindSlotInfo),					
					put(pets_skill_info,lists:keyreplace(PetId, 1, get(pets_skill_info), {PetId,SkillsInfo})),			
					EmptySlot =  lists:foldl(fun({Slot,{Skill,_,_},Status},EmptySlotAcc)->
								if
									EmptySlotAcc =/= 0  ->
										EmptySlotAcc;
									true->
										if
											(Skill =:= 0) and (Status =/= ?PET_SKILL_SLOT_INACTIVE)->
												 Slot;
											true->
												EmptySlotAcc
										end
								end
							end,0,SkillsInfo),
					if
						EmptySlot =:= 0 ->
							NewFindSlot = FindSlot;
						true->
							NewFindSlot = EmptySlot
					end,
%%					io:format("EmptySlot ~p NewFindSlot ~p SkillsInfo ~p ~n",[EmptySlot,NewFindSlot,SkillsInfo]),
					NewFindSlotInfo = {NewFindSlot,{SkillId,SkillLevel,{0,0,0}},?PET_SKILL_SLOT_ACTIVE},
					NewSkillsInfo = lists:keyreplace(NewFindSlot,1,SkillsInfo,NewFindSlotInfo),					
					put(pets_skill_info,lists:keyreplace(PetId, 1, get(pets_skill_info), {PetId,NewSkillsInfo})),
					SkillMsgBin = pet_packet:encode_update_pet_skill_s2c(PetId,pet_packet:make_psk(NewFindSlot,SkillId,SkillLevel)),
					role_op:send_data_to_gate(SkillMsgBin),
					pet_util:recompute_attr(skill,PetId),
					true
			end							
	end.
	
forget_skill(PetId,SkillId,Slot)->
	case  lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			nothing;
		{PetId,OriSkillsInfo}->
			case lists:keyfind(Slot,1,OriSkillsInfo) of
				false->
					nothing;
				{_,{0,_,_},_}->
					nothing;
				{_,_,Status}->
					if
						Status =:= ?PET_SKILL_SLOT_INACTIVE->
							nothing;
						true->
							if
								Status =:= ?PET_SKILL_SLOT_ACTIVE_AND_LOCK ->
									NewSlotInfo = {Slot,{0,0,0},?PET_SKILL_SLOT_ACTIVE},
									MsgBin = pet_packet:encode_update_pet_skill_slot_s2c(PetId,pet_packet:make_psll(Slot,?PET_SKILL_SLOT_ACTIVE)),
									role_op:send_data_to_gate(MsgBin);
								true->
									NewSlotInfo = {Slot,{0,0,0},Status}
							end,
							SkillsInfo = lists:keyreplace(Slot,1,OriSkillsInfo,NewSlotInfo),		
							put(pets_skill_info,lists:keyreplace(PetId, 1, get(pets_skill_info), {PetId,SkillsInfo})),
							SkillMsgBin = pet_packet:encode_update_pet_skill_s2c(PetId,pet_packet:make_psk(Slot,0,0)),
							role_op:send_data_to_gate(SkillMsgBin),
							pet_util:recompute_attr(skill,PetId)
					end
			end		
	end.

export_for_copy()->	
	{get(pets_skill_info)}.

load_by_copy({Skill_info})->
	put(pets_skill_info,Skill_info).

get_pet_skillnum(PetId)->
	erlang:length(get_pet_skillinfo(PetId)).

get_active_skillnum(PetId)->
	lists:foldl(fun({SkillId,Level,_},AddTmp)->
		SkillInfo = skill_db:get_skill_info(SkillId,Level),
		SkillType = skill_db:get_type(SkillInfo),				
		case (SkillType =:= ?SKILL_TYPE_ACTIVE)  or (SkillType =:=?SKILL_TYPE_ACTIVE_WITHOUT_CHECK_SILENT) of
			true->
				AddTmp+1;
			false->
				AddTmp
		end
	end,0,get_pet_skillinfo(PetId)).

get_pet_skillallinfo(PetId)->
	case  lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			[];
		{PetId,SkillsInfo}->
			SkillsInfo
	end.

get_pet_skillinfo(PetId)->
	case  lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			[];
		{PetId,SkillsInfo}->
			NewSkillsInfo = lists:filter(fun({_,{SkillId,_,_},_})-> SkillId =/= 0 end,SkillsInfo),
			lists:map(fun({_,Skill,_})-> Skill end,NewSkillsInfo)
	end.

%%
%%
%%
get_pet_bestskillinfo(PetId)->
	case  lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			[];
		{PetId,SkillsInfo}->
			lists:foldl(fun({_,{SkillId,SkillLevel,CastTime},_},Acc)-> 
								if
									SkillId =:= 0->
										Acc;
									true-> 
										case lists:keyfind(SkillId,1,Acc) of 
											false->
												NewAcc = [{SkillId,SkillLevel,CastTime}|Acc];
											{_,OldLevel,OldCastTime}->
												if
													OldLevel > SkillLevel->			
														NewAcc = Acc;
													OldLevel =:= SkillLevel ->			%%same level ,choose the last case 
														case timer:now_diff(CastTime,OldCastTime) > 0 of
															true->
																NewAcc = lists:keyreplace(SkillId,1,Acc,{SkillId,SkillLevel,CastTime});	
															_->
																NewAcc = Acc
														end;
													true->
														NewAcc = lists:keyreplace(SkillId,1,Acc,{SkillId,SkillLevel,CastTime})
												end;
											_->
												NewAcc = Acc
										end,
										NewAcc
								end
							end,[],SkillsInfo);
		_->
			[]
	end.

get_skill_level(PetId,SkillID)->
	case  lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			0;
		{PetId,SkillsInfo}->
			lists:foldl(fun({_,{SkillId,Level,_},_},Acc)->
							if
								SkillID =:= SkillId->
									erlang:max(Acc,Level);
								true->
									Acc
							end
						end,0,SkillsInfo)
	end.

check_common_cool(Now)->
	case get(last_pet_cast_time) of
		undefined->
			true;
		Time->
			timer:now_diff(Now ,Time) >= ?PET_ATTACK_TIME*1000
	end.

set_common_cool(Now)->
	put(last_pet_cast_time,Now).

is_cooldown_ok(PetId,SkillID) ->
	Now = timer_center:get_correct_now(),
	BaseCheck = check_common_cool(Now),
	if
		BaseCheck->
			case get_pet_bestskillinfo(PetId) of
				[]->
					false;
				SkillsInfo->
					case lists:keyfind(SkillID, 1,SkillsInfo ) of
						false->
							false;
						{SkillID,SkillLevel,0}->
							true;
						{SkillID,SkillLevel,LastCastTime}->
							SkillInfo =  skill_db:get_skill_info(SkillID,SkillLevel),
							timer:now_diff(Now ,LastCastTime) >= skill_db:get_cooldown(SkillInfo)*1000					
					end
			end;
		true->
			false
	end.

is_cooldown_ok(SkillID,SkillLevel,LastCastTime) ->
	Now = timer_center:get_correct_now(),
	BaseCheck = check_common_cool(Now),
	if
		BaseCheck->
			SkillInfo =  skill_db:get_skill_info(SkillID,SkillLevel),
			timer:now_diff(Now ,LastCastTime) >= skill_db:get_cooldown(SkillInfo)*1000;					
		true->
			false
	end.

set_casttime(PetId,SkillId,SkillLevel)->
	Now = timer_center:get_correct_now(),
	set_common_cool(Now),
	case  lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			nothing;
		{PetId,SkillList}->
			lists:foldl(fun({Slot,{FindSkillId,FindLevel,CastTime},Status},Acc)->
							if
								Acc->
									Acc;
								true->
									case {FindSkillId,FindLevel} of
										{SkillId,SkillLevel}->
											NewPetSkill = lists:keyreplace(Slot,1,SkillList,{Slot,{FindSkillId,FindLevel,Now},Status}),
											put(pets_skill_info,lists:keyreplace(PetId,1,get(pets_skill_info),{PetId,NewPetSkill})),
											true;
										_->
											Acc
									end
							end
						end,false,SkillList)
	end.

get_attack_module(Skill) ->
	case Skill of
		1 ->
			normal_point_attack;
		2 ->
			normal_scope_attack;
		3 ->
			complex_scope_attack;
		_ ->
			undefined
	end.

do_learn_for_pet(PetId,Skillid)->
	todo.

get_skill_addition_for_pet(PetId)->
	SkillInfos = get_pet_bestskillinfo(PetId),
	lists:foldl(fun({SkillId,Level,_},AddAttrTmp)->
			SkillInfo = skill_db:get_skill_info(SkillId, Level),
			case skill_db:get_type(SkillInfo) of
				?SKILL_TYPE_PASSIVE_ATTREXT->
					AddBuffs = skill_db:get_caster_buff(SkillInfo),
					AddAttrTmp ++
					lists:foldl(fun({{BufferId,BuffLevel},_Rate},AttrTmp)-> 
									AttrTmp ++ buffer_op:get_buffer_attr_effect(BufferId,BuffLevel)
								end, [], AddBuffs);
				_->
					AddAttrTmp
			end end, [], SkillInfos).

get_skill_addition_for_role(PetId)->
	case pet_op:get_pet_info(PetId) of
		[]->
			nothing;
		MyPetInfo->
			SkillInfos=get_skill_from_mypetinfo(MyPetInfo),
			Attr=lists:foldl(fun({_,SkillId,Level},AddAttrTmp)->
					case skill_db:get_pet_skill_info(SkillId, Level) of
						[]->
							AddAttrTmp;
						SkillInfo->
							AddBuffs = skill_db:get_pet_skill_buff(SkillInfo),
							AddBuffs++AddAttrTmp;
						_->
							AddAttrTmp
					end end, [], SkillInfos),
			if Attr=:=[]->
				   [{0,0}];
			   true->
				   Attr
			end
	end.

change_skill_slot_status(PetId,Slot,Status)->
	SkillInfos = get_pet_skillallinfo(PetId),
	{_,Skills,SlotState} = lists:keyfind(Slot,1,SkillInfos),
	if
		SlotState =:= Status->
			slogger:msg("change_skill_slot_status error same status ~p ~n",[{PetId,Slot,Status}]),
			nothing;
		SlotState =:= ?PET_SKILL_SLOT_INACTIVE->
			slogger:msg("change_skill_slot_status error slot not active ~p ~n",[{PetId,Slot,Status}]),
			nothing;
		Status =:= ?PET_SKILL_SLOT_ACTIVE->			%%unlock
			%%check item
			case item_util:is_has_enough_item_in_package_by_class(?ITEM_TYPE_PET_SKILL_SOLT_LOCK,1) of
				false->
					Errno = ?ERROR_PET_SKILL_SLOT_LOCK_ITEM_NOT_ENOUGN,
					role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno));
				true->				
					%%consume
					item_util:consume_items_by_classid(?ITEM_TYPE_PET_SKILL_SOLT_LOCK,1),
					NewSkillInfos = lists:keyreplace(Slot,1,SkillInfos,{Slot,Skills,Status}),
					put(pets_skill_info,lists:keyreplace(PetId,1,get(pets_skill_info),{PetId,NewSkillInfos})),
					%%notify client
					MsgBin = pet_packet:encode_update_pet_skill_slot_s2c(PetId,pet_packet:make_psll(Slot,Status)),
					role_op:send_data_to_gate(MsgBin)
			end;
		true->
			%%check lock solt num
			LockNum = lists:foldl(fun({_,_,FindStatus},Acc)->
										if
											FindStatus =:= ?PET_SKILL_SLOT_ACTIVE_AND_LOCK->
												Acc+1;
											true->
												Acc
										end
									end,0,SkillInfos),
			CanLockNum = ?PET_SKILL_SLOT_LOCK_NUM + vip_op:get_addition_with_vip(pet_slot_lock),
			CheckLockSolt = lists:member(Slot,?PET_SKILL_SLOTLIST_CAN_LOCK),
			{SkillId,_,_} = Skills,
			CheckSoltSkill = (SkillId =:= 0),
			if
				CheckSoltSkill->
					Errno = ?ERROR_PET_SKILL_SLOT_CANNOT_BELOCKED,
					role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno));
				CanLockNum =< LockNum  ->
					Errno = ?ERROR_PET_SKILL_SLOT_LOCKER_LIMITED,
					role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno));
				not CheckLockSolt->
					Errno = ?ERROR_PET_SKILL_SLOT_CANNOT_BELOCKED,
					role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno));
				true->
					%%check item
					case item_util:is_has_enough_item_in_package_by_class(?ITEM_TYPE_PET_SKILL_SOLT_LOCK,1) of
						false->
							Errno = ?ERROR_PET_SKILL_SLOT_LOCK_ITEM_NOT_ENOUGN,
							role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno));
						true->				
							%%consume
							item_util:consume_items_by_classid(?ITEM_TYPE_PET_SKILL_SOLT_LOCK,1),
							%%change
							NewSkillInfos = lists:keyreplace(Slot,1,SkillInfos,{Slot,Skills,Status}),
							put(pets_skill_info,lists:keyreplace(PetId,1,get(pets_skill_info),{PetId,NewSkillInfos})),
							%%notify client
							MsgBin = pet_packet:encode_update_pet_skill_slot_s2c(PetId,pet_packet:make_psll(Slot,Status)),
							role_op:send_data_to_gate(MsgBin)
					end
			end
	end.

%%
%%find useful slot	
%%
check_useful_slot(PetId)->
	SkillsInfo = get_pet_skillallinfo(PetId),
	lists:foldl(fun({_,{SkillId,_,_},Status},Acc)->
						if
							Acc->
								Acc;
							true->
								Status =/= ?PET_SKILL_SLOT_ACTIVE_AND_LOCK
						end
					end,false,SkillsInfo).

%%
%%return true | false
%%
check_common_skill(Class,SkillId)->
	case Class of
		?CLASS_MAGIC->
			SkillId =:= ?NARMAL_MAGIC_ATTACK_PET;
		?CLASS_RANGE->
			SkillId =:= ?NARMAL_RANGE_ATTACK_PET;
		?CLASS_MELEE->
			SkillId =:= ?NARMAL_MELEE_ATTACK_PET
	end.

%%
%%return true | false
%%
check_same_skill(PetId,SkillId,SkillLevel)->
	SkillsInfo = get_pet_skillallinfo(PetId),
	lists:foldl(fun({_,{_SkillId,_SkillLevel,_},_},Acc)->
						if
							Acc->
								Acc;
							true->
								(_SkillId =:= SkillId) and (_SkillLevel =:= SkillLevel) 
						end
					end,false,SkillsInfo).

%%
%%return {true,oldlevel}|false
%%
check_best_skill(PetId,SkillId,SkillLevel)->
	SkillsInfo = get_pet_skillallinfo(PetId),
	lists:foldl(fun({_,{_SkillId,_SkillLevel,_},_},Acc)->
						case Acc of
							{true,_}->
								Acc;
							_->
								case (_SkillId =:= SkillId) and (_SkillLevel > SkillLevel) of
									true->
										{true,_SkillLevel};
									_->
										Acc
								end
						end
					end,false,SkillsInfo).



%%修改宠物技能《枫少》宠物创建时只用一次,以后资质提升自动打开技能锁不用此函数
create_pet_init_skill(Quality)->
	SlotNum=pet_skill_db:get_pet_skill_slots_from_quality(Quality),
	ActivitySlotList=lists:seq(1,SlotNum),
	ActivitySlotSkill=lists:map(fun(Num)->
										{Num,0,0} end, ActivitySlotList),
	LockSlotList=lists:seq(SlotNum+1, ?PET_TOTAL_SKILL_SLOT),
	LockSlotSkill=lists:map(fun(LNum)->
										{LNum,0,-1} end, LockSlotList),
	ActivitySlotSkill++LockSlotSkill.

pet_skill_learn_skill(PetId,Skillid,SkillLevel)->
		case pet_op:get_pet_info(PetId) of
			[]->false;
			PetInfo->
				SkillList=get_skill_from_mypetinfo(PetInfo),
				NewSkill=case lists:keyfind(Skillid, 2, SkillList) of
					false->
						if SkillLevel=:=1->
							Slot=get_new_skill_slot(SkillList),
							if Slot=:=0->
								  false;
							   true->
								   NewSkillList=lists:keyreplace(Slot, 1,SkillList, {Slot,Skillid,SkillLevel}),
								   NewPetInfo=PetInfo#my_pet_info{skill=NewSkillList},
								   MSkill=make_pet_newskill(Slot,Skillid,SkillLevel),
								   pet_op:update_pet_info_all(NewPetInfo),
								   Message=pet_packet:encode_update_pet_skill_s2c(PetId, MSkill),
								   role_op:send_data_to_gate(Message),
								   achieve_op:achieve_update({pet_skill}, [SkillLevel],1),
								   true
							end;
						   true->
							   false
						end;
						{OldSlot,SkillId,Level}->
							if (Level+1)=:=SkillLevel->
								    NewSkillList=lists:keyreplace(OldSlot, 1,SkillList, {OldSlot,Skillid,SkillLevel}),
									NewPetInfo=PetInfo#my_pet_info{skill=NewSkillList},
									MSkill=make_pet_newskill(OldSlot,Skillid,SkillLevel),
									pet_op:update_pet_info_all(NewPetInfo),
								   Message=pet_packet:encode_update_pet_skill_s2c(PetId, MSkill),
								   role_op:send_data_to_gate(Message),
									achieve_op:achieve_update({pet_skill}, [SkillLevel],1),
                                   achieve_op:achieve_update({pet_skill}, [SkillLevel],1),
									true;
							   true->
								 false
							end
			end
		end.

get_new_skill_slot(SkillList)->
	NewSlotList=lists:sort(SkillList),
	case lists:keyfind(0, 3, NewSlotList) of
		{Slot,_,_}->
			Slot;
		_->
			0
	end.

make_pet_newskill(Slot,SkillId,SkillLevel)->
	{psk,Slot,SkillId,SkillLevel}.

pet_forget_skill(Slot,PetId,SkillId)->
	case pet_op:get_pet_info(PetId) of
		[]->
			nothing;
		MyPetInfo->
			SkillsInfo=get_skill_from_mypetinfo(MyPetInfo),
			case lists:keyfind(Slot, 1, SkillsInfo) of
				false->
					nothing;
				{_,PSkillId,Level}->
					if PSkillId=:=SkillId->
						   CurItemNum = package_op:get_counts_by_class_in_package(?FORGET_SKILL_ITEM_CLASS),
						   if
							   CurItemNum>=?FORGET_USE_ITEM_NUM->
								   PetSkill=make_pet_newskill(Slot,0,0),
								   NewSkillInfo=lists:keyreplace(Slot,1 , SkillsInfo,{Slot,0,0}),
								   NewPetInfo=MyPetInfo#my_pet_info{skill=NewSkillInfo},
								   role_op:consume_items_by_classid(?FORGET_SKILL_ITEM_CLASS,?FORGET_USE_ITEM_NUM),
								   pet_op:update_pet_info_all(NewPetInfo),
								   Message=pet_packet:encode_update_pet_skill_s2c(PetId, PetSkill),
								   role_op:send_data_to_gate(Message);
							   true->
								   nothing
						   end;
					true->
						nothing
					end
			end
	end.

pet_quality_to_change_skillinfo(Quality,SkillInfo)->
	SlotNum=pet_skill_db:get_pet_skill_slots_from_quality(Quality),
	OldNum=lists:foldl(fun({Slot,PetId,Level},Acc)->
							    if Level=/=-1->
									   Acc+1;
								   true->
									   Acc
								end end, 0, SkillInfo),
	if SlotNum>OldNum->
		  	SlotList=lists:seq(OldNum+1, SlotNum),
			lists:foldl(fun(Num,Acc)->
								case lists:keyfind(Num,1 , Acc) of
									false->
										SkillInfo;
									{_,_,L}->
										if L=:=-1->
											   lists:keyreplace(Num, 1, Acc, {Num,0,0});
										   true->
											   SkillInfo
										end
								end  end,SkillInfo, SlotList);
	   true->
		   []
	end.

%%宠物购买技能锁
pet_buy_skill_slot(Slot,PetId)->
	case pet_op:get_pet_info(PetId) of
		[]->
				 Message=pet_packet:encode_pet_opt_error_s2c(?ERROR_PET_NOEXIST),
				  role_op:send_data_to_gate(Message);
		MyPetInfo->
			SkillsInfo=get_skill_from_mypetinfo(MyPetInfo),
			case lists:keyfind(Slot, 1, SkillsInfo) of
				false->nothing;
				{Slot,SkillId,Level}->
					if Level=:=-1->
						   case pet_skill_db:get_pet_skill_proto_info(Slot) of
							   []->nothing;
							   ProtoSkillInfo->
								   Gold=pet_skill_db:get_gold_from_skill_protoinfo(ProtoSkillInfo),
								   if Gold=:=0->
										  nothing;
									  true->
										  HasGold=role_op:check_money(?MONEY_GOLD, Gold),
										  if not HasGold->
												 Message=pet_packet:encode_pet_opt_error_s2c(?ERROR_PET_TRAINING_NOT_ENOUGH_MONEY),
				  								role_op:send_data_to_gate(Message);
											 true->
												 role_op:money_change(?MONEY_GOLD, -Gold,pet_skillsloy_buy),
												 NewSkillList=lists:keyreplace(Slot, 1,SkillsInfo, {Slot,0,0}),
													NewPetInfo=MyPetInfo#my_pet_info{skill=NewSkillList},
													MSkill=make_pet_newskill(Slot,0,0),
													pet_op:update_pet_info_all(NewPetInfo),
								   					Message=pet_packet:encode_update_pet_skill_s2c(PetId, MSkill),
								   					role_op:send_data_to_gate(Message),
												 	pet_op:save_to_db()
												 end
								   end
						   end
					end
			end
	end.
												
												 
	
	
					
					
	



						 
						
						