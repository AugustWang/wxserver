%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-11-5
%% Description: TODO: Add description to lottery_op
-module(lottery_op).

%%
%% Include files
%%
-define(LOTTERY_STATUS,'$lottery_status$').
-define(MAGIC_BOX_SIZE,9).
-define(COOLDOWN_SECONDS,1800).
-define(IGNOR_COOLTIME,true).

-include("login_pb.hrl").
-include("error_msg.hrl").
-include("lottery_def.hrl").
-define(LOTTERY_LEVEL_LIST,[14,16,18,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35]).
%%-define(LOCK_LEVEL,lists:max(?LOTTERY_LEVEL_LIST)).
-define(LOCK_LEVEL,100).
%%
%% Exported Functions
%%
-export([on_playeronline/0,
		 on_playerlottery/1,
		 on_playerlevelup/0,
		 on_querylottery/0]).

-include("data_struct.hrl").
-include("role_struct.hrl").


-record(lottery_status,{canlottery=false,last_lottery={0,0,0},leftcount=0,thislotterycount=0}).

%%
%% API Functions
%%

on_playeronline()->
	todo.

on_playeronline_close()->
	RoleInfo = get(creature_info),
	Level = get_level_from_roleinfo(RoleInfo),
	ClassId =  get_class_from_roleinfo(RoleInfo),
	RoleId = get(roleid),
	check_cooldown_disc(RoleId,Level,ClassId),
	FixedCount = get_level_count(Level),
	if FixedCount=<0->
		   ignor;
	   true->
		   LotteryStatus =  get(?LOTTERY_STATUS),
		   #lottery_status{canlottery=Canlottery,last_lottery=LastLotteryTime,leftcount=LeftCount} =LotteryStatus,
		   case Canlottery of
			   true->
				   do_send_leftcount(LeftCount);
			   false->
				   nothing
%% 				   Now = timer_center:get_correct_now(),
%% 				   DurationSeconds = timer:now_diff(Now,LastLotteryTime) div 1000000,
%% 				   CoolDownSeconds = env:get(lottery_cooldown, ?COOLDOWN_SECONDS),
%% 				   LeftSeconds = CoolDownSeconds - DurationSeconds,
%% 				   do_send_cooldown(LeftSeconds)
		   end
	end.

on_playerlottery(_ClickSlot)->
	todo.

on_playerlottery_close(ClickSlot)->
	RoleInfo = get(creature_info),
	Level = get_level_from_roleinfo(RoleInfo),
	ClassId =  get_class_from_roleinfo(RoleInfo),
	RoleId = get(roleid),
	SelfName = get_name_from_roleinfo(RoleInfo),
	do_player_lottery(RoleId,SelfName,Level,ClassId,ClickSlot).

on_playerlevelup()->
	todo.

on_playerlevelup_close()->
	RoleInfo = get(creature_info),
	Level = get_level_from_roleinfo(RoleInfo),
	ClassId =  get_class_from_roleinfo(RoleInfo),
	RoleId = get(roleid),
	%% check level 
%%	case lists:any(fun(I)-> Level =:= I end, ?LOTTERY_LEVEL_LIST) of
%%		true->	clear_cooldowntime(RoleId,Level,ClassId);
%%		_-> nothing
%%	end.
	clear_cooldowntime(RoleId,Level,ClassId).

on_querylottery()->
	todo.

on_querylottery_close()->
	RoleInfo = get(creature_info),
	Level = get_level_from_roleinfo(RoleInfo),
	ClassId =  get_class_from_roleinfo(RoleInfo),
	RoleId = get(roleid),
	check_cooldown_mem(RoleId,Level,ClassId).

