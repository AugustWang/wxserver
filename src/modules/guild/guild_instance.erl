%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-5
%% Description: TODO: Add description to guild_instance
-module(guild_instance).

%%
%% Include files
%%
-export([stop_instance/1,on_join_instance/1,get_activity_lefttime/1,check_is_timepoint/0,
		 hook_on_line/0,on_activity_start/0,on_activity_end/0,get_activity_lefttime/0,
		 start_instance/3]).


-include("common_define.hrl").
-include("activity_define.hrl").
-include("error_msg.hrl").
-include("instance_define.hrl").
-include("game_map_define.hrl").
-include("map_info_struct.hrl").
-include("little_garden.hrl").
-define(INSTANCE_GUILD_POS,{90,104}).%%wb20130515 {50,50}杩涘叆甯細椹诲湴鍑虹幇鍧愭爣
-define(GUILD_INSTANCE_INFO,guild_instance_info).
-define(JOIN_INSTANCE_CONSUME_CONTRIBUTION,-5).
-define(JOIN_BY_NPC,0).
%%
%% Exported Functions
%%
 
%%
%% API Functions
%%
hook_on_line()->
	IsTimePoint = check_is_timepoint(),
	if
		IsTimePoint->
			LeftTime = get_activity_lefttime(),
			Message = guild_packet:encode_guild_bonfire_start_s2c(LeftTime),
			role_pos_util:send_to_role_clinet(get(roleid), Message);
		true->
			ignor
	end.

on_activity_start()->
	HasGuild = guild_util:is_have_guild(),
	IsInMap = check_is_inmap(),
	if
		HasGuild->
			if
				IsInMap->
					activity_value_op:update({join_activity,?GUILD_INSTANCE_ACTIVITY}),
					add_buff();
				true->
					ignor
			end;
		true->
			ignor
	end.

on_activity_end()->
	IsInMap = check_is_inmap(),
	if
		IsInMap->
			del_buff();
		true->
			ignor
	end.

check_is_inmap()->
	mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) =:= ?MAP_TAG_GUILD_INSTANCE.

add_buff()->
	role_op:add_buffers_by_self([?BONFIRE_BUFFERS]).

del_buff()->
	role_op:remove_buffers([?BONFIRE_BUFFERS]). 

on_join_instance(Type)->
	GuildId = guild_util:get_guild_id(),
	Proc = guild_instance_sup:make_proc_name(guild_instance,{?GUILD_INSTANCEID,GuildId}),
	MapProc = battle_ground_processor:make_map_proc_name(Proc),
	put(guild_instance_info,{MapProc,Proc}),
	case guild_util:is_have_guild() of
		true->
			case guild_instance_processor:is_instance_start(MapProc) of
				false->
					case start_instance(GuildId,MapProc,Proc) of
						ok->
							join_guildinstance(GuildId,Proc,MapProc,Type);
						_->
							error
					end;
				_->
					join_guildinstance(GuildId,Proc,MapProc,Type)
			end;
		_->
			nothing
	end.

start_instance(GuildId,MapProc,Proc)->
	case guild_instance_processor:start_instance(GuildId,?GUILD_INSTANCEID,MapProc,Proc) of
		{ok,Node}->
			case guild_spawn_db:get_guild_monsterinfo(GuildId) of
				[]->
					ignor;
				{_,_,_,_,_,_,ActivMonster} ->
					call_guild_monster(GuildId,Node,Proc,ActivMonster)
			end,
			ok;
		_->
			Message = role_packet:encode_map_change_failed_s2c(?ERRNO_INSTANCE_RESETING),
			role_op:send_data_to_gate(Message),
			error
	end.

call_guild_monster(_,_,_,[])->
	ignor;

call_guild_monster(GuildId,Node,Proc,MonsterId)->
	MonsterInfo = guild_proto_db:get_guild_monsterinfo(MonsterId),
	BornPos = guild_proto_db:get_guild_monster_bornpos(MonsterInfo),
	{Proc,Node} ! {call_guild_monster,MonsterId,BornPos,GuildId}.

join_guildinstance(GuildId,Proc,MapProc,Type)->
	case transport_op:can_directly_telesport() of
		true->
			case instance_pos_db:get_instance_pos_from_mnesia(atom_to_list(MapProc)) of			
				[]->
					case start_instance(GuildId,MapProc,Proc) of
						ok->
							join_guildinstance(GuildId,Proc,MapProc,Type);
						_->
							error
					end;
				{_Id,_Creation,_StartTime,CanJoin,InstanceNode ,_Pid,MapId,ProtoId,_Members}->
					ProtoInfo = instance_proto_db:get_info(ProtoId),
					if
						CanJoin->
							case Type of
								?JOIN_BY_NPC->
									do_transport(MapProc,ProtoInfo,InstanceNode,MapId);
								_->
									case guild_manager:add_contribute(guild_util:get_guild_id(),get(roleid),?JOIN_INSTANCE_CONSUME_CONTRIBUTION) of
										ok->
											do_transport(MapProc,ProtoInfo,InstanceNode,MapId);
										_->
											ignor
									end
							end;
						true->
							todo_send
					end
			end;
		_->
			nothing
	end.

do_transport(MapProc,ProtoInfo,InstanceNode,MapId)->
	Pos = ?INSTANCE_GUILD_POS,
	instance_op:trans_to_dungeon(false,MapProc,get(map_info),Pos ,
										?INSTANCE_TYPE_GUILD,ProtoInfo,InstanceNode,MapId).

stop_instance(GuildId)->
	guild_instance_processor:stop_instance(GuildId).

make_procedict_name({GuildLId,GuildHId})->
	lists:append(["guild_instance",integer_to_list(GuildLId),integer_to_list(GuildHId)]).

check_is_timepoint()->
	InfoList = answer_db:get_activity_info(?GUILD_INSTANCE_ACTIVITY),
	NowTime = calendar:now_to_local_time(now()),
	lists:foldl(fun(Info,Acc)->
						{_,StartLines} = answer_db:get_activity_start(Info),
						if
							Acc->
								Acc;
							true->
								timer_util:check_dateline(NowTime,StartLines)
						end
					end,false,InfoList).

get_activity_lefttime()->
	[ActivityInfo] = answer_db:get_activity_info(?GUILD_INSTANCE_ACTIVITY),
	{_,[StartLines]} = answer_db:get_activity_start(ActivityInfo),
	get_activity_lefttime(StartLines).

get_activity_lefttime(StartLines)->
	{_,{_,{EH,EM,ES}}} = StartLines,
	{{NY,NMon,ND},{NH,NM,NS}} = calendar:now_to_local_time(timer_center:get_correct_now()),
	EndSecs = calendar:datetime_to_gregorian_seconds({{NY,NMon,ND},{EH,EM,ES}}),
	NowSecs = calendar:datetime_to_gregorian_seconds({{NY,NMon,ND},{NH,NM,NS}}),
	LiftTime = EndSecs - NowSecs,
	if
		LiftTime > 0 ->
			LiftTime;
		true->
			0
	end.