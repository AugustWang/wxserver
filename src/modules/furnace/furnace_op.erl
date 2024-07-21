%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaowu
%% Created: 2013-4-17
%% Description: 根据客户端提供的数据，进行丹药功能的编写【小五】: Add description to furnace_op
-module(furnace_op).

%%
%% Include files
%%
-include("furnace_def.hrl").
-include("common_define.hrl").
%%
%% Exported Functions
%%
-export([load_from_db/1,pill_time_is_up/2,queue_time_is_up/2,furnace_queue_info/1,create_pill/3,get_furnace_queue_item/2,accelerate_furnace_queue/2,
		 unlock_furnace_queue/3,up_furnace/2,quit_furnace_queue/2,make_queues_message/3,make_and_send_pills_info/2,get_furnace_add_attribute/0]).


-include("role_struct.hrl").

%%
%% API Functions
%%

load_from_db(RoleId)->
	FurnaceInfo = furnace_db:get_furnace_info_by_roleid(RoleId),
	FARAInfo = furnace_db:get_furnace_add_role_attribute_info_by_roleid(RoleId),
	if
		FARAInfo =:= []->
			put(pill_use_info,[]);
		true->
			{_,_,Pill_Use_Info} = FARAInfo,
			put(pill_use_info,Pill_Use_Info),
			make_and_send_pills_info(RoleId,Pill_Use_Info)
	end,
	if 
		FurnaceInfo =:= []->
			put(refineinfo,[]);
		true->
			{MSec,Sec,_}=timer_center:get_correct_now(),
			CurSec=MSec*1000000+Sec,
			{_,_,RefineInfo,Furnace_Level} = FurnaceInfo,
			NewRefineInfo = lists:map(fun({FQueueid, FNum, FStatus, FPillid, FQueue_create_time, FCreate_pill_time})->
											  if
												  FQueue_create_time =/= 0 ->
													  if
														  (CurSec - FQueue_create_time >= ?QUEUE_TIME) ->
															  if
																  FPillid =/= 0->													  
																		  FPillInfo = lists:nth(FPillid,?ALL_PILL_INFO),
																		  {_,_,NeedLevel,{TNum,HNum,XNum,YNum,MNum},ONeedTime,ONeedMoney} = FPillInfo,
																		  lists:foldl(fun({FreeTemplateId,BondTemplateId},Acc)->
																							  BackCount = trunc(((lists:nth(Acc,[TNum,HNum,XNum,YNum,MNum]))*FNum)/2),
																							  role_op:auto_create_and_put(BondTemplateId,BackCount,quit_furnace_queue),
																							  Acc+1
																						end,1,?All_RESOURCCE_TEMPLATEID),
																		  {FQueueid, 0, ?FURNACE_WAIT_OPEN, 0, 0,0};
																  true->
																	  {FQueueid, 0, ?FURNACE_WAIT_OPEN, 0, 0,0}
															  end;
														  true->														  
															  if 
																  FPillid =/= 0 ->
																	  FPillInfo = lists:nth(FPillid,?ALL_PILL_INFO),
																	  {_,_,NeedLevel,{TNum,HNum,XNum,YNum,MNum},ONeedTime,ONeedMoney} = FPillInfo,
																	  HaveGone = CurSec - FCreate_pill_time,
																	  if
																		  (ONeedTime*FNum)>HaveGone ->
																			  Create_pill_remained_time = (ONeedTime*FNum) - HaveGone,
																			  {FQueueid, FNum, FStatus, FPillid, FQueue_create_time, FCreate_pill_time};
																		  true->
																			  Create_pill_remained_time =0,
																			  NewStatus = 3,
																			  {FQueueid, FNum, NewStatus, FPillid, FQueue_create_time,0}
																	  end;
																  true->
																	  {FQueueid, FNum, FStatus, FPillid, FQueue_create_time, FCreate_pill_time}
															  end
													  end;
												  true->
													  if 
														  FPillid =/= 0 ->
															  FPillInfo = lists:nth(FPillid,?ALL_PILL_INFO),
															  {_,_,NeedLevel,{TNum,HNum,XNum,YNum,MNum},ONeedTime,ONeedMoney} = FPillInfo,
															  HaveGone = CurSec - FCreate_pill_time,
															  if
																  (ONeedTime*FNum)>HaveGone ->
																	  Create_pill_remained_time = (ONeedTime*FNum) - HaveGone,
																	  {FQueueid, FNum, FStatus, FPillid, FQueue_create_time, FCreate_pill_time};
																  true->
																	  Create_pill_remained_time =0,
																	  NewStatus = ?PILL_REFINE_FINISH,
																	  {FQueueid, FNum, NewStatus, FPillid, FQueue_create_time,0}
															  end;
														  true->
															  {FQueueid, FNum, FStatus, FPillid, FQueue_create_time, FCreate_pill_time}
													  end
											  end
									  end, RefineInfo),
			furnace_db:save_furnace_info(RoleId,NewRefineInfo,Furnace_Level),
			put(refineinfo,NewRefineInfo)
	end.

