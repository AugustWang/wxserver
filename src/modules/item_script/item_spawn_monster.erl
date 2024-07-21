%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(item_spawn_monster).
-export([use_item/1]).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("error_msg.hrl").
-include("guild_define.hrl").
-include("role_struct.hrl").
-include("npc_define.hrl").

-define(SELF_SPAWN,1).
-define(GROUP_SPAWN,2).
-define(GUILD_SPAWN,3).
-define(RANGE,5).
%%
%% API Functions
%%
use_item(ItemInfo)->
	States = get_states_from_iteminfo(ItemInfo),
	case check_can_use(States) of
		true->		
			MyMapId = creature_op:get_mapid_from_mapinfo(get(map_info)),
			MyPos = creature_op:get_pos_from_creature_info(get(creature_info)),
			MapCheck = 
			case lists:keyfind(map, 1, States) of
				{map,MapId}->
					MapId =:= MyMapId;
				_->
					true
			end,
			PosCheck = 
			case lists:keyfind(pos, 1, States) of
				{pos,Pos}->
					util:is_in_range(MyPos,Pos,?RANGE);
				_->
					true
			end,
			if
				PosCheck and MapCheck-> 
					{proto,ProtoId} = lists:keyfind(proto, 1, States),
					Mylevel = get_level_from_roleinfo(get(creature_info)),
					case creature_op:call_creature_spawn_by_create(ProtoId,MyPos,{Mylevel,?CREATOR_BY_SYSTEM}) of
						error->
							false;
						_->
							true
					end;
				true->
					Msg = role_packet:encode_use_item_error_s2c(?ERROR_USED_IN_MAPPOS),
					role_op:send_data_to_gate(Msg),
					false
			end;
		_->
			false
	end.

check_can_use(States)->
	case lists:keyfind(type, 1, States) of
		{type,?GUILD_SPAWN}->
			Pose = guild_util:get_guild_posting(),
			(Pose=:= ?GUILD_POSE_LEADER) or (Pose =:= ?GUILD_POSE_MASTER) or (Pose=:= ?GUILD_POSE_VICE_LEADER);
		_->
			true
	end.