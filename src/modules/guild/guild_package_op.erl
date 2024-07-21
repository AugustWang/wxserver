%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-3-21
%% Description: TODO: Add description to guild_package_op
-module(guild_package_op).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("guild_define.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
-include("system_chat_define.hrl").
-include("instance_define.hrl").
-include("activity_define.hrl").
-include("map_info_struct.hrl").
-include("guild_def.hrl").
-define(STRING_LBRACKET,118).
-define(STRING_RBRACKET,119).
-define(GUILD_PACKAGE_NUM,2000).
-define(GUILD_PACKAGE_MAX_NUM,120).
-define(GUILD_SLOT_NUM,5000).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%



%%
%% Local Functions
%%
%%获得帮会仓库大小通过等级
get_guild_package_size_of_level(Level)->
	case Level of
		1->
			30;
		2->
			40;
		3->
			55;
		4->
			75;
		5->
			85;
		6->
			100;
		7->
			110;
		8->
			125;
		9->
			135;
		10->
			150;
		Other->
			30
	end.

init_guild_package(GuildBaseInfo,RoleId)->
	{NowNum,MaxNum}=guild_proto_db:get_guild_package(GuildBaseInfo),
	PackageLimite=guild_proto_db:get_guild_package_limit(GuildBaseInfo),
	GuildId=guild_proto_db:get_guild_id(GuildBaseInfo),
	Limit=lists:map(fun({Type,State})->
										  guild_packet:make_oprate_state(Type,State) end,PackageLimite),
	case guild_proto_db:get_guilditem_by_guildid(GuildId) of
		[]->
				Message=guild_packet:encode_guild_storage_init_s2c([],Limit,MaxNum),
				role_pos_util:send_to_role_clinet(RoleId,Message);
		ItemInfo->
					GiItem= lists:map(fun(GuildItemInfo)->
											  guild_handle:make_guilditem_s2c(GuildItemInfo,MaxNum-NowNum)
										    end , ItemInfo),
					Message=guild_packet:encode_guild_storage_init_s2c(GiItem,Limit,MaxNum),
					role_pos_util:send_to_role_clinet(RoleId,Message)
	end.			

%%帮会仓库存储物品
guild_package_instore_item(ItemInfo,GCount,RoleId)->
		IsBound=playeritems_db:get_isbond(ItemInfo),
		StackNum=get_stackable_from_iteminfo(ItemInfo),
		SrcCount=GCount,
		if IsBound=:=0->
				ItemId=get_template_id_from_iteminfo(ItemInfo),
				case guild_spawn_db:get_guildinfo_of_member(RoleId ) of
					  []->
						      ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_UNKNOWN),
		  					role_op:send_data_to_gate(ErrnoMsg);
				   MemberDbInfo->
					 	GuildId = guild_spawn_db:get_guildid_by_memberinfo(MemberDbInfo),
						GuildBanseInfo=guild_spawn_db:get_guildinfo(GuildId),
						{NowNum,MaxNum}=guild_proto_db:get_guild_package(GuildBanseInfo),
						put(nowsize,NowNum),
						put(maxsize,MaxNum),
				case  guild_proto_db:get_noidel_guilditem_by_guildid(GuildId) of
				GuildItemsInfo->
									case  get_item_slot_and_itemid_and_count(GuildItemsInfo,ItemId,StackNum) of
										[]->	 	     %%没有当前东西重新创建
										guild_manager_op:send_to_role_delete_item(ItemInfo, SrcCount, RoleId),
										NewGuildItemInfo= remain_items_in_slot(ItemInfo,SrcCount,GuildItemsInfo,RoleId,GuildId),
										 RemainSlot=MaxNum-NowNum-1,
										 ItemGi=guild_handle:make_guilditem_s2c(NewGuildItemInfo,RemainSlot),
										 Message=guild_packet:encode_guild_storage_add_item_s2c([ItemGi]),
										role_pos_util:send_to_role_clinet(RoleId,Message),
										guild_manager_op:broad_cast_to_guild_role(GuildId, {guild_message,{reset_guild_package_falg,0}});
										GItemInfo->
											Count=guild_proto_db:get_item_count_from_guilditem(GItemInfo),
											Slot=guild_proto_db:get_item_slot_from_guilditem(GItemInfo),
												if (StackNum>1) and ((SrcCount+Count)=<StackNum)->%%可以叠加
														NewGuild=GItemInfo#guilditems{count=Count+SrcCount},
														 guild_manager_op:send_to_role_delete_item(ItemInfo, SrcCount, RoleId),
														 ItemGi=guild_handle:make_guilditem_s2c(NewGuild,MaxNum- NowNum),
														 Message=guild_packet:encode_guild_storage_add_item_s2c([ItemGi]),
														role_contribute_to_guild_package(RoleId,GuildId,ItemId,1,SrcCount),
														instore_guild_items(NewGuild);
												   (StackNum>1) and (SrcCount+Count)>StackNum->%%叠加并创建新物品
														NewGuild=GItemInfo#guilditems{count=StackNum},
													   	ItemGi1=guild_handle:make_guilditem_s2c(NewGuild,NowNum),
													   	instore_guild_items(NewGuild),
														 guild_manager_op:send_to_role_delete_item(ItemInfo, SrcCount+Count-StackNum, RoleId),
														role_contribute_to_guild_package(RoleId,GuildId,ItemId,1,SrcCount+Count-StackNum),
													   NewGuildItenInfo2=remain_items_in_slot(ItemInfo,SrcCount+Count-StackNum,GuildItemsInfo,RoleId,GuildId),
													    RemainSlot2=get_remain_slot(),
													   ItemGi2=guild_handle:make_guilditem_s2c(NewGuildItenInfo2,MaxNum-NowNum-1),
													   Message=guild_packet:encode_guild_storage_add_item_s2c([ItemGi1]++[ItemGi2]);
												   true->                                                         %% 不可叠加创建新物品
													    role_op:consume_item(ItemInfo, SrcCount),
													    NewGuildItemInfo=remain_items_in_slot(ItemInfo,1,GuildItemsInfo,RoleId,GuildId),
														if NewGuildItemInfo=:=false->Message=[];%%判断等到slot没有
														   true->
																	ItemGi=guild_handle:make_guilditem_s2c(NewGuildItemInfo,MaxNum-get(nowsize)),
																	Message=guild_packet:encode_guild_storage_add_item_s2c([ItemGi])
														end
												end,
												if Message=:=[]->
													    ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_UNKNOWN),
		  												role_op:send_data_to_gate(ErrnoMsg);
												   true->
														role_pos_util:send_to_role_clinet(RoleId,Message),
														guild_manager_op:broad_cast_to_guild_role(GuildId, {guild_message,{reset_guild_package_falg,0}})
												end
											end
									end,
							Nowsize=get(nowsize),
							Maxsize=get(maxsize),
							guild_spawn_db:set_guild_package(GuildId, {Nowsize,Maxsize})%%更新背包当前存储信息的大小
						end;
				true->
						nothing
	end.