pill_time_is_up(RoleId,Queueid)->
	FurnaceInfo = furnace_db:get_furnace_info_by_roleid(RoleId),
	RefineInfo = furnace_db:get_refineinfo(FurnaceInfo),
	Furnace_Level = furnace_db:get_furnace_level(FurnaceInfo),
	{MSec,Sec,_}=timer_center:get_correct_now(),
	CurSec=MSec*1000000+Sec,
	{_, Num, Status,Pillid,Queue_create_time, Create_pill_time} = lists:nth(Queueid,RefineInfo),
	if
		Status =:= ?PILL_REFINING ->
			NewTuple = {Queueid,Num, ?PILL_REFINE_FINISH,Pillid,Queue_create_time, 0},
			NewRefineInfo = lists:keyreplace(Queueid, 1, RefineInfo, NewTuple),
			furnace_db:save_furnace_info(RoleId,NewRefineInfo,Furnace_Level),
			put(refineinfo,NewRefineInfo),
			Queues = make_queues_message(CurSec,NewRefineInfo,Furnace_Level),
			Msg = login_pb:encode_furnace_queue_info_s2c(furnace_packet:encode_furnace_queue_info_s2c(Queues)),
			role_pos_util:send_to_role_clinet(RoleId,Msg);
		true->
			nothing
	end.

queue_time_is_up(RoleId,Queueid)->
	FurnaceInfo = furnace_db:get_furnace_info_by_roleid(RoleId),
	RefineInfo = furnace_db:get_refineinfo(FurnaceInfo),
	Furnace_Level = furnace_db:get_furnace_level(FurnaceInfo),
	{MSec,Sec,_}=timer_center:get_correct_now(),
	CurSec=MSec*1000000+Sec,
	{_, Num, Status,Pillid,Queue_create_time, Create_pill_time} = lists:nth(Queueid,RefineInfo),
	case Status of
		?PILL_REFINE_FINISH ->
			NewTuple = {Queueid,Num, ?PILL_REFINE_FINISH,Pillid,0,0};
		?PILL_REFINING->
			quit_furnace_queue(RoleId,Queueid),
			NewTuple = {Queueid,0, ?FURNACE_WAIT_OPEN,0,0,0};
		_->
			NewTuple = {Queueid,0, ?FURNACE_WAIT_OPEN,0,0,0}
	end,
	NewRefineInfo = lists:keyreplace(Queueid, 1, RefineInfo, NewTuple),
	furnace_db:save_furnace_info(RoleId,NewRefineInfo,Furnace_Level),
	put(refineinfo,NewRefineInfo),
	Queues = make_queues_message(CurSec,NewRefineInfo,Furnace_Level),
	Msg = login_pb:encode_furnace_queue_info_s2c(furnace_packet:encode_furnace_queue_info_s2c(Queues)),
	role_pos_util:send_to_role_clinet(RoleId,Msg).

