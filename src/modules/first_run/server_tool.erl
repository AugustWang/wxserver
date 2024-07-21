%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-8-23
%% Description: TODO: Add description to server_tool
-module(server_tool).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([run/0,print_tool/0]).

%%
%% API Functions
%%

run()->
	applicationex:force_start(),
	%% line
	check_line_run(),
	%% db
	check_db_run(),
	%% map
	check_map_run(),
	%%autnode
	check_auth_run(),
	%%chat_node
	check_chat_run(),
	%%time center node
	check_timecenter_run(),
	%%crossdomain node
	check_crossdomain_run(),
	%% guild node
	check_guild_run(),
	%% gate
	check_gate_run(),
	%% gm
	check_gm_run(),
	%% tool
	check_tool_run(),
	
	%% server
	check_servercontrol_run().


%%
%% Local Functions
%%

check_map_run()->
	Node = node_util:get_node_sname(node()),
	case node_util:check_snode_match(map, Node) of
%	case lists:member(Node, env:get2(nodes, map ,[])) of
		true-> map_app:start();
		_-> ignor
	end.

check_chat_run()->
	Node = node_util:get_node_sname(node()),
	case node_util:check_snode_match(chat, Node) of
%	case lists:member(Node, env:get2(nodes, chat ,[])) of
		true-> chat_app:start();
		_-> ignor
	end.

check_crossdomain_run()->
	Node = node_util:get_node_sname(node()),
	case node_util:check_snode_match(cross, Node) of
%	case lists:member(Node, env:get2(nodes, cross ,[])) of
		true-> crossdomain_app:start();
		_-> ignor
	end.
	
check_gate_run()->
	Node = node_util:get_node_sname(node()),
	case node_util:check_snode_match(gate, Node) of
%	case lists:member(Node, env:get2(nodes, gate ,[])) of
		true-> gate_app:start();
		_-> ignor
	end.

check_gm_run()->
	Node = node_util:get_node_sname(node()),
	case node_util:check_snode_match(gm, Node) of
%	case lists:member(Node, env:get2(nodes, gm ,[])) of
		true-> gm_app:start();
		_-> ignor
	end.

check_line_run()->
	Node = node_util:get_node_sname(node()),
	case node_util:check_snode_match(line, Node) of
%	case lists:member(Node, env:get2(nodes, line ,[])) of
		true-> line_app:start();
		_-> ignor
	end.

check_db_run()->
	Node = node_util:get_node_sname(node()),
	case node_util:check_snode_match(db, Node) of
%	case lists:member(Node, env:get2(nodes, db ,[])) of
		true-> dbapp:start();
		_-> ignor
	end.

check_auth_run()->
	Node = node_util:get_node_sname(node()),
	case node_util:check_snode_match(auth, Node) of
%	case lists:member(Node, env:get2(nodes, auth ,[])) of
		true-> auth_app:start();
		_-> ignor
	end.

check_timecenter_run()->
	Node = node_util:get_node_sname(node()),
	case node_util:check_snode_match(timer, Node) of
%	case lists:member(Node, env:get2(nodes, timer ,[])) of
		true-> timer_app:start();
		_-> ignor
	end.

check_guild_run()->
	Node = node_util:get_node_sname(node()),
	case node_util:check_snode_match(guild, Node) of
%	case lists:member(Node, env:get2(nodes, guild ,[])) of
		true-> guild_app:start();
		_-> ignor
	end.



%%------------------------------------------------------------------------------------------
%% for tools 
%%------------------------------------------------------------------------------------------

check_tool_run()->
	SNode = node_util:get_node_sname(node()),
	SNodeStr = atom_to_list(SNode),
	case string:str(SNodeStr, "tool") of
		0->ignor_nodes;
		_->
			Cookie = env:get(cookie,undefined),
			erlang:set_cookie(node(), Cookie),
			case util:get_argument('-line') of
				[]->  io:format("Missing --line argument input the nodename~n");
				[CenterNode|_]->
					net_adm:ping(CenterNode),
					print_tool(100)
			end
	end.

check_servercontrol_run()->
	SNode = node_util:get_node_sname(node()),
	SNodeStr = atom_to_list(SNode),
	case string:str(SNodeStr, "servercontrol") of
		0->ignor_nodes;
		_->
			Cookie = env:get(cookie,undefined),
			erlang:set_cookie(node(), Cookie),
			case util:get_argument('-line') of
				[]->  io:format("Missing --line argument input the nodename~n");
				[CenterNode|_]->
					ping_center:ping(CenterNode),
					case util:get_argument('-function') of
					  []->
						nothing;
					  [Func]->
						  case util:get_argument('-funcparam') of
							  []->	  
								apply(server_control,Func,[]);
							  [Param]->
								apply(server_control,Func,[Param])
						   end
					end
			end
	end.

