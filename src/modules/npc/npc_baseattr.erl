%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2011-12-27
%% Description: TODO: Add description to npc_baseattr
-module(npc_baseattr).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([get_value/4]).

%%
%% API Functions
%%

get_value(Func,Level,OldValue,AttrScript)->
	exec_beam(AttrScript,Func,[Level,OldValue],OldValue).
%%
%% Local Functions
%%

exec_beam(Script,Fun,Args,DefaultReturn)->
	try
		apply(Script,Fun,Args)
	catch
		E:R->slogger:msg("npc basrattr error Script ~p Func ~p Args ~p Reason ~p S:~p ~n",[Script,R,Fun,Args,erlang:get_stacktrace()]),
		DefaultReturn
	end.		