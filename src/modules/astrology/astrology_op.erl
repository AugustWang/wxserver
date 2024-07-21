%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaowu
%% Created: 2013-5-2
%% Description: 占星各项功能【小五】: Add description to astrology_op
-module(astrology_op).

%%
%% Include files
%%
-include("astrology_def.hrl").
-include("common_define.hrl").

%%
%% Exported Functions
%%
-export([init/2,astrology_init/1,astrology_action/2,astrology_pickup/2,astrology_pickup_all/2,astrology_sale_all/1,astrology_add_money/1,astrology_sale/2,
		astrology_item_pos/1,astrology_expand_package/1,astrology_active/2,astrology_swap/3,astrology_mix/3,astrology_mix_all/3,
		compute_self_all_exp/3,check_star_level_up/4,astrology_lock/2,astrology_unlock/2,get_astrology_add_attribute/0,get_astrology_value_by_time/1
		,use_yuxingsui_add_money/1,get_astrology_add_attribute/1,astrology_money_init/1]).

-include("role_struct.hrl").
-include("item_struct.hrl").
%%
%% API Functions
%%



%%
%% Local Functions
%%


init(RoleId,Role_Level)->
	if Role_Level >= 50->
		%%AstrologyInfo = astrology_db:get_astrology_info_by_roleid(RoleId),
		AstrologyPackageInfo = astrology_db:get_astrology_package_info_by_roleid(RoleId),
		AARAInfo = astrology_db:get_astrology_add_role_attribute_info_by_roleid(RoleId),
		if
			AARAInfo =:= []->
				Bodynum = 0,
				BodyLists = [],
				astrology_db:save_astrology_add_role_attribute_info(RoleId, []);
			true ->
				Star_Use_Info = astrology_db:get_star_use_info_from_aarainfo(AARAInfo),
				Bodynum = length(Star_Use_Info),
				if
					Star_Use_Info =:= []->
						BodyLists = [];
					true->  
						get_astrology_fightingforce(),
						BodyLists = lists:filter(fun({BodySlot, BodyLevel, BodyStatus, BodyTid, BodyExp, BodyQuality})->
							  if
								  BodyTid =/= 0->
									  true;
								  true->
									  false
							  end
						 
						 end, Star_Use_Info)
				end
		end,
		    
		if
			AstrologyPackageInfo =:= []->
				Packnum = 12,
				PackLists = [],
				astrology_db:save_astrology_package_info(RoleId, [], Packnum);
			true ->
				PackageInfo = astrology_db:get_packageinfo_from_astrology_package_info(AstrologyPackageInfo),
				UnlockNum = astrology_db:get_unlocknum_from_astrology_package_info(AstrologyPackageInfo),
				Packnum = UnlockNum,
				if
					PackageInfo =:= []->
						PackLists = [];
					true->
						PackLists = lists:filter(fun({PackSlot, PackLevel, PackStatus, PackTid, PackExp, PackQuality})->
													  if
														  PackTid =/= 0->
															  true;
														  true->
															  false
													  end
												 end, PackageInfo)
				end
		end,
		ObjsLists = BodyLists ++ PackLists,
		if
			ObjsLists =:= []->
				nothing;
			true->
				Objs = lists:map(fun({ObjsSlot, ObjsLevel, ObjsStatus, ObjsTid, ObjsExp, ObjsQuality})->
										 astrology_packet:encode_ss(ObjsSlot, ObjsLevel, ObjsStatus, ObjsTid, ObjsExp, ObjsQuality)
								 end, ObjsLists),
				Msg1 = login_pb:encode_astrology_add_s2c(astrology_packet:encode_astrology_add_s2c(Objs)),
				role_pos_util:send_to_role_clinet(RoleId,Msg1)
		end,
		Msg = login_pb:encode_astrology_package_size_s2c(astrology_packet:encode_astrology_package_size_s2c(Bodynum,Packnum)),
		role_pos_util:send_to_role_clinet(RoleId,Msg),
		RoleInfo=role_db:get_role_info(RoleId),
		RoleLevel=role_db:get_level(RoleInfo),
	%% 	if
	%% 		RoleLevel < 50->
	%% 			nothing;
	%% 		true->
				{A,B,_}=now(),
				Now = list_to_integer(integer_to_list(A)++integer_to_list(B)),
				DbStarttime = astrology_db:get_starttime_from_astrology(RoleId),
				if
					DbStarttime=:=[]->
						astrology_db:save_astrology_add_money_time_info(RoleId,Now);
					true->
						%%调用开始计时的函数
	%% 					get_astrology_value_by_time(RoleId,Starttime)
						nothing
				end;
	true->
		nothing
end.
%% 	end.




astrology_init(RoleId)->
	AstrologyInfo = astrology_db:get_astrology_info_by_roleid(RoleId),
	{MSec,Sec,_}=timer_center:get_correct_now(),
	CurSec=MSec*1000000+Sec,
	if 
		AstrologyInfo =:= []->
			StarInfo = [],
			StarMoney = 50,
			Pos = 1,
			astrology_db:save_astrology_info(RoleId,StarInfo,StarMoney,Pos,CurSec);
		true->
			StarInfo = astrology_db:get_starinfo_from_astrology(AstrologyInfo),
			StarMoney = astrology_db:get_money_from_astrology(AstrologyInfo),
			Pos = astrology_db:get_pos_from_astrology(AstrologyInfo)
	end,
	if
		StarInfo =:= []->
			nothing;
		true->
			Objs = lists:map(fun({Solt,{Tid,_,_}})->
									 astrology_packet:encode_tss(Solt,Tid)
							  end, StarInfo),
		Msg = login_pb:encode_astrology_init_s2c(astrology_packet:encode_astrology_init_s2c(Objs)),
		role_pos_util:send_to_role_clinet(RoleId,Msg)
	end,
	Msg2 = login_pb:encode_astrology_money_and_pos_s2c(astrology_packet:encode_astrology_money_and_pos_s2c(StarMoney,Pos)),
	role_pos_util:send_to_role_clinet(RoleId,Msg2).
