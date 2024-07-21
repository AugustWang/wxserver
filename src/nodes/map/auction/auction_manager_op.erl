%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(auction_manager_op).
-behaviour(ets_operater_mod).
-export([start/0,create/0,init/0]).
%%
%% Include files
%%

-define(AUCTION_ETS,auction_ets).
-define(STALL_ITEM_ETS,stall_item_ets).

-include("auction_define.hrl").
-include("auction_def.hrl").
-include("error_msg.hrl").
-include("mnesia_table_def.hrl").
-include("string_define.hrl").
-include("item_struct.hrl").
-compile(export_all).

%% auction_ets : {Id,RoleId,RoleName,RoleLevel,NickName,StallItems,CreateTime,Logs}
%% StallItems : [{ItemId,Money}]
%% stall_item_ets {ItemId,SearchName,StallId,#playeritems{ownerid = {stall,RoleId}},Money}
%% Money :  {Silver,Gold,Ticket}

start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?AUCTION_ETS,[ordered_set,named_table,public]),
	ets:new(?STALL_ITEM_ETS,[set,named_table,public]).

init()->
	auction_stall_id_gen:init(),
	load_from_db(),
	FirstWaitTime = 10*60*1000,
	erlang:send_after(FirstWaitTime,self(),over_due_check).
%init()->
%	ets:new(?AUCTION_ETS,[ordered_set,named_table,public]),
%	ets:new(?STALL_ITEM_ETS,[set,named_table,public]),
%	auction_stall_id_gen:init(),
%	load_from_db(),
%	FirstWaitTime = 10*60*1000,
%	erlang:send_after(FirstWaitTime,self(),over_due_check).

