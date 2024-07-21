%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-28
%% Description: TODO: Add description to chrisitmas_activity_db
-module(christmas_activity_db).

%%
%% Include files
%%
-include("christmas_activity_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

-define(CHRISITMAS_ACTIVITY_REWARD_ETS,chrisitmas_activity_reward_ets).
-define(CHRISITMAS_ACTIVITY_ETS,chrisitmas_activity_ets).
%%
%% API Functions
%%
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
	db_tools:create_table_disc(christmas_tree_db,record_info(fields,christmas_tree_db),[],set),
	db_tools:create_table_disc(christmas_activity_reward,record_info(fields,christmas_activity_reward),[],set),
	db_tools:create_table_disc(christmas_tree_config,record_info(fields,christmas_tree_config),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{christmas_activity_config,proto},{christmas_tree_db,disc},{christmas_activity_reward,proto}].

delete_role_from_db(NpcId)->
	dal:delete_rpc(christmas_tree_db, NpcId).

create()->
	ets:new(?CHRISITMAS_ACTIVITY_ETS, [set,named_table]),
	ets:new(?CHRISITMAS_ACTIVITY_REWARD_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(christmas_tree_config, ?CHRISITMAS_ACTIVITY_ETS,#christmas_tree_config.npcid),
	db_operater_mod:init_ets(christmas_activity_reward, ?CHRISITMAS_ACTIVITY_REWARD_ETS,#christmas_activity_reward.type).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_christmas_tree_info(NpcId)->
	case dal:read_rpc(christmas_tree_db) of
		{ok,[]}-> [];
		{ok,[Info]}-> Info;
		_->[]
	end.

get_christmas_tree_config(NpcId)->
	case ets:lookup(?CHRISITMAS_ACTIVITY_ETS,NpcId) of
		[]-> [];
		[{_,Term}]-> Term
	end.

get_christmas_activity_reward_info(Type)->
	case ets:lookup(?CHRISITMAS_ACTIVITY_REWARD_ETS,Type) of
		[]->[];
		[{_,RewardInfo}]->RewardInfo
	end.

get_christmas_activity_consume(RewardInfo)->
	element(#christmas_activity_reward.consume,RewardInfo).

get_christmas_activity_reward(RewardInfo)->
	element(#christmas_activity_reward.reward,RewardInfo).
	
get_christmas_tree_init_hp(CrisTreeInfo)->
	element(#christmas_tree_config.init_hp,CrisTreeInfo).

get_christmas_tree_max_hp(CrisTreeInfo)->
	element(#christmas_tree_config.max_hp,CrisTreeInfo).

get_next_proto_from_cristreeinfo(CrisTreeInfo)->
	element(#christmas_tree_config.next_proto,CrisTreeInfo).

write_to_db(NpcId,Hp)->
	dal:write_rpc({christmas_tree_db,NpcId,Hp}).









