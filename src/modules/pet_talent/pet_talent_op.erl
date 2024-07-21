%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-8-22
%% Description: TODO: Add description to pet_talent_op
-module(pet_talent_op).

%%
%% Include files
%%
-define(PET_NORMAL_RANDOM,1).
-define(PET_TALENT_LEVEL_INIT,0).
-include("common_define.hrl").
-include("error_msg.hrl").
-include("system_chat_define.hrl").

%%
%% Exported Functions
%%
-export([process_message/1,export_for_copy/0,load_by_copy/1,get_talent_addition_for_role/1,
		 pet_talent_upgrade/2,get_talent_value_to_role/1,get_talent_value_from_pet_talent_info/1]).

-include("pet_struct.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-define(TALENT_LIFE,9).
-define(TALENT_ATTACK,10).
-define(TALENT_DEFENSE,11).
%%天赋存储{level,id,type}
%%
%% API Functions
%%
process_message({pet_random_talent_c2s,_,PetId,Type})->
	pet_random_talent(PetId,Type);

process_message({pet_change_talent_c2s,_,PetId})->
	pet_change_talent(PetId).
	
pet_random_talent(PetId,Type)->
	PetTalentCunsume = pet_talent_db:get_talent_consume_info(Type),
	PetInfo = pet_op:get_pet_info(PetId),
	GmPetInfo = pet_op:get_gm_petinfo(PetId),
	PetTmpId = get_proto_from_petinfo(GmPetInfo),
	PetProtoInfo = pet_proto_db:get_info(PetTmpId),
	{{L_Power,H_Power},{L_HitRate,H_HitRate},{L_Criticalrate,H_Criticalrate},{L_Stamina,H_Stamina}} = pet_proto_db:get_born_talents(PetProtoInfo),
	{Gold,ResumeItemList} = pet_talent_db:get_pet_consume_detail(PetTalentCunsume),
	#my_pet_info{talent={T_Power,T_HitRate,T_Criticalrate,T_Stamina}}=PetInfo,
	case Type of
		?PET_NORMAL_RANDOM->
			CheckGold = true,
			ResultItem = lists:map(fun({Class,Count})->
										item_util:is_has_enough_item_in_package_by_class(Class,Count)
									end,ResumeItemList),
			case lists:member(false,ResultItem) of
				false->
					HasItem = true;
				true->
					HasItem = false
			end;
		_->
			CheckGold = role_op:check_money(?MONEY_GOLD,Gold),
			HasItem = true
	end,
	if 
		not HasItem->
			Result = ?ERROR_MISS_ITEM;
		not CheckGold->
			Result = ?ERROR_LESS_GOLD;
		true->
			role_op:money_change(?MONEY_GOLD,-Gold,pet_talent),
			if ResumeItemList =/= [] ->
					lists:foreach(fun({Class, Count})->
										role_op:consume_items_by_classid(Class,Count) 
									end, ResumeItemList);
			   true->
				   nothing
			end,
			gm_logger_role:pet_talent_consume(get(roleid),PetId,PetTmpId,Type,Gold),
			[Stamina,Criticalrate,HitRate,Power] = lists:foldl(fun({Talent,BornTalent_L,BornTalent_H},Acc)->
						 												RateInfo = pet_talent_db:get_talent_rateinfo({Type,Talent}),
																		RateList = pet_talent_db:get_talent_ratelist(RateInfo),
																		ResultValue = ride_pet_util:random_value_by_rate(RateList),
																		if Talent+ResultValue<BornTalent_L->
																			    [BornTalent_L-Talent|Acc];
																   			Talent+ResultValue>=BornTalent_H->
																    			[BornTalent_H-Talent|Acc];
																   			true->
																			    [ResultValue|Acc]
																		end
																	end,[],[{T_Power,L_Power,H_Power},
																			{T_HitRate,L_HitRate,H_HitRate},
																			{T_Criticalrate,L_Criticalrate,H_Criticalrate},
																			{T_Stamina,L_Stamina,H_Stamina}]),
			case lists:keyfind(PetId,1,get(mypets_add_talent)) of
				false->
					put(mypets_add_talent,[{PetId,Power,HitRate,Criticalrate,Stamina}|get(mypets_add_talent)]);
				_->
					put(mypets_add_talent,lists:keyreplace(PetId,1,get(mypets_add_talent),{PetId,Power,HitRate,Criticalrate,Stamina}))
			end,
			Message = pet_packet:encode_pet_random_talent_s2c(Power,HitRate,Criticalrate,Stamina),
			role_op:send_data_to_gate(Message)
	end.

pet_change_talent(PetId)->
	case lists:keyfind(PetId,1,get(mypets_add_talent)) of
		false->
			nothing;
		{_,Power,HitRate,Criticalrate,Stamina}->
			MyPetInfo = pet_op:get_pet_info(PetId),
			case get_trade_lock_from_mypetinfo(MyPetInfo) of
 				?PET_TRADE_UNLOCK->
 					pet_attr:only_self_update(PetId,[{pet_lock, ?PET_TRADE_LOCK}]),
 					NewPetInfo = set_trade_lock_to_mypetinfo(MyPetInfo,?PET_TRADE_LOCK);
 				_->
 					NewPetInfo = MyPetInfo
			end,
			put(mypets_add_talent,lists:keydelete(PetId,1,get(mypets_add_talent))),
			{T_Power,T_HitRate,T_Criticalrate,T_Stamina}=get_talent_from_mypetinfo(NewPetInfo),
			%{Add_power,Add_HitRate,Add_Critiacalrate,Add_Stamina}=get_talent_add_from_mypetinfo(NewPetInfo),
			GmPetInfo = pet_op:get_gm_petinfo(PetId),
			PetName = get_name_from_petinfo(GmPetInfo),
			{Talent_Score,RankNum} = pet_util:compute_talent_score(PetId,PetName,T_Power+Power,T_HitRate+HitRate,T_Criticalrate+Criticalrate,T_Stamina+Stamina),
			NewPower = T_Power+Power,
			NewHitRate = T_HitRate+HitRate,
			NewCriticalrate = T_Criticalrate+Criticalrate,
			NewStamina = T_Stamina+Stamina,
			put(last_talent,{T_Power,T_HitRate,T_Criticalrate,T_Stamina}),
			PetQuality = get_quality_from_petinfo(GmPetInfo),
			check_broadcast(PetId,PetName,PetQuality,NewPower,NewHitRate,NewCriticalrate,NewStamina),
			NewMyPetInfo = NewPetInfo#my_pet_info{talent_score = Talent_Score,
						 							talent={NewPower,NewHitRate,NewCriticalrate,NewStamina},
												  	talent_sort=RankNum},
			achieve_op:achieve_update({pet_talent},[0],Talent_Score),
			open_service_activities:pet_talent_score(Talent_Score),
			put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewMyPetInfo)),
			pet_util:recompute_attr(talent,PetId),
			pet_util:recompute_attr(talent_sort,PetId),
			quest_op:update(change_talent,1)
			%gm_logger_role:pet_talent_change(get(roleid),PetId,T_Power+Power,T_HitRate+HitRate,T_Criticalrate+Criticalrate,T_Stamina+Stamina,get_proto_from_petinfo(GmPetInfo))
	end.
 
