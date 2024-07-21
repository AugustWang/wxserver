%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : test_quadtree.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 21 Apr 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(test_quadtree).


-export([
	 test/0
	 ]).

test() ->
    statistics(wall_clock),
    {true, Tree} = quadtree:build({{0, 0}, {1000, 1000}}, 15),
    {_, Duarion} = statistics(wall_clock),
    slogger:msg("Build Tree: ~p(ms)~n", [Duarion]),
    quadtree:hit({1000, 1000}, Tree),
    {_, Cost} = statistics(wall_clock),
    slogger:msg("Find Block: ~p(ms)~n", [Cost]).
