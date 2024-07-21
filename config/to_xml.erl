%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(to_xml).
-export([start/1]).

start(File) ->
    case file:consult(File) of
        {ok,Contents} ->
            lists:foreach(fun(Content) ->
                              Content
            end,Contents);
        {error,Reason} ->
            Reason
    end.
   
   
