%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-8-6
%%% -------------------------------------------------------------------
-module(instanceid_generator).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(MAX_ID,100000).
%% --------------------------------------------------------------------
%% External exports
-export([start_link/1,get_procname/1,turnback_proc/1,safe_turnback_proc/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {serverid,curindex}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link(ServerId)->
	gen_server:start({local,?MODULE}, ?MODULE, [ServerId], []).

%% ====================================================================
%% Server functions
%% ====================================================================
get_procname(InstanceId)->
	try
		global_util:call(?MODULE, {gen_newproc,InstanceId})
	catch
		E:R->slogger:msg("instanceid_generator get_procname error ~p ~p~n ",[E,R]),
		[]	 
	end.

safe_turnback_proc(Proc)->
	server_travels_util:cast_for_all_server_with_self_if_share_node(?MODULE,turnback_proc,[Proc]).
  
turnback_proc(Proc)->
	global_util:send(?MODULE, {back_proc,Proc}).
%%	gen_server:cast({global,?MODULE}, {back_proc,Proc}).
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([ServerId]) ->
	put(using_proc,[]),
	put(instanceid_to_proc,[]),
    {ok, #state{serverid=ServerId,curindex=0}}.

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
handle_call({gen_newproc,InstanceId}, _From, 
			#state{serverid=ServerId,curindex=CurIndex}=_State) ->
	RegistRe = lists:keyfind(InstanceId,1, get(instanceid_to_proc) ),
	if
		(InstanceId=:=[]) or (RegistRe=:=false) ->
			case get_proc_by_max(CurIndex,ServerId) of
				[]->
					NewIndexId = CurIndex,
					Reply = [];
				{NewIndexId,Proc}->	
					put(using_proc,[Proc|get(using_proc)]),
					if
						InstanceId=/=[]->
							put(instanceid_to_proc,[{InstanceId,Proc}|get(instanceid_to_proc)]);
						true->
							nothing
					end,
					Reply = Proc
			end;
		true->	%% already exsit!!!
			{_,Proc} = RegistRe,
			NewIndexId = CurIndex,
			Reply = {exsit,Proc} 
	end,
    {reply,Reply, #state{serverid=ServerId,curindex=NewIndexId}};

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

handle_info({back_proc,Proc}, State) ->
	put(using_proc,lists:delete(Proc, get(using_proc))),
	put(instanceid_to_proc,lists:keydelete(Proc, 2, get(instanceid_to_proc))), 
    {noreply, State};

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

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
get_proc_by_max(CurIndex,ServerId)->
	if
		CurIndex > ?MAX_ID->
			GenId = 0;
		true->
			GenId = CurIndex+1
	end,
	Proc = list_to_atom("instance_"++integer_to_list(ServerId)++"_"++integer_to_list(GenId)),
	case lists:member(Proc, get(using_proc)) of 
		true->			%%normally should not here.
			case erlang:length(get(using_proc)) > ?MAX_ID of
				true->
					slogger:msg("instanceid_generator error! more than MAX_ID~n"),
					[];
				false->	
					get_proc_by_max(GenId+1,ServerId)
			end;
		_->
			{GenId,Proc}
	end.



					