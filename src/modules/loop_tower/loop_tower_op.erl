%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-12-27
%% Description: TODO: Add description to loop_tower_op
-module(loop_tower_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([loop_tower_enter/3,export_for_copy/0,load_by_copy/1,write_to_db/0,
		 load_from_db/1,loop_tower_challenge/1,on_map_complete/0,challenge_success/0,
		 on_killed_monster/1,loop_tower_reward/1,loop_tower_challenge_again/2,on_offline/0,
		 loop_tower_masters_c2s/1,loop_tower_week_reward/1,do_send_week_bonus/2,npc_function/0,
		 get_cur_loop_tower_count/0]).
-include("error_msg.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("item_struct.hrl").
-include("map_info_struct.hrl").
-include("common_define.hrl").
-include("system_chat_define.hrl").
-include("game_map_define.hrl").
-include("little_garden.hrl").
-include("npc_define.hrl").
%%
%% API Functions
%%
init(RoleId)->
	put(loop_tower_monster,{0,[]}),
	put(loop_tower_monster_delete,{0,[]}),
	put(enter_loop_tower,false),
	put(role_loop_tower,{RoleId,[],0,{0,0,{0,0,0},0,0}}).

load_from_db(RoleId)->
	case loop_tower_db:get_role_loop_tower(RoleId) of
		{ok,[]}->
			init(RoleId);
		{ok,RoleLoopTowerDB}->
			%%{roleid,[{layer1,time1},{layer2,time2},...],20,LogInfo}
			{role_loop_tower,Roleid,Layertime,Highest,Log} = RoleLoopTowerDB,
			put(loop_tower_monster,{0,[]}),
			put(loop_tower_monster_delete,{0,[]}),
			put(enter_loop_tower,false),
			put(role_loop_tower,{Roleid,Layertime,Highest,Log});
		_->
			init(RoleId)
	end.

export_for_copy()->
	{get(role_loop_tower),get(loop_tower_monster),get(loop_tower_monster_delete),get(enter_loop_tower)}.
	
write_to_db()->
	nothing.

load_by_copy({RoleLoopTower,Monster,MonsterDelete,EnterLoopTower})->
	put(role_loop_tower,RoleLoopTower),
	put(loop_tower_monster,Monster),
	put(loop_tower_monster_delete,MonsterDelete),
	put(enter_loop_tower,EnterLoopTower).

loop_tower_masters_c2s(Master)->
	case loop_tower_db:get_loop_tower_instance_info(Master) of
		[]->
			LayerMaster=[];
		ok->
			LayerMaster=[];
		{loop_tower_instance,_,_,RoleName,Time}->
			LayerMaster=[{ltm,Master,binary_to_list(RoleName),Time}]
	end,
	Message = loop_tower_packet:encode_loop_tower_masters_s2c(LayerMaster),
	role_op:send_data_to_gate(Message).

loop_tower_enter(Layer,Enter,Convey)->
	case get(role_loop_tower) of
		{_,_,H,_}->
			High=H;
		_->
			High=0
	end,
	case loop_tower_db:get_loop_tower_info(Layer) of
		[]->
			Errno=?ERRNO_NPC_EXCEPTION;
		LoopTowerInfo->
			Consum_money = loop_tower_db:get_consum_money_by_info(LoopTowerInfo),
			Enter_prop = loop_tower_db:get_enter_prop_by_info(LoopTowerInfo),
			Convey_prop = loop_tower_db:get_convey_prop_by_info(LoopTowerInfo),
			TransportId = loop_tower_db:get_instance_id_by_info(LoopTowerInfo),
			if
				High+1 >= Layer,Layer >= 1,Layer rem 10 =:= 1->
					case transport_op:can_teleport(get(creature_info),get(map_info),TransportId) of
						true->
					case role_op:check_money(?MONEY_BOUND_SILVER, Consum_money) of
						true->
					case check_prop(Enter,Enter_prop) of
						true->
					case check_count() of
						true->
					case check_convey_prop(Convey,Convey_prop) of
						true->
					case get(role_loop_tower) of
						{RoleId,LayerTime,Highest,Log}->
							Errno=[],
							put(enter_loop_tower,true),
							{_,_,Ftime,Count,_} = Log,
							if 
								Ftime=:={0,0,0}->
									FirstTime = timer_center:get_correct_now();
							   	true->
								   	FirstTime = Ftime
							end,
							{MSec,Sec,_} = timer_center:get_correct_now(),
						   	Time = MSec*1000000+Sec,
							put(role_loop_tower,{RoleId,LayerTime,Highest,{{Layer,Time},Layer,FirstTime,Count+1,0}}),	
							activity_value_op:update({loop_tower},Layer),														
							loop_tower_db:sync_update_role_loop_tower_to_mnesia(RoleId, 
								{RoleId,LayerTime,Highest,{0,Layer,FirstTime,Count+1,0}}),
							if
								Consum_money > 0->
									role_op:money_change(?MONEY_BOUND_SILVER, -Consum_money, lost_loop_tower);
								true->
									nothing
							end,
							case Enter_prop of
								[]->
									nothing;
								{_,EPropCount}->
									equipment_op:consume_item(Enter, EPropCount)
							end,
							case Convey_prop of
								[]->
									nothing;
								ConveyProps->
									lists:foldl(fun({ProtoId,NeedCount},Acc)->
										if
											Acc < NeedCount->
												ItemCount = item_util:get_items_count_in_package(ProtoId),
												if
													ItemCount>=NeedCount-Acc->
														role_op:consume_items(ProtoId, NeedCount-Acc),
														NeedCount;
													true->
														role_op:consume_items(ProtoId, ItemCount),
														Acc+ItemCount
												end;
											true->
												Acc
										end
									end, 0, ConveyProps)
							end,
							gm_logger_role:role_loop_tower_detail(RoleId,Layer,0,2,get(level))
						end;
						false->
							Errno=?ERROR_LOOP_TOWER_CONVEY_PROP_NOEXIST
						end;
						false->
							Errno=?ERROR_LOOP_TOWER_IS_LIMITED
						end;
						false->
							Errno=?ERROR_LOOP_TOWER_PROP_NOEXIST
						end;
						false->
							Errno=?ERROR_LESS_MONEY
						end;
						false->
							Errno=1
					end;
				true->
					Errno=?ERROR_LOOP_TOWER_WRONG_LAYER
			end
	end,
	if 
		Errno =/= []->
			loop_tower_enter_failed_s2c(Errno);
 		true->
			transport_to_instance(Layer)
	end.

loop_tower_challenge(Type)->
	case get(role_loop_tower) of
		{RoleId,LayerTime,Highest,{_,CurLayer,Ftime,Count,DeCount}}->
			{XLayer,DeleteMonsters}=get(loop_tower_monster_delete),
			if 
				Type=:=1,XLayer=/=0,erlang:length(DeleteMonsters)=/=0->
					slogger:msg("DeleteMonsters is not empty,can't challenge next layer:~p!!!~n",[XLayer]),
					nothing;
				true->
					case loop_tower_db:get_loop_tower_info(CurLayer) of
						[]->
							role_op:respawn_self_in_situ(),
							loop_tower_over(CurLayer,1);
						_->
							if
								Type=:=1,CurLayer=/=0->
									gm_logger_role:role_loop_tower_detail(RoleId,CurLayer,0,0,get(level)),
									if 
										CurLayer rem 10=:=1->
						   					{MSec,Sec,_} = timer_center:get_correct_now(),
						   					Time = MSec*1000000+Sec,
						   					put(role_loop_tower,{RoleId,LayerTime,Highest,
															 	{{CurLayer,Time},CurLayer,Ftime,Count,DeCount}});
					   					true->
											nothing
									end,
%% 									achieve_op:achieve_update({loop_tower}, [0], CurLayer),
									transport_to_instance(CurLayer);
								Type=:=2,CurLayer=/=0->
									gm_logger_role:role_loop_tower_detail(RoleId,CurLayer,0,9,get(level)),
									role_op:respawn_self_in_situ(),
									loop_tower_over(CurLayer,1);
								true->
									put(enter_loop_tower,false),
									instance_op:kick_from_cur_instance()
							end
					end
			end;
		_->
			nothing
	end.

loop_tower_challenge_again(Type,Again)->
	case get(role_loop_tower) of
		{RoleId,LayersTime,Highest,{InitTime,CurLayer,Ftime,Count,DeCount}}->
			if
				Type=:=1,CurLayer=/=0->
					case loop_tower_db:get_loop_tower_info(CurLayer) of
						[]->
							role_op:respawn_self_in_situ(),
							loop_tower_over(CurLayer,2);
						LoopTowerInfo->
							Monsters = loop_tower_db:get_monsters_by_info(LoopTowerInfo),
							Again_prop = loop_tower_db:get_loop_prop_by_info(LoopTowerInfo),
							if 
								DeCount<1->
									gm_logger_role:role_loop_tower_detail(RoleId,CurLayer,0,3,get(level)),
									if 
										CurLayer rem 10=:=1->
											{MSec,Sec,_} = timer_center:get_correct_now(),
											Time = {CurLayer,MSec*1000000+Sec};
										true->
											Time = InitTime
									end,
									put(role_loop_tower,{RoleId,LayersTime,Highest,{Time,CurLayer,Ftime,Count,DeCount+1}}),
									role_op:respawn_self_in_situ(),
									simulation_monsters(CurLayer,Monsters);
								true->
									case check_prop_in_list(Again,Again_prop) of
										true->
											gm_logger_role:role_loop_tower_detail(RoleId,CurLayer,0,4,get(level)),
											Errno=[],
											equipment_op:consume_item(Again),
											put(role_loop_tower,{RoleId,LayersTime,Highest,{InitTime,CurLayer,Ftime,Count,DeCount}}),
											role_op:respawn_self_in_situ(),
											simulation_monsters(CurLayer,Monsters);
										false->
											Errno=?ERROR_LOOP_TOWER_AGAIN_PROP_NOEXIST
									end,
									if 
										Errno =/= []->
											loop_tower_enter_failed_s2c(Errno);
 										true->
											nothing
									end
							end
					end;
				Type=:=3,CurLayer=/=0->
					case loop_tower_db:get_loop_tower_info(CurLayer) of
						[]->
							role_op:respawn_self_in_situ(),
							loop_tower_over(CurLayer,2);
						LoopTowerInfo->
							Monsters = loop_tower_db:get_monsters_by_info(LoopTowerInfo),
							if 
								DeCount<1->
									gm_logger_role:role_loop_tower_detail(RoleId,CurLayer,0,3,get(level)),
									if 
										CurLayer rem 10=:=1->
											{MSec,Sec,_} = timer_center:get_correct_now(),
											Time = {CurLayer,MSec*1000000+Sec};
										true->
											Time = InitTime
									end,
									put(role_loop_tower,{RoleId,LayersTime,Highest,{Time,CurLayer,Ftime,Count,DeCount+1}}),
									role_op:respawn_self_in_situ(),
									simulation_monsters(CurLayer,Monsters);
								true->
									case role_op:check_money(?MONEY_GOLD, ?LOOP_TOWER_CHALLENGE_AGAIN_GOLD) of
										true->
											gm_logger_role:role_loop_tower_detail(RoleId,CurLayer,0,5,get(level)),
											Errno=[],
											role_op:money_change(?MONEY_GOLD, -?LOOP_TOWER_CHALLENGE_AGAIN_GOLD, lost_lt_again),
											put(role_loop_tower,{RoleId,LayersTime,Highest,{InitTime,CurLayer,Ftime,Count,DeCount}}),
											role_op:respawn_self_in_situ(),
											simulation_monsters(CurLayer,Monsters);
										false->
											Errno=?ERROR_LESS_GOLD
									end,
									if 
										Errno =/= []->
											loop_tower_enter_failed_s2c(Errno);
 										true->
											nothing
									end
							end
					end;
				Type=:=2,CurLayer=/=0->
					gm_logger_role:role_loop_tower_detail(RoleId,CurLayer,0,10,get(level)),
					role_op:respawn_self_in_situ(),
					loop_tower_over(CurLayer,2);
				true->
					role_op:respawn_self_in_situ(),
					loop_tower_over(CurLayer,2)
			end;
		_->
			nothing
	end.
	
loop_tower_over(Layer,Type)->
	put(enter_loop_tower,false),
	case get(role_loop_tower) of
		{RoleId,LayersTime,Highest,{_,CurLayer,FTime,Count,DeCount}}->
			if 
				CurLayer=:=Layer->
					put(role_loop_tower,
						{RoleId,LayersTime,Highest,{0,0,FTime,Count,DeCount}}),
					open_service_activities:loop_tower(Layer),
					case loop_tower_db:get_loop_tower_info(Layer-1) of
						[]->
							instance_op:kick_from_cur_instance();
						LoopTowerInfo->
							Exp = loop_tower_db:get_exp_by_info(LoopTowerInfo),
							if 
								Type=:=1->
									role_op:obtain_exp(Exp);
								Type=:=2->
									role_op:obtain_exp(erlang:trunc(Exp/2));
								true->
									nothing
							end,
							loop_tower_db:sync_update_role_loop_tower_to_mnesia(RoleId, 
								{RoleId,LayersTime,Highest,{0,0,FTime,Count,DeCount}}),
							instance_op:kick_from_cur_instance()
					end;
				true->
					nothing
			end;
		_->
			nothing
	end.

on_killed_monster(MonsterId)->
	case get(enter_loop_tower) of
		true->
			case get(loop_tower_monster) of
				{0,[]}->
					gm_logger_role:role_loop_tower_detail(get(roleid),0,0,99,get(level));
				{Layer,Monsters}->
					case lists:member(MonsterId, Monsters) of
						true->
							{_,DeleteMonsters} = get(loop_tower_monster_delete),
							MonstersResult = lists:delete(MonsterId, DeleteMonsters),
							if 
								erlang:length(MonstersResult) =:= 0->
 									case mapop:is_all_units_dead() of
										false->
											gm_logger_role:role_loop_tower_detail(get(roleid),Layer,0,98,get(level));
										true->
											challenge_success()
									end,
									put(loop_tower_monster_delete,{Layer,MonstersResult});
 								true->
 									put(loop_tower_monster_delete,{Layer,MonstersResult})
 							end;
 						false->
 							gm_logger_role:role_loop_tower_detail(get(roleid),Layer,0,97,get(level))
 					end
 			end;
		false->
			nothing;
		_->
			nothing
	end.

update_layer_master_info(RoleId,CurLayer,NewDurationTime)->
	case check_my_layer_master(RoleId,CurLayer,NewDurationTime) of
		false->
			nothing;
		true->
			case loop_tower_db:get_loop_tower_instance_info(CurLayer) of
				[]->
					gm_logger_role:role_loop_tower(RoleId,CurLayer,NewDurationTime),
					system_bodcast(?SYSTEM_CHAT_LOOP_TOWER_MASTER,get(creature_info),CurLayer-9,CurLayer),
					role_game_rank:hook_on_new_tower_master({CurLayer-9,NewDurationTime}),
					loop_tower_db:sync_update_loop_tower_instance_to_mnesia(CurLayer,
						{CurLayer,RoleId,get_name_from_roleinfo(get(creature_info)),NewDurationTime});
				{loop_tower_instance,_,_,_,OriDurationTime}->
					if
						NewDurationTime < OriDurationTime->
							gm_logger_role:role_loop_tower(RoleId,CurLayer,NewDurationTime),
							system_bodcast(?SYSTEM_CHAT_LOOP_TOWER_MASTER,get(creature_info),CurLayer-9,CurLayer),
							role_game_rank:hook_on_new_tower_master({CurLayer-9,NewDurationTime}),
							loop_tower_db:sync_update_loop_tower_instance_to_mnesia(CurLayer,
								{CurLayer,RoleId,get_name_from_roleinfo(get(creature_info)),NewDurationTime});
						true->
							nothing
					end
			end;
		LoopTowerInstance->
			loop_tower_db:delete_loop_tower_instance_by_roleid(LoopTowerInstance),
			gm_logger_role:role_loop_tower(RoleId,CurLayer,NewDurationTime),
			role_game_rank:hook_on_new_tower_master({CurLayer-9,NewDurationTime}),
			system_bodcast(?SYSTEM_CHAT_LOOP_TOWER_MASTER,get(creature_info),CurLayer-9,CurLayer),
			loop_tower_db:sync_update_loop_tower_instance_to_mnesia(CurLayer, 
				{CurLayer,RoleId,get_name_from_roleinfo(get(creature_info)),NewDurationTime})
	end.

challenge_success()->
	case get(role_loop_tower) of
		{RoleId,LayersTime,Highest,Log}->
			{Time,CurLayer,Ftime,Count,DeCount}=Log,
			case get(looptower_success) of
				false->
					put(looptower_success,true),
					case loop_tower_db:get_loop_tower_info(CurLayer) of
						[]->
							gm_logger_role:role_loop_tower_detail(get(roleid),CurLayer,0,93,get(level)),
							Errno=?ERRNO_NPC_EXCEPTION;
						LoopTowerInfo->
							Bonus = loop_tower_db:get_bonus_by_info(LoopTowerInfo),
							Errno=[],
							if 
								CurLayer>Highest->
									CurHigh=CurLayer;
								true->
									CurHigh=Highest
							end,
							{InitLayer,InitTime} = Time,
							{MSec,Sec,_} = timer_center:get_correct_now(),
							NewDurationTime = (MSec*1000000+Sec)-InitTime,
							gm_logger_role:role_loop_tower_detail(RoleId,CurLayer,NewDurationTime,1,get(level)),
							role_game_rank:hook_on_tower_num(CurLayer),
							if 
								CurLayer rem 10=:=0,CurLayer-10+1=:=InitLayer->
									case lists:keyfind(CurLayer, 1, LayersTime) of
										false->
											NewLayersTime = [{CurLayer,NewDurationTime}|LayersTime];
										{_,OldDurationTime}->
											if
												NewDurationTime<OldDurationTime->
													NewLayersTime=lists:keyreplace(CurLayer, 1, LayersTime, 
																				   {CurLayer,NewDurationTime});
												true->
													NewLayersTime=LayersTime
											end
									end,
									put(role_loop_tower,{RoleId,NewLayersTime,CurHigh,
														 {0,CurLayer+1,Ftime,Count,DeCount}}),
									update_layer_master_info(RoleId,CurLayer,NewDurationTime);
								true->
									put(role_loop_tower,{RoleId,LayersTime,CurHigh,
														 {Time,CurLayer+1,Ftime,Count,DeCount}})
							end,
							case Bonus of 
								[]->
									loop_tower_challenge_success_s2c(CurLayer,0);
								BonusId->
									loop_tower_challenge_success_s2c(CurLayer,BonusId)
							end
					end;
				true->
					gm_logger_role:role_loop_tower_detail(get(roleid),CurLayer,0,92,get(level)),
					Errno=[]
			end
	end,
	if 
		Errno =/= []->
			loop_tower_enter_failed_s2c(Errno);
 		true->
			nothing
	end.

check_my_layer_master(RoleId,CurLayer,LayerTime)->
	case loop_tower_db:get_loop_tower_instance_info_by_roleid(RoleId) of
		[]->
			true;
		ok->
			true;
		LoopTowerInstance->
			{loop_tower_instance,HMaster,_,_,Time}=LoopTowerInstance,
			if CurLayer>HMaster->
				   LoopTowerInstance;
			   CurLayer=:=HMaster,LayerTime<Time->
				   LoopTowerInstance;
			   true->
				   false
			end
	end.

loop_tower_reward(Bonus)->
	case get(role_loop_tower) of
		{_,_,_,Log}->
			{_,CurLayer,_,_,_}=Log,
			case loop_tower_db:get_loop_tower_info(CurLayer-1) of
				[]->
					Errno=?ERRNO_NPC_EXCEPTION;
				LoopTowerInfo->
					BonusDB = loop_tower_db:get_bonus_by_info(LoopTowerInfo),
					if
						BonusDB=:=Bonus->
							case package_op:can_added_to_package(BonusDB,1) of
								0 -> %% full bag
									Errno=?ERROR_PACKEGE_FULL;
								_OK ->
									Errno=[],
									role_op:auto_create_and_put(BonusDB, 1, got_from_loop_tower),
									loop_tower_enter_s2c(CurLayer,0)
							end;
						true->
							Errno=?ERRNO_NPC_EXCEPTION
					end
			end
	end,
	if 
		Errno =/= []->
			loop_tower_enter_failed_s2c(Errno);
 		true->
			nothing
	end.

loop_tower_enter_s2c(Layer,Trans)->
	Message = loop_tower_packet:encode_loop_tower_enter_s2c(Layer,Trans),
	role_op:send_data_to_gate(Message).

loop_tower_challenge_success_s2c(Layer,Bonus)->
	Message = loop_tower_packet:encode_loop_tower_challenge_success_s2c(Layer,Bonus),
	role_op:send_data_to_gate(Message).

loop_tower_enter_failed_s2c(Errno)->
	Message_failed = loop_tower_packet:encode_loop_tower_enter_failed_s2c(Errno),
	role_op:send_data_to_gate(Message_failed).

simulation_monsters(Layer,Monsters)->
	put(looptower_success,false),
	Mylevel = get_level_from_roleinfo(get(creature_info)),
	creature_op:call_creature_spawns(Monsters,{Mylevel,?CREATOR_BY_SYSTEM}),
 	put(loop_tower_monster,{Layer,Monsters}),
	put(loop_tower_monster_delete,{Layer,Monsters}).

transport_to_instance(Layer)->
	case loop_tower_db:get_loop_tower_info(Layer) of
		[]->
			slogger:msg("get_loop_tower_info is [],can't challenge next layer:~p!!!~n",[Layer]);
		LoopTowerInfo->
			TransportId = loop_tower_db:get_instance_id_by_info(LoopTowerInfo),
			transport_op:teleport(get(creature_info),get(map_info),TransportId)
	end.

on_map_complete()->
	case mapop:get_map_tag(get_mapid_from_mapinfo(get(map_info))) of
		?MAP_TAG_LOOP_TOWER->
			case get(role_loop_tower) of
				{_,_,_,Log}->
					{_,CurLayer,_,_,_}=Log,
					case loop_tower_db:get_loop_tower_info(CurLayer) of
						[]->
							Errno=?ERRNO_NPC_EXCEPTION;
						LoopTowerInfo->
							Monsters = loop_tower_db:get_monsters_by_info(LoopTowerInfo),
							simulation_monsters(CurLayer,Monsters),
							loop_tower_enter_s2c(CurLayer,0),
							Errno=[]
					end
			end,
			if 
				Errno =/= []->
					Message_failed = loop_tower_packet:encode_loop_tower_enter_failed_s2c(Errno),
					role_op:send_data_to_gate(Message_failed);
 				true->
					nothing
			end;
		_->
			nothing
	end.

on_offline()->
	case get(role_loop_tower) of
		{RoleId,LayersTime,Highest,{_,CurLayer,FTime,Count,DeCount}}->
			case loop_tower_db:get_loop_tower_info(CurLayer-1) of
					[]->
						nothing;
					LoopTowerInfo->
						Exp = loop_tower_db:get_exp_by_info(LoopTowerInfo),
						role_op:obtain_exp(erlang:trunc(Exp/2))
			end,
			loop_tower_db:sync_update_role_loop_tower_to_mnesia(RoleId, 
				{RoleId,LayersTime,Highest,{0,0,FTime,Count,DeCount}});
		_->
			nothing
	end.

do_send_week_bonus(RoleName,WeekBonusList)->
	mail_op:gm_send_multi("system", binary_to_list(RoleName), "Bonus", "Bonus", WeekBonusList, 0).
	

loop_tower_week_reward(Type)->
	case loop_tower_db:get_loop_tower_instance() of
		[]->
			{ok,"nothing"};
		Result->
			WeekRewardFun = fun({loop_tower_instance,Layer,_,RoleName,_})->
				case loop_tower_db:get_loop_tower_info(Layer) of
					[]->{ok,"nothing"};
					LoopTowerInfo->
						{_,_,_,_,_,_,_,_,WeekBonus,_,_}=LoopTowerInfo,
						case WeekBonus of
							[]->{ok,"nothing"};
							WeekBonusList->
								do_send_week_bonus(RoleName,WeekBonusList)
						end
				end
				end,
			lists:foreach(WeekRewardFun, Result),
			if Type=:=0->
				loop_tower_db:clear_loop_tower_instance_rpc(),
			   	{ok,"doclear"};
			   true->
				   {ok,"noclear"}
			end
	end.

get_cur_loop_tower_count()->
	case get(role_loop_tower) of
		{RoleId,LayerTime,Highest,Log}->
			{InitTime,Layer,Ftime,Count,_} = Log,
			if 
				Ftime=:=0->
					Ftime2={0,0,0};
				true->
					Ftime2=Ftime
			end,
			case instance_op:check_is_overdue(Ftime2, 1, {{0,0,0},{0,0,0}}) of
				true->
					put(role_loop_tower,{RoleId,LayerTime,Highest,{InitTime,Layer,{0,0,0},0,0}}),
					0;
				_->
					Count
			end
	end.
	
check_count()->
	Count = get_cur_loop_tower_count(),
	DailyCount=env:get(loop_tower_daily_count, 1),
	if
		Count < DailyCount->
			true;
		true->
			false
	end.

check_convey_prop(_,Props)->
	case Props of 
		[]->
			true;
		ListProps->
			{C1,C2} = lists:foldl(fun({ProtoId,NeedCount},{ICount,_})->
								ItemCounts = item_util:get_items_count_in_package(ProtoId),
								{ICount+ItemCounts,NeedCount}
						end, {0,0}, ListProps),
			if
				C1 >= C2->
					true;
				true->
					false
			end
	end.

check_prop(Package_slot,Prop)->
	case Prop of 
		[]->
			true;
		{ProtoId,Count}->
			case equipment_op:get_item_from_proc(Package_slot) of
				[]->
					false;
				ItemInfo->
					ItemTemplateId = get_template_id_from_iteminfo(ItemInfo),
					ItemCount = get_count_from_iteminfo(ItemInfo),
					if 
						ItemTemplateId=:=ProtoId,ItemCount>=Count->
							true;
						true->
							false
					end
			end
	end.

check_prop_in_list(Package_slot,PropList)->
	case PropList of 
		[]->
			true;
		List->
			case equipment_op:get_item_from_proc(Package_slot) of
				[]->
					false;
				ItemInfo->
					ItemTemplateId = get_template_id_from_iteminfo(ItemInfo),
					lists:member(ItemTemplateId, List)
			end
	end.

system_bodcast(SysId,RoleInfo,Num1,Num2) ->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamInt1 = system_chat_util:make_int_param(Num1),	
	ParamInt2 = system_chat_util:make_int_param(Num2),	
	MsgInfo = [ParamRole, ParamInt1, ParamInt2],
	system_chat_op:system_broadcast(SysId,MsgInfo).

loop_tower_higher_s2c(Higher)->
	Message = loop_tower_packet:encode_loop_tower_enter_higher_s2c(Higher),
	role_op:send_data_to_gate(Message).

npc_function()->
	case get(role_loop_tower) of
		[]->
			loop_tower_higher_s2c(1);
		{_,_,Highest,_}->
			if
				Highest=:=0->
					loop_tower_higher_s2c(1);
				true->
					loop_tower_higher_s2c(Highest)
			end
	end.
			
		
%%
%% Local Functions
%%

