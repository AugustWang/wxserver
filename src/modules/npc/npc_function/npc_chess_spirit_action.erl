%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_chess_spirit_action).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("npc_define.hrl").
-include("chess_spirit_define.hrl").
-include("chess_spirit_def.hrl").

%%
%% Exported Functions
%%
-behaviour(npc_function_mod).

-export([init_func/0,registe_func/1,enum/3]).

%%
%% API Functions
%%
init_func()->
	npc_function_frame:add_function(chess_spirit_action,?NPC_FUNCTION_CHESS_SPIRIT, ?MODULE).

registe_func(NpcId)->
	Mod= ?MODULE,
	Fun= chess_spirit_action,
	Arg= [?CHESS_SPIRIT_TYPE_SINGLE,?CHESS_SPIRIT_TYPE_TEAM],
	Response= #kl{key=?NPC_FUNCTION_CHESS_SPIRIT, value=[]},
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = Arg,
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	{Response,Action,Enum}.

enum(_,Args,_NpcId)->
	{ok}.