%%帮会副本掉落物品存入帮会仓库
guild_package_instore_item_of_instance(ProtoId,GCount,GuildId)->
		IsBound=0,
	case item_template_db:get_item_templateinfo(ProtoId) of
		[]->nothing;
		ProtoItemInfo->
				StackNum=item_template_db:get_stackable(ProtoItemInfo),
				SrcCount=GCount,
						GuildBanseInfo=guild_spawn_db:get_guildinfo(GuildId),
						{NowNum,MaxNum}=guild_proto_db:get_guild_package(GuildBanseInfo),
						put(nowsize,NowNum),
						put(maxsize,MaxNum),
				case  guild_proto_db:get_noidel_guilditem_by_guildid(GuildId) of
				GuildItemsInfo->
									case  get_item_slot_and_itemid_and_count(GuildItemsInfo,ProtoId,StackNum) of
										[]->	 	     %%没有当前东西重新创建
										NewGuildItemInfo= remain_items_in_slot_of_instance(ProtoId,SrcCount,GuildItemsInfo,GuildId),
										 RemainSlot=MaxNum-NowNum-1,
										 ItemGi=guild_handle:make_guilditem_s2c(NewGuildItemInfo,RemainSlot),
										 Message=guild_packet:encode_guild_storage_add_item_s2c([ItemGi]),
										guild_manager_op:broad_cast_to_guild_role(GuildId, Message);
										GItemInfo->
											Count=guild_proto_db:get_item_count_from_guilditem(GItemInfo),
											Slot=guild_proto_db:get_item_slot_from_guilditem(GItemInfo),
												if (StackNum>1) and ((SrcCount+Count)=<StackNum)->%%可以叠加
														NewGuild=GItemInfo#guilditems{count=Count+SrcCount},
														 ItemGi=guild_handle:make_guilditem_s2c(NewGuild,MaxNum- NowNum),
														 Message=guild_packet:encode_guild_storage_add_item_s2c([ItemGi]),
														instore_guild_items(NewGuild);
												   (StackNum>1) and (SrcCount+Count)>StackNum->%%叠加并创建新物品
														NewGuild=GItemInfo#guilditems{count=StackNum},
													   	ItemGi1=guild_handle:make_guilditem_s2c(NewGuild,NowNum),
													   	instore_guild_items(NewGuild),
													   NewGuildItenInfo2=remain_items_in_slot_of_instance(ProtoId,SrcCount+Count-StackNum,GuildItemsInfo,GuildId),
													    RemainSlot2=get_remain_slot(),
													   ItemGi2=guild_handle:make_guilditem_s2c(NewGuildItenInfo2,MaxNum-NowNum-1),
													   Message=guild_packet:encode_guild_storage_add_item_s2c([ItemGi1]++[ItemGi2]);
												   true->                                                         %% 不可叠加创建新物品
													    NewGuildItemInfo=remain_items_in_slot_of_instance(ProtoId,1,GuildItemsInfo,GuildId),
														if NewGuildItemInfo=:=false->Message=[];%%判断等到slot没有
														   true->
																	ItemGi=guild_handle:make_guilditem_s2c(NewGuildItemInfo,MaxNum-get(nowsize)),
																	Message=guild_packet:encode_guild_storage_add_item_s2c([ItemGi])
														end
												end,
												if Message=:=[]->
													    ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_UNKNOWN),
		  												role_op:send_data_to_gate(ErrnoMsg);
												   true->
														guild_manager_op:broad_cast_to_guild_role(GuildId, Message)
												end
											end
									end,
							Nowsize=get(nowsize),
							Maxsize=get(maxsize),
							guild_spawn_db:set_guild_package(GuildId, {Nowsize,Maxsize})%%更新背包当前存储信息的大小
	end.

