%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-5-26
%%% -------------------------------------------------------------------
-module(npc_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/3]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 init/1,
	 add_npc/6,
	 delete_npc/2,
	 remove_all_npc/1	
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

start_link(MapId,MapProc,NpcInfoEts)->
	NpcSup = make_npc_sup_name(MapProc),
	supervisor:start_link({local,NpcSup}, ?MODULE, [MapId,MapProc,NpcInfoEts,NpcSup]).

add_npc(SupRef,MapProc,NpcId,ManagerPid,Option,CreateArg)->
	ChildSpec= {NpcId,{npc_processor,start_link,[MapProc,NpcId,ManagerPid,Option,CreateArg]},
			    permanent, 2000, worker,[npc_processor]},
		supervisor:start_child(SupRef, ChildSpec).

delete_npc(SupRef,NpcId)->
	case supervisor:terminate_child(SupRef , NpcId) of
		ok ->
			ok;
		{error, not_found}->
			nothing;	
		{error, Reason1} ->
			slogger:msg("npc_sup :delete_npc :error:~p~n", [Reason1])
	end,   
	case supervisor:delete_child(SupRef, NpcId) of
		ok ->
			ok;
		{error, not_found}->
			nothing;
		{error, Reason2} ->
			slogger:msg("npc_sup :delete_npc :error:~p~n", [Reason2])
	end.

remove_all_npc(SupRef)->
	lists:foreach(fun({ChildKey,_,_,[ProcModule]})->
	 	if
	 		ProcModule=:=npc_processor->
				delete_npc(SupRef,ChildKey);
			true->
				nothing
		end
	end,supervisor:which_children(SupRef)).

%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%% --------------------------------------------------------------------
init([MapId,MapProc,NpcInfoEts,NpcSup]) ->
	ManagerSpec ={MapProc,
		      {npc_manager,start_link,[MapId,NpcInfoEts,MapProc,NpcSup]},permanent,2000,worker,[npc_manager]}, 
	{ok,{{one_for_one,60,1}, [ManagerSpec]}}.

%% ====================================================================
%% Internal functions
%% ====================================================================

make_npc_sup_name(MapProcName)->
	Name = lists:append(["npc_sup_",atom_to_list(MapProcName)]),
	list_to_atom(Name).
