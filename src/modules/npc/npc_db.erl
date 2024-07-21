%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
-module(npc_db).

%% 
%% Include
%% 
-include("mnesia_table_def.hrl").

-include("ai_define.hrl").
-include("npc_define.hrl").
-define(NPC_PROTO_ETS,npc_proto_ets).
-define(NPC_SPAWNS_ETS,npc_spawns_ets).

-export([get_creature_spawns_info/0,
		 get_creature_spawns_info/1,
		 get_creature_spawns_info_by_id/1,
		 get_spawn_id/1,get_spawn_protoid/1,get_spawn_mapid/1,set_spawn_mapid/2,get_spawn_bornposition/1,set_spawn_bornposition/2,get_spawn_movetype/1,get_spawn_retime/1,get_spawn_waypoint/1,get_spawn_hatreds_list/1,
		 get_spawn_actionlist/1,get_born_with_map/1,create_npc_spawn_info/6]).

-export([get_proto_info_by_id/1,get_proto_name/1,get_proto_level/1,get_proto_npcflags/1,get_proto_hpmax/1,
		 get_proto_mpmax/1,get_proto_attacktype/1,get_proto_power/1,get_proto_commoncool/1,get_proto_immunity/1,
		 get_proto_hitrate/1,get_proto_dodge/1,get_proto_criticalrate/1,get_proto_criticaldestroyrate/1,
		 get_proto_debuff_resist/1,get_proto_walkspeed/1,get_proto_runspeed/1,get_proto_exp/1,get_proto_min_money/1,
		 get_proto_max_money/1,get_proto_skills/1,get_proto_skillrates/1,get_proto_defense/1,get_proto_toughness/1,
		 get_hatredratio/1,get_proto_walkdelaytime/1,get_faction/1,get_death_share/1,get_proto_displayid/1,get_proto_script_baseattr/1]).

-export([import_creature_spawns/1]).

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
	ets:new(?NPC_PROTO_ETS, [set,named_table]),
	ets:new(?NPC_SPAWNS_ETS, [set,named_table]).

