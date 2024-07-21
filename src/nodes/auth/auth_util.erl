%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-10-1
%% Description: TODO: Add description to auth_util
-module(auth_util).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([escape_uri/1,binary_to_hexstring/1]).

%%
%% API Functions
%%

%%
%% Local Functions
%%

escape_uri(S) when is_list(S) ->
    escape_uri(unicode:characters_to_binary(S));
escape_uri(<<C:8, Cs/binary>>) when C >= $a, C =< $z ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C >= $A, C =< $Z ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C >= $0, C =< $9 ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C == $. ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C == $- ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C == $_ ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) ->
    escape_byte(C) ++ escape_uri(Cs);
escape_uri(<<>>) ->
    "".

escape_byte(C) ->
    "%" ++ hex_octet(C).

hex_octet(N) when N =< 9 ->
    [$0 + N];
hex_octet(N) when N > 15 ->
    hex_octet(N bsr 4) ++ hex_octet(N band 15);
hex_octet(N) ->
    [N - 10 + $A].

binary_to_hexstring(<<>>)->
	"";
binary_to_hexstring(Bin) when is_binary(Bin)->
	<<Byte:8,LefBin/binary>> = Bin,
	integer_to_hexstring(Byte) ++ binary_to_hexstring(LefBin);
binary_to_hexstring(_)->
	"".

integer_to_hexstring(Byte)->
	Str = erlang:integer_to_list(Byte,16),
	case length(Str) of
		1-> "0"++ Str;
		_-> Str
	end.