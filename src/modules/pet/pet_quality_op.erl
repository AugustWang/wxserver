%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-9-6
%% Description: TODO: Add description to pet_quality_op_v2
-module(pet_quality_op).

%%
%% Include files
%%
-include("pet_struct.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
-include("common_define.hrl").
-include("login_pb.hrl").
-include("system_chat_define.hrl").
-include("string_define.hrl").
-define(PET_QUALITY_ETS,pet_quality_ets).
-define(PET_QUALITY_UP_ETS,pet_quality_up_ets).
-define(GOLD_CONSUME,1).
-define(ITEM_CONSUME,0).
-define(QUALITY_UP_ADD,1).
-define(SUCESS,10759).
-define(FAILED,10730).
-define(FAILEDPROTECT,3).
-define(QUALITY_TO_TOP,4).
%%
%% Exported Functions
%%

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
%%
%% API Functions
%%
-define(LUCKYITEM,13140010).
-define(LUCKYITEMNUM,0).%%ä¸ä½¿ç”¨å¹¸è¿ç¬¦numä¸º0
-define(SUCCESS_RATE,[{1,25},{2,5},{3,1}]).%%ä½¿ç”¨å¹¸è¿ç¬¦æˆåŠŸçŽ‡
-define(FAIL_RATEM,[{-1,25},{-2,5},{-3,1}]).%%ä½¿ç”¨å¹¸è¿ç¬¦å¤±è´¥çŽ‡

pet_upgrade_quality(PetId,Needs,Protect,Num,LuckItem)->
	RoleId = get(roleid),
	RoleLevel = get(level),
	case equipment_op:get_item_from_proc(Needs) of 				%%judge needitem if exist	
		[]->
			ERROR = ?ERROR_MISS_ITEM;		
		NeedsProp->
			case pet_op:get_pet_info(PetId) of					%%judge pet if exist
				[]->
					ERROR = ?ERROR_PET_NOEXIST;
				MyPetInfo->
					GmPetInfo = pet_op:get_gm_petinfo(PetId),
					PetProtoId = get_proto_from_petinfo(GmPetInfo),
					QualityValue = get_quality_value_from_mypetinfo(MyPetInfo),
					QualittUpValue = get_quality_up_value_from_mypetinfo(MyPetInfo),
					case pet_quality_db:get_quality_info(QualityValue) of			%%read quality info
						[]->
							ERROR = ?ERROR_UNKNOWN,
							slogger:msg("no pet_quality data~n");
						QualityInfo->
							NeedItemClass = pet_quality_db:get_needs_with_qulity_info(QualityInfo),
							ItemClass = get_class_from_iteminfo(NeedsProp),
							if
								ItemClass =/= NeedItemClass->
									ERROR = ?ERROR_PET_UP_RESET_NEEDS_NOEXIST;
								true->
									ERROR = [],
									TmpPetInfo = check_lockstate(MyPetInfo,[NeedsProp]),
									role_op:consume_item(NeedsProp, 1),
									RateList = pet_quality_db:get_rate_with_quality_info(QualityInfo),
									AddValue = random_value_by_rate(Num,LuckItem,RateList),
									TmpQualityValue = QualityValue+AddValue,
									PetName = get_name_from_petinfo(GmPetInfo),
									put(last_quality,QualityValue),
									RoleInfo = get(creature_info),
									RoleName = get_name_from_roleinfo(RoleInfo),
									RoleId = get_id_from_roleinfo(RoleInfo),
									ServerId = get_serverid_from_roleinfo(RoleInfo),
									PetQuality = get_quality_from_petinfo(GmPetInfo),
									check_random_broadcast(RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,AddValue,QualityValue),
									quest_op:update(up_quality,1),
									case equipment_op:get_item_from_proc(Protect) of			%%judge protect item if exist
										[]->
											if 
												TmpQualityValue >= QualittUpValue ->
													Result=pet_packet:encode_pet_qualification_result_s2c(PetId,QualittUpValue,?QUALITY_TO_TOP),
													NewPetInfo = set_quality_value_to_mypetinfo(TmpPetInfo,QualittUpValue),
													gm_logger_role:pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,noprotect,sucess,QualittUpValue);
												TmpQualityValue>QualityValue->
													Result=pet_packet:encode_pet_qualification_result_s2c(PetId,TmpQualityValue,?SUCESS),
													NewPetInfo = set_quality_value_to_mypetinfo(MyPetInfo,TmpQualityValue),
													gm_logger_role:pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,noprotect,sucess,TmpQualityValue);
												TmpQualityValue =<?PET_MIN_QUALITY ->
													Result=pet_packet:encode_pet_qualification_result_s2c(PetId,?PET_MIN_QUALITY,?FAILED),
													NewPetInfo = set_quality_value_to_mypetinfo(MyPetInfo,?PET_MIN_QUALITY),
													gm_logger_role:pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,noprotect,failed,?PET_MIN_QUALITY);
												true->
													Result = pet_packet:encode_pet_qualification_result_s2c(PetId,TmpQualityValue,?FAILED),
													NewPetInfo = set_quality_value_to_mypetinfo(MyPetInfo,TmpQualityValue),
													gm_logger_role:pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,noprotect,failed,TmpQualityValue)
											end,
											role_op:send_data_to_gate(Result),
											put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
											pet_util:recompute_attr(quality_value,PetId);	
										ProtectProp->				%%has protect item
											NeedProtectClass = pet_quality_db:get_protect_with_quality_info(QualityInfo),
											ProtectItemClass = get_class_from_iteminfo(ProtectProp),
											if
												ProtectItemClass =:= NeedProtectClass->
													Tmp1PetInfo = check_lockstate(TmpPetInfo,[ProtectProp]),
													role_op:consume_item(ProtectProp, 1),
													if 
														TmpQualityValue >QualittUpValue ->
															Result = pet_packet:encode_pet_qualification_result_s2c(PetId,QualittUpValue,?SUCESS),
															NewPetInfo = set_quality_value_to_mypetinfo(Tmp1PetInfo,QualittUpValue),
															put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
															pet_util:recompute_attr(quality_value,PetId),
															gm_logger_role:pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,hasprotect,sucess,QualittUpValue);
														TmpQualityValue >= QualityValue ->
															Result = pet_packet:encode_pet_qualification_result_s2c(PetId,TmpQualityValue,?SUCESS),
															NewPetInfo = set_quality_value_to_mypetinfo(Tmp1PetInfo,TmpQualityValue),
															put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
															pet_util:recompute_attr(quality_value,PetId),
															gm_logger_role:pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,hasprotect,sucess,TmpQualityValue);
														true->
															Result = pet_packet:encode_pet_qualification_result_s2c(PetId,QualityValue,?FAILED),
															gm_logger_role:pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,hasprotect,failed,QualityValue)
													end,
													role_op:send_data_to_gate(Result);
												true->
													if 
														TmpQualityValue >= QualittUpValue ->
															Result = pet_packet:encode_pet_qualification_result_s2c(PetId,QualittUpValue,?SUCESS),
															NewPetInfo = set_quality_value_to_mypetinfo(TmpPetInfo,QualittUpValue),
															gm_logger_role:pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,noprotect,sucess,QualittUpValue);
														TmpQualityValue>QualityValue->
															Result = pet_packet:encode_pet_qualification_result_s2c(PetId,TmpQualityValue,?SUCESS),
															NewPetInfo = set_quality_value_to_mypetinfo(MyPetInfo,TmpQualityValue),
															gm_logger_role:pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,noprotect,sucess,TmpQualityValue);
														TmpQualityValue =< ?PET_MIN_QUALITY ->
															Result = pet_packet:encode_pet_qualification_result_s2c(PetId,?PET_MIN_QUALITY,?FAILED),
															NewPetInfo = set_quality_value_to_mypetinfo(MyPetInfo,?PET_MIN_QUALITY),
															gm_logger_role:pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,noprotect,failed,?PET_MIN_QUALITY);
														true->
															Result = pet_packet:encode_pet_qualification_result_s2c(PetId,TmpQualityValue,?FAILED),
															NewPetInfo = set_quality_value_to_mypetinfo(MyPetInfo,TmpQualityValue),
															gm_logger_role:pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,noprotect,failed,TmpQualityValue)
													end,
													role_op:send_data_to_gate(Result),
													put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
													pet_util:recompute_attr(quality_value,PetId)
											end
									end
							end
					end
			end
	end,
	if
		ERROR =:= []->
			nothing;
		true->
			ResultMessage = pet_packet:encode_pet_opt_error_s2c(ERROR),
			role_op:send_data_to_gate(ResultMessage)
	end. 
		


