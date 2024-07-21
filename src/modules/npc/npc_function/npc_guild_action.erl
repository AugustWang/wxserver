%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_guild_action).

-include("mnesia_table_def.hrl").
-include("login_pb.hrl").
-include("npc_define.hrl").
%%
%% Exported Functions
%%
%%
-behaviour(npc_function_mod).

-export([init_func/0,registe_func/1,enum/3]).

init_func()->
	npc_function_frame:add_function(guild_action,?NPC_FUNCTION_GUILD, ?MODULE).

registe_func(_NpcId)->
	Mod= ?MODULE,
	Fun= guild_action,
	Arg= [],
	Response= #kl{key=?NPC_FUNCTION_GUILD, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = [],
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

enum(_,_,_)->
	ignor.
