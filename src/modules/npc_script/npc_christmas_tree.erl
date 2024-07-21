%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-28
%% Description: TODO: Add description to npc_christmas_tree
-module(npc_christmas_tree).

%%
%% Exported Functions
%%
-compile(export_all).
-include("christmas_activity_define.hrl").
-include("activity_define.hrl").
-include("christmas_activity_def.hrl").
-include("npc_struct.hrl").
-include("npc_define.hrl").
%%
%% API Functions
%%

proc_msg({up_christmas_tree,RoleId,Value})->
	up_christmas_tree_by_value(RoleId,Value);

proc_msg(_)->
	nothing.

init_npc_christmas_tree()->
	case npc_op:get_lineid_from_mapinfo(get(map_info)) =/= ?CHRISTMAS_TREE_BORN_LINE of
		true->
			self() ! {forced_leave_map};
		_->
			case activity_db:get_activity_info(?TYPE_CHRISTMAS_ACTIVITY) of
				[]->
					case get(id) =/= ?NPC_SMALL_TREE of
						true->
							self() ! {forced_leave_map};
						false->
							init_tree_from_config()
					end;
				{_,_,{NpcId,CurHp,Max_Hp}}->
					case CurHp =:= Max_Hp of 
						true->
							case get(id) =:= ?NPC_FINAL_TREE of
								true->
									nothing;
								_->
									CrisTreeInfo = christmas_activity_db:get_christmas_tree_config(NpcId),
									NextId = christmas_activity_db:get_next_proto_from_cristreeinfo(CrisTreeInfo),
									case NextId =:= get(id) of
										true->
											init_tree_from_config();
										_->
											self() ! {forced_leave_map}
									end
							end;
						_->
							case NpcId =/= get(id) of
								true->
									self() ! {forced_leave_map};
								_->
									npc_op:broad_attr_changed([{hpmax,Max_Hp},{hp,CurHp}]),
									put(christmas_tree_info,{CurHp,Max_Hp})
							end
					end
			end
	end.

init_tree_from_config()->
	NpcId = get(id),
	TreeInfo = christmas_activity_db:get_christmas_tree_config(NpcId),
	Init_Hp = christmas_activity_db:get_christmas_tree_init_hp(TreeInfo),
	Max_Hp = christmas_activity_db:get_christmas_tree_max_hp(TreeInfo),
	npc_op:broad_attr_changed([{hpmax,Max_Hp},{hp,Init_Hp}]),
	put(christmas_tree_info,{Init_Hp,Max_Hp}).
	
up_christmas_tree_by_value(RoleId,Value)->
	case get(id) =:= ?NPC_FINAL_TREE of
		true->
			nothing;
		_->
			{Now_Hp,Max_Hp} = get(christmas_tree_info),
			New_Hp = Now_Hp + Value,
			if
				New_Hp >= Max_Hp ->
					write_to_db(get(id),New_Hp,Max_Hp),
					spawn_new_npc();
				true->
					write_to_db(get(id),New_Hp,Max_Hp),
					put(christmas_tree_info,{New_Hp, Max_Hp}),
					npc_op:broad_attr_changed([{hp,New_Hp}])
			end,
			Msg = christmac_activity_packet:encode_christmas_tree_hp_s2c(New_Hp,300),
			role_pos_util:send_to_role_clinet(RoleId,Msg),
			ok
	end.
			
spawn_new_npc()->
	case get(id) =/= ?NPC_FINAL_TREE of
		true->
			MyPos = get_pos_from_npcinfo(get(creature_info)),
			CrisTreeInfo = christmas_activity_db:get_christmas_tree_config(get(id)),
			NextId = christmas_activity_db:get_next_proto_from_cristreeinfo(CrisTreeInfo),
			self() ! {forced_leave_map},
			creature_op:call_creature_spawn(NextId,?CREATOR_LEVEL_BY_SYSTEM,get(id));
		_->
			nothing
	end.
	
write_to_db(NpcId,New_Hp,Max_Hp)->
	activity_db:add_to_activity_db(?TYPE_CHRISTMAS_ACTIVITY,{NpcId,New_Hp,Max_Hp}).














