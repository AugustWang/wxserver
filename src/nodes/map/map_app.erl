%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-4-11
%% Description: TODO: Add description to map_app
-module(map_app).

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
			filelib:ensure_dir("../log/"),
			FileName = "../log/"++atom_to_list(node_util:get_node_sname(node())) ++ "_node.log", 
			error_logger:logfile({open, FileName}),
			?RELOADER_RUN,
			ping_center:wait_all_nodes_connect(),
			db_tools:wait_line_db(),
			case server_travels_util:is_share_server() of
				false->
					travel_deamon_sup:start_link();
				true->
					case node_util:check_snode_match(map_travel, node()) of
						true->
							map_travel_deamon_sup:start_link();
						false->
							nothing
					end		
			end,
			global_util:global_proc_wait(),
			timer_center:start_at_app(),
			dbsup:start_dal_dmp(),
			%%wait all db table
			slogger:msg("wait_for_all_db_tables ing ~n"),
			applicationex:wait_ets_init(),
			slogger:msg("wait_for_all_db_tables end ~n"),
			role_pos_db:unreg_role_pos_to_mnesia_by_node(node()),
			role_app:start(),
			lines_manager:wait_lines_manager_loop(),
			%%load map
			start_map_sup(),
			start_map_manager_sup(),
			npc_function_frame:init_all_functions_after_ets_finish(),
			start_treasure_spawns_sup(),
			guild_instance_sup:start_link(),
			statistics_sup:start_link(),
			case node_util:check_snode_match(battle_ground_manager, node()) of
				true->
					start_battle_ground_sup(),
					start_battle_ground_manager_sup();
				false->
					start_battle_ground_sup()
			end,
			case node_util:check_snode_match(guildbattle_manager, node()) of
				true->
					start_guildbattle_manager_sup();
				false->
					nothing
			end,
			case node_util:check_snode_match(auction_manager, node()) of
				true->
					start_auction_manager_sup();
				false->
					nothing
			end,
			case node_util:check_snode_match(game_rank_manager, node()) of
				true->
					start_game_rank_manager_sup();
				false->
					nothing
			end,
			
			case node_util:check_snode_match(group_manager, node()) of
				true->
					start_group_manager_sup();
				_->
					nothing
			end,
			case node_util:check_snode_match(activity_manager, node()) of
				true->
					start_activity_manager_sup();
				false->
					nothing
			end,
			case node_util:check_snode_match(answer_processor, node()) of
				true->
					start_answer_sup();
				_->
					nothing
			end,
			case node_util:check_snode_match(dragon_fight_processor, node()) of
				true->
					start_dragon_fight_sup();
				false->
					nothing
			end,
			
			case node_util:check_snode_match(map_travel, node()) of
				true->
					start_map_travel_sup();
				false->
					nothing
			end,
			case node_util:check_snode_match(guild_instance_processor, node()) of
				true->
					start_guild_instance_sup();
				false->
					nothing
			end,
			case node_util:check_snode_match(loop_instance_mgr, node()) of
				true->
					start_loop_instance_proc_sup(),
					start_loop_instance_mgr_sup();
				false->
					start_loop_instance_proc_sup()
			end,
			{ok, self()}
	end.

start()->
	applicationex:start(?MODULE).
%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(_State) ->
	ok.

%% ====================================================================
%% Internal functions
%% ====================================================================

start_map_sup()->
	case map_sup:start_link() of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.

start_map_manager_sup()->
	case map_manager_sup:start_link() of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.

start_battle_ground_manager_sup()->
	case battle_ground_manager_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_battle_ground_manager_sup error!! ~p ~n",[Error])
	end.

start_guildbattle_manager_sup()->
	case guildbattle_manager_sup:start_link() of
		{ok,Pid}->
			slogger:msg("start_guildbattle_manager_sup success!! ~p ~n",[Pid]),
			{ok,Pid};
		Error->
			slogger:msg("start_guildbattle_manager_sup error!! ~p ~n",[Error])
	end.

start_battle_ground_sup()->
	case battle_ground_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_battle_ground_sup error!! ~p ~n",[Error])
	end.

start_answer_sup()->
	case answer_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_answer_sup error!! ~p ~n",[Error])
	end.

start_activity_manager_sup()->
	case activity_manager_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_activity_manager_sup error!! ~p ~n",[Error])
	end.
	
start_treasure_spawns_sup()->
	case treasure_spawns_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_battle_ground_sup error!! ~p ~n",[Error])
	end.
 
start_dragon_fight_sup()->
	case dragon_fight_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_battle_ground_sup error!! ~p ~n",[Error])
	end.

start_treasure_transport_sup()->
	case treasure_transport_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_treasure_transport_sup error!! ~p ~n",[Error])
	end.

start_mapdb_sup()->
	case mapdb_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_auction_manager_sup()->
	case auction_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_group_manager_sup()->
	case group_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.	

start_map_travel_sup()->
	case map_travel_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_game_rank_manager_sup()->
	case game_rank_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_guild_instance_sup()->
	case guild_instance_processor_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_loop_instance_mgr_sup()->
	case loop_instance_mgr_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_loop_instance_proc_sup()->
	case loop_instance_proc_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.
