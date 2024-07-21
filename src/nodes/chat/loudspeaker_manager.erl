%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-5-14
%% Description: TODO: Add description to role_speaker_process
-module(loudspeaker_manager).
-behaviour(gen_server).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([start_link/0]).
-export([send_loudspeaker/2,loudspeaker_queue_num/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {}).
%%
%% API Functions
%%


send_loudspeaker(Role,Args)->
	try
		global_util:call(?MODULE,{send_loudspeaker,Role,Args})
	catch
		E:R->
			slogger:msg("get_activity_state error ~p ~p ~n ",[E,R]),
			{error,R}
	end.
	
loudspeaker_queue_num(RoleId)->
	try
		global_util:send(?MODULE,{loudspeaker_queue_num,RoleId})
	catch
		E:R->
			slogger:msg("loudspeaker_queue_num error ~p ~p ~n ",[E,R]),
			error
	end.

start_link()->
	gen_server:start_link({local,?MODULE},?MODULE,[],[]).


init([]) ->
	timer_center:start_at_process(),
	try
		loudspeaker_op:init()
	catch
		E:R ->slogger:msg("loudspeaker_manager init error ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()])
	end,
    {ok, #state{}}.


handle_call({send_loudspeaker,Role,Args}, _From, State) ->
	Reply = 
	try
		loudspeaker_op:use_loudspeaker(Role,Args)
	catch
		E:R->
			slogger:msg("send_loudspeaker error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
    {reply, Reply, State};

handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.



handle_info({loudspeaker_queue_num,RoleId},State)->
	try
		loudspeaker_op:answer_loudspeaker_queue_num(RoleId)
	catch
		E:R->
			slogger:msg("loudspeaker_queue_num error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({loudspeaker_timer}, State) ->
	loudspeaker_op:loudspeaker_timer(),
    {noreply, State};

%% handle_info({hook_online,RoleId},State) ->
%% 	try
%% 		loudspeaker_op:hook_online(RoleId)
%% 	catch
%% 		E:R->
%% 			slogger:msg("loudspeaker hook_online ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
%% 			error
%% 	end,
%%     {noreply, State};
%% 

handle_info(Info, State) ->
    {noreply, State}.



handle_cast(Msg, State) ->
    {noreply, State}.


terminate(Reason, State) ->
    ok.


code_change(OldVsn, State, Extra) ->
    {ok, State}.

%%
%% Local Functions
%%

