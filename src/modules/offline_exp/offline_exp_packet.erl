%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-6-2
%% Description: TODO: Add description to offline_exp_packet
-module(offline_exp_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-export([handle/2,process_offline_exp/1,
		 encode_offline_exp_error_s2c/1,encode_offline_exp_quests_init_s2c/1,
		 encode_offline_exp_init_s2c/2
		]).

%%
%% API Functions
%%

handle(Message=#offline_exp_exchange_c2s{}, RolePid)->
	RolePid!{offline_exp,Message};
handle(Message=#offline_exp_exchange_gold_c2s{}, RolePid)->
	RolePid!{offline_exp,Message}.

process_offline_exp(#offline_exp_exchange_c2s{type=Type,hours=Hours})->
	offline_exp_op:offline_exp_exchange_c2s(Type,Hours);
process_offline_exp(#offline_exp_exchange_gold_c2s{type=Type,hours=Hours})->
	offline_exp_op:offline_exp_exchange_gold_c2s(Type,Hours).

encode_offline_exp_error_s2c(Reason)->
	login_pb:encode_offline_exp_error_s2c(#offline_exp_error_s2c{reason=Reason}).
encode_offline_exp_quests_init_s2c(QuestInfos)->
	login_pb:encode_offline_exp_quests_init_s2c(#offline_exp_quests_init_s2c{questinfos=QuestInfos}).
encode_offline_exp_init_s2c(Hour,TotalExp)->
	login_pb:encode_offline_exp_init_s2c(#offline_exp_init_s2c{hour=Hour,totalexp=TotalExp}).
%%
%% Local Functions
%%

