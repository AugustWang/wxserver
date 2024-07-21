%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-7-19
%% Description: TODO: Add description to treasure_storage_packet
-module(treasure_storage_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("item_struct.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% API Functions
%%
handle(Message = #treasure_storage_init_c2s{},RolePid)->
	RolePid ! {treasure_storage,Message};

handle(Message = #treasure_storage_getitem_c2s{},RolePid)->
	RolePid ! {treasure_storage,Message};

handle(Message = #treasure_storage_getallitems_c2s{},RolePid)->
	RolePid ! {treasure_storage,Message};

handle(_,_)->
	nothing.

encode_treasure_storage_info_s2c(ItemsInfo)->
	login_pb:encode_treasure_storage_info_s2c(#treasure_storage_info_s2c{items = ItemsInfo}).	

encode_treasure_storage_init_end_s2c()->
	login_pb:encode_treasure_storage_init_end_s2c(#treasure_storage_init_end_s2c{}).

encode_treasure_storage_updateitem_s2c(ItemsList)->
	login_pb:encode_treasure_storage_updateitem_s2c(#treasure_storage_updateitem_s2c{itemlist = ItemsList}).

encode_treasure_storage_additem_s2c(Items)->
	login_pb:encode_treasure_storage_additem_s2c(#treasure_storage_additem_s2c{items = Items}).

encode_treasure_storage_delitem_s2c(Start,Length)->
	login_pb:encode_treasure_storage_delitem_s2c(#treasure_storage_delitem_s2c{start = Start,length = Length}).

encode_treasure_storage_opt_s2c(Code)->
	login_pb:encode_treasure_storage_opt_s2c(#treasure_storage_opt_s2c{code = Code}).

make_tsi(ItemProtoId,Solt,Count,Sign)->
	#tsi{itemprotoid = ItemProtoId,solt = Solt,count = Count,itemsign = Sign}.

%%
%% Local Functions
%%