do_player_lottery(RoleId,SelfName,Level,ClassId,ClickSlot)->
	FixedCount = get_level_count(Level),
	if FixedCount=<0->
		   ignor;
	   true->
		   LotteryStatus =  get(?LOTTERY_STATUS),
		   #lottery_status{canlottery=Canlottery,last_lottery=LastLotteryTime,leftcount=LeftCount,thislotterycount=ThisLotteryCount} =LotteryStatus,
		   case Canlottery of
			   true->
				  case package_op:get_empty_slot_in_package() of
					  0-> do_send_lottery_failed(?ERROR_PACKEGE_FULL);
					  _->
						  Now = timer_center:get_correct_now(),
						  RuleIds = getrules(Level,ClassId),
						  case drop:apply_lottery_droplist(RuleIds) of
							  []-> slogger:msg("error drop rule for lottery~n");
							  [ThisDrop|_]->
								  if LeftCount>1->
										 {ItemId,ItemCount}=ThisDrop,
										 do_send_get_item(SelfName,ClickSlot,ItemId,ItemCount),
										 NewStatust = LotteryStatus#lottery_status{canlottery=true,leftcount=LeftCount-1,thislotterycount=ThisLotteryCount+1},
										 put(?LOTTERY_STATUS,NewStatust),
										 WriteObj = #role_lottery{roleid=RoleId,last_lottery=LastLotteryTime,leftcount=LeftCount-1,status=open},
										 dal:write_rpc(WriteObj);
									 true->
										 OtherCount = ?MAGIC_BOX_SIZE - ThisLotteryCount - 1,
										 SeqL = lists:seq(1, OtherCount),
										 OtherDrops = lists:map(fun(_)->
																		case drop:apply_lottery_droplist(RuleIds) of
																			[]-> slogger:msg("error drop rule for lottery~n");
																			[Item|_]-> Item
																		end
																end, SeqL),
										 {ItemId,ItemCount}=ThisDrop,
										 do_send_get_item(SelfName,ClickSlot,ItemId,ItemCount),
										 do_send_otherslot_item(OtherDrops),
										 CoolDownSeconds = env:get(lottery_cooldown, ?COOLDOWN_SECONDS),
										 do_send_cooldown(CoolDownSeconds),
										 NewStatust =  LotteryStatus#lottery_status{canlottery=false,last_lottery=Now},
										 put(?LOTTERY_STATUS,NewStatust),
										 WriteObj = #role_lottery{roleid=RoleId,last_lottery=Now,leftcount=0,status=closed},
										 dal:write_rpc(WriteObj)
								  end
						  end
				  end;
			   false->
				   ignor
		   end
	end.


clear_cooldowntime(RoleId,Level,_ClassId)->
	FixedCount = get_level_count(Level),
	if FixedCount=<0->
		   ignor;
	   true->
		   Now = timer_center:get_correct_now(),
		   WriteObj = #role_lottery{roleid=RoleId,last_lottery=Now,leftcount=FixedCount,status=open},
		   dal:write_rpc(WriteObj),
		   NewStatust =  #lottery_status{canlottery=true,last_lottery=Now,leftcount=FixedCount,thislotterycount=0},
		   put(?LOTTERY_STATUS,NewStatust),
		   do_send_leftcount(FixedCount)
	end.
	
check_mem_no_cooltime()->
	noting.

check_mem_cooltime(LastLotteryTime,FixedCount,RoleId,LotteryStatus)->
	Now = timer_center:get_correct_now(),
	DurationSeconds = timer:now_diff(Now,LastLotteryTime) div 1000000,
	CoolDownSeconds = env:get(lottery_cooldown, ?COOLDOWN_SECONDS),
	if DurationSeconds<CoolDownSeconds->
		   do_send_cooldown(CoolDownSeconds-DurationSeconds);
	   true->
		   WriteObj = #role_lottery{roleid=RoleId,last_lottery=LastLotteryTime,leftcount=FixedCount,status=open},
		   dal:write_rpc(WriteObj),
		   NewStatust =  LotteryStatus#lottery_status{canlottery=true,last_lottery=LastLotteryTime,leftcount=FixedCount,thislotterycount=0},
		   put(?LOTTERY_STATUS,NewStatust),
		   do_send_leftcount(FixedCount)
	end.

check_cooldown_mem(RoleId,Level,_ClassId)->
	FixedCount = get_level_count(Level),
	if FixedCount=<0->
		   ignor;
	   true->
		   LotteryStatus =  get(?LOTTERY_STATUS),
		   #lottery_status{canlottery=Canlottery,last_lottery=LastLotteryTime,leftcount=LeftCount} =LotteryStatus,
		   case Canlottery of
			   true->  
				   do_send_leftcount(LeftCount);
			   false->
				   check_mem_no_cooltime()
		   			%check_mem_cooltime(LastLotteryTime,FixedCount,RoleId,LotteryStatus)
		   end
	end.


check_disc_no_cooltime(LastLotteryTime)->
	#lottery_status{canlottery=false,last_lottery=LastLotteryTime}.

