%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-4-17
%% Description: TODO: Add description to wing_op
-module(wing_op).
-compile(export_all).
-define(WING_DEFAULT_LEVEL,1).
-define(WING_DEFAULT_PHASE,1).
-define(PHASE_SUCCESS_LUCKY_VALUE,500).
-define(PHASE_DEFAULT_RATE,100).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([init/0,init_wing_info/1,honk_on_role_levelup/1]).
-include("role_wing.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
%%
%% API Functions
%%



%%
%% Local Functions
%%

init()->
	put(game_wing_info,[]).

load_from_role_wing_db(RoleId)->
	case wing_db:get_role_winginfo(RoleId) of
			[]->
				[];
			Info->
				WingGameInfo=create_wing_with_info(Info),
				put(game_wing_info,WingGameInfo),
				WingGameInfo
	end.
				

init_wing_info(RoleId)->
	init(),
	load_from_role_wing_db(RoleId),
	send_info_to_client(),
	sned_to_client_wing_baseinfo().

honk_on_role_levelup(Level)->
	if Level>=60->
		case get(game_wing_info) of
			[]->
				Message=wing_packet:encode_wing_open_s2c(),
				role_op:send_data_to_gate(Message),
				create_wing(),
				role_private_option:replace([{k,50,1}]);            %%设置飞剑乘坐状态
			Info->
					nothing
		end;
	true->
		nothing
	end.

create_wing()->
	GameWingInfo=create_wing_with_args(),
	if GameWingInfo =:=[]->
		   nothing;
	   true->
		   update_game_wing_info(GameWingInfo),
			SaveInfo=make_save_to_db_info(GameWingInfo,get(roleid)),
		   send_info_to_client(),
		   sned_to_client_wing_baseinfo(),
		   wing_db:async_write_roleattr(SaveInfo),
		   	role_op:recompute_base_attr(),
		   role_fighting_force:hook_on_change_role_fight_force()
	end.
	
create_wing_with_args()->
	case wing_db:get_wing_levelinfo(?WING_DEFAULT_LEVEL) of
		[]->
			[];
		Info->
			case wing_db:get_wing_phase_info(?WING_DEFAULT_PHASE) of
				[]->
					nothing;
				PhaseInfo->
						Level=?WING_DEFAULT_LEVEL,
						Social=?WING_DEFAULT_PHASE,
						Quality=1,
						Strength=0,
						Strength_up=wing_db:get_wing_maxintensity_from_phaseinfo(PhaseInfo),
						Perfect_Value=0,
						Strength_add=100,
						Skills=[],
						Echants={[],[]},
						Lucky=0,
						Speed=0,
						Power=wing_db:get_wing_level_add_power(Info),
						Defence=wing_db:get_wing_level_add_defence(Info),
						Hp=wing_db:get_wing_level_add_hpmax(Info),
						Mp=wing_db:get_wing_level_add_mpmax(Info),
						GameWingInfo=make_wing_game_info(Level,Social,Quality,Strength,Strength_up,Strength_add,Perfect_Value,Skills,Echants,Lucky,Power,Defence,Defence,Defence,Hp,Mp,Speed),
						GameWingInfo
			end
	end.

update_game_wing_info(GameWingInfo)->
	put(game_wing_info,GameWingInfo).

send_info_to_client()->
	Info=get(game_wing_info),
	if Info=:=[]->
		   nothing;
	   true->
			RoelId=get(roleid),
			Level=get_level_from_wing_info(Info),
			Strenthinfo=wing_packet:make_instensify(Info),
			SkillInfo=get_skills_from_wing_info(Info),
			Skill=
				lists:map(fun({SkillId,Level})->
								  wing_packet:make_wing_skill(SkillId, Level) end, SkillInfo),
			Lucky=get_lucky_from_wing_info(Info),
			EchantInfo=get_echants_from_wing_info(Info),
			Echants=lists:map(fun({Type,EchantQuality,Value})->
									  echant_to_attr(Type,EchantQuality,Value)
									      end  ,erlang:element(1, EchantInfo)),
			Socail=get_socail_from_wing_info(Info),
			Quality=get_quality_from_wing_info(Info),
			Message=
				wing_packet:encode_update_role_wing_info_s2c(RoelId,Level,Strenthinfo,Skill,Lucky,Echants,Socail,Quality),
			role_op:send_data_to_gate(Message)
	end.

sned_to_client_wing_baseinfo()->
	Info=get(game_wing_info),
	if Info=:=[]->
		   nothing;
	   true->
				Attr=to_attr(Info),
				Message=wing_packet:encode_update_wing_base_info_s2c(Attr),
				role_op:send_data_to_gate(Message)
	end.

create_wing_with_info(Info)->
	{_,RoleId,Level,Social,Quality,Streng,_,Perfect_Value,Skill,Echants,Lucky}=Info,
	case wing_db:get_wing_levelinfo(Level) of
		[]->
			[];
		LevelInfo->
			case wing_db:get_wing_phase_info(Social) of
				[]->
					[];
				PhaseInfo->
						Strengup=wing_db:get_wing_maxintensity_from_phaseinfo(PhaseInfo),
					case wing_db:get_wing_quality_info(Quality) of
						[]->
							Power=wing_db:get_wing_level_add_power(LevelInfo)+wing_db:get_wing_power_from_phaseinfo(PhaseInfo),
							Defence=wing_db:get_wing_level_add_defence(LevelInfo)+wing_db:get_wing_defense_from_phaseinfo(PhaseInfo),
							Hp=wing_db:get_wing_level_add_hpmax(LevelInfo)+wing_db:get_wing_hpmax_from_phaseinfo(PhaseInfo),
							Mp=wing_db:get_wing_level_add_mpmax(LevelInfo)+wing_db:get_wing_mpmax_from_phaseinfo(PhaseInfo);
						QualityInfo->
							Power=wing_db:get_wing_level_add_power(LevelInfo)+wing_db:get_wing_power_from_phaseinfo(PhaseInfo)+wing_db:get_power_from_qualityinfo(QualityInfo),
							Defence=wing_db:get_wing_level_add_defence(LevelInfo)+wing_db:get_wing_defense_from_phaseinfo(PhaseInfo)+wing_db:get_defense_from_qualityinfo(QualityInfo),
							Hp=wing_db:get_wing_level_add_hpmax(LevelInfo)+wing_db:get_wing_hpmax_from_phaseinfo(PhaseInfo)+wing_db:get_hpmax_from_qualityinfo(QualityInfo),
							Mp=wing_db:get_wing_level_add_mpmax(LevelInfo)+wing_db:get_wing_mpmax_from_phaseinfo(PhaseInfo)+wing_db:get_mpmax_from_qualityinfo(QualityInfo)
					end,
					case wing_db:get_wing_intensify_info(Streng) of
						[]->
							Strengadd=100+Streng*10+Perfect_Value;
						InstensifyInfo->
							Maxstensifyness=wing_db:get_maxperfectness_from_intenfifyinfo(InstensifyInfo),
							Value=trunc(Perfect_Value/Maxstensifyness*10),
							Strengadd=100+Streng*10+Value
					end,
					Speed=wing_db:get_wing_speed_from_phaseinfo(PhaseInfo),
					{NewPower,NewMagicDefence,NewRangeDefence,NewMeleeDefence,NewHp,NewMp}=
						compute_attr_by_strengadd(Strengadd,Power,Defence,Defence,Defence,Hp,Mp),
					GameWingInfo=make_wing_game_info(Level,Social,Quality,Streng,Strengup,Strengadd,Perfect_Value,Skill,Echants,Lucky,NewPower,NewMagicDefence,NewRangeDefence,NewMeleeDefence,NewHp,NewMp,Speed),
					GameWingInfo
			end
	end.
%%飞剑升级《枫少》
wing_level_up()->
	case get(game_wing_info) of
		[]->
			Error=[];
		GameWingInfo->
			Level=get_level_from_wing_info(GameWingInfo),
			Nowpower=get_power_from_wing_info(GameWingInfo),
			Nowmagicdefense=get_magicdefense_from_wing_info(GameWingInfo),
			Nowrangedefense=get_rangedefense_from_wing_info(GameWingInfo),
			Nowmeleedefense=get_meleedefense_from_wing_info(GameWingInfo),
			case wing_db:get_wing_levelinfo(Level) of
				[]->
					Error=[];
				LevelInfo->
					case wing_db:get_wing_level_needitem(LevelInfo) of
						[]->
							Error=[];
						{NeedItems,Count}->
								[NeedItemId|_]=NeedItems,
								BoundItemInfo=package_op:getSlotsByItemInfo(NeedItemId,true),
								NoBoundItemInfo=package_op:getSlotsByItemInfo(NeedItemId, false),
								NowItems=lists:merge(BoundItemInfo, NoBoundItemInfo),
								case NowItems of
									[]->
										Message=wing_packet:encode_encode_wing_opt_result_s2c(?WING_THING_NOT_ENOUGH),
		  								 role_op:send_data_to_gate(Message);
									_->
										{HasCount,ItemList}=package_op:get_need_item_info(NowItems, Count),
										if HasCount<Count->
											   Message=wing_packet:encode_encode_wing_opt_result_s2c(?WING_THING_NOT_ENOUGH),
		  								 		role_op:send_data_to_gate(Message);
										   true->
											   NeedMoney=wing_db:get_wing_level_add_money(LevelInfo),
											   HasMoney=role_op:check_money(?MONEY_BOUND_SILVER, NeedMoney),
											   if not HasMoney ->
													    Message=wing_packet:encode_encode_wing_opt_result_s2c(?WING_THING_NOT_ENOUGH),
		  								 				role_op:send_data_to_gate(Message);
												  true->
													  case  wing_db:get_wing_levelinfo(Level+1) of
														  []->
															  Error=[];
														  NewLevelInfo->
															  Error=[],
															 NewWingInfo= recompute_attr_by_baseattr(levelup,LevelInfo,NewLevelInfo),
															 role_op:money_change(?MONEY_SILVER, -NeedMoney, wing_levelup),
															 lists:foreach(fun({Slot,Id,Num})->
																							package_op:consume_items(Slot,Id,Num) end, ItemList),
															   send_info_to_client(),%%发所有更新信息《客户端要求》《枫少》
															   Attr=to_attr(NewWingInfo),
															 	Message=wing_packet:encode_update_wing_base_info_s2c(Attr),
																role_op:send_data_to_gate(Message),
															  	role_op:recompute_base_attr(),
															    role_fighting_force:hook_on_change_role_fight_force(),
															 	SaveInfo=make_save_to_db_info(NewWingInfo,get(roleid)),
															 	  wing_db:async_write_roleattr(SaveInfo)
													  end
											   end
										end
								end
					end
			end
	end.
															  
%%进阶
wing_phase_up(Usergold)->
	case get(game_wing_info) of
		[]->
			nothing;
		GameWingInfo->
			Phase=get_socail_from_wing_info(GameWingInfo),
			case wing_db:get_wing_phase_info(Phase) of
				[]->
					nothing;
				PhaseInfo->
					Lucky=get_lucky_from_wing_info(GameWingInfo),
					CanPhase=can_phase(Lucky,PhaseInfo),
					if not CanPhase->
						   NewWingInfo=GameWingInfo#wing_game_info{lucky=Lucky+1},
						   put(game_wing_info,NewWingInfo),
						   Message=wing_packet:encode_encode_wing_opt_result_s2c(?WING_PHASE_UP_FAILED),
		  				 role_op:send_data_to_gate(Message),
						   send_info_to_client();
					   true->
							case wing_db:get_wing_item_from_phaseinfo(PhaseInfo) of
								[]->nothing;
								{Items,Count}->
									[ItemId|_]=Items,
									Money=wing_db:get_wing_money_from_phaseinfo(PhaseInfo),
									Can=check_caninfo(ItemId,Count,Money,Usergold),
									case Can of
										[]->
											nothing;
										{ItemLists,GoldCount}->
														  case wing_db:get_wing_phase_info(Phase+1) of
															  []->
																 nothing;
															  NewPhaseInfo->
																  StrengthUp=wing_db:get_wing_maxintensity_from_phaseinfo(NewPhaseInfo),
																  LWingInfo=GameWingInfo#wing_game_info{lucky=0,streng_up=StrengthUp},
						   											put(game_wing_info,LWingInfo),
																  NewWingInfo=recompute_attr_by_baseattr(phaseup,PhaseInfo,NewPhaseInfo),
																   role_op:money_change(?MONEY_SILVER, -Money, wing_phaseup),
																   role_op:money_change(?MONEY_GOLD, -GoldCount, wing_phaseup),
																  if ItemLists=:=[]->
																		 nothing;
																	 true->
																		 lists:foreach(fun({Slot,Id,Num})->
																										package_op:consume_items(Slot,Id,Num) end, ItemLists)
																  end,
																  		ResultMessage=wing_packet:encode_encode_wing_opt_result_s2c(?WING_PHASE_UP_SUCCESS),
		  																 role_op:send_data_to_gate(ResultMessage),
																	   send_info_to_client(),%%发所有更新信息《客户端要求》《枫少》
																	    Attr=to_attr(NewWingInfo),
																	 	Message=wing_packet:encode_update_wing_base_info_s2c(Attr),
																		role_op:send_data_to_gate(Message),
																	  	role_op:recompute_base_attr(),
																	    role_fighting_force:hook_on_change_role_fight_force(),
																  		SaveInfo=make_save_to_db_info(NewWingInfo,get(roleid)),
															 	  		wing_db:async_write_roleattr(SaveInfo)
														  end
												   end
											end
									end
			end
	end.

%%品质提升
wing_quality_up()->
	case get(game_wing_info) of
		[]->
			nothing;
		GameInfo->
			Quality=get_quality_from_wing_info(GameInfo),
	case wing_db:get_wing_quality_info(Quality) of
		[]->
				nothing;
		QualityInfo->
			{Items,Count}=wing_db:get_item_from_qualityinfo(QualityInfo),
			if Items=:=[]->
				 nothing;
			   true->
				   [ItemId|_]=Items,
				  Money=wing_db:get_money_from_qualityinfo(QualityInfo),
				Can=check_caninfo(ItemId,Count,Money,0),
				  case Can of
					  []->
						  	 ResultMessage=wing_packet:encode_encode_wing_opt_result_s2c(?WING_QUALITY_FAILED),
		  					role_op:send_data_to_gate(ResultMessage);
					  {ItemLists,GoldCount}->
						  case wing_db:get_wing_quality_info(Quality+1) of
							  []->
								   nothing;
							  NewQuality->
								  SkillInfo=get_skills_from_wing_info(GameInfo),
								  NewSkillInfo=wing_skill:check_skill_can_activity_for_quality(SkillInfo, NewQuality),
								   NewWingInfo=recompute_attr_by_baseattr(qualityup,QualityInfo,NewQuality,NewSkillInfo),
								     role_op:money_change(?MONEY_SILVER, -Money, wing_phaseup),
								   role_op:money_change(?MONEY_GOLD, -GoldCount, wing_phaseup),
								  if ItemLists=:=[]->
										 nothing;
									 true->
											lists:foreach(fun({Slot,Id,Num})->
																	package_op:consume_items(Slot,Id,Num) end, ItemLists)
								 	 end,
								  	 ResultMessage=wing_packet:encode_encode_wing_opt_result_s2c(?WING_QUALITY_SUCCESS),
		  							role_op:send_data_to_gate(ResultMessage),
									send_info_to_client(),%%发所有更新信息《客户端要求》《枫少》
									Attr=to_attr(NewWingInfo),
									Message=wing_packet:encode_update_wing_base_info_s2c(Attr),
									role_op:send_data_to_gate(Message),
									role_op:recompute_base_attr(),
									role_fighting_force:hook_on_change_role_fight_force(),
									SaveInfo=make_save_to_db_info(NewWingInfo,get(roleid)),
									wing_db:async_write_roleattr(SaveInfo)
						  end
				   end
			end
	end
	end.

%%强化(强化用到完美值lucky)
wing_qintensify(Gold)->
	case get(game_wing_info) of
		[]->
			nothing;
		GameInfo->
			Strength=get_strength_from_wing_info(GameInfo),
			Strength_up=get_strength_up_from_wing_info(GameInfo),
			Perfect_value=get_perfect_value_from_wing_info(GameInfo),
			if Strength>=Strength_up->
				   ResultMessage=wing_packet:encode_encode_wing_opt_result_s2c(?WING_INSTENFY_UP),
		  			role_op:send_data_to_gate(ResultMessage);
			   true->
				   case wing_db:get_wing_intensify_info(Strength+1) of
					   []->
						  nothing;
					   IntensifyInfo->
						  Maxperfectness=wing_db:get_maxperfectness_from_intenfifyinfo(IntensifyInfo),
						  {Items,Count}=wing_db:get_item_from_intenfifyinfo(IntensifyInfo),
						  [ItemId|_]=Items,
						  Money=wing_db:get_money_from_intenfifyinfo(IntensifyInfo),
						  Can=check_caninfo(ItemId,Count,Money,Gold),
						 case Can of
							 []->
								ResultMessage=wing_packet:encode_encode_wing_opt_result_s2c(?WING_THING_NOT_ENOUGH),
		  						role_op:send_data_to_gate(ResultMessage);
							 {ItemLists,GoldCount}->
								 {NewStrength,NewPerfect_value,NewStrengthAdd}=
									 if (Perfect_value+1)>=Maxperfectness->
											case wing_db:get_wing_intensify_info(Strength+1) of
												[]->
													StrengthAdd=wing_db:get_attrrate_from_intenfifyinfo(IntensifyInfo),
													{Strength+1,Perfect_value+1,StrengthAdd};
												NewIntensifyInfo->
													NewMaxPerfect=wing_db:get_maxperfectness_from_intenfifyinfo(NewIntensifyInfo),
													Value=trunc((Perfect_value+1-Maxperfectness)/NewMaxPerfect*10),
													StrengthAdd=wing_db:get_attrrate_from_intenfifyinfo(NewIntensifyInfo)+Value,
													{Strength+1,Perfect_value-Maxperfectness+1,StrengthAdd}
											end;
										true->
											Value=trunc((Perfect_value+1)/Maxperfectness*10),
											StrengthAdd=wing_db:get_attrrate_from_intenfifyinfo(IntensifyInfo)+Value,
											{Strength,Perfect_value+1,StrengthAdd}
									 end,
								 			CheckSkill=wing_skill:check_skill_can_activity(NewStrength),
								 			SkillsInfo=get_skills_from_wing_info(GameInfo),
								 			NewSkillsInfo=
									 								if CheckSkill=:=[]->
																			 SkillsInfo;
															 			true->	
																				wing_skill:update_wing_skill(SkillsInfo, CheckSkill)
																	end,
											NewGameWingInfo=recompute_attr_by_baseattr(instenfify,NewStrength,NewPerfect_value,NewStrengthAdd,NewSkillsInfo),
											 role_op:money_change(?MONEY_SILVER, -Money, wing_phaseup),
								 			 role_op:money_change(?MONEY_GOLD, -GoldCount, wing_phaseup),
								 			if ItemLists=:=[]->
												   nothing;
											   true->
													 lists:foreach(fun({Slot,Id,Num})->
																	package_op:consume_items(Slot,Id,Num) end, ItemLists)
											end,
								 			ResultMessage=wing_packet:encode_encode_wing_opt_result_s2c(?WING_INSTENFY_SUCCESS),
		  									role_op:send_data_to_gate(ResultMessage),
											send_info_to_client(),%%发所有更新信息《客户端要求》《枫少》
											Attr=to_attr(NewGameWingInfo),
											Message=wing_packet:encode_update_wing_base_info_s2c(Attr),
											role_op:send_data_to_gate(Message),
											role_op:recompute_base_attr(),
											role_fighting_force:hook_on_change_role_fight_force(),
											SaveInfo=make_save_to_db_info(NewGameWingInfo,get(roleid)),
											wing_db:async_write_roleattr(SaveInfo)
									 end
						  end
				   end
			end.
										 
%%飞剑洗练
wing_echant(Type,LockInfo)->
	case get(game_wing_info) of
		[]->
			nohting;
		GameWingInfo->
			Quality=get_quality_from_wing_info(GameWingInfo),
			{EchantInfo,_}=get_echants_from_wing_info(GameWingInfo),
			case wing_db:get_wing_echant_num_info(Quality) of
				[]->
					nothing;
				EchantsInfo->
					{Items,Count}=wing_db:get_item_from_echantinfo(EchantsInfo),
					[ItemId|_]=Items,
					Money=wing_db:get_money_from_echantinfo(EchantsInfo),
					if      %%wb判断是否自动购买道具
						Type=:=1->
							ItemPriceInfo=wing_db:get_item_gold_price_info(ItemId),
							case ItemPriceInfo of
								[]->
									Gold=0;
								_->
									Gold=wing_db:get_gold_from_itemgoldinfo(ItemPriceInfo)
							end;
						true->
							Gold=0
					end,
					Can=check_caninfo(ItemId,Count,Money,Gold),
					   EchantNum=wing_db:get_echantnum_from_echantinfo(EchantsInfo),
					case  Can of
						[]->
						  nothing;
					   {ItemList,GoldCount}->
						   if LockInfo =:=[]->
								  {NewEchantInfo,NewEchantList}=echant(EchantNum,LockInfo),
											 {EchantInfo,_}=get_echants_from_wing_info(GameWingInfo),
											NewInfo=GameWingInfo#wing_game_info{echants={EchantInfo,NewEchantList}},
											put(game_wing_info,NewInfo),
								  			role_op:money_change(?MONEY_SILVER, -Money, wing_phaseup),
								  			if ItemList=:=[]->   %%@@wb如果没有物品，消耗元宝
												   role_op:money_change(?MONEY_GOLD, -GoldCount, wing_phaseup);
											   true->
												    lists:foreach(fun({Slot,Id,Num})->
																	package_op:consume_items(Slot,Id,Num) end, ItemList)
											end,
											Message=wing_packet:encode_wing_enchant_s2c(NewEchantInfo),
											role_op:send_data_to_gate(Message);
							  
							  true->			%%锁定重新处理检测洗练
								  LockNum=erlang:length(LockInfo),
								  case wing_db:get_wing_echant_lockgold_info(LockNum) of
									  []->
										 nothing;
									  LockInfos->
											Goldcount=wing_db:get_gold_from_lockenchant_info(LockInfos),
											{_,ItemCount}=wing_db:get_item_from_lockenchant_info(LockInfos),
											{[ItemId1,ItemId0],NeedCount}=wing_db:get_item_from_lockenchant_info(LockInfos),
											Count1=package_op:get_counts_by_template_in_package(ItemId1),
											Count0=package_op:get_counts_by_template_in_package(ItemId0),
											Enough=(Count1+Count0)>=NeedCount,
											BItemInfo=package_op:getSlotsByItemInfo(ItemId1,true),
	                                        UBItemInfo=package_op:getSlotsByItemInfo(ItemId0, false),
	                                        ItemsL=lists:merge(BItemInfo, UBItemInfo),
										  HasGold=role_op:check_money(?MONEY_GOLD, Goldcount),
												if not HasGold->
													   nothing;
												   true->
													   if not Enough->
															  nothing;
														  true->
														LockechantInfo=lists:map(fun(Num)->
																				lists:nth(Num, EchantInfo)
																								end, LockInfo),
														{NewEchantInfo,NewEchantList}=echant(EchantNum,LockechantInfo),
														 {EchantInfo,_}=get_echants_from_wing_info(GameWingInfo),
														NewInfo=GameWingInfo#wing_game_info{echants={EchantInfo,NewEchantList}},
														put(game_wing_info,NewInfo),
														role_op:money_change(?MONEY_SILVER, -Money, wing_phaseup),
														role_op:money_change(?MONEY_GOLD, -Goldcount, wing_phaseup),
														if ItemsL=:=[]->
															   nothing;%%没有洗练锁
														   true->
															   lists:foreach(fun({Slot,Id,_Num})->
																				package_op:consume_items(Slot,Id,ItemCount) end, ItemsL)
														end,
											  			if ItemList=:=[]->
															   nothing;%%没有炼魂石
														   true->
															    lists:foreach(fun({Slot,Id,Num})->
																				package_op:consume_items(Slot,Id,Num) end, ItemList)
														end,
														Message=wing_packet:encode_wing_enchant_s2c(NewEchantInfo),
														role_op:send_data_to_gate(Message)
													   end
												end
											end
								end
					end
			end
	end.

%%洗练替换
wing_echant_replace()->
	case get(game_wing_info) of
		[]->
				nothing;
		WingGameInfo->
				{_,NowEchant}=get_echants_from_wing_info(WingGameInfo),
				NewWingGameInfo=WingGameInfo#wing_game_info{echants={NowEchant,[]}},
				put(game_wing_info,NewWingGameInfo),
				send_info_to_client()
		end.
	%%洗练					   
echant(Max,LockInfo)->
	Llist=lists:map(fun({Type,_,_})->Type end, LockInfo),
	Lists=lists:seq(1, 8)--Llist,
	NewMax=erlang:length(LockInfo),
	EchantLists=lists:seq(1, Max-NewMax),
	{Echant,_}=lists:foldl(fun(X,{Acc1,Acc2})->
					Length=erlang:length(Acc2),
					Rand=random:uniform(Length),
					Num=lists:nth(Rand,Acc2),
					{Acc1++[Num],Acc2--[Num]}
			                               end, {[],Lists}, EchantLists),
	lists:foldl(fun(EchantNum,{Acc1,Acc2})->
					 {Attr,Echantlist}= random_echant(EchantNum) ,
					 {Acc1++[Attr],Acc2++[Echantlist]} end,{[],LockInfo},Echant).
	
to_attr(Info)->
	Power=get_power_from_wing_info(Info),
	MagicDefence=get_magicdefense_from_wing_info(Info),
	RangeDefence=get_rangedefense_from_wing_info(Info),
	MeleeDefence=get_meleedefense_from_wing_info(Info),
	Hp=get_hp_from_wing_info(Info),
	Mp=get_mp_from_wing_info(Info),
	Attr=[{power,Power},{magicdefense,MagicDefence},{rangedefense,RangeDefence},{meleedefense,MeleeDefence},{hpmax,Hp},{mpmax,Mp}],
	lists:map(fun(Value)->
					  role_attr:to_role_attribute(Value) end, Attr).


to_attr_role()->
	case get(game_wing_info) of
		[]->
			[];
		GameWingInfo->
			Power=get_power_from_wing_info(GameWingInfo),
			MagicDefence=get_magicdefense_from_wing_info(GameWingInfo),
			RangeDefence=get_rangedefense_from_wing_info(GameWingInfo),
			MeleeDefence=get_meleedefense_from_wing_info(GameWingInfo),
			Hp=get_hp_from_wing_info(GameWingInfo),
			Mp=get_mp_from_wing_info(GameWingInfo),
			Speed=get_speed_from_wing_info(GameWingInfo),
			Attr=[{power,Power},{magicdefense,MagicDefence},{rangedefense,RangeDefence},{meleedefense,MeleeDefence},{mpmax,Hp},{hpmax,Mp}]
	end.

wing_to_attr_role()->
	case get(game_wing_info) of
		[]->
			[];
		GameWingInfo->
			Power=get_power_from_wing_info(GameWingInfo),
			MagicDefence=get_magicdefense_from_wing_info(GameWingInfo),
			RangeDefence=get_rangedefense_from_wing_info(GameWingInfo),
			MeleeDefence=get_meleedefense_from_wing_info(GameWingInfo),
			Hp=get_hp_from_wing_info(GameWingInfo),
			Mp=get_mp_from_wing_info(GameWingInfo),
			Speed=get_speed_from_wing_info(GameWingInfo),
			case get(classid) of
				?CLASS_MAGIC->
					Attr=[{magicpower,Power},{magicdefense,MagicDefence},{rangedefense,RangeDefence},{meleedefense,MeleeDefence},{mpmax,Hp},{hpmax,Mp},{movespeed,Speed}];
				?CLASS_RANGE->
					Attr=[{rangepower,Power},{magicdefense,MagicDefence},{rangedefense,RangeDefence},{meleedefense,MeleeDefence},{mpmax,Hp},{hpmax,Mp},{movespeed,Speed}];
				?CLASS_MELEE->
					Attr=[{meleepower,Power},{magicdefense,MagicDefence},{rangedefense,RangeDefence},{meleedefense,MeleeDefence},{mpmax,Hp},{hpmax,Mp},{movespeed,Speed}]
			end
	end.

%%飞剑等级提升重新计算飞剑基础属性
recompute_attr_by_baseattr(levelup,OldInfo,NewInfo)->
	 	  OldBasePower=wing_db:get_wing_level_add_power(OldInfo),
		  OldBaseDefense=wing_db:get_wing_level_add_defence(OldInfo),
		  OldBaseHp=wing_db:get_wing_level_add_hpmax(OldInfo),
		  OldBaseMp=wing_db:get_wing_level_add_mpmax(OldInfo),
		  NewBasePower=wing_db:get_wing_level_add_power(NewInfo),
		  NewBaseDefense=wing_db:get_wing_level_add_defence(NewInfo),
		  NewBaseHp=wing_db:get_wing_level_add_hpmax(NewInfo),
		  NewBaseMp=wing_db:get_wing_level_add_mpmax(NewInfo),
		  case get(game_wing_info) of
			  []->
				  [];
			  WingInfo->
				  Nowpower=get_power_from_wing_info(WingInfo)+(NewBasePower-OldBasePower),
				  NowMagicdefense=get_magicdefense_from_wing_info(WingInfo)+(NewBaseDefense-OldBaseDefense),
				  Nowrangedefense=get_rangedefense_from_wing_info(WingInfo)+(NewBaseDefense-OldBaseDefense),
				  Nowmeleedefense=get_meleedefense_from_wing_info(WingInfo)+(NewBaseDefense-OldBaseDefense),
				  NowHp=get_hp_from_wing_info(WingInfo)+(NewBaseHp-OldBaseHp),
				  NowMp=get_mp_from_wing_info(WingInfo)+(NewBaseMp-OldBaseMp),
				  Level=get_level_from_wing_info(WingInfo)+1,
				  NewWingInfo=update_game_wing_info(level,Level,Nowpower,NowMagicdefense,Nowrangedefense,Nowmeleedefense,NowHp,NowMp,WingInfo),
				  put(game_wing_info,NewWingInfo),
				  NewWingInfo
		  end;
recompute_attr_by_baseattr(phaseup,OldInfo,NewInfo)->
		OldBasePower=wing_db:get_wing_power_from_phaseinfo(OldInfo),
		OldBaseDefense=wing_db:get_wing_defense_from_phaseinfo(OldInfo),
		OldBaseHp=wing_db:get_wing_hpmax_from_phaseinfo(OldInfo),
		OldBaseMp=wing_db:get_wing_mpmax_from_phaseinfo(OldInfo),
		NewBasePower=wing_db:get_wing_power_from_phaseinfo(NewInfo),
		NewBaseDefense=wing_db:get_wing_defense_from_phaseinfo(NewInfo),
		NewBaseHp=wing_db:get_wing_hpmax_from_phaseinfo(NewInfo),
		NewBaseMp=wing_db:get_wing_mpmax_from_phaseinfo(NewInfo),
		Phase=wing_db:get_wing_phase_from_phaseinfo(NewInfo),
		case get(game_wing_info) of
			[]->
				[];
			WingInfo->
				Power=get_power_from_wing_info(WingInfo)+(NewBasePower-OldBasePower),
				Magicdefense=get_magicdefense_from_wing_info(WingInfo)+(NewBaseDefense-OldBaseDefense),
				RangeDefense=get_rangedefense_from_wing_info(WingInfo)+(NewBaseDefense-OldBaseDefense),
				MeleeDefense=get_meleedefense_from_wing_info(WingInfo)+(NewBaseDefense-OldBaseDefense),
				Hp=get_hp_from_wing_info(WingInfo)+(NewBaseHp-OldBaseHp),
				Mp=get_mp_from_wing_info(WingInfo)+(NewBaseMp-OldBaseMp),
				NewWingInfo=update_game_wing_info(phase,Phase,Power,Magicdefense,RangeDefense,MeleeDefense,Hp,Mp,WingInfo),
				 put(game_wing_info,NewWingInfo),
				  NewWingInfo
		  end.
recompute_attr_by_baseattr(qualityup,Info,NewInfo,SkillInfo)->
	OldBasePower=wing_db:get_power_from_qualityinfo(Info),
	OldBaseDefense=wing_db:get_defense_from_qualityinfo(Info),
	OldBaseHpmax=wing_db:get_hpmax_from_qualityinfo(Info),
	OldBaseMpmax=wing_db:get_mpmax_from_qualityinfo(Info),
	NewPower=wing_db:get_power_from_qualityinfo(NewInfo),
	NewDefense=wing_db:get_defense_from_qualityinfo(NewInfo),
	NewHpmax=wing_db:get_hpmax_from_qualityinfo(NewInfo),
	NewMpmax=wing_db:get_mpmax_from_qualityinfo(NewInfo),
	Quality=wing_db:get_quality_from_qualityinfo(NewInfo),
	case get(game_wing_info) of
		[]->
			[];
		WingInfo->
			Power=get_power_from_wing_info(WingInfo)+(NewPower-OldBasePower),
			Magicdefense=get_magicdefense_from_wing_info(WingInfo)+(NewDefense-OldBaseDefense),
			Rangedefense=get_rangedefense_from_wing_info(WingInfo)+(NewDefense-OldBaseDefense),
			MeleeDefense=get_meleedefense_from_wing_info(WingInfo)+(NewDefense-OldBaseDefense),
			Hp=get_hp_from_wing_info(WingInfo)+(NewHpmax-OldBaseHpmax),
			Mp=get_mp_from_wing_info(WingInfo)+(NewMpmax-OldBaseMpmax),
			Quality=wing_db:get_quality_from_qualityinfo(NewInfo),
			NewWingInfo=update_game_wing_info(quality,Quality,Power,Magicdefense,Rangedefense,MeleeDefense,Hp,Mp,SkillInfo,WingInfo),
			 put(game_wing_info,NewWingInfo),
			NewWingInfo
	end.

recompute_attr_by_baseattr(instenfify,Strength,Perfect_value,StrengthAdd,SkillInfo)->
	case get(game_wing_info) of 
		[]->
			[];
		GameInfo->
			Power=get_power_from_wing_info(GameInfo),
			Magicdefense=get_magicdefense_from_wing_info(GameInfo),
			Rangedefense=get_rangedefense_from_wing_info(GameInfo),
			Meleedefense=get_meleedefense_from_wing_info(GameInfo),
			Hp=get_hp_from_wing_info(GameInfo),
			Mp=get_mp_from_wing_info(GameInfo),
			OldStrengthAdd=get_strength_add_from_wing_info(GameInfo),
			NewRate=(StrengthAdd)/(OldStrengthAdd),
			NewPower=trunc(Power*NewRate),
			Newmagicdefense=trunc(Magicdefense*NewRate),
			Newrangedefense=trunc(Rangedefense*NewRate),
			Newmeleedefense=trunc(Meleedefense*NewRate),
			NewHp=trunc(Hp*NewRate),
			NewMp=trunc(Mp*NewRate),
			NewGameInfo=
				update_game_wing_info(instenfify,Strength,Perfect_value,StrengthAdd,NewPower,Newmagicdefense,Newrangedefense,Newmeleedefense,NewHp,NewMp,SkillInfo,GameInfo),
			 put(game_wing_info,NewGameInfo),
			NewGameInfo
	end.
			
							  
update_game_wing_info(level,Level,Power,Magicdefense,Rangedefense,Meleedefense,Hp,Mp,WingInfo)->
		NewWingInfo=WingInfo#wing_game_info{level=Level,power=Power,magicdefense=Magicdefense,rangedefense=Rangedefense,meleedefense=Meleedefense,hp=Hp,mp=Mp},
		NewWingInfo;
update_game_wing_info(phase,Phase,Power,Magicdefense,Rangedefense,Meleedefense,Hp,Mp,WingInfo)->
	NewWingInfo=WingInfo#wing_game_info{socail=Phase,power=Power,magicdefense=Magicdefense,rangedefense=Rangedefense,meleedefense=Meleedefense,hp=Hp,mp=Mp},
		NewWingInfo.

update_game_wing_info(quality,Quality,Power,Magicdefense,Rangedefense,Meleedefense,Hp,Mp,Skill,WingInfo)->
	NewWingInfo=WingInfo#wing_game_info{quality=Quality,power=Power,magicdefense=Magicdefense,rangedefense=Rangedefense,meleedefense=Meleedefense,hp=Hp,mp=Mp,skills=Skill},
	NewWingInfo.

update_game_wing_info(instenfify,Strength,Perfect_value,StrengthAdd,Power,Magicdefense,Rangedefense,Meleedefense,Hp,Mp,SkillInfo,GameInfo)->
	NewWingInfo=GameInfo#wing_game_info{strength=Strength,strength_add=StrengthAdd,perfect_value=Perfect_value,
							power=Power,magicdefense=Magicdefense,rangedefense=Rangedefense,meleedefense=Meleedefense,hp=Hp,mp=Mp,skills=SkillInfo},
	NewWingInfo.
		  
	
