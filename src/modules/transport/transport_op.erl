%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% 
%% transport_op
%% 

-module(transport_op).

-export([teleport/3,can_teleport/3,can_directly_telesport/0]).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("map_info_struct.hrl").
-include("common_define.hrl").
-include("instance_define.hrl").
-include("game_map_define.hrl").

-include("error_msg.hrl").

can_teleport(RoleInfo, MapInfo,TransportId)->
	case transport_db:get_transport_channel_info(TransportId) of
		[]->
			false;
		TransInfo ->
			case transport_db:get_channel_type(TransInfo) of
				?CHANEL_TYPE_NORMAL->			%%鏅�氬湴鍥句紶閫�	
					judge_condition(RoleInfo,TransInfo);
				?CHANEL_TYPE_INSTANCE->			%%鍓湰浼犻��
					instance_op:can_role_trans_to_instance(TransInfo);
				_->
					false					
			end		
	end.		

teleport(RoleInfo, MapInfo,TransportId)->	
	case transport_db:get_transport_channel_info(TransportId) of
		[]->
			slogger:msg("teleport TransportId ~p not found",[TransportId]),
			false;
		TransInfo ->
			case transport_db:get_channel_type(TransInfo) of
				?CHANEL_TYPE_NORMAL->			%%鏅�氬湴鍥句紶閫�
					do_normal_transport(RoleInfo, MapInfo,TransInfo);
				?CHANEL_TYPE_INSTANCE->			%%鍓湰浼犻��
					InstanceProtoId = transport_db:get_channel_mapid(TransInfo),
					TransPos = transport_db:get_channel_coord(TransInfo),
					instance_op:instance_trans(MapInfo,InstanceProtoId,TransPos);
				_->
					slogger:msg("teleport TransInfo error ~n")					
			end
	end.					
	                
do_normal_transport(RoleInfo, MapInfo,TransInfo)->
	case judge_condition(RoleInfo,TransInfo) of
		true->	
			%% 娑堣�楁帀锛屼紶閫�
			consume(RoleInfo,TransInfo),
		 	LineId = get_lineid_from_mapinfo(MapInfo),			
			MapId = transport_db:get_channel_mapid(TransInfo),
			Coord = transport_db:get_channel_coord(TransInfo),
			role_op:transport(RoleInfo, MapInfo,LineId, MapId,Coord);
		_ ->
			nothing
	end.

judge_condition(RoleInfo,TransInfo)->
	%%[{s,1},{q,1},{p,1}]
%%	BGuild = isbelongguild(RoleInfo,TransInfo),
	BLevel = isarivelevel(RoleInfo,TransInfo),
	BItems = ishaveitems(RoleInfo,TransInfo),
	BMoney= isenoughmoney(RoleInfo,TransInfo),
	BVip = isvip(RoleInfo,TransInfo),
	if 
		not BLevel->
			Msg = role_packet:encode_map_change_failed_s2c(?ERROR_LESS_LEVEL),
			role_op:send_data_to_gate(Msg),
			false;
		not BItems ->
			Msg = role_packet:encode_map_change_failed_s2c(?ERROR_MISS_ITEM),
			role_op:send_data_to_gate(Msg),
			false;
		not BMoney ->
			Msg = role_packet:encode_map_change_failed_s2c(?ERROR_LESS_MONEY),
			role_op:send_data_to_gate(Msg),
			false;
		not BVip ->
			Msg = role_packet:encode_map_change_failed_s2c(?ERROR_NOT_VIP),
			role_op:send_data_to_gate(Msg),
			false;
		true ->
			true
	end.			

%%isbelongguild(RoleInfo,TransInfo)->
%%	true.

isarivelevel(RoleInfo,TransInfo)->	
	Level = transport_db:get_channel_level(TransInfo),
	RoleLevel = get_level_from_roleinfo(RoleInfo),
	case  RoleLevel >= Level  of
	   false ->
		false;
	   true ->
		true
        end.

ishaveitems(RoleInfo,TransInfo)->	
	case transport_db:get_channel_items(TransInfo) of
		[]->
			ture;
		Items->
			S = fun({Temp_id,Count})->					    
					    Nums = item_util:get_items_count_in_package(Temp_id),					    
					    case Nums>=Count of
						    false->
							    false;
						    true->
							    true
					    end
			    end,				    
			NewItems = lists:filter(S,Items),
			erlang:length(Items)=:=erlang:length(NewItems)
	end.


isenoughmoney(_RoleInfo,TransInfo)->
	Money = transport_db:get_channel_money(TransInfo),
	role_op:check_money(?MONEY_BOUND_SILVER,Money).

isvip(RoleInfo,TransInfo)->
	RoleVip = vip_op:get_role_viplevel(),
	NeedVip = transport_db:get_channel_viplevel(TransInfo),
	RoleVip >= NeedVip.
	
consume(RoleInfo,TransInfo)->
	consumebaserole(RoleInfo,TransInfo),
	consumeitems(TransInfo).

consumebaserole(RoleInfo,TransInfo)->
	%% 閲戦挶
	Money = transport_db:get_channel_money(TransInfo),
	case Money of
		0->
			false;
		_->
			role_op:money_change(?MONEY_BOUND_SILVER,-Money,transport)
        end.				
	
	
consumeitems(TransInfo)->
	Items = transport_db:get_channel_items(TransInfo),
	lists:foreach(fun({Temp_id,Count})-> role_op:consume_items(Temp_id,Count) end,Items).

%%妫�娴嬪綋鍓嶇帺瀹舵槸鍚﹁兘杩涜闈炰紶閫佺偣鐨勭灛绉�,瑙勫垯:
%%1.濡傛灉鐜╁鍦ㄥ壇鏈唴,涓嶅厑璁�
%%2.濡傛灉鐜╁鍦ㄧ洃鐙卞唴,涓嶅厑璁�
%%3.鎴樻枟涓笉鍏佽浼犻��
%%4.鍓湰涓笉鍏佽浼犻��
can_directly_telesport()->
	IsInPrison = pvp_op:is_in_prison(),
	IsInTreasureTransport = role_treasure_transport:is_treasure_transporting(),
	IsBattleing = not role_op:is_leave_attack(),
	InstanceCheck = instance_op:is_in_instance(),
	if
		IsInPrison->
			Msg = role_packet:encode_map_change_failed_s2c(?ERRNO_CAN_NOT_DO_IN_PRISON),
			role_op:send_data_to_gate(Msg),
			false;
		IsInTreasureTransport->
			Msg = role_packet:encode_map_change_failed_s2c(?ERRNO_CAN_NOT_DO_IN_TREASURE_TRANSPORT),
			role_op:send_data_to_gate(Msg),
			false;	
		IsBattleing->	
			Msg = role_packet:encode_map_change_failed_s2c(?ERROR_NOT_LEAVE_ATTACK),
			role_op:send_data_to_gate(Msg),
			false;
		InstanceCheck->	
			Msg = role_packet:encode_map_change_failed_s2c(?ERRNO_ALREADY_IN_INSTANCE),
			role_op:send_data_to_gate(Msg),
			false;
		true->
			true	
	end.