furnace_queue_info(RoleId)->%%相应丹药队列信息
	RefineInfo = get(refineinfo),
	if
		RefineInfo =:= []->
			Queueid = 1,
			Num = 0,
			Status = 4,
			Pillid = 0,
			Queue_create_time = 0,
			Create_pill_time = 0,
			NewRefineInfo = [{Queueid, Num, Status,Pillid,Queue_create_time, Create_pill_time}],
			Furnace_Level = 1,
			furnace_db:save_furnace_info(RoleId,NewRefineInfo,Furnace_Level),
			put(refineinfo,NewRefineInfo),
			Queues = [furnace_packet:encode_furnace_queue_info_unit(Queueid, Num, Status, Pillid, Queue_create_time, Queue_create_time)];
		true->
			FurnaceInfo = furnace_db:get_furnace_info_by_roleid(RoleId),
			Furnace_Level = furnace_db:get_furnace_level(FurnaceInfo),
			Queues = lists:map(fun({FQueueid, FNum, FStatus, FPillid, FQueue_create_time, FCreate_pill_time})->
									   {MSec,Sec,_}=timer_center:get_correct_now(),
									   if
										   FQueue_create_time =:= 0->
											   Queue_remained_time =0;
										   true->
											   Queue_remained_time = ?QUEUE_TIME - (MSec*1000000+Sec - FQueue_create_time)
									   end,
									   if
										   FPillid =/= 0->											
											   FPillInfo = lists:nth(FPillid,?ALL_PILL_INFO),
											   {_,_,NeedLevel,{TNum,HNum,XNum,YNum,MNum},ONeedTime,ONeedMoney} = FPillInfo,
											   Queueid = FQueueid,
											   Num = FNum,
											   Pillid = FPillid,
											   Create_pill_time = FCreate_pill_time,
											   HaveGone = MSec*1000000+Sec - FCreate_pill_time,
											   if
												   FQueue_create_time =:= 0->
													   Queue_remained_time =0;
												   true->
													   Queue_remained_time = ?QUEUE_TIME - (MSec*1000000+Sec - FQueue_create_time)
											   end,
											   if
												   (ONeedTime*FNum)>HaveGone ->
													   Create_pill_remained_time = (ONeedTime*FNum) - HaveGone,
													   Status = FStatus;
												   true->
													   Create_pill_remained_time =0,
													   Status = ?PILL_REFINE_FINISH,
													   NewTuple = {FQueueid, FNum, ?PILL_REFINE_FINISH,FPillid,FQueue_create_time, 0},
													   FNewRefineInfo = lists:keyreplace(FQueueid, 1, RefineInfo, NewTuple),
													   furnace_db:save_furnace_info(RoleId,FNewRefineInfo,Furnace_Level),
													   put(refineinfo,FNewRefineInfo)
											   end,
											   furnace_packet:encode_furnace_queue_info_unit(Queueid, Num, Status, Pillid, Queue_remained_time, Create_pill_remained_time);
										   true->
											   if
												   ((FQueue_create_time =:= 0)and(FQueueid =:= 1))or (Queue_remained_time=/= 0)->
													   NStatus = ?FURNACE_FREE;
												   true->
													   NStatus = ?FURNACE_WAIT_OPEN
											   end,
											   furnace_packet:encode_furnace_queue_info_unit(FQueueid, 0, NStatus, 0, Queue_remained_time, 0)
									   end
							   	end,RefineInfo)
	end,
	Msg = login_pb:encode_furnace_queue_info_s2c(furnace_packet:encode_furnace_queue_info_s2c(Queues)),
	role_pos_util:send_to_role_clinet(RoleId,Msg),
	LevelMsg = login_pb:encode_furnace_info_s2c(furnace_packet:encode_furnace_info_s2c(Furnace_Level)),
	role_pos_util:send_to_role_clinet(RoleId,LevelMsg).


