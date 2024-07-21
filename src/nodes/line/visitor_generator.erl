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
-module(visitor_generator).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_define.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([start_link/1,gen_newid/0]).

%% for testing function.

-export([test/1]).
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
gen_newid()->
	global_util:call(?MODULE, {gen_newid}).
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([ServerId]) ->
	self()!{init_index},
    {ok, #state{serverid=ServerId,curindex=undefined}}.

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
handle_call({gen_newid}, _From, 
	#state{serverid=ServerId,curindex=CurIndex}=_State) ->
	NewCurIndx = case CurIndex of
		undefined -> idgen:get_idmax({visitor,ServerId}) + 1;
		_-> CurIndex+1
	end,
	Reply = NewCurIndx,

	idgen:update_idmax({visitor,ServerId},NewCurIndx),
    {reply,Reply, #state{serverid=ServerId,curindex=NewCurIndx}};

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
handle_info({init_index},#state{serverid=ServerId}=State)->
	IdMax = idgen:get_idmax({visitor,ServerId}),
    {noreply, State#state{curindex=IdMax}};
	
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

%%
%% For testing code 
%%
test(server)->
	start_link(999),
	lists:foreach(fun(_)-> spawn_link(fun()-> loop()end) end, lists:duplicate(1000, dummy));
test(client)->
	lists:foreach(fun(_)-> spawn_link(fun()-> loop()end) end, lists:duplicate(1000, dummy)).

loop()->
	NewId = gen_newid(),
	slogger:msg("gen_newid ~p~n",[NewId]),
	timer:sleep(1000),
	loop().


					