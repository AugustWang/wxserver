%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-2
%%% -------------------------------------------------------------------
-module(tcp_listener).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("network_setting.hrl").
-define(ACCEPTOR_PROC_ETS,'$ets_acceptor_proc$').

-ifdef(debug).
	-define(OPEN_GATE_TIME,10*1000).		%%debug  time is short
	-define(OPEN_GATE_DOOR,enable_connect()).
-else.
	-define(OPEN_GATE_DOOR,disable_connect()).
	-define(OPEN_GATE_TIME,60*2*1000).	%%10min
-endif.
%% --------------------------------------------------------------------
%% Define macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/4]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([disable_connect/0,enable_connect/0]).

-export([query_port/0]).

-record(state, {listen_socket, 	%% listen socket
				on_startup,	
				on_shutdown,
				acceptors}).

%% ====================================================================
%% External functions
%% OnAccept : {M,F} ,M : Module; F: F(Pid,Socket)
%% ====================================================================
start_link(Port, AcceptorCount ,
		   OnStartup, OnShutdown) ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, 
						  {Port, AcceptorCount  ,
						   OnStartup, OnShutdown}, []).

%% ====================================================================
%% Server functions
%% ====================================================================
query_port()->
	gen_server:call(?MODULE, {query_port} ,infinity).


%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init({Port,AcceptorCount,{M,F,A} = OnStartup, OnShutdown}) ->
	process_flag(trap_exit, true),
	Opts = ?TCP_OPTIONS,
	case gen_tcp:listen(Port, Opts) of
		{ok, Listen_socket} ->
			 SeqList = lists:seq(1, AcceptorCount),
			 Fun = fun(AccIndex,Acc)->
						   {ok, _APid} = supervisor:start_child(tcp_acceptor_sup, [Listen_socket,AccIndex]),
						   
						   AcceptorName = tcp_acceptor:get_proc_name(AccIndex),
%%@@ 						   ?OPEN_GATE_DOOR,
%%@@ 						   erlang:send_after(?OPEN_GATE_TIME,?MODULE,{enable_connect}),
                           erlang:send_after(0,?MODULE,{enable_connect}),
						   [AcceptorName|Acc]
				   end,
             AccProcs = lists:foldl(Fun,[],SeqList),
			apply(M,F,A ++ [Listen_socket,Port]),
			
			{ok, #state{listen_socket = Listen_socket,
                        on_startup = OnStartup, on_shutdown = OnShutdown,
						acceptors=AccProcs}};
	
		{error, Reason} ->
			{stop, Reason}
end.

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
handle_call(reset_opt, _From, #state{listen_socket = Listen_socket} = State) ->
	inet:setopts(Listen_socket,[{packet, 0}]),
	slogger:msg("inet:getopts active,packet ~p ~n",[inet:getopts(Listen_socket, [active,packet])]),
    Reply = ok,
    {reply, Reply, State};
handle_call({query_port}, _From, #state{listen_socket = LSock} = State) ->
	 {ok, {_IPAddress, Port}} = inet:sockname(LSock),
    Reply = Port,
    {reply, Reply, State};
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({disable_connect}, State = #state{acceptors=AccProcs}) ->
%%	io:format("handle_info disable_connect ~p ~n",[?MODULE]),
	lists:foreach(fun(AcceptorName)->
						  R = tcp_acceptor:disable_connect(AcceptorName),
						  io:format("Acceptor Stat:~p~n",[R])
				  end, AccProcs),
    {noreply, State};

handle_info({enable_connect},State = #state{acceptors=AccProcs})->
	lists:foreach(fun(AcceptorName)->
						  R = tcp_acceptor:enable_connect(AcceptorName),
						  io:format("Acceptor Stat:~p~n",[R])
				  end, AccProcs),
	{noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, #state{listen_socket=LSock, on_shutdown = {M,F,A}}) ->
    {ok, {_IPAddress, Port}} = inet:sockname(LSock),
    gen_tcp:close(LSock),
    apply(M, F, A ++ [LSock, Port]).

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%--------------------------------------------------------------------
%% Function: disable_connect/0
%% Description: disable gate connect
%% Returns: any (ignored by gen_server)
%%--------------------------------------------------------------------
disable_connect()->
	%%gen_server:send({local, ?MODULE}, {disable_connect}).
%%	io:format("disable_connect ~p ~n",[?MODULE]),
	erlang:send_after(0,?MODULE,{disable_connect}).

%%--------------------------------------------------------------------
%% Function: enable_connnect/0
%% Description: enable gate connect
%% Returns: any (ignored by gen_server)
%%--------------------------------------------------------------------
enable_connect()->
	%%gen_server:send({local, ?MODULE}, {enable_connect}).
	erlang:send_after(0,?MODULE,{enable_connect}).
%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

