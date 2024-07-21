%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-1-11
%% Description: TODO: Add description to npc_vip
-module(npc_vip).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("npc_define.hrl").
%%
%% Exported Functions
%%

%%
%% API Functions
%%
-behaviour(npc_function_mod).

-export([init_func/0,registe_func/1,enum/3]).

init_func()->
	npc_function_frame:add_function(npc_vip_action,?NPC_FUNCTION_VIP, ?MODULE).

registe_func(_NpcId)->
	Mod= ?MODULE,
	Fun= npc_vip_action,
	Arg= [],
	Response= #kl{key=?NPC_FUNCTION_VIP, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = [],
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

enum(_RoleInfo,_,_NpcId)->
	vip_op:npc_function(),		
	{ok}.


%%
%% Local Functions
%%

