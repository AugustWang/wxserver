%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(global_monster_loot).

-define(ETS_NAME,global_monster_loot).
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% Include files 
%%
-include("global_monster_loot_def.hrl").

%%
%% API Functions
%%
-export([create/0,init/0]).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(global_monster_loot_db,record_info(fields,global_monster_loot_db),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{global_monster_loot_db,disc}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?ETS_NAME,[named_table,set]).

init()->
	db_operater_mod:init_ets(global_monster_loot_db, ?ETS_NAME, #global_monster_loot_db.id).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_global_drop_list(NpcId,CreatureLevel)-> 
	ets:foldl(fun({_Id,Term},TmpDrops)->
			Level = erlang:element(#global_monster_loot_db.minlevel,Term),
			Drops = erlang:element(#global_monster_loot_db.dropids,Term),
			StartTime = erlang:element(#global_monster_loot_db.start_time,Term),
			EndTime = erlang:element(#global_monster_loot_db.end_time,Term),
			NpcList = erlang:element(#global_monster_loot_db.npclist,Term),
			IsInNpcList = lists:member(NpcId,NpcList),
			if
				(NpcList =:= [0]) and (CreatureLevel >= Level)->
					case timer_util:is_in_time_point(StartTime,EndTime,calendar:local_time()) of
						true->
							TmpDrops++Drops;
						_->
							TmpDrops
					end;
				(NpcList =/= [0]) and IsInNpcList ->
					case timer_util:is_in_time_point(StartTime,EndTime,calendar:local_time()) of
						true->
							TmpDrops++Drops;
						_->
							TmpDrops
					end;
				true->
					TmpDrops
			end
		end,[], ?ETS_NAME).


