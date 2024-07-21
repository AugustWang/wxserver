%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(db_operater_mod).

-define(DB_MOD_TABLE,dp_operater_mods).
-define(DB_SPLIT_TABLE,dp_split_tables).
-export([start/0]).
-export([start_module/2,init_ets/3]).
-export([create_all_disc_table/0,create_all_ram_table/0]).
-export([get_split_table_and_mod/1,get_all_split_table_and_mod/0]).
-export([get_all_ram_table/0]).
-export([get_backup_filter_tables/0]).
-export([behaviour_info/1]).
-export([delete_role_from_db/1]).

%%
%%	behaviour fun
%%	copy this:		[start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1]
%%

behaviour_info(callbacks) ->
    [
	{start,0},								%% start mod							%% args:[module,option]
	{create_mnesia_table,1},				%% create table not split 				%% args: ram/disc
	{create_mnesia_split_table,2},			%% create split table					%% args:[BaseTable,TrueTabName]
	{delete_role_from_db,1},				%% delete on role for persistent table  %% args:[roleid]
	{tables_info,0}							%% {DB,Type} Type:disc_split/disc/ram/proto
    ];
behaviour_info(_Other) ->
    undefined.


%% @doc start gen_mod
start() ->
    ?DB_MOD_TABLE = ets:new(?DB_MOD_TABLE,
        [public, set, named_table, {keypos, 1}]),
	?DB_SPLIT_TABLE = ets:new(?DB_SPLIT_TABLE,
        [public, set, named_table, {keypos, 1}]),
	mod_util:behaviour_apply(db_operater_mod,start,[]),
	slogger:msg("db_operater_mod start end ~n"),
    ok.

start_module(Module, Opts)->
	TablesInfo = Module:tables_info(),
	lists:foreach(fun({Table,Type})-> 
				case Type of
					disc_split->
						true = ets:insert(?DB_SPLIT_TABLE, {Table,Module});
					_->
						nothing
				end end, TablesInfo),
	true = ets:insert(?DB_MOD_TABLE, {Module, Opts,TablesInfo}).

create_all_disc_table()->
	ets:foldl(fun({Module,_,_},_)->
				Module:create_mnesia_table(disc)	  
			end,[], ?DB_MOD_TABLE).

delete_role_from_db(RoleId)->
	ets:foldl(fun({Module,_,_},_)->
				Module:delete_role_from_db(RoleId)	  
			end,[], ?DB_MOD_TABLE).

create_all_ram_table()->
	AllRamMod = ets:foldl(fun({Module,_,TablesInfo},AccMods)->
					case lists:keymember(ram,2,TablesInfo) of
						true->
							[Module|AccMods];
						_->
							AccMods
					end
			end,[], ?DB_MOD_TABLE),
	lists:foreach(fun(Mod)->Mod:create_mnesia_table(ram) end,AllRamMod).

get_all_ram_table()->
	ets:foldl(fun({_,_,TablesInfo},AccTables)->
					case lists:keyfind(ram,2,TablesInfo) of
						{Table,ram}->
							[Table|AccTables];
						_->
							AccTables
					end
			end,[], ?DB_MOD_TABLE).

get_split_table_and_mod(BaseTab)->
	case ets:lookup(?DB_SPLIT_TABLE, BaseTab) of
		[]->
			[];
		[Info]->
			Info
	end.
	
get_all_split_table_and_mod()->
	ets:tab2list(?DB_SPLIT_TABLE).

get_backup_filter_tables()->
	ets:foldl(fun({_,_,TablesInfo},AccMods)->
					lists:foldl(fun({TableName,TableType},AccTables)->
							case is_backup_filter_table({TableName,TableType}) of
								true->
									[TableName|AccTables];
								_->
									AccTables
							end end,[],TablesInfo) ++ AccMods 
			end,[], ?DB_MOD_TABLE).

is_backup_filter_table({_,ram})->
	true;
is_backup_filter_table({_,proto})->
	true;
is_backup_filter_table(_)->
	false.

%% args:
%% SourceDb: which db read from.
%% Ets: ets to write
%% EtsKeyPosOrPoses : [KeyPos]/[KeyPos1,KeyPos2,...]/KeyPos

init_ets(SourceDb,Ets,EtsKeyPosOrPoses) ->
	ets:delete_all_objects(Ets),
	case dal:read_rpc(SourceDb) of
		{ok,TermList} ->
			lists:foreach(fun(Term) -> 
					add_term_to_ets(Term,Ets,EtsKeyPosOrPoses)
					end,
					TermList);
		Error->
			slogger:msg("init_ets ~p failed from db ~p ~p ~p ~n",[Ets,SourceDb,Error])
	end.

add_term_to_ets(Term,Ets,KeyPoses)when is_list(KeyPoses)->
	Keyes = lists:map(fun(PosTmp)-> erlang:element(PosTmp,Term) end, KeyPoses),
	case KeyPoses of
		[KeyPos]->
			add_term_to_ets(Term,Ets,KeyPos);
		_->
			Key = erlang:list_to_tuple(Keyes),
			true  = ets:insert(Ets,{Key,Term})
	end;
add_term_to_ets(Term,Ets,KeyPos) ->
	Key = erlang:element(KeyPos,Term),
	true  = ets:insert(Ets,{Key,Term}).
