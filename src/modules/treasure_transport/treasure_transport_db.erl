%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(treasure_transport_db).

-compile(export_all).

-define(TREATURE_TRANSPORT_ETS,treasure_transport_ets).
-define(TREATURE_TRANSPORT_QUALITY_BONUS_ETS,treasure_transport_quality_bonus_ets).

-include("treasure_transport_def.hrl").
-export([create/0,init/0]).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(treasure_transport,record_info(fields,treasure_transport),[],bag),
	db_tools:create_table_disc(role_treasure_transport_db,record_info(fields,role_treasure_transport_db),[],set),
	db_tools:create_table_disc(treasure_transport_quality_bonus,record_info(fields,treasure_transport_quality_bonus),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{treasure_transport,proto},{treasure_transport_quality_bonus,proto},{role_treasure_transport_db,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_treasure_transport_db,RoleId).

create()->
	ets:new(?TREATURE_TRANSPORT_ETS,[set,named_table]),
	ets:new(?TREATURE_TRANSPORT_QUALITY_BONUS_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(treasure_transport, ?TREATURE_TRANSPORT_ETS, #treasure_transport.level),
	db_operater_mod:init_ets(treasure_transport_quality_bonus, ?TREATURE_TRANSPORT_QUALITY_BONUS_ETS, #treasure_transport_quality_bonus.quality).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_role_treasure_transport_info(RoleId)->
	case dal:read_rpc(role_treasure_transport_db,RoleId) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.

add_role_treasure_transport(RoleId,QuestId,Type,Quality,Bonus,Recev_time,Last_Rob_Time,Rob_times)->
	dal:write_rpc({role_treasure_transport_db,RoleId,QuestId,Type,Quality,Bonus,Recev_time,Last_Rob_Time,Rob_times}).

get_treasure_transport_info(RoleLevel)->
	case ets:lookup(?TREATURE_TRANSPORT_ETS,RoleLevel) of
		[]->
			[];
		[{_,Info}]->
			Info
	end.

get_treasure_transport_quality_bonus_info(Quality)->
	case ets:lookup(?TREATURE_TRANSPORT_QUALITY_BONUS_ETS,Quality) of
		[]->
			[];
		[{_,Quality_BonusInfo}]->
			Quality_BonusInfo
	end.

get_treasure_transport_rewardexp(TransportInfo)->
	element(#treasure_transport.rewardexp,TransportInfo).

get_treasure_transport_reward_money(TransportInfo)->
	element(#treasure_transport.reward_money,TransportInfo).

get_treasure_transport_quality_bonus(Quality_bonus_info)->
	element(#treasure_transport_quality_bonus.bonus,Quality_bonus_info).









