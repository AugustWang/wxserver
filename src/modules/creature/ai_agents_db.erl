%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(ai_agents_db).
-include("mnesia_table_def.hrl").

-define(AI_AGENTS_TABLE_NAME,ai_agents_db).

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
	db_tools:create_table_disc(ai_agents,record_info(fields,ai_agents),[],bag).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{ai_agents,proto}].

delete_role_from_db(_)->
	nothing.

create()->
	ets:new(?AI_AGENTS_TABLE_NAME, [bag,named_table]).

init()->
	db_operater_mod:init_ets(ai_agents, ?AI_AGENTS_TABLE_NAME,#ai_agents.entry).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_all_agents(Entry)->
	case ets:lookup(?AI_AGENTS_TABLE_NAME,Entry ) of
		[]->[];
		Lists-> lists:map(fun({_,Term})-> Term end, Lists)
	end.

get_id(AgentsRInfo)->
	erlang:element(#ai_agents.id, AgentsRInfo).

get_entry(AgentsRInfo)->
	erlang:element(#ai_agents.entry, AgentsRInfo).

get_next_ai(AgentsRInfo)->
	erlang:element(#ai_agents.next_ai, AgentsRInfo).

get_type(AgentsRInfo)->
	erlang:element(#ai_agents.type, AgentsRInfo).

get_events(AgentsRInfo)->
	erlang:element(#ai_agents.events, AgentsRInfo).

get_conditions(AgentsRInfo)->
	erlang:element(#ai_agents.conditions, AgentsRInfo).

get_chance(AgentsRInfo)->
	erlang:element(#ai_agents.chance, AgentsRInfo).

get_maxcount(AgentsRInfo)->
	erlang:element(#ai_agents.maxcount, AgentsRInfo).

get_skill(AgentsRInfo)->
	erlang:element(#ai_agents.skill, AgentsRInfo).

get_target(AgentsRInfo)->
	erlang:element(#ai_agents.target, AgentsRInfo).

get_cooldown(AgentsRInfo)->
	erlang:element(#ai_agents.cooldown, AgentsRInfo).

get_msgs(AgentsRInfo)->
	erlang:element(#ai_agents.msgs, AgentsRInfo).

get_script(AgentsRInfo)->
	erlang:element(#ai_agents.script, AgentsRInfo).
%%
%% Local Functions
%%


import_ai_agents(File)->	
	dal:clear_table(ai_agents),
	case file:consult(File) of
		{ok,[Terms]}->
			add_ai_agents_to_mnesia(Terms);
		{error,Reason} ->
			slogger:msg("file:consult( ~p ) error Reason ~p ~n",[File,Reason])
	end.

add_ai_agents_to_mnesia(Terms)->
	MnesiaObjcts = lists:map(fun(X)-> util:term_to_record(X,ai_agents)end, Terms),
	lists:foreach(fun(X)-> dal:write(X) end, MnesiaObjcts).
