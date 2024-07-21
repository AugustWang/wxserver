%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-3-5
%% Description: TODO: Add description to pet_inherit
-module(pet_inherit_op).

-export([inherit_c2s/2]).
-include("pet_struct.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
-include("common_define.hrl").
-include("login_pb.hrl").
-include("system_chat_define.hrl").
-include("string_define.hrl").
%%
%% Include files
%%

%%
%% Exported Functions
%%


%%
%% API Functions
%%



%%
%% Local Functions
%%
inherit_c2s(MainPid,Pid)->
	MPetInfo= pet_op:get_pet_info(MainPid),
	PetInfo= pet_op:get_pet_info(Pid) ,
	MGamePetInfo=pet_op:get_gm_petinfo(MainPid),
	GamePetInfo=pet_op:get_gm_petinfo(Pid),
	if (MPetInfo=:=[]) or (PetInfo=:=[]) or (MGamePetInfo=:=[]) or (GamePetInfo=:=[])->
		  Error=?ERROR_PET_NOEXIST,
		  Message=pet_packet:encode_pet_opt_error_s2c(Error),
		  role_op:send_data_to_gate(Message);
	   true->
		   MState=get_state_from_petinfo(MGamePetInfo),
		   State=get_state_from_petinfo(GamePetInfo),
		   if (MState=:=?PET_STATE_BATTLE) or (State=:=?PET_STATE_BATTLE)->
				 Error=?ERROR_PET_IS_EXPLORING,
				 Message=pet_packet:encode_pet_opt_error_s2c(Error),
		 		 role_op:send_data_to_gate(Message);
			  true->
				 MPetLevel=get_level_from_petinfo(MGamePetInfo),
				 PetLevel=get_level_from_petinfo(GamePetInfo),
				 MPetSocial=get_social_from_petinfo(MGamePetInfo),
				 PetSocial=get_social_from_petinfo(GamePetInfo),
				MPetQuality=get_quality_value_from_mypetinfo(MPetInfo),
				PetQuality=get_quality_value_from_mypetinfo(PetInfo),
				MPetQualityUp=get_quality_up_value_from_mypetinfo(MPetInfo),
				PetQualityUp=get_quality_up_value_from_mypetinfo(PetInfo),
				MPetGrowth=get_growth_value_from_pet_info(MGamePetInfo),
				PetGrowth=get_growth_value_from_pet_info(GamePetInfo),
				MPetXisui=get_xisui_from_mypetinfo(MPetInfo),
				PetXisui=get_xisui_from_mypetinfo(PetInfo),
				MPetSkill=get_skill_from_mypetinfo(MPetInfo),
				PetSkill=get_skill_from_mypetinfo(PetInfo),
				MPetTalent=get_talent_from_mypetinfo(MPetInfo),
				PetTalent=get_talent_from_mypetinfo(PetInfo),
				 MProto=get_proto_from_petinfo(MGamePetInfo),
				%%ç»§æ‰¿åŽçš„å±žæ€§
				Level=get_new_level(MPetLevel,PetLevel),
				Social=get_new_social(MPetSocial,PetSocial),
				Quality=get_new_quality(MPetQuality,PetQuality),
				QualityUp=get_new_queality_up(MPetQualityUp,PetQualityUp),
				Growth=get_new_growth(MPetGrowth,PetGrowth),
				Xisui=get_new_xisui(MPetXisui,PetXisui),
				Talent=get_new_talent(MPetTalent,PetTalent),
				Proto=get_new_proto(Social,MProto),
				NewPetInfo=MPetInfo#my_pet_info{xs=Xisui,
																	talent=Talent,
																	skill=PetSkill,
																	quality_value=Quality,
																	quality_up_value=QualityUp
																	},
				Message1=pet_packet:encode_pet_xs_update_s2c(Xisui, MainPid),%%æ´—é«“ä¿¡æ¯æ¶ˆæ¯é€šçŸ¥(å› ä¸ºæ²¡æœ‰çš„objectupdateè‡ªåŠ¨æ›´æ–°)
				role_op:send_data_to_gate(Message1),
				NewGamePetInfo=MGamePetInfo#gm_pet_info{proto=Proto,level=Level,social=Social,growth_value=Growth},
				pet_op:update_pet_info_all(NewPetInfo),
				pet_op:update_gm_pet_info_all(NewGamePetInfo),
				 Message=pet_packet:encode_pet_inheritance_s2c(),
				 role_op:send_data_to_gate(Message),
				 pet_op:delete_pet(Pid,true),
				pet_util:recompute_attr(inherit, MainPid),
				gm_logger_role:pet_inherit(get(roleid),MainPid,get_proto_from_petinfo(NewGamePetInfo),NewPetInfo,Pid)
		   end
	end.
		   
