%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-9-20
%% Description: TODO: Add description to golden_plume_awards
-module(golden_plume_awards_script).

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
	SendPacket = "GET "++Page++get_url(PlatForm,ServerId,SerialNumber,RoleId,Time,Sign)
				  ++" HTTP/1.1\r\nHost: "++Host++"\r\n\r\n",
	TmpResult = try
				 Socket = case gen_tcp:connect(Host, Port, [{packet,0},binary,{active, true}]) of
							  {ok,S}->S;
							  {error,R1}->exit(R1)
						  end,
				 case gen_tcp:send(Socket,SendPacket) of
					 ok ->next;
					 {error,R2}->
						 gen_tcp:close(Socket),exit(R2)
				 end,
				 RecvPacket = receive 
								  {tcp,_Socket,P}-> P;
								  R3->
									  exit(R3)
							  end,
				 gen_tcp:close(Socket),
				 HttpKvs = string:tokens(binary_to_list(RecvPacket), "\n\r"),
				 [_,RetCode|_] = lists:reverse(HttpKvs),
				 list_to_integer(RetCode)
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
%% 	slogger:msg("Result:~p,TypeNumber:~p,SerialNumber:~p,Http tmpresult:~p,Result:~p~n",[Result,TypeNumber,SerialNumber,TmpResult,Result]),
	gs_rpc:cast(FromNode, FromProc, {golden_plume_awards,{Result,TypeNumber,SerialNumber}}).	
			
			
			

make_sign(PlatForm,ServerId,SerialNumber,RoleId,Time)->
	Key = "123!@#kcv463p6xg",
%% 	io:format("PlatForm:~p,ServerId:~p,SerialNumber:~p,RoleId:~p,Time:~p~n",[PlatForm,ServerId,SerialNumber,RoleId,Time]),
	Str = atom_to_list(PlatForm)++integer_to_list(ServerId)
			++SerialNumber++integer_to_list(RoleId)++Time++Key,
	Bin = erlang:md5(Str),
	string:to_lower(auth_util:binary_to_hexstring(Bin)).


get_url(PlatForm,ServerId,SerialNumber,RoleId,Time,Sign)->
	"?platform="++atom_to_list(PlatForm)++"&serverid="
	++integer_to_list(ServerId)++"&serial_num="
	++SerialNumber++"&roleid="++integer_to_list(RoleId)
	++"&time="++Time++"&sign="++Sign.
														 

%%
%% Local Functions
%%

