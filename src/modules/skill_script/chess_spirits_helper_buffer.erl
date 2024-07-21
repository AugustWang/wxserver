%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(chess_spirits_helper_buffer).
-export([on_cast/8,on_check/2]).
-include("data_struct.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("little_garden.hrl").
-include("npc_define.hrl").

%%call by npc_chess_spirit
on_cast(OriTargetId,ManaChanged,CastResult,_,_,NpcId,BuffId,BuffLevel)->
	case creature_op:get_creature_info(NpcId) of
		undefined->
			creature_op:call_creature_spawn(NpcId,{?CREATOR_LEVEL_BY_SYSTEM,get(id)}),
			%%make sure Npc join in map
			erlang:send_after(1000, self(), {chess_spirit_call_one_skill,{NpcId,BuffId,BuffLevel}});
		CreatureInfo->
			Pid1 = get_pid_from_npcinfo(CreatureInfo),
			gs_rpc:cast(Pid1, {chess_helper_give_buff,{BuffId,BuffLevel}})
	end,		
	[].

%%true/false
on_check(SkillInfo,OtherInfo)->
	true.