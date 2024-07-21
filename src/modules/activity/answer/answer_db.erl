%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-3-28
%% Description: TODO: Add description to anwser_db
-module(answer_db).

%%
%% Include files
%%
-define(ANSWER_ETS,answer_table).
-define(ANSWER_OPTION_ETS,answer_option_table).
-define(ACTIVITY_ETS,activity_table).
-include("mnesia_table_def.hrl").
-include("base_define.hrl").
-compile(export_all).
%%
%% Exported Functions
%%
-export([
		 get_answer_option_info/1,get_activity_info/1,get_all_activity_info/0,get_all_answer_info/0,
		 get_answer_length/0,get_answer_info/1,get_answer_roleinfo/1,sync_update_answer_roleinfo_to_mnesia/2,
		 gm_add_activity_to_ets_rpc/1,gm_delete_activity_from_ets_rpc/1,add_activity_to_mnesia/1
		]).
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
	db_tools:create_table_disc(activity,record_info(fields,activity),[],bag),
	db_tools:create_table_disc(answer,record_info(fields,answer),[],set),
	db_tools:create_table_disc(answer_option,record_info(fields,answer_option),[],set),
	db_tools:create_table_disc(answer_roleinfo,record_info(fields,answer_roleinfo),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{activity,proto},{answer,proto},{answer_option,proto},{answer_roleinfo,disc}].

delete_role_from_db(RoleId)->
	dal:read_rpc(answer_roleinfo,RoleId) .

create()->
	ets:new(?ANSWER_ETS,[set,public,named_table]),
	ets:new(?ACTIVITY_ETS,[bag,public,named_table]),
	ets:new(?ANSWER_OPTION_ETS,[set,public,named_table]).

init()->
	db_operater_mod:init_ets(answer, ?ANSWER_ETS,#answer.id),
	db_operater_mod:init_ets(answer_option, ?ANSWER_OPTION_ETS,#answer_option.id),
	db_operater_mod:init_ets(activity, ?ACTIVITY_ETS,#activity.id).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gm_add_activity_to_ets_rpc(Term)->
	Object = util:term_to_record(Term,activity),
	lists:foreach(fun(N)-> rpc:call(N,?MODULE,init,[]) end ,node_util:get_mapnodes()).

gm_delete_activity_from_ets_rpc(Term)->
	Object = util:term_to_record(Term,activity),
	lists:foreach(fun(N)-> rpc:call(N,?MODULE,gm_delete_activity_from_ets,[Object]) end ,node_util:get_mapnodes()).

gm_delete_activity_from_ets(Term)->
	try
		Id = erlang:element(#activity.id,Term),
		ets:delete_object(?ACTIVITY_ETS,{Id,Term})
	catch
		_Error:Reason->
			slogger:msg("delete_activity_from_ets Reason ~p ~n",[Reason]),
			{error,Reason}
	end.

get_answer_option_info(Id)->
	case ets:lookup(?ANSWER_OPTION_ETS, Id) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_activity_info(Id)->
	case ets:lookup(?ACTIVITY_ETS, Id) of
		[]->[];
        OriInfos-> lists:map(fun({_,Info})->Info end,OriInfos) 
	end.

get_all_activity_info()->
	case ets:tab2list(?ACTIVITY_ETS) of
		[]->[];
        OriInfos-> lists:map(fun({_,Info})->Info end,OriInfos) 
	end.

get_all_answer_info()->
	case ets:tab2list(?ANSWER_ETS) of
		[]->[];
        OriInfos-> lists:map(fun({_,Info})->Info end,OriInfos) 
	end.

get_answer_length()->
	case ets:info(?ANSWER_ETS,size) of
		?ERLNULL->0;
        Value-> Value 
	end.

get_answer_info(Id)->
	case ets:lookup(?ANSWER_ETS, Id) of
		[]->[];
        [{_,Info}]-> Info
	end.


get_activity_id(Info)->
	erlang:element(#activity.id, Info).
  
get_activity_start(Info)->
	erlang:element(#activity.start, Info).

get_activity_duration(Info)->
	erlang:element(#activity.duration, Info).

get_activity_spec_info(Info)->
	erlang:element(#activity.spec_info, Info).

get_answerop_level(Info)->
	erlang:element(#answer_option.level, Info).

get_answerop_nums(Info)->
	erlang:element(#answer_option.nums, Info).

get_answerop_interval(Info)->
	erlang:element(#answer_option.interval, Info).

get_answerop_vip_addition(Info)->
	erlang:element(#answer_option.vip_addtion, Info).

get_answerop_all_addition(Info)->
	erlang:element(#answer_option.all_addtion, Info).

get_answerop_rewards(Info)->
	erlang:element(#answer_option.rewards, Info).

get_answerop_vip_props(Info)->
	erlang:element(#answer_option.vip_props, Info).

get_answerop_base_exp(Info)->
	erlang:element(#answer_option.base_exp, Info).

get_answer_id(Info)->
	erlang:element(#answer.id, Info).
	
get_answer_time(Info)->
	erlang:element(#answer.time, Info).

get_answer_score(Info)->
	erlang:element(#answer.score, Info).

get_answer_correct(Info)->
	erlang:element(#answer.correct, Info).

sync_update_answer_roleinfo_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,answer_roleinfo),
	dmp_op:sync_write(RoleId,Object).

get_answer_roleinfo(RoleId)->
	case dal:read_rpc(answer_roleinfo,RoleId) of
		{ok,[]}-> {ok,[]};
		{ok,[Result]}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_answer_roleinfo failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_answer_roleinfo failed :~p~n",[Reason])
	end.

add_activity_to_mnesia(Term)->
	Object = util:term_to_record(Term,activity),
	dal:write_rpc(Object).
