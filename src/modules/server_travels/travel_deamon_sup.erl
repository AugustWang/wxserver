%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%%-------------------------------------------------------------------
%%% File    : guildid_generator_sup.erl
%%% Author  : adrianx.lau
%%% Description : 
%%%
%%%-------------------------------------------------------------------
-module(travel_deamon_sup).

-behaviour(supervisor).

%% API
-export([
	 start_link/0
	]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================
%%--------------------------------------------------------------------
%% Function: start_link() -> {ok,Pid} | ignore | {error,Error}
%% Description: Starts the supervisor
%%--------------------------------------------------------------------
start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).
			
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
init(_) ->
  GuildIdConfig = {travel_deamon_processor,{travel_deamon_processor,start_link,[]},
	       transient,2000,worker,[travel_deamon_processor]},
	{ok,{{one_for_one, 10, 10}, [GuildIdConfig]}}.

%%====================================================================
%% Internal functions
%%====================================================================