%%占星
astrology_action(RoleId,Position)->
	AstrologyInfo = astrology_db:get_astrology_info_by_roleid(RoleId),
	StarMoney = astrology_db:get_money_from_astrology(AstrologyInfo),
	StarInfo = astrology_db:get_starinfo_from_astrology(AstrologyInfo),
	if
		(StarMoney >= Position*10)->
			if
				(length(StarInfo)<16)->
					NewStarMoney = StarMoney - Position*10,
					[{Qua1,Num1},{Qua2,Num2},{Qua3,Num3},{Qua4,Num4},{Qua5,Num5}] = lists:nth(Position,?CHOSE_QUALITY),
					ANum = Num1 + Num2 + Num3 + Num4 + Num5,
					Num = random:uniform(ANum),
					if
						(Num > Num1) and (Num =< (Num1+Num2))->
							GetQua = Qua2;
						(Num > Num2) and (Num =< (Num1+Num2+Num3))->
							GetQua = Qua3;
						(Num > Num3) and (Num =< (Num1+Num2+Num3+Num4))->
							GetQua = Qua4;
						(Num > Num4) and (Num =< (Num1+Num2+Num3+Num4+Num5))->
							GetQua = Qua5;
						true->
							GetQua = Qua1
					end,
					if
						GetQua =:= 0->
							{Tid,Quality,Price} = {19000000,0,1000};
						true->
							All_GetQua_Tid = lists:nth(GetQua,?ALL_TID),
							GetNum = random:uniform(12),
							{Tid,Quality,Price} = lists:nth(GetNum,All_GetQua_Tid)
					end,
					[{Pos1,Pro1},{Pos2,Pro2},{Pos3,Pro3},{Pos4,Pro4},{Pos5,Pro5}] = lists:nth(Position,?CHANGE_POS),
					APro = Pro1 + Pro2 + Pro3 + Pro4 + Pro5,
					Pro = random:uniform(APro),
					if
						(Pro > Pro1) and (Pro =< (Pro1+Pro2))->
							NewPos = Pos2;
						(Pro > Pro2) and (Pro =< (Pro1+Pro2+Pro3))->
							NewPos = Pos3;
						(Pro > Pro3) and (Pro =< (Pro1+Pro2+Pro3+Pro4))->
							NewPos = Pos4;
						(Pro > Pro4) and (Pro =< (Pro1+Pro2+Pro3+Pro4+Pro5))->
							NewPos = Pos5;
						true->
							NewPos = Pos1
					end,
					if
						StarInfo =:= []->
							Slot = 1;
						true->
							FilterSolts = lists:filter(fun({OldSlot,_})->
															   case lists:keyfind(OldSlot+1, 1, StarInfo) of
																   false->
																	   true;
																   _->
																	   false
															   end
													   end,StarInfo),
							{N,_} = lists:nth(1,FilterSolts),
							Slot = N+1
					end,
					NewStarInfo = StarInfo++[{Slot,{Tid,Quality,Price}}],
					Obj = astrology_packet:encode_tss(Slot,Tid),
					astrology_db:save_astrology_info(RoleId,NewStarInfo,NewStarMoney,NewPos,0),
					Msg = login_pb:encode_astrology_action_s2c(astrology_packet:encode_astrology_action_s2c(Obj)),
					role_pos_util:send_to_role_clinet(RoleId,Msg),
					Msg2 = login_pb:encode_astrology_money_and_pos_s2c(astrology_packet:encode_astrology_money_and_pos_s2c(NewStarMoney,NewPos)),
					role_pos_util:send_to_role_clinet(RoleId,Msg2);
				true->
					Msg = login_pb:encode_astrology_error_s2c(astrology_packet:encode_astrology_error_s2c(?ASTROLOGY_FACE_FULL)),
					role_pos_util:send_to_role_clinet(RoleId,Msg)
			end;
		true->
			Msg = login_pb:encode_astrology_error_s2c(astrology_packet:encode_astrology_error_s2c(?ASTROLOGY_MONEY_NOT_ENOUGH)),
			role_pos_util:send_to_role_clinet(RoleId,Msg)
	end.


astrology_pickup_all(RoleId,Position)->
	AstrologyInfo = astrology_db:get_astrology_info_by_roleid(RoleId),
	StarMoney = astrology_db:get_money_from_astrology(AstrologyInfo),
	Pos = astrology_db:get_pos_from_astrology(AstrologyInfo),
	StarInfo = astrology_db:get_starinfo_from_astrology(AstrologyInfo),
	Filter_StarInfo = lists:filter(fun({Slot,{Tid,Quality,Price}})->
										   if
											   Tid =/= 19000000 ->
												   true;
											   true->
												   false
										   end
								   end, StarInfo),
	
	if
		Filter_StarInfo =/= []->	
			Slots = lists:map(fun({Slot,_})->
									  Slot
							  end, Filter_StarInfo),
			Objs = lists:map(fun(AddSlot)->
									 {_,{Tid,Quality,Price}} = lists:keyfind(AddSlot, 1, StarInfo),
									 {PackageInfo,UnlockNum,AddPackageInfo,Obj} = check_astrology_package(RoleId,Tid,Quality),
									 if
										 AddPackageInfo =:= []->
											 false;
										 true->
											 if
												 PackageInfo =:= []->
													 NewPackageInfo = PackageInfo++[AddPackageInfo];
												 true->
													 {AddPackSlot, _, _, _, _, _} = AddPackageInfo,
													 case lists:keyfind(AddPackSlot, 1, PackageInfo) of
														 false->
															 NewPackageInfo = PackageInfo++[AddPackageInfo];
														 _->
															 NewPackageInfo = lists:keyreplace(AddPackSlot, 1, PackageInfo, AddPackageInfo)
													 end
											 end,
											 astrology_db:save_astrology_package_info(RoleId,NewPackageInfo,UnlockNum),
											 Obj
									 end
							 end, Slots),
			LastValue = lists:last(Objs),
			if
				LastValue =:= false ->
					SendObjs = lists:filter(fun(OldObj)->
												  if
													  OldObj =/= false->
														  true;
													  true->
														  false
												  end
										  end, Objs),
					FenKai = length(SendObjs),
					{SendSlots,_} = lists:split(FenKai, Slots),
					ErrorMsg = login_pb:encode_astrology_error_s2c(astrology_packet:encode_astrology_error_s2c(?ASTROLOGY_PACKAGE_FULL)),
					role_pos_util:send_to_role_clinet(RoleId,ErrorMsg);
				true->
					SendObjs = Objs,
					SendSlots = Slots
			end,
			if
				SendObjs =:= []->
					nothing;
				true->
					NewStarInfo = lists:filter(fun({DelSlot,_})->
													   case lists:member(DelSlot, SendSlots) of
														   false ->
															   true;
														   _->
															   false
													   end
											   end, StarInfo),
					astrology_db:save_astrology_info(RoleId,NewStarInfo,StarMoney,Pos,0),
					ObjsMsg = login_pb:encode_astrology_add_s2c(astrology_packet:encode_astrology_add_s2c(SendObjs)),
					role_pos_util:send_to_role_clinet(RoleId,ObjsMsg),		
					Msg = login_pb:encode_astrology_pickup_all_s2c(astrology_packet:encode_astrology_pickup_all_s2c(SendSlots)),
					role_pos_util:send_to_role_clinet(RoleId,Msg)
			end;
		true->
			nothing
	end.
%%拾取
astrology_pickup(RoleId,Slot)->
	AstrologyInfo = astrology_db:get_astrology_info_by_roleid(RoleId),
	StarMoney = astrology_db:get_money_from_astrology(AstrologyInfo),
	Pos = astrology_db:get_pos_from_astrology(AstrologyInfo),
	StarInfo = astrology_db:get_starinfo_from_astrology(AstrologyInfo),
	{_,{Tid,Quality,Price}} = lists:keyfind(Slot, 1, StarInfo),
	{PackageInfo,UnlockNum,AddPackageInfo,Objs} = check_astrology_package(RoleId,Tid,Quality),
	if
		AddPackageInfo =/= []->
			NewStarInfo = StarInfo -- [{Slot,{Tid,Quality,Price}}],
			astrology_db:save_astrology_info(RoleId,NewStarInfo,StarMoney,Pos,0),
			{AddSlot, _, _, _, _, _} = AddPackageInfo,
			if
				PackageInfo =:= []->
					NewPackageInfo = PackageInfo++[AddPackageInfo];
				true->
					case lists:keyfind(AddSlot, 1, PackageInfo) of
						false->
							NewPackageInfo = PackageInfo++[AddPackageInfo];
						_->
							NewPackageInfo = lists:keyreplace(AddSlot, 1, PackageInfo, AddPackageInfo)
					end
			end,
			astrology_db:save_astrology_package_info(RoleId,NewPackageInfo,UnlockNum),
			Msg1 = login_pb:encode_astrology_add_s2c(astrology_packet:encode_astrology_add_s2c([Objs])),
			role_pos_util:send_to_role_clinet(RoleId,Msg1),
			Msg = login_pb:encode_astrology_pickup_s2c(astrology_packet:encode_astrology_pickup_s2c(Slot)),
			role_pos_util:send_to_role_clinet(RoleId,Msg);
		true->
			Msg = login_pb:encode_astrology_error_s2c(astrology_packet:encode_astrology_error_s2c(?ASTROLOGY_PACKAGE_FULL)),
			role_pos_util:send_to_role_clinet(RoleId,Msg)
	end.

