%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(instance_quality_op).

-include("error_msg.hrl").
-include("common_define.hrl").

-define(ITEM_TYPE_EXP, 136).
-record(nq,{npcproto,expfac,quality}).
-compile(export_all).

%%{Instanceid,Map_proc,protoid,Starttime,Lastpostion}
%%lastpostion:{LineId,Mapid,{LastX,LastY}}
%% instance_log:[{protoid,firsttime,count,lastid}]

init()->
	put(instance_quality_info, []),
	put(instance_quality_ext,[]),
	put(instance_quality_quality, []).

load_from_db(RoleId)->
	case role_instance_quality_db:get_instance_quality(RoleId) of
		[]->
			init();
		InstanceQuality->
			Info = role_instance_quality_db:get_quality_info(InstanceQuality),
			Ext = role_instance_quality_db:get_quality_ext(InstanceQuality),
			Quality = role_instance_quality_db:get_quality_quality(InstanceQuality),
			put(instance_quality_info, Info),
			put(instance_quality_ext,Ext),
			put(instance_quality_quality, Quality)
	end.


export_for_copy()->
	{get(instance_quality_info),get(instance_quality_ext)}.

write_to_db()->
	role_instance_quality_db:save_role_instance_info(get(roleid),get(instance_quality_info),get(instance_quality_ext), get(instance_quality_quality)).

async_write_to_db()->
	role_instance_quality_db:async_save_role_instance_info(get(roleid),get(instance_quality_info),get(instance_quality_ext), get(instance_quality_quality)).

load_by_copy({Info,Ext})->
	put(instance_quality_info, Info),
	put(instance_quality_ext,Ext).

get_quality(InstanceId, ProtoId) ->
	case get(instance_quality_info) of
		undefined -> 1;
		[] -> 1;
		Info ->
			case lists:keyfind(InstanceId, 1, Info) of
				false -> 1;
				{InstanceId, InstanceInfo} ->
					case lists:keyfind(ProtoId, 1, InstanceInfo) of
						false -> 1;
						{ProtoId, Quality} -> Quality
					end
			end
	end.

get_addfac(InstanceId, Quality) ->
	case instance_quality_db:get_info(InstanceId) of
		[] -> 1;
		ProtoInfo ->
			AddFac = instance_quality_db:get_addfac(ProtoInfo),
			lists:nth(Quality, AddFac)
	end.

get_free_refresh_quality_time(InstanceId) ->
	case instance_quality_db:get_info(InstanceId) of
		[] -> 0;
		ProtoInfo ->
			AllFreeTime = instance_quality_db:get_freetime(ProtoInfo),
			case get(instance_quality_ext) of
				undefined -> AllFreeTime;
				[] -> AllFreeTime;
				Ext ->
					case lists:keyfind(InstanceId, 1, Ext) of
						false -> 1;
						{InstanceId, UseTime} ->
							AllFreeTime - UseTime
					end
			end
	end.

reset_instance_quality(InstanceId) ->
	NewInfo = case get(instance_quality_info) of
		undefined -> [];
		[] -> [];
		Info ->
			lists:keydelete(InstanceId, 1, Info)
	end,
	put(instance_quality_info, NewInfo).

reset_instance_free_quality_time(InstanceId) ->
	NewExt = case get(instance_quality_ext) of
		undefined -> [];
		[] -> [];
		Ext ->
			lists:keydelete(InstanceId, 1, Ext)
	end,
	put(instance_quality_ext, NewExt).

get_init_result(InstanceId) ->
	return_refresh_result(InstanceId).
	
refresh_quality(MaxQuality, InstanceId, UseGold, Auto) ->
	QualityProto = instance_quality_db:get_info(InstanceId),
	case QualityProto of
		[] -> 
			Message2 = instance_packet:encode_refresh_instance_quality_opt_s2c(?MAX_QUALITY_ALREADY),
			role_op:send_data_to_gate(Message2);
		_ ->
			MaxQualityLevel = length(instance_quality_db:get_rate(QualityProto)),
			NpcList = instance_quality_db:get_npclist(QualityProto),
			NpcQalityList = lists:map(fun(ProtoId) ->
											  Quality = get_quality(InstanceId, ProtoId),
											  {ProtoId, Quality}
									  end, NpcList),
			NpcListQualityLtMax = lists:filter(fun({ProtoId, Quality}) ->
													   if Quality < MaxQualityLevel ->
															  true;
														  true ->
															  false
													   end
											   end, NpcQalityList),
			case NpcListQualityLtMax of
				[] ->
					Message1 = instance_packet:encode_refresh_instance_quality_opt_s2c(?MAX_QUALITY_ALREADY),
					role_op:send_data_to_gate(Message1);
				_ ->
					if Auto =:= 1 ->
						   NpcListQualityNeedRefreshed = lists:filter(fun({ProtoId, Quality}) ->
																		   if Quality < MaxQuality ->
																				  true;
																			  true ->
																				  false
																		   end
																   end, NpcQalityList),
						   case NpcListQualityNeedRefreshed of
							   [] ->
								   Message = instance_packet:encode_refresh_instance_quality_opt_s2c(?MAX_QUALITY_SET_ALREADY),
								   role_op:send_data_to_gate(Message);
							   _ ->
								   FreeTimes = 0,
								   ItemTimes = 0,
								   Gold = 0,
						   		   refresh_to_quality_specified(NpcListQualityLtMax, InstanceId, MaxQuality, QualityProto, FreeTimes, ItemTimes, Gold)
						   end;
					   true ->
						   refresh_once(NpcListQualityLtMax, InstanceId, QualityProto)
					end
			end
	end.


