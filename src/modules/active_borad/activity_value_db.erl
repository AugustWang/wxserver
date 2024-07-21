%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-7-11
%% Description: TODO: Add description to activity_value_db
-module(activity_value_db).

-define(AV_ETS_TABLE,activity_value_ets).
-define(AV_REWARD_ETS_TABLE,activity_value_reward_ets).
%%
%% Include files
%%
-include("activity_value_def.hrl").
-include("activity_value_define.hrl").
-include("base_define.hrl").
%%
%% Exported Functions
%%
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
	db_tools:create_table_disc(activity_value_proto,record_info(fields,activity_value_proto),[],set),
	db_tools:create_table_disc(activity_value_reward,record_info(fields,activity_value_reward),[],set),
	db_tools:create_table_disc(role_activity_value,record_info(fields,role_activity_value),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{activity_value_proto,proto},{activity_value_reward,proto},{role_activity_value,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_activity_value,RoleId).

create()->
	ets:new(?AV_ETS_TABLE,[set,named_table]),
	ets:new(?AV_REWARD_ETS_TABLE,[set,named_table]).

init()->
	db_operater_mod:init_ets(activity_value_proto, ?AV_ETS_TABLE,#activity_value_proto.id),
	db_operater_mod:init_ets(activity_value_reward, ?AV_REWARD_ETS_TABLE,#activity_value_reward.value).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% []
%% {...}
%%[error,....]
%%
get_info(Id)->
	try
		case ets:lookup(?AV_ETS_TABLE,Id) of
			[]->[];
			[{_Id,Value}] -> Value
		end
	catch
		_:_-> [error,"No this Term!"]
	end.

%%
%% return : Value | []
%%
get_type(TableInfo)->
		element(#activity_value_proto.type,TableInfo).
%%
%% return : Value | []
%%
get_maxtimes(TableInfo)->
		element(#activity_value_proto.maxtimes,TableInfo).

%%
%% return : Value | []
%%
get_time(TableInfo)->
		element(#activity_value_proto.time,TableInfo).

%%
%% return : Value | []
%%
get_com_condition(TableInfo)->
		element(#activity_value_proto.com_condition,TableInfo).

%%
%% return : Value | []
%%
get_value(TableInfo)->
		element(#activity_value_proto.value,TableInfo).

%%
%% return : Value | []
%%
get_targetid(TableInfo)->
		element(#activity_value_proto.targetid,TableInfo).

get_reward_info(Id)->
	try
		case ets:lookup(?AV_REWARD_ETS_TABLE,Id) of
			[]->[];
			[{_Id,Value}] -> Value
		end
	catch
		_:_-> [error,"No this Term!"]
	end.

get_reward(TableInfo)->
	element(#activity_value_reward.reward,TableInfo).

get_all_reward()->
	ets:foldl(fun({_,TableInfo},Acc)->
					  [get_reward(TableInfo)|Acc]
			end, [], ?AV_REWARD_ETS_TABLE).

create_av_msg()->
	ets:foldl(fun({_,Info},Acc)->
				Id = element(#activity_value_proto.id,Info),
				ComCondition = element(#activity_value_proto.com_condition,Info),
				Value =  element(#activity_value_proto.value,Info),
				if
					ComCondition =:= []->
						Acc;
					%%Value =:= 0->
					%%	Acc;
					true->
						case ComCondition of
							[]->
								Acc;
							_->
								{Msg,Op,MaxValue} = ComCondition,
								Acc ++ [{Msg,Op,MaxValue,Id}]
						end
				end
			end,[],?AV_ETS_TABLE).

create_av_state()->
	ets:foldl(fun({_,Info},Acc)->
				Id = element(#activity_value_proto.id,Info),
				ComCondition = element(#activity_value_proto.com_condition,Info),
				Value =  element(#activity_value_proto.value,Info),
				if
					ComCondition =:= []->
						Acc;
					%%Value =:= 0->
					%%	Acc;
					true->
						Acc ++  [{Id,0,0}]
				end
			end,[],?AV_ETS_TABLE).

create_boss_born_msg()->
	ets:foldl(fun({_,Info},Acc)->
				Type = element(#activity_value_proto.type,Info),
				if
					?ACTIVITY_TYPE_BOSS =:= Type->
						Id = element(#activity_value_proto.id,Info),
						Acc ++ [Id];
					true->
						Acc
				end
			end,[],?AV_ETS_TABLE).

create_activity_relation()->
	ets:foldl(fun({_,Info},Acc)->
				Type = element(#activity_value_proto.type,Info),
				if
					?ACTIVITY_TYPE_ACTIVITY =:= Type->
						Id = element(#activity_value_proto.id,Info),
						ActivityIid = element(#activity_value_proto.targetid,Info),
						Acc ++ [{ActivityIid,Id}];
					true->
						Acc
				end
			end,[],?AV_ETS_TABLE).

get_activity_value_info(RoleId)->
	case dal:read_rpc(role_activity_value,RoleId) of
		{ok,[Info]}-> Info;
		_-> []
	end.

get_activity_value_state(TableInfo)->
	element(#role_activity_value.state,TableInfo).

get_activity_value(TableInfo)->
	element(#role_activity_value.value,TableInfo).

get_activity_rewardflag(TableInfo)->
	element(#role_activity_value.reward,TableInfo).

update_activity_value(RoleId,State,Value,Reward)->
	NewInfo = #role_activity_value{roleid = RoleId,state = State,value = Value,reward = Reward},
	dal:write_rpc(NewInfo).
	