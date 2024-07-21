%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(chess_spirit_db).

%%
%% Include files
%%
-include("chess_spirit_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

-define(CHESS_SPIRIT_CONFIG_ETS,'chess_spirit_config').
-define(CHESS_SPIRIT_SECTION_ETS,'chess_spirit_section').
-define(CHESS_SPIRIT_REWARDS_ETS,'chess_spirit_rewards').


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
	db_tools:create_table_disc(role_chess_spirit_log,record_info(fields,role_chess_spirit_log),[],set),
	db_tools:create_table_disc(chess_spirit_config,record_info(fields,chess_spirit_config),[],set),
	db_tools:create_table_disc(chess_spirit_section,record_info(fields,chess_spirit_section),[],set),
	db_tools:create_table_disc(chess_spirit_rewards,record_info(fields,chess_spirit_rewards),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{role_chess_spirit_log,disc},{chess_spirit_config,proto},{chess_spirit_section,proto},{chess_spirit_rewards,proto}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_chess_spirit_log, RoleId).

create()->
	ets:new(?CHESS_SPIRIT_CONFIG_ETS, [set,named_table]),
	ets:new(?CHESS_SPIRIT_SECTION_ETS, [set,named_table]),
	ets:new(?CHESS_SPIRIT_REWARDS_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(chess_spirit_config, ?CHESS_SPIRIT_CONFIG_ETS,#chess_spirit_config.npcid),
	db_operater_mod:init_ets(chess_spirit_section, ?CHESS_SPIRIT_SECTION_ETS,#chess_spirit_section.type_section),
	db_operater_mod:init_ets(chess_spirit_rewards, ?CHESS_SPIRIT_REWARDS_ETS,#chess_spirit_rewards.type_level).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_chess_spirit_config_info(NpcId)->
	case ets:lookup(?CHESS_SPIRIT_CONFIG_ETS,NpcId) of
		[]-> [];
		[{_,Term}]-> Term
	end.

get_chess_spirit_section_info(Type,Section)->
	case ets:lookup(?CHESS_SPIRIT_SECTION_ETS,{Type,Section}) of
		[]-> [];
		[{_,Term}]-> Term
	end.

get_chess_spirit_rewards_info(Type,RoleLevel)->
		case ets:lookup(?CHESS_SPIRIT_REWARDS_ETS,{Type,RoleLevel}) of
		[]-> [];
		[{_,Term}]-> Term
	end.

get_config_npcid(ConfigInfo)->
	element(#chess_spirit_config.npcid,ConfigInfo).

get_config_type(ConfigInfo)->
	element(#chess_spirit_config.type,ConfigInfo).

get_config_fixed_skills(ConfigInfo)->
	element(#chess_spirit_config.fixed_skills,ConfigInfo).

get_config_random_skills(ConfigInfo)->
	element(#chess_spirit_config.random_skills,ConfigInfo).

get_config_max_section(ConfigInfo)->
	element(#chess_spirit_config.max_section,ConfigInfo).

get_config_section_duration(ConfigInfo)->
	element(#chess_spirit_config.section_duration,ConfigInfo).

get_config_chess_skills(ConfigInfo)->
	element(#chess_spirit_config.chess_skills,ConfigInfo).

get_config_chess_max_power(ConfigInfo)->
	element(#chess_spirit_config.chess_max_power,ConfigInfo).

get_config_chess_power_addation(ConfigInfo)->
	element(#chess_spirit_config.chess_power_addation,ConfigInfo).

get_section_type_section(SectionInfo)->
	element(#chess_spirit_section.type_section,SectionInfo).

get_section_soulpower(SectionInfo)->
	element(#chess_spirit_section.power_rewards,SectionInfo).

get_section_spawns(SectionInfo)->
	element(#chess_spirit_section.spawns,SectionInfo).

get_section_item_rewards(SectionInfo)->
	element(#chess_spirit_section.item_rewards,SectionInfo).

get_section_role_skills_level(SectionInfo)->
	element(#chess_spirit_section.skills_level,SectionInfo).

get_reward_exp_args(RewardInfo)->
	element(#chess_spirit_rewards.exp_args,RewardInfo).

get_reward_expect_sec(RewardInfo)->
	element(#chess_spirit_rewards.expect_sec,RewardInfo).

get_role_chess_spirit_log(RoleId)->
	case dal:read_rpc(role_chess_spirit_log,RoleId) of
		{ok,[]}->[];
		{ok,[{_,_,LastInfo,BestInfo,[]}]}->{LastInfo,BestInfo};
		{failed,badrpc,Reason}-> slogger:msg("get_role_congratu_log failed ~p:~p~n",[badrpc,Reason]),[];
		{failed,Reason}-> slogger:msg("get_role_congratu_log failed :~p~n",[Reason]),[]
	end.

sync_update_role_chess_spirit_log(RoleId,LastInfo,BestInfo)->
	dmp_op:sync_write(RoleId,{role_chess_spirit_log,RoleId,LastInfo,BestInfo,[]}).
