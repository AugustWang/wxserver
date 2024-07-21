%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_dragon_fight_action).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("npc_define.hrl").
-include("dragon_fight_define.hrl").
-include("dragon_fight_def.hrl").
%%
%% Exported Functions
%%
-export([npc_dragon_fight_action/4]).

-behaviour(npc_function_mod).

-export([init_func/0,registe_func/1,enum/3]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(npc_dragon_fight,record_info(fields,npc_dragon_fight),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{npc_dragon_fight,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% API Functions
%%
init_func()->
	npc_function_frame:add_function(npc_dragon_fight_action,?NPC_FUNCTION_DRAGON_FIGHT, ?MODULE).

registe_func(NpcId)->
	Mod= ?MODULE,
	Fun= npc_dragon_fight_action,
	Arg= read_faction(NpcId),
	Response= #kl{key=?NPC_FUNCTION_DRAGON_FIGHT, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = Arg,
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

enum(_,NpcFaction,NpcId)->
	case dragon_fight_processor:get_dragon_fight_state({get(roleid),NpcFaction}) of
		error->
			State = ?DRAGON_NPC_STATE_NOTSTART;
		{?DRAGON_NPC_STATE_NOTIN_FACTION,RelationQuestId}->
			case quest_op:has_quest(RelationQuestId) of
				true->
					State = ?DRAGON_NPC_STATE_NOTIN_FACTION;
				false->
					State = ?DRAGON_NPC_STATE_NOQUEST
			end;
		State->
			nothing
	end,
	Msg = dragon_fight_packet:encode_dragon_fight_state_s2c(NpcId,NpcFaction,State),
	role_op:send_data_to_gate(Msg),
	{ok}.

npc_dragon_fight_action(_RoleInfo,NpcFaction,get_num,NpcId)->
	case dragon_fight_processor:apply_get_faction_num(NpcFaction) of
		error->
			Msg = dragon_fight_packet:encode_dragon_fight_state_s2c(NpcId,NpcFaction,?DRAGON_NPC_STATE_END),
			role_op:send_data_to_gate(Msg);
		Num->
			Msg = dragon_fight_packet:encode_dragon_fight_num_s2c(NpcId,NpcFaction,Num),
			role_op:send_data_to_gate(Msg)
	end;

npc_dragon_fight_action(_RoleInfo,NpcFaction,change_faction,NpcId)->
	case dragon_fight_processor:apply_change_my_faction({get(roleid),NpcFaction}) of
		error->
			Msg = dragon_fight_packet:encode_dragon_fight_state_s2c(NpcId,NpcFaction,?DRAGON_NPC_STATE_END),
			role_op:send_data_to_gate(Msg);
		{RemoveBuff,AddBuff}->
			Msg = dragon_fight_packet:encode_dragon_fight_faction_s2c(NpcFaction),
			role_op:send_data_to_gate(Msg),
			role_dragon_fight:dragon_fight_join_faction(AddBuff,RemoveBuff);
		_->
			nothing
	end.

read_faction(NpcId)->
	case dal:read_rpc(npc_dragon_fight,NpcId) of
		{ok,[Faction]}->  element(#npc_dragon_fight.faction,Faction);
		_->[]
	end.