export_for_copy()->
	get(mypets_add_talent).

load_by_copy(TalentInfo)->
	put(mypets_add_talent,TalentInfo).
	
check_broadcast(PetId,PetName,PetQuality,Power,HitRate,Criticalrate,Stamina)->
	RoleInfo = get(creature_info),
	RoleName = get_name_from_roleinfo(RoleInfo),
	RoleId = get_id_from_roleinfo(RoleInfo),
	ServerId = get_serverid_from_roleinfo(RoleInfo),
	{OldPower,OldHitRate,OldCriticalrate,OldStamina} = get(last_talent),
	lists:foreach(fun({OldTalent,Talent,SysId})->
						  if
							   (OldTalent < ?FIRST_TALENT_BROADCAST_EDGE) and (Talent >=?FIRST_TALENT_BROADCAST_EDGE) ->
								   system_broadcast(SysId,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?FIRST_TALENT_BROADCAST_EDGE);
							   (OldTalent < ?SEC_TALENT_BROADCAST_EDGE) and (Talent >=?SEC_TALENT_BROADCAST_EDGE) ->
								   system_broadcast(SysId,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?SEC_TALENT_BROADCAST_EDGE);
							   (OldTalent < ?THIRD_TALENT_BROADCAST_EDGE) and (Talent >=?THIRD_TALENT_BROADCAST_EDGE) ->
								   system_broadcast(SysId,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?THIRD_TALENT_BROADCAST_EDGE);
							   (OldTalent < ?FOR_TALENT_BROADCAST_EDGE) and (Talent >=?FOR_TALENT_BROADCAST_EDGE) ->
								   system_broadcast(SysId,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?FOR_TALENT_BROADCAST_EDGE);
							   true ->
								   nothing
						  end
					end,[{OldPower,Power,?SYSTEM_CHAT_PET_TALENT_POWER},
						 {OldHitRate,HitRate,?SYSTEM_CHAT_PET_TALENT_HITRATE},
						 {OldCriticalrate,Criticalrate,?SYSTEM_CHAT_PET_TALENT_CRITICALRATE},
						 {OldStamina,Stamina,?SYSTEM_CHAT_PET_TALENT_STAMINA}]).

