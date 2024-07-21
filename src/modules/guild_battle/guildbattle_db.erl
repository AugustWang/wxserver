%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-11-1
%% Description: TODO: Add description to guildbattle_db
-module(guildbattle_db).

%%
%% Include files
%%
-include("guildbattle_def.hrl").

-define(ETS_TABLE,guild_battle_proto_ets).
%%
%% Exported Functions
%%
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
	db_tools:create_table_disc(guild_battle_result,record_info(fields,guild_battle_result),[],set),
	db_tools:create_table_disc(guild_battle_proto,record_info(fields,guild_battle_proto),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{guild_battle_proto,proto},{guild_battle_result,disc}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?ETS_TABLE,[set,named_table]).

init()->
	db_operater_mod:init_ets(guild_battle_proto, ?ETS_TABLE,#guild_battle_proto.week).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(Week)->
	try
		case ets:lookup(?ETS_TABLE, Week) of
			[]->
				[];
            [Info]-> 
				{_,Term} = Info,
				Term
		end
	catch
		_:_-> []
	end.

get_checktime(Term)->
	element(#guild_battle_proto.checktime,Term).

get_startapplytime(Term)->
	element(#guild_battle_proto.startapplytime,Term).

get_stopapplytime(Term)->
	element(#guild_battle_proto.stopapplytime,Term).

get_starttime(Term)->
	element(#guild_battle_proto.starttime,Term).

add_proto_to_mnesia(Term)->
	Object = util:term_to_record(Term,guild_battle_proto),
	dal:write(Object).

gm_add_proto_to_ets_rpc(Term)->
	Object = util:term_to_record(Term,guild_battle_proto),
	lists:foreach(fun(N)-> rpc:call(N,?MODULE,init,[]) end ,node_util:get_mapnodes() ++ node_util:get_guilnodes()).

gm_delete_proto_from_ets_rpc(Term)->
	Object = util:term_to_record(Term,guild_battle_proto),
	lists:foreach(fun(N)-> rpc:call(N,?MODULE,gm_delete_proto_from_ets,[Object]) end ,node_util:get_mapnodes() ++ node_util:get_guilnodes()).

gm_delete_proto_from_ets(Term)->
	try
		Id = erlang:element(#guild_battle_proto.week,Term),
		ets:delete_object(?ETS_TABLE,{Id,Term})
	catch
		_Error:Reason->
			slogger:msg("delete_proto_from_ets Reason ~p ~n",[Reason]),
			{error,Reason}
	end.
		 
clear_guildbattle_last_score()->
	dal:clear_table_rpc(guild_battle_result).

add_guildbattle_score(ResultList)->
	lists:foreach(fun({GuildName,GuildSorce,Rank})->
						  dal:write_rpc({guild_battle_result,GuildName,GuildSorce,Rank})
					end,ResultList).

get_guildbattle_score()->
	case dal:read_rpc(guild_battle_result) of
		{ok,Info}->
			Info;
		_->
			[]
	end.







