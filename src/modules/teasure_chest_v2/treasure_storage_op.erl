%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-7-19
%% Description: TODO: Add description to treasure_storage_op
-module(treasure_storage_op).
-define(STORAGE_MAX_SOLT,10000).
-define(STORAGE_PER_PAGE_NUM,100).
-define(ZERO_COUNT,0).
%%
%% Include files
%%
-include("treasure_chest_def.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% API Functions
%%
%% treasure_storage_list [{treasure_item_id,itemprotoid,count}]
%%
%% max_treasure_item_id
%% storage_init_state 标示祈福背包是否初始化过，1：初始化过；0：未初始化
%%

init()->
	put(storage_init_state,0),
	case load_form_db(get(roleid)) of
		[]->
			put(treasure_storage_list,[]),
			put(max_treasure_item_id,0);
		Record->
			ItemList = element(#role_treasure_storage.itemlist,Record),
			MaxItemId = element(#role_treasure_storage.max_item_id,Record),
			put(treasure_storage_list,ItemList),
			put(max_treasure_item_id,MaxItemId)
	end.

process_message({treasure_storage_init_c2s,_})->
	StorageInitState =get(storage_init_state),
	if 
		StorageInitState =:= 0->
			send_items(get(treasure_storage_list)),
			put(storage_init_state,1);
		true->
			nothing
	end;
	
%%
%%function：将祈福背包中的物品放入背包。
%%arg: 
%%	TmpSlot 是所要去物品的slot
%%	Sign 祈福背包物品唯一标示
%%	

process_message({treasure_storage_getitem_c2s,_,TmpSlot,Sign})->
	Slot = TmpSlot+1,   
	if  
		(Slot =< 0) or (Slot > ?STORAGE_MAX_SOLT)->
			slogger:msg("treasure_storage_getitem_c2s role ~p slot ~p meybe hack!!!",[get(roleid),Slot]); 
		true->
			ItemList = get(treasure_storage_list),
			ItemNum = length(ItemList),
			if
				Slot > ItemNum->
					nothing;
				true->
					{TreasureItemId,ItemProtoId,Count} = lists:nth(Slot,ItemList),
					if
						TreasureItemId =/= Sign->
							nothing;
						true->
							Res =  package_op:can_added_to_package_template_list([{ItemProtoId,Count}]),
							if 
								Res ->
									NewItemList = lists:keydelete(TreasureItemId,1,ItemList),
									put(treasure_storage_list,NewItemList),
									save_to_db(get(roleid),NewItemList,get(max_treasure_item_id)),
		   							role_op:auto_create_and_put(ItemProtoId,Count,got_chest),
									%%DelItemInfo = treasure_storage_packet:make_tsi(ItemProtoId,Slot,Count,TreasureItemId),
		  							DelMsgBin = treasure_storage_packet:encode_treasure_storage_delitem_s2c(Slot,1),
									role_op:send_data_to_gate(DelMsgBin),
									RoleId = get(roleid),
									gm_logger_role:treasure_chest_package_get_items(RoleId,[{ItemProtoId,Count}]);
	  				 			true->
		   							ErrorMsgBin = treasure_storage_packet:encode_treasure_storage_opt_s2c(?ERROR_PACKEGE_FULL),
									role_op:send_data_to_gate(ErrorMsgBin)
							end
					end
			end
	end;
	
%%全部取出祈福背包中的物品，如果背包不足则取到背包满为止
process_message({treasure_storage_getallitems_c2s,_})->
	StartIndex = 1,
	{EndIndex,GetItemList} = move_item_to_packet(StartIndex,[]),
%%	io:format("GetItemList:~p~n",[GetItemList]),
	if
		StartIndex < EndIndex->
			ItemList = get(treasure_storage_list),
			if 
				ItemList =:= []->
					put(max_treasure_item_id,0);
				true->
					nothing
			end,
%%			io:format("StartIndex < EndIndex->~n"),
			save_to_db(get(roleid),get(treasure_storage_list),get(max_treasure_item_id)),
			DelMsgBin = treasure_storage_packet:encode_treasure_storage_delitem_s2c(StartIndex,EndIndex - StartIndex),
			role_op:send_data_to_gate(DelMsgBin),
			RoleId = get(roleid),
%%			io:format("RoleId = get(roleid), many~n"),
			gm_logger_role:treasure_chest_package_get_items(RoleId,GetItemList);
		true->
			nothing
	end;
		

process_message(_)->
	nothing.


%%
%%添加物品
%%
%%先合并同类物品
%%再逐个添加
%%
add_item(ItemList) when is_list(ItemList)->
	StorageInitState =get(storage_init_state),
	{UpdateInfoList,AddInfoList} = lists:foldl(fun({ProtoId,Count},Acc)->
														{UpdateAcc,AddAcc} = Acc,
														{UpdateInfo,AddInfo} = add_item_to_storage({ProtoId,Count},get(treasure_storage_list)),
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
					AddMsgBin = treasure_storage_packet:encode_treasure_storage_additem_s2c(AllAddItems),
					role_op:send_data_to_gate(AddMsgBin)
			end
	end,		
	UpdateItems = lists:map(fun({UpdateSign,UpdateItemProtoId,UpdateNewCount,UpdateIndex})->
								NewList = lists:keyreplace(UpdateSign,1,get(treasure_storage_list),{UpdateSign,UpdateItemProtoId,UpdateNewCount}),
								put(treasure_storage_list,NewList),
								treasure_storage_packet:make_tsi(UpdateItemProtoId,UpdateIndex,UpdateNewCount,UpdateSign)
							end,UpdateInfoList),
	if
		UpdateItems =:= []->
			nothing;
		true->
		if 
			StorageInitState =:= 0->
				nothing;
			true->	
%%				io:format("add_item:UpdateItems~p~n",[UpdateItems]),
				UpdateMsgBin = treasure_storage_packet:encode_treasure_storage_updateitem_s2c(UpdateItems),
				role_op:send_data_to_gate(UpdateMsgBin)
		end
	end,
	save_to_db(get(roleid),get(treasure_storage_list),get(max_treasure_item_id));				


%%添加物品
%%调用之前需检查仓库剩余容量
%%反向寻找可堆叠的位置
%%找不到 或者有剩余 加到最后
add_item({ItemProtoId,Count})->
%%	io:format("add_item: single~n"),
	TmpTempInfo = item_template_db:get_item_templateinfo(ItemProtoId),	
	MaxStack = item_template_db:get_stackable(TmpTempInfo),
	{UpdateInfo,AddInfo} = add_item_to_storage({ItemProtoId,Count},get(treasure_storage_list)),
	StorageInitState = get(storage_init_state),
	case UpdateInfo of
		[]->
			nothing;
		{UpdateSign,UpdateItemProtoId,UpdateNewCount,UpdateIndex}->	
			NewList = lists:keyreplace(UpdateSign,1,get(treasure_storage_list),{UpdateSign,UpdateItemProtoId,UpdateNewCount}),
			put(treasure_storage_list,NewList),
			if 
				StorageInitState =:= 0->
					nothing;
				true->	
					UpdateItems = treasure_storage_packet:make_tsi(UpdateItemProtoId,UpdateIndex,UpdateNewCount,UpdateSign),
					UpdateMsgBin = treasure_storage_packet:encode_treasure_storage_updateitem_s2c([UpdateItems]),
					role_op:send_data_to_gate(UpdateMsgBin)
			end
	end,
	case AddInfo of
		[]->
			nothing;
		{_,0}->
			nothing;
		{_,Count}->
			AddItems = add_item_and_makemsg(ItemProtoId,Count,MaxStack,[]),
			if 
				StorageInitState =:= 0->
					nothing;
				true->	
					AddMsgBin = treasure_storage_packet:encode_treasure_storage_additem_s2c(AddItems),
					role_op:send_data_to_gate(AddMsgBin)	
			end
	end,
	save_to_db(get(roleid),get(treasure_storage_list),get(max_treasure_item_id));	

	
add_item(Unknown)->
	slogger:msg("~p add_item unknown param ~p ~n",[?MODULE,Unknown]).


%%
%%获取仓库剩余容量
%%
get_remain_size()->
	?STORAGE_MAX_SOLT - length(get(treasure_storage_list)).
%%
%%
%%

export_for_copy()->
	{get(treasure_storage_list),get(max_treasure_item_id),get(storage_init_state)}.


load_by_copy({Info,MaxItemId,StorageInitState})->
	put(treasure_storage_list,Info),		
	put(max_treasure_item_id,MaxItemId),
	put(storage_init_state,StorageInitState).
%%
%% Local Functions
%%
send_items([])->
	EndMsgBin = treasure_storage_packet:encode_treasure_storage_init_end_s2c(),
	role_op:send_data_to_gate(EndMsgBin);

send_items(StorageItems)->
	RemainNum = length(StorageItems),
	if
		RemainNum >= ?STORAGE_PER_PAGE_NUM->
			{SendStorageItems,RemainStorageItems} = lists:split(?STORAGE_PER_PAGE_NUM,StorageItems);
		true->
			SendStorageItems = StorageItems,
			RemainStorageItems = []
	end,
	SendStorageInfo = lists:map(fun({TreasureItemId,ItemProtoId,Count})-> treasure_storage_packet:make_tsi(ItemProtoId,0,Count,TreasureItemId) end,SendStorageItems),
	MsgBin = treasure_storage_packet:encode_treasure_storage_info_s2c(SendStorageInfo),
	role_op:send_data_to_gate(MsgBin),
	send_items(RemainStorageItems).

load_form_db(RoleId)->
	OwnerTable = db_split:get_owner_table(role_treasure_storage, RoleId),
	case dal:read_rpc(OwnerTable,RoleId) of
		{ok,[Record]}->
			Record;
		_->[]
	end.

save_to_db(RoleId,ItemList,MaxItemId)->
	OwnerTable = db_split:get_owner_table(role_treasure_storage, RoleId),
	dal:write_rpc({OwnerTable,RoleId,ItemList,MaxItemId,undefined}).

gen_item_id()->
	CurIndex = get(max_treasure_item_id),
	put(max_treasure_item_id,CurIndex+1),
	CurIndex+1.

move_item_to_packet(Index,GetItemList)->
%%	io:format("move_item_to_packet(Index,GetItemList)~n"),
	ItemList = get(treasure_storage_list),
	if
		ItemList =:= []->
			{Index,GetItemList};
		true->
			[HeaderItem|RemainItems] = ItemList,
			{_TreasureItemId,ItemProtoId,Count} = HeaderItem,
			Res =  package_op:can_added_to_package_template_list([{ItemProtoId,Count}]),
			if 
				Res ->
					put(treasure_storage_list,RemainItems),
		   			role_op:auto_create_and_put(ItemProtoId,Count,got_chest),
					move_item_to_packet(Index+1,[{ItemProtoId,Count}|GetItemList]);
	  			true->
		   			ErrorMsgBin = treasure_storage_packet:encode_treasure_storage_opt_s2c(?ERROR_PACKEGE_FULL),
					role_op:send_data_to_gate(ErrorMsgBin),
%%					io:format("move_item_to_packet end ok~n"),
					{Index,GetItemList}
			end
	end.

%%
%%查找可堆叠的位置
%%
%%返回  {位置,对应位置物品信息} 
search_can_additem([],_,_,_,_)->
	{0,[]};
	
search_can_additem(List,Index,ProtoId,Count,MaxStack)->
	[Header|RemainList] = List,
	{_Sign,HProtoId,HCount} = Header,
	if
		HProtoId =:= ProtoId->
			if
				HCount < MaxStack ->	%%可堆叠
					{Index,Header};			
				true->
					{0,[]}
			end;
		true->
			search_can_additem(RemainList,Index+1,ProtoId,Count,MaxStack)
	end.

%%
%%添加物品到仓库
%%返回 {updateinfo,addinfo}
%%updateinfo:{Sign,ItemProtoId,NewCount,Index}
%%addinfo: {ItemProtoId,RemainCount}
%%
add_item_to_storage({ItemProtoId,Count},StorageItemList)->
	TmpTempInfo = item_template_db:get_item_templateinfo(ItemProtoId),	
	MaxStack = item_template_db:get_stackable(TmpTempInfo),	
	if
		MaxStack < 2->	%%不可堆叠
			UpdateInfo = [],
			AddInfo = {ItemProtoId,Count};
		true->
			RevList = lists:reverse(StorageItemList),
			case search_can_additem(RevList,1,ItemProtoId,Count,MaxStack) of			%%从反向第一个位置开始查找
				{0,_}->	%%没有找到
					UpdateInfo = [],
					AddInfo = {ItemProtoId,Count};
				{RevIndex,ItemInfo}->
					{Sign,_,CurCount} = ItemInfo,
					NewCount = erlang:min(CurCount + Count,MaxStack),
					RemainCount = Count - (NewCount - CurCount),
					Index = length(StorageItemList) - RevIndex,
					UpdateInfo = {Sign,ItemProtoId,NewCount,Index},
					AddInfo = 
						if
							RemainCount =:= ?ZERO_COUNT ->
								[];
							true->
								{ItemProtoId,RemainCount}
						end
			end
	end,
	{UpdateInfo,AddInfo}.
	
add_item_and_makemsg(_ItemProtoId,0,_MaxStack,MsgBin)->
	MsgBin;

add_item_and_makemsg(ItemProtoId,RemainCount,MaxStack,MsgBin)->
	Sign = gen_item_id(),
	CurCount = erlang:min(RemainCount,MaxStack),
	NewList = get(treasure_storage_list)++[{Sign,ItemProtoId,CurCount}],
	put(treasure_storage_list,NewList),
	NewMsgBin = [treasure_storage_packet:make_tsi(ItemProtoId,length(NewList),CurCount,Sign)|MsgBin],
	NewRemainCount = RemainCount - CurCount,
	add_item_and_makemsg(ItemProtoId,NewRemainCount,MaxStack,NewMsgBin).



%%将一组物品数据堆叠并返回

array_item([])->
	[];
	
array_item(ItemList) when is_list(ItemList)->
	SortItemList = lists:sort(ItemList),	
	array_item(SortItemList,[],[]);	

array_item(OtherMsg)->
	OtherMsg.


array_item([],LastItem,DestItemList)->
	{LProtoId,LCount} = LastItem,
	TmpTempInfo = item_template_db:get_item_templateinfo(LProtoId),	
	MaxStack = item_template_db:get_stackable(TmpTempInfo),
	if
		MaxStack >= LCount->
			[LastItem|DestItemList];
		true->
			NewLastItem = {LProtoId,LCount - MaxStack},
			NewDestItemList = [{LProtoId,LCount - MaxStack}|DestItemList],
			array_item([],NewLastItem,NewDestItemList)
	end;

array_item(SrcItemList,[],DestItemList)->
	[LastItem|SrcListRemain] = SrcItemList,
	array_item(SrcListRemain,LastItem,DestItemList);

array_item(SrcItemList,LastItem,DestItemList)->
	[HeaderItem|SrcListRemain] = SrcItemList,
	{HProtoId,HCount} = HeaderItem,
	{LProtoId,LCount} = LastItem,
	TmpTempInfo = item_template_db:get_item_templateinfo(LProtoId),	
	MaxStack = item_template_db:get_stackable(TmpTempInfo),
	if
		MaxStack =:= LCount->
			NewDestItemList = [LastItem|DestItemList],
			NewLastItem = HeaderItem,
			NewSrcItemList = SrcListRemain;
		MaxStack < LCount->
			NewDestItemList = [{LProtoId,MaxStack}|DestItemList],
			NewLastItem = {LProtoId,LCount - MaxStack},
			NewSrcItemList = SrcItemList;
		true->
			if
				HProtoId =:= LProtoId ->
					NewDestItemList = DestItemList,
					NewLastItem = {LProtoId,LCount + HCount},
					NewSrcItemList = SrcListRemain;
				true->
					NewDestItemList = [LastItem|DestItemList],
					NewLastItem = HeaderItem,
					NewSrcItemList = SrcListRemain
			end
	end,
	array_item(NewSrcItemList,NewLastItem,NewDestItemList).


%%
%%合并同类物品 
%%srclist 需经过排序
%%
collect_item([],[],[])->
	[];
collect_item(DestList,LastItem,[])->
	[LastItem|DestList];

collect_item(DestList,[],SrcList)->
	SortSrcList = lists:sort(SrcList),
	[Header|RemainList] = SortSrcList,
	collect_item(DestList,Header,RemainList);

collect_item(DestList,LastItem,SrcList)->
	{LastProtoId,LastCount} = LastItem,
	[Header|RemainList] = SrcList,
	{HProtoId,HCount} = Header,
	TmpItemInfo = item_template_db:get_item_templateinfo(LastProtoId),
	StackNum = item_template_db:get_stackable(TmpItemInfo),
	if
		(StackNum>1) and (LastProtoId =:= HProtoId)->
			NewCount = LastCount + HCount,
			NewLastItem = {LastProtoId,NewCount},
			collect_item(DestList,NewLastItem,RemainList);
		true->
			collect_item([LastItem|DestList],Header,RemainList)
	end.
	
		