%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-11-29
%% Description: TODO: Add description to npc_equipment
-module(npc_equipment_enchantment).

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
	npc_function_frame:add_function(equipment_enchantment_action,?NPC_FUNCTION_EQUIPMENT_ENCHANTMENT, ?MODULE).

registe_func(_)->
	Mod= ?MODULE,
	Fun= equipment_enchantment_action,
	Arg= [],
	Response= #kl{key=?NPC_FUNCTION_EQUIPMENT_ENCHANTMENT, value=[]},
	
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

