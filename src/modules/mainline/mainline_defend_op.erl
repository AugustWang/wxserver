%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-10-12
%% Description: TODO: Add description to mainline_defend_op
-module(mainline_defend_op).

-compile(export_all).
%%
%% Include files
%%
-include("mainline_define.hrl").
-include("ai_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_define.hrl").

-define(PREPARE_TIME,1).


%%
%% API Functions
%%

init(Chapter,Stage,Class,Difficulty,Duration,MaxSection,MonsterTargetPos)->
	put(mainline_defend_timer,[]),
	put(mainline_defend_cur_section,0),
	put(mainline_defend_duation,Duration),
	put(mainline_defend_config,{Chapter,Stage,Class,Difficulty,MaxSection,MonsterTargetPos}),
	TimeRef = erlang:send_after(?PREPARE_TIME*1000,self(),{mainline_internal_msg,{mainline_defend_next}}),
	put(mainline_defend_timer,TimeRef).

uninit()->
	case get(mainline_defend_timer) of
		undefined->
			nothing;
		[]->
			nothing;
		TimeRef->
			erlang:cancel_timer(TimeRef)
	end,
	put(mainline_defend_timer,[]),
	put(mainline_defend_cur_section,[]),
	put(mainline_defend_duation,[]),
	put(mainline_defend_config,[]).


force_update()->
	case get(mainline_defend_timer) of
		undefined->
			nothing;
		[]->
			nothing;
		TimeRef->
			erlang:cancel_timer(TimeRef),
			update()
	end.

update()->
	case get(mainline_defend_config) of
		undefined->
			nothing;
		[]->
			nothing;
		{Chapter,Stage,Class,Difficulty,MaxSection,MonsterTargetPos}->
			Duration = get(mainline_defend_duation),
			CurSection = get(mainline_defend_cur_section),
			NewSection = CurSection + 1,
			case mainline_defend_config_db:get_info(Chapter,Stage,Difficulty,Class,NewSection) of
				[]->
					io:format("mainline_defend_config_db get_info [~p] ~n",[{Chapter,Stage,Difficulty,Class,NewSection}]),
					nothing;
				ConfigInfo->
					Spwans = mainline_defend_config_db:get_spawns(ConfigInfo),
					Mylevel = get_level_from_roleinfo(get(creature_info)),
					MonsterIds = 
						lists:foldl(fun({CreatureProto,Pos},AllIds)->
									WayPoints = npc_ai:path_find(Pos,MonsterTargetPos),
									case creature_op:call_creature_spawn_by_create(CreatureProto,Pos,?MOVE_TYPE_PATH,[Pos|WayPoints],{Mylevel,?CREATOR_BY_SYSTEM}) of
										error->
											slogger:msg("mainline spawns_monster_for_section error CreatureProto ~p ~n",[CreatureProto]),
											AllIds;
										NpcId->											
											[NpcId|AllIds]
									end
								end, [],Spwans),
					role_mainline:update({add_monster,MonsterIds}),
					gm_logger_role:mainline_defend_monster(get(roleid),
														get_level_from_roleinfo(get(creature_info)),
														Chapter,Stage,Difficulty,NewSection,length(MonsterIds))
					%%role_mainline:update({section,NewSection})
			end,
			put(mainline_defend_cur_section,NewSection),
			send_update_message(),
			if
				NewSection < MaxSection ->
					TimeRef = erlang:send_after(Duration*1000,self(),{mainline_internal_msg,{mainline_defend_next}}),
					put(mainline_defend_timer,TimeRef);
				true->
					put(mainline_defend_timer,[])
			end;
		_->
			nothing
	end.
	

%%
%%return true|false
%%
check_section_over()->
	case get(mainline_defend_config) of
		undefined->
			true;
		[]->
			true;
		{_Chapter,_Stage,_Class,_Difficulty,MaxSection,_MonsterTargetPos}->
			CurSection = get(mainline_defend_cur_section),
			CurSection >= MaxSection
	end.
%%
%% Local Functions
%%

send_update_message()->
	CurSection = get(mainline_defend_cur_section),
	Duration = get(mainline_defend_duation),
	BinMsg = mainline_packet:encode_mainline_section_info_s2c(CurSection,Duration),
	role_op:send_data_to_gate(BinMsg).
