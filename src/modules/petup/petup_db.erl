%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-1-21
%% Description: TODO: Add description to petup_db
-module(petup_db).

%%
%% Include files
%%
-define(PET_UP_RESET_ETS,pet_up_reset_table).
-define(PET_UP_ABILITIES_ETS,pet_up_abilities_table).
-define(PET_UP_STAMINA_ETS,pet_up_stamina_table).
-define(PET_UP_RISEUP_ETS,pet_up_riseup_table).
-include("mnesia_table_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
create()->
	ets:new(?PET_UP_RESET_ETS,[set,public,named_table]),
	ets:new(?PET_UP_ABILITIES_ETS,[set,public,named_table]),
	ets:new(?PET_UP_STAMINA_ETS,[set,public,named_table]),
	ets:new(?PET_UP_RISEUP_ETS,[set,public,named_table]).

init()->
	ets:delete_all_objects(?PET_UP_RESET_ETS),
	ets:delete_all_objects(?PET_UP_ABILITIES_ETS),
	ets:delete_all_objects(?PET_UP_STAMINA_ETS),
	ets:delete_all_objects(?PET_UP_RISEUP_ETS),
	init_pet_up_reset(),
	init_pet_up_abilities(),
	init_pet_up_stamina(),
	init_pet_up_riseup().

init_pet_up_reset()->
	case dal:read_rpc(pet_up_reset) of
		{ok,Result}-> lists:foreach(fun(Term)-> add_pet_up_reset_to_ets(Term) end, Result);
		_->  slogger:msg("init_pet_up_reset failed!~n")
	end.

init_pet_up_abilities()->
	case dal:read_rpc(pet_up_abilities) of
		{ok,Result}-> lists:foreach(fun(Term)-> add_pet_up_abilities_to_ets(Term) end, Result);
		_->  slogger:msg("init_pet_up_abilities failed!~n")
	end.

init_pet_up_stamina()->
	case dal:read_rpc(pet_up_stamina) of
		{ok,Result}-> lists:foreach(fun(Term)-> add_pet_up_stamina_to_ets(Term) end, Result);
		_->  slogger:msg("init_pet_up_stamina failed!~n")
	end.

init_pet_up_riseup()->
	case dal:read_rpc(pet_up_riseup) of
		{ok,Result}-> lists:foreach(fun(Term)-> add_pet_up_riseup_to_ets(Term) end, Result);
		_->  slogger:msg("init_pet_up_riseup failed!~n")
	end.

add_pet_up_reset_to_ets(Term)->
	try
	       {_,Protoid,Main_growth_rate,Consume,Needs,Protect,Locked} = Term,
	       ets:insert(?PET_UP_RESET_ETS, {Protoid,Main_growth_rate,Consume,Needs,Protect,Locked})
	catch
		_:_->
			error
	end.

add_pet_up_abilities_to_ets(Term)->
	try
	       {_,Protoid,Rate,Next,Failure,Consume,Needs,Protect} = Term,
	       ets:insert(?PET_UP_ABILITIES_ETS, {Protoid,Rate,Next,Failure,Consume,Needs,Protect})
	catch
		_:_->
			error
	end.

add_pet_up_stamina_to_ets(Term)->
	try
	       {_,Protoid,Rate,Next,Failure,Consume,Needs,Protect} = Term,
	       ets:insert(?PET_UP_STAMINA_ETS, {Protoid,Rate,Next,Failure,Consume,Needs,Protect})
	catch
		_:_->
			error
	end.

add_pet_up_riseup_to_ets(Term)->
	try
	       {_,Protoid,Rate,Next,Failure,Consume,Needs,Protect} = Term,
	       ets:insert(?PET_UP_RISEUP_ETS, {Protoid,Rate,Next,Failure,Consume,Needs,Protect})
	catch
		_:_->
			error
	end.

import_pet_up_reset(File)->
	dal:clear_table(pet_up_reset),
	case file:consult(File) of
			{ok,[Terms]}->
				lists:foreach(fun(Term)-> add_pet_up_reset_to_mnesia(Term) end,Terms);
			{error,Reason} ->
				slogger:msg("import_pet_up_reset error:~p~n",[Reason])
	end.

add_pet_up_reset_to_mnesia(Term)->
	try
		Object = util:term_to_record(Term,pet_up_reset),
		dal:write(Object)
	catch
		_:_-> error
	end.

import_pet_up_abilities(File)->
	dal:clear_table(pet_up_abilities),
	case file:consult(File) of
			{ok,[Terms]}->
				lists:foreach(fun(Term)-> add_pet_up_abilities_to_mnesia(Term) end,Terms);
			{error,Reason} ->
				slogger:msg("import_pet_up_abilities error:~p~n",[Reason])
	end.

add_pet_up_abilities_to_mnesia(Term)->
	try
		Object = util:term_to_record(Term,pet_up_abilities),
		dal:write(Object)
	catch
		_:_-> error
	end.

import_pet_up_stamina(File)->
	dal:clear_table(pet_up_stamina),
	case file:consult(File) of
			{ok,[Terms]}->
				lists:foreach(fun(Term)-> add_pet_up_stamina_to_mnesia(Term) end,Terms);
			{error,Reason} ->
				slogger:msg("import_pet_up_stamina error:~p~n",[Reason])
	end.

add_pet_up_stamina_to_mnesia(Term)->
	try
		Object = util:term_to_record(Term,pet_up_stamina),
		dal:write(Object)
	catch
		_:_-> error
	end.

import_pet_up_riseup(File)->
	dal:clear_table(pet_up_riseup),
	case file:consult(File) of
			{ok,[Terms]}->
				lists:foreach(fun(Term)-> add_pet_up_riseup_to_mnesia(Term) end,Terms);
			{error,Reason} ->
				slogger:msg("import_pet_up_riseup error:~p~n",[Reason])
	end.

add_pet_up_riseup_to_mnesia(Term)->
	try
		Object = util:term_to_record(Term,pet_up_riseup),
		dal:write(Object)
	catch
		_:_-> error
	end.

get_pet_up_reset_info(Class)->
    try
		case ets:lookup(?PET_UP_RESET_ETS, Class) of
			[]->[];
            [Info]-> Info 
		end
	catch
		_:_-> []
	end.

get_needs_with_reset_info(ResetInfo)->
	try
		element(#pet_up_reset.needs,ResetInfo)
	catch
		_:_-> []
	end.

get_main_growth_rate_with_reset_info(ResetInfo)->
	try
		element(#pet_up_reset.main_growth_rate,ResetInfo)
	catch
		_:_-> []
	end.

get_protect_with_reset_info(ResetInfo)->
	try
		element(#pet_up_reset.protect,ResetInfo)
	catch
		_:_-> []
	end.

get_locked_with_reset_info(ResetInfo)->
	try
		element(#pet_up_reset.locked,ResetInfo)
	catch
		_:_-> []
	end.

get_consume_with_reset_info(ResetInfo)->
	try
		element(#pet_up_reset.consume,ResetInfo)
	catch
		_:_-> []
	end.

get_pet_up_abilities_info(Class)->
    try
		case ets:lookup(?PET_UP_ABILITIES_ETS, Class) of
			[]->[];
            [Info]-> Info 
		end
	catch
		_:_-> []
	end.

get_pet_up_stamina_info(Class)->
    try
		case ets:lookup(?PET_UP_STAMINA_ETS, Class) of
			[]->[];
            [Info]-> Info 
		end
	catch
		_:_-> []
	end.

get_pet_up_riseup_info(Class)->
    try
		case ets:lookup(?PET_UP_RISEUP_ETS, Class) of
			[]->[];
            [Info]-> Info 
		end
	catch
		_:_-> []
	end.
get_needs_with_info(Info)->
	try
		element(#pet_up_riseup.needs,Info)
	catch
		_:_-> []
	end.
get_failure_with_info(Info)->
	try
		element(#pet_up_riseup.failure,Info)
	catch
		_:_-> []
	end.
get_next_with_info(Info)->
	try
		element(#pet_up_riseup.next,Info)
	catch
		_:_-> []
	end.
get_rate_with_info(Info)->
	try
		element(#pet_up_riseup.rate,Info)
	catch
		_:_-> []
	end.
get_consume_with_info(Info)->
	try
		element(#pet_up_riseup.consume,Info)
	catch
		_:_-> []
	end.
get_protect_with_info(Info)->
	try
		element(#pet_up_riseup.protect,Info)
	catch
		_:_-> []
	end.
%%
%% Local Functions
%%