%over_due_check_2()->
%	Now = timer_center:get_correct_now(),
%	try
%		NeedDels =  ets:foldl(fun(StallInfo,StallsTmp)->
%		case timer:now_diff(Now, get_stall_by(time,StallInfo)) >= ?ACUTION_OVERDUA_TIME*1000 of
%			true->
%				[get_stall_by(stallid,StallInfo)|StallsTmp];
%			_->
%				StallsTmp
%		end end,[], ?AUCTION_ETS),
%		lists:foreach(fun(StallId)-> proc_overdue_stall(StallId) end,NeedDels)
%	catch
%		E:R->slogger:msg("auction start_over_due_check ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()])
%	end.
%	erlang:send_after(?ACUTION_OVERDUA_CHECK_DURATION,self(),over_due_check).

over_due_check()->%%3月13日写【xiaowu】检查物品和钱币元宝是否过期十分钟刷新
	Now = timer_center:get_correct_now(),
	try
		ets:foldl(fun(StallInfo,StallsTmp)->
					StallId = get_stall_by(stallid,StallInfo),
					Stallitemlists = get_stall_by(items,StallInfo),
					Stallmoneylists = get_stall_by(stallmoney,StallInfo),
					SellerId = get_stall_by(roleid,StallInfo),
					if
						Stallitemlists =:=[]->
							nothing;
						true->							
							lists:foreach(fun(Stallitem)->
											{OriItemId,StallitemsMoney,StallitemsNow,Item_Duration_Type,IndexId} = Stallitem,
											Items_Hour = lists:nth(Item_Duration_Type,[8,24,48]),
											case (timer:now_diff(Now,StallitemsNow)) >= Items_Hour*60*60*1000*1000 of
												true->
													StallItemInfo = get_stall_item_info(OriItemId),
													PlayerItems = get_stall_item_by(playeritem,StallItemInfo),
													send_stall_item_reback(SellerId,[PlayerItems],OriItemId,StallId,[]),
													true;
												_->
													false
											end
										end,Stallitemlists)
					end,
					if
						Stallmoneylists =:= []->
							nothing;
						true->							
							lists:foreach(fun(Stallmoney)->
											{StallmoneyRoleId,StallmoneyItem,StallmoneyMoney,StallmoneyNow,Money_Duration_Type,IndexId} = Stallmoney,
											Money_Hour = lists:nth(Money_Duration_Type,[8,24,48]),
											case timer:now_diff(Now,StallmoneyNow) >= Money_Hour *60*60*1000*1000 of
												true->
													{StallGold,StallValue,StallType,StallSilver} = StallmoneyItem,
													send_stall_money_reback(SellerId,StallSilver,StallGold,StallId,IndexId),
													true;
												_->
													false
											end
										end,Stallmoneylists)
					end,
				  [get_stall_by(stallid,StallInfo)|StallsTmp]
				end,[], ?AUCTION_ETS)
	catch
		E:R->slogger:msg("auction start_over_due_check ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()])
	end,
	erlang:send_after(?ACUTION_OVERDUA_CHECK_DURATION,self(),over_due_check).

%proc_all_auctions_down()->
%	ets:foldl(fun(StallInfo,_)-> proc_overdue_stall(get_stall_by(stallid,StallInfo)) end,[],?AUCTION_ETS),
%	slogger:msg("finish all_auctions_down ~n").

load_from_db()->
	Auctions = auction_db:get_auction_info(),	
	put(end_index,erlang:length(Auctions)),
	lists:map(fun(StallInfo)->
		Id = auction_db:get_id(StallInfo),
		{RoleId,RoleName,RoleLevel} = auction_db:get_roleinfo(StallInfo),
		NickName = auction_db:get_nickname(StallInfo),
		Items = auction_db:get_items(StallInfo),
		Stallmoney = auction_db:get_stallmoney(StallInfo),
		CreateTime = auction_db:get_create_time(StallInfo),
		Logs = auction_db:get_ext(StallInfo),
		auction_stall_id_gen:load_by_db(Id),
		FitlerItems = 
		lists:filter(fun({ItemId,Money,Createtime,Duration_type,IndexId})->
						case playeritems_db:load_item_info(ItemId,RoleId) of
							[]->
								slogger:msg("auction_manager_op playeritems_db:load_item_info error RoleId ~p ItemId ~p ~n",[RoleId,ItemId]),
								false;
							[PlayerItemDb]->
								PlayerItem = items_op:make_playeritem_by_db(PlayerItemDb),
								ItemName =  item_template_db:get_name(item_template_db:get_item_templateinfo(playeritems_db:get_entry(PlayerItem))),
								TruelyItemInfo = PlayerItem#playeritems{ownerguid = RoleId},
								update_item_to_ets(TruelyItemInfo,Id,Money,ItemName),
								true
						end
					end,Items),
		update_stall_to_ets(Id,RoleId,RoleName,RoleLevel,NickName,FitlerItems,Stallmoney,CreateTime,Logs)
	end,Auctions).

get_stall_info(StallId)->
	case ets:lookup(?AUCTION_ETS, StallId) of
		[]->[];
        [StallInfo]-> StallInfo  
	end.

get_stall_item_info(ItemId)->
	case ets:lookup(?STALL_ITEM_ETS, ItemId) of
		[]->[];
        [ItemInfo]-> ItemInfo  
	end.

get_stall_by_role(RoleId)->
  	case ets:match_object(?AUCTION_ETS, {'_',RoleId,'_','_','_','_','_','_','_'}) of
		[]->[];
		[StallInfo]->StallInfo
	end.

get_stall_by_rolename(RoleName)->
  	case ets:match_object(?AUCTION_ETS, {'_','_',RoleName,'_','_','_','_','_','_'}) of
		[]->[];
		[StallInfo]->StallInfo
	end.

update_stall_to_db(Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs)->
	auction_db:save_stall_info(Id,{RoleId,RoleName,RoleLevel},NickName,Items,Stallmoney,CreateTime,Logs).

update_stall_to_ets({Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs})->
	update_stall_to_ets(Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs).

update_stall_to_ets(Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs)->
	try
		ets:insert(?AUCTION_ETS, {Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs})
	catch
		_Error:Reason->
			slogger:msg("add_stall_to_ets error ~p ~n",[Reason]),
			{error,Reason}
	end.

update_item_to_ets(PlayerItemInfo,StallId,Money,ItemName)->
	try
		SearchName = transform_to_search_name(ItemName),
		ets:insert(?STALL_ITEM_ETS, {playeritems_db:get_id(PlayerItemInfo),SearchName,StallId,PlayerItemInfo,Money})
	catch
		_Error:Reason->
			slogger:msg("update_item_to_ets error ~p ~n",[Reason]),
			{error,Reason}
	end.
	
transform_to_search_name(ItemName) when is_binary(ItemName) ->
	unicode:characters_to_list(ItemName,unicode);
transform_to_search_name(ItemName) ->
	BinName = list_to_binary(ItemName),
	unicode:characters_to_list(BinName,unicode).

del_stall(Id)->
	auction_stall_id_gen:recycle_id(Id),
	auction_db:del_stall(Id),
	ets:delete(?AUCTION_ETS,Id).
del_money_stall(Id)->
  	auction_db:del_stall(Id),
	ets:delete(?AUCTION_ETS,Id).
del_item(ItemId)->
	ets:delete(?STALL_ITEM_ETS,ItemId).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		  Stall overdue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%proc_overdue_stall(StallId)->
%	StallInfo = get_stall_info(StallId),
%	StallItems = get_stall_by(items,StallInfo),
%	SellerId = get_stall_by(roleid,StallInfo),
%	PlayerItems = lists:map(fun({ItemId,_})->
%				StallItemInfo = get_stall_item_info(ItemId),
%				get_stall_item_by(playeritem,StallItemInfo)
%			end,StallItems), 
%	send_by_step(?REBACK_ITEM_NUM_ONCE_MAIL,SellerId,PlayerItems),
%	del_stall(StallId).

%send_by_step(_,_,[])->
%	nothing;
%send_by_step(Len,SellerId,PlayerItems)->
%	case length(PlayerItems) > Len of
%		true->
%			{FrontL,LeftL}= lists:split(Len, PlayerItems),
%			send_stall_item_reback(SellerId,FrontL),
%			send_by_step(Len,SellerId,LeftL);
%		_->
%			send_stall_item_reback(SellerId,PlayerItems)
%	end.

send_stall_item_reback(SellerId,PlayerItems,ItemId,StallId,Log)->
	StallInfo = get_stall_info(StallId),
	Stallmoney = get_stall_by(stallmoney,StallInfo),
	{From,Title,Body} = make_overdue_mail_body(),
	case mail_op:auction_send_by_playeritems(From,SellerId,Title,Body,PlayerItems,0,0) of
		{ok}->
			case proc_delete_item(StallId,SellerId,ItemId,StallInfo,Log) of
				delete ->
					if Stallmoney =:= []->
						   del_stall(StallId);
					   true ->
						   nothing
					end;
				_ ->
					nothing
			end;
			%lists:foreach(fun(PlayerItem)-> ItemId = playeritems_db:get_id(PlayerItem),del_item(ItemId) end,PlayerItems);
		_->
			slogger:msg("send_stall_item_reback mail PlayerItems ~p error ~n",[PlayerItems])
	end.

send_stall_money_reback(SellerId,Add_Silver,Add_Gold,StallId,IndexId)->
	StallInfo = get_stall_info(StallId),
	StallItems = get_stall_by(items,StallInfo),
	{From,Title,Body} = make_overdue_mail_body(),
	case mail_op:auction_send_by_playeritems(From,SellerId,Title,Body,[],Add_Silver,Add_Gold) of
		{ok}->
			case proc_delete_money(StallId,SellerId,StallInfo,IndexId) of
				delete ->
					if StallItems =:= []->
						   del_stall(StallId);
					   true ->
						   nothing
					end;
				_ ->
					nothing
			end;
		_->
			slogger:msg("send_stall_money_reback mail Money ~p~p error ~n",[Add_Silver,Add_Gold])
	end.
%reback_item_to_role(RoleIds) when is_list(RoleIds)->
%	lists:foreach(fun(RoleId)-> reback_item_to_role(RoleId) end,RoleIds);

%reback_item_to_role(RoleId)->
%	{From,Title,Body} = make_overdue_mail_body(),
%	TableName = db_split:get_owner_table(playeritems, RoleId),
%	AllAuctionItems = loadrole({stall,RoleId},TableName),							   
% 	lists:foreach(fun(PlayerItemDb)->
%						ItemId = element(2,PlayerItemDb),
%						NewPlayerItem = setelement(1,PlayerItemDb,playeritems),
%						case get_stall_item_info(ItemId) of
%							[]->
%								%%send mail to role
%								 mail_op:auction_send_by_playeritems(From,RoleId,Title,Body,[NewPlayerItem],0,0);
%							_->
%								nothing
%						end
%				end,AllAuctionItems).
	
%loadrole(Ownerguid,TableName)->
%	case dal:read_index_rpc(TableName, Ownerguid, 3) of
%		{ok,ItemsRecordList}-> ItemsRecordList;
%		{failed,_Reason}-> [];
%		{failed,badrpc,_Reason}-> []
%	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		  Stall search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

apply_paimai_search_by_sort(RoleId,Subsortkey,Sortkey,Levelsort,Index,Mainsort,Moneysort)->%%3月5日写【小五】（左侧搜索）
	{ItemsOri,TotalmoneyInfo} = proc_paimai_item_search(Subsortkey,Sortkey),
	make_and_send_paimai_search_result(RoleId,ItemsOri,TotalmoneyInfo,Index).
	
proc_paimai_item_search(Subsortkey,Sortkey)->%%3月5日写【小五】（左侧过滤）
	{ItemsOri0,Totalnum} = ets:foldl(fun(ItemsTmp,{OriList,TableIndex})->
											{[ItemsTmp|OriList],TableIndex+1}
										end,{[],0}, ?STALL_ITEM_ETS),
	ItemsOri1 = lists:reverse(ItemsOri0),
	{TotalmoneyInfo0,TotalStallnum} = 
	ets:foldl(fun(StallTmp,{StallList,StallIndex})->
					{get_stall_by(stallmoney,StallTmp)++StallList,StallIndex+1}
				end,{[],0}, ?AUCTION_ETS),
	TotalmoneyInfo = lists:reverse(TotalmoneyInfo0),	
	case Sortkey of   
		?AUCTION_ITEM_TYPE_WEAPON ->
			{FSubsortkey,Fen} = lists:nth((Subsortkey+1),[{0,0},{3,1},{3,24},{2,1},{2,2},{1,1},{1,2}]),
			ItemsOri = lists:filter(fun(ItemInfo)->
									PlayerItem = get_stall_item_by(playeritem,ItemInfo),
									Template_Id = playeritems_db:get_entry(PlayerItem),
									Template_Info = item_template_db:get_item_templateinfo(Template_Id),
									Class = item_template_db:get_clase(Template_Info),
									Allowableclass = item_template_db:get_allowableclass(Template_Info),
									Bool = lists:member(Class,[1,2,24]),
									if
										(Bool =:= true) and (((Class =:= Fen) or (Fen =:= 0))and((Allowableclass =:= FSubsortkey)or(FSubsortkey =:= 0)))->
											true;
										true->
											false
									end
								end,ItemsOri1),
			{ItemsOri,[]};
		?AUCTION_ITEM_TYPE_ARMOR ->
			FSubsortkey = lists:nth((Subsortkey+1),[0,5,3,4,7,6,8]),	
			ItemsOri = lists:filter(fun(ItemInfo)->
									PlayerItem = get_stall_item_by(playeritem,ItemInfo),
									Template_Id = playeritems_db:get_entry(PlayerItem),
									Template_Info = item_template_db:get_item_templateinfo(Template_Id),
									Class = item_template_db:get_clase(Template_Info),
									Bool = lists:member(Class,[5,3,4,7,6,8]),
									if
										(Bool =:= true) and ((Class =:= FSubsortkey) or (FSubsortkey =:= 0))->
											true;
										true->
											false
									end
								end,ItemsOri1),
			{ItemsOri,[]};
		?AUCTION_ITEM_TYPE_ORNAMENT ->
			FSubsortkey = lists:nth((Subsortkey+1),[0,9,10,11]),
			ItemsOri = lists:filter(fun(ItemInfo)->
									PlayerItem = get_stall_item_by(playeritem,ItemInfo),
									Template_Id = playeritems_db:get_entry(PlayerItem),
									Template_Info = item_template_db:get_item_templateinfo(Template_Id),
									Class = item_template_db:get_clase(Template_Info),
									Bool = lists:member(Class,[9,10,11]),
									if
										(Bool =:= true) and ((Class =:= FSubsortkey) or (FSubsortkey =:= 0))->
											true;
										true->
											false
									end
								end,ItemsOri1),
			{ItemsOri,[]};
		?AUCTION_ITEM_TYPE_FORGE_PROP ->
			{FSubsortkey1,FSubsortkey2,FSubsortkey3} = lists:nth((Subsortkey+1),[{0,0,0},{19,20,102},{47,46,46},{101,101,101},{42,42,42}]),
			ItemsOri = lists:filter(fun(ItemInfo)->
									PlayerItem = get_stall_item_by(playeritem,ItemInfo),
									Template_Id = playeritems_db:get_entry(PlayerItem),
									Template_Info = item_template_db:get_item_templateinfo(Template_Id),
									Class = item_template_db:get_clase(Template_Info),
									Bool = lists:member(Class,[19,20,42,46,47,101,102]),
									if
										(Bool =:= true) and ((Class =:= FSubsortkey1) or (Class =:= FSubsortkey2) or (Class =:= FSubsortkey3) or ({FSubsortkey1,FSubsortkey2,FSubsortkey3} =:= {0,0,0}))->
											true;
										true->
											false
									end
								end,ItemsOri1),
			{ItemsOri,[]};
		?AUCTION_ITEM_TYPE_PUNCH_INLAY ->
			FSubsortkey = lists:nth((Subsortkey+1),[21,15,45]),
			ItemsOri = lists:filter(fun(ItemInfo)->
									PlayerItem = get_stall_item_by(playeritem,ItemInfo),
									Template_Id = playeritems_db:get_entry(PlayerItem),
									Template_Info = item_template_db:get_item_templateinfo(Template_Id),
									Class = item_template_db:get_clase(Template_Info),
									Bool = lists:member(Class,[21,15,45]),
									if
										(Bool =:= true) and ((Class =:= FSubsortkey) or (FSubsortkey =:= 0))->
											true;
										true->
											false
									end
								end,ItemsOri1),
			{ItemsOri,[]};
		?AUCTION_ITEM_TYPE_PET_PROP ->
			FSubsortkeylist = lists:nth((Subsortkey+1),[[],[120,121,123],[127,128,129],[0],[124,125,126],[51,52,122,131,132,133]]),
			ItemsOri = lists:filter(fun(ItemInfo)->
									PlayerItem = get_stall_item_by(playeritem,ItemInfo),
									Template_Id = playeritems_db:get_entry(PlayerItem),
									Template_Info = item_template_db:get_item_templateinfo(Template_Id),
									Class = item_template_db:get_clase(Template_Info),
									Bool0 = lists:member(Class,[120,121,123,127,128,129,124,125,126,51,52,122,131,132,133]),
									Bool = lists:member(Class,FSubsortkeylist),
									if
										(Bool0 =:= true) and ((Bool =:= true)or(FSubsortkeylist =:= []))->
											true;
										true->
											false
									end
								end,ItemsOri1),
			{ItemsOri,[]};
		?AUCTION_ITEM_TYPE_REFINE_MATERIAL ->
			ItemsOri = lists:filter(fun(ItemInfo)->
									PlayerItem = get_stall_item_by(playeritem,ItemInfo),
									Template_Id = playeritems_db:get_entry(PlayerItem),
									Template_Info = item_template_db:get_item_templateinfo(Template_Id),
									Class = item_template_db:get_clase(Template_Info),
									if
										(Class =:=46) or (Class =:= 107) or (Class =:= 42)->
											true;
										true->
											false
									end
								end,ItemsOri1),
			{ItemsOri,[]};
		?AUCTION_ITEM_TYPE_MEDICINE ->
			ItemsOri = lists:filter(fun(ItemInfo)->
									PlayerItem = get_stall_item_by(playeritem,ItemInfo),
									Template_Id = playeritems_db:get_entry(PlayerItem),
									Template_Info = item_template_db:get_item_templateinfo(Template_Id),
									Class = item_template_db:get_clase(Template_Info),
									if
										(Class =:=79) or (Class =:= 80)->
											true;
										true->
											false
									end
								end,ItemsOri1),
			{ItemsOri,[]};
		?AUCTION_ITEM_TYPE_TOKEN ->
			ItemsOri = lists:filter(fun(ItemInfo)->
									PlayerItem = get_stall_item_by(playeritem,ItemInfo),
									Template_Id = playeritems_db:get_entry(PlayerItem),
									Bool = lists:member(Template_Id,[15000010,15000050,15000060,19000270,19000690,19000710,19010541,19030010,19010900,19250530]),
									if
										Bool =:= true ->
											true;
										true->
											false
									end
								end,ItemsOri1),
			{ItemsOri,[]};
		?AUCTION_ITEM_TYPE_OTHER ->
			ItemsOri = lists:filter(fun(ItemInfo)->
									PlayerItem = get_stall_item_by(playeritem,ItemInfo),
									Template_Id = playeritems_db:get_entry(PlayerItem),
									Template_Info = item_template_db:get_item_templateinfo(Template_Id),
									Class = item_template_db:get_clase(Template_Info),
									if
										(Class =:=0)->
											true;
										true->
											false
									end
								end,ItemsOri1),
			{ItemsOri,[]};
		?AUCTION_ITEM_TYPE_MONEY ->
			FTotalmoneyInfo = lists:filter(fun(StallMoney)->
											{_,{_,_,Type,_},_,_,_,_} = StallMoney,
											if
												(Type =:= Subsortkey) or (Subsortkey =:= 0)->
													true;
												true->
													false
											end
										end,TotalmoneyInfo),
			{[],FTotalmoneyInfo}
	end.

apply_paimai_search_by_string(RoleId,Levelsort,Str,Index,Mainsort,Moneysort)->%%3月6日写【小五】（下面搜索）
	{AllStallItems,StallItemsLength} = proc_paimai_item_search(Str),
	make_and_send_paimai_search_result(RoleId,AllStallItems,[],Index).

apply_paimai_search_by_grade(RoleId,Levelsort,Index,Allowableclass,Mainsort,Levelgrade,Moneysort,Qualitygrade)->%%3月7日写【小五】（上面搜索）
	{TotalmoneyInfo0,TotalStallnum} = ets:foldl(fun(StallTmp,{StallList,StallIndex})->
													{get_stall_by(stallmoney,StallTmp)++StallList,StallIndex+1}
												end,{[],0}, ?AUCTION_ETS),
	TotalmoneyInfo = lists:reverse(TotalmoneyInfo0),
	AllStallItems = proc_paimai_item_search_by_grade(Allowableclass,Levelgrade,Qualitygrade),
	if 
		%(Allowableclass =:= 0) and (Levelgrade =:= 0) and (Qualitygrade =:= 0)->
		((Levelgrade =:= 0) or (Levelgrade =:=1)) and(Qualitygrade =:= 5)->
			StallmoneyList = TotalmoneyInfo;
		true ->
			StallmoneyList = []
	end,
	make_and_send_paimai_search_result(RoleId,AllStallItems,StallmoneyList,Index).
	
proc_paimai_item_search_by_grade(Allowableclass,Levelgrade,Qualitygrade)->%%3月7日写【小五】（上面过滤）
	{ItemsOri0,Totalnum} = ets:foldl(fun(ItemsTmp,{OriList,TableIndex})->
											{[ItemsTmp|OriList],TableIndex+1}
										end,{[],0}, ?STALL_ITEM_ETS),
	ItemsOri1 = lists:reverse(ItemsOri0),
	Stall_Allowableclass = lists:nth((Allowableclass+1),[0,3,2,1]),
	{Low_Level,High_Level} = lists:nth((Levelgrade+1),[{0,100},{0,9},{10,19},{20,29},{30,39},{40,49},{50,59},{60,69},{70,79},{80,89},{90,99}]),
	ItemsOri = lists:filter(fun(ItemInfo)->
									PlayerItem = get_stall_item_by(playeritem,ItemInfo),
									Template_Id = playeritems_db:get_entry(PlayerItem),
									Template_Info = item_template_db:get_item_templateinfo(Template_Id),
									StallClass = item_template_db:get_allowableclass(Template_Info),
									Item_Level = item_template_db:get_level(Template_Info),
									Item_Qualty = item_template_db:get_qualty(Template_Info),
									if
										((StallClass =:= Stall_Allowableclass) or (Stall_Allowableclass =:= 0)or(StallClass =:= 0)) and ((Item_Level =<High_Level)and(Item_Level >= Low_Level)) and ((Item_Qualty =:= (Qualitygrade))or(Qualitygrade =:= 5))->
											true;
										true->
											false
									end
								end,ItemsOri1).

proc_paimai_item_search(Str)->
	AllStallItemsNoSort = lists:reverse(proc_stalls_search_by_itemstr(Str)),
	AllStallItems = 
	lists:sort(fun(StallItemTmp1,StallItemTmp2)->serch_item_sort_fun(StallItemTmp1,StallItemTmp2) end, AllStallItemsNoSort),
	StallItemsLength = length(AllStallItems),
	{AllStallItems,StallItemsLength}.

get_indexid_from_list(WillFindtuple,AnyList)->
	Acc1 = lists:foldl(fun(Atuple,Acc)->
					if
						(Atuple =:= WillFindtuple)->
							Acc;							
						true ->
							Acc+1
					end
				end,1,AnyList).

make_and_send_paimai_search_result(RoleId,ItemsOri,TotalmoneyInfo,Index)->%%3月5日写【小五】（制作搜索结果并发送）
	if 
		(ItemsOri =:= [])->
			{Searchitems,Acc1} = {[],0};   
		true ->
			{Searchitems,Acc1} = lists:mapfoldl(fun(ItemInfo,Acc)->
														PlayerItem = get_stall_item_by(playeritem,ItemInfo),
														Itemnum = playeritems_db:get_count(PlayerItem),
														Stallid = get_stall_item_by(stallid,ItemInfo),
														StallInfo = get_stall_info(Stallid),
														StallItems = get_stall_by(items,StallInfo),
														ItemId = get_stall_item_by(itemid,ItemInfo),
														Indexid = get_indexid_from_Stallitems(lists:keyfind(ItemId,1,StallItems)),
														Ownerid = get_stall_by(roleid,StallInfo),
														{Silver,Gold,Ticket} = get_stall_item_by(money,ItemInfo),
														StallItem = role_packet:make_item_by_playeritem(PlayerItem),
														Item = auction_packet:make_paimai_item_siv(StallItem,Silver,Gold,0,Indexid),
														Isonline = case role_pos_util:is_role_online(Ownerid) of
																		true->
																			1;
																		_->
																			0
																	end,
														Ownername = get_stall_by(rolename,StallInfo),
														{auction_packet:make_paimai_item_ssiv(Itemnum,Ownerid,Item,Stallid,Isonline,Ownername),Acc+1}
												end,0,ItemsOri)
	end,
	
	if 
		(TotalmoneyInfo =:=[]) ->
			{Searchmoney,Acc3} = {[],0};
		true ->
			{Searchmoney,Acc3} = lists:mapfoldl(fun({RoleId,{Gold,Value,Type,Silver},{Silver,Gold,Ticket},Createtime,Duration_type,IndexId},Acc2)->
														StallInfo = get_stall_by_role(RoleId),
														Money = auction_packet:make_paimai_item_sm(Value,Silver,Gold,Type,IndexId),
														Ownerid = RoleId,
														Stallid = get_stall_by(stallid,StallInfo),
														Itemnum = 1,
														Isonline = case role_pos_util:is_role_online(Ownerid) of
																				true->
																					1;
																				_->
																					0
																	end,
														Ownername = get_stall_by(rolename,StallInfo),
														{auction_packet:make_paimai_item_ssm(Money,Ownerid,Itemnum,Stallid,Isonline,Ownername),Acc2+1}
												end,0,TotalmoneyInfo)
	end,
	if
		Searchitems =:= []->
			if
				Searchmoney =:= []->
					Searchitemsresult = [],
					Searchmoneyresult = [];
				true ->
					Searchitemsresult = [],
					Searchmoneyresult =  lists:sublist(Searchmoney,Index,6)
			end;
		true ->
			if
				Searchmoney =:= [] ->
					Searchitemsresult = lists:sublist(Searchitems,Index,6),
					Searchmoneyresult = [];
				true ->
					if
						(Acc1 - Index + 1) > 0->
							if
								(Acc1 - Index + 1) >= 6 ->
									Searchitemsresult = lists:sublist(Searchitems,Index,6),
									Searchmoneyresult = [];
								true ->
									Searchitemsresult = lists:sublist(Searchitems,Index,6),
									Searchmoneyresult =  lists:sublist(Searchmoney,1,(6 -(Acc1 - Index + 1)))
							end;
						true ->
							if 
								((Index -Acc1 - 1) < 6)->
									if 
										(Index -Acc1 - 1) =:= 0->
											Searchitemsresult = [],
											Searchmoneyresult =  lists:sublist(Searchmoney,1,6);
										true ->
											Searchitemsresult = [],
											Searchmoneyresult =  lists:sublist(Searchmoney,((Acc1+Acc3)-Index + 2),(6 -(Index - Acc1 - 1)))
									end;
								true ->
									Searchitemsresult = [],
									Searchmoneyresult =  lists:sublist(Searchmoney,((Acc1+Acc3)-Index+2),Index,6)
							end
					end
			end
	end,
	Msg = auction_packet:encode_paimai_search_item_s2c((Acc1+Acc3),Index,Searchitemsresult,Searchmoneyresult),
	role_pos_util:send_to_role_clinet(RoleId,Msg).

%apply_stalls_search(RoleId,?ACUTION_SERCH_TYPE_ALL,_Str,Index)->
%	{StallResult,TotalNum} = proc_stalls_search(?ACUTION_SERCH_TYPE_ALL,Index),
%	Stalls = 
%	lists:map(fun(StallInfo)->
%			auction_packet:make_stall_base_info(
%					get_stall_by(stallid,StallInfo),
%					get_stall_by(stallname,StallInfo),
%					get_stall_by(roleid,StallInfo),
%					get_stall_by(rolename,StallInfo),
%					get_stall_by(rolelevel,StallInfo),
%					length(get_stall_by(items,StallInfo)))					  
%		end, StallResult),
%	Msg = auction_packet:encode_stalls_search_s2c(Index,TotalNum,Stalls),
%	role_pos_util:send_to_role_clinet(RoleId,Msg);

%apply_stalls_search(RoleId,?ACUTION_SERCH_TYPE_ITEMNAME,[],Index)->
%	apply_stalls_search(RoleId,?ACUTION_SERCH_TYPE_ALL,[],Index);
%apply_stalls_search(RoleId,?ACUTION_SERCH_TYPE_ITEMNAME,Str,Index)->
%	{StallItems,TotalNum} = proc_stalls_search(?ACUTION_SERCH_TYPE_ITEMNAME,Str,Index),
%	StallItemsSend = 
%	lists:map(fun(StallItemInfo)->
%			StallId = get_stall_item_by(stallid,StallItemInfo),
%			StallInfo = get_stall_info(StallId),
%			Ownerid = get_stall_by(roleid,StallInfo),
%			{Silver,Gold,Ticket} = get_stall_item_by(money,StallItemInfo),
%			SendItem = role_packet:make_item_by_playeritem(get_stall_item_by(playeritem,StallItemInfo)),
%			IsOnline = 
%			case role_pos_util:is_role_online(Ownerid) of
%				true->
%					1;
%				_->
%					0
%			end,
%			auction_packet:make_serch_item_info(SendItem,Silver,Gold,Ticket,StallId,Ownerid,get_stall_by(rolename,StallInfo),length(get_stall_by(items,StallInfo)),IsOnline)
%		end, StallItems),
%	Msg = auction_packet:encode_stalls_search_item_s2c(Index,TotalNum,lists:reverse(StallItemsSend)),
%	role_pos_util:send_to_role_clinet(RoleId,Msg).


%%{Stalls,TotalNum}
%proc_stalls_search(?ACUTION_SERCH_TYPE_ALL,Index)->
%	{StallsOri,TotalNum} = 
%	ets:foldl(fun(StallTmp,{OriList,TableIndex})->
%			NowTableIndex = TableIndex+1,
%			if
%				(NowTableIndex >= Index ) and (NowTableIndex < Index+?ACUTION_SERCH_RECORD_NUM)->
%					{[StallTmp|OriList],TableIndex+1};
%				true->
%					{OriList,NowTableIndex}
%			end end,{[],0}, ?AUCTION_ETS),
%	{lists:reverse(StallsOri),TotalNum}.

%%{StallItems,TotalNum}
%proc_stalls_search(?ACUTION_SERCH_TYPE_ITEMNAME,Str,Index)->
%	AllStallItemsNoSort = lists:reverse(proc_stalls_search_by_itemstr(Str)),
%	AllStallItems = 
%	lists:sort(fun(StallItemTmp1,StallItemTmp2)->serch_item_sort_fun(StallItemTmp1,StallItemTmp2) end, AllStallItemsNoSort),
%	StallItemsLength = length(AllStallItems),
%	if
%		StallItemsLength >= Index-> 
%			SendStallItems = lists:sublist(AllStallItems,Index,?ACUTION_SERCH_ITEM_RECORD_NUM);
%		true->
%			SendStallItems = []
%	end,
%	{SendStallItems,StallItemsLength}.

proc_stalls_search_by_itemstr(Str)->
	SeachStr = transform_to_search_name(Str),
	ets:foldl(fun(StallItemInfo,StallsItemTmp)->
		ItemName = get_stall_item_by(searchname,StallItemInfo),
		case list_util:is_part_of(SeachStr,ItemName) of
			true->
				[StallItemInfo|StallsItemTmp];
			false->
				StallsItemTmp
	end end,[], ?STALL_ITEM_ETS).

serch_item_sort_fun(StallItemTmp1,StallItemTmp2)->
	PlayerItem1 = get_stall_item_by(playeritem,StallItemTmp1),
	PlayerItem2 = get_stall_item_by(playeritem,StallItemTmp2),
	ItemTemplate1 = playeritems_db:get_entry(PlayerItem1),
	ItemTemplate2 = playeritems_db:get_entry(PlayerItem2),
	if
		ItemTemplate1< ItemTemplate2->
			true;
		ItemTemplate1>ItemTemplate2->
			false;
		true->
			{Silver1,Gold1,_Ticket1} = get_stall_item_by(money,StallItemTmp1),
			{Silver2,Gold2,_Ticket2} = get_stall_item_by(money,StallItemTmp2),
			if
				Gold1<Gold2->
					true;
				Gold1>Gold2->
					false;
				true->
					if
						Silver1=<Silver2->
							true;
						true->
							false
					end
			end
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		  Stall Details Look Up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
apply_paimai_myself(RoleId,DefaultStallName)->%%2月22日加【xiaowu】
	case get_stall_by_role(RoleId) of
		[]->
			Msg = auction_packet:encode_paimai_detail_s2c(RoleId,0,DefaultStallName,[],[],1,[]),
			role_pos_util:send_to_role_clinet(RoleId, Msg);
		StallInfo->
			send_detail_by_paimai_info(RoleId,StallInfo)
	end.	

apply_stall_detail(RoleId,StallId)->
	update_stall_items_to_role(RoleId,StallId).

apply_stall_detail_by_rolename(RoleId,RoleName)->
	RoleNameBin = list_to_binary(RoleName),
	case get_stall_by_rolename(RoleNameBin) of
		[]->
			role_pos_util:send_to_role_clinet(RoleId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_ERROR_ID));
		StallInfo->
			send_detail_by_paimai_info(RoleId,StallInfo)
	end.	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				Stall Name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
apply_stall_rename(RoleId,StallName)->
	case get_stall_by_role(RoleId) of
		[]->
			nothing;
		StallInfo->
			RoleId = get_stall_by(roleid,StallInfo),
			RoleName = get_stall_by(rolename,StallInfo),
			RoleLevel = get_stall_by(rolelevel,StallInfo),
			StallItems = get_stall_by(items,StallInfo),
			Stallmoney = get_stall_by(stallmoney,StallInfo),
			Logs = get_stall_by(log,StallInfo),
			StallId = get_stall_by(stallid,StallInfo),
			CreateTime = get_stall_by(time,StallInfo),
			update_stall_to_ets(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,CreateTime,Logs),
			update_stall_to_db(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,CreateTime,Logs)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		  Stall Item Up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_stall_items_to_role(RoleId,StallId)->
	case get_stall_info(StallId) of
		[]->
			role_pos_util:send_to_role_clinet(RoleId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_ERROR_ID));
		StallInfo->
			send_detail_by_paimai_info(RoleId,StallInfo)
	end.

