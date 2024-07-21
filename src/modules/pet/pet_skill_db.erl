%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-3-25
%% Description: TODO: Add description to pet_skill_db
-module(pet_skill_db).

-include("pet_def.hrl").
%%
%% Include files
%%
-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
-define(PET_SKILL_PROTO_ETS,pet_skill_proto_ets).
%%
%% Exported Functions
%%
%%
%% API Functions
%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)-> 
	db_tools:create_table_disc(pet_skill_proto, record_info(fields,pet_skill_proto), [], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_skill_proto,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_SKILL_PROTO_ETS,[ordered_set,named_table,public]).
	

init()->
	db_operater_mod:init_ets(pet_skill_proto, ?PET_SKILL_PROTO_ETS,#pet_skill_proto.slot).

get_pet_skill_slots_from_quality(Quality)->
	ets:foldl(fun({_,{_,Slot,Value,Money}},Acc)->
					  if (Value=<Quality) and (Money=:=0)->
							 Slot;
					  true->
						  Acc
					  end
					        end , 0, ?PET_SKILL_PROTO_ETS).

get_pet_skill_proto_info(Slot)->
	try
		case ets:lookup(?PET_SKILL_PROTO_ETS,Slot) of
			[{_,Info}]->
				Info;
			_->
				[]
			end
	catch
		_:_Error->nothing
				%io:format("@@@@@@@@@@@@   ~p~n",[Error])
	end.

get_gold_from_skill_protoinfo(SkillProtoInfo)->
	#pet_skill_proto{money=Money}=SkillProtoInfo,
	Money.

