%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(everquest_op).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("item_define.hrl").
-include("string_define.hrl").
-include("color_define.hrl").
-include("system_chat_define.hrl").
-include("error_msg.hrl").
-include("everquest_define.hrl").

%%:everquest_list [everquest] receve_time,current section,current round,current quality,quest,free_set_time
%% next_quest: used when start a everquest,if not 0, will not calculate section. 
-record(everquest,{id,rec_time,cur_sec,cur_round,cur_qua,next_quest,free_fresh_times}).

init()->
	put(everquest_list,[]).

load_from_db(EverInfos)->
	Everquests = lists:filter(fun(EverInfo)->
			QuestId = get_next_quest_by_info(EverInfo), 
			case (QuestId=:=0) of %%or (not quest_op:has_quest(QuestId)) ) of
				true->
					ProtoInfo = everquest_db:get_info(get_id_by_info(EverInfo)),
					not check_is_overdue(ProtoInfo,EverInfo);
				_->
					true
			end end, EverInfos),
	put(everquest_list,Everquests).

send_everquest_list()->
	HasEvers = lists:filter(fun(EverInfo)->quest_op:has_quest(get_next_quest_by_info(EverInfo)) end, get(everquest_list)),
	SendRecords = lists:map(fun(EverInfo)->
		#everquest{id = EverQId,cur_sec=Section,cur_round=NowRound,cur_qua=Qua,next_quest= QuestId,free_fresh_times = Freetimes} = EverInfo,
		quest_packet:make_everquest(EverQId, QuestId, Freetimes, NowRound, Section, Qua)
		end,HasEvers),
	case SendRecords of
		[]->
			nothing;
		_->
			Msg = quest_packet:encode_everquest_list_s2c(SendRecords),
			role_op:send_data_to_gate(Msg)
	end.

load_by_copy(Info)->
	put(everquest_list,Info).

export_to_db()->
	get(everquest_list).	

export_for_copy()->
	get(everquest_list).

%%%%%%%%%%%%%%%%%%%%%%%%%%%   accept   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
send_add_everquest(NewEverInfo,NpcId)->
	#everquest{id = EverQId,cur_sec=Section,cur_round=NowRound,cur_qua=Qua,next_quest= QuestId,free_fresh_times = Freetimes} = NewEverInfo,
	EverProtoInfo = everquest_db:get_info(EverQId),
	FreeSetTime = get_free_set_time(EverQId, Freetimes),
	gm_logger_role:ever_quest_accepted(get(roleid),EverQId,QuestId,NowRound,Section,get(level)),
	Msg = quest_packet:encode_start_everquest_s2c(EverQId, QuestId, Freetimes, NowRound, Section, Qua,NpcId,FreeSetTime),
	role_op:send_data_to_gate(Msg).

start_everquest(EverQId,NpcId)->
	EverProtoInfo = everquest_db:get_info(EverQId),
	case get_cur_everquest_info(EverQId) of
		[]->
			CurInfo = build_everquest_info(EverQId);
		CurInfo1->				
			case check_is_overdue(EverProtoInfo,CurInfo1) of   %%TODO:think about overdue's quest
				true->
					CurInfo = build_everquest_info(EverQId);
				_->
					CurInfo = CurInfo1
			end
	end,
	case can_accept_everquest(EverProtoInfo,CurInfo) of
		true->
			Type = everquest_db:get_type(EverProtoInfo),
			NewEverInfo = start_everquest(Type,CurInfo,EverProtoInfo),
			send_add_everquest(NewEverInfo,NpcId);
		false->
			slogger:msg("start_everquest EverQId ~p can_accept_everquest false ~n",[EverQId])
	end.
	
%%return:EverInfo	
start_everquest(?NORMAL_EVERQUEST,CurInfo,ProtoInfo)->
	#everquest{cur_round=Curround,next_quest = CurQuest,free_fresh_times = FreeTimes} =  CurInfo,
	case CurQuest of
		0->		%%never accept
			[QuestId] = everquest_db:get_quests(ProtoInfo),
			NowRound = Curround +1 ;
		QuestId->	%%has accepted
			QuestId = CurQuest,
			NowRound = Curround
	end,
	NewFreeTimes = set_free_set_time(QuestId, FreeTimes),
	NewEverInfo = CurInfo#everquest{cur_round=NowRound,next_quest = QuestId,cur_qua = ?EVERQYEST_QUALITY_WHITE,free_fresh_times = NewFreeTimes},
	add_everquest(NewEverInfo),
	NewEverInfo;

