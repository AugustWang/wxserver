%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-10-10
%% Description: TODO: Add description to pet_explore_op
-module(pet_explore_op).
%%
%% Include files
%%
-export([on_playeronline/1,request_pet_explore_info/1,pet_explore_start/4,pet_explore_stop/1,
		 load_by_copy/1,export_for_copy/0,speedup_explore/1,gm_speedup_explore/1,
		 gm_change_explore_rate/1]).

-define(SUM_EXPLORE_TIMES,8).
-define(CAN_EXPLORE,1).
-define(CAN_NOT_EXPLORE,0).
-define(POWER,1).
-define(HITRATE,2).
-define(CRITICALRATE,3).
-define(STAMINA,4).
-define(NOT_IN_EXPLORE,0).
-define(EXPLORE_END,0).
-define(LEAST_TIMES,1).
-define(HAS_LUCKY_MEDAL,1).
-define(NO_LUCKY_MEDAL,0).
-include("error_msg.hrl").
-include("pet_def.hrl").
-include("item_define.hrl").
-include("pet_struct.hrl").

%%
%% API Functions
%%
%%pet_explore: record pet_explore_info,{petid,masterid,remaintimes,siteid,styleid,starttime,duration_time,lacky,last_time,ext}
%%-record(pet_explore_gain,{id,level_limit,limit_attr,attr_value,general_drop,special_drop,add_mystery_drop,unadd_mystery_drop,starttime,endtime,week}).
%%-record(pet_explore_style,{id,time,rate}).



request_pet_explore_info(PetId)->
%%	io:format("request_pet_explore_info~n"),
	case check_pet_base_info(PetId) of 
		false->
			nothing;
		?PET_STATE_EXPEDITION->
%% 			io:format("request_pet_explore_info,pet state is explore~n"),
			update_explore_state(PetId);
		_Other->
%% 			io:format("request_pet_explore_info pet is in other stateOther:~p~n",[Other]),
			case lists:keyfind(PetId,#pet_explore_info.petid,get(pet_explore_info)) of
				false->
					Now = timer_center:get_correct_now(),
					{Today,_} = calendar:now_to_local_time(Now),
					PetExploreInfo = #pet_explore_info{petid=PetId,
													   masterid=get(roleid),
													   remaintimes=?SUM_EXPLORE_TIMES,
													   siteid = ?NOT_IN_EXPLORE,
										     		   styleid = ?NOT_IN_EXPLORE,
													   duration_time = ?NOT_IN_EXPLORE,
													   lacky = ?NOT_IN_EXPLORE,
													   last_time = Today,
													   ext = 1},
%%					io:format("first explore PetexploreInfo:~p~n",[PetExploreInfo]),
					put(pet_explore_info,[PetExploreInfo|get(pet_explore_info)]),
					pet_explore_db:save_pet_explore_info_to_db([PetExploreInfo|get(pet_explore_info)]),
					UpdateMsg = pet_packet:encode_pet_explore_info_s2c(PetId,
																	   ?SUM_EXPLORE_TIMES,
																	   ?NOT_IN_EXPLORE,
																	   ?NOT_IN_EXPLORE,
																	   ?NOT_IN_EXPLORE),
					role_op:send_data_to_gate(UpdateMsg);
				PetExploreInfo->
%%					io:format("request_pet_explore_info,not in explore state,pet exploreinfo:~p~n",[PetExploreInfo]),
					RemainTimes = get_cur_explore_remaintimes(PetId),
					UpdateMsg = pet_packet:encode_pet_explore_info_s2c(PetId,
																		RemainTimes,
																		?NOT_IN_EXPLORE,
																		?NOT_IN_EXPLORE,
																		?NOT_IN_EXPLORE),
					role_op:send_data_to_gate(UpdateMsg)
			end
	end.


