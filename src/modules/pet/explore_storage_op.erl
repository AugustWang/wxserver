%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-10-15
%% Description: TODO: Add description to explore_storage_op
-module(explore_storage_op).

%%
%% Include files
%%
-define(STORAGE_MAX_SOLT,10000).
-define(STORAGE_PER_PAGE_NUM,100).
-include("pet_def.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-export([init/1,export_for_copy/0,load_by_copy/1,explore_storage_init/0,
		explore_storage_getallitems/0,explore_storage_getitem/2,add_item/1]).

%%
%% API Functions
%%
%% explore_storage_init_state 标示宠物背包是否初始化过，1：初始化过；0：未初始化，如果初始化过则不需要发送背包中的所有数据
%%-record(pet_explore_storage,{itemlist,max_item_id}). 
%%explore_storage_list :explore_storage itemlist
%%max_explore_item_id 
%%


init(RoleId)->
	put(explore_storage_init_state,0),
	case load_form_db(RoleId) of
		[]->
%%			io:format("explore_storage_op explore_storage_op,init,[]~n"),
			put(explore_storage_list,[]),
			put(max_explore_item_id,0);
		Record->
%%			io:format("explore_storage_op Record:~p~n",[Record]),
			ItemList = element(#pet_explore_storage.itemlist,Record),
			MaxItemId = element(#pet_explore_storage.max_item_id,Record),
%%			io:format("explore_storage_op init ItemList:~p~n",[ItemList]),
			put(explore_storage_list,ItemList),
			put(max_explore_item_id,MaxItemId)
	end.


export_for_copy()->
%%	io:format("explore_storage_op export_for_copy()~n"),
	{get(explore_storage_list),get(max_explore_item_id),get(explore_storage_init_state)}.


load_by_copy({ItemList,MaxItemId,StorageInitState})->
%%	io:format("explore_storage_op Info:~p,MaxItemId:~p,StorageInitState:~p~n",[ItemList,MaxItemId,StorageInitState]),
	put(explore_storage_list,ItemList),		
	put(max_explore_item_id,MaxItemId),
	put(explore_storage_init_state,StorageInitState).


explore_storage_init()->
	StorageInitState =get(explore_storage_init_state),
	if 
		StorageInitState =:= 0->
%%			io:format("explore_storage_init ,explore_storage_list:~p~n",[get(explore_storage_list)]),
			send_items(get(explore_storage_list)),
			put(explore_storage_init_state,1);
		true->
			nothing
	end.
	



%%
%%function：将宠物探险仓库中的物品放入背包。
%%arg: 
%%	TmpSlot 是所要去物品的slot
%%	Sign 探险背包物品唯一标示
%%	

explore_storage_getitem(TmpSlot,Sign)->
	Slot = TmpSlot+1,   
	if  
		(Slot =< 0) or (Slot > ?STORAGE_MAX_SOLT)->
			slogger:msg("explore_storage_getitem_c2s role ~p slot ~p meybe hack!!!",[get(roleid),Slot]); 
		true->
			ItemList = get(explore_storage_list),
%%			io:format("explore_storage_getitem ItemList:~p~n",[ItemList]),
			ItemNum = length(ItemList),
			if
				Slot > ItemNum->
%%				io:format("ExploreItemId =/= Sign~n"),
					nothing;
				true->
					{ExploreItemId,ItemProtoId,Count} = lists:nth(Slot,ItemList),
					if
						ExploreItemId =/= Sign->
	%%						io:format("ExploreItemId =/= Sign~n"),
							nothing;
						true->
							Res = package_op:can_added_to_package_template_list([{ItemProtoId,Count}]),
							if 
								Res ->
									NewItemList = lists:keydelete(ExploreItemId,1,ItemList),
									put(explore_storage_list,NewItemList),
									save_to_db(get(roleid),NewItemList,get(max_explore_item_id)),
		   							role_op:auto_create_and_put(ItemProtoId,Count,got_pet_explore),
		  							DelMsgBin = pet_packet:encode_explore_storage_delitem_s2c(Slot,1),
									role_op:send_data_to_gate(DelMsgBin);
	  				 			true->
		   							ErrorMsgBin = pet_packet:encode_explore_storage_opt_s2c(?ERROR_PACKEGE_FULL),
									role_op:send_data_to_gate(ErrorMsgBin)
							end
					end
			end
	end.
	
%%全部取出探险背包中的物品，如果背包不足则取到背包满为止
explore_storage_getallitems()->
	StartIndex = 1,
	{EndIndex,GetItemList} = move_item_to_packet(StartIndex,[]),
%%	io:format("GetItemList:~p~n",[GetItemList]),
	if
		StartIndex < EndIndex->
			ItemList = get(explore_storage_list),
			if 
				ItemList =:= []->
					put(max_explore_item_id,0);
				true->
					nothing
			end,
%%			io:format("StartIndex < EndIndex->~n"),
			save_to_db(get(roleid),get(explore_storage_list),get(max_explore_item_id)),
			DelMsgBin = pet_packet:encode_explore_storage_delitem_s2c(StartIndex,EndIndex - StartIndex),
			role_op:send_data_to_gate(DelMsgBin);
		true->
			nothing
	end.
		



move_item_to_packet(Index,GetItemList)->
%%	io:format("move_item_to_packet(Index,GetItemList)~n"),
	ItemList = get(explore_storage_list),
	if
		ItemList =:= []->
			{Index,GetItemList};
		true->
			[HeaderItem|RemainItems] = ItemList,
			{_ExploreItemId,ItemProtoId,Count} = HeaderItem,
			Res =  package_op:can_added_to_package_template_list([{ItemProtoId,Count}]),
			if 
				Res ->
					put(explore_storage_list,RemainItems),
		   			role_op:auto_create_and_put(ItemProtoId,Count,got_pet_explore),
					move_item_to_packet(Index+1,[{ItemProtoId,Count}|GetItemList]);
	  			true->
		   			ErrorMsgBin = pet_packet:encode_explore_storage_opt_s2c(?ERROR_PACKEGE_FULL),
					role_op:send_data_to_gate(ErrorMsgBin),
%%					io:format("move_item_to_packet end ok~n"),
					{Index,GetItemList}
			end
	end.







%%
%%添加物品
%%
%%先合并同类物品
%%再逐个添加
%%
add_item(ItemList) when is_list(ItemList)->
%% 	if
%% 		ItemList =:= []->
%% 			nothing;
%% 		true->
%% 			gm_logger_role:pet_explore_get_items_log(get(roleid),get(level),ItemList)
%% 	end,
%%	io:format("add_item~n"),
	StorageInitState =get(explore_storage_init_state),
	{UpdateInfoList,AddInfoList} = lists:foldl(fun({ProtoId,Count},Acc)->
														{UpdateAcc,AddAcc} = Acc,
														{UpdateInfo,AddInfo} = treasure_storage_op:add_item_to_storage({ProtoId,Count},get(explore_storage_list)),
														if
															UpdateInfo =:= []->
																NewUpdateAcc = UpdateAcc;
															true->
																NewUpdateAcc = [UpdateInfo|UpdateAcc]
														end,
														if
															AddInfo =:= []->
																NewAddAcc = AddAcc;
															true->
																NewAddAcc = [AddInfo|AddAcc]
														end,
														{NewUpdateAcc,NewAddAcc}
													end,{[],[]},ItemList),
%%	io:format("UpdateInfoList:~p,AddInfoList:~p~n",[UpdateInfoList,AddInfoList]),
	AllAddItems = lists:foldl(fun({AddProtoId,AddCount},Acc)->
								if
									AddCount =:= 0->
										Acc;
									true->
										AddTmpTempInfo = item_template_db:get_item_templateinfo(AddProtoId),	
										AddMaxStack = item_template_db:get_stackable(AddTmpTempInfo),
										AddItems = add_item_and_makemsg(AddProtoId,AddCount,AddMaxStack,[]),
										Acc++AddItems
								end
							end,[],AddInfoList),
   	if
		AllAddItems =:= []->
			nothing;
		true->
			if
				StorageInitState =:= 0->
					nothing;
				true->	
%%					io:format("add_item:AllAddItems~p~n",[AllAddItems]),
					AddMsgBin = pet_packet:encode_explore_storage_additem_s2c(AllAddItems),
					role_op:send_data_to_gate(AddMsgBin)
			end
	end,		
	UpdateItems = lists:map(fun({UpdateSign,UpdateItemProtoId,UpdateNewCount,UpdateIndex})->
								NewList = lists:keyreplace(UpdateSign,1,get(explore_storage_list),{UpdateSign,UpdateItemProtoId,UpdateNewCount}),
								put(explore_storage_list,NewList),
								treasure_storage_packet:make_tsi(UpdateItemProtoId,UpdateIndex,UpdateNewCount,UpdateSign)
							end,UpdateInfoList),
%%	io:format(" UpdateItems:max_explore_item_id:~p~n",[get(max_explore_item_id)]),
	if
		UpdateItems =:= []->
			nothing;
		true->
		if 
			StorageInitState =:= 0->
				nothing;
			true->	
	%%			io:format("add_item:UpdateItems~p~n",[UpdateItems]),
				UpdateMsgBin = pet_packet:encode_explore_storage_updateitem_s2c(UpdateItems),
				role_op:send_data_to_gate(UpdateMsgBin)
		end
	end,
%%	io:format("	add_item:~p,max_explore_item_id:~p~n",[get(explore_storage_list),get(max_explore_item_id)]),
	save_to_db(get(roleid),get(explore_storage_list),get(max_explore_item_id)).



add_item_and_makemsg(_ItemProtoId,0,_MaxStack,MsgBin)->
	MsgBin;

add_item_and_makemsg(ItemProtoId,RemainCount,MaxStack,MsgBin)->
	Sign = gen_item_id(),
	CurCount = erlang:min(RemainCount,MaxStack),
	NewList = get(explore_storage_list)++[{Sign,ItemProtoId,CurCount}],
	put(explore_storage_list,NewList),
	NewMsgBin = [treasure_storage_packet:make_tsi(ItemProtoId,length(NewList),CurCount,Sign)|MsgBin],
	NewRemainCount = RemainCount - CurCount,
	add_item_and_makemsg(ItemProtoId,NewRemainCount,MaxStack,NewMsgBin).

gen_item_id()->
	CurIndex = get(max_explore_item_id),
	put(max_explore_item_id,CurIndex+1),
	CurIndex+1.

send_items([])->
	EndMsgBin = pet_packet:encode_explore_storage_init_end_s2c(),
	role_op:send_data_to_gate(EndMsgBin);

send_items(StorageItems)->
%%	io:format("send_items(StorageItems):~p~n",[StorageItems]),
	RemainNum = length(StorageItems),
	if
		RemainNum >= ?STORAGE_PER_PAGE_NUM->
			{SendStorageItems,RemainStorageItems} = lists:split(?STORAGE_PER_PAGE_NUM,StorageItems);
		true->
			SendStorageItems = StorageItems,
			RemainStorageItems = []
	end,
	SendStorageInfo = lists:map(fun({TreasureItemId,ItemProtoId,Count})-> treasure_storage_packet:make_tsi(ItemProtoId,0,Count,TreasureItemId) end,SendStorageItems),
	MsgBin = pet_packet:encode_explore_storage_info_s2c(SendStorageInfo),
	role_op:send_data_to_gate(MsgBin),
	send_items(RemainStorageItems).
	
	%%db operate	
save_to_db(RoleId,ItemList,MaxItemId)->
	pet_explore_db:save_explore_to_db(RoleId, ItemList, MaxItemId).

load_form_db(RoleId)->
	pet_explore_db:load_explore_form_db(RoleId).
%% Local Functions
%%

