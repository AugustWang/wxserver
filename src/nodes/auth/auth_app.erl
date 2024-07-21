%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-4-15
%% Description: TODO: Add description to auth_app
-module(auth_app).

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
	 start/0
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
%% --------------------------------------------------------------------
%% Func: start/2
%% Returns: {ok, Pid}        |
%%          {ok, Pid, State} |
%%          {error, Reason}
%% --------------------------------------------------------------------
start(_Type, _StartArgs) ->
	case util:get_argument('-line') of
		[]->  slogger:msg("Missing --line argument input the nodename");
		[CenterNode|_]->
			error_logger:logfile({open, "../log/authnode.log"}),
			?RELOADER_RUN,
			ping_center:wait_all_nodes_connect(),
			case server_travels_util:is_share_server() of
				false->
					travel_deamon_sup:start_link();
				true->
					nothing
			end,
			global_util:global_proc_wait(),
			timer_center:start_at_app(),
			statistics_sup:start_link(),
			case auth_sup:start_link() of
				{ok, Pid} ->
					nothing;
				Error ->
					Error
			end,
			{ok, self()}
	end.
	
start()->
	applicationex:start(?MODULE).
%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(State) ->
    ok.

%% ====================================================================
%% Internal functions
%% ====================================================================

