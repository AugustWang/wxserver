-record(item_info,{	
				id,								%%武器id
				ownerid,						%%所属者id								
				template_id,					%%模板信息id
				enchantments,					%%生星级别
				count,							%%数量/使用次数
				slot,							%%所在背包槽位0为未在任何
				isbonded,						%%是否已绑定
				socketsinfo,					%%孔信息[{0,itemid}...]
				duration,						%%耐久
				cooldowninfo,					%%冷却信息
				enchant,						%%附魔
				overdueinfo,					%%过期参数{激活时间,剩余秒数}
				%%模板信息
				name,							%%物品名
				class,							%%类型
				displayed,						%%显示相关
				equipmentset,					%%套装id
				level,							%%物品等级
				qualty,							%%品质
				requiredlevel,					%%{minlevel,maxlevel}
				stackable,						%%可堆叠数量
				max_duration,					%%最大耐久
				inventory_type,					%%佩戴位置
				socket_type,					%%宝石可镶嵌class
				allowableclass,					%%允许职业[]
				useable,						%%可用次数
				sellprice,						%%0为不可卖
				damage,							%%{魔，远，近}
				defense,						%%{魔，远，近}
				states,							%%附加属性[{type,value}]
				spellid,						%%触发技能id，0为无
				spellcategory,					%%效果组类型
				spellcooldown,					%%cd
				bonding,						%%绑定类型
				maxsocket,						%%最大可开孔数
				scripts,						%%触发脚本
				questid,						%%触发任务
				baserepaired,					%%修理系数
				overdue_type					%%过期类型
				}).	
								
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	装备定义
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				

create_item_baseinfo(Id,Owner,TemplateID,Enchantments,Count,Slot,Isbonded,SocketsInfo,Duration,CoolDownInfo,Enchant,OverDueInfo)->
	#item_info{	id = Id,
				ownerid = Owner,				
				template_id = TemplateID,		
				enchantments = Enchantments,			
				count = Count,					
				slot = Slot,					
				isbonded = Isbonded,
				socketsinfo = SocketsInfo,
				duration = Duration,
				cooldowninfo = CoolDownInfo,
				enchant = Enchant,
				overdueinfo = OverDueInfo
				}.
				
set_protoinfo_to_iteminfo(Iteminfo,{_,Entry,Name,Class,Displayed,Equipmentset,Level,Qualty,Requiredlevel,			%%FK 26!!!!
							Stackable,Max_duration,Inventory_type,Socket_type,Allowableclass,
							Useable,Sellprice,Damage,Defense,States,Spellid,Spellcategory,Spellcooldown,
							Bonding,Maxsocket,Scripts,Questid,Baserepaired,Overdue_type,_Overdueargs,_Overduetransform,_EnchantExt})->
				Iteminfo#item_info{
				template_id = Entry,
				name	= Name,
				class	= Class,
				displayed = Displayed,
				equipmentset = Equipmentset,
				level = Level,
				qualty = Qualty,
				requiredlevel = Requiredlevel,
				stackable  = Stackable,
				max_duration = Max_duration,
				inventory_type = Inventory_type,
				socket_type = Socket_type,
				allowableclass = Allowableclass,
				useable = Useable,
				sellprice = Sellprice,
				damage = Damage,
				defense= Defense,
				states = States,
				spellid= Spellid,
				spellcategory= Spellcategory,
				spellcooldown= Spellcooldown,
				bonding= Bonding,
				maxsocket= Maxsocket,
				scripts= Scripts,
				questid= Questid,
				baserepaired= Baserepaired,
				overdue_type = Overdue_type
				}.

get_id_from_iteminfo(Iteminfo)->
	#item_info{id=TemId} = Iteminfo,
	TemId.
	
get_lowid_from_iteminfo(Iteminfo)->
	#item_info{id=TemId} = Iteminfo,
	get_lowid_from_itemid(TemId).
get_highid_from_iteminfo(Iteminfo)->
	#item_info{id=TemId} = Iteminfo,
	get_highid_from_itemid(TemId).

get_lowid_from_itemid(ItemId)->			
	{_,Low} = ItemId,
	Low.
get_highid_from_itemid(ItemId)->
	{High,_} = ItemId,
	High.

get_itemid_by_low_high_id(High,Low)->
	{High,Low}.

set_template_id_to_iteminfo(Iteminfo,TemId)->
	Iteminfo#item_info{template_id=TemId}.
get_template_id_from_iteminfo(Iteminfo)->
	#item_info{template_id=TemId} = Iteminfo,
	TemId.

	