system_broadcast(SysId,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,ReachIndex)->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamPet = chat_packet:makeparam(pet,{PetId,PetName,PetQuality,RoleId,RoleName,ServerId}),
	ParamIndex = system_chat_util:make_int_param(ReachIndex),
	MsgInfo = [ParamRole,ParamPet,ParamIndex],
	system_chat_op:system_broadcast(SysId,MsgInfo).


	%%枫少添加宠物天赋
pet_talent_upgrade(PetId,Type)->
		case pet_op:get_pet_info(PetId) of
			[]->
					Error=?ERROR_PET_NOEXIST,
					 Message=pet_packet:encode_pet_opt_error_s2c(Error),
				   role_op:send_data_to_gate(Message);
			PetInfo->
				PetGameInfo=pet_op:get_gm_petinfo(PetId),
				PetLevel=get_level_from_petinfo(PetGameInfo),
				if PetLevel<50->
					   nothing;
				   true->
						TalentList=get_talent_from_mypetinfo(PetInfo),
						TalentLevel=lists:foldl(fun({Level,Tid,Ttype},Acc)->
																if Acc=/=-1->Acc;
																   true->
																	   if Ttype=:=Type->
																			  Level;
																		  true->
																			  Acc+0
																	   end end end, -1, TalentList),
						 case pet_talent_db:get_talent_item_info(TalentLevel+1) of
								  []->
									  nothing;
								  TalnetItemInfo->
							  			{{NoBoundItemId,BoundItemId},NeedNum}=pet_talent_db:get_neetitem_from_info(TalnetItemInfo),
										 NeedMoney=pet_talent_db:get_needmoney_from_info(TalnetItemInfo),
										 Bounditeminfo=package_op:getSlotsByItemInfo(BoundItemId,true),
										NBounditeminfo=package_op:getSlotsByItemInfo(BoundItemId,false),
										 NeedItemInfoList=lists:merge(Bounditeminfo,NBounditeminfo),
										 if NeedItemInfoList=:=[]->
													Error=?ERROR_PET_NOT_ENOUGH_ITEM,
													 Message=pet_packet:encode_pet_opt_error_s2c(Error),
						  							 role_op:send_data_to_gate(Message);
											true->
													{HasCount,ItemList}=package_op:get_need_item_info(NeedItemInfoList,NeedNum),
													HasMoney=role_op:check_money(?MONEY_BOUND_SILVER, NeedMoney),
													if not HasMoney->
														   Error=?ERROR_PET_NOT_ENOUGH_MONEY,
														    Message=pet_packet:encode_pet_opt_error_s2c(Error),
						  									 role_op:send_data_to_gate(Message);
													   HasCount<NeedNum->
														  Error=?ERROR_PET_NOT_ENOUGH_ITEM,
														   Message=pet_packet:encode_pet_opt_error_s2c(Error),
						  									 role_op:send_data_to_gate(Message);
													   true->
														   case pet_talent_db:get_pet_talent_proto_info(Type) of
															   []->nothing;
															   ProtoInfo->
																   Error=[],
																   TalentId=pet_talent_db:get_talentid_from_talent_proto_info(ProtoInfo),
																   Required=pet_talent_db:get_required_from_talent_proto_info(ProtoInfo),
																   Uprade=pet_talent_db:get_upgrade_from_talent_proto_info(ProtoInfo),
																   if Uprade=:=0->
																		   lists:foreach(fun({Slot,Id,Num})->
																									consume_items(Slot,Id,Num) end, ItemList),
																		   role_op:money_change(?MONEY_SILVER, NeedMoney,learntalent),
																		 NewTalentList=get_new_talentlist(TalentId,TalentLevel+1,Type,TalentList),
																		 NewPetInfo=PetInfo#my_pet_info{talent=NewTalentList},
																		 pet_op:update_pet_info_all(NewPetInfo),
																		    Message=pet_packet:encode_pet_talent_update_s2c(PetId, {pt,TalentLevel+1,TalentId,Type} ),
																		   role_op:send_data_to_gate(Message),
																		   check_learn_talent_of_life(?TALENT_LIFE,NewPetInfo,PetId),
																		   check_learn_talent_of_attack(?TALENT_ATTACK,NewPetInfo,PetId),
																		   check_learn_talent_of_defense(?TALENT_DEFENSE,NewPetInfo,PetId),
																		    pet_util:recompute_attr(talent, PetId),
																		   gm_logger_role:pet_talent_change(get(roleid),PetId,TalentList,get_proto_from_petinfo(pet_op:get_gm_petinfo(PetId)));
																	true->
																		nothing
																   end
														   end
													end
										 end
						 end
				end
	end.