%%设置帮会仓库物品状态
guild_storage_set_item_state(ItemId,State,GuildId)->
	case guild_proto_db:get_guilditem_by_guildid(GuildId) of
		[]->
			Errno=?GUILD_ERRNO_ITEM_NOT_ENOUGH;
		GuildPackageItems->
			case lists:keyfind(ItemId,#guilditems.id, GuildPackageItems) of
				false->
						Errno=?GUILD_ERRNO_ITEM_NOT_ENOUGH;
				ItemInfo->
					Errno=[],
					NewItemInfo=guild_proto_db:set_item_state_from_guildinfo(ItemInfo, State),
					GuildBanseInfo=guild_spawn_db:get_guildinfo(GuildId),
					{NowNum,MaxNum}=guild_proto_db:get_guild_package(GuildBanseInfo),
					 ItemGi=guild_handle:make_guilditem_s2c(NewItemInfo,MaxNum- NowNum),
					Message=guild_packet:encode_guild_storage_add_item_s2c([ItemGi]),
					guild_manager_op:broad_cast_to_guild_client(GuildId, Message),
					instore_guild_items(NewItemInfo)
			end
	end,
	if Errno=/=[]->
			 ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(Errno),
			role_op:send_data_to_gate(ErrnoMsg);
	true->nothing
end.

%%帮会仓库物品整理
guild_storage_sort_items(GuildId)->
	GuildBaseInfo=guild_spawn_db:get_guildinfo(GuildId),
	if GuildBaseInfo=:=[]->
		   ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_NOT_IN_GUILD),
			role_op:send_data_to_gate(ErrnoMsg);
	   true->
		   	{NowNum,MaxNum}=guild_proto_db:get_guild_package(GuildBaseInfo),
			PackageLimite=guild_proto_db:get_guild_package_limit(GuildBaseInfo),
			Limit=lists:map(fun({Type,State})->
										  guild_packet:make_oprate_state(Type,State) end,PackageLimite),
			IdelItemsInfo=guild_storage_sort_idel_item(GuildId),
			NoIdelItemsInfo=guild_storage_sort_noidel_item(GuildId),
			ItemsInfos=IdelItemsInfo++NoIdelItemsInfo,
			%case guild_proto_db:get_guilditem_by_guildid(GuildId) of
			case ItemsInfos of
				[]->
					Message=guild_packet:encode_guild_storage_init_s2c([],Limit,MaxNum),
						guild_manager_op:broad_cast_to_guild_client(GuildId, Message);
				GuildStorageItems->
					SortGuildStorageItems=lists:keysort(#guilditems.state, GuildStorageItems),
					NewSortItems=lists:reverse(SortGuildStorageItems),
					NewItemsInfo=reset_guild_storage_slot(NewSortItems),
					guild_proto_db:delete_all_object_from_guildpackage(),
					GiItem= lists:map(fun(GuildItemInfo)->
											  guild_handle:make_guilditem_s2c(GuildItemInfo,MaxNum-NowNum)
										    end , NewItemsInfo),
					Message=guild_packet:encode_guild_storage_init_s2c(GiItem,Limit,MaxNum),
					guild_manager_op:broad_cast_to_guild_client(GuildId, Message),
					lists:map(fun(ItemInfo)->
									  instore_guild_items(ItemInfo) end, NewItemsInfo)
			end
end.

guild_storage_sort_idel_item(GuildId)->
	case guild_proto_db:get_idel_guilditem_by_guildid(GuildId) of
		[]->
			[];
		IdelItemsInfo->
			stack_all_items_info(IdelItemsInfo)
	end.
guild_storage_sort_noidel_item(GuildId)->
	case guild_proto_db:get_noidel_guilditem_by_guildid(GuildId) of
		[]->
			[];
		NoIdelItemsInfo->
			stack_all_items_info(NoIdelItemsInfo)
	end.
%%因为闲置和非闲置物品都是同样的整理方式，所以功能放在一个函数中
stack_all_items_info(AllItemsInfo)->
				lists:foldl(fun(Info,Acc)->
								ItemId=guild_proto_db:get_item_proto_id_from_guilditem(Info),
								case lists:keyfind(ItemId, #guilditems.entry, Acc) of
									false->
										{SameItemsInfo,AllCount}=
											lists:foldl(fun(ItemInfo,{Acc1,Acc2})->
															ItemProtoId=guild_proto_db:get_item_proto_id_from_guilditem(ItemInfo),
															ItemCount=guild_proto_db:get_item_count_from_guilditem(ItemInfo),
															if ItemProtoId=:=ItemId->
																   {[ItemInfo]++Acc1,Acc2+ItemCount};
															   true->
																  {Acc1,Acc2}
															end end, {[],0},AllItemsInfo),
										case item_template_db:get_item_templateinfo(ItemId) of
											[]->
												Acc;
											ProtoInfo->
												ProtoStack=item_template_db:get_stackable(ProtoInfo),
												if ProtoStack=:=1->
													   SameItemsInfo++Acc;
												 true->
													ItemNum=AllCount div  ProtoStack,
													if ItemNum>=1->
														   ItemsInfo=get_stack_itemsinfo(Info,[],ItemNum,ProtoStack),
														   ReminNum=AllCount rem ProtoStack,
														   if ReminNum>0->
															   Id=itemid_generator:gen_newid(),
															   ReminInfo=Info#guilditems{id=Id,count=ReminNum},
															   [ReminInfo]++ItemsInfo++Acc;
															  true->
																  ItemsInfo++Acc
														   end;
													true->
														NewInfo=Info#guilditems{count=AllCount},
														[NewInfo]++Acc
													end
												end
										end;
									Other->
										Acc
								end end, [], AllItemsInfo).
%%整理时相同放物品可叠加
get_stack_itemsinfo(Info,Infos,Num,Stack)->
	if Num>0->
		ItemId=itemid_generator:gen_newid(),
		NewInfo=Info#guilditems{id=ItemId,count=Stack},
		get_stack_itemsinfo(Info,[NewInfo]++Infos,Num-1,Stack);
	true->
		Infos
	end.
		
		
%%整理后重置帮会仓库物品槽位		
reset_guild_storage_slot(SortItems)->
	Len=erlang:length(SortItems),
	SortList=lists:seq(?GUILD_SLOT_NUM+1,?GUILD_SLOT_NUM+Len),
	GuildItemsInfo=lists:zipwith(fun(Info,Slot)->
						  guild_proto_db:set_item_slot_from_guilditem(Info, Slot) end,SortItems, SortList),
	GuildItemsInfo.
	
	
instore_guild_items(GuildItems)->
	guild_proto_db:add_guilditem_into_package(GuildItems),
	guild_proto_db:update_guilditem_info(GuildItems).

delete_guild_items(Key)->
	guild_proto_db:delete_guilditem_from_package(Key),
	guild_proto_db:update_delete_guild_info(Key).


 remain_items_in_slot(ItemInfo,Count,GuildItemsInfo,RoleId,GuildId)->
	   				Protoid = get_template_id_from_iteminfo(ItemInfo),
	   				Enchantments = get_enchantments_from_iteminfo(ItemInfo),
	  				 Isbonded = get_isbonded_from_iteminfo(ItemInfo),
	   				Socketsinfo = get_socketsinfo_from_iteminfo(ItemInfo),
	  				 Duration = get_duration_from_iteminfo(ItemInfo),
					Coordown= get_cooldowninfo_from_iteminfo(ItemInfo),
	  				Enchant =get_enchant_from_iteminfo(ItemInfo),
	  				 Lefttime_s =get_overdueinfo_from_iteminfo(ItemInfo),
					 NowNum=get(nowsize),
					 MaxNum=get(maxsize),
					NewSlot=get_new_slot_store_item(GuildId),
					 Maxsize=get(guild_package_maxsize),
					 Nowsize=get(guild_package_storagesize),
					 State=0,
					if NewSlot=:=0->
						   false;
					   true->
									if NowNum>=MaxNum->false;
									true->
													ItemId=itemid_generator:gen_newid(),
													Guilditems=guild_handle:make_guilditem_info(ItemId,Protoid,Enchantments,
																								Count,State,Isbonded,Socketsinfo,Duration,Coordown,Enchant,Lefttime_s,NewSlot,GuildId),
													instore_guild_items(Guilditems),
													put(nowsize,get(nowsize)+1),
															guild_manager_op:send_to_role_delete_item(ItemInfo, Count, RoleId),
															role_contribute_to_guild_package(RoleId,GuildId,Protoid,1,Count),
															Guilditems
								end
					end.

 remain_items_in_slot_of_instance(ProtoId,Count,GuildItemsInfo,GuildId)->
	   				Enchantments = 0,
	  				 Isbonded = 0,
	   				Socketsinfo =[],
	  				 Duration =0,
					Coordown= {{0,0,0},0},
	  				Enchant =[],
	  				 Lefttime_s =[],
					 NowNum=get(nowsize),
					 MaxNum=get(maxsize),
					NewSlot=get_new_slot_store_item(GuildId),
					 Maxsize=get(guild_package_maxsize),
					 Nowsize=get(guild_package_storagesize),
					 State=0,
					if NewSlot=:=0->
						   false;
					   true->
									if NowNum>=MaxNum->false;
									true->
													ItemId=itemid_generator:gen_newid(),
													Guilditems=guild_handle:make_guilditem_info(ItemId,ProtoId,Enchantments,
																								Count,State,Isbonded,Socketsinfo,Duration,Coordown,Enchant,Lefttime_s,NewSlot,GuildId),
													instore_guild_items(Guilditems),
													put(nowsize,get(nowsize)+1),
															Guilditems
								end
					end.

get_new_slot_store_item(GuildId)->
	case guild_proto_db:get_guilditem_by_guildid(GuildId) of
		[]->?GUILD_SLOT_NUM+1;
		GuildItemInfos->
			MaxSize=get(maxsize),
			SlotList=lists:seq(?GUILD_SLOT_NUM+1, ?GUILD_SLOT_NUM+MaxSize),
			ReminSlot=lists:foldl(fun(Slot,Acc)->
								case lists:keyfind(Slot, #guilditems.slot,GuildItemInfos) of
									false->
										[Slot]++Acc;
									_->
										Acc
								end end , [], SlotList),
			if SlotList=:=[]->
				   0;
			   true->
				   NewSlotList=lists:sort(ReminSlot),
				   [GSlot|_]=NewSlotList,
				   GSlot
			end
	end.
	
%%帮会仓库取出物品通过邮件发送
guild_storage_take_out_c2s(Slot,ItemId,Count,GuildId,RoleId)->
case guild_proto_db:get_guilditem_by_guildid(GuildId) of
	[]->
		 ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_ITEM_NOT_ENOUGH),
		 role_pos_util:send_to_role_clinet(RoleId,ErrnoMsg);
	GuildItems->
			case lists:keyfind(ItemId, #guilditems.id,GuildItems) of
				false->
					 ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_ITEM_NOT_ENOUGH),
					 role_pos_util:send_to_role_clinet(RoleId,ErrnoMsg);
				GuildItemInfo->
					NowCount=guild_proto_db:get_item_count_from_guilditem(GuildItemInfo),
					ItemProto=guild_proto_db:get_item_proto_id_from_guilditem(GuildItemInfo),
					if NowCount<Count->
						   ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_ITEM_NOT_ENOUGH),
							role_pos_util:send_to_role_clinet(RoleId,ErrnoMsg);
					   true->
							PlayItem=guild_handle:make_playeritems_to_role(GuildItemInfo,RoleId,Count),
							{From,Title,Body} = auction_manager_op:make_recede_mail_body(),
							Message={takeout_item_to_role,PlayItem},
							case role_pos_util:send_to_role(RoleId,{guild_message,Message}) of
										{guild_message,_}->
											update_guilditems_info_by_count(GuildItemInfo,Count),
											Message1=guild_packet:encode_guild_opt_result_s2c(?GUILD_PACKAGE_UPDATE),
											role_contribute_to_guild_package(RoleId,GuildId,ItemProto,0,Count),
											guild_manager_op:broad_cast_to_guild_client(GuildId, Message1),
											guild_manager_op:broad_cast_to_guild_role(GuildId, {guild_message,{reset_guild_package_falg,0}}),
											true;
										Other->
											slogger:msg("mail send error ~p ~n",[Other]),
											error
									end
					end
			end
	end.
			
			
	
get_remain_slot()->
	Nowsize=get(guild_package_storagesize),
	Maxsize=get(guild_package_maxsize),
	Maxsize-Nowsize.

update_guilditems_info_by_count(GuildInfo,Count)->
	Oldcount=guild_proto_db:get_item_count_from_guilditem(GuildInfo),
	NowCount=Oldcount-Count,
	ItemId=guild_proto_db:get_item_id_from_guilditem(GuildInfo),
	 Slot=guild_proto_db:get_item_slot_from_guilditem(GuildInfo),
	Protoid=guild_proto_db:get_item_proto_id_from_guilditem(GuildInfo),
	GuildId=guild_proto_db:get_guild_guildid_from_guilditem(GuildInfo),
	GuildBaseInfo=guild_spawn_db:get_guildinfo(GuildId),
	if NowCount>=1->
		    NewGuildInfo=guild_proto_db:set_item_count_to_guilditem(GuildInfo,NowCount),
			instore_guild_items(NewGuildInfo);
	true->
		{NowSize,MaxSize}=guild_proto_db:get_guild_package(GuildBaseInfo),
		delete_guild_items(ItemId),
		guild_spawn_db:set_guild_package(GuildId, {NowSize-1,MaxSize})
	end.

send_to_guildmember_update_guilditen(MessageInfo,GuildId)->
	Msg_Add_Proc = {guildmanager_msg,{guild_message_takeout_item_update}},
	guild_manager_op:broad_cast_to_guild_proc(GuildId,Msg_Add_Proc).

get_item_slot_and_itemid_and_count(ItemsInfo,ItemId,StackCount)->
	lists:foldl(fun(ItemInfo,Acc)->
							GuildItemId=erlang:element(#guilditems.entry, ItemInfo),
							GuildItemCount=erlang:element(#guilditems.count, ItemInfo),
							if (GuildItemId=:=ItemId) and (StackCount>GuildItemCount)->
										ItemInfo;
							true->
									Acc
							end end ,[], ItemsInfo).

role_contribute_to_guild_package(RoleId,GuildId,ItemId,Operate,Count)->
	RoleName= guild_member_op:get_member_name(RoleId),
	Now = timer_center:get_correct_now(),
	{{Year,Month,Day},{Hour,Min,Sec}} = calendar:now_to_local_time(Now),
	DateTime={Month,Day,Hour,Min},
	LoInfo={RoleName,Operate,ItemId,DateTime,Count},
	guild_manager_op:add_guild_package_log(RoleId,GuildId,?GUILD_LOG_PACKAGE,LoInfo).

send_to_guild_log(RoleId)->
	case guild_spawn_db:get_guildinfo_of_member(RoleId ) of
					  []->
						 ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_NOT_IN_GUILD),
						 role_pos_util:send_to_role_clinet(RoleId,ErrnoMsg);
				   MemberDbInfo->
					 	GuildId = guild_spawn_db:get_guildid_by_memberinfo(MemberDbInfo),
						guild_manager_op:send_to_client_package_log(RoleId,GuildId)
end.

%%帮会成员申请仓库物品
guild_package_item_apply(RoleId,GuildId,Count,ItemId,Slot)->
	case guild_proto_db:get_guilditem_by_guildid(GuildId) of
		[]->
			 ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_ITEM_NOT_ENOUGH),
			 role_op:send_data_to_gate(ErrnoMsg);
		GuildItems->
			case lists:keyfind(ItemId, #guilditems.id,GuildItems) of
				false->
					ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_ITEM_NOT_ENOUGH),
					 role_op:send_data_to_gate(ErrnoMsg);
				ItemInfo->
					NowCount=guild_proto_db:get_item_count_from_guilditem(ItemInfo),
					State=guild_proto_db:get_item_state_from_guildinfo(ItemInfo),
					Slot=guild_proto_db:get_item_slot_from_guilditem(ItemInfo),
					if State=:=?GUILID_PACLAGE_IDELITEM->
							if Count=<NowCount->
								   Now=timer_center:get_correct_now(),
								   DateTime=calendar:now_to_local_time(Now),
								   GuildItemObject=guild_packet:make_guild_package_apply(GuildId, RoleId, ItemId, Count, DateTime),
								   add_applyinfo(GuildItemObject,GuildId);
							   true->
								   nothing
							end;
					   true->
						   guild_storage_take_out_c2s(Slot,ItemId,Count,GuildId,RoleId)
					end
			end
	end.

%%帮会物品申请记录初始化
guild_storage_apply_init(GuildId,RoleId)->
	case guild_proto_db:get_guid_package_apply_info(GuildId) of
		[]->
				Message=guild_packet:encode_guild_storage_init_apply_s2c([]),
				role_pos_util:send_to_role_clinet(RoleId,Message);
		ApplyIterms->
			case guild_proto_db:get_guilditem_by_guildid(GuildId) of
				[]->
					nothing;
				GuildItems->
					SendInfo=send_to_leader_apply_of_guild(ApplyIterms,GuildItems),
					if SendInfo=:=[]->
						   nothing;
					   true->
							Message=guild_packet:encode_guild_storage_init_apply_s2c(SendInfo),
							role_pos_util:send_to_role_clinet(RoleId,Message)
					end
			end
	end.

add_applyinfo(GuildItemObject,GuildId)->
	case guild_proto_db:get_guid_package_apply_info(GuildId) of
		[]->
			guild_proto_db:insert_object_to_package_apply(GuildItemObject, GuildId);
		ApplyInfos->
			Len=erlang:length(ApplyInfos),
			if Len>=100->
				  NewList= lists:keysort(5, ApplyInfos),
				  {_,[OldApplyInfo]}= lists:split(99, NewList),
					guild_proto_db:delete_object_from_package_apply(GuildId, OldApplyInfo),
					guild_proto_db:insert_object_to_package_apply(GuildItemObject, GuildId);
			true->
				guild_proto_db:insert_object_to_package_apply(GuildItemObject, GuildId)
			end
		end.

guild_storage_approve_apply(TRoleId,ItemId,GuildId,FRoleid)->
	case guild_proto_db:get_guid_package_apply_info(GuildId) of
		[]->
			ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_UNKNOWN),
			 role_op:send_data_to_gate(ErrnoMsg);
		ApplyItems->
			case lists:keyfind(ItemId,#guildpackage_apply.itemid,ApplyItems ) of
				false->
					ErrnoMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_ITEM_NOT_ENOUGH),
					 role_op:send_data_to_gate(ErrnoMsg);
				Info->
					case guild_proto_db:get_guilditem_by_guildid(GuildId) of
						[]->
							nothing;
						ItemInfos->
							case lists:keyfind(ItemId, #guilditems.id, ItemInfos) of
								false->
									nothing;
								ItemInfo->
									Slot=guild_proto_db:get_item_slot_from_guilditem(ItemInfo),
									Count=guild_proto_db:get_apply_item_count(Info),
									case guild_storage_take_out_c2s(Slot,ItemId,Count,GuildId,TRoleId) of
										true->
												guild_proto_db:delete_object_from_package_apply(GuildId, Info),
												broad_send_to_guild_client_guild_package_apply_update(GuildId);
									error->
												Message=guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_CANNOT_FIND_ROLE),
												role_pos_util:send_to_role_clinet(FRoleid,Message);
									Other->
											nothing
									end
							end
					end
			end
	end.