get_cooldowninfo_from_iteminfo(Iteminfo)->
	#item_info{cooldowninfo=Cooldowninfo} = Iteminfo,
	Cooldowninfo.	
set_cooldowninfo_to_iteminfo(Iteminfo,Cooldowninfo)->
	Iteminfo#item_info{cooldowninfo = Cooldowninfo}.	

get_overdueinfo_from_iteminfo(Iteminfo)->
	#item_info{overdueinfo=Overdueinfo} = Iteminfo,
	Overdueinfo.	
set_overdueinfo_to_iteminfo(Iteminfo,Overdueinfo)->
	Iteminfo#item_info{overdueinfo = Overdueinfo}.

set_ownerid_to_iteminfo(Iteminfo,Id)->
	Iteminfo#item_info{ownerid = Id}.
get_ownerid_from_iteminfo(Iteminfo)->
	#item_info{ownerid=ID} = Iteminfo,
	ID.
				
set_enchantments_to_iteminfo(Iteminfo,StarLevel)->
	Iteminfo#item_info{enchantments = StarLevel}.
get_enchantments_from_iteminfo(Iteminfo)->
	#item_info{enchantments=StarLevel} = Iteminfo,
	StarLevel.

set_enchant_to_iteminfo(Iteminfo,Enchant)->
	Iteminfo#item_info{enchant = Enchant}.
get_enchant_from_iteminfo(Iteminfo)->
	#item_info{enchant=Enchant} = Iteminfo,
	Enchant.

set_count_to_iteminfo(Iteminfo,Count)->
	Iteminfo#item_info{count = Count}.
get_count_from_iteminfo(Iteminfo)->
	#item_info{count=Count} = Iteminfo,
	Count.						
	
set_slot_to_iteminfo(Iteminfo,Slot)->
	Iteminfo#item_info{slot = Slot}.
get_slot_from_iteminfo(Iteminfo)->
	#item_info{slot=Slot} = Iteminfo,
	Slot.	
	
set_isbonded_to_iteminfo(Iteminfo,Isbonded)->
	Iteminfo#item_info{isbonded = Isbonded}.
get_isbonded_from_iteminfo(Iteminfo)->
	#item_info{isbonded=Isbonded} = Iteminfo,
	Isbonded.								
				
				
set_socketsinfo_to_iteminfo(Iteminfo,Socketsinfo)->
	Iteminfo#item_info{socketsinfo = Socketsinfo}.
get_socketsinfo_from_iteminfo(Iteminfo)->
	#item_info{socketsinfo=Socketsinfo} = Iteminfo,
	Socketsinfo.
	
%%孔操作
add_socket_to_iteminfo(Iteminfo)->
	Sockets = get_socketsinfo_from_iteminfo(Iteminfo),
	set_socketsinfo_to_iteminfo(Iteminfo,lists:append(Sockets,[{erlang:length(Sockets)+1,0}])).
set_stone_to_iteminfo(Iteminfo,StoneTemid,SlotNum)->
	Sockets = get_socketsinfo_from_iteminfo(Iteminfo),
	set_socketsinfo_to_iteminfo(Iteminfo,lists:keyreplace(SlotNum,1,Sockets,{SlotNum,StoneTemid})).
get_stone_from_iteminfo(Iteminfo,SlotNum)->
	{SlotNum,Stoneid} = lists:keyfind(SlotNum,1,get_socketsinfo_from_iteminfo(Iteminfo)),
	Stoneid.			
	
set_duration_to_iteminfo(Iteminfo,Duration)->
	Iteminfo#item_info{duration = Duration}.
get_duration_from_iteminfo(Iteminfo)->
	#item_info{duration=Duration} = Iteminfo,
	Duration.					

%%生星会改变实例攻击和防御属性	 
get_damage_from_iteminfo(Iteminfo )->
	#item_info{ damage = Damage} = Iteminfo,
	Damage.	
set_damage_from_iteminfo(Iteminfo,Damage)->
	Iteminfo#item_info{damage = Damage}.
	
get_defense_from_iteminfo(Iteminfo )->
	#item_info{defense = Defense} = Iteminfo,
	Defense.
set_defense_from_iteminfo(Iteminfo,Defense)->
	Iteminfo#item_info{defense = Defense}.	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%								以下均为不可变的模板信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_name_from_iteminfo(Iteminfo )->
	#item_info{ name = Name } = Iteminfo,
	Name.		
	 
get_class_from_iteminfo(Iteminfo )->
	#item_info{ class = Class} = Iteminfo,
	Class.	
	 
