%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(guild_app).

-behaviour(application).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("reloader.hrl").


-export([start/0]).
%% --------------------------------------------------------------------
%% Behavioural exports
%% --------------------------------------------------------------------
-export([
	 start/2,
	 stop/1
        ]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------


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
%% --------------------------------------------------------------------
%% Func: start/2
%% Returns: {ok, Pid}        |
%%          {ok, Pid, State} |
%%          {error, Reason}
%% --------------------------------------------------------------------
start(_Type, StartArgs) ->
	case util:get_argument('-line') of
		[]->  slogger:msg("Missing --line argument input the nodename");
		[CenterNode|_]->
			filelib:ensure_dir("../log/"),
			error_logger:logfile({open, "../log/guild_node.log"}),
			ping_center:wait_all_nodes_connect(),
			db_tools:wait_line_db(),
			?RELOADER_RUN,
			case server_travels_util:is_share_server() of
				false->
					travel_deamon_sup:start_link();
				true->
					nothing
			end,
			global_util:global_proc_wait(),
			timer_center:start_at_app(),
			statistics_sup:start_link(),
			slogger:msg("wait_for_all_db_tables ing ~n"),
			%%wait all db table
			applicationex:wait_ets_init(),
			slogger:msg("wait_for_all_db_tables end ~n"),
			start_country_manager_sup(),
			start_guild_manager_sup(),
			{ok, self()}
	end.
%% --------------------------------------------------------------------
%% Func: start/0
%% Returns: any
%% --------------------------------------------------------------------
start() ->
     applicationex:start(?MODULE).
%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(State) ->
    ok.

%% ====================================================================
%%  only start guild_process_sup ,add child for dymanic 
%% ====================================================================
start_guild_manager_sup()->	
	case guild_manager_sup:start_link([]) of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.

start_country_manager_sup()->
	case country_manager_sup:start_link([]) of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.
