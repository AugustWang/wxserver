%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-1-6
%% Description: TODO: Add description to loop_instance_proc
-module(loop_instance_proc).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/4]).

-compile(export_all).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("data_struct.hrl").

%% External functions
%% ====================================================================
start_link(ProcName,GroupId,Type,InstanceInfo)->
	gen_server:start_link({local,ProcName},?MODULE,[ProcName, {GroupId,Type,InstanceInfo}],[]).
  
%%TODO:all try catch!!!
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([ProcName, {GroupId,Type,InstanceInfo}])->
	timer_center:start_at_process(),
	loop_instance_proc_op:init(ProcName, {GroupId,Type,InstanceInfo}),
	{ok, []}.


%%
%%call
%%
%%return {ok,layer,mapproc} | error
entry_instance(GroupId,Type,Layer,Node,Proc)->
	try
		gen_server:call({Proc,Node},{entry_instance,{GroupId,Type,Layer}})
	catch
		E:R->
			slogger:msg("~p entry instance E ~p R ~p ~n",[?MODULE,E,R]),
			error
	end.

%%
%%return {ok,complatelayer} | error
%%
member_leave(RoleId,Layer,Node,Proc)->
	try
		 gen_server:call({Proc,Node},{member_leave,{RoleId,Layer}})
	catch
		E:R->
			slogger:msg("~p member_leave E ~p R ~p ~n",[?MODULE,E,R]),
			error
	end.
%%
%%send
%%
member_entry(RoleId,Layer,Node,Proc)->
	try
		 gs_rpc:cast(Node,Proc,{member_entry,{RoleId,Layer}})
	catch
		E:R->
			slogger:msg("~p member_entry E ~p R ~p ~n",[?MODULE,E,R])
	end.

kill_monster(RoleId,Layer,NpcProto,Node,Proc)->
	try
		 gs_rpc:cast(Node,Proc,{kill_monster,{RoleId,Layer,NpcProto}})
	catch
		E:R->
			slogger:msg("~p kill_monster E ~p R ~p ~n",[?MODULE,E,R])
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

handle_call({member_leave,{RoleId,Layer}}, From, State) ->
	Reply = 
		try
			loop_instance_proc_op:member_leave(RoleId,Layer)
		catch
			E:R->
				slogger:msg("~p handle_call member leave E ~p R ~p S:~p ~n",[?MODULE,E,R,erlang:get_stacktrace()]),
				error
		end,
	{reply, Reply, State};


handle_call({entry_instance,{GroupId,Type,Layer}}, From, State) ->
	Reply = 
		try
			loop_instance_proc_op:get_instance(GroupId,Type,Layer)
		catch
			E:R->
				slogger:msg("~p handle_call entry instance E ~p R ~p S:~p ~n",[?MODULE,E,R,erlang:get_stacktrace()]),
				error
		end,
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

handle_info({self_check}, State) ->
	try
		loop_instance_proc_op:self_check()	
	catch
		E:R->
			slogger:msg("~p handle_info self_check E ~p R ~p S:~p ~n",[?MODULE,E,R,erlang:get_stacktrace()])
	end,
	{noreply, State};


handle_info({member_entry,{RoleId,Layer}}, State) ->
	try
		loop_instance_proc_op:member_entry(RoleId,Layer)	
	catch
		E:R->
			slogger:msg("~p handle_info member_entry Param ~p E ~p R ~p S:~p ~n",[?MODULE,{RoleId,Layer},E,R,erlang:get_stacktrace()])
	end,
	{noreply, State};

handle_info({kill_monster,{RoleId,Layer,NpcProto}}, State) ->
	try
		loop_instance_proc_op:kill_monster(RoleId,Layer,NpcProto)	
	catch
		E:R->
			slogger:msg("~p handle_info kill_monster Param ~p E ~p R ~p S:~p ~n",[?MODULE,{RoleId,Layer,NpcProto},E,R,erlang:get_stacktrace()])
	end,
	{noreply, State};

handle_info({destroy_self}, State) ->
	try
		loop_instance_proc_op:on_destory()	
	catch
		E:R->
			slogger:msg("~p handle_info destroy_self E ~p R ~p S:~p ~n",[?MODULE,E,R,erlang:get_stacktrace()])
	end,
	{noreply, State};


handle_info({safe_turnback_proc,MapProc},State)->
	try
		loop_instance_proc_op:safe_turnback_proc(MapProc)	
	catch
		E:R->
			slogger:msg("~p handle_info safe_turnback_proc ~p E ~p R ~p S:~p ~n",[?MODULE,MapProc,E,R,erlang:get_stacktrace()])
	end,
	{noreply, State};

handle_info(Info, State) ->
	{noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
	slogger:msg("~p terminate Reason ~p ~n",[?MODULE,Reason]),
	ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
	{ok, State}.
