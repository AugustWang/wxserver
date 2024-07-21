%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : SQ.Wang
%%% Description :
%%%
%%% Created : 2012-1-13
%%% -------------------------------------------------------------------
-module(guild_instance_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/0,start_child/2,stop_child/1,make_proc_name/2]).

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
start_link() ->
	supervisor:start_link({local,?MODULE},?MODULE, []).


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
    {ok,{{one_for_all,0,1}, []}}.

%% ====================================================================
%% Internal functions
%% ====================================================================
start_child(Type,Info)->	
	ProcName = make_proc_name(Type,Info),
	try
		AChild = {ProcName ,{guild_instance_manager,start_link,[ProcName,Type,Info]},
				  	      		transient,2000,worker,[guild_instance_manager]},
		supervisor:start_child(?MODULE, AChild)
	catch
		E:R-> io:format("can not guild_instance(~p:~p) ~p ~p ~p~n",[E,R,ProcName,Type,Info]),
			  {error,R}
 	end.

stop_child(ProcName)->
	supervisor:terminate_child(?MODULE, ProcName),
	supervisor:delete_child(?MODULE, ProcName).

make_proc_name(Type,Info)->
	{InstanceId,{LId,HId}} = Info,
	ProcName = lists:append([atom_to_list(Type),"_",integer_to_list(InstanceId),"_",integer_to_list(LId),"_",integer_to_list(HId)]),
	list_to_atom(ProcName).
