%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-2-25
%% Description: TODO: Add description to pet_skill_book_db
-module(pet_skill_book_db).
-include("pet_def.hrl").
%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-export([get_skill_rate_info/1,get_skill_lucky/1,get_skill_rate/1,get_skill_book_info/0,get_skilllist/1]).
-export([store_pet_freshen_skill/2,delete_pet_skill_info/0,get_pet_skill_info_by_store/0,get_skill_info_from_store_term/1]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
-define(SKILL_BOOK_RATE_ETS,skill_book_rate).
-define(SKILL_BOOK_ETS,skill_book).
-define(Skill_BOOK_STORE_ETS,skill_book_store).

%%
%% API Functions
%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(pet_skill_book_rate, record_info(fields,pet_skill_book_rate), [], set),
	db_tools:create_table_disc(pet_skill_book, record_info(fields,pet_skill_book),[], set),
	db_tools:create_table_disc(pet_fresh_skill, record_info(fields,pet_fresh_skill), [],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_skill_book_rate,proto},{pet_skill_book,proto},{pet_fresh_skill,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?SKILL_BOOK_RATE_ETS,[ordered_set,named_table,public]),
	ets:new(?SKILL_BOOK_ETS,[ordered_set,named_table,public]),
	ets:new(?Skill_BOOK_STORE_ETS,[ordered_set,named_table,public]).

init()->
	db_operater_mod:init_ets(pet_skill_book_rate, ?SKILL_BOOK_RATE_ETS,#pet_skill_book_rate.lucky),
	db_operater_mod:init_ets(pet_skill_book, ?SKILL_BOOK_ETS, #pet_skill_book.level),
	db_operater_mod:init_ets(pet_fresh_skill, ?Skill_BOOK_STORE_ETS, #pet_fresh_skill.roleid).


get_skill_rate_info(Lucky)->
	ets:foldl(fun({Check,Object},Acc)->
					  if Acc=/=[]->
							 Acc;
						 true->
							  if Check=:=1201->
									 if Lucky>=Check->
									 			Object;
										true->
											Acc
									 end;
								 true->
									Min=element(1,Check),
									Max=element(2,Check),
									if (Lucky>=Min) and (Lucky=<Max)->
										   Object;
									   true->
										   []
									end
							  end
					  end
							end , [], ?SKILL_BOOK_RATE_ETS).

get_skill_lucky(RateInfo)->
	Lucky=erlang:element(#pet_skill_book_rate.lucky, RateInfo),
	Lucky.
get_skill_rate(RateInfo)->
	Ratelist=erlang:element(#pet_skill_book_rate.rate, RateInfo),
	Ratelist.
	
get_skill_book_info()->
	try 
		case ets:lookup(?SKILL_BOOK_ETS, 1) of
			[{_,Object}]->
				Object;
			_->
				[]
		end
	catch
		_:Reason->
			io:format("skill book ets fail~n",[])
	end.

get_skilllist(Info)->
	Skilllist=erlang:element(#pet_skill_book.skill,Info),
	Skilllist.
	
store_pet_freshen_skill(Lucky,Skillinfo)->
	Roleid=get(roleid),
	Term=#pet_fresh_skill{roleid=Roleid,lucky=Lucky,skillinfo=Skillinfo},
	try
		ets:insert(?Skill_BOOK_STORE_ETS, {Roleid,Term}),
		dal:write_rpc(Term)
	catch
		_Other:_ERROR->nothing
			%io:format("@@@@@@@@   ~p~n",[ERROR])
	end.

delete_pet_skill_info()->
	Roleid=get(roleid),
	try
		ets:delete(?Skill_BOOK_STORE_ETS, Roleid),
		dal:delete_rpc(pet_fresh_skill,Roleid)
	catch
		_Catch:_ERROR->nothing
			%io:format("@@@@@@@@@   ~p~n",[ERROR])
	end.

get_pet_skill_info_by_store()->
	Roleid=get(roleid),
	try
		case ets:lookup(?Skill_BOOK_STORE_ETS, Roleid) of
			[{_,Info}]->
				Info;
			_->
				[]
		end
	catch
		_Other:_ERROR->nothing
			%io:format("@@@@@@@@@   ~p~n",[ERROR])
	end.

%%skilllevel=Skilllevel,skillid=220001,slot=0
get_skill_info_from_store_term(Info)->
	Skilllist=element(#pet_fresh_skill.skillinfo,Info),
	Skilllist.
get_skill_lucky_from_store_term(Info)->
	#pet_fresh_skill{lucky=Lucky}=Info,
	Lucky.
	
	
	
	



%%
%% Local Functions
%%