create_pill(RoleId,WantPillid,WantTimes)->%%开始炼丹
	WantPillInfo = lists:nth(WantPillid,?ALL_PILL_INFO),
	{_,_,NeedLevel,{TNum,HNum,XNum,YNum,MNum},ONeedTime,ONeedMoney} = WantPillInfo,
	RoleInfo = get(creature_info),
	RoleLevel = get_level_from_roleinfo(RoleInfo),
	Costmoney = ONeedMoney*WantTimes,
	if
		RoleLevel >= NeedLevel ->
			[Have_TNum,Have_HNum,Have_XNum,Have_YNum,Have_MNum]= lists:map(fun({FreeTemplateId,BondTemplateId})->
							  													FreeCount = package_op:get_counts_by_template_in_package(FreeTemplateId),
																		   		BondCount = package_op:get_counts_by_template_in_package(BondTemplateId),
																				SumCount = FreeCount+BondCount
																			end,?All_RESOURCCE_TEMPLATEID),
			if
				((Have_TNum)>=(TNum*WantTimes))and((Have_HNum)>=(HNum*WantTimes))and((Have_XNum)>=(XNum*WantTimes))and((Have_YNum)>=(YNum*WantTimes))and((Have_MNum)>=(MNum*WantTimes))->			
					case role_op:check_money(?MONEY_BOUND_SILVER,Costmoney) of
						true->
							case get(refineinfo) of
								[]->
									nothing;
								OldRefineInfo ->
									FurnaceInfo = furnace_db:get_furnace_info_by_roleid(RoleId),
									Furnace_Level = furnace_db:get_furnace_level(FurnaceInfo),
									{MoLingYuCount,Speed} = lists:nth(Furnace_Level,?All_FURNACE_INFO),
									CanRefineList=lists:filter(fun({Queueid, Num, Status, FPillid, Queue_create_time, Pill_Create_time})->
																if
																	Status =:= ?FURNACE_FREE ->
																		true;
																	true->
																		false
																end
															end, OldRefineInfo),
									if
										CanRefineList =/= []->
											role_op:money_change(?MONEY_BOUND_SILVER,-Costmoney,create_pill),
											lists:foldl(fun({FreeTemplateId,BondTemplateId},Acc)->
																DelCount = (lists:nth(Acc,[TNum,HNum,XNum,YNum,MNum]))*WantTimes,
			  													FreeItemIds = items_op:get_items_by_template(FreeTemplateId),
														   		BondItemIds = items_op:get_items_by_template(BondTemplateId),
																SumItemIds = BondItemIds ++ FreeItemIds,
																role_op:consume_items_by_ids_count(DelCount,SumItemIds),
																Acc+1
															end,1,?All_RESOURCCE_TEMPLATEID),
											{Queueid, Num, Status, Pillid, Queue_create_time,Pill_Create_time} = lists:nth(1,CanRefineList),
											NewNum = WantTimes,
											NewNeedTime = trunc(ONeedTime * NewNum * Speed),
											NewStatus = ?PILL_REFINING,
											{MSec,Sec,_}=timer_center:get_correct_now(),
											NewPill_Create_time = trunc((MSec*1000000+Sec) - ((ONeedTime * NewNum)*(1-Speed))),
%% 											NewPill_Create_time = trunc((MSec*1000000+Sec) - ((ONeedTime * NewNum)*(1-Speed)*NewNum)),
											NewTuple = {Queueid, NewNum, NewStatus,WantPillid,Queue_create_time, NewPill_Create_time},
											NewRefineInfo = lists:keyreplace(Queueid, 1, OldRefineInfo, NewTuple),
											furnace_db:save_furnace_info(RoleId,NewRefineInfo,Furnace_Level),
											put(refineinfo,NewRefineInfo),
											erlang:send_after(NewNeedTime*1000,self(),{pill_time_is_up,RoleId,Queueid}),
											Queues = make_queues_message(MSec*1000000+Sec,NewRefineInfo,Furnace_Level),
											Msg = login_pb:encode_furnace_queue_info_s2c(furnace_packet:encode_furnace_queue_info_s2c(Queues)),
											role_pos_util:send_to_role_clinet(RoleId,Msg);
										true->
											ErrorMsg = login_pb:encode_pill_error_s2c(furnace_packet:encode_pill_error_s2c(?NO_FREE_QUEUE)),
											role_pos_util:send_to_role_clinet(RoleId,ErrorMsg)	
									end
							end;
						_->	
							slogger:msg("accelerate_furnace_queue no money ~p ~n",[get(roleid)])
					end;
				true->
					nothing
			end;
		true->
			nothing
	end.	

