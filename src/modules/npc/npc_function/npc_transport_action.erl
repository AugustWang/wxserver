%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-8-20
%% Description: TODO: Add description to npc_transport
-module(npc_transport_action).
-include("mnesia_table_def.hrl").
-include("login_pb.hrl").
-include("npc_define.hrl").
-include("system_chat_define.hrl").
-include("error_msg.hrl").
%%
%% Include files
%%

-behaviour(npc_function_mod).

-export([init_func/0,registe_func/1,enum/3]).
%%
%% Exported Functions
%%
-export([transport_action/5]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(npc_trans_list,record_info(fields,npc_trans_list),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{npc_trans_list,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


init_func()->
	npc_function_frame:add_function(transport, ?NPC_FUNCTION_TRANSPOT,?MODULE).

registe_func(NpcId)->
	TransportIds = read_transport_for_npc(NpcId),
	Mod= ?MODULE,
	Fun= transport_action,
	Arg= TransportIds,
	Response= #kl{key=?NPC_FUNCTION_TRANSPOT, value=TransportIds},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = [],
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	{Response,Action,Enum}.

enum(_,_,_)->
	[].

transport_action(RoleInfo,TransportIds,TransportId,MapInfo,NpcId)->	
	IsinPrison = pvp_op:is_in_prison(),
	State = if 
				IsinPrison ->
					CanOutPrison = pvp_op:can_get_outof_prison(),
					if 
						CanOutPrison ->
							system_broadcast(?SYSTEM_CHAT_GOT_OUT_PRISON,get(creature_info)),
							true;
						true ->
							false
					end;
				true ->
					true  
			end,
	IsTreasure_Transport = role_treasure_transport:is_treasure_transporting(),
	if 
		not IsTreasure_Transport ->
			if State ->
					case lists:member(TransportId, TransportIds) of
						true->
							transport_op:teleport(RoleInfo, MapInfo,TransportId);
						false ->
							slogger:msg("get_npc_trans_info_id not found,maybe hack! RoleId ~p NpcId ~p TransportId ~p ~n",[get(roleid),NpcId,TransportId]),
							false
					end;
				true ->
					false
			end;
		true->
			Msg = role_packet:encode_map_change_failed_s2c(?ERRNO_CAN_NOT_DO_IN_TREASURE_TRANSPORT),
			role_op:send_data_to_gate(Msg)
	end.

%%	transport_op:transport_by_npc(RoleInfo, MapInfo, _TransportIds,TransportId,NpcId).
system_broadcast(SysId,RoleInfo)->   
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	system_chat_op:system_broadcast(SysId,[ParamRole]).


read_transport_for_npc(NpcId)->
	case dal:read_rpc(npc_trans_list, NpcId) of
		{ok,[R]}->  element(#npc_trans_list.id,R);
		_->[]
	end.
	
