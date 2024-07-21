%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(item_arrange).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("slot_define.hrl").
-include("item_struct.hrl").

%%{slotnum,itemid,count,templeteid,stackable}
%%Type: storage or package
items_arrange(TypeInt)->
	if
		TypeInt =:=1->
			Type = package,
			PackgeSlotsInfo = package_op:get_package_slots();
		true->
			Type = storage,
			PackgeSlotsInfo = package_op:get_storage_slots()
	end,
	ArrangeSlotsInfoTmp = lists:map(fun({SlotNum,ItemId,Count})->
									if
										ItemId=:=0->
											{0,0,0,0,0,0,0};
										true->
											ItemInfo = items_op:get_item_info_by_pos(Type,ItemId),
											TempleteId = get_template_id_from_iteminfo(ItemInfo),
											Stackable = get_stackable_from_iteminfo(ItemInfo),
											ClassId = get_class_from_iteminfo(ItemInfo),
											Isbond = get_isbonded_from_iteminfo(ItemInfo),
											{SlotNum,ItemId,Count,ClassId,TempleteId,Stackable,Isbond}
									end
								end, PackgeSlotsInfo),
	%%ArrangeSlotsInfo = lists:reverse(lists:keysort(4, ArrangeSlotsInfoTmp)),		%%sort by templateid
	
	%%sort by templateid
	ArrangeSlotsInfo = lists:reverse(lists:sort(fun({_,_,_,ClassId1,TempleteIdTmp1,_,Isbond1},{_,_,_,ClassId2,TempleteIdTmp2,_,Isbond2})->
%%													if
%%														ClassId1< ClassId2->
%%															true;
%%														ClassId1> ClassId2->
%%															false;
%%														true->
															if
																TempleteIdTmp1<TempleteIdTmp2->
																	false;
																TempleteIdTmp1>TempleteIdTmp2->
																	true;
																true->
																	Isbond1=<Isbond2
%%															end
													end end, ArrangeSlotsInfoTmp)),		
	{CountUpdates,NeedDeletes} = items_merge(ArrangeSlotsInfo),
	%%io:format("items_merge CountUpdates ~p  NeedDeletes ~p ~n",[CountUpdates,NeedDeletes]),
	make_all_changes(Type,ArrangeSlotsInfo,CountUpdates,NeedDeletes).
	
make_all_changes(Type,ArrangeSlotsInfo,CountUpdates,NeedDeletes)->
	BeginPos = 
	if
		Type =:= storage->
			TypeInt = 2,
			?SLOT_STORAGES_INDEX+1;
		true->
			TypeInt = 1,
			?SLOT_PACKAGE_INDEX+1
	end,
	AllUpdates = apply_fun(Type,BeginPos,ArrangeSlotsInfo,CountUpdates,NeedDeletes,[]),
	Message =  role_packet:encode_arrange_items_s2c(TypeInt,AllUpdates,NeedDeletes),
	role_op:send_data_to_gate(Message),
	lists:foreach(fun(ItemId)-> 
		items_op:delete_item_from_itemsinfo_by_pos(Type,ItemId),
		gm_logger_role:role_release_item(get(roleid),ItemId,0,0,lost_item_arrange,get(level)) 
  	end, NeedDeletes). 

apply_fun(Type,EndSlot,[],_,_,Result)->
	case Type of
		storage->
			package_op:clear_storage_behind(EndSlot);
		_->	
			package_op:clear_package_behind(EndSlot)
	end,
	Result;

apply_fun(Type,NewSlot,[{Slot,ItemId,Count,_,_,_,_}|T],Updates,NeedDles,Result)->
	if
		Updates=:=[]->
			UpItemId=0,UpCount =0,UpT =[];
		true->
			[{UpItemId,UpCount}|UpT]=Updates
	end,
	if
		NeedDles=:=[]->
			DelItemId=0,DelT =[];
		true->
			[DelItemId|DelT]=NeedDles
	end,
	if
		ItemId =:=0 ->			%%empty slot
			apply_fun(Type,NewSlot,T,Updates,NeedDles,Result);
		true->
			if
				DelItemId=:=ItemId->	%%del
					apply_fun(Type,NewSlot,T,Updates,DelT,Result);
				true-> 					
					if
						NewSlot=/=Slot->		%%slot update
							SlotChange = [role_attr:to_item_attribute({slot,NewSlot})];
						true->
							SlotChange = []
					end,
					if
						UpItemId=:=ItemId->		%%count update
							NewCount = UpCount,
							CountChange = [role_attr:to_item_attribute({count,UpCount})];
						true->
							NewCount = Count,
							CountChange=[]
					end,
					if
						(CountChange=/=[]) or (SlotChange=/=[])-> 
							items_op:set_item_slot_count_by_pos(Type,ItemId,NewSlot,NewCount),
							package_op:set_item_to_slot(NewSlot,ItemId,NewCount),
							ItemChange = [role_attr:to_item_changed_info(get_lowid_from_itemid(ItemId),
										get_highid_from_itemid(ItemId),
									SlotChange++CountChange,[])];
						true->
							ItemChange = []
					end,
					if
						CountChange =/=[]->
							apply_fun(Type,NewSlot+1,T,UpT,NeedDles,ItemChange++Result);
						true ->
							apply_fun(Type,NewSlot+1,T,Updates,NeedDles,ItemChange++Result)
					end
			end
	end.
					
%%return:{Updates,Deltes} Updates:{itemid,count} Deletes:id	
items_merge(ArrangeSlotsInfo)->
	{{LastItemId,LastCount,LastOriCount,_,_},NeedUpdate,NeedDelete} = lists:foldl(fun fun_merge_item/2,{{0,0,0,0,0},[],[]}, ArrangeSlotsInfo),
	if
		(LastItemId=/=0 ) and (LastCount=/= LastOriCount )->
			{NeedUpdate++[{LastItemId,LastCount}],NeedDelete};
		true->
			{NeedUpdate,NeedDelete}
	end.

%%{SlotNum,ItemId,Count,ClassId,TempleteId,Stackable,Isbond}
fun_merge_item({_,ItemId,Count,_,TempleteId,Stackable,Isbond},{LastOne,Updates,Deletes})->
	{LastItemId,LastCount,LastOriCount,LastTmpid,LastIsbond} = LastOne,
	if
		TempleteId=:=0->									%%end
			if
				LastCount=/=LastOriCount->
					{{0,0,0,0,0},Updates++[{LastItemId, LastCount}],Deletes};
				true->
					{{0,0,0,0,0},Updates,Deletes}
			end;
		(LastTmpid=/=TempleteId) or (LastCount>=Stackable) or (LastIsbond=/=Isbond)-> %%cannot stack
			if
				LastCount=/=LastOriCount->
					{{ItemId,Count,Count,TempleteId,Isbond},Updates++[{LastItemId, LastCount}],Deletes};
				true->
					{{ItemId,Count,Count,TempleteId,Isbond},Updates,Deletes}
			end;
		true->							%%can stack
			LeftCount = (LastCount+Count) - Stackable,
			if
				LeftCount=<0->			%%not left	
					{{LastItemId,LastCount+Count,LastOriCount,LastTmpid,LastIsbond},Updates,Deletes++[ItemId]};
				true->					%%has left
					{{ItemId,LeftCount,Count,TempleteId,Isbond},Updates++[{LastItemId,Stackable}],Deletes}
			end
	end.
	
	













