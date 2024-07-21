%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: PCWS06
%% Created: 2010-7-8
%% Description: TODO: Add description to chat_app
-module(chat_app).

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
	%%io:format("app start"),
	case util:get_argument('-line') of
		[]->  slogger:msg("Missing --line argument input the nodename");
		[CenterNode|_]->
			filelib:ensure_dir("../log/"),
			FileName = "../log/"++atom_to_list(node_util:get_node_sname(node())) ++ "_node.log", 
			error_logger:logfile({open, FileName}),
			?RELOADER_RUN,
			ping_center:wait_all_nodes_connect(),
			db_tools:wait_line_db(),
			WaitLineManagerTime = 10000,
			timer:sleep(WaitLineManagerTime),
			case server_travels_util:is_share_server() of
				false->
					travel_deamon_sup:start_link();
				true->
					nothing
			end,
			global_util:global_proc_wait(),
			timer_center:start_at_app(),
			statistics_sup:start_link(),
			applicationex:wait_ets_init(),
			case node_util:check_snode_match(loudspeaker_manager, node()) of
				true->
					start_loudspeaker_manager_sup();
				false->
					nothing
			end,
			start_chat_manager_sup(),
			{ok, self()}
	end.
	
%% --------------------------------------------------------------------
%% Func: start/0
%% Returns: any
%% --------------------------------------------------------------------
start()->
     applicationex:start(?MODULE).
%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(State) ->
    ok.

%% ====================================================================
%%  only start chat_process_sup ,add child for dymanic 
%% ====================================================================
start_chat_manager_sup()->	
	case chat_manager_sup:start_link() of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.

start_loudspeaker_manager_sup()->
	case loudspeaker_sup:start_link() of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.
