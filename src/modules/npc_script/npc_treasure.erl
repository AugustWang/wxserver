%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-3-24
%% Description: TODO: Add description to npc_yhzq
-module(npc_treasure).

%%
%% Exported Functions
%%
-export([give_gift_by_rules/1,give_target_buff/1]).

%%
%% Include files
%%
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("login_pb.hrl").
-include("npc_struct.hrl").
-include("battle_define.hrl").
-include("common_define.hrl").

%%
%% Ai Functions
%%
give_gift_by_rules(Rules)->
	NpcId = get(id),
	NpcProtoId = get_templateid_from_npcinfo(get(creature_info)),
	GenLootInfo = drop:apply_rulelist(Rules,1),
	Pos = get_pos_from_npcinfo(get(creature_info)),
	npc_op:send_to_creature(get(targetid),{direct_show_gift,NpcId,NpcProtoId,GenLootInfo,Pos}).

give_target_buff(BuffList)->
	Msg = role_packet:encode_treasure_buffer_s2c(BuffList),
	npc_op:send_to_other_client(get(targetid), Msg),
	creature_op:process_buff_list(get(creature_info), get(targetid), 0, BuffList). 

