%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(battle_ground_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/0,start_child/2,stop_child/1]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 init/1,
	 make_battle_proc_name/2
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

start_child(BattleType,BattleInfo)->	
	ProcName = make_battle_proc_name(BattleType,BattleInfo),
	try
		AChild = {ProcName ,{battle_ground_processor,start_link,[ProcName,BattleType,BattleInfo]},
				  	      		transient,2000,worker,[battle_ground_processor]},
		supervisor:start_child(?MODULE, AChild)
	catch
		E:R-> io:format("can not start battle_ground(~p:~p) ~p ~p ~p~n",[E,R,ProcName,BattleType,BattleInfo]),
			  {error,R}
 	end.

stop_child(ProcName)->
	supervisor:terminate_child(?MODULE, ProcName),
	supervisor:delete_child(?MODULE, ProcName).
%% ====================================================================
%% Internal functions
%% ====================================================================
make_battle_proc_name(tangle_battle,BattleInfo)->
	{Class,Num} = BattleInfo,
	BattleProc = lists:append(["tangle_battle_",integer_to_list(Class),"_",integer_to_list(Num)]),
	list_to_atom(BattleProc);

make_battle_proc_name(yhzq_battle,BattleInfo)->
	{_,{GuildHA,GuildLA},{GuildHB,GuildLB}} = BattleInfo,
	BattleProc = lists:append(["yhzq_",integer_to_list(GuildHA),integer_to_list(GuildLA),integer_to_list(GuildHB),integer_to_list(GuildLB)]),
	list_to_atom(BattleProc);

make_battle_proc_name(jszd_battle,BattleInfo)->
	{BattleProc,_,_,_} = BattleInfo,
	BattleProc.
	

	
	
