%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(treasure_spawns_op).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports

-compile(export_all).

%% gen_server callbacks
-include("data_struct.hrl").
-include("activity_define.hrl").
-include("system_chat_define.hrl").
-include("npc_define.hrl").

init({Id,StartLine})->
	put(id,Id),
	put(cur_treasures,[]),
	put(online_player_num,get_all_online_palyer_num()),
	random:seed(now()),
	put(is_main_broad_cast,false),
	{{_,{StartH,StartMin,_}},_} = StartLine,
	TreasureInfo = treasure_spawns_db:get_info(Id),
	put(treasure_type,treasure_spawns_db:get_type(TreasureInfo)),
	NowDate = calendar:now_to_local_time(timer_center:get_correct_now()),
	{Today,_} = NowDate,
	NowSecs = calendar:datetime_to_gregorian_seconds(NowDate),
	StartSecs = calendar:datetime_to_gregorian_seconds({Today,{StartH,StartMin,0}}),
	LeftTime =  max(StartSecs - NowSecs,0),
	self() ! {start_left_time,LeftTime}.

left_time_interve(LeftTime)->
	if
		LeftTime =:= 0->
			start_treasure_spawns();
		LeftTime > 60*5->
			erlang:send_after((LeftTime - 60*5)*1000, self(), {start_left_time,60*5});
		LeftTime > 60*4->
			sys_broad_cast(left_time,5),
			erlang:send_after((LeftTime - 60*4)*1000, self(), {start_left_time,60*4});
		LeftTime > 60*3->
			sys_broad_cast(left_time,4),
			erlang:send_after((LeftTime - 60*3)*1000, self(), {start_left_time,60*3});
		LeftTime > 60*2->
			sys_broad_cast(left_time,3),
			erlang:send_after((LeftTime - 60*2)*1000, self(), {start_left_time,60*2});
		LeftTime > 60*1->
			sys_broad_cast(left_time,2),
			erlang:send_after((LeftTime - 60*1)*1000, self(), {start_left_time,60*1});
		true->
			sys_broad_cast(left_time,1),
			erlang:send_after(LeftTime*1000, self(), {start_left_time,0})
	end.


start_treasure_spawns()->
	do_spawns_part(1).

stop_treasure_spawns()->
	sys_broad_cast(stop,[]),
	activity_manager:apply_stop_me(?TEASURE_SPAWNS_ACTIVITY,node()).

do_spawns_part(Index)->
	TreasureInfo = treasure_spawns_db:get_info(get(id)),
	MaxRound = treasure_spawns_db:get_round_num(TreasureInfo),
	case Index > MaxRound of
		true->
			unload_treasures(),
			stop_treasure_spawns();
		_->
			unload_treasures(),
			SpawnNum = get_spawn_num(treasure_spawns_db:get_spawn_num(TreasureInfo)),
			MapSpawns = treasure_spawns_db:get_map_spawns(TreasureInfo),
			MapsTmp = treasure_spawns_db:get_maps(TreasureInfo),
			Maps = lists:filter(fun(MapTmp)-> lines_manager:get_map_node(?TREASURE_SPAWNS_DEFAULT_LINE, MapTmp)=:= node() end,MapsTmp),
			[FirstMap|_] = MapsTmp, 
			case lists:member(FirstMap,Maps) of
				true->
					put(is_main_broad_cast,true);
				_->
					put(is_main_broad_cast,false)
			end,
				
			Treasures =
			lists:foldl(fun(MapId,TreasureTmp)->
							case lists:keyfind(MapId,1, MapSpawns) of
								{MapId,Spawns}->
									MapTreasures = random_spawns(SpawnNum,Spawns,erlang:length(Spawns),[]),
									TreasureTmp ++ MapTreasures;
								_->
									TreasureTmp
							end	
						end,[],Maps),
			start_treasures(Treasures),
			NextTime = lists:nth(Index,treasure_spawns_db:get_interval(TreasureInfo)),
			if
				Index=:=1->
					sys_broad_cast(start,[]);
				Index=:=MaxRound->
					sys_broad_cast(treasure_spawn_last,MaxRound);
				true->
					sys_broad_cast(treasure_spawn,Index)
			end,
			erlang:send_after(NextTime, self(), {do_spawns,Index+1})
	end.

random_spawns(0,_,_,Re)->
	Re;
random_spawns(_,_,0,Re)->
	Re;
random_spawns(SpawnNum,Treasures,Length,Re)->
	RandomV = random:uniform(Length),
	{L1,[NewTreasure|T]} = lists:split(RandomV - 1, Treasures),
	random_spawns(SpawnNum - 1,L1++T,Length - 1,[NewTreasure|Re]).
			
unload_treasures()->
	lists:foreach(fun(NpcId)->
		try				  
			creature_op:unload_npc_by_line(?TREASURE_SPAWNS_DEFAULT_LINE,NpcId)
		catch 
			E:R->slogger:msg("treasure_spawns_op:unload_treasures ~p ~p ~n",[E,R])
		end
		end, get(cur_treasures)),
	put(cur_treasures,[]).

