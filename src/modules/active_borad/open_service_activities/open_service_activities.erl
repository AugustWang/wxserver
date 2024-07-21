%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-11
%% Description: TODO: Add description to open_service_activities
-module(open_service_activities).

%%
%% Include files
%%
-include("item_define.hrl").
-include("item_struct.hrl").
-include("pet_struct.hrl").
-include("role_struct.hrl").
-include("open_service_activities_define.hrl").
-include("open_activities_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
load_from_db(RoleId)->
	case open_service_activities_db:get_role_service_activities_info(RoleId) of
		[]->
			Activities = ets:foldl(fun({_,ActivityInfo},Acc)->
										   ActivitiveId = element(#open_service_activities.id,ActivityInfo),
										   {StartTime,EndTime} = get_activity_time_point(ActivitiveId),
										   NowTime = calendar:local_time(),
										   PartInfo = element(#open_service_activities.partinfolist,ActivityInfo),
 										   TotlePart = length(PartInfo),
										   Info = get_role_activity_info(ActivitiveId),
										   case timer_util:is_in_time_point(StartTime, EndTime, NowTime) of
											   true->
												   AllPart = lists:map(fun(Part)->
																    		 {Part,0}
													  		    		end,lists:seq(1,TotlePart)),
												   [{ActivitiveId,AllPart,Info}|Acc];
											   false->
												   AllPart = lists:map(fun(Part)->
																			 case ActivitiveId =:= ?TYPE_LEVEL_RANK of
																				 true->
																					 {Part,0};
																				 _->
																    		 		{Part,?ACTIVITY_OVERDUE}
																			 end
													  		    		end,lists:seq(1,TotlePart)),
												   [{ActivitiveId,AllPart,0}|Acc]
										   end
					  				end,[],?OPEN_SERVICE_ACTIVITIES_ETS);
		{_,_,ActivitieInfo}->
			Activities = lists:map(fun({Id,PartInfo,Info})->
										     {StartTime,EndTime} = get_activity_time_point(Id),
										     NowTime = calendar:local_time(),
											 case timer_util:is_in_time_point(StartTime, EndTime, NowTime) of
											    false->
													 NewPartInfo = lists:map(fun({Part,State})->
																					 case Id =:= ?TYPE_LEVEL_RANK of
																				 		true->
																					 		{Part,State};
																						 _->
																							{Part,?ACTIVITY_OVERDUE}
																					 end
																			  end,PartInfo),
													 {Id,NewPartInfo,Info};
												 _->
													 NewInfo = get_role_activity_info(Id),
							  						 {Id,PartInfo,NewInfo}
											 end
									 end,ActivitieInfo)
	end,
	put(role_activities_info,Activities).

%%
%%init all
%%

%%return:true/false
check_label_is_show()->
	ets:foldl(fun({_,ActivityInfo},Acc)->
					  if
						  Acc =:= true ->
							  Acc;
						  true->
					  		  ActivitiveId = element(#open_service_activities_time.id,ActivityInfo),
					  		  IsShow = element(#open_service_activities_time.show,ActivityInfo),
							  case IsShow of
								  ?FOREVER->
									  true;
								  _->
					  		  	 	  {StartTime,EndTime} = get_activity_time_point(ActivitiveId),
					  		  		  NowTime = calendar:local_time(),
					  		  		  timer_util:is_in_time_point(StartTime, EndTime, NowTime)
							  end
					  end
				end,false,?SERVICE_ACTIVITIES_TIME_ETS).

%init_open_service_activities_c2s(0)->
%	init_open_service_activities_c2s(?TYPE_LEVEL_RANK);

%init_open_service_activities_c2s(Id)->
%	io:format("^^^^Id^^^~p~n",[Id]),
%	RoleActivityInfo = get(role_activities_info),
%	case lists:keyfind(Id,1,RoleActivityInfo) of
%		false->
%			nothing;
%		{_,AllPart,Info}->
%			{StartTime,EndTime} = get_activity_time_point(Id),
%			NowTime = calendar:local_time(),
%			case timer_util:is_in_time_point(StartTime, EndTime, NowTime) of
%				true->
%					NewInfo = get_role_activity_info(Id),
%					State = ?NOT_OVERDUE;
%				_->
%					case Id =:= ?TYPE_LEVEL_RANK of
%						true->
%							NewInfo = get_role_activity_info(Id),
%							State = ?NOT_OVERDUE;
%						_->
%							NewInfo = Info,  
%							State = ?ACTIVITY_OVERDUE
%					end
%			end,
%			LeftTime = get_left_time(EndTime,NowTime),
%			PartParam = festival_packet:open_service_make_recharge(AllPart),
%			io:format("&^&^&^&^PartParam&^&&~p~n",[PartParam]),
%			StartParam = festival_packet:make_timer(StartTime),
%			EndParam = festival_packet:make_timer(EndTime),
%			Message = open_service_activities_packet:encode_init_open_service_activities_s2c(Id,PartParam,StartParam,EndParam,LeftTime,NewInfo,State),
%			role_op:send_data_to_gate(Message)
%	end.

init_open_service_activities_c2s(_Id)->
	RoleActivityInfo = get(role_activities_info),
	Info=lists:map(fun({ActiveId,AllPart,Info})->
							  {StartTime,EndTime} = get_activity_time_point(ActiveId),
							  NowTime = calendar:local_time(),
							  case timer_util:is_in_time_point(StartTime, EndTime, NowTime) of
								  true->
									  NewInfo = get_role_activity_info(ActiveId),
									  State = ?NOT_OVERDUE;
								  _->
									  case ActiveId =:= ?TYPE_LEVEL_RANK of
										  true->
											  NewInfo = get_role_activity_info(ActiveId),
											  State = ?NOT_OVERDUE;
										  _->
											  NewInfo = Info,  
											  State = ?ACTIVITY_OVERDUE
									  end
							  end,
							  LeftTime = get_left_time(EndTime,NowTime),
                              PartParam=util:term_to_record_for_list(AllPart,nsp),
							  StartParam = festival_packet:make_timer(StartTime),
							  EndParam = festival_packet:make_timer(EndTime),
							  util:term_to_record({ActiveId,StartParam,EndParam,NewInfo,State,PartParam},nsr)
					  end,RoleActivityInfo),
			Message = open_service_activities_packet:encode_init_open_service_activities_s2c(Info),
			role_op:send_data_to_gate(Message).

export_for_copy()->
	get(role_activities_info).

load_by_copy(OpenService)->
	put(role_activities_info,OpenService).
	
update_open_service_activities(Type,Value)->
	Activity_Info = open_service_activities_db:get_service_activities_info(Type),
	PartInfo = open_service_activities_db:get_activities_part(Activity_Info),
	CanAward = lists:foreach(fun({Part,Limit,_})->
								   if
									   Value >= Limit ->
										   RoleActiveInfo = get(role_activities_info),
										   case lists:keyfind(Type,1,RoleActiveInfo) of
							  				   false->
								  				   nothing;
							  				   {_,PartInfoList,_}->
												   case lists:keyfind(Part,1,PartInfoList) of
													   false->
														   nothing;
													   {_,State}->
														   if State =:= ?NOT_FINISHED ->
																  NewPartInfo = lists:keyreplace(Part,1,PartInfoList,{Part,?CAN_REWARD}),
								  				   				  put(role_activities_info,lists:keyreplace(Type,1,RoleActiveInfo,{Type,NewPartInfo,Value})),
																  update_to_client(Type,Part,?CAN_REWARD);
															  true->
																  nothing
														   end
												   end
						  				   end;
									   true->
										   nothing
								   end
						   	  end,PartInfo).

update_level_rank(Type,Value)->
	Activity_Info = open_service_activities_db:get_service_activities_info(Type),
	PartInfo = open_service_activities_db:get_activities_part(Activity_Info),
	Result = lists:foldl(fun({Part,Limit,_},Acc)->
							  if
								  Value =< Limit ->
									  true;
								  true->
									  Acc
							  end
						  end,false,PartInfo),
	if
		Result->
			RoleActiveInfo = get(role_activities_info),
			case lists:keyfind(Type,1,RoleActiveInfo) of
				false->
					nothing;
				{_,PartInfoList,_}->
					lists:foreach(fun({Part,State})->
										RoleAvtivies = get(role_activities_info),
										ActivityInfo = lists:keyfind(Type,1,RoleAvtivies),
										{_,PartList,_} = ActivityInfo, 
										NewPartInfo = lists:keyreplace(Part,1,PartList,{Part,?CAN_REWARD}),
										put(role_activities_info,lists:keyreplace(Type,1,RoleAvtivies,{Type,NewPartInfo,Value})),
										update_to_client(Type,Part,?CAN_REWARD)
									end,PartInfoList)
			end;
		true->
			nothing
	end.

open_service_reward_activities(Type,Part)->	
	Activities_Info = open_service_activities_db:get_service_activities_info(Type),
	PartInfo = open_service_activities_db:get_activities_part(Activities_Info),
	RoleActiveInfo = get(role_activities_info),
	case lists:keyfind(Type,1,RoleActiveInfo) of
		false->
			nothing;
		{_,PartInfoList,Info} ->
			case lists:keyfind(Part,1,PartInfoList) of
				false->
					nothing;
				{_,State}->
					if State =:= ?CAN_REWARD ->
						   case lists:keyfind(Part,1,PartInfo) of
							   false->
								   nothing;
							   {_,_,RewardList}->
									case check_package(RewardList) of
			   							true->
											NewPartInfo = lists:keyreplace(Part,1,PartInfoList,{Part,?FINISHED}),
				   							put(role_activities_info,lists:keyreplace(Type,1,RoleActiveInfo,{Type,NewPartInfo,Info})),
				   							achieve_op:achieve_bonus(RewardList,open_service_reward),
				   							update_to_client(Type,Part,?FINISHED);
			   							false->
					   						todo
			   						end
						   end;
						true->
			  	    		nothing
					end
			end
	end.
	
update_to_client(Type,Part,State)->
	Message = open_service_activities_packet:encode_open_sercice_activities_update_s2c(Type,Part,State),
	role_op:send_data_to_gate(Message).

on_player_off_line()->
	Activities_Info = get(role_activities_info),
	open_service_activities_db:write_role_activities_to_db(get(roleid),Activities_Info).
	
check_package(RewardList)->
	case achieve_op:has_items_in_bonus(RewardList) of
		0->
			false;
		TotleNum ->
			case package_op:get_empty_slot_in_package(TotleNum) of
				0->
					false;
				_->	
					true
			end
	end.

%%
%%return: starttime/endtime
%%
get_activity_time_point(ActivitieId)->
	case open_service_activities_db:get_open_service_activities_timeinfo(ActivitieId) of
		[]->
			{{{1970,1,1},{0,0,0}},{{1970,1,1},{0,0,0}}};
		ActivityInfo->
			StartTime = open_service_activities_db:get_open_service_activities_starttime(ActivityInfo),
			EndTime = open_service_activities_db:get_open_service_activities_endtime(ActivityInfo),
			{StartTime,EndTime}
	end.

%%
%%return:left_time :seconds
%%
get_left_time(EndTime,NowTime)->
	EndSec = calendar:datetime_to_gregorian_seconds(EndTime),
	NowSec = calendar:datetime_to_gregorian_seconds(NowTime),
	EndSec - NowSec.

get_role_activity_info(ActivitiveId)->
	case ActivitiveId of
		?TYPE_COLLECT_EQUIPMENT->
			get_body_gold_equipment();
		?TYPE_PET_TALENT_SCORE->
			get_pet_max_score();
		?TYPE_LOOP_TOWER->
			get_role_loop_tower();
		?TYPE_CHESS_SPIRIT->
			get_best_chess_spirit_section();
		?TYPE_LEVEL_RANK->
			get_level_rank_num();
		?TYPE_ENCHANTMENT->
			get_body_equipment_enchantments();
		?TYPE_VENATION_ADVANCE->
			get_role_venation_advanced();
		?TYPE_FIGHTING_FORCE->
			get_role_figthing_force();
		_->
			0
	end.

%% ===========================================================================
%% for challenge open activities
%% ===========================================================================
collect_equipment()->
	{StartTime,EndTime} = get_activity_time_point(?TYPE_COLLECT_EQUIPMENT),
	NowTime = calendar:local_time(),
	case timer_util:is_in_time_point(StartTime, EndTime, NowTime) of
		true->
			MatchResult = get_body_gold_equipment(),
			update_open_service_activities(?TYPE_COLLECT_EQUIPMENT,MatchResult);
		false->
			nothing
	end.
%%@@wb20130409开服活动：装备升星
enchantment_equipment()->
	{StartTime,EndTime} = get_activity_time_point(?TYPE_ENCHANTMENT),
	NowTime = calendar:local_time(),
	case timer_util:is_in_time_point(StartTime, EndTime, NowTime) of
		true->
			MatchResult = get_body_equipment_enchantments(),
			update_open_service_activities(?TYPE_ENCHANTMENT,MatchResult);
		false->
			nothing
	end.
%%@@wb20130409开服活动：修为顿悟
venation_advanced()->
	{StartTime,EndTime} = get_activity_time_point(?TYPE_VENATION_ADVANCE),
	NowTime = calendar:local_time(),
	case timer_util:is_in_time_point(StartTime, EndTime, NowTime) of
		true->
			MatchResult = get_role_venation_advanced(),
			update_open_service_activities(?TYPE_VENATION_ADVANCE,MatchResult);
		false->
			nothing
	end.

pet_talent_score(Talent_Score)->
	{StartTime,EndTime} = get_activity_time_point(?TYPE_PET_TALENT_SCORE),
	NowTime = calendar:local_time(),
	case timer_util:is_in_time_point(StartTime, EndTime, NowTime) of
		true->
			update_open_service_activities(?TYPE_PET_TALENT_SCORE,Talent_Score);
		false->
			nothing
	end.

loop_tower(CurLayer)->
	{StartTime,EndTime} = get_activity_time_point(?TYPE_LOOP_TOWER),
	NowTime = calendar:local_time(),
	case timer_util:is_in_time_point(StartTime, EndTime, NowTime) of
		true->
			update_open_service_activities(?TYPE_LOOP_TOWER,CurLayer);
		false->
			nothing
	end.

chess_spirit(CurSection)->
	{StartTime,EndTime} = get_activity_time_point(?TYPE_CHESS_SPIRIT),
	NowTime = calendar:local_time(),
	case timer_util:is_in_time_point(StartTime, EndTime, NowTime) of
		true->
			update_open_service_activities(?TYPE_CHESS_SPIRIT,CurSection);
		false->
			nothing
	end.

role_level_up(RoleId)->
	role_pos_util:send_to_role(RoleId,{open_service_activities,{role_level_up}}).

handle_role_level_up()->
	{StartTime,EndTime} = get_activity_time_point(?TYPE_LEVEL_RANK),
	NowTime = calendar:local_time(),
	case timer_util:is_in_time_point(StartTime, EndTime, NowTime) of
		true->
			RankNum = get_level_rank_num(),
			update_level_rank(?TYPE_LEVEL_RANK,RankNum);
		false->
			nothing
	end.
%% ======================================================================
%% return acitvities part max value
%% ======================================================================
get_body_gold_equipment()->
	BodyItemsId = package_op:get_body_items_id(),
	MatchFun = fun(ItemId,Acc)->
					case items_op:get_item_info(ItemId) of
						[]->
							Acc;
						ItemInfo->
							ItemCless = get_class_from_iteminfo(ItemInfo),
							if ItemCless =:= ?ITEM_TYPE_RIDE ->
								   Acc;
							   true->
								   Quality = items_op:get_qualty_from_iteminfo(ItemInfo),
								   case Quality >= ?EQUIP_TYPE_GOLD of
									   true->
										   Acc + 1;
									   false->
										   Acc
								   end
							end
					end
	   		end,
	lists:foldl(MatchFun, 0, BodyItemsId).

get_body_equipment_enchantments()->
	BodyItemsId=package_op:get_body_items_id(),
	if length(BodyItemsId)>=13 ->
			ResultAcc=lists:foldl(fun(Slot,Acc)->
										  ItemInfo=package_op:get_iteminfo_in_normal_slot(Slot),
										  case ItemInfo of
											  []->
												  [0]++Acc;
											  _->
										  Enchantment=get_enchantments_from_iteminfo(ItemInfo),
										  [Enchantment]++Acc
										  end
								  end,[],[1,2,3,4,5,6,7,8,9,10,11,12,13]),
			Result=lists:min(ResultAcc);
		true->
			Result=0
	end,
	Result.

get_role_venation_advanced()->
	Rvena=venation_advanced_db:get_role_venation_info(get(roleid)),
	case Rvena of
		[]->
			0;
		VenaInfo->
			lists:foldl(fun({_,Bone},Acc)->
								Bone+Acc
						end,0,VenaInfo)
	end.

%%原来取天赋，现在取战力
get_pet_max_score()->
	case get(pets_info) of
		[]->
			0;
		_->
			PetsInfo=get(pets_info),
			MaxScore = lists:map(fun(PetInfo)->
										 PetId=get_id_from_mypetinfo(PetInfo),
										 GmPetInfo=pet_op:get_pet_gminfo(PetId),
										 get_fighting_force_from_petinfo(GmPetInfo)
						  		end,PetsInfo),
			lists:max(MaxScore)
	end.
	
get_best_chess_spirit_section()->
	case lists:keyfind(1,1,get(best_chess_spirits_info)) of
		false->
			0;
		{_,Section,_}->
			Section
	end.
	
get_role_loop_tower()->
	case get(role_loop_tower) of
		[]->
			0;
		{_,_,Highest,_}->
			Highest
	end.
	
get_level_rank_num()->
	game_rank_manager:sync_get_level_rank(get(roleid)).

%%@@20130416开服活动：个人战力
get_role_figthing_force()->
	get_fighting_force_from_roleinfo(get(creature_info)).
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	