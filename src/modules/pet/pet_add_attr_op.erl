%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-8-23
%% Description: TODO: Add description to pet_add_attr
-module(pet_add_attr_op).

%%
%% Include files
%%
-include("error_msg.hrl").
-include("pet_struct.hrl").
-include("common_define.hrl").
-define(GOLD_CONSUME,1).
-define(ITEM_CONSUME,0).
-define(WASH_PET_ATTR_POINT_ETS,wash_pet_attr_point_ets).
-define(ZERO_POINT,0).
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
pet_add_attr(PetId,PowerPoint,HitratePoint,CriticalratePoint,StaminaPoint)->
%% 	io:format("pet_add_attr_op:pet_add_attr:PetId:~p,PowerPoint:~p,HitratePoint:~p,CriticalratePoint:~p,StaminaPoint:~p~n",[PetId,PowerPoint,HitratePoint,CriticalratePoint,StaminaPoint]),
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
%% 			io:format("pet_add_attr_op:pet_add_attr:ERROR_PET_NOEXIST~n"),
			Result = ?ERROR_PET_NOEXIST;
		MyPetInfo->
			GmPetInfo = pet_op:get_gm_petinfo(PetId),
			PetProtoId = get_proto_from_petinfo(GmPetInfo),
		%	RemainAttr = get_remain_attr_from_mypetinfo(MyPetInfo),
			RemainAttr=0,
%% 			io:format("pet_add_attr_op:pet_add_attr:RemainAttr:~p~n",[RemainAttr]),
			SumAddPoint = PowerPoint+HitratePoint+CriticalratePoint+StaminaPoint,
			if 
				SumAddPoint =< ?ZERO_POINT->
					Result = ?ERROR_PET_ADD_ATTR_BEYOND_REMAIN;
				SumAddPoint > RemainAttr->
%% 					io:format("pet_add_attr_op:pet_add_attr:SumAddPoint > RemainAttr~n"),
					Result = ?ERROR_PET_ADD_ATTR_BEYOND_REMAIN,
					gm_logger_role:pet_add_attr_point_log(get(roleid),get(level),PetProtoId,PetId,point_not_enough,?ZERO_POINT,RemainAttr);
				true->				%%OUAPower :OldUserAddPower ;OSPower:OldSumPower
					%{OUAPower,OUAHitrate,OUACriticalrate,OUAStamina} = get_attr_user_add_from_mypetinfo(MyPetInfo),
					%NewAttrUserAdd = {OUAPower+PowerPoint,OUAHitrate+HitratePoint,OUACriticalrate+CriticalratePoint,OUAStamina+StaminaPoint},
					%{OSPower,OSHitrate,OSCriticalrate,OSStamina} = get_attr_from_mypetinfo(MyPetInfo),
					%NewSumAttr = {OSPower+PowerPoint,OSHitrate+HitratePoint,OSCriticalrate+CriticalratePoint,OSStamina+StaminaPoint},
					%Tmp1PetInfo = set_attr_user_add_to_mypetinfo(MyPetInfo,NewAttrUserAdd),
					%Tmp2PetInfo = set_attr_to_mypetinfo(Tmp1PetInfo,NewSumAttr),
					%NewPetInfo = set_remain_attr_to_mypetinfo(Tmp2PetInfo,RemainAttr-SumAddPoint),
					%put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
					%pet_util:recompute_attr(attr,PetId),
%% 					io:format("pet_add_attr_op:pet_add_attr:ERROR_PET_ADD_ATTR_OK~n"),
					Result = ?ERROR_PET_ADD_ATTR_OK,
					gm_logger_role:pet_add_attr_point_log(get(roleid),get(level),PetProtoId,PetId,sucess,SumAddPoint,RemainAttr-SumAddPoint)
			end
	end,
%% 	io:format("pet_add_attr_op:pet_add_attr:ResultMessage:~p~n",[Result]),
	ResultMessage = petup_packet:encode_pet_opt_error_s2c(Result),
	role_op:send_data_to_gate(ResultMessage).


