%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-7-4
%% Description: qq ï¿½

-module(auth_qq).

%%
%% Include files
%%
-include("user_auth.hrl").
%%
%% Exported Functions
%%
-export([validate_user/5,validate_user_test/5]).
-export([validate_visitor/5,validate_visitor_test/5]).
-export([make_key/3]).
%%
%% API Functions
%%

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
%%ç”Ÿæˆä¸€ä¸ªéªŒè¯ç 
%%
make_key(UserName,Time,Adult)->
	BinName = case is_binary(UserName) of
						  true-> UserName;
						  _-> list_to_binary(UserName)
			end,
	NameEcode = auth_util:escape_uri(BinName),
	SecretKey = env:get(platformkey, ""),
	ValStr = NameEcode ++ integer_to_list(Time)++ SecretKey ++ integer_to_list(Adult),
			MD5Bin = erlang:md5(ValStr),
			Md5Str = auth_util:binary_to_hexstring(MD5Bin),
	ValStr.

validate_user(UserAuth,SecretKey,CfgTimeOut,FatigueList,NoFatigueList)->
	#user_auth{userid=UserId,openid=OpenId,openkey=OpenKey,appid=AppId,pf=Pf,userip=UserIp,lgtime=Time} = UserAuth,
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	Seconds = MegaSec*1000000 + Sec,
%%	DiffTim = erlang:abs(Seconds-list_to_integer(Time)),
%%	slogger:msg("1111111~n"),
%%	if DiffTim>CfgTimeOut->
%%		   {error,timeout};			
%%		true ->
		    case verify(OpenId,OpenKey,AppId,Pf,UserIp) of
				{ok, {NickName,Gender,Is_yellow_vip,Is_yellow_year_vip,Yellow_vip_level}}->
					{ok,{NickName,Gender,Is_yellow_vip,Is_yellow_year_vip,Yellow_vip_level}};
				D->
					{error,authentication_failure}
%%			end
	end.

verify(OpenId,OpenKey,_,Pf,UserIp)->
	Host = env:get(id_secret_host,[]),
	Port = env:get(id_secret_port,[]),
	AppId = env:get(id_secret_appid,[]),
	Sig = make_sig(AppId,OpenId,OpenKey,Pf,UserIp),
	DataStr = get_data_string(OpenId,OpenKey,AppId,Sig,Pf,UserIp),
	DataLength = erlang:length(DataStr),
	SendUrl = "GET /v3/user/get_info" ++ "?" ++ DataStr ++ " " ++  "HTTP/1.1\r\nHost:" ++ Host
					 ++"\r\n\r\n",
	Code = try
		   Socket = case gen_tcp:connect(Host, Port, [{packet,0},binary,{active, true}]) of
			       {ok,S}->S;
			 	    {error,R1}->exit(R1)
			    end,
			    case gen_tcp:send(Socket,SendUrl) of
				ok ->next;
				{error,R2}->gen_tcp:close(Socket),exit(R2)
			    end,
		    RecvPacket = receive
			  		{tcp,_,P}-> P,
						Result = binary_to_list(P),
						slogger:msg("json:~s~n", [Result]),
						{_,JsonObj} = util:json_decode("{" ++ lists:last(string:tokens(Result,"{"))),
						handle_json(JsonObj);
			  		_->{error,tcp_connect_error}
		  		 end,
		    gen_tcp:close(Socket),
                    RecvPacket 	 		
	       catch
		   R:E->
			io:format("R:~p,E:~p~n",[R,E]), 
			{error,E}
	       end.

make_sig(AppId,OpenId,OpenKey,Pf,UserIp)->
	Urlencode = url_util:urlencode("/v3/user/get_info"),
	Dataencode =  url_util:urlencode("appid="++AppId++"&openid="++OpenId++"&openkey="++OpenKey++"&pf="++Pf),
	BaseString = "GET&"++Urlencode++"&"++Dataencode,
	AppKey = env:get(id_secret_appkey,"8256306d3d287ac69c7632513a75aa54"),
	base64:encode_to_string(crypto:sha_mac(AppKey ++ "&", BaseString)).


handle_json({struct,_} = JsonObj)->
	Ret = util:get_json_member(JsonObj,"ret"),
	case Ret of
		{ok,0}-> 
			case util:get_json_member(JsonObj,"nickname") of
				{ok,NickName}->
					NickName;
				_->
					NickName = []
			end,
			case util:get_json_member(JsonObj,"gender") of
				{ok,Gender}->
					Gender;
				_->
					Gender = []
			end,
			case util:get_json_member(JsonObj,"is_yellow_vip") of
				{ok,Is_yellow_vip}->
					Is_yellow_vip;
				_->
					Is_yellow_vip = []
			end,
			case util:get_json_member(JsonObj,"is_yellow_year_vip") of
				{ok,Is_yellow_year_vip}->
					Is_yellow_year_vip;
				_->
					Is_yellow_year_vip = []
			end,
			case util:get_json_member(JsonObj,"yellow_vip_level") of
				{ok,Yellow_vip_level}->
					Yellow_vip_level;
				_->
					Yellow_vip_level = []
			end,
			{ok,{NickName,Gender,Is_yellow_vip,Is_yellow_year_vip,Yellow_vip_level}};
		R->
			{error,R}
	end.
			 
get_data_string(OpenId,OpenKey,AppId,Sig,Pf,UserIp)->
	"openid="++ OpenId ++ "&openkey=" ++ OpenKey ++ "&appid=" ++ AppId ++ "&sig="
	++ url_util:urlencode(Sig) ++ "&pf=" ++ Pf.

validate_user_test(UserAuth,_SecretKey,_CfgTimeOut,_FatigueList,_NoFatigueList)->
	#user_auth{cm = Adult,userid = UserId} = UserAuth,
	case Adult of
		%%1->{ok,UserId,true};
		1->{ok,{"NAME","ç”·",1,1,1}};
		_->{ok,{"NAME","ç”·",1,1,1}}
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


%%
%% Local Functions
%%
do_genvistor()->
	Id = visitor_generator:gen_newid(),
	{Id,"##visitor##_" ++ integer_to_list(Id)}.
