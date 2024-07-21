%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-8-18
%%% -------------------------------------------------------------------
-module(applicationex).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(CHECK_RAM_INTERVAL,1000).
-include("base_define.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([wait_ets_init/0]).
-export([wait_ets_init_fliter/1]).
-export([sp_call/3]).
%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
-export([start/1,start/2,force_start/0]).

%%
%% API Functions
%%

start(Application)->
	force_start(),
	Cookie = env:get(cookie,?ERLNULL),
	erlang:set_cookie(node(), Cookie),
	application:start(Application).

start(Application,Type)->
	force_start(),
	Cookie = env:get(cookie,?ERLNULL),
	erlang:set_cookie(node(), Cookie),
	application:start(Application,Type).

%%
%% Local Functions
%%

force_start()->
	case erlang:whereis(?MODULE) of
		?ERLNULL->	gen_server:start_link({local,?MODULE},?MODULE, [], []);
		_->ignor
	end.


%% ====================================================================
%% Server functions
%% ====================================================================
wait_ets_init()->
	gen_server:call(?MODULE, {wait_ets_init},infinity).

wait_ets_init_fliter(EtsFliter)->
	gen_server:call(?MODULE, {wait_ets_init_fliter,{EtsFliter}},infinity).

sp_call(M,F,A)->
	gen_server:call(?MODULE, {sp_call,M,F,A},infinity).


%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	env:init(),
	global_node:init(),
	version_up:init(),
	db_tools:wait_ets_create(),
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
handle_call({wait_ets_init}, _From, State) ->
	env:fresh(),
	db_tools:wait_ets_init(),
	 Reply = ok,
    {reply, Reply, State};

handle_call({wait_ets_init_fliter,{EtsFliter}}, _From, State) ->
	%%env:fresh(),
	db_tools:wait_ets_init_fliter(EtsFliter),
	 Reply = ok,
    {reply, Reply, State};
	
handle_call({sp_call,M,F,A},_From,State)->
	try
		apply(M,F,A)
	catch
		E:R-> io:format("~p : ~p~n",[E,R])
	end,
	 Reply = ok,
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
handle_cast(Msg, State) ->
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
	