refresh_to_quality_specified(NpcListQualityLtMax, InstanceId, MaxQuality, QualityProto, FreeTimes, ItemTimes, Gold) ->
	case check_refresh_condition(InstanceId, QualityProto) of
		{ok, Type, Count} ->
			{NewFreeTimes, NewItemTimes, NewGold} = case Type of 
				1 ->
					{FreeTimes + Count, ItemTimes, Gold};
				2 ->
					{FreeTimes, ItemTimes + Count, Gold};
				3 ->
					{FreeTimes, ItemTimes, Gold + Count}
			end,
			NewNpcListQuality = lists:map(fun({ProtoId, Quality}) ->
												  Rates = instance_quality_db:get_rate(QualityProto),
												  NewQuality = util:get_random_pos(Rates, 100),
												  if Quality < NewQuality ->
														 {ProtoId, NewQuality};
													 true ->
														{ProtoId, Quality} 
												  end
										  end, NpcListQualityLtMax),
			NpcListQualityNeedRefreshed = lists:filter(fun({ProtoId, Quality}) ->
														   if Quality < MaxQuality ->
																  true;
															  true ->
																  false
														   end
												   end, NewNpcListQuality),
		    case NpcListQualityNeedRefreshed of
			    [] ->
					Message1 = instance_packet:encode_refresh_instance_quality_result_s2c(NewFreeTimes, NewItemTimes, NewGold),
					role_op:send_data_to_gate(Message1),
				    set_quality(InstanceId, NewNpcListQuality),
					return_refresh_result(InstanceId);
			    _ ->
		   		    refresh_to_quality_specified(NewNpcListQuality, InstanceId, MaxQuality, QualityProto, NewFreeTimes, NewItemTimes, NewGold)
			end;
		false ->
			Message = instance_packet:encode_refresh_instance_quality_opt_s2c(?ERROR_LESS_GOLD),
			role_op:send_data_to_gate(Message),
			set_quality(InstanceId, NpcListQualityLtMax),
			return_refresh_result(InstanceId)
	end.

refresh_once(NpcListQualityLtMax, InstanceId, QualityProto) ->
	case check_refresh_condition(InstanceId, QualityProto) of
		{ok, Type, Count} ->
			{NewFreeTimes, NewItemTimes, NewGold} = case Type of 
				1 ->
					{Count, 0, 0};
				2 ->
					{0, Count, 0};
				3 ->
					{0, 0, Count}
			end,
			NewNpcListQuality = lists:map(fun({ProtoId, Quality}) ->
												  Rates = instance_quality_db:get_rate(QualityProto),
												  NewQuality = util:get_random_pos(Rates, 100),
												  if Quality < NewQuality ->
														 {ProtoId, NewQuality};
													 true ->
														{ProtoId, Quality} 
												  end
										  end, NpcListQualityLtMax),
			Message1 = instance_packet:encode_refresh_instance_quality_result_s2c(NewFreeTimes, NewItemTimes, NewGold),
			role_op:send_data_to_gate(Message1),
			set_quality(InstanceId, NewNpcListQuality),
			return_refresh_result(InstanceId);
		false ->
			Message = instance_packet:encode_refresh_instance_quality_opt_s2c(?ERROR_LESS_GOLD),
			role_op:send_data_to_gate(Message)
	end.

