%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(faction_relations_db).
-include("mnesia_table_def.hrl").

-define(FACTION_RELATIONS_TABLE_NAME,faction_relations_db).

-compile(export_all).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(faction_relations,record_info(fields,faction_relations),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{faction_relations,proto}].

delete_role_from_db(_RoleId)->
	nothing.

create()->
	ets:new(?FACTION_RELATIONS_TABLE_NAME, [set,named_table]).

init()->
	db_operater_mod:init_ets(faction_relations, ?FACTION_RELATIONS_TABLE_NAME,#faction_relations.id).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(FactionId)->
	case ets:lookup(?FACTION_RELATIONS_TABLE_NAME,FactionId ) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_id(FactionRInfo)->
		erlang:element(#faction_relations.id, FactionRInfo).

get_friendly(FactionRInfo)->
		erlang:element(#faction_relations.friendly, FactionRInfo).

get_opposite(FactionRInfo)->
		erlang:element(#faction_relations.opposite, FactionRInfo).
