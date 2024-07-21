%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-10-12
%% Description: TODO: Add description to guild_treasure_transport_db
-module(guild_treasure_transport_db).

%%
%% Include files
%%
-define(GUILD_TREATURE_TRANSPORT_CONSUME_ETS,guild_treasure_transport_consume_ets).
-include("treasure_transport_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

-export([create/0,init/0]).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(guild_treasure_transport_consume,record_info(fields,guild_treasure_transport_consume),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{guild_treasure_transport_consume,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?GUILD_TREATURE_TRANSPORT_CONSUME_ETS,[named_table,set]).

init()->
	db_operater_mod:init_ets(guild_treasure_transport_consume, ?GUILD_TREATURE_TRANSPORT_CONSUME_ETS, #guild_treasure_transport_consume.guildlevel).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_guild_treasure_transport_consume_info(GuildLevel)->
	case ets:lookup(?GUILD_TREATURE_TRANSPORT_CONSUME_ETS,GuildLevel) of
		[]->
			[];
		[{_,ConsumeInfo}]->
			ConsumeInfo
	end.


get_guild_treasure_transport_consume(ConsumeInfo)->
	element(#guild_treasure_transport_consume.consume,ConsumeInfo).


%%
%% Local Functions
%%

