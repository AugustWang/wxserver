%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-8
%% Description: TODO: Add description to db_ini
-module(db_ini).
-compile(export_all).
%%
%% Include files
%%
%%
%% Exported Functions
%%
-export([db_init_master/0,db_init_slave/0,create_split_table/3,db_init_line_master/0]). 

%%
%% API Functions
%%
%%

%%
%%
db_init_master()->
	db_operater_mod:start(),
	case mnesia:system_info(is_running) of
		yes ->	mnesia:stop();
		no -> o;
		starting -> mnesia:stop()
	end,
	mnesia:create_schema([node()]),
	db_init_disc_tables().

db_init_line_master()->
	db_operater_mod:start(),
	NeedShareNodes = 
	lists:filter(fun(Node)-> 
				db_tools:is_need_ram_table(Node)		 
		 end,node_util:get_all_nodes() ),
	lists:foreach(fun(Node)-> rpc:call(Node, mnesia, stop,[]) end, NeedShareNodes),
	mnesia:delete_schema(NeedShareNodes),
	mnesia:create_schema(NeedShareNodes),
	lists:foreach(fun(Node)-> rpc:call(Node, mnesia, start,[]) end, NeedShareNodes),
	db_init_ram_tables(),
	lists:foreach(fun(Node)->
				RamTables = db_tools:get_node_ram_tables(Node),
				lists:foreach(fun(Table)-> 
					TableNodes = mnesia:table_info(Table, ram_copies),
					case lists:member(Node, TableNodes) of
						false->
							mnesia:add_table_copy(Table,Node, ram_copies);
						true->
							ignor
				end end, RamTables)	
				end, NeedShareNodes).

db_init_slave()->
	DbNode = node_util:get_dbnode(),
	db_tools:config_disc_db_node(DbNode).

%%
%% Local Functions
%%
db_init_disc_tables()->
	mnesia:start(),
	db_operater_mod:create_all_disc_table().

db_init_ram_tables()->
	mnesia:start(),
	db_operater_mod:create_all_ram_table().

create_split_table(CreateMod,BaseTable,Table)->
	CreateMod:create_mnesia_split_table(BaseTable,Table).

