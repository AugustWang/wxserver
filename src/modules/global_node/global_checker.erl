%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(global_checker).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(CHECK_FIRSTINTERVAL,1000).
%% --------------------------------------------------------------------
%% External exports
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


-export([is_ready/0]).
  
-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

is_ready()->
	try
		gen_server:call(?MODULE, is_global_ready)
	catch
		_:_->false
	end.
%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	put(global_ready,false),
	do_wait(),
    {ok, #state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(is_global_ready, From, State) ->
	Reply = get(global_ready),
	{reply, Reply, State};
handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info( {check_global},State)->
	 do_wait(),
	{noreply,State};

handle_info({stop}, State) ->
	{stop,normal,State};
 
handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.

do_wait()->
	case env:get(global_wait,[]) of
		 []->
			wait_stop();
		 WaitList->
			 WaitAll = 
			 lists:foldl( fun({NodeKey,MyWaitList},Re)->
					if
						not Re->
							Re;
						true->
							case node_util:check_snode_match(NodeKey, node()) of
								false->
									Re;
								true->
									is_all_node_waite_finish(MyWaitList)
							end
					end
				end,true,WaitList),
			 if
				 WaitAll->
					 wait_stop();
				 true->
					 erlang:send_after(?CHECK_FIRSTINTERVAL, self(), {check_global})
			 end
	 end.


wait_stop()->
	put(global_ready,true),
	self() ! {stop},
	slogger:msg("global_wait finished ~n").

is_all_node_waite_finish(MyWaitList)->
	StillNotWaitedList = lists:filter(fun(ModuleName)-> not global_node:is_in_global(ModuleName) end, MyWaitList),
	if
		StillNotWaitedList=:=[]->
			true;			%%wait finish
		true->
			AllNodes = node_util:get_all_nodes_for_global(),
			lists:foreach(fun(ProcNotWaited)-> wait_global_proc(ProcNotWaited,AllNodes) end, StillNotWaitedList),
			false
	end.

wait_global_proc(ProcNotWaited,AllNodes)->
	MatchNodes = lists:filter(fun(CurNode)->
		node_util:check_snode_match(ProcNotWaited, CurNode)				 
	end, AllNodes),
	case MatchNodes of
		[]->
			nothing;
		[MatchNode|_T]->
			global_node:regist_global_proc(ProcNotWaited,MatchNode)
	end.
