%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-12-22
%% Description: TODO: Add description to equipment_fenjie
%% zhangting modi at 2012-07-15
-module(equipment_fenjie).

%%
%% Include files
%%
-define(BOUND,1).
-include("error_msg.hrl").
-include("equipment_define.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
%%
%% Exported Functions
%%
-compile(export_all).


%%
%% API Functions
%% %批量分解功能  from jianhua.zhu  by zhangting
%
equipment_fenjie(EquipSlots)->
	 MoneyAll=
	 lists:foldr(fun(EquipSlot,Money0)->
		  equipment_fenjie_money(EquipSlot)+Money0
	 end,0,EquipSlots),	
	 HasMoney = role_op:check_money(?MONEY_BOUND_SILVER,MoneyAll),
	 if HasMoney->
		 Result1=
		 lists:foldr(fun(EquipSlot,Result0)->
			if 	Result0 =:=?SUCCESS ->
				equipment_fenjie_item(EquipSlot);	
			true->
	           Result0
	       end
		 end,?SUCCESS,EquipSlots),	
		 Message = equipment_packet:encode_equip_fenjie_optresult_s2c(Result1),		
	    role_op:send_data_to_gate(Message);
	true->
		 Message = equipment_packet:encode_equip_fenjie_optresult_s2c(?ERROR_LESS_MONEY),		
	    role_op:send_data_to_gate(Message)
	end.	


equipment_fenjie_money(EquipSlot)->
	case package_op:get_iteminfo_in_normal_slot(EquipSlot) of
		[]->
			 0;
		EquipInfo->
			EquipQuality = get_qualty_from_iteminfo(EquipInfo),
			if
				EquipQuality =/= ?ITEM_QUALITY_WHITE ->
					FenJieInfo = enchantments_db:get_equipment_fenjie_info(EquipQuality),
					enchantments_db:get_equipment_fenjie_needmoney(FenJieInfo);
				true->
					0
			end
	end.
	




%%分解单一的设备
equipment_fenjie_item(EquipSlot)->
	case package_op:get_iteminfo_in_normal_slot(EquipSlot) of
		[]->
			Errno = ?ERROR_EQUIPMENT_NOEXIST;
		EquipInfo->
			EquipQuality = get_qualty_from_iteminfo(EquipInfo),
			if
				EquipQuality =/= ?ITEM_QUALITY_WHITE ->
					FenJieInfo = enchantments_db:get_equipment_fenjie_info(EquipQuality),
					NeedMoney = enchantments_db:get_equipment_fenjie_needmoney(FenJieInfo),
					[Item,BoundItem] = enchantments_db:get_equipment_fenjie_result(FenJieInfo),
					ResultCount = enchantments_db:get_equipment_fenjie_result_count(FenJieInfo),
					HasMoney = role_op:check_money(?MONEY_BOUND_SILVER,NeedMoney),
					if
						not HasMoney ->
							Errno = ?ERROR_LESS_MONEY;
						true->
							case get_isbonded_from_iteminfo(EquipInfo) of
								?BOUND->
									case package_op:can_added_to_package_template_list([{BoundItem,ResultCount}]) of
										true->
											Errno = [],
											role_op:auto_create_and_put(BoundItem,ResultCount,fenjie),
											role_op:proc_destroy_item(EquipInfo,fenjie),
											role_op:money_change(?MONEY_BOUND_SILVER,-NeedMoney,fenjie);
										_->
											Errno = ?ERROR_PACKEGE_FULL
									end;
								_->
									case package_op:can_added_to_package_template_list([{Item,ResultCount}]) of
										true->
											Errno = [],
											role_op:auto_create_and_put(Item,ResultCount,fenjie),
											%%slogger:msg("equipment_fenjie:equipment_fenjie_item 20120720 EquipInfo:~p ~n",[EquipInfo]),
											role_op:proc_destroy_item(EquipInfo,fenjie),
											role_op:money_change(?MONEY_BOUND_SILVER,-NeedMoney,fenjie);
										_->
											Errno = ?ERROR_PACKEGE_FULL
									end
							end
					end;
				true->
					Errno = ?ERROR_EQUIPMENT_CANT_FENJIE
			end
	end,
	if 
		Errno =/= []->
			%%要求只传一个结果，不要求数组
			%%{EquipSlot,Errno}; 
            Errno;
 		true->
            ?SUCCESS
			%%{EquipSlot,?SUCCESS}	
	end.

			


%%
%% API Functions
%% zhangting  rename to old
%%
equipment_fenjie_old(EquipSlot)->
	case package_op:get_iteminfo_in_normal_slot(EquipSlot) of
		[]->
			Errno = ?ERROR_EQUIPMENT_NOEXIST;
		EquipInfo->
			EquipQuality = get_qualty_from_iteminfo(EquipInfo),
			if
				EquipQuality =/= ?ITEM_QUALITY_WHITE ->
					FenJieInfo = enchantments_db:get_equipment_fenjie_info(EquipQuality),
					NeedMoney = enchantments_db:get_equipment_fenjie_needmoney(FenJieInfo),
					[Item,BoundItem] = enchantments_db:get_equipment_fenjie_result(FenJieInfo),
					ResultCount = enchantments_db:get_equipment_fenjie_result_count(FenJieInfo),
					HasMoney = role_op:check_money(?MONEY_BOUND_SILVER,NeedMoney),
					if
						not HasMoney ->
							Errno = ?ERROR_LESS_MONEY;
						true->
							case get_isbonded_from_iteminfo(EquipInfo) of
								?BOUND->
									case package_op:can_added_to_package_template_list([{BoundItem,ResultCount}]) of
										true->
											Errno = [],
											role_op:auto_create_and_put(BoundItem,ResultCount,fenjie),
											role_op:proc_destroy_item(EquipInfo,fenjie),
											role_op:money_change(?MONEY_BOUND_SILVER,-NeedMoney,fenjie);
										_->
											Errno = ?ERROR_PACKEGE_FULL
									end;
								_->
									case package_op:can_added_to_package_template_list([{Item,ResultCount}]) of
										true->
											Errno = [],
											role_op:auto_create_and_put(Item,ResultCount,fenjie),
											role_op:proc_destroy_item(EquipInfo,fenjie),
											role_op:money_change(?MONEY_BOUND_SILVER,-NeedMoney,fenjie);
										_->
											Errno = ?ERROR_PACKEGE_FULL
									end
							end
					end;
				true->
					Errno = ?ERROR_EQUIPMENT_CANT_FENJIE
			end
	end,
	if 
		Errno =/= []->
			Message = equipment_packet:encode_equip_fenjie_optresult_s2c(Errno);
 		true->
			Message = equipment_packet:encode_equip_fenjie_optresult_s2c(?SUCCESS)
	end,
	role_op:send_data_to_gate(Message).
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
							
				
