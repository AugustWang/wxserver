%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: yanzengyan
%% Created: 2012-8-23
%% Description: TODO: Add description to payment_packet
-module(payment_packet).

%%
%% Include files
%%

-include("login_pb.hrl").

%%
%% Exported Functions
%%
-export([handle/2]).
-export([encode_qz_get_balance_error_s2c/1]).

%%
%% API Functions
%%

handle(Message,RolePid)->
	RolePid ! {payment_from_client,Message}.

encode_qz_get_balance_error_s2c(Errno)->
	login_pb:encode_qz_get_balance_error_s2c(#qz_get_balance_error_s2c{error = Errno}).
%%
%% Local Functions
%%

