%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : hatred_op.erl
%%% Author  : zhaoyan
%%% Description : 
%%% Date : 12 7 2010 

-module(hatred_op).
-export([init/0,insert/2,delete/1,delete_to_back/1,get_value_back/1,delete_back/1,change/2,get_value/1,get_hatred_list/0,get_highest_enemyid/0,clear/0,get_id_by_hatred/1,get_highest_value/0,
		 get_enemy_num/0,get_nth_enemyid/1,get_other_nth_enemyid/2]).

-include("npc_struct.hrl").
%% [{EnemyId,HatredValue}]
init()->
	%%put(hatred_list,[]),
	%%put(back_hatred_list,[]). 
	nothing.
	
insert(EnemyId,HatredValue)->
	case get_value(EnemyId) of
		0->
			NpcInfo = get(creature_info),
			LastList = get_hatred_list_from_npcinfo(NpcInfo),
			NewNpcInfo = set_hatred_list_to_npcinfo(NpcInfo,[{EnemyId,HatredValue}|LastList]),
			put(creature_info,NewNpcInfo),
			npc_op:update_npc_info(get(id),NewNpcInfo);
		_->
			change(EnemyId,HatredValue)
	end.

delete(EnemyId)->
	NpcInfo = get(creature_info),
	LastList = get_hatred_list_from_npcinfo(NpcInfo),
	NewNpcInfo = set_hatred_list_to_npcinfo(NpcInfo,lists:keydelete(EnemyId,1,LastList)),
	put(creature_info,NewNpcInfo),
	npc_op:update_npc_info(get(id),NewNpcInfo).
	
clear()->
	%%put(hatred_list,[]),
	%%put(back_hatred_list,[]).
	NpcInfo = get(creature_info),
	NpcInfo1 = set_hatred_list_to_npcinfo(NpcInfo,[]),
	NpcInfo2 = set_back_hatred_list_to_npcinfo(NpcInfo1,[]),
	put(creature_info,NpcInfo2),
	npc_op:update_npc_info(get(id),NpcInfo2).

get_enemy_num()->
	erlang:length(get_hatred_list()).
	
change(EnemyId,HatredValue)->
	NpcInfo = get(creature_info),
	LastList = get_hatred_list_from_npcinfo(NpcInfo),
	NewNpcInfo = set_hatred_list_to_npcinfo(NpcInfo,lists:keyreplace(EnemyId,1,LastList,{EnemyId,HatredValue})),
	put(creature_info,NewNpcInfo),
	npc_op:update_npc_info(get(id),NewNpcInfo).
	
get_value(EnemyId)->
	case lists:keyfind(EnemyId,1,get_hatred_list()) of
		false -> 0;
		{EnemyId,Value} -> Value
	end.
	
get_id_by_hatred(Value)->
		case lists:keyfind(Value,2,get_hatred_list()) of
			false -> 0;
			{EnemyId,Value} -> EnemyId
	end.	
	
get_hatred_list()->
	get_hatred_list_from_npcinfo(get(creature_info)).

get_back_hatred_list()->
	get_back_hatred_list_from_npcinfo(get(creature_info)).
	
get_highest_enemyid()->
	get_highest_enemyid(get_hatred_list()).
	
get_highest_enemyid(HatredList)->
	case erlang:length(HatredList) of
		0 -> 0;
		Lenth -> 
			{EnemyId,_} = lists:nth(Lenth,lists:keysort(2, HatredList)),
			EnemyId
	end.

get_highest_value()->
	HatredList = get_hatred_list(),
	case erlang:length(HatredList) of
		0 -> 0;
		Lenth -> 
			{_EnemyId,Value} = lists:nth(Lenth,lists:keysort(2, HatredList)),
			Value
	end.


get_nth_enemyid(Nth)->
	HatredList = get_hatred_list(),
	BackHatredList = get_back_hatred_list(),
	HatredListLen = erlang:length(HatredList),
	BackHatredListLen = erlang:length(BackHatredList),
	if
		HatredListLen >= Nth->
			{EnemyId,_} = lists:nth(Nth,lists:reverse(lists:keysort(2, HatredList))),
			EnemyId;
		HatredListLen + BackHatredListLen >= Nth->
			{EnemyId,_} = lists:nth(Nth,lists:reverse(lists:keysort(2, HatredList++BackHatredList))),
			EnemyId;
		true->
			0
	end.

%%
%% not include first hatred	
%%
get_targetlist()->
	List = lists:map(fun({EnemyId,_})-> EnemyId end,get_hatred_list() ++ get_back_hatred_list()),
	First = get_highest_enemyid(),
	List -- [First].

get_other_nth_enemyid(NpcId,Nth)->
	%%check npc
	case creature_op:what_creature(NpcId) of
		npc->
			case creature_op:get_creature_info(NpcId) of
				undefined->
					0;
				OtherInfo->
					HatredList = get_hatred_list_from_npcinfo(OtherInfo),
					BackHatredList = get_back_hatred_list_from_npcinfo(OtherInfo),				
					HatredListLen = erlang:length(HatredList),
					BackHatredListLen = erlang:length(BackHatredList),
					if
						HatredListLen >= Nth->
							{EnemyId,_} = lists:nth(Nth,lists:reverse(lists:keysort(2, HatredList))),
							EnemyId;
						HatredListLen + BackHatredListLen >= Nth->
							{EnemyId,_} = lists:nth(Nth,lists:reverse(lists:keysort(2, HatredList++BackHatredList))),
							EnemyId;
						true->
							0
					end
			end;	
		_->
			0
	end.
	
