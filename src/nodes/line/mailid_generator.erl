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
-module(mailid_generator).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(MAX_NUMBER,999999).
%% --------------------------------------------------------------------
%% External exports
-export([start_link/1,gen_newid/0]).

%% for testing function.

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {serverid,baseid,curindex}).

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
	timer_center:start_at_process(),
	{BaseId,ContexBase} = get_base_id(ServerId),
    {ok, #state{serverid=ServerId,baseid={BaseId,ContexBase},curindex=1}}.

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
handle_call({gen_newid}, _From, #state{serverid=ServerId,baseid={BaseId,ContexBase},curindex=CurIndex}=_State) ->
	Reply =  {BaseId,ContexBase+CurIndex},
	{BaseId2,ContexBase2,CurIndex2}=
									if
										CurIndex >= ?MAX_NUMBER ->
											slogger:msg("mailid have arrive ~p\nReset this processor\n",[CurIndex]),
											{NewBaseId,NewContexBase} = get_base_id(ServerId),
											{NewBaseId,NewContexBase,1};
										true -> {BaseId,ContexBase,CurIndex+1}
									end,
	
    {reply,Reply, #state{serverid=ServerId,baseid={BaseId2,ContexBase2},curindex=CurIndex2}};	
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

get_base_id(ServerId)->
	Standard = {{2010,11,11},{0,0,0}},
	BaseSecond = calendar:datetime_to_gregorian_seconds(Standard),
	NowDate = calendar:now_to_local_time(timer_center:get_correct_now()),
	NowSecond = calendar:datetime_to_gregorian_seconds(NowDate),
	DiffSecond = NowSecond - BaseSecond,
	BaseId = (DiffSecond div 86400) * 1000000 + ServerId,
	CurIndx = (DiffSecond div 60) rem (1440),
	{BaseId,CurIndx*1000000}.
	
%%
%% For testing code 
%% TODO:change  MAX_NUMBER to 9999 & and test next code
%%
