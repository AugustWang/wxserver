%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : gm_math.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 22 Apr 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(gm_math).

-compile(export_all).

ceiling(X) ->
    T = trunc(X),
    case X - T == 0 of
        true -> T;
        false -> T + 1
    end.

floor(X) ->
    T = trunc(X),
    case X - T == 0 of
        true -> T;
        false -> T - 1
    end.