check_astrology_package(RoleId,Tid,Quality)->
	AstrologyPackageInfo = astrology_db:get_astrology_package_info_by_roleid(RoleId),
	if
		AstrologyPackageInfo =:= []->
			PackageInfo = [],
			UnlockNum = 12,
			PackageSlot = 11,
			Level = 1,
			Status = ?STATUS_UNLOCK,
			Exp = 0,
			AddPackageInfo = {PackageSlot, Level, Status, Tid, Exp, Quality},
			Objs = astrology_packet:encode_ss(PackageSlot, Level, Status, Tid, Exp, Quality);
		true->
			PackageInfo = astrology_db:get_packageinfo_from_astrology_package_info(AstrologyPackageInfo),
			UnlockNum = astrology_db:get_unlocknum_from_astrology_package_info(AstrologyPackageInfo),
			FilterPackageInfo = lists:filter(fun({BodySlot, BodyLevel, BodyStatus, BodyTid, BodyExp, BodyQuality})->
													 if
														 BodyTid =:= 0->
															 true;
														 true->
															 false
													 end
											 end, PackageInfo),
			if
				FilterPackageInfo =:= []->
					if
						length(PackageInfo) < UnlockNum ->
							PackageSlot = length(PackageInfo)+10+1,
							Level = 1,
							Status = ?STATUS_UNLOCK,
							Exp = 0,
							AddPackageInfo = {PackageSlot, Level, Status, Tid, Exp, Quality},
							Objs = astrology_packet:encode_ss(PackageSlot, Level, Status, Tid, Exp, Quality);
						true->
							AddPackageInfo = [],
							Objs = []
					end;
				true->
					{BodySlot, BodyLevel, BodyStatus, BodyTid, BodyExp, BodyQuality} = lists:nth(1, FilterPackageInfo),
					PackageSlot = BodySlot,
					Level = 1,
					Status = ?STATUS_UNLOCK,
					Exp = 0,
					AddPackageInfo = {PackageSlot, Level, Status, Tid, Exp, Quality},
					Objs = astrology_packet:encode_ss(PackageSlot, Level, Status, Tid, Exp, Quality)
			end
	end,
	{PackageInfo,UnlockNum,AddPackageInfo,Objs}.


%%一键卖出
astrology_sale_all(RoleId)->
	AstrologyInfo = astrology_db:get_astrology_info_by_roleid(RoleId),
	StarMoney = astrology_db:get_money_from_astrology(AstrologyInfo),
	Pos = astrology_db:get_pos_from_astrology(AstrologyInfo),
	StarInfo = astrology_db:get_starinfo_from_astrology(AstrologyInfo),
	Filter_StarInfo = lists:filter(fun({Slot,{Tid,Quality,Price}})->
										   if
											   Tid =:= 19000000 ->
												   true;
											   true->
												   false
										   end
								   end, StarInfo),
	NewStarInfo = StarInfo -- Filter_StarInfo,
	Slots = lists:map(fun({Slot,_})->
							  Slot
					  end, Filter_StarInfo),
	Add_money = length(Slots)*1000,
	role_op:money_change(?MONEY_BOUND_SILVER,Add_money,astrology_sale_all),
	astrology_db:save_astrology_info(RoleId,NewStarInfo,StarMoney,Pos,0),
	Msg = login_pb:encode_astrology_sale_all_s2c(astrology_packet:encode_astrology_sale_all_s2c(Slots)),
	role_pos_util:send_to_role_clinet(RoleId,Msg).


astrology_sale(RoleId,Slot)->
	AstrologyInfo = astrology_db:get_astrology_info_by_roleid(RoleId),
	StarMoney = astrology_db:get_money_from_astrology(AstrologyInfo),
	Pos = astrology_db:get_pos_from_astrology(AstrologyInfo),
	StarInfo = astrology_db:get_starinfo_from_astrology(AstrologyInfo),
	case lists:keyfind(Slot, 1, StarInfo) of
		{_,{Tid,Quality,Price}}->
			NewStarInfo = StarInfo -- [{Slot,{Tid,Quality,Price}}],
			astrology_db:save_astrology_info(RoleId,NewStarInfo,StarMoney,Pos,0),
			role_op:money_change(?MONEY_BOUND_SILVER,Price,astrology_sale_all),
			Msg = login_pb:encode_astrology_sale_s2c(astrology_packet:encode_astrology_sale_s2c(Slot)),
			role_pos_util:send_to_role_clinet(RoleId,Msg);
		_->
			nohitng
	end.

%%充值补充星魂值
astrology_add_money(RoleId)->
	NeedGold = 100,
	case role_op:check_money(?MONEY_GOLD,NeedGold) of
		true->
			role_op:money_change(?MONEY_GOLD,-NeedGold,astrology_add_Money),
			AstrologyInfo = astrology_db:get_astrology_info_by_roleid(RoleId),
			StarMoney = astrology_db:get_money_from_astrology(AstrologyInfo),
			Pos = astrology_db:get_pos_from_astrology(AstrologyInfo),
			StarInfo = astrology_db:get_starinfo_from_astrology(AstrologyInfo),
			NewStarMoney = StarMoney+100,	
			astrology_db:save_astrology_info(RoleId,StarInfo,NewStarMoney,Pos,0),
			Msg = login_pb:encode_astrology_money_and_pos_s2c(astrology_packet:encode_astrology_money_and_pos_s2c(NewStarMoney,Pos)),
			role_pos_util:send_to_role_clinet(RoleId,Msg);
		_->	
			slogger:msg("astrology_add_Money no money ~p ~n",[get(roleid)])
	end.
	
astrology_item_pos(RoleId)->
	FreeCiShenShiCount = package_op:get_counts_by_template_in_package(19010550),
	BondCiShenShiCount = package_op:get_counts_by_template_in_package(19010551),
	SumCiShenShiCount = FreeCiShenShiCount+BondCiShenShiCount,
	if
		SumCiShenShiCount >= 1 ->		
			FreeItemIds = items_op:get_items_by_template(19010550),
			BondItemIds = items_op:get_items_by_template(19010551),
			SumItemIds = BondItemIds ++ FreeItemIds,
			role_op:consume_items_by_ids_count(1,SumItemIds),
			AstrologyInfo = astrology_db:get_astrology_info_by_roleid(RoleId),
			StarMoney = astrology_db:get_money_from_astrology(AstrologyInfo),
			StarInfo = astrology_db:get_starinfo_from_astrology(AstrologyInfo),
			Pos = 4,
			astrology_db:save_astrology_info(RoleId,StarInfo,StarMoney,Pos,0),
			Msg = login_pb:encode_astrology_money_and_pos_s2c(astrology_packet:encode_astrology_money_and_pos_s2c(StarMoney,Pos)),
			role_pos_util:send_to_role_clinet(RoleId,Msg);
		true->
			nothing
	end.

