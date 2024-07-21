%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-4-11
%% Description: TODO: Add description to line_app
-module(line_app).

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
	 stop/1
        ]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 start/0	 
	]).

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
	filelib:ensure_dir("../log/"),
	error_logger:logfile({open, "../log/line_node.log"}),
	?RELOADER_RUN,
	ping_center:wait_all_nodes_connect(),
	dbsup:start_line_db_master(),
	timer_center:start_at_app(),
	case server_travels_util:is_share_server() of
		false->
			travel_deamon_sup:start_link();
		true->
			nothing
	end,
	global_util:global_proc_wait(),
	applicationex:wait_ets_init(),
	statistics_sup:start_link(),
	gm_notice_checker_sup:start_link(),
	start_line_processor_sup(),
	start_lines_manager_sup(),
	start_itemid_generator_sup(),
	start_mailid_generator_sup(),
	start_roleid_generator_sup(),
	start_petid_generator_sup(),
	start_guildid_generator_sup(),
	start_visitor_generator_sup(),
	start_instanceid_generator_sup(),
	start_server_control_sup(),
	{ok, self()}.
	
start()->
	applicationex:start(line).

%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(_State) ->
	ok.

%% ====================================================================
%% Internal functions
%% ====================================================================

start_lines_manager_sup() ->
	case lines_manager_sup:start_link() of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.

start_line_processor_sup() ->
	case line_processor_sup:start_link() of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.
start_itemid_generator_sup()->
	case itemid_generator_sup:start_link() of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.


start_roleid_generator_sup()->
	case roleid_generator_sup:start_link() of
		{ok,Pid}->
			{ok, Pid};
		Error ->
			Error
	end.

start_petid_generator_sup()->
	case petid_generator_sup:start_link() of
		{ok,Pid}->
			{ok, Pid};
		Error ->
			Error
	end.

start_visitor_generator_sup()->
	case visitor_generator_sup:start_link() of
		{ok,Pid}->
			{ok, Pid};
		Error ->
			Error
	end.
start_guildid_generator_sup()->
	case guildid_generator_sup:start_link() of
		{ok,Pid}->
			{ok, Pid};
		Error ->
			Error
	end.

start_mailid_generator_sup()->
	case mailid_generator_sup:start_link() of
		{ok,Pid}->
			{ok, Pid};
		Error ->
			Error
	end.

start_instanceid_generator_sup()->
		case instanceid_generator_sup:start_link() of
		{ok,Pid}->
			{ok, Pid};
		Error ->
			Error
	end.

start_server_control_sup()->
	case server_control_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			Error
	end.



	