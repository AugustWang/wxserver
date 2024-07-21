%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-4-3
%% Description: TODO: Add description to socket_callback
-module(socket_callback).

%%
%% Include files
%%
%%
%% Exported Functions
%%
-export([get_client_mod/0,on_client_receive_packet/3,on_client_close_socket/2]).

%%
%% API Functions
%%

get_client_mod()->
	[{?MODULE,on_client_receive_packet,[]},
	 {?MODULE,on_client_close_socket,[]}].

on_client_receive_packet(GateProc,Binary,RolePid)->
	<<ID:16, Binary1/binary>> = Binary,
	%slogger:msg("dispatch Message:~p, GateProc:~p, RolePid:~p ~n", [ID,GateProc,RolePid]),
%% 	Message = try
%% 			  	  Term = erlang:binary_to_term(Binary),
%% 				  ID = element(2,Term),
%% 				  erlang:setelement(1,Term, login_pb:get_record_name(ID))
%% 			  catch
%% 				  _:_-> slogger:msg("socket_callback:receive_packet error ~p~n",[Binary]),{}
%% 			  end,	
%% 	slogger:msg("dispatch Message:~p, GateProc:~p, RolePid:~p ~n", [Message,GateProc,RolePid]),
	package_dispatcher:dispatch(ID, Binary1,GateProc,RolePid).

on_client_close_socket(_GateProc,RolePid) ->
	slogger:msg("close socket call back called\n").
%%
%% Local Functions
%%