send_detail_by_paimai_info(RoleId,StallInfo)->
	ItemAndMoneys =  get_stall_by(items,StallInfo),
	Stallmoneys = get_stall_by(stallmoney,StallInfo),
	Logs = get_stall_by(log,StallInfo),
	StallId = get_stall_by(stallid,StallInfo),
	Ownerid = get_stall_by(roleid,StallInfo),
	Stallname = get_stall_by(stallname,StallInfo),
	IsOwnerOnline = 
		case role_pos_util:is_role_online(Ownerid) of
			true->
				1;
			_->
				0
		end,
	{Stallitems,Acc1} = lists:mapfoldl(fun({ItemId,{Silver,Gold,Ticket},ItemCreatetime,Duration_type,IndexId},Acc)->
											StallItemInfo = get_stall_item_info(ItemId),		   
											PlayerItem = get_stall_item_by(playeritem,StallItemInfo),
											StallItem = role_packet:make_item_by_playeritem(PlayerItem),									
											{auction_packet:make_paimai_item_siv(StallItem,Silver,Gold,0,IndexId),Acc+1}
										end,1,ItemAndMoneys),
	{Stallmoney,Acc2} = lists:mapfoldl(fun({RoleId,{Gold,Value,Type,Silver},{Silver,Gold,Ticket},MoneyCreatetime,Duration_type,IndexId},Acc1)->						   
											{auction_packet:make_paimai_item_sm(Value,Silver,Gold,Type,IndexId),Acc1+1}
										end,Acc1, Stallmoneys),
	Msg = auction_packet:encode_paimai_detail_s2c(Ownerid,StallId,Stallname,Stallitems,Logs,IsOwnerOnline,Stallmoney),
	role_pos_util:send_to_role_clinet(RoleId, Msg).

