%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-10
%% Description: TODO: Add description to db_tools
-module(db_tools).

%%
%% Include files
%%
%%
%% Exported Functions
%%
-export([wait_ets_init/0,wait_ets_create/0,config_ram_tables_type/1,config_disc_db_node/1,correct_need_config_tables/1]).

-export([wait_line_db/0]).

-export([create_table_disc/4,create_table_ram/4]).

-export([add_db_ram_node/2,add_dbslave_node/1]).

-export([wait_ets_init_fliter/1,get_node_ram_tables/1,is_need_ram_table/1,get_ets_table_mods/1]).

-export([wait_for_all_db_tables_in_db_node/0,wait_for_all_db_tables/0,wait_for_tables_loop/3]).

%%
%% API Functions
%%
-define(DB_WAIT_TABLE_TIMEOUT,600000).

%% ====================================================================
%% External functions
%% ====================================================================
wait_line_db()->
	db_operater_mod:start(),
	wait_line_db_loop().

wait_line_db_loop()->
	case node_util:get_linenodes() of
		[]->
			timer:sleep(1000),
			wait_line_db_loop();
		[Node|_]->
			case  line_db_master:is_db_prepread(Node) of
				true->
					mnesia:start();
				false->
					timer:sleep(1000),
					wait_line_db_loop()
			end
	end.


config_disc_db_node(DbNode)->
	mnesia:start(),
	case check_db_connected() of
		false-> dbmaster:rpc_add_self_to_dbslave_node(DbNode);
		_->
			TablesList = mnesia:system_info(tables),
			check_tables_disc_copies(TablesList),
			slogger:msg("This Node has been add to Mnesia as slave dbnode!\n")
	end.

config_ram_tables_type(RamTableList)->
	case RamTableList of
		[]-> ignor;
		_-> case node_util:get_dbnode() of
				undefined-> nodbnode;
				_DbNode->
					config_ram_db_node(RamTableList),
					CorrectTables = db_tools:correct_need_config_tables(RamTableList),
					mnesia:wait_for_tables(CorrectTables,?DB_WAIT_TABLE_TIMEOUT),
					ok
			end
	end.

config_ram_db_node(TablesList)->
	case node_util:get_dbnode() of
		undefined -> slogger:msg("DB Node havn't startd!\n");
		DbNode->
			mnesia:start(),
			case check_db_connected() of
				false-> dbmaster:rpc_add_self_to_db_node(DbNode,TablesList);
				_-> check_tables_ram_copies(db_tools:correct_need_config_tables(TablesList)),
					slogger:msg("This Node has been add to Mnesia as ram dbnode!\n")
			end
	end.

	
%%
%% Local Functions
%%
check_db_connected()->
	Nodes = mnesia:system_info(db_nodes),
	CurNode = node(),
	case Nodes of
		[CurNode]-> false;
		_-> true
	end.


%%
%% ram copies table
%%
check_tables_ram_copies([])->
	ok;
check_tables_ram_copies(TableList)->
	[Table|T] = TableList,
	Nodes = mnesia:table_info(Table, ram_copies),
	case lists:member(node(), Nodes) of
		false->
			mnesia:add_table_copy(Table, node(), ram_copies);
		true->
			ignor
	end,
	check_tables_ram_copies(T).

%%
%% disc copies table
%%
check_tables_disc_copies([])->
	ok;
check_tables_disc_copies(TableList)->
	[Table|T] = TableList,
	force_disc_copies(node(),Table),
	check_tables_disc_copies(T).

%%
%% create_table_disc(Tab,Attributes,Indexs,Type)
%%
%% Tab -> table_name :atom
%%
%% Attributes-> fields list: lists
%%
%% Indices-> index list: lists
%%
%% Type-> bag|set|...
%%
create_table_disc(Tab,Attributes,Indices,Type)->
	NeedCreate = try
					 case mnesia:table_info(Tab,attributes) of
						Attributes -> false;
						_->  
							slogger:msg("table [~p] attributes are different\n",[Tab]),false
					 end
				 catch
					 _:_-> true
				 end,
	case NeedCreate of
		true-> 
			case Indices of
				[]-> mnesia:create_table(Tab, [{disc_copies,[node()]},
										 {attributes, Attributes},
										 {type,Type}]);
				_->
				  mnesia:create_table(Tab, [{disc_copies,[node()]},
										 {attributes, Attributes},
										 {index,Indices},
										 {type,Type}])
			end;
		false-> ok
	end.
	