random_value_by_rate(?LUCKYITEMNUM,LuckyItem,RateList)->
	Sort_RateList = lists:keysort(2, RateList),
	RateSum = lists:foldl(fun({_,Rate},Acc)->
								  Rate+Acc 
						  end,0, Sort_RateList),
	RandomValue = random:uniform(RateSum),
	{ResultValue,_} = lists:foldl(fun({Value,Rate},{ResultValue,AccRate})->
										  if
											  ResultValue=/=[]->
												  {ResultValue,AccRate};
											  true->
												  if 
													  RandomValue =< Rate+AccRate->
														  {Value,Rate+AccRate};
													  true->
														  {[],Rate+AccRate}
												  end 
										  end 
								  end,{[],0}, Sort_RateList),
	ResultValue;

random_value_by_rate(Num,LuckyItem,RateList)->
	{RateSum,SuccessRateSum} = lists:foldl(fun({Value,Rate},{Acc1,Acc2})->
								  if Value>0->
										 {Acc1+Rate,Acc2+Rate};
								true->
									{Acc1+Rate,Acc2}
								  end
						  end,{0,0}, RateList),
	case  equipment_op:get_item_from_proc(LuckyItem) of
		[]->
			0;
		ItemInfo->
			ItemId=get_template_id_from_iteminfo(ItemInfo),
			if (ItemId=:=?LUCKYITEM ) or (ItemId=:=?LUCKYITEM+1)->
					NowCount=get_count_from_iteminfo(ItemInfo),
					if Num>NowCount->
						   Error=?ERROR_PET_NOT_ENOUGH_ITEM,
							Message=pet_packet:encode_pet_opt_error_s2c(Error),
					  	   role_op:send_data_to_gate(Message),
						   0;
					   true->
						   	SuccessRate=SuccessRateSum*100 div RateSum+Num*5,
						   if SuccessRate>=100->
								  NewFailRate=lists:map(fun({FValue,Frate})->{FValue,0} end,?FAIL_RATEM),
								  NewRate=?SUCCESS_RATE++NewFailRate;
							  true->
								  NewSuccessRate=lists:map(fun({Svalue,Srate})->{Svalue,Srate*SuccessRate} end, ?SUCCESS_RATE),
									NewFailRate=lists:map(fun({Fvalue,Frate})-> {Fvalue,Frate*(100-SuccessRate)} end, ?FAIL_RATEM),
								  NewRate=NewSuccessRate++NewFailRate
						   end,
							role_op:consume_item(ItemInfo, Num),
						  random_value_by_rate(0,0,NewRate)
					end;
			true->
				Error=?ERROR_PET_UP_RESET_NEEDS_NOEXIST,
				Message=pet_packet:encode_pet_opt_error_s2c(Error),
				 role_op:send_data_to_gate(Message),
				0
				end
