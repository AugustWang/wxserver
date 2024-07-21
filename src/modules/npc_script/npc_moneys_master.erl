%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_moneys_master).

%%
%% Exported Functions
%%
-export([proc_special_msg/1,init/0,is_start_section/1]).
-include("data_struct.hrl").
-include("login_pb.hrl").
-include("system_chat_define.hrl").
-include("ai_define.hrl").
-define(START_PREPARE_TIME,11000).
-define(CHECK_TIME_DURATION,1000).
-define(MAX_SECTION_NUM,20).
-define(DURATION_TIME,720000).
%%
%% API Functions
%%
init()->
	put(npc_moneys_master_cur_section,0),
	put(npc_moneys_master_start_time,{0,0,0}),
	send_check().

proc_special_msg(npc_moneys_master_check)->
	do_show_monster().

%%npc ai
is_start_section(Section)->
	 (get(npc_moneys_master_cur_section)=:=Section).

%%local
send_check()->
	erlang:send_after(?CHECK_TIME_DURATION,self(),npc_moneys_master_check).

do_show_monster()->
	case mapop:get_map_roles_id() of
		[]-> %%no role come in
			send_check();
		_->
			case get(npc_moneys_master_cur_section) of
				0->		%%not start
					case get(npc_moneys_master_start_time) of
						{0,0,0}->
							%%prepare time
							prepare_brd(trunc(?START_PREPARE_TIME/1000)),
							put(npc_moneys_master_start_time,now());
						PreStartTime->
							LeftTime = (?START_PREPARE_TIME*1000 - timer:now_diff(now(), PreStartTime)),
							case LeftTime =< 0 of
								true->
									put(npc_moneys_master_cur_section,1),
									monster_spawns_brd(1),
									npc_ai:handle_event(?EVENT_SECTION_UNITS_SPAWN),
									put(npc_moneys_master_start_time,now()),
									adjust_time(trunc(?DURATION_TIME/1000));
								_-> %%prepare time
									prepare_brd(trunc(LeftTime/1000000)+1)
							end
					end,
					send_check();
				NowSection->
					LeftTime_S = trunc((?DURATION_TIME*1000 - timer:now_diff(now(), get(npc_moneys_master_start_time)))/1000000),
					if
						LeftTime_S >= 0->
							adjust_time(LeftTime_S),
							if
								NowSection>=?MAX_SECTION_NUM->
									case mapop:is_all_units_dead_but([get(id)]) of
										true->
											finish_game();
										_->
											send_check()		
									end;		
								true->
									%%has start
									case mapop:is_all_units_dead_but([get(id)]) of
										true->
											put(npc_moneys_master_cur_section,NowSection+1),
											monster_spawns_brd(NowSection+1),
											npc_ai:handle_event(?EVENT_SECTION_UNITS_SPAWN);
										false->
											nothing
									end,
									send_check()
							end;
						true->
							game_over()		
					end
			end
	end.

finish_game()->
	Section = ?MAX_SECTION_NUM,
	UseTime_S = trunc(timer:now_diff(now(), get(npc_moneys_master_start_time))/1000000),
	io:format("finish_game Time ~p Section ~p ~n ",[UseTime_S,Section]),
	Msg = login_pb:encode_moneygame_result_s2c(#moneygame_result_s2c{result = 1,section = Section,use_time = UseTime_S}),
	broad_msg_to_whole_map(Msg).

game_over()->
	Section = get(npc_moneys_master_cur_section),
	Time = trunc(?DURATION_TIME/1000),
	Msg = login_pb:encode_moneygame_result_s2c(#moneygame_result_s2c{result = 0,section = Section,use_time = Time}),
	broad_msg_to_whole_map(Msg),
	normal_ai:stop_instance().

prepare_brd(LeftSecond)->
	Msg = login_pb:encode_moneygame_prepare_s2c(#moneygame_prepare_s2c{second = LeftSecond}),
	broad_msg_to_whole_map(Msg).

monster_spawns_brd(Section)->
	Msg = login_pb:encode_moneygame_cur_sec_s2c(#moneygame_cur_sec_s2c{cursec = Section,maxsec = ?MAX_SECTION_NUM}),
	broad_msg_to_whole_map(Msg).
	
adjust_time(LeftTime_S)->
	if
		(LeftTime_S rem 20 ) =:= 0->
			Msg = login_pb:encode_moneygame_left_time_s2c(#moneygame_left_time_s2c{left_seconds = max(0,LeftTime_S - 1)}),
			broad_msg_to_whole_map(Msg),
			io:format("LeftTime_S ~p ~n",[LeftTime_S]);
		true->
			nothing
	end.
			
broad_msg_to_whole_map(Msg)->
	lists:foreach(fun(RoleId)->npc_op:send_to_other_client(RoleId, Msg) end,mapop:get_map_roles_id()).  
	
			
