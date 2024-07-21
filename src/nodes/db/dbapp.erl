%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-14
%% Description: TODO: Add description to dbapp
-module(dbapp).

-behaviour(application).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("reloader.hrl").

%% --------------------------------------------------------------------
%% Behavioural exports
%% --------------------------------------------------------------------
-export([
	 start/2,
	 stop/1,
	 start/0,
	 import/0
        ]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% API Functions
%% --------------------------------------------------------------------


%% ====================================================================!
%% External functions
%% ====================================================================!

start()->
	applicationex:start(dbmaster).

import()->
 	data_gen:import_config("game"),
	mnesia:stop(),
	erlang:halt().


%% --------------------------------------------------------------------
%% Func: start/2
%% Returns: {ok, Pid}        |
%%          {ok, Pid, State} |
%%          {error, Reason}
%% --------------------------------------------------------------------
start(_Type, _StartArgs) ->
	do_start().

%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(_State) ->
    ok.

%% ====================================================================
%% Internal functions
%% ====================================================================

do_start()->
	filelib:ensure_dir("../log/"),
	error_logger:logfile({open, "../log/db_node.log"}),
	?RELOADER_RUN,
	ping_center:wait_node_connect(timer),
	case server_travels_util:is_share_server() of
		false->
			travel_deamon_sup:start_link();
		true->
			nothing
	end,
	global_util:global_proc_wait(),
	statistics_sup:start_link(),
	statistics_sup:start_snapshot(),
	timer_center:start_at_app(),
	case dbsup:start_master() of
		{ok, _Pid} ->
			db_tools:wait_for_tables_loop(local,1000,mnesia:system_info(tables)),
			io:format("---------------------------------------------------------~n"),
			io:format("2)To generate data input: data_gen:import_config(\"game\").~n"),
			io:format("3)To backup   data input: db_backup:backup(YourFileName).~n"),
			io:format("4)To recovery data input: db_backup:recovery(YourFileName).~n"),
			io:format("5)To recovery data input: data_gen:backup_ext(YourFileName).~n"),
			io:format("6)To recovery data input: data_gen:recovery_ext(YourFileName).~n"),
			io:format("7)To recovery data input: combin_server:backup(YourFileName).~n"),
			io:format("8)To recovery data input: combin_server:recovery(YourFileName).~n"),
			io:format("---------------------------------------------------------~n");
		Error ->
			Error
	end,
	{ok, self()}.
