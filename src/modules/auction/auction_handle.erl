%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(auction_handle).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("login_pb.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("error_msg.hrl").

%handle(#stall_sell_item_c2s{slot = Slot,silver = Silver,gold = Gold,ticket=Ticket})->
%	if
%		((Silver >= 0)  and (Gold >= 0) and ((Gold + Silver) > 0))->
%			io:format("Slot ~p ,Moneys ~p ~n",[Slot,Silver]),
%			auction_op:proc_item_up_stall(Slot,{Silver,Gold,Ticket});
%		true->
%			slogger:msg("stall_sell_item_c2s error money ~p ~n",[{Silver,Gold,Ticket}])
%	end;

handle(#paimai_sell_c2s{gold=Gold, duration_type=Duration_type, silver=Silver, value=Value, type=Type, slot=Slot})->%%2æœˆ19æ—¥ã€xiaowuã€‘
	case Value of
		0 ->
			if
				((Silver >= 0)  and (Gold >= 0) and ((Gold + Silver) > 0))->
					case auction_op:proc_item_up_stall_by_xiaowu(Slot,{Silver,Gold,0},Duration_type) of
						ok ->
							auction_op:bao_guan_fei_by_xiao_wu(Gold,Silver,Duration_type),
							role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_SHANGJIA_CHENGGONG));
						_ ->
							role_pos_util:send_to_role_clinet(get(roleid),auction_packet:encode_paimai_opt_result_s2c(?ERROR_STALL_TANWEIMAN))
					end;
				true->
					slogger:msg("stall_sell_item_c2s error money ~p ~n",[{Silver,Gold}])
			end;
		_ ->
			auction_op:proc_money_up_stall_by_xiaowu(Gold, Duration_type, Silver,Value,Type,Duration_type)%%2.21
			
	end;

handle(#paimai_detail_c2s{stallid = StallId})->
	auction_op:proc_paimai_detail(StallId);

handle(#paimai_recede_c2s{type=Type, stallid=Stallid, indexid=Indexid})->
	auction_op:proc_recede_item_by_xiaowu(Type,Stallid,Indexid);

handle(#paimai_search_by_sort_c2s{subsortkey=Subsortkey, sortkey=Sortkey, levelsort=Levelsort, index=Index, mainsort=Mainsort, moneysort=Moneysort})->
	auction_op:proc_paimai_search_by_sort(Subsortkey,Sortkey,Levelsort,Index,Mainsort,Moneysort);

handle(#paimai_search_by_string_c2s{levelsort=Levelsort, str=Str, index=Index, mainsort=Mainsort, moneysort=Moneysort})->
	auction_op:proc_paimai_search_by_string(Levelsort,Str,Index,Mainsort,Moneysort);

handle(#paimai_search_by_grade_c2s{levelsort=Levelsort, index=Index, allowableclass=Allowableclass, mainsort=Mainsort, levelgrade=Levelgrade, moneysort=Moneysort, qualitygrade=Qualitygrade})->
	auction_op:proce_paimai_search_by_grade(Levelsort,Index,Allowableclass,Mainsort,Levelgrade,Moneysort,Qualitygrade);

handle(#paimai_buy_c2s{type=Type, stallid=Stallid, indexid=Indexid})->
	auction_op:proce_paimai_buy(Type, Stallid, Indexid);

%handle(#stalls_search_c2s{index = Index})->
%	auction_op:proc_stalls_search(Index);

%handle(#stalls_search_item_c2s{index = Index,searchstr = Str})->
%	auction_op:proc_stalls_item_search(Index,Str);

%handle(#stall_detail_c2s{stallid = StallId})->
%	auction_op:proc_stall_detail(StallId);

%handle(#stall_recede_item_c2s{itemlid = ItemLid,itemhid = ItemHid})->
%	ItemId = get_itemid_by_low_high_id(ItemHid,ItemLid),
%	auction_op:proc_recede_item(ItemId);

%handle(#stall_buy_item_c2s{stallid = StallId,itemlid =ItemLid,itemhid = ItemHid})->
%	ItemId = get_itemid_by_low_high_id(ItemHid,ItemLid),
%	auction_op:proc_buy_item_c2s(StallId,ItemId);

handle(#stall_role_detail_c2s{rolename = RoleName})->
	auction_op:proc_stall_detail_by_rolename(RoleName);

handle(#stall_rename_c2s{stall_name = StallName})->
	auction_op:proc_rename(StallName);

handle(Other)->
	slogger:msg("auction_handle error msg ~p ~n",[Other]).