astrology_expand_package(RoleId)->
	NeedGold = 188,
	case role_op:check_money(?MONEY_GOLD,NeedGold) of
		true->
			role_op:money_change(?MONEY_GOLD,-NeedGold,astrology_add_Money),
			AstrologyPackageInfo = astrology_db:get_astrology_package_info_by_roleid(RoleId),
			PackageInfo = astrology_db:get_packageinfo_from_astrology_package_info(AstrologyPackageInfo),
			UnlockNum = astrology_db:get_unlocknum_from_astrology_package_info(AstrologyPackageInfo),
			NewUnlockNum = UnlockNum+6,	
			astrology_db:save_astrology_package_info(RoleId, PackageInfo, NewUnlockNum),
			AARAInfo = astrology_db:get_astrology_add_role_attribute_info_by_roleid(RoleId),
			if
				AARAInfo =:= []->
					Bodynum = 0;
				true->
					Star_Use_Info = astrology_db:get_star_use_info_from_aarainfo(AARAInfo),
					Bodynum = length(Star_Use_Info)
			end,
			Packnum = NewUnlockNum,
			Msg = login_pb:encode_astrology_package_size_s2c(astrology_packet:encode_astrology_package_size_s2c(Bodynum,Packnum)),
			role_pos_util:send_to_role_clinet(RoleId,Msg);
		_->	
			slogger:msg("astrology_add_Money no money ~p ~n",[get(roleid)])
	end.

astrology_active(RoleId,Slot)->
	{NeedLevel,{NeedBondTmpId,NeedFreeTmpId},NeedCount,NeedMoney} = lists:nth(Slot,?ALL_OPEN_BODY_STAR),
	RoleInfo = get(creature_info),
	RoleLevel = get_level_from_roleinfo(RoleInfo),
	if
		RoleLevel >= NeedLevel ->
			case role_op:check_money(?MONEY_BOUND_SILVER,NeedMoney) of
				true->
					role_op:money_change(?MONEY_BOUND_SILVER,-NeedMoney,astrology_add_Money),
					FreeItemCount = package_op:get_counts_by_template_in_package(NeedFreeTmpId),
					BondItemCount = package_op:get_counts_by_template_in_package(NeedBondTmpId),
					SumItemCount = FreeItemCount+BondItemCount,
					if
						SumItemCount >= NeedCount ->		
							FreeItemIds = items_op:get_items_by_template(NeedFreeTmpId),
							BondItemIds = items_op:get_items_by_template(NeedBondTmpId),
							SumItemIds = BondItemIds ++ FreeItemIds,
							role_op:consume_items_by_ids_count(NeedCount,SumItemIds),
							AARAInfo = astrology_db:get_astrology_add_role_attribute_info_by_roleid(RoleId),
							if
								AARAInfo =:= []->
									Bodynum = 1,
									Star_Use_Info = [];
								true->
									Star_Use_Info = astrology_db:get_star_use_info_from_aarainfo(AARAInfo),
									Bodynum = length(Star_Use_Info)+1
							end,
							SeaveStarInfo = {Slot, 0, ?STATUS_UNLOCK, 0, 0, 0},
							New_Star_Use_Info = Star_Use_Info++[{Slot, 0, ?STATUS_UNLOCK, 0, 0, 0}],		
							astrology_db:save_astrology_add_role_attribute_info(RoleId, New_Star_Use_Info),
							AstrologyPackageInfo = astrology_db:get_astrology_package_info_by_roleid(RoleId),
							UnlockNum = astrology_db:get_unlocknum_from_astrology_package_info(AstrologyPackageInfo),
							Packnum = UnlockNum,
							Msg = login_pb:encode_astrology_package_size_s2c(astrology_packet:encode_astrology_package_size_s2c(Bodynum,Packnum)),
							role_pos_util:send_to_role_clinet(RoleId,Msg);
						true->
							nothing
					end;
				_->	
					slogger:msg("astrology_add_Money no money ~p ~n",[get(roleid)])
			end;
		true->
			nothing
	end.
%%移动星座
astrology_swap(RoleId,Desslot,Srcslot)->
	AstrologyPackageInfo = astrology_db:get_astrology_package_info_by_roleid(RoleId),
	PackageInfo = astrology_db:get_packageinfo_from_astrology_package_info(AstrologyPackageInfo),
	UnlockNum = astrology_db:get_unlocknum_from_astrology_package_info(AstrologyPackageInfo),
	AARAInfo = astrology_db:get_astrology_add_role_attribute_info_by_roleid(RoleId),
	Star_Use_Info = astrology_db:get_star_use_info_from_aarainfo(AARAInfo),
	if
		Desslot < 11 ->
			
			if
				Srcslot < 11 ->
					{_, SrcLevel, SrcStatus, SrcTid, SrcExp, SrcQuality} = lists:keyfind(Srcslot, 1, Star_Use_Info),
					NewStar_Use_Info = lists:keyreplace(Srcslot, 1, Star_Use_Info, {Srcslot, 0, ?STATUS_UNLOCK, 0, 0, 0}),
					astrology_db:save_astrology_add_role_attribute_info(RoleId, NewStar_Use_Info);
				true->
					get_astrology_fightingforce(Desslot,Srcslot),
					{_, SrcLevel, SrcStatus, SrcTid, SrcExp, SrcQuality} = lists:keyfind(Srcslot, 1, PackageInfo),
					NewPackageInfo = lists:keyreplace(Srcslot, 1, PackageInfo, {Srcslot, 0, ?STATUS_UNLOCK, 0, 0, 0}),
					astrology_db:save_astrology_package_info(RoleId, NewPackageInfo, UnlockNum)
			end,
			
			Will_Change_AARAInfo = astrology_db:get_astrology_add_role_attribute_info_by_roleid(RoleId),
			Will_Change_Star_Use_Info = astrology_db:get_star_use_info_from_aarainfo(Will_Change_AARAInfo),
			case lists:keyfind(Desslot, 1, Will_Change_Star_Use_Info) of
				false->
					NewNewStar_Use_Info = Will_Change_Star_Use_Info ++ [{Desslot,SrcLevel, SrcStatus, SrcTid, SrcExp, SrcQuality}];
				_->
					NewNewStar_Use_Info = lists:keyreplace(Desslot, 1, Will_Change_Star_Use_Info, {Desslot,SrcLevel, SrcStatus, SrcTid, SrcExp, SrcQuality})
			end,
			astrology_db:save_astrology_add_role_attribute_info(RoleId, NewNewStar_Use_Info),
			role_fighting_force:hook_on_change_role_fight_force();
		true->
			if
				Srcslot < 11 ->
					get_astrology_fightingforce(Desslot,Srcslot),
					{_, SrcLevel, SrcStatus, SrcTid, SrcExp, SrcQuality} = lists:keyfind(Srcslot, 1, Star_Use_Info),
					NewStar_Use_Info = lists:keyreplace(Srcslot, 1, Star_Use_Info, {Srcslot, 0, ?STATUS_UNLOCK, 0, 0, 0}),
					astrology_db:save_astrology_add_role_attribute_info(RoleId, NewStar_Use_Info);
				true->
					{_, SrcLevel, SrcStatus, SrcTid, SrcExp, SrcQuality} = lists:keyfind(Srcslot, 1, PackageInfo),
					NewPackageInfo = lists:keyreplace(Srcslot, 1, PackageInfo, {Srcslot, 0, ?STATUS_UNLOCK, 0, 0, 0}),
					astrology_db:save_astrology_package_info(RoleId, NewPackageInfo, UnlockNum)
			end,
			
			Will_Change_AstrologyPackageInfo = astrology_db:get_astrology_package_info_by_roleid(RoleId),
			Will_change_PackageInfo = astrology_db:get_packageinfo_from_astrology_package_info(Will_Change_AstrologyPackageInfo),
			case lists:keyfind(Desslot, 1, Will_change_PackageInfo) of
				false->
					NewNewPackageInfo = Will_change_PackageInfo ++ [{Desslot, SrcLevel, SrcStatus, SrcTid, SrcExp, SrcQuality}];
				_->
					NewNewPackageInfo = lists:keyreplace(Desslot, 1, Will_change_PackageInfo, {Desslot, SrcLevel, SrcStatus, SrcTid, SrcExp, SrcQuality})
			end,
			
			astrology_db:save_astrology_package_info(RoleId, NewNewPackageInfo, UnlockNum),
			role_fighting_force:hook_on_change_role_fight_force()
	end,
	
	DelStarMsg = login_pb:encode_astrology_delete_s2c(astrology_packet:encode_astrology_delete_s2c([Srcslot])),
	role_pos_util:send_to_role_clinet(RoleId,DelStarMsg),
	Msg = login_pb:encode_astrology_update_s2c(astrology_packet:encode_astrology_update_s2c(astrology_packet:encode_ss(Desslot, SrcLevel, SrcStatus, SrcTid, SrcExp, SrcQuality))),
	role_pos_util:send_to_role_clinet(RoleId,Msg),
	get_astrology_fightingforce().