wash_pet_attr_point(Type,PetId)->
%% 	io:format("pet_add_attr_op:wash_pet_attr_point:Type:~p,PetId:~p~n",[Type,PetId]),
	{_,_,ClassId,NeedGold} = pet_quality_db:get_wash_point_info(wash_point),
%% 	io:format("pet_add_attr_op:wash_pet_attr_point:ClassId:~p,Count:~p,NeedGold:~p~n",[ClassId,Count,NeedGold]),
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
%% 			io:format("pet_add_attr_op:wash_pet_attr_point:ERROR_PET_NOEXIST~n"),
			Result = ?ERROR_PET_NOEXIST;
		MyPetInfo->
			GmPetInfo = pet_op:get_gm_petinfo(PetId),
			PetProtoId = get_proto_from_petinfo(GmPetInfo),
			if
				Type =:= ?GOLD_CONSUME->
%% 				io:format("pet_add_attr_op:wash_pet_attr_point:GOLD_CONSUME~n"),
				case role_op:check_money(?MONEY_GOLD, NeedGold) of
					false->
%% 						io:format("pet_add_attr_op:wash_pet_attr_point:ERROR_LESS_GOLD~n"),
						Result = ?ERROR_LESS_GOLD;
					true->
						role_op:money_change(?MONEY_GOLD, -NeedGold, lost_pet_wash_attr_point),
						reset_pet_attr_point(MyPetInfo,PetId),
%% 						io:format("pet_add_attr_op:wash_pet_attr_point:ERROR_PET_WASH_POINT_OK~n"),
						Result = ?ERROR_PET_WASH_POINT_OK
				end;
				true->
					case item_util:is_has_enough_item_in_package_by_class(ClassId,1) of
						false->
							gm_logger_role:pet_wash_attr_point_log(get(roleid),get(level),PetProtoId,PetId,noitem),
%% 							io:format("pet_add_attr_op:wash_pet_attr_point:ERROR_MISS_ITEM~n"),
							Result = ?ERROR_MISS_ITEM;
						true->
							item_util:consume_items_by_classid(ClassId,1),
							reset_pet_attr_point(MyPetInfo,PetId),
%% 							io:format("pet_add_attr_op:wash_pet_attr_point:ERROR_PET_WASH_POINT_OK~n"),
							Result = ?ERROR_PET_WASH_POINT_OK,
							gm_logger_role:pet_wash_attr_point_log(get(roleid),get(level),PetProtoId,PetId,sucess)
					end
			end
	end,
%% 	io:format("pet_add_attr_op:wash_pet_attr_point:Result:~p~n",[Result]),
	ResultMessage = petup_packet:encode_pet_opt_error_s2c(Result),
	role_op:send_data_to_gate(ResultMessage).

reset_pet_attr_point(MyPetInfo,PetId)->
	%RemainAttr = get_remain_attr_from_mypetinfo(MyPetInfo),
	%{OUAPower,OUAHitrate,OUACriticalrate,OUAStamina} = get_attr_user_add_from_mypetinfo(MyPetInfo),
	%{OSPower,OSHitrate,OSCriticalrate,OSStamina} = get_attr_from_mypetinfo(MyPetInfo),
	NewAttrUserAdd = {0,0,0,0},
	%NewSumAttr = {OSPower-OUAPower,OSHitrate-OUAHitrate,OSCriticalrate-OUACriticalrate,OSStamina-OUAStamina},
%	NewRemainAttr = RemainAttr+OUAPower+OUAHitrate+OUACriticalrate+OUAStamina,
	%Tmp1PetInfo = set_attr_user_add_to_mypetinfo(MyPetInfo,NewAttrUserAdd),
	%Tmp2PetInfo = set_attr_to_mypetinfo(Tmp1PetInfo,NewSumAttr),
	%NewPetInfo = set_remain_attr_to_mypetinfo(Tmp2PetInfo,NewRemainAttr),
	%put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
	pet_util:recompute_attr(attr,PetId).
%%
%% Local Functions
%%

