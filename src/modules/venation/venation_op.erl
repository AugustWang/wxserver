%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(venation_op).

-compile(export_all).


-include("venation_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("item_define.hrl").
%% process dic 
%% venation_info [{id,[venation_point]}] 
%% venation_attr_addtion []
%% venation_shareexp 
%% venation_activepoint_info {}
%% venation_time_countdown
%% venation_info_cache {message,timestamp}  
%% role_venation_advanced [{id,venation_bone}]


-define(VENATION_CACHE_TIME,1000000).

%%
%%api function
%%
init()->
	put(venation_info_cache,[]),
	put(venation_activepoint_info,[]),	
	put(venation_time_countdown,[]),
	case venation_advanced_db:get_role_venation_info(get(roleid)) of
		[] ->
			Role_Info = lists:map(fun(Id)->      %%Role_Info = Role_Venation_Info
								{Id,0}%%%%%%%%%%%%%@@wb20130402 {Id,[]}
							  end,lists:seq(1,?VENATION_NUM)),
			put(role_venation_advanced,Role_Info);
		RoleVenationInfo ->
			put(role_venation_advanced,RoleVenationInfo)
	end,
	case role_venation_db:get_info(get(roleid)) of
		[]->
			VernationInfo = lists:map(fun(Id)->
										{Id,[]}
										end,lists:seq(1,?VENATION_NUM)),
			put(venation_info,VernationInfo),
			put(venation_attr_addtion,[]),
			{Date,Time} = calendar:now_to_local_time(timer_center:get_correct_now()),
			put(venation_shareexp,role_venation_db:make_shareexp(0,?SHARE_EXP_TIME_PERDAY,Date)),
			role_venation_db:create_venationinfo(get(roleid),
												VernationInfo,
												get(venation_shareexp));
		Info->
			put(venation_info,role_venation_db:get_active_point(Info)),
			init_venation_list(),
			role_venation_db:set_active_point(get(roleid),get(venation_info)),
			put(venation_shareexp,role_venation_db:get_share_exp(Info)),
			put(venation_attr_addtion,init_venation_attr_addtion()),
			case update_remainexptime() of
				true->
					role_venation_db:set_share_exp(get(roleid),get(venation_shareexp));
				_->
					nothing
			end
	end,
	%%send to client init info
	VenationList= lists:map(fun({Id,PointList})->
								venation_packet:make_vp(Id,PointList)
							end,get(venation_info)),

	VenationBone = lists:map(fun({Id,Bone})->
									 venation_packet:make_bone(Id,Bone)
							 end,get(role_venation_advanced)),
	AttrInfo = to_role_attr(),
	RemainTime = role_venation_db:get_remain_share_time(get(venation_shareexp)),
	TotalExp = role_venation_db:get_total_exp(get(venation_shareexp)),
	Message = venation_packet:encode_venation_init_s2c(VenationList,VenationBone,AttrInfo,RemainTime,TotalExp),
	role_op:send_data_to_gate(Message).

process_message({venation_active_point_start_c2s,_,Venation,Point,ItemNum})->
	case (get_level_from_roleinfo(get(creature_info)) >= ?VENATION_OPEN_LEVEL)  and (not check_activepoint_state()) of %%check level and activepoint state
		true->
			if
				Venation > 0, Venation =< ?VENATION_NUM ,Point > 0, ItemNum >= 0,ItemNum =<?VENATION_ITEM_MAXNUM -> %%check param.
					{_,Points} = lists:nth(Venation,get(venation_info)),
					case lists:member(Point,Points) of %%check self
						true->
							nothing;
						_->
							case venation_point_db:get_info({Venation,Point}) of
								[]->
									nothing;
								PointInfo->
									%%check parent
									ParentPoint = venation_point_db:get_parent_point(PointInfo),
									CheckParent = (ParentPoint =:= 0) or (lists:member(ParentPoint,Points)),
									%%check soulpower
									SoulPower = venation_point_db:get_soulpower(PointInfo),
									CheckSoulPower = (role_soulpower:get_cursoulpower() >= SoulPower),
									%%check item
									CurItemNum = package_op:get_counts_by_class_in_package(?ITEM_TYPE_VENATION),
									if
										ItemNum =:= 0->
											ItemAddRate = 0;
										true->
											ItemAddRate = venation_item_rate_db:get_rate(venation_item_rate_db:get_info(ItemNum))
									end,
									CheckItem = (CurItemNum >= ItemNum) and (ItemAddRate =/= []),
									Money = venation_point_db:get_money(PointInfo),
									CheckMoney = role_op:check_money(?MONEY_BOUND_SILVER,Money),
 									CheckNeedLevel = get(level) >= venation_point_db:get_needlevel(PointInfo), 
									if
										not CheckParent ->
											OptMessage = venation_packet:encode_venation_active_point_opt_s2c(?VENATION_OPT_FAILD),
											role_op:send_data_to_gate(OptMessage);
										not CheckSoulPower->
											OptMessage = venation_packet:encode_venation_active_point_opt_s2c(?VENATION_OPT_FAILD),
											role_op:send_data_to_gate(OptMessage);
										not CheckItem->
											OptMessage = venation_packet:encode_venation_active_point_opt_s2c(?VENATION_OPT_FAILD),
											role_op:send_data_to_gate(OptMessage);
										not CheckMoney->
											OptMessage = venation_packet:encode_venation_active_point_opt_s2c(?VENATION_OPT_FAILD),
											role_op:send_data_to_gate(OptMessage);
 										not CheckNeedLevel->
 											OptMessage = venation_packet:encode_venation_active_point_opt_s2c(?VENATION_OPT_FAILD),
 											role_op:send_data_to_gate(OptMessage);	
										true->
											%%consume item
											role_op:consume_items_by_classid(?ITEM_TYPE_VENATION,ItemNum),
											%%consume soulpower
											role_op:consume_soulpower(SoulPower),
											%%change money
											role_op:money_change(?MONEY_BOUND_SILVER,0-Money,xiuwei),
											%% cal rate
											ActiveRate = min(venation_point_db:get_active_rate(PointInfo)+ItemAddRate,100),
											case random:uniform(100) > ActiveRate of	
												true->	%%faild
													gm_logger_role:role_venation(get(roleid),Venation,Point,faild,get(level)),
													OptMessage = venation_packet:encode_venation_active_point_opt_s2c(?VENATION_OPT_FAILD),
													role_op:send_data_to_gate(OptMessage);
												_->
													put(venation_activepoint_info,{Venation,Point}),
													put(venation_time_countdown,?VENATION_TIME_S),
													OptMessage = venation_packet:encode_venation_active_point_opt_s2c(?VENATION_OPT_SUCCESS),
													role_op:send_data_to_gate(OptMessage),
													role_fighting_force:hook_on_change_role_fight_force(),
													time_countdown()
											end
									end
							end
					end;
				true->
					nothing
			end;
		_->
			nothing
	end;

%%process_message({venation_active_point_end_c2s})->
%%	case get(venation_activepoint_info) of
%%		[]->
%%			slogger:msg("~p enation_active_point_end_c2s faild maybe hack ~n",[get(roleid)]);
%%		{Venation,Point}->
%%			put(venation_activepoint_info,[]),
%%			put(venation_time_countdown,[]),
%%			add_active_point({Venation,Point}),
%%			shareexp();
%%		_->
%%			nothing
%%	end;
process_message({venation_advanced_start_c2s,_,VenationId,Bone,UseItem,Type})->
	venation_advanced_start(VenationId,Bone,UseItem,Type);

process_message({share_exp})->
	share_other_exp();

process_message({timer})->
	time_countdown();

process_message({other_inspect_you,ServerId,RoleId})->
	case get(venation_info_cache) of
		{MsgCache,CacheTime}->
			TimeDiff = timer:now_diff(now(),CacheTime),
			if
				TimeDiff >=0, TimeDiff < ?VENATION_CACHE_TIME->
					MsgBin = MsgCache;
				true->
					MsgBin = make_info_for_other(), 
					TimeStamp = now(),
					put(venation_info_cache,{MsgBin,TimeStamp})	
			end;
		_->
			MsgBin = make_info_for_other(), 
			TimeStamp = now(),
			put(venation_info_cache,{MsgBin,TimeStamp})
	end,
	role_pos_util:send_to_role_clinet_by_serverid(ServerId,RoleId,MsgBin);

process_message(_)->
	slogger:msg("venation get unknown msg~n").

gm_venation(Venation,Count)->
	if (Venation > 0) and (Venation =< ?VENATION_NUM) ->
		   if (Count > 0) and (Count =< 21) ->
					Point = lists:seq(1,Count),
					put(venation_info,lists:keyreplace(Venation,1,get(venation_info),{Venation,Point})),
					role_venation_db:set_active_point(get(roleid),get(venation_info)),
					init();
			  true->
				  nothing
		   end;
	   true->
		   nothing
	end.
	
gm_venation_advanced(VenationId,Bone)->
	if (VenationId > 0) and (VenationId =< ?VENATION_NUM) ->
		    if (Bone > 0) and (Bone =< 10) ->
					put(role_venation_advanced,lists:keyreplace(VenationId, 1, get(role_venation_advanced), {VenationId,Bone})),
					VenationInfo = get(role_venation_advanced),
					venation_advanced_db:add_to_role_venation_advanced(get(roleid),VenationInfo),
					open_service_activities:venation_advanced(),%%@@wb20130409开服活动：修为顿悟
					init();
			   true->
				   nothing
			end;
	   true->
		   nothong
	end.

time_countdown()->
	case get(venation_time_countdown) of
		[]->
			nothing;
		Time->
			if
				Time >= 0->
					MessageBin = venation_packet:encode_venation_time_countdown_s2c(get(roleid),Time),
					role_op:broadcast_message_to_aoi_client(MessageBin),
					role_op:send_data_to_gate(MessageBin),
					put(venation_time_countdown,Time-1),
					erlang:send_after(1000, self(),{venation,{timer}});
				true->
					active_point_end()
			end
	end.	

active_point_end()->
	case get(venation_activepoint_info) of
		[]->
			nothing;
		{Venation,Point}->
			put(venation_activepoint_info,[]),
			put(venation_time_countdown,[]),
			add_active_point({Venation,Point}),
			shareexp(),
			OptMessage = venation_packet:encode_venation_opt_s2c(get(roleid),?VENATION_OPT_SUCCESS),
			role_op:send_data_to_gate(OptMessage);
		_->
			nothing
	end.

get_venation_attr()->
	get(venation_attr_addtion).

export_for_copy()->
	{get(venation_flag),
	get(venation_info),
	get(venation_attr_addtion),
	get(venation_shareexp),
	get(venation_activepoint_info),
	get(venation_time_countdown),
	get(venation_info_cache),
	get(role_venation_advanced)
	}.

load_by_copy(VentionInfo)->
	{VenationFlag,VenationInfo,AttrAddtion,ShareExp,ActivePoint,TimeCountDown,VenationInfoCache,VenationAdvance} = VentionInfo,
	put(venation_flag,VenationFlag),
	put(venation_info,VenationInfo),
	put(venation_attr_addtion,AttrAddtion),
	put(venation_shareexp,ShareExp),
	put(venation_activepoint_info,ActivePoint),
	put(venation_time_countdown,TimeCountDown),
	put(venation_info_cache,VenationInfoCache),
	put(role_venation_advanced,VenationAdvance),
	time_countdown().	


hook_on_offline()->
	case get(venation_activepoint_info) of
		[]->
			nothing;
		{Venation,Point}->
			put(venation_activepoint_info,[]),
			add_active_point({Venation,Point});
		_->
			nothing
	end.
%%
%%local function
%%

init_venation_attr_addtion()->
	VernationInfo = get(venation_info),
	NewAttr = lists:foldl(fun({Id,List},Acc1)->
								 lists:foldl(fun(PointId,Acc2)->
										PointInfo = venation_point_db:get_info({Id,PointId}),
										AttrInfo = venation_point_db:get_attr_addition(PointInfo),
										{_,Bone} = lists:keyfind(Id,1,get(role_venation_advanced)),
										if 
											Bone =:= 0 ->%%%%%%%%@@wb20130402 Bone=:=[]
												Effect = 0;
											Bone > 0 ->
												BoneInfo = venation_advanced_db:get_venation_info(Id, Bone),
												Effect = venation_advanced_db:get_venation_effect(BoneInfo);
								   			true->
									    		Effect = 0
										end,
										lists:foldl(fun({Key,Value},Acc3)->
											NewValue = Value*(100+Effect)/100,
											case lists:keyfind(Key,1,Acc3) of		
												false->
													Acc3 ++ [{Key,NewValue}];
												Info->
													{_,OldValue} = Info,
													NewInfo = {Key,OldValue + NewValue},
													lists:keyreplace(Key,1,Acc3,NewInfo)
											end
										end,Acc2,AttrInfo)
									end,Acc1,List)
						 end,[],VernationInfo),
	VernationAttr = lists:foldl(fun({Id,List},Acc1)->
						VernationTableInfo = venation_db:get_info(Id),
						TotalPoint = venation_db:get_point_num(VernationTableInfo),
						CurPoint = length(List),
						if
							TotalPoint =:= CurPoint ->
								AttrAddtion = venation_db:get_attr_addition(VernationTableInfo),
								{_,Bone} = lists:keyfind(Id,1,get(role_venation_advanced)),
								if 
									Bone =:= 0 ->%%%%%%%%@@wb20130402 Bone=:=[]
										Effect = 0;
									Bone > 0 ->
										BoneInfo = venation_advanced_db:get_venation_info(Id, Bone),
										Effect = venation_advanced_db:get_venation_effect(BoneInfo);
								   	true->
									    Effect = 0
								end,
								lists:foldl(fun({Key,Value},Acc2)->
											NewValue = Value*(100+Effect)/100,
											case lists:keyfind(Key,1,Acc2) of		
												false->
													Acc2 ++ [{Key,NewValue}];
												Info->
													{_,OldValue} = Info,
													NewInfo = {Key,OldValue + NewValue},
													lists:keyreplace(Key,1,Acc2,NewInfo)
											end
									end,Acc1,AttrAddtion);
							true->
								Acc1
						end
					end,NewAttr,VernationInfo),
	lists:map(fun({Key,Value})->
					  {Key,trunc(Value)}
					  end,VernationAttr).

%%
%%return boolean
%% if need return true
%% else return false
%%
update_remainexptime()->
	LastTime = role_venation_db:get_last_time(get(venation_shareexp)),
	{Today,Time} = calendar:now_to_local_time(timer_center:get_correct_now()),
	{DiffDays,_} = calendar:time_difference({LastTime,{0,0,0}},{Today,{0,0,0}}),
	if
		DiffDays > 0->
			AddTime = ?SHARE_EXP_TIME_PERDAY,
			LastRemainTime = role_venation_db:get_remain_share_time(get(venation_shareexp)),
			TempShareExp = role_venation_db:set_remain_share_time(get(venation_shareexp),AddTime),
			NewShareExp = role_venation_db:set_last_time(TempShareExp,Today),
			put(venation_shareexp,NewShareExp),
			true;
		true->
			false
	end.

add_active_point({Venation,Point})->
	{_,Points} = lists:nth(Venation,get(venation_info)),
	NewPoints = Points ++ [Point],
	NewVenationInfo = lists:keyreplace(Venation,1,get(venation_info),{Venation,NewPoints}),
	put(venation_info,NewVenationInfo),
	role_venation_db:add_active_point(get(roleid),{Venation,Point}),
	put(venation_attr_addtion,init_venation_attr_addtion()),
	gm_logger_role:role_venation(get(roleid),Venation,Point,success,get(level)),
	role_op:recompute_venation_attr(),
	%% notify client
	AttrInfo = to_role_attr(),
	Message = venation_packet:encode_venation_update_s2c(Venation,Point,AttrInfo),
	role_op:send_data_to_gate(Message),
	NewPoint = get_total_active_points(),
	achieve_op:achieve_update({venation},[0],NewPoint),
	goals_op:goals_update({venation},[0],NewPoint),%%
    goals_op:role_attr_update(),%%@@wb20130311
	quest_op:update({venation},NewPoint),
	achieve_op:role_attr_update().

shareexp()->
	Level = get_level_from_roleinfo(get(creature_info)),
	ExpInfo = venation_exp_proto_db:get_info(Level),
	MyExp = venation_exp_proto_db:get_exp(ExpInfo),
	role_op:obtain_exp(MyExp),
	RoleList = creature_op:get_aoi_role_by_radius(?SHARE_EXP_RADIUS),
	lists:foreach(fun(RoleId)->
						role_op:send_to_other_role(RoleId,{venation,{share_exp}})
					end,RoleList).
			
share_other_exp()->
	update_remainexptime(),
	ShareTime = role_venation_db:get_remain_share_time(get(venation_shareexp)),
	if
		ShareTime > 0->
			Level = get_level_from_roleinfo(get(creature_info)),
			ExpInfo = venation_exp_proto_db:get_info(Level),
			MyExp = venation_exp_proto_db:get_shareexp(ExpInfo),
			role_op:obtain_exp(MyExp),
			NewTotalExp = role_venation_db:get_total_exp(get(venation_shareexp)) + MyExp,
			LastTime = role_venation_db:get_last_time(get(venation_shareexp)),
			NewShareExpInfo = role_venation_db:make_shareexp(NewTotalExp,ShareTime-1,LastTime),
			put(venation_shareexp,NewShareExpInfo),
			role_venation_db:set_share_exp(get(roleid),NewShareExpInfo),
			Message = venation_packet:encode_venation_shareexp_update_s2c(ShareTime-1,NewTotalExp),
			role_op:send_data_to_gate(Message);
		true->
			nothing
	end.

check_activepoint_state()->
	case get(venation_activepoint_info) of
		[]->
			false;
		{Venation,Point}->
			true;
		_->
			false
	end.


to_role_attr()->
	{PowerFilter,PowerChange} = 
		case get(classid) of
			?CLASS_MAGIC->
				{[rangepower,rangepower_percent,meleepower,meleepower_percent],[magicpower,magicpower_percent]};
			?CLASS_RANGE->
				{[meleepower,meleepower_percent,magicpower,magicpower_percent],[rangepower,rangepower_percent]};		
			?CLASS_MELEE->
				{[magicpower,magicpower_percent,rangepower,rangepower_percent],[meleepower,meleepower_percent]}		
		end,	
	
	lists:foldl(fun({Key,Value},Re)->
					case lists:member(Key,PowerFilter) of
						true->
							Re;
						_->
							case lists:member(Key,PowerChange) of
									true->
										Re ++ [role_attr:to_role_attribute({power,Value})];
									_->
										Re ++ [role_attr:to_role_attribute({Key,Value})]
							end
					end
				end,[],get(venation_attr_addtion)).

%%
%%
%%
init_venation_list()->
	lists:foreach(fun(Id)->
					{_,ActiveList}= lists:nth(Id,get(venation_info)),
					case ActiveList of
						[]->
							nothing;
						_->
							MaxValue = lists:max(ActiveList),
							Length = length(ActiveList),
							if
								MaxValue =:= Length->
									nothing;
								true->
									NewList = lists:seq(1,MaxValue),
									put(venation_info,lists:keyreplace(Id,1,get(venation_info),{Id,NewList}))
							end
					end
				end,lists:seq(1,?VENATION_NUM)).
	
make_info_for_other()->	
	VenationList= lists:map(fun({Id,PointList})->
								venation_packet:make_vp(Id,PointList)
							end,get(venation_info)),
	AttrInfo = to_role_attr(),
	RemainTime = role_venation_db:get_remain_share_time(get(venation_shareexp)),
	TotalExp = role_venation_db:get_total_exp(get(venation_shareexp)),
	VenationBone = lists:map(fun({Id,Bone})->
									 venation_packet:make_bone(Id,Bone)
							 end,get(role_venation_advanced)),
	Message = venation_packet:encode_other_venation_info_s2c(get(roleid),VenationList,AttrInfo,RemainTime,TotalExp,VenationBone),
	Message.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%                          venation_advanced							%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
venation_advanced_start(VenationId,RBone,UseItem,Type)->
	{_,Points} = lists:nth(VenationId,get(venation_info)),
	{_,HasBone} = lists:nth(VenationId,get(role_venation_advanced)),
	Bone = erlang:min(erlang:max(HasBone,RBone),?VENATION_MAX_NUM),%%wb20130626 防止玩家操作过快客户端数据滞后
	case Bone =:= ?VENATION_MAX_NUM of                   %%if bone = 10 nothing
		true->
			nothing;
		_->
			case Points of																		%%check venation points
				[] ->
					Result = ?VENATION_NOT_OPEN;
				_ ->
					{{A,B},Need_money,Need_gold,ItemId,CunsumeId} = get_venation_detail(VenationId,Bone+1),			%%{A,B} is success_rate
					case Type of
						?TYPE_GOLD->
							CheckGold = role_op:check_money(?MONEY_GOLD,Need_gold),
							CheckMoney = role_op:check_money(?MONEY_BOUND_SILVER,Need_money),
							if
								not CheckGold->
									Result = ?ERROR_LESS_GOLD;
								not CheckMoney->
									Result = ?VENATION_NO_MONEY;
								true->
									role_op:money_change(?MONEY_GOLD,0-Need_gold,xiuwei),
									role_op:money_change(?MONEY_BOUND_SILVER,-Need_money,xiuwei),
									Result = random_venation_advance({A,B},UseItem,VenationId,Bone,0,Need_money,CunsumeId)
							end;
						_->
							CheckItem = item_util:get_items_count_in_package(ItemId),
							CheckMoney = role_op:check_money(?MONEY_BOUND_SILVER,Need_money),
							if
								not CheckMoney->
									Result = ?VENATION_NO_MONEY;
								CheckItem =:= 0 ->
									Result = ?VENATION_NO_ITEM;
								true->
									role_op:consume_items(ItemId,1),          %%consume item
									role_op:money_change(?MONEY_BOUND_SILVER,-Need_money,xiuwei),
									Result = random_venation_advance({A,B},UseItem,VenationId,Bone,ItemId,Need_money,CunsumeId)
							end
					end
			end,
			AttrInfo = to_role_attr(),
			Msg = venation_packet:encode_venation_advanced_update_s2c(AttrInfo),
			role_op:send_data_to_gate(Msg),
			{_,NewBone} = lists:keyfind(VenationId,1,get(role_venation_advanced)),
			open_service_activities:venation_advanced(),%%@@wb20130409开服活动：修为顿悟
			role_fighting_force:hook_on_change_role_fight_force(),
			Message = venation_packet:encode_venation_advanced_opt_result_s2c(Result,NewBone),
			role_op:send_data_to_gate(Message)
	end.

random_venation_advance({A,B},UseItem,VenationId,Bone,ItemId,Need_money,CunsumeId)->
	ActiveRate = min(A,B),
	{_,OldBone} = lists:keyfind(VenationId,1,get(role_venation_advanced)),
	case random:uniform(A) > ActiveRate of
		true->	                %%faild
			Result = ?VENATION_FAILED,
			case UseItem of
				?NOT_USE_ITEM ->
					achieve_op:achieve_update({venation_advance},[0],-OldBone),
					put(role_venation_advanced,lists:keyreplace(VenationId, 1, get(role_venation_advanced), {VenationId,0})),
					put(venation_attr_addtion,init_venation_attr_addtion()),
					role_op:recompute_venation_attr(),
					VenationInfo = get(role_venation_advanced),
					venation_advanced_db:add_to_role_venation_advanced(get(roleid),VenationInfo),
					gm_logger_role:role_venation_advanced(get(roleid),VenationId,Bone,faild,ItemId,[],Need_money);
				?USE_ITEM->
					gm_logger_role:role_venation_advanced(get(roleid),VenationId,Bone,faild,ItemId,CunsumeId,Need_money),
					role_op:consume_items(CunsumeId,1)
			end;
		false ->										%%success
			Result = ?VENATION_SUCCESS,
			case UseItem of
				?NOT_USE_ITEM ->
					gm_logger_role:role_venation_advanced(get(roleid),VenationId,Bone,success,ItemId,[],Need_money),
					nothing;
				?USE_ITEM->
					gm_logger_role:role_venation_advanced(get(roleid),VenationId,Bone,success,ItemId,CunsumeId,Need_money),
					role_op:consume_items(CunsumeId,1)
			end,
			achieve_op:achieve_update({venation_advance},[0],1),
			goals_op:goals_update({venation_advance},[0],OldBone+1),
%% 			goals_op:goals_update({venation_advance},[0],Bone+1),%%
            goals_op:role_attr_update(),%%@@wb20130311
			achieve_op:role_attr_update(),
			put(role_venation_advanced,lists:keyreplace(VenationId, 1, get(role_venation_advanced), {VenationId,OldBone+1})),
%% 			put(role_venation_advanced,lists:keyreplace(VenationId, 1, get(role_venation_advanced), {VenationId,Bone+1})),
			VenationInfo = get(role_venation_advanced),
			venation_advanced_db:add_to_role_venation_advanced(get(roleid),VenationInfo),
			put(venation_attr_addtion,init_venation_attr_addtion()),
			role_op:recompute_venation_attr()
	end,
	Result.
%%
%%return:{Success_rate,Need_money,ItemId,CunsumeId}
%%
get_venation_detail(VenationId,Bone)->
	Venation_Info = venation_advanced_db:get_venation_info(VenationId,Bone),
	{A,B} = venation_advanced_db:get_venation_success_rate(Venation_Info),					%%Success_rate = {A,B}
	Need_money = venation_advanced_db:get_venation_need_money(Venation_Info),
	Need_gold = venation_advanced_db:get_venation_need_gold(Venation_Info),
	[ItemId,ItemBondId] = venation_advanced_db:get_venation_useitem(Venation_Info),
	[ConsumeId,ConsumeBondId] = venation_advanced_db:get_venation_consumeitem(Venation_Info),
	case item_util:get_items_count_in_package(ItemBondId) of                   %%return BondItemId if it is in package
		0 ->
			case item_util:get_items_count_in_package(ConsumeBondId) of
				0 ->
					{{A,B},Need_money,Need_gold,ItemId,ConsumeId};
				_->
					{{A,B},Need_money,Need_gold,ItemId,ConsumeBondId}
			end;
		_->
			case item_util:get_items_count_in_package(ConsumeBondId) of
				0 ->
					{{A,B},Need_money,Need_gold,ItemBondId,ConsumeId};
				_->
					{{A,B},Need_money,Need_gold,ItemBondId,ConsumeBondId}
			end
	end.

get_total_active_points()->
	lists:foldl(fun({Id,PointList},Acc)->
					Acc + length(PointList)
				end,0,get(venation_info)).

get_max_venation_advance()->
	lists:foldl(fun({Id,Bone},Acc)->
						if
							Bone =/= [] ->
								if
									Bone >= Acc ->
										Bone;
									true->
										Acc
								end;
							true->
								Acc
						end
				end,0,get(role_venation_advanced)).



