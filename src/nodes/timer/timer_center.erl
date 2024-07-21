%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-11
%%% -------------------------------------------------------------------
-module(timer_center).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-export([get_correct_now/0,start_at_process/0,start_at_app/0,get_time_of_day/0]).	
-define(DEVIATION_SECONDS,'$deviation_seconds$').
-define(SERVER_START_TIME,'$server_start_time$').
-define(DEVIATION_SECONDS_ETS,'$ets_deviation_seconds$').


-define(CENTER_FLASH_TIMEOUT, (60*1000*10)).

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,query_time/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {tref}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?MODULE}, ?MODULE ,[], []).

%% ====================================================================
%% Server functions
%% ====================================================================

query_time()->
	gen_server:call(?MODULE, {query_time}).
	
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
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
handle_call({query_time}, _From, State) ->
   Reply = now(),
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

handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, State) ->
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
start_at_process()->
	Deviation = get_ets_deviation_seconds(),
	Time = get_ets_server_start_time(),
	put(?DEVIATION_SECONDS,Deviation),
	put(?SERVER_START_TIME,Time).

start_at_app()->
	Now = query_time_rpc(500),
	put_deviation_seconds(Now).
	
get_correct_now()->
	{A,B,C} = now(),
	{A,B+get_deviation_seconds(),C}.

get_time_of_day()->
	{A,B,C} = now(),
	{A2,B2,_} = get_server_start_time(),
	{A - A2,B - B2,C}.

get_deviation_seconds()->
	case get(?DEVIATION_SECONDS) of
		undefined-> 0;
		V->V
	end.

get_server_start_time()->
	case get(?SERVER_START_TIME) of
		undefined-> {0,0,0};
		Time->Time
	end.

put_deviation_seconds(OtherTimer)->
	{A2,B2,_C2} = OtherTimer,
	{A1,B1,_C1} = now(),
	Deviation = B2 + A2*1000000 - B1 - A1*1000000,
	ets:new(?DEVIATION_SECONDS_ETS, [set,public,named_table]),
	ets:insert(?DEVIATION_SECONDS_ETS, {1,Deviation}),
	ets:insert(?DEVIATION_SECONDS_ETS, {2,{A1,B1,0}}).
get_ets_deviation_seconds()->
	case ets:lookup(?DEVIATION_SECONDS_ETS, 1) of
		[]-> 0;
		[{_,Deviation}]->Deviation
	end.

get_ets_server_start_time()->
	case ets:lookup(?DEVIATION_SECONDS_ETS, 2) of
		[]-> 0;
		[{_,Time}]->Time
	end.

query_time_rpc(N)->
	case N of
		0-> 0;
		_->
			case rpc:call(node_util:get_timernode(), ?MODULE, query_time, []) of
				{badrpc,Reason}-> slogger:msg("query_timer error:~p~n",[Reason]),
								  timer:sleep(1000),
								  query_time_rpc(N-1);
				Deviation->	Deviation
			end
	end.
	