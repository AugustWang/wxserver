%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-4
%% Description: TODO: Add description to guild_upgrade
-module(guild_facility).

%%
%% Include files
%%
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
upgrade(FacilityId)->	
	guild_manager:upgrade(guild_util:get_guild_id(),get(roleid),FacilityId).
	
upgrade_speedup(Facilitieid,Itemid)->	
	case items_op:get_item_info(Itemid) of
		[]->
			nothing;
		ItemInfo ->
			States = get_states_from_iteminfo(ItemInfo),
			ItemName = get_name_from_iteminfo(ItemInfo),
			{contribute,AddContribute} = lists:keyfind(contribute,1,States),
			case lists:keyfind(reduce_time,1,States) of
				{reduce_time,Time}->
					SpeedType = reduce_time,
					SpeedValue = Time;					
				false->
					case lists:keyfind(reduce_timerate,1,States) of	
			 			{reduce_timerate,Timerate}->
			 				SpeedType = reduce_timerate,
							SpeedValue = Timerate;
						false->
							SpeedType =[],
							SpeedValue =[]
					end
			end,
			if 
				SpeedType =/= []->
					case guild_manager:upgrade_speedup(guild_util:get_guild_id(),get(roleid),Facilitieid,SpeedType,SpeedValue,{ItemName,AddContribute}) of
						ok->
%% 							achieve_op:achieve_update({contribute_guild},[?TYPE_GUILD_CONTRIBUTION],AddContribute),
							role_op:consume_item(ItemInfo,1);
						_->
							nothing
					end;
				true->
					nothing
			end
	end.

update_facility_info(Facilityid,FaciltiyInfo)->				
	guild_util:set_guild_facility_info(Facilityid,FaciltiyInfo).
				
set_facility_rule(Facilityid,Requirevalue)->
	guild_manager:set_facility_rule(guild_util:get_guild_id(),get(roleid),Facilityid,Requirevalue).

falility_required_check(FacilityId,Level)->
	FacilityInfo = guild_proto_db:get_facility_info(FacilityId,Level),
	CheckList = guild_proto_db:get_facility_check_script(FacilityInfo),
	{RequiredMoneyList,ItemList} = guild_proto_db:get_facility_require_resource(FacilityInfo),
	BaseCheck = lists:foldl(fun(Check,ReSult)->
		if 
			ReSult ->					
				case  guild_util:run_check(Check) of
					true->
						true;
					{error,level}->
						?ERROR_LESS_LEVEL
				end;
			true->
				ReSult
		end end,true,CheckList),
	if 
		BaseCheck ->
			ItemCheck = lists:foldl(fun({[ItemId,BoundItemId],ItemCount},Result)->
							if 
								Result =:= false ->
									case item_util:is_has_enough_item_in_package(BoundItemId,ItemCount) of
										true->
											true;
										_->
											item_util:is_has_enough_item_in_package(ItemId,ItemCount)
									end;
								true->			
									Result						 			
						 	end end,false,ItemList),
			if
				ItemCheck->%%12æœˆ21æ—¥ä¿®æ”¹[xiaowu]
					case Level of
						1 ->
							MoneyCheck = lists:foldl(fun({MoneyType,MoneyCount},Result)->
										if
											Result->														
												case script_op:has_money(MoneyType,MoneyCount) of
													true->
														true;
													_->
														?GUILD_ERRNO_MONEY_NOT_ENOUGH
												end;
											true->
												Result												
										end			
									end,true,RequiredMoneyList);
						2 ->
							MoneyCheck = case script_op:has_money(?MONEY_GOLD,128) of
												true ->
													true;
												_ ->
													?GUILD_ERRNO_MONEY_NOT_ENOUGH
										end
					end,%%
						AllCheck = MoneyCheck;
				true->
					AllCheck =  ?GUILD_ERRNO_ITEM_NOT_ENOUGH
			end;
		true->
			AllCheck = 	BaseCheck					
	end,
	AllCheck.

get_guild_facility_required(TypeId)->
	Facility_list = guild_util:get_guild_facility(),
	case lists:keyfind(TypeId,1,Facility_list) of
		false->
			[];
		{TypeId,_,_,_,Required}->
			Required
	end.

falility_required_destroy(FacilityId,Level)->
	FacilityInfo = guild_proto_db:get_facility_info(FacilityId,Level),
	{RequiredMoneyList,ItemList} = guild_proto_db:get_facility_require_resource(FacilityInfo),
	lists:foreach(fun({[ItemId,BoundItemId],ItemCount})->
						  			case item_util:is_has_enough_item_in_package(BoundItemId,ItemCount) of
										true->
											role_op:consume_items(BoundItemId,ItemCount);
										_->
											case item_util:is_has_enough_item_in_package(ItemId,ItemCount) of
												true->
													role_op:consume_items(ItemId,ItemCount);
												_->
													ignor
											end
									end
							 end,ItemList),
	case Level of%%12æœˆ21æ—¥å†™[xiaowu]
		1 ->
			lists:foreach(fun({MoneyType,MoneyCount})->
							  role_op:money_change(MoneyType,-MoneyCount,lost_function)
						end,RequiredMoneyList);
		2 ->
			role_op:money_change(?MONEY_GOLD,-128,lost_function)
	end.%%
	
						
	
run_check({level,Level})->
	case get_level_from_roleinfo(get(creature_info))>= Level of
		true->
			true;
		false->
			{error,level}
	end.

change_smith_need_contribution(Contribution)->
	guild_manager:change_smith_need_contribution({guild_util:get_guild_id(),Contribution}).