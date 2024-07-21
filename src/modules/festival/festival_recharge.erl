%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-12-9
%% Description: TODO: Add description to festival_recharge
-module(festival_recharge).

%%
%% Include files
%%
-include("festival_define.hrl").
-include("festival_def.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-export([init/0,exchange_item/1,change_recharge_num/2,charge_send_mail/0]).

%%
%% API Functions
%%

init()->
	case festival_op:get_festival_state_by_id(?FESTIVAL_RECHARGE) of 
		?CLOSE->
			Msg = festival_packet:encode_festival_error_s2c(?ERRNO_FESTIVAL_EXPIRED),
			role_op:send_data_to_gate(Msg);
		_OtherState->
%% 			io:format("festival_recharge init~n"),
			FestivalInfo = festival_db:get_festival_control_info_by_id(?FESTIVAL_RECHARGE),
			StartTime = festival_db:get_festival_starttime_by_info(FestivalInfo),
			EndTime = festival_db:get_festival_endtime_by_info(FestivalInfo),
			AWardLimitTime = festival_db:get_festival_award_limit_time_by_info(FestivalInfo),
			CStartTime = festival_packet:make_timer(StartTime),
			CEndTime = festival_packet:make_timer(EndTime),
			CAWardLimitTime  = festival_packet:make_timer(AWardLimitTime),
			NowDateTime = calendar:local_time(),
			{NowDate,_} = NowDateTime, 
			LeftTimeSecond = calendar:datetime_to_gregorian_seconds(EndTime) - calendar:datetime_to_gregorian_seconds(NowDateTime),
			case festival_db:get_role_festival_recharge_data(get(roleid)) of
				[]->
%% 					io:format("festival_db:get_role_festival_recharge_data(get(roleid)) []~n"),
					NewExChangeInfo = init_exchange_info(StartTime),
					TodayChargeNum = ?ZORE_CHARGE,
					NewReChargeInfo = #role_festival_recharge_data{roleid = get(roleid),exchange_info = NewExChangeInfo};
				ReChargeInfo->
%% 					io:format("ReChargeInfo~p~n",[ReChargeInfo]),
					ExChangeInfo = ReChargeInfo#role_festival_recharge_data.exchange_info,
					NewExChangeInfo = update_exchange_info(ExChangeInfo,StartTime),
					case lists:keyfind(NowDate, 2, NewExChangeInfo) of
						false->
							TodayChargeNum = ?ZORE_CHARGE;
						{_Id,_,TodayChargeNum,_}->
							nothing
					end,
					NewReChargeInfo = ReChargeInfo#role_festival_recharge_data{exchange_info = NewExChangeInfo}
			end,
			festival_db:put_role_festival_recharge_data(NewReChargeInfo),
			CExchangeInfo = festival_packet:make_charge_info(NewExChangeInfo),
			GiftInfo = read_gift_info(),
			Msg = festival_packet:encode_festival_recharge_s2c(?FESTIVAL_RECHARGE,?OPEN,CStartTime,CEndTime,TodayChargeNum,CExchangeInfo,CAWardLimitTime,GiftInfo,LeftTimeSecond),
			role_op:send_data_to_gate(Msg)
	end.
	


read_gift_info()->
	ets:foldl(fun({_Id,Term},TmpGiftInfo)->
					  NeedCharge = Term#festival_recharge_gift.needcount,
					  TGift = Term#festival_recharge_gift.gift,
					  Gift = festival_packet:make_giftinfo(TGift,NeedCharge),
					  [Gift|TmpGiftInfo]
			  end, [], ?FESTIVAL_RECHARGE_GIFT_ETS).


init_exchange_info(StartTime)->
	{{FYear,FMonth,FDay},_} = StartTime,
	FSumDay = calendar:date_to_gregorian_days({FYear,FMonth,FDay}),
	{SYear,SMonth,SDay} = calendar:gregorian_days_to_date(FSumDay+1),
	{TYear,TMonth,TDay} = calendar:gregorian_days_to_date(FSumDay+2),
	ActivityDays = [{1,{FYear,FMonth,FDay}},{2,{SYear,SMonth,SDay}},{3,{TYear,TMonth,TDay}}],
	{NowDate,_Time} = calendar:local_time(),
	lists:map(fun({Id,Date})->
					  case timer_util:compare_time(Date,NowDate) of 
						  equal->
							  {Id,Date,?ZORE_CHARGE,?CUROBTAIN};
						  _Other->
							  {Id,Date,?ZORE_CHARGE,?CANNOTOBTAIN}
					  end
			  	 end,ActivityDays).									 	 

check_data_state(ExChangeInfo,StartTime)->
	{FirstDay,_} = StartTime,
	FSumDay = calendar:date_to_gregorian_days(FirstDay),
	SecondDay = calendar:gregorian_days_to_date(FSumDay+1),
	ThirdDay = calendar:gregorian_days_to_date(FSumDay+2),
	lists:any(fun(Day)->
					  case lists:keyfind(Day, 2, ExChangeInfo) of
						  false->
							  false;
						  _->
							  true
					  end
			  end,[FirstDay,SecondDay,ThirdDay]).


update_exchange_info(ExChangeInfo,StartTime)->
	case check_data_state(ExChangeInfo,StartTime) of
		false->
			init_exchange_info(StartTime);
		_->
			{FirstDay,_} = StartTime,
			FSumDay = calendar:date_to_gregorian_days(FirstDay),
			SecondDay = calendar:gregorian_days_to_date(FSumDay+1),
			ThirdDay = calendar:gregorian_days_to_date(FSumDay+2),
			SExChangeInfo = lists:sort(ExChangeInfo),
			{TExChangeInfo,_} = lists:foldl(fun({Id,_Date,ChargeNum,State},{TmpExChangeInfo,TmpDate})->
												[OneDay|ReDate] = TmpDate, 
												{[{Id,OneDay,ChargeNum,State}|TmpExChangeInfo],ReDate}
										end,{[],[FirstDay,SecondDay,ThirdDay]}, SExChangeInfo), 
%% 			io:format("update_exchange_info ~n"),
			{NowDate,_Time} = calendar:local_time(),
			lists:foldr(fun({Id,Date,ChargeNum,State},Tmp1ExChangeInfo)->
%% 								io:format("{Id,Date,ChargeNum,State}:~p~n",[{Id,Date,ChargeNum,State}]),
								case timer_util:compare_time(Date,NowDate) of 
									true->
										if
											State =:= ?CUROBTAIN->
												case check_if_award(ChargeNum) of
													true->
%% 														io:format("check_if_award true~n"),
														[{Id,Date,ChargeNum,?CANOBTAIN}|Tmp1ExChangeInfo];
													false->
%% 														io:format("check_if_award false~n"),
														[{Id,Date,ChargeNum,?CANNOTOBTAIN}|Tmp1ExChangeInfo]
												end;
											true->
												[{Id,Date,ChargeNum,State}|Tmp1ExChangeInfo]
										end;
									equal->
										[{Id,Date,ChargeNum,?CUROBTAIN}|Tmp1ExChangeInfo];
									false->
										[{Id,Date,ChargeNum,?CANNOTOBTAIN}|Tmp1ExChangeInfo]
								end
										end, [], TExChangeInfo)
	end.
	
											 
check_if_award(ChargeNum)->
	GiftInfoList = ets:tab2list(?FESTIVAL_RECHARGE_GIFT_ETS),
	lists:any(fun({_Id,Term})->
					   NeedChargeNum = Term#festival_recharge_gift.needcount,
					   if 
								  NeedChargeNum =< ChargeNum->
									  true;
								  true->
									  false
							  end
			  end, GiftInfoList).


exchange_item(Id)->
	case festival_op:get_festival_state_by_id(?FESTIVAL_RECHARGE) of 
		?CLOSE->
			nothing;
		_OtherState->
			FestivalInfo = festival_db:get_festival_control_info_by_id(?FESTIVAL_RECHARGE),
			StartTime = festival_db:get_festival_starttime_by_info(FestivalInfo),
			ReChargeInfo = festival_db:get_role_festival_recharge_data(get(roleid)),
			TmpExChangeInfo = ReChargeInfo#role_festival_recharge_data.exchange_info,
			ExChangeInfo = update_exchange_info(TmpExChangeInfo,StartTime),
			case lists:keyfind(Id, 1, ExChangeInfo) of
				false->
					nothing;
				{Id,Date,ChargeNum,State}->
				if
					State =:= ?CANOBTAIN->
						GiftItemList = get_gift_itemlist(ChargeNum),
						case package_op:can_added_to_package_template_list(GiftItemList) of 
							true->
								NewExChangeInfo = lists:keyreplace(Id, 1, ExChangeInfo, {Id,Date,ChargeNum,?HASOBTAIN}),
								NewReChargeInfo = ReChargeInfo#role_festival_recharge_data{exchange_info = NewExChangeInfo},
								festival_db:put_role_festival_recharge_data(NewReChargeInfo),
								{NowDate,_}= calendar:local_time(),
								case lists:keyfind(NowDate, 2, NewExChangeInfo) of
									false->
										TodayChargeNum = ?ZORE_CHARGE;
									{_Id,_,TodayChargeNum,_} ->
										nothing
								end,
								Msg = festival_packet:encode_festival_recharge_update_s2c(Id,?HASOBTAIN,TodayChargeNum),
								role_op:send_data_to_gate(Msg),
								lists:foreach(fun({Itemid,ItemCount})->role_op:auto_create_and_put(Itemid,ItemCount,got_festival_charge) end,GiftItemList);
							false->
								Msg = festival_packet:encode_festival_error_s2c(?ERROR_PACKEGE_FULL),
								role_op:send_data_to_gate(Msg)
						end;
					true->
						nothing
				end
			end
	end.
		
get_gift_itemlist(ChargeNum)->
	TGiftInfoList = ets:tab2list(?FESTIVAL_RECHARGE_GIFT_ETS),
	GiftInfoList = lists:sort(fun({_Id1,Term1},{_Id2,Term2})->
									   NeedCount1 = Term1#festival_recharge_gift.needcount,
									   NeedCount2 = Term2#festival_recharge_gift.needcount,
									   if
										   NeedCount1 =< NeedCount2->
												true;
										   true->
												false
									   end
							   end, TGiftInfoList),
	{_State,Gift} = lists:foldr(fun({_Id,Term},{TmpState,TmpGift})->
									if
										TmpState->
											{TmpState,TmpGift};
										true->
											NeedChargeNum = Term#festival_recharge_gift.needcount,
											GiftItem = Term#festival_recharge_gift.gift,
											if
												ChargeNum < NeedChargeNum ->
													{false,TmpGift};
												true->
													{true,GiftItem}
											end
									end 
							end, {false,[]}, GiftInfoList),
	Gift.

										 
									 
change_recharge_num(ChargeNum,RoleId)->
	case festival_op:get_festival_state_by_id(?FESTIVAL_RECHARGE) of 
		?DURING_ACTIVTIY->
			FestivalInfo = festival_db:get_festival_control_info_by_id(?FESTIVAL_RECHARGE),
			StartTime = festival_db:get_festival_starttime_by_info(FestivalInfo),
			{NowDate,_} = calendar:local_time(),
			case festival_db:get_role_festival_recharge_data(RoleId) of
				[]->
					TmpExChangeInfo = init_exchange_info(StartTime);
				ReChargeInfo->
					ExChangeInfo = ReChargeInfo#role_festival_recharge_data.exchange_info,
					TmpExChangeInfo = update_exchange_info(ExChangeInfo,StartTime)
			end,
%% 			io:format("TmpExChangeInfo:~p~n",[TmpExChangeInfo]),
			{Id,NowDate,TmpChargeNum,State} = lists:keyfind(NowDate, 2, TmpExChangeInfo),
			TodayChargeNum = TmpChargeNum+ChargeNum,
			NewExChangeInfo = lists:keyreplace(Id, 1, TmpExChangeInfo, {Id,NowDate,TodayChargeNum,State}),
			NewReChargeInfo = #role_festival_recharge_data{exchange_info = NewExChangeInfo,roleid = RoleId},
			festival_db:put_role_festival_recharge_data(NewReChargeInfo),
			case role_pos_util:where_is_role(RoleId) of
				[]->
					nothing;
				RolePos->
%% 					io:format("update recharge~n"),
					UpdateMsg = festival_packet:encode_festival_recharge_update_s2c(Id,State,TodayChargeNum),
					role_pos_util:send_to_clinet_by_pos(RolePos,UpdateMsg)
			end;
		_OtherState->
			nothing
	end.


charge_send_mail()->
%% 	io:format("charge_send_mail~n"),
	AllRoleData = festival_db:get_all_role_festival_recharge_data(),
	lists:foreach(fun(Term)->
				ExChangeInfo = Term#role_festival_recharge_data.exchange_info,	
				RoleId = Term#role_festival_recharge_data.roleid,
				{NewExChangeInfo,Gift} = lists:foldl(fun({_Id,_Date,ChargeNum,State},{TmpExChangeInfo,TmpGift})->
										   if
											   (State =:= ?CANOBTAIN) or (State =:= ?CUROBTAIN)->
												  Tmp1Gift = get_gift_itemlist(ChargeNum),
												  {[{_Id,_Date,ChargeNum,?HASOBTAIN}|TmpExChangeInfo],Tmp1Gift++TmpGift};
											   true->
												   {[{_Id,_Date,ChargeNum,State}|TmpExChangeInfo],TmpGift}
										   end
								   end,{[],[]}, ExChangeInfo),
				if
					Gift =:= []->
						nothing;
					true->
						NewReChargeInfo = Term#role_festival_recharge_data{exchange_info = NewExChangeInfo},
						festival_db:put_role_festival_recharge_data(NewReChargeInfo),
						send_mail(Gift,RoleId)
				end
			 end,AllRoleData),
	ok.

					 
					 
	
send_mail(Gift,ToRoleId)->
	Title = language:get_string(?MAIL_TITLE),
	Content = language:get_string(?MAIL_CONTENT),
	FromName = language:get_string(?MAIL_FROMNAME),
	lists:map(fun({ProtoId,Count})->
					  case mail_op:gm_send_by_roleid(FromName,ToRoleId,Title,Content,ProtoId,Count,0) of
						  {ok}->
							  nothing;
						  {error,Reason}->
							  slogger:msg("festival_recharge send mail error,Reason:~p~n,ItemProtoId:~p,Count:~p~n",[Reason,ProtoId,Count]);
						  Other->
							  slogger:msg("festival_recharge send mail error,return:~p~n,ItemProtoId:~p,Count:~p~n",[Other,ProtoId,Count])
					  end
			  end,Gift).


				
%%
%% Local Functions
%%

