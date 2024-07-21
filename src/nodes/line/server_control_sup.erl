%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhang
%% Created: 2011-1-21
%% Description: TODO: Add description to server_control_sup
-module(server_control_sup).
-behaviour(supervisor).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([start_link/0]).
-export([init/1]).

%%
%% API Functions
%%
start_link() ->
		supervisor:start_link({local, ?MODULE}, ?MODULE, []).


%%====================================================================
%% Supervisor callbacks
%%====================================================================
%%--------------------------------------------------------------------
%% Func: init(Args) -> {ok,  {SupFlags,  [ChildSpec]}} |
%%                     ignore                          |
%%                     {error, Reason}
%% Description: Whenever a supervisor is started using 
%% supervisor:start_link/[2,3], this function is called by the new process 
%% to find out about restart strategy, maximum restart frequency and child 
%% specifications.
%%--------------------------------------------------------------------
init([]) ->
	Server_Control = {server_control,{server_control,start_link,[]},
	       permanent,2000,worker,[server_control]},
	{ok,{{one_for_one, 10, 10}, [Server_Control]}}.

%%
%% Local Functions
%%

