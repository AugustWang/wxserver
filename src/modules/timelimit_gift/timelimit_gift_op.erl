%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-3-23
%% Description: TODO: Add description to timelimit_gift_op
-module(timelimit_gift_op).
-compile(export_all).
%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("data_struct.hrl").
-include("little_garden.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("role_struct.hrl").

%%
%%
%%
-record(timelimit_gift_info,{curindex,starttime,duration_time,itemlist,status,gift_times}).
%%
%% API Functions
%%

on_playeronline()->
	put(timelimit_gift_info,[]),
%%	put(timelimit_gift_timer,[]),
	RoleInfo = get(creature_info),
	init_gift_info(get(roleid),get_class_from_roleinfo(RoleInfo),get_level_from_roleinfo(RoleInfo)).
	%%restart_gift_timer().

on_playeroffline()->
	save_to_db().

handle_get_timelimit_gift()->
	Now = timer_center:get_correct_now(),
	{Today,_} = calendar:now_to_local_time(Now),
	GiftInfo =  get(timelimit_gift_info),
	case get_status(GiftInfo) of
		open->
			RoleInfo = get(creature_info),
			Level = get_level_from_roleinfo(RoleInfo),
			Class = get_class_from_roleinfo(RoleInfo),
			case timelimit_gift_db:get_info({Level,Class}) of
				[]->
					put(timelimit_gift_info,set_status(GiftInfo,close)),
					nothing;
				Info->
					DropLists = timelimit_gift_db:get_droplist(Info),
					case lists:keyfind(get_curindex(GiftInfo),1,DropLists) of
						false->
							put(timelimit_gift_info,set_status(GiftInfo,close)),
							nothing;
						{_,Time,_}->				
							StartTime = get_starttime(GiftInfo),
							Duration = get_duration_time(GiftInfo),
							CurIndex = get_curindex(GiftInfo),
							ItemList = get_itemlist(GiftInfo),
							TimeDiff = Time - (trunc(timer:now_diff(Now,StartTime)/1000000)+Duration),
							if
								TimeDiff =< 0 -> %%时间到了
									%%检查背包
									case package_op:can_added_to_package_template_list(ItemList)  of
										false->
											send_error_to_client(?ERROR_PACKEGE_FULL);
										_->
											{StartDay,_} = calendar:now_to_local_time(StartTime),
											if
												StartDay =:= Today ->	%%当天领取奖励
													NextIndex = CurIndex+1;
												true->
													NextIndex = 1
											end,
											CurTimes = get_gift_times(GiftInfo) + 1,			
											NewGiftInfo = GiftInfo#timelimit_gift_info{curindex = NextIndex,gift_times = CurTimes},										
											put(timelimit_gift_info,NewGiftInfo#timelimit_gift_info{status = close}),
											save_to_db(),
											%%先存库再发送奖励
											lists:foreach(fun({TemplateId,ItemCount})->	
												role_op:auto_create_and_put(TemplateId,ItemCount,timelimit_gift)
												end,ItemList),
											RoleInfo = get(creature_info),
											case change_next_gift_info(get_class_from_roleinfo(RoleInfo),get_level_from_roleinfo(RoleInfo),NextIndex,Now,true) of  %%此处需要刷新一次gift
												true->
													nothing;
												_->
													notify_client_gift_over()
											end
									end;
								true->	%%时间未到
									notify_client_gift_info(CurIndex,TimeDiff,ItemList)
							end;
						_->
							nothing
					end
				end;
		_->
			nothing
	end.


export_for_copy()->
	get(timelimit_gift_info).

load_by_copy(TimeLimitGift)->
	put(timelimit_gift_info,TimeLimitGift).
	%%put(timelimit_gift_timer,[]),
	%%restart_gift_timer().	 
%%
%% Local Functions
%%
load_from_db()->
	nothing.

save_to_db()->
	RoleId = get(roleid),
	case get(timelimit_gift_info) of
		undefined->
			nothing;
		GiftInfo->
			Status = get_status(GiftInfo),
			CurIndex = get_curindex(GiftInfo),
			LastTime = get_starttime(GiftInfo),	%%这次开始的时间 即为上次结束的时间
			DurationTime = get_duration_time(GiftInfo),
			ItemList = get_itemlist(GiftInfo),
			GiftTime = get_gift_times(GiftInfo),
			case Status of
				open->
					LastIndex = erlang:max(CurIndex - 1,0),
					Now = timer_center:get_correct_now(),
					NewDurationTime = DurationTime +  trunc(timer:now_diff(Now,LastTime)/1000000);
				_->
					LastIndex = CurIndex,
					NewDurationTime = DurationTime
			end,
			timelimit_gift_db:save_role_info(RoleId,LastIndex,LastTime,NewDurationTime,GiftTime,ItemList)
	end.
	
%%
%%初始化领奖信息
%%
init_gift_info(RoleId,Class,Level)->
	case timelimit_gift_db:get_role_info(RoleId) of
	   []-> LastIndex = 0,LastTime={0,0,0},Duration=0,GiftTime=0,LastItem=[];
	   RoleTLGiftInfo-> {_,_,LastIndex,{LastTime,Duration,GiftTime},LastItem,_Ext} = RoleTLGiftInfo
	end,
	%%检测是否为今天 
	Now = timer_center:get_correct_now(),
	GiftInfo = #timelimit_gift_info{curindex = LastIndex,starttime = LastTime,duration_time = Duration,itemlist = LastItem,status = close,gift_times = GiftTime},
	put(timelimit_gift_info,GiftInfo),
	{Today,_} = calendar:now_to_local_time(Now),
	{LastDay,_} = calendar:now_to_local_time(LastTime),
	if
		Today =:= LastDay ->		%%今天已领取过一部分
			NextIndex = LastIndex+1,
			BeRefreshGift = false;		%%不需要再刷新礼物
		true->
			NextIndex = 1,
			BeRefreshGift = true
	end,
	%%获取下一次领奖信息
	change_next_gift_info(Class,Level,NextIndex,Now,BeRefreshGift).
	
%%
%%下一次领奖信息
%%职业 等级 下次领奖次数 当前时间 是否要刷新gift
%%
change_next_gift_info(Class,Level,NextIndex,Now,BeRefreshGift)->
	GiftInfo = get(timelimit_gift_info),
	case timelimit_gift_db:get_info({Level,Class}) of
		[]->
			put(timelimit_gift_info,set_status(GiftInfo,close)),
			false;
		Info->
			DropLists = timelimit_gift_db:get_droplist(Info),
			case lists:keyfind(NextIndex,1,DropLists) of
				false->
					put(timelimit_gift_info,set_status(GiftInfo,close)),
					false;
				{_,Time,DropList}->
					if
						BeRefreshGift->
							Duration = 0,
							DurationTime = Time,
							ItemList = lists:foldl(fun(RuleId,TempList)-> lists:append(drop:apply_rule(RuleId,1),TempList) end,[],DropList);
						true->
							%%检查最后一次时间
							Duration = get_duration_time(GiftInfo),
							TimeDiff = Duration,
							if
								TimeDiff >= Time ->
									DurationTime = 1;
								true->
									DurationTime = Time - TimeDiff
							end,
							ItemList = get_itemlist(GiftInfo)
					end,
					NewGiftInfo = GiftInfo#timelimit_gift_info{curindex = NextIndex,starttime = Now,duration_time = Duration,itemlist = ItemList,status = open},
					put(timelimit_gift_info,NewGiftInfo),
					%%发送给客户端 领奖倒计时开始
					notify_client_gift_info(NextIndex,DurationTime,ItemList),
					true;
				_->
					false
			end	
	end.		

%%
%%每天重置领奖信息
%%
reset_gift_info()->
	todo.
%%
%%通知客户端 下一次领奖
%%
notify_client_gift_info(NextIndex,Time,ItemList)->
	Message = timelimit_gift_packet:encode_timelimit_gift_info_s2c(NextIndex,Time,ItemList),
	role_op:send_data_to_gate(Message).

%%
%%通知客户端领奖已经结束
%%
notify_client_gift_over()->
	Message = timelimit_gift_packet:encode_timelimit_gift_over_s2c(),
	role_op:send_data_to_gate(Message).

%%
%%发送错误信息
%%
send_error_to_client(Errno)->
	Message = timelimit_gift_packet:encode_timelimit_gift_error_s2c(Errno),
	role_op:send_data_to_gate(Message).

get_curindex(GiftInfo)->
	#timelimit_gift_info{curindex = CurIndex} = GiftInfo,
	CurIndex.

set_curindex(GiftInfo,NextIndex)->
	GiftInfo#timelimit_gift_info{curindex = NextIndex}.

get_status(GiftInfo)->
	#timelimit_gift_info{status = Status} = GiftInfo,
	Status.

set_status(GiftInfo,Status)->
	GiftInfo#timelimit_gift_info{status = Status}.

get_starttime(GiftInfo)->
	#timelimit_gift_info{starttime = StartTime} = GiftInfo,
	StartTime.

get_duration_time(GiftInfo)->
	#timelimit_gift_info{duration_time = Duration} = GiftInfo,
	Duration.

get_itemlist(GiftInfo)->
	#timelimit_gift_info{itemlist = ItemList} = GiftInfo,
	ItemList.

get_gift_times(GiftInfo)->
	#timelimit_gift_info{gift_times = GiftTimes} = GiftInfo,
	GiftTimes.
	
set_gift_times(GiftInfo,Times)->
	GiftInfo#timelimit_gift_info{gift_times = Times}.
	
%%
%%每天凌晨刷新	
%%
%%restart_gift_timer()->
%%	Now = timer_center:get_correct_now(),
%%	{_,{H,M,S}} = calendar:now_to_local_time(Now),
%%	TimerDuration_ms = ((23-H)*60*60 + (59-M)*60 + (60-S) + 60)*1000,
%%	case get(timelimit_gift_timer) of
%%		[]->
%%			nothing;
%%		undefined->
%%			nothing;
%%		TimeRef->
%%			erlang:cancel_timer(TimeRef)
%%	end,
%%	NreTimeRef = erlang:send_after(TimerDuration_ms, self(),{timelimit_gift_reset,Now}),
%%	put(timelimit_gift_timer,NreTimeRef).
	
%%reset_today_gift(CurTime)->
%%	GiftInfo =  get(timelimit_gift_info),
%%	Now = timer_center:get_correct_now(),
%%	{Today,_} = calendar:now_to_local_time(Now),
%%	{CurDay,_} = calendar:now_to_local_time(CurTime),
%%	if
%%		Today =/= CurDay ->
%%			case get_status(GiftInfo) of
%%				open->
%%					nothing;
%%				_->
%%					LastTime = get_starttime(GiftInfo),
%%					{LastDay,_} = calendar:now_to_local_time(LastTime),
%%					if
%%						Today =/= LastDay ->
%%							NewIndex = 1,
%%							put(timelimit_gift_info,set_curindex(GiftInfo,NewIndex)),
%%							RoleInfo = get(creature_info),
%%							change_next_gift_info(get_class_from_roleinfo(RoleInfo),
%%											get_level_from_roleinfo(RoleInfo),
%%											NewIndex,Now,true);											
%%						true->
%%							nothing
%%					end
%%			end;
%%		true->
%%			nothing							
%%	end,
%%	restart_gift_timer().
	
reset_gift(Now)->
	GiftInfo =  get(timelimit_gift_info),
	case get_status(GiftInfo) of
		open->
			nothing;
		_->
			LastTime = get_starttime(GiftInfo),
			{LastDay,_} = calendar:now_to_local_time(LastTime),
			{Today,_} = calendar:now_to_local_time(Now),
			if
				Today =/= LastDay ->
					NewIndex = 1,
					put(timelimit_gift_info,set_curindex(GiftInfo,NewIndex)),
					RoleInfo = get(creature_info),
					change_next_gift_info(get_class_from_roleinfo(RoleInfo),
											get_level_from_roleinfo(RoleInfo),
											NewIndex,Now,true);											
				true->
					nothing
			end
	end.
	
			