%%pet state is explore 
update_explore_state(PetId)->
%% 	io:format("update_explore_state~n"),
	GmPetInfo = pet_op:get_gm_petinfo(PetId),
	RemainTimes = get_cur_explore_remaintimes(PetId),
	PetExploreInfo = lists:keyfind(PetId, 
								#pet_explore_info.petid, get(pet_explore_info)),
	SiteId = get_explore_siteid(PetExploreInfo),
	StyleId = get_explore_styleid(PetExploreInfo),
	ExploreStartTime = get_explore_starttime(PetExploreInfo),
	Duration = get_explore_duration_time(PetExploreInfo),
	LackyState = get_explore_lacky(PetExploreInfo),
	Ext = get_explore_ext(PetExploreInfo),
	StyleInfo = pet_explore_db:get_explore_styleinfo(StyleId),
	GainInfo = pet_explore_db:get_explore_gaininfo(SiteId),
	Now = timer_center:get_correct_now(),
	if
		(StyleInfo =/= []) and (GainInfo =/= [])->
			ExploreRate = get_explore_style_rate(StyleInfo),
			ExploreNeedTime = get_explore_style_time(StyleInfo),
			LeftTime = ExploreNeedTime - (trunc(timer:now_diff(Now,ExploreStartTime)/1000000)+Duration),
%% 			io:format("LeftTime:~p,ExploreNeedTime:~p,Now:~p,ExploreStartTime:~p,Duration:~p~n",[LeftTime,ExploreNeedTime,Now,ExploreStartTime,Duration]),
			if
				LeftTime > 0 ->
%%					io:format("update_explore_state lefttime:~p~n",[LeftTime]),
					UpdateMsg = pet_packet:encode_pet_explore_info_s2c(PetId,RemainTimes,SiteId,StyleId,LeftTime),
					role_op:send_data_to_gate(UpdateMsg);
				true->			%%explore complete
					%%update dict
%%					io:format("explore complete ~n"),
					{MegaSec,Sec,_} = ExploreStartTime,
					Seconds = MegaSec*1000000 + Sec,
					EndTime = Seconds+ExploreNeedTime-Duration,
					TmpExploreInfo = PetExploreInfo#pet_explore_info{
						remaintimes = RemainTimes,
						siteid = ?EXPLORE_END,
						styleid = ?EXPLORE_END,
						duration_time = ?EXPLORE_END,
						lacky = ?EXPLORE_END},
					NewExploreInfo = lists:keyreplace(PetId,#pet_explore_info.petid,get(pet_explore_info),TmpExploreInfo),
					put(pet_explore_info,NewExploreInfo),
					pet_explore_db:save_pet_explore_info_to_db(NewExploreInfo),
					%%update gmpetinfo pet state
					pet_op:change_pet_state(GmPetInfo,?PET_STATE_IDLE),	
					%%update client
					UpdateMsg = pet_packet:encode_pet_explore_info_s2c(PetId,
						RemainTimes,
						?EXPLORE_END,
						?EXPLORE_END,
						?EXPLORE_END),
					role_op:send_data_to_gate(UpdateMsg),
					%%random items ,put items to packet,and notice client 
					get_gain_items(PetId,GainInfo,ExploreRate,GmPetInfo,LackyState,EndTime,Ext)
			end;
		true->
			pet_op:change_pet_state(GmPetInfo,?PET_STATE_IDLE),	
			slogger:msg("update_explore_state,data error,RoleId:~p,SiteId:~p,StyleId:~p,StyleInfo:~p,GainInfo:~p~n",[get(roleid),SiteId,StyleId,StyleInfo,GainInfo])
	end.




get_gain_items(PetId,GainInfo,ExploreRate,GmPetInfo,LackyState,EndTime,Ext)->
%%	io:format("get_gain_items~n"),
	LimitAttrKey = get_explore_gain_limit_attr_key(GainInfo),
	PetAttrVaule = get_pet_attr_value(LimitAttrKey,GmPetInfo),
	GeneralDropList = get_explore_gain_general_drop(GainInfo),
	SpecialDropList = get_explore_gain_special_drop(GainInfo),
	GeneralDrop = get_fit_drop_rule(PetAttrVaule,GeneralDropList),
	SpecialDrop = get_fit_drop_rule(PetAttrVaule,SpecialDropList),
	MysteryDrop =if
					 LackyState =:= ?HAS_LUCKY_MEDAL->
						 get_explore_gain_add_mystery_drop(GainInfo);
					 true->
						 get_explore_gain_unadd_mystery_drop(GainInfo)
				 end,
%% 	io:format("GeneralDrop:~p,SpecialDrop:~p,MysteryDrop:~p,ExploreRate:~p~n",[GeneralDrop,SpecialDrop,MysteryDrop,ExploreRate]),
	GainItems = random_gain_items(GeneralDrop,SpecialDrop,MysteryDrop,ExploreRate,[],[],[]),
	lists:foreach(fun({ProtoId,Count})->
						  creature_sysbrd_util:sysbrd({pet_explore,ProtoId},Count)
				  end,GainItems),
	ClientGainItem = lists:map(fun({Proto,Count})->
									   pet_packet:make_lti(Proto,Count)
							   			   	end, GainItems),
%%	io:format("GainItems :~p~n",[GainItems]),	
	explore_storage_op:add_item(GainItems),
	gm_logger_role:pet_explore_get_items_log(get(roleid),get(level),GainItems,EndTime,Ext),
	ItemMsg = pet_packet:encode_pet_explore_gain_info_s2c(PetId,ClientGainItem),
	role_op:send_data_to_gate(ItemMsg).


get_pet_attr_value(LimitAttrKey,GmPetInfo)->
	if
		LimitAttrKey =:= ?POWER->
			get_meleepower_value_from_pet_info(GmPetInfo);
		LimitAttrKey =:= ?HITRATE->
			get_hitrate_from_petinfo(GmPetInfo);
		LimitAttrKey =:= ?CRITICALRATE->
			get_criticalrate_from_petinfo(GmPetInfo);
		LimitAttrKey =:= ?STAMINA->
			get_toughness_value_from_pet_info(GmPetInfo)
	end.



%%get comfortably drop rule list by attrvalue
get_fit_drop_rule(PetAttrVaule,DropRuleList)->
	lists:foldl(fun({AttrPoint,DropRule},TmpDropRule)->
						if
							AttrPoint =< PetAttrVaule ->
								DropRule;
							true->
								TmpDropRule
						end
				end,[],DropRuleList).


random_gain_items(_GeneralDrop,_SpecialDrop,_MysteryDrop,0,GeneralItems,SpecialItems,MysteryItems)->
%% 	io:format("random_gain_times,GeneralItems:~p,SpecialItems:~p,MysteryItems:~p~n",[GeneralItems,SpecialItems,MysteryItems]),
	MergeGeneralItems = treasure_storage_op:array_item(GeneralItems),
	MergeSpecialItems = treasure_storage_op:array_item(SpecialItems),
	MergeMysteryItems = treasure_storage_op:array_item(MysteryItems),
  	MergeGeneralItems++MergeSpecialItems++MergeMysteryItems;
		

random_gain_items(GeneralDrop,SpecialDrop,MysteryDrop,ExploreRate,GeneralItems,SpecialItems,MysteryItems)->
%% 	io:format("ExploreRate:~p~n",[ExploreRate]),
%% 	io:format("random_gain_items(GeneralDrop,SpecialDrop,MysteryDrop,ExploreRate,GeneralItems,SpecialItems,MysteryItems)~n"),
	RandomItem = fun(Drop)->
						 TmpItems = lists:append(lists:map(fun(RuleId)-> 
																   X = drop:apply_rule(RuleId,1),
%% 																   io:format("X:~p~n",[X]),
																   X 
														   end,Drop)),
						 if 
							 erlang:is_tuple(TmpItems)->
%% 								 io:format("erlang:is_tuple(TmpItems)~n"),
								 [TmpItems];
							 true->
								 TmpItems
						 end
				 end,
%% 	RandomItem = fun(DropList)->
%% 						 lists:foldl(fun(RuleId,TempList)-> 
%% 											 lists:append(drop:apply_rule(RuleId,1),TempList) 
%% 									 end,[],DropList)
%% 				 end,
	TmpGeneralItems = RandomItem(GeneralDrop),
	TmpSpecialItems = RandomItem(SpecialDrop),
	TmpMysteryItems = RandomItem(MysteryDrop),
%% 	io:format("TmpGeneralItems:~pTmpSpecialItems:~p,TmpMysteryItems:~p~n",[TmpGeneralItems,TmpSpecialItems,TmpMysteryItems]),
	random_gain_items(GeneralDrop,
					  SpecialDrop,
					  MysteryDrop,
					  ExploreRate-1,
					  GeneralItems++TmpGeneralItems,
					  SpecialItems++TmpSpecialItems,
					  MysteryItems++TmpMysteryItems).
	

pet_explore_start(PetId,StyleId,SiteId,Lucky)->
%%	io:format("pet_explore_start,PetId:~p,StyleId:~p,SiteId:~p,Lucky:~p",[PetId,StyleId,SiteId,Lucky]),
	case check_pet_base_info(PetId) of
		false->
			noting;
		?PET_STATE_IDLE->
			StyleInfo = pet_explore_db:get_explore_styleinfo(StyleId),
			GainInfo = pet_explore_db:get_explore_gaininfo(SiteId),
			if
				(StyleInfo =/= []) and (GainInfo =/= [])->			%%judge data if exist
					case check_explore_time(GainInfo) of
						true->
%%							io:format("check_explore_time ok~n"),
							case check_explore_condition(GainInfo,PetId,Lucky) of
								true->
%%									io:format("check_explore_conditionok~n"),
									explore_process(PetId,StyleId,SiteId,Lucky);
								false->
%%									io:format("check_explore_condition false~n"),
									noting
							end;
						false->
%%							io:format("check_explore_time false~n"),
							nothing
					end;
				true->
					slogger:msg("pet_explore_start,data error,SiteId:~p,StyleId:~p,StyleInfo:~p,GainInfo:~p~n",[SiteId,StyleId,StyleInfo,GainInfo]),
					ErrorMsg = pet_packet:encode_pet_explore_error_s2c(?ERROR_UNKNOWN),
					role_op:send_data_to_gate(ErrorMsg)
			end;
		OtherState->
%%			io:format("pet_explore_start, pet state is not in explore,_Other:~p~n",[OtherState]),
			Msg = pet_packet:encode_pet_explore_error_s2c(?ERROR_PET_START_EXPLORER_STATE_ERROR),
			role_op:send_data_to_gate(Msg)
	end.

%%return:true or false 
%%check time duration ,check week
check_explore_time(GainInfo)->
	Now = timer_center:get_correct_now(),
	LocalTime = calendar:now_to_local_time(Now),
	{Today,_} = LocalTime,
	SiteStartTime = get_explore_site_starttime(GainInfo),
	SiteEndTime = get_explore_site_endtime(GainInfo),
	SiteWeekList = get_explore_site_week(GainInfo),
	DurationState = timer_util:is_in_time_point(SiteStartTime,SiteEndTime,LocalTime),
	WeekNumber = calendar:day_of_the_week(Today),
	WeekState = lists:member(WeekNumber,SiteWeekList),
	if
		WeekState or DurationState ->
%% 			io:format("check_explore_time ok~n"),
			true;
		true->
%% 			io:format("check_explore_time,WeekState:~p,DurationState:~p~n",[WeekState,DurationState]),
			Msg = pet_packet:encode_pet_explore_error_s2c(?ERROR_PET_NOT_IN_TIME),
			role_op:send_data_to_gate(Msg),
			false
	end.



%%return true or false
%%check remaintimes ,check pet attr value  ,check pet level,check lucky medal 
check_explore_condition(GainInfo,PetId,Lucky)->
	GmPetInfo = pet_op:get_gm_petinfo(PetId), 
	RemainTimes = get_cur_explore_remaintimes(PetId),
	LimitAttrKey = get_explore_gain_limit_attr_key(GainInfo),
	LimitAttrValue = get_explore_gain_attr_value(GainInfo),
	PetAttrVaule = get_pet_attr_value(LimitAttrKey,GmPetInfo),
	LimitLevel = get_explore_gain_level_limit(GainInfo),
	PetLevel = get_level_from_petinfo(GmPetInfo),
	JudgeRemainTimes = (RemainTimes >=?LEAST_TIMES),	
	JudgeLevel = (PetLevel >= LimitLevel),
	JudgeAttr = (PetAttrVaule >= LimitAttrValue),
	IsHasLuckItem = item_util:is_has_enough_item_in_package_by_class(?ITEM_TYPE_PET_LUCKY_MEDAL,1),
	JudgeLucky = (((Lucky =:= ?HAS_LUCKY_MEDAL) and IsHasLuckItem) or (Lucky =:= ?NO_LUCKY_MEDAL)),
	if
		JudgeAttr and JudgeLevel and JudgeRemainTimes and JudgeLucky->
%%			io:format("check_explore_condition(GainInfo,PetId,Lucky) ok~n"),
			true;
		true->
%%			io:format("JudgeAttr:~p, JudgeLevel:~p, JudgeRemainTimes:~p,JudgeLucky:~p~n",[JudgeAttr,JudgeLevel,JudgeRemainTimes,JudgeLucky]),
			if
				not (JudgeRemainTimes) ->
					Msg = pet_packet:encode_pet_explore_error_s2c(?ERROR_PET_EXPLORE_TIMES_NOT_ENOUGH),
					role_op:send_data_to_gate(Msg),
					false;
				not(JudgeAttr)->
					Msg = pet_packet:encode_pet_explore_error_s2c(?ERROR_PET_EXPLORE_ATTR_NOT_ENOUGH),
					role_op:send_data_to_gate(Msg),
					false;
				not(JudgeLevel)->
					Msg = pet_packet:encode_pet_explore_error_s2c(?ERROR_PET_START_EXPLORER_LEVEL_ERROR),
					role_op:send_data_to_gate(Msg),
					false;
				true->
					Msg = pet_packet:encode_pet_explore_error_s2c(?ERROR_MISS_ITEM),
					role_op:send_data_to_gate(Msg),
					false
			end
	end.




%%check explore remaintimes make sure Real-time
get_cur_explore_remaintimes(PetId)->
	Now = timer_center:get_correct_now(),
	{Today,_} = calendar:now_to_local_time(Now),
	PetExploreInfo = lists:keyfind(PetId,#pet_explore_info.petid,get(pet_explore_info)),
	LastTime = get_explore_last_time(PetExploreInfo),
	if
		LastTime =:= Today ->
%% 			io:format("get_cur_explore_remaintimes,LastTime =:= Today~n"),
			get_explore_remaintimes(PetExploreInfo);
		true->
%% 			io:format("get_cur_explore_remaintimes,LastTime =/= Today~n"),
			TmpExploreInfo = PetExploreInfo#pet_explore_info{last_time = Today,remaintimes = ?SUM_EXPLORE_TIMES},
			NewExploreInfo = lists:keyreplace(PetId,#pet_explore_info.petid,get(pet_explore_info),TmpExploreInfo),
			put(pet_explore_info,NewExploreInfo),
			pet_explore_db:save_pet_explore_info_to_db(NewExploreInfo),
			?SUM_EXPLORE_TIMES
	end.


	
%%pet_explore: record pet_explore_info,{petid,masterid,remaintimes,siteid,styleid,starttime,duration_time,lacky,last_time,ext}	
explore_process(PetId,StyleId,SiteId,Lucky)->
	if
		Lucky =:= ?HAS_LUCKY_MEDAL->
			item_util:consume_items_by_classid(?ITEM_TYPE_PET_LUCKY_MEDAL,1);
		true->
			nothing
	end,
	Now = timer_center:get_correct_now(),
    {Today,_} = calendar:now_to_local_time(Now),
%% 	io:format("star Now:~p~n",[Now]),
	%%update process dict 
	RemainTimes = get_cur_explore_remaintimes(PetId),
	PetExploreInfo = lists:keyfind(PetId,#pet_explore_info.petid,get(pet_explore_info)),
	Ext = get_explore_ext(PetExploreInfo),
	TmpExploreInfo = PetExploreInfo#pet_explore_info{
													remaintimes = RemainTimes-1,
													siteid = SiteId,
													styleid = StyleId,
													starttime = Now,
													duration_time = 0,
													lacky = Lucky,
													last_time = Today,
													ext = Ext+1},
	NewExploreInfo = lists:keyreplace(PetId,#pet_explore_info.petid,get(pet_explore_info),TmpExploreInfo),
	put(pet_explore_info,NewExploreInfo),
	pet_explore_db:save_pet_explore_info_to_db(NewExploreInfo),
%%	io:format("explore_process:~p~n",[NewExploreInfo]),
	%%update gmpetinfo pet state
	GmPetInfo = pet_op:get_gm_petinfo(PetId),
	pet_op:change_pet_state(GmPetInfo,?PET_STATE_EXPEDITION),
	%%update client
	StyleInfo = pet_explore_db:get_explore_styleinfo(StyleId),
	LeftTime = get_explore_style_time(StyleInfo),
	UpdateMsg = pet_packet:encode_pet_explore_info_s2c(PetId,
													   RemainTimes-1,
													   SiteId,
													   StyleId,
													   LeftTime),
	role_op:send_data_to_gate(UpdateMsg),
	gm_logger_role:pet_explore_log(get(roleid),get(level),SiteId,StyleId,Lucky,Ext+1).



%%stop pet explore update 
pet_explore_stop(PetId)->
	case check_pet_base_info(PetId) of
		false->
			noting;
		?PET_STATE_EXPEDITION->
%%		    io:format("pet_explore_stop, pet state is in explore~n"),
			%%update dict
			RemainTimes = get_cur_explore_remaintimes(PetId),
			PetExploreInfo = lists:keyfind(PetId,#pet_explore_info.petid,get(pet_explore_info)),
			Ext = get_explore_ext(PetExploreInfo),
			TmpExploreInfo = PetExploreInfo#pet_explore_info{
				remaintimes = RemainTimes,
				siteid = ?EXPLORE_END,
				styleid = ?EXPLORE_END,
				duration_time = ?EXPLORE_END,
				lacky = ?EXPLORE_END},
			NewExploreInfo = lists:keyreplace(PetId,#pet_explore_info.petid,get(pet_explore_info),TmpExploreInfo),
			put(pet_explore_info,NewExploreInfo),
			pet_explore_db:save_pet_explore_info_to_db(NewExploreInfo),
			%%update gmpetinfo pet state
			GmPetInfo = pet_op:get_gm_petinfo(PetId),
			pet_op:change_pet_state(GmPetInfo,?PET_STATE_IDLE),	
			%%update client
			UpdateMsg = pet_packet:encode_pet_explore_info_s2c(PetId,
				RemainTimes,
				?EXPLORE_END,
				?EXPLORE_END,
				?EXPLORE_END),
			role_op:send_data_to_gate(UpdateMsg),
			{MegaSec,Sec,_} = timer_center:get_correct_now(),
			Seconds = MegaSec*1000000 + Sec,
			gm_logger_role:pet_explore_get_items_log(get(roleid),get(level),"stop",Seconds,Ext);
		OtherState->
%% 			io:format("pet_explore_stop, pet state is not in explore,OtherState:~p~n",[OtherState]),
			Msg = pet_packet:encode_pet_explore_error_s2c(?ERROR_PET_START_EXPLORER_STATE_ERROR),
			role_op:send_data_to_gate(Msg)
	end.
	
	

speedup_explore(PetId)->
	case item_util:is_has_enough_item_in_package_by_class(?ITEM_TYPE_PET_EXPLORE_SPEEDUP,1) of
		true->
			case check_pet_base_info(PetId) of
				false->
					noting;
				?PET_STATE_EXPEDITION->
					item_util:consume_items_by_classid(?ITEM_TYPE_PET_EXPLORE_SPEEDUP,1),
%%					io:format("use_item PET_STATE_EXPEDITION~n"),
					PetExploreInfo = lists:keyfind(PetId,#pet_explore_info.petid,get(pet_explore_info)),
					Duration = erlang:element(#pet_explore_info.duration_time,PetExploreInfo),
%% 					io:format("speedup_explore Duration~p~n",[Duration+?PET_SPEEDUP_EXPLORE_TIME]),
					TmpExploreInfo = PetExploreInfo#pet_explore_info{duration_time = Duration+?PET_SPEEDUP_EXPLORE_TIME},
					NewExploreInfo = lists:keyreplace(PetId, #pet_explore_info.petid, get(pet_explore_info), TmpExploreInfo),
					put(pet_explore_info,NewExploreInfo),
					pet_explore_db:save_pet_explore_info_to_db(NewExploreInfo),
					update_explore_state(PetId);
				OtherState->
%%  					io:format("speedup_explore, pet state is not in explore,OtherState:~p~n",[OtherState]),
					Msg = pet_packet:encode_pet_explore_error_s2c(?ERROR_PET_START_EXPLORER_STATE_ERROR),
					role_op:send_data_to_gate(Msg)
			end;
		false->
%%			io:format("speedup_explore no item false~n"),
			Msg = pet_packet:encode_pet_explore_error_s2c(?ERROR_PET_NOT_ENOUGH_ITEM),
			role_op:send_data_to_gate(Msg)
	end.
			



%%check pet if exist ,if can explore ,return pet current state or false
check_pet_base_info(PetId)-> 
		case pet_op:get_gm_petinfo(PetId) of
		[]->
			slogger:msg("check_pet_base_info,not exist pet ,petid:~p~n",[PetId]),
			false;
		GmPetInfo->
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			PetProtoInfo = pet_proto_db:get_info(ProtoId),
				case pet_proto_db:get_can_explore(PetProtoInfo) of
					?CAN_EXPLORE->
						PetState = get_state_from_petinfo(GmPetInfo),
						PetState;
					?CAN_NOT_EXPLORE->
%%						io:format("check_pet_base_info, pet state is can not explore~n"),
						Msg = pet_packet:encode_pet_explore_error_s2c(?ERROR_PET_CAN_NOT_EXPLORE),
						role_op:send_data_to_gate(Msg),
						false
				end
		end.			
	



on_playeronline(RoleId)->
	case pet_explore_db:load_pet_explore_info_by_roleid(RoleId) of
		[]->
%% 			io:format("pet_explore_op,on_playeronline~n"),
			put(pet_explore_info,[]);
		ExploreInfo->
			NewExploreInfo = lists:map(fun(TmpExploreInfo)->
											   Ext = get_explore_ext(TmpExploreInfo),
											   if
												   Ext =:= undefined->
													   Tmp1ExploreInfo = TmpExploreInfo#pet_explore_info{ext = 1},
													   Tmp1ExploreInfo;
												   true->
													   TmpExploreInfo
											   end
									   end,ExploreInfo),
%% 			io:format("pet_explore_op,on_playeronline,ExploreInfo:~p~n",[NewExploreInfo]),
			put(pet_explore_info,NewExploreInfo),
			pet_explore_db:save_pet_explore_info_to_db(NewExploreInfo),
			case lists:keyfind(?PET_STATE_EXPEDITION,#gm_pet_info.state, get(gm_pets_info)) of
				false->
					nothing;
				GmPetInfo->
%% 					io:format("GmpetInfo:~p~n",[GmPetInfo]),
					PetId = get_id_from_petinfo(GmPetInfo),
					update_explore_state(PetId)
			end
	end.



export_for_copy()->
%% 	io:format("pet_explore_op,export_for_copy~n"),
	get(pet_explore_info).


load_by_copy(PetExploreInfo)->
%% 	io:format("pet_explore_op,load_by_copy,PetExploreInfo~n"),
	put(pet_explore_info,PetExploreInfo).

%%gm command

gm_change_explore_rate(Times)->
%% 	io:format("gm_change_explore_rate~n"),
	case get(pet_explore_info) of
		[]->
			nothing;
		[PetExploreInfo|_]->
%% 			io:format("PetExploreInfo:~p~n",[PetExploreInfo]),
			PetId = get_explore_petid(PetExploreInfo),
			TmpExploreInfo = PetExploreInfo#pet_explore_info{remaintimes = Times},
			NewExploreInfo = lists:keyreplace(PetId, #pet_explore_info.petid, get(pet_explore_info), TmpExploreInfo),
			put(pet_explore_info,NewExploreInfo),
			pet_explore_db:save_pet_explore_info_to_db(NewExploreInfo),
			request_pet_explore_info(PetId)
  end.

gm_speedup_explore(AddDuration)->
%% 	io:format("gm_speedup_explore~n"),
	case lists:keyfind(?PET_STATE_EXPEDITION,#gm_pet_info.state, get(gm_pets_info)) of
		false->
			nothing;
		GmPetInfo->
%% 			io:format("gm_speedup explore AddDuration:~p~n",[AddDuration]),
			PetId = get_id_from_petinfo(GmPetInfo),
			PetExploreInfo = lists:keyfind(PetId,#pet_explore_info.petid,get(pet_explore_info)),
			Duration = erlang:element(#pet_explore_info.duration_time,PetExploreInfo),
%% 			io:format("speedup_explore Duration~p~n",[Duration+AddDuration]),
			TmpExploreInfo = PetExploreInfo#pet_explore_info{duration_time = Duration+AddDuration},
			NewExploreInfo = lists:keyreplace(PetId, #pet_explore_info.petid, get(pet_explore_info), TmpExploreInfo),
			put(pet_explore_info,NewExploreInfo),
			pet_explore_db:save_pet_explore_info_to_db(NewExploreInfo),
			update_explore_state(PetId)
	end.


%%						
%%pet_explore_info,pet_explore_gain,pet_explore_style db operate
%%

%%pet_explore_info: record pet_explore_info,{petid,masterid,remaintimes,siteid,styleid,starttime,duration_time,lacky,last_time,ext}
%%get info from pet_explore_info 
get_explore_petid(PetExploreInfo)->
	PetId = erlang:element(#pet_explore_info.petid,PetExploreInfo),
	PetId.

get_explore_remaintimes(PetExploreInfo)->
	RemainTimes = erlang:element(#pet_explore_info.remaintimes,PetExploreInfo),
	RemainTimes.

get_explore_siteid(PetExploreInfo)->
	SiteId = erlang:element(#pet_explore_info.siteid,PetExploreInfo),
	SiteId.

get_explore_styleid(PetExploreInfo)->
	StyleId = erlang:element(#pet_explore_info.styleid,PetExploreInfo),
	StyleId.

get_explore_starttime(PetExploreInfo)->
	ExploreStartTime = erlang:element(#pet_explore_info.starttime,PetExploreInfo),
	ExploreStartTime.

get_explore_duration_time(PetExploreInfo)->
	Duration = erlang:element(#pet_explore_info.duration_time,PetExploreInfo),
	Duration.

get_explore_lacky(PetExploreInfo)->
	Lacky = erlang:element(#pet_explore_info.lacky,PetExploreInfo),
	Lacky.

get_explore_last_time(PetExploreInfo)->
	LastTime = erlang:element(#pet_explore_info.last_time, PetExploreInfo),
	LastTime.
get_explore_ext(PetExploreInfo)->
	Key = erlang:element(#pet_explore_info.ext, PetExploreInfo),
	Key.

%%pet_explore_gain
%%-record(pet_explore_gain,{id,level_limit,limit_attr,attr_value,general_drop,special_drop,add_mystery_drop,unadd_mystery_drop,starttime,endtime,week}).

get_explore_gain_level_limit(GainInfo)->
	LevelLimit = erlang:element(#pet_explore_gain.level_limit,GainInfo),
	LevelLimit.

get_explore_gain_limit_attr_key(GainInfo)->
	LimitAttr = erlang:element(#pet_explore_gain.limit_attr,GainInfo),
	LimitAttr.

get_explore_gain_attr_value(GainInfo)->
	LimitAttrValue = erlang:element(#pet_explore_gain.attr_value,GainInfo),
	LimitAttrValue.

get_explore_gain_general_drop(GainInfo)->
	GeneralDropList = erlang:element(#pet_explore_gain.general_drop,GainInfo),
	GeneralDropList.

get_explore_gain_special_drop(GainInfo)->
	SpecialDropList = erlang:element(#pet_explore_gain.special_drop,GainInfo),
	SpecialDropList.

get_explore_gain_add_mystery_drop(GainInfo)->
	AddMysteryDrop = erlang:element(#pet_explore_gain.add_mystery_drop,GainInfo),
	AddMysteryDrop.

get_explore_gain_unadd_mystery_drop(GainInfo)->
	UnAddMysteryDrop = erlang:element(#pet_explore_gain.unadd_mystery_drop,GainInfo),
	UnAddMysteryDrop.

get_explore_site_starttime(GainInfo)->
	SiteStartTime = erlang:element(#pet_explore_gain.starttime,GainInfo),
	SiteStartTime.

get_explore_site_endtime(GainInfo)->
	SiteEndTime = erlang:element(#pet_explore_gain.endtime,GainInfo),
	SiteEndTime.

get_explore_site_week(GainInfo)->
	WeekTime = erlang:element(#pet_explore_gain.week,GainInfo),
	WeekTime.

%%pet_explore_style
%%-record(pet_explore_style,{id,time,rate}).

get_explore_style_time(StyleInfo)->
	ExploreNeedTime = erlang:element(#pet_explore_style.time,StyleInfo),
	ExploreNeedTime.

get_explore_style_rate(StyleInfo)->
	ExploreRate = erlang:element(#pet_explore_style.rate,StyleInfo),
	ExploreRate.


