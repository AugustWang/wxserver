%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(items_op).

-export([load_from_db/1,save_to_db/0,export_for_copy/0,load_by_copy/1,set_item_enchantment/2,get_item_info/1,set_item_isbonded/2]).
			

-export([obtain_from_mail_by_itemids/1,lost_from_mail_by_itemids/2,
			obtain_from_trade_by_items/1,lost_from_trad_by_slot/1,
			obtain_from_auction_by_playeritem/3,lost_from_stall_by_playeritem/1,
			obtain_from_gm_mail_send/4,exec_egg_beam/2]).

-export([get_left_time_by_overdueinfo/1]).

-export([get_lost_reason_for_client/1]).

-compile(export_all).
			
-export([consume_item/1,repair_item/1,repair_item_all/0]).
-include("equipment_up_def.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("mnesia_table_def.hrl").
-include("common_define.hrl").
-include("slot_define.hrl").
-include("item_define.hrl").
-include("item_struct.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% items_info:
%% {itemid,#iteminfo,last,{LastUsetime{0,0,0},CDTime(ms)},needsave 0:涓嶉渶瑕佸瓨搴�/1锛氭洿鏂皚
%% storages_info:
%% {itemid,#playeritems,last,{LastUsetime{0,0,0},CDTime(ms)}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load_from_db(Role_id)->
	put(items_info,[]),
	put(storages_info,[]),
	put(delete_items,[]),
	%%浠巔layeritems琛ㄨ鍙栫帺瀹舵墍鏈夌墿鍝佷俊鎭�,鍦ㄦ瀛樺叆鐨勬槸璁＄畻鐢熸槦鍚庣殑鐗╁搧灞炴��
	AllItems = playeritems_db:loadrole(Role_id),
	HandsItems = lists:filter(fun(ItemTmp)->
						(playeritems_db:get_slot(ItemTmp) < ?SLOT_PACKAGE_ENDEX) 
					end,AllItems),
	put(items_info,lists:map(fun(PlayerItem)->
				Id = playeritems_db:get_id(PlayerItem),
				FullInfo = build_fullinfo_by_item(PlayerItem), 
				Cooldowninfo= playeritems_db:get_cooldowninfo(PlayerItem),
				{Id,FullInfo,Cooldowninfo,0}
			end,HandsItems)),
	StoragesItems = lists:filter(fun(ItemTmp)->
						Slot = playeritems_db:get_slot(ItemTmp),
						(Slot > ?SLOT_STORAGES_INDEX) and (Slot  < ?SLOT_STORAGES_ENDEX)
					end,AllItems),
	put(storages_info,lists:map(fun(ItemTmp)->
				Id = playeritems_db:get_id(ItemTmp),
				PlayerItem = make_playeritem_by_db(ItemTmp),
				Cooldowninfo= playeritems_db:get_cooldowninfo(PlayerItem),
				{Id,PlayerItem,Cooldowninfo,0}
			end,StoragesItems)).

%%鍒犻櫎杩囨湡鐨�
check_item_overdue_interval()->
	{NeedRecomput,NeedReDisplay,NeedCreates} = lists:foldl(fun({_,ItemInfo,_,_},{NeedRecomputTmp,NeedReDisplayTmp,Creates})->
		case check_item_overdue(get_overdueinfo_from_iteminfo(ItemInfo)) of
			true->
				TemplateInfo = item_template_db:get_item_templateinfo(get_template_id_from_iteminfo(ItemInfo)),
				TurnItem = item_template_db:get_overdue_transform(TemplateInfo),
				ItemSlotTmp = get_slot_from_iteminfo(ItemInfo),
				case package_op:where_slot(ItemSlotTmp) of
					pet_body->
						nothing;%%@@wb20130604
%% 						pet_op:hook_item_destroy_on_pet(ItemInfo);
					_->
						nothing
				end,
				role_op:proc_destroy_item(ItemInfo,lost_over_due),
				case package_op:where_slot(ItemSlotTmp) of
					body->
						case lists:member(ItemSlotTmp,?DISPLAY_SLOTS) of 
							true->
								{true,true,TurnItem++Creates};
							_->
								{true,NeedReDisplayTmp,TurnItem++Creates}
						end;
					_->
						{NeedRecomputTmp,NeedReDisplayTmp,TurnItem++Creates}	 
				end;
			_->
				{NeedRecomputTmp,NeedReDisplayTmp,Creates}
		end end,{false,false,[]},get(items_info)),
	lists:foreach(fun({Itemid,ItemCount})->role_op:auto_create_and_put(Itemid,ItemCount,got_over_due) end,NeedCreates),
	if
		NeedReDisplay->
			role_op:redisplay_cloth_and_arm();
		true->
			nothing
	end,
	if
		NeedRecomput->
			role_op:recompute_equipment_attr();
		true->
			nothing
	end.

make_playeritem_by_db(PlayerItem)->
	ItemId = playeritems_db:get_id(PlayerItem),
	Ownerguid = playeritems_db:get_ownerguid(PlayerItem),
	Entry =playeritems_db:get_entry(PlayerItem),
	Enchantments = playeritems_db:get_enchantments(PlayerItem),
	Count = playeritems_db:get_count(PlayerItem),
	Slot= playeritems_db:get_slot(PlayerItem),
	Isbonded= playeritems_db:get_isbond(PlayerItem),
	Sockets= playeritems_db:get_sockets(PlayerItem),
	Duration= playeritems_db:get_duration(PlayerItem),
	CoolDownInfo= playeritems_db:get_cooldowninfo(PlayerItem),
	Enchant = playeritems_db:get_enchant(PlayerItem),
	Overdueinfo = playeritems_db:get_overdueinfo(PlayerItem),
	#playeritems{id = ItemId,
				ownerguid = Ownerguid,
				entry = Entry,
				enchantments = Enchantments,
				count = Count,
				slot = Slot,
				isbond = Isbonded,
				sockets = Sockets,
				duration = Duration,
				cooldowninfo = CoolDownInfo,
				enchant = Enchant,
				overdueinfo = Overdueinfo}.

make_playeritem(ItemId)->
	case lists:keyfind(ItemId,1,get(items_info)) of
		false ->
			[];
		{_,ItemInfo,CoolDownInfo,_}->
			#playeritems{
				id = ItemId,
				ownerguid = get(roleid), 
				entry = get_template_id_from_iteminfo(ItemInfo),
				enchantments = get_enchantments_from_iteminfo(ItemInfo),
				count = get_count_from_iteminfo(ItemInfo),
				slot = get_slot_from_iteminfo(ItemInfo),
				isbond = get_isbonded_from_iteminfo(ItemInfo),
				sockets = get_socketsinfo_from_iteminfo(ItemInfo),
				duration = get_duration_from_iteminfo(ItemInfo),
				cooldowninfo=CoolDownInfo,
				enchant = get_enchant_from_iteminfo(ItemInfo),
				overdueinfo = get_overdueinfo_from_iteminfo(ItemInfo)
				}
	end.
	
build_item_by_fullinfo(ItemsInfo)->
	build_item_by_fullinfo(ItemsInfo,get_cooldowninfo_from_iteminfo(ItemsInfo)).	
		
build_item_by_fullinfo(ItemsInfo,CoolDownInfo)->
	ItemId = get_id_from_iteminfo(ItemsInfo),
	Ownerguid = get(roleid),
	Entry	  = get_template_id_from_iteminfo(ItemsInfo),
	Enchantments = get_enchantments_from_iteminfo(ItemsInfo),
	Count = get_count_from_iteminfo(ItemsInfo),
	Slot  = get_slot_from_iteminfo(ItemsInfo),
	Isbonded = get_isbonded_from_iteminfo(ItemsInfo),
	Sockets = get_socketsinfo_from_iteminfo(ItemsInfo),
	Duration = get_duration_from_iteminfo(ItemsInfo),
	Enchant =  get_enchant_from_iteminfo(ItemsInfo),
	Overdueinfo = get_overdueinfo_from_iteminfo(ItemsInfo),
	#playeritems{id = ItemId,
				ownerguid = Ownerguid,
				entry = Entry,
				enchantments = Enchantments,
				count = Count,
				slot = Slot,
				isbond = Isbonded,
				sockets = Sockets,
				duration = Duration,
				cooldowninfo = CoolDownInfo,
				enchant = Enchant,
				overdueinfo = Overdueinfo}.
	
build_fullinfo_by_item(PlayerItem)->
	Id = playeritems_db:get_id(PlayerItem),
	Ownerguid = playeritems_db:get_ownerguid(PlayerItem),
	Entry =playeritems_db:get_entry(PlayerItem),
	Enchantments = playeritems_db:get_enchantments(PlayerItem),
	Count = playeritems_db:get_count(PlayerItem),
	Slot= playeritems_db:get_slot(PlayerItem),
	Isbonded= playeritems_db:get_isbond(PlayerItem),
	Sockets= playeritems_db:get_sockets(PlayerItem),
	Duration= playeritems_db:get_duration(PlayerItem),
	CoolDownInfo = playeritems_db:get_cooldowninfo(PlayerItem),
	Enchant = playeritems_db:get_enchant(PlayerItem),
	OverDueInfo = playeritems_db:get_overdueinfo(PlayerItem),
	BaseInfo = create_item_baseinfo(Id,Ownerguid,Entry,Enchantments,Count,Slot,Isbonded,Sockets,Duration,CoolDownInfo,Enchant,OverDueInfo),
	TemplateInfo = item_template_db:get_item_templateinfo(Entry),
	InfoWithProto = set_protoinfo_to_iteminfo(BaseInfo,TemplateInfo),
	set_iteminfo_by_enchantments(InfoWithProto,Enchantments).
	
add_item_to_itemsinfo(ItemFullInfo)->
	ItemId = get_id_from_iteminfo(ItemFullInfo),
	CoolDown = get_cooldowninfo_from_iteminfo(ItemFullInfo),
	case lists:keyfind(ItemId,1,get(items_info)) of
		false->
			put(items_info,[{ItemId,ItemFullInfo,CoolDown,1}| get(items_info)]);
		{ItemId,ItemOldInfo,_,_}->	
			OldSlot = get_slot_from_iteminfo(ItemOldInfo),
			package_op:del_item_from_slot(OldSlot),
			put(items_info,lists:keyreplace(ItemId,1,get(items_info),{ItemId,ItemFullInfo,CoolDown,1}))
	end.		 

export_for_copy()->
	{get(storages_info),get(items_info),get(delete_items)}.
	
load_by_copy({StorageInfo,ItemsInfo,DeleteInfo})->
	put(storages_info,StorageInfo),
	put(items_info,ItemsInfo),
	put(delete_items,DeleteInfo).
	
%%Args : attack / defence
consume_item(Args)->	
	case random:uniform(100) =< ?EQUIPMENT_CONSUME_RATE of
		true-> 
			Slots = if
						Args =:= defence->
							package_op:get_defence_slots();
						Args =:= attack-> 
							package_op:get_attack_slots()
					end,
			case erlang:length(Slots) of
				0->					%%韬笂娌℃秷鑰楃殑鐗╁搧
					nothing;
				Num->	
					ConsumeSlot = lists:nth(random:uniform(Num),Slots),
					case package_op:get_item_id_in_slot(ConsumeSlot) of
						[]->
							nothing;
						ItemId->
							case resume_item_duration(ItemId) of
								nothing->
									nothing;
								NewDuration->
									if
										NewDuration =:= 0->
											role_op:recompute_equipment_attr();
										true->
											nothing
									end
							end								
					end
			end;		  	
		false->
			nothing
	end.
	
repair_item(Slot)->
	case package_op:get_item_id_in_slot(Slot) of
		[]->
			nothing;
		ItemId->
			case lists:keyfind(ItemId,1,get(items_info)) of
				false -> 
					slogger:msg("resume_item_duration error!ItemId:~p~n",[ItemId]),
					nothing;
				{_,Iteminfo,Cooldowninfo,_} ->
					case get_item_repair_money(Iteminfo) of
						0->
							nothing;
						NeedMoney->	
							case role_op:check_money(?MONEY_BOUND_SILVER, NeedMoney) of
								true->
									OldDuration = get_duration_from_iteminfo(Iteminfo),										
									MaxDuration = get_maxduration_from_iteminfo(Iteminfo),
									put(items_info,lists:keyreplace(ItemId,1,get(items_info),{ItemId,set_duration_to_iteminfo(Iteminfo,MaxDuration),Cooldowninfo,1})),
									ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(ItemId),get_highid_from_itemid(ItemId),[role_attr:to_item_attribute({duration,MaxDuration})],[]),
									Message = role_packet:encode_update_item_s2c([ChangeInfo]),
									role_op:send_data_to_gate(Message),
									role_op:money_change( ?MONEY_BOUND_SILVER, - NeedMoney,lost_function),
									if
										OldDuration =:= 0->
												role_op:recompute_equipment_attr();
										true->
											nothing
									end,
									ok;
								_->
									less_money
							end
					end				
			end
	end.

