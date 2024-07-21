%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-15
%% Description: TODO: Add description to role_db
-module(role_pos_db).

%%
%% Include files
%%
-define(ROLE_POS,role_pos).

%%
%% Exported Functions
%%

-define(ROLEID,1).
-define(MAPNAME,?ROLEID+1).
-define(MAPNODE,?MAPNAME+1).
-define(MAPPROC,?MAPNODE+1).
-define(GATENODE,?MAPPROC+1).
-define(GATEPROC,?GATENODE+1).

-export([reg_role_pos_to_mnesia/8,
		 unreg_role_pos_to_mnesia/1,
		 update_role_line_map/3,
		 update_role_line_map_node/4,
		 update_role_pos_rolename/2]).

-export([get_role_pos_from_mnesia/1,
		 get_role_pos_from_mnesia_by_name/1,
		 get_role_id/1,
		 get_role_lineid/1,
		 get_role_mapid/1,
		 get_role_rolename/1,
		 get_role_mapnode/1,
		 get_role_pid/1,
		 get_role_gatenode/1,
		 get_role_gateproc/1,
		 foreach/1,
		 foldl/2,
		 foreach_by_map/2,
		 foreach_by_map_line/3,
		 get_online_count/0,
		 unreg_role_pos_to_mnesia_by_node/1]).

-export([get_all_rolepos/0,get_role_info_by_map/1,get_role_info_by_line/1,get_role_info_by_map_line/2]).

-include("mnesia_table_def.hrl").	
-include_lib("stdlib/include/qlc.hrl").	

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(ram)->
	db_tools:create_table_ram(role_pos, record_info(fields,role_pos),[],set);
create_mnesia_table(disc)->
	nothing.

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{role_pos,ram}].

delete_role_from_db(RoleId)->
	nothing.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%====================node operater ====================%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_role_line_map_node(RoleId,NewLineId,NewMapId,NewNode)->
	case get_role_pos_from_mnesia(RoleId) of
		[]-> ignor;
		{_,RoleId,_Lineid,_MapId,RoleName,_RoleNode,RoleProc,GateNode,Gateproc}->		
			reg_role_pos_to_mnesia(RoleId, NewLineId,NewMapId,RoleName,NewNode,RoleProc,GateNode,Gateproc)
	end.

reg_role_pos_to_mnesia(Roleid, Lineid,MapId,RoleName,Rolenode,Roleproc,Gatenode,Gateproc)->
	try		
		dal:write({role_pos,Roleid, Lineid,MapId,RoleName, Rolenode,Roleproc,Gatenode,Gateproc})
	catch
		E:R-> slogger:msg("reg_role_pos_to_mnesia ~p:~p~n",[E,R]),error
	end.

unreg_role_pos_to_mnesia(RoleId)->
	dal:delete(role_pos,RoleId).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				node operater end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				role_pos data operater,use role_pos_util instead!!!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_role_pos_rolename(RoleId,NewRoleName)->
	case get_role_pos_from_mnesia(RoleId) of
		[]-> ignor;
		{_,RoleId,Lineid,MapId,_OldRoleName,RoleNode,RoleProc,GateNode,Gateproc}->		
			reg_role_pos_to_mnesia(RoleId, Lineid,MapId,NewRoleName,RoleNode,RoleProc,GateNode,Gateproc)
	end.

update_role_line_map(RoleId,NewLineId,NewMapId)->
	case get_role_pos_from_mnesia(RoleId) of
		[]-> ignor;
		{_,RoleId,_Lineid,_MapId,RoleName,RoleNode,RoleProc,GateNode,Gateproc}->		
			reg_role_pos_to_mnesia(RoleId, NewLineId,NewMapId,RoleName,RoleNode,RoleProc,GateNode,Gateproc)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				role_pos data operater,use role_pos_util instead!!!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


delete_fun(DelList)->	
	lists:foreach(fun(DelOb)->mnesia:delete_object(DelOb)end,DelList).
	
unreg_role_pos_to_mnesia_by_node(Mapnode)->
	try
		S = fun()->
				Q = qlc:q([X|| X<-mnesia:table(role_pos),X#role_pos.rolenode=:=Mapnode]),
				DelList = qlc:e(Q),
				delete_fun(DelList)
			end,						
		dal:run_transaction(S)		
	catch
		E:R-> slogger:msg("unreg_role_pos_to_mnesia_by_node ~pR~p~n",[E,R])
	end.
	
get_role_pos_from_mnesia(RoleId)->
	case ets:lookup(?ROLE_POS, RoleId) of
		[]->[];
		[RolePosInfo|_]->RolePosInfo
	end.


get_role_pos_from_mnesia_by_name(RoleName) when is_list(RoleName)->
	case ets:match_object(?ROLE_POS, {'_','_','_','_',list_to_binary(RoleName),'_','_','_','_'}) of
		[]->[];
		[RolePosInfo|_]->RolePosInfo
	end;
get_role_pos_from_mnesia_by_name(RoleName) when is_binary(RoleName)->
	case ets:match_object(?ROLE_POS, {'_','_','_','_',RoleName,'_','_','_','_'}) of
		[]->[];
		[RolePosInfo|_]->RolePosInfo
	end.
	
get_all_rolepos()->
	ets:tab2list(?ROLE_POS).

get_role_info_by_map(MapId)->
	case ets:match_object(?ROLE_POS, {'_','_','_',MapId,'_','_','_','_','_'}) of
		[]->[];
		RolePosInfo->RolePosInfo
	end.

get_role_info_by_line(LineId)->
	case ets:match_object(?ROLE_POS, {'_','_',LineId,'_','_','_','_','_','_'}) of
		[]->[];
		RolePosInfo->RolePosInfo
	end.

get_role_info_by_map_line(MapId,LineId)->
	case ets:match_object(?ROLE_POS, {'_','_',LineId,MapId,'_','_','_','_','_'}) of
		[]->[];
		RolePosInfo->RolePosInfo
	end.

get_online_count()->
	case ets:info(?ROLE_POS,size) of
		undefined->
			0;
		Count->
			Count
	end.

get_role_id(RolePos)->
	element(#role_pos.roleid,RolePos).	

get_role_lineid(RolePos)->
	element(#role_pos.lineid,RolePos).
		
get_role_mapid(RolePos)->
	element(#role_pos.mapid,RolePos).

get_role_rolename(RolePos)->
	element(#role_pos.rolename,RolePos).

get_role_mapnode(RolePos)->
	element(#role_pos.rolenode,RolePos).
		
get_role_pid(RolePos)->
	element(#role_pos.roleproc,RolePos).	
		
get_role_gatenode(RolePos)->
	element(#role_pos.gatenode,RolePos).		
		
get_role_gateproc(RolePos)->
	element(#role_pos.gateproc,RolePos).					
		
foreach(InputFun)->
	F  = fun(E,_Acc)->
			InputFun(E),[]
		 end,
	ets:foldl(F, [], ?ROLE_POS).

foldl(F,A)->
	ets:foldl(F, A, ?ROLE_POS).

foreach_by_map(InputFun,MapId)->
	RolePos = get_role_info_by_map(MapId),
	lists:foreach(InputFun,RolePos).

foreach_by_map_line(InputFun,MapId,LineId)->
	RolePos = get_role_info_by_map_line(MapId,LineId),
	lists:foreach(InputFun,RolePos).
