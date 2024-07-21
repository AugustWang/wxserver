%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-5-17
%% Description: TODO: Add description to item_add_astrology_money
-module(item_add_astrology_money).
-export([use_item/1]).
-include("data_struct.hrl").
-include("item_struct.hrl").

use_item(ItemInfo)->

	astrology_op:use_yuxingsui_add_money(ItemInfo).