%%广播申请记录更新
broad_send_to_guild_client_guild_package_apply_update(GuildId)->
	case guild_proto_db:get_guid_package_apply_info(GuildId) of
		[]->
				Message=guild_packet:encode_guild_storage_init_apply_s2c([]),
				guild_manager_op:broad_cast_to_guild_client(GuildId, Message);
		ApplyIterms->
			case guild_proto_db:get_guilditem_by_guildid(GuildId) of
				[]->
					nothing;
				GuildItems->
					SendInfo=send_to_leader_apply_of_guild(ApplyIterms,GuildItems),
					if SendInfo=:=[]->
						   nothing;
					   true->
							Message=guild_packet:encode_guild_storage_init_apply_s2c(SendInfo),
							guild_manager_op:broad_cast_to_guild_client(GuildId, Message)
					end
			end
	end.
%%帮会申请拒绝
guild_storage_refuse_apply(TRoleId,ItemId,GuildId)->
	case guild_proto_db:get_guid_package_apply_info(GuildId) of
		[]->
						nothing;
		ApplyInfos->
				case lists:keyfind(ItemId,#guildpackage_apply.itemid,ApplyInfos ) of
				false->nothing;
					%io:format("@@@@@@@@@@@@@@  no item info  ItemId  ~p ~n",[ItemId ]);
				Info->
					guild_proto_db:delete_object_from_package_apply(GuildId, Info),
					broad_send_to_guild_client_guild_package_apply_update(GuildId)
				end
	end.
%%拒绝所有申请
guild_storage_refuse_all_apply(GuildId)->
	case guild_proto_db:get_guid_package_apply_info(GuildId) of
		[]->
			nothing;
		ApplyInfos->
					guild_proto_db:delete_all_object_from_package_apply(GuildId),
					broad_send_to_guild_client_guild_package_apply_update(GuildId)
	end.

%%帮会分配物品重复帮会仓库取出物品代码,因为客户端所需一个状态值不同，为了避免消息多发，重复上边代码
guild_storage_distribute_item(ItemId,Count,ToRoleid,Slot,GuildId,FRole)	->
	guild_storage_take_out_c2s(Slot,ItemId,Count,GuildId,ToRoleid).

guild_storage_self_apply(GuildId,RoleId)->
		case guild_proto_db:get_guid_package_apply_info(GuildId) of
		[]->
				Message=guild_packet:encode_guild_storage_init_apply_s2c([]),
				role_pos_util:send_to_role_clinet(RoleId,Message);
		ApplyIterms->
			case guild_proto_db:get_guilditem_by_guildid(GuildId) of
				[]->
					nothing;
				GuildItems->
					RoleApplyInfos=get_self_item_apply(ApplyIterms,RoleId),
					SendInfo=send_to_client_myapply(RoleApplyInfos,GuildItems),
					if SendInfo=:=[]->
						   nothing;
					   true->
							Message=guild_packet:encode_guild_storage_self_apply_s2c(SendInfo),
							role_pos_util:send_to_role_clinet(RoleId,Message)
					end
			end
	end.

get_self_item_apply(ApplyIterms,RoleId)->
	lists:foldl(fun(ApplyInfo,Acc)->
					  if erlang:element(#guildpackage_apply.roleid, ApplyInfo)=:=RoleId->
							 [ApplyInfo]++Acc;
					  true->
							Acc
						end end,[], ApplyIterms).


guild_storage_cancel_apply(GuildId,RoleId,ItemId)->
	case guild_proto_db:get_guid_package_apply_info(GuildId) of
		[]->
				Message=guild_packet:encode_guild_storage_init_apply_s2c([]),
				role_pos_util:send_to_role_clinet(RoleId,Message);
		ApplyIterms->
			RoleApplys=get_self_item_apply(ApplyIterms,RoleId),
			case lists:keyfind(ItemId, #guildpackage_apply.itemid, RoleApplys) of
				false->
						nothing;
				ApplyInfo->
				case guild_proto_db:get_guilditem_by_guildid(GuildId) of
				[]->
						nothing;
				GuildItems->
						guild_proto_db:delete_object_from_package_apply(GuildId, ApplyInfo),
						NewRoleApplys=lists:keydelete(ItemId,#guildpackage_apply.itemid ,RoleApplys),
						SendInfo=send_to_client_myapply(NewRoleApplys,GuildItems),
					if SendInfo=:=[]->
						   Message=guild_packet:encode_guild_storage_self_apply_s2c([]),
							role_pos_util:send_to_role_clinet(RoleId,Message);
					   true->
							Message=guild_packet:encode_guild_storage_self_apply_s2c(SendInfo),
							role_pos_util:send_to_role_clinet(RoleId,Message)
					end
				end		
			end
	end.

%%获取发送自己申请物品记录到客户端
send_to_client_myapply(RoleApplys,GuildItems)->
		SendInfo=lists:foldl(fun(Info,Acc)->
										ApplyRoleId=guild_proto_db:get_apply_role_id(Info),
										Count=guild_proto_db:get_apply_item_count(Info),
										ItemId=guild_proto_db:get_apply_item_id(Info),
										Rolename=guild_member_op:get_member_name(ApplyRoleId),
										case lists:keyfind(ItemId,#guilditems.id, GuildItems) of
											false->
												Acc;
											ItemInfo->
											ItemAttr=guild_packet:make_i(ItemInfo,Count),
												Spl=guild_packet:make_spl(ItemAttr, Count),
												[Spl]++Acc
										end end, [], RoleApplys),
		SendInfo.

send_to_leader_apply_of_guild(RoleApplys,GuildItems)->
	SendInfo=lists:foldl(fun(Info,Acc)->
										ApplyRoleId=guild_proto_db:get_apply_role_id(Info),
										Count=guild_proto_db:get_apply_item_count(Info),
										ItemId=guild_proto_db:get_apply_item_id(Info),
										Rolename=guild_member_op:get_member_name(ApplyRoleId),
										case lists:keyfind(ItemId,#guilditems.id, GuildItems) of
											false->
												Acc;
											ItemInfo->
											ItemAttr=guild_packet:make_i(ItemInfo,Count),
												Ar=guild_packet:make_ar(Rolename,ApplyRoleId,Count),
											Al=guild_packet:make_al([ItemAttr],[Ar]),
												[Al]++Acc
										end end, [], RoleApplys),
	SendInfo.

%%帮会仓库权限设置
guild_storage_set_state(Type,State,GuildId,RoleId)->
	case guild_spawn_db:get_guildinfo(GuildId) of
		[]->
			nothing;
		GuildInfo->
			{PackageSize,PackageLimit}=guild_proto_db:get_guild_package_info_from_guildbaseinfo(GuildInfo),
			NewPackageLimit=lists:keyreplace(Type, 1, PackageLimit, {Type,State}),
			NewGuildInfo=erlang:setelement(#guild_baseinfo.package, GuildInfo, {PackageSize,NewPackageLimit}),
			guild_spawn_db:set_guild_info(NewGuildInfo),
			MessageList=lists:map(fun({Type1,State1})->
										  guild_packet:make_oprate_state(Type1,State1) end,NewPackageLimit),
			Message=guild_packet:encode_guild_storage_update_state_s2c(MessageList),
			guild_op:broad_cast_to_guild_client(Message)
	end.

%%发送给客户端帮会仓库限制消息(因为每次登陆消息发送一次，所以在init中初始化)
send_to_client_guild_package_limit_init(GuildId)->
	case guild_spawn_db:get_guildinfo(GuildId) of
		[]->
			nothing;
		GuildInfo->
			GuildLimit=guild_proto_db:get_guild_package_limit(GuildInfo),
			MessageList=lists:map(fun({Type,State})->
										  guild_packet:make_oprate_state(Type,State) end,GuildLimit),
			Message=guild_packet:encode_guild_storage_update_state_s2c(MessageList),
			role_op:send_data_to_gate(Message)
		end.
	
			
			
			
			
			
	
					
	




