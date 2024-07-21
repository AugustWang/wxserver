%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-1-7
%% Description: TODO: Add description to vip_op
-module(vip_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([export_for_copy/0,load_by_copy/1,write_to_db/0,
		 load_from_db/1,vip_init/0,
		 get_role_vip/0,get_role_vip_ext/1,
		 vip_ui_c2s/0,vip_reward_c2s/0,
		 login_bonus_reward_c2s/0,add_sum_gold/2,
		 add_sum_gold_of_pid/1,get_addition_with_vip/1,
		 npc_function/0,check_vip_level/1,vip_level_up_s2c/0,
		 system_bodcast/2,viptag_update/0,
		 check_vip_level_up_of_pid/1,check_vip_level_up/2,
		 sys_cast/2,is_vip/0,get_role_sum_gold/0,get_role_viplevel/0,
		 get_adapt_flytimes/1,check_have_vip_addition/0,hook_on_offline/0,join_vip_map/1]).
-include("error_msg.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("system_chat_define.hrl").
-include("vip_define.hrl").
%%
%% API Functions
%%
init_vip_role()->
	put(role_vip,[]).
init_role_sum_gold()->	
	put(role_sum_gold,[]).
init_role_login_bonus(RoleId)->
	put(role_login_bonus,{RoleId,0}).

load_from_db(RoleId)->
	case vip_db:get_vip_role(RoleId) of
		{ok,[]}->
			init_vip_role();
		{ok,RoleVip}->
			Now = timer_center:get_correct_now(),
			{MSec,Sec,_}=Now,
			CurSec = MSec*1000000+Sec,
			{vip_role,RoleId,StartTime,Duration,Level,BonusTime,LoginTime,FlyShoes} = RoleVip,
			if
				CurSec > StartTime+Duration->
					vip_db:delete_vip_role(RoleId),
					init_vip_role();
				true->
					case timer_util:check_same_day(Now, LoginTime) of
						true->
							put(role_vip,{RoleId,StartTime,Duration,Level,BonusTime,LoginTime,FlyShoes});
						_->
							{Type,FlyShoe} = get_adapt_flytimes(Level),
							put(role_vip,{RoleId,StartTime,Duration,Level,BonusTime,Now,{Type,FlyShoe}})
					end
			end;
		_->
			init_vip_role()
	end,
	case vip_db:get_role_sum_gold(RoleId) of
		{ok,[]}->
			init_role_sum_gold();
		{ok,RoleSumGold}->
			{role_sum_gold,RoleId,SumGold,DurationSum} = RoleSumGold,
			put(role_sum_gold,{RoleId,SumGold,DurationSum});
		_->
			init_role_sum_gold()
	end,
	case vip_db:get_role_login_bonus(RoleId) of
		{ok,[]}->
			init_role_login_bonus(RoleId),
			vip_db:sync_update_role_login_bonus_to_mnesia(RoleId, {RoleId,0});
		{ok,RoleLoginBonus}->
			{role_login_bonus,RoleId,LoginBonusTime} = RoleLoginBonus,			
			put(role_login_bonus,{RoleId,LoginBonusTime});
		_->
			init_role_login_bonus(RoleId)
	end.

get_adapt_flytimes(Level)->
	case vip_db:get_vip_level_info(Level) of
		[]->
			{0,0};
		{_,_,_,Addition,_}->
			case lists:keyfind(flyshoes,1,Addition) of
				false->
					{0,0};
				{_,{Type,Times}}->
					{Type,Times}
			end
	end.

get_role_viplevel()->
	case get(role_vip) of
		[]->
			0;
		{_,_,_,Level,_,_,_}->
			Level
	end.

hook_on_offline()->
	case get(role_vip) of
		[]->
			ignor;
		{RoleId,StartTime,Duration,Level,BonusTime,LoginTime,FlyShoes}->
			vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,StartTime,Duration,Level,BonusTime,LoginTime,FlyShoes})
	end.
	
check_login_bonus_time()->
	case get(role_login_bonus) of
		{_RoleId,LoginBonusTime}->
			case check_bonus_date(LoginBonusTime) of
				true->
					0;
				false->
					1
			end;
		_->
			0
	end.

vip_init()->
	LoginBonus = check_login_bonus_time(),
	case get(role_vip) of
		[]->
			vip_init_s2c(0,0,LoginBonus);	
		{_,_,_,Level,BonusTime,_,_}->
			case check_bonus_date(BonusTime) of
				true->
					vip_init_s2c(Level,0,LoginBonus);
				false->
					vip_init_s2c(Level,1,LoginBonus)
			end
	end.

