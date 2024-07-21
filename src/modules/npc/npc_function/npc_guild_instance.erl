%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-12
%% Description: TODO: Add description to npc_guild_instance
-module(npc_guild_instance).

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
	npc_function_frame:add_function(guild_instance_action,?NPC_FUNCTION_GUILDINSTANCE, ?MODULE).

registe_func(_)->
	Mod= ?MODULE,
	Fun= guild_instance_action,
	Arg= [],
	Response= #kl{key=?NPC_FUNCTION_GUILDINSTANCE, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = [],
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

enum(_,_,_)->
	ignor.