end.
						  

pet_upgrade_quality_up(PetId,Type,Needs)->
	RoleId = get(roleid),
	RoleLevel = get(level),
	case pet_op:get_pet_info(PetId) of
		[]->
			ERROR = ?ERROR_PET_NOEXIST;
		MyPetInfo->
			GmPetInfo = pet_op:get_gm_petinfo(PetId),
			PetProtoId = get_proto_from_petinfo(GmPetInfo),
			QualityUpValue = get_quality_up_value_from_mypetinfo(MyPetInfo),
			case pet_quality_db:get_quality_up_info(QualityUpValue) of 
				[]->
					ERROR = ?ERROR_UNKNOWN,
					slogger:msg(" no pet_quality_up data ~n");
				QualityUpInfo->
					NeedGold = pet_quality_db:get_consumegold_with_quality_up_info(QualityUpInfo),
					NeedItemClass = pet_quality_db:get_needs_with_quality_up_info(QualityUpInfo),
					{Success,Max} = pet_quality_db:get_rate_with_quality_up_info(QualityUpInfo),
					MaxQualityValue = get_quality_max(PetId),
					RoleInfo = get(creature_info),
					RoleId = get_id_from_roleinfo(RoleInfo),
					RoleName = get_name_from_roleinfo(RoleInfo),
					ServerId = get_serverid_from_roleinfo(RoleInfo),
					PetName = get_name_from_petinfo(GmPetInfo),
					if 
						QualityUpValue >= MaxQualityValue->
							ERROR =?ERROE_PET_QUALITY_UP_TO_TOP;
						true->
							if
								Type =:=?GOLD_CONSUME->	
									case role_op:check_money(?MONEY_GOLD, NeedGold) of
										false->
											ERROR = ?ERROR_LESS_GOLD;
										true->
