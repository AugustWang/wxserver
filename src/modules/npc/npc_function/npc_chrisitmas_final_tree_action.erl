%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-28
%% Description: TODO: Add description to npc_chrisitmas_final_tree_action
-module(npc_chrisitmas_final_tree_action).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("npc_define.hrl").
%%
%% Exported Functions
%%
-behaviour(npc_function_mod).

-export([init_func/0,registe_func/1,enum/3]).

%%
%% API Functions
%%
init_func()->
	npc_function_frame:add_function(chrisitmas_final_tree_action,?NPC_FUNCTION_FINAL_TREE, ?MODULE).

registe_func(_)->
	Mod= ?MODULE,
	Fun= chrisitmas_final_tree_action,
	Arg= [],
	Response= #kl{key=?NPC_FUNCTION_FINAL_TREE, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = [],
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

enum(_,_,_)->
	ignor.

