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
-module(roleid_generator).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_define.hrl").

%% --------------------------------------------------------------------
%% External exports
-export([start_link/1,gen_newid/1]).

%% for testing function.

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {servers_index}).

%%servers_index : [{serverid,curindex}]

%% ====================================================================
%% External functions
%% ====================================================================
start_link(_ServerId)->
	gen_server:start({local,?MODULE}, ?MODULE, [], []).


%% ====================================================================
%% Server functions
%% ====================================================================
gen_newid(ServerId)->
	global_util:call(?MODULE, {gen_newid,ServerId}).
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	self()!{init_index},
    {ok, #state{servers_index = []}}.

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
handle_call({gen_newid,ServerId}, _From, 
	#state{servers_index=ServersIndex}=_State) ->
	{ServerId,CurIndex} = lists:keyfind(ServerId,1, ServersIndex),
	
	NewCurIndx = case CurIndex of
		undefined -> idgen:get_idmax({roleid,ServerId},?MIN_ROLE_ID) + 1;
		_-> CurIndex+1
	end,
	
	RoleId = ServerId*?SERVER_MAX_ROLE_NUMBER + NewCurIndx,
	%%
	Reply = RoleId,
%% 	Reply =  case ServerId of
%% 				0-> NewCurIndx;
%% 				_-> {ServerId,NewCurIndx}
%% 			  end,
	idgen:update_idmax({roleid,ServerId},NewCurIndx),
	NewServersIndex = lists:keyreplace(ServerId, 1, ServersIndex,{ServerId,NewCurIndx}),
    {reply,Reply, #state{servers_index = NewServersIndex}};

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
handle_info({init_index},State)->
	ServersIndex = 
	lists:map(fun(ServerId)->
		IdMax = idgen:get_idmax({roleid,ServerId},?MIN_ROLE_ID),
		{ServerId,IdMax} end ,env:get(serverids,[])),
    {noreply, State#state{servers_index=ServersIndex}};

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

