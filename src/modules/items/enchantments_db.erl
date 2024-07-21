%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%%
%%
-module(enchantments_db).
%% 
%% define
%% 
-define(ENCHANTMENTS_LUCKY_ETS,enchantments_lucky_table).
-include("equipment_up_def.hrl").
-include("equipment_define.hrl").

%% 
%% export
%% 
-compile(export_all).

-export([get_enchantments_info/1,get_equip_punch_info/1,get_inlay_info/1,get_stonemix_info/1]).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(enchantments, record_info(fields,enchantments), [], set),
	db_tools:create_table_disc(sock, record_info(fields,sock), [], set),
	db_tools:create_table_disc(inlay, record_info(fields,inlay), [], set),
	db_tools:create_table_disc(remove_seal, record_info(fields,remove_seal), [], set),
	db_tools:create_table_disc(stonemix, record_info(fields,stonemix), [], set),
	db_tools:create_table_disc(equipment_move, record_info(fields,equipment_move), [], set),
	db_tools:create_table_disc(enchantments_lucky, record_info(fields,enchantments_lucky), [], set),
	db_tools:create_table_disc(equipment_upgrade, record_info(fields,equipment_upgrade), [], set),
	db_tools:create_table_disc(equipment_fenjie, record_info(fields,equipment_fenjie), [], set),
	db_tools:create_table_disc(stonemix_rateinfo, record_info(fields,stonemix_rateinfo), [], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{enchantments,proto},{sock,proto},{inlay,proto},{stonemix,proto},{equipment_upgrade,proto},
	 {equipment_fenjie,proto},{equipment_move,proto},{enchantments_lucky,proto}].

delete_role_from_db(_RoleId)->
	nothing.

create()->
	ets:new(?ENCHANTMENTS_ETS,[set,public,named_table]),
	ets:new(?SOCK_ETS,[set,public,named_table]),
	ets:new(?INLAY_ETS,[set,public,named_table]),
	ets:new(?REMOVE_SEAL_ETS,[set,public,named_table]),
	ets:new(?STONEMIX_ETS,[set,public,named_table]),
	ets:new(?EQUIPMENT_UPGRADE_ETS,[set,public,named_table]),
	ets:new(?EQUIPMENT_MOVE_ETS,[bag,public,named_table]),
	ets:new(?EQUIPMENT_FENJIE_ETS,[set,public,named_table]),
	ets:new(?ENCHANTMENTS_LUCKY_ETS,[set,public,named_table]),

   %%鎵归噺鍚堟垚姒傜巼  by zhangting%%
    ets:new(?STONEMIX_RATEINFO_ETS,[set,public,named_table]).



