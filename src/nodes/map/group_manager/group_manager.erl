%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : MacX
%%% Description :
%%%
%%% Created : 2011-3-28
%%% -------------------------------------------------------------------
-module(group_manager).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([apply_deposit_group/1,get_from_deposit_group/2]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?MODULE},?MODULE,[],[]).

%% ====================================================================
%% Server functions
%% ====================================================================\
%%return:ok/error
apply_deposit_group(GroupId)->
	try
		global_util:call(?MODULE,{apply_deposit_group,GroupId})
	catch
		E:R->
			slogger:msg("apply_up_stall error ~p ~p ~n ",[E,R]),
			error
	end.

%%return:error/GroupInfo
get_from_deposit_group(GroupId,RoleId)->
	try
		global_util:call(?MODULE,{get_from_deposit_group,GroupId,RoleId})
	catch
		E:R->
			slogger:msg("apply_up_stall error ~p ~p ~n ",[E,R]),
			error
	end.
	
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	try
		timer_center:start_at_process(),
		group_manager_op:init()
	catch
		E:R ->slogger:msg("group_manager_op init error ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()])
	end,
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
handle_call({apply_deposit_group,GroupId}, _From, State) ->
	Reply = my_apply(group_manager_op,apply_deposit_group,[GroupId]),
    {reply, Reply, State};

handle_call({get_from_deposit_group,GroupId,RoleId}, _From, State) ->
	Reply = my_apply(group_manager_op,get_from_deposit_group,[GroupId,RoleId]),
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

handle_info(over_due_check, State) ->
	my_apply(group_manager_op,over_due_check,[]),
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
my_apply(Module,Fun,Args)->
	try
		erlang:apply(Module,Fun,Args)
	catch
		E:R->
			slogger:msg("apply ~p ~p ~p ~p, ~p ~p ~n",[Module,Fun,Args,erlang:get_stacktrace(),E,R]),
			error
	end.
