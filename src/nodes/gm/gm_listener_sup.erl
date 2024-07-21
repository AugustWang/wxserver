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
-module(gm_listener_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/4,start_link/5]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 init/1
        ]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================
start_link(Port, OnStartup, OnShutdown, AcceptCallback) ->
    start_link( Port, OnStartup, OnShutdown, AcceptCallback, 1).

start_link(Port, OnStartup, OnShutdown, AcceptCallback, AcceptorCount) ->
    supervisor:start_link({local,?MODULE},?MODULE, {Port, OnStartup, OnShutdown,
									AcceptCallback, AcceptorCount}).



%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%% --------------------------------------------------------------------
init({ Port, OnStartup, OnShutdown, AcceptCallback, AcceptorCount}) ->
    %% This is gross. The gm_listener needs to know about the
    %% gm_acceptor_sup, and the only way I can think of accomplishing
    %% that without jumping through hoops is to register the
    %% gm_acceptor_sup.
	
	
	{ok, {{one_for_all, 10, 10},
          [{gm_acceptor_sup, 
				{gm_acceptor_sup, start_link,
				 [AcceptCallback]},
			    transient, infinity, supervisor, [gm_acceptor_sup]},
		   {gm_listener, {gm_listener, start_link,
				[Port,  AcceptorCount, OnStartup, OnShutdown]},
			    transient, 100, worker, [gm_listener]}
		  ]}}.

%% ====================================================================
%% Internal functions
%% ====================================================================

