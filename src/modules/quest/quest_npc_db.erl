%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------

-module(quest_npc_db).
-include("mnesia_table_def.hrl").
%%
%% Include files
%%
-define(QUEST_NPC_TABLE_ETS,ets_quest_npc_info).
-define(EVERQUEST_NPC_TABLE_ETS,ets_everquest_npc_info).
%%
%% Exported Functions
%%
-export([get_quest_action/1,get_questinfo_by_npcid/1,get_everquestlist_by_npcid/1]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,init/0,create/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?QUEST_NPC_TABLE_ETS, [set,named_table]),
	ets:new(?EVERQUEST_NPC_TABLE_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(quest_npc,?QUEST_NPC_TABLE_ETS,#quest_npc.npcid),
	db_operater_mod:init_ets(everquest_list,?EVERQUEST_NPC_TABLE_ETS,#everquest_list.npcid).

create_mnesia_table(disc)->
	db_tools:create_table_disc(quest_npc,record_info(fields,quest_npc),[],set),
	db_tools:create_table_disc(everquest_list,record_info(fields,everquest_list),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{quest_npc,proto},{everquest_list,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_questinfo_by_npcid(NpcId)->        
	case ets:lookup(?QUEST_NPC_TABLE_ETS,NpcId) of
		[]->[];
    	[{_,Value}]-> Value 
	end.

get_everquestlist_by_npcid(NpcId)->
	case ets:lookup(?EVERQUEST_NPC_TABLE_ETS,NpcId) of
		[]->[];
        [{_,Value}]-> erlang:element(#everquest_list.everlist, Value) 
	end.

get_quest_action(QuestNpc)->
	element(#quest_npc.quest_action,QuestNpc).
