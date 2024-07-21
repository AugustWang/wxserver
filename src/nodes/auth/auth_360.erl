%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------

-module(auth_360).

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
%%
%%  md5("qid=".$qid."&time=".$time."&server_id=".$server_id.$key)
%%
validate_user(UserAuth,SecretKey,CfgTimeOut,FatigueList,NoFatigueList)->
	#user_auth{username = UserName, userid = UserId, lgtime = Time, cm = TmpAdult, sid = SId, flag = AuthResult} = UserAuth,
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	Adult = list_to_integer(TmpAdult),
	Seconds = MegaSec*1000000 + Sec,
	DiffTim = erlang:abs(Seconds-list_to_integer(Time)),
	if DiffTim>CfgTimeOut->
		   {error,timeout};
		true ->
			ValStr = "qid="++UserId++"&time="++Time++"&server_id="++SId++SecretKey,
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
	
	

		