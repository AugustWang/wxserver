%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : pg2_ex.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 23 Apr 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(pg2_ex).

-export([create/1, delete/1, join/2, leave/2]).
-export([get_members/1]).
-export([which_groups/0]).
-export([start/0,start_link/0,init/1,handle_call/3,handle_info/2,terminate/2, handle_cast/2]).

-record(state, {links = [] :: [pid()]}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

start() ->
    ensure_started().

create(Name) ->
    ensure_started(),
    case ets:lookup(pg2_ex_table, {local_members, Name}) of
	[] ->
	    gen_server:call({?MODULE, node()}, {create, Name});
	_ ->
	    ok
    end,
    ok.

delete(Name) ->
    ensure_started(),
    gen_server:call({?MODULE, node()}, {delete, Name}),
    ok.

join(Name, Pid) when is_pid(Pid) ->
    ensure_started(),
    case ets:lookup(pg2_ex_table, {local_members, Name}) of
	[] ->
	    {error, {no_such_group, Name}};
	_ ->
	    gen_server:cast({?MODULE, node()}, {join, Name, Pid}),
	    ok
    end.

leave(Name, Pid) when is_pid(Pid) ->
    ensure_started(),
    case ets:lookup(pg2_ex_table, {local_members, Name}) of
        [] ->
            {error, {no_such_group, Name}};
        _ ->
	    gen_server:cast({?MODULE, node()}, {leave, Name, Pid}),
            ok
    end.

get_members(Name) ->
    ensure_started(),
    case ets:lookup(pg2_ex_table, {local_members, Name}) of
	[{_, Members}] -> Members;
	[] -> {error, {no_such_group, Name}}
    end.

which_groups() ->
    ensure_started(),
    ets:filter(pg2_ex_table,
	       fun([{{local_members, Group}, _}]) ->
		       {true, Group};
		  (_) ->
		       false
	       end,
	       []).

%%%-----------------------------------------------------------------
%%% Callback functions from gen_server
%%%-----------------------------------------------------------------
-spec init([]) -> {'ok', #state{}}.
init([]) ->
    process_flag(trap_exit, true),
    %% pg2_ex_table keeps track of all members in a group
    ets:new(pg2_ex_table, [set, protected, named_table]),
    {ok, #state{}}.

handle_cast({join, Name, Pid}, S) ->
    case ets:lookup(pg2_ex_table, {local_members, Name}) of
	[{_, LocalMembers}] ->
	    NewLinks =
		if
		    node(Pid) =:= node() ->
			link(Pid),
			ets:insert(pg2_ex_table, {{local_members, Name}, [Pid | LocalMembers]}), [Pid | S#state.links];
		    true ->
			S#state.links
		end,
		    {noreply, S#state{links = NewLinks}};
	[] ->
		    {noreply, S}
    end;

handle_cast({leave, Name, Pid}, S) ->
    case ets:lookup(pg2_ex_table, {local_members, Name}) of
        [{_, LocalMembers}] ->
            ets:insert(pg2_ex_table, {{members, Name}, lists:delete(Pid,LocalMembers)}),
            NewLinks =
                if
                    node(Pid) =:= node() ->
                        case lists:member(Pid, LocalMembers) of
                            true ->
                                ets:insert(pg2_ex_table, {{local_members, Name}, 
							  lists:delete(Pid, LocalMembers)}), NLinks = lists:delete(Pid, S#state.links),
                                case lists:member(Pid, NLinks) of
                                    true -> ok;
                                    false -> unlink(Pid)
                                end,
                                NLinks;
                            false ->
                                S#state.links
                        end;
                    true ->
                        S#state.links
                end,
		    {noreply, S#state{links = NewLinks}};
        [] ->
		    {noreply, S}
    end;

handle_cast(Msg, State) ->
	{noreply, State}.

handle_call({create, Name}, _From, S) ->
    case ets:lookup(pg2_ex_table, {local_members, Name}) of
	[] ->
	    ets:insert(pg2_ex_table, {{local_members, Name}, []});
	_ ->
	    ok
    end,
    {reply, ok, S};

handle_call({delete, Name}, _From, S) ->
    ets:delete(pg2_ex_table, {local_members, Name}),
    {reply, ok, S}.

handle_info({'EXIT', Pid, _}, S) ->
    del_members(ets:match(pg2_ex_table, {{local_members, '$1'}, '$2'}), Pid),
    NewLinks = delete(S#state.links, Pid),
    {noreply, S#state{links = NewLinks}}.

terminate(_Reason, S) ->
    ets:delete(pg2_ex_table),
    lists:foreach(fun(Pid) -> unlink(Pid) end, S#state.links).

%%%-----------------------------------------------------------------
%%% Internal functions
%%%-----------------------------------------------------------------

%% Delete member Pid from all groups
del_members([[Name, Pids] | T], Pid) ->
    lists:foreach(
      fun(Pid2) when Pid =:= Pid2 ->
	      del_member(local_members, Name, Pid),
	      gen_server:abcast(nodes(), ?MODULE, {del_member, Name, Pid});
	 (_) -> ok
      end, Pids),
    del_members(T, Pid);
del_members([],_Pid) -> ok.

del_member(KeyTag, Name, Pid) ->
    [{_, Members}] = ets:lookup(pg2_ex_table, {KeyTag, Name}),
    ets:insert(pg2_ex_table, {{KeyTag, Name}, delete(Members, Pid)}).

%% delete _all_ occurences of X in list
delete([X | T], X) -> delete(T, X);
delete([H | T], X) -> [H | delete(T, X)];
delete([], _) -> [].

union(L1, L2) ->
    (L1 -- L2) ++ L2.

ensure_started() ->
    case whereis(?MODULE) of
	undefined ->
	    C = {pg2, {?MODULE, start_link, []}, permanent,
		 1000, worker, [?MODULE]},
	    supervisor:start_child(kernel_safe_sup, C);
	Pg2Pid ->
	    {ok, Pg2Pid}
    end.
