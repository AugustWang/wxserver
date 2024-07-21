%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-2-22
%% Description: TODO: Add description to item_soulpower_gift
-module(item_soulpower_baby_needle).

%%
%% Exported Functions
%%
%%-export([use_item/1]).
-compile(export_all).

%%
%% Include files
%%
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").

%%ä½¿ç”¨ç»£åŒ–é’ˆåˆºç ´å……æ°”å¨ƒå¨ƒ,ItemInfoæ˜¯å……æ°”å¨ƒå¨ƒ
use_item(ItemInfo)  ->	
    SoulPowerParams = get_states_from_iteminfo(ItemInfo),	
	case lists:keyfind(sp_add, 1, SoulPowerParams) of
		 {_,SoulPowerValue,BondTemplateId,TemplateId}->
			   MaxSpValue = role_soulpower:get_maxsoulpower(),
	          CurSpValue = role_soulpower:get_cursoulpower(),
				case  MaxSpValue > CurSpValue of
					 true->
	                   BondItemSlotInfos=package_op:getSlotsByItemInfo(BondTemplateId),
					   slogger:msg("item_soulpower_baby_needle:use_item 20120809a01  BondItemSlotInfos:~p~n"
					   ,[BondItemSlotInfos]),
						 ItemSlotInfos = if length(BondItemSlotInfos) =:=0 -> package_op:getSlotsByItemInfo(TemplateId);true->BondItemSlotInfos end,
					     case length(ItemSlotInfos)>0 of
						  true->
							  {SlotNum,Itemid,Count} = hd(ItemSlotInfos),
							  role_op:obtain_soulpower(SoulPowerValue),
							  role_op:consume_item(items_op:get_item_info(Itemid),1),
							  ErrNo= 0;
						  false->
							  ErrNo= ?ERROR_SOULPOWER_NO_BABY
                       end;
					 false->
                       ErrNo= ?ERROR_SOULPOWER_FULL   
	           end;
		 _->
			  ErrNo = ?ERROR_USED_IN_MAPPOS
	end,	
   if  ErrNo =:=0 ->true;
   true->
		 Msg = role_packet:encode_use_item_error_s2c(ErrNo),
		 role_op:send_data_to_gate(Msg),
		 false
    end.
