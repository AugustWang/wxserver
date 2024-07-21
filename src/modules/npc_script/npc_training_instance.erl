%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-2-1
%% Description: TODO: Add description to npc_training_instance
-module(npc_training_instance).

%%
%% Exported Functions
%%
-export([proc_special_msg/1,init/0,is_start_section/1]).
-include("data_struct.hrl").
-include("login_pb.hrl").
-include("system_chat_define.hrl").
-include("ai_define.hrl").
-include("map_info_struct.hrl").
-define(CHECK_TIME_DURATION,1000).
%%
%% API Functions
%%
init()->
	put(training_instance_cur_section,0),
	send_check().

proc_special_msg(npc_training_instance_check)->
	do_show_monster().

is_start_section(Section)->
	 (get(training_instance_cur_section)=:=Section).

%%local
send_check()->
	erlang:send_after(?CHECK_TIME_DURATION,self(),npc_training_instance_check).

do_show_monster()->
	case mapop:get_map_roles_id() of
		[]-> %%no role come in
			nothing;
		_->
			NowSection = get(training_instance_cur_section),
			AllMonsters = mapop:get_map_units_id() -- [get(id)],
			KillMonsters = mapop:get_map_dead_units(AllMonsters),
			
			case AllMonsters =:= KillMonsters of
				true->
					%%force leave map
					lists:foreach(fun(DeadNpcId)->
									npc_op:send_to_creature(DeadNpcId,{forced_leave_map})	  
								end, KillMonsters),
					broadcast_section(NowSection),
					if
						AllMonsters =:= []->
							NewSection = NowSection + 1,
							put(training_instance_cur_section,NewSection),
							npc_ai:handle_event(?EVENT_SECTION_UNITS_SPAWN);
						true->
							nothing
					end;
				_->
					nothing
			end
	end,
	send_check().

broadcast_section(0)->
	nothing;
broadcast_section(Section)->
	MapId = get_mapid_from_mapinfo(get(map_info)),
	Msg = role_packet:encode_monster_section_update_s2c(MapId,Section),
	lists:foreach(fun(RoleId)->
						  npc_op:send_to_other_client(RoleId, Msg)
				  end, mapop:get_map_roles_id()).