%%return:EverInfo
start_everquest(?CYCLE_EVERQUEST,CurInfo,EverProtoInfo)->
	MaxSection = everquest_db:get_sections(EverProtoInfo),
	#everquest{cur_round=Curround,cur_sec = CurSection,next_quest = CurQuest,cur_qua = CurQua,free_fresh_times = FreeTimes} =  CurInfo,
	case CurQuest of
		0->		%%never accept,random and add
			if
				 CurSection=:= 0->					%%first round
					 NewSec = CurSection+1,
					 NewRound = 1,
					 NewQua = 1;
				 CurSection=:= MaxSection->			%%max_section,next_round
					 NewSec = 1,
					 NewRound = Curround+1,
					 NewQua = 1;
				 true->
					 NewRound = Curround,
					 NewSec = CurSection +1,
					 NewQua = CurQua
			end,
			QuestId = random_obt_quest(EverProtoInfo,NewSec);
		QuestId->
			NewRound = Curround,
			NewSec = CurSection,
			NewQua = CurQua
	end,
	NewFreeTimes = set_free_set_time(QuestId, FreeTimes),
	NewEverInfo = CurInfo#everquest{cur_round=NewRound,cur_sec = NewSec ,next_quest = QuestId,cur_qua = NewQua,free_fresh_times = NewFreeTimes},
	add_everquest(NewEverInfo),
	NewEverInfo.

%%%%%%%%%%%%%%%%%%%%%%%%%%%   accept  end  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%% refresh quality %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

refresh_quality(EverQId,Type,MaxQuality,MaxTimes)->
	EverProtoInfo = everquest_db:get_info(EverQId),
	case get_cur_everquest_info(EverQId) of
		[]->
			slogger:msg("refresh_quality error role ~p not have such everquest ~p ~n",[get(roleid),EverQId]);
		EverInfo->
			case get_cur_qua_by_info(EverInfo) of
				?MAX_QUALITY->
					nothing;
				_->
					case everquest_db:get_refresh_info(EverProtoInfo) of
						[]->			%%disable refresh	
							nothing;
						_->
							RefreshResult = if Type =:= ?FRESH_TYPE_AUTO ->
												   refresh_quality(?FRESH_TYPE_AUTO,EverProtoInfo,EverInfo,MaxQuality,MaxTimes);
											   true ->
												   refresh_quality(Type,EverProtoInfo,EverInfo)
											end,										   					   
							case RefreshResult of
								error->%%@@wb20130509 é€šçŸ¥å®¢æˆ·ç«¯é“å…·ä¸è¶³
									Msg3 = quest_packet:encode_refresh_everquest_result_s2c(0,0,0),
									role_op:send_data_to_gate(Msg3);
									%nothing;
								NewQuality->
									refresh_quality_sys_brd(EverProtoInfo,NewQuality)
							end
					end
			end
	end.

%%return error/NewQuality
refresh_quality(?FRESH_TYPE_FREE,EverProtoInfo,EverInfo)->
	{MaxFree,QueRates,_,_,_,_} = everquest_db:get_refresh_info(EverProtoInfo),
	FreeTime = get_free_fresh_times_by_info(EverInfo), 
	case FreeTime < MaxFree of
		true->
			Cur_Qua = get_cur_qua_by_info(EverInfo),
			if
				Cur_Qua>?EVERQYEST_QUALITY_WHITE->		
					NewQua = random_obt_quality(EverProtoInfo,?EVERQYEST_QUALITY_GREEN,QueRates);
				true->
					NewQua = random_obt_quality(EverProtoInfo,?EVERQYEST_QUALITY_WHITE,QueRates)
			end,
			NewInfo1 = set_cur_qua_by_info(EverInfo,NewQua),
			NewInfo = set_free_fresh_times_by_info(NewInfo1,FreeTime+1),		   
			add_everquest(NewInfo),
			#everquest{id = Everqid,next_quest=QuestId} = NewInfo,
			set_free_set_time(Everqid, FreeTime),
			FreeSetTime = get_free_set_time(Everqid, FreeTime + 1),
			gm_logger_role:refresh_ever_quest(get(roleid),Everqid,?FRESH_TYPE_FREE,NewQua,get(level)),
			Msg = quest_packet:encode_refresh_everquest_s2c(Everqid,QuestId,NewQua,FreeTime+1, FreeSetTime),
			role_op:send_data_to_gate(Msg),
			NewQua;
		_->
			error
	end;

refresh_quality(?FRESH_TYPE_GOLD,EverProtoInfo,EverInfo)->
	{_,_,Gold,_,_,_} = everquest_db:get_refresh_info(EverProtoInfo),
	case role_op:check_money(?MONEY_GOLD,Gold) and (Gold=/=0) of
		true->
			role_op:money_change(?MONEY_GOLD, -Gold,lost_function),
			NewQua = proc_no_free_fresh(?FRESH_TYPE_GOLD,EverProtoInfo,EverInfo),
			NewQua;
		_->
			error
	end;

