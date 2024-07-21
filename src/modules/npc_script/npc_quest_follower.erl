%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_quest_follower).

-include("base_define.hrl").
%%
%% Exported Functions
%%
-export([spawn_follower_for_quest/2]).

spawn_follower_for_quest(QuestId,NpcProto)->
	npc_op:send_to_creature(get(targetid),{quest_script_msg,quest_follower_followed,[QuestId,NpcProto]}).
	