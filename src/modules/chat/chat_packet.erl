%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(chat_packet).

-compile(export_all).

-include("login_pb.hrl").
-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("attr_keyvalue_define.hrl").
-include("role_struct.hrl").


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 包处理函数结合
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 消息: 要定义，处理消息,如果是chat消息，rolepid没有用，获得新的pid
handle(#chat_c2s{type = Type, desserverid = ServerId,desrolename = Desrolename, msginfo = Msg,details=Details,reptype=RepType}, RolePid) ->
	role_processor:chat_message(RolePid, {Type, Desrolename, Msg,Details,ServerId,RepType});

handle(#loudspeaker_queue_num_c2s{},RolePid) ->
	role_processor:chat_loudspeaker_queue_num_c2s(RolePid);

handle(Message=#chat_private_c2s{},RolePid)->
	RolePid ! {chat_private,Message}.

encode_chat_s2c(Type,PrivateFlag,RoleId,RoleName,Msg,Details,RoleIden)->
	encode_chat_s2c(Type,PrivateFlag,RoleId,RoleName,Msg,Details,RoleIden,0,0).%%@@wb20130428
	
encode_chat_s2c(Type,PrivateFlag,RoleId,RoleName,Msg,Details,RoleIden,Serverid,RepType) ->
	try
	login_pb:encode_chat_s2c(#chat_s2c{type = Type, privateflag =PrivateFlag,serverid = Serverid, desroleid=RoleId, desrolename = RoleName, msginfo=Msg,details=Details,identity = RoleIden,reptype=RepType})
	catch
		_E:_R->
			Trace=erlang:get_stacktrace(),
			slogger:msg("---------~p=====~p---------~n~p~n",[_E,_R,Trace]),
			<<141:16, <<>>/binary>>
	end.
	
encode_chat_failed_s2c(Reasonid) ->
	encode_chat_failed_s2c(Reasonid,0).

encode_chat_failed_s2c(Reasonid,CdTime) ->
	login_pb:encode_chat_failed_s2c(#chat_failed_s2c{reasonid = Reasonid,cdtime = CdTime}).

encode_loudspeaker_opt_s2c(Reasonid) ->
	login_pb:encode_loudspeaker_opt_s2c(#loudspeaker_opt_s2c{reasonid = Reasonid}).	
	
encode_loudspeaker_queue_num_s2c(Num)->
	login_pb:encode_loudspeaker_queue_num_s2c(#loudspeaker_queue_num_s2c{num = Num}).
	
encode_system_broadcast_s2c(Id,	Param)->
	login_pb:encode_system_broadcast_s2c(#system_broadcast_s2c{id = Id,param = Param}).

encode_chat_private_s2c(RoleId,Level,RoleClass,RoleGender,Signature,GuildName,GuildlId,GuildhId,VipTag,RoleName,ServerId)->
	login_pb:encode_chat_private_s2c(#chat_private_s2c{roleid =RoleId,
													   level = Level,
													   roleclass=RoleClass,
													   rolegender=RoleGender,
													   signature=Signature,
													   guildname=GuildName,
													   guildlid=GuildlId,
													   guildhid=GuildhId,
													   viptag=VipTag,
													   rolename=RoleName,
													   serverid = ServerId}).
	
makeparam(string,{String})->
	StringKV = pb_util:key_value(?ATTR_STRING, String),
	#rkv{kv = [StringKV],kv_plus=[],color=0};
		
makeparam(string,{String,Color})->
	StringKV = pb_util:key_value(?ATTR_STRING, String),
	#rkv{kv = [StringKV],kv_plus=[],color=Color};	
	
makeparam(role,{Name,RoleId,ServerId})->
	NameKV = pb_util:key_value(?ROLE_ATTR_NAME, Name),
	RoleIdKV = pb_util:key_value(?ROLE_ATTR_ID, RoleId),
	ServerKV = pb_util:key_value(?ROLE_ATTR_SERVERID, ServerId),
	#rkv{kv = [NameKV,RoleIdKV,ServerKV],kv_plus=[],color=0};
	
makeparam(role,{Name,RoleId,ServerId,Color})->
	NameKV = pb_util:key_value(?ROLE_ATTR_NAME, Name),
	RoleIdKV = pb_util:key_value(?ROLE_ATTR_ID, RoleId),
	ServerKV = pb_util:key_value(?ROLE_ATTR_SERVERID, ServerId),
	#rkv{kv = [NameKV,RoleIdKV,ServerKV],kv_plus=[],color=Color};

makeparam(equipment,Slot)->
	case equipment_op:get_item_from_proc(Slot) of
		[]->
			[];
		EquipInfo->
			TempidKV = pb_util:key_value(?ITEM_ATTR_TEMPLATE_ID,get_template_id_from_iteminfo(EquipInfo)),
			EnchKV = pb_util:key_value(?ITEM_ATTR_ENCH,get_enchantments_from_iteminfo(EquipInfo)),
			BondedKV = pb_util:key_value(?ITEM_ATTR_ISBONDED,get_isbonded_from_iteminfo(EquipInfo)),
			DurationKV = pb_util:key_value(?ITEM_ATTR_DURATION,get_duration_from_iteminfo(EquipInfo)),
			SocketsKv = pb_util:key_value(?ITEM_ATTR_SOCKETS,equipment_op:get_client_socketsinfo(get_socketsinfo_from_iteminfo(EquipInfo))),
			Enchant = role_attr:to_item_attribute({enchant,get_enchant_from_iteminfo(EquipInfo)}),
			SlotKV = pb_util:key_value(?ITEM_ATTR_SLOT,Slot),
			LeftTimeKv = pb_util:key_value(?ITEM_ATTR_LEFTTIME,items_op:get_left_time_by_overdueinfo(get_overdueinfo_from_iteminfo(EquipInfo))),
			#rkv{kv = [TempidKV,EnchKV,BondedKV,DurationKV,SocketsKv,SlotKV,LeftTimeKv],kv_plus=Enchant,color=0}
	end;
	
makeparam(item,ItemTemplateId)->	
	TempidKV = pb_util:key_value(?ITEM_ATTR_TEMPLATE_ID, ItemTemplateId),
	#rkv{kv = [TempidKV],kv_plus=[],color=0};
	
makeparam(int,Int)->
	TempidKV = pb_util:key_value(?ATTR_INT,Int),
	#rkv{kv = [TempidKV],kv_plus=[],color=0};
	
makeparam(pet,{PetId,PetName,PetQuality,RoleId,RoleName,ServerId})->
	PetNameKV = pb_util:key_value(?ROLE_ATTR_PET_NAME, PetName),  
	PetIdKV = pb_util:key_value(?ROLE_ATTR_PET_ID, PetId),
	RoleIdKV = pb_util:key_value(?ROLE_ATTR_ID, RoleId),
	RoleNameKV = pb_util:key_value(?ROLE_ATTR_NAME, RoleName),
	ServerKV = pb_util:key_value(?ROLE_ATTR_SERVERID, ServerId),
	Color = pet_util:get_pet_quality_color(PetQuality),
	#rkv{kv = [PetNameKV,PetIdKV,RoleIdKV,RoleNameKV,ServerKV],kv_plus=[],color=Color};
  
makeparam(_,Reasonid)->
	login_pb:encode_chat_failed_s2c(#chat_failed_s2c{reasonid = Reasonid}).

makeparam_by_equipid(Id)->
	case items_op:get_item_info(Id) of
		[]->
			[];
		EquipInfo->
			TempidKV = pb_util:key_value(?ITEM_ATTR_TEMPLATE_ID,get_template_id_from_iteminfo(EquipInfo)),
			EnchKV = pb_util:key_value(?ITEM_ATTR_ENCH,get_enchantments_from_iteminfo(EquipInfo)),
			BondedKV = pb_util:key_value(?ITEM_ATTR_ISBONDED,get_isbonded_from_iteminfo(EquipInfo)),
			DurationKV = pb_util:key_value(?ITEM_ATTR_DURATION,get_duration_from_iteminfo(EquipInfo)),
			SocketsKv = pb_util:key_value(?ITEM_ATTR_SOCKETS,equipment_op:get_client_socketsinfo(get_socketsinfo_from_iteminfo(EquipInfo))),
			Enchant = role_attr:to_item_attribute({enchant,get_enchant_from_iteminfo(EquipInfo)}),
			SlotKV = pb_util:key_value(?ITEM_ATTR_SLOT,get_slot_from_iteminfo(EquipInfo)),
			LeftTimeKv = pb_util:key_value(?ITEM_ATTR_LEFTTIME,items_op:get_left_time_by_overdueinfo(get_overdueinfo_from_iteminfo(EquipInfo))),
			#rkv{kv = [TempidKV,EnchKV,BondedKV,DurationKV,SocketsKv,SlotKV,LeftTimeKv],kv_plus=Enchant,color=0}
	end.

	
	
	
	
	
	
	
	