repair_item_all()->
	OnHandsItems = package_op:get_body_slots() ,%%++ package_op:get_package_slots(),
	{NeedMoney,Ids} =  lists:foldl(fun(Items,Tmp)->get_repair_money_id(Items,Tmp) end,{0,[]},OnHandsItems),
	case role_op:check_money(?MONEY_BOUND_SILVER, NeedMoney) of
		true->
			{NeedRecompute,ChangeInfos} = lists:foldl(fun(ItemId,{NeedRecom,ChangeTemp})->
							{_,Iteminfo,Cooldowninfo,_} = lists:keyfind(ItemId,1,get(items_info)),
							OldDuration = get_duration_from_iteminfo(Iteminfo),										
							MaxDuration = get_maxduration_from_iteminfo(Iteminfo),
							put(items_info,lists:keyreplace(ItemId,1,get(items_info),{ItemId,set_duration_to_iteminfo(Iteminfo,MaxDuration),Cooldowninfo,1})),
							ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(ItemId),get_highid_from_itemid(ItemId),[role_attr:to_item_attribute({duration,MaxDuration})],[]),
							if
								not NeedRecom->
									{(OldDuration =:= 0),[ChangeInfo|ChangeTemp]};
								true->
									{true,[ChangeInfo|ChangeTemp]}
							end	 
							end,{false,[]},Ids),
			Message = role_packet:encode_update_item_s2c(ChangeInfos),
			role_op:send_data_to_gate(Message),
			role_op:money_change(?MONEY_BOUND_SILVER, - NeedMoney,lost_function),
			if
				NeedRecompute->
						role_op:recompute_equipment_attr();
				true->
					nothing
			end,
			ok;				
		_->
			less_money
	end.		

%%for repair_item_all static fun
get_repair_money_id({_Slot,ItemId,_},{MoneyTmp,ItemIdsTmp})->
	if
		ItemId =/= 0->
			ItemInfo = get_item_info(ItemId),
			if
				ItemInfo =/= []->
					Class = get_class_from_iteminfo(ItemInfo),
					if
						((Class >= ?ITEM_TYPE_MAINHAND) and (Class =< ?ITEM_TYPE_FINGER)) or (Class=:=?ITEM_TYPE_SHIELD)->
							case get_item_repair_money(ItemInfo) of
								0->
									{MoneyTmp,ItemIdsTmp};
								RepairMoney ->		
									{MoneyTmp + RepairMoney,[ ItemId |ItemIdsTmp ]}
							end;
						true->
							{MoneyTmp,ItemIdsTmp}	
					end;	
				true->
					{MoneyTmp,ItemIdsTmp}
			end;
		true->
			{MoneyTmp,ItemIdsTmp}
	end.


