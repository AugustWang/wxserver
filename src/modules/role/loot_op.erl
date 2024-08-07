%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(loot_op).

-export([init_loot_list/0,get_loot_info/1,add_loot_to_list/5,set_loot_to_hold/1,delete_loot_from_list/2,is_empty_loot/1,get_item_from_loot/2,remove_item_from_loot/2,
		get_npc_protoid_from_loot/1]).

-export([get_npcid_from_loot/1]).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("login_pb.hrl").
-include("common_define.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%								鎺夎惤鍒楄〃鎿嶄綔
%%鎺夎惤鍒楄〃鐨勬瀯鎴愶細[  {鍖卛d , [{妯℃澘1,鏁伴噺1},{妯℃澘2锛屾暟閲�2}] , 鍖呯姸鎬乮dle/hold ,鎺夎惤Npcid,鎺夎惤npc妯℃澘id,Pos}   ]
%%寮曞叆鍖呯姸鎬佺殑鍘熷洜鏄紝褰撶帺瀹舵煡鐪嬪寘鐨勬椂鍊欙紝 鍐嶆瑙﹀彂寤惰繜鍒犻櫎
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_loot_list()->
	put(loot_list,[]).
	
get_loot_info(LootId)->
	lists:keyfind(LootId,1,get(loot_list)).	
		
add_loot_to_list(LootId,LootInfo,NpcId,NpcProto,Pos)->
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of 
		false ->
			put(loot_list,lists:append(LootList,[{LootId,LootInfo,idle,NpcId,NpcProto,Pos}])),
			timer_util:send_after(?LOOT_DELEAY_TIME, self(), {delete_loot, {LootId,0}}); %%10s鍚庡垹闄odo,10s for test
		_ ->
			todo
	end.
	
set_loot_to_hold(LootId)->
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of
		false ->
			slogger:msg("set_loot_to_hold ,error Lootid:~p~n",[LootId]);
		{LootId,LootInfo,_,NpcId,ProtoId,Pos}->
			put(loot_list,lists:keyreplace(LootId,1,LootList,{LootId,LootInfo,hold,NpcId,ProtoId,Pos}))
	end.	
	
%%	DleStatu:0:鏅�氬垹闄わ紝鍙垹闄dle鐘舵�佺殑鍖呰９锛�1锛氬己鍒跺垹闄�
delete_loot_from_list(LootId,DleStatu)->
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of
		false ->					%%宸茬粡琚富鍔ㄥ垹闄�
			nothing;
		{LootId,_,Status,_,_,_}->
			case DleStatu of
				1 ->						%%寮哄埗鍒犻櫎
					put(loot_list,lists:keydelete(LootId,1,LootList)),
					release;
				0 ->						
					case Status of
						idle ->				
							put(loot_list,lists:keydelete(LootId,1,LootList)),
							release;
						hold ->
							timer_util:send_after(?LOOT_DELEAY_TIME, self(), {delete_loot, {LootId,1}}),  %%鐜╁鎵撳紑浜嗗寘瑁癸紝鏆傛椂涓嶅垹锛�10绉掑悗瑙﹀彂寮哄埗鍒犻櫎
							nothing
					end
			end
	end.

%%  0-> 绌哄寘 
%% !0-> 涓嶇┖
is_empty_loot(LootInfo)->
	lists:foldl(fun({ItemId,_Count},Sum)
				-> ItemId + Sum
				end,0,LootInfo).

%%鍙栧嚭lootid閲岀slotid涓綅缃笂鐨剓鐗╁搧id,Count}
get_item_from_loot(LootId,SlotId)->
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of
		{LootId,LootInfo,_Statu,_NpcId,_NpcProtoId,_Pos}->
			case (SlotId > erlang:length(LootInfo)) or (SlotId =< 0) of
				false->
					lists:nth(SlotId,LootInfo);
				true ->  
					{0,0}
			end;
		false ->
			{0,0}
	end.
		
%%remove鍓嶅凡璋冪敤get锛屾墍浠ヤ笉鐢ㄥ啀妫�娴嬫Ы鏁�,娉細骞朵笉鏄湡姝ｇ殑remove鎺夛紝鑰屾槸灏嗙墿鍝佷俊鎭缃负{0,0}	
remove_item_from_loot(LootId,SlotId)->			
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of
		{LootId,LootInfo,_Statu,NpcId,NpcProtoId,Pos}->
			{ItemId,_} = lists:nth(SlotId,LootInfo),
			case ItemId =/= 0 of
				true ->		
					NewLootInfo = lists:keyreplace(ItemId,1,LootInfo,{0,0}),
					put(loot_list,lists:keyreplace(LootId,1,LootList,{LootId,NewLootInfo,idle,NpcId,NpcProtoId,Pos})),
					{remove,NewLootInfo};
				false ->
					nothing
			end;				
		false ->
			nothing
	end.
%%鑾峰彇鍖呰９鏄皝鎺夎惤鐨�
get_npcid_from_loot(LootId)->
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of
		{_,_,_,NpcId,_NpcProtoId,_}->
			NpcId;
		false ->
			0
	end.
get_npc_protoid_from_loot(LootId)->
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of
		{_,_,_,_NpcId,NpcProtoId,_}->
			NpcProtoId;
		false ->
			0
	end.	
	