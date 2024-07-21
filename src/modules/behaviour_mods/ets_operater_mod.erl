%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(ets_operater_mod).

-export([behaviour_info/1]).

%%
%%	behaviour fun	-behaviour(ets_operater_mod).
%%	copy this:		-export([init/0,create/0]).
%%

behaviour_info(callbacks) ->
    [
	{create,0},							%% create ets
	{init,0}               				%% init mod	-> load to ets from db. define in  option/game_server.option
    ];
behaviour_info(_Other) ->
    undefined.
