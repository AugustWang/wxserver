%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_hatred_op).
-compile(export_all).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("ai_define.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 杩斿洖鍊�:
%% reset锛堥噸缃級/update_attack锛堟煡璇� 浠囨仺鍒楄〃鍜屾敾鍑伙級/nothing_todo(淇濇寔鐩墠鐘舵��)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%鏅�氭�笉涓诲姩鏀诲嚮
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init()->
	put(npc_enemys_list,[]),
	hatred_op:init().
	
clear()->
	put(npc_enemys_list,[]),
	hatred_op:clear().	
	
insert_to_enemys_list(CreatureId)->
	case lists:member(CreatureId,get(npc_enemys_list)) of
		true->
			nothing;
		_->
			put(npc_enemys_list,[CreatureId|get(npc_enemys_list)])
	end.
	
get_all_enemys()->
	get(npc_enemys_list).	

get_target()->
	hatred_op:get_highest_enemyid().
	
nothing_hatred(_,_)->			%%浠庝笉杩樻墜鐨勬�墿
	nothing_todo.	

normal_hatred_update(other_into_view,_EnemyId)-> %%鏅�氭�墿娌℃湁inview鐨勪粐鎭�
	nothing_todo;  
	
normal_hatred_update(call_help,	AttackerId)->  
	case hatred_op:get_highest_value() < ?ATTACKER_HATRED of        
		true ->    			%%褰撳墠娌℃湁浠讳綍鏀诲嚮浠囨仺锛屽垯璁剧疆骞舵敾鍑�
			hatred_op:insert(AttackerId,?HELP_HATRED), 
			update_attack;
		false ->   			%%褰撳墠鏈夋敾鍑讳粐鎭紝鍔犲叆鏂颁粐鎭�
			case hatred_op:get_value(AttackerId) < ?ATTACKER_HATRED of 
				true -> 
					hatred_op:insert(AttackerId,?HELP_HATRED),
					nothing_todo;
				false ->		%%杩欎汉宸茬粡鍦ㄦ敾鍑荤殑浠囨仺鍒楄〃閲屼簡
					nothing_todo
					
			end
	end; 
	
normal_hatred_update(is_attacked,{AttackerId,_HATRED})->  %%EnemyIds涓虹粍闃熶腑鎵�鏈夌帺瀹秈d,鏀诲嚮鑰呮渶楂橈紝鍏朵粬鍧囦綆,TODO:瑕佸垽鏂窛绂伙紵
		insert_to_enemys_list(AttackerId),
		case hatred_op:get_highest_value() < ?ATTACKER_HATRED of        
			true ->    			%%褰撳墠娌℃湁浠讳綍鏀诲嚮浠囨仺锛屽垯璁剧疆骞舵敾鍑�
				hatred_op:insert(AttackerId,?ATTACKER_HATRED), 
				update_attack;
			false ->   			%%褰撳墠鏈夋敾鍑讳粐鎭紝鍔犲叆鏂颁粐鎭紝骞朵笖鏃т粐鎭ㄥ姞1,浠ユ鍐冲畾鏀诲嚮椤哄簭
				case hatred_op:get_value(AttackerId) < ?ATTACKER_HATRED of 
					true -> 
						lists:foreach(fun({ID,Value})->hatred_op:change(ID,Value + 1) end,hatred_op:get_hatred_list()),
						hatred_op:insert(AttackerId,?ATTACKER_HATRED),
						nothing_todo;
					false ->		%%杩欎汉宸茬粡鍦ㄦ敾鍑荤殑浠囨仺鍒楄〃閲屼簡
						nothing_todo
				end
		end; 

normal_hatred_update(other_dead,PlayerId)-> 
	case PlayerId =:= get(targetid) of
		true  -> 
			hatred_op:delete(PlayerId),				%%鐩爣姝讳簡,浠庝粐鎭ㄥ垪琛ㄤ腑鍒犻櫎
			case hatred_op:get_hatred_list() of
				[] ->  reset;						%%浠囨仺鍒楄〃绌轰簡锛岄噸缃畁pc
			 	 _ -> update_attack					%%杩樻湁鐩爣锛屽幓鏀诲嚮鍏朵粬浜�
			end;
		false ->									%%鍋风潃涔�
				hatred_op:delete(PlayerId),
			 	nothing_todo
	end; 
	
normal_hatred_update(other_outof_bound,EnemyId)->
	case  EnemyId =:= get(targetid) of 		
		true ->  	 %%鐩爣浠庢敾鍑讳腑閫冭窇浜�
				hatred_op:delete(EnemyId),
				case hatred_op:get_hatred_list() of
					[] ->  reset;						%%浠囨仺鍒楄〃绌轰簡锛岄噸缃畁pc
					_ -> update_attack					%%杩樻湁灏忕粍闃熷弸锛屽幓鏀诲嚮鍏堕槦鍙�
				end;
		false -> 	
				hatred_op:delete(EnemyId),
			 	nothing_todo
	end;
	
normal_hatred_update(_Other,_EnemyId)->
	nothing_todo.  
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%涓诲姩鎬墿
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
active_hatred_update(other_into_view,EnemyId)->
	case hatred_op:get_hatred_list() of
		[] ->
			insert_into_view_hatred(EnemyId),
			update_attack; 
		_ ->  %%褰撳墠鏈変粐鎭紝涓嶅啀琚叾浠栫帺瀹剁殑绉诲姩鍚稿紩
			nothing_todo
	end;

active_hatred_update(call_help,AttackerId)->  
	case hatred_op:get_highest_value() < ?ATTACKER_HATRED of        
		true ->    			%%褰撳墠娌℃湁浠讳綍鏀诲嚮浠囨仺锛屽垯璁剧疆骞舵敾鍑�
			hatred_op:insert(AttackerId,?HELP_HATRED), 
			update_attack;
		false ->   			%%褰撳墠鏈夋敾鍑讳粐鎭紝鍔犲叆鏂颁粐鎭�
			case hatred_op:get_value(AttackerId) < ?ATTACKER_HATRED of 
				true -> 
					hatred_op:insert(AttackerId,?HELP_HATRED),
					nothing_todo;
				false ->		%%杩欎汉宸茬粡鍦ㄦ敾鍑荤殑浠囨仺鍒楄〃閲屼簡
					nothing_todo
			end
	end; 

active_hatred_update(is_attacked,{AttackerId,_HATRED})->
	insert_to_enemys_list(AttackerId),
	case hatred_op:get_highest_value() < ?ATTACKER_HATRED of        
		true ->    			%%褰撳墠娌℃湁浠讳綍鏀诲嚮浠囨仺锛屽垯璁剧疆骞舵敾鍑�
			hatred_op:clear(),				%%娓呴櫎褰撳墠鍕惧紩浣犱絾鏄病鏀诲嚮鐨勪汉鐨勪粐鎭�
			hatred_op:insert(AttackerId,?ATTACKER_HATRED), 
			update_attack;
		false ->   			%%褰撳墠鏈夋敾鍑讳粐鎭紝鍔犲叆鏂颁粐鎭紝骞朵笖鏃т粐鎭ㄥ姞1,浠ユ鍐冲畾鏀诲嚮椤哄簭
			case hatred_op:get_value(AttackerId) < ?ATTACKER_HATRED of 
				true -> 
					lists:foreach(fun({ID,Value})->hatred_op:change(ID,Value + 1) end,hatred_op:get_hatred_list()),
					hatred_op:insert(AttackerId,?ATTACKER_HATRED),
					nothing_todo;
				false ->		%%杩欎汉宸茬粡鍦ㄦ敾鍑荤殑浠囨仺鍒楄〃閲屼簡
					nothing_todo
					
			end
	end; 

active_hatred_update(other_dead,PlayerId)-> 
	case hatred_op:get_value(PlayerId) of
		0 -> nothing_todo;
		_ -> 
			hatred_op:delete(PlayerId),			%%鐜╁姝讳簡,浠庝粐鎭ㄥ垪琛ㄤ腑鍒犻櫎
			case hatred_op:get_hatred_list() =:= [] of 
				true ->  reset;						%%浠囨仺鍒楄〃绌轰簡锛岄噸缃畁pc
			 	false -> update_attack							%%杩樻湁灏忕粍闃熷弸锛屽幓鏀诲嚮鍏堕槦鍙�
			 end
	end;
	
active_hatred_update(other_outof_bound,PlayerId)-> 
	case PlayerId =:= get(targetid) of 
				false ->  
							hatred_op:delete(PlayerId),
							nothing_todo;
				true ->  			%%琚墦鐨勭帺瀹朵粠鏀诲嚮涓�冭窇浜�
							hatred_op:delete(PlayerId),  
							case hatred_op:get_hatred_list() =:= [] of 
								true ->  reset;						%%浠囨仺鍒楄〃绌轰簡锛岄噸缃畁pc
							 	false -> update_attack							%%杩樻湁鍒汉锛屽幓鏀诲嚮鍒汉
							end
	end;
		
active_hatred_update(_Other,_EnemyId)->
	todo. 
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Boss浠囨仺璁＄畻
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
active_boss_hatred_update(other_into_view,EnemyId) ->
	case hatred_op:get_hatred_list() of
		[] ->
			insert_into_view_hatred(EnemyId),
			update_attack; 
		_ -> 
			insert_into_view_hatred(EnemyId),
			nothing_todo
	end;

active_boss_hatred_update(call_help,AttackerId)->  
	case hatred_op:get_highest_value() < ?ATTACKER_HATRED of        
		true ->    			%%褰撳墠娌℃湁浠讳綍鏀诲嚮浠囨仺锛屽垯璁剧疆骞舵敾鍑�
			hatred_op:insert(AttackerId,?HELP_HATRED), 
			update_attack;
		false ->   			%%褰撳墠鏈夋敾鍑讳粐鎭紝鍔犲叆鏂颁粐鎭�
			case hatred_op:get_value(AttackerId) < ?ATTACKER_HATRED of 
				true -> 
					hatred_op:insert(AttackerId,?HELP_HATRED),
					nothing_todo;
				false ->		%%杩欎汉宸茬粡鍦ㄦ敾鍑荤殑浠囨仺鍒楄〃閲屼簡
					nothing_todo
			end
	end; 

active_boss_hatred_update(is_attacked,{AttackerId,HATRED}) ->
	insert_to_enemys_list(AttackerId),
	case hatred_op:get_highest_value() < ?ATTACKER_HATRED of        
		true ->    			%%褰撳墠娌℃湁浠讳綍鏀诲嚮浠囨仺锛屽垯璁剧疆骞舵敾鍑�
			hatred_op:insert(AttackerId,?ATTACKER_HATRED+HATRED),			%%鏀诲嚮浠囨仺鍩烘暟+瀹為檯浠囨仺鍊� 
			update_attack;
		false ->   			%%褰撳墠鏈夋敾鍑讳粐鎭紝鍔犲叆浠囨仺锛屽苟涓旇绠椾粐鎭ㄦ槸鍚﹁秴杩囧綋鍓嶇洰鏍囩殑110%
			NowHatred = hatred_op:get_value(AttackerId),
			case  NowHatred < ?ATTACKER_HATRED of			 %%杩欎汉鏄惁宸叉湭鍦ㄦ敾鍑讳粐鎭ㄩ噷
				true -> 									
					case hatred_op:get_value_back(AttackerId) of		%%杩欐槸鍚﹀湪澶囦唤浠囨仺閲�
						0-> NewHatred = ?ATTACKER_HATRED+HATRED;		
						BackValue -> 
							NewHatred = BackValue +	HATRED,				%%鍦ㄥ浠戒粐鎭ㄩ噷,浠庡浠戒腑鍒犻櫎
							hatred_op:delete_back(AttackerId)
					end;
				false ->
					NewHatred = HATRED + NowHatred
			end,
			hatred_op:insert(AttackerId,NewHatred),
			case AttackerId =:= get(targetid) of						%%鏀诲嚮鑰呮槸鍚︽槸褰撳墠鏀诲嚮鐩爣
				false ->
					Targethatred = hatred_op:get_value(get(targetid)),							
					case NewHatred*100 >= Targethatred*110 of				%%鍒ゆ柇鏄惁瓒呰繃褰撳墠鐩爣浠囨仺鍊�110%锛屾槸鍒欐洿鏂扮洰鏍�
						true ->	
							%%鏇存柊鏌撶孩鐩爣
							npc_op:update_touchred_into_selfinfo(AttackerId),
							npc_op:broad_attr_changed([{touchred,AttackerId}]),
							update_attack;
						false ->
							nothing_todo
					end;
				true ->
					nothing_todo
			end
	end; 

active_boss_hatred_update(other_dead,PlayerId)-> 
	case hatred_op:get_value(PlayerId) of
		0 -> nothing_todo;
		_ -> 
			hatred_op:delete_to_back(PlayerId),			%%鐜╁姝讳簡,鍒犻櫎鍒板浠藉垪琛�
			case hatred_op:get_hatred_list() =:= [] of 
				true -> 
					reset;						%%浠囨仺鍒楄〃绌轰簡锛岄噸缃畁pc
			 	false -> 
			 		update_attack				%%杩樻湁鍏朵粬浜猴紝鍘绘敾鍑诲叾浠栦汉
			 end
	end;

active_boss_hatred_update(other_outof_bound,PlayerId)-> 
	case PlayerId =:= get(targetid) of 
		false ->  
			case hatred_op:get_value(PlayerId) =< ?INVIEW_ROLE_HATRED of
				true-> nothing_todo;
				_ ->
					hatred_op:delete_to_back(PlayerId),
					nothing_todo
			end;
		true ->  			%%琚墦鐨勭帺瀹朵粠鏀诲嚮涓�冭窇浜�
			hatred_op:delete_to_back(PlayerId),  
			case hatred_op:get_hatred_list() =:= [] of 
				true ->   
					reset;						%%浠囨仺鍒楄〃绌轰簡锛岄噸缃畁pc
			 	false ->
			 		update_attack							%%杩樻湁鍒汉锛屽幓鏀诲嚮鍒汉
			end
	end;
		
active_boss_hatred_update(_Other,_EnemyId)->
	todo.
	
%%local
insert_into_view_hatred(EnemyId)->
	case creature_op:what_creature(EnemyId) of
		npc->
			hatred_op:insert(EnemyId,?INVIEW_NPC_HATRED); 
		role->
			hatred_op:insert(EnemyId,?INVIEW_ROLE_HATRED);
		_->
			nothing
	end.

	
	
	