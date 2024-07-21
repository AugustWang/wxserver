%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-3-28
%% Description: TODO: Add description to answer_packet
-module(answer_packet).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([handle/2]).
-export([encode_answer_sign_notice_s2c/1,encode_answer_sign_success_s2c/0,encode_answer_start_notice_s2c/2,
		 encode_answer_error_s2c/1,encode_answer_question_ranklist_s2c/1,encode_answer_question_s2c/4,
		 encode_answer_end_s2c/1]).
-include("login_pb.hrl").
-include("data_struct.hrl").

%%
%% API Functions
%%
handle(#answer_sign_request_c2s{},RolePid)->
	role_processor:answer_sign_request_c2s(RolePid);
handle(#answer_question_c2s{id=Id,answer=Answer,flag=Flag},RolePid)->
	role_processor:answer_question_c2s(RolePid,Id,Answer,Flag);
handle(_Message,_RolePid)->
	ok.

encode_answer_sign_notice_s2c(LeftTime)->
	login_pb:encode_answer_sign_notice_s2c(#answer_sign_notice_s2c{lefttime=LeftTime}).
encode_answer_sign_success_s2c()->
	login_pb:encode_answer_sign_success_s2c(#answer_sign_success_s2c{}).
encode_answer_start_notice_s2c(Id,Num)->
	login_pb:encode_answer_start_notice_s2c(#answer_start_notice_s2c{id=Id,num=Num}).
encode_answer_question_ranklist_s2c(RankList)->
	login_pb:encode_answer_question_ranklist_s2c(#answer_question_ranklist_s2c{ranklist=RankList}).
encode_answer_question_s2c(Id,Score,Rank,Continu)->
	login_pb:encode_answer_question_s2c(#answer_question_s2c{id=Id,score=Score,rank=Rank,continu=Continu}).
encode_answer_end_s2c(Exp)->
	login_pb:encode_answer_end_s2c(#answer_end_s2c{exp=Exp}).
encode_answer_error_s2c(Reason)->
	login_pb:encode_answer_error_s2c(#answer_error_s2c{reason=Reason}).

%%
%% Local Functions
%%