get_furnace_queue_item(RoleId,Queueid)->%%提取炼丹
	{MSec,Sec,_}=timer_center:get_correct_now(),
	CurSec=MSec*1000000+Sec,
	case get(refineinfo) of
		[]->
			nothing;
		OldRefineInfo ->
			FurnaceInfo = furnace_db:get_furnace_info_by_roleid(RoleId),
			Furnace_Level = furnace_db:get_furnace_level(FurnaceInfo),
			{Queueid, Num, Status, Pillid, Queue_create_time, Create_pill_time} = lists:nth(Queueid,OldRefineInfo),
			ItemProtoId = lists:nth(Pillid,?ALL_PILL_TEMPLATEID),		
			role_op:auto_create_and_put(ItemProtoId,Num,furnace),
			if
				((Queue_create_time =:= 0)and(Queueid =:= 1))or((CurSec - Queue_create_time) < ?QUEUE_TIME)->
					Queue_remained_time = ?QUEUE_TIME - (CurSec - Queue_create_time),
					NewTuple = {Queueid, 0, ?FURNACE_FREE, 0, Queue_create_time, 0},
					NewRefineInfo = lists:keyreplace(Queueid, 1, OldRefineInfo, NewTuple),
					Queues = make_queues_message(CurSec,NewRefineInfo,Furnace_Level);
				true->
					Queue_remained_time = 0,
					NewTuple = {Queueid, 0, ?FURNACE_WAIT_OPEN,0, 0, 0},
					NewRefineInfo = lists:keyreplace(Queueid, 1, OldRefineInfo, NewTuple),
					Queues = make_queues_message(CurSec,NewRefineInfo,Furnace_Level)
			end,
			furnace_db:save_furnace_info(RoleId,NewRefineInfo,Furnace_Level),
			put(refineinfo,NewRefineInfo),
			Msg = login_pb:encode_furnace_queue_info_s2c(furnace_packet:encode_furnace_queue_info_s2c(Queues)),
			role_pos_util:send_to_role_clinet(RoleId,Msg)
	end.
accelerate_furnace_queue(RoleId,Queueid)->%%炼丹加速
	case get(refineinfo) of
		[]->
			nothing;
		OldRefineInfo ->
			FurnaceInfo = furnace_db:get_furnace_info_by_roleid(RoleId),
			Furnace_Level = furnace_db:get_furnace_level(FurnaceInfo),
			{Queueid, Num, Status, Pillid, Queue_Create_time, Pill_Create_time} = lists:nth(Queueid,OldRefineInfo),
			PillInfo = lists:nth(Pillid,?ALL_PILL_INFO),
			{_,_,NeedLevel,{TNum,HNum,XNum,YNum,MNum},ONeedTime,ONeedMoney} = PillInfo,
			{MSec,Sec,_}=timer_center:get_correct_now(),
			CurSec=MSec*1000000+Sec,
			Create_pill_remained_time = (Num*ONeedTime) -(CurSec - Pill_Create_time),
			if
				(Create_pill_remained_time rem 120) =:= 0->
					Costmoney = (Create_pill_remained_time div 120);
				true->
					Costmoney = (Create_pill_remained_time div 120)+1
			end,		
			case role_op:check_money(?MONEY_GOLD,Costmoney) of
				true->
					role_op:money_change(?MONEY_GOLD,-Costmoney,accelerate_furnace_queue),
					NewTuple = {Queueid,Num, ?PILL_REFINE_FINISH,Pillid,Queue_Create_time, 0},
					NewRefineInfo = lists:keyreplace(Queueid, 1, OldRefineInfo, NewTuple),
					furnace_db:save_furnace_info(RoleId,NewRefineInfo,Furnace_Level),
					put(refineinfo,NewRefineInfo),
					Queues = make_queues_message(CurSec,NewRefineInfo,Furnace_Level),
					Msg = login_pb:encode_furnace_queue_info_s2c(furnace_packet:encode_furnace_queue_info_s2c(Queues)),
					role_pos_util:send_to_role_clinet(RoleId,Msg);
				_->	
					slogger:msg("accelerate_furnace_queue no money ~p ~n",[get(roleid)])
			end
	end.

quit_furnace_queue(RoleId,Queueid)->%%终止炼丹
	{MSec,Sec,_}=timer_center:get_correct_now(),
	CurSec=MSec*1000000+Sec,
	case get(refineinfo) of
		[]->
			nothing;
		OldRefineInfo ->
			FurnaceInfo = furnace_db:get_furnace_info_by_roleid(RoleId),
			Furnace_Level = furnace_db:get_furnace_level(FurnaceInfo),
			{Queueid, Num, Status, Pillid, Queue_Create_time, Pill_Create_time} = lists:nth(Queueid,OldRefineInfo),
			PillInfo = lists:nth(Pillid,?ALL_PILL_INFO),
			{_,_,NeedLevel,{TNum,HNum,XNum,YNum,MNum},ONeedTime,ONeedMoney} = PillInfo,
			lists:foldl(fun({FreeTemplateId,BondTemplateId},Acc)->
								BackCount = trunc(((lists:nth(Acc,[TNum,HNum,XNum,YNum,MNum]))*Num)/2),
								role_op:auto_create_and_put(BondTemplateId,BackCount,quit_furnace_queue),
								Acc+1
							end,1,?All_RESOURCCE_TEMPLATEID),
			NewTuple = {Queueid,0, ?FURNACE_FREE,0,Queue_Create_time, 0},
			NewRefineInfo = lists:keyreplace(Queueid, 1, OldRefineInfo, NewTuple),
			furnace_db:save_furnace_info(RoleId,NewRefineInfo,Furnace_Level),
			put(refineinfo,NewRefineInfo),
			Queues = make_queues_message(CurSec,NewRefineInfo,Furnace_Level),
			Msg = login_pb:encode_furnace_queue_info_s2c(furnace_packet:encode_furnace_queue_info_s2c(Queues)),
			role_pos_util:send_to_role_clinet(RoleId,Msg)
	end.

