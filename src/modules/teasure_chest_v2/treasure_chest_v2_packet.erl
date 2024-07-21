%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: ChenXiaowei
%% Created: 2011-7-18
%% Description: TODO: Add description to beads_pray_packet
-module(treasure_chest_v2_packet).

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

handle(#beads_pray_request_c2s{type = Type,times = Times,consume_type = ConsumeType},RolePid)->
	RolePid!{treasure_chest_v2,{Type,Times,ConsumeType}}.

encode_treasure_chest_v2_response_s2c(Type,Times,LotteryItemList)->
	login_pb:encode_beads_pray_response_s2c(#beads_pray_response_s2c{type = Type,times = Times,itemslist = LotteryItemList}).

encode_treasure_chest_v2_fail_s2c(Type)->
	login_pb:encode_beads_pray_fail_s2c(#beads_pray_fail_s2c{type = Type}).

encode_treasure_chest_broad_s2c(RoleName,ProtoId,Count)->
	login_pb:encode_treasure_chest_broad_s2c(#treasure_chest_broad_s2c{rolename=RoleName,item={lti,ProtoId,Count}}).
%%
%% Local Functions
%%

