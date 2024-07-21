%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-12-10
%% Description: TODO: Add description to achieve_op
-module(achieve_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([load_achieve_role_from_db/1,export_for_copy/0,write_to_db/0,load_by_copy/1,
		 achieve_update/2,achieve_update/3,achieve_init/0,achieve_reward/1,
		 achieve_bonus/2,has_items_in_bonus/1,hook_on_swap_equipment/4,hook_on_swap_pet_equipment/1,
		 chess_spirit_team/1,role_attr_update/0,term_to_record_for_send_achieve/1,
		 add_hpmax_to_creature/1,get_achieve_add_attr/0]).
-include("mnesia_table_def.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("base_define.hrl").

-define(STATE_UNFINISHED,0).
-define(STATE_FINISHED,1).

-define(ACHIEVE_CANAWARD,1).
-define(ACHIEVE_AWARDED,2).
-define(ACHIEVE_CANNOTAWARD,3).
-define(ALL_FUWEN_TYPE,[1,2,3,4,5,6,7,8]).
-define(ARM_SLOT,7).
-define(SUIT_SLOTS,[2,3,4,5,9,10,11,12]).
-define(POWER,1).
-define(DEFENSE,2).
-define(HPMAX,3).
-define(HITRATE,4).
-define(DODGE,5).
-define(CRITICALRATE,6).
-define(CRITICALDAMAGE,7).
-define(TOUGHNESS,8).
%%-include("config_db_def.hrl").
%%
%% API Functions
%%
init()->
	put(achieve_role,[]),
	put(achieve_proto,[]).

load_achieve_role_from_db(RoleId)->
case achieve_db:get_achieve_role(RoleId) of 
	{ok,[]}->
		case achieve_db:get_all_achieve() of
			[]->
				put(achieve_role,[]),
                put(achieve_proto,[]);
			AllAchieve->
				AchieveRole=lists:map(fun(Achieve)->
											  AchieveId=achieve_db:get_achieve_id(Achieve),
											  {0,AchieveId,0} end,AllAchieve),
				FuwenRole=lists:map(fun(Fuwen)->
											{_,FuwenId,Type,Level,_,_}=Fuwen,
											{Type,Level} end,achieve_db:get_all_fuwen()),
				AwardRole=lists:map(fun(Award)->
											{_,AwardId,_,_}=Award,
											{3,AwardId} end,achieve_db:get_all_award()),
				put(achieve_role,{RoleId,{0,[],[],AchieveRole,AwardRole}}),
 				achieve_db:sync_update_achieve_role_to_mnesia(RoleId,{RoleId,{0,[],[],AchieveRole,AwardRole}}),
				put(achieve_proto,AllAchieve)
    end;
	{ok,RoleAchievesDB}->
		[{achieve_role,RoleId,RoleAchieve}]=RoleAchievesDB,
		put(achieve_role,{RoleId,RoleAchieve}),
		case achieve_db:get_all_achieve() of
			[]->
				put(achieve_proto,[]);
			AllAchieve->
				{_Achieve_value,_Recent_achieve,_Fuwen,Achieve_info,_Award}=RoleAchieve,
				NewAllAchieve=lists:foldl(fun(Achieve,Acc)->
												  #achieve_proto{achieveid={Chapter,Part}}=Achieve,
												  case lists:keyfind({Chapter,Part},2,Achieve_info) of
													  false->
														  Acc;
													  {State,_,_}->
														  if
															  State=:=1->
																  lists:keydelete({Chapter,Part},2,Acc);
															  true->
																  Acc
														  end;
													  _->
														  Acc
												  end
										  end,AllAchieve,AllAchieve),
				put(achieve_proto,NewAllAchieve)
		end
end.
%%achieve_init().

achieve_init()->
case  get(achieve_role) of
	[]->
		InitAchieves=[];
	{RoleId,RoleAchieve}->
		{Achieve_value,Recent_achieve,Fuwen,Achieve_info,Award}=RoleAchieve,
		InitAchieveInfo=lists:foldl(fun({State,AchieveId,Finished},Acc)->
											case Finished of
												0->
													Acc;
												_->
													Acc++[{State,AchieveId,Finished}]
											end
									end,[],Achieve_info),
		Initfuwen=lists:foldl(fun({State,AchieveId,Finished},Acc)->
									  case State of
										  ?STATE_UNFINISHED->
											  Acc;
										  ?STATE_FINISHED->
											  put(achieve_proto,lists:keydelete(AchieveId,2,get(achieve_proto))),
											  case lists:keyfind([AchieveId],6,achieve_db:get_all_fuwen()) of
												  false->
													  Acc;
												  {_,FuwenId,Type,Level,_,_}->
													  Acc++[{Type,Level}]
											  end
									  end
							  end,[],Achieve_info),
		InitFuwen=get_highest_level_of_fuwen(Initfuwen),
		InitRecentAchieve=Recent_achieve,
		InitAward=lists:filter(fun({State,Id})->
									   case State of
										   ?ACHIEVE_CANNOTAWARD->
											   false;
										   _->
											   true
									   end 
							   end,Award),
		%%Test=[{0,{0,0},6},{0,{0,1},1},{0,{0,2},1},{0,{0,3},1},{0,{0,4},1},{0,{0,5},1},{0,{0,6},1}],
		InitAchieves={Achieve_value,InitRecentAchieve,InitFuwen,InitAchieveInfo,InitAward},
		send_achieve_init(InitAchieves)
end.

check_part_is_finished(AchieveId,Target,Script)->
	case Script of
		[]->
			{other};
		Value->
			exec_beam(Value,todo,AchieveId,Target)
	end.

export_for_copy()->
	{get(achieve_role)}.
	%{get(achieve_role),get(achieve_proto)}.
	
write_to_db()->
	nothing.

load_by_copy({RoleAchieves})->
	put(achieve_role,RoleAchieves).

%如果线路不唯一时将下面打开,跟export_for_copy关联
%load_by_copy({RoleAchieves,AllAchieve})->
%put(achieve_role,RoleAchieves),
%	put(achieve_ptoro,AllAchieve).

has_items_in_bonus(Bonus)->
	Items_count = lists:foldl(fun({Class,_Count},Acc)->
								if 
									Class>3->
										Acc ++ [Class];
									true->
										Acc
								end
								end,[],Bonus),
	case erlang:length(Items_count) =:= 0 of
		true ->
			0;
		false->
			erlang:length(Items_count)
	end.

achieve_bonus(Bonus,Reason)->
	BonusFun=fun({Class,Count})->
				case Class of
					 1->%%exp
						 role_op:obtain_exp(Count);
					 2->%%silver
						 role_op:money_change(?MONEY_BOUND_SILVER, Count, Reason);
					 3->%%ticket
						 role_op:money_change(?MONEY_TICKET, Count, Reason);
					 TemplateId->%%items
						 case package_op:can_added_to_package_template_list([{Class,Count}]) of
							false->
								Message = achieve_packet:encode_achieve_error_s2c(?ERROR_PACKEGE_FULL),
								role_op:send_data_to_gate(Message);
							_->	
						 		role_op:auto_create_and_put(TemplateId, Count, Reason)
						 end
				end
			 end,
	lists:foreach(BonusFun, Bonus).

achieve_update(Message,Match)->
	achieve_op:achieve_update(Message,Match,1).

achieve_update(Message,Match,MsgValue)->
	case get(achieve_proto) of
		[]->
			nothing;
		AchieveList->
			lists:foreach(fun(AchieveInfo)->
						  {Chapter,Part} = achieve_db:get_achieve_id(AchieveInfo),
						  Target = achieve_db:get_achieve_require(AchieveInfo),
						  Type = achieve_db:get_achieve_type(AchieveInfo),
						  Script = achieve_db:get_achieve_script(AchieveInfo),
						  AchieveNum = achieve_db:get_achievenum_by_chapter(Chapter),
						  if (Chapter =/= 0) and (is_list(Target)) ->
						  	[{Msg,TargetMatch,Count}] = Target,
						  	if 
							  Message =:= {Msg}->
								  MatchLength = case erlang:length(Match) of
													1 ->
														[M] = Match,
														1;
													Len->
														M = 0,
														Len
												end,
								  case Type of 
									  count->
										  MatchResult = lists:member(M, TargetMatch),
										  if TargetMatch=:=[0];MatchResult->
										  		count_function({Chapter,Part},Match,Count,MsgValue);
											 true->
												 nothing
										  end;
									  match->
										  MatchResult = lists:member(M, TargetMatch),
										  if 
											  MatchResult->
												  match_function({Chapter,Part},Match,Target,Count,MsgValue,Script);
											  MatchLength>1->
												  match_function({Chapter,Part},Match,Target,Count,MsgValue,Script);
											  true->
												 nothing
										  end;
									  matchnum->
										  if TargetMatch=:=[0];TargetMatch=:=Match->
										  		matchnum_function({Chapter,Part},Match,Count,MsgValue);
											 true->
												nothing
										  end;
									  _->
										  nothing
								  end;
							  true->
								  nothing
						  	end;
						  	true->
								nothing
						  end
						  end,AchieveList)
	end.	
	
send_achieve_init(InitAchieves)->
	InitAchievesRecord = util:term_to_record_for_list([term_to_record_for_send_achieve(InitAchieves)], ach_send),
	InitMessage = achieve_packet:encode_achieve_init_s2c(InitAchievesRecord),
	role_op:send_data_to_gate(InitMessage).

send_achieve_update(AchieveUpdate)->
	AchievePartRecord = util:term_to_record_for_list([term_to_record_for_send_achieve(AchieveUpdate)],ach_send),
	UpdateMessage = achieve_packet:encode_achieve_update_s2c(AchievePartRecord),
	role_op:send_data_to_gate(UpdateMessage).

hook_on_swap_equipment(_SrcSlot,DesSlot,SrcInfo,DesInfo)->
	case package_op:where_slot(DesSlot) of
		body->
			Quality = get_qualty_from_iteminfo(SrcInfo),
			Level = get_level_from_iteminfo(SrcInfo),
			Star = get_enchantments_from_iteminfo(SrcInfo),
			Inventory = get_inventorytype_from_iteminfo(SrcInfo),
			Suit = get_equipmentset_from_iteminfo(SrcInfo),
			Sockets = case get_socketsinfo_from_iteminfo(SrcInfo) of
						[]->
							[0];
						_->
							[0,0]
					  end;							
		_->
			if
				DesInfo =:= []->
					Quality = 0,
					Level = 0,
					Star = 0,
					Inventory = 0,
					Suit = 0,
					Sockets = [0];
				true->
					Quality = get_qualty_from_iteminfo(DesInfo),
					Level = get_level_from_iteminfo(DesInfo),
					Star = get_enchantments_from_iteminfo(DesInfo),
					Inventory = get_inventorytype_from_iteminfo(DesInfo),
					Suit = get_equipmentset_from_iteminfo(DesInfo),
					Sockets = case get_socketsinfo_from_iteminfo(DesInfo) of
								[]->
									[0];
								_->
									[0,0]
					  		  end
			end	
	end,			
	achieve_update({body_equipment},[Quality]),
%% 	achieve_update({enchantments},[Star]),
	achieve_update({inlay},Sockets),
%% 	achieve_update({enchant},[Quality]),
	achieve_update({target_equipment},[Inventory]),
	achieve_update({target_enchant},[Inventory]),
	if
		DesSlot=:=?ARM_SLOT->
			achieve_update({target_arm},[Quality],Level);
		true->
			nothing
	end,
%% 	achieve_update({target_arm},[Quality],Level),
%% 	achieve_update({target_suit},[Suit],1),
	case lists:member(_SrcSlot,?SUIT_SLOTS) or lists:member(DesSlot,?SUIT_SLOTS) of
		true->
			achieve_update({target_suit},[Suit],1);
		_->
			nothing
	end,
	role_attr_update().

role_attr_update()->
%% 	{Meleedefense,Rangedefense,Magicdefense} = get_defenses_from_roleinfo(get(creature_info)),
%% 	achieve_update({power},[0],get_power_from_roleinfo(get(creature_info))),
%% 	achieve_update({hpmax},[0],get_hpmax_from_roleinfo(get(creature_info))),
%% 	achieve_update({defense},[0],Meleedefense + Rangedefense + Magicdefense),
	achieve_update({fighting_force},[0],get_fighting_force_from_roleinfo(get(creature_info))).

hook_on_swap_pet_equipment(Quality)->
	achieve_op:achieve_update({pet_equipment},[Quality]).

chess_spirit_team(CurSection)->
	achieve_op:achieve_update({chess_spirit_team},[0],[CurSection]).
%%
%% Local Functions
%%
count_function(AchieveId,_Match,Count,MsgValue)->
	case get(achieve_role) of
		[]->
			nothing;
		AchieveRole->
			{MyRoleId,{Achieve_value,Recent_achieve,Fuwen,Achieve_info,Award}} = AchieveRole,
			case lists:keyfind(AchieveId, 2, Achieve_info) of
				false->
					nothing;
				Info->
					{State,AchieveId,Finished} = Info,
					case State of
						0->
							if Finished+MsgValue>=Count->
								   %add_hpmax_to_creature(AchieveId),
								   Value=achieve_db:get_achieve_value_by_id(AchieveId),
								   UpdateValue=Value+Achieve_value, 
								   if erlang:length(Recent_achieve)<10 ->
										  UpdateRecent=[AchieveId]++Recent_achieve;
									  true->
										  UpdateRecent=[AchieveId]++(Recent_achieve--[lists:last(Recent_achieve)])
								   end,
								   UpdateFuwen= case lists:keyfind([AchieveId],6,achieve_db:get_all_fuwen()) of
													false->[];
													{_,FuwenId,Type,Level,_,_}->[{Type,Level}] end,
								   SaveFuwen=get_highest_level_of_fuwen(UpdateFuwen++Fuwen),
								   UpdateAward=update_award(UpdateValue),
								   SaveAward = case UpdateAward of
												   []->
													   Award;
												   [{1,Id}]->
													   lists:keyreplace(Id,2,Award,{1,Id})
											   end,
								   UpdateAchieveInfo=lists:keyreplace(AchieveId,2,Achieve_info,{1,AchieveId,Count}),					
								   AchieveRoleUpdate={MyRoleId,{UpdateValue,UpdateRecent,SaveFuwen,UpdateAchieveInfo,SaveAward}},
								   achieve_db:sync_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
								   put(achieve_role,AchieveRoleUpdate),
								   put(achieve_proto,lists:keydelete(AchieveId, 2, get(achieve_proto))),
								   %%Up=update_achieve_info({1,AchieveId,Count})++check_chapter_finished({1,AchieveId,Count}),
								   send_achieve_update({UpdateValue,UpdateRecent,UpdateFuwen,[{1,AchieveId,Count}],UpdateAward}),
								   send_achieve_update(check_chapter_finished({1,AchieveId,Count})),
								   add_hpmax_to_creature(AchieveId);
							   true->
								   AchieveRoleUpdate={MyRoleId,{Achieve_value,Recent_achieve,Fuwen,lists:keyreplace(AchieveId,2,Achieve_info,{0,AchieveId,Finished+MsgValue}),Award}},
								   achieve_db:async_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
								   put(achieve_role,AchieveRoleUpdate),
								   %case achieve_db:get_achievenum_by_id(AchieveId) of
									%   1->
									%	   nothing;
									 %  _->
								   send_achieve_update({Achieve_value,[],[],[{0,AchieveId,Finished+MsgValue}],[]}) %end 
							end;
						1->
							nothing
					end
			end
	end.

match_function(AchieveId,_Match,TargetMatch,Count,_MsgValue,Script)->
	case get(achieve_role) of
		[]->
			nothing;
		AchieveRole->
			{MyRoleId,{Achieve_value,Recent_achieve,Fuwen,Achieve_info,Award}} = AchieveRole,
			case lists:keyfind(AchieveId, 2, Achieve_info) of
				false->
					nothing;
				Target->
					{State,AchieveId,Finished} = Target,
					if 
						State=:=0->
							case check_part_is_finished(AchieveId,TargetMatch,Script) of
								{true,MatchResult}->
									%add_hpmax_to_creature(AchieveId),
									Value=achieve_db:get_achieve_value_by_id(AchieveId),
							        UpdateValue=Value+Achieve_value, 
							        if erlang:length(Recent_achieve)<10 ->
							            UpdateRecent=[AchieveId]++Recent_achieve;
								    true->
							            UpdateRecent=[AchieveId]++(Recent_achieve--[lists:last(Recent_achieve)])
							        end,
                                    UpdateFuwen= case lists:keyfind([AchieveId],6,achieve_db:get_all_fuwen()) of
													false->[];
													{_,FuwenId,Type,Level,_,_}->[{Type,Level}] end,
								   SaveFuwen=get_highest_level_of_fuwen(UpdateFuwen++Fuwen),
								   UpdateAward=update_award(UpdateValue),
								   SaveAward = case UpdateAward of
												   []->
													   Award;
												   [{1,Id}]->
													   lists:keyreplace(Id,2,Award,{1,Id})
											   end,
								   UpdateAchieveInfo=lists:keyreplace(AchieveId,2,Achieve_info,{1,AchieveId,MatchResult}),					
								   AchieveRoleUpdate={MyRoleId,{UpdateValue,UpdateRecent,SaveFuwen,UpdateAchieveInfo,SaveAward}},
								   achieve_db:sync_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
								   put(achieve_role,AchieveRoleUpdate),
								   put(achieve_proto,lists:keydelete(AchieveId, 2, get(achieve_proto))),
									%%Up=update_achieve_info({1,AchieveId,Count})++check_chapter_finished({1,AchieveId,Count}),
								   send_achieve_update({UpdateValue,UpdateRecent,UpdateFuwen,[{1,AchieveId,MatchResult}],UpdateAward}),
								   send_achieve_update(check_chapter_finished({1,AchieveId,MatchResult})),
									add_hpmax_to_creature(AchieveId);
								{false,MatchResult}->
									if 
										MatchResult>Finished->
											AchieveRoleUpdate={MyRoleId,{Achieve_value,Recent_achieve,Fuwen,lists:keyreplace(AchieveId,2,Achieve_info,{0,AchieveId,MatchResult}),Award}},
											achieve_db:async_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
											put(achieve_role,AchieveRoleUpdate),
											case achieve_db:get_achievenum_by_id(AchieveId) of
												1->
													nothing;
												_->
											send_achieve_update({Achieve_value,[],[],[{0,AchieveId,MatchResult}],[]}) end;
										true->
											nothing
									end;
								_->
									nothing
							end;
						true->
							nothing
					end
			end
	end.

matchnum_function(AchieveId,_Match,Count,MsgValue)->
	case get(achieve_role) of
		[]->
			nothing;
		AchieveRole->
			{MyRoleId,{Achieve_value,Recent_achieve,Fuwen,Achieve_info,Award}} = AchieveRole,
			case lists:keyfind(AchieveId, 2, Achieve_info) of
				false->
					nothing;
				Info->
					{State,AchieveId,Finished} = Info,
					case State of
						0->
							if MsgValue>=Count->
								   %add_hpmax_to_creature(AchieveId),
								   Value=achieve_db:get_achieve_value_by_id(AchieveId),
								   UpdateValue=Value+Achieve_value, 
								   if erlang:length(Recent_achieve)<10 ->
										  UpdateRecent=[AchieveId]++Recent_achieve;
									  true->
										  UpdateRecent=[AchieveId]++(Recent_achieve--[lists:last(Recent_achieve)])
								   end,
								   UpdateFuwen= case lists:keyfind([AchieveId],6,achieve_db:get_all_fuwen()) of
													false->[];
													{_,FuwenId,Type,Level,_,_}->[{Type,Level}] end,
								   SaveFuwen=get_highest_level_of_fuwen(UpdateFuwen++Fuwen),
								   UpdateAward=update_award(UpdateValue),
								   SaveAward = case UpdateAward of
												   []->
													   Award;
												   [{1,Id}]->
													   lists:keyreplace(Id,2,Award,{1,Id})
											   end,
								   UpdateAchieveInfo=lists:keyreplace(AchieveId,2,Achieve_info,{1,AchieveId,Count}),					
								   AchieveRoleUpdate={MyRoleId,{UpdateValue,UpdateRecent,SaveFuwen,UpdateAchieveInfo,SaveAward}},
								   achieve_db:sync_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
								   put(achieve_role,AchieveRoleUpdate),
								   put(achieve_proto,lists:keydelete(AchieveId, 2, get(achieve_proto))),
								   send_achieve_update({UpdateValue,UpdateRecent,UpdateFuwen,[{1,AchieveId,Count}],UpdateAward}),
								   send_achieve_update(check_chapter_finished({1,AchieveId,Count})),
								   add_hpmax_to_creature(AchieveId);
							   true->
								   AchieveRoleUpdate={MyRoleId,{Achieve_value,Recent_achieve,Fuwen,lists:keyreplace(AchieveId,2,Achieve_info,{0,AchieveId,0}),Award}},
								   achieve_db:async_update_achieve_role_to_mnesia(MyRoleId,AchieveRoleUpdate),
								   put(achieve_role,AchieveRoleUpdate),
								   case achieve_db:get_achievenum_by_id(AchieveId)=:=1 of
									   true->
										   nothing;
									   _->
								   send_achieve_update({Achieve_value,[],[],[{0,AchieveId,MsgValue}],[]}) end
							end;
						1->
							nothing
					end
			end
	end.

term_to_record_for_send_achieve(SendInfo)->%%将消息中每个元组转化成对应记录
	{Achieve_value,Recent_achieve,Fuwen,Achieve_info,Award}=SendInfo,
	case Achieve_info of
		[]->
			AchInfoRecord=[];
		_->
			AchInfoRecord=lists:map(fun({State,AchieveId,Finished})->
												 IdToRecord=util:term_to_record(AchieveId,ach_id),
												 util:term_to_record({State,IdToRecord,Finished},achieve_info)
										 end,Achieve_info) 
	end,
	case Recent_achieve of
		[]->
			RecRecord=[];
		_->
			RecRecord=lists:map(fun({Chapter,Part})->
											util:term_to_record({Chapter,Part},ach_id) 
									end,Recent_achieve) 
	end,
	case Fuwen of
		[]->
			FwRecord=[];
		_->
			FwRecord=lists:map(fun({Type,Level})->
										   util:term_to_record({Type,Level},fw)
								   end,Fuwen) 
	end,
	case Award of
		[]->
			AwardRecord=[];
		_->
			AwardRecord=lists:map(fun({State,Id})->
											  util:term_to_record({State,Id},award_state)
									  end,Award) 
	end,
	{Achieve_value,RecRecord,FwRecord,AchInfoRecord,AwardRecord}.

add_hpmax_to_creature(AchieveId)->%%给角色增加生命上限,同时如果已经获得符文，将变化的属性更新到客户端
	Hpup=achieve_db:get_achieve_hp_by_id(AchieveId),
	RoleInfo=get(creature_info),
	Hpmax=get_hpmax_from_roleinfo(RoleInfo),
	NewHpmax=Hpup+Hpmax,
	NewInfo=set_hpmax_to_roleinfo(RoleInfo,NewHpmax),
	put(creature_info,NewInfo),
	role_op:only_self_update([{hpmax,NewHpmax}]),
	role_op:update_role_info(get(roleid),NewInfo),
	role_fighting_force:hook_on_change_role_fight_force(),
	case get(achieve_role) of
		[]->
			nothing;
		AchieveRole->
			{_MyRoleId,{_Achieve_value,_Recent_achieve,Fuwen,_Achieve_info,_Award}} = AchieveRole,
			case Fuwen of
				[]->
					nothing;
				_->
					lists:foreach(fun({Type,_Level})->
										  case Type of
											  ?POWER->
					Power=get_power_from_roleinfo(get(creature_info)),
					role_op:only_self_update([{power,Power}]);
											  ?HITRATE->
					Hitrate=get_hitrate_from_roleinfo(get(creature_info)),
					role_op:only_self_update([{hitrate,Hitrate}]);
											  ?DODGE->
					Dodge=get_dodge_from_roleinfo(get(creature_info)),
					role_op:only_self_update([{dodge,Dodge}]);
											  ?TOUGHNESS->
					Toughness=get_toughness_from_roleinfo(get(creature_info)),
					role_op:only_self_update([{toughness,Toughness}]);
											  ?CRITICALRATE->
					Criticalrate=get_criticalrate_from_roleinfo(get(creature_info)),
					role_op:only_self_update([{criticalrate,Criticalrate}]);
											  ?CRITICALDAMAGE->
					Criticaldamage=get_criticaldamage_from_roleinfo(get(creature_info)),
					role_op:only_self_update([{criticaldestroyrate,Criticaldamage}]);
											  ?DEFENSE->
					{Magicdefense,Rangedefense,Meleedefense}=get_defenses_from_roleinfo(get(creature_info)),
					role_op:only_self_update([{magicdefense,Magicdefense}]),
					role_op:only_self_update([{rangedefense,Rangedefense}]),
					role_op:only_self_update([{meleedefense,Meleedefense}]);
											  ?HPMAX->
												  Hpmax1=get_hpmax_from_roleinfo(get(creature_info)),
												  role_op:only_self_update([{hpmax,Hpmax1}]);
											  _->
												  nothing
										  end
								  end,Fuwen)
			end
	end.

get_achieve_add_attr()->%%成就血量上限提升以及符文属性加成属于永久增加，计算人物战力时应加入
	case get(achieve_role) of
		[]->
			[];
		AchieveRole->
			{_MyRoleId,{_Achieve_value,_Recent_achieve,Fuwen,Achieve_info,_Award}} = AchieveRole,
			HpSum=lists:foldl(fun({State,Id,_Finished},Acc)->
									  case State of
										  0->
											  Acc;
										  _->
											  Acc+achieve_db:get_achieve_hp_by_id(Id)
									  end
							  end,0,Achieve_info),
			FwList= case Fuwen of
						[]->
							[];
						_->
							lists:foldl(fun({Type,Level},Acc)->
												case lists:keyfind(Type*10+Level,2,achieve_db:get_all_fuwen()) of
													false->
														Acc;
													{_,_,_,_,Buffer,_}->
														Buffer++Acc
												end
										end,[],Fuwen)
					end,
			[{hpmax,HpSum}]++FwList
	end.

get_highest_level_of_fuwen(Fuwen)->%%获取同类中等级最高符文
	case Fuwen of
		[]->
			[];
		_->
			lists:foldl(fun(N,A)->
								ListN=lists:foldl(fun({T,L},Acc)->
														  case T of
															  N->
																  Acc++[{T,L}];
															  _->
																  Acc
														  end
												  end,[],Fuwen),
								case ListN of
									[]->
										A;
									_->
										case erlang:length(ListN) of
											1->
												ListN++A;
											2->
												[{T1,L1},{T2,L2}]=ListN,
												if
													L1>=L2->
														[{N,L1}]++A;
													true->
														[{N,L2}]++A
												end;
											3->
												[{N,3}]++A;
											_->
												A
										end
								end 
						end,[],?ALL_FUWEN_TYPE)
	end.

achieve_reward(AwardId)->
	case get(achieve_role) of
		[]->
			Errno=?ERRNO_NPC_EXCEPTION;
		{RoleId,AchieveRole}->
			{AchieveValue,RecentAchieve,Fuwen,AchieveInfo,Award}=AchieveRole,
			case lists:keyfind(AwardId,2,Award) of
				false->
					Errno=?ERROR_ACHIEVE_TARGET_NOEXSIT;
				{State,AwardId}->
					case State of
						?ACHIEVE_CANAWARD->
							case achieve_db:get_award_info(AwardId) of
								[]->
									Errno=?ERRNO_NPC_EXCEPTION;
								{_,_,_,Bonus}->
									[{Id,Count}]=Bonus,
									Errno=[],
									case package_op:can_added_to_package_template_list(Bonus) of
										false->
											Message = achieve_packet:encode_achieve_error_s2c(?ERROR_PACKEGE_FULL),
											role_op:send_data_to_gate(Message);
										_->
											achieve_bonus(Bonus,goals_bonus),
											%%发送日志待添加%%
                                            if
												Errno=:=[]->
													UpdateAward=lists:keyreplace(AwardId,2,Award,{2,AwardId}),
													Update={AchieveValue,[],[],[],[{2,AwardId}]},
													SaveUpdate={AchieveValue,RecentAchieve,Fuwen,AchieveInfo,UpdateAward},
													achieve_db:async_update_achieve_role_to_mnesia(RoleId,{RoleId,SaveUpdate}),
%% 													achieve_db:sync_update_achieve_role_to_mnesia(RoleId,SaveUpdate),
													put(achieve_role,{RoleId,SaveUpdate}),
													send_achieve_update(Update);
											true->
												nothing
											end
									end
							end;
						_->
							Errno=?ERROR_ACHIEVE_TARGET_NOT_FINISHED
					end
			end
	end,
	if
		Errno =/= []->
			Message_failed = achieve_packet:encode_achieve_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

update_award(Value)->
	case get(achieve_role) of
		[]->
			UpdateAward=[];
		{RoleId,AchieveRole}->
			{_,_,_,_,Award}=AchieveRole,
			List=lists:foldl(fun({_,Id,RequireValue,_},Acc)->
									 if
										 Value>=RequireValue->
											 Acc++[Id];
										 true->
											 Acc
									 end
							 end,[],achieve_db:get_all_award()),
			case List of
				[]->
					UpdateAward=[];
				_->
			Max=lists:max(List),
			UpdateAward=case lists:keyfind(Max,2,Award) of
							false->
								[];
							{State,Max}->
								case State of
									3->
										[{1,Max}];
									_->
										[]
								end
						end
			end
	end,
	UpdateAward.

update_achieve_info({State,AchieveId,Count})->
	{Chapter,Part}=AchieveId,
	{RoleId,AchieveRole}=get(achieve_role),
	{Value,Recent,Fuwen,AchieveInfo,Award}=AchieveRole,
	case State of
		0->
			Up=[];
		_->
	case lists:keyfind({0,Chapter},2,AchieveInfo) of
		false->
			Up=[];
		{State,_,Finished}->
			case State of
				1->
					Up=[];
				_->
					UpdateC=[{0,{0,Chapter},Finished+1}],
					Up=UpdateC,
					achieve_db:sync_update_achieve_role_to_mnesia(RoleId,{RoleId,{Value,Recent,Fuwen,lists:keyreplace({0,Chapter},2,AchieveInfo,{0,{0,Chapter},Finished+1}),Award}}),
					put(achieve_role,{RoleId,{Value,Recent,Fuwen,lists:keyreplace({0,Chapter},2,AchieveInfo,{0,{0,Chapter},Finished+1}),Award}}),
					case lists:keyfind({0,0},2,AchieveInfo) of
						false->
							Up=UpdateC;
						{S,_,F}->
							case S of
								1->
									Up=UpdateC;
								0->
									Update0=[{0,{0,0},F+1}],
									achieve_db:sync_update_achieve_role_to_mnesia(RoleId,{RoleId,{Value,Recent,Fuwen,lists:keyreplace({0,0},2,AchieveInfo,{0,{0,0},F+1}),Award}}),
									put(achieve_role,{RoleId,{Value,Recent,Fuwen,lists:keyreplace({0,0},2,AchieveInfo,{0,{0,0},F+1}),Award}}),
									Up=Update0++UpdateC
							end
					end
			end;
		_->
			Up=[]
	end
	end,
	Up.

check_chapter_finished(Info)->
	{State,AchieveId,_Count}=Info,
	{Chapter,Part}=AchieveId,
	{RoleId,AchieveRole}=get(achieve_role),
	{Value,Recent,Fuwen,AchieveInfo,Award}=AchieveRole,
	case State of
		0->
			{Value,Recent,[],[],[]};
		_->
			CNum=achieve_db:get_achievenum_by_chapter(Chapter),
			PNum=achieve_db:get_achievenum_by_id({Chapter,CNum}),
			Result=lists:keyfind({Chapter,CNum},2,AchieveInfo),
			if 
				Result=:=false ->{Value,Recent,[],[],[]};
				true->
				{SState,_,SFinished}=Result,
					case SState of
						1->
							{Value,Recent,[],[],[]};
						_->
							case SFinished+1>=PNum of
								true->
									UpdateInfo=lists:keyreplace({Chapter,CNum},2,AchieveInfo,{1,{Chapter,CNum},PNum}),
									Va=achieve_db:get_achieve_value_by_id({Chapter,CNum}),
									%%add_hpmax_to_creature({Chapter,CNum}),
									UpAward=update_award(Value+Va),
									if erlang:length(Recent)<10 ->
										  UpdateRecent=[{Chapter,CNum}]++Recent;
									  true->
										  UpdateRecent=[{Chapter,CNum}]++(Recent--[lists:last(Recent)])
								   end,
									achieve_db:sync_update_achieve_role_to_mnesia(RoleId,{RoleId,{Value+Va,UpdateRecent,Fuwen,UpdateInfo,Award++UpAward}}),
									put(achieve_role,{RoleId,{Value+Va,UpdateRecent,Fuwen,UpdateInfo,Award++UpAward}}),
									put(achieve_proto,lists:keydelete({Chapter,CNum},2,get(achieve_proto))),
									add_hpmax_to_creature({Chapter,CNum}),
									{Value+Va,Recent,[],[{1,{Chapter,CNum},PNum}],UpAward};
								false->
									UpdateInfo=lists:keyreplace({Chapter,CNum},2,AchieveInfo,{0,{Chapter,CNum},SFinished+1}),
									achieve_db:async_update_achieve_role_to_mnesia(RoleId,{RoleId,{Value,Recent,Fuwen,UpdateInfo,Award}}),
									put(achieve_role,{RoleId,{Value,Recent,Fuwen,UpdateInfo,Award}}),
									{Value,Recent,[],[{0,{Chapter,CNum},SFinished+1}],[]}
							end
					end
			end
	end.
			
exec_beam(Mod,Fun,AchieveId,Target)->
	try 
		Mod:Fun(AchieveId,Target) 
	catch
		Errno:Reason -> 	
			slogger:msg("exec_beam error Script : ~p fun:~p AchieveId: ~p Target: ~p ~p:~p ~n",[Mod,Fun,AchieveId,Target,Errno,Reason]),
			false
	end.
