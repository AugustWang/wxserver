%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-4-13
%% Description: TODO: Add description to guild_log
-module(guild_log).
%%
%% Include files
%%
-include("common_define.hrl").
-include("guild_define.hrl").
-include("string_define.hrl").
%%
%% Exported Functions
%%
-export([format_log/2,get_posting_string/1]).

%%
%% API Functions
%%

%%
%%鎴愬憳绠＄悊
%%error | {id,strlist}
%%
format_log(?GUILD_LOG_MEMBER_MANAGER,Info)->
	case Info of
		{promotion,LeaderName,LeaderPosting,MemberName,MemberPosting}->		%%鍗囪亴
			{1,[
				"銆�" ++ get_posting_string(LeaderPosting) ++ "銆�" ++ check_binary(LeaderName),
				check_binary(MemberName) ++ language:get_string(?STR_GUILD_PROMOTION),	
				get_posting_string(MemberPosting)
			]};
		{demotion,LeaderName,LeaderPosting,MemberName,MemberPosting}->		%%闄嶈亴
			{1,[
				"銆�" ++ get_posting_string(LeaderPosting) ++ "銆�" ++ check_binary(LeaderName),
				check_binary(MemberName) ++ language:get_string(?STR_GUILD_DEMOTION),
				get_posting_string(MemberPosting)
			]};
		{addmember,MemberName}->							%%鍔犲叆
			{2,[
				check_binary(MemberName) ++ language:get_string(?STR_GUILD_JOIN)
			]};
		{leavemember,MemberName,MemberPosting,?GUILD_DESTROY_BEKICKED}->							%%琚涪
			{2,[
				check_binary(MemberName) ++ language:get_string(?STR_GUILD_BEKICKED)
			]};
		{leavemember,MemberName,MemberPosting,_}->							%%绂诲紑
			{2,[
				check_binary(MemberName) ++ language:get_string(?STR_GUILD_LEAVE)
			]};
		{leavemember,MemberName,MemberPosting}->							%%绂诲紑
			{2,[
				check_binary(MemberName) ++ language:get_string(?STR_GUILD_LEAVE)
			]};
		_->
			slogger:msg("add unknown log ~p ~p\n",[?GUILD_LOG_MEMBER_MANAGER,Info]),
			error
	end;

%%
%%鍗囩骇
%%
format_log(?GUILD_LOG_UPGRADE,Info)->
	case Info of
		{Facilityid,Level}->		%%
			{3,[
				get_facility_string(Facilityid),
				erlang:integer_to_list(Level)
			]};
		_->
			slogger:msg("add unknown log ~p ~p\n",[?GUILD_LOG_UPGRADE,Info]),
			error
	end;

%%
%%璋冧环
%%	
format_log(?GUILD_LOG_MODIFY_PRICES,Info)->
	%%io:format("format_log ~p ~n",[Info]),
	case Info of
		{LeaderName,LeaderPosting,ItemName,OldPrice,NewPrice}->
			{4,[
				"銆�" ++ get_posting_string(LeaderPosting) ++ "銆�" ++ check_binary(LeaderName),
				check_binary(ItemName),
				format_money_str(OldPrice),
				format_money_str(NewPrice)
			]};
		_->
			slogger:msg("add unknown log ~p ~p\n",[?GUILD_LOG_MODIFY_PRICES,Info]),
			error
	end;

%%
%%鎹愮尞
%%
format_log(?GUILD_LOG_CONTRIBUTION,Info)->
	case Info of
		{money,MemberName,MemberPosting,Money}->
			{5,[
				"銆�" ++ get_posting_string(MemberPosting) ++ "銆�" ++ check_binary(MemberName),
				format_money_str(Money)
			]};
		{item,MemberName,MemberPosting,Number,ItemName,Facilityid,Time}->
			{6,[
				"銆�" ++ get_posting_string(MemberPosting) ++ "銆�" ++ check_binary(MemberName),
				erlang:integer_to_list(Number),
				%%check_binary(ItemName),
				get_facility_string(Facilityid),
				format_time_str(Time)
			]};
		_->
			slogger:msg("add unknown log ~p ~p\n",[?GUILD_LOG_CONTRIBUTION,Info]),
			error
	end;

%%
%%璐拱淇℃伅
%%
format_log(?GUILD_LOG_MALL,Info)->
	case Info of
		{shop,MemberName,MemberPosting,Money,ItemName}->
			{7,[
				"銆�" ++ get_posting_string(MemberPosting) ++ "銆�" ++ check_binary(MemberName),
				erlang:integer_to_list(Money),		%%鍏冨疂
				check_binary(ItemName)
			]};
		{treasure,MemberName,MemberPosting,Money,ItemName,Tax}->
			{8,[
				"銆�" ++ get_posting_string(MemberPosting) ++ "銆�" ++ check_binary(MemberName),
				format_money_str(Money),
				check_binary(ItemName),
				format_money_str(Tax)
			]};
		_->
			slogger:msg("add unknown log ~p ~p\n",[?GUILD_LOG_MALL,Info]),
			error
	end;

