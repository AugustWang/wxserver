%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-1-10
%% Description: TODO: Add description to vip_card_script
-module(vip_card_script).

%%
%% Include files
%%
-export([use_item/1]).
-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("system_chat_define.hrl").
-include("vip_define.hrl").
%%
%% Exported Functions
%%


%%
%% API Functions
%%
use_item(ItemInfo)->
	RoleId = get(roleid),
	%%RoleName = get_name_from_roleinfo(get(creature_info)),
	VipCard = get_states_from_iteminfo(ItemInfo),
	{MSec,Sec,_}=timer_center:get_correct_now(),
	CurSec=MSec*1000000+Sec,
	Duration = case VipCard of
		[?ITEM_TYPE_VIP_CARD_MONTH]->
			CardType=?ITEM_TYPE_VIP_CARD_MONTH,
			CompareType=4,
			60*60*24*30;
		[?ITEM_TYPE_VIP_CARD_SEASON]->
			CardType=?ITEM_TYPE_VIP_CARD_SEASON,
			CompareType=5,
			60*60*24*30*3;
		[?ITEM_TYPE_VIP_CARD_HALFYEAR]->
			CardType=?ITEM_TYPE_VIP_CARD_HALFYEAR,
			CompareType=6,
			60*60*24*30*6;
		[?ITEM_TYPE_VIP_CARD_WEEK]->
			CardType=?ITEM_TYPE_VIP_CARD_WEEK,
			CompareType=3,
			60*60*24*7;
		[?ITEM_TYPE_VIP_CARD_NEW_MONTH]->
			CardType=?ITEM_TYPE_VIP_CARD_NEW_MONTH,
			CompareType=4,
			60*60*24*30;
		[?ITEM_TYPE_VIP_CARD_NEW_SEASON]->
			CardType=?ITEM_TYPE_VIP_CARD_NEW_SEASON,
			CompareType=5,
			60*60*24*30*3;
		[?ITEM_TYPE_VIP_CARD_NEW_HALFYEAR]->
			CardType=?ITEM_TYPE_VIP_CARD_NEW_HALFYEAR,
			CompareType=6,
			60*60*24*30*6;
		[?ITEM_TYPE_VIP_CARD_EXPERIENCE]->
			CardType=?ITEM_TYPE_VIP_CARD_EXPERIENCE,
			CompareType=1,
			60*30;
		[?ITEM_TYPE_VIP_CARD_3DAY]->
			CardType=?ITEM_TYPE_VIP_CARD_3DAY,
			CompareType=2,
			60*60*24*3;
		_->
			CardType=0,
			CompareType=0,
			false
	end,
	case Duration of 
		false->
			false;
		DTime->
			case get(role_vip) of
				[]->
%%2011-04-08
%% 					case get(role_sum_gold) of
%% 						[]->
%% 							CheckLevel=1;
%% 						{_,SumGold,_}->
%% 							CheckLevel = vip_op:check_vip_level(SumGold)
%% 					end,
%%					put(role_vip,{RoleId,CurSec,DTime,CheckLevel,0}),
					FlyTimes = vip_op:get_adapt_flytimes(CardType),
					put(role_vip,{RoleId,CurSec,DTime,CardType,0,now(),FlyTimes}),
					achieve_op:achieve_update({vip},VipCard),%%@@wb20130401鎴愬氨鏇存柊
					spa_op:hook_on_vip_up(0,CardType),
%% 					vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,CurSec,DTime,CheckLevel,0}),
					gm_logger_role:role_vip(RoleId,CardType,get(level)),
 					vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,CurSec,DTime,CardType,0,now(),FlyTimes}),
					vip_op:vip_ui_c2s(),
					vip_op:viptag_update(),
					sys_cast(CardType,get(creature_info)),
					true;
				{_,StartTime,DurationTime,VipLevel,BonusTime,LoginTime,FlyShoes}->
					spa_op:hook_on_vip_up(VipLevel,CardType),
					FlyTimes = vip_op:get_adapt_flytimes(CardType),
					case VipLevel of
						?ITEM_TYPE_VIP_CARD_NEW_HALFYEAR->
							CompareLevel = 6;
						?ITEM_TYPE_VIP_CARD_NEW_SEASON->
							CompareLevel = 5;
						?ITEM_TYPE_VIP_CARD_NEW_MONTH->
							CompareLevel = 4;
						?ITEM_TYPE_VIP_CARD_WEEK->
							CompareLevel = 3;
						?ITEM_TYPE_VIP_CARD_HALFYEAR->
							CompareLevel=6;
						?ITEM_TYPE_VIP_CARD_SEASON->
							CompareLevel=5;
						?ITEM_TYPE_VIP_CARD_MONTH->
							CompareLevel=4;
						?ITEM_TYPE_VIP_CARD_EXPERIENCE->
							CompareLevel=1;
						?ITEM_TYPE_VIP_CARD_3DAY->
							CompareLevel=2
					end,
					if 
						CurSec<(StartTime+DurationTime)->
							Flag=true,
							NewStartTime = StartTime,
							NewDuration = DurationTime+DTime;
						true->
							Flag=false,
							NewStartTime = CurSec,
							NewDuration = DTime
					end,
					if
						CompareType>CompareLevel->
							sys_cast(CardType,get(creature_info)),
							put(role_vip,{RoleId,NewStartTime,NewDuration,CardType,BonusTime,LoginTime,FlyTimes}),
							gm_logger_role:role_vip(RoleId,CardType,get(level)),
							vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,NewStartTime,NewDuration,CardType,BonusTime,LoginTime,FlyTimes});
						true->
							if
								Flag->
									vip_op:sys_cast(CardType,get(creature_info)),
									put(role_vip,{RoleId,NewStartTime,NewDuration,VipLevel,BonusTime,LoginTime,FlyShoes}),
									gm_logger_role:role_vip(RoleId,CardType,get(level)),
									vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,NewStartTime,NewDuration,VipLevel,BonusTime,LoginTime,FlyShoes});
								true->
									sys_cast(CardType,get(creature_info)),
									put(role_vip,{RoleId,NewStartTime,NewDuration,CardType,BonusTime,LoginTime,FlyTimes}),
									gm_logger_role:role_vip(RoleId,CardType,get(level)),
									vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,NewStartTime,NewDuration,CardType,BonusTime,LoginTime,FlyShoes})
							end
					end,
					achieve_op:achieve_update({vip},VipCard),%%@@wb20130401鎴愬氨鏇存柊
%% 					put(role_vip,{RoleId,NewStartTime,NewDuration,VipLevel,BonusTime}),
%% 					vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,NewStartTime,NewDuration,VipLevel,BonusTime}),
					vip_op:vip_ui_c2s(),
					vip_op:viptag_update(),
					true;
				_->
					false
			end
	end.

sys_cast(CT,RoleInfo)->
	case CT of
		0->
			nothing;
		CardType->
			if
				CardType=:=1->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_1, RoleInfo);
				CardType=:=2->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_2, RoleInfo);
				CardType=:=3->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_3, RoleInfo);
				CardType=:=4->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_4, RoleInfo);
				CardType=:=5->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_1, RoleInfo);
				CardType=:=6->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_2, RoleInfo);
				CardType=:=7->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_3, RoleInfo);
				true->
					nothing
			end
	end.

	

%%
%% Local Functions
%%