print_tool()->
	[CenterNode|_] = util:get_argument('-line'),
	net_adm:ping(CenterNode),
	MapNodes = node_util:get_mapnodes(),
	case MapNodes of
		[]->io:format("can not get the map nodes~n");
		[MapNode|_]-> 
			DbNode = node_util:get_dbnode(),
			print_tool(MapNode,DbNode)
	end.
print_tool(MapNode,DbNode)->
	ServerId = env:get(serverid,undefined),
	RoleAttrTable = "roleattr_"++ integer_to_list(ServerId) ++"_0",
	io:format("input:~n"),
	io:format("		 FunSD = fun(Node)-> rpc:call(Node,init,stop,[]) end.~n"),
	io:format("		 rpc:call(node_util:get_mapnode(),gm_order_op,kick_all,[]).~n"),
	io:format("      rpc:call(node_util:get_mapnode(),chat_manager,gm_broad_cast,[L]).~n"),
	io:format("      rpc:call(node_util:get_dbnode(),role_db,get_role_list_by_account,[AccountName]).~n"),
	io:format("      rpc:call(node_util:get_dbnode(),role_db,get_roleid_by_name,[RoleName]).~n"),
	io:format("      rpc:call(node_util:get_dbnode(),role_db,get_role_info,[RoleId]).~n"),
	io:format("      rpc:call(node_util:get_mapnode(),gm_order_op,block_user,[RoleId, LeftSeconds]).~n"),
	io:format("      rpc:call(node_util:get_mapnode(),gm_block_db,delete_user,[RoleId, login]).~n"),	
	io:format("      rpc:call(node_util:get_mapnode(),gm_order_op,block_user_talk,[RoleId, LeftSeconds]).~n"),
	io:format("      rpc:call(node_util:get_mapnode(),gm_block_db,delete_user,[RoleId, talk]).~n"),
	io:format("      rpc:call(node_util:get_mapnode(),gm_order_op,block_ip,[IpAddress, LeftSeconds]).~n"),
	io:format("      rpc:call(node_util:get_mapnode(),gm_block_db,delete_user,[IpAddress, connect]).~n"),	
	io:format("      dal:read_rpc(TableName).~n"),
	io:format("      dal:read_rpc(TableName,Key).~n"),	
	io:format("      dal:write_rpc(Object).~n"),
	io:format("      gm_op:query_gate_state().~n"),
	io:format("      rpc:call(GateNode, gs_prof, procs, []).~n"),
	io:format("      gm_op:query_line_state().~n"),
	io:format("      dal:read_rpc(role_pos).~n"),
	io:format("      FO = fun()-> {ok,L} = dal:read_rpc(role_pos), erlang:length(L) end.~n"),
	io:format("      gm_viewer:get_roledictionary(RoleId).~n"),
	io:format("      dal:read_rpc(list_to_atom(\"roleattr_\"++integer_to_list(env:get(serverid,undefined))++\"_0\")).~n"),
	io:format("      dal:read_rpc(~p).~n",[list_to_atom(RoleAttrTable)]),
	io:format("      version_up:up_all().~n"),
	io:format("      version_up:up_module([module]). ~n"),
	io:format("      version_up:up_data().~n"),
	io:format("      version_up:up_ets([module]). ~n"),
	io:format("      version_up:up_option(). ~n"),
	io:format("      server_control:hotshutdown(Time_s). ~n"),
	io:format("      server_control:hotshutdown(Time_s,Reason). ~n"),
	io:format("      server_control:cancel_shutdowncmd(). ~n"),
	io:format("      server_control:openthedoor(). ~n"),
	io:format("      server_control:closethedoor(). ~n"),
	io:format("      server_control:open_gmdoor(). ~n"),
	io:format("      server_tool:print_tool().~n"),
	io:format("      lists:foreach(fun(N)-> rpc:call(N,c,l,[Module]) end ,nodes()).~n"),
	io:format("      whiteip:add_ip({A,B,C,D}).~n"),
	io:format("      etc:  L=binary_to_list(unicode:characters_to_binary(\"XX\")).~n"),
	io:format("		 rpc:call(node_util:get_mapnode(),role_pos_db,get_all_rolepos,[]).~n"),
	io:format("      rpc:call(node_util:get_dbnode(),data_gen,backup_ext,[dbfilename]).~n"),
	io:format("      rpc:call(node_util:get_dbnode(),data_gen,import_config,[\"game\"]).~n").
	
print_tool(N)->
	MapNodes = node_util:get_mapnodes(),
	case MapNodes of
		[]-> case N of 
				 0-> io:format("can not get the map nodes~n");
				 _-> timer:sleep(1000),print_tool(N-1)
			 end;
		[MapNode|_]-> 
			DbNode = node_util:get_dbnode(),
			print_tool(MapNode,DbNode)
	end.

%%------------------------------------------------------------------------------------------
%% for tools 
%%------------------------------------------------------------------------------------------
