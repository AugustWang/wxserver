%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-12-13
%% Description: TODO: Add description to system_chat_op
-module(system_chat_op).
-include("system_chat_def.hrl").
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([send_message/3,send_message_instance/4,system_broadcast/2,system_broadcast_instance/3,send_message_guild/3]).
-export([send_equipment_message/6]).

system_broadcast(Id,Param) ->
	case system_chat_db:get_msg_option(Id) of
		[]-> 
			ignor;
		OptInfo->			
			Scop = system_chat_db:get_scope_from_msg_option(OptInfo),
			case Scop of
				world->					
					case server_travels_util:is_share_server() of
						true->
							server_travels_util:cast_for_all_server(chat_manager,system_broadcast,[Id,Param,[]]);
						_->	
							chat_manager:system_broadcast(Id,Param,[])
					end;
				map->
					MapInfo = get(map_info),
					MapId = creature_op:get_mapid_from_mapinfo(MapInfo),	
					chat_manager:system_broadcast(Id,Param,{map,MapId});
				mapline->
					MapInfo = get(map_info),
					MapId = creature_op:get_mapid_from_mapinfo(MapInfo),	
					LineId = creature_op:get_lineid_from_mapinfo(MapInfo),	
					chat_manager:system_broadcast(Id,Param,{map,MapId,LineId});
				instance->
					MapInfo = get(map_info),
					Instance = creature_op:get_proc_from_mapinfo(MapInfo),	
					chat_manager:system_broadcast(Id,Param,{instance,Instance});
				allserver->
					server_travels_util:cast_for_all_server(chat_manager,system_broadcast,[Id,Param,[]])				
			end
	end.

system_broadcast_instance(Id,Param,Instance)->
	chat_manager:system_broadcast(Id,Param,{instance,Instance}).

send_message(Id,Args,ClrArgs)->
	case system_chat_db:get_msg_option(Id) of
		[]-> 
			ignor;
		OptInfo->
			Fun = system_chat_db:get_fun_from_msg_option(OptInfo),
			Out = Fun(Args,ClrArgs),
			Type = system_chat_db:get_type_from_msg_option(OptInfo),
			Scop = system_chat_db:get_scope_from_msg_option(OptInfo),
			case Scop of
				allserver->
					server_travels_util:cast_for_all_server(chat_manager,system_message,[Type,Out]);
				world->	
					case server_travels_util:is_share_server() of
						true->
							server_travels_util:cast_for_all_server(chat_manager,system_message,[Type,Out]);
						_->	
							chat_manager:system_message(Type,Out)
					end;
				map->
					MapInfo = get(map_info),
					MapId = creature_op:get_mapid_from_mapinfo(MapInfo),	
					chat_manager:system_message(Type,Out,{map,MapId});
				mapline->
					MapInfo = get(map_info),
					MapId = creature_op:get_mapid_from_mapinfo(MapInfo),	
					LineId = creature_op:get_lineid_from_mapinfo(MapInfo),	
					chat_manager:system_message(Type,Out,{map,MapId,LineId});
				instance->
					MapInfo = get(map_info),
					Instance = creature_op:get_proc_from_mapinfo(MapInfo),	
					chat_manager:system_message(Type,Out,{instance,Instance})				
			end
	end.

send_message_instance(Id,Args,ClrArgs,Instance)->
	try
		case system_chat_db:get_msg_option(Id) of
			[]-> 
				ignor;
			OptInfo->
				Fun = system_chat_db:get_fun_from_msg_option(OptInfo),
				Out = Fun(Args,ClrArgs),
				Type = system_chat_db:get_type_from_msg_option(OptInfo),
				chat_manager:system_message(Type,Out,{instance,Instance})
		end
	catch
		E:R->slogger:msg("send_message_instance Id,Args,ClrArgs,Instance ~p E:R ~p ~p ~p ~n",[{Id,Args,ClrArgs,Instance},E,R,erlang:get_stacktrace()])
	end.

%%
%%甯細骞挎挱
%%
send_message_guild(Id,Args,ClrArgs)->
	try
		case system_chat_db:get_msg_option(Id) of
			[]-> 
				ignor;
			OptInfo->
				Fun = system_chat_db:get_fun_from_msg_option(OptInfo),
				Out = Fun(Args,ClrArgs),
				Type = system_chat_db:get_type_from_msg_option(OptInfo),
				%%chat_manager:system_message(Type,Out,{guild,Guild})
				chat_op:send_guild(Type, "system",[],Out)
		end
	catch
		E:R->slogger:msg("send_message_guild Id,Args,ClrArgs ~p E:R ~p ~p ~p ~n",[{Id,Args,ClrArgs},E,R,erlang:get_stacktrace()])
	end.

%%
%%
%%
send_equipment_message(BrdId,RoleName,NpcName,EquipmentName,Count,EquipmentColor)->
	send_message(BrdId,[RoleName,EquipmentName],EquipmentColor).