compute_attr_by_strengadd(StrengAdd,Power,MagicDefence,RangeDefence,MeleeDefence,Hp,Mp)->
	NewPower=trunc(Power*(1+(StrengAdd-100)/100)),
	NewMagicDefence=trunc(MagicDefence*(1+(StrengAdd-100)/100)),
	NewRangeDefence=trunc(RangeDefence*(1+(StrengAdd-100)/100)),
	NewMeleeDefence=trunc(MeleeDefence*(1+(StrengAdd-100)/100)),
	NewHp=trunc(Hp*(1+(StrengAdd-100)/100)),
	NewMp=trunc(Mp*(1+(StrengAdd-100)/100)),
	{NewPower,NewMagicDefence,NewRangeDefence,NewMeleeDefence,NewHp,NewMp}.

can_phase(Lucky,PhaseInfo)->
	Failedbless=wing_db:get_wing_failedbless_from_phaseinfo(PhaseInfo),
	if (Lucky*Failedbless)>=?PHASE_SUCCESS_LUCKY_VALUE->
		   true;
	   true->
		   Rate=wing_db:get_wing_rate_from_phaseinfo(PhaseInfo),
		   AddRate=wing_db:get_wing_addrate_from_phaseinfo(PhaseInfo),
		   AllRate=Rate+trunc(AddRate*Lucky),
		   Random=random:uniform(?PHASE_DEFAULT_RATE),
		   if Random=<AllRate->
				  true;
			  true->
				  false
		   end
	end.

