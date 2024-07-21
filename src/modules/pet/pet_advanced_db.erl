%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-2-26
%% Description: TODO: Add description to pet_advanced_db
-module(pet_advanced_db).
-include("pet_def.hrl").
%%
%% Include files
%%
-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-export([get_pet_attr_base_info/1,get_hp_from_base/1,get_power_from_base/1,get_defence_from_base/1]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
-define(PET_ATTR_BASE_ETS,pet_attr_ets).
-define(PET_ADVANCE_ETS,pet_advance_ets).
-define(PET_ADVANCE_LUCKY_ETS,pet_advance_lucky_ets).
%%
%% Exported Functions
%%
%%
%% API Functions
%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(pet_base_attr, record_info(fields,pet_base_attr), [], set),
	db_tools:create_table_disc(pet_advance, record_info(fields,pet_advance),[],set),
	db_tools:create_table_disc(pet_advance_lucky, record_info(fields,pet_advance),[],bag),
	db_tools:create_table_disc(pet_advance_reset_time, record_info(fields,pet_advance_reset_time),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_base_attr,proto},{pet_advance,proto},{pet_advance_lucky,proto},{pet_advance_reset_time,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_ATTR_BASE_ETS,[ordered_set,named_table,public]),
	ets:new(?PET_ADVANCE_ETS,[ordered_set,named_table,public]),
	ets:new(?PET_ADVANCE_LUCKY_ETS,[bag,named_table,public]).
	

init()->
	db_operater_mod:init_ets(pet_base_attr, ?PET_ATTR_BASE_ETS,#pet_base_attr.proto),
	db_operater_mod:init_ets(pet_advance, ?PET_ADVANCE_ETS,#pet_advance.step),
	db_operater_mod:init_ets(pet_advance_lucky, ?PET_ADVANCE_LUCKY_ETS,#pet_advance_lucky.step).

get_pet_attr_base_info(Protoid)->
	try
		case ets:lookup(?PET_ATTR_BASE_ETS, Protoid) of
			[{_,Attrinfo}]->
						Attrinfo;
			_Other->
						[]
			end
	catch
		_Reason:_Error->nothing
					%io:format("@@@@   look up pet attr error ~p~n",[Error])
	end.
get_hp_from_base(Info)->
	Hp=element(#pet_base_attr.hp,Info),
	
	Hp.

get_power_from_base(Info)->
 	Powerlist=element(#pet_base_attr.power,Info),
	Power=element(1,Powerlist),
	Power.

get_defence_from_base(Info)->
	Defencelist=element(#pet_base_attr.defence,Info),
	Defence=element(1,Defencelist),
	Defence.

get_advance_info(Step)->
	try
		case ets:lookup(?PET_ADVANCE_ETS, Step) of
			[{_,Info}]->
				Info;
			_Other->
				[]
		end
	catch
		_Reason:_Error->nothing
			%io:format("@@@@@@@@@@  look up advance ifno error  ~p ~n",[Error])
	end.

get_step_from_advance_info(Info)->
	#pet_advance{step=Step}=Info,
	Step.
get_itemnum_from_advance_info(Info)->
	#pet_advance{itemnum=Itemnum}=Info,
	Itemnum.
get_needmoney_from_advance_info(Info)->
	#pet_advance{money=Money}=Info,
	Money.

get_advance_lucky_info(Step,Lucky)->
	ets:foldl(fun({_,{Name,Step1,{LuckyMin,LuckyMax},Rate}},Acc)->
					  if (Step1=:=Step) and ((LuckyMin=<Lucky) and (LuckyMax>=Lucky))->
							 {Name,Step1,{LuckyMin,LuckyMax},Rate};
						 true->
							 Acc
					  end
					  end, [], ?PET_ADVANCE_LUCKY_ETS).

get_lucky_from_advance_lucky(Info)->
	#pet_advance_lucky{lucky=Lucky}=Info,
	Lucky.
get_rate_from_advance_lucky(Info)->
	#pet_advance_lucky{rate=Rate}=Info,
	Rate.
insert_advance_reset_time(Time,RoleId)->
	dal:write_rpc({pet_advance_reset_time,RoleId,Time}).
get_advance_reset_time_info(RoleId)->
	case dal:read_rpc(pet_advance_reset_time, RoleId) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.
get_advance_reset_time(Info)->
	erlang:element(#pet_advance_reset_time.time, Info).

%%
%% Local Functions
%%

