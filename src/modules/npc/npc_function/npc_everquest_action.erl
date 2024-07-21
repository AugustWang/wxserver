%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_everquest_action).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("login_pb.hrl").
-include("npc_define.hrl").
%%
%% Exported Functions
%%
-export([everquest_action/5]).
%%
-behaviour(npc_function_mod).

-export([init_func/0,registe_func/1,enum/3]).


init_func()->
	npc_function_frame:add_function(everquest_action,?NPC_FUNCTION_EVERQUEST, ?MODULE).

registe_func(NpcId)->
	EverQuestList = quest_npc_db:get_everquestlist_by_npcid(NpcId),
	Mod= ?MODULE,
	Fun= everquest_action,
	Arg=  EverQuestList,
	Response= #kl{key=?NPC_FUNCTION_EVERQUEST, value=[]},
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg =  EverQuestList,
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	{Response,Action,Enum}.


%%not use!!!! 
enum(_,EverQuestList,NpcId)->
	CanAccptIDs = lists:filter(fun(EverId)->everquest_op:hookon_adapt_can_accpet(EverId) end , EverQuestList),
	Message = quest_packet:encode_npc_everquests_enum_s2c(NpcId,CanAccptIDs),
	role_op:send_data_to_gate(Message),
	{ok}.



everquest_action(_,EverQuestList,start,NpcId,EverQuestId)->
	case lists:member(EverQuestId, EverQuestList) of
		true->
			everquest_op:start_everquest(EverQuestId,NpcId);
		false->
			slogger:msg("quest_action accept error EverQuestId ~p ~n",[EverQuestId])
	end.
