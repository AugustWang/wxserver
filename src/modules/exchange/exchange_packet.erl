%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-3-1
%% Description: TODO: Add description to exchange_packet
-module(exchange_packet).

%%
%% Include files
%%
-export([handle/2,send_data_to_gate/1]).
-export([encode_enum_exchange_item_s2c/1,encode_exchange_item_fail_s2c/1]).
-include("login_pb.hrl").
-include("data_struct.hrl").
%%
%% Exported Functions
%%

%%
%% API Functions
%%
handle(#enum_exchange_item_c2s{npcid=NpcID},RolePid)->
	role_processor:enum_exchange_item_c2s(RolePid, NpcID);
handle(#exchange_item_c2s{npcid=NpcID, item_clsid=ItemClsid, count=Count,slots=Slots},RolePid)->
	role_processor:exchange_item_c2s(RolePid,NpcID,ItemClsid,Count,Slots);
handle(_Message,_RolePid)->
	ok.

encode_enum_exchange_item_s2c(NpcID)->
	login_pb:encode_enum_exchange_item_s2c(#enum_exchange_item_s2c{npcid=NpcID,dhs=[]}).
encode_exchange_item_fail_s2c(Reason)->
	login_pb:encode_exchange_item_fail_s2c(#exchange_item_fail_s2c{reason=Reason}).
%%
%% Local Functions
%%
send_data_to_gate(Message) ->
	role_op:send_data_to_gate(Message).
