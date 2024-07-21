%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------

-module(package_op).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("slot_define.hrl").
-include("item_struct.hrl").
-define(ATTACK_SLOTS,[?MAINHAND_SLOT,?LFINGER_SLOT,?RFINGER_SLOT,?LARMBAND_SLOT,?RARMBAND_SLOT,?NECK_SLOT]).

-define(DEFENSE_SLOTS,[?HEAD_SLOT,?SHOULDER_SLOT,?GLOVE_SLOT,?BELT_SLOT,?SHOES_SLOT,?CHEST_SLOT]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%										槽位查询操作										%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%查看槽位位置 body/pet_body/package/storage
where_slot(SlotNum)->
	PackSize = get(package_size),
	StorageSize = get(storage_size),
	if
		(SlotNum > ?SLOT_BODY_INDEX) and (SlotNum =< ?SLOT_BODY_ENDEX) -> body;
		(SlotNum > ?SLOT_PET_BODY_INDEX) and (SlotNum =< ?SLOT_PET_BODY_ENDEX) -> pet_body;
		(SlotNum > ?SLOT_PACKAGE_INDEX) and (SlotNum =< ?SLOT_PACKAGE_INDEX+PackSize )  -> package;
		(SlotNum > ?SLOT_STORAGES_INDEX) and (SlotNum =< ?SLOT_STORAGES_INDEX+StorageSize )  -> storage;
		true -> error
	end. 	
	
%%取背包里某个槽位上的物品具体信息,如果不是背包槽,返回[]
get_iteminfo_in_package_slot(SlotNum)->
	case where_slot(SlotNum) of
		package->
			get_iteminfo_in_normal_slot(SlotNum);			
		_->
			[]
	end.

%%检测某槽位上是否有物品
is_has_item_in_slot(SlotNum)->
	get_item_id_in_slot(SlotNum)=/= [].

%%获取物品id/[]	
get_item_id_in_slot(SlotNum)->
	case lists:keyfind(SlotNum,1,get(package)) of
		{SlotNum,0,_} -> [];
		{_,ItemId,_}->
			ItemId;
		false ->
			[]
	end.

%%取背包和装备槽位上的物品具体信息	
get_iteminfo_in_normal_slot(SlotNum)->
	case get_item_id_in_slot(SlotNum) of
		[]->
			[];
		ItemId->
			items_op:get_item_info(ItemId)
	end.	
							
%%取物品id和个数			
get_item_id_and_count_in_slot(SlotNum)->
	case lists:keyfind(SlotNum,1,get(package)) of
		{SlotNum,0,_} -> [];
		{SlotNum,ItemId,Count}->
			{ItemId,Count};
		false ->
			[]
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%										槽位查询结束										%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%package [{Num,itemid,count} %%空格为{Num,0,0}]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_package({PacketNum,StorageNum})->
	put(package_size,PacketNum),
	put(storage_size,StorageNum),
	InitList = lists:seq(?SLOT_BODY_INDEX+1, ?SLOT_BODY_ENDEX) ++ lists:seq(1+?SLOT_PACKAGE_INDEX, ?SLOT_PACKAGE_INDEX+PacketNum) ++ lists:seq(1+?SLOT_STORAGES_INDEX, ?SLOT_STORAGES_INDEX+StorageNum),
	put(package,lists:map(fun(Index)->{Index,0,0}end,InitList)),
	AllItems = get(items_info) ++ get(storages_info),
	lists:foreach(fun({ItemId,ItemInfo,_,_})->		
					if
						is_record(ItemInfo,item_info)->			
							SlotNum = get_slot_from_iteminfo(ItemInfo);
						true->
							SlotNum = playeritems_db:get_slot(ItemInfo)
					end,
					case (where_slot(SlotNum)=:=body) or (where_slot(SlotNum)=:=package)
					of 
						true ->
							Count = get_count_from_iteminfo(ItemInfo),
							set_item_to_slot(SlotNum,ItemId,Count);
						false ->
							case where_slot(SlotNum) of
								storage->
									Count = playeritems_db:get_count(ItemInfo),
									set_item_to_slot(SlotNum,ItemId,Count);
								_->
									nothing
							end
					end
	end,AllItems).

export_for_copy()->
	{get(package_size),get(storage_size),get(package)}.

get_size()->
	{get(package_size),get(storage_size)}.

load_by_copy({PackageSize,StorageSize,PackageInfo})->
	put(storage_size,StorageSize),
	put(package_size,PackageSize),
	put(package,PackageInfo).

clear_storage_behind(StartSlot)->
	lists:foreach(fun({SlotNum,_Itemid,_Count})-> 
		case (SlotNum >= StartSlot) and (where_slot(SlotNum)=:=storage) of
			true->
				del_item_from_slot(SlotNum);
			_->
				nothing
		end
	end,get(package)). 

clear_package_behind(StartSlot)->
	lists:foreach(fun({SlotNum,_Itemid,_Count})-> 
		case (SlotNum >= StartSlot) and (where_slot(SlotNum)=:=package) of
			true->
				del_item_from_slot(SlotNum);
			_->
				nothing
		end
	end,get(package)). 

expand_package(AddSlot)->
	Size = get(package_size),
	NesSize = erlang:min(?MAX_PACKAGE_SLOT,AddSlot + Size), 
	if
		(Size >= ?MAX_PACKAGE_SLOT)->
			error;
		true->
			AddSlots = lists:map( fun(Index)->{Index,0,0}end, lists:seq(Size+?SLOT_PACKAGE_INDEX+1, ?SLOT_PACKAGE_INDEX+NesSize) ),
			put(package,lists:append(get(package),AddSlots)),
			put(package_size,NesSize),
			role_op:only_self_update([{packsize,NesSize}]),
			gm_logger_role:role_expand_package(get(roleid),NesSize,AddSlot),
			ok
	end.

expand_storage(AddSlot)->
	Size = get(storage_size),
	NesSize = erlang:min(?MAX_STORAGE_SLOT,AddSlot + Size), 
	if
		(Size >= ?MAX_STORAGE_SLOT)->
			error;
		true->
			AddSlots = lists:map( fun(Index)->{Index,0,0}end, lists:seq(Size+?SLOT_STORAGES_INDEX+1, ?SLOT_STORAGES_INDEX+NesSize) ),
			put(package,lists:append(get(package),AddSlots)),
			put(storage_size,NesSize),
			role_op:only_self_update([{storagesize,NesSize}]),
			gm_logger_role:role_expand_storage(get(roleid),NesSize,AddSlot),
			ok
	end.


%%背包和身上的所有物品id
get_items_id_on_hands()->
	Items = lists:filter(fun({Num,Itemid,_Count})-> ( (where_slot(Num)=:=body) or (where_slot(Num)=:=package) ) and (Itemid =/= 0) end ,get(package)),
	lists:map(fun({_Num,Itemid,_Count})-> Itemid end,Items).

%%得到身上存在的物品id
get_body_items_id()->
	Items = lists:filter(fun({SlotNum,Itemid,_Count})->
							( where_slot(SlotNum)=:=body ) and (Itemid =/= 0) end ,get(package)),
	lists:map(fun({_Num,Itemid,_Count})-> Itemid end,Items).	

%%得到背包里所有的物品id
get_package_items_id()->
	Items = lists:filter(fun({SlotNum,Itemid,_Count})->
							(where_slot(SlotNum)=:=package) and (Itemid =/= 0) end ,get(package)),
	lists:map(fun({_Num,Itemid,_Count})-> Itemid end,Items).

	

%%根据物品id，获取背包里面的物品 by zhangting
%%返回[{SlotNum,Itemid,Count}]
getSlotsByItemInfo(TmpId)->	
	 lists:filter(fun({SlotNum,Itemid,Count})->
							ItemInfo=get_iteminfo_in_normal_slot(SlotNum),
							if ItemInfo=:=[] ->false;
							true->   
								%%slogger:msg("package_op:getSlotsByItemInfo  ItemInfo: ~p,tmpId:~p ~n",[ItemInfo,element(4,ItemInfo)]),	
								where_slot(SlotNum)=:=package  andalso element(#item_info.template_id,ItemInfo) =:= TmpId
							end
					end ,get(package)).

getSlotsByItemInfo(TmpId,IsBond)->
	StrTmpId = integer_to_list(TmpId),
	TmpIdNew = 
	if IsBond-> list_to_integer( string:substr(StrTmpId, 1,string:len(StrTmpId)-1) ++"1" );
	true->
		 list_to_integer( string:substr(StrTmpId, 1,string:len(StrTmpId)-1) ++"0" )
	end,	 
	getSlotsByItemInfo(TmpIdNew).
                            


%%得到仓库的东西		
get_items_id_on_storage()->
	Items = lists:filter(fun({SlotNum,Itemid,_Count})->
							(where_slot(SlotNum)=:=storage) and (Itemid =/= 0) end ,get(package)),
	lists:map(fun({_Num,Itemid,_Count})-> Itemid end,Items).
			
%%身体槽部分		
get_body_slots()->
	lists:filter(fun({SlotNum,_Itemid,_Count})->
				where_slot(SlotNum)=:=body
			end ,get(package)).

%%背包槽部分
get_package_slots()->
	lists:filter(fun({SlotNum,_Itemid,_Count})->
				where_slot(SlotNum)=:=package
			end ,get(package)).
%%仓库槽
get_storage_slots()->
	lists:filter(fun({SlotNum,_Itemid,_Count})->
							 (where_slot(SlotNum)=:=storage ) end ,get(package)).
						
get_attack_slots()->
	case get(classid) of
		?CLASS_MELEE->
			lists:filter(fun(SlotNum)-> is_has_item_in_slot(SlotNum) end,?ATTACK_SLOTS);
		_->
			lists:filter(fun(SlotNum)-> is_has_item_in_slot(SlotNum) end,[?OFFHAND_SLOT|?ATTACK_SLOTS])			
	end.

get_defence_slots()->
	case get(classid) of
		?CLASS_MELEE->
			lists:filter(fun(SlotNum)-> is_has_item_in_slot(SlotNum) end,[?OFFHAND_SLOT|?DEFENSE_SLOTS]);
		_->
			lists:filter(fun(SlotNum)-> is_has_item_in_slot(SlotNum) end,?DEFENSE_SLOTS)			
	end.

	
%%为保证交易物品的安全,在改变槽的时候要检测是否是交易槽!
set_item_to_slot(SlotNum,ItemId,Count)->
	case trade_role:is_trading_slot(SlotNum) of
		true->
			trade_role:interrupt();
		false->
			nothing
	end,
	put(package,lists:keyreplace(SlotNum,1,get(package),{SlotNum,ItemId,Count})).
	
del_item_from_slot(SlotNum)->
	case trade_role:is_trading_slot(SlotNum) of
		true->
			trade_role:interrupt();
		false->
			nothing
	end,
	put(package,lists:keyreplace(SlotNum,1,get(package),{SlotNum,0,0})).	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	物品与包裹槽位相关	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%获取一个空槽位
%%return [槽位号]/0 
%%0:无空槽位
get_empty_slot_in_package()->
	PackageList = get_package_slots(),
	case lists:keyfind(0,2,PackageList) of
		{SlotNum,0,_}->	
				[SlotNum];
		false ->
				0
	end.

%%获取Num个空槽位
%%return [槽位号]/0 
%%0:无空槽位	
get_empty_slot_in_package(Num)->
	if 
		Num =< 1->
			get_empty_slot_in_package();
		true->
			PackageList = get_package_slots(),
			Empty_slots = lists:foldl(fun({SlotNum,ItemId,_},Slots)->
								case (ItemId =:= 0) and (erlang:length(Slots)<Num )of
									true ->
										Slots ++ [SlotNum]; 
									false->
										Slots
								end end,[],PackageList),		
			case erlang:length(Empty_slots) < Num of
				true ->
					0;
				false->
					Empty_slots
			end
	end.

%%判断当前模板列表里的物品是否能全装入包裹.
%%return true/false
%%TemplateIdList:[{TemplateId,ItemCount}]
can_added_to_package_template_list([])->
	true;
	
can_added_to_package_template_list(OriTemplateIdList)->
	%%合并同类项
	MergedTemplateIdList = 
	lists:foldl(fun({TemplateId,ItemCount},TemplateListTmp)->
			case lists:keyfind(TemplateId,1,TemplateListTmp) of
				false->
					[{TemplateId,ItemCount}|TemplateListTmp];
				{TemplateId,CountTmp}->
					lists:keyreplace(TemplateId,1,TemplateListTmp,{TemplateId,CountTmp+ItemCount})
			end
		end,[],OriTemplateIdList),
	%%计算需要的新槽位	
	NeedNewSlot = 
		lists:foldl(fun({TemplateId,ItemCount},SlotNumTmp)->
			if
				SlotNumTmp=:=-1 ->			%%已无法装入
					SlotNumTmp;
				true->
					case can_added_to_package(TemplateId,ItemCount) of
						0-> 				%%无法装入
							-1;				
						{slot,SlotNums}->
							erlang:length(SlotNums) + SlotNumTmp;
						{both,_StackSlots,Empty_slots}->
							erlang:length(Empty_slots) + SlotNumTmp;
						_->
							SlotNumTmp
					end		 	
			end
		end,0,MergedTemplateIdList),
	if
		NeedNewSlot=:=-1->			%%装不下了
			false;
		NeedNewSlot=:=0->			%%光堆叠就可以装下
			true;	
		true->
			get_empty_slot_in_package(NeedNewSlot)=/=0
	end.	 	

%%判断当前包裹是否还能装入物体0/{slot,SlotNums}/{stack,SlotNums}/{both,StackSlots,Empty_slots}
can_added_to_package(TemplateId,ItemCount)->
	PackageSlot = get_package_slots(),
	TmpTempInfo = item_template_db:get_item_templateinfo(TemplateId),	
	MaxStack = item_template_db:get_stackable(TmpTempInfo),
	case MaxStack < 2 of				
		true ->							%%不可叠加
			case get_empty_slot_in_package(ItemCount) of
				0 -> 0;
				FindSlots -> {slot,FindSlots}
			end;
		false ->						%%可叠加,查找可叠加的槽
			{LeftCountEnd,CanAddSlotsEnd} = lists:foldl(fun({SlotNum,Itemid,Count},{LeftCount,CanAddSlots})->
				case (Itemid =/= 0) and (LeftCount > 0) of
						true ->
							TmpInfo = items_op:get_item_info(Itemid),
							case get_template_id_from_iteminfo(TmpInfo)=:= TemplateId of
								true ->
									if
										 Count < MaxStack->
										 	{LeftCount - (MaxStack - Count),CanAddSlots ++ [SlotNum]};												
										 true->
										 	{LeftCount,CanAddSlots}	
									end;
								false -> {LeftCount,CanAddSlots} 
							end;
						false->
							{LeftCount,CanAddSlots}
				end end,{ItemCount,[]},PackageSlot),
			case CanAddSlotsEnd of
				[]	-> 		%%没找到可叠加的槽
					NeedSlotnum = util:even_div(ItemCount,MaxStack),
					case get_empty_slot_in_package(NeedSlotnum) of
						0 -> 0;
						FindSlots ->
							{slot,FindSlots}
					end;
				_	->		%%有可堆叠的槽
						if
						  LeftCountEnd < 1 ->	{stack,CanAddSlotsEnd};		%%堆叠完了
						  true->			%%未堆叠完,剩下的需要新槽
						  		NeedSlotnum = util:even_div(LeftCountEnd,MaxStack),
						  		case get_empty_slot_in_package(NeedSlotnum) of
									0 -> 0;
									FindSlots ->
										{both,CanAddSlotsEnd,FindSlots}
								end
						end
			end
		
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	物品与包裹槽位相关	end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_counts_by_template_in_package(TempId)->	 
	ItemIds = get_package_items_id(),
	get_count_by_items_id_for_templateid(TempId,ItemIds).

get_counts_by_class_in_package(ClassId)->	 
	ItemIds = get_package_items_id(),
	get_count_by_items_id_for_class(ClassId,ItemIds).

get_counts_onhands_by_template(TempId)->	       
    ItemIds = get_items_id_on_hands(),
	get_count_by_items_id_for_templateid(TempId,ItemIds).

get_count_by_items_id_for_templateid(TempId,ItemIds)->
       S = fun(ItemId)->
			 items_op:is_item_template(ItemId,TempId)
	   end,
      Items = lists:filter(S,ItemIds),	
      F = fun(X,Sum)-> 
			  Item = items_op:get_item_info(X),
			  Count = get_count_from_iteminfo(Item),
			  Count+Sum
	  end,
      lists:foldl(F,0,Items).
      
get_count_by_items_id_for_class(Class,ItemIds)->
	lists:foldl(fun(ItemId,AccNum)->
		case items_op:get_item_info(ItemId) of
			[]->
				AccNum;
			ItemInfo->
				case get_class_from_iteminfo(ItemInfo) of
					Class->
						get_count_from_iteminfo(ItemInfo)+AccNum;
					_->	
						AccNum
				end
		end
	end,0,ItemIds).
	
%%枫少
get_item_count_by_itemid(ItemId,IsBond)->
	StrTmpId = integer_to_list(ItemId),
	TmpIdNew = 
	if IsBond-> list_to_integer( string:substr(StrTmpId, 1,string:len(StrTmpId)-1) ++"1" );
	true->
		 list_to_integer( string:substr(StrTmpId, 1,string:len(StrTmpId)-1) ++"0" )
	end,	 
	get_counts_by_template_in_package(TmpIdNew).

%%根据count检查当前背包中的物品，返回count，和itemlist《枫少》
get_need_item_info(Niteminfo,Count)->
  	lists:foldl(fun(ItemInfo,Acc)->
					{Num,Item}=Acc,
					if Num=:=Count->
						  Acc;
						true->
							case ItemInfo of
									{SlotNum,ItemId,ItemCount}->
											if Num+ItemCount<Count->
													 {Num+ItemCount,Item++[ItemInfo]};
												Num+ItemCount=:=Count->
													 {Count,Item++[ItemInfo]};
												Num+ItemCount>=Count->
													 {Count,Item++[{SlotNum,ItemId,Count-Num}]}
					end  end end end		, {0,[]},Niteminfo).
%%处理客户端物品消耗，和上边函数配合使用
consume_items(Slot,_Id,Num)->
	case package_op:get_iteminfo_in_normal_slot(Slot) of
		[]->
			io:format("error:no those items~n");
		ItemInfo->
			role_op:consume_item(ItemInfo, Num)
	end.
	
clear_package()->%%@@wb20130325清包
lists:foreach(fun({S,_,_})->
					  items_op:lost_from_trad_by_slot(S) end,get_package_slots()).
		
