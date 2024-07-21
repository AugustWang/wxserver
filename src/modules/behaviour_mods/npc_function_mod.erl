%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_function_mod).

-export([behaviour_info/1]).

%%
%%	behaviour fun	-behaviour(npc_function_mod).
%%	copy this:		-export([init_func/0,registe_func/1,enum/3]).
%%

behaviour_info(callbacks) ->
    [
	{init_func,0},               				%% init function
	{registe_func,1},								%% init Npc	args:NpcId	
	{enum,3}
    ];
behaviour_info(_Other) ->
    undefined.



