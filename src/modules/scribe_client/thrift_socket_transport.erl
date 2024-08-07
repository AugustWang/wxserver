%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%% Licensed to the Apache Software Foundation (ASF) under one
%% or more contributor license agreements. See the NOTICE file
%% distributed with this work for additional information
%% regarding copyright ownership. The ASF licenses this file
%% to you under the Apache License, Version 2.0 (the
%% "License"); you may not use this file except in compliance
%% with the License. You may obtain a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied. See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%

-module(thrift_socket_transport).

-behaviour(thrift_transport).

-export([new/1,
         new/2,
         write/2, read/2, flush/1, close/1,

         new_transport_factory/3]).

-record(data, {socket,
               recv_timeout=infinity}).
-type state() :: #data{}.
-include("thrift_transport_behaviour.hrl").

new(Socket) ->
    new(Socket, []).

new(Socket, Opts) when is_list(Opts) ->
    State =
        case lists:keysearch(recv_timeout, 1, Opts) of
            {value, {recv_timeout, Timeout}}
            when is_integer(Timeout), Timeout > 0 ->
                #data{socket=Socket, recv_timeout=Timeout};
            _ ->
                #data{socket=Socket}
        end,
    thrift_transport:new(?MODULE, State).

%% Data :: iolist()
write(This = #data{socket = Socket}, Data) ->
    {This, gen_tcp:send(Socket, Data)}.

read(This = #data{socket=Socket, recv_timeout=Timeout}, Len)
  when is_integer(Len), Len >= 0 ->
    case gen_tcp:recv(Socket, Len, Timeout) of
        Err = {error, timeout} ->
            error_logger:info_msg("read timeout: peer conn ~p", [inet:peername(Socket)]),
            gen_tcp:close(Socket),
            {This, Err};
        Data ->
            {This, Data}
    end.

%% We can't really flush - everything is flushed when we write
flush(This) ->
    {This, ok}.

close(This = #data{socket = Socket}) ->
    {This, gen_tcp:close(Socket)}.


%%%% FACTORY GENERATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% The following "local" record is filled in by parse_factory_options/2
%% below. These options can be passed to new_protocol_factory/3 in a
%% proplists-style option list. They're parsed like this so it is an O(n)
%% operation instead of O(n^2)
-record(factory_opts, {connect_timeout = infinity,
                       sockopts = [],
                       framed = false}).

parse_factory_options([], Opts) ->
    Opts;
parse_factory_options([{framed, Bool} | Rest], Opts) when is_boolean(Bool) ->
    parse_factory_options(Rest, Opts#factory_opts{framed=Bool});
parse_factory_options([{sockopts, OptList} | Rest], Opts) when is_list(OptList) ->
    parse_factory_options(Rest, Opts#factory_opts{sockopts=OptList});
parse_factory_options([{connect_timeout, TO} | Rest], Opts) when TO =:= infinity; is_integer(TO) ->
    parse_factory_options(Rest, Opts#factory_opts{connect_timeout=TO}).


%%
%% Generates a "transport factory" function - a fun which returns a thrift_transport()
%% instance.
%% This can be passed into a protocol factory to generate a connection to a
%% thrift server over a socket.
%%
new_transport_factory(Host, Port, Options) ->
    ParsedOpts = parse_factory_options(Options, #factory_opts{}),

    F = fun() ->
                SockOpts = [binary,
                            {packet, 0},
                            {active, false},
                            {nodelay, true} |
                            ParsedOpts#factory_opts.sockopts],
                case catch gen_tcp:connect(Host, Port, SockOpts,
                                           ParsedOpts#factory_opts.connect_timeout) of
                    {ok, Sock} ->
                        {ok, Transport} = thrift_socket_transport:new(Sock),
                        {ok, BufTransport} =
                            case ParsedOpts#factory_opts.framed of
                                true  -> thrift_framed_transport:new(Transport);
                                false -> thrift_buffered_transport:new(Transport)
                            end,
                        {ok, BufTransport};
                    Error  ->
                        Error
                end
        end,
    {ok, F}.
