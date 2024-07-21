%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(role_pos_util).


-export([is_role_online/1,where_is_role/1]).

-export([where_is_role_by_serverid/2,send_to_role_clinet_by_serverid/3,send_to_role_by_serverid/3]).

-export([send_to_role/2,send_to_all_role/1,send_to_role_clinet/2]).

-export([send_to_clinet_by_pos/2,send_to_role_by_pos/2]).

-export([send_to_all_online_clinet/1,send_to_clinet_list/2]).

-export([get_online_roleid_by_name/1]).

-compile(export_all).

is_role_online(RoleId)->
	where_is_role(RoleId)=/=[].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%								where is role???						%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[]/RolePos	cant find other server player not in share map ,if want ,use by serverid
where_is_role(RoleId) when is_integer(RoleId)->
	case role_server_travel:is_in_travel() of
		undefined->			%%not role processor
			role_pos_db:get_role_pos_from_mnesia(RoleId);
		false->
			case role_server_travel:is_same_source_role(RoleId) of
				true->
					role_pos_db:get_role_pos_from_mnesia(RoleId);
				_->
					case travel_deamon_op:get_share_node() of
						[]->
							[];
						ShareNode->		
							where_is_role_by_node(ShareNode,RoleId)
					end
			end;
		true->	%%role is travel
			io:format("is_in_travel where_is_role RoleId ~p ~n",[RoleId]),
			case role_pos_db:get_role_pos_from_mnesia(RoleId) of
				[]->	%%not in cur map_node
					case role_server_travel:is_same_source_role(RoleId) of
						true->
							%%io:format("is_in_travel where_is_role is_same_source_role RolePos ~p ~n",[RoleId]),
							where_is_role_by_node(role_server_travel:get_my_source_node(),RoleId);
						false->		%%cant find other server player not in share map ! not know his source serverid
							[]
					end;
				RolePos->
					%%io:format("is_in_travel where_is_role RolePos ~p ~n",[RolePos]),
					RolePos
			end
	end;

where_is_role(RoleName) ->
	case role_server_travel:is_in_travel() of
		undefined->
			role_pos_db:get_role_pos_from_mnesia_by_name(RoleName);
		false->
			role_pos_db:get_role_pos_from_mnesia_by_name(RoleName);
		true->
			%%use name only find self server!
			where_is_role_by_node(role_server_travel:get_my_source_node(),RoleName)
	end.

where_is_role_by_node(Node,RoleId) when is_integer(RoleId)->
	try
		rpc:call(Node, role_pos_db, get_role_pos_from_mnesia,[RoleId])
	catch
		E:R->
			slogger:msg("where_is_role_by_node Node ~p RoleId ~p ~p ~p ~n",[Node,RoleId,E,R]),
			[]
	end;
where_is_role_by_node(Node,RoleName)->
	try
		rpc:call(Node, role_pos_db, get_role_pos_from_mnesia_by_name,[RoleName])
	catch
		E:R->
			slogger:msg("where_is_role_by_node Node ~p RoleName ~p ~p ~p ~n",[Node,RoleName,E,R]),
			[]
	end.

%%call must in share_map node
where_is_role_travel_channel(ServerId,RoleIdOrName)->
	case where_is_role(RoleIdOrName) of
		[]->			%% not in share_map
			case map_travel_op:get_source_node_by_serverid(ServerId) of
				[]->
					[];
				SourceNode-> 		%% find his source node
					%io:format("where_is_role_by_serverid ServerId ~p SourceNode ~p ~n",[ServerId,SourceNode]),
					where_is_role_by_node(SourceNode,RoleIdOrName)
			end;
		RolePos->		%% he is in share map
			RolePos
	end.

%% call this fun if i'm not in travel and i still want use serverid to communicate!
%% make sure ServerId is not equal to main!
where_is_role_interface(ServerId,RoleIdOrName)->
	case travel_deamon_op:get_share_node() of
		[]->
			[];
		ShareNode->
			try
				rpc:call(ShareNode, ?MODULE, where_is_role_travel_channel,[ServerId,RoleIdOrName])
			catch
				E:R->
					slogger:msg("where_is_role_by_node Node ~p RoleId ~p ~p ~p ~n",[ShareNode,RoleIdOrName,E,R]),
					[]
			end
%%			where_is_role_by_node(ShareNode,RoleNameOrId)
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%								send to role !!!						%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

send_to_role(RoleId,Message)->
	case where_is_role(RoleId) of
		[]->
			nothing;
		RolePos->
			send_to_role_by_pos(RolePos,Message)
	end.

send_to_all_role(Message)->
	S = fun(RolePos)->
			send_to_role_by_pos(RolePos,Message)
		end,
	role_pos_db:foreach(S).

send_to_role_clinet(RoleId,Message)->
	case where_is_role(RoleId) of
		[]->
			nothing;
		RolePos->
			send_to_clinet_by_pos(RolePos,Message)			  
	end.	

send_to_role_by_node(Node,RoleId,Message)->
	try
		rpc:cast(Node,?MODULE, send_to_role,[RoleId,Message])
	catch
		E:R->
			slogger:msg("send_to_role_client_by_node Node ~p RoleName ~p ~p ~p ~n",[Node,RoleId,E,R]),
			[]
	end.

send_to_role_client_by_node(Node,RoleId,Message)->
	try
		rpc:cast(Node,?MODULE, send_to_role_clinet,[RoleId,Message])
	catch
		E:R->
			slogger:msg("send_to_role_client_by_node Node ~p RoleName ~p ~p ~p ~n",[Node,RoleId,E,R]),
			[]
	end.

