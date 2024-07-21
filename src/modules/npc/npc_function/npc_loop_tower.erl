%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-12-27
%% Description: TODO: Add description to npc_loop_tower
-module(npc_loop_tower).

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
	npc_function_frame:add_function(loop_tower_action,?NPC_FUNCTION_LOOP_TOWER, ?MODULE).

registe_func(_)->
	Mod= ?MODULE,
	Fun= loop_tower_action,
	Arg= [],
	Response= #kl{key=?NPC_FUNCTION_LOOP_TOWER, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = [],
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

enum(_RoleInfo,_,_NpcId)->
	loop_tower_op:npc_function(),		
	{ok}.


%%
%% Local Functions
%%

