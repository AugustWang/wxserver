%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-19
%%% -------------------------------------------------------------------
-module(gm_client).

-behaviour(gen_fsm).
-include("network_setting.hrl").


%% External exports
-export([start_link/0,
	 send_data/2,
	 send_data/3,
	 shutown_client/1]).

-export([init/1, handle_event/3,
	 handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).

-export([connecting/2,socket_ready/3,socket_disable/3]).


-export([connected/2,
	 start_auth/6]).

-export([authing/2,
	 auth_ok/3,auth_failed/3]).

-export([managing/2]).

-export([kick_client/2]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================

%% Event: socket ok
socket_ready(GMNode,GMProc,ClientSocket)->
	GMPid = GMProc,
	util:send_state_event(GMPid, {socket_ready,ClientSocket}).

socket_disable(GMNode,GMProc,ClientSocket)->
	GMPid = GMProc,   
	util:send_state_event(GMPid, {socket_disable,ClientSocket}).

%% Event: start_auth
start_auth(GMNode, GMProc,GmUserName, GmUserId,Time,AuthResult)->
	GMPid = GMProc,
	util:send_state_event(GMPid,{start_auth,GmUserName, GmUserId,Time,AuthResult}).

%% Event: auth_ok
auth_ok(GMNode, GMProc,GmUserId)->
	GMPid = GMProc,
	util:send_state_event(GMPid,{auth_ok,GmUserId}).

%% Event: auth_failed
auth_failed(GMNode, GMProc,Reason) when is_list(Reason) ->
	GMPid = GMProc,
	util:send_state_event(GMPid, {auth_failed,Reason});
auth_failed(GMNode, GMProc,ReasonId) when is_integer(ReasonId) ->
	GMPid = GMProc,
	util:send_state_event(GMPid, {auth_failed,ReasonId}).

start_link()->
	gen_fsm:start_link(?MODULE, [], []).

init([]) ->
	timer_center:start_at_process(),
	process_flag(trap_exit, true),
	{ok, connecting, #state{}}.

send_data(GMPid,Data) ->
	try 
		case Data of
			<<>> ->
				throw("error: empty data to gm client");
			[] ->
				throw("error: empty data to gm client");
			_ ->
				GMPid! {send_to_client,Data}			
		end
	catch 
		Error ->
			slogger:msg("~p~n", [erlang:get_stacktrace()])
	end.


send_data(GMNode,GMProc,Data)->
	GMPid = GMProc,
	case Data of
		<<>> ->
			throw("error: empty data to gm client");
		[] ->
			throw("error: empty data to gm client");
		_ ->
			gs_rpc:cast(GMPid, {send_to_client,Data})
	end.

shutown_client(Pid) ->
	Pid!{shutdown}.

kick_client(GMNode,GMProc)->
	GMPid = GMProc,
	gs_rpc:cast(GMPid, {kick_client}).


connecting({socket_ready,CliSocket},StateData)->
	OkIpList = env:get(gmiplist, []),
	{PeerAddress, _PeerPort} = inet_op(fun () -> inet:peername(CliSocket) end),

	FilterFun = fun({IpStr1,IpStr2})->
						ipfilter:match_tupleip(PeerAddress,IpStr1, IpStr2)
				end,
	
	case lists:any(FilterFun, OkIpList) of
		true->
			%%ProcName = make_client_name(CliSocket),
			%%erlang:register(ProcName,self()),
			inet:setopts(CliSocket, ?TCP_CLIENT_SOCKET_OPTIONS),
			put(clientsock, CliSocket),
			put(clientaddr, PeerAddress);
			%%put(procname, ProcName);
		_->
			self()!{kick_client,"Gm Error Ip login"}
	end,

	{next_state, connected, StateData};

connecting({socket_disable,CliSocket},StateData)->
	self()!{kick_client,"socket is disable "},
	put(clientsock, CliSocket),
	{stop, normal, StateData};

connecting(Event,StateData)->
	{next_state, connecting, StateData}.

connected({start_auth,GmUserName,GmUserId,Time,AuthResult}, StateData) ->
	gmauth_processor:auth(node(), self(), GmUserName, GmUserId, Time, AuthResult),	
	{next_state, authing, StateData};

connected(Event,State) ->
	{next_state, connected, State}.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% state: authing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
authing({auth_failed,Reason}, StateData) ->
	self()!{kick_client,Reason},
	{next_state, connected,StateData};

authing({auth_ok,GmId}, StateData) ->
	AuthOk = {struct,[{<<"cmd">>,<<"auth_ok">>}]},
	case util:json_encode(AuthOk) of
		{ok,JsonBin}->
			send_data(self(),JsonBin);
		{error,Reason}->
			io:format("util:json_encode ~p error:~p~n",[AuthOk,Reason])
	end,
		   
	{next_state,managing,StateData};

authing(Event, State) ->
	{next_state, authing, State}.

managing({Cmd,JsonObj},StateData) ->
		case Cmd of	
			{ok,"add_gm_notice"}-> gm_op:add_gm_notice(JsonObj);
			{ok,"delete_gm_notice"}-> gm_op:delete_gm_notice(JsonObj);
			{ok,"hide_gm_notice"}-> gm_op:hide_gm_notice(JsonObj);
			{ok,"publish_gm_notice"}->gm_op:publish_gm_notice(JsonObj);
			{ok,"user_charge"}->gm_op:user_charge(JsonObj);
			{ok,"gm_user_charge"}->gm_op:gm_user_charge(JsonObj);
			{ok,"gm_first_charge_gift"}->gm_op:gm_first_charge_gift(JsonObj);
			{ok,"gm_first_charge_gift_roleid"}->gm_op:gm_first_charge_gift_roleid(JsonObj);
			{ok,"gm_activity_finish"}->gm_op:gm_activity_finish(JsonObj);
			{ok,"gm_facebook_quest"}->gm_op:gm_facebook_quest(JsonObj);
			{ok,"gm_get_role_info"}->gm_op:gm_get_role_info(JsonObj);
			{ok,"gm_delete_mall_item"}->gm_op:gm_delete_mall_item(JsonObj);
			{ok,"gm_update_mall_item"}->gm_op:gm_update_mall_item(JsonObj);
			{ok,"gm_update_sales_item"}->gm_op:gm_update_sales_item(JsonObj);
			{ok,"gm_delete_sales_item"}->gm_op:gm_delete_sales_item(JsonObj);
			{ok,"gm_delete_activity"}->gm_op:gm_delete_activity(JsonObj);
			{ok,"gm_change_role_name"}->gm_op:gm_change_role_name(JsonObj);
			{ok,"gm_update_activity"}->gm_op:gm_update_activity(JsonObj);
			{ok,"gm_set_role_privilege"}->gm_op:gm_set_role_privilege(JsonObj);
			{ok,"gm_delete_role_privilege"}->gm_op:gm_delete_role_privilege(JsonObj);
			{ok,"map_data"}->gm_op:map_data(JsonObj);
			{ok,"online_count"}->gm_op:online_count_rpc(JsonObj);
			{ok,"gm_send"}->gm_op:gm_send(JsonObj);
			{ok,"gm_send_all"}->gm_op:gm_send_all(JsonObj);
			{ok,"gm_move_user"}->gm_op:gm_move_user(JsonObj);
			{ok,"system_option"}->gm_op:system_option(JsonObj);
			{ok,"loop_tower_week_reward"}->gm_op:loop_tower_week_reward(JsonObj);
			{ok,"get_loop_tower_curlayer"}->gm_op:get_loop_tower_curlayer(JsonObj);
			{ok,"power_gather"}->gm_op:power_gather(JsonObj);
			{ok,"query_player_request"}-> gm_op:query_player_request(JsonObj);
			{ok,"disable_player"}-> gm_op:disable_player(JsonObj);
			{ok,"enable_player"}-> gm_op:enable_player(JsonObj);
			{ok,"disable_player_say"}-> gm_op:disable_player_say(JsonObj);
			{ok,"enable_player_say"}-> gm_op:enable_player_say(JsonObj);
			{ok,"disable_ip_login"}->gm_op:disable_ip_login(JsonObj);
			{ok,"enable_ip_login"}->gm_op:enable_ip_login(JsonObj);
			{ok,"gift_send"}->gm_op:gift_send(JsonObj);
			{ok,"query_gate"}-> gm_op:query_gate_request(JsonObj);
			{ok,"query_line"}-> gm_op:query_line_request(JsonObj);
			{ok,"gm_kick_role"}-> gm_op:gm_kick_role(JsonObj);
			{ok,"all_role_vip"}-> gm_op:all_role_vip(JsonObj);
			{ok,"gm_update_global_monster"}-> gm_op:gm_update_global_monster(JsonObj);
			{ok,"gm_delete_global_monster"}-> gm_op:gm_delete_global_monster(JsonObj);
			{ok,"gm_update_global_exp_addition"}-> gm_op:gm_update_global_exp_addition(JsonObj);
			{ok,"gm_delete_global_exp_addition"}-> gm_op:gm_delete_global_exp_addition(JsonObj);
			{ok,"gm_add_whiteip"}-> gm_op:gm_add_whiteip(JsonObj);
			{ok,"gm_update_welfare_activity"}->gm_op:gm_update_welfare_activity(JsonObj);
			{ok,"gm_delete_welfare_activity"}->gm_op:gm_delete_welfare_activity(JsonObj);
			{ok,"gm_update_pet_explore_map_data"}->gm_op:gm_update_pet_explore_map_data(JsonObj);
			{ok,"gm_delete_pet_explore_map_data"}->gm_op:gm_delete_pet_explore_map_data(JsonObj);
			{ok,"gm_import_giftcard"}-> gm_op:gm_import_giftcard(JsonObj);
			{ok,"gm_update_guildbattle"}->gm_op:gm_update_guildbattle(JsonObj);
			{ok,"gm_delete_guildbattle"}->gm_op:gm_delete_guildbattle(JsonObj);
			{ok,"gm_update_festival_info"}->gm_op:gm_update_festival_info(JsonObj);
			{ok,"gm_delete_festival_info"}->gm_op:gm_delete_festival_info(JsonObj);
			{ok,"gm_update_festival_recharge_gift"}->gm_op:gm_update_festival_recharge_gift(JsonObj);
			{ok,"gm_update_open_service_activities"}->gm_op:gm_update_open_service_activities(JsonObj);
			{ok,"gm_delete_open_service_activities"}->gm_op:gm_delete_open_service_activities(JsonObj);
			{ok,"gm_log_control"}->gm_op:gm_log_control(JsonObj)
		end,
	{next_state, managing, StateData};
managing(Event,State)->
	{next_state, managing, State}.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  send by gen_fsm:sync_send_all_state_event/2,3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle_event(stop, StatName , StateData)->
	{stop, normal, StateData};

handle_event(Event, StateName, StateData) ->
	{next_state, StateName, StateData}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sync event: send by gen_fsm:send_all_state_event/2,3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle_sync_event(Event, From, StateName, StateData) ->
	Reply = ok,
	{reply, Reply, StateName, StateData}.

%%
%% game GM need to send data
handle_info({send_to_client, Data}, StateName, StateData) ->
	gen_tcp:send(get(clientsock), Data),
	{next_state, StateName, StateData};

handle_info({tcp, Socket, BinData}, StateName, StateData) ->
%% 	slogger:msg("tcp,socket"),
	handle_client_json(BinData),
	inet:setopts(Socket, [{active, once}]),
	{next_state, StateName, StateData};

handle_info({tcp_closed, _Socket}, StateName, StateData) ->
	{stop, normal, StateData};

handle_info({shutdown},StateName,StateData)->
	{stop, normal, StateData};

handle_info({kick_client},StateName,StateData)->
	slogger:msg("receive need kick client, maybe error client!\n"),
	inet:tcp_close(get(clientsock)),
	{next_state,StateName, StateData};	

handle_info({kick_client,Reason},StateName,StateData)->
	slogger:msg("receive need kick gm :~p!\n",[Reason]),
	inet:tcp_close(get(clientsock)),
	{next_state,StateName, StateData};	

handle_info(Info, StateName, StateData) ->
	{next_state, StateName, StateData}.

%% --------------------------------------------------------------------
%% Func: terminate/3
%% Purpose: Shutdown the fsm
%% Returns: any
%% --------------------------------------------------------------------
terminate(Reason, StateName, StatData) ->
	%%add for terminat
	ok.

%% --------------------------------------------------------------------
%% Func: code_change/4
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState, NewStateData}
%% --------------------------------------------------------------------
code_change(OldVsn, StateName, StateData, Extra) ->
	{ok, StateName, StateData}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

inton({A,B,C,D},P)->
	integer_to_list(A) ++ "_" ++ integer_to_list(B) ++ "_" ++ 
		integer_to_list(C) ++ "_" ++ integer_to_list(D) 
		++ "_" ++ integer_to_list(P).

make_client_name(Socket)->
	case inet:peername(Socket) of
		{error, _ } -> undefined;
		{ok,{Address,Port}}->
			ProcName = "zygmagent_"++inton(Address,Port),
			list_to_atom(ProcName)
	end.


throw_on_error(E, Thunk) ->
    case Thunk() of
        {error, Reason} -> throw({E, Reason});
        {ok, Res}       -> Res;
        Res             -> Res
    end.
inet_op(F) -> throw_on_error(inet_error, F).



handle_client_json(Bin)->
	case util:json_decode(Bin) of
		{ok,JsonObj}-> 
			handle_json(JsonObj);
		{error}-> ignor;
		_-> exception
	end.

handle_json({struct,_JsonMember} = JsonObj)->
	Cmd = util:get_json_member(JsonObj,"cmd"),
	case Cmd of
		{ok,"auth"}-> handle_json_auth(JsonObj);
		{ok,Str}->
			gen_fsm:send_event(self(), {Cmd,JsonObj})
	end.

handle_json_auth(JsonObject)->
	{ok,GmUser} = util:get_json_member(JsonObject, "username"),
	{ok,GmUserId} = util:get_json_member(JsonObject, "userid"),
	{ok,Time} = util:get_json_member(JsonObject, "time"),
	{ok,Flag} = util:get_json_member(JsonObject, "flag"),
	start_auth(node(),self(),GmUser,GmUserId,Time,Flag).

