%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(dragon_fight_packet).

%%
%% Include files
%%
-export([handle/2]).
-export([encode_dragon_fight_state_s2c/3,encode_dragon_fight_num_s2c/3,encode_dragon_fight_start_s2c/1,
		encode_dragon_fight_end_s2c/3,encode_dragon_fight_left_time_s2c/1,encode_dragon_fight_faction_s2c/1]).
-include("login_pb.hrl").
-include("data_struct.hrl").


handle(#dragon_fight_num_c2s{npcid = NpcId},RolePid)->
	RolePid ! {dragon_fight_num_c2s,NpcId};
handle(#dragon_fight_faction_c2s{npcid = NpcId},RolePid)->
	RolePid ! {dragon_fight_faction_c2s,NpcId};
handle(#dragon_fight_join_c2s{},RolePid)->
	RolePid ! dragon_fight_join_c2s;
handle(_,_)->
	nothing.

encode_dragon_fight_left_time_s2c(LeftTime_S)->
	login_pb:encode_dragon_fight_left_time_s2c(#dragon_fight_left_time_s2c{left_seconds = LeftTime_S}).
  
encode_dragon_fight_state_s2c(NpcId,Faction,State)->
	login_pb:encode_dragon_fight_state_s2c(#dragon_fight_state_s2c{npcid = NpcId,faction = Faction,state = State}).

encode_dragon_fight_num_s2c(NpcId,Faction,Num)->
	login_pb:encode_dragon_fight_num_s2c(#dragon_fight_num_s2c{npcid = NpcId,faction = Faction,num = Num}).

encode_dragon_fight_start_s2c(LeftTime_s)->
	login_pb:encode_dragon_fight_start_s2c(#dragon_fight_start_s2c{duration = LeftTime_s}).

encode_dragon_fight_faction_s2c(NewFaction)->
	login_pb:encode_dragon_fight_faction_s2c(#dragon_fight_faction_s2c{newfaction = NewFaction}).

encode_dragon_fight_end_s2c(Rednum,Bluenum,Winfaction)->
	login_pb:encode_dragon_fight_end_s2c(#dragon_fight_end_s2c{rednum = Rednum,bluenum = Bluenum,winfaction =Winfaction}).