unlock_furnace_queue(RoleId,Unlock_type,Queueid)->%%开启炼炉
	FurnaceInfo = furnace_db:get_furnace_info_by_roleid(RoleId),
	{MSec,Sec,_}=timer_center:get_correct_now(),
	CurSec=MSec*1000000+Sec,
	if
		Queueid =:= 3->
			YaoLinShiCount = 3;	
		true->
			YaoLinShiCount = 1
	end,
	if
		FurnaceInfo =/= []->
			Furnace_Level = furnace_db:get_furnace_level(FurnaceInfo),
			RefineInfo = furnace_db:get_refineinfo(FurnaceInfo),
			if
				Unlock_type =:= 1->
					FreeItemIds = items_op:get_items_by_template(13200040),
					BondItemIds = items_op:get_items_by_template(13200041),
					SumItemIds = BondItemIds ++ FreeItemIds,
					if
						SumItemIds >= YaoLinShiCount ->
							role_op:consume_items_by_ids_count(YaoLinShiCount,SumItemIds),
							case lists:keyfind(Queueid, 1, RefineInfo) of
								false->
									NewRefineInfo = lists:keysort(1, (RefineInfo++[{Queueid,0,?FURNACE_FREE,0,CurSec,0}]));
								_->
									NewRefineInfo = lists:keyreplace(Queueid, 1, RefineInfo, {Queueid,0,?FURNACE_FREE,0,CurSec,0})
							end,
							furnace_db:save_furnace_info(RoleId,NewRefineInfo,Furnace_Level),
							put(refineinfo,NewRefineInfo),
							erlang:send_after(?QUEUE_TIME*1000,self(),{queue_time_is_up,RoleId,Queueid}),
							Queues = make_queues_message(CurSec,NewRefineInfo,Furnace_Level),
							Msg = login_pb:encode_furnace_queue_info_s2c(furnace_packet:encode_furnace_queue_info_s2c(Queues)),
							role_pos_util:send_to_role_clinet(RoleId,Msg);
						true->
							ErrorMsg = login_pb:encode_pill_error_s2c(furnace_packet:encode_pill_error_s2c(?PROP_NOT_ENOUGH_TO_OPEN_QUEUE)),
							role_pos_util:send_to_role_clinet(RoleId,ErrorMsg)
					end;
				true->
					NeedGold = YaoLinShiCount*98,
					case role_op:check_money(?MONEY_GOLD,NeedGold) of
						true->
							role_op:money_change(?MONEY_GOLD,-NeedGold,up_furnace),
							case lists:keyfind(Queueid, 1, RefineInfo) of
								false->
									MNewRefineInfo = lists:keysort(1, (RefineInfo++[{Queueid,0,?FURNACE_FREE,0,CurSec,0}]));
								_->
									MNewRefineInfo = lists:keyreplace(Queueid, 1, RefineInfo, {Queueid,0,?FURNACE_FREE,0,CurSec,0})
							end,
							furnace_db:save_furnace_info(RoleId,MNewRefineInfo,Furnace_Level),
							put(refineinfo,MNewRefineInfo),
							erlang:send_after(?QUEUE_TIME*1000,self(),{queue_time_is_up,RoleId,Queueid}),
							Queues = make_queues_message(CurSec,MNewRefineInfo,Furnace_Level),
							Msg = login_pb:encode_furnace_queue_info_s2c(furnace_packet:encode_furnace_queue_info_s2c(Queues)),
							role_pos_util:send_to_role_clinet(RoleId,Msg);
						_->	
							slogger:msg("accelerate_furnace_queue no money ~p ~n",[get(roleid)])
					end
			end;
		true->
			nothing
	end.		
			