get_role_vip()->
	case get(role_vip) of
		[]->
			0;
		{_,_,_,Level,_,_,_}->
			Level
	end.

%%vip level ext {1,2,3,4}={HALFYEAR,SEASON,MONTH,WEEK}
get_role_vip_ext(VipLevel)->
	case VipLevel of
		?ITEM_TYPE_VIP_CARD_MONTH->
			3;
		?ITEM_TYPE_VIP_CARD_SEASON->
			2;
		?ITEM_TYPE_VIP_CARD_HALFYEAR->
			1;
		?ITEM_TYPE_VIP_CARD_WEEK->
			4;
		?ITEM_TYPE_VIP_CARD_NEW_MONTH->
			3;
		?ITEM_TYPE_VIP_CARD_NEW_SEASON->
			2;
		?ITEM_TYPE_VIP_CARD_NEW_HALFYEAR->
			1;
		_->
			0
	end.

is_vip()->
	case get_role_vip() of
		0->
			false;
		_->
			true
	end.

%%Msg=kill_monster|block_training|enchantment|
%%{instance,InstanceID}|flyshoes|pet_slot_lock
get_addition_with_vip(Msg)->
	case get(role_vip) of
		[]->
			0;
		{RoleId,StartTime,Duration,Level,_,_,_}->
			{MSec,Sec,_}=timer_center:get_correct_now(),
			CurSec = MSec*1000000+Sec,
			if
				CurSec < StartTime+Duration->
					case vip_db:get_vip_level_info(Level) of
						[]->
							0;
						{_,_,_,Addition,_}->
							case Msg of
								{instance,InstanceID}->
									case lists:keyfind(instance, 1, Addition) of
										false->
											0;
										{instance,InstanceList}->
											case lists:keyfind(InstanceID, 1, InstanceList) of
												false->
													0;
												{_,Value}->
													Value
											end
									end;
								_->
									case lists:keyfind(Msg, 1, Addition) of
										false->
											0;
										{_,Value}->
											Value
									end
							end
					end;
				true->
					vip_db:delete_vip_role(RoleId),
					init_vip_role(),
					viptag_update(),
					0
			end
	end.

check_have_vip_addition()->
	case get(role_vip) of
		[]->
			false;
		{RoleId,StartTime,Duration,Level,BonusTime,LoginTime,{Type,FlyShoes}}->
			case Type of
				?INFINITE->
					true;
				_->
					case FlyShoes > 0 of
						true->
							put(role_vip,{RoleId,StartTime,Duration,Level,BonusTime,LoginTime,{Type,FlyShoes-1}}),
							{_,TotleNum}= get_adapt_flytimes(Level),
							Message = vip_packet:encode_vip_role_use_flyshoes_s2c(FlyShoes-1,TotleNum),
							role_op:send_data_to_gate(Message),
							true;
						_->
							false
					end
			end
	end.

get_bonus_from_db_term(Bonus)->
	RoleLevel=get_level_from_roleinfo(get(creature_info)),
	GetBonusFun=fun({{StartLevel,EndLevel},BonusTerm},Acc)->
				if 
					RoleLevel>=StartLevel,RoleLevel=<EndLevel->
						Acc++BonusTerm;
					true->
						Acc
				end
			end,
	case lists:keyfind(0, 1, Bonus) of
		{_KeyClass,ZeroBonusList}->
			lists:foldl(GetBonusFun, [], ZeroBonusList);
		false->
			RoleClass = get_class_from_roleinfo(get(creature_info)),
			case lists:keyfind(RoleClass, 1, Bonus) of
				{_KeyClass,ClassBonusList}->
					lists:foldl(GetBonusFun, [], ClassBonusList);
				false->
					[]
			end
	end.

vip_init_s2c(VipLevel,Type,Type2)->
	Message = vip_packet:encode_vip_init_s2c(VipLevel,Type,Type2),
	role_op:send_data_to_gate(Message).
	
export_for_copy()->
	{get(role_vip),get(role_sum_gold),get(role_login_bonus)}.
	
write_to_db()->
	nothing.

load_by_copy({RoleVip,RoleSumGold,RoleLoginBonus})->
	put(role_vip,RoleVip),
	put(role_sum_gold,RoleSumGold),
	put(role_login_bonus,RoleLoginBonus).

vip_ui_c2s()->
	case get(role_vip) of
		[]->
			vip_ui_s2c(0,0,0);
		{_RoleId,StartTime,Duration,Level,_BonusTime,_,_}->
			vip_ui_s2c(Level,get_role_sum_gold(),StartTime+Duration)
	end.

get_role_sum_gold()->
	case get(role_sum_gold) of
		undefined->
			0;
		[]->
			0;
		{_,SumGold,_}->
			SumGold
	end.