%%寰楀埌鏌愪欢瑁呭鐨勫睘鎬э紝鍖呭惈妲藉唴瀹濈煶灞炴�� 鍗囨槦鍔犳垚灞炴��
get_item_attr(ItemInfo) -> 	
	case get_duration_from_iteminfo(ItemInfo) of				%%濡傛灉褰撳墠鎸佷箙涓�0,涓嶈绠�
		0->
			[]; 
		_->	
			{MagicDef,RangeDef,MeleeDef} = get_defense_from_iteminfo(ItemInfo),
			{MagicDmg,RangeDmg,MeleeDmg} = get_damage_from_iteminfo(ItemInfo),
			AttrDefAndDmg = [{magicdefense,MagicDef},{rangedefense,RangeDef},{meleedefense,MeleeDef},
							{magicpower,MagicDmg},{rangepower,RangeDmg},{meleepower,MeleeDmg}],
			AttrState = get_states_from_iteminfo(ItemInfo),					
			%%妲戒綅
			SocketsInfo = get_socketsinfo_from_iteminfo(ItemInfo),
			case erlang:length(SocketsInfo) of 
				0 -> StoneAttr = [];
				_ -> StoneAttr = get_sockets_item_attr(SocketsInfo)
			end,
			%%闄勯瓟
			AttrEnchant = get_enchant_from_iteminfo(ItemInfo),
			%%鍗囨槦闄勫姞
			AttrEnchantments = get_enchantment_item_sttr(ItemInfo),
			AttrState ++ AttrDefAndDmg ++ StoneAttr ++ AttrEnchant ++ AttrEnchantments
	end.

get_item_template_attr(TemplateInfo)->
	{MagicDef,RangeDef,MeleeDef} = item_template_db:get_defense(TemplateInfo),
	{MagicDmg,RangeDmg,MeleeDmg} = item_template_db:get_damage(TemplateInfo),
	AttrDefAndDmg = [{magicdefense,MagicDef},{rangedefense,RangeDef},{meleedefense,MeleeDef},
					{magicpower,MagicDmg},{rangepower,RangeDmg},{meleepower,MeleeDmg}],
	AttrState = item_template_db:get_states(TemplateInfo),
	AttrState ++ AttrDefAndDmg.
	
%%閫氳繃姝﹀櫒妲戒綅淇℃伅鑾峰彇妲藉姞鎴愬睘鎬�						
get_sockets_item_attr(SocketsInfo)->
	lists:foldl(fun({_,ItemId},TmpAttr)-> 
					case ItemId of
						0 -> TmpAttr; %%鏈暥宓屽疂鐭�
						_ ->							
							case item_template_db:get_item_templateinfo(ItemId) of
								[] ->
									slogger:msg("get_sockets_attr error:wrong  ItemId:~p~n",[ItemId]), 
									TmpAttr;
								TemplateInfo ->
									TmpAttr ++ get_item_template_attr(TemplateInfo)
							end
					end	end,[],SocketsInfo).

%%鑾峰彇鍗囨槦鍔犳垚灞炴��					
get_enchantment_item_sttr(ItemInfo)->
	Enchantments = get_enchantments_from_iteminfo(ItemInfo),
	ItemClass = get_class_from_iteminfo(ItemInfo),
	case enchantments_db:get_enchantments_info(Enchantments) of
		[]->
			[];
		EnchantmentInfo->
			AddAttrs = enchantments_db:get_enchantments_add_attr(EnchantmentInfo),
			case lists:keyfind(ItemClass,1,AddAttrs) of
				false->
					[];
				{_,AddAttr}->
					AddAttr
			end
	end.
	
				
%%璁剧疆鐢熸槦鏀瑰彉鐨勫睘鎬�,鍙傛暟锛氬師濮嬪睘鎬�,鏄熺骇 
%%杩斿洖鍊�:鏍规嵁鏄熺骇鏀瑰彉鐨刬tem_info		
set_iteminfo_by_enchantments(OriInfo,Enchantment)->
	case Enchantment of 
		0 -> 
			TemplateID = get_template_id_from_iteminfo(OriInfo),
			TempInfo = item_template_db:get_item_templateinfo(TemplateID),
			Info1 = set_damage_from_iteminfo(OriInfo,item_template_db:get_damage(TempInfo)),
			set_defense_from_iteminfo(Info1,item_template_db:get_defense(TempInfo));
		_ ->
			EquipLevelStar = Enchantment,
			case enchantments_db:get_enchantments_info(EquipLevelStar) of
				[] -> 
					slogger:msg("get_item_dmg_and_def_by_enchant error Enchantments:~p~n",[Enchantment]),
					OriInfo;
				EnchantmentInfo ->
					#enchantments{bonuses=Bonuses} = EnchantmentInfo,
					TemplateID = get_template_id_from_iteminfo(OriInfo),
					TempInfo = item_template_db:get_item_templateinfo(TemplateID),
					{MagicDmg,RangeDmg,MeleeDmg} = item_template_db:get_damage(TempInfo),
					{MagicDef,RangeDef,MeleeDef} = item_template_db:get_defense(TempInfo),
					[RealMagicDef,RealRangeDef,RealMeleeDef,
					RealMagicDmg,RealRangeDmg,RealMeleeDmg] = lists:map(fun(Value)->
																erlang:trunc(Value*(1 + Bonuses/100)) 
															end
															,[MagicDef,RangeDef,MeleeDef,
															MagicDmg,RangeDmg,MeleeDmg]),
					Info1 = set_damage_from_iteminfo(OriInfo,{RealMagicDmg,RealRangeDmg,RealMeleeDmg}),
					set_defense_from_iteminfo(Info1,{RealMagicDef,RealRangeDef,RealMeleeDef})
			end	
	end.

%%璁剧疆鐗╁搧鐢熸槦,濡傛灉鏃惰瓒呰繃8鏄�,鍒欐敼涓烘案涔呮�х墿鍝�
set_item_enchantment(Itemid,NewEnchantment)->
	AllInfo = get(items_info),
	case lists:keyfind(Itemid,1,AllInfo) of
		false -> 
			nothing;
		{Itemid,Iteminfo,Cooldowninfo,_} ->
			EnchantItemInfo = set_iteminfo_by_enchantments(set_enchantments_to_iteminfo(Iteminfo,NewEnchantment),NewEnchantment),
			ChangeAttrs = 
			[role_attr:to_item_attribute({enchantments,NewEnchantment})] ++
			if
				NewEnchantment>=?FASHION_DEACTIVE_OVERDUE_ENCHANMENTS->
					case get_class_from_iteminfo(EnchantItemInfo) of
						?ITEM_TYPE_FASHION->
							case get_overdueinfo_from_iteminfo(EnchantItemInfo) of
								[]->	%%宸茶缃负姘镐箙		
									put(items_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,EnchantItemInfo,Cooldowninfo,1})),
									[];
								_->	
									 put(items_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,set_overdueinfo_to_iteminfo(EnchantItemInfo,[]),Cooldowninfo,1})),
									 [role_attr:to_item_attribute({lefttime_s,?ITEM_NONE_OVERDUE_LEFTTIME})]
							end;
						_->		%%涓嶆槸鏃惰
							put(items_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,EnchantItemInfo,Cooldowninfo,1})),
							[]
					end;
				true->				%%涓嶅埌鎸囧畾鏄熺骇
					put(items_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,EnchantItemInfo,Cooldowninfo,1})),
					[]
			end,
			ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(Itemid),
												get_highid_from_itemid(Itemid),
												ChangeAttrs,[]),
			Message = role_packet:encode_update_item_s2c([ChangeInfo]),
			role_op:send_data_to_gate(Message)
	end.	

