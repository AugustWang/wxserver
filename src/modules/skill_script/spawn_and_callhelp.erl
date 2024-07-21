%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(spawn_and_callhelp).
-export([on_cast/6,on_check/2]).
-include("data_struct.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("little_garden.hrl").
-include("npc_define.hrl").

on_cast(OriTargetId,ManaChanged,CastResult,SkillID,SkillLevel,CreatureList)->
	MyId = creature_op:get_id_from_creature_info(get(creature_info)),
	lists:foreach(fun(NpcId)->
				creature_op:call_creature_spawn(NpcId,{?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM}),
				case creature_op:get_creature_info(NpcId) of
					undefined->
						nothing;
					Info1->
						Pid1 = get_pid_from_npcinfo(Info1),
						case get(targetid) of
							undefined->
								TargetId=0;
							TargetId->
								nothing
						end,
						gen_fsm:send_event(Pid1,{call_you_help,MyId,TargetId})
				end end, CreatureList),
	[].
	
%%true/false
on_check(SkillInfo,TargetInfo)->
	true.	