%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-12-14
%% Description: TODO: Add description to identify_verify
-module(identify_verify).

%%
%% Include files
%%
-define(IDENTIFY_VERIFY_CODE_NOSERVER,-6).
-define(IDENTIFY_VERIFY_CODE_BUSY,-7).
-define(THIS_TCP_OP_TIMEOUT,5000).
%%
%% Exported Functions
%%
-export([verify/5,verify_rpc/4]).

%%
%% API Functions
%%

%%
%% Local Functions
%%
verify_rpc(TrueName,Account,Card,FromProc)->
	case node_util:get_authnodes() of
		[]-> self()! {identify_verify_result,?IDENTIFY_VERIFY_CODE_BUSY};
		[AuthNode|_]->
			rpc:cast(AuthNode, ?MODULE, verify, [TrueName,Account,Card,node(),FromProc])
	end.
%% recv(Socket, Length, Timeout)
verify(TrueName,Account,Card,FromNode,FromProc)->
	SecretKey = env:get(id_secret_key,[]),
	Page = env:get(id_secret_page,[]),
	Host = env:get(id_secret_host, []),
	Port = env:get(id_secret_port, []),
	Sign = get_sign(TrueName,Account,SecretKey,Card),
	SendPacket = "GET " ++ get_url(Page,TrueName,Account,Card,Sign)	++ " HTTP/1.1\r\nHost: "++Host ++"\r\n\r\n",
	Code = try
			   Socket = case gen_tcp:connect(Host, Port, [{packet,0},binary,{active, true}]) of
							{ok,S}->S;
							{error,R1}->exit(R1)
						end,
			   case gen_tcp:send(Socket,SendPacket) of
				   ok ->next;
				   {error,R2}->gen_tcp:close(Socket),exit(R2)
			   end,
			   RecvPacket = receive
								{tcp,_Socket,P}-> P;
				   				_->exit(error)
							end,
			   gen_tcp:close(Socket),
			   HttpKvs = string:tokens(binary_to_list(RecvPacket), "\n\r"),
			   [_,RetCode|_] = lists:reverse(HttpKvs),
			   list_to_integer(RetCode)
		   catch
			   _:_-> ?IDENTIFY_VERIFY_CODE_BUSY
			end,
	slogger:msg("identify_verify: truename=~w,account=~w,card=~w,code=~p~n",[TrueName,Account,Card,Code]),
	gs_rpc:cast(FromNode, FromProc, {identify_verify_result,Code}).	

get_url(Page,TrueName,Account,Card,Sign)->
	NewTrueName = if is_binary(TrueName)->
						auth_util:escape_uri(TrueName);
					 true->
						 auth_util:escape_uri(list_to_binary(TrueName))
				  end,
	NewAccount = if is_binary(Account)->
						auth_util:escape_uri(Account);
					 true->
						auth_util:escape_uri(list_to_binary(Account))
				  end,
	
	NewCard =  if is_binary(Card)->
						binary_to_list(Card);
					 true->
						 Card
				  end,
	Page ++"account=" ++ NewAccount
         ++ "&truename=" ++ NewTrueName
         ++ "&card=" ++ NewCard
         ++ "&sign=" ++  Sign.
	

get_sign(TrueName,Account,Key,Card)->
	NewTrueName = if is_binary(TrueName)->
						binary_to_list(TrueName);
					 true->
						 TrueName
				  end,
	NewAccount = if is_binary(Account)->
						binary_to_list(Account);
					 true->
						 Account
				  end,
	NewCard =  if is_binary(Card)->
						binary_to_list(Card);
					 true->
						 Card
				  end,
	Bin = erlang:md5(NewTrueName++NewAccount++Key++NewCard),
	string:to_lower(auth_util:binary_to_hexstring(Bin)).