%%检查飞剑的各项属性提升是否满足条件，判断物品、钱币、元宝等
check_caninfo(ItemId,Count,Money,Gold)->
	BoundItemInfo=package_op:getSlotsByItemInfo(ItemId,true),
	NoBoundItemInfo=package_op:getSlotsByItemInfo(ItemId, false),
	NowItems=lists:merge(BoundItemInfo, NoBoundItemInfo),
	case NowItems of
		[]->
			if Gold=:=0->
				   [];
			   true->
				   case wing_db:get_item_gold_price_info(ItemId) of
					   []->
						   [];
					   ItemGoldInfo->
						   Price=wing_db:get_gold_from_itemgoldinfo(ItemGoldInfo),
						   HasGold=role_op:check_money(?MONEY_GOLD, Price*Count),
						   if not HasGold->
								  [];
							  true->
								  HasMoney=role_op:check_money(?MONEY_BOUND_SILVER, Money),
								      if not HasMoney->
											 ResultMessage=wing_packet:encode_encode_wing_opt_result_s2c(?WING_THING_NOT_ENOUGH),
		  									role_op:send_data_to_gate(ResultMessage),
											   [];
										 true->
											{[],Price*Count}
									  end
						   end
				   end
			end;
		_->
			{HasCount,ItemList}=package_op:get_need_item_info(NowItems, Count),
					if HasCount<Count->
							if Gold=:=0->
								 	 ResultMessage=wing_packet:encode_encode_wing_opt_result_s2c(?WING_THING_NOT_ENOUGH),
		  							role_op:send_data_to_gate(ResultMessage);
							   true->
								   case wing_db:get_item_gold_price_info(ItemId) of
									   []->[];
									   ItemGoldInfo->
										   Price=wing_db:get_gold_from_itemgoldinfo(ItemGoldInfo),
										   HasGold=role_op:check_money(?MONEY_GOLD, Price*(Count-HasCount)),
											if not HasGold->
												   ResultMessage=wing_packet:encode_encode_wing_opt_result_s2c(?WING_THING_NOT_ENOUGH),
		  											role_op:send_data_to_gate(ResultMessage);
											   true->
												   HasMoney=role_op:check_money(?MONEY_BOUND_SILVER, Money),
												     if not HasMoney->
															   ResultMessage=wing_packet:encode_encode_wing_opt_result_s2c(?WING_THING_NOT_ENOUGH),
		  														role_op:send_data_to_gate(ResultMessage),
															   [];
														 true->
															{ ItemList,Price*(Count-HasCount)}
													 end
											end
										end
							  end;
					 true->
						HasMoney=role_op:check_money(?MONEY_BOUND_SILVER, Money),
						      if not HasMoney->
									   ResultMessage=wing_packet:encode_encode_wing_opt_result_s2c(?WING_THING_NOT_ENOUGH),
		  								role_op:send_data_to_gate(ResultMessage),
									   [];
								 true->
									{ ItemList,0}
							  end
			end
