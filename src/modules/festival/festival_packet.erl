%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-11-14
%% Description: TODO: Add description to festival_packet
-module(festival_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("festival_define.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% API Functions

handle(Message,RolePid)->
	RolePid ! {festival_msg,Message}.


process_proc_message(#festival_init_c2s{festival_id = FestivalId})->
	Mod = festival_db:get_festival_mod_by_id(FestivalId),
	if
		Mod =:= error ->
			Msg = festival_packet:encode_festival_error_s2c(?ERRNO_FESTIVAL_EXPIRED),
			role_op:send_data_to_gate(Msg);
		true->
			Mod:init()
	end;

process_proc_message(#festival_recharge_exchange_c2s{id = Id})->
	festival_recharge:exchange_item(Id).
	
encode_activity_tab_isshow_s2c(LableState)->
	login_pb:encode_activity_tab_isshow_s2c(#activity_tab_isshow_s2c{ts = LableState}).
		
encode_festival_error_s2c(Error)->
	login_pb:encode_festival_error_s2c(#festival_error_s2c{error = Error}).

encode_festival_recharge_s2c(FestivalId,State,StartTime,EndTime,ChargeNum,ExchangeInfo,CAWardLimitTime,GiftInfo,LeftTimeSecond)->
	login_pb:encode_festival_recharge_s2c(#festival_recharge_s2c{festival_id = FestivalId,
			state = State,starttime = StartTime,endtime = EndTime,today_charge_num = ChargeNum,exchange_info = ExchangeInfo,award_limit_time = CAWardLimitTime,gift = GiftInfo,lefttime = LeftTimeSecond}).

encode_festival_recharge_notice_s2c()->
	login_pb:encode_festival_recharge_notice_s2c(#festival_recharge_notice_s2c{}).

encode_festival_recharge_update_s2c(Id,State,TodayChargeNum)->
	login_pb:encode_festival_recharge_update_s2c(#festival_recharge_update_s2c{id =Id,state = State,today_charge_num = TodayChargeNum}).
 

make_charge_info(ExchangeInfo)->
	lists:map(fun({Id,Date,ChargeNum,State})->
					  #charge{id = Id,awarddate = make_timer({Date,{?ZORE_HOUR,?ZORE_MINUTE,?ZORE_SECOND}}), charge_num = ChargeNum,state = State}
			  end,ExchangeInfo).

make_recharge(ExchangeInfo)->
	lists:map(fun({Id,State})->
					  #recharge{id = Id,state = State}
			  end,ExchangeInfo).

make_timer({{Year,Month,Day},{Hour,Minute,Second}})->
	#time_struct{year = Year,month = Month,day = Day,hour = Hour,minute = Minute,second = Second}.

make_tab_state(LableId,TState)->
	if
		TState =:= true->
			#tab_state{id = LableId,state = ?OPEN};
		true->
			#tab_state{id = LableId,state = ?CLOSE}
	end.

open_service_make_recharge(AllPart)->
		lists:map(fun({Id,State})->
					  #tab_state{id = Id,state = State}
			  end,AllPart).
  

make_giftinfo(TGift,NeedCharge)->
	Gift = lists:map(fun({Proto,Count})->
							 #lti{protoid = Proto,item_count = Count}
					 end,TGift),
	#giftinfo{needcharge = NeedCharge,items = Gift}.
	
%%
%% Local Functions
%%