vip_reward_c2s()->
	case get(role_vip) of
		[]->
			Errno=?ERROR_IS_NOT_VIP;
		{RoleId,StartTime,Duration,Level,BonusTime,LoginTime,FlyShoes}->
			case check_bonus_date(BonusTime) of
				true->
					NowTime = timer_center:get_correct_now(),
					case vip_db:get_vip_level_info(Level) of
						[]->
							Errno=?ERRNO_NPC_EXCEPTION;
						{_,_,_,_,Bonus}->
							BonusList = get_bonus_from_db_term(Bonus),
							case package_op:get_empty_slot_in_package(erlang:length(BonusList)) of
								0->
									Errno=?ERROR_PACKEGE_FULL;
								_->	
									Errno=[],
									achieve_op:achieve_bonus(BonusList,vip_bonus),
									put(role_vip,{RoleId,StartTime,Duration,Level,NowTime,LoginTime,FlyShoes}),
									vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,StartTime,Duration,Level,NowTime,LoginTime,FlyShoes})
							end 
					end;
				false->
					Errno=?ERROR_VIP_REWARDED_TODAY
			end
	end,
	if 
		Errno =/= []->
			Message_failed = vip_packet:encode_vip_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

login_bonus_reward_c2s()->
	case check_login_bonus_time() of
		1->
			Errno=?ERROR_VIP_REWARDED_TODAY;
		0->
			NowTime = timer_center:get_correct_now(),
			case vip_db:get_vip_level_info(0) of
				[]->
					Errno=?ERRNO_NPC_EXCEPTION;
				{_,_,_,_,Bonus}->
					BonusList = get_bonus_from_db_term(Bonus),
					case package_op:get_empty_slot_in_package(erlang:length(BonusList)) of
						0->
							Errno=?ERROR_PACKEGE_FULL;
						_->	
							Errno=[],
							{RoleId,_} = get(role_login_bonus),
							achieve_op:achieve_bonus(BonusList,login_bonus),
							put(role_login_bonus,{RoleId,NowTime}),
							vip_db:sync_update_role_login_bonus_to_mnesia(RoleId, {RoleId,NowTime})
					end 
			end
	end,
	if 
		Errno =/= []->
			Message_failed = vip_packet:encode_vip_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

vip_ui_s2c(Vip,Gold,EndTime)->
	Message = vip_packet:encode_vip_ui_s2c(Vip,Gold,EndTime),
	role_op:send_data_to_gate(Message).

add_sum_gold(RoleId,Gold)->
	case vip_db:get_role_sum_gold(RoleId) of
		{ok,[]}->
%% 			NewGold=Gold,
			vip_db:sync_update_role_sum_gold_to_mnesia(RoleId, {RoleId,Gold,0});
		{ok,RoleSumGold}->
			{role_sum_gold,_,OGold,ODurationGold} = RoleSumGold,
			NewGold=OGold+Gold,
			vip_db:sync_update_role_sum_gold_to_mnesia(RoleId, {RoleId,NewGold,ODurationGold})
	end.
%%2011-04-08
%% 	check_vip_level_up(RoleId,NewGold).

check_vip_level_up(RoleId,CheckGold)->
	case vip_db:get_vip_role(RoleId) of
		{ok,[]}->
			nothing;
		{ok,{vip_role,RoleId,StartTime,Duration,Level,BonusTime,LoginTime,FlyShoe}}->
			NewLevel = check_vip_level(CheckGold),
			{MSec,Sec,_} = timer_center:get_correct_now(),
			CurSec = MSec*1000000+Sec,
			if 
				NewLevel>Level,CurSec<StartTime+Duration->
					vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,StartTime,Duration,NewLevel,BonusTime,LoginTime,FlyShoe});
				true->
					nothing
			end
	end.

add_sum_gold_of_pid(Gold)->
	case get(role_sum_gold) of
		[]->
			vip_db:sync_update_role_sum_gold_to_mnesia(get(roleid), {get_id_from_roleinfo(get(creature_info)),Gold,0}),
%% 			CheckVipGold = Gold,
			put(role_sum_gold,{get(roleid),Gold,0});
		{RoleId,OGold,ODurationGold}->
			NewGold=OGold+Gold,
			vip_db:sync_update_role_sum_gold_to_mnesia(RoleId, {RoleId,NewGold,ODurationGold}),
%% 			CheckVipGold = NewGold,
			put(role_sum_gold,{RoleId,NewGold,ODurationGold})
	end.
%%2011-04-08
%% 	check_vip_level_up_of_pid(CheckVipGold).