%%合成
astrology_mix(RoleId,To_slot,From_slot)->
	AstrologyPackageInfo = astrology_db:get_astrology_package_info_by_roleid(RoleId),
	PackageInfo = astrology_db:get_packageinfo_from_astrology_package_info(AstrologyPackageInfo),
	UnlockNum = astrology_db:get_unlocknum_from_astrology_package_info(AstrologyPackageInfo),
	AARAInfo = astrology_db:get_astrology_add_role_attribute_info_by_roleid(RoleId),
	Star_Use_Info = astrology_db:get_star_use_info_from_aarainfo(AARAInfo),
	All_Info = Star_Use_Info ++ PackageInfo,
	{_, FromLevel, FromStatus, FromTid, FromExp, FromQuality} = lists:keyfind(From_slot, 1, All_Info),
	{_, ToLevel, ToStatus, ToTid, ToExp, ToQuality} = lists:keyfind(To_slot, 1,  All_Info),
	if
		FromStatus =:= ?STATUS_UNLOCK ->			
			if
				To_slot < 11 ->
					NeedExp = lists:nth((ToLevel+1), lists:nth(ToQuality, ?ALL_EXP)) - lists:nth((ToLevel), lists:nth(ToQuality, ?ALL_EXP)),
					if
						From_slot < 11 ->
							FromSelfExp = compute_self_all_exp(FromLevel,FromExp,FromQuality),
							AllExp = FromSelfExp + ToExp,
							{NewLevel,NewExp} = check_star_level_up(ToLevel,NeedExp,AllExp,ToQuality),
							NewStar_Use_Info = lists:keyreplace(From_slot, 1, Star_Use_Info, {From_slot, 0, ?STATUS_UNLOCK, 0, 0, 0}),
							astrology_db:save_astrology_add_role_attribute_info(RoleId, NewStar_Use_Info);
							
						true->
							FromSelfExp = compute_self_all_exp(FromLevel,FromExp,FromQuality),
							AllExp = FromSelfExp + ToExp,
							{NewLevel,NewExp} = check_star_level_up(ToLevel,NeedExp,AllExp,ToQuality),
							NewPackageInfo = lists:keyreplace(From_slot, 1, PackageInfo, {From_slot, 0, ?STATUS_UNLOCK, 0, 0, 0}),
							astrology_db:save_astrology_package_info(RoleId, NewPackageInfo, UnlockNum)
					end,
					Will_Change_AARAInfo = astrology_db:get_astrology_add_role_attribute_info_by_roleid(RoleId),
					Will_Change_Star_Use_Info = astrology_db:get_star_use_info_from_aarainfo(Will_Change_AARAInfo),
					NewNewStar_Use_Info = lists:keyreplace(To_slot, 1, Will_Change_Star_Use_Info, {To_slot, NewLevel, ToStatus, ToTid, NewExp, ToQuality}),
					astrology_db:save_astrology_add_role_attribute_info(RoleId, NewNewStar_Use_Info);
					
				
				true->
					NeedExp = lists:nth((ToLevel+1), lists:nth(ToQuality, ?ALL_EXP)) - lists:nth((ToLevel), lists:nth(ToQuality, ?ALL_EXP)),
					if
						From_slot < 11 ->
							FromSelfExp = compute_self_all_exp(FromLevel,FromExp,FromQuality),
							AllExp = FromSelfExp + ToExp,
							{NewLevel,NewExp} = check_star_level_up(ToLevel,NeedExp,AllExp,ToQuality),
							NewStar_Use_Info = lists:keyreplace(From_slot, 1, Star_Use_Info, {From_slot, 0, ?STATUS_UNLOCK, 0, 0, 0}),
							astrology_db:save_astrology_add_role_attribute_info(RoleId, NewStar_Use_Info);
						true->
							FromSelfExp = compute_self_all_exp(FromLevel,FromExp,FromQuality),
							AllExp = FromSelfExp + ToExp,
							{NewLevel,NewExp} = check_star_level_up(ToLevel,NeedExp,AllExp,ToQuality),
							NewPackageInfo = lists:keyreplace(From_slot, 1, PackageInfo, {From_slot, 0, ?STATUS_UNLOCK, 0, 0, 0}),
							astrology_db:save_astrology_package_info(RoleId, NewPackageInfo, UnlockNum)
					end,
					Will_Change_AstrologyPackageInfo = astrology_db:get_astrology_package_info_by_roleid(RoleId),
					Will_change_PackageInfo = astrology_db:get_packageinfo_from_astrology_package_info(Will_Change_AstrologyPackageInfo),
					NewNewPackageInfo = lists:keyreplace(To_slot, 1, Will_change_PackageInfo, {To_slot, NewLevel, ToStatus, ToTid, NewExp, ToQuality}),
					astrology_db:save_astrology_package_info(RoleId, NewNewPackageInfo, UnlockNum)
			end,
			DelStarMsg = login_pb:encode_astrology_delete_s2c(astrology_packet:encode_astrology_delete_s2c([From_slot])),
			role_pos_util:send_to_role_clinet(RoleId,DelStarMsg),
			Msg = login_pb:encode_astrology_update_s2c(astrology_packet:encode_astrology_update_s2c(astrology_packet:encode_ss(To_slot, NewLevel, ToStatus, ToTid, NewExp, ToQuality))),
			role_pos_util:send_to_role_clinet(RoleId,Msg);
		true->
			Msg = login_pb:encode_astrology_error_s2c(astrology_packet:encode_astrology_error_s2c(?STAR_CAN_NOT_MIX)),
			role_pos_util:send_to_role_clinet(RoleId,Msg)
	end.