%%return stallid
proc_create_stall(RoleId,RoleName,RoleLevel,StallName,OriStallItem)->
	case auction_stall_id_gen:gen_id() of
		[]->
			[];
		NewIndex->
			put(end_index,NewIndex),
			Now = timer_center:get_correct_now(),
			update_stall_to_ets(NewIndex,RoleId,RoleName,RoleLevel,StallName,[OriStallItem],[],Now,[]),
			update_stall_to_db(NewIndex,RoleId,RoleName,RoleLevel,StallName,[OriStallItem],[],Now,[]),  %%todo async save
			NewIndex
	end.


proc_item_upstall(RoleId,StallId,PlayerItem,Money,ItemName)->
	update_item_to_ets(PlayerItem,StallId,Money,ItemName),
	update_stall_items_to_role(RoleId,StallId).
				
apply_up_stall({RoleId,RoleName,RoleLevel},{PlayerItem,Money,StallName,ItemName,Duration_type})->%%[xiaowu](上架物品)
	OriItemId = playeritems_db:get_id(PlayerItem),
	Now = timer_center:get_correct_now(),
	case get_stall_by_role(RoleId) of
		[]->					%%new stall
			case proc_create_stall(RoleId,RoleName,RoleLevel,StallName,{OriItemId,Money,Now,Duration_type,1}) of
				[]->
					error;
				StallId->
					proc_item_upstall(RoleId,StallId,PlayerItem,Money,ItemName),
					ok
			end;
		StallInfo->	
			StallId = get_stall_by(stallid,StallInfo),
			OriItems = get_stall_by(items,StallInfo),
			if
				OriItems =:= [] ->
					IndexId = 1;
				true ->
					IndexId = get_indexid_from_Stallitems(lists:last(OriItems))+1
			end,						
			Stallmoney = get_stall_by(stallmoney,StallInfo),
			case lists:keymember(OriItemId, 1, OriItems) of
				false->
					StallItems = OriItems ++ [{OriItemId,Money,Now,Duration_type,IndexId}],
					Logs = get_stall_by(log,StallInfo),
					case (length(StallItems)+ length(Stallmoney))> ?ACUTION_ITEMS_MAXNUM of
						true->
							error;
						_->
							update_stall_to_ets(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,Now,Logs),
							update_stall_to_db(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,Now,Logs),  %%todo async save
							proc_item_upstall(RoleId,StallId,PlayerItem,Money,ItemName),
							ok
					end;
				true->
					ok
			end
	end.


