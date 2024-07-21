%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-9-26
%% Description: TODO: Add description to global_exp_addition
-module(global_exp_addition).

%%
%% Include files
%%
-include("global_exp_addition_def.hrl").

-define(EXP_ADDITION_ETS,global_exp_addition_ets).
-define(GLOBAL_EXP_ADDATION_TYPE_QUEST,1).
-define(GLOBAL_EXP_ADDATION_TYPE_MONSTER,2).
-define(GLOBAL_EXP_ADDATION_TYPE_SITDOWN,3).
-define(GLOBAL_EXP_ADDATION_TYPE_COMPANION_SITDOWN,4).
-define(GLOBAL_EXP_ADDATION_TYPE_BLOCK_TRAINING,5).
-define(NO_RESTRICTIONS,0).
-define(ZORE_EXP_ADDITION,0).
%%
%% Exported Functions
%%
-export([delete_global_exp_addition/1,add_global_exp_addition/1,add_global_exp_addition_to_ets/1,add_global_exp_addition_to_ets_rpc/1]).
-export([get_exp_addition/5,get_role_exp_addition/1]).
-export([del_global_exp_addition_from_ets/1,del_global_exp_addition_from_ets_rpc/1]).
-export([create/0,init/0]).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
-include("data_struct.hrl").
-include("map_info_struct.hrl").
-include("role_struct.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(global_exp_addition_db,record_info(fields,global_exp_addition_db),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{global_exp_addition_db,disc}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?EXP_ADDITION_ETS,[named_table,public,set]).

init()->
	db_operater_mod:init_ets(global_exp_addition_db, ?EXP_ADDITION_ETS, #global_exp_addition_db.key).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%quest/monster/sitdown/companion_sitdown/block_training
get_role_exp_addition(ExpTypeAtom)->
	Line = get_lineid_from_mapinfo(get(map_info)),
	Map = get_mapid_from_mapinfo(get(map_info)),
	Class = get_class_from_roleinfo(get(creature_info)),
	Level = get(level),
	try
		get_exp_addition(ExpTypeAtom,Line,Map,Class,Level)
	catch
		_E:R->
			slogger:msg("global_exp_addition ,R:~p~n",[R]),
			0
	end.



%%return addition times :0 or N
%%ExpTypeAtom:quest/monster/sitdown/companion_sitdown/block_training
get_exp_addition(ExpTypeAtom,Line,Map,Class,Level)->
	MyExpTypeId = get_exptype_key(ExpTypeAtom),
	ets:foldl(fun({_Key,Term},TmpExpTimes)->
					  TypeId = erlang:element(#global_exp_addition_db.typeid,Term),
					  if
						  TypeId =:= MyExpTypeId->
							 judge_condition(Line,Map,Class,Level,TmpExpTimes,Term);
						  true->
							  TmpExpTimes
					  end
			  end,?ZORE_EXP_ADDITION,?EXP_ADDITION_ETS).



get_exptype_key(ExpType)->
	case ExpType of
		quest->
			?GLOBAL_EXP_ADDATION_TYPE_QUEST;
		monster->
			?GLOBAL_EXP_ADDATION_TYPE_MONSTER;
		sitdown->
			?GLOBAL_EXP_ADDATION_TYPE_SITDOWN;
		companion_sitdown->
			?GLOBAL_EXP_ADDATION_TYPE_COMPANION_SITDOWN;
		block_training->
			?GLOBAL_EXP_ADDATION_TYPE_BLOCK_TRAINING
	end.


%%judge condition
%%return temp exprience times 
judge_condition(Line,Map,Class,Level,TmpExpTimes,Term)->
	StartTime = erlang:element(#global_exp_addition_db.starttime, Term),
	EndTime = erlang:element(#global_exp_addition_db.endtime, Term),
	NowTime = calendar:local_time(),
	NeedLine = erlang:element(#global_exp_addition_db.line,Term),
	NeedMap = erlang:element(#global_exp_addition_db.map,Term),
	NeedClass = erlang:element(#global_exp_addition_db.class, Term),
	NeedMinLevel = erlang:element(#global_exp_addition_db.minlevel,Term),
	NeedMaxLevel =erlang:element(#global_exp_addition_db.maxlevel,Term),
	RateNumerator = erlang:element(#global_exp_addition_db.numerator, Term),
	RateDenominator = erlang:element(#global_exp_addition_db.denominator,Term),
	ExpRate = (trunc((RateNumerator/RateDenominator)*100))/100,
	%%slogger:msg("ExpRate:~p~n",[ExpRate]),
	JudgeTime = timer_util:is_in_time_point(StartTime,EndTime,NowTime),
	JudgeLine = case erlang:is_list(NeedLine) of
					true->
						lists:member(Line,NeedLine);
					false ->
						if
							NeedLine =:= ?NO_RESTRICTIONS->
								true;
							true->
								false
						end
				end,
	
	JudgeMap = case erlang:is_list(NeedMap) of
				   true ->
					   lists:member(Map,NeedMap);
				   false ->
						if
					   		NeedMap =:= ?NO_RESTRICTIONS->
								true;
							true->
								false
						end
			   end,
	JudgeClass = (NeedClass =:= ?NO_RESTRICTIONS) or (Class =:= NeedClass),
	JudgeLevel = (Level >= NeedMinLevel) and (Level =< NeedMaxLevel),
	if
		JudgeTime and JudgeLine and JudgeMap and JudgeLevel and JudgeClass->
			TmpExpTimes+ExpRate;
		true->
			TmpExpTimes
	end.
	
add_global_exp_addition(Term)->
	Object = util:term_to_record(Term,global_exp_addition_db),
	case dal:write_rpc(Object) of
		{ok}->
			ok;
		_->
			error
	end.

delete_global_exp_addition(Id)->
	case dal:delete(global_exp_addition_db, Id) of
		{ok}->
			ok;
		_->
			error
	end.
add_global_exp_addition_to_ets_rpc(Term)->
	Object = util:term_to_record(Term,global_exp_addition_db),
	lists:foreach(fun(N)-> rpc:call(N,?MODULE,add_global_exp_addition_to_ets,[Object]) end ,node_util:get_mapnodes()).

add_global_exp_addition_to_ets(Object)->
	try
		Id = erlang:element(#global_exp_addition_db.key, Object),
		ets:insert(?EXP_ADDITION_ETS, {Id,Object})
	catch
		E:R->
			slogger:msg("add_global_exp_addition_to_ets error E:~p,R:~p~n",[E,R])
	end.
	
del_global_exp_addition_from_ets_rpc(Id)->
	lists:foreach(fun(N)-> rpc:call(N,?MODULE,del_global_exp_addition_from_ets,[Id]) end ,node_util:get_mapnodes()).

del_global_exp_addition_from_ets(Id)->
	ets:delete(?EXP_ADDITION_ETS,Id).
