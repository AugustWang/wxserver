%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(everquest_db).
-include("mnesia_table_def.hrl").

-define(EVERQUEST_TABLE_NAME,everquests_table).%%@@wb20130322 ets_everquest_db


-export([get_info/1,get_id/1,get_type/1,get_special_tag/1,get_required/1,get_qualityrates/1,get_datelines/1,
		 get_refresh_info/1,get_rounds_num/1,get_clear_time/1,get_quests/1,get_sections/1,
		 get_section_counts/1,get_section_rewards/1,get_reward_exp_type/1]).

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
	ets:new(?EVERQUEST_TABLE_NAME, [set,public,named_table]).

init()->
	db_operater_mod:init_ets(everquests, ?EVERQUEST_TABLE_NAME,#everquests.id).

create_mnesia_table(disc)->
	db_tools:create_table_disc(everquests,record_info(fields,everquests),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{everquests,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(EverQId)->
	case ets:lookup(?EVERQUEST_TABLE_NAME,EverQId ) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_id(QuestInfo)->
	erlang:element(#everquests.id, QuestInfo).

get_type(QuestInfo)->
	erlang:element(#everquests.type, QuestInfo).

get_special_tag(QuestInfo)->
	erlang:element(#everquests.special_tag, QuestInfo).

get_required(QuestInfo)->
	erlang:element(#everquests.required, QuestInfo).

get_datelines(QuestInfo)->
	erlang:element(#everquests.datelines, QuestInfo).

get_qualityrates(QuestInfo)->
	erlang:element(#everquests.qualityrates, QuestInfo).

get_refresh_info(QuestInfo)->
	erlang:element(#everquests.refresh_info, QuestInfo).

get_rounds_num(QuestInfo)->
	erlang:element(#everquests.rounds_num, QuestInfo).

get_clear_time(QuestInfo)->
	erlang:element(#everquests.clear_time, QuestInfo).

get_quests(QuestInfo)->
	erlang:element(#everquests.quests, QuestInfo).

get_sections(QuestInfo)->
	erlang:element(#everquests.sections, QuestInfo).

get_section_counts(QuestInfo)->
	erlang:element(#everquests.section_counts, QuestInfo).

get_section_rewards(QuestInfo)->
	erlang:element(#everquests.section_rewards, QuestInfo).

get_reward_exp_type(QuestInfo)->
	erlang:element(#everquests.reward_exp_type, QuestInfo).

get_free_recover_interval(QuestInfo)->
	erlang:element(#everquests.free_recover_interval, QuestInfo).

get_quality_extra_rewards(QuestInfo)->
	erlang:element(#everquests.quality_extra_rewards, QuestInfo).

get_guild_required(QuestInfo)->
	try
		erlang:element(#everquests.guild_required, QuestInfo)
	catch
		_:_-> []
	end.
