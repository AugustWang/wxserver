%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : skill_op.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 28 May 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(skill_op).

-compile(export_all).

-include("common_define.hrl").
-include("skill_define.hrl").
-include("mnesia_table_def.hrl").
-include("little_garden.hrl").
-include("map_info_struct.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%s
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_skill_info(RoleId) ->
	RoleSkillInfo = skill_db:get_role_skill_info(RoleId),
	put(skill_info,RoleSkillInfo).

send_skill_info()->
	SkillList = element(#role_skill.skillinfo,get(skill_info)),
	SendSkillInfo = lists:map(fun({SkillID,SkillLevel,LastCastTime})->
						pb_util:to_skill_info(SkillID,SkillLevel,LastCastTime)
					end,SkillList), 					
	Msg = role_packet:encode_learned_skill_s2c(get(roleid),SendSkillInfo),
	role_op:send_data_to_gate(Msg).

save_to_db()->
	skill_db:save_role_skill_info(get(skill_info)).
	
async_save_to_db()->
	skill_db:async_save_role_skill_info(get(skill_info)).

learn_skill(SkillId,SkillLevel) ->
	case is_studied(SkillId) of 
		false ->			
			put(skill_info,skill_db:add_new_skill(get(skill_info),SkillId));
		_ ->			
			put(skill_info,skill_db:change_role_skill_level(get(skill_info),SkillId,SkillLevel))
	end,
	{_,_,SkillList} = get(skill_info),
	quest_op:update({learn_skill,SkillId},SkillLevel),
%% 	achieve_op:achieve_update({learn_skill},[0],length(SkillList)),
    goals_op:goals_update({learn_skill},[0],length(SkillList)-1),%%@@wb20130311
	gm_logger_role:role_skill_learn(get(roleid),SkillId,SkillLevel,get(level)).
	
export_for_copy()->	
	{get(skill_info)}.

load_by_copy({Skill_info})->
	put(skill_info,Skill_info).

is_studied(SkillID)->
	skill_db:is_skill_studied(get(skill_info),SkillID).	

get_skill_level(SkillID)->
	skill_db:get_skill_level(get(skill_info),SkillID).

get_skill_learn_level(SkillId,SkillLevel)->
	SkillInfo = skill_db:get_skill_info(SkillId,SkillLevel),						
	skill_db:get_learn_level(SkillInfo).

get_skill_learn_class(SkillId,SkillLevel)->
	SkillInfo = skill_db:get_skill_info(SkillId,SkillLevel),							
	skill_db:get_class(SkillInfo).

set_casttime(SkillID)->
	put(skill_info,skill_db:set_skill_casttime(get(skill_info),SkillID)).
	
is_cooldown_ok(SkillID,SkillLevel) ->					
	LastCastTime = skill_db:get_skill_casttime(get(skill_info),SkillID),
	SkillInfo =  skill_db:get_skill_info(SkillID,SkillLevel),
	timer:now_diff(timer_center:get_correct_now(),LastCastTime) >= skill_db:get_cooldown(SkillInfo)*1000.	

get_attack_module(Skill) ->
	case Skill of
		1 ->
			normal_point_attack;
		2 ->
			normal_scope_attack;
		3 ->
			complex_scope_attack;
		_ ->
			undefined
	end.

enum_skill_item(RoleInfo, NpcID) ->
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	npc_function_frame:do_enum(Mapid,RoleInfo,NpcID,skill_learn).

skill_learn_item_c2s(Skillid) ->
	npc_skill_study:do_learn_without_npc(Skillid).

skill_learn_item_c2s_auto(SkillidList) ->
	lists:map(fun({_,_,SkillId})->
					  	npc_skill_study:do_learn_skill_auto(SkillId) end, SkillidList).


	

get_skill_add_attr()->
	SkillList = element(#role_skill.skillinfo,get(skill_info)),
	lists:foldl(fun({SkillId,Level,_},AddAttrTmp)->
			SkillInfo = skill_db:get_skill_info(SkillId, Level),
			case skill_db:get_type(SkillInfo) of
				?SKILL_TYPE_PASSIVE_ATTREXT->
					AddBuffs = skill_db:get_caster_buff(SkillInfo),
					lists:foldl(fun({{BufferId,BuffLevel},_Rate},AttrTmp)-> 
									AttrTmp ++ buffer_op:get_buffer_attr_effect(BufferId,BuffLevel)
								end, [], AddBuffs)++AddAttrTmp;
				_->
					AddAttrTmp
			end end, [], SkillList).
	
