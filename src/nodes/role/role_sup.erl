%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-11
%%% -------------------------------------------------------------------
-module(role_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(ROLES_DB,local_roles_datatbase).
-define(PETS_DB,local_pets_datatbase).
%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_role/2,stop_role/2,start_link/0]).

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
	supervisor:start_link({local,?SERVER}, ?MODULE, []).

start_role(RoleDB,RoleId) ->
	slogger:msg("role_sup:start_role:~p~n", [RoleId]),
	ChildSpec= {RoleId,{role_processor,start_link,[RoleDB,RoleId]},
		    temporary, 2000, worker,[role_processor]},
	supervisor:start_child(?SERVER, ChildSpec).

stop_role(RoleSupNode, RoleId)->
	supervisor:terminate_child({?SERVER,RoleSupNode} , RoleId),
	supervisor:delete_child({?SERVER, RoleSupNode}, RoleId).

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
	%% {RoleId,RoleProc,GateNode,GateProc,MapProc,Coord} 
	ets:new(?ROLES_DB, [set,public,named_table]),
	ets:new(?PETS_DB, [set,public,named_table]),
	
	ManagerSpec ={role_manager,{role_manager,start_link,[?ROLES_DB]},permanent,2000,worker,[role_manager]}, 
	{ok,{{one_for_one,10,10}, [ManagerSpec]}}.

%% ====================================================================
%% Internal functions
%% ====================================================================
