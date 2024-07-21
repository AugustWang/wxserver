%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-9-20
%% Description: TODO: Add description to golden_plume_awards
-module(serialnumber_activity_script).

%%
%% Include files
%%
-include("error_msg.hrl").
-define(PARAMETERS_INCOMPLETE,-1).
-define(TIMEOUT,-2).
-define(SIGN_ERROR,-3).

%%
%% Exported Functions
%%
-export([process_rpc/2,process/5]).
%% 
%%
%% API Functions
%%
process_rpc(TypeNumber,SerialNumber)->
	case node_util:get_authnodes() of
		[]-> ?ERROR_UNKNOWN;
		[AuthNode|_]->
			RoleId = get(roleid),
			RoleProc = role_op:make_role_proc_name(RoleId),	
			rpc:cast(AuthNode, ?MODULE, process, [RoleId,TypeNumber,SerialNumber,node(),RoleProc])
	end.

process(RoleId,TypeNumber,SerialNumber,FromNode,FromProc)->
	Page = "/api/gm_contral/check_serialnum.php",
	Host = "zygm0.my4399.com",
	Port = 83,
	ServerId = env:get(serverid,0),
	PlatForm = env:get(platform,[]),
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	Time = integer_to_list(MegaSec*1000000 + Sec),
	Sign = make_sign(PlatForm,ServerId,SerialNumber,RoleId,Time),
	SendPacket = "GET "++Page++get_url(PlatForm,ServerId,TypeNumber,SerialNumber,RoleId,Time,Sign)
				  ++" HTTP/1.1\r\nHost: "++Host++"\r\n\r\n",
	TmpResult = try
				 Socket = case gen_tcp:connect(Host, Port, [{packet,0},binary,{active, true}]) of
							  {ok,S}->S;
							  {error,R1}->
								  slogger:msg("R1:~p~n",[R1]),
								exit(R1)
						  end,
				 case gen_tcp:send(Socket,SendPacket) of
					 ok ->next;
					 {error,R2}->
						 slogger:msg("R2:~p~n",[R2]),
						 gen_tcp:close(Socket),exit(R2)
				 end,
				 RecvPacket = receive 
								  {tcp,_Socket,P}-> P;
								  R3->
									  slogger:msg("R3:~p~n",[R3]),
									  exit(R3)
							  end,
				 gen_tcp:close(Socket),
				 PacketContent = binary_to_list(RecvPacket),
				 case get_state(PacketContent) of
					 []->
 						 slogger:msg("serialnumber_activity_script,error,PacketContent:~p~n",[PacketContent]),
						 ?PARAMETERS_INCOMPLETE;
					 State->
					     list_to_integer(State)
				 end
			 catch
				 E:R->slogger:msg("golden_plume_awards_script,E:~p,R:~p~n",[E,R]),
					 ?ERROR_UNKNOWN
					   end,
	Result = if
				 TmpResult =:= ?PARAMETERS_INCOMPLETE->
					 ?ERROR_UNKNOWN;
				 TmpResult =:= ?TIMEOUT->
					 ?ERROR_UNKNOWN;
				 TmpResult =:= ?SIGN_ERROR->
					 ?ERROR_UNKNOWN;
				 true-> 
					 TmpResult
			 end,
%%	slogger:msg("Result:~p,TypeNumber:~p,SerialNumber:~p,Http tmpresult:~p,Result:~p~n",[Result,TypeNumber,SerialNumber,TmpResult,Result]),
	gs_rpc:cast(FromNode, FromProc, {serialnumber_activity_result,{Result,TypeNumber,SerialNumber}}).	
			
			
			

make_sign(PlatForm,ServerId,SerialNumber,RoleId,Time)->
	Key = "123!@#kcv463p6xg",
	Str = atom_to_list(PlatForm)++integer_to_list(ServerId)
			++SerialNumber++integer_to_list(RoleId)++Time++Key,
	Bin = erlang:md5(Str),
	string:to_lower(auth_util:binary_to_hexstring(Bin)).



get_url(PlatForm,ServerId,TypeNumber,SerialNumber,RoleId,Time,Sign)->
	"?platform="++atom_to_list(PlatForm)++"&serverid="
	++integer_to_list(ServerId)++"&key="++integer_to_list(TypeNumber)
	++"&num="++SerialNumber++"&roleid="++integer_to_list(RoleId)
	++"&time="++Time++"&sign="++Sign.
														 


get_state("{state:"++T)->
	{State,_T1} = collect_state_body(T,[]),
	State;
get_state([_|T])->
	get_state(T);
get_state([])->
	[].

collect_state_body("}"++T,L)->
	{lists:reverse(L),T};
collect_state_body([H|T],L)->
	collect_state_body(T,[H|L]);
collect_state_body([],_)->
	{[],[]}.
%%
%% Local Functions
%%

