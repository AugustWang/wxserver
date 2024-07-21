%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-10-17
%% Description: TODO: Add description to baidu_post
-module(baidu_post).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([post_role_rpc/2,post_role/2]).

%%
%% API Functions
%%
post_role_rpc(AccountName,RoleName)->
	case node_util:get_authnodes() of
		[]-> nothing;
		[AuthNode|_]->
			rpc:cast(AuthNode, ?MODULE, post_role, [AccountName,RoleName])
	end.
	
%%
%% Local Functions
%%
post_role(BaiduUserId,RoleName)->
	AppSecret = env:get2(baidu_post,app_secret,""),
	ApiKey = env:get2(baidu_post,api_key,""),
	ServerId = env:get2(baidu_post,server_id,""),
	Page = env:get2(baidu_post,page,""),
	Host = env:get2(baidu_post,host, ""),
	Port = env:get2(baidu_post,port, 80),
	Action = "CREATE",
	EncodeRoleName = util:escape_uri(list_to_binary(RoleName)),
	{{Y,MM,D},{H,M,S}} = calendar:now_to_local_time(timer_center:get_correct_now()),
	StrTime = integer_to_list(Y)++"-"++integer_to_list(MM)++"-"++integer_to_list(D)++" "
			++integer_to_list(H)++":"++integer_to_list(M)++":"++integer_to_list(S),
	Sign = get_sign(AppSecret,ApiKey,BaiduUserId,ServerId,StrTime,RoleName,Action),
	DataStr = get_data_string(ApiKey,BaiduUserId,ServerId,StrTime,EncodeRoleName,Action,Sign),
	DataLength = erlang:length(DataStr),
	SendPacket = "POST "++Page++" HTTP/1.1\r\nHost:" ++ Host ++"\r\n"
					 ++"Content-Type: application/x-www-form-urlencoded"
					 ++"\r\nContent-Length:"++integer_to_list(DataLength)++"\r\n\r\n"
					++DataStr,
	try
	   Socket = case gen_tcp:connect(Host, Port, [{packet,0},binary,{active, true}]) of
							{ok,Sock}->Sock;
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
	   PacketContent = binary_to_list(RecvPacket),
	   case string:str(PacketContent,"recive ok") of
		   0->
			   slogger:msg("baidu post error:~p,~p~n", [BaiduUserId,RoleName]);
		   _->
			   ok
	   end
	catch
		R:E->io:format("R:~p,E:~p~n",[R,E]) 
	end.

get_sign(AppSecret,ApiKey,BaiduUserId,ServerId,StrTime,RoleName,Action)->
	Sign = AppSecret++"action"++Action++"api_key"++ApiKey++"role_name"++RoleName
			++"server_id"++ServerId++"timestamp"++StrTime++"user_id"++BaiduUserId,
	Bin = erlang:md5(Sign),
	string:to_upper(auth_util:binary_to_hexstring(Bin)).

get_data_string(ApiKey,BaiduUserId,ServerId,StrTime,RoleName,Action,Sign)->
	"api_key="++ApiKey++"&user_id="++BaiduUserId++"&server_id="++ServerId
	++"&timestamp="++StrTime++"&role_name="++RoleName++"&action="++Action++"&sign="
	++Sign.