compute_self_all_exp(Level,Exp,Quality)->
	SelfExp = lists:nth(Quality, ?ALL_SELF_EXP),
	if
		Level =:= 1 ->
			AllExp = 0 + Exp + SelfExp;
		true->
			LevelExp = lists:nth(Level, lists:nth(Quality, ?ALL_EXP)),
			AllExp = LevelExp + Exp + SelfExp
	end,
	AllExp.
	
check_star_level_up(Level,NeedExp,AllExp,Quality) when(AllExp >= NeedExp)->
	NewLevel = Level +1,
	NewAllExp = AllExp -NeedExp,
	NewNeedExp = lists:nth((NewLevel+1), lists:nth(Quality, ?ALL_EXP)) - lists:nth(NewLevel, lists:nth(Quality, ?ALL_EXP)),
	check_star_level_up(NewLevel,NewNeedExp,NewAllExp,Quality);
check_star_level_up(Level,NeedExp,AllExp,Quality)->
	NewLevel = Level,
	NewExp = AllExp,
	{NewLevel,NewExp}.
%%一键合成	
astrology_mix_all(RoleId,To_slot,From_slot)->
	AstrologyPackageInfo = astrology_db:get_astrology_package_info_by_roleid(RoleId),
	PackageInfo = astrology_db:get_packageinfo_from_astrology_package_info(AstrologyPackageInfo),
	UnlockNum = astrology_db:get_unlocknum_from_astrology_package_info(AstrologyPackageInfo),
	CanMixQualityLists = lists:map(fun({_,_,_,_,_,Quality})->
										   Quality
								   end,PackageInfo),
	CanMixQualityNum = lists:max(CanMixQualityLists),
	CanMixLists = lists:filter(fun({OldSlot, OldLevel, OldStatus, OldTid, OldExp, OldQuality})->
									   if
										   (OldTid =/= 0)and(OldQuality =:= CanMixQualityNum)->
											   true;
										   true->
											   false
									   end
							   end, PackageInfo),
	CanMixSlotLists = lists:map(fun({Slot,_,_,_,_,_})->
										Slot
								end,CanMixLists),
	CanMixSlotNum = lists:min(CanMixSlotLists),
	ToSlot = CanMixSlotNum,
	{_, ToLevel, ToStatus, ToTid, ToExp, ToQuality} = lists:keyfind(ToSlot, 1, CanMixLists),
	NeedExp = lists:nth((ToLevel+1), lists:nth(ToQuality, ?ALL_EXP)) - lists:nth((ToLevel), lists:nth(ToQuality, ?ALL_EXP)),
	BeMixList = PackageInfo -- [{ToSlot, ToLevel, ToStatus, ToTid, ToExp, ToQuality}],
	AddExpLists = lists:filter(fun({BeMixSlot, BeMixLevel, BeMixStatus, BeMixTid, BeMixExp, BeMixQuality})->
									   if
										   (BeMixStatus =:= ?STATUS_UNLOCK)and(BeMixTid =/= 0) ->
											   true;
										   true->
											   false
									   end
							   end,BeMixList),
	FromExplists = lists:map(fun({_, FromLevel, FromStatus, FromTid, FromExp, FromQuality})->
									 Self_All_Exp = compute_self_all_exp(FromLevel,FromExp,FromQuality)
							 end, AddExpLists),
	FromSlotLists = lists:map(fun({FromSlot,_,_,_,_,_})->
									  FromSlot
							  end, AddExpLists),
	UpdateLists = lists:map(fun({FromSlot, _, _, _, _,_})->
									{FromSlot,0,?STATUS_UNLOCK,0,0,0}
							end, AddExpLists),
	NewPackageInfo = (PackageInfo -- AddExpLists)++ UpdateLists,
	AllExp = lists:sum(FromExplists)+ToExp,
	{NewLevel,NewExp} = check_star_level_up(ToLevel,NeedExp,AllExp,ToQuality),
	SavePackageInfo = lists:keyreplace(ToSlot, 1, NewPackageInfo, {ToSlot, NewLevel, ToStatus, ToTid, NewExp, ToQuality}),
	astrology_db:save_astrology_package_info(RoleId, SavePackageInfo, UnlockNum),
	DelStarMsg = login_pb:encode_astrology_delete_s2c(astrology_packet:encode_astrology_delete_s2c(FromSlotLists)),
	role_pos_util:send_to_role_clinet(RoleId,DelStarMsg),
	Msg = login_pb:encode_astrology_update_s2c(astrology_packet:encode_astrology_update_s2c(astrology_packet:encode_ss(ToSlot, NewLevel, ToStatus, ToTid, NewExp, ToQuality))),
	role_pos_util:send_to_role_clinet(RoleId,Msg).
	

astrology_lock(RoleId,Slot)->
	AstrologyPackageInfo = astrology_db:get_astrology_package_info_by_roleid(RoleId),
	PackageInfo = astrology_db:get_packageinfo_from_astrology_package_info(AstrologyPackageInfo),
	UnlockNum = astrology_db:get_unlocknum_from_astrology_package_info(AstrologyPackageInfo),
	AARAInfo = astrology_db:get_astrology_add_role_attribute_info_by_roleid(RoleId),
	Star_Use_Info = astrology_db:get_star_use_info_from_aarainfo(AARAInfo),
	if
		Slot < 11 ->
			{_, Level, Status, Tid, Exp, Quality} = lists:keyfind(Slot, 1, Star_Use_Info),
			NewStatus = ?STATUS_LOCK,
			NewStar_Use_Info = lists:keyreplace(Slot, 1, Star_Use_Info, {Slot, Level, NewStatus, Tid, Exp, Quality}),
			astrology_db:save_astrology_add_role_attribute_info(RoleId, NewStar_Use_Info);
		true->
			{_, Level, Status, Tid, Exp, Quality} = lists:keyfind(Slot, 1, PackageInfo),
			NewStatus = ?STATUS_LOCK,
			NewPackageInfo = lists:keyreplace(Slot, 1, PackageInfo, {Slot, Level, NewStatus, Tid, Exp, Quality}),
			astrology_db:save_astrology_package_info(RoleId, NewPackageInfo, UnlockNum)
	end,
	Msg = login_pb:encode_astrology_update_s2c(astrology_packet:encode_astrology_update_s2c(astrology_packet:encode_ss(Slot, Level, NewStatus, Tid, Exp, Quality))),
	role_pos_util:send_to_role_clinet(RoleId,Msg),
	LockMsg = login_pb:encode_astrology_error_s2c(astrology_packet:encode_astrology_error_s2c(?STAR_HAVE_LOCKED)),
	role_pos_util:send_to_role_clinet(RoleId,LockMsg).