check_learn_talent_of_life(?TALENT_LIFE,PetInfo,PetId)->
	check_talent(?TALENT_LIFE,PetInfo,PetId).
check_learn_talent_of_attack(?TALENT_ATTACK,PetInfo,PetId)->
	check_talent(?TALENT_ATTACK,PetInfo,PetId).
check_learn_talent_of_defense(?TALENT_DEFENSE,PetInfo,PetId)->
	check_talent(?TALENT_ATTACK,PetInfo,PetId).

check_talent(Type,PetInfo,PetId)->
   case pet_talent_db:get_pet_talent_proto_info(Type) of
	   []->nothing;
	   TalentProtoInfo->
		   	TalentList=get_talent_from_mypetinfo(PetInfo),
		   TalentId=pet_talent_db:get_talentid_from_talent_proto_info(TalentProtoInfo),
			Required=pet_talent_db:get_required_from_talent_proto_info(TalentProtoInfo),
		    Uprade=pet_talent_db:get_upgrade_from_talent_proto_info(TalentProtoInfo),
		   if Uprade=:=1->
				  	TalentLevel=lists:foldl(fun({Level,Tid,Ttype},Acc)->
																if Acc=/=-1->Acc;
																   true->
																	   if Ttype=:=Type->
																			  Level;
																		  true->
																			  Acc+0
																	   end end end, -1, TalentList),
					if TalentLevel=:=0->
						  Result=check_learn_talent(TalentList,Required),
						  if Result>=8->
								NewTalentList=get_new_talentlist(TalentId,TalentLevel+1,Type,TalentList),
								NewPetInfo=PetInfo#my_pet_info{talent=NewTalentList},
								pet_op:update_pet_info_all(NewPetInfo),
							    Message=pet_packet:encode_pet_talent_update_s2c(PetId, {pt,TalentLevel+1,TalentId,Type} ),
								role_op:send_data_to_gate(Message);
							 true->
								 nothing
						end;
					   true->
						   nothing
					end;
			  true->
				  nothing
		   end
   end.
		   
get_new_talentlist(TalentId,TalentLevel,Type,TalentList)->
	NewTalentList=
				lists:keyreplace(TalentId, 2, TalentList,{TalentLevel,TalentId,Type}),
			NewTalentList.

check_learn_talent(Talentlsit,Required)->
	LearnNum=erlang:length(Talentlsit),
	if LearnNum<8->
		  0;
	   true->
		  ResultList= lists:map(fun({LLevel,LTalentId,LType})->
							 lists:foldl(fun({Type,Level},Acc)->
												 if (Type=:=LType) and (LLevel>=Level)->
														Acc+1;
													true->
														Acc+0
												 end
														end, 0, Required) end, Talentlsit),
		R=lists:sum(ResultList),
		R