%% 											case role_op:check_money(?MONEY_SILVER, NeedSilver) of 
%% 												false->
%% 													io:format("pet_upgrade_quality_up:GOLD_CONSUME,ERROR_LESS_MONEY~n"),
%% 													ERROR = ?ERROR_LESS_MONEY;
%% 												true->	
													ERROR = [],
													pet_util:update_pet_lock_state(PetId,?PET_TRADE_LOCK),
													TmpPetInfo = set_trade_lock_to_mypetinfo(MyPetInfo,?PET_TRADE_LOCK),
													role_op:money_change(?MONEY_GOLD, -NeedGold, lost_pet_quality_up),
%% 													role_op:money_change(?MONEY_SILVER, -NeedSilver, lost_pet_quality_up),
													quest_op:update(up_quality_edge,1),
													RandomRate = random:uniform(Max),
													if 
														Success >= RandomRate ->
															Result = pet_packet:encode_pet_upgrade_quality_up_s2c(?GOLD_CONSUME,?SUCESS,QualityUpValue+?QUALITY_UP_ADD),
															NewPetInfo = set_quality_up_value_to_mypetinfo(TmpPetInfo,QualityUpValue+?QUALITY_UP_ADD),
															put(last_quality_edge,QualityUpValue),
															put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
															pet_util:recompute_attr(quality_up_value,PetId),
															PetQuality = get_quality_from_petinfo(pet_op:get_gm_petinfo(PetId)),
															check_quality_edge_broadcast(RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,QualityUpValue+?QUALITY_UP_ADD),
															gm_logger_role:pet_grade_quality_up_log(RoleId,RoleLevel,PetProtoId,PetId,gold_consume,sucess,QualityUpValue+?QUALITY_UP_ADD);
														true->
															Result = pet_packet:encode_pet_upgrade_quality_up_s2c(?GOLD_CONSUME,?FAILED,QualityUpValue),
															gm_logger_role:pet_grade_quality_up_log(RoleId,RoleLevel,PetProtoId,PetId,gold_consume,failed,QualityUpValue)
													end,
													role_op:send_data_to_gate(Result)
%% 											end
									end;
								true->
									case equipment_op:get_item_from_proc(Needs) of
										[]->
											ERROR = ?ERROR_PET_UP_RESET_NOEXIST;
										NeedsProp->
											ItemClassId = get_class_from_iteminfo(NeedsProp),
											if
												ItemClassId =/= NeedItemClass->
													ERROR = ?ERROR_PET_UP_RESET_NEEDS_NOEXIST;
												true->
%% 													case role_op:check_money(?MONEY_SILVER, NeedSilver) of 
%% 														false->
%% 															io:format("pet_upgrade_quality_up:itemconsume:ERROR_LESS_MONEY~n"),
%% 															ERROR = ?ERROR_LESS_MONEY;
%% 														true->
															ERROR = [],
															TmpPetInfo = check_lockstate(MyPetInfo,[NeedsProp]),
															role_op:consume_item(NeedsProp, 1),
															quest_op:update(up_quality_edge,1),
