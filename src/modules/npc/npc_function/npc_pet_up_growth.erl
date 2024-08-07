%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-1-26
%% Description: TODO: Add description to npc_pet_up_growth
-module(npc_pet_up_growth).

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
	npc_function_frame:add_function(pet_up_growth_action,?NPC_FUNCTION_PET_UP_GROWTH, ?MODULE).

registe_func(_)->
	Mod= ?MODULE,
	Fun= pet_up_growth_action,
	Arg= [],
	Response= #kl{key=?NPC_FUNCTION_PET_UP_GROWTH, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = [],
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

enum(_,_,_)->
	ignor.


%%
%% Local Functions
%%

