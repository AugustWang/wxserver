%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-8-5
%% Description: TODO: Add description to role_level_db
-module(role_level_db).

%%
%% Include files
%%
-include("levelup_opt_def.hrl").

-define(ROLE_LEVEL_ETS,role_level_up_ets).
-define(ROLE_LEVEL_OPT_ETS,role_level_opt_ets).

%%
%% Exported Functions
%%
-export([obtain_experience/1,get_level_experience/1]).

-export([load_role_levelup_opts_level/1,is_have_done_levelup_opt/2,write_level_up_done/3]).


-export([get_levelup_opt_info/1,get_levelup_opt_reward_items/1,get_levelup_opt_script/1]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,init/0,create/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?ROLE_LEVEL_ETS, [set,named_table]),
	ets:new(?ROLE_LEVEL_OPT_ETS, [set,named_table]).

init()->
	init_role_level(),
	db_operater_mod:init_ets(levelup_opt, ?ROLE_LEVEL_OPT_ETS,#levelup_opt.level).

create_mnesia_table(disc)->
	db_tools:create_table_disc(levelup_opt,record_info(fields,levelup_opt),[],set),
	db_tools:create_table_disc(role_level_experience,record_info(fields,role_level_experience),[],set),
	db_tools:create_table_disc(role_levelup_opt_record,record_info(fields,role_levelup_opt_record),[roleid],set).


create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(RoleId)->
	case dal:read_index_rpc(role_levelup_opt_record, RoleId, #role_levelup_opt_record.roleid) of
		{ok,List}->
			lists:foreach(fun(Object)->dal:delete_object_rpc(Object) end, List);
		_->
			nothing
	end.

tables_info()->
	[{role_level_experience,proto},{levelup_opt,proto},{role_levelup_opt_record,disc}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% API Functions
%%

obtain_experience(Experience)->
	OldExp = case get(current_exp) of
				undefined -> 0;
				Value-> Value
			end,
	LockExp = get_experience_lock(),
	NewExp =if OldExp <  LockExp  -> 
				put(current_exp,OldExp + Experience),OldExp + Experience;
				true->OldExp
			end,
	NewLevel = get_experience_level(NewExp),
	{NewLevel,NewExp}.

get_levelup_opt_info(Level)->
	case ets:lookup(?ROLE_LEVEL_OPT_ETS,Level ) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_levelup_opt_reward_items(Info)->
	erlang:element(#levelup_opt.items, Info).

get_levelup_opt_script(Info)->
	erlang:element(#levelup_opt.script, Info).

load_role_levelup_opts_level(RoleId)->
	case dal:read_index_rpc(role_levelup_opt_record, RoleId, #role_levelup_opt_record.roleid) of
		{ok,[]}->
			[];
		{ok,Lists}->
			lists:map(fun(Term)-> {_,Level}= erlang:element(#role_levelup_opt_record.roleid_level, Term),Level end,Lists); %%have got gift
		_->[]
	end.

is_have_done_levelup_opt(RoleId,Level)->
	case dal:read_rpc(role_levelup_opt_record, {RoleId,Level}) of
		{ok,[]}->
			false;
		{ok,[_]}->
			true;
		_->error
	end.

write_level_up_done(RoleId,Level,Ext)->
	case dal:write_rpc({role_levelup_opt_record,{RoleId,Level},RoleId,Ext}) of
		{ok}-> ok;
		{failed,Reason}->slogger:msg("Write card failed :~p ~n", [Reason]),error;
		_-> error
	end.

%%
%% Local Functions
%%

init_role_level()->
	AddLevelsTo=fun({role_level_experience,Level,Experience},Acc)-> 
					case Level of
						experience_lock->
							ets:insert(?ROLE_LEVEL_ETS, {experience_lock,Experience}),Acc;
						_-> [{Level,Experience}|Acc]
					end
				end,
	case dal:read_rpc(role_level_experience) of
		{ok,LevelExperiences}->ResultTuple = lists:foldl(AddLevelsTo, [], LevelExperiences),
							   ResultTuple2 = lists:sort(fun({Level1,_Exp1},{Level2,_Exp2})->
																 if Level1> Level2->
																		false;
																	true-> true
																 end
														 end,ResultTuple),
							   ets:insert(?ROLE_LEVEL_ETS, {every_level,ResultTuple2});
								
		_->  slogger:msg("init_role_level failed~n")
	end.
	

%%
%% return:  Value | nolevel
%%
get_level_experience(Level)->
		case get_experience_info() of
			noinfo-> nolevel;
			Level_Exp_List-> case lists:keyfind(Level, 1, Level_Exp_List) of
										false-> noleve;
										{_,Experience}-> Experience
									end
		end.


get_experience_info()->
	try
		case ets:lookup(?ROLE_LEVEL_ETS, every_level) of
			[]-> noinfo;
			[{_,Level_Exp_List}]->Level_Exp_List
		end
	catch
		_:_-> noinfo
	end.


get_experience_level(Experience)->
		case get_experience_info() of
			noinfo-> nolevel;
			Level_Exp_List-> 
				CurLevel = lists:foldr(fun({Level,Level_Experience},Acc)-> 
								if
									Acc =/= 1 -> Acc;
									Experience>= Level_Experience -> Level;
									true-> 1
								end
							end,1,Level_Exp_List),
				CurLevel
		end.		


%%
%%
%%
get_experience_lock()->
	try
		case ets:lookup(?ROLE_LEVEL_ETS, experience_lock) of
			[]-> 0;
			[{_,Level_Exp}]-> Level_Exp
		end
	catch
		_:_-> 0
	end.
