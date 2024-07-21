%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: ting.zhang 
%% Created: 2012-8-22
%% Description: TODO: Add description to qq_op
-module(qq_gold_op).

%%
%% Include files
%%
-compile(export_all).
%% Exported Functions
%%
-include("error_msg.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("string_define.hrl").
-include("login_pb.hrl").
-define(HTTP_CONNECT_TIMEOUTS,5000).

do_qq_pay(Amt,PayItem)->
	AppId = env:get(id_secret_appid,[]),
	OpenId = get(openid),
	OpenKey = get(openkey),
	Pf = get(pf),
	AppKey = env:get(id_secret_appkey, ""),
	PfKey = get(pfkey),
	UserIp = [],
	QQ_pre_pay =  qq_pre_pay(Amt,OpenId,OpenKey,PayItem,PfKey,UserIp) ,
	
   case QQ_pre_pay of
      {ok,qq_data_ok,{Billno,Balance}} ->
		      QQ_confirm_pay=qq_confirm_pay(Amt,Billno,OpenId,OpenKey,PfKey,UserIp),
			  case QQ_confirm_pay of
			      {ok,qq_data_ok,_} ->
			          {ok,Balance};
			       _->
			          error
			  end;
       _->
         error 
   end.
	

%%创建get格式url，参考RFC_1738
create_get_url(Url,ParamsStr,Host)->
	ParamsStr1=
	case  string:sub_string(ParamsStr, 1,1) of
		"?"->	ParamsStr;
		_ -> "?"++ParamsStr
	end,		
	%%slogger:msg("qq_gold_op:create_get_url  get:~p~n", ["GET "++Url++" HTTP/1.1\r\nHost:" ++ Host ++"\r\n\r\n"]),	
	"GET "++Url++ParamsStr1++" HTTP/1.1\r\nHost:" ++ Host ++"\r\n\r\n".

%%创建get格式参数串，并urlencode，参考RFC_1738
create_url_params(Url,Amt,Billno,AppId,OpenId,OpenKey,PayItem,Pf,PfKey,UserIp)->
	 if   Pf=:=undefined orelse  Pf=:=[] ->
		 Pf1 ="&pf="++get(pf);
     true->
		 Pf1 =  "&pf="++Pf
	 end,  
	 
	 ZoneId = "&zoneid=" ++ integer_to_list(  env:get(serverid, 1) ),
	 
    PayItemParam = 
    if   PayItem=:=undefined orelse  PayItem=:=[] ->
		  [];
     true->
		 "&payitem="++url_util:urlencode(PayItem)
	 end,  
	 
    UserIpParam = 
    if   UserIp=:=undefined orelse  UserIp=:=[] ->
		  [];
     true->
		 "&userip="++url_util:urlencode(UserIp)
	 end, 
	
	 BillnoParam = 
    if   Billno=:=undefined orelse  Billno=:=[] ->
		  [];
    true->
		 "&billno="++url_util:urlencode(Billno)
	 end, 

	ParamsStr ="amt="++integer_to_list(Amt)++"&appid="++AppId++BillnoParam++"&openid="++OpenId
		 ++"&openkey="++OpenKey++PayItemParam++Pf1++"&pfkey="++PfKey
		 ++"&ts="++integer_to_list(timer_util:current_seconds())++UserIpParam++ZoneId,
	
	 Sig = make_sig(Url,url_util:urlencode(ParamsStr)),
	 ParamsStr1 = ParamsStr++"&sig="++url_util:urlencode(Sig).

make_sig(UrlPath, ParamsStr)->
	Urlencode = url_util:urlencode(UrlPath),
	BaseString = "GET&"++Urlencode++"&"++ParamsStr,
	AppKey = env:get(id_secret_appkey,"8256306d3d287ac69c7632513a75aa54"),
	base64:encode_to_string(crypto:sha_mac(AppKey ++ "&", BaseString)).

%%预扣游戏币请求接口
qq_pre_pay(Amt,OpenId,OpenKey,PayItem,PfKey,UserIp) ->
	Host = env:get(id_secret_host,[]),
	Port = env:get(id_secret_port,[]),
	AppId = env:get(id_secret_appid,[]), 
	Url = "/v3/pay/pre_pay",
	DataStr = create_url_params(Url,Amt,[],AppId,OpenId,OpenKey,PayItem,[],PfKey,UserIp),

	SendUrl = create_get_url(Url,DataStr,Host),
	Code = try
		   Socket = case gen_tcp:connect(Host, Port, [{packet,0},binary,{active, true}],?HTTP_CONNECT_TIMEOUTS) of
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
						{_,JsonObj} = util:json_decode("{" ++ lists:last(string:tokens(Result,"{"))),
                     Ret = util:get_json_member(JsonObj,"ret"),
						case Ret of
								{ok,0}-> 
									case util:get_json_member(JsonObj,"billno") of
										{ok,Billno}->
											Billno;
										_->
											Billno = []
									end,
									case util:get_json_member(JsonObj,"balance") of
										{ok,Balance}->
											Balance;
										_->
											Balance = -1
									end,
									{ok,qq_data_ok,{Billno,Balance}};
								{ok,ErrNo}->
									case util:get_json_member(JsonObj,"msg") of
										{ok,Msg}->
											Msg;
										_->
											Msg = []
									end,
									{error,qq_data_error,{ErrNo,Msg}};
						             
						        _->{error,qq_return_error,nothing}
                      end;
			  		_->{error,tcp,tcp_connect_error}
		  		 end,
		    gen_tcp:close(Socket) ,RecvPacket	 	 		
	       catch
		      R:E->
			    slogger:msg("R:~p,E:~p~n",[R,E]), 
			    {error,my_sys,E}
	       end.

%%扣费确认请求接口
qq_confirm_pay(Amt,Billno,OpenId,OpenKey,PfKey,UserIp) ->
	Host = env:get(id_secret_host,[]),
	Port = env:get(id_secret_port,[]),	
	AppId = env:get(id_secret_appid,[]),
	Url = "/v3/pay/confirm_pay",
 	DataStr = create_url_params(Url,Amt,Billno,AppId,OpenId,OpenKey,[],[],PfKey,UserIp),	
	SendUrl = create_get_url(Url,DataStr,Host),	
	
	Code = try
		   Socket = case gen_tcp:connect(Host, Port, [{packet,0},binary,{active, true}],?HTTP_CONNECT_TIMEOUTS) of
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
						slogger:msg("qq_gold_op:qq_pre_pay  json:~p~n", [Result]),
						{_,JsonObj} = util:json_decode("{" ++ lists:last(string:tokens(Result,"{"))),
						Ret = util:get_json_member(JsonObj,"ret"),
						case Ret of
								{ok,0}-> 
									{ok,qq_data_ok,0};
								{ok,ErrNo}->
									case util:get_json_member(JsonObj,"msg") of
										{ok,Msg}->
											Msg;
										_->
											Msg = []
									end,
									{error,qq_data_error,{ErrNo,Msg}};
						        _->{error,qq_return_error,nothing}
                      end;
			  		_->{error,tcp,tcp_connect_error}
		  		 end,
		    gen_tcp:close(Socket) ,RecvPacket	 		
	       catch
		      R:E->
			    slogger:msg("R:~p,E:~p~n",[R,E]), 
			    {error,my_sys,E}
	       end.

%%扣费取消请求接口
qq_cancel_pay(Amt,Billno,OpenId,OpenKey,PfKey,UserIp) ->
	Host = env:get(id_secret_host,[]),
	Port = env:get(id_secret_port,[]),
	AppId = env:get(id_secret_appid,[]),
	Url = "/v3/pay/cancel_pay",
   	DataStr = create_url_params(Url,Amt,Billno,AppId,OpenId,OpenKey,[],[],PfKey,UserIp),	
	SendUrl = create_get_url(Url,DataStr,Host),
	
	Code = try
		   Socket = case gen_tcp:connect(Host, Port, [{packet,0},binary,{active, true}],?HTTP_CONNECT_TIMEOUTS) of
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
						{_,JsonObj} = util:json_decode("{" ++ lists:last(string:tokens(Result,"{"))),
						Ret = util:get_json_member(JsonObj,"ret"),
						case Ret of
								{ok,0}-> 
									
									{ok,qq_data_ok,0};
								{ok,ErrNo}->
									case util:get_json_member(JsonObj,"msg") of
										{ok,Msg}->
											Msg;
										_->
											Msg = []
									end,
									{error,qq_data_error,{ErrNo,Msg}};						             
						        _->{error,qq_return_error,nothing}
                      end;
			  		_->{error,tcp,tcp_connect_error}
		  		 end,
		    gen_tcp:close(Socket)  ,RecvPacket		 		
	       catch
		      R:E->
			    slogger:msg("R:~p,E:~p~n",[R,E]), 
			    {error,my_sys,E}
	       end.