check_disc_cooltime(LastLotteryTime,FixedCount)->
	Now = timer_center:get_correct_now(),
	DurationSeconds = timer:now_diff(Now,LastLotteryTime) div 1000000,
	CoolDownSeconds = env:get(lottery_cooldown, ?COOLDOWN_SECONDS),
	if DurationSeconds<CoolDownSeconds->
		   #lottery_status{canlottery=false,last_lottery=LastLotteryTime};
	   true->
		   #lottery_status{canlottery=true,last_lottery=LastLotteryTime,leftcount=FixedCount}
	end.

check_cooldown_disc(RoleId,Level,_ClassId)->
	FixedCount = get_level_count(Level),
	if FixedCount=<0->
		   Status = #lottery_status{}; %%current level no lottery
	   true->
		   case dal:read_rpc(role_lottery, RoleId) of
			   {ok,[RoleLotteryInfo]}-> RoleLotteryInfo;
			   _-> RoleLotteryInfo = {role_lottery,RoleId,{0,0,0},0,closed}
		   end,
		   LastStatus = erlang:element(#role_lottery.status, RoleLotteryInfo),
		   LastLotteryTime = erlang:element(#role_lottery.last_lottery, RoleLotteryInfo),
		   case LastStatus of
			   closed->
				   Status = check_disc_no_cooltime(LastLotteryTime);
			   	   %Status = check_disc_cooltime(LastLotteryTime,FixedCount);
			   open->
				   LeftCount = erlang:element(#role_lottery.leftcount, RoleLotteryInfo),
				   Status = #lottery_status{canlottery=true,last_lottery=LastLotteryTime,leftcount=LeftCount}
		   end
	end,
	put(?LOTTERY_STATUS,Status).

%%
%% Local Functions
%%



getrules(Level,ClassId)->
	TrueClassDrop = lottery_db:get_drop_by_level_and_class(Level, ClassId),
	AllClassDrop = lottery_db:get_drop_by_level_and_class(Level,0),
	TrueClassDrop ++ AllClassDrop.

get_level_count(Level)->
	LockLevel = ?LOCK_LEVEL,
	if Level > LockLevel -> 0;
	   true->
		   lottery_db:get_level_count(Level)
	end.

%%
%% send message to gate
%%
do_send_lottery_failed(Reason)->
	SendPacket = #lottery_clickslot_failed_s2c{reason = Reason},
	SendBin = login_pb:encode_lottery_clickslot_failed_s2c(SendPacket),
	role_op:send_data_to_gate(SendBin).
	


do_send_get_item(SelfName,ClickSlot,ItemId,ItemCount)->
	LoteryItem = #lti{protoid = ItemId,item_count = ItemCount},
	SendPacket = #lottery_clickslot_s2c{lottery_slot = ClickSlot,item = LoteryItem},
	SendBin = login_pb:encode_lottery_clickslot_s2c(SendPacket),
	role_op:send_data_to_gate(SendBin),
	role_op:auto_create_and_put(ItemId, ItemCount, got_lottery),
	NoticMessage = login_pb:encode_lottery_notic_s2c(#lottery_notic_s2c{rolename=SelfName,item=LoteryItem}),
	chat_op:send_binary_message(NoticMessage).
	
do_send_otherslot_item(OtherDrops)->
	case OtherDrops of
		[]->ignor;
		_->
			Items = lists:map(fun({ItemId,ItemCount})-> #lti{protoid = ItemId,item_count = ItemCount} end, OtherDrops),
			SendPacket = #lottery_otherslot_s2c{items=Items},
			SendBin = login_pb:encode_lottery_otherslot_s2c(SendPacket),
			role_op:send_data_to_gate(SendBin)
	end.

do_send_cooldown(LeftSeconds)->
	%%SendPacket = #lottery_lefttime_s2c{leftseconds=LeftSeconds},
	%%SendBin = login_pb:encode_lottery_lefttime_s2c(SendPacket),
	%%role_op:send_data_to_gate(SendBin).
	nothing.

do_send_leftcount(LeftCount)->
	SendPacket = #lottery_leftcount_s2c{leftcount=LeftCount},
	SendBin = login_pb:encode_lottery_leftcount_s2c(SendPacket),
	role_op:send_data_to_gate(SendBin).

