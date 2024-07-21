%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : PCWS06
%%% Description :
%%%
%%% Created : 2010-7-8
%%% -------------------------------------------------------------------
-module(chat_process).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([whereis_role/1,init_role/2,sendmsg/3,send_binary_msg/3,send_world/7,send_map/7,send_map/8,send_instance/7,send_broadcast_world/2,
		send_broadcast_map/3,send_broadcast_instance/3,send_broadcast_map/4]).
-export([system_to_someone/7]).
-record(state, {}).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
%% ====================================================================
%% External functions
%% ====================================================================
-compile(export_all).

%% ====================================================================
%% Server functions
%% ====================================================================
start_link(RoleId) ->	
	ChatProc = role_op:make_role_proc_name(RoleId),
	gen_server:start_link({local,ChatProc}, ?MODULE, [RoleId,ChatProc], []).
	
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([RoleId,ChatProc]) ->
	timer_center:start_at_process(),
	chat_manager:reg_chat_process(RoleId),
	case chat_manager:get_crash_role_info(RoleId) of
		undefined ->
			ok;
		RoleInfo -> 
			init_role(self(), RoleInfo),		
			chat_manager:unreg_crash_role_info(RoleId)
	end,
	{ok, #state{}}.

init_role(Role_pid, { GS_system_role_info, GS_system_gate_info})->
	gs_rpc:cast(node(),Role_pid, {init_role, {GS_system_role_info, GS_system_gate_info}}).


%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({send_msg,{Type,RoleId,RoleName,DestName,Msg,Details,SendList,RoleIden,RepType}}, State) ->
	Message = chat_manager:get_filter_msg(Msg),
	case Type of
		?CHAT_TYPE_WORLD->
			send_world(Type,RoleId, RoleName,Message,Details,RoleIden,RepType); 
		?CHAT_TYPE_INTHEVIEW->
			send_intheview(Type,RoleId, RoleName,Message,Details,SendList,RoleIden,RepType);
		?CHAT_TYPE_PRIVATECHAT->
			send_privatechat(Type, RoleId,RoleName,DestName, Message,Details,SendList,RoleIden,RepType);
		?CHAT_TYPE_GROUP->
			send_group(Type,RoleId, RoleName,Message,Details,SendList,RoleIden,RepType);
		?CHAT_TYPE_GM_NOTICE->
			send_world(Type,RoleId, RoleName,Msg,Details,RoleIden,0);%%@@wb20130428
		?CHAT_TYPE_GUILD->
			send_guild(Type,RoleId,RoleName, Message,Details,SendList,RoleIden,RepType);
		?CHAT_TYPE_ROLLTEXT->
			send_rolletext(Type,RoleId,RoleName, Message,Details,SendList,RoleIden);
		?CHAT_TYPE_LARGE_EXPRESSION->
			send_expression(Type,RoleId, RoleName,Message,Details,SendList,RoleIden)
	end,		
	{noreply, State};

handle_info({binary_msg,Message}, State) ->
	role_pos_util:send_to_all_online_clinet(Message),
	{noreply, State};


handle_info({init_role, {GS_system_role_info, GS_system_gate_info}}, State) ->
	put(role_info,GS_system_role_info),
	put(gate_info,GS_system_gate_info),
%%	send_chatnode_gate(),
%%	send_chatnode_role(),
	{noreply, State};

handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
	RoleId = get_id_from_gs_system_roleinfo(get(role_info)),
	chat_manager:unreg_chat_process(RoleId),
	chat_manager:reg_crash_role_info(RoleId,{get(map_info),get(role_info),get(gate_info)}),
	ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

whereis_role(ProcName) when is_atom(ProcName)->
	case whereis(ProcName) of
		undefined-> undefined;
		_-> ProcName
	end;
whereis_role(RoleId) when is_integer(RoleId)->
	RoleProcName = role_op:make_role_proc_name(RoleId),
	whereis_role(RoleProcName);
whereis_role(_UnknArg) ->
	undefined.
send_data_to_gate(Message) ->
	GateProc = get_proc_from_gs_system_gateinfo(get(gate_info)),
	tcp_client:send_data(GateProc, Message).

sendmsg(ChatNode,ChatProc,{Type,RoleId,RoleName, DestName,Msg,Details,SendList,RoleIden,RepType})->
	gs_rpc:cast(ChatNode, ChatProc, {send_msg,{Type,RoleId,RoleName,DestName,Msg,Details,SendList,RoleIden,RepType}}).

send_binary_msg(ChatNode,ChatProc,Message)->
	gs_rpc:cast(ChatNode, ChatProc, {binary_msg,Message}).

%%add by wb 20130503
send_world(Type,RoleId,RoleName, Msg,Details,RoleIden)->
	send_world(Type,RoleId,RoleName, Msg,Details,RoleIden,0).
%%

send_world(Type,RoleId,RoleName, Msg,Details,RoleIden,_RepType)->
	Message = chat_packet:encode_chat_s2c(Type,?DEST_CHAT,RoleId,RoleName,Msg,Details,RoleIden),
	role_pos_util:send_to_all_online_clinet(Message).

send_map(Type,RoleId,MapId,RoleName,Msg,Details,RoleIden)->
	Message = chat_packet:encode_chat_s2c(Type,?DEST_CHAT,RoleId,RoleName,Msg,Details,RoleIden),
	S = fun(RolePos)->
					role_pos_util:send_to_clinet_by_pos(RolePos, Message)
				end,
	role_pos_db:foreach_by_map(S,MapId).

send_map(Type,RoleId,MapId,LineId,RoleName,Msg,Details,RoleIden)->
	Message = chat_packet:encode_chat_s2c(Type,?DEST_CHAT,RoleId,RoleName,Msg,Details,RoleIden),
	S = fun(RolePos)->
					role_pos_util:send_to_clinet_by_pos(RolePos, Message)
				end,
	role_pos_db:foreach_by_map_line(S,MapId,LineId).

send_instance(Type,RoleId,InstanceId,RoleName,Msg,Details,RoleIden)->
	Message = chat_packet:encode_chat_s2c(Type,?DEST_CHAT,RoleId,RoleName,Msg,Details,RoleIden),
	MemberIdList = instance_pos_db:get_members_by_instanceid(InstanceId),
	role_pos_util:send_to_clinet_list(Message, MemberIdList).

send_broadcast_world(Id,Param)->
	Message = chat_packet:encode_system_broadcast_s2c(Id, Param),
	S = fun(RolePos)->
					GateProc = role_pos_db:get_role_gateproc(RolePos),
					send_direct_to_gate(GateProc,Message)
				end,
	role_pos_db:foreach(S).

send_broadcast_map(Id,MapId,Param)->
	Message = chat_packet:encode_system_broadcast_s2c(Id, Param),
	S = fun(RolePos)->
					GateProc = role_pos_db:get_role_gateproc(RolePos),
					send_direct_to_gate(GateProc,Message)
				end,
	role_pos_db:foreach_by_map(S,MapId).

send_broadcast_map(Id,MapId,LineId,Param)->
	Message = chat_packet:encode_system_broadcast_s2c(Id, Param),
	S = fun(RolePos)->
					GateProc = role_pos_db:get_role_gateproc(RolePos),
					send_direct_to_gate(GateProc,Message)
				end,
	role_pos_db:foreach_by_map_line(S,MapId,LineId).

send_broadcast_instance(Id,InstanceId,Param)->
	Message = chat_packet:encode_system_broadcast_s2c(Id, Param),
	MemberIdList = instance_pos_db:get_members_by_instanceid(InstanceId),
	role_pos_util:send_to_clinet_list(Message, MemberIdList).

send_direct_to_gate(GateProc,Message)->
	tcp_client:send_data( GateProc, Message).

send_intheview(Type,RoleId,RoleName, Msg,Details,SendList,RoleIden,RepType)->
	send_list_msg(Type,RoleId,SendList,RoleName,Msg,Details,RoleIden,RepType).	

send_privatechat(Type,RoleId,RoleName, DestName,Msg,Details,[DesId],RoleIden,RepType)->
	Messageback = chat_packet:encode_chat_s2c(Type,?SRC_CHAT,DesId,DestName,Msg,Details,RoleIden,0,RepType),
	send_data_to_gate(Messageback),
	send_list_msg(Type,RoleId,[DesId],RoleName,Msg,Details,RoleIden,RepType).

send_group(Type,RoleId,RoleName, Msg,Details,SendList,RoleIden,_RepType)->
	send_list_msg(Type,RoleId,SendList,RoleName,Msg,Details,RoleIden,0).

send_guild(Type,RoleId,RoleName, Msg,Details,SendList,RoleIden,_RepType)->
	send_list_msg(Type,RoleId,SendList,RoleName,Msg,Details,RoleIden,0).

send_rolletext(Type,RoleId,RoleName, Msg,Details,SendList,RoleIden)->
	send_list_msg(Type,RoleId,SendList,RoleName,Msg,Details,RoleIden,0).%%@@wb20130428

send_expression(Type,RoleId,RoleName, Msg,Details,SendList,RoleIden)->
	send_list_msg(Type,RoleId,SendList,RoleName,Msg,Details,RoleIden,0).%%@@wb20130428
send_list_msg(Type,RoleId,SendList,RoleName,Msg,Details,RoleIden,RepType)->
	Message = chat_packet:encode_chat_s2c(Type,?DEST_CHAT,RoleId,RoleName,Msg,Details,RoleIden,0,RepType),%%@@wb20130428
	role_pos_util:send_to_clinet_list(Message, SendList).

system_to_someone(Type,RoleId,RoleName,DestRoleId,Msg,Details,RoleIden)->
	Message = chat_packet:encode_chat_s2c(Type,?DEST_CHAT,RoleId,RoleName,Msg,Details,RoleIden),
	role_pos_util:send_to_role_clinet(DestRoleId, Message).
