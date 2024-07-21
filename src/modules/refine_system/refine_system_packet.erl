%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-9-16
%% Description: TODO: Add description to refine_system_packet
-module(refine_system_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
-define(SINGLE,1).
%%
%% Exported Functions
%%
-export([handle/2,handle_message/1]).
-export([encode_refine_system_s2c/1]).

%%
%% API Functions
%%
handle(Message,Pid)->
	Pid ! {refine_system,Message}.
%%#refine_system_c2s{serial_number=SerialNumber} 
handle_message(#refine_system_c2s{serial_number=SerialNumber,times = Times})->
%% 	io:format("SerialNumber:~p~n",[SerialNumber]),
%% 	if
%% 		Times =:= ?SINGLE->
%% 			refine_system_op:single_refine_process(SerialNumber);
%% 		true->
%% 			refine_system_op:multi_refine_process(SerialNumber,Times)
%% 	end.
	refine_system_op:refine_process(SerialNumber,Times).

encode_refine_system_s2c(Result)->
%% 	io:format("encode_refine_system_s2c(Result):~p~n",[Result]),
	login_pb:encode_refine_system_s2c(#refine_system_s2c{result = Result}).

%%
%% Local Functions
%%