astrology_unlock(RoleId,Slot)->
	AstrologyPackageInfo = astrology_db:get_astrology_package_info_by_roleid(RoleId),
	PackageInfo = astrology_db:get_packageinfo_from_astrology_package_info(AstrologyPackageInfo),
	UnlockNum = astrology_db:get_unlocknum_from_astrology_package_info(AstrologyPackageInfo),
	AARAInfo = astrology_db:get_astrology_add_role_attribute_info_by_roleid(RoleId),
	Star_Use_Info = astrology_db:get_star_use_info_from_aarainfo(AARAInfo),
	if
		Slot < 11 ->
			{_, Level, Status, Tid, Exp, Quality} = lists:keyfind(Slot, 1, Star_Use_Info),
			NewStatus = ?STATUS_UNLOCK,
			NewStar_Use_Info = lists:keyreplace(Slot, 1, Star_Use_Info, {Slot, Level, NewStatus, Tid, Exp, Quality}),
			astrology_db:save_astrology_add_role_attribute_info(RoleId, NewStar_Use_Info);
		true ->
			{_, Level, Status, Tid, Exp, Quality} = lists:keyfind(Slot, 1, PackageInfo),
			NewStatus = ?STATUS_UNLOCK,
			NewPackageInfo = lists:keyreplace(Slot, 1, PackageInfo, {Slot, Level, NewStatus, Tid, Exp, Quality}),
			astrology_db:save_astrology_package_info(RoleId, NewPackageInfo, UnlockNum)
	end,
	Msg = login_pb:encode_astrology_update_s2c(astrology_packet:encode_astrology_update_s2c(astrology_packet:encode_ss(Slot, Level, NewStatus, Tid, Exp, Quality))),
	role_pos_util:send_to_role_clinet(RoleId,Msg).

%返回一个列表（key,value)
get_astrology_add_attribute(AARAInfo)->
	A=[AARAInfo],
	Id_Level = lists:foldl(fun(An,Acc)->{_,Level,_,Id,_,_}=An,
		EffectId = list_to_integer(integer_to_list(Id)++integer_to_list(Level)),
		case lists:keyfind(EffectId,1,?ALL_EFFECT) of
		    false -> Acc;
		    _->{_,Key_Value}=lists:keyfind(EffectId,1,?ALL_EFFECT),
			Key_Value++Acc		
		end
    end,[],A),
	Id_Level.

%返回一个列表（key,value)
get_astrology_add_attribute()->
	AARAInfo = astrology_db:get_astrology_add_role_attribute_info_by_roleid(get(roleid)),
	if AARAInfo =:=[]->
		   [];
	   true->
	{_,_,A}=AARAInfo,
	Id_Level=lists:foldl(fun(An,Acc)->{_,Level,_,Id,_,_}=An,
		EffectId = list_to_integer(integer_to_list(Id)++integer_to_list(Level)),
		case lists:keyfind(EffectId,1,?ALL_EFFECT) of
		    false -> Acc;
		    _->{_,Key_Value}=lists:keyfind(EffectId,1,?ALL_EFFECT),
			Key_Value++Acc		
		end
    end,[],A),
	Id_Level
	end.
%得到最终战力返回值  
get_astrology_fightingforce()-> 
    Role_astrology_list=get_astrology_add_attribute(),
	RoleClass=get_class_from_roleinfo(get(creature_info)),
    if 
	Role_astrology_list =:= []->
		io:format("Rev   ~p~n", [Role_astrology_list]),
                            ReV = 0;				
	true->
		ReV=lists:foldl(fun(An,Acc)->{Key,Value}=An,
				case Key of
					hpmax->
						Value * 0.2 + Acc; 
					magicpower->
						Value * 2 + Acc;
					rangepower->
						Value * 2 + Acc;
                    meleepower->
						Value * 2 + Acc;
                    magicdefense->
                        Value * 2 + Acc;
                    rangedefense->
                        Value * 2 + Acc;
                    meleedefense->
						Value * 2 + Acc;
                    hitrate->
                        Value * 2 + Acc;
                    dodge->
                        Value * 2 + Acc;
                    criticalrate->
                        Value * 2 + Acc;
                    criticaldestroyrate->%criticaldamage
						Value * 2 + Acc;
                    toughness->
					    Value * 2 + Acc;
					_->
						0
				
				end
				
			end,0, Role_astrology_list)
	
		end,
       ReV1=trunc(ReV),
       ValMsg = login_pb:encode_astrology_update_value_s2c(astrology_packet:encode_astrology_update_value_s2c(ReV1)),
       role_pos_util:send_to_role_clinet(get(roleid),ValMsg).
			