up_furnace(RoleId,Auto_buy)->%%炼炉升级
	FurnaceInfo = furnace_db:get_furnace_info_by_roleid(RoleId),
	if
		FurnaceInfo =/= []->
			Furnace_Level = furnace_db:get_furnace_level(FurnaceInfo),
			{MoLingYuCount,Speed} = lists:nth(Furnace_Level,?All_FURNACE_INFO),		
			FreeMoLingYuCount = package_op:get_counts_by_template_in_package(13200050),
			BondMoLingYuCount = package_op:get_counts_by_template_in_package(13200051),
			SumMoLingYuCount = FreeMoLingYuCount+BondMoLingYuCount,
			FreeItemIds = items_op:get_items_by_template(13200050),
			BondItemIds = items_op:get_items_by_template(13200051),
			SumItemIds = BondItemIds ++ FreeItemIds,
			if
				SumMoLingYuCount >= MoLingYuCount ->				
					role_op:consume_items_by_ids_count(MoLingYuCount,SumItemIds),
					RefineInfo = furnace_db:get_refineinfo(FurnaceInfo),
					furnace_db:save_furnace_info(RoleId,RefineInfo,Furnace_Level+1),
					Msg = login_pb:encode_furnace_info_s2c(furnace_packet:encode_furnace_info_s2c(Furnace_Level+1)),
					role_pos_util:send_to_role_clinet(RoleId,Msg);
				true->
					if
						Auto_buy =:= 1->
							WillBuyCount = MoLingYuCount - SumMoLingYuCount,
							NeedGold = WillBuyCount*20,
							case role_op:check_money(?MONEY_GOLD,NeedGold) of
								true->
									role_op:consume_items_by_ids_count(WillBuyCount,SumItemIds),
									role_op:money_change(?MONEY_GOLD,-NeedGold,up_furnace),
									RefineInfo = furnace_db:get_refineinfo(FurnaceInfo),
									furnace_db:save_furnace_info(RoleId,RefineInfo,Furnace_Level+1),
									Msg = login_pb:encode_furnace_info_s2c(furnace_packet:encode_furnace_info_s2c(Furnace_Level+1)),
									role_pos_util:send_to_role_clinet(RoleId,Msg);
								_->	
									slogger:msg("accelerate_furnace_queue no money ~p ~n",[get(roleid)])
							end;
						true->
							nothing
					end
			end;
		true->
			nothing
	end.
make_queues_message(Now,RefineInfo,Furnace_Level)->
	lists:map(fun({Queueid, Num, Status, Pillid, Queue_create_time, Pill_Create_time})->
					 	if
							(Queue_create_time =:= 0)->
								Queue_remained_time = 0;
							true->									
								Queue_remained_time = ?QUEUE_TIME - (Now - Queue_create_time)
						end,
					  	case Status of
							?PILL_REFINING->							
								{_,_,NeedLevel,{TNum,HNum,XNum,YNum,MNum},ONeedTime,ONeedMoney} = lists:nth(Pillid,?ALL_PILL_INFO),
								Pill_remained_time = (ONeedTime*Num) - (Now - Pill_Create_time);
							_->
	 							Pill_remained_time = 0
						end,
						furnace_packet:encode_furnace_queue_info_unit(Queueid, Num, Status, Pillid,Queue_remained_time,Pill_remained_time)
				end,RefineInfo).

make_and_send_pills_info(RoleId,Pill_Use_Info)->
	Pills = lists:map(fun({Pillid,UseNum,MaxNum,Value})->
							  if
								  Value =:= hpmax->
									  NewUseNum = UseNum*5;
								  true->
									  NewUseNum = UseNum
							  end,
							  furnace_packet:encode_pill(NewUseNum,Pillid)
					  end, Pill_Use_Info),
	Msg = login_pb:encode_pill_info_s2c(furnace_packet:encode_pill_info_s2c(Pills)),
	role_pos_util:send_to_role_clinet(RoleId,Msg).

get_furnace_add_attribute()->%%计算人物战力时应加入
	case get(pill_use_info) of
		[]->
			[];
		Pill_Use_Info->
			AddList = lists:map(fun({PillId,UseNum,UseMaxNum,Vlue})->
										if
											Vlue =:= hpmax ->
												{hpmax,UseNum*5};
											true->
												{Vlue,UseNum}
										end
								end, Pill_Use_Info)
	end.
	