start_treasures(Treasures)->
	lists:foreach(fun(NpcId)->
		try
			creature_op:call_creature_spawn(?TREASURE_SPAWNS_DEFAULT_LINE,NpcId,{?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM})
		catch 
			E:R->slogger:msg("treasure_spawns_op:start_treasures ~p ~p ~n",[E,R])
		end
	end, Treasures),
	put(cur_treasures,Treasures).

sys_broad_cast(Item,Info)->
	case get(is_main_broad_cast) of
		true->
			sys_broad_cast_by_type(get(treasure_type),Item,Info);
		_->
			nothing
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%											Star
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_CHEST,left_time,LeftMin)->
	ParamInt = system_chat_util:make_int_param(LeftMin),
	system_chat_op:system_broadcast(?SYSTEM_CHAT_TREASURE_SPAWNS_PREPARE,[ParamInt]);

sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_CHEST,start,_)->
	todo_start,
	system_chat_op:system_broadcast(?SYSTEM_CHAT_TREASURE_SPAWNS_FIRST_SECTION,[]);

sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_CHEST,treasure_spawn,Index)->
	ParamInt = system_chat_util:make_int_param(Index-1),
	ParamInt2 = system_chat_util:make_int_param(Index),
	MsgInfo = [ParamInt,ParamInt2],
	system_chat_op:system_broadcast(?SYSTEM_CHAT_TREASURE_SPAWNS_SECTION,MsgInfo);

sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_CHEST,treasure_spawn_last,_)->
	system_chat_op:system_broadcast(?SYSTEM_CHAT_TREASURE_SPAWNS_LAST_SECTION,[]);

sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_CHEST,stop,_)->
	system_chat_op:system_broadcast(?SYSTEM_CHAT_TREASURE_SPAWNS_END,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%											Treasure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_STAR,left_time,LeftMin)->
	ParamInt = system_chat_util:make_int_param(LeftMin),
	system_chat_op:system_broadcast(?SYSTEM_CHAT_STAR_SPAWNS_PREPARE,[ParamInt]);

sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_STAR,start,_)->
	Msg = treasure_spawns_packet:encode_star_spawns_section_s2c(1),
%%	role_pos_util:send_to_all_online_clinet(Msg),
	server_travels_util:send_msg_to_all_server(Msg),
	system_chat_op:system_broadcast(?SYSTEM_CHAT_STAR_SPAWNS_FIRST_SECTION,[]);

sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_STAR,treasure_spawn,Index)->
	Msg = treasure_spawns_packet:encode_star_spawns_section_s2c(Index),
%%	role_pos_util:send_to_all_online_clinet(Msg),
	server_travels_util:send_msg_to_all_server(Msg),
	ParamInt = system_chat_util:make_int_param(Index-1),
	ParamInt2 = system_chat_util:make_int_param(Index),
	MsgInfo = [ParamInt,ParamInt2],
	system_chat_op:system_broadcast(?SYSTEM_CHAT_STAR_SPAWNS_SECTION,MsgInfo);

sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_STAR,treasure_spawn_last,MaxRound)->
	Msg = treasure_spawns_packet:encode_star_spawns_section_s2c(MaxRound),
%%	role_pos_util:send_to_all_online_clinet(Msg),
	server_travels_util:send_msg_to_all_server(Msg),
	system_chat_op:system_broadcast(?SYSTEM_CHAT_STAR_SPAWNS_LAST_SECTION,[]);

sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_STAR,stop,_)->
	system_chat_op:system_broadcast(?SYSTEM_CHAT_STAR_SPAWNS_END,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%											Ride
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_RIDE,left_time,LeftMin)->
	ParamInt = system_chat_util:make_int_param(LeftMin),
	system_chat_op:system_broadcast(?SYSTEM_CHAT_RIDE_SPAWNS_PREPARE,[ParamInt]);

sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_RIDE,start,_)->
	system_chat_op:system_broadcast(?SYSTEM_CHAT_RIDE_SPAWNS_FIRST_SECTION,[]);

sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_RIDE,treasure_spawn,Index)->
	ParamInt = system_chat_util:make_int_param(Index-1),
	ParamInt2 = system_chat_util:make_int_param(Index),
	MsgInfo = [ParamInt,ParamInt2],
	system_chat_op:system_broadcast(?SYSTEM_CHAT_RIDE_SPAWNS_SECTION,MsgInfo);

sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_RIDE,treasure_spawn_last,MaxRound)->
	system_chat_op:system_broadcast(?SYSTEM_CHAT_RIDE_SPAWNS_LAST_SECTION,[]);

sys_broad_cast_by_type(?TREASURE_SPAWNS_TYPE_RIDE,stop,_)->
	system_chat_op:system_broadcast(?SYSTEM_CHAT_RIDE_SPAWNS_END,[]);

sys_broad_cast_by_type(_,Type,Info)->
	nothing.

get_all_online_palyer_num()->
	case server_travels_util:is_share_server() of
		false->
			role_pos_db:get_online_count();
		true->
			map_travel_op:get_all_server_online()
	end.

get_spawn_num(SpawnList)->
	OnlineNum = get(online_player_num),
	[{_,MinNum}|_] = SpawnList, 
	lists:foldl(fun({RoleNum,SpawnNum},NumTmp)->
					if
						OnlineNum>= RoleNum->
							SpawnNum;
						true->
							NumTmp
					end
				end,MinNum, SpawnList).