create_table_ram(Tab,Attributes,Indices,Type)->
	NeedCreate = try
					 case mnesia:table_info(Tab,attributes) of
						Attributes -> false;
						_->  
							slogger:msg("table [~p] attributes are different\n",[Tab]),false
					 end
				 catch
					 _:_-> true
				 end,
	case NeedCreate of
		true-> 
			case Indices of
				[]-> mnesia:create_table(Tab, [{ram_copies,[node()]},
										 {attributes, Attributes},
										 {type,Type}]);
				_->
				  mnesia:create_table(Tab, [{ram_copies,[node()]},
										 {attributes, Attributes},
										 {index,Indices},
										 {type,Type}])
			end;
		false-> ok
	end.	
	

force_disc_copies(Node,Table)->
	RamCopies = try
					mnesia:table_info(Table, ram_copies)
				catch
				_:_->
					[]
				end,
	DiscCopies= try
					mnesia:table_info(Table, disc_copies)
				catch
				_:_->
					[]
				end,
	
	case lists:member(Node, DiscCopies) of
		true->  {ok,ignor};
		false->
			case lists:member(Node,RamCopies ) of
				true->mnesia:change_table_copy_type(Table, Node, disc_copies);
				false->mnesia:add_table_copy(Table,Node,disc_copies)
			end
	end.

correct_need_config_tables(NeedConfigTables)->
	AllTables = mnesia:system_info(tables),
	lists:foldl(fun(Tab,Acc)->
						case Tab of
							schema-> Acc;
							_-> case is_table_in_list(Tab,NeedConfigTables) of
									true-> [Tab|Acc];
									_-> Acc
								end
						end
				end, [], AllTables).

is_table_in_list(Table,SplitTables)->
	TabStr = atom_to_list(Table),
	SplitTableStr = lists:map(fun(T)-> atom_to_list(T) end, SplitTables),
	NewTabs = lists:filter(fun(T)->
						     StrIndex = string:str(TabStr, T),
						     if ( StrIndex =:=0 )-> false;
							    true-> true
						     end
					       end, SplitTableStr),
	if erlang:length(NewTabs) >0 -> true;
	   true-> false
	end.
	

add_db_ram_node(NewNode,Tables) -> 
    RunningNodeList = mnesia:system_info(running_db_nodes),  
    add_extra_node(RunningNodeList, NewNode),  
    mnesia:change_table_copy_type(schema, NewNode, disc_copies),  
    rpc:call(NewNode, mnesia, stop, []),  
    timer:sleep(1000),  
    rpc:call(NewNode, mnesia, start, []),  
    timer:sleep(1000),  
	NeedConfigTables = db_tools:correct_need_config_tables(Tables),
    add_ram_tables(NeedConfigTables, NewNode).
  
add_dbslave_node(NewNode) -> 
    RunningNodeList = mnesia:system_info(running_db_nodes),  
    add_extra_node(RunningNodeList, NewNode),  
    mnesia:change_table_copy_type(schema, NewNode, disc_copies),  
    rpc:call(NewNode, mnesia, stop, []),  
    timer:sleep(1000),  
    rpc:call(NewNode, mnesia, start, []),  
    timer:sleep(1000),  
	TablesList = mnesia:system_info(tables),
    add_disc_tables(TablesList, NewNode).

add_extra_node([], _NewNode) ->  
    null;  
add_extra_node(_RunningNodeList = [Node | T], NewNode) ->  
    rpc:call(Node, mnesia, change_config, [extra_db_nodes, [NewNode]]),  
    add_extra_node(T, NewNode).  
  
add_ram_tables([], _NewNode) ->  
    null;  
add_ram_tables(_TableList = [Table | T], NewNode) ->  
    mnesia:add_table_copy(Table, NewNode, ram_copies),  
    add_ram_tables(T, NewNode).


add_disc_tables([], _NewNode) ->  
    null;  
add_disc_tables(_TableList = [Table | T], NewNode) ->  
    mnesia:add_table_copy(Table, NewNode, disc_copies),  
    add_disc_tables(T, NewNode).

wait_for_tables_loop(_IsRemote,0,_TabList)->
	slogger:msg("wait_for_tables out of times~n");
wait_for_tables_loop(IsRemote,N,TabList)->
	F = if IsRemote =:= local -> 
			   fun()-> wait_for_tables_norpc(TabList, ?DB_WAIT_TABLE_TIMEOUT) end;
		   true->
			   fun()-> wait_for_tables_rpc(TabList, ?DB_WAIT_TABLE_TIMEOUT) end
		end,
	
	case F() of
		ok-> ok;
		Reason->
			slogger:msg("wait_for_tables failed IsRemote ~p Reason ~p  TabList ~p ~n",[IsRemote,Reason,TabList]),
			timer:sleep(1000),
			wait_for_tables_loop(IsRemote,N-1,TabList)
