%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-9-27
%% Description: TODO: Add description to npc_clear_crime_monster
-module(npc_clear_crime_monster).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([clear_crime/1]).


-include("npc_struct.hrl").
%%
%% API Functions
%%
clear_crime(Value)->
	npc_op:send_to_creature(get(targetid),{clear_crime,Value}).
