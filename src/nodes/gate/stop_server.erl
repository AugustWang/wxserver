%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-5-3
%% Description: TODO: Add description to stop_server
-module(stop_server).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([stop_server_process/0,kick_client_all/1,stop_authornode/1,
			stop_guildnode/1,stop_gmnode/1,stop_chatnode/1,stop_timernode/1,stop_crossdomainnode/1,stop_linenode/1,stop_dbnode/1,stop_map2node/1]).

%%
%% API Functions
%%



%%
%% Local Functions
%%
stop_server_process()->
	 tcp_listener:disable_connect(),%%璇锋眰鎷掔粷
	[MapNode|_]=node_util:get_mapnodes(),
	rpc:call(MapNode, ?MODULE, kick_client_all, [{gm_kick_you}]),

	[Map2Node]=node_util:get_mapnodes(),
	rpc:call(Map2Node, ?MODULE, stop_map2node, [stop_map2node]),

	 
CrossNode=node_util:get_crossnode(),
	 rpc:call(CrossNode, ?MODULE, stop_crossdomainnode, [crossnode_stop]),

	[Author]=node_util:get_authnodes(),
	 rpc:call(Author, ?MODULE, stop_authornode, [authornode_stop]),
	 
	 [GuildNode]=node_util:get_guilnodes(),
	 rpc:call(GuildNode, ?MODULE, stop_guildnode, [guildnode_stop]),
	 
	 [Gmnode]=node_util:get_gmnodes(),
	 rpc:call(Gmnode, ?MODULE, stop_gmnode, [gmnode_stop]),
	 
	 [Chatnode]=node_util:get_chatnodes(),
	 rpc:call(Chatnode, ?MODULE, stop_chatnode, [chatnode_stop]),

	 [TimerNode]=node_util:get_timernodes(),
	 rpc:call(TimerNode, ?MODULE, stop_timernode, [timernode_stop]),
	
	
	[LineNode]=node_util:get_linenodes(),
	rpc:call(LineNode, ?MODULE, stop_linenode, [linenode_stop]),

	 Dbnode=node_util:get_dbnode(),
	 rpc:call(Dbnode, ?MODULE, stop_dbnode, [dbnode_stop]),

	application:stop(gate_app),
	erlang:halt().
	


kick_client_all(Message)->
	role_pos_util:send_to_all_online_clinet(Message),
	application:stop(map_app),
	erlang:halt().

stop_map2node(Message)->
	erlang:halt().

stop_dbnode(Message)->
	application:stop(dbmaster),
	application:stop(dbslave),
	erlang:halt().

stop_chatnode(Message)->
	application:stop(chat_app),
	erlang:halt().

stop_guildnode(Message)->
	application:stop(guild_app),
	erlang:halt().

stop_linenode(Message)->
	application:stop(line),
	erlang:halt().

stop_authornode(Message)->
	application:stop(auth_app),
	erlang:halt().

stop_crossdomainnode(Message)->
	application:stop(crossdomain_app),
	erlang:halt().

stop_gmnode(Message)->
	application:stop(gm_app),
	erlang:halt().

stop_timernode(Message)->
	application:stop(timer_center),
	erlang:halt().



	
	