%% 															role_op:money_change(?MONEY_SILVER, -NeedSilver, lost_pet_quality_up),
															RandomRate = random:uniform(Max),
															if 
																Success >= RandomRate ->
																	Result = pet_packet:encode_pet_upgrade_quality_up_s2c(?ITEM_CONSUME,?SUCESS,QualityUpValue+?QUALITY_UP_ADD),
																	NewPetInfo = set_quality_up_value_to_mypetinfo(TmpPetInfo,QualityUpValue+?QUALITY_UP_ADD),
																	put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
																	pet_util:recompute_attr(quality_up_value,PetId),
																	PetQuality = get_quality_from_petinfo(pet_op:get_gm_petinfo(PetId)),
																	check_quality_edge_broadcast(RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,QualityUpValue+?QUALITY_UP_ADD),
																	gm_logger_role:pet_grade_quality_up_log(RoleId,RoleLevel,PetProtoId,PetId,item_consume,failed,QualityUpValue+?QUALITY_UP_ADD);
																true->
																	Result = pet_packet:encode_pet_upgrade_quality_up_s2c(?ITEM_CONSUME,?FAILED,QualityUpValue),
																	gm_logger_role:pet_grade_quality_up_log(RoleId,RoleLevel,PetProtoId,PetId,item_consume,failed,QualityUpValue)
															end,
															role_op:send_data_to_gate(Result)
%% 													end
											end
									end
							end
					end
			end
	end,
	if
		ERROR =:=[] ->
			nothing;
		true->
			ResultMessage = pet_packet:encode_pet_opt_error_s2c(ERROR),
			role_op:send_data_to_gate(ResultMessage)
	end.
	

check_lockstate(MyPetInfo,ItemInfoList)->
	TradeLockState = get_trade_lock_from_mypetinfo(MyPetInfo),
	if 
		TradeLockState =:= ?PET_TRADE_LOCK ->
			MyPetInfo;
		true->
			IsBonded = lists:any(fun(ItemInfo)-> get_isbonded_from_iteminfo(ItemInfo) =:= ?PET_TRADE_LOCK end, ItemInfoList),
			if
				IsBonded->
					PetId = get_id_from_mypetinfo(MyPetInfo),
					pet_util:update_pet_lock_state(PetId,?PET_TRADE_LOCK),
					NewPetInfo = set_trade_lock_to_mypetinfo(MyPetInfo,?PET_TRADE_LOCK),
					NewPetInfo;
				true->
					MyPetInfo
			end
	end.
	