init()->
	ets:delete_all_objects(?NPC_SPAWNS_ETS),
	init_creature_spawns(),
	db_operater_mod:init_ets(creature_proto, ?NPC_PROTO_ETS,#creature_proto.id).

create_mnesia_table(disc)->
	db_tools:create_table_disc(creature_proto,record_info(fields,creature_proto),[],set),
	db_tools:create_table_disc(creature_spawns,record_info(fields,creature_spawns),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{creature_proto,proto},{creature_spawns,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_creature_spawns()->
	case dal:read_rpc(creature_spawns) of
		{ok,Creature_Spawns}-> lists:foreach(fun(Term)-> add_creature_spawns_to_ets(Term) end, Creature_Spawns);
		_-> slogger:msg("init_creature_spawns failed~n")
	end.

add_creature_spawns_to_ets(Term)->
	try		
		Id = erlang:element(#creature_spawns.id, Term),
		MapId= erlang:element(#creature_spawns.mapid, Term),
		ets:insert(?NPC_SPAWNS_ETS,{Id,MapId,Term})	
	catch
		_Error:Reason-> {error,Reason}
	end.

%% 
%% get_creatur_spawns_info
%% []
%%[...]
%%[err,""]
get_creature_spawns_info() ->
     try	
	case ets:tab2list(?NPC_SPAWNS_ETS) of
		[]->[];
		Creature->Creature
	end
     catch		
	_:_->[error,"is empty"]
     end.	  


%% 
%% get_creatur_spawns_info
%% []
%%[...]
%%[err,""]
get_creature_spawns_info(Mapid) ->
	try
		case ets:match(?NPC_SPAWNS_ETS,{'_',Mapid,'$1'}) of
			[]-> [];
			Value-> lists:append(Value)
		end
	catch
		_:Reason->
		slogger:msg("get_creature_spawns_info error:~p~n",[Reason]), 
		[]
	end.		  
   
get_creature_spawns_info_by_id(NpcId)->
	case ets:lookup(?NPC_SPAWNS_ETS, NpcId) of
		[]->[];
		[{_NpcId,_MapId,Value}] -> Value
	end.

%% term()
%% error
%% 
get_spawn_id(SpawnInfo)->
	element(#creature_spawns.id,SpawnInfo).	       



get_spawn_protoid(SpawnInfo)->			
	element(#creature_spawns.protoid,SpawnInfo).	       

%% 
%% {ok,value}
%% {error,""}
%% 
get_spawn_mapid(SpawnInfo)->		
	case element(#creature_spawns.mapid,SpawnInfo) of
		{_LineId,MapId}->
			MapId;
		MapId->
			MapId
	end.

set_spawn_mapid(SpawnInfo,MapId)->
	erlang:setelement(#creature_spawns.mapid,SpawnInfo,MapId).

%% 
%% {ok,value}
%% {error,""}
%% 
get_spawn_bornposition(SpawnInfo)->	
	element(#creature_spawns.bornposition,SpawnInfo).	       

set_spawn_bornposition(SpawnInfo,Value)->	
	setelement(#creature_spawns.bornposition,SpawnInfo,Value).	       
%% 
%% {ok,value}
%% {error,""}
%% 
get_spawn_movetype(SpawnInfo)->	
	element(#creature_spawns.movetype,SpawnInfo).	       

%% 
%% {ok,value}
%% {error,""}
%% 
get_spawn_waypoint(SpawnInfo)->
	element(#creature_spawns.waypoint,SpawnInfo).	       
			

%% 
%% {ok,value}
%% {error,""}
%% 
get_spawn_retime(SpawnInfo)->	
	element(#creature_spawns.respawntime,SpawnInfo).	       
	
%% 
%%creature_proto 
%% 
get_spawn_actionlist(SpawnInfo)->	
	element(#creature_spawns.actionlist,SpawnInfo).	       

get_spawn_hatreds_list(SpawnInfo)->	
	element(#creature_spawns.hatreds_list,SpawnInfo).	       


get_born_with_map(SpawnInfo)->	
	element(#creature_spawns.born_with_map,SpawnInfo).	       

create_npc_spawn_info(Id,Protoid,Mapid,Bornposition,Movetype,WayPoints)->
	case WayPoints of
		[]->
			ActionList = [];
		_->
			ActionList = [{normal_ai,move,?MOVE_DELAY_TIME,[]}]
	end,
	#creature_spawns{id = Id,protoid = Protoid,mapid = Mapid,bornposition=Bornposition,
	movetype = Movetype,waypoint=WayPoints,respawntime=0,actionlist=ActionList,hatreds_list= [],born_with_map =0}.


%% 
%% get_proto_info_by_id()
%% []
%% {...}
%%[error,....]
%%
get_proto_info_by_id(Id)->
	try
		case ets:lookup(?NPC_PROTO_ETS,Id) of
			[]->[];
			[{_Id,Value}] -> Value
		end
	catch
		_:_-> [error,"No this Role!"]
	end.



%% 
%% return : Value | []
%% 
get_proto_name(ProtoInfo)->			
	element(#creature_proto.name,ProtoInfo).
%% 
%% return : Value | []
%% 
get_proto_level(ProtoInfo)->			
	element(#creature_proto.level,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_npcflags(ProtoInfo)->			
	element(#creature_proto.npcflags,ProtoInfo).

get_faction(ProtoInfo)->			
	element(#creature_proto.faction,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_hpmax(ProtoInfo)->			
	element(#creature_proto.hpmax,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_mpmax(ProtoInfo)->			
	element(#creature_proto.mpmax,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_attacktype(ProtoInfo)->			
	element(#creature_proto.attacktype,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_power(ProtoInfo)->			
	element(#creature_proto.power,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_commoncool(ProtoInfo)->			
	element(#creature_proto.commoncool,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_immunity(ProtoInfo)->			
	element(#creature_proto.immunes,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_hitrate(ProtoInfo)->			
	element(#creature_proto.hitrate,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_dodge(ProtoInfo)->			
	element(#creature_proto.dodge,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_criticalrate(ProtoInfo)->			
	element(#creature_proto.criticalrate,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_criticaldestroyrate(ProtoInfo)->			
	element(#creature_proto.criticaldestroyrate,ProtoInfo).
	
%% 
%% return : Value | []
%% 	
get_proto_toughness(ProtoInfo)->			
	element(#creature_proto.toughness,ProtoInfo).


%% 
%% return : Value | []
%% 
get_proto_debuff_resist(ProtoInfo)->			
	element(#creature_proto.debuff_resist,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_walkspeed(ProtoInfo)->			
	element(#creature_proto.walkspeed,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_runspeed(ProtoInfo)->			
	element(#creature_proto.runspeed,ProtoInfo).


%% 
%% return : Value | []
%% 
get_proto_exp(ProtoInfo)->			
	element(#creature_proto.exp,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_min_money(ProtoInfo)->			
	element(#creature_proto.min_money,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_max_money(ProtoInfo)->			
	element(#creature_proto.max_money,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_skills(ProtoInfo)->			
	element(#creature_proto.skills,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_skillrates(ProtoInfo)->			
	element(#creature_proto.skillrates,ProtoInfo).

%% 
%% return : Value | []
%% 
get_proto_defense(ProtoInfo)->			
	element(#creature_proto.defense,ProtoInfo).

get_hatredratio(ProtoInfo)->
	element(#creature_proto.hatredratio,ProtoInfo).

get_proto_walkdelaytime(ProtoInfo)->
	element(#creature_proto.walkdelaytime,ProtoInfo).

get_proto_displayid(ProtoInfo)->
	element(#creature_proto.displayid,ProtoInfo).

get_death_share(ProtoInfo)->
	element(#creature_proto.death_share,ProtoInfo).

get_proto_script_baseattr(ProtoInfo)->
	element(#creature_proto.script_baseattr,ProtoInfo).

%% 
%% 
%% import_creature_spawns
%% 	
import_creature_spawns(File)->	
	dal:clear_table(creature_spawns),
	case file:consult(File) of
		{ok,[Terms]}->
			lists:foreach(fun(Term)->add_creature_spawns_to_mnesia(Term),
									 add_creature_spawns_to_ets(Term)  end,Terms);
		{error,Reason} ->
			slogger:msg("import_creature_spawns error:~p~n",[Reason])
	end.

add_creature_spawns_to_mnesia(Term)->
	try
		NewTerm = list_to_tuple([creature_spawns|tuple_to_list(Term)]),
		dal:write(NewTerm)
	catch
		E:R-> io:format("Reason ~p: ~p~n",[E,R]),error
	end.