refresh_quality(?FRESH_TYPE_TICKET,EverProtoInfo,EverInfo)->
	{_,_,_,Ticket,_,_} = everquest_db:get_refresh_info(EverProtoInfo),
	case role_op:check_money(?MONEY_TICKET,Ticket) and (Ticket=/=0)of
		true->
			role_op:money_change(?MONEY_TICKET, -Ticket,lost_function),
			NewQua = proc_no_free_fresh(?FRESH_TYPE_TICKET,EverProtoInfo,EverInfo),
			NewQua;
		_->
			error
	end;

refresh_quality(?FRESH_TYPE_ITEM,EverProtoInfo,EverInfo)->
	{_,_,_,_,_,ItemType} = everquest_db:get_refresh_info(EverProtoInfo),
	case item_util:is_has_enough_item_in_package_by_class(ItemType,1) of
		true->
			item_util:consume_items_by_classid(ItemType, 1),
			NewQua = proc_no_free_fresh(?FRESH_TYPE_ITEM,EverProtoInfo,EverInfo),
			NewQua;
		_->
			error
	end;


refresh_quality(?FRESH_TYPE_MONEY,EverProtoInfo,EverInfo)->
	{_,_,_,_,Money,_} = everquest_db:get_refresh_info(EverProtoInfo),
	case role_op:check_money(?MONEY_BOUND_SILVER,Money) and (Money=/=0)of
		true->
			role_op:money_change(?MONEY_BOUND_SILVER, -Money,lost_function),
			NewQua = proc_no_free_fresh(?FRESH_TYPE_MONEY,EverProtoInfo,EverInfo),
			NewQua;
		_->
			error
	end.

refresh_quality(?FRESH_TYPE_AUTO,EverProtoInfo,EverInfo,MaxQuality,MaxTimes)->
	NewMaxTimes = case MaxTimes of
					  -1 -> 99999;
					  0 -> 1;
					  _ -> MaxTimes
				  end,
	FreeTimes = get_free_fresh_times_by_info(EverInfo),
	Cur_Qua = get_cur_qua_by_info(EverInfo),
	case proc_auto_refresh(EverProtoInfo,EverInfo,MaxQuality,NewMaxTimes,Cur_Qua, FreeTimes, 0, 0, 0) of
		{error, UseFreeTime, UseItem, UseMoney} ->
			error;
		{NewQua, UseFreeTime, UseItem, UseMoney} ->
			NewInfo1 = set_cur_qua_by_info(EverInfo,NewQua),
			NewInfo = set_free_fresh_times_by_info(NewInfo1,FreeTimes+UseFreeTime),			   
			add_everquest(NewInfo),
			#everquest{id = Everqid,next_quest=QuestId,free_fresh_times=NewFreeTimes} = NewInfo,
			set_free_set_time(Everqid, FreeTimes),
			FreeSetTime = get_free_set_time(Everqid, FreeTimes + UseFreeTime),
			gm_logger_role:refresh_ever_quest(get(roleid),Everqid,?FRESH_TYPE_AUTO,NewQua,get(level)),
			Msg = quest_packet:encode_refresh_everquest_s2c(Everqid,QuestId,NewQua,FreeTimes+UseFreeTime,FreeSetTime),
			role_op:send_data_to_gate(Msg),
			Msg2 = quest_packet:encode_refresh_everquest_result_s2c(UseFreeTime, UseItem, UseMoney),
			role_op:send_data_to_gate(Msg2),
			NewQua
	end.

