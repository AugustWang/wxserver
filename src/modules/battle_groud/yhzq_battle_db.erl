%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%% copy following code to module db_ini
%%
	

%%
%% add table yhzq_battle config to ebin/game_server.option
%%

%%
%% this file create by template
%% Author :
%% Created : 2011-03-18
%% Description : TODO

-module(yhzq_battle_db).

-define(ETS_TABLE_NAME,yhzq_battle_ets).
-define(ETS_YHZQ_WINNER_REWARD,yhzq_winner_raward_ets).
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% Include files 
%%
-include("mnesia_table_def.hrl").
-include("battle_define.hrl").
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
	db_tools:create_table_disc(yhzq_battle,record_info(fields,yhzq_battle),[],set),
	db_tools:create_table_disc(jszd_role_score_honor,record_info(fields,jszd_role_score_honor),[],set),
	db_tools:create_table_disc(yhzq_winner_raward,record_info(fields,yhzq_winner_raward),[],set),
	db_tools:create_table_disc(yhzq_battle_record,record_info(fields,yhzq_battle_record), [], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{yhzq_battle,proto},{yhzq_battle_record,disc},{jszd_role_score_honor,proto},{yhzq_winner_raward,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?ETS_YHZQ_WINNER_REWARD,[set,named_table]),
	ets:new(?ETS_TABLE_NAME,[set,named_table]).

init()->
	db_operater_mod:init_ets(yhzq_winner_raward, ?ETS_YHZQ_WINNER_REWARD,#yhzq_winner_raward.type),
	db_operater_mod:init_ets(yhzq_battle, ?ETS_TABLE_NAME,#yhzq_battle.id).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% get_info()
%% []
%% {...}
%%[error,....]
%%
get_info(Id)->
	try
		case ets:lookup(?ETS_TABLE_NAME,Id) of
			[]->[];
			[{_Id,Value}] -> Value
		end
	catch
		_:_-> [error,"No this Term!"]
	end.

%%
%% return : Value | []
%%
get_spawnpos(TableInfo)->
	element(#yhzq_battle.spawnpos,TableInfo).

%%
%% return : Value | []
%%
get_npcproto(TableInfo)->
	element(#yhzq_battle.npcproto,TableInfo).

%%
%%return : Value | []
%%
get_lamsterbuff(TableInfo)->
	element(#yhzq_battle.lamsterbuff,TableInfo).

get_npcproto(NpcId,Type)->
	NpcList = get_npcproto(get_info(1)),
	case lists:keyfind(NpcId,2,NpcList) of
		false->
			[];
		{_,_,ProtoList}->
			case lists:keyfind(Type,1,ProtoList) of
				false->
					[];
				{_,ProtoId}->
					ProtoId
			end
	end.

%%
%%
%%
get_npcindex(NpcId)->
	NpcList = get_npcproto(get_info(1)),
	case lists:keyfind(NpcId,2,NpcList) of
		false->
			0;
		{Index,_,_}->
			Index
	end.

load_battle_record_info()->
	case dal:read_rpc(yhzq_battle_record) of
		{ok,BattleInfo}-> BattleInfo;
		{failed,_Reason}-> [];
		{failed,badrpc,_Reason}-> []
	end.

sync_add_battle_info(Date,Class,Index,Info,RewardRecord)->
	dmp_op:sync_write({Date,Class,Index},{yhzq_battle_record,{Date,Class,Index},Info,RewardRecord,[]}).


delete_battle_record_info(Key)->
	dal:delete_rpc(yhzq_battle_record,Key).	
	
get_yhzq_reward_info(Type)->
	case ets:lookup(?ETS_YHZQ_WINNER_REWARD,Type) of
		[{_,Info}]->
			Info;
		_->[]
	end.

get_guild_add_score(Info)->
	element(#yhzq_winner_raward.score,Info).

get_role_add_honor(Info)->
	element(#yhzq_winner_raward.honor,Info).

get_role_add_exp(Info)->
	element(#yhzq_winner_raward.exp,Info).

get_role_rewards(Info)->
	element(#yhzq_winner_raward.item,Info).