apply_up_money_stall({RoleId,RoleName,RoleLevel},{PlayerItem,Money,StallName,ItemName,Duration_type})->%%【xiaowu】上架钱币或元宝
	Now = timer_center:get_correct_now(),
	case get_stall_by_role(RoleId) of
		[]->					%%new stall
			case proc_create_money_stall(RoleId,RoleName,RoleLevel,StallName,{RoleId,PlayerItem,Money,Now,Duration_type,1}) of
				[]->
					error;
				StallId->
					%update_item_to_ets(PlayerItem,StallId,Money,ItemName),
					%update_stall_items_to_role(RoleId,StallId),
					ok
			end;
		StallInfo->	
			StallId = get_stall_by(stallid,StallInfo),
			StallItems = get_stall_by(items,StallInfo),
			Stallmoney1 = get_stall_by(stallmoney,StallInfo),
			if
				Stallmoney1 =:= [] ->
					IndexId = 1;
				true ->
					IndexId = get_indexid_from_stallmoney(lists:last(Stallmoney1))+1
			end,			
			Stallmoney = Stallmoney1 ++ [{RoleId,PlayerItem,Money,Now,Duration_type,IndexId}],
			Logs = get_stall_by(log,StallInfo),
			case (length(Stallmoney)+length(StallItems)) > ?ACUTION_ITEMS_MAXNUM of
				true->
					error;
				_->
					update_stall_to_ets(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,Now,Logs),
					update_stall_to_db(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,Now,Logs),  %%todo async save
					%proc_item_upstall(RoleId,StallId,PlayerItem,Money,ItemName),
					ok
			end
	end.

