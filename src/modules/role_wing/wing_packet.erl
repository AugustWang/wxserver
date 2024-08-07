%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-4-17
%% Description: TODO: Add description to wing_packet
-module(wing_packet).
-compile(export_all).
-include("login_pb.hrl").
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).
-include("role_wing.hrl").
%%
%% API Functions
%%



%%
%% Local Functions
%%

handle(Message,RolePid)->
	RolePid ! {role_wing_message,Message}.

%%寮�鍚鍓戝姛鑳�
encode_wing_open_s2c()->
	login_pb:encode_wing_open_s2c(#wing_open_s2c{}).

%%鍙戦�侀鍓戜俊鎭�
encode_update_role_wing_info_s2c(RoleId,Level,Strenthinfo,Skill,Lucky,Echants,Phase,Quality)->
	login_pb:encode_update_role_wing_info_s2c(#update_role_wing_info_s2c{state=1,roleid=RoleId,level=Level,wing_intensify=Strenthinfo,skills=Skill,failed_num=Lucky,enchants=Echants,phase=Phase,quality=Quality}).
%%鍙戦�佸鎴风椋炲墤鐨勫睘鎬�
encode_update_wing_base_info_s2c(Attr)->
	login_pb:encode_update_wing_base_info_s2c(#update_wing_base_info_s2c{base_attr=Attr}).

%%椋炲墤杩斿洖缁撴灉
encode_encode_wing_opt_result_s2c(Result)->
	login_pb:encode_wing_opt_result_s2c(#wing_opt_result_s2c{result=Result}).
%%寮�鍚妧鑳�
encode_wing_skill_open_s2c(SkillId)->
	login_pb:encode_wing_skill_open_s2c(#wing_skill_open_s2c{skillid=SkillId}).

%%椋炲墤娲楃粌缁撴灉
encode_wing_enchant_s2c(EchantInfo)->
	login_pb:encode_wing_enchant_s2c(#wing_enchant_s2c{enchants=EchantInfo}).

make_instensify(Info)->
	Streng=get_strength_from_wing_info(Info),
	Strengadd=get_strength_add_from_wing_info(Info),
	Value=get_perfect_value_from_wing_info(Info),
	#wing_intensify{level=Streng,add_percent=Strengadd,perfect_value=Value}.


make_wing_skill(SkillId,Level)->
	#slv{level=Level,skillid=SkillId}.

make_echant_info(Quality,Info)->
	#enchant{attr=Info,quality=Quality}.