get_new_level(MPetLevel,PetLevel)->
	Level=erlang:max(MPetLevel, PetLevel),
	Level.
get_new_social(MPetSocial,PetSocial)->
	Social=erlang:max(MPetSocial, PetSocial),
	Social.
get_new_quality(MPetQuality,PetQuality)->
	Quality=erlang:max(MPetQuality, PetQuality),
	Quality.
get_new_queality_up(MPetQualityUp,PetQualirtyUp)->
	QualityUp=erlang:max(MPetQualityUp, PetQualirtyUp),
	QualityUp.
get_new_growth(MPetGrowth,PetGrowth)->
	Growth=erlang:max(MPetGrowth, PetGrowth),
	Growth.
get_new_xisui(MPetXisui,PetXisui)->
	MPetXsHp=pet_packet:get_hp_xs(MPetXisui),
	MPetXsMeleepower=pet_packet:get_meleepower_xs(MPetXisui),
	MPetXsRangepower=pet_packet:get_rangpower_xs(MPetXisui),
	MPetXsMagicpower=pet_packet:get_magicpower_xs(MPetXisui),
	MPetXsMeleedefence=pet_packet:get_meleedefence_xs(MPetXisui),
	MPetXsRangedefence=pet_packet:get_rangedefence_xs(MPetXisui),
   MPetXsMagicdefence=pet_packet:get_magicdefence_xs(MPetXisui),

	PetXsHp=pet_packet:get_hp_xs(PetXisui),
	PetXsMeleepower=pet_packet:get_meleepower_xs(PetXisui),
	PetXsRangepower=pet_packet:get_rangpower_xs(PetXisui),
	PetXsMagicpower=pet_packet:get_magicpower_xs(PetXisui),
	PetXsMeleedefence=pet_packet:get_meleedefence_xs(PetXisui),
	PetXsRangedefence=pet_packet:get_rangedefence_xs(PetXisui),
    PetXsMagicdefence=pet_packet:get_magicdefence_xs(PetXisui),
	
	XsHp=erlang:max(MPetXsHp, PetXsHp),
	XsMeleepower=erlang:max(MPetXsMeleepower, PetXsMeleepower),
	XsRangepower=erlang:max(MPetXsRangepower, PetXsRangepower),
	XsMagicpower=erlang:max(MPetXsMagicpower, PetXsMagicpower),
	XsMeleedefence=erlang:max(MPetXsMeleedefence, PetXsMeleedefence),
	XsRangedefence=erlang:max(MPetXsRangedefence, PetXsRangedefence),
	XsMagicdefence=erlang:max(MPetXsMagicdefence, PetXsMagicdefence),
	Xisui=MPetXisui#pxs{
				xshpmax=XsHp,
				xsmeleepower=XsMeleepower,
				xsmeleedefence=XsMeleedefence,
				xsrangepower=XsRangepower,
			   xsrangedefence=XsRangedefence,
				xsmagicpower=XsMagicpower,
				xsmagicdefence=XsMagicdefence
			   },
	Xisui.

get_new_talent(MPetTalent,PetTalent)->
	NewTalent=lists:map(fun({TLevel,TId,TType})->
			lists:foldl(fun({Level,Id,Type},{Acc1,Acc2,Acc3})->
						if TType=:=Type->
								NLevel=erlang:max(TLevel, Level),
								{NLevel,TId,TType};
						true->
							{Acc1,Acc2,Acc3}
						end
				end, {0,0,0}, PetTalent)    end, MPetTalent),
		NewTalent.

get_new_proto(Step,Proto)->
		if Step>1->
				Proto+1000*Step;
		 true->
				Proto
		end.

