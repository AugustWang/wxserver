%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pet_level_op).

-compile(export_all).

-include("data_struct.hrl").
-include("common_define.hrl").
-include("mnesia_table_def.hrl").
-include("role_struct.hrl").
-include("pet_struct.hrl").

obt_exp(GmPetInfo,AddExp)->
	RoleLeve = get_level_from_roleinfo(get(creature_info)),
	%ToatlExp = get_totalexp_from_petinfo(GmPetInfo),
	ToatlExp=0,
	{NewLevel,NewExp} =  pet_level_db:get_level_and_exp(ToatlExp+AddExp),
	PetId = get_id_from_petinfo(GmPetInfo),
	if
		NewLevel > RoleLeve->
			false;
		true->
			OldLevel = get_level_from_petinfo(GmPetInfo),
			if
				OldLevel=/= NewLevel->
					%NewGmPetInfo = GmPetInfo#gm_pet_info{totalexp=ToatlExp+AddExp,exp = NewExp,level = NewLevel},
					%pet_op:update_gm_pet_info_all(NewGmPetInfo),
					pet_util:recompute_attr(levelup,PetId),
					gm_logger_role:pet_level_up(get(roleid),PetId,get_proto_from_petinfo(GmPetInfo),RoleLeve,NewLevel);
				true->
					pet_attr:only_self_update(PetId,[{expr,NewExp}])
				%	NewGmPetInfo = GmPetInfo#gm_pet_info{totalexp=ToatlExp+AddExp,exp = NewExp},
					%pet_op:update_gm_pet_info_all(NewGmPetInfo)
			end,
%% 			achieve_op:achieve_update({pet_level},[0],NewLevel),
			true
	end.

pet_level_up(Petid)->
	GameInfo=pet_op:get_gm_petinfo(Petid) ,
	if  GameInfo =:=[]->
			pet_op:send_levelup_message();
  true->
	NowTime=60,
	LevelTime=get_leveluptime_s_value_from_pet_info(GameInfo),
	TotalTime=NowTime+LevelTime,
	{NewLevel,PetTime}=pet_level_db:get_level_and_time(TotalTime),
	if NewLevel =:=100->
		   nothing;
	   true->
	NewTime=pet_level_db:get_time_of_level(NewLevel),
	Time=calendar:now_to_local_time(now()),
	PetId = get_id_from_petinfo(GameInfo),
	OldLevel=get_level_from_petinfo(GameInfo),
	RoleLevel=get_level_from_roleinfo(get(creature_info)),
	if NewLevel-RoleLevel>=5->
	   nothing;
   true->
			if NewLevel>OldLevel->
		   		NewGmPetInfo=GameInfo#gm_pet_info{level=NewLevel,leveluptime_s=PetTime},
		   		pet_op:update_gm_pet_info_all(NewGmPetInfo),
				%pet_attr:only_self_update(PetId, [{leveluptime_s,TotalTime}]),
				pet_util:recompute_attr(levelup,PetId),
				gm_logger_role:pet_level_up(get(roleid),PetId,get_proto_from_petinfo(GameInfo),RoleLevel,NewLevel),
%% 		  		achieve_op:achieve_update({pet_level},[0],NewLevel),
				pet_op:send_levelup_message();
				true->
				PetLevelTime=TotalTime,
				%pet_attr:only_self_update(PetId, [{leveluptime_s,PetLevelTime}]),
				NewGmPetInfo=GameInfo#gm_pet_info{leveluptime_s=PetLevelTime},
				pet_op:update_gm_pet_info_all(NewGmPetInfo),
				pet_op:send_levelup_message()
			end
	end
	end
	end,
	pet_op:check_pet_hanpyness(Petid).
			
pet_levelup_add_speed(Level,PetId)->
	case pet_op:get_gm_petinfo(PetId) of
		[]->
			false;
		GameInfo->
					Leveltime=pet_level_db:get_time_of_level(Level-1),
					Newleveltime=pet_level_db:get_time_of_level(Level),
					 pet_attr:only_self_update(PetId,[{remain_time,Newleveltime-Leveltime}]),
					NewGamePetInfo=GameInfo#gm_pet_info{level=Level,leveluptime_s=Leveltime},
					pet_attr:only_self_update(PetId, [{leveluptime_s,Leveltime}]),
					pet_op:update_gm_pet_info_all(NewGamePetInfo),
					pet_util:recompute_attr(levelup, PetId),
					RoleLevel=get_level_from_roleinfo(get(creature_info)),
					gm_logger_role:pet_level_up(get(roleid),PetId,get_proto_from_petinfo(GameInfo),RoleLevel,Level),
%% 				  	achieve_op:achieve_update({pet_level},[0],Level),
					true
end.
	
	
get_pet_max_level()->
	case get(gm_pets_info) of
		[]->
			0;
		GmPetInfoList->
			lists:foldl(fun(GmPetInfo,Acc)->
								PetLevel = get_level_from_petinfo(GmPetInfo),
								if 
									PetLevel >= Acc ->
										PetLevel;
									true->
										Acc
								end
						end,0,GmPetInfoList)
	end.
				   