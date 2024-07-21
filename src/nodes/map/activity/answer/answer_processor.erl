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
-module(answer_processor).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/2,apply_join_activity/1,apply_answer_question/1,get_activity_state/0,
		 apply_leave_activity/1]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link(Duration,Args)->
	gen_server:start_link({local,?MODULE},?MODULE,[Duration,Args],[]).

%%@Spec player join to the someone activity.
apply_join_activity(Info)->
	try
		global_util:call(?MODULE,{apply_join_activity,Info})
	catch
		E:R->
			slogger:msg("answer apply_join_activity error ~p ~p ~n ",[E,R]),
			error
	end.

apply_leave_activity(Info)->
	try
		global_util:send(?MODULE,{apply_leave_activity,Info})
	catch
		E:R->
			slogger:msg("answer apply_leave_activity error ~p ~p ~n ",[E,R]),
			error
	end.

apply_answer_question(Info)->
	try
		global_util:call(?MODULE,{apply_answer_question,Info})
	catch
		E:R->
			slogger:msg("answer apply_answer_question error ~p ~p ~n ",[E,R]),
			error
	end.

get_activity_state()->
	try
		global_util:call(?MODULE,{get_activity_state})
	catch
		E:R->
			slogger:msg("answer get_activity_state error ~p ~p ~n ",[E,R]),
			error
	end.

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/2
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([Duration,Args])->
	timer_center:start_at_process(),
	answer:init(Duration,Args),
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
handle_call({apply_join_activity,Info}, _From, State) ->
	Reply = 
	try
		answer:apply_join_activity(Info)
	catch
		E:R->
			slogger:msg("answer apply_join_activity error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
    {reply, Reply, State};

handle_call({apply_answer_question,Info}, _From, State) ->
	Reply = 
	try
		answer:apply_answer_question(Info)
	catch
		E:R->
			slogger:msg("answer apply_answer_question error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
    {reply, Reply, State};

handle_call({get_activity_state}, _From, State) ->
	Reply = 
	try
		answer:get_activity_state()
	catch
		E:R->
			slogger:msg("answer apply_answer_question error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
    {reply, Reply, State};

handle_call(_Request, _From, State) ->
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
handle_info({activity_sign_notify,LeftTime}, State) ->
	try
		answer:activity_sign_notify(LeftTime)
	catch
		E:R->
			slogger:msg("answer activity_sign_notify error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({activity_start_notify}, State) ->
	try
		answer:activity_start_notify()
	catch
		E:R->
			slogger:msg("answer activity_start_notify error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({send_question_to_sign_user,Id,Num}, State) ->
	try
		answer:send_question_to_sign_user(Id,Num)
	catch
		E:R->
			slogger:msg("answer activity_start_notify error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({generator_rank_list}, State) ->
	try
		answer:generator_rank_list()
	catch
		E:R->
			slogger:msg("answer generator_rank_list error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({apply_leave_activity,Info}, State) ->
	try
		answer:apply_leave_activity(Info)
	catch
		E:R->
			slogger:msg("answer apply_leave_activity error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({end_notice_to_sign_user}, State) ->
	try
		answer:end_notice_to_sign_user()
	catch
		E:R->
			slogger:msg("answer end_notice_to_sign_user error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
