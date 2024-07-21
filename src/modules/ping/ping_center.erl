%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-4-15
%% Description: TODO: Add description to ping_center
-module(ping_center).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([wait_all_nodes_connect/0,ping/1,wait_node_connect/1]).

%%
%% API Functions
%%
wait_all_nodes_connect()->
	AllNodes = env:get(pre_connect_nodes,[]),
	wait_nodes(AllNodes).

wait_node_connect(Type)->
	NeedConNodes = lists:filter(fun(Node)-> node_util:check_snode_match(Type,Node) end, env:get(pre_connect_nodes,[])),
	wait_nodes(NeedConNodes).
	
wait_nodes(AllNodes)->
	slogger:msg("need wait nodes ~p ~n",[AllNodes]),
	lists:foreach(fun(Node)-> 
		slogger:msg("ping Node ~p ~n",[Node]),				  
		ping(Node) end,AllNodes).			
	
ping(Node)->	
	ping_loop(Node).

ping_loop(Node)->
	case net_adm:ping(Node) of
		pong -> ok;
		_->
			receive 
			after
					1000 -> ping_loop(Node)
			end
	end.
		
	
%%
%% Local Functions
%%