%%used in share_map node
send_to_role_travel_channel(ServerId,RoleIdOrName,Message)->
	case map_travel_op:get_source_node_by_serverid(ServerId) of
		[]->
			[];
		SourceNode->		%% find his source node
			send_to_role_by_node(SourceNode,RoleIdOrName,Message)
	end.

%%used in share_map node
send_to_role_client_travel_channel(ServerId,RoleIdOrName,Message)->
	case map_travel_op:get_source_node_by_serverid(ServerId) of
		[]->
			[];
		SourceNode->		%% find his source node
			send_to_role_client_by_node(SourceNode,RoleIdOrName,Message)
	end.

%% call this fun if i'm not in travel and i still want use serverid to communicate!
%% make sure ServerId is not equal to main!
send_to_role_interface(ServerId,RoleIdOrName,Message)->
	case travel_deamon_op:get_share_node() of
		[]->
			[];
		ShareNode->
			try
				rpc:cast(ShareNode, ?MODULE, send_to_role_travel_channel,[ServerId,RoleIdOrName,Message])
			catch
				E:R->
					slogger:msg("send_to_role_interface Node ~p RoleId ~p ~p ~p ~n",[ShareNode,RoleIdOrName,E,R]),
					[]
			end
	end.

%% call this fun if i'm not in travel and i still want use serverid to communicate!
%% make sure ServerId is not equal to main!
send_to_role_client_interface(ServerId,RoleIdOrName,Message)->
	case travel_deamon_op:get_share_node() of
		[]->
			[];
		ShareNode->
			try
				rpc:cast(ShareNode, ?MODULE, send_to_role_client_travel_channel,[ServerId,RoleIdOrName,Message])
			catch
				E:R->
					slogger:msg("send_to_role_interface Node ~p RoleId ~p ~p ~p ~n",[ShareNode,RoleIdOrName,E,R]),
					[]
			end
	end.
	
%%RoleName must in source map or travel map TODO:interface to two server!!!
where_is_role_by_serverid(ServerId,RoleNameOrId)->
	%io:format("where_is_role_by_serverid ServerId ~p ~n",[ServerId]),
	MyServerId = env:get(serverid,undefined),
	if
		(ServerId=:=0 ) or (MyServerId=:=ServerId)->%%same server
			where_is_role(RoleNameOrId);
		true->		%%diff server
			case role_server_travel:is_in_travel() of
				true->		%%i'm in travel,he is in or not
					where_is_role_travel_channel(ServerId,RoleNameOrId);
				_->			%%i'm not in travel ,maybe he is in
					where_is_role_interface(ServerId,RoleNameOrId)
			end
	end.

send_to_role_by_serverid(ServerId,RoleIdOrName,Message)->
	MyServerId = env:get(serverid,undefined),
	if
		(ServerId=:=0 ) or (MyServerId=:=ServerId)->
			send_to_role(RoleIdOrName,Message);
		true->		%% travel send
			case role_server_travel:is_in_travel() of
				true->		%%i'm in travel,he is in or not
					send_to_role_travel_channel(ServerId,RoleIdOrName,Message);
				_->		%%i'm not in travel ,he is in
					send_to_role_interface(ServerId,RoleIdOrName,Message)
			end
	end.

send_to_role_clinet_by_serverid(ServerId,RoleIdOrName,Message)->
	MyServerId = env:get(serverid,undefined),
	if
		(ServerId=:=0 ) or (MyServerId=:=ServerId)->
			send_to_role_clinet(RoleIdOrName,Message);
		true->		%% travel send
			case role_server_travel:is_in_travel() of
				true->		%%i'm in travel,he is in or not
					send_to_role_client_travel_channel(ServerId,RoleIdOrName,Message);
				_->		%%i'm not in travel ,he is in
					send_to_role_client_interface(ServerId,RoleIdOrName,Message)
			end
	end.

send_to_role_by_pos(RolePos,Message)->
	Node = role_pos_db:get_role_mapnode(RolePos),
	Proc = role_pos_db:get_role_pid(RolePos),
	gs_rpc:cast(Node,Proc,Message).

send_to_clinet_by_pos(RolePos,Message)->
	GateProc = role_pos_db:get_role_gateproc(RolePos),
	tcp_client:send_data(GateProc,Message).

get_online_roleid_by_name(RoleName)->
	case where_is_role(RoleName) of
		[]->
			[];
		RolePos->	
			role_pos_db:get_role_id(RolePos)
	end.

send_to_all_online_clinet(Message)->
	S = fun(RolePos)->
			send_to_clinet_by_pos(RolePos,Message)
		end,
	role_pos_db:foreach(S).

send_to_clinet_list(Message,RoleList)->
	lists:foreach(fun(RoleId)->
		send_to_role_clinet(RoleId,Message)			  
	end, RoleList).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%						update role_pos data in each mirror
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

update_role_pos_rolename(RoleId,RoleName)->
	case role_server_travel:is_in_travel() of
		true->
			role_pos_db:update_role_pos_rolename(RoleId,RoleName),
			role_server_travel:do_in_travels(role_pos_db,update_role_pos_rolename,[RoleId,RoleName]);
		_->
			role_pos_db:update_role_pos_rolename(RoleId,RoleName)
	end.

update_role_line_map(RoleId,NewLineId,NewMapId)->
	case role_server_travel:is_in_travel() of
		true->
			role_pos_db:update_role_line_map(RoleId,NewLineId,NewMapId),
			role_server_travel:do_in_travels(role_pos_db,update_role_line_map,[RoleId,NewLineId,NewMapId]);
		_->
			role_pos_db:update_role_line_map(RoleId,NewLineId,NewMapId)
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%								update role_pos data end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	