%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-2-22
%% Description: TODO: Add description to item_soulpower_gift
-module(item_soulpower_baby_empty).

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

%%鍏呮皵濞冨▋鍏呮皵
use_item(ItemInfo)  ->
	SoulPowerParams = get_states_from_iteminfo(ItemInfo),
	case lists:keyfind(sp_minus, 1, SoulPowerParams) of
		{_,SoulPowerValue,FillTemplateId}->
			CurSpValue = role_soulpower:get_cursoulpower(),
			case  CurSpValue >= SoulPowerValue of
				true->
				     case package_op:can_added_to_package_template_list([ {FillTemplateId,1}]) of
					  false ->
							ErrNo = ?ERROR_PACKEGE_FULL;
					  true ->	
                         role_op:consume_soulpower(SoulPowerValue),
							 role_op:auto_create_and_put(FillTemplateId,1,'baby_fill'),						
                         ErrNo= 0
					  end;
                     					
				false->
                     ErrNo = ?ERROR_SOULPOWER_NOT_ENOUGH
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