check_refresh_condition(InstanceId, QualityProto) ->
	FreeTime = get_free_refresh_quality_time(InstanceId),
	if FreeTime > 0 ->
		   use_free_refresh_quality_time(InstanceId, 1),
		   {ok, 1, 1};
	   true ->
		   case item_util:is_has_enough_item_in_package_by_class(?ITEM_TYPE_EXP,1) of
			   true ->
				   item_util:consume_items_by_classid(?ITEM_TYPE_EXP,1),
				   {ok, 2, 1};
			   false ->
				   MoneyCount = instance_quality_db:get_gold(QualityProto),
				   case role_op:check_money(?MONEY_GOLD, MoneyCount) of
					   true ->
					   		role_op:money_change(?MONEY_GOLD, -MoneyCount, refresh_exp_quality),
							{ok, 3, MoneyCount};
					   false ->
						   false
				   end
		   end
	end.

use_free_refresh_quality_time(InstanceId, FreeTime) ->
	InstanceQualityExt = case get(instance_quality_ext) of
							 undefined ->
								 [{InstanceId, FreeTime}];
							 [] ->
								 [{InstanceId, FreeTime}];
							 Ext ->
								 case lists:keyfind(InstanceId, 1, Ext) of
									 false ->
										 [{InstanceId, FreeTime} | Ext];
									 {InstanceId, UseTime} ->
										 lists:keyreplace(InstanceId, 1, Ext, {InstanceId, UseTime + FreeTime})
								 end
						 end,
	put(instance_quality_ext, InstanceQualityExt).

set_quality(InstanceId, QualityInfo) ->
	InstanceQualityInfo = case get(instance_quality_info) of
							  undefined ->
								  [{InstanceId, QualityInfo}];
							  [] ->
								  [{InstanceId, QualityInfo}];
							  Info ->
								  case lists:keyfind(InstanceId, 1, Info) of
									  false ->
										  [{InstanceId, QualityInfo} | Info];
									  {InstanceId, OldQualityInfo} ->
										  AllQualityInfo = lists:foldl(fun({ProtoId, Quality}, TempQualityInfo) ->
															  case lists:keyfind(ProtoId, 1, TempQualityInfo) of
																  false ->
																	  [{ProtoId, Quality} | TempQualityInfo];
																  _ ->
																	  lists:keyreplace(ProtoId, 1, TempQualityInfo, {ProtoId, Quality})
															  end
													  end, OldQualityInfo, QualityInfo),
										  lists:keyreplace(InstanceId, 1, Info, {InstanceId, AllQualityInfo})
								  end
						  end,
	put(instance_quality_info, InstanceQualityInfo).

return_refresh_result(InstanceId) ->
	FreeTime = get_free_refresh_quality_time(InstanceId),
	{AllFreeTime, ProtoList} = case instance_quality_db:get_info(InstanceId) of
		[] -> {0, []};
		ProtoInfo ->
			{instance_quality_db:get_freetime(ProtoInfo),
			 instance_quality_db:get_npclist(ProtoInfo)}
	end,
	Nq = lists:map(fun(ProtoId) ->
						   Quality = get_quality(InstanceId, ProtoId),
						   AddFac = get_addfac(InstanceId, Quality),
						%   {1, ProtoId, Quality, trunc(AddFac / 0.6 * 10000)}
				     #nq{npcproto=ProtoId,expfac=trunc(AddFac / 0.6 * 10000),quality =Quality}
				   end, ProtoList),
	Message = instance_packet:encode_refresh_instance_quality_s2c(InstanceId, FreeTime, AllFreeTime, Nq),
	role_op:send_data_to_gate(Message).

bakup_instance_quality(InstanceId) ->
	QualityInfo = case get(instance_quality_info) of
		undefined -> [];
		[] -> [];
		Info ->
			case lists:keyfind(InstanceId, 1, Info) of
				false -> [];
				{InstanceId, InstanceInfo} ->
					InstanceInfo
			end
	end,
	case get(instance_quality_quality) of
		undefined -> put(instance_quality_quality, [{InstanceId, QualityInfo}]);
		[] -> put(instance_quality_quality, [{InstanceId, QualityInfo}]);
		QualityList ->
			case lists:keyfind(InstanceId, 1, QualityList) of
				false ->
					put(instance_quality_quality, [{InstanceId, QualityInfo} | QualityList]);
				_ ->
					put(instance_quality_quality, lists:keyreplace(InstanceId, 1, QualityList, {InstanceId, QualityInfo}))
			end
	end.

get_real_quality(InstanceId, ProtoId) ->
	case get(instance_quality_quality) of
		undefined -> -1;
		[] -> -1;
		QualityList ->
			case lists:keyfind(InstanceId, 1, QualityList) of
				false -> -1;
				{InstanceId, InstanceInfo} ->
					case lists:keyfind(ProtoId, 1, InstanceInfo) of
						false -> 1;
						{ProtoId, Quality} -> Quality
					end
			end
	end.
							  

	
	
										
										
	