end.
		
consume_items(Slot,Id,Num)->
	case package_op:get_iteminfo_in_normal_slot(Slot) of
		[]->nothing;
			%io:format("@@@@@@@@@   no item~n",[]);
		ItemInfo->
			role_op:consume_item(ItemInfo, Num)
	end.

get_talent_addition_for_role(PetId)->
	case pet_op:get_pet_info(PetId) of
		[]->TalentList=[];
		PetInfo->TalentList=get_talent_from_mypetinfo(PetInfo)
	end,
	get_talent_value_to_role(TalentList).
	
%%得到宠物天赋附加都人身上的属性值
get_talent_value_to_role(TalentList)->
	if TalentList=:=[]->
		   NewTalent=[{ok,0}];
	   true->
			NewTalent=lists:foldl(fun({Level,TalentId,_},Acc)->
							  case pet_talent_db:get_talent_template_info(TalentId, Level) of
								  []->
										[{ok,0}]++Acc;
								  Info->
									Tinfo=pet_talent_db:get_affect_from_talent_template_info(Info),
									  Acc++Tinfo
							  end
							 end ,[],TalentList)
			end,
		TalentInfo=lists:filter(fun({_,Value})->
						 Value=/=0 end, NewTalent),
		TalentInfo.

	   	
get_talent_value_from_pet_talent_info(TalentInfo1)->
	TalentInfo=lists:filter(fun({_,Value})->
						 Value=/=0 end, TalentInfo1),
	{_,Hitrate}=case lists:keyfind(hitrate, 1, TalentInfo) of
				false ->
					{hitrate,0};
					Info->
						Info
				end,
	{_,Dodge}=case lists:keyfind(dodge,1, TalentInfo) of 
			  false->
				  {dodge,0};
			  Infododge->
				  Infododge
		  end,
	{_,Criticalrate}=case lists:keyfind(criticalrate,1,TalentInfo) of
					 false->
						 {criticalrate,0};
					 Infocriticalrate->
						 Infocriticalrate
				 end,
	{_,Criticaldestroyrate}= case lists:keyfind(criticaldestroyrate, 1,TalentInfo) of
							 false->
								 {criticaldestroyrate,0};
							 Infocriticaldestroyrate->
								 Infocriticaldestroyrate
						 end,
	{_,Toughness}=case lists:keyfind(toughness,1,TalentInfo ) of
				  false->
					  {toughness,0};
				  Infotoughness->
					  Infotoughness
			  end,
	{_,Meleeimmunity}=case lists:keyfind(meleeimmunity, 1, TalentInfo) of
					  false->
						  {meleeimmunity,0};
					  Infomeleeimmunity->
						  Infomeleeimmunity
				  end,
	{_,Rangeimmunity}=case lists:keyfind(rangeimmunity,1,TalentInfo) of
					  false->
						  {rangeimmunity,0};
					  Inforangeimmunity->
						  Inforangeimmunity
				  end,
	{_,Magicimmunity}=case lists:keyfind(magicimmunity,1,TalentInfo) of
					  false->
						  {magicmmunity,0};
					  Infomagicimmunity->
						  Infomagicimmunity
				  end,
	{_,Hpmax}=case lists:keyfind(hpmax,1,TalentInfo) of
			  false->
				  {hpmax,0};
			  Infohpmax->
				  Infohpmax
		  end,
	{_,Meleepower}=case lists:keyfind(meleepower, 1, TalentInfo) of
				   false->
					   {meleepower,0};
				   Infomeleepower->
					   Infomeleepower
			   end,
	{_,Meleedefense}=case lists:keyfind(meleedefense, 1,TalentInfo ) of
					 false->
						 {meleedefense,0};
					 Infomeleedefense->
						 Infomeleedefense
				 end,
	{Hitrate,Dodge,Criticalrate,Criticaldestroyrate,Toughness,Meleeimmunity,Rangeimmunity,Magicimmunity,Hpmax,Meleepower,Meleedefense}.
		
	


		