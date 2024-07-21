%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-3-23
%% Description: TODO: Add description to timelimit_gift_packet
-module(timelimit_gift_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("data_struct.hrl").

%%
%% Exported Functions
%%
-compile(export_all).
%%
%% API Functions
%%
encode_timelimit_gift_info_s2c(NextIndex,NextTime,DropList)->
	Items = lists:map(fun({ItemId,ItemCount})-> #lti{protoid = ItemId,item_count = ItemCount} end, DropList),
	login_pb:encode_timelimit_gift_info_s2c(#timelimit_gift_info_s2c{nextindex = NextIndex,nexttime = NextTime,itmes =Items}).

encode_timelimit_gift_error_s2c(Errno)->
	login_pb:encode_timelimit_gift_error_s2c(#timelimit_gift_error_s2c{reason = Errno}).

encode_timelimit_gift_over_s2c()->
	login_pb:encode_timelimit_gift_over_s2c(#timelimit_gift_over_s2c{}).


handle(#get_timelimit_gift_c2s{},RolePid)->
	role_processor:get_timelimit_gift_c2s(RolePid).

%%
%% Local Functions
%%

