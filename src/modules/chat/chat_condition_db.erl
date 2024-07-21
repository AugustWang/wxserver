%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%%
%%
-module(chat_condition_db).
%% 
%% define
%%

-include("mnesia_table_def.hrl").
-define(CHAT_CONDITION_ETS,chat_condition_ets).

-export([get_chat_conditioninfo/1,get_id/1,get_items/1,get_level/1]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,init/0,create/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?CHAT_CONDITION_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(chat_condition, ?CHAT_CONDITION_ETS,#chat_condition.id).

create_mnesia_table(disc)->
	db_tools:create_table_disc(chat_condition,record_info(fields,chat_condition),[],set). %set

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{chat_condition,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_chat_conditioninfo(Id)-> 
	case ets:lookup(?CHAT_CONDITION_ETS, Id) of
		[]->[];
        [{_,Term}]-> Term
	end.
       
get_id(ChatConditionInfo)->
	element(#chat_condition.id,ChatConditionInfo).

get_items(ChatConditionInfo)->
	element(#chat_condition.items,ChatConditionInfo).

get_level(ChatConditionInfo)->
	element(#chat_condition.level,ChatConditionInfo).