%%甯細浠撳簱鏃ュ織
format_log(?GUILD_LOG_PACKAGE,Info)->
	case Info of
		{RoleName,Operate,ItemId,DateTime,Count}->
			{9,Info};
		_->
			error
	end;
format_log(?GUILD_LOG_QUEST,Info)->
	error.
	

%%
%% Local Functions
%%

get_posting_string(Posting)->
	case Posting of
		?GUILD_POSE_LEADER->
			%%"甯富";
			language:get_string(?STR_GUILD_LEADER);
		?GUILD_POSE_VICE_LEADER->
			%%"鍓府涓�";
			language:get_string(?STR_GUILD_VICE_LEADER);									
		?GUILD_POSE_MASTER->
			%%"闀胯��";							
			language:get_string(?STR_GUILD_MASTER);
		?GUILD_POSE_MEMBER->
			%%"甯紬";
			language:get_string(?STR_GUILD_MEMBER);							
		?GUILD_POSE_PREMEMBER->	
			%%"甯棽";
			language:get_string(?STR_GUILD_PREMEMBER);
		_->
			nothing						
	end.

get_facility_string(FacilityId)->
	case FacilityId of
		?GUILD_FACILITY->									%%甯細
			%%"甯細";
			language:get_string(?STR_GUILD_FACILITY);
		?GUILD_FACILITY_TREASURE->							%%鐧惧疂绠�
			%%"鐧惧疂闃�";
			language:get_string(?STR_GUILD_FACILITY_TREASURE);
		?GUILD_FACILITY_SHOP->								%%甯細鍟嗗煄
			%%"甯細鍟嗗煄";
			language:get_string(?STR_GUILD_FACILITY_SHOP);
		?GUILD_FACILITY_SMITH->
			language:get_string(?STR_GUILD_FACILITY_SMITH);
		_->
			nothing
	end.

format_money_str(Money)->
	case Money of
		{?MONEY_SILVER,0}->
			"0"++language:get_string(?STR_BOUNDMONEY);
		{?MONEY_SILVER,MoneyCount}->
			%%Copper = MoneyCount rem 100,
			%%Silver = trunc((MoneyCount rem (100*100))/100),
			%%Gold = trunc(MoneyCount /(100*100)),
			%%if
			%%	Gold > 0 ->
			%%		GoldStr = integer_to_list(Gold) ++ language:get_string(?STR_SILVER_10000);
			%%	true->
			%%		GoldStr = ""
			%%end,
			%%if
			%%	Silver > 0 ->
			%%		SilverStr = integer_to_list(Silver) ++ language:get_string(?STR_SILVER_100);
			%%	MoneyCount >= 10000 ->
			%%		SilverStr = "0" ++ language:get_string(?STR_SILVER_100);
			%%	true->
			%%		SilverStr = ""
			%%end,
			%%if
			%%	Copper > 0 ->
			%%		CopperStr = integer_to_list(Copper) ++ language:get_string(?STR_SILVER_1);
			%%	MoneyCount >= 100 ->
			%%		CopperStr = "0"++language:get_string(?STR_SILVER_1);
			%%	true->
			%%		CopperStr = ""
			%%end,		 
			%%GoldStr ++ SilverStr ++ CopperStr;
			integer_to_list(MoneyCount) ++ language:get_string(?STR_MONEY);
		{?MONEY_GOLD,SuperGold}->
			integer_to_list(SuperGold) ++ language:get_string(?STR_GOLD);
		_->
			""
	end.

format_time_str(0)->
	"0"++language:get_string(?STR_SECOND);

format_time_str(Time_s)->
	Sec = Time_s rem 60,
	Min = trunc((Time_s rem (60*60))/60),
	Hour = trunc((Time_s rem (24*60*60))/(60*60)),
	Day = trunc(Time_s /(24*60*60)),
	if
		Day > 0 ->
			DayStr = integer_to_list(Day) ++ language:get_string(?STR_ONEDAY);
		true->
			DayStr = ""
	end,
	if
		Hour > 0 ->
			HourStr = integer_to_list(Hour) ++ language:get_string(?STR_ONEHOUR);
		Sec >= 24*60*60->
			HourStr = "0" ++ language:get_string(?STR_ONEHOUR);
		true->
			HourStr = ""
	end,
	if
		Min > 0 ->
			MinStr = integer_to_list(Min) ++ language:get_string(?STR_MINUTER);
		Sec >= 60*60->
			MinStr = "0" ++ language:get_string(?STR_MINUTER);
		true->
			MinStr = ""
	end,
	if
		Sec > 0 ->
			SecStr = integer_to_list(Sec) ++ language:get_string(?STR_SECOND);
		Sec >= 60->
			SecStr = "0" ++ language:get_string(?STR_SECOND);
		true->
			SecStr = ""
	end,

	DayStr ++ HourStr ++ MinStr ++ SecStr.
	

check_binary(String) when is_binary(String)->
	binary_to_list(String);

check_binary(String) when is_list(String)->
	String;

check_binary(String)->
	"".

	
	