%得到最终战力返回值同时改变人物属性值         %目标点         %源点
get_astrology_fightingforce(Desslot,Srcslot)-> 
	AARAInfo = astrology_db:get_astrology_add_role_attribute_info_by_roleid(get(roleid)),
	AstrologyPackageInfo = astrology_db:get_astrology_package_info_by_roleid(get(roleid)),
	
	if
		Srcslot<11->
			StarInfo = astrology_db:get_starinfo_from_astrology(AARAInfo);
		true->
			StarInfo = astrology_db:get_packageinfo_from_astrology_package_info(AstrologyPackageInfo)
	end,
	AARAInfo1 = lists:keyfind(Srcslot, 1, StarInfo),
	Role_astrology_list = get_astrology_add_attribute(AARAInfo1),
	[{Value,AttributeValue}|_]=Role_astrology_list,
	RoleClass=get_class_from_roleinfo(get(creature_info)),
    if 
		Role_astrology_list =:= []->
			nothing;				
		true->
			case Value of
				hpmax->
					Hpmax = get_hpmax_from_roleinfo(get(creature_info)),
					if
						Desslot < 11->
							NewHpmax = Hpmax + AttributeValue;
						true->
							NewHpmax = Hpmax - AttributeValue
					end,
					NewInfo = set_hpmax_to_roleinfo(get(creature_info),NewHpmax),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:only_self_update([{hpmax,NewHpmax}]);
				magicpower->
					
					if 
						RoleClass =:= 1->
						Magicpower = get_power_from_roleinfo(get(creature_info)),
						if
							Desslot < 11->
								NewMagicpower = Magicpower + AttributeValue;
							true->
								NewMagicpower = Magicpower - AttributeValue
						end,
						NewInfo = set_power_to_roleinfo(get(creature_info),NewMagicpower),
						put(creature_info,NewInfo),
						role_op:update_role_info(get(roleid),NewInfo),
						role_op:only_self_update([{power,NewMagicpower}]);
						true->
							nothing
					end;
				rangepower->
					if
						RoleClass =:= 2->
						Rangepower = get_power_from_roleinfo(get(creature_info)),
						if
							Desslot < 11->
								NewRangepower = Rangepower + AttributeValue;
							true->
								NewRangepower = Rangepower - AttributeValue
						end,
						NewInfo = set_power_to_roleinfo(get(creature_info),NewRangepower),
						put(creature_info,NewInfo),
						role_op:update_role_info(get(roleid),NewInfo),
						role_op:only_self_update([{power,NewRangepower}]);
						true->
							nothing
					end;
                meleepower->
					if
						RoleClass =:= 3->
						Meleepower = get_power_from_roleinfo(get(creature_info)),
						if
							Desslot < 11->
								NewMeleepower = Meleepower + AttributeValue;
							true->
								NewMeleepower = Meleepower - AttributeValue
						end,
						NewInfo = set_power_to_roleinfo(get(creature_info),NewMeleepower),
						put(creature_info,NewInfo),
						role_op:update_role_info(get(roleid),NewInfo),
						role_op:only_self_update([{power,NewMeleepower}]);
						true->
							nothing
					end;
                magicdefense->
					{Magicdefense,Rangedefense,Meleedefense} = get_defenses_from_roleinfo(get(creature_info)),
					if
						Desslot < 11->
							NewMagicdefense = Magicdefense + AttributeValue;
						true->
							NewMagicdefense = Magicdefense - AttributeValue
					end,
					NewInfo = set_defenses_to_roleinfo(get(creature_info), {NewMagicdefense,Rangedefense,Meleedefense}),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:only_self_update([{magicdefense,NewMagicdefense}]);
					
                rangedefense->
					{Magicdefense,Rangedefense,Meleedefense} = get_defenses_from_roleinfo(get(creature_info)),
					if
						Desslot < 11->
							NewRangedefense = Rangedefense + AttributeValue;
						true->
							NewRangedefense = Rangedefense - AttributeValue
					end,
					NewInfo = set_defenses_to_roleinfo(get(creature_info), {Magicdefense,NewRangedefense,Meleedefense}),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:only_self_update([{rangedefense,NewRangedefense}]);
					
                meleedefense->
					{Magicdefense,Rangedefense,Meleedefense} = get_defenses_from_roleinfo(get(creature_info)),
					if
						Desslot < 11->
							NewMeleedefense = Meleedefense + AttributeValue;
						true->
							NewMeleedefense = Meleedefense - AttributeValue
					end,
					NewInfo = set_defenses_to_roleinfo(get(creature_info), {Magicdefense,Rangedefense,NewMeleedefense}),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:only_self_update([{meleedefense,NewMeleedefense}]);
					
                hitrate->
					Hitrate=get_hitrate_from_roleinfo(get(creature_info)),
					if
						Desslot < 11->
							NewHitrate = Hitrate + AttributeValue;
						true->
							NewHitrate = Hitrate - AttributeValue
					end,
					NewInfo = set_hitrate_to_roleinfo(get(creature_info), NewHitrate),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:only_self_update([{hitrate,NewHitrate}]);
                dodge->
					Dodge=get_dodge_from_roleinfo(get(creature_info)),
					if
						Desslot < 11->
							NewDodge = Dodge + AttributeValue;
						true->
							NewDodge = Dodge - AttributeValue
					end,
					io:format("NewDodge   ~p~n", [NewDodge]),
					NewInfo = set_dodge_to_roleinfo(get(creature_info), NewDodge),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:only_self_update([{dodge,NewDodge}]);

                criticalrate->
					Criticalrate=get_criticalrate_from_roleinfo(get(creature_info)),
					if
						Desslot < 11->
							NewCriticalrate = Criticalrate + AttributeValue;
						true->
							NewCriticalrate = Criticalrate - AttributeValue
					end,
					NewInfo = set_criticalrate_to_roleinfo(get(creature_info), NewCriticalrate),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:only_self_update([{criticalrate,NewCriticalrate}]),
					role_fighting_force:hook_on_change_role_fight_force();

                criticaldestroyrate->
					Criticaldestroyrate=get_criticaldamage_from_roleinfo(get(creature_info)),
					if
						Desslot < 11->
							NewCriticaldestroyrate = Criticaldestroyrate + AttributeValue;
						true->
							NewCriticaldestroyrate = Criticaldestroyrate - AttributeValue
					end,
					NewInfo = set_criticaldamage_to_roleinfo(get(creature_info), NewCriticaldestroyrate),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:only_self_update([{criticaldestroyrate,NewCriticaldestroyrate}]);

                toughness->
					Toughness = get_toughness_from_roleinfo(get(creature_info)),
					if
						Desslot < 11->
							NewToughness = Toughness + AttributeValue;
						true->
							NewToughness = Toughness - AttributeValue
					end,
					NewInfo = set_toughness_to_roleinfo(get(creature_info), NewToughness),
					put(creature_info,NewInfo),
					role_op:update_role_info(get(roleid),NewInfo),
					role_op:only_self_update([{toughness,NewToughness}]);
					_->
						0
				
				end
		end.

%%每十分钟加一点星魂值
get_astrology_value_by_time(RoleId)->
	AstrologyInfo = astrology_db:get_astrology_info_by_roleid(RoleId),
	if AstrologyInfo=:=[]->
		   nothing;
	   true->
			StarMoney = astrology_db:get_money_from_astrology(AstrologyInfo),
			StarInfo = astrology_db:get_starinfo_from_astrology(AstrologyInfo),
			DbStarttime = astrology_db:get_starttime_from_astrology(RoleId),
			Pos=astrology_db:get_pos_from_astrology(AstrologyInfo),	
			if
				StarMoney > 30->
					NewStarMoney=StarMoney,
					astrology_db:save_astrology_add_money_time_info(RoleId,[]),
					Msg2 = login_pb:encode_astrology_money_and_pos_s2c(astrology_packet:encode_astrology_money_and_pos_s2c(NewStarMoney,Pos)),
					role_pos_util:send_to_role_clinet(RoleId,Msg2);
				true->
					{A,B,_}=now(),
					Now = 1000000 * A + B,
					if
						DbStarttime=:=[]->
							astrology_db:save_astrology_add_money_time_info(RoleId,Now);
						true->
							NStarttime =DbStarttime,
					
							if   %十分钟加一点
								trunc(Now-NStarttime) < 600->
									NewStarMoney=StarMoney,
									Msg2 = login_pb:encode_astrology_money_and_pos_s2c(astrology_packet:encode_astrology_money_and_pos_s2c(NewStarMoney,Pos)),
									role_pos_util:send_to_role_clinet(RoleId,Msg2);
								true->
									AddStarMoney=trunc((Now-NStarttime)/600),
									NewStarMoney=StarMoney+AddStarMoney,
									if
										NewStarMoney > 30->
											NewStarMoney1 = 30;									
									true->
										NewStarMoney1=NewStarMoney
									end,
									Msg2 = login_pb:encode_astrology_money_and_pos_s2c(astrology_packet:encode_astrology_money_and_pos_s2c(NewStarMoney1,Pos)),
									role_pos_util:send_to_role_clinet(RoleId,Msg2),
									astrology_db:save_astrology_info(get(roleid),StarInfo,NewStarMoney1,Pos,0),
									astrology_db:save_astrology_add_money_time_info(RoleId,Now)
							end
					end
			end
	end.
	
	

%% 使用玉星髓增加星魂值
use_yuxingsui_add_money(ItemInfo) ->
	AstrologyInfo = astrology_db:get_astrology_info_by_roleid(get(roleid)),
	StarMoney = astrology_db:get_money_from_astrology(AstrologyInfo),
	StarInfo = astrology_db:get_starinfo_from_astrology(AstrologyInfo),
	NewStarMoney=StarMoney + 10,
	Pos=astrology_db:get_pos_from_astrology(AstrologyInfo),
	role_op:consume_item(ItemInfo,1),
	astrology_db:save_astrology_info(get(roleid),StarInfo,NewStarMoney,Pos,0),
	Msg2 = login_pb:encode_astrology_money_and_pos_s2c(astrology_packet:encode_astrology_money_and_pos_s2c(NewStarMoney,Pos)),
	role_pos_util:send_to_role_clinet(get(roleid),Msg2).


%%给大于50级的可以参加占星的玩家初始化
astrology_money_init(Level)->
	if Level >= 50->
		 AstrologyInfo = astrology_db:get_astrology_info_by_roleid(get(roleid)),
		case AstrologyInfo of
			[]->
				init(get(roleid),Level);
			Info->
				nothing
		end;
		true->
			nothing
	end.

	
	