proc_auto_refresh(EverProtoInfo,EverInfo,MaxQuality,MaxTimes,Quality, CurrentFreeTime, UseFreeTime, UseItem, UseMoney) ->
	if Quality >= MaxQuality ->
		   {error, UseFreeTime, UseItem, UseMoney};
	   true ->
		  case check_use_type_and_count(EverProtoInfo,EverInfo, CurrentFreeTime, UseFreeTime, UseItem, UseMoney) of
			  {true, NewCurrentFreeTime, NewUseFreeTime, NewUseItem, NewUseMoney} ->
				  {_,QueRates,_,_,_,_} = everquest_db:get_refresh_info(EverProtoInfo),
				  NewQuality = if NewCurrentFreeTime > CurrentFreeTime ->
									  if Quality >?EVERQYEST_QUALITY_WHITE ->
											 random_obt_quality(EverProtoInfo,Quality,QueRates);
										 true ->
											 random_obt_quality(EverProtoInfo,?EVERQYEST_QUALITY_WHITE,QueRates)
									  end;
								  true ->
									  if Quality > ?EVERQYEST_QUALITY_WHITE ->
											 random_obt_quality(EverProtoInfo,Quality,QueRates);
										 true ->
											 random_obt_quality(EverProtoInfo,?EVERQYEST_QUALITY_GREEN,QueRates)
									  end
							   end,
				  if MaxTimes > 1 ->
						 case proc_auto_refresh(EverProtoInfo,EverInfo,MaxQuality,MaxTimes - 1,NewQuality, NewCurrentFreeTime, NewUseFreeTime, NewUseItem, NewUseMoney) of
							 {error, NewUseFreeTime2, NewUseItem2, NewUseMoney2} ->
								 {NewQuality, NewUseFreeTime2, NewUseItem2, NewUseMoney2};
							 {NewQuality2, NewUseFreeTime2, NewUseItem2, NewUseMoney2} ->
								 {NewQuality2, NewUseFreeTime2, NewUseItem2, NewUseMoney2}
						 end;
					  true ->
							{NewQuality, NewUseFreeTime, NewUseItem, NewUseMoney}	
				  end;
			  false ->
				  {error, UseFreeTime, UseItem, UseMoney}
		  end
	end.
			  
check_use_type_and_count(EverProtoInfo,EverInfo, CurrentFreeTime, UseFreeTime, UseItem, UseMoney) ->
	{MaxFree,_,_,_,Money,ItemType} = everquest_db:get_refresh_info(EverProtoInfo),
	if CurrentFreeTime < MaxFree ->
		   {true, CurrentFreeTime + 1, UseFreeTime + 1, UseItem, UseMoney};
	   true ->
		   CheckItem = item_util:is_has_enough_item_in_package_by_class(ItemType,1),
		   if CheckItem =:= true ->
				   item_util:consume_items_by_classid(ItemType, 1),
				   {true, CurrentFreeTime, UseFreeTime, UseItem + 1, UseMoney};
			  true -> 
				  CheckMoney = role_op:check_money(?MONEY_BOUND_SILVER,Money) and (Money=/=0),
				  if CheckMoney =:= true ->
						 role_op:money_change(?MONEY_BOUND_SILVER, -Money,lost_function),
						 {true, CurrentFreeTime, UseFreeTime, UseItem, UseMoney + Money};
					 true ->
						 false
				  end
		   end
	end.
				  
			   

%%return new Quality
proc_no_free_fresh(FreshType,EverProtoInfo,EverInfo)->
	QueRates = everquest_db:get_qualityrates(EverProtoInfo),
	Cur_Qua = get_cur_qua_by_info(EverInfo),				
	if
		Cur_Qua>?EVERQYEST_QUALITY_WHITE->		
			NewQua = random_obt_quality(EverProtoInfo,Cur_Qua,QueRates);
		true->
			NewQua = random_obt_quality(EverProtoInfo,?EVERQYEST_QUALITY_GREEN,QueRates)
	end,
	NewInfo = set_cur_qua_by_info(EverInfo,NewQua),
	add_everquest(NewInfo),
	#everquest{id = Everqid,next_quest=QuestId,free_fresh_times = FreeTime} = NewInfo,
	gm_logger_role:refresh_ever_quest(get(roleid),Everqid,FreshType,NewQua,get(level)),
	FreeSetTime = get_free_set_time(Everqid, FreeTime),
	Msg = quest_packet:encode_refresh_everquest_s2c(Everqid,QuestId,NewQua,FreeTime,FreeSetTime),
	role_op:send_data_to_gate(Msg),
	NewQua.

refresh_quality_sys_brd(EverProtoInfo,NewQuality)->
	if
		NewQuality >= ?EVERQYEST_QUALITY_PURPLE->
			ParamRole = system_chat_util:make_role_param(get(creature_info)),
			QuaParam = get_quality_brd_param(NewQuality),
			case everquest_db:get_special_tag(EverProtoInfo) of
				?SPECIAL_TAG_TREASURE_TRANSPORT->
					%%system_chat_op:system_broadcast(?SYSTEM_CHAT_TREASURE_TRANSPORT_REFRESH,[ParamRole,QuaParam]);
					nothing;
				_->
					%%system_chat_op:system_broadcast(?SYSTEM_CHAT_EVERQUEST_REFRESH,[ParamRole,QuaParam])
					nothing
			end;
		true->
			nothing
	end.

