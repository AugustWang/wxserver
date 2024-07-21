%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: yanzengyan
%% Created: 2012-8-23
%% Description: TODO: Add description to payment_op
-module(payment_handle).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-export([process_client_msg/1]).

%%
%% API Functions
%%

process_client_msg(#qz_get_balance_c2s{}) ->
	payment_op:get_balance().


%%
%% Local Functions
%%

