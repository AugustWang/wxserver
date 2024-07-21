%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-15
%%% -------------------------------------------------------------------
-module(gmauth_processor).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,auth/6]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {auth_algorithm,secret,authtimeout}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
    gen_server:start_link({local,?MODULE},?MODULE,[],[]).


auth(FromNode,FromProc,GmUserName,GmUserId,Time,GmAuthResult)->
    global_util:send(?MODULE, {auth_gm,{FromNode,FromProc,GmUserName, GmUserId,Time,GmAuthResult}}).


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
	timer_center:start_at_process(),
	SecretKey =env:get(gmsecretkey, ""),
	CfgTimeOut=env:get(gmauthttimeout, 3600),
    {ok, #state{auth_algorithm=gmauth_db,secret= SecretKey,authtimeout=CfgTimeOut}}.

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
handle_info({auth_gm,{FromNode,FromProc,GmName, GmId,Time,AuthResult}},
			 #state{auth_algorithm=Mod,secret= SecretKey,authtimeout=CfgTimeOut}=State)->
	
	Fun = case SecretKey of
			""-> validate_gm_test;
			_->  validate_gm
		  end,
	
    case Mod:Fun(GmName, GmId,Time,AuthResult,SecretKey,CfgTimeOut) of
		{ok,GmId}->
	    	slogger:msg("~p login successed userid=~p~n",[GmName,GmId]),
	    	gm_client:auth_ok(FromNode, FromProc, GmId);
		{error, Reason}-> 
	    	slogger:msg("~p login failed,Reason:~p ~n",[GmName, Reason]),
	    	gm_client:auth_failed(FromNode, FromProc, Reason)
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