%%		{timeout,BadTabList}->  slogger:msg("wait_for_tables timeout ~p~n",[BadTabList]);
%%		{error, Reason}-> case Reason of
%%							  {node_not_running,_CurNode}->
%%								  timer:sleep(1000),
%%								  slogger:msg("mnesia error :node_not_running try again~n"),
%%								  wait_for_tables_loop(IsRemote,N-1,TabList);
%%							  _ -> slogger:msg("wait_for_tables error ~p~n",[Reason])
%%						  end;
%%		Any-> slogger:msg("wait_for_tables failed:~p~n",[Any])
	end.
	
wait_ets_init()->
	wait_for_all_db_tables(),
	io:format("wait_for_all_db_tables ~n"),
	EtsInit = get_ets_table_mods(node()),
	io:format("EtsInit ~p ~n",[EtsInit]),
	config_ets_init(EtsInit).

wait_ets_init_fliter(EtsFliter)->
	wait_for_all_db_tables(),
	try
		EtsFliter:init()
	catch
		E:R->slogger:msg("init ets ~p except(~p:~p)! check the app configs\n",[EtsFliter,E,R])
	end,
	slogger:msg("ets ~p are ok now!\n",[EtsFliter]).

%%[Modules]/all
get_ets_table_mods(Node)->
	Apps = node_util:get_run_apps(Node),
	lists:foldl(fun(App,Tables)->
				case Tables of
					all->
						all;
					_->
						case env:get2(nodes_ets, App, []) of
							all->
								all;
							AppEtsIni->
								Tables++AppEtsIni
						end
				end end,[], Apps).

wait_ets_create()->
	CreateMods = get_ets_table_mods(node()),
	config_ets_create(CreateMods).
config_ets_create(all)->
	mod_util:behaviour_apply(ets_operater_mod,create,[]);
config_ets_create(CreateMods)->
	lists:foreach(fun(M)->
						try
							M:create()
						catch
							_:_->slogger:msg("create ets ~p except! check the app configs\n",[M])
						end				  
				end, CreateMods),
	case CreateMods of
		[]-> ignor;
		_->
			slogger:msg("ets ~p are created now!\n",[CreateMods])
	end.

config_ets_init(all)->
	mod_util:behaviour_apply(ets_operater_mod,init,[]);
config_ets_init(InitMods)->
	lists:foreach(fun(M)->
						try
							M:init()
						catch
							E:R->slogger:msg("init ets ~p except(~p:~p)! check the app configs\n",[M,E,R])
						end				  
				end, InitMods),
	slogger:msg("ets ~p are ok now!\n",[InitMods]).

wait_for_tables_rpc(TableList,TimeOut)->
	DbNode = node_util:get_dbnode(),
	case rpc:call(DbNode, mnesia, wait_for_tables, [TableList,TimeOut]) of
		{badrpc,Reason}-> {error,Reason};
		Result->Result
	end.

wait_for_tables_norpc(TableList,TimeOut)->
	mnesia:wait_for_tables(TableList,TimeOut).

wait_for_all_db_tables_in_db_node()->
	AllTablesList = mnesia:system_info(tables),
	case wait_for_tables_norpc(AllTablesList, ?DB_WAIT_TABLE_TIMEOUT) of
		ok->
			ok;
		Reason->
			slogger:msg("wait_for_all_db_tables_in_db_node ERROR ~p ~n",[Reason]),
			error
	end.
	
wait_for_all_db_tables()->	
	wait_tables_in_dbnode(),	
	io:format("wait_tables_in_dbnode end ~n"),
	wait_for_local_ram_tables().

wait_tables_in_dbnode()->
	DbNode = node_util:get_dbnode(),
	case rpc:call(DbNode, ?MODULE, wait_for_all_db_tables_in_db_node, [],infinity) of
		ok->
			ok;
		Reason-> 
			slogger:msg("wait_for_all_db_tables ERROR ~p ~n",[Reason]),
			timer:sleep(1000),
			wait_for_all_db_tables()
	end.

wait_for_local_ram_tables()->
	case is_need_ram_table(node()) of
		true->
			wait_for_tables_loop(local,1000,db_operater_mod:get_all_ram_table());
		_->
			nothing
	end.

is_need_ram_table(Node)->
	get_node_ram_tables(Node) =/=[].

get_node_ram_tables(Node)->
	ShareTypes = env:get(nodes_ram_table,[]),
	case lists:filter(fun({ShareType,_})->node_util:check_snode_match(ShareType,Node) end, ShareTypes) of
		[]->
			[];
		[{_,Tables}|_]->
			Tables
	end.
	
	
	