get_quality_brd_param(Quality)->
	case Quality of
		?EVERQYEST_QUALITY_WHITE->system_chat_util:make_string_param(language:get_string([]),?COLOR_WHITE);
		?EVERQYEST_QUALITY_GREEN->system_chat_util:make_string_param(language:get_string(?STR_GREEN),?COLOR_GREEN);
		?EVERQYEST_QUALITY_BLUE->system_chat_util:make_string_param(language:get_string(?STR_BLUE),?COLOR_BLUE);
		?EVERQYEST_QUALITY_PURPLE->system_chat_util:make_string_param(language:get_string(?STR_PURPLE),?COLOR_PURPLE);
		?EVERQYEST_QUALITY_GOLDEN->system_chat_util:make_string_param(language:get_string(?STR_GOLDEND),?COLOR_GOLDEN);
		_->system_chat_util:make_string_param(language:get_string([]),0)
	end.	

%%%%%%%%%%%%%%%%%%%%%%%%%%% refresh quality end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% random %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
random_obt_quality(_EverProtoInfo,MinQua,QuaRates)->
	RanValue = random:uniform(lists:sum(QuaRates)),
	{ReQua,_} = lists:foldl(fun(CurRate,{LastQua,AccRateTmp})->
					if
						AccRateTmp =:= -1 ->			%% has finded
							{LastQua,AccRateTmp};
						true->
							NewAccRate = AccRateTmp + CurRate,
							CurQua = LastQua + 1,
							if
								(RanValue > AccRateTmp) and (RanValue =< NewAccRate)->			%%find!			
									{CurQua,-1};
								true->
									{CurQua,NewAccRate}
							end
					end
				end,{0,0}, QuaRates),
	erlang:max(ReQua, MinQua).

random_obt_quest(EverProtoInfo,NowSec)->
	RanValue = random:uniform(100),
	SecCount = everquest_db:get_section_counts(EverProtoInfo),
	AllQuests = everquest_db:get_quests(EverProtoInfo),
	LastEnd = (NowSec - 1)*SecCount,
	if
		RanValue =< ?CUR_SECTION_RATE->
			Acc = RanValue rem SecCount,
			RanList = lists:sublist(AllQuests, LastEnd + 1 ,SecCount),
			lists:nth(Acc+1,RanList);
		true->
			 if
				 LastEnd =:= 0->
					Acc = RanValue rem SecCount,
					RanList = lists:sublist(AllQuests, LastEnd + 1 ,SecCount),
					lists:nth(Acc+1,RanList);
				 true->
					Acc = RanValue rem LastEnd,
					RanList = lists:sublist(AllQuests, 1 ,LastEnd),
					lists:nth(Acc+1,RanList) 
			end
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% random end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%   finish %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
finish_everquest(EverQId,QuestId)->
	CurInfo = get_cur_everquest_info(EverQId),
	#everquest{id = EverQId,cur_sec=Section,cur_round=NowRound} = CurInfo,
	everquest_op:set_everquest_chance_used(EverQId),
	gm_logger_role:ever_quest_completed(get(roleid),EverQId,QuestId,NowRound,Section,get(level)),
	activity_value_op:update({complete_everquest_by_section,EverQId},Section),
	activity_value_op:update({complete_everquest_by_round,EverQId},NowRound),
	activity_value_op:update({complete_everquest,EverQId}),
	achieve_op:achieve_update({everquest},[EverQId],1).%%@@wb201320508 æ—¥å¸¸ä»»åŠ¡æˆå°±æ›´æ–°

set_everquest_chance_used(EverQId)->
	CurInfo = get_cur_everquest_info(EverQId),
	%%set next_quest 0,next start_everquest will use a new section
	NewEverinfo = set_next_quest_by_info(CurInfo,0),
	add_everquest(NewEverinfo).

%%%%%%%%%%%%%%%%%%%%%%%%%%%   finish  end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

can_accept_everquest(EverProtoInfo,EverInfo)->
	if
		EverProtoInfo=:=[]->
			false;
		true->
			{ClassNeed,MinLev,MaxLev} = everquest_db:get_required(EverProtoInfo),
			{MinGuildLevel,MaxGuildLevel} = everquest_db:get_guild_required(EverProtoInfo),
			Level = get_level_from_roleinfo(get(creature_info)),
			Class = get_class_from_roleinfo(get(creature_info)),
			DateLineCheck = timer_util:check_dateline(everquest_db:get_datelines(EverProtoInfo)),
			LevelCheck = (MinLev =< Level) and (Level=<MaxLev),
			ClassCheck = ((ClassNeed=:=0) or (ClassNeed =:=Class)),
			QuestCheck = not quest_op:has_quest(get_next_quest_by_info(EverInfo)),
			GuildCheck = guild_quest:quest_guild_check(MinGuildLevel,MaxGuildLevel),
			if 
				(ClassCheck and LevelCheck and QuestCheck and GuildCheck and DateLineCheck)->
					check_has_chance(EverProtoInfo,EverInfo);
				true->
					false
			end
	end.

