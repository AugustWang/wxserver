%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-11-18
%% Description: TODO: Add description to battle_jszd_db
-module(battle_jszd_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-define(JSZD_RANK_OPTION_ETS,jszd_rank_option_table).
%%
%% Exported Functions
%%
-export([get_info/1,
		 get_rank/1,
		 get_bonus/1,
		 get_guild_money/1,
		 get_exp/1,
		 get_guild_score/1,
		 save_record_to_db/3,
		 clear_record_from_db/0,
		 get_role_score_info/1,
		 get_role_rank_honor/1]).

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
	db_tools:create_table_disc(jszd_rank_option, record_info(fields,jszd_rank_option), [], set),
	db_tools:create_table_disc(jszd_role_score_info, record_info(fields,jszd_role_score_info), [], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{jszd_rank_option,proto},{jszd_role_score_info,disc}].

delete_role_from_db(_RoleId)->
	nothing.

create()->
	ets:new(?JSZD_RANK_OPTION_ETS,[set,public,named_table]).

init()->
	db_operater_mod:init_ets(jszd_rank_option, ?JSZD_RANK_OPTION_ETS, #jszd_rank_option.rank).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(Rank)->
	case ets:lookup(?JSZD_RANK_OPTION_ETS, Rank) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_rank(Info)->
	erlang:element(#jszd_rank_option.rank, Info).

get_guild_money(Info)->
	erlang:element(#jszd_rank_option.guild_money, Info).

get_guild_score(Info)->
	erlang:element(#jszd_rank_option.guild_score, Info).

get_role_rank_honor(Info)->
	erlang:element(#jszd_rank_option.rolehonor, Info).

get_exp(Info)->
	erlang:element(#jszd_rank_option.exp, Info).

get_bonus(Info)->
	erlang:element(#jszd_rank_option.bonus, Info).
%%
%% Local Functions
%%
save_record_to_db(RoleId,Score,KillNum)->
	dal:write_rpc({jszd_role_score_info,RoleId,Score,KillNum}).

get_role_score_info(RoleId)->
	case dal:read_rpc(jszd_role_score_info,RoleId) of
		{ok,[Info]}->Info;
		_->
			[]
	end.

clear_record_from_db()->
	dal:clear_table_rpc(jszd_role_score_info).
