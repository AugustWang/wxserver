%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(clear_self_buff_by_type).
-export([on_cast/6,on_check/2]).
-include("data_struct.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("little_garden.hrl").

on_cast(OriTargetId,ManaChanged,CastResult,SkillID,SkillLevel,DbuffTypeList)->
	RemoveBuffList = lists:filter(fun({BufferId,BuffLevel})->
			BufferInfo = buffer_db:get_buffer_info(BufferId, BuffLevel),
			Type = buffer_db:get_buffer_resist_type(BufferInfo),
	  		lists:member(Type, DbuffTypeList)
	  	end, get(current_buffer)),
	creature_op:remove_buffers(RemoveBuffList,get(creature_info)),
	[].

%%true/false
on_check(SkillInfo,OtherInfo)->
	true.