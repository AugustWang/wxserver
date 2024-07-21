%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(example).


-export([run/0]).

-include("scribe_types.hrl").
-include("fb303_types.hrl").
run() ->
    {ok, C} = thrift_client_util:new("127.0.0.1", 8250, scribe_thrift,
                       [{strict_read, false}, 
                        {strict_write, false}, 
                        {framed, true}]),


    io:format("Connected ~p~n", [C]),
    
    Res = thrift_client:call(C, 'Log', [[#logEntry{category="test_erlang", message="This is a test"}]]),
    io:format("Log result ~p ~n", [Res]),

    Name = thrift_client:call(C, 'getStatus', []),
    io:format("Name ~p~n",[Name]),
    ok.