get_quality_max(PetId)->
	GMPetInfo =  lists:keyfind(PetId,#my_pet_info.petid,get(gm_pets_info)),
	PetProtoId = get_proto_from_petinfo(GMPetInfo),
	PetProtoInfo = pet_proto_db:get_info(PetProtoId),
	QualityInfo = pet_proto_db:get_quality_to_growth(PetProtoInfo),
	SortQualiytInfo = lists:keysort(1,QualityInfo),
	{_MaxQuality,{_Min,Max}} = lists:last(SortQualiytInfo),
	Max.

%%
%% Local Functions
%%
check_quality_edge_broadcast(RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,NewQualityUpValue)->
	OldQualityUpValue = get(last_quality_edge),
	if 
		(OldQualityUpValue < ?BROADCAST_QUALITY_EDGE_REACH_31) and (NewQualityUpValue >= ?BROADCAST_QUALITY_EDGE_REACH_31) ->
		   ColorString = language:get_string(?STR_GREEN),
		   system_broadcast(?SYSTEM_CHAT_QUALITY_EDGE_31,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?BROADCAST_QUALITY_EDGE_REACH_31,ColorString);
		(OldQualityUpValue < ?BROADCAST_QUALITY_EDGE_REACH_61) and (NewQualityUpValue >= ?BROADCAST_QUALITY_EDGE_REACH_61) ->
		   ColorString = language:get_string(?STR_BLUE),
		   system_broadcast(?SYSTEM_CHAT_QUALITY_EDGE_61,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?BROADCAST_QUALITY_EDGE_REACH_61,ColorString);
		(OldQualityUpValue < ?BROADCAST_QUALITY_EDGE_REACH_91) and (NewQualityUpValue >= ?BROADCAST_QUALITY_EDGE_REACH_91) ->
		   ColorString = language:get_string(?STR_PURPLE),
		   system_broadcast(?SYSTEM_CHAT_QUALITY_EDGE_91,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?BROADCAST_QUALITY_EDGE_REACH_91,ColorString);
		(OldQualityUpValue < ?BROADCAST_QUALITY_EDGE_REACH_121) and (NewQualityUpValue >= ?BROADCAST_QUALITY_EDGE_REACH_121) ->
		   ColorString = language:get_string(?STR_GOLDEND),
		   system_broadcast(?SYSTEM_CHAT_QUALITY_EDGE_121,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?BROADCAST_QUALITY_EDGE_REACH_121,ColorString);
		true ->
			nothing
	end.

check_random_broadcast(RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,AddValue,QualityValue)->
	if QualityValue >= ?BROADCAST_PET_QUALITY_EDGE ->
			if AddValue >= ?BROADCAST_RANDOM_QUALITY_EDGE ->
					system_broadcast(?SYSTEM_CHAT_RANDOM_QUALITY,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality);
	   			true ->
		   			nothing
			end;
	   true ->
		   nothing
	end.

check_quality_broadcast(RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,TmpQualityValue)->
	Old_Quality = get(last_quality),
	if 
		(Old_Quality < ?BROADCAST_QUALITY_REACH_30) and (TmpQualityValue >= ?BROADCAST_QUALITY_REACH_30) ->
			system_broadcast(?SYSTEM_CHAT_QUALITY_REACH_INDEX,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?BROADCAST_QUALITY_REACH_30);
		(Old_Quality < ?BROADCAST_QUALITY_REACH_60) and (TmpQualityValue >= ?BROADCAST_QUALITY_REACH_60) -> 
			system_broadcast(?SYSTEM_CHAT_QUALITY_REACH_INDEX,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?BROADCAST_QUALITY_REACH_60);
		(Old_Quality < ?BROADCAST_QUALITY_REACH_90) and (TmpQualityValue >= ?BROADCAST_QUALITY_REACH_90) -> 
			system_broadcast(?SYSTEM_CHAT_QUALITY_REACH_INDEX,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?BROADCAST_QUALITY_REACH_90);
		(Old_Quality < ?BROADCAST_QUALITY_REACH_120) and (TmpQualityValue >= ?BROADCAST_QUALITY_REACH_120) -> 
			system_broadcast(?SYSTEM_CHAT_QUALITY_REACH_INDEX,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?BROADCAST_QUALITY_REACH_120);
		(Old_Quality < ?BROADCAST_QUALITY_REACH_150) and (TmpQualityValue >= ?BROADCAST_QUALITY_REACH_150) -> 
			system_broadcast(?SYSTEM_CHAT_QUALITY_REACH_INDEX,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,?BROADCAST_QUALITY_REACH_150);
		true ->
			nothing
	end.

system_broadcast(SysId,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality)->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamPet = chat_packet:makeparam(pet,{PetId,PetName,PetQuality,RoleId,RoleName,ServerId}),
	MsgInfo = [ParamRole,ParamPet],
	system_chat_op:system_broadcast(SysId,MsgInfo).

system_broadcast(SysId,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,Reach_Index)->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamPet = chat_packet:makeparam(pet,{PetId,PetName,PetQuality,RoleId,RoleName,ServerId}),
	ParamIndex = system_chat_util:make_int_param(Reach_Index),
	MsgInfo = [ParamRole,ParamPet,ParamIndex],
	system_chat_op:system_broadcast(SysId,MsgInfo).

system_broadcast(SysId,RoleInfo,RoleId,RoleName,ServerId,PetId,PetName,PetQuality,Reach_Index,ColorString)->
	Color = pet_util:get_pet_quality_color(PetQuality),
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamPet = chat_packet:makeparam(pet,{PetId,PetName,PetQuality,RoleId,RoleName,ServerId}),
	ParamIndex = system_chat_util:make_int_param(Reach_Index),
	ParamString = system_chat_util:make_string_param(ColorString,Color),
	MsgInfo = [ParamRole,ParamPet,ParamIndex,ParamString],
	system_chat_op:system_broadcast(SysId,MsgInfo).

		
		
		
		
		
		
		
		
		
		
		
		