save_to_db()->
	RoleId = get(roleid),
	TableName = db_split:get_owner_table(playeritems, RoleId),
	lists:foreach(fun(DelItemid)->
					playeritems_db:del_playeritems(TableName,DelItemid,RoleId)
					end,get(delete_items)),
	put(delete_items,[]),
	lists:foreach(fun({_Itemid,ItemsInfo,_,NeedSave})->
					case NeedSave of
						1 ->
							sync_save_iteminfo(TableName,ItemsInfo);
						0->
							nothing
					end end, get(items_info)),
	lists:foreach(fun({_Itemid,PlayerItem,_,NeedSave})->
					case NeedSave of
						1 ->
							sync_save_playeritem(TableName,PlayerItem);
						0->
							nothing
					end end, get(storages_info)),
	put(items_info,lists:map( fun({Itemid,ItemsInfo,Cooldowninfo,_})-> 
		{Itemid,ItemsInfo,Cooldowninfo,0} end,get(items_info)) ),
	put(storages_info,lists:map( fun({Itemid,ItemsInfo,Cooldowninfo,_})-> 
		{Itemid,ItemsInfo,Cooldowninfo,0} end,get(storages_info)) ).	

sync_save_playeritem(TableName,PlayerItem)->
	playeritems_db:add_playeritems(TableName,PlayerItem).

sync_save_iteminfo(TableName,ItemsInfo)->
	Ownerguid = get(roleid),
	Itemid = get_id_from_iteminfo(ItemsInfo),
	Entry	  = get_template_id_from_iteminfo(ItemsInfo),
	Enchantments = get_enchantments_from_iteminfo(ItemsInfo),
	Count = get_count_from_iteminfo(ItemsInfo),
	Slot  = get_slot_from_iteminfo(ItemsInfo),
	Isbonded = get_isbonded_from_iteminfo(ItemsInfo),
	Sockets = get_socketsinfo_from_iteminfo(ItemsInfo),
	Duration = get_duration_from_iteminfo(ItemsInfo),
	CoolDownInfo = get_cooldowninfo_from_iteminfo(ItemsInfo),
	Enchant = get_enchant_from_iteminfo(ItemsInfo),
	OverdueInfo = get_overdueinfo_from_iteminfo(ItemsInfo),
	playeritems_db:add_playeritems(TableName,Itemid,Ownerguid,Entry,Enchantments,Count,Slot,Isbonded,Sockets,Duration,CoolDownInfo,Enchant,OverdueInfo).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%								鐗╁搧杩囨湡鐩稿叧
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%妫�鏌ョ墿鍝佹槸鍚﹁兘浣跨敤: return:true/cooldown/overdue
check_item_can_use(ItemInfo)->
	{LastUseTime,CoolDown} = get_cooldowninfo_from_iteminfo(ItemInfo),
	CoolCheck = timer:now_diff(timer_center:get_correct_now(),LastUseTime) >= CoolDown*1000,
	OverdueCheck = check_item_overdue(get_overdueinfo_from_iteminfo(ItemInfo)),
	if
		OverdueCheck->
			 overdue;
		not CoolCheck->
			cooldown;
		true->
			true
	end. 
	
check_item_overdue(OverDueInfo)->
	get_left_time_by_overdueinfo(OverDueInfo)=:=0.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 鑾峰彇褰撳墠瑁呭鏈夋晥鍓╀綑鏃堕棿 
%% return: 
%% ?ITEM_NONE_OVERDUE_LEFTTIME : 姘镐箙鏈夋晥
%% 璐熷�� : 灏氭湭婵�娲荤殑鏈夋晥绉掓暟
%% 0:宸茶繃鏈�
%% 姝ｅ�� : 鍓╀綑绉掓暟
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
get_left_time_by_overdueinfo([])->
	?ITEM_NONE_OVERDUE_LEFTTIME;
get_left_time_by_overdueinfo({{0,0,0},DurationTime})->
	-DurationTime;	
get_left_time_by_overdueinfo({ActiveTime,DurationTime})->	
	LeftTime_s = DurationTime - trunc(timer:now_diff(timer_center:get_correct_now(),ActiveTime)/1000000),
	if
		LeftTime_s =< 0-> 
			0;							%%宸茬粡杩囨湡,绛夊緟鍒犻櫎!
		true->
			LeftTime_s
	end.

%%閫氳繃妯℃澘杩囨湡鍙傛暟鑾峰彇褰撳墠婵�娲诲墿浣欐椂闂�,杩斿洖鍓╀綑鏃堕棿绉掓暟
%%濡傛灉妯℃澘杩囨湡鍙傛暟涓烘暣鏁�,鍒欑洿鎺ヨ〃绀鸿鐗╁搧N绉掑悗杩囨湡
get_left_time_by_overdue_args(_NowTime,LeftTimes) when is_integer(LeftTimes)->
	LeftTimes;
%%濡傛灉妯℃澘杩囨湡鍙傛暟涓簕鏃�,鍒�,绉拀,鍒欎负姣忓ぉ鐨剓鏃�,鍒�,绉拀瀹氱偣杩囨湡	
get_left_time_by_overdue_args(NowTime,{Hour,Min,Sec})->
	{{_,_,_},{Hnow,Mnow,Snow}} = calendar:now_to_local_time(NowTime),
	NowTimes = calendar:datetime_to_gregorian_seconds({{1,1,1},{Hnow,Mnow,Snow}}),
	TodayOverTimes = calendar:datetime_to_gregorian_seconds({{1,1,1},{Hour,Min,Sec}}),
	if
		TodayOverTimes > NowTimes->			%%杩樻病鍒颁粖澶╃殑杩囨湡鐐�,鍒欎粖澶╄繃鏈�,璁＄畻鍓╀綑鏃堕棿
		 	TodayOverTimes - NowTimes;
		true->							%%杩囦簡浠婂ぉ鐨勮繃鏈熺偣,璁＄畻鑷虫槑澶╄繃鏈熷墿浣欐椂闂�
			calendar:datetime_to_gregorian_seconds({{1,1,2},{Hour,Min,Sec}}) - NowTimes
	end.
	
should_be_actived_by_type(Type,ItemInfo)->
	case get_overdueinfo_from_iteminfo(ItemInfo) of
		{{0,0,0},_}->				%%绛夊緟琚縺娲荤姸鎬�
			get_overdue_type_from_iteminfo(ItemInfo)=:= Type;
		_->
			false
	end.

%%婵�娲荤墿鍝佽秴鏃�	
active_item_overdue(Itemid)->
	case get_item_info(Itemid) of
		[] -> 
			nothing;
		Iteminfo ->
			TemplateInfo = item_template_db:get_item_templateinfo(get_template_id_from_iteminfo(Iteminfo)),
			OverdueArgs = item_template_db:get_overdue_args(TemplateInfo),
			Now = timer_center:get_correct_now(),
			LeftTime_s = get_left_time_by_overdue_args(Now,OverdueArgs),
			set_item_overdue(Itemid,LeftTime_s)
	end.
	
