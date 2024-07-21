%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(everquest_handle).

-compile(export_all).

-include("common_define.hrl").
-include("map_info_struct.hrl").

handle_npc_start_everquest(EverQId,NpcId)->
	Mapid = get_mapid_from_mapinfo(get(map_info)),	
	npc_function_frame:do_action(Mapid,get(creature_info),NpcId,everquest_action,[start,NpcId,EverQId]).

handle_refresh_everquest(EverId,Type, MaxQuality, MaxTimes)->
	everquest_op:refresh_quality(EverId,Type, MaxQuality, MaxTimes).

handle_npc_everquests_enum_c2s(NpcId)->
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	npc_function_frame:do_enum(Mapid,get(creature_info),NpcId,everquest_action).