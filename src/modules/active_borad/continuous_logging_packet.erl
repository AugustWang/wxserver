%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-7
%% Description: TODO: Add description to continuous_logging_packet
-module(continuous_logging_packet).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).
-include("login_pb.hrl").
%%
%% API Functions
%%
handle(Message=#continuous_logging_gift_c2s{},RolePid)->
	RolePid!{continuous_logging,Message};

handle(Message=#continuous_logging_board_c2s{},RolePid)->
	RolePid!{continuous_logging,Message};

handle(Message=#continuous_days_clear_c2s{},RolePid)->
	RolePid!{continuous_logging,Message};

handle(Message=#activity_test01_recv_c2s{},RolePid)->
	RolePid!{continuous_logging,Message};

handle(Message=#collect_page_c2s{},RolePid)->
	RolePid!{continuous_logging,Message}.


encode_favorite_gift_info_s2c()->
	%%@@login_pb:encode_favorite_gift_info_s2c(#collect_page_s2c{}).
	login_pb:encode_collect_page_s2c(#collect_page_s2c{}).


encode_activity_test01_display_s2c(Index)->
	login_pb:encode_activity_test01_display_s2c(#activity_test01_display_s2c{index=Index}).

encode_activity_test01_hidden_s2c(Index)->
	login_pb:encode_activity_test01_hidden_s2c(#activity_test01_hidden_s2c{index=Index}).

encode_continuous_logging_board_s2c(NormalAwardDay,VipAwardDay,Days)->
	login_pb:encode_continuous_logging_board_s2c(#continuous_logging_board_s2c{days=Days,awarddays=NormalAwardDay}).

encode_continuous_opt_result_s2c(Result,Resultlists)->
	login_pb:encode_continuous_opt_result_s2c(#continuous_opt_result_s2c{result = Result,awarddays=Resultlists}).