%%璁剧疆鐗╁搧瓒呮椂鏃堕棿
set_item_overdue(Itemid,LeftTime_s)->
	Now = timer_center:get_correct_now(),
	case lists:keyfind(Itemid,1,get(items_info)) of
		false -> 
			nothing;
		{Itemid,Iteminfo,Cooldowninfo,_} ->
			put(items_info,lists:keyreplace(Itemid,1,get(items_info),{Itemid,set_overdueinfo_to_iteminfo(Iteminfo,{Now,LeftTime_s}),Cooldowninfo,1})),
			ChangeAttrs = [role_attr:to_item_attribute({lefttime_s,LeftTime_s})],
			ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(Itemid),
												get_highid_from_itemid(Itemid),
												ChangeAttrs,[]),
			Message = role_packet:encode_update_item_s2c([ChangeInfo]),
			role_op:send_data_to_gate(Message)
	end.	
	
%%
%%
%%
create_item_overdue(TemplateInfo)->
	case item_template_db:get_overdue_type(TemplateInfo) of
		?ITEM_OVERDUE_TYPE_NONE->
			[];
		?ITEM_OVERDUE_TYPE_OBTAIN->
			OverdueArgs = item_template_db:get_overdue_args(TemplateInfo),
			Now = timer_center:get_correct_now(),
			LeftTime_s = get_left_time_by_overdue_args(Now,OverdueArgs),
			{Now,LeftTime_s};
		_->
			OverdueArgs = item_template_db:get_overdue_args(TemplateInfo),
			Now = timer_center:get_correct_now(),
			LeftTime_s = get_left_time_by_overdue_args(Now,OverdueArgs),
			{{0,0,0},LeftTime_s}
	end.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%								鐗╁搧杩囨湡鐩稿叧end										%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_cooldowninfo(Itemid)->
	case lists:keyfind(Itemid,1,get(items_info)) of
		false ->
			slogger:msg("get_item_info error!Itemid:~p~n",[Itemid]),
			{{0,0,0},0};
		{Itemid,ItemInfo,_,_}->
			get_cooldowninfo_from_iteminfo(ItemInfo)
	end.

%%璁剧疆缁勭被鍨嬪喎鍗�
set_cooldowninfo(OriItemInfo,CoolDowninfo)->
	OriCategory = get_spellcategory_from_iteminfo(OriItemInfo), 
	if
		OriCategory =< 0->				%%涓嶅鐞嗗喎鍗�
			nothing;
		true->		
			lists:foreach( 
				fun({OtherItemid,OtherIteminfo,_,_})->
				case get_spellcategory_from_iteminfo(OtherIteminfo) =:= OriCategory of
					true->
						NewIteminfo = set_cooldowninfo_to_iteminfo(OtherIteminfo,CoolDowninfo),
						put(items_info,lists:keyreplace(OtherItemid,1,get(items_info),{OtherItemid,NewIteminfo,CoolDowninfo,1}));								
					false ->
						nothing
			end end,get(items_info))
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%											鐗╁搧淇℃伅											%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_item_info_by_pos(storage,Itemid)->
	build_fullinfo_by_item(get_item_info_storage(Itemid));
get_item_info_by_pos(_,Itemid)->	
	get_item_info(Itemid).

get_item_info(Itemid)->
	case lists:keyfind(Itemid,1,get(items_info)) of
		false ->
			[];
		{Itemid,ItemInfo,_,_}->
			ItemInfo
	end.	
	
get_item_info_storage(Itemid)->		
	case lists:keyfind(Itemid,1,get(storages_info)) of
		false ->
			slogger:msg("get_item_info error!Itemid:~p~n",[Itemid]),
			[];
		{Itemid,ItemInfo,_,_}->
		 	ItemInfo
	end.
		
get_bodyitem_template_ids()->
	BodyItemsIds = package_op:get_body_items_id(),
	lists:foldl(fun(Id,TmpIds)-> 
	case items_op:get_item_info(Id) of
		[]-> 
			TmpIds;
		Info ->
			[get_template_id_from_iteminfo(Info)|TmpIds]
	end end,[],BodyItemsIds).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%											鐗╁搧淇℃伅end										%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%											鐗╁搧鍒犻櫎											%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%export 鍒犻櫎韬笂鎴栬儗鍖呯墿鍝�,浣嗘槸涓嶄粠db涓垹闄�:鐢ㄤ簬浜ゆ槗澶勭悊
delete_item_from_itemsinfo_without_db(Itemid)->
	put(items_info,lists:keydelete(Itemid,1,get(items_info))).
%%export 鍒╃敤鎵�鍦ㄤ綅缃垹闄ょ墿鍝�
delete_item_from_itemsinfo_by_pos(storage,Itemid)->
	delete_item_from_itemsinfo_storage(Itemid);
delete_item_from_itemsinfo_by_pos(_,Itemid)->
	delete_item_from_itemsinfo(Itemid).	
	
%%private 鍒犻櫎浠撳簱鐗╁搧
delete_item_from_itemsinfo_storage(Itemid)->
	put(storages_info,lists:keydelete(Itemid,1,get(storages_info))),
	put(delete_items,lists:append(get(delete_items),[Itemid])).
%%private 鍒犻櫎韬笂鎴栬儗鍖呯墿鍝�
delete_item_from_itemsinfo(Itemid)->
	put(items_info,lists:keydelete(Itemid,1,get(items_info))),
	put(delete_items,lists:append(get(delete_items),[Itemid])).	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%											鐗╁搧鍒犻櫎end										%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%											璁剧疆涓暟											%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_item_count_by_pos(storage,Itemid,Count)->
	set_item_count_storage(Itemid,Count);

set_item_count_by_pos(_,Itemid,Count)->
	set_item_count(Itemid,Count).

set_item_count_storage(Itemid,Count)->
	AllInfo = get(storages_info),
	case lists:keyfind(Itemid,1,AllInfo) of
		false -> 
			slogger:msg("set_item_count_storage error!Itemid:~p~n",[Itemid]),
			nothing;
		{Itemid,Iteminfo,Cooldowninfo,_} ->	
			put(storages_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,Iteminfo#playeritems{count = Count},Cooldowninfo,1}))
	end.

set_item_count(Itemid,Count)->
	AllInfo = get(items_info),
	case lists:keyfind(Itemid,1,AllInfo) of
		false -> 
			slogger:msg("set_item_count error!Itemid:~p~n",[Itemid]),
			nothing;
		{Itemid,Iteminfo,Cooldowninfo,_} ->	
			put(items_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,set_count_to_iteminfo(Iteminfo,Count),Cooldowninfo,1}))
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%											璁剧疆涓暟end										%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%											璁剧疆妲戒綅											%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_item_slot_by_pos(storage,Itemid,Slot)->
	items_op:set_item_slot_storage(Itemid,Slot);
	
set_item_slot_by_pos(_,Itemid,Slot)->	
	items_op:set_item_slot(Itemid,Slot).
			
