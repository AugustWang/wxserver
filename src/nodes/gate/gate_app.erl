%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-4-2
%% Description: TODO: Add description to gate_network
-module(gate_app).

-behaviour(application).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("reloader.hrl").

%% --------------------------------------------------------------------
%% Behavioural exports
%% --------------------------------------------------------------------
-export([
	 start/2,
	 stop/1
        ]).

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start/0,tcp_listener_started/2,tcp_listener_stopped/2,start_client/2]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% API Functions
%% --------------------------------------------------------------------


%% ====================================================================!
%% External functions
%% ====================================================================!
%% --------------------------------------------------------------------
%% Func: start/2
%% Returns: {ok, Pid}        |
%%          {ok, Pid, State} |
%%          {error, Reason}
%% --------------------------------------------------------------------
start(_Type, _StartArgs) ->
	%gs_prof:support(),
	case util:get_argument('-line') of
		[]->  slogger:msg("Missing --line argument input the nodename");
		[CenterNode|_]->
			filelib:ensure_dir("../log/"),
			FileName = "../log/"++atom_to_list(node_util:get_node_sname(node())) ++ "_node.log", 
			error_logger:logfile({open, FileName}),
			?RELOADER_RUN,	
			ping_center:wait_all_nodes_connect(),
			db_tools:wait_line_db(),
			case server_travels_util:is_share_server() of
				false->
					travel_deamon_sup:start_link();
				true->
					nothing
			end,
			global_util:global_proc_wait(),
			timer_center:start_at_app(),
			applicationex:wait_ets_init(),
			statistics_sup:start_link(),
			boot_client_sup(),
			boot_listener_sup(),
			{ok, self()}
	end.

start()->
	applicationex:start(?MODULE).

boot_listener_sup() ->	
	%%SName = node_util:get_node_sname(node()),
	SName = node_util:get_match_snode(gate,node()),
	Port = env:get2(gateport, SName, 0),
	case Port of
		0-> slogger:msg("start gate error ,can not find listen port~n"),error;
		Port->
			AcceptorCount = env:get2(gate,acceptor_count,1),
			OnStartup = {?MODULE,tcp_listener_started,[]},
			OnShutdown = {?MODULE,tcp_listener_stopped,[]},
			AcceptCallback={?MODULE,start_client,[]},
			case tcp_listener_sup:start_link(Port ,OnStartup, OnShutdown, AcceptCallback,AcceptorCount) of
				{ok, Pid} ->
					{ok, Pid};
				Error ->
					Error
			end
	end.

boot_client_sup() ->
	Client_Plugin = socket_callback:get_client_mod(),
	tcp_client_sup:start_link(Client_Plugin).


%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(_State) ->
	ok.
%% --------------------------------------------------------------------
%% Func: tcp_listen_start/2
%% Returns: any
%% --------------------------------------------------------------------
tcp_listener_started(IPAddress, Port) ->
	slogger:msg("Game Gate Started at ~p : ~p\n", [IPAddress, Port]).


tcp_listener_stopped(IPAddress, Port) ->
	slogger:msg("Game Gate Stopped at ~p : ~p\n", [IPAddress, Port]).

start_client(Sock,Pid)->
	slogger:msg("start one client process pid = ~p sock = ~p\n",[Pid,Sock]).

%% ====================================================================
%% Internal functions
%% ====================================================================
