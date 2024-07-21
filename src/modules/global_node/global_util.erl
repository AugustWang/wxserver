%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(global_util).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).
-compile(export_all).

global_proc_wait()->
	global_sup:start_checker().
	%%wait_loop().

wait_loop()->
	case  global_checker:is_ready() of
		true->
			nothing;
		false->
			timer:sleep(1000),
			wait_loop()			
	end.		


send(ModuleName,Msg)->
	case global_node:get_global_proc_node(ModuleName) of
		[]->
			slogger:msg("global_util send ModuleName ~p  Msg ~p error not in node ~p !!! ~n",[ModuleName,Msg,node()]),
			error;
 			%%global:send(ModuleName,Msg);
		Node->
			gs_rpc:cast(Node,ModuleName, Msg)
	end.

call(ModuleName,Msg)->
	call(ModuleName,Msg,5000).

call(ModuleName,Msg,TimeOut)->
	case global_node:get_global_proc_node(ModuleName) of
		[]->
			slogger:msg("global_util send ModuleName ~p  Msg ~p error not in node ~p !!! ~n",[ModuleName,Msg,node()]),
			error;
 			%%gen_server:call({global,ModuleName},Msg,TimeOut);
		Node->
			gen_server:call({ModuleName,Node}, Msg,TimeOut)
	end.

