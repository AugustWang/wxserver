%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : rectangle.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 21 Apr 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(rectangle).

-compile(export_all).

contains(Rect, Point) ->
    {{L, T}, {R, B}} = Rect,
    {PtX, PtY} = Point,
    (L =< PtX) and (R >= PtX) and (T =< PtY) and (B >= PtY).

intersects(Rect1, Rect2) ->    
    {{L, T}, {R, B}} = Rect1,
    LT = {L, T},
    RT = {R, T},
    LB = {L, B},
    RB = {R, B},
    Is_contain_LT = contains(Rect2, LT),
    slogger:msg("Is_contain_LT: ~p~n", [Is_contain_LT]),

    Is_contain_RT = contains(Rect2, RT),
    slogger:msg("Is_contain_RT: ~p~n", [Is_contain_RT]),

    Is_contain_LB = contains(Rect2, LB),
    slogger:msg("Is_contain_LB: ~p~n", [Is_contain_LB]),

    Is_contain_RB = contains(Rect2, RB),
    slogger:msg("Is_contain_RB: ~p~n", [Is_contain_RB]),

%%    Is_contains = Is_contain_LT and Is_contain_RT and Is_contain_LB and Is_contain_RB,
    Is_away = not(Is_contain_LT or Is_contain_RT or Is_contain_LB or Is_contain_RB),
    not(Is_away).

%% ---------------
%% |      |      |
%% |  1   |   2  |
%% |      |      |
%% ---------------
%% |      |      |
%% |  3   |   4  |
%% |      |      |
%% ---------------
split(Rect) ->
    {{L, T}, {R, B}} = Rect,
    MiddleX = trunc((R - L) / 2),
    MiddleY = trunc((B - T) / 2),
    Rect1 = {{L, T}, {L + MiddleX, T + MiddleY}},
    Rect2 = {{L + MiddleX + 1, T}, {R, T + MiddleY}},
    Rect3 = {{L, T + MiddleY + 1}, {L + MiddleX, B}},
    Rect4 = {{L + MiddleX + 1, T + MiddleY + 1}, {R, B}},
    [Rect1, Rect2, Rect3, Rect4].
