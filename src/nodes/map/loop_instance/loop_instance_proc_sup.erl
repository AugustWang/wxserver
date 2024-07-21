%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-1-10
%% Description: TODO: Add description to loop_instance_proc_sup
-module(loop_instance_proc_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/0,start_child/4,stop_child/1]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 init/1
        ]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------
-define(SERVER, ?MODULE).

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	supervisor:start_link({local,?MODULE}, ?MODULE, []).


%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%% --------------------------------------------------------------------
init([]) ->
    {ok,{{one_for_one,10,10}, []}}.

start_child(ProcName,GroupId,Type,InstanceInfo)->	
	try
		AChild = {ProcName ,{loop_instance_proc,start_link,[ProcName,GroupId,Type,InstanceInfo]},
				  	      		transient,2000,worker,[loop_instance_proc]},
		supervisor:start_child(?MODULE, AChild)
	catch
		E:R-> io:format("can not start loop_instance(E:~p: R:~p) ~p ~p ~p ~p~n",[E,R,ProcName,GroupId,Type,InstanceInfo]),
			  {error,R}
 	end.

stop_child(ProcName)->
	supervisor:terminate_child(?MODULE, ProcName),
	supervisor:delete_child(?MODULE, ProcName).
%% ====================================================================
%% Internal functions
%% ====================================================================