check_vip_level_up_of_pid(CheckGold)->
	case get(role_vip) of
		[]->
			nothing;
		{RoleId,StartTime,Duration,Level,BonusTime,LoginTime,FlyShoes}->
			NewLevel = check_vip_level(CheckGold),
%% 			RoleName = get_name_from_roleinfo(get(creature_info)),
			if 
				NewLevel>Level->
					put(role_vip,{RoleId,StartTime,Duration,NewLevel,BonusTime,LoginTime,FlyShoes}),
					viptag_update(),
					vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,StartTime,Duration,NewLevel,BonusTime,LoginTime,FlyShoes}),
					sys_cast(NewLevel,get(creature_info)),
					vip_level_up_s2c();
				true->
					nothing
			end
	end.

vip_level_up_s2c()->
	Message = vip_packet:encode_vip_level_up_s2c(),
	role_op:send_data_to_gate(Message).

vip_npc_enum_s2c(Vip,Bonus)->
	if Bonus=:=[]->
		   Bon=[];
	   true->
		   Bon=util:term_to_record_for_list(Bonus, l)
	end,
	Message = vip_packet:encode_vip_npc_enum_s2c(Vip,Bon),
	role_op:send_data_to_gate(Message).

npc_function()->
	case get(role_vip) of
		[]->
			vip_npc_enum_s2c(0,[]);
		{_,_,_,Level,BonusTime,_,_}->
			case check_bonus_date(BonusTime) of
				true->
					case vip_db:get_vip_level_info(Level) of
						[]->
							vip_npc_enum_s2c(0,[]);
						{_,_,_,_,Bonus}->
							BonusList = get_bonus_from_db_term(Bonus),
							vip_npc_enum_s2c(Level,BonusList)
					end;
				false->
					vip_npc_enum_s2c(Level,[])
			end
	end.
		
check_bonus_date(BonusTime)->
	if
		BonusTime=:=0->
			true;
		true->
			BonusDate = calendar:now_to_local_time(BonusTime),
			{{_BonusY,_BonusM,BonusD},{_,_,_}} = BonusDate, 
			NowTime = timer_center:get_correct_now(),
			NowDate = calendar:now_to_local_time(NowTime),
			{{_NowY,_NowM,NowD},{_,_,_}} = NowDate,
			if
				NowD =/= BonusD->
					true;
				true->
					false
			end
	end.

check_vip_level(CheckGold)->
	if
		CheckGold>0,CheckGold<2000->
			NewLevel=1;
		CheckGold>=2000,CheckGold<8000->
			NewLevel=2;
		CheckGold>=8000->
			NewLevel=3;
		%%CheckGold>=8000,CheckGold<40000->
		%%	NewLevel=3;
		%%CheckGold>=40000,CheckGold<200000->
		%%	NewLevel=4;
		%%CheckGold>=200000,CheckGold<1000000->
		%%	NewLevel=5;
		%%CheckGold>=1000000->
		%%	NewLevel=6;
		true->
			NewLevel=1
	end,
	NewLevel.

sys_cast(CL,RoleInfo)->
	case CL of
		0->
			nothing;
		CurLevel->
			if
				CurLevel=:=1->
				    system_bodcast(?SYSTEM_CHAT_VIP_1, RoleInfo);
				CurLevel=:=2->
				    system_bodcast(?SYSTEM_CHAT_VIP_2, RoleInfo);
				CurLevel=:=3->
				    system_bodcast(?SYSTEM_CHAT_VIP_3, RoleInfo);
				CurLevel=:=4->
					system_bodcast(?SYSTEM_CHAT_VIP_4, RoleInfo);
				CurLevel=:=5->
					system_bodcast(?SYSTEM_CHAT_VIP_1, RoleInfo);
				CurLevel=:=6->
					system_bodcast(?SYSTEM_CHAT_VIP_2, RoleInfo);
				CurLevel=:=7->
					system_bodcast(?SYSTEM_CHAT_VIP_3, RoleInfo);
				true->
					nothing
			end
	end.

system_bodcast(SysId,RoleInfo) ->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	system_chat_op:system_broadcast(SysId,[ParamRole]).

viptag_update()->
	Viptag = get_role_vip(),
	put(creature_info,set_viptag_to_roleinfo(get(creature_info),Viptag)),
	role_op:update_role_info(get(roleid),get(creature_info)),
	role_op:self_update_and_broad([{viptag,Viptag}]).
	
%%
%% Local Functions
%%
join_vip_map(TransportId)->
	case get(role_vip) of
		[]->
			nothing;
		_->
			transport_op:teleport(get(creature_info), get(map_info),TransportId)
	end.
	