set_item_slot_storage(Itemid,Slot)->
	AllInfo = get(storages_info),
	case lists:keyfind(Itemid,1,AllInfo) of
		false -> 
			todo;
		{Itemid,PlayerItem,Cooldowninfo,_}->
			case package_op:where_slot(Slot) of
				storage->
					put(storages_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,PlayerItem#playeritems{slot = Slot},Cooldowninfo,1} ));
				_->
					put(storages_info,lists:keydelete(Itemid,1,AllInfo)),
					put(items_info,[{Itemid, build_fullinfo_by_item(PlayerItem#playeritems{slot = Slot}),Cooldowninfo,1} | get(items_info)])
			end
	end.
										
set_item_slot(Itemid,Slot)->
	AllInfo = get(items_info),
	case lists:keyfind(Itemid,1,AllInfo) of
		false -> 
			nothing;
	{Itemid,Iteminfo,Cooldowninfo,_}->
		case package_op:where_slot(Slot) of
			storage->
				put(items_info,lists:keydelete(Itemid,1,AllInfo)),
				put(storages_info,[{Itemid,build_item_by_fullinfo(set_slot_to_iteminfo(Iteminfo,Slot),Cooldowninfo),Cooldowninfo,1} | get(storages_info)]);
			_->	
				put(items_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,set_slot_to_iteminfo(Iteminfo,Slot),Cooldowninfo,1} ))
		end
	end.	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%											璁剧疆妲戒綅end										%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%											璁剧疆妲戒綅鍜屼釜鏁�									%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_item_slot_count_by_pos(storage,Itemid,Slot,Count)->
	set_item_slot_count_storage(Itemid,Slot,Count);

set_item_slot_count_by_pos(_,Itemid,Slot,Count)->
	set_item_slot_count(Itemid,Slot,Count).

set_item_slot_count_storage(Itemid,Slot,Count)->
	AllInfo = get(storages_info),
	case lists:keyfind(Itemid,1,AllInfo) of
		false -> 
			todo;
		{Itemid,PlayerItem,Cooldowninfo,_}->
			case package_op:where_slot(Slot) of
				storage->
					put(storages_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,PlayerItem#playeritems{slot = Slot,count = Count},Cooldowninfo,1} ));
				_->
					put(storages_info,lists:keydelete(Itemid,1,AllInfo)),
					put(items_info,[{Itemid, build_fullinfo_by_item(PlayerItem#playeritems{slot = Slot,count = Count}),Cooldowninfo,1} | get(items_info)])
			end
	end.
										
set_item_slot_count(Itemid,Slot,Count)->
	AllInfo = get(items_info),
	case lists:keyfind(Itemid,1,AllInfo) of
		false -> 
			todo;
	{Itemid,Iteminfo,Cooldowninfo,_}->
		case package_op:where_slot(Slot) of
			storage->
				put(items_info,lists:keydelete(Itemid,1,AllInfo)),
				put(storages_info,[{Itemid,build_item_by_fullinfo(Iteminfo#item_info{slot = Slot,count = Count},Cooldowninfo),Cooldowninfo,1} | get(storages_info)]);
			_->	
				put(items_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,Iteminfo#item_info{slot = Slot,count = Count},Cooldowninfo,1} ))
		end
	end.	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%											璁剧疆妲戒綅鍜屼釜鏁�									%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set_item_socketsInfo(Itemid,NewSocketsInfo)->
	AllInfo = get(items_info),
	case lists:keyfind(Itemid,1,AllInfo) of
		false -> 
			slogger:msg("set_item_socketsInfo error!Itemid:~p~n",[Itemid]),
			nothing;
		{Itemid,Iteminfo,Cooldowninfo,_} ->	
			put(items_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,set_socketsinfo_to_iteminfo(Iteminfo,NewSocketsInfo),Cooldowninfo,1}))
	end.

set_item_enchantInfo(Itemid,NewEnchantInfo)->
	AllInfo = get(items_info),
	case lists:keyfind(Itemid,1,AllInfo) of
		false -> 
			slogger:msg("set_item_enchantInfo error!Itemid:~p~n",[Itemid]),
			nothing;
		{Itemid,Iteminfo,Cooldowninfo,_} ->	
			put(items_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,set_enchant_to_iteminfo(Iteminfo,NewEnchantInfo),Cooldowninfo,1}))
	end.

%%by zhangting
get_item_enchantInfo(Itemid)->
	AllInfo = get(items_info),
	case lists:keyfind(Itemid,1,AllInfo) of
		false -> 
			slogger:msg("items:get_item_enchantInfo error!Itemid:~p~n",[Itemid]),
			nothing;
		{Itemid,Iteminfo,Cooldowninfo,_} ->	
			get_enchant_from_iteminfo(Iteminfo)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%										缁戝畾
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%return new ItemInfo	
hook_item_bond_by_type(Type,ItemInfo)->
	case (get_bonding_from_iteminfo(ItemInfo)=:=Type) and (get_isbonded_from_iteminfo(ItemInfo)=:=0 ) of
		true->
			set_item_isbonded(get_id_from_iteminfo(ItemInfo),1);
		_->		
			ItemInfo
	end.

%%return ItemInfo	
set_item_isbonded(Itemid,NewBonding)->
	AllInfo = get(items_info),
	case lists:keyfind(Itemid,1,AllInfo) of
		false -> 
			slogger:msg("set_item_isbonded error!Itemid:~p~n",[Itemid]),
			[];
		{Itemid,Iteminfo,Cooldowninfo,_} ->	
			NewItemInfo = set_isbonded_to_iteminfo(Iteminfo,NewBonding),
			put(items_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,NewItemInfo,Cooldowninfo,1})),
			ChangeAttrs = [role_attr:to_item_attribute({isbonded,NewBonding})],
			ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(Itemid),
												get_highid_from_itemid(Itemid),
												ChangeAttrs,[]),
			Message = role_packet:encode_update_item_s2c([ChangeInfo]),
			role_op:send_data_to_gate(Message),
			NewItemInfo
	end.	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%										缁戝畾end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%杩斿洖nothing/NewDuration
resume_item_duration(Itemid)->
	resume_item_duration(Itemid,1).
	
resume_item_duration(Itemid,N)->
	AllInfo = get(items_info),
	case lists:keyfind(Itemid,1,AllInfo) of
		false -> 
			slogger:msg("resume_item_duration error!Itemid:~p~n",[Itemid]),
			nothing;
		{Itemid,Iteminfo,Cooldowninfo,_} ->	
			case get_duration_from_iteminfo(Iteminfo) of
				0->
					nothing;
				Duration->
					NewDuration = erlang:max(Duration - N,0),
					case get_useable_from_iteminfo(Iteminfo) of
						1->
							if
								NewDuration =:= 0->
									Destroy = true;
								true->	
									Destroy = false
							end;
						0->
							Destroy = false
					end,
					if
						Destroy->
							role_op:proc_destroy_item(Iteminfo,consume_up);
						true->	
							ChangesAttr = [role_attr:to_item_attribute({duration,NewDuration})],
							ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(Itemid),get_highid_from_itemid(Itemid),ChangesAttr,[]),
							Message = role_packet:encode_update_item_s2c([ChangeInfo]),
							role_op:send_data_to_gate(Message),
							put(items_info,lists:keyreplace(Itemid,1,AllInfo,{Itemid,set_duration_to_iteminfo(Iteminfo,NewDuration),Cooldowninfo,1}))
					end,
					NewDuration
			end		
	end.
			

%%瑁呭淇悊娑堣�楅挶甯�=锛堬紙鏈�澶ц�愪箙搴�-褰撳墠鑰愪箙搴︼級*瑁呭鍩虹娑堣��*锛�1+锛�2*鏈�澶ц�愪箙搴�-褰撳墠鑰愪箙搴︼級^2/40000)
%%杩斿洖:Money
get_item_repair_money(Iteminfo)->
	BaseValue = get_baserepaired_from_iteminfo(Iteminfo),
	MaxDuration = get_maxduration_from_iteminfo(Iteminfo),
	case get_duration_from_iteminfo(Iteminfo) of
		MaxDuration->
			0;			
		Duration->
			erlang:trunc((MaxDuration - Duration)*BaseValue*(1+(2*MaxDuration - Duration)*(2*MaxDuration - Duration)/40000))
	end.
		
create_objects_with_ownerid(Slot,TemplateId,Count,OwnerId,CoolDownArgh)->
		TemplateInfo = item_template_db:get_item_templateinfo(TemplateId),
		BondType = item_template_db:get_bonding(TemplateInfo),
		Id = itemid_generator:gen_newid(),
		%%澶勭悊缁戝畾
		if BondType =:= ?ITEM_BIND_TYPE_OBTAIN -> %%bind when pick
				IsBond = 1;
			true->
				IsBond = 0
		end,
		%%澶勭悊鍐峰嵈
		if
			CoolDownArgh=:=[]->
				CoolDownInfo = {{0,0,0},0};
			true->
				CoolDownInfo = CoolDownArgh,
				nothing
		end,
		%%澶勭悊杩囨湡
		OverDueInfo = create_item_overdue(TemplateInfo),
		ChentInfo = item_template_db:get_enchant_ext(TemplateInfo), 
		BaseInfo = create_item_baseinfo(Id,OwnerId,TemplateId,0,Count,Slot,IsBond ,[],0,CoolDownInfo,ChentInfo,OverDueInfo),
		FullInfo_Noduration = set_protoinfo_to_iteminfo(BaseInfo,TemplateInfo),
		FullInfo = set_duration_to_iteminfo(FullInfo_Noduration,get_maxduration_from_iteminfo(FullInfo_Noduration)),
		if
			Slot < ?SLOT_PACKAGE_ENDEX->
				add_item_to_itemsinfo(FullInfo);
			true->
				nothing
		end,
		{Id,FullInfo}.

create_objects(Slot,TemplateId,Count,CoolDownInfo)->
	create_objects_with_ownerid(Slot,TemplateId,Count,get(roleid),CoolDownInfo).

create_objects(Slot,TemplateId,Count)->
	create_objects_with_ownerid(Slot,TemplateId,Count,get(roleid),[]).

obtain_from_trade_by_items(PlayerItems)->
	Length = erlang:length(PlayerItems),
	case package_op:get_empty_slot_in_package(Length) of
		0->
			slogger:msg("obtain_from_trade_by_items ERROR !! not engouh empty slots ~p ,PlayerItems ~p ~n",[get(roleid),PlayerItems]),
			full;			%%TODO:maybe mail
		Slots->	
			lists:foreach(fun(Index)->
				Slot = lists:nth(Index,Slots),
				PlayerItemTmp = lists:nth(Index,PlayerItems),
				obtain_item_by_item_base(PlayerItemTmp,Slot,got_tradplayer)
			end,lists:seq(1,Length))
	end.

obtain_from_mail_by_itemids([])->
	ok;	
obtain_from_mail_by_itemids(ItemIds)->
	Length = erlang:length(ItemIds),
	case package_op:get_empty_slot_in_package(Length) of
		0->
			full;
		Slots->	
			lists:foreach(fun(Index)->
				ItemId = lists:nth(Index,ItemIds),
				Slot = lists:nth(Index,Slots),
				case playeritems_db:load_item_info(ItemId,get(roleid)) of 
						[]->
							nothing;
						[PlayerItemDb]->
							PlayerItem = make_playeritem_by_db(PlayerItemDb),	
							obtain_item_by_item_base(PlayerItem,Slot,getmail),
							ItemInfo = build_fullinfo_by_item(PlayerItem),
							ItemProto = get_template_id_from_iteminfo(ItemInfo),
							Count = get_count_from_iteminfo(ItemInfo),
							creature_sysbrd_util:sysbrd({mail,ItemProto},Count)
				end end,lists:seq(1,Length) )
	end.
	
obtain_from_gm_mail_send(RoleId,Slot,TemplateId,Count)->
	{ItemId,ItemsInfo} = items_op:create_objects_with_ownerid(Slot,TemplateId,Count,RoleId,[]),
	Enchantments = get_enchantments_from_iteminfo(ItemsInfo),
	Isbonded = get_isbonded_from_iteminfo(ItemsInfo),
	Sockets = get_socketsinfo_from_iteminfo(ItemsInfo),
	Duration = get_duration_from_iteminfo(ItemsInfo),
	CoolDownInf = get_cooldowninfo_from_iteminfo(ItemsInfo),
	Enchant = get_enchant_from_iteminfo(ItemsInfo),
	OverdueInfo = get_overdueinfo_from_iteminfo(ItemsInfo),
	playeritems_db:add_playeritems(ItemId,RoleId,TemplateId,Enchantments,Count,Slot,Isbonded,Sockets,Duration,CoolDownInf,Enchant,OverdueInfo),
	ItemId.

obtain_from_auction_by_playeritem(PlayerItem,Slot,Reason)->
	obtain_item_by_item_base(PlayerItem,Slot, Reason).

lost_from_trad_by_slot(Slot)->
	role_op:proc_destroy_item_without_db(Slot,lost_tradplayer).
	
lost_from_stall_by_playeritem(PlayerItem)->
	MyId = get(roleid),
	OldTable = db_split:get_owner_table(playeritems,MyId),
	#playeritems{
		id = ItemId,
		entry = Entry,
		enchantments = Enchantments,
		count = Count,
		slot = Slot,
		isbond = Isbonded,
		sockets = Sockets,
		cooldowninfo = CoolDownInfo,
		duration = Duration,
		enchant = Enchant,
		overdueinfo = Overdueinfo} = PlayerItem,
	role_op:proc_destroy_item_without_db(Slot,lost_up_stall),
	playeritems_db:add_playeritems(OldTable,ItemId,{stall,MyId},Entry,Enchantments,Count,0,Isbonded,Sockets,Duration,CoolDownInfo,Enchant,Overdueinfo).
		
%%杩斿洖:澶卞幓鐨勭墿鍝佹ā鏉縤d鍜屼釜鏁�
lost_from_mail_by_itemids(ItemIds,SendRoleId)->
	MyId = get(roleid),
	OldTable = db_split:get_owner_table(playeritems,MyId),
	NewTable = db_split:get_owner_table(playeritems, SendRoleId),
	ItemInfos = lists:map(fun(ItemId)-> get_item_info(ItemId) end,ItemIds),
	lists:map(fun(ItemInfo)-> 
						ItemId = get_id_from_iteminfo(ItemInfo),
						OldSlot = get_slot_from_iteminfo(ItemInfo),
						TmplateId = get_template_id_from_iteminfo(ItemInfo),
						ItemCount =  get_count_from_iteminfo(ItemInfo),
						role_op:proc_destroy_item_without_db(OldSlot,sendmail),
						%%鐩存帴浠庢暟鎹簱鍒犻櫎璇ョ墿鍝�!
						if
							NewTable =/= OldTable->
								playeritems_db:del_playeritems(OldTable,ItemId,MyId);
							true->
								nothing
						end,
						modify_item_to_other_mail(SendRoleId,ItemInfo),
						{TmplateId,ItemCount}
					end,ItemInfos ).	
					
%%娣诲姞璇ョ墿鍝佸埌瀵规柟鏁版嵁搴�
modify_item_to_other_mail(SendRoleId,ItemInfo) when is_record(ItemInfo, item_info)->
	modify_item_to_other_mail(SendRoleId,build_item_by_fullinfo(ItemInfo));
	
%%娣诲姞璇ョ墿鍝佸埌瀵规柟鏁版嵁搴�
modify_item_to_other_mail(SendRoleId,PlayerItem) when is_record(PlayerItem, playeritems)->	
	Slot  = ?MAIL_SLOT,
	NewPlayerItem = PlayerItem#playeritems{slot=Slot,ownerguid=SendRoleId},
	NewTable = db_split:get_owner_table(playeritems, SendRoleId),
	playeritems_db:add_playeritems(NewTable,NewPlayerItem).	

%%浠庡疄浣撻噷鑾峰彇鐗╁搧	
obtain_item_by_item_base(PlayerItemTmp,SlotNum,Reason)->
	MyId = get(roleid),
	#playeritems{id = ItemId,ownerguid =SendRoleId,entry = ItemProto} = PlayerItemTmp,
	OldTable = db_split:get_owner_table(playeritems,SendRoleId),
	NewTable = db_split:get_owner_table(playeritems,MyId),
	if
		NewTable =/= OldTable->
			playeritems_db:del_playeritems(OldTable,ItemId,SendRoleId);
		true->
			nothing
	end,
	PlayerItem = PlayerItemTmp#playeritems{ownerguid = MyId,slot = SlotNum},
	ItemInfo = items_op:build_fullinfo_by_item(PlayerItem),
	add_item_to_itemsinfo(ItemInfo),
	ItemCount = get_count_from_iteminfo(ItemInfo),
	package_op:set_item_to_slot(SlotNum,ItemId,ItemCount),
	quest_op:update({obt_item,ItemProto}),	
	Message = role_packet:encode_add_item_s2c(ItemInfo),
	role_op:send_data_to_gate(Message),
	gm_logger_role:role_get_item(MyId,ItemId,ItemCount,ItemProto,Reason,get(level)),
	sync_save_iteminfo(NewTable,ItemInfo).	
	

%%鍦ㄥ凡鏈夋Ы涓婂爢鍙犵墿鍝�		
auto_stack_to_slots(Count,StackSlots,MaxStack)->
	{Left,NeedSendInfos,RelationIds} = 
		lists:foldl(fun(SlotNum,{LeftNum,TmpChangedInfo,TmpIds})->
				if 
					LeftNum > 0 ->
						{Itemid,OldCount} = package_op:get_item_id_and_count_in_slot(SlotNum),	
						NewCount = erlang:min(MaxStack,OldCount+LeftNum),				 
						package_op:set_item_to_slot(SlotNum,Itemid,NewCount),
						items_op:set_item_count(Itemid,NewCount),								
						ChangeAttrs = [role_attr:to_item_attribute({count,NewCount})],
						ChangeInfo = role_attr:to_item_changed_info(get_lowid_from_itemid(Itemid),
																	get_highid_from_itemid(Itemid),
																	ChangeAttrs,[]),
						{LeftNum - (MaxStack - OldCount),TmpChangedInfo++[ChangeInfo],TmpIds ++ [Itemid]};
					true->
						{LeftNum,TmpChangedInfo,TmpIds}
				end																			
			end
		,{Count,[],[]},StackSlots),			
		%%鍙戦�佸鎴风鐗╁搧鐘舵�佹敼鍙�																													
		Message = role_packet:encode_update_item_s2c(NeedSendInfos),
		role_op:send_data_to_gate(Message),
		{Left,RelationIds}.		
		
auto_multi_create(Count,EmptySlots,MaxStack,ItemProtoId)->
		{_,ItemIds} = lists:foldl(fun(SlotNum,{LeftNum,TmpId})->
					if 
						LeftNum > 0 -> 			
							ItemCount = erlang:min(MaxStack,LeftNum),
							{Id,ItemInfo} = create_objects(SlotNum,ItemProtoId,ItemCount),
							package_op:set_item_to_slot(SlotNum,Id,ItemCount),						%%鍔犲叆鑳屽寘
							Message = role_packet:encode_add_item_s2c(ItemInfo),
							role_op:send_data_to_gate(Message),							
							{LeftNum - MaxStack,TmpId ++ [Id]};
						true ->
							{LeftNum,TmpId}
					end														
				end
			,{Count,[]},EmptySlots),
		ItemIds.			
		
get_items_by_template(Id)->	       
       ItemIds = package_op:get_items_id_on_hands(),
       S = fun(ItemId)->
	  		is_item_template(ItemId,Id)
	   end,
      lists:filter(S,ItemIds).			

get_items_by_class_sort_by_bond(ClassId)->
   	ItemIds = lists:reverse(package_op:get_items_id_on_hands()),
    {NotBondItems,BondedItems} = 
    lists:foldl(fun(ItemId,{AccItemsNotBond,AccItemsBond})-> 
		case get_item_info(ItemId) of
			[]->
				{AccItemsNotBond,AccItemsBond};
			ItemInfo->	
				case get_class_from_iteminfo(ItemInfo) of
					ClassId->
				   		case get_isbonded_from_iteminfo(ItemInfo) of
				   			0->		%%not bond
				   				{[ItemId|AccItemsNotBond],AccItemsBond};
				   			_->
				   				{AccItemsNotBond,[ItemId|AccItemsBond]}
				   		end;	
				   	_->
				   		{AccItemsNotBond,AccItemsBond}
				end
		end
	end,{[],[]},ItemIds),
	BondedItems++NotBondItems.
	
is_item_template(ItemId,TmplateId)->
	case get_item_info(ItemId) of
		[]->
			false;
		Item->	
			case get_template_id_from_iteminfo(Item) of
				TmplateId->
					true;
				_->
					false
			end
	end.	

%%姣旇緝涓や釜鐗╁搧鐨勪紭鍔�,鎸� 鍝佽川->鐗╁搧绛夌骇->鏄熺骇->瀛旀暟 鏉ユ瘮杈�
is_item_better_than(ItemInfo1,ItemInfo2)->
	Qua1 = get_qualty_from_iteminfo(ItemInfo1),
	Qua2 = get_qualty_from_iteminfo(ItemInfo2),
	case is_bigger_than(Qua1,Qua2) of
		equal->
			Lv1 = get_level_from_iteminfo(ItemInfo1),
			Lv2 = get_level_from_iteminfo(ItemInfo2),
			case is_bigger_than(Lv1,Lv2)of
				equal->
					Enchantments1 = get_enchantments_from_iteminfo(ItemInfo1),
					Enchantments2 = get_enchantments_from_iteminfo(ItemInfo2),	
					case is_bigger_than(Enchantments1,Enchantments2) of
						equal->	
							SockNum1 = length(get_socketsinfo_from_iteminfo(ItemInfo1)),
							SockNum2 = length(get_socketsinfo_from_iteminfo(ItemInfo2)),
							case is_bigger_than(SockNum1,SockNum2) of
								true->
									true;
								_->
									false
							end;			
						EncRe->	
							EncRe
					end;
				LevRe->
					LevRe
			end;
		QuaRe->
			QuaRe
	end.

%%return true/false/equal	
is_bigger_than(A,B)->
	if
		A>B->
			true;
		A=:=B->
			equal;
		true->
			false
	end.					

get_lost_reason_for_client(Reason)->
	case Reason of
		lost_over_due->
			?ITEM_DESTROY_NOTICE_OVERDUE;
		role_destroy->
			?ITEM_DESTROY_NOTICE_CONSUMEUP;
		consume_up->
			?ITEM_DESTROY_NOTICE_CONSUMEUP;
		lost_up_stall->
			?ITEM_DESTROY_NOTICE_STALL;
		lost_tradplayer->
			?ITEM_DESTROY_NOTICE_TRADROLE;
		sendmail->      
			?ITEM_DESTROY_NOTICE_SENDMAIL;
		_->
			?ITEM_DESTROY_NOTICE_NONE
	end.
			
%%鎵ц鐗╁搧鑴氭湰
exec_item_beam(Mod,Args)->
	try 
		case erlang:apply(Mod,use_item,Args) of
			true->
				ok;
			_->
				error
		end			
	catch
		_Errno:Reason -> 	
			slogger:msg("exec_item_beam Mod ~p Fun ~p ~p ~p~n",[Mod,Args,Reason,erlang:get_stacktrace()]),
			error
	end.
exec_egg_beam(Mod,Args)->
	try 
		case erlang:apply(Mod,use_egg,Args) of
			true->
				ok;
			_->
				error
		end			
	catch
		_Errno:Reason -> 	
			slogger:msg("exec_item_beam Mod ~p Fun ~p ~p ~p~n",[Mod,Args,Reason,erlang:get_stacktrace()]),
			error
	end.
	


     
      
