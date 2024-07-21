%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : test_rectangle.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 21 Apr 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(test_rectangle).

-export([
	 test/0
	]).

-include_lib("eunit/include/eunit.hrl").

test() ->
%%     ?assert(rectangle:contains({{0, 0}, {100, 100}}, {10, 10}) =:= true),
%%     ?assert(rectangle:contains({{0, 0}, {100, 100}}, {100, 100}) =:= true),
%%     ?assert(rectangle:contains({{0, 0}, {100, 100}}, {101, 101}) =:= false),

%%     ?assert(rectangle:intersects({{0, 0}, {100, 100}}, {{0, 0}, {100, 100}}) =:= true),
%%     ?assert(rectangle:intersects({{0, 0}, {100, 100}}, {{50, 50}, {120, 120}}) =:= true),
%%     ?assert(rectangle:intersects({{0, 0}, {100, 100}}, {{101, 101}, {120, 120}}) =:= false),
    ?assert(rectangle:intersects({{0, 0}, {100, 100}}, {{10, 10}, {50, 50}}) =:= true),

    ?assert(rectangle:split({{0, 0}, {100, 100}}) =:= [{{0, 0}, {50, 50}}, {{51, 0}, {100, 50}}, {{0, 51}, {50, 100}}, {{51, 51}, {100, 100}}]),
    ?assert(rectangle:split({{0, 0}, {101, 101}}) =:= [{{0, 0}, {50, 50}}, {{51, 0}, {101, 50}}, {{0, 51}, {50, 101}}, {{51, 51}, {101, 101}}]).