proc_create_money_stall(RoleId,RoleName,RoleLevel,StallName,OriStallItem)->%%[xiaowu]
	case auction_stall_id_gen:gen_id() of
		[]->
			[];
		NewIndex->
			put(end_index,NewIndex),
			Now = timer_center:get_correct_now(),
			update_stall_to_ets(NewIndex,RoleId,RoleName,RoleLevel,StallName,[],[OriStallItem],Now,[]),
			update_stall_to_db(NewIndex,RoleId,RoleName,RoleLevel,StallName,[],[OriStallItem],Now,[]),  %%todo async save
			NewIndex
	end.	
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		  Stall Item Down
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%down or buy return : update/delete
proc_delete_money(StallId,RoleId,StallInfo,Indexid)->%%3.5jia[xiaowu](删除钱币)
	Stallmoney_Del = lists:keyfind(Indexid,6,get_stall_by(stallmoney,StallInfo)),
	proce_delete_money2(StallId,RoleId,StallInfo,[Stallmoney_Del]).
proce_delete_money2(StallId,RoleId,StallInfo,Stallmoney_Del)->
	RoleName = get_stall_by(rolename,StallInfo),
	RoleLevel = get_stall_by(rolelevel,StallInfo),
	StallName = get_stall_by(stallname,StallInfo),
	StallItems = get_stall_by(items,StallInfo),
	Stallmoney = lists:subtract(get_stall_by(stallmoney,StallInfo),Stallmoney_Del),
	Now = timer_center:get_correct_now(),
	Logs= get_stall_by(log,StallInfo),
	if
		Stallmoney =/= []->		%%has left
			update_stall_to_ets(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,Now,Logs),
			update_stall_to_db(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,Now,Logs),
			update;
		true->					%%not left -> del
			update_stall_to_ets(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,Now,Logs),
			update_stall_to_db(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,Now,Logs),
			delete
	end.
proc_delete_item(StallId,RoleId,ItemId,StallInfo,NewLog)->%%【xiaowu】删除物品
	RoleName = get_stall_by(rolename,StallInfo),
	RoleLevel = get_stall_by(rolelevel,StallInfo),
	StallName = get_stall_by(stallname,StallInfo),
	Stallmoney = get_stall_by(stallmoney,StallInfo),
	StallItems = lists:keydelete(ItemId, 1, get_stall_by(items,StallInfo)),
	Now = timer_center:get_correct_now(),
	OriLogs= 
	if
		NewLog=/= []->
			[NewLog|get_stall_by(log,StallInfo)];
		true->
			get_stall_by(log,StallInfo)
	end,
	Logs = lists:sublist(OriLogs,?ACUTION_MAX_LOG_NUM),
	CreateTime = get_stall_by(time,StallInfo),
	del_item(ItemId),
	if
		StallItems =/= []->		%%has left
			update_stall_to_ets(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,Now,Logs),
			update_stall_to_db(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,Now,Logs),
			update;
		true->					%%not left -> del
			update_stall_to_ets(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,Now,Logs),
			update_stall_to_db(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Stallmoney,Now,Logs),
			delete
			%%update_stall_items_to_role(RoleId,StallId),
			%%del_stall(StallId)
	end.

apply_recede_item(RoleId,ItemId)->%%【xiaowu】物品下架
	case get_stall_item_info(ItemId) of
		[]->
			role_pos_util:send_to_role_clinet(RoleId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_RECEDE_NO_ITEM)),
			error;
		StallItemInfo->
			StallId = get_stall_item_by(stallid,StallItemInfo),
			PlayerItem = get_stall_item_by(playeritem,StallItemInfo),
			case get_stall_info(StallId) of
				[]->
					role_pos_util:send_to_role_clinet(RoleId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_RECEDE_NO_STALL)),
					error;
				StallInfo->
					OwnerId = get_stall_by(roleid,StallInfo),
					Stallmoney = get_stall_by(stallmoney,StallInfo),
					if
						OwnerId =/= RoleId->
							slogger:msg("apply_recede_item from stall error. not belong ~p OwnerId ~p ~n",[OwnerId,RoleId]),
							error;
						true->
							{From,Title,Body} =	make_recede_mail_body(),
							case mail_op:auction_send_by_playeritems(From,OwnerId,Title,Body,[PlayerItem],0,0) of
								{ok}->
									case proc_delete_item(StallId,RoleId,ItemId,StallInfo,[]) of
										update->
											update_stall_items_to_role(RoleId,StallId);
										delete->
											%%update to role empty before del_stall
											update_stall_items_to_role(RoleId,StallId),
											if 
												Stallmoney =:= []->
													del_stall(StallId);
												true ->
													nothing
											end
									end,		
									{ok,PlayerItem};
								MailError->
								slogger:msg("mail send error ~p ~n",[MailError]),
								error
							end
					end
			end
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		  Stall Item Buy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc_deal_log(SellerId,SellerName,BuyerId,BuyerName,StallItemInfo,{Silver,Gold,_}=Moneys)->
%%	{{Year,Month,Day},{Hour,Min,Sec}} = calendar:now_to_local_time(timer_center:get_correct_now()),
	LogStr = make_deal_log_str(BuyerName,Silver,Gold,StallItemInfo),
	sell_notify(LogStr),
	LogStr.

sell_notify(LogStr)->
	todo.

