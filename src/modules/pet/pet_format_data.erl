%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-9-2
%% Description: TODO: Add description to pet_format_data
-module(pet_format_data).

%%
%% Include files
%%
-include("pet_def.hrl").
-include("pet_define.hrl").
-include("string_define.hrl").
-include("mnesia_table_def.hrl").
-include("item_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

-define(ETS_TABLE,temp_pet_convert_ets).
-define(ETS_PET_LEVEL,temp_pet_level_ets).

%%
%% API Functions
%%
%%old data {Level,Name,Gender,Mana,Quality,Talents,Exp,Strength,Agile,Intelligence,Stamina,Growth,Stamina_growth
%%		,Class,State,Maxskillnum,Slot,Born_strength,Born_intelligence,Born_agile,Born_stamina}.
%%
%%new data {Level,Name,Gender,Mana,Exp,Quality_Value_Add,Quality_Up_Value_Add,Happiness,State,TradeLock,
%% AttrUserAddInfo,TalentAddInfo}.
%%
format_data()->
	ets:new(?ETS_TABLE, [named_table,set]),
	ets:new(?ETS_PET_LEVEL, [named_table,set]),
	import("../config/pet_convert.config",?ETS_TABLE),
	import("../config/pet_level.config",?ETS_PET_LEVEL),
	PetsTables = rpc:call(node_util:get_dbnode(),db_split,get_splitted_tables,[pets]),
	lists:foreach(fun(TableName)->
					{ok,OldPetInfo} = dal:read_rpc(TableName),	
					lists:foreach(fun(PetInfo)->									
								convert_data(PetInfo)											
							end,OldPetInfo) 
				end,PetsTables),
	ets:delete(?ETS_TABLE),
	ets:delete(?ETS_PET_LEVEL),
	format_quick_bar(),
	format_pet_slot().


%%
%% Local Functions
%%
import(File,EtsName)->
	case file:consult(File) of
		{ok, [Terms]}->
			lists:foreach(fun(X)->
							ets:insert(EtsName,X)
						  end,Terms);
		{error,Reason}->
			slogger:msg("import error:~p~n",[Reason])
	end.

convert_data(PetInfo)->
	PetId = pets_db:get_petid(PetInfo),
	MasterId = pets_db:get_masterid(PetInfo),
	Proto = pets_db:get_protoid(PetInfo),
	PetDbInfo = pets_db:get_petinfo(PetInfo),
	Level = erlang:element(1,PetDbInfo),
	Name = erlang:element(2,PetDbInfo),
	Gender = erlang:element(3,PetDbInfo),
	Quality = erlang:element(5,PetDbInfo),
	Exp = erlang:element(7,PetDbInfo),
	case ets:lookup(?ETS_TABLE,Proto) of
		[]->
			[];
		[{_,Type,TargetList}]->
			case Type of
				1->		%%pet
					{NewProto,SavePetinfo} = convert_pet(Level,Name,Gender,Quality,Exp,TargetList),
					SkillInfo = pet_skill_op:initskillinfo(),
					EquipInfo = pet_equip_op:init_pet_equipinfo(),
					pets_db:save_pet_info(MasterId,PetId,NewProto,SavePetinfo,SkillInfo,EquipInfo,[],[]);
				2->		%%ride
					pets_db:del_pet(PetId,MasterId),
					NewProto = convert_ride(Quality,TargetList),
					FromName = language:get_string(?STR_SYSTEM),
					Title = language:get_string(?STR_SEND_RIDE_TITLE),
					Context = language:get_string(?STR_SEND_RIDE_CONTEXT),
					Add_Silver = 0,
					RoleName = role_db:get_name(role_db:get_role_info(MasterId)),
					gm_op:gm_send_rpc(FromName,RoleName,Title,Context,NewProto,1,Add_Silver)
			end;	
		_->
			[]
	end.	

convert_pet(Level,Name,Gender,Quality,Exp,TargetList)->
	TargetProto = lists:nth(get_level_type(Level),TargetList),
	ProtoInfo = pet_proto_db:get_info(TargetProto),
	QualityInfo = pet_proto_db:get_quality_to_growth(ProtoInfo),
	{Quality_Value_Min,_} = pet_util:get_adapt_qualityinfo(Quality,QualityInfo),
	{Quality_Value_Min_Base,_} = pet_util:get_adapt_qualityinfo(?PET_MIN_QUALITY,QualityInfo),
	{OldExpMin,OldEXpMax} = get_old_exp(Level),
	ExpRate = Exp/(OldEXpMax - OldExpMin),
	NewExpMin = pet_level_db:get_exp(pet_level_db:get_info(Level)),
	NewExpMax = pet_level_db:get_exp(pet_level_db:get_info(Level+1)),
	NewExp = erlang:max(erlang:trunc((NewExpMax-NewExpMin)*ExpRate),0),
	ProtoName = pet_proto_db:get_name(ProtoInfo),
	if
		Quality =:= ?PET_MIN_QUALITY->
			QualityValue = 15 - Quality_Value_Min_Base, 
			QualityUpValue = 30 - Quality_Value_Min_Base;
		true->
			QualityValue = (Quality_Value_Min - Quality_Value_Min_Base), 
			QualityUpValue = (Quality_Value_Min - Quality_Value_Min_Base)
	end,
	DbInfo = {Level,Name,Gender,0,NewExp,QualityValue,QualityUpValue,
	 			?PET_MAX_HAPPINESS,?PET_STATE_IDLE,?PET_TRADE_UNLOCK,{0,0,0,0},{0,0,0,0},false},
	{TargetProto,DbInfo}.

convert_ride(Quality,TargetList)->
	TargetProto = lists:nth(Quality,TargetList),
	TargetProto.

format_quick_bar()->
	%%format quickbar
	%%clsid是9位的，转换成1（是技能）
	%%clsid是8位的，转换成2（是物品）
	%%clsid是13~15，转换成3（是宠物）
	%%clsid是16的，转换成4（是坐骑）
	%%
	QuickBarTables = rpc:call(node_util:get_dbnode(),db_split,get_splitted_tables,[role_quick_bar]),
	lists:foreach(fun(TableName)->
					{ok,OldQuickBar} = dal:read_rpc(TableName),	
					lists:foreach(fun(QuickBarInfo)->
								QuickBarList = erlang:element(#role_quick_bar.quickbarinfo, QuickBarInfo),							
								NewQuickBarList = lists:map(fun({Slot,Class,EntryId})->
															if
																Class >= 100000000->
																	{Slot,1,EntryId};
																Class >= 10000000->
																	{Slot,2,EntryId};
																(Class>=13) and (Class =<15)->
																	{Slot,3,EntryId};
																Class =:= 16->
																	{Slot,4,EntryId};
																true->
																	{Slot,Class,EntryId}
															end
														end,QuickBarList),
								NewQuickBarInfo =  erlang:setelement(#role_quick_bar.quickbarinfo,QuickBarInfo,NewQuickBarList),
								dal:write_rpc(NewQuickBarInfo)
							end,OldQuickBar) 
				end,QuickBarTables).

format_pet_slot()->
	%%format role pet slot
	RoleAttrTables = rpc:call(node_util:get_dbnode(),db_split,get_splitted_tables,[roleattr]),
	lists:foreach(fun(TableName)->
					{ok,OldRoleAttr} = dal:read_rpc(TableName),	
					lists:foreach(fun(RoleAttrInfo)->
								NewRoleAttrInfo = erlang:setelement(#roleattr.pet,RoleAttrInfo,{{buy_pet_slot,0},{present_pet_slot,4}}),
								dal:write_rpc(NewRoleAttrInfo)
							end,OldRoleAttr) 
				end,RoleAttrTables).

get_level_type(Level)->
	if
		(Level>=1) and (Level<40)->
			1;
		(Level>=40) and (Level<60)->
			2;
		(Level>=60) and (Level<80)->
			3;
		Level>=80->
			4
	end.

get_old_exp(Level)->
	case ets:lookup(?ETS_PET_LEVEL,Level) of
		[]->
			MinExp = 0;
		[{_,MinExp}]->
			nothing
	end,
	case ets:lookup(?ETS_PET_LEVEL,(Level+1)) of
		[]->
			MaxExp = 0;
		[{_,MaxExp}]->
			nothing
	end,
	{MinExp,MaxExp}.

%%
%%补偿规则
%%1.有大于等于1个RIDELIST中的坐骑奖励RIDEREWARDLIST1
%%2.不满足条件1 但是有坐骑 奖励RIDEREWARDLIST2
-define(RIDELIST,[33100108,31100108,31100106,33100106]).
-define(RIDEREWARDLIST1,[{33100108,1},{24000088,4}]).
-define(RIDEREWARDLIST2,[{24000088,4},{24000075,10}]).
reward_ride()->
	AllRideItemId = item_template_db:get_itemid_by_class(?ITEM_TYPE_RIDE),
	RoleAttrTables = rpc:call(node_util:get_dbnode(),db_split,get_splitted_tables,[roleattr]),
	FromName = language:get_string(?STR_SYSTEM),
	Title = language:get_string(?STR_SEND_RIDE_REWARD_TITLE),
	Context = language:get_string(?STR_SEND_RIDE_REWARD_CONTEXT),
	Add_Silver = 0,
	lists:foreach(fun(TableName)->
				{ok,RoleAttrs} = dal:read_rpc(TableName),
				lists:foreach(fun(RoleAttr)->				
					RoleID = element(#roleattr.roleid,RoleAttr),
					RoleName = role_db:get_name(RoleAttr),
					RoleItems = playeritems_db:loadrole(RoleID),
										
					RideItems = lists:filter(fun(ItemInfo)->
													Entry = playeritems_db:get_entry(ItemInfo),
													lists:member(Entry,AllRideItemId)
												end,RoleItems),
												
					GoldRideItems = lists:filter(fun(ItemInfo)->
													Entry = playeritems_db:get_entry(ItemInfo),
													lists:member(Entry,?RIDELIST)
												end,RideItems),
					
					if
						GoldRideItems =/= []->
							lists:foreach(fun({Proto,Count})->
									gm_op:gm_send_rpc(FromName,RoleName,Title,Context,Proto,Count,Add_Silver)
								end,?RIDEREWARDLIST1);
						RideItems =/= []->
							lists:foreach(fun({Proto,Count})->
									gm_op:gm_send_rpc(FromName,RoleName,Title,Context,Proto,Count,Add_Silver)
								end,?RIDEREWARDLIST2);
						true->
							nothing
					end
				end,RoleAttrs) end,RoleAttrTables).			 
		
	