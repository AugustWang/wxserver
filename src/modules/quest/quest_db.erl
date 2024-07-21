%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-6-24
%% Description: TODO: Add description to quest_db
-module(quest_db).
-include("mnesia_table_def.hrl").

-define(QUEST_TABLE_NAME,ets_quest_info).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([get_info/1]).


-compile(export_all).
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
	ets:new(?QUEST_TABLE_NAME, [set,named_table]).

init()->
	db_operater_mod:init_ets(quests, ?QUEST_TABLE_NAME,#quests.id).

create_mnesia_table(disc)->
	db_tools:create_table_disc(quests,record_info(fields,quests),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{quests,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(QuestId)->
	case ets:lookup(?QUEST_TABLE_NAME,QuestId ) of
		[]->[];
		[{_QuestId,Term}]-> Term
	end.

get_id(QuestInfo)->
	erlang:element(#quests.id, QuestInfo).

get_isactivity(QuestInfo)->
	erlang:element(#quests.isactivity, QuestInfo).

get_level(QuestInfo)->
	erlang:element(#quests.level, QuestInfo).

get_limittime(QuestInfo)->
	erlang:element(#quests.limittime, QuestInfo).

get_required(QuestInfo)->
	erlang:element(#quests.required, QuestInfo).

get_prevquestid(QuestInfo)->
	erlang:element(#quests.prevquestid, QuestInfo).

get_nextquestid(QuestInfo)->
	erlang:element(#quests.nextquestid, QuestInfo).

get_rewrules(QuestInfo)->
	erlang:element(#quests.rewrules, QuestInfo).

get_rewitem(QuestInfo)->
	erlang:element(#quests.rewitem, QuestInfo).


get_choiceitemid(QuestInfo)->
	erlang:element(#quests.choiceitemid, QuestInfo).

get_rewxp(QuestInfo)->
	erlang:element(#quests.rewxp, QuestInfo).


get_reworreqmoney(QuestInfo)->
	erlang:element(#quests.reworreqmoney, QuestInfo).
	
get_reqmob(QuestInfo)->
	erlang:element(#quests.reqmob, QuestInfo).

get_reqmobitem(QuestInfo)->
	erlang:element(#quests.reqmobitem, QuestInfo).

get_objectivemsg(QuestInfo)->
	erlang:element(#quests.objectivemsg, QuestInfo).

get_objectivetext(QuestInfo)->
	erlang:element(#quests.objectivetext, QuestInfo).

get_acc_script(QuestInfo)->
	erlang:element(#quests.acc_script, QuestInfo).
		
get_on_acc_script(QuestInfo)->
	erlang:element(#quests.on_acc_script, QuestInfo).
	
get_com_script(QuestInfo)->
	erlang:element(#quests.com_script, QuestInfo).
	
get_on_com_script(QuestInfo)->
	erlang:element(#quests.on_com_script, QuestInfo).
	
get_direct_com_disable(QuestInfo)->
	erlang:element(#quests.direct_com_disable, QuestInfo).
