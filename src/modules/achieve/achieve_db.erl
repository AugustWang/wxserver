%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-12-10
%% Description: TODO: Add description to achieve_db
-module(achieve_db).
%% 
%% define
%% 
-define(ACHIEVE_ETS,achieve_table).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%@@wb20130301
-define(ACHIEVE_PROTO_ETS,achieve_proto_table).
-define(ACHIEVE_AWARD_ETS,achieve_award_table).
-define(ACHIEVE_FUWEN_ETS,achieve_fuwen_table).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Include files
%%
-include("mnesia_table_def.hrl").
%%
%% Exported Functions
%%

-export([get_bonus/1]).
  
-export([
		 async_update_achieve_role_to_mnesia/2,sync_update_achieve_role_to_mnesia/2,
		 get_achieve_role/1,get_achieve_info/1,get_achieve_by_chapter/1,get_all_achieve/0,
		get_achieve_id/1,get_achieve_value/1,get_achieve_hp/1,get_achieve_type/1,
		 get_achieve_script/1,get_all_fuwen/0,get_all_award/0,get_achieve_require/1,
		 get_achieve_value_by_id/1,get_achieve_hp_by_id/1,get_award_info/1,
		 get_achievelist_by_chapter/1,get_achievenum_by_chapter/1,get_achievenum_by_id/1]).

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
%% 	db_tools:create_table_disc(achieve, record_info(fields,achieve), [], set),
	db_tools:create_table_disc(achieve_role, record_info(fields,achieve_role), [], set),
	db_tools:create_table_disc(achieve_proto, record_info(fields,achieve_proto), [], set),
	db_tools:create_table_disc(achieve_fuwen, record_info(fields,achieve_fuwen), [], set),
	db_tools:create_table_disc(achieve_award, record_info(fields,achieve_award), [], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{achieve_role,disc},{achieve_proto,proto},{achieve_award,proto},{achieve_fuwen,proto}].
%% 	[{achieve,proto},{achieve_role,disc},{achieve_proto,proto},{achieve_award,proto},{achieve_fuwen,proto}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(achieve_role, RoleId).

create()->
%% 	ets:new(?ACHIEVE_ETS,[set,public,named_table]),
	ets:new(?ACHIEVE_PROTO_ETS,[set,public,named_table]),
	ets:new(?ACHIEVE_AWARD_ETS,[set,public,named_table]),
	ets:new(?ACHIEVE_FUWEN_ETS,[set,public,named_table]).

init()->
%% 	db_operater_mod:init_ets(achieve, ?ACHIEVE_ETS,#achieve.achieveid),
	db_operater_mod:init_ets(achieve_proto, ?ACHIEVE_PROTO_ETS,#achieve_proto.achieveid),
	db_operater_mod:init_ets(achieve_award, ?ACHIEVE_AWARD_ETS,#achieve_award.awardid),
	db_operater_mod:init_ets(achieve_fuwen, ?ACHIEVE_FUWEN_ETS,#achieve_fuwen.fuwenid).
%%%%%%%%%%%%%%%%%%%%%%%%%%@@wb20130301æŒ‰å®¢æˆ·ç«¯æ›´æ–°

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

async_update_achieve_role_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,achieve_role),
	dmp_op:async_write(RoleId,Object).

sync_update_achieve_role_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,achieve_role),
	dmp_op:sync_write(RoleId,Object).

get_achieve_info(Id)->
	case ets:lookup(?ACHIEVE_ETS, Id) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_bonus(Info)->
	erlang:element(#achieve.bonus, Info).

get_chapter(Info)->
	erlang:element(#achieve.chapter, Info).

get_achieve_by_chapter(Chapter)->
	ets:foldl(fun({_,Info},AccInfoTmp)->
					case get_chapter(Info) of
						Chapter->
							{_T,Achieveid,Chapter,Part,Target,Bonus,Bonus2,Type,Script} = Info,
							AccInfoTmp++[{Achieveid,Chapter,Part,Target,Bonus,Bonus2,Type,Script}];
						_->
							AccInfoTmp
					end
				end,[], ?ACHIEVE_ETS).

get_achieve_role(RoleId)->
	case dal:read_rpc(achieve_role,RoleId) of
		{ok,[]}-> {ok,[]};
		{ok,Result}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_achieve_role failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_achieve_role failed :~p~n",[Reason])
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%@@wbæˆå°±ï¼ŒæŒ‰å®¢æˆ·ç«¯æ·»åŠ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_all_achieve()->
	case ets:tab2list(?ACHIEVE_PROTO_ETS) of
		[]->[];
		OriInfos->
			lists:map(fun({_,Info})->Info end,OriInfos) 
	end.

get_all_fuwen()->
	case ets:tab2list(?ACHIEVE_FUWEN_ETS) of
		[]->[];
		OriInfos->
			lists:map(fun({_,Info})->Info end,OriInfos) 
	end.

get_all_award()->
	case ets:tab2list(?ACHIEVE_AWARD_ETS) of
		[]->[];
		OriInfos->
			lists:map(fun({_,Info})->Info end,OriInfos) 
	end.

get_achieve_id(Info)->
	erlang:element(#achieve_proto.achieveid, Info).

get_achieve_hp(Info)->
	erlang:element(#achieve_proto.achieve_hp, Info).

get_achieve_value(Info)->
	erlang:element(#achieve_proto.achieve_value, Info).

get_achieve_type(Info)->
	erlang:element(#achieve_proto.type, Info).

get_achieve_script(Info)->
	erlang:element(#achieve_proto.script, Info).

get_achieve_require(Info)->
	erlang:element(#achieve_proto.require, Info).

get_achieve_value_by_id(AchieveId)->
	case lists:keyfind(AchieveId,2,get_all_achieve()) of
		false->
			nothing;
		Info->
			erlang:element(#achieve_proto.achieve_value, Info)
	end.

get_achieve_hp_by_id(AchieveId)->
	case lists:keyfind(AchieveId,2,get_all_achieve()) of
		false->
			nothing;
		Info->
			erlang:element(#achieve_proto.achieve_hp, Info)
	end.

get_award_info(Id)->
	case ets:lookup(?ACHIEVE_AWARD_ETS, Id) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_achievelist_by_chapter(Chapter)->
	lists:foldl(fun(Achieve,Acc)->
					  {C,_}=erlang:element(#achieve_proto.achieveid, Achieve),
					  case C=:=Chapter of
						  true->
							  Acc++[Achieve];
						  false->
							  Acc
					  end
				end,[],get_all_achieve()).

get_achievenum_by_chapter(Chapter)->
	case lists:keyfind({0,Chapter},2,get_all_achieve()) of
		false->
			nothing;
		Info->
			erlang:element(#achieve_proto.achieve_num,Info)
	end.

get_achievenum_by_id(Id)->
	{Chapter,Part}=Id,
	case Chapter of
		0->
			get_achievenum_by_chapter(Part);
		_->
			case lists:keyfind({Chapter,Part},2,get_all_achieve()) of
				false->
					nothing;
				Info->
					erlang:element(#achieve_proto.achieve_num,Info)
			end
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Local Functions
%%

