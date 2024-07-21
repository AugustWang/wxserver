%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-1-4
%% Description: TODO: Add description to loop_instance
-module(loop_instance_mgr).
-behaviour(gen_server).
%%
%% Include files
%%

%%
%% Exported Functions
%%
%% External exports
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-compile(export_all).

%%
%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: start_link/1
%% Description: start server
%% --------------------------------------------------------------------
start_link()->
	slogger:msg("~p start~n",[?MODULE]),
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).
	
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init(_Args) ->	
    slogger:msg("~p init~n",[?MODULE]),
	try    
		timer_center:start_at_process(),
		loop_instance_mgr_op:init()
	catch
		E:R->
			slogger:msg("init E:~p R:~p S:~p \n",[E,R,erlang:get_stacktrace()])
	end,
	{ok, []}.

%%
%%call
%%

%%
%%return {ok,node,proc}|{error,reason}
%%
start_loop_instance(GroupId,Type,CreatorInfo)->
	try
		global_util:call(?MODULE,{start_loop_instance,{GroupId,Type,CreatorInfo}})
	catch
		E:R->
			slogger:msg("~p start loop instance E:~p R:~p ~n",[?MODULE,E,R]),
			{error,R}
	end.

check_loop_instance(GroupId,Type)->
	try
		global_util:call(?MODULE,{check_loop_instance,{GroupId,Type}})
	catch
		E:R->
			slogger:msg("~p check loop instance E:~p R:~p ~n",[?MODULE,E,R]),
			{error,R}
	end.
	
%%
%%cast
%%

%%
%%send
%%
stop_loop_instance(GroupId,Type,Node,ProcName)->
	try
		global_util:send(?MODULE,{stop_loop_instance,{GroupId,Type,Node,ProcName}})
	catch
		E:R->
			slogger:msg("~p stop loop instance E:~p R:~p ~n",[?MODULE,E,R]),
			{error,R}
	end.

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
handle_call({start_loop_instance,{GroupId,Type,CreatorInfo}},_From, State) ->
    Reply = 
		try
			loop_instance_mgr_op:start_instance(GroupId,Type,CreatorInfo)
		catch
			E:R->
				slogger:msg("~p handle_call start_loop_instance ~p E:~p R:~p S:~p ~n",[?MODULE,E,R,erlang:get_stacktrace()]),
				error
		end,
    {reply, Reply, State};

handle_call({check_loop_instance,{GroupId,Type}},_From, State) ->
    Reply = 
		try
			loop_instance_mgr_op:check_instance(GroupId,Type)
		catch
			E:R->
				slogger:msg("~p handle_call check_loop_instance ~p E:~p R:~p S:~p ~n",[?MODULE,E,R,erlang:get_stacktrace()]),
				error
		end,
    {reply, Reply, State};

handle_call(_Request,_From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info({stop_loop_instance,{GroupId,Type,Node,ProcName}}, State) ->
	try
		loop_instance_mgr_op:stop_instance(GroupId,Type,Node,ProcName)
	catch
		E:R->
			slogger:msg("~p handle_info stop_loop_instance E:~p R:~p S:~p ~n",[?MODULE,E,R,erlang:get_stacktrace()])
	end,
    {noreply, State};

handle_info(Info, State) ->
	slogger:msg("~p handle_info error:~p~n", [?MODULE,Info]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
	slogger:msg("~p~n",[Reason]),
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State,_Extra) ->
    {ok, State}.


