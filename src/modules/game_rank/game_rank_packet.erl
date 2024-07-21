%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(game_rank_packet).

%%
%% Include files
%%
-export([handle/2]).
-compile(export_all).
-include("login_pb.hrl").
-include("data_struct.hrl").


handle(Msg,RolePid)->
	RolePid ! {role_game_rank,Msg}.

encode_rank_get_rank_role_s2c(RoleId,RoleName,Class,Gender,GuildName,Level,Cloth,Arm,VipTag,Items,Be_disdain,Be_praised,Left_judge)->
	login_pb:encode_rank_get_rank_role_s2c(#rank_get_rank_role_s2c{roleid = RoleId,rolename = RoleName,classtype = Class,
										gender = Gender,guildname = GuildName,level = Level,cloth = Cloth,arm = Arm,vip_tag = VipTag,items_attr = Items,
										be_disdain = Be_disdain,be_praised = Be_praised,left_judge = Left_judge}).

encode_rank_judge_opt_result_s2c(Parised_RoleId,DisdainNum,PraisedNum,LeftNum)->
	login_pb:encode_rank_judge_opt_result_s2c(#rank_judge_opt_result_s2c{roleid=Parised_RoleId,disdainnum=DisdainNum,praisednum=PraisedNum,leftnum=LeftNum}).

encode_rank_judge_to_other_s2c(Type,OtherName)->
	login_pb:encode_rank_judge_to_other_s2c(#rank_judge_to_other_s2c{type=Type,othername=OtherName}).
	 
encode_rank_loop_tower_s2c(Param)->
	login_pb:encode_rank_loop_tower_s2c(#rank_loop_tower_s2c{param=Param}).

encode_rank_chess_spirits_single_s2c(Param)->
	login_pb:encode_rank_chess_spirits_single_s2c(#rank_chess_spirits_single_s2c{param=Param}).

encode_rank_chess_spirits_team_s2c(Param)->
	login_pb:encode_rank_chess_spirits_team_s2c(#rank_chess_spirits_team_s2c{param=Param}).

encode_rank_talent_score_s2c(Param)->
	login_pb:encode_rank_talent_score_s2c(#rank_talent_score_s2c{param=Param}).
%%【小五加】
encode_rank_pet_fighting_force_s2c(Param)->
	login_pb:encode_rank_pet_fighting_force_s2c(#rank_talent_score_s2c{param=Param}).
%%【小五加】
encode_rank_quality_value_s2c(Param)->
	login_pb:encode_rank_quality_value_s2c(#rank_talent_score_s2c{param=Param}).
%%【小五加】
encode_rank_growth_s2c(Param)->
	login_pb:encode_rank_growth_s2c(#rank_talent_score_s2c{param=Param}).

encode_rank_killer_s2c(Param)->
	login_pb:encode_rank_killer_s2c(#rank_killer_s2c{param=Param}).

encode_rank_moneys_s2c(Param)->
	login_pb:encode_rank_moneys_s2c(#rank_moneys_s2c{param=Param}).

encode_rank_melee_power_s2c(Param)->
	login_pb:encode_rank_melee_power_s2c(#rank_melee_power_s2c{param=Param}).

encode_rank_range_power_s2c(Param)->
	login_pb:encode_rank_range_power_s2c(#rank_range_power_s2c{param=Param}).

encode_rank_magic_power_s2c(Param)->
	login_pb:encode_rank_magic_power_s2c(#rank_magic_power_s2c{param=Param}).

encode_rank_loop_tower_num_s2c(Param)->
	login_pb:encode_rank_loop_tower_num_s2c(#rank_loop_tower_num_s2c{param=Param}).

encode_rank_level_s2c(Param)->
	login_pb:encode_rank_level_s2c(#rank_level_s2c{param=Param}).

encode_rank_answer_s2c(Param)->
	login_pb:encode_rank_answer_s2c(#rank_answer_s2c{param=Param}).

encode_rank_fighting_force_s2c(Param)->
	login_pb:encode_rank_fighting_force_s2c(#rank_fighting_force_s2c{param=Param}).

encode_rank_mail_line_s2c(Chapter,Festival,Difficulty,Param)->
	login_pb:encode_rank_mail_line_s2c(#rank_mail_line_s2c{chapter=Chapter,festival=Festival,difficulty=Difficulty,param=Param}).

make_param(Id,RoleName,GuildName,ClassType,ServerId,RoleGender,Infos)->
	%加【小五】
	IdKv = pb_util:key_value(2800,Id),
	RoleNameKv = pb_util:key_value(1002,RoleName),
	ClassTypeKv = pb_util:key_value(0,ClassType),
	GuildNameKv = pb_util:key_value(1004,GuildName),
	ServerIdKv = pb_util:key_value(912,ServerId),
	RoleGenderKv = pb_util:key_value(5,RoleGender),
	Kv = [IdKv,RoleNameKv,ClassTypeKv,GuildNameKv,ServerIdKv,RoleGenderKv],
	#rk{kv=Kv,args=Infos}.

make_mparam(Id,RoleName,GuildName,ClassType,ServerId,Infos)->
	#rm{roleid=Id,rolename=RoleName,classtype=ClassType,guildname=GuildName,serverid = ServerId,money=Infos}.  

make_chess_spirits_param(RoleNameList,Infos)->
	#rc{rolename=RoleNameList,args=Infos}.

make_pet_rank_param(PetId,PetName,RoleName,Infos)->
	%#rp{petid=PetId,petname=PetName,rolename=RoleName,args=Infos}.
	%%加【小五】
	PetIdKv = pb_util:key_value(2801,PetId),
	PetNameKv = pb_util:key_value(1005,PetName),
	RoleNameKv = pb_util:key_value(1002,RoleName),
	Kv = [PetIdKv,PetNameKv,RoleNameKv],
	#rk{kv=Kv,args=Infos}.
	