apply_buy_item({BuyerId,BuyerName},StallId,ItemId,{Silver,Gold,Ticket})->
	case get_stall_info(StallId) of
		[]->
			role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_RECEDE_NO_STALL)),
			error;
		StallInfo->
			SellerId = get_stall_by(roleid,StallInfo),
			SellerName = get_stall_by(rolename,StallInfo),
			Stallmoney = get_stall_by(stallmoney,StallInfo),
			if
				BuyerId =:= SellerId->
					role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_BUY_ERROR_SELF)),
					error;
				true->
					case lists:keyfind(ItemId, 1, get_stall_by(items,StallInfo)) of
						false->
							role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_RECEDE_NO_ITEM)),
							error;
						{_,{NeedSilver,NeedGold,NeedTicket} = Moneys,Createtime,Duration_type,IndexId}->
							case get_stall_item_info(ItemId) of
								[]->
									role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_RECEDE_NO_ITEM)),
									error;
								StallItemInfo->
									PlayerItem = get_stall_item_by(playeritem,StallItemInfo),
									if
										(Silver>=NeedSilver) and (Gold>=NeedGold) and (Ticket>=NeedTicket)->
											{MFrom,MTitle,MBody} = make_seller_deal_mail_body(BuyerName,StallItemInfo,Moneys),
											%%send seller's money
											case mail_op:auction_send_by_playeritems(MFrom,SellerId,MTitle,MBody,[],NeedSilver,NeedGold) of
												{ok}->
													{MiFrom,MiTitle,MiBody} = make_buyer_deal_mail_item_body(),
													case mail_op:auction_send_by_playeritems(MiFrom,BuyerId,MiTitle,MiBody,[PlayerItem],0,0) of
														{ok}->
															NewLog = proc_deal_log(SellerId,SellerName,BuyerId,BuyerName,StallItemInfo,Moneys),
															case proc_delete_item(StallId,SellerId,ItemId,StallInfo,NewLog) of
																update->
																	update_stall_items_to_role(SellerId,StallId),
																	update_stall_items_to_role(BuyerId,StallId);
																delete->
																	%%update to role empty before del_stall
																	update_stall_items_to_role(SellerId,StallId),
																	update_stall_items_to_role(BuyerId,StallId),
																	if 
																		Stallmoney =:= []->
																			del_stall(StallId);
																		true ->
																			nothing
																	end
															end,
															%% logger
															StallItemInfo_s = make_itemname_str(StallItemInfo),
															gm_logger_role:role_auction_log(SellerId,BuyerId,StallItemInfo_s,NeedSilver,NeedGold),		
															{ok,{NeedSilver,NeedGold,NeedTicket},PlayerItem};
														MailError->
															slogger:msg("mail send error ~p ~n",[MailError]),
															error
													end;
												MailError->
													slogger:msg("mail send error ~p ~n",[MailError]),
													error
											end;
										true->
											role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_LESS_MONEY)),
											error
									end
							end
					end
			end
	end.



apply_buy_money({BuyerId,BuyerName},StallId,{StallGold,StallValue,StallType,StallSilver},{NeedSilver,NeedGold,NeedTicket},{Silver,Gold,Ticket},Num)->
	case get_stall_info(StallId) of
		[]->
			role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_RECEDE_NO_STALL)),
			error;
		StallInfo->
			SellerId = get_stall_by(roleid,StallInfo),
			SellerName = get_stall_by(rolename,StallInfo),
%			Stallmoney = get_stall_by(stallmoney,StallInfo),
			Stallitems = get_stall_by(items,StallInfo),
			if
				BuyerId =:= SellerId->
					role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_BUY_ERROR_SELF)),
					error;
				true->
					if
						(Silver>=NeedSilver) and (Gold>=NeedGold) and (Ticket>=NeedTicket)->
							{MFrom,MTitle,MBody} = make_seller_deal_mail_money_body(BuyerName,{NeedSilver,NeedGold,NeedTicket}),
							case mail_op:auction_send_by_playeritems(MFrom,SellerId,MTitle,MBody,[],NeedSilver,NeedGold) of
								{ok}->
									{MmFrom,MmTitle,MmBody} = make_buyer_deal_mail_money_body(),
									case mail_op:auction_send_by_playeritems(MmFrom,BuyerId,MmTitle,MmBody,[],StallSilver,StallGold)of
										{ok}->
											case proc_delete_money(StallId,SellerId,StallInfo,Num) of
												update->
													update_stall_items_to_role(SellerId,StallId),
													update_stall_items_to_role(BuyerId,StallId),
													ok;
												delete->
													update_stall_items_to_role(SellerId,StallId),
													update_stall_items_to_role(BuyerId,StallId),
													if 
														Stallitems =:= []->
															del_money_stall(StallId),
															ok;
														true ->
															ok
													end
											end;
										MailError->
											slogger:msg("mail send error ~p ~n",[MailError]),
											error
									end;
								MailError->
									slogger:msg("mail send error ~p ~n",[MailError]),
									error
							end;
						true->
							role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_LESS_MONEY)),
							error
					end
			end
	end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 					Log And Mail Str
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%make_money_str(Silver) when Silver>=10000 ->
%%	integer_to_list(trunc(Silver/10000)) ++ language:get_string(?STR_SILVER_10000) ++ make_money_str(Silver rem 10000);
%%make_money_str(Silver) when Silver>=100 ->
%%	SilMoney = trunc(Silver/100),
%%	if
%%		SilMoney =:= 0->
%%			make_money_str(Silver rem 100);
%%		true->
%%			integer_to_list(SilMoney) ++ language:get_string(?STR_SILVER_100)++ make_money_str(Silver rem 100)
%%	end;		
make_money_str(Silver)->
	if
		Silver =:=0->
			[];
		true->
			integer_to_list(Silver) ++ language:get_string(?STR_MONEY)
	end.
make_moneys_str(Silver,Gold)->
	if
		Gold =:= 0->
			make_money_str(Silver);
		true->
			integer_to_list(Gold) ++ language:get_string(?STR_GOLD) ++make_money_str(Silver)
	end.
  
make_itemname_str(StallItemInfo)->
	SearchName = get_stall_item_by(searchname,StallItemInfo),
	Count = playeritems_db:get_count(get_stall_item_by(playeritem,StallItemInfo)),
	binary_to_list(unicode:characters_to_binary(SearchName))++"X"++ integer_to_list(Count).

make_deal_log_str(BuyerName,Silver,Gold,StallItemInfo)->
%%		integer_to_list(Month)++ [230,156,136]
%%		++ integer_to_list(Day)++ [230,151,165] 
%%		++ integer_to_list(Hour) ++ ":"
%%		++ integer_to_list(Min) ++ ":"
%%		++ integer_to_list(Sec) ++ "  "
		{{_Year,_Month,_Day},{Hour,Min,_Sec}} = calendar:now_to_local_time(timer_center:get_correct_now()),
		util:safe_binary_to_list(BuyerName) 
		++ [228,187,165] 
		++ make_moneys_str(Silver,Gold)
		++ language:get_string(?STR_AUCTION_DEAL_LOG)
		++ make_itemname_str(StallItemInfo)
		++[227,128,144]
		++ integer_to_list(Hour)
		++ ":"
		++ integer_to_list(Min)
		++[227,128,145].

%%{MSend,MTitle,MBody}
make_seller_deal_mail_body(BuyerName,StallItemInfo,{Silver,Gold,_})->
%%	{
%%		[231,179,187,231,187,159],[231,137,169,229,147,129,229,148,174,229,135,186],
%%		util:safe_binary_to_list(BuyerName)++
%%		[229,156,168,230,130,168,231,154,132,230,145,138,228,189,141,228,184,138,232,180,173,228,185,176,228,186,134]++
%%		make_itemname_str(StallItemInfo) ++ ","	++ [230,156,172,230,172,161,228,186,164,230,152,147,230,148,182,229,133,165,228,184,186,58]++
%%		make_moneys_str(Silver,Gold) ++ [44,232,175,183,231,130,185,229,135,187,34,230,148,182,229,143,150,34,233,162,134,229,143,150,230,156,172,230,172,161,228,186,164,230,152,147,230,137,128,229,190,151,46,232,175,183,228,184,141,232,166,129,229,155,158,229,164,141,230,173,164,233,130,174,228,187,182,46]	   		
%%	}.
	MailSender = language:get_string(?STR_SYSTEM),
	MailTitle = language:get_string(?STR_AUCTION_SELL_MAIL_TITLE),
