%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-30
%% Description: TODO: Add description to honor_stores_packet
-module(honor_stores_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
handle(Message,RolePid)->
	RolePid ! {honor_stores_msg,Message}.

process_msg(#honor_stores_buy_items_c2s{type=Type,itemid=Item,count=Count})->
	honor_stores:honor_stores_buy_items(Type,Item,Count);

process_msg(_)->
	ignor.

encode_buy_honor_item_error_s2c(Errno)->
	login_pb:encode_buy_honor_item_error_s2c(#buy_honor_item_error_s2c{error=Errno}).