init()->
	db_operater_mod:init_ets(enchantments, ?ENCHANTMENTS_ETS,#enchantments.level),
	db_operater_mod:init_ets(sock, ?SOCK_ETS,#sock.punchnum),
	db_operater_mod:init_ets(inlay, ?INLAY_ETS,#inlay.level),
	db_operater_mod:init_ets(remove_seal, ?REMOVE_SEAL_ETS,#remove_seal.equipid),
	db_operater_mod:init_ets(stonemix, ?STONEMIX_ETS,#stonemix.stoneclass),
	db_operater_mod:init_ets(enchantments_lucky, ?ENCHANTMENTS_LUCKY_ETS,#enchantments_lucky.id),
	db_operater_mod:init_ets(equipment_upgrade, ?EQUIPMENT_UPGRADE_ETS,#equipment_upgrade.equipid),
	db_operater_mod:init_ets(equipment_move, ?EQUIPMENT_MOVE_ETS,#equipment_move.flevel),
	db_operater_mod:init_ets(equipment_fenjie, ?EQUIPMENT_FENJIE_ETS,#equipment_fenjie.quality),

    %%鎵归噺鍚堟垚姒傜巼  by zhangting%%
   db_operater_mod:init_ets(stonemix_rateinfo, ?STONEMIX_RATEINFO_ETS,#stonemix_rateinfo.amount).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_enchantments_info(Level)->
	case ets:lookup(?ENCHANTMENTS_ETS, Level) of
		[]->[];
        [{_,Info}]-> Info 
	end.



get_enchantments_bonuses(EnchantInfo)->
	element(#enchantments.bonuses,EnchantInfo).

get_enchantments_consum(EnchantInfo)->
	element(#enchantments.consum,EnchantInfo).

get_enchantments_riseup(EnchantInfo)->
	element(#enchantments.riseup,EnchantInfo).

get_enchantments_successrate(EnchantInfo)->
	element(#enchantments.successrate,EnchantInfo).

get_enchantments_failure(EnchantInfo)->
	element(#enchantments.failure,EnchantInfo).

get_enchantments_protect(EnchantInfo)->
	element(#enchantments.protect,EnchantInfo).

get_enchantments_return(EnchantInfo)->
	element(#enchantments.return,EnchantInfo).

get_enchantments_lucky(EnchantInfo)->
	element(#enchantments.lucky,EnchantInfo).

get_enchantments_set_attr(EnchantInfo)->
	element(#enchantments.set_attr,EnchantInfo).

get_enchantments_add_attr(EnchantInfo)->
	element(#enchantments.add_attr,EnchantInfo).

get_enchantments_successsysbrd(EnchantInfo)->
	element(#enchantments.successsysbrd,EnchantInfo).

get_enchantments_faildsysbrd(EnchantInfo)->
	element(#enchantments.faildsysbrd,EnchantInfo).

get_enchantments_faildsysbrdwithprotect(EnchantInfo)->
	element(#enchantments.faildsysbrdwithprotect,EnchantInfo).

get_equip_punch_info(PunchNum)->
	case ets:lookup(?SOCK_ETS, PunchNum) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_sock_info(Level)->
	case ets:lookup(?SOCK_ETS, Level) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_inlay_info(Level)->
	case ets:lookup(?INLAY_ETS, Level) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_stonemix_info(Class)->
	case ets:lookup(?STONEMIX_ETS, Class) of
		[]->[];
        [{_,StonemixInfo}]-> StonemixInfo 
	end.

 %%鎵归噺鍚堟垚姒傜巼  by zhangting%%
get_stonemix_rateinfo(Amount)->
	case ets:lookup(?STONEMIX_RATEINFO_ETS, Amount) of
		 []->[];
        [{_,Stonemix_rateinfo}]-> Stonemix_rateinfo 
	end.

get_relieve_seal_info(ItemId)->
	case ets:lookup(?REMOVE_SEAL_ETS, ItemId) of
		[]->[];
        [{_,SealInfo}]-> SealInfo 
	end.

get_equipment_upgrade_info(ItemId)->
	case ets:lookup(?EQUIPMENT_UPGRADE_ETS, ItemId) of
		[]->[];
        [{_,UpgradeInfo}]-> UpgradeInfo
	end.

get_equipment_fenjie_info(Quality)->
	case ets:lookup(?EQUIPMENT_FENJIE_ETS, Quality) of
		[]->[];
        [{_,Info}]-> Info
	end.

get_equipment_fenjie_needmoney(Info)->
	element(#equipment_fenjie.needmoney,Info).

get_equipment_fenjie_result(Info)->
	element(#equipment_fenjie.result,Info).

get_equipment_fenjie_result_count(Info)->
	element(#equipment_fenjie.resultcount,Info).

get_equipment_upgrade_needitem(UpgradeInfo)->
	element(#equipment_upgrade.needitem,UpgradeInfo).

get_equipment_upgrade_needitemcount(UpgradeInfo)->
	element(#equipment_upgrade.needitemcount,UpgradeInfo).

get_equipment_upgrade_needmoney(UpgradeInfo)->
	element(#equipment_upgrade.needmoney,UpgradeInfo).

get_equipment_upgrade_result(UpgradeInfo)->
	element(#equipment_upgrade.resultid,UpgradeInfo).

get_relieve_seal_needitem(SealInfo)->
	element(#remove_seal.needitem,SealInfo).

get_relieve_seal_needitemcount(SealInfo)->
	element(#remove_seal.needitemcount,SealInfo).

get_relieve_seal_needmoney(SealInfo)->
	element(#remove_seal.needmoney,SealInfo).

get_relieve_seal_result(SealInfo)->
	element(#remove_seal.resultid,SealInfo).

get_equip_punch_consume(PunchInfo)->
	element(#sock.consume,PunchInfo).

get_equip_punch_money(PunchInfo)->
	element(#sock.money,PunchInfo).

get_equip_punch_rate(PunchInfo)->
	element(#sock.rate,PunchInfo).

get_stonemix_consume_silver(StonemixInfo)->
	erlang:element(#stonemix.silver, StonemixInfo).

get_stonemix_consume_gold(StonemixInfo)->
	erlang:element(#stonemix.gold, StonemixInfo).

get_random_rate(StonemixInfo)->
	erlang:element(#stonemix.rate, StonemixInfo).

get_stonemix_result(StonemixInfo)->
	erlang:element(#stonemix.result, StonemixInfo).

get_enchantments_lucky_info(ItemTemplateId)->
	case ets:lookup(?ENCHANTMENTS_LUCKY_ETS, ItemTemplateId) of
		[]->[];
        [{_,Info}]-> Info 
	end.	

get_enchantments_lucky_rate(LuckyInfo)->
	erlang:element(#enchantments_lucky.rate, LuckyInfo).

get_enchantments_lucky_rate_by_templateid(ItemTemplateId)->
	case ets:lookup(?ENCHANTMENTS_LUCKY_ETS, ItemTemplateId) of
		[]->0;
        [{_,LuckyInfo}]-> 
			erlang:element(#enchantments_lucky.rate, LuckyInfo)
	end.