end.
									
random_echant(Type)->
	WingGameInfo=get(game_wing_info),
	{Echants,_}=get_echants_from_wing_info(WingGameInfo),
	Nowechants=[],
	case Type of
		?Hp->
			Attr= role_attr:to_role_attribute({hpmax,150}),
			AttrInfo=wing_packet:make_echant_info(1,Attr),
			{AttrInfo,{1,1,150}};
		?POWER->
			Attr= role_attr:to_role_attribute({power,150}),
			AttrInfo=wing_packet:make_echant_info(1,Attr),
				{AttrInfo,{2,1,150}};
		?MELEEDEFENSE->
			Attr= role_attr:to_role_attribute({magicdefense,150}),
			AttrInfo=wing_packet:make_echant_info(1,Attr),
				{AttrInfo,{3,1,150}};
		?RANGEDEFENSE->
			Attr= role_attr:to_role_attribute({rangedefense,150}),
			AttrInfo=wing_packet:make_echant_info(1,Attr),
			{AttrInfo,{4,1,150}};
		?MAGICDEFENSE->
			Attr= role_attr:to_role_attribute({meleedefense,150}),
			AttrInfo=wing_packet:make_echant_info(1,Attr),
			{AttrInfo,{5,1,150}};
		?HIRATE->
			Attr= role_attr:to_role_attribute({hitrate,150}),
			AttrInfo=wing_packet:make_echant_info(1,Attr),
					{AttrInfo,{6,1,150}};
		?DODGE->
			Attr= role_attr:to_role_attribute({dodge,150}),
			AttrInfo=wing_packet:make_echant_info(1,Attr),
			{AttrInfo,{7,1,150}};
		?CRITICALRATE->
			Attr= role_attr:to_role_attribute({criticalrate,150}),
			AttrInfo=wing_packet:make_echant_info(1,Attr),
			{AttrInfo,{8,1,150}};
		?CRITICALDAMAGE->
			
			Attr= role_attr:to_role_attribute({criticaldestroyrate,150}),
			AttrInfo=wing_packet:make_echant_info(1,Attr),
			{AttrInfo,{9,1,150}};
		?TOUGHNESS->
				
			Attr= role_attr:to_role_attribute({toughness,150}),
			AttrInfo=wing_packet:make_echant_info(1,Attr),
				{AttrInfo,{10,1,150}};
		_->
			nothing
	end.
		

