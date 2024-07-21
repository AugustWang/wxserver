%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-4-11
%% Description: TODO: Add description to gs_rpc
-module(gs_rpc).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([cast/2,cast/3,mult_cast/3]).

%%
%% API Functions
%%
cast(NamedProc,Msg)->
	try
		NamedProc!Msg
	catch
		E:R->
			slogger:msg("gs_rpc cast NamedProc ~p Msg ~p ERROR ~p ~n",[NamedProc,Msg,erlang:get_stacktrace()]),
			error
	end.
cast(Node,NamedProc,Msg)->
	CurNode = node(),
	try
		case Node of
			CurNode -> NamedProc ! Msg;
			_Node  ->  {NamedProc,Node} ! Msg%%rpc:abcast([Node],NamedProc, Msg) %% abcast 's first arg is NodeList
		end		
	catch 
		E:R ->
			slogger:msg("gs_rpc:cast exception[~p:~p]!Node ~p NamedProc ~p Message ~p ~n~p ~n",
				[E,R,Node,NamedProc,Msg,erlang:get_stacktrace()]),
			error
	end.


mult_cast(Nodes,NamedProc,Msg) ->
	rpc:abcast(Nodes, NamedProc, Msg).
	
%%
%% Local Functions
%%

