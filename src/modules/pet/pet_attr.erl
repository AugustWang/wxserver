%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pet_attr).

-include("common_define.hrl").
-include("data_struct.hrl").
-include("pet_struct.hrl").
-compile(export_all).

pet_into_view_broad(GmPetInfo)->
	CreateObj = object_update:make_create_data(?UPDATETYPE_PET,GmPetInfo),
	GateProc = get_proc_from_gs_system_gateinfo(get(gate_info)),
	tcp_client:object_update_create(GateProc,CreateObj),
	creature_op:direct_broadcast_to_aoi_gate({object_update_create,CreateObj}).

pet_out_view_broad(PetId)->
	DelData = object_update:make_delete_data(PetId),
	GatePid = get_proc_from_gs_system_gateinfo(get(gate_info)),
	tcp_client:object_update_delete(GatePid,DelData),
	creature_op:direct_broadcast_to_aoi_gate({object_update_delete,DelData}).

self_update_and_broad(PetId,UpdateAttr)->
	UpdateObj = object_update:make_update_attr(?UPDATETYPE_PET,PetId,UpdateAttr),
	GateProc = get_proc_from_gs_system_gateinfo(get(gate_info)),
	tcp_client:object_update_update(GateProc,UpdateObj),
	creature_op:direct_broadcast_to_aoi_gate({object_update_update,UpdateObj}).

only_self_update(PetId,UpdateAttr)->
	UpdateObj = object_update:make_update_attr(?UPDATETYPE_PET,PetId,UpdateAttr),
	GateProc = get_proc_from_gs_system_gateinfo(get(gate_info)),
	tcp_client:object_update_update(GateProc,UpdateObj).

move_notify_aoi_roles(PetId,Pos,Path,Time)->
	Message = role_packet:encode_other_role_move_s2c(PetId,Time, Pos, Path),
	role_op:broadcast_message_to_aoi_client(Message).
