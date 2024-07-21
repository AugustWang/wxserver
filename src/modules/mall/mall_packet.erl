%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaodya
%% Created: 2010-11-3
%% Description: TODO: Add description to mall_packet
-module(mall_packet).

%%
%% Include files
%%
-export([handle/2,process_mall/1]).
-export([encode_init_mall_item_list_s2c/1,
		 encode_mall_item_list_s2c/1,
		 encode_mall_item_list_special_s2c/1,
		 encode_mall_item_list_sales_s2c/1,
		 encode_init_hot_item_s2c/1,
		 encode_init_latest_item_s2c/1,
		 encode_buy_item_fail_s2c/1]).
-include("login_pb.hrl").
-include("data_struct.hrl").
%%
%% Exported Functions
%%


%%
%% API Functions
%%

%%
%% Local Functions
%%
handle(Message=#init_mall_item_list_c2s{}, RolePid) ->
	RolePid!{process_mall,Message};
handle(Message=#mall_item_list_c2s{}, RolePid) ->
	RolePid!{process_mall,Message};
handle(Message=#buy_mall_item_c2s{}, RolePid)->
	RolePid!{process_mall,Message};
handle(Message=#mall_item_list_special_c2s{}, RolePid)->
	RolePid!{process_mall,Message};
handle(Message=#mall_item_list_sales_c2s{}, RolePid)->
	RolePid!{process_mall,Message};
handle(_Message,_RolePid)->
	ok.

process_mall(#init_mall_item_list_c2s{ntype=Ntype})->
	mall_op:init_mall_item_list(Ntype);
process_mall(#mall_item_list_c2s{ntype=Ntype})->
	mall_op:get_mall_item_list(Ntype);
process_mall(#mall_item_list_special_c2s{ntype2=Ntype2})->
	mall_op:get_mall_item_list_special(Ntype2);
process_mall(#mall_item_list_sales_c2s{ntype=Ntype})->
	mall_op:get_mall_item_list_sales(Ntype);
process_mall(#buy_mall_item_c2s{mitemid=MitemId,count=Count,price=Price,type=Type})->
	case get(is_in_world) of
		true->
			mall_op:mall_buy_action(get(creature_info),MitemId,Count,Price,Type);
		_ ->
			nothing	
	end.

encode_buy_item_fail_s2c(ErrorCode) ->
	login_pb:encode_buy_item_fail_s2c(#buy_item_fail_s2c{reason=ErrorCode}).
encode_init_mall_item_list_s2c(MallItemList)->
	login_pb:encode_init_mall_item_list_s2c(#init_mall_item_list_s2c{mitemlists = MallItemList}).
encode_mall_item_list_s2c(MallItemList)->
	login_pb:encode_mall_item_list_s2c(#mall_item_list_s2c{mitemlists = MallItemList}).
encode_mall_item_list_special_s2c(MallItemList)->
	login_pb:encode_mall_item_list_special_s2c(#mall_item_list_special_s2c{mitemlists = MallItemList}).
encode_mall_item_list_sales_s2c(MallItemList)->
	login_pb:encode_mall_item_list_sales_s2c(#mall_item_list_sales_s2c{mitemlists = MallItemList}).
encode_init_hot_item_s2c(HotLists)->
	login_pb:encode_init_hot_item_s2c(#init_hot_item_s2c{lists = HotLists}).
encode_init_latest_item_s2c(LatestLists)->
	login_pb:encode_init_latest_item_s2c(#init_latest_item_s2c{lists = LatestLists}).
