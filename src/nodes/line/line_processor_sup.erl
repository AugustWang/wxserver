%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%%-------------------------------------------------------------------
%%% File    : lineproc_sup.erl
%%% Author  : tengjiaozhao
%%% Description : 
%%%
%%% Created : 15 Apr 2010 by tengjiaozhao
%%%-------------------------------------------------------------------
-module(line_processor_sup).

-behaviour(supervisor).

-define(MAP_PROC_DB, map_proc_db).
%% API
-export([
	 start_link/0,
	 add_line/1,
	 delete_line/1
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
	ets:new(?MAP_PROC_DB, [set, public, named_table]),
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
init([]) ->
	{ok,{{one_for_one, 10, 10}, []}}.

%%====================================================================
%% Internal functions
%%====================================================================
add_line({LineName, From}) ->
	supervisor:start_child(?MODULE, {LineName, {line_processor, start_link, [{LineName, From}]},
					 permanent, 2000, worker, [line_processor]}).

delete_line(LineName) ->
	supervisor:terminate_child(?MODULE, LineName),
	supervisor:delete_child(?MODULE, LineName).
