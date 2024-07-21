%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-7-13
%% Description: TODO: Add description to auth_rising
-module(auth_rising).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("user_auth.hrl").
%%
%% Exported Functions
%%
-export([validate_user/5,validate_user_test/5]).
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

validate_user(UserAuth,SecretKey,CfgTimeOut,FatigueList,NoFatigueList)->
	#user_auth{username = UserName, userid = UserId, lgtime = LGTime, cm = TmpAdult, flag = AuthResult} = UserAuth,
	Adult = list_to_integer(TmpAdult),
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	Seconds = MegaSec*1000000 + Sec,
	DiffTim = erlang:abs(Seconds-list_to_integer(LGTime)),
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
					_->{ok,UserId,true}
				end;
			true->
				{error,authentication_failure}
			end
	end.

%% rising Authentication method
%%return ValStr
%% VarStr = uid=XXX&uname=XXX&lgtime=XXXX&uip=XXX&type=XXXX&sid=XXXX&key=XXXX
%%type 瑞星在合作方类型表示
%%sid  瑞星中 验证成功后进入那个大区 sid
make_key(UserAuth,SecretKey)->
	#user_auth{userid = UserId,username = UserName,lgtime=LGTime,userip = UserIp,type = Type,sid = SId} = UserAuth,
		BinName = case is_binary(UserName) of
						  true-> UserName;
						  _-> list_to_binary(UserName)
					  end,
	NameEcode = auth_util:escape_uri(BinName),
	ValStr = "uid=" ++ UserId 
					++ "&uname=" ++ NameEcode 
					++ "&lgtime=" ++ LGTime
					++ "&uip=" ++ UserIp 
					++ "&type=" ++ Type
					++ "&sid=" ++ SId
					++ "&key=" ++ SecretKey,
	ValStr.

validate_user_test(UserAuth,_SecretKey,_CfgTimeOut,_FatigueList,_NoFatigueList)->
	#user_auth{cm = Adult,userid = UserId} = UserAuth,
	case Adult of
		1->{ok,UserId,true};
		_->{ok,UserId,true}
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
	
	

		