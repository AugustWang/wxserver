%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrianx
%%% Description :
%%%
%%% Created : 2010-10-23
%%% -------------------------------------------------------------------
-module(dbchecker).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(CHECK_SPLIT_TABLE_FIRSTINTERVAL,1000).
-define(CHECK_SPLIT_TABLE_INTERVAL,1000*60*10).
%% --------------------------------------------------------------------
%% External exports
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

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
	mnesia:start(),
	timer_center:start_at_process(),
	erlang:send_after(?CHECK_SPLIT_TABLE_FIRSTINTERVAL, self(), {check_ram}),
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
handle_info( {check_ram},State)->
	 case node_util:get_dbnode() of
		 undefined->
			 io:format("can not connect to dbnode ,interval be short!!!~n"),
			 erlang:send_after(?CHECK_SPLIT_TABLE_FIRSTINTERVAL, self(), {check_ram});
		 _->
			 Apps = node_util:get_run_apps(node()),
			 %%check the ram tables
			 case check_ram_tables(Apps) of
				 nodbnode->
					 io:format("can not connect to dbnode ,interval be short!!!~n"),
					 erlang:send_after(?CHECK_SPLIT_TABLE_FIRSTINTERVAL, self(), {check_ram});
				 ignor-> ignor;
				 _->
					 case check_split_tables(Apps) of
						 ignor-> ignor;
						 uncompleted->
							 io:format("split table has not been add to schema,interval be short!!!~n"),
							 erlang:send_after(?CHECK_SPLIT_TABLE_FIRSTINTERVAL, self(), {check_ram});
						 ok-> 
							 io:format("split table has been add to schema,interval be long!!!~n"),
							 erlang:send_after(?CHECK_SPLIT_TABLE_INTERVAL, self(), {check_ram})
					 end
			 end
	 	 end,
	{noreply,State};
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
check_ram_tables(Apps)->
	RamTables = lists:foldl(fun(App,Tables)->
									AppTables = db_tools:get_ram_table(App),
									Tables++ lists:filter(fun(Tab)-> not db_split:check_split_table(Tab) end, AppTables)
							end,[], Apps),
	db_tools:config_ram_tables_type(RamTables).

check_split_tables(Apps)->
	%% get the table need split
	SplitTables = lists:foldl(fun(App,Tables)->
									  BaseTables = db_split:check_hasplit(App),
									  Tables ++ BaseTables
							  end,[],Apps),
	case SplitTables of
		[]-> ignor;
		_->
			%% split
			Restult = lists:map(fun(App)->
										AppTables = db_split:check_ramsplit(App),
										case AppTables of
											[]-> true;
											_-> case lists:member(false, AppTables) of
													true->false; %%thers's table havn't split
													_-> true
												end
										end
								end, Apps),
			case Restult of
				[]-> ignor;
				_-> case lists:member(false, Restult) of
						true-> uncompleted;
						false-> ok
					end
			end
	end.

