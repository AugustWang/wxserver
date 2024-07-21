%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhang
%% Created: 2011-1-25
%% Description: TODO: Add description to pet_level_db
-module(pet_level_db).
%%
%% Include files
%%
-include("pet_def.hrl").
-define(PET_LEVEL_ETS,pet_level_ets).
-define(PET_LEVEL_SPEED_ETS,pet_level_speed_ets).
-define(SKILL_BOOK_RATE_ETS,skill_book_rate).
-define(SKILL_BOOK_ETS,skill_book).
%%
%% Exported Functions
%%
-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0,get_time_of_level/1]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).
create_mnesia_table(disc)->
	db_tools:create_table_disc(pet_level,record_info(fields,pet_level),[],set).
	   

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_level,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_LEVEL_ETS,[ordered_set,named_table]).

init()->
	ets:delete_all_objects(?PET_LEVEL_ETS),
	init_pet_level().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init_pet_level()->
	case dal:read_rpc(pet_level) of
		{ok,Pet_Levels}->
			Pet_Levels2 = lists:reverse(lists:keysort(#pet_level.level, Pet_Levels)),
			lists:foreach(fun(Term)-> add_pet_level_to_ets(Term) end, Pet_Levels2);
		_-> slogger:msg("init_pet_level failed~n")
	end.

add_pet_level_to_ets(Term)->
	try
		Id = erlang:element(#pet_level.level, Term),
 		ets:insert(?PET_LEVEL_ETS,{Id,Term})	
	catch
		_Error:Reason-> {error,Reason}
	end.

		
%% 
%% get_info()
%% []
%% {...}
%%[error,....]
%%
get_info(Level)->
	try
		case ets:lookup(?PET_LEVEL_ETS,Level) of
			[]->[];
			[{_Level,Value}] -> Value
		end
	catch
		_:_-> [error,"No this Pet level!"]
	end.

%%
%%	 return : Value | []
%%
get_level_and_exp(AllExp)->
	ets:foldr(fun({Level,Info},{LevelTmp,ExpTmp})->
					Exp = get_exp(Info),
			 		if 
						LevelTmp=/=0->
							{LevelTmp,ExpTmp};
						AllExp >= Exp->
							{Level ,AllExp - Exp};
						true->
							{0,0}
					end
			 end, {0,0}, ?PET_LEVEL_ETS).

%%鏋皯娣诲姞瀹犵墿鍗囩骇锛堟牴鎹椂闂村崌绾э級
get_level_and_time(AllTime)->
	ets:foldr(fun({Level,Info},{NewLevel,PetTime})->
					  Time=element(#pet_level.exp,Info),
					  if    NewLevel=/=0->
							  {NewLevel,PetTime};
							AllTime>=Time->
								{Level+1,AllTime};
							true->
								{0,0}
						end
					end,{0,0},?PET_LEVEL_ETS).


get_time_of_level(Level)->
	try 
		case ets:lookup(?PET_LEVEL_ETS,Level) of
			[{_,{_,_,Time,_,_}}]->
				Time;
			[]->
				-1
		end
	catch
		_:_->
			-1
	end.
get_exp(PetLevelInfo)->
	element(#pet_level.exp,PetLevelInfo).
%%
%%	 return : Value | []
%%
get_maxmp(PetLevelInfo)->
	element(#pet_level.maxhp,PetLevelInfo).
%%
%%	 return : Value | []
%%
get_sysaddattr(PetLevelInfo)->
	element(#pet_level.sysaddattr,PetLevelInfo).


	
	