check_has_chance(EverProtoInfo,EverInfo)->
	QuestType = everquest_db:get_type(EverProtoInfo),
	MaxRounds = everquest_db:get_rounds_num(EverProtoInfo),
	CruQuest = get_next_quest_by_info(EverInfo),
	AlreadyHas = (CruQuest =/= 0 ) and (not quest_op:has_quest(CruQuest)), 
	case check_is_overdue(EverProtoInfo,EverInfo) of
		true->
			true;
		false->
			Section_num = get_cur_sec_by_info(EverInfo),
			Round_num = get_cur_round_by_info(EverInfo),
			if
				QuestType =:= ?NORMAL_EVERQUEST->
					(MaxRounds=:=0) or (Round_num < MaxRounds) or AlreadyHas;
				QuestType =:= ?CYCLE_EVERQUEST->
					MaxSection = everquest_db:get_sections(EverProtoInfo),
					(MaxRounds=:=0) or (Round_num < MaxRounds) or ((Round_num =:= MaxRounds) and (Section_num < MaxSection)) or AlreadyHas;
				true->
					false
			end
	end.

check_is_overdue(EverProtoInfo,EverInfo)->
	{ClearType,ClearArg}=  everquest_db:get_clear_time(EverProtoInfo),
	Receive_time = get_rec_time_by_info(EverInfo),
	QuestId = get_next_quest_by_info(EverInfo),
	timer_util:check_is_overdue(ClearType,ClearArg,Receive_time) and (not quest_op:has_quest(QuestId)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% hook fun %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hookon_adapt_can_accpet(EverQId)->
	EverProtoInfo = everquest_db:get_info(EverQId),
	hookon_adapt_can_accpet_info(EverQId,EverProtoInfo).

hookon_adapt_can_accpet_info(EverQId,EverProtoInfo)->
	case get_cur_everquest_info(EverQId) of
		[]->
			CurInfo = build_everquest_info(EverQId);
		CurInfo1->
			case check_is_overdue(EverProtoInfo,CurInfo1) of
				true->
					CurInfo = build_everquest_info(EverQId);
				_->
					CurInfo = CurInfo1
			end
	end,
	can_accept_everquest(EverProtoInfo,CurInfo).

hookon_after_accpet_quest(QuestId)->
	nothing.
%%	case lists:keyfind(QuestId, #everquest.next_quest, get(everquest_list)) of
%%		false->
%%			nothing;
%%		EverInfo->
%%			#everquest{id = EverQId,cur_sec=Section,cur_round=NowRound,cur_qua=Qua,next_quest= QuestId,free_fresh_times = Freetimes} = EverInfo,
%%			Msg = quest_packet:encode_update_everquest_s2c(EverQId, QuestId, Freetimes, NowRound, Section, Qua),
%5			role_op:send_data_to_gate(Msg)
%%	end.		

hookon_quest_can_accept(EverQuestId,QuestId)->
	case get_cur_everquest_info(EverQuestId) of
		[]->
			false;
		EverInfo->
			case get_next_quest_by_info(EverInfo) of
				QuestId->
					not quest_op:has_quest(QuestId);
				_->
					false
			end
	end.

hook_on_quest_quit(EverQuestId,QuestId)->
	EverProtoInfo = everquest_db:get_info(EverQuestId),
	case everquest_db:get_special_tag(EverProtoInfo) of
		?SPECIAL_TAG_TREASURE_TRANSPORT->
			finish_everquest(EverQuestId,QuestId),					%%set complete even quit
			role_treasure_transport:treasure_transport_over();
		_->
			nothing
	end.

hookon_quest_complete_quest(EverQuestId,QuestId)->
	EverProtoInfo = everquest_db:get_info(EverQuestId),
	finish_everquest(EverQuestId,QuestId),
	case everquest_db:get_special_tag(EverProtoInfo) of
		?SPECIAL_TAG_TREASURE_TRANSPORT->
			role_treasure_transport:treasure_transport_over();		%%set chance used when quest accept_script by self
		_->
			nothing
	end.

%%return {EverExp,EverMoneys,EverItems}
hookon_get_rewards(EverQId,QuestId)->
	EverProtoInfo = everquest_db:get_info(EverQId),
	case get_cur_everquest_info(EverQId) of
		[]->
			{0,[],[]};
		EverInfo->
			Type = everquest_db:get_type(EverProtoInfo),
			{ReExp,ReMoneys,Items} = get_rewards(Type,EverProtoInfo,EverInfo),
			QualityExtraRewardsRate = everquest_db:get_quality_extra_rewards(EverProtoInfo),
			case QualityExtraRewardsRate of
				[] ->
					{ReExp,ReMoneys,Items};
				_ ->
					Quality = get_cur_qua_by_info(EverInfo),
					QualityExtraRewards = trunc(ReExp * lists:nth(Quality, QualityExtraRewardsRate) / 100),
					{ReExp + QualityExtraRewards,ReMoneys,Items}
			end		
	end.

%%return {EverExp,EverMoneys,EverItems}
get_rewards(?NORMAL_EVERQUEST,EverProtoInfo,EverInfo)->
	CurRound = get_cur_round_by_info(EverInfo),
	CurSec = 1,	
	AllRewards= everquest_db:get_section_rewards(EverProtoInfo),
	{_,Moneys,Exp,Items} = get_my_reward(AllRewards,CurRound,CurSec),
	case everquest_db:get_reward_exp_type(EverProtoInfo) of
		?REWARD_TYPE_NUM->
			ReExp = Exp,
			ReMoneys = Moneys;
		?REWARD_TYPE_LEVEL_NUM->
			ReExp = get(level)*Exp,
			ReMoneys = get(level)*Moneys;
		?REWARD_TYPE_DRAGON_FIGHT->
			ReExp = role_dragon_fight:get_reward_exp(),
			ReMoneys = Moneys;
		?REWARD_TYPE_TREASURE_TRANSPORT->
			{ReExp,ReMoneys} = role_treasure_transport:get_reward_exp_moneys();
		_->
			ReExp = 0,ReMoneys = []
	end,
	{ReExp,ReMoneys,Items};

%%return {EverExp,EverMoneys,EverItems}
get_rewards(?CYCLE_EVERQUEST,EverProtoInfo,EverInfo)->
	CurQua = get_cur_qua_by_info(EverInfo),
	CurSec = get_cur_sec_by_info(EverInfo),
	CurRound = get_cur_round_by_info(EverInfo),
	Addation = lists:nth(CurQua,?QUALITY_ADDATION),
	AllRewards = everquest_db:get_section_rewards(EverProtoInfo),
	{_,Moneys,Exp,Items} = get_my_reward(AllRewards,CurRound,CurSec),
	case everquest_db:get_reward_exp_type(EverProtoInfo) of
		?REWARD_TYPE_NUM->
			ReExp = trunc(Exp*(100+Addation)/100),
			ReMoneys = lists:map(fun({MType,Money})-> {MType,trunc(Money*(100+Addation)/100)}end, Moneys);
		?REWARD_TYPE_LEVEL_NUM->
			ReExp = trunc(Exp*get(level)*(100+Addation)/100),
			ReMoneys = lists:map(fun({MType,Money})-> {MType,trunc(Money*get(level)*(100+Addation)/100)}end, Moneys);
		?REWARD_TYPE_DRAGON_FIGHT->
			ReExp = role_dragon_fight:get_reward_exp(),
			ReMoneys = lists:map(fun({MType,Money})-> {MType,trunc(Money*(100+Addation)/100)}end, Moneys);
		?REWARD_TYPE_TREASURE_TRANSPORT->
			{ReExp,ReMoneys} = role_treasure_transport:get_reward_exp_moneys();
		_->
			ReExp = 0,ReMoneys = []
	end,
	{ReExp,ReMoneys,Items}.

get_my_reward(AllRewards,CurRound,CurSec)->
	case lists:keyfind(CurRound,1, AllRewards) of
		false->
			{_,Rewards} = lists:nth(erlang:length(AllRewards), AllRewards);	
		{_,Rewards}->
			nothing
	end,
	case lists:keyfind(CurSec, 1, Rewards) of
		false->
			lists:nth(erlang:length(Rewards), Rewards);
		CureReward->
			CureReward
	end.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% hook fun end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% everquest_list operate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
add_everquest(EverInfo)->
	case lists:keymember(get_id_by_info(EverInfo),#everquest.id, get(everquest_list)) of
		false->
			put(everquest_list,[EverInfo|get(everquest_list)]);
		_->
			put(everquest_list,lists:keyreplace(get_id_by_info(EverInfo),#everquest.id, get(everquest_list), EverInfo))
	end.

build_everquest_info(EverQId)->
	#everquest{id = EverQId,rec_time = timer_center:get_correct_now(),cur_sec = 0,cur_round = 0,cur_qua = 0,next_quest = 0,free_fresh_times = 0}.

has_everquest(EverQId)->
	lists:keymember(EverQId, 2, get(everquest_list)).

get_cur_everquest_info(EverQId)->
	case lists:keyfind(EverQId, 2, get(everquest_list)) of
		false->
			[];
		EverInfo->
			EverInfo
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% everquest_list operate end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% record operate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_id_by_info(EverInfo)->
	erlang:element(#everquest.id, EverInfo).

get_rec_time_by_info(EverInfo)->
	erlang:element(#everquest.rec_time, EverInfo).
set_rec_time_by_info(EverInfo,Time)->
	erlang:setelement(#everquest.rec_time, EverInfo,Time).

get_cur_sec_by_info(EverInfo)->
	erlang:element(#everquest.cur_sec, EverInfo).
set_cur_sec_by_info(EverInfo,Section)->
	erlang:setelement(#everquest.cur_sec, EverInfo,Section).

get_cur_round_by_info(EverInfo)->
	erlang:element(#everquest.cur_round, EverInfo).
set_cur_round_by_info(EverInfo,Round)->
	erlang:setelement(#everquest.cur_round, EverInfo,Round).

get_cur_qua_by_info(EverInfo)->
	erlang:element(#everquest.cur_qua, EverInfo).
set_cur_qua_by_info(EverInfo,Qua)->
	erlang:setelement(#everquest.cur_qua, EverInfo,Qua).

get_next_quest_by_info(EverInfo)->
	erlang:element(#everquest.next_quest, EverInfo).
set_next_quest_by_info(EverInfo,Quest)->
	erlang:setelement(#everquest.next_quest, EverInfo,Quest).

get_free_fresh_times_by_info(EverInfo)->
	erlang:element(#everquest.free_fresh_times, EverInfo).
set_free_fresh_times_by_info(EverInfo,Free_fresh_times)->
	erlang:setelement(#everquest.free_fresh_times, EverInfo,Free_fresh_times).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% record operate end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% free reset time %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_free_set_time(EverQuestId, FreeTimes) ->
	case everquest_db:get_info(EverQuestId) of
		[] -> 0;
		EverProtoInfo ->
			case everquest_db:get_free_recover_interval(EverProtoInfo) of
				0 -> 0;
				RecoverIntervalMax ->
					if FreeTimes =:= 0 ->
						   0;
					   true ->
							case get(everquest_free_set_times) of
								undefined -> RecoverIntervalMax;
								[] -> RecoverIntervalMax;
								EverQuestFreeSetTimes ->
									case lists:keyfind(EverQuestId, 1, EverQuestFreeSetTimes) of
										false -> RecoverIntervalMax;
										{EverQuestId, FreeSetTime} ->
											RecoverIntervalMax - ((timer_util:current_seconds() - FreeSetTime) rem RecoverIntervalMax)
									end
							end
					end
			end
	end.
			

set_free_set_time(EverQuestId, FreeTimes) ->
	case everquest_db:get_info(EverQuestId) of
		[] -> FreeTimes;
		EverProtoInfo ->
			case everquest_db:get_free_recover_interval(EverProtoInfo) of
				0 -> FreeTimes;
				RecoverIntervalMax ->
					case get(everquest_free_set_times) of
						undefined ->
							put(everquest_free_set_times, [{EverQuestId, timer_util:current_seconds()}]),
							FreeTimes;
						[] ->
							put(everquest_free_set_times, [{EverQuestId, timer_util:current_seconds()}]),
							FreeTimes;
						EverQuestFreeSetTimes ->
							case lists:keyfind(EverQuestId, 1, EverQuestFreeSetTimes) of
								false ->
									put(everquest_free_set_times, [{EverQuestId, timer_util:current_seconds()} | EverQuestFreeSetTimes]),
									FreeTimes;
								{EverQuestId, FreeSetTime} ->
									if FreeTimes =:= 0 ->
										   lists:keyreplace(EverQuestId, 1, EverQuestFreeSetTimes, {EverQuestId, timer_util:current_seconds()}),
										   put(everquest_free_set_times, EverQuestFreeSetTimes),
										   FreeTimes;
									   true ->
										   Now = timer_util:current_seconds(),
										   TimeDelta = Now - FreeSetTime,
										   FreeTimesTmp = TimeDelta div RecoverIntervalMax,
										   if FreeTimesTmp >= FreeTimes ->
												  lists:keyreplace(EverQuestId, 1, EverQuestFreeSetTimes, {EverQuestId, timer_util:current_seconds()}),
					                              put(everquest_free_set_times, EverQuestFreeSetTimes),
												  0;
											  FreeTimesTmp > 0 ->
												  lists:keyreplace(EverQuestId, 1, EverQuestFreeSetTimes, {EverQuestId, Now - TimeDelta rem RecoverIntervalMax}),
												  put(everquest_free_set_times, EverQuestFreeSetTimes),
												  FreeTimes - FreeTimesTmp;
											  true ->
												  FreeTimes
										   end
									end
							end
					end
			end
	end.
										   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% free reset time %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
