%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(mainline_db).

-include("mainline_def.hrl").
-include("mainline_define.hrl").

-define(ETS_TABLE,mainline_proto_ets).

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
	db_tools:create_table_disc(mainline_proto,record_info(fields,mainline_proto),[],bag).

create_mnesia_split_table(role_mainline,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,role_mainline),[],set).

tables_info()->
	[{mainline_proto,proto},{role_mainline,disc_split}].

delete_role_from_db(RoleId)->
	TableName = db_split:get_owner_table(role_mainline, RoleId),
	dal:delete_rpc(TableName, RoleId).

create()->
	ets:new(?ETS_TABLE,[set,public,named_table]).

init()->
	db_operater_mod:init_ets(mainline_proto, ?ETS_TABLE,[#mainline_proto.chapter,#mainline_proto.stage,#mainline_proto.difficulty,#mainline_proto.class]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_info(Chapter,Stage,Difficulty,Class)->
	case ets:lookup(?ETS_TABLE, {Chapter,Stage,Difficulty,Class}) of
		[]->
			[];
        [{_,Term}]-> 
			Term
	end.

get_allinfo(Class)->
	Difficulty = ?EASY,
	ets:foldl(fun({{_,Stage,_Difficulty,_Class},Term},Acc)->
					  if
						  	Stage =:= 0->
								Acc;
							(Difficulty =:= _Difficulty) and (Class =:= _Class) ->
								[Term|Acc];
							true->
								Acc
					  end
			end, [], ?ETS_TABLE).

get_chapter(Term)->
	erlang:element(#mainline_proto.chapter, Term).

get_stage(Term)->
	erlang:element(#mainline_proto.stage, Term).

get_pre_stage(Term)->
	erlang:element(#mainline_proto.pre_stage, Term).	

get_entry_condition(Term)->
	erlang:element(#mainline_proto.entry_condition, Term).

get_entry_times(Term)->
	erlang:element(#mainline_proto.entry_times, Term).

get_difficulty(Term)->
	erlang:element(#mainline_proto.difficulty, Term).

get_transportid(Term)->
	erlang:element(#mainline_proto.transportid, Term).

get_type(Term)->
	erlang:element(#mainline_proto.type, Term).

get_time_s(Term)->
	erlang:element(#mainline_proto.time_s, Term).

get_killmonsterlist(Term)->
	erlang:element(#mainline_proto.killmonsterlist, Term).

get_protectnpclist(Term)->
	erlang:element(#mainline_proto.protectnpclist, Term).

get_defend_sections(Term)->
	erlang:element(#mainline_proto.defend_sections, Term).

get_first_award_money(Term)->
	erlang:element(#mainline_proto.first_award_money, Term).

get_first_award_exp(Term)->
	erlang:element(#mainline_proto.first_award_exp, Term).

get_first_award_items(Term)->
	erlang:element(#mainline_proto.first_award_items, Term).

get_common_award_money(Term)->
	erlang:element(#mainline_proto.common_award_money, Term).

get_common_award_exp(Term)->
	erlang:element(#mainline_proto.common_award_exp, Term).

get_common_award_items(Term)->
	erlang:element(#mainline_proto.common_award_items, Term).

get_level_factor(Term)->
	erlang:element(#mainline_proto.level_factor, Term).

get_time_factor(Term)->
	erlang:element(#mainline_proto.time_factor, Term).

get_designation(Term)->
	erlang:element(#mainline_proto.designation, Term).

get_monsterslist(Term)->
	erlang:element(#mainline_proto.monsterslist, Term).

get_section_duration(Term)->
	erlang:element(#mainline_proto.section_duration, Term).

get_role_record(RoleId)->
	TableName = db_split:get_owner_table(role_mainline, RoleId),
	case dal:read_rpc(TableName,RoleId) of
		{ok,[R]}-> 
			{_,_,RecordList} = R,
			RecordList;
		_->
			[]
	end.

save_record_to_db(RoleId,RecordList)->
	TableName = db_split:get_owner_table(role_mainline, RoleId),
	dmp_op:sync_write(RoleId,{TableName,RoleId,RecordList}).