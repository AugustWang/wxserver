
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 地图信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-ifndef(MAP_INFO_STRUCT_H).
-define(MAP_INFO_STRUCT_H,true).
-compile({inline, [{get_grid_width_from_mapinfo, 1},
		   {get_proc_from_mapinfo, 1}
		  ]}).

-record(gm_map_info, {map_id, line_id, map_proc, map_node, grid_width, width}).

create_mapinfo(MapId,LineId,MapNode,MapProc,GridWith) ->
	#gm_map_info{map_id = MapId, line_id = LineId, map_proc = MapProc, map_node = MapNode, grid_width = GridWith}.

get_grid_width_from_mapinfo(MapInfo) ->
	#gm_map_info{grid_width=Grid_width} = MapInfo,
	Grid_width.
set_grid_width_to_mapinfo(MapInfo, Grid_width) ->
	MapInfo#gm_map_info{grid_width=Grid_width}.

get_proc_from_mapinfo(MapInfo) ->
	#gm_map_info{map_proc=MapProc} = MapInfo,
	MapProc.
set_proc_to_mapinfo(MapInfo, Proc) ->
	MapInfo#gm_map_info{map_proc=Proc}.

get_node_from_mapinfo(MapInfo) ->
	#gm_map_info{map_node=Map_node} = MapInfo,
	Map_node.
set_node_to_mapinfo(MapInfo, Node) ->
	MapInfo#gm_map_info{map_node=Node}.
	
get_mapid_from_mapinfo(MapInfo) ->
	#gm_map_info{map_id=MapId} = MapInfo,
	MapId.
set_mapid_to_mapinfo(MapInfo, MapId) ->
	MapInfo#gm_map_info{map_id=MapId}.

get_lineid_from_mapinfo(MapInfo) ->
	#gm_map_info{line_id=LineId} = MapInfo,
	LineId.
set_lineid_to_mapinfo(MapInfo, LineId) ->
	MapInfo#gm_map_info{line_id=LineId}.

-endif.