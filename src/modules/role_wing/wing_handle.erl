%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-4-17
%% Description: TODO: Add description to wing_handle
-module(wing_handle).
-compile(export_all).
-include("login_pb.hrl").
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).

%%
%% API Functions
%%



%%
%% Local Functions
%%
%%飞剑升级
process_base_message(#wing_level_up_c2s{})->
	wing_op:wing_level_up();

%%飞剑进阶
process_base_message(#wing_phase_up_c2s{is_use_gold=Usegold})->
	wing_op:wing_phase_up(Usegold);
%%品质提升
process_base_message(#wing_quality_up_c2s{})->
	wing_op:wing_quality_up();
%%强化
process_base_message(#wing_intensify_c2s{is_use_gold=Gold})->
	wing_op:wing_qintensify(Gold);

%%飞剑洗练
process_base_message(#wing_enchant_c2s{type=Type,lock_list=LockList})->
	wing_op:wing_echant(Type,LockList);

%%飞剑洗练替换
process_base_message(#wing_enchant_replace_c2s{})->
	wing_op:wing_echant_replace();

process_base_message(Message)->nothing.
	%io:format("@@@@@@@@@@@@@    no message ~n",[]).