%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
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
								TimeDiff =< 0 -> %%鏃堕棿鍒颁簡
									%%妫�鏌ヨ儗鍖�
									case package_op:can_added_to_package_template_list(ItemList)  of
										false->
											send_error_to_client(?ERROR_PACKEGE_FULL);
										_->
											{StartDay,_} = calendar:now_to_local_time(StartTime),
											if
												StartDay =:= Today ->	%%褰撳ぉ棰嗗彇濂栧姳
													NextIndex = CurIndex+1;
												true->
													NextIndex = 1
											end,
											CurTimes = get_gift_times(GiftInfo) + 1,			
											NewGiftInfo = GiftInfo#timelimit_gift_info{curindex = NextIndex,gift_times = CurTimes},										
											put(timelimit_gift_info,NewGiftInfo#timelimit_gift_info{status = close}),
											save_to_db(),
											%%鍏堝瓨搴撳啀鍙戦�佸鍔�
											lists:foreach(fun({TemplateId,ItemCount})->	
												role_op:auto_create_and_put(TemplateId,ItemCount,timelimit_gift)
												end,ItemList),
											RoleInfo = get(creature_info),
											case change_next_gift_info(get_class_from_roleinfo(RoleInfo),get_level_from_roleinfo(RoleInfo),NextIndex,Now,true) of  %%姝ゅ闇�瑕佸埛鏂颁竴娆ift
												true->
													nothing;
												_->
													notify_client_gift_over()
											end
									end;
								true->	%%鏃堕棿鏈埌
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
			LastTime = get_starttime(GiftInfo),	%%杩欐寮�濮嬬殑鏃堕棿 鍗充负涓婃缁撴潫鐨勬椂闂�
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
%%鍒濆鍖栭濂栦俊鎭�
%%
init_gift_info(RoleId,Class,Level)->
	case timelimit_gift_db:get_role_info(RoleId) of
	   []-> LastIndex = 0,LastTime={0,0,0},Duration=0,GiftTime=0,LastItem=[];
	   RoleTLGiftInfo-> {_,_,LastIndex,{LastTime,Duration,GiftTime},LastItem,_Ext} = RoleTLGiftInfo
	end,
	%%妫�娴嬫槸鍚︿负浠婂ぉ 
	Now = timer_center:get_correct_now(),
	GiftInfo = #timelimit_gift_info{curindex = LastIndex,starttime = LastTime,duration_time = Duration,itemlist = LastItem,status = close,gift_times = GiftTime},
	put(timelimit_gift_info,GiftInfo),
	{Today,_} = calendar:now_to_local_time(Now),
	{LastDay,_} = calendar:now_to_local_time(LastTime),
	if
		Today =:= LastDay ->		%%浠婂ぉ宸查鍙栬繃涓�閮ㄥ垎
			NextIndex = LastIndex+1,
			BeRefreshGift = false;		%%涓嶉渶瑕佸啀鍒锋柊绀肩墿
		true->
			NextIndex = 1,
			BeRefreshGift = true
	end,
	%%鑾峰彇涓嬩竴娆￠濂栦俊鎭�
	change_next_gift_info(Class,Level,NextIndex,Now,BeRefreshGift).
	
%%
%%涓嬩竴娆￠濂栦俊鎭�
%%鑱屼笟 绛夌骇 涓嬫棰嗗娆℃暟 褰撳墠鏃堕棿 鏄惁瑕佸埛鏂癵ift
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
							%%妫�鏌ユ渶鍚庝竴娆℃椂闂�
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
					%%鍙戦�佺粰瀹㈡埛绔� 棰嗗鍊掕鏃跺紑濮�
					notify_client_gift_info(NextIndex,DurationTime,ItemList),
					true;
				_->
					false
			end	
	end.		

%%
%%姣忓ぉ閲嶇疆棰嗗淇℃伅
%%
reset_gift_info()->
	todo.
%%
%%閫氱煡瀹㈡埛绔� 涓嬩竴娆￠濂�
%%
notify_client_gift_info(NextIndex,Time,ItemList)->
	Message = timelimit_gift_packet:encode_timelimit_gift_info_s2c(NextIndex,Time,ItemList),
	role_op:send_data_to_gate(Message).

%%
%%閫氱煡瀹㈡埛绔濂栧凡缁忕粨鏉�
%%
notify_client_gift_over()->
	Message = timelimit_gift_packet:encode_timelimit_gift_over_s2c(),
	role_op:send_data_to_gate(Message).

%%
%%鍙戦�侀敊璇俊鎭�
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
%%姣忓ぉ鍑屾櫒鍒锋柊	
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
	
			