%%	MailContextFormat = language:get_string(?STR_AUCTION_SELL_MAIL_CONTEXT),
	MailContext = util:safe_binary_to_list(BuyerName) 
					++ language:get_string(?STR_AUCTION_SELL_MAIL_CONTEXT1)
					++ make_itemname_str(StallItemInfo)
					++ language:get_string(?STR_AUCTION_SELL_MAIL_CONTEXT2)
					++ make_moneys_str(Silver,Gold)
					++ language:get_string(?STR_AUCTION_SELL_MAIL_CONTEXT3),
	{MailSender,MailTitle,MailContext}.

make_seller_deal_mail_money_body(BuyerName,{Silver,Gold,_})->
	MailSender = language:get_string(?STR_SYSTEM),
	MailTitle = language:get_string(?STR_AUCTION_SELL_MAIL_TITLE),
	MailContext = util:safe_binary_to_list(BuyerName) 
					++ language:get_string(?STR_AUCTION_SELL_MAIL_CONTEXT1)
%					++ make_itemname_str(StallItemInfo)
					++ language:get_string(?STR_AUCTION_SELL_MAIL_CONTEXT2)
					++ make_moneys_str(Silver,Gold)
					++ language:get_string(?STR_AUCTION_SELL_MAIL_CONTEXT3),
	{MailSender,MailTitle,MailContext}.

make_buyer_deal_mail_money_body()->
	MailSender = language:get_string(?STR_SYSTEM),
	MailTitle = language:get_string(?STR_AUCTION_SELL_MAIL_GET_ITEM_TITLE),
	MailContext = language:get_string(?STR_AUCTION_SELL_MAIL_ITEM_CONTEXT),
	{MailSender,MailTitle,MailContext}.

make_buyer_deal_mail_item_body()->
	MailSender = language:get_string(?STR_SYSTEM),
	MailTitle = language:get_string(?STR_AUCTION_SELL_MAIL_GET_ITEM_TITLE),
	MailContext = language:get_string(?STR_AUCTION_SELL_MAIL_ITEM_CONTEXT),
	{MailSender,MailTitle,MailContext}.

make_recede_mail_body()->
	MailSender = language:get_string(?STR_SYSTEM),
	MailTitle = language:get_string(?STR_AUCTION_SELL_MAIL_RECEDE_TITLE),
	MailContext = language:get_string(?STR_AUCTION_SELL_MAIL_RECEDE_CONTEXT),
	{MailSender,MailTitle,MailContext}.


%%{MSend,MTitle,MBody}
make_overdue_mail_body()->
	%%{[231,179,187,231,187,159],[230,145,138,228,189,141,229,183,178,232,191,135,230,156,159],
	%%[230,130,168,231,154,132,230,145,138,228,189,141,229,156,168,228,186,140,229,141,129,229,155,155,229,176,143,230,151,182,228,185,139,229,134,133,229,183,178,230,178,161,230,156,137,228,187,187,228,189,149,230,147,141,228,189,156,44,230,145,138,228,189,141,229,183,178,230,146,164,233,148,128,44,230,137,128,230,156,137,231,137,169,229,147,129,232,191,148,232,191,152,44,232,175,183,229,143,138,230,151,182,230,148,182,229,143,150,231,137,169,229,147,129,46]}.
	MailSender = language:get_string(?STR_SYSTEM),
	MailTitle = language:get_string(?STR_AUCTION_OVERDUE_MAIL_TITLE),
	MailContext = language:get_string(?STR_AUCTION_OVERDUE_MAIL_CONTEXT),
	{MailSender,MailTitle,MailContext}.

%%Stall item : {stallid,roleid,rolename,rolelevel,stallname,items,time,log}

get_stall_by(stallid,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs})->
	Id;
get_stall_by(roleid,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs})->
	RoleId;
get_stall_by(rolename,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs})->
	RoleName;
get_stall_by(stallmoney,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs})->
	Stallmoney;
get_stall_by(rolelevel,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs})->
	RoleLevel;
get_stall_by(stallname,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs})->
	NickName;
get_stall_by(items,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs})->
	Items;
get_stall_by(time,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs})->
	CreateTime;
get_stall_by(log,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs})->
	Logs.

set_stall_by(stallid,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs},Value)->
	{Value,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs};
set_stall_by(roleid,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs},Value)->
	{Id,Value,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs};
set_stall_by(rolename,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs},Value)->
	{Id,RoleId,Value,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs};
set_stall_by(rolelevel,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs},Value)->
	{Id,RoleId,RoleName,Value,NickName,Items,Stallmoney,CreateTime,Logs};
set_stall_by(stallname,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs},Value)->
	{Id,RoleId,RoleName,RoleLevel,Value,Items,Stallmoney,CreateTime,Logs};
set_stall_by(items,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs},Value)->
	{Id,RoleId,RoleName,RoleLevel,NickName,Value,Stallmoney,CreateTime,Logs};
set_stall_by(time,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs},Value)->
	{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,Value,Logs};
set_stall_by(log,{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Logs},Value)->
	{Id,RoleId,RoleName,RoleLevel,NickName,Items,Stallmoney,CreateTime,Value}.

%% {itemid,searchname,stallid,playeritem,money}

get_stall_item_by(itemid,{Itemid,Searchname,Stallid,Playeritem,Money})->
	Itemid;
get_stall_item_by(searchname,{Itemid,Searchname,Stallid,Playeritem,Money})->
	Searchname;
get_stall_item_by(stallid,{Itemid,Searchname,Stallid,Playeritem,Money})->
	Stallid;
get_stall_item_by(playeritem,{Itemid,Searchname,Stallid,Playeritem,Money})->
	Playeritem;
get_stall_item_by(money,{Itemid,Searchname,Stallid,Playeritem,Money})->
	Money.

set_stall_item_by(itemid,{Itemid,Searchname,Stallid,Playeritem,Money},Value)->
	{Itemid,Searchname,Stallid,Playeritem,Money};
set_stall_item_by(searchname,{Itemid,Searchname,Stallid,Playeritem,Money},Value)->
	{Itemid,Value,Stallid,Playeritem,Money};
set_stall_item_by(stallid,{Itemid,Searchname,Stallid,Playeritem,Money},Value)->
	{Itemid,Searchname,Value,Playeritem,Money};
set_stall_item_by(playeritem,{Itemid,Searchname,Stallid,Playeritem,Money},Value)->
	{Itemid,Searchname,Stallid,Value,Money};
set_stall_item_by(money,{Itemid,Searchname,Stallid,Playeritem,Money},Value)->
	{Itemid,Searchname,Stallid,Playeritem,Value}.

%%3月13日写【xiaowu】
get_oritemid_from_Stallitems({OriItemId,Money,Now,Duration_type,IndexId})->
	OriItemId.
get_money_from_Stallitems({OriItemId,Money,Now,Duration_type,IndexId})->
	Money.
get_now_from_Stallitems({OriItemId,Money,Now,Duration_type,IndexId})->
	Now.
get_duration_type_from_Stallitems({OriItemId,Money,Now,Duration_type,IndexId})->
	Duration_type.
get_indexid_from_Stallitems({OriItemId,Money,Now,Duration_type,IndexId})->
	IndexId.
%%3月13日写【xiaowu】
get_roleid_from_Stallmoney({RoleId,PlayerItem,Money,Now,Duration_type,IndexId})->
	RoleId.
get_playeritem_from_Stallmoney({RoleId,PlayerItem,Money,Now,Duration_type,IndexId})->
	PlayerItem.
get_money_from_Stallmoney({RoleId,PlayerItem,Money,Now,Duration_type,IndexId})->
	Money.
get_now_from_Stallmoney({RoleId,PlayerItem,Money,Now,Duration_type,IndexId})->
	Now.
get_indexid_from_stallmoney({RoleId,PlayerItem,Money,Now,Duration_type,IndexId})->
	IndexId.