get_displayed_from_iteminfo(Iteminfo )->
	#item_info{ displayed = Displayed} = Iteminfo,
	Displayed.

get_equipmentset_from_iteminfo(Iteminfo )->
	#item_info{ equipmentset = Equipmentset} = Iteminfo,
	Equipmentset.	

get_level_from_iteminfo(Iteminfo )->
	#item_info{ level = Level } = Iteminfo,
	Level.	
	 
get_qualty_from_iteminfo(Iteminfo )->
	#item_info{ qualty = Qualty} = Iteminfo,
	Qualty.	
	 
get_requiredlevel_from_iteminfo(Iteminfo )->
	#item_info{ requiredlevel = Requiredlevel} = Iteminfo,
	Requiredlevel.	

get_stackable_from_iteminfo(Iteminfo )->
	#item_info{stackable = Stackable} = Iteminfo,
	Stackable.
	 
get_maxduration_from_iteminfo(Iteminfo )->
	#item_info{ max_duration = Max_duration} = Iteminfo,
	Max_duration.	

get_inventorytype_from_iteminfo(Iteminfo )->
	#item_info{inventory_type =Inventory_type } = Iteminfo,
	Inventory_type.	

get_socket_type_from_iteminfo(Iteminfo )->
	#item_info{socket_type = Socket_type } = Iteminfo,
	Socket_type.	
	 
get_allowableclass_from_iteminfo(Iteminfo )->
	#item_info{ allowableclass = Allowableclass} = Iteminfo,
	Allowableclass.	
	 
get_useable_from_iteminfo(Iteminfo )->
	#item_info{ useable = Useable} = Iteminfo,
	Useable.	

get_sellprice_from_iteminfo(Iteminfo )->
	#item_info{ sellprice = Sellprice} = Iteminfo,
	Sellprice.		
	 
get_states_from_iteminfo(Iteminfo )->
	#item_info{ states = States} = Iteminfo,
	States.	
	 
get_spellid_from_iteminfo(Iteminfo )->
	#item_info{ spellid = Spellid} = Iteminfo,
	Spellid.	

get_spellcategory_from_iteminfo(Iteminfo )->
	#item_info{ spellcategory = Spellcategory} = Iteminfo,
	Spellcategory.	
	 
get_spellcooldown_from_iteminfo(Iteminfo )->
	#item_info{ spellcooldown = Spellcooldown} = Iteminfo,
	Spellcooldown.			 
	 
get_bonding_from_iteminfo(Iteminfo )->
	#item_info{ bonding = Bonding} = Iteminfo,
	 Bonding.	

get_maxsocket_from_iteminfo(Iteminfo )->
	#item_info{ maxsocket = Maxsocket} = Iteminfo,
	Maxsocket.	
	 
get_scripts_from_iteminfo(Iteminfo )->
	#item_info{ scripts = Scripts} = Iteminfo,
	Scripts.	
	 
get_questid_from_iteminfo(Iteminfo )->
	#item_info{ questid = Questid} = Iteminfo,
	Questid.	
	 
get_baserepaired_from_iteminfo(Iteminfo )->
	#item_info{ baserepaired = Baserepaired} = Iteminfo,
	Baserepaired.								

get_overdue_type_from_iteminfo(Iteminfo )->
	#item_info{ overdue_type = Overdue_type} = Iteminfo,
	Overdue_type.	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%chat info
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
-record(chat_info,{chatnode,chatproc,last_time,talk_block}).

get_chatnode_from_chat_info(Chatinfo)->
	#chat_info{ chatnode = Chatnode} = Chatinfo,
	Chatnode.								
	
get_chatproc_from_chat_info(Chatinfo)->
	#chat_info{ chatproc = Chatproc} = Chatinfo,
	Chatproc.
	
set_chat_info(ChatNode,ChatProc,Time,Tag)->
	#chat_info{chatnode = ChatNode,chatproc = ChatProc,last_time = Time,talk_block = Tag}.								

get_last_time_from_chat_info(Chatinfo)->
	#chat_info{ last_time = Last_Time} = Chatinfo,
	Last_Time.	
	
set_chat_last_time(ChatInfo,Time)->
	ChatInfo#chat_info{last_time = Time}.	
	
get_talk_block(ChatInfo)->
	#chat_info{ talk_block = BlockTime} = ChatInfo,
	BlockTime.
	
set_talk_block(ChatInfo,Tag)->
	ChatInfo#chat_info{talk_block = Tag}.	
