%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(quest_follower_followed).

-export([on_acc_script/1,com_script/1,proc_script_msg/2,on_com_script/1,on_delete_addation_state/1]).

-include("quest_define.hrl").
-include("base_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_define.hrl").

on_acc_script(QuestId)->
	QuestInfo = quest_db:get_info(QuestId),
	lists:foreach(fun({Msg,_Op,_ObjValue})-> 
						case Msg of
							{quest_follower,NpcProto}->
								self() ! {quest_script_msg,?MODULE,[QuestId,NpcProto]};
							_->
								nothing
						end
				end, quest_db:get_objectivemsg(QuestInfo)),
	true.
	
%% com_script self! 
com_script(QuestId)->
	QuestInfo = quest_db:get_info(QuestId),
	lists:map(fun({Msg,_Op,_ObjValue})->
				{Msg,0}	  
			end, quest_db:get_objectivemsg(QuestInfo)).		  

on_com_script(Questid)->
	on_delete_addation_state(Questid).	
	
on_delete_addation_state(Questid)->
	NpcIds = quest_op:get_addation_state(Questid), 
	lists:foreach(fun(NpcId)-> 
		case creature_op:get_creature_info(NpcId) of
			?ERLNULL->
				nothing;
			CreatureInfo->
				creature_op:get_pid_from_creature_info(CreatureInfo) ! {forced_leave_map}
		end	end,NpcIds),
	true.

proc_script_msg(QuestId,NpcProto)->
	case quest_op:get_quest_state(QuestId) of
		[]->
			nothing;
		?QUEST_STATUS_INCOMPLETE->				%%todo,should use ext_status to record intermediate
			{BaseX,BaseY} = get_pos_from_roleinfo(get(creature_info)),
			Bornposition = {BaseX - 2,BaseY - 2}, 
			Mylevel = get_level_from_roleinfo(get(creature_info)),
			case creature_op:call_creature_spawn_by_create(NpcProto,Bornposition,{Mylevel,?CREATOR_BY_SYSTEM}) of
				error->	
					quest_op:update_with_ext_statu({quest_follower,NpcProto},1,0);
				NpcId->
					quest_op:update_with_ext_statu({quest_follower,NpcProto},1,NpcId),
					case creature_op:get_creature_info(NpcId) of
						?ERLNULL->
							nothing;
						CreatureInfo->
							creature_op:get_pid_from_creature_info(CreatureInfo) ! {follow_me,get(roleid)}
					end
			end
	end.