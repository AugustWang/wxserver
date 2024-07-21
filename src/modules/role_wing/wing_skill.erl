%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-4-24
%% Description: TODO: Add description to wing_skill
-module(wing_skill).
-compile(export_all).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).
-include("role_wing.hrl").
-include("common_define.hrl").
%%
%% API Functions
%%



%%
%% Local Functions
%%

check_skill_can_activity(Strength)->
	case wing_db:get_wing_intensify_info(Strength) of
		[]->
			[];
		IntensifyInfo->
			case wing_db:get_unlockskill_from_intenfifyinfo(IntensifyInfo) of
				[]->
					[];
				[Skill]->
					skill_op:learn_skill(Skill, 1),
					{Skill,1}
			end
	end.

update_wing_skill(SkillInfo,{SkillId,Level})->
	case lists:keyfind(SkillId, 1,SkillInfo) of
		false->
			Message=wing_packet:encode_wing_skill_open_s2c(SkillId),
			role_op:send_data_to_gate(Message),
			SkillInfo++[{SkillId,Level}];
		_->
			lists:keyreplace(SkillId, 1, SkillInfo, {SkillId,Level})
	end.

check_skill_can_activity_for_quality(SkillsInfo,QualityInfo)->
	case wing_db:get_skill_from_qualityinfo(QualityInfo) of
		[]->
			SkillsInfo;
		SkillsId->
			lists:foldl(fun(SkillId,Acc)->
								case lists:keyfind(SkillId, 2, Acc) of
									false->
										skill_op:learn_skill(SkillId, 1),
											Message=wing_packet:encode_wing_skill_open_s2c(SkillId),
											role_op:send_data_to_gate(Message),
										Acc++[{SkillId,1}];
									_->
										Acc
								end
									end	, SkillsInfo, SkillsId)
	end.

