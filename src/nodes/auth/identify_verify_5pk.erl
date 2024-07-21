%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-9-19
%% Description: TODO: Add description to identify_verify_5pk
-module(identify_verify_5pk).

%%
%% Include files
%%
-define(IDENTIFY_VERIFY_CODE_BUSY,-7).
-define(THIS_TCP_OP_TIMEOUT,5000).
-define(NOT_AUTHORIZATION,101).
-define(LINK_FAILURE,102).
-define(INCORRECT_SIGNATURE,103).
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
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	Time = integer_to_list(MegaSec*1000000 + Sec),
	Sign = get_sign(TrueName,Account,SecretKey,Card,Time),
	DataStr = get_data_string(TrueName,Account,Card,Time,Sign),
	DataLength = erlang:length(DataStr),
	SendPacket = "POST "++Page++" HTTP/1.1\r\nHost:" ++ Host ++"\r\n"
					 ++"Content-Type: application/x-www-form-urlencoded"++"\r\n"
					 "Content-Length:"++integer_to_list(DataLength)++"\r\n\r\n"
					++DataStr,
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
			   PacketContent = binary_to_list(RecvPacket),
			   case get_state(PacketContent) of
				   []->
					   ?IDENTIFY_VERIFY_CODE_BUSY;
				   State->
					   list_to_integer(State)
			   end
		   catch
			   R:E->io:format("R:~p,E:~p~n",[R,E]) 
			end,
	if 
		Code =:= ?NOT_AUTHORIZATION->
			Result = ?IDENTIFY_VERIFY_CODE_BUSY;
		Code =:= ?LINK_FAILURE->
			Result = ?IDENTIFY_VERIFY_CODE_BUSY;
		Code =:= ?INCORRECT_SIGNATURE->
			Result = ?IDENTIFY_VERIFY_CODE_BUSY;
		true->
			Result = Code
	end,
	slogger:msg("identify_verify: truename=~w,account=~w,card=~w,code=~p~n",[TrueName,Account,Card,Code]),
	gs_rpc:cast(FromNode, FromProc, {identify_verify_result,Result}).	



get_data_string(TrueName,Account,Card,Time,Sign)->
	"userid="++"&username="++Account++"&identity="++Card++"&realname="
	++TrueName++"&key="++"4399.com"++"&ver=1.0"++"&encrypt=md5"++"&format=json"
	++"&time="++Time++"&sign="++Sign.
	
get_sign(TrueName,Account,Key,Card,Time)->
	Sign = "encrypt"++"md5"++"format"++"json"++"identity"
			++Card++"key"++"4399.com"++"realname"++TrueName
			++"time"++Time++"userid"++"username"++Account
			++"ver1.0"++Key,
	Bin = erlang:md5(Sign),
	string:to_lower(auth_util:binary_to_hexstring(Bin)).

get_state("{\"status\":"++T)->
	{State,_T1} = collect_state_body(T,[]),
	State;
get_state([_|T])->
	get_state(T);
get_state([])->
	[].

collect_state_body(","++T,L)->
	{lists:reverse(L),T};
collect_state_body([H|T],L)->
	collect_state_body(T,[H|L]);
collect_state_body([],_)->
	{[],[]}.
	