echant_to_attr(Type,Quality,Value)->
	case Type of
		?Hp->
			Attr= role_attr:to_role_attribute({hpmax,Value}),
			wing_packet:make_echant_info(Quality,Attr);
		?POWER->
			Attr= role_attr:to_role_attribute({power,Value}),
			wing_packet:make_echant_info(Quality,Attr);
		?MELEEDEFENSE->
			Attr= role_attr:to_role_attribute({magicdefense,Value}),
			wing_packet:make_echant_info(Quality,Attr);
		?RANGEDEFENSE->
			Attr= role_attr:to_role_attribute({rangedefense,Value}),
			wing_packet:make_echant_info(Quality,Attr);
		?MAGICDEFENSE->
			Attr= role_attr:to_role_attribute({meleedefense,Value}),
			wing_packet:make_echant_info(Quality,Attr);
		?HIRATE->
			Attr= role_attr:to_role_attribute({hitrate,Value}),
			wing_packet:make_echant_info(Quality,Attr);
		?DODGE->
			Attr= role_attr:to_role_attribute({dodge,Value}),
			wing_packet:make_echant_info(Quality,Attr);
		?CRITICALRATE->
			Attr= role_attr:to_role_attribute({criticalrate,Value}),
			wing_packet:make_echant_info(Quality,Attr);
		?CRITICALDAMAGE->
			Attr= role_attr:to_role_attribute({criticaldestroyrate,Value}),
			wing_packet:make_echant_info(Quality,Attr);
		?TOUGHNESS->
			Attr= role_attr:to_role_attribute({toughness,Value}),
			wing_packet:make_echant_info(Quality,Attr);
		_->
			nothing
	end.
make_wing_game_info(Level,Socail,Quality,Strength,StrengthUp,StrengthAdd,Perfect_value,Skill,Echants,Lucky,Power,MagicDefence,RangeDefence,MeleeDefence,Hp,Mp,Speed)->
	#wing_game_info{
					level=Level,
					socail=Socail,
					quality=Quality,
					strength=Strength,
					streng_up=StrengthUp,
					strength_add=StrengthAdd,
					perfect_value=Perfect_value,
					skills=Skill,
					echants=Echants,
					lucky=Lucky,
					power=Power,
					magicdefense=MagicDefence,
					rangedefense=RangeDefence,
					meleedefense=MeleeDefence,
					hp=Hp,
					mp=Mp,
					speed=Speed
					}.

make_save_to_db_info(GameInfo,RoleId)->
	#wing_game_info{
					level=Level,
					socail=Socail,
					quality=Quality,
					strength=Strength,
					streng_up=StrengthUp,
					perfect_value=Perfect_value,
					skills=Skill,
					echants=Echants,
					lucky=Lucky
					}=GameInfo,
	{RoleId, Level,Socail,Quality,Strength, StrengthUp, Perfect_value,Skill,Echants, Lucky}.
	
