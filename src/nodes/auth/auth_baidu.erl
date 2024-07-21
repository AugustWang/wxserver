%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-10-14
%% Description: TODO: Add description to auth_baidu
-module(auth_baidu).



%%
%% Include files
%%
-include("login_pb.hrl").
-include("user_auth.hrl").
%%
%% Exported Functions
%%
-export([validate_user/5,validate_user_test/5,make_key/2]).
-export([validate_visitor/5,validate_visitor_test/5]).
%%
%% API Functions
%%

do_genvistor()->
	Id = visitor_generator:gen_newid(),
	{Id,"##visitor##_" ++ integer_to_list(Id)}.

validate_visitor_test(_Time,_AuthResult,_VisitorKey,_CfgTimeOut,NeedPlayerId)->
	{PlayerId,PlayerName} =case NeedPlayerId of
							   true->do_genvistor();
							   _-> {0,[]}
						   end,
	{ok,{PlayerId,PlayerName},false}.

validate_visitor(Time,AuthResult,VisitorKey,CfgTimeOut,NeedPlayerId)->
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	Seconds = MegaSec*1000000 + Sec,
	DiffTim = erlang:abs(Seconds-Time),
	if DiffTim>CfgTimeOut->
		   {error,timeout};
	   true ->
			ValStr = integer_to_list(Time)++ VisitorKey,
			MD5Bin = erlang:md5(ValStr),
			Md5Str = auth_util:binary_to_hexstring(MD5Bin),
			AuthStr = string:to_upper(AuthResult),
			Ret = string:equal(AuthStr, Md5Str),
			if
				Ret->
						{PlayerId,PlayerName} =case NeedPlayerId of
							   true->do_genvistor();
							   _-> {0,[]}
						   end,
					{ok,{PlayerId,PlayerName},false};
				true->
					{error,authentication_failure}
			end
	end.


make_key(UserAuth,SecretKey)->
	#user_auth{userid=UserId,lgtime=LGTime,cm=Adult,sid = ServerId,type = ApiKey } = UserAuth,
	ValStr = SecretKey++"api_key"++ApiKey++"cm_flag"++Adult
			 ++"server_id"++ServerId++"timestamp"++LGTime++"user_id"++UserId,
	ValStr.

time_convert(LGTime)->
	[Date,Time] = string:tokens(LGTime," "),
	[Year,Month,Day] = string:tokens(Date,"-"),
	IntYear = list_to_integer(Year),
	IntMonth = list_to_integer(Month),
	IntDay = list_to_integer(Day),
	[Hour,Minute,Second] = string:tokens(Time,":"),
	IntHour = list_to_integer(Hour),
	IntMinute = list_to_integer(Minute),
	IntSecond = list_to_integer(Second),
	DateTime = {{IntYear,IntMonth,IntDay},{IntHour,IntMinute,IntSecond}},
	Secs = calendar:datetime_to_gregorian_seconds(DateTime),
	Secs.

validate_user(UserAuth,SecretKey,CfgTimeOut,FatigueList,NoFatigueList)->
	#user_auth{username=UserName,userid=UserId,lgtime=LGTime,cm=TmpAdult,flag=AuthResult} = UserAuth,
	Time = time_convert(LGTime),
	if
		TmpAdult =:= "n"->
			Adult = 1;
		true->
			Adult = 0
	end, 
	Seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	DiffTim = erlang:abs(Seconds-Time),
	if DiffTim>CfgTimeOut->
		   {error,timeout};
		true ->
			ValStr = make_key(UserAuth,SecretKey),
			MD5Bin = erlang:md5(ValStr),
			Md5Str = auth_util:binary_to_hexstring(MD5Bin),
			AuthStr = string:to_upper(AuthResult),
			Ret = string:equal(AuthStr, Md5Str),
			if Ret ->
				case check_fatigue(UserName,Adult,FatigueList,NoFatigueList) of
					1->{ok,UserId,true};
					_->{ok,UserId,false}
				end;
			true->
				{error,authentication_failure}
			end
	end.

validate_user_test(UserAuth,_SecretKey,_CfgTimeOut,_FatigueList,_NoFatigueList)->
	#user_auth{cm = Adult,userid = UserId} = UserAuth,
	case Adult of
		1->{ok,UserId,false};
		_->{ok,UserId,false}
	end.

check_fatigue(AccountName,OldAdultFlag,FatigueList,NoFatigueList)->
	case lists:filter(fun({Account,_})->
							  Account=:=AccountName
					  end , FatigueList ) of
		[]-> 
			case lists:filter(fun({Account,_})->
							  Account=:=AccountName
					  end , NoFatigueList ) of
				[]->OldAdultFlag;
				[{_Account,_Level}]-> 1;
				[{_Account,_Level}|_T] -> 1
			end;
		
		[{_Account,_Level}]->0;
		[{_Account,_Level}|_T]->0
	end.
	
	

		