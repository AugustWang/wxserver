%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 说明: 
%%     gs 表示该 record 是在game_server内部用的数据结构;
%%     system 表示该 record 的信息是基础系统的信息, 与游戏逻辑系统没有关系;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 基础系统的地图数据 Map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-ifndef(DATA_STRUCT_H).
-define(DATA_STRUCT_H,true).

-record(gs_system_map_info, {map_id, line_id, map_proc, map_node}).

get_proc_from_gs_system_mapinfo(GS_system_mapinfo)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	#gs_system_map_info{map_proc=Proc} = GS_system_mapinfo,
	Proc.
set_proc_to_gs_system_mapinfo(GS_system_mapinfo, Proc)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	GS_system_mapinfo#gs_system_map_info{map_proc=Proc}.

get_node_from_gs_system_mapinfo(GS_system_mapinfo)    
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	#gs_system_map_info{map_node=Node} = GS_system_mapinfo,
	Node.
set_node_to_gs_system_mapinfo(GS_system_mapinfo, Node)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	GS_system_mapinfo#gs_system_map_info{map_node=Node}.

get_mapid_from_gs_system_mapinfo(GS_system_mapinfo)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	#gs_system_map_info{map_id=Id} = GS_system_mapinfo,
	Id.
set_mapid_to_gs_system_mapinfo(GS_system_mapinfo, Id)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	GS_system_mapinfo#gs_system_map_info{map_id=Id}.

get_lineid_from_gs_system_mapinfo(GS_system_mapinfo)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	#gs_system_map_info{line_id=Line_id} = GS_system_mapinfo,
	Line_id.
set_lineid_to_gs_system_mapinfo(GS_system_mapinfo, Line_id)
  when is_record(GS_system_mapinfo, gs_system_map_info) ->
	GS_system_mapinfo#gs_system_map_info{line_id=Line_id}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 基础系统的角色数据 Role
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-compile({inline, [{get_id_from_gs_system_roleinfo,1}]}).

-record(gs_system_role_info, {role_id, role_pid,role_node}).

get_id_from_gs_system_roleinfo(GS_system_role_info) 
  when is_record(GS_system_role_info, gs_system_role_info) ->
	#gs_system_role_info{role_id=Id} = GS_system_role_info,
	Id.
set_id_to_gs_system_roleinfo(GS_system_role_info, Id)
  when is_record(GS_system_role_info, gs_system_role_info) ->
	GS_system_role_info#gs_system_role_info{role_id=Id}.

get_pid_from_gs_system_roleinfo(GS_system_role_info)
  when is_record(GS_system_role_info, gs_system_role_info) ->
	#gs_system_role_info{role_pid=Pid} = GS_system_role_info,
	Pid.
set_pid_to_gs_system_roleinfo(GS_system_role_info, Pid)
  when is_record(GS_system_role_info, gs_system_role_info) ->
	GS_system_role_info#gs_system_role_info{role_pid=Pid}.
	
get_node_from_gs_system_roleinfo(GS_system_role_info)
  when is_record(GS_system_role_info, gs_system_role_info) ->
	#gs_system_role_info{role_node=Role_node} = GS_system_role_info,
	Role_node.
set_node_to_gs_system_roleinfo(GS_system_role_info, Role_node)
  when is_record(GS_system_role_info, gs_system_role_info) ->
	GS_system_role_info#gs_system_role_info{role_node=Role_node}.	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 基础系统的网关信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(gs_system_gate_info, {gate_proc, gate_node, gate_pid}).

get_proc_from_gs_system_gateinfo(GS_system_gate_info)
  when is_record(GS_system_gate_info, gs_system_gate_info) ->
	#gs_system_gate_info{gate_proc=Proc} = GS_system_gate_info,
	Proc.
set_proc_to_gs_system_gateinfo(GS_system_gate_info, Proc)
  when is_record(GS_system_gate_info, gs_system_gate_info) ->
	GS_system_gate_info#gs_system_gate_info{gate_proc=Proc}.

get_node_from_gs_system_gateinfo(GS_system_gate_info)
  when is_record(GS_system_gate_info, gs_system_gate_info) ->
	#gs_system_gate_info{gate_node=Node} = GS_system_gate_info,
	Node.
set_node_to_gs_system_gateinfo(GS_system_gate_info, Node)
  when is_record(GS_system_gate_info, gs_system_gate_info) ->
	GS_system_gate_info#gs_system_gate_info{gate_node=Node}.

get_pid_from_gs_system_gateinfo(GS_system_gate_info)
  when is_record(GS_system_gate_info, gs_system_gate_info) ->
	#gs_system_gate_info{gate_pid=Pid} = GS_system_gate_info,
	Pid.
set_pid_to_gs_system_gateinfo(GS_system_gate_info, Pid)
  when is_record(GS_system_gate_info, gs_system_gate_info) ->
	GS_system_gate_info#gs_system_gate_info{gate_pid=Pid}.
	
-endif.