get_other_enemyid_list(NpcId)->
	%%check npc
	case creature_op:what_creature(NpcId) of
		npc->
			case creature_op:get_creature_info(NpcId) of
				undefined->
					[];
				OtherInfo->
					HatredList = get_hatred_list_from_npcinfo(OtherInfo),
					BackHatredList = get_back_hatred_list_from_npcinfo(OtherInfo),	
					%% delete first 
					First = get_highest_enemyid(HatredList),
					List = lists:map(fun({EnemyId,_})-> EnemyId end,HatredList ++ BackHatredList),
					List -- [First]			
			end;	
		_->
			[]
	end.
	
copy_other_all_enemyid_list(NpcId)->
	%%check npc
	case creature_op:what_creature(NpcId) of
		npc->
			case creature_op:get_creature_info(NpcId) of
				undefined->
					nothing;
				OtherInfo->
					HatredList = get_hatred_list_from_npcinfo(OtherInfo),
					BackHatredList = get_back_hatred_list_from_npcinfo(OtherInfo),	
					NpcInfo = get(creature_info),
					NpcInfo1 = set_hatred_list_to_npcinfo(NpcInfo,HatredList),
					NpcInfo2 = set_back_hatred_list_to_npcinfo(NpcInfo1,BackHatredList),
					put(creature_info,NpcInfo2),
					npc_op:update_npc_info(get(id),NpcInfo2)	
			end;	
		_->
			nothing
	end.
	
copy_other_one_enemyid(NpcId)->
	%%check npc
	case creature_op:what_creature(NpcId) of
		npc->
			case creature_op:get_creature_info(NpcId) of
				undefined->
					nothing;
				OtherInfo->
					HatredList = get_hatred_list_from_npcinfo(OtherInfo),
					BackHatredList = get_back_hatred_list_from_npcinfo(OtherInfo),	
					NpcInfo = get(creature_info),
					case get_highest_enemyid(HatredList) of
						0->
							NewHatredList = [];
						HighestEnemyId->
							NewHatredList = lists:keydelete(HighestEnemyId,1,HatredList)
					end,
					case NewHatredList of
						[]->
							NpcInfo1 = set_hatred_list_to_npcinfo(NpcInfo,HatredList),
							NpcInfo2 = set_back_hatred_list_to_npcinfo(NpcInfo1,BackHatredList),
							put(creature_info,NpcInfo2),
							npc_op:update_npc_info(get(id),NpcInfo2);
						_->
							MyHatredList = [lists:nth(random:uniform(length(NewHatredList)),NewHatredList)],
							NpcInfo1 = set_hatred_list_to_npcinfo(NpcInfo,MyHatredList),
							NpcInfo2 = set_back_hatred_list_to_npcinfo(NpcInfo1,BackHatredList),
							put(creature_info,NpcInfo2),
							npc_op:update_npc_info(get(id),NpcInfo2)
					end
			end;	
		_->
			nothing
	end.
	
rand_loop(TargetList)->
	TargetLen = length(TargetList),
	if
		TargetLen =:= 0->
			0;
		true->
			Rand = random:uniform(TargetLen),
			SelectId = lists:nth(TargetList),
			case npc_ai:check_target(SelectId) of
				true->
					SelectId;
				_->
					rand_loop(TargetList -- [SelectId])	
			end	
	end.	
	
rand_target()->
	TargetList = get_targetlist(),
	rand_loop(TargetList).
		
rand_other_target(NpcId)->
	TargetList = get_other_enemyid_list(NpcId),
	rand_loop(TargetList).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  浠囨仺澶囦唤鍒楄〃
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delete_back(EnemyId)->
	NpcInfo = get(creature_info),
	LastList = get_back_hatred_list_from_npcinfo(NpcInfo),
	NewNpcInfo = set_back_hatred_list_to_npcinfo(NpcInfo,lists:keydelete(EnemyId,1,LastList)),
	put(creature_info,NewNpcInfo),
	npc_op:update_npc_info(get(id),NewNpcInfo).

insert_back(EnemyId,HatredValue)->
	NpcInfo = get(creature_info),
	LastList = get_back_hatred_list_from_npcinfo(NpcInfo),
	NewNpcInfo = set_back_hatred_list_to_npcinfo(NpcInfo,[{EnemyId,HatredValue}|LastList]),
	put(creature_info,NewNpcInfo),
	npc_op:update_npc_info(get(id),NewNpcInfo).

get_value_back(EnemyId)->
	case lists:keyfind(EnemyId,1,get_back_hatred_list()) of
		false -> 0;
		{EnemyId,Value} -> Value
	end.

delete_to_back(EnemyId)->
	Value = get_value(EnemyId),
	delete(EnemyId),
	insert_back(EnemyId,Value).
